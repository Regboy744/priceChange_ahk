#Requires AutoHotkey >=v2.0

; ============================================================================
; SECTION COST — EXPORT WORKFLOW
; Iterates every family group in categories_map, copies price data from GOLD
; via clipboard, and appends each batch to a CSV file.
;
; Dependencies (provided by the includer — main.ahk):
;   categories (Map), CONFIG,
;   ClickAndType, LogDebug, LogError, IsGoldWindowActive,
;   DismissGoldDialogIfPresent, EnsureGoldFocus, WaitForColorToDisappear,
;   AppendClipboardToCsv, WaitIfPaused, InitializeCsvFile, GetCsvFilePath
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

PushSkippedFamilyGroup(skippedFamilyGroups, familyGroup) {
    for _, code in skippedFamilyGroups {
        if (code == familyGroup)
            return false
    }

    skippedFamilyGroups.Push(familyGroup)
    return true
}

HandleMissingFamilyGroup(familyGroup, skippedFamilyGroups) {
    dismissResult := DismissGoldDialogIfPresent()
    if (dismissResult == -1)
        LogError("Failed to dismiss GOLD not-found dialog for " . familyGroup)

    LogDebug("Family group not found — skipping " . familyGroup)
    PushSkippedFamilyGroup(skippedFamilyGroups, familyGroup)
}

/**
 * Main export loop — runs through every family group, copies data from
 * GOLD, and writes to CSV.
 */
