# Tasks Document: Unified Keyboard Theme and All-Day Mixin Split

> **Implementation status** — All tasks in this document are complete, including Phase 8 test coverage (tasks 21–22).

## Phase 1: All-Day Mixin Split

- [x] 1. Split MCalAllDayThemeMixin into tile and section mixins
  - Files: `lib/src/styles/mcal_all_day_tile_theme_mixin.dart` (new), `lib/src/styles/mcal_all_day_section_theme_mixin.dart` (renamed from `mcal_all_day_theme_mixin.dart`)
  - Create `MCalAllDayTileThemeMixin` with 5 abstract getters: `allDayEventBackgroundColor` (Color?), `allDayEventTextStyle` (TextStyle?), `allDayEventBorderColor` (Color?), `allDayEventBorderWidth` (double?), `allDayEventPadding` (EdgeInsets?).
  - Rename `MCalAllDayThemeMixin` → `MCalAllDaySectionThemeMixin`. Remove 5 tile appearance properties and `allDayKeyboardFocusBorderWidth` (6 total), leaving 13 section layout properties.
  - _Leverage: Existing `mcal_all_day_theme_mixin.dart` structure._
  - _Requirements: 1.1, 1.2_
  - _Prompt: Role: Dart mixin developer. Task: (1) Create `mcal_all_day_tile_theme_mixin.dart` with mixin `MCalAllDayTileThemeMixin` containing 5 abstract nullable getters for all-day tile appearance. Add dartdoc. (2) Rename `mcal_all_day_theme_mixin.dart` → `mcal_all_day_section_theme_mixin.dart`, rename mixin to `MCalAllDaySectionThemeMixin`, remove allDayEventBackgroundColor/TextStyle/BorderColor/BorderWidth/Padding and allDayKeyboardFocusBorderWidth. Restrictions: Only abstract getters in mixins. Success: Both files compile; analyzer passes._

- [x] 2. Update MCalDayViewThemeData mixin composition
  - File: `lib/src/styles/mcal_day_view_theme_data.dart`
  - Replace `MCalAllDayThemeMixin` with `MCalAllDayTileThemeMixin` + `MCalAllDaySectionThemeMixin` in the `with` clause.
  - Add `@override final` fields for the 5 `MCalAllDayTileThemeMixin` properties.
  - Remove `allDayKeyboardFocusBorderWidth` field (moved to unified keyboard properties in Phase 2).
  - Update constructor, `defaults()`, `copyWith`, `lerp`, `==`, `hashCode`.
  - `defaults()` key value: `allDayEventBackgroundColor: colorScheme.secondaryContainer`.
  - _Leverage: Existing MCalDayViewThemeData patterns._
  - _Requirements: 1.3, 1.5_
  - _Prompt: Role: Flutter theme developer. Task: Update MCalDayViewThemeData: replace MCalAllDayThemeMixin with MCalAllDayTileThemeMixin + MCalAllDaySectionThemeMixin. Add @override final fields for 5 tile mixin properties. Remove allDayKeyboardFocusBorderWidth. Update defaults (allDayEventBackgroundColor: colorScheme.secondaryContainer), constructor, copyWith, lerp, ==, hashCode. Restrictions: Follow existing patterns. Success: Compiles; analyzer clean._

- [x] 3. Add MCalAllDayTileThemeMixin to MCalMonthViewThemeData
  - File: `lib/src/styles/mcal_month_view_theme_data.dart`
  - Add `MCalAllDayTileThemeMixin` to the `with` clause.
  - Add `@override final` fields for the 5 tile appearance properties.
  - Update constructor, `defaults()`, `copyWith`, `lerp`, `==`, `hashCode`.
  - `defaults()` key value: `allDayEventBackgroundColor: colorScheme.secondaryContainer`.
  - _Leverage: Existing MCalMonthViewThemeData patterns._
  - _Requirements: 1.4, 1.5_
  - _Prompt: Role: Flutter theme developer. Task: Add MCalAllDayTileThemeMixin to MCalMonthViewThemeData. Add @override final fields for allDayEventBackgroundColor, allDayEventTextStyle, allDayEventBorderColor, allDayEventBorderWidth, allDayEventPadding. Update defaults (allDayEventBackgroundColor: colorScheme.secondaryContainer), constructor, copyWith, lerp, ==, hashCode. Restrictions: Follow existing patterns. Success: Compiles; analyzer clean._

