# Design Document

## Introduction

This design document specifies the technical implementation approach for the McMonthView widget, the first calendar view in the Multi Calendar package. The design addresses all requirements from the requirements document while maintaining consistency with the project's architecture, performance goals, and customization philosophy.

## Architecture Overview

### High-Level Architecture

McMonthView follows a layered architecture:

1. **Widget Layer**: `McMonthView` (StatefulWidget) - Public API and state management
2. **Rendering Layer**: Internal widgets for grid, cells, headers, event tiles
3. **Data Layer**: Integration with `McEventController` for event loading
4. **Styling Layer**: `McCalendarThemeData` integration with Flutter's ThemeData
5. **Interaction Layer**: Gesture detection (swipe, tap, long-press)
6. **Accessibility Layer**: Semantics widgets for screen readers

### Component Diagram

```
McMonthView (StatefulWidget)
├── McMonthViewState
│   ├── _MonthGridWidget (renders calendar grid)
│   │   ├── _WeekdayHeaderRow (weekday names)
│   │   └── _WeekRow[] (5-6 rows of days)
│   │       └── _DayCell[] (7 cells per row)
│   │           ├── Date label
│   │           └── Event tiles
│   ├── _MonthNavigatorWidget (optional, if showNavigator is true)
│   └── GestureDetector (swipe handling)
├── McEventController (required)
├── McCalendarThemeData (optional, from ThemeData)
└── Builder callbacks (optional customization)
```

## Core Components

### 1. McMonthView Widget

**Location**: `lib/src/widgets/mc_month_view.dart`

**Structure**:
```dart
class McMonthView extends StatefulWidget {
  // Required
  final McEventController controller;
  
  // Date configuration
  final DateTime? initialDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final int? firstDayOfWeek; // 0 is Sunday, 1 is Monday, etc.
  
  // Navigation
  final bool showNavigator;
  final bool enableSwipeNavigation;
  final SwipeNavigationDirection swipeNavigationDirection;
  
  // Theme
  final McCalendarThemeData? theme;
  
  // Builders
  final Widget Function(BuildContext, McDayCellContext, Widget)? dayCellBuilder;
  final Widget Function(BuildContext, McEventTileContext, Widget)? eventTileBuilder;
  final Widget Function(BuildContext, McDayHeaderContext, Widget)? dayHeaderBuilder;
  final Widget Function(BuildContext, McNavigatorContext, Widget)? navigatorBuilder;
  final Widget Function(BuildContext, McDateLabelContext, String)? dateLabelBuilder;
  
  // Interactivity
  final bool Function(DateTime, bool, bool)? cellInteractivityCallback;
  final void Function(DateTime, List<McCalendarEvent>, bool)? onCellTap;
  final void Function(DateTime, List<McCalendarEvent>, bool)? onCellLongPress;
  final void Function(McCalendarEvent, DateTime)? onEventTap;
  final void Function(McCalendarEvent, DateTime)? onEventLongPress;
  final void Function(DateTime, DateTime, SwipeDirection)? onSwipeNavigation;
  
  // Localization
  final String? dateFormat;
  final Locale? locale;
}
```

**Key Design Decisions**:
- StatefulWidget for managing month state and event subscriptions
- All customization via optional builder callbacks
- Theme integration via ThemeExtension pattern
- Swipe gestures handled at widget level using GestureDetector

### 2. McMonthViewState

**Responsibilities**:
- Manage current displayed month
- Subscribe to McEventController changes
- Handle swipe gesture detection
- Coordinate event loading with McEventController
- Manage widget rebuilds when events change

**State Variables**:
```dart
class _McMonthViewState extends State<McMonthView> {
  late DateTime _currentMonth; // First day of displayed month
  List<McCalendarEvent> _events = []; // Events for current month
  bool _isLoadingEvents = false;
  
  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialDate ?? DateTime.now();
    _loadEvents();
    widget.controller.addListener(_onControllerChanged);
  }
  
  void _loadEvents() {
    // Request events for current + previous + next month
    final range = _getMonthRange(_currentMonth);
    final prevRange = _getPreviousMonthRange(_currentMonth);
    final nextRange = _getNextMonthRange(_currentMonth);
    
    widget.controller.loadEvents(prevRange.start, nextRange.end);
  }
  
  void _onControllerChanged() {
    // Filter events for current month
    final monthRange = _getMonthRange(_currentMonth);
    _events = widget.controller.getEventsForRange(monthRange);
    setState(() {});
  }
}
```

