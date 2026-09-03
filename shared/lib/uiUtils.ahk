#Requires AutoHotkey >=v2.0

; ============================================================================
; UI UTILITIES
; Functions for GOLD UI automation: clicking, typing, clipboard, window
; management, overlay, and pixel-color polling.
; ============================================================================

; ── Global pause flag ─────────────────────────────────────────────────────
global IsPaused := false

; ── Pause control ─────────────────────────────────────────────────────────

/** Toggle pause state. Bind to a hotkey in the entry script. */
TogglePause() {
    global IsPaused
    if (IsPaused) {
        IsPaused := false
        ToolTip("▶ Resumed")
        SetTimer(() => ToolTip(), -1500)
    } else {
        IsPaused := true
        ToolTip("⏸ Paused – press F4 again to resume")
    }
}

/** Block execution while IsPaused is true. Call at every loop checkpoint. */
WaitIfPaused() {
    global IsPaused
    while (IsPaused)
        Sleep(200)
}

; ── Click / Type helpers ──────────────────────────────────────────────────

/**
 * Click at screen coordinates.
 * @returns true on success
 */
ClickAt(x, y) {
    global CONFIG
    try {
        Click(x, y, "Down")
        Sleep 100
        Click(x, y, "Up")
        Sleep(CONFIG.DELAYS.SHORT)
        LogDebug("Clicked at (" . x . "," . y . ")")
        return true
    } catch as e {
        LogError("Failed to click at (" . x . "," . y . "): " . e.Message)
        return false
    }
}

/**
 * Double-click at screen coordinates. Use for list rows / icons that only
 * react to a double-click (e.g. opening a product from a search result).
 * @returns true on success
 */
DoubleClickAt(x, y) {
    global CONFIG
    try {
        Click(x, y, 2)
        Sleep(CONFIG.DELAYS.SHORT)
        LogDebug("Double-clicked at (" . x . "," . y . ")")
        return true
    } catch as e {
        LogError("Failed to double-click at (" . x . "," . y . "): " . e.Message)
        return false
    }
}

/**
 * Click a field and paste a value via clipboard.
 */
SetFieldValue(x, y, value) {
    global CONFIG
    savedClipboard := ""
    clipboardBackedUp := false

    try {
        savedClipboard := ClipboardAll()
        clipboardBackedUp := true
    } catch as e {
        LogWarn("Failed to back up clipboard before setting field at ("
            . x . "," . y . "): " . e.Message)
    }

    try {
        Click(x, y)
        Sleep(CONFIG.DELAYS.SHORT)
        Send("^a")
        Sleep(CONFIG.DELAYS.TINY)
        A_Clipboard := ""
        Sleep(CONFIG.DELAYS.TINY)
        A_Clipboard := value
        if (!ClipWait(1))
            LogWarn("Clipboard update timed out before pasting field value at ("
                . x . "," . y . ")")
        Send("^v")
        Sleep(CONFIG.DELAYS.MEDIUM)
        LogDebug("Set field value at (" . x . "," . y . "): " . value)
        return true
    } catch as e {
        LogError("Failed to set field value: " . e.Message)
        return false
    } finally {
        if (clipboardBackedUp) {
            try A_Clipboard := savedClipboard
            catch as e {
                LogWarn("Failed to restore clipboard after setting field at ("
                    . x . "," . y . "): " . e.Message)
            }
        }
    }
}

/**
 * Click at coordinates, select all, then optionally type text.
 * Legacy name: clickSomething() — now ClickAndType().
 */
ClickAndType(x, y, value := "") {
    global CONFIG
    Click(x, y)
    Sleep(CONFIG.DELAYS.TINY)
    Send("^a")
    Sleep(300)
    Send("{Delete}")
    Sleep(CONFIG.DELAYS.SHORT)

    if (value != "") {
        SendText(value)
        LogDebug("Clicked and typed at (" . x . "," . y . "): " . value)
    } else {
        LogDebug("Clicked at (" . x . "," . y . ")")
    }
}

/**
 * Re-focus a field in GOLD, clear any existing text, then type a replacement.
 * Extra click/settle time helps when Citrix lags behind the automation.
 */
