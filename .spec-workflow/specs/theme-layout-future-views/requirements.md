# Requirements Document: Theme Layout Properties and Future View Preparation

## Introduction

This specification restructures the Multi Calendar theming system to eliminate all hardcoded visual layout values, remove property duplication, and establish an architecture that naturally extends to future views (Multi-Day, Pivoted Multi-Day). It builds on the fully implemented `theme-cascade-refactor` spec.

The current `MCalDayThemeData` is a 46-property class covering time grids, all-day events, and day headers. This monolithic design does not scale: a future Multi-Day View would need the same time-grid and all-day properties but not the day-header ones. Meanwhile, `MCalThemeData` (the parent) holds ~20 properties, many of which are event-tile properties that benefit from per-view control, and several that are duplicated across both sub-themes.

This spec addresses all three problems with a mixin-based architecture:

- **Three mixins** (`MCalEventTileThemeMixin`, `MCalTimeGridThemeMixin`, `MCalAllDayThemeMixin`) define property contracts once. View-level theme classes mix in the relevant ones.
- **Zero property duplication** — each property is defined in exactly one place (a mixin or a specific class).
- **Zero hardcoded visual values** — every padding, margin, spacing, border width/radius, icon size, and font size in widget code is replaced with a theme property that has a master default.
- **Slim parent** — `MCalThemeData` is reduced to ~7 truly global properties. Event tile, contrast, hover, drop target, and week number properties move into per-view themes via mixins.
- **Consumer clarity** — consumers still interact with only 2 sub-themes (`dayViewTheme`, `monthTheme`). Mixins are internal organization.

## Alignment with Product Vision

- **Customization First** (product.md §79.4): Moving event tile properties to per-view themes gives consumers fine-grained control over each view's appearance. Theming every hardcoded layout value ensures full customization without forking.
- **Separation of Concerns** (product.md §79.1): Mixins separate time-grid, all-day, and event-tile concerns cleanly. Future views compose only the relevant mixins.
- **Developer-Friendly** (product.md §79.6): Consumers see a flat API per view — they don't need to know about mixins. The renamed `enableEventColorOverrides` flag has clear semantics.
- **Modularity Over Monolith** (product.md §79.2): Each view's theme class composes exactly the mixins it needs. No view inherits irrelevant properties.

## Requirements

### Requirement 1: Rename MCalDayThemeData and Property Accessor

**User Story:** As a developer, I want the Day View theme class name to clearly indicate it is view-specific, so that naming is consistent with future view theme classes.

#### Acceptance Criteria

1. WHEN referring to the Day View theme class THEN the class SHALL be named `MCalDayViewThemeData` (renamed from `MCalDayThemeData`).
2. WHEN accessing the Day View theme on `MCalThemeData` THEN the property SHALL be named `dayViewTheme` (renamed from `dayTheme`).
3. WHEN the file `mcal_day_theme_data.dart` is renamed THEN the new filename SHALL be `mcal_day_view_theme_data.dart`.
4. ALL references in library code, example app, and tests SHALL be updated to use the new names.

### Requirement 2: Rename ignoreEventColors to enableEventColorOverrides

**User Story:** As a developer, I want the cascade control flag to have clear, positive semantics, so that I can understand its effect without reading documentation.

#### Acceptance Criteria

1. WHEN controlling whether theme colors override per-event colors THEN the property SHALL be named `enableEventColorOverrides` (renamed from `ignoreEventColors`).
2. WHEN `enableEventColorOverrides` is `false` (default) THEN the cascade order SHALL remain: `event.color` → `consumer theme property` → `master defaults` (event colors take precedence).
3. WHEN `enableEventColorOverrides` is `true` THEN the cascade order SHALL remain: `consumer theme property` → `event.color` → `master defaults` (theme overrides event colors).
4. The cascade utility functions SHALL be updated to use the new parameter name.
5. ALL references in library code, example app, tests, and dartdoc SHALL be updated.

### Requirement 3: Create MCalEventTileThemeMixin

**User Story:** As a developer, I want event tile styling properties available on each view's theme independently, so that I can style Day View and Month View event tiles differently while avoiding property duplication in the code.

#### Acceptance Criteria

