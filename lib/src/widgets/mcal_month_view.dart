import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../controllers/mcal_event_controller.dart';
import '../models/mcal_calendar_event.dart';
import '../styles/mcal_theme.dart';
import '../utils/date_utils.dart';
import '../utils/mcal_localization.dart';
import 'mcal_builder_wrapper.dart';
import 'mcal_callback_details.dart';
import 'mcal_default_week_layout.dart';
import 'mcal_drag_handler.dart';
import 'mcal_draggable_event_tile.dart';
import 'mcal_month_view_contexts.dart';
import 'mcal_multi_day_renderer.dart';
import 'mcal_week_layout_contexts.dart';

/// Builder callback for customizing week row event layout.
///
/// Receives [MCalWeekLayoutContext] containing all events, dates, column widths,
/// and pre-wrapped builders for event tiles, date labels, and overflow indicators.
typedef MCalWeekLayoutBuilder =
    Widget Function(BuildContext context, MCalWeekLayoutContext layoutContext);

/// Direction for swipe navigation gestures.
enum MCalSwipeNavigationDirection {
  /// Horizontal swipe navigation (left/right).
  horizontal,

  /// Vertical swipe navigation (up/down).
  vertical,
}

/// Direction of navigation resulting from a swipe gesture.
enum MCalSwipeDirection {
  /// Navigated to the previous period (triggered by swipe right or down).
  previous,

  /// Navigated to the next period (triggered by swipe left or up).
  next,
}

/// A widget that displays a month calendar grid with events.
///
/// MCalMonthView displays a traditional month calendar grid showing days of the
/// month with events displayed as tiles. It integrates with [MCalEventController]
/// to load and display events, supports extensive customization through builder
/// callbacks, and provides theme integration via [MCalThemeData].
///
/// Example:
/// ```dart
/// final controller = MCalEventController();
///
/// MCalMonthView(
///   controller: controller,
///   onCellTap: (context, details) {
///     print('Tapped on ${details.date} with ${details.events.length} events');
///   },
///   onEventTap: (context, details) {
///     print('Tapped on event: ${details.event.title}');
///   },
/// )
/// ```
class MCalMonthView extends StatefulWidget {
  /// The event controller for loading and managing calendar events.
  ///
  /// This is a required parameter. The controller is responsible for loading
  /// events for the visible date range and notifying the widget of changes.
  final MCalEventController controller;

  /// The initial date to display (defaults to today).
  /// The minimum date that can be displayed.
  ///
  /// If provided, navigation to dates before this date will be disabled.
  final DateTime? minDate;

  /// The maximum date that can be displayed.
  ///
  /// If provided, navigation to dates after this date will be disabled.
  final DateTime? maxDate;

  /// The first day of the week (0 = Sunday, 1 = Monday, etc.).
  ///
  /// If not provided, the system locale's default is used.
  final int? firstDayOfWeek;

  /// Whether to show the month navigator (month/year display and controls).
  ///
  /// Defaults to true.
  final bool showNavigator;

  /// Whether swipe gestures are enabled for navigation.
  ///
  /// Defaults to false.
  final bool enableSwipeNavigation;

  /// The direction for swipe navigation gestures.
  ///
  /// Only used if [enableSwipeNavigation] is true.
  /// Defaults to [MCalSwipeNavigationDirection.horizontal].
  final MCalSwipeNavigationDirection swipeNavigationDirection;

  /// Builder callback for customizing day cell rendering.
  ///
  /// Receives the build context, [MCalDayCellContext] with cell data, and
  /// the default cell widget. Return a custom widget to override the default.
  final Widget Function(BuildContext, MCalDayCellContext, Widget)?
  dayCellBuilder;

  /// Builder callback for customizing event tile rendering.
  ///
  /// Receives the build context, [MCalEventTileContext] with event data, and
  /// the default tile widget. Return a custom widget to override the default.
  final Widget Function(BuildContext, MCalEventTileContext, Widget)?
  eventTileBuilder;

  /// Builder callback for customizing day header rendering.
  ///
  /// Receives the build context, [MCalDayHeaderContext] with header data, and
  /// the default header widget. Return a custom widget to override the default.
  final Widget Function(BuildContext, MCalDayHeaderContext, Widget)?
  dayHeaderBuilder;

  /// Builder callback for customizing navigator rendering.
  ///
  /// Receives the build context, [MCalNavigatorContext] with navigator data,
  /// and the default navigator widget. Return a custom widget to override
  /// the default.
  final Widget Function(BuildContext, MCalNavigatorContext, Widget)?
  navigatorBuilder;

  /// Builder callback for customizing date label rendering.
  ///
  /// Receives the build context, [MCalDateLabelContext] with date data, and
  /// the default formatted string. Return a custom widget to override the
  /// default date label.
  final Widget Function(BuildContext, MCalDateLabelContext, String)?
  dateLabelBuilder;

  /// Callback to determine if a cell is interactive.
  ///
  /// Receives the [BuildContext] and [MCalCellInteractivityDetails] containing
  /// the date, whether it's in the current month, and whether it's selectable.
  /// Return false to disable interactions for that cell.
  final bool Function(BuildContext, MCalCellInteractivityDetails)?
  cellInteractivityCallback;

  /// Callback invoked when a day cell is tapped.
  ///
  /// Receives the [BuildContext] and [MCalCellTapDetails] containing the
  /// tapped date, list of events on that date, and whether the date is
  /// in the current month.
  final void Function(BuildContext, MCalCellTapDetails)? onCellTap;

  /// Callback invoked when a day cell is long-pressed.
  ///
  /// Receives the [BuildContext] and [MCalCellTapDetails] containing the
  /// long-pressed date, list of events on that date, and whether the date
  /// is in the current month.
  final void Function(BuildContext, MCalCellTapDetails)? onCellLongPress;

  /// Callback invoked when a date label is tapped.
  ///
  /// When set, date labels become tappable with this handler.
  /// When not set, taps on date labels pass through to trigger [onCellTap].
  final void Function(BuildContext, MCalDateLabelTapDetails)? onDateLabelTap;

  /// Callback invoked when a date label is long-pressed.
  ///
  /// When set, date labels respond to long-press with this handler.
  /// When not set, long-presses on date labels pass through to the cell.
  final void Function(BuildContext, MCalDateLabelTapDetails)?
  onDateLabelLongPress;

  /// Callback invoked when an event tile is tapped.
  ///
  /// Receives the [BuildContext] and [MCalEventTapDetails] containing the
  /// tapped event and the date context for the tile.
  final void Function(BuildContext, MCalEventTapDetails)? onEventTap;

  /// Callback invoked when an event tile is long-pressed.
  ///
  /// Receives the [BuildContext] and [MCalEventTapDetails] containing the
  /// long-pressed event and the date context for the tile.
  final void Function(BuildContext, MCalEventTapDetails)? onEventLongPress;

  /// Callback invoked when a swipe navigation gesture is detected.
  ///
  /// Receives the [BuildContext] and [MCalSwipeNavigationDetails] containing
  /// the previous month, new month, and swipe direction.
  final void Function(BuildContext, MCalSwipeNavigationDetails)?
  onSwipeNavigation;

  /// Custom date format string for date labels.
  ///
  /// If not provided, default formatting is used based on locale.
  final String? dateFormat;

  /// Locale for date formatting and localization.
  ///
  /// If not provided, the locale from the widget tree is used.
  final Locale? locale;

  // ============ Hover callbacks ============

  /// Callback invoked when the mouse hovers over a day cell.
  ///
  /// Receives the [MCalDayCellContext] for the hovered cell, or null when
  /// the mouse exits the cell. Useful for showing preview information or
  /// highlighting related elements.
  final ValueChanged<MCalDayCellContext?>? onHoverCell;

  /// Callback invoked when the mouse hovers over an event tile.
  ///
  /// Receives the [MCalEventTileContext] for the hovered event, or null when
  /// the mouse exits the event tile. Useful for showing event details in a
  /// tooltip or preview panel.
  final ValueChanged<MCalEventTileContext?>? onHoverEvent;

  // ============ Keyboard navigation ============

  /// Whether keyboard navigation is enabled.
  ///
  /// When true, users can navigate between cells using arrow keys, Enter to
  /// select, and other keyboard shortcuts. Defaults to true.
  final bool enableKeyboardNavigation;

  // ============ Navigation callbacks ============

  /// Callback invoked when the display date changes.
  ///
  /// Fires when the user navigates to a different month. The [DateTime]
  /// represents the first day of the newly displayed month.
  final ValueChanged<DateTime>? onDisplayDateChanged;

  /// Callback invoked when the viewable date range changes.
  ///
  /// Fires when the visible date range changes, such as when navigating
  /// between months. The [DateTimeRange] represents the full range of
  /// dates currently visible in the view.
  final ValueChanged<DateTimeRange>? onViewableRangeChanged;

  /// Callback invoked when the focused date changes.
  ///
  /// Fires when keyboard focus moves to a different cell. The [DateTime]
  /// represents the newly focused date, or null if no cell is focused.
  final ValueChanged<DateTime?>? onFocusedDateChanged;

  /// Callback invoked when the focused date range changes.
  ///
  /// Fires when keyboard focus moves to a different cell or when a range
  /// selection changes. The [DateTimeRange] represents the currently focused
  /// range, or null if no range is focused.
  final ValueChanged<DateTimeRange?>? onFocusedRangeChanged;

  // ============ Cell behavior ============

  /// Whether tapping a cell automatically sets focus to that cell.
  ///
  /// When true, tapping on a day cell will move keyboard focus to that cell,
  /// enabling subsequent keyboard navigation from that position.
  /// Defaults to true.
  final bool autoFocusOnCellTap;

  // ============ Overflow handling ============

  /// Callback invoked when the overflow indicator ("+N more") is tapped.
  ///
  /// Receives the [BuildContext] and [MCalOverflowTapDetails] containing the
  /// date of the cell, the complete list of events for that date, and the
  /// number of hidden events. Useful for showing a popup or expanding the
  /// view to show all events.
  final void Function(BuildContext, MCalOverflowTapDetails)? onOverflowTap;

  /// Callback invoked when the overflow indicator ("+N more") is long-pressed.
  ///
  /// Receives the [BuildContext] and [MCalOverflowTapDetails] containing the
  /// date of the cell, the complete list of events for that date, and the
  /// number of hidden events. Useful for showing a context menu or
  /// alternative interaction.
  final void Function(BuildContext, MCalOverflowTapDetails)?
  onOverflowLongPress;

  // ============ Animation ============

  /// Whether animations are enabled.
  ///
  /// When true, transitions between months and other state changes are
  /// animated. Set to false for reduced motion or performance reasons.
  /// Defaults to true.
  final bool enableAnimations;

  /// The duration for animations.
  ///
  /// Controls the duration of month transitions and other animated changes.
  /// Only used when [enableAnimations] is true.
  /// Defaults to 300 milliseconds.
  final Duration animationDuration;

  /// The curve for animations.
  ///
  /// Controls the easing curve for month transitions and other animated changes.
  /// Only used when [enableAnimations] is true.
  /// Defaults to [Curves.easeInOut].
  final Curve animationCurve;

  // ============ Event display ============

  /// The maximum number of event tiles to display before showing overflow.
  ///
  /// Events beyond this limit are represented by a "+N more" indicator.
  /// The overflow indicator shows when EITHER:
  /// - Number of events exceeds what fits by height, OR
  /// - Number of events exceeds this limit
  /// Defaults to 5.
  final int maxVisibleEventsPerDay;

  // ============ State builders ============

  /// Builder for the loading state widget.
  ///
  /// Called when events are being loaded from the controller. Return a custom
  /// widget to display during loading, such as a progress indicator.
  final Widget Function(BuildContext context)? loadingBuilder;

  /// Builder for the error state widget.
  ///
  /// Called when event loading fails. Receives the [BuildContext] and
  /// [MCalErrorDetails] containing the error object and a retry callback.
  /// Return a custom widget to display the error with an option to retry.
  final Widget Function(BuildContext, MCalErrorDetails)? errorBuilder;

  // ============ Week numbers ============

  /// Whether to display week numbers.
  ///
  /// When true, a column showing ISO week numbers is displayed on the
  /// leading edge of the calendar grid. Defaults to false.
  final bool showWeekNumbers;

  /// Builder callback for customizing week number cell rendering.
  ///
  /// Receives the build context and [MCalWeekNumberContext] with week data.
  /// Return a custom widget to override the default week number display.
  final Widget Function(
    BuildContext context,
    MCalWeekNumberContext weekContext,
  )?
  weekNumberBuilder;

  // ============ Accessibility ============

  /// Semantic label for the entire calendar widget.
  ///
  /// Used by screen readers to describe the calendar. If not provided,
  /// a default label will be generated based on the current month.
  final String? semanticsLabel;

  // ============ Multi-day event rendering ============

  /// Builder callback for customizing week row event layout.
  ///
  /// When provided, this builder has complete control over how events are
  /// positioned within each week row in Layer 2. It receives pre-wrapped
  /// builders that include interaction handlers.
  ///
  /// If not provided, the default layout (greedy first-fit) is used.
  final MCalWeekLayoutBuilder? weekLayoutBuilder;

  /// Builder callback for customizing overflow indicator rendering.
  ///
  /// Receives the build context, [MCalOverflowIndicatorContext] with overflow data,
  /// and the default indicator widget. Return a custom widget to override the default.
  final Widget Function(BuildContext, MCalOverflowIndicatorContext, Widget)?
  overflowIndicatorBuilder;

  // ============ Drag-and-Drop ============

  /// Whether drag-and-drop functionality is enabled for event tiles.
  ///
  /// When true, event tiles can be dragged to other day cells using a
  /// long-press gesture. Day cells become drop targets that accept events.
  ///
  /// Defaults to false.
  final bool enableDragAndDrop;

  /// Builder callback for customizing the dragged tile feedback widget.
  ///
  /// When provided, this builder creates the visual representation of the
  /// tile while it's being dragged. Receives [MCalDraggedTileDetails] with
  /// the event, source date, and current drag position.
  ///
  /// If not provided, the default feedback is the tile with elevation.
  ///
  /// Only used when [enableDragAndDrop] is true.
  final Widget Function(BuildContext, MCalDraggedTileDetails)?
  draggedTileBuilder;

  /// Builder callback for customizing the drag source placeholder widget.
  ///
  /// When provided, this builder creates the placeholder widget shown at
  /// the original tile position while dragging. Receives [MCalDragSourceDetails]
  /// with the event and source date.
  ///
  /// If not provided, the default placeholder is the tile with 50% opacity.
  ///
  /// Only used when [enableDragAndDrop] is true.
  final Widget Function(BuildContext, MCalDragSourceDetails)?
  dragSourceTileBuilder;

  /// Builder callback for customizing the drag target preview widget.
  ///
  /// When provided, this builder creates a preview widget shown when
  /// hovering over a potential drop target. Receives [MCalDragTargetDetails]
  /// with the event, target date, and validity state.
  ///
  /// Only used when [enableDragAndDrop] is true.
  final Widget Function(BuildContext, MCalDragTargetDetails)?
  dragTargetTileBuilder;

  /// Builder callback for customizing drop target cell appearance.
  ///
  /// When provided, this builder customizes how individual cells appear during
  /// drag when they are potential drop targets. Receives [MCalDropTargetCellDetails]
  /// with the cell date, bounds, validity state, and position flags.
  ///
  /// This builder has lower precedence than [dropTargetOverlayBuilder]. If both
  /// are provided, [dropTargetOverlayBuilder] takes precedence.
  ///
  /// If neither builder is provided, the default [CustomPainter] implementation
  /// draws colored rounded rectangles for each highlighted cell.
  ///
  /// Only used when [enableDragAndDrop] is true.
  final Widget Function(BuildContext, MCalDropTargetCellDetails)?
  dropTargetCellBuilder;

  /// Builder callback for creating a custom drop target overlay.
  ///
  /// When provided, this builder has precedence over [dropTargetCellBuilder]
  /// and the default CustomPainter implementation. It receives
  /// [MCalDropOverlayDetails] with the complete list of highlighted cells,
  /// validity state, and calendar dimensions.
  ///
  /// Use this for advanced customization scenarios where you need full control
  /// over the highlight rendering, such as drawing connected highlights or
  /// custom animations.
  ///
  /// Only used when [enableDragAndDrop] is true.
  final Widget Function(BuildContext, MCalDropOverlayDetails)?
  dropTargetOverlayBuilder;

  /// Callback to validate whether a drop should be accepted.
  ///
  /// Called when an event is being dragged over a cell. Receives
  /// [MCalDragWillAcceptDetails] with the event and proposed new dates.
  /// Return true to accept the drop, false to reject it.
  ///
  /// If not provided, all drops are accepted by default.
  ///
  /// Only used when [enableDragAndDrop] is true.
  final bool Function(BuildContext, MCalDragWillAcceptDetails)?
  onDragWillAccept;

  /// Callback invoked when an event is dropped on a new date.
  ///
  /// Called after a successful drop. Receives [MCalEventDroppedDetails]
  /// with the event and both old and new dates.
  ///
  /// Return true to confirm the drop, or false to revert the event to
  /// its original position (useful if a backend update fails).
  ///
  /// Only used when [enableDragAndDrop] is true.
  final bool Function(BuildContext, MCalEventDroppedDetails)? onEventDropped;

  /// Whether edge navigation is enabled during drag operations.
  ///
  /// When true, dragging an event tile near the left or right edge of the
  /// calendar will trigger navigation to the previous or next month after
  /// [dragEdgeNavigationDelay].
  ///
  /// When false, edge navigation is disabled and the user must manually
  /// navigate to drop events on other months.
  ///
  /// Defaults to true.
  ///
  /// Only used when [enableDragAndDrop] is true.
  final bool dragEdgeNavigationEnabled;

  /// The delay before edge navigation triggers during drag operations.
  ///
  /// When the user drags an event tile near the left or right edge of the
  /// calendar, a timer starts. If the drag position remains near the edge
  /// for this duration, the calendar navigates to the previous or next month.
  ///
  /// This enables seamless cross-month drag-and-drop operations without
  /// requiring the user to manually navigate.
  ///
  /// Defaults to 1200 milliseconds.
  ///
  /// Only used when [enableDragAndDrop] and [dragEdgeNavigationEnabled] are true.
  final Duration dragEdgeNavigationDelay;

