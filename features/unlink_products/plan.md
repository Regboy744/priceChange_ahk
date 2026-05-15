This is a new feature that will work on the same window like the other features work.
Prefenrentiablu reuse the current functios that alredy does the same task, what changes are the coordenates and also a image check.

This a AHK V2.

Use the best practices, act like a professional expert in AHK, commente th code, DRY, easy to debug, error handler.

This is the first step.

Window:
GOLD PRD - \\Remote
ahk_class Transparent Windows Client
ahk_exe wfica32.exe
ahk_pid 345340
ahk_id 4197688

Step 1 - Click on ean_code form. 225, 173 coordanates
step2 2 - Paste the eancode. There are already a function with this action
step 3 - Search like the alt + T There are already a function with this action
step 4 - Click on the product Color: CCCCFF (Red=CC Green=CC Blue=FF) coordanats 366, 332
step 5 - Click on the tab Lable_scales coordenates: 174, 276
step 6 - Look the image on the Screenshot 2026-05-14 153554 so, is possble to check if it is checked, if it is, you have to uncheck both, so you is there any way to do that ?
step 7 - Send Alt+C to validate. GOLD pops the modal
        "G.O.L.D. - ARTICLE / SITE DATA MANAGEMENT - <date> - \\Remote".
        Click OK at Window (132, 89), wait for the modal to disappear,
        then move on to the next EAN.

---

# Implementation Plan

> Free-form notes above are the source of truth for *what* the workflow does.
> This section is the source of truth for *how* it's structured in code.
> When you add more steps above, ping me and I'll extend §4, §5 and §6.

## 1. File structure

```
PriceChange/
├── run_unlink_products.ahk                  ← thin launcher (mirrors run_price_change.ahk)
└── features/unlink_products/
    ├── main.ahk                             ← #Includes, hotkey registration
    ├── processing.ahk                       ← ProcessSingleUnlink(item, index, total)
    └── gui.ahk                              ← Excel loader + Start button + status/progress
```

Edits to existing files:

- `shared/config.ahk`       — add `CONFIG.COORDS.UNLINK` + `CONFIG.COLORS`
- `shared/lib/uiUtils.ahk`  — add two generic helpers (see §3)

## 2. Data source — Excel only

Reuse the Excel pattern from
[features/price_change/gui.ahk](../price_change/gui.ahk) (`OnLoadExcel`),
adapted for a simple one-column file:

- `StartExcelSession()` prompts for the file (any name).
- Read **first sheet** by index (`Sheets(1)` — not the `IMPULSE` name).
- Column A = EAN codes, **header on row 1**, data starting row 2.
- Populate a ListView with `Status | Row | EAN Code` (no price column).
- `EndExcelSession()` on Close / completion.

No PDF loader. No "new price" column.

## 3. New shared helpers (in `shared/lib/uiUtils.ahk`)

Both small, generic, documented; mirror the existing
`WaitForColorToDisappear` / `ClickAt` idiom so they stay DRY.

```ahk
/**
 * Wait for a colour to APPEAR at (x, y). Inverse of WaitForColorToDisappear.
 * Use when a UI element (e.g. a highlighted row) is expected to show up.
 *
 * @param targetColor    Hex without "0x" prefix, e.g. "CCCCFF"
 * @param timeout        Milliseconds (default 4000)
 * @param checkInterval  Polling ms (default 100)
 * @returns true if the colour appeared before timeout, false otherwise
 */
WaitForColorToAppear(x, y, targetColor, timeout := 4000, checkInterval := 100)

/**
 * Decide whether a checkbox is currently checked by scanning a small ROI
 * around (cx, cy) for any near-black pixel (the glyph stroke).
 *
 * Region scan + brightness threshold (not single-pixel + emptyBgColor):
 * GOLD's row striping shifts the empty-box background between products
 * (D2EDED / CFEBEB / E6E6E6 observed), so an exact `!= emptyBg` check
 * produced false positives on alternate rows.
 *
 * @param cx, cy         Centre of the checkbox interior
 * @param radius         Half-size of the scan square in px (default 5 → 11×11)
 * @param darkThreshold  Max R, G AND B value considered "dark" (default 80)
 * @returns true if any pixel in the region is dark enough to be the glyph
 */
IsCheckboxChecked(cx, cy, radius := 5, darkThreshold := 80)
```