1. The system SHALL define a mixin `MCalEventTileThemeMixin` in a new file `mcal_event_tile_theme_mixin.dart` containing abstract getters for the following properties:
   - Event tile appearance: `eventTileBackgroundColor` (Color?), `eventTileTextStyle` (TextStyle?), `eventTileCornerRadius` (double?), `eventTileHorizontalSpacing` (double?), `eventTileBorderWidth` (double?), `eventTileBorderColor` (Color?)
   - Hover: `hoverEventBackgroundColor` (Color?)
   - Contrast: `eventTileLightContrastColor` (Color?), `eventTileDarkContrastColor` (Color?)
   - Week number: `weekNumberTextStyle` (TextStyle?), `weekNumberBackgroundColor` (Color?)
   - Drop target tile: `dropTargetTileBackgroundColor` (Color?), `dropTargetTileInvalidBackgroundColor` (Color?), `dropTargetTileCornerRadius` (double?), `dropTargetTileBorderColor` (Color?), `dropTargetTileBorderWidth` (double?)
   - Resize handle: `resizeHandleColor` (Color?)
   - Multi-day events: `multiDayEventBackgroundColor` (Color?) — cascade-eligible color for multi-day event tiles. In Month View this colors the horizontal bar segments; in Day View it colors multi-day events that appear in the all-day section or as timed tiles.
2. `MCalDayViewThemeData` SHALL mix in `MCalEventTileThemeMixin` and implement all abstract getters as final fields.
3. `MCalMonthThemeData` SHALL mix in `MCalEventTileThemeMixin` and implement all abstract getters as final fields.
4. The 5 `dropTargetTile*` properties and `resizeHandleColor` that currently exist on both `MCalDayThemeData` and `MCalMonthThemeData` as separate declarations SHALL be consolidated into this mixin (defined once, no duplication).
5. `multiDayEventBackgroundColor`, currently declared only on `MCalMonthThemeData`, SHALL move into this mixin so that both Day View and Month View can independently theme multi-day events.
6. `eventTileBorderWidth` and `eventTileBorderColor`, currently declared only on `MCalMonthThemeData`, SHALL move into this mixin so that both Day View (timed event tiles) and Month View can independently theme event tile borders. All-day event tile borders use separate properties (`allDayEventBorderWidth`, `allDayEventBorderColor`) defined in `MCalAllDayThemeMixin` (see Req 5).
7. The 9 properties currently on `MCalThemeData` (parent) that are moved into this mixin (`eventTileBackgroundColor`, `eventTileTextStyle`, `eventTileCornerRadius`, `eventTileHorizontalSpacing`, `hoverEventBackgroundColor`, `eventTileLightContrastColor`, `eventTileDarkContrastColor`, `weekNumberTextStyle`, `weekNumberBackgroundColor`) SHALL be **removed from `MCalThemeData`**.
8. WHEN widgets resolve event tile properties THEN they SHALL read from the per-view theme (e.g. `theme.dayViewTheme?.eventTileBackgroundColor`) instead of the parent theme.

### Requirement 4: Create MCalTimeGridThemeMixin

**User Story:** As a developer, I want time-grid properties grouped in a mixin, so that future time-grid views (Multi-Day, Pivoted Multi-Day) can reuse them without duplicating property definitions.

#### Acceptance Criteria

1. The system SHALL define a mixin `MCalTimeGridThemeMixin` in a new file `mcal_time_grid_theme_mixin.dart` containing abstract getters for all existing time-grid-related properties currently on `MCalDayThemeData`:
   - Time legend: `timeLegendWidth`, `timeLegendTextStyle`, `timeLegendBackgroundColor`, `timeLegendTickColor`, `timeLegendTickWidth`, `timeLegendTickLength`, `showTimeLegendTicks`, `timeLabelPosition`
   - Gridlines: `hourGridlineColor`, `hourGridlineWidth`, `majorGridlineColor`, `majorGridlineWidth`, `minorGridlineColor`, `minorGridlineWidth`
   - Current time indicator: `currentTimeIndicatorColor`, `currentTimeIndicatorWidth`, `currentTimeIndicatorDotRadius`
   - Time regions: `specialTimeRegionColor`, `blockedTimeRegionColor`, `timeRegionBorderColor`, `timeRegionTextColor`, `timeRegionTextStyle`
   - Timed events: `timedEventMinHeight`, `timedEventPadding`
   - Hover/focus: `hoverTimeSlotBackgroundColor`, `focusedSlotBackgroundColor`, `focusedSlotBorderColor`, `focusedSlotBorderWidth`, `focusedSlotDecoration`
   - Drop target overlay: `dropTargetOverlayValidColor`, `dropTargetOverlayInvalidColor`, `dropTargetOverlayBorderWidth`, `dropTargetOverlayBorderColor`
   - Other: `disabledTimeSlotColor`, `keyboardFocusBorderColor`, `resizeHandleSize`, `minResizeDurationMinutes`
