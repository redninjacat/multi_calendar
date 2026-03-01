import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/src/models/mcal_region.dart';
import 'package:multi_calendar/src/models/mcal_recurrence_rule.dart';

void main() {
  group('MCalRegion', () {
    final testStart = DateTime(2026, 2, 14, 12, 0);
    final testEnd = DateTime(2026, 2, 14, 13, 0);

    // -----------------------------------------------------------------------
    // 1. Constructor and properties
    // -----------------------------------------------------------------------

    group('constructor and properties', () {
      test('creates instance with required fields only', () {
        final region = MCalRegion(
          id: 'region-1',
          start: testStart,
          end: testEnd,
        );

        expect(region.id, 'region-1');
        expect(region.start, testStart);
        expect(region.end, testEnd);
        expect(region.color, isNull);
        expect(region.text, isNull);
        expect(region.icon, isNull);
        expect(region.blockInteraction, isFalse);
        expect(region.isAllDay, isFalse);
        expect(region.recurrenceRule, isNull);
        expect(region.customData, isNull);
      });

      test('creates instance with all optional fields', () {
        final rule = MCalRecurrenceRule(frequency: MCalFrequency.daily);
        final region = MCalRegion(
          id: 'lunch',
          start: testStart,
          end: testEnd,
          color: Colors.amber.withValues(alpha: 0.3),
          text: 'Lunch Break',
          icon: Icons.restaurant,
          blockInteraction: true,
          isAllDay: true,
          recurrenceRule: rule,
          customData: {'priority': 'high'},
        );

        expect(region.id, 'lunch');
        expect(region.start, testStart);
        expect(region.end, testEnd);
        expect(region.color, Colors.amber.withValues(alpha: 0.3));
        expect(region.text, 'Lunch Break');
        expect(region.icon, Icons.restaurant);
        expect(region.blockInteraction, isTrue);
        expect(region.isAllDay, isTrue);
        expect(region.recurrenceRule, rule);
        expect(region.customData, {'priority': 'high'});
      });

      test('blockInteraction defaults to false', () {
        final region = MCalRegion(
          id: 'visual-only',
          start: testStart,
          end: testEnd,
        );
        expect(region.blockInteraction, isFalse);
      });

      test('isAllDay defaults to false', () {
        final region = MCalRegion(
          id: 'timed',
          start: testStart,
          end: testEnd,
        );
        expect(region.isAllDay, isFalse);
      });

      test('customData map is preserved as-is', () {
        final data = {'key1': 'value1', 'key2': 42, 'key3': true};
        final region = MCalRegion(
          id: 'data-region',
          start: testStart,
          end: testEnd,
          customData: data,
        );
        expect(region.customData, equals(data));
        expect(region.customData!['key2'], 42);
      });
    });

    // -----------------------------------------------------------------------
    // 2. copyWith
    // -----------------------------------------------------------------------

    group('copyWith', () {
      late MCalRegion base;

      setUp(() {
        base = MCalRegion(
          id: 'base',
          start: testStart,
          end: testEnd,
          color: Colors.blue,
          text: 'Base',
          icon: Icons.star,
          blockInteraction: false,
          isAllDay: false,
          recurrenceRule:
              MCalRecurrenceRule(frequency: MCalFrequency.daily),
          customData: {'k': 'v'},
        );
      });

      test('copy with no changes returns equal instance', () {
        final copy = base.copyWith();
        expect(copy, equals(base));
      });

      test('copy with id', () {
        final copy = base.copyWith(id: 'new-id');
        expect(copy.id, 'new-id');
        expect(copy.start, base.start);
      });

      test('copy with start', () {
        final newStart = DateTime(2027, 1, 1);
        final copy = base.copyWith(start: newStart);
        expect(copy.start, newStart);
      });

      test('copy with end', () {
        final newEnd = DateTime(2027, 1, 2);
        final copy = base.copyWith(end: newEnd);
        expect(copy.end, newEnd);
      });

      test('copy with color', () {
        final copy = base.copyWith(color: Colors.red);
        expect(copy.color, Colors.red);
      });

      test('copy with color set to null', () {
        final copy = base.copyWith(color: null);
        expect(copy.color, isNull);
      });

      test('copy with text', () {
        final copy = base.copyWith(text: 'Updated');
        expect(copy.text, 'Updated');
      });

      test('copy with text set to null', () {
        final copy = base.copyWith(text: null);
        expect(copy.text, isNull);
      });

      test('copy with icon', () {
        final copy = base.copyWith(icon: Icons.home);
        expect(copy.icon, Icons.home);
      });

      test('copy with icon set to null', () {
        final copy = base.copyWith(icon: null);
        expect(copy.icon, isNull);
      });

      test('copy with blockInteraction', () {
        final copy = base.copyWith(blockInteraction: true);
        expect(copy.blockInteraction, isTrue);
      });

      test('copy with isAllDay', () {
        final copy = base.copyWith(isAllDay: true);
        expect(copy.isAllDay, isTrue);
      });

      test('copy with recurrenceRule', () {
        final newRule =
            MCalRecurrenceRule(frequency: MCalFrequency.weekly);
        final copy = base.copyWith(recurrenceRule: newRule);
        expect(copy.recurrenceRule, newRule);
      });

      test('copy with recurrenceRule set to null', () {
        final copy = base.copyWith(recurrenceRule: null);
        expect(copy.recurrenceRule, isNull);
      });

      test('copy with customData', () {
        final copy = base.copyWith(customData: {'new': true});
        expect(copy.customData, {'new': true});
      });

      test('copy with customData set to null', () {
        final copy = base.copyWith(customData: null);
        expect(copy.customData, isNull);
      });
    });

    // -----------------------------------------------------------------------
    // 3. == and hashCode
    // -----------------------------------------------------------------------

    group('== and hashCode', () {
      test('equal instances', () {
        final rule = MCalRecurrenceRule(frequency: MCalFrequency.daily);
        final a = MCalRegion(
          id: 'eq',
          start: testStart,
          end: testEnd,
          color: Colors.blue,
          text: 'Same',
          icon: Icons.star,
          blockInteraction: true,
          isAllDay: true,
          recurrenceRule: rule,
        );
        final b = MCalRegion(
          id: 'eq',
          start: testStart,
          end: testEnd,
          color: Colors.blue,
          text: 'Same',
          icon: Icons.star,
          blockInteraction: true,
          isAllDay: true,
          recurrenceRule:
              MCalRecurrenceRule(frequency: MCalFrequency.daily),
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('equal instances with same customData content', () {
        final a = MCalRegion(
          id: 'eq',
          start: testStart,
          end: testEnd,
          customData: {'x': 1},
        );
        final b = MCalRegion(
          id: 'eq',
          start: testStart,
          end: testEnd,
          customData: {'x': 1},
        );
        expect(a, equals(b));
      });

      test('equality works with equivalent customData maps', () {
        final a = MCalRegion(
          id: 'eq',
          start: testStart,
          end: testEnd,
          customData: {'x': 1},
        );
        final b = MCalRegion(
          id: 'eq',
          start: testStart,
          end: testEnd,
          customData: {'x': 1},
        );
        expect(a, equals(b));
      });

      test('unequal by id', () {
        final a = MCalRegion(id: 'a', start: testStart, end: testEnd);
        final b = MCalRegion(id: 'b', start: testStart, end: testEnd);
        expect(a, isNot(equals(b)));
      });

      test('unequal by start', () {
        final a = MCalRegion(
            id: 'r', start: DateTime(2026, 1, 1), end: testEnd);
        final b = MCalRegion(
            id: 'r', start: DateTime(2026, 1, 2), end: testEnd);
        expect(a, isNot(equals(b)));
      });

      test('unequal by end', () {
        final a = MCalRegion(
            id: 'r', start: testStart, end: DateTime(2026, 2, 14, 14, 0));
        final b = MCalRegion(
            id: 'r', start: testStart, end: DateTime(2026, 2, 14, 15, 0));
        expect(a, isNot(equals(b)));
      });

      test('unequal by color', () {
        final a = MCalRegion(
            id: 'r', start: testStart, end: testEnd, color: Colors.red);
        final b = MCalRegion(
            id: 'r', start: testStart, end: testEnd, color: Colors.blue);
        expect(a, isNot(equals(b)));
      });

      test('unequal by text', () {
        final a = MCalRegion(
            id: 'r', start: testStart, end: testEnd, text: 'A');
        final b = MCalRegion(
            id: 'r', start: testStart, end: testEnd, text: 'B');
        expect(a, isNot(equals(b)));
      });

      test('unequal by icon', () {
        final a = MCalRegion(
            id: 'r', start: testStart, end: testEnd, icon: Icons.star);
        final b = MCalRegion(
            id: 'r', start: testStart, end: testEnd, icon: Icons.home);
        expect(a, isNot(equals(b)));
      });

      test('unequal by blockInteraction', () {
        final a = MCalRegion(
            id: 'r',
            start: testStart,
            end: testEnd,
            blockInteraction: false);
        final b = MCalRegion(
            id: 'r',
            start: testStart,
            end: testEnd,
            blockInteraction: true);
        expect(a, isNot(equals(b)));
      });

      test('unequal by isAllDay', () {
        final a = MCalRegion(
            id: 'r', start: testStart, end: testEnd, isAllDay: false);
        final b = MCalRegion(
            id: 'r', start: testStart, end: testEnd, isAllDay: true);
        expect(a, isNot(equals(b)));
      });

      test('unequal by recurrenceRule', () {
        final a = MCalRegion(
          id: 'r',
          start: testStart,
          end: testEnd,
          recurrenceRule:
              MCalRecurrenceRule(frequency: MCalFrequency.daily),
        );
        final b = MCalRegion(
          id: 'r',
          start: testStart,
          end: testEnd,
          recurrenceRule:
              MCalRecurrenceRule(frequency: MCalFrequency.weekly),
        );
        expect(a, isNot(equals(b)));
      });

      test('unequal by customData', () {
        final a = MCalRegion(
            id: 'r',
            start: testStart,
            end: testEnd,
            customData: {'a': 1});
        final b = MCalRegion(
            id: 'r',
            start: testStart,
            end: testEnd,
            customData: {'b': 2});
        expect(a, isNot(equals(b)));
      });

      test('hashCode consistency across equal instances', () {
        final region = MCalRegion(
          id: 'hc',
          start: testStart,
          end: testEnd,
          text: 'test',
        );
        final hash1 = region.hashCode;
        final hash2 = region.hashCode;
        expect(hash1, equals(hash2));
      });
    });

    // -----------------------------------------------------------------------
    // 4. toString
    // -----------------------------------------------------------------------

    group('toString', () {
      test('contains all field values', () {
        final region = MCalRegion(
          id: 'str-test',
          start: testStart,
          end: testEnd,
          color: Colors.red,
          text: 'Label',
          icon: Icons.star,
          blockInteraction: true,
          isAllDay: true,
          recurrenceRule:
              MCalRecurrenceRule(frequency: MCalFrequency.daily),
          customData: {'k': 'v'},
        );

        final str = region.toString();
        expect(str, contains('str-test'));
        expect(str, contains('$testStart'));
        expect(str, contains('$testEnd'));
        expect(str, contains('isAllDay: true'));
        expect(str, contains('blockInteraction: true'));
        expect(str, contains('Label'));
        expect(str, contains('customData'));
      });
    });

    // -----------------------------------------------------------------------
    // 5. contains (timed regions)
    // -----------------------------------------------------------------------

    group('contains', () {
      test('returns true for time inside region', () {
        final region = MCalRegion(
          id: 'lunch',
          start: DateTime(2026, 2, 14, 12, 0),
          end: DateTime(2026, 2, 14, 13, 0),
        );

        expect(region.contains(DateTime(2026, 2, 14, 12, 0)), isTrue);
        expect(region.contains(DateTime(2026, 2, 14, 12, 30)), isTrue);
        expect(region.contains(DateTime(2026, 2, 14, 12, 59)), isTrue);
      });

      test('returns false for time before region', () {
        final region = MCalRegion(
          id: 'lunch',
          start: DateTime(2026, 2, 14, 12, 0),
          end: DateTime(2026, 2, 14, 13, 0),
        );

        expect(region.contains(DateTime(2026, 2, 14, 11, 59)), isFalse);
        expect(region.contains(DateTime(2026, 2, 14, 10, 0)), isFalse);
      });

      test('returns false for time after region', () {
        final region = MCalRegion(
          id: 'lunch',
          start: DateTime(2026, 2, 14, 12, 0),
          end: DateTime(2026, 2, 14, 13, 0),
        );

        expect(region.contains(DateTime(2026, 2, 14, 13, 1)), isFalse);
        expect(region.contains(DateTime(2026, 2, 14, 14, 0)), isFalse);
      });

      test('at start is included', () {
        final region = MCalRegion(
          id: 'slot',
          start: DateTime(2026, 2, 14, 9, 0),
          end: DateTime(2026, 2, 14, 10, 0),
        );
        expect(region.contains(DateTime(2026, 2, 14, 9, 0)), isTrue);
      });

      test('at end is excluded', () {
        final region = MCalRegion(
          id: 'slot',
          start: DateTime(2026, 2, 14, 9, 0),
          end: DateTime(2026, 2, 14, 10, 0),
        );
        expect(region.contains(DateTime(2026, 2, 14, 10, 0)), isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // 6. overlaps (timed regions)
    // -----------------------------------------------------------------------

    group('overlaps', () {
      test('returns true for overlapping ranges', () {
        final region = MCalRegion(
          id: 'lunch',
          start: DateTime(2026, 2, 14, 12, 0),
          end: DateTime(2026, 2, 14, 13, 0),
        );

        expect(
          region.overlaps(
            DateTime(2026, 2, 14, 11, 30),
            DateTime(2026, 2, 14, 12, 30),
          ),
          isTrue,
        );
      });

      test('returns false for range entirely before region', () {
        final region = MCalRegion(
          id: 'lunch',
          start: DateTime(2026, 2, 14, 12, 0),
          end: DateTime(2026, 2, 14, 13, 0),
        );

        expect(
          region.overlaps(
            DateTime(2026, 2, 14, 10, 0),
            DateTime(2026, 2, 14, 11, 0),
          ),
          isFalse,
        );
      });

      test('returns false for range entirely after region', () {
        final region = MCalRegion(
          id: 'lunch',
          start: DateTime(2026, 2, 14, 12, 0),
          end: DateTime(2026, 2, 14, 13, 0),
        );

        expect(
          region.overlaps(
            DateTime(2026, 2, 14, 14, 0),
            DateTime(2026, 2, 14, 15, 0),
          ),
          isFalse,
        );
      });

      test('touching boundaries do not overlap (range ends at region start)',
          () {
        final region = MCalRegion(
          id: 'slot',
          start: DateTime(2026, 2, 14, 9, 0),
          end: DateTime(2026, 2, 14, 10, 0),
        );

        expect(
          region.overlaps(
            DateTime(2026, 2, 14, 8, 0),
            DateTime(2026, 2, 14, 9, 0),
          ),
          isFalse,
        );
      });

      test('touching boundaries do not overlap (range starts at region end)',
          () {
        final region = MCalRegion(
          id: 'slot',
          start: DateTime(2026, 2, 14, 9, 0),
          end: DateTime(2026, 2, 14, 10, 0),
        );

        expect(
          region.overlaps(
            DateTime(2026, 2, 14, 10, 0),
            DateTime(2026, 2, 14, 11, 0),
          ),
          isFalse,
        );
      });

      test('partial overlap from start', () {
        final region = MCalRegion(
          id: 'lunch',
          start: DateTime(2026, 2, 14, 12, 0),
          end: DateTime(2026, 2, 14, 13, 0),
        );

        expect(
          region.overlaps(
            DateTime(2026, 2, 14, 12, 30),
            DateTime(2026, 2, 14, 13, 30),
          ),
          isTrue,
        );
      });

      test('range fully inside region', () {
        final region = MCalRegion(
          id: 'lunch',
          start: DateTime(2026, 2, 14, 12, 0),
          end: DateTime(2026, 2, 14, 13, 0),
        );

        expect(
          region.overlaps(
            DateTime(2026, 2, 14, 12, 15),
            DateTime(2026, 2, 14, 12, 45),
          ),
          isTrue,
        );
      });

      test('range fully contains region', () {
        final region = MCalRegion(
          id: 'lunch',
          start: DateTime(2026, 2, 14, 12, 0),
          end: DateTime(2026, 2, 14, 13, 0),
        );

        expect(
          region.overlaps(
            DateTime(2026, 2, 14, 11, 0),
            DateTime(2026, 2, 14, 14, 0),
          ),
          isTrue,
        );
      });
    });

    // -----------------------------------------------------------------------
    // 7. appliesTo
    // -----------------------------------------------------------------------

    group('appliesTo', () {
      group('all-day single date', () {
        test('matching date returns true', () {
          final region = MCalRegion(
            id: 'holiday',
            start: DateTime(2026, 7, 4),
            end: DateTime(2026, 7, 4),
            isAllDay: true,
          );
          expect(region.appliesTo(DateTime(2026, 7, 4)), isTrue);
        });

        test('non-matching date returns false', () {
          final region = MCalRegion(
            id: 'holiday',
            start: DateTime(2026, 7, 4),
            end: DateTime(2026, 7, 4),
            isAllDay: true,
          );
          expect(region.appliesTo(DateTime(2026, 7, 5)), isFalse);
          expect(region.appliesTo(DateTime(2026, 7, 3)), isFalse);
        });
      });

      group('all-day date range', () {
        late MCalRegion region;

        setUp(() {
          region = MCalRegion(
            id: 'vacation',
            start: DateTime(2026, 8, 1),
            end: DateTime(2026, 8, 5),
            isAllDay: true,
          );
        });

        test('start date matches', () {
          expect(region.appliesTo(DateTime(2026, 8, 1)), isTrue);
        });

        test('middle date matches', () {
          expect(region.appliesTo(DateTime(2026, 8, 3)), isTrue);
        });

        test('end date matches (inclusive)', () {
          expect(region.appliesTo(DateTime(2026, 8, 5)), isTrue);
        });

        test('date outside range returns false', () {
          expect(region.appliesTo(DateTime(2026, 7, 31)), isFalse);
          expect(region.appliesTo(DateTime(2026, 8, 6)), isFalse);
        });
      });

      group('all-day with recurrence (weekly)', () {
        test('matches recurring weekend days', () {
          final region = MCalRegion(
            id: 'weekends',
            start: DateTime(2026, 1, 3), // Saturday
            end: DateTime(2026, 1, 3),
            isAllDay: true,
            recurrenceRule: MCalRecurrenceRule(
              frequency: MCalFrequency.weekly,
              byWeekDays: {
                MCalWeekDay.every(DateTime.saturday),
              },
            ),
          );

          // Jan 10, 2026 is a Saturday
          expect(region.appliesTo(DateTime(2026, 1, 10)), isTrue);
          // Jan 12, 2026 is a Monday
          expect(region.appliesTo(DateTime(2026, 1, 12)), isFalse);
        });
      });

      group('timed single date', () {
        test('matching date returns true', () {
          final region = MCalRegion(
            id: 'meeting',
            start: DateTime(2026, 3, 10, 14, 0),
            end: DateTime(2026, 3, 10, 15, 0),
            isAllDay: false,
          );
          expect(region.appliesTo(DateTime(2026, 3, 10)), isTrue);
        });

        test('wrong date returns false', () {
          final region = MCalRegion(
            id: 'meeting',
            start: DateTime(2026, 3, 10, 14, 0),
            end: DateTime(2026, 3, 10, 15, 0),
            isAllDay: false,
          );
          expect(region.appliesTo(DateTime(2026, 3, 11)), isFalse);
        });
      });

      group('timed with recurrence (daily)', () {
        test('applies to days after anchor', () {
          final region = MCalRegion(
            id: 'after-hours',
            start: DateTime(2026, 1, 1, 18, 0),
            end: DateTime(2026, 1, 1, 22, 0),
            recurrenceRule:
                MCalRecurrenceRule(frequency: MCalFrequency.daily),
          );

          expect(region.appliesTo(DateTime(2026, 1, 1)), isTrue);
          expect(region.appliesTo(DateTime(2026, 2, 15)), isTrue);
        });

        test('does not apply before anchor', () {
          final region = MCalRegion(
            id: 'after-hours',
            start: DateTime(2026, 3, 1, 18, 0),
            end: DateTime(2026, 3, 1, 22, 0),
            recurrenceRule:
                MCalRecurrenceRule(frequency: MCalFrequency.daily),
          );

          expect(region.appliesTo(DateTime(2026, 2, 28)), isFalse);
        });
      });

      group('isAllDay=true ignores time components', () {
        test('matches even when query has non-zero time', () {
          final region = MCalRegion(
            id: 'holiday',
            start: DateTime(2026, 7, 4),
            end: DateTime(2026, 7, 4),
            isAllDay: true,
          );
          expect(
              region.appliesTo(DateTime(2026, 7, 4, 23, 59, 59)), isTrue);
        });
      });
    });

    // -----------------------------------------------------------------------
    // 8. expandedForDate
    // -----------------------------------------------------------------------

    group('expandedForDate', () {
      group('non-recurring timed', () {
        test('match returns self', () {
          final region = MCalRegion(
            id: 'lunch',
            start: DateTime(2026, 2, 14, 12, 0),
            end: DateTime(2026, 2, 14, 13, 0),
          );

          final expanded = region.expandedForDate(DateTime(2026, 2, 14));
          expect(expanded, same(region));
        });

        test('miss returns null', () {
          final region = MCalRegion(
            id: 'lunch',
            start: DateTime(2026, 2, 14, 12, 0),
            end: DateTime(2026, 2, 14, 13, 0),
          );

          expect(region.expandedForDate(DateTime(2026, 2, 15)), isNull);
          expect(region.expandedForDate(DateTime(2026, 2, 13)), isNull);
        });
      });

      group('non-recurring all-day', () {
        test('match returns self', () {
          final region = MCalRegion(
            id: 'holiday',
            start: DateTime(2026, 7, 4),
            end: DateTime(2026, 7, 4),
            isAllDay: true,
          );

          final expanded = region.expandedForDate(DateTime(2026, 7, 4));
          expect(expanded, same(region));
        });

        test('multi-day match returns self', () {
          final region = MCalRegion(
            id: 'vacation',
            start: DateTime(2026, 8, 1),
            end: DateTime(2026, 8, 3),
            isAllDay: true,
          );

          expect(region.expandedForDate(DateTime(2026, 8, 1)), same(region));
          expect(region.expandedForDate(DateTime(2026, 8, 2)), same(region));
          expect(region.expandedForDate(DateTime(2026, 8, 3)), same(region));
        });

        test('miss returns null', () {
          final region = MCalRegion(
            id: 'holiday',
            start: DateTime(2026, 7, 4),
            end: DateTime(2026, 7, 4),
            isAllDay: true,
          );

          expect(region.expandedForDate(DateTime(2026, 7, 5)), isNull);
        });
      });

      group('recurring timed', () {
        test('returns adjusted start/end preserving time-of-day', () {
          final region = MCalRegion(
            id: 'after-hours',
            start: DateTime(2026, 1, 1, 18, 0),
            end: DateTime(2026, 1, 1, 22, 0),
            recurrenceRule:
                MCalRecurrenceRule(frequency: MCalFrequency.daily),
            blockInteraction: true,
            color: Colors.grey,
            text: 'After Hours',
            icon: Icons.block,
          );

          final expanded = region.expandedForDate(DateTime(2026, 2, 25));
          expect(expanded, isNotNull);
          expect(expanded!.start, DateTime(2026, 2, 25, 18, 0));
          expect(expanded.end, DateTime(2026, 2, 25, 22, 0));
          expect(expanded.blockInteraction, isTrue);
          expect(expanded.color, Colors.grey);
          expect(expanded.text, 'After Hours');
          expect(expanded.icon, Icons.block);
          expect(expanded.recurrenceRule, isNull);
        });
      });

      group('recurring all-day', () {
        test('returns region for occurrence date', () {
          final region = MCalRegion(
            id: 'weekends',
            start: DateTime(2026, 1, 3), // Saturday
            end: DateTime(2026, 1, 3),
            isAllDay: true,
            recurrenceRule: MCalRecurrenceRule(
              frequency: MCalFrequency.weekly,
              byWeekDays: {MCalWeekDay.every(DateTime.saturday)},
            ),
            color: Colors.green,
            text: 'Weekend',
          );

          // Jan 10, 2026 is a Saturday
          final expanded = region.expandedForDate(DateTime(2026, 1, 10));
          expect(expanded, isNotNull);
          expect(expanded!.start, DateTime(2026, 1, 10));
          expect(expanded.end, DateTime(2026, 1, 10));
          expect(expanded.isAllDay, isTrue);
          expect(expanded.color, Colors.green);
          expect(expanded.text, 'Weekend');
          expect(expanded.recurrenceRule, isNull);
        });
      });

      group('COUNT limit respected', () {
        test('daily recurring with COUNT=5 stops after 5 occurrences', () {
          final region = MCalRegion(
            id: 'focus',
            start: DateTime(2026, 1, 1, 9, 0),
            end: DateTime(2026, 1, 1, 10, 0),
            recurrenceRule: MCalRecurrenceRule(
              frequency: MCalFrequency.daily,
              count: 5,
            ),
          );

          expect(region.expandedForDate(DateTime(2026, 1, 1)), isNotNull);
          expect(region.expandedForDate(DateTime(2026, 1, 2)), isNotNull);
          expect(region.expandedForDate(DateTime(2026, 1, 3)), isNotNull);
          expect(region.expandedForDate(DateTime(2026, 1, 4)), isNotNull);
          expect(region.expandedForDate(DateTime(2026, 1, 5)), isNotNull);
          expect(region.expandedForDate(DateTime(2026, 1, 6)), isNull);
        });
      });

      group('non-matching date returns null', () {
        test('date before anchor for recurring region', () {
          final region = MCalRegion(
            id: 'after-hours',
            start: DateTime(2026, 3, 1, 18, 0),
            end: DateTime(2026, 3, 1, 22, 0),
            recurrenceRule:
                MCalRecurrenceRule(frequency: MCalFrequency.daily),
          );

          expect(region.expandedForDate(DateTime(2026, 2, 28)), isNull);
        });

        test('weekly recurring on non-matching weekday', () {
          final region = MCalRegion(
            id: 'mondays',
            start: DateTime(2026, 1, 5, 9, 0), // Monday
            end: DateTime(2026, 1, 5, 9, 30),
            recurrenceRule: MCalRecurrenceRule(
              frequency: MCalFrequency.weekly,
              byWeekDays: {MCalWeekDay.every(DateTime.monday)},
            ),
          );

          // Jan 6, 2026 is a Tuesday
          expect(region.expandedForDate(DateTime(2026, 1, 6)), isNull);
        });
      });

      group('invalid recurrence rule', () {
        test('returns null gracefully', () {
          final region = MCalRegion(
            id: 'bad-rule',
            start: DateTime(2026, 1, 1, 9, 0),
            end: DateTime(2026, 1, 1, 10, 0),
            recurrenceRule: MCalRecurrenceRule(
              frequency: MCalFrequency.weekly,
              byWeekDays: {},
            ),
          );

          expect(
            () => region.expandedForDate(DateTime(2026, 2, 1)),
            returnsNormally,
          );
        });
      });
    });
  });
}
