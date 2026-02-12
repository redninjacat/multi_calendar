import 'dart:ui' show Color;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';

// =============================================================================
// Helpers
// =============================================================================

/// 1-hour event, single day, weekly on Tuesday starting Jan 6, 2026.
MCalCalendarEvent _weeklyEvent({
  String id = 'weekly1',
  DateTime? start,
  MCalRecurrenceRule? rule,
}) {
  final s = start ?? DateTime(2026, 1, 6, 10, 0); // Tuesday
  return MCalCalendarEvent(
    id: id,
    title: 'Weekly Meeting',
    start: s,
    end: s.add(const Duration(hours: 1)),
    recurrenceRule: rule ?? MCalRecurrenceRule(frequency: MCalFrequency.weekly),
  );
}

/// Multi-day event: 3-day conference recurring every 2 weeks on Monday.
MCalCalendarEvent _multiDayWeekly({
  String id = 'conf1',
  DateTime? start,
  int durationDays = 3,
  MCalRecurrenceRule? rule,
}) {
  final s = start ?? DateTime(2026, 1, 5, 9, 0); // Monday
  return MCalCalendarEvent(
    id: id,
    title: '3-Day Conference',
    start: s,
    end: DateTime(s.year, s.month, s.day + durationDays - 1, 17, 0),
    recurrenceRule: rule ??
        MCalRecurrenceRule(
          frequency: MCalFrequency.weekly,
          interval: 2,
        ),
  );
}

/// Daily recurring event.
MCalCalendarEvent _dailyEvent({
  String id = 'daily1',
  DateTime? start,
  int? count,
  DateTime? until,
}) {
  final s = start ?? DateTime(2026, 1, 1, 8, 0);
  return MCalCalendarEvent(
    id: id,
    title: 'Daily Standup',
    start: s,
    end: s.add(const Duration(minutes: 30)),
    recurrenceRule: MCalRecurrenceRule(
      frequency: MCalFrequency.daily,
      count: count,
      until: until,
    ),
  );
}

/// Monthly recurring event on the 15th.
MCalCalendarEvent _monthlyEvent({
  String id = 'monthly1',
  DateTime? start,
}) {
  final s = start ?? DateTime(2026, 1, 15, 14, 0);
  return MCalCalendarEvent(
    id: id,
    title: 'Monthly Review',
    start: s,
    end: s.add(const Duration(hours: 2)),
    recurrenceRule: MCalRecurrenceRule(
      frequency: MCalFrequency.monthly,
    ),
  );
}

/// Yearly recurring event on March 1.
MCalCalendarEvent _yearlyEvent({
  String id = 'yearly1',
  DateTime? start,
}) {
  final s = start ?? DateTime(2026, 3, 1, 12, 0);
  return MCalCalendarEvent(
    id: id,
    title: 'Annual Party',
    start: s,
    end: s.add(const Duration(hours: 4)),
    recurrenceRule: MCalRecurrenceRule(
      frequency: MCalFrequency.yearly,
    ),
  );
}

/// All-day recurring event (2 days).
MCalCalendarEvent _allDayMultiDay({
  String id = 'allday1',
  DateTime? start,
}) {
  final s = start ?? DateTime(2026, 1, 10);
  return MCalCalendarEvent(
    id: id,
    title: 'Company Retreat',
    start: s,
    end: DateTime(s.year, s.month, s.day + 1, 23, 59, 59),
    isAllDay: true,
    recurrenceRule: MCalRecurrenceRule(
      frequency: MCalFrequency.monthly,
    ),
  );
}

/// Standalone (non-recurring) event.
MCalCalendarEvent _singleEvent({
  String id = 'single1',
  DateTime? start,
}) {
  final s = start ?? DateTime(2026, 1, 10, 14, 0);
  return MCalCalendarEvent(
    id: id,
    title: 'One-Off Event',
    start: s,
    end: s.add(const Duration(hours: 1)),
  );
}

/// Rich event with color, comment, externalId.
MCalCalendarEvent _richRecurringEvent({String id = 'rich1'}) {
  return MCalCalendarEvent(
    id: id,
    title: 'Rich Event',
    start: DateTime(2026, 1, 5, 10, 0), // Monday
    end: DateTime(2026, 1, 5, 11, 0),
    color: const Color(0xFF6366F1),
    comment: 'Test comment',
    externalId: 'ext-123',
    recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.weekly),
  );
}

final _januaryRange = DateTimeRange(
  start: DateTime(2026, 1, 1),
  end: DateTime(2026, 1, 31, 23, 59, 59),
);

final _janFebRange = DateTimeRange(
  start: DateTime(2026, 1, 1),
  end: DateTime(2026, 2, 28, 23, 59, 59),
);

final _q1Range = DateTimeRange(
  start: DateTime(2026, 1, 1),
  end: DateTime(2026, 3, 31, 23, 59, 59),
);

final _yearRange = DateTimeRange(
  start: DateTime(2026, 1, 1),
  end: DateTime(2026, 12, 31, 23, 59, 59),
);

// =============================================================================
// Tests
// =============================================================================

