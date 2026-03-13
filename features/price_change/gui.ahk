#Requires AutoHotkey >=v2.0

; ============================================================================
; PRICE CHANGE — GUI
; Creates the main window, handles load/start/close events, and provides
; helper functions for status updates, progress, and list-view management.
;
; Dependencies (provided by the includer — main.ahk):
;   CONFIG, ProjectPath(),
;   LogInfo, LogDebug, LogWarn, LogError, ShowError,
;   StartExcelSession, EndExcelSession, GetExcelRowCount, GetExcelData,
;   ParsePDFFile, CheckPDFParserReady, ExportLabelsToExcel,
;   FormatNumber,
;   ActivateTargetWindow, ShowWorkingOverlay, HideWorkingOverlay,
;   ProcessSinglePriceChangeFromGui
; ============================================================================

; ── GUI globals ───────────────────────────────────────────────────────────
global MainGui := ""
global DataListView := ""
global StatusText := ""
global ProgressBar := ""
global StartBtn := ""
global LoadPdfBtn := ""
global LoadExcelBtn := ""
global StartDateEdit := ""
global EndDateEdit := ""
global ReasonCodeDDL := ""
global PriceData := []    ; Array of {row, ean, price, description?, status}
global LoadedSource := ""    ; "pdf" | "excel"

; ============================================================================
; SHOW MAIN GUI
; ============================================================================

ShowMainGui() {
    global MainGui, DataListView, StatusText, ProgressBar
    global StartBtn, LoadPdfBtn, LoadExcelBtn, StartDateEdit, EndDateEdit, CONFIG

    ; Destroy previous instance if still open
    if (MainGui != "") {
        try MainGui.Destroy()
    }

    MainGui := Gui("+Resize +AlwaysOnTop", "Gold Price Change Tool")

    ; ── Custom icon ──
    iconPath := ProjectPath("assets\labelPriceChange.ico")
    if FileExist(iconPath) {
        TraySetIcon(iconPath)
        hIconSmall := LoadPicture(iconPath, "w16 h16 Icon1", &imgType)
        hIconBig := LoadPicture(iconPath, "w32 h32 Icon1", &imgType)
        SendMessage(0x0080, 0, hIconSmall, MainGui)   ; WM_SETICON ICON_SMALL
        SendMessage(0x0080, 1, hIconBig, MainGui)   ; WM_SETICON ICON_BIG
    }

    MainGui.SetFont("s10", "Segoe UI")

    ; ── Header ──
    MainGui.Add("Text", "x0 y0 w450 h80 BackgroundF0F4F8")
    MainGui.Add("Picture", "x55 y10 w36 h36 BackgroundTrans",
        ProjectPath("assets\chart_accept_12944.png"))
    MainGui.SetFont("s14 bold", "Segoe UI")
    MainGui.Add("Text", "x+8 yp+5 cBlack BackgroundTrans", "Gold Price Change Automation")

    MainGui.SetFont("s10 norm", "Segoe UI")
    MainGui.Add("Text", "xm y48 w410 Center BackgroundTrans",
        "Load a PDF or Excel file, review the data, then start")

    ; ── Buttons ──
    LoadPdfBtn := MainGui.Add("Button", "x25 y95 w90 h28", "📄 PDF ▼")
    LoadPdfBtn.OnEvent("Click", OnPdfButtonClick)

    LoadExcelBtn := MainGui.Add("Button", "x+5 y95 w90 h28", "📊 Excel")
    LoadExcelBtn.OnEvent("Click", OnLoadExcel)

    StartBtn := MainGui.Add("Button", "x+5 y95 w105 h28 Disabled", "▶️ Start")
    StartBtn.OnEvent("Click", OnStartAutomation)

    MainGui.Add("Button", "x+5 y95 w70 h28", "❌ Close").OnEvent("Click", OnCloseGui)

    ; ── Data table ──
    MainGui.SetFont("s9", "Segoe UI")
    MainGui.Add("Text", "xm y140", "Data Preview:")

    DataListView := MainGui.Add("ListView", "xm y160 w410 h260 Grid -Theme",
        ["Status", "Row", "EAN Code", "Price Change"])

    DataListView.ModifyCol(1, 55)
    DataListView.ModifyCol(1, "Center")
    DataListView.ModifyCol(2, 45)
    DataListView.ModifyCol(2, "Center")
    DataListView.ModifyCol(3, 175)
    DataListView.ModifyCol(3, "Center")
    DataListView.ModifyCol(4, 114)
    DataListView.ModifyCol(4, "Center")

    ; ── Progress ──
    MainGui.Add("Text", "xm y430", "Progress:")
    ProgressBar := MainGui.Add("Progress", "x+10 y430 w200 h20 cGreen", 0)

    ; ── Status ──
    StatusText := MainGui.Add("Text", "xm y460 w280 h25 cGray",
        "Ready. Load a PDF or Excel file to begin.")

    ; ── Info ──
    MainGui.SetFont("s8", "Segoe UI")
    MainGui.Add("Text", "xm y485 cGray",
        "PDF mode: faster | Excel sheet: " . CONFIG.SHEET_NAME)

    ; ── Date inputs (bottom-right) ──
    MainGui.SetFont("s9", "Segoe UI")
    MainGui.Add("Text", "x290 y432", "Start Date:")
    StartDateEdit := MainGui.Add("Edit", "x355 y430 w65 h22 Limit8 Center", "")
    MainGui.Add("Text", "x295 y462", "End Date:")
    EndDateEdit := MainGui.Add("Edit", "x355 y460 w65 h22 Limit8 Center", "")

    ; ── Reason Code dropdown ──
    MainGui.Add("Text", "x274 y495", "Reason Code:")
    ReasonCodeDDL := MainGui.Add("DropDownList", "x355 y490 w65 Choose1",
        ["      0", "      1", "      2", "     900"])

    MainGui.OnEvent("Close", OnCloseGui)
    MainGui.Show("w435 h530")
}

