#SingleInstance Force
#Requires AutoHotkey >=v2.0

; ============================================================================
; PRICE CHANGE — MAIN ENTRY
; Self-contained feature module.  Includes every dependency so this file
; (or the thin root launcher) is the only thing you need to run.
;
; Hotkeys:
;   F1  → Open Price Change GUI
;   F2  → Force-close all Excel instances
;   Esc → Abort running automation
; ============================================================================

; ── Shared libraries (resolved relative to this file) ─────────────────────
#Include ..\..\shared\config.ahk
#Include ..\..\shared\lib\logger.ahk
#Include ..\..\shared\lib\stringUtils.ahk
#Include ..\..\shared\lib\excelUtils.ahk
#Include ..\..\shared\lib\uiUtils.ahk
#Include ..\..\shared\lib\jsonUtils.ahk
#Include ..\..\shared\lib\pdfUtils.ahk

; ── Feature modules ───────────────────────────────────────────────────────
#Include processing.ahk
#Include gui.ahk

; ── State ─────────────────────────────────────────────────────────────────
global IsRunning := false

; ── Hotkey registration ───────────────────────────────────────────────────

RegisterPriceChangeHotkeys() {
    Hotkey("F1", (*) => ShowMainGui(), "On")
    Hotkey("F2", (*) => CloseAllExcelSafely(), "On")
    Hotkey("Esc", (*) => AbortPriceChangeAutomation(), "On")
}

AbortPriceChangeAutomation() {
    global IsRunning
    if (IsRunning) {
        IsRunning := false
        BlockInput(false)
        HideWorkingOverlay()
        UpdateStatus("⚠️ Automation aborted by user!")
        EnableButtons(true)
    }
}

; ── Legacy alias (kept for backward compatibility) ────────────────────────
RunPriceChangeWorkflow() {
    ShowMainGui()
}

; ── Auto-start when run directly ──────────────────────────────────────────
if (A_LineFile == A_ScriptFullPath) {
    RegisterPriceChangeHotkeys()
}
