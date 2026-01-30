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