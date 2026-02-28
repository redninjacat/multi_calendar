# Requirements Document: Recurring Events

## Introduction

This specification adds full recurring event support to the multi_calendar package. Recurrence rules are wrapped behind package-owned types (`MCalRecurrenceRule`, `MCalFrequency`, `MCalWeekDay`, `MCalRecurrenceException`) that internally use the `teno_rrule` package for RFC 5545 compliant expansion. The `MCalEventController` is enhanced to automatically expand recurring master events into individual occurrences for the visible date range, apply exceptions (deletions, reschedules, full overrides), and support series splitting. Builder contexts are enriched with recurrence metadata so consuming UIs can distinguish recurring occurrences from standalone events. A full-featured recurrence editor is added to the example app (not part of the package) to demonstrate the API.

## Alignment with Product Vision

* **RFC 5545 RRULE Support**: The product vision lists full RFC 5545 compliance as a key feature. This spec delivers on that promise.
* **Delegation for Storage**: The package handles recurrence expansion and display but does not persist events — consistent with the delegation pattern.
* **Customization First**: Recurrence metadata is exposed through builder contexts, giving developers full control over how recurring events are rendered.
* **Performance Conscious**: Expansion is lazy — only occurrences within the visible date range are generated.
* **Developer-Friendly**: The wrapper API is simpler than raw RFC 5545, with `MCalRecurrenceRule` providing a clean Dart-native interface.

## Requirements

### Requirement 1: Wrapper Types

**User Story:** As a developer, I want package-owned recurrence types so that my code is not coupled to a third-party RRULE library.

#### Acceptance Criteria

