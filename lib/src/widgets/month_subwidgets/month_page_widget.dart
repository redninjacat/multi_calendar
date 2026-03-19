import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../controllers/mcal_event_controller.dart';
import '../../models/mcal_calendar_event.dart';
import '../../models/mcal_recurrence_exception.dart';
import '../../models/mcal_recurrence_rule.dart';
import '../../styles/mcal_theme.dart';
import '../../utils/date_utils.dart';
import '../../utils/theme_cascade_utils.dart';
import '../../utils/mcal_date_format_utils.dart';
import '../../utils/mcal_l10n_helper.dart';
import '../mcal_callback_details.dart';
import '../mcal_drag_handler.dart';
import '../mcal_layout_directionality.dart';
import '../mcal_month_default_week_layout.dart';
import '../mcal_month_multi_day_renderer.dart';
import '../mcal_month_view.dart';
import '../mcal_month_view_contexts.dart';
import '../mcal_month_week_layout_contexts.dart';
import '../shared_subwidgets/month_resize_handle.dart';
import 'drop_target_highlight_painter.dart';
import 'week_row_widget.dart';

/// Returns recurrence metadata for an event — forward declaration.
/// This is passed from the main file via a function reference.
typedef GetRecurrenceMetadataFn =
    ({
      bool isRecurring,
      String? seriesId,
      MCalRecurrenceRule? recurrenceRule,
      MCalCalendarEvent? masterEvent,
      bool isException,
    })
    Function(MCalCalendarEvent event, MCalEventController controller);

/// Returns phantom event segments for the proposed drop range (Layer 3).
///
/// Creates a synthetic all-day event from [proposedStartDate] to [proposedEndDate],
/// then uses [MCalMultiDayRenderer.calculateAllEventSegments] to get one segment
/// per week row that the range intersects.
List<List<MCalMonthEventSegment>> _getPhantomSegmentsForDropTarget({
  required DateTime proposedStartDate,
  required DateTime proposedEndDate,
  required DateTime monthStart,
  required int firstDayOfWeek,
}) {
  final startDay = DateTime(
    proposedStartDate.year,
    proposedStartDate.month,
    proposedStartDate.day,
  );
  final endDay = DateTime(
    proposedEndDate.year,
    proposedEndDate.month,
    proposedEndDate.day,
  );
  final synthetic = MCalCalendarEvent(
    id: '__drop_target_phantom__',
    title: '',
    start: startDay,
    end: endDay,
    isAllDay: true,
  );
  return MCalMultiDayRenderer.calculateAllEventSegments(
    events: [synthetic],
    monthStart: monthStart,
    firstDayOfWeek: firstDayOfWeek,
  );
}

/// Creates a [MCalDateLabelBuilder] for Layer 3 that reserves the same space as
/// the default date label but draws nothing (SizedBox with [dateLabelHeight] and
/// [dayWidth] - 4 to match default layout).
MCalDateLabelBuilder _buildDropTargetDateLabelPlaceholder({
  required double dateLabelHeight,
  required double dayWidth,
}) {
  return (BuildContext context, MCalDateLabelContext labelContext) {
    return SizedBox(height: dateLabelHeight, width: dayWidth - 4);
  };
}

/// Widget for rendering a single month page in the PageView.
///
/// This widget is used by [MCalMonthView]'s PageView.builder to render
/// each month's grid. It calculates and displays the dates for the given month.
class MonthPageWidget extends StatefulWidget {
  /// The month to display (first day of month).
  final DateTime month;

  /// The current display month from the controller.
  /// Used to determine if dates are in the "current" month for styling.
  final DateTime currentDisplayMonth;

  /// Events loaded for the current display month.
  /// For adjacent months being previewed, events may not be loaded yet.
  final List<MCalCalendarEvent> events;

  /// The theme for styling.
  final MCalThemeData theme;

  /// The locale for formatting.
  final Locale locale;

  /// The controller for event management.
  final MCalEventController controller;

  /// Builder callbacks
  final Widget Function(BuildContext, MCalDayCellContext, Widget)?
  dayCellBuilder;
  final Widget Function(BuildContext, MCalEventTileContext, Widget)?
  eventTileBuilder;
  final Widget Function(BuildContext, MCalDateLabelContext, String)?
  dateLabelBuilder;
  final DateFormat? dateFormat;
  final bool Function(BuildContext, MCalCellInteractivityDetails)?
  cellInteractivityCallback;
  final void Function(BuildContext, MCalCellTapDetails)? onCellTap;
  final void Function(BuildContext, MCalCellTapDetails)? onCellLongPress;
  final void Function(BuildContext, MCalCellTapDetails)? onCellSecondaryTap;
  final void Function(BuildContext, MCalDateLabelTapDetails)? onDateLabelTap;
  final void Function(BuildContext, MCalDateLabelTapDetails)?
  onDateLabelLongPress;
  final void Function(BuildContext, MCalDateLabelTapDetails)?
  onDateLabelSecondaryTap;
  final void Function(BuildContext, MCalEventTapDetails)? onEventTap;
  final void Function(BuildContext, MCalEventTapDetails)? onEventLongPress;
  final void Function(BuildContext, MCalEventTapDetails)? onEventSecondaryTap;
  final void Function(BuildContext, MCalCellDoubleTapDetails)? onCellDoubleTap;
  final void Function(BuildContext, MCalEventDoubleTapDetails)?
  onEventDoubleTap;
  final void Function(BuildContext, MCalDayCellContext?)? onHoverCell;
  final void Function(BuildContext, MCalEventTileContext?)? onHoverEvent;
  final void Function(BuildContext, MCalDateLabelContext?)? onHoverDateLabel;
  final void Function(BuildContext, MCalOverflowTapDetails?)? onHoverOverflow;
  final int maxVisibleEventsPerDay;
  final void Function(BuildContext, MCalOverflowTapDetails)? onOverflowTap;
  final void Function(BuildContext, MCalOverflowTapDetails)?
  onOverflowLongPress;
  final void Function(BuildContext, MCalOverflowTapDetails)?
  onOverflowDoubleTap;
  final void Function(BuildContext, MCalOverflowTapDetails)?
  onOverflowSecondaryTap;
  final void Function(BuildContext, MCalDateLabelTapDetails)?
  onDateLabelDoubleTap;
  final bool showWeekNumbers;
  final Widget Function(BuildContext, MCalWeekNumberContext)? weekNumberBuilder;
  final bool autoFocusOnCellTap;

  /// Function to get events for a specific month.
  final List<MCalCalendarEvent> Function(DateTime month) getEventsForMonth;

  /// Builder callback for customizing week row event layout.
  final MCalWeekLayoutBuilder? weekLayoutBuilder;

  /// Builder callback for customizing overflow indicator rendering.
  final Widget Function(
    BuildContext,
    MCalMonthOverflowIndicatorContext,
    Widget,
  )?
  overflowIndicatorBuilder;

  // Drag-and-drop parameters
  final bool enableDragToMove;
  final bool showDropTargetTiles;
  final bool showDropTargetOverlay;
  final bool dropTargetTilesAboveOverlay;
  final Widget Function(BuildContext, MCalDraggedTileDetails, Widget)?
  draggedTileBuilder;
  final Widget Function(BuildContext, MCalDragSourceDetails, Widget)?
  dragSourceTileBuilder;
  final MCalEventTileBuilder? dropTargetTileBuilder;
  final Widget Function(BuildContext, MCalDropTargetCellDetails)?
  dropTargetCellBuilder;
  final Widget Function(BuildContext, MCalDropOverlayDetails)?
  dropTargetOverlayBuilder;
  final bool Function(BuildContext, MCalDragWillAcceptDetails)?
  onDragWillAccept;
  final bool Function(BuildContext, MCalEventDroppedDetails)? onEventDropped;
  final bool dragEdgeNavigationEnabled;
  final Duration dragEdgeNavigationDelay;
  final Duration dragLongPressDelay;
  final VoidCallback? onNavigateToPreviousMonth;
  final VoidCallback? onNavigateToNextMonth;

