import 'package:flutter/material.dart';

import 'mcal_recurrence_rule.dart';

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
    final displayDay =
        DateTime(displayDate.year, displayDate.month, displayDate.day);

    if (recurrenceRule == null) {
      return _expandNonRecurring(displayDay, displayDate);
    }
    return _expandRecurring(displayDay, displayDate);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  bool _appliesToNonRecurring(DateTime queryDate) {
    final queryDay =
        DateTime(queryDate.year, queryDate.month, queryDate.day);
    if (isAllDay) {
      final startDay = DateTime(start.year, start.month, start.day);
      final endDay = DateTime(end.year, end.month, end.day);
      return !queryDay.isBefore(startDay) && !queryDay.isAfter(endDay);
    } else {
      return _matchesDate(start, queryDate);
    }
  }

  bool _appliesToRecurring(DateTime queryDate) {
    try {
      final queryDay =
          DateTime(queryDate.year, queryDate.month, queryDate.day);
      final anchor = isAllDay
          ? DateTime(start.year, start.month, start.day)
          : start;
      final beforeDay =
          DateTime(queryDate.year, queryDate.month, queryDate.day + 1);
      final after = anchor.subtract(const Duration(microseconds: 1));

      final untilDay = recurrenceRule!.until;
      MCalRecurrenceRule expansionRule = recurrenceRule!;
      if (untilDay != null) {
        final untilDayOnly =
            DateTime(untilDay.year, untilDay.month, untilDay.day);
        if (queryDay.isAfter(untilDayOnly)) return false;
        expansionRule = recurrenceRule!.copyWith(until: () => null);
      }

      final raw = expansionRule.getOccurrences(
        start: anchor,
        after: after,
        before: beforeDay,
      );
      final occurrences = recurrenceRule!.count != null
          ? raw.take(recurrenceRule!.count!).toList()
          : raw;

      if (isAllDay) {
        return occurrences.any((d) => _matchesDate(d, queryDate));
      } else {
        return occurrences.any((d) => _matchesDate(d, queryDate));
      }
    } catch (_) {
      return false;
    }
  }

  MCalRegion? _expandNonRecurring(DateTime displayDay, DateTime displayDate) {
    if (isAllDay) {
      final startDay = DateTime(start.year, start.month, start.day);
      final endDay = DateTime(end.year, end.month, end.day);
      if (!displayDay.isBefore(startDay) && !displayDay.isAfter(endDay)) {
        return this;
      }
      return null;
    } else {
      final regionDay = DateTime(start.year, start.month, start.day);
      return regionDay == displayDay ? this : null;
    }
  }

  MCalRegion? _expandRecurring(DateTime displayDay, DateTime displayDate) {
    try {
      final anchor = isAllDay
          ? DateTime(start.year, start.month, start.day)
          : start;
      final beforeDay =
          DateTime(displayDate.year, displayDate.month, displayDate.day + 1);
      final after = anchor.subtract(const Duration(microseconds: 1));

      final untilDay = recurrenceRule!.until;
      MCalRecurrenceRule expansionRule = recurrenceRule!;
      if (untilDay != null) {
        final untilDayOnly =
            DateTime(untilDay.year, untilDay.month, untilDay.day);
        if (displayDay.isAfter(untilDayOnly)) return null;
        expansionRule = recurrenceRule!.copyWith(until: () => null);
      }

      final raw = expansionRule.getOccurrences(
        start: anchor,
        after: after,
        before: beforeDay,
      );
      final occurrences = recurrenceRule!.count != null
          ? raw.take(recurrenceRule!.count!).toList()
          : raw;

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

      if (isAllDay) {
        return MCalRegion(
          id: '${id}_${displayDay.toIso8601String().split('T')[0]}',
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
        final duration = end.difference(start);
        return MCalRegion(
          id: '${id}_${displayDay.toIso8601String().split('T')[0]}',
          start: occurrenceStart,
          end: occurrenceStart.add(duration),
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

  static bool _matchesDate(DateTime candidate, DateTime query) {
    return candidate.year == query.year &&
        candidate.month == query.month &&
        candidate.day == query.day;
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