  /// Creates a new [MCalMonthView] widget.
  ///
  /// The [controller] parameter is required. All other parameters are optional.
  const MCalMonthView({
    super.key,
    required this.controller,
    this.minDate,
    this.maxDate,
    this.firstDayOfWeek,
    this.showNavigator = false,
    this.enableSwipeNavigation = false,
    this.swipeNavigationDirection = MCalSwipeNavigationDirection.horizontal,
    this.dayCellBuilder,
    this.eventTileBuilder,
    this.dayHeaderBuilder,
    this.navigatorBuilder,
    this.dateLabelBuilder,
    this.cellInteractivityCallback,
    this.onCellTap,
    this.onCellLongPress,
    this.onDateLabelTap,
    this.onDateLabelLongPress,
    this.onEventTap,
    this.onEventLongPress,
    this.onSwipeNavigation,
    this.dateFormat,
    this.locale,
    // Hover callbacks
    this.onHoverCell,
    this.onHoverEvent,
    // Keyboard navigation
    this.enableKeyboardNavigation = true,
    // Navigation callbacks
    this.onDisplayDateChanged,
    this.onViewableRangeChanged,
    this.onFocusedDateChanged,
    this.onFocusedRangeChanged,
    // Cell behavior
    this.autoFocusOnCellTap = true,
    // Overflow handling
    this.onOverflowTap,
    this.onOverflowLongPress,
    // Animation
    this.enableAnimations = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    // Event display
    this.maxVisibleEventsPerDay = 5,
    // State builders
    this.loadingBuilder,
    this.errorBuilder,
    // Week numbers
    this.showWeekNumbers = false,
    this.weekNumberBuilder,
    // Accessibility
    this.semanticsLabel,
    // Week layout customization
    this.weekLayoutBuilder,
    this.overflowIndicatorBuilder,
    // Drag-and-drop
    this.enableDragAndDrop = false,
    this.draggedTileBuilder,
    this.dragSourceTileBuilder,
    this.dragTargetTileBuilder,
    this.dropTargetCellBuilder,
    this.dropTargetOverlayBuilder,
    this.onDragWillAccept,
    this.onEventDropped,
    this.dragEdgeNavigationEnabled = true,
    this.dragEdgeNavigationDelay = const Duration(milliseconds: 1200),
  });

  @override
  State<MCalMonthView> createState() => _MCalMonthViewState();
}

/// State class for [MCalMonthView].
class _MCalMonthViewState extends State<MCalMonthView> {
  /// List of events for the current month.
  List<MCalCalendarEvent> _events = [];

  /// Whether events are currently being loaded.
  bool _isLoadingEvents = false;

  /// Tracks the previous display date to detect changes.
  DateTime? _previousDisplayDate;

  /// Tracks the previous focused date to detect changes.
  DateTime? _previousFocusedDate;

  /// Focus node for keyboard navigation.
  late FocusNode _focusNode;

  // ============================================================
  // PageView Controller and State (Task 8)
  // ============================================================

  /// The page controller for PageView-based navigation.
  ///
  /// Initialized with a large initial page (10000) to enable "infinite"
  /// scrolling in both directions while keeping the index positive.
  late PageController _pageController;

  /// The initial page index used as the "center" for the current month.
  ///
  /// This is a large number (10000) that serves as the reference point.
  /// Page 10000 corresponds to the initial month when the widget is created.
  static const int _initialPageIndex = 10000;

  /// The reference month (first day) that corresponds to _initialPageIndex.
  ///
  /// This is set during initState and used for page index ↔ month conversion.
  late DateTime _referenceMonth;

  /// Whether we're currently programmatically changing the page.
  ///
  /// Used to prevent recursive updates when the controller triggers navigation
  /// that updates the PageView, which would then trigger onPageChanged.
  bool _isProgrammaticPageChange = false;

  // ============================================================
  // Drag-and-Drop State (Task 20 & 21)
  // ============================================================

  /// The drag handler for managing drag-and-drop state.
  ///
  /// Created lazily when drag-and-drop is enabled. Manages drag lifecycle,
  /// edge navigation timers, and state cleanup on cancellation.
  MCalDragHandler? _dragHandler;

  /// Gets or creates the drag handler instance.
  ///
  /// The handler is created lazily to avoid overhead when drag-and-drop
  /// is not enabled.
  MCalDragHandler get _ensureDragHandler {
    _dragHandler ??= MCalDragHandler();
    return _dragHandler!;
  }

  /// Whether a drag operation is currently active.
  ///
  /// Used to determine whether to check for edge proximity.
  bool _isDragActive = false;

  /// The edge proximity threshold in logical pixels.
  ///
  /// When the drag position is within this distance from the left or right
  /// edge of the calendar, edge navigation is triggered after the delay.
  static const double _edgeProximityThreshold = 50.0;

  // ============================================================
  // Boundary Calculation Methods (Task 9)
  // ============================================================

  /// Calculates the minimum page index based on minDate.
  ///
  /// Returns null if there's no minDate constraint.
  int? get _minPageIndex {
    if (widget.minDate == null) return null;
    final minMonth = DateTime(widget.minDate!.year, widget.minDate!.month, 1);
    return _monthToPageIndex(minMonth);
  }

  /// Calculates the maximum page index based on maxDate.
  ///
  /// Returns null if there's no maxDate constraint.
  int? get _maxPageIndex {
    if (widget.maxDate == null) return null;
    final maxMonth = DateTime(widget.maxDate!.year, widget.maxDate!.month, 1);
    return _monthToPageIndex(maxMonth);
  }

  /// Checks if the given page index is within the allowed boundaries.
  bool _isPageIndexWithinBounds(int pageIndex) {
    final minIdx = _minPageIndex;
    final maxIdx = _maxPageIndex;

    if (minIdx != null && pageIndex < minIdx) return false;
    if (maxIdx != null && pageIndex > maxIdx) return false;
    return true;
  }

  /// Gets the current month from the controller's display date.
  DateTime get _currentMonth {
    final displayDate = widget.controller.displayDate;
    return DateTime(displayDate.year, displayDate.month, 1);
  }

