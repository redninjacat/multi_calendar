# Multi Calendar

A flexible Flutter package for displaying calendar views with full RFC 5545 RRULE support. This package provides separate widgets for Day, Multi-day, and Month views, offering greater modularity and customization compared to single-widget calendar solutions.

## Features

- **Multiple Calendar Views**: Separate widgets for Day, Multi-day (configurable day count), and Month views
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

// Create an event controller
final controller = MCalEventController();

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
  initialDate: DateTime.now(),
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
- **MCalDayView**: Day calendar view widget (coming soon)
- **MCalMultiDayView**: Multi-day calendar view widget (coming soon)
- **MCalThemeData**: Theme extension for calendar-specific styling
- **MCalLocalizations**: Built-in support for English and Mexican Spanish

## MCalMonthView

`MCalMonthView` displays a traditional month calendar grid showing days of the month with events displayed as tiles.

### Basic Usage

```dart
final controller = MCalEventController();

MCalMonthView(
  controller: controller,
  initialDate: DateTime.now(),
)
```

### Parameters

#### Required Parameters

- **`controller`** (`MCalEventController`): The event controller for loading and managing calendar events.

#### Optional Parameters

**Date Configuration:**
- **`initialDate`** (`DateTime?`): The initial date to display (defaults to today).
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

**Interactivity:**
- **`cellInteractivityCallback`**: Callback to determine if a cell is interactive.
- **`onCellTap`**: Callback when a day cell is tapped.
- **`onCellLongPress`**: Callback when a day cell is long-pressed.
- **`onEventTap`**: Callback when an event tile is tapped.
- **`onEventLongPress`**: Callback when an event tile is long-pressed.
- **`onSwipeNavigation`**: Callback when a swipe navigation gesture is detected.

**Localization:**
- **`dateFormat`** (`String?`): Custom date format string.
- **`locale`** (`Locale?`): Locale for date formatting and localization.

### Theme Customization

There are three ways to provide theme data:

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
      weekdayHeaderTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
  ],
)
```

#### 3. Pass directly to widget

```dart
MCalMonthView(
  controller: controller,
  theme: MCalThemeData(
    cellBackgroundColor: Colors.grey[100],
    todayBackgroundColor: Colors.blue[100],
  ),
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
)
```

#### Details Classes

| Class | Properties | Used By |
|-------|-----------|---------|
| `MCalCellTapDetails` | `date`, `events`, `isCurrentMonth` | `onCellTap`, `onCellLongPress` |
| `MCalEventTapDetails` | `event`, `displayDate` | `onEventTap`, `onEventLongPress` |
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
  eventTileBuilder: (context, ctx, defaultTile) {
    return Container(
      decoration: BoxDecoration(
        color: ctx.isAllDay ? Colors.blue : Colors.green,
        borderRadius: BorderRadius.circular(4),
      ),
      child: defaultTile,
    );
  },
)
```

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

```dart
// English
MCalMonthView(
  controller: controller,
  locale: Locale('en'),
)

// Spanish (Mexico)
MCalMonthView(
  controller: controller,
  locale: Locale('es', 'MX'),
)

// Custom date format
MCalMonthView(
  controller: controller,
  dateFormat: 'MMM d',
  locale: Locale('en'),
)
```

### Accessibility

`MCalMonthView` includes built-in accessibility support:

- All day cells have semantic labels describing the date
- Event tiles have semantic labels with event details
- Navigator buttons have descriptive labels
- Screen reader announcements for month/year changes

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

