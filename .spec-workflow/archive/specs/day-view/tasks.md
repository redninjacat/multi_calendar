# Tasks Document: Day View Implementation

## Phase 0: Code Organization - Separate Month View from Shared Code

**Purpose**: Before continuing Day View implementation, reorganize the codebase to clearly separate month-view-specific code from day-view-specific code from truly shared code. This prevents confusion and ensures Day View follows the correct architectural patterns.

**Context**: Month View was implemented first (completed). Many classes and files are month-view-specific but have generic names suggesting they're shared. See `code-organization-analysis.md` for full details.

* [x] 0.1. Rename month-view-specific widget files and classes
  * **File renames** (use `git mv` to preserve history):
    * `lib/src/widgets/mcal_default_week_layout.dart` → `mcal_month_default_week_layout.dart`
    * `lib/src/widgets/mcal_multi_day_renderer.dart` → `mcal_month_multi_day_renderer.dart`
    * `lib/src/widgets/mcal_multi_day_tile.dart` → `mcal_month_multi_day_tile.dart`
    * `lib/src/widgets/mcal_week_layout_contexts.dart` → `mcal_month_week_layout_contexts.dart`
  * **Class renames** (update within files):
    * In `mcal_month_default_week_layout.dart`:
      * `MCalDefaultWeekLayoutBuilder` → `MCalMonthDefaultWeekLayoutBuilder`
      * `MCalSegmentRowAssignment` → `MCalMonthSegmentRowAssignment`
      * `MCalOverflowInfo` → `MCalMonthOverflowInfo`
    * In `mcal_month_multi_day_tile.dart`:
      * `MCalMultiDayTile` → `MCalMonthMultiDayTile`
    * In `mcal_month_week_layout_contexts.dart`:
      * `MCalEventSegment` → `MCalMonthEventSegment`
      * `MCalWeekLayoutContext` → `MCalMonthWeekLayoutContext`
      * `MCalWeekLayoutConfig` → `MCalMonthWeekLayoutConfig`
      * `MCalOverflowIndicatorContext` → `MCalMonthOverflowIndicatorContext`
    * In `mcal_month_multi_day_renderer.dart`:
      * Keep class names as-is (internal implementation)
  * Purpose: Clearly indicate these are month-view-specific, not shared. Keep "Default" for default implementations.
  * *Leverage: Code organization analysis document, git mv for safe renaming*
  * *Requirements: Code organization, maintainability, preparation for Multi-Day View*
  * *Prompt: Rename 4 month-view-specific widget files AND classes to clearly indicate their scope. Files: Keep "default" in name (e.g., `mcal_month_default_week_layout.dart`). Classes: Prefix with "Month" (e.g., `MCalMonthDefaultWeekLayoutBuilder`). Use `git mv` for files. Update class names, dartdoc, and internal references. Do NOT modify logic.*
* [x] 0.2. Update imports and class references in mcal\_month\_view.dart
  * File: `lib/src/widgets/mcal_month_view.dart`
  * **Update import statements**:
    * `import 'mcal_default_week_layout.dart'` → `import 'mcal_month_default_week_layout.dart'`
    * `import 'mcal_multi_day_renderer.dart'` → `import 'mcal_month_multi_day_renderer.dart'`
    * `import 'mcal_multi_day_tile.dart'` → `import 'mcal_month_multi_day_tile.dart'`
    * `import 'mcal_week_layout_contexts.dart'` → `import 'mcal_month_week_layout_contexts.dart'`
  * **Update class references** throughout the file:
    * `MCalDefaultWeekLayoutBuilder` → `MCalMonthDefaultWeekLayoutBuilder`
    * `MCalSegmentRowAssignment` → `MCalMonthSegmentRowAssignment`
    * `MCalOverflowInfo` → `MCalMonthOverflowInfo`
    * `MCalMultiDayTile` → `MCalMonthMultiDayTile`
    * `MCalEventSegment` → `MCalMonthEventSegment`
    * `MCalWeekLayoutContext` → `MCalMonthWeekLayoutContext`
    * `MCalWeekLayoutConfig` → `MCalMonthWeekLayoutConfig`
    * `MCalOverflowIndicatorContext` → `MCalMonthOverflowIndicatorContext`
  * Purpose: Fix imports and class references after renaming
  * *Leverage: IDE find/replace with whole word matching*
  * *Requirements: Working imports, compiles without errors*
  * *Prompt: Update all imports and class references in `mcal_month_view.dart`. Use find/replace with whole word matching. Verify file compiles with `dart analyze lib/src/widgets/mcal_month_view.dart`.*
* [x] 0.3. Update exports in multi\_calendar.dart
  * File: `lib/multi_calendar.dart`
  * **Update export paths AND class names** (API not yet published, breaking changes OK):
    * `export 'src/widgets/mcal_default_week_layout.dart'` → `export 'src/widgets/mcal_month_default_week_layout.dart'`
    * Update show clause: `MCalDefaultWeekLayoutBuilder` → `MCalMonthDefaultWeekLayoutBuilder`
    * Update show clause: `MCalSegmentRowAssignment` → `MCalMonthSegmentRowAssignment`
    * Update show clause: `MCalOverflowInfo` → `MCalMonthOverflowInfo`
  * Similar updates for other renamed files and classes
  * Purpose: Export renamed classes with new month-specific names
  * *Leverage: Export pattern in multi\_calendar.dart*
  * *Requirements: Working exports*
  * *Prompt: Update export paths AND exported class names in `lib/multi_calendar.dart`. Change both file paths and class names in show clauses. Verify exports compile with `dart analyze lib/multi_calendar.dart`.*
* [x] 0.4. Update test file imports and class references
  * **Find affected test files**:
    * `grep -r "mcal_default_week_layout\|mcal_multi_day_renderer\|mcal_multi_day_tile\|mcal_week_layout_contexts\|MCalDefaultWeekLayoutBuilder\|MCalSegmentRowAssignment\|MCalOverflowInfo\|MCalMultiDayTile\|MCalEventSegment\|MCalWeekLayoutContext\|MCalWeekLayoutConfig\|MCalOverflowIndicatorContext" test/`
  * **Update imports** to new file paths
  * **Update class references** to new class names with "Month" prefix
  * **Update test descriptions** to clarify these test month view components
  * Purpose: Fix test imports and references after renaming
  * *Leverage: grep to find all affected tests, then update systematically*
  * *Requirements: Working test imports, tests compile*
  * *Prompt: Find all test files affected by Phase 0 renames using grep. Update imports, class references, and test descriptions. Run `dart analyze test/` to verify.*
* [x] 0.5. Rename month-view-specific test files
  * **Rename test files** (use `git mv`):
    * `test/widgets/mcal_default_week_layout_test.dart` → `mcal_month_default_week_layout_test.dart`
    * Consider renaming `mcal_multi_day_renderer_test.dart` → `mcal_month_multi_day_renderer_test.dart` if exists
  * **Update test file contents**:
    * Test group names: "MCalDefaultWeekLayoutBuilder" → "MCalMonthDefaultWeekLayoutBuilder"
    * Descriptions: Add "Month View" context to clarify scope
  * Purpose: Clearly indicate these tests are month-view-specific
  * *Leverage: git mv, test file patterns*
  * *Requirements: Clear test organization*
  * *Prompt: Rename month-specific test files using `git mv`. Keep "default" in filename. Update test group names and descriptions to use new class names with "Month" prefix. Verify with `flutter test test/widgets/mcal_month_default_week_layout_test.dart`.*
* [x] 0.6. Run full test suite and verify
  * Run: `flutter test`
  * Run: `dart analyze`
  * Purpose: Verify all renaming and import updates are correct
  * *Requirements: All tests pass, no analyzer errors*
  * *Prompt: Run `flutter test` to verify all tests pass after renaming. Run `dart analyze` to verify no analyzer errors. If any failures, fix import paths. All tests must pass before proceeding to Phase 1.*
* [x] 0.7. Update code organization documentation
  * File: `.spec-workflow/specs/day-view/code-organization-analysis.md`
  * Add section documenting completed reorganization
  * Update status from "Recommended" to "Completed"
  * Purpose: Record what was done for future reference
  * *Requirements: Documentation*
  * *Prompt: Update `code-organization-analysis.md` to add "Reorganization Completed" section showing old → new filenames, date completed, and verification that all tests pass. Update recommendation status to "Completed".*

**Phase 0 Status**: ✅ **COMPLETE** - All 7 tasks finished, all tests passing (998/998), zero errors

## Phase 1: Foundation - Time Utilities and Context Objects

* [x] 1\. Create time calculation utilities
  * File: `lib/src/utils/time_utils.dart`
  * Create `timeToOffset()` - converts DateTime to vertical pixel offset
  * Create `offsetToTime()` - converts pixel offset to DateTime with time slot snapping
  * Create `durationToHeight()` - converts Duration to pixel height
  * Create `snapToTimeSlot()` - snaps DateTime to nearest time slot interval
  * Create `snapToNearbyTime()` - snaps to nearby time boundaries (for magnetic snapping)
  * Create `isWithinSnapRange()` - checks if two times are within snap range
  * All functions must be pure (no side effects) and DST-safe
  * Purpose: Core time↔pixel conversion for all rendering and interaction
  * *Leverage: Month View's DST-safe date arithmetic patterns using `DateTime(y, m, d)` constructor*
  * *Requirements: FR-3 (Time slot granularity), FR-12 (Snap-to-time), FR-14 (Drag and resize)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter/Dart Developer specializing in pure functions and date/time arithmetic | Task: Create `lib/src/utils/time_utils.dart` with time↔pixel conversion utilities following design doc `.spec-workflow/specs/day-view/design.md` Component 2. Implement `timeToOffset`, `offsetToTime`, `durationToHeight`, `snapToTimeSlot`, `snapToNearbyTime`, `isWithinSnapRange`. All must be pure functions using DST-safe arithmetic (DateTime constructor, not Duration.days). Add comprehensive dartdoc with examples. | Restrictions: No side effects. No Duration-based day arithmetic. Handle edge cases (before startHour, after endHour). | Success: `dart analyze` clean, all functions pure and tested, DST-safe arithmetic verified. Mark task as \[-] before starting, log with log-implementation tool after completion, mark as \[x].*
* [x] 2\. Create Day View context objects
  * File: `lib/src/widgets/mcal_day_view_contexts.dart`
  * Create `MCalDayHeaderContext` - day of week, date, weekNumber (optional)
  * Create `MCalTimeLabelContext` - hour, minute, formatted time string
  * Create `MCalGridlineContext` - hour, minute, offset, type (hour/major/minor), intervalMinutes
  * Create `MCalTimedEventTileContext` - event, displayDate, columnIndex, totalColumns, startTime, endTime, isDropTargetPreview, dropValid
  * Create `MCalAllDayEventTileContext` - event, displayDate, isDropTargetPreview, dropValid
  * Create `MCalCurrentTimeContext` - currentTime, offset
  * Create `MCalTimeSlotContext` - displayDate, hour, minute, offset, isAllDayArea
  * Create `MCalTimeRegionContext` - region, displayDate, startOffset, height, isBlocked, startTime, endTime
  * Create `MCalDayLayoutContext` - events, displayDate, startHour, endHour, hourHeight, areaWidth
  * All classes immutable with const constructors and full dartdoc
  * Purpose: Type-safe context objects for all builder callbacks
  * *Leverage: Month View's context pattern in `lib/src/widgets/mcal_month_view_contexts.dart`*
  * *Requirements: All functional requirements (builder patterns)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Dart Developer specializing in immutable data structures | Task: Create `lib/src/widgets/mcal_day_view_contexts.dart` with 9 context classes following design doc section "Context Objects". Model after Month View's `MCalDayCellContext`, `MCalEventTileContext` patterns. All classes immutable with const constructors. Add comprehensive dartdoc explaining when each context is provided to builders. | Restrictions: All fields final. Only const constructors. No methods (pure data classes). | Success: `dart analyze` clean, all contexts immutable, follow Month View patterns. Mark task as \[-] before starting, log implementation, mark as \[x].*
