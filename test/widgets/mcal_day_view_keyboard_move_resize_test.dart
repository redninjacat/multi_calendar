import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

class _TestController extends MCalEventController {
  _TestController({required super.initialDate});

  void setEvents(List<MCalCalendarEvent> events) {
    clearEvents();
    addEvents(events);
  }
}

final _testDate = DateTime(2026, 2, 10);

/// Timed event at 6:00 AM — slot index 0 when startHour=6, slot duration 15 min.
MCalCalendarEvent _timedEvent({String id = 'ev-timed'}) => MCalCalendarEvent(
      id: id,
      title: 'Morning Meeting',
      start: DateTime(_testDate.year, _testDate.month, _testDate.day, 6, 0),
      end: DateTime(_testDate.year, _testDate.month, _testDate.day, 6, 30),
      color: Colors.blue,
    );

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
  });

  group('MCalDayView Move and Resize Mode', () {
    late _TestController controller;

    setUp(() {
      controller = _TestController(initialDate: _testDate);
    });

    tearDown(() {
      controller.dispose();
    });

    /// Pumps a [MCalDayView] configured for move/resize keyboard testing.
    Future<void> pumpCalendar(
      WidgetTester tester, {
      List<MCalCalendarEvent> events = const [],
      bool Function(BuildContext, MCalEventDroppedDetails)? onEventDropped,
      bool Function(BuildContext, MCalEventResizedDetails)? onEventResized,
      MCalDayKeyBindings? keyBindings,
    }) async {
      controller.setEvents(events);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: MCalDayView(
                controller: controller,
                startHour: 6,
                endHour: 10,
                timeSlotDuration: const Duration(minutes: 15),
                showNavigator: false,
                showCurrentTimeIndicator: false,
                autoScrollToCurrentTime: false,
                enableKeyboardNavigation: true,
                enableDragToMove: true,
                enableDragToResize: true,
                keyBindings: keyBindings,
                onEventDropped: onEventDropped,
                onEventResized: onEventResized,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> sendKey(
      WidgetTester tester,
      LogicalKeyboardKey key,
    ) async {
      await tester.tap(find.byType(MCalDayView));
      await tester.pumpAndSettle();
      // Normalise to all-day section (slot 0 as last grid slot) so subsequent
      // keys start from the same state regardless of where tap-to-focus landed.
      await tester.sendKeyEvent(LogicalKeyboardKey.home);  // → slot 0
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);  // → all-day
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();
    }

    Future<void> sendKeyOnly(
      WidgetTester tester,
      LogicalKeyboardKey key,
    ) async {
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();
    }

    // ── Move Mode ────────────────────────────────────────────────────────────

    group('Move Mode', () {
      testWidgets(
          'M key in Event Mode enters Move Mode and '
          'Escape cancels returning to Event Mode '
          '(subsequent D fires onDeleteEventRequested)', (tester) async {
        // We verify return to Event Mode by checking that D fires delete.
        int deleteCount = 0;
        final event = _timedEvent();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 600,
                child: MCalDayView(
                  controller: controller..setEvents([event]),
                  startHour: 6,
                  endHour: 10,
                  timeSlotDuration: const Duration(minutes: 15),
                  showNavigator: false,
                  showCurrentTimeIndicator: false,
                  autoScrollToCurrentTime: false,
                  enableKeyboardNavigation: true,
                  enableDragToMove: true,
                  enableDragToResize: true,
                  onDeleteEventRequested: (ctx, details) {
                    deleteCount++;
                    return false; // keep in Event Mode
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate: ↓ → slot 0 → Enter Event Mode → M → Move Mode.
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyM);
        // Escape → back to Event Mode.
        await sendKeyOnly(tester, LogicalKeyboardKey.escape);
        // D in Event Mode should fire delete.
        await sendKeyOnly(tester, LogicalKeyboardKey.keyD);
        expect(deleteCount, equals(1),
            reason: 'After cancelling Move Mode, should return to Event Mode');
      });

      testWidgets(
          'ArrowDown in Move Mode moves event down one slot '
          'and Enter confirms (fires onEventDropped)', (tester) async {
        MCalEventDroppedDetails? droppedDetails;
        final event = _timedEvent();
        await pumpCalendar(
          tester,
          events: [event],
          onEventDropped: (ctx, details) {
            droppedDetails = details;
            return true;
          },
        );

        // Enter Move Mode.
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyM);
        // Move down one slot (15 min).
        await sendKeyOnly(tester, LogicalKeyboardKey.arrowDown);
        // Confirm move.
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);

        expect(droppedDetails, isNotNull,
            reason: 'Confirming move should fire onEventDropped');
        // New start should be one slot later (6:15 AM).
        expect(
          droppedDetails!.newStartDate.hour * 60 +
              droppedDetails!.newStartDate.minute,
          greaterThan(event.start.hour * 60 + event.start.minute),
          reason: 'Event should have moved forward in time',
        );
      });

      testWidgets(
          'R key in Move Mode transitions to Resize Mode '
          '(subsequent Escape cancels resize and returns to Event Mode)',
          (tester) async {
        int deleteCount = 0;
        final event = _timedEvent();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 600,
                child: MCalDayView(
                  controller: controller..setEvents([event]),
                  startHour: 6,
                  endHour: 10,
                  timeSlotDuration: const Duration(minutes: 15),
                  showNavigator: false,
                  showCurrentTimeIndicator: false,
                  autoScrollToCurrentTime: false,
                  enableKeyboardNavigation: true,
                  enableDragToMove: true,
                  enableDragToResize: true,
                  onDeleteEventRequested: (ctx, details) {
                    deleteCount++;
                    return false;
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Enter Move Mode.
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyM);
        // R → Resize Mode.
        await sendKeyOnly(tester, LogicalKeyboardKey.keyR);
        // Escape → Event Mode.
        await sendKeyOnly(tester, LogicalKeyboardKey.escape);
        // D should fire in Event Mode.
        await sendKeyOnly(tester, LogicalKeyboardKey.keyD);
        expect(deleteCount, equals(1));
      });
    });

    // ── Resize Mode ──────────────────────────────────────────────────────────

    group('Resize Mode', () {
      testWidgets(
          'R key in Event Mode enters Resize Mode and '
          'Escape cancels returning to Event Mode', (tester) async {
        int deleteCount = 0;
        final event = _timedEvent();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 600,
                child: MCalDayView(
                  controller: controller..setEvents([event]),
                  startHour: 6,
                  endHour: 10,
                  timeSlotDuration: const Duration(minutes: 15),
                  showNavigator: false,
                  showCurrentTimeIndicator: false,
                  autoScrollToCurrentTime: false,
                  enableKeyboardNavigation: true,
                  enableDragToMove: true,
                  enableDragToResize: true,
                  onDeleteEventRequested: (ctx, details) {
                    deleteCount++;
                    return false;
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Enter Resize Mode.
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyR);
        // Escape → Event Mode.
        await sendKeyOnly(tester, LogicalKeyboardKey.escape);
        // D should fire.
        await sendKeyOnly(tester, LogicalKeyboardKey.keyD);
        expect(deleteCount, equals(1));
      });

      testWidgets(
          'ArrowDown in Resize Mode extends end edge and '
          'Enter confirms (fires onEventResized)', (tester) async {
        MCalEventResizedDetails? resizedDetails;
        final event = _timedEvent();
        await pumpCalendar(
          tester,
          events: [event],
          onEventResized: (ctx, details) {
            resizedDetails = details;
            return true;
          },
        );

        // Enter Resize Mode.
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyR);
        // ArrowDown extends end edge one slot.
        await sendKeyOnly(tester, LogicalKeyboardKey.arrowDown);
        // Confirm.
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);

        expect(resizedDetails, isNotNull,
            reason: 'Confirming resize should fire onEventResized');
        // New end should be later than original.
        expect(
          resizedDetails!.newEndDate.isAfter(event.end),
          isTrue,
          reason: 'Event end should have extended',
        );
      });

      testWidgets(
          'M key in Resize Mode transitions to Move Mode '
          '(subsequent Escape cancels move and returns to Event Mode)',
          (tester) async {
        int deleteCount = 0;
        final event = _timedEvent();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 600,
                child: MCalDayView(
                  controller: controller..setEvents([event]),
                  startHour: 6,
                  endHour: 10,
                  timeSlotDuration: const Duration(minutes: 15),
                  showNavigator: false,
                  showCurrentTimeIndicator: false,
                  autoScrollToCurrentTime: false,
                  enableKeyboardNavigation: true,
                  enableDragToMove: true,
                  enableDragToResize: true,
                  onDeleteEventRequested: (ctx, details) {
                    deleteCount++;
                    return false;
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Enter Resize Mode.
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyR);
        // M → Move Mode.
        await sendKeyOnly(tester, LogicalKeyboardKey.keyM);
        // Escape → Event Mode.
        await sendKeyOnly(tester, LogicalKeyboardKey.escape);
        // D fires.
        await sendKeyOnly(tester, LogicalKeyboardKey.keyD);
        expect(deleteCount, equals(1));
      });

      testWidgets('S/E switch edge in Resize Mode without throwing',
          (tester) async {
        final event = _timedEvent();
        await pumpCalendar(tester, events: [event]);
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyR);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyS);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyE);
        await sendKeyOnly(tester, LogicalKeyboardKey.escape);
        // No exception = pass.
      });
    });

    // ── Legacy removal ───────────────────────────────────────────────────────

    group('Legacy removal', () {
      testWidgets(
          'MCalDayView can be constructed without keyboardShortcuts '
          'and without onEditEventRequested', (tester) async {
        // This test verifies the legacy parameters were removed. The fact that
        // the code compiles without them is the primary check. We just need
        // to pump the widget to confirm it works with the current API.
        await pumpCalendar(tester);
        expect(find.byType(MCalDayView), findsOneWidget);
      });

      testWidgets('keyBindings parameter is accepted and applied',
          (tester) async {
        bool createFired = false;
        const customBindings = MCalDayKeyBindings(
          createEvent: [MCalKeyActivator(LogicalKeyboardKey.keyC)],
        );
        final event = _timedEvent();
        controller.setEvents([event]);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 600,
                child: MCalDayView(
                  controller: controller,
                  startHour: 6,
                  endHour: 10,
                  timeSlotDuration: const Duration(minutes: 15),
                  showNavigator: false,
                  showCurrentTimeIndicator: false,
                  autoScrollToCurrentTime: false,
                  enableKeyboardNavigation: true,
                  enableDragToMove: true,
                  keyBindings: customBindings,
                  onCreateEventRequested: (ctx, startTime) {
                    createFired = true;
                    return true;
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        // N should not fire (remapped to C).
        await sendKeyOnly(tester, LogicalKeyboardKey.keyN);
        expect(createFired, isFalse);
        // C should fire.
        await sendKeyOnly(tester, LogicalKeyboardKey.keyC);
        expect(createFired, isTrue);
      });
    });
  });
}
