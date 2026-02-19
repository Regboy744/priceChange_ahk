#Requires AutoHotkey >=v2.0

; Include stringUtils for CalculateCostPrice function
#Include stringUtils.ahk

; ============================================================================
; CSV UTILITIES
; Functions for parsing GOLD clipboard data and saving to CSV
; ============================================================================

global CSV_FILE_PATH := A_ScriptDir . "\gold_export.csv"
global CSV_INITIALIZED := false

/**
 * Initialize CSV file with headers (call once at start of session)
 * @param filePath - (Optional) Path to CSV file. Default: gold_export.csv in script folder
 * @returns true if succeeded, false if failed
 * @example InitializeCsvFile()  ; Creates/overwrites CSV with headers
 */
InitializeCsvFile(filePath := "") {
    global CSV_FILE_PATH, CSV_INITIALIZED

    if (filePath != "") {
        CSV_FILE_PATH := filePath
    }

    try {
        ; Create header row
        headers :=
            "Department,SubDepartment,Section,FamilyGroup,ArticleCode,Description,NetworkPrice,ImplementedPrice,NewPrice,NewPriceEnd,VatCode,VatRate,Margin,CostPrice,ReasonCode,PriceListCode"

        file := FileOpen(CSV_FILE_PATH, "w", "UTF-8")
        file.WriteLine(headers)
        file.Close()

        CSV_INITIALIZED := true
        LogDebug("CSV file initialized: " . CSV_FILE_PATH)
        return true
    } catch as e {
        LogError("Failed to initialize CSV file: " . e.Message)
        return false
    }
}

/**
 * Parse clipboard data from GOLD and append to CSV file
 * @param department - The department name (e.g., "D0024 - GROCERY - IMPULSE")
 * @param subDepartment - The sub-department name (e.g., "S0001 - IMPULSE CONFECTIONERY")
 * @param section - The section name (e.g., "C0001 - CHOCOLATE")
 * @param familyGroup - The family group code (e.g., "F0001")
 * @param clipboardText - (Optional) Text to parse. Default: current clipboard content
 * @returns Number of items added, or -1 if failed
 * @example AppendClipboardToCsv("D0024 - GROCERY", "S0001 - IMPULSE", "C0001 - CHOCOLATE", "F0001")
 */
AppendClipboardToCsv(department, subDepartment, section, familyGroup, clipboardText := "") {
    global CSV_FILE_PATH, CSV_INITIALIZED

    ; Auto-initialize if not done yet
    if (!CSV_INITIALIZED) {
        InitializeCsvFile()
    }

    if (clipboardText == "") {
        clipboardText := A_Clipboard
    }

    if (clipboardText == "") {
        LogError("Clipboard is empty")
        return -1
    }

    ; Parse the clipboard data
    items := ParseGoldData(clipboardText)

    if (items.Length == 0) {
        LogDebug("No valid items found in clipboard for family group: " . familyGroup)
        return 0
    }

    try {
        ; Append to CSV file
        file := FileOpen(CSV_FILE_PATH, "a", "UTF-8")

        for item in items {
            ; Calculate cost price from ImplementedPrice, VatRate and Margin (4 decimal places)
            costPrice := CalculateCostPrice(item.implementedPrice, item.vatRate, item.margin, 4)

            line := EscapeCsvField(department) . ","
            line .= EscapeCsvField(subDepartment) . ","
            line .= EscapeCsvField(section) . ","
            line .= EscapeCsvField(familyGroup) . ","
            line .= EscapeCsvField(item.articleCode) . ","
            line .= EscapeCsvField(item.description) . ","
            line .= item.networkPrice . ","
            line .= item.implementedPrice . ","
            line .= item.newPrice . ","
            line .= EscapeCsvField(item.newPriceEnd) . ","
            line .= EscapeCsvField(item.vatCode) . ","
            line .= item.vatRate . ","
            line .= item.margin . ","
            line .= costPrice . ","
            line .= EscapeCsvField(item.reasonCode) . ","
            line .= EscapeCsvField(item.priceListCode)

            file.WriteLine(line)
        }

        file.Close()
        LogDebug("Added " . items.Length . " items to CSV for: " . department . " > " . subDepartment . " > " .
            section . " > " . familyGroup)
        return items.Length

    } catch as e {
        LogError("Failed to append to CSV: " . e.Message)
        return -1
    }
}