  // Drag lifecycle callbacks (Task 21)
  final void Function(MCalCalendarEvent event, DateTime sourceDate)?
  onDragStartedCallback;
  final void Function(bool wasAccepted)? onDragEndedCallback;
  final VoidCallback? onDragCanceledCallback;

  /// The drag handler for coordinating drag state across week rows.
  final MCalDragHandler? dragHandler;

  /// Whether event resize handles should be shown on multi-day event tiles.
  final bool enableDragToResize;

  /// Called during a resize operation to validate the proposed dates.
  final bool Function(BuildContext, MCalResizeWillAcceptDetails)?
  onResizeWillAccept;

  /// Called when an event resize operation completes.
  final bool Function(BuildContext, MCalEventResizedDetails)? onEventResized;

  /// Optional custom builder for the visual part of resize handles.
  final Widget Function(BuildContext, MCalResizeHandleContext)?
  resizeHandleBuilder;

  /// Optional callback returning horizontal inset for a resize handle.
  final double Function(MCalEventTileContext, MCalResizeEdge)?
  resizeHandleInset;

  /// Called when a resize handle pointer-down occurs.
  /// Delegates to the parent [_MCalMonthViewState] for tracking.
  final void Function(MCalCalendarEvent, MCalResizeEdge, int)?
  onResizePointerDownCallback;

  /// The event ID currently highlighted during keyboard event cycling.
  final String? keyboardHighlightedEventId;

  /// The event ID currently selected for keyboard move/resize.
  final String? keyboardSelectedEventId;

  /// The date whose overflow indicator is keyboard-focused in Event Mode.
  /// Null when the overflow indicator is not focused.
  final DateTime? keyboardOverflowFocusedDate;

  /// Shared map from [_MCalMonthViewState] for layout-computed visible counts.
  final Map<String, int>? layoutVisibleCounts;

  /// Optional custom builder for day region overlays.
  final Widget Function(BuildContext, MCalRegionContext, Widget)?
  dayRegionBuilder;

  /// Function to get recurrence metadata for an event.
  final GetRecurrenceMetadataFn getRecurrenceMetadata;

  const MonthPageWidget({
    super.key,
    required this.month,
    required this.currentDisplayMonth,
    required this.events,
    required this.theme,
    required this.locale,
    required this.controller,
    required this.getEventsForMonth,
    required this.getRecurrenceMetadata,
    this.dayCellBuilder,
    this.eventTileBuilder,
    this.dateLabelBuilder,
    this.dateFormat,
    this.cellInteractivityCallback,
    this.onCellTap,
    this.onCellLongPress,
    this.onCellSecondaryTap,
    this.onDateLabelTap,
    this.onDateLabelLongPress,
    this.onDateLabelSecondaryTap,
    this.onEventTap,
    this.onEventLongPress,
    this.onEventSecondaryTap,
    this.onCellDoubleTap,
    this.onEventDoubleTap,
    this.onHoverCell,
    this.onHoverEvent,
    this.onHoverDateLabel,
    this.onHoverOverflow,
    this.maxVisibleEventsPerDay = 5,
    this.onOverflowTap,
    this.onOverflowLongPress,
    this.onOverflowDoubleTap,
    this.onOverflowSecondaryTap,
    this.onDateLabelDoubleTap,
    this.showWeekNumbers = false,
    this.weekNumberBuilder,
    this.autoFocusOnCellTap = true,
    // Week layout customization
    this.weekLayoutBuilder,
    this.overflowIndicatorBuilder,
    // Drag-and-drop
    this.enableDragToMove = false,
    this.showDropTargetTiles = true,
    this.showDropTargetOverlay = true,
    this.dropTargetTilesAboveOverlay = false,
    this.draggedTileBuilder,
    this.dragSourceTileBuilder,
    this.dropTargetTileBuilder,
    this.dropTargetCellBuilder,
    this.dropTargetOverlayBuilder,
    this.onDragWillAccept,
    this.onEventDropped,
    this.dragEdgeNavigationEnabled = true,
    this.dragEdgeNavigationDelay = const Duration(milliseconds: 1200),
    this.dragLongPressDelay = const Duration(milliseconds: 200),
    this.onNavigateToPreviousMonth,
    this.onNavigateToNextMonth,
    // Drag lifecycle callbacks (Task 21)
    this.onDragStartedCallback,
    this.onDragEndedCallback,
    this.onDragCanceledCallback,
    this.dragHandler,
    // Resize
    this.enableDragToResize = false,
    this.onResizeWillAccept,
    this.onEventResized,
    this.resizeHandleBuilder,
    this.resizeHandleInset,
    this.onResizePointerDownCallback,
    // Keyboard selection state
    this.keyboardHighlightedEventId,
    this.keyboardSelectedEventId,
    this.keyboardOverflowFocusedDate,
    this.layoutVisibleCounts,
    // Day regions
    this.dayRegionBuilder,
  });

  @override
  State<MonthPageWidget> createState() => MonthPageWidgetState();
}

/// State class for [MonthPageWidget].
///
/// Handles the unified DragTarget for the entire month grid.
class MonthPageWidgetState extends State<MonthPageWidget> {
  /// Cached dates for this month.
  late List<DateTime> _dates;

  /// Cached weeks for this month.
  late List<List<DateTime>> _weeks;

  /// Number of weeks in this month.
  int get _weeksInMonth => _weeks.length;

  // ============================================================
  // Cached Layout Values (for drag performance)
  // ============================================================

  /// Cached day width (content area only, excludes week number column).
  double _cachedDayWidth = 0;

  /// Cached week row height - updated when layout changes.
  double _cachedWeekRowHeight = 0;

  /// Cached calendar size (full widget including week number column).
  Size _cachedCalendarSize = Size.zero;

  /// Cached calendar global offset - updated when layout changes.
  Offset _cachedCalendarOffset = Offset.zero;

  /// Cached week number column width (0 when week numbers hidden).
  double _cachedWeekNumberWidth = 0;

  /// Cached X offset from widget left to content area start.
  /// In LTR: equals week number width; in RTL: 0 (week numbers on right).
  double _cachedContentOffsetX = 0;

  /// Tracks the last resolved firstDayOfWeek used to compute dates.
  /// Because the controller is a mutable shared object, comparing
  /// oldWidget.controller.resolvedFirstDayOfWeek with the current value always
  /// yields the same result in didUpdateWidget. We track the last-seen value
  /// separately so we can detect a real change.
  late int _lastFirstDayOfWeek;

  /// Cached event duration for the current drag operation.
  int _cachedEventDuration = 1;

  /// Cached drag data for the current drag operation.
  MCalDragData? _cachedDragData;

  /// Latest drag details for debounced processing.
  DragTargetDetails<MCalDragData>? _latestDragDetails;

  /// Debounce timer for drag move processing (16ms = ~60fps).
  Timer? _dragMoveDebounceTimer;

  /// Whether layout has been cached for the current drag operation.
  /// Reset when drag ends to force re-caching on next drag.
  bool _layoutCachedForDrag = false;

