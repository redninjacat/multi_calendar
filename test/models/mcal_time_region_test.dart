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

    group('expandedForDate', () {
      test('non-recurring region on its own date returns itself', () {
        final region = MCalTimeRegion(
          id: 'lunch',
          startTime: DateTime(2026, 2, 14, 12, 0),
          endTime: DateTime(2026, 2, 14, 13, 0),
        );

        final expanded = region.expandedForDate(DateTime(2026, 2, 14));
        expect(expanded, same(region));
      });

      test('non-recurring region on a different date returns null', () {
        final region = MCalTimeRegion(
          id: 'lunch',
          startTime: DateTime(2026, 2, 14, 12, 0),
          endTime: DateTime(2026, 2, 14, 13, 0),
        );

        expect(region.expandedForDate(DateTime(2026, 2, 15)), isNull);
        expect(region.expandedForDate(DateTime(2026, 2, 13)), isNull);
      });

      test('daily recurring region applies to the anchor date', () {
        final region = MCalTimeRegion(
          id: 'after-hours',
          startTime: DateTime(2026, 1, 1, 18, 0),
          endTime: DateTime(2026, 1, 1, 22, 0),
          recurrenceRule: 'FREQ=DAILY',
          blockInteraction: true,
        );

        final expanded = region.expandedForDate(DateTime(2026, 1, 1));
        expect(expanded, isNotNull);
        expect(expanded!.startTime, DateTime(2026, 1, 1, 18, 0));
        expect(expanded.endTime, DateTime(2026, 1, 1, 22, 0));
        expect(expanded.blockInteraction, isTrue);
      });

      test('daily recurring region expands to a later date', () {
        final region = MCalTimeRegion(
          id: 'after-hours',
          startTime: DateTime(2026, 1, 1, 18, 0),
          endTime: DateTime(2026, 1, 1, 22, 0),
          recurrenceRule: 'FREQ=DAILY',
          blockInteraction: true,
          color: Colors.grey,
          text: 'After Hours',
          icon: Icons.block,
        );

        final expanded = region.expandedForDate(DateTime(2026, 2, 25));
        expect(expanded, isNotNull);
        expect(expanded!.startTime, DateTime(2026, 2, 25, 18, 0));
        expect(expanded.endTime, DateTime(2026, 2, 25, 22, 0));
        expect(expanded.blockInteraction, isTrue);
        expect(expanded.color, Colors.grey);
        expect(expanded.text, 'After Hours');
        expect(expanded.icon, Icons.block);
        // Expanded instance has no recurrence rule
        expect(expanded.recurrenceRule, isNull);
      });

      test('daily recurring region with COUNT does not apply beyond limit', () {
        // Anchored 2026-01-01, COUNT=3 → applies Jan 1, 2, 3 only
        final region = MCalTimeRegion(
          id: 'focus',
          startTime: DateTime(2026, 1, 1, 9, 0),
          endTime: DateTime(2026, 1, 1, 10, 0),
          recurrenceRule: 'FREQ=DAILY;COUNT=3',
        );

        expect(region.expandedForDate(DateTime(2026, 1, 1)), isNotNull);
        expect(region.expandedForDate(DateTime(2026, 1, 2)), isNotNull);
        expect(region.expandedForDate(DateTime(2026, 1, 3)), isNotNull);
        expect(region.expandedForDate(DateTime(2026, 1, 4)), isNull);
      });

      test('weekly recurring region applies only on matching weekday', () {
        // Anchor 2026-01-05 is a Monday; BYDAY=MO → every Monday
        final region = MCalTimeRegion(
          id: 'standup',
          startTime: DateTime(2026, 1, 5, 9, 0),
          endTime: DateTime(2026, 1, 5, 9, 30),
          recurrenceRule: 'FREQ=WEEKLY;BYDAY=MO',
        );

        // 2026-02-16 is a Monday
        final monday = region.expandedForDate(DateTime(2026, 2, 16));
        expect(monday, isNotNull);
        expect(monday!.startTime.weekday, DateTime.monday);

        // 2026-02-17 is a Tuesday
        expect(region.expandedForDate(DateTime(2026, 2, 17)), isNull);
        // 2026-02-15 is a Sunday
        expect(region.expandedForDate(DateTime(2026, 2, 15)), isNull);
      });

      test('date before anchor returns null for recurring region', () {
        final region = MCalTimeRegion(
          id: 'after-hours',
          startTime: DateTime(2026, 3, 1, 18, 0),
          endTime: DateTime(2026, 3, 1, 22, 0),
          recurrenceRule: 'FREQ=DAILY',
        );

        expect(region.expandedForDate(DateTime(2026, 2, 28)), isNull);
      });

      test(
          'expanded region overlaps correctly on the display date for '
          'drop-blocking validation', () {
        // Simulate the exact bug that was reported:
        // region anchored on Jan 1, drop attempted on Feb 25
        final afterHours = MCalTimeRegion(
          id: 'after-hours',
          startTime: DateTime(2026, 1, 1, 18, 0),
          endTime: DateTime(2026, 1, 1, 22, 0),
          recurrenceRule: 'FREQ=DAILY',
          blockInteraction: true,
        );

        final displayDate = DateTime(2026, 2, 25);
        final expanded = afterHours.expandedForDate(displayDate);
        expect(expanded, isNotNull,
            reason: 'Region should apply on Feb 25 via FREQ=DAILY');

        // A drop at 19:00–20:00 on Feb 25 should be blocked
        expect(
          expanded!.overlaps(
            DateTime(2026, 2, 25, 19, 0),
            DateTime(2026, 2, 25, 20, 0),
          ),
          isTrue,
          reason: 'Expanded region should block a 19:00–20:00 drop on Feb 25',
        );

        // A drop at 08:00–09:00 on Feb 25 should NOT be blocked
        expect(
          expanded.overlaps(
            DateTime(2026, 2, 25, 8, 0),
            DateTime(2026, 2, 25, 9, 0),
          ),
          isFalse,
          reason: 'Expanded region should not block a morning drop',
        );
      });

      test('invalid recurrence rule returns null gracefully', () {
        final region = MCalTimeRegion(
          id: 'bad-rule',
          startTime: DateTime(2026, 1, 1, 9, 0),
          endTime: DateTime(2026, 1, 1, 10, 0),
          recurrenceRule: 'FREQ=INVALID;GARBAGE',
        );

        expect(region.expandedForDate(DateTime(2026, 2, 1)), isNull);
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
