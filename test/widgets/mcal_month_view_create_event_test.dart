import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

class _TestController extends MCalEventController {
  _TestController({super.initialDate});

  void setEvents(List<MCalCalendarEvent> events) {
    clearEvents();
    addEvents(events);
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
  });

  group('MCalMonthView — Navigation Mode create event (Requirement 8)', () {
    late _TestController controller;

    setUp(() {
      controller = _TestController(initialDate: DateTime(2025, 3, 1));
    });

    tearDown(() {
      controller.dispose();
    });

    /// Pumps a month view focused on 2025-03-15 with the given callbacks.
    Future<void> pumpCalendar(
      WidgetTester tester, {
      FutureOr<bool> Function(BuildContext, DateTime)? onCreateEventRequested,
      MCalMonthKeyBindings? keyBindings,
    }) async {
      controller.setFocusedDateTime(DateTime(2025, 3, 15), isAllDay: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              width: 400,
              child: MCalMonthView(
                controller: controller,
                enableKeyboardNavigation: true,
                enableDragToMove: true,
                keyBindings: keyBindings,
                onCreateEventRequested: onCreateEventRequested,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    /// Focuses the calendar and sends [key], restoring focused date afterward.
    Future<void> focusAndSendKey(
      WidgetTester tester,
      LogicalKeyboardKey key,
    ) async {
      final savedDate = controller.focusedDateTime;
      await tester.tap(find.byType(MCalMonthView));
      await tester.pumpAndSettle();
      controller.setFocusedDateTime(savedDate, isAllDay: true);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();
    }

    testWidgets('N key fires onCreateEventRequested with focused date', (
      tester,
    ) async {
      BuildContext? receivedContext;
      DateTime? receivedDate;

      await pumpCalendar(
        tester,
        onCreateEventRequested: (ctx, date) {
          receivedContext = ctx;
          receivedDate = date;
          return true;
        },
      );

      await focusAndSendKey(tester, LogicalKeyboardKey.keyN);

      expect(receivedContext, isNotNull, reason: 'Callback should receive a BuildContext');
      expect(receivedDate, equals(DateTime(2025, 3, 15)),
          reason: 'Callback should receive the focused date');
    });

    testWidgets('N key is absorbed when onCreateEventRequested is null', (
      tester,
    ) async {
      await pumpCalendar(tester);

      // Should not throw — key is silently absorbed.
      await focusAndSendKey(tester, LogicalKeyboardKey.keyN);
      // If we reach here without exception the key was absorbed cleanly.
      expect(true, isTrue);
    });

    testWidgets('async onCreateEventRequested (Future<bool>) is awaited without error', (
      tester,
    ) async {
      final completer = Completer<bool>();
      bool callbackFired = false;

      await pumpCalendar(
        tester,
        onCreateEventRequested: (ctx, date) {
          callbackFired = true;
          return completer.future;
        },
      );

      await focusAndSendKey(tester, LogicalKeyboardKey.keyN);

      expect(callbackFired, isTrue, reason: 'Async callback should fire');

      // Complete the future — no errors should occur.
      completer.complete(true);
      await tester.pumpAndSettle();
    });

    testWidgets('N key can be remapped via MCalMonthKeyBindings.createEvent', (
      tester,
    ) async {
      DateTime? receivedDate;

      await pumpCalendar(
        tester,
        keyBindings: const MCalMonthKeyBindings(
          createEvent: [MCalKeyActivator(LogicalKeyboardKey.keyC)],
        ),
        onCreateEventRequested: (ctx, date) {
          receivedDate = date;
          return true;
        },
      );

      // Default N should NOT fire (remapped).
      await focusAndSendKey(tester, LogicalKeyboardKey.keyN);
      expect(receivedDate, isNull,
          reason: 'Default N should not fire when remapped to C');

      // Custom C SHOULD fire.
      await focusAndSendKey(tester, LogicalKeyboardKey.keyC);
      expect(receivedDate, equals(DateTime(2025, 3, 15)),
          reason: 'Remapped C key should fire onCreateEventRequested');
    });

    testWidgets('createEvent binding can be disabled via empty list', (
      tester,
    ) async {
      bool callbackFired = false;

      await pumpCalendar(
        tester,
        keyBindings: const MCalMonthKeyBindings(createEvent: []),
        onCreateEventRequested: (ctx, date) {
          callbackFired = true;
          return true;
        },
      );

      await focusAndSendKey(tester, LogicalKeyboardKey.keyN);

      expect(callbackFired, isFalse,
          reason: 'Disabled createEvent binding should not fire the callback');
    });

    testWidgets('N key does NOT fire onCreateEventRequested when in Event Mode', (
      tester,
    ) async {
      bool callbackFired = false;

      final event = MCalCalendarEvent(
        id: 'ev-1',
        title: 'March Event',
        start: DateTime(2025, 3, 15, 10),
        end: DateTime(2025, 3, 15, 11),
        color: Colors.blue,
      );
      controller.setEvents([event]);

      await pumpCalendar(
        tester,
        onCreateEventRequested: (ctx, date) {
          callbackFired = true;
          return true;
        },
      );

      // Enter Event Mode via Enter key.
      await focusAndSendKey(tester, LogicalKeyboardKey.enter);

      // Now press N — should be captured by Event Mode, not Navigation Mode.
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.pumpAndSettle();

      expect(callbackFired, isFalse,
          reason: 'N in Event Mode should not trigger onCreateEventRequested');
    });

    testWidgets('null keyBindings falls back to default N binding', (
      tester,
    ) async {
      DateTime? receivedDate;

      await pumpCalendar(
        tester,
        onCreateEventRequested: (ctx, date) {
          receivedDate = date;
          return true;
        },
      );

      await focusAndSendKey(tester, LogicalKeyboardKey.keyN);

      expect(receivedDate, isNotNull,
          reason: 'Default N binding should work when keyBindings is null');
    });
  });
}
