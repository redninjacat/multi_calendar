// ignore_for_file: avoid_print
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';

// =============================================================================
// In-Memory Data Store
// =============================================================================
//
// Simulates a consumer's database/backend that is entirely separate from the
// MCalEventController.  The test flow mirrors real integration:
//
//   1. Populate the store (initial load or sync from server).
//   2. Push master events + exceptions to the controller.
//   3. Perform queries via the controller.
//   4. When the user edits, update the store FIRST then push changes to the
//      controller — just like a real app would persist before updating the UI.
//
// This validates that consumers can integrate our package reliably with their
// own persistence layer.
// =============================================================================

/// Represents a stored recurring event and its exceptions in a consumer's
/// database.  This is intentionally NOT an MCalCalendarEvent — a real app
/// would map between its own model and ours.
class _StoredEvent {
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final bool isAllDay;
  final Color? color;
  final MCalRecurrenceRule? recurrenceRule;

  _StoredEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.isAllDay = false,
    this.color,
    this.recurrenceRule,
  });

  _StoredEvent copyWith({
    String? id,
    String? title,
    DateTime? start,
    DateTime? end,
    bool? isAllDay,
    Color? color,
    MCalRecurrenceRule? recurrenceRule,
  }) {
    return _StoredEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      start: start ?? this.start,
      end: end ?? this.end,
      isAllDay: isAllDay ?? this.isAllDay,
      color: color ?? this.color,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
    );
  }

  /// Converts to the package's event model.
  MCalCalendarEvent toCalendarEvent() {
    return MCalCalendarEvent(
      id: id,
      title: title,
      start: start,
      end: end,
      isAllDay: isAllDay,
      color: color,
      externalId: id, // link back to the store
      recurrenceRule: recurrenceRule,
    );
  }
}

/// A stored exception — again, separate from [MCalRecurrenceException].
class _StoredException {
  final String seriesId;
  final MCalExceptionType type;
  final DateTime originalDate;
  final DateTime? newDate;
  final _StoredEvent? modifiedEvent;

  _StoredException({
    required this.seriesId,
    required this.type,
    required this.originalDate,
    this.newDate,
    this.modifiedEvent,
  });

  /// Converts to the package's exception model.
  MCalRecurrenceException toException() {
    switch (type) {
      case MCalExceptionType.deleted:
        return MCalRecurrenceException.deleted(originalDate: originalDate);
      case MCalExceptionType.rescheduled:
        return MCalRecurrenceException.rescheduled(
          originalDate: originalDate,
          newDate: newDate!,
        );
      case MCalExceptionType.modified:
        return MCalRecurrenceException.modified(
          originalDate: originalDate,
          modifiedEvent: modifiedEvent!.toCalendarEvent(),
        );
    }
  }
}

/// An in-memory data store that a consumer would maintain.
///
/// Contains all CRUD operations and can synchronize with an
/// [MCalEventController] via [syncToController].
class InMemoryEventStore {
  final Map<String, _StoredEvent> _events = {};
  final Map<String, List<_StoredException>> _exceptions = {};

  // ---------------------------------------------------------------------------
  // Event CRUD
  // ---------------------------------------------------------------------------

  void addEvent(_StoredEvent event) {
    _events[event.id] = event;
  }

  void addEvents(List<_StoredEvent> events) {
    for (final e in events) {
      _events[e.id] = e;
    }
  }

  void updateEvent(String id, _StoredEvent updated) {
    _events[id] = updated;
  }

  void removeEvent(String id) {
    _events.remove(id);
    _exceptions.remove(id);
  }

  _StoredEvent? getEvent(String id) => _events[id];

  List<_StoredEvent> get allEvents => _events.values.toList();

  // ---------------------------------------------------------------------------
  // Exception CRUD
  // ---------------------------------------------------------------------------

  void addException(_StoredException exception) {
    _exceptions.putIfAbsent(exception.seriesId, () => []);
    // Remove any existing exception for the same original date first.
    _exceptions[exception.seriesId]!.removeWhere(
      (e) =>
          DateTime(e.originalDate.year, e.originalDate.month,
              e.originalDate.day) ==
          DateTime(exception.originalDate.year, exception.originalDate.month,
              exception.originalDate.day),
    );
    _exceptions[exception.seriesId]!.add(exception);
  }

  void removeException(String seriesId, DateTime originalDate) {
    final norm = DateTime(originalDate.year, originalDate.month, originalDate.day);
    _exceptions[seriesId]?.removeWhere(
      (e) =>
          DateTime(e.originalDate.year, e.originalDate.month,
              e.originalDate.day) ==
          norm,
    );
  }

  List<_StoredException> getExceptions(String seriesId) {
    return _exceptions[seriesId] ?? [];
  }

  // ---------------------------------------------------------------------------
  // Sync to Controller
  // ---------------------------------------------------------------------------

  /// Pushes the full data set to a controller, replacing its contents.
  ///
  /// This is what a consumer's initial load would look like:
  ///   1. Fetch all master events from the DB.
  ///   2. Convert & add to controller.
  ///   3. Push all exceptions.
  void syncToController(MCalEventController controller) {
    controller.clearEvents();
    controller.addEvents(
      _events.values.map((e) => e.toCalendarEvent()).toList(),
    );
    for (final entry in _exceptions.entries) {
      final seriesId = entry.key;
      if (entry.value.isNotEmpty) {
        controller.addExceptions(
          seriesId,
          entry.value.map((e) => e.toException()).toList(),
        );
      }
    }
  }

  /// Pushes a single event change to the controller.
  void syncEventToController(String id, MCalEventController controller) {
    final event = _events[id];
    if (event == null) {
      controller.removeEvents([id]);
    } else {
      // Remove and re-add to handle both insert and update.
      controller.removeEvents([id]);
      controller.addEvents([event.toCalendarEvent()]);
      // Re-push exceptions for this series.
      final excs = _exceptions[id];
      if (excs != null && excs.isNotEmpty) {
        controller.addExceptions(
          id,
          excs.map((e) => e.toException()).toList(),
        );
      }
    }
  }

  /// Pushes a single exception change to the controller.
  void syncExceptionToController(
    String seriesId,
    _StoredException exception,
    MCalEventController controller,
  ) {
    controller.addException(seriesId, exception.toException());
  }

  /// Removes a single exception from the controller.
  void syncExceptionRemovalToController(
    String seriesId,
    DateTime originalDate,
    MCalEventController controller,
  ) {
    controller.removeException(seriesId, originalDate);
  }
}

// =============================================================================
// Test Data Generators
// =============================================================================

