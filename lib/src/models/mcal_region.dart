import 'package:flutter/material.dart';

import 'mcal_recurrence_rule.dart';
import '../utils/date_utils.dart' as date_utils;

/// Sentinel value used by [MCalRegion.copyWith] to distinguish between
/// "not passed" and "explicitly passed as null" for nullable fields.
const _sentinel = _Sentinel();

class _Sentinel {
  const _Sentinel();
}

/// Represents a calendar region with custom styling and optional interaction
/// blocking.
///
/// [MCalRegion] is the unified region model for all calendar views. It replaces
/// both `MCalTimeRegion` (timed regions in Day View) and `MCalDayRegion`
/// (all-day regions in Month View) with a single class that supports both
/// semantics via the [isAllDay] flag.
///
/// Regions are added to [MCalEventController] via `addRegions()` and are
/// automatically available to all views. Views query the controller for
/// applicable regions and pass them to builder contexts for custom rendering.
///
/// ## Field semantics by [isAllDay]
///
/// | Field | `isAllDay: true` | `isAllDay: false` |
/// |-------|------------------|-------------------|
/// | [start] | Anchor date (time ignored) | Start date/time (both significant) |
/// | [end] | End date (time ignored, inclusive) | End date/time (exclusive) |
///
/// ## All-day region example
///
/// ```dart
/// MCalRegion(
///   id: 'weekends',
///   start: DateTime(2026, 1, 3),
///   end: DateTime(2026, 1, 3),
///   isAllDay: true,
///   recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.weekly,
///       byWeekDays: {MCalWeekDay.every(DateTime.saturday),
///                    MCalWeekDay.every(DateTime.sunday)}),
///   color: Colors.grey.withValues(alpha: 0.15),
///   blockInteraction: true,
///   text: 'Weekend',
/// )
/// ```
///
/// ## Timed region example
///
/// ```dart
/// MCalRegion(
///   id: 'after-hours',
///   start: DateTime(2026, 1, 1, 18, 0),
///   end: DateTime(2026, 1, 1, 22, 0),
///   isAllDay: false,
///   recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.daily),
///   color: Colors.red.withValues(alpha: 0.15),
///   blockInteraction: true,
///   text: 'After Hours (blocked)',
/// )
/// ```
///
/// ## Cross-view enforcement
///
/// Because regions live on the controller, a timed blocking region (e.g.,
/// Mondays 2–5 PM) automatically prevents dragging a 3–4 PM event onto
/// Monday in both Day View and Month View.
///
/// See also:
/// - [MCalEventController.addRegions] — add regions to the controller
/// - [MCalEventController.getRegionsForDate] — query regions for a date
/// - [MCalEventController.isDateBlocked] — check if a date is blocked
/// - [MCalEventController.isTimeRangeBlocked] — check if a time range is blocked
class MCalRegion {
  /// Unique identifier for this region.
  final String id;

  /// Start date/time for this region.
  ///
  /// For all-day regions (`isAllDay: true`), only the date component is
  /// significant. For non-recurring all-day regions, this is the specific
  /// date. For recurring all-day regions, this is the anchor date from which
  /// occurrences are calculated.
  ///
  /// For timed regions (`isAllDay: false`), both date and time components
  /// are significant. The region is active from [start] (inclusive) to
  /// [end] (exclusive).
  final DateTime start;

  /// End date/time for this region.
  ///
  /// For all-day regions (`isAllDay: true`), only the date component is
  /// significant. For single-day regions, this equals [start]. For multi-day
  /// regions, this is the last day of the range.
  ///
  /// For timed regions (`isAllDay: false`), both date and time components
  /// are significant. The region is active from [start] (inclusive) to
  /// [end] (exclusive).
  final DateTime end;

  /// Optional background color for the region.
  final Color? color;

  /// Optional label text to display in the region.
  final String? text;

  /// Optional icon to display in the region.
  final IconData? icon;

  /// Whether to block interaction (prevent drops/taps) in this region.
  ///
  /// Defaults to `false` (region is visual only).
  ///
  /// When `true`:
  /// - Event drops to this region will be rejected
  /// - Visual feedback shows invalid drop target
  /// - The consumer's `onDragWillAccept` callback is NOT called
  final bool blockInteraction;

  /// Whether this is an all-day region.
  ///
  /// When `true`, only the date components of [start] and [end] are
  /// significant; time components are ignored for matching and overlap logic.
  ///
  /// When `false`, both date and time components are used.
  ///
  /// Defaults to `false`.
  final bool isAllDay;

  /// Optional recurrence rule for recurring regions.
  ///
  /// When non-null, [start] acts as the anchor date from which occurrences
  /// are calculated. The region repeats according to the rule.
  final MCalRecurrenceRule? recurrenceRule;

  /// Additional custom data that can be used by region builders.
  ///
  /// Allows passing arbitrary data for custom rendering logic.
  final Map<String, dynamic>? customData;

  /// Creates a new [MCalRegion] instance.
  const MCalRegion({
    required this.id,
    required this.start,
    required this.end,
    this.color,
    this.text,
    this.icon,
    this.blockInteraction = false,
    this.isAllDay = false,
    this.recurrenceRule,
    this.customData,
  });

