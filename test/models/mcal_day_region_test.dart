import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  group('MCalDayRegion', () {
    // -------------------------------------------------------------------------
    // Constructor / properties
    // -------------------------------------------------------------------------

    group('constructor and properties', () {
      test('creates instance with required fields only', () {
        final region = MCalDayRegion(
          id: 'region-1',
          date: DateTime(2026, 6, 15),
        );

        expect(region.id, 'region-1');
        expect(region.date, DateTime(2026, 6, 15));
        expect(region.color, isNull);
        expect(region.text, isNull);
        expect(region.icon, isNull);
        expect(region.blockInteraction, isFalse);
        expect(region.recurrenceRule, isNull);
        expect(region.customData, isNull);
      });

      test('creates instance with all optional fields', () {
        final region = MCalDayRegion(
          id: 'holiday',
          date: DateTime(2026, 1, 1),
          color: Colors.red.withValues(alpha: 0.2),
          text: 'New Year',
          icon: Icons.celebration,
          blockInteraction: true,
          recurrenceRule: 'FREQ=YEARLY;BYMONTH=1;BYMONTHDAY=1',
          customData: {'type': 'public_holiday'},
        );

        expect(region.id, 'holiday');
        expect(region.color, Colors.red.withValues(alpha: 0.2));
        expect(region.text, 'New Year');
        expect(region.icon, Icons.celebration);
        expect(region.blockInteraction, isTrue);
        expect(region.recurrenceRule, 'FREQ=YEARLY;BYMONTH=1;BYMONTHDAY=1');
        expect(region.customData, {'type': 'public_holiday'});
      });

      test('blockInteraction defaults to false', () {
        final region = MCalDayRegion(
          id: 'visual-only',
          date: DateTime(2026, 6, 15),
        );
        expect(region.blockInteraction, isFalse);
      });

      test('customData map is preserved as-is', () {
        final data = {'key1': 'value1', 'key2': 42, 'key3': true};
        final region = MCalDayRegion(
          id: 'data-region',
          date: DateTime(2026, 6, 15),
          customData: data,
        );
        expect(region.customData, equals(data));
        expect(region.customData!['key2'], 42);
      });
    });

    // -------------------------------------------------------------------------
    // appliesTo — single occurrence (no recurrence rule)
    // -------------------------------------------------------------------------

    group('appliesTo — single occurrence', () {
      final anchor = DateTime(2026, 6, 15);
      late MCalDayRegion region;

      setUp(() {
        region = MCalDayRegion(id: 'single', date: anchor);
      });

      test('returns true for the exact anchor date', () {
        expect(region.appliesTo(DateTime(2026, 6, 15)), isTrue);
      });

      test('returns false for the day before anchor', () {
        expect(region.appliesTo(DateTime(2026, 6, 14)), isFalse);
      });

      test('returns false for the day after anchor', () {
        expect(region.appliesTo(DateTime(2026, 6, 16)), isFalse);
      });

      test('ignores time components — matches even with non-zero time', () {
        expect(region.appliesTo(DateTime(2026, 6, 15, 23, 59, 59)), isTrue);
      });

      test('returns false for a completely different date', () {
        expect(region.appliesTo(DateTime(2025, 6, 15)), isFalse);
      });
    });

    // -------------------------------------------------------------------------
    // appliesTo — FREQ=WEEKLY
    // -------------------------------------------------------------------------

    group('appliesTo — FREQ=WEEKLY', () {
      test('SA,SU matches every Saturday and Sunday after anchor', () {
        final region = MCalDayRegion(
          id: 'weekends',
          date: DateTime(2026, 1, 3), // Saturday anchor
          recurrenceRule: 'FREQ=WEEKLY;BYDAY=SA,SU',
        );

        // Saturdays
        expect(region.appliesTo(DateTime(2026, 1, 3)), isTrue); // anchor
        expect(region.appliesTo(DateTime(2026, 1, 10)), isTrue);
        expect(region.appliesTo(DateTime(2026, 6, 20)), isTrue); // June 20
        // Sundays
        expect(region.appliesTo(DateTime(2026, 1, 4)), isTrue);
        expect(region.appliesTo(DateTime(2026, 1, 11)), isTrue);
      });

      test('SA,SU does not match weekdays', () {
        final region = MCalDayRegion(
          id: 'weekends',
          date: DateTime(2026, 1, 3),
          recurrenceRule: 'FREQ=WEEKLY;BYDAY=SA,SU',
        );

        expect(region.appliesTo(DateTime(2026, 1, 5)), isFalse); // Monday
        expect(region.appliesTo(DateTime(2026, 1, 6)), isFalse); // Tuesday
        expect(region.appliesTo(DateTime(2026, 1, 7)), isFalse); // Wednesday
        expect(region.appliesTo(DateTime(2026, 1, 8)), isFalse); // Thursday
        expect(region.appliesTo(DateTime(2026, 1, 9)), isFalse); // Friday
      });

      test('does not match dates before the anchor', () {
        final region = MCalDayRegion(
          id: 'weekends',
          date: DateTime(2026, 1, 10), // Saturday anchor
          recurrenceRule: 'FREQ=WEEKLY;BYDAY=SA,SU',
        );

        // Jan 3 is a Saturday but before the anchor
        expect(region.appliesTo(DateTime(2026, 1, 3)), isFalse);
        expect(region.appliesTo(DateTime(2026, 1, 4)), isFalse); // Sunday before
      });

      test('BYDAY=MO matches every Monday', () {
        final region = MCalDayRegion(
          id: 'mondays',
          date: DateTime(2026, 1, 5), // Monday anchor
          recurrenceRule: 'FREQ=WEEKLY;BYDAY=MO',
        );

        expect(region.appliesTo(DateTime(2026, 1, 5)), isTrue);
        expect(region.appliesTo(DateTime(2026, 1, 12)), isTrue);
        expect(region.appliesTo(DateTime(2026, 1, 6)), isFalse); // Tuesday
      });

      test('UNTIL stops occurrences after the UNTIL date', () {
        final region = MCalDayRegion(
          id: 'limited-weekends',
          date: DateTime(2026, 1, 3),
          recurrenceRule: 'FREQ=WEEKLY;BYDAY=SA,SU;UNTIL=20260110',
        );

        expect(region.appliesTo(DateTime(2026, 1, 3)), isTrue); // anchor
        expect(region.appliesTo(DateTime(2026, 1, 4)), isTrue); // Sunday within
        expect(region.appliesTo(DateTime(2026, 1, 10)), isTrue); // last Saturday (= UNTIL)
        expect(region.appliesTo(DateTime(2026, 1, 17)), isFalse); // past UNTIL
      });

      test('COUNT=4 stops after 4 occurrences', () {
        // Anchor: Monday Jan 5, 2026; BYDAY=SA; COUNT=4 means 4 Saturdays
        // Jan 10, Jan 17, Jan 24, Jan 31 — Feb 7 should be false
        final region = MCalDayRegion(
          id: 'four-saturdays',
          date: DateTime(2026, 1, 3), // Saturday
          recurrenceRule: 'FREQ=WEEKLY;BYDAY=SA;COUNT=4',
        );

        expect(region.appliesTo(DateTime(2026, 1, 3)), isTrue); // 1st
        expect(region.appliesTo(DateTime(2026, 1, 10)), isTrue); // 2nd
        expect(region.appliesTo(DateTime(2026, 1, 17)), isTrue); // 3rd
        expect(region.appliesTo(DateTime(2026, 1, 24)), isTrue); // 4th
        expect(region.appliesTo(DateTime(2026, 1, 31)), isFalse); // 5th — stop
      });

      test('INTERVAL=2;BYDAY=MO matches every other Monday', () {
        final region = MCalDayRegion(
          id: 'biweekly-monday',
          date: DateTime(2026, 1, 5), // Monday
          recurrenceRule: 'FREQ=WEEKLY;BYDAY=MO;INTERVAL=2',
        );

        expect(region.appliesTo(DateTime(2026, 1, 5)), isTrue); // week 0
        expect(region.appliesTo(DateTime(2026, 1, 12)), isFalse); // week 1 — skip
        expect(region.appliesTo(DateTime(2026, 1, 19)), isTrue); // week 2
        expect(region.appliesTo(DateTime(2026, 1, 26)), isFalse); // week 3 — skip
        expect(region.appliesTo(DateTime(2026, 2, 2)), isTrue); // week 4
      });
    });

    // -------------------------------------------------------------------------
    // appliesTo — FREQ=DAILY
    // -------------------------------------------------------------------------

    group('appliesTo — FREQ=DAILY', () {
      test('matches every day on and after anchor', () {
        final region = MCalDayRegion(
          id: 'daily',
          date: DateTime(2026, 6, 1),
          recurrenceRule: 'FREQ=DAILY',
        );

        expect(region.appliesTo(DateTime(2026, 6, 1)), isTrue);
        expect(region.appliesTo(DateTime(2026, 6, 2)), isTrue);
        expect(region.appliesTo(DateTime(2026, 12, 31)), isTrue);
        expect(region.appliesTo(DateTime(2026, 5, 31)), isFalse); // before anchor
      });

      test('COUNT=3 matches exactly 3 days; 4th is false', () {
        final region = MCalDayRegion(
          id: 'three-days',
          date: DateTime(2026, 6, 1),
          recurrenceRule: 'FREQ=DAILY;COUNT=3',
        );

        expect(region.appliesTo(DateTime(2026, 6, 1)), isTrue); // day 0
        expect(region.appliesTo(DateTime(2026, 6, 2)), isTrue); // day 1
        expect(region.appliesTo(DateTime(2026, 6, 3)), isTrue); // day 2
        expect(region.appliesTo(DateTime(2026, 6, 4)), isFalse); // day 3 — stop
      });

      test('INTERVAL=2 matches every other day', () {
        final region = MCalDayRegion(
          id: 'every-other',
          date: DateTime(2026, 6, 1),
          recurrenceRule: 'FREQ=DAILY;INTERVAL=2',
        );

        expect(region.appliesTo(DateTime(2026, 6, 1)), isTrue);
        expect(region.appliesTo(DateTime(2026, 6, 2)), isFalse);
        expect(region.appliesTo(DateTime(2026, 6, 3)), isTrue);
        expect(region.appliesTo(DateTime(2026, 6, 4)), isFalse);
      });

      test('UNTIL stops on the UNTIL date (inclusive)', () {
        final region = MCalDayRegion(
          id: 'daily-until',
          date: DateTime(2026, 6, 1),
          recurrenceRule: 'FREQ=DAILY;UNTIL=20260605',
        );

        expect(region.appliesTo(DateTime(2026, 6, 5)), isTrue);
        expect(region.appliesTo(DateTime(2026, 6, 6)), isFalse);
      });
    });

    // -------------------------------------------------------------------------
    // appliesTo — FREQ=MONTHLY
    // -------------------------------------------------------------------------

    group('appliesTo — FREQ=MONTHLY', () {
      test('BYMONTHDAY=15 matches the 15th of each month from anchor', () {
        final region = MCalDayRegion(
          id: 'monthly-15',
          date: DateTime(2026, 1, 15),
          recurrenceRule: 'FREQ=MONTHLY;BYMONTHDAY=15',
        );

        expect(region.appliesTo(DateTime(2026, 1, 15)), isTrue);
        expect(region.appliesTo(DateTime(2026, 2, 15)), isTrue);
        expect(region.appliesTo(DateTime(2026, 12, 15)), isTrue);
        expect(region.appliesTo(DateTime(2025, 12, 15)), isFalse); // before anchor
      });

      test('BYMONTHDAY=15 does not match the 14th or 16th', () {
        final region = MCalDayRegion(
          id: 'monthly-15',
          date: DateTime(2026, 1, 15),
          recurrenceRule: 'FREQ=MONTHLY;BYMONTHDAY=15',
        );

        expect(region.appliesTo(DateTime(2026, 2, 14)), isFalse);
        expect(region.appliesTo(DateTime(2026, 2, 16)), isFalse);
      });

      test('BYMONTHDAY=31 only matches months that have 31 days', () {
        final region = MCalDayRegion(
          id: 'monthly-31',
          date: DateTime(2026, 1, 31),
          recurrenceRule: 'FREQ=MONTHLY;BYMONTHDAY=31',
        );

        expect(region.appliesTo(DateTime(2026, 1, 31)), isTrue);
        expect(region.appliesTo(DateTime(2026, 3, 31)), isTrue);
        expect(region.appliesTo(DateTime(2026, 5, 31)), isTrue);
        // February never has a 31st day
        expect(region.appliesTo(DateTime(2026, 2, 28)), isFalse);
        expect(region.appliesTo(DateTime(2026, 2, 1)), isFalse);
      });

      test('COUNT=3 stops after 3 occurrences', () {
        final region = MCalDayRegion(
          id: 'monthly-count',
          date: DateTime(2026, 1, 15),
          recurrenceRule: 'FREQ=MONTHLY;BYMONTHDAY=15;COUNT=3',
        );

        expect(region.appliesTo(DateTime(2026, 1, 15)), isTrue); // 1st
        expect(region.appliesTo(DateTime(2026, 2, 15)), isTrue); // 2nd
        expect(region.appliesTo(DateTime(2026, 3, 15)), isTrue); // 3rd
        expect(region.appliesTo(DateTime(2026, 4, 15)), isFalse); // 4th — stop
      });
    });

    // -------------------------------------------------------------------------
    // appliesTo — FREQ=YEARLY
    // -------------------------------------------------------------------------

    group('appliesTo — FREQ=YEARLY', () {
      test('BYMONTH=1;BYMONTHDAY=1 matches Jan 1 each year', () {
        final region = MCalDayRegion(
          id: 'new-year',
          date: DateTime(2026, 1, 1),
          recurrenceRule: 'FREQ=YEARLY;BYMONTH=1;BYMONTHDAY=1',
        );

        expect(region.appliesTo(DateTime(2026, 1, 1)), isTrue);
        expect(region.appliesTo(DateTime(2027, 1, 1)), isTrue);
        expect(region.appliesTo(DateTime(2030, 1, 1)), isTrue);
        expect(region.appliesTo(DateTime(2025, 1, 1)), isFalse); // before anchor
      });

      test('BYMONTH=1;BYMONTHDAY=1 does not match Jan 2 or Feb 1', () {
        final region = MCalDayRegion(
          id: 'new-year',
          date: DateTime(2026, 1, 1),
          recurrenceRule: 'FREQ=YEARLY;BYMONTH=1;BYMONTHDAY=1',
        );

        expect(region.appliesTo(DateTime(2026, 1, 2)), isFalse);
        expect(region.appliesTo(DateTime(2026, 2, 1)), isFalse);
      });

      test('BYMONTH=12;BYMONTHDAY=25;COUNT=2 stops after 2 years', () {
        final region = MCalDayRegion(
          id: 'christmas',
          date: DateTime(2026, 12, 25),
          recurrenceRule: 'FREQ=YEARLY;BYMONTH=12;BYMONTHDAY=25;COUNT=2',
        );

        expect(region.appliesTo(DateTime(2026, 12, 25)), isTrue); // 1st
        expect(region.appliesTo(DateTime(2027, 12, 25)), isTrue); // 2nd
        expect(region.appliesTo(DateTime(2028, 12, 25)), isFalse); // 3rd — stop
      });

      test('matches correct date across year boundaries', () {
        final region = MCalDayRegion(
          id: 'independence-day',
          date: DateTime(2026, 7, 4),
          recurrenceRule: 'FREQ=YEARLY;BYMONTH=7;BYMONTHDAY=4',
        );

        expect(region.appliesTo(DateTime(2026, 7, 4)), isTrue);
        expect(region.appliesTo(DateTime(2026, 7, 5)), isFalse);
        expect(region.appliesTo(DateTime(2026, 6, 4)), isFalse);
        expect(region.appliesTo(DateTime(2027, 7, 4)), isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // Unsupported / malformed RRULE
    // -------------------------------------------------------------------------

    group('unsupported / malformed recurrence rules', () {
      test('unsupported FREQ value returns false without throwing', () {
        final region = MCalDayRegion(
          id: 'hourly',
          date: DateTime(2026, 6, 15),
          recurrenceRule: 'FREQ=HOURLY',
        );

        expect(() => region.appliesTo(DateTime(2026, 6, 15)), returnsNormally);
        expect(region.appliesTo(DateTime(2026, 6, 15)), isFalse);
      });

      test('malformed UNTIL value causes the rule to be rejected safely', () {
        final region = MCalDayRegion(
          id: 'bad-until',
          date: DateTime(2026, 1, 1),
          recurrenceRule: 'FREQ=DAILY;UNTIL=NOTADATE',
        );

        // teno_rrule cannot parse a malformed UNTIL value; the rule is rejected
        // and appliesTo returns false rather than throwing.
        expect(() => region.appliesTo(DateTime(2026, 6, 15)), returnsNormally);
        expect(region.appliesTo(DateTime(2026, 6, 15)), isFalse);
      });

      test('empty recurrenceRule string returns false', () {
        final region = MCalDayRegion(
          id: 'empty-rule',
          date: DateTime(2026, 6, 15),
          recurrenceRule: '',
        );

        expect(region.appliesTo(DateTime(2026, 6, 15)), isFalse);
      });

      test('rule with unknown keys is tolerated; known parts still parsed', () {
        final region = MCalDayRegion(
          id: 'extra-keys',
          date: DateTime(2026, 1, 1),
          recurrenceRule: 'FREQ=YEARLY;BYMONTH=1;BYMONTHDAY=1;WKST=MO',
        );

        // Unknown WKST key should be silently ignored; YEARLY rule still works
        expect(region.appliesTo(DateTime(2026, 1, 1)), isTrue);
        expect(region.appliesTo(DateTime(2027, 1, 1)), isTrue);
      });
    });
  });

  // ---------------------------------------------------------------------------
  // MCalDayRegionContext
  // ---------------------------------------------------------------------------

  group('MCalDayRegionContext', () {
    test('stores all fields correctly', () {
      final region = MCalDayRegion(
        id: 'ctx-region',
        date: DateTime(2026, 6, 15),
        color: Colors.blue,
      );
      final context = MCalDayRegionContext(
        region: region,
        date: DateTime(2026, 6, 15),
        isCurrentMonth: true,
        isToday: false,
      );

      expect(context.region, same(region));
      expect(context.date, DateTime(2026, 6, 15));
      expect(context.isCurrentMonth, isTrue);
      expect(context.isToday, isFalse);
    });

    test('isToday can be true', () {
      final region = MCalDayRegion(id: 'today', date: DateTime.now());
      final context = MCalDayRegionContext(
        region: region,
        date: DateTime.now(),
        isCurrentMonth: true,
        isToday: true,
      );

      expect(context.isToday, isTrue);
    });

    test('isCurrentMonth can be false for overflow cells', () {
      final region = MCalDayRegion(
        id: 'overflow',
        date: DateTime(2026, 5, 31),
      );
      final context = MCalDayRegionContext(
        region: region,
        date: DateTime(2026, 5, 31),
        isCurrentMonth: false,
        isToday: false,
      );

      expect(context.isCurrentMonth, isFalse);
    });
  });
}
