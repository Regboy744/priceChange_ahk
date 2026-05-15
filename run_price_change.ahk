#SingleInstance Force
#Requires AutoHotkey >=v2.0

; ============================================================================
; GOLD — Price Change Launcher
; Thin entry point: loads the feature module and registers hotkeys.
; Double-click this file (or compile it) to start the price-change tool.
;
; Command-line args:
;   --from-hub   Launched by the GOLD hub.  Skip the F1 binding (hub owns it)
;                and auto-open the GUI so the user doesn't have to press F1.
; ============================================================================

#Include features\price_change\main.ahk

fromHub := HasFlag(A_Args, "--from-hub")
RegisterPriceChangeHotkeys(fromHub)
if (fromHub)
    ShowMainGui()

HasFlag(args, flag) {
    for arg in args
        if (arg == flag)
            return true
    return false
}