#Requires AutoHotkey >=v2.0
#SingleInstance Force

; ============================================================================
; BUILD — Compile every runner to a standalone .exe via Ahk2Exe.
; Output: build\<name>.exe + a copy of assets\ and dist\ alongside.
; Run by double-clicking this file.  The compiled folder can be zipped and
; copied to any Windows machine — no AutoHotkey install required there.
;
; Speed notes:
;   • dist\ contains a 200 MB portable Node runtime, so we use robocopy in
;     /MIR mode — only changed files are copied.  First build copies all
;     ~2,900 files (~60 s on a slow disk); subsequent builds are near-instant.
;   • Only the four .exe files are deleted between builds; everything else
;     in build\ is mirrored in place.
; ============================================================================

#Include shared\paths.ahk

global RUNNERS := [{ in: "run_gold_hub.ahk", out: "GOLD_Tools.exe" }, { in: "run_price_change.ahk", out: "run_price_change.exe" }, { in: "run_unlink_products.ahk", out: "run_unlink_products.exe" }, { in: "run_section_cost.ahk", out: "run_section_cost.exe" }, { in: "run_merge_labels.ahk", out: "run_merge_labels.exe" }
]

global ICON_PATH := "assets\labelPriceChange.ico"

; ── Status GUI globals ────────────────────────────────────────────────────
global BuildGui := ""
global BuildStatusText := ""
global BuildLogText := ""

