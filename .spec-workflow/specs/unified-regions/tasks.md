# Tasks Document: Unified Regions

## Phase 1: Model Layer

- [ ] 1. Create `MCalRegion` class
  - File: `lib/src/models/mcal_region.dart` (NEW)
  - Create immutable `MCalRegion` class with `const` constructor and all fields: `id` (String), `start` (DateTime), `end` (DateTime), `color` (Color?), `text` (String?), `icon` (IconData?), `blockInteraction` (bool, default false), `isAllDay` (bool, default false), `recurrenceRule` (MCalRecurrenceRule?), `customData` (Map<String, dynamic>?)
  - Implement `copyWith()`, `==`, `hashCode`, `toString()`
  - Purpose: Foundation unified region data class
  - _Leverage: `MCalCalendarEvent` patterns in `lib/src/models/mcal_calendar_event.dart` for `copyWith`/`==`/`hashCode`/`toString`. Field semantics from `MCalTimeRegion` and `MCalDayRegion`._
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.7_
  - _Prompt: Role: Dart Developer specializing in immutable data models | Task: Create `MCalRegion` class in a new file `lib/src/models/mcal_region.dart` as specified in the design doc `.spec-workflow/specs/unified-regions/design.md` section "MCalRegion". Follow `MCalCalendarEvent` patterns for `copyWith`, `==`, `hashCode`, `toString`. The class has 10 fields: `id` (String, required), `start` (DateTime, required), `end` (DateTime, required), `color` (Color?), `text` (String?), `icon` (IconData?), `blockInteraction` (bool, default false), `isAllDay` (bool, default false), `recurrenceRule` (MCalRecurrenceRule?), `customData` (Map<String, dynamic>?). Add comprehensive dartdoc comments explaining the dual semantics of `start`/`end` based on `isAllDay`. Import `package:flutter/material.dart` for Color/IconData. Import `mcal_recurrence_rule.dart` for MCalRecurrenceRule. | Restrictions: Do NOT add methods yet (Task 2). Do NOT export from `multi_calendar.dart` yet (Task 4). Do NOT modify any existing files. | Success: `dart analyze` clean, all fields accessible, equality works correctly._

- [ ] 2. Add `MCalRegion` methods: `appliesTo`, `overlaps`, `contains`, `expandedForDate`
  - File: `lib/src/models/mcal_region.dart` (continue from Task 1)
  - Implement `appliesTo(DateTime queryDate)` — handles both `isAllDay` and timed regions, with recurrence expansion via `MCalRecurrenceRule.getOccurrences()`. For all-day regions, checks date range coverage. For timed regions, checks date match.
  - Implement `overlaps(DateTime rangeStart, DateTime rangeEnd)` — half-open interval overlap check for timed regions
  - Implement `contains(DateTime time)` — point-in-time check for timed regions
  - Implement `expandedForDate(DateTime displayDate)` — returns concrete `MCalRegion` for a date, adjusting `start`/`end` to the occurrence date. Preserves time-of-day for timed regions. Returns `null` if region doesn't apply. Handles COUNT and UNTIL edge cases using the existing patterns from `MCalTimeRegion.expandedForDate` and `MCalDayRegion.appliesTo`.
  - Purpose: Region query and expansion logic
  - _Leverage: `MCalTimeRegion.expandedForDate()` and `MCalTimeRegion.overlaps()` in `lib/src/models/mcal_time_region.dart`. `MCalDayRegion.appliesTo()` and `_matchesDate()` in `lib/src/models/mcal_day_region.dart`. Both use the same µs-offset-before-anchor pattern for inclusive anchor matching and COUNT handling._
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  - _Prompt: Role: Dart Developer with expertise in date/time logic | Task: Add `appliesTo`, `overlaps`, `contains`, and `expandedForDate` methods to `MCalRegion` in `lib/src/models/mcal_region.dart`. Follow the design doc `.spec-workflow/specs/unified-regions/design.md` section "MCalRegion" for field semantics by `isAllDay`. Port the recurrence expansion logic from `MCalTimeRegion.expandedForDate()` (for timed) and `MCalDayRegion.appliesTo()` (for all-day), adapting them to use `MCalRecurrenceRule` directly instead of parsing from string. Preserve the µs-offset-before-anchor pattern and COUNT/UNTIL edge case handling from both existing classes. For all-day `appliesTo`, check if `queryDate` falls within the `start`–`end` date range OR matches a recurrence occurrence. For timed `appliesTo`, check if `queryDate` matches the date component of `start` or a recurrence occurrence. For `expandedForDate`, return a new `MCalRegion` with adjusted dates, or null. | Restrictions: Do NOT modify existing files. Preserve all edge case handling from existing region classes. | Success: `dart analyze` clean, all methods produce correct results for both all-day and timed regions with and without recurrence._

