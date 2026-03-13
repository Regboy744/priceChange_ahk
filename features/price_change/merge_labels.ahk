#Requires AutoHotkey >=v2.0

; ============================================================================
; MERGE LABELS — Clipboard‑based price/label merge task
;
; Two‑press F3 workflow:
;   1st press → capture Prices Table from clipboard  (EAN → Retail Price, SKU, Units)
;   2nd press → capture Changed Labels from clipboard, merge, write merged_labels.csv
;
; Dependencies (already included via main.ahk — do NOT re-include):
;   shared\lib\csvUtils.ahk   — ParseTabDelimited(), WriteCsvFile(), EscapeCsvField()
;   shared\lib\logger.ahk     — LogDebug(), LogError()
;   shared\paths.ahk          — ProjectPath()
;
; Note: Static analysers may warn about "unassigned" functions.  Those
;       symbols are resolved at runtime because main.ahk #Includes the
;       shared libraries before this file.
; ============================================================================

; ── State ─────────────────────────────────────────────────────────────────
global MergeStep := 0       ; 0 = idle / awaiting prices,  1 = prices loaded
global PricesLookup := Map()   ; EAN → {retailPrice, sku, units}

; ── Constants ─────────────────────────────────────────────────────────────
global MERGE_OUTPUT_FILE := "merged_labels.csv"
global MERGE_OUTPUT_HEADERS := ["Till code", "Description", "Retail Price", "SKU", "Units", "Validity date"]

; ── Required columns per clipboard ────────────────────────────────────────
global PRICES_REQUIRED_COLS := ["EAN", "Retail Price", "SKU", "Units"]
global LABELS_REQUIRED_COLS := ["Till code", "Description", "Validity date"]

; ── Hotkey callback ───────────────────────────────────────────────────────

/**
 * Two‑step state machine triggered by F3.
 *   Step 0 → parse Prices Table clipboard, build lookup Map
 *   Step 1 → parse Changed Labels clipboard, merge, write CSV
 */
HandleMergeLabelHotkey() {
    global MergeStep, PricesLookup

    clipText := A_Clipboard
    if (Trim(clipText) == "") {
        ShowMergeTooltip("❌ Clipboard is empty — copy data first.")
        return
    }

    if (MergeStep == 0)
        LoadPricesFromClipboard(clipText)
    else
        MergeAndExport(clipText)
}

; ── Step 1: Load Prices Table ─────────────────────────────────────────────

/**
 * Parse the Prices Table clipboard (tab‑separated with header row).
 * Validates expected columns, builds PricesLookup keyed by EAN.
 */
LoadPricesFromClipboard(clipText) {
    global MergeStep, PricesLookup, PRICES_REQUIRED_COLS

    rows := ParseTabDelimited(clipText)

    if (rows.Length == 0) {
        ShowMergeTooltip("❌ No data rows found in clipboard.")
        return
    }

    ; Validate required columns exist in the first row
    missing := ValidateColumns(rows[1], PRICES_REQUIRED_COLS)
    if (missing != "") {
        ShowMergeTooltip("❌ Missing columns: " . missing . "`nExpected a Prices Table clipboard.")
        return
    }

    ; Build lookup Map
    PricesLookup := Map()
    for row in rows {
        ean := row.Has("EAN") ? row["EAN"] : ""
        if (ean == "")
            continue

        PricesLookup[ean] := {
            retailPrice: row.Has("Retail Price") ? row["Retail Price"] : "",
            sku: row.Has("SKU") ? row["SKU"] : "",
            units: row.Has("Units") ? row["Units"] : ""
        }
    }

    MergeStep := 1
    LogDebug("MergeLabels: Prices loaded — " . PricesLookup.Count . " items")
    ShowMergeTooltip("✅ Prices table loaded (" . PricesLookup.Count .
        " items).`nNow copy Changed Labels and press F3 again.")
}

; ── Step 2: Merge & Export ────────────────────────────────────────────────

/**
 * Parse the Changed Labels clipboard, look up each Till code in
 * PricesLookup, and write the merged result to merged_labels.csv.
 */
MergeAndExport(clipText) {
    global MergeStep, PricesLookup
    global MERGE_OUTPUT_FILE, MERGE_OUTPUT_HEADERS, LABELS_REQUIRED_COLS

    rows := ParseTabDelimited(clipText)

    if (rows.Length == 0) {
        ShowMergeTooltip("❌ No data rows found in clipboard.")
        return
    }

    ; Validate required columns
    missing := ValidateColumns(rows[1], LABELS_REQUIRED_COLS)
    if (missing != "") {
        ShowMergeTooltip("❌ Missing columns: " . missing . "`nExpected a Changed Labels clipboard.")
        return
    }

    ; Merge rows
    merged := []
    skipped := 0

    for row in rows {
        tillCode := row.Has("Till code") ? row["Till code"] : ""
        if (tillCode == "")
            continue

        if (!PricesLookup.Has(tillCode)) {
            skipped++
            continue
        }

        priceInfo := PricesLookup[tillCode]
        outRow := Map()
        outRow["Till code"] := tillCode
        outRow["Description"] := row.Has("Description") ? row["Description"] : ""
        outRow["Retail Price"] := priceInfo.retailPrice
        outRow["SKU"] := priceInfo.sku
        outRow["Units"] := priceInfo.units
        outRow["Validity date"] := row.Has("Validity date") ? row["Validity date"] : ""

        merged.Push(outRow)
    }

    ; Write output
    outPath := ProjectPath(MERGE_OUTPUT_FILE)
    ok := WriteCsvFile(outPath, MERGE_OUTPUT_HEADERS, merged)

    ; Reset state regardless of outcome
    ResetMergeState()

    if (ok) {
        msg := "✅ Merged " . merged.Length . " items → " . MERGE_OUTPUT_FILE
        if (skipped > 0)
            msg .= "`n(" . skipped . " unmatched labels skipped)"
        LogDebug("MergeLabels: " . merged.Length . " merged, " . skipped . " skipped → " . outPath)
        ShowMergeTooltip(msg)
    } else {
        ShowMergeTooltip("❌ Failed to write " . MERGE_OUTPUT_FILE . ". Check log.")
    }
}

; ── Helpers ───────────────────────────────────────────────────────────────

/**
 * Reset the merge state machine so F3 starts from scratch.
 */
ResetMergeState() {
    global MergeStep, PricesLookup
    MergeStep := 0
    PricesLookup := Map()
}

/**
 * Check that a Map row contains all required column keys.
 * @returns {String} Comma‑separated list of missing keys, or "" if all present.
 */
ValidateColumns(row, requiredCols) {
    missing := ""
    for col in requiredCols {
        if (!row.Has(col)) {
            missing .= (missing != "" ? ", " : "") . col
        }
    }
    return missing
}

/**
 * Show a temporary tooltip for 4 seconds, then auto‑dismiss.
 */
ShowMergeTooltip(text) {
    ToolTip(text)
    SetTimer(() => ToolTip(), -4000)
}