Why pixel-color over `ImageSearch` / OCR / ONNX: GOLD's UI is flat, the
checkmark is a solid dark glyph on a light pastel background, and
`PixelGetColor` is faster, asset-free, and already the project's idiom
(see [`WaitForGoldSpinnerToFinish`](../../shared/lib/uiUtils.ahk#L584)).
ONNX/Tesseract/OpenCV were considered and rejected: ~250 MB of deps and
1–3 s cold-start per check to answer a binary "is this pixel dark?" question
the region-scan answers in microseconds with zero dependencies.

## 4. Coordinates (added to `shared/config.ahk`)

```ahk
COORDS: {
    ...existing...,
    UNLINK: {
        EAN_FIELD:           { x: 225, y: 173 },   ; Step 1
        PRODUCT_ROW:         { x: 366, y: 332 },   ; Step 4 — also pixel for CCCCFF
        LABEL_SCALES_TAB:    { x: 174, y: 276 },   ; Step 5
        SCALE_DOWNLOAD_CHK:  { x: 233, y: 357 },   ; Step 6
        PRINTABLE_CHK:       { x: 234, y: 399 },   ; Step 6
        CONFIRM_OK:          { x: 132, y: 89  }    ; Step 7 — validate dialog OK
    }
},
COLORS: {
    PRODUCT_ROW_SELECTED:    "CCCCFF"              ; Step 4 highlight
}
```

The three checkbox coordinates still need to be captured with AHK Window Spy
(both the click point AND a pixel inside the box that goes dark when checked
— they can be the same point).

## 5. Reuse map — existing functions powering each step

| Step | Reused function | Source |
|------|-----------------|--------|
| Focus / activate | `EnsureGoldFocus`, `ActivateTargetWindow` | [uiUtils.ahk](../../shared/lib/uiUtils.ahk) |
| 1 + 2 (click + paste EAN) | `SetFieldValue(x, y, value)` — click → ^a → clipboard-paste | uiUtils.ahk |
| 3 (search Alt+T) | `Send("!t")` + `WaitForGoldSpinnerToFinish()` | uiUtils.ahk |
| 4 (wait + click product) | **new** `WaitForColorToAppear` + `ClickAt` | uiUtils.ahk |
| 5 (Label_scales tab) | `ClickAt` | uiUtils.ahk |
| 6 (uncheck Scale download / Printable) | `IsCheckboxChecked` + `ClickAt` | uiUtils.ahk |
| 7 (Alt+C validate + confirm dialog) | `Send("!c")` + `WaitForGoldDialog` + `ClickAt` + `WaitForGoldDialogToClose` | uiUtils.ahk |
| Stale dialogs | `DismissGoldDialogIfPresent` | uiUtils.ahk |
| Pause / abort | `WaitIfPaused`, `TogglePause`, `BlockInput`, `ShowWorkingOverlay` | uiUtils.ahk |
| Logging / status | `LogInfo/Debug/Warn/Error`, `UpdateStatus`, `UpdateProgress` | logger.ahk, gui.ahk |

> Note: I deliberately **do not** reuse
> [`EnterArticleCode`](../../shared/lib/uiUtils.ahk#L231). It bundles `Alt+R`
> + click on `CONFIG.COORDS.ARTICLE_CODE` (349, 136) + `Alt+T`, which is the
> price-change screen. Unlink uses a different EAN field (225, 173) with no
> `Alt+R` prefix. Composing the lower-level helpers (`SetFieldValue` +
> `Send("!t")`) is cleaner DRY here.

## 6. Per-item workflow — `ProcessSingleUnlink(item, index, total)`

Same return contract as
[`ProcessSinglePriceChangeFromGui`](../price_change/processing.ahk#L25):
`"success" | "not_found" | "error"`.

```
WaitIfPaused()                                              ; pause/resume support
EnsureGoldFocus()                                           ; recover focus
DismissGoldDialogIfPresent()                                ; clear any stale modal

Step 1+2  SetFieldValue(UNLINK.EAN_FIELD.x, .y, item.ean)   ; click + select-all
                                                            ; + clipboard-paste

Step 3    Send("!t")                                        ; trigger search
          WaitForGoldSpinnerToFinish()                      ; wait for results

Step 4    if !WaitForColorToAppear(PRODUCT_ROW.x, .y,       ; highlight check
                                   "CCCCFF", 4000)
              return "not_found"                            ; row never appeared
          ClickAt(PRODUCT_ROW.x, .y)                        ; select the row

Step 5    ClickAt(LABEL_SCALES_TAB.x, .y)                   ; open Label_scales tab
          Sleep(CONFIG.DELAYS.PAGE_LOAD)                    ; let the tab render

Step 6    ToggleOffIfChecked(SCALE_DOWNLOAD_CHK, "Scale download")
          Sleep(CONFIG.DELAYS.LONG)                          ; panel redraw
          ToggleOffIfChecked(PRINTABLE_CHK,      "Printable")

Step 7    Send("!c")                                         ; validate/save
          hwnd := WaitForGoldDialog(SEARCH_WAIT, 200,
                  "G.O.L.D. - ARTICLE / SITE DATA MANAGEMENT")
          if !hwnd → return "error"                          ; save never confirmed
          WinActivate("ahk_id " hwnd)
          ClickAt(CONFIRM_OK.x, .y)                          ; dismiss the modal
          if !WaitForGoldDialogToClose(hwnd)                 ; verify it went away
              return "error"

return "success"
```

Every block:

- Calls `WaitIfPaused()` between steps so `F4` pause works mid-item.
- Wraps risky calls (`Send`, `Click`, `PixelGetColor`) in `try / catch` and
  returns `"error"` on exception with `LogError` + `UpdateStatus`.
- Logs entry/exit with `LogInfo` / `LogDebug` and updates the status bar via
  `UpdateStatus` so the GUI stays informative.

## 7. GUI — `features/unlink_products/gui.ahk`

Lean version of `price_change/gui.ahk`. Reused verbatim from price_change:
`ShowWorkingOverlay`, `HideWorkingOverlay`, `MoveGuiToCorner` /
`MoveGuiToCenter`, `UpdateStatus`, `UpdateProgress`, `UpdateListViewStatus`,
`EnableButtons` (straight copy + trim — no PDF / price / reason-code logic).

Controls:

```
[ 📊 Excel ]   [ ▶️ Start ]   [ ❌ Close ]
ListView:  Status | Row | EAN Code
Progress bar + Status label
```

The top-level loop in `OnStartAutomation` is structurally identical to the
price-change one but calls `ProcessSingleUnlink` and tracks
`success / not_found / failed` counts.

## 8. Hotkeys (`main.ahk`)

```
F4   → TogglePause()
F1   → ShowUnlinkGui()
F2   → CloseAllExcelSafely()
Esc  → AbortUnlinkAutomation()
```

`AbortUnlinkAutomation` mirrors `AbortPriceChangeAutomation` — sets
`IsRunning := false`, restores input, hides overlay, re-enables buttons.

## 9. Launcher — `run_unlink_products.ahk`

```ahk
#SingleInstance Force
#Requires AutoHotkey >=v2.0
#Include features\unlink_products\main.ahk
RegisterUnlinkProductsHotkeys()
```

## 10. Open items

- [x] Capture coords for `SCALE_DOWNLOAD_CHK`, `PRINTABLE_CHK` — done
      (233, 357) and (234, 399). No separate sample pixel needed; the 11×11
      region scan in `IsCheckboxChecked` covers ±5 px of drift.
- [x] Empty-checkbox background hex — N/A under the new region-scan
      approach (rejected: row striping shifts it between products).
- [x] Step 7 confirmation dialog — implemented via `WaitForGoldDialog`
      + `WaitForGoldDialogToClose` against title pattern
      `"G.O.L.D. - ARTICLE / SITE DATA MANAGEMENT"`, OK at (132, 89).
- [ ] Confirm `F2` should close Excel (as in price_change) or do something
      unlink-specific.

## 11. Future iterations (out of scope right now)

- Verification step (re-search the EAN and confirm checkboxes are off)
- CSV / log of skipped EANs
- Optional re-link / inverse workflow