- [ ] 3. Create `MCalRegion` unit tests
  - File: `test/models/mcal_region_test.dart` (NEW)
  - Test constructor, `copyWith`, `==`, `hashCode`, `toString`
  - Test `appliesTo` for: all-day single date, all-day with recurrence, timed single date, timed with recurrence
  - Test `overlaps` for: overlapping, non-overlapping, edge cases (touching boundaries)
  - Test `contains` for: inside, outside, boundary times
  - Test `expandedForDate` for: non-recurring match/miss, recurring match/miss, COUNT limits, UNTIL limits
  - Test `isAllDay` semantics: time components ignored for all-day
  - Purpose: Comprehensive model correctness validation
  - _Leverage: `test/models/mcal_time_region_test.dart` and `test/models/mcal_day_region_test.dart` for test patterns and edge cases_
  - _Requirements: 1.1–1.7, 2.1–2.5_
  - _Prompt: Role: QA Engineer specializing in Dart unit testing | Task: Create comprehensive unit tests for `MCalRegion` in `test/models/mcal_region_test.dart`. Test all constructor fields, `copyWith` (including each field individually), `==`/`hashCode` (equal and unequal cases), `toString`. Test `appliesTo` for both `isAllDay: true` and `isAllDay: false` with and without recurrence rules. Test `overlaps` with overlapping, non-overlapping, and touching-boundary ranges. Test `contains` for inside, outside, and boundary times. Test `expandedForDate` for non-recurring and recurring regions, including COUNT and UNTIL edge cases. Use patterns from existing tests in `test/models/mcal_time_region_test.dart` and `test/models/mcal_day_region_test.dart`. | Restrictions: Do NOT modify existing test files. | Success: All tests pass with `flutter test test/models/mcal_region_test.dart`._

- [ ] 4. Export `MCalRegion` from `multi_calendar.dart`
  - File: `lib/multi_calendar.dart` (modify existing)
  - Add `export 'src/models/mcal_region.dart';`
  - Purpose: Make `MCalRegion` part of the public API
  - _Leverage: Existing export pattern in `lib/multi_calendar.dart`_
  - _Requirements: 1.6_
  - _Prompt: Role: Dart Developer | Task: Add `export 'src/models/mcal_region.dart';` to `lib/multi_calendar.dart`, in alphabetical order with the other model exports. | Restrictions: Do NOT remove existing exports. | Success: `dart analyze` clean, `MCalRegion` importable via `package:multi_calendar/multi_calendar.dart`._

## Phase 2: Controller Layer

