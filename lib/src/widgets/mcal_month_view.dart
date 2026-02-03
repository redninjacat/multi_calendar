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
import 'mcal_callback_details.dart';
import 'mcal_drag_handler.dart';
import 'mcal_draggable_event_tile.dart';
import 'mcal_month_view_contexts.dart';
import 'mcal_multi_day_renderer.dart';
import 'mcal_multi_day_tile.dart';

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
///   initialDate: DateTime.now(),
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
  ///
  /// The widget will display the month containing this date. If not provided,
  /// the current month is displayed.
  final DateTime? initialDate;

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

  /// Custom theme data for calendar styling.
  ///
  /// If not provided, the widget will attempt to resolve theme from the
  /// widget tree's ThemeData, or use sensible defaults.
  final MCalThemeData? theme;

  /// Builder callback for customizing day cell rendering.
  ///
  /// Receives the build context, [MCalDayCellContext] with cell data, and
  /// the default cell widget. Return a custom widget to override the default.
  final Widget Function(BuildContext, MCalDayCellContext, Widget)? dayCellBuilder;

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
  final bool Function(BuildContext, MCalCellInteractivityDetails)? cellInteractivityCallback;

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
  final void Function(BuildContext, MCalSwipeNavigationDetails)? onSwipeNavigation;

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
  final void Function(BuildContext, MCalOverflowTapDetails)? onOverflowLongPress;

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
  /// Defaults to 3.
  final int maxVisibleEvents;

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
  final Widget Function(BuildContext context, MCalWeekNumberContext weekContext)? weekNumberBuilder;

  // ============ Accessibility ============

  /// Semantic label for the entire calendar widget.
  ///
  /// Used by screen readers to describe the calendar. If not provided,
  /// a default label will be generated based on the current month.
  final String? semanticsLabel;

  // ============ Multi-day event rendering ============

  /// Whether to render multi-day events as contiguous tiles spanning cells.
  ///
  /// When true (default), multi-day events are rendered as single tiles that
  /// span across multiple day cells, positioned at the top of each week row.
  /// This provides a cleaner visual representation similar to Google Calendar.
  ///
  /// When false, multi-day events are rendered in each day cell independently,
  /// using the traditional per-cell rendering approach.
  ///
  /// Defaults to true.
  final bool renderMultiDayEventsAsContiguous;

  /// Builder callback for customizing multi-day event tile rendering.
  ///
  /// Receives the build context and [MCalMultiDayTileDetails] with complete
  /// information about the tile's position within the event and row.
  /// Return a custom widget to override the default multi-day tile rendering.
  ///
  /// This is only used when [renderMultiDayEventsAsContiguous] is true.
  final Widget Function(BuildContext, MCalMultiDayTileDetails)?
      multiDayEventTileBuilder;

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
      dragSourceBuilder;

  /// Builder callback for customizing the drag target preview widget.
  ///
  /// When provided, this builder creates a preview widget shown when
  /// hovering over a potential drop target. Receives [MCalDragTargetDetails]
  /// with the event, target date, and validity state.
  ///
  /// Only used when [enableDragAndDrop] is true.
  final Widget Function(BuildContext, MCalDragTargetDetails)?
      dragTargetBuilder;

  /// Builder callback for customizing drop target cell appearance.
  ///
  /// When provided, this builder customizes how cells appear during drag
  /// when they are potential drop targets. Receives [MCalDropTargetCellDetails]
  /// with the cell date, validity state, and dragged event.
  ///
  /// If not provided, valid targets show a green overlay and invalid targets
  /// show a red overlay using theme colors.
  ///
  /// Only used when [enableDragAndDrop] is true.
  final Widget Function(BuildContext, MCalDropTargetCellDetails)?
      dropTargetCellBuilder;

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
  final bool Function(BuildContext, MCalEventDroppedDetails)?
      onEventDropped;

  /// The delay before edge navigation triggers during drag operations.
  ///
  /// When the user drags an event tile near the left or right edge of the
  /// calendar, a timer starts. If the drag position remains near the edge
  /// for this duration, the calendar navigates to the previous or next month.
  ///
  /// This enables seamless cross-month drag-and-drop operations without
  /// requiring the user to manually navigate.
  ///
  /// Defaults to 500 milliseconds.
  ///
  /// Only used when [enableDragAndDrop] is true.
  final Duration dragEdgeNavigationDelay;

  /// Creates a new [MCalMonthView] widget.
  ///
  /// The [controller] parameter is required. All other parameters are optional.
  const MCalMonthView({
    super.key,
    required this.controller,
    this.initialDate,
    this.minDate,
    this.maxDate,
    this.firstDayOfWeek,
    this.showNavigator = false,
    this.enableSwipeNavigation = false,
    this.swipeNavigationDirection = MCalSwipeNavigationDirection.horizontal,
    this.theme,
    this.dayCellBuilder,
    this.eventTileBuilder,
    this.dayHeaderBuilder,
    this.navigatorBuilder,
    this.dateLabelBuilder,
    this.cellInteractivityCallback,
    this.onCellTap,
    this.onCellLongPress,
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
    this.maxVisibleEvents = 3,
    // State builders
    this.loadingBuilder,
    this.errorBuilder,
    // Week numbers
    this.showWeekNumbers = false,
    this.weekNumberBuilder,
    // Accessibility
    this.semanticsLabel,
    // Multi-day event rendering
    this.renderMultiDayEventsAsContiguous = true,
    this.multiDayEventTileBuilder,
    // Drag-and-drop
    this.enableDragAndDrop = false,
    this.draggedTileBuilder,
    this.dragSourceBuilder,
    this.dragTargetBuilder,
    this.dropTargetCellBuilder,
    this.onDragWillAccept,
    this.onEventDropped,
    this.dragEdgeNavigationDelay = const Duration(milliseconds: 500),
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
    
    // IMPORTANT: Defer initialDate setup to post-frame to avoid triggering
    // setState on other widgets that share this controller during their build.
    // Also fire initial callbacks after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      // Set initial date if provided (deferred to avoid build-phase conflicts)
      if (widget.initialDate != null) {
        widget.controller.setDisplayDate(
          DateTime(widget.initialDate!.year, widget.initialDate!.month, 1),
        );
      }
      
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
    final referenceMonths = _referenceMonth.year * 12 + _referenceMonth.month - 1;
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
    final referenceMonths = _referenceMonth.year * 12 + _referenceMonth.month - 1;
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
    if (newMonth.year == previousMonth.year && newMonth.month == previousMonth.month) {
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
    final displayDateChanged = _previousDisplayDate == null ||
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
            23, 59, 59, 999,
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
      _pageController.animateToPage(
        targetPageIndex,
        duration: widget.animationDuration,
        curve: widget.animationCurve,
      ).then((_) {
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
    final isBuildPhase = phase == SchedulerPhase.persistentCallbacks ||
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

  /// Gets events for a specific month from the controller.
  ///
  /// Filters events from the controller's loaded events that fall within
  /// the specified month's date range.
  List<MCalCalendarEvent> _getEventsForMonth(DateTime month) {
    final monthRange = getMonthRange(month);
    return widget.controller.getEventsForRange(monthRange);
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
      // Use custom boundary physics that provides bounce-back at min/max dates
      physics = _MCalBoundaryScrollPhysics(
        parent: const PageScrollPhysics(),
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
      scrollDirection: widget.swipeNavigationDirection == MCalSwipeNavigationDirection.vertical
          ? Axis.vertical
          : Axis.horizontal,
      // Reverse for RTL languages when horizontal
      reverse: isRTL && widget.swipeNavigationDirection == MCalSwipeNavigationDirection.horizontal,
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
          onEventTap: widget.onEventTap,
          onEventLongPress: widget.onEventLongPress,
          onHoverCell: widget.onHoverCell,
          onHoverEvent: widget.onHoverEvent,
          maxVisibleEvents: widget.maxVisibleEvents,
          onOverflowTap: widget.onOverflowTap,
          onOverflowLongPress: widget.onOverflowLongPress,
          showWeekNumbers: widget.showWeekNumbers,
          weekNumberBuilder: widget.weekNumberBuilder,
          autoFocusOnCellTap: widget.autoFocusOnCellTap,
          getEventsForMonth: _getEventsForMonth,
          renderMultiDayEventsAsContiguous: widget.renderMultiDayEventsAsContiguous,
          multiDayEventTileBuilder: widget.multiDayEventTileBuilder,
          // Drag-and-drop
          enableDragAndDrop: widget.enableDragAndDrop,
          draggedTileBuilder: widget.draggedTileBuilder,
          dragSourceBuilder: widget.dragSourceBuilder,
          dragTargetBuilder: widget.dragTargetBuilder,
          dropTargetCellBuilder: widget.dropTargetCellBuilder,
          onDragWillAccept: widget.onDragWillAccept,
          onEventDropped: widget.onEventDropped,
          // Drag lifecycle callbacks for cross-month navigation (Task 20)
          // and drag cancellation handling (Task 21)
          onDragStartedCallback: _handleDragStarted,
          onDragEndedCallback: _handleDragEnded,
          onDragCanceledCallback: _handleDragCancelled,
        );
      },
    );

    // Wrap in Directionality for RTL support
    final textDirection = isRTL ? TextDirection.rtl : TextDirection.ltr;
    return Directionality(textDirection: textDirection, child: pageView);
  }
  /// Resolves the calendar theme from widget, context, or defaults.
  MCalThemeData _resolveTheme(BuildContext context) {
    final theme = Theme.of(context);
    final extension = theme.extension<MCalThemeData>();

    return widget.theme ?? extension ?? MCalThemeData.fromTheme(theme);
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
      children: [
        calendarContent,
        if (overlay != null) overlay,
      ],
    );

    // Generate default semantics label if not provided
    final localizations = MCalLocalizations();
    final defaultSemanticsLabel = '${localizations.getLocalizedString('calendar', locale)}, ${localizations.formatMonthYear(_currentMonth, locale)}';
    final semanticsLabel = widget.semanticsLabel ?? defaultSemanticsLabel;

    // Wrap in Focus widget for keyboard navigation and drag cancellation (Task 21)
    // Use Listener to capture pointer events and request focus without 
    // competing with child gesture detectors
    // Wrap entire widget tree with MCalTheme so descendants can access theme via MCalTheme.of(context)
    // Use LayoutBuilder to get the calendar size for edge detection during drag
    // Enable key events if keyboard navigation OR drag-and-drop is enabled
    // (drag-and-drop needs Escape key for cancellation)
    final enableKeyEvents = widget.enableKeyboardNavigation || widget.enableDragAndDrop;
    
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
                onPointerUp: (_) {
                  // Clean up drag state when pointer is released
                  if (_isDragActive) {
                    _handleDragEnded(false);
                  }
                },
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
    DateTime focusedDate = widget.controller.focusedDate ?? 
        widget.controller.displayDate;
    
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
      final lastDayOfPrevMonth = DateTime(prevMonth.year, prevMonth.month + 1, 0).day;
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
      final lastDayOfNextMonth = DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
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
      final newFocusMonth = DateTime(newFocusedDate.year, newFocusedDate.month, 1);
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
      final checkDate = DateTime(focusedDate.year, focusedDate.month, focusedDate.day);
      return (checkDate.isAtSameMomentAs(eventStart) ||
          checkDate.isAtSameMomentAs(eventEnd) ||
          (checkDate.isAfter(eventStart) && checkDate.isBefore(eventEnd)));
    }).toList();

    // Determine if it's in the current month
    final isCurrentMonth = focusedDate.year == _currentMonth.year &&
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
    _dragHandler?.cancelDrag();
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
    
    // Get the local position within the calendar widget
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final localPosition = renderBox.globalToLocal(globalPosition);
    
    // Check if near left edge
    final nearLeftEdge = localPosition.dx < _edgeProximityThreshold;
    
    // Check if near right edge
    final nearRightEdge = localPosition.dx > (calendarSize.width - _edgeProximityThreshold);
    
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

  /// Spring description for bounce-back animation.
  @override
  SpringDescription get spring => const SpringDescription(
    mass: 0.5,
    stiffness: 100.0,
    damping: 1.0,
  );
}

