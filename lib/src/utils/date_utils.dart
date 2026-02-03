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
List<DateTime> generateMonthDates(DateTime month, int firstDayOfWeek, {bool showSixthRowIfNeeded = false}) {
  // Normalize month to first day
  final firstDay = DateTime(month.year, month.month, 1);
  final lastDay = DateTime(month.year, month.month + 1, 0); // Last day of month

  // Calculate the weekday of the first day
  // DateTime.weekday returns 1 = Monday, 2 = Tuesday, ..., 7 = Sunday
  // Convert to 0-based where 0 = Sunday, 1 = Monday, etc.
  int firstDayWeekday = firstDay.weekday % 7; // 0 = Sunday, 1 = Monday, ..., 6 = Saturday

  // Calculate offset to align with firstDayOfWeek
  // If firstDayWeekday < firstDayOfWeek, we need to wrap around
  int offset = (firstDayWeekday - firstDayOfWeek) % 7;
  if (offset < 0) {
    offset += 7;
  }

  // Calculate the first day of the grid (may be from previous month)
  final gridStart = firstDay.subtract(Duration(days: offset));

  // Calculate how many weeks we need
  // Check if the 6th week contains any dates from the current month
  final fifthWeekEnd = gridStart.add(const Duration(days: 34)); // End of 5th week (day 35)
  final needsSixthWeek = showSixthRowIfNeeded || lastDay.isAfter(fifthWeekEnd);

  final totalDays = needsSixthWeek ? 42 : 35;

  // Generate the dates
  final dates = <DateTime>[];
  for (int i = 0; i < totalDays; i++) {
    dates.add(gridStart.add(Duration(days: i)));
  }

  return dates;
}

/// Calculates the ISO 8601 week number for a given date.
///
/// ISO 8601 defines week 1 as the week containing the first Thursday
/// of the year. Weeks start on Monday.
///
/// Returns a value from 1 to 53.
///
/// Example:
/// ```dart
/// final week = getISOWeekNumber(DateTime(2024, 1, 1)); // Returns 1
/// final week2 = getISOWeekNumber(DateTime(2023, 1, 1)); // Returns 52 (of 2022)
/// ```
int getISOWeekNumber(DateTime date) {
  // Calculate day of year (1-366)
  final startOfYear = DateTime(date.year, 1, 1);
  final dayOfYear = date.difference(startOfYear).inDays + 1;

  // DateTime.weekday: Monday = 1, Sunday = 7 (ISO 8601 convention)
  final weekday = date.weekday;

  // Calculate week number using ISO 8601 formula
  final weekNumber = ((dayOfYear - weekday + 10) ~/ 7);

  // Handle edge case: week 0 means it's the last week of the previous year
  if (weekNumber == 0) {
    // Recursively get the week number for Dec 31 of the previous year
    return getISOWeekNumber(DateTime(date.year - 1, 12, 31));
  }

  // Handle edge case: week 53 might actually be week 1 of the next year
  if (weekNumber == 53) {
    // Check if Dec 31 of this year is before Thursday (weekday < 4)
    final dec31 = DateTime(date.year, 12, 31);
    if (dec31.weekday < 4) {
      // It's actually week 1 of the next year
      return 1;
    }
  }

  return weekNumber;
}
