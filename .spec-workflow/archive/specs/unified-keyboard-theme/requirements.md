# Requirements Document: Unified Keyboard Theme and All-Day Mixin Split

## Introduction

This specification retroactively documents changes to the Multi Calendar theming and keyboard navigation systems made after the **Theme Layout Future Views** spec (commit `1e1f9b9`) was completed. The work addresses four concerns:

1. The original `MCalAllDayThemeMixin` combined tile appearance properties (needed by both Day and Month Views) with section layout properties (needed only by Day View). Month View could not independently theme all-day event tiles via `isAllDay` branching without also inheriting irrelevant section layout properties.

2. Keyboard focus styling properties were scattered across three different theme classes (`MCalTimeGridThemeMixin`, `MCalAllDaySectionThemeMixin`, and `MCalMonthViewThemeData`), each with slightly different property names and no shared contract. Day View lacked the highlight/selected state distinction that Month View already had.

3. Two keyboard resize bugs in Day View caused incorrect behavior: a stale focused event reference after keyboard move, and proposed time reversion when switching between start/end resize edges.

4. The contrast color utility produced incorrect results for semi-transparent tile backgrounds.

5. The `multiDayEventBackgroundColor` property on `MCalEventTileThemeMixin` became redundant once `isAllDay` branching was introduced — multi-day all-day events now use `allDayEventBackgroundColor` through the same branching logic as other all-day events.

## Alignment with Product Vision

- **Customization First** (product.md §79.4): Unifying keyboard theme properties into `MCalEventTileThemeMixin` gives consumers a single, consistent API for keyboard styling across all views and event types. The all-day tile mixin split enables independent theming of all-day vs timed events in Month View.
- **Separation of Concerns** (product.md §79.1): Splitting the all-day mixin into tile appearance (shared) and section layout (view-specific) respects the principle that each mixin covers one concern.
- **Modularity Over Monolith** (product.md §79.2): Month View now mixes in only `MCalAllDayTileThemeMixin` (5 properties) instead of the full `MCalAllDayThemeMixin` (19 properties), composing exactly the properties it needs.
- **Accessibility First** (product.md §79.7): Distinguishing highlighted (browsing) from selected (manipulating) keyboard states in Day View improves the accessibility experience — users get clearer visual and semantic feedback about what state they are in.
- **Developer-Friendly** (product.md §79.6): Consumers use the same 6 property names (`keyboardSelection*`, `keyboardHighlight*`) regardless of which view or event type they are styling.

## Requirements

### Requirement 1: Split MCalAllDayThemeMixin into Tile and Section Mixins

**User Story:** As a developer, I want all-day event tile appearance properties separated from section layout properties, so that Month View can theme all-day tile appearance independently without inheriting Day View section layout properties.

#### Acceptance Criteria

1. The system SHALL define a mixin `MCalAllDayTileThemeMixin` in a new file `mcal_all_day_tile_theme_mixin.dart` containing abstract getters for all-day event tile appearance:
   - `allDayEventBackgroundColor` (Color?)
   - `allDayEventTextStyle` (TextStyle?)
   - `allDayEventBorderColor` (Color?)
   - `allDayEventBorderWidth` (double?)
   - `allDayEventPadding` (EdgeInsets?)
2. The existing `MCalAllDayThemeMixin` SHALL be renamed to `MCalAllDaySectionThemeMixin` (file: `mcal_all_day_section_theme_mixin.dart`) and SHALL retain only section layout properties (tile sizing, wrap spacing, overflow handles — 13 properties). The 5 tile appearance properties and `allDayKeyboardFocusBorderWidth` SHALL be removed from this mixin.
3. `MCalDayViewThemeData` SHALL mix in both `MCalAllDayTileThemeMixin` and `MCalAllDaySectionThemeMixin`.
4. `MCalMonthViewThemeData` SHALL mix in `MCalAllDayTileThemeMixin` (not `MCalAllDaySectionThemeMixin`).
5. Both `MCalDayViewThemeData` and `MCalMonthViewThemeData` SHALL implement all `MCalAllDayTileThemeMixin` abstract getters as `@override final` fields with corresponding entries in constructor, `defaults()`, `copyWith`, `lerp`, `==`, and `hashCode`.
6. `lib/multi_calendar.dart` SHALL export both new/renamed mixin files.

