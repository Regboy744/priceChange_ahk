#Requires AutoHotkey >=v2.0

; ============================================================================
; MERGE LABELS — STATUS WINDOW
; Small always-on-top window pinned to the bottom-right corner.  Shows the
; current step of the two-press merge workflow so the user knows whether F3
; will capture prices or finalise the merge.  Polls MergeStep / PricesLookup
; from logic.ahk every 250 ms.
;
; Dependencies (from main.ahk):
;   MergeStep, PricesLookup (globals from logic.ahk)
;   ProjectPath
; ============================================================================

global MergeStatusGui := ""
global MergeStatusStepText := ""
global MergeStatusHintText := ""

ShowMergeStatusWindow() {
    global MergeStatusGui, MergeStatusStepText, MergeStatusHintText

    if (MergeStatusGui != "")
        try MergeStatusGui.Destroy()

    MergeStatusGui := Gui("+AlwaysOnTop +ToolWindow", "Merge Labels")
    MergeStatusGui.BackColor := "F0F4F8"

    ; Tray + window icon
    iconPath := ProjectPath("assets\labelPriceChange.ico")
    if FileExist(iconPath) {
        TraySetIcon(iconPath)
        hSmall := LoadPicture(iconPath, "w16 h16 Icon1", &t1)
        hBig   := LoadPicture(iconPath, "w32 h32 Icon1", &t2)
        SendMessage(0x0080, 0, hSmall, MergeStatusGui)
        SendMessage(0x0080, 1, hBig,   MergeStatusGui)
    }

    MergeStatusGui.SetFont("s10 bold", "Segoe UI")
    MergeStatusGui.Add("Text", "xm ym w260 cBlack", "Merge Labels — active")

    MergeStatusGui.SetFont("s9 norm", "Segoe UI")
    MergeStatusStepText := MergeStatusGui.Add("Text", "xm y+6 w260 cBlack",
        "Step 1 — copy the Prices Table, then press F3")

    MergeStatusGui.SetFont("s8 norm", "Segoe UI")
    MergeStatusHintText := MergeStatusGui.Add("Text", "xm y+6 w260 cGray",
        "After step 2 you'll be asked where to save the CSV.`nEsc resets · close this window to exit.")

    MergeStatusGui.OnEvent("Close", (*) => ExitApp())

    ; Bottom-right with a small margin from screen edges.
    guiW := 290
    guiH := 140
    xPos := A_ScreenWidth - guiW - 20
    yPos := A_ScreenHeight - guiH - 60

    ; NoActivate so the window doesn't steal focus from whatever app the user
    ; is copying data out of (Excel, GOLD, etc).
    MergeStatusGui.Show("x" . xPos . " y" . yPos . " w" . guiW . " h" . guiH . " NoActivate")

    SetTimer(RefreshMergeStatusWindow, 250)
    RefreshMergeStatusWindow()
}

RefreshMergeStatusWindow() {
    global MergeStep, PricesLookup, MergeStatusStepText
    if (MergeStatusStepText == "")
        return

    try {
        if (MergeStep == 0) {
            MergeStatusStepText.Text := "Step 1 — copy the Prices Table, then press F3"
        } else {
            MergeStatusStepText.Text := "Prices loaded (" . PricesLookup.Count
                . " items)`nStep 2 — in Labels, copy the desired lot,`nthen press F3"
        }
    }
}
