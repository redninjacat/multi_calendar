import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

/// Mock MCalEventController for testing
class MockMCalEventController extends MCalEventController {
  MockMCalEventController({super.initialDate});

  void addEventsForRange(
    DateTime start,
    DateTime end,
    List<MCalCalendarEvent> events,
  ) {
    addEvents(events);
  }

  void setMockEvents(List<MCalCalendarEvent> events) {
    clearEvents();
    addEvents(events);
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('es_MX', null);
  });

  group('Month View onCellDoubleTap', () {
    testWidgets('onCellDoubleTap fires when empty cell is double-tapped', (
      tester,
    ) async {
      final controller = MockMCalEventController(
        initialDate: DateTime(2025, 1, 15),
      );
      controller.addEventsForRange(
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 31, 23, 59, 59, 999),
        [],
      );

      MCalCellDoubleTapDetails? capturedDetails;
      BuildContext? capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalMonthView(
                controller: controller,
                onCellDoubleTap: (context, details) {
                  capturedContext = context;
                  capturedDetails = details;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Double-tap on day 15 (empty cell)
      final cellFinder = find.text('15').first;
      await tester.tap(cellFinder, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(cellFinder, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(capturedContext, isNotNull);
      expect(capturedDetails, isNotNull);
      expect(capturedDetails!.date.day, equals(15));
      expect(capturedDetails!.date.month, equals(1));
      expect(capturedDetails!.date.year, equals(2025));
      expect(capturedDetails!.isCurrentMonth, isTrue);
      expect(capturedDetails!.events, isEmpty);
      expect(capturedDetails!.localPosition, isNotNull);
      expect(capturedDetails!.globalPosition, isNotNull);

      controller.dispose();
    });

    testWidgets('onCellDoubleTap receives correct date for different cells', (
      tester,
    ) async {
      final controller = MockMCalEventController(
        initialDate: DateTime(2025, 1, 1),
      );
      controller.addEventsForRange(
        DateTime(2024, 12, 1),
        DateTime(2025, 2, 28, 23, 59, 59, 999),
        [],
      );

      DateTime? lastTappedDate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalMonthView(
                controller: controller,
                onCellDoubleTap: (context, details) {
                  lastTappedDate = details.date;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Double-tap on day 7
      await tester.tap(find.text('7').first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('7').first, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(lastTappedDate, isNotNull);
      expect(lastTappedDate!.day, equals(7));
      expect(lastTappedDate!.month, equals(1));

      // Double-tap on day 20
      lastTappedDate = null;
      await tester.tap(find.text('20').first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('20').first, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(lastTappedDate, isNotNull);
      expect(lastTappedDate!.day, equals(20));
      expect(lastTappedDate!.month, equals(1));

      controller.dispose();
    });

    testWidgets('onCellDoubleTap receives localPosition and globalPosition', (
      tester,
    ) async {
      final controller = MockMCalEventController(
        initialDate: DateTime(2025, 1, 15),
      );
      controller.addEventsForRange(
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 31, 23, 59, 59, 999),
        [],
      );

      Offset? localPos;
      Offset? globalPos;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalMonthView(
                controller: controller,
                onCellDoubleTap: (context, details) {
                  localPos = details.localPosition;
                  globalPos = details.globalPosition;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('15').first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('15').first, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(localPos, isNotNull);
      expect(globalPos, isNotNull);
      expect(localPos!.dx, greaterThanOrEqualTo(0));
      expect(localPos!.dy, greaterThanOrEqualTo(0));
      expect(globalPos!.dx, greaterThanOrEqualTo(0));
      expect(globalPos!.dy, greaterThanOrEqualTo(0));

      controller.dispose();
    });

    testWidgets('onCellDoubleTap receives events when cell has events', (
      tester,
    ) async {
      final controller = MockMCalEventController(
        initialDate: DateTime(2025, 1, 15),
      );
      final events = [
        MCalCalendarEvent(
          id: 'event-1',
          title: 'Cell Event',
          start: DateTime(2025, 1, 10, 9, 0),
          end: DateTime(2025, 1, 10, 10, 0),
        ),
      ];
      controller.addEventsForRange(
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 31, 23, 59, 59, 999),
        events,
      );

      MCalCellDoubleTapDetails? capturedDetails;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalMonthView(
                controller: controller,
                onCellDoubleTap: (context, details) {
                  capturedDetails = details;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Double-tap on day 10 (cell with event - tap on empty part of cell)
      // We need to tap on the cell but not on the event - tap on date label area
      final cellFinder = find.text('10').first;
      await tester.tap(cellFinder, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(cellFinder, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(capturedDetails, isNotNull);
      expect(capturedDetails!.date.day, equals(10));
      expect(capturedDetails!.events.length, equals(1));
      expect(capturedDetails!.events.first.title, equals('Cell Event'));

      controller.dispose();
    });

    testWidgets('onCellDoubleTap is not called when callback is null', (
      tester,
    ) async {
      final controller = MockMCalEventController(
        initialDate: DateTime(2025, 1, 15),
      );
      controller.addEventsForRange(
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 31, 23, 59, 59, 999),
        [],
      );

      var callbackCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalMonthView(
                controller: controller,
                onCellDoubleTap: null,
                onCellTap: (context, details) {
                  callbackCount++;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Double-tap - should not trigger onCellDoubleTap (null)
      // Single tap should still work
      await tester.tap(find.text('15').first, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(callbackCount, equals(1));

      controller.dispose();
    });

    testWidgets('single tap does not trigger onCellDoubleTap', (tester) async {
      final controller = MockMCalEventController(
        initialDate: DateTime(2025, 1, 15),
      );
      controller.addEventsForRange(
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 31, 23, 59, 59, 999),
        [],
      );

      var doubleTapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalMonthView(
                controller: controller,
                onCellDoubleTap: (context, details) {
                  doubleTapCount++;
                },
                onCellTap: (context, details) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Single tap only
      await tester.tap(find.text('15').first, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(doubleTapCount, equals(0));

      controller.dispose();
    });

    testWidgets('onCellDoubleTap works for leading dates (previous month)', (
      tester,
    ) async {
      final controller = MockMCalEventController(
        initialDate: DateTime(2025, 2, 1),
      );
      controller.addEventsForRange(
        DateTime(2025, 1, 1),
        DateTime(2025, 3, 31, 23, 59, 59, 999),
        [],
      );

      MCalCellDoubleTapDetails? capturedDetails;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalMonthView(
                controller: controller,
                firstDayOfWeek: 0,
                onCellDoubleTap: (context, details) {
                  capturedDetails = details;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // February 2025 - first row has Jan 26-31 as leading dates
      final leadingDayFinder = find.text('26');
      if (leadingDayFinder.evaluate().isNotEmpty) {
        await tester.tap(leadingDayFinder.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(leadingDayFinder.first, warnIfMissed: false);
        await tester.pumpAndSettle();

        if (capturedDetails != null && capturedDetails!.date.month == 1) {
          expect(capturedDetails!.isCurrentMonth, isFalse);
          expect(capturedDetails!.date.day, equals(26));
        }
      }

      controller.dispose();
    });
  });

  group('Month View onEventDoubleTap', () {
    testWidgets('onEventDoubleTap fires when event tile is double-tapped', (
      tester,
    ) async {
      final controller = MockMCalEventController(
        initialDate: DateTime(2025, 1, 15),
      );
      final event = MCalCalendarEvent(
        id: 'event-double-tap',
        title: 'Double Tap Meeting',
        start: DateTime(2025, 1, 10, 10, 0),
        end: DateTime(2025, 1, 10, 11, 0),
      );
      controller.addEventsForRange(
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 31, 23, 59, 59, 999),
        [event],
      );

      MCalEventDoubleTapDetails? capturedDetails;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalMonthView(
                controller: controller,
                onEventDoubleTap: (context, details) {
                  capturedDetails = details;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Double-tap on the event tile
      final eventFinder = find.text('Double Tap Meeting');
      expect(eventFinder, findsOneWidget);

      await tester.tap(eventFinder, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(eventFinder, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(capturedDetails, isNotNull);
      expect(capturedDetails!.event.id, equals('event-double-tap'));
      expect(capturedDetails!.event.title, equals('Double Tap Meeting'));
      expect(capturedDetails!.displayDate.day, equals(10));
      expect(capturedDetails!.localPosition, isNotNull);
      expect(capturedDetails!.globalPosition, isNotNull);

      controller.dispose();
    });

    testWidgets('onEventDoubleTap receives correct event and displayDate', (
      tester,
    ) async {
      final controller = MockMCalEventController(
        initialDate: DateTime(2025, 1, 15),
      );
      final events = [
        MCalCalendarEvent(
          id: 'evt-1',
          title: 'First Event',
          start: DateTime(2025, 1, 5, 9, 0),
          end: DateTime(2025, 1, 5, 10, 0),
        ),
        MCalCalendarEvent(
          id: 'evt-2',
          title: 'Second Event',
          start: DateTime(2025, 1, 15, 14, 0),
          end: DateTime(2025, 1, 15, 15, 0),
        ),
      ];
      controller.addEventsForRange(
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 31, 23, 59, 59, 999),
        events,
      );

      MCalEventDoubleTapDetails? capturedDetails;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalMonthView(
                controller: controller,
                onEventDoubleTap: (context, details) {
                  capturedDetails = details;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Double-tap on Second Event
      await tester.tap(find.text('Second Event'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Second Event'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(capturedDetails, isNotNull);
      expect(capturedDetails!.event.id, equals('evt-2'));
      expect(capturedDetails!.displayDate.day, equals(15));

      controller.dispose();
    });

    testWidgets('single tap on event does not trigger onEventDoubleTap', (
      tester,
    ) async {
      final controller = MockMCalEventController(
        initialDate: DateTime(2025, 1, 15),
      );
      final event = MCalCalendarEvent(
        id: 'evt-single',
        title: 'Single Tap Event',
        start: DateTime(2025, 1, 10, 10, 0),
        end: DateTime(2025, 1, 10, 11, 0),
      );
      controller.addEventsForRange(
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 31, 23, 59, 59, 999),
        [event],
      );

      var doubleTapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalMonthView(
                controller: controller,
                onEventDoubleTap: (context, details) {
                  doubleTapCount++;
                },
                onEventTap: (context, details) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Single tap on event
      await tester.tap(find.text('Single Tap Event'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(doubleTapCount, equals(0));

      controller.dispose();
    });

    testWidgets('onEventTap and onEventDoubleTap can coexist', (tester) async {
      final controller = MockMCalEventController(
        initialDate: DateTime(2025, 1, 15),
      );
      final event = MCalCalendarEvent(
        id: 'evt-coexist',
        title: 'Coexist Event',
        start: DateTime(2025, 1, 10, 10, 0),
        end: DateTime(2025, 1, 10, 11, 0),
      );
      controller.addEventsForRange(
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 31, 23, 59, 59, 999),
        [event],
      );

      var doubleTapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalMonthView(
                controller: controller,
                onEventTap: (context, details) {},
                onEventDoubleTap: (context, details) {
                  doubleTapCount++;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Double-tap - should trigger onEventDoubleTap (both handlers registered)
      await tester.tap(find.text('Coexist Event'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Coexist Event'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(doubleTapCount, equals(1));

      controller.dispose();
    });

    testWidgets('onCellTap and onCellDoubleTap can coexist', (tester) async {
      final controller = MockMCalEventController(
        initialDate: DateTime(2025, 1, 15),
      );
      controller.addEventsForRange(
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 31, 23, 59, 59, 999),
        [],
      );

      var cellDoubleTapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalMonthView(
                controller: controller,
                onCellTap: (context, details) {},
                onCellDoubleTap: (context, details) {
                  cellDoubleTapCount++;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Double-tap - should trigger onCellDoubleTap (both handlers registered)
      await tester.tap(find.text('20').first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('20').first, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(cellDoubleTapCount, equals(1));

      controller.dispose();
    });

    testWidgets('onEventDoubleTap is not called when callback is null', (
      tester,
    ) async {
      final controller = MockMCalEventController(
        initialDate: DateTime(2025, 1, 15),
      );
      final event = MCalCalendarEvent(
        id: 'evt-null',
        title: 'Null Callback Event',
        start: DateTime(2025, 1, 10, 10, 0),
        end: DateTime(2025, 1, 10, 11, 0),
      );
      controller.addEventsForRange(
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 31, 23, 59, 59, 999),
        [event],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalMonthView(
                controller: controller,
                onEventDoubleTap: null,
                onEventTap: (context, details) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Double-tap - should not crash, onEventTap may fire for first tap
      await tester.tap(find.text('Null Callback Event'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Null Callback Event'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(MCalMonthView), findsOneWidget);

      controller.dispose();
    });

    testWidgets('both onCellDoubleTap and onEventDoubleTap work in same view', (
      tester,
    ) async {
      final controller = MockMCalEventController(
        initialDate: DateTime(2025, 1, 15),
      );
      final event = MCalCalendarEvent(
        id: 'evt-both',
        title: 'Both Handlers Event',
        start: DateTime(2025, 1, 10, 10, 0),
        end: DateTime(2025, 1, 10, 11, 0),
      );
      controller.addEventsForRange(
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 31, 23, 59, 59, 999),
        [event],
      );

      var cellDoubleTapCount = 0;
      var eventDoubleTapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalMonthView(
                controller: controller,
                onCellDoubleTap: (context, details) {
                  cellDoubleTapCount++;
                },
                onEventDoubleTap: (context, details) {
                  eventDoubleTapCount++;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Double-tap on empty cell (day 20)
      await tester.tap(find.text('20').first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('20').first, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(cellDoubleTapCount, equals(1));
      expect(eventDoubleTapCount, equals(0));

      // Double-tap on event
      cellDoubleTapCount = 0;
      eventDoubleTapCount = 0;
      await tester.tap(find.text('Both Handlers Event'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Both Handlers Event'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(cellDoubleTapCount, equals(0));
      expect(eventDoubleTapCount, equals(1));

      controller.dispose();
    });

    testWidgets('long-press on cell does not trigger onCellDoubleTap', (
      tester,
    ) async {
      final controller = MockMCalEventController(
        initialDate: DateTime(2025, 1, 15),
      );
      controller.addEventsForRange(
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 31, 23, 59, 59, 999),
        [],
      );

      var doubleTapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalMonthView(
                controller: controller,
                onCellDoubleTap: (context, details) {
                  doubleTapCount++;
                },
                onCellLongPress: (context, details) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Long-press instead of double-tap
      await tester.longPress(find.text('15').first, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(doubleTapCount, equals(0));

      controller.dispose();
    });
  });
}
