#Requires AutoHotkey >=v2.0

; ============================================================================
; LOGGER UTILITY
; Centralized logging mechanism for debugging and audit trail
; ============================================================================

; Log levels
global LOG_LEVEL := {
    DEBUG: "DEBUG",
    INFO: "INFO",
    WARN: "WARN",
    ERROR: "ERROR"
}

; Main logging function
LogMessage(message, level := "INFO") {
    global CONFIG

    if (!CONFIG.LOG_ENABLED)
        return

    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    logLine := "[" . timestamp . "] [" . level . "] " . message . "`n"

    ; Append to log file
    logPath := A_ScriptDir . "\" . CONFIG.LOG_FILE
    try {
        FileAppend(logLine, logPath)
    } catch {
        ; Silently fail if logging fails
    }
}

; Convenience functions for different log levels
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

; Show error to user and log it
ShowError(message, title := "Error") {
    LogError(message)
    MsgBox(message, title, "Icon!")
}

; Show warning to user and log it
ShowWarning(message, title := "Warning") {
    LogWarn(message)
    MsgBox(message, title, "Icon!")
}

; Show info to user and log it
ShowInfo(message, title := "Information") {
    LogInfo(message)
    MsgBox(message, title, "Iconi")
}
