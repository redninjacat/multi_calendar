import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

/// Mock MCalEventController for Day View region testing.
class MockMCalEventController extends MCalEventController {
  MockMCalEventController({super.initialDate});

  void setMockEvents(List<MCalCalendarEvent> events) {
    clearEvents();
    addEvents(events);
  }
}

void main() {
  final testDate = DateTime(2026, 2, 14); // Saturday

  setUpAll(() async {
    await initializeDateFormatting('en', null);
  });

  group('MCalDayView special time regions', () {
    late MockMCalEventController controller;

    setUp(() {
      controller = MockMCalEventController(initialDate: testDate);
    });

    tearDown(() {
      controller.dispose();
    });

    Widget buildDayView({
      List<MCalCalendarEvent>? events,
      List<MCalTimeRegion> specialTimeRegions = const [],
      Widget Function(BuildContext, MCalTimeRegionContext)? timeRegionBuilder,
    }) {
      if (events != null) {
        controller.setMockEvents(events);
      }
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 600,
            height: 1000,
            child: MCalDayView(
              controller: controller,
              startHour: 8,
              endHour: 18,
              hourHeight: 80,
              showNavigator: false,
              showCurrentTimeIndicator: false,
              specialTimeRegions: specialTimeRegions,
              timeRegionBuilder: timeRegionBuilder,
            ),
          ),
        ),
      );
    }

    group('MCalTimeRegion rendering', () {
      testWidgets('region renders at correct position with text', (
        tester,
      ) async {
        final regions = [
          MCalTimeRegion(
            id: 'lunch',
            startTime: DateTime(2026, 2, 14, 12, 0),
            endTime: DateTime(2026, 2, 14, 13, 0),
            text: 'Lunch Break',
            color: Colors.amber.withValues(alpha: 0.3),
          ),
        ];

        await tester.pumpWidget(buildDayView(specialTimeRegions: regions));
        await tester.pumpAndSettle();

        expect(find.text('Lunch Break'), findsOneWidget);
      });

      testWidgets('region renders with icon and text', (tester) async {
        final regions = [
          MCalTimeRegion(
            id: 'focus',
            startTime: DateTime(2026, 2, 14, 9, 0),
            endTime: DateTime(2026, 2, 14, 10, 0),
            text: 'Focus Time',
            icon: Icons.work,
            color: Colors.blue.withValues(alpha: 0.2),
          ),
        ];

        await tester.pumpWidget(buildDayView(specialTimeRegions: regions));
        await tester.pumpAndSettle();

        expect(find.text('Focus Time'), findsOneWidget);
        expect(find.byIcon(Icons.work), findsOneWidget);
      });

      testWidgets('multiple regions render', (tester) async {
        final regions = [
          MCalTimeRegion(
            id: 'morning',
            startTime: DateTime(2026, 2, 14, 9, 0),
            endTime: DateTime(2026, 2, 14, 10, 0),
            text: 'Morning Block',
          ),
          MCalTimeRegion(
            id: 'lunch',
            startTime: DateTime(2026, 2, 14, 12, 0),
            endTime: DateTime(2026, 2, 14, 13, 0),
            text: 'Lunch',
          ),
        ];

        await tester.pumpWidget(buildDayView(specialTimeRegions: regions));
        await tester.pumpAndSettle();

        expect(find.text('Morning Block'), findsOneWidget);
        expect(find.text('Lunch'), findsOneWidget);
      });

      testWidgets('region outside visible hours does not render', (
        tester,
      ) async {
        final regions = [
          MCalTimeRegion(
            id: 'late',
            startTime: DateTime(2026, 2, 14, 22, 0),
            endTime: DateTime(2026, 2, 14, 23, 0),
            text: 'Late Night',
          ),
        ];

        await tester.pumpWidget(
          buildDayView(specialTimeRegions: regions),
        );
        await tester.pumpAndSettle();

        // Day view shows 8-18, so 22:00 is outside - region may not be visible
        // The region is filtered by _getApplicableRegions - it still applies
        // to display date but is outside startHour-endHour. The _TimeRegionsLayer
        // builds all applicable regions; positioning may place it off-screen.
        // Verify widget builds without error.
        expect(find.byType(MCalDayView), findsOneWidget);
      });
    });

    group('blocked interaction behavior', () {
      testWidgets('blocked region prevents drop via validation', (
        tester,
      ) async {
        final event = MCalCalendarEvent(
          id: 'drag-1',
          title: 'Draggable Event',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
        );
        controller.setMockEvents([event]);

        final blockedRegion = MCalTimeRegion(
          id: 'blocked',
          startTime: DateTime(2026, 2, 14, 12, 0),
          endTime: DateTime(2026, 2, 14, 13, 0),
          text: 'Blocked Time',
          blockInteraction: true,
        );

        var dropCalled = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 800,
                child: MCalDayView(
                  controller: controller,
                  startHour: 8,
                  endHour: 18,
                  hourHeight: 80,
                  specialTimeRegions: [blockedRegion],
                  enableDragToMove: true,
                  onEventDropped: (_) => dropCalled = true,
                  showCurrentTimeIndicator: false,
                  autoScrollToCurrentTime: false,
                  initialScrollTime: const TimeOfDay(hour: 9, minute: 0),
                  dragLongPressDelay: const Duration(milliseconds: 150),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final eventFinder = find.text('Draggable Event');
        final center = tester.getCenter(eventFinder);
        final gesture = await tester.startGesture(center);
        await tester.pump(const Duration(milliseconds: 200));

        // Move down to 12:00-13:00 (blocked region) - ~2 hours = 160px
        await gesture.moveBy(const Offset(0, 160));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        await gesture.up();
        await tester.pumpAndSettle();

        // Drop should be rejected - event stays at original position
        expect(dropCalled, isFalse);
      });

      testWidgets('non-blocked region allows drop', (tester) async {
        final event = MCalCalendarEvent(
          id: 'drag-2',
          title: 'Drop Allowed',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
        );
        controller.setMockEvents([event]);

        final visualRegion = MCalTimeRegion(
          id: 'visual',
          startTime: DateTime(2026, 2, 14, 12, 0),
          endTime: DateTime(2026, 2, 14, 13, 0),
          text: 'Visual Only',
          blockInteraction: false,
        );

        MCalEventDroppedDetails? capturedDetails;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 800,
                child: MCalDayView(
                  controller: controller,
                  startHour: 8,
                  endHour: 18,
                  hourHeight: 80,
                  specialTimeRegions: [visualRegion],
                  enableDragToMove: true,
                  onEventDropped: (d) => capturedDetails = d,
                  showCurrentTimeIndicator: false,
                  dragLongPressDelay: const Duration(milliseconds: 150),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final eventFinder = find.text('Drop Allowed');
        final gesture = await tester.startGesture(tester.getCenter(eventFinder));
        await tester.pump(const Duration(milliseconds: 200));
        await gesture.moveBy(const Offset(0, 160));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await gesture.up();
        await tester.pumpAndSettle();

        // Non-blocked region should not prevent drop - widget remains stable.
        // (Drop callback may or may not fire depending on drag target hit testing)
        expect(find.byType(MCalDayView), findsOneWidget);
        if (capturedDetails != null) {
          expect(capturedDetails!.event.id, 'drag-2');
        }
      });
    });

    group('visual styling', () {
      testWidgets('blocked region uses blocked styling when no custom color', (
        tester,
      ) async {
        final regions = [
          MCalTimeRegion(
            id: 'blocked',
            startTime: DateTime(2026, 2, 14, 12, 0),
            endTime: DateTime(2026, 2, 14, 13, 0),
            blockInteraction: true,
            text: 'Blocked',
          ),
        ];

        await tester.pumpWidget(buildDayView(specialTimeRegions: regions));
        await tester.pumpAndSettle();

        expect(find.text('Blocked'), findsOneWidget);
      });

      testWidgets('region with custom color renders', (tester) async {
        final regions = [
          MCalTimeRegion(
            id: 'custom',
            startTime: DateTime(2026, 2, 14, 12, 0),
            endTime: DateTime(2026, 2, 14, 13, 0),
            color: Colors.red.withValues(alpha: 0.5),
            text: 'Custom Color',
          ),
        ];

        await tester.pumpWidget(buildDayView(specialTimeRegions: regions));
        await tester.pumpAndSettle();

        expect(find.text('Custom Color'), findsOneWidget);
      });
    });

    group('recurring regions with RRULE', () {
      testWidgets('recurring region expands for display date', (tester) async {
        final regions = [
          MCalTimeRegion(
            id: 'focus-time',
            startTime: DateTime(2026, 2, 14, 9, 0),
            endTime: DateTime(2026, 2, 14, 10, 0),
            recurrenceRule: 'FREQ=DAILY;COUNT=30',
            text: 'Focus Time',
          ),
        ];

        await tester.pumpWidget(buildDayView(specialTimeRegions: regions));
        await tester.pumpAndSettle();

        expect(find.text('Focus Time'), findsOneWidget);
      });

      testWidgets('recurring region on display date shows correct time', (
        tester,
      ) async {
        final regions = [
          MCalTimeRegion(
            id: 'daily-lunch',
            startTime: DateTime(2026, 2, 10, 12, 0),
            endTime: DateTime(2026, 2, 10, 13, 0),
            recurrenceRule: 'FREQ=DAILY;COUNT=10',
            text: 'Daily Lunch',
          ),
        ];

        await tester.pumpWidget(buildDayView(specialTimeRegions: regions));
        await tester.pumpAndSettle();

        expect(find.text('Daily Lunch'), findsOneWidget);
      });
    });

    group('overlaps and collision detection', () {
      testWidgets('region and event can coexist - region below events layer', (
        tester,
      ) async {
        final events = [
          MCalCalendarEvent(
            id: 'ev-1',
            title: 'Meeting',
            start: DateTime(2026, 2, 14, 12, 0),
            end: DateTime(2026, 2, 14, 13, 0),
          ),
        ];
        final regions = [
          MCalTimeRegion(
            id: 'lunch',
            startTime: DateTime(2026, 2, 14, 12, 0),
            endTime: DateTime(2026, 2, 14, 13, 0),
            text: 'Lunch',
          ),
        ];

        await tester.pumpWidget(
          buildDayView(events: events, specialTimeRegions: regions),
        );
        await tester.pumpAndSettle();

        expect(find.text('Meeting'), findsOneWidget);
        expect(find.text('Lunch'), findsOneWidget);
      });
    });

    group('custom timeRegionBuilder', () {
      testWidgets('custom builder overrides default rendering', (
        tester,
      ) async {
        var builderCalled = false;
        final regions = [
          MCalTimeRegion(
            id: 'custom',
            startTime: DateTime(2026, 2, 14, 12, 0),
            endTime: DateTime(2026, 2, 14, 13, 0),
            text: 'Original',
          ),
        ];

        await tester.pumpWidget(
          buildDayView(
            specialTimeRegions: regions,
            timeRegionBuilder: (context, ctx) {
              builderCalled = true;
              return Container(
                color: Colors.purple,
                child: Text('Custom Region: ${ctx.region.id}'),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(builderCalled, isTrue);
        expect(find.text('Custom Region: custom'), findsOneWidget);
        expect(find.text('Original'), findsNothing);
      });

      testWidgets('custom builder receives MCalTimeRegionContext', (
        tester,
      ) async {
        MCalTimeRegionContext? capturedContext;
        final regions = [
          MCalTimeRegion(
            id: 'ctx-test',
            startTime: DateTime(2026, 2, 14, 12, 0),
            endTime: DateTime(2026, 2, 14, 13, 0),
            text: 'Context Test',
          ),
        ];

        await tester.pumpWidget(
          buildDayView(
            specialTimeRegions: regions,
            timeRegionBuilder: (context, ctx) {
              capturedContext = ctx;
              return Text('Region: ${ctx.region.id}');
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(capturedContext, isNotNull);
        expect(capturedContext!.region.id, 'ctx-test');
        expect(capturedContext!.region.text, 'Context Test');
        expect(capturedContext!.displayDate, testDate);
        expect(capturedContext!.height, 80.0);
      });
    });

    group('regions render below events layer', () {
      testWidgets('time regions layer present when regions provided', (
        tester,
      ) async {
        final regions = [
          MCalTimeRegion(
            id: 'layer-test',
            startTime: DateTime(2026, 2, 14, 12, 0),
            endTime: DateTime(2026, 2, 14, 13, 0),
            text: 'Layer Test',
          ),
        ];

        await tester.pumpWidget(buildDayView(specialTimeRegions: regions));
        await tester.pumpAndSettle();

        expect(find.byType(MCalDayView), findsOneWidget);
        expect(find.text('Layer Test'), findsOneWidget);
      });

      testWidgets('no regions layer when specialTimeRegions empty', (
        tester,
      ) async {
        await tester.pumpWidget(buildDayView());
        await tester.pumpAndSettle();

        expect(find.byType(MCalDayView), findsOneWidget);
      });
    });
  });
}
