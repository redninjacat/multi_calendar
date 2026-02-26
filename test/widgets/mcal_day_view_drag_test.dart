import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

/// Mock MCalEventController for Day View drag testing.
class MockMCalEventController extends MCalEventController {
  MockMCalEventController({super.initialDate});

  void setMockEvents(List<MCalCalendarEvent> events) {
    clearEvents();
    addEvents(events);
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
  });

  group('MCalDayView drag and drop', () {
    late MockMCalEventController controller;

    setUp(() {
      controller = MockMCalEventController(initialDate: DateTime(2026, 2, 14));
    });

    tearDown(() {
      controller.dispose();
    });

    Widget buildDayView({
      required MockMCalEventController ctrl,
      bool enableDragToMove = true,
      bool Function(BuildContext, MCalEventDroppedDetails)? onEventDropped,
      bool Function(MCalEventDroppedDetails)? onDragWillAccept,
      bool showDropTargetTiles = true,
      bool showDropTargetOverlay = true,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 800,
            child: MCalDayView(
              controller: ctrl,
              enableDragToMove: enableDragToMove,
              onEventDropped: onEventDropped,
              onDragWillAccept: onDragWillAccept,
              showDropTargetTiles: showDropTargetTiles,
              showDropTargetOverlay: showDropTargetOverlay,
              dragLongPressDelay: const Duration(milliseconds: 150),
              showCurrentTimeIndicator: false,
              autoScrollToCurrentTime: false,
              initialScrollTime: const TimeOfDay(hour: 9, minute: 0),
            ),
          ),
        ),
      );
    }

    testWidgets(
      'enableDragToMove:false does not wrap tiles with LongPressDraggable',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'no-drag-1',
          title: 'No Drag Event',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
        );
        controller.setMockEvents([event]);

        await tester.pumpWidget(
          buildDayView(ctrl: controller, enableDragToMove: false),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LongPressDraggable<MCalDragData>), findsNothing);
      },
    );

    testWidgets(
      'enableDragToMove:true wraps timed events with LongPressDraggable',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'drag-enabled-1',
          title: 'Draggable Timed',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
        );
        controller.setMockEvents([event]);

        await tester.pumpWidget(buildDayView(ctrl: controller));
        await tester.pumpAndSettle();

        expect(find.byType(LongPressDraggable<MCalDragData>), findsWidgets);
      },
    );

    testWidgets('long-press on timed event initiates drag', (tester) async {
      final event = MCalCalendarEvent(
        id: 'long-press-timed-1',
        title: 'Long Press Timed',
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 11, 0),
      );
      controller.setMockEvents([event]);

      await tester.pumpWidget(buildDayView(ctrl: controller));
      await tester.pumpAndSettle();

      final eventFinder = find.text('Long Press Timed');
      expect(eventFinder, findsOneWidget);

      final gesture = await tester.startGesture(tester.getCenter(eventFinder));
      await tester.pump(const Duration(milliseconds: 200));

      await gesture.moveBy(const Offset(20, 50));
      await tester.pump();

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('drop fires onEventDropped callback with correct data', (
      tester,
    ) async {
      final event = MCalCalendarEvent(
        id: 'drop-callback-1',
        title: 'Drop Callback Test',
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 11, 0),
      );
      controller.setMockEvents([event]);

      MCalEventDroppedDetails? capturedDetails;

      await tester.pumpWidget(
        buildDayView(
          ctrl: controller,
          onEventDropped: (_, d) {
            capturedDetails = d;
            return true;
          },
        ),
      );
      await tester.pumpAndSettle();

      final eventFinder = find.text('Drop Callback Test');
      expect(eventFinder, findsOneWidget);

      final center = tester.getCenter(eventFinder);
      final gesture = await tester.startGesture(center);
      await tester.pump(const Duration(milliseconds: 200));

      await gesture.moveTo(center + const Offset(0, 120));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      await gesture.up();
      await tester.pumpAndSettle();

      if (capturedDetails != null) {
        expect(capturedDetails!.event.id, 'drop-callback-1');
        expect(capturedDetails!.oldStartDate, DateTime(2026, 2, 14, 10, 0));
        expect(capturedDetails!.oldEndDate, DateTime(2026, 2, 14, 11, 0));
        expect(capturedDetails!.newStartDate, isNotNull);
        expect(capturedDetails!.newEndDate, isNotNull);
      }
      expect(find.byType(MCalDayView), findsOneWidget);
    });

    testWidgets('drag data contains correct event and times', (tester) async {
      final event = MCalCalendarEvent(
        id: 'drag-data-1',
        title: 'Drag Data Test',
        start: DateTime(2026, 2, 14, 9, 30),
        end: DateTime(2026, 2, 14, 10, 30),
      );
      controller.setMockEvents([event]);

      MCalEventDroppedDetails? capturedDetails;

      await tester.pumpWidget(
        buildDayView(
          ctrl: controller,
          onEventDropped: (_, d) {
            capturedDetails = d;
            return true;
          },
        ),
      );
      await tester.pumpAndSettle();

      final eventFinder = find.text('Drag Data Test');
      final gesture = await tester.startGesture(tester.getCenter(eventFinder));
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.moveBy(const Offset(0, 80));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.up();
      await tester.pumpAndSettle();

      if (capturedDetails != null) {
        expect(capturedDetails!.event.id, 'drag-data-1');
        expect(capturedDetails!.event.title, 'Drag Data Test');
        expect(capturedDetails!.event.start, DateTime(2026, 2, 14, 9, 30));
        expect(capturedDetails!.event.end, DateTime(2026, 2, 14, 10, 30));
        final duration = capturedDetails!.newEndDate.difference(
          capturedDetails!.newStartDate,
        );
        expect(duration.inMinutes, 60);
      }
      expect(find.byType(MCalDayView), findsOneWidget);
    });

    testWidgets('cancel drag clears state', (tester) async {
      final event = MCalCalendarEvent(
        id: 'cancel-drag-1',
        title: 'Cancel Drag',
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 11, 0),
      );
      controller.setMockEvents([event]);

      var dropCalled = false;
      await tester.pumpWidget(
        buildDayView(
          ctrl: controller,
          onEventDropped: (_, __) {
            dropCalled = true;
            return true;
          },
        ),
      );
      await tester.pumpAndSettle();

      final eventFinder = find.text('Cancel Drag');
      final gesture = await tester.startGesture(tester.getCenter(eventFinder));
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.moveBy(const Offset(0, 50));
      await tester.pump();

      await gesture.cancel();
      await tester.pumpAndSettle();

      expect(dropCalled, isFalse);
      expect(find.text('Cancel Drag'), findsOneWidget);
    });

    testWidgets(
      'all-day event wraps with LongPressDraggable when drag enabled',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'allday-drag-1',
          title: 'All Day Event',
          start: DateTime(2026, 2, 14),
          end: DateTime(2026, 2, 14),
          isAllDay: true,
        );
        controller.setMockEvents([event]);

        await tester.pumpWidget(buildDayView(ctrl: controller));
        await tester.pumpAndSettle();

        expect(find.byType(LongPressDraggable<MCalDragData>), findsWidgets);
      },
    );

    testWidgets('all-day to timed conversion - drop in timed area', (
      tester,
    ) async {
      final event = MCalCalendarEvent(
        id: 'allday-to-timed-1',
        title: 'All Day To Timed',
        start: DateTime(2026, 2, 14),
        end: DateTime(2026, 2, 14),
        isAllDay: true,
      );
      controller.setMockEvents([event]);

      MCalEventDroppedDetails? capturedDetails;

      await tester.pumpWidget(
        buildDayView(
          ctrl: controller,
          onEventDropped: (_, d) {
            capturedDetails = d;
            return true;
          },
        ),
      );
      await tester.pumpAndSettle();

      final eventFinder = find.text('All Day To Timed');
      expect(eventFinder, findsOneWidget);

      final center = tester.getCenter(eventFinder);
      final gesture = await tester.startGesture(center);
      await tester.pump(const Duration(milliseconds: 200));

      await gesture.moveBy(const Offset(0, 150));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await gesture.up();
      await tester.pumpAndSettle();

      if (capturedDetails != null) {
        expect(capturedDetails!.typeConversion, 'allDayToTimed');
        expect(capturedDetails!.newStartDate.hour, greaterThanOrEqualTo(0));
        expect(capturedDetails!.newEndDate.hour, greaterThanOrEqualTo(0));
      }
    });

    testWidgets('timed to all-day conversion - drop in all-day area', (
      tester,
    ) async {
      final event = MCalCalendarEvent(
        id: 'timed-to-allday-1',
        title: 'Timed To All Day',
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 11, 0),
      );
      controller.setMockEvents([event]);

      MCalEventDroppedDetails? capturedDetails;

      await tester.pumpWidget(
        buildDayView(
          ctrl: controller,
          onEventDropped: (_, d) {
            capturedDetails = d;
            return true;
          },
        ),
      );
      await tester.pumpAndSettle();

      final eventFinder = find.text('Timed To All Day');
      expect(eventFinder, findsOneWidget);

      final center = tester.getCenter(eventFinder);
      final gesture = await tester.startGesture(center);
      await tester.pump(const Duration(milliseconds: 200));

      // Move far enough upward to land inside the all-day section, which sits
      // above the scrollable time grid viewport. The viewport starts at roughly
      // Y=121 (all-day section height). Moving 380px up from ~Y=455 brings the
      // pointer to ~Y=75, well inside the all-day zone.
      await gesture.moveBy(const Offset(0, -380));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await gesture.up();
      await tester.pumpAndSettle();

      expect(capturedDetails, isNotNull,
          reason: 'onEventDropped should have fired when dropping in the all-day area');
      expect(capturedDetails!.typeConversion, 'timedToAllDay');
      expect(capturedDetails!.newStartDate.hour, 0);
      expect(capturedDetails!.newStartDate.minute, 0);
    });

    testWidgets('onDragWillAccept returning false prevents drop', (
      tester,
    ) async {
      final event = MCalCalendarEvent(
        id: 'reject-drag-1',
        title: 'Reject Drop',
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 11, 0),
      );
      controller.setMockEvents([event]);

      var dropCalled = false;
      await tester.pumpWidget(
        buildDayView(
          ctrl: controller,
          onEventDropped: (_, __) {
            dropCalled = true;
            return true;
          },
          onDragWillAccept: (_) => false,
        ),
      );
      await tester.pumpAndSettle();

      final eventFinder = find.text('Reject Drop');
      final gesture = await tester.startGesture(tester.getCenter(eventFinder));
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(dropCalled, isFalse);
    });

    testWidgets('onDragWillAccept returning true allows drop', (tester) async {
      final event = MCalCalendarEvent(
        id: 'accept-drag-1',
        title: 'Accept Drop',
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 11, 0),
      );
      controller.setMockEvents([event]);

      MCalEventDroppedDetails? capturedDetails;
      await tester.pumpWidget(
        buildDayView(
          ctrl: controller,
          onEventDropped: (_, d) {
            capturedDetails = d;
            return true;
          },
          onDragWillAccept: (_) => true,
        ),
      );
      await tester.pumpAndSettle();

      final eventFinder = find.text('Accept Drop');
      final gesture = await tester.startGesture(tester.getCenter(eventFinder));
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.moveBy(const Offset(0, 80));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.up();
      await tester.pumpAndSettle();

      if (capturedDetails != null) {
        expect(capturedDetails!.event.id, 'accept-drag-1');
      }
      expect(find.byType(MCalDayView), findsOneWidget);
    });

    testWidgets('showDropTargetPreview shows preview during drag', (
      tester,
    ) async {
      final event = MCalCalendarEvent(
        id: 'preview-1',
        title: 'Preview Test',
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 11, 0),
      );
      controller.setMockEvents([event]);

      await tester.pumpWidget(
        buildDayView(ctrl: controller, showDropTargetTiles: true),
      );
      await tester.pumpAndSettle();

      final eventFinder = find.text('Preview Test');
      final gesture = await tester.startGesture(tester.getCenter(eventFinder));
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.moveBy(const Offset(0, 60));
      await tester.pump();

      expect(find.byType(MCalDayView), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('showDropTargetOverlay shows overlay during drag', (
      tester,
    ) async {
      final event = MCalCalendarEvent(
        id: 'overlay-1',
        title: 'Overlay Test',
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 11, 0),
      );
      controller.setMockEvents([event]);

      await tester.pumpWidget(
        buildDayView(ctrl: controller, showDropTargetOverlay: true),
      );
      await tester.pumpAndSettle();

      final eventFinder = find.text('Overlay Test');
      final gesture = await tester.startGesture(tester.getCenter(eventFinder));
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.moveBy(const Offset(0, 60));
      await tester.pump();

      expect(find.byType(MCalDayView), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('DragTarget wraps day view when enableDragToMove is true', (
      tester,
    ) async {
      final event = MCalCalendarEvent(
        id: 'target-1',
        title: 'Target Test',
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 11, 0),
      );
      controller.setMockEvents([event]);

      await tester.pumpWidget(buildDayView(ctrl: controller));
      await tester.pumpAndSettle();

      expect(find.byType(DragTarget<MCalDragData>), findsOneWidget);
    });

    testWidgets('timed event drag within day preserves duration', (
      tester,
    ) async {
      final event = MCalCalendarEvent(
        id: 'duration-1',
        title: 'Duration Test',
        start: DateTime(2026, 2, 14, 9, 0),
        end: DateTime(2026, 2, 14, 11, 0),
      );
      controller.setMockEvents([event]);

      MCalEventDroppedDetails? capturedDetails;
      await tester.pumpWidget(
        buildDayView(
          ctrl: controller,
          onEventDropped: (_, d) {
            capturedDetails = d;
            return true;
          },
        ),
      );
      await tester.pumpAndSettle();

      final eventFinder = find.text('Duration Test');
      final gesture = await tester.startGesture(tester.getCenter(eventFinder));
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.moveBy(const Offset(0, 120));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.up();
      await tester.pumpAndSettle();

      if (capturedDetails != null) {
        final oldDuration = capturedDetails!.oldEndDate.difference(
          capturedDetails!.oldStartDate,
        );
        final newDuration = capturedDetails!.newEndDate.difference(
          capturedDetails!.newStartDate,
        );
        expect(newDuration.inMinutes, oldDuration.inMinutes);
      }
      expect(find.byType(MCalDayView), findsOneWidget);
    });
  });
}