  @override
  void initState() {
    super.initState();
    _lastFirstDayOfWeek = widget.controller.resolvedFirstDayOfWeek;
    _computeDates();
    widget.dragHandler?.addListener(_onDragHandlerChanged);
  }

  @override
  void didUpdateWidget(MonthPageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentFirstDayOfWeek = widget.controller.resolvedFirstDayOfWeek;
    if (oldWidget.month != widget.month ||
        _lastFirstDayOfWeek != currentFirstDayOfWeek) {
      _lastFirstDayOfWeek = currentFirstDayOfWeek;
      _computeDates();
    }
    if (oldWidget.dragHandler != widget.dragHandler) {
      oldWidget.dragHandler?.removeListener(_onDragHandlerChanged);
      widget.dragHandler?.addListener(_onDragHandlerChanged);
    }
  }

  @override
  void dispose() {
    _dragMoveDebounceTimer?.cancel();
    widget.dragHandler?.removeListener(_onDragHandlerChanged);
    super.dispose();
  }

  /// Builds the semantic label for the drop target during an active drag.
  ///
  /// Returns null when there is no drop target state to announce (e.g. no
  /// highlighted cells). For multi-day events, includes the full date range
  /// (e.g. "January 20, 2025 to January 22, 2025").
  String? _buildDropTargetSemanticLabel() {
    final dragHandler = widget.dragHandler;
    if (dragHandler == null) return null;

    final highlightedCells = dragHandler.highlightedCells;
    if (highlightedCells.isEmpty) return null;

    final isValid = dragHandler.isProposedDropValid;
    final locale = widget.locale;
    final l10n = mcalL10n(context);
    final localizations = MCalDateFormatUtils();
    final prefix = l10n.dropTargetPrefix;
    final validStr = isValid ? l10n.dropTargetValid : l10n.dropTargetInvalid;

    final firstDate = highlightedCells.first.date;
    final firstDateStr = localizations.formatDate(firstDate, locale);

    final String dateRangeStr;
    if (highlightedCells.length == 1) {
      dateRangeStr = firstDateStr;
    } else {
      final lastDate = highlightedCells.last.date;
      final lastDateStr = localizations.formatDate(lastDate, locale);
      final toStr = l10n.dropTargetDateRangeTo;
      dateRangeStr = '$firstDateStr $toStr $lastDateStr';
    }

    return '$prefix, $dateRangeStr, $validStr';
  }

  /// Called when drag handler state changes.
  ///
  /// During an active resize, feedback layers are updated by their own
  /// [ListenableBuilder] wrappers — a full [setState] here is skipped to
  /// avoid rebuilding the event-tile subtree during active operations.
  ///
  /// With the Layer 5 architecture, pointer tracking for resize lives in a
  /// stable sibling branch, so full rebuilds during resize are now safe.
  void _onDragHandlerChanged() {
    if (!mounted) return;
    final dragHandler = widget.dragHandler;
    if (dragHandler != null &&
        !dragHandler.isDragging &&
        !dragHandler.isResizing) {
      // Drag/resize ended or cancelled - clear caches so indicators never stick
      _cachedDragData = null;
      _layoutCachedForDrag = false;
      setState(() {});
    } else if (dragHandler != null) {
      // Active drag or resize: rebuild is safe because:
      //  - Drag: LongPressDraggable manages its own gesture state.
      //  - Resize: Layer 5 Listener tracks the pointer independently.
      setState(() {});
    }
  }

  /// Compute the dates and weeks for this month.
  void _computeDates() {
    _dates = generateMonthDates(
      widget.month,
      widget.controller.resolvedFirstDayOfWeek,
    );
    _weeks = <List<DateTime>>[];
    for (int i = 0; i < _dates.length; i += 7) {
      _weeks.add(_dates.sublist(i, i + 7));
    }
  }

  /// Update cached layout values from render box.
  /// Called once at start of each drag (guarded by [_layoutCachedForDrag]).
  /// Always recomputes — the formula depends on [widget.showWeekNumbers] and
  /// text direction, which can change without affecting overall widget size.
  void _updateLayoutCache(RenderBox renderBox) {
    _cachedCalendarSize = renderBox.size;
    _cachedCalendarOffset = renderBox.localToGlobal(Offset.zero);
    // Account for week number column: day width is computed from content area only
    final weekNumColWidth = widget.theme.monthViewTheme?.weekNumberColumnWidth ??
        MCalThemeData.fromTheme(Theme.of(context)).monthViewTheme!.weekNumberColumnWidth!;
    final weekNumberWidth = widget.showWeekNumbers ? weekNumColWidth : 0.0;
    _cachedWeekNumberWidth = weekNumberWidth;
    // In LTR, week numbers are on the left → content starts at weekNumberWidth.
    // In RTL, week numbers are on the right → content starts at 0.
    final isLayoutRTL = MCalLayoutDirectionality.of(context);
    _cachedContentOffsetX = isLayoutRTL ? 0.0 : weekNumberWidth;
    _cachedDayWidth = (_cachedCalendarSize.width - weekNumberWidth) / 7;
    _cachedWeekRowHeight = _cachedCalendarSize.height / _weeksInMonth;
  }

  /// Whether a drag is currently active.
  bool get _isDragActive => widget.dragHandler?.isDragging ?? false;

  /// Whether a resize is currently active.
  bool get _isResizeActive => widget.dragHandler?.isResizing ?? false;

  /// Whether a drag or resize is currently active (for overlay rendering).
  bool get _isDragOrResizeActive => _isDragActive || _isResizeActive;

  /// Get week dates for a specific week row index.
  List<DateTime> _getWeekDates(int weekRowIndex) {
    if (weekRowIndex < 0 || weekRowIndex >= _weeks.length) return [];
    return _weeks[weekRowIndex];
  }

  /// Get bounds for a specific week row (uses cached values).
  /// Returns the content area bounds (excluding week number column).
  Rect _getWeekRowBounds(int index) {
    return Rect.fromLTWH(
      _cachedContentOffsetX,
      index * _cachedWeekRowHeight,
      _cachedCalendarSize.width - _cachedWeekNumberWidth,
      _cachedWeekRowHeight,
    );
  }

  /// Calculate event duration in days.
  int _calculateEventDuration(MCalCalendarEvent event) {
    return daysBetween(event.start, event.end) + 1;
  }

  // ============================================================
  // Unified Drag Target Handlers
  // ============================================================

  /// Handles drag move events from the unified DragTarget.
  ///
  /// This method is called on every frame during drag. To maintain 60fps,
  /// we only store the latest position here and debounce the expensive
  /// calculations to run at most once per 16ms.
  void _handleDragMove(DragTargetDetails<MCalDragData> details) {
    // Store the latest details for debounced processing
    _latestDragDetails = details;

    // Start debounce timer if not already running.
    // Don't cancel - we want to process the latest position every 16ms,
    // not 16ms after the last move.
    if (_dragMoveDebounceTimer == null || !_dragMoveDebounceTimer!.isActive) {
      _dragMoveDebounceTimer = Timer(
        const Duration(milliseconds: 16),
        _processDragMove,
      );
    }
  }

