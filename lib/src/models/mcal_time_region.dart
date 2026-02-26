import 'package:flutter/material.dart';

import 'mcal_recurrence_rule.dart';

/// Represents a special time region with custom styling and optional interaction blocking.
///
/// Similar to month view's blockout dates, but time-based and with custom styling.
/// Inspired by Syncfusion's TimeRegion feature, this allows you to visually style
/// specific time periods and optionally prevent event drops/taps in those regions.
///
/// ## Use Cases
///
/// ### Non-Working Hours
///
/// Gray out time outside business hours and block event drops:
///
/// ```dart
/// MCalTimeRegion(
///   id: 'after-hours',
///   startTime: DateTime(2026, 2, 14, 18, 0),
///   endTime: DateTime(2026, 2, 14, 23, 59),
///   color: Colors.grey.withValues(alpha: 0.5),
///   text: 'After Hours',
///   icon: Icons.block,
///   blockInteraction: true, // Rejects drops via validation
/// )
/// ```
///
/// ### Lunch Break
///
/// Visual indicator for lunch time (allows drops):
///
/// ```dart
/// MCalTimeRegion(
///   id: 'lunch',
///   startTime: DateTime(2026, 2, 14, 12, 0),
///   endTime: DateTime(2026, 2, 14, 13, 0),
///   color: Colors.amber.withValues(alpha: 0.3),
///   text: 'Lunch Break',
///   icon: Icons.restaurant,
///   blockInteraction: false,
/// )
/// ```
///
/// ### Recurring Focus Time
///
/// Daily morning focus time with recurrence:
///
/// ```dart
/// MCalTimeRegion(
///   id: 'focus-time',
///   startTime: DateTime(2026, 2, 14, 9, 0),
///   endTime: DateTime(2026, 2, 14, 10, 0),
///   recurrenceRule: 'FREQ=DAILY;COUNT=30',
///   color: Colors.blue.withValues(alpha: 0.2),
///   text: 'Focus Time',
///   blockInteraction: true,
/// )
/// ```
///
/// ## Interaction Blocking
///
/// When [blockInteraction] is `true`, the region behaves like month view's
/// blockout dates:
/// 1. User drags event to blocked region
/// 2. `_validateDrop()` checks for blocked regions
/// 3. Drop rejected → visual feedback shows invalid drop
///
/// ## Recurrence Support
///
/// The [recurrenceRule] field uses RFC 5545 RRULE syntax (same as calendar events):
/// - `FREQ=DAILY`: Repeats daily
/// - `FREQ=WEEKLY`: Repeats weekly
/// - `BYHOUR=12;BYMINUTE=0`: At specific time
/// - `COUNT=30`: Repeat 30 times
///
/// Example: Daily lunch from noon to 1pm for 30 days:
/// ```dart
/// recurrenceRule: 'FREQ=DAILY;BYHOUR=12;BYMINUTE=0;COUNT=30'
/// ```
///
/// See also:
/// - [MCalTimeRegionContext] - Context provided to timeRegionBuilder
/// - [MCalDayView.specialTimeRegions] - List of regions to render
/// - [MCalDayView.timeRegionBuilder] - Custom region builder callback
/// - [MCalDayView.onDragWillAccept] - Drop validation callback
class MCalTimeRegion {
  /// Unique identifier for this region.
  ///
  /// Used for comparison and as a key when rendering regions.
  final String id;

  /// Start time for this region.
  ///
  /// The region is active from this time (inclusive) to [endTime] (exclusive).
  final DateTime startTime;

  /// End time for this region.
  ///
  /// The region is active from [startTime] (inclusive) to this time (exclusive).
  final DateTime endTime;

  /// Optional background color for the region.
  ///
  /// If null, uses theme default for blocked ([blockInteraction] = true)
  /// or non-blocked regions, or the custom builder must provide styling.
  ///
  /// Common patterns:
  /// - Blocked regions: `Colors.grey.withValues(alpha: 0.5)`
  /// - Lunch breaks: `Colors.amber.withValues(alpha: 0.3)`
  /// - Focus time: `Colors.blue.withValues(alpha: 0.2)`
  final Color? color;

  /// Optional label text to display in the region.
  ///
  /// Example: "Lunch Break", "After Hours", "Focus Time", "Meeting-Free Zone"
  final String? text;

  /// Whether to block interaction (prevent drops/taps) in this region.
  ///
  /// Similar to month view's blockout dates that reject drops via
  /// `onDragWillAccept`.
  ///
  /// Defaults to `false` (region is visual only).
  ///
  /// When `true`:
  /// - Event drops to this region will be rejected
  /// - Visual feedback shows invalid drop target
  /// - User must drop outside blocked regions
  final bool blockInteraction;

