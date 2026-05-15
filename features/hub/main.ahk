#SingleInstance Force
#Requires AutoHotkey >=v2.0

; ============================================================================
; HUB — MAIN ENTRY
; A small launcher GUI that spawns / stops the three feature scripts:
;   - Price Change   (run_price_change.ahk)
;   - Unlink Products (run_unlink_products.ahk)
;   - Section Cost   (run_section_cost.ahk)
;
; Each feature is launched in its own AHK process with `--from-hub`, which
; tells the feature to skip its own F1 binding (the hub owns F1) and to
; auto-open / auto-run instead of waiting for a hotkey.
;
; Hotkey:
;   F1 → Toggle hub visibility
; ============================================================================

; ── Shared libraries (resolved relative to this file) ─────────────────────
#Include ..\..\shared\config.ahk
#Include ..\..\shared\lib\logger.ahk
#Include ..\..\shared\lib\stringUtils.ahk

; ── Feature module ────────────────────────────────────────────────────────
#Include gui.ahk

; ── Hotkey registration ───────────────────────────────────────────────────

RegisterHubHotkeys() {
    try {
        Hotkey("F1", (*) => ToggleHubGui(), "On")
    } catch as e {
        ; Another GOLD script is already holding F1.  The hub still works
        ; via the tray menu — just warn the user once.
        LogWarn("Hub: F1 already bound by another process: " . e.Message)
        TrayTip("F1 is bound elsewhere — use the tray icon to open the hub.",
            "GOLD Tools", 0x1)
    }
}

; ── Tray menu (so the hub is still reachable if F1 is blocked) ────────────
A_TrayMenu.Delete()
A_TrayMenu.Add("Show GOLD Tools", (*) => ShowHubGui())
A_TrayMenu.Add()
A_TrayMenu.Add("Stop running feature", (*) => StopRunningHubFeature("tray menu"))
A_TrayMenu.Add()
A_TrayMenu.Add("Exit", (*) => ExitHub())
A_TrayMenu.Default := "Show GOLD Tools"
A_TrayMenu.ClickCount := 1

ExitHub() {
    StopRunningHubFeature("hub exiting")
    ExitApp()
}

; ── Auto-start when run directly ──────────────────────────────────────────
if (A_LineFile == A_ScriptFullPath) {
    RegisterHubHotkeys()
    ShowHubGui()
}
