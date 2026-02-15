import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/src/models/mcal_calendar_event.dart';
import 'package:multi_calendar/src/utils/day_view_overlap.dart';

/// Helper to create a timed event for testing overlap detection.
MCalCalendarEvent event({
  required String id,
  required int startHour,
  required int startMinute,
  required int endHour,
  required int endMinute,
  int year = 2026,
  int month = 2,
  int day = 14,
}) {
  return MCalCalendarEvent(
    id: id,
    title: id,
    start: DateTime(year, month, day, startHour, startMinute),
    end: DateTime(year, month, day, endHour, endMinute),
    isAllDay: false,
  );
}

void main() {
  group('detectOverlapsAndAssignColumns', () {
    group('empty and single event', () {
      test('returns empty list for 0 events', () {
        final result = detectOverlapsAndAssignColumns([]);
        expect(result, isEmpty);
      });

      test('single event gets column 0 and totalColumns 1', () {
        final events = [
          event(
            id: 'a',
            startHour: 9,
            startMinute: 0,
            endHour: 10,
            endMinute: 0,
          ),
        ];
        final result = detectOverlapsAndAssignColumns(events);
        expect(result.length, 1);
        expect(result[0].event.id, 'a');
        expect(result[0].columnIndex, 0);
        expect(result[0].totalColumns, 1);
      });
    });

    group('no overlaps - each event in separate column', () {
      test('two non-overlapping events each get own column', () {
        final events = [
          event(
            id: 'a',
            startHour: 9,
            startMinute: 0,
            endHour: 10,
            endMinute: 0,
          ),
          event(
            id: 'b',
            startHour: 11,
            startMinute: 0,
            endHour: 12,
            endMinute: 0,
          ),
        ];
        final result = detectOverlapsAndAssignColumns(events);
        expect(result.length, 2);
        expect(result[0].columnIndex, 0);
        expect(result[0].totalColumns, 1);
        expect(result[1].columnIndex, 0);
        expect(result[1].totalColumns, 1);
      });

      test('three non-overlapping events each get own column', () {
        final events = [
          event(
            id: 'a',
            startHour: 9,
            startMinute: 0,
            endHour: 10,
            endMinute: 0,
          ),
          event(
            id: 'b',
            startHour: 11,
            startMinute: 0,
            endHour: 12,
            endMinute: 0,
          ),
          event(
            id: 'c',
            startHour: 14,
            startMinute: 0,
            endHour: 15,
            endMinute: 0,
          ),
        ];
        final result = detectOverlapsAndAssignColumns(events);
        expect(result.length, 3);
        for (final r in result) {
          expect(r.columnIndex, 0);
          expect(r.totalColumns, 1);
        }
      });
    });

    group('two overlapping events - side by side', () {
      test('two overlapping events get columns 0 and 1', () {
        final events = [
          event(
            id: 'a',
            startHour: 9,
            startMinute: 0,
            endHour: 10,
            endMinute: 30,
          ),
          event(
            id: 'b',
            startHour: 10,
            startMinute: 0,
            endHour: 11,
            endMinute: 0,
          ),
        ];
        final result = detectOverlapsAndAssignColumns(events);
        expect(result.length, 2);
        expect(result[0].totalColumns, 2);
        expect(result[1].totalColumns, 2);
        expect(result[0].columnIndex, 0);
        expect(result[1].columnIndex, 1);
      });

      test('two fully overlapping events get columns 0 and 1', () {
        final events = [
          event(
            id: 'a',
            startHour: 9,
            startMinute: 0,
            endHour: 11,
            endMinute: 0,
          ),
          event(
            id: 'b',
            startHour: 9,
            startMinute: 30,
            endHour: 10,
            endMinute: 30,
          ),
        ];
        final result = detectOverlapsAndAssignColumns(events);
        expect(result.length, 2);
        expect(result[0].totalColumns, 2);
        expect(result[1].totalColumns, 2);
        expect(result[0].columnIndex, 0);
        expect(result[1].columnIndex, 1);
      });
    });

    group('three overlapping events - three columns', () {
      test('three concurrent events get three columns', () {
        final events = [
          event(
            id: 'a',
            startHour: 9,
            startMinute: 0,
            endHour: 11,
            endMinute: 0,
          ),
          event(
            id: 'b',
            startHour: 9,
            startMinute: 30,
            endHour: 10,
            endMinute: 30,
          ),
          event(
            id: 'c',
            startHour: 10,
            startMinute: 0,
            endHour: 11,
            endMinute: 30,
          ),
        ];
        final result = detectOverlapsAndAssignColumns(events);
        expect(result.length, 3);
        expect(result[0].totalColumns, 3);
        expect(result[1].totalColumns, 3);
        expect(result[2].totalColumns, 3);
        expect(result[0].columnIndex, 0);
        expect(result[1].columnIndex, 1);
        expect(result[2].columnIndex, 2);
      });

      test('three events at same start time get three columns', () {
        final events = [
          event(
            id: 'a',
            startHour: 9,
            startMinute: 0,
            endHour: 10,
            endMinute: 0,
          ),
          event(
            id: 'b',
            startHour: 9,
            startMinute: 0,
            endHour: 10,
            endMinute: 30,
          ),
          event(
            id: 'c',
            startHour: 9,
            startMinute: 0,
            endHour: 11,
            endMinute: 0,
          ),
        ];
        final result = detectOverlapsAndAssignColumns(events);
        expect(result.length, 3);
        for (final r in result) {
          expect(r.totalColumns, 3);
          expect(r.columnIndex, inInclusiveRange(0, 2));
        }
        // All three column indices should be used (0, 1, 2)
        final indices = result.map((r) => r.columnIndex).toSet();
        expect(indices.length, 3);
      });
    });

    group('partial overlaps - correct column assignment', () {
      test(
        'nested overlaps: A contains B, B overlaps C - C reuses column 0',
        () {
          // A: 9:00-10:00, B: 9:30-10:30, C: 10:15-11:00
          // A and B overlap -> columns 0,1
          // C overlaps B but not A -> reuses column 0
          final events = [
            event(
              id: 'a',
              startHour: 9,
              startMinute: 0,
              endHour: 10,
              endMinute: 0,
            ),
            event(
              id: 'b',
              startHour: 9,
              startMinute: 30,
              endHour: 10,
              endMinute: 30,
            ),
            event(
              id: 'c',
              startHour: 10,
              startMinute: 15,
              endHour: 11,
              endMinute: 0,
            ),
          ];
          final result = detectOverlapsAndAssignColumns(events);
          expect(result.length, 3);
          expect(result[0].totalColumns, 2);
          expect(result[1].totalColumns, 2);
          expect(result[2].totalColumns, 2);
          expect(result[0].columnIndex, 0);
          expect(result[1].columnIndex, 1);
          expect(
            result[2].columnIndex,
            0,
          ); // C reuses column 0 (doesn't overlap A)
        },
      );

      test('chain overlap: A-B, B-C, A and C do not overlap', () {
        // A: 9:00-9:45, B: 9:30-10:15, C: 10:00-10:45
        // A and B overlap, B and C overlap, A and C don't overlap
        final events = [
          event(
            id: 'a',
            startHour: 9,
            startMinute: 0,
            endHour: 9,
            endMinute: 45,
          ),
          event(
            id: 'b',
            startHour: 9,
            startMinute: 30,
            endHour: 10,
            endMinute: 15,
          ),
          event(
            id: 'c',
            startHour: 10,
            startMinute: 0,
            endHour: 10,
            endMinute: 45,
          ),
        ];
        final result = detectOverlapsAndAssignColumns(events);
        expect(result.length, 3);
        expect(result[0].totalColumns, 2);
        expect(result[1].totalColumns, 2);
        expect(result[2].totalColumns, 2);
        expect(result[0].columnIndex, 0);
        expect(result[1].columnIndex, 1);
        expect(result[2].columnIndex, 0); // C reuses A's column
      });
    });

    group('events at same time - proper ordering', () {
      test('two events at exact same time get columns 0 and 1', () {
        final events = [
          event(
            id: 'a',
            startHour: 9,
            startMinute: 0,
            endHour: 10,
            endMinute: 0,
          ),
          event(
            id: 'b',
            startHour: 9,
            startMinute: 0,
            endHour: 10,
            endMinute: 0,
          ),
        ];
        final result = detectOverlapsAndAssignColumns(events);
        expect(result.length, 2);
        expect(result[0].totalColumns, 2);
        expect(result[1].totalColumns, 2);
        expect(result[0].columnIndex, 0);
        expect(result[1].columnIndex, 1);
      });

      test('preserves original event order in result', () {
        final events = [
          event(
            id: 'z',
            startHour: 11,
            startMinute: 0,
            endHour: 12,
            endMinute: 0,
          ),
          event(
            id: 'a',
            startHour: 9,
            startMinute: 0,
            endHour: 10,
            endMinute: 0,
          ),
          event(
            id: 'm',
            startHour: 10,
            startMinute: 0,
            endHour: 11,
            endMinute: 0,
          ),
        ];
        final result = detectOverlapsAndAssignColumns(events);
        expect(result.length, 3);
        expect(result[0].event.id, 'z');
        expect(result[1].event.id, 'a');
        expect(result[2].event.id, 'm');
      });
    });

    group('edge case: event ending when another starts - no overlap', () {
      test('adjacent events do not overlap', () {
        // A ends at 10:00, B starts at 10:00 - touching but not overlapping
        final events = [
          event(
            id: 'a',
            startHour: 9,
            startMinute: 0,
            endHour: 10,
            endMinute: 0,
          ),
          event(
            id: 'b',
            startHour: 10,
            startMinute: 0,
            endHour: 11,
            endMinute: 0,
          ),
        ];
        final result = detectOverlapsAndAssignColumns(events);
        expect(result.length, 2);
        expect(result[0].totalColumns, 1);
        expect(result[1].totalColumns, 1);
        expect(result[0].columnIndex, 0);
        expect(result[1].columnIndex, 0);
      });

      test('event ending at 23:59 and next at midnight next day', () {
        final events = [
          event(
            id: 'a',
            startHour: 23,
            startMinute: 0,
            endHour: 23,
            endMinute: 59,
          ),
          event(
            id: 'b',
            startHour: 0,
            startMinute: 0,
            endHour: 1,
            endMinute: 0,
            day: 15,
          ),
        ];
        final result = detectOverlapsAndAssignColumns(events);
        expect(result.length, 2);
        expect(result[0].totalColumns, 1);
        expect(result[1].totalColumns, 1);
      });
    });

    group('complex multi-event scenarios', () {
      test('mixed overlapping and non-overlapping groups', () {
        // Group 1: A, B overlap (9-10:30, 10-11)
        // Group 2: C alone (12-13)
        // Group 3: D, E, F overlap (14-16, 14:30-15:30, 15-16:30)
        final events = [
          event(
            id: 'a',
            startHour: 9,
            startMinute: 0,
            endHour: 10,
            endMinute: 30,
          ),
          event(
            id: 'b',
            startHour: 10,
            startMinute: 0,
            endHour: 11,
            endMinute: 0,
          ),
          event(
            id: 'c',
            startHour: 12,
            startMinute: 0,
            endHour: 13,
            endMinute: 0,
          ),
          event(
            id: 'd',
            startHour: 14,
            startMinute: 0,
            endHour: 16,
            endMinute: 0,
          ),
          event(
            id: 'e',
            startHour: 14,
            startMinute: 30,
            endHour: 15,
            endMinute: 30,
          ),
          event(
            id: 'f',
            startHour: 15,
            startMinute: 0,
            endHour: 16,
            endMinute: 30,
          ),
        ];
        final result = detectOverlapsAndAssignColumns(events);
        expect(result.length, 6);

        // Group 1: a, b
        expect(result[0].totalColumns, 2);
        expect(result[1].totalColumns, 2);

        // Group 2: c
        expect(result[2].totalColumns, 1);

        // Group 3: d, e, f
        expect(result[3].totalColumns, 3);
        expect(result[4].totalColumns, 3);
        expect(result[5].totalColumns, 3);
      });

      test('four fully concurrent events get four columns', () {
        // All four overlap with each other: 9:00-10:00, 9:00-10:00, 9:00-10:00, 9:00-10:00
        final events = [
          event(
            id: 'a',
            startHour: 9,
            startMinute: 0,
            endHour: 10,
            endMinute: 0,
          ),
          event(
            id: 'b',
            startHour: 9,
            startMinute: 0,
            endHour: 10,
            endMinute: 0,
          ),
          event(
            id: 'c',
            startHour: 9,
            startMinute: 0,
            endHour: 10,
            endMinute: 0,
          ),
          event(
            id: 'd',
            startHour: 9,
            startMinute: 0,
            endHour: 10,
            endMinute: 0,
          ),
        ];
        final result = detectOverlapsAndAssignColumns(events);
        expect(result.length, 4);
        for (final r in result) {
          expect(r.totalColumns, 4);
          expect(r.columnIndex, inInclusiveRange(0, 3));
        }
        final indices = result.map((r) => r.columnIndex).toSet();
        expect(indices.length, 4);
      });
    });

    group('column width calculations', () {
      test('totalColumns determines column count for width calculation', () {
        final events = [
          event(
            id: 'a',
            startHour: 9,
            startMinute: 0,
            endHour: 11,
            endMinute: 0,
          ),
          event(
            id: 'b',
            startHour: 9,
            startMinute: 30,
            endHour: 10,
            endMinute: 30,
          ),
          event(
            id: 'c',
            startHour: 10,
            startMinute: 0,
            endHour: 11,
            endMinute: 30,
          ),
        ];
        final result = detectOverlapsAndAssignColumns(events);
        const areaWidth = 300.0;
        for (final r in result) {
          final columnWidth = areaWidth / r.totalColumns;
          expect(columnWidth, 100.0); // 300/3
          expect(r.columnIndex, lessThan(r.totalColumns));
        }
      });

      test('columnIndex is always less than totalColumns', () {
        final events = [
          event(
            id: 'a',
            startHour: 9,
            startMinute: 0,
            endHour: 10,
            endMinute: 30,
          ),
          event(
            id: 'b',
            startHour: 10,
            startMinute: 0,
            endHour: 11,
            endMinute: 0,
          ),
          event(
            id: 'c',
            startHour: 9,
            startMinute: 30,
            endHour: 10,
            endMinute: 30,
          ),
        ];
        final result = detectOverlapsAndAssignColumns(events);
        for (final r in result) {
          expect(r.columnIndex, lessThan(r.totalColumns));
          expect(r.columnIndex, greaterThanOrEqualTo(0));
        }
      });
    });

    group('totalColumns count correctness', () {
      test('no unnecessary columns for non-overlapping events', () {
        final events = [
          event(
            id: 'a',
            startHour: 8,
            startMinute: 0,
            endHour: 9,
            endMinute: 0,
          ),
          event(
            id: 'b',
            startHour: 10,
            startMinute: 0,
            endHour: 11,
            endMinute: 0,
          ),
          event(
            id: 'c',
            startHour: 12,
            startMinute: 0,
            endHour: 13,
            endMinute: 0,
          ),
        ];
        final result = detectOverlapsAndAssignColumns(events);
        for (final r in result) {
          expect(r.totalColumns, 1);
        }
      });

      test('totalColumns matches maximum concurrent events in group', () {
        // At 9:30, all three overlap
        final events = [
          event(
            id: 'a',
            startHour: 9,
            startMinute: 0,
            endHour: 11,
            endMinute: 0,
          ),
          event(
            id: 'b',
            startHour: 9,
            startMinute: 30,
            endHour: 10,
            endMinute: 30,
          ),
          event(
            id: 'c',
            startHour: 10,
            startMinute: 0,
            endHour: 11,
            endMinute: 30,
          ),
        ];
        final result = detectOverlapsAndAssignColumns(events);
        for (final r in result) {
          expect(r.totalColumns, 3);
        }
      });
    });

    group('various time slot durations', () {
      test('short 15-minute events', () {
        final events = [
          event(
            id: 'a',
            startHour: 9,
            startMinute: 0,
            endHour: 9,
            endMinute: 15,
          ),
          event(
            id: 'b',
            startHour: 9,
            startMinute: 10,
            endHour: 9,
            endMinute: 25,
          ),
        ];
        final result = detectOverlapsAndAssignColumns(events);
        expect(result.length, 2);
        expect(result[0].totalColumns, 2);
        expect(result[1].totalColumns, 2);
      });

      test('long multi-hour events', () {
        final events = [
          event(
            id: 'a',
            startHour: 8,
            startMinute: 0,
            endHour: 12,
            endMinute: 0,
          ),
          event(
            id: 'b',
            startHour: 10,
            startMinute: 0,
            endHour: 14,
            endMinute: 0,
          ),
        ];
        final result = detectOverlapsAndAssignColumns(events);
        expect(result.length, 2);
        expect(result[0].totalColumns, 2);
        expect(result[1].totalColumns, 2);
      });
    });
  });
}
