#Requires AutoHotkey >=v2.0

; ============================================================================
; STRING UTILITIES
; Pure functions for string manipulation and price/cost calculations.
; No external dependencies — safe to include anywhere.
; ============================================================================

; ── String helpers ────────────────────────────────────────────────────────

/**
 * Split a string like "1418892-00" into two parts at the delimiter.
 * @returns {Object}  { valueOne, valueTwo }
 */
SplitValueParts(fullValue, delimiter := "-") {
    parts := StrSplit(fullValue, delimiter)
    return {
        valueOne: parts.Length >= 1 ? parts[1] : "",
        valueTwo: parts.Length >= 2 ? parts[2] : ""
    }
}

/** Trim all whitespace from a string. */
TrimAll(text) {
    return Trim(text)
}

/** Return true if text is empty or whitespace-only. */
IsEmpty(text) {
    return Trim(text) == ""
}

/** Round a number to the given decimal places. */
FormatNumber(number, decimalPlaces := 2) {
    return Round(number, decimalPlaces)
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

/**
 * Strip VAT from a selling price.
 * @example GetPriceExVat(12.30, 23)  ; → 10.00
 */
GetPriceExVat(sellingPrice, vatRate, decimalPlaces := 2) {
    vatMultiplier := 1 + (vatRate / 100)
    return Round(sellingPrice / vatMultiplier, decimalPlaces)
}

/**
 * Return the VAT portion of a selling price.
 * @example GetVatAmount(12.30, 23)  ; → 2.30
 */
GetVatAmount(sellingPrice, vatRate, decimalPlaces := 2) {
    priceExVat := GetPriceExVat(sellingPrice, vatRate, decimalPlaces + 3)
    return Round(sellingPrice - priceExVat, decimalPlaces)
}