/**
 * Parse GOLD clipboard data into array of item objects
 * @param clipboardText - Tab-separated text from GOLD
 * @param hasHeader - (Optional) Whether first row is header. Default: true
 * @returns Array of item objects
 */
ParseGoldData(clipboardText, hasHeader := true) {
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

        ; Parse margin to check if we should skip this item
        marginValue := columns.Length >= 9 ? ParsePriceValue(columns[9]) : 0

        ; Skip items where margin is 0
        if (marginValue == 0) {
            continue
        }

        item := {
            articleCode: columns.Length >= 1 ? Trim(columns[1]) : "",
            description: columns.Length >= 2 ? Trim(columns[2]) : "",
            networkPrice: columns.Length >= 3 ? ParsePriceValue(columns[3]) : 0,
            implementedPrice: columns.Length >= 4 ? ParsePriceValue(columns[4]) : 0,
            newPrice: columns.Length >= 5 ? ParsePriceValue(columns[5]) : 0,
            newPriceEnd: columns.Length >= 6 ? Trim(columns[6]) : "",
            vatCode: columns.Length >= 7 ? Trim(columns[7]) : "",
            vatRate: columns.Length >= 8 ? ParsePriceValue(columns[8]) : 0,
            margin: marginValue,
            reasonCode: columns.Length >= 10 ? Trim(columns[10]) : "",
            priceListCode: columns.Length >= 11 ? Trim(columns[11]) : ""
        }

        items.Push(item)
    }

    return items
}

/**
 * Parse a price string to number
 * @param priceStr - Price string (e.g., "2.38" or "10,99")
 * @returns Number value, or 0 if invalid
 */
ParsePriceValue(priceStr) {
    priceStr := Trim(priceStr)
    if (priceStr == "") {
        return 0
    }

    ; Normalize common numeric formats from GOLD exports
    ; - remove spaces/currency/percent decorations
    ; - support both decimal comma and decimal dot
    priceStr := RegExReplace(priceStr, "[^\d,\.\-]", "")

    if (priceStr == "" || priceStr == "-" || priceStr == "." || priceStr == ",") {
        return 0
    }

    hasComma := InStr(priceStr, ",")
    hasDot := InStr(priceStr, ".")

    if (hasComma && hasDot) {
        ; If comma appears after dot, assume dot is thousands separator and comma is decimal
        if (hasComma > hasDot) {
            priceStr := StrReplace(priceStr, ".", "")
            priceStr := StrReplace(priceStr, ",", ".")
        } else {
            ; Otherwise assume comma is thousands separator
            priceStr := StrReplace(priceStr, ",", "")
        }
    } else if (hasComma) {
        priceStr := StrReplace(priceStr, ",", ".")
    }

    try {
        return Number(priceStr)
    } catch {
        return 0
    }
}

/**
 * Escape a field for CSV (handles commas, quotes, newlines)
 * @param field - The field value to escape
 * @returns Escaped field value
 */
EscapeCsvField(field) {
    field := String(field)

    ; If field contains comma, quote, or newline, wrap in quotes
    if (InStr(field, ",") || InStr(field, '"') || InStr(field, "`n") || InStr(field, "`r")) {
        ; Double any existing quotes
        field := StrReplace(field, '"', '""')
        ; Wrap in quotes
        field := '"' . field . '"'
    }

    return field
}

/**
 * Get the current CSV file path
 * @returns The path to the CSV file
 */
GetCsvFilePath() {
    global CSV_FILE_PATH
    return CSV_FILE_PATH
}

/**
 * Reset CSV tracking (useful if you want to start a new file)
 */
ResetCsvFile() {
    global CSV_INITIALIZED
    CSV_INITIALIZED := false
}
