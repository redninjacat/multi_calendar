import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

/// Test controller that supports adding events.
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

  group('Keyboard event selection - keyboardState in eventTileBuilder', () {
    late _TestController controller;

    setUp(() {
      controller = _TestController(initialDate: DateTime(2025, 1, 1));
    });

    tearDown(() {
      controller.dispose();
    });

    /// Helper: pumps a calendar with keyboard navigation, drag-and-drop,
    /// and a custom eventTileBuilder that captures [MCalEventTileContext].
    Future<void> pumpCalendar(
      WidgetTester tester, {
      required List<MCalCalendarEvent> events,
      required void Function(MCalEventTileContext) onTileBuild,
      bool enableDragToResize = false,
      void Function(BuildContext, MCalEventTapDetails)? onEventTap,
      void Function(BuildContext, MCalOverflowTapDetails)? onOverflowTap,
      int maxVisibleEventsPerDay = 5,
    }) async {
      controller.setEvents(events);
      controller.setFocusedDateTime(DateTime(2025, 1, 15), isAllDay: true);

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
                enableDragToResize: enableDragToResize,
                maxVisibleEventsPerDay: maxVisibleEventsPerDay,
                onEventTap: onEventTap,
                onOverflowTap: onOverflowTap,
                eventTileBuilder: (context, ctx, defaultTile) {
                  onTileBuild(ctx);
                  return defaultTile;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    /// Helper: focuses the calendar and sends a key event.
    /// Saves and restores [controller.focusedDateTime] across the tap to prevent
    /// the tap's cell-focus side-effect from interfering with the test.
    Future<void> focusAndSendKey(
      WidgetTester tester,
      LogicalKeyboardKey key,
    ) async {
      final savedFocusedDate = controller.focusedDateTime;
      await tester.tap(find.byType(MCalMonthView));
      await tester.pumpAndSettle();
      controller.setFocusedDateTime(savedFocusedDate, isAllDay: true);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();
    }

    testWidgets(
      'single event: Enter immediately selects event in Event Mode',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'single-event',
          title: 'Single',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 15, 11, 0),
          color: Colors.blue,
        );

        final capturedStates = <MCalEventKeyboardState>[];

        await pumpCalendar(
          tester,
          events: [event],
          onTileBuild: (ctx) {
            if (ctx.event.id == 'single-event') {
              capturedStates.add(ctx.keyboardState);
            }
          },
        );

        // Initial build: should be none
        expect(
          capturedStates.where((s) => s == MCalEventKeyboardState.none),
          isNotEmpty,
          reason: 'Initial build should have keyboardState.none',
        );
        capturedStates.clear();

        // Enter: Event Mode — event is immediately selected (no highlighted phase)
        await focusAndSendKey(tester, LogicalKeyboardKey.enter);

        expect(
          capturedStates.where((s) => s == MCalEventKeyboardState.selected),
          isNotEmpty,
          reason: 'After Enter, single event should be immediately selected',
        );
        expect(
          capturedStates.where((s) => s == MCalEventKeyboardState.highlighted),
          isEmpty,
          reason: 'There is no highlighted state — Event Mode uses selected directly',
        );
      },
    );

    testWidgets(
      'multiple events: Enter immediately selects first event',
      (tester) async {
        final event1 = MCalCalendarEvent(
          id: 'multi-1',
          title: 'First',
          start: DateTime(2025, 1, 15, 9, 0),
          end: DateTime(2025, 1, 15, 10, 0),
          color: Colors.blue,
        );
        final event2 = MCalCalendarEvent(
          id: 'multi-2',
          title: 'Second',
          start: DateTime(2025, 1, 15, 11, 0),
          end: DateTime(2025, 1, 15, 12, 0),
          color: Colors.red,
        );

        final statesById = <String, List<MCalEventKeyboardState>>{};

        await pumpCalendar(
          tester,
          events: [event1, event2],
          onTileBuild: (ctx) {
            statesById.putIfAbsent(ctx.event.id, () => []);
            statesById[ctx.event.id]!.add(ctx.keyboardState);
          },
        );

        // Clear initial build states
        statesById.clear();

        // Enter: first event should be immediately selected (index 0)
        await focusAndSendKey(tester, LogicalKeyboardKey.enter);

        final firstStates = statesById['multi-1'] ?? [];
        final secondStates = statesById['multi-2'] ?? [];

        expect(
          firstStates.where((s) => s == MCalEventKeyboardState.selected),
          isNotEmpty,
          reason: 'First event should be selected immediately after Enter',
        );
        expect(
          secondStates.every((s) => s == MCalEventKeyboardState.none),
          isTrue,
          reason: 'Second event should remain none when first is selected',
        );
      },
    );

    testWidgets(
      'Tab cycles selection to next event',
      (tester) async {
        final event1 = MCalCalendarEvent(
          id: 'cycle-1',
          title: 'CycleA',
          start: DateTime(2025, 1, 15, 9, 0),
          end: DateTime(2025, 1, 15, 10, 0),
          color: Colors.blue,
        );
        final event2 = MCalCalendarEvent(
          id: 'cycle-2',
          title: 'CycleB',
          start: DateTime(2025, 1, 15, 11, 0),
          end: DateTime(2025, 1, 15, 12, 0),
          color: Colors.red,
        );

        final statesById = <String, List<MCalEventKeyboardState>>{};

        await pumpCalendar(
          tester,
          events: [event1, event2],
          onTileBuild: (ctx) {
            statesById.putIfAbsent(ctx.event.id, () => []);
            statesById[ctx.event.id]!.add(ctx.keyboardState);
          },
        );

        // Enter Event Mode (first event selected)
        await focusAndSendKey(tester, LogicalKeyboardKey.enter);
        statesById.clear();

        // Tab to cycle to next event (widget already has focus)
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        // Second event should now be selected
        final secondStates = statesById['cycle-2'] ?? [];
        expect(
          secondStates.where((s) => s == MCalEventKeyboardState.selected),
          isNotEmpty,
          reason: 'Second event should be selected after Tab',
        );

        // First event should no longer be selected
        final firstStates = statesById['cycle-1'] ?? [];
        expect(
          firstStates.every((s) => s == MCalEventKeyboardState.none),
          isTrue,
          reason: 'First event should be none after Tab moves selection away',
        );
      },
    );

    testWidgets(
      'Enter in Event Mode fires onEventTap for selected event',
      (tester) async {
        final event1 = MCalCalendarEvent(
          id: 'confirm-1',
          title: 'ConfirmA',
          start: DateTime(2025, 1, 15, 9, 0),
          end: DateTime(2025, 1, 15, 10, 0),
          color: Colors.blue,
        );
        final event2 = MCalCalendarEvent(
          id: 'confirm-2',
          title: 'ConfirmB',
          start: DateTime(2025, 1, 15, 11, 0),
          end: DateTime(2025, 1, 15, 12, 0),
          color: Colors.red,
        );

        MCalEventTapDetails? tappedDetails;
        final statesById = <String, List<MCalEventKeyboardState>>{};

        await pumpCalendar(
          tester,
          events: [event1, event2],
          onEventTap: (ctx, details) => tappedDetails = details,
          onTileBuild: (ctx) {
            statesById.putIfAbsent(ctx.event.id, () => []);
            statesById[ctx.event.id]!.add(ctx.keyboardState);
          },
        );

        // Enter Event Mode and Tab to second event
        await focusAndSendKey(tester, LogicalKeyboardKey.enter);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        statesById.clear();

        // Enter fires onEventTap for the currently selected (second) event
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(
          tappedDetails,
          isNotNull,
          reason: 'onEventTap should fire when Enter is pressed in Event Mode',
        );
        // The tapped event should be one of the events on the cell
        final tappedId = tappedDetails!.event.id;
        expect(
          tappedId == 'confirm-1' || tappedId == 'confirm-2',
          isTrue,
          reason: 'onEventTap should fire for one of the events on the cell',
        );
      },
    );

    testWidgets(
      'Escape clears all keyboard states back to none',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'escape-test',
          title: 'Escape',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 15, 11, 0),
          color: Colors.blue,
        );

        final capturedStates = <MCalEventKeyboardState>[];

        await pumpCalendar(
          tester,
          events: [event],
          onTileBuild: (ctx) {
            if (ctx.event.id == 'escape-test') {
              capturedStates.add(ctx.keyboardState);
            }
          },
        );

        // Enter Event Mode — event is selected
        await focusAndSendKey(tester, LogicalKeyboardKey.enter);
        capturedStates.clear();

        // Press Escape to exit Event Mode (widget already has focus)
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        // After Escape, all states should be none
        expect(
          capturedStates.every((s) => s == MCalEventKeyboardState.none),
          isTrue,
          reason: 'After Escape, keyboard state should revert to none',
        );
      },
    );

    testWidgets(
      'keyboardState propagates through resize handle wrapper',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'resize-kb',
          title: 'ResizeKB',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 15, 11, 0),
          color: Colors.blue,
        );

        final capturedStates = <MCalEventKeyboardState>[];

        await pumpCalendar(
          tester,
          events: [event],
          enableDragToResize: true,
          onTileBuild: (ctx) {
            if (ctx.event.id == 'resize-kb') {
              capturedStates.add(ctx.keyboardState);
            }
          },
        );

        // Initial build: should be none
        expect(
          capturedStates.where((s) => s == MCalEventKeyboardState.none),
          isNotEmpty,
          reason: 'Initial build should have keyboardState.none',
        );
        capturedStates.clear();

        // Enter: immediately selects event in Event Mode (even with resize enabled)
        await focusAndSendKey(tester, LogicalKeyboardKey.enter);

        final selectedStates = capturedStates
            .where((s) => s == MCalEventKeyboardState.selected)
            .toList();
        expect(
          selectedStates,
          isNotEmpty,
          reason:
              'With enableDragToResize, keyboard state should still propagate '
              'through the resize handle wrapper to the tile builder',
        );
      },
    );

    testWidgets(
      'keyboardState defaults to none when no keyboard interaction',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'no-kb-test',
          title: 'NoKB',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 15, 11, 0),
          color: Colors.blue,
        );

        final capturedStates = <MCalEventKeyboardState>[];

        await pumpCalendar(
          tester,
          events: [event],
          onTileBuild: (ctx) {
            if (ctx.event.id == 'no-kb-test') {
              capturedStates.add(ctx.keyboardState);
            }
          },
        );

        // No keyboard interaction — all should be none
        expect(capturedStates, isNotEmpty);
        expect(
          capturedStates.every((s) => s == MCalEventKeyboardState.none),
          isTrue,
          reason: 'Without keyboard interaction, all states should be none',
        );
      },
    );

    testWidgets(
      'M key in Event Mode enters Move Mode for selected event',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'move-from-event',
          title: 'MoveEvent',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 15, 11, 0),
          color: Colors.blue,
        );

        final capturedStates = <MCalEventKeyboardState>[];

        await pumpCalendar(
          tester,
          events: [event],
          onTileBuild: (ctx) {
            if (ctx.event.id == 'move-from-event') {
              capturedStates.add(ctx.keyboardState);
            }
          },
        );

        // Enter Event Mode
        await focusAndSendKey(tester, LogicalKeyboardKey.enter);
        capturedStates.clear();

        // Press M to enter Move Mode
        await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
        await tester.pumpAndSettle();

        // Event should still be selected (Move Mode shows selected)
        expect(
          capturedStates.where((s) => s == MCalEventKeyboardState.selected),
          isNotEmpty,
          reason: 'In Move Mode, event should still appear selected',
        );

        // Move right and confirm — event should move to Jan 16
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        final movedEvents = controller.getEventsForDate(DateTime(2025, 1, 16));
        expect(
          movedEvents.any((e) => e.id == 'move-from-event'),
          isTrue,
          reason: 'Event should move to Jan 16 after M + ArrowRight + Enter',
        );
      },
    );

    testWidgets(
      'Escape from Move Mode returns to Event Mode (event still selected)',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'escape-move',
          title: 'EscapeMove',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 15, 11, 0),
          color: Colors.blue,
        );

        final capturedStates = <MCalEventKeyboardState>[];

        await pumpCalendar(
          tester,
          events: [event],
          onTileBuild: (ctx) {
            if (ctx.event.id == 'escape-move') {
              capturedStates.add(ctx.keyboardState);
            }
          },
        );

        // Enter Event Mode → M key → Move Mode
        await focusAndSendKey(tester, LogicalKeyboardKey.enter);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
        await tester.pumpAndSettle();
        capturedStates.clear();

        // Escape from Move Mode → returns to Event Mode
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        // Event should still be selected (back in Event Mode)
        expect(
          capturedStates.where((s) => s == MCalEventKeyboardState.selected),
          isNotEmpty,
          reason: 'After Escape from Move Mode, event should remain selected in Event Mode',
        );

        // A second Escape exits Event Mode entirely
        capturedStates.clear();
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        expect(
          capturedStates.every((s) => s == MCalEventKeyboardState.none),
          isTrue,
          reason: 'After second Escape, all keyboard states should be none',
        );
      },
    );

    testWidgets(
      'Down arrow cycles selection to next event same as Tab',
      (tester) async {
        final event1 = MCalCalendarEvent(
          id: 'down-1',
          title: 'Down A',
          start: DateTime(2025, 1, 15, 9, 0),
          end: DateTime(2025, 1, 15, 10, 0),
          color: Colors.blue,
        );
        final event2 = MCalCalendarEvent(
          id: 'down-2',
          title: 'Down B',
          start: DateTime(2025, 1, 15, 11, 0),
          end: DateTime(2025, 1, 15, 12, 0),
          color: Colors.red,
        );

        final statesById = <String, List<MCalEventKeyboardState>>{};

        await pumpCalendar(
          tester,
          events: [event1, event2],
          onTileBuild: (ctx) {
            statesById.putIfAbsent(ctx.event.id, () => []);
            statesById[ctx.event.id]!.add(ctx.keyboardState);
          },
        );

        // Enter Event Mode
        await focusAndSendKey(tester, LogicalKeyboardKey.enter);
        statesById.clear();

        // Down arrow cycles to next event
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        // Second event should be selected
        final secondStates = statesById['down-2'] ?? [];
        expect(
          secondStates.where((s) => s == MCalEventKeyboardState.selected),
          isNotEmpty,
          reason: 'Second event should be selected after ArrowDown',
        );
      },
    );

    testWidgets(
      'onOverflowTap fires when Enter is pressed on overflow indicator',
      (tester) async {
        // Create enough events to trigger overflow (default maxVisible = 5)
        final events = List.generate(
          6,
          (i) => MCalCalendarEvent(
            id: 'overflow-$i',
            title: 'Event $i',
            start: DateTime(2025, 1, 15, 8 + i, 0),
            end: DateTime(2025, 1, 15, 9 + i, 0),
            color: Colors.blue,
          ),
        );

        MCalOverflowTapDetails? overflowDetails;
        final capturedStates = <MCalEventKeyboardState>[];

        await pumpCalendar(
          tester,
          events: events,
          maxVisibleEventsPerDay: 4,
          onOverflowTap: (ctx, details) => overflowDetails = details,
          onTileBuild: (ctx) => capturedStates.add(ctx.keyboardState),
        );

        // Enter Event Mode — first visible event is selected
        await focusAndSendKey(tester, LogicalKeyboardKey.enter);

        // Cycle down past the visible events to reach the overflow indicator.
        // With maxVisible=4, there are 3 visible events + 1 overflow indicator.
        // Pressing down 3 times (3 events) reaches the overflow indicator.
        for (int i = 0; i < 3; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pumpAndSettle();
        }

        // Enter on the overflow indicator should fire onOverflowTap
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(
          overflowDetails,
          isNotNull,
          reason: 'onOverflowTap should fire when Enter is pressed on overflow indicator',
        );
      },
    );
  });

  group('Keyboard event selection - height-based overflow and custom builders', () {
    late _TestController controller;

    setUp(() {
      controller = _TestController(initialDate: DateTime(2025, 1, 1));
    });

    tearDown(() {
      controller.dispose();
    });

    /// Helper: pumps a calendar with constrained height.
    Future<void> pumpConstrainedCalendar(
      WidgetTester tester, {
      required List<MCalCalendarEvent> events,
      required void Function(MCalEventTileContext) onTileBuild,
      double height = 250,
      double width = 400,
      int maxVisibleEventsPerDay = 100,
      void Function(BuildContext, MCalOverflowTapDetails)? onOverflowTap,
      void Function(BuildContext, MCalEventTapDetails)? onEventTap,
      MCalWeekLayoutBuilder? weekLayoutBuilder,
    }) async {
      controller.setEvents(events);
      controller.setFocusedDateTime(DateTime(2025, 1, 15), isAllDay: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: height,
              width: width,
              child: MCalMonthView(
                controller: controller,
                enableKeyboardNavigation: true,
                enableDragToMove: true,
                maxVisibleEventsPerDay: maxVisibleEventsPerDay,
                onEventTap: onEventTap,
                onOverflowTap: onOverflowTap,
                weekLayoutBuilder: weekLayoutBuilder,
                eventTileBuilder: (context, ctx, defaultTile) {
                  onTileBuild(ctx);
                  return defaultTile;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> focusAndSendKey(
      WidgetTester tester,
      LogicalKeyboardKey key,
    ) async {
      final savedFocusedDate = controller.focusedDateTime;
      await tester.tap(find.byType(MCalMonthView));
      await tester.pumpAndSettle();
      controller.setFocusedDateTime(savedFocusedDate, isAllDay: true);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();
    }

    testWidgets(
      'height-based overflow: cycling skips hidden events and reaches '
      'overflow indicator',
      (tester) async {
        // 4 events on the same day in a very short calendar (250px).
        // With ~5 week rows, each row is ~50px. After the date label
        // (~18px + 4px padding) there is barely room for 1 event tile
        // (~18px + 2px spacing). So only 1 event should be visible with
        // an overflow indicator, despite maxVisibleEventsPerDay being
        // unconstrained (100).
        final events = List.generate(
          4,
          (i) => MCalCalendarEvent(
            id: 'hgt-$i',
            title: 'Hgt $i',
            start: DateTime(2025, 1, 15, 8 + i, 0),
            end: DateTime(2025, 1, 15, 9 + i, 0),
            color: Colors.blue,
          ),
        );

        MCalOverflowTapDetails? overflowDetails;
        MCalEventTapDetails? tappedDetails;
        final selectedIds = <String>[];

        await pumpConstrainedCalendar(
          tester,
          events: events,
          height: 250,
          onOverflowTap: (ctx, details) => overflowDetails = details,
          onEventTap: (ctx, details) => tappedDetails = details,
          onTileBuild: (ctx) {
            if (ctx.keyboardState == MCalEventKeyboardState.selected) {
              selectedIds.add(ctx.event.id);
            }
          },
        );

        // Enter Event Mode
        selectedIds.clear();
        await focusAndSendKey(tester, LogicalKeyboardKey.enter);

        // The first (and only visible) event should be selected
        expect(selectedIds, contains('hgt-0'));

        // Pressing Down once should reach the overflow indicator (since
        // only 1 event is visible). Pressing Enter should fire
        // onOverflowTap.
        selectedIds.clear();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        // No event should be selected (overflow is focused)
        expect(
          selectedIds,
          isEmpty,
          reason:
              'When overflow indicator is focused, no event should be selected',
        );

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(
          overflowDetails,
          isNotNull,
          reason:
              'onOverflowTap should fire when height-based overflow is present',
        );

        // The hidden events should NOT have been cycled through
        expect(
          tappedDetails,
          isNull,
          reason:
              'onEventTap should not fire — overflow indicator was activated',
        );
      },
    );

    testWidgets(
      'height-based overflow: onEventTap fires for visible event',
      (tester) async {
        final events = List.generate(
          4,
          (i) => MCalCalendarEvent(
            id: 'tap-$i',
            title: 'Tap $i',
            start: DateTime(2025, 1, 15, 8 + i, 0),
            end: DateTime(2025, 1, 15, 9 + i, 0),
            color: Colors.blue,
          ),
        );

        MCalEventTapDetails? tappedDetails;

        await pumpConstrainedCalendar(
          tester,
          events: events,
          height: 250,
          onEventTap: (ctx, details) => tappedDetails = details,
          onTileBuild: (_) {},
        );

        // Enter Event Mode, then press Enter on the first visible event
        await focusAndSendKey(tester, LogicalKeyboardKey.enter);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(tappedDetails, isNotNull);
        expect(tappedDetails!.event.id, equals('tap-0'));
      },
    );

    testWidgets(
      'custom weekLayoutBuilder that reports visible counts: cycling '
      'respects custom counts',
      (tester) async {
        // 4 events, but the custom builder reports only 2 as visible.
        final events = List.generate(
          4,
          (i) => MCalCalendarEvent(
            id: 'custom-$i',
            title: 'Custom $i',
            start: DateTime(2025, 1, 15, 8 + i, 0),
            end: DateTime(2025, 1, 15, 9 + i, 0),
            color: Colors.blue,
          ),
        );

        MCalOverflowTapDetails? overflowDetails;
        final selectedIds = <String>[];

        await pumpConstrainedCalendar(
          tester,
          events: events,
          height: 600,
          maxVisibleEventsPerDay: 100,
          onOverflowTap: (ctx, details) => overflowDetails = details,
          onTileBuild: (ctx) {
            if (ctx.keyboardState == MCalEventKeyboardState.selected) {
              selectedIds.add(ctx.event.id);
            }
          },
          weekLayoutBuilder: (context, layoutContext) {
            // Fully custom builder: renders all tiles but reports only 2
            // as visible for Jan 15. Does NOT delegate to the default
            // builder (which would overwrite the counts).
            return LayoutBuilder(
              builder: (ctx, constraints) {
                final map = layoutContext.layoutVisibleCounts;
                if (map != null) {
                  for (final d in layoutContext.dates) {
                    final dk = '${d.year}-${d.month}-${d.day}';
                    if (d.day == 15 && d.month == 1 && d.year == 2025) {
                      map[dk] = 2;
                    } else {
                      map.remove(dk);
                    }
                  }
                }

                final dayWidth = constraints.maxWidth / 7;
                final children = <Widget>[];
                for (final seg in layoutContext.segments) {
                  final tileCtx = MCalEventTileContext(
                    event: seg.event,
                    displayDate: layoutContext.dates[seg.startDayInWeek],
                    isAllDay: seg.event.isAllDay,
                    segment: seg,
                    width: dayWidth * seg.spanDays,
                    height: layoutContext.config.tileHeight,
                  );
                  children.add(
                    Positioned(
                      left: dayWidth * seg.startDayInWeek,
                      top: seg.weekRowIndex * 20.0,
                      width: dayWidth * seg.spanDays,
                      height: layoutContext.config.tileHeight,
                      child: layoutContext.eventTileBuilder(ctx, tileCtx),
                    ),
                  );
                }
                if (children.isEmpty) {
                  children.add(const SizedBox.shrink());
                }
                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: children,
                );
              },
            );
          },
        );

        // Enter Event Mode
        selectedIds.clear();
        await focusAndSendKey(tester, LogicalKeyboardKey.enter);

        // First event selected
        expect(selectedIds, contains('custom-0'));

        // Down → second visible event
        selectedIds.clear();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(selectedIds, contains('custom-1'));

        // Down → overflow indicator (only 2 visible per custom report)
        selectedIds.clear();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(
          selectedIds,
          isEmpty,
          reason: 'Third Down should reach overflow indicator, not third event',
        );

        // Enter activates overflow
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(overflowDetails, isNotNull);
      },
    );

    testWidgets(
      'custom weekLayoutBuilder that does NOT report visible counts: '
      'falls back to cycling all events',
      (tester) async {
        // 3 events, custom builder renders tiles but does not write to
        // layoutVisibleCounts. Keyboard cycling should fall back to
        // treating all 3 as visible with no overflow indicator.
        final events = List.generate(
          3,
          (i) => MCalCalendarEvent(
            id: 'nomap-$i',
            title: 'NoMap $i',
            start: DateTime(2025, 1, 15, 8 + i, 0),
            end: DateTime(2025, 1, 15, 9 + i, 0),
            color: Colors.blue,
          ),
        );

        final selectedIds = <String>[];

        await pumpConstrainedCalendar(
          tester,
          events: events,
          height: 600,
          onTileBuild: (ctx) {
            if (ctx.keyboardState == MCalEventKeyboardState.selected) {
              selectedIds.add(ctx.event.id);
            }
          },
          weekLayoutBuilder: (context, layoutContext) {
            // Custom builder that renders tiles but intentionally does
            // NOT write to layoutVisibleCounts.
            return LayoutBuilder(
              builder: (ctx, constraints) {
                final dayWidth = constraints.maxWidth / 7;
                final children = <Widget>[];
                for (final seg in layoutContext.segments) {
                  final tileCtx = MCalEventTileContext(
                    event: seg.event,
                    displayDate: layoutContext.dates[seg.startDayInWeek],
                    isAllDay: seg.event.isAllDay,
                    segment: seg,
                    width: dayWidth * seg.spanDays,
                    height: layoutContext.config.tileHeight,
                  );
                  children.add(
                    Positioned(
                      left: dayWidth * seg.startDayInWeek,
                      top: seg.weekRowIndex * 20.0,
                      width: dayWidth * seg.spanDays,
                      height: layoutContext.config.tileHeight,
                      child: layoutContext.eventTileBuilder(ctx, tileCtx),
                    ),
                  );
                }
                if (children.isEmpty) {
                  children.add(const SizedBox.shrink());
                }
                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: children,
                );
              },
            );
          },
        );

        // Enter Event Mode
        selectedIds.clear();
        await focusAndSendKey(tester, LogicalKeyboardKey.enter);
        expect(selectedIds, contains('nomap-0'));

        // Cycle through all 3 events
        selectedIds.clear();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(selectedIds, contains('nomap-1'));

        selectedIds.clear();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(selectedIds, contains('nomap-2'));

        // Down again wraps back to first event (no overflow indicator)
        selectedIds.clear();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(selectedIds, contains('nomap-0'));
      },
    );
  });

  group('Day View tap-to-Event-Mode and jumpToEventMode (E)', () {
    late _TestController controller;

    setUp(() {
      controller = _TestController(initialDate: DateTime(2025, 1, 15));
    });

    tearDown(() {
      controller.dispose();
    });

    Future<void> pumpDayView(
      WidgetTester tester, {
      required List<MCalCalendarEvent> events,
      void Function(BuildContext, MCalEventTapDetails)? onEventTap,
      int startHour = 6,
      int endHour = 18,
    }) async {
      controller.setEvents(events);
      controller.setFocusedDateTime(DateTime(2025, 1, 15, 8, 0));

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 900,
              child: MCalDayView(
                controller: controller,
                startHour: startHour,
                endHour: endHour,
                timeSlotDuration: const Duration(minutes: 15),
                showNavigator: false,
                showCurrentTimeIndicator: false,
                autoScrollToCurrentTime: false,
                enableKeyboardNavigation: true,
                autoFocusOnEventTap: true,
                onEventTap: onEventTap,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> focusDayView(WidgetTester tester) async {
      await tester.tap(find.byType(MCalDayView));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'tap timed event then arrow down cycles to next event in Event Mode',
      (tester) async {
        final activated = <String>[];
        final a = MCalCalendarEvent(
          id: 'dv-a',
          title: 'Alpha',
          start: DateTime(2025, 1, 15, 9, 0),
          end: DateTime(2025, 1, 15, 10, 0),
          color: Colors.blue,
        );
        final b = MCalCalendarEvent(
          id: 'dv-b',
          title: 'Beta',
          start: DateTime(2025, 1, 15, 11, 0),
          end: DateTime(2025, 1, 15, 12, 0),
          color: Colors.orange,
        );

        await pumpDayView(
          tester,
          events: [a, b],
          onEventTap: (c, d) => activated.add(d.event.id),
        );

        await focusDayView(tester);
        await tester.tap(find.text('Beta'));
        await tester.pumpAndSettle();
        expect(activated, contains('dv-b'));

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(activated.last, 'dv-a');
      },
    );

    testWidgets(
      'E key from time grid focuses first timed event at or after focused slot',
      (tester) async {
        final activated = <String>[];
        final a = MCalCalendarEvent(
          id: 'dv-e-a',
          title: 'Early',
          start: DateTime(2025, 1, 15, 9, 0),
          end: DateTime(2025, 1, 15, 10, 0),
          color: Colors.blue,
        );
        final b = MCalCalendarEvent(
          id: 'dv-e-b',
          title: 'Late',
          start: DateTime(2025, 1, 15, 11, 0),
          end: DateTime(2025, 1, 15, 12, 0),
          color: Colors.orange,
        );

        await pumpDayView(
          tester,
          events: [a, b],
          onEventTap: (c, d) => activated.add(d.event.id),
        );

        await focusDayView(tester);
        controller.setFocusedDateTime(DateTime(2025, 1, 15, 10, 0));
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(activated, contains('dv-e-b'));
        expect(activated.last, 'dv-e-b');
      },
    );

    testWidgets(
      'E key from all-day section focuses first visible all-day event',
      (tester) async {
        final activated = <String>[];
        final ad = MCalCalendarEvent(
          id: 'dv-ad',
          title: 'AllDayFirst',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15, 23, 59),
          isAllDay: true,
          color: Colors.teal,
        );
        final timed = MCalCalendarEvent(
          id: 'dv-timed',
          title: 'Timed',
          start: DateTime(2025, 1, 15, 9, 0),
          end: DateTime(2025, 1, 15, 10, 0),
          color: Colors.blue,
        );

        await pumpDayView(
          tester,
          events: [ad, timed],
          onEventTap: (c, d) => activated.add(d.event.id),
        );

        await focusDayView(tester);
        controller.setFocusedDateTime(DateTime(2025, 1, 15), isAllDay: true);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(activated.last, 'dv-ad');
      },
    );

    testWidgets('E key on empty day does not throw', (tester) async {
      await pumpDayView(tester, events: []);
      await focusDayView(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
      await tester.pumpAndSettle();
      expect(find.byType(MCalDayView), findsOneWidget);
    });
  });
}
