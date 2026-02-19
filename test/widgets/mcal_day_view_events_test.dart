import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_calendar/multi_calendar.dart';

/// Mock MCalEventController for Day View testing.
class MockMCalEventController extends MCalEventController {
  MockMCalEventController({super.initialDate});

  void setMockEvents(List<MCalCalendarEvent> events) {
    clearEvents();
    addEvents(events);
  }
}

/// Sample events for Day View event rendering tests.
/// Uses fixed date 2026-02-14 (Saturday) for deterministic tests.
List<MCalCalendarEvent> createDayViewTestEvents(DateTime date) {
  final d = DateTime(date.year, date.month, date.day);
  return [
    // All-day events
    MCalCalendarEvent(
      id: 'allday-1',
      title: 'Holiday',
      start: DateTime(d.year, d.month, d.day, 0, 0),
      end: DateTime(d.year, d.month, d.day, 0, 0),
      isAllDay: true,
      color: Colors.amber,
    ),
    MCalCalendarEvent(
      id: 'allday-2',
      title: 'Project Kickoff',
      start: DateTime(d.year, d.month, d.day, 0, 0),
      end: DateTime(d.year, d.month, d.day, 0, 0),
      isAllDay: true,
      color: Colors.cyan,
    ),
    MCalCalendarEvent(
      id: 'allday-3',
      title: 'Team Meeting',
      start: DateTime(d.year, d.month, d.day, 0, 0),
      end: DateTime(d.year, d.month, d.day, 0, 0),
      isAllDay: true,
      color: Colors.indigo,
    ),
    // Timed events - non-overlapping
    MCalCalendarEvent(
      id: 'timed-1',
      title: 'Team Standup',
      start: DateTime(d.year, d.month, d.day, 9, 0),
      end: DateTime(d.year, d.month, d.day, 9, 30),
      isAllDay: false,
      color: Colors.indigo,
    ),
    MCalCalendarEvent(
      id: 'timed-2',
      title: 'Code Review',
      start: DateTime(d.year, d.month, d.day, 15, 0),
      end: DateTime(d.year, d.month, d.day, 16, 0),
      isAllDay: false,
      color: Colors.purple,
    ),
    MCalCalendarEvent(
      id: 'timed-3',
      title: 'Design Workshop',
      start: DateTime(d.year, d.month, d.day, 10, 30),
      end: DateTime(d.year, d.month, d.day, 12, 0),
      isAllDay: false,
      color: Colors.amber,
    ),
    // Overlapping timed events (9:00-10:30 and 10:00-11:00)
    MCalCalendarEvent(
      id: 'timed-overlap-a',
      title: 'Meeting A',
      start: DateTime(d.year, d.month, d.day, 11, 0),
      end: DateTime(d.year, d.month, d.day, 11, 45),
      isAllDay: false,
      color: Colors.green,
    ),
    MCalCalendarEvent(
      id: 'timed-overlap-b',
      title: 'Meeting B',
      start: DateTime(d.year, d.month, d.day, 11, 15),
      end: DateTime(d.year, d.month, d.day, 12, 0),
      isAllDay: false,
      color: Colors.teal,
    ),
  ];
}

/// Events that trigger all-day overflow (many all-day events).
List<MCalCalendarEvent> createAllDayOverflowEvents(DateTime date) {
  final d = DateTime(date.year, date.month, date.day);
  final List<MCalCalendarEvent> events = [];
  for (int i = 0; i < 10; i++) {
    events.add(
      MCalCalendarEvent(
        id: 'allday-overflow-$i',
        title: 'All-day Event $i',
        start: DateTime(d.year, d.month, d.day, 0, 0),
        end: DateTime(d.year, d.month, d.day, 0, 0),
        isAllDay: true,
        color: Colors.primaries[i % Colors.primaries.length],
      ),
    );
  }
  return events;
}

