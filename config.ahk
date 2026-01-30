#Requires AutoHotkey >=v2.0

; ============================================================================
; CONFIGURATION FILE
; Central location for all configurable parameters
; ============================================================================

global CONFIG := {
    ; === SHEET SETTINGS ===
    SHEET_NAME: "IMPULSE",
    ; === DATE SETTINGS ===
    START_DATE_NEW_PRICE: "31/01/26",
    END_DATE_NEW_PRICE: "",  ; Leave empty ("") for regular price change
    ; === WINDOW SETTINGS ===
    WINDOW_TITLE: "GOLD PRD - \\Remote",
    ; === UI COORDINATES ===
    ; Centralized coordinates for easy maintenance when UI changes
    COORDS: {
        START_DATE: { x: 269, y: 205 },
        ARTICLE_CODE: { x: 349, y: 136 },
        NEW_PRICE: { x: 537, y: 290 },
        SAVE_NEW_PRICE: { x: 395, y: -78 }
    },
    ; === TIMING DELAYS (milliseconds) ===
    DELAYS: {
        TINY: 100,
        SHORT: 333,
        MEDIUM: 500,
        LONG: 1000,
        CLIPBOARD_WAIT: 2000,
        SEARCH_WAIT: 3000,
        PAGE_LOAD: 2000
    },
    ; === EXCEL COLUMNS ===
    ; Column indexes in the source sheet
    COLUMNS: {
        EAN_CODE: 1,
        NEW_PRICE: 5
    },
    ; === LOGGING ===
    LOG_ENABLED: true,
    LOG_FILE: "execution.log"
}