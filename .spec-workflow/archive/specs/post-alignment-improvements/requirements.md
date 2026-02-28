# Requirements Document

## Introduction

This specification documents three related enhancements and refactors delivered after the `month-day-view-api-alignment` spec was completed:

1. **Day View Page Swiping Improvements** — the initial swipe navigation implementation (from the alignment spec) was refined to fix swipe reliability, page synchronisation, and drag-and-drop coexistence.
2. **`MCalDayRegion`** — a new day-level region model for Month View that lets developers visually annotate calendar days (weekends, holidays, closures, blackout periods) and optionally block drag-and-drop onto those days, with full RFC 5545 RRULE recurrence support.
3. **DST-Safe `addDays()` Utility** — a new helper function `addDays(DateTime, int)` in `date_utils.dart` that centralises all calendar-day arithmetic behind a single, DST-correct call, eliminating scattered inline `DateTime(y, m, d + N)` constructs across the core library.

These three items are bundled together because they were all delivered in the same development session and share no overlapping code paths.

## Alignment with Product Vision

- **Drag and Drop** (Key Feature #5): Day View swipe improvements and `MCalDayRegion.blockInteraction` directly strengthen the reliability and expressiveness of event drag-and-drop.
- **Dynamic Cell Customisation** (Key Feature #12): `MCalDayRegion` is the day-level counterpart of `MCalTimeRegion` and delivers on the product commitment to let developers disable interactivity and style cells declaratively.
- **Developer-Friendly** (Product Principle #6): `addDays()` removes a class of subtle DST bugs from the library internals and makes the pattern immediately discoverable by contributors.
- **Reliability** (Scalability & Reliability): All three items improve robustness — swipe fixes prevent navigation drift, `blockInteraction` prevents invalid drops, and `addDays()` prevents DST edge cases.

## Requirements

### Requirement 1: Day View Page Swiping Reliability

**User Story:** As a calendar user on a touch device, I want swiping between days to feel instant and reliable, so that day navigation never drifts out of sync with the displayed date.

#### Acceptance Criteria

1. WHEN `enableSwipeNavigation` is `true` THEN the PageView SHALL display the correct day for each page index at all times.
2. WHEN the user swipes to a new page THEN `controller.setDisplayDate()` SHALL be called with the exact date corresponding to that page index.
3. WHEN programmatic date changes occur (e.g., Today button) THEN the PageView SHALL animate to the correct page without visual glitches.
4. WHEN a drag-and-drop gesture is active THEN horizontal page swiping SHALL NOT interfere with the drag.
5. WHEN the app is RTL THEN the swipe direction SHALL be reversed so swiping left advances to the next day.
6. WHEN `enableSwipeNavigation` is `false` (the default) THEN all existing non-swipe navigation behavior SHALL be unchanged.

### Requirement 2: MCalDayRegion Model

**User Story:** As a Flutter developer, I want to define recurring or one-off day regions on Month View cells, so that I can visually communicate special days (weekends, holidays, blackout dates) without writing custom cell builders.

#### Acceptance Criteria

1. WHEN `MCalDayRegion` is constructed with a `date` and no `recurrenceRule` THEN `appliesTo(queryDate)` SHALL return `true` only for the exact same calendar date.
2. WHEN `MCalDayRegion` is constructed with `recurrenceRule: 'FREQ=WEEKLY;BYDAY=SA,SU'` THEN `appliesTo` SHALL return `true` for every Saturday and Sunday after the anchor date.
3. WHEN `MCalDayRegion` supports RRULE patterns THEN it SHALL handle at minimum: `FREQ=DAILY`, `FREQ=WEEKLY` (with `BYDAY`), `FREQ=MONTHLY` (with `BYMONTHDAY`), `FREQ=YEARLY` (with `BYMONTH` and `BYMONTHDAY`), `UNTIL`, `COUNT`, and `INTERVAL`.
4. WHEN `MCalDayRegion` has a `color` THEN the region SHALL render as a semi-transparent background layer beneath the cell content.
5. WHEN `MCalDayRegion` has `text` or `icon` THEN those SHALL be rendered at the bottom of the cell in a small, non-intrusive style.
6. WHEN `MCalDayRegion` has `blockInteraction: true` THEN drag-and-drop onto that day SHALL be automatically rejected by the library without requiring any consumer `onDragWillAccept` wiring.
7. WHEN multiple regions apply to the same cell THEN all regions SHALL be rendered in declaration order, bottom-first.
8. WHEN a `dayRegionBuilder` is provided THEN the builder SHALL receive the default region widget and MAY replace or wrap it.
9. WHEN `MCalDayRegion` is exported from `multi_calendar.dart` THEN consumers SHALL be able to import it via `package:multi_calendar/multi_calendar.dart`.

### Requirement 3: MCalDayRegion Drop Blocking

**User Story:** As a calendar user, I want drag-and-drop to be automatically rejected on blocked days, so that I cannot accidentally reschedule events onto weekends or holidays.

#### Acceptance Criteria

1. WHEN a multi-day event spans a range that includes one or more blocking regions THEN the drag SHALL be rejected even if the event's start day is not blocked.
2. WHEN a blocking region rejects a drop THEN the consumer's `onDragWillAccept` callback SHALL NOT be called (library short-circuits first).
3. WHEN `blockInteraction` is `false` THEN drops SHALL be accepted and `onDragWillAccept` SHALL still be called as normal.
4. WHEN keyboard-based move is in progress THEN the same region-blocking rules SHALL apply to keyboard navigation as to mouse/touch drag.

### Requirement 4: DST-Safe addDays() Utility

**User Story:** As a core library contributor, I want a single `addDays(DateTime date, int days)` function, so that all calendar-day arithmetic in the library uses DST-safe constructor-form arithmetic and I do not have to remember to avoid `Duration(days: N)`.

#### Acceptance Criteria

1. WHEN `addDays(date, N)` is called THEN the result SHALL have year/month/day equal to `date` shifted by exactly `N` calendar days.
2. WHEN `addDays(date, N)` crosses a DST boundary THEN the resulting date SHALL still be the correct calendar date (not shifted by an hour due to wall-clock drift).
3. WHEN `addDays(date, N)` is called with a non-zero time component THEN all time-of-day components (hour, minute, second, millisecond, microsecond) SHALL be preserved unchanged.
4. WHEN `addDays(date, N)` crosses a month or year boundary THEN the result SHALL correctly roll over (e.g., Jan 31 + 1 = Feb 1, Dec 31 + 1 = Jan 1 next year).
5. WHEN `addDays(date, N)` is called with a negative `N` THEN the date SHALL move backwards by the absolute value of `N` days.
6. WHEN `addDays` is available THEN all `DateTime(d.year, d.month, d.day + N)` and `DateTime(d.year, d.month, d.day + N, d.hour, ...)` constructs in core library files SHALL be replaced by `addDays(d, N)` calls (where time components come from the same source date).
7. WHEN `addDays` is added to `date_utils.dart` THEN it SHALL be covered by unit tests for: zero delta, positive delta, negative delta, month rollover, year rollover, leap year (Feb 28/29), large deltas, time preservation, and DST-invariant calendar-day progression over 400 days.

## Non-Functional Requirements

### Code Architecture and Modularity

- **Single Responsibility**: `MCalDayRegion` is a pure model class; rendering logic lives in `MCalMonthView`; recurrence expansion is self-contained within the model.
- **Backward Compatibility**: All three features are purely additive — no existing public API parameters are removed or renamed. Existing code with no `dayRegions` or `addDays` calls compiles and behaves identically.
- **Consistent Patterns**: `MCalDayRegion` follows the same shape as `MCalTimeRegion`. `addDays` follows the same pattern as other functions already in `date_utils.dart`. `dayRegionBuilder` follows the same builder-with-default pattern established in `month-day-view-api-alignment`.

### Performance

- `MCalDayRegion.appliesTo()` is called once per cell per region on every build; the simplified RRULE interpreter must complete in O(1) for the supported patterns (no full expansion required).
- `addDays()` is a trivial single-allocation operation; no performance concerns.

### Reliability

- Day View swipe fixes must not regress any existing drag-and-drop or keyboard navigation tests.
- `blockInteraction` must block both pointer drag and keyboard-move equally.
- `addDays()` must produce correct results for all inputs including DST-transition dates, leap days, and year boundaries.

### Backward Compatibility

- `dayRegions` defaults to `const []`; `dayRegionBuilder` defaults to `null`. Both views compile and behave identically when these are not supplied.
- `enableSwipeNavigation` defaults to `false`; unchanged default behavior.
- `addDays()` is a new exported function; no existing function is renamed or removed.
