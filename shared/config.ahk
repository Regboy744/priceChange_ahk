#Requires AutoHotkey >=v2.0
#Include paths.ahk

; ============================================================================
; CONFIGURATION
; Central location for all configurable parameters.
; Every feature and library reads from this single CONFIG object.
; ============================================================================

global CONFIG := {
    ; --- Project root (auto-detected) ---
    ROOT_DIR: GetProjectRoot(),
    ; === SHEET SETTINGS ===
    SHEET_NAME: "IMPULSE",
    ; === WINDOW SETTINGS ===
    WINDOW_TITLE: "GOLD PRD - \\Remote",
    ; === UI COORDINATES ===
    ; Centralized coordinates for easy maintenance when UI layout changes
    COORDS: {
        START_DATE: { x: 269, y: 205 },
        ARTICLE_CODE: { x: 349, y: 136 },
        NEW_PRICE: { x: 537, y: 290 },
        PRICE_CHANGE_DIALOG_OK: { x: 693, y: 378 },
        ; --- Unlink Products screen ---
        ; x=0,y=0 sentinels mean "not configured yet"; ProcessSingleUnlink
        ; logs a warning and skips that checkbox rather than mis-clicking.
        UNLINK: {
            EAN_FIELD:           { x: 225, y: 173 },   ; Step 1
            PRODUCT_ROW:         { x: 366, y: 332 },   ; Step 4 — also pixel for CCCCFF
            LABEL_SCALES_TAB:    { x: 174, y: 276 },   ; Step 5
            SCALE_DOWNLOAD_CHK:  { x: 233, y: 357 },   ; Step 6
            PRINTABLE_CHK:       { x: 234, y: 399 },   ; Step 6
            CONFIRM_OK:          { x: 132, y: 89  }    ; Step 7 — OK button on the
                                                       ;          "ARTICLE / SITE DATA
                                                       ;          MANAGEMENT" save dialog
        }
    },
    ; === PIXEL COLOURS ===
    ; Reference colours used by pixel-polling helpers (WaitForColorToAppear).
    ; Hex without "0x" prefix, uppercase.
    COLORS: {
        PRODUCT_ROW_SELECTED: "CCCCFF"    ; Highlight when a product row is selected
    },
    ; === TIMING DELAYS (milliseconds) ===
    DELAYS: {
        TINY: 100,
        SHORT: 333,
        MEDIUM: 500,
        LONG: 1000,
        SEARCH_WAIT: 4000,
        PAGE_LOAD: 2000
    },
    ; === EXCEL COLUMNS ===
    ; Column indexes in the source sheet
    COLUMNS: {
        EAN_CODE: 1,
        NEW_PRICE: 2
    },
    ; === LOGGING ===
    LOG_ENABLED: true,
    LOG_FILE: "execution.log"
}
