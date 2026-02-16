import 'dart:ui' show Color;

import 'package:multi_calendar/multi_calendar.dart';

const List<Color> eventColors = [
  Color(0xFF6366F1),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
  Color(0xFFEF4444),
  Color(0xFF8B5CF6),
  Color(0xFF06B6D4),
  Color(0xFFEC4899),
  Color(0xFF14B8A6),
];

List<MCalCalendarEvent> createSampleEvents() {
  final now = DateTime.now();
  final daysUntilFriday = (DateTime.friday - now.weekday + 7) % 7;
  final nextFriday = DateTime(now.year, now.month, now.day + daysUntilFriday);

  return [
    MCalCalendarEvent(
      id: 'event-1',
      title: 'Team Standup',
      start: DateTime(now.year, now.month, now.day, 9, 0),
      end: DateTime(now.year, now.month, now.day, 9, 30),
      isAllDay: false,
      color: eventColors[0],
    ),
    MCalCalendarEvent(
      id: 'event-2',
      title: 'Project Review',
      start: DateTime(now.year, now.month, now.day + 1, 14, 0),
      end: DateTime(now.year, now.month, now.day + 1, 15, 30),
      isAllDay: false,
      color: eventColors[1],
    ),
    MCalCalendarEvent(
      id: 'event-3',
      title: 'Design Workshop',
      start: DateTime(now.year, now.month, now.day + 2, 10, 0),
      end: DateTime(now.year, now.month, now.day + 2, 12, 0),
      isAllDay: false,
      color: eventColors[2],
    ),
    MCalCalendarEvent(
      id: 'event-4',
      title: 'Code Review',
      start: DateTime(now.year, now.month, now.day, 15, 0),
      end: DateTime(now.year, now.month, now.day, 16, 0),
      isAllDay: false,
      color: eventColors[4],
    ),
    MCalCalendarEvent(
      id: 'event-5',
      title: 'Lunch Meeting',
      start: DateTime(now.year, now.month, now.day + 3, 12, 0),
      end: DateTime(now.year, now.month, now.day + 3, 13, 0),
      isAllDay: false,
      color: eventColors[0],
    ),
    MCalCalendarEvent(
      id: 'event-6',
      title: 'Training Session',
      start: DateTime(now.year, now.month, now.day + 4, 9, 0),
      end: DateTime(now.year, now.month, now.day + 4, 11, 0),
      isAllDay: false,
      color: eventColors[1],
    ),
    MCalCalendarEvent(
      id: 'event-7',
      title: 'Holiday',
      start: DateTime(now.year, now.month, now.day + 6, 0, 0),
      end: DateTime(now.year, now.month, now.day + 6, 0, 0),
      isAllDay: true,
      color: eventColors[2],
    ),
    MCalCalendarEvent(
      id: 'event-8',
      title: 'Team Retreat',
      start: DateTime(now.year, now.month, now.day + 7, 0, 0),
      end: DateTime(now.year, now.month, now.day + 9, 0, 0),
      isAllDay: true,
      color: eventColors[5],
    ),
    MCalCalendarEvent(
      id: 'event-9',
      title: 'Tech Conference',
      start: DateTime(now.year, now.month, now.day + 12, 0, 0),
      end: DateTime(now.year, now.month, now.day + 15, 0, 0),
      isAllDay: true,
      color: eventColors[3],
    ),
    MCalCalendarEvent(
      id: 'event-10',
      title: 'Sprint Planning',
      start: DateTime(nextFriday.year, nextFriday.month, nextFriday.day, 0, 0),
      end: DateTime(nextFriday.year, nextFriday.month, nextFriday.day + 3, 0, 0),
      isAllDay: true,
      color: eventColors[6],
    ),
    MCalCalendarEvent(
      id: 'event-11',
      title: 'Team Off-Site',
      start: DateTime(now.year, now.month, now.day + 18, 0, 0),
      end: DateTime(now.year, now.month, now.day + 24, 0, 0),
      isAllDay: true,
      color: eventColors[7],
    ),
    MCalCalendarEvent(
      id: 'event-12',
      title: 'Vacation',
      start: DateTime(now.year, now.month, now.day + 25, 0, 0),
      end: DateTime(now.year, now.month, now.day + 30, 0, 0),
      isAllDay: true,
      color: eventColors[4],
    ),
    MCalCalendarEvent(
      id: 'event-13',
      title: 'Hackathon',
      start: DateTime(now.year, now.month, now.day + 5, 0, 0),
      end: DateTime(now.year, now.month, now.day + 6, 0, 0),
      isAllDay: true,
      color: eventColors[0],
    ),
    MCalCalendarEvent(
      id: 'recurring-standup',
      title: 'Weekly Standup',
      start: _previousOrCurrentMonday(now).copyWith(hour: 10, minute: 0),
      end: _previousOrCurrentMonday(now).copyWith(hour: 10, minute: 30),
      isAllDay: false,
      color: const Color(0xFF0EA5E9),
      recurrenceRule: MCalRecurrenceRule(
        frequency: MCalFrequency.weekly,
        byWeekDays: {MCalWeekDay.every(DateTime.monday)},
      ),
    ),
    MCalCalendarEvent(
      id: 'recurring-review',
      title: 'Monthly Review',
      start: DateTime(now.year, now.month, 1, 14, 0),
      end: DateTime(now.year, now.month, 1, 15, 0),
      isAllDay: false,
      color: const Color(0xFFF97316),
      recurrenceRule: MCalRecurrenceRule(
        frequency: MCalFrequency.monthly,
        byMonthDays: const [1],
      ),
    ),
    MCalCalendarEvent(
      id: 'recurring-retro',
      title: 'Bi-Weekly Retro',
      start: _previousOrCurrentFriday(now).copyWith(hour: 16, minute: 0),
      end: _previousOrCurrentFriday(now).copyWith(hour: 16, minute: 45),
      isAllDay: false,
      color: const Color(0xFFD946EF),
      recurrenceRule: MCalRecurrenceRule(
        frequency: MCalFrequency.weekly,
        interval: 2,
        byWeekDays: {MCalWeekDay.every(DateTime.friday)},
      ),
    ),
  ];
}

