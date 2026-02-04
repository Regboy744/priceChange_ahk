#SingleInstance Force
#Requires AutoHotkey >=v2.0

; ============================================================================
; GOLD PRICE CHANGE AUTOMATION
; Author: Gilberto Carvalho
; Version: 2.0 - With GUI
; Main entry point for the price change workflow
; ============================================================================

; Include configuration and libraries
#Include config.ahk
#Include lib\logger.ahk
#Include lib\excelUtils.ahk
#Include lib\uiUtils.ahk
#Include lib\stringUtils.ahk
#Include lib\jsonUtils.ahk
#Include lib\pdfUtils.ahk

; ============================================================================
; GLOBAL VARIABLES
; ============================================================================

global IsRunning := false
global MainGui := ""
global DataListView := ""
global StatusText := ""
global ProgressBar := ""
global StartBtn := ""
global LoadPdfBtn := ""
global LoadExcelBtn := ""
global StartDateEdit := ""
global EndDateEdit := ""
global PriceData := []  ; Store loaded data (from PDF or Excel)
global LoadedSource := ""  ; Track source: "pdf" or "excel"

; ============================================================================
; HOTKEYS
; ============================================================================

; F2: Emergency Excel cleanup
f2:: CloseAllExcelSafely()

; F1: Show main GUI
f1:: ShowMainGui()

; ESC as emergency stop
Esc:: {
    global IsRunning
    if (IsRunning) {
        IsRunning := false
        BlockInput(false)
        HideWorkingOverlay()
        UpdateStatus("⚠️ Automation aborted by user!")
        EnableButtons(true)
    }
}

; ============================================================================
; MAIN GUI
; ============================================================================

ShowMainGui() {
    global MainGui, DataListView, StatusText, ProgressBar, StartBtn, LoadPdfBtn, LoadExcelBtn, StartDateEdit,
        EndDateEdit, CONFIG

    ; Destroy existing GUI if open
    if (MainGui != "") {
        try MainGui.Destroy()
    }

    ; Create main window (AlwaysOnTop keeps it visible during automation)
    MainGui := Gui("+Resize +AlwaysOnTop", "Gold Price Change Tool")

    ; Set custom icon (tray, GUI title bar, and taskbar)
    iconPath := A_ScriptDir . "\icon\labelPriceChange.ico"
    if FileExist(iconPath) {
        TraySetIcon(iconPath)  ; System tray icon
        ; Load and set icon for GUI window (title bar + taskbar)
        hIconSmall := LoadPicture(iconPath, "w16 h16 Icon1", &imgType)
        hIconBig := LoadPicture(iconPath, "w32 h32 Icon1", &imgType)
        SendMessage(0x0080, 0, hIconSmall, MainGui)  ; WM_SETICON, ICON_SMALL
        SendMessage(0x0080, 1, hIconBig, MainGui)    ; WM_SETICON, ICON_BIG
    }

    MainGui.SetFont("s10", "Segoe UI")

    ; === Header Section with background ===
    ; Add a smooth background panel for the header
    MainGui.Add("Text", "x0 y0 w450 h80 BackgroundF0F4F8")

    ; Add chart icon image (centered with text)
    MainGui.Add("Picture", "x55 y10 w36 h36 BackgroundTrans", A_ScriptDir . "\icon\chart_accept_12944.png")
    MainGui.SetFont("s14 bold", "Segoe UI")
    MainGui.Add("Text", "x+8 yp+5 cBlack BackgroundTrans", "Gold Price Change Automation")

    MainGui.SetFont("s10 norm", "Segoe UI")
    MainGui.Add("Text", "xm y48 w410 Center BackgroundTrans",
        "Load a PDF or Excel file, review the data, then start")

    ; === Buttons Section (Centered) ===
    ; Buttons sized to fit: 90 + 5 + 90 + 5 + 100 + 5 + 70 = 365px (fits in 410px)
    LoadPdfBtn := MainGui.Add("Button", "x25 y95 w90 h28", "📄 PDF")
    LoadPdfBtn.OnEvent("Click", OnLoadPDF)

    LoadExcelBtn := MainGui.Add("Button", "x+5 y95 w90 h28", "📊 Excel")
    LoadExcelBtn.OnEvent("Click", OnLoadExcel)

    StartBtn := MainGui.Add("Button", "x+5 y95 w105 h28 Disabled", "▶️ Start")
    StartBtn.OnEvent("Click", OnStartAutomation)

    MainGui.Add("Button", "x+5 y95 w70 h28", "❌ Close").OnEvent("Click", OnCloseGui)

    ; === Data Table Section ===
    MainGui.SetFont("s9", "Segoe UI")
    MainGui.Add("Text", "xm y140", "Data Preview:")

    ; ListView with columns: Status, Row, EAN Code, New Price
    DataListView := MainGui.Add("ListView", "xm y160 w410 h260 Grid -Theme",
        ["Status", "Row", "EAN Code", "Price Change"])

    ; Set column widths based on content size (total ~390px for 410px ListView with scrollbar)
    ; Status: small icons, Row: 2-3 digits, EAN: 13 digits, Price: 4-5 chars
    DataListView.ModifyCol(1, 55)       ; Status - icons
    DataListView.ModifyCol(1, "Center")
    DataListView.ModifyCol(2, 45)       ; Row - short numbers
    DataListView.ModifyCol(2, "Center")
    DataListView.ModifyCol(3, 175)      ; EAN Code - long numbers
    DataListView.ModifyCol(3, "Center")
    DataListView.ModifyCol(4, 114)      ; New Price - prices
    DataListView.ModifyCol(4, "Center")

    ; === Progress Section ===
    MainGui.Add("Text", "xm y430", "Progress:")
    ProgressBar := MainGui.Add("Progress", "x+10 y430 w200 h20 cGreen", 0)

    ; === Status Bar ===
    StatusText := MainGui.Add("Text", "xm y460 w280 h25 cGray", "Ready. Load a PDF or Excel file to begin.")

    ; === Config Info ===
    MainGui.SetFont("s8", "Segoe UI")
    MainGui.Add("Text", "xm y485 cGray", "PDF mode: faster | Excel sheet: " . CONFIG.SHEET_NAME)

    ; === Date Settings Section (Bottom Right, aligned with table margin) ===
    MainGui.SetFont("s9", "Segoe UI")
    MainGui.Add("Text", "x290 y432", "Start Date:")
    StartDateEdit := MainGui.Add("Edit", "x355 y430 w65 h22 Limit8 Center", "")
    MainGui.Add("Text", "x295 y462", "End Date:")
    EndDateEdit := MainGui.Add("Edit", "x355 y460 w65 h22 Limit8 Center", "")

    ; Handle window close
    MainGui.OnEvent("Close", OnCloseGui)

    ; Show the GUI
    MainGui.Show("w435 h510")
}

