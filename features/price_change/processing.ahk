#Requires AutoHotkey >=v2.0

; ============================================================================
; PRICE CHANGE — SINGLE-ITEM PROCESSING
; Automates one row of the price-change workflow inside the GOLD window.
; Called in a loop by the GUI's OnStartAutomation handler.
;
; Dependencies (provided by the includer — main.ahk):
;   CONFIG, StartDateEdit, EndDateEdit,
;   LogInfo, LogWarn, LogError, UpdateStatus,
;   WaitIfPaused,
;   SetStartDate, EnterArticleCode, EnterNewPrice, SetEndDate,
;   SaveNewPrice, ClickAt, WaitForGoldSpinnerToFinish,
;   DismissGoldDialogIfPresent, ActivateTargetWindow
; ============================================================================

/**
 * Process a single price-change row.
 * 
 * @param item   Object with .ean and .price
 * @param index  1-based position in the batch
 * @param total  Total items in the batch
 * @returns "success", "not_found", or "error"
 */
ProcessSinglePriceChangeFromGui(item, index, total) {
    global CONFIG, StartDateEdit, EndDateEdit, ReasonCodeDDL

    WaitIfPaused()

    LogInfo("Processing item " . index . "/" . total)
    UpdateStatus("Processing: " . item.ean . " → " . item.price)

    ; Clear any leftover modal so one bad item does not poison the next one.
    if (!ClearPriceChangeDialogIfPresent(item.ean, index))
        return "error"

    ; Get dates from GUI inputs
    startDate := (StartDateEdit != "") ? StartDateEdit.Text : ""
    endDate := (EndDateEdit != "") ? EndDateEdit.Text : ""

    ; Step 1: Set start date (first item only). SetStartDate already settles internally.
    if (index == 1 && !SetStartDate(startDate))
        return "error"
    WaitIfPaused()

    ; Step 2: Enter article code and search
    if (!EnterArticleCode(item.ean))
        return "error"
    WaitIfPaused()
    if (!WaitForGoldSpinnerToFinish())
        return "error"
    WaitIfPaused()

    searchOutcome := HandlePriceChangeSearchDialog(item)
    if (searchOutcome != "clear")
        return searchOutcome

    ; Step 3: Enter new price
    if (!EnterNewPrice(item.price)) {
        ; The not-found popup can appear slightly late, just as price entry starts.
        lateSearchOutcome := HandlePriceChangeSearchDialog(item, 0, 0)
        if (lateSearchOutcome != "clear")
            return lateSearchOutcome
        return "error"
    }
    WaitIfPaused()

    ; Step 4: Set end date (if specified). SetEndDate already settles internally.
    if (!SetEndDate(endDate))
        return "error"
    WaitIfPaused()

    ; Step 5: Set Reason Code (if specified)
    reasonCodes := [0, 1, 2, 900]
    selectedIndex := (ReasonCodeDDL != "") ? ReasonCodeDDL.Value : 1
    reasonCode := reasonCodes[selectedIndex]
    if (reasonCode == 0)
        reasonCode := ""  ; 0 = "Do not copy" → skip
    if (!SetReasonCode(reasonCode))
        return "error"
    WaitIfPaused()

    ; Step 6: Save the change. SaveNewPrice already waits PAGE_LOAD;
    ; Step 7's WaitForGoldDialog will then poll for the next modal.
    if (!SaveNewPrice())
        return "error"
    WaitIfPaused()

    ; Step 7: Wait for "Till download lot number", click OK, then confirm it closed
    lotDlgHwnd := WaitForGoldDialog()
    if (!lotDlgHwnd) {
        LogError("Till download lot number dialog never appeared for " . item.ean)
        UpdateStatus("❌ Lot number dialog missing for " . item.ean)
        return "error"
    }
    try WinActivate("ahk_id " . lotDlgHwnd)
    Sleep(CONFIG.DELAYS.SHORT)
    if (!ClickAt(134, 90))
        return "error"
    if (!WaitForGoldDialogToClose(lotDlgHwnd)) {
        LogError("Till download lot number dialog did not close for " . item.ean)
        UpdateStatus("❌ Lot number dialog still open for " . item.ean)
        return "error"
    }
    WaitIfPaused()

    ; Step 8: Wait for "Immediate Till Download", click Close, confirm it closed.
    ; If the pixel click is swallowed by Citrix focus issues, escalate to
    ; WM_CLOSE then WinKill so the modal never lingers across iterations.
    ; The item still reports as "error" on the recovery paths — the goal of the
    ; fallback is solely to keep the workflow from accumulating dead windows.
    tillDlgHwnd := WaitForGoldDialog(, , "IMMEDIATE TILL DOWNLOAD")
    if (!tillDlgHwnd) {
        LogError("Immediate Till Download dialog never appeared for " . item.ean)
        UpdateStatus("❌ Till download dialog missing for " . item.ean)
        return "error"
    }

    try WinActivate("ahk_id " . tillDlgHwnd)
    Sleep(CONFIG.DELAYS.SHORT)
    ClickAt(230, 123)

    if (!WaitForGoldDialogToClose(tillDlgHwnd, 1500)) {
        LogWarn("Click on Close did not close IMMEDIATE TILL DOWNLOAD for "
            . item.ean . " — escalating to WinClose")
        try WinClose("ahk_id " . tillDlgHwnd, , 2)

        if (WinExist("ahk_id " . tillDlgHwnd)) {
            LogWarn("WinClose did not close IMMEDIATE TILL DOWNLOAD for "
                . item.ean . " — escalating to WinKill")
            try WinKill("ahk_id " . tillDlgHwnd, , 2)
        }

        if (WinExist("ahk_id " . tillDlgHwnd)) {
            LogError("Could not close IMMEDIATE TILL DOWNLOAD for " . item.ean
                . " — modal still open")
            UpdateStatus("❌ Till download dialog STUCK for " . item.ean)
            return "error"
        }

        LogInfo("Force-closed IMMEDIATE TILL DOWNLOAD for " . item.ean
            . " — item reported as error to flag the missed confirmation")
        UpdateStatus("⚠️ Recovered Till download dialog: " . item.ean)
        return "error"
    }

    LogInfo("Successfully processed item " . index)
    return "success"
}