- [x] 4. Update exports
  - File: `lib/multi_calendar.dart`
  - Add export for `mcal_all_day_tile_theme_mixin.dart`.
  - Update export from `mcal_all_day_theme_mixin.dart` → `mcal_all_day_section_theme_mixin.dart`.
  - _Leverage: Existing export patterns._
  - _Requirements: 1.6_
  - _Prompt: Role: Dart developer. Task: In lib/multi_calendar.dart, add export for mcal_all_day_tile_theme_mixin.dart. Rename mcal_all_day_theme_mixin.dart export to mcal_all_day_section_theme_mixin.dart. Success: Exports correct._

## Phase 2: Unified Keyboard Theme Properties

- [x] 5. Add 6 keyboard properties to MCalEventTileThemeMixin
  - File: `lib/src/styles/mcal_event_tile_theme_mixin.dart`
  - Add abstract getters: `keyboardSelectionBorderWidth` (double?), `keyboardSelectionBorderColor` (Color?), `keyboardSelectionBorderRadius` (double?), `keyboardHighlightBorderWidth` (double?), `keyboardHighlightBorderColor` (Color?), `keyboardHighlightBorderRadius` (double?).
  - Add dartdoc distinguishing selection (move/resize confirmed) from highlight (Tab cycle).
  - _Leverage: Existing MCalEventTileThemeMixin structure._
  - _Requirements: 2.1_
  - _Prompt: Role: Dart mixin developer. Task: Add 6 abstract nullable getters to MCalEventTileThemeMixin for unified keyboard focus styling: keyboardSelectionBorderWidth, keyboardSelectionBorderColor, keyboardSelectionBorderRadius, keyboardHighlightBorderWidth, keyboardHighlightBorderColor, keyboardHighlightBorderRadius. Add dartdoc explaining selection vs highlight states. Success: Mixin compiles._

- [x] 6. Remove multiDayEventBackgroundColor from MCalEventTileThemeMixin
  - File: `lib/src/styles/mcal_event_tile_theme_mixin.dart`
  - Remove `multiDayEventBackgroundColor` abstract getter.
  - _Leverage: isAllDay branching (Task 11) replaces this property._
  - _Requirements: 9.1_
  - _Prompt: Role: Dart developer. Task: Remove multiDayEventBackgroundColor from MCalEventTileThemeMixin. Success: Mixin compiles without the property._

- [x] 7. Remove old keyboard properties from MCalTimeGridThemeMixin
  - File: `lib/src/styles/mcal_time_grid_theme_mixin.dart`
  - Remove: `timedEventKeyboardFocusBorderWidth`, `keyboardFocusBorderColor`, `keyboardFocusBorderRadius`.
  - _Leverage: Replaced by unified properties on MCalEventTileThemeMixin._
  - _Requirements: 2.4_
  - _Prompt: Role: Dart developer. Task: Remove 3 abstract getters from MCalTimeGridThemeMixin: timedEventKeyboardFocusBorderWidth, keyboardFocusBorderColor, keyboardFocusBorderRadius. Success: Mixin compiles._

- [x] 8. Implement 6 keyboard properties on MCalDayViewThemeData
  - File: `lib/src/styles/mcal_day_view_theme_data.dart`
  - Add `@override final` fields for all 6 keyboard properties.
  - Remove old keyboard fields: `timedEventKeyboardFocusBorderWidth`, `keyboardFocusBorderColor`, `keyboardFocusBorderRadius` (from TimeGridThemeMixin removal).
  - Remove `multiDayEventBackgroundColor` field.
  - Update constructor, `defaults()`, `copyWith`, `lerp`, `==`, `hashCode`.
  - `defaults()`: `keyboardSelectionBorderWidth: 2.0`, `keyboardSelectionBorderColor: colorScheme.primary`, `keyboardSelectionBorderRadius: 4.0`, `keyboardHighlightBorderWidth: 1.5`, `keyboardHighlightBorderColor: colorScheme.outline`, `keyboardHighlightBorderRadius: 4.0`.
  - _Leverage: Existing MCalDayViewThemeData patterns._
  - _Requirements: 2.2, 2.3, 9.2_
  - _Prompt: Role: Flutter theme developer. Task: Add @override final fields for 6 keyboard properties on MCalDayViewThemeData. Remove old keyboard fields (timedEventKeyboardFocusBorderWidth, keyboardFocusBorderColor, keyboardFocusBorderRadius) and multiDayEventBackgroundColor. Update defaults with specified values. Update constructor, copyWith, lerp, ==, hashCode. Restrictions: Follow existing patterns. Success: Compiles; analyzer clean._

