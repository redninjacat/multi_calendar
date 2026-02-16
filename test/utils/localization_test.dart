import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  group('MCalDateFormatUtils', () {
    late MCalDateFormatUtils utils;

    setUpAll(() async {
      // Initialize locale data for intl package in tests
      await initializeDateFormatting('en', null);
      await initializeDateFormatting('es', null);
      await initializeDateFormatting('ar', null);
      await initializeDateFormatting('he', null);
    });

    setUp(() {
      utils = MCalDateFormatUtils();
    });

    test('creates instance successfully', () {
      expect(utils, isNotNull);
    });

    group('formatDate', () {
      test('formats date for English locale', () async {
        final date = DateTime(2024, 1, 15);
        final result = utils.formatDate(date, const Locale('en'));
        expect(result, isNotEmpty);
        expect(result, contains('2024'));
      });

      test('formats date for Spanish locale', () async {
        final date = DateTime(2024, 1, 15);
        final result = utils.formatDate(date, const Locale('es'));
        expect(result, isNotEmpty);
        expect(result, contains('2024'));
      });

      test('falls back to English for unsupported locale', () async {
        final date = DateTime(2024, 1, 15);
        final result = utils.formatDate(date, const Locale('zh'));
        expect(result, isNotEmpty);
      });
    });

    group('formatTime', () {
      test('formats time for English locale', () async {
        final time = DateTime(2024, 1, 15, 14, 30);
        final result = utils.formatTime(time, const Locale('en'));
        expect(result, isNotEmpty);
      });

      test('formats time for Spanish locale', () async {
        final time = DateTime(2024, 1, 15, 14, 30);
        final result = utils.formatTime(time, const Locale('es'));
        expect(result, isNotEmpty);
      });

      test('falls back to English for unsupported locale', () async {
        final time = DateTime(2024, 1, 15, 14, 30);
        final result = utils.formatTime(time, const Locale('zh'));
        expect(result, isNotEmpty);
      });
    });

    group('isRTL', () {
      test('returns false for English locale', () {
        expect(utils.isRTL(const Locale('en')), isFalse);
      });

      test('returns false for Spanish locale', () {
        expect(utils.isRTL(const Locale('es')), isFalse);
      });

      test('returns true for Arabic (RTL) locale', () {
        expect(utils.isRTL(const Locale('ar')), isTrue);
      });

      test('returns true for Hebrew (RTL) locale', () {
        expect(utils.isRTL(const Locale('he')), isTrue);
      });
    });

    group('getSupportedLocales', () {
      test('returns list of supported locales', () {
        final locales = utils.getSupportedLocales();
        expect(locales, isNotEmpty);
        expect(locales.length, 5);
        expect(locales, contains(const Locale('en')));
        expect(locales, contains(const Locale('es')));
        expect(locales, contains(const Locale('fr')));
        expect(locales, contains(const Locale('ar')));
        expect(locales, contains(const Locale('he')));
      });

      test('returns unmodifiable list', () {
        final locales = utils.getSupportedLocales();
        expect(() => locales.add(const Locale('fr')), throwsA(anything));
      });
    });

    group('static helper methods', () {
      testWidgets('weekdayName returns correct localized names', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: MCalLocalizations.localizationsDelegates,
            supportedLocales: MCalLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Builder(
              builder: (context) {
                final l10n = MCalLocalizations.of(context);
                
                expect(MCalDateFormatUtils.weekdayName(l10n, 0), 'Sunday');
                expect(MCalDateFormatUtils.weekdayName(l10n, 1), 'Monday');
                expect(MCalDateFormatUtils.weekdayName(l10n, 2), 'Tuesday');
                expect(MCalDateFormatUtils.weekdayName(l10n, 3), 'Wednesday');
                expect(MCalDateFormatUtils.weekdayName(l10n, 4), 'Thursday');
                expect(MCalDateFormatUtils.weekdayName(l10n, 5), 'Friday');
                expect(MCalDateFormatUtils.weekdayName(l10n, 6), 'Saturday');
                
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('weekdayName throws for invalid day', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: MCalLocalizations.localizationsDelegates,
            supportedLocales: MCalLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Builder(
              builder: (context) {
                final l10n = MCalLocalizations.of(context);
                
                expect(
                  () => MCalDateFormatUtils.weekdayName(l10n, 7),
                  throwsArgumentError,
                );
                expect(
                  () => MCalDateFormatUtils.weekdayName(l10n, -1),
                  throwsArgumentError,
                );
                
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('weekdayShortName returns correct localized names', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: MCalLocalizations.localizationsDelegates,
            supportedLocales: MCalLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Builder(
              builder: (context) {
                final l10n = MCalLocalizations.of(context);
                
                expect(MCalDateFormatUtils.weekdayShortName(l10n, 0), 'Sun');
                expect(MCalDateFormatUtils.weekdayShortName(l10n, 1), 'Mon');
                expect(MCalDateFormatUtils.weekdayShortName(l10n, 2), 'Tue');
                expect(MCalDateFormatUtils.weekdayShortName(l10n, 3), 'Wed');
                expect(MCalDateFormatUtils.weekdayShortName(l10n, 4), 'Thu');
                expect(MCalDateFormatUtils.weekdayShortName(l10n, 5), 'Fri');
                expect(MCalDateFormatUtils.weekdayShortName(l10n, 6), 'Sat');
                
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('weekdayShortName throws for invalid day', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: MCalLocalizations.localizationsDelegates,
            supportedLocales: MCalLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Builder(
              builder: (context) {
                final l10n = MCalLocalizations.of(context);
                
                expect(
                  () => MCalDateFormatUtils.weekdayShortName(l10n, 7),
                  throwsArgumentError,
                );
                expect(
                  () => MCalDateFormatUtils.weekdayShortName(l10n, -1),
                  throwsArgumentError,
                );
                
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('monthName returns correct localized names', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: MCalLocalizations.localizationsDelegates,
            supportedLocales: MCalLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Builder(
              builder: (context) {
                final l10n = MCalLocalizations.of(context);
                
                expect(MCalDateFormatUtils.monthName(l10n, 1), 'January');
                expect(MCalDateFormatUtils.monthName(l10n, 2), 'February');
                expect(MCalDateFormatUtils.monthName(l10n, 3), 'March');
                expect(MCalDateFormatUtils.monthName(l10n, 4), 'April');
                expect(MCalDateFormatUtils.monthName(l10n, 5), 'May');
                expect(MCalDateFormatUtils.monthName(l10n, 6), 'June');
                expect(MCalDateFormatUtils.monthName(l10n, 7), 'July');
                expect(MCalDateFormatUtils.monthName(l10n, 8), 'August');
                expect(MCalDateFormatUtils.monthName(l10n, 9), 'September');
                expect(MCalDateFormatUtils.monthName(l10n, 10), 'October');
                expect(MCalDateFormatUtils.monthName(l10n, 11), 'November');
                expect(MCalDateFormatUtils.monthName(l10n, 12), 'December');
                
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('monthName throws for invalid month', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: MCalLocalizations.localizationsDelegates,
            supportedLocales: MCalLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Builder(
              builder: (context) {
                final l10n = MCalLocalizations.of(context);
                
                expect(
                  () => MCalDateFormatUtils.monthName(l10n, 0),
                  throwsArgumentError,
                );
                expect(
                  () => MCalDateFormatUtils.monthName(l10n, 13),
                  throwsArgumentError,
                );
                
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });
  });

  group('MCalMonthView RTL Keyboard Navigation', () {
    testWidgets('RTL: arrowLeft navigates forward (+1 day)', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2024, 6, 15),
      );
      // Set initial focused date
      controller.setFocusedDate(DateTime(2024, 6, 15));

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          locale: const Locale('ar'),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: MCalMonthView(
                controller: controller,
                enableKeyboardNavigation: true,
                autoFocusOnCellTap: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Focus the month view
      await tester.tap(find.byType(MCalMonthView));
      await tester.pumpAndSettle();

      // Simulate arrowLeft key press (should advance to next day in RTL)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();

      // Verify focused date advanced by 1 day
      expect(controller.focusedDate?.day, 16);

      controller.dispose();
    });

    testWidgets('RTL: arrowRight navigates backward (-1 day)', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2024, 6, 15),
      );
      // Set initial focused date
      controller.setFocusedDate(DateTime(2024, 6, 15));

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          locale: const Locale('ar'),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: MCalMonthView(
                controller: controller,
                enableKeyboardNavigation: true,
                autoFocusOnCellTap: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Focus the month view
      await tester.tap(find.byType(MCalMonthView));
      await tester.pumpAndSettle();

      // Simulate arrowRight key press (should go to previous day in RTL)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      // Verify focused date went back by 1 day
      expect(controller.focusedDate?.day, 14);

      controller.dispose();
    });

    testWidgets('RTL: arrowUp/arrowDown navigation unchanged', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2024, 6, 15),
      );
      // Set initial focused date
      controller.setFocusedDate(DateTime(2024, 6, 15));

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          locale: const Locale('ar'),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: MCalMonthView(
                controller: controller,
                enableKeyboardNavigation: true,
                autoFocusOnCellTap: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Focus the month view
      await tester.tap(find.byType(MCalMonthView));
      await tester.pumpAndSettle();

      // Simulate arrowDown key press (should advance by 7 days)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(controller.focusedDate?.day, 22);

      // Simulate arrowUp key press (should go back by 7 days)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(controller.focusedDate?.day, 15);

      controller.dispose();
    });

    testWidgets('LTR: arrowLeft navigates backward (-1 day)', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2024, 6, 15),
      );
      // Set initial focused date
      controller.setFocusedDate(DateTime(2024, 6, 15));

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: MCalMonthView(
              controller: controller,
              enableKeyboardNavigation: true,
              autoFocusOnCellTap: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Focus the month view
      await tester.tap(find.byType(MCalMonthView));
      await tester.pumpAndSettle();

      // Simulate arrowLeft key press (should go to previous day in LTR)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();

      // Verify focused date went back by 1 day
      expect(controller.focusedDate?.day, 14);

      controller.dispose();
    });

    testWidgets('LTR: arrowRight navigates forward (+1 day)', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2024, 6, 15),
      );
      // Set initial focused date
      controller.setFocusedDate(DateTime(2024, 6, 15));

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: MCalMonthView(
              controller: controller,
              enableKeyboardNavigation: true,
              autoFocusOnCellTap: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Focus the month view
      await tester.tap(find.byType(MCalMonthView));
      await tester.pumpAndSettle();

      // Simulate arrowRight key press (should advance to next day in LTR)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      // Verify focused date advanced by 1 day
      expect(controller.focusedDate?.day, 16);

      controller.dispose();
    });
  });

  group('MCalDayView RTL Keyboard Navigation', () {
    testWidgets('RTL: arrowLeft navigates to next day', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2024, 6, 15),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          locale: const Locale('ar'),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SizedBox(
                width: 600,
                height: 800,
                child: MCalDayView(
                  controller: controller,
                  enableKeyboardNavigation: true,
                  showNavigator: true,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Focus the day view
      await tester.tap(find.byType(MCalDayView));
      await tester.pumpAndSettle();

      // Simulate arrowLeft key press (should navigate to next day in RTL)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();

      // Verify displayDate advanced by 1 day
      expect(controller.displayDate.day, 16);

      controller.dispose();
    });

    testWidgets('RTL: arrowRight navigates to previous day', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2024, 6, 15),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          locale: const Locale('ar'),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SizedBox(
                width: 600,
                height: 800,
                child: MCalDayView(
                  controller: controller,
                  enableKeyboardNavigation: true,
                  showNavigator: true,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Focus the day view
      await tester.tap(find.byType(MCalDayView));
      await tester.pumpAndSettle();

      // Simulate arrowRight key press (should navigate to previous day in RTL)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      // Verify displayDate went back by 1 day
      expect(controller.displayDate.day, 14);

      controller.dispose();
    });

    testWidgets('LTR: arrowLeft navigates to previous day', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2024, 6, 15),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 800,
              child: MCalDayView(
                controller: controller,
                enableKeyboardNavigation: true,
                showNavigator: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Focus the day view
      await tester.tap(find.byType(MCalDayView));
      await tester.pumpAndSettle();

      // Simulate arrowLeft key press (should navigate to previous day in LTR)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();

      // Verify displayDate went back by 1 day
      expect(controller.displayDate.day, 14);

      controller.dispose();
    });

    testWidgets('LTR: arrowRight navigates to next day', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2024, 6, 15),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: MCalLocalizations.localizationsDelegates,
          supportedLocales: MCalLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 800,
              child: MCalDayView(
                controller: controller,
                enableKeyboardNavigation: true,
                showNavigator: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Focus the day view
      await tester.tap(find.byType(MCalDayView));
      await tester.pumpAndSettle();

      // Simulate arrowRight key press (should navigate to next day in LTR)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      // Verify displayDate advanced by 1 day
      expect(controller.displayDate.day, 16);

      controller.dispose();
    });
  });
}
