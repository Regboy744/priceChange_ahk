#Requires AutoHotkey >=v2.0

; ============================================================================
; HUB — GUI
; A tiny launcher window with one button per feature.  Each click toggles a
; child process (run_<feature>.ahk) passed `--from-hub` so the feature skips
; its own F1 binding and auto-opens its workflow.  Only ONE feature is
; allowed to run at a time — launching another stops the current one first.
;
; Dependencies (provided by the includer — main.ahk):
;   CONFIG, ProjectPath(),
;   LogInfo, LogDebug, LogWarn, LogError, ShowError
; ============================================================================

; ── State ─────────────────────────────────────────────────────────────────
global HubGui := ""
global HubStatusText := ""
global HubRunningKey := ""    ; key of the feature currently running, "" if none
global HubRunningPid := 0     ; PID of the running feature process

; Feature registry. `runner` is resolved relative to project root at launch.
global HubFeatures := Map(
    "price_change",  { label: "Price Change",   runner: "run_price_change.ahk"   },
    "unlink",        { label: "Unlink Products", runner: "run_unlink_products.ahk" },
    "section_cost",  { label: "Section Cost",   runner: "run_section_cost.ahk"   }
)
; Per-feature controls (populated by ShowHubGui).
global HubButtons := Map()    ; key -> { btn, indicator }

; ============================================================================
; SHOW / TOGGLE
; ============================================================================

/**
 * Toggle hub visibility.  Builds the GUI lazily on first call.
 */
ToggleHubGui() {
    global HubGui
    if (HubGui == "" || !WinExist("ahk_id " . HubGui.Hwnd)) {
        ShowHubGui()
        return
    }
    if (WinActive("ahk_id " . HubGui.Hwnd)) {
        HubGui.Hide()
    } else {
        HubGui.Show()
        WinActivate("ahk_id " . HubGui.Hwnd)
    }
}

ShowHubGui() {
    global HubGui, HubStatusText, HubFeatures, HubButtons

    if (HubGui != "") {
        try {
            HubGui.Show()
            WinActivate("ahk_id " . HubGui.Hwnd)
            return
        }
    }

    HubGui := Gui("+AlwaysOnTop", "GOLD Tools")
    HubGui.SetFont("s10", "Segoe UI")

    ; ── Custom icon ──
    iconPath := ProjectPath("assets\labelPriceChange.ico")
    if FileExist(iconPath) {
        TraySetIcon(iconPath)
        hSmall := LoadPicture(iconPath, "w16 h16 Icon1", &t1)
        hBig   := LoadPicture(iconPath, "w32 h32 Icon1", &t2)
        SendMessage(0x0080, 0, hSmall, HubGui)
        SendMessage(0x0080, 1, hBig,   HubGui)
    }

    ; ── Header ──
    HubGui.Add("Text", "x0 y0 w300 h60 BackgroundF0F4F8")
    HubGui.SetFont("s13 bold", "Segoe UI")
    HubGui.Add("Text", "xm yp+12 cBlack BackgroundTrans", "GOLD Tools")
    HubGui.SetFont("s9 norm", "Segoe UI")
    HubGui.Add("Text", "xm y36 cGray BackgroundTrans",
        "Pick a workflow. Only one runs at a time.")

    ; ── Feature rows ──
    HubGui.SetFont("s10", "Segoe UI")
    y := 75
    for key, feature in HubFeatures {
        indicator := HubGui.Add("Text", "xm y" . y . " w14 h22 cGray", "○")
        HubGui.Add("Text", "x+5 yp w160 h22", feature.label)
        btn := HubGui.Add("Button", "x+5 yp-3 w80 h26", "▶ Start")
        btn.OnEvent("Click", OnHubFeatureClick.Bind(key))
        HubButtons[key] := { btn: btn, indicator: indicator }
        y += 32
    }

    ; ── Status + close ──
    y += 8
    HubStatusText := HubGui.Add("Text", "xm y" . y . " w290 h22 cGray",
        "Idle — F1 toggles this window.")
    y += 30
    closeBtn := HubGui.Add("Button", "xm y" . y . " w290 h26", "Hide (F1)")
    closeBtn.OnEvent("Click", (*) => HubGui.Hide())

    ; X button → fully exit (stops running feature first via ExitHub in main.ahk).
    ; Use the "Hide (F1)" button or press F1 to keep the script running in the tray.
    HubGui.OnEvent("Close", (*) => ExitHub())
    HubGui.Show("w310 h" . (y + 40))

    RefreshHubButtons()
    SetTimer(PollHubProcess, 1000)
}

; ============================================================================
; LAUNCH / STOP
; ============================================================================

