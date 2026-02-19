#SingleInstance Force
#Requires AutoHotkey v2.0
#Include supportFunctions.ahk
#Include lib\uiUtils.ahk
#Include lib\csvUtils.ahk
#Include categories_map.ahk

; ── Esc toggles pause (logic lives in lib\uiUtils.ahk) ──
Esc:: TogglePause()

/**
 * Count total family groups across all categories for progress tracking
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

f1:: { ; Start session once
    ; Initialize CSV file at start of session
    InitializeCsvFile()

    ; Count total family groups for progress tracking
    totalFamilyGroups := CountTotalFamilyGroups()
    currentFamilyGroup := 0
    skippedFamilyGroups := []

    MsgBox "Starting export of " . totalFamilyGroups . " family groups across all categories"

    ; Iterate over departments
    for department, subDepts in categories {
        ; Iterate over sub-departments
        for subDepartment, sections in subDepts {
            ; Iterate over sections (C0001 - CHOCOLATE, etc.)
            for section, familyGroups in sections {
                ; Iterate over family groups (F0001, F0002, etc.)
                for familyGroup in familyGroups {
                    currentFamilyGroup++

                    ; ── Pause checkpoint ──
                    WaitIfPaused()

                    ; Show progress in ToolTip
                    ToolTip("Processing [" . currentFamilyGroup . "/" . totalFamilyGroups . "]`n"
                        . familyGroup . "`n"
                        . section . "`n"
                        . subDepartment)

                    try {
                        ; Click on the text box Merchandise structure and fill it up with the family group code
                        clickSomething(712, 135, familyGroup)
                        Sleep(150)
                        WaitIfPaused()

                        ; Run the alt + t to search for the article code
                        Send("!t")

                        ; Poll for error dialog instead of checking once after a fixed delay.
                        ; The error window may appear at unpredictable timings, so we check
                        ; repeatedly over 8 seconds (40 checks × 200ms).
                        ; We also log what the active window title is for diagnostics.
                        errorFound := false
                        loop 40 {
                            Sleep(200)
                            try {
                                activeTitle := WinGetTitle("A")
                                ; Log every 5th check for diagnostics (avoid log spam)
                                if (Mod(A_Index, 5) == 0)
                                    LogDebug("Poll #" . A_Index . " active window: '" . activeTitle . "'")
                            }

                            ; Check if the error/not-found dialog appeared
                            ; The GOLD title with the trailing dash + date means the main window
                            ; stayed active (error popup is a child of it)
                            if (IsGoldWindowActive("G.O.L.D. - LOCAL SALES PRICE SIMPLIFIED INPUT -")) {
                                errorFound := true
                                break
                            }
                        }

                        if (errorFound) {
                            ; Click to close the error window
                            clickSomething(131, 90)
                            Sleep(500)
                            LogDebug("Family group not found - skipping " . familyGroup)
                            skippedFamilyGroups.Push(familyGroup)
                            continue  ; Skip remaining steps, go to next familyGroup in the loop
                        }

                        WaitIfPaused()

                        ; Wait till the spinner disappear (30 minutes timeout)
                        if (!WaitForColorToDisappear(623, 653, "CCCCCC", 1800000, 200)) {
                            LogDebug("Error waiting for spinner - skipping " . familyGroup)
                            skippedFamilyGroups.Push(familyGroup)
                            continue
                        }
                        Sleep 1500

                        WaitIfPaused()

                        ; Click on the green arrow to open options
                        clickSomething(1174, 274)
                        Sleep(1500)

                        ; Click on the copy current data
                        Send("{Down 4}")
                        Sleep(700)

                        ; Press enter to copy the data
                        Send("{Enter}")
                        Sleep(1500)
                        WaitIfPaused()

                        ; Append clipboard data to CSV with department, sub-department, section, and family group
                        itemsAdded := AppendClipboardToCsv(department, subDepartment, section, familyGroup)
                        LogDebug("Family group " . familyGroup . ": " . itemsAdded . " items added to CSV")
                        Sleep(1000)

                    } catch as e {
                        ; Log the error with more details
                        LogError("Critical error processing " . familyGroup . ": " . e.Message)
                        LogDebug("Error Details - File: " . e.File . " | Line: " . e.Line)

                        ; Mark as skipped
                        skippedFamilyGroups.Push(familyGroup)

                        ; Pause briefly and show error notification
                        ToolTip("⚠️ ERROR on " . familyGroup . "`n" . e.Message .
                            "`nContinuing to next family group...", 200,
                            200)
                        Sleep(2000)

                        ; Try to recover by clicking back to the search field for next iteration
                        try {
                            clickSomething(712, 135, "")
                            Sleep(500)
                        }

                        ; Continue with next family group
                        continue
                    }
                }
            }
        }
    }

    ; Hide ToolTip
    ToolTip()

    ; Log completion
    LogDebug("All categories processed - work finished")

    ; Build summary message
    summaryMsg := "✓ Work Finished - Export Complete!`n`n"
    summaryMsg .= "Processed: " . currentFamilyGroup . "/" . totalFamilyGroups . " family groups`n"
    summaryMsg .= "Skipped: " . skippedFamilyGroups.Length . " family groups`n`n"

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
