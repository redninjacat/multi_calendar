import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  group('MCalEventController Region Management', () {
    late MCalEventController controller;

    setUp(() {
      controller = MCalEventController();
    });

    // ================================================================
    // addRegions
    // ================================================================

    group('addRegions', () {
      test('adds regions and notifies listeners', () {
        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        final region = MCalRegion(
          id: 'r1',
          start: DateTime(2026, 3, 1),
          end: DateTime(2026, 3, 1),
          isAllDay: true,
        );

        controller.addRegions([region]);

        expect(controller.regions, hasLength(1));
        expect(controller.regions.first.id, 'r1');
        expect(notifyCount, 1);
      });

      test('upsert: adding region with same ID replaces existing', () {
        final original = MCalRegion(
          id: 'r1',
          start: DateTime(2026, 3, 1),
          end: DateTime(2026, 3, 1),
          isAllDay: true,
          text: 'Original',
        );
        final replacement = MCalRegion(
          id: 'r1',
          start: DateTime(2026, 3, 2),
          end: DateTime(2026, 3, 2),
          isAllDay: true,
          text: 'Replaced',
        );

        controller.addRegions([original]);
        controller.addRegions([replacement]);

        expect(controller.regions, hasLength(1));
        expect(controller.regions.first.text, 'Replaced');
        expect(controller.regions.first.start, DateTime(2026, 3, 2));
      });

      test('regions accessible via regions getter', () {
        controller.addRegions([
          MCalRegion(
            id: 'a',
            start: DateTime(2026, 3, 1),
            end: DateTime(2026, 3, 1),
            isAllDay: true,
          ),
          MCalRegion(
            id: 'b',
            start: DateTime(2026, 3, 2),
            end: DateTime(2026, 3, 2),
            isAllDay: true,
          ),
        ]);

        final ids = controller.regions.map((r) => r.id).toSet();
        expect(ids, containsAll(['a', 'b']));
        expect(controller.regions, hasLength(2));
      });
    });

    // ================================================================
    // removeRegions
    // ================================================================

    group('removeRegions', () {
      test('removes by ID and notifies listeners', () {
        controller.addRegions([
          MCalRegion(
            id: 'r1',
            start: DateTime(2026, 3, 1),
            end: DateTime(2026, 3, 1),
            isAllDay: true,
          ),
          MCalRegion(
            id: 'r2',
            start: DateTime(2026, 3, 2),
            end: DateTime(2026, 3, 2),
            isAllDay: true,
          ),
        ]);

        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.removeRegions(['r1']);

        expect(controller.regions, hasLength(1));
        expect(controller.regions.first.id, 'r2');
        expect(notifyCount, 1);
      });

      test('non-existent ID is harmless', () {
        controller.addRegions([
          MCalRegion(
            id: 'r1',
            start: DateTime(2026, 3, 1),
            end: DateTime(2026, 3, 1),
            isAllDay: true,
          ),
        ]);

        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.removeRegions(['does-not-exist']);

        expect(controller.regions, hasLength(1));
        expect(notifyCount, 1);
      });
    });

    // ================================================================
    // clearRegions
    // ================================================================

    group('clearRegions', () {
      test('clears all regions and notifies listeners', () {
        controller.addRegions([
          MCalRegion(
            id: 'r1',
            start: DateTime(2026, 3, 1),
            end: DateTime(2026, 3, 1),
            isAllDay: true,
          ),
          MCalRegion(
            id: 'r2',
            start: DateTime(2026, 3, 2),
            end: DateTime(2026, 3, 2),
            isAllDay: true,
          ),
        ]);

        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        controller.clearRegions();

        expect(controller.regions, isEmpty);
        expect(notifyCount, 1);
      });
    });

    // ================================================================
    // getRegionsForDate
    // ================================================================

    group('getRegionsForDate', () {
      test('returns both all-day and timed regions', () {
        final allDay = MCalRegion(
          id: 'allday',
          start: DateTime(2026, 3, 5),
          end: DateTime(2026, 3, 5),
          isAllDay: true,
        );
        final timed = MCalRegion(
          id: 'timed',
          start: DateTime(2026, 3, 5, 9, 0),
          end: DateTime(2026, 3, 5, 17, 0),
          isAllDay: false,
        );

        controller.addRegions([allDay, timed]);

        final results = controller.getRegionsForDate(DateTime(2026, 3, 5));
        final ids = results.map((r) => r.id).toSet();

        expect(results, hasLength(2));
        expect(ids, contains('allday'));
        expect(ids, contains('timed'));
      });

      test('consumer can filter by isAllDay', () {
        controller.addRegions([
          MCalRegion(
            id: 'allday',
            start: DateTime(2026, 3, 5),
            end: DateTime(2026, 3, 5),
            isAllDay: true,
          ),
          MCalRegion(
            id: 'timed',
            start: DateTime(2026, 3, 5, 9, 0),
            end: DateTime(2026, 3, 5, 17, 0),
            isAllDay: false,
          ),
        ]);

        final results = controller.getRegionsForDate(DateTime(2026, 3, 5));
        final allDayRegions = results.where((r) => r.isAllDay).toList();
        final timedRegions = results.where((r) => !r.isAllDay).toList();

        expect(allDayRegions, hasLength(1));
        expect(timedRegions, hasLength(1));
      });

      test('recurring regions expanded correctly', () {
        final weekendRegion = MCalRegion(
          id: 'weekends',
          start: DateTime(2026, 3, 1),
          end: DateTime(2026, 3, 1),
          isAllDay: true,
          recurrenceRule: MCalRecurrenceRule(
            frequency: MCalFrequency.weekly,
            byWeekDays: {
              MCalWeekDay.every(DateTime.saturday),
              MCalWeekDay.every(DateTime.sunday),
            },
          ),
        );

        controller.addRegions([weekendRegion]);

        // March 7, 2026 is a Saturday
        final satResults = controller.getRegionsForDate(DateTime(2026, 3, 7));
        expect(satResults, hasLength(1));

        // March 8, 2026 is a Sunday
        final sunResults = controller.getRegionsForDate(DateTime(2026, 3, 8));
        expect(sunResults, hasLength(1));

        // March 9, 2026 is a Monday — should not match
        final monResults = controller.getRegionsForDate(DateTime(2026, 3, 9));
        expect(monResults, isEmpty);
      });

      test('non-matching date returns empty', () {
        controller.addRegions([
          MCalRegion(
            id: 'r1',
            start: DateTime(2026, 3, 1),
            end: DateTime(2026, 3, 1),
            isAllDay: true,
          ),
        ]);

        final results = controller.getRegionsForDate(DateTime(2026, 4, 1));
        expect(results, isEmpty);
      });

      test('returns expanded instances (adjusted dates)', () {
        final timedRecurring = MCalRegion(
          id: 'daily-block',
          start: DateTime(2026, 3, 1, 12, 0),
          end: DateTime(2026, 3, 1, 13, 0),
          isAllDay: false,
          recurrenceRule: MCalRecurrenceRule(
            frequency: MCalFrequency.daily,
          ),
        );

        controller.addRegions([timedRecurring]);

        final results = controller.getRegionsForDate(DateTime(2026, 3, 10));
        expect(results, hasLength(1));

        final expanded = results.first;
        expect(expanded.start, DateTime(2026, 3, 10, 12, 0));
        expect(expanded.end, DateTime(2026, 3, 10, 13, 0));
      });
    });

    // ================================================================
    // isDateBlocked
    // ================================================================

    group('isDateBlocked', () {
      test('returns true for blocked all-day region', () {
        controller.addRegions([
          MCalRegion(
            id: 'blocked',
            start: DateTime(2026, 3, 5),
            end: DateTime(2026, 3, 5),
            isAllDay: true,
            blockInteraction: true,
          ),
        ]);

        expect(controller.isDateBlocked(DateTime(2026, 3, 5)), isTrue);
      });

      test('returns false for non-blocking region', () {
        controller.addRegions([
          MCalRegion(
            id: 'visual-only',
            start: DateTime(2026, 3, 5),
            end: DateTime(2026, 3, 5),
            isAllDay: true,
            blockInteraction: false,
          ),
        ]);

        expect(controller.isDateBlocked(DateTime(2026, 3, 5)), isFalse);
      });

      test('works with recurring all-day regions', () {
        controller.addRegions([
          MCalRegion(
            id: 'weekends-blocked',
            start: DateTime(2026, 3, 1),
            end: DateTime(2026, 3, 1),
            isAllDay: true,
            blockInteraction: true,
            recurrenceRule: MCalRecurrenceRule(
              frequency: MCalFrequency.weekly,
              byWeekDays: {
                MCalWeekDay.every(DateTime.saturday),
                MCalWeekDay.every(DateTime.sunday),
              },
            ),
          ),
        ]);

        // March 7 is Saturday, March 8 is Sunday
        expect(controller.isDateBlocked(DateTime(2026, 3, 7)), isTrue);
        expect(controller.isDateBlocked(DateTime(2026, 3, 8)), isTrue);

        // March 9 is Monday
        expect(controller.isDateBlocked(DateTime(2026, 3, 9)), isFalse);
      });
    });

    // ================================================================
    // isTimeRangeBlocked
    // ================================================================

    group('isTimeRangeBlocked', () {
      test('returns true for overlapping timed blocking region', () {
        controller.addRegions([
          MCalRegion(
            id: 'lunch',
            start: DateTime(2026, 3, 5, 12, 0),
            end: DateTime(2026, 3, 5, 13, 0),
            isAllDay: false,
            blockInteraction: true,
          ),
        ]);

        expect(
          controller.isTimeRangeBlocked(
            DateTime(2026, 3, 5, 12, 30),
            DateTime(2026, 3, 5, 13, 30),
          ),
          isTrue,
        );
      });

      test('returns false for non-overlapping', () {
        controller.addRegions([
          MCalRegion(
            id: 'lunch',
            start: DateTime(2026, 3, 5, 12, 0),
            end: DateTime(2026, 3, 5, 13, 0),
            isAllDay: false,
            blockInteraction: true,
          ),
        ]);

        expect(
          controller.isTimeRangeBlocked(
            DateTime(2026, 3, 5, 14, 0),
            DateTime(2026, 3, 5, 15, 0),
          ),
          isFalse,
        );
      });

      test('returns false for non-blocking region', () {
        controller.addRegions([
          MCalRegion(
            id: 'visual',
            start: DateTime(2026, 3, 5, 12, 0),
            end: DateTime(2026, 3, 5, 13, 0),
            isAllDay: false,
            blockInteraction: false,
          ),
        ]);

        expect(
          controller.isTimeRangeBlocked(
            DateTime(2026, 3, 5, 12, 30),
            DateTime(2026, 3, 5, 13, 30),
          ),
          isFalse,
        );
      });

      test('cross-view scenario: weekly recurring timed blocking region', () {
        final monday = DateTime(2026, 3, 2); // March 2, 2026 is a Monday
        final tuesday = DateTime(2026, 3, 3);

        controller.addRegions([
          MCalRegion(
            id: 'monday-block',
            start: DateTime(monday.year, monday.month, monday.day, 14, 0),
            end: DateTime(monday.year, monday.month, monday.day, 17, 0),
            isAllDay: false,
            blockInteraction: true,
            recurrenceRule: MCalRecurrenceRule(
              frequency: MCalFrequency.weekly,
              byWeekDays: {MCalWeekDay.every(DateTime.monday)},
            ),
          ),
        ]);

        final monday3pm = DateTime(monday.year, monday.month, monday.day, 15, 0);
        final monday4pm = DateTime(monday.year, monday.month, monday.day, 16, 0);
        expect(
          controller.isTimeRangeBlocked(monday3pm, monday4pm),
          isTrue,
          reason: 'Monday 3–4 PM falls within the Monday 2–5 PM block',
        );

        final tuesday3pm =
            DateTime(tuesday.year, tuesday.month, tuesday.day, 15, 0);
        final tuesday4pm =
            DateTime(tuesday.year, tuesday.month, tuesday.day, 16, 0);
        expect(
          controller.isTimeRangeBlocked(tuesday3pm, tuesday4pm),
          isFalse,
          reason: 'Tuesday is not a blocked day',
        );

        final monday1pm = DateTime(monday.year, monday.month, monday.day, 13, 0);
        final monday2pm = DateTime(monday.year, monday.month, monday.day, 14, 0);
        expect(
          controller.isTimeRangeBlocked(monday1pm, monday2pm),
          isFalse,
          reason: 'Monday 1–2 PM is before the blocked range (half-open)',
        );
      });
    });
  });
}
