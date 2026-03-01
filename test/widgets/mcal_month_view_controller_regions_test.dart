import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget buildTestApp({required Widget child}) {
  return MaterialApp(
    localizationsDelegates: MCalLocalizations.localizationsDelegates,
    supportedLocales: MCalLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
  });

  // =========================================================================
  // 1. Month View renders all-day regions from controller
  // =========================================================================

  group('Month View renders all-day regions from controller', () {
    late MCalEventController controller;

    setUp(() {
      controller = MCalEventController(
        initialDate: DateTime(2026, 6, 15),
      );
    });

    tearDown(() => controller.dispose());

    testWidgets(
      'all-day region with color renders overlay in the month cell',
      (tester) async {
        const regionColor = Color(0x33FF0000);

        controller.addRegions([
          MCalRegion(
            id: 'holiday',
            start: DateTime(2026, 6, 15),
            end: DateTime(2026, 6, 15),
            isAllDay: true,
            color: regionColor,
            text: 'Holiday',
          ),
        ]);

        await tester.pumpWidget(
          buildTestApp(
            child: SizedBox(
              width: 400,
              height: 600,
              child: MCalMonthView(controller: controller),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // The region overlay container should be present.
        final coloredContainers = tester.widgetList<Container>(
          find.byWidgetPredicate(
            (w) => w is Container && w.color == regionColor,
          ),
        );
        expect(coloredContainers, isNotEmpty,
            reason: 'Region overlay with specified color should be rendered');
      },
    );

    testWidgets(
      'all-day region with text renders text in the cell',
      (tester) async {
        controller.addRegions([
          MCalRegion(
            id: 'labeled-region',
            start: DateTime(2026, 6, 15),
            end: DateTime(2026, 6, 15),
            isAllDay: true,
            color: Colors.blue.withValues(alpha: 0.2),
            text: 'Team Day',
          ),
        ]);

        await tester.pumpWidget(
          buildTestApp(
            child: SizedBox(
              width: 400,
              height: 600,
              child: MCalMonthView(controller: controller),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Team Day'), findsWidgets);
      },
    );

    testWidgets(
      'all-day region with icon renders icon in the cell',
      (tester) async {
        controller.addRegions([
          MCalRegion(
            id: 'icon-region',
            start: DateTime(2026, 6, 15),
            end: DateTime(2026, 6, 15),
            isAllDay: true,
            color: Colors.green.withValues(alpha: 0.2),
            icon: Icons.star,
          ),
        ]);

        await tester.pumpWidget(
          buildTestApp(
            child: SizedBox(
              width: 400,
              height: 600,
              child: MCalMonthView(controller: controller),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.star), findsWidgets);
      },
    );

    testWidgets(
      'timed-only region does not render as day cell overlay',
      (tester) async {
        const timedColor = Color(0x33009900);

        controller.addRegions([
          MCalRegion(
            id: 'timed-only',
            start: DateTime(2026, 6, 15, 9, 0),
            end: DateTime(2026, 6, 15, 10, 0),
            isAllDay: false,
            color: timedColor,
            text: 'Timed Region',
          ),
        ]);

        await tester.pumpWidget(
          buildTestApp(
            child: SizedBox(
              width: 400,
              height: 600,
              child: MCalMonthView(controller: controller),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Timed regions should not render as day cell overlays in month view.
        // The overlay is only built for isAllDay regions.
        final coloredContainers = tester.widgetList<Container>(
          find.byWidgetPredicate(
            (w) => w is Container && w.color == timedColor,
          ),
        );
        expect(coloredContainers, isEmpty,
            reason: 'Timed-only region should not render as day cell overlay');
      },
    );

    testWidgets(
      'dayCellBuilder receives controller regions in context',
      (tester) async {
        controller.addRegions([
          MCalRegion(
            id: 'cell-ctx-region',
            start: DateTime(2026, 6, 15),
            end: DateTime(2026, 6, 15),
            isAllDay: true,
            text: 'Cell Context Region',
          ),
        ]);

        MCalDayCellContext? capturedCtx;

        await tester.pumpWidget(
          buildTestApp(
            child: SizedBox(
              width: 400,
              height: 600,
              child: MCalMonthView(
                controller: controller,
                dayCellBuilder: (context, ctx, defaultCell) {
                  if (ctx.date.month == 6 && ctx.date.day == 15) {
                    capturedCtx = ctx;
                  }
                  return defaultCell;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(capturedCtx, isNotNull);
        expect(capturedCtx!.regions, isNotEmpty);
        expect(
          capturedCtx!.regions.any((r) => r.id == 'cell-ctx-region'),
          isTrue,
        );
      },
    );
  });

  // =========================================================================
  // 2. Month View drag validation rejects drops on blocked all-day regions
  // =========================================================================

  group('Month View drag validation with controller regions', () {
    late MCalEventController controller;

    setUp(() {
      controller = MCalEventController(
        initialDate: DateTime(2026, 6, 15),
      );
    });

    tearDown(() => controller.dispose());

    testWidgets(
      'controller.isDateBlocked rejects blocked all-day region date',
      (tester) async {
        controller.addRegions([
          MCalRegion(
            id: 'blocked-day',
            start: DateTime(2026, 6, 20),
            end: DateTime(2026, 6, 20),
            isAllDay: true,
            blockInteraction: true,
          ),
        ]);

        expect(
          controller.isDateBlocked(DateTime(2026, 6, 20)),
          isTrue,
          reason: 'Date with blocking all-day region should be blocked',
        );

        expect(
          controller.isDateBlocked(DateTime(2026, 6, 19)),
          isFalse,
          reason: 'Date without blocking region should not be blocked',
        );
      },
    );

    testWidgets(
      'blocked all-day region prevents drag acceptance in Month View',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'ev-drag',
          title: 'Drag Me',
          start: DateTime(2026, 6, 15, 10, 0),
          end: DateTime(2026, 6, 15, 11, 0),
        );
        controller.addEvents([event]);

        // Block June 20.
        controller.addRegions([
          MCalRegion(
            id: 'blocked-20',
            start: DateTime(2026, 6, 20),
            end: DateTime(2026, 6, 20),
            isAllDay: true,
            blockInteraction: true,
          ),
        ]);

        bool dragWillAcceptCalled = false;

        await tester.pumpWidget(
          buildTestApp(
            child: SizedBox(
              width: 400,
              height: 600,
              child: MCalMonthView(
                controller: controller,
                enableDragToMove: true,
                onDragWillAccept: (context, details) {
                  dragWillAcceptCalled = true;
                  return true;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final eventFinder = find.text('Drag Me');
        expect(eventFinder, findsOneWidget);

        final gesture = await tester.startGesture(
          tester.getCenter(eventFinder),
        );
        await tester.pump(const Duration(milliseconds: 300));
        dragWillAcceptCalled = false;

        // Move to "20" (June 20 — blocked).
        final targetFinder = find.text('20');
        if (targetFinder.evaluate().isNotEmpty) {
          await gesture.moveTo(tester.getCenter(targetFinder.first));
          await tester.pump(const Duration(milliseconds: 100));

          expect(
            dragWillAcceptCalled,
            isFalse,
            reason:
                'onDragWillAccept must not be called when date is blocked by controller region',
          );
        }

        await gesture.up();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'non-blocked region allows drag acceptance in Month View',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'ev-drag-2',
          title: 'Drag Allowed',
          start: DateTime(2026, 6, 15, 10, 0),
          end: DateTime(2026, 6, 15, 11, 0),
        );
        controller.addEvents([event]);

        // Block only June 20; drag to June 19 (not blocked).
        controller.addRegions([
          MCalRegion(
            id: 'blocked-20-only',
            start: DateTime(2026, 6, 20),
            end: DateTime(2026, 6, 20),
            isAllDay: true,
            blockInteraction: true,
          ),
        ]);

        bool dragWillAcceptCalled = false;

        await tester.pumpWidget(
          buildTestApp(
            child: SizedBox(
              width: 400,
              height: 600,
              child: MCalMonthView(
                controller: controller,
                enableDragToMove: true,
                onDragWillAccept: (context, details) {
                  dragWillAcceptCalled = true;
                  return true;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final eventFinder = find.text('Drag Allowed');
        expect(eventFinder, findsOneWidget);

        final gesture = await tester.startGesture(
          tester.getCenter(eventFinder),
        );
        await tester.pump(const Duration(milliseconds: 300));
        dragWillAcceptCalled = false;

        // Move to "19" (June 19 — not blocked).
        final targetFinder = find.text('19');
        if (targetFinder.evaluate().isNotEmpty) {
          await gesture.moveTo(tester.getCenter(targetFinder.first));
          await tester.pump(const Duration(milliseconds: 100));

          expect(
            dragWillAcceptCalled,
            isTrue,
            reason:
                'onDragWillAccept must be called when date is not blocked',
          );
        }

        await gesture.up();
        await tester.pumpAndSettle();
      },
    );
  });

  // =========================================================================
  // 3. Cross-view enforcement
  // =========================================================================

  group('Cross-view enforcement in Month View', () {
    late MCalEventController controller;

    setUp(() {
      controller = MCalEventController(
        initialDate: DateTime(2026, 6, 15), // Monday
      );
    });

    tearDown(() => controller.dispose());

    testWidgets(
      'timed blocking region on Mondays blocks drag via controller validation',
      (tester) async {
        // Add a timed blocking region for Mondays 14:00-17:00.
        controller.addRegions([
          MCalRegion(
            id: 'monday-blocked',
            start: DateTime(2026, 6, 15, 14, 0), // Monday anchor
            end: DateTime(2026, 6, 15, 17, 0),
            isAllDay: false,
            blockInteraction: true,
            recurrenceRule: MCalRecurrenceRule(
              frequency: MCalFrequency.weekly,
              byWeekDays: {MCalWeekDay.every(DateTime.monday)},
            ),
          ),
        ]);

        // A 15:00-16:00 event on a non-Monday (Wednesday June 17) is fine.
        final event = MCalCalendarEvent(
          id: 'afternoon-event',
          title: 'Afternoon Meeting',
          start: DateTime(2026, 6, 17, 15, 0), // Wednesday
          end: DateTime(2026, 6, 17, 16, 0),
        );
        controller.addEvents([event]);

        // Verify controller-level cross-view enforcement:
        // Moving the 15:00-16:00 event to Monday June 15 should be blocked
        // because the region 14:00-17:00 overlaps with 15:00-16:00.
        expect(
          controller.isTimeRangeBlocked(
            DateTime(2026, 6, 15, 15, 0),
            DateTime(2026, 6, 15, 16, 0),
          ),
          isTrue,
          reason:
              'Moving a 15-16 event to Monday should be blocked by 14-17 timed region',
        );

        // But the same time on Wednesday should not be blocked
        // (no blocking region on Wednesdays).
        expect(
          controller.isTimeRangeBlocked(
            DateTime(2026, 6, 17, 15, 0),
            DateTime(2026, 6, 17, 16, 0),
          ),
          isFalse,
          reason:
              'Same time on Wednesday should not be blocked (no region on Wednesdays)',
        );

        // The date itself is not blocked (only timed region, not all-day).
        expect(
          controller.isDateBlocked(DateTime(2026, 6, 15)),
          isFalse,
          reason:
              'Monday is not date-blocked (only has timed region, not all-day)',
        );
      },
    );

    testWidgets(
      'cross-view enforcement rejects drag to Monday via Month View drag validation',
      (tester) async {
        // Add recurring timed blocking region: Mondays 14:00-17:00.
        controller.addRegions([
          MCalRegion(
            id: 'monday-blocked-cv',
            start: DateTime(2026, 6, 15, 14, 0),
            end: DateTime(2026, 6, 15, 17, 0),
            isAllDay: false,
            blockInteraction: true,
            recurrenceRule: MCalRecurrenceRule(
              frequency: MCalFrequency.weekly,
              byWeekDays: {MCalWeekDay.every(DateTime.monday)},
            ),
          ),
        ]);

        // Timed event on Wednesday 15:00-16:00 (not blocked on Wednesday).
        final event = MCalCalendarEvent(
          id: 'cross-view-event',
          title: 'Cross View',
          start: DateTime(2026, 6, 17, 15, 0),
          end: DateTime(2026, 6, 17, 16, 0),
        );
        controller.addEvents([event]);

        bool dragWillAcceptCalled = false;

        await tester.pumpWidget(
          buildTestApp(
            child: SizedBox(
              width: 400,
              height: 600,
              child: MCalMonthView(
                controller: controller,
                enableDragToMove: true,
                onDragWillAccept: (context, details) {
                  dragWillAcceptCalled = true;
                  return true;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final eventFinder = find.text('Cross View');
        expect(eventFinder, findsOneWidget);

        final gesture = await tester.startGesture(
          tester.getCenter(eventFinder),
        );
        await tester.pump(const Duration(milliseconds: 300));
        dragWillAcceptCalled = false;

        // Try to drag to Monday June 15.
        // The cross-view enforcement should detect that the event's timed
        // range (15:00-16:00) overlaps with the blocking region (14:00-17:00)
        // on Mondays, and reject the drop.
        final targetFinder = find.text('15');
        if (targetFinder.evaluate().isNotEmpty) {
          await gesture.moveTo(tester.getCenter(targetFinder.first));
          await tester.pump(const Duration(milliseconds: 100));

          expect(
            dragWillAcceptCalled,
            isFalse,
            reason:
                'Cross-view enforcement: timed region on Mondays 14-17 must '
                'prevent moving a 15-16 event to Monday',
          );
        }

        await gesture.up();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'cross-view enforcement allows drag to non-blocked day',
      (tester) async {
        // Same recurring timed blocking region: Mondays 14:00-17:00.
        controller.addRegions([
          MCalRegion(
            id: 'monday-blocked-allow',
            start: DateTime(2026, 6, 15, 14, 0),
            end: DateTime(2026, 6, 15, 17, 0),
            isAllDay: false,
            blockInteraction: true,
            recurrenceRule: MCalRecurrenceRule(
              frequency: MCalFrequency.weekly,
              byWeekDays: {MCalWeekDay.every(DateTime.monday)},
            ),
          ),
        ]);

        // Timed event 15:00-16:00 on Monday June 15 (currently blocked).
        final event = MCalCalendarEvent(
          id: 'move-to-tuesday',
          title: 'Move To Tuesday',
          start: DateTime(2026, 6, 15, 15, 0),
          end: DateTime(2026, 6, 15, 16, 0),
        );
        controller.addEvents([event]);

        bool dragWillAcceptCalled = false;

        await tester.pumpWidget(
          buildTestApp(
            child: SizedBox(
              width: 400,
              height: 600,
              child: MCalMonthView(
                controller: controller,
                enableDragToMove: true,
                onDragWillAccept: (context, details) {
                  dragWillAcceptCalled = true;
                  return true;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final eventFinder = find.text('Move To Tuesday');
        expect(eventFinder, findsOneWidget);

        final gesture = await tester.startGesture(
          tester.getCenter(eventFinder),
        );
        await tester.pump(const Duration(milliseconds: 300));
        dragWillAcceptCalled = false;

        // Move to Tuesday June 16 (not blocked).
        final targetFinder = find.text('16');
        if (targetFinder.evaluate().isNotEmpty) {
          await gesture.moveTo(tester.getCenter(targetFinder.first));
          await tester.pump(const Duration(milliseconds: 100));

          expect(
            dragWillAcceptCalled,
            isTrue,
            reason:
                'Dragging to Tuesday should be allowed (no blocking region)',
          );
        }

        await gesture.up();
        await tester.pumpAndSettle();
      },
    );
  });
}
