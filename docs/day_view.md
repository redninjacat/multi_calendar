# MCalDayView — Day View Documentation

A comprehensive guide to the Day View calendar widget in the `multi_calendar` Flutter package. The Day View displays events for a single day in a time-based vertical layout with hour markers, gridlines, and interactive event tiles.

## Table of Contents

- [Overview and Use Cases](#overview-and-use-cases)
- [Basic Setup and Usage](#basic-setup-and-usage)
- [Configuration Options](#configuration-options)
- [Event Display](#event-display)
- [Drag and Drop](#drag-and-drop)
- [Resize](#resize)
- [Time Slots and Gridlines](#time-slots-and-gridlines)
- [Navigation and Scrolling](#navigation-and-scrolling)
- [Callbacks and Events](#callbacks-and-events)
- [Theming](#theming)
- [Accessibility Features](#accessibility-features)
- [RTL Support](#rtl-support)
- [API Reference](#api-reference)
- [Troubleshooting](#troubleshooting)

---

## Overview and Use Cases

`MCalDayView` is a Day View calendar widget that displays events for a single day in a vertical timeline. It is ideal for:

- **Scheduling apps** — Show hourly schedule with meetings and appointments
- **Task management** — Time-block tasks throughout the day
- **Resource booking** — Display availability and bookings
- **Personal calendars** — Daily agenda with all-day and timed events
- **Work day planners** — Focus on business hours (e.g., 8 AM–6 PM)

### Key Features

| Feature | Description |
|--------|-------------|
| All-day events | Section at top for events without specific times |
| Timed events | Events positioned by start/end time with overlap detection |
| Drag and drop | Move events within day, across days, or convert all-day ↔ timed |
| Resize | Drag event edges to change duration |
| Time regions | Blocked time, lunch breaks, non-working hours |
| Current time indicator | Live-updating line marking current time |
| Keyboard navigation | Full keyboard support for accessibility |
| Customizable | Builders for every visual element |

---

## Basic Setup and Usage

### Installation

Add `multi_calendar` to your `pubspec.yaml`:

```yaml
dependencies:
  multi_calendar: ^0.0.1
```

### Minimal Example

```dart
import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MCalEventController(initialDate: DateTime.now());
    controller.addEvents([
      MCalCalendarEvent(
        id: 'meeting',
        title: 'Team Meeting',
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 11, 0),
      ),
      MCalCalendarEvent(
        id: 'lunch',
        title: 'Lunch',
        start: DateTime(2026, 2, 14, 12, 0),
        end: DateTime(2026, 2, 14, 13, 0),
        isAllDay: false,
      ),
    ]);

    return MaterialApp(
      home: Scaffold(
        body: MCalDayView(
          controller: controller,
          startHour: 8,
          endHour: 18,
          showNavigator: true,
          enableDragToMove: true,
        ),
      ),
    );
  }
}
```

### With Event Controller

The Day View uses `MCalEventController` to manage events and display date. Share the same controller with `MCalMonthView` for synchronized multi-view apps:

```dart
final controller = MCalEventController(initialDate: DateTime.now());

// Use in Day View
MCalDayView(
  controller: controller,
  showNavigator: true,
)

// Same controller in Month View — stays in sync
MCalMonthView(
  controller: controller,
  showNavigator: false,
)
```

---

## Configuration Options

### Time Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `startHour` | `int` | 0 | First hour displayed (0–23) |
| `endHour` | `int` | 23 | Last hour displayed (0–23) |
| `timeSlotDuration` | `Duration` | 15 min | Snapping granularity for drag/resize |
| `hourHeight` | `double?` | null | Pixel height per hour (null = auto) |
| `gridlineInterval` | `Duration` | 15 min | Interval between gridlines (1, 5, 10, 15, 20, 30, 60) |

```dart
MCalDayView(
  controller: controller,
  startHour: 8,
  endHour: 18,
  timeSlotDuration: const Duration(minutes: 15),
  gridlineInterval: const Duration(minutes: 30),
  hourHeight: 80.0, // Spacious timeline
)
```

### Display Options

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `showNavigator` | `bool` | false | Show Previous/Today/Next navigation bar |
| `showCurrentTimeIndicator` | `bool` | true | Show live current time line |
| `showWeekNumber` | `bool` | false | Show ISO week number in header |

### All-Day Section

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `allDaySectionMaxRows` | `int` | 3 | Max rows before overflow indicator |
| `allDayToTimedDuration` | `Duration` | 1 hour | Duration when converting all-day → timed |

---

## Event Display

### All-Day Events

All-day events appear in a section at the top of the Day View. They span the full width and do not have time-based positioning.

```dart
MCalCalendarEvent(
  id: 'holiday',
  title: 'Company Holiday',
  start: DateTime(2026, 2, 14, 0, 0),
  end: DateTime(2026, 2, 14, 0, 0),
  isAllDay: true,
)
```

### Timed Events

Timed events are positioned vertically according to their start and end times. Overlapping events are laid out side-by-side automatically.

```dart
MCalCalendarEvent(
  id: 'meeting',
  title: 'Team Standup',
  start: DateTime(2026, 2, 14, 9, 0),
  end: DateTime(2026, 2, 14, 9, 30),
  isAllDay: false,
)
```

### Overlapping Events

When multiple events overlap in time, the Day View automatically:

1. Detects overlaps using start/end times
2. Assigns events to columns to avoid visual overlap
3. Renders events side-by-side with proportional widths

No configuration needed — overlap handling is built-in. Use `MCalTimedEventTileContext.columnIndex` and `totalColumns` in custom builders to style overlapping events differently.

### Custom Event Tiles

```dart
MCalDayView(
  controller: controller,
  allDayEventTileBuilder: (context, ctx, defaultTile) {
    return Container(
      decoration: BoxDecoration(
        color: ctx.event.color ?? Colors.blue,
        borderRadius: BorderRadius.circular(4),
      ),
      child: defaultTile,
    );
  },
  timedEventTileBuilder: (context, ctx, defaultTile) {
    return Container(
      decoration: BoxDecoration(
        color: ctx.event.color ?? Colors.green,
        borderRadius: BorderRadius.circular(8),
      ),
      child: defaultTile,
    );
  },
)
```

**Context objects:** See [MCalAllDayEventTileContext] and [MCalTimedEventTileContext] in the API documentation.

---

## Drag and Drop

Enable drag-and-drop to move events within the day, across days (via edge navigation), and convert between all-day and timed.

### Basic Setup

```dart
MCalDayView(
  controller: controller,
  enableDragToMove: true,
  onEventDropped: (details) {
    // Persist to backend; controller updates the event automatically
    persistEvent(details.event, details.newStartDate, details.newEndDate);
  },
)
```

### Drag Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enableDragToMove` | `bool` | false | Enable long-press drag |
| `dragLongPressDelay` | `Duration` | 200 ms | Delay before drag starts |
| `dragEdgeNavigationEnabled` | `bool` | true | Navigate to prev/next day when dragging near edge |
| `dragEdgeNavigationDelay` | `Duration` | 1200 ms | Delay before edge navigation |
| `showDropTargetPreview` | `bool` | true | Show phantom tile at drop position |
| `showDropTargetOverlay` | `bool` | true | Highlight target time slot |

### Type Conversion

Dragging an all-day event into the timed area converts it to a timed event (using `allDayToTimedDuration`). Dragging a timed event into the all-day area converts it to all-day. Check `MCalEventDroppedDetails.typeConversion` for `'allDayToTimed'` or `'timedToAllDay'`.

### Validation

Use `onDragWillAccept` to reject invalid drops (e.g., past dates, blocked regions):

```dart
MCalDayView(
  controller: controller,
  enableDragToMove: true,
  onDragWillAccept: (details) {
    if (details.proposedStartDate.isBefore(DateTime.now())) {
      return false; // Can't drop on past
    }
    return true;
  },
)
```

### Custom Drag Visuals

```dart
MCalDayView(
  controller: controller,
  enableDragToMove: true,
  draggedTileBuilder: (context, details) {
    return Material(
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Text(details.event.title),
      ),
    );
  },
  dropTargetTileBuilder: (context, tileContext, defaultTile) {
    final valid = tileContext.dropValid ?? true;
    return Container(
      color: valid ? Colors.blue.withOpacity(0.3) : Colors.red.withOpacity(0.3),
      child: defaultTile,
    );
  },
)
```

---

## Resize

Enable resize to change event duration by dragging the top or bottom edge of timed events.

### Setup

```dart
MCalDayView(
  controller: controller,
  enableDragToMove: true,  // Required for resize
  enableDragToResize: true, // or null for platform auto-detect
  onEventResized: (details) {
    persistResizedEvent(details);
  },
)
```

**`enableDragToResize`** (`bool?`):

| Value | Behavior |
|-------|----------|
| `null` (default) | Auto: enabled on desktop/web/tablet, disabled on phones |
| `true` | Force enable |
| `false` | Force disable |

### Validation

```dart
onResizeWillAccept: (details) {
  // Reject resize to weekends
  if (details.proposedEndDate.weekday == DateTime.saturday ||
      details.proposedEndDate.weekday == DateTime.sunday) {
    return false;
  }
  return true;
},
```

### Custom Resize Handle

```dart
timeResizeHandleBuilder: (context, event, edge) {
  return Container(
    height: 8,
    color: Colors.blue,
    child: Center(
      child: Icon(edge == MCalResizeEdge.start ? Icons.expand_less : Icons.expand_more),
    ),
  );
}
```

---

## Time Slots and Gridlines

### Time Slot Duration

`timeSlotDuration` controls snapping during drag and resize. Common values: 15, 30, or 60 minutes.

### Gridline Interval

`gridlineInterval` controls horizontal lines. Valid: 1, 5, 10, 15, 20, 30, or 60 minutes. Gridlines are classified as:

- **Hour** — On the hour (e.g., 9:00, 10:00)
- **Major** — 30-minute marks when interval < 30
- **Minor** — Other interval boundaries

### Custom Gridlines

```dart
MCalDayView(
  controller: controller,
  gridlineInterval: const Duration(minutes: 30),
  gridlineBuilder: (context, ctx, defaultLine) {
    if (ctx.type == MCalGridlineType.hour) {
      return Container(color: Colors.grey, height: 1);
    }
    return defaultLine;
  },
)
```

### Snapping

Events snap to time slots, other event boundaries, and current time when within `snapRange` (default 5 minutes):

```dart
MCalDayView(
  controller: controller,
  snapToTimeSlots: true,
  snapToOtherEvents: true,
  snapToCurrentTime: true,
  snapRange: const Duration(minutes: 5),
)
```

---

## Navigation and Scrolling

### Day Navigation

Use the built-in navigator or programmatic control:

```dart
MCalDayView(
  controller: controller,
  showNavigator: true,
  onNavigatePrevious: () => controller.setDisplayDate(prevDay),
  onNavigateNext: () => controller.setDisplayDate(nextDay),
  onNavigateToday: () => controller.setDisplayDate(DateTime.now()),
)

// Programmatic
controller.setDisplayDate(DateTime(2026, 2, 15));
controller.navigateToDateWithoutAnimation(DateTime(2026, 2, 15));
```

### Scrolling

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `autoScrollToCurrentTime` | `bool` | true | Scroll to current time on load |
| `initialScrollTime` | `TimeOfDay?` | null | Override initial scroll target |
| `scrollController` | `ScrollController?` | null | External scroll controller |
| `scrollPhysics` | `ScrollPhysics?` | null | Custom scroll physics |

```dart
MCalDayView(
  controller: controller,
  autoScrollToCurrentTime: true,
  initialScrollTime: const TimeOfDay(hour: 9, minute: 0), // Start at 9 AM
)
```

---

## Callbacks and Events

### Interaction Callbacks

| Callback | When Fired |
|----------|------------|
| `onEventTap` | User taps an event tile |
| `onEventLongPress` | User long-presses an event |
| `onDayHeaderTap` | User taps the day header |
| `onTimeSlotTap` | User taps an empty time slot |
| `onTimeSlotLongPress` | User long-presses an empty time slot |
| `onEmptySpaceDoubleTap` | User double-taps empty area (create event) |
| `onOverflowTap` | User taps "+N more" overflow indicator |

### Example: Create Event on Double-Tap

```dart
MCalDayView(
  controller: controller,
  onEmptySpaceDoubleTap: (tappedTime) async {
    final event = await showCreateEventDialog(
      context,
      initialTime: tappedTime,
      displayDate: controller.displayDate,
    );
    if (event != null) {
      controller.addEvents([event]);
    }
  },
)
```

### Example: Edit on Tap

```dart
MCalDayView(
  controller: controller,
  onEventTap: (context, details) {
    showEventDetailDialog(
      context,
      details.event,
      onEdit: () => editEvent(details.event),
      onDelete: () => deleteEvent(details.event),
    );
  },
)
```

### Example: Create Event on Time Slot Tap

```dart
MCalDayView(
  controller: controller,
  onTimeSlotTap: (slotContext) {
    final time = DateTime(
      slotContext.displayDate.year,
      slotContext.displayDate.month,
      slotContext.displayDate.day,
      slotContext.hour ?? 0,
      slotContext.minute ?? 0,
    );
    showCreateEventDialog(context, initialTime: time);
  },
)
```

### Details Classes

| Class | Properties |
|-------|------------|
| `MCalEventTapDetails` | `event`, `displayDate` |
| `MCalEventDroppedDetails` | `event`, `oldStartDate`, `oldEndDate`, `newStartDate`, `newEndDate`, `typeConversion` |
| `MCalEventResizedDetails` | `event`, `oldStartDate`, `oldEndDate`, `newStartDate`, `newEndDate`, `resizeEdge` |

---

## Theming

### MCalThemeData

Use `MCalTheme` or `ThemeData.extensions` to customize Day View appearance:

```dart
MCalTheme(
  data: MCalThemeData(
    hourGridlineColor: Colors.grey.shade300,
    hourGridlineWidth: 1.0,
    majorGridlineColor: Colors.grey.shade200,
    minorGridlineColor: Colors.grey.shade100,
    currentTimeIndicatorColor: Colors.red,
    currentTimeIndicatorWidth: 2.0,
    currentTimeIndicatorDotRadius: 6.0,
    timeLegendTextStyle: TextStyle(fontSize: 12, color: Colors.grey),
    timedEventMinHeight: 24.0,
    timedEventBorderRadius: 8.0,
    timedEventPadding: EdgeInsets.all(8),
    allDayEventBackgroundColor: Colors.blue.shade100,
    dayHeaderDayOfWeekStyle: TextStyle(fontWeight: FontWeight.bold),
    dayHeaderDateStyle: TextStyle(fontSize: 24),
  ),
  child: MCalDayView(controller: controller),
)
```

### Day View Theme Properties

| Property | Description |
|----------|-------------|
| `hourGridlineColor`, `hourGridlineWidth` | Hour boundary lines |
| `majorGridlineColor`, `majorGridlineWidth` | Major subdivision (e.g., 30 min) |
| `minorGridlineColor`, `minorGridlineWidth` | Minor subdivision |
| `currentTimeIndicatorColor`, `currentTimeIndicatorWidth`, `currentTimeIndicatorDotRadius` | Current time line |
| `timeLegendWidth`, `timeLegendTextStyle`, `timeLegendBackgroundColor` | Time column |
| `timedEventMinHeight`, `timedEventBorderRadius`, `timedEventPadding` | Timed event tiles |
| `allDayEventBackgroundColor`, `allDayEventTextStyle` | All-day section |
| `dayHeaderDayOfWeekStyle`, `dayHeaderDateStyle` | Day header |
| `specialTimeRegionColor`, `blockedTimeRegionColor` | Time regions |

### Per-Widget Theme

```dart
MCalDayView(
  controller: controller,
  theme: MCalThemeData(
    currentTimeIndicatorColor: Colors.blue,
  ),
)
```

---

## Special Time Regions

Display blocked time, lunch breaks, or non-working hours:

```dart
MCalDayView(
  controller: controller,
  specialTimeRegions: [
    MCalTimeRegion(
      id: 'lunch',
      startTime: DateTime(2026, 2, 14, 12, 0),
      endTime: DateTime(2026, 2, 14, 13, 0),
      color: Colors.amber.withValues(alpha: 0.3),
      text: 'Lunch Break',
      icon: Icons.restaurant,
      blockInteraction: false,
    ),
    MCalTimeRegion(
      id: 'after-hours',
      startTime: DateTime(2026, 2, 14, 18, 0),
      endTime: DateTime(2026, 2, 14, 23, 59),
      color: Colors.grey.withValues(alpha: 0.5),
      text: 'After Hours',
      blockInteraction: true,
    ),
  ],
  timeRegionBuilder: (context, ctx) {
    return Container(
      color: ctx.region.color ?? Colors.grey.withValues(alpha: 0.2),
      child: Center(child: Text(ctx.region.text ?? '')),
    );
  },
)
```

Recurring regions use RFC 5545 RRULE:

```dart
MCalTimeRegion(
  id: 'focus',
  startTime: DateTime(2026, 2, 14, 9, 0),
  endTime: DateTime(2026, 2, 14, 10, 0),
  recurrenceRule: 'FREQ=DAILY;COUNT=30',
  color: Colors.blue.withValues(alpha: 0.2),
  text: 'Focus Time',
  blockInteraction: true,
)
```

---

## Accessibility Features

### Screen Reader Support

- Day header, time labels, and events have semantic labels
- Event tiles announce title, time range, and overlap info
- Navigator buttons have descriptive labels

### Keyboard Navigation

When `enableKeyboardNavigation` is true (default):

| Key | Action |
|-----|--------|
| `Tab` / `Shift+Tab` | Cycle focus between events |
| `Enter` / `Space` | Activate focused event |
| `←` `→` | Move event by 1 day |
| `↑` `↓` | Move event by 1 time slot |
| `R` | Enter resize mode |
| `S` / `E` | Switch resize edge (start/end) |
| `Escape` | Cancel move/resize |

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Cmd/Ctrl+N` | Create new event |
| `Cmd/Ctrl+E` | Edit focused event |
| `Cmd/Ctrl+D` or `Delete` | Delete focused event |

Override via `keyboardShortcuts`:

```dart
MCalDayView(
  controller: controller,
  keyboardShortcuts: {
    SingleActivator(LogicalKeyboardKey.keyN, meta: true): MCalDayViewCreateEventIntent(),
  },
  onCreateEventRequested: () => showCreateDialog(),
  onEditEventRequested: (event) => showEditDialog(event),
  onDeleteEventRequested: (event) => confirmDelete(event),
)
```

### Reduced Motion

`enableAnimations: null` (default) respects the OS "Reduce Motion" setting.

---

## RTL Support

Day View automatically supports right-to-left layouts when the locale is RTL (e.g., Arabic, Hebrew):

```dart
MCalDayView(
  controller: controller,
  locale: const Locale('ar'),
)
```

Time legend, gridlines, and event layout flip for RTL.

---

## Troubleshooting

For common issues and solutions, see the [Troubleshooting Guide](troubleshooting.md). It covers:

- Events not appearing
- Drag/drop not working
- Resize handles missing
- Theme not applying
- Performance issues
- Overlap layout problems
- Scroll behavior issues
- Keyboard shortcuts not working
- RTL layout issues

---

## API Reference

Run `dart doc .` to generate API documentation, or see [pub.dev](https://pub.dev/packages/multi_calendar) for the published package docs.

### Main Widget

- **MCalDayView** — Day View widget

### Context Objects (for builders)

- **MCalDayHeaderContext** — Day header
- **MCalTimeLabelContext** — Time legend labels
- **MCalGridlineContext** — Gridlines
- **MCalTimedEventTileContext** — Timed event tiles
- **MCalAllDayEventTileContext** — All-day event tiles
- **MCalCurrentTimeContext** — Current time indicator
- **MCalTimeRegionContext** — Special time regions

### Models

- **MCalTimeRegion** — Special time region model
- **MCalCalendarEvent** — Event model
- **MCalEventController** — Event controller

### Related Documentation

- [Troubleshooting](troubleshooting.md) — Common issues and solutions
- [README](../README.md) — Package overview and Month View docs
- **MCalThemeData** — Full theme reference (see `lib/src/styles/mcal_theme.dart`)
- [Example app](../example/) — Complete Day View examples with multiple styles