- [x] 9. Implement 6 keyboard properties on MCalMonthViewThemeData
  - File: `lib/src/styles/mcal_month_view_theme_data.dart`
  - Add `@override final` fields for all 6 keyboard properties.
  - Remove old month-specific keyboard fields: `keyboardSelectionBorderWidth`, `keyboardHighlightBorderWidth`.
  - Remove `multiDayEventBackgroundColor` field.
  - Update constructor, `defaults()`, `copyWith`, `lerp`, `==`, `hashCode`.
  - Same defaults as Day View.
  - _Leverage: Existing MCalMonthViewThemeData patterns._
  - _Requirements: 2.2, 2.3, 9.2_
  - _Prompt: Role: Flutter theme developer. Task: Add @override final fields for 6 keyboard properties on MCalMonthViewThemeData. Remove old keyboardSelectionBorderWidth, keyboardHighlightBorderWidth, and multiDayEventBackgroundColor. Update defaults, constructor, copyWith, lerp, ==, hashCode. Same keyboard defaults as Day View. Restrictions: Follow existing patterns. Success: Compiles; analyzer clean._

## Phase 3: Day View Keyboard State Distinction

- [x] 10. Add highlight/selected getters and pass to sub-widgets
  - File: `lib/src/widgets/mcal_day_view.dart`
  - Add `_keyboardHighlightedEventIdForDayView` getter: returns focused event ID when in Event Mode (Tab cycling), null otherwise.
  - Add `_keyboardSelectedEventIdForDayView` getter: returns event ID when in Move or Resize Mode, null otherwise.
  - Pass both IDs to `all_day_events_section.dart` and `time_grid_events_layer.dart` widget constructors.
  - _Leverage: Existing `_isKeyboardEventMode`, `_isKeyboardMoveMode`, `_isKeyboardResizeMode` flags._
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_
  - _Prompt: Role: Flutter widget developer. Task: Add two computed getters to MCalDayView state: _keyboardHighlightedEventIdForDayView (returns focused event ID during Event Mode only) and _keyboardSelectedEventIdForDayView (returns event ID during Move/Resize Mode). Pass both as named parameters to AllDayEventsSection and TimeGridEventsLayer. Restrictions: No highlight and selection should be active simultaneously. Success: Getters return correct IDs for each keyboard state._

- [x] 11. Update Day View sub-widgets to render highlight vs selected rings
  - Files: `lib/src/widgets/day_subwidgets/all_day_events_section.dart`, `lib/src/widgets/day_subwidgets/time_grid_events_layer.dart`
  - Accept `keyboardHighlightedEventId` and `keyboardSelectedEventId` parameters.
  - Render keyboard rings using unified theme properties: `keyboardSelection*` for selected state, `keyboardHighlight*` for highlighted state.
  - Remove old keyboard focus rendering that used `timedEventKeyboardFocusBorderWidth`, `keyboardFocusBorderColor`, `keyboardFocusBorderRadius`, `allDayKeyboardFocusBorderWidth`.
  - _Leverage: Existing keyboard ring rendering code; unified theme properties from Tasks 8–9._
  - _Requirements: 2.5, 3.5_
  - _Prompt: Role: Flutter widget developer. Task: Update all_day_events_section.dart and time_grid_events_layer.dart to accept keyboardHighlightedEventId and keyboardSelectedEventId. For each event tile, check both IDs. If selected: wrap with Container using keyboardSelectionBorderWidth/Color/Radius. If highlighted: wrap with Container using keyboardHighlightBorderWidth/Color/Radius. Remove old keyboard focus rendering. Restrictions: No double rings. Success: Tiles show correct ring style per state._

## Phase 4: Month View isAllDay Branching

