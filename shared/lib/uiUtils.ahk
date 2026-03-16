#Requires AutoHotkey >=v2.0

; ============================================================================
; UI UTILITIES
; Functions for GOLD UI automation: clicking, typing, clipboard, window
; management, overlay, and pixel-color polling.
; ============================================================================

; ── Global pause flag ─────────────────────────────────────────────────────
global IsPaused := false

; ── Pause control ─────────────────────────────────────────────────────────

/** Toggle pause state. Bind to a hotkey in the entry script. */
TogglePause() {
    global IsPaused
    if (IsPaused) {
        IsPaused := false
        ToolTip("▶ Resumed")
        SetTimer(() => ToolTip(), -1500)
    } else {
        IsPaused := true
        ToolTip("⏸ Paused – press F4 again to resume")
    }
}

/** Block execution while IsPaused is true. Call at every loop checkpoint. */
WaitIfPaused() {
    global IsPaused
    while (IsPaused)
        Sleep(200)
}

; ── Click / Type helpers ──────────────────────────────────────────────────

/**
 * Click at screen coordinates.
 * @returns true on success
 */
ClickAt(x, y) {
    global CONFIG
    try {
        Click(x, y, "Down")
        Sleep 100
        Click(x, y, "Up")
        Sleep(CONFIG.DELAYS.SHORT)
        LogDebug("Clicked at (" . x . "," . y . ")")
        return true
    } catch as e {
        LogError("Failed to click at (" . x . "," . y . "): " . e.Message)
        return false
    }
}

/**
 * Click a field and paste a value via clipboard.
 */
SetFieldValue(x, y, value) {
    global CONFIG
    try {
        Click(x, y)
        Sleep(CONFIG.DELAYS.SHORT)
        Send("^a")
        Sleep(CONFIG.DELAYS.TINY)
        A_Clipboard := value
        Sleep(CONFIG.DELAYS.TINY)
        Send("^v")
        Sleep(CONFIG.DELAYS.MEDIUM)
        LogDebug("Set field value at (" . x . "," . y . "): " . value)
        return true
    } catch as e {
        LogError("Failed to set field value: " . e.Message)
        return false
    }
}

/**
 * Click at coordinates, select all, then optionally type text.
 * Legacy name: clickSomething() — now ClickAndType().
 */
ClickAndType(x, y, value := "") {
    global CONFIG
    Click(x, y)
    Sleep(CONFIG.DELAYS.TINY)
    Send("^a")
    Sleep(300)
    Send("{Delete}")
    Sleep(CONFIG.DELAYS.SHORT)

    if (value != "") {
        SendText(value)
        LogDebug("Clicked and typed at (" . x . "," . y . "): " . value)
    } else {
        LogDebug("Clicked at (" . x . "," . y . ")")
    }
}

; ── GOLD-specific field helpers ───────────────────────────────────────────

/**
 * Set the start-date field in GOLD.
 * @param startDate  "DD/MM/YY" format
 */
SetStartDate(startDate) {
    global CONFIG
    try {
        coords := CONFIG.COORDS.START_DATE
        result := SetFieldValue(coords.x, coords.y, startDate)
        if (result)
            LogInfo("Start date set to: " . startDate)
        return result
    } catch as e {
        LogError("Failed to set start date: " . e.Message)
        ShowError("Failed to set start date: " . e.Message)
        return false
    }
}

/**
 * Set the end-date field (Tab then type). Empty string = skip.
 */
SetEndDate(endDate) {
    global CONFIG

    if (endDate == "") {
        LogDebug("End date is empty, skipping")
        return true
    }

    try {
        Send("{Tab}")
        Sleep(CONFIG.DELAYS.SHORT)
        SendText(endDate)
        Sleep(CONFIG.DELAYS.LONG)
        LogInfo("End date set to: " . endDate)
        return true
    } catch as e {
        LogError("Failed to set end date: " . e.Message)
        return false
    }
}

/**
 * Set the Reason Code field (4 X Tab then type). Empty string = skip.
 */
SetReasonCode(reasonCode) {
    global CONFIG

    if (reasonCode == "") {
        LogDebug("Reason Code is empty, skipping")
        return true
    }

    try {
        Send("{Tab 4}")
        Sleep(CONFIG.DELAYS.SHORT)
        SendText(reasonCode)
        Sleep(CONFIG.DELAYS.LONG)
        LogInfo("Reason Code set to: " . reasonCode)
        return true
    } catch as e {
        LogError("Failed to set Reason Code: " . e.Message)
        return false
    }
}


/**
 * Enter an EAN code and trigger search (Alt+R → type → Alt+T).
 */
