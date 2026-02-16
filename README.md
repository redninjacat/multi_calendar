# Multi Calendar

A flexible Flutter package for displaying calendar views with full RFC 5545 RRULE support. This package provides separate widgets for Day, Multi-day, and Month views, offering greater modularity and customization compared to single-widget calendar solutions.

## Table of Contents

- [Features](#features)
- [Getting Started](#getting-started)
- [Package Structure](#package-structure)
- [MCalMonthView](#mcalmonthview)
- [MCalDayView](#mcaldayview)
- [Example](#example)
- [Requirements](#requirements)
- [Contributing](#contributing)

## Features

- **Multiple Calendar Views**: Separate widgets for Day, Multi-day (configurable day count), and Month views
- **Day View**: Time-based vertical layout with hour markers, all-day events, overlap detection, drag-and-drop, resize, keyboard navigation, and special time regions
- **RFC 5545 RRULE Support**: Full support for recurring event rules with exception handling
- **Flexible Time Ranges**: Configurable time ranges for Day and Multi-day views (e.g., 8am-8pm)
- **Event Controller Pattern**: Single controller that dynamically loads events based on visible date range
- **Drag and Drop**: Move events between dates/times via drag-and-drop
- **Event Resizing**: Resize event tiles to change duration (hours on time views, days on month/all-day)
- **External Event Management**: Package handles display only; storage and CRUD operations delegated to external classes
- **Customizable Event Tiles**: Builder callbacks for event tiles on all views
- **Localization & Globalization**: Display dates/times using globalized formats, localize all static calendar text
- **Accessibility**: Full screen reader support
- **Right-to-Left (RTL) Support**: RTL direction support for languages like Hebrew and Arabic
- **Mobile-First Design**: Optimized for mobile devices while scaling to larger screens

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  multi_calendar: ^0.0.1
```

Then run:

```bash
flutter pub get
```

### Basic Usage

```dart
import 'package:multi_calendar/multi_calendar.dart';

// Create an event controller (defaults to showing current month)
final controller = MCalEventController();

// Or specify an initial date to display
final controller = MCalEventController(initialDate: DateTime(2024, 6, 15));

// Create calendar events
final event = MCalCalendarEvent(
  id: 'event-1',
  title: 'Team Meeting',
  start: DateTime(2024, 1, 15, 10, 0),
  end: DateTime(2024, 1, 15, 11, 0),
  comment: 'Quarterly planning',
  isAllDay: false,
);

// Create an all-day event
final allDayEvent = MCalCalendarEvent(
  id: 'event-2',
  title: 'Holiday',
  start: DateTime(2024, 1, 20, 0, 0),
  end: DateTime(2024, 1, 20, 0, 0),
  isAllDay: true,
);

// Display month view
MCalMonthView(
  controller: controller,
  showNavigator: true,
  enableSwipeNavigation: true,
  onCellTap: (context, details) {
    print('Tapped on ${details.date} with ${details.events.length} events');
  },
  onEventTap: (context, details) {
    print('Tapped on event: ${details.event.title}');
  },
)
```

## Package Structure

- **MCalCalendarEvent**: Data model for calendar events (includes `isAllDay` field for all-day event support)
- **MCalEventController**: Controller for managing calendar events and view state
- **MCalMonthView**: Month calendar view widget (available now)
- **MCalDayView**: Day calendar view widget — see [Day View documentation](docs/day_view.md)
- **MCalMultiDayView**: Multi-day calendar view widget (coming soon)
- **MCalThemeData**: Theme extension for calendar-specific styling (supports nested [MCalDayThemeData] and [MCalMonthThemeData])
- **MCalDayThemeData**: Day View–specific theme properties (time legend, gridlines, ticks, etc.)
- **MCalMonthThemeData**: Month View–specific theme properties (event tiles, overflow, etc.)
- **MCalLocalizations**: Built-in support for English, Spanish, French, Arabic, and Hebrew (with RTL for Arabic and Hebrew)

## MCalMonthView

`MCalMonthView` displays a traditional month calendar grid showing days of the month with events displayed as tiles.

### Basic Usage

```dart
final controller = MCalEventController();

MCalMonthView(
  controller: controller,
)
```

### Parameters

#### Required Parameters

- **`controller`** (`MCalEventController`): The event controller for loading and managing calendar events.

#### Optional Parameters

**Date Configuration:**
- **`minDate`** (`DateTime?`): The minimum date that can be displayed.
- **`maxDate`** (`DateTime?`): The maximum date that can be displayed.
- **`firstDayOfWeek`** (`int?`): The first day of the week (0 = Sunday, 1 = Monday, etc.).

**Navigation:**
- **`showNavigator`** (`bool`): Whether to show the month navigator (defaults to `true`).
- **`enableSwipeNavigation`** (`bool`): Whether swipe gestures are enabled (defaults to `false`).
- **`swipeNavigationDirection`** (`MCalSwipeNavigationDirection`): Direction for swipe navigation (defaults to `horizontal`).

**Theme:**
- **`theme`** (`MCalThemeData?`): Custom theme data for calendar styling.

**Builder Callbacks:**
- **`dayCellBuilder`**: Custom builder for day cell rendering.
- **`eventTileBuilder`**: Custom builder for event tile rendering.
- **`dayHeaderBuilder`**: Custom builder for weekday header rendering.
- **`navigatorBuilder`**: Custom builder for navigator rendering.
- **`dateLabelBuilder`**: Custom builder for date label rendering.
- **`weekLayoutBuilder`**: Custom builder for week row event layout (Layer 2).
- **`overflowIndicatorBuilder`**: Custom builder for "+N more" overflow indicators.

**Interactivity:**
- **`cellInteractivityCallback`**: Callback to determine if a cell is interactive.
- **`onCellTap`**: Callback when a day cell is tapped.
- **`onCellLongPress`**: Callback when a day cell is long-pressed.
- **`onCellDoubleTap`**: Callback when a day cell is double-tapped (e.g., create event).
- **`onEventTap`**: Callback when an event tile is tapped.
- **`onEventLongPress`**: Callback when an event tile is long-pressed.
- **`onEventDoubleTap`**: Callback when an event tile is double-tapped (e.g., open details).
- **`onSwipeNavigation`**: Callback when a swipe navigation gesture is detected.

**Event Resizing:**
- **`enableDragToResize`** (`bool?`): Whether to enable edge-drag resizing. `null` (default) auto-detects by platform.
- **`onResizeWillAccept`**: Validation callback during resize. Return `false` to reject.
- **`onEventResized`**: Completion callback when resize finishes. Return `false` to revert.

**Animation:**
- **`enableAnimations`** (`bool?`): Controls month transition animations. `null` (default) follows OS reduced motion preference. `true`/`false` are explicit overrides.

**Localization:**
- **`dateFormat`** (`String?`): Custom date format string.
- **`locale`** (`Locale?`): Locale for date formatting and localization.

### Theme Customization

Theme properties are organized into **nested theme classes** for clarity:

- **`MCalThemeData`** — Root theme; holds shared properties and optional `dayTheme` / `monthTheme`.
- **`MCalDayThemeData`** — Day View–specific: time legend, gridlines, time legend ticks, current time indicator, etc.
- **`MCalMonthThemeData`** — Month View–specific: event tiles, overflow indicators, weekday headers, etc.

#### Nested Theme Structure

```dart
MCalTheme(
  data: MCalThemeData(
    // Shared
    cellBackgroundColor: Colors.white,
    todayBackgroundColor: Colors.blue,
    // Day View–specific
    dayTheme: MCalDayThemeData(
      timeLegendWidth: 56,
      showTimeLegendTicks: true,
      timeLegendTickColor: Colors.grey,
      timeLegendTickLength: 8,
    ),
    // Month View–specific
    monthTheme: MCalMonthThemeData(
      eventTileHeight: 24,
      weekdayHeaderTextStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  child: MCalMonthView(controller: controller),
)
```

**Migration from flat theme:** If you previously used flat properties (e.g. `weekdayHeaderTextStyle` on `MCalThemeData`), move them into `monthTheme` or `dayTheme`:

```dart
// Before (deprecated flat structure)
MCalThemeData(weekdayHeaderTextStyle: myStyle)

// After (nested structure)
MCalThemeData(monthTheme: MCalMonthThemeData(weekdayHeaderTextStyle: myStyle))
```

#### Time Legend Ticks (Day View)

Customize tick marks on the Day View time legend:

```dart
MCalThemeData(
  dayTheme: MCalDayThemeData(
    showTimeLegendTicks: true,
    timeLegendTickColor: Colors.grey.withOpacity(0.5),
    timeLegendTickWidth: 1.0,
    timeLegendTickLength: 8.0,
  ),
)
```

#### 1. Wrap with MCalTheme InheritedWidget

```dart
MCalTheme(
  data: MCalThemeData(
    cellBackgroundColor: Colors.white,
    todayBackgroundColor: Colors.blue,
  ),
  child: MCalMonthView(
    controller: controller,
  ),
)
```

#### 2. Use ThemeData extension

```dart
ThemeData(
  extensions: [
    MCalThemeData(
      cellBackgroundColor: Colors.white,
      todayBackgroundColor: Colors.blue,
      eventTileBackgroundColor: Colors.green,
      monthTheme: MCalMonthThemeData(
        weekdayHeaderTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    ),
  ],
)
```

#### Theme Access via Context

Access theme data anywhere in the widget tree using `MCalTheme.of(context)`:

```dart
Widget build(BuildContext context) {
  final theme = MCalTheme.of(context);
  return Container(
    color: theme.cellBackgroundColor,
  );
}
```

The fallback chain is:
1. `MCalTheme` InheritedWidget ancestor
2. `Theme.of(context).extension<MCalThemeData>()`
3. `MCalThemeData.fromTheme(Theme.of(context))` (auto-derived from theme)

Use `MCalTheme.maybeOf(context)` to get `null` if no explicit theme is set.

### Callback API Pattern

All callbacks follow a standardized `(BuildContext, Details)` pattern for consistency and enhanced functionality. The `BuildContext` enables theme access via `MCalTheme.of(context)`, while the Details object provides all relevant data.

#### Cell Callbacks

```dart
MCalMonthView(
  controller: controller,
  onCellTap: (context, details) {
    print('Date: ${details.date}');
    print('Events: ${details.events.length}');
    print('Is current month: ${details.isCurrentMonth}');
  },
  onCellLongPress: (context, details) {
    // Same MCalCellTapDetails
  },
)
```

#### Event Callbacks

```dart
MCalMonthView(
  controller: controller,
  onEventTap: (context, details) {
    print('Event: ${details.event.title}');
    print('Display date: ${details.displayDate}');
  },
  onEventLongPress: (context, details) {
    // Same MCalEventTapDetails
  },
  onEventDoubleTap: (context, details) {
    // Open event details or edit dialog
    print('Double-tapped: ${details.event.title} at ${details.localPosition}');
  },
)
```

#### Double-Tap Callbacks

Use `onCellDoubleTap` and `onEventDoubleTap` for quick-create or quick-edit flows:

```dart
MCalMonthView(
  controller: controller,
  onCellDoubleTap: (context, details) {
    // Create new event on this date
    showCreateEventDialog(context, details.date);
  },
  onEventDoubleTap: (context, details) {
    // Open event editor
    showEditEventDialog(context, details.event);
  },
)
```

#### Details Classes

| Class | Properties | Used By |
|-------|-----------|---------|
| `MCalCellTapDetails` | `date`, `events`, `isCurrentMonth` | `onCellTap`, `onCellLongPress` |
| `MCalCellDoubleTapDetails` | `date`, `localPosition`, `globalPosition` | `onCellDoubleTap` |
| `MCalEventTapDetails` | `event`, `displayDate` | `onEventTap`, `onEventLongPress` |
| `MCalEventDoubleTapDetails` | `event`, `displayDate`, `localPosition`, `globalPosition` | `onEventDoubleTap` |
| `MCalSwipeNavigationDetails` | `previousMonth`, `newMonth`, `direction` | `onSwipeNavigation` |
| `MCalOverflowTapDetails` | `date`, `allEvents`, `hiddenCount` | `onOverflowTap`, `onOverflowLongPress` |
| `MCalCellInteractivityDetails` | `date`, `isCurrentMonth`, `isSelectable` | `cellInteractivityCallback` |
| `MCalErrorDetails` | `error`, `onRetry` | `errorBuilder` |

### Builder Callbacks

#### Custom Day Cell

```dart
MCalMonthView(
  controller: controller,
  dayCellBuilder: (context, ctx, defaultCell) {
    if (ctx.isToday) {
      final theme = MCalTheme.of(context);
      return Container(
        decoration: BoxDecoration(
          color: theme.todayBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: defaultCell,
      );
    }
    return defaultCell;
  },
)
```

#### Custom Event Tile

```dart
MCalMonthView(
  controller: controller,
  eventTileBuilder: (context, tileContext, defaultTile) {
    // Access segment info for multi-day events
    final segment = tileContext.segment;
    
    // Apply different styling for first/last segments
    final leftRadius = segment?.isFirstSegment == true ? 4.0 : 0.0;
    final rightRadius = segment?.isLastSegment == true ? 4.0 : 0.0;
    
    return Container(
      decoration: BoxDecoration(
        color: tileContext.event.color,
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(leftRadius),
          right: Radius.circular(rightRadius),
        ),
      ),
      child: defaultTile,
    );
  },
)
```

**MCalEventTileContext properties:**

| Property | Description |
|----------|-------------|
| `event` | The calendar event being rendered |
| `displayDate` | The date the tile is displayed on |
| `isAllDay` | Whether the event is an all-day event |
| `segment` | `MCalEventSegment` with multi-day positioning info |
| `width` | Tile width in pixels |
| `height` | Tile height in pixels |

#### Overflow Indicator

When more events exist than can be displayed, an overflow indicator appears:

```dart
MCalMonthView(
  controller: controller,
  overflowIndicatorBuilder: (context, overflowContext, defaultIndicator) {
    return GestureDetector(
      onTap: () => showAllEvents(overflowContext.date, overflowContext.hiddenEvents),
      child: Text('+${overflowContext.hiddenEventCount} more'),
    );
  },
)
```

**Note:** The overflow indicator does not support drag-and-drop. Only visible event tiles can be dragged. Users must tap the overflow indicator to reveal hidden events in a separate view if they need to drag them.

**MCalOverflowIndicatorContext properties:**

| Property | Description |
|----------|-------------|
| `date` | The date with overflow |
| `hiddenEventCount` | Number of hidden events |
| `hiddenEvents` | List of hidden events |
| `visibleEvents` | List of visible events |
| `width` | Indicator width in pixels |
| `height` | Indicator height in pixels |

### Swipe Navigation

The calendar supports PageView-style swipe navigation with smooth animations and peek preview of adjacent months.

```dart
MCalMonthView(
  controller: controller,
  enableSwipeNavigation: true,
  swipeNavigationDirection: MCalSwipeNavigationDirection.horizontal,
  minDate: DateTime(2024, 1, 1),
  maxDate: DateTime(2024, 12, 31),
  onSwipeNavigation: (context, details) {
    print('From: ${details.previousMonth}');
    print('To: ${details.newMonth}');
    print('Direction: ${details.direction}');
  },
)
```

**Key behaviors:**
- Smooth 60fps animations during swipe
- Peek preview shows next/previous month while swiping
- Bounce-back effect at `minDate`/`maxDate` boundaries
- Works with both touch and trackpad gestures

**Programmatic Navigation:**

```dart
// Animate to a specific month
controller.setDisplayDate(DateTime(2024, 6, 1));

// Navigate without animation (instant jump)
controller.setDisplayDate(DateTime(2024, 6, 1), animate: false);

// Or use the convenience method
controller.navigateToDateWithoutAnimation(DateTime(2024, 6, 1));
```

### Navigator Controls

```dart
MCalMonthView(
  controller: controller,
  showNavigator: true,
  navigatorBuilder: (context, navigatorContext) {
    // Custom navigator UI
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: navigatorContext.canNavigatePrevious
              ? navigatorContext.navigatePrevious
              : null,
        ),
        Text(navigatorContext.displayMonth),
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed: navigatorContext.canNavigateNext
              ? navigatorContext.navigateNext
              : null,
        ),
      ],
    );
  },
)
```

### Localization

The package supports **5 languages** out of the box: **English (en)**, **Spanish (es)**, **French (fr)**, **Arabic (ar)**, and **Hebrew (he)**. Arabic and Hebrew use right-to-left (RTL) layout automatically.

```dart
// English
MCalMonthView(controller: controller, locale: Locale('en'))

// Spanish (Mexico)
MCalMonthView(controller: controller, locale: Locale('es', 'MX'))

// French
MCalMonthView(controller: controller, locale: Locale('fr'))

// Arabic (RTL)
MCalMonthView(controller: controller, locale: Locale('ar'))

// Hebrew (RTL)
MCalMonthView(controller: controller, locale: Locale('he'))

// Custom date format
MCalMonthView(
  controller: controller,
  dateFormat: 'MMM d',
  locale: Locale('en'),
)
```

**Adding a new language:** Add an ARB file (e.g. `app_de.arb`) in `lib/l10n/` with the same keys as `app_en.arb`, run `flutter gen-l10n`, and ensure your app includes the new locale in `supportedLocales` and `localizationsDelegates` (including `MCalLocalizations.delegate`).

### Accessibility

`MCalMonthView` includes built-in accessibility support:

- All day cells have semantic labels describing the date
- Event tiles have semantic labels with event details
- Multi-day event tiles include span information (e.g., "3-day event, day 2 of 3") for screen readers
- Navigator buttons have descriptive labels
- Screen reader announcements for month/year changes
- Keyboard-based event moving and resizing with announcements at every step (see [Keyboard Navigation](#keyboard-navigation))
- Resize handles have semantic labels ("Resize start edge" / "Resize end edge")
- `enableAnimations: null` (default) automatically respects the OS "Reduce Motion" accessibility setting

The widget automatically integrates with Flutter's accessibility system and works with screen readers like VoiceOver (iOS) and TalkBack (Android).

### RTL Support

`MCalMonthView` automatically detects and supports right-to-left languages:

```dart
MCalMonthView(
  controller: controller,
  locale: Locale('ar'), // Arabic - RTL
)
```

The calendar grid, navigator buttons, and weekday headers automatically flip for RTL layouts.

### Keyboard Navigation

`MCalMonthView` supports full keyboard navigation when focused:

**Cell Navigation:**

| Key | Action |
|-----|--------|
| `←` `→` `↑` `↓` | Navigate between cells |
| `Enter` / `Space` | Select the focused cell (or enter event selection mode if drag-and-drop is enabled) |
| `Home` | Jump to first day of month |
| `End` | Jump to last day of month |
| `Page Up` | Previous month |
| `Page Down` | Next month |

**Keyboard Event Moving** (when `enableDragToMove` is `true`):

| Key | Action |
|-----|--------|
| `Enter` / `Space` | Enter event selection mode on the focused cell |
| `Tab` / `Shift+Tab` | Cycle through events when multiple exist on a cell |
| `Enter` | Confirm event selection, then confirm move |
| `←` `→` | Move the selected event by 1 day |
| `↑` `↓` | Move the selected event by 1 week |
| `Escape` | Cancel the move |

**Keyboard Event Resizing** (when both `enableDragToMove` and `enableDragToResize` are enabled):

| Key | Action |
|-----|--------|
| `R` | Enter resize mode (from event selection/move mode) |
| `S` | Switch to resizing the start edge |
| `E` | Switch to resizing the end edge |
| `←` `→` | Adjust the active edge by 1 day |
| `↑` `↓` | Adjust the active edge by 1 week |
| `M` | Return to move mode |
| `Enter` | Confirm the resize |
| `Escape` | Cancel the resize |

Screen reader announcements are provided at every step of both keyboard move and resize interactions.

```dart
MCalMonthView(
  controller: controller,
  enableKeyboardNavigation: true, // Default: true
  autoFocusOnCellTap: true, // Default: true
  onFocusedDateChanged: (date) {
    print('Focus moved to: $date');
  },
)
```

### Hover Support

For desktop applications, `MCalMonthView` provides hover callbacks:

```dart
MCalMonthView(
  controller: controller,
  onHoverCell: (cellContext) {
    if (cellContext != null) {
      print('Hovering: ${cellContext.date}, Events: ${cellContext.events.length}');
    }
  },
  onHoverEvent: (eventContext) {
    if (eventContext != null) {
      print('Hovering event: ${eventContext.event.title}');
    }
  },
)
```

### Display Date vs Focused Date

The controller manages two date concepts:

- **Display Date**: The currently visible month (set via `setDisplayDate()`)
- **Focused Date**: The cell with keyboard focus (set via `setFocusedDate()`)

```dart
final controller = MCalEventController();

// Navigate to a specific month
controller.setDisplayDate(DateTime(2024, 6, 1));

// Set keyboard focus to a specific date
controller.setFocusedDate(DateTime(2024, 6, 15));

// Or navigate and focus in one call
controller.navigateToDate(DateTime(2024, 6, 15), focus: true);
```

### Week Numbers

Display ISO week numbers on the leading edge of the calendar:

```dart
MCalMonthView(
  controller: controller,
  showWeekNumbers: true,
  weekNumberBuilder: (context, weekContext) {
    // Optional: customize week number display
    return Center(
      child: Text('W${weekContext.weekNumber}'),
    );
  },
)
```

### Animations

Control month transition animations:

```dart
MCalMonthView(
  controller: controller,
  enableAnimations: null, // Default: null (follow OS preference)
  animationDuration: Duration(milliseconds: 300), // Default
  animationCurve: Curves.easeInOut, // Default
)
```

`enableAnimations` is a nullable `bool?` with three behaviors:

| Value | Behavior |
|-------|----------|
| `null` (default) | Follows the OS reduced motion accessibility setting. Animations are disabled when the system has "Reduce Motion" enabled, and enabled otherwise. |
| `true` | Force animations on regardless of OS setting (developer override). |
| `false` | Force animations off regardless of OS setting (backward compatible). |

The `setDisplayDate(date, animate: false)` and `navigateToDateWithoutAnimation()` methods always skip animation regardless of this setting.

### Week Layout Builder

MCalMonthView uses a 3-layer architecture for rendering:

- **Layer 1**: Calendar grid (day cells, backgrounds, borders)
- **Layer 2**: Events, date labels, and overflow indicators
- **Layer 3**: Drag-and-drop feedback (ghost tiles)

Customize event layout with `weekLayoutBuilder`:

```dart
MCalMonthView(
  controller: controller,
  weekLayoutBuilder: (context, layoutContext) {
    // layoutContext provides:
    // - segments: List<MCalEventSegment> for this week
    // - dates: 7 DateTime objects for each day
    // - eventTileBuilder, dateLabelBuilder, overflowIndicatorBuilder
    // - config: MCalWeekLayoutConfig with layout settings
    
    // Return a Widget that positions events for this week row
    return MCalDefaultWeekLayoutBuilder.build(context, layoutContext);
  },
)
```

**MCalWeekLayoutContext properties:**

| Property | Description |
|----------|-------------|
| `segments` | List of `MCalEventSegment` objects for the week |
| `dates` | 7 `DateTime` objects for each day in the week |
| `config` | `MCalWeekLayoutConfig` with layout settings |
| `eventTileBuilder` | Pre-wrapped builder for event tiles |
| `dateLabelBuilder` | Pre-wrapped builder for date labels |
| `overflowIndicatorBuilder` | Pre-wrapped builder for overflow indicators |

**MCalEventSegment properties:**

| Property | Description |
|----------|-------------|
| `event` | The calendar event |
| `weekRowIndex` | Which week row (0-based) |
| `startDayInWeek` | Starting day column (0-6) |
| `endDayInWeek` | Ending day column (0-6) |
| `isFirstSegment` | True if this is the event's first week segment |
| `isLastSegment` | True if this is the event's last week segment |
| `spanDays` | Number of days this segment spans |
| `isSingleDay` | True if segment spans only one day |

### Drag-and-Drop

Enable drag-and-drop to move events between dates.

```dart
MCalMonthView(
  controller: controller,
  enableDragToMove: true,
  dragEdgeNavigationDelay: Duration(milliseconds: 500),
  onEventDropped: (context, details) {
    print('Moved ${details.event.title}');
    print('From: ${details.oldStartDate} - ${details.oldEndDate}');
    print('To: ${details.newStartDate} - ${details.newEndDate}');
    
    // Return true to confirm, false to revert
    return updateEventInBackend(details);
  },
  onDragWillAccept: (context, details) {
    // Validate drop target
    if (details.proposedStartDate.isBefore(DateTime.now())) {
      return false; // Can't drop on past dates
    }
    return true;
  },
)
```

**Drag behaviors:**
- Long-press (default 200ms, configurable via `dragLongPressDelay`) initiates drag
- Visual feedback shows valid/invalid drop targets
- Events preserve duration when moved
- Escape key cancels drag
- Cross-month dragging supported with edge navigation

#### Validation and Revert

Two callbacks control whether a drop succeeds and whether the UI reverts:

- **`onDragWillAccept`** (validation): Called as the pointer moves over potential drop targets. Return `false` to reject the proposed range (cells show invalid/red highlight; releasing does nothing). Return `true` (or omit the callback) to accept.

- **`onEventDropped`** (revert): Called when the user releases over a valid target. Return `true` to confirm the move; the event stays at the new dates. Return `false` to revert; the package restores the event to its original position.

```dart
onEventDropped: (context, details) {
  // If persistence fails, return false to revert
  final success = persistToBackend(details);
  return success;
}
```

#### Async Persistence

`onEventDropped` is synchronous and must return `bool` immediately. For async persistence:

1. **Optimistic confirm**: Return `true` right away, persist in the background, and if the operation fails, revert via the controller (e.g. `controller.addEvents` with the original event).

2. **Blocking wait**: If you can afford to block the UI, use a synchronous wrapper (e.g. `Future.value(...).then((v) => v)` with a run-loop wait—not recommended for long operations).

3. **Loading + confirm**: Show a loading overlay before/during the drop, perform the async work, then either let the move stand or revert via the controller. The callback itself still returns `true` or `false` synchronously based on your immediate decision.

#### Drop Target Builder Precedence

Drop target visuals come from two layers, each with its own builders:

| Layer | Purpose | Builder | Precedence |
|-------|---------|---------|------------|
| Layer 3 | Phantom event tiles (where the event would land) | `dropTargetTileBuilder` | Builder or default tile |
| Layer 4 | Cell highlight overlay | `dropTargetOverlayBuilder` | **1.** overlay builder |
| Layer 4 | Cell highlight overlay | `dropTargetCellBuilder` | **2.** cell builder (per-cell) |
| Layer 4 | Cell highlight overlay | (default) | **3.** built-in `CustomPainter` |

For Layer 4, only one path is used: `dropTargetOverlayBuilder` > `dropTargetCellBuilder` > default. If both overlay and cell builders are provided, the overlay builder is used.

Toggle layers with `showDropTargetTiles` (Layer 3) and `showDropTargetOverlay` (Layer 4). Both default to `true`.

#### Custom Drag Visuals

```dart
MCalMonthView(
  controller: controller,
  enableDragToMove: true,
  // Dragged tile (follows pointer)
  draggedTileBuilder: (context, details) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(8),
        child: Text(details.event.title),
      ),
    );
  },
  // Source placeholder (where the tile was)
  dragSourceTileBuilder: (context, details) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  },
  // Layer 3: Phantom tiles showing drop position
  dropTargetTileBuilder: (context, tileContext) {
    return Container(
      decoration: BoxDecoration(
        color: (tileContext.dropValid ?? true)
            ? Colors.blue.withOpacity(0.3)
            : Colors.red.withOpacity(0.3),
      ),
    );
  },
  // Layer 4 (per-cell): Highlight each target cell
  dropTargetCellBuilder: (context, details) {
    return Container(
      decoration: BoxDecoration(
        color: details.isValid
            ? Colors.green.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.horizontal(
          left: details.isFirst ? Radius.circular(8) : Radius.zero,
          right: details.isLast ? Radius.circular(8) : Radius.zero,
        ),
      ),
    );
  },
  // Layer 4 (full overlay): Alternative to dropTargetCellBuilder
  dropTargetOverlayBuilder: (context, details) {
    return Stack(
      children: details.highlightedCells.map((cell) {
        return Positioned.fromRect(
          rect: cell.bounds,
          child: Container(
            decoration: BoxDecoration(
              color: details.isValid
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
            ),
          ),
        );
      }).toList(),
    );
  },
)
```

**Drag-related Details classes:**

| Class | Properties | Used By |
|-------|-----------|---------|
| `MCalDraggedTileDetails` | `event`, `sourceDate`, `currentPosition` | `draggedTileBuilder` |
| `MCalDragSourceDetails` | `event`, `sourceDate` | `dragSourceTileBuilder` |
| `MCalEventTileContext` (drop target) | `event`, `displayDate`, `isDropTargetPreview`, `dropValid`, `proposedStartDate`, `proposedEndDate` | `dropTargetTileBuilder` |
| `MCalDragWillAcceptDetails` | `event`, `proposedStartDate`, `proposedEndDate` | `onDragWillAccept` |
| `MCalDropTargetCellDetails` | `date`, `bounds`, `isValid`, `isFirst`, `isLast`, `cellIndex`, `weekRowIndex` | `dropTargetCellBuilder` |
| `MCalDropOverlayDetails` | `highlightedCells`, `isValid`, `dayWidth`, `calendarSize`, `dragData` | `dropTargetOverlayBuilder` |
| `MCalEventDroppedDetails` | `event`, `oldStartDate`, `oldEndDate`, `newStartDate`, `newEndDate` | `onEventDropped` |

**Cross-month drag navigation:**

When dragging near the left/right edges, the calendar auto-navigates to the adjacent month after `dragEdgeNavigationDelay`. The drag continues seamlessly across months, respecting `minDate`/`maxDate` boundaries.

**cellInteractivityCallback and onDragWillAccept together:**

- `cellInteractivityCallback` controls whether a cell receives tap, long-press, and keyboard focus. Returning `false` disables those interactions for that cell.
- `onDragWillAccept` validates drop targets during drag. It is called when the proposed drop range changes. Return `false` to reject the drop (red highlight, drop reverted on release).
- `cellInteractivityCallback` does **not** block drag-and-drop. A cell that returns `false` from `cellInteractivityCallback` can still receive dropped events unless you also return `false` from `onDragWillAccept` for that target. Use both together when you want to disable both tap and drop (e.g., past dates, weekends).

### Event Resizing

Enable edge-drag resizing to let users change event start or end dates by dragging the edges of event tiles.

```dart
MCalMonthView(
  controller: controller,
  enableDragToMove: true, // Required — resize uses drag infrastructure
  enableDragToResize: null, // Default: null (auto-detect by platform)
  onResizeWillAccept: (context, details) {
    // Validate proposed dates (e.g., reject weekends)
    if (details.proposedEndDate.weekday == DateTime.saturday ||
        details.proposedEndDate.weekday == DateTime.sunday) {
      return false;
    }
    return true;
  },
  onEventResized: (context, details) {
    print('Resized "${details.event.title}" ${details.resizeEdge.name} edge');
    print('Old: ${details.oldStartDate} - ${details.oldEndDate}');
    print('New: ${details.newStartDate} - ${details.newEndDate}');

    // Return true to confirm, false to revert
    return updateEventInBackend(details);
  },
)
```

**`enableDragToResize`** is a nullable `bool?`:

| Value | Behavior |
|-------|----------|
| `null` (default) | Auto-detects by platform: enabled on web, desktop, and tablets (shortest side >= 600dp); disabled on phones. |
| `true` | Force resize on regardless of platform. |
| `false` | Force resize off regardless of platform. |

**Note:** `enableDragToResize` requires `enableDragToMove` to be `true` — the resize interaction uses the same drag infrastructure.

**Custom resize handles:**

- **`resizeHandleBuilder`**: Optional builder that replaces the default white bar visual indicator. Receives a `MCalResizeHandleContext` with the edge (`start`/`end`), event, and whether this is a drop-target preview handle.
- **`resizeHandleInset`**: Optional callback returning a horizontal inset (in logical pixels) to shift the handle inward from the tile edge. Useful for custom tile builders where the visual content is narrower than the slot (e.g. a centered pill). Receives `MCalEventTileContext` and `MCalResizeEdge`.

**Resize behaviors:**
- Drag the leading edge (left in LTR, right in RTL) to change the start date
- Drag the trailing edge (right in LTR, left in RTL) to change the end date
- Minimum duration is 1 day — the start edge cannot be dragged past the end edge, and vice versa
- Visual preview updates in real-time during the drag (reuses the same Layer 3/4 system as drag-and-drop)
- Resize handles appear on multi-day event tiles only (single-day events are already at minimum)
- Resizing a recurring event occurrence creates a `modified` exception, similar to how drag-and-drop creates a `rescheduled` exception for moves

**Resize Details classes:**

| Class | Properties | Used By |
|-------|-----------|---------|
| `MCalResizeWillAcceptDetails` | `event`, `proposedStartDate`, `proposedEndDate`, `resizeEdge` | `onResizeWillAccept` |
| `MCalEventResizedDetails` | `event`, `oldStartDate`, `oldEndDate`, `newStartDate`, `newEndDate`, `resizeEdge`, `isRecurring`, `seriesId` | `onEventResized` |
| `MCalResizeEdge` | Enum: `start`, `end` | Used within details |

Keyboard-based resizing is also supported as an accessibility alternative — see [Keyboard Navigation](#keyboard-navigation).

### Event Display Control

Limit the number of visible events per cell:

```dart
MCalMonthView(
  controller: controller,
  maxVisibleEventsPerDay: 5, // Default: 5
  onOverflowTap: (context, details) {
    // Custom handler for "+N more" tap
    print('${details.hiddenCount} more events on ${details.date}');
    showEventListDialog(context, details.allEvents);
  },
)
```

### Loading and Error States

Display loading and error overlays using controller state:

```dart
final controller = MCalEventController();

// Show loading overlay
controller.setLoading(true);

// Show error overlay
controller.setError('Failed to load events');

// Clear error
controller.clearError();

// Custom builders
MCalMonthView(
  controller: controller,
  loadingBuilder: (context) {
    return Center(child: CircularProgressIndicator());
  },
  errorBuilder: (context, details) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Error: ${details.error}'),
        if (details.onRetry != null)
          ElevatedButton(
            onPressed: details.onRetry,
            child: Text('Retry'),
          ),
      ],
    );
  },
)
```

### Multi-View Synchronization

Share a controller between multiple views to keep them synchronized:

```dart
final sharedController = MCalEventController();

