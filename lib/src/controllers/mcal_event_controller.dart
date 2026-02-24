import 'package:flutter/material.dart';
import '../models/mcal_calendar_event.dart';
import '../models/mcal_event_change_info.dart';
import '../utils/date_utils.dart';
import '../models/mcal_recurrence_exception.dart';
import '../models/mcal_recurrence_rule.dart';

/// Controller for managing calendar events, recurring event expansion, and
/// view state.
///
/// Extends [ChangeNotifier] for reactive state management — widgets rebuild
/// when events are loaded, modified, or the visible range changes.
///
/// ## Core capabilities
///
/// - **Event storage**: In-memory cache indexed by event ID. Add events with
///   [addEvents], remove with [removeEvents] or [clearEvents].
/// - **Recurring event expansion**: Events with a non-null
///   [MCalCalendarEvent.recurrenceRule] are automatically expanded into
///   individual occurrences when queried via [getEventsForRange]. Multi-day
///   events that start before the query range but overlap into it are included
///   automatically — consumers do not need to pad the range.
/// - **Exception handling**: Add, remove, or overwrite per-occurrence
///   exceptions (deletions, reschedules, modifications) via [addException],
///   [removeException], and [modifyOccurrence]. Single-exception edits use
///   O(1) cache patching; overwrites invalidate the series cache.
/// - **Series management**: [updateRecurringEvent], [deleteRecurringEvent],
///   and [splitSeries] for full recurring event lifecycle management.
/// - **Change metadata**: [lastChange] describes each mutation for targeted
///   view rebuilds.
/// - **Delegation pattern**: Override [loadEvents] to integrate with any
///   database, API, or persistence layer. The controller handles expansion
///   and caching; the consumer handles storage.
///
/// ## Performance
///
/// - Expansion is lazy — only occurrences within the requested range.
/// - For daily/weekly events that started far in the past, the DTSTART is
///   advanced close to the query window to avoid a linear walk.
/// - Expanded occurrences are cached per series; repeated queries on the
///   same range are O(1).
///
/// ## Example
///
/// ```dart
/// final controller = MCalEventController();
///
/// // Add standalone and recurring events
/// controller.addEvents([
///   MCalCalendarEvent(
///     id: 'meeting',
///     title: 'Meeting',
///     start: DateTime(2024, 6, 15, 10, 0),
///     end: DateTime(2024, 6, 15, 11, 0),
///   ),
///   MCalCalendarEvent(
///     id: 'standup',
///     title: 'Daily Standup',
///     start: DateTime(2024, 6, 1, 9, 0),
///     end: DateTime(2024, 6, 1, 9, 15),
///     recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.daily),
///   ),
/// ]);
///
/// // Query — recurring events are expanded automatically
/// final events = controller.getEventsForRange(
///   DateTimeRange(
///     start: DateTime(2024, 6, 1),
///     end: DateTime(2024, 6, 30),
///   ),
/// );
///
/// // Add an exception (delete a single occurrence)
/// controller.addException(
///   'standup',
///   MCalRecurrenceException.deleted(originalDate: DateTime(2024, 6, 10)),
/// );
/// ```
class MCalEventController extends ChangeNotifier {
  /// The currently visible date range in the calendar view.
  DateTimeRange? _visibleDateRange;

  /// Cached events indexed by their ID for efficient lookup.
  final Map<String, MCalCalendarEvent> _eventsById = {};

  // ============================================================
  // Task 1: Display and Focus Date State
  // ============================================================

  /// The currently displayed date in the calendar view.
  ///
  /// This represents the primary date being shown (e.g., the month being viewed).
  /// Initialized from the constructor's initialDate parameter, defaults to today.
  DateTime _displayDate;

  /// The currently focused date in the calendar view.
  ///
  /// This represents a specific date that has focus (e.g., user selection).
  /// Can be null if no specific date is focused.
  DateTime? _focusedDate;

  // ============================================================
  // Task 2: Loading and Error State
  // ============================================================

  /// Whether events are currently being loaded.
  bool _isLoading = false;

  /// The current error, if any occurred during loading.
  Object? _error;

  // ============================================================
  // Task 7: Animation Control State
  // ============================================================

  /// Whether the next display date change should animate.
  ///
  /// This flag is consumed by the view after reading, allowing programmatic
  /// navigation to optionally skip animation.
  bool _animateNextChange = true;

  // ============================================================
  // Recurrence Foundation State
  // ============================================================

  /// Exception store: seriesId -> {normalizedOriginalDate -> exception}.
  ///
  /// Stores recurrence exceptions keyed by series ID and then by normalized
  /// original date for O(1) lookup during expansion.
  final Map<String, Map<DateTime, MCalRecurrenceException>>
      _exceptionsBySeriesId = {};

  /// Expansion cache: seriesId -> expanded occurrence list.
  ///
  /// Caches expanded occurrences for each recurring series so that
  /// repeated calls to [getEventsForRange] don't re-expand.
  final Map<String, List<MCalCalendarEvent>> _expandedBySeriesId = {};

  /// The date range for which [_expandedBySeriesId] is valid.
  DateTimeRange? _expandedRange;

  /// Metadata describing the last mutation performed on the controller.
  ///
  /// Set before [notifyListeners] by mutation methods to enable targeted
  /// view rebuilds.
  MCalEventChangeInfo? _lastChange;

  /// The first day of the week for visual calendar layout and recurrence
  /// expansion.
  ///
  /// Uses the same convention as [DateTime.weekday]:
  /// - 0 = Sunday
  /// - 1 = Monday
  /// - 2 = Tuesday
  /// - 3 = Wednesday
  /// - 4 = Thursday
  /// - 5 = Friday
  /// - 6 = Saturday
  ///
  /// This value affects both visual layout (which day appears in the leftmost
  /// column of week rows) and recurrence expansion: it is used as the fallback
  /// `WKST` when expanding any [MCalRecurrenceRule] whose
  /// [MCalRecurrenceRule.weekStart] is `null`. A rule with an explicit
  /// `weekStart` (e.g. imported from a CalDAV feed with a `WKST` component)
  /// uses that value instead.
  ///
  /// When `null`, defaults to [DateTime.monday] (ISO 8601 standard).
  ///
  /// Setting this property notifies listeners so the calendar redraws
  /// immediately, without needing to recreate the controller.
  int? get firstDayOfWeek => _firstDayOfWeek;
  int? _firstDayOfWeek;

