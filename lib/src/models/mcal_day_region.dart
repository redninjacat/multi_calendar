import 'package:flutter/material.dart';

import 'mcal_recurrence_rule.dart';

/// Represents a special day region in Month View with custom styling and
/// optional interaction blocking.
///
/// [MCalDayRegion] is the day-level counterpart of [MCalTimeRegion] in Day
/// View.  Instead of marking a time range within a day, it marks entire
/// calendar days — useful for weekends, public holidays, company closures,
/// blackout dates, or any other per-day metadata.
///
/// The library renders the region decoration automatically as a cell
/// background layer and enforces [blockInteraction] during drag-and-drop
/// without requiring custom builders or manual `onDragWillAccept` wiring.
///
/// ## Use cases
///
/// ### Blackout weekends
///
/// ```dart
/// MCalDayRegion(
///   id: 'weekends',
///   date: DateTime(2026, 1, 3),          // any Saturday anchor
///   recurrenceRule: 'FREQ=WEEKLY;BYDAY=SA,SU',
///   color: Colors.grey.withValues(alpha: 0.15),
///   blockInteraction: true,
///   text: 'Weekend',
/// )
/// ```
///
/// ### Public holiday
///
/// ```dart
/// MCalDayRegion(
///   id: 'holiday-2026-01-01',
///   date: DateTime(2026, 1, 1),
///   color: Colors.red.withValues(alpha: 0.2),
///   icon: Icons.celebration,
///   text: 'New Year\'s Day',
///   blockInteraction: false,   // visual only — drops still allowed
/// )
/// ```
///
/// ### Company closure (date range)
///
/// Use one region per day, or use a recurrence rule, or pass multiple regions:
///
/// ```dart
/// for (int d = 24; d <= 26; d++)
///   MCalDayRegion(
///     id: 'closure-dec-$d',
///     date: DateTime(2026, 12, d),
///     color: Colors.orange.withValues(alpha: 0.2),
///     blockInteraction: true,
///     text: 'Office Closed',
///   ),
/// ```
///
/// ## Recurrence
///
/// [recurrenceRule] uses the same RFC 5545 RRULE syntax as [MCalTimeRegion]
/// and calendar events:
///
/// - `FREQ=WEEKLY;BYDAY=SA,SU` — every weekend
/// - `FREQ=YEARLY;BYMONTH=1;BYMONTHDAY=1` — every 1 January
/// - `FREQ=WEEKLY;BYDAY=MO` — every Monday
///
/// When a recurrence rule is present, [date] acts as the anchor/start date
/// from which occurrences are calculated.
///
/// ## Interaction blocking
///
/// When [blockInteraction] is `true` the library automatically:
/// 1. Rejects drag-and-drop onto the blocked day (equivalent to returning
///    `false` from `onDragWillAccept` for that date).
/// 2. Calls `onDragWillAccept` *after* the built-in block check, so consumer
///    code never needs to duplicate the date-matching logic.
///
/// See also:
/// - [MCalTimeRegion] — same concept applied to time ranges in Day View
/// - [MCalMonthView.dayRegions] — where regions are declared
/// - [MCalMonthView.dayRegionBuilder] — custom cell overlay builder
class MCalDayRegion {
  /// Unique identifier for this region.
  ///
  /// Used for equality checks and as a widget key when rendering overlays.
  final String id;

  /// The anchor date for this region.
  ///
  /// For non-recurring regions this is the exact date the region applies to.
  /// For recurring regions this is the start date from which occurrences are
  /// calculated; only the date part (year/month/day) is significant.
  final DateTime date;

  /// Optional background color painted behind the day cell contents.
  ///
  /// Blends over the cell's default background, so semi-transparent values
  /// work best:
  /// - Blocked days:  `Colors.grey.withValues(alpha: 0.3)`
  /// - Holidays:      `Colors.red.withValues(alpha: 0.15)`
  /// - Special days:  `Colors.amber.withValues(alpha: 0.2)`
  ///
  /// If null and [dayRegionBuilder] is also null, the cell is rendered
  /// without a colour change (useful when you only need [blockInteraction]).
  final Color? color;

  /// Optional short label to display inside the cell.
  ///
  /// Rendered at a small font size below the date number by the default
  /// region renderer.  Examples: `'Holiday'`, `'Closed'`, `'Weekend'`.
  final String? text;

  /// Optional icon to display inside the cell alongside [text].
  final IconData? icon;

  /// Whether to block drag-and-drop onto this day.
  ///
  /// When `true`:
  /// - A dragged event hovering over this day shows the invalid-drop visual.
  /// - Dropping is rejected; the event returns to its original position.
  /// - The consumer's `onDragWillAccept` callback is **not** called (the
  ///   library short-circuits before reaching it).
  ///
  /// When `false` the region is purely visual and drops are still allowed.
  ///
  /// Defaults to `false`.
  final bool blockInteraction;

  /// Optional recurrence rule (RFC 5545 RRULE syntax).
  ///
  /// When provided the region repeats according to the rule, starting from
  /// [date].  Only the date portion of each occurrence is considered.
  ///
  /// Examples:
  /// - `'FREQ=WEEKLY;BYDAY=SA,SU'` — every Saturday and Sunday
  /// - `'FREQ=YEARLY;BYMONTH=7;BYMONTHDAY=4'` — every 4 July
  /// - `'FREQ=WEEKLY;BYDAY=MO;COUNT=52'` — every Monday for a year
  final String? recurrenceRule;

