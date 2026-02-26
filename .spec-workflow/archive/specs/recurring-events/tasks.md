# Tasks Document: Recurring Events

## Phase 1: Model Layer (wrapper types, no Flutter dependency)

- [x] 1. Create `MCalFrequency` enum and `MCalWeekDay` class
  - File: `lib/src/models/mcal_recurrence_rule.dart` (NEW)
  - Create `MCalFrequency` enum with values: `daily`, `weekly`, `monthly`, `yearly`
  - Create `MCalWeekDay` class with `dayOfWeek` (int), optional `occurrence` (int?), convenience constructors `.every()` and `.nth()`, `copyWith`, `==`, `hashCode`, `toString`
  - Pure Dart — no Flutter dependency
  - Purpose: Foundation types for recurrence rules
  - _Leverage: Follow `MCalCalendarEvent` patterns for `==`/`hashCode`/`toString` in `lib/src/models/mcal_calendar_event.dart`_
  - _Requirements: 1.1, 1.2_
  - _Prompt: Implement the task for spec recurring-events, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Dart Developer specializing in data modeling | Task: Create `MCalFrequency` enum and `MCalWeekDay` class in a new file `lib/src/models/mcal_recurrence_rule.dart` as specified in the design doc `.spec-workflow/specs/recurring-events/design.md` section "MCalFrequency" and "MCalWeekDay". The `MCalWeekDay` class has `dayOfWeek` (int using DateTime.monday..DateTime.sunday), optional `occurrence` (int?, e.g. 1=first, -1=last), convenience constructors `.every(dayOfWeek)` and `.nth(dayOfWeek, n)`, plus `copyWith`, `==`, `hashCode`, `toString`. This is pure Dart, no Flutter import. | Restrictions: Do NOT add MCalRecurrenceRule yet (that is Task 2). Do NOT export from multi_calendar.dart yet (that is Task 6). | Success: File compiles with `dart analyze`, all types have correct constructors and equality. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

- [x] 2. Create `MCalRecurrenceRule` class with `teno_rrule` integration
  - File: `lib/src/models/mcal_recurrence_rule.dart` (append to file from Task 1)
  - Create immutable `MCalRecurrenceRule` class with all fields from design: `frequency`, `interval`, `count`, `until`, `byWeekDays`, `byMonthDays`, `byMonths`, `bySetPositions`, `weekStart`
  - Implement validation: `count` and `until` mutually exclusive (`ArgumentError`), `interval >= 1`
  - Implement `fromRruleString(String)` factory — parse RFC 5545 string using `teno_rrule`, convert to MCal types. Throw `ArgumentError` for unsupported frequencies (SECONDLY, MINUTELY, HOURLY)
  - Implement `toRruleString()` — convert to `teno_rrule` `RecurrenceRule` and serialize
  - Implement `getOccurrences({required DateTime start, required DateTime after, required DateTime before})` — convert to `teno_rrule`, call `between()`, convert results back. Handle `teno_rrule`'s requirements internally (no UTC exposure to consumer)
  - Implement `copyWith`, `==`, `hashCode`, `toString`
  - Add private conversion functions `_toTenoRrule()` and `_fromTenoRrule()`
  - Add `teno_rrule` as a dependency to `pubspec.yaml`
  - Purpose: Core recurrence rule wrapper with RFC 5545 interop
  - _Leverage: `teno_rrule` package API (see design doc for conversion approach). Follow existing `MCalCalendarEvent` patterns._
  - _Requirements: 1.3, 1.4, 1.5, 1.6, 1.7, 1.12, 11.1, 11.2, 11.3, 11.4_
  - _Prompt: Implement the task for spec recurring-events, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Dart Developer specializing in third-party library integration | Task: Add `MCalRecurrenceRule` class to `lib/src/models/mcal_recurrence_rule.dart` (file already has MCalFrequency and MCalWeekDay from Task 1). Follow the design doc `.spec-workflow/specs/recurring-events/design.md` section "MCalRecurrenceRule" exactly. Add `teno_rrule` as a dependency in `pubspec.yaml`. Import `teno_rrule` ONLY in this file. Implement private `_toTenoRrule(DateTime dtStart)` and `_fromTenoRrule(RecurrenceRule)` converters. The `getOccurrences` method creates a `teno_rrule` `RecurrenceRule` from the MCal rule, calls `.between(after, before)`, and returns the dates. Handle teno_rrule's UTC/local requirements internally so consumers pass normal DateTimes. Validate: count+until mutually exclusive (ArgumentError), interval >= 1. fromRruleString throws ArgumentError for SECONDLY/MINUTELY/HOURLY. | Restrictions: Do NOT import teno_rrule anywhere else. Do NOT export from multi_calendar.dart yet. | Success: dart analyze clean, round-trip fromRruleString/toRruleString works, getOccurrences returns correct dates. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