  /// Creates a copy of this region with the given fields replaced.
  ///
  /// Nullable fields ([color], [text], [icon], [recurrenceRule], [customData])
  /// use a sentinel pattern so you can explicitly pass `null` to clear them.
  MCalRegion copyWith({
    String? id,
    DateTime? start,
    DateTime? end,
    Object? color = _sentinel,
    Object? text = _sentinel,
    Object? icon = _sentinel,
    bool? blockInteraction,
    bool? isAllDay,
    Object? recurrenceRule = _sentinel,
    Object? customData = _sentinel,
  }) {
    return MCalRegion(
      id: id ?? this.id,
      start: start ?? this.start,
      end: end ?? this.end,
      color: color == _sentinel ? this.color : color as Color?,
      text: text == _sentinel ? this.text : text as String?,
      icon: icon == _sentinel ? this.icon : icon as IconData?,
      blockInteraction: blockInteraction ?? this.blockInteraction,
      isAllDay: isAllDay ?? this.isAllDay,
      recurrenceRule: recurrenceRule == _sentinel
          ? this.recurrenceRule
          : recurrenceRule as MCalRecurrenceRule?,
      customData: customData == _sentinel
          ? this.customData
          : customData as Map<String, dynamic>?,
    );
  }

  /// Whether this region contains the given time.
  ///
  /// Returns `true` if [time] falls within [start] (inclusive) to
  /// [end] (exclusive). Intended for timed regions.
  bool contains(DateTime time) {
    return !time.isBefore(start) && time.isBefore(end);
  }

  /// Whether this region overlaps with the given time range.
  ///
  /// Uses half-open interval logic: [start, end) overlaps with
  /// [rangeStart, rangeEnd) if `start < rangeEnd` AND `end > rangeStart`.
  ///
  /// Intended for timed regions.
  bool overlaps(DateTime rangeStart, DateTime rangeEnd) {
    return start.isBefore(rangeEnd) && end.isAfter(rangeStart);
  }

  /// Whether this region applies to the given calendar date.
  ///
  /// For all-day regions, checks if [queryDate] falls within the [start]–[end]
  /// date range or matches a recurrence occurrence.
  ///
  /// For timed regions, checks if [queryDate] matches the date component of
  /// [start] or a recurrence occurrence.
  bool appliesTo(DateTime queryDate) {
    if (recurrenceRule == null) {
      return _appliesToNonRecurring(queryDate);
    }
    return _appliesToRecurring(queryDate);
  }

