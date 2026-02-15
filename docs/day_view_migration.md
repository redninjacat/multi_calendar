# Migrating to MCalDayView from Other Calendar Packages

This guide helps you migrate from popular Flutter calendar packages to `MCalDayView` in the `multi_calendar` package. It provides parameter mappings, side-by-side code examples, and migration patterns for common scenarios.

## Table of Contents

- [Overview](#overview)
- [Benefits of Switching](#benefits-of-switching)
- [Migration from table_calendar](#migration-from-table_calendar)
- [Migration from Syncfusion Flutter Calendar](#migration-from-syncfusion-flutter-calendar)
- [Migration from calendar_view (flutter_calendar_view)](#migration-from-calendar_view-flutter_calendar_view)
- [Migration from calendar_day_view](#migration-from-calendar_day_view)
- [Parameter Mapping Reference](#parameter-mapping-reference)
- [Breaking Changes and Different Patterns](#breaking-changes-and-different-patterns)
- [Troubleshooting](#troubleshooting)

---

## Overview

`MCalDayView` is a Day View calendar widget that displays events for a single day in a time-based vertical layout. It supports:

- **All-day events** — Section at top for events without specific times
- **Timed events** — Events positioned by start/end time with automatic overlap detection
- **Drag and drop** — Move events within day, across days, or convert all-day ↔ timed
- **Resize** — Drag event edges to change duration
- **Time regions** — Blocked time, lunch breaks, non-working hours
- **Current time indicator** — Live-updating line
- **Keyboard navigation** — Full accessibility support

---

## Benefits of Switching

| Benefit | Description |
|---------|-------------|
| **MIT License** | Free, open source — no commercial license required |
| **Unified API** | Same `MCalEventController` and `MCalCalendarEvent` for Day View and Month View |
| **Built-in overlap** | Automatic side-by-side layout for overlapping events |
| **Rich interactions** | Drag, resize, tap, long-press with magnetic snapping |
| **Extensive customization** | Builders for every visual element |
| **RTL support** | Right-to-left layout for Arabic, Hebrew, and other RTL languages |
| **Accessibility** | Keyboard shortcuts, screen reader support |

---

## Migration from table_calendar

**table_calendar** focuses on month/week grid views with event markers. It does not provide a true time-based day view. If you use table_calendar for event display and want a proper hourly schedule, switch to `MCalDayView`.

### Key Differences

| table_calendar | MCalDayView |
|----------------|-------------|
| `eventLoader` callback returns events per day | `MCalEventController` holds events; controller provides events for displayed date |
| `focusedDay` / `selectedDay` | `controller.displayDate` |
| `onDaySelected` | `onEventTap`, `onTimeSlotTap`, `onDayHeaderTap` |
| Events shown as markers (dots) in calendar cells | Events shown in time-based vertical layout |
| No built-in day view | Full day view with hour markers |

### Side-by-Side: Basic Setup

**table_calendar** (month view with events):

```dart
// table_calendar
TableCalendar(
  firstDay: DateTime.utc(2010, 1, 1),
  lastDay: DateTime.utc(2030, 12, 31),
  focusedDay: _focusedDay,
  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
  eventLoader: (day) => _getEventsForDay(day),
  onDaySelected: (selectedDay, focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedEvents = _getEventsForDay(selectedDay);
    });
  },
  onPageChanged: (focusedDay) {
    _focusedDay = focusedDay;
  },
);
```

**MCalDayView** (time-based day view):

```dart
// MCalDayView
final controller = MCalEventController(initialDate: DateTime.now());
controller.addEvents([
  MCalCalendarEvent(
    id: 'meeting',
    title: 'Team Meeting',
    start: DateTime(2026, 2, 14, 10, 0),
    end: DateTime(2026, 2, 14, 11, 0),
  ),
]);

MCalDayView(
  controller: controller,
  startHour: 8,
  endHour: 18,
  showNavigator: true,
  onEventTap: (details) => print('Tapped ${details.event.title}'),
  onDisplayDateChanged: (date) => print('Now viewing $date'),
);
```

### Event Data Conversion

**table_calendar** uses `eventLoader` with any event type:

```dart
// table_calendar - your events
final events = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
);

eventLoader: (day) => events[day] ?? [],
```

**MCalDayView** uses `MCalCalendarEvent`:

```dart
// MCalDayView - convert your events
List<MCalCalendarEvent> convertToMCalEvents(Map<DateTime, List<MyEvent>> events) {
  final result = <MCalCalendarEvent>[];
  for (final entry in events.entries) {
    for (final e in entry.value) {
      result.add(MCalCalendarEvent(
        id: e.id,
        title: e.title,
        start: e.start ?? DateTime(entry.key.year, entry.key.month, entry.key.day),
        end: e.end ?? DateTime(entry.key.year, entry.key.month, entry.key.day, 23, 59),
      ));
    }
  }
  return result;
}

controller.addEvents(convertToMCalEvents(myEvents));
```

---

## Migration from Syncfusion Flutter Calendar

**SfCalendar** provides day, week, schedule, and timeline views. It uses `CalendarDataSource` and appointment objects. **Note:** Syncfusion requires a commercial or community license.

### Key Differences

| Syncfusion SfCalendar | MCalDayView |
|-----------------------|-------------|
| `CalendarDataSource` | `MCalEventController` |
| `CalendarView.day` | `MCalDayView` (single view) |
| `TimeSlotViewSettings(startHour, endHour)` | `startHour`, `endHour` |
| `CalendarDataSource` subclasses | `MCalCalendarEvent` model |
| `getStartTime`, `getEndTime`, `getSubject` | `start`, `end`, `title` on event |

### Side-by-Side: Basic Setup

**Syncfusion**:

```dart
// Syncfusion
SfCalendar(
  view: CalendarView.day,
  dataSource: MeetingDataSource(_getDataSource()),
  timeSlotViewSettings: TimeSlotViewSettings(
    startHour: 9,
    endHour: 16,
    nonWorkingDays: [DateTime.friday, DateTime.saturday],
  ),
);

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }
  @override
  DateTime getStartTime(int index) => appointments![index].from;
  @override
  DateTime getEndTime(int index) => appointments![index].to;
  @override
  String getSubject(int index) => appointments![index].eventName;
  @override
  Color getColor(int index) => appointments![index].background;
  @override
  bool isAllDay(int index) => appointments![index].isAllDay;
}
```

**MCalDayView**:

```dart
// MCalDayView
final controller = MCalEventController(initialDate: DateTime.now());
controller.addEvents(_getDataSource().map((m) => MCalCalendarEvent(
  id: m.id ?? '${m.eventName}-${m.from.millisecondsSinceEpoch}',
  title: m.eventName,
  start: m.from,
  end: m.to,
  isAllDay: m.isAllDay,
  color: m.background,
)).toList());

MCalDayView(
  controller: controller,
  startHour: 9,
  endHour: 16,
  specialTimeRegions: [
    // After-hours: gray out and block drops (like non-working time)
    MCalTimeRegion(
      id: 'after-hours',
      startTime: DateTime(2026, 2, 14, 16, 0),
      endTime: DateTime(2026, 2, 14, 23, 59),
      color: Colors.grey.withValues(alpha: 0.5),
      blockInteraction: true,
    ),
  ],
);
```

### Side-by-Side: Event Tap

**Syncfusion**:

```dart
// Syncfusion
SfCalendar(
  onTap: (details) {
    if (details.appointments != null && details.appointments!.isNotEmpty) {
      final appointment = details.appointments!.first;
      // Handle tap
    }
  },
);
```

**MCalDayView**:

```dart
// MCalDayView
MCalDayView(
  controller: controller,
  onEventTap: (details) {
    final event = details.event;
    // Handle tap - details.event, details.tapPosition, etc.
  },
);
```

---

## Migration from calendar_view (flutter_calendar_view)

**calendar_view** provides `DayView`, `WeekView`, and `MonthView`. It uses `CalendarControllerProvider` and `CalendarEventData`.

### Key Differences

| calendar_view | MCalDayView |
|---------------|-------------|
| `CalendarControllerProvider` + `EventController` | `MCalEventController` |
| `CalendarEventData` | `MCalCalendarEvent` |
| `DayView(controller: ...)` | `MCalDayView(controller: ...)` |
| `heightPerMinute` | `hourHeight` (pixels per hour; divide by 60 for per-minute) |
| `eventTileBuilder` | `timedEventTileBuilder`, `allDayEventTileBuilder` |
| `onEventTap` | `onEventTap` |
| `showVerticalLine` | `showCurrentTimeIndicator` |
| `eventArranger: SideEventArranger()` | Built-in overlap detection |

### Side-by-Side: Basic Setup

**calendar_view**:

```dart
// calendar_view
CalendarControllerProvider(
  controller: EventController(),
  child: MaterialApp(
    home: Scaffold(
      body: DayView(
        controller: EventController(),
        eventTileBuilder: (date, events, boundry, start, end) {
          return Container(/* custom tile */);
        },
        fullDayEventBuilder: (events, date) => Container(/* all-day */),
        showVerticalLine: true,
        heightPerMinute: 1,
        startHour: 5,
        endHour: 20,
        eventArranger: SideEventArranger(),
        onEventTap: (events, date) => print(events),
      ),
    ),
  ),
);
```

**MCalDayView**:

```dart
// MCalDayView
final controller = MCalEventController(initialDate: DateTime.now());
controller.addEvents([/* your events */]);

MCalDayView(
  controller: controller,
  startHour: 5,
  endHour: 20,
  hourHeight: 60, // 60 px per hour = 1 px per minute (like heightPerMinute: 1)
  showCurrentTimeIndicator: true,
  timedEventTileBuilder: (context, ctx, defaultTile) {
    return Container(/* custom tile using ctx.event, ctx.start, ctx.end */);
  },
  allDayEventTileBuilder: (context, ctx, defaultTile) {
    return Container(/* all-day */);
  },
  onEventTap: (details) => print(details.event),
);
```

### Event Data Conversion

**calendar_view** `CalendarEventData`:

```dart
// calendar_view
CalendarEventData(
  date: DateTime(2021, 8, 10),
  endDate: DateTime(2021, 8, 10, 12, 0),
  event: "Event 1",
);
```

**MCalDayView** `MCalCalendarEvent`:

```dart
// MCalDayView
MCalCalendarEvent(
  id: 'event-1',
  title: 'Event 1',
  start: DateTime(2021, 8, 10),
  end: DateTime(2021, 8, 10, 12, 0),
  isAllDay: false,
);
```

---

## Migration from calendar_day_view

**calendar_day_view** offers specialized day view types (Category Day View, Overflow Day View, etc.). It uses `DayView` with `Event` model.

### Key Differences

| calendar_day_view | MCalDayView |
|-------------------|-------------|
| `Event` model | `MCalCalendarEvent` |
| `DayView` with `events` | `MCalDayView` with `controller` |
| `startTime` / `endTime` | `startHour` / `endHour` |
| `timeSlotDuration` | `timeSlotDuration` |
| Category-based views | Single day view; use builders for custom grouping |

### Side-by-Side: Basic Setup

**calendar_day_view**:

```dart
// calendar_day_view
DayView(
  events: myEvents,
  startTime: TimeOfDay(hour: 8, minute: 0),
  endTime: TimeOfDay(hour: 18, minute: 0),
  timeSlotDuration: Duration(minutes: 30),
  onEventTap: (event) => print(event),
);
```

**MCalDayView**:

```dart
// MCalDayView
final controller = MCalEventController(initialDate: DateTime.now());
controller.addEvents(myEvents.map((e) => MCalCalendarEvent(
  id: e.id,
  title: e.title,
  start: e.start,
  end: e.end,
  isAllDay: e.isAllDay ?? false,
)).toList());

MCalDayView(
  controller: controller,
  startHour: 8,
  endHour: 18,
  timeSlotDuration: const Duration(minutes: 30),
  onEventTap: (details) => print(details.event),
);
```

---

## Parameter Mapping Reference

| Feature | table_calendar | Syncfusion | calendar_view | MCalDayView |
|---------|----------------|------------|---------------|-------------|
| Display date | `focusedDay` | `controller.displayDate` | `initialDay` | `controller.displayDate` |
| Time range | N/A | `startHour`, `endHour` | `startHour`, `endHour` | `startHour`, `endHour` |
| Hour height | N/A | `timeIntervalHeight` | `heightPerMinute` | `hourHeight` |
| Event model | Any (via loader) | `CalendarDataSource` | `CalendarEventData` | `MCalCalendarEvent` |
| Event tap | `onDaySelected` + list | `onTap` | `onEventTap` | `onEventTap` |
| All-day events | In event list | `isAllDay` | `fullDayEventBuilder` | `allDayEventTileBuilder` |
| Current time | N/A | Built-in | `showVerticalLine` | `showCurrentTimeIndicator` |
| Overlap | N/A | Built-in | `eventArranger` | Built-in |
| Drag/drop | N/A | Built-in | Limited | `enableDragToMove` |
| Resize | N/A | Built-in | Limited | `enableDragToResize` |

---

## Breaking Changes and Different Patterns

### 1. Controller vs. Provider

- **Syncfusion / calendar_view**: Use `CalendarController` or `CalendarControllerProvider` at app level.
- **MCalDayView**: Use `MCalEventController` — create it where you need it, pass to widget. No provider required.

### 2. Event Model

- **Other packages**: Custom models or `CalendarEventData` with `date`, `endDate`, `event`.
- **MCalDayView**: `MCalCalendarEvent` with `id`, `title`, `start`, `end`, `isAllDay`. Always provide `id`.

### 3. Event Loading

- **table_calendar**: `eventLoader` returns events per day on demand.
- **MCalDayView**: Add events to controller with `addEvents` or implement `loadEvents` in controller for async loading.

### 4. All-Day vs. Timed

- **MCalDayView**: Use `isAllDay: true` for all-day events. `start` and `end` can have same date; time is ignored for all-day.

### 5. Builders

- **MCalDayView**: Uses `timedEventTileBuilder`, `allDayEventTileBuilder`, `dayHeaderBuilder`, etc. Pass `(context, ctx, defaultTile)` — you can customize or wrap `defaultTile`.

---

## Troubleshooting

### Events not appearing

**Cause:** Events not in range of displayed date, or controller not updated.

**Solution:** Ensure events are added to the controller and that `start`/`end` fall on the displayed day. Use `controller.addEvents()` or `controller.loadEvents()`.

```dart
controller.addEvents([
  MCalCalendarEvent(
    id: '1',
    title: 'Meeting',
    start: controller.displayDate.add(const Duration(hours: 10)),
    end: controller.displayDate.add(const Duration(hours: 11)),
  ),
]);
```

### Drag/drop not working

**Cause:** `enableDragToMove` is false (default).

**Solution:** Set `enableDragToMove: true` and handle `onEventDropped` to persist changes.

```dart
MCalDayView(
  controller: controller,
  enableDragToMove: true,
  onEventDropped: (details) {
    // Update your backend; controller updates the event automatically
    persistEvent(details.event, details.newStartDate, details.newEndDate);
  },
);
```

### Resize handles missing

**Cause:** `enableDragToResize` is false or null (defaults to `enableDragToMove`).

**Solution:** Set `enableDragToResize: true` or `enableDragToMove: true` (resize inherits from move when null).

### Theme not applying

**Cause:** `theme` not passed or `MCalThemeData` not applied.

**Solution:** Pass `theme` to `MCalDayView`:

```dart
MCalDayView(
  controller: controller,
  theme: MCalThemeData(
    hourGridlineColor: Colors.grey.shade300,
    currentTimeIndicatorColor: Colors.red,
  ),
);
```

### Overlap layout looks wrong

**Cause:** Events with identical start/end or very short duration.

**Solution:** Ensure events have valid `start` < `end`. Use `timeSlotDuration` of at least 15 minutes for clean snapping.

### Scroll behavior issues

**Cause:** `autoScrollToCurrentTime` or `scrollController` conflict.

**Solution:** Disable `autoScrollToCurrentTime` if you manage scroll manually, or avoid attaching `scrollController` to multiple widgets.

### Keyboard shortcuts not working

**Cause:** `enableKeyboardNavigation` is false or focus not on the widget.

**Solution:** Set `enableKeyboardNavigation: true` and ensure the Day View has focus (e.g., after tapping an event with `autoFocusOnEventTap: true`).

### RTL layout issues

**Cause:** Locale or `Directionality` not set for RTL.

**Solution:** Pass `locale: const Locale('ar')` or wrap in `Directionality(textDirection: TextDirection.rtl, child: MCalDayView(...))`.

---

## Next Steps

- [Day View Documentation](day_view.md) — Full API and usage guide
- [Example app](../example/) — Run the demo app for Day View examples
- [API reference](https://pub.dev/documentation/multi_calendar/latest/) — Full Dart API docs