2. The mixin SHALL also include abstract getters for **new** layout properties that replace hardcoded values in time-grid widgets:
   - `timeLegendLabelHeight` (double?) — replaces hardcoded `20.0` in `time_legend_column.dart`
   - `timedEventMargin` (EdgeInsets?) — replaces hardcoded `EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0)` in `time_grid_events_layer.dart`
   - `timedEventKeyboardFocusBorderWidth` (double?) — replaces hardcoded `2` in `time_grid_events_layer.dart`
   - `timedEventCompactFontSize` (double?) — replaces hardcoded `10` in `time_grid_events_layer.dart`
   - `timedEventNormalFontSize` (double?) — replaces hardcoded `12` in `time_grid_events_layer.dart`
   - `timeRegionBorderWidth` (double?) — replaces hardcoded `1` in `time_regions_layer.dart`
   - `timeRegionIconSize` (double?) — replaces hardcoded `16` in `time_regions_layer.dart`
   - `timeRegionIconGap` (double?) — replaces hardcoded `4` in `time_regions_layer.dart`
   - `resizeHandleVisualHeight` (double?) — replaces hardcoded `2` (bar height) in `time_resize_handle.dart`
   - `resizeHandleHorizontalMargin` (double?) — replaces hardcoded `4` (horizontal margin per side; the bar width `tileWidth - 8` is derived from this value × 2) in `time_resize_handle.dart`
   - `resizeHandleBorderRadius` (double?) — replaces hardcoded `1` in `time_resize_handle.dart`
3. `MCalDayViewThemeData` SHALL mix in `MCalTimeGridThemeMixin` and implement all abstract getters.

### Requirement 5: Create MCalAllDayThemeMixin

**User Story:** As a developer, I want all-day event section properties grouped in a mixin, so that future views with all-day sections (Multi-Day) can reuse them.

#### Acceptance Criteria

1. The system SHALL define a mixin `MCalAllDayThemeMixin` in a new file `mcal_all_day_theme_mixin.dart` containing abstract getters for:
   - Colors/styles (moved from `MCalThemeData` parent): `allDayEventBackgroundColor` (Color?), `allDayEventTextStyle` (TextStyle?), `allDayEventBorderColor` (Color?), `allDayEventBorderWidth` (double?)
   - Sizing (moved from `MCalDayThemeData`): `allDayTileWidth` (double?), `allDayTileHeight` (double?), `allDayEventPadding` (EdgeInsets?), `allDayOverflowIndicatorWidth` (double?)
   - **New** layout properties that replace hardcoded values in `all_day_events_section.dart`:
     - `allDayWrapSpacing` (double?) — replaces hardcoded `4.0`
     - `allDayWrapRunSpacing` (double?) — replaces hardcoded `4.0`
     - `allDaySectionPadding` (EdgeInsets?) — replaces hardcoded `EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0)`
     - `allDayKeyboardFocusBorderWidth` (double?) — replaces hardcoded `2`
     - `allDayOverflowHandleWidth` (double?) — replaces hardcoded `3`
     - `allDayOverflowHandleHeight` (double?) — replaces hardcoded `16`
     - `allDayOverflowHandleBorderRadius` (double?) — replaces hardcoded `1.5`
     - `allDayOverflowHandleGap` (double?) — replaces hardcoded `4`
     - `allDayOverflowIndicatorFontSize` (double?) — replaces hardcoded `11` (used in the `'+$count more'` overflow indicator, not the tile text)
2. The 4 `allDayEvent*` properties currently on `MCalThemeData` (parent) SHALL be **removed from `MCalThemeData`** and exist only via this mixin.
3. `MCalDayViewThemeData` SHALL mix in `MCalAllDayThemeMixin` and implement all abstract getters.

### Requirement 6: MCalDayViewThemeData Composition

**User Story:** As a developer, I want the Day View theme class to compose all three mixins plus its own view-specific properties, so that it provides a complete, flat API for Day View theming.

#### Acceptance Criteria