### 3. Month Grid Layout

**Structure**: 7 columns × 5-6 rows grid

**Implementation Approach**:
- Use `Table` or `Row`/`Column` widgets for grid structure
- Each cell is a `_DayCellWidget` that handles its own rendering
- Grid calculates which dates belong to current/previous/next month
- Responsive sizing using `Expanded` or `Flexible` widgets

**Date Calculation Algorithm**:
```dart
List<DateTime> _generateMonthDates(DateTime month, int firstDayOfWeek) {
  final firstDay = DateTime(month.year, month.month, 1);
  final lastDay = DateTime(month.year, month.month + 1, 0);
  
  // Find first day of grid (may be from previous month)
  int firstDayWeekday = firstDay.weekday;
  int offset = (firstDayWeekday - firstDayOfWeek) % 7;
  final gridStart = firstDay.subtract(Duration(days: offset));
  
  // Generate 42 days (6 weeks × 7 days)
  final dates = <DateTime>[];
  for (int i = 0; i < 42; i++) {
    dates.add(gridStart.add(Duration(days: i)));
  }
  
  return dates;
}
```

### 4. Day Cell Widget

**Location**: Internal widget within `mc_month_view.dart`

**Structure**:
```dart
class _DayCellWidget extends StatelessWidget {
  final DateTime date;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelectable;
  final List<McCalendarEvent> events;
  final McCalendarThemeData theme;
  final Widget Function(BuildContext, McDayCellContext, Widget)? builder;
  final bool Function(DateTime, bool, bool)? interactivityCallback;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  
  @override
  Widget build(BuildContext context) {
    final isInteractive = interactivityCallback?.call(date, isCurrentMonth, isSelectable) ?? true;
    
    Widget cell = Container(
      decoration: _getCellDecoration(),
      child: Column(
        children: [
          _buildDateLabel(),
          _buildEventTiles(),
        ],
      ),
    );
    
    if (builder != null) {
      cell = builder!(context, McDayCellContext(...), cell);
    }
    
    return GestureDetector(
      onTap: isInteractive ? onTap : null,
      onLongPress: isInteractive ? onLongPress : null,
      child: Semantics(
        label: _getSemanticLabel(),
        child: cell,
      ),
    );
  }
}
```

**Key Features**:
- Handles cell decoration (background, borders)
- Renders date label with appropriate styling
- Displays event tiles (up to max, then overflow indicator)
- Supports custom builder for complete override
- Includes semantic labels for accessibility

### 5. Event Tile Rendering

**Approach**: 
- Events displayed as small tiles within day cells
- Multi-day events span across multiple cells
- Overflow handling: show "+N more" indicator when too many events

**Event Tile Widget**:
```dart
class _EventTileWidget extends StatelessWidget {
  final McCalendarEvent event;
  final DateTime displayDate; // Date context for this tile
  final bool isAllDay;
  final McCalendarThemeData theme;
  final Widget Function(BuildContext, McEventTileContext, Widget)? builder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  
  @override
  Widget build(BuildContext context) {
    Widget tile = Container(
      decoration: BoxDecoration(
        color: theme.eventTileBackgroundColor,
        borderRadius: BorderRadius.circular(2),
      ),
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: Text(
        event.title,
        style: theme.eventTileTextStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
    
    if (builder != null) {
      tile = builder!(context, McEventTileContext(...), tile);
    }
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Semantics(
        label: '${event.title}, ${_formatEventTime()}',
        child: tile,
      ),
    );
  }
}
```

**Multi-Day Event Handling**:
- Events spanning multiple days are rendered as continuous tiles
- Each day cell shows portion of the event
- Uses `CustomPaint` or `Container` with calculated widths for spanning

### 6. Swipe Gesture Implementation

**Approach**: Use `GestureDetector` with `onHorizontalDragEnd` or `onVerticalDragEnd`

**Implementation**:
```dart
GestureDetector(
  onHorizontalDragEnd: widget.enableSwipeNavigation && 
                       widget.swipeNavigationDirection == SwipeNavigationDirection.horizontal
    ? (details) {
        if (details.primaryVelocity! < -500) {
          // Swipe left - next month
          _navigateToNextMonth();
        } else if (details.primaryVelocity! > 500) {
          // Swipe right - previous month
          _navigateToPreviousMonth();
        }
      }
    : null,
  onVerticalDragEnd: widget.enableSwipeNavigation && 
                     widget.swipeNavigationDirection == SwipeNavigationDirection.vertical
    ? (details) {
        if (details.primaryVelocity! < -500) {
          // Swipe up - next month
          _navigateToNextMonth();
        } else if (details.primaryVelocity! > 500) {
          // Swipe down - previous month
          _navigateToPreviousMonth();
        }
      }
    : null,
  child: _buildMonthGrid(),
)
```

