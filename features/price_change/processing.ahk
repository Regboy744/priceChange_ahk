#Requires AutoHotkey >=v2.0

; ============================================================================
; PRICE CHANGE — SINGLE-ITEM PROCESSING
; Automates one row of the price-change workflow inside the GOLD window.
; Called in a loop by the GUI's OnStartAutomation handler.
;
; Dependencies (provided by the includer — main.ahk):
;   CONFIG, StartDateEdit, EndDateEdit,
;   LogInfo, UpdateStatus,
;   WaitIfPaused,
;   SetStartDate, EnterArticleCode, EnterNewPrice, SetEndDate,
;   SaveNewPrice, ClickAt, WaitForGoldSpinnerToFinish
; ============================================================================

/**
 * Process a single price-change row.
 * 
 * @param item   Object with .ean and .price
 * @param index  1-based position in the batch
 * @param total  Total items in the batch
 * @returns true on success
 */
ProcessSinglePriceChangeFromGui(item, index, total) {
    global CONFIG, StartDateEdit, EndDateEdit, ReasonCodeDDL

    WaitIfPaused()

    LogInfo("Processing item " . index . "/" . total)
    UpdateStatus("Processing: " . item.ean . " → " . item.price)

    ; Get dates from GUI inputs
    startDate := (StartDateEdit != "") ? StartDateEdit.Text : ""
    endDate := (EndDateEdit != "") ? EndDateEdit.Text : ""

    ; Step 1: Set start date (first item only)
    if (index == 1 && !SetStartDate(startDate))
        return false
    Sleep(CONFIG.DELAYS.MEDIUM)
    WaitIfPaused()

    ; Step 2: Enter article code and search
    if (!EnterArticleCode(item.ean))
        return false
    WaitIfPaused()
    if (!WaitForGoldSpinnerToFinish())
        return false
    WaitIfPaused()

    ; Step 3: Enter new price
    if (!EnterNewPrice(item.price))
        return false
    WaitIfPaused()

    ; Step 4: Set end date (if specified)
    if (!SetEndDate(endDate))
        return false
    Sleep(CONFIG.DELAYS.MEDIUM)
    WaitIfPaused()

    ; Step 5: Set Reason Code (if specified)
    reasonCodes := [0, 1, 2, 900]
    selectedIndex := (ReasonCodeDDL != "") ? ReasonCodeDDL.Value : 1
    reasonCode := reasonCodes[selectedIndex]
    if (reasonCode == 0)
        reasonCode := ""  ; 0 = "Do not copy" → skip
    if (!SetReasonCode(reasonCode))
        return false
    Sleep(CONFIG.DELAYS.MEDIUM)
    WaitIfPaused()

    ; Step 6: Save the change
    if (!SaveNewPrice())
        return false
    Sleep(CONFIG.DELAYS.PAGE_LOAD)
    WaitIfPaused()

    ; Step 7: Close "Till download lot number" OK button
    if (!ClickAt(134, 90))
        return false
    Sleep(CONFIG.DELAYS.PAGE_LOAD)
    WaitIfPaused()

    ; Step 8: Close "Immediate Till Download" without downloading
    if (!ClickAt(230, 123))
        return false
    Sleep(CONFIG.DELAYS.PAGE_LOAD)

    LogInfo("Successfully processed item " . index)
    return true
}
