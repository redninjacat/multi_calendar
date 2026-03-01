# Design Document: Unified Regions

## Overview

This design merges `MCalTimeRegion` and `MCalDayRegion` into a single `MCalRegion` class and moves region ownership from individual views to `MCalEventController`. The unified model supports both all-day and timed regions via an `isAllDay` flag, and uses the typed `MCalRecurrenceRule` for recurrence instead of raw strings.

The key architectural change is that regions become controller-managed data (like events), not view-level configuration. This enables cross-view region enforcement — a timed blocking region on Mondays automatically blocks drops on Monday in both Day View and Month View.

## Steering Document Alignment

### Technical Standards (tech.md)
- **Controller Pattern**: Regions move to `MCalEventController`, following the established pattern where the controller is the single source of truth. This parallels how events, display date, and loading state are already managed.
- **Builder Pattern**: View-specific rendering continues via builder callbacks. The controller provides data; views decide presentation.
- **Delegation for Storage**: Like events, the controller manages regions in memory. Persistence is the consumer's responsibility.
- **Immutable Data Classes**: `MCalRegion` is immutable with a `const` constructor, following `MCalCalendarEvent` patterns.
- **`MCal` Prefix**: New class uses `MCalRegion` naming convention.

### Project Structure (structure.md)
- New model file in `lib/src/models/mcal_region.dart`
- Controller changes in `lib/src/controllers/mcal_event_controller.dart`
- View changes in `lib/src/widgets/mcal_day_view.dart` and `lib/src/widgets/mcal_month_view.dart`
- Context classes updated/added for unified region builder contexts
- Existing region files deprecated but retained

## Code Reuse Analysis

### Existing Components to Leverage
- **`MCalTimeRegion`** (`lib/src/models/mcal_time_region.dart`): `contains()`, `overlaps()`, and `expandedForDate()` logic will be adapted for the unified class. The recurrence expansion pattern (using `MCalRecurrenceRule`, handling COUNT edge cases, using µs offset for inclusive anchor matching) is directly reusable.
- **`MCalDayRegion`** (`lib/src/models/mcal_day_region.dart`): `appliesTo()` logic and its UNTIL handling will be adapted. The `_matchesDate()` helper is reusable.
- **`MCalEventController`** (`lib/src/controllers/mcal_event_controller.dart`): `addEvents()`, `removeEvents()`, `notifyListeners()` patterns will be followed for region management methods.
- **`MCalRecurrenceRule`** (`lib/src/models/mcal_recurrence_rule.dart`): Used directly as the `recurrenceRule` field type. Its `getOccurrences()` method replaces raw string parsing.
- **`MCalCalendarEvent`** (`lib/src/models/mcal_calendar_event.dart`): `isAllDay` field pattern and `copyWith`/`==`/`hashCode` implementation patterns are reused.

### Integration Points
- **Day View drag validation** (`_validateDrop` in `mcal_day_view.dart`): Currently iterates `widget.specialTimeRegions`. Will be updated to query controller.
- **Month View drag validation** (`validationCallback` in `mcal_month_view.dart`): Currently iterates `widget.dayRegions`. Will be updated to query controller.
- **Day View region rendering** (`_TimeRegionsLayer`): Currently reads `widget.specialTimeRegions`. Will be updated to read from controller.
- **Month View region rendering** (`_buildRegionOverlay`): Currently reads `widget.dayRegions`. Will be updated to read from controller.

## Architecture

### Data Flow

```
Developer creates MCalRegion instances
        │
        ▼
MCalEventController.addRegions([...])
        │
        ▼
Controller stores regions, calls notifyListeners()
        │
        ├──► MCalMonthView rebuilds
        │    ├── Queries controller.getAllDayRegionsForDate(date) for cell overlays
        │    └── Queries controller.isDateBlocked(date) + controller.isTimeRangeBlocked(start, end) for drag validation
        │
        └──► MCalDayView rebuilds
             ├── Queries controller.getTimedRegionsForDate(date) for time region overlays
             └── Queries controller.isTimeRangeBlocked(start, end) + controller.isDateBlocked(date) for drag validation
```

