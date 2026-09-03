#Requires AutoHotkey >=v2.0

; ============================================================================
; STRING UTILITIES
; Pure functions for string manipulation and price/cost calculations.
; No external dependencies — safe to include anywhere.
; ============================================================================

; ── String helpers ────────────────────────────────────────────────────────

/** Round a number to the given decimal places. */
FormatNumber(number, decimalPlaces := 2) {
    return Round(number, decimalPlaces)
}

; ── Paste-list parsing ─────────────────────────────────────────────────────
; Helpers for the "copy & paste" data source. Users copy a list straight from
; Excel (or type it), so the input is tolerant of Tab / space / comma /
; semicolon column separators and European "1,99" decimals.

/**
 * Normalize a numeric token to use "." as the decimal separator.
 * Handles European "1,99" and mixed thousands forms ("1.234,56" / "1,234.56").
 *
 * @param token  Raw numeric text (e.g. "1,99", "1.234,56").
 * @returns A string using "." for the decimal point and no thousands separators.
 */
NormalizeDecimalSeparator(token) {
    token := Trim(token)
    hasDot := InStr(token, ".")
    hasComma := InStr(token, ",")

    if (hasDot && hasComma) {
        ; The right-most separator is the decimal point; the other one is a
        ; thousands separator and gets stripped.
        if (InStr(token, ",", , , -1) > InStr(token, ".", , , -1)) {
            token := StrReplace(token, ".", "")     ; dots = thousands
            token := StrReplace(token, ",", ".")    ; comma = decimal
        } else {
            token := StrReplace(token, ",", "")     ; commas = thousands
        }
    } else if (hasComma) {
        token := StrReplace(token, ",", ".")        ; lone comma = decimal
    }

    return token
}

/**
 * Parse pasted "EAN + price" rows into a list of items.
 * Each non-empty line must start with a numeric EAN (3+ digits) followed by a
 * price; the EAN and price may be separated by Tab, space, comma or semicolon.
 *
 * @param text  Raw multi-line clipboard text.
 * @returns { items: Array of {ean, price}, skipped: Integer } where price is a
 *          number rounded to 2 decimals (same shape the PDF/Excel loaders use).
 */
ParsePastedPriceList(text) {
    items := []
    skipped := 0

    for line in StrSplit(text, "`n", "`r") {
        trimmed := Trim(line, " `t`r`n")
        if (trimmed == "")
            continue

        ; EAN = the leading run of digits (stops at the first separator).
        if (!RegExMatch(trimmed, "^(\d{3,})", &m)) {
            skipped++
            continue
        }
        ean := m[1]

        ; First numeric token in the remainder is the price. The character class
        ; allows internal "." / "," so thousands + decimal forms ("1.234,56")
        ; survive intact for NormalizeDecimalSeparator to interpret.
        rest := SubStr(trimmed, StrLen(ean) + 1)
        if (!RegExMatch(rest, "[-+]?\d[\d.,]*\d|[-+]?\d", &pm)) {
            skipped++
            continue
        }

        priceNum := NormalizeDecimalSeparator(pm[0]) + 0
        items.Push({ ean: ean, price: FormatNumber(priceNum, 2) })
    }

    return { items: items, skipped: skipped }
}

/**
 * Parse pasted EAN codes into a list. Each non-empty line must start with a
 * numeric EAN (3+ digits); any trailing columns are ignored.
 *
 * @param text  Raw multi-line clipboard text.
 * @returns { items: Array of ean strings, skipped: Integer }
 */
ParsePastedEanList(text) {
    items := []
    skipped := 0

    for line in StrSplit(text, "`n", "`r") {
        trimmed := Trim(line, " `t`r`n")
        if (trimmed == "")
            continue

        if (!RegExMatch(trimmed, "^(\d{3,})", &m)) {
            skipped++
            continue
        }

        items.Push(m[1])
    }

    return { items: items, skipped: skipped }
}

; ── Price / Cost calculations ─────────────────────────────────────────────

/**
 * Calculate cost price from selling price, VAT rate, and margin.
 * 
 * Formula:  costPrice = sellingPrice / (1 + VAT%) × (1 − Margin%)
 * 
 * @param sellingPrice   Selling price including VAT (e.g. 10.99)
 * @param vatRate        VAT as a number, NOT a fraction (e.g. 23 for 23 %)
 * @param margin         Margin as a number (e.g. 25 for 25 %)
 * @param decimalPlaces  Rounding precision (default 2)
 * @returns {Number}
 * 
 * @example CalculateCostPrice(2.20, 23, 51.61)  ; → 0.87
 */
CalculateCostPrice(sellingPrice, vatRate, margin, decimalPlaces := 2) {
    vatMultiplier := 1 + (vatRate / 100)
    marginMultiplier := 1 - (margin / 100)
    priceExVat := sellingPrice / vatMultiplier
    costPrice := priceExVat * marginMultiplier
    return Round(costPrice, decimalPlaces)
}