**Key Considerations**:
- Velocity threshold (500) ensures intentional swipes
- Respects minDate/maxDate restrictions
- Uses pre-loaded events from McEventController for instant navigation
- Calls onSwipeNavigation callback if provided

### 7. Navigator Widget

**Location**: `lib/src/widgets/navigator.dart` (shared component)

**Structure**:
```dart
class _MonthNavigatorWidget extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onToday;
  final bool canGoPrevious;
  final bool canGoNext;
  final Locale? locale;
  final Widget Function(BuildContext, McNavigatorContext, Widget)? builder;
  
  @override
  Widget build(BuildContext context) {
    Widget navigator = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: canGoPrevious ? onPrevious : null,
        ),
        Text(_formatMonthYear(currentMonth, locale)),
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed: canGoNext ? onNext : null,
        ),
      ],
    );
    
    if (builder != null) {
      navigator = builder!(context, McNavigatorContext(...), navigator);
    }
    
    return navigator;
  }
}
```

### 8. Theme Integration

**McCalendarThemeData Structure**:
```dart
class McCalendarThemeData extends ThemeExtension<McCalendarThemeData> {
  // Cell styling
  final Color? cellBackgroundColor;
  final Color? cellBorderColor;
  final TextStyle? cellTextStyle;
  
  // Current day styling
  final Color? todayBackgroundColor;
  final TextStyle? todayTextStyle;
  
  // Leading/trailing date styling
  final TextStyle? leadingDatesTextStyle;
  final TextStyle? trailingDatesTextStyle;
  final Color? leadingDatesBackgroundColor;
  final Color? trailingDatesBackgroundColor;
  
  // Day header styling
  final TextStyle? weekdayHeaderTextStyle;
  final Color? weekdayHeaderBackgroundColor;
  
  // Event tile styling
  final Color? eventTileBackgroundColor;
  final TextStyle? eventTileTextStyle;
  
  // Navigator styling
  final TextStyle? navigatorTextStyle;
  final Color? navigatorBackgroundColor;
  
  @override
  McCalendarThemeData copyWith({...}) { ... }
  
  @override
  McCalendarThemeData lerp(McCalendarThemeData? other, double t) { ... }
}
```

**Theme Resolution**:
```dart
McCalendarThemeData _resolveTheme(BuildContext context) {
  final theme = Theme.of(context);
  final extension = theme.extension<McCalendarThemeData>();
  
  return widget.theme ?? 
         extension ?? 
         McCalendarThemeData.fromTheme(theme);
}
```

### 9. McEventController Integration

**Event Loading Strategy**:
- McMonthView requests events for current + previous + next month
- McEventController loads events asynchronously
- McEventController uses efficient data structures (SortedMap by date range)
- Events cached in McEventController for instant swipe navigation

**Event Retrieval**:
```dart
List<McCalendarEvent> _getEventsForMonth(DateTime month) {
  final monthRange = _getMonthRange(month);
  return widget.controller.getEventsForRange(monthRange);
}
```

**Performance Considerations**:
- McEventController maintains O(log n) lookup for date ranges
- Pre-loading adjacent months enables instant swipe
- Memory cleanup removes events outside visible/near-range windows

### 10. Localization and RTL Support

**Localization**:
- Uses `CalendarLocalizations` utility for date formatting
- Respects app's locale from widget tree
- Day names and month names localized via `intl` package

**RTL Support**:
```dart
bool _isRTL(BuildContext context) {
  return CalendarLocalizations.isRTL(Localizations.localeOf(context));
}

Widget _buildGrid(BuildContext context) {
  return Directionality(
    textDirection: _isRTL(context) ? TextDirection.rtl : TextDirection.ltr,
    child: _buildMonthGrid(),
  );
}
```

**RTL Considerations**:
- Grid layout automatically flips in RTL
- Navigator buttons positioned appropriately
- Swipe directions remain logically consistent (left goes forward in time)

### 11. Accessibility Implementation

**Semantic Labels**:
```dart
Semantics(
  label: '${_formatDate(date)}, ${isToday ? "today" : ""}, ${events.length} events',
  hint: isCurrentMonth ? null : 'Date from ${isCurrentMonth ? "current" : "previous"} month',
  child: dayCell,
)
```

