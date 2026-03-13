#SingleInstance Force
#Requires AutoHotkey v2.0

; ============================================================================
; SECTION COST — MAIN ENTRY
; Self-contained feature module.  Includes every dependency so this file
; (or the thin root launcher) is the only thing you need to run.
;
; Hotkeys:
;   F4  → Toggle Pause / Resume
;   F1  → Start the Section Cost Export
; ============================================================================

; ── Shared libraries ──────────────────────────────────────────────────────
#Include ..\..\shared\config.ahk
#Include ..\..\shared\lib\logger.ahk
#Include ..\..\shared\lib\stringUtils.ahk
#Include ..\..\shared\lib\uiUtils.ahk
#Include ..\..\shared\lib\csvUtils.ahk

; ── Feature data & workflow ───────────────────────────────────────────────
#Include categories_map.ahk
#Include workflow.ahk

; ── Hotkey registration ───────────────────────────────────────────────────

RegisterSectionCostHotkeys() {
    Hotkey("F4", (*) => TogglePause(), "On")
    Hotkey("F1", (*) => RunSectionCostExport(), "On")
}

; ── Auto-start when run directly ──────────────────────────────────────────
if (A_LineFile == A_ScriptFullPath) {
    RegisterSectionCostHotkeys()
}