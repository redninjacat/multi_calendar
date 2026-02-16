import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('es', null);
    await initializeDateFormatting('es_MX', null);
    await initializeDateFormatting('fr', null);
    await initializeDateFormatting('ar', null);
    await initializeDateFormatting('he', null);
  });

  group('MCalLocalizations - supported locales', () {
    test('supportedLocales includes all 5 languages', () {
      final locales = MCalLocalizations.supportedLocales;

      expect(locales.length, greaterThanOrEqualTo(5));
      expect(
        locales.any((l) => l.languageCode == 'en'),
        isTrue,
      );
      expect(
        locales.any((l) => l.languageCode == 'es'),
        isTrue,
      );
      expect(
        locales.any((l) => l.languageCode == 'fr'),
        isTrue,
      );
      expect(
        locales.any((l) => l.languageCode == 'ar'),
        isTrue,
      );
      expect(
        locales.any((l) => l.languageCode == 'he'),
        isTrue,
      );
    });

    test('getSupportedLocales returns unmodifiable list', () {
      final localizations = MCalLocalizations();
      final locales = localizations.getSupportedLocales();

      expect(locales, isNotNull);
      expect(locales, isA<List<Locale>>());
      expect(() => locales.add(const Locale('xx')), throwsUnsupportedError);
    });
  });

  group('MCalLocalizations - English (en)', () {
    test('getLocalizedString returns English for day names', () {
      final localizations = MCalLocalizations();

      expect(
        localizations.getLocalizedString('dayMonday', const Locale('en')),
        equals('Monday'),
      );
      expect(
        localizations.getLocalizedString('daySunday', const Locale('en')),
        equals('Sunday'),
      );
      expect(
        localizations.getLocalizedString('previousDay', const Locale('en')),
        equals('Previous day'),
      );
      expect(
        localizations.getLocalizedString('nextDay', const Locale('en')),
        equals('Next day'),
      );
    });

    test('getLocalizedString returns English for month names', () {
      final localizations = MCalLocalizations();

      expect(
        localizations.getLocalizedString('monthJanuary', const Locale('en')),
        equals('January'),
      );
      expect(
        localizations.getLocalizedString('monthDecember', const Locale('en')),
        equals('December'),
      );
    });

    test('getLocalizedString returns key when key not found', () {
      final localizations = MCalLocalizations();

      expect(
        localizations.getLocalizedString('nonexistentKey', const Locale('en')),
        equals('nonexistentKey'),
      );
    });
  });

  group('MCalLocalizations - Spanish (es)', () {
    test('getLocalizedString returns Spanish for day names', () {
      final localizations = MCalLocalizations();

      expect(
        localizations.getLocalizedString('dayMonday', const Locale('es')),
        equals('Lunes'),
      );
      expect(
        localizations.getLocalizedString('daySunday', const Locale('es')),
        equals('Domingo'),
      );
    });

    test('getLocalizedString returns Spanish for Day View strings', () {
      final localizations = MCalLocalizations();

      expect(
        localizations.getLocalizedString('previousDay', const Locale('es')),
        equals('Día anterior'),
      );
      expect(
        localizations.getLocalizedString('nextDay', const Locale('es')),
        equals('Día siguiente'),
      );
    });
  });

  group('MCalLocalizations - French (fr)', () {
    test('getLocalizedString returns French for day names', () {
      final localizations = MCalLocalizations();

      expect(
        localizations.getLocalizedString('dayMonday', const Locale('fr')),
        equals('Lundi'),
      );
      expect(
        localizations.getLocalizedString('daySaturday', const Locale('fr')),
        equals('Samedi'),
      );
    });

    test('getLocalizedString returns French for month names', () {
      final localizations = MCalLocalizations();

      expect(
        localizations.getLocalizedString('monthJanuary', const Locale('fr')),
        equals('Janvier'),
      );
    });
  });

  group('MCalLocalizations - Arabic (ar)', () {
    test('getLocalizedString returns Arabic for day names', () {
      final localizations = MCalLocalizations();

      final monday = localizations.getLocalizedString('dayMonday', const Locale('ar'));
      expect(monday, isNotEmpty);
      expect(monday, isNot(equals('Monday')));
    });

    test('isRTL returns true for Arabic', () {
      final localizations = MCalLocalizations();

      expect(localizations.isRTL(const Locale('ar')), isTrue);
    });
  });

  group('MCalLocalizations - Hebrew (he)', () {
    test('getLocalizedString returns Hebrew for day names', () {
      final localizations = MCalLocalizations();

      final monday = localizations.getLocalizedString('dayMonday', const Locale('he'));
      expect(monday, isNotEmpty);
      expect(monday, isNot(equals('Monday')));
    });

    test('isRTL returns true for Hebrew', () {
      final localizations = MCalLocalizations();

      expect(localizations.isRTL(const Locale('he')), isTrue);
    });
  });

  group('MCalLocalizations - RTL detection', () {
    test('isRTL returns false for LTR languages', () {
      final localizations = MCalLocalizations();

      expect(localizations.isRTL(const Locale('en')), isFalse);
      expect(localizations.isRTL(const Locale('es')), isFalse);
      expect(localizations.isRTL(const Locale('fr')), isFalse);
    });

    test('isRTL returns true for RTL languages', () {
      final localizations = MCalLocalizations();

      expect(localizations.isRTL(const Locale('ar')), isTrue);
      expect(localizations.isRTL(const Locale('he')), isTrue);
    });
  });

  group('MCalLocalizations - locale fallback', () {
    test('es_MX falls back to es strings', () {
      final localizations = MCalLocalizations();

      final monday = localizations.getLocalizedString(
        'dayMonday',
        const Locale('es', 'MX'),
      );
      expect(monday, equals('Lunes'));
    });

    test('unsupported locale falls back to English', () {
      final localizations = MCalLocalizations();

      final monday = localizations.getLocalizedString(
        'dayMonday',
        const Locale('de'),
      );
      expect(monday, equals('Monday'));
    });
  });

  group('MCalLocalizations - parameter substitution', () {
    test('formatMultiDaySpanLabel substitutes placeholders', () {
      final localizations = MCalLocalizations();

      final label = localizations.formatMultiDaySpanLabel(
        3,
        2,
        const Locale('en'),
      );

      expect(label, contains('3'));
      expect(label, contains('2'));
      expect(label, contains('day'));
      expect(label, contains('event'));
    });

    test('currentTime string has placeholder', () {
      final localizations = MCalLocalizations();

      final template = localizations.getLocalizedString(
        'currentTime',
        const Locale('en'),
      );
      expect(template, contains('{time}'));
    });

    test('scheduleFor string has placeholder', () {
      final localizations = MCalLocalizations();

      final template = localizations.getLocalizedString(
        'scheduleFor',
        const Locale('en'),
      );
      expect(template, contains('{date}'));
    });
  });

  group('MCalLocalizations - date/time formatting', () {
    test('formatDate formats date for English locale', () {
      final localizations = MCalLocalizations();
      final date = DateTime(2026, 2, 15);

      final formatted = localizations.formatDate(date, const Locale('en'));

      expect(formatted, contains('2026'));
      expect(formatted, anyOf(contains('February'), contains('Feb')));
      expect(formatted, contains('15'));
    });

    test('formatDate formats date for Spanish locale', () {
      final localizations = MCalLocalizations();
      final date = DateTime(2026, 2, 15);

      final formatted = localizations.formatDate(date, const Locale('es'));

      expect(formatted, contains('2026'));
      expect(formatted, contains('15'));
    });

    test('formatTime formats time for English locale', () {
      final localizations = MCalLocalizations();
      final time = DateTime(2026, 2, 15, 14, 30);

      final formatted = localizations.formatTime(time, const Locale('en'));

      expect(formatted, isNotEmpty);
    });

    test('formatFullDateWithDayName includes day name', () {
      final localizations = MCalLocalizations();
      final date = DateTime(2026, 2, 15); // Sunday

      final formatted = localizations.formatFullDateWithDayName(
        date,
        const Locale('en'),
      );

      expect(formatted, contains('Sunday'));
      expect(formatted, contains('2026'));
    });

    test('formatMonthYear formats month and year', () {
      final localizations = MCalLocalizations();
      final date = DateTime(2026, 2, 15);

      final formatted = localizations.formatMonthYear(date, const Locale('en'));

      expect(formatted, contains('2026'));
      expect(formatted, anyOf(contains('February'), contains('Feb')));
    });
  });

  group('MCalLocalizations - Day View strings', () {
    test('all 5 languages have Day View navigation strings', () {
      final localizations = MCalLocalizations();
      const locales = [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('ar'),
        Locale('he'),
      ];

      for (final locale in locales) {
        final prevDay = localizations.getLocalizedString('previousDay', locale);
        final nextDay = localizations.getLocalizedString('nextDay', locale);

        expect(prevDay, isNotEmpty);
        expect(nextDay, isNotEmpty);
      }
    });

    test('timeGrid and doubleTapToCreateEvent exist in all languages', () {
      final localizations = MCalLocalizations();
      const locales = [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('ar'),
        Locale('he'),
      ];

      for (final locale in locales) {
        final timeGrid = localizations.getLocalizedString('timeGrid', locale);
        final doubleTap = localizations.getLocalizedString(
          'doubleTapToCreateEvent',
          locale,
        );

        expect(timeGrid, isNotEmpty);
        expect(doubleTap, isNotEmpty);
      }
    });
  });

  group('Localization - widget integration', () {
    testWidgets('Day View renders with English locale', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalDayView(controller: controller),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('8 AM'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('Day View renders with Arabic locale (RTL)', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: SizedBox(
                height: 600,
                child: MCalDayView(controller: controller),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MCalDayView), findsOneWidget);
      controller.dispose();
    });

    testWidgets('Day View renders with Hebrew locale (RTL)', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('he'),
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: SizedBox(
                height: 600,
                child: MCalDayView(controller: controller),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MCalDayView), findsOneWidget);
      controller.dispose();
    });
  });
}
