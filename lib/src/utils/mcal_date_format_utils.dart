import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/mcal_localizations.dart';

/// Utility class for calendar date/time formatting.
///
/// This class provides date and time formatting methods using the intl package,
/// along with static helpers for accessing localized day and month names from
/// [MCalLocalizations].
///
/// Example:
/// ```dart
/// final utils = MCalDateFormatUtils();
/// final formattedDate = utils.formatDate(DateTime.now(), Locale('es'));
/// 
/// // For localized names, use with MCalLocalizations.of(context)
/// final l10n = MCalLocalizations.of(context);
/// final dayName = MCalDateFormatUtils.weekdayName(l10n, 1); // Monday
/// ```
class MCalDateFormatUtils {
  /// Supported locales for the calendar package.
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('es'), // Spanish
    Locale('fr'), // French
    Locale('ar'), // Arabic
    Locale('he'), // Hebrew
  ];

  /// Default locale fallback (English).
  static const Locale defaultLocale = Locale('en');

  /// Creates a new [MCalDateFormatUtils] instance.
  MCalDateFormatUtils();

  /// Formats a date according to the specified locale.
  String formatDate(DateTime date, Locale locale) {
    final localeString = _localeToString(_getEffectiveLocale(locale));
    return DateFormat.yMMMMd(localeString).format(date);
  }

  /// Formats a date with full day name for accessibility.
  String formatFullDateWithDayName(DateTime date, Locale locale) {
    final localeString = _localeToString(_getEffectiveLocale(locale));
    return DateFormat('EEEE, ', localeString).format(date) +
        DateFormat.yMMMMd(localeString).format(date);
  }

  /// Formats a month and year for accessibility announcements.
  String formatMonthYear(DateTime date, Locale locale) {
    final localeString = _localeToString(_getEffectiveLocale(locale));
    return DateFormat.yMMMM(localeString).format(date);
  }

  /// Formats a time according to the specified locale.
  String formatTime(DateTime time, Locale locale) {
    final localeString = _localeToString(_getEffectiveLocale(locale));
    return DateFormat.jm(localeString).format(time);
  }

  /// Detects if the locale uses right-to-left (RTL) text direction.
  bool isRTL(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
      case 'he':
      case 'fa':
      case 'ur':
        return true;
      default:
        return false;
    }
  }

  /// Gets the list of supported locales.
  List<Locale> getSupportedLocales() {
    return List.unmodifiable(supportedLocales);
  }

  /// Formats a multi-day event span label for screen readers.
  /// 
  /// Parameters:
  /// - [l10n]: The MCalLocalizations instance from context
  /// - [spanLength]: Total number of days in the span
  /// - [dayPosition]: Current day position in the span (1-indexed)
  String formatMultiDaySpanLabel(
    MCalLocalizations l10n,
    int spanLength,
    int dayPosition,
  ) {
    return l10n.multiDaySpanLabel(
      spanLength.toString(),
      dayPosition.toString(),
    );
  }

  /// Returns the full weekday name for the given day of week.
  /// 
  /// Parameters:
  /// - [l10n]: The MCalLocalizations instance from context
  /// - [dayOfWeek]: Day of week (0=Sunday, 1=Monday, ..., 6=Saturday)
  /// 
  /// Returns the localized full weekday name.
  static String weekdayName(MCalLocalizations l10n, int dayOfWeek) {
    switch (dayOfWeek) {
      case 0:
        return l10n.daySunday;
      case 1:
        return l10n.dayMonday;
      case 2:
        return l10n.dayTuesday;
      case 3:
        return l10n.dayWednesday;
      case 4:
        return l10n.dayThursday;
      case 5:
        return l10n.dayFriday;
      case 6:
        return l10n.daySaturday;
      default:
        throw ArgumentError('Invalid day of week: $dayOfWeek (must be 0-6)');
    }
  }

  /// Returns the short weekday name for the given day of week.
  /// 
  /// Parameters:
  /// - [l10n]: The MCalLocalizations instance from context
  /// - [dayOfWeek]: Day of week (0=Sunday, 1=Monday, ..., 6=Saturday)
  /// 
  /// Returns the localized short weekday name.
  static String weekdayShortName(MCalLocalizations l10n, int dayOfWeek) {
    switch (dayOfWeek) {
      case 0:
        return l10n.daySundayShort;
      case 1:
        return l10n.dayMondayShort;
      case 2:
        return l10n.dayTuesdayShort;
      case 3:
        return l10n.dayWednesdayShort;
      case 4:
        return l10n.dayThursdayShort;
      case 5:
        return l10n.dayFridayShort;
      case 6:
        return l10n.daySaturdayShort;
      default:
        throw ArgumentError('Invalid day of week: $dayOfWeek (must be 0-6)');
    }
  }

  /// Returns the month name for the given month number.
  /// 
  /// Parameters:
  /// - [l10n]: The MCalLocalizations instance from context
  /// - [month]: Month number (1=January, 2=February, ..., 12=December)
  /// 
  /// Returns the localized month name.
  static String monthName(MCalLocalizations l10n, int month) {
    switch (month) {
      case 1:
        return l10n.monthJanuary;
      case 2:
        return l10n.monthFebruary;
      case 3:
        return l10n.monthMarch;
      case 4:
        return l10n.monthApril;
      case 5:
        return l10n.monthMay;
      case 6:
        return l10n.monthJune;
      case 7:
        return l10n.monthJuly;
      case 8:
        return l10n.monthAugust;
      case 9:
        return l10n.monthSeptember;
      case 10:
        return l10n.monthOctober;
      case 11:
        return l10n.monthNovember;
      case 12:
        return l10n.monthDecember;
      default:
        throw ArgumentError('Invalid month: $month (must be 1-12)');
    }
  }

  Locale _getEffectiveLocale(Locale locale) {
    for (final supported in supportedLocales) {
      if (supported.languageCode == locale.languageCode) {
        if (supported.countryCode == null ||
            supported.countryCode == locale.countryCode) {
          return supported;
        }
      }
    }
    return defaultLocale;
  }

  String _localeToString(Locale locale) {
    if (locale.countryCode != null) {
      return '${locale.languageCode}_${locale.countryCode}';
    }
    return locale.languageCode;
  }
}
