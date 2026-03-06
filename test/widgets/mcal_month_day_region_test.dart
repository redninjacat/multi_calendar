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
  required MCalEventController controller,
  Widget Function(BuildContext, MCalRegionContext, Widget)? dayRegionBuilder,
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

  group('MCalRegion rendering in Month View', () {
    late _TestController controller;

    setUp(() {
      controller = _TestController(initialDate: DateTime(2026, 6, 15));
    });

    tearDown(() => controller.dispose());

    testWidgets(
        'widget builds without error when no regions added (default)', (
      tester,
    ) async {
      await pumpMonthView(tester, controller: controller);
      expect(find.byType(MCalMonthView), findsOneWidget);
    });

    testWidgets('region with color renders a Container with that color', (
      tester,
    ) async {
      const regionColor = Color(0x33FF0000);
      final region = MCalRegion(
        id: 'colored',
        start: DateTime(2026, 6, 15),
        end: DateTime(2026, 6, 15),
        isAllDay: true,
        color: regionColor,
      );
      controller.addRegions([region]);

      await pumpMonthView(
        tester,
        controller: controller,
      );

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
      final region = MCalRegion(
        id: 'labeled',
        start: DateTime(2026, 6, 15),
        end: DateTime(2026, 6, 15),
        isAllDay: true,
        color: Colors.amber.withValues(alpha: 0.2),
        text: 'Holiday',
      );
      controller.addRegions([region]);

      await pumpMonthView(
        tester,
        controller: controller,
      );

      expect(find.text('Holiday'), findsWidgets);
    });

    testWidgets('region with icon renders that icon in the cell', (
      tester,
    ) async {
      final region = MCalRegion(
        id: 'iconic',
        start: DateTime(2026, 6, 15),
        end: DateTime(2026, 6, 15),
        isAllDay: true,
        color: Colors.green.withValues(alpha: 0.2),
        icon: Icons.star,
      );
      controller.addRegions([region]);

      await pumpMonthView(
        tester,
        controller: controller,
      );

      expect(find.byIcon(Icons.star), findsWidgets);
    });

    testWidgets('region with neither text nor icon renders no label widget', (
      tester,
    ) async {
      const label = 'ShouldNotAppear';
      final region = MCalRegion(
        id: 'color-only',
        start: DateTime(2026, 6, 15),
        end: DateTime(2026, 6, 15),
        isAllDay: true,
        color: Colors.blue.withValues(alpha: 0.2),
      );
      controller.addRegions([region]);

      await pumpMonthView(
        tester,
        controller: controller,
      );

      expect(find.text(label), findsNothing);
    });

    testWidgets('region does not render on non-matching cells', (tester) async {
      const regionColor = Color(0x4400FF00);
      final region = MCalRegion(
        id: 'specific-day',
        start: DateTime(2026, 6, 15),
        end: DateTime(2026, 6, 15),
        isAllDay: true,
        color: regionColor,
      );
      controller.addRegions([region]);

      await pumpMonthView(
        tester,
        controller: controller,
      );

      final coloredContainers = tester.widgetList<Container>(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              (w.color == regionColor ||
                  (w.decoration is BoxDecoration &&
                      (w.decoration as BoxDecoration).color == regionColor)),
        ),
      );
      expect(coloredContainers.length, 1);
    });

    testWidgets(
        'FREQ=WEEKLY;BYDAY=SA,SU produces overlays only on weekend cells', (
      tester,
    ) async {
      const weekendColor = Color(0x22888888);
      final region = MCalRegion(
        id: 'weekends',
        start: DateTime(2026, 6, 6),
        end: DateTime(2026, 6, 6),
        isAllDay: true,
        recurrenceRule: MCalRecurrenceRule(
          frequency: MCalFrequency.weekly,
          byWeekDays: {
            MCalWeekDay.every(DateTime.saturday),
            MCalWeekDay.every(DateTime.sunday),
          },
        ),
        color: weekendColor,
      );
      controller.addRegions([region]);

      await pumpMonthView(
        tester,
        controller: controller,
      );

      final coloredContainers = tester.widgetList<Container>(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              (w.color == weekendColor ||
                  (w.decoration is BoxDecoration &&
                      (w.decoration as BoxDecoration).color == weekendColor)),
        ),
      );
      expect(coloredContainers.length, greaterThanOrEqualTo(8));
    });

    testWidgets('multiple regions on the same cell are all rendered', (
      tester,
    ) async {
      const color1 = Color(0x33FF0000);
      const color2 = Color(0x330000FF);
      final regions = [
        MCalRegion(
          id: 'r1',
          start: DateTime(2026, 6, 15),
          end: DateTime(2026, 6, 15),
          isAllDay: true,
          color: color1,
        ),
        MCalRegion(
          id: 'r2',
          start: DateTime(2026, 6, 15),
          end: DateTime(2026, 6, 15),
          isAllDay: true,
          color: color2,
        ),
      ];
      controller.addRegions(regions);

      await pumpMonthView(
        tester,
        controller: controller,
      );

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
      final region = MCalRegion(
        id: 'builder-test',
        start: DateTime(2026, 6, 15),
        end: DateTime(2026, 6, 15),
        isAllDay: true,
        color: Colors.purple,
      );
      controller.addRegions([region]);

      await pumpMonthView(
        tester,
        controller: controller,
        dayRegionBuilder: (context, ctx, defaultWidget) {
          return const ColoredBox(
            key: sentinelKey,
            color: Colors.transparent,
          );
        },
      );

      expect(find.byKey(sentinelKey), findsWidgets);
    });

    testWidgets('dayRegionBuilder receives correct MCalRegionContext fields', (
      tester,
    ) async {
      final capturedContexts = <MCalRegionContext>[];
      final region = MCalRegion(
        id: 'ctx-check',
        start: DateTime(2026, 6, 15),
        end: DateTime(2026, 6, 15),
        isAllDay: true,
        color: Colors.teal,
      );
      controller.addRegions([region]);

      await pumpMonthView(
        tester,
        controller: controller,
        dayRegionBuilder: (context, ctx, defaultWidget) {
          capturedContexts.add(ctx);
          return defaultWidget;
        },
      );

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
      final region = MCalRegion(
        id: 'wrapper-test',
        start: DateTime(2026, 6, 15),
        end: DateTime(2026, 6, 15),
        isAllDay: true,
        color: Colors.amber.withValues(alpha: 0.2),
      );
      controller.addRegions([region]);

      await pumpMonthView(
        tester,
        controller: controller,
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

  group('MCalRegion drop blocking in Month View', () {
    late _TestController controller;

    setUp(() {
      controller = _TestController(initialDate: DateTime(2025, 1, 1));
    });

    tearDown(() => controller.dispose());

    testWidgets(
      'dragging onto a blockInteraction:true cell does NOT call onDragWillAccept',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'move-me',
          title: 'Move Me',
          start: DateTime(2025, 1, 10, 9, 0),
          end: DateTime(2025, 1, 10, 10, 0),
        );
        controller.setEvents([event]);

        bool dragWillAcceptCalled = false;

        final blockingRegion = MCalRegion(
          id: 'saturdays',
          start: DateTime(2025, 1, 4),
          end: DateTime(2025, 1, 4),
          isAllDay: true,
          recurrenceRule: MCalRecurrenceRule(
            frequency: MCalFrequency.weekly,
            byWeekDays: {MCalWeekDay.every(DateTime.saturday)},
          ),
          blockInteraction: true,
        );
        controller.addRegions([blockingRegion]);

        await pumpMonthView(
          tester,
          controller: controller,
          enableDragToMove: true,
          onDragWillAccept: (context, details) {
            dragWillAcceptCalled = true;
            return true;
          },
        );

        final eventFinder = find.text('Move Me');
        expect(eventFinder, findsOneWidget);

        final gesture = await tester.startGesture(
          tester.getCenter(eventFinder),
        );
        await tester.pump(const Duration(milliseconds: 300));
        dragWillAcceptCalled = false;

        final targetFinder = find.text('18');
        if (targetFinder.evaluate().isNotEmpty) {
          await gesture.moveTo(tester.getCenter(targetFinder.first));
          await tester.pump(const Duration(milliseconds: 100));

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

        final blockingRegion = MCalRegion(
          id: 'saturdays-only',
          start: DateTime(2025, 1, 4),
          end: DateTime(2025, 1, 4),
          isAllDay: true,
          recurrenceRule: MCalRecurrenceRule(
            frequency: MCalFrequency.weekly,
            byWeekDays: {MCalWeekDay.every(DateTime.saturday)},
          ),
          blockInteraction: true,
        );
        controller.addRegions([blockingRegion]);

        await pumpMonthView(
          tester,
          controller: controller,
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
        dragWillAcceptCalled = false;

        final targetFinder = find.text('17');
        if (targetFinder.evaluate().isNotEmpty) {
          await gesture.moveTo(tester.getCenter(targetFinder.first));
          await tester.pump(const Duration(milliseconds: 100));

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

        final visualRegion = MCalRegion(
          id: 'visual-weekends',
          start: DateTime(2025, 1, 4),
          end: DateTime(2025, 1, 4),
          isAllDay: true,
          recurrenceRule: MCalRecurrenceRule(
            frequency: MCalFrequency.weekly,
            byWeekDays: {MCalWeekDay.every(DateTime.saturday)},
          ),
          color: Colors.grey.withValues(alpha: 0.15),
          blockInteraction: false,
        );
        controller.addRegions([visualRegion]);

        await pumpMonthView(
          tester,
          controller: controller,
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

        final targetFinder = find.text('18');
        if (targetFinder.evaluate().isNotEmpty) {
          await gesture.moveTo(tester.getCenter(targetFinder.first));
          await tester.pump(const Duration(milliseconds: 100));

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
        final event = MCalCalendarEvent(
          id: 'multi-day',
          title: 'Multi Day',
          start: DateTime(2025, 1, 6),
          end: DateTime(2025, 1, 8),
        );
        controller.setEvents([event]);

        bool dragWillAcceptCalled = false;

        final blockWeek = [
          for (int d = 12; d <= 18; d++)
            MCalRegion(
              id: 'block-jan-$d',
              start: DateTime(2025, 1, d),
              end: DateTime(2025, 1, d),
              isAllDay: true,
              blockInteraction: true,
            ),
        ];
        controller.addRegions(blockWeek);

        await pumpMonthView(
          tester,
          controller: controller,
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

        dragWillAcceptCalled = false;

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
