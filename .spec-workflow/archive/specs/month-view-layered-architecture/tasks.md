# Tasks Document

## Phase 1: Foundation - New Models and Context Objects

- [x] 1. Create MCalEventSegment and DateLabelPosition in new contexts file
  - File: `lib/src/widgets/mcal_week_layout_contexts.dart`
  - Create `MCalEventSegment` class with event, weekRowIndex, startDayInWeek, endDayInWeek, isFirstSegment, isLastSegment
  - Create `DateLabelPosition` enum with 6 values (topLeft, topCenter, topRight, bottomLeft, bottomCenter, bottomRight)
  - Add computed properties: spanDays, isSingleDay
  - Purpose: Unified segment model for single-day and multi-day events
  - _Leverage: Existing `MCalMultiDayRowSegment` pattern from `lib/src/widgets/mcal_multi_day_renderer.dart`_
  - _Requirements: 5, 12_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: Dart Developer specializing in Flutter data models | Task: Create MCalEventSegment class and DateLabelPosition enum in new file mcal_week_layout_contexts.dart, following patterns from MCalMultiDayRowSegment. Include proper equality, hashCode, and toString implementations. | Restrictions: Do not modify existing files yet, follow existing naming conventions (MCal prefix), ensure immutable class design | Success: Classes compile without errors, follow existing patterns, include all required properties and computed getters. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

- [x] 2. Create MCalWeekLayoutConfig in contexts file
  - File: `lib/src/widgets/mcal_week_layout_contexts.dart` (continue from task 1)
  - Create `MCalWeekLayoutConfig` class with all layout configuration values
  - Add factory constructor `fromTheme(MCalThemeData theme)` to inherit values
  - Include: tileHeight, tileVerticalSpacing, tileHorizontalSpacing, tileCornerRadius, tileBorderWidth, dateLabelHeight, dateLabelPosition, overflowIndicatorHeight
  - Purpose: Configuration object that inherits from theme with override capability
  - _Leverage: `MCalThemeData` patterns from `lib/src/styles/mcal_theme.dart`_
  - _Requirements: 12, 13_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: Dart Developer with Flutter theming expertise | Task: Create MCalWeekLayoutConfig class with factory fromTheme constructor that pulls values from MCalThemeData, using sensible defaults (tileHeight: 18.0, tileVerticalSpacing: 2.0, etc.) | Restrictions: Must be immutable, use null-coalescing for theme values with defaults, follow existing config patterns | Success: Config class compiles, fromTheme correctly inherits values, defaults match POC values. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

- [x] 3. Create MCalOverflowIndicatorContext in contexts file
  - File: `lib/src/widgets/mcal_week_layout_contexts.dart` (continue from task 2)
  - Create `MCalOverflowIndicatorContext` class with date, hiddenEventCount, hiddenEvents, visibleEvents, width, height
  - Purpose: Context object for overflow indicator builder
  - _Leverage: Existing context patterns from `lib/src/widgets/mcal_month_view_contexts.dart`_
  - _Requirements: 7, 9_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: Dart Developer specializing in Flutter builder patterns | Task: Create MCalOverflowIndicatorContext following existing context patterns (MCalDateLabelContext, MCalEventTileContext), including all required properties for overflow indicator rendering | Restrictions: Follow existing context naming and structure, immutable class design, include proper const constructor | Success: Context class follows existing patterns, contains all required properties for overflow building and tap handling. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

- [x] 4. Create MCalWeekLayoutContext in contexts file
  - File: `lib/src/widgets/mcal_week_layout_contexts.dart` (continue from task 3)
  - Create `MCalWeekLayoutContext` class with segments, dates, columnWidths, rowHeight, weekRowIndex, currentMonth
  - Add builder function properties: eventTileBuilder, dateLabelBuilder, overflowIndicatorBuilder
  - Add config property for MCalWeekLayoutConfig
  - Purpose: Main context object passed to weekLayoutBuilder
  - _Leverage: Existing context patterns, MCalNavigatorContext as example with callbacks_
  - _Requirements: 3, 10_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: Dart Developer with Flutter builder pattern expertise | Task: Create MCalWeekLayoutContext containing all data needed by weekLayoutBuilder including pre-wrapped builder functions for event tiles, date labels, and overflow indicators | Restrictions: Builder function types must match expected signatures, follow existing context patterns, document all properties | Success: Context class contains all required data for week layout building, builder function types are correctly defined. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

