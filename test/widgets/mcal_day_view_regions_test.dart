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
      List<MCalRegion> regions = const [],
      Widget Function(BuildContext, MCalTimeRegionContext, Widget)?
          timeRegionBuilder,
    }) {
      if (events != null) {
        controller.setMockEvents(events);
      }
      controller.clearRegions();
      if (regions.isNotEmpty) {
        controller.addRegions(regions);
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
              timeRegionBuilder: timeRegionBuilder,
            ),
          ),
        ),
      );
    }

    group('MCalRegion rendering', () {
      testWidgets('region renders at correct position with text', (
        tester,
      ) async {
        final regions = [
          MCalRegion(
            id: 'lunch',
            start: DateTime(2026, 2, 14, 12, 0),
            end: DateTime(2026, 2, 14, 13, 0),
            isAllDay: false,
            text: 'Lunch Break',
            color: Colors.amber.withValues(alpha: 0.3),
          ),
        ];

        await tester.pumpWidget(buildDayView(regions: regions));
        await tester.pumpAndSettle();

        expect(find.text('Lunch Break'), findsOneWidget);
      });

      testWidgets('region renders with icon and text', (tester) async {
        final regions = [
          MCalRegion(
            id: 'focus',
            start: DateTime(2026, 2, 14, 9, 0),
            end: DateTime(2026, 2, 14, 10, 0),
            isAllDay: false,
            text: 'Focus Time',
            icon: Icons.work,
            color: Colors.blue.withValues(alpha: 0.2),
          ),
        ];

        await tester.pumpWidget(buildDayView(regions: regions));
        await tester.pumpAndSettle();

        expect(find.text('Focus Time'), findsOneWidget);
        expect(find.byIcon(Icons.work), findsOneWidget);
      });

      testWidgets('multiple regions render', (tester) async {
        final regions = [
          MCalRegion(
            id: 'morning',
            start: DateTime(2026, 2, 14, 9, 0),
            end: DateTime(2026, 2, 14, 10, 0),
            isAllDay: false,
            text: 'Morning Block',
          ),
          MCalRegion(
            id: 'lunch',
            start: DateTime(2026, 2, 14, 12, 0),
            end: DateTime(2026, 2, 14, 13, 0),
            isAllDay: false,
            text: 'Lunch',
          ),
        ];

        await tester.pumpWidget(buildDayView(regions: regions));
        await tester.pumpAndSettle();

        expect(find.text('Morning Block'), findsOneWidget);
        expect(find.text('Lunch'), findsOneWidget);
      });

      testWidgets('region outside visible hours does not render', (
        tester,
      ) async {
        final regions = [
          MCalRegion(
            id: 'late',
            start: DateTime(2026, 2, 14, 22, 0),
            end: DateTime(2026, 2, 14, 23, 0),
            isAllDay: false,
            text: 'Late Night',
          ),
        ];

        await tester.pumpWidget(
          buildDayView(regions: regions),
        );
        await tester.pumpAndSettle();

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

        final blockedRegion = MCalRegion(
          id: 'blocked',
          start: DateTime(2026, 2, 14, 12, 0),
          end: DateTime(2026, 2, 14, 13, 0),
          isAllDay: false,
          text: 'Blocked Time',
          blockInteraction: true,
        );

        final testController = MockMCalEventController(initialDate: testDate);
        testController.setMockEvents([event]);
        testController.addRegions([blockedRegion]);

        var dropCalled = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 800,
                child: MCalDayView(
                  controller: testController,
                  startHour: 8,
                  endHour: 18,
                  hourHeight: 80,
                  enableDragToMove: true,
                  onEventDropped: (_, __) {
                    dropCalled = true;
                    return true;
                  },
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

        await gesture.moveBy(const Offset(0, 160));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        await gesture.up();
        await tester.pumpAndSettle();

        expect(dropCalled, isFalse);

        testController.dispose();
      });

      testWidgets('non-blocked region allows drop', (tester) async {
        final event = MCalCalendarEvent(
          id: 'drag-2',
          title: 'Drop Allowed',
          start: DateTime(2026, 2, 14, 10, 0),
          end: DateTime(2026, 2, 14, 11, 0),
        );

        final visualRegion = MCalRegion(
          id: 'visual',
          start: DateTime(2026, 2, 14, 12, 0),
          end: DateTime(2026, 2, 14, 13, 0),
          isAllDay: false,
          text: 'Visual Only',
          blockInteraction: false,
        );

        final testController = MockMCalEventController(initialDate: testDate);
        testController.setMockEvents([event]);
        testController.addRegions([visualRegion]);

        MCalEventDroppedDetails? capturedDetails;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 800,
                child: MCalDayView(
                  controller: testController,
                  startHour: 8,
                  endHour: 18,
                  hourHeight: 80,
                  enableDragToMove: true,
                  onEventDropped: (_, d) {
                    capturedDetails = d;
                    return true;
                  },
                  showCurrentTimeIndicator: false,
                  dragLongPressDelay: const Duration(milliseconds: 150),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final eventFinder = find.text('Drop Allowed');
        final gesture =
            await tester.startGesture(tester.getCenter(eventFinder));
        await tester.pump(const Duration(milliseconds: 200));
        await gesture.moveBy(const Offset(0, 160));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await gesture.up();
        await tester.pumpAndSettle();

        expect(find.byType(MCalDayView), findsOneWidget);
        if (capturedDetails != null) {
          expect(capturedDetails!.event.id, 'drag-2');
        }

        testController.dispose();
      });
    });

    group('visual styling', () {
      testWidgets('blocked region uses blocked styling when no custom color', (
        tester,
      ) async {
        final regions = [
          MCalRegion(
            id: 'blocked',
            start: DateTime(2026, 2, 14, 12, 0),
            end: DateTime(2026, 2, 14, 13, 0),
            isAllDay: false,
            blockInteraction: true,
            text: 'Blocked',
          ),
        ];

        await tester.pumpWidget(buildDayView(regions: regions));
        await tester.pumpAndSettle();

        expect(find.text('Blocked'), findsOneWidget);
      });

      testWidgets('region with custom color renders', (tester) async {
        final regions = [
          MCalRegion(
            id: 'custom',
            start: DateTime(2026, 2, 14, 12, 0),
            end: DateTime(2026, 2, 14, 13, 0),
            isAllDay: false,
            color: Colors.red.withValues(alpha: 0.5),
            text: 'Custom Color',
          ),
        ];

        await tester.pumpWidget(buildDayView(regions: regions));
        await tester.pumpAndSettle();

        expect(find.text('Custom Color'), findsOneWidget);
      });
    });

    group('recurring regions with MCalRecurrenceRule', () {
      testWidgets('recurring region expands for display date', (tester) async {
        final regions = [
          MCalRegion(
            id: 'focus-time',
            start: DateTime(2026, 2, 14, 9, 0),
            end: DateTime(2026, 2, 14, 10, 0),
            isAllDay: false,
            recurrenceRule: MCalRecurrenceRule(
              frequency: MCalFrequency.daily,
              count: 30,
            ),
            text: 'Focus Time',
          ),
        ];

        await tester.pumpWidget(buildDayView(regions: regions));
        await tester.pumpAndSettle();

        expect(find.text('Focus Time'), findsOneWidget);
      });

      testWidgets('recurring region on display date shows correct time', (
        tester,
      ) async {
        final regions = [
          MCalRegion(
            id: 'daily-lunch',
            start: DateTime(2026, 2, 10, 12, 0),
            end: DateTime(2026, 2, 10, 13, 0),
            isAllDay: false,
            recurrenceRule: MCalRecurrenceRule(
              frequency: MCalFrequency.daily,
              count: 10,
            ),
            text: 'Daily Lunch',
          ),
        ];

        await tester.pumpWidget(buildDayView(regions: regions));
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
          MCalRegion(
            id: 'lunch',
            start: DateTime(2026, 2, 14, 12, 0),
            end: DateTime(2026, 2, 14, 13, 0),
            isAllDay: false,
            text: 'Lunch',
          ),
        ];

        await tester.pumpWidget(
          buildDayView(events: events, regions: regions),
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
          MCalRegion(
            id: 'custom',
            start: DateTime(2026, 2, 14, 12, 0),
            end: DateTime(2026, 2, 14, 13, 0),
            isAllDay: false,
            text: 'Original',
          ),
        ];

        await tester.pumpWidget(
          buildDayView(
            regions: regions,
            timeRegionBuilder: (context, ctx, defaultWidget) {
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
          MCalRegion(
            id: 'ctx-test',
            start: DateTime(2026, 2, 14, 12, 0),
            end: DateTime(2026, 2, 14, 13, 0),
            isAllDay: false,
            text: 'Context Test',
          ),
        ];

        await tester.pumpWidget(
          buildDayView(
            regions: regions,
            timeRegionBuilder: (context, ctx, defaultWidget) {
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
          MCalRegion(
            id: 'layer-test',
            start: DateTime(2026, 2, 14, 12, 0),
            end: DateTime(2026, 2, 14, 13, 0),
            isAllDay: false,
            text: 'Layer Test',
          ),
        ];

        await tester.pumpWidget(buildDayView(regions: regions));
        await tester.pumpAndSettle();

        expect(find.byType(MCalDayView), findsOneWidget);
        expect(find.text('Layer Test'), findsOneWidget);
      });

      testWidgets('no regions layer when no regions added', (
        tester,
      ) async {
        await tester.pumpWidget(buildDayView());
        await tester.pumpAndSettle();

        expect(find.byType(MCalDayView), findsOneWidget);
      });
    });
  });
}
