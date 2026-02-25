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
/// - Multi-day view (MCalMultiDayView)

library;

// Export controllers
export 'src/controllers/mcal_event_controller.dart';
// Export models
export 'src/models/mcal_calendar_event.dart';
export 'src/models/mcal_day_region.dart';
export 'src/models/mcal_event_change_info.dart';
export 'src/models/mcal_recurrence_exception.dart';
export 'src/models/mcal_recurrence_rule.dart';
export 'src/models/mcal_time_region.dart';
// Export styles
export 'src/styles/mcal_day_theme_data.dart';
export 'src/styles/mcal_month_theme_data.dart';
export 'src/styles/mcal_theme.dart';
// Export utilities
export 'src/utils/color_utils.dart';
export 'src/utils/date_utils.dart';
export 'src/utils/mcal_date_format_utils.dart';
// Export generated localization class
export 'l10n/mcal_localizations.dart';
export 'src/widgets/mcal_callback_details.dart';
export 'src/widgets/mcal_month_default_week_layout.dart'
    show
        MCalMonthDefaultWeekLayoutBuilder,
        MCalMonthSegmentRowAssignment,
        MCalMonthOverflowInfo;
export 'src/widgets/mcal_draggable_event_tile.dart';
// Export widgets
export 'src/widgets/mcal_day_view.dart'
    show
        MCalDayView,
        MCalDayViewCreateEventIntent,
        MCalDayViewDeleteEventIntent,
        MCalDayViewEditEventIntent,
        MCalDayViewState;
export 'src/widgets/mcal_day_view_contexts.dart'
    show
        MCalAllDayEventTileContext,
        MCalCurrentTimeContext,
        MCalDayHeaderContext,
        MCalDayLayoutContext,
        MCalGridlineContext,
        MCalGridlineType,
        MCalTimeLabelContext,
        MCalTimeLabelPosition,
        MCalTimeRegionContext,
        MCalTimeSlotContext,
        MCalTimedEventTileContext;
// Note: Day View uses MCalDayHeaderContext; Month View uses MCalMonthDayHeaderContext.
export 'src/widgets/mcal_month_view.dart';
export 'src/widgets/mcal_month_view_contexts.dart';
export 'src/widgets/mcal_month_multi_day_renderer.dart';
export 'src/widgets/mcal_month_multi_day_tile.dart';
export 'src/widgets/mcal_month_week_layout_contexts.dart'
    show
        MCalMonthEventSegment,
        MCalMonthWeekLayoutContext,
        MCalMonthWeekLayoutConfig,
        MCalMonthOverflowIndicatorContext,
        DateLabelPosition;

// Future exports (to be implemented):
// export 'src/views/mcal_day_view.dart';
// export 'src/views/mcal_multi_day_view.dart';