; ============================================================================
; GUI EVENT HANDLERS
; ============================================================================

; Load from PDF (faster - no Excel COM overhead)
OnLoadPDF(*) {
    global DataListView, PriceData, StartBtn, LoadedSource

    ; Check if PDF parser is ready
    parserStatus := CheckPDFParserReady()
    if (!parserStatus.ready) {
        UpdateStatus("❌ " . parserStatus.error)
        ShowError(parserStatus.error)
        return
    }

    ; Select PDF file
    pdfPath := FileSelect(, , "Select Price Change PDF", "PDF Files (*.pdf)")
    if (!pdfPath) {
        UpdateStatus("⚠️ No file selected")
        return
    }

    UpdateStatus("📄 Parsing PDF... (this may take a moment)")

    ; Clear existing data
    DataListView.Delete()
    PriceData := []
    LoadedSource := "pdf"

    ; Parse the PDF
    labels := ParsePDFFile(pdfPath)

    if (labels.Length == 0) {
        UpdateStatus("❌ No data found in PDF or parsing failed")
        return
    }

    ; Load data into array and ListView
    rowNum := 0
    for label in labels {
        ; Skip items without EAN or price
        if (label.ean == "" || label.ean == "null" || label.price == "" || label.price == 0) {
            continue
        }

        ; Skip separator labels (like "LABEL SEPERATOR" with price 9999)
        if (label.price >= 9999) {
            continue
        }

        rowNum++

        ; Format the price
        formatted_price := FormatNumber(label.price, 2)

        ; Store in array
        PriceData.Push({
            row: rowNum,
            ean: label.ean,
            price: formatted_price,
            description: label.HasProp("description") ? label.description : "",
            status: "pending"
        })

        ; Add to ListView
        DataListView.Add("", "⏳", rowNum, label.ean, formatted_price)
    }

    if (PriceData.Length == 0) {
        UpdateStatus("❌ No valid price change items found in PDF")
        return
    }

    ; Enable start button
    StartBtn.Enabled := true

    UpdateStatus("✅ Loaded " . PriceData.Length . " items from PDF. Ready to start!")
    LogInfo("Loaded " . PriceData.Length . " items from PDF: " . pdfPath)
}