; ============================================================================
; EVENT HANDLERS
; ============================================================================

; ── PDF button → context menu ─────────────────────────────────────────────

OnPdfButtonClick(*) {
    global LoadPdfBtn, MainGui

    pdfMenu := Menu()
    pdfMenu.Add("📊 Parse for Price Change", OnLoadPDF)
    pdfMenu.Add("💾 Export to Excel File", OnLoadPDFForExcel)

    ; Position menu directly below the PDF button (client-area coords)
    LoadPdfBtn.GetPos(&btnX, &btnY, &btnW, &btnH)
    pdfMenu.Show(btnX, btnY + btnH)
}

; ── Load PDF → Excel export ───────────────────────────────────────────────

OnLoadPDFForExcel(*) {
    global MainGui

    parserStatus := CheckPDFParserReady()
    if (!parserStatus.ready) {
        UpdateStatus("❌ " . parserStatus.error)
        ShowError(parserStatus.error)
        return
    }

    pdfPath := FileSelect(, , "Select Price Change PDF", "PDF Files (*.pdf)")
    if (!pdfPath) {
        UpdateStatus("⚠️ No file selected")
        return
    }

    UpdateStatus("📄 Parsing PDF for Excel export...")
    labels := ParsePDFFile(pdfPath)

    if (labels.Length == 0) {
        UpdateStatus("❌ No data found in PDF or parsing failed")
        return
    }

    UpdateStatus("💾 Exporting " . labels.Length . " items to Excel...")
    result := ExportLabelsToExcel(labels)

    if (result.success) {
        UpdateStatus("✅ Exported " . result.count . " items to Excel!")
        MainGui.Opt("-AlwaysOnTop")

        openResult := MsgBox("Successfully exported " . result.count . " items!`n`n"
            . "File saved to:`n" . result.path . "`n`nOpen the file now?",
            "Export Complete", "YesNo Icon!")

        if (openResult == "Yes")
            try Run(result.path)

        MainGui.Opt("+AlwaysOnTop")
    } else {
        UpdateStatus("❌ Export failed: " . result.error)
        ShowError("Failed to export to Excel:`n" . result.error)
    }
}

; ── Load PDF → price change ───────────────────────────────────────────────

OnLoadPDF(*) {
    global DataListView, PriceData, StartBtn, LoadedSource

    parserStatus := CheckPDFParserReady()
    if (!parserStatus.ready) {
        UpdateStatus("❌ " . parserStatus.error)
        ShowError(parserStatus.error)
        return
    }

    pdfPath := FileSelect(, , "Select Price Change PDF", "PDF Files (*.pdf)")
    if (!pdfPath) {
        UpdateStatus("⚠️ No file selected")
        return
    }

    UpdateStatus("📄 Parsing PDF... (this may take a moment)")

    DataListView.Delete()
    PriceData := []
    LoadedSource := "pdf"

    labels := ParsePDFFile(pdfPath)

    if (labels.Length == 0) {
        UpdateStatus("❌ No data found in PDF or parsing failed")
        return
    }

    rowNum := 0
    for label in labels {
        if (label.ean == "" || label.ean == "null" || label.price == "" || label.price == 0)
            continue
        if (label.price >= 9999)
            continue

        rowNum++
        formatted_price := FormatNumber(label.price, 2)

        PriceData.Push({
            row: rowNum,
            ean: label.ean,
            price: formatted_price,
            description: label.HasProp("description") ? label.description : "",
            status: "pending"
        })

        DataListView.Add("", "⏳", rowNum, label.ean, formatted_price)
    }

    if (PriceData.Length == 0) {
        UpdateStatus("❌ No valid price change items found in PDF")
        return
    }

    StartBtn.Enabled := true
    UpdateStatus("✅ Loaded " . PriceData.Length . " items from PDF. Ready to start!")
    LogInfo("Loaded " . PriceData.Length . " items from PDF: " . pdfPath)
}

; ── Load from Excel ───────────────────────────────────────────────────────

