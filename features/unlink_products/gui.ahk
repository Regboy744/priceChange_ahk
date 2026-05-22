#Requires AutoHotkey >=v2.0

; ============================================================================
; UNLINK PRODUCTS — GUI
; Excel loader + Start button + status / progress. Trimmed-down version of
; the price-change GUI: no PDF loader, no price column, no reason code, no
; date inputs.
;
; Dependencies (provided by the includer — main.ahk):
;   CONFIG, ProjectPath(),
;   LogInfo, LogDebug, LogWarn, LogError, ShowError,
;   StartExcelSession, EndExcelSession, GetExcelRowCount, GetExcelData,
;   ActivateTargetWindow, ShowWorkingOverlay, HideWorkingOverlay,
;   ProcessSingleUnlink
; ============================================================================

; ── GUI globals ───────────────────────────────────────────────────────────
global MainGui := ""
global DataListView := ""
global StatusText := ""
global ProgressBar := ""
global StartBtn := ""
global LoadExcelBtn := ""
global UnlinkData := []    ; Array of { row, ean, status }

; ============================================================================
; SHOW MAIN GUI
; ============================================================================

ShowUnlinkGui() {
    global MainGui, DataListView, StatusText, ProgressBar
    global StartBtn, LoadExcelBtn, CONFIG

    ; Destroy previous instance if still open
    if (MainGui != "") {
        try MainGui.Destroy()
    }

    MainGui := Gui("+Resize +AlwaysOnTop", "Gold Unlink Products Tool")
    MainGui.BackColor := "F0F4F8"

    ; ── Custom icon (reuse the price-change icon — no need for a new one) ─
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
    MainGui.Add("Text", "x0 y0 w360 h70 BackgroundF0F4F8")
    MainGui.SetFont("s14 bold", "Segoe UI")
    MainGui.Add("Text", "xm yp+15 cBlack BackgroundTrans", "Gold Unlink Products")

    MainGui.SetFont("s9 norm", "Segoe UI")
    MainGui.Add("Text", "xm y45 cGray BackgroundTrans",
        "Load an Excel of EANs, then start to unlink scale / print / article links")

    ; ── Buttons ──
    LoadExcelBtn := MainGui.Add("Button", "xm y85 w105 h28", "📊 Excel")
    LoadExcelBtn.OnEvent("Click", OnLoadExcelUnlink)

    StartBtn := MainGui.Add("Button", "x+5 y85 w105 h28 Disabled", "▶️ Start")
    StartBtn.OnEvent("Click", OnStartUnlink)

    MainGui.Add("Button", "x+5 y85 w70 h28", "❌ Close").OnEvent("Click", OnCloseUnlinkGui)

    ; ── Data table ──
    MainGui.SetFont("s9 norm", "Segoe UI")
    MainGui.Add("Text", "xm y125", "Data Preview:")

    DataListView := MainGui.Add("ListView", "xm y145 w320 h290 Grid -Theme",
        ["Status", "Row", "EAN Code"])
    DataListView.ModifyCol(1, 60)
    DataListView.ModifyCol(1, "Center")
    DataListView.ModifyCol(2, 50)
    DataListView.ModifyCol(2, "Center")
    DataListView.ModifyCol(3, 200)
    DataListView.ModifyCol(3, "Center")

    ; ── Progress ──
    MainGui.Add("Text", "xm y445", "Progress:")
    ProgressBar := MainGui.Add("Progress", "x+10 y445 w200 h20 cGreen", 0)

    ; ── Status ──
    StatusText := MainGui.Add("Text", "xm y475 w320 h25 cGray",
        "Ready. Load an Excel file to begin.")

    ; ── Info ──
    MainGui.SetFont("s8", "Segoe UI")
    MainGui.Add("Text", "xm y505 cGray",
        "Excel: first sheet, column A (header on row 1)")

    MainGui.OnEvent("Close", OnCloseUnlinkGui)
    MainGui.Show("w345 h530")
}

; ============================================================================
; EVENT HANDLERS
; ============================================================================

; ── Load from Excel ───────────────────────────────────────────────────────

