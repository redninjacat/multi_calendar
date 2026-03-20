# Design Document: Focused Cell Theme Alignment

## Overview

This design aligns the "focused" theme properties across Day View and Month View so both views follow a consistent, symmetrical naming convention and resolution pattern. It also fixes the double-border rendering bug for keyboard-selected/highlighted event tiles in Day View, restores adaptive contrast-based border colors for keyboard focus rings (via null defaults + `resolveContrastColor` fallback), and reorganizes the example app Theme tabs — adding a new "Focused" section and replacing the existing "Keyboard" section with a renamed/repositioned "Keyboard Event Border" section.

The changes touch four categories of files:

1. **Theme data classes** — rename `focusedDate*` → `focusedCell*` on `MCalMonthViewThemeData`, add three new focused-cell properties, change keyboard border color defaults to `null`
2. **Widget files** — rename `focusedDate*` → `focusedCell*` references in `day_cell_widget.dart` (cascade already correct from prior hotfix) and fix the missing-defaults cascade in `week_row_widget.dart` overflow indicator; eliminate double-border wrapping in `time_grid_events_layer.dart` and `all_day_events_section.dart` (Day View only — Month View already uses merged `BoxDecoration`); add adaptive `resolveContrastColor` fallback when keyboard border color is null
3. **Example app** — add "Focused" and "Keyboard Event Border" control panel sections to both Day and Month Theme tabs, with localized labels
4. **Tests** — unit and widget tests for all changes

## Steering Document Alignment

### Technical Standards (tech.md)

- **Widget-based Architecture**: No new widget types. Changes are to existing theme data classes and widget build methods.
- **Builder Pattern**: Builder callbacks are unaffected. Focused-cell decoration is an optional full-override (`BoxDecoration?`), following the same pattern as `focusedSlotDecoration` on Day View.
- **Performance**: No performance impact. Property resolution is the same null-coalescing pattern used throughout the codebase. The `resolveContrastColor` call adds a single luminance check — identical to what was already computed pre-refactor.
- **Accessibility**: No accessibility changes. Semantic labels and screen reader announcements are unaffected by theming changes.

### Project Structure (structure.md)

- **Naming**: New properties follow existing `focusedSlot*` naming pattern (→ `focusedCell*`). File names are unchanged.
- **Single Responsibility**: Theme data classes store properties. Cascade resolution happens at point of use in widgets. Adaptive color fallback uses the existing `resolveContrastColor` utility.
- **Code Size**: No new library/source files under `lib/` or `example/lib/`. Two new test files are created under `test/widgets/` (exempt from the "no new files" principle — tests are expected to grow with the codebase). Theme data additions are mechanical (properties, constructor, copyWith, lerp, ==, hashCode). Example app additions are straightforward control panel sections.
- **Module Boundaries**: No new package or example library files; no new public exports. New test files under `test/widgets/` are the only additions. Note: renaming `focusedDate*` → `focusedCell*` on the publicly exported `MCalMonthViewThemeData` is a **breaking public API change** (see Backward Compatibility in requirements).

## Code Reuse Analysis

### Existing Components to Leverage

- **`MCalThemeData.fromTheme(ThemeData)`**: Master defaults factory. Used at point of use by widgets to get non-null fallbacks. No change needed.
- **`MCalMonthViewThemeData.defaults(ThemeData)`**: Extended with three new `focusedCell*` properties and renamed from `focusedDate*`. Keyboard border color defaults changed to `null`.
- **`MCalDayViewThemeData.defaults(ThemeData)`**: Keyboard border color defaults changed to `null`. Focused slot properties unchanged.
- **`resolveContrastColor` in `theme_cascade_utils.dart`**: Already used for event tile text contrast. Reused as the adaptive fallback for keyboard border colors when the theme provides `null`.
- **`MCalTimeGridThemeMixin`**: Reference pattern for focused-slot property structure. Month View's `focusedCell*` mirrors this structure exactly.
- **`ControlPanelSection` / `ControlWidgets`**: Existing example app widget builders for theme control panels. New sections use the same API.