FocusAndReplaceField(x, y, value, settleDelay := 0) {
    global CONFIG

    try {
        focusResult := EnsureGoldFocus()
        if (focusResult == 2) {
            LogError("GOLD dialog blocked field input at (" . x . "," . y . ")")
            return false
        }
        if (focusResult == -1) {
            LogError("Could not focus GOLD before field input at (" . x . "," . y . ")")
            return false
        }

        Click(x, y)
        Sleep(CONFIG.DELAYS.SHORT)
        Click(x, y)
        Sleep(settleDelay ? settleDelay : CONFIG.DELAYS.SHORT)
        Send("^a")
        Sleep(CONFIG.DELAYS.SHORT)
        Send("{Delete}")
        Sleep(CONFIG.DELAYS.SHORT)
        SendText(value)
        Sleep(CONFIG.DELAYS.MEDIUM)
        LogDebug("Focused and replaced field at (" . x . "," . y . "): " . value)
        return true
    } catch as e {
        LogError("Failed to focus and replace field at (" . x . "," . y . "): "
            . e.Message)
        return false
    }
}

; ── GOLD-specific field helpers ───────────────────────────────────────────

/**
 * Set the start-date field in GOLD.
 * @param startDate  "DD/MM/YY" format
 */
SetStartDate(startDate) {
    global CONFIG
    try {
        coords := CONFIG.COORDS.START_DATE
        result := SetFieldValue(coords.x, coords.y, startDate)
        if (result)
            LogInfo("Start date set to: " . startDate)
        return result
    } catch as e {
        LogError("Failed to set start date: " . e.Message)
        ShowError("Failed to set start date: " . e.Message)
        return false
    }
}

/**
 * Set the end-date field (Tab then type). Empty string = skip.
 */
SetEndDate(endDate) {
    global CONFIG

    if (endDate == "") {
        LogDebug("End date is empty, skipping")
        return true
    }

    try {
        Send("{Tab}")
        Sleep(CONFIG.DELAYS.SHORT)
        SendText(endDate)
        Sleep(CONFIG.DELAYS.LONG)
        LogInfo("End date set to: " . endDate)
        return true
    } catch as e {
        LogError("Failed to set end date: " . e.Message)
        return false
    }
}

/**
 * Set the Reason Code field (4 X Tab then type). Empty string = skip.
 */
SetReasonCode(reasonCode) {
    global CONFIG

    if (reasonCode == "") {
        LogDebug("Reason Code is empty, skipping")
        return true
    }

    try {
        Send("{Tab 4}")
        Sleep(CONFIG.DELAYS.SHORT)
        SendText(reasonCode)
        Sleep(CONFIG.DELAYS.LONG)
        LogInfo("Reason Code set to: " . reasonCode)
        return true
    } catch as e {
        LogError("Failed to set Reason Code: " . e.Message)
        return false
    }
}


/**
 * Enter an EAN code and trigger search (Alt+R → type → Alt+T).
 */
EnterArticleCode(eanCode) {
    global CONFIG
    try {
        focusResult := EnsureGoldFocus()
        if (focusResult == 2) {
            LogError("GOLD dialog blocked article-code entry")
            return false
        }
        if (focusResult == -1) {
            LogError("Could not focus GOLD before entering article code")
            return false
        }

        Send("!r")
        Sleep 100
        coords := CONFIG.COORDS.ARTICLE_CODE
        ClickAndType(coords.x, coords.y, eanCode)
        Sleep(CONFIG.DELAYS.LONG)
        Send("!t")
        LogInfo("Searched for article: " . eanCode)
        return true
    } catch as e {
        LogError("Failed to enter article code: " . e.Message)
        return false
    }
}

/**
 * Type a new price into the price field.
 */
EnterNewPrice(newPrice) {
    global CONFIG
    try {
        coords := CONFIG.COORDS.NEW_PRICE
        if (!FocusAndReplaceField(coords.x, coords.y, newPrice, CONFIG.DELAYS.PAGE_LOAD))
            return false
        LogInfo("Entered new price: " . newPrice)
        return true
    } catch as e {
        LogError("Failed to enter new price: " . e.Message)
        return false
    }
}

/**
 * Save the current price entry (Tab → Alt+S).
 */
SaveNewPrice() {
    global CONFIG
    try {
        Send("{Tab}")
        Sleep 100
        Send("!s")
        Sleep(CONFIG.DELAYS.PAGE_LOAD)
        LogInfo("Pressed Alt+S to save the new price")
        return true
    } catch as e {
        LogError("Failed to save new price: " . e.Message)
        return false
    }
}

