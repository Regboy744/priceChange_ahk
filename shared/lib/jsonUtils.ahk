#Requires AutoHotkey >=v2.0

; ============================================================================
; JSON UTILITIES
; Recursive-descent JSON parser for reading parsed PDF output.
; Supports: objects, arrays, strings, numbers, booleans, null.
; ============================================================================

; ── Public API ────────────────────────────────────────────────────────────

/**
 * Parse a JSON string into an AHK object/array.
 * @param jsonStr  Raw JSON text
 * @returns        AHK Object, Array, String, Number, or ""
 */
ParseJSON(jsonStr) {
    jsonStr := Trim(jsonStr)
    pos := 1
    return _ParseValue(&pos, jsonStr)
}

/**
 * Read a JSON file from disk and return the parsed result.
 * @param filePath  Absolute path to the .json file
 * @returns         Parsed object, or "" on failure
 */
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

; ── Internal parser ───────────────────────────────────────────────────────

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
    backslash := "\"

    while (pos <= StrLen(str)) {
        char := SubStr(str, pos, 1)

        if (char == '"') {
            pos++
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

    if (SubStr(str, pos, 1) == '-')
        pos++

    while (pos <= StrLen(str) && _IsDigit(SubStr(str, pos, 1)))
        pos++

    if (SubStr(str, pos, 1) == '.') {
        pos++
        while (pos <= StrLen(str) && _IsDigit(SubStr(str, pos, 1)))
            pos++
    }

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

    pos++
    arr := []

    _SkipWhitespace(&pos, str)

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

    pos++
    obj := {}

    _SkipWhitespace(&pos, str)

    if (SubStr(str, pos, 1) == '}') {
        pos++
        return obj
    }

    loop {
        _SkipWhitespace(&pos, str)

        key := _ParseString(&pos, str)
        if (key == "")
            break

        _SkipWhitespace(&pos, str)

        if (SubStr(str, pos, 1) == ':')
            pos++

        _SkipWhitespace(&pos, str)

        value := _ParseValue(&pos, str)
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

; ── Helpers ───────────────────────────────────────────────────────────────

/** Safe logger call — LogError may not be available in all include orders. */
_JsonLogError(msg) {
    if IsSet(LogError)
        LogError(msg)
}