  /// Optional recurrence rule for recurring regions.
  ///
  /// Uses RFC 5545 RRULE syntax like calendar events.
  ///
  /// Examples:
  /// - Daily lunch: `"FREQ=DAILY;COUNT=30"`
  /// - Weekends: `"FREQ=WEEKLY;BYDAY=SA,SU"`
  /// - Daily at specific time: `"FREQ=DAILY;BYHOUR=12;BYMINUTE=0;BYSECOND=0"`
  ///
  /// When provided, the region will be expanded for the display date
  /// according to the recurrence pattern.
  final String? recurrenceRule;

  /// Optional icon to display in the region.
  ///
  /// Examples:
  /// - `Icons.restaurant` for lunch
  /// - `Icons.block` for blocked time
  /// - `Icons.work` for focus time
  /// - `Icons.coffee` for break time
  final IconData? icon;

  /// Additional custom data that can be used by timeRegionBuilder.
  ///
  /// Allows passing arbitrary data for custom rendering logic.
  ///
  /// Example:
  /// ```dart
  /// MCalTimeRegion(
  ///   id: 'custom',
  ///   customData: {
  ///     'priority': 'high',
  ///     'category': 'meeting-free',
  ///     'notifyUser': true,
  ///   },
  /// )
  /// ```
  final Map<String, dynamic>? customData;

  /// Creates a new [MCalTimeRegion] instance.
  ///
  /// All fields are final and this is an immutable data class.
  ///
  /// The region is active from [startTime] (inclusive) to [endTime] (exclusive).
  ///
  /// Example:
  /// ```dart
  /// MCalTimeRegion(
  ///   id: 'lunch',
  ///   startTime: DateTime(2026, 2, 14, 12, 0),
  ///   endTime: DateTime(2026, 2, 14, 13, 0),
  ///   color: Colors.amber.withValues(alpha: 0.3),
  ///   text: 'Lunch Break',
  ///   blockInteraction: false,
  /// )
  /// ```
  const MCalTimeRegion({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.color,
    this.text,
    this.blockInteraction = false,
    this.recurrenceRule,
    this.icon,
    this.customData,
  });

  /// Whether this region contains the given time.
  ///
  /// Returns `true` if [time] falls within [startTime] (inclusive) to
  /// [endTime] (exclusive).
  ///
  /// This is a pure function with no side effects.
  ///
  /// Example:
  /// ```dart
  /// final lunchRegion = MCalTimeRegion(
  ///   id: 'lunch',
  ///   startTime: DateTime(2026, 2, 14, 12, 0),
  ///   endTime: DateTime(2026, 2, 14, 13, 0),
  /// );
  ///
  /// lunchRegion.contains(DateTime(2026, 2, 14, 12, 30)); // true
  /// lunchRegion.contains(DateTime(2026, 2, 14, 11, 59)); // false
  /// lunchRegion.contains(DateTime(2026, 2, 14, 13, 0));  // false (exclusive end)
  /// ```
  bool contains(DateTime time) {
    return !time.isBefore(startTime) && time.isBefore(endTime);
  }

  /// Whether this region overlaps with the given time range.
  ///
  /// Returns `true` if there is any overlap between this region's time range
  /// and the range from [rangeStart] to [rangeEnd].
  ///
  /// Uses half-open interval logic: [startTime, endTime) overlaps with
  /// [rangeStart, rangeEnd) if:
  /// - `startTime < rangeEnd` AND
  /// - `endTime > rangeStart`
  ///
  /// This is a pure function with no side effects.
  ///
  /// Example:
  /// ```dart
  /// final lunchRegion = MCalTimeRegion(
  ///   id: 'lunch',
  ///   startTime: DateTime(2026, 2, 14, 12, 0),
  ///   endTime: DateTime(2026, 2, 14, 13, 0),
  /// );
  ///
  /// // Overlaps: meeting from 11:30 to 12:30
  /// lunchRegion.overlaps(
  ///   DateTime(2026, 2, 14, 11, 30),
  ///   DateTime(2026, 2, 14, 12, 30),
  /// ); // true
  ///
  /// // No overlap: meeting from 10:00 to 11:00
  /// lunchRegion.overlaps(
  ///   DateTime(2026, 2, 14, 10, 0),
  ///   DateTime(2026, 2, 14, 11, 0),
  /// ); // false
  ///
  /// // No overlap: meeting from 13:00 to 14:00
  /// lunchRegion.overlaps(
  ///   DateTime(2026, 2, 14, 13, 0),
  ///   DateTime(2026, 2, 14, 14, 0),
  /// ); // false
  /// ```
  bool overlaps(DateTime rangeStart, DateTime rangeEnd) {
    return startTime.isBefore(rangeEnd) && endTime.isAfter(rangeStart);
  }