1. The system SHALL provide an `MCalFrequency` enum with values: `daily`, `weekly`, `monthly`, `yearly`.
2. The system SHALL provide an `MCalWeekDay` class with a `dayOfWeek` field (int, using Dart's `DateTime.monday` through `DateTime.sunday` constants) and an optional `occurrence` field (int, e.g., `1` = first, `-1` = last, used for patterns like "first Friday" or "last Monday").
3. The system SHALL provide an immutable `MCalRecurrenceRule` class with the following fields:
   - `frequency` (`MCalFrequency`, required)
   - `interval` (`int`, default 1)
   - `count` (`int?`, optional — number of occurrences)
   - `until` (`DateTime?`, optional — end date, mutually exclusive with `count`)
   - `byWeekDays` (`Set<MCalWeekDay>?`, optional)
   - `byMonthDays` (`Set<int>?`, optional — day numbers, negative values count from end)
   - `byMonths` (`Set<int>?`, optional — month numbers 1-12)
   - `bySetPositions` (`Set<int>?`, optional — for complex patterns like "second-to-last weekday")
   - `weekStart` (`int?`, optional — first day of week, defaults to `DateTime.monday`)
4. `MCalRecurrenceRule` SHALL provide a `factory MCalRecurrenceRule.fromRruleString(String rrule)` constructor that parses an RFC 5545 RRULE string.
5. `MCalRecurrenceRule` SHALL provide a `String toRruleString()` method that serializes to an RFC 5545 RRULE string.
6. `MCalRecurrenceRule` SHALL provide a `List<DateTime> getOccurrences({required DateTime after, required DateTime before})` method that returns all occurrence dates within the specified range.
7. `MCalRecurrenceRule` SHALL provide `copyWith()`, `==`, `hashCode`, and `toString()` implementations.
8. The system SHALL provide an `MCalExceptionType` enum with values: `deleted`, `rescheduled`, `modified`.
9. The system SHALL provide an immutable `MCalRecurrenceException` class with:
   - `type` (`MCalExceptionType`, required)
   - `originalDate` (`DateTime`, required — the occurrence date being excepted)
   - `newDate` (`DateTime?`, optional — only for `rescheduled` type)
   - `modifiedEvent` (`MCalCalendarEvent?`, optional — only for `modified` type, the full replacement event for this occurrence)
10. `MCalRecurrenceException` SHALL provide `copyWith()`, `==`, `hashCode`, and `toString()` implementations.
11. All wrapper types SHALL be defined in new files under `lib/src/models/` and exported from `lib/multi_calendar.dart`.
12. The internal `teno_rrule` package SHALL NOT be exposed in any public API. All public types are package-owned.

### Requirement 2: Event Model Changes

**User Story:** As a developer, I want to create recurring events using the same `MCalCalendarEvent` model so that the API remains simple and consistent.

#### Acceptance Criteria

1. `MCalCalendarEvent` SHALL gain an optional `MCalRecurrenceRule? recurrenceRule` field.
2. WHEN `recurrenceRule` is non-null THEN the event is a "master" event representing the series. The `start` and `end` fields define the first occurrence's timing and the duration template for all occurrences.
3. WHEN `recurrenceRule` is null THEN the event is a standalone (non-recurring) event, preserving full backward compatibility.
4. The `copyWith()` method SHALL be updated to include `recurrenceRule`.
5. The `==` and `hashCode` implementations SHALL include `recurrenceRule`.

### Requirement 3: Controller Expansion Engine

**User Story:** As a developer, I want the controller to automatically expand recurring events into individual occurrences for the visible date range so that I don't have to implement expansion logic myself.

#### Acceptance Criteria

1. WHEN `getEventsForRange()` is called THEN the controller SHALL expand all master events (events with non-null `recurrenceRule`) into individual occurrence `MCalCalendarEvent` instances whose `start`/`end` dates fall within or overlap the requested range.
2. Each expanded occurrence SHALL be an `MCalCalendarEvent` with:
   - `id` set to `"{masterEventId}_{occurrenceIndex}"` or a deterministic scheme based on the occurrence date
   - `start` and `end` adjusted to the occurrence date while preserving the original duration
   - `occurrenceId` set to uniquely identify this occurrence (e.g., ISO 8601 date string of the occurrence start)
   - All other fields copied from the master event (title, color, isAllDay, comment, externalId)
3. The controller SHALL cache expanded occurrences for the current visible range. Cache management SHALL be granular:
   - Single-occurrence exception operations (add/remove/modify exception) SHALL patch the cache in place (O(1) per occurrence) rather than re-expanding the entire series.
   - Master event changes (updateRecurringEvent, deleteRecurringEvent) SHALL invalidate only that series' cached occurrences, not all cached data.
   - Adding a new recurring event SHALL expand only the new series for the cached range.
4. Non-recurring events SHALL continue to work exactly as before — no behavioral change for events without a `recurrenceRule`.
5. The controller SHALL pass `weekStart` from the `MCalRecurrenceRule` to the underlying `teno_rrule` expansion engine so that WEEKLY recurrences respect the configured week start.
6. Expansion SHALL be lazy — only occurrences within the requested range are generated, not the full infinite series.

### Requirement 4: Exception Handling

**User Story:** As a developer, I want to manage exceptions to individual occurrences (delete, reschedule, or fully override) so that users can customize specific instances of a recurring series.

#### Acceptance Criteria

1. The controller SHALL provide `addException(String seriesId, MCalRecurrenceException exception)` to register an exception for a specific occurrence.
2. The controller SHALL provide `removeException(String seriesId, DateTime originalDate)` to remove a previously registered exception.
3. The controller SHALL provide `getExceptions(String seriesId)` to retrieve all exceptions for a series.
4. WHEN an exception of type `deleted` exists for an occurrence date THEN that occurrence SHALL be excluded from `getEventsForRange()` results.
5. WHEN an exception of type `rescheduled` exists THEN the occurrence SHALL appear at the `newDate` instead of `originalDate`, preserving all other fields from the master event.
6. WHEN an exception of type `modified` exists THEN the occurrence SHALL be replaced entirely by `modifiedEvent`, with the original occurrence removed. The `modifiedEvent` SHALL have its `occurrenceId` set to identify it as belonging to the series.
7. The controller SHALL provide a convenience method `modifyOccurrence(String seriesId, DateTime originalDate, MCalCalendarEvent modifiedEvent)` that creates a `modified` exception.
8. Exceptions SHALL be stored separately from the master event in the controller's internal state.
9. Adding, removing, or modifying exceptions SHALL trigger `notifyListeners()` to refresh views.
10. Exception operations SHALL NOT require the consuming application to reload events from its external data source. The controller SHALL handle exception state locally. The consumer is only responsible for persisting the exception to their backend asynchronously.

### Requirement 5: Series Management

**User Story:** As a developer, I want CRUD operations and series splitting so that I can fully manage recurring event lifecycles.

#### Acceptance Criteria

1. The controller SHALL provide `addRecurringEvent(MCalCalendarEvent event)` that adds a master event with a `recurrenceRule`. This MAY be the same as `addEvents()` — the controller detects recurring events automatically.
2. The controller SHALL provide `updateRecurringEvent(MCalCalendarEvent event)` that replaces the master event, invalidates cached expansions, and preserves existing exceptions.
3. The controller SHALL provide `deleteRecurringEvent(String eventId)` that removes the master event and all associated exceptions.
4. The controller SHALL provide `splitSeries(String seriesId, DateTime fromDate)` that:
   - Modifies the original master event's `recurrenceRule` to end before `fromDate` (by setting `until` to the day before `fromDate`)
   - Creates a new master event starting from `fromDate` with the same recurrence pattern
   - Moves exceptions on or after `fromDate` to the new series
   - Returns the new master event's ID
5. `splitSeries` SHALL trigger `notifyListeners()` after completing.

### Requirement 6: Context Enrichment for Builders

**User Story:** As a developer, I want builder callbacks to receive recurrence metadata so that I can render recurring events differently (e.g., show a recurrence icon, display series info).

#### Acceptance Criteria

1. `MCalEventTileContext` SHALL gain the following optional fields:
   - `bool isRecurring` (default `false`) — `true` for occurrences of recurring events
   - `String? seriesId` — the master event's ID
   - `MCalRecurrenceRule? recurrenceRule` — the recurrence rule from the master event
   - `MCalCalendarEvent? masterEvent` — the full master event (for accessing original title, color, etc.)
   - `bool isException` (default `false`) — `true` if this occurrence has been modified or rescheduled
2. The month view SHALL populate these fields when constructing `MCalEventTileContext` for expanded occurrences.
3. For non-recurring events, all recurrence-related fields SHALL be null/false, preserving backward compatibility.
4. `MCalDayCellContext` SHALL continue to receive the expanded occurrence list in its `events` field (including recurring occurrences), requiring no changes to `MCalDayCellContext` itself.

### Requirement 7: Drag-and-Drop Integration

**User Story:** As a developer, I want drag-and-drop on recurring event occurrences to automatically create reschedule exceptions so that the interaction is seamless.

#### Acceptance Criteria

1. WHEN a user drags and drops a recurring event occurrence to a new date THEN the controller SHALL automatically create a `rescheduled` exception for that occurrence.
2. The `onEventDropped` callback SHALL still be invoked, and its return value SHALL still control whether the drop is accepted.
3. The `MCalEventDroppedDetails` (or equivalent callback details) SHALL include `isRecurring` and `seriesId` fields so the consuming app can distinguish recurring drops from standalone drops.
4. IF the consuming app returns `false` from `onEventDropped` THEN no exception SHALL be created.

### Requirement 8: Example App Editor UI

**User Story:** As a developer evaluating the package, I want a full-featured recurrence editor in the example app so that I can see how the recurrence API works in practice.

#### Acceptance Criteria

1. The example app SHALL provide a recurrence editor dialog (not part of the package) with:
   - Frequency picker (daily, weekly, monthly, yearly)
   - Interval input (e.g., "every 2 weeks")
   - Day-of-week selector (for weekly frequency — checkboxes for Mon through Sun)
   - Day-of-month selector (for monthly frequency)
   - End condition selector: never, after N occurrences, until a specific date
   - Week start selector
2. The editor SHALL support creating new recurring events and editing existing ones.
3. WHEN editing a recurring event occurrence THEN the editor SHALL present a dialog with three options: "This event", "This and following events", "All events".
   - "This event" → creates an exception for the single occurrence
   - "This and following events" → calls `splitSeries` and modifies the new series
   - "All events" → updates the master event
4. The editor SHALL display a list of exceptions for the series and allow deleting individual exceptions.
5. The editor SHALL support deleting occurrences (creating `deleted` exceptions) via a delete button on each event.
6. The editor UI SHALL follow Material Design guidelines and match the existing example app styling.

### Requirement 10: Efficient Change Notifications

**User Story:** As a developer, I want the controller to provide information about what changed so that my UI can perform targeted updates instead of full re-renders, especially important for apps with hundreds of recurring events.

#### Acceptance Criteria

1. The controller SHALL expose a `MCalEventChangeInfo? lastChange` property that describes the most recent mutation. This is set before `notifyListeners()` is called and cleared on the next mutation.
2. `MCalEventChangeInfo` SHALL include:
   - `type` (`MCalChangeType` enum: `eventAdded`, `eventUpdated`, `eventRemoved`, `exceptionAdded`, `exceptionRemoved`, `seriesSplit`, `bulkChange`)
   - `affectedEventIds` (`Set<String>` — the master event IDs or standalone event IDs affected)
   - `affectedDateRange` (`DateTimeRange?` — the date range where visible changes occurred, enabling views to skip rebuilding unaffected regions)
3. WHEN a single-occurrence exception is added (e.g., from a drag-drop reschedule) THEN `affectedDateRange` SHALL cover only the original date and the new date (if rescheduled), not the entire series range.
4. WHEN `addEvents()` or `clearEvents()` is called with many events THEN `type` SHALL be `bulkChange` and `affectedDateRange` SHALL be null (indicating views should fully rebuild).
5. Views MAY use `lastChange` to optimize rebuilds. Views that do not check `lastChange` SHALL still work correctly (full rebuild on every `notifyListeners()`).

### Requirement 11: RFC 5545 String Interop

**User Story:** As a developer, I want to import and export recurrence rules as RFC 5545 strings so that my app can interoperate with other calendar systems.

#### Acceptance Criteria

1. `MCalRecurrenceRule.fromRruleString(String)` SHALL parse standard RFC 5545 RRULE strings (e.g., `"RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH;BYMONTH=12"`).
2. `MCalRecurrenceRule.toRruleString()` SHALL produce valid RFC 5545 RRULE strings.
3. Round-trip conversion (parse → serialize → parse) SHALL produce equivalent rules.
4. Unsupported frequencies (SECONDLY, MINUTELY, HOURLY) SHALL throw an `ArgumentError` with a clear message when encountered in `fromRruleString`.

### Requirement 12: External Data Source Integration

**User Story:** As a developer using a persistence layer (Drift, SQLite, Firestore, etc.), I want the controller's recurring event API to integrate efficiently with my data loading patterns so that I don't have to load all events upfront or reload everything when a single occurrence changes.

#### Acceptance Criteria

1. The existing `loadEvents(start, end)` override pattern SHALL work seamlessly with recurring events. When a consumer overrides `loadEvents`, they load master events (with `recurrenceRule` set) and exceptions from their database; the controller handles expansion.
2. The controller SHALL provide `addExceptions(String seriesId, List<MCalRecurrenceException> exceptions)` (batch version) so that consumers can efficiently load all exceptions for a series from their database in one call.
3. WHEN the visible date range changes (e.g., swipe to next month) THEN the controller SHALL only expand recurring events for the new range, reusing cached occurrences for dates that overlap with the previous range.
4. The controller SHALL NOT require all events to be loaded in memory simultaneously. The existing `loadEvents` → `addEvents` pattern supports incremental loading, and recurring event expansion SHALL work with whatever subset of master events is currently loaded.
5. All mutation methods (`addException`, `modifyOccurrence`, `splitSeries`, etc.) SHALL return sufficient information (e.g., the created exception, the new series ID) for the consumer to persist the change to their backend without querying the controller's internal state.

## Non-Functional Requirements

### Code Architecture and Modularity

* **Single Responsibility**: Wrapper types in `lib/src/models/`, expansion logic in the controller, context enrichment in the widget layer, editor UI in `example/`.
* **Modular Design**: `MCalRecurrenceRule` is a standalone model with no Flutter dependency (pure Dart). The controller bridges models and views.
* **Dependency Isolation**: `teno_rrule` is imported only in the wrapper implementation files, never in public headers.

### Performance

* Recurrence expansion SHALL be lazy — only occurrences within the requested date range are generated.
* The controller SHALL cache expanded occurrences for the current visible range. Cache invalidation occurs on master event changes, exception changes, or visible range changes.
* Expansion of typical recurring events (daily/weekly/monthly for a 3-month range) SHALL complete in under 10ms on mobile devices.
* Single-occurrence mutations (exception add/remove/modify, drag-drop reschedule) SHALL complete in O(1) time relative to the number of recurring events, by patching the cached expansion rather than re-expanding.

### Reliability

* All existing tests SHALL continue to pass unchanged. Non-recurring events have zero behavioral change.
* `MCalRecurrenceRule` SHALL be validated on construction: `count` and `until` are mutually exclusive (throw `ArgumentError` if both provided), `interval` must be >= 1.
* Exception dates that don't match any occurrence SHALL be silently ignored (no error).

### Usability

* The wrapper API should feel native to Dart developers — no UTC conversion required (the wrapper handles `teno_rrule`'s requirements internally).
* The example editor should be intuitive enough to serve as reference implementation for consuming apps building their own editors.