- [x] 3. Create `MCalRecurrenceException` class
  - File: `lib/src/models/mcal_recurrence_exception.dart` (NEW)
  - Create `MCalExceptionType` enum: `deleted`, `rescheduled`, `modified`
  - Create immutable `MCalRecurrenceException` with named constructors: `.deleted(originalDate)`, `.rescheduled(originalDate, newDate)`, `.modified(originalDate, modifiedEvent)`
  - Implement `copyWith`, `==`, `hashCode`, `toString`
  - Pure Dart — no Flutter dependency (but imports `MCalCalendarEvent` for `modifiedEvent`)
  - Purpose: Exception model for recurring event overrides
  - _Leverage: Design doc section "MCalRecurrenceException". Follow MCalCalendarEvent patterns._
  - _Requirements: 1.8, 1.9, 1.10_
  - _Prompt: Implement the task for spec recurring-events, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Dart Developer | Task: Create `MCalExceptionType` enum and `MCalRecurrenceException` class in a new file `lib/src/models/mcal_recurrence_exception.dart` as specified in the design doc `.spec-workflow/specs/recurring-events/design.md` section "MCalRecurrenceException". Use named constructors for type safety: `.deleted(originalDate)`, `.rescheduled(originalDate, newDate)`, `.modified(originalDate, modifiedEvent)`. Include `copyWith`, `==`, `hashCode`, `toString`. | Restrictions: Do NOT export from multi_calendar.dart yet. | Success: dart analyze clean, all constructors work, equality correct. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

- [x] 4. Create `MCalEventChangeInfo` class
  - File: `lib/src/models/mcal_event_change_info.dart` (NEW)
  - Create `MCalChangeType` enum: `eventAdded`, `eventUpdated`, `eventRemoved`, `exceptionAdded`, `exceptionRemoved`, `seriesSplit`, `bulkChange`
  - Create `MCalEventChangeInfo` with: `type` (MCalChangeType), `affectedEventIds` (`Set<String>`), `affectedDateRange` (DateTimeRange?)
  - Requires Flutter import for `DateTimeRange`
  - Purpose: Change notification metadata for targeted view rebuilds
  - _Leverage: Design doc section "MCalEventChangeInfo"_
  - _Requirements: 10.1, 10.2_
  - _Prompt: Implement the task for spec recurring-events, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Create `MCalChangeType` enum and `MCalEventChangeInfo` class in a new file `lib/src/models/mcal_event_change_info.dart` as specified in design doc `.spec-workflow/specs/recurring-events/design.md` section "MCalEventChangeInfo". This needs `import 'package:flutter/material.dart'` for `DateTimeRange`. | Restrictions: Do NOT export from multi_calendar.dart yet. | Success: dart analyze clean. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