### Components to Modify

| File | Change |
|------|--------|
| `lib/src/styles/mcal_month_view_theme_data.dart` | Rename `focusedDateBackgroundColor` → `focusedCellBackgroundColor`, `focusedDateTextStyle` → `focusedCellTextStyle`; add `focusedCellBorderColor`, `focusedCellBorderWidth`, `focusedCellDecoration`; change `keyboardSelectionBorderColor` and `keyboardHighlightBorderColor` defaults to `null`; update constructor, `defaults()`, `copyWith`, `lerp`, `==`, `hashCode` |
| `lib/src/styles/mcal_day_view_theme_data.dart` | Change `keyboardSelectionBorderColor` default from `colorScheme.primary` to `null`; change `keyboardHighlightBorderColor` default from `colorScheme.outline` to `null`; update `defaults()` factory |
| `lib/src/widgets/month_subwidgets/day_cell_widget.dart` | Rename `focusedDateBackgroundColor` → `focusedCellBackgroundColor`, `focusedDateTextStyle` → `focusedCellTextStyle` references (cascade pattern already correct from prior hotfix); extend `_getCellDecoration` to compose `BoxDecoration` from new border properties when `focusedCellDecoration` is null |
| `lib/src/widgets/month_subwidgets/week_row_widget.dart` | Update `focusedDateBackgroundColor` → `focusedCellBackgroundColor` reference in overflow indicator (line ~443); fix cascade fallback to use master defaults; add adaptive `resolveContrastColor` fallback for keyboard border colors |
| `lib/src/widgets/day_subwidgets/time_grid_events_layer.dart` | Eliminate double-border: replace outer `Container` wrapping with border applied directly to the tile's existing decoration; add adaptive `resolveContrastColor` fallback for null keyboard border colors |
| `lib/src/widgets/day_subwidgets/all_day_events_section.dart` | Same double-border fix and adaptive fallback as `time_grid_events_layer.dart` |
| `lib/multi_calendar.dart` | No change needed — `MCalMonthViewThemeData` is already exported |
| `example/lib/views/month_view/tabs/month_theme_tab.dart` | Add "Focused" section (3 controls); **replace** existing "Keyboard" section with renamed "Keyboard Event Border" section (same 6 controls, new title, repositioned as last section) |
| `example/lib/views/day_view/tabs/day_theme_tab.dart` | Add "Focused" section (3 controls); **replace** existing "Keyboard" section with renamed "Keyboard Event Border" section (same 6 controls, new title, repositioned as last section) |
| `example/lib/shared/utils/theme_presets.dart` | Add reasonable `focusedCell*` values to existing month theme presets (R5.8); rename any `focusedDate*` references. Note: today presets have no `focusedSlot*` keys for Day View — implementation should decide whether to add Day focused-slot preset values for parity or document that presets only touch Month. |
| `example/lib/l10n/app_en.arb` (+ 4 locales) | Add localized labels for new control panel sections and controls |
| `example/lib/l10n/app_localizations*.dart` | Regenerated by `flutter gen-l10n` |
| `test/styles/mcal_month_view_theme_data_test.dart` | Add/update tests for renamed and new properties (file exists) |
| `test/widgets/day_cell_widget_test.dart` | **New file** — widget tests for focused-cell decoration composition |
| `test/widgets/time_grid_events_layer_test.dart` | **New file** — widget tests for single-border rendering and adaptive keyboard border color. Must cover both timed events (`time_grid_events_layer.dart`) and all-day events (`all_day_events_section.dart`) per R6.9 / R7.3 — can be a single test file or split; tasks should ensure all-day coverage is not forgotten. |

### Integration Points

- **`MCalTheme.of(context)`**: Widgets continue to obtain the consumer theme via this. No change to the InheritedWidget.
- **`Theme.of(context)`**: Only accessed by master defaults factories and by widgets needing `resolveContrastColor` (which needs `lightContrastColor` / `darkContrastColor` from theme).
- **Builder callbacks**: Consumers using `eventTileBuilder` to render custom tiles are unaffected — they render their own decoration.

