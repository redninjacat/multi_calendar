import 'dart:ui' show Color;

import 'package:multi_calendar/multi_calendar.dart';

/// Predefined event colors for demonstration purposes.
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

/// Creates a list of sample events for demonstration purposes.
/// 
/// Each event is assigned a color from the predefined palette.
/// Includes multi-day events that span multiple days and week boundaries.
List<MCalCalendarEvent> createSampleEvents() {
  final now = DateTime.now();
  
  // Calculate dates for week boundary spanning events
  // Find the next Friday from today
  final daysUntilFriday = (DateTime.friday - now.weekday + 7) % 7;
  final nextFriday = DateTime(now.year, now.month, now.day + daysUntilFriday);
  
  return [
    // ============ Single-day timed events ============
    MCalCalendarEvent(
      id: 'event-1',
      title: 'Team Standup',
      start: DateTime(now.year, now.month, now.day, 9, 0),
      end: DateTime(now.year, now.month, now.day, 9, 30),
      isAllDay: false,
      color: _eventColors[0], // Indigo
    ),
    MCalCalendarEvent(
      id: 'event-2',
      title: 'Project Review',
      start: DateTime(now.year, now.month, now.day + 1, 14, 0),
      end: DateTime(now.year, now.month, now.day + 1, 15, 30),
      isAllDay: false,
      color: _eventColors[1], // Emerald
    ),
    MCalCalendarEvent(
      id: 'event-3',
      title: 'Design Workshop',
      start: DateTime(now.year, now.month, now.day + 2, 10, 0),
      end: DateTime(now.year, now.month, now.day + 2, 12, 0),
      isAllDay: false,
      color: _eventColors[2], // Amber
    ),
    MCalCalendarEvent(
      id: 'event-4',
      title: 'Code Review',
      start: DateTime(now.year, now.month, now.day, 15, 0),
      end: DateTime(now.year, now.month, now.day, 16, 0),
      isAllDay: false,
      color: _eventColors[4], // Violet
    ),
    MCalCalendarEvent(
      id: 'event-5',
      title: 'Lunch Meeting',
      start: DateTime(now.year, now.month, now.day + 3, 12, 0),
      end: DateTime(now.year, now.month, now.day + 3, 13, 0),
      isAllDay: false,
      color: _eventColors[0], // Indigo
    ),
    MCalCalendarEvent(
      id: 'event-6',
      title: 'Training Session',
      start: DateTime(now.year, now.month, now.day + 4, 9, 0),
      end: DateTime(now.year, now.month, now.day + 4, 11, 0),
      isAllDay: false,
      color: _eventColors[1], // Emerald
    ),
    
    // ============ Single-day all-day events ============
    MCalCalendarEvent(
      id: 'event-7',
      title: 'Holiday',
      start: DateTime(now.year, now.month, now.day + 6, 0, 0),
      end: DateTime(now.year, now.month, now.day + 6, 0, 0),
      isAllDay: true,
      comment: 'Public holiday - all day event',
      color: _eventColors[2], // Amber
    ),
    
    // ============ Multi-day events ============
    // 3-day Team Retreat (within a week)
    MCalCalendarEvent(
      id: 'event-8',
      title: 'Team Retreat',
      start: DateTime(now.year, now.month, now.day + 7, 0, 0),
      end: DateTime(now.year, now.month, now.day + 9, 0, 0),
      isAllDay: true,
      comment: '3-day all-day team retreat event',
      color: _eventColors[5], // Cyan
    ),
    
    // Conference spanning 4 days
    MCalCalendarEvent(
      id: 'event-9',
      title: 'Tech Conference',
      start: DateTime(now.year, now.month, now.day + 12, 0, 0),
      end: DateTime(now.year, now.month, now.day + 15, 0, 0),
      isAllDay: true,
      comment: '4-day conference event',
      color: _eventColors[3], // Red
    ),
    
    // Sprint Planning spanning a weekend (Fri-Mon) - crosses week boundary
    MCalCalendarEvent(
      id: 'event-10',
      title: 'Sprint Planning',
      start: DateTime(nextFriday.year, nextFriday.month, nextFriday.day, 0, 0),
      end: DateTime(nextFriday.year, nextFriday.month, nextFriday.day + 3, 0, 0),
      isAllDay: true,
      comment: 'Spans Fri-Mon crossing week boundary',
      color: _eventColors[6], // Pink
    ),
    
    // Team Off-Site spanning multiple days
    MCalCalendarEvent(
      id: 'event-11',
      title: 'Team Off-Site',
      start: DateTime(now.year, now.month, now.day + 18, 0, 0),
      end: DateTime(now.year, now.month, now.day + 24, 0, 0),
      isAllDay: true,
      comment: 'Week-long team off-site event',
      color: _eventColors[7], // Teal
    ),
    
    // Vacation spanning into next month (if applicable)
    MCalCalendarEvent(
      id: 'event-12',
      title: 'Vacation',
      start: DateTime(now.year, now.month, now.day + 25, 0, 0),
      end: DateTime(now.year, now.month, now.day + 30, 0, 0),
      isAllDay: true,
      comment: 'Multi-day vacation potentially spanning month boundary',
      color: _eventColors[4], // Violet
    ),
    
    // Shorter 2-day event
    MCalCalendarEvent(
      id: 'event-13',
      title: 'Hackathon',
      start: DateTime(now.year, now.month, now.day + 5, 0, 0),
      end: DateTime(now.year, now.month, now.day + 6, 0, 0),
      isAllDay: true,
      comment: '2-day hackathon event',
      color: _eventColors[0], // Indigo
    ),

    // ============ Recurring events ============
    // Weekly standup every Monday at 10:00, 30min
    MCalCalendarEvent(
      id: 'recurring-standup',
      title: 'Weekly Standup',
      start: _previousOrCurrentMonday(now).copyWith(hour: 10, minute: 0),
      end: _previousOrCurrentMonday(now).copyWith(hour: 10, minute: 30),
      isAllDay: false,
      color: const Color(0xFF0EA5E9), // Sky blue
      recurrenceRule: MCalRecurrenceRule(
        frequency: MCalFrequency.weekly,
        byWeekDays: {MCalWeekDay.every(DateTime.monday)},
      ),
    ),
    // Monthly review on the 1st of each month at 14:00, 1hr
    MCalCalendarEvent(
      id: 'recurring-review',
      title: 'Monthly Review',
      start: DateTime(now.year, now.month, 1, 14, 0),
      end: DateTime(now.year, now.month, 1, 15, 0),
      isAllDay: false,
      color: const Color(0xFFF97316), // Orange
      recurrenceRule: MCalRecurrenceRule(
        frequency: MCalFrequency.monthly,
        byMonthDays: const [1],
      ),
    ),
    // Bi-weekly Friday retrospective at 16:00, 45min
    MCalCalendarEvent(
      id: 'recurring-retro',
      title: 'Bi-Weekly Retro',
      start: _previousOrCurrentFriday(now).copyWith(hour: 16, minute: 0),
      end: _previousOrCurrentFriday(now).copyWith(hour: 16, minute: 45),
      isAllDay: false,
      color: const Color(0xFFD946EF), // Fuchsia
      recurrenceRule: MCalRecurrenceRule(
        frequency: MCalFrequency.weekly,
        interval: 2,
        byWeekDays: {MCalWeekDay.every(DateTime.friday)},
      ),
    ),
  ];
}