### Requirement 2: Unified Keyboard Theme Properties on MCalEventTileThemeMixin

**User Story:** As a developer, I want a single, consistent set of keyboard styling properties available on every view's theme, so that I can control keyboard focus appearance without knowing which view-specific class or mixin originally held each property.

#### Acceptance Criteria

1. `MCalEventTileThemeMixin` SHALL define 6 new abstract getters for unified keyboard focus styling:
   - `keyboardSelectionBorderWidth` (double?) — border width for the **selected** state (move/resize confirmed)
   - `keyboardSelectionBorderColor` (Color?) — border color for the selected state
   - `keyboardSelectionBorderRadius` (double?) — corner radius for the selected state
   - `keyboardHighlightBorderWidth` (double?) — border width for the **highlighted** state (Tab/Shift+Tab cycle)
   - `keyboardHighlightBorderColor` (Color?) — border color for the highlighted state
   - `keyboardHighlightBorderRadius` (double?) — corner radius for the highlighted state
2. `MCalDayViewThemeData` and `MCalMonthViewThemeData` SHALL implement all 6 getters as `@override final` fields with corresponding entries in constructor, `defaults()`, `copyWith`, `lerp`, `==`, and `hashCode`.
3. Master defaults SHALL be: `keyboardSelectionBorderWidth: 2.0`, `keyboardSelectionBorderColor: colorScheme.primary`, `keyboardSelectionBorderRadius: 4.0`, `keyboardHighlightBorderWidth: 1.5`, `keyboardHighlightBorderColor: colorScheme.outline`, `keyboardHighlightBorderRadius: 4.0`. The highlight color uses `outline` (rather than `primary`) to provide a subtler visual distinction from the selection state.
4. The following old keyboard properties SHALL be removed:
   - From `MCalTimeGridThemeMixin`: `timedEventKeyboardFocusBorderWidth`, `keyboardFocusBorderColor`, `keyboardFocusBorderRadius`
   - From `MCalAllDaySectionThemeMixin`: `allDayKeyboardFocusBorderWidth`
   - From `MCalMonthViewThemeData` (view-specific): `keyboardSelectionBorderWidth`, `keyboardHighlightBorderWidth`
5. ALL widget rendering code that draws keyboard focus rings SHALL read from the unified mixin properties (`keyboardSelection*` or `keyboardHighlight*`) via the appropriate view theme.

### Requirement 3: Day View Keyboard Highlight vs Selected State Distinction

**User Story:** As a user navigating Day View with the keyboard, I want a visual distinction between browsing events (Tab cycling) and actively manipulating an event (move/resize), so that I understand my current interaction state.

#### Acceptance Criteria

1. WHEN the user is in Event Mode (Tab/Shift+Tab cycling through events) THEN the focused event tile SHALL render with `keyboardHighlight*` theme properties (thinner, browse-state ring).
2. WHEN the user enters Move Mode (M key) or Resize Mode (R key) THEN the event being moved/resized SHALL render with `keyboardSelection*` theme properties (thicker, action-state ring).
3. WHEN the user is in Move Mode THEN only the event being moved SHALL show the selection ring; no highlight ring SHALL be visible.
4. WHEN the user is in Resize Mode THEN only the event being resized SHALL show the selection ring; no highlight ring SHALL be visible.
5. Both `all_day_events_section.dart` and `time_grid_events_layer.dart` SHALL accept `keyboardHighlightedEventId` and `keyboardSelectedEventId` parameters and render the appropriate ring style based on which ID matches the event.

### Requirement 4: Month View isAllDay Branching for All-Day Tile Theme

**User Story:** As a developer, I want Month View to automatically use `allDayEvent*` theme properties for all-day events and `eventTile*` properties for timed events, so that all-day events can be styled distinctly without custom builders.

#### Acceptance Criteria

