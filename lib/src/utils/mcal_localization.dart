import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

/// Utility class for calendar localization and date/time formatting.
///
/// This class provides methods to get localized strings, format dates and times
/// according to locale, detect RTL languages, and manage supported locales.
/// It integrates with the intl package and ARB files for localization.
///
/// Example:
/// ```dart
/// final localizations = MCalLocalizations();
/// final dayName = localizations.getLocalizedString('dayMonday', Locale('en'));
/// final formattedDate = localizations.formatDate(DateTime.now(), Locale('es_MX'));
/// ```
class MCalLocalizations {
  /// Supported locales for the calendar package.
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('es', 'MX'), // Mexican Spanish
  ];

  /// Default locale fallback (English).
  static const Locale defaultLocale = Locale('en');

  /// Creates a new [MCalLocalizations] instance.
  MCalLocalizations();

  /// Gets a localized string for the given key and locale.
  ///
  /// If the locale is not supported, falls back to English.
  /// If the key is not found, returns the key itself.
  ///
  /// Parameters:
  /// - [key]: The localization key (e.g., 'dayMonday', 'today')
  /// - [locale]: The target locale
  ///
  /// Returns the localized string or the key if not found.
  String getLocalizedString(String key, Locale locale) {
    // For now, return a simple mapping
    // In a full implementation, this would load from ARB files
    final effectiveLocale = _getEffectiveLocale(locale);

    // Simple string mapping - in production this would use generated code from ARB
    final strings = _getLocalizedStrings(effectiveLocale);
    return strings[key] ?? key;
  }

  /// Formats a date according to the specified locale.
  ///
  /// Parameters:
  /// - [date]: The date to format
  /// - [locale]: The target locale
  ///
  /// Returns a formatted date string.
  String formatDate(DateTime date, Locale locale) {
    final effectiveLocale = _getEffectiveLocale(locale);
    final localeString = _localeToString(effectiveLocale);

    return DateFormat.yMMMMd(localeString).format(date);
  }

  /// Formats a date with full day name for accessibility.
  ///
  /// Returns a full date string including the day name, suitable for
  /// screen reader announcements (e.g., "Saturday, January 15, 2026").
  ///
  /// Parameters:
  /// - [date]: The date to format
  /// - [locale]: The target locale
  ///
  /// Returns a formatted date string with day name.
  String formatFullDateWithDayName(DateTime date, Locale locale) {
    final effectiveLocale = _getEffectiveLocale(locale);
    final localeString = _localeToString(effectiveLocale);

    // EEEE = full day name, yMMMMd = full date
    return DateFormat('EEEE, ', localeString).format(date) +
        DateFormat.yMMMMd(localeString).format(date);
  }

  /// Formats a month and year for accessibility announcements.
  ///
  /// Returns a month-year string suitable for screen reader announcements
  /// (e.g., "January 2026").
  ///
  /// Parameters:
  /// - [date]: The date (only month and year are used)
  /// - [locale]: The target locale
  ///
  /// Returns a formatted month-year string.
  String formatMonthYear(DateTime date, Locale locale) {
    final effectiveLocale = _getEffectiveLocale(locale);
    final localeString = _localeToString(effectiveLocale);

    return DateFormat.yMMMM(localeString).format(date);
  }

  /// Formats a time according to the specified locale.
  ///
  /// Parameters:
  /// - [time]: The time to format
  /// - [locale]: The target locale
  ///
  /// Returns a formatted time string.
  String formatTime(DateTime time, Locale locale) {
    final effectiveLocale = _getEffectiveLocale(locale);
    final localeString = _localeToString(effectiveLocale);

    return DateFormat.jm(localeString).format(time);
  }

  /// Detects if the locale uses right-to-left (RTL) text direction.
  ///
  /// Currently returns false for all supported locales (English and Spanish).
  /// This method is prepared for future RTL language support.
  ///
  /// Parameters:
  /// - [locale]: The locale to check
  ///
  /// Returns true if the locale is RTL, false otherwise.
  bool isRTL(Locale locale) {
    // English and Spanish are LTR
    // Future: Add RTL language detection (e.g., Arabic, Hebrew)
    return false;
  }

  /// Gets the list of supported locales.
  ///
  /// Returns a list of [Locale] objects that are supported by the package.
  List<Locale> getSupportedLocales() {
    return List.unmodifiable(supportedLocales);
  }

  /// Gets the effective locale, falling back to default if not supported.
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

  /// Converts a Locale to a string format for intl package.
  String _localeToString(Locale locale) {
    if (locale.countryCode != null) {
      return '${locale.languageCode}_${locale.countryCode}';
    }
    return locale.languageCode;
  }

  /// Gets localized strings for a locale.
  ///
  /// This is a simple implementation. In production, this would use
  /// generated code from ARB files via flutter gen-l10n.
  Map<String, String> _getLocalizedStrings(Locale locale) {
    if (locale.languageCode == 'es') {
      return _spanishStrings;
    }
    return _englishStrings;
  }

  static const Map<String, String> _englishStrings = {
    'daySunday': 'Sunday',
    'dayMonday': 'Monday',
    'dayTuesday': 'Tuesday',
    'dayWednesday': 'Wednesday',
    'dayThursday': 'Thursday',
    'dayFriday': 'Friday',
    'daySaturday': 'Saturday',
    'daySundayShort': 'Sun',
    'dayMondayShort': 'Mon',
    'dayTuesdayShort': 'Tue',
    'dayWednesdayShort': 'Wed',
    'dayThursdayShort': 'Thu',
    'dayFridayShort': 'Fri',
    'daySaturdayShort': 'Sat',
    'monthJanuary': 'January',
    'monthFebruary': 'February',
    'monthMarch': 'March',
    'monthApril': 'April',
    'monthMay': 'May',
    'monthJune': 'June',
    'monthJuly': 'July',
    'monthAugust': 'August',
    'monthSeptember': 'September',
    'monthOctober': 'October',
    'monthNovember': 'November',
    'monthDecember': 'December',
    'today': 'Today',
    'week': 'Week',
    'month': 'Month',
    'day': 'Day',
    'year': 'Year',
    // Accessibility strings
    'focused': 'focused',
    'selected': 'selected',
    'event': 'event',
    'events': 'events',
    'previousMonth': 'previous month',
    'nextMonth': 'next month',
    'doubleTapToSelect': 'Double tap to select',
    'calendar': 'Calendar',
    // Drop target semantics (single announcement for whole overlay)
    'dropTargetPrefix': 'Drop target',
    'dropTargetDateRangeTo': 'to',
    'dropTargetValid': 'valid',
    'dropTargetInvalid': 'invalid',
  };

  static const Map<String, String> _spanishStrings = {
    'daySunday': 'Domingo',
    'dayMonday': 'Lunes',
    'dayTuesday': 'Martes',
    'dayWednesday': 'Miércoles',
    'dayThursday': 'Jueves',
    'dayFriday': 'Viernes',
    'daySaturday': 'Sábado',
    'daySundayShort': 'Dom',
    'dayMondayShort': 'Lun',
    'dayTuesdayShort': 'Mar',
    'dayWednesdayShort': 'Mié',
    'dayThursdayShort': 'Jue',
    'dayFridayShort': 'Vie',
    'daySaturdayShort': 'Sáb',
    'monthJanuary': 'Enero',
    'monthFebruary': 'Febrero',
    'monthMarch': 'Marzo',
    'monthApril': 'Abril',
    'monthMay': 'Mayo',
    'monthJune': 'Junio',
    'monthJuly': 'Julio',
    'monthAugust': 'Agosto',
    'monthSeptember': 'Septiembre',
    'monthOctober': 'Octubre',
    'monthNovember': 'Noviembre',
    'monthDecember': 'Diciembre',
    'today': 'Hoy',
    'week': 'Semana',
    'month': 'Mes',
    'day': 'Día',
    'year': 'Año',
    // Accessibility strings
    'focused': 'enfocado',
    'selected': 'seleccionado',
    'event': 'evento',
    'events': 'eventos',
    'previousMonth': 'mes anterior',
    'nextMonth': 'mes siguiente',
    'doubleTapToSelect': 'Toca dos veces para seleccionar',
    'calendar': 'Calendario',
    // Drop target semantics (single announcement for whole overlay)
    'dropTargetPrefix': 'Zona de soltar',
    'dropTargetDateRangeTo': 'a',
    'dropTargetValid': 'válido',
    'dropTargetInvalid': 'no válido',
  };
}