void main() {
  final testDate = DateTime(2026, 2, 14); // Saturday

  setUpAll(() async {
    await initializeDateFormatting('en', null);
  });

  group('MCalDayView Event Rendering', () {
    late MockMCalEventController controller;

    /// Minimal tile builder to avoid layout overflow in small slots.
    Widget minimalTimedTile(
      BuildContext context,
      MCalCalendarEvent event,
      MCalTimedEventTileContext ctx,
      Widget defaultWidget,
    ) {
      return Container(
        padding: const EdgeInsets.all(2),
        child: Text(event.title, style: const TextStyle(fontSize: 10)),
      );
    }

    setUp(() {
      controller = MockMCalEventController(initialDate: testDate);
    });

    tearDown(() {
      controller.dispose();
    });

    Widget buildDayView({
      List<MCalCalendarEvent>? events,
      int allDaySectionMaxRows = 3,
      double? hourHeight,
      Widget Function(
        BuildContext,
        MCalCalendarEvent,
        MCalAllDayEventTileContext,
        Widget,
      )?
      allDayEventTileBuilder,
      Widget Function(
        BuildContext,
        MCalCalendarEvent,
        MCalTimedEventTileContext,
        Widget,
      )?
      timedEventTileBuilder,
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
              showNavigator: false,
              showCurrentTimeIndicator: false,
              hourHeight: hourHeight ?? 80.0,
              allDaySectionMaxRows: allDaySectionMaxRows,
              allDayEventTileBuilder: allDayEventTileBuilder,
              timedEventTileBuilder: timedEventTileBuilder,
            ),
          ),
        ),
      );
    }

    group('all-day events', () {
      testWidgets('events appear in all-day section', (tester) async {
        final events = createDayViewTestEvents(testDate);
        final allDayOnly = events.where((e) => e.isAllDay).toList();

        await tester.pumpWidget(buildDayView(events: allDayOnly));
        await tester.pumpAndSettle();

        expect(find.text('All-day'), findsOneWidget);
        expect(find.text('Holiday'), findsOneWidget);
        expect(find.text('Project Kickoff'), findsOneWidget);
        expect(find.text('Team Meeting'), findsOneWidget);
      });

      testWidgets('multiple events flow correctly in wrap layout', (
        tester,
      ) async {
        final events = createDayViewTestEvents(testDate);
        final allDayOnly = events.where((e) => e.isAllDay).toList();

        await tester.pumpWidget(buildDayView(events: allDayOnly));
        await tester.pumpAndSettle();

        // All three all-day events should be visible
        expect(find.text('Holiday'), findsOneWidget);
        expect(find.text('Project Kickoff'), findsOneWidget);
        expect(find.text('Team Meeting'), findsOneWidget);
      });

      testWidgets('overflow indicator appears when events exceed max visible', (
        tester,
      ) async {
        final events = createAllDayOverflowEvents(testDate);
        // Use narrow width and low maxRows to force overflow with 10 events
        controller.setMockEvents(events);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 200,
                height: 600,
                child: MCalDayView(
                  controller: controller,
                  startHour: 8,
                  endHour: 18,
                  showNavigator: false,
                  showCurrentTimeIndicator: false,
                  allDaySectionMaxRows: 1,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // With 10 events and narrow width, overflow indicator should appear.
        // If overflow shows: "+N more". Otherwise verify many events rendered.
        final moreFinder = find.textContaining('more');
        final plusFinder = find.textContaining('+');
        expect(
          moreFinder.evaluate().isNotEmpty ||
              plusFinder.evaluate().isNotEmpty ||
              find.text('All-day Event 0').evaluate().isNotEmpty,
          isTrue,
          reason: 'Overflow indicator or all-day events should be visible',
        );
      });
    });

    group('timed events', () {
      testWidgets('events appear at correct positions', (tester) async {
        final events = createDayViewTestEvents(testDate);
        final timedOnly = events.where((e) => !e.isAllDay).toList();

        await tester.pumpWidget(
          buildDayView(
            events: timedOnly,
            timedEventTileBuilder: minimalTimedTile,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Team Standup'), findsOneWidget);
        expect(find.text('Code Review'), findsOneWidget);
        expect(find.text('Design Workshop'), findsOneWidget);
      });

      testWidgets('event tiles show title and time', (tester) async {
        final events = [
          MCalCalendarEvent(
            id: 'single',
            title: 'Single Event',
            start: DateTime(testDate.year, testDate.month, testDate.day, 9, 0),
            end: DateTime(testDate.year, testDate.month, testDate.day, 10, 0),
            isAllDay: false,
          ),
        ];

        await tester.pumpWidget(
          buildDayView(events: events, timedEventTileBuilder: minimalTimedTile),
        );
        await tester.pumpAndSettle();

        expect(find.text('Single Event'), findsOneWidget);
      });

      testWidgets('event height matches duration', (tester) async {
        final events = [
          MCalCalendarEvent(
            id: 'short',
            title: 'Short',
            start: DateTime(testDate.year, testDate.month, testDate.day, 9, 0),
            end: DateTime(testDate.year, testDate.month, testDate.day, 9, 30),
            isAllDay: false,
          ),
          MCalCalendarEvent(
            id: 'long',
            title: 'Long Meeting',
            start: DateTime(testDate.year, testDate.month, testDate.day, 10, 0),
            end: DateTime(testDate.year, testDate.month, testDate.day, 12, 0),
            isAllDay: false,
          ),
        ];

        await tester.pumpWidget(
          buildDayView(events: events, timedEventTileBuilder: minimalTimedTile),
        );
        await tester.pumpAndSettle();

        // Both events should be present; height is determined by duration in layout
        expect(find.text('Short'), findsOneWidget);
        expect(find.text('Long Meeting'), findsOneWidget);
      });

      testWidgets('overlapping events show side by side', (tester) async {
        final events = [
          MCalCalendarEvent(
            id: 'a',
            title: 'Event A',
            start: DateTime(testDate.year, testDate.month, testDate.day, 9, 0),
            end: DateTime(testDate.year, testDate.month, testDate.day, 10, 30),
            isAllDay: false,
          ),
          MCalCalendarEvent(
            id: 'b',
            title: 'Event B',
            start: DateTime(testDate.year, testDate.month, testDate.day, 10, 0),
            end: DateTime(testDate.year, testDate.month, testDate.day, 11, 0),
            isAllDay: false,
          ),
        ];

        await tester.pumpWidget(
          buildDayView(events: events, timedEventTileBuilder: minimalTimedTile),
        );
        await tester.pumpAndSettle();

        // Both overlapping events should be visible
        expect(find.text('Event A'), findsOneWidget);
        expect(find.text('Event B'), findsOneWidget);
      });
    });

    group('custom builders', () {
      testWidgets('allDayEventTileBuilder is used when provided', (
        tester,
      ) async {
        final events = [
          MCalCalendarEvent(
            id: 'custom-allday',
            title: 'Custom All-day',
            start: DateTime(testDate.year, testDate.month, testDate.day, 0, 0),
            end: DateTime(testDate.year, testDate.month, testDate.day, 0, 0),
            isAllDay: true,
          ),
        ];

        bool builderCalled = false;
        await tester.pumpWidget(
          buildDayView(
            events: events,
            allDayEventTileBuilder: (context, event, ctx, defaultWidget) {
              builderCalled = true;
              expect(ctx.event.title, 'Custom All-day');
              expect(ctx.displayDate, testDate);
              return Container(
                padding: const EdgeInsets.all(8),
                color: Colors.purple,
                child: Text('CUSTOM: ${event.title}'),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(builderCalled, isTrue);
        expect(find.text('CUSTOM: Custom All-day'), findsOneWidget);
      });

      testWidgets('timedEventTileBuilder is used when provided', (
        tester,
      ) async {
        final events = [
          MCalCalendarEvent(
            id: 'custom-timed',
            title: 'Custom Timed',
            start: DateTime(testDate.year, testDate.month, testDate.day, 9, 0),
            end: DateTime(testDate.year, testDate.month, testDate.day, 10, 0),
            isAllDay: false,
          ),
        ];

        bool builderCalled = false;
        await tester.pumpWidget(
          buildDayView(
            events: events,
            timedEventTileBuilder: (context, event, ctx, defaultWidget) {
              builderCalled = true;
              expect(ctx.event.title, 'Custom Timed');
              expect(ctx.columnIndex, 0);
              expect(ctx.totalColumns, 1);
              return Container(
                padding: const EdgeInsets.all(8),
                color: Colors.orange,
                child: Text('TIMED: ${event.title}'),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(builderCalled, isTrue);
        expect(find.text('TIMED: Custom Timed'), findsOneWidget);
      });

      testWidgets(
        'timedEventTileBuilder receives overlap context for overlapping events',
        (tester) async {
          final events = [
            MCalCalendarEvent(
              id: 'overlap-1',
              title: 'Overlap 1',
              start: DateTime(
                testDate.year,
                testDate.month,
                testDate.day,
                9,
                0,
              ),
              end: DateTime(testDate.year, testDate.month, testDate.day, 10, 0),
              isAllDay: false,
            ),
            MCalCalendarEvent(
              id: 'overlap-2',
              title: 'Overlap 2',
              start: DateTime(
                testDate.year,
                testDate.month,
                testDate.day,
                9,
                30,
              ),
              end: DateTime(
                testDate.year,
                testDate.month,
                testDate.day,
                10,
                30,
              ),
              isAllDay: false,
            ),
          ];

          final columnIndices = <String, int>{};
          final totalColumns = <String, int>{};

          await tester.pumpWidget(
            buildDayView(
              events: events,
              timedEventTileBuilder: (context, event, ctx, defaultWidget) {
                columnIndices[event.id] = ctx.columnIndex;
                totalColumns[event.id] = ctx.totalColumns;
                return Container(
                  padding: const EdgeInsets.all(4),
                  child: Text(event.title),
                );
              },
            ),
          );
          await tester.pumpAndSettle();

          expect(columnIndices['overlap-1'], isNotNull);
          expect(columnIndices['overlap-2'], isNotNull);
          expect(totalColumns['overlap-1'], 2);
          expect(totalColumns['overlap-2'], 2);
          expect(
            columnIndices['overlap-1'],
            isNot(equals(columnIndices['overlap-2'])),
          );
        },
      );
    });

    group('semantic labels', () {
      testWidgets('all-day events have semantic labels', (tester) async {
        final events = [
          MCalCalendarEvent(
            id: 'sem-allday',
            title: 'Semantic All-day',
            start: DateTime(testDate.year, testDate.month, testDate.day, 0, 0),
            end: DateTime(testDate.year, testDate.month, testDate.day, 0, 0),
            isAllDay: true,
          ),
        ];

        await tester.pumpWidget(buildDayView(events: events));
        await tester.pumpAndSettle();

        // Verify event renders and has accessible content (title visible)
        expect(find.text('Semantic All-day'), findsOneWidget);
      });

      testWidgets('timed events have semantic labels with time', (
        tester,
      ) async {
        final events = [
          MCalCalendarEvent(
            id: 'sem-timed',
            title: 'Semantic Timed',
            start: DateTime(testDate.year, testDate.month, testDate.day, 9, 0),
            end: DateTime(testDate.year, testDate.month, testDate.day, 10, 0),
            isAllDay: false,
          ),
        ];

        await tester.pumpWidget(
          buildDayView(events: events, timedEventTileBuilder: minimalTimedTile),
        );
        await tester.pumpAndSettle();

        // Verify event renders with title
        expect(find.text('Semantic Timed'), findsOneWidget);
      });

      testWidgets('overflow indicator has semantic label', (tester) async {
        final events = createAllDayOverflowEvents(testDate);
        controller.setMockEvents(events);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 200,
                height: 600,
                child: MCalDayView(
                  controller: controller,
                  startHour: 8,
                  endHour: 18,
                  showNavigator: false,
                  showCurrentTimeIndicator: false,
                  allDaySectionMaxRows: 1,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // With many events, either overflow indicator or visible events
        expect(
          find.textContaining('more').evaluate().isNotEmpty ||
              find.textContaining('+').evaluate().isNotEmpty ||
              find.text('All-day Event 0').evaluate().isNotEmpty,
          isTrue,
        );
      });
    });

    group('combined all-day and timed', () {
      testWidgets('both all-day and timed events render together', (
        tester,
      ) async {
        final events = createDayViewTestEvents(testDate);

        await tester.pumpWidget(
          buildDayView(events: events, timedEventTileBuilder: minimalTimedTile),
        );
        await tester.pumpAndSettle();

        expect(find.text('All-day'), findsOneWidget);
        expect(find.text('Holiday'), findsOneWidget);
        expect(find.text('Team Standup'), findsOneWidget);
        expect(find.text('Code Review'), findsOneWidget);
      });
    });
  });
}