// Both views share the same controller and stay in sync
Row(
  children: [
    Expanded(
      child: MCalMonthView(
        controller: sharedController,
        showNavigator: true,
      ),
    ),
    Expanded(
      child: MCalMonthView(
        controller: sharedController,
        showNavigator: false, // Controlled by the first view
      ),
    ),
  ],
)
```

When you navigate in one view, all views sharing the controller update together.

## MCalDayView

`MCalDayView` displays a single day in a time-based vertical layout with hour markers, gridlines, and interactive event tiles. It is ideal for scheduling apps, task management, resource booking, and daily agenda views.

### Day View vs Month View

| Aspect | MCalDayView | MCalMonthView |
|--------|-------------|---------------|
| **Layout** | Vertical timeline with hour slots | Grid of days in month |
| **Focus** | Single day, time-of-day precision | Full month overview |
| **Events** | Positioned by start/end time; overlap detection | Tiles in day cells; multi-day spanning |
| **Use case** | Scheduling, meetings, time-blocking | Month-at-a-glance, planning |
| **Time range** | Configurable (e.g., 8am–6pm) | Full day cells |
| **Special regions** | Time regions (lunch, blocked hours) | N/A |

### Quick Start

```dart
import 'package:multi_calendar/multi_calendar.dart';

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
  ),
]);

