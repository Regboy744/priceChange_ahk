#SingleInstance Force
#Requires AutoHotkey v2.0

; ============================================================================
; GOLD — Section Cost Export Launcher
; Thin entry point: loads the feature module and registers hotkeys.
; Double-click this file (or compile it) to start the section-cost export.
;
; Command-line args:
;   --from-hub   Launched by the GOLD hub.  Skip the F1 binding (hub owns it)
;                and run the export immediately so the user doesn't press F1.
; ============================================================================

#Include features\section_cost\main.ahk

fromHub := HasFlag(A_Args, "--from-hub")
RegisterSectionCostHotkeys(fromHub)
if (fromHub)
    RunSectionCostExport()

HasFlag(args, flag) {
    for arg in args
        if (arg == flag)
            return true
    return false
}