- [x] 12. Update Month View multi-day tile rendering for isAllDay branching
  - File: `lib/src/widgets/mcal_month_multi_day_tile.dart`
  - Branch on `event.isAllDay` for background color, text style, border, and padding resolution.
  - When `isAllDay` is true: prefer `allDayEventBackgroundColor`/`allDayEventTextStyle`/`allDayEventBorderColor`/`allDayEventBorderWidth`/`allDayEventPadding` from `MCalAllDayTileThemeMixin`, falling back to `eventTile*` properties.
  - When `isAllDay` is false: use `eventTile*` properties from `MCalEventTileThemeMixin`.
  - _Leverage: Existing cascade utility functions; MCalAllDayTileThemeMixin properties from Task 3._
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 9.3_
  - _Prompt: Role: Flutter widget developer. Task: In mcal_month_multi_day_tile.dart, branch rendering on event.isAllDay. For all-day events: resolve background via allDayEventBackgroundColor (falling back to eventTileBackgroundColor), text via allDayEventTextStyle, border via allDayEventBorderColor/Width, padding via allDayEventPadding. For timed events: use eventTile* properties. Add segment-aware border rendering. Restrictions: Maintain existing cascade order. Success: All-day events styled differently from timed events._

- [x] 13. Update Month View week row widget rendering for isAllDay branching
  - File: `lib/src/widgets/month_subwidgets/week_row_widget.dart`
  - Same `isAllDay` branching as Task 12 for single-day tiles within week rows.
  - Add contrast color resolution for text on all-day tiles.
  - _Leverage: Same pattern as Task 12._
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 9.3_
  - _Prompt: Role: Flutter widget developer. Task: In week_row_widget.dart, apply same isAllDay branching as mcal_month_multi_day_tile.dart for single-day event tiles. Branch background, text style, border, and padding resolution on event.isAllDay. Add contrast color resolution for all-day tiles. Restrictions: Maintain cascade order. Success: Single-day all-day tiles styled consistently with multi-day all-day tiles._

## Phase 5: Bug Fixes

- [x] 14. Fix stale focused event after keyboard move (Day View)
  - File: `lib/src/widgets/mcal_day_view.dart`
  - Add `_syncFocusedEventFromController()` method: scans `_allDayEvents` and `_timedEvents` for an event matching `_focusedEvent.id` and replaces the stale reference.
  - Call at: start of `_enterKeyboardMoveMode()`, start of `_enterKeyboardResizeMode()`, after `_handleDrop()` and `_completePendingDrop()` when the dropped event ID matches `_focusedEvent`.
  - _Leverage: Existing `_allDayEvents` and `_timedEvents` lists from the controller._
  - _Requirements: 5.1, 5.2, 5.3, 5.4_
  - _Prompt: Role: Flutter widget developer. Task: Add _syncFocusedEventFromController() to MCalDayView state. It scans _allDayEvents then _timedEvents for an event with the same ID as _focusedEvent and replaces the reference. Call at: start of _enterKeyboardMoveMode, start of _enterKeyboardResizeMode, after _handleDrop if focused ID matches, after _completePendingDrop if focused ID matches. Restrictions: No-op if _focusedEvent is null or not found. Success: After keyboard move, resize mode uses post-move event times._

- [x] 15. Fix keyboard resize S/E edge switching (Day View)
  - File: `lib/src/widgets/mcal_day_view.dart`
  - Add `_keyboardResizeProposedStart` and `_keyboardResizeProposedEnd` nullable DateTime fields.
  - Initialize to `event.start`/`event.end` in `_enterKeyboardResizeMode` (for timed events).
  - In `_updateKeyboardResizePreview`: use cached fields for the inactive edge instead of `event.start`/`event.end`; save post-clamping values back to cached fields after `updateResize`.
  - In 'S'/'E' key handlers: snapshot current proposed dates from drag handler into cached fields; re-base `_keyboardResizeEdgeOffset` to the active edge's offset.
  - _Leverage: Existing `_updateKeyboardResizePreview`, `_keyboardResizeEdgeOffset`, `MCalDragHandler` API._
  - _Requirements: 6.1, 6.2, 6.3, 6.4_
  - _Prompt: Role: Flutter widget developer. Task: Add _keyboardResizeProposedStart/_keyboardResizeProposedEnd fields. Initialize in _enterKeyboardResizeMode for timed events. In _updateKeyboardResizePreview: read inactive edge from cached fields (?? event.start/end); save post-clamping values back. In S/E key handlers: snapshot dragHandler.proposedStartDate/proposedEndDate into cached fields; re-base _keyboardResizeEdgeOffset to timeToOffset of active edge's proposed time. Restrictions: Fallback to event.start/end via ?? for safety. Success: Proposed times persist when switching between S and E._