  /// Processes the drag move after debounce.
  ///
  /// This contains all the expensive calculations that should only
  /// run at most once per 16ms frame.
  void _processDragMove() {
    final details = _latestDragDetails;
    if (details == null) return;

    final dragHandler = widget.dragHandler;
    if (dragHandler == null) return;

    final dragData = details.data;

    // Cache drag data and event duration at start of drag (not every frame)
    if (_cachedDragData != dragData) {
      _cachedDragData = dragData;
      _cachedEventDuration = _calculateEventDuration(dragData.event);
      _layoutCachedForDrag = false; // Reset to force layout cache on new drag
    }

    // Calculate pointer position (details.offset is feedback position, add grabOffsetX)
    final pointerGlobalX = details.offset.dx + dragData.grabOffsetX;
    final pointerGlobalY = details.offset.dy;

    // Cache layout once at drag start - layout doesn't change during drag
    if (!_layoutCachedForDrag) {
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) return;
      _updateLayoutCache(renderBox);
      _layoutCachedForDrag = true;
    }

    // Use cached values for fast calculation
    final localY = pointerGlobalY - _cachedCalendarOffset.dy;
    final weekRowIndex = (localY / _cachedWeekRowHeight).floor().clamp(
      0,
      _weeksInMonth - 1,
    );

    // Call dragHandler.handleDragMove with cached/minimal parameters.
    // weekRowBounds uses content area (excluding week number column) so that
    // cell index and highlight bounds are computed correctly.
    final contentLeft = _cachedCalendarOffset.dx + _cachedContentOffsetX;
    final contentWidth = _cachedCalendarSize.width - _cachedWeekNumberWidth;
    dragHandler.handleDragMove(
      globalPosition: Offset(pointerGlobalX, pointerGlobalY),
      dayWidth: _cachedDayWidth,
      grabOffsetX: dragData.grabOffsetX,
      eventDurationDays: _cachedEventDuration,
      weekRowIndex: weekRowIndex,
      weekRowBounds: Rect.fromLTWH(
        contentLeft,
        _cachedCalendarOffset.dy + weekRowIndex * _cachedWeekRowHeight,
        contentWidth,
        _cachedWeekRowHeight,
      ),
      calendarBounds: _cachedCalendarOffset & _cachedCalendarSize,
      weekDates: _getWeekDates(weekRowIndex),
      totalWeekRows: _weeksInMonth,
      getWeekRowBounds: _getWeekRowBounds,
      getWeekDates: _getWeekDates,
      validationCallback: (start, end) {
        // Library-level region block check via controller.
        for (DateTime d = start; !d.isAfter(end); d = addDays(d, 1)) {
          if (widget.controller.isDateBlocked(d)) {
            return false;
          }
        }
        // Cross-view enforcement: check timed regions for non-all-day events.
        if (!dragData.event.isAllDay) {
          final eventDuration = dragData.event.end.difference(
            dragData.event.start,
          );
          final projectedStart = DateTime(
            start.year,
            start.month,
            start.day,
            dragData.event.start.hour,
            dragData.event.start.minute,
          );
          final projectedEnd = projectedStart.add(eventDuration);
          if (widget.controller.isTimeRangeBlocked(
            projectedStart,
            projectedEnd,
          )) {
            return false;
          }
        }
        // Consumer validation.
        if (widget.onDragWillAccept != null) {
          return widget.onDragWillAccept!(
            context,
            MCalDragWillAcceptDetails(
              event: dragData.event,
              proposedStartDate: start,
              proposedEndDate: end,
            ),
          );
        }
        return true;
      },
    );

