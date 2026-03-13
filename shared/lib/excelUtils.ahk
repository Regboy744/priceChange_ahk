#Requires AutoHotkey >=v2.0

; ============================================================================
; EXCEL UTILITIES
; COM Automation helpers for reading, writing, and exporting Excel files.
; ============================================================================

; ── Session state ─────────────────────────────────────────────────────────
global xl_session := ""
global wb_session := ""

; ── Session management ────────────────────────────────────────────────────

/**
 * Open (or re-open) an Excel COM session.
 * If filePath is empty the user is prompted with a file dialog.
 * 
 * @param filePath  (Optional) Absolute path to .xlsx/.xls/.xlsm
 * @returns true on success
 */
StartExcelSession(filePath := "") {
    global xl_session, wb_session

    if (xl_session != "")
        EndExcelSession()

    if (filePath == "") {
        filePath := FileSelect(, , "Select Excel File", "Excel Files (*.xlsx; *.xls; *.xlsm)")
        if (!filePath) {
            LogWarn("No file selected for Excel session")
            return false
        }
    }

    try {
        LogInfo("Starting Excel session with file: " . filePath)

        xl_session := ComObject("Excel.Application")
        xl_session.Visible := false
        xl_session.DisplayAlerts := false
        xl_session.ScreenUpdating := false

        wb_session := xl_session.Workbooks.Open(filePath)

        LogInfo("Excel session started successfully")
        return true

    } catch as e {
        LogError("Failed to start Excel session: " . e.message)
        ShowError("Failed to start Excel session: " . e.message)
        return false
    }
}

/**
 * Read a single cell value from the active workbook.
 */
GetExcelData(sheetName, column, row) {
    global xl_session, wb_session

    if (xl_session == "" || wb_session == "") {
        LogError("No Excel session active when trying to get data")
        ShowError("No Excel session active! Start session first.")
        return ""
    }

    try {
        ws := wb_session.Sheets(sheetName)
        cellValue := ws.Cells(row, column).Value
        LogDebug("Got value from " . sheetName . "[" . row . "," . column . "]: " . cellValue)
        return cellValue
    } catch as e {
        LogError("Get Excel data failed: " . e.message)
        ShowError("Get failed: " . e.message)
        return ""
    }
}

/**
 * Count rows with data starting from startRow in the given column.
 */
GetExcelRowCount(sheetName, column, startRow := 1) {
    global xl_session, wb_session

    if (xl_session == "" || wb_session == "") {
        LogError("No Excel session active when trying to count rows")
        ShowError("No Excel session active! Start session first.")
        return 0
    }

    try {
        ws := wb_session.Sheets(sheetName)
        lastRow := ws.Cells(ws.Rows.Count, column).End(-4162).Row   ; -4162 = xlUp

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

/**
 * Close the current workbook and quit Excel.
 */
EndExcelSession() {
    global xl_session, wb_session

    try {
        LogInfo("Ending Excel session")

        if (wb_session != "") {
            wb_session.Close(false)
            wb_session := ""
        }

        if (xl_session != "") {
            xl_session.Quit()
            xl_session := ""
        }

        LogInfo("Excel session ended successfully")

    } catch as e {
        LogError("Error closing Excel: " . e.message)
        ShowError("Error closing Excel: " . e.message)
    }
}

/**
 * Force-close every running Excel instance.
 */
CloseAllExcelSafely() {
    LogInfo("Closing all Excel instances")

    ClosedCount := 0
    while WinExist("ahk_exe EXCEL.EXE") {
        WinClose("ahk_exe EXCEL.EXE")
        ClosedCount++
        Sleep(500)
        if (ClosedCount > 6)
            break
    }

    KilledCount := 0
    while ProcessExist("EXCEL.EXE") {
        ProcessClose("EXCEL.EXE")
        KilledCount++
        Sleep(100)
    }

    LogInfo("Excel closed. Graceful: " . ClosedCount . ", Forced: " . KilledCount)

    if (ClosedCount > 0 || KilledCount > 0)
        MsgBox("Excel instances closed. Graceful: " . ClosedCount . ", Forced: " . KilledCount)
    else
        MsgBox("No Excel instances were running.")
}

; ============================================================================
; EXPORT — write parsed PDF labels to a brand-new Excel file
; ============================================================================

/**
 * Create a new .xlsx workbook from an array of label objects.
 * 
 * @param labels     Array of { ean, price, description?, page? }
 * @param outputPath (Optional) Where to save. Prompts if omitted.
 * @returns {Object} { success, count, path } or { success, error }
 */
ExportLabelsToExcel(labels, outputPath := "") {
    if (labels.Length == 0) {
        LogError("No labels to export")
        return { success: false, error: "No labels to export" }
    }

    if (outputPath == "") {
        outputPath := FileSelect("S", A_Desktop . "\price_change_export.xlsx",
            "Save Excel File", "Excel Files (*.xlsx)")
        if (!outputPath) {
            LogWarn("No output file selected for Excel export")
            return { success: false, error: "No output file selected" }
        }
        if (!RegExMatch(outputPath, "i)\.xlsx$"))
            outputPath .= ".xlsx"
    }

    try {
        LogInfo("Exporting " . labels.Length . " labels to Excel: " . outputPath)

        xl := ComObject("Excel.Application")
        xl.Visible := false
        xl.DisplayAlerts := false

        wb := xl.Workbooks.Add()
        ws := wb.Sheets(1)
        ws.Name := "Price Change"

        ; Headers
        headers := ["Row", "EAN Code", "Description", "New Price", "Page"]
        loop headers.Length {
            ws.Cells(1, A_Index).Value := headers[A_Index]
            ws.Cells(1, A_Index).Font.Bold := true
        }

        ; Data rows
        rowNum := 2
        validCount := 0
        for label in labels {
            if (!label.HasProp("ean") || label.ean == "" || label.ean == "null")
                continue
            if (!label.HasProp("price") || label.price == "" || label.price == 0 || label.price >= 9999)
                continue

            validCount++
            ws.Cells(rowNum, 1).Value := validCount
            ws.Cells(rowNum, 2).Value := "'" . label.ean
            ws.Cells(rowNum, 3).Value := label.HasProp("description") ? label.description : ""
            ws.Cells(rowNum, 4).Value := label.price
            ws.Cells(rowNum, 5).Value := label.HasProp("page") ? label.page : ""
            rowNum++
        }

        ; Formatting
        ws.Columns("A:A").ColumnWidth := 8
        ws.Columns("B:B").ColumnWidth := 18
        ws.Columns("C:C").ColumnWidth := 40
        ws.Columns("D:D").ColumnWidth := 12
        ws.Columns("E:E").ColumnWidth := 8
        ws.Columns("D:D").NumberFormat := "#,##0.00"
        ws.Range("A1:E1").AutoFilter()

        ; Save
        if (FileExist(outputPath))
            try FileDelete(outputPath)

        wb.SaveAs(outputPath, 51)   ; 51 = xlOpenXMLWorkbook
        wb.Close(false)
        xl.Quit()

        LogInfo("Successfully exported " . validCount . " items to Excel")
        return { success: true, count: validCount, path: outputPath }

    } catch as e {
        LogError("Failed to export to Excel: " . e.Message)
        try {
            if (IsSet(wb) && wb != "")
                wb.Close(false)
            if (IsSet(xl) && xl != "")
                xl.Quit()
        }
        return { success: false, error: e.Message }
    }
}