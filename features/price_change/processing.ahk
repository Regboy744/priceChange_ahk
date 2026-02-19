#Requires AutoHotkey >=v2.0

; ============================================================================
; PRICE CHANGE — SINGLE-ITEM PROCESSING
; Automates one row of the price-change workflow inside the GOLD window.
; Called in a loop by the GUI's OnStartAutomation handler.
;
; Dependencies (provided by the includer — main.ahk):
;   CONFIG, StartDateEdit, EndDateEdit,
;   LogInfo, UpdateStatus,
;   SetStartDate, EnterArticleCode, EnterNewPrice, SetEndDate,
;   SaveNewPrice, ClickAt
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
    global CONFIG, StartDateEdit, EndDateEdit

    LogInfo("Processing item " . index . "/" . total)
    UpdateStatus("Processing: " . item.ean . " → " . item.price)

    ; Get dates from GUI inputs
    startDate := (StartDateEdit != "") ? StartDateEdit.Text : ""
    endDate   := (EndDateEdit   != "") ? EndDateEdit.Text   : ""

    ; Step 1: Set start date (first item only)
    if (index == 1 && !SetStartDate(startDate))
        return false
    Sleep(CONFIG.DELAYS.MEDIUM)

    ; Step 2: Enter article code and search
    if (!EnterArticleCode(item.ean))
        return false

    ; Step 3: Enter new price
    if (!EnterNewPrice(item.price))
        return false

    ; Step 4: Set end date (if specified)
    if (!SetEndDate(endDate))
        return false
    Sleep(CONFIG.DELAYS.MEDIUM)

    ; Step 5: Save the change
    if (!SaveNewPrice())
        return false
    Sleep(CONFIG.DELAYS.PAGE_LOAD)

    ; Step 6: Close "Till download lot number" OK button
    if (!ClickAt(134, 90))
        return false
    Sleep(CONFIG.DELAYS.PAGE_LOAD)

    ; Step 7: Close "Immediate Till Download" without downloading
    if (!ClickAt(230, 123))
        return false
    Sleep(CONFIG.DELAYS.PAGE_LOAD)

    LogInfo("Successfully processed item " . index)
    return true
}