* [x] 3\. Create Day View callback detail classes
  * File: `lib/src/widgets/mcal_callback_details.dart` (extend existing)
  * Create `MCalDropOverlayDetails` - highlightedTimeSlots, draggedEvent, proposedStartDate, proposedEndDate, isValid, sourceDate
  * Create `MCalTimeSlotRange` - startTime, endTime, topOffset, height
  * Create `MCalDragSourceDetails` - event, sourceDate, sourceTime, isAllDay
  * Create `MCalDraggedTileDetails` - event, sourceDate, position, isAllDay
  * Extend `MCalEventDroppedDetails` with `typeConversion` field (nullable String: 'allDayToTimed', 'timedToAllDay', null)
  * All classes immutable with const constructors and full dartdoc
  * Purpose: Type-safe detail objects for drag/drop callbacks
  * *Leverage: Existing callback detail patterns in same file (`MCalEventDroppedDetails`, `MCalEventResizedDetails`)*
  * *Requirements: FR-14 (Drag and drop), FR-15 (All-day ↔ Timed conversion)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Dart Developer specializing in data modeling | Task: Extend `lib/src/widgets/mcal_callback_details.dart` with Day View detail classes following design doc section "Callback Detail Extensions". Model after existing `MCalEventDroppedDetails`. Add `typeConversion` field to `MCalEventDroppedDetails` (nullable String for all-day conversion tracking). Add comprehensive dartdoc. | Restrictions: Do NOT modify existing classes except `MCalEventDroppedDetails`. Append to end of file. All new classes immutable. | Success: `dart analyze` clean, new classes follow existing patterns, typeConversion field added correctly. Mark task as \[-], log implementation, mark as \[x].*

## Phase 2: Core Widget Structure and Theme

* [x] 4\. Add Day View theme properties to MCalThemeData
  * File: `lib/src/styles/mcal_theme.dart`
  * Add day header properties: `dayHeaderDayOfWeekStyle`, `dayHeaderDateStyle`
  * Add week number properties: `weekNumberBackgroundColor`, `weekNumberTextColor`, `weekNumberTextStyle`
  * Add time legend properties: `timeLegendWidth`, `timeLegendTextStyle`, `timeLegendBackgroundColor`
  * Add gridline properties: `hourGridlineColor`, `hourGridlineWidth`, `majorGridlineColor`, `majorGridlineWidth`, `minorGridlineColor`, `minorGridlineWidth`
  * Add current time indicator properties: `currentTimeIndicatorColor`, `currentTimeIndicatorWidth`, `currentTimeIndicatorDotRadius`
  * Add timed event properties: `timedEventMinHeight`, `timedEventBorderRadius`, `timedEventPadding`
  * Add special time region properties: `specialTimeRegionColor`, `blockedTimeRegionColor`, `timeRegionBorderColor`, `timeRegionTextColor`, `timeRegionTextStyle`
  * Add all-day section: `allDaySectionMaxRows`
  * Update `copyWith`, `lerp`, and `fromTheme` with sensible defaults from Material 3 theme
  * Purpose: Comprehensive theme support for Day View
  * *Leverage: Existing theme pattern in same file, Month View theme properties*
  * *Requirements: NFR-5 (Theming), all visual customization requirements*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in theming and Material Design | Task: Add Day View theme properties to `MCalThemeData` in `lib/src/styles/mcal_theme.dart` following design doc section "Theme Property Additions". Add \~25 new properties for day header, gridlines, time legend, time regions, etc. Update `copyWith`, `lerp`, and `fromTheme` methods. Use Material 3 ColorScheme for defaults. Add full dartdoc for each property. | Restrictions: Do NOT modify existing Month View theme properties. Maintain theme consistency. | Success: `dart analyze` clean, all properties with sensible defaults, copyWith/lerp updated, Material 3 integration. Mark task as \[-], log implementation, mark as \[x].*
* [x] 5\. Create MCalDayView widget scaffold and public API
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Create `MCalDayView` StatefulWidget with complete public API (\~80 parameters):
    * Core: `controller`, `displayDate`, `startHour`, `endHour`, `timeSlotDuration`, `gridlineInterval`
    * Navigation: `showNavigator`, `navigatorBuilder`, `onNavigatePrevious`, `onNavigateNext`, `onNavigateToday`
    * All-day section: `allDaySectionMaxRows`, `allDayToTimedDuration`, `allDayEventTileBuilder`
    * Drag and drop: `enableDragToMove`, `enableDragToResize`, `dragEdgeNavigationEnabled`, all drag builders and callbacks
    * Snapping: `snapToTimeSlots`, `snapToOtherEvents`, `snapToCurrentTime`, `snapRange`
    * Special regions: `specialTimeRegions`, `timeRegionBuilder`
    * Builders: all 15+ builder callbacks
    * Callbacks: all tap/long-press/hover callbacks
    * Appearance: `showWeekNumber`, `showCurrentTimeIndicator`, `theme`, `locale`
    * Accessibility: `enableKeyboardNavigation`, `autoFocusOnEventTap`, `semanticsLabel`
  * Create `_MCalDayViewState` class with state fields (from design doc)
  * Implement `initState`, `dispose`, `didUpdateWidget` lifecycle methods
  * Add `_resolveTheme`, `_isRTL`, `_resolveDragToResize` helper methods
  * Build method returns basic Column scaffold (Navigator + Expanded placeholder)
  * Purpose: Complete public API surface and widget lifecycle
  * *Leverage: Month View's widget structure in `lib/src/widgets/mcal_month_view.dart` (\~lines 1-800)*
  * *Requirements: All functional requirements*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in widget API design | Task: Create `lib/src/widgets/mcal_day_view.dart` with `MCalDayView` widget and `_MCalDayViewState` following design doc "Public API" and "State Management" sections. Add all \~80 parameters mirroring Month View structure. Implement lifecycle methods, helper methods. Build method returns basic Column scaffold. Add comprehensive dartdoc for every parameter. | Restrictions: Do NOT implement rendering logic yet (Phases 3-7). Just API surface and lifecycle. No child widgets yet. | Success: `dart analyze` clean, widget compiles, all parameters with dartdoc, lifecycle correct. Mark task as \[-], log implementation, mark as \[x].*
* [x] 6\. Export Day View types from multi\_calendar.dart
  * File: `lib/multi_calendar.dart`
  * Export `MCalDayView`
  * Export all Day View context classes (9 classes)
  * Export all Day View detail classes (5 new classes)
  * Export `MCalTimeRegion` data model
  * Purpose: Public API accessibility
  * *Leverage: Existing export pattern in same file*
  * *Requirements: All functional requirements*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Dart Developer | Task: Add Day View exports to `lib/multi_calendar.dart`. Export `MCalDayView`, all context classes from `mcal_day_view_contexts.dart`, detail classes from `mcal_callback_details.dart`, and `MCalTimeRegion`. Follow existing export pattern. | Restrictions: Do NOT change existing exports. Maintain alphabetical grouping. | Success: All Day View types importable from `package:multi_calendar/multi_calendar.dart`. Mark task as \[-], log implementation, mark as \[x].*

## Phase 3: Navigation and Day Header

* [x] 7\. Implement Day Navigator component
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Create `_DayNavigator` private StatelessWidget
  * Layout: Row with IconButton (prev), Text/GestureDetector (date label), IconButton (today), IconButton (next)
  * Wire to callbacks: `onNavigatePrevious`, `onNavigateNext`, `onNavigateToday`
  * Support custom `navigatorBuilder` callback
  * Default styling from theme
  * Semantic labels: "Previous day", "Today", "Next day", "{formatted date}"
  * RTL support for button order
  * Purpose: Day-to-day navigation controls
  * *Leverage: Month View's `_NavigatorWidget` pattern (\~line 5400)*
  * *Requirements: FR-1 (Basic day view structure), FR-17 (Cross-day navigation)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in navigation UI | Task: Create `_DayNavigator` widget in `lib/src/widgets/mcal_day_view.dart` following design doc Component 1. Model after Month View's `_NavigatorWidget`. Add prev/today/next buttons with proper RTL support. Support custom builder callback. Add semantic labels. Wire to parent widget callbacks. | Restrictions: Match Month View patterns. RTL-aware button order. | Success: Navigator renders correctly, buttons work, custom builder supported, RTL correct. Mark task as \[-], log implementation, mark as \[x].*
* [x] 8\. Implement Day Header with optional week number
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Create `_DayHeader` private StatelessWidget
  * Display day of week (e.g., "Monday") and date number (e.g., "14")
  * Optionally display ISO 8601 week number when `showWeekNumber: true`
  * Implement `_calculateISOWeekNumber(DateTime date)` helper using ISO 8601 algorithm
  * Position in top-leading corner (RTL-aware)
  * Support custom `dayHeaderBuilder` callback
  * Default styling from theme (`dayHeaderDayOfWeekStyle`, `dayHeaderDateStyle`, `weekNumberTextStyle`)
  * Semantic label: "Monday, February 14, Week 7" (when week number shown)
  * Purpose: Date identification and optional week context
  * *Leverage: Month View's week number calculation, date formatting with `intl` package*
  * *Requirements: FR-1 (Basic structure), FR-18 (Week number display)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in date formatting | Task: Create `_DayHeader` widget in `lib/src/widgets/mcal_day_view.dart` following design doc Component 4. Display day of week and date. Implement ISO 8601 week number calculation. Support custom builder. RTL-aware positioning. Use intl package for localization. Add comprehensive semantic label. | Restrictions: Week number must follow ISO 8601 standard. RTL positioning correct. | Success: Header renders correctly, week number accurate, RTL works, custom builder supported. Mark task as \[-], log implementation, mark as \[x].*

## Phase 4: Time Legend and Gridlines

* [x] 9\. Implement Time Legend Column
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Create `_TimeLegendColumn` private StatelessWidget
  * Render hour labels (e.g., "9 AM", "2 PM") at each hour boundary
  * Use `intl.DateFormat` for locale-aware time formatting
  * Vertical positioning matches gridline layer (uses `timeToOffset`)
  * Support custom `timeLabelBuilder` callback
  * Support `onTimeLabelTap` callback
  * Default width from theme (`timeLegendWidth`)
  * Semantic labels for each hour
  * Purpose: Time scale reference for events
  * *Leverage: Time utilities from Task 1, intl package for formatting*
  * *Requirements: FR-1 (Basic structure), NFR-4 (i18n)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in internationalization | Task: Create `_TimeLegendColumn` widget in `lib/src/widgets/mcal_day_view.dart` following design doc Component 6. Render hour labels using `timeToOffset` for positioning. Use intl.DateFormat for locale-aware formatting. Support custom builder and tap callback. Add semantic labels. | Restrictions: Must use time utilities from Task 1. Locale-aware formatting required. | Success: Time labels render at correct positions, locale formatting works, custom builder supported, tappable. Mark task as \[-], log implementation, mark as \[x].*
