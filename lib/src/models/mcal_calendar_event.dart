import 'dart:ui' show Color;

import 'package:multi_calendar/src/models/mcal_recurrence_rule.dart';

/// Sentinel value used by [MCalCalendarEvent.copyWith] to distinguish between
/// "not passed" and "explicitly passed as null" for the [MCalCalendarEvent.recurrenceRule] field.
const _sentinel = _Sentinel();

class _Sentinel {
  const _Sentinel();
}

/// A data model representing a calendar event.
///
/// This class provides a simple, immutable representation of a calendar event
/// with all necessary fields for basic event data. The model supports both
/// one-time and recurring events through the optional [occurrenceId] field.
///
/// Example:
/// ```dart
/// final event = MCalCalendarEvent(
///   id: 'event-1',
///   title: 'Team Meeting',
///   start: DateTime(2024, 1, 15, 10, 0),
///   end: DateTime(2024, 1, 15, 11, 0),
///   comment: 'Quarterly planning',
///   isAllDay: false,
///   color: Color(0xFF6366F1), // Optional custom color
/// );
/// ```
class MCalCalendarEvent {
  /// Unique identifier for the event.
  final String id;

  /// Event title or name.
  final String title;

  /// Event start date and time.
  final DateTime start;

  /// Event end date and time.
  final DateTime end;

  /// Whether this event is an all-day event.
  ///
  /// When true, the time components of [start] and [end] should be ignored.
  /// All-day events will be displayed in the header section of Day and Multi-Day views.
  /// Defaults to false.
  final bool isAllDay;

  /// Optional comments or notes about the event.
  final String? comment;

  /// Optional external identifier to link to app's data store.
  ///
  /// This field allows the consuming application to maintain a relationship
  /// between the MCalCalendarEvent and its external data storage system.
  final String? externalId;

  /// Optional identifier for specific occurrence of a recurring event.
  ///
  /// When an event is part of a recurring series, this field uniquely
  /// identifies the specific occurrence instance.
  final String? occurrenceId;

  /// Optional color for the event.
  ///
  /// When provided, this color will be used for the event tile background
  /// and indicators. If not provided, the calendar will use the theme's
  /// default event color or the color from an [eventTileBuilder].
  final Color? color;

  /// Optional recurrence rule defining how this event repeats.
  ///
  /// When non-null, this event is the master event for a recurring series.
  /// The controller will expand occurrences based on this rule.
  /// When null, this is a standalone (non-recurring) event.
  final MCalRecurrenceRule? recurrenceRule;

  /// Creates a new [MCalCalendarEvent] instance.
  ///
  /// The [id], [title], [start], and [end] parameters are required.
  /// All other parameters are optional.
  const MCalCalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.isAllDay = false,
    this.comment,
    this.externalId,
    this.occurrenceId,
    this.color,
    this.recurrenceRule,
  });

  /// Creates a copy of this event with the given fields replaced.
  ///
  /// The [recurrenceRule] parameter uses a sentinel pattern so you can
  /// explicitly pass `null` to clear recurrence (remove it from the event).
  /// Passing nothing preserves the current value; passing `null` clears it.
  MCalCalendarEvent copyWith({
    String? id,
    String? title,
    DateTime? start,
    DateTime? end,
    bool? isAllDay,
    String? comment,
    String? externalId,
    String? occurrenceId,
    Color? color,
    Object? recurrenceRule = _sentinel,
  }) {
    return MCalCalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      start: start ?? this.start,
      end: end ?? this.end,
      isAllDay: isAllDay ?? this.isAllDay,
      comment: comment ?? this.comment,
      externalId: externalId ?? this.externalId,
      occurrenceId: occurrenceId ?? this.occurrenceId,
      color: color ?? this.color,
      recurrenceRule: recurrenceRule == _sentinel
          ? this.recurrenceRule
          : recurrenceRule as MCalRecurrenceRule?,
    );
  }

  @override
  String toString() {
    return 'MCalCalendarEvent(id: $id, title: $title, start: $start, end: $end, '
        'isAllDay: $isAllDay, comment: $comment, externalId: $externalId, '
        'occurrenceId: $occurrenceId, color: $color, '
        'recurrenceRule: $recurrenceRule)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MCalCalendarEvent &&
        other.id == id &&
        other.title == title &&
        other.start == start &&
        other.end == end &&
        other.isAllDay == isAllDay &&
        other.comment == comment &&
        other.externalId == externalId &&
        other.occurrenceId == occurrenceId &&
        other.color == color &&
        other.recurrenceRule == recurrenceRule;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      start,
      end,
      isAllDay,
      comment,
      externalId,
      occurrenceId,
      color,
      recurrenceRule,
    );
  }
}