; ── Window management ─────────────────────────────────────────────────────

/** Bring the GOLD Remote Desktop window to front. */
ActivateTargetWindow() {
    global CONFIG
    try {
        WinActivate(CONFIG.WINDOW_TITLE)
        Sleep(CONFIG.DELAYS.SHORT)
        LogInfo("Activated window: " . CONFIG.WINDOW_TITLE)
        return true
    } catch as e {
        LogError("Failed to activate window: " . e.Message)
        return false
    }
}

/**
 * Find the first top-level GOLD window whose title contains titlePattern.
 * Returns its HWND, or 0 if none was found.
 */
FindGoldWindow(titlePattern := "G.O.L.D. - LOCAL SALES PRICE SIMPLIFIED INPUT -") {
    try {
        for hwnd in WinGetList() {
            try {
                title := WinGetTitle(hwnd)
                if (InStr(title, titlePattern))
                    return hwnd
            }
        }
    } catch as e {
        LogError("FindGoldWindow failed: " . e.Message)
    }

    return 0
}

/**
 * Poll until a GOLD modal dialog whose title contains titlePattern appears.
 * @returns HWND of the dialog, or 0 if it never appeared before the timeout.
 */
WaitForGoldDialog(timeout := 4000, pollInterval := 200, titlePattern := "G.O.L.D. - LOCAL SALES PRICE SIMPLIFIED INPUT -") {
    startTime := A_TickCount
    loop {
        WaitIfPaused()
        hwnd := FindGoldWindow(titlePattern)
        if (hwnd) {
            LogDebug("WaitForGoldDialog: dialog appeared (hwnd=" . hwnd . ")")
            return hwnd
        }
        if (A_TickCount - startTime >= timeout)
            break
        Sleep(Max(pollInterval, 1))
    }

    LogWarn("WaitForGoldDialog: timed out after " . timeout . " ms waiting for '"
        . titlePattern . "'")
    return 0
}

/**
 * Poll until a specific dialog HWND no longer exists.
 * @returns true if the dialog closed before the timeout, false otherwise.
 */
WaitForGoldDialogToClose(hwnd, timeout := 4000, pollInterval := 200) {
    startTime := A_TickCount
    loop {
        WaitIfPaused()
        if (!WinExist("ahk_id " . hwnd)) {
            LogDebug("WaitForGoldDialogToClose: dialog closed (hwnd=" . hwnd . ")")
            return true
        }
        if (A_TickCount - startTime >= timeout)
            break
        Sleep(Max(pollInterval, 1))
    }

    LogWarn("WaitForGoldDialogToClose: hwnd=" . hwnd . " still open after "
        . timeout . " ms")
    return false
}

/**
 * Dismiss a GOLD modal dialog if one is already open.
 * Returns 1 if dismissed, 0 if none was present, -1 if dismissal failed.
 */
DismissGoldDialogIfPresent(titlePattern := "G.O.L.D. - LOCAL SALES PRICE SIMPLIFIED INPUT -", okX := 131, okY := 90) {
    dialogHwnd := FindGoldWindow(titlePattern)
    if (!dialogHwnd)
        return 0

    title := ""
    try title := WinGetTitle("ahk_id " . dialogHwnd)

    try WinActivate("ahk_id " . dialogHwnd)
    Sleep(500)

    ; Try the dialog's default button first, then fall back to the known OK coordinate.
    Send("{Enter}")
    Sleep(500)

    if (FindGoldWindow(titlePattern)) {
        Click(okX, okY)
        Sleep(1000)
    }

    if (FindGoldWindow(titlePattern)) {
        LogError("DismissGoldDialogIfPresent: dialog still present '" . title . "'")
        return -1
    }

    LogDebug("DismissGoldDialogIfPresent: dismissed '" . title . "'")
    return 1
}

/**
 * Ensure the GOLD RDP window is in focus before sending clicks/keys.
 * Re-activates it up to maxRetries times if another window stole focus.
 * @returns 0 = already focused, 1 = recovered focus,
 *          2 = GOLD modal dialog active, -1 = failed
 */
