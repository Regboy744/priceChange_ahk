#Requires AutoHotkey >=v2.0

; ============================================================================
; UNLINK PRODUCTS — SINGLE-ITEM PROCESSING
; Automates one EAN through the unlink workflow inside the GOLD window.
; Called in a loop by the GUI's OnStartUnlink handler.
;
; Dependencies (provided by the includer — main.ahk):
;   CONFIG,
;   LogInfo, LogDebug, LogWarn, LogError, UpdateStatus,
;   WaitIfPaused, EnsureGoldFocus, DismissGoldDialogIfPresent,
;   SetFieldValue, ClickAt, DoubleClickAt, WaitForGoldSpinnerToFinish,
;   WaitForColorToAppear, IsCheckboxChecked,
;   WaitForGoldDialog, WaitForGoldDialogToClose
; ============================================================================

/**
 * Process a single unlink row.
 *
 * @param item   Object with .ean (and optional .row)
 * @param index  1-based position in the batch
 * @param total  Total items in the batch
 * @returns "success", "not_found", or "error"
 */
ProcessSingleUnlink(item, index, total) {
    global CONFIG

    WaitIfPaused()

    LogInfo("Unlink: processing item " . index . "/" . total . " (EAN " . item.ean . ")")
    UpdateStatus("Unlinking: " . item.ean)

    ; ── Pre-flight: focus + clear any stale modal ─────────────────────────
    focusResult := EnsureGoldFocus()
    if (focusResult == -1) {
        LogError("Unlink: could not focus GOLD for " . item.ean)
        UpdateStatus("❌ Could not focus GOLD for " . item.ean)
        return "error"
    }
    DismissGoldDialogIfPresent()
    WaitIfPaused()

    ; ── Step 1 + 2: click EAN field, paste the code ───────────────────────
    eanField := CONFIG.COORDS.UNLINK.EAN_FIELD
    if (!SetFieldValue(eanField.x, eanField.y, item.ean)) {
        LogError("Unlink: could not enter EAN " . item.ean)
        UpdateStatus("❌ Could not enter EAN " . item.ean)
        return "error"
    }
    WaitIfPaused()

    ; ── Step 3: trigger search and wait for the spinner to settle ─────────
    try {
        Send("!t")
    } catch as e {
        LogError("Unlink: Alt+T send failed for " . item.ean . ": " . e.Message)
        return "error"
    }
    if (!WaitForGoldSpinnerToFinish())
        return "error"
    WaitIfPaused()

    ; ── Step 4: click the product row to open the detail screen ──────────
    ; We intentionally do NOT gate the click on the CCCCFF colour check —
    ; the exact highlight tint varies with Citrix rendering, so polling for
    ; an exact match was timing out and dropping us into the "not found"
    ; branch even when the row was clearly there.  We sample the pixel
    ; once for the log (useful when tuning) and rely on the dialog check
    ; for the real not-found signal.
    productRow := CONFIG.COORDS.UNLINK.PRODUCT_ROW

    Sleep(CONFIG.DELAYS.SHORT)   ; grace period for results to render

    try {
        sampledColor := PixelGetColor(productRow.x, productRow.y)
        LogDebug("Step 4: pixel at product row = " . StrUpper(SubStr(sampledColor, 3))
            . " (reference " . CONFIG.COLORS.PRODUCT_ROW_SELECTED . ")")
    } catch as e {
        LogWarn("Step 4: PixelGetColor failed at product row: " . e.Message)
    }

    ; If GOLD raised a not-found / error modal during the search, handle it
    ; here before clicking — the click would otherwise miss the row.
    dismissed := DismissGoldDialogIfPresent()
    if (dismissed == 1) {
        LogWarn("Unlink: not-found dialog dismissed for " . item.ean)
        UpdateStatus("⚠️ Not found: " . item.ean)
        return "not_found"
    }
    if (dismissed == -1) {
        LogError("Unlink: could not dismiss blocking dialog before row click for " . item.ean)
        return "error"
    }

    ; Product rows open their detail screen on double-click, not single click.
    if (!DoubleClickAt(productRow.x, productRow.y))
        return "error"
    Sleep(CONFIG.DELAYS.PAGE_LOAD)   ; let the detail screen render
    WaitIfPaused()

    ; ── Step 5: open the Label_scales tab ─────────────────────────────────
    labelScalesTab := CONFIG.COORDS.UNLINK.LABEL_SCALES_TAB
    if (!ClickAt(labelScalesTab.x, labelScalesTab.y))
        return "error"
    Sleep(CONFIG.DELAYS.PAGE_LOAD)
    WaitIfPaused()

    ; ── Step 6: uncheck Scale download first, then Printable ─────────────
    ; Order matters: clicking Scale download can briefly redraw the panel,
    ; so we click it first, wait LONG for the UI to settle, then handle
    ; Printable.
    if (!ToggleOffIfChecked(CONFIG.COORDS.UNLINK.SCALE_DOWNLOAD_CHK, "Scale download"))
        return "error"
    Sleep(CONFIG.DELAYS.LONG)
    WaitIfPaused()
    if (!ToggleOffIfChecked(CONFIG.COORDS.UNLINK.PRINTABLE_CHK, "Printable"))
        return "error"
    WaitIfPaused()

    ; ── Step 7: send Alt+C to validate, then confirm the save dialog ──────
    ; Pressing Alt+C tells GOLD to validate/save the changes.  A modal
    ; titled "G.O.L.D. - ARTICLE / SITE DATA MANAGEMENT - <date> - \\Remote"
    ; pops up; we click OK at the known coord, then wait for it to close
    ; before letting the outer loop move on to the next EAN.
    try {
        Send("!c")
    } catch as e {
        LogError("Unlink: Alt+C send failed for " . item.ean . ": " . e.Message)
        UpdateStatus("❌ Validate (Alt+C) failed for " . item.ean)
        return "error"
    }

    confirmTitle := "G.O.L.D. - ARTICLE / SITE DATA MANAGEMENT"
    confirmHwnd := WaitForGoldDialog(CONFIG.DELAYS.SEARCH_WAIT, 200, confirmTitle)
    if (!confirmHwnd) {
        LogError("Unlink: validation dialog never appeared for " . item.ean)
        UpdateStatus("❌ Validate dialog missing for " . item.ean)
        return "error"
    }

    okCoord := CONFIG.COORDS.UNLINK.CONFIRM_OK
    try WinActivate("ahk_id " . confirmHwnd)
    Sleep(CONFIG.DELAYS.SHORT)
    if (!ClickAt(okCoord.x, okCoord.y)) {
        LogError("Unlink: failed to click OK on validation dialog for " . item.ean)
        UpdateStatus("❌ Could not click OK for " . item.ean)
        return "error"
    }

    if (!WaitForGoldDialogToClose(confirmHwnd, CONFIG.DELAYS.SEARCH_WAIT)) {
        LogError("Unlink: validation dialog did not close for " . item.ean)
        UpdateStatus("❌ Validate dialog stuck for " . item.ean)
        return "error"
    }
    LogDebug("Unlink: validation dialog acknowledged for " . item.ean)

    LogInfo("Unlink: successfully processed item " . index . " (" . item.ean . ")")
    return "success"
}

/**
 * Toggle a checkbox to "unchecked" — but only if it is currently checked.
 *
 * Coords with x=0 and y=0 are treated as "not configured yet" and the call
 * is skipped with a warning instead of clicking at the origin (which could
 * trigger unexpected GOLD behaviour).
 *
 * @param coords  { x, y } click point inside the checkbox
 * @param label   Human-readable name for log / status messages
 * @returns true on success (including no-op), false if the click failed
 */
ToggleOffIfChecked(coords, label) {
    global CONFIG

    if (coords.x == 0 && coords.y == 0) {
        LogWarn("Unlink: '" . label . "' coordinates are not configured — skipping")
        UpdateStatus("⚠️ '" . label . "' coords not set — skipping")
        return true
    }

    if (!IsCheckboxChecked(coords.x, coords.y)) {
        LogDebug("Unlink: '" . label . "' is already empty — no action")
        return true
    }

    if (!ClickAt(coords.x, coords.y)) {
        LogError("Unlink: failed to click '" . label . "' to uncheck")
        UpdateStatus("❌ Could not uncheck '" . label . "'")
        return false
    }
    LogInfo("Unlink: unchecked '" . label . "'")
    Sleep(CONFIG.DELAYS.SHORT)
    return true
}
