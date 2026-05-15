#SingleInstance Force
#Requires AutoHotkey >=v2.0

; ============================================================================
; GOLD — Unlink Products Launcher
; Thin entry point: loads the feature module and registers hotkeys.
; Double-click this file (or compile it) to start the unlink-products tool.
; ============================================================================

#Include features\unlink_products\main.ahk

RegisterUnlinkProductsHotkeys()