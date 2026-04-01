#SingleInstance Force
#Requires AutoHotkey >=v2.0

; ============================================================================
; PRICE CHANGE — MAIN ENTRY
; Self-contained feature module.  Includes every dependency so this file
; (or the thin root launcher) is the only thing you need to run.
;
; Hotkeys:
;   F4  → Toggle Pause / Resume
;   F1  → Open Price Change GUI
;   F2  → Force-close all Excel instances
;   F3  → Merge Labels (2-press: prices table → changed labels → CSV)
;   Esc → Abort running automation
; ============================================================================

; ── Shared libraries (resolved relative to this file) ─────────────────────
#Include ..\..\shared\config.ahk
#Include ..\..\shared\lib\logger.ahk
#Include ..\..\shared\lib\stringUtils.ahk
#Include ..\..\shared\lib\csvUtils.ahk
#Include ..\..\shared\lib\excelUtils.ahk
#Include ..\..\shared\lib\uiUtils.ahk
#Include ..\..\shared\lib\jsonUtils.ahk
#Include ..\..\shared\lib\pdfUtils.ahk

; ── Feature modules ───────────────────────────────────────────────────────
#Include processing.ahk
#Include gui.ahk
#Include merge_labels.ahk

; ── State ─────────────────────────────────────────────────────────────────
global IsRunning := false

; ── Hotkey registration ───────────────────────────────────────────────────

RegisterPriceChangeHotkeys() {
    Hotkey("F4", (*) => TogglePause(), "On")
    Hotkey("F1", (*) => ShowMainGui(), "On")
    Hotkey("F2", (*) => CloseAllExcelSafely(), "On")
    Hotkey("F3", (*) => HandleMergeLabelHotkey(), "On")
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
    ; Always reset the merge-label state machine on Esc
    ResetMergeState()
}

; ── Auto-start when run directly ──────────────────────────────────────────
if (A_LineFile == A_ScriptFullPath) {
    RegisterPriceChangeHotkeys()
}
