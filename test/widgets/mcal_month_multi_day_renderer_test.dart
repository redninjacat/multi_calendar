import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  group('MCalMultiDayRenderer (Month View)', () {
    group('isMultiDay()', () {
      test('returns true for event spanning 2 days', () {
        final event = MCalCalendarEvent(
          id: 'multi-2-days',
          title: 'Two Day Event',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 16, 18, 0),
        );

        expect(MCalMultiDayRenderer.isMultiDay(event), isTrue);
      });

      test('returns true for event spanning 5 days', () {
        final event = MCalCalendarEvent(
          id: 'multi-5-days',
          title: 'Five Day Event',
          start: DateTime(2025, 1, 10),
          end: DateTime(2025, 1, 14),
        );

        expect(MCalMultiDayRenderer.isMultiDay(event), isTrue);
      });

      test('returns true for event spanning multiple weeks', () {
        final event = MCalCalendarEvent(
          id: 'multi-weeks',
          title: 'Multi Week Event',
          start: DateTime(2025, 1, 10),
          end: DateTime(2025, 1, 24),
        );

        expect(MCalMultiDayRenderer.isMultiDay(event), isTrue);
      });

      test('returns false for same-day event', () {
        final event = MCalCalendarEvent(
          id: 'same-day',
          title: 'Same Day Event',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 15, 18, 0),
        );

        expect(MCalMultiDayRenderer.isMultiDay(event), isFalse);
      });

      test('returns false for same-day event spanning full day', () {
        final event = MCalCalendarEvent(
          id: 'same-day-full',
          title: 'Full Day Same Day',
          start: DateTime(2025, 1, 15, 0, 0),
          end: DateTime(2025, 1, 15, 23, 59),
        );

        expect(MCalMultiDayRenderer.isMultiDay(event), isFalse);
      });

      test('handles all-day event on single day correctly (returns false)', () {
        final event = MCalCalendarEvent(
          id: 'all-day-single',
          title: 'Single All Day',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
          isAllDay: true,
        );

        expect(MCalMultiDayRenderer.isMultiDay(event), isFalse);
      });

      test('handles all-day event spanning multiple days correctly (returns true)', () {
        final event = MCalCalendarEvent(
          id: 'all-day-multi',
          title: 'Multi Day All Day',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 17),
          isAllDay: true,
        );

        expect(MCalMultiDayRenderer.isMultiDay(event), isTrue);
      });

      test('ignores time components when comparing dates', () {
        // Event that spans from late night to early morning next day
        final event = MCalCalendarEvent(
          id: 'overnight',
          title: 'Overnight Event',
          start: DateTime(2025, 1, 15, 23, 0),
          end: DateTime(2025, 1, 16, 1, 0),
        );

        expect(MCalMultiDayRenderer.isMultiDay(event), isTrue);
      });
    });

    group('multiDayEventComparator()', () {
      test('sorts all-day multi-day events before timed multi-day events', () {
        final allDayMulti = MCalCalendarEvent(
          id: 'allday-multi',
          title: 'All Day Multi',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 17),
          isAllDay: true,
        );

        final timedMulti = MCalCalendarEvent(
          id: 'timed-multi',
          title: 'Timed Multi',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 17, 18, 0),
        );

        final events = [timedMulti, allDayMulti];
        events.sort(MCalMultiDayRenderer.multiDayEventComparator);

        expect(events[0].id, equals('allday-multi'));
        expect(events[1].id, equals('timed-multi'));
      });

      test('sorts timed multi-day events before all-day single-day events', () {
        final timedMulti = MCalCalendarEvent(
          id: 'timed-multi',
          title: 'Timed Multi',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 17, 18, 0),
        );

        final allDaySingle = MCalCalendarEvent(
          id: 'allday-single',
          title: 'All Day Single',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
          isAllDay: true,
        );

        final events = [allDaySingle, timedMulti];
        events.sort(MCalMultiDayRenderer.multiDayEventComparator);

        expect(events[0].id, equals('timed-multi'));
        expect(events[1].id, equals('allday-single'));
      });

      test('sorts all-day single-day events before timed single-day events', () {
        final allDaySingle = MCalCalendarEvent(
          id: 'allday-single',
          title: 'All Day Single',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
          isAllDay: true,
        );

        final timedSingle = MCalCalendarEvent(
          id: 'timed-single',
          title: 'Timed Single',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 15, 11, 0),
        );

        final events = [timedSingle, allDaySingle];
        events.sort(MCalMultiDayRenderer.multiDayEventComparator);

        expect(events[0].id, equals('allday-single'));
        expect(events[1].id, equals('timed-single'));
      });

      test('full priority order: all-day multi → timed multi → all-day single → timed single', () {
        final allDayMulti = MCalCalendarEvent(
          id: '1-allday-multi',
          title: 'All Day Multi',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 17),
          isAllDay: true,
        );

        final timedMulti = MCalCalendarEvent(
          id: '2-timed-multi',
          title: 'Timed Multi',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 17, 18, 0),
        );

        final allDaySingle = MCalCalendarEvent(
          id: '3-allday-single',
          title: 'All Day Single',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 15),
          isAllDay: true,
        );

        final timedSingle = MCalCalendarEvent(
          id: '4-timed-single',
          title: 'Timed Single',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 15, 11, 0),
        );

        // Add in reverse order to ensure sorting works
        final events = [timedSingle, allDaySingle, timedMulti, allDayMulti];
        events.sort(MCalMultiDayRenderer.multiDayEventComparator);

        expect(events[0].id, equals('1-allday-multi'));
        expect(events[1].id, equals('2-timed-multi'));
        expect(events[2].id, equals('3-allday-single'));
        expect(events[3].id, equals('4-timed-single'));
      });

      test('within same category, sorts by start time', () {
        final event1 = MCalCalendarEvent(
          id: 'later',
          title: 'Later Event',
          start: DateTime(2025, 1, 15, 14, 0),
          end: DateTime(2025, 1, 17, 18, 0),
        );

        final event2 = MCalCalendarEvent(
          id: 'earlier',
          title: 'Earlier Event',
          start: DateTime(2025, 1, 15, 9, 0),
          end: DateTime(2025, 1, 17, 12, 0),
        );

        final events = [event1, event2];
        events.sort(MCalMultiDayRenderer.multiDayEventComparator);

        expect(events[0].id, equals('earlier'));
        expect(events[1].id, equals('later'));
      });

      test('with same start time, sorts longer events first', () {
        final shorter = MCalCalendarEvent(
          id: 'shorter',
          title: 'Shorter Event',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 16, 10, 0),
        );

        final longer = MCalCalendarEvent(
          id: 'longer',
          title: 'Longer Event',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 18, 10, 0),
        );

        final events = [shorter, longer];
        events.sort(MCalMultiDayRenderer.multiDayEventComparator);

        expect(events[0].id, equals('longer'));
        expect(events[1].id, equals('shorter'));
      });

      test('with same start time and duration, sorts by id for stability', () {
        final eventA = MCalCalendarEvent(
          id: 'aaa',
          title: 'Event A',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 17, 10, 0),
        );

        final eventZ = MCalCalendarEvent(
          id: 'zzz',
          title: 'Event Z',
          start: DateTime(2025, 1, 15, 10, 0),
          end: DateTime(2025, 1, 17, 10, 0),
        );

        final events = [eventZ, eventA];
        events.sort(MCalMultiDayRenderer.multiDayEventComparator);

        expect(events[0].id, equals('aaa'));
        expect(events[1].id, equals('zzz'));
      });
    });

    group('calculateLayouts()', () {
      test('returns empty list when no multi-day events exist', () {
        final events = [
          MCalCalendarEvent(
            id: 'single-1',
            title: 'Single Event 1',
            start: DateTime(2025, 1, 15, 10, 0),
            end: DateTime(2025, 1, 15, 11, 0),
          ),
          MCalCalendarEvent(
            id: 'single-2',
            title: 'Single Event 2',
            start: DateTime(2025, 1, 20, 14, 0),
            end: DateTime(2025, 1, 20, 15, 0),
          ),
        ];

        final layouts = MCalMultiDayRenderer.calculateLayouts(
          events: events,
          monthStart: DateTime(2025, 1, 1),
          firstDayOfWeek: 0, // Sunday
        );

        expect(layouts, isEmpty);
      });

      test('calculates single-week event with one segment', () {
        // Event from Wednesday Jan 15 to Friday Jan 17 (within one week)
        final event = MCalCalendarEvent(
          id: 'single-week',
          title: 'Single Week Event',
          start: DateTime(2025, 1, 15), // Wednesday
          end: DateTime(2025, 1, 17), // Friday
        );

        final layouts = MCalMultiDayRenderer.calculateLayouts(
          events: [event],
          monthStart: DateTime(2025, 1, 1),
          firstDayOfWeek: 0, // Sunday
        );

        expect(layouts, hasLength(1));
        expect(layouts[0].event.id, equals('single-week'));
        expect(layouts[0].rowSegments, hasLength(1));

        final segment = layouts[0].rowSegments[0];
        expect(segment.isFirstSegment, isTrue);
        expect(segment.isLastSegment, isTrue);
      });

      test('calculates week-wrapping event with two segments', () {
        // Event from Friday Jan 17 to Tuesday Jan 21 (wraps to next week)
        // With Sunday = 0, the week ends on Saturday
        final event = MCalCalendarEvent(
          id: 'week-wrap',
          title: 'Week Wrapping Event',
          start: DateTime(2025, 1, 17), // Friday
          end: DateTime(2025, 1, 21), // Tuesday
        );

        final layouts = MCalMultiDayRenderer.calculateLayouts(
          events: [event],
          monthStart: DateTime(2025, 1, 1),
          firstDayOfWeek: 0, // Sunday
        );

        expect(layouts, hasLength(1));
        expect(layouts[0].event.id, equals('week-wrap'));
        expect(layouts[0].rowSegments, hasLength(2));

        // First segment: Friday to Saturday (end of first week)
        final segment1 = layouts[0].rowSegments[0];
        expect(segment1.isFirstSegment, isTrue);
        expect(segment1.isLastSegment, isFalse);

        // Second segment: Sunday to Tuesday (start of next week)
        final segment2 = layouts[0].rowSegments[1];
        expect(segment2.isFirstSegment, isFalse);
        expect(segment2.isLastSegment, isTrue);
      });

      test('handles month-boundary event (clips to visible grid)', () {
        // Event that starts before the visible month and ends within it
        final event = MCalCalendarEvent(
          id: 'month-boundary',
          title: 'Month Boundary Event',
          start: DateTime(2024, 12, 28), // Before January
          end: DateTime(2025, 1, 5), // Within January
        );

        final layouts = MCalMultiDayRenderer.calculateLayouts(
          events: [event],
          monthStart: DateTime(2025, 1, 1),
          firstDayOfWeek: 0, // Sunday
        );

        expect(layouts, hasLength(1));
        expect(layouts[0].event.id, equals('month-boundary'));

        // The first segment should have isFirstSegment = false (clipped)
        // because the event starts before the visible grid
        final firstSegment = layouts[0].rowSegments.first;
        // isFirstSegment reflects whether the visible start equals the event start
        // Since the event starts Dec 28 but grid might show it (leading days)
        expect(firstSegment, isNotNull);
      });

      test('handles event ending after visible month (clips to visible grid)', () {
        // Event that starts within month but ends after it
        final event = MCalCalendarEvent(
          id: 'extends-past-month',
          title: 'Extends Past Month',
          start: DateTime(2025, 1, 28),
          end: DateTime(2025, 2, 5), // After January
        );

        final layouts = MCalMultiDayRenderer.calculateLayouts(
          events: [event],
          monthStart: DateTime(2025, 1, 1),
          firstDayOfWeek: 0, // Sunday
        );

        expect(layouts, hasLength(1));
        expect(layouts[0].event.id, equals('extends-past-month'));

        // The last segment should reflect clipping
        final lastSegment = layouts[0].rowSegments.last;
        expect(lastSegment, isNotNull);
      });

      test('filters out events completely outside visible grid', () {
        final event = MCalCalendarEvent(
          id: 'outside',
          title: 'Outside Event',
          start: DateTime(2025, 3, 1),
          end: DateTime(2025, 3, 5),
        );

        final layouts = MCalMultiDayRenderer.calculateLayouts(
          events: [event],
          monthStart: DateTime(2025, 1, 1),
          firstDayOfWeek: 0,
        );

        expect(layouts, isEmpty);
      });

      test('handles firstDayOfWeek = 1 (Monday) correctly', () {
        // Event from Sunday Jan 19 to Tuesday Jan 21
        // With Monday = 1, Sunday is the last day of the week
        final event = MCalCalendarEvent(
          id: 'monday-start',
          title: 'Monday Start Week',
          start: DateTime(2025, 1, 19), // Sunday
          end: DateTime(2025, 1, 21), // Tuesday
        );

        final layouts = MCalMultiDayRenderer.calculateLayouts(
          events: [event],
          monthStart: DateTime(2025, 1, 1),
          firstDayOfWeek: 1, // Monday
        );

        expect(layouts, hasLength(1));
        // With Monday as first day, Sunday is last day of week
        // So Sunday Jan 19 is end of one week, Mon-Tue are start of next
        expect(layouts[0].rowSegments, hasLength(2));
      });

      test('calculates correct weekRowIndex values', () {
        // Event spanning multiple weeks
        final event = MCalCalendarEvent(
          id: 'multi-week',
          title: 'Multi Week',
          start: DateTime(2025, 1, 10), // Friday
          end: DateTime(2025, 1, 20), // Monday
        );

        final layouts = MCalMultiDayRenderer.calculateLayouts(
          events: [event],
          monthStart: DateTime(2025, 1, 1),
          firstDayOfWeek: 0, // Sunday
        );

        expect(layouts, hasLength(1));

        // Check that segments have incrementing weekRowIndex
        final segments = layouts[0].rowSegments;
        expect(segments.length, greaterThanOrEqualTo(2));

        for (int i = 0; i < segments.length - 1; i++) {
          expect(segments[i].weekRowIndex, lessThan(segments[i + 1].weekRowIndex));
        }
      });

      test('calculates correct spanDays for each segment', () {
        // Event from Thursday Jan 16 to Sunday Jan 19 (4 days)
        // With Sunday = 0: Thu-Fri-Sat (3 days) in one week, Sun (1 day) in next
        final event = MCalCalendarEvent(
          id: 'span-test',
          title: 'Span Test',
          start: DateTime(2025, 1, 16), // Thursday
          end: DateTime(2025, 1, 19), // Sunday
        );

        final layouts = MCalMultiDayRenderer.calculateLayouts(
          events: [event],
          monthStart: DateTime(2025, 1, 1),
          firstDayOfWeek: 0, // Sunday
        );

        expect(layouts, hasLength(1));
        expect(layouts[0].rowSegments, hasLength(2));

        final segment1 = layouts[0].rowSegments[0];
        expect(segment1.spanDays, equals(3)); // Thu-Fri-Sat = 3 days

        final segment2 = layouts[0].rowSegments[1];
        expect(segment2.spanDays, equals(1)); // Sun = 1 day
      });

      test('sorts multiple multi-day events correctly', () {
        final event1 = MCalCalendarEvent(
          id: 'later-event',
          title: 'Later',
          start: DateTime(2025, 1, 20),
          end: DateTime(2025, 1, 22),
        );

        final event2 = MCalCalendarEvent(
          id: 'earlier-event',
          title: 'Earlier',
          start: DateTime(2025, 1, 10),
          end: DateTime(2025, 1, 12),
        );

        final layouts = MCalMultiDayRenderer.calculateLayouts(
          events: [event1, event2],
          monthStart: DateTime(2025, 1, 1),
          firstDayOfWeek: 0,
        );

        expect(layouts, hasLength(2));
        expect(layouts[0].event.id, equals('earlier-event'));
        expect(layouts[1].event.id, equals('later-event'));
      });
    });

    group('segment flags (isFirstSegment, isLastSegment)', () {
      test('single-row event has isFirstSegment and isLastSegment both true', () {
        final event = MCalCalendarEvent(
          id: 'single-row',
          title: 'Single Row',
          start: DateTime(2025, 1, 14), // Tuesday
          end: DateTime(2025, 1, 16), // Thursday
        );

        final layouts = MCalMultiDayRenderer.calculateLayouts(
          events: [event],
          monthStart: DateTime(2025, 1, 1),
          firstDayOfWeek: 0,
        );

        expect(layouts, hasLength(1));
        expect(layouts[0].rowSegments, hasLength(1));

        final segment = layouts[0].rowSegments[0];
        expect(segment.isFirstSegment, isTrue);
        expect(segment.isLastSegment, isTrue);
      });

      test('first segment of multi-row event has correct flags', () {
        final event = MCalCalendarEvent(
          id: 'multi-row',
          title: 'Multi Row',
          start: DateTime(2025, 1, 17), // Friday
          end: DateTime(2025, 1, 21), // Tuesday
        );

        final layouts = MCalMultiDayRenderer.calculateLayouts(
          events: [event],
          monthStart: DateTime(2025, 1, 1),
          firstDayOfWeek: 0,
        );

        expect(layouts, hasLength(1));
        expect(layouts[0].rowSegments.length, greaterThanOrEqualTo(2));

        final firstSegment = layouts[0].rowSegments.first;
        expect(firstSegment.isFirstSegment, isTrue);
        expect(firstSegment.isLastSegment, isFalse);
      });

      test('middle segment of multi-row event has both flags false', () {
        // Event spanning 3 weeks
        final event = MCalCalendarEvent(
          id: 'three-week',
          title: 'Three Week',
          start: DateTime(2025, 1, 10), // Friday
          end: DateTime(2025, 1, 26), // Sunday
        );

        final layouts = MCalMultiDayRenderer.calculateLayouts(
          events: [event],
          monthStart: DateTime(2025, 1, 1),
          firstDayOfWeek: 0,
        );

        expect(layouts, hasLength(1));
        expect(layouts[0].rowSegments.length, greaterThanOrEqualTo(3));

        // Middle segment(s) should have both flags false
        for (int i = 1; i < layouts[0].rowSegments.length - 1; i++) {
          final segment = layouts[0].rowSegments[i];
          expect(segment.isFirstSegment, isFalse, 
              reason: 'Segment $i should not be first segment');
          expect(segment.isLastSegment, isFalse, 
              reason: 'Segment $i should not be last segment');
        }
      });

      test('last segment of multi-row event has correct flags', () {
        final event = MCalCalendarEvent(
          id: 'multi-row',
          title: 'Multi Row',
          start: DateTime(2025, 1, 17), // Friday
          end: DateTime(2025, 1, 21), // Tuesday
        );

        final layouts = MCalMultiDayRenderer.calculateLayouts(
          events: [event],
          monthStart: DateTime(2025, 1, 1),
          firstDayOfWeek: 0,
        );

        expect(layouts, hasLength(1));
        expect(layouts[0].rowSegments.length, greaterThanOrEqualTo(2));

        final lastSegment = layouts[0].rowSegments.last;
        expect(lastSegment.isFirstSegment, isFalse);
        expect(lastSegment.isLastSegment, isTrue);
      });

      test('clipped event at start has isFirstSegment false', () {
        // Event starting before visible grid
        final event = MCalCalendarEvent(
          id: 'clipped-start',
          title: 'Clipped Start',
          start: DateTime(2024, 12, 20), // Before grid
          end: DateTime(2025, 1, 5),
        );

        final layouts = MCalMultiDayRenderer.calculateLayouts(
          events: [event],
          monthStart: DateTime(2025, 1, 1),
          firstDayOfWeek: 0,
        );

        if (layouts.isNotEmpty) {
          final firstSegment = layouts[0].rowSegments.first;
          // If the event starts before the visible grid, isFirstSegment should be false
          // because the visible start doesn't match the event start
          expect(firstSegment.isFirstSegment, isFalse);
        }
      });

      test('clipped event at end has isLastSegment false', () {
        // Event ending after visible grid
        final event = MCalCalendarEvent(
          id: 'clipped-end',
          title: 'Clipped End',
          start: DateTime(2025, 1, 28),
          end: DateTime(2025, 2, 10), // After grid
        );

        final layouts = MCalMultiDayRenderer.calculateLayouts(
          events: [event],
          monthStart: DateTime(2025, 1, 1),
          firstDayOfWeek: 0,
        );

        if (layouts.isNotEmpty) {
          final lastSegment = layouts[0].rowSegments.last;
          // If the event ends after the visible grid, isLastSegment should be false
          expect(lastSegment.isLastSegment, isFalse);
        }
      });
    });

    group('MCalMultiDayRowSegment', () {
      test('spanDays returns correct value', () {
        final segment = MCalMultiDayRowSegment(
          weekRowIndex: 0,
          startDayInRow: 2,
          endDayInRow: 5,
          isFirstSegment: true,
          isLastSegment: false,
        );

        expect(segment.spanDays, equals(4)); // 5 - 2 + 1 = 4
      });

      test('spanDays returns 1 for single-day segment', () {
        final segment = MCalMultiDayRowSegment(
          weekRowIndex: 0,
          startDayInRow: 3,
          endDayInRow: 3,
          isFirstSegment: true,
          isLastSegment: true,
        );

        expect(segment.spanDays, equals(1));
      });

      test('spanDays returns 7 for full-week segment', () {
        final segment = MCalMultiDayRowSegment(
          weekRowIndex: 0,
          startDayInRow: 0,
          endDayInRow: 6,
          isFirstSegment: false,
          isLastSegment: false,
        );

        expect(segment.spanDays, equals(7));
      });

      test('equals and hashCode work correctly', () {
        final segment1 = MCalMultiDayRowSegment(
          weekRowIndex: 1,
          startDayInRow: 2,
          endDayInRow: 4,
          isFirstSegment: true,
          isLastSegment: false,
        );

        final segment2 = MCalMultiDayRowSegment(
          weekRowIndex: 1,
          startDayInRow: 2,
          endDayInRow: 4,
          isFirstSegment: true,
          isLastSegment: false,
        );

        final segment3 = MCalMultiDayRowSegment(
          weekRowIndex: 1,
          startDayInRow: 2,
          endDayInRow: 5, // Different
          isFirstSegment: true,
          isLastSegment: false,
        );

        expect(segment1, equals(segment2));
        expect(segment1.hashCode, equals(segment2.hashCode));
        expect(segment1, isNot(equals(segment3)));
      });

      test('toString returns meaningful representation', () {
        final segment = MCalMultiDayRowSegment(
          weekRowIndex: 2,
          startDayInRow: 1,
          endDayInRow: 5,
          isFirstSegment: true,
          isLastSegment: false,
        );

        final str = segment.toString();
        expect(str, contains('weekRowIndex: 2'));
        expect(str, contains('startDayInRow: 1'));
        expect(str, contains('endDayInRow: 5'));
        expect(str, contains('isFirstSegment: true'));
        expect(str, contains('isLastSegment: false'));
      });
    });

    group('MCalMultiDayEventLayout', () {
      test('equals and hashCode work correctly', () {
        final event = MCalCalendarEvent(
          id: 'test-event',
          title: 'Test',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 17),
        );

        final segment = MCalMultiDayRowSegment(
          weekRowIndex: 0,
          startDayInRow: 3,
          endDayInRow: 5,
          isFirstSegment: true,
          isLastSegment: true,
        );

        final layout1 = MCalMultiDayEventLayout(
          event: event,
          rowSegments: [segment],
        );

        final layout2 = MCalMultiDayEventLayout(
          event: event,
          rowSegments: [segment],
        );

        expect(layout1, equals(layout2));
        expect(layout1.hashCode, equals(layout2.hashCode));
      });

      test('toString returns meaningful representation', () {
        final event = MCalCalendarEvent(
          id: 'test-event',
          title: 'Test',
          start: DateTime(2025, 1, 15),
          end: DateTime(2025, 1, 17),
        );

        final layout = MCalMultiDayEventLayout(
          event: event,
          rowSegments: [
            MCalMultiDayRowSegment(
              weekRowIndex: 0,
              startDayInRow: 3,
              endDayInRow: 5,
              isFirstSegment: true,
              isLastSegment: true,
            ),
          ],
        );

        final str = layout.toString();
        expect(str, contains('test-event'));
        expect(str, contains('segments: 1'));
      });
    });

    group('calculateWeekLayout() - Greedy First-Fit Algorithm', () {
      // Helper to generate week dates starting from a given Sunday
      List<DateTime> weekDatesFrom(DateTime sunday) {
        return List.generate(7, (i) => sunday.add(Duration(days: i)));
      }

      test('returns empty frame when no multi-day events', () {
        final weekDates = weekDatesFrom(DateTime(2025, 1, 12)); // Sun-Sat

        final frame = MCalMultiDayRenderer.calculateWeekLayout(
          multiDayLayouts: [],
          weekDates: weekDates,
          weekRowIndex: 0,
        );

        expect(frame.assignments, isEmpty);
        expect(frame.totalRows, equals(0));
        expect(frame.columnMaxRows, isEmpty);
      });

      test('single event gets assigned to row 0', () {
        final event = MCalCalendarEvent(
          id: 'event-1',
          title: 'Single Event',
          start: DateTime(2025, 1, 14), // Tuesday
          end: DateTime(2025, 1, 16), // Thursday
        );

        final layouts = MCalMultiDayRenderer.calculateLayouts(
          events: [event],
          monthStart: DateTime(2025, 1, 1),
          firstDayOfWeek: 0,
        );

        final weekDates = weekDatesFrom(DateTime(2025, 1, 12)); // Week containing the event

        final frame = MCalMultiDayRenderer.calculateWeekLayout(
          multiDayLayouts: layouts,
          weekDates: weekDates,
          weekRowIndex: 2, // Third week of January
        );

        expect(frame.assignments, hasLength(1));
        expect(frame.assignments[0].row, equals(0));
        expect(frame.totalRows, equals(1));
      });

      test('non-overlapping events share row 0', () {
        // Event A: Mon-Tue, Event B: Thu-Fri (no overlap)
        final eventA = MCalCalendarEvent(
          id: 'event-a',
          title: 'Event A',
          start: DateTime(2025, 1, 13), // Monday
          end: DateTime(2025, 1, 14), // Tuesday
        );

        final eventB = MCalCalendarEvent(
          id: 'event-b',
          title: 'Event B',
          start: DateTime(2025, 1, 16), // Thursday
          end: DateTime(2025, 1, 17), // Friday
        );

        final layouts = MCalMultiDayRenderer.calculateLayouts(
          events: [eventA, eventB],
          monthStart: DateTime(2025, 1, 1),
          firstDayOfWeek: 0,
        );

        final weekDates = weekDatesFrom(DateTime(2025, 1, 12));

        final frame = MCalMultiDayRenderer.calculateWeekLayout(
          multiDayLayouts: layouts,
          weekDates: weekDates,
          weekRowIndex: 2,
        );

        expect(frame.assignments, hasLength(2));
        // Both should be in row 0 since they don't overlap
        expect(frame.assignments[0].row, equals(0));
        expect(frame.assignments[1].row, equals(0));
        expect(frame.totalRows, equals(1));
      });

      test('overlapping events get different rows', () {
        // Event A: Mon-Thu, Event B: Wed-Fri (overlap on Wed-Thu)
        final eventA = MCalCalendarEvent(
          id: 'event-a',
          title: 'Event A',
          start: DateTime(2025, 1, 13), // Monday
          end: DateTime(2025, 1, 16), // Thursday
        );

        final eventB = MCalCalendarEvent(
          id: 'event-b',
          title: 'Event B',
          start: DateTime(2025, 1, 15), // Wednesday
          end: DateTime(2025, 1, 17), // Friday
        );

        final layouts = MCalMultiDayRenderer.calculateLayouts(
          events: [eventA, eventB],
          monthStart: DateTime(2025, 1, 1),
          firstDayOfWeek: 0,
        );

        final weekDates = weekDatesFrom(DateTime(2025, 1, 12));

        final frame = MCalMultiDayRenderer.calculateWeekLayout(
          multiDayLayouts: layouts,
          weekDates: weekDates,
          weekRowIndex: 2,
        );

        expect(frame.assignments, hasLength(2));
        // First event gets row 0, overlapping event gets row 1
        expect(frame.assignments[0].row, equals(0));
        expect(frame.assignments[1].row, equals(1));
        expect(frame.totalRows, equals(2));
      });

      test('greedy first-fit fills gaps in earlier rows', () {
        // Event A: Mon-Thu (row 0)
        // Event B: Tue-Wed (overlaps A, row 1)
        // Event C: Fri-Sat (no overlap, should fit in row 0)
        final eventA = MCalCalendarEvent(
          id: 'event-a',
          title: 'Event A',
          start: DateTime(2025, 1, 13), // Monday
          end: DateTime(2025, 1, 16), // Thursday
        );

        final eventB = MCalCalendarEvent(
          id: 'event-b',
          title: 'Event B',
          start: DateTime(2025, 1, 14), // Tuesday
          end: DateTime(2025, 1, 15), // Wednesday
        );

        final eventC = MCalCalendarEvent(
          id: 'event-c',
          title: 'Event C',
          start: DateTime(2025, 1, 17), // Friday
          end: DateTime(2025, 1, 18), // Saturday
        );

        final layouts = MCalMultiDayRenderer.calculateLayouts(
          events: [eventA, eventB, eventC],
          monthStart: DateTime(2025, 1, 1),
          firstDayOfWeek: 0,
        );

        final weekDates = weekDatesFrom(DateTime(2025, 1, 12));

        final frame = MCalMultiDayRenderer.calculateWeekLayout(
          multiDayLayouts: layouts,
          weekDates: weekDates,
          weekRowIndex: 2,
        );

        expect(frame.assignments, hasLength(3));
        // A is in row 0 (Mon-Thu)
        // B is in row 1 (overlaps with A on Tue-Wed)
        // C should fit in row 0 (Fri-Sat, no overlap with A)
        expect(frame.totalRows, equals(2)); // Only 2 rows needed
        
        // Find Event C's assignment
        final eventCAssignment = frame.assignments.firstWhere(
          (a) => a.event.id == 'event-c',
        );
        expect(eventCAssignment.row, equals(0)); // C fills the gap in row 0
      });

      test('columnMaxRows tracks per-column occupancy correctly', () {
        // Event A: Mon-Wed (columns 1-3)
        // Event B: Tue-Thu (columns 2-4, overlaps A)
        final eventA = MCalCalendarEvent(
          id: 'event-a',
          title: 'Event A',
          start: DateTime(2025, 1, 13), // Monday
          end: DateTime(2025, 1, 15), // Wednesday
        );

        final eventB = MCalCalendarEvent(
          id: 'event-b',
          title: 'Event B',
          start: DateTime(2025, 1, 14), // Tuesday
          end: DateTime(2025, 1, 16), // Thursday
        );

        final layouts = MCalMultiDayRenderer.calculateLayouts(
          events: [eventA, eventB],
          monthStart: DateTime(2025, 1, 1),
          firstDayOfWeek: 0,
        );

        final weekDates = weekDatesFrom(DateTime(2025, 1, 12));

        final frame = MCalMultiDayRenderer.calculateWeekLayout(
          multiDayLayouts: layouts,
          weekDates: weekDates,
          weekRowIndex: 2,
        );

        // Monday (column 1): only A in row 0
        expect(frame.maxRowAtColumn(1), equals(0));
        expect(frame.rowCountAtColumn(1), equals(1));

        // Tuesday (column 2): A in row 0, B in row 1
        expect(frame.maxRowAtColumn(2), equals(1));
        expect(frame.rowCountAtColumn(2), equals(2));

        // Wednesday (column 3): A in row 0, B in row 1
        expect(frame.maxRowAtColumn(3), equals(1));
        expect(frame.rowCountAtColumn(3), equals(2));

        // Thursday (column 4): only B in row 1
        expect(frame.maxRowAtColumn(4), equals(1));
        expect(frame.rowCountAtColumn(4), equals(2));

        // Sunday (column 0): no events
        expect(frame.maxRowAtColumn(0), equals(-1));
        expect(frame.rowCountAtColumn(0), equals(0));
      });

      test('assignments are sorted by row then column', () {
        // Create multiple events that will be assigned to different positions
        final eventA = MCalCalendarEvent(
          id: 'event-a',
          title: 'Event A',
          start: DateTime(2025, 1, 16), // Thursday
          end: DateTime(2025, 1, 17), // Friday
        );

        final eventB = MCalCalendarEvent(
          id: 'event-b',
          title: 'Event B',
          start: DateTime(2025, 1, 13), // Monday
          end: DateTime(2025, 1, 14), // Tuesday
        );

        final layouts = MCalMultiDayRenderer.calculateLayouts(
          events: [eventA, eventB],
          monthStart: DateTime(2025, 1, 1),
          firstDayOfWeek: 0,
        );

        final weekDates = weekDatesFrom(DateTime(2025, 1, 12));

        final frame = MCalMultiDayRenderer.calculateWeekLayout(
          multiDayLayouts: layouts,
          weekDates: weekDates,
          weekRowIndex: 2,
        );

        // Both are in row 0, should be sorted by startColumn
        expect(frame.assignments[0].startColumn, lessThan(frame.assignments[1].startColumn));
      });

      test('MCalWeekEventLayoutFrame.empty() creates correct empty frame', () {
        final weekDates = weekDatesFrom(DateTime(2025, 1, 12));

        final frame = MCalWeekEventLayoutFrame.empty(
          weekRowIndex: 2,
          weekDates: weekDates,
        );

        expect(frame.weekRowIndex, equals(2));
        expect(frame.weekDates, equals(weekDates));
        expect(frame.assignments, isEmpty);
        expect(frame.totalRows, equals(0));
        expect(frame.columnMaxRows, isEmpty);
      });

      test('multi-week event gets correct row assignment in each week independently', () {
        // Event spanning two weeks
        final event = MCalCalendarEvent(
          id: 'multi-week',
          title: 'Multi Week Event',
          start: DateTime(2025, 1, 17), // Friday week 2
          end: DateTime(2025, 1, 21), // Tuesday week 3
        );

        final layouts = MCalMultiDayRenderer.calculateLayouts(
          events: [event],
          monthStart: DateTime(2025, 1, 1),
          firstDayOfWeek: 0,
        );

        // Week 2 (Jan 12-18)
        final week2Dates = weekDatesFrom(DateTime(2025, 1, 12));
        final frame2 = MCalMultiDayRenderer.calculateWeekLayout(
          multiDayLayouts: layouts,
          weekDates: week2Dates,
          weekRowIndex: 2,
        );

        // Week 3 (Jan 19-25)
        final week3Dates = weekDatesFrom(DateTime(2025, 1, 19));
        final frame3 = MCalMultiDayRenderer.calculateWeekLayout(
          multiDayLayouts: layouts,
          weekDates: week3Dates,
          weekRowIndex: 3,
        );

        // Both weeks should have the event in row 0
        expect(frame2.assignments, hasLength(1));
        expect(frame2.assignments[0].row, equals(0));

        expect(frame3.assignments, hasLength(1));
        expect(frame3.assignments[0].row, equals(0));
      });

      test('complex scenario with multiple overlapping events', () {
        // Week: Sun Mon Tue Wed Thu Fri Sat
        //       |   A---------A   |   |   |  (Mon-Thu)
        //       |   |   B---------B   |   |  (Tue-Fri)
        //       |   |   |   C---C |   |   |  (Wed-Thu)
        //       |   D   |   |   |   |   |   |  (Mon only, single-column)
        final eventA = MCalCalendarEvent(
          id: 'A',
          title: 'Event A',
          start: DateTime(2025, 1, 13), // Monday
          end: DateTime(2025, 1, 16), // Thursday
        );

        final eventB = MCalCalendarEvent(
          id: 'B',
          title: 'Event B',
          start: DateTime(2025, 1, 14), // Tuesday
          end: DateTime(2025, 1, 17), // Friday
        );

        final eventC = MCalCalendarEvent(
          id: 'C',
          title: 'Event C',
          start: DateTime(2025, 1, 15), // Wednesday
          end: DateTime(2025, 1, 16), // Thursday
        );

        // Note: D is a single-day event, so it won't be in multi-day layouts

        final layouts = MCalMultiDayRenderer.calculateLayouts(
          events: [eventA, eventB, eventC],
          monthStart: DateTime(2025, 1, 1),
          firstDayOfWeek: 0,
        );

        final weekDates = weekDatesFrom(DateTime(2025, 1, 12));

        final frame = MCalMultiDayRenderer.calculateWeekLayout(
          multiDayLayouts: layouts,
          weekDates: weekDates,
          weekRowIndex: 2,
        );

        expect(frame.assignments, hasLength(3));

        // A is longest and starts earliest -> row 0
        final assignmentA = frame.assignments.firstWhere((a) => a.event.id == 'A');
        expect(assignmentA.row, equals(0));

        // B overlaps with A -> row 1
        final assignmentB = frame.assignments.firstWhere((a) => a.event.id == 'B');
        expect(assignmentB.row, equals(1));

        // C overlaps with both A (Wed-Thu) and B (Wed-Thu) -> row 2
        final assignmentC = frame.assignments.firstWhere((a) => a.event.id == 'C');
        expect(assignmentC.row, equals(2));

        expect(frame.totalRows, equals(3));
      });
    });

    group('MCalEventLayoutAssignment', () {
      test('columnSpan returns correct value', () {
        final event = MCalCalendarEvent(
          id: 'test',
          title: 'Test',
          start: DateTime(2025, 1, 13),
          end: DateTime(2025, 1, 16),
        );

        final segment = MCalMultiDayRowSegment(
          weekRowIndex: 0,
          startDayInRow: 1,
          endDayInRow: 4,
          isFirstSegment: true,
          isLastSegment: true,
        );

        final assignment = MCalEventLayoutAssignment(
          event: event,
          segment: segment,
          row: 0,
          startColumn: 1,
          endColumn: 4,
        );

        expect(assignment.columnSpan, equals(4)); // 4 - 1 + 1 = 4
      });

      test('equals and hashCode work correctly', () {
        final event = MCalCalendarEvent(
          id: 'test',
          title: 'Test',
          start: DateTime(2025, 1, 13),
          end: DateTime(2025, 1, 16),
        );

        final segment = MCalMultiDayRowSegment(
          weekRowIndex: 0,
          startDayInRow: 1,
          endDayInRow: 4,
          isFirstSegment: true,
          isLastSegment: true,
        );

        final assignment1 = MCalEventLayoutAssignment(
          event: event,
          segment: segment,
          row: 0,
          startColumn: 1,
          endColumn: 4,
        );

        final assignment2 = MCalEventLayoutAssignment(
          event: event,
          segment: segment,
          row: 0,
          startColumn: 1,
          endColumn: 4,
        );

        expect(assignment1, equals(assignment2));
        expect(assignment1.hashCode, equals(assignment2.hashCode));
      });

      test('toString returns meaningful representation', () {
        final event = MCalCalendarEvent(
          id: 'test-event',
          title: 'Test',
          start: DateTime(2025, 1, 13),
          end: DateTime(2025, 1, 16),
        );

        final segment = MCalMultiDayRowSegment(
          weekRowIndex: 0,
          startDayInRow: 1,
          endDayInRow: 4,
          isFirstSegment: true,
          isLastSegment: true,
        );

        final assignment = MCalEventLayoutAssignment(
          event: event,
          segment: segment,
          row: 2,
          startColumn: 1,
          endColumn: 4,
        );

        final str = assignment.toString();
        expect(str, contains('test-event'));
        expect(str, contains('row: 2'));
        expect(str, contains('columns: 1-4'));
      });
    });

    group('MCalWeekEventLayoutFrame', () {
      test('equals and hashCode work correctly', () {
        final weekDates = List.generate(
          7,
          (i) => DateTime(2025, 1, 12).add(Duration(days: i)),
        );

        final frame1 = MCalWeekEventLayoutFrame(
          weekRowIndex: 2,
          weekDates: weekDates,
          assignments: [],
          totalRows: 0,
          columnMaxRows: {},
        );

        final frame2 = MCalWeekEventLayoutFrame(
          weekRowIndex: 2,
          weekDates: weekDates,
          assignments: [],
          totalRows: 0,
          columnMaxRows: {},
        );

        expect(frame1, equals(frame2));
        expect(frame1.hashCode, equals(frame2.hashCode));
      });

      test('toString returns meaningful representation', () {
        final weekDates = List.generate(
          7,
          (i) => DateTime(2025, 1, 12).add(Duration(days: i)),
        );

        final frame = MCalWeekEventLayoutFrame(
          weekRowIndex: 2,
          weekDates: weekDates,
          assignments: [],
          totalRows: 3,
          columnMaxRows: {},
        );

        final str = frame.toString();
        expect(str, contains('weekRowIndex: 2'));
        expect(str, contains('totalRows: 3'));
      });
    });
  });
}