Main() {
    root := GetProjectRoot()
    buildDir := root . "\build"

    ahk2exe := FindAhk2Exe()
    if (ahk2exe == "") {
        MsgBox(
            "Could not find Ahk2Exe.exe.`n`n"
            . "Install AutoHotkey v2 from https://www.autohotkey.com/`n"
            . "(the installer includes the compiler under `"AutoHotkey\Compiler\Ahk2Exe.exe`").",
            "Build failed", "OK Icon!")
        return
    }

    baseExe := FindBaseExe()
    iconPath := root . "\" . ICON_PATH

    ShowBuildGui()

    ; ── Step 1: prepare build dir (don't nuke it — robocopy below mirrors it) ──
    if (!DirExist(buildDir))
        DirCreate(buildDir)

    ; Delete stale .exe files so we always rebuild fresh binaries
    for runner in RUNNERS {
        stale := buildDir . "\" . runner.out
        if (FileExist(stale))
            try FileDelete(stale)
    }

    failures := []

    ; ── Step 2: compile each runner ────────────────────────────────────────
    SetBuildStatus("Compiling runners...")
    for runner in RUNNERS {
        inPath := root . "\" . runner.in
        outPath := buildDir . "\" . runner.out

        AppendBuildLog("→ " . runner.in)

        if (!FileExist(inPath)) {
            failures.Push(runner.in . " — source not found")
            AppendBuildLog("  ✗ source not found")
            continue
        }

        args := '/in "' . inPath . '" /out "' . outPath . '"'
        if (FileExist(iconPath))
            args .= ' /icon "' . iconPath . '"'
        if (baseExe != "")
            args .= ' /base "' . baseExe . '"'

        cmd := '"' . ahk2exe . '" ' . args
        RunWait(cmd, root, "Hide")

        if (!FileExist(outPath)) {
            failures.Push(runner.in . " — Ahk2Exe produced no output")
            AppendBuildLog("  ✗ Ahk2Exe produced no output")
        } else {
            AppendBuildLog("  ✓ " . runner.out)
        }
    }

    ; ── Step 3: mirror assets\ and dist\ with robocopy (incremental) ───────
    for folder in ["assets", "dist"] {
        src := root . "\" . folder
        dst := buildDir . "\" . folder
        if (!DirExist(src))
            continue

        SetBuildStatus("Syncing " . folder . "\ (this is fast after the first build)...")
        AppendBuildLog("→ syncing " . folder . "\")

        result := SyncFolderRobocopy(src, dst)
        if (result.success)
            AppendBuildLog("  ✓ " . result.summary)
        else {
            AppendBuildLog("  ✗ " . result.summary)
            failures.Push(folder . "\ — " . result.summary)
        }
    }

    ; ── Step 3b: assemble the PDF parser into build\dist\pdfParser\ ────────
    ; The runtime expects ONE folder containing the compiled JS, runtime
    ; node_modules, and package.json.  Source tree splits these across
    ; tools\pdfParser\{dist,node_modules,package.json}, so we recombine
    ; them here.  Must run AFTER the dist\ robocopy above, otherwise /MIR
    ; would wipe what we just placed.
    parserSrc := root . "\tools\pdfParser"
    parserDst := buildDir . "\dist\pdfParser"

    if (DirExist(parserSrc . "\dist") && DirExist(parserSrc . "\node_modules")) {
        SetBuildStatus("Assembling PDF parser...")
        AppendBuildLog("→ pdfParser\")

        ; Mirror the compiled JS first.  /MIR cleans up renamed/removed files.
        compiled := SyncFolderRobocopy(parserSrc . "\dist", parserDst)
        if (!compiled.success) {
            AppendBuildLog("  ✗ compiled JS — " . compiled.summary)
            failures.Push("pdfParser dist — " . compiled.summary)
        }

        ; Mirror runtime node_modules (~100 MB, robocopy keeps it incremental).
        modules := SyncFolderRobocopy(parserSrc . "\node_modules", parserDst . "\node_modules")
        if (!modules.success) {
            AppendBuildLog("  ✗ node_modules — " . modules.summary)
            failures.Push("pdfParser node_modules — " . modules.summary)
        }

        ; package.json is referenced by some Node module-resolution paths.
        if (FileExist(parserSrc . "\package.json"))
            try FileCopy(parserSrc . "\package.json", parserDst . "\package.json", 1)

        if (compiled.success && modules.success)
            AppendBuildLog("  ✓ parser ready at " . parserDst)
    } else {
        AppendBuildLog("→ pdfParser\")
        AppendBuildLog("  ✗ source not built — run 'npm install && npm run build' in tools\pdfParser")
        failures.Push("pdfParser — source not built (run npm install && npm run build in tools\pdfParser)")
    }

    ; ── Step 4: create / refresh the desktop shortcut to the hub ───────────
    ; Only meaningful when the hub exe actually built — otherwise the link
    ; would point at a missing target.  Idempotent: overwrites any existing
    ; "GOLD Tools.lnk" on the user's desktop.
    hubExe := buildDir . "\GOLD_Tools.exe"
    if (FileExist(hubExe)) {
        SetBuildStatus("Creating desktop shortcut...")
        AppendBuildLog("→ desktop shortcut")
        shortcutPath := A_Desktop . "\GOLD Tools.lnk"
        try {
            FileCreateShortcut(hubExe, shortcutPath, buildDir,
                , "GOLD Tools — launcher", iconPath)
            AppendBuildLog("  ✓ " . shortcutPath)
        } catch as e {
            AppendBuildLog("  ✗ " . e.Message)
            failures.Push("desktop shortcut — " . e.Message)
        }
    }

    SetBuildStatus(failures.Length > 0 ? "Build finished with errors." : "Build complete.")

    if (failures.Length > 0) {
        msg := "Build completed with errors:`n`n"
        for f in failures
            msg .= "  - " . f . "`n"
        MsgBox(msg, "Build", "OK Icon!")
        return
    }

    result := MsgBox(
        "Build complete.`n`nOutput folder:`n" . buildDir . "`n`n"
        . "Zip the whole `"build`" folder and copy it to any Windows PC.`n"
        . "Launch GOLD_Tools.exe to start.`n`nOpen the folder now?",
        "Build", "YesNo Iconi")

    if (result == "Yes")
        try Run('explorer.exe "' . buildDir . '"')
}

; ── Status GUI ────────────────────────────────────────────────────────────

ShowBuildGui() {
    global BuildGui, BuildStatusText, BuildLogText

    ; No AlwaysOnTop — the final "open folder?" MsgBox needs to appear on top
    ; of this window so the user can see and click it.
    BuildGui := Gui(, "Building GOLD Tools")
    BuildGui.BackColor := "F0F4F8"

    ; Tray + window icon: use the project's label icon so the taskbar and
    ; tray entry are recognisable instead of the default AHK "H".
    iconPath := GetProjectRoot() . "\" . ICON_PATH
    if FileExist(iconPath) {
        TraySetIcon(iconPath)
        hSmall := LoadPicture(iconPath, "w16 h16 Icon1", &t1)
        hBig := LoadPicture(iconPath, "w32 h32 Icon1", &t2)
        SendMessage(0x0080, 0, hSmall, BuildGui)
        SendMessage(0x0080, 1, hBig, BuildGui)
    }

    BuildGui.SetFont("s10", "Segoe UI")
    BuildStatusText := BuildGui.Add("Text", "xm ym w300 h22", "Starting...")
    BuildGui.SetFont("s9", "Consolas")
    BuildLogText := BuildGui.Add("Edit", "xm y+8 w300 h200 ReadOnly -Wrap +HScroll", "")

    BuildGui.SetFont("s10", "Segoe UI")
    closeBtn := BuildGui.Add("Button", "xm y+8 w300 h26", "Close")
    closeBtn.OnEvent("Click", (*) => ExitApp())
    BuildGui.OnEvent("Close", (*) => ExitApp())

    BuildGui.Show("w320")
}

SetBuildStatus(text) {
    global BuildStatusText
    try BuildStatusText.Value := text
}

AppendBuildLog(line) {
    global BuildLogText
    try {
        existing := BuildLogText.Value
        BuildLogText.Value := existing . (existing == "" ? "" : "`r`n") . line
        ; Auto-scroll to bottom
        SendMessage(0x115, 7, 0, BuildLogText)   ; WM_VSCROLL, SB_BOTTOM
    }
}

; ── robocopy wrapper ──────────────────────────────────────────────────────

/**
 * Mirror src → dst with robocopy.  Only changed files are copied.
 * Returns { success: bool, summary: "copied=N skipped=M ..." }.
 * 
 * Robocopy exit codes 0-7 are success (0 = nothing copied, all OK; 1 = some
 * files copied; 2 = extra files in dst; etc.).  Codes 8+ are real failures.
 */
SyncFolderRobocopy(src, dst) {
    if (!DirExist(dst))
        DirCreate(dst)

    tmpLog := A_Temp . "\gold_build_robocopy_" . A_TickCount . ".log"

    ; /MIR    — mirror src to dst (copy + delete extras)
    ; /R:1    — 1 retry on locked file
    ; /W:1    — 1-second wait between retries
    ; /NFL /NDL /NP — suppress per-file noise so the log stays small
    ; /NJH /NJS     — drop header / summary sections, we only want a clean exit code
    cmd := 'robocopy "' . src . '" "' . dst . '" /MIR /R:1 /W:1 /NFL /NDL /NP /NJH /NJS /LOG:"' . tmpLog . '"'
    exitCode := RunWait(A_ComSpec . " /c " . cmd, , "Hide")

    try FileDelete(tmpLog)

    if (exitCode < 8)
        return { success: true, summary: "robocopy exit " . exitCode . " (ok)" }

    return { success: false, summary: "robocopy exit " . exitCode . " (failure)" }
}

; ── Tool location helpers ─────────────────────────────────────────────────

FindAhk2Exe() {
    candidates := [
        "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe",
        "C:\Program Files\AutoHotkey\v2\Compiler\Ahk2Exe.exe",
        A_ProgramFiles . "\AutoHotkey\Compiler\Ahk2Exe.exe",
        A_ProgramFiles . "\AutoHotkey\v2\Compiler\Ahk2Exe.exe"
    ]
    for path in candidates
        if (FileExist(path))
            return path
    return ""
}

FindBaseExe() {
    candidates := [
        "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe",
        "C:\Program Files\AutoHotkey\v2\AutoHotkey32.exe",
        A_ProgramFiles . "\AutoHotkey\v2\AutoHotkey64.exe",
        A_ProgramFiles . "\AutoHotkey\v2\AutoHotkey32.exe"
    ]
    for path in candidates
        if (FileExist(path))
            return path
    return ""
}

Main()