import 'dart:async';

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

MCalCalendarEvent _timedEvent({String id = 'ev-timed'}) => MCalCalendarEvent(
      id: id,
      title: 'Morning Meeting',
      start: DateTime(_testDate.year, _testDate.month, _testDate.day, 6, 0),
      end: DateTime(_testDate.year, _testDate.month, _testDate.day, 6, 30),
      color: Colors.blue,
    );

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

  group('MCalDayView keyboard accessibility announcements', () {
    late _TestController controller;
    late List<String> announcements;

    setUp(() {
      controller = _TestController(initialDate: _testDate);
      announcements = [];
      MCalDayView.debugAnnouncementLog = announcements;
    });

    tearDown(() {
      MCalDayView.debugAnnouncementLog = null;
      controller.dispose();
    });

    Future<void> pumpCalendar(
      WidgetTester tester, {
      List<MCalCalendarEvent> events = const [],
      FutureOr<bool> Function(BuildContext, MCalEventTapDetails)?
          onDeleteEventRequested,
      FutureOr<bool> Function(BuildContext, MCalCalendarEvent, bool,
              DateTime? suggestedStartTime)?
          onEventTypeConversionRequested,
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
                onDeleteEventRequested:
                    onDeleteEventRequested ?? (ctx, details) => true,
                onEventTypeConversionRequested:
                    onEventTypeConversionRequested,
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

    // ── Navigation Mode announcements ────────────────────────────────────────

    group('Navigation Mode', () {
      testWidgets(
          'pressing ↑ from slot 0 announces all-day section transition',
          (tester) async {
        await pumpCalendar(tester);
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        announcements.clear();
        await sendKeyOnly(tester, LogicalKeyboardKey.arrowUp);
        expect(
          announcements.any((a) =>
              a.toLowerCase().contains('all-day') ||
              a.toLowerCase().contains('all day')),
          isTrue,
          reason:
              'Should announce transition to all-day section. Got: $announcements',
        );
      });

      testWidgets(
          'pressing ↓ from all-day section announces time grid transition',
          (tester) async {
        await pumpCalendar(tester);
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.arrowUp);
        announcements.clear();
        await sendKeyOnly(tester, LogicalKeyboardKey.arrowDown);
        expect(
          announcements.any((a) => a.toLowerCase().contains('time')),
          isTrue,
          reason:
              'Should announce transition back to time grid. Got: $announcements',
        );
      });

      testWidgets('A key announces all-day section', (tester) async {
        await pumpCalendar(tester);
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        announcements.clear();
        await sendKeyOnly(tester, LogicalKeyboardKey.keyA);
        expect(
          announcements.any((a) =>
              a.toLowerCase().contains('all-day') ||
              a.toLowerCase().contains('all day')),
          isTrue,
          reason: 'A key should announce all-day section. Got: $announcements',
        );
      });

      testWidgets('T key announces time grid', (tester) async {
        await pumpCalendar(tester);
        announcements.clear();
        await sendKey(tester, LogicalKeyboardKey.keyT);
        expect(
          announcements.any((a) => a.toLowerCase().contains('time')),
          isTrue,
          reason: 'T key should announce time grid. Got: $announcements',
        );
      });
    });

    // ── Event Mode announcements ──────────────────────────────────────────────

    group('Event Mode', () {
      testWidgets('entering Event Mode announces event count', (tester) async {
        final event = _timedEvent();
        await pumpCalendar(tester, events: [event]);
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        announcements.clear();
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        expect(
          announcements.any((a) => a.toLowerCase().contains('event')),
          isTrue,
          reason:
              'Entering Event Mode should announce event info. Got: $announcements',
        );
      });

      testWidgets(
          'pressing Escape from Event Mode announces Navigation Mode',
          (tester) async {
        final event = _timedEvent();
        await pumpCalendar(tester, events: [event]);
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        announcements.clear();
        await sendKeyOnly(tester, LogicalKeyboardKey.escape);
        expect(
          announcements.any((a) => a.toLowerCase().contains('navigation')),
          isTrue,
          reason:
              'Escape from Event Mode should announce Navigation Mode. Got: $announcements',
        );
      });

      testWidgets('D key in Event Mode announces deletion', (tester) async {
        final event = _timedEvent();
        await pumpCalendar(tester, events: [event]);
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        announcements.clear();
        await sendKeyOnly(tester, LogicalKeyboardKey.keyD);
        expect(
          announcements.any((a) =>
              a.toLowerCase().contains('deleted') ||
              a.toLowerCase().contains('morning meeting')),
          isTrue,
          reason: 'D key should announce deletion. Got: $announcements',
        );
      });

      testWidgets('M key in Event Mode announces Move Mode', (tester) async {
        final event = _timedEvent();
        await pumpCalendar(tester, events: [event]);
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        announcements.clear();
        await sendKeyOnly(tester, LogicalKeyboardKey.keyM);
        expect(
          announcements.any((a) => a.toLowerCase().contains('move')),
          isTrue,
          reason:
              'M key should announce Move Mode. Got: $announcements',
        );
      });

      testWidgets('R key in Event Mode announces Resize Mode', (tester) async {
        final event = _timedEvent();
        await pumpCalendar(tester, events: [event]);
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        announcements.clear();
        await sendKeyOnly(tester, LogicalKeyboardKey.keyR);
        expect(
          announcements.any((a) => a.toLowerCase().contains('resize')),
          isTrue,
          reason:
              'R key should announce Resize Mode. Got: $announcements',
        );
      });

      testWidgets(
          'X key in Event Mode announces conversion request',
          (tester) async {
        final event = _timedEvent();
        await pumpCalendar(
          tester,
          events: [event],
          onEventTypeConversionRequested: (ctx, ev, toAllDay, start) => true,
        );
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        announcements.clear();
        await sendKeyOnly(tester, LogicalKeyboardKey.keyX);
        expect(
          announcements.any((a) =>
              a.toLowerCase().contains('convert') ||
              a.toLowerCase().contains('morning meeting')),
          isTrue,
          reason:
              'X key should announce conversion. Got: $announcements',
        );
      });
    });

    // ── Move Mode announcements ───────────────────────────────────────────────

    group('Move Mode', () {
      testWidgets('Escape from Move Mode announces cancellation',
          (tester) async {
        final event = _timedEvent();
        await pumpCalendar(tester, events: [event]);
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyM);
        announcements.clear();
        await sendKeyOnly(tester, LogicalKeyboardKey.escape);
        expect(
          announcements.any((a) =>
              a.toLowerCase().contains('cancel') ||
              a.toLowerCase().contains('cancelled')),
          isTrue,
          reason:
              'Escape from Move Mode should announce cancellation. Got: $announcements',
        );
      });
    });

    // ── Resize Mode announcements ─────────────────────────────────────────────

    group('Resize Mode', () {
      testWidgets('Escape from Resize Mode announces cancellation',
          (tester) async {
        final event = _timedEvent();
        await pumpCalendar(tester, events: [event]);
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyR);
        announcements.clear();
        await sendKeyOnly(tester, LogicalKeyboardKey.escape);
        expect(
          announcements.any((a) =>
              a.toLowerCase().contains('cancel') ||
              a.toLowerCase().contains('cancelled') ||
              a.toLowerCase().contains('resize')),
          isTrue,
          reason:
              'Escape from Resize Mode should announce cancellation. Got: $announcements',
        );
      });

      testWidgets('S key announces start edge switch', (tester) async {
        final event = _timedEvent();
        await pumpCalendar(tester, events: [event]);
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyR);
        announcements.clear();
        await sendKeyOnly(tester, LogicalKeyboardKey.keyS);
        expect(
          announcements.any((a) => a.toLowerCase().contains('start')),
          isTrue,
          reason: 'S key should announce start edge. Got: $announcements',
        );
      });

      testWidgets('E key announces end edge switch', (tester) async {
        final event = _timedEvent();
        await pumpCalendar(tester, events: [event]);
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyR);
        announcements.clear();
        await sendKeyOnly(tester, LogicalKeyboardKey.keyE);
        expect(
          announcements.any((a) => a.toLowerCase().contains('end')),
          isTrue,
          reason: 'E key should announce end edge. Got: $announcements',
        );
      });

      testWidgets(
          'M key in Resize Mode announces switch to Move Mode',
          (tester) async {
        final event = _timedEvent();
        await pumpCalendar(tester, events: [event]);
        await sendKey(tester, LogicalKeyboardKey.arrowDown);
        await sendKeyOnly(tester, LogicalKeyboardKey.enter);
        await sendKeyOnly(tester, LogicalKeyboardKey.keyR);
        announcements.clear();
        await sendKeyOnly(tester, LogicalKeyboardKey.keyM);
        expect(
          announcements.any((a) => a.toLowerCase().contains('move')),
          isTrue,
          reason:
              'M key in Resize Mode should announce Move Mode. Got: $announcements',
        );
      });
    });

    // ── All-day event announcements ───────────────────────────────────────────

    group('All-day Event Mode', () {
      testWidgets(
          'entering Event Mode from all-day section with events announces',
          (tester) async {
        final event = _allDayEvent();
        await pumpCalendar(tester, events: [event]);
        announcements.clear();
        await sendKey(tester, LogicalKeyboardKey.enter);
        expect(
          announcements.any((a) =>
              a.toLowerCase().contains('event') ||
              a.toLowerCase().contains('all day')),
          isTrue,
          reason:
              'Entering Event Mode from all-day should announce event info. Got: $announcements',
        );
      });
    });
  });
}
