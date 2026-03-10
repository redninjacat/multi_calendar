import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

/// Controller with helper to set events in tests.
class _TestController extends MCalEventController {
  _TestController({required super.initialDate});

  void setEvents(List<MCalCalendarEvent> events) {
    clearEvents();
    addEvents(events);
  }
}

// ── Shared fixture ─────────────────────────────────────────────────────────────

/// Date used in all tests.
final _testDate = DateTime(2026, 2, 10);

/// Timed event at 6:00 AM — slot index 0 when startHour=6, slot duration 15 min.
MCalCalendarEvent _timedEvent({String id = 'ev-timed'}) => MCalCalendarEvent(
      id: id,
      title: 'Morning Meeting',
      start: DateTime(_testDate.year, _testDate.month, _testDate.day, 6, 0),
      end: DateTime(_testDate.year, _testDate.month, _testDate.day, 6, 30),
      color: Colors.blue,
    );

/// All-day event on the test date.
MCalCalendarEvent _allDayEvent({String id = 'ev-allday'}) => MCalCalendarEvent(
      id: id,
      title: 'All Day Event',
      start: DateTime(_testDate.year, _testDate.month, _testDate.day),
      end: DateTime(_testDate.year, _testDate.month, _testDate.day, 23, 59),
      isAllDay: true,
      color: Colors.green,
    );

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
  });

  group('MCalDayView keyboard navigation state machine', () {
    late _TestController controller;

    setUp(() {
      controller = _TestController(initialDate: _testDate);
    });

    tearDown(() {
      controller.dispose();
    });

    /// Pumps a [MCalDayView] configured for keyboard testing.
    ///
    /// Uses startHour=6, endHour=10, timeSlotDuration=15 min so that the event
    /// at 6:00 AM lands on slot index 0 (immediately reachable via ↓ from
    /// all-day section).
    Future<void> pumpCalendar(
      WidgetTester tester, {
      List<MCalCalendarEvent> events = const [],
      void Function(BuildContext, MCalEventTapDetails)? onEventTap,
      FutureOr<bool> Function(BuildContext, MCalEventTapDetails)?
          onDeleteEventRequested,
      FutureOr<bool> Function(
              BuildContext, DateTime)?
          onCreateEventRequested,
      FutureOr<bool> Function(
              BuildContext,
              MCalCalendarEvent,
              bool toAllDay,
              DateTime? suggestedStartTime)?
          onEventTypeConversionRequested,
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
                onEventTap: onEventTap,
                onDeleteEventRequested: onDeleteEventRequested,
                onCreateEventRequested: onCreateEventRequested,
                onEventTypeConversionRequested: onEventTypeConversionRequested,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    /// Taps the view to give it focus and sends [key].
    ///
    /// Tap-to-focus activates keyboard nav on an arbitrary time slot, so we
    /// normalise to a known starting state (all-day section, slot 0 as the
    /// last time-grid slot) before delivering [key].
    Future<void> sendKey(
      WidgetTester tester,
      LogicalKeyboardKey key,
    ) async {
      await tester.tap(find.byType(MCalDayView));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.home);  // → slot 0
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);  // → all-day
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();
    }

    /// Sends [key] without re-tapping (for subsequent keys in a sequence).
    Future<void> sendKeyOnly(
      WidgetTester tester,
      LogicalKeyboardKey key,
    ) async {
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();
    }

    // ── Navigation Mode ──────────────────────────────────────────────────────

    group('Navigation Mode', () {
      testWidgets('PageDown advances displayDate by one day', (tester) async {
        await pumpCalendar(tester);
        final before = controller.displayDate;
        await sendKey(tester, LogicalKeyboardKey.pageDown);
        final after = controller.displayDate;
        expect(
          after.difference(before).inDays,
          equals(1),
          reason: 'PageDown should navigate to the next day',
        );
      });

      testWidgets('PageUp moves displayDate back one day', (tester) async {
        await pumpCalendar(tester);
        final before = controller.displayDate;
        await sendKey(tester, LogicalKeyboardKey.pageUp);
        final after = controller.displayDate;
        expect(
          before.difference(after).inDays,
          equals(1),
          reason: 'PageUp should navigate to the previous day',
        );
      });

      testWidgets('N key fires onCreateEventRequested with a DateTime',
          (tester) async {
        DateTime? capturedStart;
        await pumpCalendar(
          tester,
          onCreateEventRequested: (ctx, startTime) {
            capturedStart = startTime;
            return true;
          },
        );

        // Press ArrowDown to begin navigation (activates keyboard nav), then N.
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyN);

        expect(capturedStart, isNotNull);
        expect(capturedStart, isA<DateTime>());
      });

      testWidgets(
          'N key does not fire create when onCreateEventRequested is null',
          (tester) async {
        // Should not throw if the callback is null — just absorbed.
        await pumpCalendar(tester);
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyN);
        // No exception = pass.
      });

      testWidgets('ArrowLeft and ArrowRight navigate between days in Navigation Mode',
          (tester) async {
        final before = controller.displayDate;
        await pumpCalendar(tester);
        await sendKey(tester, LogicalKeyboardKey.arrowLeft);
        await sendKeyOnly(tester, LogicalKeyboardKey.arrowRight);
        // ← then → returns to the original day (navigates back and then forward).
        expect(controller.displayDate, equals(before));
      });

      testWidgets(
          'Enter without events at slot does not enter Event Mode '
          '(onEventTap not called)', (tester) async {
        bool tapFired = false;
        await pumpCalendar(
          tester,
          // No events seeded.
          onEventTap: (ctx, details) => tapFired = true,
        );
        // Navigate to a slot with no events, then press Enter.
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        // Enter again (would activate if in Event Mode).
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        expect(tapFired, isFalse);
      });

      testWidgets(
          'Enter with timed event at slot enters Event Mode '
          '(subsequent Enter fires onEventTap)', (tester) async {
        bool tapFired = false;
        final event = _timedEvent();
        await pumpCalendar(
          tester,
          events: [event],
          onEventTap: (ctx, details) => tapFired = true,
        );
        // ↓ moves from all-day section to slot 0 (where the 6:00 AM event is).
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        // Enter → Event Mode.
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        // Enter → Activate focused event (fires onEventTap).
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        expect(tapFired, isTrue);
      });

      testWidgets('Home key does not throw', (tester) async {
        await pumpCalendar(tester);
        await sendKey(tester, LogicalKeyboardKey.home);
        // No exception = pass.
      });

      testWidgets('End key does not throw', (tester) async {
        await pumpCalendar(tester);
        await sendKey(tester, LogicalKeyboardKey.end);
        // No exception = pass.
      });

      testWidgets('A key (jumpToAllDay) does not throw', (tester) async {
        await pumpCalendar(tester);
        // Navigate to time grid first, then press A.
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyA);
        // No exception = pass.
      });

      testWidgets('T key (jumpToTimeGrid) does not throw', (tester) async {
        await pumpCalendar(tester);
        // Navigate to all-day (default), then press T.
        await sendKey(tester, LogicalKeyboardKey.keyT);
        // No exception = pass.
      });
    });

    // ── Event Mode ───────────────────────────────────────────────────────────

    group('Event Mode', () {
      testWidgets(
          'D key in Event Mode fires onDeleteEventRequested with correct event',
          (tester) async {
        MCalEventTapDetails? captured;
        final event = _timedEvent();
        await pumpCalendar(
          tester,
          events: [event],
          onDeleteEventRequested: (ctx, details) {
            captured = details;
            return true;
          },
        );
        // Enter navigation mode → slot 0 → Event Mode → delete.
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyD);

        expect(captured, isNotNull);
        expect(captured!.event.id, equals(event.id));
      });

      testWidgets(
          'Delete key in Event Mode fires onDeleteEventRequested', (tester) async {
        MCalEventTapDetails? captured;
        final event = _timedEvent();
        await pumpCalendar(
          tester,
          events: [event],
          onDeleteEventRequested: (ctx, details) {
            captured = details;
            return true;
          },
        );
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        await sendKeyOnly(tester, LogicalKeyboardKey.delete);

        expect(captured, isNotNull);
      });

      testWidgets(
          'X key on timed event fires conversion with toAllDay=true',
          (tester) async {
        bool? capturedToAllDay;
        final event = _timedEvent();
        await pumpCalendar(
          tester,
          events: [event],
          onEventTypeConversionRequested: (ctx, ev, toAllDay, suggested) {
            capturedToAllDay = toAllDay;
            return true;
          },
        );
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyX);

        expect(capturedToAllDay, isTrue,
            reason: 'Converting timed event → toAllDay should be true');
      });

      testWidgets(
          'X key on all-day event fires conversion with toAllDay=false '
          'and a non-null suggestedStartTime', (tester) async {
        bool? capturedToAllDay;
        DateTime? capturedSuggested;
        final event = _allDayEvent();
        await pumpCalendar(
          tester,
          events: [event],
          onEventTypeConversionRequested: (ctx, ev, toAllDay, suggested) {
            capturedToAllDay = toAllDay;
            capturedSuggested = suggested;
            return true;
          },
        );
        // Initial focus is on all-day section; press Enter to enter Event Mode.
        await sendKey(tester, LogicalKeyboardKey.enter);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyX);

        expect(capturedToAllDay, isFalse,
            reason: 'Converting all-day event → toAllDay should be false');
        expect(capturedSuggested, isNotNull,
            reason:
                'Converting all-day to timed should provide a suggestedStartTime');
      });

      testWidgets('Escape exits Event Mode (subsequent D does not delete)',
          (tester) async {
        int deleteCount = 0;
        final event = _timedEvent();
        await pumpCalendar(
          tester,
          events: [event],
          onDeleteEventRequested: (ctx, details) {
            deleteCount++;
            return false; // Return false so event stays
          },
        );
        // Enter Event Mode.
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        // Escape → back to Navigation Mode.
        await sendKeyOnly(tester, LogicalKeyboardKey.escape);
        // D in Navigation Mode should NOT trigger delete.
        await sendKeyOnly(tester, LogicalKeyboardKey.keyD);

        expect(deleteCount, equals(0),
            reason: 'D in Navigation Mode should not delete');
      });

      testWidgets('Tab cycles forward in Event Mode without throwing',
          (tester) async {
        final event = _timedEvent();
        await pumpCalendar(tester, events: [event]);
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        // Tab cycles to next event (only 1 event → wraps back to same).
        await sendKeyOnly(tester, LogicalKeyboardKey.tab);
        await sendKeyOnly(tester, LogicalKeyboardKey.tab);
        // No exception = pass.
      });

      testWidgets('Shift+Tab cycles backward in Event Mode without throwing',
          (tester) async {
        final event = _timedEvent();
        await pumpCalendar(tester, events: [event]);
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
        await tester.pumpAndSettle();
        // No exception = pass.
      });

      testWidgets(
          'onDeleteEventRequested returning false keeps focus in Event Mode '
          '(can still press D again)', (tester) async {
        int deleteCount = 0;
        final event = _timedEvent();
        await pumpCalendar(
          tester,
          events: [event],
          onDeleteEventRequested: (ctx, details) {
            deleteCount++;
            return false; // Deny the delete — stay in Event Mode.
          },
        );
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyD);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyD);

        expect(deleteCount, equals(2),
            reason:
                'When delete is denied (returns false), pressing D again should re-fire');
      });

      testWidgets(
          'onDeleteEventRequested returning async false stays in Event Mode',
          (tester) async {
        int deleteCount = 0;
        final event = _timedEvent();
        await pumpCalendar(
          tester,
          events: [event],
          onDeleteEventRequested: (ctx, details) async {
            deleteCount++;
            await Future<void>.delayed(Duration.zero);
            return false;
          },
        );
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyD);
        await tester.pumpAndSettle();
        await sendKeyOnly(tester, LogicalKeyboardKey.keyD);

        expect(deleteCount, equals(2));
      });
    });

    // ── Custom key bindings ──────────────────────────────────────────────────

    group('Custom key bindings', () {
      testWidgets('jumpToAllDay can be remapped to Q', (tester) async {
        const bindings = MCalDayKeyBindings(
          jumpToAllDay: [MCalKeyActivator(LogicalKeyboardKey.keyQ)],
        );
        await pumpCalendar(tester, keyBindings: bindings);
        // Q should now act as jumpToAllDay — should not throw.
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyQ);
      });

      testWidgets('createEvent can be disabled by passing empty list',
          (tester) async {
        bool createFired = false;
        const bindings = MCalDayKeyBindings(createEvent: []);
        await pumpCalendar(
          tester,
          keyBindings: bindings,
          onCreateEventRequested: (ctx, startTime) {
            createFired = true;
            return true;
          },
        );
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyN);

        expect(createFired, isFalse,
            reason: 'N should be disabled when createEvent binding is empty');
      });

      testWidgets('convertEventType can be remapped', (tester) async {
        bool convertFired = false;
        // Remap to Y — X should no longer trigger it.
        const bindings = MCalDayKeyBindings(
          convertEventType: [MCalKeyActivator(LogicalKeyboardKey.keyY)],
        );
        final event = _timedEvent();
        await pumpCalendar(
          tester,
          events: [event],
          keyBindings: bindings,
          onEventTypeConversionRequested: (ctx, ev, toAllDay, suggested) {
            convertFired = true;
            return true;
          },
        );
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        // X should NOT fire (it's been remapped).
        await sendKeyOnly(tester, LogicalKeyboardKey.keyX);
        expect(convertFired, isFalse);
        // Y should fire.
        await sendKeyOnly(tester, LogicalKeyboardKey.keyY);
        expect(convertFired, isTrue);
      });
    });
  });
}