  @override
  void initState() {
    super.initState();

    // Initialize focus node for keyboard navigation
    _focusNode = FocusNode(debugLabel: 'MCalMonthView');

    // Initialize tracking variables
    _previousDisplayDate = _currentMonth;
    _previousFocusedDate = widget.controller.focusedDate;

    // Initialize PageView controller for swipe navigation (Task 8)
    // Set the reference month to the current display date
    _referenceMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    _pageController = PageController(initialPage: _initialPageIndex);

    // Load initial events
    _loadEvents();

    // Subscribe to controller changes
    widget.controller.addListener(_onControllerChanged);

    // Fire initial callbacks after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fireViewableRangeChanged();
    });
  }

  @override
  void dispose() {
    // Remove controller listener
    widget.controller.removeListener(_onControllerChanged);
    // Dispose focus node
    _focusNode.dispose();
    // Dispose page controller (Task 8)
    _pageController.dispose();
    // Dispose drag handler if created (Task 21)
    _dragHandler?.dispose();
    super.dispose();
  }

  // ============================================================
  // Page Index ↔ Month Conversion Methods (Task 8)
  // ============================================================

  /// Converts a page index to the corresponding month DateTime.
  ///
  /// The page at [_initialPageIndex] corresponds to [_referenceMonth].
  /// Each page offset of +1 represents the next month, and -1 the previous.
  DateTime _pageIndexToMonth(int pageIndex) {
    final offset = pageIndex - _initialPageIndex;
    // Calculate the target month by adding the offset in months
    final referenceMonths =
        _referenceMonth.year * 12 + _referenceMonth.month - 1;
    final targetMonths = referenceMonths + offset;
    final targetYear = targetMonths ~/ 12;
    final targetMonth = (targetMonths % 12) + 1;
    return DateTime(targetYear, targetMonth, 1);
  }

  /// Converts a month DateTime to the corresponding page index.
  ///
  /// The month matching [_referenceMonth] returns [_initialPageIndex].
  /// Each month forward adds 1, each month backward subtracts 1.
  int _monthToPageIndex(DateTime month) {
    final referenceMonths =
        _referenceMonth.year * 12 + _referenceMonth.month - 1;
    final targetMonths = month.year * 12 + month.month - 1;
    return _initialPageIndex + (targetMonths - referenceMonths);
  }

  /// Called when the PageView page changes due to user swipe.
  ///
  /// Updates the controller's displayDate and fires the onSwipeNavigation callback.
  /// Respects minDate/maxDate boundaries - prevents navigation beyond allowed range.
  void _onPageChanged(int pageIndex) {
    // Skip if this is a programmatic change to avoid recursive updates
    if (_isProgrammaticPageChange) return;

    // Task 9: Boundary detection - check if new page is within allowed range
    if (!_isPageIndexWithinBounds(pageIndex)) {
      // Snap back to the nearest valid page
      final minIdx = _minPageIndex;
      final maxIdx = _maxPageIndex;

      int targetPage = pageIndex;
      if (minIdx != null && pageIndex < minIdx) {
        targetPage = minIdx;
      } else if (maxIdx != null && pageIndex > maxIdx) {
        targetPage = maxIdx;
      }

      // Programmatically jump back to the valid page
      if (_pageController.hasClients && targetPage != pageIndex) {
        _isProgrammaticPageChange = true;
        _pageController.jumpToPage(targetPage);
        _isProgrammaticPageChange = false;
      }
      return;
    }

    final newMonth = _pageIndexToMonth(pageIndex);
    final previousMonth = _currentMonth;

    // Skip if same month (shouldn't happen but be safe)
    if (newMonth.year == previousMonth.year &&
        newMonth.month == previousMonth.month) {
      return;
    }

    // Determine swipe direction for callback
    // AxisDirection.left = swiped left (navigating to next month)
    // AxisDirection.right = swiped right (navigating to previous month)
    final axisDirection = newMonth.isAfter(previousMonth)
        ? AxisDirection.left
        : AxisDirection.right;

    // Update the controller's display date (this triggers _onControllerChanged)
    widget.controller.setDisplayDate(newMonth);

    // Fire the swipe navigation callback
    if (widget.onSwipeNavigation != null) {
      widget.onSwipeNavigation!(
        context,
        MCalSwipeNavigationDetails(
          previousMonth: previousMonth,
          newMonth: newMonth,
          direction: axisDirection,
        ),
      );
    }
  }

  /// Handles controller change notifications.
  ///
  /// Called when the [MCalEventController] notifies listeners of changes.
  /// Reacts to displayDate and focusedDate changes.
  void _onControllerChanged() {
    if (!mounted) return;

    final currentDisplayDate = _currentMonth;
    final currentFocusedDate = widget.controller.focusedDate;

    // Check if display date changed
    final displayDateChanged =
        _previousDisplayDate == null ||
        currentDisplayDate.year != _previousDisplayDate!.year ||
        currentDisplayDate.month != _previousDisplayDate!.month;

    // Check if focused date changed
    final focusedDateChanged = _previousFocusedDate != currentFocusedDate;

    if (displayDateChanged) {
      _previousDisplayDate = currentDisplayDate;

      // Sync PageView to the new month if needed (Task 8)
      // This handles external navigation from the controller
      _syncPageViewToMonth(currentDisplayDate);

      // Fire onDisplayDateChanged callback
      widget.onDisplayDateChanged?.call(currentDisplayDate);

      // Fire onViewableRangeChanged callback
      _fireViewableRangeChanged();

      // Announce month change for accessibility
      _announceMonthChange(currentDisplayDate);

      // Reload events for new month
      _loadEvents();
    }

    if (focusedDateChanged) {
      _previousFocusedDate = currentFocusedDate;

      // Fire onFocusedDateChanged callback
      widget.onFocusedDateChanged?.call(currentFocusedDate);

      // Fire onFocusedRangeChanged callback (single date range when focused)
      if (currentFocusedDate != null) {
        final focusedRange = DateTimeRange(
          start: DateTime(
            currentFocusedDate.year,
            currentFocusedDate.month,
            currentFocusedDate.day,
          ),
          end: DateTime(
            currentFocusedDate.year,
            currentFocusedDate.month,
            currentFocusedDate.day,
            23,
            59,
            59,
            999,
          ),
        );
        widget.onFocusedRangeChanged?.call(focusedRange);
      } else {
        widget.onFocusedRangeChanged?.call(null);
      }
    }

    // Update events when controller changes.
    // Use post-frame callback if we're in a build phase to avoid
    // "setState during build" errors when multiple widgets share a controller.
    _scheduleSetState(() {
      _events = _getEventsForMonth(_currentMonth);
    });
  }

  /// Syncs the PageView to display the specified month.
  ///
  /// Called when the controller's displayDate changes externally.
  /// Uses animateToPage or jumpToPage based on the controller's animation flag.
  void _syncPageViewToMonth(DateTime month) {
    // Don't sync if PageController isn't attached yet
    if (!_pageController.hasClients) return;

    final targetPageIndex = _monthToPageIndex(month);
    final currentPageIndex = _pageController.page?.round() ?? _initialPageIndex;

    // Skip if already on the correct page
    if (targetPageIndex == currentPageIndex) return;

    // Check the controller's animation flag
    final shouldAnimate = widget.controller.shouldAnimateNextChange;
    widget.controller.consumeAnimationFlag();

    // Mark as programmatic to prevent recursive updates from onPageChanged
    _isProgrammaticPageChange = true;

    if (shouldAnimate && widget.enableAnimations) {
      _pageController
          .animateToPage(
            targetPageIndex,
            duration: widget.animationDuration,
            curve: widget.animationCurve,
          )
          .then((_) {
            _isProgrammaticPageChange = false;
          });
    } else {
      _pageController.jumpToPage(targetPageIndex);
      _isProgrammaticPageChange = false;
    }
  }

  /// Safely schedules a setState, deferring to post-frame if in build phase.
  void _scheduleSetState(VoidCallback fn) {
    if (!mounted) return;

    final phase = SchedulerBinding.instance.schedulerPhase;
    final isBuildPhase =
        phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks;

    if (isBuildPhase) {
      // Defer to next frame to avoid setState during build
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(fn);
        }
      });
    } else {
      setState(fn);
    }
  }

  /// Fires the onViewableRangeChanged callback with the current month's range.
  void _fireViewableRangeChanged() {
    final monthRange = getMonthRange(_currentMonth);
    widget.onViewableRangeChanged?.call(monthRange);
  }

  /// Announces month change for screen readers.
  ///
  /// Uses [SemanticsService.sendAnnouncement] to notify screen reader users
  /// when the displayed month changes (e.g., "January 2026").
  void _announceMonthChange(DateTime month) {
    final locale = widget.locale ?? Localizations.localeOf(context);
    final localizations = MCalLocalizations();
    final monthYearText = localizations.formatMonthYear(month, locale);

    // Announce the new month to screen readers
    // Use sendAnnouncement for compatibility with multiple windows
    final view = View.of(context);
    SemanticsService.sendAnnouncement(view, monthYearText, TextDirection.ltr);
  }

  /// Loads events for the current month plus previous and next months.
  ///
  /// Requests events from the controller for a 3-month range to enable
  /// smooth navigation and pre-loading. Only events for the current month
  /// are stored in state.
  Future<void> _loadEvents() async {
    if (_isLoadingEvents) return;

    setState(() {
      _isLoadingEvents = true;
    });

    try {
      // Get date ranges for current, previous, and next months
      final previousRange = getPreviousMonthRange(_currentMonth);
      final nextRange = getNextMonthRange(_currentMonth);

      // Request events for the entire 3-month range
      // This enables smooth navigation and pre-loading
      await widget.controller.loadEvents(previousRange.start, nextRange.end);

      // Filter events for current month only
      if (mounted) {
        setState(() {
          _events = _getEventsForMonth(_currentMonth);
          _isLoadingEvents = false;
        });
      }
    } catch (e) {
      // Handle error - for now, just mark as not loading
      // Error handling will be enhanced in later tasks
      if (mounted) {
        setState(() {
          _isLoadingEvents = false;
        });
      }
    }
  }

  /// Gets events for a specific month's visible grid from the controller.
  ///
  /// Filters events from the controller's loaded events that fall within
  /// the visible grid range (including leading/trailing days from adjacent months).
  /// This ensures events are correctly displayed on all visible cells, not just
  /// cells within the calendar month.
  List<MCalCalendarEvent> _getEventsForMonth(DateTime month) {
    final firstDayOfWeek = widget.firstDayOfWeek ?? _getDefaultFirstDayOfWeek();
    final gridRange = getVisibleGridRange(month, firstDayOfWeek);
    return widget.controller.getEventsForRange(gridRange);
  }

  /// Gets the default first day of week based on locale.
  ///
  /// Returns 0 for Sunday, 1 for Monday, etc.
  /// Defaults to Sunday (0) if locale is not available.
  int _getDefaultFirstDayOfWeek() {
    // For now, default to Sunday (0)
    // In a full implementation, this would use locale-specific defaults
    // (e.g., Monday for most European locales)
    return widget.firstDayOfWeek ?? 0;
  }

  /// Builds the month grid with PageView for swipe navigation.
  ///
  /// Uses PageView.builder for "infinite" scrolling navigation with peek preview.
  /// The [resolvedTheme] and [resolvedLocale] are passed from build()
  /// to avoid resolving them multiple times.
  ///
  /// Task 9: Implements boundary handling for minDate/maxDate constraints:
  /// - Uses custom scroll physics for bounce-back at boundaries
  /// - Uses finite itemCount when both bounds are set
  /// - Uses semi-infinite or infinite when only one or no bounds are set
  Widget _buildMonthGridWithRTL(
    BuildContext context,
    MCalThemeData resolvedTheme,
    Locale resolvedLocale,
  ) {
    final localizations = MCalLocalizations();
    final isRTL = localizations.isRTL(resolvedLocale);

    // Task 9: Determine scroll physics based on swipe navigation setting and boundaries
    final ScrollPhysics physics;
    if (widget.enableSwipeNavigation) {
      // Use custom boundary physics with snappy (non-bouncy) page snapping
      physics = _MCalBoundaryScrollPhysics(
        parent: const _MCalSnappyPageScrollPhysics(),
        minPageIndex: _minPageIndex,
        maxPageIndex: _maxPageIndex,
      );
    } else {
      // Disable swiping when navigation is disabled
      physics = const NeverScrollableScrollPhysics();
    }

    // Build the PageView for month navigation
    // Note: We use "infinite" scrolling (no itemCount) and rely on custom physics
    // and onPageChanged boundary checks to enforce minDate/maxDate limits.
    // This approach preserves our 10000-based offset indexing system.
    Widget pageView = PageView.builder(
      controller: _pageController,
      physics: physics,
      onPageChanged: _onPageChanged,
      // Determine scroll direction based on swipe navigation direction setting
      scrollDirection:
          widget.swipeNavigationDirection ==
              MCalSwipeNavigationDirection.vertical
          ? Axis.vertical
          : Axis.horizontal,
      // Reverse for RTL languages when horizontal
      reverse:
          isRTL &&
          widget.swipeNavigationDirection ==
              MCalSwipeNavigationDirection.horizontal,
      itemBuilder: (context, pageIndex) {
        // Convert page index to month and build the grid for that month
        final month = _pageIndexToMonth(pageIndex);
        return _MonthPageWidget(
          month: month,
          currentDisplayMonth: _currentMonth,
          events: _events,
          theme: resolvedTheme,
          locale: resolvedLocale,
          controller: widget.controller,
          firstDayOfWeek: _getDefaultFirstDayOfWeek(),
          dayCellBuilder: widget.dayCellBuilder,
          eventTileBuilder: widget.eventTileBuilder,
          dateLabelBuilder: widget.dateLabelBuilder,
          dateFormat: widget.dateFormat,
          cellInteractivityCallback: widget.cellInteractivityCallback,
          onCellTap: widget.onCellTap,
          onCellLongPress: widget.onCellLongPress,
          onDateLabelTap: widget.onDateLabelTap,
          onDateLabelLongPress: widget.onDateLabelLongPress,
          onEventTap: widget.onEventTap,
          onEventLongPress: widget.onEventLongPress,
          onHoverCell: widget.onHoverCell,
          onHoverEvent: widget.onHoverEvent,
          maxVisibleEventsPerDay: widget.maxVisibleEventsPerDay,
          onOverflowTap: widget.onOverflowTap,
          onOverflowLongPress: widget.onOverflowLongPress,
          showWeekNumbers: widget.showWeekNumbers,
          weekNumberBuilder: widget.weekNumberBuilder,
          autoFocusOnCellTap: widget.autoFocusOnCellTap,
          getEventsForMonth: _getEventsForMonth,
          // Week layout customization
          weekLayoutBuilder: widget.weekLayoutBuilder,
          overflowIndicatorBuilder: widget.overflowIndicatorBuilder,
          // Drag-and-drop
          enableDragAndDrop: widget.enableDragAndDrop,
          draggedTileBuilder: widget.draggedTileBuilder,
          dragSourceTileBuilder: widget.dragSourceTileBuilder,
          dragTargetTileBuilder: widget.dragTargetTileBuilder,
          dropTargetCellBuilder: widget.dropTargetCellBuilder,
          dropTargetOverlayBuilder: widget.dropTargetOverlayBuilder,
          onDragWillAccept: widget.onDragWillAccept,
          onEventDropped: widget.onEventDropped,
          dragEdgeNavigationEnabled: widget.dragEdgeNavigationEnabled,
          dragEdgeNavigationDelay: widget.dragEdgeNavigationDelay,
          onNavigateToPreviousMonth: _canNavigateToPreviousMonth()
              ? _navigateToPreviousMonth
              : null,
          onNavigateToNextMonth: _canNavigateToNextMonth()
              ? _navigateToNextMonth
              : null,
          // Drag lifecycle callbacks for cross-month navigation (Task 20)
          // and drag cancellation handling (Task 21)
          onDragStartedCallback: _handleDragStarted,
          onDragEndedCallback: _handleDragEnded,
          onDragCanceledCallback: _handleDragCancelled,
          dragHandler: widget.enableDragAndDrop ? _ensureDragHandler : null,
        );
      },
    );

    // Wrap in Directionality for RTL support
    final textDirection = isRTL ? TextDirection.rtl : TextDirection.ltr;
    return Directionality(textDirection: textDirection, child: pageView);
  }

  /// Resolves the calendar theme from context.
  ///
  /// Uses the fallback chain in [MCalTheme.of]:
  /// 1. [MCalTheme] ancestor widget
  /// 2. [Theme.of(context).extension<MCalThemeData>()]
  /// 3. [MCalThemeData.fromTheme(Theme.of(context))]
  MCalThemeData _resolveTheme(BuildContext context) {
    return MCalTheme.of(context);
  }

  @override
  Widget build(BuildContext context) {
    // Resolve theme and locale ONCE at the top of build() and pass down
    // to avoid multiple resolutions in child widgets
    final theme = _resolveTheme(context);
    final locale = widget.locale ?? Localizations.localeOf(context);
    final firstDayOfWeek = _getDefaultFirstDayOfWeek();

    // Build the main calendar content
    final calendarContent = Column(
      children: [
        if (widget.showNavigator)
          _NavigatorWidget(
            currentMonth: _currentMonth,
            minDate: widget.minDate,
            maxDate: widget.maxDate,
            theme: theme,
            navigatorBuilder: widget.navigatorBuilder,
            locale: locale,
            onPrevious: () => _navigateToPreviousMonth(),
            onNext: () => _navigateToNextMonth(),
            onToday: () => _navigateToToday(),
          ),
        _WeekdayHeaderRowWidget(
          firstDayOfWeek: firstDayOfWeek,
          theme: theme,
          dayHeaderBuilder: widget.dayHeaderBuilder,
          locale: locale,
          showWeekNumbers: widget.showWeekNumbers,
        ),
        Expanded(child: _buildMonthGridWithRTL(context, theme, locale)),
      ],
    );

    // Build overlay widgets based on controller state
    // Error takes precedence over loading
    Widget? overlay;
    if (widget.controller.hasError) {
      final error = widget.controller.error;
      final retryCallback = widget.controller.retryLoad;

      if (widget.errorBuilder != null) {
        overlay = widget.errorBuilder!(
          context,
          MCalErrorDetails(error: error!, onRetry: retryCallback),
        );
      } else {
        overlay = _ErrorOverlay(
          error: error,
          onRetry: retryCallback,
          theme: theme,
        );
      }
    } else if (widget.controller.isLoading) {
      if (widget.loadingBuilder != null) {
        overlay = widget.loadingBuilder!(context);
      } else {
        overlay = _LoadingOverlay(theme: theme);
      }
    }

    // Use Stack to layer overlays on top of the calendar
    final content = Stack(
      children: [calendarContent, if (overlay != null) overlay],
    );

    // Generate default semantics label if not provided
    final localizations = MCalLocalizations();
    final defaultSemanticsLabel =
        '${localizations.getLocalizedString('calendar', locale)}, ${localizations.formatMonthYear(_currentMonth, locale)}';
    final semanticsLabel = widget.semanticsLabel ?? defaultSemanticsLabel;

    // Wrap in Focus widget for keyboard navigation and drag cancellation (Task 21)
    // Use Listener to capture pointer events and request focus without
    // competing with child gesture detectors
    // Wrap entire widget tree with MCalTheme so descendants can access theme via MCalTheme.of(context)
    // Use LayoutBuilder to get the calendar size for edge detection during drag
    // Enable key events if keyboard navigation OR drag-and-drop is enabled
    // (drag-and-drop needs Escape key for cancellation)
    final enableKeyEvents =
        widget.enableKeyboardNavigation || widget.enableDragAndDrop;

    return MCalTheme(
      data: theme,
      child: Semantics(
        label: semanticsLabel,
        container: true,
        child: Focus(
          focusNode: _focusNode,
          onKeyEvent: enableKeyEvents ? _handleKeyEvent : null,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate the calendar size for edge detection
              final calendarSize = Size(
                constraints.maxWidth,
                constraints.maxHeight,
              );

              return Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (_) {
                  // Request focus when the calendar is tapped (Task 21)
                  // Focus is needed for keyboard navigation OR drag cancellation via Escape
                  if (enableKeyEvents && !_focusNode.hasFocus) {
                    _focusNode.requestFocus();
                  }
                },
                onPointerMove: (event) {
                  // Track pointer position during drag for edge detection
                  if (widget.enableDragAndDrop && _isDragActive) {
                    _handleDragPositionUpdate(event.position, calendarSize);
                  }
                },
                // Note: We intentionally don't use onPointerUp for drag cleanup.
                // LongPressDraggable.onDragEnd handles this with the correct
                // wasAccepted value. Using onPointerUp would cause duplicate
                // _handleDragEnded calls with incorrect wasAccepted=false.
                onPointerCancel: (_) {
                  // Clean up drag state when pointer is cancelled
                  if (_isDragActive) {
                    _handleDragCancelled();
                  }
                },
                child: content,
              );
            },
          ),
        ),
      ),
    );
  }

  /// Handles keyboard events for navigation and drag cancellation.
  ///
  /// Processes arrow keys, Home/End, Page Up/Down, and Enter/Space
  /// for keyboard-based calendar navigation. Also handles Escape key
  /// to cancel active drag operations.
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    // Only process key down events
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    // Handle Escape key for drag cancellation (Task 21)
    // This works even if keyboard navigation is disabled
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (widget.enableDragAndDrop && _isDragActive) {
        // Use the centralized handler to ensure all cleanup happens
        _handleDragCancelled();
        return KeyEventResult.handled;
      }
    }

    // Only process when keyboard navigation is enabled
    if (!widget.enableKeyboardNavigation) {
      return KeyEventResult.ignored;
    }

    // Get or initialize the focused date
    DateTime focusedDate =
        widget.controller.focusedDate ?? widget.controller.displayDate;

    // If no focused date was set, set it now
    if (widget.controller.focusedDate == null) {
      widget.controller.setFocusedDate(focusedDate);
    }

    final key = event.logicalKey;
    DateTime? newFocusedDate;
    bool handled = false;

    // Arrow key navigation
    if (key == LogicalKeyboardKey.arrowLeft) {
      newFocusedDate = focusedDate.subtract(const Duration(days: 1));
      handled = true;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      newFocusedDate = focusedDate.add(const Duration(days: 1));
      handled = true;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      newFocusedDate = focusedDate.subtract(const Duration(days: 7));
      handled = true;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      newFocusedDate = focusedDate.add(const Duration(days: 7));
      handled = true;
    }
    // Home - first day of current month
    else if (key == LogicalKeyboardKey.home) {
      newFocusedDate = DateTime(focusedDate.year, focusedDate.month, 1);
      handled = true;
    }
    // End - last day of current month
    else if (key == LogicalKeyboardKey.end) {
      newFocusedDate = DateTime(focusedDate.year, focusedDate.month + 1, 0);
      handled = true;
    }
    // Page Up - previous month
    else if (key == LogicalKeyboardKey.pageUp) {
      _navigateToPreviousMonth();
      // Move focus to same day in previous month (or last day if month is shorter)
      final prevMonth = focusedDate.month == 1
          ? DateTime(focusedDate.year - 1, 12, 1)
          : DateTime(focusedDate.year, focusedDate.month - 1, 1);
      final lastDayOfPrevMonth = DateTime(
        prevMonth.year,
        prevMonth.month + 1,
        0,
      ).day;
      final targetDay = focusedDate.day > lastDayOfPrevMonth
          ? lastDayOfPrevMonth
          : focusedDate.day;
      newFocusedDate = DateTime(prevMonth.year, prevMonth.month, targetDay);
      handled = true;
    }
    // Page Down - next month
    else if (key == LogicalKeyboardKey.pageDown) {
      _navigateToNextMonth();
      // Move focus to same day in next month (or last day if month is shorter)
      final nextMonth = focusedDate.month == 12
          ? DateTime(focusedDate.year + 1, 1, 1)
          : DateTime(focusedDate.year, focusedDate.month + 1, 1);
      final lastDayOfNextMonth = DateTime(
        nextMonth.year,
        nextMonth.month + 1,
        0,
      ).day;
      final targetDay = focusedDate.day > lastDayOfNextMonth
          ? lastDayOfNextMonth
          : focusedDate.day;
      newFocusedDate = DateTime(nextMonth.year, nextMonth.month, targetDay);
      handled = true;
    }
    // Enter/Space - trigger cell tap
    else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.numpadEnter) {
      _triggerCellTapForFocusedDate(focusedDate);
      return KeyEventResult.handled;
    }

    // If we have a new focused date, validate and apply it
    if (newFocusedDate != null && handled) {
      // Check minDate restriction
      if (widget.minDate != null) {
        final minDateNormalized = DateTime(
          widget.minDate!.year,
          widget.minDate!.month,
          widget.minDate!.day,
        );
        if (newFocusedDate.isBefore(minDateNormalized)) {
          return KeyEventResult.handled; // Don't move focus outside bounds
        }
      }

      // Check maxDate restriction
      if (widget.maxDate != null) {
        final maxDateNormalized = DateTime(
          widget.maxDate!.year,
          widget.maxDate!.month,
          widget.maxDate!.day,
        );
        if (newFocusedDate.isAfter(maxDateNormalized)) {
          return KeyEventResult.handled; // Don't move focus outside bounds
        }
      }

      // Update focused date
      widget.controller.setFocusedDate(newFocusedDate);

      // Auto-navigate if focus moves outside visible month
      final newFocusMonth = DateTime(
        newFocusedDate.year,
        newFocusedDate.month,
        1,
      );
      if (newFocusMonth.year != _currentMonth.year ||
          newFocusMonth.month != _currentMonth.month) {
        _navigateToMonth(newFocusMonth);
      }

      return KeyEventResult.handled;
    }

    return handled ? KeyEventResult.handled : KeyEventResult.ignored;
  }

  /// Triggers onCellTap callback for the focused date.
  void _triggerCellTapForFocusedDate(DateTime focusedDate) {
    // Get events for this date
    final dayEvents = _events.where((event) {
      final eventStart = DateTime(
        event.start.year,
        event.start.month,
        event.start.day,
      );
      final eventEnd = DateTime(event.end.year, event.end.month, event.end.day);
      final checkDate = DateTime(
        focusedDate.year,
        focusedDate.month,
        focusedDate.day,
      );
      return (checkDate.isAtSameMomentAs(eventStart) ||
          checkDate.isAtSameMomentAs(eventEnd) ||
          (checkDate.isAfter(eventStart) && checkDate.isBefore(eventEnd)));
    }).toList();

    // Determine if it's in the current month
    final isCurrentMonth =
        focusedDate.year == _currentMonth.year &&
        focusedDate.month == _currentMonth.month;

    // Fire the callback
    if (widget.onCellTap != null) {
      widget.onCellTap!(
        context,
        MCalCellTapDetails(
          date: focusedDate,
          events: dayEvents,
          isCurrentMonth: isCurrentMonth,
        ),
      );
    }
  }

  /// Navigates to a specific month.
  ///
  /// Validates that the month is within minDate/maxDate restrictions,
  /// updates the current month, notifies the controller, and loads events.
  /// Uses PageController for animated or instant navigation.
  void _navigateToMonth(DateTime month) {
    // Normalize to first day of month
    final targetMonth = DateTime(month.year, month.month, 1);

    // Check minDate restriction
    if (widget.minDate != null) {
      final minMonth = DateTime(widget.minDate!.year, widget.minDate!.month, 1);
      if (targetMonth.isBefore(minMonth)) {
        return; // Don't navigate if before minDate
      }
    }

    // Check maxDate restriction
    if (widget.maxDate != null) {
      final maxMonth = DateTime(widget.maxDate!.year, widget.maxDate!.month, 1);
      if (targetMonth.isAfter(maxMonth)) {
        return; // Don't navigate if after maxDate
      }
    }

    // Update the controller's display date (this triggers _onControllerChanged
    // which will sync the PageView via _syncPageViewToMonth)
    widget.controller.setDisplayDate(targetMonth);

    // Notify controller of new visible range
    try {
      final monthRange = getMonthRange(targetMonth);
      widget.controller.setVisibleDateRange(monthRange);
    } catch (e) {
      // Controller method may not be fully implemented yet
      // This is expected and will work when controller is complete
    }
  }

  /// Navigates to the previous month.
  void _navigateToPreviousMonth() {
    final previousMonth = _currentMonth.month == 1
        ? DateTime(_currentMonth.year - 1, 12, 1)
        : DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    _navigateToMonth(previousMonth);
  }

  /// Navigates to the next month.
  void _navigateToNextMonth() {
    final nextMonth = _currentMonth.month == 12
        ? DateTime(_currentMonth.year + 1, 1, 1)
        : DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    _navigateToMonth(nextMonth);
  }

  /// Navigates to the current month (today).
  void _navigateToToday() {
    final today = DateTime.now();
    _navigateToMonth(today);
  }

  // ============================================================
  // Cross-Month Drag Navigation (Task 20)
  // ============================================================

  /// Called when a drag operation starts on an event tile.
  ///
  /// Updates drag state tracking and prepares the drag handler.
  void _handleDragStarted(MCalCalendarEvent event, DateTime sourceDate) {
    if (!widget.enableDragAndDrop) return;

    _isDragActive = true;
    _ensureDragHandler.startDrag(event, sourceDate);
  }

  /// Called when a drag operation ends.
  ///
  /// Cleans up drag state and cancels any pending edge navigation.
  void _handleDragEnded(bool wasAccepted) {
    _isDragActive = false;
    // If the drop was accepted, _handleDrop already ran and cleaned up.
    // We only need to clean up for rejected drops (released outside valid target).
    if (!wasAccepted) {
      _dragHandler?.cancelDrag();
    }
  }

  /// Called when a drag operation is cancelled.
  ///
  /// Cleans up drag state and cancels any pending edge navigation.
  void _handleDragCancelled() {
    _isDragActive = false;
    _dragHandler?.cancelDrag();
  }

  /// Called when the drag position updates.
  ///
  /// Checks for edge proximity based on the current drag position.
  void _handleDragPositionUpdate(Offset globalPosition, Size calendarSize) {
    if (!widget.enableDragAndDrop || !_isDragActive) return;

    _checkEdgeProximity(globalPosition, calendarSize);
  }

  /// Checks if the drag position is near the left or right edge.
  ///
  /// If near an edge and navigation is allowed (within minDate/maxDate bounds),
  /// starts the edge navigation timer via the drag handler.
  void _checkEdgeProximity(Offset globalPosition, Size calendarSize) {
    if (!_isDragActive || _dragHandler == null) return;
    if (!widget.dragEdgeNavigationEnabled) return;

    // Get the local position within the calendar widget
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = renderBox.globalToLocal(globalPosition);

    // Check if near left edge
    final nearLeftEdge = localPosition.dx < _edgeProximityThreshold;

    // Check if near right edge
    final nearRightEdge =
        localPosition.dx > (calendarSize.width - _edgeProximityThreshold);

    final nearEdge = nearLeftEdge || nearRightEdge;

    if (nearEdge) {
      // Check boundary restrictions before allowing navigation
      if (nearLeftEdge) {
        // Check if we can navigate to previous month (minDate restriction)
        if (_canNavigateToPreviousMonth()) {
          _ensureDragHandler.handleEdgeProximity(
            true,
            true, // isLeftEdge
            _navigateToPreviousMonth,
            delay: widget.dragEdgeNavigationDelay,
          );
        } else {
          // At boundary, cancel any pending navigation
          _ensureDragHandler.handleEdgeProximity(false, true, () {});
        }
      } else if (nearRightEdge) {
        // Check if we can navigate to next month (maxDate restriction)
        if (_canNavigateToNextMonth()) {
          _ensureDragHandler.handleEdgeProximity(
            true,
            false, // isLeftEdge = false means right edge
            _navigateToNextMonth,
            delay: widget.dragEdgeNavigationDelay,
          );
        } else {
          // At boundary, cancel any pending navigation
          _ensureDragHandler.handleEdgeProximity(false, false, () {});
        }
      }
    } else {
      // Not near any edge, cancel pending navigation
      _ensureDragHandler.handleEdgeProximity(false, false, () {});
    }
  }

  /// Checks if navigation to previous month is allowed (minDate restriction).
  bool _canNavigateToPreviousMonth() {
    if (widget.minDate == null) return true;

    final previousMonth = _currentMonth.month == 1
        ? DateTime(_currentMonth.year - 1, 12, 1)
        : DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    final minMonth = DateTime(widget.minDate!.year, widget.minDate!.month, 1);

    return !previousMonth.isBefore(minMonth);
  }

  /// Checks if navigation to next month is allowed (maxDate restriction).
  bool _canNavigateToNextMonth() {
    if (widget.maxDate == null) return true;

    final nextMonth = _currentMonth.month == 12
        ? DateTime(_currentMonth.year + 1, 1, 1)
        : DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    final maxMonth = DateTime(widget.maxDate!.year, widget.maxDate!.month, 1);

    return !nextMonth.isAfter(maxMonth);
  }
}