    // Handle edge proximity for month navigation
    if (widget.dragEdgeNavigationEnabled) {
      final localX = pointerGlobalX - _cachedCalendarOffset.dx;
      _checkEdgeProximity(localX, _cachedCalendarSize.width);
    }
  }

  /// Handle edge proximity for cross-month navigation.
  void _checkEdgeProximity(double localX, double calendarWidth) {
    final dragHandler = widget.dragHandler;
    if (dragHandler == null) return;

    // Edge threshold is 10% of calendar width
    final edgeThreshold = calendarWidth * 0.1;
    final nearLeftEdge = localX < edgeThreshold;
    final nearRightEdge = localX > (calendarWidth - edgeThreshold);

    if (nearLeftEdge && widget.onNavigateToPreviousMonth != null) {
      dragHandler.handleEdgeProximity(
        true,
        true, // left edge -> previous month
        widget.onNavigateToPreviousMonth!,
        delay: widget.dragEdgeNavigationDelay,
      );
    } else if (nearRightEdge && widget.onNavigateToNextMonth != null) {
      dragHandler.handleEdgeProximity(
        true,
        false, // right edge -> next month
        widget.onNavigateToNextMonth!,
        delay: widget.dragEdgeNavigationDelay,
      );
    } else {
      dragHandler.handleEdgeProximity(false, false, () {});
    }
  }

  /// Handles drag leave events from the unified DragTarget.
  ///
  /// Cancels the debounce timer and clears stale drag details to prevent
  /// a pending [_processDragMove] from re-creating drop indicators after
  /// they've been cleared. Then clears the full proposed drop range so both
  /// Layer 3 (phantom tiles) and Layer 4 (cell overlay) disappear.
  ///
  /// NOTE: DragTarget.onLeave fires BEFORE onAcceptWithDetails when a drop
  /// is accepted. This is safe because [_handleDrop] sets fresh
  /// [_latestDragDetails] and calls [_processDragMove] to recalculate
  /// the proposed range from scratch before reading proposed dates.
  void _handleDragLeave() {
    // Cancel pending debounce timer to prevent it from re-creating
    // drop indicators with stale position data after we clear them.
    _dragMoveDebounceTimer?.cancel();
    _dragMoveDebounceTimer = null;
    _latestDragDetails = null;

    // Do not cancel edge navigation during drag leave
    // to allow edge navigation during drag leave.

    // Clear the proposed drop range to remove any stale highlight cells.
    widget.dragHandler?.clearProposedDropRange();
  }

  /// Handles drop events from the unified DragTarget.
  void _handleDrop(DragTargetDetails<MCalDragData> details) {
    final dragHandler = widget.dragHandler;

    // Cancel edge navigation immediately
    dragHandler?.cancelEdgeNavigation();

    // Flush any pending local debounce timer and process immediately.
    // If the month changed during drag (edge nav) without an onMove, we may have
    // stale proposed dates from the previous page. Use the drop position to
    // recalculate with this page's layout so the drop lands on the visible month.
    if (_dragMoveDebounceTimer?.isActive ?? false) {
      _dragMoveDebounceTimer?.cancel();
    }
    _latestDragDetails = details;
    _layoutCachedForDrag = false;
    _processDragMove();

    // Check if drop is valid
    if (dragHandler != null && !dragHandler.isProposedDropValid) {
      // Invalid drop - clear all drag state so drop indicators disappear
      dragHandler.cancelDrag();
      return;
    }

    final dragData = details.data;
    final event = dragData.event;

    // Use the proposed dates from the drag handler if available.
    final proposedStart = dragHandler?.proposedStartDate;
    final proposedEnd = dragHandler?.proposedEndDate;

    if (proposedStart == null || proposedEnd == null) {
      // No valid proposed dates, can't complete drop - clear all drag state
      dragHandler?.cancelDrag();
      return;
    }

    // Calculate new dates preserving time components (DST-safe).
    final dayDelta = daysBetween(dateOnly(event.start), proposedStart);
    final newStartDate = addDays(event.start, dayDelta);
    final newEndDate = addDays(event.end, dayDelta);

    // Store old dates for potential revert
    final oldStartDate = event.start;
    final oldEndDate = event.end;

    // Create the updated event
    final updatedEvent = event.copyWith(start: newStartDate, end: newEndDate);

    // Detect recurring occurrence
    final isRecurring = event.occurrenceId != null;
    String? seriesId;
    if (isRecurring) {
      final occId = event.occurrenceId!;
      seriesId = event.id.endsWith('_$occId')
          ? event.id.substring(0, event.id.length - occId.length - 1)
          : event.id;
    }

    if (isRecurring && seriesId != null) {
      // Recurring occurrence: use a `modified` exception so the full event
      // state (including any prior resize or other modifications) is preserved.
      // A `rescheduled` exception only carries a newDate and would revert the
      // occurrence to the master event's original duration.
      final exception = MCalRecurrenceException.modified(
        originalDate: DateTime.parse(event.occurrenceId!),
        modifiedEvent: updatedEvent,
      );
      if (widget.onEventDropped != null) {
        final shouldKeep = widget.onEventDropped!(
          context,
          MCalEventDroppedDetails(
            event: event,
            oldStartDate: oldStartDate,
            oldEndDate: oldEndDate,
            newStartDate: newStartDate,
            newEndDate: newEndDate,
            isRecurring: true,
            seriesId: seriesId,
          ),
        );

        if (shouldKeep) {
          widget.controller.addException(seriesId, exception);
        }
      } else {
        // No callback provided — auto-create modified exception
        widget.controller.addException(seriesId, exception);
      }
    } else {
      // Non-recurring event: existing behavior
      widget.controller.addEvents([updatedEvent]);

      // Call onEventDropped callback if provided
      if (widget.onEventDropped != null) {
        final shouldKeep = widget.onEventDropped!(
          context,
          MCalEventDroppedDetails(
            event: event,
            oldStartDate: oldStartDate,
            oldEndDate: oldEndDate,
            newStartDate: newStartDate,
            newEndDate: newEndDate,
          ),
        );

        // If callback returns false, revert the change
        if (!shouldKeep) {
          final revertedEvent = event.copyWith(
            start: oldStartDate,
            end: oldEndDate,
          );
          widget.controller.addEvents([revertedEvent]);
        }
      }
    }

    // Mark drag as complete - this clears all drag state including isDragging.
    // This prevents the microtask in _handleDragEnded from doing redundant cleanup.
    dragHandler?.cancelDrag();
  }

  // ============================================================
  // Resize Interaction (delegates to parent for pointer tracking)
  // ============================================================

  /// Called by [MonthResizeHandle.onPointerDown]. Delegates to the parent
  /// [_MCalMonthViewState] via the [onResizePointerDownCallback] so
  /// the gesture survives across page transitions during edge navigation.
  void _handleResizePointerDown(
    MCalCalendarEvent event,
    MCalResizeEdge edge,
    int pointer,
  ) {
    widget.onResizePointerDownCallback?.call(event, edge, pointer);
  }

  /// Builds a list of [MCalHighlightCellInfo] for a date range.
  ///
  /// Uses the cached layout values to compute bounds for each cell
  /// in the proposed range, spanning across week rows as needed.
  List<MCalHighlightCellInfo> _buildHighlightCellsForDateRange(
    DateTime start,
    DateTime end,
  ) {
    final cells = <MCalHighlightCellInfo>[];
    if (_weeks.isEmpty) return cells;

    // Ensure we have valid layout cache
    final dayWidth = _cachedDayWidth > 0
        ? _cachedDayWidth
        : (_cachedCalendarSize.width - _cachedWeekNumberWidth) / 7;
    final weekRowHeight = _cachedWeekRowHeight > 0
        ? _cachedWeekRowHeight
        : (_weeks.isNotEmpty
              ? _cachedCalendarSize.height / _weeks.length
              : 0.0);

    if (dayWidth <= 0 || weekRowHeight <= 0) return cells;

    final normalizedStart = dateOnly(start);
    final normalizedEnd = dateOnly(end);
    final totalDays = daysBetween(normalizedStart, normalizedEnd) + 1;

    int cellNumber = 0;

    // Iterate through each week row to find matching dates
    for (int weekRowIndex = 0; weekRowIndex < _weeks.length; weekRowIndex++) {
      final weekDates = _weeks[weekRowIndex];
      for (int cellIndex = 0; cellIndex < weekDates.length; cellIndex++) {
        final cellDate = weekDates[cellIndex];
        final normalizedCell = DateTime(
          cellDate.year,
          cellDate.month,
          cellDate.day,
        );

        // Check if this cell is within the proposed range
        if (!normalizedCell.isBefore(normalizedStart) &&
            !normalizedCell.isAfter(normalizedEnd)) {
          final cellLeft = _cachedContentOffsetX + (cellIndex * dayWidth);
          final cellTop = weekRowIndex * weekRowHeight;
          final cellBounds = Rect.fromLTWH(
            cellLeft,
            cellTop,
            dayWidth,
            weekRowHeight,
          );

          cells.add(
            MCalHighlightCellInfo(
              date: normalizedCell,
              cellIndex: cellIndex,
              weekRowIndex: weekRowIndex,
              bounds: cellBounds,
              isFirst: cellNumber == 0,
              isLast: cellNumber == totalDays - 1,
            ),
          );
          cellNumber++;
        }
      }
    }

    return cells;
  }

  // ============================================================
  // Layer 3 Drop Target Tile Builder
  // ============================================================

  /// Returns an [MCalEventTileBuilder] for Layer 3 that builds [MCalEventTileContext]
  /// with [isDropTargetPreview], [dropValid], [proposedStartDate], [proposedEndDate]
  /// from [dragHandler], then calls [widget.dropTargetTileBuilder] or default tile.
  MCalEventTileBuilder _buildDropTargetTileEventBuilder(
    MCalDragHandler dragHandler,
  ) {
    final customBuilder = widget.dropTargetTileBuilder;
    return (BuildContext context, MCalEventTileContext tileContext) {
      // Use dragged event during drag, or resizing event during resize
      final event = dragHandler.draggedEvent ?? dragHandler.resizingEvent;
      if (event == null) return const SizedBox.shrink();
      final meta = widget.getRecurrenceMetadata(event, widget.controller);
      final newContext = MCalEventTileContext(
        event: event,
        displayDate: tileContext.displayDate,
        isAllDay: tileContext.isAllDay,
        segment: tileContext.segment,
        width: tileContext.width,
        height: tileContext.height,
        isDropTargetPreview: true,
        dropValid: dragHandler.isProposedDropValid,
        proposedStartDate: dragHandler.proposedStartDate,
        proposedEndDate: dragHandler.proposedEndDate,
        isRecurring: meta.isRecurring,
        seriesId: meta.seriesId,
        recurrenceRule: meta.recurrenceRule,
        masterEvent: meta.masterEvent,
        isException: meta.isException,
        regions: widget.controller.getRegionsForDate(tileContext.displayDate),
      );
      if (customBuilder != null) return customBuilder(context, newContext);
      return _buildDefaultDropTargetTile(context, newContext);
    };
  }

  /// Default drop target tile: same shape as default event tile, no text.
  /// Style: dropTargetTile* → eventTile* → event.color → fallback.
  Widget _buildDefaultDropTargetTile(
    BuildContext context,
    MCalEventTileContext tileContext,
  ) {
    final theme = widget.theme;
    final event = tileContext.event;
    final segment = tileContext.segment;
    final valid = tileContext.dropValid ?? true;
    final defaults = MCalThemeData.fromTheme(Theme.of(context));

    final cornerRadius =
        theme.monthViewTheme?.dropTargetTileCornerRadius ??
        theme.monthViewTheme?.eventTileCornerRadius ??
        defaults.monthViewTheme!.eventTileCornerRadius!;
    final leftRadius = segment?.isFirstSegment ?? true ? cornerRadius : 0.0;
    final rightRadius = segment?.isLastSegment ?? true ? cornerRadius : 0.0;
    final tileColor = valid
        ? resolveDropTargetTileColor(
            dropTargetThemeColor: theme.monthViewTheme?.dropTargetTileBackgroundColor,
            themeColor: theme.monthViewTheme?.eventTileBackgroundColor,
            eventColor: event.color,
            enableEventColorOverrides: theme.enableEventColorOverrides,
            defaultColor: defaults.monthViewTheme!.eventTileBackgroundColor!,
          )
        : (theme.monthViewTheme?.dropTargetTileInvalidBackgroundColor ??
              defaults.monthViewTheme!.dropTargetTileInvalidBackgroundColor!);

    final isFirstSegment = segment?.isFirstSegment ?? true;
    final isLastSegment = segment?.isLastSegment ?? true;

    // If the theme specifies explicit border settings, honour them.
    // Otherwise use the tile color as a 1px border with a translucent fill
    // so the drop-target preview is visually distinct from the original tile.
    final themeBorderWidth =
        theme.monthViewTheme?.dropTargetTileBorderWidth ??
        theme.monthViewTheme?.eventTileBorderWidth;
    final themeBorderColor =
        theme.monthViewTheme?.dropTargetTileBorderColor ??
        theme.monthViewTheme?.eventTileBorderColor;
    final hasThemeBorder =
        themeBorderWidth != null &&
        themeBorderWidth > 0 &&
        themeBorderColor != null;

    final Color fillColor;
    final Border tileBorder;
    if (hasThemeBorder) {
      // Explicit theme border — use the tile color as-is for the fill.
      fillColor = tileColor;
      final topBorder = BorderSide(
        color: themeBorderColor,
        width: themeBorderWidth,
      );
      final bottomBorder = BorderSide(
        color: themeBorderColor,
        width: themeBorderWidth,
      );
      final leftBorder = isFirstSegment
          ? BorderSide(color: themeBorderColor, width: themeBorderWidth)
          : BorderSide.none;
      final rightBorder = isLastSegment
          ? BorderSide(color: themeBorderColor, width: themeBorderWidth)
          : BorderSide.none;
      tileBorder = Border(
        top: topBorder,
        bottom: bottomBorder,
        left: leftBorder,
        right: rightBorder,
      );
    } else {
      // Translucent fill in the event colour with a solid border.
      // No outer Opacity — Month View tiles are thin bars on a white
      // background, so they need a stronger fill than the Day View.
      fillColor = valid
          ? tileColor.withValues(alpha: 0.35)
          : tileColor.withValues(alpha: 0.35);
      final borderColor = valid
          ? tileColor
          : (theme.monthViewTheme?.dropTargetTileInvalidBackgroundColor ??
              defaults.monthViewTheme!.dropTargetTileInvalidBackgroundColor!);
      final fallbackBorderWidth =
          defaults.monthViewTheme!.dropTargetTileBorderWidth!;
      final borderSide = BorderSide(color: borderColor, width: fallbackBorderWidth);
      final leftBorder = isFirstSegment ? borderSide : BorderSide.none;
      final rightBorder = isLastSegment ? borderSide : BorderSide.none;
      tileBorder = Border(
        top: borderSide,
        bottom: borderSide,
        left: leftBorder,
        right: rightBorder,
      );
    }

    final baseTile = Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(leftRadius),
          right: Radius.circular(rightRadius),
        ),
        border: tileBorder,
      ),
    );

    // During a resize operation, show a visual handle on the active edge
    // so the user can see where to grab even though the drop target tile
    // covers the real event tile (and its resize handle).
    final dragHandler = widget.dragHandler;
    if (dragHandler != null && dragHandler.isResizing) {
      final resizeEdge = dragHandler.resizeEdge;
      final isLayoutRTL = MCalLayoutDirectionality.of(context);

      // Determine whether to show handle on this segment's edge.
      // Start handle on first segment, end handle on last segment.
      final showStartHandle =
          resizeEdge == MCalResizeEdge.start &&
          (segment?.isFirstSegment ?? true);
      final showEndHandle =
          resizeEdge == MCalResizeEdge.end && (segment?.isLastSegment ?? true);

      if (showStartHandle || showEndHandle) {
        final isLeading = (resizeEdge == MCalResizeEdge.start) != isLayoutRTL;

        // Compute inset for the drop-target handle.
        final handleInset = widget.resizeHandleInset != null
            ? widget.resizeHandleInset!(tileContext, resizeEdge!)
            : 0.0;

        // Build the visual child — custom builder or default white bar.
        final handleContext = MCalResizeHandleContext(
          edge: resizeEdge!,
          event: tileContext.event,
          isDropTargetPreview: true,
        );
        final resizeHandleColor = theme.monthViewTheme?.resizeHandleColor ??
            defaults.monthViewTheme!.resizeHandleColor!;
        final handleVisualWidth = theme.monthViewTheme?.resizeHandleVisualWidth ??
            defaults.monthViewTheme!.resizeHandleVisualWidth!;
        final handleVMargin = theme.monthViewTheme?.resizeHandleVerticalMargin ??
            defaults.monthViewTheme!.resizeHandleVerticalMargin!;
        final handleRadius = theme.monthViewTheme?.resizeHandleBorderRadius ??
            defaults.monthViewTheme!.resizeHandleBorderRadius!;
        final tileHeight = theme.monthViewTheme?.eventTileHeight ??
            defaults.monthViewTheme!.eventTileHeight!;
        final handleVisualHeight = tileHeight - (2 * handleVMargin);
        final visual = widget.resizeHandleBuilder != null
            ? widget.resizeHandleBuilder!(context, handleContext)
            : Container(
                width: handleVisualWidth,
                height: handleVisualHeight,
                decoration: BoxDecoration(
                  color: resizeHandleColor,
                  borderRadius: BorderRadius.circular(handleRadius),
                ),
              );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: baseTile),
            Positioned(
              left: isLeading ? handleInset : null,
              right: isLeading ? null : handleInset,
              top: 0,
              bottom: 0,
              width: MonthResizeHandle.handleWidth,
              child: Center(child: visual),
            ),
          ],
        );
      }
    }

    return baseTile;
  }

  // ============================================================
  // Highlight Overlay Builder
  // ============================================================

  /// Builds Layer 3: drop target preview tiles (phantom segments, same week layout as Layer 2).
  ///
  /// Tiles are only shown when the drop target is valid ([isProposedDropValid]).
  /// This matches overlay and drop handling: invalid targets (e.g. conflicts, or
  /// dragged out of range) should not show tiles.
  Widget _buildDropTargetTilesLayer(BuildContext context) {
    final dragHandler = widget.dragHandler;
    if (dragHandler == null ||
        !dragHandler.isProposedDropValid ||
        dragHandler.proposedStartDate == null ||
        dragHandler.proposedEndDate == null) {
      return const SizedBox.shrink();
    }
    final proposedStart = dragHandler.proposedStartDate!;
    final proposedEnd = dragHandler.proposedEndDate!;
    final monthStart = DateTime(widget.month.year, widget.month.month, 1);
    final firstDayOfWeek = widget.controller.resolvedFirstDayOfWeek;

    return LayoutBuilder(
      builder: (context, constraints) {
        final defaults = MCalThemeData.fromTheme(Theme.of(context));
        final weekNumColWidthDrop = widget.theme.monthViewTheme?.weekNumberColumnWidth ??
            defaults.monthViewTheme!.weekNumberColumnWidth!;
        final weekNumberWidth = widget.showWeekNumbers ? weekNumColWidthDrop : 0.0;
        final contentWidth = constraints.maxWidth - weekNumberWidth;
        final dayWidth = _weeks.isNotEmpty ? contentWidth / 7 : 0.0;
        final rowHeight = _weeks.isNotEmpty
            ? constraints.maxHeight / _weeks.length
            : 0.0;
        final dateLabelHeight = widget.theme.monthViewTheme?.dateLabelHeight ??
            defaults.monthViewTheme!.dateLabelHeight!;

        final phantomSegments = _getPhantomSegmentsForDropTarget(
          proposedStartDate: proposedStart,
          proposedEndDate: proposedEnd,
          monthStart: monthStart,
          firstDayOfWeek: firstDayOfWeek,
        );
        final dropTargetTileBuilder = _buildDropTargetTileEventBuilder(
          dragHandler,
        );
        final dateLabelPlaceholder = _buildDropTargetDateLabelPlaceholder(
          dateLabelHeight: dateLabelHeight,
          dayWidth: dayWidth,
        );
        final config = MCalMonthWeekLayoutConfig.fromTheme(
          widget.theme,
          flutterTheme: Theme.of(context),
          maxVisibleEventsPerDay: widget.maxVisibleEventsPerDay,
        );
        Widget noOpOverflow(
          BuildContext ctx,
          MCalMonthOverflowIndicatorContext overflowContext,
        ) => const SizedBox.shrink();

        return Column(
          children: List.generate(_weeks.length, (weekRowIndex) {
            final weekDates = _weeks[weekRowIndex];
            final columnWidths = List.filled(7, dayWidth);
            final segments = weekRowIndex < phantomSegments.length
                ? phantomSegments[weekRowIndex]
                : <MCalMonthEventSegment>[];
            final layoutContext = MCalMonthWeekLayoutContext(
              segments: segments,
              dates: weekDates,
              columnWidths: columnWidths,
              rowHeight: rowHeight,
              weekRowIndex: weekRowIndex,
              currentMonth: widget.month,
              config: config,
              eventTileBuilder: dropTargetTileBuilder,
              dateLabelBuilder: dateLabelPlaceholder,
              overflowIndicatorBuilder: noOpOverflow,
            );
            final weekLayout = widget.weekLayoutBuilder != null
                ? widget.weekLayoutBuilder!(context, layoutContext)
                : MCalMonthDefaultWeekLayoutBuilder.build(
                    context,
                    layoutContext,
                  );
            return Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.showWeekNumbers)
                    SizedBox(width: weekNumColWidthDrop),
                  Expanded(child: weekLayout),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  /// Builds the Layer 4 highlight overlay for drop target cells.
  ///
  /// Precedence: dropTargetOverlayBuilder > dropTargetCellBuilder > default CustomPainter.
  /// Semantics for the drop target are applied at the DragTarget level (see
  /// [build]) so they remain when the overlay is disabled.
  Widget _buildDropTargetOverlayLayer(BuildContext context) {
    final dragHandler = widget.dragHandler;
    if (dragHandler == null) return const SizedBox.shrink();

    var highlightedCells = dragHandler.highlightedCells;

    // When keyboard operations provide empty cells but have valid proposed
    // dates (keyboard handlers live in the outer _MCalMonthViewState and
    // don't have access to the layout cache), compute the cells here.
    if (highlightedCells.isEmpty &&
        dragHandler.proposedStartDate != null &&
        dragHandler.proposedEndDate != null &&
        (dragHandler.isDragging || dragHandler.isResizing)) {
      highlightedCells = _buildHighlightCellsForDateRange(
        dragHandler.proposedStartDate!,
        dragHandler.proposedEndDate!,
      );
    }
    if (highlightedCells.isEmpty) return const SizedBox.shrink();

    final isValid = dragHandler.isProposedDropValid;

    Widget overlay;
    // Precedence: dropTargetOverlayBuilder > dropTargetCellBuilder > default
    // Note: dropTargetOverlayBuilder requires drag data; during resize,
    // fall through to dropTargetCellBuilder or default painter.
    if (widget.dropTargetOverlayBuilder != null &&
        dragHandler.draggedEvent != null) {
      // Use cached values instead of findRenderObject
      final draggedEvent = dragHandler.draggedEvent;
      final sourceDate = dragHandler.sourceDate;
      if (draggedEvent == null || sourceDate == null) {
        return const SizedBox.shrink();
      }

      // Reuse cached drag data if available
      final dragData =
          _cachedDragData ??
          MCalDragData(
            event: draggedEvent,
            sourceDate: sourceDate,
            grabOffsetHolder: MCalGrabOffsetHolder(),
            horizontalSpacing: 0,
            feedbackWidth: 0,
            feedbackHeight: 0,
          );

      overlay = widget.dropTargetOverlayBuilder!(
        context,
        MCalDropOverlayDetails(
          highlightedCells: highlightedCells,
          isValid: isValid,
          dayWidth: _cachedDayWidth,
          calendarSize: _cachedCalendarSize,
          dragData: dragData,
        ),
      );
    } else if (widget.dropTargetCellBuilder != null) {
      overlay = Stack(
        children: [
          for (final cell in highlightedCells)
            Positioned.fromRect(
              rect: cell.bounds,
              child: widget.dropTargetCellBuilder!(
                context,
                MCalDropTargetCellDetails(
                  date: cell.date,
                  bounds: cell.bounds,
                  isValid: isValid,
                  isFirst: cell.isFirst,
                  isLast: cell.isLast,
                  cellIndex: cell.cellIndex,
                  weekRowIndex: cell.weekRowIndex,
                ),
              ),
            ),
        ],
      );
    } else {
      // Default: CustomPainter (most performant)
      final first = highlightedCells.first;
      final last = highlightedCells.last;
      overlay = CustomPaint(
        size: Size.infinite,
        painter: DropTargetHighlightPainter(
          highlightedCells: highlightedCells,
          dropStartWeekRow: first.weekRowIndex,
          dropStartCellIndex: first.cellIndex,
          dropEndWeekRow: last.weekRowIndex,
          dropEndCellIndex: last.cellIndex,
          isValid: isValid,
          validColor: () {
                final d = MCalThemeData.fromTheme(Theme.of(context));
                return widget.theme.monthViewTheme?.dropTargetCellValidColor ??
                    d.monthViewTheme!.dropTargetCellValidColor!;
              }(),
          invalidColor: () {
                final d = MCalThemeData.fromTheme(Theme.of(context));
                return widget.theme.monthViewTheme?.dropTargetCellInvalidColor ??
                    d.monthViewTheme!.dropTargetCellInvalidColor!;
              }(),
          borderRadius: widget.theme.monthViewTheme?.dropTargetCellBorderRadius ??
              MCalThemeData.fromTheme(Theme.of(context)).monthViewTheme!.dropTargetCellBorderRadius!,
        ),
      );
    }

    return overlay;
  }

  @override
  Widget build(BuildContext context) {
    // Get events for this specific month (may differ from currentDisplayMonth)
    final monthEvents =
        (widget.month.year == widget.currentDisplayMonth.year &&
            widget.month.month == widget.currentDisplayMonth.month)
        ? widget.events
        : widget.getEventsForMonth(widget.month);

    // Calculate multi-day event layouts
    final multiDayLayouts = MCalMultiDayRenderer.calculateLayouts(
      events: monthEvents,
      monthStart: widget.month,
      firstDayOfWeek: widget.controller.resolvedFirstDayOfWeek,
    );

    // Build the week rows
    Widget weekRowsColumn = Column(
      children: _weeks.asMap().entries.map((entry) {
        final weekRowIndex = entry.key;
        final weekDates = entry.value;

        // Get layouts for this week row
        final weekLayouts = multiDayLayouts
            .where(
              (layout) => layout.rowSegments.any(
                (segment) => segment.weekRowIndex == weekRowIndex,
              ),
            )
            .toList();

        return Expanded(
          child: WeekRowWidget(
            dates: weekDates,
            currentMonth: widget.month,
            events: monthEvents,
            theme: widget.theme,
            focusedDate: widget.controller.focusedDateTime != null
                ? dateOnly(widget.controller.focusedDateTime!)
                : null,
            autoFocusOnCellTap: widget.autoFocusOnCellTap,
            onSetFocusedDate: (date) {
              // Month View always passes isAllDay: true — it focuses entire days
              widget.controller.setFocusedDateTime(
                dateOnly(date),
                isAllDay: true,
              );
            },
            dayCellBuilder: widget.dayCellBuilder,
            eventTileBuilder: widget.eventTileBuilder,
            dateLabelBuilder: widget.dateLabelBuilder,
            dateFormat: widget.dateFormat,
            cellInteractivityCallback: widget.cellInteractivityCallback,
            onCellTap: widget.onCellTap,
            onCellLongPress: widget.onCellLongPress,
            onCellSecondaryTap: widget.onCellSecondaryTap,
            onDateLabelTap: widget.onDateLabelTap,
            onDateLabelLongPress: widget.onDateLabelLongPress,
            onDateLabelDoubleTap: widget.onDateLabelDoubleTap,
            onDateLabelSecondaryTap: widget.onDateLabelSecondaryTap,
            onEventTap: widget.onEventTap,
            onEventLongPress: widget.onEventLongPress,
            onEventSecondaryTap: widget.onEventSecondaryTap,
            onCellDoubleTap: widget.onCellDoubleTap,
            onEventDoubleTap: widget.onEventDoubleTap,
            onHoverCell: widget.onHoverCell,
            onHoverEvent: widget.onHoverEvent,
            onHoverDateLabel: widget.onHoverDateLabel,
            onHoverOverflow: widget.onHoverOverflow,
            locale: widget.locale,
            maxVisibleEventsPerDay: widget.maxVisibleEventsPerDay,
            onOverflowTap: widget.onOverflowTap,
            onOverflowLongPress: widget.onOverflowLongPress,
            onOverflowDoubleTap: widget.onOverflowDoubleTap,
            onOverflowSecondaryTap: widget.onOverflowSecondaryTap,
            showWeekNumbers: widget.showWeekNumbers,
            weekNumberBuilder: widget.weekNumberBuilder,
            weekLayoutBuilder: widget.weekLayoutBuilder,
            overflowIndicatorBuilder: widget.overflowIndicatorBuilder,
            weekRowIndex: weekRowIndex,
            multiDayLayouts: weekLayouts,
            // Drag-and-drop - pass builders but NOT drop target handling
            enableDragToMove: widget.enableDragToMove,
            draggedTileBuilder: widget.draggedTileBuilder,
            dragSourceTileBuilder: widget.dragSourceTileBuilder,
            dropTargetTileBuilder: widget.dropTargetTileBuilder,
            dropTargetCellBuilder: widget.dropTargetCellBuilder,
            onDragWillAccept: widget.onDragWillAccept,
            onEventDropped: widget.onEventDropped,
            controller: widget.controller,
            onDragStartedCallback: widget.onDragStartedCallback,
            onDragEndedCallback: widget.onDragEndedCallback,
            onDragCanceledCallback: widget.onDragCanceledCallback,
            dragHandler: widget.dragHandler,
            dragLongPressDelay: widget.dragLongPressDelay,
            enableDragToResize: widget.enableDragToResize,
            resizeHandleBuilder: widget.resizeHandleBuilder,
            resizeHandleInset: widget.resizeHandleInset,
            onResizeHandlePointerDown: _handleResizePointerDown,
            // Keyboard selection state
            keyboardHighlightedEventId: widget.keyboardHighlightedEventId,
            keyboardSelectedEventId: widget.keyboardSelectedEventId,
            keyboardOverflowFocusedDate: widget.keyboardOverflowFocusedDate,
            layoutVisibleCounts: widget.layoutVisibleCounts,
            // Day regions
            dayRegionBuilder: widget.dayRegionBuilder,
          ),
        );
      }).toList(),
    );

    // Wrap with unified DragTarget if drag-and-drop is enabled
    if (widget.enableDragToMove) {
      return DragTarget<MCalDragData>(
        onMove: _handleDragMove,
        onLeave: (_) => _handleDragLeave(),
        onAcceptWithDetails: _handleDrop,
        builder: (context, candidateData, rejectedData) {
          // Build drop-feedback layers (order controlled by dropTargetTilesAboveOverlay)
          //
          // The feedback layers use ListenableBuilder so they can update
          // independently when the drag handler notifies, without requiring
          // a full setState on the parent widget.
          final dragHandler = widget.dragHandler;

          Widget buildFeedbackLayer({
            required bool enabled,
            required Widget Function(BuildContext) layerBuilder,
          }) {
            if (dragHandler == null) return const SizedBox.shrink();
            // ListenableBuilder rebuilds this subtree whenever the drag
            // handler notifies, even when MonthPageWidgetState doesn't
            // call setState (i.e. during resize).
            return Positioned.fill(
              child: ListenableBuilder(
                listenable: dragHandler,
                builder: (ctx, _) {
                  final active = _isDragOrResizeActive;
                  if (!enabled || !active) {
                    return const SizedBox.shrink();
                  }
                  return RepaintBoundary(
                    child: IgnorePointer(child: layerBuilder(ctx)),
                  );
                },
              ),
            );
          }

          final tilesLayer = buildFeedbackLayer(
            enabled: widget.showDropTargetTiles,
            layerBuilder: _buildDropTargetTilesLayer,
          );
          final overlayLayer = buildFeedbackLayer(
            enabled: widget.showDropTargetOverlay,
            layerBuilder: _buildDropTargetOverlayLayer,
          );

          // By default (dropTargetTilesAboveOverlay: false), tiles are Layer 3
          // (below) and overlay is Layer 4 (above). When true, the order reverses.
          final firstLayer = widget.dropTargetTilesAboveOverlay
              ? overlayLayer
              : tilesLayer;
          final secondLayer = widget.dropTargetTilesAboveOverlay
              ? tilesLayer
              : overlayLayer;

          // Layer 5 (resize gesture tracking) has been moved to the parent
          // _MCalMonthViewState Listener so it survives page transitions.

          // 3 children: main content + 2 drop feedback layers.
          final stack = Stack(
            children: [
              // Layer 1+2: Main content (week rows with grid and events)
              weekRowsColumn,
              // Layer 3+4: Drop feedback (always present via ListenableBuilder)
              firstLayer,
              secondLayer,
            ],
          );

          // Semantics at DragTarget level so drop target state is announced
          // even when overlay is disabled. Includes full date range for multi-day.
          final dropTargetLabel = _isDragOrResizeActive
              ? _buildDropTargetSemanticLabel()
              : null;
          if (dropTargetLabel != null) {
            return Semantics(label: dropTargetLabel, child: stack);
          }
          return stack;
        },
      );
    }

    return weekRowsColumn;
  }
}