EnterArticleCode(eanCode) {
    global CONFIG
    try {
        Send("!r")
        Sleep 100
        coords := CONFIG.COORDS.ARTICLE_CODE
        ClickAndType(coords.x, coords.y, eanCode)
        Sleep(CONFIG.DELAYS.LONG)
        Send("!t")
        Sleep(CONFIG.DELAYS.SEARCH_WAIT)
        LogInfo("Searched for article: " . eanCode)
        return true
    } catch as e {
        LogError("Failed to enter article code: " . e.Message)
        return false
    }
}

/**
 * Type a new price into the price field.
 */
EnterNewPrice(newPrice) {
    global CONFIG
    try {
        coords := CONFIG.COORDS.NEW_PRICE
        Click(coords.x, coords.y)
        Sleep(CONFIG.DELAYS.PAGE_LOAD)
        SendText(newPrice)
        Sleep(CONFIG.DELAYS.SHORT)
        LogInfo("Entered new price: " . newPrice)
        return true
    } catch as e {
        LogError("Failed to enter new price: " . e.Message)
        return false
    }
}

/**
 * Save the current price entry (Tab → Alt+S).
 */
SaveNewPrice() {
    global CONFIG
    try {
        Send("{Tab}")
        Sleep 100
        Send("!s")
        Sleep(CONFIG.DELAYS.PAGE_LOAD)
        LogInfo("Pressed Alt+S to save the new price")
        return true
    } catch as e {
        LogError("Failed to save new price: " . e.Message)
        return false
    }
}

; ── Window management ─────────────────────────────────────────────────────

/** Bring the GOLD Remote Desktop window to front. */
ActivateTargetWindow() {
    global CONFIG
    try {
        WinActivate(CONFIG.WINDOW_TITLE)
        Sleep(CONFIG.DELAYS.SHORT)
        LogInfo("Activated window: " . CONFIG.WINDOW_TITLE)
        return true
    } catch as e {
        LogError("Failed to activate window: " . e.Message)
        return false
    }
}

/**
 * Find the first top-level GOLD window whose title contains titlePattern.
 * Returns its HWND, or 0 if none was found.
 */
FindGoldWindow(titlePattern := "G.O.L.D. - LOCAL SALES PRICE SIMPLIFIED INPUT -") {
    try {
        for hwnd in WinGetList() {
            try {
                title := WinGetTitle(hwnd)
                if (InStr(title, titlePattern))
                    return hwnd
            }
        }
    } catch as e {
        LogError("FindGoldWindow failed: " . e.Message)
    }

    return 0
}

/**
 * Dismiss a GOLD modal dialog if one is already open.
 * Returns 1 if dismissed, 0 if none was present, -1 if dismissal failed.
 */
DismissGoldDialogIfPresent(titlePattern := "G.O.L.D. - LOCAL SALES PRICE SIMPLIFIED INPUT -", okX := 131, okY := 90) {
    dialogHwnd := FindGoldWindow(titlePattern)
    if (!dialogHwnd)
        return 0

    title := ""
    try title := WinGetTitle("ahk_id " . dialogHwnd)

    try WinActivate("ahk_id " . dialogHwnd)
    Sleep(500)

    ; Try the dialog's default button first, then fall back to the known OK coordinate.
    Send("{Enter}")
    Sleep(500)

    if (FindGoldWindow(titlePattern)) {
        Click(okX, okY)
        Sleep(1000)
    }

    if (FindGoldWindow(titlePattern)) {
        LogError("DismissGoldDialogIfPresent: dialog still present '" . title . "'")
        return -1
    }

    LogDebug("DismissGoldDialogIfPresent: dismissed '" . title . "'")
    return 1
}

/**
 * Ensure the GOLD RDP window is in focus before sending clicks/keys.
 * Re-activates it up to maxRetries times if another window stole focus.
 * @returns 0 = already focused, 1 = recovered focus,
 *          2 = GOLD modal dialog active, -1 = failed
 */
EnsureGoldFocus(maxRetries := 3) {
    global CONFIG
    goldDialogTitle := "G.O.L.D. - LOCAL SALES PRICE SIMPLIFIED INPUT -"
    activeTitle := ""
    loop maxRetries {
        try {
            activeTitle := WinGetTitle("A")
            if (InStr(activeTitle, goldDialogTitle)) {
                LogDebug("EnsureGoldFocus: GOLD dialog active '" . activeTitle . "'")
                return 2
            }
            if (InStr(activeTitle, CONFIG.WINDOW_TITLE)) {
                if (A_Index > 1) {
                    LogDebug("EnsureGoldFocus: recovered on attempt #" . A_Index)
                    return 1   ; focus was lost but recovered
                }
                return 0       ; already focused — no intervention
            }
        }

        LogDebug("EnsureGoldFocus: wrong window '" . activeTitle
            . "', re-activating (" . A_Index . "/" . maxRetries . ")")
        try {
            WinActivate(CONFIG.WINDOW_TITLE)
        }
        Sleep(1500)
    }

    LogError("EnsureGoldFocus: FAILED after " . maxRetries . " attempts")
    return -1
}