/// Widget for rendering a single month page in the PageView.
///
/// This widget is used by [MCalMonthView]'s PageView.builder to render
/// each month's grid. It calculates and displays the dates for the given month.
class _MonthPageWidget extends StatelessWidget {
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
  final Widget Function(BuildContext, MCalDayCellContext, Widget)? dayCellBuilder;
  final Widget Function(BuildContext, MCalEventTileContext, Widget)? eventTileBuilder;
  final Widget Function(BuildContext, MCalDateLabelContext, String)? dateLabelBuilder;
  final String? dateFormat;
  final bool Function(BuildContext, MCalCellInteractivityDetails)? cellInteractivityCallback;
  final void Function(BuildContext, MCalCellTapDetails)? onCellTap;
  final void Function(BuildContext, MCalCellTapDetails)? onCellLongPress;
  final void Function(BuildContext, MCalEventTapDetails)? onEventTap;
  final void Function(BuildContext, MCalEventTapDetails)? onEventLongPress;
  final ValueChanged<MCalDayCellContext?>? onHoverCell;
  final ValueChanged<MCalEventTileContext?>? onHoverEvent;
  final int maxVisibleEvents;
  final void Function(BuildContext, MCalOverflowTapDetails)? onOverflowTap;
  final void Function(BuildContext, MCalOverflowTapDetails)? onOverflowLongPress;
  final bool showWeekNumbers;
  final Widget Function(BuildContext, MCalWeekNumberContext)? weekNumberBuilder;
  final bool autoFocusOnCellTap;
  
