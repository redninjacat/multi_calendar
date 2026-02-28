# Tasks Document

## Group 1: Day View Swipe Navigation Improvements

- [x] 1. Implement DST-safe page-index-to-date conversion in Day View swipe
  - File: `lib/src/widgets/mcal_day_view.dart`
  - Replace `DateTime(ref.year, ref.month, ref.day + offset)` with `addDays(ref, offset)` in `_pageIndexToDate()`
  - Purpose: Ensure every page in the PageView maps to the correct calendar date across DST transitions
  - _Requirements: 1.1, 1.2_

- [x] 2. Fix Day View navigate-previous / navigate-next helpers to use addDays
  - File: `lib/src/widgets/mcal_day_view.dart`
  - Update `_handleNavigatePrevious`, `_handleNavigateNext`, `_handleResizeNavigatePrevious`, `_handleResizeNavigateNext`, `_canGoPrevious`, `_canGoNext`, and keyboard-move delta sites to call `addDays(_displayDate, ±1)` or `addDays(start/end, deltaDays)`
  - Purpose: Eliminate residual inline `DateTime(d.year, d.month, d.day ±1)` constructs; keep boundary guards consistent with page arithmetic
  - _Requirements: 1.1, 1.2_

- [x] 3. Write widget tests for Day View swipe navigation
  - File: `test/widgets/mcal_day_view_swipe_test.dart` (new file)
  - Test that `enableSwipeNavigation: false` (default) does not install a PageView
  - Test that swiping left on an LTR layout calls `controller.setDisplayDate` with `date + 1`
  - Test that swiping right on an LTR layout calls `controller.setDisplayDate` with `date - 1`
  - Test that swiping direction is reversed when `swipeNavigationDirection` is RTL
  - Test that `minDate` / `maxDate` boundaries are respected (cannot swipe past boundary)
  - Test that an active drag gesture does not trigger page swipe (gesture arena)
  - Test that programmatic `controller.setDisplayDate` animates the PageView to the correct page
  - _Leverage: existing `mcal_day_view_test.dart` test helpers and controller setup_
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6_
  - _Prompt: Role: Flutter widget test engineer | Task: Write widget tests for MCalDayView swipe navigation covering all acceptance criteria in Requirement 1. Use the existing day view test helpers and controller setup from mcal_day_view_test.dart. Pump the widget, simulate fling gestures with tester.fling(), and verify controller.displayDate changes. Verify the PageView is absent when enableSwipeNavigation is false. | Restrictions: Do not test internal implementation details such as _pageIndexToDate directly; test observable behaviour only. | Success: All six acceptance criteria have at least one passing test; tests are self-contained and deterministic._

## Group 2: MCalDayRegion Model

- [x] 4. Implement MCalDayRegion model class
  - File: `lib/src/models/mcal_day_region.dart` (new file)
  - Implement `MCalDayRegion` with fields: `id`, `date`, `color`, `text`, `icon`, `blockInteraction`, `recurrenceRule`, `customData`
  - Implement `appliesTo(DateTime queryDate)` with internal `_expandedOccurrences()` RRULE interpreter supporting: `FREQ=DAILY`, `FREQ=WEEKLY` (with `BYDAY`), `FREQ=MONTHLY` (with `BYMONTHDAY`), `FREQ=YEARLY` (with `BYMONTH` + `BYMONTHDAY`), `UNTIL`, `COUNT`, `INTERVAL`
  - Implement `MCalDayRegionContext` companion class
  - Purpose: Provide a pure-model class for annotating calendar days in Month View
  - _Requirements: 2.1, 2.2, 2.3_

- [x] 5. Export MCalDayRegion from public library
  - File: `lib/multi_calendar.dart`
  - Add `export 'src/models/mcal_day_region.dart';`
  - Purpose: Make `MCalDayRegion` and `MCalDayRegionContext` importable via `package:multi_calendar/multi_calendar.dart`
  - _Requirements: 2.9_

