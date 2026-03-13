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