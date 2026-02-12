import 'package:teno_rrule/teno_rrule.dart' as teno_rrule;

/// Defines the frequency at which a recurring event repeats.
enum MCalFrequency {
  /// The event repeats every day (or every N days with interval).
  daily,

  /// The event repeats every week (or every N weeks with interval).
  weekly,

  /// The event repeats every month (or every N months with interval).
  monthly,

  /// The event repeats every year (or every N years with interval).
  yearly,
}

/// Represents a day of the week, optionally with an occurrence qualifier.
///
/// Used in recurrence rules to specify which days of the week the event
/// occurs on. The optional [occurrence] field allows specifying a particular
/// instance within a month (e.g., "first Monday" or "last Friday").
///
/// Example:
/// ```dart
/// // Every Tuesday
/// final everyTuesday = MCalWeekDay.every(DateTime.tuesday);
///
/// // The first Monday of the month
/// final firstMonday = MCalWeekDay.nth(DateTime.monday, 1);
///
/// // The last Friday of the month
/// final lastFriday = MCalWeekDay.nth(DateTime.friday, -1);
/// ```
class MCalWeekDay {
  /// The day of the week, using [DateTime.monday] (1) through
  /// [DateTime.sunday] (7).
  final int dayOfWeek;

  /// The occurrence of the day within a month.
  ///
  /// Positive values count from the beginning (1 = first, 2 = second, etc.).
  /// Negative values count from the end (-1 = last, -2 = second to last, etc.).
  /// When `null`, the rule applies to every occurrence of this day.
  final int? occurrence;

  /// Creates a new [MCalWeekDay] with the given [dayOfWeek] and optional
  /// [occurrence].
  const MCalWeekDay(this.dayOfWeek, [this.occurrence]);

  /// Creates a [MCalWeekDay] that matches every occurrence of [dayOfWeek]
  /// in a period.
  ///
  /// This is equivalent to `MCalWeekDay(dayOfWeek)` with `occurrence = null`.
  const MCalWeekDay.every(this.dayOfWeek) : occurrence = null;

  /// Creates a [MCalWeekDay] that matches the [n]th occurrence of [dayOfWeek]
  /// in a month.
  ///
  /// Use positive values for counting from the start (1 = first, 2 = second)
  /// and negative values for counting from the end (-1 = last).
  const MCalWeekDay.nth(this.dayOfWeek, int n) : occurrence = n;

  /// Creates a copy of this [MCalWeekDay] with the given fields replaced.
  MCalWeekDay copyWith({
    int? dayOfWeek,
    int? Function()? occurrence,
  }) {
    return MCalWeekDay(
      dayOfWeek ?? this.dayOfWeek,
      occurrence != null ? occurrence() : this.occurrence,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MCalWeekDay &&
        other.dayOfWeek == dayOfWeek &&
        other.occurrence == occurrence;
  }

  @override
  int get hashCode => Object.hash(dayOfWeek, occurrence);

  @override
  String toString() {
    return 'MCalWeekDay(dayOfWeek: $dayOfWeek, occurrence: $occurrence)';
  }
}

/// An immutable recurrence rule that defines how a recurring event repeats.
///
/// Wraps the `teno_rrule` package internally for RFC 5545 RRULE parsing,
/// serialization, and occurrence expansion. The `teno_rrule` types are never
/// exposed in the public API.
///
/// Example:
/// ```dart
/// // Every other week on Tuesday and Thursday
/// final rule = MCalRecurrenceRule(
///   frequency: MCalFrequency.weekly,
///   interval: 2,
///   byWeekDays: {
///     MCalWeekDay.every(DateTime.tuesday),
///     MCalWeekDay.every(DateTime.thursday),
///   },
/// );
///
/// // Parse from RFC 5545 RRULE string
/// final parsed = MCalRecurrenceRule.fromRruleString(
///   'RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH',
/// );
///
/// // Get occurrences in a date range
/// final dates = rule.getOccurrences(
///   start: DateTime(2024, 1, 1),
///   after: DateTime(2024, 1, 1),
///   before: DateTime(2024, 2, 1),
/// );
/// ```
class MCalRecurrenceRule {
  /// The frequency at which the event repeats.
  final MCalFrequency frequency;

  /// The interval between recurrences. Defaults to 1.
  ///
  /// For example, an [interval] of 2 with [frequency] of [MCalFrequency.weekly]
  /// means the event repeats every 2 weeks.
  final int interval;

  /// The maximum number of occurrences. Mutually exclusive with [until].
  final int? count;

