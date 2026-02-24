import 'package:flutter/material.dart';

/// Gets the date range for a given month.
///
/// Returns a [DateTimeRange] from the first day of the month (00:00:00)
/// to the last day of the month (23:59:59.999).
///
/// Example:
/// ```dart
/// final range = _getMonthRange(DateTime(2024, 2, 15));
/// // Returns: DateTimeRange(start: 2024-02-01 00:00:00, end: 2024-02-29 23:59:59.999)
/// ```
/// Gets the date range for a given month (public version for widget use).
DateTimeRange getMonthRange(DateTime month) {
  final firstDay = DateTime(month.year, month.month, 1);
  final lastDay = DateTime(month.year, month.month + 1, 0, 23, 59, 59, 999);
  return DateTimeRange(start: firstDay, end: lastDay);
}

/// Gets the date range for the previous month.
///
/// Handles year boundaries correctly (e.g., January -> December of previous year).
///
/// Example:
/// ```dart
/// final range = _getPreviousMonthRange(DateTime(2024, 1, 15));
/// // Returns: DateTimeRange for December 2023
/// ```
/// Gets the date range for the previous month (public version for widget use).
DateTimeRange getPreviousMonthRange(DateTime month) {
  final previousMonth = month.month == 1
      ? DateTime(month.year - 1, 12, 1)
      : DateTime(month.year, month.month - 1, 1);
  return getMonthRange(previousMonth);
}

/// Gets the date range for the next month.
///
/// Handles year boundaries correctly (e.g., December -> January of next year).
///
/// Example:
/// ```dart
/// final range = _getNextMonthRange(DateTime(2024, 12, 15));
/// // Returns: DateTimeRange for January 2025
/// ```
/// Gets the date range for the next month (public version for widget use).
DateTimeRange getNextMonthRange(DateTime month) {
  final nextMonth = month.month == 12
      ? DateTime(month.year + 1, 1, 1)
      : DateTime(month.year, month.month + 1, 1);
  return getMonthRange(nextMonth);
}

/// Generates a list of DateTime objects for the calendar grid.
///
/// The grid includes:
/// - Leading dates from the previous month (to fill the first week)
/// - All dates from the current month
/// - Trailing dates from the next month (to fill the last week)
///
/// The [firstDayOfWeek] parameter determines which day starts the week:
/// - 0 = Sunday
/// - 1 = Monday
/// - etc.
///
/// If [showSixthRowIfNeeded] is false (default), the grid will only include
/// 5 weeks (35 dates) when the 6th week contains no dates from the current month.
/// If true, always returns 42 dates (6 weeks × 7 days).
///
/// Example:
/// ```dart
/// final dates = generateMonthDates(DateTime(2024, 2, 1), 0); // Sunday = 0
/// // Returns 35 or 42 dates starting from the Sunday before Feb 1, 2024
/// ```
List<DateTime> generateMonthDates(
  DateTime month,
  int firstDayOfWeek, {
  bool showSixthRowIfNeeded = false,
}) {
  // Normalize month to first day
  final firstDay = DateTime(month.year, month.month, 1);
  final lastDay = DateTime(month.year, month.month + 1, 0); // Last day of month

  // Calculate the weekday of the first day
  // DateTime.weekday returns 1 = Monday, 2 = Tuesday, ..., 7 = Sunday
  // Convert to 0-based where 0 = Sunday, 1 = Monday, etc.
  int firstDayWeekday =
      firstDay.weekday % 7; // 0 = Sunday, 1 = Monday, ..., 6 = Saturday

  // Calculate offset to align with firstDayOfWeek
  // If firstDayWeekday < firstDayOfWeek, we need to wrap around
  int offset = (firstDayWeekday - firstDayOfWeek) % 7;
  if (offset < 0) {
    offset += 7;
  }

  // Calculate the first day of the grid (may be from previous month)
  // Use calendar-day arithmetic (not Duration) to avoid DST issues; e.g. on
  // Nov 2 when DST ends, adding Duration(days: 1) = 24h can land on Nov 2 23:00.
  final gridStart =
      DateTime(firstDay.year, firstDay.month, firstDay.day - offset);

  // Calculate how many weeks we need
  // Check if the 6th week contains any dates from the current month
  final fifthWeekEnd =
      DateTime(gridStart.year, gridStart.month, gridStart.day + 34);
  final needsSixthWeek = showSixthRowIfNeeded || lastDay.isAfter(fifthWeekEnd);

  final totalDays = needsSixthWeek ? 42 : 35;

  // Generate the dates (calendar-day arithmetic for DST correctness)
  final dates = <DateTime>[];
  for (int i = 0; i < totalDays; i++) {
    dates.add(DateTime(gridStart.year, gridStart.month, gridStart.day + i));
  }

  return dates;
}

/// Gets the date range for the visible grid of a month view.
///
/// Unlike [getMonthRange], this returns the full range of dates shown in the
/// calendar grid, including leading days from the previous month and trailing
/// days from the next month.
///
/// This is essential for correctly filtering events that should appear in the
/// grid, even if they start/end in adjacent months.
///
/// Example:
/// ```dart
/// // For February 2024 with Sunday as first day of week:
/// // Grid shows Jan 28 - March 9 (6 weeks)
/// final range = getVisibleGridRange(DateTime(2024, 2, 1), 0);
/// ```
DateTimeRange getVisibleGridRange(
  DateTime month,
  int firstDayOfWeek, {
  bool showSixthRowIfNeeded = false,
}) {
  // Generate the grid dates to get the actual range
  final dates = generateMonthDates(
    month,
    firstDayOfWeek,
    showSixthRowIfNeeded: showSixthRowIfNeeded,
  );

  if (dates.isEmpty) {
    // Fallback to month range if dates are empty
    return getMonthRange(month);
  }

  final firstDate = dates.first;
  final lastDate = dates.last;

  // Create range from start of first day to end of last day
  return DateTimeRange(
    start: DateTime(firstDate.year, firstDate.month, firstDate.day),
    end: DateTime(lastDate.year, lastDate.month, lastDate.day, 23, 59, 59, 999),
  );
}

