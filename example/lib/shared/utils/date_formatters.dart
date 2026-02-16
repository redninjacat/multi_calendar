import 'dart:ui';
import 'package:intl/intl.dart';

/// Formats a month and year for display based on locale.
///
/// Uses the [intl] package for proper locale-aware formatting.
/// Returns the month name and year in the format appropriate for
/// the given locale (e.g., "January 2026" for English, "Enero 2026" for Spanish).
///
/// Example:
/// ```dart
/// final date = DateTime(2026, 2, 15);
/// final formatted = formatMonthYear(date, Locale('en')); // "February 2026"
/// ```
String formatMonthYear(DateTime date, Locale locale) {
  // Create a DateFormat for the locale that shows month and year
  final formatter = DateFormat.yMMMM(locale.toString());
  return formatter.format(date);
}
