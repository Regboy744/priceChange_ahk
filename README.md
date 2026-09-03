# GOLD Tools

AutoHotkey v2 automation suite for the **GOLD PRD** Windows application. Bundles three
workflows behind a single launcher (the **Hub**) so you only need to remember one hotkey.

| Feature           | What it does                                                                                       |
| ----------------- | -------------------------------------------------------------------------------------------------- |
| Price Change      | Reads a PDF, Excel, or pasted list of EAN + new price, drives GOLD's price-change screen item by item. |
| Unlink Products   | Reads an Excel or pasted list of EANs and unticks **Scale download**, **Printable**, and **Article link**. |
| Section Cost      | Iterates every department / section / family group and exports cost data to CSV via clipboard.    |

---

## Requirements

- Windows 10 / 11
- [AutoHotkey v2](https://www.autohotkey.com/) (the `.ahk` files are launched with the AHK runtime — `#Requires AutoHotkey >=v2.0`)
- Microsoft Excel (only needed when loading data from `.xlsx`)
- GOLD PRD client open with the title `GOLD PRD - \\Remote` (configured in [shared/config.ahk](shared/config.ahk))

Bundled and ready to go (no install needed):

- Node.js portable runtime — [dist/node/](dist/node/)
- PDF parser used by **Price Change** — [dist/pdfParser/](dist/pdfParser/)

---

## Quick start

1. Make sure the GOLD PRD window is open.
2. Double-click **[run_gold_hub.ahk](run_gold_hub.ahk)**.
3. Press **F1** to toggle the Hub window.
4. Click **Start** next to the workflow you want.

Only one workflow can run at a time — clicking another one stops the current one first.
The Hub also lives in the system tray (right-click for *Show*, *Stop running feature*, *Exit*).

> The same scripts can be launched **standalone** by double-clicking
> [run_price_change.ahk](run_price_change.ahk),
> [run_unlink_products.ahk](run_unlink_products.ahk), or
> [run_section_cost.ahk](run_section_cost.ahk). In standalone mode, **F1** opens that
> feature's own GUI instead of the Hub.

---

## Global hotkeys

| Key   | Action                                                                  |
| ----- | ----------------------------------------------------------------------- |
| F1    | Toggle Hub window (or feature GUI in standalone mode)                   |
| F2    | Force-close all Excel instances (Price Change / Unlink only)            |
| F3    | Merge Labels — two-press clipboard merge (Price Change only)            |
| F4    | Toggle Pause / Resume                                                   |
| Esc   | Abort the running automation                                            |

---

## Feature: Price Change

Source file: [features/price_change/](features/price_change/)

1. Open the Hub, click **Start** next to *Price Change*.
2. Load data:
   - **PDF ▼ → Parse for Price Change** — pick a price-change PDF from GOLD.
   - **PDF ▼ → Export to Excel File** — same parse, but writes the data to a new `.xlsx` instead of loading it.
   - **Excel** — opens the most recent `.xlsx` and reads sheet `IMPULSE`, column A = EAN, column B = New price.
   - **📋 Paste** — opens a box (prefilled from the clipboard) where you paste an `EAN  price` list, one item per line. Columns may be separated by Tab, space, comma, or semicolon — so copying two columns straight from Excel works. Comma decimals (`1,99`) are accepted.
3. Optionally set **Start Date**, **End Date**, and **Reason Code** (bottom-right of the GUI).
4. Click **▶️ Start**. Confirm the prompt — the script then drives GOLD for every row.
5. Each row shows ✅ success, ⚠️ not found, or ❌ failed in the preview table. A summary message appears at the end.

The Excel sheet name and column indexes are configurable in [shared/config.ahk](shared/config.ahk).

### Merge Labels (F3)

Two-press clipboard merge — useful when you have a *Prices Table* and a *Changed Labels*
export and need them joined by EAN. See [features/price_change/merge_labels.ahk](features/price_change/merge_labels.ahk).

1. Copy the Prices Table to the clipboard, press **F3** (loads EAN → price/SKU/units lookup).
2. Copy the Changed Labels to the clipboard, press **F3** again — output is written to [merged_labels.csv](merged_labels.csv).

---

## Feature: Unlink Products

Source file: [features/unlink_products/](features/unlink_products/)

1. Open the Hub, click **Start** next to *Unlink Products*.
2. Load EANs one of two ways:
   - **📊 Excel** — pick a workbook whose **first sheet, column A** lists EANs (row 1 = header).
   - **📋 Paste** — paste a list of EAN codes, one per line (any trailing columns are ignored). The box is prefilled from the clipboard.
3. Make sure GOLD is on the unlink screen, then click **▶️ Start**.
4. For each EAN the script:
   - pastes the code into the EAN field,
   - searches and waits for the row highlight,
   - opens the **Label scales** tab and unticks *Scale download* and *Printable*,
   - opens the **Assortment** tab and unticks *Article link*.

Per-step screen coordinates live in `CONFIG.COORDS.UNLINK` inside [shared/config.ahk](shared/config.ahk).
If the UI layout changes, update them there.

---

## Feature: Section Cost

Source file: [features/section_cost/](features/section_cost/)

1. Open the Hub, click **Start** next to *Section Cost*.
2. Confirm the prompt. The script iterates every family group defined in
   [features/section_cost/categories_map.ahk](features/section_cost/categories_map.ahk),
   pulls cost data out of GOLD via clipboard, and appends each batch to a CSV
   (default path: [gold_export.csv](gold_export.csv)).
3. A progress overlay at the bottom of the screen shows `[current / total]  —  family | section | sub-dept`.

Press **F4** to pause/resume mid-run, **Esc** to abort.

---

## Configuration

All tunables live in one place: **[shared/config.ahk](shared/config.ahk)**.

- `WINDOW_TITLE` — title of the GOLD PRD window the scripts target.
- `SHEET_NAME` — Excel sheet name for Price Change (`IMPULSE` by default).
- `COLUMNS.EAN_CODE` / `COLUMNS.NEW_PRICE` — column indexes in the source sheet.
- `COORDS.*` — screen coordinates clicked by each workflow. Update these if the GOLD UI moves.
- `DELAYS.*` — sleep durations between UI actions.
- `LOG_ENABLED` / `LOG_FILE` — toggles the execution log ([execution.log](execution.log)).

---

## Build a standalone version (.exe) for other computers

The whole suite can be compiled into standalone `.exe` files so you can
launch by double-clicking an icon — no AutoHotkey installation required on
the target PC.

### Build (on a machine with AutoHotkey v2 installed)

1. Double-click **[build.ahk](build.ahk)**.
2. Wait a few seconds — the script runs `Ahk2Exe` for every runner.
3. Output lands in [build/](build/):

   ```
   build/
     GOLD_Tools.exe          ← launcher (was run_gold_hub.ahk)
     run_price_change.exe
     run_unlink_products.exe
     run_section_cost.exe
     assets/                 ← icons (copied as-is)
     dist/                   ← node + pdfParser (copied as-is)
   ```

The Hub auto-detects the compiled siblings — when `run_price_change.exe`
exists next to `run_price_change.ahk`, it launches the `.exe`; otherwise it
falls back to the `.ahk` source via the installed AHK runtime. So the same
[features/hub/gui.ahk](features/hub/gui.ahk) works for both dev and production.

### Deploy to another computer

1. Zip the entire `build/` folder.
2. Copy it to the target PC and unzip anywhere (e.g. `C:\GOLD_Tools\`).
3. Right-click **`GOLD_Tools.exe`** → *Send to* → *Desktop (create shortcut)*.
4. The desktop shortcut already shows the GOLD icon (it's baked into the `.exe`).
5. Double-click the shortcut to launch.

> Make sure the target PC has the GOLD PRD client open with the same window
> title (`GOLD PRD - \\Remote`). If not, update `CONFIG.WINDOW_TITLE` in
> [shared/config.ahk](shared/config.ahk) **before** building, since
> compiled `.exe` files bake in the config.

### Tweaking config after deployment

The compiled `.exe` files have `shared/config.ahk` baked in, so changing
that file on the target PC has no effect. If you need per-machine settings,
rebuild on the source PC after editing config and re-deploy the `build/`
folder.

---

## Troubleshooting

- **F1 doesn't open anything** — another GOLD script may already own F1. The Hub falls back to the system tray icon; right-click it → *Show GOLD Tools*.
- **"Cannot activate Gold window"** — the title in `CONFIG.WINDOW_TITLE` doesn't match. Adjust it in [shared/config.ahk](shared/config.ahk).
- **PDF parse fails** — the bundled Node parser lives in [dist/pdfParser/](dist/pdfParser/). Make sure that folder still exists; the price-change GUI checks for it before parsing.
- **Mis-clicks after a GOLD UI update** — re-measure and update `CONFIG.COORDS.*`. The helper [tools/checkbox_probe.ahk](tools/checkbox_probe.ahk) prints the pixel under the cursor.
- **Detailed log** — [execution.log](execution.log) records every step with timestamps.

---

## Project layout

```
PriceChange/
├── run_gold_hub.ahk          ← main entry point (double-click this)
├── run_price_change.ahk      ← standalone Price Change
├── run_unlink_products.ahk   ← standalone Unlink Products
├── run_section_cost.ahk      ← standalone Section Cost
├── build.ahk                 ← compile all runners to .exe (see Build section)
├── features/
│   ├── hub/                  ← launcher GUI + process management
│   ├── price_change/         ← GUI, processing, F3 merge labels
│   ├── unlink_products/      ← GUI + processing
│   └── section_cost/         ← workflow + categories map
├── shared/
│   ├── config.ahk            ← single source of config
│   ├── paths.ahk
│   └── lib/                  ← logger, csv/excel/ui/pdf/json/string utils
├── dist/
│   ├── node/                 ← portable Node.js runtime
│   ├── pdfParser/            ← Node-based PDF parser
│   └── icon/
├── tools/                    ← diagnostic helpers
├── assets/                   ← icons / images
└── execution.log             ← runtime log
```