* [x] 10\. Implement Gridlines Layer with configurable intervals
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Create `_GridlinesLayer` private StatelessWidget
  * Render horizontal lines at configured `gridlineInterval` (1, 5, 10, 15, 20, 30, or 60 minutes)
  * Classify gridlines: `MCalGridlineType.hour` (on the hour), `MCalGridlineType.major` (30 min), `MCalGridlineType.minor` (other intervals)
  * Use different colors/widths from theme: `hourGridlineColor/Width`, `majorGridlineColor/Width`, `minorGridlineColor/Width`
  * Support custom `gridlineBuilder` callback with `MCalGridlineContext`
  * Use CustomPainter for performance
  * Purpose: Visual time scale with customizable granularity
  * *Leverage: Time utilities from Task 1, CustomPainter for efficient rendering*
  * *Requirements: FR-2 (Configurable gridlines), FR-3 (Time slot granularity)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in CustomPainter | Task: Create `_GridlinesLayer` widget in `lib/src/widgets/mcal_day_view.dart` following design doc Component 7. Render gridlines at configured interval. Classify as hour/major/minor. Use CustomPainter for performance. Support custom builder. Provide full context object. | Restrictions: Must use CustomPainter. Interval must be validated (1/5/10/15/20/30/60 min only). | Success: Gridlines render at correct intervals, different styles per type, custom builder works, performant. Mark task as \[-], log implementation, mark as \[x].*

## Phase 5: Current Time Indicator

* [x] 11\. Implement Current Time Indicator with live updates
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Create `_CurrentTimeIndicator` private StatefulWidget with timer
  * Render horizontal line at current time position (using `timeToOffset`)
  * Add leading dot (circle) at RTL-aware edge
  * Timer updates every minute (not continuously)
  * Support custom `currentTimeIndicatorBuilder` callback
  * Styling from theme: `currentTimeIndicatorColor`, `currentTimeIndicatorWidth`, `currentTimeIndicatorDotRadius`
  * Semantic label: "Current time: {formatted time}"
  * Cancel timer in `dispose()`
  * Purpose: Live current time reference
  * *Leverage: Time utilities from Task 1, Timer for updates*
  * *Requirements: FR-1 (Basic structure), FR-8 (Current time indicator)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in real-time UI | Task: Create `_CurrentTimeIndicator` StatefulWidget in `lib/src/widgets/mcal_day_view.dart` following design doc Component 8. Render horizontal line at current time using `timeToOffset`. Add timer that fires every minute. Support custom builder. RTL-aware dot position. Cancel timer in dispose. Add semantic label. | Restrictions: Timer must fire every 60 seconds, not continuously. Must cancel in dispose. | Success: Indicator renders at current time, updates every minute, timer cleaned up, RTL works, custom builder supported. Mark task as \[-], log implementation, mark as \[x].*

## Phase 6: Special Time Regions

* [x] 12\. Create MCalTimeRegion data model
  * File: `lib/src/models/mcal_time_region.dart` (new)
  * Create `MCalTimeRegion` class with fields: `id`, `startTime`, `endTime`, `color`, `text`, `blockInteraction`, `recurrenceRule`, `icon`, `customData`
  * Implement `contains(DateTime time)` method
  * Implement `overlaps(DateTime start, DateTime end)` method
  * Support recurring regions via `recurrenceRule` (daily lunch, weekends, etc.)
  * Immutable with const constructor
  * Comprehensive dartdoc with examples
  * Purpose: Data model for special time regions (non-working hours, blocked slots, etc.)
  * *Leverage: Existing model patterns, RFC 5545 RRULE support from controller*
  * *Requirements: FR-13 (Special time regions)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Dart Developer specializing in data modeling | Task: Create `lib/src/models/mcal_time_region.dart` with `MCalTimeRegion` class following design doc "Data Models" section. Add all fields, contains/overlaps methods. Support recurrence. Immutable with const constructor. Add comprehensive dartdoc with examples (lunch break, non-working hours, blocked time). | Restrictions: Immutable class. Only pure methods. | Success: `dart analyze` clean, class is immutable, methods work correctly, good dartdoc. Mark task as \[-], log implementation, mark as \[x].*
* [x] 13\. Implement Special Time Regions Layer
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Create `_TimeRegionsLayer` private StatelessWidget
  * Filter regions applicable to display date (including recurring region expansion)
  * Render each region as positioned colored overlay using `timeToOffset` and `durationToHeight`
  * Support custom `timeRegionBuilder` callback with `MCalTimeRegionContext`
  * Default styling: region color, border, optional text/icon
  * Different default colors for `blockInteraction: true` vs false (from theme)
  * Render below events layer but above gridlines
  * Purpose: Visual indication of special time periods
  * *Leverage: Time utilities from Task 1, time region model from Task 12*
  * *Requirements: FR-13 (Special time regions)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in overlays | Task: Create `_TimeRegionsLayer` widget in `lib/src/widgets/mcal_day_view.dart` following design doc Component 5a. Filter applicable regions for display date. Expand recurring regions. Render as positioned colored overlays. Support custom builder. Use theme colors for blocked vs non-blocked. Position correctly using time utilities. | Restrictions: Must handle recurring regions. Must expand RRULE for display date. Blocked regions use different color. | Success: Regions render at correct positions, recurring regions work, custom builder supported, blocked regions visually distinct. Mark task as \[-], log implementation, mark as \[x].*

## Phase 7: All-Day Events Section

* [x] 14\. Implement All-Day Events Section
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Create `_AllDayEventsSection` private StatelessWidget
  * Layout all-day events in rows (max rows from `allDaySectionMaxRows` theme property)
  * Wrap events in Wrap widget for flow layout
  * Each event uses `allDayEventTileBuilder` or default tile
  * Support drag-to-move when enabled (wrap in `MCalDraggableEventTile`)
  * Support tap/long-press callbacks
  * Show overflow indicator if events exceed max rows (similar to Month View)
  * Semantic labels for each all-day event
  * Purpose: Display and interact with all-day events
  * *Leverage: Month View's all-day event rendering patterns, `MCalDraggableEventTile` from Task 15*
  * *Requirements: FR-1 (Basic structure), FR-14 (Drag and drop), FR-15 (All-day ↔ Timed conversion)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in event rendering | Task: Create `_AllDayEventsSection` widget in `lib/src/widgets/mcal_day_view.dart` following design doc Component 9. Layout all-day events in Wrap with max rows limit. Use custom builder or default tile. Support drag-to-move via `MCalDraggableEventTile`. Support overflow indicator. Add tap/long-press callbacks. Add semantic labels. | Restrictions: Must respect max rows limit. Must show overflow. Drag must integrate with handler. | Success: All-day events render correctly, overflow works, draggable when enabled, callbacks fire, semantic labels present. Mark task as \[-], log implementation, mark as \[x].*

## Phase 8: Timed Events Rendering (No Interaction Yet)

* [x] 15\. Implement overlap detection algorithm for timed events
  * File: `lib/src/widgets/mcal_day_view.dart` (or separate utility file)
  * Create `detectOverlapsAndAssignColumns()` function
  * Input: List of timed events for the day
  * Algorithm: Sort by start time, detect overlaps, assign column indices
  * Output: List of events with columnIndex and totalColumns
  * Handle nested overlaps (3+ concurrent events)
  * Pure function, no side effects
  * Purpose: Layout events side-by-side when they overlap
  * *Leverage: Interval tree or sweep-line algorithm for O(n log n) performance*
  * *Requirements: FR-9 (Event overlap layout)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Algorithm Developer specializing in interval problems | Task: Implement `detectOverlapsAndAssignColumns` function in `lib/src/widgets/mcal_day_view.dart` following design doc Component 10. Sort events by start, detect overlaps, assign column indices for side-by-side layout. Handle nested overlaps. O(n log n) or better. Pure function. Add comprehensive dartdoc with examples. | Restrictions: Must be pure function. Must handle all overlap cases. Optimal complexity. | Success: Function works for all overlap patterns (2-way, 3-way, nested), efficient, well-documented. Mark task as \[-], log implementation, mark as \[x].*
* [x] 16\. Implement Timed Events Layer (static rendering)
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Create `_TimedEventsLayer` private StatelessWidget
  * Use overlap detection from Task 15 to calculate column layout
  * Support custom `dayLayoutBuilder` callback for full layout control
  * Default layout: render events in columns using Stack with Positioned
  * Each event positioned using `timeToOffset` (top), `durationToHeight` (height), column width calculations
  * Use `timedEventTileBuilder` or default tile for each event
  * Apply `timedEventMinHeight` from theme
  * Semantic labels for each event: "{title}, {start time} to {end time}, {duration}"
  * Purpose: Render timed events at correct vertical positions
  * *Leverage: Time utilities from Task 1, overlap detection from Task 15, Month View's event tile patterns*
  * *Requirements: FR-1 (Basic structure), FR-9 (Event overlap layout)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in complex layouts | Task: Create `_TimedEventsLayer` widget in `lib/src/widgets/mcal_day_view.dart` following design doc Component 10. Use overlap detection to calculate columns. Support custom layout builder. Default: Stack with Positioned events. Use time utilities for positioning. Apply min height. Add semantic labels. | Restrictions: Do NOT add drag/resize yet (Phase 9-10). Static rendering only. Must support custom layout builder. | Success: Events render at correct positions, overlaps show side-by-side, custom builder works, semantic labels present. Mark task as \[-], log implementation, mark as \[x].*

## Phase 9: Drag and Drop - Basic Structure

* [x] 17\. Integrate MCalDragHandler and add drag state to Day View
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Add drag state fields to `_MCalDayViewState`: `_dragHandler`, `_isDragActive`, `_isResizeActive`
  * Add debouncing state (matching Month View): `_latestDragDetails`, `_dragMoveDebounceTimer`, `_layoutCachedForDrag`
  * Create `_ensureDragHandler` lazy getter
  * Implement `_cacheLayoutForDrag()` method
  * Add `_handleDragStarted()`, `_handleDragEnded()`, `_handleDragCancelled()` callbacks
  * Wire to controller and widget callbacks
  * Purpose: Drag state management infrastructure
  * *Leverage: Month View's drag handler integration pattern (\~lines 1450-1550), `MCalDragHandler` from existing codebase*
  * *Requirements: FR-14 (Drag and drop)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in state management | Task: Add drag state to `_MCalDayViewState` in `lib/src/widgets/mcal_day_view.dart` following design doc "State Management" section and Month View pattern. Add drag handler, debouncing fields, lazy getter. Implement drag lifecycle callbacks. Wire to controller. | Restrictions: EXACTLY match Month View's debouncing pattern. Do NOT implement drag gestures yet (Task 19). | Success: Drag state fields present, handler integrates correctly, lifecycle callbacks wired. Mark task as \[-], log implementation, mark as \[x].*
* [x] 18\. Add DragTarget wrapper to timed events area
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Wrap timed events area in `DragTarget<MCalDragData>`
  * Implement `onMove`, `onLeave`, `onAcceptWithDetails` callbacks (placeholder implementations)
  * Wire to drag handler methods (to be implemented in next tasks)
  * Add global key `_timedEventsAreaKey` for layout access
  * Purpose: Unified drag target for entire day view
  * *Leverage: Month View's DragTarget pattern (\~lines 4958-5036)*
  * *Requirements: FR-14 (Drag and drop)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in drag and drop | Task: Wrap timed events area with `DragTarget<MCalDragData>` in `lib/src/widgets/mcal_day_view.dart` following Month View pattern. Add `onMove`, `onLeave`, `onAcceptWithDetails` with placeholder implementations. Add global key for layout access. | Restrictions: EXACTLY match Month View's DragTarget structure. Placeholder implementations only (will be filled in Tasks 19-21). | Success: DragTarget wraps timed events area, callbacks present (empty), key added. Mark task as \[-], log implementation, mark as \[x].*

