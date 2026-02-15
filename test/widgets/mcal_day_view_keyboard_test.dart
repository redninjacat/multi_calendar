import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

/// Mock MCalEventController for Day View keyboard testing.
class MockMCalEventController extends MCalEventController {
  MockMCalEventController({super.initialDate});

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

  group('MCalDayView keyboard shortcuts', () {
    late MockMCalEventController controller;

    setUp(() {
      controller = MockMCalEventController(initialDate: testDate);
    });

    tearDown(() {
      controller.dispose();
    });

    /// Focus the day view and send a key with optional modifier.
    Future<void> focusAndSendKey(
      WidgetTester tester,
      LogicalKeyboardKey key, {
      bool meta = false,
      bool control = false,
    }) async {
      await tester.tap(find.byType(MCalDayView));
      await tester.pumpAndSettle();

      if (meta) {
        await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      }
      if (control) {
        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      }
      await tester.sendKeyEvent(key);
      if (control) {
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      }
      if (meta) {
        await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      }
      await tester.pumpAndSettle();
    }

    /// Send Delete or Backspace (no modifier).
    Future<void> sendDeleteKey(
      WidgetTester tester,
      LogicalKeyboardKey key,
    ) async {
      await tester.tap(find.byType(MCalDayView));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();
    }

    testWidgets('Cmd+N fires onCreateEventRequested', (tester) async {
      bool createFired = false;
      await tester.pumpWidget(
        MaterialApp(
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
                onCreateEventRequested: () => createFired = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await focusAndSendKey(tester, LogicalKeyboardKey.keyN, meta: true);

      expect(createFired, isTrue);
    });

    testWidgets('Ctrl+N fires onCreateEventRequested', (tester) async {
      bool createFired = false;
      await tester.pumpWidget(
        MaterialApp(
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
                onCreateEventRequested: () => createFired = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await focusAndSendKey(tester, LogicalKeyboardKey.keyN, control: true);

      expect(createFired, isTrue);
    });

    testWidgets('Cmd+D fires onDeleteEventRequested when event has focus', (
      tester,
    ) async {
      final event = MCalCalendarEvent(
        id: 'ev-1',
        title: 'Meeting',
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 11, 0),
      );
      controller.setMockEvents([event]);

      MCalCalendarEvent? deletedEvent;
      await tester.pumpWidget(
        MaterialApp(
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
                onDeleteEventRequested: (e) => deletedEvent = e,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap event to give it focus
      await tester.tap(find.text('Meeting'));
      await tester.pumpAndSettle();

      await focusAndSendKey(tester, LogicalKeyboardKey.keyD, meta: true);

      expect(deletedEvent, isNotNull);
      expect(deletedEvent!.id, equals('ev-1'));
    });

    testWidgets(
      'Delete key fires onDeleteEventRequested when event has focus',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'ev-del',
          title: 'Delete Me',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
        );
        controller.setMockEvents([event]);

        MCalCalendarEvent? deletedEvent;
        await tester.pumpWidget(
          MaterialApp(
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
                  onDeleteEventRequested: (e) => deletedEvent = e,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete Me'));
        await tester.pumpAndSettle();

        await sendDeleteKey(tester, LogicalKeyboardKey.delete);

        expect(deletedEvent, isNotNull);
        expect(deletedEvent!.title, equals('Delete Me'));
      },
    );

    testWidgets('Backspace fires onDeleteEventRequested when event has focus', (
      tester,
    ) async {
      final event = MCalCalendarEvent(
        id: 'ev-bs',
        title: 'Backspace Me',
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 11, 0),
      );
      controller.setMockEvents([event]);

      MCalCalendarEvent? deletedEvent;
      await tester.pumpWidget(
        MaterialApp(
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
                onDeleteEventRequested: (e) => deletedEvent = e,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Backspace Me'));
      await tester.pumpAndSettle();

      await sendDeleteKey(tester, LogicalKeyboardKey.backspace);

      expect(deletedEvent, isNotNull);
      expect(deletedEvent!.title, equals('Backspace Me'));
    });

    testWidgets('Cmd+E fires onEditEventRequested when event has focus', (
      tester,
    ) async {
      final event = MCalCalendarEvent(
        id: 'ev-edit',
        title: 'Edit Me',
        start: DateTime(2026, 2, 14, 10, 0),
        end: DateTime(2026, 2, 14, 11, 0),
      );
      controller.setMockEvents([event]);

      MCalCalendarEvent? editedEvent;
      await tester.pumpWidget(
        MaterialApp(
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
                onEditEventRequested: (e) => editedEvent = e,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit Me'));
      await tester.pumpAndSettle();

      await focusAndSendKey(tester, LogicalKeyboardKey.keyE, meta: true);

      expect(editedEvent, isNotNull);
      expect(editedEvent!.id, equals('ev-edit'));
    });

    testWidgets('onDeleteEventRequested does not fire when no event focused', (
      tester,
    ) async {
      // No events - tap anywhere won't focus an event
      controller.setMockEvents([]);

      bool deleteFired = false;
      await tester.pumpWidget(
        MaterialApp(
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
                onDeleteEventRequested: (_) => deleteFired = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Focus the view (tap) and press Delete - no event to delete
      await focusAndSendKey(tester, LogicalKeyboardKey.delete);

      expect(deleteFired, isFalse);
    });
  });

  group('MCalDayView keyboard navigation', () {
    late MockMCalEventController controller;

    setUp(() {
      controller = MockMCalEventController(initialDate: testDate);
    });

    tearDown(() {
      controller.dispose();
    });

    Future<void> focusAndSendKey(
      WidgetTester tester,
      LogicalKeyboardKey key,
    ) async {
      await tester.tap(find.byType(MCalDayView));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();
    }

    testWidgets('arrow up scrolls by time slot', (tester) async {
      final scrollController = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 400,
              child: MCalDayView(
                controller: controller,
                scrollController: scrollController,
                startHour: 8,
                endHour: 18,
                showNavigator: false,
                showCurrentTimeIndicator: false,
                autoScrollToCurrentTime: false,
                initialScrollTime: const TimeOfDay(hour: 12, minute: 0),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final offsetBefore = scrollController.offset;
      await focusAndSendKey(tester, LogicalKeyboardKey.arrowUp);
      final offsetAfter = scrollController.offset;

      expect(offsetAfter, lessThan(offsetBefore));
    });

    testWidgets('arrow down scrolls by time slot', (tester) async {
      final scrollController = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 400,
              child: MCalDayView(
                controller: controller,
                scrollController: scrollController,
                startHour: 8,
                endHour: 18,
                showNavigator: false,
                showCurrentTimeIndicator: false,
                autoScrollToCurrentTime: false,
                initialScrollTime: const TimeOfDay(hour: 9, minute: 0),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final offsetBefore = scrollController.offset;
      await focusAndSendKey(tester, LogicalKeyboardKey.arrowDown);
      final offsetAfter = scrollController.offset;

      expect(offsetAfter, greaterThan(offsetBefore));
    });

    testWidgets('Page Up scrolls by viewport', (tester) async {
      final scrollController = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 400,
              child: MCalDayView(
                controller: controller,
                scrollController: scrollController,
                startHour: 8,
                endHour: 18,
                showNavigator: false,
                showCurrentTimeIndicator: false,
                autoScrollToCurrentTime: false,
                initialScrollTime: const TimeOfDay(hour: 14, minute: 0),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final offsetBefore = scrollController.offset;
      await focusAndSendKey(tester, LogicalKeyboardKey.pageUp);
      final offsetAfter = scrollController.offset;

      expect(offsetAfter, lessThan(offsetBefore));
    });

    testWidgets('Page Down scrolls by viewport', (tester) async {
      final scrollController = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 400,
              child: MCalDayView(
                controller: controller,
                scrollController: scrollController,
                startHour: 8,
                endHour: 18,
                showNavigator: false,
                showCurrentTimeIndicator: false,
                autoScrollToCurrentTime: false,
                initialScrollTime: const TimeOfDay(hour: 9, minute: 0),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final offsetBefore = scrollController.offset;
      await focusAndSendKey(tester, LogicalKeyboardKey.pageDown);
      final offsetAfter = scrollController.offset;

      expect(offsetAfter, greaterThan(offsetBefore));
    });

    testWidgets('Home scrolls to start', (tester) async {
      final scrollController = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 400,
              child: MCalDayView(
                controller: controller,
                scrollController: scrollController,
                startHour: 8,
                endHour: 18,
                showNavigator: false,
                showCurrentTimeIndicator: false,
                autoScrollToCurrentTime: false,
                initialScrollTime: const TimeOfDay(hour: 14, minute: 0),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await focusAndSendKey(tester, LogicalKeyboardKey.home);

      expect(scrollController.offset, equals(0));
    });

    testWidgets('End scrolls to end', (tester) async {
      final scrollController = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 400,
              child: MCalDayView(
                controller: controller,
                scrollController: scrollController,
                startHour: 8,
                endHour: 18,
                showNavigator: false,
                showCurrentTimeIndicator: false,
                autoScrollToCurrentTime: false,
                initialScrollTime: const TimeOfDay(hour: 9, minute: 0),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final maxExtent = scrollController.position.maxScrollExtent;

      await focusAndSendKey(tester, LogicalKeyboardKey.end);

      expect(scrollController.offset, equals(maxExtent));
    });

    testWidgets('arrow left/right change day when showNavigator is true', (
      tester,
    ) async {
      controller.setMockEvents([]);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 600,
              child: MCalDayView(
                controller: controller,
                startHour: 8,
                endHour: 18,
                showNavigator: true,
                showCurrentTimeIndicator: false,
                autoScrollToCurrentTime: false,
                initialScrollTime: const TimeOfDay(hour: 9, minute: 0),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.displayDate, equals(DateTime(2026, 2, 14)));

      await focusAndSendKey(tester, LogicalKeyboardKey.arrowRight);
      expect(controller.displayDate, equals(DateTime(2026, 2, 15)));

      await focusAndSendKey(tester, LogicalKeyboardKey.arrowLeft);
      expect(controller.displayDate, equals(DateTime(2026, 2, 14)));
    });

    testWidgets('Tab navigates between events', (tester) async {
      controller.setMockEvents([
        MCalCalendarEvent(
          id: 'ev-1',
          title: 'First',
          start: DateTime(2026, 2, 14, 9, 0),
          end: DateTime(2026, 2, 14, 10, 0),
        ),
        MCalCalendarEvent(
          id: 'ev-2',
          title: 'Second',
          start: DateTime(2026, 2, 14, 11, 0),
          end: DateTime(2026, 2, 14, 12, 0),
        ),
      ]);

      MCalCalendarEvent? deletedEvent;
      await tester.pumpWidget(
        MaterialApp(
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
                onDeleteEventRequested: (e) => deletedEvent = e,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap first event to focus it
      await tester.tap(find.text('First'));
      await tester.pumpAndSettle();

      // Tab to next event - focus should move to Second
      await focusAndSendKey(tester, LogicalKeyboardKey.tab);

      // Delete should fire for Second (the now-focused event)
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.pumpAndSettle();

      expect(deletedEvent, isNotNull);
      expect(deletedEvent!.title, equals('Second'));
    });
  });

  group('MCalDayView focus state', () {
    late MockMCalEventController controller;

    setUp(() {
      controller = MockMCalEventController(initialDate: testDate);
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('tap on event gives it keyboard focus', (tester) async {
      controller.setMockEvents([
        MCalCalendarEvent(
          id: 'focus-ev',
          title: 'Focus Me',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
        ),
      ]);

      bool deleteFired = false;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
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
                onDeleteEventRequested: (_) => deleteFired = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on time legend first - no event focused, Delete should not fire
      await tester.tap(find.text('8 AM'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.pumpAndSettle();
      expect(deleteFired, isFalse);

      // Tap event to focus it, then Delete - should fire
      await tester.tap(find.text('Focus Me'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.pumpAndSettle();
      expect(deleteFired, isTrue);
    });

    testWidgets('autoFocusOnEventTap:false does not set focus on tap', (
      tester,
    ) async {
      controller.setMockEvents([
        MCalCalendarEvent(
          id: 'no-focus',
          title: 'No Focus',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
        ),
      ]);

      bool deleteFired = false;
      await tester.pumpWidget(
        MaterialApp(
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
                autoFocusOnEventTap: false,
                onDeleteEventRequested: (_) => deleteFired = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('No Focus'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.pumpAndSettle();

      expect(deleteFired, isFalse);
    });
  });

  group('MCalDayView enableKeyboardNavigation', () {
    late MockMCalEventController controller;

    setUp(() {
      controller = MockMCalEventController(initialDate: testDate);
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('enableKeyboardNavigation=false disables shortcuts', (
      tester,
    ) async {
      bool createFired = false;
      await tester.pumpWidget(
        MaterialApp(
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
                enableKeyboardNavigation: false,
                onCreateEventRequested: () => createFired = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(MCalDayView));
      await tester.pumpAndSettle();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      expect(createFired, isFalse);
    });
  });

  group('MCalDayView custom shortcuts', () {
    late MockMCalEventController controller;

    setUp(() {
      controller = MockMCalEventController(initialDate: testDate);
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('custom keyboardShortcuts override defaults', (tester) async {
      bool customCreateFired = false;
      await tester.pumpWidget(
        MaterialApp(
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
                keyboardShortcuts: {
                  const SingleActivator(LogicalKeyboardKey.keyN, meta: true):
                      MCalDayViewCreateEventIntent(),
                },
                onCreateEventRequested: () => customCreateFired = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(MCalDayView));
      await tester.pumpAndSettle();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      expect(customCreateFired, isTrue);
    });
  });
}