1. `MCalDayViewThemeData` SHALL mix in `MCalEventTileThemeMixin`, `MCalTimeGridThemeMixin`, and `MCalAllDayThemeMixin`.
2. `MCalDayViewThemeData` SHALL retain its own Day-View-specific properties not from any mixin:
   - Existing: `dayHeaderDayOfWeekStyle` (TextStyle?), `dayHeaderDateStyle` (TextStyle?)
   - **New** layout properties:
     - `dayHeaderPadding` (EdgeInsets?) — replaces hardcoded `EdgeInsets.all(8.0)` in `day_header.dart`
     - `dayHeaderWeekNumberPadding` (EdgeInsets?) — replaces hardcoded `EdgeInsets.symmetric(horizontal: 6, vertical: 2)` in `day_header.dart`
     - `dayHeaderWeekNumberBorderRadius` (double?) — replaces hardcoded `4` in `day_header.dart`
     - `dayHeaderSpacing` (double?) — replaces hardcoded `8` in `day_header.dart`
3. The `MCalDayViewThemeData.defaults(ThemeData)` factory SHALL populate all mixin properties and view-specific properties with Material 3–derived master defaults.
4. The constructor SHALL include all mixin properties plus view-specific properties as named optional parameters.
5. `copyWith`, `lerp`, `==`, and `hashCode` SHALL include all properties from all three mixins and the view-specific properties.

### Requirement 7: MCalMonthThemeData Composition

**User Story:** As a developer, I want `MCalMonthThemeData` to gain per-view event tile properties via the shared mixin, so that I can style Month View event tiles independently from Day View.

#### Acceptance Criteria

1. `MCalMonthThemeData` SHALL mix in `MCalEventTileThemeMixin`.
2. `MCalMonthThemeData` SHALL retain all its existing month-specific properties (cell styling, date labels, headers, multi-day tiles, drag & drop, overflow, regions, overlays).
3. The 5 `dropTargetTile*` properties and `resizeHandleColor` currently declared directly on `MCalMonthThemeData` SHALL be replaced by the mixin's abstract getters (same names, no duplication).
4. `MCalMonthThemeData` SHALL add the following **new** layout properties that replace hardcoded values in Month View widgets:
   - `dateLabelPadding` (EdgeInsets?) — replaces hardcoded `EdgeInsets.only(left: 4.0, top: 4.0, right: 4.0)` in `day_cell_widget.dart`
   - `cellBorderWidth` (double?) — replaces hardcoded `1.0` in `day_cell_widget.dart`
   - `regionContentPadding` (EdgeInsets?) — replaces hardcoded `EdgeInsets.only(bottom: 2.0)` in `day_cell_widget.dart`
   - `regionIconSize` (double?) — replaces hardcoded `9.0` in `day_cell_widget.dart`
   - `regionIconGap` (double?) — replaces hardcoded `2.0` in `day_cell_widget.dart`
   - `regionFontSize` (double?) — replaces hardcoded `8.0` in `day_cell_widget.dart`
   - `keyboardSelectionBorderWidth` (double?) — replaces hardcoded `2.0` (selected/move/resize state) in `week_row_widget.dart`
   - `keyboardHighlightBorderWidth` (double?) — replaces hardcoded `1.5` (highlighted/cycling state) in `week_row_widget.dart`
   - `dateLabelCircleSize` (double?) — replaces hardcoded `24.0` in `week_row_widget.dart`
   - `weekNumberColumnWidth` (double?) — replaces hardcoded `36.0` in `week_number_cell.dart`
   - `weekNumberBorderWidth` (double?) — replaces hardcoded `0.5` in `week_number_cell.dart`
   - `weekdayHeaderPadding` (EdgeInsets?) — replaces hardcoded `EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0)` in `weekday_header_row_widget.dart`
   - `multiDayTilePadding` (EdgeInsets?) — replaces hardcoded `EdgeInsets.symmetric(horizontal: 4, vertical: 2)` in `mcal_month_multi_day_tile.dart`
   - `multiDayTileBorderRadius` (double?) — replaces hardcoded `4.0` in `mcal_month_multi_day_tile.dart`
   - `weekLayoutDateLabelPadding` (double?) — replaces hardcoded `2.0` in week layout
   - `weekLayoutBaseMargin` (double?) — replaces hardcoded `2.0` in week layout