## Phase 10: Drag and Drop - Debounced Handlers

* [x] 19\. Implement debounced drag handlers (matching Month View pattern)
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Implement `_handleDragMove(DragTargetDetails details)` - stores latest details, starts debounce timer (16ms)
  * Implement `_processDragMove()` - debounced processor (called max once per 16ms):
    * Cache layout if not cached
    * Convert global position to local
    * Detect section crossing (all-day ↔ timed)
    * Call appropriate handler (see Task 20)
    * Check horizontal edge proximity for cross-day navigation
  * Implement `_handleDragLeave()` - cancels timer, clears details, clears proposed range
  * Implement `_handleDrop(DragTargetDetails details)` - cancels edge nav, flushes timer, validates, calls user callback, updates controller
  * Purpose: 60fps drag performance with debounced calculations
  * *Leverage: Month View's debounced drag pattern EXACTLY (\~lines 4084-4362)*
  * *Requirements: FR-14 (Drag and drop), FR-17 (Cross-day navigation), NFR-2 (Performance)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in performance optimization | Task: Implement debounced drag handlers in `lib/src/widgets/mcal_day_view.dart` EXACTLY matching Month View pattern (lines 4084-4362). Implement `_handleDragMove`, `_processDragMove`, `_handleDragLeave`, `_handleDrop`. Use 16ms debounce timer. Follow design doc "Drag Handling" section precisely. | Restrictions: MUST match Month View debouncing pattern exactly. MUST use 16ms timer. MUST flush on drop. | Success: Drag handlers work at 60fps, debouncing correct, edge cases handled, matches Month View architecture. Mark task as \[-], log implementation, mark as \[x].*
* [x] 20\. Implement drag move calculations and validation
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Implement `_handleSameTypeMove(Offset localPosition)` - calculate new time from Y offset, apply snapping, validate
  * Implement `_handleTimedToAllDayConversion(Offset localPosition)` - convert to all-day (midnight times)
  * Implement `_handleAllDayToTimedConversion(Offset localPosition)` - convert to timed (calculate time from Y, use configured duration)
  * Implement `_checkHorizontalEdgeProximity(double x)` - trigger day navigation when near edge
  * Implement `_validateDrop()` - check user callback, blocked regions, date boundaries
  * Implement snapping helpers: `_applySnapping()`, `_findNearbyEventBoundary()`
  * All date arithmetic must be DST-safe (use `DateTime(y, m, d, h, m)`)
  * Purpose: Calculate proposed dates during drag with validation
  * *Leverage: Time utilities from Task 1, time region model from Task 12, Month View's validation pattern*
  * *Requirements: FR-12 (Snap-to-time), FR-13 (Special time regions), FR-14 (Drag and drop), FR-15 (All-day ↔ Timed conversion), FR-17 (Cross-day navigation)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in gesture calculations | Task: Implement drag calculation methods in `lib/src/widgets/mcal_day_view.dart` following design doc "Drag Handling" section. Implement same-type move, type conversion, edge proximity, validation, snapping. Use DST-safe arithmetic. Use time utilities. Check blocked regions. | Restrictions: MUST use DST-safe arithmetic (DateTime constructor). MUST apply snapping. MUST validate against blocked regions. | Success: Drag calculations correct, snapping works, type conversion works, validation blocks invalid drops, edge navigation triggers. Mark task as \[-], log implementation, mark as \[x].*

## Phase 11: Drag and Drop - Preview Layers (Match Month View Architecture)

* [x] 21\. Implement drop target preview and overlay layers
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Implement `_buildTimedEventsArea()` method returning Stack with DragTarget:
    * Layer 1+2: Main content (gridlines + regions + events + current time)
    * Layer 3: `_buildDropTargetPreviewLayer()` wrapped in ListenableBuilder + RepaintBoundary + IgnorePointer
    * Layer 4: `_buildDropTargetOverlayLayer()` wrapped in ListenableBuilder + RepaintBoundary + IgnorePointer
  * Implement `_buildDropTargetPreviewLayer(BuildContext)`:
    * Shows phantom event tile at proposed position
    * Uses `dropTargetTileBuilder` or default preview
    * Only visible when drag handler has valid proposed range
  * Implement `_buildDropTargetOverlayLayer(BuildContext)`:
    * Highlights time slot range being targeted
    * Uses `dropTargetOverlayBuilder` or default CustomPainter
    * Semi-transparent colored overlay (blue if valid, red if invalid)
  * Support `dropTargetTilesAboveOverlay` flag to swap Layer 3/4 order
  * Add semantics at DragTarget level with drop target range announcement
  * Purpose: Real-time drag feedback matching Month View architecture
  * *Leverage: Month View's Stack architecture EXACTLY (\~lines 5016-5024, 4672-4863)*
  * *Requirements: FR-14 (Drag and drop), NFR-2 (Performance)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in complex UI rendering | Task: Implement `_buildTimedEventsArea` with 3-layer Stack in `lib/src/widgets/mcal_day_view.dart` EXACTLY matching Month View architecture (lines 5016-5024). Implement preview and overlay layers with ListenableBuilder wrappers. Follow design doc "Stack Build Pattern" section precisely. Support layer order toggle. Add semantics. | Restrictions: MUST match Month View Stack architecture exactly. MUST use ListenableBuilder. MUST use RepaintBoundary + IgnorePointer. | Success: Stack structure matches Month View, preview shows during drag, overlay highlights correctly, no performance issues. Mark task as \[-], log implementation, mark as \[x].*
* [x] 22\. Make timed events draggable using MCalDraggableEventTile
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Wrap each timed event tile in `MCalDraggableEventTile` when `enableDragToMove: true`
  * Pass `draggedTileBuilder` and `dragSourceTileBuilder` to wrapper
  * Wire `onDragStarted`, `onDragEnd`, `onDragCanceled` callbacks to drag handler
  * Pass event and source date to wrapper
  * Purpose: Enable LongPressDraggable on timed events
  * *Leverage: Existing `MCalDraggableEventTile` widget (\~line 6544 in Month View), already supports time-based drag data*
  * *Requirements: FR-14 (Drag and drop)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Wrap timed event tiles in `MCalDraggableEventTile` in `lib/src/widgets/mcal_day_view.dart` when drag enabled. Use existing widget from Month View. Pass builders and callbacks. Follow Month View pattern for wrapping event tiles. | Restrictions: Reuse existing `MCalDraggableEventTile` widget. Do NOT create new wrapper. | Success: Timed events are draggable with long-press, feedback tile follows cursor, source tile shows drag state. Mark task as \[-], log implementation, mark as \[x].*
* [x] 23\. Make all-day events draggable
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Wrap all-day event tiles in `MCalDraggableEventTile` when `enableDragToMove: true`
  * Same pattern as Task 22 but for all-day section
  * Purpose: Enable drag from/to all-day section
  * *Leverage: Same `MCalDraggableEventTile` widget*
  * *Requirements: FR-14 (Drag and drop), FR-15 (All-day ↔ Timed conversion)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Wrap all-day event tiles in `MCalDraggableEventTile` in `lib/src/widgets/mcal_day_view.dart` when drag enabled. Same pattern as timed events. | Restrictions: Reuse existing widget. | Success: All-day events draggable, can drag between all-day and timed sections, type conversion works. Mark task as \[-], log implementation, mark as \[x].*
* [x] 23.5. Verify drag visual feedback works correctly
  * Role: QA Engineer specializing in Flutter testing
  * Context: Phase 11 of day-view spec. Tasks 21-22 are complete. Need to verify the drag system works end-to-end.
  * Manually test drag operations (run example app)
  * Verify preview layer shows phantom event during drag
  * Verify overlay layer highlights drop target
  * Verify snap-to-grid aligns to gridline intervals
  * Verify invalid drops show red overlay
  * Verify valid drops show blue overlay
  * Test all-day to timed drag and vice versa
  * Check accessibility announcements during drag
  * *Requirements: FR-14 (Drag and drop), NFR-1 (Accessibility), NFR-2 (Performance)*
  * *Leverage: Example app, browser testing tools if needed*
  * *Success: All drag operations work smoothly, visual feedback is clear, no errors, accessible.*

## Phase 12: Drag to Resize

* [x] 24\. Add resize gesture tracking in parent Listener
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Wrap entire Day View content in `Listener` (outside DragTarget Stack)
  * Implement `_handleResizePointerMoveFromParent(PointerMoveEvent)`
  * Implement `_handleResizePointerUpFromParent(PointerUpEvent)`
  * Implement `_handleResizePointerCancelFromParent(PointerCancelEvent)`
  * Track resize state that survives scroll and navigation
  * Purpose: Pointer tracking for resize gestures outside Stack
  * *Leverage: Month View's Listener pattern EXACTLY (\~lines 1689-1703)*
  * *Requirements: FR-14 (Drag and drop - resize)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in gesture handling | Task: Add Listener wrapper around Day View content in `lib/src/widgets/mcal_day_view.dart` EXACTLY matching Month View pattern (lines 1689-1703). Implement pointer handlers for resize tracking. Place outside DragTarget Stack so it survives scroll/navigation. Follow design doc "Resize Gesture Tracking" section. | Restrictions: MUST match Month View Listener structure. MUST wrap entire content. Listener OUTSIDE Stack. | Success: Listener wraps content, pointer handlers present, resize tracking survives scroll. Mark task as \[-], log implementation, mark as \[x].*
* [x] 25\. Implement resize handles on timed event tiles
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Create `_ResizeHandle` private widget (similar to Month View but vertical)
  * Position handles at top and bottom edges of timed event tiles
  * Use `GestureDetector` with `onVerticalDragStart/Update/End/Cancel`
  * Visual: subtle horizontal line/grip that appears on hover
  * Cursor: `SystemMouseCursors.resizeRow` on hover-capable platforms
  * Only show on non-all-day events when `enableDragToResize` resolves to true
  * Semantic labels: "Resize start time" / "Resize end time"
  * Purpose: Interactive resize affordance on event edges
  * *Leverage: Month View's `_ResizeHandle` pattern (\~line 4600), but adapted for vertical (time-based) resize*
  * *Requirements: FR-14 (Drag and drop - resize)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in gesture UI | Task: Create `_ResizeHandle` widget and integrate into timed event tiles in `lib/src/widgets/mcal_day_view.dart`. Model after Month View's horizontal resize handle (line 4600) but adapt for vertical time-based resize. Add top/bottom handles to timed events. Use vertical drag gestures. Add cursor and semantic labels. | Restrictions: Adapt Month View pattern, do NOT duplicate code. Vertical gestures only. Platform-aware cursor. | Success: Handles render on timed event edges, cursor changes on hover, gestures wire up, semantic labels present. Mark task as \[-], log implementation, mark as \[x].*
* [x] 26\. Implement resize interaction logic
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Wire resize handle callbacks to drag handler:
    * `onResizeStart`: call `dragHandler.startResize(event, edge)`
    * `onResizeUpdate(dy)`: accumulate dy, calculate time delta, compute proposed start/end, call validation callback, update drag handler with preview
    * `onResizeEnd`: call `_handleResizeEnd()` (similar to `_handleDrop`)
    * `onResizeCancel`: call `dragHandler.cancelResize()`
  * Implement `_handleResizeEnd()` method:
    * Get final times from `dragHandler.completeResize()`
    * Build `MCalEventResizedDetails`
    * Call `onEventResized` callback
    * Update controller (for recurring: `modifyOccurrence`)
  * Enforce minimum duration (e.g., 15 minutes based on time slot granularity)
  * Apply snapping during resize
  * No cross-day edge navigation during resize (clamp to day boundaries)
  * Purpose: Complete resize interaction with validation and event mutation
  * *Leverage: Month View's resize completion pattern (\~line 2550), Task 20's validation helpers*
  * *Requirements: FR-12 (Snap-to-time), FR-14 (Drag and drop - resize)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in gesture calculations | Task: Implement resize interaction logic in `lib/src/widgets/mcal_day_view.dart` following design doc. Wire resize handles to drag handler. Implement time delta calculation (DST-safe), validation, snapping, preview updates, completion. Implement `_handleResizeEnd()` mirroring Month View's pattern. Apply minimum duration. | Restrictions: MUST use DST-safe arithmetic. MUST apply snapping. MUST enforce minimum duration. No cross-day resize. | Success: Resize works end-to-end: drag edge → preview shows → release → event updates with new times. Mark task as \[-], log implementation, mark as \[x].*