## Architecture

### Property Symmetry Between Views

```
Day View (MCalTimeGridThemeMixin)      Month View (MCalMonthViewThemeData)
─────────────────────────────────      ──────────────────────────────────
focusedSlotBackgroundColor             focusedCellBackgroundColor      ← renamed
focusedSlotBorderColor                 focusedCellBorderColor          ← NEW
focusedSlotBorderWidth                 focusedCellBorderWidth          ← NEW
focusedSlotDecoration                  focusedCellDecoration           ← NEW
(no text style — slots have none)      focusedCellTextStyle            ← renamed (extra)
```

Month View retains `focusedCellTextStyle` because day cells display a date label that needs styling. Day View time slots have no text content, so there is no `focusedSlotTextStyle`.

### Focused Cell Decoration Composition

When `focusedCellDecoration` is non-null, it replaces the entire cell decoration. When null (the default), the decoration is composed from individual properties:

```
focusedCellDecoration != null?
  ├── YES → Use focusedCellDecoration as-is
  └── NO  → Compose BoxDecoration(
                color: focusedCellBackgroundColor,
                border: Border.all(
                  color: focusedCellBorderColor,
                  width: focusedCellBorderWidth,
                ),
              )
```

The focused border **replaces** the normal grid border (`cellBorderColor` / `cellBorderWidth`) for that cell — they are not stacked. Today `_getCellDecoration` returns a single `BoxDecoration` with `Border.all(color: borderColor, width: borderWidth)` using grid border values. When focused, the entire decoration is swapped to use `focusedCellBorderColor` / `focusedCellBorderWidth` instead. This matches the current behavior where the focused background already replaces the normal cell background.

This mirrors Day View's `focusedSlotDecoration` override-or-compose **pattern** in `_buildFocusedSlotIndicator` (line ~6236 of `mcal_day_view.dart`). The visual geometry differs intentionally: Day View uses a `Border(left: BorderSide(...))` accent bar, while Month View uses `Border.all(...)` around all four edges (see border width asymmetry note above).

### Adaptive Keyboard Border Color Resolution

When the keyboard border color resolves to `null` (the new default), widgets compute an adaptive color using the existing `resolveContrastColor` utility:

```
Consumer theme keyboardSelectionBorderColor → non-null? Use it.
                                            → null?
Master defaults keyboardSelectionBorderColor → non-null? Use it.
                                             → null (new default)?
Widget falls back to:
  resolveContrastColor(
    backgroundColor: tileBackgroundColor,
    lightContrastColor: eventTileLightContrastColor,
    darkContrastColor: eventTileDarkContrastColor,
  )
```

This restores the pre-unified-keyboard-theme behavior where the border color adapted to the tile's background — light border on dark tiles, dark border on light tiles.

The `eventTileLightContrastColor` and `eventTileDarkContrastColor` are already resolved from the theme cascade in both `time_grid_events_layer.dart` and `week_row_widget.dart` for text contrast, so no new property resolution is needed.

### Double-Border Fix (Day View Event Tiles Only)

This issue is specific to **Day View**. Month View's `week_row_widget.dart` (lines ~721–772) already constructs a single `BoxDecoration` that includes the keyboard border — no outer wrapper is used.

In Day View, `time_grid_events_layer.dart` and `all_day_events_section.dart` currently wrap the tile in an outer `Container`:

**Current implementation** (causes double border):
```
┌─ Outer Container (keyboard border) ──────────┐
│ ┌─ Inner Container (tile decoration) ───────┐ │
│ │ Event content                              │ │
│ └────────────────────────────────────────────┘ │
└────────────────────────────────────────────────┘
  ↑ gap between borders is visible
```

**New implementation** (single border):
```
┌─ Single Container (merged decoration) ────────┐
│ Event content                                  │
└────────────────────────────────────────────────┘
```

The fix merges the keyboard border into the tile's own `BoxDecoration` rather than wrapping it in a separate `Container`. Specifically:

