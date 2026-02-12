/// Multi Calendar — A flexible Flutter package for displaying calendar views
/// with full RFC 5545 RRULE recurring event support.
///
/// The package focuses on event display and recurrence expansion while
/// delegating event storage and management to external systems. This makes
/// it ideal for applications that need calendar UI without being locked into
/// a specific data persistence strategy.
///
/// ## Key features
///
/// - **Month view** ([MCalMonthView]) with drag-and-drop, multi-day events,
///   and customizable builders.
/// - **Recurring events** via [MCalRecurrenceRule] — daily, weekly, monthly,
///   yearly with RFC 5545 RRULE string interop.
/// - **Exception handling** — delete, reschedule, or modify individual
///   occurrences without reloading from the database.
/// - **Delegation pattern** — override [MCalEventController.loadEvents] to
///   integrate with any backend (Drift, Firestore, REST API, etc.).
///
/// ## Quick start
///
/// ```dart
/// import 'package:multi_calendar/multi_calendar.dart';
///
/// // Create a controller and add events
/// final controller = MCalEventController();
/// controller.addEvents([
///   MCalCalendarEvent(
///     id: 'meeting',
///     title: 'Team Meeting',
///     start: DateTime(2024, 1, 15, 10, 0),
///     end: DateTime(2024, 1, 15, 11, 0),
///   ),
///   MCalCalendarEvent(
///     id: 'standup',
///     title: 'Daily Standup',
///     start: DateTime(2024, 1, 1, 9, 0),
///     end: DateTime(2024, 1, 1, 9, 15),
///     recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.daily),
///   ),
/// ]);
///
/// // Query — recurring events are expanded automatically
/// final events = controller.getEventsForRange(
///   DateTimeRange(
///     start: DateTime(2024, 1, 1),
///     end: DateTime(2024, 1, 31, 23, 59, 59),
///   ),
/// );
/// ```
///
/// ## Future exports
///
/// The following will be exported in future releases:
/// - Day view (MCalDayView)
/// - Multi-day view (MCalMultiDayView)

library;

// Export controllers
export 'src/controllers/mcal_event_controller.dart';
// Export models
export 'src/models/mcal_calendar_event.dart';
export 'src/models/mcal_recurrence_rule.dart';
export 'src/models/mcal_recurrence_exception.dart';
export 'src/models/mcal_event_change_info.dart';
// Export styles
export 'src/styles/mcal_theme.dart';
// Export utilities
export 'src/utils/mcal_localization.dart';
export 'src/widgets/mcal_callback_details.dart';
export 'src/widgets/mcal_default_week_layout.dart'
    show
        MCalDefaultWeekLayoutBuilder,
        MCalSegmentRowAssignment,
        MCalOverflowInfo;
export 'src/widgets/mcal_draggable_event_tile.dart';
// Export widgets
export 'src/widgets/mcal_month_view.dart';
export 'src/widgets/mcal_month_view_contexts.dart';
export 'src/widgets/mcal_multi_day_renderer.dart';
export 'src/widgets/mcal_multi_day_tile.dart';
export 'src/widgets/mcal_week_layout_contexts.dart'
    show
        MCalEventSegment,
        MCalWeekLayoutContext,
        MCalWeekLayoutConfig,
        MCalOverflowIndicatorContext,
        DateLabelPosition;

// Future exports (to be implemented):
// export 'src/views/mcal_day_view.dart';
// export 'src/views/mcal_multi_day_view.dart';
