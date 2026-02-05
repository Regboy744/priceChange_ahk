#Requires AutoHotkey >=v2.0

; ============================================================================
; STRING UTILITIES
; Functions for string manipulation
; ============================================================================

; Function to separate a value like "1418892-00" into two parts
SplitValueParts(fullValue, delimiter := "-") {
    ; Split the value at the delimiter character
    parts := StrSplit(fullValue, delimiter)

    ; Create an object to return both values
    result := {}
    result.valueOne := parts.Length >= 1 ? parts[1] : ""
    result.valueTwo := parts.Length >= 2 ? parts[2] : ""

    return result
}

; Function to get any specific line from multi-line text

; Trim whitespace from string
TrimAll(text) {
    return Trim(text)
}

; Check if string is empty or whitespace only
IsEmpty(text) {
    return Trim(text) == ""
}

; Format number to specified decimal places
FormatNumber(number, decimalPlaces := 2) {
    return Round(number, decimalPlaces)
}

; ============================================================================
; PRICE CALCULATION UTILITIES
; Functions for calculating cost prices from selling prices
; ============================================================================

/**
 * Calculate the cost price from selling price, VAT rate, and margin
 * 
 * Formula: costPrice = sellingPrice / (1 + VAT%) * (1 - Margin%)
 * 
 * @param sellingPrice - The selling price including VAT (e.g., 10.99)
 * @param vatRate      - VAT rate as number, NOT percentage (e.g., 23 for 23%, 13.5 for 13.5%)
 * @param margin       - Margin as number, NOT percentage (e.g., 25 for 25%)
 * @param decimalPlaces - (Optional) Number of decimal places to round to. Default: 2
 * @returns The calculated cost price
 * 
 * @example CalculateCostPrice(2.20, 23, 51.61)   ; Returns 0.87
 * @example CalculateCostPrice(3.50, 23, 45)     ; Returns 1.57
 */
CalculateCostPrice(sellingPrice, vatRate, margin, decimalPlaces := 2) {
    ; Convert VAT from number to multiplier (e.g., 23 -> 1.23)
    vatMultiplier := 1 + (vatRate / 100)

    ; Convert margin from number to multiplier (e.g., 45 -> 0.55)
    marginMultiplier := 1 - (margin / 100)

    ; Calculate: sellingPrice / vatMultiplier * marginMultiplier
    priceExVat := sellingPrice / vatMultiplier
    costPrice := priceExVat * marginMultiplier

    return Round(costPrice, decimalPlaces)
}

/**
 * Calculate price excluding VAT from selling price
 * 
 * @param sellingPrice - The selling price including VAT
 * @param vatRate      - VAT rate as number (e.g., 23 for 23%)
 * @param decimalPlaces - (Optional) Number of decimal places. Default: 2
 * @returns Price excluding VAT
 * 
 * @example GetPriceExVat(12.30, 23)  ; Returns 10.00
 */
GetPriceExVat(sellingPrice, vatRate, decimalPlaces := 2) {
    vatMultiplier := 1 + (vatRate / 100)
    return Round(sellingPrice / vatMultiplier, decimalPlaces)
}

/**
 * Calculate VAT amount from selling price
 * 
 * @param sellingPrice - The selling price including VAT
 * @param vatRate      - VAT rate as number (e.g., 23 for 23%)
 * @param decimalPlaces - (Optional) Number of decimal places. Default: 2
 * @returns The VAT amount
 * 
 * @example GetVatAmount(12.30, 23)  ; Returns 2.30
 */
GetVatAmount(sellingPrice, vatRate, decimalPlaces := 2) {
    priceExVat := GetPriceExVat(sellingPrice, vatRate, decimalPlaces + 2)
    return Round(sellingPrice - priceExVat, decimalPlaces)
}