  /// The end date for the recurrence (inclusive). Mutually exclusive with
  /// [count].
  final DateTime? until;

  /// The days of the week on which the event occurs.
  ///
  /// Used primarily with [MCalFrequency.weekly], but also with
  /// [MCalFrequency.monthly] and [MCalFrequency.yearly] to specify
  /// specific weekday occurrences (e.g., "first Monday").
  /// Per RFC 5545 BYDAY, order is insignificant — use [Set] for spec alignment.
  final Set<MCalWeekDay>? byWeekDays;

  /// The days of the month on which the event occurs (1-31).
  ///
  /// Negative values count from the end of the month (-1 = last day).
  final List<int>? byMonthDays;

  /// The months in which the event occurs (1-12).
  final List<int>? byMonths;

  /// The positions within the set of occurrences to include.
  ///
  /// Used to filter the expanded set (e.g., 1 = first, -1 = last).
  final List<int>? bySetPositions;

  /// The days of the year on which the event occurs (1-366).
  ///
  /// Negative values count from the end of the year (-1 = last day).
  /// Only valid with [MCalFrequency.yearly] per RFC 5545.
  final List<int>? byYearDays;

  /// The week numbers in which the event occurs (1-53).
  ///
  /// Negative values count from the end of the year (-1 = last week).
  /// Only valid with [MCalFrequency.yearly] per RFC 5545.
  final List<int>? byWeekNumbers;

  /// The day that starts the week. Defaults to [DateTime.monday].
  ///
  /// Uses [DateTime.monday] (1) through [DateTime.sunday] (7).
  final int weekStart;