/// Strips the time component from a [DateTime], returning midnight of that day.
///
/// Example:
/// ```dart
/// dateOnly(DateTime(2026, 2, 24, 14, 30)); // DateTime(2026, 2, 24)
/// ```
DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// Returns true if [dt] falls on the current calendar day.
///
/// Example:
/// ```dart
/// isToday(DateTime.now());  // true
/// isToday(DateTime(2000));  // false
/// ```
bool isToday(DateTime dt) {
  final now = DateTime.now();
  return dt.year == now.year && dt.month == now.month && dt.day == now.day;
}

/// Calculates the number of calendar days between two dates.
///
/// This function is DST-safe: it counts calendar days rather than using
/// duration-based arithmetic which can be off by one hour during DST transitions.
///
/// The time components of both dates are ignored - only the date parts
/// (year, month, day) are considered.
///
/// Returns a positive number if [to] is after [from], negative if before,
/// and 0 if they are the same calendar day.
///
/// Example:
/// ```dart
/// daysBetween(DateTime(2026, 3, 6), DateTime(2026, 3, 9)); // Returns 3
/// ```
int daysBetween(DateTime from, DateTime to) {
  // Convert to UTC to avoid DST issues with difference()
  // By creating UTC dates with the same year/month/day, we ensure
  // the difference is exactly N*24 hours
  final fromUtc = DateTime.utc(from.year, from.month, from.day);
  final toUtc = DateTime.utc(to.year, to.month, to.day);
  return toUtc.difference(fromUtc).inDays;
}

/// Calculates the week number for [date] relative to [firstDayOfWeek].
///
/// [firstDayOfWeek] uses the same 0-based convention as
/// [MCalEventController.firstDayOfWeek]: 0 = Sunday, 1 = Monday, …,
/// 6 = Saturday.
///
/// The algorithm generalises ISO 8601 to any week-start day:
///  - A "week anchor" is computed as the day 3 positions after the week start
///    (e.g. Thursday for Monday-start, Wednesday for Sunday-start).
///  - Week 1 of a year is the first week whose anchor falls in January.
///
/// When [firstDayOfWeek] is [DateTime.monday] (1) the results are identical to
/// ISO 8601, so both views produce the same numbers as before for the default
/// Monday-start setting.
///
/// Returns a value from 1 to 53.
int getWeekNumber(DateTime date, int firstDayOfWeek) {
  final weekStart = _weekStartOf(date, firstDayOfWeek);
  // Anchor is 3 days into the week (determines which year the week belongs to).
  final anchor = DateTime(weekStart.year, weekStart.month, weekStart.day + 3);
  final firstWS = _firstWeekStart(anchor.year, firstDayOfWeek);

  final daysDiff = DateTime.utc(weekStart.year, weekStart.month, weekStart.day)
      .difference(
        DateTime.utc(firstWS.year, firstWS.month, firstWS.day),
      )
      .inDays;

  final weekNumber = 1 + daysDiff ~/ 7;

  // The week belongs to the previous year (days before week 1).
  if (weekNumber < 1) {
    final prevFirstWS = _firstWeekStart(anchor.year - 1, firstDayOfWeek);
    final prevDiff =
        DateTime.utc(weekStart.year, weekStart.month, weekStart.day)
            .difference(
              DateTime.utc(prevFirstWS.year, prevFirstWS.month, prevFirstWS.day),
            )
            .inDays;
    return 1 + prevDiff ~/ 7;
  }

  return weekNumber;
}

/// Returns the [DateTime] of the start of the week containing [date], where
/// weeks begin on [firstDayOfWeek] (0 = Sunday, 1 = Monday, …, 6 = Saturday).
DateTime _weekStartOf(DateTime date, int firstDayOfWeek) {
  // Convert controller convention (0=Sun…6=Sat) to DateTime.weekday (1=Mon…7=Sun).
  final fDow = firstDayOfWeek == 0 ? 7 : firstDayOfWeek;
  final daysSince = (date.weekday - fDow + 7) % 7;
  return DateTime(date.year, date.month, date.day - daysSince);
}

/// Returns the start date of week 1 of [year] for the given [firstDayOfWeek].
///
/// Week 1 is the first week whose anchor (weekStart + 3 days) falls in January.
DateTime _firstWeekStart(int year, int firstDayOfWeek) {
  final jan1WeekStart = _weekStartOf(DateTime(year, 1, 1), firstDayOfWeek);
  final anchor =
      DateTime(jan1WeekStart.year, jan1WeekStart.month, jan1WeekStart.day + 3);
  if (anchor.year == year) {
    return jan1WeekStart;
  }
  // Anchor fell in the previous year → week 1 starts the following week.
  return DateTime(
    jan1WeekStart.year,
    jan1WeekStart.month,
    jan1WeekStart.day + 7,
  );
}