- In `time_grid_events_layer.dart` (~line 261): Instead of wrapping the tile `Widget` in a new `Container`, modify the tile's `BoxDecoration` to include the keyboard border. The tile is already built with a `Container` that has a `BoxDecoration` — add `border` and `borderRadius` to that decoration when the event is keyboard-highlighted/selected.
- In `all_day_events_section.dart` (~line 302): Same approach — merge the border into the tile's existing decoration.

The keyboard border color, width, and radius are still resolved from `keyboardSelectionBorder*` / `keyboardHighlightBorder*` theme properties (with the new null → adaptive fallback).

## Components and Interfaces

### Component 1: MCalMonthViewThemeData (property rename + additions)

- **Purpose:** Stores Month View-specific theme properties.
- **Changes:**
  - Remove: `focusedDateBackgroundColor`, `focusedDateTextStyle`
  - Add: `focusedCellBackgroundColor` (`Color?`), `focusedCellTextStyle` (`TextStyle?`), `focusedCellBorderColor` (`Color?`), `focusedCellBorderWidth` (`double?`), `focusedCellDecoration` (`BoxDecoration?`)
  - Modify defaults: `keyboardSelectionBorderColor` → `null`, `keyboardHighlightBorderColor` → `null`
- **Interfaces:** Constructor, `defaults()`, `copyWith`, `lerp`, `==`, `hashCode`
- **Reuses:** Existing structure of `MCalMonthViewThemeData`; mirrors `MCalTimeGridThemeMixin` focused-slot pattern

### Component 2: MCalDayViewThemeData (default change only)

- **Purpose:** Stores Day View-specific theme properties.
- **Changes:**
  - Modify defaults only: `keyboardSelectionBorderColor` → `null`, `keyboardHighlightBorderColor` → `null`
  - No property rename or addition.
- **Interfaces:** `defaults()` factory
- **Reuses:** Existing structure unchanged

### Component 3: DayCellWidget (focused cell rendering)

- **Purpose:** Renders individual day cells in Month View.
- **Changes:**
  - `_getCellDecoration`: Rename `focusedDateBackgroundColor` → `focusedCellBackgroundColor`. The cascade pattern is already correct from the prior hotfix (`theme.monthViewTheme?.property ?? defaults.monthViewTheme!.property!`). Extend the focused branch to check `focusedCellDecoration` first; if null, compose `BoxDecoration` from `focusedCellBackgroundColor`, `focusedCellBorderColor`, `focusedCellBorderWidth`.
  - `_buildDateLabel` / `_buildDefaultDateLabelWidget`: Rename `focusedDateTextStyle` → `focusedCellTextStyle`. Cascade already correct.
- **Dependencies:** `MCalThemeData`, `MCalMonthViewThemeData`
- **Reuses:** Existing cascade pattern

### Component 4: WeekRowWidget (overflow focus + keyboard border adaptive fallback)

- **Purpose:** Renders week rows with event tiles and overflow indicators.
- **Changes:**
  - Line ~443: Change `focusedDateBackgroundColor` → `focusedCellBackgroundColor` with master defaults fallback.
  - Keyboard border color resolution (~line 730): When resolved color is `null`, call `resolveContrastColor` with the tile's background color.
- **Dependencies:** `MCalThemeData`, `MCalMonthViewThemeData`, `resolveContrastColor`
- **Reuses:** `resolveContrastColor` already imported and used in same file for text contrast

### Component 5: TimeGridEventsLayer (double-border fix + adaptive fallback)

- **Purpose:** Renders timed event tiles in Day View.
- **Changes:**
  - Lines ~247-267: Remove outer `Container` wrapper. Instead, pass keyboard border properties into the tile's own `BoxDecoration`.
  - When `keyboardSelectionBorderColor` / `keyboardHighlightBorderColor` resolves to `null`, fall back to `resolveContrastColor`.
- **Dependencies:** `MCalThemeData`, `MCalDayViewThemeData`, `resolveContrastColor`
- **Reuses:** `resolveContrastColor` already imported in same file

### Component 6: AllDayEventsSection (double-border fix + adaptive fallback)

