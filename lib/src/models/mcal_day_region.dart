import 'package:flutter/material.dart';

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
  /// For recurring regions, expands occurrences and checks membership.
  bool appliesTo(DateTime queryDate) {
    if (recurrenceRule == null) {
      return _matchesDate(date, queryDate);
    }
    return _expandedOccurrences(queryDate).any(
      (d) => _matchesDate(d, queryDate),
    );
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

  /// Expands recurring occurrences that could fall on [queryDate].
  ///
  /// This is a simplified RRULE interpreter that handles the patterns most
  /// relevant for day regions:
  ///
  /// - `FREQ=DAILY`
  /// - `FREQ=WEEKLY` (with optional `BYDAY=MO,TU,...`)
  /// - `FREQ=MONTHLY` (with optional `BYMONTHDAY=`)
  /// - `FREQ=YEARLY` (with optional `BYMONTH=` and `BYMONTHDAY=`)
  ///
  /// For complex rules that are not supported here the region will silently
  /// not match.  Consumers needing full RFC 5545 expansion should pre-compute
  /// the list of dates and pass one [MCalDayRegion] per date.
  List<DateTime> _expandedOccurrences(DateTime queryDate) {
    final rule = recurrenceRule!.toUpperCase();
    final parts = _parseRuleParts(rule);
    final freq = parts['FREQ'] ?? '';
    final anchor = DateTime(date.year, date.month, date.day);
    final query = DateTime(queryDate.year, queryDate.month, queryDate.day);

    // Honour UNTIL / COUNT limits
    final until = _parseUntil(parts['UNTIL']);
    final count = int.tryParse(parts['COUNT'] ?? '');

    // For most patterns we only need to check if queryDate is a valid
    // occurrence — we don't need to enumerate all of them.
    switch (freq) {
      case 'DAILY':
        if (query.isBefore(anchor)) return [];
        if (until != null && query.isAfter(until)) return [];
        final diff = query.difference(anchor).inDays;
        final interval = int.tryParse(parts['INTERVAL'] ?? '1') ?? 1;
        if (diff % interval != 0) return [];
        if (count != null && diff ~/ interval >= count) return [];
        return [query];

      case 'WEEKLY':
        if (query.isBefore(anchor)) return [];
        if (until != null && query.isAfter(until)) return [];
        final byDay = _parseByDay(parts['BYDAY'] ?? '');
        if (byDay.isNotEmpty && !byDay.contains(query.weekday)) return [];
        final interval = int.tryParse(parts['INTERVAL'] ?? '1') ?? 1;
        // Check that query falls on a matching week offset from anchor week
        final anchorWeekStart = anchor.subtract(
          Duration(days: (anchor.weekday - 1) % 7),
        );
        final queryWeekStart = query.subtract(
          Duration(days: (query.weekday - 1) % 7),
        );
        final weeksDiff =
            queryWeekStart.difference(anchorWeekStart).inDays ~/ 7;
        if (weeksDiff < 0 || weeksDiff % interval != 0) return [];
        if (count != null) {
          // Approximate: count occurrences up to query
          int occurrences = 0;
          DateTime cur = anchor;
          while (!cur.isAfter(query)) {
            final wStart = cur.subtract(Duration(days: (cur.weekday - 1) % 7));
            final wEnd = wStart.add(const Duration(days: 6));
            for (
              DateTime d = wStart;
              !d.isAfter(wEnd);
              d = d.add(const Duration(days: 1))
            ) {
              if (!d.isBefore(anchor) &&
                  (byDay.isEmpty || byDay.contains(d.weekday))) {
                occurrences++;
              }
            }
            cur = cur.add(Duration(days: 7 * interval));
          }
          if (occurrences > count) return [];
        }
        return [query];

      case 'MONTHLY':
        if (query.isBefore(anchor)) return [];
        if (until != null && query.isAfter(until)) return [];
        final byMonthDay = int.tryParse(parts['BYMONTHDAY'] ?? '');
        if (byMonthDay != null && query.day != byMonthDay) return [];
        if (byMonthDay == null && query.day != anchor.day) return [];
        final interval = int.tryParse(parts['INTERVAL'] ?? '1') ?? 1;
        final monthsDiff =
            (query.year - anchor.year) * 12 + (query.month - anchor.month);
        if (monthsDiff % interval != 0) return [];
        if (count != null && monthsDiff ~/ interval >= count) return [];
        return [query];

      case 'YEARLY':
        if (query.isBefore(anchor)) return [];
        if (until != null && query.isAfter(until)) return [];
        final byMonth = int.tryParse(parts['BYMONTH'] ?? '');
        final byMonthDay = int.tryParse(parts['BYMONTHDAY'] ?? '');
        if (byMonth != null && query.month != byMonth) return [];
        if (byMonth == null && query.month != anchor.month) return [];
        if (byMonthDay != null && query.day != byMonthDay) return [];
        if (byMonthDay == null && query.day != anchor.day) return [];
        final interval = int.tryParse(parts['INTERVAL'] ?? '1') ?? 1;
        final yearsDiff = query.year - anchor.year;
        if (yearsDiff % interval != 0) return [];
        if (count != null && yearsDiff ~/ interval >= count) return [];
        return [query];

      default:
        return [];
    }
  }

  /// Parses `KEY=VALUE;KEY=VALUE` rule string into a map.
  static Map<String, String> _parseRuleParts(String rule) {
    final map = <String, String>{};
    for (final part in rule.split(';')) {
      final eq = part.indexOf('=');
      if (eq > 0) {
        map[part.substring(0, eq).trim()] = part.substring(eq + 1).trim();
      }
    }
    return map;
  }

  /// Parses `BYDAY=MO,TU,WE` into a set of [DateTime] weekday constants.
  static Set<int> _parseByDay(String byDay) {
    if (byDay.isEmpty) return {};
    const dayMap = {
      'MO': DateTime.monday,
      'TU': DateTime.tuesday,
      'WE': DateTime.wednesday,
      'TH': DateTime.thursday,
      'FR': DateTime.friday,
      'SA': DateTime.saturday,
      'SU': DateTime.sunday,
    };
    final result = <int>{};
    for (final token in byDay.split(',')) {
      final key = token.trim().replaceAll(RegExp(r'[+-]\d+'), '');
      final day = dayMap[key];
      if (day != null) result.add(day);
    }
    return result;
  }

  /// Parses an RRULE UNTIL value (basic ISO 8601 date or datetime).
  static DateTime? _parseUntil(String? until) {
    if (until == null || until.isEmpty) return null;
    try {
      // Accept YYYYMMDD or YYYYMMDDTHHMMSSZ
      final s = until.replaceAll('T', '').replaceAll('Z', '');
      if (s.length >= 8) {
        final y = int.parse(s.substring(0, 4));
        final m = int.parse(s.substring(4, 6));
        final d = int.parse(s.substring(6, 8));
        return DateTime(y, m, d);
      }
    } catch (_) {}
    return null;
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
