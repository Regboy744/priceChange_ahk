#SingleInstance Force
#Requires AutoHotkey >=v2.0

; ============================================================================
; UNLINK PRODUCTS — MAIN ENTRY
; Self-contained feature module. Includes every dependency so this file
; (or the thin root launcher) is the only thing you need to run.
;
; Workflow per EAN (see ../plan.md for the full step list):
;   1+2  Click EAN field → paste code           (SetFieldValue)
;   3    Alt+T to search → wait for spinner     (Send + WaitForGoldSpinnerToFinish)
;   4    Wait for highlight CCCCFF → click row  (WaitForColorToAppear + ClickAt)
;   5    Click Label_scales tab                 (ClickAt)
;   6    Uncheck Scale download / Printable if currently checked
;   7    Click Assortment tab, uncheck Article link if currently checked
;
; Hotkeys:
;   F4  → Toggle Pause / Resume
;   F1  → Open Unlink Products GUI
;   F2  → Force-close all Excel instances
;   Esc → Abort running automation
; ============================================================================

; ── Shared libraries (resolved relative to this file) ─────────────────────
#Include ..\..\shared\config.ahk
#Include ..\..\shared\lib\logger.ahk
#Include ..\..\shared\lib\stringUtils.ahk
#Include ..\..\shared\lib\excelUtils.ahk
#Include ..\..\shared\lib\uiUtils.ahk

; ── Feature modules ───────────────────────────────────────────────────────
#Include processing.ahk
#Include gui.ahk

; ── State ─────────────────────────────────────────────────────────────────
global IsRunning := false

; ── Hotkey registration ───────────────────────────────────────────────────

RegisterUnlinkProductsHotkeys() {
    Hotkey("F4", (*) => TogglePause(), "On")
    Hotkey("F1", (*) => ShowUnlinkGui(), "On")
    Hotkey("F2", (*) => CloseAllExcelSafely(), "On")
    Hotkey("Esc", (*) => AbortUnlinkAutomation(), "On")
}

AbortUnlinkAutomation() {
    global IsRunning
    if (IsRunning) {
        IsRunning := false
        BlockInput(false)
        HideWorkingOverlay()
        UpdateStatus("⚠️ Automation aborted by user!")
        EnableButtons(true)
    }
}

; ── Auto-start when run directly ──────────────────────────────────────────
if (A_LineFile == A_ScriptFullPath) {
    RegisterUnlinkProductsHotkeys()
}
