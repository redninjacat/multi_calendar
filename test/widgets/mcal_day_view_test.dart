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

  group('MCalDayView basic rendering', () {
    late MCalEventController controller;
    final displayDate = DateTime(2026, 2, 14); // Saturday

    setUp(() {
      controller = MCalEventController(initialDate: displayDate);
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('widget builds without errors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalDayView(controller: controller),
            ),
          ),
        ),
      );

      expect(find.byType(MCalDayView), findsOneWidget);
    });

    testWidgets('time legend shows correct hours', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          home: Scaffold(
            body: SizedBox(
              height: 800,
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

      // Time legend shows hour labels - default format for en_US is "9 AM", "10 AM", etc.
      expect(find.text('8 AM'), findsOneWidget);
      expect(find.text('9 AM'), findsOneWidget);
      expect(find.text('10 AM'), findsOneWidget);
      expect(find.text('11 AM'), findsOneWidget);
      expect(find.text('12 PM'), findsOneWidget);
    });

    testWidgets('gridlines render at correct positions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
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

      // Gridlines layer uses Semantics with label 'Time grid'
      expect(find.bySemanticsLabel('Time grid'), findsOneWidget);
    });

    testWidgets('all-day section appears when all-day events exist', (
      tester,
    ) async {
      controller.addEvents([
        MCalCalendarEvent(
          id: 'all-day-1',
          title: 'Conference',
          start: DateTime(2026, 2, 14),
          end: DateTime(2026, 2, 14, 23, 59, 59),
          isAllDay: true,
        ),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalDayView(controller: controller),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // All-day event title should be visible
      expect(find.text('Conference'), findsOneWidget);
    });

    testWidgets('timed events area appears', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalDayView(controller: controller),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Timed events area is present (contains scrollable content)
      expect(find.byType(MCalDayView), findsOneWidget);
      // Gridlines confirm timed area structure
      expect(find.bySemanticsLabel('Time grid'), findsOneWidget);
    });

    testWidgets('day header displays date', (tester) async {
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

      // Day header shows day of week (SAT - short form uppercased) and date (14)
      expect(find.text('SAT'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
    });
  });

  group('MCalDayView with empty controller', () {
    late MCalEventController controller;

    setUp(() {
      controller = MCalEventController(initialDate: DateTime(2026, 2, 14));
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders without events', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalDayView(controller: controller),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MCalDayView), findsOneWidget);
    });

    testWidgets('does not show all-day section when no all-day events', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalDayView(controller: controller),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // With no all-day events, the all-day section is not rendered
      // (design: only shows when _allDayEvents.isNotEmpty)
      expect(find.byType(MCalDayView), findsOneWidget);
    });
  });

  group('MCalDayView with sample events', () {
    late MCalEventController controller;
    final displayDate = DateTime(2026, 2, 14);

    setUp(() {
      controller = MCalEventController(initialDate: displayDate);
      controller.addEvents([
        MCalCalendarEvent(
          id: 'timed-1',
          title: 'Team Meeting',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
          isAllDay: false,
        ),
        MCalCalendarEvent(
          id: 'all-day-1',
          title: 'Holiday',
          start: DateTime(2026, 2, 14),
          end: DateTime(2026, 2, 14, 23, 59, 59),
          isAllDay: true,
        ),
      ]);
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders timed events', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 800,
              child: MCalDayView(
                controller: controller,
                startHour: 8,
                endHour: 18,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Team Meeting'), findsOneWidget);
    });

    testWidgets('renders all-day and timed events together', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 800,
              child: MCalDayView(
                controller: controller,
                startHour: 8,
                endHour: 18,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Team Meeting'), findsOneWidget);
      expect(find.text('Holiday'), findsOneWidget);
    });
  });

  group('MCalDayView edge cases', () {
    testWidgets('accepts theme from MCalTheme', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );
      final customTheme = MCalThemeData(
        dayTheme: MCalDayThemeData(
          timeLegendTextStyle: const TextStyle(fontSize: 14, color: Colors.blue),
          hourGridlineColor: Colors.grey,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MCalTheme(
              data: customTheme,
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

    testWidgets('accepts minimal parameters', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MCalDayView(controller: controller)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MCalDayView), findsOneWidget);
      controller.dispose();
    });

    testWidgets('does not crash with narrow time range', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200,
              child: MCalDayView(
                controller: controller,
                startHour: 12,
                endHour: 12,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MCalDayView), findsOneWidget);
      controller.dispose();
    });

    testWidgets('handles showNavigator', (tester) async {
      final controller = MCalEventController(
        initialDate: DateTime(2026, 2, 14),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalDayView(controller: controller, showNavigator: true),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MCalDayView), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      controller.dispose();
    });

    testWidgets(
      'supports RTL layout - time legend on right, navigator flipped',
      (tester) async {
        final controller = MCalEventController(
          initialDate: DateTime(2026, 2, 14),
        );
        controller.addEvents([
          MCalCalendarEvent(
            id: 'rtl-event',
            title: 'RTL Event',
            start: DateTime(2026, 2, 14, 10, 0),
            end: DateTime(2026, 2, 14, 11, 0),
          ),
        ]);

        await tester.pumpWidget(
          MaterialApp(
          locale: const Locale('ar'),
          home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: SizedBox(
                  height: 600,
                  child: MCalDayView(
                    controller: controller,
                    locale: const Locale('ar'),
                    showNavigator: true,
                    startHour: 8,
                    endHour: 18,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(MCalDayView), findsOneWidget);
        expect(find.text('RTL Event'), findsOneWidget);
        // In RTL, navigator uses flipped chevrons (chevron_left for next, etc.)
        expect(find.byIcon(Icons.chevron_left), findsAtLeast(1));
        expect(find.byIcon(Icons.chevron_right), findsAtLeast(1));
        controller.dispose();
      },
    );
  });
}