- [x] 6. Write unit tests for MCalDayRegion model
  - File: `test/models/mcal_day_region_test.dart` (new file)
  - Follow the same structure as `test/models/mcal_time_region_test.dart`
  - **Constructor / properties group:**
    - Creates with required fields only; verify defaults (`blockInteraction: false`, all optionals null)
    - Creates with all optional fields; verify each field is stored correctly
    - `blockInteraction` defaults to `false`
    - `customData` map is preserved as-is
  - **appliesTo — single occurrence (no recurrence rule) group:**
    - `appliesTo` returns `true` for the exact anchor date
    - `appliesTo` returns `false` for the day before the anchor date
    - `appliesTo` returns `false` for the day after the anchor date
    - `appliesTo` ignores time components (compares only y/m/d)
  - **appliesTo — FREQ=WEEKLY group:**
    - `FREQ=WEEKLY;BYDAY=SA,SU` matches every Saturday and Sunday on and after the anchor
    - `FREQ=WEEKLY;BYDAY=SA,SU` does not match weekdays
    - `FREQ=WEEKLY;BYDAY=SA,SU` does not match dates before the anchor
    - `FREQ=WEEKLY;BYDAY=MO` matches a specific weekday
    - `FREQ=WEEKLY;BYDAY=SA,SU;UNTIL=<date>` stops after UNTIL
    - `FREQ=WEEKLY;BYDAY=SA,SU;COUNT=4` stops after 4 occurrences
    - `FREQ=WEEKLY;INTERVAL=2;BYDAY=MO` matches every other Monday
  - **appliesTo — FREQ=DAILY group:**
    - `FREQ=DAILY` matches every day on and after anchor
    - `FREQ=DAILY;COUNT=3` matches exactly 3 days; 4th is false
    - `FREQ=DAILY;INTERVAL=2` matches every other day
    - `FREQ=DAILY;UNTIL=<date>` stops on UNTIL date
  - **appliesTo — FREQ=MONTHLY group:**
    - `FREQ=MONTHLY;BYMONTHDAY=15` matches the 15th of each month from anchor
    - `FREQ=MONTHLY;BYMONTHDAY=15` does not match the 14th or 16th
    - `FREQ=MONTHLY;BYMONTHDAY=31` matches months that have a 31st
    - `FREQ=MONTHLY;BYMONTHDAY=31;COUNT=3` stops after 3 occurrences
  - **appliesTo — FREQ=YEARLY group:**
    - `FREQ=YEARLY;BYMONTH=1;BYMONTHDAY=1` matches Jan 1 each year
    - `FREQ=YEARLY;BYMONTH=1;BYMONTHDAY=1` does not match Jan 2 or Feb 1
    - `FREQ=YEARLY;BYMONTH=12;BYMONTHDAY=25;COUNT=2` stops after 2 years
  - **Unsupported / malformed RRULE group:**
    - Unsupported `FREQ` value returns `false` silently (does not throw)
    - Malformed `UNTIL` value is ignored; region behaves as if no UNTIL set
    - Empty `recurrenceRule` string returns `false`
  - _Leverage: `mcal_time_region_test.dart` structure; no widget infrastructure needed_
  - _Requirements: 2.1, 2.2, 2.3_
  - _Prompt: Role: Dart unit test engineer | Task: Write comprehensive unit tests for MCalDayRegion.appliesTo() and constructor properties, following the structure of test/models/mcal_time_region_test.dart. Cover all four RRULE frequency types (DAILY, WEEKLY, MONTHLY, YEARLY) plus UNTIL, COUNT, INTERVAL modifiers. Cover single-occurrence (no RRULE), boundary cases (before anchor, at anchor, after last occurrence), and unsupported/malformed rules. | Restrictions: Pure Dart unit tests only — no Flutter widget pump required. Import from package:multi_calendar/multi_calendar.dart. | Success: All groups pass; each acceptance criterion in Requirement 2.1–2.3 is exercised by at least two tests (happy path + boundary/edge)._

## Group 3: MCalDayRegion Widget Integration

- [x] 7. Add dayRegions and dayRegionBuilder parameters to MCalMonthView
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Add `List<MCalDayRegion> dayRegions = const []` and `Widget Function(BuildContext, MCalDayRegionContext, Widget)? dayRegionBuilder` parameters
  - Thread both through `_MonthPageWidget → _WeekRowWidget → _DayCellWidget`
  - Purpose: Expose day regions to the widget tree for rendering and blocking
  - _Requirements: 2.4, 2.5, 2.7, 2.8_

- [x] 8. Implement region overlay rendering in _DayCellWidget
  - File: `lib/src/widgets/mcal_month_view.dart`
  - In `_DayCellWidgetState.build()`: collect `applicableRegions`, wrap cell in a `Stack` only when non-empty, render each region with `_buildRegionOverlay()`
  - `_buildRegionOverlay()`: render `Container(color: region.color)` fill, optional `Row(icon + text)` at bottom, pass to `dayRegionBuilder` if set
  - Purpose: Render region decorations as a background layer beneath cell content
  - _Requirements: 2.4, 2.5, 2.7, 2.8_

