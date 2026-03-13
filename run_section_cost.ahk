#SingleInstance Force
#Requires AutoHotkey v2.0

; ============================================================================
; GOLD — Section Cost Export Launcher
; Thin entry point: loads the feature module and registers hotkeys.
; Double-click this file (or compile it) to start the section-cost export.
; ============================================================================

#Include features\section_cost\main.ahk

RegisterSectionCostHotkeys()
