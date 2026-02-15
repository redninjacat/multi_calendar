import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  group('MCalTimeRegion', () {
    final testStart = DateTime(2026, 2, 14, 12, 0);
    final testEnd = DateTime(2026, 2, 14, 13, 0);

    group('constructor and properties', () {
      test('creates instance with required fields only', () {
        final region = MCalTimeRegion(
          id: 'region-1',
          startTime: testStart,
          endTime: testEnd,
        );

        expect(region.id, 'region-1');
        expect(region.startTime, testStart);
        expect(region.endTime, testEnd);
        expect(region.color, isNull);
        expect(region.text, isNull);
        expect(region.blockInteraction, isFalse);
        expect(region.recurrenceRule, isNull);
        expect(region.icon, isNull);
        expect(region.customData, isNull);
      });

      test('creates instance with all optional fields', () {
        final region = MCalTimeRegion(
          id: 'lunch',
          startTime: testStart,
          endTime: testEnd,
          color: Colors.amber.withValues(alpha: 0.3),
          text: 'Lunch Break',
          blockInteraction: true,
          recurrenceRule: 'FREQ=DAILY;COUNT=30',
          icon: Icons.restaurant,
          customData: {'priority': 'high'},
        );

        expect(region.id, 'lunch');
        expect(region.startTime, testStart);
        expect(region.endTime, testEnd);
        expect(region.color, Colors.amber.withValues(alpha: 0.3));
        expect(region.text, 'Lunch Break');
        expect(region.blockInteraction, isTrue);
        expect(region.recurrenceRule, 'FREQ=DAILY;COUNT=30');
        expect(region.icon, Icons.restaurant);
        expect(region.customData, {'priority': 'high'});
      });

      test('blockInteraction defaults to false', () {
        final region = MCalTimeRegion(
          id: 'visual-only',
          startTime: testStart,
          endTime: testEnd,
        );
        expect(region.blockInteraction, isFalse);
      });

      test('stores recurrence rule for recurring regions', () {
        final dailyRegion = MCalTimeRegion(
          id: 'focus-time',
          startTime: DateTime(2026, 2, 14, 9, 0),
          endTime: DateTime(2026, 2, 14, 10, 0),
          recurrenceRule: 'FREQ=DAILY;COUNT=30',
        );
        expect(dailyRegion.recurrenceRule, 'FREQ=DAILY;COUNT=30');

        final weeklyRegion = MCalTimeRegion(
          id: 'weekends',
          startTime: DateTime(2026, 2, 14, 0, 0),
          endTime: DateTime(2026, 2, 14, 23, 59),
          recurrenceRule: 'FREQ=WEEKLY;BYDAY=SA,SU',
        );
        expect(weeklyRegion.recurrenceRule, 'FREQ=WEEKLY;BYDAY=SA,SU');
      });
    });

    group('contains', () {
      test('returns true for time inside region', () {
        final region = MCalTimeRegion(
          id: 'lunch',
          startTime: DateTime(2026, 2, 14, 12, 0),
          endTime: DateTime(2026, 2, 14, 13, 0),
        );

        expect(region.contains(DateTime(2026, 2, 14, 12, 0)), isTrue);
        expect(region.contains(DateTime(2026, 2, 14, 12, 30)), isTrue);
        expect(region.contains(DateTime(2026, 2, 14, 12, 59)), isTrue);
      });

      test('returns false for time at exclusive end boundary', () {
        final region = MCalTimeRegion(
          id: 'lunch',
          startTime: DateTime(2026, 2, 14, 12, 0),
          endTime: DateTime(2026, 2, 14, 13, 0),
        );

        expect(region.contains(DateTime(2026, 2, 14, 13, 0)), isFalse);
      });

      test('returns false for time before region', () {
        final region = MCalTimeRegion(
          id: 'lunch',
          startTime: DateTime(2026, 2, 14, 12, 0),
          endTime: DateTime(2026, 2, 14, 13, 0),
        );

        expect(region.contains(DateTime(2026, 2, 14, 11, 59)), isFalse);
        expect(region.contains(DateTime(2026, 2, 14, 10, 0)), isFalse);
      });

      test('returns false for time after region', () {
        final region = MCalTimeRegion(
          id: 'lunch',
          startTime: DateTime(2026, 2, 14, 12, 0),
          endTime: DateTime(2026, 2, 14, 13, 0),
        );

        expect(region.contains(DateTime(2026, 2, 14, 13, 1)), isFalse);
        expect(region.contains(DateTime(2026, 2, 14, 14, 0)), isFalse);
      });

      test('handles single-minute region', () {
        final region = MCalTimeRegion(
          id: 'instant',
          startTime: DateTime(2026, 2, 14, 12, 0),
          endTime: DateTime(2026, 2, 14, 12, 1),
        );

        expect(region.contains(DateTime(2026, 2, 14, 12, 0)), isTrue);
        expect(region.contains(DateTime(2026, 2, 14, 12, 0, 30)), isTrue);
        expect(region.contains(DateTime(2026, 2, 14, 12, 1)), isFalse);
      });
    });

    group('overlaps', () {
      test('returns true when ranges overlap', () {
        final region = MCalTimeRegion(
          id: 'lunch',
          startTime: DateTime(2026, 2, 14, 12, 0),
          endTime: DateTime(2026, 2, 14, 13, 0),
        );

        // Meeting 11:30-12:30 overlaps
        expect(
          region.overlaps(
            DateTime(2026, 2, 14, 11, 30),
            DateTime(2026, 2, 14, 12, 30),
          ),
          isTrue,
        );

        // Meeting 12:30-13:30 overlaps
        expect(
          region.overlaps(
            DateTime(2026, 2, 14, 12, 30),
            DateTime(2026, 2, 14, 13, 30),
          ),
          isTrue,
        );

        // Meeting 12:15-12:45 fully inside
        expect(
          region.overlaps(
            DateTime(2026, 2, 14, 12, 15),
            DateTime(2026, 2, 14, 12, 45),
          ),
          isTrue,
        );

        // Meeting 11:00-14:00 contains region
        expect(
          region.overlaps(
            DateTime(2026, 2, 14, 11, 0),
            DateTime(2026, 2, 14, 14, 0),
          ),
          isTrue,
        );
      });

      test('returns false when ranges do not overlap', () {
        final region = MCalTimeRegion(
          id: 'lunch',
          startTime: DateTime(2026, 2, 14, 12, 0),
          endTime: DateTime(2026, 2, 14, 13, 0),
        );

        // Meeting 10:00-11:00 ends before region
        expect(
          region.overlaps(
            DateTime(2026, 2, 14, 10, 0),
            DateTime(2026, 2, 14, 11, 0),
          ),
          isFalse,
        );

        // Meeting 13:00-14:00 starts when region ends
        expect(
          region.overlaps(
            DateTime(2026, 2, 14, 13, 0),
            DateTime(2026, 2, 14, 14, 0),
          ),
          isFalse,
        );

        // Meeting 14:00-15:00 after region
        expect(
          region.overlaps(
            DateTime(2026, 2, 14, 14, 0),
            DateTime(2026, 2, 14, 15, 0),
          ),
          isFalse,
        );
      });

      test('handles adjacent ranges (no overlap)', () {
        final region = MCalTimeRegion(
          id: 'slot',
          startTime: DateTime(2026, 2, 14, 9, 0),
          endTime: DateTime(2026, 2, 14, 10, 0),
        );

        // Range ends exactly when region starts
        expect(
          region.overlaps(
            DateTime(2026, 2, 14, 8, 0),
            DateTime(2026, 2, 14, 9, 0),
          ),
          isFalse,
        );

        // Range starts exactly when region ends
        expect(
          region.overlaps(
            DateTime(2026, 2, 14, 10, 0),
            DateTime(2026, 2, 14, 11, 0),
          ),
          isFalse,
        );
      });

      test('handles zero-duration range', () {
        final region = MCalTimeRegion(
          id: 'lunch',
          startTime: DateTime(2026, 2, 14, 12, 0),
          endTime: DateTime(2026, 2, 14, 13, 0),
        );

        // Point at 12:30 - overlaps (point is inside)
        expect(
          region.overlaps(
            DateTime(2026, 2, 14, 12, 30),
            DateTime(2026, 2, 14, 12, 30),
          ),
          isTrue,
        );

        // Point at 13:00 - no overlap (at exclusive end)
        expect(
          region.overlaps(
            DateTime(2026, 2, 14, 13, 0),
            DateTime(2026, 2, 14, 13, 0),
          ),
          isFalse,
        );
      });
    });

    group('edge cases and validation', () {
      test('handles multi-day region', () {
        final region = MCalTimeRegion(
          id: 'multi-day',
          startTime: DateTime(2026, 2, 14, 18, 0),
          endTime: DateTime(2026, 2, 15, 9, 0),
        );

        expect(region.contains(DateTime(2026, 2, 14, 18, 0)), isTrue);
        expect(region.contains(DateTime(2026, 2, 14, 23, 59)), isTrue);
        expect(region.contains(DateTime(2026, 2, 15, 0, 0)), isTrue);
        expect(region.contains(DateTime(2026, 2, 15, 8, 59)), isTrue);
        expect(region.contains(DateTime(2026, 2, 15, 9, 0)), isFalse);
      });

      test('overlaps works across date boundary', () {
        final region = MCalTimeRegion(
          id: 'overnight',
          startTime: DateTime(2026, 2, 14, 22, 0),
          endTime: DateTime(2026, 2, 15, 6, 0),
        );

        // Meeting 23:00-01:00 overlaps
        expect(
          region.overlaps(
            DateTime(2026, 2, 14, 23, 0),
            DateTime(2026, 2, 15, 1, 0),
          ),
          isTrue,
        );

        // Meeting 20:00-23:00 overlaps
        expect(
          region.overlaps(
            DateTime(2026, 2, 14, 20, 0),
            DateTime(2026, 2, 14, 23, 0),
          ),
          isTrue,
        );
      });
    });
  });
}
