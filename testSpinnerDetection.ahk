#SingleInstance Force
#Requires AutoHotkey >=v2.0

; ============================================================================
; SPINNER DETECTION TEST TOOL
; Run this separately to find the right pixel/coordinates for spinner detection
; ============================================================================

global TestGui := ""
global StatusText := ""
global ColorText := ""
global CoordsText := ""
global IsMonitoring := false

; Configurable values - ADJUST THESE after finding the right spot
global SpinnerX := 575      ; X coordinate to monitor
global SpinnerY := 380      ; Y coordinate to monitor
global SpinnerColor := "EBEBEB"  ; Color when spinner is visible

; ============================================================================
; HOTKEYS
; ============================================================================

F1:: ShowTestGui()
F2:: StartMonitoring()
F3:: StopMonitoring()
F4:: CaptureCoordinates()
Esc:: ExitApp()

; ============================================================================
; GUI
; ============================================================================

ShowTestGui() {
    global TestGui, StatusText, ColorText, CoordsText, SpinnerX, SpinnerY, SpinnerColor

    if (TestGui != "") {
        try TestGui.Destroy()
    }

    TestGui := Gui("+AlwaysOnTop", "Spinner Detection Test")
    TestGui.SetFont("s10", "Segoe UI")

    TestGui.Add("Text", "w350", "This tool helps you detect when the loading spinner disappears.")
    TestGui.Add("Text", "w350 cGray", "Hover over the spinner area in GOLD and press F4 to capture.")

    TestGui.Add("Text", "y+15", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    ; Current mouse position display
    TestGui.Add("Text", "y+10", "Current Mouse Position:")
    CoordsText := TestGui.Add("Text", "w350 cBlue", "X: 0, Y: 0")

    TestGui.Add("Text", "y+10", "Pixel Color at Mouse:")
    ColorText := TestGui.Add("Text", "w350 cBlue", "Color: ------")

    TestGui.Add("Text", "y+15", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    ; Saved coordinates
    TestGui.Add("Text", "y+10", "Saved Monitoring Coordinates:")
    TestGui.Add("Text", "w350 cGreen", "X: " . SpinnerX . ", Y: " . SpinnerY . " | Target Color: " . SpinnerColor)

    TestGui.Add("Text", "y+15", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    ; Status
    TestGui.Add("Text", "y+10", "Detection Status:")
    StatusText := TestGui.Add("Text", "w350 h40 cGray", "Press F2 to start monitoring...")

    ; Buttons
    TestGui.Add("Button", "y+15 w100", "F4: Capture").OnEvent("Click", (*) => CaptureCoordinates())
    TestGui.Add("Button", "x+10 w100", "F2: Monitor").OnEvent("Click", (*) => StartMonitoring())
    TestGui.Add("Button", "x+10 w100", "F3: Stop").OnEvent("Click", (*) => StopMonitoring())

    TestGui.Add("Text", "xm y+20 w350 cGray", "Hotkeys: F1=Show | F2=Start | F3=Stop | F4=Capture | ESC=Exit")

    TestGui.OnEvent("Close", (*) => TestGui.Destroy())
    TestGui.Show()

    ; Start timer to update mouse position
    SetTimer(UpdateMousePosition, 100)
}

; ============================================================================
; FUNCTIONS
; ============================================================================

UpdateMousePosition() {
    global CoordsText, ColorText

    if (CoordsText == "") {
        return
    }

    ; Get mouse position
    MouseGetPos(&mouseX, &mouseY)
    CoordsText.Value := "X: " . mouseX . ", Y: " . mouseY

    ; Get pixel color at mouse position
    try {
        pixelColor := PixelGetColor(mouseX, mouseY)
        ColorText.Value := "Color: " . pixelColor . " (Hex: " . SubStr(pixelColor, 3) . ")"
    } catch {
        ColorText.Value := "Color: Unable to read"
    }
}

CaptureCoordinates() {
    global SpinnerX, SpinnerY, SpinnerColor, StatusText

    ; Get current mouse position
    MouseGetPos(&mouseX, &mouseY)

    ; Get pixel color
    try {
        pixelColor := PixelGetColor(mouseX, mouseY)
        colorHex := SubStr(pixelColor, 3)

        SpinnerX := mouseX
        SpinnerY := mouseY
        SpinnerColor := colorHex

        StatusText.Value := "✅ CAPTURED!`nX: " . SpinnerX . ", Y: " . SpinnerY . "`nColor: " . SpinnerColor

        ; Show in message box for easy copying
        MsgBox("Coordinates captured!`n`n" .
            "SpinnerX := " . SpinnerX . "`n" .
            "SpinnerY := " . SpinnerY . "`n" .
            "SpinnerColor := `"" . SpinnerColor . "`"`n`n" .
            "Copy these values to your config!",
            "Captured!", "Icon!")

    } catch as e {
        StatusText.Value := "❌ Failed to capture: " . e.Message
    }
}

StartMonitoring() {
    global IsMonitoring, StatusText, SpinnerX, SpinnerY, SpinnerColor

    if (IsMonitoring) {
        return
    }

    IsMonitoring := true
    StatusText.Value := "🔍 MONITORING...`nWaiting for spinner to disappear at X:" . SpinnerX . " Y:" . SpinnerY

    ; Start monitoring timer
    SetTimer(CheckForSpinner, 100)
}

StopMonitoring() {
    global IsMonitoring, StatusText

    IsMonitoring := false
    SetTimer(CheckForSpinner, 0)
    StatusText.Value := "⏹️ Monitoring stopped."
}

CheckForSpinner() {
    global IsMonitoring, StatusText, SpinnerX, SpinnerY, SpinnerColor

    if (!IsMonitoring) {
        return
    }

    try {
        ; Get current pixel color at the monitored position
        currentColor := PixelGetColor(SpinnerX, SpinnerY)
        currentColorHex := SubStr(currentColor, 3)

        ; Check if color matches the spinner color
        if (currentColorHex == SpinnerColor) {
            ; Spinner still visible
            StatusText.Value := "🔄 SPINNER DETECTED`nColor: " . currentColorHex . " (matches target)`nWaiting..."
        } else {
            ; Spinner gone!
            SetTimer(CheckForSpinner, 0)
            IsMonitoring := false

            StatusText.Value := "✅ SPINNER DISAPPEARED!`nNew color: " . currentColorHex . "`n(was: " . SpinnerColor .
                ")"

            ; Play a sound to notify
            SoundBeep(1000, 200)
            SoundBeep(1500, 200)
        }
    } catch as e {
        StatusText.Value := "❌ Error reading pixel: " . e.Message
    }
}

; ============================================================================
; AUTO-START
; ============================================================================

ShowTestGui()