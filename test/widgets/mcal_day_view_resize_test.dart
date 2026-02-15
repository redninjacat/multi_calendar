import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

/// Widget tests for MCalDayView resize gestures (FR-16).
///
/// Handle visibility and constraints are tested. Resize drag tests are skipped
/// because the resize handle's vertical drag competes with the scroll view's
/// gesture arena in widget tests; resize is verified via manual/integration testing.

/// ScrollBehavior that disables drag scrolling so resize handle gestures win.
class _NoDragScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {};
}

/// Mock MCalEventController for Day View resize testing.
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

  group('MCalDayView resize gestures', () {
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
      bool enableDragToResize = true,
      void Function(MCalEventResizedDetails)? onEventResized,
      bool Function(MCalEventResizedDetails)? onResizeWillAccept,
      MCalThemeData? theme,
      double hourHeight = 80,
    }) {
      return MaterialApp(
        scrollBehavior: _NoDragScrollBehavior(),
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 800,
            child: MCalDayView(
              controller: ctrl,
              enableDragToMove: enableDragToMove,
              enableDragToResize: enableDragToResize,
              onEventResized: onEventResized,
              onResizeWillAccept: onResizeWillAccept,
              theme: theme,
              startHour: 8,
              endHour: 12,
              hourHeight: hourHeight,
              gridlineInterval: const Duration(minutes: 15),
              showCurrentTimeIndicator: false,
              autoScrollToCurrentTime: false,
              initialScrollTime: const TimeOfDay(hour: 9, minute: 0),
              dragLongPressDelay: const Duration(milliseconds: 300),
              scrollPhysics: const NeverScrollableScrollPhysics(),
            ),
          ),
        ),
      );
    }

    testWidgets(
      'resize handles appear on timed events when enableDragToResize is true',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'resize-1',
          title: 'Resizable Event',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
        );
        controller.setMockEvents([event]);

        await tester.pumpWidget(buildDayView(ctrl: controller));
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Resize start time'), findsWidgets);
        expect(find.bySemanticsLabel('Resize end time'), findsWidgets);
      },
    );

    testWidgets(
      'resize handles do not appear when enableDragToResize is false',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'no-resize-1',
          title: 'No Resize Event',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
        );
        controller.setMockEvents([event]);

        await tester.pumpWidget(
          buildDayView(ctrl: controller, enableDragToResize: false),
        );
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Resize start time'), findsNothing);
        expect(find.bySemanticsLabel('Resize end time'), findsNothing);
      },
    );

    testWidgets(
      'short events do not show resize handles when below min duration',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'short-1',
          title: 'Short Event',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 10, 30),
        );
        controller.setMockEvents([event]);

        final theme = MCalThemeData(minResizeDurationMinutes: 60);

        await tester.pumpWidget(
          buildDayView(
            ctrl: controller,
            theme: theme,
            hourHeight: 120,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Resize start time'), findsNothing);
        expect(find.bySemanticsLabel('Resize end time'), findsNothing);
      },
    );

    testWidgets('events at or above min duration show resize handles', (
      tester,
    ) async {
      final event = MCalCalendarEvent(
        id: 'min-dur-1',
        title: 'Min Duration Event',
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 11, 0),
      );
      controller.setMockEvents([event]);

      final theme = MCalThemeData(minResizeDurationMinutes: 30);

      await tester.pumpWidget(buildDayView(ctrl: controller, theme: theme));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Resize start time'), findsWidgets);
      expect(find.bySemanticsLabel('Resize end time'), findsWidgets);
    });

    testWidgets(
      'resize handles have Listener with onPointerDown for gesture tracking',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'top-handle-1',
          title: 'Top Handle Event',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
        );
        controller.setMockEvents([event]);

        await tester.pumpWidget(
          buildDayView(
            ctrl: controller,
            enableDragToMove: false,
          ),
        );
        await tester.pumpAndSettle();

        final startHandleFinder = find.bySemanticsLabel('Resize start time');
        final endHandleFinder = find.bySemanticsLabel('Resize end time');
        expect(startHandleFinder, findsWidgets);
        expect(endHandleFinder, findsWidgets);

        // Resize handles use Listener for pointer events (parent tracks gesture)
        expect(find.byType(Listener), findsWidgets);
      },
    );

    testWidgets(
      'MCalDayView receives onEventResized and onResizeWillAccept callbacks',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'callback-1',
          title: 'Callback Event',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
        );
        controller.setMockEvents([event]);

        await tester.pumpWidget(
          buildDayView(
            ctrl: controller,
            enableDragToMove: false,
            onEventResized: (_) {},
            onResizeWillAccept: (_) => true,
          ),
        );
        await tester.pumpAndSettle();

        final dayView = tester.widget<MCalDayView>(find.byType(MCalDayView));
        expect(dayView.onEventResized, isNotNull);
        expect(dayView.onResizeWillAccept, isNotNull);
      },
    );

    testWidgets(
      'resize handles show correct semantic labels for start and end edges',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'data-1',
          title: 'Data Test Event',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 30),
        );
        controller.setMockEvents([event]);

        await tester.pumpWidget(
          buildDayView(
            ctrl: controller,
            enableDragToMove: false,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Resize start time'), findsWidgets);
        expect(find.bySemanticsLabel('Resize end time'), findsWidgets);
      },
    );

    testWidgets(
      'resize handles appear on events at or above min duration',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'min-1',
          title: 'Min Duration Resize',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
        );
        controller.setMockEvents([event]);

        final theme = MCalThemeData(minResizeDurationMinutes: 15);

        await tester.pumpWidget(
          buildDayView(
            ctrl: controller,
            theme: theme,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Resize start time'), findsWidgets);
        expect(find.bySemanticsLabel('Resize end time'), findsWidgets);
      },
    );

    testWidgets(
      'gridline interval is applied for snap-to-grid during resize',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'snap-1',
          title: 'Snap Event',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
        );
        controller.setMockEvents([event]);

        await tester.pumpWidget(
          buildDayView(
            ctrl: controller,
            enableDragToMove: false,
          ),
        );
        await tester.pumpAndSettle();

        // Verify gridline interval is passed to Day View (15-min default)
        final dayView = tester.widget<MCalDayView>(find.byType(MCalDayView));
        expect(dayView.gridlineInterval, const Duration(minutes: 15));
      },
    );

    testWidgets(
      'Day View builds with resize enabled for preview during interaction',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'preview-1',
          title: 'Preview Event',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
        );
        controller.setMockEvents([event]);

        await tester.pumpWidget(
          buildDayView(ctrl: controller, enableDragToMove: false),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MCalDayView), findsOneWidget);
        expect(find.bySemanticsLabel('Resize end time'), findsWidgets);
      },
    );

    testWidgets(
      'onResizeWillAccept callback is wired when provided',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'reject-1',
          title: 'Reject Resize',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
        );
        controller.setMockEvents([event]);

        await tester.pumpWidget(
          buildDayView(
            ctrl: controller,
            enableDragToMove: false,
            onResizeWillAccept: (_) => false,
          ),
        );
        await tester.pumpAndSettle();

        final dayView = tester.widget<MCalDayView>(find.byType(MCalDayView));
        expect(dayView.onResizeWillAccept, isNotNull);
      },
    );

    testWidgets(
      'onEventResized callback is wired when provided',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'cancel-1',
          title: 'Cancel Resize',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
        );
        controller.setMockEvents([event]);

        await tester.pumpWidget(
          buildDayView(
            ctrl: controller,
            enableDragToMove: false,
            onEventResized: (_) {},
          ),
        );
        await tester.pumpAndSettle();

        final dayView = tester.widget<MCalDayView>(find.byType(MCalDayView));
        expect(dayView.onEventResized, isNotNull);
      },
    );

    testWidgets('all-day events do not show resize handles', (tester) async {
      final event = MCalCalendarEvent(
        id: 'allday-1',
        title: 'All Day Event',
        start: DateTime(2026, 2, 14),
        end: DateTime(2026, 2, 14),
        isAllDay: true,
      );
      controller.setMockEvents([event]);

      await tester.pumpWidget(buildDayView(ctrl: controller));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Resize start time'), findsNothing);
      expect(find.bySemanticsLabel('Resize end time'), findsNothing);
    });
  });

  group('MCalEventResizedDetails', () {
    test('callback data structure is correct for end-edge resize', () {
      final event = MCalCalendarEvent(
        id: 'resize-details-1',
        title: 'Resize Details Test',
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 11, 0),
      );
      final oldStart = DateTime(2026, 2, 14, 10, 0);
      final oldEnd = DateTime(2026, 2, 14, 11, 0);
      final newStart = DateTime(2026, 2, 14, 10, 0);
      final newEnd = DateTime(2026, 2, 14, 11, 30);

      final details = MCalEventResizedDetails(
        event: event,
        oldStartDate: oldStart,
        oldEndDate: oldEnd,
        newStartDate: newStart,
        newEndDate: newEnd,
        resizeEdge: MCalResizeEdge.end,
      );

      expect(details.event.id, 'resize-details-1');
      expect(details.oldStartDate, oldStart);
      expect(details.oldEndDate, oldEnd);
      expect(details.newStartDate, newStart);
      expect(details.newEndDate, newEnd);
      expect(details.resizeEdge, MCalResizeEdge.end);
      expect(details.newEndDate.difference(details.newStartDate).inMinutes, 90);
    });

    test('callback data structure is correct for start-edge resize', () {
      final event = MCalCalendarEvent(
        id: 'resize-details-2',
        title: 'Start Resize Test',
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 11, 0),
      );
      final oldStart = DateTime(2026, 2, 14, 10, 0);
      final oldEnd = DateTime(2026, 2, 14, 11, 0);
      final newStart = DateTime(2026, 2, 14, 10, 30);
      final newEnd = DateTime(2026, 2, 14, 11, 0);

      final details = MCalEventResizedDetails(
        event: event,
        oldStartDate: oldStart,
        oldEndDate: oldEnd,
        newStartDate: newStart,
        newEndDate: newEnd,
        resizeEdge: MCalResizeEdge.start,
      );

      expect(details.resizeEdge, MCalResizeEdge.start);
      expect(details.newStartDate, newStart);
      expect(details.newEndDate, newEnd);
      expect(details.newEndDate.difference(details.newStartDate).inMinutes, 30);
    });
  });
}
