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
        ToolTip("⏸ Paused – press Esc again to resume")
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
 * Check whether the GOLD window matching titlePattern is active.
 * Uses three detection methods for reliability.
 */
IsGoldWindowActive(titlePattern := "G.O.L.D. - LOCAL SALES PRICE SIMPLIFIED INPUT") {
    try {
        ; Method 1: active window title
        activeTitle := WinGetTitle("A")
        if (InStr(activeTitle, titlePattern)) {
            LogDebug("IsGoldWindowActive: matched active title '" . activeTitle . "'")
            return true
        }

        ; Method 2: WinExist
        if (WinExist("ahk_name *" . titlePattern . "*") || WinExist(titlePattern)) {
            LogDebug("IsGoldWindowActive: matched via WinExist")
            return true
        }

        ; Method 3: enumerate all windows
        for hwnd in WinGetList() {
            try {
                title := WinGetTitle(hwnd)
                if (InStr(title, titlePattern)) {
                    LogDebug("IsGoldWindowActive: found via enumeration '" . title . "'")
                    return true
                }
            }
        }

        return false
    } catch as e {
        LogError("Failed to check window: " . e.Message)
        return false
    }
}

/** Wait up to timeout ms for a GOLD window to become active. */
WaitForGoldWindow(titlePattern := "G.O.L.D. - LOCAL SALES PRICE", timeout := 10000) {
    startTime := A_TickCount
    while (A_TickCount - startTime < timeout) {
        if (IsGoldWindowActive(titlePattern))
            return true
        Sleep(200)
    }
    LogDebug("Timeout waiting for GOLD window: " . titlePattern)
    return false
}

; ── Overlay ───────────────────────────────────────────────────────────────
global WarningOverlay := ""

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

/**
 * Wait for a colour to APPEAR at (x, y).
 * Typical use: wait for a button/element to become ready.
 */
WaitForColorToAppear(x, y, targetColor, timeout := 30000, checkInterval := 100) {
    if (SubStr(targetColor, 1, 2) == "0x")
        targetColor := SubStr(targetColor, 3)
    targetColor := StrUpper(targetColor)

    LogDebug("Waiting for color " . targetColor . " to appear at (" . x . "," . y . ")")
    startTime := A_TickCount

    while (A_TickCount - startTime < timeout) {
        try {
            currentColor := PixelGetColor(x, y)
            currentColorHex := StrUpper(SubStr(currentColor, 3))

            if (currentColorHex == targetColor) {
                LogDebug("Color " . targetColor . " appeared — element ready")
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

    LogError("Timeout waiting for color to appear at (" . x . "," . y . ")")
    return false
}

/**
 * Wait for ANY colour change at (x, y).
 * Useful for animated spinners where the exact colour is unknown.
 */
WaitForColorChange(x, y, timeout := 30000, checkInterval := 100) {
    try {
        initialColor := PixelGetColor(x, y)
    } catch as e {
        LogError("Failed to get initial color: " . e.Message)
        return false
    }

    LogDebug("Waiting for color change from " . initialColor . " at (" . x . "," . y . ")")
    startTime := A_TickCount

    while (A_TickCount - startTime < timeout) {
        try {
            currentColor := PixelGetColor(x, y)
            if (currentColor != initialColor) {
                LogDebug("Color changed from " . initialColor . " to " . currentColor)
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

    LogError("Timeout waiting for color change at (" . x . "," . y . ")")
    return false
}
