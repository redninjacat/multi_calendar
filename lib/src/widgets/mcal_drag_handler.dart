import 'dart:async';
import 'dart:ui' show Offset, Rect;
import 'package:flutter/foundation.dart';
import '../models/mcal_calendar_event.dart';
import '../utils/date_utils.dart';
import 'mcal_callback_details.dart';

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
  // Proposed Drop Range (for multi-week highlighting)
  // ============================================================

  /// The proposed start date if the event were dropped at the current position.
  DateTime? _proposedStartDate;

  /// The proposed end date if the event were dropped at the current position.
  DateTime? _proposedEndDate;

  /// Whether the proposed drop is valid.
  bool _isProposedDropValid = false;

  /// List of cells to highlight during drag.
  List<MCalHighlightCellInfo> _highlightedCells = [];

  /// The list of cells that should be highlighted during the current drag.
  List<MCalHighlightCellInfo> get highlightedCells =>
      List.unmodifiable(_highlightedCells);

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
  // Debounce State (for unified drag target)
  // ============================================================

  /// Timer for debouncing onMove position updates (legacy, kept for cleanup).
  Timer? _debounceTimer;

  /// The latest position received from onMove (pending processing).
  Offset? _latestGlobalPosition;

  // ============================================================
  // Change Detection State
  // ============================================================

  /// Previous start cell index for change detection.
  int? _previousStartCellIndex;

  /// Previous week row index for change detection.
  int? _previousWeekRowIndex;

  /// Cached day width for position calculations.
  double _cachedDayWidth = 0;

  /// Cached grab offset X for position calculations.
  double _cachedGrabOffsetX = 0;

  /// Cached event duration in days.
  int _cachedEventDurationDays = 0;

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

  /// The proposed start date if the event were dropped at the current position.
  ///
  /// Used by week rows to determine which cells should be highlighted
  /// during a drag operation. Returns null if no drag is active or
  /// the proposed range hasn't been set.
  DateTime? get proposedStartDate => _proposedStartDate;

  /// The proposed end date if the event were dropped at the current position.
  ///
  /// Used by week rows to determine which cells should be highlighted
  /// during a drag operation. Returns null if no drag is active or
  /// the proposed range hasn't been set.
  DateTime? get proposedEndDate => _proposedEndDate;

  /// Whether the proposed drop position is valid.
  ///
  /// Used to determine the highlight color (valid = green, invalid = red).
  bool get isProposedDropValid => _isProposedDropValid;

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

    final changed =
        _targetDate != targetDate ||
        _isValidTarget != isValid ||
        _dragPosition != position;

    if (changed) {
      _targetDate = targetDate;
      _isValidTarget = isValid;
      _dragPosition = position;
      notifyListeners();
    }
  }

  /// Updates the proposed drop range for multi-week highlighting.
  ///
  /// Called by DragTarget widgets when drag data is received. This allows
  /// all week rows to check if any of their cells fall within the proposed
  /// date range and highlight accordingly.
  ///
  /// Parameters:
  /// - [proposedStart]: The date where the event would start if dropped
  /// - [proposedEnd]: The date where the event would end if dropped
  /// - [isValid]: Whether this drop position is valid
  ///
  /// Example:
  /// ```dart
  /// dragHandler.updateProposedDropRange(
  ///   proposedStart: DateTime(2024, 6, 15),
  ///   proposedEnd: DateTime(2024, 6, 21),
  ///   isValid: true,
  /// );
  /// ```
  void updateProposedDropRange({
    required DateTime proposedStart,
    required DateTime proposedEnd,
    required bool isValid,
  }) {
    // NOTE: We removed the `if (!isDragging) return;` guard here because
    // onWillAcceptWithDetails can fire before onDragStarted completes,
    // causing the proposed range to not be updated and showing red indicators.
    // If this method is called, there IS a drag happening.

    final normalizedStart = DateTime(
      proposedStart.year,
      proposedStart.month,
      proposedStart.day,
    );
    final normalizedEnd = DateTime(
      proposedEnd.year,
      proposedEnd.month,
      proposedEnd.day,
    );

    final changed =
        _proposedStartDate != normalizedStart ||
        _proposedEndDate != normalizedEnd ||
        _isProposedDropValid != isValid;

    if (changed) {
      _proposedStartDate = normalizedStart;
      _proposedEndDate = normalizedEnd;
      _isProposedDropValid = isValid;
      notifyListeners();
    }
  }

  /// Clears the proposed drop range.
  ///
  /// Called when the drag leaves the calendar grid or is cancelled.
  void clearProposedDropRange() {
    if (_proposedStartDate == null &&
        _proposedEndDate == null &&
        !_isProposedDropValid) {
      return; // Already cleared, no need to notify
    }

    _proposedStartDate = null;
    _proposedEndDate = null;
    _isProposedDropValid = false;
    notifyListeners();
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
    _cancelDebounceTimer();

    final wasActive = isDragging;

    _draggedEvent = null;
    _sourceDate = null;
    _targetDate = null;
    _isValidTarget = false;
    _dragPosition = null;
    _proposedStartDate = null;
    _proposedEndDate = null;
    _isProposedDropValid = false;
    _highlightedCells = [];
    _previousStartCellIndex = null;
    _previousWeekRowIndex = null;

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
        final effectiveDelay =
            delay ?? const Duration(milliseconds: defaultEdgeNavigationDelayMs);
        _edgeNavigationTimer = Timer(effectiveDelay, () {
          if (isDragging) {
            navigateCallback();
          }
        });
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

  /// Cancels the debounce timer if active.
  void _cancelDebounceTimer() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  /// Clears the highlighted cells list and resets change detection state.
  void clearHighlightedCells() {
    if (_highlightedCells.isNotEmpty) {
      _highlightedCells = [];
      // Reset change detection so re-entering triggers an update
      _previousStartCellIndex = null;
      _previousWeekRowIndex = null;
      notifyListeners();
    }
  }

  /// Cancels any pending edge navigation.
  ///
  /// Call this immediately when a drop is accepted to prevent the
  /// edge navigation timer from firing during drop processing.
  /// This is safe to call even if no timer is active.
  void cancelEdgeNavigation() {
    _cancelEdgeNavigationTimer();
  }

  // ============================================================
  // Unified Drag Move Handling
  // ============================================================

  // Pending context for processing
  int _pendingWeekRowIndex = 0;
  Rect _pendingWeekRowBounds = Rect.zero;
  List<DateTime> _pendingWeekDates = [];
  int _pendingTotalWeekRows = 0;
  Rect Function(int)? _pendingGetWeekRowBounds;
  List<DateTime> Function(int)? _pendingGetWeekDates;
  bool Function(DateTime, DateTime)? _pendingValidationCallback;

  /// Handles drag move events from the unified DragTarget.
  ///
  /// This method implements debounced position tracking. It stores the latest
  /// position and starts a debounce timer. When the timer fires, it processes
  /// the most recent position, calculates target cells, and updates state
  /// only if the target has changed.
  ///
  /// Parameters:
  /// - [globalPosition]: The global position of the pointer (feedback position + grabOffsetX)
  /// - [dayWidth]: Width of each day cell in pixels
  /// - [horizontalSpacing]: Horizontal margin around event tiles
  /// - [grabOffsetX]: Offset from tile left edge where drag started
  /// - [eventDurationDays]: Number of days the event spans
  /// - [weekRowIndex]: Index of the current week row being hovered
  /// - [weekRowBounds]: Bounds of the week row in global coordinates
  /// - [calendarBounds]: Bounds of the full calendar in global coordinates
  /// - [weekDates]: List of dates for each day in the current week row
  /// - [totalWeekRows]: Total number of week rows in the month
  /// - [getWeekRowBounds]: Function to get bounds for a specific week row index
  /// - [getWeekDates]: Function to get dates for a specific week row index
  /// - [validationCallback]: Optional callback to validate drop position
  void handleDragMove({
    required Offset globalPosition,
    required double dayWidth,
    required double grabOffsetX,
    required int eventDurationDays,
    required int weekRowIndex,
    required Rect weekRowBounds,
    required Rect calendarBounds,
    required List<DateTime> weekDates,
    required int totalWeekRows,
    required Rect Function(int) getWeekRowBounds,
    required List<DateTime> Function(int) getWeekDates,
    bool Function(DateTime proposedStart, DateTime proposedEnd)?
    validationCallback,
  }) {
    // Store latest position and calculation context
    _latestGlobalPosition = globalPosition;
    _cachedDayWidth = dayWidth;
    _cachedGrabOffsetX = grabOffsetX;
    _cachedEventDurationDays = eventDurationDays;

    // Store context for processing
    _pendingWeekRowIndex = weekRowIndex;
    _pendingWeekRowBounds = weekRowBounds;
    // Note: calendarBounds parameter kept for API compatibility but not stored
    _pendingWeekDates = weekDates;
    _pendingTotalWeekRows = totalWeekRows;
    _pendingGetWeekRowBounds = getWeekRowBounds;
    _pendingGetWeekDates = getWeekDates;
    _pendingValidationCallback = validationCallback;

    if (_latestGlobalPosition == null || !isDragging) {
      return;
    }
    if (_pendingGetWeekRowBounds == null || _pendingGetWeekDates == null) {
      return;
    }

    final globalPos = _latestGlobalPosition!;

    // Convert global position to local position within week row
    final localX = globalPos.dx - _pendingWeekRowBounds.left;

    // Calculate drop start cell using center-weighted logic:
    // The drop target is the cell containing >50% of the first day of the tile.
    // Adding dayWidth/2 shifts the calculation from left-edge to center of first day.
    // Note: grabOffsetX already includes horizontalSpacing from when drag started.
    final dropStartCellIndex =
        ((localX - _cachedGrabOffsetX + _cachedDayWidth / 2) / _cachedDayWidth)
            .floor();

    // Check if target has changed
    if (dropStartCellIndex == _previousStartCellIndex &&
        _pendingWeekRowIndex == _previousWeekRowIndex) {
      // No change, skip update
      return;
    }

    // Update previous state for next comparison
    _previousStartCellIndex = dropStartCellIndex;
    _previousWeekRowIndex = _pendingWeekRowIndex;

    // Calculate proposed date range
    final baseDate = _pendingWeekDates.isNotEmpty
        ? _pendingWeekDates[0]
        : DateTime.now();
    final proposedStartDate = baseDate.add(Duration(days: dropStartCellIndex));
    final proposedEndDate = proposedStartDate.add(
      Duration(days: _cachedEventDurationDays - 1),
    );

    // Validate if callback provided
    bool isValid = true;
    if (_pendingValidationCallback != null) {
      isValid = _pendingValidationCallback!(proposedStartDate, proposedEndDate);
    }

    // Build highlighted cells list
    _buildHighlightedCells(
      dropStartCellIndex: dropStartCellIndex,
      eventDurationDays: _cachedEventDurationDays,
      weekRowIndex: _pendingWeekRowIndex,
      totalWeekRows: _pendingTotalWeekRows,
      getWeekRowBounds: _pendingGetWeekRowBounds!,
      getWeekDates: _pendingGetWeekDates!,
    );

    // Update proposed drop range (reuse existing method)
    updateProposedDropRange(
      proposedStart: proposedStartDate,
      proposedEnd: proposedEndDate,
      isValid: isValid,
    );
  }

  /// Builds the list of highlighted cells spanning across week rows if needed.
  void _buildHighlightedCells({
    required int dropStartCellIndex,
    required int eventDurationDays,
    required int weekRowIndex,
    required int totalWeekRows,
    required Rect Function(int) getWeekRowBounds,
    required List<DateTime> Function(int) getWeekDates,
  }) {
    _highlightedCells = [];

    int remainingDays = eventDurationDays;
    int currentWeekRow = weekRowIndex;
    int currentCellIndex = dropStartCellIndex;
    int cellNumber = 0;

    while (remainingDays > 0 && currentWeekRow < totalWeekRows) {
      // Handle cells that start before the current week (negative index)
      if (currentCellIndex < 0) {
        // Move to previous week row
        currentWeekRow--;
        if (currentWeekRow < 0) {
          // Event starts before visible calendar, adjust
          currentCellIndex += 7;
          currentWeekRow = 0;
          continue;
        }
        currentCellIndex += 7;
        continue;
      }

      // Get bounds and dates for this week row
      final rowBounds = getWeekRowBounds(currentWeekRow);
      final rowDates = getWeekDates(currentWeekRow);

      // Add cells for this week row
      while (currentCellIndex <= 6 && remainingDays > 0) {
        if (currentCellIndex >= 0 && currentCellIndex < rowDates.length) {
          final cellLeft =
              rowBounds.left + (currentCellIndex * _cachedDayWidth);
          final cellBounds = Rect.fromLTWH(
            cellLeft,
            rowBounds.top,
            _cachedDayWidth,
            rowBounds.height,
          );

          _highlightedCells.add(
            MCalHighlightCellInfo(
              date: rowDates[currentCellIndex],
              cellIndex: currentCellIndex,
              weekRowIndex: currentWeekRow,
              bounds: cellBounds,
              isFirst: cellNumber == 0,
              isLast: remainingDays == 1,
            ),
          );
        }

        currentCellIndex++;
        remainingDays--;
        cellNumber++;
      }

      // Move to next week row
      currentWeekRow++;
      currentCellIndex = 0;
    }
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

    // Use DST-safe daysBetween for accurate day calculation
    return daysBetween(_sourceDate!, _targetDate!);
  }

  // ============================================================
  // Disposal
  // ============================================================

  /// Disposes of the drag handler and cleans up resources.
  ///
  /// Cancels any pending edge navigation and debounce timers before disposing.
  @override
  void dispose() {
    _cancelEdgeNavigationTimer();
    _cancelDebounceTimer();
    super.dispose();
  }
}
