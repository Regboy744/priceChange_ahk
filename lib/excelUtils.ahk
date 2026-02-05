#Requires AutoHotkey >=v2.0

; ============================================================================
; EXCEL UTILITIES
; Functions for Excel COM automation
; ============================================================================

; Global variables to keep Excel session open
global xl_session := ""
global wb_session := ""
global current_file := ""

; Start Excel session (call once at the beginning)
StartExcelSession(filePath := "") {
    global xl_session, wb_session, current_file

    ; Close existing session if open
    if (xl_session != "") {
        EndExcelSession()
    }

    ; Select file if not provided
    if (filePath == "") {
        filePath := FileSelect(, , "Select Excel File", "Excel Files (*.xlsx; *.xls; *.xlsm)")
        if (!filePath) {
            LogWarn("No file selected for Excel session")
            return false
        }
    }

    try {
        LogInfo("Starting Excel session with file: " . filePath)

        ; Create Excel application
        xl_session := ComObject("Excel.Application")
        xl_session.Visible := false  ; Keep hidden for speed
        xl_session.DisplayAlerts := false
        xl_session.ScreenUpdating := false  ; Disable screen updates for speed

        ; Open workbook
        wb_session := xl_session.Workbooks.Open(filePath)
        current_file := filePath

        LogInfo("Excel session started successfully")
        return true

    } catch as e {
        LogError("Failed to start Excel session: " . e.message)
        ShowError("Failed to start Excel session: " . e.message)
        return false
    }
}

; Get data from a cell in the active workbook
GetExcelData(sheetName, column, row) {
    global xl_session, wb_session

    ; Check if session exists
    if (xl_session == "" || wb_session == "") {
        LogError("No Excel session active when trying to get data")
        ShowError("No Excel session active! Start session first.")
        return ""
    }

    try {
        ; Access sheet directly (no file opening overhead)
        ws := wb_session.Sheets(sheetName)

        ; Get data from cell
        cellValue := ws.Cells(row, column).Value

        LogDebug("Got value from " . sheetName . "[" . row . "," . column . "]: " . cellValue)
        return cellValue

    } catch as e {
        LogError("Get Excel data failed: " . e.message)
        ShowError("Get failed: " . e.message)
        return ""
    }
}

; Count rows with data starting from a specific row
GetExcelRowCount(sheetName, column, startRow := 1) {
    global xl_session, wb_session

    ; Check if session exists
    if (xl_session == "" || wb_session == "") {
        LogError("No Excel session active when trying to count rows")
        ShowError("No Excel session active! Start session first.")
        return 0
    }

    try {
        ; Access sheet directly
        ws := wb_session.Sheets(sheetName)

        ; Find last row with data in the specified column
        ; -4162 is xlUp constant
        lastRow := ws.Cells(ws.Rows.Count, column).End(-4162).Row

        ; Calculate count from startRow to lastRow
        if (lastRow >= startRow) {
            count := lastRow - startRow + 1
            LogInfo("Row count in " . sheetName . ": " . count)
            return count
        } else {
            LogWarn("No data found from row " . startRow . " onwards")
            return 0
        }

    } catch as e {
        LogError("Get row count failed: " . e.message)
        ShowError("Get row count failed: " . e.message)
        return 0
    }
}

; Paste data to a cell with validation and options
PasteExcelData(sheetName, column, row, dataValue, autoSave := false) {
    global xl_session, wb_session

    ; Check if session exists
    if (xl_session == "" || wb_session == "") {
        LogError("No Excel session active when trying to paste data")
        ShowError("No Excel session active! Start session first.")
        return false
    }

    try {
        ; Access sheet with error handling
        ws := wb_session.Sheets(sheetName)

        ; Check if sheet is protected
        if (ws.ProtectContents) {
            LogError("Sheet '" . sheetName . "' is protected")
            ShowError("Sheet '" . sheetName . "' is protected! Cannot paste.")
            return false
        }

        ; Paste the data
        ws.Cells(row, column).Value := dataValue
        LogDebug("Pasted to " . sheetName . "[" . row . "," . column . "]: " . dataValue)

        ; Optional: Save immediately
        if (autoSave) {
            wb_session.Save()
            LogDebug("Workbook saved")
        }

        return true

    } catch as e {
        LogError("Paste failed: " . e.message)
        ShowError("Paste failed: " . e.message)
        return false
    }
}

; End Excel session (call when done)
EndExcelSession() {
    global xl_session, wb_session, current_file

    try {
        LogInfo("Ending Excel session")

        if (wb_session != "") {
            wb_session.Close(false)  ; Don't save
            wb_session := ""
        }

        if (xl_session != "") {
            xl_session.Quit()
            xl_session := ""
        }

        current_file := ""
        LogInfo("Excel session ended successfully")

    } catch as e {
        LogError("Error closing Excel: " . e.message)
        ShowError("Error closing Excel: " . e.message)
    }
}

