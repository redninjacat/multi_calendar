import 'dart:ui' show Color;
import 'package:multi_calendar/multi_calendar.dart';

/// Predefined event colors for stress testing.
const List<Color> _eventColors = [
  Color(0xFF6366F1), // Indigo
  Color(0xFF10B981), // Emerald
  Color(0xFFF59E0B), // Amber
  Color(0xFFEF4444), // Red
  Color(0xFF8B5CF6), // Violet
  Color(0xFF06B6D4), // Cyan
  Color(0xFFEC4899), // Pink
  Color(0xFF14B8A6), // Teal
];

/// Generic event title prefixes for stress testing.
const List<String> _stressTestTitles = [
  'Meeting',
  'Standup',
  'Review',
  'Workshop',
  'Call',
  'Sync',
  'Planning',
  'Retro',
  'Demo',
  'Training',
  'Interview',
  'Brainstorm',
  'Sprint',
  'Design',
  'Code Review',
];

/// Creates a large set of events for Day View performance stress testing.
///
/// Generates [count] events (default 200) for [date], with many overlapping
/// timed events to stress overlap detection and layout. Uses [startHour] to
/// [endHour] for event placement. Includes some all-day events.
///
/// Events are distributed across the day with intentional overlaps to
/// demonstrate efficient rendering with CustomPainter and overlap handling.
List<MCalCalendarEvent> createDayViewStressTestEvents(
  DateTime date, {
  int count = 200,
  int startHour = 0,
  int endHour = 24,
}) {
  final d = DateTime(date.year, date.month, date.day);
  final events = <MCalCalendarEvent>[];
  final random = _SeededRandom(count);

  final hourSpan = (endHour - startHour).clamp(1, 24);
  final colorCount = _eventColors.length;

  // Add 5-10 all-day events
  final allDayCount = 5 + (count ~/ 50).clamp(0, 5);
  for (var i = 0; i < allDayCount; i++) {
    events.add(MCalCalendarEvent(
      id: 'stress-allday-$i',
      title: 'All-day ${_stressTestTitles[i % _stressTestTitles.length]} $i',
      start: DateTime(d.year, d.month, d.day, 0, 0),
      end: DateTime(d.year, d.month, d.day, 0, 0),
      isAllDay: true,
      color: _eventColors[i % colorCount],
    ));
  }

  // Add timed events - many overlapping
  final timedCount = count - allDayCount;
  for (var i = 0; i < timedCount; i++) {
    final durationMinutes = [15, 30, 45, 60, 90, 120][random.nextInt(6)];
    final startMinutes = random.nextInt(hourSpan * 60);
    final start = DateTime(
      d.year,
      d.month,
      d.day,
      startHour + (startMinutes ~/ 60),
      startMinutes % 60,
    );
    final end = start.add(Duration(minutes: durationMinutes));

    events.add(MCalCalendarEvent(
      id: 'stress-timed-$i',
      title: '${_stressTestTitles[i % _stressTestTitles.length]} $i',
      start: start,
      end: end,
      isAllDay: false,
      color: _eventColors[i % colorCount],
    ));
  }

  return events;
}

/// Creates a large set of events for Month View performance stress testing.
///
/// Generates stress test events distributed across [month] with clusters of
/// 10-20 events on 3-5 random days, plus a mix of single-day and multi-day
/// events. Uses seeded RNG for deterministic event generation.
///
/// The [count] parameter controls the approximate total number of events.
/// Events are clustered on specific days to stress the Month View's overflow
/// and multi-day event layout logic.
///
/// Example:
/// ```dart
/// final events = createMonthViewStressTestEvents(
///   DateTime(2026, 2, 1),
///   count: 300,
/// );
/// ```
List<MCalCalendarEvent> createMonthViewStressTestEvents(
  DateTime month, {
  int count = 300,
}) {
  final events = <MCalCalendarEvent>[];
  final random = _SeededRandom(count);
  final colorCount = _eventColors.length;

  // Determine the last day of the month
  final lastDay = DateTime(month.year, month.month + 1, 0);
  final daysInMonth = lastDay.day;

  // Determine number of cluster days (3-5 based on count)
  final numClusterDays = 3 + (count ~/ 100).clamp(0, 2);

  // Pick random days for clustering
  final clusterDays = <int>{};
  while (clusterDays.length < numClusterDays && clusterDays.length < daysInMonth) {
    clusterDays.add(1 + random.nextInt(daysInMonth));
  }

  // Calculate events per cluster day
  final clusterEventCount = (count * 0.7).toInt(); // 70% in clusters
  final eventsPerCluster = clusterEventCount ~/ clusterDays.length;

  var eventId = 0;

  // Create clustered events
  for (final day in clusterDays) {
    final clusterSize = eventsPerCluster + random.nextInt(10) - 5; // 10-20 variance
    for (var i = 0; i < clusterSize; i++) {
      final eventDate = DateTime(month.year, month.month, day);

      // 70% single-day, 30% multi-day
      final isMultiDay = random.nextInt(10) < 3;

      if (isMultiDay) {
        // Multi-day event spanning 2-5 days
        final duration = 2 + random.nextInt(4);
        events.add(MCalCalendarEvent(
          id: 'stress-month-$eventId',
          title: '${_stressTestTitles[eventId % _stressTestTitles.length]} $eventId',
          start: eventDate,
          end: DateTime(
            eventDate.year,
            eventDate.month,
            (eventDate.day + duration).clamp(1, daysInMonth),
          ),
          isAllDay: true,
          color: _eventColors[eventId % colorCount],
        ));
      } else {
        // Single-day event
        events.add(MCalCalendarEvent(
          id: 'stress-month-$eventId',
          title: '${_stressTestTitles[eventId % _stressTestTitles.length]} $eventId',
          start: eventDate,
          end: eventDate,
          isAllDay: true,
          color: _eventColors[eventId % colorCount],
        ));
      }

      eventId++;
    }
  }

  // Distribute remaining events across random days
  final remainingCount = count - eventId;
  for (var i = 0; i < remainingCount; i++) {
    final day = 1 + random.nextInt(daysInMonth);
    final eventDate = DateTime(month.year, month.month, day);

    // 80% single-day, 20% multi-day for distributed events
    final isMultiDay = random.nextInt(10) < 2;

    if (isMultiDay) {
      final duration = 2 + random.nextInt(3);
      events.add(MCalCalendarEvent(
        id: 'stress-month-$eventId',
        title: '${_stressTestTitles[eventId % _stressTestTitles.length]} $eventId',
        start: eventDate,
        end: DateTime(
          eventDate.year,
          eventDate.month,
          (eventDate.day + duration).clamp(1, daysInMonth),
        ),
        isAllDay: true,
        color: _eventColors[eventId % colorCount],
      ));
    } else {
      events.add(MCalCalendarEvent(
        id: 'stress-month-$eventId',
        title: '${_stressTestTitles[eventId % _stressTestTitles.length]} $eventId',
        start: eventDate,
        end: eventDate,
        isAllDay: true,
        color: _eventColors[eventId % colorCount],
      ));
    }

    eventId++;
  }

  return events;
}

/// Simple seeded random for deterministic stress test event generation.
class _SeededRandom {
  _SeededRandom(this._seed);

  int _seed;

  int nextInt(int max) {
    if (max <= 0) return 0;
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed % max;
  }
}
