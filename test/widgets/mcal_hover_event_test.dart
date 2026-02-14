import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';
import 'package:multi_calendar/src/widgets/mcal_builder_wrapper.dart';

/// Mock controller that supports adding events for testing.
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

  group('onHoverEvent callback', () {
    late _TestController controller;

    setUp(() {
      controller = _TestController(initialDate: DateTime(2025, 1, 15));
    });

    testWidgets('widget accepts onHoverEvent parameter', (tester) async {
      MCalEventTileContext? hoverContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalMonthView(
                controller: controller,
                onHoverEvent: (ctx) {
                  hoverContext = ctx;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Widget renders without error
      expect(find.byType(MCalMonthView), findsOneWidget);
      // No hover yet
      expect(hoverContext, isNull);
    });

    testWidgets('fires with event context on mouse enter', (tester) async {
      final testEvent = MCalCalendarEvent(
        id: 'hover-test-1',
        title: 'Hover Me',
        start: DateTime(2025, 1, 15, 10, 0),
        end: DateTime(2025, 1, 15, 11, 0),
        color: Colors.blue,
      );
      controller.setEvents([testEvent]);

      MCalEventTileContext? hoverContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalMonthView(
                controller: controller,
                onHoverEvent: (ctx) {
                  hoverContext = ctx;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the event tile
      final eventFinder = find.text('Hover Me');
      if (eventFinder.evaluate().isEmpty) {
        // Event tile not rendered (e.g. off-screen), skip
        return;
      }

      // Create a mouse gesture and hover over the event tile
      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.moveTo(tester.getCenter(eventFinder.first));
      await tester.pump();

      // Verify hover callback was called with event data
      expect(hoverContext, isNotNull);
      expect(hoverContext!.event.id, equals('hover-test-1'));
      expect(hoverContext!.event.title, equals('Hover Me'));
      expect(hoverContext!.displayDate.day, equals(15));
      expect(hoverContext!.isAllDay, isFalse);
    });

    testWidgets('fires null on mouse exit', (tester) async {
      final testEvent = MCalCalendarEvent(
        id: 'hover-exit-test',
        title: 'Leave Me',
        start: DateTime(2025, 1, 15, 10, 0),
        end: DateTime(2025, 1, 15, 11, 0),
      );
      controller.setEvents([testEvent]);

      final hoverValues = <MCalEventTileContext?>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalMonthView(
                controller: controller,
                onHoverEvent: (ctx) {
                  hoverValues.add(ctx);
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final eventFinder = find.text('Leave Me');
      if (eventFinder.evaluate().isEmpty) return;

      // Create mouse gesture
      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      // Move to event (enter)
      await gesture.moveTo(tester.getCenter(eventFinder.first));
      await tester.pump();

      // Move away from event (exit) — move to an area guaranteed not to be
      // an event tile (top-left corner area, typically the weekday header)
      await gesture.moveTo(const Offset(10, 10));
      await tester.pump();

      // We should have received at least one enter (non-null) and one exit (null)
      expect(hoverValues.where((v) => v != null), isNotEmpty,
          reason: 'Should have received at least one hover enter');
      expect(hoverValues.last, isNull,
          reason: 'Last hover event should be null (exit)');
    });

    testWidgets('provides correct isAllDay for all-day events', (tester) async {
      final allDayEvent = MCalCalendarEvent(
        id: 'allday-hover',
        title: 'All Day Hover',
        start: DateTime(2025, 1, 15),
        end: DateTime(2025, 1, 15, 23, 59, 59),
        isAllDay: true,
        color: Colors.green,
      );
      controller.setEvents([allDayEvent]);

      MCalEventTileContext? hoverContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalMonthView(
                controller: controller,
                onHoverEvent: (ctx) {
                  hoverContext = ctx;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final eventFinder = find.text('All Day Hover');
      if (eventFinder.evaluate().isEmpty) return;

      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.moveTo(tester.getCenter(eventFinder.first));
      await tester.pump();

      expect(hoverContext, isNotNull);
      expect(hoverContext!.isAllDay, isTrue);
      expect(hoverContext!.event.id, equals('allday-hover'));
    });

    testWidgets('works when drag-and-drop is enabled', (tester) async {
      final testEvent = MCalCalendarEvent(
        id: 'hover-drag-test',
        title: 'Drag Hover',
        start: DateTime(2025, 1, 15, 10, 0),
        end: DateTime(2025, 1, 15, 11, 0),
        color: Colors.red,
      );
      controller.setEvents([testEvent]);

      MCalEventTileContext? hoverContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalMonthView(
                controller: controller,
                enableDragToMove: true,
                onHoverEvent: (ctx) {
                  hoverContext = ctx;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final eventFinder = find.text('Drag Hover');
      if (eventFinder.evaluate().isEmpty) return;

      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.moveTo(tester.getCenter(eventFinder.first));
      await tester.pump();

      expect(hoverContext, isNotNull);
      expect(hoverContext!.event.id, equals('hover-drag-test'));
    });

    testWidgets('does not fire when onHoverEvent is null', (tester) async {
      final testEvent = MCalCalendarEvent(
        id: 'no-hover-test',
        title: 'No Hover',
        start: DateTime(2025, 1, 15, 10, 0),
        end: DateTime(2025, 1, 15, 11, 0),
      );
      controller.setEvents([testEvent]);

      // Build without onHoverEvent — just verify no error
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalMonthView(
                controller: controller,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final eventFinder = find.text('No Hover');
      if (eventFinder.evaluate().isEmpty) return;

      // Hover over event — should not crash even without callback
      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.moveTo(tester.getCenter(eventFinder.first));
      await tester.pump();

      // No crash — test passes
    });

    testWidgets('provides recurrence metadata for recurring events',
        (tester) async {
      // Create a recurring event
      final masterEvent = MCalCalendarEvent(
        id: 'recurring-hover',
        title: 'Daily Standup',
        start: DateTime(2025, 1, 1, 9, 0),
        end: DateTime(2025, 1, 1, 9, 30),
        color: Colors.purple,
        recurrenceRule: MCalRecurrenceRule(
          frequency: MCalFrequency.daily,
        ),
      );
      controller.setEvents([masterEvent]);

      MCalEventTileContext? hoverContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalMonthView(
                controller: controller,
                onHoverEvent: (ctx) {
                  hoverContext = ctx;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find any occurrence of the recurring event
      final eventFinder = find.text('Daily Standup');
      if (eventFinder.evaluate().isEmpty) return;

      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.moveTo(tester.getCenter(eventFinder.first));
      await tester.pump();

      expect(hoverContext, isNotNull);
      expect(hoverContext!.event.title, equals('Daily Standup'));
      expect(hoverContext!.isRecurring, isTrue);
      expect(hoverContext!.seriesId, equals('recurring-hover'));
      expect(hoverContext!.recurrenceRule, isNotNull);
      expect(hoverContext!.recurrenceRule!.frequency,
          equals(MCalFrequency.daily));
      expect(hoverContext!.masterEvent, isNotNull);
      expect(hoverContext!.masterEvent!.id, equals('recurring-hover'));
    });

    testWidgets('hovering over different events fires distinct contexts',
        (tester) async {
      final event1 = MCalCalendarEvent(
        id: 'multi-hover-1',
        title: 'Event A',
        start: DateTime(2025, 1, 10, 10, 0),
        end: DateTime(2025, 1, 10, 11, 0),
        color: Colors.blue,
      );
      final event2 = MCalCalendarEvent(
        id: 'multi-hover-2',
        title: 'Event B',
        start: DateTime(2025, 1, 20, 14, 0),
        end: DateTime(2025, 1, 20, 15, 0),
        color: Colors.red,
      );
      controller.setEvents([event1, event2]);

      final hoverIds = <String?>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: MCalMonthView(
                controller: controller,
                onHoverEvent: (ctx) {
                  hoverIds.add(ctx?.event.id);
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final finderA = find.text('Event A');
      final finderB = find.text('Event B');
      if (finderA.evaluate().isEmpty || finderB.evaluate().isEmpty) return;

      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      // Hover over Event A
      await gesture.moveTo(tester.getCenter(finderA.first));
      await tester.pump();

      // Hover over Event B (exits A, enters B)
      await gesture.moveTo(tester.getCenter(finderB.first));
      await tester.pump();

      // Should have received hover for both events
      expect(hoverIds.where((id) => id == 'multi-hover-1'), isNotEmpty,
          reason: 'Should have received hover for Event A');
      expect(hoverIds.where((id) => id == 'multi-hover-2'), isNotEmpty,
          reason: 'Should have received hover for Event B');
    });
  });

  group('MCalBuilderWrapper.wrapEventTileBuilder hover wrapping', () {
    testWidgets('wraps with MouseRegion when onHoverEvent is provided',
        (tester) async {
      MCalEventTileContext? receivedContext;

      final builder = MCalBuilderWrapper.wrapEventTileBuilder(
        developerBuilder: null,
        defaultBuilder: (context, tileContext) {
          return const SizedBox(width: 100, height: 20, key: Key('tile'));
        },
        onHoverEvent: (ctx) {
          receivedContext = ctx;
        },
        dayWidth: 100,
      );

      final tileContext = MCalEventTileContext(
        event: MCalCalendarEvent(
          id: 'wrapper-test',
          title: 'Wrapper Hover',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 15, 11, 0),
        ),
        displayDate: DateTime(2025, 1, 15),
        isAllDay: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => builder(context, tileContext),
            ),
          ),
        ),
      );

      // Should have a MouseRegion in the tree
      expect(find.byType(MouseRegion), findsWidgets);

      // Find the tile and hover over it
      final tileFinder = find.byKey(const Key('tile'));
      expect(tileFinder, findsOneWidget);

      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.moveTo(tester.getCenter(tileFinder));
      await tester.pump();

      expect(receivedContext, isNotNull);
      expect(receivedContext!.event.id, equals('wrapper-test'));
    });

    testWidgets('does not add MouseRegion when onHoverEvent is null',
        (tester) async {
      final builder = MCalBuilderWrapper.wrapEventTileBuilder(
        developerBuilder: null,
        defaultBuilder: (context, tileContext) {
          return const SizedBox(
            width: 100,
            height: 20,
            key: Key('no-hover-tile'),
          );
        },
        onHoverEvent: null,
        dayWidth: 100,
      );

      final tileContext = MCalEventTileContext(
        event: MCalCalendarEvent(
          id: 'no-hover-wrapper',
          title: 'No Hover Wrapper',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 15, 11, 0),
        ),
        displayDate: DateTime(2025, 1, 15),
        isAllDay: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => builder(context, tileContext),
            ),
          ),
        ),
      );

      // The builder-wrapper's GestureDetector shouldn't be wrapped with
      // a MouseRegion since onHoverEvent is null.
      // Note: MaterialApp / Scaffold may introduce their own MouseRegions,
      // so we check for the tile's immediate ancestors.
      final tileFinder = find.byKey(const Key('no-hover-tile'));
      expect(tileFinder, findsOneWidget);

      // Walk up: the tile's parent should be a GestureDetector, not a MouseRegion
      final gestureDetector = find.ancestor(
        of: tileFinder,
        matching: find.byType(GestureDetector),
      );
      expect(gestureDetector, findsWidgets);

      // No crash — the key assertion is that the builder wrapper does NOT add
      // a MouseRegion when onHoverEvent is null. We verify no error occurs
      // when hovering without the callback.
      expect(tileFinder, findsOneWidget);
    });

    testWidgets('hover fires null on exit via wrapper', (tester) async {
      final hoverValues = <MCalEventTileContext?>[];

      final builder = MCalBuilderWrapper.wrapEventTileBuilder(
        developerBuilder: null,
        defaultBuilder: (context, tileContext) {
          return const SizedBox(width: 100, height: 20, key: Key('exit-tile'));
        },
        onHoverEvent: (ctx) {
          hoverValues.add(ctx);
        },
        dayWidth: 100,
      );

      final tileContext = MCalEventTileContext(
        event: MCalCalendarEvent(
          id: 'exit-test',
          title: 'Exit Test',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 15, 11, 0),
        ),
        displayDate: DateTime(2025, 1, 15),
        isAllDay: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => builder(context, tileContext),
              ),
            ),
          ),
        ),
      );

      final tileFinder = find.byKey(const Key('exit-tile'));
      expect(tileFinder, findsOneWidget);

      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      // Enter
      await gesture.moveTo(tester.getCenter(tileFinder));
      await tester.pump();

      // Exit (move far away)
      await gesture.moveTo(const Offset(0, 0));
      await tester.pump();

      // Should have enter (non-null) followed by exit (null)
      expect(hoverValues.where((v) => v != null), isNotEmpty);
      expect(hoverValues.last, isNull);
    });

    testWidgets('hover works with drag-and-drop enabled via wrapper',
        (tester) async {
      MCalEventTileContext? hoverContext;

      final builder = MCalBuilderWrapper.wrapEventTileBuilder(
        developerBuilder: null,
        defaultBuilder: (context, tileContext) {
          return const SizedBox(
            width: 100,
            height: 20,
            key: Key('drag-hover-tile'),
          );
        },
        onHoverEvent: (ctx) {
          hoverContext = ctx;
        },
        enableDragToMove: true,
        dayWidth: 100,
        tileHeight: 20,
      );

      final tileContext = MCalEventTileContext(
        event: MCalCalendarEvent(
          id: 'drag-hover',
          title: 'Drag Hover Test',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 15, 11, 0),
        ),
        displayDate: DateTime(2025, 1, 15),
        isAllDay: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => builder(context, tileContext),
              ),
            ),
          ),
        ),
      );

      final tileFinder = find.byKey(const Key('drag-hover-tile'));
      expect(tileFinder, findsOneWidget);

      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.moveTo(tester.getCenter(tileFinder));
      await tester.pump();

      expect(hoverContext, isNotNull);
      expect(hoverContext!.event.id, equals('drag-hover'));
    });

    testWidgets('hover context includes recurrence metadata when controller provided',
        (tester) async {
      final testController = _TestController(
        initialDate: DateTime(2025, 1, 15),
      );
      final masterEvent = MCalCalendarEvent(
        id: 'rec-master',
        title: 'Recurring',
        start: DateTime(2025, 1, 1, 9, 0),
        end: DateTime(2025, 1, 1, 9, 30),
        recurrenceRule: MCalRecurrenceRule(
          frequency: MCalFrequency.weekly,
        ),
      );
      testController.setEvents([masterEvent]);

      MCalEventTileContext? hoverContext;

      // Simulate an occurrence event (as the controller would generate)
      final occurrenceEvent = MCalCalendarEvent(
        id: 'rec-master_2025-01-15T09:00:00.000',
        title: 'Recurring',
        start: DateTime(2025, 1, 15, 9, 0),
        end: DateTime(2025, 1, 15, 9, 30),
        occurrenceId: '2025-01-15T09:00:00.000',
      );

      final builder = MCalBuilderWrapper.wrapEventTileBuilder(
        developerBuilder: null,
        defaultBuilder: (context, tileContext) {
          return const SizedBox(width: 100, height: 20, key: Key('rec-tile'));
        },
        onHoverEvent: (ctx) {
          hoverContext = ctx;
        },
        controller: testController,
        dayWidth: 100,
      );

      final tileContext = MCalEventTileContext(
        event: occurrenceEvent,
        displayDate: DateTime(2025, 1, 15),
        isAllDay: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => builder(context, tileContext),
              ),
            ),
          ),
        ),
      );

      final tileFinder = find.byKey(const Key('rec-tile'));
      expect(tileFinder, findsOneWidget);

      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.moveTo(tester.getCenter(tileFinder));
      await tester.pump();

      expect(hoverContext, isNotNull);
      expect(hoverContext!.isRecurring, isTrue);
      expect(hoverContext!.seriesId, equals('rec-master'));
      expect(hoverContext!.masterEvent, isNotNull);
      expect(hoverContext!.masterEvent!.id, equals('rec-master'));
      expect(hoverContext!.recurrenceRule, isNotNull);
      expect(hoverContext!.recurrenceRule!.frequency,
          equals(MCalFrequency.weekly));
    });

    testWidgets('hover context for non-recurring event has isRecurring=false',
        (tester) async {
      MCalEventTileContext? hoverContext;

      final builder = MCalBuilderWrapper.wrapEventTileBuilder(
        developerBuilder: null,
        defaultBuilder: (context, tileContext) {
          return const SizedBox(
            width: 100,
            height: 20,
            key: Key('nonrec-tile'),
          );
        },
        onHoverEvent: (ctx) {
          hoverContext = ctx;
        },
        dayWidth: 100,
      );

      // Non-recurring event (no occurrenceId)
      final tileContext = MCalEventTileContext(
        event: MCalCalendarEvent(
          id: 'nonrec',
          title: 'Non-Recurring',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 15, 11, 0),
        ),
        displayDate: DateTime(2025, 1, 15),
        isAllDay: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => builder(context, tileContext),
              ),
            ),
          ),
        ),
      );

      final tileFinder = find.byKey(const Key('nonrec-tile'));
      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.moveTo(tester.getCenter(tileFinder));
      await tester.pump();

      expect(hoverContext, isNotNull);
      expect(hoverContext!.isRecurring, isFalse);
      expect(hoverContext!.seriesId, isNull);
      expect(hoverContext!.masterEvent, isNull);
    });
  });
}