  /// Returns a concrete [MCalRegion] for [displayDate] if this region
  /// applies to that date, or `null` if it does not.
  ///
  /// For timed regions, the returned region has [start] and [end] adjusted
  /// to the occurrence date, preserving the original time-of-day.
  ///
  /// For all-day regions, the returned region has [start] and [end] set to
  /// the occurrence date.
  MCalRegion? expandedForDate(DateTime displayDate) {
    final displayDay = date_utils.dateOnly(displayDate);

    if (recurrenceRule == null) {
      return _expandNonRecurring(displayDay, displayDate);
    }
    return _expandRecurring(displayDay, displayDate);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  bool _appliesToNonRecurring(DateTime queryDate) {
    final queryDay = date_utils.dateOnly(queryDate);
    if (isAllDay) {
      final startDay = date_utils.dateOnly(start);
      final endDay = date_utils.dateOnly(end);
      return !queryDay.isBefore(startDay) && !queryDay.isAfter(endDay);
    } else {
      return date_utils.dateOnly(start) == queryDay;
    }
  }

  bool _appliesToRecurring(DateTime queryDate) {
    try {
      final queryDay = date_utils.dateOnly(queryDate);
      final occurrences = _getOccurrencesForDay(queryDay);
      return occurrences.any(
        (d) => date_utils.dateOnly(d) == queryDay,
      );
    } catch (_) {
      return false;
    }
  }

  MCalRegion? _expandNonRecurring(DateTime displayDay, DateTime displayDate) {
    if (isAllDay) {
      final startDay = date_utils.dateOnly(start);
      final endDay = date_utils.dateOnly(end);
      if (!displayDay.isBefore(startDay) && !displayDay.isAfter(endDay)) {
        return this;
      }
      return null;
    } else {
      return date_utils.dateOnly(start) == displayDay ? this : null;
    }
  }

  MCalRegion? _expandRecurring(DateTime displayDay, DateTime displayDate) {
    try {
      final occurrences = _getOccurrencesForDay(displayDay);

      DateTime? occurrenceStart;
      for (final d in occurrences) {
        if (date_utils.dateOnly(d) == displayDay) {
          occurrenceStart = d;
          break;
        }
      }
      if (occurrenceStart == null) return null;

      final dayId = displayDay.toIso8601String().split('T')[0];

      if (isAllDay) {
        return MCalRegion(
          id: '${id}_$dayId',
          start: displayDay,
          end: displayDay,
          color: color,
          text: text,
          icon: icon,
          blockInteraction: blockInteraction,
          isAllDay: true,
          customData: customData,
        );
      } else {
        // DST-safe end time: use daysBetween (UTC-based) for the day span
        // and calendar-day constructor arithmetic for the result, consistent
        // with MCalEventController._getExpandedOccurrences.
        final daySpan = date_utils.daysBetween(start, end);
        final newEnd = DateTime(
          occurrenceStart.year,
          occurrenceStart.month,
          occurrenceStart.day + daySpan,
          occurrenceStart.hour + (end.hour - start.hour),
          occurrenceStart.minute + (end.minute - start.minute),
          occurrenceStart.second + (end.second - start.second),
          occurrenceStart.millisecond + (end.millisecond - start.millisecond),
          occurrenceStart.microsecond + (end.microsecond - start.microsecond),
        );

        return MCalRegion(
          id: '${id}_$dayId',
          start: occurrenceStart,
          end: newEnd,
          color: color,
          text: text,
          icon: icon,
          blockInteraction: blockInteraction,
          isAllDay: false,
          customData: customData,
        );
      }
    } catch (_) {
      return null;
    }
  }

  /// Core recurrence expansion for a single day. Shared by [_appliesToRecurring]
  /// and [_expandRecurring] to avoid duplicating expansion logic.
  ///
  /// Uses DTSTART optimization for daily/weekly rules (consistent with
  /// [MCalEventController._advanceDtStart]) and handles COUNT/UNTIL edge cases.
  List<DateTime> _getOccurrencesForDay(DateTime queryDay) {
    final anchor = isAllDay ? date_utils.dateOnly(start) : start;
    final beforeDay = date_utils.addDays(queryDay, 1);

    // UNTIL check: short-circuit if past the end date.
    final untilDay = recurrenceRule!.until;
    MCalRecurrenceRule expansionRule = recurrenceRule!;
    if (untilDay != null) {
      final untilDayOnly = date_utils.dateOnly(untilDay);
      if (queryDay.isAfter(untilDayOnly)) return const [];
      expansionRule = recurrenceRule!.copyWith(until: () => null);
    }

    // DTSTART optimization: advance the start close to the query window
    // for daily/weekly rules to avoid a linear walk from anchors that may
    // be years in the past. Only safe when there is no COUNT — count-based
    // rules must iterate from the real start to count correctly.
    // Consistent with MCalEventController._advanceDtStart.
    final optimizedStart = recurrenceRule!.count == null
        ? _advanceDtStart(anchor, expansionRule, queryDay)
        : anchor;

    final after = optimizedStart.subtract(const Duration(microseconds: 1));

    final raw = expansionRule.getOccurrences(
      start: optimizedStart,
      after: after,
      before: beforeDay,
    );

    // Guard against teno_rrule ignoring COUNT in between().
    return recurrenceRule!.count != null
        ? raw.take(recurrenceRule!.count!).toList()
        : raw;
  }

  /// Advances [dtStart] close to [target] for daily/weekly rules to avoid
  /// iterating from a distant anchor. Monthly/yearly are left unchanged
  /// because their occurrence dates depend on month length and day-of-month.
  ///
  /// Uses [date_utils.daysBetween] for DST-safe day counting and
  /// [date_utils.addDays] for DST-safe day shifting.
  ///
  /// Consistent with [MCalEventController._advanceDtStart].
  static DateTime _advanceDtStart(
    DateTime dtStart,
    MCalRecurrenceRule rule,
    DateTime target,
  ) {
    if (!target.isAfter(dtStart)) return dtStart;

    switch (rule.frequency) {
      case MCalFrequency.daily:
        final daysDiff = date_utils.daysBetween(dtStart, target);
        final periods = daysDiff ~/ rule.interval;
        final safePeriods = (periods - 1).clamp(0, periods);
        return date_utils.addDays(dtStart, safePeriods * rule.interval);
      case MCalFrequency.weekly:
        final daysDiff = date_utils.daysBetween(dtStart, target);
        final weekPeriod = rule.interval * 7;
        final periods = daysDiff ~/ weekPeriod;
        final safePeriods = (periods - 1).clamp(0, periods);
        return date_utils.addDays(dtStart, safePeriods * weekPeriod);
      case MCalFrequency.monthly:
      case MCalFrequency.yearly:
        return dtStart;
    }
  }

  @override
  String toString() {
    return 'MCalRegion(id: $id, start: $start, end: $end, isAllDay: $isAllDay, '
        'blockInteraction: $blockInteraction, color: $color, text: $text, '
        'icon: $icon, recurrenceRule: $recurrenceRule, customData: $customData)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MCalRegion) return false;
    return other.id == id &&
        other.start == start &&
        other.end == end &&
        other.color == color &&
        other.text == text &&
        other.icon == icon &&
        other.blockInteraction == blockInteraction &&
        other.isAllDay == isAllDay &&
        other.recurrenceRule == recurrenceRule &&
        _mapEquals(other.customData, customData);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      start,
      end,
      color,
      text,
      icon,
      blockInteraction,
      isAllDay,
      recurrenceRule,
      customData != null ? Object.hashAll(customData!.entries) : null,
    );
  }

  static bool _mapEquals(
      Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
