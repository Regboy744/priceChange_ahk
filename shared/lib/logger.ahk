#Requires AutoHotkey >=v2.0

; ============================================================================
; LOGGER UTILITY
; Centralized logging mechanism for debugging and audit trail.
; Writes timestamped entries to CONFIG.LOG_FILE in the project root.
; ============================================================================

; Log levels
global LOG_LEVEL := {
    DEBUG: "DEBUG",
    INFO: "INFO",
    WARN: "WARN",
    ERROR: "ERROR"
}

/**
 * Write a single log line to the project log file.
 * 
 * @param message  Human-readable message
 * @param level    One of LOG_LEVEL.* (default: "INFO")
 */
LogMessage(message, level := "INFO") {
    global CONFIG

    if (!CONFIG.LOG_ENABLED)
        return

    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    logLine := "[" . timestamp . "] [" . level . "] " . message . "`n"

    rootDir := CONFIG.HasProp("ROOT_DIR") ? CONFIG.ROOT_DIR : A_ScriptDir
    logPath := rootDir . "\" . CONFIG.LOG_FILE

    try {
        FileAppend(logLine, logPath)
    } catch {
        ; Silently fail — never break automation because of logging
    }
}

; ── Convenience wrappers ──────────────────────────────────────────────────

LogDebug(message) {
    LogMessage(message, LOG_LEVEL.DEBUG)
}

LogInfo(message) {
    LogMessage(message, LOG_LEVEL.INFO)
}

LogWarn(message) {
    LogMessage(message, LOG_LEVEL.WARN)
}

LogError(message) {
    LogMessage(message, LOG_LEVEL.ERROR)
}

; ── User-facing dialogs that also log ─────────────────────────────────────

ShowError(message, title := "Error") {
    LogError(message)
    MsgBox(message, title, "Icon!")
}