- [x] 9. Write widget tests for MCalDayRegion rendering
  - File: `test/widgets/mcal_month_day_region_test.dart` (new file)
  - **Rendering group:**
    - A region with a `color` renders a `Container` with that color on the matching cell
    - A region does NOT render a colored Container on non-matching cells
    - A region with `text` renders the text string on matching cells
    - A region with `icon` renders the icon on matching cells
    - A region with neither `text` nor `icon` renders no label widget
    - Multiple regions on the same cell are all rendered (bottom-first order)
    - No `Stack` is injected when `dayRegions` is empty (default)
  - **`dayRegionBuilder` group:**
    - When `dayRegionBuilder` is provided, the returned widget replaces the default overlay for that region
    - The `MCalDayRegionContext` passed to the builder has the correct `date`, `region`, `isToday`, `isCurrentMonth`
    - A builder that wraps the default widget (third argument) with a `ColoredBox` is rendered correctly
    - When `dayRegionBuilder` is null (default), the library's own default overlay is rendered
  - **Non-matching group:**
    - A region whose anchor date does not match any visible cell produces no overlay in the grid
    - `FREQ=WEEKLY;BYDAY=SA,SU` produces overlays only on Saturday/Sunday cells
  - _Leverage: `mcal_month_view_test.dart` for widget pump setup; `MCalDayRegion` model from task 6_
  - _Requirements: 2.4, 2.5, 2.7, 2.8_
  - _Prompt: Role: Flutter widget test engineer | Task: Write widget tests for MCalMonthView dayRegions rendering. Pump MCalMonthView with specific dayRegions and verify the UI using find.byType, find.text, find.byIcon, and find.byWidgetPredicate to check Container colors. Cover the dayRegionBuilder callback (verify context fields and that the builder's returned widget appears). Cover multi-region stacking and the empty-default no-overhead path. | Restrictions: Do not test internal state directly. Focus on rendered widget tree. | Success: All rendering and builder acceptance criteria from Requirement 2 are covered by passing tests._

## Group 4: MCalDayRegion Drop Blocking

- [x] 10. Implement blockInteraction drop-rejection in MCalMonthView drag logic
  - File: `lib/src/widgets/mcal_month_view.dart`
  - In `_processDragMove` and the `validationCallback`, iterate `DateTime d = start; d <= end; d = addDays(d, 1)` and set `isValid = false` (short-circuit) if any `d` has an applicable blocking region
  - Purpose: Auto-reject drops onto blocked day ranges without consumer `onDragWillAccept` wiring
  - _Requirements: 3.1, 3.2, 3.3_

- [x] 11. Apply keyboard-move region blocking in MCalMonthView
  - File: `lib/src/widgets/mcal_month_view.dart`
  - In the keyboard-initiated move path, apply the same blocking-region validation as the drag path before proposing a new date
  - Purpose: Ensure keyboard moves respect `blockInteraction` consistently with pointer drag
  - _Requirements: 3.4_

- [x] 12. Write widget tests for MCalDayRegion drop blocking
  - File: `test/widgets/mcal_month_day_region_test.dart` (extend file from task 9)
  - **Single-day blocking group:**
    - Dragging an event onto a single-day blocking region cell: `onDragWillAccept` is NOT called; move is rejected
    - Dragging the same event onto a non-blocking region cell: `onDragWillAccept` IS called; move proceeds
  - **Multi-day blocking group:**
    - A multi-day event spanning Mon–Wed; Wednesday is blocked: drag is rejected even though Monday and Tuesday are not blocked
    - A multi-day event spanning Mon–Wed; a non-blocking region covers Wednesday: `onDragWillAccept` IS called
  - **blockInteraction: false group:**
    - A region with `blockInteraction: false` and a color does NOT block drops; `onDragWillAccept` is called
  - **Keyboard move blocking group:**
    - Keyboard-initiated move to a blocked date is rejected (proposed date does not change)
    - Keyboard-initiated move to an unblocked date succeeds
  - _Leverage: existing drag-and-drop test helpers in `mcal_drag_handler_test.dart` and `mcal_month_view_test.dart`_
  - _Requirements: 3.1, 3.2, 3.3, 3.4_
  - _Prompt: Role: Flutter widget test engineer specialising in gesture testing | Task: Write widget tests for MCalMonthView drop-blocking via MCalDayRegion.blockInteraction. Pump MCalMonthView with blocking and non-blocking regions. Use gesture simulation (long press + drag) to simulate drops onto blocked and unblocked cells. Use a captured boolean flag in onDragWillAccept to verify whether it was called. Also test keyboard-move blocking by sending keyboard events. | Restrictions: Use only the public MCalMonthView API. Do not access private state. | Success: All acceptance criteria in Requirement 3 are covered by passing tests._

## Group 5: DST-Safe addDays() Utility

- [x] 13. Implement addDays() in date_utils.dart
  - File: `lib/src/utils/date_utils.dart`
  - Add `DateTime addDays(DateTime date, int days)` using the `DateTime` constructor form
  - Full dartdoc explaining DST safety, time component preservation, rollover, and negative delta
  - Purpose: Centralise calendar-day arithmetic behind one DST-correct function
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 14. Replace inline day-arithmetic constructs in core library
  - Files: `lib/src/widgets/mcal_day_view.dart`, `lib/src/widgets/mcal_month_view.dart`, `lib/src/widgets/mcal_drag_handler.dart`, `lib/src/controllers/mcal_event_controller.dart`
  - Replace all `DateTime(d.year, d.month, d.day + N, ...)` where time components come from the same source date with `addDays(d, N)` (25 sites total)
  - Purpose: Eliminate scattered DST-unsafe arithmetic in core library
  - _Requirements: 4.6_

- [x] 15. Write unit tests for addDays()
  - File: `test/utils/date_utils_test.dart` (extended)
  - 20 tests covering: zero delta, positive delta, negative delta, month rollover (forward/backward), year rollover (forward/backward), leap-year Feb 28/29, non-leap-year Feb 28/Mar 1, large deltas (±365/366), time-component preservation (hour/minute/second/millisecond/microsecond), midnight-stays-midnight, DST-invariant progression over 400 consecutive days (verified via UTC-based `daysBetween`), and round-trip negation
  - _Requirements: 4.7_

## Group 6: Example App Update

- [x] 16. Update month_features_tab to use MCalDayRegion
  - File: `example/lib/views/month_view/tabs/month_features_tab.dart`
  - Replace the hand-rolled `Set<DateTime>` blackout-day computation with a `List<MCalDayRegion>` using `FREQ=WEEKLY;BYDAY=SA,SU` and other recurrence patterns
  - Purpose: Demonstrate the MCalDayRegion API in a realistic consumer context and serve as a living integration test
  - _Requirements: 2.4, 2.5, 2.6_

## Group 7: Regression and Integration

- [x] 17. Audit and update existing month view tests for dayRegions parameter
  - File: `test/widgets/mcal_month_view_test.dart`
  - Review every `MCalMonthView(...)` construction in the test file; confirm that omitting `dayRegions` (defaulting to `const []`) still compiles and passes — no changes should be needed since it defaults
  - Verify that any test that previously verified cell content is not broken by the new `Stack` overlay injection (only injected when `dayRegions` is non-empty, so tests without `dayRegions` are unaffected)
  - Fix any tests whose expectations were implicitly relying on widget-tree structure that the Stack injection may have shifted (e.g., `find.byType(Container)` counts)
  - Purpose: Prevent regressions from the new overlay rendering path
  - _Requirements: NFR — backward compatibility_
  - _Prompt: Role: Flutter QA engineer | Task: Review test/widgets/mcal_month_view_test.dart for any tests that may be broken by the MCalDayRegion Stack overlay injection. The overlay is only injected when dayRegions is non-empty, so most tests should be unaffected. Fix any that fail. | Restrictions: Do not modify test intent — only fix test assertions that are now stale. | Success: flutter test test/widgets/mcal_month_view_test.dart passes with zero failures._

- [x] 18. Audit and update existing drag handler tests for addDays refactor
  - File: `test/widgets/mcal_drag_handler_test.dart`
  - Run `flutter test test/widgets/mcal_drag_handler_test.dart` and confirm all tests pass
  - If any test used an exact `DateTime` comparison that now differs by one hour due to the DST-correct arithmetic change, update the expected value to use `dateOnly()` or `daysBetween()` comparison instead of direct equality
  - Purpose: Confirm that replacing `DateTime(d.year, d.month, d.day + N)` with `addDays` in `mcal_drag_handler.dart` did not change observable date outcomes that existing tests assert on
  - _Requirements: NFR — reliability_

- [x] 19. Run the full date_utils test suite and confirm all 20 addDays tests pass
  - Command: `flutter test test/utils/date_utils_test.dart`
  - Confirm zero failures; all 20 `addDays` group tests plus pre-existing tests for `getMonthRange`, `generateMonthDates`, `getWeekNumber` pass
  - Purpose: Verify the utility layer is fully green before marking implementation complete
  - _Requirements: 4.7_
  - _Prompt: Role: QA engineer | Task: Run flutter test test/utils/date_utils_test.dart and report all pass/fail results. If any test fails, diagnose and fix the root cause. | Success: All tests pass with zero failures and zero skips._
