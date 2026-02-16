import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/mcal_localizations.dart' as l10n;

/// Utility class for calendar localization and date/time formatting.
///
/// This class provides a compatibility layer that delegates to the generated
/// [MCalLocalizations] from Flutter's gen-l10n (see [lookupMCalLocalizations]).
/// It also provides date/time formatting via the intl package.
///
/// Example:
/// ```dart
/// final localizations = MCalLocalizations();
/// final dayName = localizations.getLocalizedString('dayMonday', Locale('en'));
/// final formattedDate = localizations.formatDate(DateTime.now(), Locale('es_MX'));
/// ```
///
/// For apps using [MaterialApp], prefer [MCalLocalizations.of] from the
/// generated `package:multi_calendar/l10n/mcal_localizations.dart` for
/// context-based locale resolution.
class MCalLocalizations {
  /// Supported locales for the calendar package.
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('es'), // Spanish
    Locale('es', 'MX'), // Mexican Spanish
    Locale('fr'), // French
    Locale('ar'), // Arabic
    Locale('he'), // Hebrew
  ];

  /// Default locale fallback (English).
  static const Locale defaultLocale = Locale('en');

  /// Creates a new [MCalLocalizations] instance.
  MCalLocalizations();

  /// Gets a localized string for the given key and locale.
  ///
  /// Delegates to the generated [MCalLocalizations] from gen-l10n.
  /// For parameterized strings (e.g. currentTime, scheduleFor), returns the
  /// template with placeholders; callers should use [replaceAll] for substitution.
  ///
  /// Parameters:
  /// - [key]: The localization key (e.g., 'dayMonday', 'today')
  /// - [locale]: The target locale
  ///
  /// Returns the localized string or the key if not found.
  String getLocalizedString(String key, Locale locale) {
    final l = _lookup(locale);
    switch (key) {
      case 'daySunday':
        return l.daySunday;
      case 'dayMonday':
        return l.dayMonday;
      case 'dayTuesday':
        return l.dayTuesday;
      case 'dayWednesday':
        return l.dayWednesday;
      case 'dayThursday':
        return l.dayThursday;
      case 'dayFriday':
        return l.dayFriday;
      case 'daySaturday':
        return l.daySaturday;
      case 'daySundayShort':
        return l.daySundayShort;
      case 'dayMondayShort':
        return l.dayMondayShort;
      case 'dayTuesdayShort':
        return l.dayTuesdayShort;
      case 'dayWednesdayShort':
        return l.dayWednesdayShort;
      case 'dayThursdayShort':
        return l.dayThursdayShort;
      case 'dayFridayShort':
        return l.dayFridayShort;
      case 'daySaturdayShort':
        return l.daySaturdayShort;
      case 'monthJanuary':
        return l.monthJanuary;
      case 'monthFebruary':
        return l.monthFebruary;
      case 'monthMarch':
        return l.monthMarch;
      case 'monthApril':
        return l.monthApril;
      case 'monthMay':
        return l.monthMay;
      case 'monthJune':
        return l.monthJune;
      case 'monthJuly':
        return l.monthJuly;
      case 'monthAugust':
        return l.monthAugust;
      case 'monthSeptember':
        return l.monthSeptember;
      case 'monthOctober':
        return l.monthOctober;
      case 'monthNovember':
        return l.monthNovember;
      case 'monthDecember':
        return l.monthDecember;
      case 'today':
        return l.today;
      case 'week':
        return l.week;
      case 'month':
        return l.month;
      case 'day':
        return l.day;
      case 'year':
        return l.year;
      case 'previousDay':
        return l.previousDay;
      case 'nextDay':
        return l.nextDay;
      case 'previousMonth':
        return l.previousMonth;
      case 'nextMonth':
        return l.nextMonth;
      case 'currentTime':
        return l.currentTime('{time}');
      case 'focused':
        return l.focused;
      case 'selected':
        return l.selected;
      case 'event':
        return l.event;
      case 'events':
        return l.events;
      case 'doubleTapToSelect':
        return l.doubleTapToSelect;
      case 'calendar':
        return l.calendar;
      case 'dropTargetPrefix':
        return l.dropTargetPrefix;
      case 'dropTargetDateRangeTo':
        return l.dropTargetDateRangeTo;
      case 'dropTargetValid':
        return l.dropTargetValid;
      case 'dropTargetInvalid':
        return l.dropTargetInvalid;
      case 'multiDaySpanLabel':
        return l.multiDaySpanLabel('{days}', '{position}');
      case 'scheduleFor':
        return l.scheduleFor('{date}');
      case 'timeGrid':
        return l.timeGrid;
      case 'doubleTapToCreateEvent':
        return l.doubleTapToCreateEvent;
      case 'allDay':
        return l.allDay;
      default:
        return key;
    }
  }

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
  String formatMultiDaySpanLabel(int spanLength, int dayPosition, Locale locale) {
    final template = getLocalizedString('multiDaySpanLabel', locale);
    return template
        .replaceAll('{days}', spanLength.toString())
        .replaceAll('{position}', dayPosition.toString());
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

  l10n.MCalLocalizations _lookup(Locale locale) {
    try {
      return l10n.lookupMCalLocalizations(_getEffectiveLocale(locale));
    } catch (_) {
      return l10n.lookupMCalLocalizations(defaultLocale);
    }
  }
}