  set firstDayOfWeek(int? value) {
    if (_firstDayOfWeek == value) return;
    _firstDayOfWeek = value;
    // firstDayOfWeek is used as the fallback WKST during recurrence expansion;
    // changing it invalidates any cached expansions.
    _expandedBySeriesId.clear();
    _expandedRange = null;
    notifyListeners();
  }

  /// Creates a new [MCalEventController] instance.
  ///
  /// [initialDate] sets the initially displayed date. Defaults to today if not provided.
  /// The view will display the month containing this date.
  ///
  /// [firstDayOfWeek] sets the first day of the week (0 = Sunday … 6 = Saturday).
  /// Defaults to Monday (ISO 8601) when `null`. Affects both visual layout and
  /// recurrence expansion: used as the fallback `WKST` when a rule's own
  /// [MCalRecurrenceRule.weekStart] is `null`. Can be changed at any time via
  /// the [firstDayOfWeek] setter.
  MCalEventController({DateTime? initialDate, int? firstDayOfWeek})
    : _firstDayOfWeek = firstDayOfWeek,
      _displayDate = initialDate ?? DateTime.now();

  // ============================================================
  // Task 1: Display and Focus Date Getters
  // ============================================================

  /// Gets the currently displayed date.
  DateTime get displayDate => _displayDate;

  /// Gets the currently focused date, or null if none.
  DateTime? get focusedDate => _focusedDate;

  // ============================================================
  // Task 2: Loading and Error State Getters
  // ============================================================

  /// Whether events are currently being loaded.
  bool get isLoading => _isLoading;

  /// The current error, or null if no error.
  Object? get error => _error;

  /// Whether there is a current error.
  bool get hasError => _error != null;

  // ============================================================
  // Task 7: Animation Control Getters
  // ============================================================

  /// Whether the next display date change should animate.
  ///
  /// Views should check this flag when handling displayDate changes to
  /// determine whether to animate or jump directly to the new date.
  /// After reading this value, call [consumeAnimationFlag] to reset it.
  bool get shouldAnimateNextChange => _animateNextChange;

  // ============================================================
  // Recurrence Foundation Getters
  // ============================================================

  /// The last change info describing the most recent mutation.
  ///
  /// Returns null if no mutation has been performed yet. Updated before
  /// [notifyListeners] by methods like [addEvents], [clearEvents], and
  /// future recurrence mutation methods.
  MCalEventChangeInfo? get lastChange => _lastChange;

  /// The resolved first day of the week for visual calendar layout and
  /// recurrence expansion.
  ///
  /// Returns [firstDayOfWeek] if set, otherwise defaults to [DateTime.monday] (1).
  ///
  /// This value:
  /// - Determines which day appears in the leftmost column of calendar week rows.
  /// - Acts as the fallback `WKST` when expanding recurrence rules whose
  ///   [MCalRecurrenceRule.weekStart] is `null` (i.e. no explicit `WKST` was
  ///   set on the rule). When a rule has an explicit `weekStart`, that value
  ///   takes precedence over this one.
  int get resolvedFirstDayOfWeek => _firstDayOfWeek ?? DateTime.monday;

  /// Converts the controller's [firstDayOfWeek] convention (0 = Sunday … 6 = Saturday)
  /// to the [MCalRecurrenceRule.weekStart] convention ([DateTime.monday] = 1 …
  /// [DateTime.sunday] = 7).
  ///
  /// The only difference is Sunday: the controller stores it as 0, while
  /// [DateTime.sunday] is 7.
  static int _toRuleWeekStart(int controllerDay) =>
      controllerDay == 0 ? DateTime.sunday : controllerDay;

  // ============================================================
  // Task 1: Display and Focus Date Methods
  // ============================================================

  /// Sets the display date.
  ///
  /// Updates the display date and notifies listeners only if the value changed.
  ///
  /// Parameters:
  /// - [date]: The new display date
  /// - [animate]: Whether the view should animate to the new date (defaults to true).
  ///   When false, sets [shouldAnimateNextChange] to false before notifying listeners,
  ///   allowing views to skip animation and jump directly to the new date.
  void setDisplayDate(DateTime date, {bool animate = true}) {
    if (_displayDate != date) {
      if (!animate) {
        _animateNextChange = false;
      }
      _displayDate = date;
      notifyListeners();
    }
  }

  /// Sets the focused date.
  ///
  /// Updates the focused date and notifies listeners only if the value changed.
  ///
  /// Parameters:
  /// - [date]: The new focused date, or null to clear focus
  void setFocusedDate(DateTime? date) {
    if (_focusedDate != date) {
      _focusedDate = date;
      notifyListeners();
    }
  }

  /// Navigates to a specific date.
  ///
  /// Updates the display date and optionally sets the focused date.
  /// Notifies listeners only if something changed.
  ///
  /// Parameters:
  /// - [date]: The date to navigate to
  /// - [focus]: Whether to also set this date as focused (defaults to true)
  void navigateToDate(DateTime date, {bool focus = true}) {
    final displayChanged = _displayDate != date;
    final focusChanged = focus && _focusedDate != date;

    if (displayChanged) {
      _displayDate = date;
    }
    if (focusChanged) {
      _focusedDate = date;
    }

    if (displayChanged || focusChanged) {
      notifyListeners();
    }
  }

  // ============================================================
  // Task 7: Animation Control Methods
  // ============================================================

