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

; ============================================================================
; GLOBAL VARIABLES
; ============================================================================

global IsRunning := false
global MainGui := ""
global DataListView := ""
global StatusText := ""
global ProgressBar := ""
global StartBtn := ""
global LoadBtn := ""
global StartDateEdit := ""
global EndDateEdit := ""
global ExcelData := []  ; Store loaded data

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
    global MainGui, DataListView, StatusText, ProgressBar, StartBtn, LoadBtn, StartDateEdit, EndDateEdit, CONFIG

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
        "Load an Excel file, review the data, then start the automation")

    ; === Buttons Section (Centered) ===
    ; Total button width: 120 + 15 + 120 + 15 + 80 = 350px
    ; Center position: (410 - 350) / 2 = 30px from left margin
    LoadBtn := MainGui.Add("Button", "x40 y95 w120 h30", "📂 Load Excel File")
    LoadBtn.OnEvent("Click", OnLoadExcel)

    StartBtn := MainGui.Add("Button", "x+15 y95 w120 h30 Disabled", "▶️ Start Automation")
    StartBtn.OnEvent("Click", OnStartAutomation)

    MainGui.Add("Button", "x+15 y95 w80 h30", "❌ Close").OnEvent("Click", OnCloseGui)

    ; === Data Table Section ===
    MainGui.SetFont("s9", "Segoe UI")
    MainGui.Add("Text", "xm y140", "Data Preview:")

    ; ListView with columns: Status, Row, EAN Code, New Price
    DataListView := MainGui.Add("ListView", "xm y160 w410 h260 Grid -Theme",
        ["Status", "Row", "EAN Code", "New Price"])

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
    StatusText := MainGui.Add("Text", "xm y460 w280 h25 cGray", "Ready. Load an Excel file to begin.")

    ; === Config Info ===
    MainGui.SetFont("s8", "Segoe UI")
    MainGui.Add("Text", "xm y485 cGray", "Sheet: " . CONFIG.SHEET_NAME)

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

OnLoadExcel(*) {
    global DataListView, ExcelData, StartBtn, CONFIG

    UpdateStatus("📂 Loading Excel file...")

    ; Clear existing data
    DataListView.Delete()
    ExcelData := []

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
        ExcelData.Push({
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

    UpdateStatus("✅ Loaded " . ExcelData.Length . " items. Ready to start!")
    LogInfo("Loaded " . ExcelData.Length . " items from Excel")
}

OnStartAutomation(*) {
    global IsRunning, ExcelData, CONFIG, MainGui

    if (ExcelData.Length == 0) {
        UpdateStatus("❌ No data loaded. Please load an Excel file first.")
        return
    }

    ; Temporarily disable AlwaysOnTop so MsgBox appears on top
    MainGui.Opt("-AlwaysOnTop")

    ; Confirm before starting
    result := MsgBox("Start automation for " . ExcelData.Length . " items?`n`nMake sure the Gold window is open!",
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
    totalItems := ExcelData.Length
    successCount := 0
    failCount := 0

    loop totalItems {
        if (!IsRunning) {
            break
        }

        index := A_Index
        item := ExcelData[index]

        UpdateProgress(index, totalItems)
        UpdateListViewStatus(index, "🔄")  ; Processing

        if (ProcessSinglePriceChangeFromGui(item, index, totalItems)) {
            UpdateListViewStatus(index, "✅")  ; Success
            ExcelData[index].status := "done"
            successCount++
        } else {
            UpdateListViewStatus(index, "❌")  ; Failed
            ExcelData[index].status := "failed"
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
    global MainGui, IsRunning

    if (IsRunning) {
        MsgBox("Cannot close while automation is running!`nPress ESC to abort first.")
        return
    }

    EndExcelSession()
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
    global StartBtn, LoadBtn
    StartBtn.Enabled := enable
    LoadBtn.Enabled := enable
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
