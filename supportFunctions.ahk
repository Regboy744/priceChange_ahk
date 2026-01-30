#Requires AutoHotkey >=v2.0

; ============================================================================
; LEGACY SUPPORT FUNCTIONS
; This file is kept for backward compatibility.
; New code should use the modular files in the lib/ folder instead.
; ============================================================================

; Include all new modular files
#Include config.ahk
#Include lib\logger.ahk
#Include lib\excelUtils.ahk
#Include lib\uiUtils.ahk
#Include lib\stringUtils.ahk

; ============================================================================
; LEGACY FUNCTION ALIASES
; These maintain backward compatibility with old code
; ============================================================================

; Legacy alias for StartDateOfNewPrice
StartDateOfNewPrice(startDate) {
    return SetStartDate(startDate)
}

; Legacy alias for clickSomething
clickSomething(x, y, value := "") {
    return ClickAndType(x, y, value)
}

; Legacy alias for clickAndGetValue
clickAndGetValue(x, y) {
    return ClickAndGetValue(x, y)
}

; Legacy alias for separateValue
separateValue(fullValue) {
    return SeparateValue(fullValue)
}

; Legacy alias for getLine
getLine(InputText, LineNumber := 2) {
    return GetLine(InputText, LineNumber)
}