1. WHEN rendering a Month View event tile WHERE `event.isAllDay` is `true` THEN the background color resolution SHALL prefer `allDayEventBackgroundColor` over `eventTileBackgroundColor`.
2. WHEN rendering a Month View event tile WHERE `event.isAllDay` is `true` THEN the text style SHALL prefer `allDayEventTextStyle` over `eventTileTextStyle`.
3. WHEN rendering a Month View event tile WHERE `event.isAllDay` is `true` THEN the border SHALL use `allDayEventBorderColor`/`allDayEventBorderWidth` over `eventTileBorderColor`/`eventTileBorderWidth`.
4. WHEN rendering a Month View event tile WHERE `event.isAllDay` is `true` THEN the padding SHALL use `allDayEventPadding` over `eventTilePadding`.
5. WHEN rendering a Month View event tile WHERE `event.isAllDay` is `false` THEN the standard `eventTile*` properties SHALL be used.
6. This branching SHALL apply in both `mcal_month_multi_day_tile.dart` (multi-day bar segments) and `week_row_widget.dart` (single-day tiles within week rows).

### Requirement 5: Bug Fix — Stale Focused Event After Keyboard Move

**User Story:** As a user who moves an event with the keyboard and then enters resize mode, I want the resize operation to act on the event at its new location, so that I don't see a ghost overlay at the old position.

#### Acceptance Criteria

1. WHEN the user completes a keyboard move (Enter key confirms drop) AND subsequently enters keyboard resize mode (R key) THEN the resize SHALL operate on the event's post-move `start`/`end` times.
2. The system SHALL refresh `_focusedEvent` with the latest instance from the event controller after the move drop is processed.
3. The system SHALL also refresh `_focusedEvent` before entering keyboard move mode and before entering keyboard resize mode, to guard against any stale reference.
4. IF `_focusedEvent` cannot be found in the controller's current event lists THEN the refresh SHALL be a no-op (existing null guards handle this gracefully).

### Requirement 6: Bug Fix — Keyboard Resize Proposed Times Persist When Switching Edges

**User Story:** As a user resizing an event's end time with the keyboard and then pressing 'S' to switch to the start edge, I want my end time adjustment to persist, so that switching edges does not discard my work.

#### Acceptance Criteria

1. WHEN the user is in keyboard resize mode for a timed event in Day View AND has adjusted the end time AND presses 'S' to switch to the start edge THEN the adjusted end time SHALL be preserved.
2. WHEN the user is in keyboard resize mode for a timed event in Day View AND has adjusted the start time AND presses 'E' to switch to the end edge THEN the adjusted start time SHALL be preserved.
3. WHEN switching edges THEN `_keyboardResizeEdgeOffset` SHALL be re-based to the offset corresponding to the active edge's current proposed time.
4. The system SHALL maintain `_keyboardResizeProposedStart` and `_keyboardResizeProposedEnd` state fields that cache the full proposed range throughout a keyboard resize session.

### Requirement 7: Improved Contrast Color Resolution for Semi-Transparent Backgrounds

**User Story:** As a developer using semi-transparent event tile colors, I want the auto-contrast text color to account for the background's transparency, so that text remains readable when the effective visual color differs from the raw color value.

#### Acceptance Criteria

1. `resolveContrastColor` SHALL alpha-composite the `backgroundColor` against white before calculating luminance.
2. WHEN `backgroundColor` has `alpha < 1.0` THEN the effective RGB values SHALL be computed as `color.channel * alpha + (1.0 - alpha)` for each channel.
3. The luminance SHALL use the standard perceptual weighting: `0.299 * R + 0.587 * G + 0.114 * B`.
4. WHEN luminance > 0.5 THEN `darkContrastColor` SHALL be returned. OTHERWISE `lightContrastColor` SHALL be returned.

### Requirement 8: Example App Keyboard Theme Controls

**User Story:** As a developer using the example app, I want a dedicated "Keyboard" section on both the Day Theme Tab and Month Theme Tab exposing all 6 unified keyboard properties, so that I can preview and test keyboard styling.

#### Acceptance Criteria

