#Requires AutoHotkey >=v2.0

; ============================================================================
; JSON UTILITIES
; Simple JSON parser for reading parsed PDF output
; ============================================================================

; Parse JSON string into AHK object
; Supports: objects, arrays, strings, numbers, booleans, null
ParseJSON(jsonStr) {
    ; Clean the string
    jsonStr := Trim(jsonStr)

    ; Use recursive descent parsing
    pos := 1
    return _ParseValue(&pos, jsonStr)
}

_ParseValue(&pos, str) {
    _SkipWhitespace(&pos, str)

    if (pos > StrLen(str))
        return ""

    char := SubStr(str, pos, 1)

    if (char == '"')
        return _ParseString(&pos, str)
    else if (char == '[')
        return _ParseArray(&pos, str)
    else if (char == '{')
        return _ParseObject(&pos, str)
    else if (char == 't' || char == 'f')
        return _ParseBool(&pos, str)
    else if (char == 'n')
        return _ParseNull(&pos, str)
    else if (_IsDigit(char) || char == '-')
        return _ParseNumber(&pos, str)

    return ""
}

_ParseString(&pos, str) {
    if (SubStr(str, pos, 1) != '"')
        return ""

    pos++  ; Skip opening quote
    result := ""
    backslash := "\"  ; Store backslash in variable for comparison

    while (pos <= StrLen(str)) {
        char := SubStr(str, pos, 1)

        if (char == '"') {
            pos++  ; Skip closing quote
            return result
        }

        if (char == backslash) {
            pos++
            if (pos > StrLen(str))
                break
            nextChar := SubStr(str, pos, 1)
            if (nextChar == 'n')
                result .= "`n"
            else if (nextChar == 'r')
                result .= "`r"
            else if (nextChar == 't')
                result .= "`t"
            else if (nextChar == backslash)
                result .= backslash
            else if (nextChar == '"')
                result .= '"'
            else if (nextChar == '/')
                result .= '/'
            else if (nextChar == 'u') {
                ; Unicode escape \uXXXX
                hexCode := SubStr(str, pos + 1, 4)
                if (StrLen(hexCode) == 4) {
                    try {
                        result .= Chr(Integer("0x" . hexCode))
                    } catch {
                        result .= "?"
                    }
                    pos += 4
                }
            }
            else
                result .= nextChar
            pos++
        } else {
            result .= char
            pos++
        }
    }

    return result
}

_ParseNumber(&pos, str) {
    start := pos

    ; Handle negative
    if (SubStr(str, pos, 1) == '-')
        pos++

    ; Integer part
    while (pos <= StrLen(str) && _IsDigit(SubStr(str, pos, 1)))
        pos++

    ; Decimal part
    if (SubStr(str, pos, 1) == '.') {
        pos++
        while (pos <= StrLen(str) && _IsDigit(SubStr(str, pos, 1)))
            pos++
    }

    ; Exponent part
    expChar := SubStr(str, pos, 1)
    if (expChar == 'e' || expChar == 'E') {
        pos++
        signChar := SubStr(str, pos, 1)
        if (signChar == '+' || signChar == '-')
            pos++
        while (pos <= StrLen(str) && _IsDigit(SubStr(str, pos, 1)))
            pos++
    }

    numStr := SubStr(str, start, pos - start)
    try {
        return Number(numStr)
    } catch {
        return 0
    }
}

_ParseBool(&pos, str) {
    if (SubStr(str, pos, 4) == 'true') {
        pos += 4
        return true
    }
    if (SubStr(str, pos, 5) == 'false') {
        pos += 5
        return false
    }
    return false
}

_ParseNull(&pos, str) {
    if (SubStr(str, pos, 4) == 'null') {
        pos += 4
        return ""
    }
    return ""
}

_ParseArray(&pos, str) {
    if (SubStr(str, pos, 1) != '[')
        return []

    pos++  ; Skip opening bracket
    arr := []

    _SkipWhitespace(&pos, str)

    ; Empty array
    if (SubStr(str, pos, 1) == ']') {
        pos++
        return arr
    }

    loop {
        _SkipWhitespace(&pos, str)
        value := _ParseValue(&pos, str)
        arr.Push(value)

        _SkipWhitespace(&pos, str)
        char := SubStr(str, pos, 1)

        if (char == ']') {
            pos++
            break
        }

        if (char == ',')
            pos++
        else
            break
    }

    return arr
}

_ParseObject(&pos, str) {
    if (SubStr(str, pos, 1) != '{')
        return {}

    pos++  ; Skip opening brace
    obj := {}

    _SkipWhitespace(&pos, str)

    ; Empty object
    if (SubStr(str, pos, 1) == '}') {
        pos++
        return obj
    }

    loop {
        _SkipWhitespace(&pos, str)

        ; Parse key
        key := _ParseString(&pos, str)

        if (key == "")
            break

        _SkipWhitespace(&pos, str)

        ; Skip colon
        if (SubStr(str, pos, 1) == ':')
            pos++

        _SkipWhitespace(&pos, str)

        ; Parse value
        value := _ParseValue(&pos, str)

        ; Use bracket notation for safety
        obj.%key% := value

        _SkipWhitespace(&pos, str)
        char := SubStr(str, pos, 1)

        if (char == '}') {
            pos++
            break
        }

        if (char == ',')
            pos++
        else
            break
    }

    return obj
}

_SkipWhitespace(&pos, str) {
    while (pos <= StrLen(str)) {
        char := SubStr(str, pos, 1)
        if (char != ' ' && char != '`t' && char != '`n' && char != '`r')
            break
        pos++
    }
}

_IsDigit(char) {
    code := Ord(char)
    return code >= 48 && code <= 57  ; ASCII 0-9
}

; ============================================================================
; FILE READING
; ============================================================================

; Helper to safely log errors (LogError may not be available)
_JsonLogError(msg) {
    if IsSet(LogError)
        LogError(msg)
}

; Read and parse a JSON file
ReadJSONFile(filePath) {
    if (!FileExist(filePath)) {
        _JsonLogError("JSON file not found: " . filePath)
        return ""
    }

    try {
        content := FileRead(filePath, "UTF-8")
        return ParseJSON(content)
    } catch as e {
        _JsonLogError("Failed to read JSON file: " . e.Message)
        return ""
    }
}
