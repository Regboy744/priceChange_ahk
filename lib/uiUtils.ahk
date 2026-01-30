#Requires AutoHotkey >=v2.0

; ============================================================================
; UI UTILITIES
; Functions for UI automation (clicks, clipboard, windows)
; ============================================================================

; Click at specific coordinates
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

; Generic function to set a field value at coordinates
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
        Sleep(CONFIG.DELAYS.SHORT)

        LogDebug("Set field value at (" . x . "," . y . "): " . value)
        return true
    } catch as e {
        LogError("Failed to set field value: " . e.Message)
        return false
    }
}

; Set the start date of new price
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

; Set the end date of new price
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

; Flexible click function that can either just click or click and send text
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

; Activate the target window
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

; Enter article code and search
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

; Enter new price
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

HideWorkingOverlay() {
    global WarningOverlay
    if (WarningOverlay != "") {
        WarningOverlay.Destroy()
        WarningOverlay := ""
    }
}
