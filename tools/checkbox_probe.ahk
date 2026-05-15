#Requires AutoHotkey >=v2.0
#SingleInstance Force
; Scratch probe: validate IsCheckboxChecked against GOLD's Label_scales tab.
; Run alongside GOLD, open a product so Scale download / Printable are visible,
; then press Ctrl+F12 to read both checkboxes. Toggle and re-test.

CoordMode "Pixel", "Client"
CoordMode "Mouse", "Client"

; --- candidate coords (from Window Spy) ---
SCALE_X := 233, SCALE_Y := 357
PRINT_X := 233, PRINT_Y := 399

^F12:: {
    global SCALE_X, SCALE_Y, PRINT_X, PRINT_Y
    scale := IsCheckboxChecked(SCALE_X, SCALE_Y)
    print := IsCheckboxChecked(PRINT_X, PRINT_Y)
    MsgBox Format(
        "Scale download ({},{}): {}`nPrintable      ({},{}): {}",
        SCALE_X, SCALE_Y, scale ? "CHECKED" : "empty",
        PRINT_X, PRINT_Y, print ? "CHECKED" : "empty"
    ), "Checkbox probe"
}

; Ctrl+F11: dump raw colors of the 11x11 scan area for whichever checkbox
; the mouse is closest to — useful if a result looks wrong.
^F11:: {
    global SCALE_X, SCALE_Y, PRINT_X, PRINT_Y
    MouseGetPos &mx, &my
    if Abs(my - SCALE_Y) < Abs(my - PRINT_Y)
        cx := SCALE_X, cy := SCALE_Y, name := "Scale download"
    else
        cx := PRINT_X, cy := PRINT_Y, name := "Printable"
    DumpRegion(name, cx, cy, 5)
}

; Esc closes the probe so it doesn't linger.
Esc:: ExitApp

IsCheckboxChecked(cx, cy, radius := 5, darkThreshold := 80) {
    loop radius * 2 + 1 {
        py := cy - radius + A_Index - 1
        loop radius * 2 + 1 {
            px := cx - radius + A_Index - 1
            c := PixelGetColor(px, py)
            if ((c >> 16) & 0xFF) < darkThreshold
                && ((c >> 8) & 0xFF) < darkThreshold
                && (c & 0xFF) < darkThreshold
                return true
        }
    }
    return false
}

DumpRegion(name, cx, cy, radius) {
    out := name . " @ (" . cx . "," . cy . ")  radius=" . radius . "`n`n"
    minBright := 999
    loop radius * 2 + 1 {
        py := cy - radius + A_Index - 1
        row := ""
        loop radius * 2 + 1 {
            px := cx - radius + A_Index - 1
            c := PixelGetColor(px, py)
            r := (c >> 16) & 0xFF, g := (c >> 8) & 0xFF, b := c & 0xFF
            bright := (r + g + b) // 3
            if bright < minBright
                minBright := bright
            row .= (bright < 80 ? "#" : bright < 180 ? "." : " ")
        }
        out .= row . "`n"
    }
    out .= "`nmin brightness in region: " . minBright
        . "  →  " . (minBright < 80 ? "CHECKED" : "empty")
    MsgBox out, "Region dump"
}