EnsureGoldFocus(maxRetries := 3) {
    global CONFIG
    goldDialogTitle := "G.O.L.D. - LOCAL SALES PRICE SIMPLIFIED INPUT -"
    activeTitle := ""
    loop maxRetries {
        try {
            activeTitle := WinGetTitle("A")
            if (InStr(activeTitle, goldDialogTitle)) {
                LogDebug("EnsureGoldFocus: GOLD dialog active '" . activeTitle . "'")
                return 2
            }
            if (InStr(activeTitle, CONFIG.WINDOW_TITLE)) {
                if (A_Index > 1) {
                    LogDebug("EnsureGoldFocus: recovered on attempt #" . A_Index)
                    return 1   ; focus was lost but recovered
                }
                return 0       ; already focused — no intervention
            }
        }

        LogDebug("EnsureGoldFocus: wrong window '" . activeTitle
            . "', re-activating (" . A_Index . "/" . maxRetries . ")")
        try {
            WinActivate(CONFIG.WINDOW_TITLE)
        }
        Sleep(1500)
    }

    LogError("EnsureGoldFocus: FAILED after " . maxRetries . " attempts")
    return -1
}

/**
 * Check whether the active window title contains titlePattern.
 */
IsGoldWindowActive(titlePattern := "G.O.L.D. - LOCAL SALES PRICE SIMPLIFIED INPUT") {
    try {
        activeTitle := WinGetTitle("A")
        if (InStr(activeTitle, titlePattern)) {
            LogDebug("IsGoldWindowActive: matched active title '" . activeTitle . "'")
            return true
        }

        return false
    } catch as e {
        LogError("Failed to check window: " . e.Message)
        return false
    }
}

; ── Overlay ───────────────────────────────────────────────────────────────
global WarningOverlay := ""
global ProgressOverlay := ""
global ProgressOverlayText := ""

/**
 * Show a modal-style multi-line paste dialog and return the entered text.
 * Pre-fills with the current clipboard text so a "copy → open dialog" flow
 * needs no extra Ctrl+V. Blocks until the user confirms or cancels.
 *
 * @param title         Window caption.
 * @param instructions  Help line shown above the edit box.
 * @param ownerGui       Optional owner Gui object (keeps the dialog on top and
 *                       disables the owner for true modal behaviour).
 * @returns The entered text, or "" if the user cancelled / closed the dialog.
 */
ShowPasteInputDialog(title, instructions, ownerGui := "") {
    dlgResult := ""
    dlgDone := false

    opts := "+AlwaysOnTop +ToolWindow"
    if (ownerGui != "")
        opts .= " +Owner" . ownerGui.Hwnd

    pasteGui := Gui(opts, title)
    pasteGui.BackColor := "F0F4F8"
    pasteGui.SetFont("s9", "Segoe UI")
    pasteGui.Add("Text", "xm ym w400", instructions)

    editCtl := pasteGui.Add("Edit", "xm y+8 w400 r14 +Multi +WantReturn +HScroll")

    ; Prefill from the clipboard so the common copy → paste flow is one click.
    prefill := ""
    try prefill := A_Clipboard
    if (prefill != "")
        editCtl.Value := prefill

    loadBtn := pasteGui.Add("Button", "xm y+10 w120 h30 Default", "✅ Load List")
    loadBtn.OnEvent("Click", OnPasteLoad)
    pasteGui.Add("Button", "x+10 yp w120 h30", "❌ Cancel").OnEvent("Click", OnPasteCancel)
    pasteGui.OnEvent("Close", OnPasteCancel)
    pasteGui.OnEvent("Escape", OnPasteCancel)

    if (ownerGui != "")
        ownerGui.Opt("+Disabled")

    pasteGui.Show("AutoSize Center")

    ; Focus + select-all only after the dialog is visible, so the keystroke
    ; lands in this edit box (not whatever had focus before Show).
    editCtl.Focus()
    if (prefill != "")
        Send("^a")

    while (!dlgDone)
        Sleep(30)

    if (ownerGui != "")
        ownerGui.Opt("-Disabled")

    return dlgResult

    OnPasteLoad(*) {
        dlgResult := editCtl.Value
        dlgDone := true
        pasteGui.Destroy()
    }
    OnPasteCancel(*) {
        dlgResult := ""
        dlgDone := true
        pasteGui.Destroy()
    }
}