## Phase 6: Contrast Color Improvement

- [x] 16. Alpha-composite in resolveContrastColor
  - File: `lib/src/utils/theme_cascade_utils.dart`
  - Modify `resolveContrastColor`: before luminance calculation, alpha-composite `backgroundColor` against white.
  - Effective RGB: `channel * alpha + (1.0 - alpha)` for each channel.
  - Luminance formula unchanged: `0.299 * R + 0.587 * G + 0.114 * B`.
  - _Leverage: Existing resolveContrastColor function._
  - _Requirements: 7.1, 7.2, 7.3, 7.4_
  - _Prompt: Role: Dart developer. Task: In resolveContrastColor, compute effective RGB by alpha-compositing backgroundColor against white: effectiveR = backgroundColor.r * a + (1.0 - a), same for G/B. Use effective values for luminance. Restrictions: Do not change luminance formula or threshold. Success: Semi-transparent colors resolve correct contrast._

## Phase 7: Example App and Tests

- [x] 17. Add Keyboard section to Day Theme Tab
  - Files: `example/lib/views/day_view/tabs/day_theme_tab.dart`, `example/lib/l10n/app_*.arb`, generated localization files
  - Add "Keyboard" `ControlPanelSection` as the **last** section with 6 controls: `keyboardSelectionBorderWidth` (slider), `keyboardSelectionBorderColor` (color picker), `keyboardSelectionBorderRadius` (slider), `keyboardHighlightBorderWidth` (slider), `keyboardHighlightBorderColor` (color picker), `keyboardHighlightBorderRadius` (slider).
  - Remove old `keyboardFocusBorderRadius` control from "All Events" section.
  - Add localization keys: `sectionKeyboard`, `settingKeyboardSelectionBorderWidth`, `settingKeyboardSelectionBorderColor`, `settingKeyboardSelectionBorderRadius`, `settingKeyboardHighlightBorderWidth`, `settingKeyboardHighlightBorderColor`, `settingKeyboardHighlightBorderRadius` across all 5 locales.
  - _Leverage: Existing ControlPanelSection and ControlWidgets patterns._
  - _Requirements: 8.1, 8.3, 8.4_
  - _Prompt: Role: Flutter app developer. Task: Add "Keyboard" ControlPanelSection as the last section in day_theme_tab.dart with 6 controls for the unified keyboard properties. Remove old keyboardFocusBorderRadius from "All Events". Add localization keys across all 5 ARB files and regenerate. Restrictions: Section must be last. Success: 6 controls visible; localized._

- [x] 18. Add Keyboard section to Month Theme Tab
  - File: `example/lib/views/month_view/tabs/month_theme_tab.dart`
  - Add "Keyboard" `ControlPanelSection` as the **last** section with the same 6 controls as Task 17.
  - _Leverage: Same patterns as Task 17._
  - _Requirements: 8.2_
  - _Prompt: Role: Flutter app developer. Task: Add "Keyboard" ControlPanelSection as the last section in month_theme_tab.dart with 6 controls for unified keyboard properties. Restrictions: Section must be last. Success: 6 controls visible; localized._

- [x] 19. Update theme presets
  - File: `example/lib/shared/utils/theme_presets.dart`
  - Replace `keyboardFocusBorderRadius` with `keyboardSelectionBorderRadius` and `keyboardHighlightBorderRadius` in all presets.
  - _Leverage: Existing theme preset structure._
  - _Requirements: 8.5_
  - _Prompt: Role: Flutter app developer. Task: In theme_presets.dart, replace keyboardFocusBorderRadius with keyboardSelectionBorderRadius and keyboardHighlightBorderRadius in all presets. Success: Presets compile._