- **Purpose:** Renders all-day event tiles in Day View.
- **Changes:** Same as Component 5 — merge keyboard border into tile decoration, add adaptive fallback.
- **Dependencies:** `MCalThemeData`, `MCalDayViewThemeData`, `resolveContrastColor`
- **Reuses:** `resolveContrastColor` already imported in same file

### Component 7: Example App Theme Tabs (reorganized control sections)

- **Purpose:** Surface focused-cell/slot and keyboard border theme properties for interactive preview.
- **Changes:**
  - `month_theme_tab.dart`: Add state variables for 3 focused-cell controls. Add a new "Focused" `ControlPanelSection`. **Replace** the existing "Keyboard" section (`sectionKeyboard`) with a renamed "Keyboard Event Border" section (`sectionKeyboardEventBorder`) repositioned as the last section. The six keyboard border controls are unchanged — only the section title and position change. Wire focused-cell controls into `_buildThemeData`.
  - `day_theme_tab.dart`: Add state variables for 3 focused-slot controls. Same "Focused" section addition and "Keyboard" → "Keyboard Event Border" rename/reposition as Month.
  - ARB files (5 locales): Add labels for `sectionFocused`, `settingFocusedCellBackgroundColor`, `settingFocusedCellBorderColor`, `settingFocusedCellBorderWidth`, `settingFocusedSlotBackgroundColor`, `settingFocusedSlotBorderColor`, `settingFocusedSlotBorderWidth`, `sectionKeyboardEventBorder`. Existing `settingKeyboardSelectionBorder*` and `settingKeyboardHighlightBorder*` labels are reused.
- **Dependencies:** `ControlPanelSection`, `ControlWidgets`, `AppLocalizations`
- **Reuses:** Existing control panel pattern used in all other sections

## Data Models

### MCalMonthViewThemeData — Focused Cell Properties

```dart
// Renamed from focusedDateBackgroundColor
final Color? focusedCellBackgroundColor;

// Renamed from focusedDateTextStyle
final TextStyle? focusedCellTextStyle;

// NEW — border color for focused cell indicator
final Color? focusedCellBorderColor;

// NEW — border width for focused cell indicator
final double? focusedCellBorderWidth;

// NEW — full decoration override (takes precedence over individual properties)
final BoxDecoration? focusedCellDecoration;
```

### MCalMonthViewThemeData.defaults() — New/Changed Values

```dart
focusedCellBackgroundColor: colorScheme.primary.withValues(alpha: 0.2),  // same as old focusedDateBackgroundColor
focusedCellTextStyle: textTheme.bodyMedium?.copyWith(                     // same as old focusedDateTextStyle
  color: colorScheme.primary,
  fontWeight: FontWeight.w600,
),
focusedCellBorderColor: colorScheme.primary,   // NEW — same color role as Day View focusedSlotBorderColor
focusedCellBorderWidth: 2.0,                   // NEW — intentionally thinner than Day View's 3.0 (see note below)
focusedCellDecoration: null,                   // NEW — null = compose from individual properties
keyboardSelectionBorderColor: null,            // CHANGED from colorScheme.primary
keyboardHighlightBorderColor: null,            // CHANGED from colorScheme.outline
```

**`focusedCellBorderWidth: 2.0` vs Day View's `focusedSlotBorderWidth: 3.0`**: The asymmetry is intentional. Day View's focused slot indicator uses a `Border(left: BorderSide(..., width: 3.0))` — a thick left-edge accent bar similar to Material 3's navigation indicator. Month View cells are smaller and surrounded by grid borders, so a thinner `Border.all(..., width: 2.0)` around all four edges is more proportionate. Both use `colorScheme.primary` for the color.

### MCalDayViewThemeData.defaults() — Changed Values

```dart
keyboardSelectionBorderColor: null,            // CHANGED from colorScheme.primary
keyboardHighlightBorderColor: null,            // CHANGED from colorScheme.outline
```

### Example App ARB Additions (app_en.arb template)