- [x] 5. Add `recurrenceRule` field to `MCalCalendarEvent`
  - File: `lib/src/models/mcal_calendar_event.dart`
  - Add `final MCalRecurrenceRule? recurrenceRule;` field
  - Add `this.recurrenceRule` to constructor
  - Update `copyWith` to include `recurrenceRule` (with sentinel or nullable handling to allow clearing)
  - Update `==` and `hashCode` to include `recurrenceRule`
  - Update `toString` to include `recurrenceRule`
  - Purpose: Enable events to carry recurrence rules
  - _Leverage: Existing `copyWith`/`==`/`hashCode` patterns in the same file_
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  - _Prompt: Implement the task for spec recurring-events, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Add `MCalRecurrenceRule? recurrenceRule` field to `MCalCalendarEvent` in `lib/src/models/mcal_calendar_event.dart`. Add import for `mcal_recurrence_rule.dart`. Add `this.recurrenceRule` to constructor. Update `copyWith`, `==`, `hashCode`, `toString` to include `recurrenceRule`. For `copyWith`, to allow clearing recurrenceRule to null, use an explicit check pattern (e.g., a boolean flag `clearRecurrenceRule` or check if the parameter was explicitly passed). | Restrictions: Do NOT change any other behavior. Backward compatible — events without recurrenceRule work identically. | Success: dart analyze clean, existing tests pass (no behavioral change for events without recurrenceRule). Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

- [x] 6. Export new model types from `multi_calendar.dart`
  - File: `lib/multi_calendar.dart`
  - Add exports for: `mcal_recurrence_rule.dart`, `mcal_recurrence_exception.dart`, `mcal_event_change_info.dart`
  - Ensure `teno_rrule` internals are NOT re-exported (use `show` clauses if needed)
  - Purpose: Make new types available to consumers
  - _Leverage: Existing export patterns in `lib/multi_calendar.dart`_
  - _Requirements: 1.11, 1.12_
  - _Prompt: Implement the task for spec recurring-events, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Add export statements to `lib/multi_calendar.dart` for the three new model files: `lib/src/models/mcal_recurrence_rule.dart`, `lib/src/models/mcal_recurrence_exception.dart`, `lib/src/models/mcal_event_change_info.dart`. Verify that no `teno_rrule` types leak through the exports. | Restrictions: Do NOT change any existing exports. | Success: dart analyze clean, new types are importable via `import 'package:multi_calendar/multi_calendar.dart'`. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

## Phase 2: Controller Layer (expansion, exceptions, series management)

- [x] 7. Add exception store and `lastChange` to `MCalEventController`
  - File: `lib/src/controllers/mcal_event_controller.dart`
  - Add internal state: `_exceptionsBySeriesId` (`Map<String, Map<DateTime, MCalRecurrenceException>>`), `_expandedBySeriesId` (`Map<String, List<MCalCalendarEvent>>`), `_expandedRange` (DateTimeRange?), `_lastChange` (MCalEventChangeInfo?)
  - Add public getter: `MCalEventChangeInfo? get lastChange => _lastChange;`
  - Add private helper: `DateTime _normalizeDate(DateTime date)` — strips time to midnight for consistent keying
  - Update existing `addEvents()` and `clearEvents()` to set `_lastChange` with `bulkChange` type
  - Purpose: Foundation state for recurrence expansion and change tracking
  - _Leverage: Existing controller patterns, design doc section "New Internal State"_
  - _Requirements: 4.8, 10.1, 10.2, 10.4_
  - _Prompt: Implement the task for spec recurring-events, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in state management | Task: Add internal state fields to `MCalEventController` in `lib/src/controllers/mcal_event_controller.dart`: `_exceptionsBySeriesId`, `_expandedBySeriesId`, `_expandedRange`, `_lastChange`. Add `lastChange` getter. Add `_normalizeDate` helper. Update `addEvents()` and `clearEvents()` to set `_lastChange = MCalEventChangeInfo(type: MCalChangeType.bulkChange, affectedEventIds: {...})` before `notifyListeners()`. See design doc `.spec-workflow/specs/recurring-events/design.md`. | Restrictions: Do NOT modify `getEventsForRange()` yet (Task 8). Do NOT add exception methods yet (Task 9). | Success: dart analyze clean, existing tests pass (addEvents/clearEvents still work, now also set lastChange). Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

