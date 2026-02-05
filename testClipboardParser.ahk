#SingleInstance Force
#Requires AutoHotkey >=v2.0

; ============================================================================
; CLIPBOARD PARSER TEST
; Copy data from GOLD, then press F1 to parse and see the result
; ============================================================================

global TestGui := ""
global ResultEdit := ""
global StatusText := ""

F1:: ShowParserGui()
Esc:: ExitApp()

ShowParserGui() {
    global TestGui, ResultEdit, StatusText

    if (TestGui != "") {
        try TestGui.Destroy()
    }

    TestGui := Gui("+AlwaysOnTop +Resize", "Clipboard Parser Test")
    TestGui.SetFont("s10", "Segoe UI")

    TestGui.Add("Text", "w500", "Copy the data from GOLD, then click 'Parse Clipboard'")

    ; Buttons
    TestGui.Add("Button", "y+10 w120 h30", "📋 Parse Clipboard").OnEvent("Click", OnParseClipboard)
    TestGui.Add("Button", "x+10 w120 h30", "💾 Save to JSON").OnEvent("Click", OnSaveToJson)
    TestGui.Add("Button", "x+10 w100 h30", "🗑️ Clear").OnEvent("Click", OnClear)

    ; Status
    StatusText := TestGui.Add("Text", "xm y+10 w500 cBlue", "Ready. Clipboard has " . StrLen(A_Clipboard) .
    " characters")

    ; Result area
    TestGui.Add("Text", "xm y+10", "Result:")
    ResultEdit := TestGui.Add("Edit", "xm y+5 w500 h400 ReadOnly -Wrap HScroll VScroll", "")

    TestGui.OnEvent("Close", (*) => TestGui.Destroy())
    TestGui.Show()
}

OnParseClipboard(*) {
    global ResultEdit, StatusText

    clipText := A_Clipboard

    if (clipText == "") {
        StatusText.Value := "❌ Clipboard is empty!"
        return
    }

    ; Parse the data
    items := ParseGoldClipboardData(clipText)

    if (items.Length == 0) {
        StatusText.Value := "❌ No valid data found in clipboard"
        ResultEdit.Value := "Could not parse clipboard content.`n`nClipboard preview:`n" . SubStr(clipText, 1, 500)
        return
    }

    ; Convert to JSON
    json := GoldDataToJson(items)

    ; Show result
    ResultEdit.Value := json
    StatusText.Value := "✅ Parsed " . items.Length . " items successfully!"
}

OnSaveToJson(*) {
    global ResultEdit, StatusText

    json := ResultEdit.Value

    if (json == "" || SubStr(json, 1, 1) != "[") {
        StatusText.Value := "❌ No parsed data to save. Parse clipboard first!"
        return
    }

    ; Ask where to save
    savePath := FileSelect("S", A_ScriptDir . "\gold_export.json", "Save JSON File", "JSON Files (*.json)")

    if (savePath == "") {
        StatusText.Value := "⚠️ Save cancelled"
        return
    }

    ; Ensure .json extension
    if (!InStr(savePath, ".json")) {
        savePath .= ".json"
    }

    try {
        file := FileOpen(savePath, "w", "UTF-8")
        file.Write(json)
        file.Close()
        StatusText.Value := "✅ Saved to: " . savePath
    } catch as e {
        StatusText.Value := "❌ Failed to save: " . e.Message
    }
}

OnClear(*) {
    global ResultEdit, StatusText
    ResultEdit.Value := ""
    StatusText.Value := "Cleared. Ready for new data."
}

; ============================================================================
; PARSER FUNCTIONS (embedded for standalone test)
; ============================================================================

ParseGoldClipboardData(clipboardText := "", hasHeader := true) {
    if (clipboardText == "") {
        clipboardText := A_Clipboard
    }

    lines := StrSplit(clipboardText, "`n", "`r")
    items := []
    startIndex := hasHeader ? 2 : 1

    loop lines.Length {
        if (A_Index < startIndex) {
            continue
        }

        line := Trim(lines[A_Index])

        if (line == "") {
            continue
        }

        columns := StrSplit(line, "`t")

        if (columns.Length < 1 || Trim(columns[1]) == "") {
            continue
        }

        ; Parse margin first to check if we should skip this item
        marginValue := columns.Length >= 9 ? ParsePrice(columns[9]) : 0

        ; Skip items where margin is 0 (only keep items with margin != 0)
        if (marginValue == 0) {
            continue
        }

        item := {
            articleCode: columns.Length >= 1 ? Trim(columns[1]) : "",
            description: columns.Length >= 2 ? Trim(columns[2]) : "",
            networkPrice: columns.Length >= 3 ? ParsePrice(columns[3]) : 0,
            implementedPrice: columns.Length >= 4 ? ParsePrice(columns[4]) : 0,
            newPrice: columns.Length >= 5 ? ParsePrice(columns[5]) : 0,
            newPriceEnd: columns.Length >= 6 ? Trim(columns[6]) : "",
            vatCode: columns.Length >= 7 ? Trim(columns[7]) : "",
            vatRate: columns.Length >= 8 ? ParsePrice(columns[8]) : 0,
            margin: marginValue,
            reasonCode: columns.Length >= 10 ? Trim(columns[10]) : "",
            priceListCode: columns.Length >= 11 ? Trim(columns[11]) : ""
        }

        items.Push(item)
    }

    return items
}

ParsePrice(priceStr) {
    priceStr := Trim(priceStr)
    if (priceStr == "") {
        return 0
    }
    try {
        return Number(priceStr)
    } catch {
        return 0
    }
}

GoldDataToJson(items) {
    json := "["

    loop items.Length {
        item := items[A_Index]

        if (A_Index > 1) {
            json .= ","
        }

        json .= "`n  {"
        json .= '`n    "articleCode": "' . EscapeJsonString(item.articleCode) . '",'
        json .= '`n    "description": "' . EscapeJsonString(item.description) . '",'
        json .= '`n    "networkPrice": ' . item.networkPrice . ','
        json .= '`n    "implementedPrice": ' . item.implementedPrice . ','
        json .= '`n    "newPrice": ' . item.newPrice . ','
        json .= '`n    "newPriceEnd": "' . EscapeJsonString(item.newPriceEnd) . '",'
        json .= '`n    "vatCode": "' . EscapeJsonString(item.vatCode) . '",'
        json .= '`n    "vatRate": ' . item.vatRate . ','
        json .= '`n    "margin": ' . item.margin . ','
        json .= '`n    "reasonCode": "' . EscapeJsonString(item.reasonCode) . '",'
        json .= '`n    "priceListCode": "' . EscapeJsonString(item.priceListCode) . '"'
        json .= "`n  }"
    }

    json .= "`n]"
    return json
}

EscapeJsonString(str) {
    str := StrReplace(str, "\", "\\")
    str := StrReplace(str, '"', '\"')
    str := StrReplace(str, "`n", "\n")
    str := StrReplace(str, "`r", "\r")
    str := StrReplace(str, "`t", "\t")
    return str
}

; Auto-start
ShowParserGui()