  /// Function to get events for a specific month.
  final List<MCalCalendarEvent> Function(DateTime month) getEventsForMonth;
  
  /// Whether to render multi-day events as contiguous tiles.
  final bool renderMultiDayEventsAsContiguous;
  
  /// Builder for custom multi-day event tile rendering.
  final Widget Function(BuildContext, MCalMultiDayTileDetails)?
      multiDayEventTileBuilder;

  // Drag-and-drop parameters
  final bool enableDragAndDrop;
  final Widget Function(BuildContext, MCalDraggedTileDetails)?
      draggedTileBuilder;
  final Widget Function(BuildContext, MCalDragSourceDetails)?
      dragSourceBuilder;
  final Widget Function(BuildContext, MCalDragTargetDetails)?
      dragTargetBuilder;
  final Widget Function(BuildContext, MCalDropTargetCellDetails)?
      dropTargetCellBuilder;
  final bool Function(BuildContext, MCalDragWillAcceptDetails)?
      onDragWillAccept;
  final bool Function(BuildContext, MCalEventDroppedDetails)?
      onEventDropped;

  // Drag lifecycle callbacks (Task 21)
  final void Function(MCalCalendarEvent event, DateTime sourceDate)?
      onDragStartedCallback;
  final void Function(bool wasAccepted)? onDragEndedCallback;
  final VoidCallback? onDragCanceledCallback;

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
    this.onEventTap,
    this.onEventLongPress,
    this.onHoverCell,
    this.onHoverEvent,
    this.maxVisibleEvents = 3,
    this.onOverflowTap,
    this.onOverflowLongPress,
    this.showWeekNumbers = false,
    this.weekNumberBuilder,
    this.autoFocusOnCellTap = true,
    this.renderMultiDayEventsAsContiguous = true,
    this.multiDayEventTileBuilder,
    // Drag-and-drop
    this.enableDragAndDrop = false,
    this.draggedTileBuilder,
    this.dragSourceBuilder,
    this.dragTargetBuilder,
    this.dropTargetCellBuilder,
    this.onDragWillAccept,
    this.onEventDropped,
    // Drag lifecycle callbacks (Task 21)
    this.onDragStartedCallback,
    this.onDragEndedCallback,
    this.onDragCanceledCallback,
  });

  @override
  Widget build(BuildContext context) {
    // Generate dates for this month
    final dates = generateMonthDates(month, firstDayOfWeek);

    // Get events for this specific month (may differ from currentDisplayMonth)
    final monthEvents = (month.year == currentDisplayMonth.year && 
                         month.month == currentDisplayMonth.month)
        ? events
        : getEventsForMonth(month);

    // Group dates into weeks (7 dates per week)
    final weeks = <List<DateTime>>[];
    for (int i = 0; i < dates.length; i += 7) {
      weeks.add(dates.sublist(i, i + 7));
    }

    // Calculate multi-day event layouts if contiguous rendering is enabled
    List<MCalMultiDayEventLayout>? multiDayLayouts;
    if (renderMultiDayEventsAsContiguous) {
      multiDayLayouts = MCalMultiDayRenderer.calculateLayouts(
        events: monthEvents,
        monthStart: month,
        firstDayOfWeek: firstDayOfWeek,
      );
    }

    return Column(
      children: weeks.asMap().entries.map((entry) {
        final weekRowIndex = entry.key;
        final weekDates = entry.value;
        
        // Get layouts for this week row
        List<MCalMultiDayEventLayout>? weekLayouts;
        if (multiDayLayouts != null) {
          weekLayouts = multiDayLayouts
              .where((layout) => layout.rowSegments
                  .any((segment) => segment.weekRowIndex == weekRowIndex))
              .toList();
        }
        
        return Expanded(
          child: _WeekRowWidget(
            dates: weekDates,
            currentMonth: month, // Use this page's month for styling
            events: monthEvents,
            theme: theme,
            focusedDate: controller.focusedDate,
            autoFocusOnCellTap: autoFocusOnCellTap,
            onSetFocusedDate: (date) {
              controller.setFocusedDate(date);
            },
            dayCellBuilder: dayCellBuilder,
            eventTileBuilder: eventTileBuilder,
            dateLabelBuilder: dateLabelBuilder,
            dateFormat: dateFormat,
            cellInteractivityCallback: cellInteractivityCallback,
            onCellTap: onCellTap,
            onCellLongPress: onCellLongPress,
            onEventTap: onEventTap,
            onEventLongPress: onEventLongPress,
            onHoverCell: onHoverCell,
            onHoverEvent: onHoverEvent,
            locale: locale,
            maxVisibleEvents: maxVisibleEvents,
            onOverflowTap: onOverflowTap,
            onOverflowLongPress: onOverflowLongPress,
            showWeekNumbers: showWeekNumbers,
            weekNumberBuilder: weekNumberBuilder,
            renderMultiDayEventsAsContiguous: renderMultiDayEventsAsContiguous,
            multiDayEventTileBuilder: multiDayEventTileBuilder,
            weekRowIndex: weekRowIndex,
            multiDayLayouts: weekLayouts,
            // Drag-and-drop
            enableDragAndDrop: enableDragAndDrop,
            draggedTileBuilder: draggedTileBuilder,
            dragSourceBuilder: dragSourceBuilder,
            dragTargetBuilder: dragTargetBuilder,
            dropTargetCellBuilder: dropTargetCellBuilder,
            onDragWillAccept: onDragWillAccept,
            onEventDropped: onEventDropped,
            controller: controller,
            // Drag lifecycle callbacks (Task 21)
            onDragStartedCallback: onDragStartedCallback,
            onDragEndedCallback: onDragEndedCallback,
            onDragCanceledCallback: onDragCanceledCallback,
          ),
        );
      }).toList(),
    );
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
          style: theme.weekNumberTextStyle ??
              TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
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
        child: const Center(
          child: CircularProgressIndicator(),
        ),
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
                    style: theme.cellTextStyle?.copyWith(
                      fontSize: 14,
                    ) ?? const TextStyle(fontSize: 14),
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
class _WeekRowWidget extends StatelessWidget {
  final List<DateTime> dates;
  final DateTime currentMonth;
  final List<MCalCalendarEvent> events;
  final MCalThemeData theme;
  final DateTime? focusedDate;
  final bool autoFocusOnCellTap;
  final ValueChanged<DateTime>? onSetFocusedDate;
  final Widget Function(BuildContext, MCalDayCellContext, Widget)? dayCellBuilder;
  final Widget Function(BuildContext, MCalEventTileContext, Widget)?
  eventTileBuilder;
  final Widget Function(BuildContext, MCalDateLabelContext, String)?
  dateLabelBuilder;
  final String? dateFormat;
  final bool Function(BuildContext, MCalCellInteractivityDetails)? cellInteractivityCallback;
  final void Function(BuildContext, MCalCellTapDetails)? onCellTap;
  final void Function(BuildContext, MCalCellTapDetails)? onCellLongPress;
  final void Function(BuildContext, MCalEventTapDetails)? onEventTap;
  final void Function(BuildContext, MCalEventTapDetails)? onEventLongPress;
  final ValueChanged<MCalDayCellContext?>? onHoverCell;
  final ValueChanged<MCalEventTileContext?>? onHoverEvent;
  final Locale locale;
  final int maxVisibleEvents;
  final void Function(BuildContext, MCalOverflowTapDetails)? onOverflowTap;
  final void Function(BuildContext, MCalOverflowTapDetails)? onOverflowLongPress;
  final bool showWeekNumbers;
  final Widget Function(BuildContext, MCalWeekNumberContext)? weekNumberBuilder;
  
  /// Whether to render multi-day events as contiguous tiles.
  final bool renderMultiDayEventsAsContiguous;
  
  /// Builder for custom multi-day event tile rendering.
  final Widget Function(BuildContext, MCalMultiDayTileDetails)?
      multiDayEventTileBuilder;
  
  /// The index of this week row within the month grid.
  final int weekRowIndex;
  
  /// Multi-day event layouts for this week row.
  final List<MCalMultiDayEventLayout>? multiDayLayouts;

  // Drag-and-drop parameters
  final bool enableDragAndDrop;
  final Widget Function(BuildContext, MCalDraggedTileDetails)?
      draggedTileBuilder;
  final Widget Function(BuildContext, MCalDragSourceDetails)?
      dragSourceBuilder;
  final Widget Function(BuildContext, MCalDragTargetDetails)?
      dragTargetBuilder;
  final Widget Function(BuildContext, MCalDropTargetCellDetails)?
      dropTargetCellBuilder;
  final bool Function(BuildContext, MCalDragWillAcceptDetails)?
      onDragWillAccept;
  final bool Function(BuildContext, MCalEventDroppedDetails)?
      onEventDropped;
  final MCalEventController controller;

  // Drag lifecycle callbacks (Task 21)
  final void Function(MCalCalendarEvent event, DateTime sourceDate)?
      onDragStartedCallback;
  final void Function(bool wasAccepted)? onDragEndedCallback;
  final VoidCallback? onDragCanceledCallback;

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
    this.onEventTap,
    this.onEventLongPress,
    this.onHoverCell,
    this.onHoverEvent,
    required this.locale,
    this.maxVisibleEvents = 3,
    this.onOverflowTap,
    this.onOverflowLongPress,
    this.showWeekNumbers = false,
    this.weekNumberBuilder,
    this.renderMultiDayEventsAsContiguous = true,
    this.multiDayEventTileBuilder,
    this.weekRowIndex = 0,
    this.multiDayLayouts,
    // Drag-and-drop
    this.enableDragAndDrop = false,
    this.draggedTileBuilder,
    this.dragSourceBuilder,
    this.dragTargetBuilder,
    this.dropTargetCellBuilder,
    this.onDragWillAccept,
    this.onEventDropped,
    required this.controller,
    // Drag lifecycle callbacks (Task 21)
    this.onDragStartedCallback,
    this.onDragEndedCallback,
    this.onDragCanceledCallback,
  });

  /// Total height of the date label including top padding.
  /// This should match the value used in _DayCellWidget (20.0 label + 4.0 top padding).
  static const double dateLabelHeightWithPadding = 24.0;

  @override
  Widget build(BuildContext context) {
    // Determine text direction for RTL support
    final textDirection = Directionality.of(context);
    final isRTL = textDirection == TextDirection.rtl;
    
    // Calculate the layout frame using greedy first-fit algorithm
    MCalWeekEventLayoutFrame? layoutFrame;
    if (renderMultiDayEventsAsContiguous && 
        multiDayLayouts != null && 
        multiDayLayouts!.isNotEmpty) {
      layoutFrame = MCalMultiDayRenderer.calculateWeekLayout(
        multiDayLayouts: multiDayLayouts!,
        weekDates: dates,
        weekRowIndex: weekRowIndex,
      );
    }
    
    // Get row count from layout frame
    final multiDayRowCount = layoutFrame?.totalRows ?? 0;
    
    // Get theme-based tile height (slot height including margins)
    final tileHeight = theme.eventTileHeight ?? 20.0;
    
    // Calculate the height needed for multi-day events area (below date label)
    // Each row = tileHeight (margins are inside the tile, no additional spacing)
    final multiDayAreaHeight = multiDayRowCount > 0
        ? multiDayRowCount * tileHeight
        : 0.0;
    
    // No additional offset needed - dateLabelHeightWithPadding includes the spacing
    const multiDayTopOffset = 0.0;

    // Build the day cells
    final dayCells = dates.asMap().entries.map((entry) {
        final dayIndex = entry.key;
        final date = entry.value;
        final isCurrentMonth =
            date.year == currentMonth.year && date.month == currentMonth.month;
        final isToday = _isToday(date);
        
        // Get all events for this date (used for callbacks)
        final allDayEvents = _getEventsForDate(date);
        
        // Filter out multi-day events for rendering if contiguous rendering is enabled
        // Multi-day events are rendered separately as contiguous tiles
        final eventsForRendering = renderMultiDayEventsAsContiguous
            ? allDayEvents.where((e) => !MCalMultiDayRenderer.isMultiDay(e)).toList()
            : allDayEvents;
        
        // Check if this date is focused
        final isFocused = focusedDate != null &&
            date.year == focusedDate!.year &&
            date.month == focusedDate!.month &&
            date.day == focusedDate!.day;
        
        // Calculate multi-day reserved height for this specific day column
        // Uses per-column occupancy from the layout frame
        double dayMultiDayReservedHeight = 0.0;
        if (layoutFrame != null && multiDayAreaHeight > 0) {
          final rowsAtColumn = layoutFrame.rowCountAtColumn(dayIndex);
          if (rowsAtColumn > 0) {
            // Calculate height based on how many rows occupy this column
            // No additional spacing - margins are inside tiles
            dayMultiDayReservedHeight = rowsAtColumn * tileHeight;
          }
        }

        return Expanded(
          child: _DayCellWidget(
            date: date,
            displayMonth: currentMonth,
            isCurrentMonth: isCurrentMonth,
            isToday: isToday,
            isSelectable: true,
            isFocused: isFocused,
            autoFocusOnCellTap: autoFocusOnCellTap,
            onSetFocusedDate: onSetFocusedDate,
            events: allDayEvents, // All events for callbacks
            eventsForRendering: eventsForRendering, // Filtered events for tile rendering
            theme: theme,
            dayCellBuilder: dayCellBuilder,
            eventTileBuilder: eventTileBuilder,
            dateLabelBuilder: dateLabelBuilder,
            dateFormat: dateFormat,
            cellInteractivityCallback: cellInteractivityCallback,
            onCellTap: onCellTap,
            onCellLongPress: onCellLongPress,
            onEventTap: onEventTap,
            onEventLongPress: onEventLongPress,
            onHoverCell: onHoverCell,
            onHoverEvent: onHoverEvent,
            locale: locale,
            maxVisibleEvents: maxVisibleEvents,
            onOverflowTap: onOverflowTap,
            onOverflowLongPress: onOverflowLongPress,
            // Use per-column reserved height for accurate single-day event offsetting
            multiDayReservedHeight: dayMultiDayReservedHeight,
            // Drag-and-drop
            enableDragAndDrop: enableDragAndDrop,
            draggedTileBuilder: draggedTileBuilder,
            dragSourceBuilder: dragSourceBuilder,
            dragTargetBuilder: dragTargetBuilder,
            dropTargetCellBuilder: dropTargetCellBuilder,
            onDragWillAccept: onDragWillAccept,
            onEventDropped: onEventDropped,
            controller: controller,
            // Drag lifecycle callbacks (Task 21)
            onDragStartedCallback: onDragStartedCallback,
            onDragEndedCallback: onDragEndedCallback,
            onDragCanceledCallback: onDragCanceledCallback,
          ),
        );
      }).toList();

    // Calculate week number from the first day of the week
    final firstDayOfWeek = dates.first;
    final weekNumber = getISOWeekNumber(firstDayOfWeek);

    // Build week number cell if needed
    Widget? weekNumberCell;
    if (showWeekNumbers) {
      weekNumberCell = _WeekNumberCell(
        weekNumber: weekNumber,
        firstDayOfWeek: firstDayOfWeek,
        theme: theme,
        weekNumberBuilder: weekNumberBuilder,
      );
    }

    // Build the base row with day cells (and optional week number)
    final List<Widget> rowChildren;
    if (weekNumberCell != null) {
      rowChildren = isRTL
          ? [...dayCells, weekNumberCell]
          : [weekNumberCell, ...dayCells];
    } else {
      rowChildren = dayCells;
    }

    final dayRow = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rowChildren,
    );

    // If multi-day contiguous rendering is enabled and we have a layout frame,
    // overlay the multi-day tiles on top of the day row
    if (renderMultiDayEventsAsContiguous && layoutFrame != null && multiDayRowCount > 0) {
      return ClipRect(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Day cells fill the entire row
            dayRow,
            // Multi-day event tiles positioned below date labels
            // Uses dateLabelHeightWithPadding to align with single-day tiles in cells
            Positioned(
              top: dateLabelHeightWithPadding + multiDayTopOffset,
              left: showWeekNumbers && !isRTL ? _WeekNumberCell.columnWidth : 0,
              right: showWeekNumbers && isRTL ? _WeekNumberCell.columnWidth : 0,
              height: multiDayAreaHeight,
              child: ClipRect(
                child: _MultiDayEventRowsWidget(
                  layoutFrame: layoutFrame,
                  theme: theme,
                  multiDayEventTileBuilder: multiDayEventTileBuilder,
                  onEventTap: onEventTap,
                  onEventLongPress: onEventLongPress,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return dayRow;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  List<MCalCalendarEvent> _getEventsForDate(DateTime date) {
    final matchingEvents = events.where((event) {
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

/// Widget for rendering multi-day event tiles at the top of a week row.
///
/// This widget renders contiguous tiles for multi-day events that span
/// across multiple day cells. Each tile is positioned to span the
/// appropriate cells based on the event's layout segments.
class _MultiDayEventRowsWidget extends StatelessWidget {
  /// The layout frame containing positioned event assignments.
  final MCalWeekEventLayoutFrame layoutFrame;
  
  /// The theme for styling.
  final MCalThemeData theme;
  
  /// Custom builder for multi-day tiles.
  final Widget Function(BuildContext, MCalMultiDayTileDetails)?
      multiDayEventTileBuilder;
  
  /// Callback when event is tapped.
  final void Function(BuildContext, MCalEventTapDetails)? onEventTap;
  
  /// Callback when event is long-pressed.
  final void Function(BuildContext, MCalEventTapDetails)? onEventLongPress;

  const _MultiDayEventRowsWidget({
    required this.layoutFrame,
    required this.theme,
    this.multiDayEventTileBuilder,
    this.onEventTap,
    this.onEventLongPress,
  });
  
  /// Gets the tile slot height from theme or uses default.
  /// This is the total height per row including margins.
  double _getTileHeight() => theme.eventTileHeight ?? 20.0;

  @override
  Widget build(BuildContext context) {
    if (layoutFrame.assignments.isEmpty) {
      return const SizedBox.shrink();
    }

    final tileHeight = _getTileHeight();

    // Calculate total height: rows * tileHeight
    // No additional spacing needed - tile margins handle visual gaps
    final totalHeight = layoutFrame.totalRows * tileHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth / 7;

        // Build children with LayoutId wrappers
        final children = <Widget>[];

        for (int i = 0; i < layoutFrame.assignments.length; i++) {
          final assignment = layoutFrame.assignments[i];
          final event = assignment.event;
          final segment = assignment.segment;

          // Calculate display date (first day of this segment)
          final displayDate = layoutFrame.weekDates[segment.startDayInRow];

          // Build the tile details
          final eventStartDay = DateTime(
              event.start.year, event.start.month, event.start.day);
          final eventEndDay =
              DateTime(event.end.year, event.end.month, event.end.day);
          final totalDaysInEvent =
              eventEndDay.difference(eventStartDay).inDays + 1;
          final dayIndexInEvent = displayDate.difference(eventStartDay).inDays;

          final details = MCalMultiDayTileDetails(
            event: event,
            displayDate: displayDate,
            isFirstDayOfEvent: segment.isFirstSegment,
            isLastDayOfEvent: segment.isLastSegment,
            isFirstDayInRow: true, // Always true for segment start
            isLastDayInRow: true, // Always true for segment end
            dayIndexInEvent: dayIndexInEvent,
            totalDaysInEvent: totalDaysInEvent,
            dayIndexInRow: 0,
            totalDaysInRow: segment.spanDays,
            rowIndex: assignment.row,
            totalRows: layoutFrame.totalRows,
          );

          // Build the tile widget
          Widget tile;
          if (multiDayEventTileBuilder != null) {
            tile = multiDayEventTileBuilder!(context, details);
          } else {
            tile = MCalMultiDayTile(
              event: event,
              details: details,
              onTap: onEventTap,
              onLongPress: onEventLongPress,
            );
          }

          // Wrap in Semantics for accessibility
          tile = Semantics(
            label: '${event.title}, multi-day event',
            child: tile,
          );

          children.add(LayoutId(
            id: i,
            child: tile,
          ));
        }

        // Get margin values from theme
        final horizontalMargin = theme.eventTileHorizontalSpacing ?? 1.0;
        final verticalMargin = theme.eventTileVerticalSpacing ?? 1.0;

        // DEBUG: Set to true to visualize multi-day event area
        const bool debugMultiDaySpacing = false;

        return Container(
          height: totalHeight,
          // DEBUG: Blue border shows the multi-day events area bounds
          decoration: debugMultiDaySpacing
              ? BoxDecoration(border: Border.all(color: Colors.blue, width: 0.5))
              : null,
          child: CustomMultiChildLayout(
            delegate: _MultiDayLayoutDelegate(
              layoutFrame: layoutFrame,
              cellWidth: cellWidth,
              rowHeight: tileHeight,
              horizontalMargin: horizontalMargin,
              verticalMargin: verticalMargin,
            ),
            children: children,
          ),
        );
      },
    );
  }
}

/// Layout delegate that positions multi-day event tiles using greedy-assigned rows.
///
/// This delegate positions each tile based on its [MCalEventLayoutAssignment]
/// and enforces margins around each tile. The margins are:
/// - Vertical: always applied top and bottom
/// - Horizontal left: only applied if this is the first segment of the event
/// - Horizontal right: only applied if this is the last segment of the event
///
/// This approach ensures:
/// - Tiles within a single week have proper spacing on all sides
/// - Tiles that span multiple weeks have no horizontal margin at week boundaries,
///   creating visual continuity across week rows
/// - The tile widget receives its final clickable area, not including margins
class _MultiDayLayoutDelegate extends MultiChildLayoutDelegate {
  final MCalWeekEventLayoutFrame layoutFrame;
  final double cellWidth;
  final double rowHeight;
  final double horizontalMargin;
  final double verticalMargin;

  _MultiDayLayoutDelegate({
    required this.layoutFrame,
    required this.cellWidth,
    required this.rowHeight,
    required this.horizontalMargin,
    required this.verticalMargin,
  });

  @override
  void performLayout(Size size) {
    for (int i = 0; i < layoutFrame.assignments.length; i++) {
      final assignment = layoutFrame.assignments[i];
      final segment = assignment.segment;

      // Calculate margin based on segment position:
      // - Left margin: only if this is the first segment of the event
      // - Right margin: only if this is the last segment of the event
      final leftMargin = segment.isFirstSegment ? horizontalMargin : 0.0;
      final rightMargin = segment.isLastSegment ? horizontalMargin : 0.0;

      // Calculate base position and size from grid coordinates
      final baseLeft = assignment.startColumn * cellWidth;
      final baseTop = assignment.row * rowHeight;
      final baseWidth = assignment.columnSpan * cellWidth;

      // Apply margins to position and size
      final left = baseLeft + leftMargin;
      final top = baseTop + verticalMargin;
      final width = baseWidth - leftMargin - rightMargin;
      final height = rowHeight - (verticalMargin * 2);

      // DEBUG: Uncomment to see margin calculations
      // print('[MARGIN DEBUG] Event: ${assignment.event.title}, '
      //     'weekRow: ${segment.weekRowIndex}, '
      //     'cols: ${assignment.startColumn}-${assignment.endColumn}, '
      //     'isFirst: ${segment.isFirstSegment}, isLast: ${segment.isLastSegment}, '
      //     'leftM: $leftMargin, rightM: $rightMargin, topM: $verticalMargin, '
      //     'baseLeft: $baseLeft, left: $left, baseWidth: $baseWidth, width: $width, height: $height');

      // Layout and position the child with margin-adjusted dimensions
      if (hasChild(i)) {
        layoutChild(i, BoxConstraints.tight(Size(width.clamp(0.0, double.infinity), height.clamp(0.0, double.infinity))));
        positionChild(i, Offset(left, top));
      }
    }
  }

  @override
  bool shouldRelayout(_MultiDayLayoutDelegate oldDelegate) {
    return layoutFrame != oldDelegate.layoutFrame ||
        cellWidth != oldDelegate.cellWidth ||
        rowHeight != oldDelegate.rowHeight ||
        horizontalMargin != oldDelegate.horizontalMargin ||
        verticalMargin != oldDelegate.verticalMargin;
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
  final Widget Function(BuildContext, MCalDayCellContext, Widget)? dayCellBuilder;
  final Widget Function(BuildContext, MCalEventTileContext, Widget)?
  eventTileBuilder;
  final Widget Function(BuildContext, MCalDateLabelContext, String)?
  dateLabelBuilder;
  final String? dateFormat;
  final bool Function(BuildContext, MCalCellInteractivityDetails)? cellInteractivityCallback;
  final void Function(BuildContext, MCalCellTapDetails)? onCellTap;
  final void Function(BuildContext, MCalCellTapDetails)? onCellLongPress;
  final void Function(BuildContext, MCalEventTapDetails)? onEventTap;
  final void Function(BuildContext, MCalEventTapDetails)? onEventLongPress;
  final ValueChanged<MCalDayCellContext?>? onHoverCell;
  final ValueChanged<MCalEventTileContext?>? onHoverEvent;
  final Locale locale;
  final int maxVisibleEvents;
  final void Function(BuildContext, MCalOverflowTapDetails)? onOverflowTap;
  final void Function(BuildContext, MCalOverflowTapDetails)? onOverflowLongPress;

  // Drag-and-drop parameters
  final bool enableDragAndDrop;
  final Widget Function(BuildContext, MCalDraggedTileDetails)?
      draggedTileBuilder;
  final Widget Function(BuildContext, MCalDragSourceDetails)?
      dragSourceBuilder;
  final Widget Function(BuildContext, MCalDragTargetDetails)?
      dragTargetBuilder;
  final Widget Function(BuildContext, MCalDropTargetCellDetails)?
      dropTargetCellBuilder;
  final bool Function(BuildContext, MCalDragWillAcceptDetails)?
      onDragWillAccept;
  final bool Function(BuildContext, MCalEventDroppedDetails)?
      onEventDropped;
  final MCalEventController controller;

  // Drag lifecycle callbacks (Task 21)
  final void Function(MCalCalendarEvent event, DateTime sourceDate)?
      onDragStartedCallback;
  final void Function(bool wasAccepted)? onDragEndedCallback;
  final VoidCallback? onDragCanceledCallback;
  
  /// Reserved height for multi-day events above single-day events.
  /// When > 0, single-day events are pushed down by this amount.
  final double multiDayReservedHeight;

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
    this.onEventTap,
    this.onEventLongPress,
    this.onHoverCell,
    this.onHoverEvent,
    required this.locale,
    this.maxVisibleEvents = 3,
    this.onOverflowTap,
    this.onOverflowLongPress,
    this.multiDayReservedHeight = 0.0,
    // Drag-and-drop
    this.enableDragAndDrop = false,
    this.draggedTileBuilder,
    this.dragSourceBuilder,
    this.dragTargetBuilder,
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

    // Build cell decoration (apply non-interactive styling if needed)
    final decoration = _getCellDecoration(isInteractive);

    // Build date label
    final dateLabel = _buildDateLabel(context);

    // Build the cell widget with clip to prevent overflow on small screens
    // The LayoutBuilder dynamically calculates how many events fit
    Widget cell = LayoutBuilder(
      builder: (context, constraints) {
        // Get theme-based tile height (slot height including margins)
        final tileHeight = theme.eventTileHeight ?? 20.0;
        
        // Calculate available height for events after:
        // - date label with top padding (20.0 + 4.0 = 24.0)
        // - multi-day reserved area (variable)
        // - cell border (1px top + 1px bottom = 2px)
        // Note: Event tiles now go edge-to-edge horizontally (no cell padding)
        // and tiles handle their own margins
        const dateLabelHeightWithPadding = 24.0; // 20.0 label + 4.0 top padding
        const cellBorderHeight = 2.0; // 1px border on top and bottom
        final availableEventHeight =
            constraints.maxHeight - dateLabelHeightWithPadding - multiDayReservedHeight - cellBorderHeight;

        // Calculate how many event tiles can fit
        final maxTilesByHeight = availableEventHeight > 0
            ? (availableEventHeight / tileHeight).floor()
            : 0;

        // Use the smaller of maxVisibleEvents and what fits by height
        final effectiveMaxEvents = maxVisibleEvents == 0
            ? maxTilesByHeight
            : (maxTilesByHeight < maxVisibleEvents
                ? maxTilesByHeight
                : maxVisibleEvents);

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
              ? BoxDecoration(border: Border.all(color: Colors.green, width: 0.5))
              : null,
          clipBehavior: Clip.hardEdge,
          child: Opacity(
            opacity: isInteractive ? 1.0 : 0.5,
            // ClipRect ensures nothing in the Column can overflow the cell
            child: ClipRect(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch, // Full width for tiles
                children: [
                  // Date label with padding (only the label gets padding)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, top: 4.0, right: 4.0),
                    child: dateLabel,
                  ),
                  // Spacer for multi-day events (if any reserved space)
                  // No horizontal padding - aligns with multi-day overlay
                  if (multiDayReservedHeight > 0)
                    Container(
                      height: multiDayReservedHeight,
                      // DEBUG: Purple shows multi-day reserved space within cell
                      color: debugCellSpacing ? Colors.purple.withValues(alpha: 0.2) : null,
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
      );
      cell = dayCellBuilder!(context, contextObj, cell);
    }

    // Wrap in DragTarget when drag-and-drop is enabled
    if (enableDragAndDrop) {
      cell = _wrapWithDragTarget(context, cell);
    }

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
      backgroundColor = theme.focusedDateBackgroundColor ?? theme.cellBackgroundColor;
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

  /// Builds event tiles for this day cell.
  /// Builds event tiles with a dynamic limit based on available space.
  ///
  /// This method is similar to [_buildEventTiles] but accepts an explicit
  /// limit to use instead of [maxVisibleEvents], allowing the layout to
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
      if (enableDragAndDrop) {
        // Capture event and date for the callback closures
        final capturedEvent = event;
        final capturedDate = date;
        
        tile = MCalDraggableEventTile(
          event: event,
          sourceDate: date,
          enabled: true,
          draggedTileBuilder: draggedTileBuilder,
          dragSourceBuilder: dragSourceBuilder,
          // Drag lifecycle callbacks (Task 21)
          onDragStarted: onDragStartedCallback != null
              ? () => onDragStartedCallback!(capturedEvent, capturedDate)
              : null,
          onDragEnded: onDragEndedCallback,
          onDragCanceled: onDragCanceledCallback,
          child: tile,
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
    final length = eventEndDate.difference(eventStartDate).inDays + 1;

    return _EventSpanInfo(isStart: isStart, isEnd: isEnd, length: length);
  }

  /// Wraps the cell content with a DragTarget for drag-and-drop support.
  ///
  /// Implements the DragTarget callbacks:
  /// - onWillAcceptWithDetails: Validates drop using [onDragWillAccept] callback
  /// - builder: Shows visual feedback using [dropTargetCellBuilder] or default overlay
  /// - onAcceptWithDetails: Handles the drop, updates controller, and calls [onEventDropped]
  Widget _wrapWithDragTarget(BuildContext context, Widget child) {
    return DragTarget<MCalCalendarEvent>(
      onWillAcceptWithDetails: (details) {
        final event = details.data;
        
        // Calculate proposed new dates by computing the day delta
        // The source date is stored on the draggable (from MCalDraggableEventTile)
        // We calculate delta from the event's start to the target cell
        final eventStartDate = DateTime(
          event.start.year,
          event.start.month,
          event.start.day,
        );
        final targetCellDate = DateTime(date.year, date.month, date.day);
        final dayDelta = targetCellDate.difference(eventStartDate).inDays;

        // Calculate proposed new start and end dates
        final proposedStartDate = event.start.add(Duration(days: dayDelta));
        final proposedEndDate = event.end.add(Duration(days: dayDelta));

        // Call onDragWillAccept if provided, otherwise accept
        if (onDragWillAccept != null) {
          return onDragWillAccept!(
            context,
            MCalDragWillAcceptDetails(
              event: event,
              proposedStartDate: proposedStartDate,
              proposedEndDate: proposedEndDate,
            ),
          );
        }

        // Default: accept all drops
        return true;
      },
      builder: (context, candidateData, rejectedData) {
        final isDragOver = candidateData.isNotEmpty || rejectedData.isNotEmpty;
        
        if (!isDragOver) {
          return child;
        }

        // Determine if this is a valid drop target
        final isValid = candidateData.isNotEmpty;
        final draggedEvent = isValid ? candidateData.first : rejectedData.first;

        // Use custom dropTargetCellBuilder if provided
        if (dropTargetCellBuilder != null && draggedEvent != null) {
          return dropTargetCellBuilder!(
            context,
            MCalDropTargetCellDetails(
              date: date,
              isValid: isValid,
              draggedEvent: draggedEvent,
            ),
          );
        }

        // Default visual feedback: colored overlay
        // Use theme colors if available, otherwise use defaults
        final validColor = theme.dragTargetValidColor ?? Colors.green.withValues(alpha: 0.3);
        final invalidColor = theme.dragTargetInvalidColor ?? Colors.red.withValues(alpha: 0.3);
        final overlayColor = isValid ? validColor : invalidColor;

        return Stack(
          children: [
            child,
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: overlayColor,
                  border: Border.all(
                    color: isValid ? Colors.green : Colors.red,
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      onAcceptWithDetails: (details) {
        final event = details.data;

        // Calculate the day delta between event start and target cell
        final eventStartDate = DateTime(
          event.start.year,
          event.start.month,
          event.start.day,
        );
        final targetCellDate = DateTime(date.year, date.month, date.day);
        final dayDelta = targetCellDate.difference(eventStartDate).inDays;

        // Calculate new dates
        final newStartDate = event.start.add(Duration(days: dayDelta));
        final newEndDate = event.end.add(Duration(days: dayDelta));

        // Store old dates for potential revert
        final oldStartDate = event.start;
        final oldEndDate = event.end;

        // Create the updated event
        final updatedEvent = event.copyWith(
          start: newStartDate,
          end: newEndDate,
        );

        // Update event in controller (addEvents replaces events by ID)
        controller.addEvents([updatedEvent]);

        // Call onEventDropped callback if provided
        if (onEventDropped != null) {
          final shouldKeep = onEventDropped!(
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
            controller.addEvents([revertedEvent]);
          }
        }
      },
    );
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
      final currentDisplayMonth = DateTime(displayMonth.year, displayMonth.month, 1);
      
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
      backgroundColor = event.color ?? 
          theme.allDayEventBackgroundColor ?? 
          theme.eventTileBackgroundColor ?? 
          Colors.blue.shade50;
      textStyle = theme.allDayEventTextStyle ?? 
          theme.eventTileTextStyle ?? 
          const TextStyle(fontSize: 11, color: Colors.black87);
      borderColor = theme.allDayEventBorderColor;
      borderWidth = theme.allDayEventBorderWidth ?? 1.0;
    } else {
      // Use event color if provided, otherwise fall back to theme/defaults
      backgroundColor = event.color ?? 
          theme.eventTileBackgroundColor ?? 
          Colors.blue.shade100;
      textStyle = theme.eventTileTextStyle ?? 
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
  final void Function(BuildContext, MCalOverflowTapDetails)? onOverflowLongPress;

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
        style: (theme.eventTileTextStyle ?? const TextStyle(fontSize: 11)).copyWith(
          fontStyle: FontStyle.italic,
          color: (theme.eventTileTextStyle?.color ?? Colors.black87).withValues(
            alpha: 0.7,
          ),
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
            ? () => onOverflowLongPress!(
                  context,
                  MCalOverflowTapDetails(
                    date: date,
                    allEvents: allEvents,
                    hiddenCount: count,
                  ),
                )
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
      onOverflowTap!(
        context,
        MCalOverflowTapDetails(
          date: date,
          allEvents: allEvents,
          hiddenCount: count,
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
                          style: theme.navigatorTextStyle?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ) ?? const TextStyle(
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
                    style: theme.cellTextStyle?.copyWith(
                      color: Colors.grey[600],
                    ) ?? TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  // Scrollable list of events
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: allEvents.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
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
        ? (theme.allDayEventBackgroundColor ?? theme.eventTileBackgroundColor ?? Colors.blue)
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
                        style: theme.eventTileTextStyle?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ) ?? const TextStyle(
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
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
        color: theme.weekNumberBackgroundColor ?? theme.weekdayHeaderBackgroundColor,
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