  /// Additional custom data available in [dayRegionBuilder].
  ///
  /// Allows passing arbitrary domain data without subclassing.
  final Map<String, dynamic>? customData;

  const MCalDayRegion({
    required this.id,
    required this.date,
    this.color,
    this.text,
    this.icon,
    this.blockInteraction = false,
    this.recurrenceRule,
    this.customData,
  });

  /// Returns `true` when this region applies to [queryDate].
  ///
  /// For non-recurring regions, delegates to [_matchesDate].
  /// For recurring regions, delegates to [MCalRecurrenceRule] for full
  /// RFC 5545 RRULE expansion — the same engine used by calendar events.
  ///
  /// ### `after` and COUNT handling
  ///
  /// We always generate from 1 µs before the anchor (DTSTART) so that:
  ///
  /// 1. The anchor occurrence itself is included — `teno_rrule.between` treats
  ///    `after` as exclusive, and day-region occurrences fall exactly at
  ///    midnight, so a naive `after = queryDay` would miss the occurrence.
  /// 2. COUNT is respected — when `after` is positioned far ahead of DTSTART,
  ///    `teno_rrule` may seek there efficiently, bypassing the COUNT ceiling and
  ///    returning occurrences that should already be exhausted.  Starting from
  ///    the anchor forces the engine to count correctly from the beginning.
  ///
  /// The `raw.take(count)` guard enforces COUNT for rules where `teno_rrule`
  /// still escapes the ceiling for FREQ=DAILY patterns.
  bool appliesTo(DateTime queryDate) {
    if (recurrenceRule == null) {
      return _matchesDate(date, queryDate);
    }
    try {
      final rule = MCalRecurrenceRule.fromRruleString(recurrenceRule!);
      final anchor = DateTime(date.year, date.month, date.day);
      final queryDay = DateTime(queryDate.year, queryDate.month, queryDate.day);
      // Exclusive upper bound: midnight of the day after queryDate.
      final beforeDay =
          DateTime(queryDate.year, queryDate.month, queryDate.day + 1);
      // Always start from just before the anchor so both the anchor occurrence
      // and COUNT are handled correctly (see docstring above).
      final after = anchor.subtract(const Duration(microseconds: 1));
      // teno_rrule treats endDate (UNTIL) as exclusive, but RFC 5545 defines
      // UNTIL as inclusive.  We enforce UNTIL manually:
      //   1. Parse UNTIL directly from the raw rule string (bypasses timezone
      //      conversion issues in teno_rrule's RecurrenceRule.endDate).
      //   2. Short-circuit if queryDate is past UNTIL.
      //   3. Strip UNTIL from the expansion rule so teno_rrule's exclusive
      //      boundary does not discard the UNTIL-date occurrence.
      //      The `before = queryDay + 1` bound already limits the results to
      //      queryDate, so removing UNTIL is safe.
      final untilDay = _parseUntilDay(recurrenceRule!);
      if (untilDay != null && queryDay.isAfter(untilDay)) return false;
      final expansionRule =
          untilDay != null ? rule.copyWith(until: () => null) : rule;
      final raw = expansionRule.getOccurrences(
        start: anchor,
        after: after,
        before: beforeDay,
      );
      // Guard against teno_rrule ignoring COUNT in between() (observed for
      // FREQ=DAILY): take only the first COUNT occurrences.
      final occurrences =
          rule.count != null ? raw.take(rule.count!).toList() : raw;
      return occurrences.any((d) => _matchesDate(d, queryDate));
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// True when [candidate] and [query] fall on the same calendar day.
  static bool _matchesDate(DateTime candidate, DateTime query) {
    return candidate.year == query.year &&
        candidate.month == query.month &&
        candidate.day == query.day;
  }

  /// Parses the UNTIL date from an RFC 5545 RRULE string, or returns `null` if
  /// no UNTIL clause is present or the value cannot be parsed.
  ///
  /// Only the YYYYMMDD (date-only) form is extracted.  Parsing from the raw
  /// string avoids timezone-conversion side-effects that can arise when
  /// reading [MCalRecurrenceRule.until] (which passes through teno_rrule's
  /// internal UTC normalisation).
  static DateTime? _parseUntilDay(String ruleString) {
    final match =
        RegExp(r'UNTIL=(\d{8})', caseSensitive: false).firstMatch(ruleString);
    if (match == null) return null;
    try {
      final s = match.group(1)!;
      return DateTime(
        int.parse(s.substring(0, 4)),
        int.parse(s.substring(4, 6)),
        int.parse(s.substring(6, 8)),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Context passed to [MCalMonthView.dayRegionBuilder] when rendering a day
/// region overlay inside a month cell.
class MCalDayRegionContext {
  /// The region being rendered.
  final MCalDayRegion region;

  /// The calendar date this cell represents.
  final DateTime date;

  /// `true` when [date] belongs to the currently displayed month.
  final bool isCurrentMonth;

  /// `true` when [date] is today.
  final bool isToday;

  const MCalDayRegionContext({
    required this.region,
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
  });
}
