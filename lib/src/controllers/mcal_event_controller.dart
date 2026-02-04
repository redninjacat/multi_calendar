import 'package:flutter/material.dart';
import '../models/mcal_calendar_event.dart';

/// Controller for managing calendar events and view state.
///
/// This controller manages calendar events with efficient caching and retrieval.
/// It extends [ChangeNotifier] to support reactive state management, allowing
/// widgets to rebuild when events are loaded or the visible range changes.
///
/// The controller supports:
/// - Loading events for date ranges (override [loadEvents] for custom loading)
/// - Caching events in memory for efficient retrieval
/// - Querying events by date range
/// - Managing the visible date range for view synchronization
///
/// Example:
/// ```dart
/// final controller = MCalEventController();
///
/// // Add events directly
/// controller.addEvents([
///   MCalCalendarEvent(
///     id: '1',
///     title: 'Meeting',
///     start: DateTime(2024, 6, 15, 10, 0),
///     end: DateTime(2024, 6, 15, 11, 0),
///   ),
/// ]);
///
/// // Get events for a specific date range
/// final events = controller.getEventsForRange(
///   DateTimeRange(
///     start: DateTime(2024, 6, 1),
///     end: DateTime(2024, 6, 30),
///   ),
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

  /// Creates a new [MCalEventController] instance.
  ///
  /// [initialDate] sets the initially displayed date. Defaults to today if not provided.
  /// The view will display the month containing this date.
  MCalEventController({DateTime? initialDate})
    : _displayDate = initialDate ?? DateTime.now();

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
  /// Events are indexed by their ID for efficient lookup. If an event with
  /// the same ID already exists, it will be replaced.
  ///
  /// Notifies listeners after adding events.
  ///
  /// Parameters:
  /// - [events]: The list of events to add
  void addEvents(List<MCalCalendarEvent> events) {
    for (final event in events) {
      _eventsById[event.id] = event;
    }
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
    notifyListeners();
  }

  /// Clears all events from the controller's cache.
  ///
  /// Notifies listeners after clearing events.
  void clearEvents() {
    _eventsById.clear();
    notifyListeners();
  }

  /// Gets all cached events.
  ///
  /// Returns an unmodifiable list of all events in the cache.
  List<MCalCalendarEvent> get allEvents =>
      List.unmodifiable(_eventsById.values);

  /// Gets events that fall within the specified date range.
  ///
  /// An event is included if it overlaps with the specified range, meaning:
  /// - Event starts before range ends, AND
  /// - Event ends after range starts
  ///
  /// Parameters:
  /// - [range]: The date range to query
  ///
  /// Returns a list of events that overlap with the range.
  List<MCalCalendarEvent> getEventsForRange(DateTimeRange range) {
    return _eventsById.values.where((event) {
      // Event overlaps with range if it starts before range ends
      // and ends after range starts
      return event.start.isBefore(range.end) && event.end.isAfter(range.start);
    }).toList();
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
    final dayStart = DateTime(date.year, date.month, date.day);
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
}
