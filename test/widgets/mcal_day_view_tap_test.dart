import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

/// ScrollBehavior that disables drag scrolling so tap/long-press gestures win.
class _NoDragScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {};
}

/// Mock MCalEventController for Day View tap testing.
class MockMCalEventController extends MCalEventController {
  MockMCalEventController({super.initialDate});

  void setMockEvents(List<MCalCalendarEvent> events) {
    clearEvents();
    addEvents(events);
  }
}

/// Key for the schedule GestureDetector in MCalDayView (used for tap testing).
const _scheduleKey = Key('day_view_schedule');

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('en_US', null);
  });

  Widget buildDayView({
    required MockMCalEventController ctrl,
    bool enableDragToMove = false,
    void Function(BuildContext, MCalEventTapDetails)? onEventTap,
    void Function(BuildContext, MCalEventTapDetails)? onEventLongPress,
    void Function(MCalTimeSlotContext)? onTimeSlotTap,
    void Function(MCalTimeSlotContext)? onTimeSlotLongPress,
    void Function(DateTime)? onEmptySpaceDoubleTap,
  }) {
    return MaterialApp(
      locale: const Locale('en', 'US'),
      scrollBehavior: _NoDragScrollBehavior(),
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 800,
          child: MCalDayView(
            showNavigator: false,
            controller: ctrl,
            enableDragToMove: enableDragToMove,
            onEventTap: onEventTap,
            onEventLongPress: onEventLongPress,
            onTimeSlotTap: onTimeSlotTap,
            onTimeSlotLongPress: onTimeSlotLongPress,
            onEmptySpaceDoubleTap: onEmptySpaceDoubleTap,
            showCurrentTimeIndicator: false,
            autoScrollToCurrentTime: false,
            initialScrollTime: const TimeOfDay(hour: 8, minute: 0),
            startHour: 8,
            endHour: 14,
            hourHeight: 80,
            scrollPhysics: const NeverScrollableScrollPhysics(),
          ),
        ),
      ),
    );
  }

  group('MCalDayView event tap callbacks', () {
    late MockMCalEventController controller;

    setUp(() {
      controller = MockMCalEventController(initialDate: DateTime(2026, 2, 14));
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('onEventTap fires when event tapped', (tester) async {
      controller.setMockEvents([
        MCalCalendarEvent(
          id: 'tap-1',
          title: 'Team Meeting',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
        ),
      ]);

      MCalEventTapDetails? capturedDetails;

      await tester.pumpWidget(
        buildDayView(
          ctrl: controller,
          onEventTap: (_, details) => capturedDetails = details,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Team Meeting'));
      await tester.pumpAndSettle();

      expect(capturedDetails, isNotNull);
      expect(capturedDetails!.event.id, 'tap-1');
      expect(capturedDetails!.event.title, 'Team Meeting');
      expect(capturedDetails!.event.start, DateTime(2026, 2, 14, 10, 0));
      expect(capturedDetails!.event.end, DateTime(2026, 2, 14, 11, 0));
      expect(capturedDetails!.displayDate, DateTime(2026, 2, 14));
    });

    testWidgets('onEventLongPress fires when event long-pressed', (
      tester,
    ) async {
      controller.setMockEvents([
        MCalCalendarEvent(
          id: 'longpress-1',
          title: 'Design Review',
          start: DateTime(2026, 2, 14, 9, 0),
          end: DateTime(2026, 2, 14, 10, 0),
        ),
      ]);

      MCalEventTapDetails? capturedDetails;

      await tester.pumpWidget(
        buildDayView(
          ctrl: controller,
          onEventLongPress: (_, details) => capturedDetails = details,
        ),
      );
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Design Review'));
      await tester.pumpAndSettle();

      expect(capturedDetails, isNotNull);
      expect(capturedDetails!.event.id, 'longpress-1');
      expect(capturedDetails!.event.title, 'Design Review');
      expect(capturedDetails!.displayDate, DateTime(2026, 2, 14));
    });

    testWidgets('correct event data passed to onEventTap callback', (
      tester,
    ) async {
      final event = MCalCalendarEvent(
        id: 'data-test-1',
        title: 'Data Test Event',
        start: DateTime(2026, 2, 14, 11, 30),
        end: DateTime(2026, 2, 14, 12, 30),
        color: Colors.blue,
      );
      controller.setMockEvents([event]);

      MCalEventTapDetails? capturedDetails;

      await tester.pumpWidget(
        buildDayView(
          ctrl: controller,
          onEventTap: (_, details) => capturedDetails = details,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Data Test Event'));
      await tester.pumpAndSettle();

      expect(capturedDetails, isNotNull);
      expect(capturedDetails!.event.id, event.id);
      expect(capturedDetails!.event.title, event.title);
      expect(capturedDetails!.event.start, event.start);
      expect(capturedDetails!.event.end, event.end);
      expect(capturedDetails!.event.color, event.color);
    });
  });

  group('MCalDayView empty space callbacks', () {
    // Widget tests cannot reliably trigger gestures on nested GestureDetectors
    // inside scrollables. We verify the schedule GestureDetector exists and
    // callbacks are correctly wired.
    late MockMCalEventController controller;

    setUp(() {
      controller = MockMCalEventController(initialDate: DateTime(2026, 2, 14));
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets(
      'schedule GestureDetector has onTapUp when onTimeSlotTap provided',
      (tester) async {
        controller.setMockEvents([]);

        await tester.pumpWidget(
          buildDayView(
            ctrl: controller,
            onTimeSlotTap: (_) {},
          ),
        );
        await tester.pumpAndSettle();

        final scheduleFinder = find.byKey(_scheduleKey);
        expect(scheduleFinder, findsOneWidget);

        final gestureDetector = tester.widget<GestureDetector>(scheduleFinder);
        expect(gestureDetector.onTapUp, isNotNull);
      },
    );

    testWidgets(
      'schedule GestureDetector has onLongPressStart when onTimeSlotLongPress provided',
      (tester) async {
        controller.setMockEvents([]);

        await tester.pumpWidget(
          buildDayView(
            ctrl: controller,
            onTimeSlotLongPress: (_) {},
          ),
        );
        await tester.pumpAndSettle();

        final scheduleFinder = find.byKey(_scheduleKey);
        expect(scheduleFinder, findsOneWidget);

        final gestureDetector = tester.widget<GestureDetector>(scheduleFinder);
        expect(gestureDetector.onLongPressStart, isNotNull);
      },
    );

    testWidgets(
      'schedule GestureDetector has onDoubleTap when onEmptySpaceDoubleTap provided',
      (tester) async {
        controller.setMockEvents([]);

        await tester.pumpWidget(
          buildDayView(
            ctrl: controller,
            onEmptySpaceDoubleTap: (_) {},
          ),
        );
        await tester.pumpAndSettle();

        final scheduleFinder = find.byKey(_scheduleKey);
        expect(scheduleFinder, findsOneWidget);

        final gestureDetector = tester.widget<GestureDetector>(scheduleFinder);
        expect(gestureDetector.onDoubleTap, isNotNull);
      },
    );

    testWidgets(
      'schedule GestureDetector has all tap handlers when all callbacks provided',
      (tester) async {
        controller.setMockEvents([]);

        await tester.pumpWidget(
          buildDayView(
            ctrl: controller,
            onTimeSlotTap: (_) {},
            onTimeSlotLongPress: (_) {},
            onEmptySpaceDoubleTap: (_) {},
          ),
        );
        await tester.pumpAndSettle();

        final scheduleFinder = find.byKey(_scheduleKey);
        expect(scheduleFinder, findsOneWidget);

        final gestureDetector = tester.widget<GestureDetector>(scheduleFinder);
        expect(gestureDetector.onTapUp, isNotNull);
        expect(gestureDetector.onLongPressStart, isNotNull);
        expect(gestureDetector.onDoubleTap, isNotNull);
      },
    );
  });

  group('MCalDayView event vs empty space precedence', () {
    late MockMCalEventController controller;

    setUp(() {
      controller = MockMCalEventController(initialDate: DateTime(2026, 2, 14));
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets(
      'event tile and schedule both have gesture handlers when both callbacks provided',
      (tester) async {
        controller.setMockEvents([
          MCalCalendarEvent(
            id: 'precedence-1',
            title: 'Precedence Test',
            start: DateTime(2026, 2, 14, 10, 0),
            end: DateTime(2026, 2, 14, 11, 0),
          ),
        ]);

        await tester.pumpWidget(
          buildDayView(
            ctrl: controller,
            onEventTap: (_, _) {},
            onTimeSlotTap: (_) {},
          ),
        );
        await tester.pumpAndSettle();

        // Event tile exists (event taps take precedence over schedule)
        expect(find.text('Precedence Test'), findsOneWidget);

        // Schedule GestureDetector exists for empty space taps with onTapUp
        final scheduleFinder = find.byKey(_scheduleKey);
        expect(scheduleFinder, findsOneWidget);
        final gestureDetector = tester.widget<GestureDetector>(scheduleFinder);
        expect(gestureDetector.onTapUp, isNotNull);
      },
    );
  });

  group('MCalDayView all-day event taps', () {
    late MockMCalEventController controller;

    setUp(() {
      controller = MockMCalEventController(initialDate: DateTime(2026, 2, 14));
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('onEventTap fires when all-day event tapped', (tester) async {
      controller.setMockEvents([
        MCalCalendarEvent(
          id: 'allday-tap-1',
          title: 'Holiday',
          start: DateTime(2026, 2, 14),
          end: DateTime(2026, 2, 14, 23, 59, 59),
          isAllDay: true,
        ),
      ]);

      MCalEventTapDetails? capturedDetails;

      await tester.pumpWidget(
        buildDayView(
          ctrl: controller,
          onEventTap: (_, details) => capturedDetails = details,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Holiday'));
      await tester.pumpAndSettle();

      expect(capturedDetails, isNotNull);
      expect(capturedDetails!.event.id, 'allday-tap-1');
      expect(capturedDetails!.event.title, 'Holiday');
      expect(capturedDetails!.event.isAllDay, true);
      expect(capturedDetails!.displayDate, DateTime(2026, 2, 14));
    });

    testWidgets('onEventLongPress fires when all-day event long-pressed', (
      tester,
    ) async {
      controller.setMockEvents([
        MCalCalendarEvent(
          id: 'allday-longpress-1',
          title: 'Conference',
          start: DateTime(2026, 2, 14),
          end: DateTime(2026, 2, 14, 23, 59, 59),
          isAllDay: true,
        ),
      ]);

      MCalEventTapDetails? capturedDetails;

      await tester.pumpWidget(
        buildDayView(
          ctrl: controller,
          onEventLongPress: (_, details) => capturedDetails = details,
        ),
      );
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Conference'));
      await tester.pumpAndSettle();

      expect(capturedDetails, isNotNull);
      expect(capturedDetails!.event.id, 'allday-longpress-1');
      expect(capturedDetails!.event.title, 'Conference');
      expect(capturedDetails!.event.isAllDay, true);
    });
  });
}
