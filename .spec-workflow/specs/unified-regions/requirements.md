# Requirements Document: Unified Regions

## Introduction

This specification merges `MCalTimeRegion` (Day View timed regions) and `MCalDayRegion` (Month View day-level regions) into a single unified `MCalRegion` class that lives on the `MCalEventController`, not on individual views. This enables cross-view region enforcement — for example, a blocked time region on Mondays 2–5 PM will automatically prevent dragging a 3–4 PM event onto Monday in the Month View, not just in the Day View.

Currently, regions are view-local: `MCalDayView` receives `specialTimeRegions` (timed) and `MCalMonthView` receives `dayRegions` (all-day). The two classes share most fields but differ in date representation (`startTime`/`endTime` vs `date`). Neither class is known to the controller, so cross-view validation is impossible. This spec unifies them into one model that supports both timed and all-day semantics, moves region ownership to the controller, and updates both views to read regions from the controller and enforce blocking rules consistently.

## Alignment with Product Vision

**From product.md:**
- **Separation of Concerns**: Moving regions to the controller aligns with the existing pattern where the controller is the single source of truth for view state (display date, events, loading/error state). Regions are data, not view configuration.
- **Modularity**: A single region class used by all views avoids duplicated models and inconsistent blocking behavior.
- **Developer Experience**: Developers define regions once on the controller rather than maintaining parallel lists on each view.
- **Customization First**: Builder callbacks (`regionBuilder`) remain on each view for view-specific rendering.

**From tech.md:**
- **Controller Pattern**: The controller already manages events, display state, and recurrence expansion. Adding regions is a natural extension.
- **Performance**: Region lookups during drag validation must remain fast. The existing O(n) region scan per validation call is acceptable since region counts are typically small (<50).

## Requirements

### Requirement 1: Unified MCalRegion Model

**User Story:** As a developer, I want a single region class that handles both all-day and timed regions, so that I don't have to manage two separate region types with nearly identical fields.

#### Acceptance Criteria

1. The system SHALL provide an `MCalRegion` class with the following fields:
   - `id` (`String`, required) — unique identifier
   - `start` (`DateTime`, required) — start date/time for the region
   - `end` (`DateTime`, required) — end date/time for the region
   - `color` (`Color?`, optional) — background color
   - `text` (`String?`, optional) — label text
   - `icon` (`IconData?`, optional) — display icon
   - `blockInteraction` (`bool`, default `false`) — whether to block drag/drop/tap
   - `isAllDay` (`bool`, default `false`) — whether this is an all-day region (only date components of `start`/`end` are significant)
   - `recurrenceRule` (`MCalRecurrenceRule?`, optional) — typed recurrence rule, not a raw `String`
   - `customData` (`Map<String, dynamic>?`, optional) — arbitrary metadata for builders
2. WHEN `isAllDay` is `true` THEN only the date components of `start` and `end` SHALL be significant; time components SHALL be ignored for matching and overlap logic.
3. WHEN `isAllDay` is `false` THEN both date and time components of `start` and `end` SHALL be used for matching and overlap logic.
4. `MCalRegion` SHALL provide `copyWith()`, `==`, `hashCode`, and `toString()` implementations.
5. `MCalRegion` SHALL be an immutable class with a `const` constructor.
6. `MCalRegion` SHALL be defined in a new file `lib/src/models/mcal_region.dart` and exported from `lib/multi_calendar.dart`.
7. WHEN `recurrenceRule` is non-null THEN `start` SHALL act as the anchor date from which occurrences are calculated (same semantics as the existing `MCalTimeRegion.startTime` and `MCalDayRegion.date` anchor behavior).

### Requirement 2: Region Methods

**User Story:** As a developer, I want the region class to provide methods for checking whether a date or time range falls within the region, so that I can use it in validation and rendering logic.

#### Acceptance Criteria

1. `MCalRegion` SHALL provide an `appliesTo(DateTime queryDate)` method that returns `true` when the region covers the given calendar date, handling both all-day and timed regions, with full recurrence expansion.
2. `MCalRegion` SHALL provide an `overlaps(DateTime rangeStart, DateTime rangeEnd)` method that returns `true` when the region overlaps with the given time range, for timed regions.
3. `MCalRegion` SHALL provide an `expandedForDate(DateTime displayDate)` method that returns a concrete `MCalRegion` instance for the given date if the region applies (with recurrence expansion), or `null` if it does not.
4. WHEN `appliesTo()` is called on a recurring region THEN it SHALL use `MCalRecurrenceRule.getOccurrences()` for expansion (not raw string parsing), preserving the existing COUNT and UNTIL handling.
5. WHEN `expandedForDate()` returns a non-null result THEN the returned region SHALL have `start` and `end` adjusted to the occurrence date (preserving time-of-day for timed regions).

### Requirement 3: Controller Region Management

**User Story:** As a developer, I want to add, remove, and query regions on the controller, so that regions are managed centrally and available to all views.

#### Acceptance Criteria

