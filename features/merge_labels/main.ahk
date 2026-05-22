#SingleInstance Force
#Requires AutoHotkey >=v2.0

; ============================================================================
; MERGE LABELS — MAIN ENTRY
; Self-contained feature module for merging the GOLD Prices Table and
; Changed Labels clipboards into a single CSV.
;
; Runs standalone (hub button or run_merge_labels.ahk) and stays alive while
; the status window is shown.  The same logic is re-included by the price
; change feature so F3 still works there during a price change run.
;
; Hotkeys (registered when launched directly):
;   F3  → Two-step capture (prices → labels → CSV)
;   Esc → Reset merge state
; ============================================================================

; ── Shared libraries ──────────────────────────────────────────────────────
#Include ..\..\shared\paths.ahk
#Include ..\..\shared\config.ahk
#Include ..\..\shared\lib\logger.ahk
#Include ..\..\shared\lib\csvUtils.ahk

; ── Feature modules ───────────────────────────────────────────────────────
#Include logic.ahk
#Include status_window.ahk

; ── Hotkey registration ───────────────────────────────────────────────────

RegisterMergeLabelsHotkeys() {
    Hotkey("F3", (*) => HandleMergeLabelHotkey(), "On")
    Hotkey("Esc", (*) => ResetMergeState(), "On")
}

; ── Auto-start when run directly ──────────────────────────────────────────
if (A_LineFile == A_ScriptFullPath) {
    RegisterMergeLabelsHotkeys()
    ShowMergeStatusWindow()
}