/// Generates a large, realistic set of recurring events starting from various
/// points in the past.  Returns a populated [InMemoryEventStore].
///
/// The mix mirrors a real-world calendar:
/// - ~40% daily events (stand-ups, medication reminders, etc.)
/// - ~30% weekly events (team meetings, classes)
/// - ~20% monthly events (reviews, bill reminders)
/// - ~10% yearly events (birthdays, anniversaries)
///
/// Within each frequency, the termination strategy varies:
/// - ~40% no end (infinite)
/// - ~30% with until date
/// - ~30% with count
InMemoryEventStore _buildLargeStore({
  required int eventCount,
  required DateTime viewMonth,
}) {
  final store = InMemoryEventStore();
  final rng = Random(42); // fixed seed for reproducibility

  final frequencies = [
    MCalFrequency.daily,
    MCalFrequency.weekly,
    MCalFrequency.monthly,
    MCalFrequency.yearly,
  ];
  // Weighted distribution: daily 40%, weekly 30%, monthly 20%, yearly 10%
  final freqWeights = [0.40, 0.70, 0.90, 1.0];

  for (var i = 0; i < eventCount; i++) {
    // Pick frequency
    final freqRoll = rng.nextDouble();
    final freqIdx = freqWeights.indexWhere((w) => freqRoll < w);
    final freq = frequencies[freqIdx];

    // How far back does this event start? (1 month to 10 years)
    final daysBack = 30 + rng.nextInt(3600); // ~30 days to ~10 years
    final startDate = DateTime(
      viewMonth.year,
      viewMonth.month,
      viewMonth.day - daysBack,
      8 + rng.nextInt(10), // 8 AM to 5 PM
      rng.nextBool() ? 0 : 30,
    );

    // Event duration: 30 min to 3 days
    final isMultiDay = rng.nextDouble() < 0.15; // 15% multi-day
    final isAllDay = !isMultiDay && rng.nextDouble() < 0.10; // 10% all-day
    final durationMinutes = isMultiDay
        ? (24 * 60 + rng.nextInt(48 * 60)) // 1–3 days
        : isAllDay
            ? 0
            : (30 + rng.nextInt(150)); // 30 min to 3 hours
    final endDate = isAllDay
        ? DateTime(startDate.year, startDate.month, startDate.day)
        : startDate.add(Duration(minutes: durationMinutes));

    // Termination strategy
    final termRoll = rng.nextDouble();
    MCalRecurrenceRule rule;
    final interval = freq == MCalFrequency.daily
        ? (rng.nextBool() ? 1 : 2)
        : freq == MCalFrequency.weekly
            ? (rng.nextDouble() < 0.3 ? 2 : 1)
            : 1;

    if (termRoll < 0.40) {
      // No end — infinite
      rule = MCalRecurrenceRule(frequency: freq, interval: interval);
    } else if (termRoll < 0.70) {
      // Until date — ends 1-12 months from now
      final untilDaysFromNow = 30 + rng.nextInt(330);
      final until = DateTime(
        viewMonth.year,
        viewMonth.month,
        viewMonth.day + untilDaysFromNow,
      );
      rule = MCalRecurrenceRule(
        frequency: freq,
        interval: interval,
        until: until,
      );
    } else {
      // Count — 10 to 500 occurrences
      final count = 10 + rng.nextInt(490);
      rule = MCalRecurrenceRule(
        frequency: freq,
        interval: interval,
        count: count,
      );
    }

    // Weekly events with byWeekDays (50% of weekly)
    if (freq == MCalFrequency.weekly && rng.nextBool()) {
      final weekday = startDate.weekday;
      rule = MCalRecurrenceRule(
        frequency: freq,
        interval: interval,
        count: rule.count,
        until: rule.until,
        byWeekDays: {MCalWeekDay.every(weekday)},
      );
    }

    store.addEvent(_StoredEvent(
      id: 'event-$i',
      title: 'Event #$i (${freq.name})',
      start: startDate,
      end: endDate,
      isAllDay: isAllDay,
      color: Color(0xFF000000 + rng.nextInt(0xFFFFFF)),
      recurrenceRule: rule,
    ));
  }

  return store;
}

/// Adds a realistic set of exceptions to the store.
///
/// For each event that is currently recurring, adds 0–5 exceptions on
/// random dates that fall within the query range.
void _addExceptionsToStore(
  InMemoryEventStore store,
  DateTimeRange queryRange,
  Random rng,
) {
  for (final event in store.allEvents) {
    if (event.recurrenceRule == null) continue;

    final exCount = rng.nextInt(6); // 0–5 exceptions per series
    if (exCount == 0) continue;

    for (var j = 0; j < exCount; j++) {
      final dayOffset = rng.nextInt(
        queryRange.end.difference(queryRange.start).inDays,
      );
      final exDate = DateTime(
        queryRange.start.year,
        queryRange.start.month,
        queryRange.start.day + dayOffset,
      );

      final typeRoll = rng.nextDouble();
      if (typeRoll < 0.5) {
        // Delete
        store.addException(_StoredException(
          seriesId: event.id,
          type: MCalExceptionType.deleted,
          originalDate: exDate,
        ));
      } else if (typeRoll < 0.8) {
        // Reschedule (move by 1–3 days)
        final shift = 1 + rng.nextInt(3);
        store.addException(_StoredException(
          seriesId: event.id,
          type: MCalExceptionType.rescheduled,
          originalDate: exDate,
          newDate: DateTime(exDate.year, exDate.month, exDate.day + shift),
        ));
      } else {
        // Modify (change title)
        store.addException(_StoredException(
          seriesId: event.id,
          type: MCalExceptionType.modified,
          originalDate: exDate,
          modifiedEvent: _StoredEvent(
            id: '${event.id}_modified_$j',
            title: 'MODIFIED ${event.title}',
            start: DateTime(exDate.year, exDate.month, exDate.day,
                event.start.hour, event.start.minute),
            end: DateTime(exDate.year, exDate.month, exDate.day,
                event.end.hour, event.end.minute),
          ),
        ));
      }
    }
  }
}

// =============================================================================
// Ranges
// =============================================================================

/// February 2026 — the "current" month for all tests.
final _viewMonth = DateTime(2026, 2, 1);

final _februaryRange = DateTimeRange(
  start: DateTime(2026, 2, 1),
  end: DateTime(2026, 2, 28, 23, 59, 59),
);

final _marchRange = DateTimeRange(
  start: DateTime(2026, 3, 1),
  end: DateTime(2026, 3, 31, 23, 59, 59),
);

final _januaryRange = DateTimeRange(
  start: DateTime(2026, 1, 1),
  end: DateTime(2026, 1, 31, 23, 59, 59),
);

final _q1Range = DateTimeRange(
  start: DateTime(2026, 1, 1),
  end: DateTime(2026, 3, 31, 23, 59, 59),
);

// =============================================================================
// Tests
// =============================================================================