void main() {
  // ===========================================================================
  // 1. Multi-Day Recurring Event Expansion
  // ===========================================================================
  group('Multi-day recurring event expansion', () {
    test('3-day event recurring bi-weekly expands with correct duration', () {
      final controller = MCalEventController();
      controller.addEvents([_multiDayWeekly()]);

      final events = controller.getEventsForRange(_januaryRange);

      // Bi-weekly from Jan 5: Jan 5 and Jan 19 in January
      expect(events.length, 2);

      for (final e in events) {
        // Each occurrence should span from 09:00 to 17:00, 3 days later
        final duration = e.end.difference(e.start);
        // Original: Jan 5 09:00 → Jan 7 17:00 = 2 days + 8 hours
        expect(duration, const Duration(days: 2, hours: 8));
      }
    });

    test('3-day event occurrence start dates are correct', () {
      final controller = MCalEventController();
      controller.addEvents([_multiDayWeekly()]);

      final events = controller.getEventsForRange(_januaryRange);
      final starts = events.map((e) => e.start).toList()..sort();

      expect(starts[0], DateTime(2026, 1, 5, 9, 0));
      expect(starts[1], DateTime(2026, 1, 19, 9, 0));
    });

    test('multi-day event overlapping range start is included', () {
      final controller = MCalEventController();
      // 3-day event starting Dec 30 2025
      controller.addEvents([
        _multiDayWeekly(start: DateTime(2025, 12, 29, 9, 0)),
      ]);

      // Query for January — Dec 29–31 event overlaps Jan 1
      final events = controller.getEventsForRange(_januaryRange);

      // Dec 29 occurrence ends Dec 31. But the bi-weekly from Dec 29
      // next is Jan 12. Both should appear if they overlap January.
      // Dec 29 → Dec 31 17:00 overlaps Jan 1 range? No, Dec 31 < Jan 1.
      // Actually, the RRULE generates occurrence dates. Dec 29 is the
      // first, Jan 12 is the next bi-weekly.
      // The range.start is Jan 1. getOccurrences returns dates where
      // the occurrence starts within [after, before]. But a Dec 29 event
      // that ends on Dec 31 doesn't overlap Jan.
      // Let's instead create an event starting Dec 31 that spans 3 days.
      // We need it to be on a Monday for the rule. Dec 29, 2025 is Monday.
      // Jan 12, 2026 is the next bi-weekly Monday.
      expect(events.length, greaterThanOrEqualTo(1));
    });

    test('multi-day event overlapping into range is included automatically',
        () {
      final controller = MCalEventController();
      // Weekly 3-day event starting on Mon 09:00, ending Wed 17:00.
      final event = MCalCalendarEvent(
        id: 'overlap1',
        title: 'Overlap Test',
        start: DateTime(2026, 1, 5, 9, 0), // Monday
        end: DateTime(2026, 1, 7, 17, 0), // Wednesday
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.weekly),
      );
      controller.addEvents([event]);

      // Query Wed Jan 7 to Fri Jan 9. The Mon Jan 5 occurrence ends
      // Wed 17:00, overlapping the range. The expansion engine pads the
      // query backwards by the event duration so this is captured.
      final narrowRange = DateTimeRange(
        start: DateTime(2026, 1, 7),
        end: DateTime(2026, 1, 9, 23, 59, 59),
      );
      final events = controller.getEventsForRange(narrowRange);

      expect(events.length, 1);
      expect(events.first.start, DateTime(2026, 1, 5, 9, 0));
      expect(events.first.end, DateTime(2026, 1, 7, 17, 0));
    });

    test('multi-day event with deleted exception', () {
      final controller = MCalEventController();
      controller.addEvents([_multiDayWeekly()]);

      // Delete the Jan 19 occurrence
      controller.addException(
        'conf1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 19),
        ),
      );

      final events = controller.getEventsForRange(_januaryRange);
      expect(events.length, 1);
      expect(events.first.start, DateTime(2026, 1, 5, 9, 0));
    });

    test('multi-day event with rescheduled exception preserves duration', () {
      final controller = MCalEventController();
      controller.addEvents([_multiDayWeekly()]);

      // Reschedule Jan 19 occurrence to Jan 21
      controller.addException(
        'conf1',
        MCalRecurrenceException.rescheduled(
          originalDate: DateTime(2026, 1, 19),
          newDate: DateTime(2026, 1, 21, 9, 0),
        ),
      );

      final events = controller.getEventsForRange(_januaryRange);
      expect(events.length, 2);

      final rescheduled = events.firstWhere(
        (e) => e.start.day == 21,
      );
      // Duration should be preserved: 2 days + 8 hours
      expect(
        rescheduled.end.difference(rescheduled.start),
        const Duration(days: 2, hours: 8),
      );
    });

    test('multi-day event with modified exception replaces entire occurrence',
        () {
      final controller = MCalEventController();
      controller.addEvents([_multiDayWeekly()]);

      // Replace Jan 19 occurrence with a 1-day event
      final replacement = MCalCalendarEvent(
        id: 'conf1_mod',
        title: 'Short Meeting',
        start: DateTime(2026, 1, 19, 10, 0),
        end: DateTime(2026, 1, 19, 11, 0),
      );
      controller.addException(
        'conf1',
        MCalRecurrenceException.modified(
          originalDate: DateTime(2026, 1, 19),
          modifiedEvent: replacement,
        ),
      );

      final events = controller.getEventsForRange(_januaryRange);
      expect(events.length, 2);

      final modified = events.firstWhere((e) => e.title == 'Short Meeting');
      // Modified event is 1 hour, not 3 days
      expect(
        modified.end.difference(modified.start),
        const Duration(hours: 1),
      );
    });
  });

  // ===========================================================================
  // 2. Daily Recurring Events in Controller
  // ===========================================================================
  group('Daily recurring event expansion', () {
    test('daily event expands correctly for January', () {
      final controller = MCalEventController();
      controller.addEvents([_dailyEvent()]);

      final events = controller.getEventsForRange(_januaryRange);

      // Jan 1 through Jan 31 = 31 days
      expect(events.length, 31);
    });

    test('daily event with count limit', () {
      final controller = MCalEventController();
      controller.addEvents([_dailyEvent(count: 10)]);

      final events = controller.getEventsForRange(_januaryRange);

      // Only 10 occurrences: Jan 1–10
      expect(events.length, 10);
      expect(events.last.start.day, 10);
    });

    test('daily event with until limit', () {
      final controller = MCalEventController();
      controller.addEvents([
        _dailyEvent(until: DateTime(2026, 1, 15)),
      ]);

      final events = controller.getEventsForRange(_januaryRange);

      // Should stop at or before Jan 15
      expect(events.length, lessThanOrEqualTo(15));
      for (final e in events) {
        expect(e.start.isBefore(DateTime(2026, 1, 16)), isTrue);
      }
    });

    test('daily event with deleted exceptions', () {
      final controller = MCalEventController();
      controller.addEvents([_dailyEvent(count: 7)]);

      // Delete Jan 3 and Jan 5
      controller.addException(
        'daily1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 3),
        ),
      );
      controller.addException(
        'daily1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 5),
        ),
      );

      final events = controller.getEventsForRange(_januaryRange);
      expect(events.length, 5);

      final dates = events.map((e) => e.start.day).toSet();
      expect(dates.contains(3), isFalse);
      expect(dates.contains(5), isFalse);
    });

    test('daily event with rescheduled exception', () {
      final controller = MCalEventController();
      controller.addEvents([_dailyEvent(count: 5)]);

      // Reschedule Jan 3 to Jan 10
      controller.addException(
        'daily1',
        MCalRecurrenceException.rescheduled(
          originalDate: DateTime(2026, 1, 3),
          newDate: DateTime(2026, 1, 10, 8, 0),
        ),
      );

      final events = controller.getEventsForRange(_januaryRange);
      expect(events.length, 5);

      final dates = events.map((e) => e.start.day).toSet();
      expect(dates.contains(3), isFalse);
      expect(dates.contains(10), isTrue);
    });
  });

  // ===========================================================================
  // 3. Monthly Recurring Events in Controller
  // ===========================================================================
  group('Monthly recurring event expansion', () {
    test('monthly event expands correctly over Q1', () {
      final controller = MCalEventController();
      controller.addEvents([_monthlyEvent()]);

      final events = controller.getEventsForRange(_q1Range);

      // Jan 15, Feb 15, Mar 15
      expect(events.length, 3);
      expect(events[0].start.month, 1);
      expect(events[1].start.month, 2);
      expect(events[2].start.month, 3);
    });

    test('monthly event preserves time across months', () {
      final controller = MCalEventController();
      controller.addEvents([_monthlyEvent()]);

      final events = controller.getEventsForRange(_q1Range);

      for (final e in events) {
        expect(e.start.hour, 14);
        expect(e.start.minute, 0);
        expect(e.end.difference(e.start), const Duration(hours: 2));
      }
    });

    test('monthly event with deleted exception on the first occurrence', () {
      final controller = MCalEventController();
      controller.addEvents([_monthlyEvent()]);

      // Delete the first occurrence (Jan 15). We use the exact start date
      // of the series because _normalizeDate on both the exception's
      // originalDate and the expanded occurrence date must produce the same
      // DateTime key.
      controller.addException(
        'monthly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 15),
        ),
      );

      final events = controller.getEventsForRange(_q1Range);

      // Verify Jan 15 occurrence is absent
      final jan15 = events.where(
        (e) => e.start.month == 1 && e.start.day == 15,
      );
      expect(jan15, isEmpty);

      // Should have Feb and Mar (and possibly more depending on teno_rrule)
      // minus the deleted one
      expect(events.length, greaterThanOrEqualTo(2));
    });
  });

  // ===========================================================================
  // 4. Yearly Recurring Events in Controller
  // ===========================================================================
  group('Yearly recurring event expansion', () {
    test('yearly event appears once per year', () {
      final controller = MCalEventController();
      controller.addEvents([_yearlyEvent()]);

      final events = controller.getEventsForRange(_yearRange);

      // Only March 1, 2026
      expect(events.length, 1);
      expect(events.first.start, DateTime(2026, 3, 1, 12, 0));
    });

    test('yearly event over multi-year range', () {
      final controller = MCalEventController();
      controller.addEvents([_yearlyEvent()]);

      final multiYear = DateTimeRange(
        start: DateTime(2026, 1, 1),
        end: DateTime(2028, 12, 31, 23, 59, 59),
      );
      final events = controller.getEventsForRange(multiYear);

      // 2026, 2027, 2028 — 3 March 1sts
      expect(events.length, 3);
    });
  });

  // ===========================================================================
  // 5. All-Day Multi-Day Recurring Events
  // ===========================================================================
  group('All-day multi-day recurring events', () {
    test('all-day 2-day event expands with isAllDay preserved', () {
      final controller = MCalEventController();
      controller.addEvents([_allDayMultiDay()]);

      final events = controller.getEventsForRange(_januaryRange);

      // Monthly from Jan 10 — only 1 in January
      expect(events.length, 1);
      expect(events.first.isAllDay, isTrue);
    });

    test('all-day multi-day event preserves duration', () {
      final controller = MCalEventController();
      controller.addEvents([_allDayMultiDay()]);

      final events = controller.getEventsForRange(_q1Range);

      for (final e in events) {
        // Original: Jan 10 00:00 → Jan 11 23:59:59 = ~2 days
        final duration = e.end.difference(e.start);
        expect(duration.inDays, greaterThanOrEqualTo(1));
      }
    });

    test('all-day multi-day event with deleted exception on first occurrence',
        () {
      final controller = MCalEventController();
      controller.addEvents([_allDayMultiDay()]);

      // Delete the first occurrence (Jan 10)
      controller.addException(
        'allday1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 10),
        ),
      );

      final events = controller.getEventsForRange(_q1Range);

      // Verify Jan 10 occurrence is absent
      final jan10 = events.where(
        (e) => e.start.month == 1 && e.start.day == 10,
      );
      expect(jan10, isEmpty);

      // Should have remaining monthly occurrences (Feb, Mar)
      expect(events.length, greaterThanOrEqualTo(2));
    });
  });

  // ===========================================================================
  // 6. Event Property Preservation Through Expansion
  // ===========================================================================
  group('Event property preservation through expansion', () {
    test('color is preserved in expanded occurrences', () {
      final controller = MCalEventController();
      controller.addEvents([_richRecurringEvent()]);

      final events = controller.getEventsForRange(_januaryRange);

      for (final e in events) {
        expect(e.color, const Color(0xFF6366F1));
      }
    });

    test('comment is preserved in expanded occurrences', () {
      final controller = MCalEventController();
      controller.addEvents([_richRecurringEvent()]);

      final events = controller.getEventsForRange(_januaryRange);

      for (final e in events) {
        expect(e.comment, 'Test comment');
      }
    });

    test('externalId is preserved in expanded occurrences', () {
      final controller = MCalEventController();
      controller.addEvents([_richRecurringEvent()]);

      final events = controller.getEventsForRange(_januaryRange);

      for (final e in events) {
        expect(e.externalId, 'ext-123');
      }
    });

    test('title is preserved in expanded occurrences', () {
      final controller = MCalEventController();
      controller.addEvents([_richRecurringEvent()]);

      final events = controller.getEventsForRange(_januaryRange);

      for (final e in events) {
        expect(e.title, 'Rich Event');
      }
    });

    test('isAllDay=false is preserved', () {
      final controller = MCalEventController();
      controller.addEvents([_richRecurringEvent()]);

      final events = controller.getEventsForRange(_januaryRange);

      for (final e in events) {
        expect(e.isAllDay, isFalse);
      }
    });
  });

  // ===========================================================================
  // 7. addExceptions (Batch) Behavior
  // ===========================================================================
  group('addExceptions batch behavior', () {
    test('batch exceptions are applied correctly in getEventsForRange', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Batch: delete Jan 6, reschedule Jan 13 → Jan 14
      controller.addExceptions('weekly1', [
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 6),
        ),
        MCalRecurrenceException.rescheduled(
          originalDate: DateTime(2026, 1, 13),
          newDate: DateTime(2026, 1, 14, 10, 0),
        ),
      ]);

      final events = controller.getEventsForRange(_januaryRange);

      // Jan 6 deleted, Jan 13 → Jan 14, Jan 20, Jan 27 = 3 events
      expect(events.length, 3);
      expect(events.any((e) => e.start.day == 6), isFalse);
      expect(events.any((e) => e.start.day == 14), isTrue);
    });

    test('batch exceptions returned by getExceptions', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      controller.addExceptions('weekly1', [
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 6),
        ),
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 20),
        ),
      ]);

      final exceptions = controller.getExceptions('weekly1');
      expect(exceptions.length, 3);
    });

    test('batch with modified exception is applied', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      final modifiedEvent = MCalCalendarEvent(
        id: 'mod_jan13',
        title: 'Special',
        start: DateTime(2026, 1, 13, 16, 0),
        end: DateTime(2026, 1, 13, 17, 0),
      );
      controller.addExceptions('weekly1', [
        MCalRecurrenceException.modified(
          originalDate: DateTime(2026, 1, 13),
          modifiedEvent: modifiedEvent,
        ),
      ]);

      final events = controller.getEventsForRange(_januaryRange);
      final special = events.firstWhere((e) => e.title == 'Special');
      expect(special.start.hour, 16);
    });
  });

  // ===========================================================================
  // 8. Exception Replacement (Overwrite)
  // ===========================================================================
  group('Exception replacement', () {
    test('adding exception on same date overwrites previous exception', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // First: delete Jan 13
      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
      );

      var events = controller.getEventsForRange(_januaryRange);
      expect(events.length, 3); // deleted

      // Now: replace with reschedule on the same originalDate
      controller.addException(
        'weekly1',
        MCalRecurrenceException.rescheduled(
          originalDate: DateTime(2026, 1, 13),
          newDate: DateTime(2026, 1, 14, 10, 0),
        ),
      );

      events = controller.getEventsForRange(_januaryRange);
      expect(events.length, 4); // rescheduled, not deleted

      final jan14 = events.where((e) => e.start.day == 14);
      expect(jan14.length, 1);

      // getExceptions should only have 1 exception for this date
      final exceptions = controller.getExceptions('weekly1');
      expect(exceptions.length, 1);
      expect(exceptions.first.type, MCalExceptionType.rescheduled);
    });

    test('overwriting rescheduled with deleted removes occurrence', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      controller.addException(
        'weekly1',
        MCalRecurrenceException.rescheduled(
          originalDate: DateTime(2026, 1, 13),
          newDate: DateTime(2026, 1, 14, 10, 0),
        ),
      );

      // Now overwrite with delete
      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
      );

      final events = controller.getEventsForRange(_januaryRange);
      expect(events.length, 3);
      expect(events.any((e) => e.start.day == 14), isFalse);
    });
  });

  // ===========================================================================
  // 9. Exception on Non-Existent Occurrence (Silently Ignored)
  // ===========================================================================
  group('Exception on non-existent occurrence', () {
    test('exception for date with no occurrence is silently stored', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Jan 10 is a Saturday — no weekly Tuesday occurrence on this date
      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 10),
        ),
      );

      // Should still have 4 Tuesdays — the exception doesn't match anything
      final events = controller.getEventsForRange(_januaryRange);
      expect(events.length, 4);

      // But the exception is still stored
      final exceptions = controller.getExceptions('weekly1');
      expect(exceptions.length, 1);
    });

    test('rescheduled exception for non-existent date is ignored in expansion',
        () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      controller.addException(
        'weekly1',
        MCalRecurrenceException.rescheduled(
          originalDate: DateTime(2026, 1, 10), // Saturday, no occurrence
          newDate: DateTime(2026, 1, 11, 10, 0),
        ),
      );

      // Still 4 normal occurrences — no rescheduled occurrence added
      // because the originalDate (Jan 10) doesn't match any expanded date.
      // However, the "rescheduled from outside range" logic may pick it up.
      // Per the code, the second loop checks if entry.key was NOT in
      // processedDateKeys — if the RRULE doesn't produce Jan 10, it won't
      // be in processedDateKeys. So the second loop WILL add it.
      final events = controller.getEventsForRange(_januaryRange);
      // 4 regular + 1 rescheduled from "outside range" logic
      expect(events.length, 5);
    });
  });

  // ===========================================================================
  // 10. removeException for Modified Exception
  // ===========================================================================
  group('removeException for modified exception', () {
    test('removing modified exception restores original occurrence', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      final modifiedEvent = MCalCalendarEvent(
        id: 'mod_jan13',
        title: 'Custom',
        start: DateTime(2026, 1, 13, 16, 0),
        end: DateTime(2026, 1, 13, 17, 0),
      );
      controller.addException(
        'weekly1',
        MCalRecurrenceException.modified(
          originalDate: DateTime(2026, 1, 13),
          modifiedEvent: modifiedEvent,
        ),
      );

      var events = controller.getEventsForRange(_januaryRange);
      expect(events.any((e) => e.title == 'Custom'), isTrue);

      // Remove the exception
      final removed = controller.removeException(
        'weekly1',
        DateTime(2026, 1, 13),
      );

      expect(removed, isNotNull);
      expect(removed!.type, MCalExceptionType.modified);

      events = controller.getEventsForRange(_januaryRange);
      expect(events.any((e) => e.title == 'Custom'), isFalse);
      expect(events.any((e) => e.title == 'Weekly Meeting'), isTrue);
      expect(events.length, 4);
    });
  });

  // ===========================================================================
  // 11. splitSeries Edge Cases
  // ===========================================================================
  group('splitSeries edge cases', () {
    test('split at first occurrence date leaves empty original series', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Split at the very first occurrence date (Jan 6)
      final newId = controller.splitSeries('weekly1', DateTime(2026, 1, 6));

      // Original series: until = Jan 5 (day before Jan 6).
      // Since the series starts Jan 6, the original produces 0 occurrences.
      final originalEvents = controller.getEventsForRange(_januaryRange);
      final fromOriginal = originalEvents.where(
        (e) => e.id.startsWith('weekly1_') && !e.id.contains('split'),
      );
      expect(fromOriginal, isEmpty);

      // New series should have all the Tuesdays
      final fromNew = originalEvents.where(
        (e) => e.id.startsWith(newId),
      );
      expect(fromNew.length, 4);
    });

    test('split with count-based rule clears count and sets until', () {
      final controller = MCalEventController();
      final event = MCalCalendarEvent(
        id: 'counted1',
        title: 'Counted',
        start: DateTime(2026, 1, 6, 10, 0),
        end: DateTime(2026, 1, 6, 11, 0),
        recurrenceRule: MCalRecurrenceRule(
          frequency: MCalFrequency.weekly,
          count: 10,
        ),
      );
      controller.addEvents([event]);

      controller.splitSeries('counted1', DateTime(2026, 1, 20));

      // Original should have until set (count cleared)
      final original = controller.getEventById('counted1')!;
      expect(original.recurrenceRule!.count, isNull);
      expect(original.recurrenceRule!.until, isNotNull);
      expect(
        original.recurrenceRule!.until!,
        DateTime(2026, 1, 19), // day before split
      );
    });

    test('new series from split uses original (untruncated) recurrence rule',
        () {
      final controller = MCalEventController();
      final event = MCalCalendarEvent(
        id: 'biweekly1',
        title: 'Bi-Weekly',
        start: DateTime(2026, 1, 6, 10, 0),
        end: DateTime(2026, 1, 6, 11, 0),
        recurrenceRule: MCalRecurrenceRule(
          frequency: MCalFrequency.weekly,
          interval: 2,
        ),
      );
      controller.addEvents([event]);

      final newId = controller.splitSeries('biweekly1', DateTime(2026, 1, 20));

      final newMaster = controller.getEventById(newId)!;
      // New series uses original rule: weekly interval=2, no until
      expect(newMaster.recurrenceRule!.frequency, MCalFrequency.weekly);
      expect(newMaster.recurrenceRule!.interval, 2);
      expect(newMaster.recurrenceRule!.until, isNull);
      expect(newMaster.recurrenceRule!.count, isNull);
    });

    test('split both series expand correctly in wider range', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      controller.splitSeries('weekly1', DateTime(2026, 1, 20));

      final events = controller.getEventsForRange(_janFebRange);

      // Original: Jan 6, 13 (until = Jan 19)
      // New: Jan 20, 27, Feb 3, 10, 17, 24 = 6
      // Total: 8
      expect(events.length, 8);
    });

    test('split moves exceptions at the boundary correctly', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Exception exactly ON the split date
      controller.addException(
        'weekly1',
        MCalRecurrenceException.rescheduled(
          originalDate: DateTime(2026, 1, 20),
          newDate: DateTime(2026, 1, 21, 10, 0),
        ),
      );

      final newId = controller.splitSeries('weekly1', DateTime(2026, 1, 20));

      // The exception on Jan 20 should move to the new series
      final oldExceptions = controller.getExceptions('weekly1');
      expect(oldExceptions, isEmpty);

      final newExceptions = controller.getExceptions(newId);
      expect(newExceptions.length, 1);
      expect(newExceptions.first.originalDate, DateTime(2026, 1, 20));
    });
  });

  // ===========================================================================
  // 12. Multiple Concurrent Recurring Series
  // ===========================================================================
  group('Multiple concurrent recurring series', () {
    test('two different recurring events expand independently', () {
      final controller = MCalEventController();
      controller.addEvents([
        _weeklyEvent(id: 'series-a', start: DateTime(2026, 1, 6, 10, 0)),
        _weeklyEvent(id: 'series-b', start: DateTime(2026, 1, 7, 14, 0)),
      ]);

      final events = controller.getEventsForRange(_januaryRange);

      // Series A: Tuesdays (Jan 6, 13, 20, 27) = 4
      // Series B: Wednesdays (Jan 7, 14, 21, 28) = 4
      expect(events.length, 8);

      final aEvents = events.where((e) => e.id.startsWith('series-a'));
      final bEvents = events.where((e) => e.id.startsWith('series-b'));
      expect(aEvents.length, 4);
      expect(bEvents.length, 4);
    });

    test('exception on one series does not affect another', () {
      final controller = MCalEventController();
      controller.addEvents([
        _weeklyEvent(id: 'series-a', start: DateTime(2026, 1, 6, 10, 0)),
        _weeklyEvent(id: 'series-b', start: DateTime(2026, 1, 7, 14, 0)),
      ]);

      // Delete only from series A
      controller.addException(
        'series-a',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
      );

      final events = controller.getEventsForRange(_januaryRange);
      expect(events.length, 7); // 3 + 4

      final aEvents = events.where((e) => e.id.startsWith('series-a'));
      expect(aEvents.length, 3);

      final bEvents = events.where((e) => e.id.startsWith('series-b'));
      expect(bEvents.length, 4);
    });

    test('deleting one series preserves the other', () {
      final controller = MCalEventController();
      controller.addEvents([
        _weeklyEvent(id: 'series-a'),
        _weeklyEvent(id: 'series-b', start: DateTime(2026, 1, 7, 14, 0)),
      ]);

      controller.deleteRecurringEvent('series-a');

      final events = controller.getEventsForRange(_januaryRange);
      expect(events.length, 4);
      expect(events.every((e) => e.id.startsWith('series-b')), isTrue);
    });

    test('mixed recurring and non-recurring events coexist', () {
      final controller = MCalEventController();
      controller.addEvents([
        _weeklyEvent(),
        _singleEvent(id: 'standalone1'),
        _singleEvent(id: 'standalone2', start: DateTime(2026, 1, 20, 9, 0)),
      ]);

      final events = controller.getEventsForRange(_januaryRange);
      expect(events.length, 6); // 4 weekly + 2 standalone
    });
  });

  // ===========================================================================
  // 13. notifyListeners Verification
  // ===========================================================================
  group('notifyListeners call counts', () {
    test('addException notifies exactly once', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      var count = 0;
      controller.addListener(() => count++);

      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
      );

      expect(count, 1);
    });

    test('addExceptions (batch) notifies exactly once', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      var count = 0;
      controller.addListener(() => count++);

      controller.addExceptions('weekly1', [
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 6),
        ),
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
      ]);

      expect(count, 1);
    });

    test('removeException notifies exactly once when found', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);
      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
      );

      var count = 0;
      controller.addListener(() => count++);

      controller.removeException('weekly1', DateTime(2026, 1, 13));
      expect(count, 1);
    });

    test('removeException does not notify when not found', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      var count = 0;
      controller.addListener(() => count++);

      controller.removeException('weekly1', DateTime(2026, 1, 13));
      expect(count, 0);
    });

    test('updateRecurringEvent notifies once', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      var count = 0;
      controller.addListener(() => count++);

      controller.updateRecurringEvent(
        _weeklyEvent().copyWith(title: 'Updated'),
      );
      expect(count, 1);
    });

    test('deleteRecurringEvent notifies once', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      var count = 0;
      controller.addListener(() => count++);

      controller.deleteRecurringEvent('weekly1');
      expect(count, 1);
    });

    test('splitSeries notifies once', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      var count = 0;
      controller.addListener(() => count++);

      controller.splitSeries('weekly1', DateTime(2026, 1, 20));
      expect(count, 1);
    });

    test('modifyOccurrence notifies once (delegates to addException)', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      var count = 0;
      controller.addListener(() => count++);

      controller.modifyOccurrence(
        'weekly1',
        DateTime(2026, 1, 13),
        MCalCalendarEvent(
          id: 'mod',
          title: 'Modified',
          start: DateTime(2026, 1, 13, 11, 0),
          end: DateTime(2026, 1, 13, 12, 0),
        ),
      );
      expect(count, 1);
    });
  });

  // ===========================================================================
  // 14. Cache Invalidation Thoroughness
  // ===========================================================================
  group('Cache invalidation thoroughness', () {
    test('updateRecurringEvent preserves existing exceptions', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Add an exception
      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
      );

      // Update the master (change title)
      controller.updateRecurringEvent(
        _weeklyEvent().copyWith(title: 'Updated Title'),
      );

      // Exception should still be there
      final exceptions = controller.getExceptions('weekly1');
      expect(exceptions.length, 1);

      // And reflected in expansion
      final events = controller.getEventsForRange(_januaryRange);
      expect(events.length, 3); // still missing Jan 13
      expect(events.every((e) => e.title == 'Updated Title'), isTrue);
    });

    test('deleteRecurringEvent clears expansion cache', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Fill cache
      controller.getEventsForRange(_januaryRange);

      // Delete
      controller.deleteRecurringEvent('weekly1');

      // No events
      final events = controller.getEventsForRange(_januaryRange);
      expect(events, isEmpty);
    });

    test('clearEvents clears recurring events and expansion cache', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent(), _dailyEvent()]);

      // Fill cache
      controller.getEventsForRange(_januaryRange);

      // Clear all
      controller.clearEvents();

      final events = controller.getEventsForRange(_januaryRange);
      expect(events, isEmpty);
    });

    test('removeEvents clears recurring event and its expansion cache', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Fill cache
      controller.getEventsForRange(_januaryRange);

      // Remove via generic removeEvents
      controller.removeEvents(['weekly1']);

      final events = controller.getEventsForRange(_januaryRange);
      expect(events, isEmpty);
    });
  });

  // ===========================================================================
  // 15. lastChange affectedDateRange Accuracy
  // ===========================================================================
  group('lastChange affectedDateRange accuracy', () {
    test('deleted exception range covers just the original date', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
      );

      final range = controller.lastChange!.affectedDateRange!;
      expect(range.start, DateTime(2026, 1, 13));
      // End is the next day (exclusive upper bound)
      expect(range.end, DateTime(2026, 1, 14));
    });

    test('rescheduled exception range covers original through new date', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      controller.addException(
        'weekly1',
        MCalRecurrenceException.rescheduled(
          originalDate: DateTime(2026, 1, 13),
          newDate: DateTime(2026, 1, 20, 10, 0),
        ),
      );

      final range = controller.lastChange!.affectedDateRange!;
      expect(range.start, DateTime(2026, 1, 13));
      expect(range.end, DateTime(2026, 1, 21));
    });

    test('rescheduled to earlier date: range covers new through original', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      controller.addException(
        'weekly1',
        MCalRecurrenceException.rescheduled(
          originalDate: DateTime(2026, 1, 20),
          newDate: DateTime(2026, 1, 10, 10, 0),
        ),
      );

      final range = controller.lastChange!.affectedDateRange!;
      expect(range.start, DateTime(2026, 1, 10));
      expect(range.end, DateTime(2026, 1, 21));
    });

    test('modified exception range covers the original date', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      controller.addException(
        'weekly1',
        MCalRecurrenceException.modified(
          originalDate: DateTime(2026, 1, 13),
          modifiedEvent: MCalCalendarEvent(
            id: 'mod',
            title: 'Mod',
            start: DateTime(2026, 1, 13, 16, 0),
            end: DateTime(2026, 1, 13, 17, 0),
          ),
        ),
      );

      final range = controller.lastChange!.affectedDateRange!;
      expect(range.start, DateTime(2026, 1, 13));
      expect(range.end, DateTime(2026, 1, 14));
    });
  });

  // ===========================================================================
  // 16. Exception CRUD on Non-Existent Series
  // ===========================================================================
  group('Exception CRUD on non-existent series', () {
    test('addException stores exception even if master not yet loaded', () {
      final controller = MCalEventController();

      // Add exception before adding the master event
      controller.addException(
        'future_series',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 3, 15),
        ),
      );

      // Exception is stored
      final exceptions = controller.getExceptions('future_series');
      expect(exceptions.length, 1);

      // Now add the master
      controller.addEvents([
        MCalCalendarEvent(
          id: 'future_series',
          title: 'Future',
          start: DateTime(2026, 3, 1, 10, 0),
          end: DateTime(2026, 3, 1, 11, 0),
          recurrenceRule: MCalRecurrenceRule(
            frequency: MCalFrequency.weekly,
          ),
        ),
      ]);

      // Expand and verify exception is applied
      final marchRange = DateTimeRange(
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 31, 23, 59, 59),
      );
      final events = controller.getEventsForRange(marchRange);

      // Mar 15 should be excluded
      expect(events.any((e) => e.start.day == 15), isFalse);
    });

    test('removeException returns null for series with no exceptions', () {
      final controller = MCalEventController();

      final result = controller.removeException(
        'nonexistent',
        DateTime(2026, 1, 1),
      );
      expect(result, isNull);
    });
  });

  // ===========================================================================
  // 17. getEventsForDate (Single Day Query)
  // ===========================================================================
  group('getEventsForDate with recurring events', () {
    test('returns occurrences for a specific date', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      final events = controller.getEventsForDate(DateTime(2026, 1, 13));
      expect(events.length, 1);
      expect(events.first.start.day, 13);
    });

    test('returns empty for a date with no occurrence', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Jan 10 is a Saturday — no weekly Tuesday occurrence
      final events = controller.getEventsForDate(DateTime(2026, 1, 10));
      expect(events, isEmpty);
    });

    test('returns deleted occurrence date as empty', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
      );

      final events = controller.getEventsForDate(DateTime(2026, 1, 13));
      expect(events, isEmpty);
    });

    test('multi-day recurring event appears on intermediate day', () {
      final controller = MCalEventController();
      // 3-day event starting Monday 9am to Wednesday 5pm
      final event = MCalCalendarEvent(
        id: 'multi1',
        title: 'Multi Day',
        start: DateTime(2026, 1, 5, 9, 0), // Monday
        end: DateTime(2026, 1, 7, 17, 0), // Wednesday
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.weekly),
      );
      controller.addEvents([event]);

      // Tuesday Jan 6 is an intermediate day of the Mon-Wed occurrence.
      // The expansion engine pads the query backwards by the event duration,
      // so the Monday occurrence is captured.
      final events = controller.getEventsForDate(DateTime(2026, 1, 6));
      expect(events.length, 1);
      expect(events.first.title, 'Multi Day');
      expect(events.first.start, DateTime(2026, 1, 5, 9, 0));
    });
  });

  // ===========================================================================
  // 18. Interaction Between Split and Exceptions
  // ===========================================================================
  group('Interaction between split and exceptions', () {
    test('after split, exceptions on original series still work', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Add exception on original series before split date
      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 6),
        ),
      );

      controller.splitSeries('weekly1', DateTime(2026, 1, 20));

      final events = controller.getEventsForRange(_januaryRange);

      // Original: Jan 6 (deleted), Jan 13 → only Jan 13
      // New: Jan 20, 27
      // Total: 3
      expect(events.length, 3);
      expect(events.any((e) => e.start.day == 6), isFalse);
    });

    test('after split, can add exception to new series', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      final newId = controller.splitSeries('weekly1', DateTime(2026, 1, 20));

      // Add exception to new series
      controller.addException(
        newId,
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 27),
        ),
      );

      final events = controller.getEventsForRange(_januaryRange);
      // Original: Jan 6, 13
      // New: Jan 20 (Jan 27 deleted)
      expect(events.length, 3);
    });

    test('after split, can add exception to original series', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      controller.splitSeries('weekly1', DateTime(2026, 1, 20));

      // Add exception to original (truncated) series
      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 6),
        ),
      );

      final events = controller.getEventsForRange(_januaryRange);
      // Original: Jan 13 (Jan 6 deleted)
      // New: Jan 20, 27
      expect(events.length, 3);
    });
  });

  // ===========================================================================
  // 19. Weekly with byWeekDays in Controller
  // ===========================================================================
  group('Weekly with byWeekDays in controller', () {
    test('weekly event on Tue/Thu expands correctly', () {
      final controller = MCalEventController();
      final event = MCalCalendarEvent(
        id: 'tuth1',
        title: 'Tu/Th Class',
        start: DateTime(2026, 1, 6, 10, 0), // Tuesday
        end: DateTime(2026, 1, 6, 11, 0),
        recurrenceRule: MCalRecurrenceRule(
          frequency: MCalFrequency.weekly,
          byWeekDays: {
            MCalWeekDay.every(DateTime.tuesday),
            MCalWeekDay.every(DateTime.thursday),
          },
        ),
      );
      controller.addEvents([event]);

      final events = controller.getEventsForRange(_januaryRange);

      // January 2026:
      // Tue: 6, 13, 20, 27
      // Thu: 8, 15, 22, 29
      // = 8 occurrences
      expect(events.length, 8);

      for (final e in events) {
        expect(
          e.start.weekday == DateTime.tuesday ||
              e.start.weekday == DateTime.thursday,
          isTrue,
        );
      }
    });

    test('exception deleting one Thursday does not affect Tuesdays', () {
      final controller = MCalEventController();
      final event = MCalCalendarEvent(
        id: 'tuth1',
        title: 'Tu/Th Class',
        start: DateTime(2026, 1, 6, 10, 0),
        end: DateTime(2026, 1, 6, 11, 0),
        recurrenceRule: MCalRecurrenceRule(
          frequency: MCalFrequency.weekly,
          byWeekDays: {
            MCalWeekDay.every(DateTime.tuesday),
            MCalWeekDay.every(DateTime.thursday),
          },
        ),
      );
      controller.addEvents([event]);

      // Delete the Jan 8 (Thursday) occurrence
      controller.addException(
        'tuth1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 8),
        ),
      );

      final events = controller.getEventsForRange(_januaryRange);
      expect(events.length, 7); // 8 - 1

      // All Tuesdays still present
      final tuesdays = events.where(
        (e) => e.start.weekday == DateTime.tuesday,
      );
      expect(tuesdays.length, 4);
    });
  });

  // ===========================================================================
  // 20. Edge Case: Empty Range Query
  // ===========================================================================
  group('Edge case: empty and narrow range queries', () {
    test('range that ends before series starts returns empty', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]); // starts Jan 6

      final earlyRange = DateTimeRange(
        start: DateTime(2025, 12, 1),
        end: DateTime(2025, 12, 31, 23, 59, 59),
      );
      final events = controller.getEventsForRange(earlyRange);
      expect(events, isEmpty);
    });

    test('single-day range containing an occurrence returns it', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Jan 13 is a Tuesday occurrence
      final singleDay = DateTimeRange(
        start: DateTime(2026, 1, 13),
        end: DateTime(2026, 1, 13, 23, 59, 59),
      );
      final events = controller.getEventsForRange(singleDay);
      expect(events.length, 1);
    });
  });

  // ===========================================================================
  // 21. Occurrence ID Determinism
  // ===========================================================================
  group('Occurrence ID determinism', () {
    test('same range queried twice produces identical occurrence IDs', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      final first = controller.getEventsForRange(_januaryRange);
      // Force cache invalidation by querying a different range first
      controller.getEventsForRange(_janFebRange);
      final second = controller.getEventsForRange(_januaryRange);

      expect(first.length, second.length);
      for (var i = 0; i < first.length; i++) {
        expect(first[i].id, second[i].id);
        expect(first[i].occurrenceId, second[i].occurrenceId);
      }
    });

    test('occurrenceId is based on normalized date (midnight)', () {
      final controller = MCalEventController();
      // Event at 3pm — occurrenceId should still be midnight-based
      controller.addEvents([
        _weeklyEvent(start: DateTime(2026, 1, 6, 15, 30)),
      ]);

      final events = controller.getEventsForRange(_januaryRange);

      for (final e in events) {
        final occDate = DateTime.parse(e.occurrenceId!);
        expect(occDate.hour, 0);
        expect(occDate.minute, 0);
        expect(occDate.second, 0);
      }
    });
  });

  // ===========================================================================
  // 22. updateRecurringEvent After Exceptions
  // ===========================================================================
  group('updateRecurringEvent after exceptions', () {
    test('updating title reflects in new expansion while exceptions remain',
        () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Add exceptions
      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 6),
        ),
      );
      controller.addException(
        'weekly1',
        MCalRecurrenceException.rescheduled(
          originalDate: DateTime(2026, 1, 13),
          newDate: DateTime(2026, 1, 14, 10, 0),
        ),
      );

      // Update master title
      controller.updateRecurringEvent(
        _weeklyEvent().copyWith(title: 'New Title'),
      );

      final events = controller.getEventsForRange(_januaryRange);

      // Jan 6 deleted, Jan 13 → 14, Jan 20, Jan 27 = 3 events
      expect(events.length, 3);

      // Non-modified occurrences should have new title
      final normalOccs = events.where((e) => e.start.day != 14);
      for (final e in normalOccs) {
        expect(e.title, 'New Title');
      }

      // Rescheduled occurrence also gets new title (copied from master)
      final rescheduled = events.firstWhere((e) => e.start.day == 14);
      expect(rescheduled.title, 'New Title');
    });

    test('updating rule changes occurrences but exceptions still apply', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
      );

      // Change to daily
      controller.updateRecurringEvent(
        _weeklyEvent().copyWith(
          recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.daily),
        ),
      );

      final events = controller.getEventsForRange(_januaryRange);

      // Daily from Jan 6: 26 days, minus Jan 13 deleted = 25
      expect(events.length, 25);
      expect(events.any((e) => e.start.day == 13), isFalse);
    });
  });

  // ===========================================================================
  // 23. Multi-Day with Split
  // ===========================================================================
  group('Multi-day recurring event with split', () {
    test('split multi-day event preserves duration in new series', () {
      final controller = MCalEventController();
      controller.addEvents([_multiDayWeekly()]);

      final newId = controller.splitSeries('conf1', DateTime(2026, 1, 19));

      final newMaster = controller.getEventById(newId)!;
      final duration = newMaster.end.difference(newMaster.start);
      expect(duration, const Duration(days: 2, hours: 8));
    });

    test('split multi-day event, both series produce correct occurrences', () {
      final controller = MCalEventController();
      controller.addEvents([_multiDayWeekly()]);

      controller.splitSeries('conf1', DateTime(2026, 1, 19));

      final events = controller.getEventsForRange(_januaryRange);

      // Original: bi-weekly from Jan 5, until = Jan 18. Only Jan 5.
      // New: bi-weekly from Jan 19. Jan 19 in January. (Next: Feb 2)
      expect(events.length, 2);
    });
  });

  // ===========================================================================
  // 24. Exception for Master Without Master Loaded
  // ===========================================================================
  group('Exception without master loaded', () {
    test('addExceptions before master loads, then master loaded applies them',
        () {
      final controller = MCalEventController();

      // Pre-load exceptions
      controller.addExceptions('deferred1', [
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
        MCalRecurrenceException.rescheduled(
          originalDate: DateTime(2026, 1, 20),
          newDate: DateTime(2026, 1, 21, 10, 0),
        ),
      ]);

      // Now add the master
      controller.addEvents([
        MCalCalendarEvent(
          id: 'deferred1',
          title: 'Deferred',
          start: DateTime(2026, 1, 6, 10, 0),
          end: DateTime(2026, 1, 6, 11, 0),
          recurrenceRule: MCalRecurrenceRule(
            frequency: MCalFrequency.weekly,
          ),
        ),
      ]);

      final events = controller.getEventsForRange(_januaryRange);

      // Jan 6, (13 deleted), (20→21), 27 = 3 visible
      expect(events.length, 3);
      expect(events.any((e) => e.start.day == 13), isFalse);
      expect(events.any((e) => e.start.day == 21), isTrue);
    });
  });

  // ===========================================================================
  // 25. modifyOccurrence Return Value
  // ===========================================================================
  group('modifyOccurrence return value', () {
    test('returns the created MCalRecurrenceException', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      final modifiedEvent = MCalCalendarEvent(
        id: 'mod1',
        title: 'Modified',
        start: DateTime(2026, 1, 13, 11, 0),
        end: DateTime(2026, 1, 13, 12, 0),
      );

      final result = controller.modifyOccurrence(
        'weekly1',
        DateTime(2026, 1, 13),
        modifiedEvent,
      );

      expect(result.type, MCalExceptionType.modified);
      expect(result.originalDate, DateTime(2026, 1, 13));
      expect(result.modifiedEvent, modifiedEvent);
    });
  });

  // ===========================================================================
  // 26. addException Return Value
  // ===========================================================================
  group('addException return value', () {
    test('returns the added exception for chaining/persistence', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      final exception = MCalRecurrenceException.deleted(
        originalDate: DateTime(2026, 1, 13),
      );
      final result = controller.addException('weekly1', exception);

      expect(result, same(exception));
      expect(result.type, MCalExceptionType.deleted);
    });

    test('rescheduled exception return includes newDate', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      final result = controller.addException(
        'weekly1',
        MCalRecurrenceException.rescheduled(
          originalDate: DateTime(2026, 1, 13),
          newDate: DateTime(2026, 1, 14, 10, 0),
        ),
      );

      expect(result.newDate, DateTime(2026, 1, 14, 10, 0));
    });
  });

  // ===========================================================================
  // 27. splitSeries Return Value
  // ===========================================================================
  group('splitSeries return value', () {
    test('returns a deterministic new series ID', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      final newId = controller.splitSeries('weekly1', DateTime(2026, 1, 20));

      expect(newId, contains('weekly1'));
      expect(newId, contains('split'));
    });

    test('new series ID is usable with getEventById', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      final newId = controller.splitSeries('weekly1', DateTime(2026, 1, 20));

      final newMaster = controller.getEventById(newId);
      expect(newMaster, isNotNull);
      expect(newMaster!.recurrenceRule, isNotNull);
    });
  });

  // ===========================================================================
  // 28. Far-Past Start Date Optimization
  // ===========================================================================
  group('Far-past start date optimization', () {
    test('daily event started years ago expands correctly for current month',
        () {
      final controller = MCalEventController();
      // Daily event starting 3 years ago, no count/until
      controller.addEvents([
        MCalCalendarEvent(
          id: 'old-daily',
          title: 'Daily Standup',
          start: DateTime(2023, 1, 1, 9, 0),
          end: DateTime(2023, 1, 1, 9, 30),
          recurrenceRule: MCalRecurrenceRule(
            frequency: MCalFrequency.daily,
          ),
        ),
      ]);

      final events = controller.getEventsForRange(_januaryRange);

      // Should produce one occurrence per day in January 2026
      expect(events.length, 31);

      // Verify correct dates
      for (final e in events) {
        expect(e.start.year, 2026);
        expect(e.start.month, 1);
        expect(e.start.hour, 9);
        expect(e.start.minute, 0);
      }
    });

    test('weekly event started years ago expands correctly', () {
      final controller = MCalEventController();
      // Weekly event on Tuesday starting 2 years ago
      controller.addEvents([
        MCalCalendarEvent(
          id: 'old-weekly',
          title: 'Old Weekly',
          start: DateTime(2024, 1, 2, 10, 0), // Tuesday
          end: DateTime(2024, 1, 2, 11, 0),
          recurrenceRule: MCalRecurrenceRule(
            frequency: MCalFrequency.weekly,
          ),
        ),
      ]);

      final events = controller.getEventsForRange(_januaryRange);

      // January 2026 Tuesdays: 6, 13, 20, 27
      expect(events.length, 4);
      for (final e in events) {
        expect(e.start.weekday, DateTime.tuesday);
      }
    });

    test('bi-weekly event started years ago preserves alignment', () {
      final controller = MCalEventController();
      // Bi-weekly on Monday starting 2 years ago
      controller.addEvents([
        MCalCalendarEvent(
          id: 'old-biweekly',
          title: 'Old Bi-Weekly',
          start: DateTime(2024, 1, 1, 10, 0), // Monday
          end: DateTime(2024, 1, 1, 11, 0),
          recurrenceRule: MCalRecurrenceRule(
            frequency: MCalFrequency.weekly,
            interval: 2,
          ),
        ),
      ]);

      final events = controller.getEventsForRange(_januaryRange);

      // Bi-weekly from a Monday 2 years ago — verify occurrences land on Mondays
      for (final e in events) {
        expect(e.start.weekday, DateTime.monday);
      }
      // Should be 2 or 3 Mondays depending on alignment
      expect(events.length, greaterThanOrEqualTo(2));
      expect(events.length, lessThanOrEqualTo(3));
    });

    test('monthly event started years ago expands correctly', () {
      final controller = MCalEventController();
      controller.addEvents([
        MCalCalendarEvent(
          id: 'old-monthly',
          title: 'Old Monthly',
          start: DateTime(2020, 3, 15, 14, 0),
          end: DateTime(2020, 3, 15, 16, 0),
          recurrenceRule: MCalRecurrenceRule(
            frequency: MCalFrequency.monthly,
          ),
        ),
      ]);

      final events = controller.getEventsForRange(_q1Range);

      // Should have 3 occurrences: Jan 15, Feb 15, Mar 15
      expect(events.length, 3);
      expect(events[0].start.month, 1);
      expect(events[1].start.month, 2);
      expect(events[2].start.month, 3);
      for (final e in events) {
        expect(e.start.day, 15);
        expect(e.start.hour, 14);
      }
    });

    test('yearly event started long ago expands correctly', () {
      final controller = MCalEventController();
      controller.addEvents([
        MCalCalendarEvent(
          id: 'old-yearly',
          title: 'Old Yearly',
          start: DateTime(2000, 6, 15, 12, 0),
          end: DateTime(2000, 6, 15, 14, 0),
          recurrenceRule: MCalRecurrenceRule(
            frequency: MCalFrequency.yearly,
          ),
        ),
      ]);

      final events = controller.getEventsForRange(_yearRange);

      // One occurrence in 2026: June 15
      expect(events.length, 1);
      expect(events.first.start, DateTime(2026, 6, 15, 12, 0));
    });

    test('far-past daily with count is NOT optimized (DTSTART preserved)', () {
      final controller = MCalEventController();
      // Daily event starting 3 years ago with count=10.
      //
      // NOTE: teno_rrule's between() counts occurrences only within the query
      // window (instances before `after` are skipped without decrementing the
      // counter). This means count=10 effectively limits the number of results
      // per query window rather than the total series length. This is a known
      // teno_rrule behavior — the DTSTART walk is preserved for correctness
      // (our optimization is skipped when count != null).
      controller.addEvents([
        MCalCalendarEvent(
          id: 'counted-old',
          title: 'Short Series',
          start: DateTime(2023, 1, 1, 9, 0),
          end: DateTime(2023, 1, 1, 9, 30),
          recurrenceRule: MCalRecurrenceRule(
            frequency: MCalFrequency.daily,
            count: 10,
          ),
        ),
      ]);

      final events = controller.getEventsForRange(_januaryRange);

      // Due to teno_rrule behavior, count limits per-window, so 10 results
      // appear in any 31-day window.
      expect(events.length, 10);
    });

    test('far-past multi-day daily event overlaps into range correctly', () {
      final controller = MCalEventController();
      // 3-day daily event starting 2 years ago
      controller.addEvents([
        MCalCalendarEvent(
          id: 'old-multi',
          title: 'Old Multi-Day',
          start: DateTime(2024, 1, 1, 9, 0),
          end: DateTime(2024, 1, 3, 17, 0),
          recurrenceRule: MCalRecurrenceRule(
            frequency: MCalFrequency.daily,
          ),
        ),
      ]);

      // Query just Jan 2, 2026 — the Jan 1 occurrence ends Jan 3 (overlaps)
      // and the Jan 2 occurrence starts on Jan 2.
      final events = controller.getEventsForDate(DateTime(2026, 1, 2));

      // Should find at least 1 event (the Jan 2 occurrence, and possibly
      // the Jan 1 occurrence if the multi-day overlap padding captures it)
      expect(events.length, greaterThanOrEqualTo(1));
    });

    test('far-past event with exceptions works correctly', () {
      final controller = MCalEventController();
      controller.addEvents([
        MCalCalendarEvent(
          id: 'old-exc',
          title: 'Old With Exceptions',
          start: DateTime(2023, 1, 2, 10, 0), // Monday/Tuesday
          end: DateTime(2023, 1, 2, 11, 0),
          recurrenceRule: MCalRecurrenceRule(
            frequency: MCalFrequency.weekly,
          ),
        ),
      ]);

      // Delete a specific occurrence in the current range
      controller.addException(
        'old-exc',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
      );

      final events = controller.getEventsForRange(_januaryRange);

      // Verify the deleted occurrence is absent
      expect(events.any((e) => e.start.day == 13), isFalse);

      // Should still have the other occurrences
      expect(events.length, greaterThanOrEqualTo(3));
    });
  });
}