  /// Resets the animation flag after the view has read it.
  ///
  /// Views should call this method after reading [shouldAnimateNextChange]
  /// and before handling the display date change. This ensures the flag
  /// is reset to true for subsequent navigations.
  ///
  /// Typical usage in a view:
  /// ```dart
  /// final shouldAnimate = controller.shouldAnimateNextChange;
  /// controller.consumeAnimationFlag();
  /// if (shouldAnimate) {
  ///   pageController.animateToPage(...);
  /// } else {
  ///   pageController.jumpToPage(...);
  /// }
  /// ```
  void consumeAnimationFlag() {
    _animateNextChange = true;
  }

  /// Navigates to a specific date without animation.
  ///
  /// This is a convenience method that calls [setDisplayDate] with
  /// `animate: false`, causing views to jump directly to the new date
  /// instead of animating.
  ///
  /// Parameters:
  /// - [date]: The date to navigate to
  void navigateToDateWithoutAnimation(DateTime date) {
    setDisplayDate(date, animate: false);
  }

  // ============================================================
  // Task 2: Loading and Error State Methods
  // ============================================================

  /// Sets the loading state.
  ///
  /// Updates the loading state and notifies listeners only if the value changed.
  ///
  /// Parameters:
  /// - [loading]: Whether events are currently loading
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Sets an error and stops loading.
  ///
  /// Sets the error state, sets loading to false, and notifies listeners.
  ///
  /// Parameters:
  /// - [error]: The error that occurred
  void setError(Object? error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  /// Clears the current error.
  ///
  /// Clears the error state and notifies listeners only if there was an error.
  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  /// Retries loading events after an error.
  ///
  /// Clears the current error and loads events for a 3-month range
  /// centered around the current display date.
  ///
  /// Returns a [Future] that completes with the loaded events.
  Future<List<MCalCalendarEvent>> retryLoad() async {
    clearError();
    final start = DateTime(_displayDate.year, _displayDate.month - 1, 1);
    final end = DateTime(_displayDate.year, _displayDate.month + 2, 0);
    return loadEvents(start, end);
  }

  /// Loads events for the specified date range.
  ///
  /// Override this method in a subclass to implement custom event loading
  /// from a database, API, or other data source. The base implementation
  /// returns events already cached that fall within the specified range.
  ///
  /// After loading events from an external source, call [addEvents] to
  /// cache them and notify listeners.
  ///
  /// Parameters:
  /// - [start]: The start date/time of the range
  /// - [end]: The end date/time of the range
  ///
  /// Returns a [Future] that completes with a list of [MCalCalendarEvent] instances.
  ///
  /// Example:
  /// ```dart
  /// class MyEventController extends MCalEventController {
  ///   @override
  ///   Future<List<MCalCalendarEvent>> loadEvents(DateTime start, DateTime end) async {
  ///     final events = await myApi.fetchEvents(start, end);
  ///     addEvents(events);
  ///     return events;
  ///   }
  /// }
  /// ```
  Future<List<MCalCalendarEvent>> loadEvents(
    DateTime start,
    DateTime end,
  ) async {
    // Base implementation returns cached events for the range
    return getEventsForRange(DateTimeRange(start: start, end: end));
  }

  /// Adds events to the controller's cache.
  ///
  /// Events are indexed by their ID for O(1) lookup. If an event with the
  /// same ID already exists, it will be replaced. Recurring events (those
  /// with a non-null [MCalCalendarEvent.recurrenceRule]) are stored as master
  /// events and expanded lazily when [getEventsForRange] is called.
  ///
  /// Sets [lastChange] with type [MCalChangeType.bulkChange] and calls
  /// [notifyListeners].
  ///
  /// ## Example
  ///
  /// ```dart
  /// controller.addEvents([
  ///   MCalCalendarEvent(
  ///     id: 'weekly-meeting',
  ///     title: 'Team Meeting',
  ///     start: DateTime(2024, 1, 2, 10, 0),
  ///     end: DateTime(2024, 1, 2, 11, 0),
  ///     recurrenceRule: MCalRecurrenceRule(frequency: MCalFrequency.weekly),
  ///   ),
  /// ]);
  /// ```
  void addEvents(List<MCalCalendarEvent> events) {
    for (final event in events) {
      _eventsById[event.id] = event;
    }
    _lastChange = MCalEventChangeInfo(
      type: MCalChangeType.bulkChange,
      affectedEventIds: events.map((e) => e.id).toSet(),
    );
    notifyListeners();
  }

  /// Removes events from the controller's cache.
  ///
  /// Events are removed by their ID.
  ///
  /// Notifies listeners after removing events.
  ///
  /// Parameters:
  /// - [eventIds]: The list of event IDs to remove
  void removeEvents(List<String> eventIds) {
    for (final id in eventIds) {
      _eventsById.remove(id);
    }
    _lastChange = MCalEventChangeInfo(
      type: MCalChangeType.bulkChange,
      affectedEventIds: eventIds.toSet(),
    );
    notifyListeners();
  }

  /// Clears all events from the controller's cache.
  ///
  /// Notifies listeners after clearing events.
  void clearEvents() {
    final clearedIds = _eventsById.keys.toSet();
    _eventsById.clear();
    _lastChange = MCalEventChangeInfo(
      type: MCalChangeType.bulkChange,
      affectedEventIds: clearedIds,
    );
    notifyListeners();
  }

  /// Gets all cached events.
  ///
  /// Returns an unmodifiable list of all events in the cache.
  List<MCalCalendarEvent> get allEvents =>
      List.unmodifiable(_eventsById.values);

  /// Gets a single cached event by its ID.
  ///
  /// Returns the [MCalCalendarEvent] with the given [id], or `null` if
  /// no event with that ID exists in the cache.
  MCalCalendarEvent? getEventById(String id) => _eventsById[id];

  /// Gets events that fall within the specified date range.
  ///
  /// **Standalone events** are included if they overlap with [range] (event
  /// starts before range ends AND event ends after range starts).
  ///
  /// **Recurring events** are expanded into individual
  /// [MCalCalendarEvent] occurrences. The expansion engine:
  /// - Generates occurrences via [MCalRecurrenceRule.getOccurrences].
  /// - Pads the query backwards by the event's duration so that multi-day
  ///   events whose start is before [range] but whose end overlaps into it
  ///   are included automatically. Consumers do **not** need to pad the range.
  /// - For daily/weekly events from the far past, advances the DTSTART
  ///   close to the query window for O(1) iteration.
  /// - Applies exceptions: deleted occurrences are skipped, rescheduled
  ///   occurrences are moved, modified occurrences are replaced.
  /// - Caches expanded occurrences per series; repeated queries on the same
  ///   range are served from cache.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final events = controller.getEventsForRange(
  ///   DateTimeRange(
  ///     start: DateTime(2024, 6, 1),
  ///     end: DateTime(2024, 6, 30, 23, 59, 59),
  ///   ),
  /// );
  /// ```
  ///
  /// Returns a list of events (standalone + expanded occurrences) that
  /// overlap with [range].
  List<MCalCalendarEvent> getEventsForRange(DateTimeRange range) {
    // If the query range differs from the cached range, invalidate expansion cache
    if (_expandedRange != null &&
        (_expandedRange!.start != range.start ||
            _expandedRange!.end != range.end)) {
      _expandedBySeriesId.clear();
    }

    final results = <MCalCalendarEvent>[];

    for (final event in _eventsById.values) {
      if (event.recurrenceRule != null) {
        // Expand recurring event into occurrences
        final occurrences = _getExpandedOccurrences(event, range);
        results.addAll(occurrences);
      } else {
        // Existing logic for standalone events: overlap check
        final startsBeforeRangeEnds = !event.start.isAfter(range.end);
        final endsAfterRangeStarts = !event.end.isBefore(range.start);
        if (startsBeforeRangeEnds && endsAfterRangeStarts) {
          results.add(event);
        }
      }
    }

    // Update the cached range
    _expandedRange = range;

    return results;
  }

  /// Gets events for a specific date.
  ///
  /// Returns events that occur on the specified date, including:
  /// - Events that start on this date
  /// - Events that end on this date
  /// - Multi-day events that span this date
  ///
  /// Parameters:
  /// - [date]: The date to query
  ///
  /// Returns a list of events that occur on the specified date.
  List<MCalCalendarEvent> getEventsForDate(DateTime date) {
    final dayStart = dateOnly(date);
    final dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    return getEventsForRange(DateTimeRange(start: dayStart, end: dayEnd));
  }

  /// Gets the currently visible date range.
  ///
  /// Returns the visible [DateTimeRange] or null if not set.
  DateTimeRange? getVisibleDateRange() {
    return _visibleDateRange;
  }

  /// Sets the visible date range.
  ///
  /// This is called by calendar views when the visible range changes
  /// (e.g., when navigating to a different month).
  ///
  /// Notifies listeners after setting the range.
  ///
  /// Parameters:
  /// - [range]: The date range to set as visible
  void setVisibleDateRange(DateTimeRange range) {
    _visibleDateRange = range;
    notifyListeners();
  }

  // ============================================================
  // Recurrence Foundation Helpers
  // ============================================================

  /// Normalizes a [DateTime] to midnight (strips time components).
  ///
  /// Returns midnight of the given date for consistent map keying in the
  /// exception store and expansion cache.
  DateTime _normalizeDate(DateTime date) => dateOnly(date);

  /// Advances a recurrence DTSTART close to [target] while staying aligned
  /// with the recurrence pattern defined by [rule].
  ///
  /// Only applied to **daily** and **weekly** frequencies whose iteration in
  /// teno_rrule simply adds days (preserving alignment). Monthly and yearly
  /// rules are left unchanged because teno_rrule resets the day to 1 during
  /// `_getNextInstance` and relies on ByXXX chain expansion relative to the
  /// original DTSTART — changing it would break implicit by-rule defaults.
  /// Monthly (≤12 iter/year) and yearly (≤1 iter/year) iteration counts are
  /// already negligible, so there is no performance concern.
  ///
  /// A one-period safety margin is kept so that by-rule expansions within
  /// a period (e.g. BYDAY=MO,WE,FR inside a WEEKLY period) are not missed.
  ///
  /// Returns [dtStart] unchanged when [target] is not after [dtStart] or
  /// when the frequency is monthly/yearly.
  DateTime _advanceDtStart(
    DateTime dtStart,
    MCalRecurrenceRule rule,
    DateTime target,
  ) {
    if (!target.isAfter(dtStart)) return dtStart;

    switch (rule.frequency) {
      case MCalFrequency.daily:
        final daysDiff = target.difference(dtStart).inDays;
        final periods = daysDiff ~/ rule.interval;
        // Keep one period of margin for safety.
        final safePeriods = (periods - 1).clamp(0, periods);
        return DateTime(
          dtStart.year,
          dtStart.month,
          dtStart.day + safePeriods * rule.interval,
          dtStart.hour,
          dtStart.minute,
          dtStart.second,
          dtStart.millisecond,
        );

      case MCalFrequency.weekly:
        final daysDiff = target.difference(dtStart).inDays;
        final weekPeriod = rule.interval * 7;
        final periods = daysDiff ~/ weekPeriod;
        final safePeriods = (periods - 1).clamp(0, periods);
        return DateTime(
          dtStart.year,
          dtStart.month,
          dtStart.day + safePeriods * weekPeriod,
          dtStart.hour,
          dtStart.minute,
          dtStart.second,
          dtStart.millisecond,
        );

      // Monthly and yearly: return unchanged (see doc comment above).
      case MCalFrequency.monthly:
      case MCalFrequency.yearly:
        return dtStart;
    }
  }

  // ============================================================
  // Task 8: Recurrence Expansion Engine
  // ============================================================

  /// Expands a recurring [master] event into individual occurrences for the
  /// given [range].
  ///
  /// Checks [_expandedBySeriesId] for a cache hit before expanding. When
  /// expanding, calls [MCalRecurrenceRule.getOccurrences] and applies
  /// exceptions from [_exceptionsBySeriesId]:
  /// - **deleted**: the occurrence is skipped
  /// - **rescheduled**: the occurrence's start/end are moved to [newDate]
  /// - **modified**: the occurrence is replaced with [modifiedEvent]
  ///
  /// For multi-day events, the query start is padded backwards by the event
  /// duration so that occurrences starting before the range but ending
  /// within it are included. An overlap check filters false positives.
  ///
  /// Each occurrence gets a deterministic ID of the form
  /// `"{masterId}_{normalizedDateIso8601}"` and an [occurrenceId] set to
  /// the normalized date's ISO 8601 string.
  ///
  /// Results are cached in [_expandedBySeriesId] for the current range.
  List<MCalCalendarEvent> _getExpandedOccurrences(
    MCalCalendarEvent master,
    DateTimeRange range,
  ) {
    // Check cache — if the expanded range matches, filter cached results.
    if (_expandedRange != null &&
        _expandedBySeriesId.containsKey(master.id) &&
        _expandedRange!.start == range.start &&
        _expandedRange!.end == range.end) {
      return _expandedBySeriesId[master.id]!
          .where((e) =>
              !e.start.isAfter(range.end) && !e.end.isBefore(range.start))
          .toList();
    }

    // Expand using MCalRecurrenceRule.getOccurrences()
    //
    // Use DST-safe calendar-day span instead of Duration for end time
    // calculation. Duration-based arithmetic shifts local times by ±1 hour
    // at DST boundaries (e.g., a 9 PM event becomes 8 PM or 10 PM).
    // Calendar-day arithmetic preserves the local time.
    final masterDaySpan = DateTime(
      master.end.year,
      master.end.month,
      master.end.day,
    )
        .difference(DateTime(
          master.start.year,
          master.start.month,
          master.start.day,
        ))
        .inDays;
    // Keep a Duration for the padding calculation only (a few hours off
    // at DST boundaries is fine for the padding heuristic).
    final duration = master.end.difference(master.start);

    // Pad the query start backwards by the event duration so that multi-day
    // occurrences whose start is before the range but whose end overlaps
    // into it are captured. For single-day events the pad is effectively
    // zero, so there is no performance penalty.
    final paddedAfter = range.start.subtract(duration);

    // Advance the DTSTART close to the query window to avoid a linear walk
    // from the real master start (which could be years in the past).
    // Only safe when there is no `count` — count-based rules must iterate
    // from the real start to count occurrences correctly.
    final optimizedStart = master.recurrenceRule!.count == null
        ? _advanceDtStart(master.start, master.recurrenceRule!, paddedAfter)
        : master.start;

    final occurrenceDates = master.recurrenceRule!.getOccurrences(
      start: optimizedStart,
      after: paddedAfter,
      before: range.end,
      fallbackWeekStart: _toRuleWeekStart(resolvedFirstDayOfWeek),
    );

    final exceptions = _exceptionsBySeriesId[master.id] ?? {};
    final expanded = <MCalCalendarEvent>[];
    final processedDateKeys = <DateTime>{};

    for (final date in occurrenceDates) {
      final dateKey = _normalizeDate(date);
      processedDateKeys.add(dateKey);
      final exception = exceptions[dateKey];

      if (exception != null) {
        switch (exception.type) {
          case MCalExceptionType.deleted:
            continue; // Skip this occurrence
          case MCalExceptionType.rescheduled:
            final newStart = exception.newDate!;
            // DST-safe end: preserve the master event's local-time duration.
            // The user may have set a different start time than the master,
            // so we apply the master's start→end delta to the new start.
            // DateTime's constructor handles overflow (e.g. hour 25 → next day).
            final newEnd = DateTime(
              newStart.year,
              newStart.month,
              newStart.day + masterDaySpan,
              newStart.hour + (master.end.hour - master.start.hour),
              newStart.minute + (master.end.minute - master.start.minute),
              newStart.second + (master.end.second - master.start.second),
              newStart.millisecond +
                  (master.end.millisecond - master.start.millisecond),
              newStart.microsecond +
                  (master.end.microsecond - master.start.microsecond),
            );
            // Only include if the rescheduled date falls within query range
            if (!newStart.isAfter(range.end) &&
                !newEnd.isBefore(range.start)) {
              expanded.add(master.copyWith(
                id: '${master.id}_${dateKey.toIso8601String()}',
                start: newStart,
                end: newEnd,
                occurrenceId: dateKey.toIso8601String(),
              ));
            }
            break;
          case MCalExceptionType.modified:
            final modEvent = exception.modifiedEvent!.copyWith(
              occurrenceId: dateKey.toIso8601String(),
            );
            // Only include if the modified event overlaps the query range
            if (!modEvent.start.isAfter(range.end) &&
                !modEvent.end.isBefore(range.start)) {
              expanded.add(modEvent);
            }
            break;
        }
      } else {
        // DST-safe end: preserve master.end's time with calendar-day offset.
        final occEnd = DateTime(
          date.year,
          date.month,
          date.day + masterDaySpan,
          master.end.hour,
          master.end.minute,
          master.end.second,
          master.end.millisecond,
          master.end.microsecond,
        );
        // Only include if the occurrence overlaps the original query range.
        // Occurrences in the padded zone whose end is still before the
        // range start are filtered out here.
        if (!date.isAfter(range.end) && !occEnd.isBefore(range.start)) {
          expanded.add(master.copyWith(
            id: '${master.id}_${dateKey.toIso8601String()}',
            start: date,
            end: occEnd,
            occurrenceId: dateKey.toIso8601String(),
          ));
        }
      }
    }

    // Include rescheduled occurrences whose original date falls outside the
    // query range but whose new date lands inside it.
    for (final entry in exceptions.entries) {
      final exception = entry.value;
      if (!processedDateKeys.contains(entry.key)) {
        if (exception.type == MCalExceptionType.rescheduled) {
          final newStart = exception.newDate!;
          // DST-safe end: preserve the master's local-time duration.
          final newEnd = DateTime(
            newStart.year,
            newStart.month,
            newStart.day + masterDaySpan,
            newStart.hour + (master.end.hour - master.start.hour),
            newStart.minute + (master.end.minute - master.start.minute),
            newStart.second + (master.end.second - master.start.second),
            newStart.millisecond +
                (master.end.millisecond - master.start.millisecond),
            newStart.microsecond +
                (master.end.microsecond - master.start.microsecond),
          );
          if (!newStart.isAfter(range.end) && !newEnd.isBefore(range.start)) {
            expanded.add(master.copyWith(
              id: '${master.id}_${entry.key.toIso8601String()}',
              start: newStart,
              end: newEnd,
              occurrenceId: entry.key.toIso8601String(),
            ));
          }
        } else if (exception.type == MCalExceptionType.modified) {
          // Include modified occurrences whose original date falls outside
          // the query range but whose modified event overlaps it.
          // This handles cross-month resizes where an occurrence on e.g.
          // Feb 1 is modified to start on Jan 22 — the January query must
          // include it even though Feb 1 is outside January's grid range.
          final modEvent = exception.modifiedEvent!.copyWith(
            occurrenceId: entry.key.toIso8601String(),
          );
          if (!modEvent.start.isAfter(range.end) &&
              !modEvent.end.isBefore(range.start)) {
            expanded.add(modEvent);
          }
        }
      }
    }

    // Cache results for this series
    _expandedBySeriesId[master.id] = expanded;
    return expanded;
  }

  /// Patches the expansion cache in O(1) when an exception is added.
  ///
  /// For **deleted** exceptions: removes the matching occurrence from cache.
  /// For **rescheduled** exceptions: finds and updates the matching
  /// occurrence's start/end.
  /// For **modified** exceptions: finds and replaces the matching occurrence.
  ///
  /// This avoids a full re-expansion of the series when a single exception
  /// is added.
  void _patchCacheForException(
    String seriesId,
    MCalRecurrenceException exception,
  ) {
    final cached = _expandedBySeriesId[seriesId];
    if (cached == null) return;

    final dateKey = _normalizeDate(exception.originalDate);
    final dateKeyIso = dateKey.toIso8601String();

    switch (exception.type) {
      case MCalExceptionType.deleted:
        cached.removeWhere((e) => e.occurrenceId == dateKeyIso);
        break;
      case MCalExceptionType.rescheduled:
        final idx = cached.indexWhere((e) => e.occurrenceId == dateKeyIso);
        if (idx >= 0) {
          final master = _eventsById[seriesId]!;
          // Use DST-safe calendar-day arithmetic to preserve the master's
          // local-time duration. The rescheduled start may have a different
          // time-of-day than the master, so apply the master's start→end
          // delta to the new start rather than using the master's end time.
          final daySpan = DateTime(
            master.end.year,
            master.end.month,
            master.end.day,
          )
              .difference(DateTime(
                master.start.year,
                master.start.month,
                master.start.day,
              ))
              .inDays;
          final newDate = exception.newDate!;
          final newEnd = DateTime(
            newDate.year,
            newDate.month,
            newDate.day + daySpan,
            newDate.hour + (master.end.hour - master.start.hour),
            newDate.minute + (master.end.minute - master.start.minute),
            newDate.second + (master.end.second - master.start.second),
            newDate.millisecond +
                (master.end.millisecond - master.start.millisecond),
            newDate.microsecond +
                (master.end.microsecond - master.start.microsecond),
          );
          cached[idx] = master.copyWith(
            id: '${seriesId}_$dateKeyIso',
            start: newDate,
            end: newEnd,
            occurrenceId: dateKeyIso,
          );
        }
        break;
      case MCalExceptionType.modified:
        final idx = cached.indexWhere((e) => e.occurrenceId == dateKeyIso);
        if (idx >= 0) {
          cached[idx] = exception.modifiedEvent!.copyWith(
            occurrenceId: dateKeyIso,
          );
        }
        break;
    }
  }

  /// Invalidates the expansion cache for a series when an exception is removed.
  ///
  /// Uses the simplest correct approach: removes the series from
  /// [_expandedBySeriesId] so it will be re-expanded on the next query.
  void _patchCacheForExceptionRemoval(
    String seriesId,
    MCalRecurrenceException exception,
  ) {
    _expandedBySeriesId.remove(seriesId);
  }

  /// Computes the [DateTimeRange] affected by the given [exception].
  ///
  /// Returns a range covering the affected dates:
  /// - **deleted**: covers just the original date
  /// - **rescheduled**: covers the original date through the new date (or vice
  ///   versa if the new date is earlier)
  /// - **modified**: covers just the original date (the modified event may
  ///   have different dates, but the original occurrence date is the anchor)
  DateTimeRange _computeAffectedRange(MCalRecurrenceException exception) {
    final originalDay = _normalizeDate(exception.originalDate);

    switch (exception.type) {
      case MCalExceptionType.deleted:
      case MCalExceptionType.modified:
        // Use calendar-day arithmetic (not Duration) to avoid DST issues.
        // Duration(days: 1) = 24h can land on the same day at 23:00 on
        // DST fall-back (e.g. Nov 2, 2025 US).
        return DateTimeRange(
          start: originalDay,
          end: DateTime(originalDay.year, originalDay.month, originalDay.day + 1),
        );
      case MCalExceptionType.rescheduled:
        final newDay = _normalizeDate(exception.newDate!);
        final start = originalDay.isBefore(newDay) ? originalDay : newDay;
        final end = originalDay.isBefore(newDay) ? newDay : originalDay;
        return DateTimeRange(
          start: start,
          end: DateTime(end.year, end.month, end.day + 1),
        );
    }
  }

  // ============================================================
  // Task 9: Exception CRUD Methods
  // ============================================================

  /// Adds a recurrence exception for a series.
  ///
  /// Stores the [exception] keyed by its normalized original date. For the
  /// **first** exception on a given date, the expansion cache is patched
  /// in O(1). If an exception for the same original date already exists
  /// (an overwrite — e.g., changing a deletion to a reschedule), the entire
  /// series cache is invalidated to ensure correctness.
  ///
  /// Sets [lastChange] with type [MCalChangeType.exceptionAdded] and calls
  /// [notifyListeners].
  ///
  /// Returns the [exception] that was added, enabling callers to persist it
  /// to their backend.
  ///
  /// See also: [removeException], [modifyOccurrence], [addExceptions].
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Delete a single occurrence
  /// controller.addException(
  ///   'weekly-meeting',
  ///   MCalRecurrenceException.deleted(originalDate: DateTime(2024, 6, 10)),
  /// );
  ///
  /// // Reschedule an occurrence
  /// controller.addException(
  ///   'weekly-meeting',
  ///   MCalRecurrenceException.rescheduled(
  ///     originalDate: DateTime(2024, 6, 17),
  ///     newDate: DateTime(2024, 6, 18),
  ///   ),
  /// );
  /// ```
  MCalRecurrenceException addException(
    String seriesId,
    MCalRecurrenceException exception,
  ) {
    _exceptionsBySeriesId.putIfAbsent(seriesId, () => {});
    final dateKey = _normalizeDate(exception.originalDate);
    final isOverwrite = _exceptionsBySeriesId[seriesId]!.containsKey(dateKey);
    _exceptionsBySeriesId[seriesId]![dateKey] = exception;

    if (isOverwrite) {
      // When overwriting an existing exception, the previous O(1) cache
      // patch may have already modified the cached list (e.g. a deleted
      // exception removed the entry). A second patch for the new type
      // can't reliably find or restore the entry, so invalidate the
      // series cache to force a clean re-expansion on the next query.
      _expandedBySeriesId.remove(seriesId);
    } else {
      // First exception for this date — O(1) cache patch is safe.
      _patchCacheForException(seriesId, exception);
    }

    _lastChange = MCalEventChangeInfo(
      type: MCalChangeType.exceptionAdded,
      affectedEventIds: {seriesId},
      affectedDateRange: _computeAffectedRange(exception),
    );
    notifyListeners();
    return exception;
  }

  /// Adds multiple recurrence exceptions for a series in batch.
  ///
  /// Stores all [exceptions] in [_exceptionsBySeriesId], then invalidates
  /// the series expansion cache (batch re-expansion is cheaper than N
  /// individual patches). Sets [_lastChange] with type
  /// [MCalChangeType.bulkChange] and notifies listeners.
  ///
  /// Parameters:
  /// - [seriesId]: The ID of the recurring event master
  /// - [exceptions]: The list of exceptions to add
  void addExceptions(
    String seriesId,
    List<MCalRecurrenceException> exceptions,
  ) {
    _exceptionsBySeriesId.putIfAbsent(seriesId, () => {});
    for (final ex in exceptions) {
      _exceptionsBySeriesId[seriesId]![_normalizeDate(ex.originalDate)] = ex;
    }
    // Invalidate series cache (batch = re-expand is more efficient than N patches)
    _expandedBySeriesId.remove(seriesId);
    _lastChange = MCalEventChangeInfo(
      type: MCalChangeType.bulkChange,
      affectedEventIds: {seriesId},
    );
    notifyListeners();
  }

  /// Removes a recurrence exception for a series by its original date.
  ///
  /// Removes the exception keyed by `_normalizeDate(originalDate)` from
  /// [_exceptionsBySeriesId]. If found, invalidates the series expansion
  /// cache via [_patchCacheForExceptionRemoval], sets [_lastChange] with
  /// type [MCalChangeType.exceptionRemoved], and notifies listeners.
  ///
  /// Returns the removed [MCalRecurrenceException], or `null` if no
  /// exception was found for the given [originalDate].
  ///
  /// Parameters:
  /// - [seriesId]: The ID of the recurring event master
  /// - [originalDate]: The original occurrence date of the exception to remove
  MCalRecurrenceException? removeException(
    String seriesId,
    DateTime originalDate,
  ) {
    final dateKey = _normalizeDate(originalDate);
    final removed = _exceptionsBySeriesId[seriesId]?.remove(dateKey);
    if (removed != null) {
      _patchCacheForExceptionRemoval(seriesId, removed);
      _lastChange = MCalEventChangeInfo(
        type: MCalChangeType.exceptionRemoved,
        affectedEventIds: {seriesId},
        affectedDateRange: _computeAffectedRange(removed),
      );
      notifyListeners();
    }
    return removed;
  }

  /// Returns all recurrence exceptions for a series.
  ///
  /// Returns an empty list if no exceptions exist for the given [seriesId].
  /// This is a read-only operation with no side effects.
  ///
  /// Parameters:
  /// - [seriesId]: The ID of the recurring event master
  List<MCalRecurrenceException> getExceptions(String seriesId) {
    return _exceptionsBySeriesId[seriesId]?.values.toList() ?? [];
  }

  /// Convenience method that creates a modified exception and adds it.
  ///
  /// Creates an [MCalRecurrenceException.modified] for the given
  /// [originalDate] with [modifiedEvent] and delegates to [addException].
  ///
  /// Returns the created [MCalRecurrenceException].
  ///
  /// Parameters:
  /// - [seriesId]: The ID of the recurring event master
  /// - [originalDate]: The original occurrence date to modify
  /// - [modifiedEvent]: The replacement event for this occurrence
  MCalRecurrenceException modifyOccurrence(
    String seriesId,
    DateTime originalDate,
    MCalCalendarEvent modifiedEvent,
  ) {
    return addException(
      seriesId,
      MCalRecurrenceException.modified(
        originalDate: originalDate,
        modifiedEvent: modifiedEvent,
      ),
    );
  }

  // ============================================================
  // Task 10: Series Management Methods
  // ============================================================

  /// Replaces a recurring master event and invalidates its expansion cache.
  ///
  /// Updates the master event in the cache and forces re-expansion on the
  /// next [getEventsForRange] call. Existing exceptions for the series are
  /// preserved — they continue to apply to the updated rule.
  ///
  /// Sets [lastChange] with type [MCalChangeType.eventUpdated] and calls
  /// [notifyListeners].
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Change a weekly meeting to bi-weekly
  /// final master = controller.getEventById('weekly-meeting')!;
  /// controller.updateRecurringEvent(master.copyWith(
  ///   recurrenceRule: MCalRecurrenceRule(
  ///     frequency: MCalFrequency.weekly,
  ///     interval: 2,
  ///   ),
  /// ));
  /// ```
  void updateRecurringEvent(MCalCalendarEvent event) {
    _eventsById[event.id] = event;
    _expandedBySeriesId.remove(event.id);
    _lastChange = MCalEventChangeInfo(
      type: MCalChangeType.eventUpdated,
      affectedEventIds: {event.id},
    );
    notifyListeners();
  }

  /// Removes a recurring master event and all associated data.
  ///
  /// Removes the event from [_eventsById], its exceptions from
  /// [_exceptionsBySeriesId], and its expansion cache from
  /// [_expandedBySeriesId]. Sets [_lastChange] with type
  /// [MCalChangeType.eventRemoved] and notifies listeners.
  ///
  /// Parameters:
  /// - [eventId]: The ID of the recurring master event to delete
  void deleteRecurringEvent(String eventId) {
    _eventsById.remove(eventId);
    _exceptionsBySeriesId.remove(eventId);
    _expandedBySeriesId.remove(eventId);
    _lastChange = MCalEventChangeInfo(
      type: MCalChangeType.eventRemoved,
      affectedEventIds: {eventId},
    );
    notifyListeners();
  }

  /// Splits a recurring series into two at [fromDate].
  ///
  /// This is the "this and following events" operation in calendar UIs.
  /// Uses calendar-day arithmetic (not [Duration]) for DST safety.
  ///
  /// 1. **Truncates** the original master by setting its recurrence rule's
  ///    `until` to the day before [fromDate] (clearing any `count`).
  /// 2. **Creates a new master** starting at [fromDate] with the same
  ///    recurrence pattern as the original (before truncation), preserving
  ///    the original event's time-of-day and duration.
  /// 3. **Moves exceptions** whose `originalDate` is on or after [fromDate]
  ///    from the original series to the new series.
  /// 4. **Invalidates** expansion caches for both series.
  /// 5. Sets [_lastChange] with type [MCalChangeType.seriesSplit] and
  ///    notifies listeners.
  ///
  /// Throws [StateError] if no event with [seriesId] exists.
  /// Throws [ArgumentError] if the event is not recurring.
  ///
  /// Returns the new master event's ID.
  ///
  /// Parameters:
  /// - [seriesId]: The ID of the recurring master event to split
  /// - [fromDate]: The date at which to split the series
  String splitSeries(String seriesId, DateTime fromDate) {
    final master = _eventsById[seriesId];
    if (master == null) {
      throw StateError('No event found with id "$seriesId".');
    }
    if (master.recurrenceRule == null) {
      throw ArgumentError('Event "$seriesId" is not a recurring event.');
    }

    // 1. Truncate original series to end before fromDate
    // Use calendar-day arithmetic (not Duration) to avoid DST issues.
    final dayBefore = DateTime(fromDate.year, fromDate.month, fromDate.day - 1);
    final truncatedRule = master.recurrenceRule!.copyWith(
      until: () => dayBefore,
      count: () => null, // clear count, use until instead
    );
    _eventsById[seriesId] = master.copyWith(recurrenceRule: truncatedRule);

    // 2. Create new master starting at fromDate
    final newId = '${seriesId}_split_${fromDate.toIso8601String()}';
    final daySpan = DateTime(
      master.end.year,
      master.end.month,
      master.end.day,
    )
        .difference(DateTime(
          master.start.year,
          master.start.month,
          master.start.day,
        ))
        .inDays;
    final newStart = DateTime(
      fromDate.year,
      fromDate.month,
      fromDate.day,
      master.start.hour,
      master.start.minute,
      master.start.second,
      master.start.millisecond,
    );
    // DST-safe end: preserve master.end's time with calendar-day offset.
    final newEnd = DateTime(
      newStart.year,
      newStart.month,
      newStart.day + daySpan,
      master.end.hour,
      master.end.minute,
      master.end.second,
      master.end.millisecond,
      master.end.microsecond,
    );
    final newMaster = master.copyWith(
      id: newId,
      start: newStart,
      end: newEnd,
      recurrenceRule: master.recurrenceRule, // original pattern (no truncation)
    );
    _eventsById[newId] = newMaster;

    // 3. Move exceptions on or after fromDate to new series
    final originalExceptions = _exceptionsBySeriesId[seriesId];
    if (originalExceptions != null) {
      final toMove = <DateTime, MCalRecurrenceException>{};
      originalExceptions.removeWhere((date, ex) {
        if (!date.isBefore(fromDate)) {
          toMove[date] = ex;
          return true;
        }
        return false;
      });
      if (toMove.isNotEmpty) {
        _exceptionsBySeriesId[newId] = toMove;
      }
    }

    // 4. Invalidate caches for both series
    _expandedBySeriesId.remove(seriesId);
    _expandedBySeriesId.remove(newId);

    _lastChange = MCalEventChangeInfo(
      type: MCalChangeType.seriesSplit,
      affectedEventIds: {seriesId, newId},
    );
    notifyListeners();
    return newId;
  }
}