1. `MCalEventController` SHALL provide an `addRegions(List<MCalRegion> regions)` method.
2. `MCalEventController` SHALL provide a `removeRegions(List<String> regionIds)` method.
3. `MCalEventController` SHALL provide a `clearRegions()` method.
4. `MCalEventController` SHALL provide a `List<MCalRegion> get regions` getter that returns the current list of regions.
5. `MCalEventController` SHALL provide a `getRegionsForDate(DateTime date)` method that returns all regions (both all-day and timed) that apply to the given date, with recurrence expansion.
6. `MCalEventController` SHALL provide a `getTimedRegionsForDate(DateTime date)` method that returns only timed regions (where `isAllDay == false`) expanded for the given date.
7. `MCalEventController` SHALL provide a `getAllDayRegionsForDate(DateTime date)` method that returns only all-day regions (where `isAllDay == true`) that apply to the given date.
8. WHEN regions are added, removed, or cleared THEN the controller SHALL call `notifyListeners()` to trigger view rebuilds.
9. `MCalEventController` SHALL provide an `isDateBlocked(DateTime date)` method that returns `true` if any all-day region with `blockInteraction == true` applies to that date.
10. `MCalEventController` SHALL provide an `isTimeRangeBlocked(DateTime start, DateTime end)` method that returns `true` if any timed region with `blockInteraction == true` overlaps with the given range.

### Requirement 4: Cross-View Drag Validation

**User Story:** As a user, I want blocked regions to be enforced regardless of which view I'm dragging in, so that I get consistent, meaningful feedback when trying to drop an event on a blocked date or time.

#### Acceptance Criteria

1. WHEN a user drags an event in Month View to a date that has an all-day blocking region THEN the drop SHALL be rejected with the invalid-drop visual feedback.
2. WHEN a user drags an event in Month View to a date that has a timed blocking region overlapping the event's time range THEN the drop SHALL be rejected with the invalid-drop visual feedback.
3. WHEN a user drags an event in Day View to a time range that overlaps a timed blocking region THEN the drop SHALL be rejected with the invalid-drop visual feedback.
4. WHEN a user drags an event in Day View to a date that has an all-day blocking region THEN the drop SHALL be rejected with the invalid-drop visual feedback.
5. WHEN a blocking region rejects a drop THEN the consumer's `onDragWillAccept` callback SHALL NOT be called (the library short-circuits before reaching it), consistent with existing behavior.
6. The validation order SHALL be: library-level region block check → consumer's `onDragWillAccept` callback.

### Requirement 5: View Updates

**User Story:** As a developer, I want the views to read regions from the controller and render them appropriately, while still supporting view-specific region builders.

#### Acceptance Criteria

1. `MCalDayView` SHALL read timed regions from the controller via `getTimedRegionsForDate()` for rendering time region overlays.
2. `MCalMonthView` SHALL read all-day regions from the controller via `getAllDayRegionsForDate()` for rendering day cell overlays.
3. `MCalDayView` SHALL continue to support the `timeRegionBuilder` callback for custom rendering of timed regions.
4. `MCalMonthView` SHALL continue to support the `dayRegionBuilder` callback for custom rendering of day regions.
5. `MCalDayView` SHALL also check all-day blocking regions (via `isDateBlocked()`) when validating day-level drops (e.g., dropping an all-day event onto a blocked day in the all-day section).
6. Both views SHALL continue to support a `regionBuilder` callback (renamed/unified where appropriate) with a context object providing region metadata.

### Requirement 6: Removal of Old Region Classes and Parameters

**User Story:** As a developer, I want the old region classes and view-level parameters removed so that the codebase has a single, clean region API.

#### Acceptance Criteria

1. `MCalTimeRegion` class and its file (`lib/src/models/mcal_time_region.dart`) SHALL be removed.
2. `MCalDayRegion` class, `MCalDayRegionContext` class, and their file (`lib/src/models/mcal_day_region.dart`) SHALL be removed.
3. `MCalDayView.specialTimeRegions` parameter SHALL be removed.
4. `MCalMonthView.dayRegions` parameter SHALL be removed.
5. All exports of the removed classes SHALL be removed from `lib/multi_calendar.dart`.
6. All imports and usages of the removed classes in test files, example app, and views SHALL be updated to use `MCalRegion` and controller-based APIs.
7. Removal SHALL happen in a dedicated final phase, after all new `MCalRegion` code is implemented, integrated into views, and verified with passing tests.

### Requirement 7: Recurrence Rule as Typed Object

**User Story:** As a developer, I want the region's recurrence rule to use the typed `MCalRecurrenceRule` class instead of a raw string, so that I get compile-time safety and avoid string formatting errors.

#### Acceptance Criteria

1. `MCalRegion.recurrenceRule` SHALL be of type `MCalRecurrenceRule?`, not `String?`.
2. WHEN creating a recurring region THEN the developer SHALL construct an `MCalRecurrenceRule` instance rather than passing a raw RRULE string.
3. The expansion logic in `appliesTo()` and `expandedForDate()` SHALL call methods directly on the `MCalRecurrenceRule` instance rather than parsing from string.

## Non-Functional Requirements

### Code Architecture and Modularity
- **Single Responsibility**: `MCalRegion` handles region data; the controller handles storage and query; views handle rendering.
- **Modular Design**: The region model is independent of any specific view.
- **Clear Interfaces**: Controller exposes clean query methods; views consume regions via the controller.

### Performance
- Region lookups during drag validation must not cause frame drops. With typical region counts (<50), O(n) scans are acceptable.
- Recurrence expansion for regions should be cached or lazily computed per visible date range, consistent with event expansion patterns.

### Clean Removal
- Old region classes (`MCalTimeRegion`, `MCalDayRegion`) and view-level parameters (`specialTimeRegions`, `dayRegions`) are removed entirely — no deprecation period.
- Removal happens in a final phase after all new code is implemented and tested, so the agent has working references during development.