RunSectionCostExport() {
    ; Initialize the CSV file at the start of the session
    InitializeCsvFile()

    totalFamilyGroups := CountTotalFamilyGroups()
    currentFamilyGroup := 0
    skippedFamilyGroups := []

    MsgBox "Starting export of " . totalFamilyGroups . " family groups across all categories"

    ; ── Iterate departments → sub-departments → sections → family groups ──
    for department, subDepts in categories {
        for subDepartment, sections in subDepts {
            for section, familyGroups in sections {
                for familyGroup in familyGroups {
                    currentFamilyGroup++

                    WaitIfPaused()

                    ; Progress overlay (pinned to bottom of screen)
                    ShowProgressOverlay("Processing [" . currentFamilyGroup . "/" . totalFamilyGroups . "]  —  "
                        . familyGroup . "  |  " . section . "  |  " . subDepartment)

                    ; ── Focus-recovery retry loop ─────────────────────
                    ; If GOLD lost focus mid-operation, wait 3 s and
                    ; restart this family group from scratch.
                    familyCompleted := false
                    familySkipped := false
                    maxFocusRetries := 3

                    loop maxFocusRetries {
                        familyAttempt := A_Index

                        try {
                            staleDialogResult := DismissGoldDialogIfPresent()
                            if (staleDialogResult == -1) {
                                familySkipped := true
                                LogError("A stale GOLD dialog blocked " . familyGroup . " — skipping")
                                PushSkippedFamilyGroup(skippedFamilyGroups, familyGroup)
                                break
                            }
                            if (staleDialogResult == 1) {
                                LogDebug("Cleared stale GOLD dialog before processing " . familyGroup)
                                Sleep(1000)
                            }

                            ; Ensure GOLD is in focus before interacting
                            focusResult := EnsureGoldFocus()
                            if (focusResult == 2) {
                                familySkipped := true
                                HandleMissingFamilyGroup(familyGroup, skippedFamilyGroups)
                                break
                            }
                            if (focusResult == -1) {
                                LogError("GOLD window lost — skipping " . familyGroup)
                                familySkipped := true
                                PushSkippedFamilyGroup(skippedFamilyGroups, familyGroup)
                                break
                            }
                            if (focusResult == 1) {
                                LogDebug("Focus recovered — waiting 3 s then restarting "
                                    . familyGroup . " (attempt " . familyAttempt . "/" . maxFocusRetries . ")")
                                Sleep(3000)
                                continue   ; restart this family from scratch
                            }

                            ; Fill the "Merchandise structure" search box
                            ClickAndType(712, 135, familyGroup)
                            Sleep(2000)
                            WaitIfPaused()

                            ; Trigger search (Alt+T)
                            Send("!t")

                            ; ── Early poll for the "not found" error dialog ───
                            ; Some dialogs appear quickly; delayed ones are
                            ; checked again before copy and on the next family.
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
                                familySkipped := true
                                HandleMissingFamilyGroup(familyGroup, skippedFamilyGroups)
                                break   ; skip — no retry needed
                            }

                            WaitIfPaused()

                            ; Wait for the spinner to disappear (30 min timeout)
                            if (!WaitForColorToDisappear(623, 653, "CCCCCC", 1800000, 200)) {
                                LogDebug("Error waiting for spinner — skipping " . familyGroup)
                                familySkipped := true
                                PushSkippedFamilyGroup(skippedFamilyGroups, familyGroup)
                                break   ; skip — no retry needed
                            }
                            Sleep 1500

                            WaitIfPaused()

                            ; Re-verify focus before copy step
                            focusResult := EnsureGoldFocus()
                            if (focusResult == 2) {
                                familySkipped := true
                                HandleMissingFamilyGroup(familyGroup, skippedFamilyGroups)
                                break
                            }
                            if (focusResult == -1) {
                                LogError("GOLD window lost before copy — skipping " . familyGroup)
                                familySkipped := true
                                PushSkippedFamilyGroup(skippedFamilyGroups, familyGroup)
                                break
                            }
                            if (focusResult == 1) {
                                LogDebug("Focus recovered before copy — waiting 3 s then restarting "
                                    . familyGroup . " (attempt " . familyAttempt . "/" . maxFocusRetries . ")")
                                Sleep(3000)
                                continue   ; restart this family from scratch
                            }

                            ; ── Copy data from GOLD with retry ────────────────
                            A_Clipboard := ""   ; clear so we can detect a real copy
                            copySuccess := false
                            focusRecovered := false
                            delayedNotFoundDuringCopy := false
                            goldLostDuringCopy := false
                            maxCopyRetries := 3

                            loop maxCopyRetries {
                                if (A_Index > 1) {
                                    LogDebug("Clipboard retry #" . (A_Index - 1) . " for " . familyGroup)
                                    Send("{Escape}")   ; dismiss any stale menu
                                    Sleep(1000)
                                    focusResult := EnsureGoldFocus()
                                    if (focusResult == 2) {
                                        delayedNotFoundDuringCopy := true
                                        break
                                    }
                                    if (focusResult == 1) {
                                        LogDebug("Focus recovered during copy retry — restarting " . familyGroup)
                                        focusRecovered := true
                                        break   ; break copy loop → outer loop will restart family
                                    }
                                    if (focusResult == -1) {
                                        LogError("GOLD lost during copy retry — skipping " . familyGroup)
                                        familySkipped := true
                                        PushSkippedFamilyGroup(skippedFamilyGroups, familyGroup)
                                        goldLostDuringCopy := true
                                        break
                                    }
                                    A_Clipboard := ""
                                }

                                ; Click the green-arrow context menu (plain click — no Ctrl+A)
                                Click(1174, 274)
                                Sleep(1500)
                                Send("{Down 4}")
                                Sleep(1500)
                                Send("{Enter}")
                                Sleep(2000)

                                if (A_Clipboard != "") {
                                    copySuccess := true
                                    break
                                }
                            }

                            ; If focus was recovered inside copy loop, restart this family
                            if (focusRecovered) {
                                Sleep(3000)
                                continue   ; restart this family from scratch
                            }

                            if (delayedNotFoundDuringCopy) {
                                familySkipped := true
                                HandleMissingFamilyGroup(familyGroup, skippedFamilyGroups)
                                break
                            }

                            if (goldLostDuringCopy)
                                break

                            WaitIfPaused()

                            if (!copySuccess) {
                                lateDialogResult := DismissGoldDialogIfPresent()
                                if (lateDialogResult != 0) {
                                    familySkipped := true
                                    HandleMissingFamilyGroup(familyGroup, skippedFamilyGroups)
                                    break
                                }

                                LogDebug("Clipboard still empty after " . maxCopyRetries
                                    . " retries — skipping " . familyGroup)
                                familySkipped := true
                                PushSkippedFamilyGroup(skippedFamilyGroups, familyGroup)
                                break   ; skip — no retry needed
                            }

                            ; Append clipboard to CSV
                            itemsAdded := AppendClipboardToCsv(department, subDepartment, section, familyGroup)
                            if (itemsAdded == 0) {
                                lateDialogResult := DismissGoldDialogIfPresent()
                                if (lateDialogResult != 0) {
                                    familySkipped := true
                                    HandleMissingFamilyGroup(familyGroup, skippedFamilyGroups)
                                    break
                                }
                            }
                            LogDebug("Family group " . familyGroup . ": " . itemsAdded . " items added to CSV")
                            Sleep(1000)

                            familyCompleted := true
                            break   ; success — exit retry loop

                        } catch as e {
                            LogError("Critical error processing " . familyGroup . ": " . e.Message)
                            LogDebug("Error Details — File: " . e.File . " | Line: " . e.Line)

                            familySkipped := true
                            PushSkippedFamilyGroup(skippedFamilyGroups, familyGroup)

                            ShowProgressOverlay("⚠️ ERROR on " . familyGroup
                                . "  —  " . e.Message . "  —  Continuing to next family group...")
                            Sleep(2000)

                            ; Try to recover for the next iteration
                            try {
                                ClickAndType(712, 135, "")
                                Sleep(500)
                            }
                            break   ; skip — don't retry on exceptions
                        }
                    } ; end focus-recovery retry loop

                    ; If all focus-recovery retries exhausted without success or explicit skip
                    if (!familyCompleted && !familySkipped && familyAttempt >= maxFocusRetries) {
                        LogError("Max focus retries (" . maxFocusRetries . ") exhausted for " . familyGroup)
                        PushSkippedFamilyGroup(skippedFamilyGroups, familyGroup)
                    }
                }
            }
        }
    }

    HideProgressOverlay()

    LogDebug("All categories processed — work finished")

    ; ── Summary ──
    summaryMsg := "✓ Work Finished — Export Complete!`n`n"
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