## Phase 13: Scrolling and Auto-Scroll

* [x] 27\. Implement vertical scrolling with auto-scroll to current time
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Wrap timed events Stack in `SingleChildScrollView`
  * Support external `scrollController` or create internal one
  * Implement `_autoScrollToCurrentTime()` method:
    * Calculate scroll position using `timeToOffset(DateTime.now())`
    * Center current time in viewport
    * Only execute once on initial load (use `_autoScrollDone` flag)
    * Configurable via `autoScrollToCurrentTime` parameter
  * Call auto-scroll in `didChangeDependencies` after first frame
  * Purpose: Navigate to current time for immediate context
  * *Leverage: ScrollController, `timeToOffset` from Task 1*
  * *Requirements: FR-7 (Vertical scrolling)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in scroll behavior | Task: Add vertical scrolling to timed events area in `lib/src/widgets/mcal_day_view.dart`. Wrap in SingleChildScrollView. Implement `_autoScrollToCurrentTime()` that scrolls to current time on first load. Support external or internal controller. Use `timeToOffset` for calculation. Only execute once. | Restrictions: Only auto-scroll once. Must support external controller. Must center current time in viewport. | Success: Vertical scrolling works, auto-scrolls to current time on load (if enabled), respects external controller. Mark task as \[-], log implementation, mark as \[x].*

## Phase 14: Empty Time Slot Gestures

* [x] 28\. Implement empty time slot tap and long-press handlers
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Wrap timed events Stack with `GestureDetector`
  * Implement `_handleTimeSlotTap(Offset localPosition)` - convert position to DateTime, call `onTimeSlotTap` callback
  * Implement `_handleTimeSlotLongPress(Offset localPosition)` - convert position to DateTime, call `onTimeSlotLongPress` callback
  * Implement `_didTapHitEvent(Offset position)` - check if tap hit an event (event tap takes precedence)
  * Use `offsetToTime` utility to convert position to DateTime
  * Build `MCalTimeSlotContext` with date, time, offset, and `isAllDayArea: false`
  * Purpose: Enable event creation gestures on empty time slots
  * *Leverage: Month View's empty cell gesture pattern, `offsetToTime` from Task 1*
  * *Requirements: FR-19 (Empty space tap/long press handlers)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in gesture handling | Task: Add GestureDetector around timed events Stack in `lib/src/widgets/mcal_day_view.dart` following design doc Component 8a. Implement tap and long-press handlers that convert position to DateTime using `offsetToTime`. Check if tap hit event first. Build context object. Call user callbacks. | Restrictions: Event taps must take precedence over empty slot taps. Must use `offsetToTime` utility. | Success: Empty time slot taps work, long press works, event taps still work (precedence), callbacks receive correct time. Mark task as \[-], log implementation, mark as \[x].*
* [x] 28.5. Implement double-tap gesture for quick event creation
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Add `onDoubleTap` to the GestureDetector from Task 28
  * Convert tap position to time using `offsetToTime()`
  * Fire `onEmptySpaceDoubleTap(DateTime time)` callback
  * Typical use case: Create event dialog
  * Ensure it doesn't conflict with single tap
  * Add semantic action for double-tap
  * *Leverage: offsetToTime utility, GestureDetector double-tap support*
  * *Requirements: FR-6 (Tap empty space to create event)*
  * *Success: Double-tap on empty area fires callback with correct time, works alongside single tap.*
* [x] 29\. Implement all-day section tap and long-press handlers
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Add GestureDetector around all-day section
  * Implement similar tap/long-press handlers for all-day area
  * Build `MCalTimeSlotContext` with `isAllDayArea: true`
  * Purpose: Enable all-day event creation gestures
  * *Leverage: Task 28 pattern*
  * *Requirements: FR-19 (Empty space tap/long press handlers)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Add tap/long-press handlers to all-day section in `lib/src/widgets/mcal_day_view.dart`. Same pattern as Task 28. Check if tap hit event. Build context with `isAllDayArea: true`. Call callbacks. | Restrictions: Event taps must take precedence. | Success: All-day section taps work, callbacks receive correct context with isAllDayArea flag. Mark task as \[-], log implementation, mark as \[x].*

## Phase 15: Keyboard Navigation

* [x] 30\. Implement keyboard event focus and navigation
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Wrap entire Day View in `Focus` widget with `FocusNode`
  * Implement `_handleKeyEvent(KeyEvent)` method
  * Arrow Up/Down: Navigate between events vertically (chronologically)
  * Tab/Shift+Tab: Navigate between events (forward/backward)
  * Enter/Space: Activate focused event (call `onEventTap`)
  * Escape: Clear focus or cancel keyboard operation
  * Track `_focusedEvent` and `_focusedEventIndex` in state
  * Add visual focus indicator (border/outline) on focused event
  * Purpose: Keyboard alternative to mouse/touch for event navigation
  * *Leverage: Month View's keyboard navigation pattern (\~line 1442), Flutter's Focus widget*
  * *Requirements: FR-11 (Keyboard navigation), NFR-6 (Accessibility)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in accessibility | Task: Add keyboard navigation to Day View in `lib/src/widgets/mcal_day_view.dart` following design doc. Wrap in Focus widget. Implement `_handleKeyEvent` for arrow/tab/enter/escape keys. Navigate between events chronologically. Add visual focus indicator. Track focused event state. | Restrictions: Must wrap entire widget in Focus. Must handle all specified keys. Focus indicator must be visible. | Success: Arrow keys navigate events, Tab cycles forward, Shift+Tab backward, Enter activates, Escape clears, focus indicator visible. Mark task as \[-], log implementation, mark as \[x].*
* [x] 31\. Implement keyboard shortcuts (Cmd/Ctrl+N for new event, etc.)
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Add keyboard shortcuts using `Shortcuts` and `Actions` widgets
  * Cmd/Ctrl+N: Fire `onCreateEventRequested` callback
  * Cmd/Ctrl+D: Fire `onDeleteEventRequested` for focused event
  * Cmd/Ctrl+E: Fire `onEditEventRequested` for focused event
  * Delete/Backspace: Fire `onDeleteEventRequested` for focused event
  * Support customizable shortcuts via `keyboardShortcuts` parameter
  * *Leverage: Flutter Shortcuts/Actions pattern, existing Focus widget*
  * *Requirements: NFR-1 (Accessibility), FR-6 (Quick event creation)*
  * *Success: Shortcuts work on all platforms, actions fire with correct context, customizable.*
* [x] 32.5. Verify screen reader announcements for all interactions
  * Role: Accessibility QA Engineer
  * Context: Phase 15 of day-view spec. Need to audit and verify all accessibility features.
  * Review all semantic labels and hints added in previous tasks
  * Test with screen reader (VoiceOver on macOS/iOS, TalkBack on Android)
  * Verify announcements for: time legend hours, gridlines (optional), events, drag operations, resize operations, empty slot gestures, keyboard navigation
  * Add missing semantic labels where needed
  * Ensure proper focus order
  * *Requirements: NFR-1 (Accessibility), WCAG 2.1 Level AA compliance*
  * *Leverage: Semantics widget, SemanticsService, existing labels*
  * *Success: All interactions are accessible, proper announcements, logical focus order.*
* [x] 32\. Implement keyboard event moving (reusing drag infrastructure)
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Add keyboard move mode state: `_isKeyboardMoveMode`, `_keyboardMoveEvent`, `_keyboardMoveOriginalStart`, `_keyboardMoveOriginalEnd`
  * When focused event + Ctrl+M (or similar): enter move mode
  * Arrow Up/Down: Move event up/down by time slot increments
  * Arrow Left/Right: Move event to previous/next day
  * Enter: Confirm move (reuse `_handleDrop` flow)
  * Escape: Cancel move
  * Reuse `MCalDragHandler.startDrag/updateDrag/completeDrag` for state and preview
  * Announce each step via `SemanticsService`
  * Purpose: Keyboard alternative to drag-and-drop
  * *Leverage: Month View's keyboard move pattern (\~line 1442-2237), drag handler from Phase 9*
  * *Requirements: FR-11 (Keyboard navigation), FR-14 (Drag and drop), NFR-6 (Accessibility)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in accessibility | Task: Implement keyboard event moving in `lib/src/widgets/mcal_day_view.dart` following design doc Component 7 and Month View pattern. Add move mode state. Arrow keys move event in time or across days. Reuse drag handler for preview. Enter confirms via `_handleDrop`. Escape cancels. Add screen reader announcements. | Restrictions: MUST reuse existing drag handler and `_handleDrop`. Do NOT duplicate drop logic. MUST announce each step. | Success: Keyboard move works: select event → enter move mode → arrow keys → preview shows → Enter confirms → event moves. Announcements at each step. Mark task as \[-], log implementation, mark as \[x].*
* [x] 33\. Implement keyboard event resizing
  * File: `lib/src/widgets/mcal_day_view.dart`
  * Add keyboard resize mode state: `_isKeyboardResizeMode`, `_keyboardResizeEdge`
  * When focused event + Ctrl+R: enter resize mode, choose edge (start vs end)
  * Arrow Up: Decrease time (move start later or end earlier)
  * Arrow Down: Increase time (move start earlier or end later)
  * Tab: Switch between start and end edge
  * Enter: Confirm resize (reuse `_handleResizeEnd` flow)
  * Escape: Cancel resize
  * Reuse `MCalDragHandler.startResize/updateResize/completeResize`
  * Announce each step via `SemanticsService`
  * Purpose: Keyboard alternative to edge-drag resize
  * *Leverage: Month View's keyboard resize pattern, drag handler resize state from Phase 12*
  * *Requirements: FR-11 (Keyboard navigation), FR-14 (Drag and drop - resize), NFR-6 (Accessibility)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in accessibility | Task: Implement keyboard event resizing in `lib/src/widgets/mcal_day_view.dart`. Add resize mode state. Arrow Up/Down adjust times. Tab switches edge. Reuse drag handler resize methods. Enter confirms via `_handleResizeEnd`. Escape cancels. Add announcements. | Restrictions: MUST reuse existing drag handler and `_handleResizeEnd`. MUST announce each step. | Success: Keyboard resize works: select event → enter resize mode → arrow keys → preview shows → Enter confirms → event resizes. Mark task as \[-], log implementation, mark as \[x].*

## Phase 16: Testing - Unit Tests

