import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';

/// Helper: builds a weekly recurring event starting on a Tuesday at 10:00.
MCalCalendarEvent _weeklyEvent({String id = 'weekly1', DateTime? start}) {
  final s = start ?? DateTime(2026, 1, 6, 10, 0); // A Tuesday
  return MCalCalendarEvent(
    id: id,
    title: 'Weekly Meeting',
    start: s,
    end: s.add(const Duration(hours: 1)),
    recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.weekly),
  );
}

/// Helper: builds a simple non-recurring event.
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

/// January 2026 range (covers 5 Tuesdays: Jan 6, 13, 20, 27, and Feb 3 is
/// outside, but Jan has 4 Tuesdays after the 6th start).
final _januaryRange = DateTimeRange(
  start: DateTime(2026, 1, 1),
  end: DateTime(2026, 1, 31, 23, 59, 59),
);

/// A wider range that covers February too.
final _janFebRange = DateTimeRange(
  start: DateTime(2026, 1, 1),
  end: DateTime(2026, 2, 28, 23, 59, 59),
);

void main() {
  // ==========================================================================
  // 1. Expansion
  // ==========================================================================
  group('Expansion', () {
    test('weekly recurring event returns correct occurrences for a month', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      final events = controller.getEventsForRange(_januaryRange);

      // Jan 6, 13, 20, 27 — 4 Tuesdays in January starting from Jan 6
      expect(events.length, 4);
    });

    test('each occurrence has correct id format "{masterId}_{dateIso8601}"',
        () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      final events = controller.getEventsForRange(_januaryRange);

      for (final e in events) {
        expect(e.id, startsWith('weekly1_'));
        // The id should contain an ISO 8601 date string after the underscore
        final suffix = e.id.replaceFirst('weekly1_', '');
        expect(() => DateTime.parse(suffix), returnsNormally);
      }
    });

    test('each occurrence has correct occurrenceId', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      final events = controller.getEventsForRange(_januaryRange);

      for (final e in events) {
        expect(e.occurrenceId, isNotNull);
        // occurrenceId should be the normalized date ISO string
        expect(() => DateTime.parse(e.occurrenceId!), returnsNormally);
      }
    });

    test('occurrences preserve the original event duration', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      final events = controller.getEventsForRange(_januaryRange);

      for (final e in events) {
        final duration = e.end.difference(e.start);
        expect(duration, const Duration(hours: 1));
      }
    });

    test('occurrences have the correct start dates (all Tuesdays)', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      final events = controller.getEventsForRange(_januaryRange);
      final startDates = events.map((e) => e.start).toList()..sort();

      // Expect Tuesdays in January 2026 starting from Jan 6
      expect(startDates[0], DateTime(2026, 1, 6, 10, 0));
      expect(startDates[1], DateTime(2026, 1, 13, 10, 0));
      expect(startDates[2], DateTime(2026, 1, 20, 10, 0));
      expect(startDates[3], DateTime(2026, 1, 27, 10, 0));
    });

    test('non-recurring events still work alongside recurring events', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent(), _singleEvent()]);

      final events = controller.getEventsForRange(_januaryRange);

      // 4 weekly occurrences + 1 single event = 5
      expect(events.length, 5);

      // Verify the single event is present
      final single = events.where((e) => e.id == 'single1');
      expect(single.length, 1);
    });

    test('wider range returns more occurrences', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      final events = controller.getEventsForRange(_janFebRange);

      // Jan 6 through Feb 28 — should have ~8 Tuesdays
      expect(events.length, greaterThanOrEqualTo(8));
    });
  });

  // ==========================================================================
  // Exception switch fall-through regression
  // ==========================================================================
  // Each exception type (deleted, rescheduled, modified) must be handled by its
  // own switch case with a break. Without breaks, rescheduled would fall through
  // to modified and crash on exception.modifiedEvent! (null for rescheduled).
  // These tests would fail before the fall-through fix.
  group('Exception switch fall-through regression', () {
    test('rescheduled exception does not fall through to modified path', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Reschedule Jan 13 to Jan 14 — must not crash or trigger modified path
      controller.addException(
        'weekly1',
        MCalRecurrenceException.rescheduled(
          originalDate: DateTime(2026, 1, 13),
          newDate: DateTime(2026, 1, 14, 10, 0),
        ),
      );

      // Would crash before fix: fall-through to modified case accesses null
      final events = controller.getEventsForRange(_januaryRange);

      expect(events.length, 4);
      // Rescheduled occurrence must appear at new date, not original
      final jan14 = events.where((e) => e.start.day == 14 && e.start.month == 1);
      expect(jan14.length, 1);
      expect(jan14.first.title, 'Weekly Meeting');
    });

    test('modified exception does not fall through to other paths', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      final modifiedEvent = MCalCalendarEvent(
        id: 'weekly1_jan20_custom',
        title: 'Custom Meeting',
        start: DateTime(2026, 1, 20, 14, 0),
        end: DateTime(2026, 1, 20, 15, 0),
      );
      controller.addException(
        'weekly1',
        MCalRecurrenceException.modified(
          originalDate: DateTime(2026, 1, 20),
          modifiedEvent: modifiedEvent,
        ),
      );

      final events = controller.getEventsForRange(_januaryRange);

      expect(events.length, 4);
      final custom = events.where((e) => e.title == 'Custom Meeting');
      expect(custom.length, 1);
      expect(custom.first.start.hour, 14);
    });

    test('deleted exception does not fall through to rescheduled path', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
      );

      final events = controller.getEventsForRange(_januaryRange);

      expect(events.length, 3);
      final jan13 = events.where((e) => e.start.day == 13 && e.start.month == 1);
      expect(jan13, isEmpty);
    });

    test('mixed exception types each handled correctly', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Deleted: Jan 6
      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 6),
        ),
      );
      // Rescheduled: Jan 13 → Jan 14
      controller.addException(
        'weekly1',
        MCalRecurrenceException.rescheduled(
          originalDate: DateTime(2026, 1, 13),
          newDate: DateTime(2026, 1, 14, 10, 0),
        ),
      );
      // Modified: Jan 20 with custom event
      controller.addException(
        'weekly1',
        MCalRecurrenceException.modified(
          originalDate: DateTime(2026, 1, 20),
          modifiedEvent: MCalCalendarEvent(
            id: 'mod_jan20',
            title: 'Modified Jan 20',
            start: DateTime(2026, 1, 20, 12, 0),
            end: DateTime(2026, 1, 20, 13, 0),
          ),
        ),
      );

      final events = controller.getEventsForRange(_januaryRange);

      // Jan 6 deleted (skip), Jan 13→14 rescheduled, Jan 20 modified, Jan 27 normal = 3 events
      expect(events.length, 3);

      expect(events.any((e) => e.start.day == 6 && e.start.month == 1), isFalse);
      expect(events.any((e) => e.start.day == 13 && e.start.month == 1), isFalse);
      expect(events.any((e) => e.start.day == 14 && e.start.month == 1), isTrue);
      expect(events.any((e) => e.title == 'Modified Jan 20'), isTrue);
      expect(events.any((e) => e.start.day == 27 && e.title == 'Weekly Meeting'), isTrue);
    });
  });

  // ==========================================================================
  // 2. Exceptions - deleted
  // ==========================================================================
  group('Exceptions - deleted', () {
    test('deleted exception skips one occurrence', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Delete the Jan 13 occurrence
      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
      );

      final events = controller.getEventsForRange(_januaryRange);

      // Should be 3 instead of 4 (Jan 13 is skipped)
      expect(events.length, 3);

      // Verify Jan 13 is not present
      final jan13 = events.where(
        (e) => e.start.day == 13 && e.start.month == 1,
      );
      expect(jan13, isEmpty);
    });

    test('multiple deleted exceptions skip multiple occurrences', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
      );
      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 27),
        ),
      );

      final events = controller.getEventsForRange(_januaryRange);
      expect(events.length, 2);
    });
  });

  // ==========================================================================
  // 3. Exceptions - rescheduled
  // ==========================================================================
  group('Exceptions - rescheduled', () {
    test('rescheduled exception moves occurrence to a new date', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Reschedule Jan 13 to Jan 14
      controller.addException(
        'weekly1',
        MCalRecurrenceException.rescheduled(
          originalDate: DateTime(2026, 1, 13),
          newDate: DateTime(2026, 1, 14, 10, 0),
        ),
      );

      final events = controller.getEventsForRange(_januaryRange);

      // Still 4 events, but one is on Jan 14 instead of Jan 13
      expect(events.length, 4);

      final jan13 = events.where(
        (e) =>
            e.start.day == 13 &&
            e.start.month == 1 &&
            e.start.hour == 10,
      );
      expect(jan13, isEmpty);

      final jan14 = events.where(
        (e) => e.start.day == 14 && e.start.month == 1,
      );
      expect(jan14.length, 1);
    });

    test('rescheduled occurrence preserves duration', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      controller.addException(
        'weekly1',
        MCalRecurrenceException.rescheduled(
          originalDate: DateTime(2026, 1, 13),
          newDate: DateTime(2026, 1, 14, 15, 0),
        ),
      );

      final events = controller.getEventsForRange(_januaryRange);
      final rescheduled = events.firstWhere(
        (e) => e.start.day == 14 && e.start.month == 1,
      );
      expect(
        rescheduled.end.difference(rescheduled.start),
        const Duration(hours: 1),
      );
    });
  });

  // ==========================================================================
  // 4. Exceptions - modified
  // ==========================================================================
  group('Exceptions - modified', () {
    test('modified exception replaces occurrence with different event data',
        () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Replace Jan 20 occurrence with a different event
      final modifiedEvent = MCalCalendarEvent(
        id: 'weekly1_modified_jan20',
        title: 'Special Meeting',
        start: DateTime(2026, 1, 20, 14, 0),
        end: DateTime(2026, 1, 20, 16, 0),
      );
      controller.addException(
        'weekly1',
        MCalRecurrenceException.modified(
          originalDate: DateTime(2026, 1, 20),
          modifiedEvent: modifiedEvent,
        ),
      );

      final events = controller.getEventsForRange(_januaryRange);

      // Still 4 events
      expect(events.length, 4);

      // The modified one should have the new title and times
      final modified = events.firstWhere((e) => e.title == 'Special Meeting');
      expect(modified.start, DateTime(2026, 1, 20, 14, 0));
      expect(modified.end, DateTime(2026, 1, 20, 16, 0));
    });

    test('modified occurrence has occurrenceId set', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      final modifiedEvent = MCalCalendarEvent(
        id: 'weekly1_custom',
        title: 'Custom Event',
        start: DateTime(2026, 1, 20, 14, 0),
        end: DateTime(2026, 1, 20, 16, 0),
      );
      controller.addException(
        'weekly1',
        MCalRecurrenceException.modified(
          originalDate: DateTime(2026, 1, 20),
          modifiedEvent: modifiedEvent,
        ),
      );

      final events = controller.getEventsForRange(_januaryRange);
      final modified = events.firstWhere((e) => e.title == 'Custom Event');
      expect(modified.occurrenceId, isNotNull);
    });
  });

  // ==========================================================================
  // 5. removeException
  // ==========================================================================
  group('removeException', () {
    test('removing a deleted exception restores the occurrence', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Delete Jan 13
      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
      );

      var events = controller.getEventsForRange(_januaryRange);
      expect(events.length, 3);

      // Remove the exception
      final removed =
          controller.removeException('weekly1', DateTime(2026, 1, 13));

      expect(removed, isNotNull);
      expect(removed!.type, MCalExceptionType.deleted);

      // Occurrence should be restored
      events = controller.getEventsForRange(_januaryRange);
      expect(events.length, 4);
    });

    test('removeException returns null when no exception exists', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      final removed =
          controller.removeException('weekly1', DateTime(2026, 1, 13));
      expect(removed, isNull);
    });

    test('removing a rescheduled exception restores original date', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Reschedule Jan 13 to Jan 14
      controller.addException(
        'weekly1',
        MCalRecurrenceException.rescheduled(
          originalDate: DateTime(2026, 1, 13),
          newDate: DateTime(2026, 1, 14, 10, 0),
        ),
      );

      // Remove the reschedule
      controller.removeException('weekly1', DateTime(2026, 1, 13));

      final events = controller.getEventsForRange(_januaryRange);
      // Should be back on Jan 13
      final jan13 = events.where(
        (e) => e.start.day == 13 && e.start.month == 1,
      );
      expect(jan13.length, 1);

      // Jan 14 should NOT have an occurrence
      final jan14 = events.where(
        (e) => e.start.day == 14 && e.start.month == 1,
      );
      expect(jan14, isEmpty);
    });
  });

  // ==========================================================================
  // 6. getExceptions
  // ==========================================================================
  group('getExceptions', () {
    test('returns empty list when no exceptions exist', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      expect(controller.getExceptions('weekly1'), isEmpty);
    });

    test('returns all exceptions for a series', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
      );
      controller.addException(
        'weekly1',
        MCalRecurrenceException.rescheduled(
          originalDate: DateTime(2026, 1, 20),
          newDate: DateTime(2026, 1, 21, 10, 0),
        ),
      );
      controller.addException(
        'weekly1',
        MCalRecurrenceException.modified(
          originalDate: DateTime(2026, 1, 27),
          modifiedEvent: MCalCalendarEvent(
            id: 'mod1',
            title: 'Modified',
            start: DateTime(2026, 1, 27, 14, 0),
            end: DateTime(2026, 1, 27, 15, 0),
          ),
        ),
      );

      final exceptions = controller.getExceptions('weekly1');
      expect(exceptions.length, 3);

      final types = exceptions.map((e) => e.type).toSet();
      expect(types, contains(MCalExceptionType.deleted));
      expect(types, contains(MCalExceptionType.rescheduled));
      expect(types, contains(MCalExceptionType.modified));
    });

    test('returns empty list for unknown series id', () {
      final controller = MCalEventController();
      expect(controller.getExceptions('nonexistent'), isEmpty);
    });
  });

  // ==========================================================================
  // 7. modifyOccurrence
  // ==========================================================================
  group('modifyOccurrence', () {
    test('creates a modified exception via addException', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      final modifiedEvent = MCalCalendarEvent(
        id: 'weekly1_jan13_modified',
        title: 'Modified Occurrence',
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

      // Verify via getExceptions
      final exceptions = controller.getExceptions('weekly1');
      expect(exceptions.length, 1);
      expect(exceptions.first.type, MCalExceptionType.modified);
    });

    test('modifyOccurrence changes are reflected in getEventsForRange', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      controller.modifyOccurrence(
        'weekly1',
        DateTime(2026, 1, 13),
        MCalCalendarEvent(
          id: 'weekly1_jan13_mod',
          title: 'Renamed Meeting',
          start: DateTime(2026, 1, 13, 11, 0),
          end: DateTime(2026, 1, 13, 12, 0),
        ),
      );

      final events = controller.getEventsForRange(_januaryRange);
      expect(events.length, 4);

      final modified = events.firstWhere((e) => e.title == 'Renamed Meeting');
      expect(modified.start, DateTime(2026, 1, 13, 11, 0));
    });
  });

  // ==========================================================================
  // 8. Cache behavior
  // ==========================================================================
  group('Cache behavior', () {
    test('getEventsForRange returns same results on repeated calls (cache hit)',
        () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      final first = controller.getEventsForRange(_januaryRange);
      final second = controller.getEventsForRange(_januaryRange);

      expect(first.length, second.length);
      for (int i = 0; i < first.length; i++) {
        expect(first[i].id, second[i].id);
        expect(first[i].start, second[i].start);
      }
    });

    test('addException patches cache (reflected without full re-expansion)',
        () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // First call fills the cache
      var events = controller.getEventsForRange(_januaryRange);
      expect(events.length, 4);

      // Add a delete exception — should patch cache in O(1)
      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
      );

      // Calling getEventsForRange with the SAME range should reflect the change
      events = controller.getEventsForRange(_januaryRange);
      expect(events.length, 3);
    });

    test('changing query range invalidates cache', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Query January
      final janEvents = controller.getEventsForRange(_januaryRange);
      expect(janEvents.length, 4);

      // Query a different range — should re-expand
      final febRange = DateTimeRange(
        start: DateTime(2026, 2, 1),
        end: DateTime(2026, 2, 28, 23, 59, 59),
      );
      final febEvents = controller.getEventsForRange(febRange);

      // February 2026 has 4 Tuesdays (3, 10, 17, 24)
      expect(febEvents.length, 4);
    });
  });

  // ==========================================================================
  // 9. Series management - updateRecurringEvent
  // ==========================================================================
  group('Series management - updateRecurringEvent', () {
    test('updating recurrence rule changes occurrences', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Initially 4 weekly occurrences in January
      var events = controller.getEventsForRange(_januaryRange);
      expect(events.length, 4);

      // Change to daily recurrence
      final updated = _weeklyEvent().copyWith(
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.daily),
      );
      controller.updateRecurringEvent(updated);

      events = controller.getEventsForRange(_januaryRange);

      // Daily from Jan 6 to Jan 31 = 26 days
      expect(events.length, 26);
    });

    test('updateRecurringEvent invalidates expansion cache', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Fill cache
      controller.getEventsForRange(_januaryRange);

      // Update master
      final updated = _weeklyEvent().copyWith(
        recurrenceRule: MCalRecurrenceRule(
          frequency: MCalFrequency.weekly,
          interval: 2,
        ),
      );
      controller.updateRecurringEvent(updated);

      final events = controller.getEventsForRange(_januaryRange);

      // Every other week from Jan 6: Jan 6, Jan 20 = 2 occurrences
      expect(events.length, 2);
    });
  });

  // ==========================================================================
  // 10. Series management - deleteRecurringEvent
  // ==========================================================================
  group('Series management - deleteRecurringEvent', () {
    test('deleteRecurringEvent removes all occurrences', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Verify occurrences exist
      var events = controller.getEventsForRange(_januaryRange);
      expect(events.length, 4);

      controller.deleteRecurringEvent('weekly1');

      events = controller.getEventsForRange(_januaryRange);
      expect(events, isEmpty);
    });

    test('deleteRecurringEvent also removes exceptions', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
      );

      controller.deleteRecurringEvent('weekly1');

      expect(controller.getExceptions('weekly1'), isEmpty);
    });

    test('deleteRecurringEvent does not affect other events', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent(), _singleEvent()]);

      controller.deleteRecurringEvent('weekly1');

      final events = controller.getEventsForRange(_januaryRange);
      expect(events.length, 1);
      expect(events.first.id, 'single1');
    });
  });

  // ==========================================================================
  // 11. Series management - splitSeries
  // ==========================================================================
  group('Series management - splitSeries', () {
    test('splitSeries truncates original and creates new series', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Split at Jan 20 — original covers Jan 6, Jan 13; new covers Jan 20+
      final newId = controller.splitSeries('weekly1', DateTime(2026, 1, 20));

      expect(newId, isNotEmpty);
      expect(newId, isNot('weekly1'));

      // Verify original is truncated (until = Jan 19)
      final original = controller.getEventById('weekly1');
      expect(original, isNotNull);
      expect(original!.recurrenceRule!.until, isNotNull);
      expect(
        original.recurrenceRule!.until!.isBefore(DateTime(2026, 1, 20)),
        isTrue,
      );

      // Verify new master exists
      final newMaster = controller.getEventById(newId);
      expect(newMaster, isNotNull);
      expect(newMaster!.recurrenceRule, isNotNull);
    });

    test('splitSeries distributes exceptions correctly', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Add exception before split date (Jan 13)
      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
      );

      // Add exception on split date (Jan 20)
      controller.addException(
        'weekly1',
        MCalRecurrenceException.rescheduled(
          originalDate: DateTime(2026, 1, 20),
          newDate: DateTime(2026, 1, 21, 10, 0),
        ),
      );

      // Add exception after split date (Jan 27)
      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 27),
        ),
      );

      final newId = controller.splitSeries('weekly1', DateTime(2026, 1, 20));

      // Original should keep exceptions before split date
      final originalExceptions = controller.getExceptions('weekly1');
      expect(originalExceptions.length, 1);
      expect(originalExceptions.first.originalDate, DateTime(2026, 1, 13));

      // New series should get exceptions on/after split date
      final newExceptions = controller.getExceptions(newId);
      expect(newExceptions.length, 2);

      final newExDates =
          newExceptions.map((e) => e.originalDate.day).toSet();
      expect(newExDates, contains(20));
      expect(newExDates, contains(27));
    });

    test('splitSeries preserves original time-of-day and duration', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      final newId = controller.splitSeries('weekly1', DateTime(2026, 1, 20));

      final newMaster = controller.getEventById(newId)!;
      expect(newMaster.start.hour, 10);
      expect(newMaster.start.minute, 0);
      expect(
        newMaster.end.difference(newMaster.start),
        const Duration(hours: 1),
      );
    });

    test('splitSeries throws StateError for nonexistent event', () {
      final controller = MCalEventController();

      expect(
        () => controller.splitSeries('nonexistent', DateTime(2026, 1, 20)),
        throwsA(isA<StateError>()),
      );
    });

    test('splitSeries throws ArgumentError for non-recurring event', () {
      final controller = MCalEventController();
      controller.addEvents([_singleEvent()]);

      expect(
        () => controller.splitSeries('single1', DateTime(2026, 1, 20)),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('after split, getEventsForRange returns occurrences from both series',
        () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      controller.splitSeries('weekly1', DateTime(2026, 1, 20));

      // Query the full month — should still see occurrences from both series
      final events = controller.getEventsForRange(_januaryRange);

      // Original series: Jan 6, 13 (until is Jan 19)
      // New series: Jan 20, 27 (and beyond, but within January)
      expect(events.length, 4);
    });
  });

  // ==========================================================================
  // 12. lastChange tracking
  // ==========================================================================
  group('lastChange tracking', () {
    test('after addException: lastChange.type == exceptionAdded', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
      );

      expect(controller.lastChange, isNotNull);
      expect(controller.lastChange!.type, MCalChangeType.exceptionAdded);
      expect(controller.lastChange!.affectedEventIds, contains('weekly1'));
    });

    test('after removeException: lastChange.type == exceptionRemoved', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
      );

      controller.removeException('weekly1', DateTime(2026, 1, 13));

      expect(controller.lastChange!.type, MCalChangeType.exceptionRemoved);
      expect(controller.lastChange!.affectedEventIds, contains('weekly1'));
    });

    test('after updateRecurringEvent: lastChange.type == eventUpdated', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      final updated = _weeklyEvent().copyWith(
        recurrenceRule: MCalRecurrenceRule(
          frequency: MCalFrequency.daily,
        ),
      );
      controller.updateRecurringEvent(updated);

      expect(controller.lastChange!.type, MCalChangeType.eventUpdated);
      expect(controller.lastChange!.affectedEventIds, contains('weekly1'));
    });

    test('after deleteRecurringEvent: lastChange.type == eventRemoved', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      controller.deleteRecurringEvent('weekly1');

      expect(controller.lastChange!.type, MCalChangeType.eventRemoved);
      expect(controller.lastChange!.affectedEventIds, contains('weekly1'));
    });

    test('after splitSeries: lastChange.type == seriesSplit', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      final newId = controller.splitSeries('weekly1', DateTime(2026, 1, 20));

      expect(controller.lastChange!.type, MCalChangeType.seriesSplit);
      expect(controller.lastChange!.affectedEventIds, contains('weekly1'));
      expect(controller.lastChange!.affectedEventIds, contains(newId));
    });

    test('after addEvents (non-recurring): lastChange.type == bulkChange', () {
      final controller = MCalEventController();
      controller.addEvents([_singleEvent()]);

      expect(controller.lastChange!.type, MCalChangeType.bulkChange);
      expect(controller.lastChange!.affectedEventIds, contains('single1'));
    });

    test('after clearEvents: lastChange.type == bulkChange', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      controller.clearEvents();

      expect(controller.lastChange!.type, MCalChangeType.bulkChange);
    });

    test('addException sets affectedDateRange', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      controller.addException(
        'weekly1',
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
      );

      expect(controller.lastChange!.affectedDateRange, isNotNull);
    });

    test('addExceptions sets lastChange.type to bulkChange', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      controller.addExceptions('weekly1', [
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 13),
        ),
        MCalRecurrenceException.deleted(
          originalDate: DateTime(2026, 1, 20),
        ),
      ]);

      expect(controller.lastChange!.type, MCalChangeType.bulkChange);
      expect(controller.lastChange!.affectedEventIds, contains('weekly1'));
    });

    test('modifyOccurrence sets lastChange.type to exceptionAdded', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

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

      // modifyOccurrence delegates to addException
      expect(controller.lastChange!.type, MCalChangeType.exceptionAdded);
    });
  });

  // ==========================================================================
  // 13. Backward compatibility
  // ==========================================================================
  group('Backward compatibility', () {
    test('non-recurring events add and retrieve correctly', () {
      final controller = MCalEventController();
      final event = _singleEvent();
      controller.addEvents([event]);

      expect(controller.allEvents, contains(event));
      expect(controller.allEvents.length, 1);
    });

    test('non-recurring events return correctly from getEventsForRange', () {
      final controller = MCalEventController();
      final event = _singleEvent();
      controller.addEvents([event]);

      final events = controller.getEventsForRange(_januaryRange);
      expect(events.length, 1);
      expect(events.first.id, 'single1');
    });

    test('clearEvents works for non-recurring events', () {
      final controller = MCalEventController();
      controller.addEvents([_singleEvent(), _singleEvent(id: 'single2')]);
      expect(controller.allEvents.length, 2);

      controller.clearEvents();
      expect(controller.allEvents, isEmpty);
    });

    test('non-recurring events range filtering works correctly', () {
      final controller = MCalEventController();
      final janEvent = _singleEvent(start: DateTime(2026, 1, 15, 10, 0));
      final febEvent = _singleEvent(
        id: 'single2',
        start: DateTime(2026, 2, 15, 10, 0),
      );

      controller.addEvents([janEvent, febEvent]);

      final janEvents = controller.getEventsForRange(_januaryRange);
      expect(janEvents.length, 1);
      expect(janEvents.first.id, 'single1');
    });

    test('getEventById works for non-recurring events', () {
      final controller = MCalEventController();
      final event = _singleEvent();
      controller.addEvents([event]);

      expect(controller.getEventById('single1'), event);
      expect(controller.getEventById('nonexistent'), isNull);
    });

    test('removeEvents works for non-recurring events', () {
      final controller = MCalEventController();
      controller.addEvents([_singleEvent()]);
      expect(controller.allEvents.length, 1);

      controller.removeEvents(['single1']);
      expect(controller.allEvents, isEmpty);
    });

    test('listeners still fire for non-recurring operations', () {
      final controller = MCalEventController();
      var notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.addEvents([_singleEvent()]);
      expect(notifyCount, 1);

      controller.clearEvents();
      expect(notifyCount, 2);
    });
  });

  // ==========================================================================
  // 14. Bug fixes - rescheduled occurrence range boundaries
  // ==========================================================================
  group('Rescheduled occurrence range boundaries', () {
    test('rescheduled occurrence outside query range is excluded', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Reschedule Jan 13 occurrence to Feb 5 (outside January range)
      controller.addException(
        'weekly1',
        MCalRecurrenceException.rescheduled(
          originalDate: DateTime(2026, 1, 13),
          newDate: DateTime(2026, 2, 5, 10, 0),
        ),
      );

      final events = controller.getEventsForRange(_januaryRange);

      // Should be 3: Jan 6, 20, 27 (Jan 13 is rescheduled out of range)
      expect(events.length, 3);

      // Verify none of the events are on Feb 5
      final feb5 = events.where((e) => e.start.month == 2 && e.start.day == 5);
      expect(feb5, isEmpty);
    });

    test('rescheduled occurrence appears in the new date range', () {
      final controller = MCalEventController();
      controller.addEvents([_weeklyEvent()]);

      // Reschedule Jan 13 occurrence to Feb 5
      controller.addException(
        'weekly1',
        MCalRecurrenceException.rescheduled(
          originalDate: DateTime(2026, 1, 13),
          newDate: DateTime(2026, 2, 5, 10, 0),
        ),
      );

      final febRange = DateTimeRange(
        start: DateTime(2026, 2, 1),
        end: DateTime(2026, 2, 28, 23, 59, 59),
      );
      final events = controller.getEventsForRange(febRange);

      // Should include the rescheduled occurrence on Feb 5 plus regular Feb Tuesdays
      final feb5 = events.where((e) => e.start.day == 5 && e.start.month == 2);
      expect(feb5.length, 1);
    });

    test('rescheduled from outside range into range appears', () {
      final controller = MCalEventController();
      // Weekly starting Jan 6
      controller.addEvents([_weeklyEvent()]);

      // Reschedule Dec 30 2025 occurrence (outside Jan range) to Jan 15
      // First we need an occurrence on Dec 30 — our weekly event starts Jan 6,
      // so Dec 30 is before the start. Let's use a different approach:
      // Reschedule a February occurrence into January
      controller.addException(
        'weekly1',
        MCalRecurrenceException.rescheduled(
          originalDate: DateTime(2026, 2, 3), // First Tuesday in Feb
          newDate: DateTime(2026, 1, 15, 10, 0), // Move into January
        ),
      );

      final events = controller.getEventsForRange(_januaryRange);

      // Regular January Tuesdays: Jan 6, 13, 20, 27 = 4
      // Plus the rescheduled Feb 3 occurrence now on Jan 15 = 5
      expect(events.length, 5);

      final jan15 = events.where(
        (e) => e.start.day == 15 && e.start.month == 1,
      );
      expect(jan15.length, 1);
    });
  });

  // ==========================================================================
  // 15. Bug fix - removeEvents sets lastChange
  // ==========================================================================
  group('removeEvents lastChange', () {
    test('removeEvents sets lastChange with bulkChange type', () {
      final controller = MCalEventController();
      controller.addEvents([_singleEvent()]);

      controller.removeEvents(['single1']);

      expect(controller.lastChange, isNotNull);
      expect(controller.lastChange!.type, MCalChangeType.bulkChange);
      expect(controller.lastChange!.affectedEventIds, contains('single1'));
    });

    test('removeEvents sets affectedEventIds for all removed events', () {
      final controller = MCalEventController();
      controller.addEvents([
        _singleEvent(id: 'a'),
        _singleEvent(id: 'b'),
      ]);

      controller.removeEvents(['a', 'b']);

      expect(controller.lastChange!.affectedEventIds, containsAll(['a', 'b']));
    });
  });
}
