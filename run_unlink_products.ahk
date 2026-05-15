#SingleInstance Force
#Requires AutoHotkey >=v2.0

; ============================================================================
; GOLD — Unlink Products Launcher
; Thin entry point: loads the feature module and registers hotkeys.
; Double-click this file (or compile it) to start the unlink-products tool.
;
; Command-line args:
;   --from-hub   Launched by the GOLD hub.  Skip the F1 binding (hub owns it)
;                and auto-open the GUI so the user doesn't have to press F1.
; ============================================================================

#Include features\unlink_products\main.ahk

fromHub := HasFlag(A_Args, "--from-hub")
RegisterUnlinkProductsHotkeys(fromHub)
if (fromHub)
    ShowUnlinkGui()

HasFlag(args, flag) {
    for arg in args
        if (arg == flag)
            return true
    return false
}