- [ ] 5. Add region storage and management methods to `MCalEventController`
  - File: `lib/src/controllers/mcal_event_controller.dart` (modify existing)
  - Add `final List<MCalRegion> _regions = [];`
  - Implement `addRegions(List<MCalRegion> regions)` — upsert semantics (replace existing by ID), then `notifyListeners()`
  - Implement `removeRegions(List<String> regionIds)` — remove by ID, then `notifyListeners()`
  - Implement `clearRegions()` — clear all, then `notifyListeners()`
  - Implement `List<MCalRegion> get regions` — returns unmodifiable list
  - Purpose: Central region storage on the controller
  - _Leverage: `addEvents()`, `removeEvents()` patterns in `mcal_event_controller.dart`_
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.8_
  - _Prompt: Role: Flutter Developer | Task: Add region management to `MCalEventController` in `lib/src/controllers/mcal_event_controller.dart`. Add a private `_regions` list. Implement `addRegions` with upsert semantics (if a region with the same ID exists, replace it), `removeRegions` by ID list, `clearRegions`, and a `regions` getter returning an unmodifiable view. Each mutation method must call `notifyListeners()`. Follow the patterns of `addEvents`/`removeEvents` in the same file. Import `mcal_region.dart`. | Restrictions: Do NOT modify event-related methods. Do NOT change the constructor signature. | Success: `dart analyze` clean, mutations trigger listener notifications._

- [ ] 6. Add region query methods to `MCalEventController`
  - File: `lib/src/controllers/mcal_event_controller.dart` (continue from Task 5)
  - Implement `getRegionsForDate(DateTime date)` — returns all regions (all-day and timed) that apply to the date
  - Implement `getTimedRegionsForDate(DateTime date)` — returns timed regions expanded for the date
  - Implement `getAllDayRegionsForDate(DateTime date)` — returns all-day regions that apply to the date
  - Implement `isDateBlocked(DateTime date)` — true if any all-day region with `blockInteraction` applies
  - Implement `isTimeRangeBlocked(DateTime start, DateTime end)` — true if any timed region with `blockInteraction` overlaps the range (expanded for the date)
  - Purpose: Query interface for views and drag validation
  - _Leverage: `MCalRegion.appliesTo()`, `MCalRegion.expandedForDate()`, `MCalRegion.overlaps()` from Task 2_
  - _Requirements: 3.5, 3.6, 3.7, 3.9, 3.10_
  - _Prompt: Role: Flutter Developer | Task: Add region query methods to `MCalEventController`. `getRegionsForDate(date)` filters `_regions` using `appliesTo(date)`. `getTimedRegionsForDate(date)` filters for `!isAllDay`, calls `expandedForDate(date)`, returns non-null results. `getAllDayRegionsForDate(date)` filters for `isAllDay` and `appliesTo(date)`. `isDateBlocked(date)` checks if any all-day region with `blockInteraction == true` applies. `isTimeRangeBlocked(start, end)` iterates timed regions with `blockInteraction == true`, calls `expandedForDate(start)` on each, checks `overlaps(start, end)` on expanded result. | Restrictions: Methods must handle empty region list efficiently. | Success: `dart analyze` clean, correct results for mixed all-day and timed regions._

- [ ] 7. Create controller region tests
  - File: `test/controllers/mcal_event_controller_region_test.dart` (NEW)
  - Test `addRegions`, `removeRegions`, `clearRegions` with listener notification verification
  - Test upsert semantics for `addRegions` (replace by ID)
  - Test all query methods with mixed all-day and timed regions, with and without recurrence
  - Test `isDateBlocked` and `isTimeRangeBlocked` with blocking and non-blocking regions
  - Test cross-view scenario: timed blocking region on specific weekday, verify `isTimeRangeBlocked` returns true for overlapping time range on that day
  - Purpose: Verify controller region management and query correctness
  - _Leverage: Existing controller tests in `test/controllers/` for test patterns_
  - _Requirements: 3.1–3.10_
  - _Prompt: Role: QA Engineer | Task: Create controller region tests in `test/controllers/mcal_event_controller_region_test.dart`. Test all CRUD operations (add, remove, clear) with listener notification count verification. Test upsert: add region, add region with same ID but different data, verify replacement. Test all query methods with a mix of all-day and timed regions (some blocking, some not, some recurring). Key test: add a timed blocking region for Mondays 2-5 PM, verify `isTimeRangeBlocked(monday3pm, monday4pm)` returns true and `isTimeRangeBlocked(tuesday3pm, tuesday4pm)` returns false. Test `isDateBlocked` with all-day blocking region. | Restrictions: Do NOT modify existing test files. | Success: All tests pass with `flutter test test/controllers/mcal_event_controller_region_test.dart`._