* [x] 33\. Write unit tests for time utilities
  * File: `test/utils/time_utils_test.dart`
  * Test `timeToOffset` with various times (start hour, end hour, middle, midnight edge cases)
  * Test `offsetToTime` with various offsets and time slot durations
  * Test `durationToHeight` conversion
  * Test `snapToTimeSlot` with different granularities (1, 5, 10, 15, 20, 30, 60 min)
  * Test `snapToNearbyTime` and `isWithinSnapRange`
  * Test DST transitions (verify no Duration-based arithmetic errors)
  * Purpose: Ensure core time↔pixel conversions are accurate
  * *Leverage: Existing test patterns in `test/` directory*
  * *Requirements: All time-related functional requirements, NFR-2 (Performance), NFR-3 (Reliability)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: QA Engineer specializing in unit testing | Task: Create comprehensive unit tests for time utilities in `test/utils/time_utils_test.dart`. Test all functions from Task 1 with various inputs, edge cases, DST transitions. Use existing test patterns. Aim for 100% coverage. | Restrictions: Test all edge cases. Test DST safety. Isolate tests. | Success: All time utility functions tested, 100% coverage, DST tests pass, all tests green. Mark task as \[-], log implementation, mark as \[x].*
* [x] 34\. Write unit tests for overlap detection algorithm
  * File: `test/widgets/mcal_day_view_overlap_test.dart`
  * Test with 0 events, 1 event, 2 overlapping events, 3+ concurrent events
  * Test nested overlaps (A contains B, B overlaps C)
  * Test events at day boundaries (midnight, 23:59)
  * Test column assignment is optimal (no unnecessary columns)
  * Test with various time slot durations
  * Purpose: Ensure overlap detection works for all patterns
  * *Leverage: Existing widget test patterns*
  * *Requirements: FR-9 (Event overlap layout), NFR-2 (Performance), NFR-3 (Reliability)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: QA Engineer specializing in algorithm testing | Task: Create unit tests for overlap detection in `test/widgets/mcal_day_view_overlap_test.dart`. Test all overlap patterns (0, 1, 2, 3+ concurrent, nested). Test edge cases (boundaries, various durations). Verify column assignments optimal. | Restrictions: Test all overlap patterns. Verify optimality. | Success: Overlap detection tested comprehensively, all patterns work, edge cases covered, tests green. Mark task as \[-], log implementation, mark as \[x].*
* [x] 35.5. Write unit tests for MCalDragHandler and drag state management
  * File: `test/models/mcal_drag_handler_test.dart`
  * Test `MCalDragHandler` state transitions:
    * Start drag: sets isDragging, draggedEvent
    * Update proposed range: updates proposedRange, notifies listeners
    * Complete drag: clears state, notifies
    * Cancel drag: clears state, notifies
    * Start resize: sets isResizing, resizeEdge (start/end)
    * Resize state management
  * Test validation logic (isProposedDropValid)
  * Test listener notifications
  * Verify state is properly cleared after operations
  * Purpose: Ensure drag/resize state management is correct
  * *Leverage: Flutter test framework, mock listeners*
  * *Requirements: NFR-3 (Test coverage), FR-14 (Drag and drop), FR-16 (Resize)*
  * *Success: All drag handler state transitions tested, validation tested, listeners verified.*
* [x] 35\. Write unit tests for MCalTimeRegion model
  * File: `test/models/mcal_time_region_test.dart`
  * Test `contains` method with various times
  * Test `overlaps` method with various time ranges
  * Test recurring regions (daily, weekly patterns)
  * Test region filtering for specific dates
  * Purpose: Ensure time region model works correctly
  * *Leverage: Existing model test patterns*
  * *Requirements: FR-13 (Special time regions), NFR-3 (Reliability)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: QA Engineer | Task: Create unit tests for `MCalTimeRegion` in `test/models/mcal_time_region_test.dart`. Test contains/overlaps methods. Test recurring regions. Test filtering. Edge cases. | Restrictions: Test recurring patterns thoroughly. | Success: MCalTimeRegion fully tested, recurring regions work, all tests green. Mark task as \[-], log implementation, mark as \[x].*

## Phase 17: Testing - Widget Tests

* [x] 36\. Write widget tests for MCalDayView basic rendering
  * File: `test/widgets/mcal_day_view_test.dart`
  * Test widget creation with minimal parameters
  * Test day header rendering
  * Test time legend rendering
  * Test gridlines rendering with various intervals
  * Test current time indicator rendering
  * Test navigator rendering
  * Test theme application
  * Test RTL layout
  * Purpose: Ensure core widget renders correctly
  * *Leverage: Existing widget test patterns in `test/widgets/`*
  * *Requirements: All basic structure requirements (FR-1 to FR-8), NFR-3 (Reliability)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: QA Engineer specializing in Flutter widget testing | Task: Create widget tests for Day View basic rendering in `test/widgets/mcal_day_view_test.dart`. Test creation, header, legend, gridlines, indicator, navigator, theme, RTL. Use existing widget test patterns. | Restrictions: Test rendering, not interaction yet. | Success: Basic rendering tests pass, all components render correctly, theme applies, RTL works. Mark task as \[-], log implementation, mark as \[x].*
* [x] 37\. Write widget tests for event rendering
  * File: `test/widgets/mcal_day_view_events_test.dart`
  * Test all-day event rendering
  * Test timed event rendering with correct positioning
  * Test overlapping events render side-by-side
  * Test event minimum height enforcement
  * Test event tile builders (custom builders)
  * Test overflow indicator in all-day section
  * Purpose: Ensure events render at correct positions
  * *Leverage: Existing event rendering test patterns*
  * *Requirements: FR-1 (Basic structure), FR-9 (Event overlap layout), NFR-3 (Reliability)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: QA Engineer | Task: Create widget tests for event rendering in `test/widgets/mcal_day_view_events_test.dart`. Test all-day events, timed events, overlaps, positioning, min height, custom builders, overflow. | Restrictions: Use pump and settle. Verify positions. | Success: Event rendering tests pass, positions correct, overlaps work, custom builders applied. Mark task as \[-], log implementation, mark as \[x].*
* [x] 38\. Write widget tests for special time regions
  * File: `test/widgets/mcal_day_view_regions_test.dart`
  * Test region rendering at correct positions
  * Test recurring regions expand correctly for display date
  * Test blocked regions use correct styling
  * Test custom region builder
  * Test regions render below events layer
  * Purpose: Ensure time regions work as expected
  * *Leverage: Existing widget test patterns*
  * *Requirements: FR-13 (Special time regions), NFR-3 (Reliability)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: QA Engineer | Task: Create widget tests for special time regions in `test/widgets/mcal_day_view_regions_test.dart`. Test rendering, recurring expansion, blocked styling, custom builder, layer order. | Restrictions: Test recurring regions thoroughly. | Success: Region tests pass, recurring works, styling correct, custom builder applied. Mark task as \[-], log implementation, mark as \[x].*
* [x] 39\. Write widget tests for drag and drop
  * File: `test/widgets/mcal_day_view_drag_test.dart`
  * Test drag-to-move within day (timed to timed)
  * Test drag across days (horizontal edge detection)
  * Test timed → all-day conversion
  * Test all-day → timed conversion
  * Test drag validation (onDragWillAccept callback)
  * Test blocked region prevents drop
  * Test drag preview layers render during drag
  * Test drag callbacks fire correctly
  * Purpose: Ensure drag-and-drop works end-to-end
  * *Leverage: Month View's drag test patterns, `WidgetTester` gestures*
  * *Requirements: FR-14 (Drag and drop), FR-15 (All-day ↔ Timed conversion), FR-17 (Cross-day navigation), NFR-3 (Reliability)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: QA Engineer specializing in gesture testing | Task: Create drag and drop tests in `test/widgets/mcal_day_view_drag_test.dart`. Test drag within day, across days, type conversion, validation, blocked regions, preview layers, callbacks. Use existing drag test patterns. | Restrictions: Test all drag scenarios. Mock callbacks. | Success: All drag scenarios tested, type conversion works, validation blocks invalid drops, callbacks fire, tests green. Mark task as \[-], log implementation, mark as \[x].*
* [x] 40\. Write widget tests for drag-to-resize
  * File: `test/widgets/mcal_day_view_resize_test.dart`
  * Test resize start time (drag top edge down/up)
  * Test resize end time (drag bottom edge down/up)
  * Test minimum duration enforcement
  * Test snapping during resize
  * Test resize validation callback
  * Test resize preview shows during resize
  * Test resize callbacks fire correctly
  * Purpose: Ensure resize works correctly
  * *Leverage: Month View's resize test patterns*
  * *Requirements: FR-14 (Drag and drop - resize), FR-12 (Snap-to-time), NFR-3 (Reliability)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: QA Engineer | Task: Create resize tests in `test/widgets/mcal_day_view_resize_test.dart`. Test start/end edge resize, minimum duration, snapping, validation, preview, callbacks. Use existing resize test patterns. | Restrictions: Test both edges. Test minimum duration. | Success: All resize scenarios tested, minimum enforced, snapping works, callbacks fire, tests green. Mark task as \[-], log implementation, mark as \[x].*
* [x] 41\. Write widget tests for keyboard navigation
  * File: `test/widgets/mcal_day_view_keyboard_test.dart`
  * Test arrow key event navigation
  * Test Tab/Shift+Tab cycling
  * Test Enter/Space activation
  * Test Escape clears focus
  * Test keyboard move mode (arrow keys → preview → Enter confirms)
  * Test keyboard resize mode
  * Test screen reader announcements (verify SemanticsService calls)
  * Purpose: Ensure keyboard accessibility works
  * *Leverage: Month View's keyboard test patterns*
  * *Requirements: FR-11 (Keyboard navigation), NFR-6 (Accessibility), NFR-3 (Reliability)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: QA Engineer specializing in accessibility testing | Task: Create keyboard navigation tests in `test/widgets/mcal_day_view_keyboard_test.dart`. Test all keyboard operations (arrow, tab, enter, escape), move mode, resize mode, announcements. Use existing keyboard test patterns. | Restrictions: Test all keys. Mock SemanticsService. | Success: All keyboard operations tested, move/resize modes work, announcements verified, tests green. Mark task as \[-], log implementation, mark as \[x].*
* [x] 42\. Write widget tests for snapping functionality
  * File: `test/widgets/mcal_day_view_snapping_test.dart`
  * Test snap to time slots during drag
  * Test snap to other events (magnetic snapping)
  * Test snap to current time indicator
  * Test snap range configuration
  * Test snapping can be disabled per type
  * Purpose: Ensure snapping works correctly
  * *Leverage: Snap utilities from Task 1*
  * *Requirements: FR-12 (Snap-to-time), NFR-3 (Reliability)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: QA Engineer | Task: Create snapping tests in `test/widgets/mcal_day_view_snapping_test.dart`. Test snap to time slots, other events, current time. Test snap range. Test disabling. | Restrictions: Test all snap types. | Success: All snapping scenarios tested, snapping works within range, can be disabled, tests green. Mark task as \[-], log implementation, mark as \[x].*

## Phase 18: Example App Integration

* [x] 43\. Update example app main screen with view selector
  * File: `example/lib/screens/main_screen.dart`
  * Add NavigationRail with two destinations: Month View, Day View
  * Update state to track selected view
  * Update body to show selected view
  * Maintain existing Month View functionality
  * Purpose: Allow users to switch between Month and Day views
  * *Leverage: Existing NavigationRail in example app*
  * *Requirements: Example app requirements*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Update example app main screen in `example/lib/screens/main_screen.dart` to add Day View option to NavigationRail. Add state for selected view. Show Month or Day view based on selection. Maintain existing functionality. | Restrictions: Do NOT break existing Month View. | Success: NavigationRail shows both views, can switch between Month and Day, existing functionality preserved. Mark task as \[-], log implementation, mark as \[x].*
