#Requires AutoHotkey >=v2.0

; ============================================================================
; UI UTILITIES
; Functions for UI automation (clicks, clipboard, windows)
; ============================================================================

; ── Global pause flag ──
global IsPaused := false

/**
 * Toggle pause state. Bind this to a hotkey in the main script.
 */
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

/**
 * Blocks execution while IsPaused is true.
 * Call this at every checkpoint inside the main loop.
 */
WaitIfPaused() {
    global IsPaused
    while (IsPaused)
        Sleep(200)
}

/**
 * Click at specific screen coordinates
 * @param x - X coordinate (pixels from left of screen)
 * @param y - Y coordinate (pixels from top of screen)
 * @returns true if click succeeded, false if failed
 * @example ClickAt(100, 200)  ; Clicks at position 100,200
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
 * Click on a field and set its value using clipboard paste
 * @param x     - X coordinate of the field
 * @param y     - Y coordinate of the field
 * @param value - Text value to paste into the field
 * @returns true if succeeded, false if failed
 * @example SetFieldValue(300, 150, "12345")  ; Clicks and pastes "12345"
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
 * Set the start date field in GOLD application
 * @param startDate - Date string in format "DD/MM/YY" (e.g., "04/02/26")
 * @returns true if succeeded, false if failed
 * @example SetStartDate("04/02/26")  ; Sets start date to Feb 4, 2026
 */
SetStartDate(startDate) {
    global CONFIG

    try {
        coords := CONFIG.COORDS.START_DATE
        result := SetFieldValue(coords.x, coords.y, startDate)

        if (result) {
            LogInfo("Start date set to: " . startDate)
        }
        return result

    } catch as e {
        LogError("Failed to set start date: " . e.Message)
        ShowError("Failed to set start date: " . e.Message)
        return false
    }
}

/**
 * Set the end date field in GOLD application (presses Tab then types)
 * @param endDate - Date string in format "DD/MM/YY" (e.g., "31/12/26"), or empty to skip
 * @returns true if succeeded (or skipped), false if failed
 * @example SetEndDate("31/12/26")  ; Sets end date to Dec 31, 2026
 * @example SetEndDate("")          ; Skips setting end date
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
 * Click at coordinates and optionally type text (selects all first with Ctrl+A)
 * @param x     - X coordinate to click
 * @param y     - Y coordinate to click
 * @param value - (Optional) Text to type after clicking. Default: "" (just click)
 * @example ClickAndType(100, 200, "Hello")  ; Clicks, selects all, types "Hello"
 * @example ClickAndType(100, 200)           ; Just clicks and selects all
 */
ClickAndType(x, y, value := "") {
    global CONFIG

    ; Click at the specified coordinates
    Click(x, y)
    Sleep(CONFIG.DELAYS.TINY)
    Send("^a")
    Sleep(CONFIG.DELAYS.SHORT)

    ; If a value is provided, send it as text
    if (value != "") {
        SendText(value)
        LogDebug("Clicked and typed at (" . x . "," . y . "): " . value)
    } else {
        LogDebug("Clicked at (" . x . "," . y . ")")
    }
}

/**
 * Activate the GOLD application window (brings it to front)
 * Uses CONFIG.WINDOW_TITLE to find the window
 * @returns true if window activated, false if failed
 * @example ActivateTargetWindow()  ; Activates GOLD PRD window
 */
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
 * Check if the GOLD LOCAL SALES PRICE window is currently active
 * Uses partial title match to handle dynamic date/time in title
 * @param titlePattern - (Optional) Pattern to match. Default: "G.O.L.D. - LOCAL SALES PRICE"
 * @returns true if the window is active, false otherwise
 * @example IsGoldWindowActive()  ; Checks if GOLD window is active
 * @example IsGoldWindowActive("SIMPLIFIED INPUT")  ; Checks for specific window type
 */
