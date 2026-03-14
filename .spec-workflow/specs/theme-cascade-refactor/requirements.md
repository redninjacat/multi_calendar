# Requirements Document: Theme Cascade Refactor

## Introduction

This specification addresses two related issues in the theming system:

1. **Cascade priority bug** — `MCalThemeData.fromTheme()` (the fallback used by `MCalTheme.of(context)`) fills properties like `eventTileBackgroundColor` with Material Design defaults (e.g. `colorScheme.primaryContainer`). These auto-filled values are indistinguishable from values explicitly set by a consumer. Widgets that cascade through theme properties before `event.color` end up using a generic Material color instead of the event's own color — even though the consumer never asked for that.

2. **Day View theme parity gap** — `MCalMonthThemeData` exposes five `dropTargetTile*` theme properties for styling the default drop target tile. `MCalDayThemeData` has zero — all Day View drop target styling is hardcoded. Consumers cannot theme Day View drop targets without a custom builder.

The fix introduces a clear separation: the `MCalThemeData` default constructor leaves all nullable properties `null`. Widgets resolve nulls at the point of use with a well-defined cascade. The `fromTheme()` factory is retained as an opt-in "full Material theme" for consumers who want it, but it is no longer silently injected as a fallback. A new lightweight fallback (`MCalThemeData()` with all nulls) is used instead when no ancestor `MCalTheme` or `ThemeExtension` is found.

## Alignment with Product Vision

- **Customization First** (product.md §79.4): Theme properties should not silently override event-level colors. The event's own color should be the default unless the consumer explicitly overrides it.
- **Developer-Friendly** (product.md §79.6): A clear, documented cascade (event color → theme → fallback by default, or theme → event color → fallback when `ignoreEventColors` is true) reduces surprises and makes theming predictable.
- **Separation of Concerns** (product.md §79.1): The theme system should express *what the consumer set*, not pre-fill values that look like consumer intent but are actually factory defaults.

## Requirements

### Requirement 1: Null-Default Theme Constructor

**User Story:** As a developer, I want `MCalThemeData()` to leave all nullable color/style properties as `null`, so that I can distinguish between "consumer did not set this" and "consumer explicitly set this."

#### Acceptance Criteria

1. WHEN `MCalThemeData()` is constructed with no arguments THEN all `Color?`, `TextStyle?`, and `double?` properties SHALL be `null`. Only `bool` properties with explicit defaults (e.g. `ignoreEventColors: false`) SHALL have non-null defaults.
2. WHEN `MCalThemeData.fromTheme(ThemeData)` is called THEN the system SHALL fill properties with Material Design–derived values (current behavior preserved). This factory is opt-in for consumers who want a fully populated Material-based theme.
3. WHEN `MCalMonthThemeData()` is constructed with no arguments THEN all nullable properties SHALL be `null`. The `MCalMonthThemeData.defaults(ThemeData)` factory SHALL remain for opt-in Material defaults.
4. WHEN `MCalDayThemeData()` is constructed with no arguments THEN all nullable properties SHALL be `null`. The `MCalDayThemeData.defaults(ThemeData)` factory SHALL remain for opt-in Material defaults.

### Requirement 2: Master Defaults and Widget-Level Cascade Resolution

**User Story:** As a developer, I want a predictable, documented cascade order for how widgets resolve colors, so that my event colors appear by default and my explicit theme overrides take precedence when I set them, while unset properties still receive sensible defaults derived from the app's Material theme.

#### Master Defaults

`MCalThemeData.fromTheme(Theme.of(context))` is the **master defaults** — a single computed instance that provides all fallback values from the app's Material theme. It is the canonical term for the last-resort fallback used in every cascade. All dartdoc and documentation SHALL use the term "master defaults" when referring to this instance.

#### Acceptance Criteria

