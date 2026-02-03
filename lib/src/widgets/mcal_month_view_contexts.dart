import 'package:flutter/material.dart';
import '../models/mcal_calendar_event.dart';

/// Context object for day cell builder callbacks.
///
/// Provides all necessary data for customizing the rendering of individual
/// day cells in the month view calendar grid.
///
/// Theme data is accessed via `MCalTheme.of(context)` from within the builder
/// callback, rather than being passed through this context object.
///
/// Example:
/// ```dart
/// dayCellBuilder: (context, ctx, defaultCell) {
///   final theme = MCalTheme.of(context);
///   if (ctx.isToday) {
///     return Container(
///       decoration: BoxDecoration(
///         color: theme.todayBackgroundColor,
///         shape: BoxShape.circle,
///       ),
///       child: defaultCell,
///     );
///   }
///   return defaultCell;
/// }
/// ```
class MCalDayCellContext {
  /// The date represented by this cell.
  final DateTime date;

  /// Whether this date belongs to the currently displayed month.
  final bool isCurrentMonth;

  /// Whether this date is today.
  final bool isToday;

  /// Whether this date cell is selectable/interactive.
  final bool isSelectable;

  /// Whether this cell currently has keyboard focus.
  ///
  /// This is true when the cell is the current focus target for keyboard
  /// navigation. Use this to render a focus indicator or highlight.
  final bool isFocused;

  /// List of events occurring on this date.
  final List<MCalCalendarEvent> events;

  /// Creates a new [MCalDayCellContext] instance.
  const MCalDayCellContext({
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelectable,
    this.isFocused = false,
    required this.events,
  });
}

/// Context object for event tile builder callbacks.
///
/// Provides all necessary data for customizing the rendering of individual
/// event tiles displayed within day cells.
///
/// Theme data is accessed via `MCalTheme.of(context)` from within the builder
/// callback, rather than being passed through this context object.
///
/// Example:
/// ```dart
/// eventTileBuilder: (context, ctx, defaultTile) {
///   return Container(
///     decoration: BoxDecoration(
///       color: ctx.isAllDay ? Colors.blue : Colors.green,
///     ),
///     child: defaultTile,
///   );
/// }
/// ```
class MCalEventTileContext {
  /// The calendar event being displayed.
  final MCalCalendarEvent event;

  /// The date context for this event tile (may differ from event.start
  /// for multi-day events).
  final DateTime displayDate;

  /// Whether this event is an all-day event.
  final bool isAllDay;

  /// Creates a new [MCalEventTileContext] instance.
  const MCalEventTileContext({
    required this.event,
    required this.displayDate,
    required this.isAllDay,
  });
}

/// Context object for day header builder callbacks.
///
/// Provides all necessary data for customizing the rendering of weekday
/// headers (Monday, Tuesday, etc.) in the calendar grid.
///
/// Theme data is accessed via `MCalTheme.of(context)` from within the builder
/// callback, rather than being passed through this context object.
///
/// Example:
/// ```dart
/// dayHeaderBuilder: (context, ctx, defaultHeader) {
///   final theme = MCalTheme.of(context);
///   return Container(
///     decoration: BoxDecoration(
///       color: theme.weekdayHeaderBackgroundColor,
///     ),
///     child: Center(
///       child: Text(
///         ctx.dayName,
///         style: theme.weekdayHeaderTextStyle,
///       ),
///     ),
///   );
/// }
/// ```
class MCalDayHeaderContext {
  /// Day of week index (0-6, where 0 is typically Sunday or first day of week).
  final int dayOfWeek;

  /// Localized day name (e.g., "Monday", "Lundi", "月曜日").
  final String dayName;

  /// Creates a new [MCalDayHeaderContext] instance.
  const MCalDayHeaderContext({
    required this.dayOfWeek,
    required this.dayName,
  });
}

/// Context object for navigator builder callbacks.
///
/// Provides all necessary data for customizing the rendering of the month
/// navigator (month/year display and navigation controls).
///
/// Example:
/// ```dart
/// navigatorBuilder: (context, ctx, defaultNavigator) {
///   return Row(
///     mainAxisAlignment: MainAxisAlignment.spaceBetween,
///     children: [
///       IconButton(
///         onPressed: ctx.canGoPrevious ? ctx.onPrevious : null,
///         icon: Icon(Icons.chevron_left),
///       ),
///       Text(_formatMonth(ctx.currentMonth, ctx.locale)),
///       IconButton(
///         onPressed: ctx.canGoNext ? ctx.onNext : null,
///         icon: Icon(Icons.chevron_right),
///       ),
///     ],
///   );
/// }
/// ```
class MCalNavigatorContext {
  /// The currently displayed month (first day of the month).
  final DateTime currentMonth;

  /// Callback to navigate to the previous month.
  final VoidCallback onPrevious;

  /// Callback to navigate to the next month.
  final VoidCallback onNext;

  /// Callback to navigate to the current month (today).
  final VoidCallback onToday;

  /// Whether navigation to the previous month is allowed.
  final bool canGoPrevious;

  /// Whether navigation to the next month is allowed.
  final bool canGoNext;

  /// The locale for formatting dates.
  final Locale locale;

  /// Creates a new [MCalNavigatorContext] instance.
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

/// Context object for date label builder callbacks.
///
/// Provides all necessary data for customizing the rendering of date labels
/// (day numbers) within day cells.
///
/// Example:
/// ```dart
/// dateLabelBuilder: (context, ctx, defaultLabel) {
///   if (ctx.isToday) {
///     return Text(
///       ctx.defaultFormattedString,
///       style: TextStyle(
///         color: Colors.blue,
///         fontWeight: FontWeight.bold,
///       ),
///     );
///   }
///   return Text(ctx.defaultFormattedString);
/// }
/// ```
class MCalDateLabelContext {
  /// The date being labeled.
  final DateTime date;

  /// Whether this date belongs to the currently displayed month.
  final bool isCurrentMonth;

  /// Whether this date is today.
  final bool isToday;

  /// The default formatted string for this date (typically just the day number).
  final String defaultFormattedString;

  /// The locale for formatting dates.
  final Locale locale;

  /// Creates a new [MCalDateLabelContext] instance.
  const MCalDateLabelContext({
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    required this.defaultFormattedString,
    required this.locale,
  });
}

/// Context object for week number builder callbacks.
///
/// Provides all necessary data for customizing the rendering of week number
/// cells displayed in the calendar grid when week numbers are enabled.
///
/// Theme data is accessed via `MCalTheme.of(context)` from within the builder
/// callback, rather than being passed through this context object.
///
/// Example:
/// ```dart
/// weekNumberBuilder: (context, ctx, defaultWeekNumber) {
///   final theme = MCalTheme.of(context);
///   return Container(
///     decoration: BoxDecoration(
///       color: theme.weekNumberBackgroundColor,
///     ),
///     child: Center(
///       child: Text(
///         ctx.defaultFormattedString,
///         style: theme.weekNumberTextStyle,
///       ),
///     ),
///   );
/// }
/// ```
class MCalWeekNumberContext {
  /// The ISO week number (1-53).
  final int weekNumber;

  /// The first day of this week.
  final DateTime firstDayOfWeek;

  /// The default formatted string for this week number.
  final String defaultFormattedString;

  /// Creates a new [MCalWeekNumberContext] instance.
  const MCalWeekNumberContext({
    required this.weekNumber,
    required this.firstDayOfWeek,
    required this.defaultFormattedString,
  });
}