## Phase 2: Theme and Callback Updates

- [x] 5. Add new properties to MCalThemeData
  - File: `lib/src/styles/mcal_theme.dart`
  - Add: dateLabelHeight, dateLabelPosition (using DateLabelPosition enum), overflowIndicatorHeight, tileCornerRadius
  - Update fromTheme() with sensible defaults
  - Update copyWith() and lerp() methods
  - Purpose: Enable theme-based configuration of new layout values
  - _Leverage: Existing MCalThemeData property patterns_
  - _Requirements: 12, 13_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: Dart Developer specializing in Flutter theming | Task: Add new nullable properties to MCalThemeData for dateLabelHeight, dateLabelPosition, overflowIndicatorHeight, tileCornerRadius. Update fromTheme with defaults (18.0, topLeft, 14.0, 3.0), copyWith, and lerp methods | Restrictions: Must maintain backward compatibility, follow existing property patterns exactly, ensure lerp handles enum correctly | Success: New properties added, fromTheme provides defaults, copyWith and lerp work correctly, existing tests still pass. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

- [x] 6. Update MCalEventTileContext with segment info
  - File: `lib/src/widgets/mcal_month_view_contexts.dart`
  - Add segment property (MCalEventSegment) to MCalEventTileContext
  - Add width and height properties for tile dimensions
  - Update constructor to include new properties (with backwards-compatible defaults where possible)
  - Purpose: Unified tile context for single-day and multi-day events
  - _Leverage: Existing MCalEventTileContext structure_
  - _Requirements: 5_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: Dart Developer with Flutter context pattern expertise | Task: Update MCalEventTileContext to include MCalEventSegment, width, and height properties, maintaining backward compatibility where possible | Restrictions: Import the new contexts file, preserve existing properties, add new properties as nullable or with defaults for compatibility | Success: Updated context includes segment info, existing code using old signature still compiles or has clear migration path. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

- [x] 7. Add MCalOverflowTapDetails to callback details
  - File: `lib/src/widgets/mcal_callback_details.dart`
  - Create `MCalOverflowTapDetails` class with date, hiddenEvents, visibleEvents
  - Purpose: Details object for onOverflowTap callback
  - _Leverage: Existing callback details patterns (MCalCellTapDetails, etc.)_
  - _Requirements: 7_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: Dart Developer specializing in Flutter callback patterns | Task: Create MCalOverflowTapDetails class following existing callback details patterns, containing date, hiddenEvents list, and visibleEvents list | Restrictions: Follow existing naming and structure exactly, immutable class with const constructor | Success: Details class follows existing patterns, can be used in onOverflowTap callback signature. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

## Phase 3: Builder Wrapper Implementation

- [x] 8. Create MCalBuilderWrapper utility class
  - File: `lib/src/widgets/mcal_builder_wrapper.dart` (new file)
  - Implement static `wrapEventTileBuilder` method that wraps developer builder with GestureDetector and LongPressDraggable
  - Implement static `wrapDateLabelBuilder` method (currently pass-through, extensible for future)
  - Implement static `wrapOverflowIndicatorBuilder` method with tap handler
  - Purpose: Separate visual customization from interaction handling
  - _Leverage: Existing `MCalDraggableEventTile` wrapping patterns, GestureDetector usage in mcal_month_view.dart_
  - _Requirements: 4_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: Dart Developer with Flutter gesture handling expertise | Task: Create MCalBuilderWrapper with static methods to wrap developer-provided builders with interaction handlers. wrapEventTileBuilder should add GestureDetector (onTap, onLongPress) and optionally LongPressDraggable. wrapOverflowIndicatorBuilder should add tap handler. | Restrictions: Must call developer's builder first to get visual widget, then wrap result with handlers, handle null developer builders by using default, maintain clean separation of concerns | Success: Wrapped builders include interaction handling, developer's visual customization is preserved, handlers invoke appropriate callbacks. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

## Phase 4: Default Week Layout Builder