/// Custom scroll physics for month view boundary handling.
///
/// Provides bounce-back behavior at minDate/maxDate boundaries while allowing
/// visual overscroll feedback. When at a boundary, the user can drag slightly
/// but the view will snap back instead of completing the page change.
class _MCalBoundaryScrollPhysics extends ScrollPhysics {
  /// The minimum allowed page index (based on minDate).
  final int? minPageIndex;

  /// The maximum allowed page index (based on maxDate).
  final int? maxPageIndex;

  /// The page controller's viewport fraction (typically 1.0).
  final double viewportFraction;

  const _MCalBoundaryScrollPhysics({
    super.parent,
    this.minPageIndex,
    this.maxPageIndex,
    this.viewportFraction = 1.0,
  });

  @override
  _MCalBoundaryScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _MCalBoundaryScrollPhysics(
      parent: buildParent(ancestor),
      minPageIndex: minPageIndex,
      maxPageIndex: maxPageIndex,
      viewportFraction: viewportFraction,
    );
  }

  /// Calculates the pixel position for a given page index.
  double _pageToPixels(int pageIndex, ScrollMetrics position) {
    return pageIndex * position.viewportDimension * viewportFraction;
  }

  /// Gets the minimum scroll extent based on minPageIndex.
  double? _getMinExtent(ScrollMetrics position) {
    if (minPageIndex == null) return null;
    return _pageToPixels(minPageIndex!, position);
  }

  /// Gets the maximum scroll extent based on maxPageIndex.
  double? _getMaxExtent(ScrollMetrics position) {
    if (maxPageIndex == null) return null;
    return _pageToPixels(maxPageIndex!, position);
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Get the calculated bounds
    final minExtent = _getMinExtent(position);
    final maxExtent = _getMaxExtent(position);

    // Check if we're trying to scroll before the minimum
    if (minExtent != null && value < minExtent) {
      // Return the amount of overscroll to clamp
      return value - minExtent;
    }

    // Check if we're trying to scroll past the maximum
    if (maxExtent != null && value > maxExtent) {
      // Return the amount of overscroll to clamp
      return value - maxExtent;
    }

    // No boundary conditions violated - allow the scroll
    return 0.0;
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // Get the calculated bounds
    final minExtent = _getMinExtent(position);
    final maxExtent = _getMaxExtent(position);

    // Check if we're out of bounds and need to snap back
    if (minExtent != null && position.pixels < minExtent) {
      // Snap back to minimum
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        minExtent,
        velocity,
      );
    }

    if (maxExtent != null && position.pixels > maxExtent) {
      // Snap back to maximum
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        maxExtent,
        velocity,
      );
    }

    // Use default page physics behavior
    return super.createBallisticSimulation(position, velocity);
  }

  /// Spring description for page settling animation.
  ///
  /// Uses a critically-damped spring for smooth settling without oscillation.
  /// Critical damping = 2 * sqrt(stiffness * mass)
  /// For mass=1.0, stiffness=100: critical damping ≈ 20
  /// Using slightly higher (over-damped) for faster settling.
  @override
  SpringDescription get spring =>
      const SpringDescription(mass: 1.0, stiffness: 100.0, damping: 20.0);
}

/// Custom page scroll physics with snappy (non-bouncy) settling and
/// lower threshold for page changes.
///
/// Extends [PageScrollPhysics] to provide page snapping behavior
/// while using a critically-damped spring to eliminate oscillation.
/// Also reduces the distance threshold needed to trigger a page change.
class _MCalSnappyPageScrollPhysics extends PageScrollPhysics {
  /// The fraction of the page width that must be dragged to trigger a page change.
  /// Default PageScrollPhysics uses ~0.5 (50%). We use 0.3 (30%) for easier swiping.
  static const double _pageChangeThreshold = 0.3;

  const _MCalSnappyPageScrollPhysics({super.parent});

  @override
  _MCalSnappyPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _MCalSnappyPageScrollPhysics(parent: buildParent(ancestor));
  }

  /// Uses a critically-damped spring for smooth, non-bouncy settling.
  @override
  SpringDescription get spring =>
      const SpringDescription(mass: 1.0, stiffness: 100.0, damping: 20.0);

  /// Lower the minimum fling velocity to make page changes easier with quick swipes.
  @override
  double get minFlingVelocity => 50.0; // Default is ~365

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // If there's no viewport, use default behavior
    if (position.viewportDimension == 0) {
      return super.createBallisticSimulation(position, velocity);
    }

    final double pageSize = position.viewportDimension;
    final double currentPage = position.pixels / pageSize;
    final int currentPageFloor = currentPage.floor();

    // Calculate how far into the current page we are (0.0 to 1.0)
    final double pageFraction = currentPage - currentPageFloor;

    // Determine target page based on velocity and position
    int targetPage;

    // If velocity is significant, use it to determine direction
    if (velocity.abs() > minFlingVelocity) {
      targetPage = velocity > 0 ? currentPageFloor + 1 : currentPageFloor;
    } else {
      // Use position-based threshold
      if (pageFraction > (1.0 - _pageChangeThreshold)) {
        // Crossed threshold to next page
        targetPage = currentPageFloor + 1;
      } else if (pageFraction < _pageChangeThreshold) {
        // Still on current page
        targetPage = currentPageFloor;
      } else {
        // In the middle - go to nearest page
        targetPage = currentPage.round();
      }
    }

    final double targetPixels = targetPage * pageSize;

    // If we're already at the target, no simulation needed
    if ((position.pixels - targetPixels).abs() < tolerance.distance) {
      return null;
    }

    // Create a spring simulation to the target
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      targetPixels,
      velocity,
      tolerance: tolerance,
    );
  }
}

/// Widget for rendering a single month page in the PageView.
///
/// This widget is used by [MCalMonthView]'s PageView.builder to render
/// each month's grid. It calculates and displays the dates for the given month.
class _MonthPageWidget extends StatefulWidget {
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

  /// First day of week (0 = Sunday, 1 = Monday, etc.).
  final int firstDayOfWeek;

  /// Builder callbacks
  final Widget Function(BuildContext, MCalDayCellContext, Widget)?
  dayCellBuilder;
  final Widget Function(BuildContext, MCalEventTileContext, Widget)?
  eventTileBuilder;
  final Widget Function(BuildContext, MCalDateLabelContext, String)?
  dateLabelBuilder;
  final String? dateFormat;
  final bool Function(BuildContext, MCalCellInteractivityDetails)?
  cellInteractivityCallback;
  final void Function(BuildContext, MCalCellTapDetails)? onCellTap;
  final void Function(BuildContext, MCalCellTapDetails)? onCellLongPress;
  final void Function(BuildContext, MCalDateLabelTapDetails)? onDateLabelTap;
  final void Function(BuildContext, MCalDateLabelTapDetails)?
  onDateLabelLongPress;
  final void Function(BuildContext, MCalEventTapDetails)? onEventTap;
  final void Function(BuildContext, MCalEventTapDetails)? onEventLongPress;
  final ValueChanged<MCalDayCellContext?>? onHoverCell;
  final ValueChanged<MCalEventTileContext?>? onHoverEvent;
  final int maxVisibleEventsPerDay;
  final void Function(BuildContext, MCalOverflowTapDetails)? onOverflowTap;
  final void Function(BuildContext, MCalOverflowTapDetails)?
  onOverflowLongPress;
  final bool showWeekNumbers;
  final Widget Function(BuildContext, MCalWeekNumberContext)? weekNumberBuilder;
  final bool autoFocusOnCellTap;

  /// Function to get events for a specific month.
  final List<MCalCalendarEvent> Function(DateTime month) getEventsForMonth;

  /// Builder callback for customizing week row event layout.
  final MCalWeekLayoutBuilder? weekLayoutBuilder;

  /// Builder callback for customizing overflow indicator rendering.
  final Widget Function(BuildContext, MCalOverflowIndicatorContext, Widget)?
  overflowIndicatorBuilder;

  // Drag-and-drop parameters
  final bool enableDragAndDrop;
  final Widget Function(BuildContext, MCalDraggedTileDetails)?
  draggedTileBuilder;
  final Widget Function(BuildContext, MCalDragSourceDetails)?
  dragSourceTileBuilder;
  final Widget Function(BuildContext, MCalDragTargetDetails)?
  dragTargetTileBuilder;
  final Widget Function(BuildContext, MCalDropTargetCellDetails)?
  dropTargetCellBuilder;
  final Widget Function(BuildContext, MCalDropOverlayDetails)?
  dropTargetOverlayBuilder;
  final bool Function(BuildContext, MCalDragWillAcceptDetails)?
  onDragWillAccept;
  final bool Function(BuildContext, MCalEventDroppedDetails)? onEventDropped;
  final bool dragEdgeNavigationEnabled;
  final Duration dragEdgeNavigationDelay;
  final VoidCallback? onNavigateToPreviousMonth;
  final VoidCallback? onNavigateToNextMonth;

  // Drag lifecycle callbacks (Task 21)
  final void Function(MCalCalendarEvent event, DateTime sourceDate)?
  onDragStartedCallback;
  final void Function(bool wasAccepted)? onDragEndedCallback;
  final VoidCallback? onDragCanceledCallback;

  /// The drag handler for coordinating drag state across week rows.
  final MCalDragHandler? dragHandler;

  const _MonthPageWidget({
    required this.month,
    required this.currentDisplayMonth,
    required this.events,
    required this.theme,
    required this.locale,
    required this.controller,
    required this.firstDayOfWeek,
    required this.getEventsForMonth,
    this.dayCellBuilder,
    this.eventTileBuilder,
    this.dateLabelBuilder,
    this.dateFormat,
    this.cellInteractivityCallback,
    this.onCellTap,
    this.onCellLongPress,
    this.onDateLabelTap,
    this.onDateLabelLongPress,
    this.onEventTap,
    this.onEventLongPress,
    this.onHoverCell,
    this.onHoverEvent,
    this.maxVisibleEventsPerDay = 5,
    this.onOverflowTap,
    this.onOverflowLongPress,
    this.showWeekNumbers = false,
    this.weekNumberBuilder,
    this.autoFocusOnCellTap = true,
    // Week layout customization
    this.weekLayoutBuilder,
    this.overflowIndicatorBuilder,
    // Drag-and-drop
    this.enableDragAndDrop = false,
    this.draggedTileBuilder,
    this.dragSourceTileBuilder,
    this.dragTargetTileBuilder,
    this.dropTargetCellBuilder,
    this.dropTargetOverlayBuilder,
    this.onDragWillAccept,
    this.onEventDropped,
    this.dragEdgeNavigationEnabled = true,
    this.dragEdgeNavigationDelay = const Duration(milliseconds: 1200),
    this.onNavigateToPreviousMonth,
    this.onNavigateToNextMonth,
    // Drag lifecycle callbacks (Task 21)
    this.onDragStartedCallback,
    this.onDragEndedCallback,
    this.onDragCanceledCallback,
    this.dragHandler,
  });

  @override
  State<_MonthPageWidget> createState() => _MonthPageWidgetState();
}

/// State class for [_MonthPageWidget].
///
/// Handles the unified DragTarget for the entire month grid.
class _MonthPageWidgetState extends State<_MonthPageWidget> {
  /// Cached dates for this month.
  late List<DateTime> _dates;

  /// Cached weeks for this month.
  late List<List<DateTime>> _weeks;

  /// Number of weeks in this month.
  int get _weeksInMonth => _weeks.length;

  // ============================================================
  // Cached Layout Values (for drag performance)
  // ============================================================

  /// Cached day width - updated when layout changes.
  double _cachedDayWidth = 0;

  /// Cached week row height - updated when layout changes.
  double _cachedWeekRowHeight = 0;

  /// Cached calendar size - updated when layout changes.
  Size _cachedCalendarSize = Size.zero;