MCalDayView(
  controller: controller,
  startHour: 8,
  endHour: 18,
  showNavigator: true,
  enableDragToMove: true,
  onEventTap: (context, details) {
    print('Tapped: ${details.event.title}');
  },
)
```

### Key Features

- **All-day events** — Section at top for events without specific times
- **Timed events** — Positioned by start/end time with automatic overlap detection
- **Drag and drop** — Move events within day, across days, or convert all-day ↔ timed
- **Resize** — Drag event edges to change duration
- **Time regions** — Blocked time, lunch breaks, non-working hours
- **Current time indicator** — Live-updating line marking current time
- **Keyboard navigation** — Full keyboard support for accessibility

### Documentation

For complete Day View documentation, including configuration options, builders, theming, and troubleshooting, see [Day View documentation](docs/day_view.md).

## Example

See the [example](example/) directory for a complete example application demonstrating package usage, including:
- **Features Demo**: Interactive showcase of keyboard navigation, hover feedback, week numbers, animations, event resizing, keyboard move/resize shortcuts, multi-view sync, and loading/error states
- **Day View**: Time-based layout with hour markers, all-day events, overlap detection, drag-and-drop, and time regions
- **Multi-Day Events**: Contiguous tile rendering across cells and weeks
- **Drag-and-Drop**: Move events between dates with visual feedback
- **Event Resizing**: Drag event edges to change duration, with validation and keyboard alternatives
- Basic MCalMonthView and MCalDayView usage
- Theme customization with multiple styles (Default, Modern, Classic, Minimal, Colorful)
- Builder callbacks with the new `(BuildContext, Details)` pattern
- PageView-style swipe navigation
- Localization (English and Spanish)
- Accessibility features

## Requirements

- Flutter SDK: `>=1.17.0`
- Dart SDK: `^3.10.4`

## Performance Expectations

- **Drag-and-drop:** The month view targets **60fps** during continuous drag (pointer move and highlight updates). Drag state and drop-target highlighting are updated synchronously; avoid heavy work in `onDragWillAccept` or `onEventDropped` on the UI thread to keep frame times under ~16ms. The package includes performance-style tests that assert drag-move updates complete within a frame-rate budget.

## Known Limitations

- **Recurring events:** Drag-and-drop moves the displayed instance only — creating a `rescheduled` exception. Resizing a recurring occurrence creates a `modified` exception. In both cases, the recurrence rule itself is not updated. Use `onEventDropped` or `onEventResized` to persist changes in your backend (e.g., create an exception or update the rule).
- **Overflow indicator:** The "+N more" overflow indicator does not support drag-and-drop or resizing. Only visible event tiles can be dragged or resized. Users must tap the overflow indicator to reveal hidden events in a separate view if they need to manipulate them.
- **Resize on phones:** Event resizing is disabled by default on phones (small screen, small touch targets). Set `enableDragToResize: true` to force-enable it if your app has sufficiently large event tiles.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

See [LICENSE](LICENSE) file for details.

## Additional Information

This package is currently in early development. Core features are being implemented incrementally. See the [CHANGELOG](CHANGELOG.md) for version history and planned features.