- [x] 8. Enhance `getEventsForRange()` with recurrence expansion
  - File: `lib/src/controllers/mcal_event_controller.dart`
  - Modify `getEventsForRange()` to detect recurring events and expand them
  - Implement private `_getExpandedOccurrences(MCalCalendarEvent master, DateTimeRange range)` that: expands using `MCalRecurrenceRule.getOccurrences()`, applies exceptions from `_exceptionsBySeriesId`, caches results in `_expandedBySeriesId`, returns expanded occurrence list
  - Implement `_patchCacheForException()` and `_patchCacheForExceptionRemoval()` private methods (used by Task 9)
  - Implement `_computeAffectedRange(MCalRecurrenceException)` private helper
  - Non-recurring events continue through existing path unchanged
  - Purpose: Core expansion engine that transparently converts master events into occurrences
  - _Leverage: Design doc section "Enhanced getEventsForRange()" and "Private Expansion Method". `MCalRecurrenceRule.getOccurrences()` from Task 2._
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_
  - _Prompt: Implement the task for spec recurring-events, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in caching and data transformation | Task: Enhance `getEventsForRange()` in `lib/src/controllers/mcal_event_controller.dart` to expand recurring events. Add `_getExpandedOccurrences()` private method following the design doc `.spec-workflow/specs/recurring-events/design.md` section "Private Expansion Method" exactly. Each occurrence gets id="{masterId}_{dateIso8601}", occurrenceId=dateIso8601, start/end adjusted preserving duration. Apply exceptions from `_exceptionsBySeriesId` (deleted=skip, rescheduled=move, modified=replace). Cache in `_expandedBySeriesId`. Also add `_patchCacheForException()`, `_patchCacheForExceptionRemoval()`, `_computeAffectedRange()` private methods from the design doc "Cache Patch Methods" section. | Restrictions: Non-recurring events must work exactly as before. Do NOT add public exception/series methods yet. | Success: dart analyze clean, existing tests pass, recurring events expand correctly for a given range. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

- [x] 9. Add exception CRUD methods to controller
  - File: `lib/src/controllers/mcal_event_controller.dart`
  - Implement `addException(String seriesId, MCalRecurrenceException exception)` — stores exception, patches cache in O(1), sets `_lastChange`, notifies. Returns the exception.
  - Implement `addExceptions(String seriesId, List<MCalRecurrenceException> exceptions)` — batch load, invalidates series cache, sets `_lastChange` as `bulkChange`, notifies.
  - Implement `removeException(String seriesId, DateTime originalDate)` — removes, patches cache, sets `_lastChange`, notifies. Returns removed exception.
  - Implement `getExceptions(String seriesId)` — returns list of exceptions for series.
  - Implement `modifyOccurrence(String seriesId, DateTime originalDate, MCalCalendarEvent modifiedEvent)` — convenience that creates modified exception via `addException`.
  - Purpose: Full exception management API
  - _Leverage: Design doc section "Exception Methods". Cache patching from Task 8._
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.9, 4.10, 10.3, 12.2, 12.5_
  - _Prompt: Implement the task for spec recurring-events, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Add exception CRUD methods to `MCalEventController` in `lib/src/controllers/mcal_event_controller.dart` following the design doc `.spec-workflow/specs/recurring-events/design.md` section "Exception Methods" exactly. Methods: `addException`, `addExceptions`, `removeException`, `getExceptions`, `modifyOccurrence`. Each method sets `_lastChange` appropriately before `notifyListeners()`. `addException` uses `_patchCacheForException` (O(1)). `addExceptions` invalidates series cache (batch is cheaper to re-expand). `removeException` uses `_patchCacheForExceptionRemoval`. All mutation methods return sufficient info for consumer persistence. | Restrictions: Do NOT add series management methods yet (Task 10). | Success: dart analyze clean, exception operations work correctly with cached expansions. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