OnLoadExcel(*) {
    global DataListView, PriceData, StartBtn, CONFIG, LoadedSource

    UpdateStatus("📊 Loading Excel file...")

    DataListView.Delete()
    PriceData := []
    LoadedSource := "excel"

    if (!StartExcelSession()) {
        UpdateStatus("❌ Failed to load Excel file")
        return
    }

    totalRows := GetExcelRowCount(CONFIG.SHEET_NAME, CONFIG.COLUMNS.EAN_CODE, 2)

    if (totalRows <= 0) {
        UpdateStatus("❌ No data found in sheet: " . CONFIG.SHEET_NAME)
        EndExcelSession()
        return
    }

    loop totalRows {
        currentRow := A_Index + 1

        ean_code := GetExcelData(CONFIG.SHEET_NAME, CONFIG.COLUMNS.EAN_CODE, currentRow)
        new_price := GetExcelData(CONFIG.SHEET_NAME, CONFIG.COLUMNS.NEW_PRICE, currentRow)

        if (ean_code == "")
            continue

        formatted_price := FormatNumber(new_price, 2)

        PriceData.Push({
            row: currentRow,
            ean: ean_code,
            price: formatted_price,
            status: "pending"
        })

        DataListView.Add("", "⏳", currentRow, ean_code, formatted_price)
    }

    StartBtn.Enabled := true
    UpdateStatus("✅ Loaded " . PriceData.Length . " items from Excel. Ready to start!")
    LogInfo("Loaded " . PriceData.Length . " items from Excel")
}

; ── Start automation ──────────────────────────────────────────────────────

OnStartAutomation(*) {
    global IsRunning, PriceData, CONFIG, MainGui, LoadedSource

    if (PriceData.Length == 0) {
        UpdateStatus("❌ No data loaded. Please load a PDF or Excel file first.")
        return
    }

    MainGui.Opt("-AlwaysOnTop")

    sourceInfo := LoadedSource == "pdf" ? " (from PDF)" : " (from Excel)"
    result := MsgBox("Start automation for " . PriceData.Length . " items" . sourceInfo
        . "?`n`nMake sure the Gold window is open!",
        "Confirm Start", "YesNo Icon?")

    if (result != "Yes") {
        MainGui.Opt("+AlwaysOnTop")
        return
    }

    LogInfo("=== Starting Price Change Workflow ===")
    IsRunning := true
    EnableButtons(false)

    MoveGuiToCorner()
    MainGui.Opt("+AlwaysOnTop")

    if (!ActivateTargetWindow()) {
        UpdateStatus("❌ Cannot activate Gold window. Make sure it's open.")
        EnableButtons(true)
        IsRunning := false
        MoveGuiToCenter()
        return
    }

    ShowWorkingOverlay()
    Sleep(CONFIG.DELAYS.SHORT)
    BlockInput(true)
    Sleep(CONFIG.DELAYS.SHORT)

    totalItems := PriceData.Length
    successCount := 0
    failCount := 0

    loop totalItems {
        if (!IsRunning)
            break

        index := A_Index
        item := PriceData[index]

        UpdateProgress(index, totalItems)
        UpdateListViewStatus(index, "🔄")

        if (ProcessSinglePriceChangeFromGui(item, index, totalItems)) {
            UpdateListViewStatus(index, "✅")
            PriceData[index].status := "done"
            successCount++
        } else {
            UpdateListViewStatus(index, "❌")
            PriceData[index].status := "failed"
            failCount++
        }
    }

    BlockInput(false)
    HideWorkingOverlay()
    EnableButtons(true)
    IsRunning := false

    UpdateStatus("🎉 Completed! Success: " . successCount . " | Failed: " . failCount)
    UpdateProgress(totalItems, totalItems)

    LogInfo("=== Price Change Workflow Completed ===")

    MoveGuiToCenter()
    MainGui.Opt("-AlwaysOnTop")
    MsgBox("Price change completed!`n`n✅ Success: " . successCount . "`n❌ Failed: " . failCount)
    MainGui.Opt("+AlwaysOnTop")
}

; ── Close ─────────────────────────────────────────────────────────────────

OnCloseGui(*) {
    global MainGui, IsRunning, LoadedSource

    if (IsRunning) {
        MsgBox("Cannot close while automation is running!`nPress ESC to abort first.")
        return
    }

    if (LoadedSource == "excel")
        EndExcelSession()

    MainGui.Destroy()
}

; ============================================================================
; GUI HELPERS
; ============================================================================

UpdateStatus(message) {
    global StatusText
    if (StatusText != "")
        StatusText.Value := message
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
        DataListView.Modify(rowIndex, "Vis")
        DataListView.Modify(rowIndex, "Select Focus")
    }
}

EnableButtons(enable) {
    global StartBtn, LoadPdfBtn, LoadExcelBtn
    StartBtn.Enabled := enable
    LoadPdfBtn.Enabled := enable
    LoadExcelBtn.Enabled := enable
}

/** Move GUI to bottom-right corner during automation. */
MoveGuiToCorner() {
    global MainGui
    if (MainGui != "") {
        guiWidth := 450
        guiHeight := 520
        xPos := A_ScreenWidth - guiWidth - 10
        yPos := A_ScreenHeight - guiHeight - 50
        MainGui.Move(xPos, yPos)
    }
}

/** Move GUI back to centre of screen. */
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