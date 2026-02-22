/// Time calculation utilities for Day View.
///
/// Provides pure functions for converting between time values and pixel offsets,
/// with DST-safe arithmetic and time slot snapping.
library;

/// Converts a time to a vertical offset in pixels.
///
/// Returns the distance from the top of the time range (at [startHour]) to the
/// given [time]. The offset is calculated based on the [hourHeight] in pixels.
///
/// This function is pure and DST-safe.
///
/// Example:
/// ```dart
/// final offset = timeToOffset(
///   time: DateTime(2026, 2, 14, 10, 30),
///   startHour: 8,
///   hourHeight: 60.0,
/// );
/// // Returns 150.0 (2.5 hours * 60 pixels/hour)
/// ```
///
/// Parameters:
/// - [time]: The DateTime to convert to an offset.
/// - [startHour]: The hour at which the time range starts (0-23).
/// - [hourHeight]: The height in pixels of one hour.
///
/// Returns the vertical offset in pixels from the top of the time range.
double timeToOffset({
  required DateTime time,
  required int startHour,
  required double hourHeight,
}) {
  final minutesFromStart = (time.hour - startHour) * 60 + time.minute;
  return (minutesFromStart / 60.0) * hourHeight;
}

/// Converts a vertical offset to a time at 1-minute resolution.
///
/// Returns a DateTime on the given [date] with the time calculated from the
/// vertical [offset]. The result is rounded to the nearest whole minute.
/// No time-slot snapping is applied — callers that want snapping should
/// pass the result to [snapToTimeSlot] (or [_applySnapping] in the widget).
///
/// Keeping conversion and snapping separate ensures that [gridlineInterval]
/// (a purely visual concept controlling where gridlines are drawn) never
/// influences drag granularity.  All snapping is governed solely by
/// [timeSlotDuration] and [snapRange] at the call site.
///
/// This function is pure and DST-safe, using the DateTime constructor form
/// to avoid DST-related arithmetic errors.
///
/// Example:
/// ```dart
/// final time = offsetToTime(
///   offset: 150.0,
///   date: DateTime(2026, 2, 14),
///   startHour: 8,
///   hourHeight: 60.0,
/// );
/// // Returns DateTime(2026, 2, 14, 10, 30) (150px / 60px/hr * 60 min/hr = 150 min from 08:00 → 10:30)
/// ```
///
/// Parameters:
/// - [offset]: The vertical offset in pixels from the top of the time range.
/// - [date]: The date to use for the returned DateTime.
/// - [startHour]: The hour at which the time range starts (0-23).
/// - [hourHeight]: The height in pixels of one hour.
///
/// Returns a DateTime with the calculated time on the given date.
DateTime offsetToTime({
  required double offset,
  required DateTime date,
  required int startHour,
  required double hourHeight,
}) {
  final minutesFromStart = ((offset / hourHeight) * 60).round();

  // DST-safe: construct DateTime with hour/minute components
  final totalMinutes = startHour * 60 + minutesFromStart;
  final hour = totalMinutes ~/ 60;
  final minute = totalMinutes % 60;

  return DateTime(date.year, date.month, date.day, hour, minute);
}

/// Calculates the height in pixels for a duration.
///
/// Converts a [duration] to a vertical height in pixels based on the
/// [hourHeight].
///
/// This function is pure.
///
/// Example:
/// ```dart
/// final height = durationToHeight(
///   duration: Duration(minutes: 90),
///   hourHeight: 60.0,
/// );
/// // Returns 90.0 (1.5 hours * 60 pixels/hour)
/// ```
///
/// Parameters:
/// - [duration]: The duration to convert to pixels.
/// - [hourHeight]: The height in pixels of one hour.
///
/// Returns the height in pixels corresponding to the duration.
double durationToHeight({
  required Duration duration,
  required double hourHeight,
}) {
  return (duration.inMinutes / 60.0) * hourHeight;
}