1. The system SHALL provide the master defaults via `MCalThemeData.fromTheme(Theme.of(context))` (existing factory, repurposed). This instance SHALL have all properties populated with values derived from the app's `ThemeData` (color scheme, text theme). It serves as the **last-resort fallback** — never as the primary theme.
2. WHEN `MCalTheme.of(context)` finds no `MCalTheme` ancestor and no `ThemeExtension<MCalThemeData>` THEN it SHALL return `MCalThemeData()` (all nulls) rather than `MCalThemeData.fromTheme(Theme.of(context))`. The master defaults are resolved at the point of use, not injected as the consumer's theme.
3. WHEN resolving the color for a **normal event tile** (timed event, all-day event, single-day month tile, multi-day month tile) THEN the cascade SHALL be:
   - If `ignoreEventColors` is `false` (default): `event.color` → `consumer theme property` → `defaults.property`
   - If `ignoreEventColors` is `true`: `consumer theme property` → `event.color` → `defaults.property`
   Where `defaults` = master defaults (`MCalThemeData.fromTheme(Theme.of(context))`). Each step SHALL fall through to the next when null. This means `ignoreEventColors` controls the **priority** between event colors and theme colors — when false, event colors win; when true, theme colors win. In both cases, `event.color` participates in the cascade as a fallback; it is never skipped entirely. This ensures a color is always resolved even when the event has no `event.color` and the consumer theme has not set the relevant properties.
4. WHEN resolving the color for a **drop target tile** THEN the cascade SHALL be:
   - `dropTargetTile*` consumer theme property → (same event tile cascade as criterion 3)
5. WHEN a consumer sets `eventTileBackgroundColor` via their theme but leaves `ignoreEventColors` as `false` (default), `event.color` SHALL take precedence. The theme color serves as a fallback for events without their own color. To force the theme color to override all event colors, the consumer SHALL set `ignoreEventColors: true`.
6. The master defaults instance SHALL adapt to the app's current theme (light/dark mode, color scheme changes). It SHALL NOT be a compile-time constant. Widgets MAY cache it per build cycle to avoid redundant computation.
7. The existing `_fillNullSubThemes` helper in `MCalTheme` SHALL be **removed**. `MCalTheme.of(context)` SHALL return the consumer theme as-is, without filling null `monthTheme` or `dayTheme` sub-themes with `MCalMonthThemeData.defaults()` or `MCalDayThemeData.defaults()`. When widgets need a sub-theme property (e.g. `theme.monthTheme?.dateLabelHeight`), and the sub-theme or property is `null`, they SHALL fall through to the corresponding property on the master defaults (e.g. `defaults.monthTheme!.dateLabelHeight`). This ensures a consumer theme with `monthTheme: MCalMonthThemeData(dateLabelHeight: 24)` does not get other month properties auto-filled.
8. The lerp helpers `_lerpMonthTheme` and `_lerpDayTheme` SHALL NOT use `ThemeData.light()` as a fabricated default when one side is `null`. WHEN both sides are `null` THEN lerp SHALL return `null`. WHEN only one side is `null` THEN lerp SHALL return the non-null side. This avoids injecting a fixed light-theme default that does not reflect the current app theme.

### Requirement 3: Day View Drop Target Tile Theme Properties

**User Story:** As a developer, I want `MCalDayThemeData` to expose the same `dropTargetTile*` styling properties as `MCalMonthThemeData`, so that I can theme Day View drop targets without a custom builder.

#### Acceptance Criteria

1. WHEN styling the Day View default drop target tile THEN `MCalDayThemeData` SHALL support the following theme properties (matching `MCalMonthThemeData`): `dropTargetTileBackgroundColor`, `dropTargetTileInvalidBackgroundColor`, `dropTargetTileCornerRadius`, `dropTargetTileBorderColor`, `dropTargetTileBorderWidth`.
2. WHEN these Day View properties are `null` THEN the Day View drop target tile builder SHALL fall through to the same cascade as the Month View: `dropTargetTile*` → event color cascade → `defaults.property`.
3. WHEN both `MCalDayThemeData.dropTargetTileCornerRadius` and the shared `MCalThemeData.eventTileCornerRadius` are `null` THEN the Day View drop target tile SHALL use `defaults.eventTileCornerRadius` (which derives from the app theme), falling back to 8.0 only if that is also somehow null.

### Requirement 4: Day View Drop Target Overlay Theme Properties

**User Story:** As a developer, I want `MCalDayThemeData` to expose overlay color properties for the drop target overlay (Layer 4), so that I can theme the Day View overlay the same way I can theme the Month View overlay.

#### Acceptance Criteria