- [x] 9. Create MCalDefaultWeekLayoutBuilder with row assignment algorithm
  - File: `lib/src/widgets/mcal_default_week_layout.dart` (new file)
  - Create `MCalSegmentRowAssignment` class (segment + row index)
  - Create `MCalOverflowInfo` class (hiddenCount, hiddenEvents, visibleEvents)
  - Implement static `assignRows(List<MCalEventSegment>)` using greedy first-fit algorithm
  - Implement static `calculateOverflow()` to compute per-day overflow info
  - Purpose: Core layout algorithm matching POC behavior
  - _Leverage: Algorithm from `MCalMultiDayRenderer.calculateWeekLayout()`, POC `_assignSegmentRows()` logic_
  - _Requirements: 3, 9, 10_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: Dart Developer with algorithm implementation expertise | Task: Create MCalDefaultWeekLayoutBuilder with greedy first-fit row assignment algorithm matching POC implementation. Port _assignSegmentRows logic and add overflow calculation that correctly counts hidden events per day column (not hidden rows) | Restrictions: Algorithm must handle multi-day events creating blank spaces, must match POC behavior exactly, O(n*m) complexity where n is events and m is max rows | Success: Row assignment produces same results as POC, overflow calculation correctly counts per-day hidden events. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

- [x] 10. Add build method to MCalDefaultWeekLayoutBuilder
  - File: `lib/src/widgets/mcal_default_week_layout.dart` (continue from task 9)
  - Implement static `build(BuildContext, MCalWeekLayoutContext)` method
  - Use Stack with Positioned widgets for date labels, event tiles, overflow indicators
  - Apply conditional styling for multi-week event continuity (corners, borders, spacing)
  - Purpose: Default layout matching POC visual output
  - _Leverage: POC `_buildLayer2Events()`, `_buildEventTile()`, `_buildDateLabel()` logic_
  - _Requirements: 3, 5, 6, 7_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: Flutter Developer with layout expertise | Task: Implement build method that creates a Stack with Positioned date labels, event tiles (via wrapped builder), and overflow indicators (via wrapped builder). Apply conditional corner radius, border, and spacing based on isFirstSegment/isLastSegment flags | Restrictions: Must use LayoutBuilder for constraints, must invoke the wrapped builders from context (not create widgets directly), must match POC visual output | Success: Default layout matches POC appearance, multi-week events have visual continuity, overflow indicators display correctly. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

## Phase 5: MCalMultiDayRenderer Extension

- [x] 11. Extend MCalMultiDayRenderer to generate segments for ALL events
  - File: `lib/src/widgets/mcal_multi_day_renderer.dart`
  - Add new method `calculateAllEventSegments()` that generates MCalEventSegment for both single-day and multi-day events
  - Single-day events get segment with spanDays=1, isFirstSegment=true, isLastSegment=true
  - Maintain existing methods for backward compatibility during transition
  - Purpose: Unified segment generation for new architecture
  - _Leverage: Existing `calculateLayouts()` method as basis_
  - _Requirements: 3, 5_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: Dart Developer with event processing expertise | Task: Add calculateAllEventSegments method to MCalMultiDayRenderer that creates MCalEventSegment objects for ALL events (not just multi-day). Single-day events should have segments with spanDays=1 and both isFirstSegment and isLastSegment true | Restrictions: Keep existing methods working for now, sort all events consistently (multi-day first, then by start time), handle edge cases for events at month boundaries | Success: Method generates correct segments for all event types, maintains consistent ordering for layout algorithm. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

## Phase 6: MCalMonthView Refactoring

- [x] 12. Add new parameters to MCalMonthView
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Add `weekLayoutBuilder` parameter with typedef
  - Add `overflowIndicatorBuilder` parameter with typedef
  - Remove `renderMultiDayEventsAsContiguous` parameter
  - Remove `multiDayEventTileBuilder` parameter
  - Update constructor documentation
  - Purpose: New API surface for layered architecture
  - _Leverage: Existing builder parameter patterns_
  - _Requirements: 10, 11_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: Flutter Developer with widget API design expertise | Task: Add weekLayoutBuilder and overflowIndicatorBuilder parameters to MCalMonthView. Remove renderMultiDayEventsAsContiguous and multiDayEventTileBuilder parameters. Update parameter documentation. | Restrictions: Breaking changes are acceptable (unreleased package), follow existing builder parameter patterns, ensure proper nullability | Success: New parameters added with proper types and documentation, removed parameters cause compile errors in dependent code (expected). Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