; Force close all Excel instances
CloseAllExcelSafely() {
    LogInfo("Closing all Excel instances")

    ; First, try to close gracefully
    ClosedCount := 0
    while WinExist("ahk_exe EXCEL.EXE") {
        WinClose("ahk_exe EXCEL.EXE")
        ClosedCount++
        Sleep(500)  ; Give time to save/close

        ; If same window still exists after 3 seconds, break
        if (ClosedCount > 6) {
            break
        }
    }

    ; Then force kill any remaining processes
    KilledCount := 0
    while ProcessExist("EXCEL.EXE") {
        ProcessClose("EXCEL.EXE")
        KilledCount++
        Sleep(100)
    }

    LogInfo("Excel closed. Graceful: " . ClosedCount . ", Forced: " . KilledCount)

    if (ClosedCount > 0 || KilledCount > 0) {
        MsgBox("Excel instances closed. Graceful: " . ClosedCount . ", Forced: " . KilledCount)
    } else {
        MsgBox("No Excel instances were running.")
    }
}

; ============================================================================
; EXPORT FUNCTIONS
; ============================================================================

; Export parsed PDF data to a new Excel file
; labels: Array of objects with {description, price, ean, page}
; Returns: object with {success, count, path} or {success, error}
ExportLabelsToExcel(labels, outputPath := "") {
    if (labels.Length == 0) {
        LogError("No labels to export")
        return { success: false, error: "No labels to export" }
    }

    ; If no output path provided, prompt user
    if (outputPath == "") {
        outputPath := FileSelect("S", A_Desktop . "\price_change_export.xlsx",
            "Save Excel File", "Excel Files (*.xlsx)")
        if (!outputPath) {
            LogWarn("No output file selected for Excel export")
            return { success: false, error: "No output file selected" }
        }
        ; Ensure .xlsx extension
        if (!RegExMatch(outputPath, "i)\.xlsx$")) {
            outputPath .= ".xlsx"
        }
    }

    try {
        LogInfo("Exporting " . labels.Length . " labels to Excel: " . outputPath)

        ; Create new Excel application
        xl := ComObject("Excel.Application")
        xl.Visible := false
        xl.DisplayAlerts := false

        ; Create new workbook
        wb := xl.Workbooks.Add()
        ws := wb.Sheets(1)
        ws.Name := "Price Change"

        ; Add headers
        headers := ["Row", "EAN Code", "Description", "New Price", "Page"]
        loop headers.Length {
            ws.Cells(1, A_Index).Value := headers[A_Index]
            ws.Cells(1, A_Index).Font.Bold := true
        }

        ; Add data
        rowNum := 2
        validCount := 0
        for label in labels {
            ; Skip invalid entries
            if (!label.HasProp("ean") || label.ean == "" || label.ean == "null") {
                continue
            }
            if (!label.HasProp("price") || label.price == "" || label.price == 0 || label.price >= 9999) {
                continue
            }

            validCount++
            ws.Cells(rowNum, 1).Value := validCount  ; Row number
            ws.Cells(rowNum, 2).Value := "'" . label.ean  ; EAN as text (prefix with ')
            ws.Cells(rowNum, 3).Value := label.HasProp("description") ? label.description : ""
            ws.Cells(rowNum, 4).Value := label.price
            ws.Cells(rowNum, 5).Value := label.HasProp("page") ? label.page : ""
            rowNum++
        }

        ; Format columns
        ws.Columns("A:A").ColumnWidth := 8     ; Row
        ws.Columns("B:B").ColumnWidth := 18    ; EAN Code
        ws.Columns("C:C").ColumnWidth := 40    ; Description
        ws.Columns("D:D").ColumnWidth := 12    ; Price
        ws.Columns("E:E").ColumnWidth := 8     ; Page

        ; Format price column as currency
        ws.Columns("D:D").NumberFormat := "#,##0.00"

        ; Add autofilter to headers
        ws.Range("A1:E1").AutoFilter()

        ; Delete existing file if it exists
        if (FileExist(outputPath)) {
            try FileDelete(outputPath)
        }

        ; Save as xlsx (51 = xlOpenXMLWorkbook)
        wb.SaveAs(outputPath, 51)

        ; Close and cleanup
        wb.Close(false)
        xl.Quit()

        LogInfo("Successfully exported " . validCount . " items to Excel")
        return { success: true, count: validCount, path: outputPath }

    } catch as e {
        LogError("Failed to export to Excel: " . e.Message)

        ; Cleanup on error
        try {
            if (IsSet(wb) && wb != "")
                wb.Close(false)
            if (IsSet(xl) && xl != "")
                xl.Quit()
        }

        return { success: false, error: e.Message }
    }
}