1. WHEN styling the Day View drop target overlay (Layer 4) THEN `MCalDayThemeData` SHALL support the following theme properties:
   - `dropTargetOverlayValidColor` — color for valid drop target overlay (currently hardcoded `Colors.blue.withValues(alpha: 0.2)`)
   - `dropTargetOverlayInvalidColor` — color for invalid drop target overlay (currently hardcoded `Colors.red.withValues(alpha: 0.2)`)
   - `dropTargetOverlayBorderWidth` — width of the left accent bar (currently hardcoded `3`)
   - `dropTargetOverlayBorderColor` — color of the left accent bar (currently derived from valid/invalid color at full opacity)
2. WHEN these properties are `null` THEN the Day View `_buildDropTargetOverlayLayer` SHALL fall through to the corresponding `defaults.dayTheme` properties (e.g. `defaults.dayTheme!.dropTargetOverlayValidColor`, `defaults.dayTheme!.dropTargetOverlayInvalidColor`, etc.).
3. The master defaults factory SHALL provide sensible values for these properties derived from the app's `ColorScheme` (e.g. `colorScheme.primary.withValues(alpha: 0.2)` for valid overlay, `colorScheme.error.withValues(alpha: 0.2)` for invalid overlay).
4. These properties SHALL achieve parity with `MCalMonthThemeData`'s existing `dropTargetCellValidColor` and `dropTargetCellInvalidColor` (which style the Month View's Layer 4 cell overlay).

### Requirement 5: Multi-Day Tile Consistency

**User Story:** As a developer, I want `ignoreEventColors` to be respected by multi-day event tiles in Month View, so that the flag behaves consistently across all tile types.

#### Acceptance Criteria

1. WHEN `ignoreEventColors` is `true` THEN the multi-day event tile SHALL follow the cascade: `theme.allDayEventBackgroundColor` → `theme.eventTileBackgroundColor` → `event.color` → `defaults.allDayEventBackgroundColor` → `defaults.eventTileBackgroundColor` (theme takes priority, event.color is a fallback).
2. WHEN `ignoreEventColors` is `false` THEN the multi-day event tile SHALL follow the cascade: `event.color` → `theme.allDayEventBackgroundColor` → `theme.eventTileBackgroundColor` → `defaults.allDayEventBackgroundColor` → `defaults.eventTileBackgroundColor` (event.color takes priority).
3. In both cases, a color SHALL always be resolved — the master defaults guarantee non-null values at the end of the cascade.

### Requirement 6: Remove `_fillNullSubThemes`

**User Story:** As a developer, I want `MCalTheme.of(context)` to return exactly what I set, without silently populating sub-themes I did not provide, so that the cascade model works correctly.

#### Acceptance Criteria

1. `MCalTheme.of(context)` SHALL return the consumer theme as-is, without filling null `monthTheme` or `dayTheme` sub-themes (see Requirement 2.7 for full details).
2. WHEN widgets need a sub-theme property (e.g. `theme.monthTheme?.dateLabelHeight`), and the sub-theme or property is `null`, they SHALL fall through to the master defaults (e.g. `defaults.monthTheme!.dateLabelHeight`).
3. The `_fillNullSubThemes` helper SHALL be removed from the `MCalTheme` class.

### Requirement 7: Shared Cascade Utility

**User Story:** As a developer maintaining the codebase, I want a single reusable function for resolving event tile colors, so that the cascade logic is not duplicated across every tile builder and remains consistent.

#### Acceptance Criteria

1. The system SHALL provide a shared utility function (e.g. `resolveEventTileColor`) that encapsulates the standard cascade: when `ignoreEventColors` is `false`, `event.color` → `consumer theme property` → `defaults.property`; when `ignoreEventColors` is `true`, `consumer theme property` → `event.color` → `defaults.property`. In both modes, `event.color` participates in the cascade and is never skipped.
2. ALL event tile builders (timed event, all-day event, single-day month tile, multi-day month tile) SHALL use this utility instead of implementing the cascade inline.
3. A variant or parameter SHALL support the drop target tile cascade: `dropTargetTile*` → event tile cascade → `defaults.property`.
4. The utility SHALL accept the consumer theme, the event (or `event.color`), the master defaults, and any view-specific overrides (e.g. `allDayEventBackgroundColor`).