OnHubFeatureClick(key, *) {
    global HubRunningKey
    if (HubRunningKey == key) {
        StopRunningHubFeature("user clicked Stop")
        return
    }
    if (HubRunningKey != "") {
        ; Switching features — stop the current one first.
        StopRunningHubFeature("switching to " . key)
    }
    LaunchHubFeature(key)
}

/**
 * Launch a feature with `--from-hub`.
 *
 * Feature runners always sit next to the Hub — A_ScriptDir, NOT the
 * discovered project root.  Anchoring to A_ScriptDir keeps the compiled
 * build (build\GOLD_Tools.exe + build\run_*.exe) and the dev tree
 * (run_gold_hub.ahk + run_*.ahk at the project root) both working with the
 * same lookup logic.
 *
 * Records the PID so we can stop it later and so the poller can detect exit.
 */
LaunchHubFeature(key) {
    global CONFIG, HubFeatures, HubRunningKey, HubRunningPid

    feature := HubFeatures[key]
    ahkPath := A_ScriptDir . "\" . feature.runner
    exePath := A_ScriptDir . "\" . RegExReplace(feature.runner, "i)\.ahk$", ".exe")

    if (FileExist(exePath)) {
        cmd := '"' . exePath . '" --from-hub'
    } else if (!A_IsCompiled && FileExist(ahkPath) && A_AhkPath != "" && FileExist(A_AhkPath)) {
        ; Dev mode only: run the .ahk source through the installed AHK runtime.
        ; Skipped when running a compiled Hub because A_AhkPath then points at
        ; the Hub itself, which would re-launch us recursively.
        cmd := '"' . A_AhkPath . '" "' . ahkPath . '" --from-hub'
    } else {
        LogError("Hub: runner not found — looked for " . exePath . " and " . ahkPath)
        SetHubStatus("❌ Cannot find " . feature.runner)
        return
    }

    LogInfo("Hub: launching " . key . " via " . cmd)

    try {
        Run(cmd, CONFIG.ROOT_DIR, , &pid)
    } catch as e {
        LogError("Hub: failed to launch " . key . ": " . e.Message)
        SetHubStatus("❌ Launch failed: " . e.Message)
        return
    }

    HubRunningKey := key
    HubRunningPid := pid
    SetHubStatus("▶ Running: " . HubFeatures[key].label . "  (PID " . pid . ")")
    RefreshHubButtons()
}

/**
 * Terminate whichever feature is currently running.  Safe to call when
 * nothing is running — it just resets state.
 */
StopRunningHubFeature(reason := "") {
    global HubRunningKey, HubRunningPid, HubFeatures

    if (HubRunningKey == "" || HubRunningPid == 0) {
        ClearHubRunningState()
        return
    }

    label := HubFeatures.Has(HubRunningKey) ? HubFeatures[HubRunningKey].label : HubRunningKey
    LogInfo("Hub: stopping " . HubRunningKey . " (PID " . HubRunningPid . ")"
        . (reason != "" ? " — " . reason : ""))

    if (ProcessExist(HubRunningPid)) {
        try ProcessClose(HubRunningPid)
        ; Best-effort wait so the user sees the indicator flip before the next launch.
        ProcessWaitClose(HubRunningPid, 2)
    }

    SetHubStatus("■ Stopped: " . label)
    ClearHubRunningState()
}

ClearHubRunningState() {
    global HubRunningKey, HubRunningPid
    HubRunningKey := ""
    HubRunningPid := 0
    RefreshHubButtons()
}

; ============================================================================
; POLLING + UI HELPERS
; ============================================================================

/**
 * Detect when a feature process exits on its own (user closed the feature
 * GUI, or the script ExitApp'd) so the hub's indicator stays accurate.
 */
PollHubProcess() {
    global HubRunningKey, HubRunningPid, HubFeatures
    if (HubRunningKey == "" || HubRunningPid == 0)
        return
    if (ProcessExist(HubRunningPid))
        return

    label := HubFeatures.Has(HubRunningKey) ? HubFeatures[HubRunningKey].label : HubRunningKey
    LogInfo("Hub: feature '" . HubRunningKey . "' exited (PID " . HubRunningPid . ")")
    SetHubStatus("● Exited: " . label)
    ClearHubRunningState()
}

RefreshHubButtons() {
    global HubButtons, HubRunningKey
    for key, controls in HubButtons {
        running := (key == HubRunningKey)
        controls.btn.Text := running ? "■ Stop" : "▶ Start"
        controls.indicator.Text := running ? "●" : "○"
        controls.indicator.Opt(running ? "cGreen" : "cGray")
        controls.indicator.Redraw()
    }
}

SetHubStatus(text) {
    global HubStatusText
    try HubStatusText.Text := text
}
