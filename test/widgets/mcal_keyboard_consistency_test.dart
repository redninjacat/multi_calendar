import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

class _MockController extends MCalEventController {
  _MockController({super.initialDate});

  void setMockEvents(List<MCalCalendarEvent> events) {
    clearEvents();
    addEvents(events);
  }
}

void main() {
  final testDate = DateTime(2026, 2, 14);

  setUpAll(() async {
    await initializeDateFormatting('en', null);
  });

  Future<void> pumpDayView(
    WidgetTester tester, {
    required _MockController controller,
    bool enableDragToMove = true,
    bool? enableDragToResize = true,
    bool enableKeyboardNavigation = true,
    bool Function(BuildContext, MCalEventDroppedDetails)? onEventDropped,
    bool Function(BuildContext, MCalEventResizedDetails)? onEventResized,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: MCalLocalizations.localizationsDelegates,
        supportedLocales: MCalLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 600,
            height: 800,
            child: MCalDayView(
              controller: controller,
              startHour: 8,
              endHour: 18,
              timeSlotDuration: const Duration(minutes: 15),
              showNavigator: false,
              showCurrentTimeIndicator: false,
              autoScrollToCurrentTime: false,
              initialScrollTime: const TimeOfDay(hour: 8, minute: 0),
              enableDragToMove: enableDragToMove,
              enableDragToResize: enableDragToResize,
              enableKeyboardNavigation: enableKeyboardNavigation,
              onEventDropped: onEventDropped,
              onEventResized: onEventResized,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Enters Move Mode via the new four-mode state machine:
  /// Tap → ArrowDown (Navigation Mode, slot 0) → Enter (Event Mode) → M (Move Mode).
  /// Events must overlap slot 0 (startHour).
  Future<void> enterMoveMode(WidgetTester tester) async {
    await tester.tap(find.byType(MCalDayView));
    await tester.pumpAndSettle();
    // After the tap, keyboard navigation is active but on some time slot.
    // Press Home to jump to slot 0 (startHour), where the test event lives,
    // restoring the same state the tests had before tap-to-focus was added.
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
    await tester.pumpAndSettle();
  }

  Future<void> enterResizeModeFromMove(WidgetTester tester) async {
    await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
    await tester.pumpAndSettle();
  }

  // ── Resize Mode: S/E/M keys ────────────────────────────────────────────────

  group('Day View keyboard resize uses S/E/M keys (consistent with Month View)',
      () {
    late _MockController controller;

    setUp(() {
      controller = _MockController(initialDate: testDate);
    });

    tearDown(() => controller.dispose());

    testWidgets('S key switches to start edge in resize mode', (tester) async {
      final event = MCalCalendarEvent(
        id: 'resize-s',
        title: 'S Key Test',
        start: DateTime(2026, 2, 14, 8, 0),
        end: DateTime(2026, 2, 14, 10, 0),
      );
      controller.setMockEvents([event]);

      MCalEventResizedDetails? resizedDetails;

      await pumpDayView(
        tester,
        controller: controller,
        onEventResized: (ctx, details) {
          resizedDetails = details;
          return true;
        },
      );

      await enterMoveMode(tester);
      await enterResizeModeFromMove(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(resizedDetails, isNotNull,
          reason: 'onEventResized should fire after confirming resize');
      expect(resizedDetails!.resizeEdge, equals(MCalResizeEdge.start),
          reason: 'S key should switch the active resize edge to start');
    });

    testWidgets('E key switches to end edge in resize mode', (tester) async {
      final event = MCalCalendarEvent(
        id: 'resize-e',
        title: 'E Key Test',
        start: DateTime(2026, 2, 14, 8, 0),
        end: DateTime(2026, 2, 14, 10, 0),
      );
      controller.setMockEvents([event]);

      MCalEventResizedDetails? resizedDetails;

      await pumpDayView(
        tester,
        controller: controller,
        onEventResized: (ctx, details) {
          resizedDetails = details;
          return true;
        },
      );

      await enterMoveMode(tester);
      await enterResizeModeFromMove(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(resizedDetails, isNotNull,
          reason: 'onEventResized should fire after confirming resize');
      expect(resizedDetails!.resizeEdge, equals(MCalResizeEdge.end),
          reason: 'E key should switch the active resize edge to end');
    });

    testWidgets('M key exits resize and returns to move mode', (tester) async {
      final event = MCalCalendarEvent(
        id: 'resize-m',
        title: 'M Key Test',
        start: DateTime(2026, 2, 14, 8, 0),
        end: DateTime(2026, 2, 14, 10, 0),
      );
      controller.setMockEvents([event]);

      MCalEventDroppedDetails? droppedDetails;

      await pumpDayView(
        tester,
        controller: controller,
        onEventDropped: (ctx, details) {
          droppedDetails = details;
          return true;
        },
      );

      await enterMoveMode(tester);
      await enterResizeModeFromMove(tester);

      // M returns to Move Mode
      await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
      await tester.pumpAndSettle();

      // Move the event and confirm
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(droppedDetails, isNotNull,
          reason:
              'After M exits resize back to move mode, confirming should fire onEventDropped');
    });

    testWidgets(
        'Escape cancels resize and returns to Event Mode',
        (tester) async {
      final event = MCalCalendarEvent(
        id: 'resize-esc',
        title: 'Escape Test',
        start: DateTime(2026, 2, 14, 8, 0),
        end: DateTime(2026, 2, 14, 10, 0),
      );
      controller.setMockEvents([event]);

      MCalEventResizedDetails? resizedDetails;

      await pumpDayView(
        tester,
        controller: controller,
        onEventResized: (ctx, details) {
          resizedDetails = details;
          return true;
        },
      );

      await enterMoveMode(tester);
      await enterResizeModeFromMove(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Escape cancels resize → Event Mode (per spec: Resize → Event)
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Should be in Event Mode now. R should re-enter Resize Mode.
      await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(resizedDetails, isNotNull,
          reason:
              'After Escape from Resize → Event Mode, R re-enters Resize '
              'and Enter confirms');
    });
  });

  // ── Move Mode: Enter/Space confirm ──────────────────────────────────────────

  group('Day View move mode uses Enter/Space (consistent with Month View)', () {
    late _MockController controller;

    setUp(() {
      controller = _MockController(initialDate: testDate);
    });

    tearDown(() => controller.dispose());

    testWidgets('Enter confirms the move', (tester) async {
      final event = MCalCalendarEvent(
        id: 'move-enter',
        title: 'Enter Move',
        start: DateTime(2026, 2, 14, 8, 0),
        end: DateTime(2026, 2, 14, 9, 0),
      );
      controller.setMockEvents([event]);

      MCalEventDroppedDetails? droppedDetails;

      await pumpDayView(
        tester,
        controller: controller,
        onEventDropped: (ctx, details) {
          droppedDetails = details;
          return true;
        },
      );

      await enterMoveMode(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(droppedDetails, isNotNull,
          reason: 'Enter should confirm the keyboard move');
      expect(droppedDetails!.event.id, equals('move-enter'));
    });

    testWidgets('Space confirms the move', (tester) async {
      final event = MCalCalendarEvent(
        id: 'move-space',
        title: 'Space Move',
        start: DateTime(2026, 2, 14, 8, 0),
        end: DateTime(2026, 2, 14, 9, 0),
      );
      controller.setMockEvents([event]);

      MCalEventDroppedDetails? droppedDetails;

      await pumpDayView(
        tester,
        controller: controller,
        onEventDropped: (ctx, details) {
          droppedDetails = details;
          return true;
        },
      );

      await enterMoveMode(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      expect(droppedDetails, isNotNull,
          reason: 'Space should confirm the keyboard move (same as Enter)');
      expect(droppedDetails!.event.id, equals('move-space'));
    });
  });

  // ── Resize Mode: Enter/Space confirm ────────────────────────────────────────

  group('Day View resize mode uses Enter/Space (consistent with Month View)',
      () {
    late _MockController controller;

    setUp(() {
      controller = _MockController(initialDate: testDate);
    });

    tearDown(() => controller.dispose());

    testWidgets('Enter confirms the resize', (tester) async {
      final event = MCalCalendarEvent(
        id: 'resize-enter',
        title: 'Enter Resize',
        start: DateTime(2026, 2, 14, 8, 0),
        end: DateTime(2026, 2, 14, 10, 0),
      );
      controller.setMockEvents([event]);

      MCalEventResizedDetails? resizedDetails;

      await pumpDayView(
        tester,
        controller: controller,
        onEventResized: (ctx, details) {
          resizedDetails = details;
          return true;
        },
      );

      await enterMoveMode(tester);
      await enterResizeModeFromMove(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(resizedDetails, isNotNull,
          reason: 'Enter should confirm the keyboard resize');
      expect(resizedDetails!.event.id, equals('resize-enter'));
    });

    testWidgets('Space confirms the resize', (tester) async {
      final event = MCalCalendarEvent(
        id: 'resize-space',
        title: 'Space Resize',
        start: DateTime(2026, 2, 14, 8, 0),
        end: DateTime(2026, 2, 14, 10, 0),
      );
      controller.setMockEvents([event]);

      MCalEventResizedDetails? resizedDetails;

      await pumpDayView(
        tester,
        controller: controller,
        onEventResized: (ctx, details) {
          resizedDetails = details;
          return true;
        },
      );

      await enterMoveMode(tester);
      await enterResizeModeFromMove(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      expect(resizedDetails, isNotNull,
          reason: 'Space should confirm the keyboard resize (same as Enter)');
      expect(resizedDetails!.event.id, equals('resize-space'));
    });
  });

  // ── Move Mode: R key enters Resize Mode ─────────────────────────────────────

  group(
      'Day View move mode R key enters resize mode (consistent with Month View)',
      () {
    late _MockController controller;

    setUp(() {
      controller = _MockController(initialDate: testDate);
    });

    tearDown(() => controller.dispose());

    testWidgets('R enters resize mode from move mode when resize is enabled',
        (tester) async {
      final event = MCalCalendarEvent(
        id: 'r-resize',
        title: 'R Key Test',
        start: DateTime(2026, 2, 14, 8, 0),
        end: DateTime(2026, 2, 14, 10, 0),
      );
      controller.setMockEvents([event]);

      MCalEventResizedDetails? resizedDetails;

      await pumpDayView(
        tester,
        controller: controller,
        onEventResized: (ctx, details) {
          resizedDetails = details;
          return true;
        },
      );

      await enterMoveMode(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(resizedDetails, isNotNull,
          reason:
              'R key in move mode should enter resize mode; confirming should '
              'fire onEventResized');
      expect(resizedDetails!.resizeEdge, equals(MCalResizeEdge.end),
          reason: 'Default resize edge should be end');
    });
  });
}