- [x] 20. Update and add tests
  - Files: `test/styles/mcal_theme_layout_defaults_test.dart`, `test/styles/mcal_day_view_theme_data_test.dart`, `test/styles/mcal_theme_test.dart`, `test/styles/mcal_month_view_theme_data_test.dart`, `test/widgets/mcal_day_view_keyboard_move_resize_test.dart`
  - Remove tests for deleted keyboard properties.
  - Add expectations for the 6 new keyboard property defaults on both `MCalDayViewThemeData` and `MCalMonthViewThemeData`.
  - Add `keyboardHighlightBorderColor` assertion in theme cascade tests.
  - Add Month View keyboard ring default test.
  - Add 4 regression tests for keyboard move/resize bug fixes:
    1. After keyboard move, resize uses post-move event instance.
    2. 'S' key re-bases resize offset to start edge correctly.
    3. Nudge end time then 'S' preserves extended end.
    4. Nudge start time then 'E' preserves adjusted start.
  - _Leverage: Existing test infrastructure, pumpCalendar, sendKey helpers._
  - _Requirements: 2.2, 2.3, 5.1, 6.1, 6.2, NFR Reliability_
  - _Prompt: Role: Test developer. Task: (1) Remove tests for deleted keyboard properties. (2) Add defaults expectations for 6 keyboard properties on both theme data classes. (3) Add keyboardHighlightBorderColor assertion. (4) Add month view keyboard ring default test. (5) Add 4 regression tests in mcal_day_view_keyboard_move_resize_test.dart covering stale event fix and S/E edge switching. Restrictions: Use flutter_test. Success: All tests pass._

## Phase 8: Additional Test Coverage

- [x] 21. Add resolveContrastColor alpha compositing tests
  - File: `test/utils/theme_cascade_utils_test.dart`
  - Add tests within the existing `resolveContrastColor` group for semi-transparent backgrounds:
    1. A dark color (e.g. `Colors.black`) with low alpha (e.g. 0.1) composited against white yields a light effective color → should return `darkContrastColor`.
    2. A light color (e.g. `Colors.white`) with low alpha composited against white yields a light effective color → should return `darkContrastColor`.
    3. A dark color with high alpha (e.g. 0.9) composited against white still reads as dark → should return `lightContrastColor`.
    4. Fully transparent (`alpha: 0.0`) of any color composited against white → luminance ~1.0 → should return `darkContrastColor`.
  - _Leverage: Existing `resolveContrastColor` test group in `theme_cascade_utils_test.dart`._
  - _Requirements: 7.1, 7.2, 7.3, 7.4_
  - _Prompt: Role: Test developer. Task: Add 4 tests to the existing resolveContrastColor group in test/utils/theme_cascade_utils_test.dart covering semi-transparent backgrounds. (1) Dark color at low alpha (0.1) composited against white → effective light → dark contrast. (2) Light color at low alpha → still light → dark contrast. (3) Dark color at high alpha (0.9) → still dark → light contrast. (4) Fully transparent (alpha 0.0) → composites to white → dark contrast. Restrictions: Use flutter_test. Follow existing test patterns in the file. Success: All 4 tests pass, validating the alpha compositing logic._

- [x] 22. Add Month View isAllDay theme branching widget tests
  - File: `test/widgets/mcal_month_view_theme_branching_test.dart` (new) or additions to existing month view test file
  - Test that when a custom theme sets `allDayEventBackgroundColor` to a distinct color and `eventTileBackgroundColor` to a different color:
    1. An all-day event tile (`isAllDay: true`) uses the `allDayEventBackgroundColor`.
    2. A timed event tile (`isAllDay: false`) uses the `eventTileBackgroundColor`.
  - Test in both `mcal_month_multi_day_tile.dart` (multi-day segments) and `week_row_widget.dart` (single-day tiles) rendering paths.
  - _Leverage: Existing month view widget test infrastructure (pumpCalendar or pumpWidget with MCalTheme); MCalAllDayTileThemeMixin properties._
  - _Requirements: 4.1, 4.2, 4.5, 4.6, 9.3, 9.4_
  - _Prompt: Role: Test developer. Task: Create widget tests verifying Month View isAllDay theme branching. Set up a theme with distinct allDayEventBackgroundColor (e.g. Colors.green) and eventTileBackgroundColor (e.g. Colors.red). Add two events: one with isAllDay=true, one with isAllDay=false. Render Month View and verify: (1) The all-day event tile uses allDayEventBackgroundColor. (2) The timed event tile uses eventTileBackgroundColor. Cover both multi-day bar segments and single-day tiles. Restrictions: Use flutter_test with MCalTheme wrapping. Success: Tests pass, confirming isAllDay branching selects correct theme properties._