- [x] 10. Add series management methods to controller
  - File: `lib/src/controllers/mcal_event_controller.dart`
  - Implement `updateRecurringEvent(MCalCalendarEvent event)` — replaces master, invalidates series cache, sets `_lastChange`, notifies.
  - Implement `deleteRecurringEvent(String eventId)` — removes master + exceptions + cache, sets `_lastChange`, notifies.
  - Implement `splitSeries(String seriesId, DateTime fromDate)` — truncates original, creates new master, moves exceptions, invalidates caches, sets `_lastChange`, returns new ID.
  - Purpose: Full series lifecycle management
  - _Leverage: Design doc section "Series Management Methods". Existing `_eventsById` patterns._
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_
  - _Prompt: Implement the task for spec recurring-events, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in state management | Task: Add series management methods to `MCalEventController` in `lib/src/controllers/mcal_event_controller.dart` following the design doc `.spec-workflow/specs/recurring-events/design.md` section "Series Management Methods" exactly. Methods: `updateRecurringEvent`, `deleteRecurringEvent`, `splitSeries`. `splitSeries` truncates original series (set until=dayBefore), creates new master at fromDate with same recurrence pattern, moves exceptions on/after fromDate to new series, invalidates both caches, returns new master ID. All set `_lastChange` before `notifyListeners()`. | Restrictions: Do NOT modify any widget code. | Success: dart analyze clean, splitSeries correctly produces two series with exceptions distributed. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

## Phase 3: Widget Layer (context enrichment, drag-drop integration)

- [x] 11. Enrich `MCalEventTileContext` with recurrence metadata
  - File: `lib/src/widgets/mcal_month_view_contexts.dart`
  - Add fields to `MCalEventTileContext`: `isRecurring` (bool, default false), `seriesId` (String?), `recurrenceRule` (MCalRecurrenceRule?), `masterEvent` (MCalCalendarEvent?), `isException` (bool, default false)
  - Add these to the constructor as optional named parameters with defaults
  - Purpose: Expose recurrence info to builder callbacks
  - _Leverage: Follow existing optional field pattern (isDropTargetPreview, dropValid, etc.) in same file_
  - _Requirements: 6.1, 6.3_
  - _Prompt: Implement the task for spec recurring-events, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Add recurrence metadata fields to `MCalEventTileContext` in `lib/src/widgets/mcal_month_view_contexts.dart`: `bool isRecurring` (default false), `String? seriesId`, `MCalRecurrenceRule? recurrenceRule`, `MCalCalendarEvent? masterEvent`, `bool isException` (default false). Follow the exact same optional-parameter pattern used by existing fields like `isDropTargetPreview` and `dropValid`. Add import for `mcal_recurrence_rule.dart`. | Restrictions: Do NOT modify where MCalEventTileContext is constructed (that is Task 12). Non-recurring defaults preserve backward compat. | Success: dart analyze clean, existing tests pass. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

- [x] 12. Populate recurrence metadata in month view tile context construction
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Find all locations where `MCalEventTileContext` is constructed (in `_WeekRowWidget` build methods and `_buildDropTargetTileEventBuilder`)
  - For each construction site: check if the event has `occurrenceId` set. If so, derive `seriesId` from the event id (strip occurrence suffix), look up master event from controller, and populate `isRecurring`, `seriesId`, `recurrenceRule`, `masterEvent`, `isException`
  - Add a private helper method to extract recurrence metadata from an event
  - Purpose: Views automatically populate recurrence context for builders
  - _Leverage: Controller's `_eventsById` (accessible via widget.controller). Event ID scheme from design doc "Occurrence ID Scheme"._
  - _Requirements: 6.2, 6.4_
  - _Prompt: Implement the task for spec recurring-events, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in widget architecture | Task: In `lib/src/widgets/mcal_month_view.dart`, find all call sites where `MCalEventTileContext(...)` is constructed. At each site, populate the new recurrence fields (isRecurring, seriesId, recurrenceRule, masterEvent, isException) by inspecting `event.occurrenceId`. If `occurrenceId` is non-null, the event is a recurring occurrence: extract seriesId by stripping the `_dateIso8601` suffix from the event id. Look up the master event from the controller to get the recurrence rule. Check if an exception exists for this occurrence. Add a private helper `_getRecurrenceMetadata(MCalCalendarEvent event, MCalEventController controller)` that returns a record/tuple of these fields. | Restrictions: Do NOT change any rendering logic. Only populate new context fields. Non-recurring events get default values (false/null). | Success: dart analyze clean, existing tests pass, recurring occurrences have correct metadata in context. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