```json
"sectionFocused": "Focused",
"settingFocusedCellBackgroundColor": "Focused Cell Background",
"settingFocusedCellBorderColor": "Focused Cell Border Color",
"settingFocusedCellBorderWidth": "Focused Cell Border Width",
"settingFocusedSlotBackgroundColor": "Focused Slot Background",
"settingFocusedSlotBorderColor": "Focused Slot Border Color",
"settingFocusedSlotBorderWidth": "Focused Slot Border Width",
"sectionKeyboardEventBorder": "Keyboard Event Border"
```

The "Keyboard Event Border" section reuses the existing `settingKeyboardSelectionBorder*` and `settingKeyboardHighlightBorder*` labels already defined in the ARB files. Only the section title (`sectionKeyboardEventBorder`) is new.

**ARB cleanup note:** After replacing the "Keyboard" section, `sectionKeyboard` will no longer be referenced by Day/Month Theme tabs. If no other code uses it, it should be removed from the ARB files during implementation to avoid dead strings. If other tabs reference it, it can remain.

## Error Handling

### Error Scenarios

1. **Consumer references old property names (`focusedDateBackgroundColor`, `focusedDateTextStyle`)**
   - **Handling:** Compile error — old names are fully removed, not deprecated.
   - **User Impact:** Clear error message pointing to undefined name; replacement name follows obvious pattern (`Date` → `Cell`).

2. **Keyboard border color resolves to null at point of use**
   - **Handling:** Widget computes adaptive color via `resolveContrastColor`. This always returns a non-null `Color`.
   - **User Impact:** Border adapts to tile background — visually harmonious by default.

3. **`focusedCellDecoration` conflicts with individual properties**
   - **Handling:** When `focusedCellDecoration` is non-null, individual `focusedCellBackgroundColor`, `focusedCellBorderColor`, and `focusedCellBorderWidth` are ignored. This is documented in the dartdoc and matches the `focusedSlotDecoration` precedent.
   - **User Impact:** Predictable behavior — decoration override is all-or-nothing.

## Testing Strategy

### Unit Testing

- **`MCalMonthViewThemeData`**:
  - `defaults()` returns non-null values for `focusedCellBackgroundColor`, `focusedCellBorderColor`, and `focusedCellBorderWidth`; non-null for `focusedCellTextStyle` when `ThemeData.textTheme.bodyMedium` is non-null (standard Material `ThemeData()` always provides this); `focusedCellDecoration` is null
  - `defaults()` returns `null` for `keyboardSelectionBorderColor` and `keyboardHighlightBorderColor`
  - `copyWith` correctly overrides each `focusedCell*` property
  - `lerp` interpolates `focusedCellBackgroundColor`, `focusedCellBorderColor`, `focusedCellBorderWidth`; switches `focusedCellTextStyle` at midpoint; switches `focusedCellDecoration` at t=0.5
  - `==` and `hashCode` include all five properties

- **`MCalDayViewThemeData`**:
  - `defaults()` returns `null` for `keyboardSelectionBorderColor` and `keyboardHighlightBorderColor`
  - Focused slot defaults remain unchanged

### Widget Testing

- **Month View focused cell**:
  - Default theme: focused cell renders with `focusedCellBackgroundColor` from master defaults (non-null, non-transparent)
  - Consumer theme override: focused cell uses consumer's `focusedCellBackgroundColor`
  - `focusedCellDecoration` override takes precedence over individual properties
  - `focusedCellBorderColor` and `focusedCellBorderWidth` are applied when `focusedCellDecoration` is null

- **Day View double-border fix**:
  - Keyboard-highlighted timed event has single border (no gap between border and background)
  - Keyboard-selected all-day event has single border

- **Adaptive keyboard border color**:
  - Default theme (null border color): border color adapts to tile background via `resolveContrastColor`
  - Consumer sets explicit border color: that color is used, no adaptive fallback

### Existing Test Regression

- All existing Day View `focusedSlot*` tests pass without modification (Requirement 4)
- All existing keyboard navigation tests pass (border width/radius unchanged)
- Tests and example code referencing the old `focusedDate*` names require mechanical updates to `focusedCell*` — this is expected breakage from the rename, not a regression
