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
    }) async {
      controller.setEvents(events);
      controller.setFocusedDate(DateTime(2025, 1, 15));

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
    Future<void> focusAndSendKey(
      WidgetTester tester,
      LogicalKeyboardKey key,
    ) async {
      await tester.tap(find.byType(MCalMonthView));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();
    }

    testWidgets(
      'single event: Enter selects immediately, tile receives selected state',
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

        // Press Enter to select the event (single event = immediate selection)
        await focusAndSendKey(tester, LogicalKeyboardKey.enter);

        // After Enter on a single-event cell, the event should be selected
        final selectedStates = capturedStates
            .where((s) => s == MCalEventKeyboardState.selected)
            .toList();
        expect(
          selectedStates,
          isNotEmpty,
          reason: 'After Enter, single event should receive selected state',
        );
      },
    );

    testWidgets(
      'multiple events: Enter enters cycling, first event is highlighted',
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

        // Press Enter to enter event selection cycling mode
        await focusAndSendKey(tester, LogicalKeyboardKey.enter);

        // First event should be highlighted (index 0)
        final firstStates = statesById['multi-1'] ?? [];
        final secondStates = statesById['multi-2'] ?? [];

        expect(
          firstStates.where((s) => s == MCalEventKeyboardState.highlighted),
          isNotEmpty,
          reason: 'First event should be highlighted after Enter on multi-event cell',
        );
        // Second event should remain none
        expect(
          secondStates.every((s) => s == MCalEventKeyboardState.none),
          isTrue,
          reason: 'Second event should remain none when first is highlighted',
        );
      },
    );

    testWidgets(
      'Tab cycles highlight to next event',
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

        // Enter selection mode
        await focusAndSendKey(tester, LogicalKeyboardKey.enter);
        statesById.clear();

        // Tab to cycle to next event
        await focusAndSendKey(tester, LogicalKeyboardKey.tab);

        // Second event should now be highlighted
        final secondStates = statesById['cycle-2'] ?? [];
        expect(
          secondStates.where((s) => s == MCalEventKeyboardState.highlighted),
          isNotEmpty,
          reason: 'Second event should be highlighted after Tab',
        );

        // First event should no longer be highlighted
        final firstStates = statesById['cycle-1'] ?? [];
        expect(
          firstStates.every((s) => s == MCalEventKeyboardState.none),
          isTrue,
          reason: 'First event should be none after Tab moves highlight away',
        );
      },
    );

    testWidgets(
      'Enter during cycling confirms selection (selected state)',
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

        final statesById = <String, List<MCalEventKeyboardState>>{};

        await pumpCalendar(
          tester,
          events: [event1, event2],
          onTileBuild: (ctx) {
            statesById.putIfAbsent(ctx.event.id, () => []);
            statesById[ctx.event.id]!.add(ctx.keyboardState);
          },
        );

        // Enter selection mode, Tab to second event, Enter to confirm
        await focusAndSendKey(tester, LogicalKeyboardKey.enter);
        await focusAndSendKey(tester, LogicalKeyboardKey.tab);
        statesById.clear();

        await focusAndSendKey(tester, LogicalKeyboardKey.enter);

        // Second event should now be selected (confirmed for move)
        final secondStates = statesById['confirm-2'] ?? [];
        expect(
          secondStates.where((s) => s == MCalEventKeyboardState.selected),
          isNotEmpty,
          reason: 'Confirmed event should receive selected state',
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

        // Select the event
        await focusAndSendKey(tester, LogicalKeyboardKey.enter);
        capturedStates.clear();

        // Press Escape to cancel
        await focusAndSendKey(tester, LogicalKeyboardKey.escape);

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

        // Press Enter to select the event (single event = immediate selection)
        await focusAndSendKey(tester, LogicalKeyboardKey.enter);

        // After Enter, the event should be selected even with resize enabled
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
  });
}