/**
 * Check whether the active window title contains titlePattern.
 */
IsGoldWindowActive(titlePattern := "G.O.L.D. - LOCAL SALES PRICE SIMPLIFIED INPUT") {
    try {
        activeTitle := WinGetTitle("A")
        if (InStr(activeTitle, titlePattern)) {
            LogDebug("IsGoldWindowActive: matched active title '" . activeTitle . "'")
            return true
        }

        return false
    } catch as e {
        LogError("Failed to check window: " . e.Message)
        return false
    }
}

; ── Overlay ───────────────────────────────────────────────────────────────
global WarningOverlay := ""
global ProgressOverlay := ""
global ProgressOverlayText := ""

/** Show a full-width red "AUTOMATION IN PROGRESS" banner at the top of the screen. */
ShowWorkingOverlay() {
    global WarningOverlay

    WarningOverlay := Gui("+AlwaysOnTop -Caption +ToolWindow")
    WarningOverlay.BackColor := "FF0000"
    WarningOverlay.SetFont("s24 bold", "Arial")
    WarningOverlay.Add("Text", "cWhite Center w" . A_ScreenWidth,
        "⚠️ AUTOMATION IN PROGRESS ⚠️`n`nDO NOT USE MOUSE OR KEYBOARD`n`nPress ESC to abort")

    WarningOverlay.Opt("+E0x20")            ; Click-through
    WinSetTransparent(180, WarningOverlay)

    WarningOverlay.Show("x0 y0 w" . A_ScreenWidth . " h150 NoActivate")
}

/** Remove the warning overlay (safe to call when not showing). */
HideWorkingOverlay() {
    global WarningOverlay
    if (WarningOverlay != "") {
        WarningOverlay.Destroy()
        WarningOverlay := ""
    }
}

/**
 * Show (or update) a click-through progress bar pinned to the bottom of the screen.
 * Safe to call repeatedly — the first call creates the GUI, subsequent calls
 * just update the text without flicker.
 */
ShowProgressOverlay(text) {
    global ProgressOverlay, ProgressOverlayText

    overlayH := 80
    yPos := A_ScreenHeight - overlayH

    if (ProgressOverlay == "") {
        ProgressOverlay := Gui("+AlwaysOnTop -Caption +ToolWindow")
        ProgressOverlay.BackColor := "1a1a2e"
        ProgressOverlay.SetFont("s14 bold", "Arial")
        ProgressOverlayText := ProgressOverlay.Add("Text",
            "cWhite Center w" . A_ScreenWidth . " h" . overlayH, text)

        ProgressOverlay.Opt("+E0x20")           ; Click-through
        WinSetTransparent(200, ProgressOverlay)

        ProgressOverlay.Show("x0 y" . yPos . " w" . A_ScreenWidth
            . " h" . overlayH . " NoActivate")
    } else {
        ProgressOverlayText.Value := text
    }
}

/** Remove the progress overlay (safe to call when not showing). */
HideProgressOverlay() {
    global ProgressOverlay, ProgressOverlayText
    if (ProgressOverlay != "") {
        ProgressOverlay.Destroy()
        ProgressOverlay := ""
        ProgressOverlayText := ""
    }
}

; ============================================================================
; PIXEL-COLOR POLLING
; Wait for loading spinners / UI elements by monitoring a single pixel.
; ============================================================================

/**
 * Wait for a colour to DISAPPEAR at (x, y).
 * Typical use: wait for a loading spinner to finish.
 * 
 * @param targetColor  Hex without "0x" prefix, e.g. "CCCCCC"
 * @param timeout      Milliseconds (default 30 000)
 * @param checkInterval  Polling interval ms (default 100)
 * @returns true if colour disappeared before timeout
 */
WaitForColorToDisappear(x, y, targetColor, timeout := 30000, checkInterval := 100) {
    if (SubStr(targetColor, 1, 2) == "0x")
        targetColor := SubStr(targetColor, 3)
    targetColor := StrUpper(targetColor)

    LogDebug("Waiting for color " . targetColor . " to disappear at (" . x . "," . y . ")")
    startTime := A_TickCount

    while (A_TickCount - startTime < timeout) {
        try {
            currentColor := PixelGetColor(x, y)
            currentColorHex := StrUpper(SubStr(currentColor, 3))

            if (currentColorHex != targetColor) {
                LogDebug("Color changed from " . targetColor . " to " . currentColorHex . " — loading complete")
                SoundBeep(1000, 200)
                SoundBeep(1500, 200)
                Sleep(200)
                return true
            }
        } catch as e {
            LogError("PixelGetColor failed: " . e.Message)
        }
        Sleep(checkInterval)
    }

    LogError("Timeout waiting for color to disappear at (" . x . "," . y . ")")
    return false
}