  /// Returns a concrete [MCalTimeRegion] for [displayDate] if this region
  /// applies to that date, or `null` if it does not.
  ///
  /// Non-recurring regions apply only when [startTime]'s calendar date equals
  /// [displayDate]; in that case `this` is returned unchanged.
  ///
  /// Recurring regions use [MCalRecurrenceRule] — the same full RFC 5545
  /// expansion engine used by calendar events — to determine whether
  /// [displayDate] is an occurrence.  When it is, a new [MCalTimeRegion]
  /// instance is returned whose [startTime] and [endTime] are set to the
  /// occurrence's date (preserving the original time-of-day).  This ensures
  /// that the plain [overlaps] method works correctly for validation and
  /// rendering without any date-normalisation gymnastics.
  ///
  /// Example:
  /// ```dart
  /// final afterHours = MCalTimeRegion(
  ///   id: 'after-hours',
  ///   startTime: DateTime(2026, 1, 1, 18, 0), // anchor date is Jan 1
  ///   endTime:   DateTime(2026, 1, 1, 22, 0),
  ///   blockInteraction: true,
  ///   recurrenceRule: 'FREQ=DAILY',
  /// );
  ///
  /// final expanded = afterHours.expandedForDate(DateTime(2026, 2, 25));
  /// // expanded.startTime == DateTime(2026, 2, 25, 18, 0)
  /// // expanded.endTime   == DateTime(2026, 2, 25, 22, 0)
  ///
  /// // Now plain overlaps() works correctly:
  /// expanded!.overlaps(
  ///   DateTime(2026, 2, 25, 19, 0),
  ///   DateTime(2026, 2, 25, 20, 0),
  /// ); // true
  /// ```
  MCalTimeRegion? expandedForDate(DateTime displayDate) {
    final displayDay =
        DateTime(displayDate.year, displayDate.month, displayDate.day);
    final regionDay =
        DateTime(startTime.year, startTime.month, startTime.day);

    if (recurrenceRule == null) {
      // Non-recurring: applies only when the anchor date matches.
      return regionDay == displayDay ? this : null;
    }

    // Recurring: delegate to the full RFC 5545 expansion engine.
    try {
      final rule = MCalRecurrenceRule.fromRruleString(recurrenceRule!);
      // Exclusive upper bound: midnight of the day after displayDate.
      final beforeDay =
          DateTime(displayDate.year, displayDate.month, displayDate.day + 1);
      // Always generate from 1 µs before the anchor (DTSTART) so that:
      //   1. The anchor occurrence is included (teno_rrule.between is exclusive
      //      on `after`, and anchor-date occurrences are at exact anchor time).
      //   2. COUNT is respected — teno_rrule may seek past the COUNT ceiling
      //      when `after` is far from DTSTART; starting from anchor forces it
      //      to count correctly.  The raw.take(count) below adds a final guard.
      final after = startTime.subtract(const Duration(microseconds: 1));
      final raw = rule.getOccurrences(
        start: startTime,
        after: after,
        before: beforeDay,
      );
      // teno_rrule may not respect COUNT in between() when the window extends
      // past the count boundary (observed for FREQ=DAILY).  Taking at most
      // rule.count results enforces the ceiling regardless of library behaviour.
      final occurrences =
          rule.count != null ? raw.take(rule.count!).toList() : raw;

      // Find the occurrence whose calendar date matches displayDate.
      // `occurrences` starts from the anchor and may contain many entries
      // before reaching displayDate, so we must locate the matching one
      // explicitly rather than using occurrences.first.
      DateTime? occurrenceStart;
      for (final d in occurrences) {
        if (d.year == displayDate.year &&
            d.month == displayDate.month &&
            d.day == displayDate.day) {
          occurrenceStart = d;
          break;
        }
      }
      if (occurrenceStart == null) return null;
      final duration = endTime.difference(startTime);
      return MCalTimeRegion(
        id: '${id}_${displayDay.toIso8601String().split('T')[0]}',
        startTime: occurrenceStart,
        endTime: occurrenceStart.add(duration),
        color: color,
        text: text,
        blockInteraction: blockInteraction,
        icon: icon,
        customData: customData,
        // recurrenceRule is omitted — the expanded instance represents a
        // single concrete occurrence, not the recurring series.
      );
    } catch (_) {
      return null;
    }
  }
}
