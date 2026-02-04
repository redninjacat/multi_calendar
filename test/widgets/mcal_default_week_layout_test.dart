import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  late MCalCalendarEvent event1;
  late MCalCalendarEvent event2;
  late MCalCalendarEvent event3;

  setUp(() {
    event1 = MCalCalendarEvent(
      id: '1',
      title: 'Event 1',
      start: DateTime(2024, 1, 15),
      end: DateTime(2024, 1, 17),
    );
    event2 = MCalCalendarEvent(
      id: '2',
      title: 'Event 2',
      start: DateTime(2024, 1, 16),
      end: DateTime(2024, 1, 16),
    );
    event3 = MCalCalendarEvent(
      id: '3',
      title: 'Event 3',
      start: DateTime(2024, 1, 15),
      end: DateTime(2024, 1, 15),
    );
  });

  group('MCalDefaultWeekLayoutBuilder.assignRows', () {
    test('assigns single segment to row 0', () {
      final segments = [
        MCalEventSegment(
          event: event1,
          weekRowIndex: 0,
          startDayInWeek: 1,
          endDayInWeek: 3,
          isFirstSegment: true,
          isLastSegment: true,
        ),
      ];

      final assignments = MCalDefaultWeekLayoutBuilder.assignRows(segments);

      expect(assignments.length, 1);
      expect(assignments[0].row, 0);
    });

    test('assigns non-overlapping segments to same row', () {
      final segments = [
        MCalEventSegment(
          event: event1,
          weekRowIndex: 0,
          startDayInWeek: 0,
          endDayInWeek: 1,
          isFirstSegment: true,
          isLastSegment: true,
        ),
        MCalEventSegment(
          event: event2,
          weekRowIndex: 0,
          startDayInWeek: 3,
          endDayInWeek: 4,
          isFirstSegment: true,
          isLastSegment: true,
        ),
      ];

      final assignments = MCalDefaultWeekLayoutBuilder.assignRows(segments);

      expect(assignments.length, 2);
      expect(assignments[0].row, 0);
      expect(assignments[1].row, 0);
    });

    test('assigns overlapping segments to different rows', () {
      final segments = [
        MCalEventSegment(
          event: event1,
          weekRowIndex: 0,
          startDayInWeek: 1,
          endDayInWeek: 3,
          isFirstSegment: true,
          isLastSegment: true,
        ),
        MCalEventSegment(
          event: event2,
          weekRowIndex: 0,
          startDayInWeek: 2,
          endDayInWeek: 2,
          isFirstSegment: true,
          isLastSegment: true,
        ),
      ];

      final assignments = MCalDefaultWeekLayoutBuilder.assignRows(segments);

      expect(assignments.length, 2);
      expect(assignments[0].row, 0);
      expect(assignments[1].row, 1); // Pushed to row 1 due to overlap
    });

    test('handles empty segment list', () {
      final assignments = MCalDefaultWeekLayoutBuilder.assignRows([]);
      expect(assignments, isEmpty);
    });

    test('assigns adjacent segments to same row', () {
      // Events that are adjacent (not overlapping) can share a row
      final segments = [
        MCalEventSegment(
          event: event1,
          weekRowIndex: 0,
          startDayInWeek: 0,
          endDayInWeek: 2,
          isFirstSegment: true,
          isLastSegment: true,
        ),
        MCalEventSegment(
          event: event2,
          weekRowIndex: 0,
          startDayInWeek: 3, // Starts right after event1 ends
          endDayInWeek: 5,
          isFirstSegment: true,
          isLastSegment: true,
        ),
      ];

      final assignments = MCalDefaultWeekLayoutBuilder.assignRows(segments);

      expect(assignments.length, 2);
      expect(assignments[0].row, 0);
      expect(assignments[1].row, 0); // Same row since no overlap
    });

    test('handles three overlapping segments correctly', () {
      final segments = [
        MCalEventSegment(
          event: event1,
          weekRowIndex: 0,
          startDayInWeek: 0,
          endDayInWeek: 6, // Full week
          isFirstSegment: true,
          isLastSegment: true,
        ),
        MCalEventSegment(
          event: event2,
          weekRowIndex: 0,
          startDayInWeek: 1,
          endDayInWeek: 5,
          isFirstSegment: true,
          isLastSegment: true,
        ),
        MCalEventSegment(
          event: event3,
          weekRowIndex: 0,
          startDayInWeek: 2,
          endDayInWeek: 4,
          isFirstSegment: true,
          isLastSegment: true,
        ),
      ];

      final assignments = MCalDefaultWeekLayoutBuilder.assignRows(segments);

      expect(assignments.length, 3);
      expect(assignments[0].row, 0);
      expect(assignments[1].row, 1);
      expect(assignments[2].row, 2);
    });

    test('reuses rows when possible', () {
      // First segment spans days 0-1, second spans 5-6, third spans 2-4
      // All can fit in row 0
      final segments = [
        MCalEventSegment(
          event: event1,
          weekRowIndex: 0,
          startDayInWeek: 0,
          endDayInWeek: 1,
          isFirstSegment: true,
          isLastSegment: true,
        ),
        MCalEventSegment(
          event: event2,
          weekRowIndex: 0,
          startDayInWeek: 5,
          endDayInWeek: 6,
          isFirstSegment: true,
          isLastSegment: true,
        ),
        MCalEventSegment(
          event: event3,
          weekRowIndex: 0,
          startDayInWeek: 2,
          endDayInWeek: 4,
          isFirstSegment: true,
          isLastSegment: true,
        ),
      ];

      final assignments = MCalDefaultWeekLayoutBuilder.assignRows(segments);

      expect(assignments.length, 3);
      // All should fit in row 0
      expect(assignments[0].row, 0);
      expect(assignments[1].row, 0);
      expect(assignments[2].row, 0);
    });
  });

  group('MCalDefaultWeekLayoutBuilder.calculateOverflow', () {
    test('returns empty map when no overflow', () {
      final segments = [
        MCalEventSegment(
          event: event1,
          weekRowIndex: 0,
          startDayInWeek: 0,
          endDayInWeek: 2,
          isFirstSegment: true,
          isLastSegment: true,
        ),
      ];
      final assignments = MCalDefaultWeekLayoutBuilder.assignRows(segments);
      final overflow = MCalDefaultWeekLayoutBuilder.calculateOverflow(
        assignments: assignments,
        maxVisibleRows: 5,
      );

      expect(overflow, isEmpty);
    });

    test('counts hidden events per day correctly', () {
      // Create segments that will overflow
      final segments = <MCalEventSegment>[];
      for (int i = 0; i < 10; i++) {
        final event = MCalCalendarEvent(
          id: 'evt-$i',
          title: 'Event $i',
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 1, 15),
        );
        segments.add(MCalEventSegment(
          event: event,
          weekRowIndex: 0,
          startDayInWeek: 1, // All on day 1
          endDayInWeek: 1,
          isFirstSegment: true,
          isLastSegment: true,
        ));
      }

      final assignments = MCalDefaultWeekLayoutBuilder.assignRows(segments);
      final overflow = MCalDefaultWeekLayoutBuilder.calculateOverflow(
        assignments: assignments,
        maxVisibleRows: 3,
      );

      expect(overflow.containsKey(1), true);
      expect(overflow[1]!.hiddenCount, 7); // 10 events - 3 visible = 7 hidden
      expect(overflow[1]!.visibleEvents.length, 3);
      expect(overflow[1]!.hiddenEvents.length, 7);
    });

    test('handles multi-day event spanning multiple days', () {
      // Event spans days 0-2
      final segments = [
        MCalEventSegment(
          event: event1,
          weekRowIndex: 0,
          startDayInWeek: 0,
          endDayInWeek: 2,
          isFirstSegment: true,
          isLastSegment: true,
        ),
      ];

      final assignments = MCalDefaultWeekLayoutBuilder.assignRows(segments);
      // With maxVisibleRows: 0, all events should be hidden
      final overflow = MCalDefaultWeekLayoutBuilder.calculateOverflow(
        assignments: assignments,
        maxVisibleRows: 0,
      );

      // Event should appear as hidden in all 3 days it spans
      expect(overflow.containsKey(0), true);
      expect(overflow.containsKey(1), true);
      expect(overflow.containsKey(2), true);
      expect(overflow[0]!.hiddenCount, 1);
      expect(overflow[1]!.hiddenCount, 1);
      expect(overflow[2]!.hiddenCount, 1);
    });

    test('correctly separates visible and hidden events', () {
      // Create 5 events on the same day
      final segments = <MCalEventSegment>[];
      for (int i = 0; i < 5; i++) {
        final event = MCalCalendarEvent(
          id: 'evt-$i',
          title: 'Event $i',
          start: DateTime(2024, 1, 15),
          end: DateTime(2024, 1, 15),
        );
        segments.add(MCalEventSegment(
          event: event,
          weekRowIndex: 0,
          startDayInWeek: 3,
          endDayInWeek: 3,
          isFirstSegment: true,
          isLastSegment: true,
        ));
      }

      final assignments = MCalDefaultWeekLayoutBuilder.assignRows(segments);
      final overflow = MCalDefaultWeekLayoutBuilder.calculateOverflow(
        assignments: assignments,
        maxVisibleRows: 2,
      );

      expect(overflow[3]!.visibleEvents.length, 2);
      expect(overflow[3]!.hiddenEvents.length, 3);
      expect(overflow[3]!.hiddenCount, 3);
    });

    test('handles mixed visible and hidden across different days', () {
      // Event 1 on day 0, Event 2 on days 1-3, Event 3 on day 2
      // With maxVisibleRows=1, we should see overflow on days 1,2,3
      final segments = [
        MCalEventSegment(
          event: event1,
          weekRowIndex: 0,
          startDayInWeek: 0,
          endDayInWeek: 0,
          isFirstSegment: true,
          isLastSegment: true,
        ),
        MCalEventSegment(
          event: event2,
          weekRowIndex: 0,
          startDayInWeek: 1,
          endDayInWeek: 3,
          isFirstSegment: true,
          isLastSegment: true,
        ),
        MCalEventSegment(
          event: event3,
          weekRowIndex: 0,
          startDayInWeek: 2,
          endDayInWeek: 2,
          isFirstSegment: true,
          isLastSegment: true,
        ),
      ];

      final assignments = MCalDefaultWeekLayoutBuilder.assignRows(segments);
      final overflow = MCalDefaultWeekLayoutBuilder.calculateOverflow(
        assignments: assignments,
        maxVisibleRows: 1,
      );

      // Day 0 has only 1 event (row 0) - visible, no overflow
      expect(overflow.containsKey(0), false);

      // Day 2 has both events, event2 in row 0 (visible), event3 in row 1 (hidden)
      expect(overflow.containsKey(2), true);
      expect(overflow[2]!.hiddenCount, 1);
    });

    test('returns empty map when maxVisibleRows covers all events', () {
      final segments = [
        MCalEventSegment(
          event: event1,
          weekRowIndex: 0,
          startDayInWeek: 0,
          endDayInWeek: 2,
          isFirstSegment: true,
          isLastSegment: true,
        ),
        MCalEventSegment(
          event: event2,
          weekRowIndex: 0,
          startDayInWeek: 1,
          endDayInWeek: 3,
          isFirstSegment: true,
          isLastSegment: true,
        ),
      ];

      final assignments = MCalDefaultWeekLayoutBuilder.assignRows(segments);
      // With maxVisibleRows: 10, all 2 events should be visible
      final overflow = MCalDefaultWeekLayoutBuilder.calculateOverflow(
        assignments: assignments,
        maxVisibleRows: 10,
      );

      expect(overflow, isEmpty);
    });
  });
}