OnLoadExcelUnlink(*) {
    global DataListView, UnlinkData, StartBtn, CONFIG

    UpdateStatus("📊 Loading Excel file...")

    DataListView.Delete()
    UnlinkData := []

    if (!StartExcelSession()) {
        UpdateStatus("❌ Failed to load Excel file")
        return
    }

    ; Excel's Sheets() collection accepts either a name OR a 1-based index.
    ; We pass 1 so the loader works with any sheet name — the user just needs
    ; the EAN list on the first tab with a header on row 1.
    sheetRef := 1
    totalRows := GetExcelRowCount(sheetRef, CONFIG.COLUMNS.EAN_CODE, 2)

    if (totalRows <= 0) {
        UpdateStatus("❌ No data found on the first sheet")
        EndExcelSession()
        return
    }

    loop totalRows {
        currentRow := A_Index + 1

        eanCode := GetExcelData(sheetRef, CONFIG.COLUMNS.EAN_CODE, currentRow)

        ; Convert ean to text and strip any decimal (e.g. "1234500.0" → "1234500")
        if (eanCode != "")
            eanCode := String(Integer(eanCode))

        if (eanCode == "")
            continue

        UnlinkData.Push({ row: currentRow, ean: eanCode, status: "pending" })
        DataListView.Add("", "⏳", currentRow, eanCode)
    }

    if (UnlinkData.Length == 0) {
        UpdateStatus("❌ No valid EAN codes found in Excel")
        return
    }

    StartBtn.Enabled := true
    UpdateStatus("✅ Loaded " . UnlinkData.Length . " items. Ready to start!")
    LogInfo("Unlink: loaded " . UnlinkData.Length . " items from Excel")
}

; ── Start automation ──────────────────────────────────────────────────────

OnStartUnlink(*) {
    global IsRunning, UnlinkData, CONFIG, MainGui

    if (UnlinkData.Length == 0) {
        UpdateStatus("❌ No data loaded. Please load an Excel file first.")
        return
    }

    MainGui.Opt("-AlwaysOnTop")
    confirm := MsgBox("Unlink " . UnlinkData.Length . " items?`n`n"
        . "Make sure the Gold window is on the unlink screen!",
        "Confirm Start", "YesNo Icon?")
    if (confirm != "Yes") {
        MainGui.Opt("+AlwaysOnTop")
        return
    }

    LogInfo("=== Starting Unlink Workflow ===")
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

    totalItems := UnlinkData.Length
    successCount := 0
    notFoundCount := 0
    failCount := 0

    loop totalItems {
        if (!IsRunning)
            break

        index := A_Index
        item := UnlinkData[index]

        UpdateProgress(index, totalItems)
        UpdateListViewStatus(index, "🔄")

        itemResult := ProcessSingleUnlink(item, index, totalItems)

        if (itemResult == "success") {
            UpdateListViewStatus(index, "✅")
            UnlinkData[index].status := "done"
            successCount++
        } else if (itemResult == "not_found") {
            UpdateListViewStatus(index, "⚠️")
            UnlinkData[index].status := "not_found"
            notFoundCount++
        } else {
            UpdateListViewStatus(index, "❌")
            UnlinkData[index].status := "failed"
            failCount++
        }
    }

    BlockInput(false)
    HideWorkingOverlay()
    EnableButtons(true)
    IsRunning := false

    UpdateStatus("🎉 Completed! Success: " . successCount . " | Not found: "
        . notFoundCount . " | Failed: " . failCount)
    UpdateProgress(totalItems, totalItems)

    LogInfo("=== Unlink Workflow Completed | Success: " . successCount
        . " | Not found: " . notFoundCount . " | Failed: " . failCount . " ===")

    MoveGuiToCenter()
    MainGui.Opt("-AlwaysOnTop")
    MsgBox("Unlink completed!`n`n✅ Success: " . successCount
        . "`n⚠️ Not found: " . notFoundCount . "`n❌ Failed: " . failCount)
    MainGui.Opt("+AlwaysOnTop")
}

; ── Close ─────────────────────────────────────────────────────────────────

OnCloseUnlinkGui(*) {
    global MainGui, IsRunning

    if (IsRunning) {
        MsgBox("Cannot close while automation is running!`nPress ESC to abort first.")
        return
    }

    EndExcelSession()
    MainGui.Destroy()
    ExitApp()
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
    global StartBtn, LoadExcelBtn
    StartBtn.Enabled := enable
    LoadExcelBtn.Enabled := enable
}

/** Move GUI to bottom-right corner during automation. */
MoveGuiToCorner() {
    global MainGui
    if (MainGui != "") {
        guiWidth := 345
        guiHeight := 530
        xPos := A_ScreenWidth - guiWidth - 10
        yPos := A_ScreenHeight - guiHeight - 50
        MainGui.Move(xPos, yPos)
    }
}

/** Move GUI back to the centre of the screen. */
MoveGuiToCenter() {
    global MainGui
    if (MainGui != "") {
        guiWidth := 345
        guiHeight := 530
        xPos := (A_ScreenWidth - guiWidth) / 2
        yPos := (A_ScreenHeight - guiHeight) / 2
        MainGui.Move(xPos, yPos)
    }
}