## Phase 3: View Integration

- [ ] 8. Update `MCalDayView` to read regions from controller
  - File: `lib/src/widgets/mcal_day_view.dart` (modify existing)
  - Update `_TimeRegionsLayer` to read from controller: `widget.controller.getTimedRegionsForDate(displayDate)` instead of `widget.specialTimeRegions`. The `specialTimeRegions` parameter remains temporarily during this phase (removed in Phase 6).
  - Update `_validateDrop()` to query `widget.controller.isTimeRangeBlocked(proposedStart, proposedEnd)` and `widget.controller.isDateBlocked(displayDate)` instead of iterating `widget.specialTimeRegions`.
  - Update keyboard move validation similarly.
  - Purpose: Day View reads regions from controller
  - _Leverage: Existing `_TimeRegionsLayer` and `_validateDrop` in `mcal_day_view.dart`_
  - _Requirements: 4.3, 4.4, 4.5, 4.6, 5.1, 5.3, 5.5_
  - _Prompt: Role: Flutter Developer | Task: Update `MCalDayView` in `lib/src/widgets/mcal_day_view.dart` to read regions from the controller instead of `specialTimeRegions`. Update `_TimeRegionsLayer` to get regions via `widget.controller.getTimedRegionsForDate(displayDate)`. Update `_validateDrop` and keyboard validation to check `controller.isTimeRangeBlocked` and `controller.isDateBlocked` instead of iterating `widget.specialTimeRegions`. Maintain the existing check order: library block check → consumer `onDragWillAccept`. The old `specialTimeRegions` parameter will be removed in a later cleanup task — for now just stop using it internally. | Restrictions: Do NOT change builder callback signatures. | Success: `dart analyze` clean, controller regions render correctly, drag validation enforces blocking via controller._

- [ ] 9. Update `MCalMonthView` to read regions from controller
  - File: `lib/src/widgets/mcal_month_view.dart` (modify existing)
  - Update cell overlay rendering to read from controller: `widget.controller.getAllDayRegionsForDate(date)` instead of `widget.dayRegions`. The `dayRegions` parameter remains temporarily during this phase (removed in Phase 6).
  - Update drag validation to check `widget.controller.isDateBlocked(date)` instead of iterating `widget.dayRegions`. For timed events being dragged, also check `widget.controller.isTimeRangeBlocked(eventStart, eventEnd)` where the times are projected onto the target date. This is the key cross-view enforcement.
  - Update keyboard move validation similarly.
  - Purpose: Month View reads regions from controller with cross-view enforcement
  - _Leverage: Existing region rendering and drag validation in `mcal_month_view.dart`_
  - _Requirements: 4.1, 4.2, 4.5, 4.6, 5.2, 5.4, 5.6_
  - _Prompt: Role: Flutter Developer | Task: Update `MCalMonthView` in `lib/src/widgets/mcal_month_view.dart` to read regions from the controller. Update cell overlay rendering to use `widget.controller.getAllDayRegionsForDate(date)`. Critical change: update drag validation to check `controller.isDateBlocked(date)` and also `controller.isTimeRangeBlocked()` for timed events — when a timed event (e.g., 3-4 PM) is dragged to a target date, project the event's time range onto the target date and check for blocking timed regions. This is the key cross-view enforcement. Maintain check order: library block → consumer `onDragWillAccept`. The old `dayRegions` parameter will be removed in a later cleanup task — for now just stop using it internally. | Restrictions: Do NOT change builder callback signatures. | Success: `dart analyze` clean, controller regions render correctly, timed blocking regions block drops of overlapping timed events in Month View._

## Phase 4: Widget Testing