/** Show a full-width red "AUTOMATION IN PROGRESS" banner at the top of the screen. */
ShowWorkingOverlay() {
    global WarningOverlay

    WarningOverlay := Gui("+AlwaysOnTop -Caption +ToolWindow")
    WarningOverlay.BackColor := "FF0000"
    WarningOverlay.SetFont("s24 bold", "Arial")
    WarningOverlay.Add("Text", "cWhite Center w" . A_ScreenWidth,
        "⚠️ AUTOMATION IN PROGRESS ⚠️`n`nDO NOT USE MOUSE OR KEYBOARD`n`nPress ESC to abort")

    WarningOverlay.Opt("+E0x20")            ; Click-through
    WinSetTransparent(180, WarningOverlay)

    WarningOverlay.Show("x0 y0 w" . A_ScreenWidth . " h150 NoActivate")
}

/** Remove the warning overlay (safe to call when not showing). */
HideWorkingOverlay() {
    global WarningOverlay
    if (WarningOverlay != "") {
        WarningOverlay.Destroy()
        WarningOverlay := ""
    }
}

/**
 * Show (or update) a click-through progress bar pinned to the bottom of the screen.
 * Safe to call repeatedly — the first call creates the GUI, subsequent calls
 * just update the text without flicker.
 */
ShowProgressOverlay(text) {
    global ProgressOverlay, ProgressOverlayText

    overlayH := 80
    yPos := A_ScreenHeight - overlayH

    if (ProgressOverlay == "") {
        ProgressOverlay := Gui("+AlwaysOnTop -Caption +ToolWindow")
        ProgressOverlay.BackColor := "1a1a2e"
        ProgressOverlay.SetFont("s14 bold", "Arial")
        ProgressOverlayText := ProgressOverlay.Add("Text",
            "cWhite Center w" . A_ScreenWidth . " h" . overlayH, text)

        ProgressOverlay.Opt("+E0x20")           ; Click-through
        WinSetTransparent(200, ProgressOverlay)

        ProgressOverlay.Show("x0 y" . yPos . " w" . A_ScreenWidth
            . " h" . overlayH . " NoActivate")
    } else {
        ProgressOverlayText.Value := text
    }
}

/** Remove the progress overlay (safe to call when not showing). */
HideProgressOverlay() {
    global ProgressOverlay, ProgressOverlayText
    if (ProgressOverlay != "") {
        ProgressOverlay.Destroy()
        ProgressOverlay := ""
        ProgressOverlayText := ""
    }
}

; ============================================================================
; PIXEL-COLOR POLLING
; Wait for loading spinners / UI elements by monitoring a single pixel.
; ============================================================================

/**
 * Wait for a colour to DISAPPEAR at (x, y).
 * Typical use: wait for a loading spinner to finish.
 * 
 * @param targetColor  Hex without "0x" prefix, e.g. "CCCCCC"
 * @param timeout      Milliseconds (default 30 000)
 * @param checkInterval  Polling interval ms (default 100)
 * @returns true if colour disappeared before timeout
 */
WaitForColorToDisappear(x, y, targetColor, timeout := 30000, checkInterval := 100) {
    if (SubStr(targetColor, 1, 2) == "0x")
        targetColor := SubStr(targetColor, 3)
    targetColor := StrUpper(targetColor)

    LogDebug("Waiting for color " . targetColor . " to disappear at (" . x . "," . y . ")")
    startTime := A_TickCount

    while (A_TickCount - startTime < timeout) {
        try {
            currentColor := PixelGetColor(x, y)
            currentColorHex := StrUpper(SubStr(currentColor, 3))

            if (currentColorHex != targetColor) {
                LogDebug("Color changed from " . targetColor . " to " . currentColorHex . " — loading complete")
                SoundBeep(1000, 200)
                SoundBeep(1500, 200)
                Sleep(200)
                return true
            }
        } catch as e {
            LogError("PixelGetColor failed: " . e.Message)
        }
        Sleep(checkInterval)
    }

    LogError("Timeout waiting for color to disappear at (" . x . "," . y . ")")
    return false
}

/**
 * Wait for a colour to APPEAR at (x, y). Inverse of WaitForColorToDisappear.
 * Typical use: wait for a list row to highlight before clicking it.
 *
 * @param targetColor    Hex without "0x" prefix, e.g. "CCCCFF"
 * @param timeout        Milliseconds (default 4000)
 * @param checkInterval  Polling interval ms (default 100)
 * @returns true if the colour appeared before timeout, false otherwise
 */