IsGoldWindowActive(titlePattern := "G.O.L.D. - LOCAL SALES PRICE SIMPLIFIED INPUT") {
    try {
        ; Method 1: Check active window title
        activeTitle := WinGetTitle("A")
        if (InStr(activeTitle, titlePattern)) {
            LogDebug("IsGoldWindowActive: matched active title '" . activeTitle . "'")
            return true
        }

        ; Method 2: Use WinExist to search ALL windows (not just active)
        ; This catches cases where the error dialog stole focus or the window isn't foreground
        if (WinExist("ahk_name *" . titlePattern . "*") || WinExist(titlePattern)) {
            LogDebug("IsGoldWindowActive: matched via WinExist")
            return true
        }

        ; Method 3: Enumerate windows with partial title match
        ; WinExist may fail with partial matches, so do a manual search
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

/**
 * Wait for GOLD window to be active, with timeout
 * @param titlePattern - (Optional) Pattern to match. Default: "G.O.L.D. - LOCAL SALES PRICE"
 * @param timeout - (Optional) Timeout in milliseconds. Default: 10000 (10 seconds)
 * @returns true if window became active, false if timeout
 * @example WaitForGoldWindow()  ; Waits up to 10s for GOLD window
 */
WaitForGoldWindow(titlePattern := "G.O.L.D. - LOCAL SALES PRICE", timeout := 10000) {
    startTime := A_TickCount
    while (A_TickCount - startTime < timeout) {
        if (IsGoldWindowActive(titlePattern)) {
            return true
        }
        Sleep(200)
    }
    LogDebug("Timeout waiting for GOLD window: " . titlePattern)
    return false
}

/**
 * Enter an EAN/article code and trigger search in GOLD
 * Presses Alt+R, clicks article field, types code, then Alt+T to search
 * @param eanCode - The EAN/barcode to search for (e.g., "5391509393140")
 * @returns true if succeeded, false if failed
 * @example EnterArticleCode("5391509393140")  ; Searches for this EAN
 */
EnterArticleCode(eanCode) {
    global CONFIG

    try {
        Send("!r")
        Sleep 100
        coords := CONFIG.COORDS.ARTICLE_CODE
        ClickAndType(coords.x, coords.y, eanCode)
        Sleep(CONFIG.DELAYS.LONG)

        ; Run the alt + t to search for the article code
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
 * Enter a new price value in the price field
 * @param newPrice - Price as string with decimal (e.g., "2.38" or "10.99")
 * @returns true if succeeded, false if failed
 * @example EnterNewPrice("2.38")  ; Enters price 2.38
 */
EnterNewPrice(newPrice) {
    global CONFIG

    try {
        coords := CONFIG.COORDS.NEW_PRICE

        ; Click on new price text box
        Click(coords.x, coords.y)
        Sleep(CONFIG.DELAYS.PAGE_LOAD)

        ; Write the new price on the text box
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
 * Save the new price by pressing Tab then Alt+S
 * @returns true if succeeded, false if failed
 * @example SaveNewPrice()  ; Saves the current price entry
 */
SaveNewPrice() {
    global CONFIG

    try {
        Send("{Tab}")
        Sleep 100

        ; Send Alt+S to save the new price
        Send("!s")
        Sleep(CONFIG.DELAYS.PAGE_LOAD)

        LogInfo("Pressed Alt+S to save the new price")
        return true
    } catch as e {
        LogError("Failed to save new price: " . e.Message)
        return false
    }
}

; Global variable to track the overlay
global WarningOverlay := ""

/**
 * Show a red warning overlay at top of screen during automation
 * Displays "AUTOMATION IN PROGRESS" message
 * Call HideWorkingOverlay() to remove it
 * @example ShowWorkingOverlay()  ; Shows the warning banner
 */
ShowWorkingOverlay() {
    global WarningOverlay

    ; Create a GUI overlay
    WarningOverlay := Gui("+AlwaysOnTop -Caption +ToolWindow")
    WarningOverlay.BackColor := "FF0000"  ; Red background
    WarningOverlay.SetFont("s24 bold", "Arial")

    ; Make text width match screen width for proper centering
    WarningOverlay.Add("Text", "cWhite Center w" . A_ScreenWidth,
        "⚠️ AUTOMATION IN PROGRESS ⚠️`n`nDO NOT USE MOUSE OR KEYBOARD`n`nPress ESC to abort")

    ; Make it semi-transparent
    WarningOverlay.Opt("+E0x20")  ; Click-through
    WinSetTransparent(180, WarningOverlay)

    ; Position at top of screen
    WarningOverlay.Show("x0 y0 w" . A_ScreenWidth . " h150 NoActivate")
}

/**
 * Hide and destroy the warning overlay
 * Safe to call even if overlay is not showing
 * @example HideWorkingOverlay()  ; Removes the warning banner
 */
HideWorkingOverlay() {
    global WarningOverlay
    if (WarningOverlay != "") {
        WarningOverlay.Destroy()
        WarningOverlay := ""
    }
}

; ============================================================================
; LOADING/SPINNER DETECTION
; Functions to wait for UI elements to appear/disappear by monitoring pixel color
; ============================================================================

/**
 * Wait for a specific color to DISAPPEAR from a coordinate
 * Use this when waiting for loading spinners/overlays to go away
 * 
 * @param x             - X coordinate to monitor (pixels from left of screen)
 * @param y             - Y coordinate to monitor (pixels from top of screen)
 * @param targetColor   - Color to wait for it to disappear (hex string like "EBEBEB" or "0xEBEBEB")
 * @param timeout       - (Optional) Max wait time in milliseconds. Default: 30000 (30 seconds)
 * @param checkInterval - (Optional) How often to check in milliseconds. Default: 100 (0.1 seconds)
 * @returns true if color disappeared, false if timeout reached
 * 
 * @example WaitForColorToDisappear(575, 380, "EBEBEB")              ; Wait up to 30s, check every 100ms
 * @example WaitForColorToDisappear(575, 380, "EBEBEB", 10000)       ; Wait up to 10s
 * @example WaitForColorToDisappear(575, 380, "EBEBEB", 60000, 200)  ; Wait up to 60s, check every 200ms
 */
WaitForColorToDisappear(x, y, targetColor, timeout := 30000, checkInterval := 100) {
    ; Normalize the target color (remove 0x prefix if present)
    if (SubStr(targetColor, 1, 2) == "0x") {
        targetColor := SubStr(targetColor, 3)
    }
    targetColor := StrUpper(targetColor)

    LogDebug("Waiting for color " . targetColor . " to disappear at (" . x . "," . y . ")")
    startTime := A_TickCount

    while (A_TickCount - startTime < timeout) {
        try {
            currentColor := PixelGetColor(x, y)
            currentColorHex := StrUpper(SubStr(currentColor, 3))

            if (currentColorHex != targetColor) {
                LogDebug("Color changed from " . targetColor . " to " . currentColorHex . " - loading complete")
                SoundBeep(1000, 200)
                SoundBeep(1500, 200)
                Sleep(200)  ; Small buffer to ensure UI is stable
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
 * Wait for a specific color to APPEAR at a coordinate
 * Use this when waiting for a UI element/button to become ready
 * 
 * @param x             - X coordinate to monitor (pixels from left of screen)
 * @param y             - Y coordinate to monitor (pixels from top of screen)
 * @param targetColor   - Color to wait for it to appear (hex string like "4CAF50" or "0x4CAF50")
 * @param timeout       - (Optional) Max wait time in milliseconds. Default: 30000 (30 seconds)
 * @param checkInterval - (Optional) How often to check in milliseconds. Default: 100 (0.1 seconds)
 * @returns true if color appeared, false if timeout reached
 * 
 * @example WaitForColorToAppear(100, 200, "4CAF50")         ; Wait for green button
 * @example WaitForColorToAppear(100, 200, "FFFFFF", 5000)   ; Wait up to 5s for white
 */
WaitForColorToAppear(x, y, targetColor, timeout := 30000, checkInterval := 100) {
    ; Normalize the target color (remove 0x prefix if present)
    if (SubStr(targetColor, 1, 2) == "0x") {
        targetColor := SubStr(targetColor, 3)
    }
    targetColor := StrUpper(targetColor)

    LogDebug("Waiting for color " . targetColor . " to appear at (" . x . "," . y . ")")
    startTime := A_TickCount

    while (A_TickCount - startTime < timeout) {
        try {
            currentColor := PixelGetColor(x, y)
            currentColorHex := StrUpper(SubStr(currentColor, 3))

            if (currentColorHex == targetColor) {
                LogDebug("Color " . targetColor . " appeared - element ready")
                SoundBeep(1000, 200)
                SoundBeep(1500, 200)
                Sleep(200)  ; Small buffer to ensure UI is stable
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
 * Wait for ANY color change at a coordinate
 * Use this when you don't know the exact color but want to detect when something changes
 * Good for animated spinners where the color keeps changing
 * 
 * @param x             - X coordinate to monitor (pixels from left of screen)
 * @param y             - Y coordinate to monitor (pixels from top of screen)
 * @param timeout       - (Optional) Max wait time in milliseconds. Default: 30000 (30 seconds)
 * @param checkInterval - (Optional) How often to check in milliseconds. Default: 100 (0.1 seconds)
 * @returns true if color changed, false if timeout reached
 * 
 * @example WaitForColorChange(575, 380)          ; Wait for any change at spinner location
 * @example WaitForColorChange(575, 380, 15000)   ; Wait up to 15 seconds
 */
WaitForColorChange(x, y, timeout := 30000, checkInterval := 100) {
    ; Get the initial color
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
                Sleep(200)  ; Small buffer to ensure UI is stable
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
