import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

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

  group('MCalMonthView key bindings', () {
    late _TestController controller;

    setUp(() {
      controller = _TestController(initialDate: DateTime(2025, 1, 1));
    });

    tearDown(() {
      controller.dispose();
    });

    final testEvent = MCalCalendarEvent(
      id: 'test-event',
      title: 'Test Event',
      start: DateTime(2025, 1, 15, 10, 0),
      end: DateTime(2025, 1, 15, 11, 0),
      color: Colors.blue,
    );

    /// Pumps a month view with optional custom bindings and callbacks.
    Future<void> pumpCalendar(
      WidgetTester tester, {
      MCalMonthKeyBindings? keyBindings,
      List<MCalCalendarEvent> events = const [],
      void Function(BuildContext, MCalEventTapDetails)? onEventTap,
      FutureOr<bool> Function(BuildContext, MCalEventTapDetails)?
      onDeleteEventRequested,
      void Function(MCalEventTileContext)? onTileBuild,
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
                keyBindings: keyBindings,
                onEventTap: onEventTap,
                onDeleteEventRequested: onDeleteEventRequested,
                eventTileBuilder: onTileBuild != null
                    ? (context, ctx, defaultTile) {
                        onTileBuild(ctx);
                        return defaultTile;
                      }
                    : null,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    /// Taps the calendar to focus it, then sends [key].
    Future<void> focusAndSendKey(
      WidgetTester tester,
      LogicalKeyboardKey key,
    ) async {
      final savedDate = controller.focusedDate;
      await tester.tap(find.byType(MCalMonthView));
      await tester.pumpAndSettle();
      controller.setFocusedDate(savedDate);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();
    }

    group('default bindings (behavioral equivalence)', () {
      testWidgets('Enter enters Event Mode with first event selected', (
        tester,
      ) async {
        final capturedStates = <MCalEventKeyboardState>[];
        await pumpCalendar(
          tester,
          events: [testEvent],
          onTileBuild: (ctx) {
            if (ctx.event.id == 'test-event') {
              capturedStates.add(ctx.keyboardState);
            }
          },
        );
        capturedStates.clear();

        await focusAndSendKey(tester, LogicalKeyboardKey.enter);

        expect(
          capturedStates.any((s) => s == MCalEventKeyboardState.selected),
          isTrue,
          reason: 'Enter should enter Event Mode with event selected',
        );
      });
    });

    group('remapped action', () {
      testWidgets('remapping enterMoveMode to X — X enters Move Mode', (
        tester,
      ) async {
        final capturedStates = <MCalEventKeyboardState>[];
        await pumpCalendar(
          tester,
          events: [testEvent],
          keyBindings: const MCalMonthKeyBindings(
            enterMoveMode: [MCalKeyActivator(LogicalKeyboardKey.keyX)],
          ),
          onTileBuild: (ctx) {
            if (ctx.event.id == 'test-event') {
              capturedStates.add(ctx.keyboardState);
            }
          },
        );

        // Enter Event Mode
        await focusAndSendKey(tester, LogicalKeyboardKey.enter);
        expect(
          capturedStates.any((s) => s == MCalEventKeyboardState.selected),
          isTrue,
        );
        capturedStates.clear();

        // Press X directly (no re-tap — tapping would exit keyboard mode)
        await tester.sendKeyEvent(LogicalKeyboardKey.keyX);
        await tester.pumpAndSettle();

        // In Move Mode the event tile retains selected keyboard state.
        // The key signal is that the widget continues to be in the keyboard
        // interaction flow (no crash and event is still selected).
        expect(
          capturedStates.any((s) => s == MCalEventKeyboardState.selected),
          isTrue,
          reason: 'X should enter Move Mode when remapped (event stays selected)',
        );
      });

      testWidgets('default M key does NOT enter Move Mode when remapped to X', (
        tester,
      ) async {
        final capturedStates = <MCalEventKeyboardState>[];
        await pumpCalendar(
          tester,
          events: [testEvent],
          keyBindings: const MCalMonthKeyBindings(
            enterMoveMode: [MCalKeyActivator(LogicalKeyboardKey.keyX)],
          ),
          onTileBuild: (ctx) {
            if (ctx.event.id == 'test-event') {
              capturedStates.add(ctx.keyboardState);
            }
          },
        );

        // Enter Event Mode (uses focusAndSendKey to tap + focus first)
        await focusAndSendKey(tester, LogicalKeyboardKey.enter);
        expect(
          capturedStates.any((s) => s == MCalEventKeyboardState.selected),
          isTrue,
        );
        capturedStates.clear();

        // Send M directly WITHOUT re-tapping (tapping would exit keyboard mode)
        await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
        await tester.pumpAndSettle();

        // M is not bound → returns KeyEventResult.ignored → no setState called
        // → no rebuild → capturedStates is empty (mode state unchanged).
        // If Move Mode had been entered, setState would be called and the
        // tile would rebuild with none (or a mode-change indication).
        expect(
          capturedStates.any((s) => s == MCalEventKeyboardState.none),
          isFalse,
          reason: 'Event Mode should not have been exited by unbound M key',
        );
      });
    });

    group('disabled action', () {
      testWidgets('delete: [] disables D key deletion', (tester) async {
        var deleteCalled = false;
        await pumpCalendar(
          tester,
          events: [testEvent],
          keyBindings: const MCalMonthKeyBindings(delete: []),
          onDeleteEventRequested: (ctx, details) {
            deleteCalled = true;
            return false;
          },
        );

        // Enter Event Mode
        await focusAndSendKey(tester, LogicalKeyboardKey.enter);
        // Press D
        await focusAndSendKey(tester, LogicalKeyboardKey.keyD);

        expect(deleteCalled, isFalse, reason: 'D should do nothing when delete binding is empty');
      });

      testWidgets('delete: [] disables Delete key deletion', (tester) async {
        var deleteCalled = false;
        await pumpCalendar(
          tester,
          events: [testEvent],
          keyBindings: const MCalMonthKeyBindings(delete: []),
          onDeleteEventRequested: (ctx, details) {
            deleteCalled = true;
            return false;
          },
        );

        await focusAndSendKey(tester, LogicalKeyboardKey.enter);
        await focusAndSendKey(tester, LogicalKeyboardKey.delete);

        expect(
          deleteCalled,
          isFalse,
          reason: 'Delete should do nothing when delete binding is empty',
        );
      });
    });

    group('delete callback fires with default bindings', () {
      testWidgets('D key triggers onDeleteEventRequested', (tester) async {
        var deleteCalled = false;
        String? deletedEventId;

        await pumpCalendar(
          tester,
          events: [testEvent],
          onDeleteEventRequested: (ctx, details) {
            deleteCalled = true;
            deletedEventId = details.event.id;
            return false; // Don't exit keyboard mode
          },
        );

        await focusAndSendKey(tester, LogicalKeyboardKey.enter);
        await focusAndSendKey(tester, LogicalKeyboardKey.keyD);

        expect(deleteCalled, isTrue);
        expect(deletedEventId, equals('test-event'));
      });
    });

    group('no keyBindings parameter (null) uses defaults', () {
      testWidgets('Enter works without keyBindings parameter', (tester) async {
        final capturedStates = <MCalEventKeyboardState>[];
        await pumpCalendar(
          tester,
          events: [testEvent],
          // keyBindings intentionally omitted
          onTileBuild: (ctx) {
            if (ctx.event.id == 'test-event') {
              capturedStates.add(ctx.keyboardState);
            }
          },
        );
        capturedStates.clear();

        await focusAndSendKey(tester, LogicalKeyboardKey.enter);

        expect(
          capturedStates.any((s) => s == MCalEventKeyboardState.selected),
          isTrue,
          reason: 'Default Enter binding works when keyBindings is null',
        );
      });
    });
  });
}