WaitForColorToAppear(x, y, targetColor, timeout := 4000, checkInterval := 100) {
    if (SubStr(targetColor, 1, 2) == "0x")
        targetColor := SubStr(targetColor, 3)
    targetColor := StrUpper(targetColor)

    LogDebug("Waiting for color " . targetColor . " to appear at (" . x . "," . y . ")")
    startTime := A_TickCount

    while (A_TickCount - startTime < timeout) {
        try {
            currentColor := PixelGetColor(x, y)
            currentColorHex := StrUpper(SubStr(currentColor, 3))

            if (currentColorHex == targetColor) {
                LogDebug("Color " . targetColor . " appeared at (" . x . "," . y . ")")
                return true
            }
        } catch as e {
            LogError("PixelGetColor failed at (" . x . "," . y . "): " . e.Message)
        }
        Sleep(checkInterval)
    }

    LogWarn("Timeout waiting for color " . targetColor . " at (" . x . "," . y . ")")
    return false
}

/**
 * Decide whether a checkbox is currently checked by scanning a small ROI
 * around (cx, cy) for any near-black pixel (the glyph stroke).
 *
 * Why a region scan rather than a single PixelGetColor:
 *   - GOLD's row striping shifts the empty-box background between products
 *     (e.g. D2EDED vs CFEBEB vs E6E6E6), so an exact `!= emptyBg` check
 *     produced false positives on every alternate row.
 *   - The checkmark glyph is ~1-2 px thick — a single sample can miss the
 *     stroke and report false negative.
 * Scanning a small radius for ANY dark pixel is robust to both.
 *
 * @param cx, cy         Centre of the checkbox interior
 * @param radius         Half-size of the scan square in px (default 5 -> 11x11)
 * @param darkThreshold  Max R, G AND B value considered "dark" (default 80)
 * @returns true if any pixel in the region is dark enough to be the glyph
 */
IsCheckboxChecked(cx, cy, radius := 5, darkThreshold := 80) {
    try {
        minBright := 999
        loop radius * 2 + 1 {
            py := cy - radius + A_Index - 1
            loop radius * 2 + 1 {
                px := cx - radius + A_Index - 1
                c := PixelGetColor(px, py)
                r := (c >> 16) & 0xFF
                g := (c >>  8) & 0xFF
                b :=  c        & 0xFF
                bright := (r + g + b) // 3
                if (bright < minBright)
                    minBright := bright
                if (r < darkThreshold && g < darkThreshold && b < darkThreshold) {
                    LogDebug("IsCheckboxChecked(" . cx . "," . cy . "): glyph hit at ("
                        . px . "," . py . ") rgb=(" . r . "," . g . "," . b . ") -> CHECKED")
                    return true
                }
            }
        }
        LogDebug("IsCheckboxChecked(" . cx . "," . cy . "): no dark pixels in "
            . (radius * 2 + 1) . "x" . (radius * 2 + 1) . " region (min bright="
            . minBright . ") -> empty")
        return false
    } catch as e {
        ; Treat read failures as "empty" so the caller does not blindly click
        ; and accidentally re-CHECK a checkbox we cannot read.
        LogError("IsCheckboxChecked failed at (" . cx . "," . cy . "): " . e.Message)
        return false
    }
}

/**
 * Wait for the GOLD spinner to finish.
 * Gives the spinner a brief chance to appear so callers do not race it.
 *
 * @param timeout        Milliseconds to wait for spinner completion
 * @param checkInterval  Polling interval ms
 * @param appearTimeout  Milliseconds to wait for spinner to appear first
 * @returns true if the spinner finished or never appeared
 */
WaitForGoldSpinnerToFinish(timeout := 1800000, checkInterval := 200, appearTimeout := 1000) {
    spinnerX := 623
    spinnerY := 653
    spinnerColor := "CCCCCC"

    LogDebug("Waiting for GOLD spinner to finish at (" . spinnerX . "," . spinnerY . ")")
    appearStart := A_TickCount

    while (A_TickCount - appearStart < appearTimeout) {
        try {
            currentColor := PixelGetColor(spinnerX, spinnerY)
            currentColorHex := StrUpper(SubStr(currentColor, 3))

            if (currentColorHex == spinnerColor)
                return WaitForColorToDisappear(spinnerX, spinnerY, spinnerColor, timeout, checkInterval)
        } catch as e {
            LogError("PixelGetColor failed while waiting for GOLD spinner: " . e.Message)
        }
        Sleep(checkInterval)
    }

    LogDebug("GOLD spinner did not appear within " . appearTimeout . " ms — continuing")
    return true
}
