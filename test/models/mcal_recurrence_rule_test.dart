import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  group('MCalFrequency', () {
    test('has all 4 enum values', () {
      expect(MCalFrequency.values, hasLength(4));
      expect(MCalFrequency.values, contains(MCalFrequency.daily));
      expect(MCalFrequency.values, contains(MCalFrequency.weekly));
      expect(MCalFrequency.values, contains(MCalFrequency.monthly));
      expect(MCalFrequency.values, contains(MCalFrequency.yearly));
    });
  });

  group('MCalWeekDay', () {
    test('constructs with positional args', () {
      final wd = MCalWeekDay(DateTime.monday, 2);
      expect(wd.dayOfWeek, DateTime.monday);
      expect(wd.occurrence, 2);
    });

    test('constructs with dayOfWeek only (occurrence is null)', () {
      final wd = MCalWeekDay(DateTime.friday);
      expect(wd.dayOfWeek, DateTime.friday);
      expect(wd.occurrence, isNull);
    });

    test('.every() convenience constructor sets occurrence to null', () {
      final wd = MCalWeekDay.every(DateTime.tuesday);
      expect(wd.dayOfWeek, DateTime.tuesday);
      expect(wd.occurrence, isNull);
    });

    test('.nth() convenience constructor sets occurrence', () {
      final wd = MCalWeekDay.nth(DateTime.monday, 1);
      expect(wd.dayOfWeek, DateTime.monday);
      expect(wd.occurrence, 1);
    });

    test('.nth() with negative occurrence', () {
      final wd = MCalWeekDay.nth(DateTime.friday, -1);
      expect(wd.dayOfWeek, DateTime.friday);
      expect(wd.occurrence, -1);
    });

    test('copyWith replaces dayOfWeek', () {
      final original = MCalWeekDay.every(DateTime.monday);
      final copied = original.copyWith(dayOfWeek: DateTime.wednesday);
      expect(copied.dayOfWeek, DateTime.wednesday);
      expect(copied.occurrence, isNull);
    });

    test('copyWith replaces occurrence', () {
      final original = MCalWeekDay.nth(DateTime.monday, 1);
      final copied = original.copyWith(occurrence: () => 3);
      expect(copied.dayOfWeek, DateTime.monday);
      expect(copied.occurrence, 3);
    });

    test('copyWith can set occurrence to null', () {
      final original = MCalWeekDay.nth(DateTime.monday, 1);
      final copied = original.copyWith(occurrence: () => null);
      expect(copied.occurrence, isNull);
    });

    test('copyWith with no args returns equal instance', () {
      final original = MCalWeekDay.nth(DateTime.tuesday, 2);
      final copied = original.copyWith();
      expect(copied, equals(original));
    });

    test('== returns true for equal instances', () {
      final a = MCalWeekDay.every(DateTime.tuesday);
      final b = MCalWeekDay.every(DateTime.tuesday);
      expect(a, equals(b));
    });

    test('== returns true for equal instances with occurrence', () {
      final a = MCalWeekDay.nth(DateTime.monday, 1);
      final b = MCalWeekDay.nth(DateTime.monday, 1);
      expect(a, equals(b));
    });

    test('== returns false for different dayOfWeek', () {
      final a = MCalWeekDay.every(DateTime.monday);
      final b = MCalWeekDay.every(DateTime.tuesday);
      expect(a, isNot(equals(b)));
    });

    test('== returns false for different occurrence', () {
      final a = MCalWeekDay.nth(DateTime.monday, 1);
      final b = MCalWeekDay.nth(DateTime.monday, 2);
      expect(a, isNot(equals(b)));
    });

    test('== returns false when one has occurrence and other does not', () {
      final a = MCalWeekDay.every(DateTime.monday);
      final b = MCalWeekDay.nth(DateTime.monday, 1);
      expect(a, isNot(equals(b)));
    });

    test('hashCode is equal for equal instances', () {
      final a = MCalWeekDay.every(DateTime.wednesday);
      final b = MCalWeekDay.every(DateTime.wednesday);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('hashCode differs for different instances', () {
      final a = MCalWeekDay.every(DateTime.monday);
      final b = MCalWeekDay.every(DateTime.friday);
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });

    test('toString contains dayOfWeek and occurrence', () {
      final wd = MCalWeekDay.nth(DateTime.monday, 1);
      final str = wd.toString();
      expect(str, contains('dayOfWeek: ${DateTime.monday}'));
      expect(str, contains('occurrence: 1'));
    });

    test('toString with null occurrence', () {
      final wd = MCalWeekDay.every(DateTime.tuesday);
      final str = wd.toString();
      expect(str, contains('dayOfWeek: ${DateTime.tuesday}'));
      expect(str, contains('occurrence: null'));
    });
  });

  group('MCalRecurrenceRule', () {
    test('basic construction with defaults', () {
      final rule = MCalRecurrenceRule(frequency: MCalFrequency.daily);
      expect(rule.frequency, MCalFrequency.daily);
      expect(rule.interval, 1);
      expect(rule.count, isNull);
      expect(rule.until, isNull);
      expect(rule.byWeekDays, isNull);
      expect(rule.byMonthDays, isNull);
      expect(rule.byMonths, isNull);
      expect(rule.bySetPositions, isNull);
      expect(rule.weekStart, DateTime.monday);
    });

    test('construction with all fields', () {
      final until = DateTime(2025, 12, 31);
      final rule = MCalRecurrenceRule(
        frequency: MCalFrequency.weekly,
        interval: 2,
        until: until,
        byWeekDays: {
          MCalWeekDay.every(DateTime.tuesday),
          MCalWeekDay.every(DateTime.thursday),
        },
        weekStart: DateTime.sunday,
      );
      expect(rule.frequency, MCalFrequency.weekly);
      expect(rule.interval, 2);
      expect(rule.until, until);
      expect(rule.byWeekDays, hasLength(2));
      expect(rule.weekStart, DateTime.sunday);
    });

    test('validation: count and until together throws ArgumentError', () {
      expect(
        () => MCalRecurrenceRule(
          frequency: MCalFrequency.daily,
          count: 5,
          until: DateTime(2025, 12, 31),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('validation: interval < 1 throws ArgumentError', () {
      expect(
        () => MCalRecurrenceRule(
          frequency: MCalFrequency.daily,
          interval: 0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('validation: negative interval throws ArgumentError', () {
      expect(
        () => MCalRecurrenceRule(
          frequency: MCalFrequency.daily,
          interval: -1,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('copyWith replaces frequency', () {
      final original = MCalRecurrenceRule(frequency: MCalFrequency.daily);
      final copied = original.copyWith(frequency: MCalFrequency.weekly);
      expect(copied.frequency, MCalFrequency.weekly);
      expect(copied.interval, 1);
    });

    test('copyWith replaces interval', () {
      final original = MCalRecurrenceRule(frequency: MCalFrequency.daily);
      final copied = original.copyWith(interval: 3);
      expect(copied.interval, 3);
    });

    test('copyWith can set count to null', () {
      final original = MCalRecurrenceRule(
        frequency: MCalFrequency.daily,
        count: 10,
      );
      final copied = original.copyWith(count: () => null);
      expect(copied.count, isNull);
    });

    test('copyWith can set until', () {
      final original = MCalRecurrenceRule(frequency: MCalFrequency.daily);
      final untilDate = DateTime(2025, 6, 1);
      final copied = original.copyWith(until: () => untilDate);
      expect(copied.until, untilDate);
    });

    test('copyWith with no args returns equal instance', () {
      final original = MCalRecurrenceRule(
        frequency: MCalFrequency.weekly,
        interval: 2,
        byWeekDays: {MCalWeekDay.every(DateTime.monday)},
      );
      final copied = original.copyWith();
      expect(copied, equals(original));
    });

    test('== returns true for equal instances', () {
      final a = MCalRecurrenceRule(
        frequency: MCalFrequency.weekly,
        interval: 2,
        byWeekDays: {
          MCalWeekDay.every(DateTime.tuesday),
          MCalWeekDay.every(DateTime.thursday),
        },
      );
      final b = MCalRecurrenceRule(
        frequency: MCalFrequency.weekly,
        interval: 2,
        byWeekDays: {
          MCalWeekDay.every(DateTime.tuesday),
          MCalWeekDay.every(DateTime.thursday),
        },
      );
      expect(a, equals(b));
    });

    test('== returns false for different frequency', () {
      final a = MCalRecurrenceRule(frequency: MCalFrequency.daily);
      final b = MCalRecurrenceRule(frequency: MCalFrequency.weekly);
      expect(a, isNot(equals(b)));
    });

    test('== returns false for different interval', () {
      final a = MCalRecurrenceRule(
        frequency: MCalFrequency.daily,
        interval: 1,
      );
      final b = MCalRecurrenceRule(
        frequency: MCalFrequency.daily,
        interval: 2,
      );
      expect(a, isNot(equals(b)));
    });

    test('== returns false for different byWeekDays', () {
      final a = MCalRecurrenceRule(
        frequency: MCalFrequency.weekly,
        byWeekDays: {MCalWeekDay.every(DateTime.monday)},
      );
      final b = MCalRecurrenceRule(
        frequency: MCalFrequency.weekly,
        byWeekDays: {MCalWeekDay.every(DateTime.friday)},
      );
      expect(a, isNot(equals(b)));
    });

    test('hashCode is equal for equal instances', () {
      final a = MCalRecurrenceRule(
        frequency: MCalFrequency.daily,
        interval: 2,
      );
      final b = MCalRecurrenceRule(
        frequency: MCalFrequency.daily,
        interval: 2,
      );
      expect(a.hashCode, equals(b.hashCode));
    });

    test('hashCode differs for different instances', () {
      final a = MCalRecurrenceRule(frequency: MCalFrequency.daily);
      final b = MCalRecurrenceRule(frequency: MCalFrequency.weekly);
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });

    group('fromRruleString', () {
      test('parses WEEKLY rule with BYDAY', () {
        final rule = MCalRecurrenceRule.fromRruleString(
          'RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH',
        );
        expect(rule.frequency, MCalFrequency.weekly);
        expect(rule.interval, 2);
        expect(rule.byWeekDays, isNotNull);
        expect(rule.byWeekDays, hasLength(2));
        final days =
            rule.byWeekDays!.map((wd) => wd.dayOfWeek).toSet();
        expect(days, contains(DateTime.tuesday));
        expect(days, contains(DateTime.thursday));
      });

      test('parses DAILY rule', () {
        final rule = MCalRecurrenceRule.fromRruleString(
          'RRULE:FREQ=DAILY;INTERVAL=1',
        );
        expect(rule.frequency, MCalFrequency.daily);
        expect(rule.interval, 1);
      });

      test('parses MONTHLY rule with COUNT', () {
        final rule = MCalRecurrenceRule.fromRruleString(
          'RRULE:FREQ=MONTHLY;COUNT=12',
        );
        expect(rule.frequency, MCalFrequency.monthly);
        expect(rule.count, 12);
      });

      test('parses YEARLY rule', () {
        final rule = MCalRecurrenceRule.fromRruleString(
          'RRULE:FREQ=YEARLY;INTERVAL=1',
        );
        expect(rule.frequency, MCalFrequency.yearly);
        expect(rule.interval, 1);
      });

      test('parses string without RRULE: prefix', () {
        final rule = MCalRecurrenceRule.fromRruleString(
          'FREQ=WEEKLY;INTERVAL=1;BYDAY=MO',
        );
        expect(rule.frequency, MCalFrequency.weekly);
        final days =
            rule.byWeekDays!.map((wd) => wd.dayOfWeek).toList();
        expect(days, contains(DateTime.monday));
      });

      test('throws ArgumentError for SECONDLY frequency', () {
        expect(
          () => MCalRecurrenceRule.fromRruleString(
            'RRULE:FREQ=SECONDLY;INTERVAL=30',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws ArgumentError for MINUTELY frequency', () {
        expect(
          () => MCalRecurrenceRule.fromRruleString(
            'RRULE:FREQ=MINUTELY;INTERVAL=15',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws ArgumentError for HOURLY frequency', () {
        expect(
          () => MCalRecurrenceRule.fromRruleString(
            'RRULE:FREQ=HOURLY;INTERVAL=2',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('toRruleString', () {
      test('serializes daily rule', () {
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.daily,
          interval: 1,
        );
        final rrule = rule.toRruleString();
        expect(rrule, startsWith('RRULE:'));
        expect(rrule, contains('FREQ=DAILY'));
      });

      test('serializes weekly rule with interval', () {
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.weekly,
          interval: 2,
        );
        final rrule = rule.toRruleString();
        expect(rrule, contains('FREQ=WEEKLY'));
        expect(rrule, contains('INTERVAL=2'));
      });

      test('serializes rule with count', () {
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.monthly,
          count: 10,
        );
        final rrule = rule.toRruleString();
        expect(rrule, contains('FREQ=MONTHLY'));
        expect(rrule, contains('COUNT=10'));
      });
    });

    group('round-trip fromRruleString/toRruleString', () {
      test('round-trip produces equivalent rule', () {
        const input = 'RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH';
        final parsed = MCalRecurrenceRule.fromRruleString(input);
        final serialized = parsed.toRruleString();
        final reparsed = MCalRecurrenceRule.fromRruleString(serialized);

        expect(reparsed.frequency, parsed.frequency);
        expect(reparsed.interval, parsed.interval);
        expect(reparsed.count, parsed.count);
        expect(reparsed.until, parsed.until);
        // Check byWeekDays contain the same days
        final originalDays =
            parsed.byWeekDays!.map((wd) => wd.dayOfWeek).toSet();
        final roundTripDays =
            reparsed.byWeekDays!.map((wd) => wd.dayOfWeek).toSet();
        expect(roundTripDays, equals(originalDays));
      });

      test('round-trip daily rule', () {
        const input = 'RRULE:FREQ=DAILY;INTERVAL=3';
        final parsed = MCalRecurrenceRule.fromRruleString(input);
        final serialized = parsed.toRruleString();
        final reparsed = MCalRecurrenceRule.fromRruleString(serialized);

        expect(reparsed.frequency, MCalFrequency.daily);
        expect(reparsed.interval, 3);
      });
    });

    group('getOccurrences', () {
      test('daily rule returns correct dates in a range', () {
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.daily,
          interval: 1,
        );
        final occurrences = rule.getOccurrences(
          start: DateTime(2024, 1, 1),
          after: DateTime(2024, 1, 1),
          before: DateTime(2024, 1, 8),
        );
        expect(occurrences, hasLength(7));
        expect(occurrences[0], DateTime(2024, 1, 1));
        expect(occurrences[1], DateTime(2024, 1, 2));
        expect(occurrences[6], DateTime(2024, 1, 7));
      });

      test('daily rule with interval=2', () {
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.daily,
          interval: 2,
        );
        final occurrences = rule.getOccurrences(
          start: DateTime(2024, 1, 1),
          after: DateTime(2024, 1, 1),
          before: DateTime(2024, 1, 10),
        );
        // Jan 1, 3, 5, 7, 9
        expect(occurrences, hasLength(5));
        expect(occurrences[0], DateTime(2024, 1, 1));
        expect(occurrences[1], DateTime(2024, 1, 3));
        expect(occurrences[2], DateTime(2024, 1, 5));
        expect(occurrences[3], DateTime(2024, 1, 7));
        expect(occurrences[4], DateTime(2024, 1, 9));
      });

      test('weekly rule with specific days', () {
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.weekly,
          interval: 1,
          byWeekDays: {
            MCalWeekDay.every(DateTime.tuesday),
            MCalWeekDay.every(DateTime.thursday),
          },
        );
        // Jan 1, 2024 is a Monday
        final occurrences = rule.getOccurrences(
          start: DateTime(2024, 1, 1),
          after: DateTime(2024, 1, 1),
          before: DateTime(2024, 1, 15),
        );
        // Tue Jan 2, Thu Jan 4, Tue Jan 9, Thu Jan 11
        expect(occurrences, hasLength(4));
        for (final occ in occurrences) {
          expect(
            occ.weekday == DateTime.tuesday ||
                occ.weekday == DateTime.thursday,
            isTrue,
            reason: '${occ} should be Tuesday or Thursday',
          );
        }
      });

      test('monthly rule with byMonthDays', () {
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.monthly,
          interval: 1,
          byMonthDays: [15],
        );
        // Starting Jan 1, expand from Jan through May
        final occurrences = rule.getOccurrences(
          start: DateTime(2024, 1, 1),
          after: DateTime(2024, 1, 1),
          before: DateTime(2024, 6, 1),
        );
        // Jan 15, Feb 15, Mar 15, Apr 15, May 15
        expect(occurrences, hasLength(5));
        expect(occurrences[0], DateTime(2024, 1, 15));
        expect(occurrences[1], DateTime(2024, 2, 15));
        expect(occurrences[2], DateTime(2024, 3, 15));
        expect(occurrences[3], DateTime(2024, 4, 15));
        expect(occurrences[4], DateTime(2024, 5, 15));
      });

      test('monthly rule produces occurrences at monthly intervals', () {
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.monthly,
          interval: 1,
        );
        final occurrences = rule.getOccurrences(
          start: DateTime(2024, 1, 1),
          after: DateTime(2024, 1, 1),
          before: DateTime(2024, 6, 1),
        );
        // Should produce monthly occurrences
        expect(occurrences, isNotEmpty);
        expect(occurrences.length, greaterThanOrEqualTo(4));
        // Verify monthly spacing: each occurrence is in a different month
        for (int i = 1; i < occurrences.length; i++) {
          expect(
            occurrences[i].month,
            greaterThan(occurrences[i - 1].month),
            reason: 'Occurrences should be in increasing months',
          );
        }
      });

      test('yearly rule', () {
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.yearly,
          interval: 1,
        );
        final occurrences = rule.getOccurrences(
          start: DateTime(2024, 3, 1),
          after: DateTime(2024, 1, 1),
          before: DateTime(2027, 1, 1),
        );
        // Mar 1 2024, Mar 1 2025, Mar 1 2026
        expect(occurrences, hasLength(3));
        expect(occurrences[0], DateTime(2024, 3, 1));
        expect(occurrences[1], DateTime(2025, 3, 1));
        expect(occurrences[2], DateTime(2026, 3, 1));
      });

      test('rule with count stops at count', () {
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.daily,
          interval: 1,
          count: 5,
        );
        final occurrences = rule.getOccurrences(
          start: DateTime(2024, 1, 1),
          after: DateTime(2024, 1, 1),
          before: DateTime(2024, 12, 31),
        );
        // Only 5 occurrences despite large range
        expect(occurrences, hasLength(5));
        expect(occurrences.last, DateTime(2024, 1, 5));
      });

      test('rule with until stops at until', () {
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.daily,
          interval: 1,
          until: DateTime(2024, 1, 6),
        );
        final occurrences = rule.getOccurrences(
          start: DateTime(2024, 1, 1),
          after: DateTime(2024, 1, 1),
          before: DateTime(2024, 12, 31),
        );
        // Should stop well before the large range end
        expect(occurrences.length, lessThanOrEqualTo(6));
        expect(occurrences, isNotEmpty);
        expect(occurrences.first, DateTime(2024, 1, 1));
        // All occurrences should be on or before the until date
        for (final occ in occurrences) {
          expect(
            occ.isBefore(DateTime(2024, 1, 7)),
            isTrue,
            reason: '$occ should be before Jan 7',
          );
        }
      });
    });

    test('toString contains all fields', () {
      final rule = MCalRecurrenceRule(
        frequency: MCalFrequency.weekly,
        interval: 2,
        count: 10,
        byWeekDays: {MCalWeekDay.every(DateTime.monday)},
      );
      final str = rule.toString();
      expect(str, contains('MCalRecurrenceRule'));
      expect(str, contains('frequency: MCalFrequency.weekly'));
      expect(str, contains('interval: 2'));
      expect(str, contains('count: 10'));
    });

    test('toString with null optional fields', () {
      final rule = MCalRecurrenceRule(frequency: MCalFrequency.daily);
      final str = rule.toString();
      expect(str, contains('count: null'));
      expect(str, contains('until: null'));
      expect(str, contains('byWeekDays: null'));
    });

    test('== is order-independent for byWeekDays', () {
      final a = MCalRecurrenceRule(
        frequency: MCalFrequency.weekly,
        byWeekDays: {
          MCalWeekDay.every(DateTime.monday),
          MCalWeekDay.every(DateTime.friday),
        },
      );
      final b = MCalRecurrenceRule(
        frequency: MCalFrequency.weekly,
        byWeekDays: {
          MCalWeekDay.every(DateTime.friday),
          MCalWeekDay.every(DateTime.monday),
        },
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('== is order-independent for byMonthDays', () {
      final a = MCalRecurrenceRule(
        frequency: MCalFrequency.monthly,
        byMonthDays: [1, 15, 28],
      );
      final b = MCalRecurrenceRule(
        frequency: MCalFrequency.monthly,
        byMonthDays: [28, 1, 15],
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    group('byYearDays', () {
      test('construction with byYearDays', () {
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.yearly,
          byYearDays: [1, 100, 200],
        );
        expect(rule.byYearDays, [1, 100, 200]);
      });

      test('throws ArgumentError when used with non-yearly frequency', () {
        expect(
          () => MCalRecurrenceRule(
            frequency: MCalFrequency.monthly,
            byYearDays: [1],
          ),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => MCalRecurrenceRule(
            frequency: MCalFrequency.weekly,
            byYearDays: [1],
          ),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => MCalRecurrenceRule(
            frequency: MCalFrequency.daily,
            byYearDays: [1],
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('copyWith replaces byYearDays', () {
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.yearly,
          byYearDays: [1, 100],
        );
        final copied = rule.copyWith(byYearDays: () => [200, 300]);
        expect(copied.byYearDays, [200, 300]);
      });

      test('copyWith can set byYearDays to null', () {
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.yearly,
          byYearDays: [1],
        );
        final copied = rule.copyWith(byYearDays: () => null);
        expect(copied.byYearDays, isNull);
      });

      test('round-trip with BYYEARDAY', () {
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.yearly,
          byYearDays: [1, 100, 200],
        );
        final serialized = rule.toRruleString();
        expect(serialized, contains('BYYEARDAY='));
        final reparsed = MCalRecurrenceRule.fromRruleString(serialized);
        expect(reparsed.byYearDays, isNotNull);
        expect(reparsed.byYearDays!.toSet(), equals({1, 100, 200}));
      });

      test('getOccurrences with byYearDays', () {
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.yearly,
          byYearDays: [1, 60], // Jan 1 and Mar 1 (in non-leap year)
        );
        final occurrences = rule.getOccurrences(
          start: DateTime(2025, 1, 1),
          after: DateTime(2025, 1, 1),
          before: DateTime(2025, 12, 31),
        );
        expect(occurrences.length, 2);
        // Day 1 of 2025 = Jan 1
        expect(occurrences[0], DateTime(2025, 1, 1));
        // Day 60 of 2025 = Mar 1
        expect(occurrences[1], DateTime(2025, 3, 1));
      });

      test('== and hashCode with byYearDays', () {
        final a = MCalRecurrenceRule(
          frequency: MCalFrequency.yearly,
          byYearDays: [1, 100],
        );
        final b = MCalRecurrenceRule(
          frequency: MCalFrequency.yearly,
          byYearDays: [100, 1],
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('toString includes byYearDays', () {
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.yearly,
          byYearDays: [1, 100],
        );
        expect(rule.toString(), contains('byYearDays'));
      });
    });

    /// RFC 5545 section 3.8.5.3 examples — validates against the standard.
    group('RFC 5545 examples', () {
      test('weekly on Tuesday and Thursday for 10 occurrences', () {
        // RFC: DTSTART 1997-09-02 09:00, RRULE FREQ=WEEKLY;COUNT=10;WKST=SU;BYDAY=TU,TH
        // Expected: Sep 2,4,9,11,16,18,23,25,30; Oct 2
        final rule = MCalRecurrenceRule.fromRruleString(
          'RRULE:FREQ=WEEKLY;COUNT=10;WKST=SU;BYDAY=TU,TH',
        );
        final start = DateTime(1997, 9, 2, 9, 0);
        final occurrences = rule.getOccurrences(
          start: start,
          after: DateTime(1997, 9, 1),
          before: DateTime(1997, 10, 15),
        );
        expect(occurrences, hasLength(10));
        final dates = occurrences.map((d) => DateTime(d.year, d.month, d.day)).toList();
        expect(dates[0], DateTime(1997, 9, 2));
        expect(dates[1], DateTime(1997, 9, 4));
        expect(dates[2], DateTime(1997, 9, 9));
        expect(dates[3], DateTime(1997, 9, 11));
        expect(dates[4], DateTime(1997, 9, 16));
        expect(dates[5], DateTime(1997, 9, 18));
        expect(dates[6], DateTime(1997, 9, 23));
        expect(dates[7], DateTime(1997, 9, 25));
        expect(dates[8], DateTime(1997, 9, 30));
        expect(dates[9], DateTime(1997, 10, 2));
      });

      test('monthly on the first Friday for 10 occurrences', () {
        // RFC: DTSTART 1997-09-05 09:00, RRULE FREQ=MONTHLY;COUNT=10;BYDAY=1FR
        // Expected: Sep 5, Oct 3, Nov 7, Dec 5, Jan 2 1998, Feb 6, Mar 6, Apr 3, May 1, Jun 5
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.monthly,
          count: 10,
          byWeekDays: {MCalWeekDay.nth(DateTime.friday, 1)},
        );
        final start = DateTime(1997, 9, 5, 9, 0);
        final occurrences = rule.getOccurrences(
          start: start,
          after: DateTime(1997, 9, 1),
          before: DateTime(1998, 7, 1),
        );
        expect(occurrences, hasLength(10));
        final dates = occurrences.map((d) => DateTime(d.year, d.month, d.day)).toList();
        expect(dates[0], DateTime(1997, 9, 5));
        expect(dates[1], DateTime(1997, 10, 3));
        expect(dates[2], DateTime(1997, 11, 7));
        expect(dates[3], DateTime(1997, 12, 5));
        expect(dates[4], DateTime(1998, 1, 2));
        expect(dates[5], DateTime(1998, 2, 6));
        expect(dates[6], DateTime(1998, 3, 6));
        expect(dates[7], DateTime(1998, 4, 3));
        expect(dates[8], DateTime(1998, 5, 1));
        expect(dates[9], DateTime(1998, 6, 5));
      });

      test('daily for 10 occurrences', () {
        // RFC: DTSTART 1997-09-02 09:00, RRULE FREQ=DAILY;COUNT=10
        // Expected: Sep 2–11 (each at 09:00)
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.daily,
          count: 10,
        );
        final start = DateTime(1997, 9, 2, 9, 0);
        final occurrences = rule.getOccurrences(
          start: start,
          after: DateTime(1997, 9, 1),
          before: DateTime(1997, 9, 20),
        );
        expect(occurrences, hasLength(10));
        expect(occurrences[0], DateTime(1997, 9, 2, 9, 0));
        expect(occurrences[1], DateTime(1997, 9, 3, 9, 0));
        expect(occurrences[9], DateTime(1997, 9, 11, 9, 0));
      });

      test('every 10 days, 5 occurrences', () {
        // RFC: DTSTART 1997-09-02 09:00, RRULE FREQ=DAILY;INTERVAL=10;COUNT=5
        // Expected: Sep 2, 12, 22; Oct 2, 12 (each at 09:00)
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.daily,
          interval: 10,
          count: 5,
        );
        final start = DateTime(1997, 9, 2, 9, 0);
        final occurrences = rule.getOccurrences(
          start: start,
          after: DateTime(1997, 9, 1),
          before: DateTime(1997, 11, 1),
        );
        expect(occurrences, hasLength(5));
        expect(occurrences[0], DateTime(1997, 9, 2, 9, 0));
        expect(occurrences[1], DateTime(1997, 9, 12, 9, 0));
        expect(occurrences[2], DateTime(1997, 9, 22, 9, 0));
        expect(occurrences[3], DateTime(1997, 10, 2, 9, 0));
        expect(occurrences[4], DateTime(1997, 10, 12, 9, 0));
      });
    });

    group('byWeekNumbers', () {
      test('construction with byWeekNumbers', () {
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.yearly,
          byWeekNumbers: [1, 20, 52],
        );
        expect(rule.byWeekNumbers, [1, 20, 52]);
      });

      test('throws ArgumentError when used with non-yearly frequency', () {
        expect(
          () => MCalRecurrenceRule(
            frequency: MCalFrequency.monthly,
            byWeekNumbers: [1],
          ),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => MCalRecurrenceRule(
            frequency: MCalFrequency.weekly,
            byWeekNumbers: [1],
          ),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => MCalRecurrenceRule(
            frequency: MCalFrequency.daily,
            byWeekNumbers: [1],
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('copyWith replaces byWeekNumbers', () {
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.yearly,
          byWeekNumbers: [1, 20],
        );
        final copied = rule.copyWith(byWeekNumbers: () => [30, 40]);
        expect(copied.byWeekNumbers, [30, 40]);
      });

      test('copyWith can set byWeekNumbers to null', () {
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.yearly,
          byWeekNumbers: [1],
        );
        final copied = rule.copyWith(byWeekNumbers: () => null);
        expect(copied.byWeekNumbers, isNull);
      });

      test('round-trip with BYWEEKNO', () {
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.yearly,
          byWeekNumbers: [1, 20],
          byWeekDays: {MCalWeekDay.every(DateTime.monday)},
        );
        final serialized = rule.toRruleString();
        expect(serialized, contains('BYWEEKNO='));
        final reparsed = MCalRecurrenceRule.fromRruleString(serialized);
        expect(reparsed.byWeekNumbers, isNotNull);
        expect(reparsed.byWeekNumbers!.toSet(), equals({1, 20}));
      });

      test('== and hashCode with byWeekNumbers', () {
        final a = MCalRecurrenceRule(
          frequency: MCalFrequency.yearly,
          byWeekNumbers: [1, 20],
        );
        final b = MCalRecurrenceRule(
          frequency: MCalFrequency.yearly,
          byWeekNumbers: [20, 1],
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('toString includes byWeekNumbers', () {
        final rule = MCalRecurrenceRule(
          frequency: MCalFrequency.yearly,
          byWeekNumbers: [1, 20],
        );
        expect(rule.toString(), contains('byWeekNumbers'));
      });
    });
  });
}
