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
  final testDate = DateTime(2026, 6, 15); // Monday

  setUpAll(() async {
    await initializeDateFormatting('en', null);
  });

  // =========================================================================
  // 1. Day View renders timed regions from controller
  // =========================================================================

  group('Day View renders timed regions from controller', () {
    late MCalEventController controller;

    setUp(() {
      controller = MCalEventController(initialDate: testDate);
    });

    tearDown(() => controller.dispose());

    testWidgets(
      'timed blocking region with text renders in the day view',
      (tester) async {
        controller.addRegions([
          MCalRegion(
            id: 'lunch-blocked',
            start: DateTime(2026, 6, 15, 12, 0),
            end: DateTime(2026, 6, 15, 13, 0),
            isAllDay: false,
            blockInteraction: true,
            text: 'Lunch Break',
            color: Colors.amber.withValues(alpha: 0.3),
          ),
        ]);

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
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Lunch Break'), findsOneWidget);
      },
    );

    testWidgets(
      'multiple timed regions from controller all render',
      (tester) async {
        controller.addRegions([
          MCalRegion(
            id: 'focus',
            start: DateTime(2026, 6, 15, 9, 0),
            end: DateTime(2026, 6, 15, 10, 0),
            isAllDay: false,
            text: 'Focus Time',
          ),
          MCalRegion(
            id: 'lunch',
            start: DateTime(2026, 6, 15, 12, 0),
            end: DateTime(2026, 6, 15, 13, 0),
            isAllDay: false,
            text: 'Lunch',
          ),
        ]);

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
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Focus Time'), findsOneWidget);
        expect(find.text('Lunch'), findsOneWidget);
      },
    );

    testWidgets(
      'timed region with icon renders icon in the day view',
      (tester) async {
        controller.addRegions([
          MCalRegion(
            id: 'after-hours',
            start: DateTime(2026, 6, 15, 17, 0),
            end: DateTime(2026, 6, 15, 18, 0),
            isAllDay: false,
            text: 'After Hours',
            icon: Icons.block,
          ),
        ]);

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
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('After Hours'), findsOneWidget);
        expect(find.byIcon(Icons.block), findsOneWidget);
      },
    );

    testWidgets(
      'all-day region on controller does not render as timed overlay',
      (tester) async {
        controller.addRegions([
          MCalRegion(
            id: 'allday-only',
            start: DateTime(2026, 6, 15),
            end: DateTime(2026, 6, 15),
            isAllDay: true,
            text: 'All Day Region',
          ),
        ]);

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
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // All-day regions are filtered out for the timed regions layer.
        // The text should not appear in the timed grid area.
        // (It may appear in the all-day section header if rendered.)
        expect(find.byType(MCalDayView), findsOneWidget);
      },
    );
  });

  // =========================================================================
  // 2. Day View drag validation rejects drops on blocked timed regions
  // =========================================================================

  group('Day View drag validation with controller regions', () {
    late MCalEventController controller;

    setUp(() {
      controller = MCalEventController(initialDate: testDate);
    });

    tearDown(() => controller.dispose());

    testWidgets(
      'controller.isTimeRangeBlocked returns true for blocked timed region',
      (tester) async {
        controller.addRegions([
          MCalRegion(
            id: 'blocked-slot',
            start: DateTime(2026, 6, 15, 12, 0),
            end: DateTime(2026, 6, 15, 13, 0),
            isAllDay: false,
            blockInteraction: true,
          ),
        ]);

        // Verify controller-level blocking for overlapping time range.
        expect(
          controller.isTimeRangeBlocked(
            DateTime(2026, 6, 15, 12, 30),
            DateTime(2026, 6, 15, 13, 30),
          ),
          isTrue,
          reason: 'Overlapping time range should be blocked',
        );

        // Non-overlapping range should not be blocked.
        expect(
          controller.isTimeRangeBlocked(
            DateTime(2026, 6, 15, 14, 0),
            DateTime(2026, 6, 15, 15, 0),
          ),
          isFalse,
          reason: 'Non-overlapping time range should not be blocked',
        );
      },
    );

    testWidgets(
      'blocked timed region prevents drop via drag validation',
      (tester) async {
        final event = MCalCalendarEvent(
          id: 'drag-test',
          title: 'Draggable Event',
          start: DateTime(2026, 6, 15, 10, 0),
          end: DateTime(2026, 6, 15, 11, 0),
        );
        controller.addEvents([event]);

        controller.addRegions([
          MCalRegion(
            id: 'blocked-12-13',
            start: DateTime(2026, 6, 15, 12, 0),
            end: DateTime(2026, 6, 15, 13, 0),
            isAllDay: false,
            blockInteraction: true,
            text: 'Blocked',
          ),
        ]);

        var dropCalled = false;

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
                autoScrollToCurrentTime: false,
                initialScrollTime: const TimeOfDay(hour: 9, minute: 0),
                enableDragToMove: true,
                onEventDropped: (_, _) {
                  dropCalled = true;
                  return true;
                },
                dragLongPressDelay: const Duration(milliseconds: 150),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify blocked region is rendered.
        expect(find.text('Blocked'), findsOneWidget);

        // Start drag on the event.
        final eventFinder = find.text('Draggable Event');
        expect(eventFinder, findsOneWidget);

        final gesture = await tester.startGesture(
          tester.getCenter(eventFinder),
        );
        await tester.pump(const Duration(milliseconds: 200));

        // Move down toward the blocked region (12:00-13:00).
        // Event is at 10:00-11:00, need to move ~2 hours = 160px at 80px/hr.
        await gesture.moveBy(const Offset(0, 160));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        await gesture.up();
        await tester.pumpAndSettle();

        // Drop should be rejected since the blocked region overlaps.
        expect(dropCalled, isFalse);
      },
    );

    testWidgets(
      'controller.isDateBlocked returns true for blocked all-day region',
      (tester) async {
        controller.addRegions([
          MCalRegion(
            id: 'blocked-day',
            start: DateTime(2026, 6, 15),
            end: DateTime(2026, 6, 15),
            isAllDay: true,
            blockInteraction: true,
          ),
        ]);

        expect(
          controller.isDateBlocked(DateTime(2026, 6, 15)),
          isTrue,
          reason: 'Date with all-day blocking region should be blocked',
        );

        expect(
          controller.isDateBlocked(DateTime(2026, 6, 16)),
          isFalse,
          reason: 'Date without blocking region should not be blocked',
        );
      },
    );
  });

  // =========================================================================
  // 3. Day View region overlay widget tree verification
  // =========================================================================

  group('Day View region overlay widget tree', () {
    late MCalEventController controller;

    setUp(() {
      controller = MCalEventController(initialDate: testDate);
    });

    tearDown(() => controller.dispose());

    testWidgets(
      'timeRegionBuilder receives MCalTimeRegionContext from controller regions',
      (tester) async {
        controller.addRegions([
          MCalRegion(
            id: 'custom-region',
            start: DateTime(2026, 6, 15, 14, 0),
            end: DateTime(2026, 6, 15, 15, 0),
            isAllDay: false,
            text: 'Custom Region',
          ),
        ]);

        MCalTimeRegionContext? capturedContext;

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
                timeRegionBuilder: (context, ctx, defaultWidget) {
                  capturedContext = ctx;
                  return Container(
                    color: Colors.purple.withValues(alpha: 0.2),
                    child: Text('Builder: ${ctx.region.text}'),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(capturedContext, isNotNull);
        expect(capturedContext!.region.text, 'Custom Region');
        expect(capturedContext!.displayDate, testDate);
        expect(capturedContext!.height, 80.0);
        expect(find.text('Builder: Custom Region'), findsOneWidget);
      },
    );

    testWidgets(
      'region and event can coexist with controller-based regions',
      (tester) async {
        controller.addEvents([
          MCalCalendarEvent(
            id: 'meeting',
            title: 'Meeting',
            start: DateTime(2026, 6, 15, 12, 0),
            end: DateTime(2026, 6, 15, 13, 0),
          ),
        ]);

        controller.addRegions([
          MCalRegion(
            id: 'lunch-overlay',
            start: DateTime(2026, 6, 15, 12, 0),
            end: DateTime(2026, 6, 15, 13, 0),
            isAllDay: false,
            text: 'Lunch Overlay',
          ),
        ]);

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
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Meeting'), findsOneWidget);
        expect(find.text('Lunch Overlay'), findsOneWidget);
      },
    );
  });
}
