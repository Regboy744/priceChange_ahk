#SingleInstance Force
#Requires AutoHotkey >=v2.0

; ============================================================================
; GOLD — Price Change Launcher
; Thin entry point: loads the feature module and registers hotkeys.
; Double-click this file (or compile it) to start the price-change tool.
; ============================================================================

#Include features\price_change\main.ahk

RegisterPriceChangeHotkeys()