# GOLD Tools — AI Agent Instructions

**AutoHotkey v2 automation suite** for the GOLD PRD Windows application. Three independent workflows (Price Change, Unlink Products, Section Cost) bundled under a single launcher (Hub).

## Architecture

### Hub-and-Spoke
- **Hub** (`features/hub/`) — orchestrator GUI that launches/stops features and displays status.
- **Features** — three independent workflows, each in `features/{feature_name}/`. Each can run standalone or via the Hub (launched with `--from-hub` flag to skip duplicate hotkey binding).
- **Shared code** — utilities in `shared/lib/` (logging, UI automation, Excel/CSV parsing, PDF parsing).
- **Single CONFIG** — `shared/config.ahk` is the source of truth for window titles, UI coordinates, delays, logging.

### Process Management
- Hub uses `Run()` to spawn child processes and monitors PIDs with `ProcessExist()` / `ProcessWaitClose()`.
- Only one feature runs at a time; starting another auto-stops the current.
- Features poll for pause/resume (F4) and abort (Esc) signals.

### Shared Utilities
- **logger.ahk** — timestamped file logging (DEBUG/INFO/WARN/ERROR) → `execution.log`.
- **uiUtils.ahk** — click, type, clipboard, pause/resume, pixel polling.
- **excelUtils.ahk** — COM automation for reading `.xlsx` sheets.
- **csvUtils.ahk** — parsing GOLD clipboard data into CSV.
- **pdfUtils.ahk** — Node.js subprocess wrapper for PDF parsing (lives in `dist/pdfParser/`).
- **stringUtils.ahk** — pure string/price calculations (no dependencies).
- **jsonUtils.ahk** — JSON utilities.
- **paths.ahk** — portable project root detection.

## Development Workflow

### Running Locally
1. **Double-click** `run_gold_hub.ahk` to launch the Hub GUI.
2. **F1** to toggle the Hub window; F2/F3/F4/Esc for global hotkeys (see README).
3. Each feature can also be launched standalone by double-clicking its `.ahk` file.

### Making Changes
- Edit `.ahk` files directly; no build required for testing (AutoHotkey runtime interprets directly).
- **Config changes** in `shared/config.ahk` apply immediately on restart.
- **UI coordinate changes** — use `tools/checkbox_probe.ahk` to measure pixel positions.
- **Logging** — centralized in `execution.log`; enable with `CONFIG.LOG_ENABLED := true`.

### Building Standalone .exe
- **Double-click** `build.ahk` to compile all runners with Ahk2Exe.
- Output lands in `build/` (includes `dist/` portable Node runtime).
- Deployment: zip `build/` folder and copy to target PC; unzip anywhere and double-click `GOLD_Tools.exe`.
- **Important**: compiled `.exe` files bake in the config (especially `CONFIG.WINDOW_TITLE`). Update config **before** rebuilding if the target PC has a different GOLD window title.

## Code Conventions

### Naming
- **Functions**: verb + noun (`ProcessSinglePriceChange()`, `EnterArticleCode()`, `WaitForGoldSpinnerToFinish()`).
- **Globals**: UPPERCASE (`CONFIG`, `IsRunning`, `IsPaused`, `HubRunningPid`).
- **Module files**: `gui.ahk` (UI), `processing.ahk` (item loop), `workflow.ahk` (batch procedure), `*_map.ahk` (data tables).

### Patterns
- **Hub detection**: check `A_LineFile == A_ScriptFullPath` to detect standalone vs. included mode.
- **COM cleanup**: always wrap Excel/COM in `try-finally` to prevent leaks.
- **Hotkey conflicts**: F1 may be owned by another script; Hub gracefully falls back to tray menu.
- **State machine**: use global flags (`IsRunning`, `IsPaused`, `MergeStep`) for feature state.
- **Delays**: all timing lives in `CONFIG.DELAYS.*` (no magic numbers).

### AutoHotkey v2 Syntax
- All files start with `#Requires AutoHotkey >=v2.0`.
- `try-catch as e` with `e.Message` for exceptions.
- Arrow functions: `Hotkey("F1", (*) => TogglePause(), "On")`.
- GUI events: `GuiObject.OnEvent("Click", handler)`.
- Maps for data: `Map("key", value, ...)`.
- Static caching in functions: `static cachedValue := ""`.