### Cross-View Validation Flow (Month View Example)

When a user drags a timed event (e.g., 3–4 PM) from Tuesday to Monday in Month View:

```
1. User drags event to Monday cell
2. Month View calls controller.isDateBlocked(monday)
   → checks all-day regions with blockInteraction: true
3. Month View calls controller.isTimeRangeBlocked(monday 3pm, monday 4pm)
   → checks timed regions with blockInteraction: true, expanded for Monday
4. If either returns true → reject drop, show invalid visual
5. If both return false → call consumer's onDragWillAccept (if provided)
```

## Components and Interfaces

### MCalRegion

- **Purpose:** Unified region model replacing both `MCalTimeRegion` and `MCalDayRegion`
- **File:** `lib/src/models/mcal_region.dart`
- **Interfaces:**
  - `const MCalRegion({required id, required start, required end, color, text, icon, blockInteraction, isAllDay, recurrenceRule, customData})`
  - `bool appliesTo(DateTime queryDate)` — does this region apply to the given date?
  - `bool overlaps(DateTime rangeStart, DateTime rangeEnd)` — does this timed region overlap the range?
  - `MCalRegion? expandedForDate(DateTime displayDate)` — concrete instance for a specific date
  - `bool contains(DateTime time)` — is the given time within this timed region?
  - `MCalRegion copyWith({...})`
- **Dependencies:** `MCalRecurrenceRule`

### MCalEventController (Region Extensions)

- **Purpose:** Central storage and query interface for regions
- **File:** `lib/src/controllers/mcal_event_controller.dart` (modify existing)
- **New Methods:**
  - `void addRegions(List<MCalRegion> regions)`
  - `void removeRegions(List<String> regionIds)`
  - `void clearRegions()`
  - `List<MCalRegion> get regions`
  - `List<MCalRegion> getRegionsForDate(DateTime date)`
  - `List<MCalRegion> getTimedRegionsForDate(DateTime date)`
  - `List<MCalRegion> getAllDayRegionsForDate(DateTime date)`
  - `bool isDateBlocked(DateTime date)`
  - `bool isTimeRangeBlocked(DateTime start, DateTime end)`
- **Internal Storage:** `final List<MCalRegion> _regions = [];`

### View Updates

- **MCalDayView** (`lib/src/widgets/mcal_day_view.dart`):
  - `_TimeRegionsLayer` reads from `widget.controller.getTimedRegionsForDate(displayDate)` instead of `widget.specialTimeRegions`
  - `_validateDrop()` queries `widget.controller.isTimeRangeBlocked()` and `widget.controller.isDateBlocked()`
  - `specialTimeRegions` parameter removed (old code removed in final cleanup phase)

- **MCalMonthView** (`lib/src/widgets/mcal_month_view.dart`):
  - `_buildRegionOverlay` reads from `widget.controller.getAllDayRegionsForDate(date)` instead of `widget.dayRegions`
  - Drag validation queries `widget.controller.isDateBlocked()` and `widget.controller.isTimeRangeBlocked()`
  - `dayRegions` parameter removed (old code removed in final cleanup phase)

## Data Models

### MCalRegion

```dart
class MCalRegion {
  final String id;
  final DateTime start;
  final DateTime end;
  final Color? color;
  final String? text;
  final IconData? icon;
  final bool blockInteraction;   // default: false
  final bool isAllDay;           // default: false
  final MCalRecurrenceRule? recurrenceRule;
  final Map<String, dynamic>? customData;
}
```

**Field semantics by `isAllDay`:**

| Field | `isAllDay: true` | `isAllDay: false` |
|-------|-------------------|--------------------|
| `start` | Anchor date (time ignored). For non-recurring: the specific date. For recurring: the anchor from which occurrences are calculated. | Start date/time (both date and time significant) |
| `end` | End date (time ignored). For single-day: same as `start`. For multi-day: last day of the range (inclusive). | End date/time (both date and time significant) |
| `appliesTo(date)` | True if `date` falls within `start`–`end` date range or matches a recurrence occurrence | True if `date` matches the date component of `start` or a recurrence occurrence |
| `overlaps(start, end)` | N/A (use `appliesTo` for all-day) | True if the timed range overlaps |
| `expandedForDate(date)` | Returns region with `start`/`end` adjusted to occurrence date | Returns region with `start`/`end` adjusted to occurrence date preserving time-of-day |