; Load from Excel (legacy method)
OnLoadExcel(*) {
    global DataListView, PriceData, StartBtn, CONFIG, LoadedSource

    UpdateStatus("📊 Loading Excel file...")

    ; Clear existing data
    DataListView.Delete()
    PriceData := []
    LoadedSource := "excel"

    ; Start Excel session (will prompt for file)
    if (!StartExcelSession()) {
        UpdateStatus("❌ Failed to load Excel file")
        return
    }

    ; Get total rows
    totalRows := GetExcelRowCount(CONFIG.SHEET_NAME, CONFIG.COLUMNS.EAN_CODE, 2)

    if (totalRows <= 0) {
        UpdateStatus("❌ No data found in sheet: " . CONFIG.SHEET_NAME)
        EndExcelSession()
        return
    }

    ; Load data into array and ListView
    loop totalRows {
        currentRow := A_Index + 1  ; Data starts from row 2

        ean_code := GetExcelData(CONFIG.SHEET_NAME, CONFIG.COLUMNS.EAN_CODE, currentRow)
        new_price := GetExcelData(CONFIG.SHEET_NAME, CONFIG.COLUMNS.NEW_PRICE, currentRow)

        ; Skip empty rows
        if (ean_code == "") {
            continue
        }

        ; Format the price
        formatted_price := FormatNumber(new_price, 2)

        ; Store in array
        PriceData.Push({
            row: currentRow,
            ean: ean_code,
            price: formatted_price,
            status: "pending"
        })

        ; Add to ListView
        DataListView.Add("", "⏳", currentRow, ean_code, formatted_price)
    }

    ; Enable start button
    StartBtn.Enabled := true

    UpdateStatus("✅ Loaded " . PriceData.Length . " items from Excel. Ready to start!")
    LogInfo("Loaded " . PriceData.Length . " items from Excel")
}

OnStartAutomation(*) {
    global IsRunning, PriceData, CONFIG, MainGui, LoadedSource

    if (PriceData.Length == 0) {
        UpdateStatus("❌ No data loaded. Please load a PDF or Excel file first.")
        return
    }

    ; Temporarily disable AlwaysOnTop so MsgBox appears on top
    MainGui.Opt("-AlwaysOnTop")

    ; Confirm before starting
    sourceInfo := LoadedSource == "pdf" ? " (from PDF)" : " (from Excel)"
    result := MsgBox("Start automation for " . PriceData.Length . " items" . sourceInfo .
        "?`n`nMake sure the Gold window is open!",
        "Confirm Start", "YesNo Icon?")

    if (result != "Yes") {
        ; Re-enable AlwaysOnTop only if user cancels
        MainGui.Opt("+AlwaysOnTop")
        return
    }

    LogInfo("=== Starting Price Change Workflow ===")
    IsRunning := true
    EnableButtons(false)

    ; Move GUI to bottom-right corner so it's visible but not blocking Gold window
    MoveGuiToCorner()
    MainGui.Opt("+AlwaysOnTop")  ; Re-enable AlwaysOnTop

    ; Activate target window
    if (!ActivateTargetWindow()) {
        UpdateStatus("❌ Cannot activate Gold window. Make sure it's open.")
        EnableButtons(true)
        IsRunning := false
        MoveGuiToCenter()  ; Move back to center on error
        return
    }

    ; Show overlay and block input
    ShowWorkingOverlay()
    Sleep(CONFIG.DELAYS.SHORT)
    BlockInput(true)
    Sleep(CONFIG.DELAYS.SHORT)

    ; Process each row
    totalItems := PriceData.Length
    successCount := 0
    failCount := 0

    loop totalItems {
        if (!IsRunning) {
            break
        }

        index := A_Index
        item := PriceData[index]

        UpdateProgress(index, totalItems)
        UpdateListViewStatus(index, "🔄")  ; Processing

        if (ProcessSinglePriceChangeFromGui(item, index, totalItems)) {
            UpdateListViewStatus(index, "✅")  ; Success
            PriceData[index].status := "done"
            successCount++
        } else {
            UpdateListViewStatus(index, "❌")  ; Failed
            PriceData[index].status := "failed"
            failCount++
        }
    }

    ; Cleanup
    BlockInput(false)
    HideWorkingOverlay()
    EnableButtons(true)
    IsRunning := false

    ; Final status
    UpdateStatus("🎉 Completed! Success: " . successCount . " | Failed: " . failCount)
    UpdateProgress(totalItems, totalItems)

    LogInfo("=== Price Change Workflow Completed ===")

    ; Move GUI back to center and show completion message
    MoveGuiToCenter()
    MainGui.Opt("-AlwaysOnTop")  ; Disable so MsgBox appears on top
    MsgBox("Price change completed!`n`n✅ Success: " . successCount . "`n❌ Failed: " . failCount)
    MainGui.Opt("+AlwaysOnTop")
}