* [x] 44\. Create Day View showcase structure
  * File: `example/lib/views/day_view/day_view_showcase.dart`
  * Create `DayViewShowcase` StatefulWidget
  * Add TabBar with style tabs (Default, Modern, Classic, Minimal, Colorful, Features Demo)
  * Structure mirrors Month View showcase
  * Purpose: Showcase framework for Day View styles
  * *Leverage: Month View showcase structure in `example/lib/views/month_view/month_view_showcase.dart`*
  * *Requirements: Example app requirements*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Create Day View showcase structure in `example/lib/views/day_view/day_view_showcase.dart`. Mirror Month View showcase structure. Add TabBar with 6 style tabs. Create scaffold for style widgets. | Restrictions: Mirror Month View structure exactly. | Success: Showcase renders with TabBar, 6 tabs, structure matches Month View. Mark task as \[-], log implementation, mark as \[x].*
* [x] 44.25. Add interactive examples (create, edit, delete events)
  * Files: `example/lib/views/day_view/`, `example/lib/widgets/`
  * Add event creation dialog (double-tap or Cmd+N)
  * Add event edit dialog (tap event or Cmd+E)
  * Add event delete confirmation (Cmd+D or Delete key)
  * Show snackbars for successful operations
  * Demonstrate proper controller usage (addEvent, updateEvent, deleteEvent)
  * Handle recurring events if applicable
  * Add form validation
  * Purpose: Complete event lifecycle CRUD in Day View example
  * *Leverage: Month View dialog patterns, MCalEventController API*
  * *Requirements: Show complete event lifecycle*
  * *Success: Can create, edit, delete events via UI and keyboard, proper validation.*
* [x] 44.5. Add theme customization demo
  * Files: `example/lib/views/day_view/`
  * Add settings panel or drawer to customize theme properties:
    * Hour height
    * Gridline colors and widths
    * Time slot duration
    * All-day section max rows
    * Event tile styling
    * Resize handle size
  * Show theme changes apply immediately
  * Demonstrate MCalTheme usage
  * Add presets for common configurations
  * *Requirements: FR-4 (Theming), demonstrate customization*
  * *Leverage: MCalTheme system, Flutter UI controls*
  * *Success: Can customize all major theme properties, changes visible immediately.*
* [x] 45\. Create Default style example for Day View
  * File: `example/lib/views/day_view/styles/default_style.dart`
  * Implement Default style: clean, neutral theme with default builders
  * Show basic Day View functionality
  * Add sample events (meetings, appointments)
  * Purpose: Baseline example showing out-of-box experience
  * *Leverage: Month View's default style in `example/lib/views/month_view/styles/default_style.dart`*
  * *Requirements: Example app requirements*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Create Default style for Day View in `example/lib/views/day_view/styles/default_style.dart`. Clean neutral theme, default builders, sample events. Mirror Month View's default style approach. | Restrictions: Use default builders. Clean design. | Success: Default style renders cleanly, shows basic functionality, matches Month View quality. Mark task as \[-], log implementation, mark as \[x].*
* [x] 46\. Create Modern style example for Day View
  * File: `example/lib/views/day_view/styles/modern_style.dart`
  * Implement Modern style: Material 3 design, vibrant colors, rounded corners, shadows
  * Custom event tile builders with modern aesthetics
  * Purpose: Showcase modern design possibilities
  * *Leverage: Month View's modern style*
  * *Requirements: Example app requirements*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer with design sensibility | Task: Create Modern style in `example/lib/views/day_view/styles/modern_style.dart`. Material 3 design, vibrant colors, rounded corners, custom builders. Mirror Month View's modern style quality. | Restrictions: Must use Material 3 design language. | Success: Modern style looks polished, Material 3 aesthetics, custom builders enhance appearance. Mark task as \[-], log implementation, mark as \[x].*
* [x] 47\. Create Classic style example for Day View
  * File: `example/lib/views/day_view/styles/classic_style.dart`
  * Implement Classic style: traditional calendar look, grid emphasis, serif fonts
  * Custom gridline and header builders
  * Purpose: Showcase traditional calendar aesthetics
  * *Leverage: Month View's classic style*
  * *Requirements: Example app requirements*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Create Classic style in `example/lib/views/day_view/styles/classic_style.dart`. Traditional calendar look, grid emphasis, serif fonts, custom builders. Mirror Month View's classic style approach. | Restrictions: Traditional aesthetics. | Success: Classic style looks like traditional paper calendar, grid emphasis, serif fonts. Mark task as \[-], log implementation, mark as \[x].*
* [x] 47.5. Add localization demo (multiple languages)
  * Files: `example/lib/`
  * Add language switcher to example app
  * Support at least 3 languages (English, Spanish, French or similar)
  * Show all text properly localizes: time formats (12h vs 24h), date formats, day names, month names, UI labels
  * Demonstrate RTL support if applicable
  * Use Flutter intl package
  * *Requirements: NFR-4 (Localization), FR-13 (Locale-aware formatting)*
  * *Leverage: Flutter intl, MaterialApp localization*
  * *Success: Can switch languages, all text localizes, proper date/time formatting.*
* [x] 48.5. Add accessibility demo (screen reader testing)
  * Role: Accessibility Specialist
  * Context: Phase 18 of day-view spec. Demonstrate accessibility features.
  * Files: `example/lib/views/day_view/`
  * Add accessibility demo tab or section
  * Document keyboard shortcuts visible in UI
  * Show semantic labels work with screen reader
  * Add accessibility checklist
  * Demonstrate high contrast mode
  * Add screen reader instructions
  * Show keyboard navigation flow
  * *Requirements: NFR-1 (Accessibility), WCAG 2.1 AA*
  * *Leverage: Existing semantic labels, keyboard support*
  * *Success: Accessibility features well documented and demonstrable.*
* [x] 48\. Create Minimal style example for Day View
  * File: `example/lib/views/day_view/styles/minimal_style.dart`
  * Implement Minimal style: clean, spacious, subtle colors, reduced visual noise
  * Hide optional elements (week number, some gridlines)
  * Purpose: Showcase minimalist design
  * *Leverage: Month View's minimal style*
  * *Requirements: Example app requirements*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Create Minimal style in `example/lib/views/day_view/styles/minimal_style.dart`. Clean, spacious, subtle colors, hide optional elements. Mirror Month View's minimal approach. | Restrictions: Minimize visual elements. Spacious. | Success: Minimal style looks clean and spacious, reduced visual noise, elegant. Mark task as \[-], log implementation, mark as \[x].*
* [x] 49\. Add RTL layout demo
  * Files: `example/lib/views/day_view/`
  * Verify Day View works in RTL mode
  * Test with Arabic locale from Task 47.5
  * Ensure all UI elements mirror correctly:
    * Time legend on right side
    * Navigator arrows flip
    * Event tiles align properly
    * Drag/resize handles work in RTL
  * Add RTL-specific test cases if needed
  * Document any RTL-specific behavior
  * *Requirements: NFR-5 (RTL support)*
  * *Leverage: Flutter RTL system, Arabic locale from Task 47.5*
  * *Success: Day View works perfectly in RTL, all features functional.*
* [x] 49.5. Create Colorful style example for Day View
  * File: `example/lib/views/day_view/styles/colorful_style.dart`
  * Implement Colorful style: vibrant event colors, color-coded categories, playful
  * Custom color mapping for different event types
  * Purpose: Showcase color customization
  * *Leverage: Month View's colorful style*
  * *Requirements: Example app requirements*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Create Colorful style in `example/lib/views/day_view/styles/colorful_style.dart`. Vibrant colors, color-coded categories, custom color mapping. Mirror Month View's colorful approach. | Restrictions: Vibrant colors required. | Success: Colorful style is vibrant and playful, color-coded categories, visually appealing. Mark task as \[-], log implementation, mark as \[x].*
* [x] 50\. Create Features Demo style example for Day View
  * File: `example/lib/views/day_view/styles/features_demo_style.dart`
  * Implement Features Demo: showcase ALL Day View features
  * Special time regions (lunch break, non-working hours)
  * Blocked time slots (no meetings zones)
  * Custom builders for all components
  * Snap-to-time demonstrations
  * Week number display
  * All drag/drop scenarios (timed↔timed, timed↔all-day, cross-day)
  * Keyboard navigation hints
  * Purpose: Comprehensive feature showcase for developers
  * *Leverage: Month View's features demo style in `example/lib/views/month_view/styles/features_demo_style.dart`*
  * *Requirements: Example app requirements, ALL functional requirements*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Senior Flutter Developer | Task: Create Features Demo style in `example/lib/views/day_view/styles/features_demo_style.dart`. Showcase ALL Day View features: special regions, blocked slots, snapping, week number, drag scenarios, keyboard nav. Mirror Month View's comprehensive features demo. Add code comments explaining each feature. | Restrictions: MUST demonstrate all features. Add explanatory comments. | Success: Features Demo showcases every Day View feature, well-commented, serves as developer reference. Mark task as \[-], log implementation, mark as \[x].*
* [x] 50.6. Add Month View vs Day View comparison demo
  * Role: Flutter Developer creating comparative demos
  * Context: Phase 18 of day-view spec. Final example app task. Show both views side by side.
  * Files: `example/lib/views/comparison/`
  * Create comparison view showing Month View and Day View side by side
  * Use same controller for both
  * Show how they complement each other
  * Demonstrate clicking day in Month View navigates to Day View
  * Show synchronized event updates
  * Add split view for desktop/tablet
  * Document when to use each view
  * *Success: Can see both views together, navigate between them, changes sync.*
* [x] 50.5. Add performance stress test with many events
  * Role: Performance Engineer creating test scenarios
  * Context: Phase 18 of day-view spec. Demonstrate performance with large datasets.
  * Files: `example/lib/views/day_view/`
  * Create stress test mode with 100-500 events
  * Show Day View handles many overlapping events
  * Add toggle to enable/disable stress test
  * Monitor and display performance metrics if possible
  * Ensure no janky scrolling or rendering
  * Demonstrate efficient rendering with CustomPainter
  * *Leverage: CustomPainter, RepaintBoundary*
  * *Requirements: NFR-2 (Performance), handle large datasets*
  * *Success: Handles 100+ events smoothly, no performance degradation.*

## Phase 19: Documentation and Polish

* [x] 51\. Write comprehensive Day View documentation (docs/day\_view.md)
  * File: `docs/day_view.md` (created)
  * Document Day View features: overview, setup, configuration, event display, drag/drop, resize, time slots, navigation, callbacks, theming, accessibility, RTL
  * Include code examples for common use cases
  * Cross-reference API documentation and README
  * Purpose: Complete user-facing Day View guide
  * *Leverage: Example app, existing Month View docs in README*
  * *Requirements: NFR-7 (Documentation)*
  * *Success: Developers can understand and use Day View from docs alone.*
* [x] 51.1. Add dartdoc comments to all public APIs
  * Files: All Day View source files in `lib/src/`
  * Add dartdoc to MCalDayView, MCalDayViewState, Intent classes
  * Add dartdoc to all context objects (MCalDayLayoutContext, etc.)
  * Add dartdoc to callback typedefs and time utilities
  * Include parameter descriptions, usage examples, return values
  * Cross-reference related APIs
  * Purpose: Complete API documentation for dart doc generation
  * *Leverage: Month View dartdoc as example*
  * *Success: All public APIs documented, dartdoc generates without warnings.*
* [x] 52\. Document best practices and patterns
  * File: `docs/best_practices.md`
  * Document best practices for: Event controller management, Theme organization, Custom builders (when to use, patterns), Performance optimization, Accessibility implementation, Localization setup, Testing strategies, State management with Day View, Integration with backends, Error handling
  * Include do's and don'ts, code examples for each practice, rationale behind recommendations
  * Purpose: Guide developers to optimal usage
  * *Leverage: Example app patterns, test patterns*
  * *Success: Clear guidance on how to use Day View effectively.*