/// Snaps a time to the nearest time slot boundary.
///
/// Returns a new DateTime with the time snapped to the nearest
/// [timeSlotDuration] interval. For example, with a 15-minute slot duration,
/// 10:37 would snap to 10:30 or 10:45, whichever is closer.
///
/// This function is pure and DST-safe, using the DateTime constructor form.
///
/// Example:
/// ```dart
/// final snapped = snapToTimeSlot(
///   time: DateTime(2026, 2, 14, 10, 37),
///   timeSlotDuration: Duration(minutes: 15),
/// );
/// // Returns DateTime(2026, 2, 14, 10, 30)
/// ```
///
/// Parameters:
/// - [time]: The DateTime to snap to a time slot.
/// - [timeSlotDuration]: The duration of each time slot.
///
/// Returns a new DateTime snapped to the nearest time slot boundary.
DateTime snapToTimeSlot({
  required DateTime time,
  required Duration timeSlotDuration,
}) {
  final totalMinutes = time.hour * 60 + time.minute;
  final snappedMinutes =
      (totalMinutes / timeSlotDuration.inMinutes).round() *
      timeSlotDuration.inMinutes;

  final hour = snappedMinutes ~/ 60;
  final minute = snappedMinutes % 60;

  return DateTime(time.year, time.month, time.day, hour, minute);
}

/// Snaps a time to nearby time boundaries (for magnetic snapping).
///
/// Returns a snapped DateTime if [time] is within [snapRange] of any of the
/// [nearbyTimes]. Otherwise, returns [time] unchanged.
///
/// This is used for magnetic snapping during drag operations, where events
/// can snap to other event boundaries, the current time indicator, or time
/// slot boundaries.
///
/// This function is pure and DST-safe.
///
/// Example:
/// ```dart
/// final snapped = snapToNearbyTime(
///   time: DateTime(2026, 2, 14, 10, 33),
///   nearbyTimes: [
///     DateTime(2026, 2, 14, 10, 30),
///     DateTime(2026, 2, 14, 11, 0),
///   ],
///   snapRange: Duration(minutes: 5),
/// );
/// // Returns DateTime(2026, 2, 14, 10, 30) because it's within 5 minutes
/// ```
///
/// Parameters:
/// - [time]: The DateTime to potentially snap.
/// - [nearbyTimes]: List of nearby times to snap to.
/// - [snapRange]: The maximum duration within which snapping occurs.
///
/// Returns a snapped DateTime if within range, otherwise [time] unchanged.
DateTime snapToNearbyTime({
  required DateTime time,
  required List<DateTime> nearbyTimes,
  required Duration snapRange,
}) {
  if (nearbyTimes.isEmpty) return time;

  DateTime? closestTime;
  Duration? closestDistance;

  for (final nearbyTime in nearbyTimes) {
    if (isWithinSnapRange(time, nearbyTime, snapRange)) {
      final distance = time.difference(nearbyTime).abs();
      if (closestDistance == null || distance < closestDistance) {
        closestDistance = distance;
        closestTime = nearbyTime;
      }
    }
  }

  return closestTime ?? time;
}

/// Checks if two times are within the snap range.
///
/// Returns true if the absolute difference between [time1] and [time2] is
/// less than or equal to [snapRange].
///
/// This function is pure and DST-safe.
///
/// Example:
/// ```dart
/// final isWithin = isWithinSnapRange(
///   DateTime(2026, 2, 14, 10, 33),
///   DateTime(2026, 2, 14, 10, 30),
///   Duration(minutes: 5),
/// );
/// // Returns true (3 minutes difference < 5 minutes range)
/// ```
///
/// Parameters:
/// - [time1]: The first DateTime to compare.
/// - [time2]: The second DateTime to compare.
/// - [snapRange]: The maximum duration for considering times within range.
///
/// Returns true if the times are within [snapRange] of each other.
bool isWithinSnapRange(DateTime time1, DateTime time2, Duration snapRange) {
  final difference = time1.difference(time2).abs();
  return difference <= snapRange;
}
