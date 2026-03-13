#Requires AutoHotkey >=v2.0

; Depends on CalculateCostPrice() from stringUtils
#Include stringUtils.ahk

; ============================================================================
; CSV UTILITIES
; Parse GOLD clipboard data and append to a CSV export file.
; ============================================================================

global CSV_FILE_PATH := ProjectPath("gold_export.csv")
global CSV_INITIALIZED := false

; ── File management ───────────────────────────────────────────────────────

/**
 * Create (or overwrite) the CSV with header row.
 * Call once at the start of an export session.
 */
InitializeCsvFile(filePath := "") {
    global CSV_FILE_PATH, CSV_INITIALIZED

    if (filePath != "")
        CSV_FILE_PATH := filePath

    try {
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

/** Return the path currently in use. */
GetCsvFilePath() {
    global CSV_FILE_PATH
    return CSV_FILE_PATH
}

/** Reset the initialized flag so the next append re-creates the file. */
ResetCsvFile() {
    global CSV_INITIALIZED
    CSV_INITIALIZED := false
}

; ── Clipboard → CSV ──────────────────────────────────────────────────────

/**
 * Parse GOLD clipboard text and append rows to the CSV.
 * 
 * @param department    e.g. "D0024 - GROCERY - IMPULSE"
 * @param subDepartment e.g. "S0001 - IMPULSE CONFECTIONERY"
 * @param section       e.g. "C0001 - CHOCOLATE"
 * @param familyGroup   e.g. "F0001"
 * @param clipboardText (Optional) Raw text; defaults to A_Clipboard
 * @returns Number of items added, or -1 on error
 */
AppendClipboardToCsv(department, subDepartment, section, familyGroup, clipboardText := "") {
    global CSV_FILE_PATH, CSV_INITIALIZED

    if (!CSV_INITIALIZED)
        InitializeCsvFile()

    if (clipboardText == "")
        clipboardText := A_Clipboard

    if (clipboardText == "") {
        LogError("Clipboard is empty")
        return -1
    }

    items := ParseGoldData(clipboardText)

    if (items.Length == 0) {
        LogDebug("No valid items found in clipboard for family group: " . familyGroup)
        return 0
    }

    try {
        file := FileOpen(CSV_FILE_PATH, "a", "UTF-8")

        for item in items {
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
        LogDebug("Added " . items.Length . " items to CSV for: "
            . department . " > " . subDepartment . " > " . section . " > " . familyGroup)
        return items.Length

    } catch as e {
        LogError("Failed to append to CSV: " . e.Message)
        return -1
    }
}

; ── GOLD data parser ─────────────────────────────────────────────────────

/**
 * Parse tab-separated GOLD clipboard text into an array of item objects.
 * 
 * @param clipboardText  Raw text (tab-separated columns, newline-separated rows)
 * @param hasHeader      Whether the first row is a header (default: true)
 * @returns {Array}      Array of item objects
 */
ParseGoldData(clipboardText, hasHeader := true) {
    lines := StrSplit(clipboardText, "`n", "`r")
    items := []
    startIndex := hasHeader ? 2 : 1

    loop lines.Length {
        if (A_Index < startIndex)
            continue

        line := Trim(lines[A_Index])
        if (line == "")
            continue

        columns := StrSplit(line, "`t")
        if (columns.Length < 1 || Trim(columns[1]) == "")
            continue

        ; Skip rows with zero margin
        marginValue := columns.Length >= 9 ? ParsePriceValue(columns[9]) : 0
        if (marginValue == 0)
            continue

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

; ── Price string → Number ─────────────────────────────────────────────────

/**
 * Normalise a price string (handles comma/dot decimals) and return a Number.
 */
ParsePriceValue(priceStr) {
    priceStr := Trim(priceStr)
    if (priceStr == "")
        return 0

    priceStr := RegExReplace(priceStr, "[^\d,\.\-]", "")

    if (priceStr == "" || priceStr == "-" || priceStr == "." || priceStr == ",")
        return 0

    hasComma := InStr(priceStr, ",")
    hasDot := InStr(priceStr, ".")

    if (hasComma && hasDot) {
        if (hasComma > hasDot) {
            ; Dot = thousands, Comma = decimal  (e.g. 1.234,56)
            priceStr := StrReplace(priceStr, ".", "")
            priceStr := StrReplace(priceStr, ",", ".")
        } else {
            ; Comma = thousands  (e.g. 1,234.56)
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

; ── CSV helpers ───────────────────────────────────────────────────────────

/** Escape a value for CSV output (RFC 4180). */
EscapeCsvField(field) {
    field := String(field)

    if (InStr(field, ",") || InStr(field, '"') || InStr(field, "`n") || InStr(field, "`r")) {
        field := StrReplace(field, '"', '""')
        field := '"' . field . '"'
    }

    return field
}

; ── Generic tab-delimited parser ──────────────────────────────────────────

/**
 * Parse tab-delimited text (with a header row) into an array of Map objects.
 * Each Map is keyed by the column headers from the first row.
 * 
 * @param text       Raw tab-separated text (e.g. from clipboard)
 * @param delimiter  Column separator (default: Tab)
 * @returns {Array}  Array of Map objects, one per data row
 */
ParseTabDelimited(text, delimiter := "`t") {
    lines := StrSplit(text, "`n", "`r")
    results := []

    if (lines.Length < 2)
        return results

    ; ── Parse header row ──────────────────────────────────────────────
    headers := StrSplit(lines[1], delimiter)
    headerCount := headers.Length

    loop headerCount
        headers[A_Index] := Trim(headers[A_Index])

    ; ── Parse data rows ───────────────────────────────────────────────
    loop lines.Length - 1 {
        rowIndex := A_Index + 1
        line := Trim(lines[rowIndex])
        if (line == "")
            continue

        columns := StrSplit(line, delimiter)
        row := Map()

        loop headerCount {
            key := headers[A_Index]
            value := columns.Length >= A_Index ? Trim(columns[A_Index]) : ""
            row[key] := value
        }

        results.Push(row)
    }

    return results
}

; ── Structured CSV file writer ────────────────────────────────────────────

/**
 * Write an array of Map/Object rows to a CSV file with the given headers.
 * Uses RFC 4180 escaping via EscapeCsvField().
 * 
 * @param filePath   Absolute path to the output file (overwritten)
 * @param headers    Array of column header strings (also used as Map keys)
 * @param rows       Array of Map objects keyed by header names
 * @returns {Boolean} true on success, false on error
 */
WriteCsvFile(filePath, headers, rows) {
    try {
        file := FileOpen(filePath, "w", "UTF-8")

        ; ── Header line ───────────────────────────────────────────────
        headerLine := ""
        for i, h in headers {
            if (i > 1)
                headerLine .= ","
            headerLine .= EscapeCsvField(h)
        }
        file.WriteLine(headerLine)

        ; ── Data lines ────────────────────────────────────────────────
        for row in rows {
            line := ""
            for i, h in headers {
                if (i > 1)
                    line .= ","
                value := row.Has(h) ? row[h] : ""
                line .= EscapeCsvField(value)
            }
            file.WriteLine(line)
        }

        file.Close()
        return true

    } catch as e {
        LogError("WriteCsvFile failed: " . e.Message)
        return false
    }
}