- [ ] 11. Add Day View region integration tests
  - File: `test/widgets/mcal_day_view_regions_test.dart` (modify existing or create new section)
  - Test: Day View renders timed regions from controller
  - Test: Day View drag validation rejects drops on controller-level blocked timed regions
  - Test: Day View drag validation rejects drops on controller-level blocked all-day regions
  - Purpose: Verify Day View integration with controller regions
  - _Leverage: Existing tests in `test/widgets/mcal_day_view_regions_test.dart`_
  - _Requirements: 4.3, 4.4, 5.1, 5.3, 5.5_
  - _Prompt: Role: QA Engineer | Task: Add or extend tests in `test/widgets/mcal_day_view_regions_test.dart` for controller-based regions. Test that Day View renders regions added to the controller via `controller.addRegions()`. Test drag validation with controller blocking regions (both timed and all-day). Use `MCalRegion` exclusively — do not use old `MCalTimeRegion`. | Restrictions: Do NOT remove existing tests yet (they are cleaned up in Phase 6). | Success: All tests pass._

- [ ] 12. Add Month View region integration tests
  - File: `test/widgets/mcal_month_day_region_test.dart` (modify existing or create new section)
  - Test: Month View renders all-day regions from controller
  - Test: Month View drag validation rejects drops on controller-level blocked all-day regions
  - Test: Month View drag validation rejects drops of timed events on dates with controller-level blocking timed regions (cross-view enforcement)
  - Purpose: Verify Month View integration with controller regions, especially cross-view enforcement
  - _Leverage: Existing tests in `test/widgets/mcal_month_day_region_test.dart`_
  - _Requirements: 4.1, 4.2, 4.5, 4.6, 5.2, 5.4_
  - _Prompt: Role: QA Engineer | Task: Add or extend tests in `test/widgets/mcal_month_day_region_test.dart` for controller-based regions. Critical test: create a timed blocking region for Mondays 2-5 PM via `controller.addRegions()`, create a timed event 3-4 PM on Tuesday, drag it to Monday in Month View → verify drop is rejected. Test all-day blocking regions from controller. Use `MCalRegion` exclusively — do not use old `MCalDayRegion`. | Restrictions: Do NOT remove existing tests yet (they are cleaned up in Phase 6). | Success: All tests pass, cross-view enforcement test passes._

## Phase 5: Example App

- [ ] 13. Update example app to use `MCalRegion` on controller
  - File: `example/lib/views/day_view/tabs/day_features_tab.dart` (modify existing)
  - File: `example/lib/views/month_view/tabs/month_features_tab.dart` (modify existing)
  - Migrate `_buildTimeRegions()` to create `MCalRegion` instances with `isAllDay: false` and add to controller
  - Migrate `_buildDayRegions()` to create `MCalRegion` instances with `isAllDay: true` and add to controller
  - Remove usage of `specialTimeRegions` and `dayRegions` view parameters
  - Add UI demo showing cross-view region enforcement (e.g., timed blocking region visible in Day View also blocks in Month View)
  - Purpose: Demonstrate unified region API and cross-view enforcement
  - _Leverage: Existing region creation code in both feature tabs_
  - _Requirements: All_
  - _Prompt: Role: Flutter Developer | Task: Update the example app to use `MCalRegion` with the controller instead of the old view-level parameters. In `day_features_tab.dart`, convert `_buildTimeRegions()` to create `MCalRegion(isAllDay: false, recurrenceRule: MCalRecurrenceRule.fromRruleString(...))` instances and add them via `controller.addRegions()`. In `month_features_tab.dart`, convert `_buildDayRegions()` similarly with `isAllDay: true`. Remove the `specialTimeRegions` and `dayRegions` parameters from view constructors in the example app. | Restrictions: Preserve existing UI toggles and behavior. | Success: Example app compiles and runs, regions display correctly in both views, blocking works cross-view._

## Phase 6: Cleanup — Remove Old Region Code

**Important:** This phase runs AFTER all new code is implemented, tested, and verified in Phases 1–5.