### Requirement 8: Consistent Cascade Ordering Across All Tile Types

**User Story:** As a developer, I want all event tile color cascades to follow the same pattern, so that theming behavior is predictable regardless of view or tile type.

#### Acceptance Criteria

1. WHEN resolving the color for any event tile (timed event, all-day event, single-day month tile, multi-day month tile) THEN the cascade SHALL follow the pattern in Requirement 2.3.
2. WHEN resolving the color for any drop target tile (Day View or Month View) THEN the cascade SHALL follow the pattern in Requirement 2.4.
3. WHEN `ignoreEventColors` is `false` THEN the system SHALL NOT have any tile color resolution that checks `theme.eventTileBackgroundColor` before `event.color`. WHEN `ignoreEventColors` is `true` THEN `theme.eventTileBackgroundColor` SHALL be checked before `event.color`.
4. All tile builders SHALL use the shared cascade utility (Requirement 7) to enforce consistency.

### Requirement 9: Theme Properties for Remaining Hardcoded Colors

**User Story:** As a developer, I want all visual properties to be themeable, so that the calendar adapts fully to my app's design system without hardcoded colors.

#### Acceptance Criteria

1. `MCalDayThemeData` SHALL add the following properties to replace remaining hardcoded `Colors.*` and direct `colorScheme` usages:
   - `disabledTimeSlotColor` — for `DisabledTimeSlotsLayer` (currently `Colors.grey.withValues(alpha: 0.3)`)
   - `resizeHandleColor` — for `TimeResizeHandle` (currently `Colors.white.withValues(alpha: 0.7)`)
   - `keyboardFocusBorderColor` — for the keyboard focus border on focused event tiles in `time_grid_events_layer` and `all_day_events_section` (currently `Theme.of(context).colorScheme.primary`)
   - `focusedSlotBorderColor` — for the Navigation Mode focused time slot border in `mcal_day_view` (currently `colorScheme.primary`)
   - `focusedSlotBorderWidth` — for the Navigation Mode focused time slot border width (currently hardcoded `3`)
2. `MCalMonthThemeData` SHALL add the following properties:
   - `defaultRegionColor` — for region overlays in `day_cell_widget` when `region.color` is `null` (currently `Colors.grey`)
   - `resizeHandleColor` — for `MonthResizeHandle` (currently `Colors.white.withValues(alpha: 0.5)`)
   - `overlayScrimColor` — for `LoadingOverlay` / `ErrorOverlay` scrim (currently `Colors.black.withValues(alpha: 0.3)`)
   - `errorIconColor` — for the error icon in `ErrorOverlay` (currently `Theme.of(context).colorScheme.error`)
   - `overflowIndicatorTextStyle` — for the "+N more" overflow indicator text in `week_row_widget` (currently hardcoded `TextStyle(fontSize: 10, color: Colors.grey.shade600)` via `leadingDatesTextStyle` fallback)
3. The keyboard focus/selection border in `week_row_widget` (currently `Colors.black` / `Colors.white` based on tile luminance) SHALL reuse `eventTileLightContrastColor` / `eventTileDarkContrastColor` (Requirement 10) rather than a dedicated property, since the same contrast logic applies.
4. WHEN any of these properties are `null` THEN the widget SHALL fall through to the corresponding master defaults value.
5. The master defaults factories SHALL provide sensible values for these properties derived from the app's `ColorScheme` and `TextTheme`.
6. Widgets that currently do not receive a theme parameter (e.g. `DisabledTimeSlotsLayer`, `TimeResizeHandle`, `MonthResizeHandle`) SHALL be updated to accept the theme or relevant properties.

### Requirement 10: Event Tile Text Contrast Colors

**User Story:** As a developer, I want to configure the contrast color used for text on event tiles, so that I can match my app's typography rather than relying on hardcoded black/white.

#### Acceptance Criteria

1. `MCalThemeData` SHALL add the following shared properties:
   - `eventTileLightContrastColor` — used for text on dark-background tiles (currently hardcoded `Colors.white`)
   - `eventTileDarkContrastColor` — used for text on light-background tiles (currently hardcoded `Colors.black87`)