### Migration Mapping

| Old Class | New Equivalent |
|-----------|---------------|
| `MCalDayRegion(id, date, ...)` | `MCalRegion(id, start: date, end: date, isAllDay: true, ...)` |
| `MCalTimeRegion(id, startTime, endTime, ...)` | `MCalRegion(id, start: startTime, end: endTime, isAllDay: false, ...)` |
| `MCalDayRegion.recurrenceRule` (String?) | `MCalRegion.recurrenceRule` (MCalRecurrenceRule?) |
| `MCalTimeRegion.recurrenceRule` (String?) | `MCalRegion.recurrenceRule` (MCalRecurrenceRule?) |

## Migration Strategy

Old classes (`MCalTimeRegion`, `MCalDayRegion`) and view-level parameters (`specialTimeRegions`, `dayRegions`) are removed entirely — no deprecation period. To help the implementing agent, removal is deferred to a final cleanup phase after all new code is implemented and tested. During development, the old classes remain as reference material.

### Phasing

1. **Phases 1–4**: Implement `MCalRegion`, controller methods, view integration, and all tests. Old classes and parameters remain in the codebase but are not used by the new code paths.
2. **Phase 5**: Update example app to use `MCalRegion` on controller.
3. **Phase 6 (Cleanup)**: Remove `MCalTimeRegion`, `MCalDayRegion`, `MCalDayRegionContext`, `MCalTimeRegionContext`, the `specialTimeRegions` parameter, the `dayRegions` parameter, their exports, their test files, and all references. Update documentation.

## Error Handling

### Error Scenarios

1. **Duplicate region IDs:**
   - **Handling:** `addRegions()` replaces existing regions with the same ID (upsert semantics), matching `addEvents()` behavior.
   - **User Impact:** None — latest definition wins.

2. **Invalid recurrence rule:**
   - **Handling:** `appliesTo()` and `expandedForDate()` catch exceptions from `MCalRecurrenceRule.getOccurrences()` and return `false`/`null` (consistent with existing `MCalTimeRegion` and `MCalDayRegion` behavior).
   - **User Impact:** Region silently skipped for invalid dates.

3. **`end` before `start`:**
   - **Handling:** Constructor does not validate (consistent with `MCalCalendarEvent`). Methods handle gracefully (overlaps returns false, appliesTo uses date matching).
   - **User Impact:** Region has no effect.

## Testing Strategy

### Unit Testing
- `MCalRegion` model: constructor, `appliesTo()`, `overlaps()`, `contains()`, `expandedForDate()`, `copyWith()`, `==`/`hashCode`
- All-day vs timed behavior for each method
- Recurrence expansion with `MCalRecurrenceRule` (daily, weekly, monthly, with COUNT, UNTIL)
- Edge cases: midnight boundaries, DST transitions, multi-day all-day regions

### Controller Testing
- `addRegions()`, `removeRegions()`, `clearRegions()` with listener notifications
- `getRegionsForDate()`, `getTimedRegionsForDate()`, `getAllDayRegionsForDate()` with mixed region types
- `isDateBlocked()`, `isTimeRangeBlocked()` with various region configurations
- Cross-view scenario: timed blocking region blocks date in Month View context

### Widget Testing
- Day View reads timed regions from controller and renders overlays
- Month View reads all-day regions from controller and renders cell overlays
- Day View drag validation checks controller blocking methods
- Month View drag validation checks controller blocking methods (including timed region check for timed events)
- Backward compatibility: deprecated view-level parameters still work
- Combined: deprecated parameters + controller regions both applied

### Integration Testing
- Full drag-and-drop flow: drag event to blocked region → rejected → visual feedback
- Cross-view: define timed blocking region → Month View rejects drop on affected day for overlapping timed events
