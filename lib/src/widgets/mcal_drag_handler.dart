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
  // Resize State Fields (mutually exclusive with drag state)
  // ============================================================

  /// Whether a resize operation is currently in progress.
  bool _isResizing = false;

  /// The event currently being resized.
  MCalCalendarEvent? _resizingEvent;

  /// Which edge of the event is being resized.
  MCalResizeEdge? _resizeEdge;

  /// The original start date of the event before resizing began.
  DateTime? _resizeOriginalStart;

  /// The original end date of the event before resizing began.
  DateTime? _resizeOriginalEnd;

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

  /// Whether the pointer is currently in the edge zone.
  ///
  /// Set to `true` by [handleEdgeProximity] when [nearEdge] is true, and
  /// reset to `false` when the pointer leaves the edge OR after the timer
  /// fires and navigates.  After navigation the old page's proximity state
  /// is stale — resetting forces the next [handleEdgeProximity] call (from
  /// the new page's onMove) to re-evaluate before scheduling another timer.
  bool _isNearEdge = false;

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
  // Resize Getters
  // ============================================================

  /// Whether a resize operation is currently in progress.
  bool get isResizing => _isResizing;

  /// Debug-only accessors for logging from external widgets.
  bool get debugIsNearEdge => _isNearEdge;
  bool get debugEdgeTimerActive => _edgeNavigationTimer != null;

  /// The event currently being resized, or null if not resizing.
  MCalCalendarEvent? get resizingEvent => _resizingEvent;

  /// The edge being resized (start or end), or null if not resizing.
  MCalResizeEdge? get resizeEdge => _resizeEdge;

  /// The original start date of the event before resizing began, or null.
  DateTime? get resizeOriginalStart => _resizeOriginalStart;

  /// The original end date of the event before resizing began, or null.
  DateTime? get resizeOriginalEnd => _resizeOriginalEnd;

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
    // If a resize is in progress (e.g. a LongPressDraggable fired its
    // delayed recognizer while a resize was active), cancel it first
    // so the drag can proceed cleanly.
    if (_isResizing) {
      cancelResize();
    }

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
  /// When [preserveTime] is true (day view), stores full DateTime with time.
  /// When false (month view), normalizes to date-only for cell highlighting.
  void updateProposedDropRange({
    required DateTime proposedStart,
    required DateTime proposedEnd,
    required bool isValid,
    bool preserveTime = false,
  }) {
    // NOTE: We removed the `if (!isDragging) return;` guard here because
    // onWillAcceptWithDetails can fire before onDragStarted completes,
    // causing the proposed range to not be updated and showing red indicators.
    // If this method is called, there IS a drag happening.

    final DateTime normalizedStart;
    final DateTime normalizedEnd;
    if (preserveTime) {
      // Day view: preserve full time for timed events
      normalizedStart = proposedStart;
      normalizedEnd = proposedEnd;
    } else {
      // Month view: normalize to date-only for cell highlighting
      normalizedStart = DateTime(
        proposedStart.year,
        proposedStart.month,
        proposedStart.day,
      );
      normalizedEnd = DateTime(
        proposedEnd.year,
        proposedEnd.month,
        proposedEnd.day,
      );
    }

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

  /// Clears the proposed drop range (highlighted cells, proposed dates, validity).
  ///
  /// Called when the drag leaves the calendar grid, is cancelled, or when the
  /// displayed month changes during drag (e.g. edge navigation). In the latter
  /// case, the user must move the pointer to re-trigger [handleDragMove] and
  /// re-show the drop target for the new month.
  void clearProposedDropRange() {
    final hadState =
        _highlightedCells.isNotEmpty ||
        _proposedStartDate != null ||
        _proposedEndDate != null ||
        _isProposedDropValid;
    if (!hadState) return;

    _highlightedCells = [];
    _proposedStartDate = null;
    _proposedEndDate = null;
    _isProposedDropValid = false;
    _previousStartCellIndex = null;
    _previousWeekRowIndex = null;
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
    debugPrint('[DD] cancelDrag() called — isDragging=$isDragging edgeTimerActive=${_edgeNavigationTimer != null}');
    _reset();
  }

  /// Resets all drag state to initial values.
  ///
  /// Clears highlighted cells, proposed drop range, edge navigation timer,
  /// and all drag-related fields so drop indicators never persist after
  /// the drag completes or is cancelled. Called by [completeDrag] and [cancelDrag].
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
  /// the specified [delay]. If the user moves away from the edge before
  /// the timer fires, navigation is cancelled.
  ///
  /// **Self-repeating navigation:** The first time the pointer enters the
  /// edge zone a timer is started with the configured [delay]. When it
  /// fires, it navigates and then — if the pointer is still in the edge
  /// zone — automatically schedules the next navigation after
  /// [_edgeRepeatDelay]. This allows the user to hold the pointer at the
  /// edge and watch months scroll by without needing to wiggle.
  ///
  /// Moving away from the edge cancels any pending timer and resets all
  /// repeat state so the next edge hover starts fresh.
  ///
  /// Parameters:
  /// - [nearEdge]: Whether the drag position is near an edge
  /// - [isLeftEdge]: True for left edge (previous month), false for right
  /// - [navigateCallback]: Callback to invoke for navigation
  /// - [delay]: Optional custom delay before the *first* navigation triggers
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
    // Works for both drag-to-move and resize operations
    if (!isDragging && !isResizing) {
      _cancelEdgeNavigationTimer();
      return;
    }

    if (nearEdge) {
      _isNearEdge = true;

      // Start the initial timer if none is pending.  Each timer fire resets
      // _isNearEdge → false, so a new timer will only start once the next
      // handleEdgeProximity(true, ...) call confirms the cursor is still
      // near the edge on the (possibly new) page.
      if (_edgeNavigationTimer == null) {
        debugPrint('[DD] EdgeProx: nearEdge=true, no timer pending — starting new timer at=${DateTime.now().toIso8601String()} isLeft=$isLeftEdge');
        _startEdgeTimer(
          delay ?? const Duration(milliseconds: defaultEdgeNavigationDelayMs),
          navigateCallback,
        );
      }
    } else {
      // Left the edge zone — cancel everything so next entry starts fresh.
      _isNearEdge = false;
      _cancelEdgeNavigationTimer();
    }
  }

  /// Starts (or restarts) the edge navigation timer with the given [delay].
  ///
  /// When the timer fires it navigates, then self-schedules the next
  /// navigation after [_edgeRepeatDelay] if the pointer is still near
  /// the edge.
  void _startEdgeTimer(Duration delay, VoidCallback navigateCallback) {
    _edgeNavigationTimer?.cancel();
    final scheduledAt = DateTime.now();
    debugPrint('[DD] EdgeTimer: scheduled delay=${delay.inMilliseconds}ms at=${scheduledAt.toIso8601String()} isDragging=$isDragging isResizing=$isResizing');
    _edgeNavigationTimer = Timer(delay, () {
      _edgeNavigationTimer = null;
      final firedAt = DateTime.now();
      final elapsed = firedAt.difference(scheduledAt).inMilliseconds;
      debugPrint('[DD] EdgeTimer FIRED: at=${firedAt.toIso8601String()} elapsed=${elapsed}ms isDragging=$isDragging isResizing=$isResizing _isNearEdge=$_isNearEdge');
      if (!(isDragging || isResizing)) {
        debugPrint('[DD] EdgeTimer FIRED: guard triggered — NOT navigating (drag/resize not active)');
        return;
      }

      debugPrint('[DD] EdgeTimer FIRED: calling navigateCallback at=${DateTime.now().toIso8601String()}');
      navigateCallback();

      // Reset _isNearEdge after navigating.  The page just changed, so the
      // old proximity measurement is stale.  Do NOT auto-reschedule based
      // on it — the next onMove / handleEdgeProximity call on the new page
      // will re-establish _isNearEdge if the cursor is still near the edge.
      // Without this reset, a Day View page change (where _processDragMove
      // may bail out before reaching the edge check) leaves _isNearEdge
      // stuck true and the timer reschedules forever.
      _isNearEdge = false;
      debugPrint('[DD] EdgeTimer: _isNearEdge reset to false after navigate at=${DateTime.now().toIso8601String()}');
    });
  }

  /// Cancels the edge navigation timer and resets all edge-repeat state.
  void _cancelEdgeNavigationTimer() {
    if (_edgeNavigationTimer != null) {
      debugPrint('[DD] EdgeTimer: CANCELLED at=${DateTime.now().toIso8601String()} _isNearEdge=$_isNearEdge isDragging=$isDragging');
    }
    _edgeNavigationTimer?.cancel();
    _edgeNavigationTimer = null;
    _isNearEdge = false;
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
    debugPrint('[DD] cancelEdgeNavigation() called — edgeTimerActive=${_edgeNavigationTimer != null} isDragging=$isDragging');
    _cancelEdgeNavigationTimer();
  }

  // ============================================================
  // Resize Lifecycle Methods
  // ============================================================

  /// Begins a resize operation for the given [event] on the specified [edge].
  ///
  /// This sets the resize state and stores the original dates so they can
  /// be restored on cancel. Resize and drag are mutually exclusive.
  ///
  /// **Does not call [notifyListeners]**. The first visual update happens
  /// when [updateResize] is called (which does notify). This is critical
  /// for pointer-based resize: `startResize` is called inside the
  /// `onHorizontalDragStart` callback of the resize handle's
  /// [GestureDetector]. A synchronous rebuild at that point would alter
  /// the widget tree (feedback layers appear), causing Flutter's gesture
  /// system to lose the active pointer and cancel the drag.
  void startResize(MCalCalendarEvent event, MCalResizeEdge edge) {
    assert(!isDragging, 'Cannot start resize while dragging');
    _isResizing = true;
    _resizingEvent = event;
    _resizeEdge = edge;
    _resizeOriginalStart = event.start;
    _resizeOriginalEnd = event.end;
    // Intentionally no notifyListeners() — see doc comment above.
  }

  /// Updates the proposed range during a resize operation.
  ///
  /// Reuses the shared [proposedStartDate], [proposedEndDate],
  /// [isProposedDropValid], and [highlightedCells] fields.
  void updateResize({
    required DateTime proposedStart,
    required DateTime proposedEnd,
    required bool isValid,
    required List<MCalHighlightCellInfo> cells,
  }) {
    assert(_isResizing, 'Cannot update resize when not resizing');
    _proposedStartDate = proposedStart;
    _proposedEndDate = proposedEnd;
    _isProposedDropValid = isValid;
    _highlightedCells = cells;
    notifyListeners();
  }

  /// Completes the resize operation.
  ///
  /// Returns the proposed (start, end) dates if the resize is valid,
  /// or null if the resize state is invalid.
  /// Clears all resize state after completion.
  (DateTime, DateTime)? completeResize() {
    if (!_isResizing || !_isProposedDropValid) {
      cancelResize();
      return null;
    }
    final result = (_proposedStartDate!, _proposedEndDate!);
    _clearResizeState();
    notifyListeners();
    return result;
  }

  /// Cancels the current resize operation and clears all resize state.
  void cancelResize() {
    _clearResizeState();
    notifyListeners();
  }

  /// Clears all resize-specific state and the shared proposed drop range fields.
  void _clearResizeState() {
    _isResizing = false;
    _resizingEvent = null;
    _resizeEdge = null;
    _resizeOriginalStart = null;
    _resizeOriginalEnd = null;
    _proposedStartDate = null;
    _proposedEndDate = null;
    _isProposedDropValid = false;
    _highlightedCells = [];
    // Cancel any pending edge navigation from resize
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

    // Calculate proposed date range using calendar-day arithmetic (not Duration)
    // to avoid DST bugs: on Nov 2 when DST ends, Duration(days: 1) = 24h lands
    // on Nov 2 23:00 instead of Nov 3.
    final baseDate = _pendingWeekDates.isNotEmpty
        ? _pendingWeekDates[0]
        : DateTime.now();
    final proposedStartDate = addDays(baseDate, dropStartCellIndex);
    final proposedEndDate = addDays(proposedStartDate, _cachedEventDurationDays - 1);

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
  ///
  /// Assigns a new list to [_highlightedCells] on each call to avoid reference
  /// equality issues for listeners that compare the list instance.
  void _buildHighlightedCells({
    required int dropStartCellIndex,
    required int eventDurationDays,
    required int weekRowIndex,
    required int totalWeekRows,
    required Rect Function(int) getWeekRowBounds,
    required List<DateTime> Function(int) getWeekDates,
  }) {
    final newList = <MCalHighlightCellInfo>[];

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

          newList.add(
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

    _highlightedCells = newList;
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