List<MCalCalendarEvent> createDayViewSampleEvents(DateTime date) {
  final d = DateTime(date.year, date.month, date.day);
  return [
    MCalCalendarEvent(
      id: 'dv-timed-1',
      title: 'Team Standup',
      start: DateTime(d.year, d.month, d.day, 9, 0),
      end: DateTime(d.year, d.month, d.day, 9, 30),
      isAllDay: false,
      color: eventColors[0],
    ),
    MCalCalendarEvent(
      id: 'dv-timed-2',
      title: 'Code Review',
      start: DateTime(d.year, d.month, d.day, 15, 0),
      end: DateTime(d.year, d.month, d.day, 16, 0),
      isAllDay: false,
      color: eventColors[4],
    ),
    MCalCalendarEvent(
      id: 'dv-timed-3',
      title: 'Design Workshop',
      start: DateTime(d.year, d.month, d.day, 10, 30),
      end: DateTime(d.year, d.month, d.day, 12, 0),
      isAllDay: false,
      color: eventColors[2],
    ),
    MCalCalendarEvent(
      id: 'dv-allday-1',
      title: 'Holiday',
      start: DateTime(d.year, d.month, d.day, 0, 0),
      end: DateTime(d.year, d.month, d.day, 0, 0),
      isAllDay: true,
      color: eventColors[2],
    ),
    MCalCalendarEvent(
      id: 'dv-allday-2',
      title: 'Project Kickoff',
      start: DateTime(d.year, d.month, d.day, 0, 0),
      end: DateTime(d.year, d.month, d.day, 0, 0),
      isAllDay: true,
      color: eventColors[5],
    ),
  ];
}

DateTime _previousOrCurrentMonday(DateTime date) {
  final daysFromMonday = (date.weekday - DateTime.monday) % 7;
  final monday = date.subtract(Duration(days: daysFromMonday));
  return DateTime(monday.year, monday.month, monday.day);
}

DateTime _previousOrCurrentFriday(DateTime date) {
  final daysFromFriday = (date.weekday - DateTime.friday + 7) % 7;
  final friday = date.subtract(Duration(days: daysFromFriday));
  return DateTime(friday.year, friday.month, friday.day);
}