- [x] 13. Add recurrence fields to `MCalEventDroppedDetails` and update `_handleDrop`
  - File: `lib/src/widgets/mcal_callback_details.dart` and `lib/src/widgets/mcal_month_view.dart`
  - Add `isRecurring` (bool) and `seriesId` (String?) fields to `MCalEventDroppedDetails`
  - Update `_handleDrop()` in `mcal_month_view.dart` to:
    - Detect recurring occurrences (check `event.occurrenceId`)
    - Populate `isRecurring` and `seriesId` in `MCalEventDroppedDetails`
    - After `onEventDropped` returns `true` for a recurring occurrence: call `controller.addException(seriesId, MCalRecurrenceException.rescheduled(...))` instead of `controller.addEvents([updatedEvent])`
    - For non-recurring events: keep existing `addEvents([updatedEvent])` behavior
  - Purpose: Drag-drop seamlessly handles recurring occurrences
  - _Leverage: Design doc section "Drag-Drop Integration". Existing `_handleDrop` logic in mcal_month_view.dart (~line 2394)._
  - _Requirements: 7.1, 7.2, 7.3, 7.4_
  - _Prompt: Implement the task for spec recurring-events, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in drag-and-drop | Task: (1) Add `bool isRecurring` (default false) and `String? seriesId` fields to `MCalEventDroppedDetails` in `lib/src/widgets/mcal_callback_details.dart`. Update its constructor. (2) In `lib/src/widgets/mcal_month_view.dart`, modify `_handleDrop()` to detect recurring occurrences by checking `event.occurrenceId != null`. If recurring: extract seriesId, populate isRecurring/seriesId in MCalEventDroppedDetails, and after onEventDropped returns true, call `widget.controller.addException(seriesId, MCalRecurrenceException.rescheduled(originalDate: event.start, newDate: newStart))` instead of `addEvents([updatedEvent])`. If not recurring: keep existing addEvents behavior. If onEventDropped returns false: do nothing (no exception). Follow design doc section "Drag-Drop Integration". | Restrictions: Must preserve existing non-recurring drag-drop behavior exactly. | Success: dart analyze clean, existing tests pass, recurring occurrence drops create reschedule exceptions. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

## Phase 4: Testing

- [x] 14. Unit tests for model types
  - Files: `test/models/mcal_recurrence_rule_test.dart` (NEW), `test/models/mcal_recurrence_exception_test.dart` (NEW), `test/models/mcal_event_change_info_test.dart` (NEW)
  - Test `MCalFrequency`, `MCalWeekDay` construction/equality
  - Test `MCalRecurrenceRule`: construction, validation (count+until error, `interval < 1` error), `fromRruleString`/`toRruleString` round-trip, `getOccurrences` for daily/weekly/monthly/yearly, byWeekDays/byMonthDays/byMonths filtering, weekStart behavior, unsupported frequency error
  - Test `MCalRecurrenceException`: all named constructors, copyWith, equality
  - Test `MCalEventChangeInfo`: construction, fields
  - Test `MCalCalendarEvent`: new recurrenceRule in copyWith/==/hashCode
  - Purpose: Validate all model types
  - _Leverage: Existing test patterns in `test/`_
  - _Requirements: 1.1-1.12, 2.1-2.5, 11.1-11.4_
  - _Prompt: Implement the task for spec recurring-events, first run spec-workflow-guide to get the workflow guide then implement the task: Role: QA Engineer specializing in Dart testing | Task: Create unit tests for all model types. (1) `test/models/mcal_recurrence_rule_test.dart`: test MCalFrequency values, MCalWeekDay construction/equality/convenience constructors, MCalRecurrenceRule construction/validation/copyWith/==/hashCode, fromRruleString round-trip with strings like "RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH", getOccurrences for each frequency, unsupported frequency ArgumentError. (2) `test/models/mcal_recurrence_exception_test.dart`: test all named constructors, copyWith, equality. (3) `test/models/mcal_event_change_info_test.dart`: basic construction. (4) Add tests to existing MCalCalendarEvent tests for recurrenceRule in copyWith/==/hashCode. | Restrictions: Use flutter_test. | Success: All tests pass. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