**Screen Reader Support**:
- Each day cell has descriptive label
- Event tiles include event details in semantic label
- Month navigation announces month/year changes
- Non-interactive cells marked appropriately

### 12. Performance Optimizations

**Rendering Optimizations**:
- Use `const` constructors where possible
- `RepaintBoundary` widgets for complex cells
- Efficient grid generation (calculate once per month change)
- Event filtering done once per month change

**Memory Optimizations**:
- McEventController handles efficient caching
- McMonthView only holds events for current month
- No unnecessary widget rebuilds

**Gesture Performance**:
- Swipe detection uses velocity thresholds
- Pre-loaded events enable instant navigation
- Async event loading doesn't block UI

## Data Models

### MCalCalendarEvent
```dart
class MCalCalendarEvent {
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final bool isAllDay; // When true, time components of start/end are ignored
  final String? comment;
  final String? externalId;
  final String? occurrenceId;
  
  const MCalCalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.isAllDay = false,
    this.comment,
    this.externalId,
    this.occurrenceId,
  });
}
```

### MCalDayCellContext
```dart
class MCalDayCellContext {
  final DateTime date;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelectable;
  final List<MCalCalendarEvent> events;
  final MCalThemeData theme;
  
  const MCalDayCellContext({
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelectable,
    required this.events,
    required this.theme,
  });
}
```

### MCalEventTileContext
```dart
class MCalEventTileContext {
  final MCalCalendarEvent event;
  final DateTime displayDate;
  final bool isAllDay; // From event.isAllDay
  final MCalThemeData theme;
  
  const MCalEventTileContext({
    required this.event,
    required this.displayDate,
    required this.isAllDay,
    required this.theme,
  });
}
```

### MCalDayHeaderContext
```dart
class MCalDayHeaderContext {
  final int dayOfWeek; // 0-6
  final String dayName; // Localized
  final MCalThemeData theme;
  
  const MCalDayHeaderContext({
    required this.dayOfWeek,
    required this.dayName,
    required this.theme,
  });
}
```

### MCalNavigatorContext
```dart
class MCalNavigatorContext {
  final DateTime currentMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final bool canGoPrevious;
  final bool canGoNext;
  final Locale locale;
  
  const MCalNavigatorContext({
    required this.currentMonth,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.locale,
  });
}
```

### MCalDateLabelContext
```dart
class MCalDateLabelContext {
  final DateTime date;
  final bool isCurrentMonth;
  final bool isToday;
  final String defaultFormattedString;
  final Locale locale;
  
  const MCalDateLabelContext({
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    required this.defaultFormattedString,
    required this.locale,
  });
}
```

## Error Handling

### Invalid Date Ranges
- Validate minDate is less than or equal to maxDate in constructor
- Clamp initialDate to minDate/maxDate range
- Prevent navigation beyond minDate/maxDate

### McEventController Errors
- Handle async loading errors gracefully
- Show loading state while events load
- Fallback to empty event list on error

### Builder Callback Errors
- Wrap builder callbacks in try-catch
- Fallback to default rendering on builder error
- Log errors for debugging

## Testing Strategy

### Unit Tests
- Date calculation logic (month range, grid generation)
- Event filtering by date range
- Theme resolution
- Localization formatting

### Widget Tests
- McMonthView rendering
- Cell interactivity
- Swipe gesture detection
- Builder callback integration
- Theme application
- Accessibility semantics

### Integration Tests
- McEventController integration
- Event loading and display
- Month navigation
- Swipe navigation with pre-loaded events

## Implementation Notes

### File Structure
```
lib/src/widgets/
├── mc_month_view.dart          # Main widget
└── navigator.dart              # Shared navigator widget (if not already exists)

lib/src/styles/
└── mc_calendar_theme.dart      # Theme extension

lib/src/utils/
├── date_utils.dart             # Date calculation utilities
└── localization.dart           # Already exists
```

### Dependencies
- No new external dependencies required
- Uses existing `intl` package for localization
- Uses Flutter's built-in gesture detection

### Migration Considerations
- This is the first view implementation
- Establishes patterns for McDayView and McMultiDayView
- Theme structure will be reused across all views

## Future Enhancements (Out of Scope)

- Smooth animations during swipe navigation
- Drag-and-drop event manipulation
- Event resizing (not applicable to month view)
- Custom holiday/region calendars
- Time zone handling