- [x] 13. Refactor _WeekRowWidget to use 3-layer Stack
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Refactor `_WeekRowWidget.build()` to return Stack with 3 layers
  - Layer 1: Grid cells using dayCellBuilder (remove event rendering from cells)
  - Layer 2: Events/labels using weekLayoutBuilder (or default)
  - Layer 3: Drag ghost (conditional on isDragging)
  - Use MCalBuilderWrapper to wrap builders before passing to weekLayoutBuilder
  - Purpose: Core architectural change to layered rendering
  - _Leverage: POC `_buildCalendarStack()` structure, MCalBuilderWrapper_
  - _Requirements: 1, 2, 3, 4, 8_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: Senior Flutter Developer with widget architecture expertise | Task: Refactor _WeekRowWidget to use 3-layer Stack architecture. Layer 1 renders grid cells only (no events). Layer 2 uses weekLayoutBuilder with wrapped builders. Layer 3 renders drag ghost during drag operations. | Restrictions: Must wrap developer builders using MCalBuilderWrapper before passing to weekLayoutBuilder, Layer 3 only renders when drag is active, preserve all existing interaction callbacks | Success: 3-layer Stack renders correctly, events appear in Layer 2 above grid, drag ghost appears in Layer 3, all interactions work. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

- [x] 14. Update week number rendering to be outside layers
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Move week number rendering outside the 3-layer Stack
  - Position left (LTR) or right (RTL) based on text direction
  - Use same height calculations as layers for vertical alignment
  - Purpose: Week numbers aligned but independent of layer system
  - _Leverage: Existing week number rendering, RTL detection patterns_
  - _Requirements: 2_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: Flutter Developer with RTL layout expertise | Task: Move week number column outside the 3-layer Stack, positioned using Row with week numbers on left (LTR) or right (RTL). Ensure week row heights match between week numbers and Stack content. | Restrictions: Must detect RTL via Directionality.of(context), must maintain vertical alignment with week rows, preserve weekNumberBuilder callback | Success: Week numbers display correctly for both LTR and RTL, vertically aligned with corresponding week rows. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

## Phase 7: Export and Integration

- [x] 15. Update multi_calendar.dart exports
  - File: `lib/multi_calendar.dart`
  - Export new public classes: MCalEventSegment, MCalWeekLayoutContext, MCalWeekLayoutConfig, MCalOverflowIndicatorContext, DateLabelPosition, MCalOverflowTapDetails
  - Export MCalDefaultWeekLayoutBuilder for developers who want to extend it
  - Purpose: Make new API publicly accessible
  - _Leverage: Existing export patterns_
  - _Requirements: 10, 11_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: Dart Developer with package API design expertise | Task: Add exports for all new public classes to multi_calendar.dart, following existing export organization | Restrictions: Only export truly public API classes, maintain alphabetical ordering if present, ensure no circular dependencies | Success: All new public classes are importable via package:multi_calendar/multi_calendar.dart. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

## Phase 8: Example App Updates

- [x] 16. Update minimal_style.dart to use new API
  - File: `example/lib/views/month_view/styles/minimal_style.dart`
  - Remove renderMultiDayEventsAsContiguous parameter
  - Provide custom weekLayoutBuilder that renders dots for events
  - Purpose: Demonstrate dots-style layout with new architecture
  - _Leverage: POC patterns, new weekLayoutBuilder API_
  - _Requirements: 12_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: Flutter Developer with example app expertise | Task: Update minimal_style.dart to use new API. Remove deprecated renderMultiDayEventsAsContiguous. Create custom weekLayoutBuilder that renders a single dot per day if events exist (like current behavior but via new architecture). | Restrictions: Must use weekLayoutBuilder pattern, maintain current visual appearance (dots), remove all usage of deprecated parameters | Success: Minimal style renders dots correctly using new architecture, no deprecated parameter usage. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

- [x] 17. Update modern_style.dart to use new API
  - File: `example/lib/views/month_view/styles/modern_style.dart`
  - Remove renderMultiDayEventsAsContiguous parameter
  - Provide custom weekLayoutBuilder for modern dots layout
  - Purpose: Demonstrate modern styling with new architecture
  - _Leverage: POC patterns, new weekLayoutBuilder API_
  - _Requirements: 12_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: Flutter Developer with UI design expertise | Task: Update modern_style.dart to use new API with custom weekLayoutBuilder that maintains current modern dots appearance | Restrictions: Remove deprecated parameters, use new builder patterns, preserve visual appearance | Success: Modern style works with new architecture, visual appearance preserved. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

