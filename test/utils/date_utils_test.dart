import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/src/utils/date_utils.dart';

void main() {
  group('getMonthRange', () {
    test('returns correct range for January', () {
      final month = DateTime(2024, 1, 15);
      final range = getMonthRange(month);

      expect(range.start, DateTime(2024, 1, 1));
      expect(range.end, DateTime(2024, 1, 31, 23, 59, 59, 999));
    });

    test('returns correct range for February (non-leap year)', () {
      final month = DateTime(2023, 2, 15);
      final range = getMonthRange(month);

      expect(range.start, DateTime(2023, 2, 1));
      expect(range.end, DateTime(2023, 2, 28, 23, 59, 59, 999));
    });

    test('returns correct range for February (leap year)', () {
      final month = DateTime(2024, 2, 15);
      final range = getMonthRange(month);

      expect(range.start, DateTime(2024, 2, 1));
      expect(range.end, DateTime(2024, 2, 29, 23, 59, 59, 999));
    });

    test('returns correct range for December', () {
      final month = DateTime(2024, 12, 15);
      final range = getMonthRange(month);

      expect(range.start, DateTime(2024, 12, 1));
      expect(range.end, DateTime(2024, 12, 31, 23, 59, 59, 999));
    });
  });

  group('getPreviousMonthRange', () {
    test('handles normal month transition', () {
      final month = DateTime(2024, 3, 15);
      final range = getPreviousMonthRange(month);

      expect(range.start, DateTime(2024, 2, 1));
      expect(range.end, DateTime(2024, 2, 29, 23, 59, 59, 999)); // 2024 is leap year
    });

    test('handles year boundary (January -> December)', () {
      final month = DateTime(2024, 1, 15);
      final range = getPreviousMonthRange(month);

      expect(range.start, DateTime(2023, 12, 1));
      expect(range.end, DateTime(2023, 12, 31, 23, 59, 59, 999));
    });
  });

  group('getNextMonthRange', () {
    test('handles normal month transition', () {
      final month = DateTime(2024, 2, 15);
      final range = getNextMonthRange(month);

      expect(range.start, DateTime(2024, 3, 1));
      expect(range.end, DateTime(2024, 3, 31, 23, 59, 59, 999));
    });

    test('handles year boundary (December -> January)', () {
      final month = DateTime(2024, 12, 15);
      final range = getNextMonthRange(month);

      expect(range.start, DateTime(2025, 1, 1));
      expect(range.end, DateTime(2025, 1, 31, 23, 59, 59, 999));
    });
  });

  group('generateMonthDates', () {
    test('generates 35 or 42 dates depending on month layout', () {
      // January 2024 starts on Monday, needs 5 weeks
      final month = DateTime(2024, 1, 1);
      final dates = generateMonthDates(month, 0); // Sunday = 0

      // Can return 35 or 42 based on whether 6th row is needed
      expect(dates.length, anyOf(35, 42));
    });

    test('generates exactly 42 dates when showSixthRowIfNeeded is true', () {
      final month = DateTime(2024, 1, 1);
      final dates = generateMonthDates(month, 0, showSixthRowIfNeeded: true);

      expect(dates.length, 42);
    });

    test('includes leading dates from previous month', () {
      final month = DateTime(2024, 1, 1); // January 2024 starts on Monday
      final dates = generateMonthDates(month, 0); // Sunday = 0

      // First date should be from previous month (December 2023)
      expect(dates.first.year, 2023);
      expect(dates.first.month, 12);
    });

    test('includes trailing dates from next month', () {
      final month = DateTime(2024, 1, 1);
      final dates = generateMonthDates(month, 0);

      // Last date should be from next month (February 2024)
      expect(dates.last.year, 2024);
      expect(dates.last.month, 2);
    });

    test('respects firstDayOfWeek parameter (Sunday = 0)', () {
      final month = DateTime(2024, 1, 1); // Monday
      final dates = generateMonthDates(month, 0); // Sunday = 0

      // First day should be Sunday
      expect(dates.first.weekday % 7, 0); // Sunday
    });

    test('respects firstDayOfWeek parameter (Monday = 1)', () {
      final month = DateTime(2024, 1, 1); // Monday
      final dates = generateMonthDates(month, 1); // Monday = 1

      // First day should be Monday
      expect(dates.first.weekday % 7, 1); // Monday
    });

    test('handles February correctly', () {
      final month = DateTime(2024, 2, 1); // Leap year
      final dates = generateMonthDates(month, 0);

      // February 2024 starts on Thursday, needs 5 weeks
      expect(dates.length, 35);
      // Check that dates include January and March
      expect(dates.any((d) => d.month == 1), true);
      expect(dates.any((d) => d.month == 3), true);
    });

    test('handles February correctly with 6 weeks forced', () {
      final month = DateTime(2024, 2, 1); // Leap year
      final dates = generateMonthDates(month, 0, showSixthRowIfNeeded: true);

      expect(dates.length, 42);
      // Check that dates include January and March
      expect(dates.any((d) => d.month == 1), true);
      expect(dates.any((d) => d.month == 3), true);
    });

    test('handles year boundary correctly', () {
      final month = DateTime(2023, 12, 1);
      final dates = generateMonthDates(month, 0);

      // December 2023 starts on Friday, needs 6 weeks to show all days
      expect(dates.length, 42);
      // Check that dates include November 2023 and January 2024
      expect(dates.any((d) => d.month == 11 && d.year == 2023), true);
      expect(dates.any((d) => d.month == 1 && d.year == 2024), true);
    });

    test('returns 35 dates when 6th row not needed', () {
      // January 2026 starts on Thursday, only needs 5 weeks
      final month = DateTime(2026, 1, 1);
      final dates = generateMonthDates(month, 0);

      expect(dates.length, 35);
    });

    test('returns 42 dates when 6th row is needed', () {
      // March 2024 starts on Friday, needs 6 weeks
      final month = DateTime(2024, 3, 1);
      final dates = generateMonthDates(month, 0);

      expect(dates.length, 42);
    });

    test('all dates are consecutive', () {
      final month = DateTime(2024, 6, 1);
      final dates = generateMonthDates(month, 0);

      for (int i = 1; i < dates.length; i++) {
        final diff = dates[i].difference(dates[i - 1]).inDays;
        expect(diff, 1, reason: 'Dates should be consecutive');
      }
    });
  });

  group('getWeekNumber (Monday-start / ISO 8601)', () {
    group('standard weeks in middle of year', () {
      test('July 15, 2024 is Week 29 - typical mid-year date', () {
        final date = DateTime(2024, 7, 15);
        expect(getWeekNumber(date, DateTime.monday), 29);
      });

      test('June 1, 2024 is Week 22 - first day of June', () {
        final date = DateTime(2024, 6, 1);
        expect(getWeekNumber(date, DateTime.monday), 22);
      });

      test('August 20, 2024 is Week 34 - late summer date', () {
        final date = DateTime(2024, 8, 20);
        expect(getWeekNumber(date, DateTime.monday), 34);
      });
    });

    group('Week 1 - first week containing Thursday', () {
      test('2024-01-01 (Monday) is Week 1 - year starts on Monday', () {
        // When Jan 1 is a Monday, it's in Week 1 because that week
        // contains the first Thursday (Jan 4)
        final date = DateTime(2024, 1, 1);
        expect(date.weekday, DateTime.monday);
        expect(getWeekNumber(date, DateTime.monday), 1);
      });

      test('2024-01-04 (Thursday) is Week 1 - first Thursday of year', () {
        // The first Thursday of the year is always in Week 1
        final date = DateTime(2024, 1, 4);
        expect(date.weekday, DateTime.thursday);
        expect(getWeekNumber(date, DateTime.monday), 1);
      });

      test('2024-01-07 (Sunday) is Week 1 - last day of first week', () {
        // Sunday is the last day of Week 1 in 2024
        final date = DateTime(2024, 1, 7);
        expect(date.weekday, DateTime.sunday);
        expect(getWeekNumber(date, DateTime.monday), 1);
      });

      test('2024-01-08 (Monday) is Week 2 - first day of second week', () {
        // The Monday after Week 1 starts Week 2
        final date = DateTime(2024, 1, 8);
        expect(date.weekday, DateTime.monday);
        expect(getWeekNumber(date, DateTime.monday), 2);
      });
    });

    group('year boundary - December dates that are Week 1 of next year', () {
      test('2025-12-31 (Wednesday) is Week 1 - belongs to Week 1 of 2026', () {
        // Dec 31, 2025 is a Wednesday. Since Jan 1, 2026 is Thursday,
        // the week containing Dec 31 is Week 1 of 2026
        final date = DateTime(2025, 12, 31);
        expect(date.weekday, DateTime.wednesday);
        expect(getWeekNumber(date, DateTime.monday), 1);
      });

      test('2025-12-29 (Monday) is Week 1 - first day of Week 1 of 2026', () {
        // This Monday starts the week that contains the first Thursday of 2026
        final date = DateTime(2025, 12, 29);
        expect(date.weekday, DateTime.monday);
        expect(getWeekNumber(date, DateTime.monday), 1);
      });
    });

    group('year boundary - January dates that are last week of previous year',
        () {
      test('2023-01-01 (Sunday) is Week 52 - belongs to Week 52 of 2022', () {
        // Jan 1, 2023 is a Sunday, which is the last day of the week
        // that started in 2022 (Dec 26, 2022)
        final date = DateTime(2023, 1, 1);
        expect(date.weekday, DateTime.sunday);
        expect(getWeekNumber(date, DateTime.monday), 52);
      });

      test('2022-01-01 (Saturday) is Week 52 - belongs to Week 52 of 2021',
          () {
        // Jan 1, 2022 is a Saturday, part of the previous year's last week
        final date = DateTime(2022, 1, 1);
        expect(date.weekday, DateTime.saturday);
        expect(getWeekNumber(date, DateTime.monday), 52);
      });

      test('2022-01-02 (Sunday) is Week 52 - last day before Week 1 of 2022',
          () {
        // Jan 2, 2022 is Sunday, still part of Week 52 of 2021
        final date = DateTime(2022, 1, 2);
        expect(date.weekday, DateTime.sunday);
        expect(getWeekNumber(date, DateTime.monday), 52);
      });

      test('2022-01-03 (Monday) is Week 1 - first day of Week 1 of 2022', () {
        // Jan 3, 2022 is Monday, starts Week 1 of 2022
        final date = DateTime(2022, 1, 3);
        expect(date.weekday, DateTime.monday);
        expect(getWeekNumber(date, DateTime.monday), 1);
      });
    });

    group('Week 53 - years with 53 weeks', () {
      test('2020-12-31 (Thursday) is Week 53 - 2020 has 53 weeks', () {
        // 2020 is a leap year that started on Wednesday, so it has 53 weeks
        // Dec 31, 2020 is a Thursday, which is in Week 53
        final date = DateTime(2020, 12, 31);
        expect(date.weekday, DateTime.thursday);
        expect(getWeekNumber(date, DateTime.monday), 53);
      });

      test('2020-12-28 (Monday) is Week 53 - first day of Week 53 of 2020',
          () {
        // Dec 28, 2020 is Monday, the start of Week 53
        final date = DateTime(2020, 12, 28);
        expect(date.weekday, DateTime.monday);
        expect(getWeekNumber(date, DateTime.monday), 53);
      });

      test('2021-01-03 (Sunday) is Week 53 - last day of Week 53 of 2020', () {
        // Jan 3, 2021 is Sunday, still in Week 53 of 2020
        final date = DateTime(2021, 1, 3);
        expect(date.weekday, DateTime.sunday);
        expect(getWeekNumber(date, DateTime.monday), 53);
      });

      test('2021-01-04 (Monday) is Week 1 - first day of Week 1 of 2021', () {
        // After Week 53 of 2020, Week 1 of 2021 starts
        final date = DateTime(2021, 1, 4);
        expect(date.weekday, DateTime.monday);
        expect(getWeekNumber(date, DateTime.monday), 1);
      });
    });

    group('first Thursday rule', () {
      test('2026-01-01 (Thursday) is Week 1 - year starts on Thursday', () {
        // When Jan 1 falls on Thursday, it's automatically Week 1
        // because Week 1 is defined as the week containing the first Thursday
        final date = DateTime(2026, 1, 1);
        expect(date.weekday, DateTime.thursday);
        expect(getWeekNumber(date, DateTime.monday), 1);
      });

      test('2015-01-01 (Thursday) is Week 1 - another year starting Thursday',
          () {
        // Verify the same rule applies consistently
        final date = DateTime(2015, 1, 1);
        expect(date.weekday, DateTime.thursday);
        expect(getWeekNumber(date, DateTime.monday), 1);
      });

      test('2014-12-29 (Monday) is Week 1 - start of Week 1 of 2015', () {
        // The Monday before Jan 1, 2015 (Thursday) is in Week 1 of 2015
        final date = DateTime(2014, 12, 29);
        expect(date.weekday, DateTime.monday);
        expect(getWeekNumber(date, DateTime.monday), 1);
      });
    });

    group('edge cases for years with different starting days', () {
      test('year starting on Friday - Jan 1 is in previous year week', () {
        // 2027 starts on Friday, so Jan 1 is in Week 53 of 2026
        final date = DateTime(2027, 1, 1);
        expect(date.weekday, DateTime.friday);
        expect(getWeekNumber(date, DateTime.monday), 53);
      });

      test('year starting on Saturday - Jan 1 is in previous year week', () {
        // 2028 starts on Saturday, so Jan 1 is in Week 52 of 2027
        final date = DateTime(2028, 1, 1);
        expect(date.weekday, DateTime.saturday);
        expect(getWeekNumber(date, DateTime.monday), 52);
      });

      test('year starting on Tuesday - Jan 1 is in Week 1', () {
        // 2030 starts on Tuesday, which is still in Week 1
        final date = DateTime(2030, 1, 1);
        expect(date.weekday, DateTime.tuesday);
        expect(getWeekNumber(date, DateTime.monday), 1);
      });
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // getWeekNumber — unified, parameterised by firstDayOfWeek
  // ──────────────────────────────────────────────────────────────────────────

  group('getWeekNumber', () {
    group('Sunday-start (firstDayOfWeek=0)', () {
      // 2026 key dates: Jan 1 is Thursday. First Sunday on or before Jan 1 is
      // Dec 28, 2025 (anchor=Dec 31 in 2025) → week 1 starts Jan 4, 2026.

      test('Jan 4, 2026 (first Sunday of 2026) is week 1', () {
        expect(getWeekNumber(DateTime(2026, 1, 4), 0), 1);
      });

      test('Jan 3, 2026 (Saturday, last day of prev year\'s week) is week 53 of 2025', () {
        expect(getWeekNumber(DateTime(2026, 1, 3), 0), 53);
      });

      test('Feb 15, 2026 (Sunday starting the Feb 15-21 row) is week 7', () {
        expect(getWeekNumber(DateTime(2026, 2, 15), 0), 7);
      });

      test('Feb 19, 2026 (Thursday, same row) is also week 7', () {
        // Day View must agree with Month View for the same visual week.
        expect(getWeekNumber(DateTime(2026, 2, 19), 0), 7);
      });

      test('Feb 21, 2026 (Saturday, last day of that row) is also week 7', () {
        expect(getWeekNumber(DateTime(2026, 2, 21), 0), 7);
      });

      test('Feb 22, 2026 (next Sunday) is week 8', () {
        expect(getWeekNumber(DateTime(2026, 2, 22), 0), 8);
      });
    });

    group('Saturday-start (firstDayOfWeek=6)', () {
      // 2026: Jan 1 is Thursday. First Saturday on or before Jan 1 is Dec 27,
      // 2025 (anchor=Dec 30, in 2025) → week 1 starts Jan 3, 2026 (Saturday).

      test('Jan 3, 2026 (first Saturday of 2026 block) is week 1', () {
        expect(getWeekNumber(DateTime(2026, 1, 3), 6), 1);
      });

      test('Jan 2, 2026 (Friday, belongs to last week of 2025) is not week 1', () {
        final w = getWeekNumber(DateTime(2026, 1, 2), 6);
        expect(w, greaterThanOrEqualTo(52)); // last week of 2025
      });

      test('Feb 19, 2026 is in a consistent week for all days of that row', () {
        // The Saturday that starts this row is Feb 14.
        final rowWeek = getWeekNumber(DateTime(2026, 2, 14), 6);
        for (var d = 14; d <= 20; d++) {
          expect(getWeekNumber(DateTime(2026, 2, d), 6), rowWeek);
        }
      });
    });

    group('consistency: all days in a week share the same week number', () {
      for (final fdow in [0, 1, 6]) {
        test('firstDayOfWeek=$fdow — week of Feb 19, 2026', () {
          // Find the week start for Feb 19.
          final anchor = DateTime(2026, 2, 19);
          final weekNum = getWeekNumber(anchor, fdow);
          // Go 3 days back and 3 days forward and confirm same week number.
          for (var offset = -3; offset <= 3; offset++) {
            final d = anchor.add(Duration(days: offset));
            final n = getWeekNumber(d, fdow);
            // Days that share the same visual row share the same week number.
            // We only check the 7-day span anchored on the week start.
            final fDowIso = fdow == 0 ? 7 : fdow;
            final daysSinceStart = (anchor.weekday - fDowIso + 7) % 7;
            final weekStart = anchor.subtract(Duration(days: daysSinceStart));
            final daysFromStart = d.difference(weekStart).inDays;
            if (daysFromStart >= 0 && daysFromStart < 7) {
              expect(n, weekNum,
                  reason: 'fdow=$fdow offset=$offset date=$d');
            }
          }
        });
      }
    });
  });
}
