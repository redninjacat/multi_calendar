# Multi Calendar Example

Example application demonstrating the Multi Calendar Flutter package.

## Overview

This example app showcases how to integrate and use the Multi Calendar package in a Flutter application. It demonstrates:

- Importing the `multi_calendar` package
- Creating `MCalEventController` instances
- Creating `MCalCalendarEvent` instances
- Using `MCalMonthView` widget with various features
- Localization with language switching (English/Spanish)
- Basic package integration patterns

## Running the Example

1. Ensure you have Flutter installed and configured
2. Navigate to this directory: `cd example`
3. Get dependencies: `flutter pub get`
4. Run the app: `flutter run`

The example app will run on all supported platforms (iOS, Android, Web, Desktop).

## Features Demonstrated

### Basic Usage

The example demonstrates basic `MCalMonthView` usage with:
- **MCalEventController**: Creating and using the event controller to manage calendar events
- **MCalCalendarEvent**: Creating calendar events with various fields (id, title, start, end, comment, externalId)
- **MCalMonthView Widget**: Displaying a month calendar grid with events

### Navigation

The example shows:
- **Month Navigator**: Built-in navigator with previous/next buttons and today button
- **Swipe Navigation**: Horizontal swipe gestures to navigate between months
- **Date Restrictions**: Using `minDate` and `maxDate` to restrict navigation

### Interactions

The example demonstrates:
- **Cell Tapping**: `onCellTap` callback shows a SnackBar when day cells are tapped
- **Event Tapping**: `onEventTap` callback shows a SnackBar when event tiles are tapped
- **Event Information**: Displaying event details including start/end times and comments

### Localization

The example includes:
- **Language Switching**: Toggle between English and Spanish (Mexico) via app bar menu
- **Localized Dates**: Date formatting respects the selected locale
- **Localized Strings**: Day names, month names, and other calendar text are localized

### Accessibility

The example demonstrates:
- **Screen Reader Support**: All calendar elements have semantic labels
- **Accessible Navigation**: Navigator buttons are accessible to screen readers
- **Event Announcements**: Event tiles provide descriptive labels for screen readers

## Code Examples

### Basic MCalMonthView Setup

```dart
final controller = MCalEventController();

MCalMonthView(
  controller: controller,
  initialDate: DateTime.now(),
  showNavigator: true,
  enableSwipeNavigation: true,
  locale: widget.currentLocale,
  onCellTap: (date, events, isCurrentMonth) {
    // Handle cell tap
  },
  onEventTap: (event, date) {
    // Handle event tap
  },
)
```

### Creating Calendar Events

```dart
// Timed event
final event = MCalCalendarEvent(
  id: 'event-1',
  title: 'Team Meeting',
  start: DateTime.now().add(Duration(days: 1)),
  end: DateTime.now().add(Duration(days: 1, hours: 1)),
  comment: 'Quarterly planning session',
  externalId: 'ext-123',
  isAllDay: false,
);

// All-day event
final allDayEvent = MCalCalendarEvent(
  id: 'event-2',
  title: 'Holiday',
  start: DateTime.now().add(Duration(days: 5)),
  end: DateTime.now().add(Duration(days: 5)),
  isAllDay: true,
  comment: 'Public holiday',
);
```

### Localization

```dart
// Switch locale
void _changeLocale(Locale locale) {
  setState(() {
    _locale = locale;
  });
}

// Use in widget
MCalMonthView(
  controller: controller,
  locale: _locale,
)
```

## What Each Example Shows

- **Basic Calendar Display**: Shows how to create a simple month view calendar
- **Event Display**: Demonstrates how events appear in day cells
- **Navigation**: Shows month navigation via buttons and swipe gestures
- **Interactions**: Demonstrates tap callbacks for cells and events
- **Localization**: Shows calendar in English and Spanish
- **Accessibility**: Demonstrates screen reader compatibility

## Next Steps

After running the example:
1. Try tapping on different day cells
2. Try tapping on event tiles
3. Swipe left/right to navigate months
4. Switch languages using the app bar menu
5. Enable screen reader to test accessibility

For more detailed documentation, see the main [README.md](../README.md) file.
