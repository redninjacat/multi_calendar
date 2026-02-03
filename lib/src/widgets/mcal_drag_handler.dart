import 'dart:async';
import 'dart:ui' show Offset;
import 'package:flutter/foundation.dart';
import '../models/mcal_calendar_event.dart';

/// A state manager for handling drag-and-drop operations on calendar events.
///
/// This class manages the complete lifecycle of drag-and-drop operations,
/// including tracking the dragged event, source and target dates, drag position,
/// and edge navigation for cross-month dragging.
///
/// [MCalDragHandler] extends [ChangeNotifier] to support reactive state
/// management, allowing widgets to rebuild when drag state changes.
///
/// Example:
/// ```dart
/// final dragHandler = MCalDragHandler();
///
/// // Start a drag operation
/// dragHandler.startDrag(event, DateTime(2024, 6, 15));
///
/// // Update during drag
/// dragHandler.updateDrag(DateTime(2024, 6, 18), true, Offset(100, 200));
///
/// // Complete the drag and get the target date
/// final targetDate = dragHandler.completeDrag();
/// if (targetDate != null) {
///   // Handle the drop
///   final dayDelta = dragHandler.calculateDayDelta();
/// }
///
/// // Or cancel the drag
/// dragHandler.cancelDrag();
/// ```
class MCalDragHandler extends ChangeNotifier {
  // ============================================================
  // Drag State Fields
  // ============================================================

  /// The event currently being dragged.
  MCalCalendarEvent? _draggedEvent;

  /// The original date where the drag started.
  DateTime? _sourceDate;

  /// The current target date under the cursor.
  DateTime? _targetDate;

  /// Whether the current target is valid for drop.
  bool _isValidTarget = false;

  /// The current drag position.
  Offset? _dragPosition;

  // ============================================================
  // Edge Navigation State
  // ============================================================

  /// Timer for delayed edge navigation.
  ///
  /// When the user drags near the left or right edge of the calendar,
  /// this timer triggers navigation to the previous or next month after
  /// the configured delay.
  Timer? _edgeNavigationTimer;

  /// Default delay before edge navigation triggers (in milliseconds).
  static const int defaultEdgeNavigationDelayMs = 500;

  // ============================================================
  // Getters
  // ============================================================

  /// The event currently being dragged, or null if no drag is active.
  MCalCalendarEvent? get draggedEvent => _draggedEvent;

  /// The original date where the drag started, or null if no drag is active.
  DateTime? get sourceDate => _sourceDate;

  /// The current target date under the cursor, or null if not set.
  DateTime? get targetDate => _targetDate;

  /// Whether the current target is valid for drop.
  ///
  /// Returns false if there is no active drag operation.
  bool get isValidTarget => _isValidTarget;

  /// The current drag position, or null if not set.
  Offset? get dragPosition => _dragPosition;

  /// Whether a drag operation is currently active.
  ///
  /// Returns true if [draggedEvent] is not null.
  bool get isDragging => _draggedEvent != null;

  // ============================================================
  // Drag Lifecycle Methods
  // ============================================================

  /// Begins a drag operation with the specified event and source date.
  ///
  /// This sets up the initial drag state and notifies listeners.
  /// Any existing drag operation is implicitly cancelled.
  ///
  /// Parameters:
  /// - [event]: The calendar event being dragged
  /// - [sourceDate]: The date where the drag originated
  ///
  /// Example:
  /// ```dart
  /// dragHandler.startDrag(
  ///   event,
  ///   DateTime(2024, 6, 15),
  /// );
  /// ```
  void startDrag(MCalCalendarEvent event, DateTime sourceDate) {
    // Cancel any existing edge navigation timer
    _cancelEdgeNavigationTimer();

    _draggedEvent = event;
    _sourceDate = sourceDate;
    _targetDate = sourceDate;
    _isValidTarget = true;
    _dragPosition = null;

    notifyListeners();
  }

  /// Updates the current drag state with new target information.
  ///
  /// Call this method as the user drags over different cells to update
  /// the visual feedback and track the potential drop target.
  ///
  /// Parameters:
  /// - [targetDate]: The date currently under the cursor
  /// - [isValid]: Whether this target is valid for drop
  /// - [position]: The current drag position in local coordinates
  ///
  /// Example:
  /// ```dart
  /// dragHandler.updateDrag(
  ///   DateTime(2024, 6, 18),
  ///   true,
  ///   Offset(150, 200),
  /// );
  /// ```
  void updateDrag(DateTime targetDate, bool isValid, Offset position) {
    if (!isDragging) return;

    final changed = _targetDate != targetDate ||
        _isValidTarget != isValid ||
        _dragPosition != position;

    if (changed) {
      _targetDate = targetDate;
      _isValidTarget = isValid;
      _dragPosition = position;
      notifyListeners();
    }
  }

