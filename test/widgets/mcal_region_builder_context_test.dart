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
  // 1. Month View – MCalDayCellContext.regions
  // =========================================================================

  group('MCalDayCellContext.regions', () {
    late MCalEventController controller;

    setUp(() {
      controller = MCalEventController(
        initialDate: DateTime(2026, 6, 15),
      );
    });

    tearDown(() => controller.dispose());

    testWidgets(
      'dayCellBuilder receives all-day and timed regions for the cell date',
      (tester) async {
        // Add mixed all-day and timed regions.
        controller.addRegions([
          MCalRegion(
            id: 'holiday',
            start: DateTime(2026, 6, 15),
            end: DateTime(2026, 6, 15),
            isAllDay: true,
            text: 'Holiday',
          ),
          MCalRegion(
            id: 'focus',
            start: DateTime(2026, 6, 15, 9, 0),
            end: DateTime(2026, 6, 15, 10, 0),
            isAllDay: false,
            text: 'Focus Time',
          ),
        ]);

        final capturedContexts = <MCalDayCellContext>[];

        await tester.pumpWidget(
          buildTestApp(
            child: SizedBox(
              width: 400,
              height: 600,
              child: MCalMonthView(
                controller: controller,
                dayCellBuilder: (context, ctx, defaultCell) {
                  capturedContexts.add(ctx);
                  return defaultCell;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find the context for June 15.
        final june15Contexts = capturedContexts.where(
          (c) => c.date.month == 6 && c.date.day == 15,
        );
        expect(june15Contexts, isNotEmpty, reason: 'Should build a cell for June 15');

        final ctx = june15Contexts.first;
        expect(ctx.regions, isNotEmpty, reason: 'Regions list should be populated');

        // Verify both all-day and timed regions are present.
        final regionIds = ctx.regions.map((r) => r.id).toSet();
        expect(
          regionIds,
          containsAll(['holiday', 'focus']),
          reason: 'Both the all-day and timed region should be in the context',
        );
      },
    );

    testWidgets(
      'dayCellBuilder receives empty regions list for dates without regions',
      (tester) async {
        // Add a region only for June 15.
        controller.addRegions([
          MCalRegion(
            id: 'single-day',
            start: DateTime(2026, 6, 15),
            end: DateTime(2026, 6, 15),
            isAllDay: true,
          ),
        ]);

        final capturedContexts = <MCalDayCellContext>[];

        await tester.pumpWidget(
          buildTestApp(
            child: SizedBox(
              width: 400,
              height: 600,
              child: MCalMonthView(
                controller: controller,
                dayCellBuilder: (context, ctx, defaultCell) {
                  capturedContexts.add(ctx);
                  return defaultCell;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // A different date (e.g. June 20) should have no regions.
        final june20Contexts = capturedContexts.where(
          (c) => c.date.month == 6 && c.date.day == 20,
        );
        expect(june20Contexts, isNotEmpty);
        expect(june20Contexts.first.regions, isEmpty);
      },
    );
  });

  // =========================================================================
  // 2. Month View – MCalEventTileContext.regions
  // =========================================================================

  group('MCalEventTileContext.regions (Month View)', () {
    late MCalEventController controller;

    setUp(() {
      controller = MCalEventController(
        initialDate: DateTime(2026, 6, 15),
      );
    });

    tearDown(() => controller.dispose());

    testWidgets(
      'eventTileBuilder is called and controller provides regions for the event display date',
      (tester) async {
        // Add an event on June 15.
        controller.addEvents([
          MCalCalendarEvent(
            id: 'ev-1',
            title: 'Team Standup',
            start: DateTime(2026, 6, 15, 10, 0),
            end: DateTime(2026, 6, 15, 10, 30),
          ),
        ]);

        // Add regions on June 15.
        controller.addRegions([
          MCalRegion(
            id: 'blocked-afternoon',
            start: DateTime(2026, 6, 15, 14, 0),
            end: DateTime(2026, 6, 15, 17, 0),
            isAllDay: false,
            blockInteraction: true,
            text: 'Blocked Afternoon',
          ),
          MCalRegion(
            id: 'holiday-15',
            start: DateTime(2026, 6, 15),
            end: DateTime(2026, 6, 15),
            isAllDay: true,
            text: 'Holiday',
          ),
        ]);

        final capturedContexts = <MCalEventTileContext>[];

        await tester.pumpWidget(
          buildTestApp(
            child: SizedBox(
              width: 400,
              height: 600,
              child: MCalMonthView(
                controller: controller,
                eventTileBuilder: (context, ctx, defaultTile) {
                  capturedContexts.add(ctx);
                  return defaultTile;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(capturedContexts, isNotEmpty, reason: 'Event tile should be built');

        final ctx = capturedContexts.firstWhere(
          (c) => c.event.id == 'ev-1',
        );
        expect(ctx.event.id, 'ev-1');

        // Verify the controller has regions for the event's display date.
        // This confirms the data flow: regions are on the controller and
        // accessible via getRegionsForDate for the event's date.
        final controllerRegions = controller.getRegionsForDate(ctx.displayDate);
        expect(controllerRegions, isNotEmpty,
            reason: 'Controller should have regions for the event display date');

        final regionIds = controllerRegions.map((r) => r.id).toSet();
        expect(regionIds, contains('holiday-15'));
      },
    );

    testWidgets(
      'dayCellBuilder regions include both all-day and timed regions for event date',
      (tester) async {
        // Add an event and regions on the same date.
        controller.addEvents([
          MCalCalendarEvent(
            id: 'ev-2',
            title: 'Sprint Planning',
            start: DateTime(2026, 6, 15, 14, 0),
            end: DateTime(2026, 6, 15, 15, 0),
          ),
        ]);

        controller.addRegions([
          MCalRegion(
            id: 'timed-r',
            start: DateTime(2026, 6, 15, 9, 0),
            end: DateTime(2026, 6, 15, 10, 0),
            isAllDay: false,
            text: 'Timed Region',
          ),
          MCalRegion(
            id: 'allday-r',
            start: DateTime(2026, 6, 15),
            end: DateTime(2026, 6, 15),
            isAllDay: true,
            text: 'All-Day Region',
          ),
        ]);

        MCalDayCellContext? cellCtxForJune15;
        MCalEventTileContext? eventCtx;

        await tester.pumpWidget(
          buildTestApp(
            child: SizedBox(
              width: 400,
              height: 600,
              child: MCalMonthView(
                controller: controller,
                dayCellBuilder: (context, ctx, defaultCell) {
                  if (ctx.date.month == 6 && ctx.date.day == 15) {
                    cellCtxForJune15 = ctx;
                  }
                  return defaultCell;
                },
                eventTileBuilder: (context, ctx, defaultTile) {
                  if (ctx.event.id == 'ev-2') {
                    eventCtx = ctx;
                  }
                  return defaultTile;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // The cell context for June 15 should have both regions.
        expect(cellCtxForJune15, isNotNull);
        final cellRegionIds =
            cellCtxForJune15!.regions.map((r) => r.id).toSet();
        expect(cellRegionIds, contains('timed-r'));
        expect(cellRegionIds, contains('allday-r'));

        // The event tile should also be built for June 15.
        expect(eventCtx, isNotNull);
        expect(eventCtx!.event.id, 'ev-2');
      },
    );
  });

  // =========================================================================
  // 3. Day View – MCalTimedEventTileContext.regions
  // =========================================================================

  group('MCalTimedEventTileContext.regions (Day View)', () {
    late MCalEventController controller;
    final testDate = DateTime(2026, 6, 15);

    setUp(() {
      controller = MCalEventController(initialDate: testDate);
    });

    tearDown(() => controller.dispose());

    testWidgets(
      'timedEventTileBuilder receives regions for the display date',
      (tester) async {
        // Add an event.
        controller.addEvents([
          MCalCalendarEvent(
            id: 'meeting',
            title: 'Design Review',
            start: DateTime(2026, 6, 15, 10, 0),
            end: DateTime(2026, 6, 15, 11, 0),
          ),
        ]);

        // Add timed regions.
        controller.addRegions([
          MCalRegion(
            id: 'lunch',
            start: DateTime(2026, 6, 15, 12, 0),
            end: DateTime(2026, 6, 15, 13, 0),
            isAllDay: false,
            text: 'Lunch',
          ),
          MCalRegion(
            id: 'holiday-allday',
            start: DateTime(2026, 6, 15),
            end: DateTime(2026, 6, 15),
            isAllDay: true,
            text: 'Company Holiday',
          ),
        ]);

        final capturedContexts = <MCalTimedEventTileContext>[];

        await tester.pumpWidget(
          buildTestApp(
            child: SizedBox(
              width: 600,
              height: 1000,
              child: MCalDayView(
                controller: controller,
                startHour: 8,
                endHour: 18,
                hourHeight: 80,
                showNavigator: false,
                showCurrentTimeIndicator: false,
                timedEventTileBuilder: (context, event, ctx, defaultTile) {
                  capturedContexts.add(ctx);
                  return defaultTile;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(capturedContexts, isNotEmpty, reason: 'Timed event tile should be built');

        final ctx = capturedContexts.firstWhere(
          (c) => c.event.id == 'meeting',
        );
        expect(ctx.regions, isNotEmpty, reason: 'Regions should be populated');

        final regionIds = ctx.regions.map((r) => r.id).toSet();
        expect(regionIds, contains('lunch'));
        expect(regionIds, contains('holiday-allday'));
      },
    );
  });
}