1. `day_theme_tab.dart` SHALL include a "Keyboard" section as the **last** section in the control panel, containing controls for all 6 unified keyboard properties.
2. `month_theme_tab.dart` SHALL include a "Keyboard" section as the **last** section in the control panel, containing controls for all 6 unified keyboard properties.
3. The old `keyboardFocusBorderRadius` control SHALL be removed from the Day Theme Tab's "All Events" section.
4. Localization SHALL provide keys for the section header (`sectionKeyboard`) and all 6 property labels (`settingKeyboardSelectionBorderWidth`, `settingKeyboardSelectionBorderColor`, `settingKeyboardSelectionBorderRadius`, `settingKeyboardHighlightBorderWidth`, `settingKeyboardHighlightBorderColor`, `settingKeyboardHighlightBorderRadius`) across all 5 supported locales.
5. Theme presets SHALL be updated: `keyboardFocusBorderRadius` replaced with `keyboardSelectionBorderRadius` and `keyboardHighlightBorderRadius`.

### Requirement 9: Remove multiDayEventBackgroundColor from MCalEventTileThemeMixin

**User Story:** As a developer, I want multi-day events to use the same `allDayEventBackgroundColor` as other all-day events when `event.isAllDay` is true, rather than a separate `multiDayEventBackgroundColor` property, so that the theming API is simpler and the `isAllDay` branching (Req 4) handles multi-day events consistently.

#### Acceptance Criteria

1. `multiDayEventBackgroundColor` SHALL be removed from `MCalEventTileThemeMixin`.
2. `multiDayEventBackgroundColor` SHALL be removed from `MCalDayViewThemeData` and `MCalMonthViewThemeData` (field, constructor, `defaults()`, `copyWith`, `lerp`, `==`, `hashCode`).
3. WHEN rendering a multi-day event tile WHERE `event.isAllDay` is `true` THEN the `isAllDay` branching (Req 4) SHALL apply, selecting `allDayEventBackgroundColor` from `MCalAllDayTileThemeMixin`.
4. WHEN rendering a multi-day event tile WHERE `event.isAllDay` is `false` (a timed multi-day event) THEN `eventTileBackgroundColor` from `MCalEventTileThemeMixin` SHALL be used.

## Non-Functional Requirements

### Zero Property Duplication

- No keyboard-related property SHALL appear as a direct field declaration on more than one mixin or class. If two views need the same keyboard property, it SHALL be defined once in `MCalEventTileThemeMixin`.
- All-day tile appearance properties SHALL be defined once in `MCalAllDayTileThemeMixin` and mixed into both view theme classes.

### Master Defaults Preservation

- The master defaults pattern from `theme-cascade-refactor` SHALL be preserved. `MCalThemeData.fromTheme(ThemeData)` remains the canonical master defaults factory.
- All new keyboard properties SHALL have master defaults that produce the same visual appearance as the old scattered properties they replace.
- WHEN a consumer does not set any theme THEN the keyboard focus appearance SHALL be identical to the prior implementation (selection ring = 2.0px primary, highlight ring = 1.5px outline, both with 4.0px corner radius).

### Backward Compatibility (Mixin Rename)

- The rename from `MCalAllDayThemeMixin` to `MCalAllDaySectionThemeMixin` plus the creation of `MCalAllDayTileThemeMixin` is a breaking change for consumers who imported the old mixin directly. This is acceptable because:
  - The mixins are primarily internal organization (consumers interact with the flat view theme constructors).
  - The rename produces a clear compile error guiding the migration.

### Performance

- No performance impact. The keyboard state getters are O(1) computed properties. The `_syncFocusedEventFromController` method is O(n) over the event list but runs only on discrete keyboard mode transitions, not per-frame.

### Reliability

- All existing tests SHALL pass after updates.
- New regression tests SHALL cover the two keyboard resize bug fixes.
- New unit tests SHALL verify the 6 keyboard property defaults on both `MCalDayViewThemeData` and `MCalMonthViewThemeData`.

### Code Architecture

- New mixin files SHALL follow the naming convention `mcal_*_theme_mixin.dart` in `lib/src/styles/`.
- All new/renamed files SHALL be exported from `lib/multi_calendar.dart`.
