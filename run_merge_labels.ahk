#SingleInstance Force
#Requires AutoHotkey >=v2.0

; ============================================================================
; GOLD — Merge Labels Launcher
; Thin entry point: loads the feature module, registers F3/Esc, shows the
; status window in the bottom-right corner.  Stays alive until the user
; closes the status window (or the hub stops the process).
;
; Command-line args:
;   --from-hub   Launched by the GOLD hub.  Same flow as direct launch —
;                accepted for consistency with the other runners.
; ============================================================================

#Include features\merge_labels\main.ahk

RegisterMergeLabelsHotkeys()
ShowMergeStatusWindow()