5. The `MCalMonthThemeData.defaults(ThemeData)` factory SHALL populate all mixin properties and month-specific properties (including new layout properties) with master defaults.
6. `eventTileBorderWidth` (double?) and `eventTileBorderColor` (Color?) SHALL come from `MCalEventTileThemeMixin` (see Req 3.6). Day View SHALL use these for timed event tile borders. All-day event tile borders are controlled by `allDayEventBorderWidth` and `allDayEventBorderColor` from `MCalAllDayThemeMixin` (Req 5).
7. `multiDayEventBackgroundColor` (Color?) SHALL come from `MCalEventTileThemeMixin` (see Req 3.5). It is no longer Month-specific because Day View also displays multi-day events in the all-day section and as timed tiles.
8. `weekLayoutDateLabelPadding` and `weekLayoutBaseMargin` SHALL be accessed by `MCalMonthDefaultWeekLayoutBuilder` through the `BuildContext` parameter it already receives, using `MCalTheme.of(context).monthTheme?.weekLayoutDateLabelPadding` (same pattern as all other widget theme access).

### Requirement 8: Slim MCalThemeData Parent

**User Story:** As a developer, I want `MCalThemeData` to contain only truly global properties, so that per-view properties are clearly scoped to their respective view themes.

#### Acceptance Criteria

1. `MCalThemeData` SHALL retain only the following properties:
   - `cellBackgroundColor` (Color?) — grid structure consistency across views
   - `cellBorderColor` (Color?) — grid structure consistency across views
   - `navigatorBackgroundColor` (Color?) — identical navigators on both views
   - `navigatorTextStyle` (TextStyle?) — identical navigators on both views
   - `enableEventColorOverrides` (bool, default: `false`) — global cascade policy (renamed from `ignoreEventColors`)
   - `dayViewTheme` (MCalDayViewThemeData?) — renamed from `dayTheme`
   - `monthTheme` (MCalMonthThemeData?) — unchanged
   - **New:** `navigatorPadding` (EdgeInsets?) — replaces hardcoded `EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)` in both navigators
2. The following 13 properties SHALL be **removed from `MCalThemeData`** (moved to mixins as specified in Requirements 3 and 5):
   - To `MCalEventTileThemeMixin`: `eventTileBackgroundColor`, `eventTileTextStyle`, `eventTileCornerRadius`, `eventTileHorizontalSpacing`, `hoverEventBackgroundColor`, `eventTileLightContrastColor`, `eventTileDarkContrastColor`, `weekNumberTextStyle`, `weekNumberBackgroundColor`
   - To `MCalAllDayThemeMixin`: `allDayEventBackgroundColor`, `allDayEventTextStyle`, `allDayEventBorderColor`, `allDayEventBorderWidth`
3. `MCalThemeData.fromTheme(ThemeData)` SHALL still produce a fully populated instance by populating the 8 parent properties and creating `dayViewTheme: MCalDayViewThemeData.defaults(theme)` and `monthTheme: MCalMonthThemeData.defaults(theme)`.

### Requirement 9: Zero Hardcoded Visual Values

**User Story:** As a developer, I want every visual layout value in widget code to come from a theme property, so that consumers can fully customize the calendar's appearance without forking the package.

#### Acceptance Criteria

1. AFTER this spec is implemented THEN no widget file in `lib/src/widgets/` SHALL contain hardcoded numeric literals for padding, margin, spacing, border width, border radius, icon size, or font size. **Exception**: behavioral thresholds (drag detection distances, spring physics, tablet breakpoints, debug overlay dimensions) SHALL remain hardcoded.
2. Each replaced hardcoded value SHALL have a corresponding theme property on the appropriate class or mixin with a master default that preserves the current visual appearance.
3. The master defaults factories (`MCalDayViewThemeData.defaults`, `MCalMonthThemeData.defaults`) SHALL provide values for all new layout properties derived from the current hardcoded values.
4. WHEN a consumer does not set any theme THEN the visual appearance SHALL be identical to the current hardcoded appearance (master defaults match current values).

### Requirement 10: Example App Control Panel Reorganization

**User Story:** As a developer using the example app, I want the theme control panel sections to mirror the new class/mixin structure, so that I can understand which properties belong to which theme class.

#### Acceptance Criteria

Each theme tab SHALL expose controls for **all** theme properties applicable to that view — every property from `MCalThemeData` (global), every property from each mixin the view's theme class mixes in, and every view-specific property. No applicable property SHALL be omitted.