- [x] 15. Unit tests for controller recurrence features
  - File: `test/controllers/mcal_event_controller_recurrence_test.dart` (NEW)
  - Test expansion: add recurring event, getEventsForRange returns correct occurrences
  - Test exceptions: addException (deleted/rescheduled/modified), removeException, getExceptions, modifyOccurrence
  - Test cache: verify cache hit, verify O(1) exception patch doesn't re-expand
  - Test series management: updateRecurringEvent, deleteRecurringEvent, splitSeries
  - Test lastChange: verify correct MCalEventChangeInfo after each operation
  - Test backward compat: non-recurring events work unchanged
  - Test incremental loading: addExceptions batch, loadEvents pattern
  - Purpose: Validate controller expansion engine, exception handling, and series management
  - _Leverage: Existing controller test patterns_
  - _Requirements: 3.1-3.6, 4.1-4.10, 5.1-5.5, 10.1-10.5, 12.1-12.5_
  - _Prompt: Implement the task for spec recurring-events, first run spec-workflow-guide to get the workflow guide then implement the task: Role: QA Engineer specializing in Flutter testing | Task: Create comprehensive unit tests for controller recurrence features in `test/controllers/mcal_event_controller_recurrence_test.dart`. Test groups: (1) Expansion: add weekly event, getEventsForRange returns 4-5 occurrences per month, each with correct id/occurrenceId/start/end. (2) Exceptions: addException deleted skips occurrence, rescheduled moves it, modified replaces it. removeException restores occurrence. (3) Cache: after initial getEventsForRange, subsequent call returns cached data; addException patches cache. (4) Series: updateRecurringEvent invalidates cache, deleteRecurringEvent removes all, splitSeries creates two series with exceptions distributed. (5) lastChange: verify type/affectedEventIds/affectedDateRange after each mutation. (6) Non-recurring events work unchanged. | Success: All tests pass. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

## Phase 5: Example App

- [x] 16. Create recurrence editor dialog
  - File: `example/lib/widgets/recurrence_editor_dialog.dart` (NEW)
  - Material Design dialog for editing `MCalRecurrenceRule`
  - Frequency picker (SegmentedButton or DropdownButton for daily/weekly/monthly/yearly)
  - Interval input (TextFormField with number keyboard)
  - Day-of-week selector (FilterChip row for Mon-Sun, shown when frequency=weekly)
  - Day-of-month selector (Wrap of number chips 1-31, shown when frequency=monthly)
  - End condition radio group: Never / After N occurrences / Until date (with DatePicker)
  - Week start dropdown (Mon-Sun)
  - Returns `MCalRecurrenceRule?` via Navigator.pop (null = cancelled or "no recurrence")
  - Purpose: Full-featured recurrence editor for the example app
  - _Leverage: Existing Material Design patterns in example app. Design doc section "Example App Editor"._
  - _Requirements: 8.1, 8.2, 8.6_
  - _Prompt: Implement the task for spec recurring-events, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in Material Design UI | Task: Create a full-featured recurrence editor dialog in `example/lib/widgets/recurrence_editor_dialog.dart`. This is a StatefulWidget that accepts an optional existing `MCalRecurrenceRule` for editing and returns `MCalRecurrenceRule?` via Navigator.pop. UI: frequency picker (SegmentedButton with daily/weekly/monthly/yearly), interval input, day-of-week selector (FilterChip row, visible for weekly), day-of-month chips (visible for monthly), end condition radio group (never/count/until with appropriate inputs), week start dropdown. Follow Material Design guidelines, use the app's theme colors. Beautiful, modern UI. | Restrictions: This file is NOT part of the package — it's in example/. Import recurrence types from multi_calendar. | Success: Dialog renders correctly, all controls work, returns valid MCalRecurrenceRule. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

