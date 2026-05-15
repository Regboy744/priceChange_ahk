#SingleInstance Force
#Requires AutoHotkey >=v2.0

; ============================================================================
; GOLD — Hub Launcher
; Thin entry point: loads the hub module, registers F1, shows the hub GUI.
; Double-click this file to use the hub as your single starting point for
; Price Change, Unlink Products, and Section Cost.
; ============================================================================

#Include features\hub\main.ahk

RegisterHubHotkeys()
ShowHubGui()