| Key | Action |
|-----|--------|
| `←` `→` `↑` `↓` | Navigate between cells |
| `Enter` / `Space` | Select the focused cell |
| `Home` | Jump to first day of month |
| `End` | Jump to last day of month |
| `Page Up` | Previous month |
| `Page Down` | Next month |

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
  enableAnimations: true, // Default: true
  animationDuration: Duration(milliseconds: 300), // Default
  animationCurve: Curves.easeInOut, // Default
)
```

Set `enableAnimations: false` for reduced motion or performance optimization.

### Multi-Day Event Rendering

Events spanning multiple days can render as contiguous tiles that visually span across cells.

```dart
MCalMonthView(
  controller: controller,
  renderMultiDayEventsAsContiguous: true, // Default
  multiDayEventTileBuilder: (context, details) {
    // Smart corner radius based on position
    final leftRadius = details.isFirstDayInRow ? 8.0 : 0.0;
    final rightRadius = details.isLastDayInRow ? 8.0 : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(leftRadius),
          right: Radius.circular(rightRadius),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        // Only show title on first day in row
        details.isFirstDayInRow ? details.event.title : '',
        overflow: TextOverflow.ellipsis,
      ),
    );
  },
)
```

**MCalMultiDayTileDetails properties:**

| Property | Description |
|----------|-------------|
| `event` | The calendar event being rendered |
| `displayDate` | Current date being rendered |
| `isFirstDayOfEvent` | True if this is the event's start date |
| `isLastDayOfEvent` | True if this is the event's end date |
| `isFirstDayInRow` | True if at start of week row |
| `isLastDayInRow` | True if at end of week row |
| `dayIndexInEvent` | 0-based index within event span |
| `totalDaysInEvent` | Total days the event spans |
| `rowIndex` | Which week row (0-based) |
| `totalRows` | Total rows the event spans |

Set `renderMultiDayEventsAsContiguous: false` for traditional per-cell rendering.

### Drag-and-Drop

Enable drag-and-drop to move events between dates.

```dart
MCalMonthView(
  controller: controller,
  enableDragAndDrop: true,
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
- Long-press (200ms) initiates drag
- Visual feedback shows valid/invalid drop targets
- Events preserve duration when moved
- Escape key cancels drag
- Cross-month dragging supported with edge navigation

**Custom Drag Visuals:**

```dart
MCalMonthView(
  controller: controller,
  enableDragAndDrop: true,
  // Customize the dragged tile appearance
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
  // Customize the source placeholder
  dragSourceBuilder: (context, details) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  },
  // Customize drop target cell appearance
  dropTargetCellBuilder: (context, details) {
    return Container(
      color: details.isValid
          ? Colors.green.withOpacity(0.2)
          : Colors.red.withOpacity(0.2),
    );
  },
)
```

**Drag-related Details classes:**

| Class | Properties | Used By |
|-------|-----------|---------|
| `MCalDraggedTileDetails` | `event`, `sourceDate`, `currentPosition` | `draggedTileBuilder` |
| `MCalDragSourceDetails` | `event`, `sourceDate` | `dragSourceBuilder` |
| `MCalDragTargetDetails` | `event`, `targetDate`, `isValid` | `dragTargetBuilder` |
| `MCalDragWillAcceptDetails` | `event`, `proposedStartDate`, `proposedEndDate` | `onDragWillAccept` |
| `MCalDropTargetCellDetails` | `date`, `isValid`, `draggedEvent` | `dropTargetCellBuilder` |
| `MCalEventDroppedDetails` | `event`, `oldStartDate`, `oldEndDate`, `newStartDate`, `newEndDate` | `onEventDropped` |

**Cross-month drag navigation:**

When dragging near the left/right edges, the calendar auto-navigates to the adjacent month after `dragEdgeNavigationDelay`. The drag continues seamlessly across months, respecting `minDate`/`maxDate` boundaries.

### Event Display Control

Limit the number of visible events per cell:

```dart
MCalMonthView(
  controller: controller,
  maxVisibleEvents: 3, // Default: 3
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

## Example

See the [example](example/) directory for a complete example application demonstrating package usage, including:
- **Features Demo**: Interactive showcase of keyboard navigation, hover feedback, week numbers, animations, multi-view sync, and loading/error states
- **Multi-Day Events**: Contiguous tile rendering across cells and weeks
- **Drag-and-Drop**: Move events between dates with visual feedback
- Basic MCalMonthView usage
- Theme customization with multiple styles (Default, Modern, Classic, Minimal, Colorful)
- Builder callbacks with the new `(BuildContext, Details)` pattern
- PageView-style swipe navigation
- Localization (English and Spanish)
- Accessibility features

## Requirements

- Flutter SDK: `>=1.17.0`
- Dart SDK: `^3.10.4`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

See [LICENSE](LICENSE) file for details.

## Additional Information

This package is currently in early development. Core features are being implemented incrementally. See the [CHANGELOG](CHANGELOG.md) for version history and planned features.