- [x] 18. Create elongated pills style example
  - File: `example/lib/views/month_view/styles/colorful_style.dart` (or new file)
  - Remove renderMultiDayEventsAsContiguous parameter
  - Create custom weekLayoutBuilder using eventTileBuilder that returns ~3px height pills without labels
  - Demonstrate multi-day events as continuous elongated pills
  - Purpose: Showcase elongated pill layout style per requirements
  - _Leverage: POC patterns, new eventTileBuilder API with segment info_
  - _Requirements: 12_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: Flutter Developer with creative UI expertise | Task: Create or update a style to use elongated pills (~3px height) without labels for events. Use eventTileBuilder that returns a thin colored bar, leveraging segment info for multi-day continuity (no rounded corners on continuation edges). | Restrictions: Pills should be ~3px tall, use event color, show visual continuity for multi-week events, no text labels | Success: Events display as thin elongated pills, multi-week events are visually continuous. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

- [x] 19. Update features_demo_style.dart toggles
  - File: `example/lib/views/month_view/styles/features_demo_style.dart`
  - Remove renderMultiDayEventsAsContiguous toggle and related state
  - Add toggles for new configuration options (dateLabelPosition, tileHeight, etc.)
  - Purpose: Feature demo reflects new architecture capabilities
  - _Leverage: Existing toggle patterns in features_demo_style.dart_
  - _Requirements: 12, 13_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: Flutter Developer with demo app expertise | Task: Update features_demo_style.dart to remove deprecated toggle for renderMultiDayEventsAsContiguous. Add controls for new themeable properties: dateLabelPosition dropdown, tileHeight slider. | Restrictions: Remove all references to deprecated parameters, add new controls following existing UI patterns | Success: Demo has controls for new config options, no deprecated parameter usage. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

- [x] 20. Update remaining example styles
  - Files: `example/lib/views/month_view/styles/classic_style.dart`, `example/lib/views/month_view/styles/compact_style.dart`
  - Remove any usage of deprecated parameters
  - Ensure all example styles compile and work with new API
  - Purpose: Complete migration of example app
  - _Requirements: 11, 12_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: Flutter Developer | Task: Update classic_style.dart, compact_style.dart and any other example styles to remove deprecated parameters and work with new API | Restrictions: Must compile without errors, preserve intended visual appearance where possible | Success: All example styles compile and run correctly with new API. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

## Phase 9: Testing

- [x] 21. Create unit tests for new context classes
  - File: `test/widgets/mcal_week_layout_contexts_test.dart` (new file)
  - Test MCalEventSegment (creation, computed properties, equality)
  - Test MCalWeekLayoutConfig (fromTheme, defaults)
  - Test DateLabelPosition enum values
  - Purpose: Ensure model reliability
  - _Leverage: Existing test patterns from test/models/_
  - _Requirements: 5, 12_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: QA Engineer with Flutter testing expertise | Task: Create unit tests for MCalEventSegment, MCalWeekLayoutConfig, and DateLabelPosition covering construction, computed properties, equality, and theme inheritance | Restrictions: Follow existing test patterns, use flutter_test framework, ensure good coverage | Success: All new classes have comprehensive tests, edge cases covered. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

- [x] 22. Create unit tests for MCalDefaultWeekLayoutBuilder
  - File: `test/widgets/mcal_default_week_layout_test.dart` (new file)
  - Test assignRows with various event combinations
  - Test calculateOverflow with multi-day events creating blank spaces
  - Test edge cases (empty events, single event, full week)
  - Purpose: Ensure layout algorithm correctness
  - _Leverage: Existing MCalMultiDayRenderer tests_
  - _Requirements: 9, 10_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: QA Engineer with algorithm testing expertise | Task: Create unit tests for MCalDefaultWeekLayoutBuilder focusing on assignRows algorithm and calculateOverflow. Test various scenarios: overlapping events, multi-week events, overflow edge cases | Restrictions: Test algorithm logic in isolation, mock event data, verify row assignments match expected output | Success: Algorithm tests cover all scenarios, overflow calculation correctly handles blank spaces. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

