#Requires AutoHotkey >=v2.0

; ============================================================================
; PROJECT PATH UTILITIES
; Centralized path resolution for portable project references.
; Every script that needs the project root or a relative path should
; #Include this file first.
; ============================================================================

/**
 * Walk up the directory tree from the running script and return the
 * first folder that contains both `shared\config.ahk` AND `shared\lib\`.
 * Caches the result so the file-system scan only runs once per session.
 * 
 * @returns {String} Absolute path to the project root (no trailing backslash)
 */
GetProjectRoot() {
    static cachedRoot := ""

    if (cachedRoot != "") {
        return cachedRoot
    }

    currentDir := A_ScriptDir
    loop 12 {
        ; Primary layout: shared\config.ahk + shared\lib\
        hasConfig := FileExist(currentDir . "\shared\config.ahk")
        hasLib := DirExist(currentDir . "\shared\lib")

        if (hasConfig && hasLib) {
            cachedRoot := currentDir
            return cachedRoot
        }

        ; Walk one level up
        parentDir := RegExReplace(currentDir, "\\[^\\]+$", "")
        if (parentDir == currentDir || parentDir == "") {
            break
        }
        currentDir := parentDir
    }

    ; Fallback — assume script is somewhere inside the project
    cachedRoot := A_ScriptDir
    return cachedRoot
}

/**
 * Build an absolute path from a project-relative path.
 * 
 * @param relativePath  Path relative to the project root (e.g. "assets\icon.ico")
 *                      Accepts forward or back slashes. Leading slash is stripped.
 * @returns {String}    Absolute path (e.g. "C:\...\gold - PriceChange\assets\icon.ico")
 */
ProjectPath(relativePath := "") {
    rootDir := GetProjectRoot()

    if (relativePath == "") {
        return rootDir
    }

    normalizedRelative := StrReplace(relativePath, "/", "\")
    if (SubStr(normalizedRelative, 1, 1) == "\") {
        normalizedRelative := SubStr(normalizedRelative, 2)
    }

    return rootDir . "\" . normalizedRelative
}