  /// Completes the drag operation and returns the target date.
  ///
  /// If the current target is valid, returns the target date.
  /// If the current target is invalid or no drag is active, returns null.
  /// The drag state is cleared after calling this method.
  ///
  /// Returns the target [DateTime] if the drop is valid, otherwise null.
  ///
  /// Example:
  /// ```dart
  /// final targetDate = dragHandler.completeDrag();
  /// if (targetDate != null) {
  ///   // Handle successful drop
  ///   print('Dropped on $targetDate');
  /// }
  /// ```
  DateTime? completeDrag() {
    if (!isDragging || !_isValidTarget) {
      _reset();
      return null;
    }

    final target = _targetDate;
    _reset();
    return target;
  }

  /// Cancels the drag operation without returning a target.
  ///
  /// Clears all drag state and notifies listeners. Use this when
  /// the user cancels the drag (e.g., by pressing Escape or dragging
  /// out of bounds).
  ///
  /// Example:
  /// ```dart
  /// // User pressed Escape
  /// dragHandler.cancelDrag();
  /// ```
  void cancelDrag() {
    _reset();
  }

  /// Resets all drag state to initial values.
  ///
  /// This is a private method called by [completeDrag] and [cancelDrag].
  void _reset() {
    _cancelEdgeNavigationTimer();

    final wasActive = isDragging;

    _draggedEvent = null;
    _sourceDate = null;
    _targetDate = null;
    _isValidTarget = false;
    _dragPosition = null;

    if (wasActive) {
      notifyListeners();
    }
  }

  // ============================================================
  // Edge Navigation
  // ============================================================

  /// Handles edge proximity during drag for cross-month navigation.
  ///
  /// When the user drags near the left or right edge of the calendar,
  /// this method starts a timer that will call [navigateCallback] after
  /// the specified [delay] (default 500ms). If the user moves away from
  /// the edge before the timer fires, navigation is cancelled.
  ///
  /// Parameters:
  /// - [nearEdge]: Whether the drag position is near an edge
  /// - [isLeftEdge]: True for left edge (previous month), false for right
  /// - [navigateCallback]: Callback to invoke for navigation
  /// - [delay]: Optional custom delay before navigation triggers
  ///
  /// Example:
  /// ```dart
  /// dragHandler.handleEdgeProximity(
  ///   true,
  ///   false, // right edge
  ///   () => controller.navigateToNextMonth(),
  ///   delay: Duration(milliseconds: 300),
  /// );
  /// ```
  void handleEdgeProximity(
    bool nearEdge,
    bool isLeftEdge,
    VoidCallback navigateCallback, {
    Duration? delay,
  }) {
    if (!isDragging) {
      _cancelEdgeNavigationTimer();
      return;
    }

    if (nearEdge) {
      // Start timer if not already running
      if (_edgeNavigationTimer == null || !_edgeNavigationTimer!.isActive) {
        final effectiveDelay = delay ?? 
            const Duration(milliseconds: defaultEdgeNavigationDelayMs);
        _edgeNavigationTimer = Timer(
          effectiveDelay,
          () {
            if (isDragging) {
              navigateCallback();
            }
          },
        );
      }
    } else {
      // Not near edge, cancel any pending navigation
      _cancelEdgeNavigationTimer();
    }
  }

  /// Cancels the edge navigation timer if it's active.
  void _cancelEdgeNavigationTimer() {
    _edgeNavigationTimer?.cancel();
    _edgeNavigationTimer = null;
  }

  // ============================================================
  // Delta Calculation
  // ============================================================

  /// Calculates the number of days between source and target dates.
  ///
  /// Returns the difference in days between [targetDate] and [sourceDate].
  /// A positive value means the event is being moved forward in time,
  /// a negative value means backward.
  ///
  /// Returns 0 if either date is null or no drag is active.
  ///
  /// This is useful for updating multi-day events, where both start and
  /// end dates need to be shifted by the same delta.
  ///
  /// Example:
  /// ```dart
  /// final delta = dragHandler.calculateDayDelta();
  /// if (delta != 0) {
  ///   final newStart = event.start.add(Duration(days: delta));
  ///   final newEnd = event.end.add(Duration(days: delta));
  ///   // Update event with new dates
  /// }
  /// ```
  int calculateDayDelta() {
    if (_sourceDate == null || _targetDate == null) {
      return 0;
    }

    // Normalize to date-only (remove time component) for accurate day calculation
    final sourceDay = DateTime(
      _sourceDate!.year,
      _sourceDate!.month,
      _sourceDate!.day,
    );
    final targetDay = DateTime(
      _targetDate!.year,
      _targetDate!.month,
      _targetDate!.day,
    );

    return targetDay.difference(sourceDay).inDays;
  }

  // ============================================================
  // Disposal
  // ============================================================

  /// Disposes of the drag handler and cleans up resources.
  ///
  /// Cancels any pending edge navigation timer before disposing.
  @override
  void dispose() {
    _cancelEdgeNavigationTimer();
    super.dispose();
  }
}