* [x] 53\. Create Day View README section
  * File: `README.md` (add Day View section)
  * Add Day View overview with screenshot
  * List key features
  * Provide quick start code example
  * Link to API documentation
  * Purpose: User-facing documentation
  * *Leverage: Existing Month View README section*
  * *Requirements: NFR-7 (Documentation)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Technical Writer | Task: Add Day View section to README.md. Include overview, screenshot (from example app), feature list, quick start example, API docs link. Match Month View README quality. | Restrictions: Must include screenshot. Code example must compile. | Success: Day View README section complete, screenshot included, example compiles, links work. Mark task as \[-], log implementation, mark as \[x].*
* [x] 54\. Create Day View migration guide
  * File: `docs/day_view_migration.md` (new)
  * Document how to migrate from third-party day view widgets
  * Provide parameter mapping tables
  * Include common patterns and examples
  * Purpose: Help developers adopt Day View
  * *Leverage: Month View as reference for patterns*
  * *Requirements: NFR-7 (Documentation)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Technical Writer | Task: Create Day View migration guide in `docs/day_view_migration.md`. Document migration from common third-party widgets (table\_calendar, syncfusion\_flutter\_calendar, etc.). Provide parameter mapping, pattern examples. | Restrictions: Must include concrete examples. | Success: Migration guide is helpful, parameter mappings clear, examples work. Mark task as \[-], log implementation, mark as \[x].*
* [x] 55\. Create troubleshooting guide for common issues
  * Role: Technical Writer and Support Engineer
  * Context: Phase 19 of day-view spec. Document common issues and solutions.
  * File: `docs/troubleshooting.md` or section in day\_view.md
  * Document common issues: events not appearing, drag/drop not working, resize handles missing, theme not applying, performance issues, overlap layout problems, scroll behavior issues, keyboard shortcuts not working, RTL layout issues
  * For each issue: symptoms, common causes, solutions with code examples, prevention tips
  * Add debugging tips
  * Purpose: Help users solve problems independently
  * *Leverage: Implementation experience, test cases*
  * *Success: Most common issues documented with clear solutions.*
* [x] 55.1. Create upgrade guide from previous package versions
  * Role: Technical Writer creating upgrade documentation
  * Context: Phase 19 of day-view spec. Final documentation task.
  * File: `docs/upgrade_guide.md`
  * Document upgrade steps for users of previous package versions
  * Note any API changes in shared components (MCalEventController, etc.)
  * Document new dependencies if added
  * Show code examples of changes needed
  * Add version compatibility matrix
  * Include deprecation notices
  * Provide migration timeline if applicable
  * Purpose: Help existing users upgrade smoothly
  * *Leverage: CHANGELOG, git history*
  * *Success: Clear upgrade path, minimal friction for existing users.*
* [x] 56\. Run dart analyze and fix all issues
  * Files: All Day View implementation files
  * Run `dart analyze` on project
  * Fix all errors, warnings, and lints
  * Ensure code follows project style guide
  * Purpose: Clean, maintainable code
  * *Requirements: NFR-1 (Code quality), NFR-3 (Reliability)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Code Quality Engineer | Task: Run `dart analyze` on entire project. Fix all errors, warnings, and lint issues in Day View code. Ensure code follows project conventions and style guide. | Restrictions: Zero warnings/errors allowed. | Success: `dart analyze` shows zero issues, code clean and consistent. Mark task as \[-], log implementation, mark as \[x].*
* [x] 57\. Run dart format on all Day View files
  * Files: All Day View implementation files
  * Run `dart format` on all Day View files
  * Verify consistent formatting
  * Purpose: Consistent code style
  * *Requirements: NFR-1 (Code quality)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Developer | Task: Run `dart format .` on project to format all Day View files. Verify formatting applied consistently. | Restrictions: Use standard dart format. | Success: All files formatted consistently, no manual formatting needed. Mark task as \[-], log implementation, mark as \[x].*
* [x] 58\. Run all tests and ensure 100% pass rate
  * Files: All test files
  * Run `flutter test` on entire test suite
  * Fix any failing tests
  * Ensure Day View tests pass
  * Ensure existing Month View tests still pass (no regressions)
  * Purpose: Verify implementation correctness
  * *Requirements: All functional requirements, NFR-3 (Reliability)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: QA Engineer | Task: Run complete test suite with `flutter test`. Fix any failing tests. Ensure all Day View tests pass. Ensure no Month View regressions. Verify 100% pass rate. | Restrictions: All tests must pass. No regressions. | Success: `flutter test` shows 100% pass rate, no regressions, all Day View functionality verified. Mark task as \[-], log implementation, mark as \[x].*
* [x] 59\. Performance testing and optimization
  * Test Day View rendering with 100+ events
  * Measure frame times during scroll (target: 60fps)
  * Measure frame times during drag (target: 60fps with debouncing)
  * Profile memory usage with large event sets
  * Optimize any bottlenecks found
  * Purpose: Ensure performance meets requirements
  * *Leverage: Flutter DevTools for profiling*
  * *Requirements: NFR-2 (Performance)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Performance Engineer | Task: Profile Day View performance with Flutter DevTools. Test with 100+ events. Measure scroll fps, drag fps, memory usage. Optimize bottlenecks. Target: 60fps scroll/drag, `<100MB` memory for 100 events. Document findings. | Restrictions: Must measure objectively. Target 60fps. | Success: Day View maintains 60fps with 100+ events, memory usage reasonable, optimizations documented. Mark task as \[-], log implementation, mark as \[x].*
* [x] 60\. Accessibility audit
  * Test with screen reader (TalkBack on Android, VoiceOver on iOS)
  * Verify all interactive elements are accessible
  * Verify semantic labels are descriptive
  * Test keyboard navigation completely
  * Test with high contrast mode
  * Test with large text sizes
  * Purpose: Ensure accessibility compliance
  * *Requirements: NFR-6 (Accessibility)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Accessibility Specialist | Task: Perform comprehensive accessibility audit on Day View. Test with screen readers on Android/iOS. Test keyboard navigation. Test high contrast, large text. Verify WCAG 2.1 AA compliance. Document issues and fix. | Restrictions: Must test on real devices. WCAG AA compliance required. | Success: Day View is fully accessible, screen reader works, keyboard nav complete, WCAG AA compliant. Mark task as \[-], log implementation, mark as \[x].*

## Phase 20: Final Integration and Release Prep

* [x] 61\. Update CHANGELOG.md
  * File: `CHANGELOG.md`
  * Add new version section with Day View feature
  * Document all new APIs
  * Document breaking changes (if any)
  * Purpose: Release notes for users
  * *Requirements: NFR-7 (Documentation)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Developer | Task: Update CHANGELOG.md with new version section. Document Day View feature, all new APIs (MCalDayView, context classes, detail classes, MCalTimeRegion). Document breaking changes. Follow existing CHANGELOG format. | Restrictions: Follow semantic versioning. Complete API list. | Success: CHANGELOG updated, new APIs documented, follows format, ready for release. Mark task as \[-], log implementation, mark as \[x].*
* [x] 62\. Final review and sign-off for Day View release
  * Role: Project Manager and Tech Lead
  * Context: Phase 20 of day-view spec. Final task - comprehensive review.
  * Review all completed tasks (0-61)
  * Verify all requirements met (FR-1 through FR-16, NFR-1 through NFR-5)
  * Check all documentation complete
  * Verify all tests passing
  * Review code quality
  * Test example app on multiple platforms
  * Create release checklist
  * Document any known issues or limitations
  * Get stakeholder approval if needed
  * Mark spec as complete
  * *Requirements: All FR and NFR requirements met*
  * *Leverage: All previous tasks*
  * *Success: Day View ready for release, all requirements satisfied.*
* [x] 63\. Final code review and cleanup
  * Review all Day View code for consistency
  * Remove any debug prints or commented code
  * Verify all TODOs resolved
  * Ensure naming conventions consistent
  * Verify file organization matches project structure
  * Purpose: Code quality and maintainability
  * *Requirements: NFR-1 (Code quality)*
  * *Prompt: Implement the task for spec day-view, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Senior Developer | Task: Perform final code review of all Day View implementation. Remove debug code, resolve TODOs, check naming consistency, verify file organization. Ensure code quality matches Month View standards. | Restrictions: No debug code. No unresolved TODOs. | Success: Code is clean, consistent, well-organized, ready for production. Mark task as \[-], log implementation, mark as \[x].*

## Task Completion Workflow

For each task:

1. Mark as `[-]` in tasks.md BEFORE starting implementation
2. Read the design doc section(s) referenced in the task
3. Review any *Leverage* files/patterns mentioned
4. Implement following the *Prompt* guidance
5. Test implementation against *Success* criteria
6. Log implementation using log-implementation tool (include artifacts: APIs, components, functions, classes, integrations)
7. Mark as `[x]` in tasks.md AFTER completion

## Progress Tracking

* **Phase 0 (Code Organization)**: Tasks 0.1-0.7 (7 tasks) - **MUST COMPLETE BEFORE CONTINUING**
* **Phase 1 (Foundation)**: Tasks 1-3 (3 tasks) ✅ **COMPLETED**
* **Phase 2 (Core Widget)**: Tasks 4-6 (3 tasks) ✅ **COMPLETED**
* **Phase 3 (Navigation/Header)**: Tasks 7-8 (2 tasks) ✅ **COMPLETED**
* **Phase 4 (Time Legend/Gridlines)**: Tasks 9-10 (2 tasks) ⚠️ **Task 10 INCOMPLETE**
* **Phase 5 (Current Time)**: Task 11 (1 task) ✅ **COMPLETED**
* **Phase 6 (Time Regions)**: Tasks 12-13 (2 tasks) ✅ **COMPLETED**
* **Phase 7 (All-Day Events)**: Task 14 (1 task)
* **Phase 8 (Timed Events)**: Tasks 15-16 (2 tasks) ⚠️ **Task 15 COMPLETED, Task 16 INCOMPLETE**
* **Phase 9 (Drag State)**: Tasks 17-18 (2 tasks) ✅ **COMPLETED**
* **Phase 10 (Drag Handlers)**: Tasks 19-20 (2 tasks) ✅ **COMPLETED**
* **Phase 11 (Drag Previews)**: Tasks 21-23 (3 tasks) ⚠️ **Task 21 IN PROGRESS**
* **Phase 12 (Resize)**: Tasks 24-26 (3 tasks)
* **Phase 13 (Scrolling)**: Task 27 (1 task)
* **Phase 14 (Empty Gestures)**: Tasks 28-29 (2 tasks)
* **Phase 15 (Keyboard)**: Tasks 30-32 (3 tasks)
* **Phase 16 (Unit Tests)**: Tasks 33-35 (3 tasks)
* **Phase 17 (Widget Tests)**: Tasks 36-42 (7 tasks)
* **Phase 18 (Example App)**: Tasks 43-50 (8 tasks)
* **Phase 19 (Documentation)**: Tasks 51-59 (9 tasks)
* **Phase 20 (Release)**: Tasks 60-64 (5 tasks) — Task 62 Final review COMPLETE

**Total: 69 tasks across 21 phases (7 new organization tasks + 62 original)**

**Current Status**: 59+ implementation tasks completed. Task 62 (Final review and sign-off) COMPLETE. Day View ready for release with documented known issues. Remaining: Tasks 60 (accessibility audit), 63 (pubspec version), 64 (code review), 65 (release notes).

**Spec Status**: Day View implementation COMPLETE for core release. See `docs/day_view_release_checklist.md` for release readiness, known issues, and stakeholder sign-off.