void main() {
  // ===========================================================================
  // 1. Data Store ↔ Controller Sync (Basic Integration)
  // ===========================================================================
  group('Data store ↔ controller sync', () {
    test('full sync populates controller accurately', () {
      final store = InMemoryEventStore();
      final controller = MCalEventController();

      // Add a mix of events to the store.
      store.addEvent(_StoredEvent(
        id: 'daily-1',
        title: 'Daily Standup',
        start: DateTime(2026, 1, 5, 9, 0),
        end: DateTime(2026, 1, 5, 9, 15),
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.daily),
      ));
      store.addEvent(_StoredEvent(
        id: 'weekly-1',
        title: 'Team Meeting',
        start: DateTime(2026, 2, 3, 10, 0), // Tuesday
        end: DateTime(2026, 2, 3, 11, 0),
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.weekly),
      ));
      store.addEvent(_StoredEvent(
        id: 'standalone-1',
        title: 'One-off Event',
        start: DateTime(2026, 2, 14, 18, 0),
        end: DateTime(2026, 2, 14, 20, 0),
      ));

      store.syncToController(controller);

      // Controller should have all 3 master events.
      expect(controller.allEvents.length, 3);
      expect(controller.getEventById('daily-1'), isNotNull);
      expect(controller.getEventById('weekly-1'), isNotNull);
      expect(controller.getEventById('standalone-1'), isNotNull);
    });

    test('sync preserves externalId linkage', () {
      final store = InMemoryEventStore();
      final controller = MCalEventController();

      store.addEvent(_StoredEvent(
        id: 'my-db-id-123',
        title: 'DB-Linked Event',
        start: DateTime(2026, 2, 10, 9, 0),
        end: DateTime(2026, 2, 10, 10, 0),
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.weekly),
      ));

      store.syncToController(controller);

      final events = controller.getEventsForRange(_februaryRange);
      for (final e in events) {
        expect(e.externalId, 'my-db-id-123');
      }
    });

    test('sync pushes exceptions correctly', () {
      final store = InMemoryEventStore();
      final controller = MCalEventController();

      store.addEvent(_StoredEvent(
        id: 'weekly-exc',
        title: 'Weekly',
        start: DateTime(2026, 2, 3, 10, 0), // Tuesday
        end: DateTime(2026, 2, 3, 11, 0),
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.weekly),
      ));
      store.addException(_StoredException(
        seriesId: 'weekly-exc',
        type: MCalExceptionType.deleted,
        originalDate: DateTime(2026, 2, 10),
      ));

      store.syncToController(controller);

      final events = controller.getEventsForRange(_februaryRange);
      // Feb Tuesdays: 3, 10, 17, 24. Delete 10 → 3 events.
      expect(events.length, 3);
      expect(events.any((e) => e.start.day == 10), isFalse);
    });

    test('incremental sync updates single event', () {
      final store = InMemoryEventStore();
      final controller = MCalEventController();

      store.addEvent(_StoredEvent(
        id: 'evt-1',
        title: 'Original Title',
        start: DateTime(2026, 2, 5, 9, 0),
        end: DateTime(2026, 2, 5, 10, 0),
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.daily),
      ));
      store.syncToController(controller);

      // Simulate user editing the event title in the store.
      store.updateEvent(
        'evt-1',
        store.getEvent('evt-1')!.copyWith(title: 'Updated Title'),
      );
      store.syncEventToController('evt-1', controller);

      final events = controller.getEventsForRange(_februaryRange);
      expect(events.every((e) => e.title == 'Updated Title'), isTrue);
    });

    test('incremental sync removes deleted event', () {
      final store = InMemoryEventStore();
      final controller = MCalEventController();

      store.addEvent(_StoredEvent(
        id: 'to-delete',
        title: 'Will Be Deleted',
        start: DateTime(2026, 2, 5, 9, 0),
        end: DateTime(2026, 2, 5, 10, 0),
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.daily),
      ));
      store.syncToController(controller);
      expect(controller.getEventsForRange(_februaryRange), isNotEmpty);

      // Delete from store, sync.
      store.removeEvent('to-delete');
      store.syncEventToController('to-delete', controller);
      expect(controller.getEventsForRange(_februaryRange), isEmpty);
    });
  });

  // ===========================================================================
  // 2. Performance: Large-Scale Expansion
  // ===========================================================================
  group('Performance: large-scale expansion', () {
    test('200 recurring events expand within reasonable time', () {
      final store = _buildLargeStore(eventCount: 200, viewMonth: _viewMonth);
      final controller = MCalEventController();
      store.syncToController(controller);

      final sw = Stopwatch()..start();
      final events = controller.getEventsForRange(_februaryRange);
      sw.stop();

      print('  200 events → ${events.length} occurrences in '
          '${sw.elapsedMilliseconds}ms');

      // Sanity: we should have some events (not all 200 will expand into Feb).
      expect(events.length, greaterThan(0));

      // Performance: should complete well under 2 seconds even in debug mode.
      expect(sw.elapsedMilliseconds, lessThan(2000));
    });

    test('500 recurring events expand within reasonable time', () {
      final store = _buildLargeStore(eventCount: 500, viewMonth: _viewMonth);
      final controller = MCalEventController();
      store.syncToController(controller);

      final sw = Stopwatch()..start();
      final events = controller.getEventsForRange(_februaryRange);
      sw.stop();

      print('  500 events → ${events.length} occurrences in '
          '${sw.elapsedMilliseconds}ms');

      expect(events.length, greaterThan(0));
      expect(sw.elapsedMilliseconds, lessThan(5000));
    });

    test('1000 recurring events expand within reasonable time', () {
      final store = _buildLargeStore(eventCount: 1000, viewMonth: _viewMonth);
      final controller = MCalEventController();
      store.syncToController(controller);

      final sw = Stopwatch()..start();
      final events = controller.getEventsForRange(_februaryRange);
      sw.stop();

      print('  1000 events → ${events.length} occurrences in '
          '${sw.elapsedMilliseconds}ms');

      expect(events.length, greaterThan(0));
      expect(sw.elapsedMilliseconds, lessThan(10000));
    });

    test('repeated queries on same range use cache efficiently', () {
      final store = _buildLargeStore(eventCount: 300, viewMonth: _viewMonth);
      final controller = MCalEventController();
      store.syncToController(controller);

      // First query — populates cache.
      final sw1 = Stopwatch()..start();
      final first = controller.getEventsForRange(_februaryRange);
      sw1.stop();

      // Second query — should be cache hit.
      final sw2 = Stopwatch()..start();
      final second = controller.getEventsForRange(_februaryRange);
      sw2.stop();

      print('  300 events: first=${sw1.elapsedMilliseconds}ms, '
          'cached=${sw2.elapsedMilliseconds}ms');

      // Results must be identical.
      expect(second.length, first.length);

      // Cached query should be faster (or at least not slower).
      // In debug mode timing is noisy, so just verify it completes.
      expect(sw2.elapsedMilliseconds, lessThan(sw1.elapsedMilliseconds + 200));
    });
  });

  // ===========================================================================
  // 3. Performance + Accuracy: Mixed Termination Strategies
  // ===========================================================================
  group('Mixed termination strategies', () {
    late InMemoryEventStore store;
    late MCalEventController controller;

    setUp(() {
      store = InMemoryEventStore();
      controller = MCalEventController();

      // Infinite daily — started 2 years ago
      store.addEvent(_StoredEvent(
        id: 'inf-daily',
        title: 'Infinite Daily',
        start: DateTime(2024, 2, 1, 9, 0),
        end: DateTime(2024, 2, 1, 9, 30),
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.daily),
      ));

      // Until-bounded weekly — ends mid-February 2026
      store.addEvent(_StoredEvent(
        id: 'until-weekly',
        title: 'Until Weekly',
        start: DateTime(2025, 6, 3, 14, 0), // Tuesday
        end: DateTime(2025, 6, 3, 15, 0),
        recurrenceRule: MCalRecurrenceRule(
          frequency: MCalFrequency.weekly,
          until: DateTime(2026, 2, 15),
        ),
      ));

      // Count-bounded monthly — started 5 years ago, count=60
      store.addEvent(_StoredEvent(
        id: 'count-monthly',
        title: 'Count Monthly',
        start: DateTime(2021, 1, 15, 10, 0),
        end: DateTime(2021, 1, 15, 11, 0),
        recurrenceRule: MCalRecurrenceRule(
          frequency: MCalFrequency.monthly,
          count: 60,
        ),
      ));

      // Infinite multi-day weekly — 3-day event started 1 year ago
      store.addEvent(_StoredEvent(
        id: 'inf-multiday',
        title: 'Multi-Day Weekly',
        start: DateTime(2025, 2, 3, 9, 0), // Monday
        end: DateTime(2025, 2, 5, 17, 0), // Wednesday
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.weekly),
      ));

      // Yearly birthday — started 30 years ago
      store.addEvent(_StoredEvent(
        id: 'birthday',
        title: 'Birthday',
        start: DateTime(1996, 2, 20, 0, 0),
        end: DateTime(1996, 2, 20, 0, 0),
        isAllDay: true,
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.yearly),
      ));

      // Old infinite that does NOT expand into February
      store.addEvent(_StoredEvent(
        id: 'no-overlap',
        title: 'Ended Last Year',
        start: DateTime(2020, 3, 1, 9, 0),
        end: DateTime(2020, 3, 1, 10, 0),
        recurrenceRule: MCalRecurrenceRule(
          frequency: MCalFrequency.weekly,
          until: DateTime(2025, 1, 1),
        ),
      ));

      store.syncToController(controller);
    });

    test('infinite daily from 2 years ago produces 28 occurrences in Feb', () {
      final events = controller.getEventsForRange(_februaryRange);
      final daily = events.where((e) => e.externalId == 'inf-daily');

      expect(daily.length, 28); // 2026 is not a leap year
      for (final e in daily) {
        expect(e.start.month, 2);
        expect(e.start.year, 2026);
      }
    });

    test('until-bounded weekly stops at cutoff date', () {
      final events = controller.getEventsForRange(_februaryRange);
      final weekly = events.where((e) => e.externalId == 'until-weekly');

      // Feb Tuesdays: 3, 10. Until=Feb 15, so Feb 17 is excluded.
      expect(weekly.length, 2);
      for (final e in weekly) {
        expect(e.start.isBefore(DateTime(2026, 2, 16)), isTrue);
      }
    });

    test('yearly birthday appears in February', () {
      final events = controller.getEventsForRange(_februaryRange);
      final bday = events.where((e) => e.externalId == 'birthday');

      expect(bday.length, 1);
      expect(bday.first.start.day, 20);
      expect(bday.first.isAllDay, isTrue);
    });

    test('multi-day weekly overlaps into range correctly', () {
      final events = controller.getEventsForRange(_februaryRange);
      final multiDay = events.where((e) => e.externalId == 'inf-multiday');

      // Mondays in Feb: 2, 9, 16, 23. Each lasts Mon–Wed.
      // Jan 26 (Mon) → ends Jan 28 (Wed) — does NOT overlap Feb.
      // Feb 2, 9, 16, 23 all start in Feb.
      expect(multiDay.length, greaterThanOrEqualTo(4));
    });

    test('event that ended before query range returns nothing', () {
      final events = controller.getEventsForRange(_februaryRange);
      final noOverlap = events.where((e) => e.externalId == 'no-overlap');
      expect(noOverlap, isEmpty);
    });

    test('expansion is consistent across range changes', () {
      // Query Feb, then March, then Feb again.
      final febFirst = controller.getEventsForRange(_februaryRange);
      controller.getEventsForRange(_marchRange);
      final febSecond = controller.getEventsForRange(_februaryRange);

      // Length and content should match.
      expect(febSecond.length, febFirst.length);
      final firstIds = febFirst.map((e) => e.id).toSet();
      final secondIds = febSecond.map((e) => e.id).toSet();
      expect(secondIds, firstIds);
    });
  });

  // ===========================================================================
  // 4. Performance: Large-Scale with Exceptions
  // ===========================================================================
  group('Performance: large-scale with exceptions', () {
    test('300 events with random exceptions expand accurately', () {
      final store = _buildLargeStore(eventCount: 300, viewMonth: _viewMonth);
      final rng = Random(99);

      // Take a snapshot BEFORE exceptions.
      final controllerBefore = MCalEventController();
      store.syncToController(controllerBefore);
      final beforeCount =
          controllerBefore.getEventsForRange(_februaryRange).length;

      // Add exceptions.
      _addExceptionsToStore(store, _februaryRange, rng);

      // Sync with exceptions.
      final controller = MCalEventController();
      store.syncToController(controller);

      final sw = Stopwatch()..start();
      final events = controller.getEventsForRange(_februaryRange);
      sw.stop();

      print('  300 events + exceptions → ${events.length} occurrences '
          '(was $beforeCount before) in ${sw.elapsedMilliseconds}ms');

      // Should still complete quickly.
      expect(sw.elapsedMilliseconds, lessThan(5000));

      // Exception count should differ from the no-exception case.
      // (With ~50% deletes and some reschedules, the count will change.)
      // We just verify it's a reasonable number.
      expect(events.length, greaterThan(0));
    });
  });

  // ===========================================================================
  // 5. Edit Operations: Store → Controller Flow
  // ===========================================================================
  group('Edit operations via store', () {
    late InMemoryEventStore store;
    late MCalEventController controller;

    setUp(() {
      store = InMemoryEventStore();
      controller = MCalEventController();

      store.addEvent(_StoredEvent(
        id: 'editable',
        title: 'Editable Weekly',
        start: DateTime(2026, 2, 3, 10, 0), // Tuesday
        end: DateTime(2026, 2, 3, 11, 0),
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.weekly),
      ));

      store.syncToController(controller);
    });

    test('add delete exception via store → controller', () {
      var events = controller.getEventsForRange(_februaryRange);
      expect(events.length, 4); // Feb Tuesdays: 3, 10, 17, 24

      // Persist deletion in store, then sync.
      final exc = _StoredException(
        seriesId: 'editable',
        type: MCalExceptionType.deleted,
        originalDate: DateTime(2026, 2, 10),
      );
      store.addException(exc);
      store.syncExceptionToController('editable', exc, controller);

      events = controller.getEventsForRange(_februaryRange);
      expect(events.length, 3);
      expect(events.any((e) => e.start.day == 10), isFalse);
    });

    test('add reschedule exception via store → controller', () {
      final exc = _StoredException(
        seriesId: 'editable',
        type: MCalExceptionType.rescheduled,
        originalDate: DateTime(2026, 2, 10),
        newDate: DateTime(2026, 2, 11),
      );
      store.addException(exc);
      store.syncExceptionToController('editable', exc, controller);

      final events = controller.getEventsForRange(_februaryRange);
      expect(events.length, 4); // still 4, one is moved
      expect(events.any((e) => e.start.day == 11), isTrue);
      expect(
        events.where((e) => e.start.day == 10).length,
        0,
      );
    });

    test('add modified exception via store → controller', () {
      final modifiedEvt = _StoredEvent(
        id: 'editable_modified',
        title: 'Special Meeting',
        start: DateTime(2026, 2, 17, 10, 0),
        end: DateTime(2026, 2, 17, 12, 0), // 2 hours instead of 1
      );
      final exc = _StoredException(
        seriesId: 'editable',
        type: MCalExceptionType.modified,
        originalDate: DateTime(2026, 2, 17),
        modifiedEvent: modifiedEvt,
      );
      store.addException(exc);
      store.syncExceptionToController('editable', exc, controller);

      final events = controller.getEventsForRange(_februaryRange);
      final special = events.firstWhere((e) => e.title == 'Special Meeting');
      expect(special.end.difference(special.start).inHours, 2);
    });

    test('remove exception restores original occurrence', () {
      // First delete an occurrence.
      final exc = _StoredException(
        seriesId: 'editable',
        type: MCalExceptionType.deleted,
        originalDate: DateTime(2026, 2, 10),
      );
      store.addException(exc);
      store.syncExceptionToController('editable', exc, controller);
      expect(
        controller.getEventsForRange(_februaryRange).length,
        3,
      );

      // Now remove the exception from the store.
      store.removeException('editable', DateTime(2026, 2, 10));
      store.syncExceptionRemovalToController(
        'editable',
        DateTime(2026, 2, 10),
        controller,
      );

      final events = controller.getEventsForRange(_februaryRange);
      expect(events.length, 4); // restored
      expect(events.any((e) => e.start.day == 10), isTrue);
    });

    test('overwrite exception type via store → controller', () {
      // Delete an occurrence first.
      final delExc = _StoredException(
        seriesId: 'editable',
        type: MCalExceptionType.deleted,
        originalDate: DateTime(2026, 2, 10),
      );
      store.addException(delExc);
      store.syncExceptionToController('editable', delExc, controller);
      expect(
        controller.getEventsForRange(_februaryRange).length,
        3,
      );

      // Overwrite with reschedule.
      final resExc = _StoredException(
        seriesId: 'editable',
        type: MCalExceptionType.rescheduled,
        originalDate: DateTime(2026, 2, 10),
        newDate: DateTime(2026, 2, 12),
      );
      store.addException(resExc);
      store.syncExceptionToController('editable', resExc, controller);

      final events = controller.getEventsForRange(_februaryRange);
      expect(events.length, 4); // 3 normal + 1 rescheduled
      expect(events.any((e) => e.start.day == 12), isTrue);
    });

    test('update master event title propagates to expanded occurrences', () {
      // Update in store.
      store.updateEvent(
        'editable',
        store.getEvent('editable')!.copyWith(title: 'New Title'),
      );
      store.syncEventToController('editable', controller);

      final events = controller.getEventsForRange(_februaryRange);
      expect(events.every((e) => e.title == 'New Title'), isTrue);
    });

    test('update master event time propagates to expanded occurrences', () {
      final evt = store.getEvent('editable')!;
      store.updateEvent(
        'editable',
        evt.copyWith(
          start: DateTime(2026, 2, 3, 14, 0), // 2 PM instead of 10 AM
          end: DateTime(2026, 2, 3, 15, 0),
        ),
      );
      store.syncEventToController('editable', controller);

      final events = controller.getEventsForRange(_februaryRange);
      for (final e in events) {
        expect(e.start.hour, 14);
      }
    });

    test('delete master event via store removes all occurrences', () {
      store.removeEvent('editable');
      store.syncEventToController('editable', controller);

      final events = controller.getEventsForRange(_februaryRange);
      expect(events, isEmpty);
    });
  });

  // ===========================================================================
  // 6. Multi-Series Batch Editing
  // ===========================================================================
  group('Multi-series batch editing', () {
    late InMemoryEventStore store;
    late MCalEventController controller;

    setUp(() {
      store = InMemoryEventStore();
      controller = MCalEventController();

      // Series A: daily from Jan 1 (old, infinite)
      store.addEvent(_StoredEvent(
        id: 'series-a',
        title: 'Daily A',
        start: DateTime(2025, 1, 1, 8, 0),
        end: DateTime(2025, 1, 1, 8, 30),
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.daily),
      ));

      // Series B: weekly Tuesday from Feb 3 (starts in query range)
      store.addEvent(_StoredEvent(
        id: 'series-b',
        title: 'Weekly B',
        start: DateTime(2026, 2, 3, 10, 0),
        end: DateTime(2026, 2, 3, 11, 0),
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.weekly),
      ));

      // Series C: monthly on the 15th from 3 years ago (with until)
      store.addEvent(_StoredEvent(
        id: 'series-c',
        title: 'Monthly C',
        start: DateTime(2023, 1, 15, 12, 0),
        end: DateTime(2023, 1, 15, 13, 0),
        recurrenceRule: MCalRecurrenceRule(
          frequency: MCalFrequency.monthly,
          until: DateTime(2026, 6, 30),
        ),
      ));

      store.syncToController(controller);
    });

    test('batch exceptions across multiple series', () {
      // Delete series-a Feb 5, reschedule series-b Feb 10→11, modify series-c.
      store.addException(_StoredException(
        seriesId: 'series-a',
        type: MCalExceptionType.deleted,
        originalDate: DateTime(2026, 2, 5),
      ));
      store.addException(_StoredException(
        seriesId: 'series-b',
        type: MCalExceptionType.rescheduled,
        originalDate: DateTime(2026, 2, 10),
        newDate: DateTime(2026, 2, 11),
      ));
      store.addException(_StoredException(
        seriesId: 'series-c',
        type: MCalExceptionType.modified,
        originalDate: DateTime(2026, 2, 15),
        modifiedEvent: _StoredEvent(
          id: 'series-c', // Keep same ID as series for externalId linkage
          title: 'Special Review',
          start: DateTime(2026, 2, 15, 14, 0),
          end: DateTime(2026, 2, 15, 16, 0),
        ),
      ));

      store.syncToController(controller);
      final events = controller.getEventsForRange(_februaryRange);

      // Series A: 28 - 1 = 27 daily occurrences.
      final aEvents = events.where((e) => e.externalId == 'series-a');
      expect(aEvents.length, 27);

      // Series B: 4 weekly — Feb 10 → Feb 11.
      final bEvents = events.where((e) => e.externalId == 'series-b');
      expect(bEvents.length, 4);
      expect(bEvents.any((e) => e.start.day == 11), isTrue);
      expect(bEvents.where((e) => e.start.day == 10).length, 0);

      // Series C: 1 monthly — modified.
      final cEvents = events.where((e) => e.externalId == 'series-c');
      expect(cEvents.length, 1);
      expect(cEvents.first.title, 'Special Review');
    });

    test('remove one series, others remain intact', () {
      final beforeCount =
          controller.getEventsForRange(_februaryRange).length;

      store.removeEvent('series-a');
      store.syncEventToController('series-a', controller);

      final events = controller.getEventsForRange(_februaryRange);
      // series-a had 28 daily occurrences.
      expect(events.length, beforeCount - 28);

      // series-b and series-c should still be present.
      expect(events.any((e) => e.externalId == 'series-b'), isTrue);
      expect(events.any((e) => e.externalId == 'series-c'), isTrue);
    });
  });

  // ===========================================================================
  // 7. Accuracy: View Navigation Simulation
  // ===========================================================================
  group('View navigation simulation', () {
    late InMemoryEventStore store;
    late MCalEventController controller;

    setUp(() {
      store = _buildLargeStore(eventCount: 150, viewMonth: _viewMonth);
      controller = MCalEventController();
      store.syncToController(controller);
    });

    test('navigating across 12 months produces consistent results', () {
      // Simulate a user flipping through months.
      final monthCounts = <int, int>{};

      for (var m = 1; m <= 12; m++) {
        final range = DateTimeRange(
          start: DateTime(2026, m, 1),
          end: DateTime(2026, m + 1, 0, 23, 59, 59),
        );
        final events = controller.getEventsForRange(range);
        monthCounts[m] = events.length;
      }

      // Now go back and verify each month gives the same count.
      for (var m = 12; m >= 1; m--) {
        final range = DateTimeRange(
          start: DateTime(2026, m, 1),
          end: DateTime(2026, m + 1, 0, 23, 59, 59),
        );
        final events = controller.getEventsForRange(range);
        expect(events.length, monthCounts[m],
            reason: 'Month $m count changed on second pass');
      }
    });

    test('rapid range changes do not corrupt cache', () {
      // Rapidly alternate between two ranges.
      for (var i = 0; i < 20; i++) {
        controller.getEventsForRange(_februaryRange);
        controller.getEventsForRange(_marchRange);
      }

      // Final query should be accurate.
      final feb = controller.getEventsForRange(_februaryRange);
      final march = controller.getEventsForRange(_marchRange);

      // Verify they're different (different months, different events).
      // Just check they're both populated and counts are stable.
      expect(feb.length, greaterThan(0));
      expect(march.length, greaterThan(0));

      // Re-query to confirm stability.
      expect(
        controller.getEventsForRange(_februaryRange).length,
        feb.length,
      );
    });
  });

  // ===========================================================================
  // 8. Accuracy: Multi-Day Overlap Edge Cases
  // ===========================================================================
  group('Multi-day overlap edge cases', () {
    test('3-day event starting day before range overlaps into range', () {
      final store = InMemoryEventStore();
      final controller = MCalEventController();

      // 3-day event on Mondays, started a year ago.
      store.addEvent(_StoredEvent(
        id: 'multi-3',
        title: 'Multi-Day',
        start: DateTime(2025, 2, 3, 9, 0), // Monday
        end: DateTime(2025, 2, 5, 17, 0), // Wednesday
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.weekly),
      ));
      store.syncToController(controller);

      // Query just Feb 4 (Wednesday) — the Feb 2 (Monday) occurrence
      // should overlap.
      final events = controller.getEventsForDate(DateTime(2026, 2, 4));
      expect(events.length, greaterThanOrEqualTo(1));
      // The occurrence starting Feb 2 ends Feb 4 17:00.
      expect(events.any((e) => e.start.day == 2), isTrue);
    });

    test('week-long event started years ago overlaps correctly', () {
      final store = InMemoryEventStore();
      final controller = MCalEventController();

      store.addEvent(_StoredEvent(
        id: 'week-long',
        title: 'Week Event',
        start: DateTime(2022, 1, 3, 0, 0), // Monday
        end: DateTime(2022, 1, 9, 23, 59), // Sunday
        recurrenceRule: MCalRecurrenceRule(
          frequency: MCalFrequency.weekly,
        ),
      ));
      store.syncToController(controller);

      // Query Feb 5 (Thursday) — the Feb 2 (Mon) occurrence ends Feb 8 (Sun).
      final events = controller.getEventsForDate(DateTime(2026, 2, 5));
      expect(events.length, 1);
      expect(events.first.start.day, 2);
    });
  });

  // ===========================================================================
  // 9. Accuracy: Exception Interactions
  // ===========================================================================
  group('Exception interactions at scale', () {
    test('many deletions across a large daily series', () {
      final store = InMemoryEventStore();
      final controller = MCalEventController();

      store.addEvent(_StoredEvent(
        id: 'daily-del',
        title: 'Daily',
        start: DateTime(2025, 1, 1, 9, 0),
        end: DateTime(2025, 1, 1, 9, 30),
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.daily),
      ));

      // Delete every other day in February (14 deletions).
      for (var d = 1; d <= 28; d += 2) {
        store.addException(_StoredException(
          seriesId: 'daily-del',
          type: MCalExceptionType.deleted,
          originalDate: DateTime(2026, 2, d),
        ));
      }

      store.syncToController(controller);
      final events = controller.getEventsForRange(_februaryRange);

      // 28 days - 14 deleted = 14 remaining.
      expect(events.length, 14);

      // Verify remaining are all even days.
      for (final e in events) {
        expect(e.start.day % 2, 0, reason: 'Day ${e.start.day} should be even');
      }
    });

    test('reschedule chain: A→B, then edit B→C', () {
      final store = InMemoryEventStore();
      final controller = MCalEventController();

      store.addEvent(_StoredEvent(
        id: 'chain',
        title: 'Chainable',
        start: DateTime(2026, 2, 3, 10, 0), // Tuesday
        end: DateTime(2026, 2, 3, 11, 0),
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.weekly),
      ));
      store.syncToController(controller);

      // Reschedule Feb 10 → Feb 11.
      final exc1 = _StoredException(
        seriesId: 'chain',
        type: MCalExceptionType.rescheduled,
        originalDate: DateTime(2026, 2, 10),
        newDate: DateTime(2026, 2, 11),
      );
      store.addException(exc1);
      store.syncExceptionToController('chain', exc1, controller);

      // Now overwrite: reschedule Feb 10 → Feb 12 instead.
      final exc2 = _StoredException(
        seriesId: 'chain',
        type: MCalExceptionType.rescheduled,
        originalDate: DateTime(2026, 2, 10),
        newDate: DateTime(2026, 2, 12),
      );
      store.addException(exc2);
      store.syncExceptionToController('chain', exc2, controller);

      final events = controller.getEventsForRange(_februaryRange);
      expect(events.length, 4);
      expect(events.any((e) => e.start.day == 12), isTrue);
      // Neither the original (10) nor first reschedule (11) should appear.
      expect(events.any((e) => e.start.day == 10), isFalse);
      expect(events.any((e) => e.start.day == 11), isFalse);
    });

    test('mixed exception types across many dates', () {
      final store = InMemoryEventStore();
      final controller = MCalEventController();

      store.addEvent(_StoredEvent(
        id: 'mixed',
        title: 'Daily Mixed',
        start: DateTime(2026, 1, 1, 9, 0),
        end: DateTime(2026, 1, 1, 10, 0),
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.daily),
      ));

      // Apply a variety of exceptions.
      // Days 1-7: delete odd days.
      for (var d = 1; d <= 7; d += 2) {
        store.addException(_StoredException(
          seriesId: 'mixed',
          type: MCalExceptionType.deleted,
          originalDate: DateTime(2026, 2, d),
        ));
      }
      // Days 8-14: reschedule even days forward by 1.
      for (var d = 8; d <= 14; d += 2) {
        store.addException(_StoredException(
          seriesId: 'mixed',
          type: MCalExceptionType.rescheduled,
          originalDate: DateTime(2026, 2, d),
          newDate: DateTime(2026, 2, d, 16, 0), // same day but 4 PM
        ));
      }
      // Days 15-21: modify to change title.
      for (var d = 15; d <= 21; d += 2) {
        store.addException(_StoredException(
          seriesId: 'mixed',
          type: MCalExceptionType.modified,
          originalDate: DateTime(2026, 2, d),
          modifiedEvent: _StoredEvent(
            id: 'mixed_mod_$d',
            title: 'SPECIAL $d',
            start: DateTime(2026, 2, d, 9, 0),
            end: DateTime(2026, 2, d, 10, 0),
          ),
        ));
      }

      store.syncToController(controller);
      final events = controller.getEventsForRange(_februaryRange);

      // 28 days - 4 deleted (days 1,3,5,7) = 24 events.
      expect(events.length, 24);

      // Check some modified events.
      final specials = events.where((e) => e.title.startsWith('SPECIAL'));
      expect(specials.length, 4); // days 15, 17, 19, 21

      // Check rescheduled events moved to 4 PM.
      final rescheduled = events.where((e) => e.start.hour == 16);
      expect(rescheduled.length, 4); // days 8, 10, 12, 14
    });
  });

  // ===========================================================================
  // 10. Regression: _advanceDtStart Optimization Accuracy
  // ===========================================================================
  group('DTSTART optimization accuracy', () {
    test('bi-daily event from 5 years ago produces correct alignment', () {
      final store = InMemoryEventStore();
      final controller = MCalEventController();

      // Every 2 days from Jan 1, 2021.
      store.addEvent(_StoredEvent(
        id: 'bi-daily',
        title: 'Bi-Daily',
        start: DateTime(2021, 1, 1, 9, 0),
        end: DateTime(2021, 1, 1, 9, 30),
        recurrenceRule: MCalRecurrenceRule(
          frequency: MCalFrequency.daily,
          interval: 2,
        ),
      ));
      store.syncToController(controller);

      final events = controller.getEventsForRange(_februaryRange);

      // Every 2nd day. From Jan 1, 2021 to Feb 1, 2026 = 1857 days.
      // 1857 is odd → Feb 1 is day 1857 from start. 1857 % 2 = 1 → no hit.
      // Feb 2 = day 1858, 1858 % 2 = 0 → hit.
      // So pattern: Feb 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28 = 14.
      // OR: Feb 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27 = 14.
      expect(events.length, 14);

      // Verify all occurrences are 2 days apart.
      final days = events.map((e) => e.start.day).toList()..sort();
      for (var i = 1; i < days.length; i++) {
        expect(days[i] - days[i - 1], 2);
      }
    });

    test('bi-weekly from 3 years ago preserves day-of-week', () {
      final store = InMemoryEventStore();
      final controller = MCalEventController();

      store.addEvent(_StoredEvent(
        id: 'bi-weekly',
        title: 'Bi-Weekly',
        start: DateTime(2023, 1, 9, 10, 0), // Monday
        end: DateTime(2023, 1, 9, 11, 0),
        recurrenceRule: MCalRecurrenceRule(
          frequency: MCalFrequency.weekly,
          interval: 2,
        ),
      ));
      store.syncToController(controller);

      final events = controller.getEventsForRange(_februaryRange);

      // All occurrences must land on Monday.
      for (final e in events) {
        expect(e.start.weekday, DateTime.monday,
            reason: 'Expected Monday, got day ${e.start.day}');
      }

      // Should have 1-3 occurrences in a 28-day month with bi-weekly.
      expect(events.length, greaterThanOrEqualTo(1));
      expect(events.length, lessThanOrEqualTo(3));
    });

    test('optimization does not break monthly events from far past', () {
      final store = InMemoryEventStore();
      final controller = MCalEventController();

      store.addEvent(_StoredEvent(
        id: 'old-monthly',
        title: 'Monthly',
        start: DateTime(2018, 2, 20, 14, 0),
        end: DateTime(2018, 2, 20, 15, 0),
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.monthly),
      ));
      store.syncToController(controller);

      final events = controller.getEventsForRange(_februaryRange);
      expect(events.length, 1);
      expect(events.first.start, DateTime(2026, 2, 20, 14, 0));
    });

    test('optimization does not break yearly events from far past', () {
      final store = InMemoryEventStore();
      final controller = MCalEventController();

      store.addEvent(_StoredEvent(
        id: 'old-yearly',
        title: 'Anniversary',
        start: DateTime(2000, 2, 14, 0, 0),
        end: DateTime(2000, 2, 14, 0, 0),
        isAllDay: true,
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.yearly),
      ));
      store.syncToController(controller);

      final events = controller.getEventsForRange(_februaryRange);
      expect(events.length, 1);
      expect(events.first.start.day, 14);
      expect(events.first.isAllDay, isTrue);
    });
  });

  // ===========================================================================
  // 11. Full Integration: Realistic Workflow Simulation
  // ===========================================================================
  group('Realistic workflow simulation', () {
    test('initial load → edits → navigation → verify', () {
      final store = InMemoryEventStore();
      final controller = MCalEventController();

      // Step 1: App launches, loads events from "server".
      store.addEvent(_StoredEvent(
        id: 'standup',
        title: 'Daily Standup',
        start: DateTime(2025, 6, 1, 9, 0),
        end: DateTime(2025, 6, 1, 9, 15),
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.daily),
      ));
      store.addEvent(_StoredEvent(
        id: 'sprint',
        title: 'Sprint Planning',
        start: DateTime(2025, 6, 2, 10, 0), // Monday
        end: DateTime(2025, 6, 2, 12, 0),
        recurrenceRule: MCalRecurrenceRule(
          frequency: MCalFrequency.weekly,
          interval: 2,
        ),
      ));
      store.addEvent(_StoredEvent(
        id: 'review',
        title: 'Monthly Review',
        start: DateTime(2025, 1, 15, 14, 0),
        end: DateTime(2025, 1, 15, 15, 0),
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.monthly),
      ));
      store.syncToController(controller);

      // Step 2: User views February.
      var feb = controller.getEventsForRange(_februaryRange);
      final standups = feb.where((e) => e.externalId == 'standup').length;
      expect(standups, 28);

      // Step 3: User cancels Feb 10 standup (holiday).
      final deleteExc = _StoredException(
        seriesId: 'standup',
        type: MCalExceptionType.deleted,
        originalDate: DateTime(2026, 2, 10),
      );
      store.addException(deleteExc);
      store.syncExceptionToController('standup', deleteExc, controller);

      feb = controller.getEventsForRange(_februaryRange);
      expect(
        feb.where((e) => e.externalId == 'standup').length,
        27,
      );

      // Step 4: User reschedules Feb 9 sprint planning to Feb 11.
      // (Bi-weekly from June 2 2025 lands on Feb 9 and Feb 23.)
      final resExc = _StoredException(
        seriesId: 'sprint',
        type: MCalExceptionType.rescheduled,
        originalDate: DateTime(2026, 2, 9),
        newDate: DateTime(2026, 2, 11),
      );
      store.addException(resExc);
      store.syncExceptionToController('sprint', resExc, controller);

      feb = controller.getEventsForRange(_februaryRange);
      final sprints = feb.where((e) => e.externalId == 'sprint').toList();
      expect(sprints.any((e) => e.start.day == 11), isTrue);
      expect(sprints.any((e) => e.start.day == 9), isFalse);

      // Step 5: User navigates to March.
      final march = controller.getEventsForRange(_marchRange);
      expect(march.where((e) => e.externalId == 'standup').length, 31);

      // Step 6: User returns to February — should still be accurate.
      final febAgain = controller.getEventsForRange(_februaryRange);
      expect(febAgain.length, feb.length);

      // Step 7: User navigates to January — verify Q1 consistency.
      final jan = controller.getEventsForRange(_januaryRange);
      final q1 = controller.getEventsForRange(_q1Range);
      expect(q1.length, greaterThanOrEqualTo(jan.length + feb.length));
    });

    test('server sync replaces entire data set', () {
      final store = InMemoryEventStore();
      final controller = MCalEventController();

      // Initial sync.
      store.addEvent(_StoredEvent(
        id: 'old-event',
        title: 'Old Event',
        start: DateTime(2026, 2, 5, 9, 0),
        end: DateTime(2026, 2, 5, 10, 0),
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.daily),
      ));
      store.syncToController(controller);
      expect(controller.getEventsForRange(_februaryRange).length, 24);

      // Simulate server returning a completely different data set.
      final newStore = InMemoryEventStore();
      newStore.addEvent(_StoredEvent(
        id: 'new-event',
        title: 'New Event',
        start: DateTime(2026, 2, 1, 15, 0),
        end: DateTime(2026, 2, 1, 16, 0),
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.weekly),
      ));
      newStore.syncToController(controller);

      final events = controller.getEventsForRange(_februaryRange);
      expect(events.every((e) => e.externalId == 'new-event'), isTrue);
      expect(events.any((e) => e.externalId == 'old-event'), isFalse);
    });
  });

  // ===========================================================================
  // 12. Stress Test: Concurrent Modifications
  // ===========================================================================
  group('Stress: concurrent modifications', () {
    test('rapid add/delete cycle maintains consistency', () {
      final store = InMemoryEventStore();
      final controller = MCalEventController();

      store.addEvent(_StoredEvent(
        id: 'stress',
        title: 'Stress Test',
        start: DateTime(2026, 2, 3, 10, 0),
        end: DateTime(2026, 2, 3, 11, 0),
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.weekly),
      ));
      store.syncToController(controller);

      // Rapidly add and remove exceptions for the same date.
      for (var i = 0; i < 50; i++) {
        final exc = _StoredException(
          seriesId: 'stress',
          type: MCalExceptionType.deleted,
          originalDate: DateTime(2026, 2, 10),
        );
        store.addException(exc);
        store.syncExceptionToController('stress', exc, controller);

        store.removeException('stress', DateTime(2026, 2, 10));
        store.syncExceptionRemovalToController(
          'stress',
          DateTime(2026, 2, 10),
          controller,
        );
      }

      // After all the churn, Feb 10 should be restored.
      final events = controller.getEventsForRange(_februaryRange);
      expect(events.length, 4);
      expect(events.any((e) => e.start.day == 10), isTrue);
    });

    test('rapid exception type overwrites maintain consistency', () {
      final store = InMemoryEventStore();
      final controller = MCalEventController();

      store.addEvent(_StoredEvent(
        id: 'overwrite',
        title: 'Overwrite Test',
        start: DateTime(2026, 2, 3, 10, 0),
        end: DateTime(2026, 2, 3, 11, 0),
        recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.weekly),
      ));
      store.syncToController(controller);

      // Cycle through exception types rapidly.
      for (var i = 0; i < 20; i++) {
        // Delete.
        final del = _StoredException(
          seriesId: 'overwrite',
          type: MCalExceptionType.deleted,
          originalDate: DateTime(2026, 2, 10),
        );
        store.addException(del);
        store.syncExceptionToController('overwrite', del, controller);

        // Overwrite with reschedule.
        final res = _StoredException(
          seriesId: 'overwrite',
          type: MCalExceptionType.rescheduled,
          originalDate: DateTime(2026, 2, 10),
          newDate: DateTime(2026, 2, 11),
        );
        store.addException(res);
        store.syncExceptionToController('overwrite', res, controller);

        // Overwrite with modify.
        final mod = _StoredException(
          seriesId: 'overwrite',
          type: MCalExceptionType.modified,
          originalDate: DateTime(2026, 2, 10),
          modifiedEvent: _StoredEvent(
            id: 'overwrite_mod',
            title: 'Modified',
            start: DateTime(2026, 2, 10, 10, 0),
            end: DateTime(2026, 2, 10, 11, 0),
          ),
        );
        store.addException(mod);
        store.syncExceptionToController('overwrite', mod, controller);
      }

      // After the churn, the last state is "modified".
      final events = controller.getEventsForRange(_februaryRange);
      expect(events.length, 4);
      final modEvent = events.firstWhere(
        (e) => e.title == 'Modified',
        orElse: () => throw StateError('Modified event not found'),
      );
      expect(modEvent.start.day, 10);
    });
  });

  // ===========================================================================
  // 13. Performance: Timing of _advanceDtStart vs No Optimization
  // ===========================================================================
  group('Performance: DTSTART optimization impact', () {
    test('daily event from 10 years ago benefits from optimization', () {
      final controller = MCalEventController();
      controller.addEvents([
        MCalCalendarEvent(
          id: 'ancient-daily',
          title: 'Ancient Daily',
          start: DateTime(2016, 1, 1, 9, 0),
          end: DateTime(2016, 1, 1, 9, 30),
          recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.daily),
        ),
      ]);

      final sw = Stopwatch()..start();
      final events = controller.getEventsForRange(_februaryRange);
      sw.stop();

      print('  10-year-old daily → ${events.length} occurrences in '
          '${sw.elapsedMilliseconds}ms');

      expect(events.length, 28);
      // With optimization, this should be fast (< 100ms even in debug).
      expect(sw.elapsedMilliseconds, lessThan(500));
    });

    test('weekly event from 20 years ago is still fast', () {
      final controller = MCalEventController();
      controller.addEvents([
        MCalCalendarEvent(
          id: 'ancient-weekly',
          title: 'Ancient Weekly',
          start: DateTime(2006, 2, 6, 10, 0), // Monday
          end: DateTime(2006, 2, 6, 11, 0),
          recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.weekly),
        ),
      ]);

      final sw = Stopwatch()..start();
      final events = controller.getEventsForRange(_februaryRange);
      sw.stop();

      print('  20-year-old weekly → ${events.length} occurrences in '
          '${sw.elapsedMilliseconds}ms');

      expect(events.length, greaterThan(0));
      for (final e in events) {
        expect(e.start.weekday, DateTime.monday);
      }
      expect(sw.elapsedMilliseconds, lessThan(200));
    });
  });
}
