import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('es', null);
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

    test('supportedLocales is unmodifiable', () {
      final locales = MCalDateFormatUtils.supportedLocales;

      expect(locales, isNotNull);
      expect(locales, isA<List<Locale>>());
      expect(() => locales.add(const Locale('xx')), throwsUnsupportedError);
    });
  });

  group('MCalLocalizations - English (en)', () {
    testWidgets('provides English for day names', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = MCalLocalizations.of(context);
              return Column(
                children: [
                  Text(l10n.dayMonday),
                  Text(l10n.daySunday),
                  Text(l10n.previousDay),
                  Text(l10n.nextDay),
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('Sunday'), findsOneWidget);
      expect(find.text('Previous day'), findsOneWidget);
      expect(find.text('Next day'), findsOneWidget);
    });

    testWidgets('provides English for month names', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = MCalLocalizations.of(context);
              return Column(
                children: [
                  Text(l10n.monthJanuary),
                  Text(l10n.monthDecember),
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('January'), findsOneWidget);
      expect(find.text('December'), findsOneWidget);
    });
  });

  group('MCalLocalizations - Spanish (es)', () {
    testWidgets('provides Spanish for day names', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = MCalLocalizations.of(context);
              return Column(
                children: [
                  Text(l10n.dayMonday),
                  Text(l10n.daySunday),
                  Text(l10n.previousDay),
                  Text(l10n.nextDay),
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Lunes'), findsOneWidget);
      expect(find.text('Domingo'), findsOneWidget);
      expect(find.text('Día anterior'), findsOneWidget);
      expect(find.text('Día siguiente'), findsOneWidget);
    });
  });

  group('MCalLocalizations - French (fr)', () {
    testWidgets('provides French for day names and months', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = MCalLocalizations.of(context);
              return Column(
                children: [
                  Text(l10n.dayMonday),
                  Text(l10n.daySaturday),
                  Text(l10n.monthJanuary),
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Lundi'), findsOneWidget);
      expect(find.text('Samedi'), findsOneWidget);
      expect(find.text('Janvier'), findsOneWidget);
    });
  });

  group('MCalLocalizations - Arabic (ar)', () {
    testWidgets('provides Arabic for day names', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = MCalLocalizations.of(context);
              return Text(l10n.dayMonday);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final mondayWidget = find.byType(Text);
      expect(mondayWidget, findsOneWidget);
      final text = tester.widget<Text>(mondayWidget).data;
      expect(text, isNotEmpty);
      expect(text, isNot(equals('Monday')));
    });

    test('isRTL returns true for Arabic', () {
      final utils = MCalDateFormatUtils();
      expect(utils.isRTL(const Locale('ar')), isTrue);
    });
  });

  group('MCalLocalizations - Hebrew (he)', () {
    testWidgets('provides Hebrew for day names', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('he'),
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = MCalLocalizations.of(context);
              return Text(l10n.dayMonday);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final mondayWidget = find.byType(Text);
      expect(mondayWidget, findsOneWidget);
      final text = tester.widget<Text>(mondayWidget).data;
      expect(text, isNotEmpty);
      expect(text, isNot(equals('Monday')));
    });

    test('isRTL returns true for Hebrew', () {
      final utils = MCalDateFormatUtils();
      expect(utils.isRTL(const Locale('he')), isTrue);
    });
  });

  group('MCalDateFormatUtils - RTL detection', () {
    test('isRTL returns false for LTR languages', () {
      final utils = MCalDateFormatUtils();

      expect(utils.isRTL(const Locale('en')), isFalse);
      expect(utils.isRTL(const Locale('es')), isFalse);
      expect(utils.isRTL(const Locale('fr')), isFalse);
    });

    test('isRTL returns true for RTL languages', () {
      final utils = MCalDateFormatUtils();

      expect(utils.isRTL(const Locale('ar')), isTrue);
      expect(utils.isRTL(const Locale('he')), isTrue);
    });
  });

  group('MCalLocalizations - parameter substitution', () {
    testWidgets('multiDaySpanLabel substitutes placeholders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = MCalLocalizations.of(context);
              return Text(l10n.multiDaySpanLabel('3', '2'));
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textWidget = find.byType(Text);
      expect(textWidget, findsOneWidget);
      final text = tester.widget<Text>(textWidget).data;
      expect(text, contains('3'));
      expect(text, contains('2'));
      expect(text, contains('day'));
    });

    testWidgets('currentTime has placeholder substitution', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = MCalLocalizations.of(context);
              return Text(l10n.currentTime('2:30 PM'));
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('2:30 PM'), findsOneWidget);
    });

    testWidgets('scheduleFor has placeholder substitution', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = MCalLocalizations.of(context);
              return Text(l10n.scheduleFor('Feb 15'));
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Feb 15'), findsOneWidget);
    });
  });

  group('MCalDateFormatUtils - date/time formatting', () {
    test('formatDate formats date for English locale', () {
      final utils = MCalDateFormatUtils();
      final date = DateTime(2026, 2, 15);

      final formatted = utils.formatDate(date, const Locale('en'));

      expect(formatted, contains('2026'));
      expect(formatted, anyOf(contains('February'), contains('Feb')));
      expect(formatted, contains('15'));
    });

    test('formatDate formats date for Spanish locale', () {
      final utils = MCalDateFormatUtils();
      final date = DateTime(2026, 2, 15);

      final formatted = utils.formatDate(date, const Locale('es'));

      expect(formatted, contains('2026'));
      expect(formatted, contains('15'));
    });

    test('formatTime formats time for English locale', () {
      final utils = MCalDateFormatUtils();
      final time = DateTime(2026, 2, 15, 14, 30);

      final formatted = utils.formatTime(time, const Locale('en'));

      expect(formatted, isNotEmpty);
    });

    test('formatFullDateWithDayName includes day name', () {
      final utils = MCalDateFormatUtils();
      final date = DateTime(2026, 2, 15); // Sunday

      final formatted = utils.formatFullDateWithDayName(
        date,
        const Locale('en'),
      );

      expect(formatted, contains('Sunday'));
      expect(formatted, contains('2026'));
    });

    test('formatMonthYear formats month and year', () {
      final utils = MCalDateFormatUtils();
      final date = DateTime(2026, 2, 15);

      final formatted = utils.formatMonthYear(date, const Locale('en'));

      expect(formatted, contains('2026'));
      expect(formatted, anyOf(contains('February'), contains('Feb')));
    });
  });

  group('MCalLocalizations - Day View strings', () {
    testWidgets('all 5 languages have Day View navigation strings',
        (tester) async {
      const locales = [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('ar'),
        Locale('he'),
      ];

      for (final locale in locales) {
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: MCalLocalizations.localizationsDelegates,
            supportedLocales: MCalLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                final l10n = MCalLocalizations.of(context);
                return Column(
                  children: [
                    Text(l10n.previousDay),
                    Text(l10n.nextDay),
                  ],
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        expect(texts[0].data, isNotEmpty);
        expect(texts[1].data, isNotEmpty);
      }
    });

    testWidgets('timeGrid and doubleTapToCreateEvent exist in all languages',
        (tester) async {
      const locales = [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('ar'),
        Locale('he'),
      ];

      for (final locale in locales) {
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: MCalLocalizations.localizationsDelegates,
            supportedLocales: MCalLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                final l10n = MCalLocalizations.of(context);
                return Column(
                  children: [
                    Text(l10n.timeGrid),
                    Text(l10n.doubleTapToCreateEvent),
                  ],
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        expect(texts[0].data, isNotEmpty);
        expect(texts[1].data, isNotEmpty);
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
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
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
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
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
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
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
