; Global variables to keep Excel session open
xl_session := ""
wb_session := ""
current_file := ""

; Start Excel session (call once)
StartExcelSession(filePath := "") {
    global xl_session, wb_session, current_file

    ; Close existing session if open
    if (xl_session != "") {
        EndExcelSession()
    }

    ; Select file if not provided
    if (filePath == "") {
        filePath := FileSelect(, , "Select Excel File", "Excel Files (*.xlsx; *.xls; *.xlsm)")
        if (!filePath)
            return false
    }

    try {
        ; Create Excel application
        xl_session := ComObject("Excel.Application")
        xl_session.Visible := false  ; Keep hidden for speed
        xl_session.DisplayAlerts := false
        xl_session.ScreenUpdating := false  ; Disable screen updates for speed

        ; Open workbook
        wb_session := xl_session.Workbooks.Open(filePath)
        current_file := filePath

        return true

    } catch as e {
        MsgBox "Failed to start Excel session: " e.message
        return false
    }
}

StartDateOfNewPrice(startDate) {
    try {
        ; Click on Start date of the new price
        Click(269, 205)
        Sleep(600)

        ; Add the START_DATE_NEW_PRICE to clipboard memory
        A_Clipboard := startDate
        Sleep(333)

        ; Select the Start date
        Send("^a")
        Sleep(100)

        ; Paste the Start date of the new price
        Send("^v")
        Sleep(333)

        return true

    } catch as e {
        MsgBox "Failed to set start date: " e.Message
        return false
    }
}

; Fast GET function using existing session
GetExcelData(sheetName, column, row) {
    global xl_session, wb_session, current_file

    ; Check if session exists
    if (xl_session == "" || wb_session == "") {
        MsgBox "No Excel session active! Start session first."
        return ""
    }

    try {
        ; Access sheet directly (no file opening overhead)
        ws := wb_session.Sheets(sheetName)

        ; Get data from cell
        cellValue := ws.Cells(row, column).Value

        return cellValue

    } catch as e {
        MsgBox "Get failed: " e.message
        return ""
    }
}

; End Excel session (call when done)
EndExcelSession() {
    global xl_session, wb_session, current_file

    try {
        if (wb_session != "") {
            wb_session.Close(false)  ; Don't save
            wb_session := ""
        }

        if (xl_session != "") {
            xl_session.Quit()
            xl_session := ""
        }

        current_file := ""

    } catch as e {
        MsgBox "Error closing Excel: " e.message
    }
}

; Count rows with data starting from a specific row
GetExcelRowCount(sheetName, column, startRow := 1) {
    global xl_session, wb_session, current_file

    ; Check if session exists
    if (xl_session == "" || wb_session == "") {
        MsgBox "No Excel session active! Start session first."
        return 0
    }

    try {
        ; Access sheet directly
        ws := wb_session.Sheets(sheetName)

        ; Find last row with data in the specified column
        lastRow := ws.Cells(ws.Rows.Count, column).End(-4162).Row

        ; Calculate count from startRow to lastRow
        if (lastRow >= startRow) {
            return lastRow - startRow + 1  ; +1 to include the startRow
        } else {
            return 0  ; No data from startRow onwards
        }

    } catch as e {
        MsgBox "Get row count failed: " e.message
        return 0
    }
}

; Enhanced paste function with validation and options
PasteExcelData(sheetName, column, row, dataValue, autoSave := false) {
    global xl_session, wb_session, current_file

    ; Check if session exists
    if (xl_session == "" || wb_session == "") {
        MsgBox "No Excel session active! Start session first."
        return false
    }

    try {
        ; Access sheet with error handling
        ws := wb_session.Sheets(sheetName)

        ; Check if sheet is protected
        if (ws.ProtectContents) {
            MsgBox "Sheet '" . sheetName . "' is protected! Cannot paste."
            return false
        }

        ; Paste the data
        ws.Cells(row, column).Value := dataValue

        ; Optional: Save immediately
        if (autoSave) {
            wb_session.Save()
        }

        return true

    } catch as e {
        MsgBox "Paste failed: " e.message
        return false
    }
}

; Flexible click function that can either just click or click and send text
clickSomething(x, y, value := "") {
    ; Click at the specified coordinates
    Click(x, y)
    Sleep(100)
    Send("^a")
    Sleep(333)

    ; If a value is provided, send it as text
    if (value != "") {
        SendText(value)
    }
}

; Function to click and retrieve the value at the specified coordinates
clickAndGetValue(x, y) {
    ; Click at the specified coordinates
    Click(x, y)
    Sleep(100)

    ; Select all content
    ; Send("^a")
    Sleep(333)

    ; Copy to clipboard
    A_Clipboard := ""  ; Clear clipboard first
    Send("^c")

    ; Wait for clipboard to contain data (with timeout)
    if (!ClipWait(1)) {
        return ""  ; Return empty if copy failed
    }

    ; Return the clipboard content
    return A_Clipboard
}


; Function to separate a value like "1418892-00" into two parts
separateValue(fullValue) {
    ; Split the value at the dash character
    parts := StrSplit(fullValue, "-")

    ; Create an object to return both values
    result := {}
    result.valueOne := parts[1]     ; First part (before dash)
    result.valueTwo := parts[2]     ; Second part (after dash)

    return result
}

; Function to get any specific line from multi-line text
getLine(InputText, LineNumber := 2) {
    ; Remove any carriage returns and split by line breaks
    CleanText := StrReplace(InputText, "`r", "")
    Lines := StrSplit(CleanText, "`n")

    ; Check if the line number exists
    if (LineNumber <= Lines.Length && LineNumber > 0) {
        return Lines[LineNumber]
    } else {
        return ""  ; Return empty if line doesn't exist
    }
}

; Function that tries graceful close first, then force kill
CloseAllExcelSafely() {
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

    if (ClosedCount > 0 || KilledCount > 0) {
        MsgBox("Excel instances closed. Graceful: " . ClosedCount . ", Forced: " . KilledCount)
    } else {
        MsgBox("No Excel instances were running.")
    }
}