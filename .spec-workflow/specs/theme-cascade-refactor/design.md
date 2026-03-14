# Design Document: Theme Cascade Refactor

## Overview

This design refactors the calendar theming system to implement a clear three-tier cascade for resolving visual properties. The order depends on `ignoreEventColors`: when `false` (default), **event color → consumer theme → master defaults**; when `true`, **consumer theme → event color → master defaults**. The refactor touches three theme data classes (`MCalThemeData`, `MCalMonthThemeData`, `MCalDayThemeData`), the `MCalTheme` InheritedWidget, a new shared cascade utility, and ~20 widget files that currently use hardcoded `Colors.*` or direct `colorScheme` fallbacks.

The key architectural changes are:

1. **`MCalTheme.of(context)`** returns the consumer theme as-is (no `_fillNullSubThemes`, no `fromTheme()` fallback).
2. **Master defaults** (`MCalThemeData.fromTheme(Theme.of(context))`) are resolved at the point of use in each widget, not injected as the consumer's theme.
3. A **shared cascade utility** (`resolveEventTileColor` and related helpers) replaces ~10 inline cascade implementations across tile builders.
4. All `Colors.*` literals and direct `Theme.of(context).colorScheme` accesses are removed from widget code and moved into the master defaults factories.

## Steering Document Alignment

### Technical Standards (tech.md)

- **Widget-based Architecture**: No new widget types. Changes are to existing theme data classes and widget build methods.
- **Builder Pattern**: Drop target tile builders continue to receive theme-derived colors; the cascade utility is internal.
- **Performance**: Master defaults computed once per build cycle via `MCalThemeData.fromTheme(Theme.of(context))`. No new computation; just relocation of existing fallback logic. Widgets MAY cache the defaults instance.
- **Accessibility**: No accessibility changes. Semantic labels are unaffected.

### Material 3 Color Role Alignment