  /// Cached calendar global offset - updated when layout changes.
  Offset _cachedCalendarOffset = Offset.zero;

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
    _computeDates();
    widget.dragHandler?.addListener(_onDragHandlerChanged);
  }

  @override
  void didUpdateWidget(_MonthPageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month != widget.month ||
        oldWidget.firstDayOfWeek != widget.firstDayOfWeek) {
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

  /// Called when drag handler state changes.
  void _onDragHandlerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Compute the dates and weeks for this month.
  void _computeDates() {
    _dates = generateMonthDates(widget.month, widget.firstDayOfWeek);
    _weeks = <List<DateTime>>[];
    for (int i = 0; i < _dates.length; i += 7) {
      _weeks.add(_dates.sublist(i, i + 7));
    }
  }

  /// Update cached layout values from render box.
  /// Called once at start of drag and when layout changes.
  void _updateLayoutCache(RenderBox renderBox) {
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    // Only update if changed
    if (size != _cachedCalendarSize || offset != _cachedCalendarOffset) {
      _cachedCalendarSize = size;
      _cachedCalendarOffset = offset;
      _cachedDayWidth = size.width / 7;
      _cachedWeekRowHeight = size.height / _weeksInMonth;
    }
  }

  /// Whether a drag is currently active.
  bool get _isDragActive => widget.dragHandler?.isDragging ?? false;

  /// Get week dates for a specific week row index.
  List<DateTime> _getWeekDates(int weekRowIndex) {
    if (weekRowIndex < 0 || weekRowIndex >= _weeks.length) return [];
    return _weeks[weekRowIndex];
  }

  /// Get bounds for a specific week row (uses cached values).
  Rect _getWeekRowBounds(int index) {
    return Rect.fromLTWH(
      0,
      index * _cachedWeekRowHeight,
      _cachedCalendarSize.width,
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

    // Call dragHandler.handleDragMove with cached/minimal parameters
    dragHandler.handleDragMove(
      globalPosition: Offset(pointerGlobalX, pointerGlobalY),
      dayWidth: _cachedDayWidth,
      grabOffsetX: dragData.grabOffsetX,
      eventDurationDays: _cachedEventDuration,
      weekRowIndex: weekRowIndex,
      weekRowBounds: Rect.fromLTWH(
        _cachedCalendarOffset.dx,
        _cachedCalendarOffset.dy + weekRowIndex * _cachedWeekRowHeight,
        _cachedCalendarSize.width,
        _cachedWeekRowHeight,
      ),
      calendarBounds: _cachedCalendarOffset & _cachedCalendarSize,
      weekDates: _getWeekDates(weekRowIndex),
      totalWeekRows: _weeksInMonth,
      getWeekRowBounds: _getWeekRowBounds,
      getWeekDates: _getWeekDates,
      validationCallback: widget.onDragWillAccept != null
          ? (start, end) => widget.onDragWillAccept!(
              context,
              MCalDragWillAcceptDetails(
                event: dragData.event,
                proposedStartDate: start,
                proposedEndDate: end,
              ),
            )
          : null,
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
  /// NOTE: We do NOT clear the proposed drop range here because onLeave
  /// fires BEFORE onAcceptWithDetails when a drop is accepted. The state
  /// is cleared in _handleDrop after processing the drop. For genuine
  /// drag-leave (user drags outside calendar), the highlights will remain
  /// briefly but will be cleared when the drag ends via the draggable's
  /// onDragEnd callback or when the next drag starts.
  void _handleDragLeave() {
    // Only clear visual highlights, not the proposed drop data.
    // The drop handler needs the proposed dates to complete the drop.
    // DO NOT call clearProposedDropRange() here - it would break drop handling
    // because DragTarget.onLeave fires BEFORE DragTarget.onAcceptWithDetails.
    widget.dragHandler?.clearHighlightedCells();
  }

  /// Handles drop events from the unified DragTarget.
  void _handleDrop(DragTargetDetails<MCalDragData> details) {
    final dragHandler = widget.dragHandler;

    // Cancel edge navigation immediately
    dragHandler?.cancelEdgeNavigation();

    // Flush any pending local debounce timer and process immediately
    if (_dragMoveDebounceTimer?.isActive ?? false) {
      _dragMoveDebounceTimer?.cancel();
      _processDragMove();
    }

    // Check if drop is valid
    if (dragHandler != null && !dragHandler.isProposedDropValid) {
      // Invalid drop - clean up and return
      dragHandler.clearHighlightedCells();
      dragHandler.clearProposedDropRange();
      return;
    }

    final dragData = details.data;
    final event = dragData.event;

    // Use the proposed dates from the drag handler if available.
    final proposedStart = dragHandler?.proposedStartDate;
    final proposedEnd = dragHandler?.proposedEndDate;

    if (proposedStart == null || proposedEnd == null) {
      // No valid proposed dates, can't complete drop
      dragHandler?.clearHighlightedCells();
      dragHandler?.clearProposedDropRange();
      return;
    }

    // Calculate new dates preserving time components
    final normalizedEventStart = DateTime(
      event.start.year,
      event.start.month,
      event.start.day,
    );
    final dayDelta = proposedStart.difference(normalizedEventStart).inDays;

    final newStartDate = DateTime(
      event.start.year,
      event.start.month,
      event.start.day + dayDelta,
      event.start.hour,
      event.start.minute,
      event.start.second,
      event.start.millisecond,
      event.start.microsecond,
    );
    final newEndDate = DateTime(
      event.end.year,
      event.end.month,
      event.end.day + dayDelta,
      event.end.hour,
      event.end.minute,
      event.end.second,
      event.end.millisecond,
      event.end.microsecond,
    );

    // Store old dates for potential revert
    final oldStartDate = event.start;
    final oldEndDate = event.end;

    // Create the updated event
    final updatedEvent = event.copyWith(start: newStartDate, end: newEndDate);

    // Update event in controller
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

    // Mark drag as complete - this clears all drag state including isDragging.
    // This prevents the microtask in _handleDragEnded from doing redundant cleanup.
    dragHandler?.cancelDrag();
  }

  // ============================================================
  // Highlight Overlay Builder
  // ============================================================

  /// Builds the highlight overlay for drop targets.
  ///
  /// Precedence: dropTargetOverlayBuilder > dropTargetCellBuilder > default CustomPainter
  Widget _buildLayer3HighlightOverlay(BuildContext context) {
    final dragHandler = widget.dragHandler;
    if (dragHandler == null) return const SizedBox.shrink();

    final highlightedCells = dragHandler.highlightedCells;
    if (highlightedCells.isEmpty) return const SizedBox.shrink();

    final isValid = dragHandler.isProposedDropValid;

    // Precedence: dropTargetOverlayBuilder > dropTargetCellBuilder > default
    if (widget.dropTargetOverlayBuilder != null) {
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
          );

      return widget.dropTargetOverlayBuilder!(
        context,
        MCalDropOverlayDetails(
          highlightedCells: highlightedCells,
          isValid: isValid,
          dayWidth: _cachedDayWidth,
          calendarSize: _cachedCalendarSize,
          dragData: dragData,
        ),
      );
    }

    if (widget.dropTargetCellBuilder != null) {
      return Stack(
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
    }

    // Default: CustomPainter (most performant)
    return CustomPaint(
      size: Size.infinite,
      painter: _DropTargetHighlightPainter(
        highlightedCells: highlightedCells,
        isValid: isValid,
        validColor:
            widget.theme.dragTargetValidColor ??
            Colors.green.withValues(alpha: 0.3),
        invalidColor:
            widget.theme.dragTargetInvalidColor ??
            Colors.red.withValues(alpha: 0.3),
        borderRadius: widget.theme.dragTargetBorderRadius ?? 4.0,
      ),
    );
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
      firstDayOfWeek: widget.firstDayOfWeek,
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
          child: _WeekRowWidget(
            dates: weekDates,
            currentMonth: widget.month,
            events: monthEvents,
            theme: widget.theme,
            focusedDate: widget.controller.focusedDate,
            autoFocusOnCellTap: widget.autoFocusOnCellTap,
            onSetFocusedDate: (date) {
              widget.controller.setFocusedDate(date);
            },
            dayCellBuilder: widget.dayCellBuilder,
            eventTileBuilder: widget.eventTileBuilder,
            dateLabelBuilder: widget.dateLabelBuilder,
            dateFormat: widget.dateFormat,
            cellInteractivityCallback: widget.cellInteractivityCallback,
            onCellTap: widget.onCellTap,
            onCellLongPress: widget.onCellLongPress,
            onDateLabelTap: widget.onDateLabelTap,
            onDateLabelLongPress: widget.onDateLabelLongPress,
            onEventTap: widget.onEventTap,
            onEventLongPress: widget.onEventLongPress,
            onHoverCell: widget.onHoverCell,
            onHoverEvent: widget.onHoverEvent,
            locale: widget.locale,
            maxVisibleEventsPerDay: widget.maxVisibleEventsPerDay,
            onOverflowTap: widget.onOverflowTap,
            onOverflowLongPress: widget.onOverflowLongPress,
            showWeekNumbers: widget.showWeekNumbers,
            weekNumberBuilder: widget.weekNumberBuilder,
            weekLayoutBuilder: widget.weekLayoutBuilder,
            overflowIndicatorBuilder: widget.overflowIndicatorBuilder,
            weekRowIndex: weekRowIndex,
            multiDayLayouts: weekLayouts,
            // Drag-and-drop - pass builders but NOT drop target handling
            enableDragAndDrop: widget.enableDragAndDrop,
            draggedTileBuilder: widget.draggedTileBuilder,
            dragSourceTileBuilder: widget.dragSourceTileBuilder,
            dragTargetTileBuilder: widget.dragTargetTileBuilder,
            dropTargetCellBuilder: widget.dropTargetCellBuilder,
            onDragWillAccept: widget.onDragWillAccept,
            onEventDropped: widget.onEventDropped,
            controller: widget.controller,
            onDragStartedCallback: widget.onDragStartedCallback,
            onDragEndedCallback: widget.onDragEndedCallback,
            onDragCanceledCallback: widget.onDragCanceledCallback,
            dragHandler: widget.dragHandler,
          ),
        );
      }).toList(),
    );

    // Wrap with unified DragTarget if drag-and-drop is enabled
    if (widget.enableDragAndDrop) {
      return DragTarget<MCalDragData>(
        onMove: _handleDragMove,
        onLeave: (_) => _handleDragLeave(),
        onAcceptWithDetails: _handleDrop,
        builder: (context, candidateData, rejectedData) {
          return Stack(
            children: [
              // Main content (week rows with grid and events)
              weekRowsColumn,

              // Highlight overlay (only when dragging)
              // RepaintBoundary prevents highlight changes from repainting calendar
              if (_isDragActive)
                Positioned.fill(
                  child: RepaintBoundary(
                    child: IgnorePointer(
                      child: _buildLayer3HighlightOverlay(context),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    }

    return weekRowsColumn;
  }
}

/// Widget for rendering a week number cell.
///
/// Displays the ISO week number for a given week. Supports custom rendering
/// via the optional [weekNumberBuilder] callback.
class _WeekNumberCell extends StatelessWidget {
  /// The ISO week number (1-53).
  final int weekNumber;

  /// The first day of this week.
  final DateTime firstDayOfWeek;

  /// The theme data for styling.
  final MCalThemeData theme;

  /// Optional builder for custom week number rendering.
  final Widget Function(BuildContext, MCalWeekNumberContext)? weekNumberBuilder;

  /// Fixed width for the week number column.
  static const double columnWidth = 36.0;

  const _WeekNumberCell({
    required this.weekNumber,
    required this.firstDayOfWeek,
    required this.theme,
    this.weekNumberBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // Create the context object
    final defaultFormattedString = 'W$weekNumber';
    final weekContext = MCalWeekNumberContext(
      weekNumber: weekNumber,
      firstDayOfWeek: firstDayOfWeek,
      defaultFormattedString: defaultFormattedString,
    );

    // Use custom builder if provided
    if (weekNumberBuilder != null) {
      return SizedBox(
        width: columnWidth,
        child: weekNumberBuilder!(context, weekContext),
      );
    }

    // Default rendering
    return Container(
      width: columnWidth,
      decoration: BoxDecoration(
        color: theme.weekNumberBackgroundColor,
        border: Border.all(
          color: theme.cellBorderColor ?? Colors.grey.shade300,
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          '$weekNumber',
          style:
              theme.weekNumberTextStyle ??
              TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ),
    );
  }
}

/// Loading overlay widget displayed during event loading.
///
/// Shows a semi-transparent background with a centered loading spinner.
/// The calendar grid remains visible underneath.
class _LoadingOverlay extends StatelessWidget {
  /// The theme for styling.
  final MCalThemeData theme;

  const _LoadingOverlay({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

/// Error overlay widget displayed when event loading fails.
///
/// Shows a semi-transparent background with a centered error message,
/// icon, and retry button. The calendar grid remains visible underneath.
class _ErrorOverlay extends StatelessWidget {
  /// The error that occurred.
  final Object? error;

  /// Callback to retry loading.
  final VoidCallback onRetry;

  /// The theme for styling.
  final MCalThemeData theme;

  const _ErrorOverlay({
    required this.error,
    required this.onRetry,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // Get error message - use string representation or generic message
    final errorMessage = error is String
        ? error as String
        : 'Failed to load events. Please try again.';

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style:
                        theme.cellTextStyle?.copyWith(fontSize: 14) ??
                        const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget for rendering a single week row in the calendar grid.
class _WeekRowWidget extends StatefulWidget {
  final List<DateTime> dates;
  final DateTime currentMonth;
  final List<MCalCalendarEvent> events;
  final MCalThemeData theme;
  final DateTime? focusedDate;
  final bool autoFocusOnCellTap;
  final ValueChanged<DateTime>? onSetFocusedDate;
  final Widget Function(BuildContext, MCalDayCellContext, Widget)?
  dayCellBuilder;
  final Widget Function(BuildContext, MCalEventTileContext, Widget)?
  eventTileBuilder;
  final Widget Function(BuildContext, MCalDateLabelContext, String)?
  dateLabelBuilder;
  final String? dateFormat;
  final bool Function(BuildContext, MCalCellInteractivityDetails)?
  cellInteractivityCallback;
  final void Function(BuildContext, MCalCellTapDetails)? onCellTap;
  final void Function(BuildContext, MCalCellTapDetails)? onCellLongPress;
  final void Function(BuildContext, MCalDateLabelTapDetails)? onDateLabelTap;
  final void Function(BuildContext, MCalDateLabelTapDetails)?
  onDateLabelLongPress;
  final void Function(BuildContext, MCalEventTapDetails)? onEventTap;
  final void Function(BuildContext, MCalEventTapDetails)? onEventLongPress;
  final ValueChanged<MCalDayCellContext?>? onHoverCell;
  final ValueChanged<MCalEventTileContext?>? onHoverEvent;
  final Locale locale;
  final int maxVisibleEventsPerDay;
  final void Function(BuildContext, MCalOverflowTapDetails)? onOverflowTap;
  final void Function(BuildContext, MCalOverflowTapDetails)?
  onOverflowLongPress;
  final bool showWeekNumbers;
  final Widget Function(BuildContext, MCalWeekNumberContext)? weekNumberBuilder;

  /// Builder callback for customizing week row event layout.
  final MCalWeekLayoutBuilder? weekLayoutBuilder;

  /// Builder callback for customizing overflow indicator rendering.
  final Widget Function(BuildContext, MCalOverflowIndicatorContext, Widget)?
  overflowIndicatorBuilder;

  /// The index of this week row within the month grid.
  final int weekRowIndex;

  /// Multi-day event layouts for this week row.
  final List<MCalMultiDayEventLayout>? multiDayLayouts;

  // Drag-and-drop parameters
  final bool enableDragAndDrop;
  final Widget Function(BuildContext, MCalDraggedTileDetails)?
  draggedTileBuilder;
  final Widget Function(BuildContext, MCalDragSourceDetails)?
  dragSourceTileBuilder;
  final Widget Function(BuildContext, MCalDragTargetDetails)?
  dragTargetTileBuilder;
  final Widget Function(BuildContext, MCalDropTargetCellDetails)?
  dropTargetCellBuilder;
  final bool Function(BuildContext, MCalDragWillAcceptDetails)?
  onDragWillAccept;
  final bool Function(BuildContext, MCalEventDroppedDetails)? onEventDropped;
  final MCalEventController controller;

  // Drag lifecycle callbacks (Task 21)
  final void Function(MCalCalendarEvent event, DateTime sourceDate)?
  onDragStartedCallback;
  final void Function(bool wasAccepted)? onDragEndedCallback;
  final VoidCallback? onDragCanceledCallback;

  /// The drag handler for coordinating drag state across week rows.
  final MCalDragHandler? dragHandler;

  const _WeekRowWidget({
    required this.dates,
    required this.currentMonth,
    required this.events,
    required this.theme,
    this.focusedDate,
    this.autoFocusOnCellTap = true,
    this.onSetFocusedDate,
    this.dayCellBuilder,
    this.eventTileBuilder,
    this.dateLabelBuilder,
    this.dateFormat,
    this.cellInteractivityCallback,
    this.onCellTap,
    this.onCellLongPress,
    this.onDateLabelTap,
    this.onDateLabelLongPress,
    this.onEventTap,
    this.onEventLongPress,
    this.onHoverCell,
    this.onHoverEvent,
    required this.locale,
    this.maxVisibleEventsPerDay = 5,
    this.onOverflowTap,
    this.onOverflowLongPress,
    this.showWeekNumbers = false,
    this.weekNumberBuilder,
    // Week layout customization
    this.weekLayoutBuilder,
    this.overflowIndicatorBuilder,
    this.weekRowIndex = 0,
    this.multiDayLayouts,
    // Drag-and-drop
    this.enableDragAndDrop = false,
    this.draggedTileBuilder,
    this.dragSourceTileBuilder,
    this.dragTargetTileBuilder,
    this.dropTargetCellBuilder,
    this.onDragWillAccept,
    this.onEventDropped,
    required this.controller,
    // Drag lifecycle callbacks (Task 21)
    this.onDragStartedCallback,
    this.onDragEndedCallback,
    this.onDragCanceledCallback,
    this.dragHandler,
  });

  @override
  State<_WeekRowWidget> createState() => _WeekRowWidgetState();
}

class _WeekRowWidgetState extends State<_WeekRowWidget> {
  // Note: Per-cell drop target state (_hoveredDropTarget) has been removed.
  // Drop target handling is now done at the _MonthPageWidget level with a
  // unified DragTarget wrapping all week rows.

  @override
  Widget build(BuildContext context) {
    // Determine text direction for RTL support
    final textDirection = Directionality.of(context);
    final isRTL = textDirection == TextDirection.rtl;

    // Calculate week number for week number column
    final firstDayOfWeekDate = widget.dates.first;
    final weekNumber = getISOWeekNumber(firstDayOfWeekDate);

    // Build week number cell if needed
    Widget? weekNumberCell;
    if (widget.showWeekNumbers) {
      weekNumberCell = _WeekNumberCell(
        weekNumber: weekNumber,
        firstDayOfWeek: firstDayOfWeekDate,
        theme: widget.theme,
        weekNumberBuilder: widget.weekNumberBuilder,
      );
    }

    // Build the 2-layer Stack architecture
    // Note: Layer 3 (drop targets) has been moved to _MonthPageWidget
    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate column widths (excluding week number column)
          final weekNumberWidth = widget.showWeekNumbers
              ? _WeekNumberCell.columnWidth
              : 0.0;
          final availableWidth = constraints.maxWidth - weekNumberWidth;
          final dayWidth = availableWidth / 7;
          final columnWidths = List.filled(7, dayWidth);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Week number column (positioned outside the Stack)
              if (weekNumberCell != null && !isRTL) weekNumberCell,

              // Main calendar content with 2-layer Stack
              Expanded(
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // Layer 1: Grid cells (just backgrounds/borders, NO events)
                    _buildLayer1Grid(context, isRTL),

                    // Layer 2: Events, date labels, overflow indicators
                    Positioned.fill(
                      child: _buildLayer2Events(
                        context,
                        columnWidths,
                        constraints.maxHeight,
                      ),
                    ),

                    // Layer 3: Removed - drop targets are now at _MonthPageWidget level
                  ],
                ),
              ),

              // Week number column for RTL
              if (weekNumberCell != null && isRTL) weekNumberCell,
            ],
          );
        },
      ),
    );
  }

  /// Layer 1: Grid cells with just backgrounds/borders, NO events.
  Widget _buildLayer1Grid(BuildContext context, bool isRTL) {
    final dayCells = widget.dates.asMap().entries.map((entry) {
      final date = entry.value;
      final isCurrentMonth =
          date.year == widget.currentMonth.year &&
          date.month == widget.currentMonth.month;
      final isToday = _isToday(date);

      // Get events for this date (for callbacks, not rendering)
      final allDayEvents = _getEventsForDate(date);

      // Check if this date is focused
      final isFocused =
          widget.focusedDate != null &&
          date.year == widget.focusedDate!.year &&
          date.month == widget.focusedDate!.month &&
          date.day == widget.focusedDate!.day;

      return Expanded(
        child: _DayCellWidget(
          date: date,
          displayMonth: widget.currentMonth,
          isCurrentMonth: isCurrentMonth,
          isToday: isToday,
          isSelectable: true,
          isFocused: isFocused,
          autoFocusOnCellTap: widget.autoFocusOnCellTap,
          onSetFocusedDate: widget.onSetFocusedDate,
          events: allDayEvents,
          // IMPORTANT: Pass empty list for rendering - events are in Layer 2
          eventsForRendering: const [],
          theme: widget.theme,
          dayCellBuilder: widget.dayCellBuilder,
          eventTileBuilder: widget.eventTileBuilder,
          dateLabelBuilder: null, // Date labels are in Layer 2
          showDateLabel: false, // Date labels are rendered in Layer 2
          dateFormat: widget.dateFormat,
          cellInteractivityCallback: widget.cellInteractivityCallback,
          onCellTap: widget.onCellTap,
          onCellLongPress: widget.onCellLongPress,
          onDateLabelTap: widget.onDateLabelTap,
          onDateLabelLongPress: widget.onDateLabelLongPress,
          onEventTap: widget.onEventTap,
          onEventLongPress: widget.onEventLongPress,
          onHoverCell: widget.onHoverCell,
          onHoverEvent: widget.onHoverEvent,
          locale: widget.locale,
          maxVisibleEventsPerDay: widget.maxVisibleEventsPerDay,
          onOverflowTap: widget.onOverflowTap,
          onOverflowLongPress: widget.onOverflowLongPress,
          multiDayReservedHeight:
              0.0, // No reserved height - all events in Layer 2
          enableDragAndDrop: widget.enableDragAndDrop,
          draggedTileBuilder: widget.draggedTileBuilder,
          dragSourceTileBuilder: widget.dragSourceTileBuilder,
          dragTargetTileBuilder: widget.dragTargetTileBuilder,
          dropTargetCellBuilder: widget.dropTargetCellBuilder,
          onDragWillAccept: widget.onDragWillAccept,
          onEventDropped: widget.onEventDropped,
          controller: widget.controller,
          onDragStartedCallback: widget.onDragStartedCallback,
          onDragEndedCallback: widget.onDragEndedCallback,
          onDragCanceledCallback: widget.onDragCanceledCallback,
        ),
      );
    }).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: dayCells,
    );
  }

  /// Layer 2: Events, date labels, and overflow indicators.
  Widget _buildLayer2Events(
    BuildContext context,
    List<double> columnWidths,
    double rowHeight,
  ) {
    // Create layout config from theme, passing maxVisibleEventsPerDay
    final config = MCalWeekLayoutConfig.fromTheme(
      widget.theme,
      maxVisibleEventsPerDay: widget.maxVisibleEventsPerDay,
    );

    // Calculate event segments for this week using the dates' first day to determine week start
    final firstDayOfWeekValue = widget.dates.first.weekday == DateTime.sunday
        ? 0
        : widget.dates.first.weekday;
    final allSegments = MCalMultiDayRenderer.calculateAllEventSegments(
      events: widget.events,
      monthStart: widget.currentMonth,
      firstDayOfWeek: firstDayOfWeekValue,
    );

    // Get segments for this specific week row
    final weekSegments = widget.weekRowIndex < allSegments.length
        ? allSegments[widget.weekRowIndex]
        : <MCalEventSegment>[];

    // Get day width for dragged tile sizing
    final dayWidth = columnWidths.isNotEmpty ? columnWidths[0] : 0.0;

    // Create wrapped builders using MCalBuilderWrapper
    final wrappedEventTileBuilder = MCalBuilderWrapper.wrapEventTileBuilder(
      developerBuilder: widget.eventTileBuilder,
      defaultBuilder: _buildDefaultEventTile,
      onEventTap: widget.onEventTap,
      onEventLongPress: widget.onEventLongPress,
      enableDragAndDrop: widget.enableDragAndDrop,
      dragHandler: null,
      // Drag-related parameters
      draggedTileBuilder: widget.draggedTileBuilder,
      dragSourceTileBuilder: widget.dragSourceTileBuilder,
      onDragStartedCallback: widget.onDragStartedCallback,
      onDragEndedCallback: widget.onDragEndedCallback,
      onDragCanceledCallback: widget.onDragCanceledCallback,
      // Tile sizing for dragged feedback (styling comes from theme via defaultBuilder)
      dayWidth: dayWidth,
      tileHeight: widget.theme.eventTileHeight,
      horizontalSpacing: widget.theme.eventTileHorizontalSpacing ?? 2.0,
    );

    final wrappedDateLabelBuilder = MCalBuilderWrapper.wrapDateLabelBuilder(
      developerBuilder: widget.dateLabelBuilder,
      defaultBuilder: _buildDefaultDateLabel,
      onDateLabelTap: widget.onDateLabelTap,
      onDateLabelLongPress: widget.onDateLabelLongPress,
    );

    final wrappedOverflowIndicatorBuilder =
        MCalBuilderWrapper.wrapOverflowIndicatorBuilder(
          developerBuilder: widget.overflowIndicatorBuilder,
          defaultBuilder: _buildDefaultOverflowIndicator,
          onOverflowTap: widget.onOverflowTap,
          onOverflowLongPress: widget.onOverflowLongPress,
        );

    // Create the week layout context
    final layoutContext = MCalWeekLayoutContext(
      segments: weekSegments,
      dates: widget.dates,
      columnWidths: columnWidths,
      rowHeight: rowHeight,
      weekRowIndex: widget.weekRowIndex,
      currentMonth: widget.currentMonth,
      config: config,
      eventTileBuilder: wrappedEventTileBuilder,
      dateLabelBuilder: wrappedDateLabelBuilder,
      overflowIndicatorBuilder: wrappedOverflowIndicatorBuilder,
    );

    // Use custom weekLayoutBuilder if provided, otherwise use default
    if (widget.weekLayoutBuilder != null) {
      return widget.weekLayoutBuilder!(context, layoutContext);
    }

    // Use default week layout builder
    return MCalDefaultWeekLayoutBuilder.build(context, layoutContext);
  }

  // Note: _buildLayer3DropTargets and _shouldHighlightCell have been removed.
  // Drop target handling is now done at the _MonthPageWidget level with a
  // unified DragTarget wrapping all week rows.

  /// Builds the default event tile widget.
  Widget _buildDefaultEventTile(
    BuildContext context,
    MCalEventTileContext tileContext,
  ) {
    final event = tileContext.event;
    final segment = tileContext.segment;
    final theme = widget.theme;

    // Determine corner radius based on segment position
    final cornerRadius = theme.eventTileCornerRadius ?? 4.0;
    final leftRadius = segment?.isFirstSegment ?? true ? cornerRadius : 0.0;
    final rightRadius = segment?.isLastSegment ?? true ? cornerRadius : 0.0;

    // Determine tile color - respect ignoreEventColors theme setting
    final tileColor = theme.ignoreEventColors
        ? (theme.eventTileBackgroundColor ?? Colors.blue)
        : (event.color ?? theme.eventTileBackgroundColor ?? Colors.blue);

    // Determine border - only add if both color and width are specified
    // For continuation segments, omit border on the continuation edge
    final borderWidth = theme.eventTileBorderWidth ?? 0.0;
    final hasBorder = borderWidth > 0 && theme.eventTileBorderColor != null;
    final isFirstSegment = segment?.isFirstSegment ?? true;
    final isLastSegment = segment?.isLastSegment ?? true;

    // Build border with individual sides based on segment position
    Border? tileBorder;
    if (hasBorder) {
      final borderColor = theme.eventTileBorderColor!;
      final topBorder = BorderSide(color: borderColor, width: borderWidth);
      final bottomBorder = BorderSide(color: borderColor, width: borderWidth);
      // Only add left border if this is the first segment (event starts here)
      final leftBorder = isFirstSegment
          ? BorderSide(color: borderColor, width: borderWidth)
          : BorderSide.none;
      // Only add right border if this is the last segment (event ends here)
      final rightBorder = isLastSegment
          ? BorderSide(color: borderColor, width: borderWidth)
          : BorderSide.none;
      tileBorder = Border(
        top: topBorder,
        bottom: bottomBorder,
        left: leftBorder,
        right: rightBorder,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(leftRadius),
          right: Radius.circular(rightRadius),
        ),
        border: tileBorder,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      alignment: Alignment.centerLeft,
      child: Text(
        event.title,
        style:
            theme.eventTileTextStyle ??
            const TextStyle(fontSize: 11, color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Builds the default date label widget.
  Widget _buildDefaultDateLabel(
    BuildContext context,
    MCalDateLabelContext labelContext,
  ) {
    final theme = widget.theme;
    final isCurrentMonth = labelContext.isCurrentMonth;
    final isToday = labelContext.isToday;

    // Text style - today uses bold but keeps readable color
    final textStyle = isToday
        ? (theme.todayTextStyle ??
              TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isCurrentMonth ? Colors.black87 : Colors.grey.shade600,
              ))
        : (theme.cellTextStyle ??
              TextStyle(
                fontSize: 12,
                color: isCurrentMonth ? Colors.black87 : Colors.grey,
              ));

    final dateText = Text(
      labelContext.defaultFormattedString,
      style: textStyle,
      textAlign: TextAlign.center,
    );

    // Get alignment from the DateLabelPosition
    final alignment = labelContext.horizontalAlignment;

    // Use a fixed-size container for ALL dates to ensure uniform spacing.
    // For today, the circle is visible; for other days, it's transparent.
    // This prevents alignment shifts when using left/right aligned labels.
    final circleContainer = Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // Only show the background color for today
        color: isToday
            ? (theme.todayBackgroundColor ?? Colors.grey.shade300)
            : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: dateText,
    );

    // Align the container according to DateLabelPosition
    return SizedBox(
      height: 24,
      child: Align(alignment: alignment, child: circleContainer),
    );
  }

  /// Builds the default overflow indicator widget.
  Widget _buildDefaultOverflowIndicator(
    BuildContext context,
    MCalOverflowIndicatorContext overflowContext,
  ) {
    final theme = widget.theme;
    return Center(
      child: Text(
        '+${overflowContext.hiddenEventCount} more',
        style:
            theme.leadingDatesTextStyle ??
            TextStyle(fontSize: 10, color: Colors.grey.shade600),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  List<MCalCalendarEvent> _getEventsForDate(DateTime date) {
    final matchingEvents = widget.events.where((event) {
      final eventStart = DateTime(
        event.start.year,
        event.start.month,
        event.start.day,
      );
      final eventEnd = DateTime(event.end.year, event.end.month, event.end.day);
      final checkDate = DateTime(date.year, date.month, date.day);
      return (checkDate.isAtSameMomentAs(eventStart) ||
          checkDate.isAtSameMomentAs(eventEnd) ||
          (checkDate.isAfter(eventStart) && checkDate.isBefore(eventEnd)));
    }).toList();

    // Sort events using the standard multi-day comparator
    // Order: all-day multi → timed multi → all-day single → timed single
    matchingEvents.sort(MCalMultiDayRenderer.multiDayEventComparator);

    return matchingEvents;
  }
}

/// Placeholder widget for day cell (will be fully implemented in task 9).
class _DayCellWidget extends StatelessWidget {
  final DateTime date;
  final DateTime displayMonth;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelectable;
  final bool isFocused;
  final bool autoFocusOnCellTap;
  final ValueChanged<DateTime>? onSetFocusedDate;

  /// All events for this date, used for callbacks.
  final List<MCalCalendarEvent> events;

  /// Events to render as tiles in this cell.
  /// May exclude multi-day events when they're rendered separately as contiguous tiles.
  /// If null, defaults to [events].
  final List<MCalCalendarEvent>? eventsForRendering;

  final MCalThemeData theme;
  final Widget Function(BuildContext, MCalDayCellContext, Widget)?
  dayCellBuilder;
  final Widget Function(BuildContext, MCalEventTileContext, Widget)?
  eventTileBuilder;
  final Widget Function(BuildContext, MCalDateLabelContext, String)?
  dateLabelBuilder;
  final String? dateFormat;
  final bool Function(BuildContext, MCalCellInteractivityDetails)?
  cellInteractivityCallback;
  final void Function(BuildContext, MCalCellTapDetails)? onCellTap;
  final void Function(BuildContext, MCalCellTapDetails)? onCellLongPress;
  final void Function(BuildContext, MCalDateLabelTapDetails)? onDateLabelTap;
  final void Function(BuildContext, MCalDateLabelTapDetails)?
  onDateLabelLongPress;
  final void Function(BuildContext, MCalEventTapDetails)? onEventTap;
  final void Function(BuildContext, MCalEventTapDetails)? onEventLongPress;
  final ValueChanged<MCalDayCellContext?>? onHoverCell;
  final ValueChanged<MCalEventTileContext?>? onHoverEvent;
  final Locale locale;
  final int maxVisibleEventsPerDay;
  final void Function(BuildContext, MCalOverflowTapDetails)? onOverflowTap;
  final void Function(BuildContext, MCalOverflowTapDetails)?
  onOverflowLongPress;

  // Drag-and-drop parameters
  final bool enableDragAndDrop;
  final Widget Function(BuildContext, MCalDraggedTileDetails)?
  draggedTileBuilder;
  final Widget Function(BuildContext, MCalDragSourceDetails)?
  dragSourceTileBuilder;
  final Widget Function(BuildContext, MCalDragTargetDetails)?
  dragTargetTileBuilder;
  final Widget Function(BuildContext, MCalDropTargetCellDetails)?
  dropTargetCellBuilder;
  final bool Function(BuildContext, MCalDragWillAcceptDetails)?
  onDragWillAccept;
  final bool Function(BuildContext, MCalEventDroppedDetails)? onEventDropped;
  final MCalEventController controller;

  // Drag lifecycle callbacks (Task 21)
  final void Function(MCalCalendarEvent event, DateTime sourceDate)?
  onDragStartedCallback;
  final void Function(bool wasAccepted)? onDragEndedCallback;
  final VoidCallback? onDragCanceledCallback;

  /// Reserved height for multi-day events above single-day events.
  /// When > 0, single-day events are pushed down by this amount.
  final double multiDayReservedHeight;

  /// Whether to show date labels in this cell.
  /// Set to false for Layer 1 grid cells when date labels are rendered in Layer 2.
  final bool showDateLabel;

  const _DayCellWidget({
    required this.date,
    required this.displayMonth,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelectable,
    this.isFocused = false,
    this.autoFocusOnCellTap = true,
    this.onSetFocusedDate,
    required this.events,
    this.eventsForRendering,
    required this.theme,
    this.dayCellBuilder,
    this.eventTileBuilder,
    this.dateLabelBuilder,
    this.dateFormat,
    this.cellInteractivityCallback,
    this.onCellTap,
    this.onCellLongPress,
    this.onDateLabelTap,
    this.onDateLabelLongPress,
    this.onEventTap,
    this.onEventLongPress,
    this.onHoverCell,
    this.onHoverEvent,
    required this.locale,
    this.maxVisibleEventsPerDay = 5,
    this.onOverflowTap,
    this.onOverflowLongPress,
    this.multiDayReservedHeight = 0.0,
    this.showDateLabel = true,
    // Drag-and-drop
    this.enableDragAndDrop = false,
    this.draggedTileBuilder,
    this.dragSourceTileBuilder,
    this.dragTargetTileBuilder,
    this.dropTargetCellBuilder,
    this.onDragWillAccept,
    this.onEventDropped,
    required this.controller,
    // Drag lifecycle callbacks (Task 21)
    this.onDragStartedCallback,
    this.onDragEndedCallback,
    this.onDragCanceledCallback,
  });

  /// Gets the events to use for rendering tiles.
  List<MCalCalendarEvent> get _renderableEvents => eventsForRendering ?? events;

  @override
  Widget build(BuildContext context) {
    // Check if cell is interactive
    final isInteractive = cellInteractivityCallback != null
        ? cellInteractivityCallback!(
            context,
            MCalCellInteractivityDetails(
              date: date,
              isCurrentMonth: isCurrentMonth,
              isSelectable: isSelectable,
            ),
          )
        : true;

    // Create wrapped date label builder for use in dayCellBuilder context
    // This builder is pre-wrapped with tap handlers (or IgnorePointer)
    final wrappedDateLabelBuilder = MCalBuilderWrapper.wrapDateLabelBuilder(
      developerBuilder: dateLabelBuilder,
      defaultBuilder: _buildDefaultDateLabelWidget,
      onDateLabelTap: onDateLabelTap,
      onDateLabelLongPress: onDateLabelLongPress,
    );

    // Build cell decoration (apply non-interactive styling if needed)
    final decoration = _getCellDecoration(isInteractive);

    // Build date label (only if showDateLabel is true - Layer 2 handles labels now)
    final dateLabel = showDateLabel ? _buildDateLabel(context) : null;

    // Build the cell widget with clip to prevent overflow on small screens
    // The LayoutBuilder dynamically calculates how many events fit
    Widget cell = LayoutBuilder(
      builder: (context, constraints) {
        // Get theme-based tile height (slot height including margins)
        final tileHeight = theme.eventTileHeight ?? 20.0;

        // Calculate available height for events after:
        // - date label with top padding (20.0 + 4.0 = 24.0) if showing
        // - multi-day reserved area (variable)
        // - cell border (1px top + 1px bottom = 2px)
        // Note: Event tiles now go edge-to-edge horizontally (no cell padding)
        // and tiles handle their own margins
        final dateLabelHeightWithPadding = showDateLabel
            ? 24.0
            : 0.0; // 20.0 label + 4.0 top padding
        const cellBorderHeight = 2.0; // 1px border on top and bottom
        final availableEventHeight =
            constraints.maxHeight -
            dateLabelHeightWithPadding -
            multiDayReservedHeight -
            cellBorderHeight;

        // Calculate how many event tiles can fit
        final maxTilesByHeight = availableEventHeight > 0
            ? (availableEventHeight / tileHeight).floor()
            : 0;

        // Use the smaller of maxVisibleEventsPerDay and what fits by height
        final effectiveMaxEvents = maxVisibleEventsPerDay == 0
            ? maxTilesByHeight
            : (maxTilesByHeight < maxVisibleEventsPerDay
                  ? maxTilesByHeight
                  : maxVisibleEventsPerDay);

        // Rebuild event tiles with the effective max, applying consistent sizing
        final effectiveTiles = _buildEventTilesWithLimit(
          context,
          effectiveMaxEvents,
          tileHeight: tileHeight,
        );

        // DEBUG: Set to true to visualize cell structure
        const bool debugCellSpacing = false;

        // Cell structure:
        // - Outer container with decoration (cell background/border)
        // - Column with:
        //   - Date label (with horizontal padding)
        //   - Multi-day reserved spacer (full width, no padding)
        //   - Single-day event tiles (full width, no horizontal padding -
        //     tiles handle their own margins)
        return Container(
          decoration: decoration,
          // DEBUG: Green border shows the cell boundary
          foregroundDecoration: debugCellSpacing
              ? BoxDecoration(
                  border: Border.all(color: Colors.green, width: 0.5),
                )
              : null,
          clipBehavior: Clip.hardEdge,
          child: Opacity(
            opacity: isInteractive ? 1.0 : 0.5,
            // ClipRect ensures nothing in the Column can overflow the cell
            child: ClipRect(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Full width for tiles
                children: [
                  // Date label with padding (only if showDateLabel is true)
                  if (dateLabel != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 4.0,
                        top: 4.0,
                        right: 4.0,
                      ),
                      child: dateLabel,
                    ),
                  // Spacer for multi-day events (if any reserved space)
                  // No horizontal padding - aligns with multi-day overlay
                  if (multiDayReservedHeight > 0)
                    Container(
                      height: multiDayReservedHeight,
                      // DEBUG: Purple shows multi-day reserved space within cell
                      color: debugCellSpacing
                          ? Colors.purple.withValues(alpha: 0.2)
                          : null,
                    ),
                  // Single-day events - NO horizontal padding
                  // Each tile handles its own 1px margin via the Padding wrapper
                  ...effectiveTiles,
                ],
              ),
            ),
          ),
        );
      },
    );

    // Apply builder callback if provided
    if (dayCellBuilder != null) {
      final contextObj = MCalDayCellContext(
        date: date,
        isCurrentMonth: isCurrentMonth,
        isToday: isToday,
        isSelectable: isSelectable,
        isFocused: isFocused,
        events: events,
        dateLabelBuilder: wrappedDateLabelBuilder,
      );
      cell = dayCellBuilder!(context, contextObj, cell);
    }

    // NOTE: DragTarget is now in Layer 3, not here in Layer 1
    // This ensures drop targets are on top of events and always receive pointer events

    // Wrap in gesture detector for tap/long-press
    final localizations = MCalLocalizations();
    Widget result = GestureDetector(
      onTap: isInteractive
          ? () {
              // Set focus if autoFocusOnCellTap is enabled
              if (autoFocusOnCellTap) {
                onSetFocusedDate?.call(date);
              }
              // Fire the onCellTap callback if provided
              if (onCellTap != null) {
                onCellTap!(
                  context,
                  MCalCellTapDetails(
                    date: date,
                    events: events,
                    isCurrentMonth: isCurrentMonth,
                  ),
                );
              }
            }
          : null,
      onLongPress: isInteractive && onCellLongPress != null
          ? () => onCellLongPress!(
              context,
              MCalCellTapDetails(
                date: date,
                events: events,
                isCurrentMonth: isCurrentMonth,
              ),
            )
          : null,
      child: Semantics(
        label: _getSemanticLabel(),
        selected: isFocused,
        hint: isInteractive
            ? localizations.getLocalizedString('doubleTapToSelect', locale)
            : null,
        child: cell,
      ),
    );

    // Wrap in MouseRegion for hover support (only if callback provided)
    if (onHoverCell != null) {
      result = MouseRegion(
        onEnter: (_) {
          final contextObj = MCalDayCellContext(
            date: date,
            isCurrentMonth: isCurrentMonth,
            isToday: isToday,
            isSelectable: isSelectable,
            isFocused: isFocused,
            events: events,
            dateLabelBuilder: wrappedDateLabelBuilder,
          );
          onHoverCell!(contextObj);
        },
        onExit: (_) => onHoverCell!(null),
        child: result,
      );
    }

    // Wrap in RepaintBoundary to isolate repaints so that changes to one
    // cell don't trigger repaints of other cells
    return RepaintBoundary(child: result);
  }

  /// Gets the cell decoration based on date type and theme.
  ///
  /// [isInteractive] parameter indicates if the cell is interactive.
  /// Non-interactive cells may have reduced visual prominence.
  BoxDecoration _getCellDecoration([bool isInteractive = true]) {
    Color? backgroundColor;
    Color? borderColor = theme.cellBorderColor;

    // Apply focused styling first (takes priority)
    if (isFocused) {
      backgroundColor =
          theme.focusedDateBackgroundColor ?? theme.cellBackgroundColor;
    } else if (isToday) {
      backgroundColor = theme.todayBackgroundColor ?? theme.cellBackgroundColor;
    } else if (isCurrentMonth) {
      backgroundColor = theme.cellBackgroundColor;
    } else {
      // Leading/trailing date
      backgroundColor = isCurrentMonth
          ? theme.cellBackgroundColor
          : (theme.leadingDatesBackgroundColor ??
                theme.trailingDatesBackgroundColor ??
                theme.cellBackgroundColor);
    }

    // Apply reduced opacity for non-interactive cells
    if (!isInteractive && backgroundColor != null) {
      backgroundColor = backgroundColor.withValues(alpha: 0.6);
    }

    return BoxDecoration(
      color: backgroundColor,
      border: Border.all(
        color: borderColor ?? Colors.grey.shade300,
        width: 1.0,
      ),
    );
  }

  /// Builds the date label widget.
  ///
  /// Supports dateLabelBuilder callback, dateFormat parameter, or
  /// default formatting via MCalLocalizations.
  Widget _buildDateLabel(BuildContext context) {
    // Determine default formatted string
    String defaultFormattedString;
    if (dateFormat != null) {
      // Use custom date format if provided
      try {
        defaultFormattedString = DateFormat(
          dateFormat,
          locale.toString(),
        ).format(date);
      } catch (e) {
        // Fallback to day number if format is invalid
        defaultFormattedString = '${date.day}';
      }
    } else {
      // Use default day number
      defaultFormattedString = '${date.day}';
    }

    // Use dateLabelBuilder if provided
    if (dateLabelBuilder != null) {
      final contextObj = MCalDateLabelContext(
        date: date,
        isCurrentMonth: isCurrentMonth,
        isToday: isToday,
        defaultFormattedString: defaultFormattedString,
        locale: locale,
      );
      return dateLabelBuilder!(context, contextObj, defaultFormattedString);
    }

    // Otherwise use default rendering with appropriate styling
    TextStyle? textStyle;
    if (isFocused) {
      // Focused date takes priority for text styling
      textStyle = theme.focusedDateTextStyle ?? theme.cellTextStyle;
    } else if (isToday) {
      textStyle = theme.todayTextStyle ?? theme.cellTextStyle;
    } else if (isCurrentMonth) {
      textStyle = theme.cellTextStyle;
    } else {
      // Leading/trailing date
      textStyle =
          theme.leadingDatesTextStyle ??
          theme.trailingDatesTextStyle ??
          theme.cellTextStyle;
    }

    return Text(
      defaultFormattedString,
      style: textStyle?.copyWith(
        fontWeight: (isToday || isFocused) ? FontWeight.bold : null,
      ),
      textAlign: TextAlign.left,
    );
  }

  /// Builds the default date label widget for use in builder wrapper.
  ///
  /// This method matches the signature required by [MCalBuilderWrapper.wrapDateLabelBuilder]
  /// and provides the default rendering for date labels.
  Widget _buildDefaultDateLabelWidget(
    BuildContext context,
    MCalDateLabelContext labelContext,
  ) {
    // Use the same styling logic as _buildDateLabel but with context-based values
    TextStyle? textStyle;
    if (labelContext.isToday) {
      textStyle = theme.todayTextStyle ?? theme.cellTextStyle;
    } else if (labelContext.isCurrentMonth) {
      textStyle = theme.cellTextStyle;
    } else {
      textStyle =
          theme.leadingDatesTextStyle ??
          theme.trailingDatesTextStyle ??
          theme.cellTextStyle;
    }

    final dateText = Text(
      labelContext.defaultFormattedString,
      style: textStyle?.copyWith(
        fontWeight: labelContext.isToday ? FontWeight.bold : null,
      ),
      textAlign: TextAlign.center,
    );

    // Get alignment from the DateLabelPosition
    final alignment = labelContext.horizontalAlignment;

    // Use a fixed-size container for uniform spacing
    final circleContainer = Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: labelContext.isToday
            ? (theme.todayBackgroundColor ?? Colors.grey.shade300)
            : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: dateText,
    );

    return SizedBox(
      height: 24,
      child: Align(alignment: alignment, child: circleContainer),
    );
  }

  /// Builds event tiles for this day cell.
  /// Builds event tiles with a dynamic limit based on available space.
  ///
  /// This method is similar to [_buildEventTiles] but accepts an explicit
  /// limit to use instead of [maxVisibleEventsPerDay], allowing the layout to
  /// adapt to the actual available cell height.
  ///
  /// The [tileHeight] parameter controls the height of each tile slot
  /// (including margins which are applied inside the tile).
  List<Widget> _buildEventTilesWithLimit(
    BuildContext context,
    int limit, {
    double tileHeight = 20.0,
  }) {
    final renderEvents = _renderableEvents;

    // If no space for any tiles (limit <= 0), show nothing at all
    // Even the overflow indicator needs space, so we can't show it either
    if (renderEvents.isEmpty || limit <= 0) {
      return [];
    }

    // If we have more events than can fit, we need to reserve one slot
    // for the overflow indicator. So we show (limit - 1) tiles + indicator.
    // This ensures the total items (tiles + indicator) never exceeds limit.
    //
    // Edge cases:
    // - limit = 1, events = 2: Show 0 tiles + "+2 more" (only indicator fits)
    // - limit = 2, events = 3: Show 1 tile + "+2 more"
    // - limit = 3, events = 3: Show 3 tiles (no overflow)
    // - limit = 1, events = 1: Show 1 tile (no overflow)
    final hasOverflow = renderEvents.length > limit;
    final tilesLimit = hasOverflow ? (limit - 1).clamp(0, limit) : limit;
    final visibleEvents = renderEvents.take(tilesLimit).toList();
    final overflowCount = hasOverflow ? renderEvents.length - tilesLimit : 0;

    final tiles = <Widget>[];

    // Add visible event tiles with consistent sizing
    for (int i = 0; i < visibleEvents.length; i++) {
      final event = visibleEvents[i];
      final eventSpanInfo = _getEventSpanInfo(event);

      Widget tile = _EventTileWidget(
        event: event,
        displayDate: date,
        isAllDay: event.isAllDay,
        theme: theme,
        eventTileBuilder: eventTileBuilder,
        isStartOfSpan: eventSpanInfo.isStart,
        isEndOfSpan: eventSpanInfo.isEnd,
        spanLength: eventSpanInfo.length,
        onEventTap: onEventTap,
        onEventLongPress: onEventLongPress,
        onHoverEvent: onHoverEvent,
        locale: locale,
      );

      // Wrap with MCalDraggableEventTile when drag-and-drop is enabled
      // Note: This is legacy Layer 1 rendering. Layer 2 (via weekLayoutBuilder)
      // is the primary path for event rendering in the new architecture.
      if (enableDragAndDrop) {
        // Capture event and date for the callback closures
        final capturedEvent = event;
        final capturedDate = date;

        // For Layer 1 rendering, we don't have direct access to dayWidth,
        // so we use a LayoutBuilder wrapper to get it dynamically
        tile = LayoutBuilder(
          builder: (context, constraints) {
            // Cell width is approximately the available width
            final cellWidth = constraints.maxWidth > 0
                ? constraints.maxWidth
                : 50.0;
            final hSpacing = theme.eventTileHorizontalSpacing ?? 2.0;

            return MCalDraggableEventTile(
              event: capturedEvent,
              sourceDate: capturedDate,
              dayWidth: cellWidth,
              horizontalSpacing: hSpacing,
              enabled: true,
              draggedTileBuilder: draggedTileBuilder,
              dragSourceTileBuilder: dragSourceTileBuilder,
              onDragStarted: onDragStartedCallback != null
                  ? () => onDragStartedCallback!(capturedEvent, capturedDate)
                  : null,
              onDragEnded: onDragEndedCallback,
              onDragCanceled: onDragCanceledCallback,
              child: tile,
            );
          },
        );
      }

      // Wrap in SizedBox with Padding to enforce margin at layout level.
      // The margin space is NOT part of the tile (clicks there go to the cell).
      // Single-day tiles have margin on all sides.
      final horizontalMargin = theme.eventTileHorizontalSpacing ?? 1.0;
      final verticalMargin = theme.eventTileVerticalSpacing ?? 1.0;

      tiles.add(
        SizedBox(
          height: tileHeight,
          child: Padding(
            padding: EdgeInsets.only(
              left: horizontalMargin,
              right: horizontalMargin,
              top: verticalMargin,
              bottom: verticalMargin,
            ),
            child: tile,
          ),
        ),
      );
    }

    // Add overflow indicator if needed - with same height as tiles for consistency
    if (overflowCount > 0) {
      final horizontalMargin = theme.eventTileHorizontalSpacing ?? 1.0;
      final verticalMargin = theme.eventTileVerticalSpacing ?? 1.0;

      tiles.add(
        SizedBox(
          height: tileHeight,
          child: Padding(
            padding: EdgeInsets.only(
              left: horizontalMargin,
              right: horizontalMargin,
              top: verticalMargin,
              bottom: verticalMargin,
            ),
            child: _OverflowIndicatorWidget(
              count: overflowCount,
              date: date,
              allEvents: events,
              theme: theme,
              locale: locale,
              onOverflowTap: onOverflowTap,
              onOverflowLongPress: onOverflowLongPress,
            ),
          ),
        ),
      );
    }

    return tiles;
  }

  /// Gets information about how an event spans across days.
  ///
  /// Returns information about whether this date is the start or end
  /// of a multi-day event, and the total length of the span.
  _EventSpanInfo _getEventSpanInfo(MCalCalendarEvent event) {
    final eventStartDate = DateTime(
      event.start.year,
      event.start.month,
      event.start.day,
    );
    final eventEndDate = DateTime(
      event.end.year,
      event.end.month,
      event.end.day,
    );
    final cellDate = DateTime(date.year, date.month, date.day);

    final isStart = cellDate.isAtSameMomentAs(eventStartDate);
    final isEnd = cellDate.isAtSameMomentAs(eventEndDate);
    // Use DST-safe daysBetween to calculate length
    final length = daysBetween(eventStartDate, eventEndDate) + 1;

    return _EventSpanInfo(isStart: isStart, isEnd: isEnd, length: length);
  }

  /// Gets the semantic label for accessibility.
  ///
  /// Builds a comprehensive label for screen readers including:
  /// - Full date with day name (e.g., "Saturday, January 15, 2026")
  /// - "today" if the cell represents today's date
  /// - "focused" if the cell is currently focused
  /// - "previous month" or "next month" if outside the display month
  /// - Event count (e.g., "3 events")
  String _getSemanticLabel() {
    final localizations = MCalLocalizations();

    // Full date with day name for better screen reader experience
    final dateStr = localizations.formatFullDateWithDayName(date, locale);

    final parts = <String>[dateStr];

    // Add "today" indicator
    if (isToday) {
      parts.add(localizations.getLocalizedString('today', locale));
    }

    // Add focused/selected indicator
    if (isFocused) {
      parts.add(localizations.getLocalizedString('focused', locale));
    }

    // Add month context for dates outside current month
    if (!isCurrentMonth) {
      // Determine if date is in previous or next month relative to display month
      final dateMonth = DateTime(date.year, date.month, 1);
      final currentDisplayMonth = DateTime(
        displayMonth.year,
        displayMonth.month,
        1,
      );

      if (dateMonth.isBefore(currentDisplayMonth)) {
        parts.add(localizations.getLocalizedString('previousMonth', locale));
      } else {
        parts.add(localizations.getLocalizedString('nextMonth', locale));
      }
    }

    // Add event count
    if (events.isNotEmpty) {
      final eventWord = events.length == 1
          ? localizations.getLocalizedString('event', locale)
          : localizations.getLocalizedString('events', locale);
      parts.add('${events.length} $eventWord');
    }

    return parts.join(', ');
  }
}

/// Information about how an event spans across days.
class _EventSpanInfo {
  final bool isStart;
  final bool isEnd;
  final int length;

  const _EventSpanInfo({
    required this.isStart,
    required this.isEnd,
    required this.length,
  });
}

/// Widget for rendering a single event tile within a day cell.
class _EventTileWidget extends StatelessWidget {
  final MCalCalendarEvent event;
  final DateTime displayDate;
  final bool isAllDay;
  final MCalThemeData theme;
  final Widget Function(BuildContext, MCalEventTileContext, Widget)?
  eventTileBuilder;
  final bool isStartOfSpan;
  final bool isEndOfSpan;
  final int spanLength;
  final void Function(BuildContext, MCalEventTapDetails)? onEventTap;
  final void Function(BuildContext, MCalEventTapDetails)? onEventLongPress;
  final ValueChanged<MCalEventTileContext?>? onHoverEvent;
  final Locale locale;

  const _EventTileWidget({
    required this.event,
    required this.displayDate,
    required this.isAllDay,
    required this.theme,
    this.eventTileBuilder,
    this.isStartOfSpan = false,
    this.isEndOfSpan = false,
    this.spanLength = 1,
    required this.onEventTap,
    required this.onEventLongPress,
    this.onHoverEvent,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    // Build default tile with multi-day spanning support
    // For multi-day events, adjust border radius and content to show continuity
    BorderRadiusGeometry? borderRadius;
    EdgeInsetsGeometry padding;

    final bool isMultiDay = spanLength > 1;
    final bool isContinuation = isMultiDay && !isStartOfSpan;

    if (isMultiDay) {
      if (isStartOfSpan && isEndOfSpan) {
        // Single day event (shouldn't happen, but handle it)
        borderRadius = BorderRadius.circular(4);
        padding = const EdgeInsets.symmetric(horizontal: 4, vertical: 2);
      } else if (isStartOfSpan) {
        // Start of multi-day event - round start corners, no end padding
        borderRadius = const BorderRadiusDirectional.only(
          topStart: Radius.circular(4),
          bottomStart: Radius.circular(4),
        );
        padding = const EdgeInsetsDirectional.only(start: 4, top: 2, bottom: 2);
      } else if (isEndOfSpan) {
        // End of multi-day event - round end corners, no start padding
        borderRadius = const BorderRadiusDirectional.only(
          topEnd: Radius.circular(4),
          bottomEnd: Radius.circular(4),
        );
        padding = const EdgeInsetsDirectional.only(end: 4, top: 2, bottom: 2);
      } else {
        // Middle of multi-day event - no rounded corners
        borderRadius = BorderRadius.zero;
        padding = const EdgeInsets.symmetric(vertical: 2);
      }
    } else {
      borderRadius = BorderRadius.circular(4);
      padding = const EdgeInsets.symmetric(horizontal: 4, vertical: 2);
    }

    // Determine styling based on whether this is an all-day event
    // Priority: event.color > theme colors > defaults
    final Color backgroundColor;
    final TextStyle textStyle;
    final Color? borderColor;
    final double borderWidth;

    if (isAllDay) {
      // Use event color if provided, otherwise fall back to theme/defaults
      backgroundColor =
          event.color ??
          theme.allDayEventBackgroundColor ??
          theme.eventTileBackgroundColor ??
          Colors.blue.shade50;
      textStyle =
          theme.allDayEventTextStyle ??
          theme.eventTileTextStyle ??
          const TextStyle(fontSize: 11, color: Colors.black87);
      borderColor = theme.allDayEventBorderColor;
      borderWidth = theme.allDayEventBorderWidth ?? 1.0;
    } else {
      // Use event color if provided, otherwise fall back to theme/defaults
      backgroundColor =
          event.color ?? theme.eventTileBackgroundColor ?? Colors.blue.shade100;
      textStyle =
          theme.eventTileTextStyle ??
          const TextStyle(fontSize: 11, color: Colors.black87);
      borderColor = null;
      borderWidth = 0.0;
    }

    // Content: show title on first day, continuation indicator on other days
    Widget content;
    if (isContinuation) {
      // For continuation days, show a subtle continuation indicator
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_back,
            size: 10,
            color: textStyle.color?.withAlpha(128) ?? Colors.black54,
          ),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              event.title,
              style: textStyle.copyWith(fontStyle: FontStyle.italic),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      );
    } else {
      // Build content with optional all-day indicator icon
      if (isAllDay && !isMultiDay) {
        // For single-day all-day events, show a visual indicator
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wb_sunny_outlined,
              size: 10,
              color: textStyle.color ?? Colors.black87,
            ),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                event.title,
                style: textStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        );
      } else {
        content = Text(
          event.title,
          style: textStyle,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        );
      }
    }

    // Note: Margins are enforced by the parent layout (SizedBox + Padding wrapper),
    // not by this widget. The tile receives its final size and should fill it completely.
    // This makes the tile the clickable area, with margin space belonging to the cell.

    Widget tile = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: borderColor != null && borderWidth > 0
            ? Border.all(color: borderColor, width: borderWidth)
            : null,
      ),
      clipBehavior: Clip.hardEdge,
      padding: padding,
      alignment: Alignment.centerLeft,
      child: content,
    );

    // Apply builder callback if provided (takes precedence over theme styling)
    if (eventTileBuilder != null) {
      final contextObj = MCalEventTileContext(
        event: event,
        displayDate: displayDate,
        isAllDay: isAllDay,
      );
      tile = eventTileBuilder!(context, contextObj, tile);
    }

    // Wrap in gesture detector for tap/long-press
    Widget result = GestureDetector(
      onTap: onEventTap != null
          ? () => onEventTap!(
              context,
              MCalEventTapDetails(event: event, displayDate: displayDate),
            )
          : null,
      onLongPress: onEventLongPress != null
          ? () => onEventLongPress!(
              context,
              MCalEventTapDetails(event: event, displayDate: displayDate),
            )
          : null,
      child: Semantics(label: _getSemanticLabel(), child: tile),
    );

    // Wrap in MouseRegion for hover support (only if callback provided)
    if (onHoverEvent != null) {
      result = MouseRegion(
        onEnter: (_) {
          final contextObj = MCalEventTileContext(
            event: event,
            displayDate: displayDate,
            isAllDay: isAllDay,
          );
          onHoverEvent!(contextObj);
        },
        onExit: (_) => onHoverEvent!(null),
        child: result,
      );
    }

    return result;
  }

  /// Gets the semantic label for accessibility.
  String _getSemanticLabel() {
    final localizations = MCalLocalizations();
    final timeStr = _formatEventTime(localizations);
    return '${event.title}, $timeStr';
  }

  /// Formats the event time for display.
  String _formatEventTime(MCalLocalizations localizations) {
    if (isAllDay) {
      return 'all day';
    }

    final startTime = localizations.formatTime(event.start, locale);
    final endTime = localizations.formatTime(event.end, locale);
    return '$startTime to $endTime';
  }
}

/// Widget for displaying overflow event indicator.
///
/// This widget displays a "+N more" indicator when there are more events
/// than can be shown in a day cell. It supports tap and long-press interactions:
/// - On tap: calls [onOverflowTap] if provided, otherwise shows a default bottom sheet
/// - On long-press: calls [onOverflowLongPress] if provided
class _OverflowIndicatorWidget extends StatelessWidget {
  /// The number of hidden events.
  final int count;

  /// The date this overflow indicator belongs to.
  final DateTime date;

  /// All events for this date (including visible and hidden).
  final List<MCalCalendarEvent> allEvents;

  /// The theme for styling.
  final MCalThemeData theme;

  /// The locale for formatting.
  final Locale locale;

  /// Callback when the overflow indicator is tapped.
  /// If null, a default bottom sheet is shown.
  final void Function(BuildContext, MCalOverflowTapDetails)? onOverflowTap;

  /// Callback when the overflow indicator is long-pressed.
  final void Function(BuildContext, MCalOverflowTapDetails)?
  onOverflowLongPress;

  const _OverflowIndicatorWidget({
    required this.count,
    required this.date,
    required this.allEvents,
    required this.theme,
    required this.locale,
    this.onOverflowTap,
    this.onOverflowLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final indicatorText = '+$count more';

    final Widget indicator = Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Text(
        indicatorText,
        style: (theme.eventTileTextStyle ?? const TextStyle(fontSize: 11))
            .copyWith(
              fontStyle: FontStyle.italic,
              color: (theme.eventTileTextStyle?.color ?? Colors.black87)
                  .withValues(alpha: 0.7),
            ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );

    // Semantic label for accessibility
    final semanticLabel = '$count more events, tap to view all';

    return Semantics(
      label: semanticLabel,
      button: true,
      child: GestureDetector(
        onTap: () => _handleTap(context),
        onLongPress: onOverflowLongPress != null
            ? () {
                final visibleCount = allEvents.length - count;
                onOverflowLongPress!(
                  context,
                  MCalOverflowTapDetails(
                    date: date,
                    hiddenEvents: allEvents.sublist(
                      visibleCount.clamp(0, allEvents.length),
                    ),
                    visibleEvents: allEvents.sublist(
                      0,
                      visibleCount.clamp(0, allEvents.length),
                    ),
                  ),
                );
              }
            : null,
        child: indicator,
      ),
    );
  }

  /// Handles tap on the overflow indicator.
  ///
  /// If [onOverflowTap] is provided, calls it with the context and details.
  /// Otherwise, shows a default bottom sheet with all events for the day.
  void _handleTap(BuildContext context) {
    if (onOverflowTap != null) {
      final visibleCount = allEvents.length - count;
      onOverflowTap!(
        context,
        MCalOverflowTapDetails(
          date: date,
          hiddenEvents: allEvents.sublist(
            visibleCount.clamp(0, allEvents.length),
          ),
          visibleEvents: allEvents.sublist(
            0,
            visibleCount.clamp(0, allEvents.length),
          ),
        ),
      );
    } else {
      _showDefaultBottomSheet(context);
    }
  }

  /// Shows the default bottom sheet with all events for the day.
  void _showDefaultBottomSheet(BuildContext context) {
    final localizations = MCalLocalizations();
    final dateStr = localizations.formatDate(date, locale);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.25,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          dateStr,
                          style:
                              theme.navigatorTextStyle?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ) ??
                              const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${allEvents.length} ${allEvents.length == 1 ? 'event' : 'events'}',
                    style:
                        theme.cellTextStyle?.copyWith(
                          color: Colors.grey[600],
                        ) ??
                        TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  // Scrollable list of events
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: allEvents.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final event = allEvents[index];
                        return _buildEventListItem(context, event);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Builds a list item for an event in the bottom sheet.
  Widget _buildEventListItem(BuildContext context, MCalCalendarEvent event) {
    final localizations = MCalLocalizations();

    // Format time string
    String timeStr;
    if (event.isAllDay) {
      timeStr = localizations.getLocalizedString('allDay', locale);
      // Fallback if localization doesn't have allDay
      if (timeStr == 'allDay') {
        timeStr = 'All day';
      }
    } else {
      final startTime = localizations.formatTime(event.start, locale);
      final endTime = localizations.formatTime(event.end, locale);
      timeStr = '$startTime - $endTime';
    }

    // Use appropriate color based on whether event is all-day
    final indicatorColor = event.isAllDay
        ? (theme.allDayEventBackgroundColor ??
              theme.eventTileBackgroundColor ??
              Colors.blue)
        : (theme.eventTileBackgroundColor ?? Colors.blue);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color indicator
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: indicatorColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          // Event details with optional all-day icon
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (event.isAllDay) ...[
                      Icon(
                        Icons.wb_sunny_outlined,
                        size: 14,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(
                        event.title,
                        style:
                            theme.eventTileTextStyle?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ) ??
                            const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for rendering weekday header row.
class _WeekdayHeaderRowWidget extends StatelessWidget {
  final int firstDayOfWeek;
  final MCalThemeData theme;
  final Widget Function(BuildContext, MCalDayHeaderContext, Widget)?
  dayHeaderBuilder;
  final Locale locale;
  final bool showWeekNumbers;

  const _WeekdayHeaderRowWidget({
    required this.firstDayOfWeek,
    required this.theme,
    this.dayHeaderBuilder,
    required this.locale,
    this.showWeekNumbers = false,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = MCalLocalizations();
    final isRTL = localizations.isRTL(locale);

    // Generate weekday names in the correct order based on firstDayOfWeek
    // Use abbreviated names (Short) for better fit
    final weekdayNames = <String>[];
    final weekdayKeys = [
      'daySundayShort',
      'dayMondayShort',
      'dayTuesdayShort',
      'dayWednesdayShort',
      'dayThursdayShort',
      'dayFridayShort',
      'daySaturdayShort',
    ];

    for (int i = 0; i < 7; i++) {
      final dayIndex = (firstDayOfWeek + i) % 7;
      weekdayNames.add(
        localizations.getLocalizedString(weekdayKeys[dayIndex], locale),
      );
    }

    // If RTL, reverse the order
    final displayNames = isRTL ? weekdayNames.reversed.toList() : weekdayNames;

    // Build the day headers
    final dayHeaders = List.generate(7, (index) {
      final dayOfWeek = (firstDayOfWeek + index) % 7;
      final dayName = displayNames[index];

      // Default header content (without Expanded - that's added at the end)
      Widget headerContent = Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
        decoration: BoxDecoration(
          color: theme.weekdayHeaderBackgroundColor,
          border: Border(
            bottom: BorderSide(
              color: theme.cellBorderColor ?? Colors.grey.shade300,
            ),
          ),
        ),
        child: Center(
          child: Text(
            dayName,
            style: theme.weekdayHeaderTextStyle,
            textAlign: TextAlign.center,
            overflow: TextOverflow.clip,
            maxLines: 1,
          ),
        ),
      );

      // Apply builder callback if provided
      if (dayHeaderBuilder != null) {
        final contextObj = MCalDayHeaderContext(
          dayOfWeek: dayOfWeek,
          dayName: dayName,
        );
        headerContent = dayHeaderBuilder!(context, contextObj, headerContent);
      }

      // Wrap in Expanded after builder callback to ensure proper Row layout
      return Expanded(child: headerContent);
    });

    // If not showing week numbers, return simple row
    if (!showWeekNumbers) {
      return Row(children: dayHeaders);
    }

    // Build week number header cell
    final weekNumberHeader = Container(
      width: _WeekNumberCell.columnWidth,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color:
            theme.weekNumberBackgroundColor ??
            theme.weekdayHeaderBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.cellBorderColor ?? Colors.grey.shade300,
          ),
        ),
      ),
      child: Center(
        child: Text(
          'Wk',
          style: theme.weekNumberTextStyle ?? theme.weekdayHeaderTextStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );

    // Position based on text direction
    // LTR: week number on LEFT, RTL: week number on RIGHT
    return Row(
      children: isRTL
          ? [...dayHeaders, weekNumberHeader]
          : [weekNumberHeader, ...dayHeaders],
    );
  }
}

/// Widget for rendering month navigator with previous/next/today controls.
class _NavigatorWidget extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime? minDate;
  final DateTime? maxDate;
  final MCalThemeData theme;
  final Widget Function(BuildContext, MCalNavigatorContext, Widget)?
  navigatorBuilder;
  final Locale locale;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  const _NavigatorWidget({
    required this.currentMonth,
    this.minDate,
    this.maxDate,
    required this.theme,
    this.navigatorBuilder,
    required this.locale,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = MCalLocalizations();
    final isRTL = localizations.isRTL(locale);

    // Calculate if navigation is allowed
    final canGoPrevious = _canGoPrevious();
    final canGoNext = _canGoNext();

    // Format month/year display
    final monthName = _getMonthName(localizations);
    final year = currentMonth.year.toString();
    final monthYearText = '$monthName $year';

    // Build default navigator - use Expanded for text to prevent overflow
    Widget navigator = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(color: theme.navigatorBackgroundColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Semantics(
            label: 'Previous month',
            button: true,
            enabled: canGoPrevious,
            child: IconButton(
              icon: Icon(isRTL ? Icons.chevron_right : Icons.chevron_left),
              onPressed: canGoPrevious ? onPrevious : null,
              tooltip: 'Previous month',
            ),
          ),
          Expanded(
            child: Semantics(
              label: monthYearText,
              header: true,
              child: Text(
                monthYearText,
                style: theme.navigatorTextStyle,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                label: 'Next month',
                button: true,
                enabled: canGoNext,
                child: IconButton(
                  icon: Icon(isRTL ? Icons.chevron_left : Icons.chevron_right),
                  onPressed: canGoNext ? onNext : null,
                  tooltip: 'Next month',
                ),
              ),
              Semantics(
                label: localizations.getLocalizedString('today', locale),
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.today),
                  onPressed: onToday,
                  tooltip: localizations.getLocalizedString('today', locale),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // Apply builder callback if provided
    if (navigatorBuilder != null) {
      final contextObj = MCalNavigatorContext(
        currentMonth: currentMonth,
        onPrevious: onPrevious,
        onNext: onNext,
        onToday: onToday,
        canGoPrevious: canGoPrevious,
        canGoNext: canGoNext,
        locale: locale,
      );
      navigator = navigatorBuilder!(context, contextObj, navigator);
    }

    // Wrap in Directionality for RTL support
    // Note: Using enum values directly - TextDirection is an enum from dart:ui
    final textDirection = isRTL ? TextDirection.rtl : TextDirection.ltr;
    return Directionality(textDirection: textDirection, child: navigator);
  }

  /// Checks if navigation to previous month is allowed.
  bool _canGoPrevious() {
    if (minDate == null) return true;
    final previousMonth = currentMonth.month == 1
        ? DateTime(currentMonth.year - 1, 12, 1)
        : DateTime(currentMonth.year, currentMonth.month - 1, 1);
    final minMonth = DateTime(minDate!.year, minDate!.month, 1);
    return !previousMonth.isBefore(minMonth);
  }

  /// Checks if navigation to next month is allowed.
  bool _canGoNext() {
    if (maxDate == null) return true;
    final nextMonth = currentMonth.month == 12
        ? DateTime(currentMonth.year + 1, 1, 1)
        : DateTime(currentMonth.year, currentMonth.month + 1, 1);
    final maxMonth = DateTime(maxDate!.year, maxDate!.month, 1);
    return !nextMonth.isAfter(maxMonth);
  }

  /// Gets the localized month name.
  String _getMonthName(MCalLocalizations localizations) {
    final monthKeys = [
      'monthJanuary',
      'monthFebruary',
      'monthMarch',
      'monthApril',
      'monthMay',
      'monthJune',
      'monthJuly',
      'monthAugust',
      'monthSeptember',
      'monthOctober',
      'monthNovember',
      'monthDecember',
    ];
    return localizations.getLocalizedString(
      monthKeys[currentMonth.month - 1],
      locale,
    );
  }
}

/// CustomPainter for rendering drop target highlights efficiently.
///
/// This is the default highlight renderer used when neither
/// [MCalMonthView.dropTargetOverlayBuilder] nor [MCalMonthView.dropTargetCellBuilder]
/// is provided. It draws colored rounded rectangles for each highlighted cell.
class _DropTargetHighlightPainter extends CustomPainter {
  /// The list of cells to highlight.
  final List<MCalHighlightCellInfo> highlightedCells;

  /// Whether the drop target is valid.
  final bool isValid;

  /// Color for valid drop targets.
  final Color validColor;

  /// Color for invalid drop targets.
  final Color invalidColor;

  /// Border radius for the highlight rectangles.
  final double borderRadius;

  /// Creates a new [_DropTargetHighlightPainter].
  _DropTargetHighlightPainter({
    required this.highlightedCells,
    required this.isValid,
    this.validColor = const Color(0x4000FF00),
    this.invalidColor = const Color(0x40FF0000),
    this.borderRadius = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (highlightedCells.isEmpty) return;

    final paint = Paint()
      ..color = isValid ? validColor : invalidColor
      ..style = PaintingStyle.fill;

    for (final cell in highlightedCells) {
      final rrect = RRect.fromRectAndRadius(
        cell.bounds,
        Radius.circular(borderRadius),
      );
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(_DropTargetHighlightPainter oldDelegate) {
    // Check if we need to repaint
    if (oldDelegate.isValid != isValid) return true;
    if (oldDelegate.highlightedCells.length != highlightedCells.length)
      return true;
    if (oldDelegate.validColor != validColor) return true;
    if (oldDelegate.invalidColor != invalidColor) return true;
    if (oldDelegate.borderRadius != borderRadius) return true;

    // Deep compare cells (by reference should be sufficient if list is rebuilt)
    if (!identical(oldDelegate.highlightedCells, highlightedCells)) {
      // Compare bounds of first and last cell as quick check
      if (highlightedCells.isNotEmpty &&
          oldDelegate.highlightedCells.isNotEmpty) {
        if (highlightedCells.first.bounds !=
                oldDelegate.highlightedCells.first.bounds ||
            highlightedCells.last.bounds !=
                oldDelegate.highlightedCells.last.bounds) {
          return true;
        }
      }
    }

    return false;
  }
}