## Configuration

All tunables are in `shared/config.ahk`:
- **WINDOW_TITLE** — title of the GOLD PRD window (default: `"GOLD PRD - \\Remote"`).
- **SHEET_NAME** — Excel sheet name for Price Change (default: `"IMPULSE"`).
- **COLUMNS.EAN_CODE / COLUMNS.NEW_PRICE** — column indexes for source data.
- **COORDS.*** — screen coordinates for each workflow's UI elements.
- **DELAYS.*** — sleep durations between actions (100 ms, 333 ms, 500 ms, 1000 ms, etc.).
- **LOG_ENABLED / LOG_FILE** — enable/disable logging and set output path.

### Environment-Specific Tuning
- **Different GOLD window title**: update `CONFIG.WINDOW_TITLE` and rebuild (or update `shared/config.ahk` before running standalone).
- **Different Excel sheet / columns**: update `SHEET_NAME` and `COLUMNS.*` in `CONFIG`.
- **Screen resolution / UI layout changes**: re-measure coordinates with `tools/checkbox_probe.ahk` and update `CONFIG.COORDS.*`.
- **Timing issues** (UI too slow): increase `CONFIG.DELAYS.*` values.

## Common Tasks

| Task | How |
|------|-----|
| Add a new feature | Create `features/{name}/` with `main.ahk` (entry point), `gui.ahk`, `processing.ahk`. Register in Hub's feature map. |
| Add a utility function | Create or extend a file in `shared/lib/` and `#Include` it from features that need it. |
| Debug a feature | Check `execution.log` for step-by-step audit; enable `CONFIG.LOG_ENABLED := true` and restart. |
| Fix UI mis-clicks | Use `tools/checkbox_probe.ahk` to measure pixels, then update `CONFIG.COORDS.*`. |
| Deploy to another PC | Build with `build.ahk`, zip `build/` folder, unzip on target, double-click `GOLD_Tools.exe`. |
| Change hotkey binding | Update `Hotkey()` call in the relevant feature; conflicts with other scripts will auto-fallback to tray menu. |

## Key Files & Directories

- **[README.md](README.md)** — user-facing features, hotkeys, troubleshooting, build/deploy guide.
- **[shared/config.ahk](shared/config.ahk)** — centralized configuration (single source of truth).
- **[shared/paths.ahk](shared/paths.ahk)** — project root detection (portable).
- **[features/hub/](features/hub/)** — launcher GUI and process orchestration.
- **[features/price_change/](features/price_change/)** — PDF/Excel price import and GOLD UI automation.
- **[features/unlink_products/](features/unlink_products/)** — batch unlink automation.
- **[features/section_cost/](features/section_cost/)** — cost data export with category mapping.
- **[shared/lib/](shared/lib/)** — reusable utilities (logger, UI, Excel, CSV, PDF, JSON, strings).
- **[tools/checkbox_probe.ahk](tools/checkbox_probe.ahk)** — diagnostic tool for UI coordinate measurement.
- **[build.ahk](build.ahk)** — compiles all `.ahk` files to standalone `.exe` with Ahk2Exe.
- **[execution.log](execution.log)** — centralized audit trail (all features log here; git-ignored).

## Troubleshooting Checklist

- **F1 doesn't open the Hub GUI** → Another script owns F1; right-click the system tray icon for *Show GOLD Tools*.
- **"Cannot activate Gold window"** → `CONFIG.WINDOW_TITLE` doesn't match the GOLD PRD window. Update [shared/config.ahk](shared/config.ahk) and restart.
- **PDF parsing fails** → Check that `dist/pdfParser/` exists; the GUI validates it before parsing.
- **UI clicks miss** → Measure coordinates with `tools/checkbox_probe.ahk` and update `CONFIG.COORDS.*`.
- **Excel read fails** → Verify Excel is running, file path is correct, and sheet/column names match `CONFIG`.
- **Execution log is empty** → Enable logging: set `CONFIG.LOG_ENABLED := true` and restart the feature.

## Related Documentation

- **[README.md](README.md)** — Quick start, features overview, hotkeys, deployment guide.
- **[shared/config.ahk](shared/config.ahk)** — Inline comments for all CONFIG tunables.