New master default values use M3 semantic color roles:
- **`primary`** — focus indicators, active borders, valid drop target overlays, current time indicator
- **`primaryContainer`** — event tile and drop target tile backgrounds (prominent containers)
- **`errorContainer`** — invalid drop target tile background (error state, less emphasis)
- **`error`** — error icons, invalid overlay tints (error state, full emphasis)
- **`tertiary`** — valid drop target cell overlay (contrasting accent for heightened attention)
- **`scrim`** — modal overlay backgrounds (loading/error scrims)
- **`onSurface`** — high-emphasis text contrast color (M3 uses full opacity, not M2's 87%)
- **`onSurfaceVariant`** — lower-emphasis labels (overflow indicator, time legend, week numbers)
- **`outlineVariant`** — decorative region fills (low-contrast, no 3:1 requirement)
- **`onSurface` at 12% opacity** — disabled time slot fill (M3 disabled container pattern)
- **`outlineVariant`** — decorative borders, gridlines, tick marks, and time region borders (low-contrast separators that don't require 3:1 contrast ratio). Sub-hour gridlines use reduced alpha to maintain visual hierarchy (`0.7` for major, `0.4` for minor).

### Project Structure (structure.md)

- **Naming**: New utility file follows `snake_case.dart` convention; new properties use existing naming patterns (`dropTargetTile*`, `eventTile*`).
- **Single Responsibility**: Cascade logic extracted into a dedicated utility file; theme data classes remain focused on property storage.
- **Code Size**: The new utility file will be well under 100 lines. Theme data file additions are mechanical (properties, copyWith, lerp, ==, hashCode).
- **Module Boundaries**: The cascade utility is internal (`lib/src/utils/`); not exported from `multi_calendar.dart`. Theme data classes remain public.

## Code Reuse Analysis

### Existing Components to Leverage

- **`MCalThemeData.fromTheme(ThemeData)`**: Already derives all shared properties from `ColorScheme` and `TextTheme`. Repurposed as the "master defaults" factory — no API change needed.
- **`MCalMonthThemeData.defaults(ThemeData)`**: Already derives month-specific properties. Extended with new properties (see Data Models).
- **`MCalDayThemeData.defaults(ThemeData)`**: Already derives day-specific properties. Extended with new properties.
- **`MCalTheme.of(context)`**: Existing fallback chain. Modified to remove `_fillNullSubThemes` and change step 3 from `fromTheme()` to `MCalThemeData()`.
- **`_getContrastColor` in `time_grid_events_layer.dart`**: Luminance-based contrast logic. Extracted and generalized to use theme properties instead of hardcoded colors.

### Components to Modify

| File | Change |
|------|--------|
| `lib/src/styles/mcal_theme.dart` | Remove `_fillNullSubThemes`; change `of()` step 3; add `hoverEventBackgroundColor`, `eventTileLightContrastColor`, `eventTileDarkContrastColor`; fix lerp helpers; update `copyWith`, `lerp`, `==`, `hashCode` |
| `lib/src/styles/mcal_month_theme_data.dart` | Remove 13 duplicated properties (3 pre-applied: `cellBorderColor`, `navigatorBackgroundColor`, `navigatorTextStyle`; 10 additional: `cellBackgroundColor`, `allDayEventBackgroundColor`, `allDayEventTextStyle`, `allDayEventBorderColor`, `allDayEventBorderWidth`, `weekNumberTextStyle`, `weekNumberBackgroundColor`, `eventTileCornerRadius`, `eventTileHorizontalSpacing`, `hoverEventBackgroundColor`); add 5 new properties; update `defaults()` factory; update `copyWith`, `lerp`, `==`, `hashCode` |
| `lib/src/styles/mcal_day_theme_data.dart` | Remove 3 properties (`hoverEventBackgroundColor`, `timedEventBorderRadius`, `weekNumberTextColor`); add 14 new properties; update `defaults()` factory; update `copyWith`, `lerp`, `==`, `hashCode` |
| `lib/src/utils/theme_cascade_utils.dart` | **New file** — shared cascade utility |
| ~18 widget files | Replace inline cascades with utility calls; replace `Colors.*` with master defaults |

### Integration Points

- **`MCalTheme.of(context)`**: All widgets that call this get the consumer theme (possibly all-nulls). They then obtain master defaults separately.
- **`Theme.of(context)`**: Only accessed by master defaults factories. No widget code accesses it for color values.
- **Builder callbacks**: Continue to receive the theme via existing parameters. Builders that override tile appearance are unaffected.

## Architecture

### Cascade Resolution Model

`ignoreEventColors` controls the **priority** between event colors and theme colors. In both modes, `event.color` participates in the cascade — it is never skipped entirely.

```
ignoreEventColors: false (default)     ignoreEventColors: true
──────────────────────────────         ─────────────────────────
1. event.color                         1. consumer theme property
     ↓ (null)                               ↓ (null)
2. consumer theme property             2. event.color
     ↓ (null)                               ↓ (null)
3. defaults.property                   3. defaults.property
     (master defaults)                      (master defaults)
```

Where `defaults` = `MCalThemeData.fromTheme(Theme.of(context))`.

### Resolution Flow

```
Widget.build(context)
  │
  ├─ theme = MCalTheme.of(context)       // consumer theme (may have nulls)
  ├─ defaults = MCalThemeData.fromTheme(  // master defaults (fully populated)
  │     Theme.of(context))
  │
  ├─ tileColor = resolveEventTileColor(   // shared cascade utility
  │     theme: theme,
  │     event: event,
  │     defaults: defaults,
  │   )
  │
  └─ build widget with tileColor
```

### MCalTheme.of(context) — Before vs After

**Before:**
```
1. Find MCalTheme ancestor → _fillNullSubThemes(data, themeData)
2. Find ThemeExtension     → _fillNullSubThemes(extension, themeData)
3. Fallback                → MCalThemeData.fromTheme(themeData)   ← all properties filled
```

**After:**
```
1. Find MCalTheme ancestor → return data as-is                   ← nulls preserved
2. Find ThemeExtension     → return extension as-is               ← nulls preserved
3. Fallback                → return MCalThemeData()               ← all nulls
```

### File Organization

```
lib/src/
├── styles/
│   ├── mcal_theme.dart              # MCalTheme, MCalThemeData (modified)
│   ├── mcal_month_theme_data.dart   # MCalMonthThemeData (modified)
│   └── mcal_day_theme_data.dart     # MCalDayThemeData (modified)
├── utils/
│   └── theme_cascade_utils.dart     # NEW: resolveEventTileColor, resolveContrastColor
```

## Components and Interfaces

### Component 1: MCalTheme (modified)

- **Purpose**: InheritedWidget providing `MCalThemeData` to descendants.
- **Changes**:
  - `of(context)`: Remove `_fillNullSubThemes` calls. Change step 3 from `MCalThemeData.fromTheme(themeData)` to `MCalThemeData()`.
  - Delete `_fillNullSubThemes` static method.
  - `_lerpMonthTheme`: When both null → return null. When one null → return non-null side. Remove `MCalMonthThemeData.defaults(ThemeData.light())`.
  - `_lerpDayTheme`: Same null-handling as `_lerpMonthTheme`. Remove `MCalDayThemeData.defaults(ThemeData.light())`.

```dart
static MCalThemeData of(BuildContext context) {
  final inheritedTheme =
      context.dependOnInheritedWidgetOfExactType<MCalTheme>();
  if (inheritedTheme != null) return inheritedTheme.data;

  final extension = Theme.of(context).extension<MCalThemeData>();
  if (extension != null) return extension;

  return const MCalThemeData();
}
```

```dart
MCalMonthThemeData? _lerpMonthTheme(
  MCalMonthThemeData? a, MCalMonthThemeData? b, double t,
) {
  if (a == null && b == null) return null;
  if (a == null) return b;
  if (b == null) return a;
  return a.lerp(b, t);
}
```

### Component 2: MCalThemeData (modified)

- **Purpose**: Root theme data class, also serves as `ThemeExtension`.
- **New properties** (Req 10, 11):
  - `Color? eventTileLightContrastColor` — text on dark tiles (master default: `Colors.white`)
  - `Color? eventTileDarkContrastColor` — text on light tiles (master default: `colorScheme.onSurface`)
  - `Color? hoverEventBackgroundColor` — background color for event tiles on hover (master default: `colorScheme.primaryContainer.withValues(alpha: 0.8)`). Moved from both `MCalMonthThemeData` and `MCalDayThemeData` to the shared parent (Req 11.2).
- **`fromTheme` factory**: Add the three new properties. Existing `cellBorderColor` updated from `colorScheme.outline.withValues(alpha: 0.2)` to `colorScheme.outlineVariant` (M3 alignment — already applied to code).
- **`copyWith`, `lerp`, `==`, `hashCode`**: Updated to include new properties.

### Component 3: MCalDayThemeData (modified)

- **Purpose**: Day View specific theme properties.
- **Removed properties** (Req 11):
  - `hoverEventBackgroundColor` — moved to shared `MCalThemeData` (Req 11.2). Day View widgets now use `theme.hoverEventBackgroundColor ?? defaults.hoverEventBackgroundColor`.
  - `timedEventBorderRadius` — removed, unified with the shared `eventTileCornerRadius` on `MCalThemeData` (Req 11.3). Day View code changes from `theme.dayTheme?.timedEventBorderRadius ?? theme.eventTileCornerRadius ?? 3.0` to `theme.eventTileCornerRadius ?? defaults.eventTileCornerRadius!`.
  - `weekNumberTextColor` — removed (Req 11.4). Day View code changes from `TextStyle(color: theme.dayTheme?.weekNumberTextColor ?? Colors.black54)` to `theme.weekNumberTextStyle ?? defaults.weekNumberTextStyle!`. This unifies week number styling under a single `TextStyle` property on the parent, matching Month View.
- **New properties** (Req 3, 4, 9):

| Property | Type | Master Default | Req |
|----------|------|----------------|-----|
| `dropTargetTileBackgroundColor` | `Color?` | `colorScheme.primaryContainer` | 3 |
| `dropTargetTileInvalidBackgroundColor` | `Color?` | `colorScheme.errorContainer` | 3 |
| `dropTargetTileCornerRadius` | `double?` | `3.0` (matches shared `eventTileCornerRadius`) | 3 |
| `dropTargetTileBorderColor` | `Color?` | `colorScheme.primary` | 3 |
| `dropTargetTileBorderWidth` | `double?` | `2.0` | 3 |
| `dropTargetOverlayValidColor` | `Color?` | `colorScheme.primary.withValues(alpha: 0.2)` | 4 |
| `dropTargetOverlayInvalidColor` | `Color?` | `colorScheme.error.withValues(alpha: 0.2)` | 4 |
| `dropTargetOverlayBorderWidth` | `double?` | `3.0` | 4 |
| `dropTargetOverlayBorderColor` | `Color?` | `colorScheme.primary` | 4 |
| `disabledTimeSlotColor` | `Color?` | `colorScheme.onSurface.withValues(alpha: 0.12)` | 9 |
| `resizeHandleColor` | `Color?` | `Colors.white.withValues(alpha: 0.7)` | 9 |
| `keyboardFocusBorderColor` | `Color?` | `colorScheme.primary` | 9 |
| `focusedSlotBorderColor` | `Color?` | `colorScheme.primary` | 9 |
| `focusedSlotBorderWidth` | `double?` | `3.0` | 9 |

- **`defaults` factory**: Populate all new properties from `colorScheme`. Also populate the existing `focusedSlotBackgroundColor` property (currently missing from `defaults()`; master default: `colorScheme.primary.withValues(alpha: 0.08)`). Existing outline-based defaults updated to `outlineVariant` (M3 alignment — already applied to code): `timeLegendTickColor` → `outlineVariant`, `hourGridlineColor` → `outlineVariant`, `majorGridlineColor` → `outlineVariant.withValues(alpha: 0.7)`, `minorGridlineColor` → `outlineVariant.withValues(alpha: 0.4)`, `timeRegionBorderColor` → `outlineVariant`.
- **`copyWith`, `lerp`, `==`, `hashCode`**: Updated.

### Component 4: MCalMonthThemeData (modified)

- **Purpose**: Month View specific theme properties.
- **Removed properties** (Req 11):
  - `cellBorderColor` — duplicated the shared `MCalThemeData.cellBorderColor`. Already applied to code.
  - `navigatorBackgroundColor` — duplicated the shared `MCalThemeData.navigatorBackgroundColor`. Already applied to code.
  - `navigatorTextStyle` — duplicated the shared `MCalThemeData.navigatorTextStyle`. Already applied to code.
  - `cellBackgroundColor` — duplicated the shared `MCalThemeData.cellBackgroundColor` (Req 11.1).
  - `allDayEventBackgroundColor` — duplicated the shared `MCalThemeData.allDayEventBackgroundColor` (Req 11.1).
  - `allDayEventTextStyle` — duplicated the shared `MCalThemeData.allDayEventTextStyle` (Req 11.1).
  - `allDayEventBorderColor` — duplicated the shared `MCalThemeData.allDayEventBorderColor` (Req 11.1).
  - `allDayEventBorderWidth` — duplicated the shared `MCalThemeData.allDayEventBorderWidth` (Req 11.1).
  - `weekNumberTextStyle` — duplicated the shared `MCalThemeData.weekNumberTextStyle` (Req 11.1/11.5).
  - `weekNumberBackgroundColor` — duplicated the shared `MCalThemeData.weekNumberBackgroundColor` (Req 11.1).
  - `eventTileCornerRadius` — duplicated the shared `MCalThemeData.eventTileCornerRadius` (Req 11.1).
  - `eventTileHorizontalSpacing` — duplicated the shared `MCalThemeData.eventTileHorizontalSpacing` (Req 11.1).
  - `hoverEventBackgroundColor` — moved to shared `MCalThemeData` (Req 11.2). Month View widgets now use `theme.hoverEventBackgroundColor ?? defaults.hoverEventBackgroundColor`.
- **New properties** (Req 9):

| Property | Type | Master Default | Req |
|----------|------|----------------|-----|
| `defaultRegionColor` | `Color?` | `colorScheme.outlineVariant` | 9 |
| `resizeHandleColor` | `Color?` | `Colors.white.withValues(alpha: 0.5)` | 9 |
| `overlayScrimColor` | `Color?` | `colorScheme.scrim.withValues(alpha: 0.3)` | 9 |
| `errorIconColor` | `Color?` | `colorScheme.error` | 9 |
| `overflowIndicatorTextStyle` | `TextStyle?` | `textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)` | 9 |

- **`overflowIndicatorTextStyle` note**: This new property replaces the current fallback through `leadingDatesTextStyle` in `week_row_widget.dart`. The current code uses `theme.monthTheme?.leadingDatesTextStyle ?? TextStyle(fontSize: 10, color: Colors.grey.shade600)` for the "+N more" overflow indicator — this was a hack reusing an unrelated style. After the refactor, the cascade is simply `theme.monthTheme?.overflowIndicatorTextStyle ?? defaults.monthTheme!.overflowIndicatorTextStyle`. The `leadingDatesTextStyle` fallback is removed.
- **`defaults` factory changes**:
  - Populate all new properties.
  - Replace `Colors.green.withValues(alpha: 0.3)` → `colorScheme.tertiary.withValues(alpha: 0.3)` for `dropTargetCellValidColor`.
  - Replace `Colors.red.withValues(alpha: 0.3)` → `colorScheme.error.withValues(alpha: 0.3)` for `dropTargetCellInvalidColor`.
- **`copyWith`, `lerp`, `==`, `hashCode`**: Updated.

### Component 5: theme_cascade_utils.dart (new file)

- **Purpose**: Shared cascade resolution functions (Req 7).
- **Location**: `lib/src/utils/theme_cascade_utils.dart`
- **Functions**:

```dart
/// Resolves the background color for an event tile using the standard cascade.
///
/// [ignoreEventColors] controls the priority between event and theme colors:
/// - `false` (default): `event.color` → `themeColor` → `defaultColor`
/// - `true`: `themeColor` → `event.color` → `defaultColor`
///
/// In both modes, `event.color` participates as a fallback — it is never
/// skipped entirely.
///
/// For all-day tiles, pass [allDayThemeColor] as a higher-priority theme color
/// (e.g. theme.allDayEventBackgroundColor) and [themeColor] as the secondary
/// (e.g. theme.eventTileBackgroundColor).
Color resolveEventTileColor({
  required Color? themeColor,
  Color? allDayThemeColor,
  required Color? eventColor,
  required bool ignoreEventColors,
  required Color defaultColor,
}) {
  if (ignoreEventColors) {
    // Theme takes priority, event.color is a fallback
    return allDayThemeColor ?? themeColor ?? eventColor ?? defaultColor;
  } else {
    // Event color takes priority, theme is a fallback
    return eventColor ?? allDayThemeColor ?? themeColor ?? defaultColor;
  }
}

/// Resolves the background color for a drop target tile.
///
/// [dropTargetThemeColor] (e.g. theme.dayTheme?.dropTargetTileBackgroundColor)
/// takes first priority. If null, falls through to the standard event tile
/// cascade (which respects [ignoreEventColors]).
///
/// Pass [allDayThemeColor] when the dragged event is all-day or multi-day
/// (e.g. theme.allDayEventBackgroundColor) so the full cascade is respected.
Color resolveDropTargetTileColor({
  required Color? dropTargetThemeColor,
  required Color? themeColor,
  Color? allDayThemeColor,
  required Color? eventColor,
  required bool ignoreEventColors,
  required Color defaultColor,
}) {
  if (dropTargetThemeColor != null) return dropTargetThemeColor;
  return resolveEventTileColor(
    themeColor: themeColor,
    allDayThemeColor: allDayThemeColor,
    eventColor: eventColor,
    ignoreEventColors: ignoreEventColors,
    defaultColor: defaultColor,
  );
}

/// Resolves a contrast color for text on a tile with the given [backgroundColor].
///
/// Uses luminance to choose between [lightContrastColor] (for dark backgrounds)
/// and [darkContrastColor] (for light backgrounds).
Color resolveContrastColor({
  required Color backgroundColor,
  required Color lightContrastColor,
  required Color darkContrastColor,
}) {
  final luminance = (0.299 * backgroundColor.r +
      0.587 * backgroundColor.g +
      0.114 * backgroundColor.b);
  return luminance > 0.5 ? darkContrastColor : lightContrastColor;
}
```

### Component 6: DropTargetHighlightPainter (modified)

- **Purpose**: CustomPainter for Month View Layer 4 overlay.
- **Change**: Make `validColor` and `invalidColor` `required` constructor parameters. Remove default hex literal values.

```dart
DropTargetHighlightPainter({
  required this.validColor,
  required this.invalidColor,
  this.borderRadius = 4.0,
  // ... other params
});
```

### Component 7: Widget Updates (summary)

Each widget that currently uses `Colors.*` or direct `colorScheme` will be updated to:

1. Obtain master defaults: `final defaults = MCalThemeData.fromTheme(Theme.of(context));`
2. Resolve colors via the cascade utility or direct `theme.property ?? defaults.property` pattern.

**Pattern for sub-theme property resolution:**
```dart
// Before:
final dateLabelHeight = theme.monthTheme?.dateLabelHeight ?? 18.0;

// After:
final dateLabelHeight = theme.monthTheme?.dateLabelHeight
    ?? defaults.monthTheme!.dateLabelHeight;
```

**Pattern for drop target corner radius (Req 3.3 intermediate cascade):**
```dart
// Drop target tile corner radius has a three-step consumer cascade:
// dayTheme.dropTargetTileCornerRadius → shared theme.eventTileCornerRadius → defaults
final cornerRadius = theme.dayTheme?.dropTargetTileCornerRadius
    ?? theme.eventTileCornerRadius
    ?? defaults.eventTileCornerRadius!;
```

**Pattern for deduplicated properties moved to parent (Req 11):**
```dart
// Before (Month View accessing monthTheme duplicate):
final bgColor = theme.cellBackgroundColor ?? theme.monthTheme?.cellBackgroundColor;

// After (parent-only, with master defaults fallback):
final bgColor = theme.cellBackgroundColor ?? defaults.cellBackgroundColor;
```

**Pattern for timedEventBorderRadius → eventTileCornerRadius (Req 11.3):**
```dart
// Before (Day View):
final cornerRadius = theme.dayTheme?.timedEventBorderRadius
    ?? theme.eventTileCornerRadius ?? 3.0;

// After (Day View uses shared eventTileCornerRadius):
final cornerRadius = theme.eventTileCornerRadius
    ?? defaults.eventTileCornerRadius!;
```

**Pattern for weekNumberTextColor → weekNumberTextStyle (Req 11.4):**
```dart
// Before (Day View day_header):
TextStyle(color: theme.dayTheme?.weekNumberTextColor ?? Colors.black54)

// After (Day View uses shared weekNumberTextStyle from parent):
theme.weekNumberTextStyle ?? defaults.weekNumberTextStyle!
```

**Pattern for event tile color resolution:**
```dart
// Before (ignoreEventColors: false):
final tileColor = event.color ?? theme.eventTileBackgroundColor ?? Colors.blue;

// Before (ignoreEventColors: true):
final tileColor = theme.eventTileBackgroundColor ?? Colors.blue;

// After (both modes):
final tileColor = resolveEventTileColor(
  themeColor: theme.eventTileBackgroundColor,
  eventColor: event.color,
  ignoreEventColors: theme.ignoreEventColors,
  defaultColor: defaults.eventTileBackgroundColor!,
);
// ignoreEventColors: false → event.color → theme → defaults
// ignoreEventColors: true  → theme → event.color → defaults
```

**Widgets requiring master defaults + cascade utility:**

| Widget | Current Cascade | After |
|--------|----------------|-------|
| `time_grid_events_layer` | `ignoreEventColors → eventTileBackgroundColor → Colors.blue` | `resolveEventTileColor(...)` |
| `all_day_events_section` | `ignoreEventColors → allDayEventBackgroundColor → eventTileBackgroundColor → Colors.blue` | `resolveEventTileColor(allDayThemeColor: ..., ...)` |
| `week_row_widget` | `ignoreEventColors → eventTileBackgroundColor → Colors.blue` | `resolveEventTileColor(...)` |
| `mcal_month_multi_day_tile` | `event.color → allDayEventBackgroundColor → eventTileBackgroundColor → Colors.blue.shade100` | `resolveEventTileColor(allDayThemeColor: ..., ...)` |
| `month_page_widget` (drop target) | `dropTargetTile* → ignoreEventColors → event.color → eventTileBackgroundColor → Colors.blue` | `resolveDropTargetTileColor(...)` |
| `mcal_day_view` (drop target) | `ignoreEventColors → event.color → eventTileBackgroundColor → Colors.blue` | `resolveDropTargetTileColor(...)` |

**Widgets requiring master defaults for non-tile properties (direct `??` pattern):**

| Widget | Properties | Hardcoded Fallback Removed |
|--------|-----------|---------------------------|
| `gridlines_layer` | `hourGridlineColor`, `majorGridlineColor`, `minorGridlineColor` | `Colors.grey.withValues(alpha: 0.2/0.15/0.08)` |
| `current_time_indicator` | `currentTimeIndicatorColor` | `Colors.red` |
| `time_regions_layer` | `timeRegionBorderColor`, `timeRegionTextColor` | `Colors.grey`, `Colors.black54` |
| `time_legend_column` | `timeLegendTickColor`, `timeLegendTextStyle` | `colorScheme.outline`, `Colors.grey[600]` |
| `day_header` | `weekNumberBackgroundColor`, `weekNumberTextStyle` (replaces `weekNumberTextColor`), `dayHeaderDayOfWeekStyle`, `dayHeaderDateStyle` | `Colors.grey`, `Colors.black54`, `Colors.grey[600]`, `Colors.black87` |
| `all_day_events_section` | `cellBorderColor`, text style fallbacks | `Colors.grey`, `Colors.black87`, `Colors.grey[700]` |
| `disabled_time_slots_layer` | `disabledTimeSlotColor` | `Colors.grey.withValues(alpha: 0.3)` |
| `time_resize_handle` | `resizeHandleColor` | `Colors.white.withValues(alpha: 0.7)` |
| `month_resize_handle` | `resizeHandleColor` | `Colors.white.withValues(alpha: 0.5)` |
| `day_cell_widget` | `cellBorderColor`, `todayBackgroundColor`, `defaultRegionColor` | `Colors.grey.shade300`, `Colors.grey` |
| `weekday_header_row_widget` | `cellBorderColor` | `Colors.grey.shade300` |
| `week_number_cell` | `cellBorderColor`, `weekNumberTextStyle` | `Colors.grey.shade300`, `Colors.grey.shade600` |
| `week_row_widget` | `todayTextStyle`, `cellTextStyle`, `todayBackgroundColor`, `eventTileTextStyle`, `overflowIndicatorTextStyle` | `Colors.black87`, `Colors.grey`, `Colors.grey.shade300/600`, `Colors.white` |
| `month_overlays` | `overlayScrimColor`, `errorIconColor` | `Colors.black.withValues(alpha: 0.3)`, `colorScheme.error` |
| `month_page_widget` | `dropTargetCellValidColor`, `dropTargetCellInvalidColor` | `Colors.green`, `Colors.red` |
| `mcal_day_view` (overlay) | `dropTargetOverlayValidColor`, `dropTargetOverlayInvalidColor`, etc. | `Colors.blue`, `Colors.red` |
| `mcal_day_view` (focus) | `focusedSlotBorderColor`, `focusedSlotBorderWidth`, `keyboardFocusBorderColor` | `colorScheme.primary` |
| `day_navigator` | `navigatorBackgroundColor`, `navigatorTextStyle` | null (no fill/style when theme is all-null) |
| `month_navigator_widget` | `navigatorBackgroundColor`, `navigatorTextStyle` | null (no fill/style when theme is all-null) |

**Widgets requiring theme parameter additions:**

| Widget | Current | After |
|--------|---------|-------|
| `DisabledTimeSlotsLayer` | No theme parameter | Add `MCalThemeData theme` (or `Color? disabledTimeSlotColor`) |
| `TimeResizeHandle` | No theme parameter | Add `Color? resizeHandleColor` |
| `MonthResizeHandle` | No theme parameter | Add `Color? resizeHandleColor` |

For resize handles and disabled slots, the parent widget will pass the resolved color rather than the full theme object, keeping these widgets simple. The parent obtains the color from `theme.dayTheme?.disabledTimeSlotColor ?? defaults.dayTheme!.disabledTimeSlotColor`.

## Data Models

### MCalThemeData — New Properties

```dart
class MCalThemeData extends ThemeExtension<MCalThemeData> {
  // ... existing properties ...

  /// Light contrast color for text on dark-background event tiles.
  /// Used by the contrast color resolver when a tile's background
  /// luminance is low. Falls through to master defaults when null.
  final Color? eventTileLightContrastColor;

  /// Dark contrast color for text on light-background event tiles.
  /// Used by the contrast color resolver when a tile's background
  /// luminance is high. Falls through to master defaults when null.
  final Color? eventTileDarkContrastColor;

  /// Background color for event tiles on hover.
  /// Shared across Day View and Month View.
  /// Falls through to master defaults when null.
  final Color? hoverEventBackgroundColor;
}
```

### MCalDayThemeData — Changes

**Removed properties** (Req 11): `hoverEventBackgroundColor` (→ shared parent), `timedEventBorderRadius` (→ use shared `eventTileCornerRadius`), `weekNumberTextColor` (→ use shared `weekNumberTextStyle`).

**New properties:**

```dart
class MCalDayThemeData {
  // ... existing properties (minus removed ones above) ...

  // Drop target tile (Req 3)
  final Color? dropTargetTileBackgroundColor;
  final Color? dropTargetTileInvalidBackgroundColor;
  final double? dropTargetTileCornerRadius;
  final Color? dropTargetTileBorderColor;
  final double? dropTargetTileBorderWidth;

  // Drop target overlay (Req 4)
  final Color? dropTargetOverlayValidColor;
  final Color? dropTargetOverlayInvalidColor;
  final double? dropTargetOverlayBorderWidth;
  final Color? dropTargetOverlayBorderColor;

  // Remaining hardcoded colors (Req 9)
  final Color? disabledTimeSlotColor;
  final Color? resizeHandleColor;
  final Color? keyboardFocusBorderColor;
  final Color? focusedSlotBorderColor;
  final double? focusedSlotBorderWidth;
}
```

### MCalMonthThemeData — Changes

**Removed properties** (Req 11): `cellBorderColor` (already applied), `navigatorBackgroundColor` (already applied), `navigatorTextStyle` (already applied), `cellBackgroundColor`, `allDayEventBackgroundColor`, `allDayEventTextStyle`, `allDayEventBorderColor`, `allDayEventBorderWidth`, `weekNumberTextStyle`, `weekNumberBackgroundColor`, `eventTileCornerRadius`, `eventTileHorizontalSpacing`, `hoverEventBackgroundColor` — all moved to / already on shared `MCalThemeData`.

**New properties:**

```dart
class MCalMonthThemeData {
  // ... existing properties (minus removed ones above) ...

  // Remaining hardcoded colors (Req 9)
  final Color? defaultRegionColor;
  final Color? resizeHandleColor;
  final Color? overlayScrimColor;
  final Color? errorIconColor;
  final TextStyle? overflowIndicatorTextStyle;
}
```

## Error Handling

### Error Scenarios

1. **Consumer provides no theme at all**
   - **Handling**: `MCalTheme.of(context)` returns `MCalThemeData()` (all nulls). Every widget resolves via master defaults. Visual output is identical to current behavior.
   - **User Impact**: None — appearance matches Material theme.

2. **Consumer provides partial theme**
   - **Handling**: Non-null properties take precedence; null properties fall through to `event.color` (when applicable) then master defaults.
   - **User Impact**: Consumer sees their explicit overrides applied; everything else adapts to their app's Material theme.

3. **Consumer uses `MCalThemeData.fromTheme()` explicitly**
   - **Handling**: All properties are non-null (pre-filled by the factory). When `ignoreEventColors` is `false`, `event.color` is checked first but the cascade immediately finds a non-null theme color at step 2, so only events whose `event.color` is non-null will show their own color. When `ignoreEventColors` is `true`, the cascade short-circuits at step 1 (theme is always non-null), so `event.color` is never consulted.
   - **User Impact**: Full Material theme appearance — same as current behavior when consumer wraps in `MCalTheme(data: MCalThemeData.fromTheme(theme))`.

4. **Master defaults sub-theme is null**
   - **Handling**: `MCalThemeData.fromTheme()` always populates `monthTheme` and `dayTheme` via `MCalMonthThemeData.defaults()` and `MCalDayThemeData.defaults()`. So `defaults.monthTheme!` and `defaults.dayTheme!` are guaranteed non-null. The `!` is safe.
   - **User Impact**: None.

## Testing Strategy

### Unit Testing

**Cascade utility (`theme_cascade_utils.dart`):**
- `resolveEventTileColor`: Test all combinations of null/non-null `themeColor`, `eventColor`, `allDayThemeColor` with `ignoreEventColors` true/false.
  - `ignoreEventColors: false`, both non-null: must return `eventColor` (event wins).
  - `ignoreEventColors: true`, both non-null: must return `themeColor` (theme wins).
  - `ignoreEventColors: true`, theme null, event non-null: must return `eventColor` (fallback).
  - `ignoreEventColors: false`, event null, theme non-null: must return `themeColor` (fallback).
  - All null except `defaultColor`: must return `defaultColor`.
- `resolveDropTargetTileColor`: Test that `dropTargetThemeColor` takes precedence, then falls through to event tile cascade.
- `resolveContrastColor`: Test luminance threshold — dark background returns light contrast, light background returns dark contrast.

**MCalTheme.of(context):**
- With `MCalTheme` ancestor: returns consumer theme as-is (nulls preserved).
- With `ThemeExtension`: returns extension as-is.
- With neither: returns `MCalThemeData()` (all nulls, `ignoreEventColors: false`).
- `_fillNullSubThemes` no longer called (verify by checking `monthTheme` and `dayTheme` remain null when consumer doesn't set them).

**Lerp helpers:**
- Both null → null.
- One null → non-null side returned.
- Both non-null → interpolated.
- No `ThemeData.light()` reference anywhere.

**Theme data classes:**
- New properties present in `copyWith`, `lerp`, `==`, `hashCode`.
- `defaults()` factories populate all new properties with non-null values derived from `ColorScheme`.
- `MCalThemeData()` constructor: all new `Color?` properties default to null.
- Removed properties (`hoverEventBackgroundColor`, `timedEventBorderRadius`, `weekNumberTextColor` from `MCalDayThemeData`; 13 properties from `MCalMonthThemeData` — 3 pre-applied + 10 additional) are absent from constructors, `copyWith`, `lerp`, `==`, `hashCode`.
- `MCalDayThemeData.defaults()` no longer sets `hoverEventBackgroundColor`, `timedEventBorderRadius`, or `weekNumberTextColor`.
- `MCalMonthThemeData.defaults()` no longer sets any of the 13 removed properties.

### Widget Testing

**Tile color resolution (via cascade utility):**
- Timed event tile: verify cascade order with various theme/event color combinations.
- All-day event tile: verify `allDayEventBackgroundColor` takes precedence over `eventTileBackgroundColor`.
- Multi-day tile: verify `ignoreEventColors` is respected (Req 5).
- Drop target tiles (Day + Month): verify `dropTargetTile*` takes precedence, then falls through.
- Keyboard selection border (Month): verify uses `eventTileLightContrastColor` / `eventTileDarkContrastColor`.
- Keyboard focus border (Day): verify uses `keyboardFocusBorderColor` from theme.
- Text style color precedence (Req 10.3): when `ignoreEventColors` is `true` and consumer sets `eventTileTextStyle` with a color, the text style color takes precedence over the luminance-based contrast color.

**No hardcoded colors in widget output:**
- For each widget with removed `Colors.*` fallbacks: verify that when consumer theme is all-null, the rendered color matches the master defaults value (not a hardcoded constant).

**Drop target overlay (Day View):**
- Verify `dropTargetOverlayValidColor`, `dropTargetOverlayInvalidColor`, `dropTargetOverlayBorderWidth`, `dropTargetOverlayBorderColor` are used from theme, falling through to defaults.

**DropTargetHighlightPainter:**
- Verify `validColor` and `invalidColor` are required (compile-time enforced).

### Integration Testing

- Theme animation (lerp): Verify smooth interpolation between two `MCalThemeData` instances including new properties, with null sub-themes handled correctly.
- Light/dark mode switch: Verify master defaults adapt when `ThemeData` changes (e.g. `colorScheme.primary` changes between light and dark).
- Consumer partial theme with `ignoreEventColors: false`: Set `eventTileBackgroundColor` via `MCalTheme`, verify events with `event.color` show their own color (event wins), events without `event.color` show the theme color (fallback).
- Consumer partial theme with `ignoreEventColors: true`: Set `eventTileBackgroundColor` via `MCalTheme`, verify all events show the theme color (theme wins), events without theme color but with `event.color` fall back to event color.
