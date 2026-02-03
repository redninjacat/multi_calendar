/// Multi Calendar - A flexible Flutter package for displaying calendar views.
///
/// This package provides customizable calendar widgets for displaying events
/// with full RFC 5545 RRULE support. The package focuses on event display
/// and RRULE handling while delegating event storage and management to
/// external systems.
///
/// ## Usage
///
/// ```dart
/// import 'package:multi_calendar/multi_calendar.dart';
///
/// // Create an event controller
/// final controller = MCalEventController();
///
/// // Create calendar events
/// final event = MCalCalendarEvent(
///   id: 'event-1',
///   title: 'Team Meeting',
///   start: DateTime(2024, 1, 15, 10, 0),
///   end: DateTime(2024, 1, 15, 11, 0),
///   isAllDay: false,
/// );
///
/// // Create an all-day event
/// final allDayEvent = MCalCalendarEvent(
///   id: 'event-2',
///   title: 'Holiday',
///   start: DateTime(2024, 1, 20, 0, 0),
///   end: DateTime(2024, 1, 20, 0, 0),
///   isAllDay: true,
/// );
/// ```
///
/// ## Future Exports
///
/// The following will be exported in future releases:
/// - View widgets: DayView, MultiDayView, MonthView
/// - Style/theme classes: CalendarTheme, ViewStyles

library;

// Export models
export 'src/models/mcal_calendar_event.dart';

// Export controllers
export 'src/controllers/mcal_event_controller.dart';

// Export widgets
export 'src/widgets/mcal_month_view.dart';
export 'src/widgets/mcal_month_view_contexts.dart';
export 'src/widgets/mcal_callback_details.dart';
export 'src/widgets/mcal_multi_day_renderer.dart';
export 'src/widgets/mcal_multi_day_tile.dart';
export 'src/widgets/mcal_draggable_event_tile.dart';

// Export styles
export 'src/styles/mcal_theme.dart';

// Export utilities
export 'src/utils/mcal_localization.dart';

// Future exports (to be implemented):
// export 'src/views/day_view.dart';
// export 'src/views/multi_day_view.dart';
