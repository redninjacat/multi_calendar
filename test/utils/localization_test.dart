import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/src/utils/mcal_localization.dart';

void main() {
  group('MCalLocalizations', () {
    late MCalLocalizations localizations;

    setUpAll(() async {
      // Initialize locale data for intl package in tests
      await initializeDateFormatting('en', null);
      await initializeDateFormatting('es_MX', null);
    });

    setUp(() {
      localizations = MCalLocalizations();
    });

    test('creates instance successfully', () {
      expect(localizations, isNotNull);
    });

    group('getLocalizedString', () {
      test('returns English string for English locale', () {
        final result = localizations.getLocalizedString(
          'dayMonday',
          const Locale('en'),
        );
        expect(result, 'Monday');
      });

      test('returns Spanish string for Spanish locale', () {
        final result = localizations.getLocalizedString(
          'dayMonday',
          const Locale('es', 'MX'),
        );
        expect(result, 'Lunes');
      });

      test('falls back to English for unsupported locale', () {
        final result = localizations.getLocalizedString(
          'dayMonday',
          const Locale('zh'), // Chinese not supported
        );
        expect(result, 'Monday'); // Falls back to English
      });

      test('returns key if key not found', () {
        final result = localizations.getLocalizedString(
          'nonexistentKey',
          const Locale('en'),
        );
        expect(result, 'nonexistentKey');
      });

      test('handles all day names correctly', () {
        final days = [
          'daySunday',
          'dayMonday',
          'dayTuesday',
          'dayWednesday',
          'dayThursday',
          'dayFriday',
          'daySaturday',
        ];
        for (final day in days) {
          final result = localizations.getLocalizedString(
            day,
            const Locale('en'),
          );
          expect(result, isNotEmpty);
          expect(result, isNot(day)); // Should be translated, not the key
        }
      });
    });

    group('formatDate', () {
      test('formats date for English locale', () async {
        final date = DateTime(2024, 1, 15);
        final result = localizations.formatDate(date, const Locale('en'));
        expect(result, isNotEmpty);
        expect(result, contains('2024'));
      });

      test('formats date for Spanish locale', () async {
        final date = DateTime(2024, 1, 15);
        final result = localizations.formatDate(date, const Locale('es', 'MX'));
        expect(result, isNotEmpty);
        expect(result, contains('2024'));
      });

      test('falls back to English for unsupported locale', () async {
        final date = DateTime(2024, 1, 15);
        final result = localizations.formatDate(date, const Locale('zh'));
        expect(result, isNotEmpty);
      });
    });

    group('formatTime', () {
      test('formats time for English locale', () async {
        final time = DateTime(2024, 1, 15, 14, 30);
        final result = localizations.formatTime(time, const Locale('en'));
        expect(result, isNotEmpty);
      });

      test('formats time for Spanish locale', () async {
        final time = DateTime(2024, 1, 15, 14, 30);
        final result = localizations.formatTime(time, const Locale('es', 'MX'));
        expect(result, isNotEmpty);
      });

      test('falls back to English for unsupported locale', () async {
        final time = DateTime(2024, 1, 15, 14, 30);
        final result = localizations.formatTime(time, const Locale('zh'));
        expect(result, isNotEmpty);
      });
    });

    group('isRTL', () {
      test('returns false for English locale', () {
        expect(localizations.isRTL(const Locale('en')), isFalse);
      });

      test('returns false for Spanish locale', () {
        expect(localizations.isRTL(const Locale('es', 'MX')), isFalse);
      });

      test('returns true for Arabic (RTL) locale', () {
        expect(localizations.isRTL(const Locale('ar')), isTrue);
      });

      test('returns true for Hebrew (RTL) locale', () {
        expect(localizations.isRTL(const Locale('he')), isTrue);
      });
    });

    group('getSupportedLocales', () {
      test('returns list of supported locales', () {
        final locales = localizations.getSupportedLocales();
        expect(locales, isNotEmpty);
        expect(locales.length, greaterThanOrEqualTo(5));
        expect(locales, contains(const Locale('en')));
        expect(locales, contains(const Locale('es')));
        expect(locales, contains(const Locale('es', 'MX')));
        expect(locales, contains(const Locale('fr')));
      });

      test('returns unmodifiable list', () {
        final locales = localizations.getSupportedLocales();
        expect(() => locales.add(const Locale('fr')), throwsA(anything));
      });
    });
  });
}