  /// Creates a new [MCalRecurrenceRule].
  ///
  /// Throws [ArgumentError] if both [count] and [until] are provided,
  /// or if [interval] is less than 1.
  MCalRecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.count,
    this.until,
    this.byWeekDays,
    this.byMonthDays,
    this.byMonths,
    this.bySetPositions,
    this.byYearDays,
    this.byWeekNumbers,
    this.weekStart = DateTime.monday,
  }) {
    if (count != null && until != null) {
      throw ArgumentError(
        'count and until are mutually exclusive; '
        'only one may be specified.',
      );
    }
    if (interval < 1) {
      throw ArgumentError('interval must be >= 1, but was $interval.');
    }
    if (byYearDays != null && frequency != MCalFrequency.yearly) {
      throw ArgumentError(
        'byYearDays is only valid with yearly frequency, '
        'but frequency was $frequency.',
      );
    }
    if (byWeekNumbers != null && frequency != MCalFrequency.yearly) {
      throw ArgumentError(
        'byWeekNumbers is only valid with yearly frequency, '
        'but frequency was $frequency.',
      );
    }
  }

  /// Creates an [MCalRecurrenceRule] from an RFC 5545 RRULE string.
  ///
  /// The [rruleString] should be in the format `RRULE:FREQ=...;...` or
  /// just `FREQ=...;...`.
  ///
  /// Throws [ArgumentError] if the string cannot be parsed or contains
  /// an unsupported frequency (SECONDLY, MINUTELY, HOURLY).
  ///
  /// Example:
  /// ```dart
  /// final rule = MCalRecurrenceRule.fromRruleString(
  ///   'RRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH',
  /// );
  /// ```
  factory MCalRecurrenceRule.fromRruleString(String rruleString) {
    // Ensure the input has the RRULE: prefix for consistency
    String rrulePart = rruleString;
    if (!rrulePart.startsWith('RRULE:')) {
      rrulePart = 'RRULE:$rrulePart';
    }

    // Prepend a dummy DTSTART since teno_rrule requires it for parsing
    final input = 'DTSTART:19700101T000000\n$rrulePart';

    final parsed = teno_rrule.RecurrenceRule.from(input);
    if (parsed == null) {
      throw ArgumentError('Failed to parse RRULE string: $rruleString');
    }

    return _fromTenoRrule(parsed);
  }

  /// Converts this rule to an RFC 5545 RRULE string.
  ///
  /// Returns a string in the format `RRULE:FREQ=...;...`.
  ///
  /// Example:
  /// ```dart
  /// final rule = MCalRecurrenceRule(
  ///   frequency: MCalFrequency.weekly,
  ///   interval: 2,
  /// );
  /// print(rule.toRruleString()); // RRULE:FREQ=WEEKLY;INTERVAL=2
  /// ```
  String toRruleString() {
    // Use a dummy start date for serialization — DTSTART is not part of RRULE
    final tenoRule = _toTenoRrule(DateTime(1970));
    final fullString = tenoRule.rfc5545String;

    // Extract just the RRULE line, stripping DTSTART
    for (final line in fullString.split('\n')) {
      if (line.startsWith('RRULE:')) {
        return line;
      }
    }

    // Fallback: return the full string if no RRULE line found
    return fullString;
  }

  /// Expands this rule into a list of occurrence dates within the given range.
  ///
  /// **Required: [start] as DTSTART** — [start] is the series start date
  /// (DTSTART in RFC 5545). It defines the first instance in the recurrence
  /// set and anchors all recurrence calculations. The [start] value MUST be
  /// synchronized with the recurrence rule (e.g., for BYDAY=TU,TH, [start]
  /// should fall on a Tuesday or Thursday). Pass the master event's [start]
  /// when expanding recurring events.
  ///
  /// [after] is the beginning of the query range (inclusive).
  /// [before] is the end of the query range (exclusive).
  ///
  /// Handles `teno_rrule`'s UTC/local requirements internally so callers
  /// can pass normal [DateTime] values.
  ///
  /// Example:
  /// ```dart
  /// final rule = MCalRecurrenceRule(
  ///   frequency: MCalFrequency.daily,
  ///   interval: 1,
  /// );
  /// final dates = rule.getOccurrences(
  ///   start: DateTime(2024, 1, 1),
  ///   after: DateTime(2024, 1, 1),
  ///   before: DateTime(2024, 1, 8),
  /// );
  /// // dates: [Jan 1, Jan 2, Jan 3, Jan 4, Jan 5, Jan 6, Jan 7]
  /// ```
  List<DateTime> getOccurrences({
    required DateTime start,
    required DateTime after,
    required DateTime before,
  }) {
    final tenoRule = _toTenoRrule(start);
    return tenoRule.between(after, before);
  }

  /// Converts this [MCalRecurrenceRule] to a `teno_rrule` [RecurrenceRule].
  ///
  /// [dtStart] is the series start date used as the DTSTART.
  teno_rrule.RecurrenceRule _toTenoRrule(DateTime dtStart) {
    return teno_rrule.RecurrenceRule(
      frequency: _toTenoFrequency(frequency),
      startDate: dtStart,
      isLocal: true,
      endDate: until,
      interval: interval,
      count: count,
      byWeekDays: byWeekDays != null
          ? byWeekDays!
              .map(
                (wd) => teno_rrule.WeekDay(wd.dayOfWeek, wd.occurrence),
              )
              .toSet()
          : null,
      byMonthDays: byMonthDays?.toSet(),
      byMonths: byMonths?.toSet(),
      bySetPositions: bySetPositions?.toSet(),
      byYearDays: byYearDays?.toSet(),
      byWeeks: byWeekNumbers?.toSet(),
      weekStart: weekStart,
    );
  }

  /// Converts a `teno_rrule` [RecurrenceRule] to an [MCalRecurrenceRule].
  static MCalRecurrenceRule _fromTenoRrule(teno_rrule.RecurrenceRule rule) {
    return MCalRecurrenceRule(
      frequency: _fromTenoFrequency(rule.frequency),
      interval: rule.interval,
      count: rule.count,
      until: rule.endDate,
      byWeekDays: rule.byWeekDays
          ?.map((wd) => MCalWeekDay(wd.weekDay, wd.occurrence))
          .toSet(),
      byMonthDays: rule.byMonthDays?.toList(),
      byMonths: rule.byMonths?.toList(),
      bySetPositions: rule.bySetPositions?.toList(),
      byYearDays: rule.byYearDays?.toList(),
      byWeekNumbers: rule.byWeeks?.toList(),
      weekStart: rule.weekStart ?? DateTime.monday,
    );
  }

  /// Creates a copy of this rule with the given fields replaced.
  ///
  /// Nullable fields use a callback pattern to allow explicitly setting
  /// them to `null` (e.g., `count: () => null` to clear count).
  MCalRecurrenceRule copyWith({
    MCalFrequency? frequency,
    int? interval,
    int? Function()? count,
    DateTime? Function()? until,
    Set<MCalWeekDay>? Function()? byWeekDays,
    List<int>? Function()? byMonthDays,
    List<int>? Function()? byMonths,
    List<int>? Function()? bySetPositions,
    List<int>? Function()? byYearDays,
    List<int>? Function()? byWeekNumbers,
    int? weekStart,
  }) {
    return MCalRecurrenceRule(
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      count: count != null ? count() : this.count,
      until: until != null ? until() : this.until,
      byWeekDays: byWeekDays != null ? byWeekDays() : this.byWeekDays,
      byMonthDays: byMonthDays != null ? byMonthDays() : this.byMonthDays,
      byMonths: byMonths != null ? byMonths() : this.byMonths,
      bySetPositions:
          bySetPositions != null ? bySetPositions() : this.bySetPositions,
      byYearDays: byYearDays != null ? byYearDays() : this.byYearDays,
      byWeekNumbers: byWeekNumbers != null ? byWeekNumbers() : this.byWeekNumbers,
      weekStart: weekStart ?? this.weekStart,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MCalRecurrenceRule &&
        other.frequency == frequency &&
        other.interval == interval &&
        other.count == count &&
        other.until == until &&
        _setEquals(other.byWeekDays, byWeekDays) &&
        _unorderedEquals(other.byMonthDays, byMonthDays) &&
        _unorderedEquals(other.byMonths, byMonths) &&
        _unorderedEquals(other.bySetPositions, bySetPositions) &&
        _unorderedEquals(other.byYearDays, byYearDays) &&
        _unorderedEquals(other.byWeekNumbers, byWeekNumbers) &&
        other.weekStart == weekStart;
  }

  @override
  int get hashCode => Object.hash(
        frequency,
        interval,
        count,
        until,
        byWeekDays != null ? _setHashCode(byWeekDays!) : null,
        byMonthDays != null ? _unorderedHashAll(byMonthDays!) : null,
        byMonths != null ? _unorderedHashAll(byMonths!) : null,
        bySetPositions != null ? _unorderedHashAll(bySetPositions!) : null,
        byYearDays != null ? _unorderedHashAll(byYearDays!) : null,
        byWeekNumbers != null ? _unorderedHashAll(byWeekNumbers!) : null,
        weekStart,
      );

  @override
  String toString() {
    return 'MCalRecurrenceRule('
        'frequency: $frequency, '
        'interval: $interval, '
        'count: $count, '
        'until: $until, '
        'byWeekDays: $byWeekDays, '
        'byMonthDays: $byMonthDays, '
        'byMonths: $byMonths, '
        'bySetPositions: $bySetPositions, '
        'byYearDays: $byYearDays, '
        'byWeekNumbers: $byWeekNumbers, '
        'weekStart: $weekStart)';
  }

  // -- Static helpers for frequency conversion --

  static teno_rrule.Frequency _toTenoFrequency(MCalFrequency freq) {
    return switch (freq) {
      MCalFrequency.daily => teno_rrule.Frequency.daily,
      MCalFrequency.weekly => teno_rrule.Frequency.weekly,
      MCalFrequency.monthly => teno_rrule.Frequency.monthly,
      MCalFrequency.yearly => teno_rrule.Frequency.yearly,
    };
  }

  static MCalFrequency _fromTenoFrequency(teno_rrule.Frequency freq) {
    return switch (freq) {
      teno_rrule.Frequency.daily => MCalFrequency.daily,
      teno_rrule.Frequency.weekly => MCalFrequency.weekly,
      teno_rrule.Frequency.monthly => MCalFrequency.monthly,
      teno_rrule.Frequency.yearly => MCalFrequency.yearly,
      teno_rrule.Frequency.secondly ||
      teno_rrule.Frequency.minutely ||
      teno_rrule.Frequency.hourly =>
        throw ArgumentError(
          'Unsupported frequency: ${freq.value}. '
          'Only DAILY, WEEKLY, MONTHLY, and YEARLY are supported.',
        ),
    };
  }
}

/// Compares two sets for equality.
bool _setEquals<T>(Set<T>? a, Set<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b;
  return a.length == b.length && a.containsAll(b);
}

/// Order-independent hash for a set.
int _setHashCode(Set<Object> set) {
  return set.fold<int>(0, (h, item) => h ^ item.hashCode);
}

/// Compares two lists for equality regardless of element order.
///
/// Uses set-based comparison since RFC 5545 collection fields (BYMONTHDAY,
/// BYMONTH, etc.) are unordered sets semantically.
bool _unorderedEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  final setA = Set<T>.from(a);
  final setB = Set<T>.from(b);
  return setA.length == setB.length && setA.containsAll(setB);
}

/// Computes an order-independent hash for a list of objects.
int _unorderedHashAll(List<Object> list) {
  return list.fold<int>(0, (prev, item) => prev + item.hashCode);
}