- [x] 23. Update existing MCalMonthView tests
  - File: `test/widgets/mcal_month_view_test.dart`
  - Remove tests for renderMultiDayEventsAsContiguous
  - Add tests for weekLayoutBuilder and overflowIndicatorBuilder
  - Add tests for 3-layer Stack structure
  - Purpose: Ensure widget tests reflect new architecture
  - _Leverage: Existing widget test patterns_
  - _Requirements: 1, 3, 4_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: QA Engineer with Flutter widget testing expertise | Task: Update mcal_month_view_test.dart to remove tests for deprecated parameters. Add tests verifying 3-layer Stack structure, weekLayoutBuilder invocation, and builder wrapping behavior | Restrictions: Remove all tests using deprecated parameters, add meaningful tests for new architecture, maintain existing test coverage for unchanged features | Success: Tests pass, deprecated parameter tests removed, new architecture tests added. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

- [x] 24. Update integration tests
  - File: `test/integration/mcal_month_view_integration_test.dart`
  - Remove references to deprecated parameters
  - Add integration tests for complete event flow with new architecture
  - Purpose: Ensure end-to-end functionality
  - _Leverage: Existing integration test patterns_
  - _Requirements: All_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: QA Engineer with integration testing expertise | Task: Update integration tests to remove deprecated parameter usage. Add tests for complete event rendering flow through Layer 2, drag-and-drop through Layer 3, and overflow indicator interactions | Restrictions: Must test real user scenarios, ensure drag-and-drop integration works with new layers | Success: Integration tests pass, cover new architecture flow, no deprecated parameter usage. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

## Phase 10: Documentation and Cleanup

- [x] 25. Update CHANGELOG.md
  - File: `CHANGELOG.md`
  - Document breaking changes (removed parameters)
  - Document new features (weekLayoutBuilder, overflowIndicatorBuilder, layered architecture)
  - Provide migration guidance
  - Purpose: Communicate changes to developers
  - _Requirements: 11_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: Technical Writer | Task: Update CHANGELOG.md with breaking changes section listing removed parameters (renderMultiDayEventsAsContiguous, multiDayEventTileBuilder), new features section (weekLayoutBuilder, 3-layer architecture, overflowIndicatorBuilder), and migration guidance | Restrictions: Follow existing changelog format, be specific about breaking changes, provide clear migration steps | Success: Changelog clearly documents all changes and helps developers migrate. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

- [x] 26. Update README.md
  - File: `README.md`
  - Update API documentation for new builders
  - Remove references to deprecated parameters
  - Add examples of custom weekLayoutBuilder usage
  - Purpose: Package documentation reflects new architecture
  - _Requirements: All_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: Technical Writer with Flutter documentation expertise | Task: Update README.md to document new weekLayoutBuilder pattern, overflowIndicatorBuilder, and layered architecture. Remove all references to deprecated parameters. Add usage examples. | Restrictions: Keep documentation concise but complete, update code examples to reflect new API | Success: README accurately describes new architecture and API, no deprecated parameter references. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

- [x] 27. Remove deprecated code paths
  - Files: `lib/src/widgets/mcal_month_view.dart`, `lib/src/widgets/mcal_multi_day_tile.dart`
  - Remove any remaining code for renderMultiDayEventsAsContiguous=false path
  - Remove multiDayEventTileBuilder handling code
  - Clean up unused imports and methods
  - Purpose: Code cleanup and simplification
  - _Requirements: 11_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: Senior Dart Developer | Task: Remove all code related to deprecated parameters. Clean up unused methods, imports, and conditional code paths that were for the old architecture | Restrictions: Ensure no dead code remains, verify all tests still pass after cleanup | Success: Codebase is clean with no deprecated code paths, all tests pass. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._

- [x] 28. Final verification and example app testing
  - Files: All example app files
  - Run example app and verify all tabs work correctly
  - Verify POC tab still functions as reference
  - Test on both mobile and web
  - Purpose: Final validation of implementation
  - _Requirements: 12_
  - _Prompt: Implement the task for spec month-view-layered-architecture, first run spec-workflow-guide to get the workflow guide then implement the task: | Role: QA Engineer | Task: Run comprehensive manual testing of example app. Verify all month view tabs render correctly. Test event interactions (tap, long-press, drag-drop). Verify both light and dark themes. Test on Chrome web and iOS/Android simulator. | Restrictions: Must test all tabs including Layout POC, verify no visual regressions | Success: All example tabs work correctly, interactions function properly, no visual regressions from current behavior. Mark task in-progress in tasks.md before starting, log implementation with log-implementation tool after completion, then mark complete._