- [ ] 14. Remove `MCalTimeRegion`, `MCalDayRegion`, and old view parameters
  - Files to delete:
    - `lib/src/models/mcal_time_region.dart`
    - `lib/src/models/mcal_day_region.dart`
  - Files to modify:
    - `lib/multi_calendar.dart` — remove exports for `mcal_time_region.dart` and `mcal_day_region.dart`
    - `lib/src/widgets/mcal_day_view.dart` — remove `specialTimeRegions` parameter, remove import of `mcal_time_region.dart`, remove any remaining references to `MCalTimeRegion`
    - `lib/src/widgets/mcal_day_view_contexts.dart` — remove or update `MCalTimeRegionContext` if it references `MCalTimeRegion`
    - `lib/src/widgets/mcal_month_view.dart` — remove `dayRegions` parameter, remove import of `mcal_day_region.dart`, remove any remaining references to `MCalDayRegion` and `MCalDayRegionContext`
  - Purpose: Clean removal of superseded region classes and parameters
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  - _Prompt: Role: Dart Developer | Task: Remove the old region classes and view parameters that have been replaced by `MCalRegion`. Delete `lib/src/models/mcal_time_region.dart` and `lib/src/models/mcal_day_region.dart`. Remove their exports from `lib/multi_calendar.dart`. Remove the `specialTimeRegions` parameter from `MCalDayView` and the `dayRegions` parameter from `MCalMonthView`. Remove or update `MCalTimeRegionContext` and `MCalDayRegionContext`. Search for ALL remaining references to `MCalTimeRegion`, `MCalDayRegion`, `MCalDayRegionContext`, `MCalTimeRegionContext`, `specialTimeRegions`, and `dayRegions` across the entire `lib/` directory and remove/replace them. | Restrictions: Do NOT remove new `MCalRegion` code. Ensure `dart analyze` is clean after removal. | Success: `dart analyze` clean, no references to old classes remain in `lib/`._

- [ ] 15. Update old region tests to use `MCalRegion`
  - Files to modify or replace:
    - `test/models/mcal_time_region_test.dart` — remove or rewrite tests to use `MCalRegion`
    - `test/models/mcal_day_region_test.dart` — remove or rewrite tests to use `MCalRegion`
    - `test/widgets/mcal_day_view_regions_test.dart` — update to use only `MCalRegion` and controller APIs
    - `test/widgets/mcal_month_day_region_test.dart` — update to use only `MCalRegion` and controller APIs
  - Search all test files for remaining references to `MCalTimeRegion`, `MCalDayRegion`, `specialTimeRegions`, `dayRegions` and update
  - Purpose: Complete migration of test suite to unified region API
  - _Requirements: 6.6_
  - _Prompt: Role: QA Engineer | Task: Update all test files to remove references to old region classes. The model test files (`mcal_time_region_test.dart`, `mcal_day_region_test.dart`) can be deleted since `mcal_region_test.dart` (Task 3) covers the new class. Update widget test files to use `MCalRegion` and controller APIs exclusively. Search ALL test files for `MCalTimeRegion`, `MCalDayRegion`, `MCalDayRegionContext`, `MCalTimeRegionContext`, `specialTimeRegions`, `dayRegions` and update/remove. | Restrictions: Do NOT remove tests added in Tasks 3, 7, 11, 12. | Success: `flutter test` passes with no references to old classes._

- [ ] 16. Update README and documentation
  - File: `README.md` (modify existing)
  - Replace any references to `MCalTimeRegion` and `MCalDayRegion` with `MCalRegion`
  - Add section on unified regions with examples for both all-day and timed usage
  - Show cross-view blocking example
  - Update any docs files that reference old region classes
  - Purpose: Documentation reflects the current API
  - _Requirements: All_
  - _Prompt: Role: Technical Writer | Task: Update `README.md` to replace all references to `MCalTimeRegion` and `MCalDayRegion` with `MCalRegion`. Add examples showing: 1) All-day blocking region (weekend blackout), 2) Timed blocking region (after-hours), 3) Adding regions to controller, 4) Cross-view enforcement scenario. Check `docs/` directory for any files referencing old region classes and update them. | Restrictions: Do NOT remove unrelated documentation. | Success: README and docs accurately describe the unified `MCalRegion` API with no references to removed classes._
