import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

/// Mock controller for keyboard consistency testing.
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

  /// Pumps a [MCalDayView] with all the plumbing needed for keyboard
  /// move / resize testing.
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
              showNavigator: false,
              showCurrentTimeIndicator: false,
              autoScrollToCurrentTime: false,
              initialScrollTime: const TimeOfDay(hour: 9, minute: 0),
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

  /// Gives the DayView keyboard focus, uses Tab to focus the first event,
  /// then sends Ctrl+M to enter keyboard move mode.
  Future<void> enterMoveMode(WidgetTester tester) async {
    // Tap the day view to give it keyboard focus
    await tester.tap(find.byType(MCalDayView));
    await tester.pumpAndSettle();

    // Tab to focus the first event
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    // Ctrl+M enters keyboard move mode
    await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
    await tester.pumpAndSettle();
  }

  /// From move mode, presses R to enter resize mode.
  Future<void> enterResizeModeFromMove(WidgetTester tester) async {
    await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
    await tester.pumpAndSettle();
  }

  // ============================================================
  // Group 1: Day View keyboard resize uses S/E/M keys
  // ============================================================

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
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 12, 0),
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

      // Press S to switch to start edge
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.pumpAndSettle();

      // Adjust start edge (ArrowUp = earlier start)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();

      // Confirm resize
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
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 12, 0),
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

      // Switch to start first, then back to end with E
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
      await tester.pumpAndSettle();

      // Adjust end edge (ArrowDown = later end)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Confirm resize
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
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 12, 0),
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

      // Press M to return to move mode
      await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
      await tester.pumpAndSettle();

      // Verify we're back in move mode: R should enter resize again
      // (only possible from move mode)
      await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
      await tester.pumpAndSettle();

      // Press Escape to cancel resize and return to move mode again
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Now move and confirm — should fire onEventDropped (move, not resize)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(droppedDetails, isNotNull,
          reason:
              'After M exits resize back to move mode, confirming should fire onEventDropped');
    });

    testWidgets(
        'Escape cancels resize but does NOT exit move mode',
        (tester) async {
      final event = MCalCalendarEvent(
        id: 'resize-esc',
        title: 'Escape Test',
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 12, 0),
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

      // Adjust resize
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Escape cancels resize but stays in move mode
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Still in move mode: arrow keys should move the event
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Enter to confirm the move
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(droppedDetails, isNotNull,
          reason:
              'After Escape in resize mode, move mode should still be active '
              '— arrow keys move the event and Enter confirms');
    });
  });

  // ============================================================
  // Group 2: Day View move mode uses Enter/NumpadEnter
  // ============================================================

  group('Day View move mode uses Enter/NumpadEnter (consistent with Month View)',
      () {
    late _MockController controller;

    setUp(() {
      controller = _MockController(initialDate: testDate);
    });

    tearDown(() => controller.dispose());

    testWidgets('Enter confirms the move', (tester) async {
      final event = MCalCalendarEvent(
        id: 'move-enter',
        title: 'Enter Move',
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 11, 0),
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

      // Move event down one slot
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Confirm with Enter
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(droppedDetails, isNotNull,
          reason: 'Enter should confirm the keyboard move');
      expect(droppedDetails!.event.id, equals('move-enter'));
    });

    testWidgets('NumpadEnter confirms the move', (tester) async {
      final event = MCalCalendarEvent(
        id: 'move-numpad',
        title: 'Numpad Move',
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 11, 0),
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

      // Move event down one slot
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Confirm with NumpadEnter
      await tester.sendKeyEvent(LogicalKeyboardKey.numpadEnter);
      await tester.pumpAndSettle();

      expect(droppedDetails, isNotNull,
          reason: 'NumpadEnter should confirm the keyboard move');
      expect(droppedDetails!.event.id, equals('move-numpad'));
    });

    testWidgets('Space does NOT confirm the move', (tester) async {
      final event = MCalCalendarEvent(
        id: 'move-space',
        title: 'Space Move',
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 11, 0),
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

      // Move event down one slot
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Press Space — should NOT confirm
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      expect(droppedDetails, isNull,
          reason:
              'Space should not confirm the move — only Enter/NumpadEnter do');

      // Clean up: Escape to cancel the move
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
    });
  });

  // ============================================================
  // Group 3: Day View resize mode uses Enter/NumpadEnter
  // ============================================================

  group(
      'Day View resize mode uses Enter/NumpadEnter (consistent with Month View)',
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
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 12, 0),
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

      // Adjust end edge
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Confirm with Enter
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(resizedDetails, isNotNull,
          reason: 'Enter should confirm the keyboard resize');
      expect(resizedDetails!.event.id, equals('resize-enter'));
    });

    testWidgets('NumpadEnter confirms the resize', (tester) async {
      final event = MCalCalendarEvent(
        id: 'resize-numpad',
        title: 'Numpad Resize',
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 12, 0),
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

      // Adjust end edge
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Confirm with NumpadEnter
      await tester.sendKeyEvent(LogicalKeyboardKey.numpadEnter);
      await tester.pumpAndSettle();

      expect(resizedDetails, isNotNull,
          reason: 'NumpadEnter should confirm the keyboard resize');
      expect(resizedDetails!.event.id, equals('resize-numpad'));
    });
  });

  // ============================================================
  // Group 4: Day View move mode R key enters resize mode
  // ============================================================

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
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 12, 0),
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

      // Press R to enter resize mode (from move mode)
      await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
      await tester.pumpAndSettle();

      // ArrowDown should now adjust the end edge (default edge in resize)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Confirm resize
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