OnCloseGui(*) {
    global MainGui, IsRunning, LoadedSource

    if (IsRunning) {
        MsgBox("Cannot close while automation is running!`nPress ESC to abort first.")
        return
    }

    ; Only end Excel session if we loaded from Excel
    if (LoadedSource == "excel") {
        EndExcelSession()
    }
    MainGui.Destroy()
}

; ============================================================================
; GUI HELPER FUNCTIONS
; ============================================================================

UpdateStatus(message) {
    global StatusText
    if (StatusText != "") {
        StatusText.Value := message
    }
}

UpdateProgress(current, total) {
    global ProgressBar
    if (ProgressBar != "") {
        percentage := Round((current / total) * 100)
        ProgressBar.Value := percentage
    }
}

UpdateListViewStatus(rowIndex, status) {
    global DataListView
    if (DataListView != "") {
        DataListView.Modify(rowIndex, , status)
        ; Auto-scroll to make the current row visible
        DataListView.Modify(rowIndex, "Vis")  ; Ensure row is visible
        DataListView.Modify(rowIndex, "Select Focus")  ; Select and focus the row
    }
}

EnableButtons(enable) {
    global StartBtn, LoadPdfBtn, LoadExcelBtn
    StartBtn.Enabled := enable
    LoadPdfBtn.Enabled := enable
    LoadExcelBtn.Enabled := enable
}

; Move GUI to bottom-right corner (compact mode for automation)
MoveGuiToCorner() {
    global MainGui
    if (MainGui != "") {
        guiWidth := 450
        guiHeight := 520
        xPos := A_ScreenWidth - guiWidth - 10   ; 10px from right edge
        yPos := A_ScreenHeight - guiHeight - 50  ; 50px from bottom (taskbar)
        MainGui.Move(xPos, yPos)
    }
}

; Move GUI back to center of screen
MoveGuiToCenter() {
    global MainGui
    if (MainGui != "") {
        guiWidth := 450
        guiHeight := 520
        xPos := (A_ScreenWidth - guiWidth) / 2
        yPos := (A_ScreenHeight - guiHeight) / 2
        MainGui.Move(xPos, yPos)
    }
}

; ============================================================================
; SINGLE ROW PROCESSING (GUI VERSION)
; ============================================================================

ProcessSinglePriceChangeFromGui(item, index, total) {
    global CONFIG, StartDateEdit, EndDateEdit

    LogInfo("Processing item " . index . "/" . total)
    UpdateStatus("Processing: " . item.ean . " → " . item.price)

    ; Get dates from GUI inputs
    startDate := (StartDateEdit != "") ? StartDateEdit.Text : ""
    endDate := (EndDateEdit != "") ? EndDateEdit.Text : ""

    ; Step 1: Set start date (only on first item)
    if (index == 1 && !SetStartDate(startDate)) {
        return false
    }
    Sleep(CONFIG.DELAYS.MEDIUM)

    ; Step 2: Enter article code and search
    if (!EnterArticleCode(item.ean)) {
        return false
    }

    ; Step 3: Enter new price
    if (!EnterNewPrice(item.price)) {
        return false
    }

    ; Step 4: Set end date if specified
    if (!SetEndDate(endDate)) {
        return false
    }
    Sleep(CONFIG.DELAYS.MEDIUM)

    ; Step 5: Save the change
    if (!SaveNewPrice()) {
        return false
    }
    Sleep(CONFIG.DELAYS.PAGE_LOAD)

    ; Step 6: Close the OK button for Till download lot number
    if (!ClickAt(134, 90)) {
        return false
    }
    Sleep(CONFIG.DELAYS.PAGE_LOAD)

    ; Step 7: Close the Immediate Till Download without downloading
    if (!ClickAt(230, 123)) {
        return false
    }
    Sleep(CONFIG.DELAYS.PAGE_LOAD)

    LogInfo("Successfully processed item " . index)
    return true
}

; ============================================================================
; LEGACY WORKFLOW (Keep for compatibility)
; ============================================================================

RunPriceChangeWorkflow() {
    ; Now just show the GUI instead
    ShowMainGui()
}
