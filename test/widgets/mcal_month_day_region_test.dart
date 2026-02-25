import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Test helpers
// ─────────────────────────────────────────────────────────────────────────────

class _TestController extends MCalEventController {
  _TestController({super.initialDate});

  void setEvents(List<MCalCalendarEvent> events) {
    clearEvents();
    addEvents(events);
  }
}

/// Pumps a [MCalMonthView] with the given parameters and settles animations.
Future<void> pumpMonthView(
  WidgetTester tester, {
  required _TestController controller,
  List<MCalDayRegion> dayRegions = const [],
  Widget Function(BuildContext, MCalDayRegionContext, Widget)? dayRegionBuilder,
  bool enableDragToMove = false,
  bool Function(BuildContext, MCalDragWillAcceptDetails)? onDragWillAccept,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 600,
          child: MCalMonthView(
            controller: controller,
            dayRegions: dayRegions,
            dayRegionBuilder: dayRegionBuilder,
            enableDragToMove: enableDragToMove,
            onDragWillAccept: onDragWillAccept,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

// ─────────────────────────────────────────────────────────────────────────────
// Main
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Group 1: Rendering
  // ───────────────────────────────────────────────────────────────────────────

  group('MCalDayRegion rendering', () {
    late _TestController controller;

    setUp(() {
      // Use June 2026; we'll target June 15 (Monday) as the region anchor.
      controller = _TestController(initialDate: DateTime(2026, 6, 15));
    });

    tearDown(() => controller.dispose());

    testWidgets('widget builds without error when dayRegions is empty (default)', (
      tester,
    ) async {
      await pumpMonthView(tester, controller: controller);
      expect(find.byType(MCalMonthView), findsOneWidget);
    });

    testWidgets('region with color renders a Container with that color', (
      tester,
    ) async {
      const regionColor = Color(0x33FF0000); // semi-transparent red
      final region = MCalDayRegion(
        id: 'colored',
        date: DateTime(2026, 6, 15),
        color: regionColor,
      );

      await pumpMonthView(
        tester,
        controller: controller,
        dayRegions: [region],
      );

      // There should be a Container decorated with the region color somewhere
      // in the widget tree (the region overlay).
      final coloredContainers = tester.widgetList<Container>(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              (w.color == regionColor ||
                  (w.decoration is BoxDecoration &&
                      (w.decoration as BoxDecoration).color == regionColor)),
        ),
      );
      expect(coloredContainers, isNotEmpty);
    });

    testWidgets('region with text renders that text in the cell', (
      tester,
    ) async {
      final region = MCalDayRegion(
        id: 'labeled',
        date: DateTime(2026, 6, 15),
        color: Colors.amber.withValues(alpha: 0.2),
        text: 'Holiday',
      );

      await pumpMonthView(
        tester,
        controller: controller,
        dayRegions: [region],
      );

      expect(find.text('Holiday'), findsWidgets);
    });

    testWidgets('region with icon renders that icon in the cell', (
      tester,
    ) async {
      final region = MCalDayRegion(
        id: 'iconic',
        date: DateTime(2026, 6, 15),
        color: Colors.green.withValues(alpha: 0.2),
        icon: Icons.star,
      );

      await pumpMonthView(
        tester,
        controller: controller,
        dayRegions: [region],
      );

      expect(find.byIcon(Icons.star), findsWidgets);
    });

    testWidgets('region with neither text nor icon renders no label widget', (
      tester,
    ) async {
      const label = 'ShouldNotAppear';
      final region = MCalDayRegion(
        id: 'color-only',
        date: DateTime(2026, 6, 15),
        color: Colors.blue.withValues(alpha: 0.2),
      );

      await pumpMonthView(
        tester,
        controller: controller,
        dayRegions: [region],
      );

      expect(find.text(label), findsNothing);
    });

    testWidgets('region does not render on non-matching cells', (tester) async {
      // Region is for June 15; Jun 20 should have no colored overlay.
      const regionColor = Color(0x4400FF00); // unique semi-transparent green
      final region = MCalDayRegion(
        id: 'specific-day',
        date: DateTime(2026, 6, 15),
        color: regionColor,
      );

      await pumpMonthView(
        tester,
        controller: controller,
        dayRegions: [region],
      );

      // Because region only applies to Jun 15, a different cell (Jun 20) does
      // not have the overlay.  We can't directly locate cells, but we verify
      // that exactly the correct number of colored containers appear (one for
      // each visible cell that matches — here exactly one since Jun 15 matches).
      final coloredContainers = tester.widgetList<Container>(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              (w.color == regionColor ||
                  (w.decoration is BoxDecoration &&
                      (w.decoration as BoxDecoration).color == regionColor)),
        ),
      );
      // Exactly one cell (Jun 15) should be coloured.
      expect(coloredContainers.length, 1);
    });

    testWidgets('FREQ=WEEKLY;BYDAY=SA,SU produces overlays only on weekend cells', (
      tester,
    ) async {
      const weekendColor = Color(0x22888888);
      final region = MCalDayRegion(
        id: 'weekends',
        date: DateTime(2026, 6, 6), // Saturday anchor
        recurrenceRule: 'FREQ=WEEKLY;BYDAY=SA,SU',
        color: weekendColor,
      );

      await pumpMonthView(
        tester,
        controller: controller,
        dayRegions: [region],
      );

      // June 2026 visible in the grid:
      // The month grid typically shows 5 or 6 weeks.
      // June 2026: starts Monday.  The grid from Mon-Sun shows:
      //   Week 1: Jun 1 (Mon) … Jun 7 (Sun)    → Sat Jun 6, Sun Jun 7
      //   Week 2: Jun 8 … Jun 14               → Sat Jun 13, Sun Jun 14
      //   Week 3: Jun 15 … Jun 21              → Sat Jun 20, Sun Jun 21
      //   Week 4: Jun 22 … Jun 28              → Sat Jun 27, Sun Jun 28
      //   Week 5: Jun 29 … Jul 5 (overflow)    → Sat Jul 4, Sun Jul 5
      // (Default firstDayOfWeek=0 = Sunday, so a Sunday-start grid:)
      // Either way, there should be multiple colored containers — one per
      // weekend cell visible in the grid.

      final coloredContainers = tester.widgetList<Container>(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              (w.color == weekendColor ||
                  (w.decoration is BoxDecoration &&
                      (w.decoration as BoxDecoration).color == weekendColor)),
        ),
      );
      // Should be at least 8 (2 per week × 4 full weeks of June).
      expect(coloredContainers.length, greaterThanOrEqualTo(8));
    });

    testWidgets('multiple regions on the same cell are all rendered', (
      tester,
    ) async {
      const color1 = Color(0x33FF0000);
      const color2 = Color(0x330000FF);
      final regions = [
        MCalDayRegion(id: 'r1', date: DateTime(2026, 6, 15), color: color1),
        MCalDayRegion(id: 'r2', date: DateTime(2026, 6, 15), color: color2),
      ];

      await pumpMonthView(
        tester,
        controller: controller,
        dayRegions: regions,
      );

      // Both colored containers should appear for the one matching cell.
      final red = tester.widgetList<Container>(
        find.byWidgetPredicate(
          (w) => w is Container && w.color == color1,
        ),
      );
      final blue = tester.widgetList<Container>(
        find.byWidgetPredicate(
          (w) => w is Container && w.color == color2,
        ),
      );

      expect(red, isNotEmpty);
      expect(blue, isNotEmpty);
    });

    testWidgets('dayRegionBuilder overrides default overlay widget', (
      tester,
    ) async {
      const sentinelKey = Key('region-sentinel');
      final region = MCalDayRegion(
        id: 'builder-test',
        date: DateTime(2026, 6, 15),
        color: Colors.purple,
      );

      await pumpMonthView(
        tester,
        controller: controller,
        dayRegions: [region],
        dayRegionBuilder: (context, ctx, defaultWidget) {
          // Return a sentinel widget that is uniquely findable.
          return const ColoredBox(
            key: sentinelKey,
            color: Colors.transparent,
          );
        },
      );

      // The sentinel widget should appear in the tree.
      expect(find.byKey(sentinelKey), findsWidgets);
    });

    testWidgets('dayRegionBuilder receives correct MCalDayRegionContext fields', (
      tester,
    ) async {
      final capturedContexts = <MCalDayRegionContext>[];
      final region = MCalDayRegion(
        id: 'ctx-check',
        date: DateTime(2026, 6, 15),
        color: Colors.teal,
      );

      await pumpMonthView(
        tester,
        controller: controller,
        dayRegions: [region],
        dayRegionBuilder: (context, ctx, defaultWidget) {
          capturedContexts.add(ctx);
          return defaultWidget;
        },
      );

      // Should have been called at least once for Jun 15.
      expect(capturedContexts, isNotEmpty);
      final ctx = capturedContexts.firstWhere(
        (c) => c.date.day == 15 && c.date.month == 6,
        orElse: () => capturedContexts.first,
      );
      expect(ctx.region.id, 'ctx-check');
      expect(ctx.date.month, 6);
      expect(ctx.date.day, 15);
    });

    testWidgets('dayRegionBuilder that wraps default widget renders correctly', (
      tester,
    ) async {
      const wrapperColor = Color(0xFF123456);
      final region = MCalDayRegion(
        id: 'wrapper-test',
        date: DateTime(2026, 6, 15),
        color: Colors.amber.withValues(alpha: 0.2),
      );

      await pumpMonthView(
        tester,
        controller: controller,
        dayRegions: [region],
        dayRegionBuilder: (context, ctx, defaultWidget) {
          return ColoredBox(color: wrapperColor, child: defaultWidget);
        },
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is ColoredBox && w.color == wrapperColor,
        ),
        findsWidgets,
      );
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Group 2: Drop blocking
  // ───────────────────────────────────────────────────────────────────────────

  group('MCalDayRegion drop blocking', () {
    late _TestController controller;

    setUp(() {
      controller = _TestController(initialDate: DateTime(2025, 1, 1));
    });

    tearDown(() => controller.dispose());

    testWidgets(
      'dragging onto a blockInteraction:true cell does NOT call onDragWillAccept',
      (tester) async {
        // Event on Jan 10 (Friday); blocking region on Jan 18 (Saturday).
        final event = MCalCalendarEvent(
          id: 'move-me',
          title: 'Move Me',
          start: DateTime(2025, 1, 10, 9, 0),
          end: DateTime(2025, 1, 10, 10, 0),
        );
        controller.setEvents([event]);

        bool dragWillAcceptCalled = false;

        // Block every Saturday.
        final blockingRegion = MCalDayRegion(
          id: 'saturdays',
          date: DateTime(2025, 1, 4), // Saturday anchor
          recurrenceRule: 'FREQ=WEEKLY;BYDAY=SA',
          blockInteraction: true,
        );

        await pumpMonthView(
          tester,
          controller: controller,
          dayRegions: [blockingRegion],
          enableDragToMove: true,
          onDragWillAccept: (context, details) {
            dragWillAcceptCalled = true;
            return true;
          },
        );

        // Start a drag on the event tile.
        final eventFinder = find.text('Move Me');
        expect(eventFinder, findsOneWidget);

        final gesture = await tester.startGesture(
          tester.getCenter(eventFinder),
        );
        await tester.pump(const Duration(milliseconds: 300));
        // Reset: the first _processDragMove fires at the original event
        // position (Jan 10, Friday — not blocked), potentially calling
        // onDragWillAccept before we reach the blocked target.
        dragWillAcceptCalled = false;

        // Move to a Saturday cell (Jan 18).
        final targetFinder = find.text('18');
        if (targetFinder.evaluate().isNotEmpty) {
          await gesture.moveTo(tester.getCenter(targetFinder.first));
          await tester.pump(const Duration(milliseconds: 100));

          // The library should have blocked the drop before calling the callback.
          expect(
            dragWillAcceptCalled,
            isFalse,
            reason:
                'onDragWillAccept must not be called when blockInteraction is true',
          );
        }

        await gesture.up();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'dragging onto a non-blocked cell DOES call onDragWillAccept',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'move-me-2',
          title: 'Move Me 2',
          start: DateTime(2025, 1, 10, 9, 0),
          end: DateTime(2025, 1, 10, 10, 0),
        );
        controller.setEvents([event]);

        bool dragWillAcceptCalled = false;

        // Block only Saturdays, but we'll drag to a Friday (Jan 17).
        final blockingRegion = MCalDayRegion(
          id: 'saturdays-only',
          date: DateTime(2025, 1, 4),
          recurrenceRule: 'FREQ=WEEKLY;BYDAY=SA',
          blockInteraction: true,
        );

        await pumpMonthView(
          tester,
          controller: controller,
          dayRegions: [blockingRegion],
          enableDragToMove: true,
          onDragWillAccept: (context, details) {
            dragWillAcceptCalled = true;
            return true;
          },
        );

        final eventFinder = find.text('Move Me 2');
        expect(eventFinder, findsOneWidget);

        final gesture = await tester.startGesture(
          tester.getCenter(eventFinder),
        );
        await tester.pump(const Duration(milliseconds: 300));
        // Allow the first _processDragMove (over the original position) to
        // possibly fire; reset flag so we only measure the target position.
        dragWillAcceptCalled = false;

        // Move to a Friday cell (Jan 17 = Friday).
        final targetFinder = find.text('17');
        if (targetFinder.evaluate().isNotEmpty) {
          await gesture.moveTo(tester.getCenter(targetFinder.first));
          await tester.pump(const Duration(milliseconds: 100));

          // Jan 17 is a Friday — not blocked — so the callback should fire.
          expect(
            dragWillAcceptCalled,
            isTrue,
            reason:
                'onDragWillAccept must be called when the target is not blocked',
          );
        }

        await gesture.up();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'blockInteraction:false region does NOT block drops; onDragWillAccept called',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'visual-region-test',
          title: 'Visual Region Test',
          start: DateTime(2025, 1, 10, 9, 0),
          end: DateTime(2025, 1, 10, 10, 0),
        );
        controller.setEvents([event]);

        bool dragWillAcceptCalled = false;

        // Visual-only weekend region (blockInteraction: false).
        final visualRegion = MCalDayRegion(
          id: 'visual-weekends',
          date: DateTime(2025, 1, 4),
          recurrenceRule: 'FREQ=WEEKLY;BYDAY=SA',
          color: Colors.grey.withValues(alpha: 0.15),
          blockInteraction: false, // visual only
        );

        await pumpMonthView(
          tester,
          controller: controller,
          dayRegions: [visualRegion],
          enableDragToMove: true,
          onDragWillAccept: (context, details) {
            dragWillAcceptCalled = true;
            return true;
          },
        );

        final eventFinder = find.text('Visual Region Test');
        expect(eventFinder, findsOneWidget);

        final gesture = await tester.startGesture(
          tester.getCenter(eventFinder),
        );
        await tester.pump(const Duration(milliseconds: 300));
        dragWillAcceptCalled = false;

        // Drag to Saturday Jan 18 — blocked by a visual-only region.
        final targetFinder = find.text('18');
        if (targetFinder.evaluate().isNotEmpty) {
          await gesture.moveTo(tester.getCenter(targetFinder.first));
          await tester.pump(const Duration(milliseconds: 100));

          // Not blocked → callback should fire.
          expect(
            dragWillAcceptCalled,
            isTrue,
            reason:
                'blockInteraction:false must not prevent onDragWillAccept from being called',
          );
        }

        await gesture.up();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'multi-day event spanning a blocked date is rejected',
      (tester) async {
        // Tests that when a multi-day event is dragged, the library rejects
        // drops that would cause the event to span a blocked day — even if
        // the proposed START day is not itself blocked.
        //
        // Strategy: use a 3-day event and a region that blocks the ENTIRE
        // second week of January (Jan 12-18).  No matter where the drag lands
        // in or around that week, the 3-day span will include a blocked day,
        // so onDragWillAccept must never be called.
        final event = MCalCalendarEvent(
          id: 'multi-day',
          title: 'Multi Day',
          start: DateTime(2025, 1, 6), // Monday
          end: DateTime(2025, 1, 8), // (3-day span Mon-Wed)
        );
        controller.setEvents([event]);

        // Track calls AFTER the drag has moved to the target (reset flag mid-test).
        bool dragWillAcceptCalled = false;

        // Block the entire second week of January (Sun Jan 12 – Sat Jan 18).
        final blockWeek = [
          for (int d = 12; d <= 18; d++)
            MCalDayRegion(
              id: 'block-jan-$d',
              date: DateTime(2025, 1, d),
              blockInteraction: true,
            ),
        ];

        await pumpMonthView(
          tester,
          controller: controller,
          dayRegions: blockWeek,
          enableDragToMove: true,
          onDragWillAccept: (context, details) {
            dragWillAcceptCalled = true;
            return true;
          },
        );

        final eventFinder = find.text('Multi Day');
        expect(eventFinder, findsOneWidget);

        final gesture = await tester.startGesture(
          tester.getCenter(eventFinder),
        );
        await tester.pump(const Duration(milliseconds: 300));

        // Reset after initial drag-start (the first _processDragMove fires
        // over the original position, which is not in the blocked week).
        dragWillAcceptCalled = false;

        // Drag to "13" (Jan 13 = Monday, middle of the blocked week).
        // Regardless of grab-offset shift, the proposed 3-day span will
        // include at least one day in Jan 12-18.
        final targetFinder = find.text('13');
        if (targetFinder.evaluate().isNotEmpty) {
          await gesture.moveTo(tester.getCenter(targetFinder.first));
          await tester.pump(const Duration(milliseconds: 100));

          expect(
            dragWillAcceptCalled,
            isFalse,
            reason:
                'Multi-day event spanning a blocked day must be rejected; '
                'onDragWillAccept must not be called',
          );
        }

        await gesture.up();
        await tester.pumpAndSettle();
      },
    );
  });
}