/// Event title templates for stress test generation.
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

/// Returns the most recent Monday on or before [date].
DateTime _previousOrCurrentMonday(DateTime date) {
  final daysFromMonday = (date.weekday - DateTime.monday) % 7;
  final monday = date.subtract(Duration(days: daysFromMonday));
  return DateTime(monday.year, monday.month, monday.day);
}

/// Returns the most recent Friday on or before [date].
DateTime _previousOrCurrentFriday(DateTime date) {
  final daysFromFriday = (date.weekday - DateTime.friday + 7) % 7;
  final friday = date.subtract(Duration(days: daysFromFriday));
  return DateTime(friday.year, friday.month, friday.day);
}

/// Creates sample events for Day View testing (timed + all-day for [date]).
List<MCalCalendarEvent> createDayViewSampleEvents(DateTime date) {
  final d = DateTime(date.year, date.month, date.day);
  return [
    MCalCalendarEvent(
      id: 'dv-timed-1',
      title: 'Team Standup',
      start: DateTime(d.year, d.month, d.day, 9, 0),
      end: DateTime(d.year, d.month, d.day, 9, 30),
      isAllDay: false,
      color: _eventColors[0],
    ),
    MCalCalendarEvent(
      id: 'dv-timed-2',
      title: 'Code Review',
      start: DateTime(d.year, d.month, d.day, 15, 0),
      end: DateTime(d.year, d.month, d.day, 16, 0),
      isAllDay: false,
      color: _eventColors[4],
    ),
    MCalCalendarEvent(
      id: 'dv-timed-3',
      title: 'Design Workshop',
      start: DateTime(d.year, d.month, d.day, 10, 30),
      end: DateTime(d.year, d.month, d.day, 12, 0),
      isAllDay: false,
      color: _eventColors[2],
    ),
    MCalCalendarEvent(
      id: 'dv-allday-1',
      title: 'Holiday',
      start: DateTime(d.year, d.month, d.day, 0, 0),
      end: DateTime(d.year, d.month, d.day, 0, 0),
      isAllDay: true,
      comment: 'All-day event for drag testing',
      color: _eventColors[2],
    ),
    MCalCalendarEvent(
      id: 'dv-allday-2',
      title: 'Project Kickoff',
      start: DateTime(d.year, d.month, d.day, 0, 0),
      end: DateTime(d.year, d.month, d.day, 0, 0),
      isAllDay: true,
      color: _eventColors[5],
    ),
  ];
}