ClearPriceChangeDialogIfPresent(eanCode, index) {
    global CONFIG

    ; Safety net: if a prior item's Step 8 left an IMMEDIATE TILL DOWNLOAD modal
    ; open, sweep it before anything else. DismissGoldDialogIfPresent below
    ; matches a different title pattern and would not catch it.
    staleTillHwnd := FindGoldWindow("IMMEDIATE TILL DOWNLOAD")
    if (staleTillHwnd) {
        LogWarn("Found stale IMMEDIATE TILL DOWNLOAD before item " . index
            . " (" . eanCode . ") — closing via WinClose")
        try WinClose("ahk_id " . staleTillHwnd, , 2)
        if (WinExist("ahk_id " . staleTillHwnd))
            try WinKill("ahk_id " . staleTillHwnd, , 2)
        if (WinExist("ahk_id " . staleTillHwnd)) {
            LogError("Could not clear stale IMMEDIATE TILL DOWNLOAD before "
                . eanCode)
            UpdateStatus("❌ Stale Till download dialog stuck before " . eanCode)
            return false
        }
        Sleep(CONFIG.DELAYS.MEDIUM)
        ActivateTargetWindow()
        Sleep(CONFIG.DELAYS.MEDIUM)
    }

    coords := CONFIG.COORDS.PRICE_CHANGE_DIALOG_OK
    dismissResult := DismissGoldDialogIfPresent(, coords.x, coords.y)

    if (dismissResult == -1) {
        LogError("Failed to dismiss stale GOLD dialog before item "
            . index . " (" . eanCode . ")")
        UpdateStatus("❌ Could not clear GOLD popup before " . eanCode)
        return false
    }

    if (dismissResult == 1) {
        LogWarn("Cleared stale GOLD dialog before processing article " . eanCode)
        Sleep(CONFIG.DELAYS.MEDIUM)
        if (!ActivateTargetWindow()) {
            LogError("Failed to reactivate GOLD after clearing stale dialog for "
                . eanCode)
            UpdateStatus("❌ Could not reactivate GOLD after clearing popup")
            return false
        }
        Sleep(CONFIG.DELAYS.MEDIUM)
    }

    return true
}

HandlePriceChangeSearchDialog(item, pollTimeout := 1200, pollInterval := 200) {
    global CONFIG

    coords := CONFIG.COORDS.PRICE_CHANGE_DIALOG_OK
    startTime := A_TickCount

    loop {
        WaitIfPaused()

        dismissResult := DismissGoldDialogIfPresent(, coords.x, coords.y)
        if (dismissResult == -1) {
            LogError("Could not close GOLD not-found popup for article " . item.ean)
            UpdateStatus("❌ Could not close GOLD popup for " . item.ean)
            return "error"
        }

        if (dismissResult == 1) {
            LogWarn("Article not found in GOLD — skipping " . item.ean)
            UpdateStatus("⚠️ Not found in GOLD: " . item.ean . " — continuing")

            Sleep(CONFIG.DELAYS.MEDIUM)
            if (!ActivateTargetWindow()) {
                LogError("Failed to reactivate GOLD after not-found popup for "
                    . item.ean)
                UpdateStatus("❌ Could not reactivate GOLD after popup")
                return "error"
            }
            Sleep(CONFIG.DELAYS.LONG)
            return "not_found"
        }

        if (A_TickCount - startTime >= pollTimeout)
            break

        Sleep(Max(pollInterval, 1))
    }

    return "clear"
}