1. `day_theme_tab.dart` SHALL organize its control panel sections as:
   - **Global (MCalThemeData)** — `enableEventColorOverrides` toggle, `cellBackgroundColor`, `cellBorderColor`, `navigatorBackgroundColor`, `navigatorPadding`
   - **Event Tiles (MCalEventTileThemeMixin)** — event tile colors, contrast colors, hover, drop target tile properties, resize handle, week number properties
   - **Time Grid (MCalTimeGridThemeMixin)** — time legend, gridlines, current time, time regions, timed events, focus/hover slots, drop target overlay, disabled slots
   - **All-Day Events (MCalAllDayThemeMixin)** — all-day event colors, tile sizing, section layout, overflow
   - **Day Header (MCalDayViewThemeData-specific)** — header padding, spacing, styles
2. `month_theme_tab.dart` SHALL organize its control panel sections as:
   - **Global (MCalThemeData)** — `enableEventColorOverrides` toggle, `cellBackgroundColor`, `cellBorderColor`, `navigatorBackgroundColor`, `navigatorPadding`
   - **Event Tiles (MCalEventTileThemeMixin)** — event tile colors, contrast colors, hover, drop target tile properties, resize handle, week number properties
   - **Month View (MCalMonthThemeData-specific)** — cell styling, date labels, headers, multi-day tiles, drag & drop, overflow
3. WHEN `enableEventColorOverrides` is `false` (default) THEN the following color controls SHALL be visually disabled (greyed out / non-interactive):
   - `eventTileBackgroundColor` (both tabs)
   - `allDayEventBackgroundColor` (Day Theme Tab only)
   - `multiDayEventBackgroundColor` (both tabs — from `MCalEventTileThemeMixin`)
4. WHEN `enableEventColorOverrides` is toggled to `true` THEN those controls SHALL become active.

### Requirement 11: Future View Architecture Conventions

**User Story:** As a developer adding future views, I want documented conventions for how new view theme classes should compose mixins, so that the architecture remains consistent.

#### Acceptance Criteria

1. The design document SHALL document how future view theme classes compose mixins:
   - `MCalMultiDayViewThemeData` — mixes in `MCalEventTileThemeMixin`, `MCalTimeGridThemeMixin`, `MCalAllDayThemeMixin`
   - `MCalPivotedMultiDayViewThemeData` — mixes in `MCalEventTileThemeMixin`, `MCalTimeGridThemeMixin`
2. Future view theme classes SHALL be self-contained: each view's properties are resolved from its own theme, not falling back to another view's theme.
3. Master defaults ensure cross-view consistency when consumers do not explicitly configure per-view properties.

## Non-Functional Requirements

### Zero Property Duplication

- No property SHALL appear as a direct field declaration on more than one class. If two views need the same property, it SHALL be defined in a shared mixin (once) and mixed into both view theme classes.

### Zero Hardcoded Visual Values

- Every padding, margin, spacing, border width/radius, icon size, and font size in `lib/src/widgets/` SHALL come from a theme property with a master default.
- Behavioral thresholds (drag detection distances like `_resizeDragThreshold`, `_edgeProximityThreshold`; spring physics constants; tablet breakpoints; debug overlay dimensions) SHALL remain hardcoded.
- `Colors.transparent` is permitted as a "no fill" sentinel.

### Consumer API Clarity

- Consumers SHALL interact with at most 2 sub-themes (`dayViewTheme`, `monthTheme`). No additional top-level sub-theme properties on `MCalThemeData`.
- Mixins are internal organization. The consumer sees a single flat constructor per view theme class.

### Master Defaults Preservation

- The master defaults pattern from `theme-cascade-refactor` SHALL be preserved. `MCalThemeData.fromTheme(ThemeData)` remains the canonical master defaults factory.
- All new layout properties SHALL have master defaults that match the current hardcoded values, ensuring zero visual change for consumers who do not set a theme.

### Cascade Logic Preservation

- The cascade utility functions (`resolveEventTileColor`, `resolveDropTargetTileColor`, `resolveContrastColor`) SHALL continue to work. Their parameter names SHALL be updated for `enableEventColorOverrides`.
- The cascade order SHALL be unchanged (only the property source locations change from parent to per-view theme).

### Code Architecture

- New mixin files SHALL follow the naming convention `mcal_*_theme_mixin.dart` in `lib/src/styles/`.
- Mixin files SHALL be under 500 lines each (per structure.md guidelines).
- All new files SHALL be exported from `lib/multi_calendar.dart`.

### Performance

- No performance impact. Property resolution is the same number of null checks; only the source object changes.

### Reliability

- All existing tests SHALL pass after updates (with necessary changes to property access paths and class names).
- New layout properties SHALL have unit tests verifying their master defaults match current hardcoded values.
