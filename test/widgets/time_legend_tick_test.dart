import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('en_US', null);
    await initializeDateFormatting('ar', null);
  });

  group('Time legend tick marks - visibility', () {
    testWidgets('ticks render when showTimeLegendTicks is true (default)', (
      tester,
    ) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          home: Scaffold(
            body: SizedBox(
              height: 600,
              width: 400,
              child: MCalDayView(
                controller: controller,
                startHour: 8,
                endHour: 12,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // With default theme, showTimeLegendTicks is true - CustomPaint for ticks
      // is present. The Day View contains a Stack with CustomPaint for ticks.
      expect(find.byType(MCalDayView), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      controller.dispose();
    });

    testWidgets('ticks can be disabled via dayTheme.showTimeLegendTicks false', (
      tester,
    ) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );
      final themeWithNoTicks = MCalThemeData(
        dayTheme: MCalDayThemeData(showTimeLegendTicks: false),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          home: Scaffold(
            body: MCalTheme(
              data: themeWithNoTicks,
              child: SizedBox(
                height: 600,
                width: 400,
                child: MCalDayView(
                  controller: controller,
                  startHour: 8,
                  endHour: 12,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Day View should still render
      expect(find.byType(MCalDayView), findsOneWidget);
      // Time labels should still be present
      expect(find.text('8 AM'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('ticks explicitly enabled via dayTheme', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );
      final themeWithTicks = MCalThemeData(
        dayTheme: MCalDayThemeData(showTimeLegendTicks: true),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          home: Scaffold(
            body: MCalTheme(
              data: themeWithTicks,
              child: SizedBox(
                height: 600,
                width: 400,
                child: MCalDayView(
                  controller: controller,
                  startHour: 9,
                  endHour: 11,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MCalDayView), findsOneWidget);
      expect(find.text('9 AM'), findsOneWidget);
      expect(find.text('10 AM'), findsOneWidget);
      expect(find.text('11 AM'), findsOneWidget);

      controller.dispose();
    });
  });

  group('Time legend tick marks - theme customization', () {
    testWidgets('accepts custom timeLegendTickColor', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );
      final themeWithCustomTickColor = MCalThemeData(
        dayTheme: MCalDayThemeData(
          showTimeLegendTicks: true,
          timeLegendTickColor: Colors.red,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          home: Scaffold(
            body: MCalTheme(
              data: themeWithCustomTickColor,
              child: SizedBox(
                height: 600,
                width: 400,
                child: MCalDayView(
                  controller: controller,
                  startHour: 8,
                  endHour: 10,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MCalDayView), findsOneWidget);

      controller.dispose();
    });

    testWidgets('accepts custom timeLegendTickWidth', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );
      final themeWithCustomTickWidth = MCalThemeData(
        dayTheme: MCalDayThemeData(
          showTimeLegendTicks: true,
          timeLegendTickWidth: 2.0,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          home: Scaffold(
            body: MCalTheme(
              data: themeWithCustomTickWidth,
              child: SizedBox(
                height: 600,
                width: 400,
                child: MCalDayView(
                  controller: controller,
                  startHour: 8,
                  endHour: 10,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MCalDayView), findsOneWidget);

      controller.dispose();
    });

    testWidgets('accepts custom timeLegendTickLength', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );
      final themeWithCustomTickLength = MCalThemeData(
        dayTheme: MCalDayThemeData(
          showTimeLegendTicks: true,
          timeLegendTickLength: 12.0,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          home: Scaffold(
            body: MCalTheme(
              data: themeWithCustomTickLength,
              child: SizedBox(
                height: 600,
                width: 400,
                child: MCalDayView(
                  controller: controller,
                  startHour: 8,
                  endHour: 10,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MCalDayView), findsOneWidget);

      controller.dispose();
    });

    testWidgets('accepts all tick customization properties together', (
      tester,
    ) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );
      final themeWithAllCustomTicks = MCalThemeData(
        dayTheme: MCalDayThemeData(
          showTimeLegendTicks: true,
          timeLegendTickColor: Colors.blue,
          timeLegendTickWidth: 3.0,
          timeLegendTickLength: 16.0,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          home: Scaffold(
            body: MCalTheme(
              data: themeWithAllCustomTicks,
              child: SizedBox(
                height: 600,
                width: 400,
                child: MCalDayView(
                  controller: controller,
                  startHour: 8,
                  endHour: 12,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MCalDayView), findsOneWidget);
      expect(find.text('8 AM'), findsOneWidget);

      controller.dispose();
    });
  });

  group('Time legend tick marks - LTR and RTL', () {
    testWidgets('Day View renders in LTR with default locale', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          home: Scaffold(
            body: SizedBox(
              height: 600,
              width: 400,
              child: MCalDayView(
                controller: controller,
                startHour: 8,
                endHour: 10,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MCalDayView), findsOneWidget);
      expect(find.text('8 AM'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('Day View renders in RTL with Arabic locale', (tester) async {
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
                width: 400,
                child: MCalDayView(
                  controller: controller,
                  startHour: 8,
                  endHour: 10,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MCalDayView), findsOneWidget);

      controller.dispose();
    });

    testWidgets('Day View renders in RTL with Hebrew locale', (tester) async {
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
                width: 400,
                child: MCalDayView(
                  controller: controller,
                  startHour: 8,
                  endHour: 10,
                ),
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

  group('Time legend tick marks - golden tests', () {
    testWidgets('golden: LTR time legend with ticks', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          home: Scaffold(
            body: SizedBox(
              height: 400,
              width: 300,
              child: MCalDayView(
                controller: controller,
                startHour: 9,
                endHour: 11,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MCalDayView),
        matchesGoldenFile('goldens/time_legend_ltr.png'),
      );

      controller.dispose();
    });

    testWidgets('golden: RTL time legend with ticks', (tester) async {
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
                height: 400,
                width: 300,
                child: MCalDayView(
                  controller: controller,
                  startHour: 9,
                  endHour: 11,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MCalDayView),
        matchesGoldenFile('goldens/time_legend_rtl.png'),
      );

      controller.dispose();
    });

    testWidgets('golden: time legend with ticks disabled', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );
      final themeNoTicks = MCalThemeData(
        dayTheme: MCalDayThemeData(showTimeLegendTicks: false),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          home: Scaffold(
            body: MCalTheme(
              data: themeNoTicks,
              child: SizedBox(
                height: 400,
                width: 300,
                child: MCalDayView(
                  controller: controller,
                  startHour: 9,
                  endHour: 11,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MCalDayView),
        matchesGoldenFile('goldens/time_legend_no_ticks.png'),
      );

      controller.dispose();
    });
  });
}
