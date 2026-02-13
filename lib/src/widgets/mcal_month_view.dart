import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../controllers/mcal_event_controller.dart';
import '../models/mcal_calendar_event.dart';
import '../models/mcal_recurrence_exception.dart';
import '../models/mcal_recurrence_rule.dart';
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

/// Returns recurrence metadata for an event.
///
/// For recurring occurrences (identified by non-null [MCalCalendarEvent.occurrenceId]),
/// extracts seriesId from the event ID, looks up the master event via the
/// controller, and checks for exceptions.
///
/// For non-recurring events, returns default values (isRecurring: false, all
/// others null/false).
({
  bool isRecurring,
  String? seriesId,
  MCalRecurrenceRule? recurrenceRule,
  MCalCalendarEvent? masterEvent,
  bool isException,
})
_getRecurrenceMetadata(
  MCalCalendarEvent event,
  MCalEventController controller,
) {
  if (event.occurrenceId == null) {
    return (
      isRecurring: false,
      seriesId: null,
      recurrenceRule: null,
      masterEvent: null,
      isException: false,
    );
  }

  // Recurring occurrence — extract seriesId from the event ID.
  // The ID scheme is "{masterId}_{normalizedDateIso8601}".
  // The occurrenceId IS the date part, so seriesId = id without the
  // trailing "_{occurrenceId}".
  final occId = event.occurrenceId!;
  final seriesId = event.id.endsWith('_$occId')
      ? event.id.substring(0, event.id.length - occId.length - 1)
      : event.id;

  // Look up master event from controller
  final masterEvent = controller.getEventById(seriesId);

  // Check if an exception exists for this occurrence
  final exceptions = controller.getExceptions(seriesId);
  final normalizedOccDate = DateTime.tryParse(occId);
  final isException =
      normalizedOccDate != null &&
      exceptions.any((e) {
        final eDate = DateTime(
          e.originalDate.year,
          e.originalDate.month,
          e.originalDate.day,
        );
        final oDate = DateTime(
          normalizedOccDate.year,
          normalizedOccDate.month,
          normalizedOccDate.day,
        );
        return eDate == oDate;
      });

  return (
    isRecurring: true,
    seriesId: seriesId,
    recurrenceRule: masterEvent?.recurrenceRule,
    masterEvent: masterEvent,
    isException: isException,
  );
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
  /// Defaults to false.
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
  /// Return false to disable tap, long-press, and keyboard focus for that cell.
  ///
  /// **Interaction with [onDragWillAccept]:** [cellInteractivityCallback] affects
  /// whether a cell receives tap/long-press; it does not block drag-and-drop.
  /// A dragged event can still be dropped on a cell that returns false from
  /// [cellInteractivityCallback]. Use [onDragWillAccept] to validate drop targets
  /// during drag (e.g., reject drops on disabled cells).
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
  ///
  /// **Note:** The overflow indicator does not support drag-and-drop. Only
  /// visible event tiles can be dragged.
  final void Function(BuildContext, MCalOverflowTapDetails)? onOverflowTap;

  /// Callback invoked when the overflow indicator ("+N more") is long-pressed.
  ///
  /// Receives the [BuildContext] and [MCalOverflowTapDetails] containing the
  /// date of the cell, the complete list of events for that date, and the
  /// number of hidden events. Useful for showing a context menu or
  /// alternative interaction.
  ///
  /// **Note:** The overflow indicator does not support drag-and-drop. Only
  /// visible event tiles can be dragged.
  final void Function(BuildContext, MCalOverflowTapDetails)?
  onOverflowLongPress;

  // ============ Animation ============

  /// Whether animations are enabled.
  ///
  /// Controls how month transitions and other state changes behave:
  ///
  /// - **`null`** (the default): follows the OS reduced motion preference.
  ///   When the system has "reduce motion" enabled (e.g. iOS "Reduce Motion",
  ///   Android "Remove animations"), animations are disabled automatically.
  ///   When the system has normal motion settings, animations are enabled.
  ///   Uses [MediaQuery.disableAnimationsOf] to detect the preference.
  ///
  /// - **`true`**: force animations enabled regardless of the OS accessibility
  ///   setting. Use this as a developer override when you always want animated
  ///   transitions, even if the user has enabled reduced motion at the OS level.
  ///
  /// - **`false`**: force animations disabled regardless of the OS accessibility
  ///   setting. Transitions use [PageController.jumpToPage] instead of
  ///   [PageController.animateToPage]. This is backward-compatible with the
  ///   previous behavior when `enableAnimations` was set to `false`.
  final bool? enableAnimations;

  /// The duration for animations.
  ///
  /// Controls the duration of month transitions and other animated changes.
  /// Only used when animations are resolved as enabled (see
  /// [enableAnimations]).
  /// Defaults to 300 milliseconds.
  final Duration animationDuration;

  /// The curve for animations.
  ///
  /// Controls the easing curve for month transitions and other animated changes.
  /// Only used when animations are resolved as enabled (see
  /// [enableAnimations]).
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
  ///
  /// **Note:** The overflow indicator does not support drag-and-drop. Only
  /// visible event tiles can be dragged.
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
  /// When true (and [enableDragAndDrop] is true), drop target preview tiles
  /// (Layer 3) are shown during drag. Defaults to true.
  final bool showDropTargetTiles;

  /// When true (and [enableDragAndDrop] is true), the drop target cell overlay
  /// (Layer 4) is shown during drag. Defaults to true.
  final bool showDropTargetOverlay;

  /// When true, the drop target tiles layer renders above the drop target
  /// overlay layer during drag-and-drop. When false (default), tiles render
  /// below the overlay.
  ///
  /// By default, drop target tiles are Layer 3 and the overlay is Layer 4.
  /// Setting this to true reverses their order.
  ///
  /// Only relevant when both [showDropTargetTiles] and [showDropTargetOverlay]
  /// are true and [enableDragAndDrop] is true.
  final bool dropTargetTilesAboveOverlay;

  /// Optional builder for drop target preview tiles (Layer 3).
  ///
  /// When provided, this builder creates a preview widget shown when
  /// hovering over a potential drop target. Receives [MCalEventTileContext]
  /// with [isDropTargetPreview] true and [dropValid], [proposedStartDate],
  /// [proposedEndDate] set. If null, a default tile (same shape, no text) is used.
  ///
  /// Only used when [enableDragAndDrop] and [showDropTargetTiles] are true.
  final MCalEventTileBuilder? dropTargetTileBuilder;

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
  /// **Interaction with [cellInteractivityCallback]:** [cellInteractivityCallback]
  /// disables tap/long-press but does not block drops. Use [onDragWillAccept] to
  /// reject drops on cells you consider disabled (e.g., past dates, weekends).
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

  // ============ Event Resize ============

  /// Whether to enable event edge-drag resizing.
  ///
  /// When `null` (the default), resize is auto-detected based on platform:
  /// enabled on web, desktop (macOS, Windows, Linux), and tablets
  /// (shortest side >= 600dp), but disabled on phones.
  ///
  /// When `true`, resize is enabled regardless of platform.
  /// When `false`, resize is disabled regardless of platform.
  ///
  /// Event resize requires [enableDragAndDrop] to be `true` as well,
  /// since it uses the same drag infrastructure.
  final bool? enableEventResize;

  /// Called during a resize operation to validate whether the proposed
  /// new dates should be accepted.
  ///
  /// If provided, this callback is called with the event and proposed
  /// date range. Return `true` to accept or `false` to reject.
  /// If not provided, all resize positions are accepted.
  final bool Function(
    BuildContext context,
    MCalResizeWillAcceptDetails details,
  )?
  onResizeWillAccept;

  /// Called when an event resize operation completes.
  ///
  /// The callback receives the event with its old and new date ranges.
  /// Return `true` to confirm the resize, or `false` to revert.
  /// If not provided, the resize is always confirmed.
  final bool Function(BuildContext context, MCalEventResizedDetails details)?
  onEventResized;

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

  /// The long-press delay before a drag operation starts.
  ///
  /// When the user long-presses an event tile, the drag begins after this
  /// duration. A shorter delay makes drags start faster; a longer delay
  /// reduces accidental drags when tapping.
  ///
  /// Defaults to 200 milliseconds.
  ///
  /// Only used when [enableDragAndDrop] is true.
  final Duration dragLongPressDelay;

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
    this.enableAnimations,
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
    // Event resize
    this.enableEventResize,
    this.onResizeWillAccept,
    this.onEventResized,
    this.dragEdgeNavigationEnabled = true,
    this.dragEdgeNavigationDelay = const Duration(milliseconds: 1200),
    this.dragLongPressDelay = const Duration(milliseconds: 200),
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
  // Keyboard Event Move Mode State (Task 9 — month-view-polish)
  // ============================================================

  /// Whether keyboard event move mode is active (event selected, arrows move).
  bool _isKeyboardMoveMode = false;

  /// Whether keyboard event selection mode is active (cycling through events).
  bool _isKeyboardEventSelectionMode = false;

  /// The event currently being moved via keyboard.
  MCalCalendarEvent? _keyboardMoveEvent;

  /// The original start date of the event before keyboard move began.
  DateTime? _keyboardMoveOriginalStart;

  /// The original end date of the event before keyboard move began.
  DateTime? _keyboardMoveOriginalEnd;

  /// Index for cycling through events when multiple events are on a cell.
  int _keyboardMoveEventIndex = 0;

  /// The currently proposed target date (event start) during keyboard move.
  DateTime? _keyboardMoveProposedDate;

  // ============================================================
  // Keyboard Event Resize Mode State (Task 10 — month-view-polish)
  // ============================================================

  /// Whether keyboard resize mode is active (sub-mode of keyboard move mode).
  bool _isKeyboardResizeMode = false;

  /// Which edge is currently being resized via keyboard.
  MCalResizeEdge _keyboardResizeEdge = MCalResizeEdge.end;

  /// The proposed start date during keyboard resize.
  DateTime? _keyboardResizeProposedStart;

  /// The proposed end date during keyboard resize.
  DateTime? _keyboardResizeProposedEnd;

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
    // Clean up keyboard move mode state (Task 9 — month-view-polish)
    _exitKeyboardMoveMode();
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

      // Clear drop target when month changes during drag (edge nav or programmatic).
      // User must move pointer to re-trigger onMove and re-show drop target.
      if (_isDragActive) {
        _dragHandler?.clearProposedDropRange();
      }

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

  /// Resolves whether animations should be enabled based on the
  /// [MCalMonthView.enableAnimations] setting and OS accessibility preferences.
  ///
  /// - If [MCalMonthView.enableAnimations] is explicitly `true` or `false`,
  ///   that value is returned directly (developer override).
  /// - If `null` (the default), the OS reduced-motion preference is checked
  ///   via [MediaQuery.disableAnimationsOf]. Animations are enabled when
  ///   the system does **not** have reduced motion turned on.
  bool _resolveAnimationsEnabled(BuildContext context) {
    // Explicit true/false overrides everything
    if (widget.enableAnimations != null) return widget.enableAnimations!;

    // null = follow OS reduced motion preference
    return !MediaQuery.disableAnimationsOf(context);
  }

  /// Resolves whether event resizing should be enabled based on the
  /// [MCalMonthView.enableEventResize] setting and platform detection.
  ///
  /// - Resize requires [MCalMonthView.enableDragAndDrop] to be `true`,
  ///   since resize uses the same drag infrastructure.
  /// - If [MCalMonthView.enableEventResize] is explicitly `true` or `false`,
  ///   that value is returned directly (developer override), subject to the
  ///   drag-and-drop requirement.
  /// - If `null` (the default), auto-detection enables resize on web,
  ///   desktop (macOS, Windows, Linux), and tablets (shortest side >= 600dp),
  ///   but disables it on phones.
  bool _resolveEnableResize(BuildContext context) {
    // Resize requires drag-and-drop infrastructure
    if (!widget.enableDragAndDrop) return false;

    // Explicit override takes precedence
    if (widget.enableEventResize != null) return widget.enableEventResize!;

    // Auto-detect: enabled on web, desktop, and tablets; disabled on phones
    if (kIsWeb) return true;

    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.macOS ||
        platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux) {
      return true;
    }

    // Mobile: enabled on tablets (shortest side >= 600dp)
    final size = MediaQuery.sizeOf(context);
    return size.shortestSide >= 600;
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

    if (shouldAnimate && _resolveAnimationsEnabled(context)) {
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
          showDropTargetTiles: widget.showDropTargetTiles,
          showDropTargetOverlay: widget.showDropTargetOverlay,
          dropTargetTilesAboveOverlay: widget.dropTargetTilesAboveOverlay,
          draggedTileBuilder: widget.draggedTileBuilder,
          dragSourceTileBuilder: widget.dragSourceTileBuilder,
          dropTargetTileBuilder: widget.dropTargetTileBuilder,
          dropTargetCellBuilder: widget.dropTargetCellBuilder,
          dropTargetOverlayBuilder: widget.dropTargetOverlayBuilder,
          onDragWillAccept: widget.onDragWillAccept,
          onEventDropped: widget.onEventDropped,
          dragEdgeNavigationEnabled: widget.dragEdgeNavigationEnabled,
          dragEdgeNavigationDelay: widget.dragEdgeNavigationDelay,
          dragLongPressDelay: widget.dragLongPressDelay,
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
          enableResize: _resolveEnableResize(context),
          onResizeWillAccept: widget.onResizeWillAccept,
          onEventResized: widget.onEventResized,
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
  /// to cancel active drag operations and keyboard event move mode.
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    // Only process key down events
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    // Handle Escape key — works even if keyboard navigation is disabled.
    // Priority: keyboard resize mode > keyboard move mode > keyboard selection mode > pointer drag.
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (_isKeyboardResizeMode) {
        // Cancel resize sub-mode, stay in move mode
        _ensureDragHandler.cancelResize();
        _exitKeyboardResizeMode();
        setState(() {});
        SemanticsService.sendAnnouncement(
          View.of(context),
          'Resize cancelled',
          Directionality.of(context),
        );
        return KeyEventResult.handled;
      }
      if (_isKeyboardMoveMode) {
        final title = _keyboardMoveEvent?.title ?? 'event';
        _ensureDragHandler.cancelDrag();
        _isDragActive = false;
        _exitKeyboardMoveMode();
        setState(() {});
        SemanticsService.sendAnnouncement(
          View.of(context),
          'Move cancelled for $title',
          Directionality.of(context),
        );
        return KeyEventResult.handled;
      }
      if (_isKeyboardEventSelectionMode) {
        _exitKeyboardMoveMode();
        setState(() {});
        SemanticsService.sendAnnouncement(
          View.of(context),
          'Event selection cancelled',
          Directionality.of(context),
        );
        return KeyEventResult.handled;
      }
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

    // Handle keyboard resize mode (arrow keys resize, Enter confirms, S/E switch edge)
    // Resize mode takes priority over move mode.
    if (_isKeyboardResizeMode) {
      return _handleKeyboardResizeModeKey(event);
    }

    // Handle keyboard event selection mode (Tab/Shift+Tab cycles, Enter selects)
    if (_isKeyboardEventSelectionMode && !_isKeyboardMoveMode) {
      return _handleKeyboardSelectionModeKey(event);
    }

    // Handle keyboard move mode (arrow keys move, Enter confirms, R enters resize)
    if (_isKeyboardMoveMode) {
      return _handleKeyboardMoveModeKey(event);
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
    // Use calendar-day arithmetic (not Duration) to avoid DST issues.
    // On DST fall-back (e.g. Nov 2, 2025 US), Duration(days: 1) = 24h can
    // land on the same calendar day at 23:00 instead of the next day.
    if (key == LogicalKeyboardKey.arrowLeft) {
      newFocusedDate = DateTime(
        focusedDate.year,
        focusedDate.month,
        focusedDate.day - 1,
      );
      handled = true;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      newFocusedDate = DateTime(
        focusedDate.year,
        focusedDate.month,
        focusedDate.day + 1,
      );
      handled = true;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      newFocusedDate = DateTime(
        focusedDate.year,
        focusedDate.month,
        focusedDate.day - 7,
      );
      handled = true;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      newFocusedDate = DateTime(
        focusedDate.year,
        focusedDate.month,
        focusedDate.day + 7,
      );
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
    // Enter/Space - enter keyboard move mode if drag-and-drop is enabled
    // and the focused cell has events; otherwise trigger normal cell tap.
    else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.numpadEnter) {
      if (widget.enableDragAndDrop) {
        final dayEvents = _getEventsForDate(focusedDate);
        if (dayEvents.isNotEmpty) {
          _enterKeyboardEventSelectionMode(focusedDate, dayEvents);
          return KeyEventResult.handled;
        }
      }
      // No events or drag-and-drop disabled: fall through to cell tap
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

  // ============================================================
  // Keyboard Event Move Mode Methods (Task 9 — month-view-polish)
  // ============================================================

  /// Returns all events that overlap the given [date].
  ///
  /// Uses the same logic as [_triggerCellTapForFocusedDate] for consistency.
  List<MCalCalendarEvent> _getEventsForDate(DateTime date) {
    final checkDate = DateTime(date.year, date.month, date.day);
    return _events.where((event) {
      final eventStart = DateTime(
        event.start.year,
        event.start.month,
        event.start.day,
      );
      final eventEnd = DateTime(event.end.year, event.end.month, event.end.day);
      return (checkDate.isAtSameMomentAs(eventStart) ||
          checkDate.isAtSameMomentAs(eventEnd) ||
          (checkDate.isAfter(eventStart) && checkDate.isBefore(eventEnd)));
    }).toList();
  }

  /// Clears all keyboard-move state fields (and keyboard-resize sub-mode).
  void _exitKeyboardMoveMode() {
    _exitKeyboardResizeMode();
    _isKeyboardMoveMode = false;
    _isKeyboardEventSelectionMode = false;
    _keyboardMoveEvent = null;
    _keyboardMoveOriginalStart = null;
    _keyboardMoveOriginalEnd = null;
    _keyboardMoveEventIndex = 0;
    _keyboardMoveProposedDate = null;
  }

  /// Clears keyboard-resize sub-mode state fields.
  void _exitKeyboardResizeMode() {
    _isKeyboardResizeMode = false;
    _keyboardResizeEdge = MCalResizeEdge.end;
    _keyboardResizeProposedStart = null;
    _keyboardResizeProposedEnd = null;
  }

  /// Enters keyboard event selection mode for the given [date] and [events].
  ///
  /// If only one event exists, selects it immediately and enters move mode.
  /// If multiple events exist, enters cycling mode (Tab/Shift+Tab).
  void _enterKeyboardEventSelectionMode(
    DateTime date,
    List<MCalCalendarEvent> events,
  ) {
    if (events.length == 1) {
      // Single event: select immediately and enter move mode
      _selectKeyboardMoveEvent(events.first);
    } else {
      // Multiple events: enter cycling mode
      _isKeyboardEventSelectionMode = true;
      _keyboardMoveEventIndex = 0;
      setState(() {});
      SemanticsService.sendAnnouncement(
        View.of(context),
        '${events.length} events. ${events.first.title} highlighted. '
        'Tab to cycle, Enter to confirm.',
        Directionality.of(context),
      );
    }
  }

  /// Selects the given [event] for keyboard move mode.
  ///
  /// Sets up the move state with the event's original dates and the proposed
  /// date initialized to the event's normalized start date.
  void _selectKeyboardMoveEvent(MCalCalendarEvent event) {
    _isKeyboardEventSelectionMode = false;
    _isKeyboardMoveMode = true;
    _keyboardMoveEvent = event;
    _keyboardMoveOriginalStart = event.start;
    _keyboardMoveOriginalEnd = event.end;
    _keyboardMoveProposedDate = DateTime(
      event.start.year,
      event.start.month,
      event.start.day,
    );
    setState(() {});
    SemanticsService.sendAnnouncement(
      View.of(context),
      'Selected ${event.title}. '
      'Arrow keys to move, Enter to confirm, Escape to cancel.',
      Directionality.of(context),
    );
  }

  /// Handles key events during event selection mode (cycling through events).
  ///
  /// Tab/Shift+Tab cycles through events on the focused cell.
  /// Enter confirms the selection and enters move mode.
  /// Escape exits selection mode.
  KeyEventResult _handleKeyboardSelectionModeKey(KeyEvent event) {
    final key = event.logicalKey;
    final focusedDate =
        widget.controller.focusedDate ?? widget.controller.displayDate;
    final dayEvents = _getEventsForDate(focusedDate);

    if (dayEvents.isEmpty) {
      _exitKeyboardMoveMode();
      setState(() {});
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.tab) {
      final isShift = HardwareKeyboard.instance.isShiftPressed;
      if (isShift) {
        _keyboardMoveEventIndex =
            (_keyboardMoveEventIndex - 1 + dayEvents.length) % dayEvents.length;
      } else {
        _keyboardMoveEventIndex =
            (_keyboardMoveEventIndex + 1) % dayEvents.length;
      }
      final highlighted = dayEvents[_keyboardMoveEventIndex];
      setState(() {});
      SemanticsService.sendAnnouncement(
        View.of(context),
        '${highlighted.title}. '
        '${_keyboardMoveEventIndex + 1} of ${dayEvents.length}.',
        Directionality.of(context),
      );
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      final selectedIndex = _keyboardMoveEventIndex.clamp(
        0,
        dayEvents.length - 1,
      );
      _selectKeyboardMoveEvent(dayEvents[selectedIndex]);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  /// Handles key events during move mode (arrow keys, Enter, Escape).
  ///
  /// Arrow keys shift the proposed date:
  /// - Left/Right: +/-1 day
  /// - Up/Down: +/-7 days
  ///
  /// On the first arrow press, [MCalDragHandler.startDrag] is called to
  /// enter drag state. Each arrow press calls
  /// [MCalDragHandler.updateProposedDropRange] so Layer 3/4 previews render.
  ///
  /// Enter confirms via [_handleKeyboardDrop], reusing the same drop logic
  /// as pointer-based drag-and-drop.
  KeyEventResult _handleKeyboardMoveModeKey(KeyEvent event) {
    final key = event.logicalKey;
    final moveEvent = _keyboardMoveEvent;
    if (moveEvent == null) return KeyEventResult.ignored;

    // Determine arrow-key day delta
    int dayDelta = 0;
    if (key == LogicalKeyboardKey.arrowRight) {
      dayDelta = 1;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      dayDelta = -1;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      dayDelta = 7;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      dayDelta = -7;
    }

    if (dayDelta != 0) {
      final dragHandler = _ensureDragHandler;

      // Start drag on first arrow press if not already dragging
      if (!dragHandler.isDragging) {
        final sourceDate = DateTime(
          _keyboardMoveOriginalStart!.year,
          _keyboardMoveOriginalStart!.month,
          _keyboardMoveOriginalStart!.day,
        );
        dragHandler.startDrag(moveEvent, sourceDate);
        _isDragActive = true;
      }

      // Calculate new proposed date using DST-safe arithmetic
      final currentProposed = _keyboardMoveProposedDate!;
      final newProposed = DateTime(
        currentProposed.year,
        currentProposed.month,
        currentProposed.day + dayDelta,
      );
      _keyboardMoveProposedDate = newProposed;

      // Calculate event span duration in days (inclusive)
      final eventDurationDays =
          daysBetween(
            DateTime(
              moveEvent.start.year,
              moveEvent.start.month,
              moveEvent.start.day,
            ),
            DateTime(
              moveEvent.end.year,
              moveEvent.end.month,
              moveEvent.end.day,
            ),
          ) +
          1;

      final proposedEnd = DateTime(
        newProposed.year,
        newProposed.month,
        newProposed.day + eventDurationDays - 1,
      );

      // Validate via onDragWillAccept
      bool isValid = true;
      if (widget.onDragWillAccept != null) {
        isValid = widget.onDragWillAccept!(
          context,
          MCalDragWillAcceptDetails(
            event: moveEvent,
            proposedStartDate: newProposed,
            proposedEndDate: proposedEnd,
          ),
        );
      }

      // Update drag handler proposed range (triggers Layer 3/4 rebuild)
      dragHandler.updateProposedDropRange(
        proposedStart: newProposed,
        proposedEnd: proposedEnd,
        isValid: isValid,
      );

      // Update drag target date and validity
      dragHandler.updateDrag(newProposed, isValid, Offset.zero);

      // Navigate to new month if proposed date leaves visible month
      final newMonth = DateTime(newProposed.year, newProposed.month, 1);
      if (newMonth.year != _currentMonth.year ||
          newMonth.month != _currentMonth.month) {
        _navigateToMonth(newMonth);
      }

      // Track focus on the proposed date
      widget.controller.setFocusedDate(newProposed);

      // Screen reader announcement
      final dateStr = DateFormat.yMMMd().format(newProposed);
      SemanticsService.sendAnnouncement(
        View.of(context),
        'Moving ${moveEvent.title} to $dateStr',
        Directionality.of(context),
      );

      setState(() {});
      return KeyEventResult.handled;
    }

    // R key: enter resize mode (if resize is enabled)
    if (key == LogicalKeyboardKey.keyR && _resolveEnableResize(context)) {
      final dragHandler = _ensureDragHandler;

      // If currently in drag state (from arrow move), cancel it first
      if (dragHandler.isDragging) {
        dragHandler.cancelDrag();
        _isDragActive = false;
      }

      // Enter resize mode
      _isKeyboardResizeMode = true;
      _keyboardResizeEdge = MCalResizeEdge.end;

      // Initialize proposed dates from the event's current dates
      _keyboardResizeProposedStart = DateTime(
        moveEvent.start.year,
        moveEvent.start.month,
        moveEvent.start.day,
      );
      _keyboardResizeProposedEnd = DateTime(
        moveEvent.end.year,
        moveEvent.end.month,
        moveEvent.end.day,
      );

      // Start resize on the drag handler
      dragHandler.startResize(moveEvent, MCalResizeEdge.end);

      // Set up initial highlight state in handler
      final isValid = _validateKeyboardResize(moveEvent);
      dragHandler.updateResize(
        proposedStart: _keyboardResizeProposedStart!,
        proposedEnd: _keyboardResizeProposedEnd!,
        isValid: isValid,
        cells: [],
      );

      setState(() {});
      SemanticsService.sendAnnouncement(
        View.of(context),
        'Resize mode. Adjusting end edge. '
        'Arrow keys to resize, S for start, E for end, '
        'Enter to confirm, Escape to cancel.',
        Directionality.of(context),
      );
      return KeyEventResult.handled;
    }

    // Enter: confirm the move
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      _handleKeyboardDrop();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  /// Confirms the keyboard-initiated event move.
  ///
  /// Mirrors the logic of [_MonthPageWidgetState._handleDrop], reusing the
  /// same [MCalEventDroppedDetails] callback and controller mutation flow.
  void _handleKeyboardDrop() {
    final dragHandler = _dragHandler;
    final event = _keyboardMoveEvent;

    if (dragHandler == null || event == null) {
      _exitKeyboardMoveMode();
      setState(() {});
      return;
    }

    final proposedStart = dragHandler.proposedStartDate;
    final proposedEnd = dragHandler.proposedEndDate;

    if (proposedStart == null ||
        proposedEnd == null ||
        !dragHandler.isProposedDropValid) {
      dragHandler.cancelDrag();
      _isDragActive = false;
      _exitKeyboardMoveMode();
      setState(() {});
      SemanticsService.sendAnnouncement(
        View.of(context),
        'Move cancelled. Invalid target.',
        Directionality.of(context),
      );
      return;
    }

    // Use the stored original dates (set when the event was selected).
    final oldStartDate = _keyboardMoveOriginalStart ?? event.start;
    final oldEndDate = _keyboardMoveOriginalEnd ?? event.end;

    // Calculate day delta using DST-safe daysBetween
    final normalizedEventStart = DateTime(
      oldStartDate.year,
      oldStartDate.month,
      oldStartDate.day,
    );
    final dayDelta = daysBetween(normalizedEventStart, proposedStart);

    // Calculate new dates preserving time components
    final newStartDate = DateTime(
      oldStartDate.year,
      oldStartDate.month,
      oldStartDate.day + dayDelta,
      oldStartDate.hour,
      oldStartDate.minute,
      oldStartDate.second,
      oldStartDate.millisecond,
      oldStartDate.microsecond,
    );
    final newEndDate = DateTime(
      oldEndDate.year,
      oldEndDate.month,
      oldEndDate.day + dayDelta,
      oldEndDate.hour,
      oldEndDate.minute,
      oldEndDate.second,
      oldEndDate.millisecond,
      oldEndDate.microsecond,
    );

    // Create updated event
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
      // Recurring occurrence: use addException instead of addEvents
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
          widget.controller.addException(
            seriesId,
            MCalRecurrenceException.rescheduled(
              originalDate: DateTime.parse(event.occurrenceId!),
              newDate: newStartDate,
            ),
          );
        }
      } else {
        // No callback provided — auto-create reschedule exception
        widget.controller.addException(
          seriesId,
          MCalRecurrenceException.rescheduled(
            originalDate: DateTime.parse(event.occurrenceId!),
            newDate: newStartDate,
          ),
        );
      }
    } else {
      // Non-recurring event: update via controller
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

    // Announce success
    final dateStr = DateFormat.yMMMd().format(newStartDate);
    SemanticsService.sendAnnouncement(
      View.of(context),
      'Moved ${event.title} to $dateStr',
      Directionality.of(context),
    );

    // Clean up drag and keyboard move state
    dragHandler.cancelDrag();
    _isDragActive = false;
    _exitKeyboardMoveMode();
    setState(() {});
  }

  // ============================================================
  // Keyboard Resize Mode (Task 10 — month-view-polish)
  // ============================================================

  /// Handles key events during keyboard resize mode.
  ///
  /// - Arrow keys: adjust the active edge (+/-1 day for Left/Right, +/-7 for Up/Down)
  /// - S: switch to start edge
  /// - E: switch to end edge
  /// - M: cancel resize, return to move mode
  /// - Enter: confirm resize via [_handleKeyboardResizeEnd]
  /// - Escape: cancel resize, stay in move mode
  KeyEventResult _handleKeyboardResizeModeKey(KeyEvent event) {
    final key = event.logicalKey;
    final resizeEvent = _keyboardMoveEvent;
    if (resizeEvent == null) return KeyEventResult.ignored;

    final dragHandler = _ensureDragHandler;

    // S key: switch to start edge
    if (key == LogicalKeyboardKey.keyS) {
      _keyboardResizeEdge = MCalResizeEdge.start;
      // Restart resize with new edge
      dragHandler.cancelResize();
      dragHandler.startResize(resizeEvent, MCalResizeEdge.start);
      // Restore proposed range in handler
      if (_keyboardResizeProposedStart != null &&
          _keyboardResizeProposedEnd != null) {
        final isValid = _validateKeyboardResize(resizeEvent);
        dragHandler.updateResize(
          proposedStart: _keyboardResizeProposedStart!,
          proposedEnd: _keyboardResizeProposedEnd!,
          isValid: isValid,
          cells: [],
        );
      }
      setState(() {});
      SemanticsService.sendAnnouncement(
        View.of(context),
        'Resizing start edge',
        Directionality.of(context),
      );
      return KeyEventResult.handled;
    }

    // E key: switch to end edge
    if (key == LogicalKeyboardKey.keyE) {
      _keyboardResizeEdge = MCalResizeEdge.end;
      // Restart resize with new edge
      dragHandler.cancelResize();
      dragHandler.startResize(resizeEvent, MCalResizeEdge.end);
      // Restore proposed range in handler
      if (_keyboardResizeProposedStart != null &&
          _keyboardResizeProposedEnd != null) {
        final isValid = _validateKeyboardResize(resizeEvent);
        dragHandler.updateResize(
          proposedStart: _keyboardResizeProposedStart!,
          proposedEnd: _keyboardResizeProposedEnd!,
          isValid: isValid,
          cells: [],
        );
      }
      setState(() {});
      SemanticsService.sendAnnouncement(
        View.of(context),
        'Resizing end edge',
        Directionality.of(context),
      );
      return KeyEventResult.handled;
    }

    // M key: cancel resize, return to move mode
    if (key == LogicalKeyboardKey.keyM) {
      dragHandler.cancelResize();
      _exitKeyboardResizeMode();
      setState(() {});
      SemanticsService.sendAnnouncement(
        View.of(context),
        'Move mode',
        Directionality.of(context),
      );
      return KeyEventResult.handled;
    }

    // Arrow keys: adjust active edge
    final int delta;
    if (key == LogicalKeyboardKey.arrowRight) {
      delta = 1;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      delta = -1;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      delta = 7;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      delta = -7;
    } else {
      delta = 0;
    }

    if (delta != 0) {
      if (_keyboardResizeEdge == MCalResizeEdge.end) {
        final currentEnd = _keyboardResizeProposedEnd!;
        final newEnd = DateTime(
          currentEnd.year,
          currentEnd.month,
          currentEnd.day + delta,
        );
        // Clamp: end cannot be before start (minimum 1 day)
        _keyboardResizeProposedEnd = newEnd.isBefore(
              _keyboardResizeProposedStart!,
            )
            ? DateTime(
                _keyboardResizeProposedStart!.year,
                _keyboardResizeProposedStart!.month,
                _keyboardResizeProposedStart!.day,
              )
            : newEnd;
      } else {
        final currentStart = _keyboardResizeProposedStart!;
        final newStart = DateTime(
          currentStart.year,
          currentStart.month,
          currentStart.day + delta,
        );
        // Clamp: start cannot be after end (minimum 1 day)
        _keyboardResizeProposedStart = newStart.isAfter(
              _keyboardResizeProposedEnd!,
            )
            ? DateTime(
                _keyboardResizeProposedEnd!.year,
                _keyboardResizeProposedEnd!.month,
                _keyboardResizeProposedEnd!.day,
              )
            : newStart;
      }

      // Validate via callback
      final isValid = _validateKeyboardResize(resizeEvent);

      // Update drag handler (triggers Layer 3/4 rebuild)
      dragHandler.updateResize(
        proposedStart: _keyboardResizeProposedStart!,
        proposedEnd: _keyboardResizeProposedEnd!,
        isValid: isValid,
        cells: [],
      );

      // Calculate span length for announcement
      final spanDays =
          daysBetween(
            _keyboardResizeProposedStart!,
            _keyboardResizeProposedEnd!,
          ) +
          1;
      final activeDate = _keyboardResizeEdge == MCalResizeEdge.end
          ? _keyboardResizeProposedEnd!
          : _keyboardResizeProposedStart!;
      final dateStr = DateFormat.yMMMd().format(activeDate);
      SemanticsService.sendAnnouncement(
        View.of(context),
        'Resizing ${resizeEvent.title} ${_keyboardResizeEdge.name} to $dateStr, $spanDays days',
        Directionality.of(context),
      );

      setState(() {});
      return KeyEventResult.handled;
    }

    // Enter: confirm resize
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      _handleKeyboardResizeEnd();
      return KeyEventResult.handled;
    }

    // Escape: cancel resize, stay in move mode
    if (key == LogicalKeyboardKey.escape) {
      dragHandler.cancelResize();
      _exitKeyboardResizeMode();
      setState(() {});
      SemanticsService.sendAnnouncement(
        View.of(context),
        'Resize cancelled',
        Directionality.of(context),
      );
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  /// Validates the current keyboard resize proposal via [onResizeWillAccept].
  bool _validateKeyboardResize(MCalCalendarEvent event) {
    if (widget.onResizeWillAccept == null) return true;
    return widget.onResizeWillAccept!(
      context,
      MCalResizeWillAcceptDetails(
        event: event,
        proposedStartDate: _keyboardResizeProposedStart!,
        proposedEndDate: _keyboardResizeProposedEnd!,
        resizeEdge: _keyboardResizeEdge,
      ),
    );
  }

  /// Confirms the keyboard-initiated event resize.
  ///
  /// Mirrors the logic of [_MonthPageWidgetState._handleResizeEnd], reusing
  /// the same [MCalDragHandler.completeResize] state machine and
  /// [MCalEventResizedDetails] callback flow.
  void _handleKeyboardResizeEnd() {
    final dragHandler = _dragHandler;
    final event = _keyboardMoveEvent;

    if (dragHandler == null || event == null || !dragHandler.isResizing) {
      _exitKeyboardResizeMode();
      _exitKeyboardMoveMode();
      setState(() {});
      return;
    }

    // Save state before completeResize() clears it
    final originalStart = dragHandler.resizeOriginalStart!;
    final originalEnd = dragHandler.resizeOriginalEnd!;
    final edge = dragHandler.resizeEdge!;

    final result = dragHandler.completeResize();
    if (result == null) {
      // Invalid resize
      _exitKeyboardResizeMode();
      setState(() {});
      SemanticsService.sendAnnouncement(
        View.of(context),
        'Resize cancelled. Invalid resize.',
        Directionality.of(context),
      );
      return;
    }

    final (proposedStart, proposedEnd) = result;

    // Calculate new dates preserving time components using DST-safe arithmetic.
    final DateTime newStartDate;
    final DateTime newEndDate;

    if (edge == MCalResizeEdge.start) {
      // Start edge changed
      final normalizedOriginalStart = DateTime(
        originalStart.year,
        originalStart.month,
        originalStart.day,
      );
      final dayDelta = daysBetween(normalizedOriginalStart, proposedStart);
      newStartDate = DateTime(
        originalStart.year,
        originalStart.month,
        originalStart.day + dayDelta,
        originalStart.hour,
        originalStart.minute,
        originalStart.second,
        originalStart.millisecond,
        originalStart.microsecond,
      );
      newEndDate = originalEnd;
    } else {
      // End edge changed
      final normalizedOriginalEnd = DateTime(
        originalEnd.year,
        originalEnd.month,
        originalEnd.day,
      );
      final dayDelta = daysBetween(normalizedOriginalEnd, proposedEnd);
      newEndDate = DateTime(
        originalEnd.year,
        originalEnd.month,
        originalEnd.day + dayDelta,
        originalEnd.hour,
        originalEnd.minute,
        originalEnd.second,
        originalEnd.millisecond,
        originalEnd.microsecond,
      );
      newStartDate = originalStart;
    }

    // Detect recurring occurrence
    final isRecurring = event.occurrenceId != null;
    String? seriesId;
    if (isRecurring) {
      final occId = event.occurrenceId!;
      seriesId = event.id.endsWith('_$occId')
          ? event.id.substring(0, event.id.length - occId.length - 1)
          : event.id;
    }

    // Build details
    final details = MCalEventResizedDetails(
      event: event,
      oldStartDate: originalStart,
      oldEndDate: originalEnd,
      newStartDate: newStartDate,
      newEndDate: newEndDate,
      resizeEdge: edge,
      isRecurring: isRecurring,
      seriesId: seriesId,
    );

    // Create the updated event
    final updatedEvent = event.copyWith(start: newStartDate, end: newEndDate);

    if (isRecurring && seriesId != null) {
      // Recurring occurrence: create a modified exception
      if (widget.onEventResized != null) {
        final shouldKeep = widget.onEventResized!(context, details);
        if (shouldKeep) {
          widget.controller.addException(
            seriesId,
            MCalRecurrenceException.rescheduled(
              originalDate: DateTime.parse(event.occurrenceId!),
              newDate: newStartDate,
            ),
          );
        }
      } else {
        // No callback — auto-create exception
        widget.controller.addException(
          seriesId,
          MCalRecurrenceException.rescheduled(
            originalDate: DateTime.parse(event.occurrenceId!),
            newDate: newStartDate,
          ),
        );
      }
    } else {
      // Non-recurring event: update via controller
      widget.controller.addEvents([updatedEvent]);

      // Call onEventResized callback if provided
      if (widget.onEventResized != null) {
        final shouldKeep = widget.onEventResized!(context, details);

        // If callback returns false, revert the change
        if (!shouldKeep) {
          final revertedEvent = event.copyWith(
            start: originalStart,
            end: originalEnd,
          );
          widget.controller.addEvents([revertedEvent]);
        }
      }
    }

    // Announce success
    final startStr = DateFormat.yMMMd().format(newStartDate);
    final endStr = DateFormat.yMMMd().format(newEndDate);
    SemanticsService.sendAnnouncement(
      View.of(context),
      'Resized ${event.title} to $startStr through $endStr',
      Directionality.of(context),
    );

    // Clean up resize and move state
    _exitKeyboardResizeMode();
    _exitKeyboardMoveMode();
    _isDragActive = false;
    setState(() {});
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
  /// Cleans up drag state and cancels any pending edge navigation so drop
  /// indicators are always cleared. When the drop was accepted, _handleDrop
  /// already ran and called cancelDrag(); we only need to clean up when the
  /// drop was rejected (released outside the calendar).
  void _handleDragEnded(bool wasAccepted) {
    _isDragActive = false;
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
  final bool showDropTargetTiles;
  final bool showDropTargetOverlay;
  final bool dropTargetTilesAboveOverlay;
  final Widget Function(BuildContext, MCalDraggedTileDetails)?
  draggedTileBuilder;
  final Widget Function(BuildContext, MCalDragSourceDetails)?
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
  final bool enableResize;

  /// Called during a resize operation to validate the proposed dates.
  final bool Function(BuildContext, MCalResizeWillAcceptDetails)?
  onResizeWillAccept;

  /// Called when an event resize operation completes.
  final bool Function(BuildContext, MCalEventResizedDetails)? onEventResized;

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
    this.enableResize = false,
    this.onResizeWillAccept,
    this.onEventResized,
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

  // ============================================================
  // Resize Gesture State
  // ============================================================

  /// Accumulated horizontal drag distance during a resize gesture.
  double _resizeDxAccumulated = 0.0;

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
    final localizations = MCalLocalizations();
    final prefix = localizations.getLocalizedString('dropTargetPrefix', locale);
    final validStr = localizations.getLocalizedString(
      isValid ? 'dropTargetValid' : 'dropTargetInvalid',
      locale,
    );

    final firstDate = highlightedCells.first.date;
    final firstDateStr = localizations.formatDate(firstDate, locale);

    final String dateRangeStr;
    if (highlightedCells.length == 1) {
      dateRangeStr = firstDateStr;
    } else {
      final lastDate = highlightedCells.last.date;
      final lastDateStr = localizations.formatDate(lastDate, locale);
      final toStr = localizations.getLocalizedString(
        'dropTargetDateRangeTo',
        locale,
      );
      dateRangeStr = '$firstDateStr $toStr $lastDateStr';
    }

    return '$prefix, $dateRangeStr, $validStr';
  }

  /// Called when drag handler state changes.
  void _onDragHandlerChanged() {
    if (!mounted) return;
    final dragHandler = widget.dragHandler;
    if (dragHandler != null && !dragHandler.isDragging && !dragHandler.isResizing) {
      // Drag/resize ended or cancelled - clear caches so indicators never stick
      _cachedDragData = null;
      _layoutCachedForDrag = false;
    }
    setState(() {});
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
  /// Called once at start of each drag (guarded by [_layoutCachedForDrag]).
  /// Always recomputes — the formula depends on [widget.showWeekNumbers] and
  /// text direction, which can change without affecting overall widget size.
  void _updateLayoutCache(RenderBox renderBox) {
    _cachedCalendarSize = renderBox.size;
    _cachedCalendarOffset = renderBox.localToGlobal(Offset.zero);
    // Account for week number column: day width is computed from content area only
    final weekNumberWidth = widget.showWeekNumbers
        ? _WeekNumberCell.columnWidth
        : 0.0;
    _cachedWeekNumberWidth = weekNumberWidth;
    // In LTR, week numbers are on the left → content starts at weekNumberWidth.
    // In RTL, week numbers are on the right → content starts at 0.
    final isRTL = Directionality.maybeOf(context) == TextDirection.rtl;
    _cachedContentOffsetX = isRTL ? 0.0 : weekNumberWidth;
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

    // Calculate new dates preserving time components.
    // Use DST-safe daysBetween (not .difference().inDays) for day delta.
    final normalizedEventStart = DateTime(
      event.start.year,
      event.start.month,
      event.start.day,
    );
    final dayDelta = daysBetween(normalizedEventStart, proposedStart);

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
      // Recurring occurrence: use addException instead of addEvents
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
          widget.controller.addException(
            seriesId,
            MCalRecurrenceException.rescheduled(
              originalDate: DateTime.parse(event.occurrenceId!),
              newDate: newStartDate,
            ),
          );
        }
      } else {
        // No callback provided — auto-create reschedule exception
        widget.controller.addException(
          seriesId,
          MCalRecurrenceException.rescheduled(
            originalDate: DateTime.parse(event.occurrenceId!),
            newDate: newStartDate,
          ),
        );
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
  // Resize Interaction Methods
  // ============================================================

  /// Begins a resize operation for the given [event] on the specified [edge].
  ///
  /// Resets the accumulated drag distance, ensures the layout cache is
  /// populated, and starts the resize state on the drag handler.
  void _handleResizeStart(MCalCalendarEvent event, MCalResizeEdge edge) {
    _resizeDxAccumulated = 0.0;

    // Ensure layout cache is populated for building highlight cells
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      _updateLayoutCache(renderBox);
    }

    widget.dragHandler?.startResize(event, edge);
  }

  /// Handles incremental drag updates during a resize gesture.
  ///
  /// Accumulates horizontal drag distance [dx], converts to a day delta
  /// using [dayWidth], computes proposed dates with DST-safe arithmetic,
  /// enforces minimum 1-day duration, validates via [onResizeWillAccept],
  /// builds highlight cells, and updates the drag handler for Layer 3/4 preview.
  void _handleResizeUpdate(double dx, double dayWidth) {
    final dragHandler = widget.dragHandler;
    if (dragHandler == null || !dragHandler.isResizing) return;

    _resizeDxAccumulated += dx;

    // Use provided dayWidth, falling back to cached layout value
    final effectiveDayWidth = dayWidth > 0 ? dayWidth : _cachedDayWidth;
    if (effectiveDayWidth <= 0) return;
    final dayDelta = (_resizeDxAccumulated / effectiveDayWidth).round();

    final originalStart = dragHandler.resizeOriginalStart!;
    final originalEnd = dragHandler.resizeOriginalEnd!;
    final edge = dragHandler.resizeEdge!;

    DateTime proposedStart;
    DateTime proposedEnd;

    if (edge == MCalResizeEdge.start) {
      // Adjusting start edge: apply delta to original start
      final newDate = DateTime(
        originalStart.year,
        originalStart.month,
        originalStart.day + dayDelta,
      );
      // Enforce minimum: start cannot be after end (minimum 1 day event)
      proposedStart = newDate.isBefore(originalEnd) || newDate.isAtSameMomentAs(originalEnd)
          ? newDate
          : DateTime(originalEnd.year, originalEnd.month, originalEnd.day);
      proposedEnd = originalEnd;
    } else {
      // Adjusting end edge: apply delta to original end
      final newDate = DateTime(
        originalEnd.year,
        originalEnd.month,
        originalEnd.day + dayDelta,
      );
      // Enforce minimum: end cannot be before start (minimum 1 day event)
      proposedEnd = newDate.isAfter(originalStart) || newDate.isAtSameMomentAs(originalStart)
          ? newDate
          : DateTime(originalStart.year, originalStart.month, originalStart.day);
      proposedStart = originalStart;
    }

    // Validate via callback
    bool isValid = true;
    if (widget.onResizeWillAccept != null) {
      isValid = widget.onResizeWillAccept!(
        context,
        MCalResizeWillAcceptDetails(
          event: dragHandler.resizingEvent!,
          proposedStartDate: proposedStart,
          proposedEndDate: proposedEnd,
          resizeEdge: edge,
        ),
      );
    }

    // Build highlighted cells for preview
    final cells = _buildHighlightCellsForDateRange(proposedStart, proposedEnd);

    // Update drag handler (triggers Layer 3/4 rebuild)
    dragHandler.updateResize(
      proposedStart: proposedStart,
      proposedEnd: proposedEnd,
      isValid: isValid,
      cells: cells,
    );
  }

  /// Completes the resize operation.
  ///
  /// Mirrors the logic of [_handleDrop]: saves event state before clearing,
  /// builds [MCalEventResizedDetails], calls the [onEventResized] callback,
  /// and updates the controller. For recurring events, creates a modified
  /// exception via [addException].
  void _handleResizeEnd() {
    final dragHandler = widget.dragHandler;
    if (dragHandler == null || !dragHandler.isResizing) return;

    // Save state before completeResize() clears it
    final event = dragHandler.resizingEvent!;
    final originalStart = dragHandler.resizeOriginalStart!;
    final originalEnd = dragHandler.resizeOriginalEnd!;
    final edge = dragHandler.resizeEdge!;

    final result = dragHandler.completeResize();
    if (result == null) return; // Invalid resize

    final (proposedStart, proposedEnd) = result;

    // Calculate new dates preserving time components using DST-safe arithmetic.
    // For the edge that changed, compute day delta and apply to the original
    // date with time components. The unchanged edge keeps its original value.
    final DateTime newStartDate;
    final DateTime newEndDate;

    if (edge == MCalResizeEdge.start) {
      // Start edge changed
      final normalizedOriginalStart = DateTime(
        originalStart.year,
        originalStart.month,
        originalStart.day,
      );
      final dayDelta = daysBetween(normalizedOriginalStart, proposedStart);
      newStartDate = DateTime(
        originalStart.year,
        originalStart.month,
        originalStart.day + dayDelta,
        originalStart.hour,
        originalStart.minute,
        originalStart.second,
        originalStart.millisecond,
        originalStart.microsecond,
      );
      newEndDate = originalEnd;
    } else {
      // End edge changed
      final normalizedOriginalEnd = DateTime(
        originalEnd.year,
        originalEnd.month,
        originalEnd.day,
      );
      final dayDelta = daysBetween(normalizedOriginalEnd, proposedEnd);
      newEndDate = DateTime(
        originalEnd.year,
        originalEnd.month,
        originalEnd.day + dayDelta,
        originalEnd.hour,
        originalEnd.minute,
        originalEnd.second,
        originalEnd.millisecond,
        originalEnd.microsecond,
      );
      newStartDate = originalStart;
    }

    // Detect recurring occurrence
    final isRecurring = event.occurrenceId != null;
    String? seriesId;
    if (isRecurring) {
      final occId = event.occurrenceId!;
      seriesId = event.id.endsWith('_$occId')
          ? event.id.substring(0, event.id.length - occId.length - 1)
          : event.id;
    }

    // Build details
    final details = MCalEventResizedDetails(
      event: event,
      oldStartDate: originalStart,
      oldEndDate: originalEnd,
      newStartDate: newStartDate,
      newEndDate: newEndDate,
      resizeEdge: edge,
      isRecurring: isRecurring,
      seriesId: seriesId,
    );

    // Create the updated event
    final updatedEvent = event.copyWith(start: newStartDate, end: newEndDate);

    if (isRecurring && seriesId != null) {
      // Recurring occurrence: create a modified exception
      if (widget.onEventResized != null) {
        final shouldKeep = widget.onEventResized!(context, details);
        if (shouldKeep) {
          widget.controller.addException(
            seriesId,
            MCalRecurrenceException.rescheduled(
              originalDate: DateTime.parse(event.occurrenceId!),
              newDate: newStartDate,
            ),
          );
        }
      } else {
        // No callback — auto-create exception
        widget.controller.addException(
          seriesId,
          MCalRecurrenceException.rescheduled(
            originalDate: DateTime.parse(event.occurrenceId!),
            newDate: newStartDate,
          ),
        );
      }
    } else {
      // Non-recurring event: update via controller
      widget.controller.addEvents([updatedEvent]);

      // Call onEventResized callback if provided
      if (widget.onEventResized != null) {
        final shouldKeep = widget.onEventResized!(context, details);

        // If callback returns false, revert the change
        if (!shouldKeep) {
          final revertedEvent = event.copyWith(
            start: originalStart,
            end: originalEnd,
          );
          widget.controller.addEvents([revertedEvent]);
        }
      }
    }
  }

  /// Cancels the current resize operation.
  void _handleResizeCancel() {
    widget.dragHandler?.cancelResize();
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
        : (_weeks.isNotEmpty ? _cachedCalendarSize.height / _weeks.length : 0.0);

    if (dayWidth <= 0 || weekRowHeight <= 0) return cells;

    // Normalize dates to date-only
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);
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
      final meta = _getRecurrenceMetadata(event, widget.controller);
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

    final cornerRadius =
        theme.dropTargetTileCornerRadius ?? theme.eventTileCornerRadius ?? 4.0;
    final leftRadius = segment?.isFirstSegment ?? true ? cornerRadius : 0.0;
    final rightRadius = segment?.isLastSegment ?? true ? cornerRadius : 0.0;

    final tileColor = valid
        ? (theme.dropTargetTileBackgroundColor ??
              theme.eventTileBackgroundColor ??
              event.color ??
              Colors.blue)
        : (theme.dropTargetTileInvalidBackgroundColor ??
              theme.eventTileBackgroundColor ??
              Colors.red.withValues(alpha: 0.5));

    final borderWidth =
        theme.dropTargetTileBorderWidth ?? theme.eventTileBorderWidth ?? 0.0;
    final borderColor =
        theme.dropTargetTileBorderColor ?? theme.eventTileBorderColor;
    final hasBorder = borderWidth > 0 && borderColor != null;
    final isFirstSegment = segment?.isFirstSegment ?? true;
    final isLastSegment = segment?.isLastSegment ?? true;

    Border? tileBorder;
    if (hasBorder) {
      final topBorder = BorderSide(color: borderColor, width: borderWidth);
      final bottomBorder = BorderSide(color: borderColor, width: borderWidth);
      final leftBorder = isFirstSegment
          ? BorderSide(color: borderColor, width: borderWidth)
          : BorderSide.none;
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
    );
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
    final firstDayOfWeek = widget.firstDayOfWeek;

    return LayoutBuilder(
      builder: (context, constraints) {
        final weekNumberWidth = widget.showWeekNumbers
            ? _WeekNumberCell.columnWidth
            : 0.0;
        final contentWidth = constraints.maxWidth - weekNumberWidth;
        final dayWidth = _weeks.isNotEmpty ? contentWidth / 7 : 0.0;
        final rowHeight = _weeks.isNotEmpty
            ? constraints.maxHeight / _weeks.length
            : 0.0;
        final dateLabelHeight = widget.theme.dateLabelHeight ?? 18.0;

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
        final config = MCalWeekLayoutConfig.fromTheme(
          widget.theme,
          maxVisibleEventsPerDay: widget.maxVisibleEventsPerDay,
        );
        Widget noOpOverflow(
          BuildContext ctx,
          MCalOverflowIndicatorContext overflowContext,
        ) => const SizedBox.shrink();

        return Column(
          children: List.generate(_weeks.length, (weekRowIndex) {
            final weekDates = _weeks[weekRowIndex];
            final columnWidths = List.filled(7, dayWidth);
            final segments = weekRowIndex < phantomSegments.length
                ? phantomSegments[weekRowIndex]
                : <MCalEventSegment>[];
            final layoutContext = MCalWeekLayoutContext(
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
                : MCalDefaultWeekLayoutBuilder.build(context, layoutContext);
            return Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.showWeekNumbers)
                    SizedBox(width: _WeekNumberCell.columnWidth),
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

    final highlightedCells = dragHandler.highlightedCells;
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
        painter: _DropTargetHighlightPainter(
          highlightedCells: highlightedCells,
          dropStartWeekRow: first.weekRowIndex,
          dropStartCellIndex: first.cellIndex,
          dropEndWeekRow: last.weekRowIndex,
          dropEndCellIndex: last.cellIndex,
          isValid: isValid,
          validColor:
              widget.theme.dropTargetCellValidColor ??
              Colors.green.withValues(alpha: 0.3),
          invalidColor:
              widget.theme.dropTargetCellInvalidColor ??
              Colors.red.withValues(alpha: 0.3),
          borderRadius: widget.theme.dropTargetCellBorderRadius ?? 4.0,
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
            enableResize: widget.enableResize,
            onResizeStartCallback: _handleResizeStart,
            onResizeUpdateCallback: _handleResizeUpdate,
            onResizeEndCallback: _handleResizeEnd,
            onResizeCancelCallback: _handleResizeCancel,
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
          // Build drop-feedback layers (order controlled by dropTargetTilesAboveOverlay)
          // Show during both drag and resize operations
          final showFeedback = _isDragOrResizeActive;
          final tilesLayer = (widget.showDropTargetTiles && showFeedback)
              ? Positioned.fill(
                  child: RepaintBoundary(
                    child: IgnorePointer(
                      child: _buildDropTargetTilesLayer(context),
                    ),
                  ),
                )
              : null;

          final overlayLayer = (widget.showDropTargetOverlay && showFeedback)
              ? Positioned.fill(
                  child: RepaintBoundary(
                    child: IgnorePointer(
                      child: _buildDropTargetOverlayLayer(context),
                    ),
                  ),
                )
              : null;

          // By default (dropTargetTilesAboveOverlay: false), tiles are Layer 3
          // (below) and overlay is Layer 4 (above). When true, the order reverses.
          final firstLayer = widget.dropTargetTilesAboveOverlay
              ? overlayLayer
              : tilesLayer;
          final secondLayer = widget.dropTargetTilesAboveOverlay
              ? tilesLayer
              : overlayLayer;

          final stack = Stack(
            children: [
              // Layer 1+2: Main content (week rows with grid and events)
              weekRowsColumn,
              if (firstLayer != null) firstLayer,
              if (secondLayer != null) secondLayer,
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
  final MCalEventTileBuilder? dropTargetTileBuilder;
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

  /// Long-press delay before drag starts.
  final Duration dragLongPressDelay;

  /// Whether event resize handles should be shown on multi-day event tiles.
  final bool enableResize;

  /// Called when the user begins dragging a resize handle.
  final void Function(MCalCalendarEvent event, MCalResizeEdge edge)?
  onResizeStartCallback;

  /// Called as the user drags a resize handle, with pixel dx and day width.
  final void Function(double dx, double dayWidth)? onResizeUpdateCallback;

  /// Called when the user releases a resize handle.
  final VoidCallback? onResizeEndCallback;

  /// Called when a resize drag is cancelled by the system.
  final VoidCallback? onResizeCancelCallback;

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
    this.dropTargetTileBuilder,
    this.dropTargetCellBuilder,
    this.onDragWillAccept,
    this.onEventDropped,
    required this.controller,
    // Drag lifecycle callbacks (Task 21)
    this.onDragStartedCallback,
    this.onDragEndedCallback,
    this.onDragCanceledCallback,
    this.dragHandler,
    this.dragLongPressDelay = const Duration(milliseconds: 200),
    // Resize
    this.enableResize = false,
    this.onResizeStartCallback,
    this.onResizeUpdateCallback,
    this.onResizeEndCallback,
    this.onResizeCancelCallback,
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
          dropTargetCellBuilder: widget.dropTargetCellBuilder,
          onDragWillAccept: widget.onDragWillAccept,
          onEventDropped: widget.onEventDropped,
          controller: widget.controller,
          onDragStartedCallback: widget.onDragStartedCallback,
          onDragEndedCallback: widget.onDragEndedCallback,
          onDragCanceledCallback: widget.onDragCanceledCallback,
          dragLongPressDelay: widget.dragLongPressDelay,
          enableResize: widget.enableResize,
          onResizeStartCallback: widget.onResizeStartCallback,
          onResizeUpdateCallback: widget.onResizeUpdateCallback,
          onResizeEndCallback: widget.onResizeEndCallback,
          onResizeCancelCallback: widget.onResizeCancelCallback,
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
      dragLongPressDelay: widget.dragLongPressDelay,
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

    // Optionally wrap event tile builder with resize handles for multi-day events
    final MCalEventTileBuilder finalEventTileBuilder;
    if (widget.enableResize) {
      finalEventTileBuilder = (BuildContext ctx, MCalEventTileContext tileCtx) {
        final tile = wrappedEventTileBuilder(ctx, tileCtx);
        final segment = tileCtx.segment;

        // Only add resize handles for multi-day events (not single-day)
        if (segment == null || segment.isSingleDay) return tile;

        final children = <Widget>[Positioned.fill(child: tile)];
        if (segment.isFirstSegment) {
          children.add(
            _ResizeHandle(
              edge: MCalResizeEdge.start,
              event: tileCtx.event,
              onResizeStart: () => widget.onResizeStartCallback?.call(
                tileCtx.event,
                MCalResizeEdge.start,
              ),
              onResizeUpdate: (dx) => widget.onResizeUpdateCallback?.call(
                dx,
                dayWidth,
              ),
              onResizeEnd: () => widget.onResizeEndCallback?.call(),
              onResizeCancel: () => widget.onResizeCancelCallback?.call(),
            ),
          );
        }
        if (segment.isLastSegment) {
          children.add(
            _ResizeHandle(
              edge: MCalResizeEdge.end,
              event: tileCtx.event,
              onResizeStart: () => widget.onResizeStartCallback?.call(
                tileCtx.event,
                MCalResizeEdge.end,
              ),
              onResizeUpdate: (dx) => widget.onResizeUpdateCallback?.call(
                dx,
                dayWidth,
              ),
              onResizeEnd: () => widget.onResizeEndCallback?.call(),
              onResizeCancel: () => widget.onResizeCancelCallback?.call(),
            ),
          );
        }

        // Only wrap in Stack if we actually added handles
        if (children.length > 1) {
          return Stack(clipBehavior: Clip.none, children: children);
        }
        return tile;
      };
    } else {
      finalEventTileBuilder = wrappedEventTileBuilder;
    }

    // Create the week layout context
    final layoutContext = MCalWeekLayoutContext(
      segments: weekSegments,
      dates: widget.dates,
      columnWidths: columnWidths,
      rowHeight: rowHeight,
      weekRowIndex: widget.weekRowIndex,
      currentMonth: widget.currentMonth,
      config: config,
      eventTileBuilder: finalEventTileBuilder,
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

  // Note: _buildDropTargetTilesLayer and _shouldHighlightCell have been removed.
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

  /// Long-press delay before drag starts.
  final Duration dragLongPressDelay;

  /// Reserved height for multi-day events above single-day events.
  /// When > 0, single-day events are pushed down by this amount.
  final double multiDayReservedHeight;

  /// Whether to show date labels in this cell.
  /// Set to false for Layer 1 grid cells when date labels are rendered in Layer 2.
  final bool showDateLabel;

  /// Whether event resize handles should be shown on multi-day event tiles.
  final bool enableResize;

  /// Called when the user begins dragging a resize handle.
  final void Function(MCalCalendarEvent event, MCalResizeEdge edge)?
  onResizeStartCallback;

  /// Called as the user drags a resize handle, with pixel dx and day width.
  final void Function(double dx, double dayWidth)? onResizeUpdateCallback;

  /// Called when the user releases a resize handle.
  final VoidCallback? onResizeEndCallback;

  /// Called when a resize drag is cancelled by the system.
  final VoidCallback? onResizeCancelCallback;

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
    this.dropTargetCellBuilder,
    this.onDragWillAccept,
    this.onEventDropped,
    required this.controller,
    // Drag lifecycle callbacks (Task 21)
    this.onDragStartedCallback,
    this.onDragEndedCallback,
    this.onDragCanceledCallback,
    this.dragLongPressDelay = const Duration(milliseconds: 200),
    // Resize
    this.enableResize = false,
    this.onResizeStartCallback,
    this.onResizeUpdateCallback,
    this.onResizeEndCallback,
    this.onResizeCancelCallback,
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

        // Cell structure:
        // - Outer container with decoration (cell background/border)
        // - Column with:
        //   - Date label (with horizontal padding)
        //   - Multi-day reserved spacer (full width, no padding)
        //   - Single-day event tiles (full width, no horizontal padding -
        //     tiles handle their own margins)
        return Container(
          decoration: decoration,
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
                    SizedBox(height: multiDayReservedHeight),
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
        controller: controller,
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
              dragLongPressDelay: dragLongPressDelay,
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

      // Wrap with resize handles for multi-day events when resize is enabled
      // (Legacy Layer 1 rendering path)
      // Note: In legacy Layer 1, the cell width serves as an approximate
      // dayWidth since each cell represents one day.
      if (enableResize && eventSpanInfo.length > 1) {
        final capturedEvent = event;
        final resizeChildren = <Widget>[Positioned.fill(child: tile)];
        if (eventSpanInfo.isStart) {
          resizeChildren.add(
            _ResizeHandle(
              edge: MCalResizeEdge.start,
              event: capturedEvent,
              onResizeStart: () => onResizeStartCallback?.call(
                capturedEvent,
                MCalResizeEdge.start,
              ),
              // dayWidth will be obtained from the _MonthPageWidgetState
              // layout cache via _handleResizeStart, so we pass 0 here
              // as a fallback — the actual width comes from context.
              onResizeUpdate: (dx) => onResizeUpdateCallback?.call(dx, 0),
              onResizeEnd: () => onResizeEndCallback?.call(),
              onResizeCancel: () => onResizeCancelCallback?.call(),
            ),
          );
        }
        if (eventSpanInfo.isEnd) {
          resizeChildren.add(
            _ResizeHandle(
              edge: MCalResizeEdge.end,
              event: capturedEvent,
              onResizeStart: () => onResizeStartCallback?.call(
                capturedEvent,
                MCalResizeEdge.end,
              ),
              onResizeUpdate: (dx) => onResizeUpdateCallback?.call(dx, 0),
              onResizeEnd: () => onResizeEndCallback?.call(),
              onResizeCancel: () => onResizeCancelCallback?.call(),
            ),
          );
        }
        if (resizeChildren.length > 1) {
          tile = Stack(clipBehavior: Clip.none, children: resizeChildren);
        }
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
  final MCalEventController controller;

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
    required this.controller,
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
      final meta = _getRecurrenceMetadata(event, controller);
      final contextObj = MCalEventTileContext(
        event: event,
        displayDate: displayDate,
        isAllDay: isAllDay,
        isRecurring: meta.isRecurring,
        seriesId: meta.seriesId,
        recurrenceRule: meta.recurrenceRule,
        masterEvent: meta.masterEvent,
        isException: meta.isException,
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
          final meta = _getRecurrenceMetadata(event, controller);
          final contextObj = MCalEventTileContext(
            event: event,
            displayDate: displayDate,
            isAllDay: isAllDay,
            isRecurring: meta.isRecurring,
            seriesId: meta.seriesId,
            recurrenceRule: meta.recurrenceRule,
            masterEvent: meta.masterEvent,
            isException: meta.isException,
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
    var label = '${event.title}, $timeStr';

    if (spanLength > 1) {
      final eventStartDate = DateTime(
        event.start.year,
        event.start.month,
        event.start.day,
      );
      final cellDate = DateTime(
        displayDate.year,
        displayDate.month,
        displayDate.day,
      );
      final dayPosition = daysBetween(eventStartDate, cellDate) + 1;
      final spanLabel = localizations.formatMultiDaySpanLabel(
        spanLength,
        dayPosition,
        locale,
      );
      label = '$label, $spanLabel';
    }

    return label;
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

/// A thin draggable zone on the leading or trailing edge of an event tile
/// that allows the user to resize the event by dragging.
///
/// The handle is positioned as a narrow vertical strip (default 8dp wide)
/// at the start or end edge of the event tile. It provides:
/// - A `SystemMouseCursors.resizeColumn` cursor on hover
/// - Horizontal drag gesture callbacks for resize interaction
/// - RTL-aware positioning using `Directionality.of(context)`
/// - Semantic labels for accessibility ("Resize start edge" / "Resize end edge")
///
/// This widget must be placed inside a [Stack] alongside the event tile.
class _ResizeHandle extends StatelessWidget {
  const _ResizeHandle({
    required this.edge,
    required this.event,
    required this.onResizeStart,
    required this.onResizeUpdate,
    required this.onResizeEnd,
    required this.onResizeCancel,
  });

  /// Which edge this handle is positioned on.
  final MCalResizeEdge edge;

  /// The event this handle belongs to.
  final MCalCalendarEvent event;

  /// Called when the user begins a horizontal drag on the handle.
  final VoidCallback onResizeStart;

  /// Called as the user drags horizontally, with the delta X in pixels.
  final ValueChanged<double> onResizeUpdate;

  /// Called when the user finishes dragging.
  final VoidCallback onResizeEnd;

  /// Called when the drag is cancelled (e.g. interrupted by the system).
  final VoidCallback onResizeCancel;

  /// The width of the interactive handle zone in logical pixels.
  static const double handleWidth = 8.0;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    // In LTR: start edge is on the left, end edge is on the right
    // In RTL: start edge is on the right, end edge is on the left
    final isLeading = (edge == MCalResizeEdge.start) != isRtl;

    return Positioned(
      left: isLeading ? 0 : null,
      right: isLeading ? null : 0,
      top: 0,
      bottom: 0,
      width: handleWidth,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (_) => onResizeStart(),
          onHorizontalDragUpdate: (details) => onResizeUpdate(details.delta.dx),
          onHorizontalDragEnd: (_) => onResizeEnd(),
          onHorizontalDragCancel: () => onResizeCancel(),
          child: Semantics(
            label: edge == MCalResizeEdge.start
                ? 'Resize start edge'
                : 'Resize end edge',
            child: Center(
              child: Container(
                width: 2,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget for displaying overflow event indicator.
///
/// This widget displays a "+N more" indicator when there are more events
/// than can be shown in a day cell. It supports tap and long-press interactions:
/// - On tap: calls [onOverflowTap] if provided, otherwise shows a default bottom sheet
/// - On long-press: calls [onOverflowLongPress] if provided
///
/// Drag-and-drop is not supported on the overflow indicator. Only visible
/// event tiles can be dragged.
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

/// Returns phantom event segments for the proposed drop range (Layer 3).
///
/// Creates a synthetic all-day event from [proposedStartDate] to [proposedEndDate],
/// then uses [MCalMultiDayRenderer.calculateAllEventSegments] to get one segment
/// per week row that the range intersects.
List<List<MCalEventSegment>> _getPhantomSegmentsForDropTarget({
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

/// CustomPainter for rendering drop target highlights efficiently.
///
/// This is the default highlight renderer used when neither
/// [MCalMonthView.dropTargetOverlayBuilder] nor [MCalMonthView.dropTargetCellBuilder]
/// is provided. It draws colored rounded rectangles for each highlighted cell.
///
/// [shouldRepaint] uses index-based comparison (drop start/end week row and cell
/// indices) instead of list reference or Rect comparison for better performance.
class _DropTargetHighlightPainter extends CustomPainter {
  /// The list of cells to highlight.
  final List<MCalHighlightCellInfo> highlightedCells;

  /// Week row index of the first highlighted cell (for [shouldRepaint]).
  final int dropStartWeekRow;

  /// Cell index of the first highlighted cell (for [shouldRepaint]).
  final int dropStartCellIndex;

  /// Week row index of the last highlighted cell (for [shouldRepaint]).
  final int dropEndWeekRow;

  /// Cell index of the last highlighted cell (for [shouldRepaint]).
  final int dropEndCellIndex;

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
    required this.dropStartWeekRow,
    required this.dropStartCellIndex,
    required this.dropEndWeekRow,
    required this.dropEndCellIndex,
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
    if (oldDelegate.isValid != isValid) return true;
    if (oldDelegate.validColor != validColor) return true;
    if (oldDelegate.invalidColor != invalidColor) return true;
    if (oldDelegate.borderRadius != borderRadius) return true;
    if (oldDelegate.highlightedCells.length != highlightedCells.length) {
      return true;
    }

    // Index-based comparison: repaint only when drop target cell indices change.
    if (oldDelegate.dropStartWeekRow != dropStartWeekRow ||
        oldDelegate.dropStartCellIndex != dropStartCellIndex ||
        oldDelegate.dropEndWeekRow != dropEndWeekRow ||
        oldDelegate.dropEndCellIndex != dropEndCellIndex) {
      return true;
    }

    return false;
  }
}
