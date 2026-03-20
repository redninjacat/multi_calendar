# Implementation Review: Focused Cell Theme Alignment

**Date:** 2026-03-20  
**Scope:** Uncommitted changes implementing **Focused Cell Theme Alignment** (library, example, tests).  
**Note:** The same git revision may also include unrelated workspace edits (e.g. steering docs, archived/deleted other specs). This report focuses on **focused-cell / keyboard theme** behavior only.

---

## Executive summary

Implementation **matches the spec intent**: `focusedCell*` on `MCalMonthViewThemeData`, cascade fixes, Day View keyboard border merged into a **single** `BoxDecoration`, **null** keyboard border color defaults with **`resolveContrastColor`** fallback, example **Focused** + **Keyboard Event Border** sections, presets, and new widget tests.

- **`flutter analyze`:** No issues found  
- **`flutter test`:** **1884** tests passed (full suite)

---

## Requirements coverage (spot-check)

| Area | Status | Notes |
|------|--------|--------|
| **R1–R2** Rename + five `focusedCell*` fields, defaults | OK | `defaults()`: bg α=0.2, border primary, width 2.0, decoration null |
| **R3** Cascade (DayCell + overflow) | OK | Overflow uses `?? defaults.monthViewTheme!.focusedCellBackgroundColor!` |
| **R2.7–2.8** Decoration override; focused border replaces grid border | OK | Composed branch replaces grid border; decoration + non-interactive dimming aligned (Gap A fixed) |
| **R4** `focusedSlot*` unchanged | OK | No regression in focused-slot API |
| **R7–R8** Single border + adaptive keyboard | OK | `time_grid_events_layer` / `all_day_events_section` merge border; null → `resolveContrastColor` |
| **R8.9** Month `week_row_widget` | OK | Adaptive path uses `rawIndicator ?? resolveContrastColor(...)` |
| **R5 / R9** Example tabs | OK | `sectionFocused` + `sectionKeyboardEventBorder` on Day/Month **theme** tabs |
| **R5.8** Presets | OK | `highContrast` month preset sets `focusedCell*` |
| **R6** Tests | OK | `day_cell_widget_test.dart`, `time_grid_events_layer_test.dart`; style tests updated for null keyboard colors |

**Repo hygiene:** `rg 'focusedDateBackgroundColor|focusedDateTextStyle' lib/` and `test/` → **no matches** (theme rename complete).

---

## Implementation quality

### Theme data

- Keyboard **`keyboardSelectionBorderColor` / `keyboardHighlightBorderColor`** default to **`null`** on both Day and Month theme data classes.
- **`lerp`** uses **`t < 0.5`** snap for `focusedCellDecoration` and `focusedCellTextStyle`, consistent with other decoration fields.

### `DayCellWidget`

- Focused path: **`focusedCellDecoration`** cascade first; else composed **`Border.all`** from focused border color/width; **non-focused** path still uses grid **`cellBorderColor` / `cellBorderWidth`** — satisfies “replace, not stack.”
- **`focusedCellTextStyle`** cascade preserves nullable `TextStyle` (matches **R6.4** edge case).

### `WeekRowWidget`

- Overflow highlight always has a color via defaults fallback; **`DecoratedBox`** applied when date matches (no null skip).

### Day View timed / all-day tiles

- Keyboard styling applied **inside** the same `Container` `BoxDecoration` as fill/radius/border — removes double-wrapper gap.
- **`rawKbColor ?? resolveContrastColor(...)`** uses the same light/dark contrast pair as text.

### Example app

- Theme tabs use **`sectionKeyboardEventBorder`** for the renamed section.
- **`sectionKeyboard`** correctly **retained** for **Day/Month features** tabs (`day_features_tab`, `month_features_tab`) — not dead l10n.

---

## Gaps, inconsistencies, and minor bugs

### A. `focusedCellDecoration` + non-interactive cells (**addressed**)

**Fix:** When **`focusedCellDecoration != null`** and **`!isInteractive`**, `_getCellDecoration` now returns **`_dimNonInteractiveFocusedFill`**, which sets fill **α = 0.6** on solid `Color` and on supported `Gradient` types (`LinearGradient`, `RadialGradient`, `SweepGradient`), leaving **border** and other `BoxDecoration` fields unchanged — parity with the composed focused branch.

### B. Dartdoc wording on `focusedCell*` (**addressed**)

**Fix:** `MCalMonthViewThemeData` dartdocs for `focusedCellBackgroundColor`, `focusedCellBorderColor`, and `focusedCellBorderWidth` now say **“focused day cell”** instead of “keyboard-focused.”

### C. Test import of private API (**hygiene**)

`test/widgets/day_cell_widget_test.dart` imports **`package:multi_calendar/src/widgets/month_subwidgets/day_cell_widget.dart`** to assert on **`DayCellWidget` / `isFocused`**. This is common for deep widget tests but **bypasses** the public barrel; acceptable for the package, optional follow-up is a **test-only export** or testing via public `MCalMonthView` only (already partially done).

### D. Timed tile: keyboard border vs. normal event border (**behavioral note**)

When keyboard highlight/selection is active, the implementation **replaces** the tile border with the keyboard border (width/color). Any separate **event tile** border is not stacked with the keyboard ring in that state. This matches a **single-ring** spec; document if consumers expect both simultaneously.

---

## Unrelated git noise (FYI)

`git diff` / status may show **deleted/moved spec folders**, **steering** edits, **TODOS**, etc. Those are **outside** this implementation review unless you intend them in the same commit.

---

## Conclusion

The focused-cell theme alignment work is **coherent, spec-aligned, analyzer-clean, and fully passing the test suite**. Remaining notes are **hygiene / awareness** only: **test-internal imports** of `day_cell_widget.dart`, and **keyboard vs. tile border** replacement during Day View focus (by design).
