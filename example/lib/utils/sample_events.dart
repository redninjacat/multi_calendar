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
  ];
}
