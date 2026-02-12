import 'mcal_calendar_event.dart';

/// The type of exception applied to a recurring event occurrence.
enum MCalExceptionType {
  /// The occurrence is deleted (skipped).
  deleted,

  /// The occurrence is moved to a new date/time.
  rescheduled,

  /// The occurrence is replaced with a modified event.
  modified,
}

/// An exception to a recurring event series, representing a single occurrence
/// that has been deleted, rescheduled, or modified.
///
/// Use the named constructors for type safety:
/// - [MCalRecurrenceException.deleted] — removes a single occurrence.
/// - [MCalRecurrenceException.rescheduled] — moves an occurrence to a new date.
/// - [MCalRecurrenceException.modified] — replaces an occurrence with a custom event.
///
/// Example:
/// ```dart
/// // Delete the Jan 15 occurrence
/// final deletion = MCalRecurrenceException.deleted(
///   originalDate: DateTime(2024, 1, 15),
/// );
///
/// // Reschedule the Jan 22 occurrence to Jan 23
/// final reschedule = MCalRecurrenceException.rescheduled(
///   originalDate: DateTime(2024, 1, 22),
///   newDate: DateTime(2024, 1, 23),
/// );
///
/// // Modify the Jan 29 occurrence with a different event
/// final modification = MCalRecurrenceException.modified(
///   originalDate: DateTime(2024, 1, 29),
///   modifiedEvent: modifiedEvent,
/// );
/// ```
class MCalRecurrenceException {
  /// The type of this exception.
  final MCalExceptionType type;

  /// The original date of the occurrence being excepted.
  final DateTime originalDate;

  /// The new date for a rescheduled occurrence.
  ///
  /// Only non-null when [type] is [MCalExceptionType.rescheduled].
  final DateTime? newDate;

  /// The modified event that replaces the original occurrence.
  ///
  /// Only non-null when [type] is [MCalExceptionType.modified].
  final MCalCalendarEvent? modifiedEvent;

  /// Creates a deleted exception that removes a single occurrence.
  const MCalRecurrenceException.deleted({required this.originalDate})
      : type = MCalExceptionType.deleted,
        newDate = null,
        modifiedEvent = null;

  /// Creates a rescheduled exception that moves an occurrence to [newDate].
  const MCalRecurrenceException.rescheduled({
    required this.originalDate,
    required DateTime this.newDate,
  })  : type = MCalExceptionType.rescheduled,
        modifiedEvent = null;

  /// Creates a modified exception that replaces an occurrence with
  /// [modifiedEvent].
  const MCalRecurrenceException.modified({
    required this.originalDate,
    required MCalCalendarEvent this.modifiedEvent,
  })  : type = MCalExceptionType.modified,
        newDate = null;

  /// Private general constructor used by [copyWith].
  const MCalRecurrenceException._({
    required this.type,
    required this.originalDate,
    this.newDate,
    this.modifiedEvent,
  });

  /// Creates a copy of this exception with the given fields replaced.
  MCalRecurrenceException copyWith({
    MCalExceptionType? type,
    DateTime? originalDate,
    DateTime? newDate,
    MCalCalendarEvent? modifiedEvent,
  }) {
    return MCalRecurrenceException._(
      type: type ?? this.type,
      originalDate: originalDate ?? this.originalDate,
      newDate: newDate ?? this.newDate,
      modifiedEvent: modifiedEvent ?? this.modifiedEvent,
    );
  }

  @override
  String toString() {
    return 'MCalRecurrenceException(type: $type, originalDate: $originalDate, '
        'newDate: $newDate, modifiedEvent: $modifiedEvent)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MCalRecurrenceException &&
        other.type == type &&
        other.originalDate == originalDate &&
        other.newDate == newDate &&
        other.modifiedEvent == modifiedEvent;
  }

  @override
  int get hashCode {
    return Object.hash(
      type,
      originalDate,
      newDate,
      modifiedEvent,
    );
  }
}