- [x] 17. Create recurrence edit scope dialog
  - File: `example/lib/widgets/recurrence_edit_scope_dialog.dart` (NEW)
  - Simple Material dialog with three ListTile options: "This event", "This and following events", "All events"
  - Returns an enum value (`RecurrenceEditScope.thisEvent`, `.thisAndFollowing`, `.allEvents`) via Navigator.pop
  - Purpose: Standard "how should this edit apply?" prompt
  - _Leverage: Design doc section "recurrence_edit_scope_dialog.dart"_
  - _Requirements: 8.3_
  - _Prompt: Implement the task for spec recurring-events, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Create a simple dialog in `example/lib/widgets/recurrence_edit_scope_dialog.dart`. Define a `RecurrenceEditScope` enum with values: `thisEvent`, `thisAndFollowing`, `allEvents`. The dialog is a StatelessWidget that shows three ListTile options with appropriate icons and descriptions. Returns the selected enum value via Navigator.pop. Include a Cancel button. Follow Material Design guidelines. | Restrictions: This is in example/, not the package. | Success: Dialog renders, returns correct enum value. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

- [x] 18. Integrate recurrence editor into Features demo
  - File: `example/lib/views/month_view/styles/features_demo_style.dart`
  - Add sample recurring events to `createSampleEvents()` in `example/lib/utils/sample_events.dart`
  - Add "Create Recurring Event" button to the control panel
  - Modify event tap handler to open event editor with recurrence support
  - Modify event long-press to show delete confirmation, with scope dialog for recurring events
  - Wire up the recurrence editor dialog and scope dialog
  - Handle all three edit scopes: this event (exception), this and following (splitSeries + update), all events (updateRecurringEvent)
  - Purpose: Full demonstration of the recurrence API
  - _Leverage: Existing event tap/long-press handlers in features_demo_style.dart. RecurrenceEditorDialog from Task 16, RecurrenceEditScopeDialog from Task 17._
  - _Requirements: 8.1-8.6_
  - _Prompt: Implement the task for spec recurring-events, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in app integration | Task: Integrate recurrence editing into the Features demo in `example/lib/views/month_view/styles/features_demo_style.dart`. (1) Add 2-3 sample recurring events to `createSampleEvents()` in `example/lib/utils/sample_events.dart` (e.g., weekly standup, monthly review). (2) Add a "Create Recurring Event" button to the desktop control panel. (3) Modify `_onEventTap` to open an edit dialog that includes the recurrence editor for recurring events. Show RecurrenceEditScopeDialog first if event is recurring. (4) Modify `_onEventLongPress` to show delete options (with scope dialog for recurring). (5) Wire up: "This event" → addException/modifyOccurrence, "This and following" → splitSeries + update, "All events" → updateRecurringEvent. Import the two dialogs from Tasks 16-17. | Restrictions: Do NOT modify package code. All editor UI is in example/. | Success: Can create, edit, and delete recurring events in the example app with all three scope options working correctly. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

## Phase 6: Verification

- [x] 19. Run full test suite and analyzer
  - Run `dart analyze` on the full project
  - Run all tests (model tests, controller tests, existing month view tests)
  - Verify no regressions in the existing 121+ month view tests
  - Verify all new tests pass
  - Purpose: Final verification that everything works together
  - _Requirements: All_
  - _Prompt: Implement the task for spec recurring-events, first run spec-workflow-guide to get the workflow guide then implement the task: Role: QA Engineer | Task: Run `dart analyze` on the full project and run the complete test suite. Verify: (1) dart analyze reports no errors, (2) all existing month view tests pass (121+), (3) all new recurrence model tests pass, (4) all new controller recurrence tests pass. Report results. | Restrictions: Do NOT modify any source files. Verification only. | Success: Zero analyzer errors, all tests pass. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._
