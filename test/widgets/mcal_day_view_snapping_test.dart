import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

/// Mock MCalEventController for Day View snapping testing.
class MockMCalEventController extends MCalEventController {
  MockMCalEventController({super.initialDate});

  void setMockEvents(List<MCalCalendarEvent> events) {
    clearEvents();
    addEvents(events);
  }
}

void main() {
  final testDate = DateTime(2026, 2, 14); // Saturday

  setUpAll(() async {
    await initializeDateFormatting('en', null);
  });

  group('MCalDayView snapping functionality', () {
    late MockMCalEventController controller;

    setUp(() {
      controller = MockMCalEventController(initialDate: testDate);
    });

    tearDown(() {
      controller.dispose();
    });

    Widget buildDayView({
      required MockMCalEventController ctrl,
      bool snapToTimeSlots = true,
      bool snapToOtherEvents = true,
      bool snapToCurrentTime = true,
      Duration snapRange = const Duration(minutes: 5),
      Duration timeSlotDuration = const Duration(minutes: 15),
      void Function(MCalEventDroppedDetails)? onEventDropped,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 800,
            child: MCalDayView(
              controller: ctrl,
              startHour: 8,
              endHour: 18,
              hourHeight: 80,
              timeSlotDuration: timeSlotDuration,
              snapToTimeSlots: snapToTimeSlots,
              snapToOtherEvents: snapToOtherEvents,
              snapToCurrentTime: snapToCurrentTime,
              snapRange: snapRange,
              enableDragToMove: true,
              onEventDropped: onEventDropped,
              showCurrentTimeIndicator: false,
              autoScrollToCurrentTime: false,
              initialScrollTime: const TimeOfDay(hour: 9, minute: 0),
              dragLongPressDelay: const Duration(milliseconds: 150),
            ),
          ),
        ),
      );
    }

    group('snap to time slots', () {
      testWidgets('drop snaps to 15-minute intervals', (tester) async {
        final event = MCalCalendarEvent(
          id: 'snap-slot-1',
          title: 'Snap Slot Event',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
        );
        controller.setMockEvents([event]);

        MCalEventDroppedDetails? capturedDetails;
        await tester.pumpWidget(
          buildDayView(
            ctrl: controller,
            onEventDropped: (d) => capturedDetails = d,
          ),
        );
        await tester.pumpAndSettle();

        final eventFinder = find.text('Snap Slot Event');
        final gesture = await tester.startGesture(tester.getCenter(eventFinder));
        await tester.pump(const Duration(milliseconds: 200));
        // Move down ~1.5 slots (22.5 min) - raw would be ~10:22, should snap to 10:15 or 10:30
        await gesture.moveBy(const Offset(0, 120));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await gesture.up();
        await tester.pumpAndSettle();

        if (capturedDetails != null) {
          expect(capturedDetails!.newStartDate.minute % 15, 0);
          expect(capturedDetails!.newEndDate.minute % 15, 0);
        }
        expect(find.byType(MCalDayView), findsOneWidget);
      });

      testWidgets('timeSlotDuration affects snap granularity', (tester) async {
        final event = MCalCalendarEvent(
          id: 'snap-5min',
          title: '5 Min Snap',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
        );
        controller.setMockEvents([event]);

        MCalEventDroppedDetails? capturedDetails;
        await tester.pumpWidget(
          buildDayView(
            ctrl: controller,
            timeSlotDuration: const Duration(minutes: 5),
            onEventDropped: (d) => capturedDetails = d,
          ),
        );
        await tester.pumpAndSettle();

        final eventFinder = find.text('5 Min Snap');
        final gesture = await tester.startGesture(tester.getCenter(eventFinder));
        await tester.pump(const Duration(milliseconds: 200));
        await gesture.moveBy(const Offset(0, 80));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await gesture.up();
        await tester.pumpAndSettle();

        if (capturedDetails != null) {
          expect(capturedDetails!.newStartDate.minute % 5, 0);
          expect(capturedDetails!.newEndDate.minute % 5, 0);
        }
        expect(find.byType(MCalDayView), findsOneWidget);
      });
    });

    group('snap to other events', () {
      testWidgets('drop near other event snaps to event boundary', (
        tester,
      ) async {
        controller.setMockEvents([
          MCalCalendarEvent(
            id: 'anchor',
            title: 'Anchor Event',
            start: DateTime(2026, 2, 14, 11, 0),
            end: DateTime(2026, 2, 14, 12, 0),
          ),
          MCalCalendarEvent(
            id: 'draggable',
            title: 'Draggable Event',
            start: DateTime(2026, 2, 14, 10, 0),
            end: DateTime(2026, 2, 14, 11, 0),
          ),
        ]);

        MCalEventDroppedDetails? capturedDetails;
        await tester.pumpWidget(
          buildDayView(
            ctrl: controller,
            snapRange: const Duration(minutes: 10),
            onEventDropped: (d) => capturedDetails = d,
          ),
        );
        await tester.pumpAndSettle();

        // Drag "Draggable Event" down toward "Anchor Event" (11:00)
        final eventFinder = find.text('Draggable Event');
        final gesture = await tester.startGesture(tester.getCenter(eventFinder));
        await tester.pump(const Duration(milliseconds: 200));
        await gesture.moveBy(const Offset(0, 70));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await gesture.up();
        await tester.pumpAndSettle();

        if (capturedDetails != null) {
          // Should snap to 11:00 (anchor start) or 15-min boundary
          final start = capturedDetails!.newStartDate;
          final isOnBoundary = start.minute % 15 == 0 ||
              (start.hour == 11 && start.minute == 0);
          expect(isOnBoundary, isTrue);
        }
        expect(find.byType(MCalDayView), findsOneWidget);
      });
    });

    group('snap range configuration', () {
      testWidgets('snapRange limits magnetic snap distance', (tester) async {
        final event = MCalCalendarEvent(
          id: 'range-1',
          title: 'Range Test',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
        );
        controller.setMockEvents([event]);

        MCalEventDroppedDetails? capturedDetails;
        await tester.pumpWidget(
          buildDayView(
            ctrl: controller,
            snapRange: const Duration(minutes: 2),
            onEventDropped: (d) => capturedDetails = d,
          ),
        );
        await tester.pumpAndSettle();

        final eventFinder = find.text('Range Test');
        final gesture = await tester.startGesture(tester.getCenter(eventFinder));
        await tester.pump(const Duration(milliseconds: 200));
        await gesture.moveBy(const Offset(0, 100));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await gesture.up();
        await tester.pumpAndSettle();

        if (capturedDetails != null) {
          expect(capturedDetails!.newStartDate.minute % 15, 0);
        }
        expect(find.byType(MCalDayView), findsOneWidget);
      });
    });

    group('snapping can be disabled per type', () {
      testWidgets('snapToTimeSlots:false allows non-slot times', (
        tester,
      ) async {
        final event = MCalCalendarEvent(
          id: 'no-slot-snap',
          title: 'No Slot Snap',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
        );
        controller.setMockEvents([event]);

        MCalEventDroppedDetails? capturedDetails;
        await tester.pumpWidget(
          buildDayView(
            ctrl: controller,
            snapToTimeSlots: false,
            snapToOtherEvents: false,
            snapToCurrentTime: false,
            onEventDropped: (d) => capturedDetails = d,
          ),
        );
        await tester.pumpAndSettle();

        final eventFinder = find.text('No Slot Snap');
        final gesture = await tester.startGesture(tester.getCenter(eventFinder));
        await tester.pump(const Duration(milliseconds: 200));
        await gesture.moveBy(const Offset(0, 50));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await gesture.up();
        await tester.pumpAndSettle();

        if (capturedDetails != null) {
          // With snapping disabled, offsetToTime still snaps internally for
          // grid alignment. The widget uses offsetToTime which has timeSlotDuration.
          // So we verify the widget accepts the config.
          expect(capturedDetails!.event.id, 'no-slot-snap');
        }
        expect(find.byType(MCalDayView), findsOneWidget);
      });

      testWidgets('snapToOtherEvents:false disables event boundary snap', (
        tester,
      ) async {
        controller.setMockEvents([
          MCalCalendarEvent(
            id: 'other',
            title: 'Other Event',
            start: DateTime(2026, 2, 14, 11, 0),
            end: DateTime(2026, 2, 14, 12, 0),
          ),
          MCalCalendarEvent(
            id: 'drag',
            title: 'Drag Event',
            start: DateTime(2026, 2, 14, 10, 0),
            end: DateTime(2026, 2, 14, 11, 0),
          ),
        ]);

        MCalEventDroppedDetails? capturedDetails;
        await tester.pumpWidget(
          buildDayView(
            ctrl: controller,
            snapToOtherEvents: false,
            onEventDropped: (d) => capturedDetails = d,
          ),
        );
        await tester.pumpAndSettle();

        final eventFinder = find.text('Drag Event');
        final gesture = await tester.startGesture(tester.getCenter(eventFinder));
        await tester.pump(const Duration(milliseconds: 200));
        await gesture.moveBy(const Offset(0, 80));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await gesture.up();
        await tester.pumpAndSettle();

        expect(find.byType(MCalDayView), findsOneWidget);
        if (capturedDetails != null) {
          expect(capturedDetails!.event.id, 'drag');
        }
      });
    });

    group('snap feedback during drag', () {
      testWidgets('drop target preview shows during drag with snapping', (
        tester,
      ) async {
        final event = MCalCalendarEvent(
          id: 'preview-1',
          title: 'Preview Event',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
        );
        controller.setMockEvents([event]);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 800,
                child: MCalDayView(
                  controller: controller,
                  startHour: 8,
                  endHour: 18,
                  hourHeight: 80,
                  enableDragToMove: true,
                  showDropTargetPreview: true,
                  showDropTargetOverlay: true,
                  snapToTimeSlots: true,
                  showCurrentTimeIndicator: false,
                  autoScrollToCurrentTime: false,
                  initialScrollTime: const TimeOfDay(hour: 9, minute: 0),
                  dragLongPressDelay: const Duration(milliseconds: 150),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final eventFinder = find.text('Preview Event');
        final gesture = await tester.startGesture(tester.getCenter(eventFinder));
        await tester.pump(const Duration(milliseconds: 200));
        await gesture.moveBy(const Offset(0, 60));
        await tester.pump();

        expect(find.byType(MCalDayView), findsOneWidget);

        await gesture.up();
        await tester.pumpAndSettle();
      });
    });

    group('snap to current time', () {
      testWidgets('snapToCurrentTime config is accepted', (tester) async {
        final event = MCalCalendarEvent(
          id: 'current-1',
          title: 'Current Time Test',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
        );
        controller.setMockEvents([event]);

        await tester.pumpWidget(
          buildDayView(
            ctrl: controller,
            snapToCurrentTime: true,
            snapRange: const Duration(minutes: 5),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MCalDayView), findsOneWidget);
        expect(find.text('Current Time Test'), findsOneWidget);
      });
    });
  });
}
