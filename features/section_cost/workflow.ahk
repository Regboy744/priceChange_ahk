#Requires AutoHotkey >=v2.0

; ============================================================================
; SECTION COST — EXPORT WORKFLOW
; Iterates every family group in categories_map, copies price data from GOLD
; via clipboard, and appends each batch to a CSV file.
;
; Dependencies (provided by the includer — main.ahk):
;   categories (Map), CONFIG,
;   ClickAndType, LogDebug, LogError, IsGoldWindowActive,
;   WaitForColorToDisappear, AppendClipboardToCsv, WaitIfPaused,
;   InitializeCsvFile, GetCsvFilePath
; ============================================================================

/**
 * Count total family groups across all categories for progress tracking.
 */
CountTotalFamilyGroups() {
    total := 0
    for department, subDepts in categories {
        for subDepartment, sections in subDepts {
            for section, familyGroups in sections {
                total += familyGroups.Length
            }
        }
    }
    return total
}

/**
 * Main export loop — runs through every family group, copies data from
 * GOLD, and writes to CSV.
 */
RunSectionCostExport() {
    ; Initialize the CSV file at the start of the session
    InitializeCsvFile()

    totalFamilyGroups   := CountTotalFamilyGroups()
    currentFamilyGroup  := 0
    skippedFamilyGroups := []

    MsgBox "Starting export of " . totalFamilyGroups . " family groups across all categories"

    ; ── Iterate departments → sub-departments → sections → family groups ──
    for department, subDepts in categories {
        for subDepartment, sections in subDepts {
            for section, familyGroups in sections {
                for familyGroup in familyGroups {
                    currentFamilyGroup++

                    WaitIfPaused()

                    ; Progress tooltip
                    ToolTip("Processing [" . currentFamilyGroup . "/" . totalFamilyGroups . "]`n"
                        . familyGroup . "`n"
                        . section . "`n"
                        . subDepartment)

                    try {
                        ; Fill the "Merchandise structure" search box
                        ClickAndType(712, 135, familyGroup)
                        Sleep(150)
                        WaitIfPaused()

                        ; Trigger search (Alt+T)
                        Send("!t")

                        ; ── Poll for the "not found" error dialog ─────────
                        ; The error window appears at unpredictable timings,
                        ; so we check repeatedly over 8 s (40 × 200 ms).
                        errorFound := false
                        loop 40 {
                            Sleep(200)
                            try {
                                activeTitle := WinGetTitle("A")
                                if (Mod(A_Index, 5) == 0)
                                    LogDebug("Poll #" . A_Index . " active window: '" . activeTitle . "'")
                            }

                            if (IsGoldWindowActive("G.O.L.D. - LOCAL SALES PRICE SIMPLIFIED INPUT -")) {
                                errorFound := true
                                break
                            }
                        }

                        if (errorFound) {
                            ClickAndType(131, 90)
                            Sleep(500)
                            LogDebug("Family group not found — skipping " . familyGroup)
                            skippedFamilyGroups.Push(familyGroup)
                            continue
                        }

                        WaitIfPaused()

                        ; Wait for the spinner to disappear (30 min timeout)
                        if (!WaitForColorToDisappear(623, 653, "CCCCCC", 1800000, 200)) {
                            LogDebug("Error waiting for spinner — skipping " . familyGroup)
                            skippedFamilyGroups.Push(familyGroup)
                            continue
                        }
                        Sleep 1500

                        WaitIfPaused()

                        ; Open the green-arrow context menu → Copy current data
                        ClickAndType(1174, 274)
                        Sleep(1500)
                        Send("{Down 4}")
                        Sleep(700)
                        Send("{Enter}")
                        Sleep(1500)

                        WaitIfPaused()

                        ; Append clipboard to CSV
                        itemsAdded := AppendClipboardToCsv(department, subDepartment, section, familyGroup)
                        LogDebug("Family group " . familyGroup . ": " . itemsAdded . " items added to CSV")
                        Sleep(1000)

                    } catch as e {
                        LogError("Critical error processing " . familyGroup . ": " . e.Message)
                        LogDebug("Error Details — File: " . e.File . " | Line: " . e.Line)

                        skippedFamilyGroups.Push(familyGroup)

                        ToolTip("⚠️ ERROR on " . familyGroup . "`n" . e.Message
                            . "`nContinuing to next family group...", 200, 200)
                        Sleep(2000)

                        ; Try to recover for the next iteration
                        try {
                            ClickAndType(712, 135, "")
                            Sleep(500)
                        }
                        continue
                    }
                }
            }
        }
    }

    ToolTip()

    LogDebug("All categories processed — work finished")

    ; ── Summary ──
    summaryMsg := "✓ Work Finished — Export Complete!`n`n"
    summaryMsg .= "Processed: " . currentFamilyGroup . "/" . totalFamilyGroups . " family groups`n"
    summaryMsg .= "Skipped: "   . skippedFamilyGroups.Length . " family groups`n`n"

    if (skippedFamilyGroups.Length > 0) {
        summaryMsg .= "Failed family groups: "
        for idx, code in skippedFamilyGroups {
            summaryMsg .= code
            if (idx < skippedFamilyGroups.Length)
                summaryMsg .= ", "
        }
        summaryMsg .= "`n`n"
    }

    summaryMsg .= "CSV saved to:`n" . GetCsvFilePath()

    MsgBox summaryMsg
}