2. The existing `_getContrastColor` utility (in `time_grid_events_layer.dart` and equivalent logic elsewhere) SHALL use these theme properties instead of hardcoded `Colors.black87` / `Colors.white`, falling through to master defaults when the consumer theme does not set them.
3. WHEN `ignoreEventColors` is `true` and the consumer has set `eventTileTextStyle` with a color THEN the text style color SHALL take precedence over the contrast color.

## Non-Functional Requirements

### Code Architecture and Modularity

- **Centralized Defaults (Master Defaults)**: `MCalThemeData.fromTheme(Theme.of(context))` — the master defaults — serves as the single source of computed fallback values. **ALL** hardcoded `Colors.*` fallbacks in `lib/src/` SHALL be removed and replaced with values from the master defaults. This includes:
  - `Colors.blue` — event tiles, drop target tiles (~15 usages)
  - `Colors.red` — invalid drop targets, overlays, current time indicator (~8 usages)
  - `Colors.grey` / `Colors.grey.shade*` — gridlines, cells, week numbers, headers, disabled slots, regions (~12 usages)
  - `Colors.green` — overlay valid color (~2 usages)
  - `Colors.black87` / `Colors.white` — contrast text, scrim, resize handles (~10 usages)
  - `Colors.black` / `Colors.black54` — keyboard selection border, region text (~5 usages)
  The master defaults factory (`MCalThemeData.fromTheme`) and its sub-theme factories (`MCalMonthThemeData.defaults`, `MCalDayThemeData.defaults`) SHALL be the **single source** for all these values, deriving them from the app's `ColorScheme` and `TextTheme`. No `Colors.*` literal SHALL appear in widget or tile-building code outside these factories.
- **No Direct `colorScheme` Access**: Widget and tile-building code SHALL NOT use `Theme.of(context).colorScheme` directly for color values. All color resolution SHALL go through the MCal theme cascade (consumer theme → master defaults). The master defaults factories are the only code that reads `colorScheme` to derive values. This ensures a single resolution path and prevents widgets from bypassing the cascade. Current direct usages that must be replaced include: `colorScheme.outline` (time legend tick), `colorScheme.primary` (Day View keyboard focus border, focused slot), and `colorScheme.error` (error icon).
- **`DropTargetHighlightPainter`**: The `validColor` and `invalidColor` parameters SHALL be `required` (no default values). Callers SHALL always pass theme-derived colors. The current default hex literals (`Color(0x4000FF00)`, `Color(0x40FF0000)`) SHALL be removed from the constructor.
- **Shared Cascade Utility**: The utility required by Requirement 7 SHALL be the single entry point for resolving tile colors. All tile builders SHALL delegate to it.
- **Backward Compatibility**: `MCalThemeData.fromTheme()` and the sub-theme `defaults()` factories SHALL continue to work for consumers who explicitly use them. The breaking change is that `MCalTheme.of(context)` no longer auto-fills via `fromTheme()`.
- **Documentation**: The cascade order and the master defaults concept SHALL be documented in dartdoc on `MCalThemeData`, the relevant theme properties, and the drop target tile builder parameters.

### Lerp Helpers

- `_lerpMonthTheme` and `_lerpDayTheme` SHALL NOT use `ThemeData.light()` as a fabricated default when one side is `null`. WHEN both sides are `null` THEN lerp SHALL return `null`. WHEN only one side is `null` THEN lerp SHALL return the non-null side (see Requirement 2.8).

### Performance

- No performance impact — this refactor changes when/where fallback values are computed but does not add new computation. Widgets MAY cache the master defaults per build cycle to avoid redundant `fromTheme()` calls.

### Reliability

- All existing tests SHALL pass after the refactor (with updates to tests that relied on auto-filled theme values or `_fillNullSubThemes`).
- The cascade behavior SHALL be covered by unit tests for each tile type.
- The shared cascade utility (Requirement 7) SHALL have dedicated unit tests verifying the cascade order for all combinations of `ignoreEventColors`, null/non-null theme properties, and null/non-null `event.color`.

### Usability

- The default visual appearance (event colors, tile styling) SHALL be preserved for consumers who do not explicitly set a theme. The only visual change is that event-level colors will now correctly appear in drop target tiles (fixing the "gray ghost tile" bug).
