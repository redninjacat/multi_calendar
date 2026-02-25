import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../controllers/mcal_event_controller.dart';
import '../models/mcal_calendar_event.dart';
import '../models/mcal_time_region.dart';
import '../styles/mcal_theme.dart';
import '../utils/date_utils.dart';
import '../utils/mcal_date_format_utils.dart';
import '../utils/mcal_scroll_behavior.dart';
import '../../l10n/mcal_localizations.dart';
import '../utils/mcal_l10n_helper.dart';
import '../utils/day_view_overlap.dart';
import '../utils/time_utils.dart';
import 'mcal_callback_details.dart';
import 'mcal_day_view_contexts.dart';
import 'mcal_drag_handler.dart';
import 'mcal_draggable_event_tile.dart';
import 'mcal_layout_directionality.dart';
import 'mcal_month_view_contexts.dart' show MCalWeekNumberContext;

// ============================================================================
// Keyboard Shortcut Intents
// ============================================================================

/// Intent for the "create new event" keyboard shortcut (Cmd/Ctrl+N).
///
/// When [MCalDayView.enableKeyboardNavigation] is true, pressing Cmd+N (Mac)
/// or Ctrl+N (Windows/Linux) triggers [MCalDayView.onCreateEventRequested].
///
/// Override via [MCalDayView.keyboardShortcuts] to customize the activator.
class MCalDayViewCreateEventIntent extends Intent {
  const MCalDayViewCreateEventIntent();
}

/// Intent for the "delete event" keyboard shortcut (Cmd/Ctrl+D, Delete, Backspace).
///
/// When [MCalDayView.enableKeyboardNavigation] is true and an event has focus,
/// pressing Cmd+D, Delete, or Backspace triggers [MCalDayView.onDeleteEventRequested].
///
/// Override via [MCalDayView.keyboardShortcuts] to customize the activator.
class MCalDayViewDeleteEventIntent extends Intent {
  const MCalDayViewDeleteEventIntent();
}

/// Intent for the "edit event" keyboard shortcut (Cmd/Ctrl+E).
///
/// When [MCalDayView.enableKeyboardNavigation] is true and an event has focus,
/// pressing Cmd+E (Mac) or Ctrl+E (Windows/Linux) triggers
/// [MCalDayView.onEditEventRequested].
///
/// Override via [MCalDayView.keyboardShortcuts] to customize the activator.
class MCalDayViewEditEventIntent extends Intent {
  const MCalDayViewEditEventIntent();
}

/// Intent for keyboard move mode (Ctrl+M or Cmd+M).
///
/// When [MCalDayView.enableKeyboardNavigation] is true and an event has focus,
/// pressing Ctrl+M (Windows/Linux) or Cmd+M (Mac) enters keyboard move mode.
/// Arrow keys then move the event; Enter confirms, Escape cancels.
class MCalDayViewKeyboardMoveIntent extends Intent {
  const MCalDayViewKeyboardMoveIntent();
}

/// Intent for keyboard resize mode (Ctrl+R or Cmd+R).
///
/// When [MCalDayView.enableKeyboardNavigation] is true and an event has focus,
/// pressing Ctrl+R (Windows/Linux) or Cmd+R (Mac) enters keyboard resize mode.
/// Arrow Up/Down adjust time; Tab switches edge; Enter confirms, Escape cancels.
class MCalDayViewKeyboardResizeIntent extends Intent {
  const MCalDayViewKeyboardResizeIntent();
}

// ============================================================================
// MCalDayView Widget
// ============================================================================

/// A Day View calendar widget that displays events for a single day in a time-based vertical layout.
///
/// The Day View provides a vertical timeline with hour markers, gridlines, and events positioned
/// according to their start and end times. It supports:
///
/// - Configurable time range (startHour/endHour) and granularity (timeSlotDuration)
/// - All-day events section at the top
/// - Timed events with automatic overlap detection and side-by-side layout
/// - Drag-and-drop to move events (including type conversion between all-day and timed)
/// - Drag-to-resize event duration
/// - Magnetic snapping to time slots, other events, and current time
/// - Special time regions (blocked time, lunch breaks, non-working hours)
/// - Current time indicator with live updates
/// - Keyboard navigation and accessibility support
/// - Extensive customization via builders and theme properties
/// - RTL (right-to-left) layout support for Arabic, Hebrew, and other RTL languages
///
/// ## RTL Support
///
/// When [locale] or the ambient [Directionality] indicates RTL (e.g., Arabic `ar`):
/// - Time legend appears on the right side
/// - Navigator arrows flip (previous/next swap positions)
/// - Day header and week number position for RTL
/// - Event tiles, drag handles, and resize handles align correctly
/// - All interactions (drag, resize, tap) work in RTL
///
/// Pass [locale] for RTL languages or wrap in [Directionality] with
/// [TextDirection.rtl] to test RTL layout.
///
/// ## Basic Usage
///
/// ```dart
/// MCalDayView(
///   controller: myEventController,
///   startHour: 8,
///   endHour: 18,
///   showNavigator: true,
///   enableDragToMove: true,
/// )
/// ```
///
/// ## Event Interaction
///
/// Events can be tapped, long-pressed, dragged, and resized. Use the corresponding
/// callbacks to handle these interactions:
///
/// ```dart
/// MCalDayView(
///   controller: controller,
///   onEventTap: (details) => print('Tapped ${details.event.title}'),
///   onEventDropped: (context, details) {
///     print('Dropped at ${details.newStartDate}');
///     return true; // Accept the change
///   },
///   onEventResized: (context, details) {
///     print('Resized to ${details.newDuration}');
///     return true; // Accept the change
///   },
/// )
/// ```
///
/// ## Customization
///
/// All visual elements can be customized via builder callbacks or theme properties:
///
/// ```dart
/// MCalDayView(
///   controller: controller,
///   timedEventTileBuilder: (context, event, ctx) => MyCustomTile(event),
///   theme: MCalThemeData(
///     hourGridlineColor: Colors.grey.shade300,
///     currentTimeIndicatorColor: Colors.red,
///   ),
/// )
/// ```
///
/// See also:
/// - [MCalEventController] for managing calendar events
/// - [MCalThemeData] for theming options
/// - [MCalDayViewContexts] for context objects passed to builders
class MCalDayView extends StatefulWidget {
  /// Creates a Day View calendar widget.
  const MCalDayView({
    super.key,
    required this.controller,

    // Time configuration
    this.startHour = 0,
    this.endHour = 23,
    this.timeSlotDuration = const Duration(minutes: 15),
    this.hourHeight,

    // Display
    this.showNavigator = false,
    this.showCurrentTimeIndicator = true,
    this.showWeekNumbers = false,
    this.weekNumberBuilder,
    this.gridlineInterval = const Duration(minutes: 15),
    this.dateFormat,
    this.timeLabelFormat,
    this.locale,
    this.textDirection,
    this.layoutDirection,
    this.showSubHourLabels = false,
    this.subHourLabelInterval,
    this.subHourLabelBuilder,

    // Scrolling
    this.autoScrollToCurrentTime = true,
    this.initialScrollTime,
    this.initialScrollDuration = Duration.zero,
    this.initialScrollCurve = Curves.easeInOut,
    this.scrollPhysics,
    this.scrollController,

    // All-day section
    this.allDaySectionMaxRows = 3,
    this.allDayToTimedDuration = const Duration(hours: 1),

    // Drag and drop
    this.enableDragToMove = false,
    this.enableDragToResize,
    this.dragEdgeNavigationEnabled = true,
    this.dragLongPressDelay = const Duration(milliseconds: 200),
    this.dragEdgeNavigationDelay = const Duration(milliseconds: 1200),
    this.showDropTargetTiles = true,
    this.showDropTargetOverlay = true,
    this.dropTargetTilesAboveOverlay = false,

    // Snapping
    this.snapToTimeSlots = true,
    this.snapToOtherEvents = true,
    this.snapToCurrentTime = true,
    this.snapRange = const Duration(minutes: 5),

    // Special time regions
    this.specialTimeRegions = const [],

    // Keyboard
    this.enableKeyboardNavigation = true,
    this.autoFocusOnEventTap = true,
    this.keyboardShortcuts,

    // Animations
    this.enableAnimations,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,

    // Boundaries
    this.minDate,
    this.maxDate,

    // Swipe Navigation
    this.enableSwipeNavigation = false,
    this.onSwipeNavigation,

    // Builders
    this.dayHeaderBuilder,
    this.timeLabelBuilder,
    this.gridlineBuilder,
    this.allDayEventTileBuilder,
    this.timedEventTileBuilder,
    this.currentTimeIndicatorBuilder,
    this.navigatorBuilder,
    this.dayLayoutBuilder,
    this.draggedTileBuilder,
    this.dragSourceTileBuilder,
    this.dropTargetTileBuilder,
    this.dropTargetOverlayBuilder,
    this.timeResizeHandleBuilder,
    this.resizeHandleInset,
    this.loadingBuilder,
    this.errorBuilder,
    this.timeRegionBuilder,
    this.timeSlotInteractivityCallback,

    // Interaction callbacks
    this.onDayHeaderTap,
    this.onDayHeaderLongPress,
    this.onDayHeaderDoubleTap,
    this.onTimeLabelTap,
    this.onTimeLabelLongPress,
    this.onTimeLabelDoubleTap,
    this.onTimeSlotTap,
    this.onTimeSlotLongPress,
    this.onTimeSlotDoubleTap,
    this.onEventTap,
    this.onEventLongPress,
    this.onEventDoubleTap,
    this.onHoverEvent,
    this.onHoverTimeSlot,
    this.onHoverDayHeader,
    this.onHoverTimeLabel,
    this.onHoverOverflow,
    this.onOverflowTap,
    this.onOverflowLongPress,
    this.onOverflowDoubleTap,

    // Keyboard shortcut callbacks
    this.onCreateEventRequested,
    this.onDeleteEventRequested,
    this.onEditEventRequested,

    // Drag and drop callbacks
    this.onDragWillAccept,
    this.onEventDropped,
    this.onResizeWillAccept,
    this.onEventResized,

    // State change callbacks
    this.onDisplayDateChanged,
    this.onScrollChanged,

    // Accessibility
    this.semanticsLabel,

    // Theme
    this.theme,
  }) : assert(
         endHour > startHour,
         'endHour ($endHour) must be greater than startHour ($startHour)',
       );

  /// The event controller that manages calendar events and display date.
  ///
  /// This controller provides access to events, handles event modifications,
  /// and controls which day is currently displayed.
  final MCalEventController controller;

  // ============================================================================
  // Time Configuration
  // ============================================================================

  /// The starting hour of the day view (0-23).
  ///
  /// Events before this hour will not be displayed in the time grid.
  /// Defaults to 0 (midnight).
  ///
  /// Example: Set to 8 for a work day view (8 AM - 6 PM):
  /// ```dart
  /// MCalDayView(
  ///   controller: controller,
  ///   startHour: 8,
  ///   endHour: 18,
  /// )
  /// ```
  final int startHour;

  /// The ending hour of the day view (0-23).
  ///
  /// Events after this hour will not be displayed in the time grid.
  /// Defaults to 23 (11 PM).
  ///
  /// Must be greater than [startHour].
  final int endHour;

  /// The granularity of time slots for event snapping and positioning.
  ///
  /// When dragging or resizing events, they will snap to multiples of this duration.
  /// Common values: 15 minutes, 30 minutes, 1 hour.
  ///
  /// Defaults to 15 minutes.
  final Duration timeSlotDuration;

  /// The pixel height of one hour in the day view.
  ///
  /// If null, automatically calculated based on available height.
  /// Larger values make the timeline more spacious but require more scrolling.
  ///
  /// Example: 80.0 for a spacious timeline, 40.0 for compact.
  final double? hourHeight;

  // ============================================================================
  // Display Options
  // ============================================================================

  /// Whether to show the navigation bar at the top.
  ///
  /// The navigator displays the current date and provides Previous/Today/Next buttons
  /// for day-to-day navigation.
  ///
  /// Defaults to false.
  final bool showNavigator;

  /// Whether to show the current time indicator.
  ///
  /// A horizontal line with a leading dot that marks the current time.
  /// Updates every minute.
  ///
  /// Defaults to true.
  final bool showCurrentTimeIndicator;

  /// Whether to show the ISO 8601 week number in the day header.
  ///
  /// When true, displays the week number (1-53) in the top-leading corner.
  ///
  /// Defaults to false.
  final bool showWeekNumbers;

  /// Builder callback for customizing week number display in the day header.
  ///
  /// Receives [BuildContext], [MCalWeekNumberContext] with week number data,
  /// and the default week number widget as parameters.
  ///
  /// Return a custom widget to override the default week number badge, or
  /// wrap/modify the default widget to preserve consistent styling while
  /// adding customization.
  ///
  /// Only applies when [showWeekNumbers] is true.
  ///
  /// Example: Custom styling for week numbers
  /// ```dart
  /// weekNumberBuilder: (context, weekContext, defaultWidget) {
  ///   return Container(
  ///     decoration: BoxDecoration(
  ///       color: Colors.blue,
  ///       borderRadius: BorderRadius.circular(8),
  ///     ),
  ///     padding: EdgeInsets.all(8),
  ///     child: Text(
  ///       'Week ${weekContext.weekNumber}',
  ///       style: TextStyle(color: Colors.white),
  ///     ),
  ///   );
  /// }
  /// ```
  final Widget Function(
    BuildContext context,
    MCalWeekNumberContext weekContext,
    Widget defaultWidget,
  )?
  weekNumberBuilder;

  /// The interval between gridlines in the time grid.
  ///
  /// Valid values: 1, 5, 10, 15, 20, 30, or 60 minutes.
  /// Gridlines are classified as hour (on the hour), major (30 min), or minor (other).
  ///
  /// Defaults to 15 minutes.
  ///
  /// Example: Show gridlines every 30 minutes:
  /// ```dart
  /// MCalDayView(
  ///   controller: controller,
  ///   gridlineInterval: Duration(minutes: 30),
  /// )
  /// ```
  final Duration gridlineInterval;

  /// Custom date format for displaying the day header.
  ///
  /// If null, uses locale-appropriate default format.
  /// Uses [intl.DateFormat] syntax.
  ///
  /// Example: 'EEEE, MMMM d, yyyy' for "Monday, February 14, 2026"
  final DateFormat? dateFormat;

  /// Custom time format for hour labels in the time legend.
  ///
  /// If null, uses locale-appropriate default format.
  /// Uses [intl.DateFormat] syntax.
  ///
  /// Example: 'HH:mm' for 24-hour format, 'h a' for 12-hour format
  final DateFormat? timeLabelFormat;

  /// The locale for date/time formatting.
  ///
  /// If null, uses the system locale from [Localizations].
  final Locale? locale;

  /// Controls the direction used to render text within the calendar (event
  /// titles, time labels, day header, etc.).
  ///
  /// This only affects text rendering — it does **not** control the visual
  /// layout of the time legend, navigation buttons, or swipe direction. Use
  /// [layoutDirection] for those concerns.
  ///
  /// Resolution priority:
  ///   1. This parameter (if provided).
  ///   2. Ambient [Directionality] from the widget tree.
  ///   3. [locale]-based detection via [MCalDateFormatUtils.isRTL] (if locale
  ///      is available).
  ///   4. [TextDirection.ltr] as a final fallback.
  ///
  /// Setting this independently from [layoutDirection] allows RTL scripts
  /// (e.g., Hebrew, Arabic) to render text correctly while keeping the
  /// time legend and navigation in an LTR layout.
  final TextDirection? textDirection;

  /// Controls the visual layout direction of the calendar — column ordering,
  /// navigation button positions, time-legend placement, swipe direction, and
  /// drag edge detection.
  ///
  /// This does **not** affect text rendering. Use [textDirection] for that.
  ///
  /// Resolution priority:
  ///   1. This parameter (if provided).
  ///   2. Ambient [Directionality] from the widget tree.
  ///   3. [locale]-based detection via [MCalDateFormatUtils.isRTL] (if locale
  ///      is available).
  ///   4. [TextDirection.ltr] as a final fallback.
  ///
  /// Setting this independently from [textDirection] allows RTL scripts
  /// (e.g., Hebrew, Arabic) to render text correctly while keeping the
  /// time legend and navigation in an LTR layout.
  final TextDirection? layoutDirection;

  /// Whether to display sub-hour time labels in the time legend.
  ///
  /// When true and [subHourLabelInterval] is set, additional time labels are
  /// rendered between each hour mark (e.g., at 30-minute intervals).
  ///
  /// Sub-hour labels use a smaller font size (80% of the hour label size) and
  /// lighter color (50% opacity) by default. Customize via [subHourLabelBuilder].
  ///
  /// Defaults to false.
  final bool showSubHourLabels;

  /// The interval at which sub-hour labels appear.
  ///
  /// Only used when [showSubHourLabels] is true. Common values are
  /// `Duration(minutes: 30)` or `Duration(minutes: 15)`.
  ///
  /// The interval must be less than 60 minutes. If null, no sub-hour labels
  /// are rendered even if [showSubHourLabels] is true.
  final Duration? subHourLabelInterval;

  /// Builder for sub-hour time labels.
  ///
  /// When non-null, replaces the default sub-hour label rendering.
  /// The default sub-hour label uses smaller, lighter text compared to hour labels.
  ///
  /// Receives [MCalTimeLabelContext] with the sub-hour time (hour and minute fields set).
  /// The [Widget] parameter is the default sub-hour label widget.
  final Widget Function(
    BuildContext context,
    MCalTimeLabelContext labelContext,
    Widget defaultWidget,
  )?
  subHourLabelBuilder;

  // ============================================================================
  // Scrolling
  // ============================================================================

  /// Whether to automatically scroll to the current time on initial load.
  ///
  /// When true, the view scrolls to position the current time in the center of
  /// the viewport when first displayed. The scroll is instant by default;
  /// set [initialScrollDuration] to a positive value for an animated scroll.
  ///
  /// Ignored when [initialScrollTime] is non-null.
  ///
  /// Defaults to true.
  final bool autoScrollToCurrentTime;

  /// The time to scroll to on widget creation.
  ///
  /// When non-null, the view will scroll to this time when first displayed,
  /// overriding [autoScrollToCurrentTime]. Use this to open the day view
  /// focused on a specific time (e.g., 9:00 AM for work day start).
  ///
  /// When null, [autoScrollToCurrentTime] controls initial scroll behavior.
  final TimeOfDay? initialScrollTime;

  /// Duration for the initial auto-scroll animation.
  ///
  /// Controls how the view scrolls to the current time (or [initialScrollTime])
  /// on first load when [autoScrollToCurrentTime] is true.
  ///
  /// - [Duration.zero] (default): instant jump with no animation.
  /// - Any positive [Duration]: animated scroll using [initialScrollCurve].
  ///
  /// Defaults to [Duration.zero].
  final Duration initialScrollDuration;

  /// Animation curve for the initial auto-scroll when [initialScrollDuration]
  /// is greater than [Duration.zero].
  ///
  /// Has no effect when [initialScrollDuration] is [Duration.zero].
  ///
  /// Defaults to [Curves.easeInOut].
  final Curve initialScrollCurve;

  /// The scroll physics for the time grid.
  ///
  /// If null, uses platform-appropriate default physics.
  final ScrollPhysics? scrollPhysics;

  /// Optional external scroll controller for the time grid.
  ///
  /// If provided, you can programmatically control scrolling.
  /// If null, an internal controller is created.
  final ScrollController? scrollController;

  // ============================================================================
  // All-Day Events Section
  // ============================================================================

  /// The maximum number of all-day event rows to display.
  ///
  /// If more all-day events exist, an overflow indicator is shown.
  ///
  /// Defaults to 3.
  final int allDaySectionMaxRows;

  /// The default duration for all-day events converted to timed events.
  ///
  /// When dragging an all-day event into the time grid, it will be given this duration.
  ///
  /// Defaults to 1 hour.
  final Duration allDayToTimedDuration;

  // ============================================================================
  // Drag and Drop
  // ============================================================================

  /// Whether events can be dragged to move them.
  ///
  /// Enables long-press drag on both all-day and timed events.
  /// Supports moving within the day, across days (via edge navigation),
  /// and type conversion (all-day ↔ timed).
  ///
  /// Defaults to false.
  final bool enableDragToMove;

  /// Whether events can be resized by dragging their edges.
  ///
  /// If null, automatically enabled on desktop/web, disabled on mobile.
  /// Only applies to timed events (all-day events cannot be resized).
  final bool? enableDragToResize;

  /// Whether dragging near the horizontal edge triggers cross-day navigation.
  ///
  /// When true, dragging an event near the left/right edge will navigate
  /// to the previous/next day after a delay.
  ///
  /// Defaults to true.
  final bool dragEdgeNavigationEnabled;

  /// The delay before initiating a long-press drag.
  ///
  /// Defaults to 200 milliseconds.
  final Duration dragLongPressDelay;

  /// The delay before edge navigation is triggered during drag.
  ///
  /// Defaults to 1200 milliseconds.
  final Duration dragEdgeNavigationDelay;

  /// Whether to show the drop target preview tile (Layer 3).
  ///
  /// The preview is a phantom event tile rendered at the proposed drop position.
  ///
  /// Defaults to true.
  final bool showDropTargetTiles;

  /// Whether to show the drop target overlay (Layer 4).
  ///
  /// The overlay highlights the time slot range being targeted.
  ///
  /// Defaults to true.
  final bool showDropTargetOverlay;

  /// Whether to render drop target tiles above the overlay.
  ///
  /// Controls the z-order of Layer 3 (preview) and Layer 4 (overlay).
  /// false = overlay above tiles, true = tiles above overlay.
  ///
  /// Defaults to false (matches Month View).
  final bool dropTargetTilesAboveOverlay;

  // ============================================================================
  // Snapping
  // ============================================================================

  /// Whether to snap events to time slot boundaries during drag/resize.
  ///
  /// When true, events snap to multiples of [timeSlotDuration].
  ///
  /// Defaults to true.
  final bool snapToTimeSlots;

  /// Whether to magnetically snap to nearby event boundaries during drag/resize.
  ///
  /// When true, events will snap to the start/end times of other events
  /// when within [snapRange].
  ///
  /// Defaults to true.
  final bool snapToOtherEvents;

  /// Whether to magnetically snap to the current time indicator during drag/resize.
  ///
  /// When true, events will snap to the current time when within [snapRange].
  ///
  /// Defaults to true.
  final bool snapToCurrentTime;

  /// The time range within which magnetic snapping occurs.
  ///
  /// When dragging/resizing, if an event is within this range of a snap target
  /// (other event boundary, current time), it will snap to that target.
  ///
  /// Defaults to 5 minutes.
  final Duration snapRange;

  // ============================================================================
  // Special Time Regions
  // ============================================================================

  /// A list of special time regions to display.
  ///
  /// Time regions can represent blocked time, lunch breaks, non-working hours, etc.
  /// They are rendered as colored overlays in the time grid.
  ///
  /// Supports recurring regions via RRULE.
  ///
  /// Example:
  /// ```dart
  /// specialTimeRegions: [
  ///   MCalTimeRegion(
  ///     id: 'lunch',
  ///     startTime: DateTime(2026, 2, 14, 12, 0),
  ///     endTime: DateTime(2026, 2, 14, 13, 0),
  ///     color: Colors.grey.shade300,
  ///     text: 'Lunch Break',
  ///   ),
  /// ]
  /// ```
  final List<MCalTimeRegion> specialTimeRegions;

  // ============================================================================
  // Keyboard Navigation
  // ============================================================================

  /// Whether keyboard navigation is enabled.
  ///
  /// When true, arrow keys navigate between events, Tab cycles focus,
  /// Enter/Space activates events, and keyboard move/resize modes are available.
  ///
  /// Defaults to true.
  final bool enableKeyboardNavigation;

  /// Whether to automatically focus an event when tapped.
  ///
  /// When true, tapping an event gives it keyboard focus for subsequent
  /// keyboard operations.
  ///
  /// Defaults to true.
  final bool autoFocusOnEventTap;

  /// Custom keyboard shortcuts to add or override.
  ///
  /// When non-null, the map is merged with default shortcuts. User entries override
  /// defaults for the same [ShortcutActivator]. Use [Intent] subclasses for
  /// [MCalDayViewCreateEventIntent], [MCalDayViewDeleteEventIntent], and
  /// [MCalDayViewEditEventIntent].
  ///
  /// Example: Override Cmd+N to use a different shortcut:
  /// ```dart
  /// keyboardShortcuts: {
  ///   SingleActivator(LogicalKeyboardKey.keyN, meta: true): MCalDayViewCreateEventIntent(),
  /// }
  /// ```
  final Map<ShortcutActivator, Intent>? keyboardShortcuts;

  // ============================================================================
  // Animations
  // ============================================================================

  /// Whether to enable animations.
  ///
  /// If null, respects the system's reduced motion setting.
  /// If true, animations are always enabled.
  /// If false, animations are always disabled.
  final bool? enableAnimations;

  /// The duration of animations.
  ///
  /// Defaults to 300 milliseconds.
  final Duration animationDuration;

  /// The curve for animations.
  ///
  /// Defaults to [Curves.easeInOut].
  final Curve animationCurve;

  // ============================================================================
  // Boundaries
  // ============================================================================

  /// The minimum date that can be navigated to.
  ///
  /// If null, no minimum boundary is enforced.
  final DateTime? minDate;

  /// The maximum date that can be navigated to.
  ///
  /// If null, no maximum boundary is enforced.
  final DateTime? maxDate;

  // ============================================================================
  // Swipe Navigation
  // ============================================================================

  /// Whether to enable swipe navigation between days.
  ///
  /// When true, the day view content is wrapped in a [PageView.builder]
  /// allowing users to swipe left/right to navigate between days.
  ///
  /// The day view always uses horizontal swiping for day navigation because
  /// the view already scrolls vertically through the hours of the day.
  ///
  /// When false (default), the view displays a single day and swipe gestures
  /// do not change the displayed date.
  ///
  /// Defaults to false.
  final bool enableSwipeNavigation;

  /// Called when the user navigates to a different day via swipe gesture.
  ///
  /// Receives [BuildContext] and [MCalSwipeNavigationDetails] containing the
  /// previous and new display dates, and the swipe direction.
  ///
  /// Note: [onDisplayDateChanged] also fires when swipe navigation occurs.
  /// Use [onSwipeNavigation] when you need to distinguish swipe navigation
  /// from other navigation methods (keyboard, buttons, programmatic).
  ///
  /// Only fires when [enableSwipeNavigation] is true.
  final void Function(BuildContext context, MCalSwipeNavigationDetails details)?
  onSwipeNavigation;

  // ============================================================================
  // Builder Callbacks
  // ============================================================================

  /// Builder for the day header (day of week + date number).
  ///
  /// If null, uses default header rendering.
  ///
  /// Receives [MCalDayHeaderContext] with date information.
  final Widget Function(
    BuildContext context,
    MCalDayHeaderContext headerContext,
    Widget defaultWidget,
  )?
  dayHeaderBuilder;

  /// Builder for time labels in the time legend.
  ///
  /// If null, uses default time label rendering.
  ///
  /// Receives [MCalTimeLabelContext] with hour/minute and formatted time string.
  final Widget Function(
    BuildContext context,
    MCalTimeLabelContext labelContext,
    Widget defaultWidget,
  )?
  timeLabelBuilder;

  /// Builder for gridlines in the time grid.
  ///
  /// If null, uses default gridline rendering.
  ///
  /// Receives [MCalGridlineContext] with gridline type (hour/major/minor) and position.
  final Widget Function(
    BuildContext context,
    MCalGridlineContext gridlineContext,
    Widget defaultWidget,
  )?
  gridlineBuilder;

  /// Builder for all-day event tiles.
  ///
  /// If null, uses default all-day event tile rendering.
  ///
  /// Receives [MCalAllDayEventTileContext] with event and display date.
  final Widget Function(
    BuildContext context,
    MCalCalendarEvent event,
    MCalAllDayEventTileContext tileContext,
    Widget defaultWidget,
  )?
  allDayEventTileBuilder;

  /// Builder for timed event tiles.
  ///
  /// If null, uses default timed event tile rendering.
  ///
  /// Receives [MCalTimedEventTileContext] with event, position, and column layout info.
  final Widget Function(
    BuildContext context,
    MCalCalendarEvent event,
    MCalTimedEventTileContext tileContext,
    Widget defaultWidget,
  )?
  timedEventTileBuilder;

  /// Builder for the current time indicator.
  ///
  /// If null, uses default indicator rendering (horizontal line with dot).
  ///
  /// Receives [MCalCurrentTimeContext] with current time and vertical position.
  final Widget Function(
    BuildContext context,
    MCalCurrentTimeContext timeContext,
    Widget defaultWidget,
  )?
  currentTimeIndicatorBuilder;

  /// Builder for the navigation bar.
  ///
  /// If null, uses default navigator rendering (prev/today/next buttons).
  ///
  /// Receives the current display date.
  final Widget Function(
    BuildContext context,
    DateTime displayDate,
    Widget defaultWidget,
  )?
  navigatorBuilder;

  /// Builder for custom day layout (advanced).
  ///
  /// Allows complete control over timed event layout.
  /// If null, uses default column-based overlap layout.
  ///
  /// Receives [MCalDayLayoutContext] with all events and layout parameters.
  final Widget Function(
    BuildContext context,
    MCalDayLayoutContext layoutContext,
    Widget defaultWidget,
  )?
  dayLayoutBuilder;

  /// Builder for the dragged event tile (feedback during drag).
  ///
  /// This tile follows the cursor during drag.
  /// If null, uses a semi-transparent copy of the original tile.
  ///
  /// Receives the event being dragged and [MCalDraggedTileDetails].
  final Widget Function(
    BuildContext context,
    MCalCalendarEvent event,
    MCalDraggedTileDetails details,
    Widget defaultWidget,
  )?
  draggedTileBuilder;

  /// Builder for the source tile appearance during drag.
  ///
  /// This customizes how the original tile looks while being dragged.
  /// If null, uses default styling (semi-transparent or hidden).
  ///
  /// Receives the event being dragged and [MCalDragSourceDetails].
  final Widget Function(
    BuildContext context,
    MCalCalendarEvent event,
    MCalDragSourceDetails details,
    Widget defaultWidget,
  )?
  dragSourceTileBuilder;

  /// Builder for the drop target preview tile (Layer 3).
  ///
  /// This phantom tile shows where the event will be dropped.
  /// If null, uses a semi-transparent copy with visual indicators.
  ///
  /// Receives the event being dragged and [MCalTimedEventTileContext] at proposed position.
  final Widget Function(
    BuildContext context,
    MCalCalendarEvent event,
    MCalTimedEventTileContext tileContext,
    Widget defaultWidget,
  )?
  dropTargetTileBuilder;

  /// Builder for the drop target overlay (Layer 4).
  ///
  /// This highlights the time slot range being targeted.
  /// If null, uses default colored overlay (blue if valid, red if invalid).
  ///
  /// Receives [MCalDayViewDropOverlayDetails] with highlighted range and validity.
  final Widget Function(
    BuildContext context,
    MCalDayViewDropOverlayDetails details,
    Widget defaultWidget,
  )?
  dropTargetOverlayBuilder;

  /// Builder for resize handles on timed events.
  ///
  /// If null, uses default resize handles (horizontal grips at top/bottom edges).
  ///
  /// Receives the event and resize edge (start/end).
  final Widget Function(
    BuildContext context,
    MCalCalendarEvent event,
    MCalResizeEdge edge,
    Widget defaultWidget,
  )?
  timeResizeHandleBuilder;

  /// Optional callback returning horizontal inset for a resize handle.
  ///
  /// This callback receives the full [MCalTimedEventTileContext] and the
  /// [MCalResizeEdge] indicating which edge is being positioned (start or end).
  ///
  /// Returns the horizontal offset in logical pixels to shift the resize handle
  /// inward from the edge of the event tile. A value of `0.0` (or `null` callback)
  /// positions the handle at the tile edge.
  ///
  /// Use this to ensure resize handles don't overlap with event content or to
  /// create visual spacing between handles and tile borders.
  ///
  /// Only used when [enableDragToResize] is true and events have resize handles.
  ///
  /// Example: Add 4px inset to all resize handles
  /// ```dart
  /// resizeHandleInset: (tileContext, edge) => 4.0
  /// ```
  ///
  /// Example: Different insets based on edge
  /// ```dart
  /// resizeHandleInset: (tileContext, edge) {
  ///   return edge == MCalResizeEdge.start ? 6.0 : 4.0;
  /// }
  /// ```
  final double Function(MCalTimedEventTileContext, MCalResizeEdge)?
  resizeHandleInset;

  /// Builder for loading state.
  ///
  /// Displayed while events are being loaded from the controller.
  /// If null, shows a centered [CircularProgressIndicator].
  ///
  /// The builder receives the default loading widget as the last parameter,
  /// allowing you to wrap or replace it.
  final Widget Function(BuildContext context, Widget defaultWidget)?
  loadingBuilder;

  /// Builder for error state.
  ///
  /// Displayed when event loading fails.
  /// If null, shows a centered error message.
  ///
  /// Receives the error object and the default error widget as the last parameter,
  /// allowing you to wrap or replace it.
  final Widget Function(
    BuildContext context,
    Object error,
    Widget defaultWidget,
  )?
  errorBuilder;

  /// Builder for special time regions.
  ///
  /// If null, uses default region rendering (colored overlay with optional text).
  ///
  /// Receives [MCalTimeRegionContext] with region data and position.
  final Widget Function(
    BuildContext context,
    MCalTimeRegionContext regionContext,
    Widget defaultWidget,
  )?
  timeRegionBuilder;

  /// Callback to determine whether a specific time slot is interactive.
  ///
  /// Return `true` to allow interaction (taps, long-press, double-tap) with the time slot,
  /// or `false` to disable interaction. When disabled, the slot is rendered with reduced
  /// opacity (0.5) to provide visual feedback.
  ///
  /// This callback receives [MCalTimeSlotInteractivityDetails] containing:
  /// - [date]: The date of the time slot
  /// - [hour]: The hour component (0-23)
  /// - [minute]: The minute component (0-59)
  /// - [startTime]: Full start time of the slot
  /// - [endTime]: Full end time of the slot (based on [timeSlotDuration])
  ///
  /// **Note:** This callback does NOT block drag-and-drop operations. Use
  /// [onDragWillAccept] to control whether events can be dropped on specific time slots.
  /// This matches the documented behavior of Month View's [cellInteractivityCallback].
  ///
  /// Example usage:
  /// ```dart
  /// timeSlotInteractivityCallback: (context, details) {
  ///   // Disable past time slots
  ///   if (details.startTime.isBefore(DateTime.now())) {
  ///     return false;
  ///   }
  ///   // Only allow slots during working hours (9 AM - 5 PM)
  ///   if (details.hour < 9 || details.hour >= 17) {
  ///     return false;
  ///   }
  ///   return true;
  /// }
  /// ```
  final bool Function(BuildContext, MCalTimeSlotInteractivityDetails)?
  timeSlotInteractivityCallback;

  // ============================================================================
  // Interaction Callbacks
  // ============================================================================

  /// Called when the day header is tapped.
  ///
  /// Receives [BuildContext] and the display date.
  final void Function(BuildContext context, DateTime date)? onDayHeaderTap;

  /// Called when the day header is long-pressed.
  ///
  /// Receives [BuildContext] and the display date.
  final void Function(BuildContext context, DateTime date)?
  onDayHeaderLongPress;

  /// Called when the day header is double-tapped.
  ///
  /// Receives [BuildContext] and [MCalDayHeaderContext] with the display date.
  final void Function(BuildContext context, MCalDayHeaderContext headerContext)?
  onDayHeaderDoubleTap;

  /// Called when a time label in the time legend is tapped.
  ///
  /// Receives [BuildContext] and [MCalTimeLabelContext].
  final void Function(BuildContext context, MCalTimeLabelContext labelContext)?
  onTimeLabelTap;

  /// Called when a time label in the time legend is long-pressed.
  ///
  /// Receives [BuildContext] and [MCalTimeLabelContext].
  final void Function(BuildContext context, MCalTimeLabelContext labelContext)?
  onTimeLabelLongPress;

  /// Called when a time label in the time legend is double-tapped.
  ///
  /// Receives [BuildContext] and [MCalTimeLabelContext].
  final void Function(BuildContext context, MCalTimeLabelContext labelContext)?
  onTimeLabelDoubleTap;

  /// Called when an empty time slot is tapped.
  ///
  /// Receives [BuildContext] and [MCalTimeSlotContext] with the date and time of the tapped slot.
  ///
  /// Useful for creating new events at the tapped time.
  final void Function(BuildContext context, MCalTimeSlotContext slotContext)?
  onTimeSlotTap;

  /// Called when an empty time slot is long-pressed.
  ///
  /// Receives [BuildContext] and [MCalTimeSlotContext] with the date and time of the pressed slot.
  ///
  /// Useful for creating new events at the pressed time.
  final void Function(BuildContext context, MCalTimeSlotContext slotContext)?
  onTimeSlotLongPress;

  /// Called when empty time slot space is double-tapped.
  ///
  /// Receives [BuildContext] and [MCalTimeSlotContext] at the double-tap position (snapped to time slot).
  /// Typical use case: Show create event dialog at the tapped time.
  ///
  /// Double-tap does not conflict with single tap; Flutter's gesture arena
  /// ensures only one gesture wins.
  final void Function(BuildContext context, MCalTimeSlotContext slotContext)?
  onTimeSlotDoubleTap;

  /// Called when an event tile is tapped.
  ///
  /// Receives [BuildContext] and [MCalEventTapDetails] with the event and display date.
  final void Function(BuildContext context, MCalEventTapDetails details)?
  onEventTap;

  /// Called when an event tile is long-pressed.
  ///
  /// Receives [BuildContext] and [MCalEventTapDetails] with the event and display date.
  final void Function(BuildContext context, MCalEventTapDetails details)?
  onEventLongPress;

  /// Called when an event tile is double-tapped.
  ///
  /// Receives [BuildContext] and [MCalEventTapDetails] with the event and display date.
  final void Function(BuildContext context, MCalEventTapDetails details)?
  onEventDoubleTap;

  /// Called when the pointer hovers over an event.
  ///
  /// Only fires on platforms with hover support (desktop/web).
  ///
  /// Receives [BuildContext] and the event being hovered, or null when exiting.
  final void Function(BuildContext, MCalCalendarEvent?)? onHoverEvent;

  /// Called when the pointer hovers over an empty time slot.
  ///
  /// Only fires on platforms with hover support (desktop/web).
  ///
  /// Receives [BuildContext] and [MCalTimeSlotContext], or null when exiting.
  final void Function(BuildContext, MCalTimeSlotContext?)? onHoverTimeSlot;

  /// Called when the pointer hovers over the day header.
  ///
  /// Only fires on platforms with hover support (desktop/web).
  ///
  /// Receives [BuildContext] and [MCalDayHeaderContext], or null when exiting.
  final void Function(BuildContext, MCalDayHeaderContext?)? onHoverDayHeader;

  /// Called when the pointer hovers over a time label.
  ///
  /// Only fires on platforms with hover support (desktop/web).
  ///
  /// Receives [BuildContext] and [MCalTimeLabelContext], or null when exiting.
  final void Function(BuildContext, MCalTimeLabelContext?)? onHoverTimeLabel;

  /// Called when the pointer hovers over the overflow indicator.
  ///
  /// Only fires on platforms with hover support (desktop/web).
  ///
  /// Receives [BuildContext] and [MCalOverflowTapDetails], or null when exiting.
  final void Function(BuildContext, MCalOverflowTapDetails?)? onHoverOverflow;

  /// Called when the all-day section overflow indicator is tapped.
  ///
  /// The overflow indicator appears when there are more all-day events than [allDaySectionMaxRows].
  ///
  /// Receives [BuildContext], the list of overflowing events, and the display date.
  final void Function(
    BuildContext context,
    List<MCalCalendarEvent> events,
    DateTime date,
  )?
  onOverflowTap;

  /// Called when the all-day section overflow indicator is long-pressed.
  ///
  /// Receives [BuildContext], the list of overflowing events, and the display date.
  final void Function(
    BuildContext context,
    List<MCalCalendarEvent> events,
    DateTime date,
  )?
  onOverflowLongPress;

  /// Called when the all-day section overflow indicator is double-tapped.
  ///
  /// Receives [BuildContext] and [MCalOverflowTapDetails] with overflow event data.
  final void Function(BuildContext context, MCalOverflowTapDetails details)?
  onOverflowDoubleTap;

  /// Called when the user requests to create a new event via keyboard shortcut (Cmd/Ctrl+N).
  ///
  /// Use the controller's [MCalEventController.displayDate] to determine the date
  /// for the new event.
  final VoidCallback? onCreateEventRequested;

  /// Called when the user requests to delete the focused event via keyboard shortcut
  /// (Cmd/Ctrl+D or Delete/Backspace).
  ///
  /// Receives the focused event. Only fires when an event has keyboard focus.
  final void Function(MCalCalendarEvent event)? onDeleteEventRequested;

  /// Called when the user requests to edit the focused event via keyboard shortcut
  /// (Cmd/Ctrl+E).
  ///
  /// Receives the focused event. Only fires when an event has keyboard focus.
  final void Function(MCalCalendarEvent event)? onEditEventRequested;

  // ============================================================================
  // Drag and Drop Callbacks
  // ============================================================================

  /// Called to validate whether a drop should be accepted.
  ///
  /// Return true to accept the drop, false to reject it.
  /// If this callback is not provided, all drops are accepted by default.
  ///
  /// Receives [MCalEventDroppedDetails] with proposed new dates.
  ///
  /// Example: Prevent dropping on weekends
  /// ```dart
  /// onDragWillAccept: (details) {
  ///   return details.newStartDate.weekday != DateTime.saturday &&
  ///          details.newStartDate.weekday != DateTime.sunday;
  /// }
  /// ```
  final bool Function(MCalEventDroppedDetails details)? onDragWillAccept;

  /// Called when an event is successfully dropped.
  ///
  /// Receives [BuildContext] and [MCalEventDroppedDetails] with old and new dates.
  /// The [typeConversion] field indicates if the event was converted between all-day and timed.
  ///
  /// Return `true` to accept the change, `false` to revert it.
  /// If this callback is not provided, the change is accepted by default.
  ///
  /// You are responsible for updating the event in your data source.
  /// The controller will automatically update if you call its modification methods.
  final bool Function(BuildContext, MCalEventDroppedDetails)? onEventDropped;

  /// Called to validate whether a resize should be accepted.
  ///
  /// Return true to accept the resize, false to reject it.
  /// If this callback is not provided, all resizes are accepted by default.
  ///
  /// Receives [MCalEventResizedDetails] with [oldStartDate], [oldEndDate],
  /// [newStartDate], [newEndDate], and [resizeEdge]. The proposed range is
  /// in [newStartDate] and [newEndDate].
  ///
  /// Example: Enforce minimum 30-minute duration
  /// ```dart
  /// onResizeWillAccept: (details) {
  ///   final duration = details.newEndDate.difference(details.newStartDate);
  ///   return duration >= Duration(minutes: 30);
  /// }
  /// ```
  final bool Function(MCalEventResizedDetails details)? onResizeWillAccept;

  /// Called when an event is successfully resized.
  ///
  /// Receives [BuildContext] and [MCalEventResizedDetails] with old and new times/durations.
  ///
  /// Return `true` to accept the change, `false` to revert it.
  /// If this callback is not provided, the change is accepted by default.
  ///
  /// You are responsible for updating the event in your data source.
  final bool Function(BuildContext, MCalEventResizedDetails)? onEventResized;

  // ============================================================================
  // State Change Callbacks
  // ============================================================================

  /// Called when the display date changes.
  ///
  /// This fires when navigating to a different day (via buttons, drag navigation, or controller).
  ///
  /// Receives the new display date.
  final void Function(DateTime newDate)? onDisplayDateChanged;

  /// Called when the scroll position changes.
  ///
  /// Receives the current scroll offset.
  final void Function(double offset)? onScrollChanged;

  // ============================================================================
  // Accessibility
  // ============================================================================

  /// The semantic label for the entire Day View.
  ///
  /// If null, a default label is generated based on the display date.
  ///
  /// Example: "Day view for Monday, February 14, 2026"
  final String? semanticsLabel;

  // ============================================================================
  // Theming
  // ============================================================================

  /// Optional theme data to customize the appearance.
  ///
  /// If null, uses [MCalTheme.of(context)] or default theme.
  final MCalThemeData? theme;

  @override
  State<MCalDayView> createState() => MCalDayViewState();
}

/// The [State] for [MCalDayView], exposed for programmatic control.
///
/// [MCalDayViewState] provides programmatic access to scroll behavior and
/// other operations. Use a [GlobalKey] to obtain a reference to the state.
///
/// ## Public API
///
/// - [scrollToTime] — Programmatically scroll the time grid to a
///   specific time of day.
///
/// ## Display Date
///
/// The displayed date is controlled by [MCalEventController.displayDate].
/// Use [MCalEventController.setDisplayDate] or [MCalEventController.navigateToDateWithoutAnimation]
/// to change the displayed day. The state syncs automatically with the controller.
///
/// ## Example
///
/// ```dart
/// final _dayViewKey = GlobalKey<MCalDayViewState>();
///
/// MCalDayView(
///   key: _dayViewKey,
///   controller: controller,
///   // ...
/// )
///
/// // Later, scroll to 9:00 AM:
/// _dayViewKey.currentState?.scrollToTime(const TimeOfDay(hour: 9, minute: 0));
/// ```
///
/// See also:
/// - [MCalDayView] — The parent widget
/// - [MCalEventController] — Manages events and display date
class MCalDayViewState extends State<MCalDayView> {
  // ============================================================================
  // Controller Integration
  // ============================================================================

  late DateTime _displayDate;

  // dateOnly() and isToday() are in date_utils.dart

  List<MCalCalendarEvent> _allEvents = [];
  List<MCalCalendarEvent> _allDayEvents = [];
  List<MCalCalendarEvent> _timedEvents = [];
  bool _isLoading = false;
  Object? _error;

  // ============================================================================
  // Drag State (matches Month View pattern)
  // ============================================================================

  MCalDragHandler? _dragHandler;
  bool _isDragActive = false;

  /// Sets [_isDragActive] and logs every transition with the caller name.
  /// Helps diagnose spurious true→false→true cycles after a drop.
  void _setDragActive(bool value, String caller) {
    if (_isDragActive == value) return;
    debugPrint(
      '[DD] isDragActive: $_isDragActive → $value  caller=$caller  ts=${DateTime.now().toIso8601String()}',
    );
    _isDragActive = value;
  }

  bool _isResizeActive = false;
  bool _isProcessingDrop = false;
  bool _isDragTargetActive = false;

  // Drag debouncing (matches Month View lines 3915-3922)
  DragTargetDetails<MCalDragData>? _latestDragDetails;
  Timer? _dragMoveDebounceTimer;

  // Resize state: offset of the edge being dragged (from top of time grid)
  double _resizeEdgeOffset = 0.0;

  /// Pointer ID for active resize gesture (survives scroll/navigation).
  int? _resizeActivePointer;

  /// Whether the drag threshold has been crossed and resize has started.
  bool _resizeGestureStarted = false;

  /// Accumulated vertical movement during the threshold phase.
  double _resizeDyAccumulated = 0.0;

  /// Event and edge for pending/active resize (set on pointer down).
  MCalCalendarEvent? _pendingResizeEvent;
  MCalResizeEdge? _pendingResizeEdge;

  /// Scroll hold that freezes [SingleChildScrollView] during resize.
  ScrollHoldController? _resizeScrollHold;

  /// Last pointer position during an active resize, used to re-check edge
  /// proximity after day navigation while the pointer is stationary.
  Offset? _lastResizePointerGlobal;

  static const double _resizeDragThreshold = 8.0;

  // ============================================================================
  // Scroll State
  // ============================================================================

  ScrollController? _scrollController;
  bool _autoScrollDone = false;

  /// Last known vertical scroll offset — kept in sync via a listener so that
  /// adjacent pages in the PageView can start at the same position.
  double _lastKnownScrollOffset = 0.0;

  // Vertical auto-scroll during drag/resize: when the user drags near the
  // top or bottom of the visible time grid, scroll the content automatically
  // so they can drop onto time slots outside the current viewport.
  Timer? _verticalScrollTimer;
  double _verticalScrollDelta = 0.0; // px per 16ms frame, negative = up
  bool _verticalScrollReprocessDrag =
      false; // re-run _processDragMove each tick

  // Grace period: suppress vertical auto-scroll for a short window after drag
  // start so that pressing an event near the viewport top/bottom doesn't
  // immediately trigger scrolling before the user has moved their finger.
  DateTime? _dragStartTime;
  static const _vertEdgeGracePeriod = Duration(milliseconds: 400);

  // Navigation cooldown: suppress horizontal edge detection for a short window
  // (Edge navigation cooldown removed — the drag handler's own _isNearEdge
  // reset-after-navigate mechanism prevents double-navigation, matching the
  // Month View pattern.)

  // Fraction of the time grid width that defines each edge navigation zone.
  // The left and right 25% of the time grid are trigger zones; the center 50%
  // is a safe zone.  Detection is based on the tile's horizontal center.
  static const _edgeZoneFraction = 0.25;

  // The tile's top/bottom edge must be within this many pixels of the
  // scroll viewport's top/bottom boundary to trigger vertical auto-scroll.
  static const _vertEdgeThresholdPx = 40.0;

  // Feedback tile dimensions and grab offsets — cached from MCalDragData.
  double _feedbackTileWidth = 0.0;
  double _feedbackTileHeight = 0.0;
  double _cachedGrabOffsetX = 0.0;
  double _cachedGrabOffsetY = 0.0;

  // TEMPORARY DEBUG: tile center in global coordinates, updated from both
  // DragTarget.onMove and raw pointer fallback so the debug overlay tracks
  // the tile center even after DragLeave.
  Offset? _debugTileCenterGlobal;

  // Last cursor position from the fallback pointer handler. Used by
  // _schedulePostNavLayoutRefresh to re-check edge proximity after navigation
  // when the DragTarget is no longer active (onLeave has fired).
  Offset? _lastFallbackCursorGlobal;

  // Feedback widget top-left in global coordinates, computed by the fallback
  // pointer handler from the cursor position minus grab offsets. Used by
  // _processDragMove when _isDragTargetActive is false so the drop preview
  // and debug overlay continue to track the dragged tile even after DragLeave.
  Offset? _fallbackFeedbackGlobal;

  // ============================================================================
  // Layout Cache
  // ============================================================================

  // Measured once when the time grid lays out (via LayoutBuilder) and
  // used throughout as a fallback when widget.hourHeight is not explicitly set.
  // A value of 0.0 means not yet measured; callers fall back to widget.hourHeight
  // or the default of 80.0 px/hour.
  double _cachedHourHeight = 0.0;

  // Drag layout cache — captured once per drag session (or refreshed after
  // page navigation) to avoid repeated RenderBox lookups every frame.
  // Mirrors the caching strategy in Month View's _updateLayoutCache.
  bool _layoutCachedForDrag = false;
  Offset _cachedDayContentOffset = Offset.zero;
  Size _cachedDayContentSize = Size.zero;
  double _cachedTimeGridTopInDayContent = 0.0;
  double _cachedScrollOffset = 0.0;

  // Time grid boundaries in global coordinates for tile-edge-based
  // edge detection. Left/right define where horizontal edge navigation
  // triggers; top is also used for the all-day area ↔ time grid boundary.
  double _cachedTimeGridGlobalLeft = 0.0;
  double _cachedTimeGridGlobalRight = 0.0;
  double _cachedTimeGridGlobalTop = 0.0;
  double _cachedMinuteHeight = 0.0; // px per minute

  // ============================================================================
  // Keyboard State
  // ============================================================================

  late FocusNode _focusNode;
  MCalCalendarEvent? _focusedEvent;

  // Keyboard move mode (Task 32)
  bool _isKeyboardMoveMode = false;
  MCalCalendarEvent? _keyboardMoveEvent;
  DateTime? _keyboardMoveOriginalStart;
  DateTime? _keyboardMoveOriginalEnd;
  DateTime? _keyboardMoveProposedStart;
  DateTime? _keyboardMoveProposedEnd;

  // Keyboard resize mode (Task 33)
  bool _isKeyboardResizeMode = false;
  MCalResizeEdge? _keyboardResizeEdge;

  // ============================================================================
  // Current Time
  // ============================================================================

  Timer? _currentTimeTimer;

  // ============================================================================
  // Swipe Navigation (Task 8)
  // ============================================================================

  /// PageController for swipe navigation between days.
  /// Initialized with a large initial page (10000) to allow infinite scrolling
  /// in both directions.
  PageController? _swipePageController;

  /// Flag to prevent recursive updates when programmatically changing pages.
  bool _isProgrammaticPageChange = false;

  /// True while _onSwipePageChanged is calling controller.setDisplayDate().
  /// Prevents _onControllerChanged from issuing a redundant jumpToPage that
  /// would interrupt the ongoing user swipe gesture.
  bool _isSwipeInitiatedChange = false;

  /// The initial page index for the PageView (center of the "infinite" scroll range).
  static const int _initialSwipePageIndex = 10000;

  /// The reference date for page index calculations.
  /// Set to the display date when swipe navigation is enabled.
  DateTime? _swipeReferenceDate;

  // ============================================================================
  // Keys for Layout Access
  // ============================================================================

  final GlobalKey _timeGridKey = GlobalKey();
  final GlobalKey _dayContentKey = GlobalKey();

  /// Position from the most recent [GestureDetector.onDoubleTapDown].
  /// Used by [onDoubleTap] since it does not receive position.
  Offset? _lastDoubleTapDownPosition;

  // ============================================================================
  // Lifecycle Methods
  // ============================================================================

  @override
  void initState() {
    super.initState();
    _displayDate = dateOnly(widget.controller.displayDate);
    _scrollController =
        widget.scrollController ?? _ResettableScrollController();
    _scrollController!.addListener(_onScrollPositionChanged);
    _focusNode = FocusNode();

    // Initialize swipe navigation PageController if enabled (Task 8)
    if (widget.enableSwipeNavigation) {
      _swipeReferenceDate = DateTime(
        _displayDate.year,
        _displayDate.month,
        _displayDate.day,
      );
      _swipePageController = PageController(
        initialPage: _initialSwipePageIndex,
      );
    }

    widget.controller.addListener(_onControllerChanged);
    _loadEvents();
    _startCurrentTimeTimer();
  }

  @override
  void dispose() {
    _currentTimeTimer?.cancel();
    _dragMoveDebounceTimer?.cancel();
    _verticalScrollTimer?.cancel();
    _dragHandler?.dispose();
    _focusNode.dispose();
    _scrollController?.removeListener(_onScrollPositionChanged);
    if (widget.scrollController == null) {
      _scrollController?.dispose();
    }
    _swipePageController
        ?.dispose(); // Task 8: Dispose swipe navigation controller
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(MCalDayView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controller listener if controller changed
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
      _displayDate = dateOnly(widget.controller.displayDate);
      _loadEvents();
    }

    // Update scroll controller if changed
    if (widget.scrollController != oldWidget.scrollController) {
      _scrollController?.removeListener(_onScrollPositionChanged);
      if (oldWidget.scrollController == null) {
        _scrollController?.dispose();
      }
      _scrollController =
          widget.scrollController ??
          _ResettableScrollController(
            initialScrollOffset: _lastKnownScrollOffset,
          );
      _scrollController!.addListener(_onScrollPositionChanged);
    }

    // Task 8: Handle swipe navigation parameter changes
    if (widget.enableSwipeNavigation != oldWidget.enableSwipeNavigation) {
      if (widget.enableSwipeNavigation) {
        // Enable swipe navigation - create PageController
        _swipeReferenceDate = DateTime(
          _displayDate.year,
          _displayDate.month,
          _displayDate.day,
        );
        _swipePageController = PageController(
          initialPage: _initialSwipePageIndex,
        );
      } else {
        // Disable swipe navigation - dispose PageController
        _swipePageController?.dispose();
        _swipePageController = null;
        _swipeReferenceDate = null;
      }
    }

    // Reload events if display date changed
    final normalizedNewDate = dateOnly(widget.controller.displayDate);
    if (normalizedNewDate != _displayDate) {
      _displayDate = normalizedNewDate;
      _loadEvents();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Schedule auto-scroll after first frame is built
    _autoScrollToCurrentTime();
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Resolves the theme from widget.theme or context.
  MCalThemeData _resolveTheme(BuildContext context) {
    return widget.theme ?? MCalTheme.of(context);
  }

  /// Resolves the effective text [TextDirection] for the calendar using the
  /// priority chain documented on [MCalDayView.textDirection].
  TextDirection _resolveTextDirection(BuildContext context) {
    if (widget.textDirection != null) return widget.textDirection!;
    final ambient = Directionality.maybeOf(context);
    if (ambient != null) return ambient;
    final locale = widget.locale;
    if (locale != null && MCalDateFormatUtils().isRTL(locale)) {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }

  /// Resolves the effective layout [TextDirection] for the calendar using the
  /// priority chain documented on [MCalDayView.layoutDirection].
  TextDirection _resolveLayoutDirection(BuildContext context) {
    if (widget.layoutDirection != null) return widget.layoutDirection!;
    final ambient = Directionality.maybeOf(context);
    if (ambient != null) return ambient;
    final locale = widget.locale;
    if (locale != null && MCalDateFormatUtils().isRTL(locale)) {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }

  /// Checks if the current layout direction is RTL.
  bool _isLayoutRTL(BuildContext context) {
    return MCalLayoutDirectionality.of(context);
  }

  /// Resolves whether drag-to-resize should be enabled.
  /// If widget.enableDragToResize is null, auto-detects based on platform.
  bool _resolveDragToResize() {
    if (widget.enableDragToResize != null) {
      return widget.enableDragToResize!;
    }
    // Auto-detect: enable on desktop/web, disable on mobile
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.macOS ||
        platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux ||
        platform == TargetPlatform.fuchsia;
  }

  // ============================================================================
  // Swipe Navigation Helper Methods (Task 8)
  // ============================================================================

  /// Converts a PageView page index to the corresponding day DateTime.
  ///
  /// The PageView uses a large initial page index (10000) to allow infinite
  /// scrolling in both directions. This method calculates the offset from
  /// the reference date based on the page index.
  ///
  /// Example:
  /// - pageIndex = 10000 (initial) → reference date (no offset)
  /// - pageIndex = 10001 → reference date + 1 day
  /// - pageIndex = 9999 → reference date - 1 day
  DateTime _pageIndexToDay(int pageIndex) {
    if (_swipeReferenceDate == null) {
      return _displayDate;
    }

    final dayOffset = pageIndex - _initialSwipePageIndex;
    return DateTime(
      _swipeReferenceDate!.year,
      _swipeReferenceDate!.month,
      _swipeReferenceDate!.day + dayOffset,
    );
  }

  /// Called when the user swipes to a different page in the PageView.
  ///
  /// This method:
  /// 1. Computes the new day from the page index
  /// 2. Updates the controller's display date (which triggers onDisplayDateChanged)
  /// 3. Fires the onSwipeNavigation callback with direction details
  void _onSwipePageChanged(int pageIndex) {
    debugPrint(
      '[DD] SwipePageChanged: pageIndex=$pageIndex isProgrammatic=$_isProgrammaticPageChange isDragActive=$_isDragActive isResizing=${_dragHandler?.isResizing}',
    );
    // Skip if this is a programmatic change to avoid recursive updates
    if (_isProgrammaticPageChange) return;

    final newDay = _pageIndexToDay(pageIndex);
    final previousDay = _displayDate;
    debugPrint(
      '[DD] SwipePageChanged: NAVIGATING from $previousDay → $newDay (from=${StackTrace.current.toString().split('\n').skip(1).take(2).join(' | ')})',
    );

    // Skip if same day (shouldn't happen but be safe)
    if (newDay.year == previousDay.year &&
        newDay.month == previousDay.month &&
        newDay.day == previousDay.day) {
      return;
    }

    // Determine swipe direction for callback
    // AxisDirection.left = swiped left (navigating to next day)
    // AxisDirection.right = swiped right (navigating to previous day)
    final axisDirection = newDay.isAfter(previousDay)
        ? AxisDirection.left
        : AxisDirection.right;

    // Update the controller's display date (this triggers _onControllerChanged).
    // The flag tells _onControllerChanged that this change originated from a user
    // swipe, so it should NOT call jumpToPage — the PageView is already animating
    // to the correct page and interrupting it would steal the gesture from the user.
    _isSwipeInitiatedChange = true;
    widget.controller.setDisplayDate(newDay);
    _isSwipeInitiatedChange = false;

    // Fire the swipe navigation callback
    if (widget.onSwipeNavigation != null) {
      widget.onSwipeNavigation!(
        context,
        MCalSwipeNavigationDetails(
          previousMonth: previousDay,
          newMonth: newDay,
          direction: axisDirection,
        ),
      );
    }
  }

  // ============================================================================
  // Private Methods (Placeholder implementations)
  // ============================================================================

  void _onControllerChanged() {
    if (!mounted) return;

    final normalizedControllerDate = dateOnly(widget.controller.displayDate);
    if (normalizedControllerDate != _displayDate) {
      final oldDate = _displayDate;
      debugPrint(
        '[DD] ControllerChanged: date $oldDate → $normalizedControllerDate isDragActive=$_isDragActive isResizing=${_dragHandler?.isResizing}',
      );

      // Snapshot the current scroll offset before the rebuild detaches the
      // controller from the outgoing page.  _lastKnownScrollOffset is already
      // up-to-date via the scroll listener, but a fresh read guarantees we
      // capture any sub-frame changes.
      if (_scrollController?.hasClients == true) {
        _lastKnownScrollOffset = _scrollController!.offset;
      }

      // Tell _ResettableScrollController to use this offset when it is next
      // attached to a new Scrollable (programmatic navigation via jumpToPage).
      // For swipe-initiated changes the adjacent page's _DayPageScroller
      // already starts at the correct offset, so this is a no-op in practice.
      if (_scrollController is _ResettableScrollController) {
        (_scrollController! as _ResettableScrollController).nextInitialOffset =
            _lastKnownScrollOffset;
      }

      setState(() {
        _displayDate = dateOnly(widget.controller.displayDate);
      });

      // For user-provided controllers that we can't subclass, fall back to a
      // post-frame jump so scroll position is still preserved (with a brief
      // flash for that one frame).
      if (_scrollController is! _ResettableScrollController &&
          _lastKnownScrollOffset > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _scrollController == null) return;
          if (!_scrollController!.hasClients) return;
          final maxExtent = _scrollController!.position.maxScrollExtent;
          _scrollController!.jumpTo(
            _lastKnownScrollOffset.clamp(0.0, maxExtent),
          );
        });
      }

      // Task 8: Update PageController when display date changes programmatically
      if (widget.enableSwipeNavigation &&
          _swipePageController != null &&
          _swipeReferenceDate != null) {
        final dayOffset = daysBetween(_swipeReferenceDate!, _displayDate);
        final newPageIndex = _initialSwipePageIndex + dayOffset;

        if (_swipePageController!.hasClients) {
          if (_isSwipeInitiatedChange) {
            // The display date changed because the user swiped. The PageView is
            // already animating to the correct page — don't interrupt the gesture.
            debugPrint(
              '[DD] ControllerChanged: swipe-initiated change — skipping jumpToPage',
            );
          } else {
            // External change (e.g. button press, programmatic navigation).
            // Jump the PageView to match the new date.
            _isProgrammaticPageChange = true;
            debugPrint(
              '[DD] ControllerChanged: jumpToPage($newPageIndex) isProgrammatic=true',
            );
            _swipePageController!.jumpToPage(newPageIndex);
            _isProgrammaticPageChange = false;
            debugPrint('[DD] ControllerChanged: isProgrammatic reset to false');
          }
        }
      }

      widget.onDisplayDateChanged?.call(_displayDate);
    }

    // Always reload events on any controller notification — not just when the
    // display date changes. Without this, same-day moves (addEvents with the
    // same date) update the controller but leave _timedEvents stale, causing
    // the event to visually snap back to its original position after a drop.
    _loadEvents();
  }

  void _loadEvents() {
    // Placeholder: Load events for the display date
    // Will be implemented in later phases
    setState(() {
      _isLoading = false;
      _allEvents = widget.controller.getEventsForDate(_displayDate);
      _allDayEvents = _allEvents.where((e) => e.isAllDay).toList();
      _timedEvents = _allEvents.where((e) => !e.isAllDay).toList();
    });
  }

  /// Returns events for [date], using the cached lists when [date] matches
  /// [_displayDate] to avoid redundant controller queries during build.
  ///
  /// This is needed by [_buildDayContent] so that adjacent pages pre-built by
  /// [PageView] show their own events rather than the current day's events.
  ///
  /// During cross-day resize, also injects a preview version of the resizing
  /// event for days within the proposed range that do not yet have it, so the
  /// user sees the event continuation tile on the destination day while the
  /// handle is still being dragged.
  ({List<MCalCalendarEvent> allDay, List<MCalCalendarEvent> timed})
  _eventsForPageDate(DateTime date) {
    final List<MCalCalendarEvent> allDay;
    List<MCalCalendarEvent> timed;

    if (date.year == _displayDate.year &&
        date.month == _displayDate.month &&
        date.day == _displayDate.day) {
      allDay = _allDayEvents;
      timed = _timedEvents;
    } else {
      final all = widget.controller.getEventsForDate(date);
      allDay = all.where((e) => e.isAllDay).toList();
      timed = all.where((e) => !e.isAllDay).toList();
    }

    // During resize, substitute or inject a proposed-size version of the
    // resizing event so tiles update in real time while the handle is dragged:
    //
    //  • Source day (event already in list): replace with proposed version so
    //    the tile stretches/shrinks visually as the handle moves.
    //  • Destination day (event not yet in list): inject the proposed version
    //    so the continuation tile appears before the drop is committed.
    if (_isResizeActive) {
      final dragHandler = _dragHandler;
      final proposedStart = dragHandler?.proposedStartDate;
      final proposedEnd = dragHandler?.proposedEndDate;
      final resizingEvent = dragHandler?.resizingEvent;

      if (resizingEvent != null &&
          !resizingEvent.isAllDay &&
          proposedStart != null &&
          proposedEnd != null) {
        final day = dateOnly(date);
        final propStartDay = dateOnly(proposedStart);
        final propEndDay = dateOnly(proposedEnd);

        if (!day.isBefore(propStartDay) && !day.isAfter(propEndDay)) {
          final proposedVersion = resizingEvent.copyWith(
            start: proposedStart,
            end: proposedEnd,
          );
          final existingIndex = timed.indexWhere(
            (e) => e.id == resizingEvent.id,
          );
          if (existingIndex >= 0) {
            // Source day: replace the committed tile with the proposed version.
            timed = List.of(timed)..[existingIndex] = proposedVersion;
          } else {
            // Destination day: inject a preview tile.
            timed = [...timed, proposedVersion];
          }
        }
      }
    }

    return (allDay: allDay, timed: timed);
  }

  void _startCurrentTimeTimer() {
    if (!widget.showCurrentTimeIndicator) return;

    _currentTimeTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {});
    });
  }

  /// Programmatically scrolls to the given time.
  ///
  /// Uses [timeToOffset] to calculate the scroll position and
  /// [ScrollController.animateTo] to perform the scroll.
  ///
  /// [time] is combined with [MCalEventController.displayDate] to form
  /// a full [DateTime] for the scroll target.
  ///
  /// Parameters:
  /// - [time]: The time of day to scroll to.
  /// - [duration]: Animation duration. Defaults to 300ms. Use [Duration.zero]
  ///   for instant scroll.
  /// - [curve]: Animation curve. Defaults to [Curves.easeInOut].
  ///
  /// Example:
  /// ```dart
  /// dayViewKey.currentState?.scrollToTime(
  ///   const TimeOfDay(hour: 9, minute: 0),
  ///   duration: Duration(milliseconds: 500),
  /// );
  /// ```
  void scrollToTime(
    TimeOfDay time, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    if (_scrollController == null || !_scrollController!.hasClients) return;

    final scrollController = _scrollController!;
    final hourHeight = widget.hourHeight ?? _cachedHourHeight;
    final effectiveHourHeight = hourHeight > 0 ? hourHeight : 80.0;

    final targetDateTime = DateTime(
      _displayDate.year,
      _displayDate.month,
      _displayDate.day,
      time.hour,
      time.minute,
    );

    final targetOffset = timeToOffset(
      time: targetDateTime,
      startHour: widget.startHour,
      hourHeight: effectiveHourHeight,
    );

    // Center the time in the viewport
    final viewportHeight = scrollController.position.viewportDimension;
    final scrollTarget = targetOffset - (viewportHeight / 2);

    final maxScrollExtent = scrollController.position.maxScrollExtent;
    final minScrollExtent = scrollController.position.minScrollExtent;
    final clampedOffset = scrollTarget.clamp(minScrollExtent, maxScrollExtent);

    if (duration == Duration.zero) {
      scrollController.jumpTo(clampedOffset);
    } else {
      scrollController.animateTo(
        clampedOffset,
        duration: duration,
        curve: curve,
      );
    }
  }

  /// Auto-scrolls to the current time or [initialScrollTime] on first load.
  ///
  /// When [initialScrollTime] is set, scrolls to that time. Otherwise, when
  /// [autoScrollToCurrentTime] is true, scrolls to center the current time
  /// in the viewport. Only executes once (tracked by [_autoScrollDone]).
  ///
  /// The scroll is scheduled after the first frame is built using
  /// [WidgetsBinding.instance.addPostFrameCallback] to ensure layout
  /// is complete before calculating scroll position.
  void _autoScrollToCurrentTime() {
    final targetTime = widget.initialScrollTime;

    if ((targetTime == null && !widget.autoScrollToCurrentTime) ||
        _autoScrollDone) {
      return;
    }

    _autoScrollDone = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _scrollController == null) return;

      final scrollController = _scrollController!;
      if (!scrollController.hasClients) return;

      final timeToScrollTo =
          targetTime ?? TimeOfDay.fromDateTime(DateTime.now());

      scrollToTime(
        timeToScrollTo,
        duration: widget.initialScrollDuration,
        curve: widget.initialScrollCurve,
      );
    });
  }

  /// Keeps [_lastKnownScrollOffset] in sync with the current page's scroll
  /// position.  Called by the listener attached to [_scrollController].
  void _onScrollPositionChanged() {
    final sc = _scrollController;
    if (sc != null && sc.hasClients) {
      _lastKnownScrollOffset = sc.offset;
    }
  }

  // ============================================================================
  // Drag Handling (Placeholder - will be implemented in Tasks 19-20)
  // ============================================================================

  /// Gets or creates the drag handler instance.
  ///
  /// Created lazily to avoid overhead when drag is not enabled.
  /// No blanket setState listener is attached here — the drop target
  /// layers use [ListenableBuilder] to rebuild independently when the
  /// drag handler's proposed range changes, and the drag lifecycle
  /// methods (_handleDragStarted / _handleDragEnded / _handleDragCancelled)
  /// call setState explicitly.  A blanket listener caused
  /// PageView rebuilds on every drag-move frame, which detached/reattached
  /// the SingleChildScrollView's scroll controller and reset its offset.
  MCalDragHandler get _ensureDragHandler {
    _dragHandler ??= MCalDragHandler();
    return _dragHandler!;
  }

  /// Captures layout dimensions for the current drag session.
  ///
  /// Called once at the start of a drag (or after a page navigation invalidates
  /// the cache). Mirrors Month View's `_updateLayoutCache` pattern: perform all
  /// RenderBox lookups in one place and store the results so `_processDragMove`
  /// uses cheap cached arithmetic on every frame.
  void _cacheLayoutForDrag() {
    final dayContentBox =
        _dayContentKey.currentContext?.findRenderObject() as RenderBox?;
    if (dayContentBox == null || !dayContentBox.attached) {
      debugPrint('[DD] CacheLayout: FAILED — dayContentBox null or detached');
      return;
    }

    _cachedDayContentOffset = dayContentBox.localToGlobal(Offset.zero);
    _cachedDayContentSize = dayContentBox.size;

    // Determine where the time grid starts within the day content.
    // Everything above this Y is the day header / all-day area.
    final timeGridBox =
        _timeGridKey.currentContext?.findRenderObject() as RenderBox?;
    if (timeGridBox != null &&
        timeGridBox.attached &&
        timeGridBox.size.width > 0) {
      final timeGridGlobal = timeGridBox.localToGlobal(Offset.zero);
      _cachedTimeGridTopInDayContent =
          timeGridGlobal.dy - _cachedDayContentOffset.dy;
      _cachedTimeGridGlobalLeft = timeGridGlobal.dx;
      _cachedTimeGridGlobalRight = timeGridGlobal.dx + timeGridBox.size.width;
      _cachedTimeGridGlobalTop = timeGridGlobal.dy;
    } else {
      debugPrint(
        '[DD] CacheLayout: WARNING — timeGridBox null/detached/zero-size, skipping cache',
      );
      _layoutCachedForDrag = false;
      return;
    }

    final sc = _scrollController;
    _cachedScrollOffset = (sc != null && sc.hasClients) ? sc.offset : 0.0;

    final hourHeight = widget.hourHeight ?? 80.0;
    _cachedMinuteHeight = hourHeight / 60.0;

    _layoutCachedForDrag = true;
    debugPrint(
      '[DD] CacheLayout: dayContentOffset=$_cachedDayContentOffset dayContentSize=$_cachedDayContentSize timeGridTopInDayContent=$_cachedTimeGridTopInDayContent timeGridGlobal=($_cachedTimeGridGlobalLeft..$_cachedTimeGridGlobalRight top=$_cachedTimeGridGlobalTop) scrollOffset=$_cachedScrollOffset minuteHeight=$_cachedMinuteHeight',
    );
  }

  /// Sends a screen reader announcement for accessibility.
  ///
  /// Uses [SemanticsService.sendAnnouncement] to notify screen reader users
  /// of drag, resize, and other state changes.
  void _announceScreenReader(BuildContext context, String message) {
    if (!mounted) return;
    try {
      final view = View.of(context);
      SemanticsService.sendAnnouncement(
        view,
        message,
        Directionality.of(context),
      );
    } catch (_) {
      // View.of may throw if context is invalid; ignore
    }
  }

  /// Called when a drag operation starts on an event tile.
  ///
  /// Updates drag state tracking and prepares the drag handler.
  /// Caches layout dimensions and invokes user callback if provided.
  void _handleDragStarted(MCalCalendarEvent event, DateTime sourceDate) {
    if (!widget.enableDragToMove) return;

    debugPrint('[DD] ═══════════════════════════════════════════════════');
    debugPrint(
      '[DD] DragStarted: event="${event.title}" source=$sourceDate isAllDay=${event.isAllDay}',
    );
    final sc = _scrollController;
    final scAttached = sc != null && sc.hasClients;
    debugPrint(
      '[DD] DragStarted: scrollOffset=${scAttached ? sc.offset : 'N/A'} scrollMax=${scAttached ? sc.position.maxScrollExtent : 'N/A'} viewportDim=${scAttached ? sc.position.viewportDimension : 'N/A'}',
    );
    _setDragActive(true, '_handleDragStarted');
    _layoutCachedForDrag = false;
    _dragStartTime = DateTime.now();
    _ensureDragHandler.startDrag(event, sourceDate);

    if (mounted) {
      _announceScreenReader(
        context,
        'Moving ${event.title}. Drag to new position.',
      );
    }
    setState(() {});
  }

  /// Called when a drag operation ends.
  ///
  /// Resets every piece of drag state — flags, timers, caches, and debug aids.
  ///
  /// Call this at the end of every drag termination path (ended, cancelled) so
  /// that no stale value from one drag session can bleed into the next.
  void _resetDragState() {
    // Flags
    _setDragActive(false, '_resetDragState');
    _isDragTargetActive = false;
    _isProcessingDrop = false;
    _layoutCachedForDrag = false;

    // Timers — cancel before nulling to avoid firing after reset.
    _dragMoveDebounceTimer?.cancel();
    _dragMoveDebounceTimer = null;
    _cancelVerticalScrollTimer();

    // Live drag data
    _latestDragDetails = null;
    _dragStartTime = null;

    // Feedback tile dimensions and grab offsets
    _feedbackTileWidth = 0.0;
    _feedbackTileHeight = 0.0;
    _cachedGrabOffsetX = 0.0;
    _cachedGrabOffsetY = 0.0;

    // Vertical scroll state
    _verticalScrollDelta = 0.0;
    _verticalScrollReprocessDrag = false;

    // Drag layout cache
    _cachedDayContentOffset = Offset.zero;
    _cachedDayContentSize = Size.zero;
    _cachedTimeGridTopInDayContent = 0.0;
    _cachedScrollOffset = 0.0;
    _cachedTimeGridGlobalLeft = 0.0;
    _cachedTimeGridGlobalRight = 0.0;
    _cachedTimeGridGlobalTop = 0.0;
    _cachedMinuteHeight = 0.0;

    // Debug overlays and fallback position cache
    _debugTileCenterGlobal = null;
    _lastFallbackCursorGlobal = null;
    _fallbackFeedbackGlobal = null;
  }

  /// Cleans up drag state and resets cached layout flag. When the drop was
  /// accepted, _handleDrop already ran and called cancelDrag(); we only need
  /// to clean up when the drop was rejected (released outside valid target).
  void _handleDragEnded(bool wasAccepted) {
    debugPrint(
      '[DD] DragEnded: wasAccepted=$wasAccepted isDragActive=$_isDragActive proposedValid=${_dragHandler?.isProposedDropValid} vertScrollTimerActive=${_verticalScrollTimer?.isActive}',
    );

    // Drag already cleaned up — _handleDrop (accepted) or _handleDragCancelled
    // (which fires before onDragEnd) already called _resetDragState().
    if (!_isDragActive) {
      debugPrint('[DD] DragEnded: drag already inactive — skipping');
      return;
    }

    if (!wasAccepted &&
        _dragHandler != null &&
        _dragHandler!.isProposedDropValid) {
      debugPrint(
        '[DD] DragEnded: NOT accepted but proposedDrop is valid — completing drop via _completePendingDrop',
      );
      // _completePendingDrop handles cancelDrag + _resetDragState + setState.
      _completePendingDrop();
      return;
    } else if (!wasAccepted) {
      debugPrint(
        '[DD] DragEnded: drop was NOT accepted and no valid proposal — calling cancelDrag()',
      );
      _dragHandler?.cancelDrag();
    }

    _resetDragState();
    setState(() {});
  }

  /// Called when a drag operation is cancelled.
  ///
  /// When [isUserCancel] is false (the default), this was triggered by
  /// Flutter's `onDraggableCanceled` — the DragTarget didn't accept the drop
  /// because the pointer was outside its bounds. If there's a valid proposed
  /// drop range, complete the drop instead of discarding it.
  ///
  /// When [isUserCancel] is true, the user explicitly cancelled (e.g. via
  /// Escape key or pointer cancel), so always discard.
  void _handleDragCancelled({bool isUserCancel = false}) {
    debugPrint(
      '[DD] DragCancelled: isUserCancel=$isUserCancel isDragActive=$_isDragActive proposedValid=${_dragHandler?.isProposedDropValid}',
    );

    // Guard: _handleDrop already called _resetDragState() for accepted drops.
    // This mirrors the identical guard in _handleDragEnded.
    if (!_isDragActive) {
      debugPrint('[DD] DragCancelled: drag already inactive — skipping');
      return;
    }

    if (!isUserCancel &&
        _dragHandler != null &&
        _dragHandler!.isProposedDropValid) {
      debugPrint(
        '[DD] DragCancelled: NOT user cancel and proposedDrop is valid — completing drop via _completePendingDrop',
      );
      // _completePendingDrop handles cancelDrag + _resetDragState + setState.
      _completePendingDrop();
      return;
    }

    _ensureDragHandler.cancelDrag();
    _resetDragState();
    setState(() {});
  }

  /// Handles keyboard events for navigation and shortcuts.
  ///
  /// Arrow up/down scroll by time slot; Page Up/Down by viewport; Home/End to
  /// start/end. Tab cycles focus between events. Shortcuts (Cmd+N, etc.) are
  /// handled by [Shortcuts] and [Actions].
  ///
  /// When in keyboard move mode (Ctrl+M): arrow keys move event, Enter confirms,
  /// Escape cancels. When in keyboard resize mode (Ctrl+R): arrow keys adjust
  /// time, Tab switches edge, Enter confirms, Escape cancels.
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!widget.enableKeyboardNavigation) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    // Handle keyboard move mode (Task 32)
    if (_isKeyboardMoveMode) {
      final result = _handleKeyboardMoveKey(event);
      if (result != null) return result;
    }

    // Handle keyboard resize mode (Task 33)
    if (_isKeyboardResizeMode) {
      final result = _handleKeyboardResizeKey(event);
      if (result != null) return result;
    }

    final scrollController = _scrollController;
    if (scrollController == null || !scrollController.hasClients) {
      return KeyEventResult.ignored;
    }

    final hourHeight = _cachedHourHeight > 0
        ? _cachedHourHeight
        : (widget.hourHeight ?? 80.0);
    final slotHeight = (widget.timeSlotDuration.inMinutes / 60.0) * hourHeight;
    final viewportHeight = scrollController.position.viewportDimension;
    final maxExtent = scrollController.position.maxScrollExtent;
    final minExtent = scrollController.position.minScrollExtent;
    final currentOffset = scrollController.offset;

    double? newOffset;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp:
        newOffset = (currentOffset - slotHeight).clamp(minExtent, maxExtent);
        break;
      case LogicalKeyboardKey.arrowDown:
        newOffset = (currentOffset + slotHeight).clamp(minExtent, maxExtent);
        break;
      case LogicalKeyboardKey.pageUp:
        newOffset = (currentOffset - viewportHeight).clamp(
          minExtent,
          maxExtent,
        );
        break;
      case LogicalKeyboardKey.pageDown:
        newOffset = (currentOffset + viewportHeight).clamp(
          minExtent,
          maxExtent,
        );
        break;
      case LogicalKeyboardKey.home:
        newOffset = minExtent;
        break;
      case LogicalKeyboardKey.end:
        newOffset = maxExtent;
        break;
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.arrowRight:
        if (widget.showNavigator) {
          final isLayoutRTL = MCalLayoutDirectionality.of(context);
          if ((event.logicalKey == LogicalKeyboardKey.arrowLeft &&
                  !isLayoutRTL) ||
              (event.logicalKey == LogicalKeyboardKey.arrowRight &&
                  isLayoutRTL)) {
            _handleNavigatePrevious();
          } else {
            _handleNavigateNext();
          }
          return KeyEventResult.handled;
        }
        break;
      case LogicalKeyboardKey.tab:
        _handleTabNavigation(
          HardwareKeyboard.instance.isLogicalKeyPressed(
            LogicalKeyboardKey.shift,
          ),
        );
        return KeyEventResult.handled;
      default:
        break;
    }

    if (newOffset != null && newOffset != currentOffset) {
      scrollController.jumpTo(newOffset);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// Handles key events when in keyboard move mode. Returns handled/ignored
  /// if the key was consumed, or null to fall through to normal handling.
  KeyEventResult? _handleKeyboardMoveKey(KeyEvent event) {
    final ev = _keyboardMoveEvent;
    final proposedStart = _keyboardMoveProposedStart;
    final proposedEnd = _keyboardMoveProposedEnd;
    if (ev == null || proposedStart == null || proposedEnd == null) return null;

    final isLayoutRTL = MCalLayoutDirectionality.of(context);
    final rtlMult = isLayoutRTL ? -1 : 1;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.escape:
        _exitKeyboardMoveMode(cancel: true);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.space:
        _confirmKeyboardMove();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        _keyboardMoveBySlots(-1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown:
        _keyboardMoveBySlots(1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowLeft:
        _keyboardMoveByDays(-1 * rtlMult);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
        _keyboardMoveByDays(1 * rtlMult);
        return KeyEventResult.handled;
      default:
        return null;
    }
  }

  /// Handles key events when in keyboard resize mode.
  KeyEventResult? _handleKeyboardResizeKey(KeyEvent event) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.escape:
        _exitKeyboardResizeMode(cancel: true);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.space:
        _confirmKeyboardResize();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.tab:
        _keyboardResizeSwitchEdge();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        _keyboardResizeBySlots(-1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown:
        _keyboardResizeBySlots(1);
        return KeyEventResult.handled;
      default:
        return null;
    }
  }

  /// Enters keyboard move mode for the focused event (Ctrl+M).
  void _enterKeyboardMoveMode() {
    final event = _focusedEvent;
    if (event == null || !widget.enableDragToMove) return;

    final sourceDate = DateTime(
      event.start.year,
      event.start.month,
      event.start.day,
    );
    _isKeyboardMoveMode = true;
    _keyboardMoveEvent = event;
    _keyboardMoveOriginalStart = event.start;
    _keyboardMoveOriginalEnd = event.end;
    _keyboardMoveProposedStart = event.start;
    _keyboardMoveProposedEnd = event.end;

    _ensureDragHandler.startDrag(event, sourceDate);
    _updateKeyboardMovePreview();

    if (mounted) {
      _announceScreenReader(
        context,
        'Move mode. Use arrow keys to move ${event.title}. Enter to confirm, Escape to cancel.',
      );
    }
    setState(() {});
  }

  /// Updates the drag handler with current keyboard move proposed range.
  void _updateKeyboardMovePreview() {
    final dragHandler = _dragHandler;
    final ev = _keyboardMoveEvent;
    final start = _keyboardMoveProposedStart;
    final end = _keyboardMoveProposedEnd;
    if (dragHandler == null || ev == null || start == null || end == null)
      return;

    final isValid = _validateDropForEvent(ev, start, end);
    dragHandler.updateProposedDropRange(
      proposedStart: start,
      proposedEnd: end,
      isValid: isValid,
      preserveTime: true,
    );
  }

  /// Validates a proposed drop for the given event (used by keyboard move).
  bool _validateDropForEvent(
    MCalCalendarEvent event,
    DateTime proposedStart,
    DateTime proposedEnd,
  ) {
    if (widget.onDragWillAccept != null) {
      final dropDetails = MCalEventDroppedDetails(
        event: event,
        oldStartDate: event.start,
        oldEndDate: event.end,
        newStartDate: proposedStart,
        newEndDate: proposedEnd,
        isRecurring: event.recurrenceRule != null,
        seriesId: event.recurrenceRule != null ? event.id : null,
        typeConversion: null,
      );
      if (!widget.onDragWillAccept!(dropDetails)) return false;
    }
    if (event.isAllDay) return true;
    for (final other in _timedEvents) {
      if (other.id == event.id) continue;
      if (proposedStart.isBefore(other.end) &&
          other.start.isBefore(proposedEnd)) {
        return false;
      }
    }
    for (final region in widget.specialTimeRegions) {
      if (region.blockInteraction &&
          region.overlaps(proposedStart, proposedEnd)) {
        return false;
      }
    }
    if (widget.minDate != null) {
      final minDate = DateTime(
        widget.minDate!.year,
        widget.minDate!.month,
        widget.minDate!.day,
      );
      final proposedDate = DateTime(
        proposedStart.year,
        proposedStart.month,
        proposedStart.day,
      );
      if (proposedDate.isBefore(minDate)) return false;
    }
    if (widget.maxDate != null) {
      final maxDate = DateTime(
        widget.maxDate!.year,
        widget.maxDate!.month,
        widget.maxDate!.day,
      );
      final proposedDate = DateTime(
        proposedStart.year,
        proposedStart.month,
        proposedStart.day,
      );
      if (proposedDate.isAfter(maxDate)) return false;
    }
    return true;
  }

  /// Moves the keyboard-moved event by N time slots (positive = down).
  void _keyboardMoveBySlots(int deltaSlots) {
    final ev = _keyboardMoveEvent;
    var start = _keyboardMoveProposedStart;
    var end = _keyboardMoveProposedEnd;
    if (ev == null || start == null || end == null) return;

    final slotMins = widget.timeSlotDuration.inMinutes;
    final deltaMins = deltaSlots * slotMins;
    start = DateTime(
      start.year,
      start.month,
      start.day,
      start.hour,
      start.minute + deltaMins,
    );
    end = DateTime(
      end.year,
      end.month,
      end.day,
      end.hour,
      end.minute + deltaMins,
    );

    final hourHeight = _cachedHourHeight > 0
        ? _cachedHourHeight
        : (widget.hourHeight ?? 80.0);
    final minOffset = 0.0;
    final maxOffset = (widget.endHour - widget.startHour) * hourHeight;
    final startOffset = timeToOffset(
      time: start,
      startHour: widget.startHour,
      hourHeight: hourHeight,
    );
    final endOffset = timeToOffset(
      time: end,
      startHour: widget.startHour,
      hourHeight: hourHeight,
    );
    if (startOffset < minOffset || endOffset > maxOffset) return;

    _keyboardMoveProposedStart = _applySnapping(start);
    _keyboardMoveProposedEnd = DateTime(
      _keyboardMoveProposedStart!.year,
      _keyboardMoveProposedStart!.month,
      _keyboardMoveProposedStart!.day,
      _keyboardMoveProposedStart!.hour,
      _keyboardMoveProposedStart!.minute +
          _keyboardMoveOriginalEnd!
              .difference(_keyboardMoveOriginalStart!)
              .inMinutes,
    );
    _updateKeyboardMovePreview();
    if (mounted) {
      final locale = widget.locale ?? Localizations.localeOf(context);
      final timeStr = DateFormat.Hm(
        locale.toString(),
      ).format(_keyboardMoveProposedStart!);
      _announceScreenReader(context, 'Moved to $timeStr');
    }
    setState(() {});
  }

  /// Moves the keyboard-moved event by N days.
  void _keyboardMoveByDays(int deltaDays) {
    final ev = _keyboardMoveEvent;
    var start = _keyboardMoveProposedStart;
    var end = _keyboardMoveProposedEnd;
    if (ev == null || start == null || end == null) return;

    start = DateTime(
      start.year,
      start.month,
      start.day + deltaDays,
      start.hour,
      start.minute,
    );
    end = DateTime(
      end.year,
      end.month,
      end.day + deltaDays,
      end.hour,
      end.minute,
    );

    _keyboardMoveProposedStart = start;
    _keyboardMoveProposedEnd = end;
    widget.controller.setDisplayDate(dateOnly(start));

    _updateKeyboardMovePreview();
    if (mounted) {
      final locale = widget.locale ?? Localizations.localeOf(context);
      final dateStr = DateFormat.yMMMMEEEEd(locale.toString()).format(start);
      _announceScreenReader(context, 'Moved to $dateStr');
    }
    setState(() {});
  }

  /// Confirms the keyboard move (Enter) - reuses _handleDrop flow.
  void _confirmKeyboardMove() {
    final ev = _keyboardMoveEvent;
    final proposedStart = _keyboardMoveProposedStart;
    final proposedEnd = _keyboardMoveProposedEnd;
    if (ev == null || proposedStart == null || proposedEnd == null) return;

    final isValid = _validateDropForEvent(ev, proposedStart, proposedEnd);
    if (!isValid) {
      if (mounted) {
        _announceScreenReader(context, 'Invalid drop position');
      }
      return;
    }

    final sourceDate = dateOnly(ev.start);
    final dragData = MCalDragData(
      event: ev,
      sourceDate: sourceDate,
      grabOffsetHolder: MCalGrabOffsetHolder(),
      horizontalSpacing: 0,
      feedbackWidth: 0,
      feedbackHeight: 0,
    );
    final hourHeight = _cachedHourHeight > 0
        ? _cachedHourHeight
        : (widget.hourHeight ?? 80.0);
    final localY = timeToOffset(
      time: proposedStart,
      startHour: widget.startHour,
      hourHeight: hourHeight,
    );
    final timeGridBox = _timeGridKey.currentContext?.findRenderObject();
    final globalOffset = timeGridBox is RenderBox
        ? timeGridBox.localToGlobal(Offset(0, localY))
        : Offset.zero;
    final details = DragTargetDetails<MCalDragData>(
      data: dragData,
      offset: globalOffset,
    );
    _latestDragDetails = details;
    _processDragMove();
    _handleDrop(details);
    _exitKeyboardMoveMode(cancel: false);
  }

  /// Exits keyboard move mode.
  void _exitKeyboardMoveMode({required bool cancel}) {
    _isKeyboardMoveMode = false;
    _keyboardMoveEvent = null;
    _keyboardMoveOriginalStart = null;
    _keyboardMoveOriginalEnd = null;
    _keyboardMoveProposedStart = null;
    _keyboardMoveProposedEnd = null;
    _ensureDragHandler.cancelDrag();
    if (mounted && cancel) {
      _announceScreenReader(context, 'Move cancelled');
    }
    setState(() {});
  }

  /// Enters keyboard resize mode for the focused event (Ctrl+R).
  void _enterKeyboardResizeMode() {
    final event = _focusedEvent;
    if (event == null || !_resolveDragToResize()) return;
    if (event.isAllDay) return;

    _isKeyboardResizeMode = true;
    _keyboardResizeEdge = MCalResizeEdge.end;
    _ensureDragHandler.startResize(event, MCalResizeEdge.end);
    _keyboardResizeEdgeOffset = timeToOffset(
      time: event.end,
      startHour: widget.startHour,
      hourHeight: _cachedHourHeight > 0
          ? _cachedHourHeight
          : (widget.hourHeight ?? 80.0),
    );
    _updateKeyboardResizePreview();

    if (mounted) {
      _announceScreenReader(
        context,
        'Resize mode. Adjusting end time. Arrow Up/Down to change. Tab to switch edge. Enter to confirm, Escape to cancel.',
      );
    }
    setState(() {});
  }

  /// Offset of the edge being resized (for keyboard resize mode).
  double _keyboardResizeEdgeOffset = 0.0;

  /// Updates the drag handler with current keyboard resize proposed range.
  void _updateKeyboardResizePreview() {
    final dragHandler = _dragHandler;
    if (dragHandler == null || !dragHandler.isResizing) return;

    final event = dragHandler.resizingEvent!;
    final edge = _keyboardResizeEdge ?? MCalResizeEdge.end;
    final hourHeight = _cachedHourHeight > 0
        ? _cachedHourHeight
        : (widget.hourHeight ?? 80.0);
    final proposedStart = edge == MCalResizeEdge.start
        ? snapToTimeSlot(
            time: offsetToTime(
              offset: _keyboardResizeEdgeOffset,
              date: _displayDate,
              startHour: widget.startHour,
              hourHeight: hourHeight,
            ),
            timeSlotDuration: widget.timeSlotDuration,
          )
        : event.start;
    final proposedEnd = edge == MCalResizeEdge.end
        ? snapToTimeSlot(
            time: offsetToTime(
              offset: _keyboardResizeEdgeOffset,
              date: _displayDate,
              startHour: widget.startHour,
              hourHeight: hourHeight,
            ),
            timeSlotDuration: widget.timeSlotDuration,
          )
        : event.end;

    final eventMinDuration = widget.timeSlotDuration.inMinutes >= 15
        ? widget.timeSlotDuration
        : const Duration(minutes: 15);
    DateTime start = proposedStart;
    DateTime end = proposedEnd;
    if (edge == MCalResizeEdge.start) {
      final minimumEnd = start.add(eventMinDuration);
      if (end.isBefore(minimumEnd) || !end.isAfter(start)) {
        start = end.subtract(eventMinDuration);
      }
    } else {
      final minimumEnd = start.add(eventMinDuration);
      if (end.isBefore(minimumEnd) || !end.isAfter(start)) {
        end = minimumEnd;
      }
    }
    final isValid = _validateResize(event, start, end, edge);
    dragHandler.updateResize(
      proposedStart: start,
      proposedEnd: end,
      isValid: isValid,
      cells: const [],
    );
  }

  /// Adjusts keyboard resize by N slots (positive = longer).
  void _keyboardResizeBySlots(int deltaSlots) {
    final dragHandler = _dragHandler;
    if (dragHandler == null || !dragHandler.isResizing) return;

    final slotMins = widget.timeSlotDuration.inMinutes;
    final hourHeight = _cachedHourHeight > 0
        ? _cachedHourHeight
        : (widget.hourHeight ?? 80.0);
    final deltaPx = (deltaSlots * slotMins / 60.0) * hourHeight;
    final minOffset = 0.0;
    final maxOffset = (widget.endHour - widget.startHour) * hourHeight;
    _keyboardResizeEdgeOffset = (_keyboardResizeEdgeOffset + deltaPx).clamp(
      minOffset,
      maxOffset,
    );
    _updateKeyboardResizePreview();
    if (mounted) {
      final edge = _keyboardResizeEdge == MCalResizeEdge.start
          ? 'start'
          : 'end';
      _announceScreenReader(context, 'Adjusted $edge time');
    }
    setState(() {});
  }

  /// Switches keyboard resize edge (Tab).
  void _keyboardResizeSwitchEdge() {
    final dragHandler = _dragHandler;
    if (dragHandler == null || !dragHandler.isResizing) return;

    final event = dragHandler.resizingEvent!;
    final edge = _keyboardResizeEdge ?? MCalResizeEdge.end;
    final newEdge = edge == MCalResizeEdge.start
        ? MCalResizeEdge.end
        : MCalResizeEdge.start;
    _keyboardResizeEdge = newEdge;
    _ensureDragHandler.cancelResize();
    _ensureDragHandler.startResize(event, newEdge);
    _keyboardResizeEdgeOffset = timeToOffset(
      time: newEdge == MCalResizeEdge.start
          ? dragHandler.resizeOriginalStart!
          : dragHandler.resizeOriginalEnd!,
      startHour: widget.startHour,
      hourHeight: _cachedHourHeight > 0
          ? _cachedHourHeight
          : (widget.hourHeight ?? 80.0),
    );
    _updateKeyboardResizePreview();
    if (mounted) {
      final edgeLabel = newEdge == MCalResizeEdge.start ? 'start' : 'end';
      _announceScreenReader(context, 'Now adjusting $edgeLabel time');
    }
    setState(() {});
  }

  /// Confirms the keyboard resize (Enter).
  void _confirmKeyboardResize() {
    final dragHandler = _dragHandler;
    if (dragHandler == null || !dragHandler.isResizing) return;
    if (!dragHandler.isProposedDropValid) {
      if (mounted) {
        _announceScreenReader(context, 'Invalid resize');
      }
      return;
    }
    _handleResizeEnd();
    _exitKeyboardResizeMode(cancel: false);
  }

  /// Exits keyboard resize mode.
  void _exitKeyboardResizeMode({required bool cancel}) {
    _isKeyboardResizeMode = false;
    _keyboardResizeEdge = null;
    _ensureDragHandler.cancelResize();
    if (mounted && cancel) {
      _announceScreenReader(context, 'Resize cancelled');
    }
    setState(() {});
  }

  /// Handles Tab/Shift+Tab to cycle focus between events.
  void _handleTabNavigation(bool shift) {
    final allFocusable = [..._allDayEvents, ..._timedEvents];
    if (allFocusable.isEmpty) return;

    int nextIndex;
    if (_focusedEvent == null) {
      nextIndex = shift ? allFocusable.length - 1 : 0;
    } else {
      final idx = allFocusable.indexWhere((e) => e.id == _focusedEvent!.id);
      if (idx < 0) {
        nextIndex = shift ? allFocusable.length - 1 : 0;
      } else {
        nextIndex = shift
            ? (idx - 1 + allFocusable.length) % allFocusable.length
            : (idx + 1) % allFocusable.length;
      }
    }

    setState(() {
      _focusedEvent = allFocusable[nextIndex];
    });
  }

  /// Handles event tap - forwards to widget callback and optionally sets keyboard focus.
  void _handleEventTap(BuildContext context, MCalEventTapDetails details) {
    if (widget.autoFocusOnEventTap && widget.enableKeyboardNavigation) {
      setState(() {
        _focusedEvent = details.event;
      });
      if (!_focusNode.hasFocus) {
        _focusNode.requestFocus();
      }
    }
    widget.onEventTap?.call(context, details);
  }

  /// Called when the user presses on a resize handle.
  ///
  /// Stores pointer/event/edge for parent [Listener] to track the gesture
  /// across scroll and navigation. Resize start is triggered when the
  /// drag threshold is crossed in [_handleResizePointerMoveFromParent].
  void _handleResizePointerDownFromChild(
    MCalCalendarEvent event,
    MCalResizeEdge edge,
    int pointer,
  ) {
    _resizeActivePointer = pointer;
    _resizeGestureStarted = false;
    _resizeDyAccumulated = 0.0;
    _pendingResizeEvent = event;
    _pendingResizeEdge = edge;

    // Hold scroll so SingleChildScrollView doesn't steal the pointer
    _releaseResizeScrollHold();
    final scForHold = _scrollController;
    final position = (scForHold != null && scForHold.hasClients)
        ? scForHold.position
        : null;
    if (position != null && position.hasPixels) {
      try {
        _resizeScrollHold = position.hold(() {
          _resizeScrollHold = null;
        });
      } catch (_) {
        // Scroll hold failed, resize can still proceed
      }
    }
  }

  /// Releases the scroll hold that freezes [SingleChildScrollView] during resize.
  void _releaseResizeScrollHold() {
    _resizeScrollHold?.cancel();
    _resizeScrollHold = null;
  }

  /// Called by the parent [Listener.onPointerMove].
  /// Implements a manual drag threshold, then delegates to [_handleResizeUpdate].
  void _handleResizePointerMoveFromParent(PointerMoveEvent pointerEvent) {
    if (pointerEvent.pointer != _resizeActivePointer) return;

    if (!_resizeGestureStarted) {
      _resizeDyAccumulated += pointerEvent.delta.dy;
      if (_resizeDyAccumulated.abs() < _resizeDragThreshold) return;

      _resizeGestureStarted = true;
      final event = _pendingResizeEvent;
      final edge = _pendingResizeEdge;
      if (event == null || edge == null) return;

      _handleResizeStart(event, edge);
      return;
    }

    // Resize in progress — pass delta to update.
    _handleResizeUpdate(
      _pendingResizeEvent!,
      _pendingResizeEdge!,
      pointerEvent.delta.dy,
    );

    // Store pointer position for post-navigation edge re-check.
    _lastResizePointerGlobal = pointerEvent.position;

    // Vertical auto-scroll when the resize handle is near the top/bottom of
    // the visible viewport. reprocessDrag=false: resize tracks an accumulated
    // delta, not an absolute position, so no need to re-run drag-move each tick.
    _checkVerticalScrollEdge(pointerEvent.position.dy, reprocessDrag: false);

    // Horizontal edge detection for cross-day navigation:
    // start handle near leading edge → previous day,
    // end handle near trailing edge → next day.
    _checkResizeEdgeProximity(pointerEvent.position);
  }

  /// Called by the parent [Listener.onPointerUp].
  void _handleResizePointerUpFromParent(PointerUpEvent pointerEvent) {
    if (pointerEvent.pointer != _resizeActivePointer) return;

    if (_resizeGestureStarted) {
      _handleResizeEnd();
    } else {
      _dragHandler?.cancelResize();
    }
    _cleanupResizePointerState();
  }

  /// Called by the parent [Listener.onPointerCancel].
  void _handleResizePointerCancelFromParent(PointerCancelEvent pointerEvent) {
    if (pointerEvent.pointer != _resizeActivePointer) return;

    _dragHandler?.cancelResize();
    _cleanupResizePointerState();
  }

  /// Resets all pointer-level resize tracking state and releases the scroll hold.
  void _cleanupResizePointerState() {
    _resizeActivePointer = null;
    _resizeGestureStarted = false;
    _pendingResizeEvent = null;
    _pendingResizeEdge = null;
    _lastResizePointerGlobal = null;
    _releaseResizeScrollHold();
    _cancelVerticalScrollTimer();
    _dragHandler?.cancelEdgeNavigation();
    // Invalidate the layout cache so a subsequent drag session re-captures
    // fresh RenderBox positions (the resize may have scrolled the viewport).
    _layoutCachedForDrag = false;

    if (_isResizeActive) {
      _isResizeActive = false;
      setState(() {});
    }
  }

  /// Called when resize drag starts. Initializes resize state.
  void _handleResizeStart(MCalCalendarEvent event, MCalResizeEdge edge) {
    if (!_resolveDragToResize()) return;
    // Populate the drag layout cache so _checkVerticalScrollEdge has the
    // viewport bounds it needs for auto-scroll edge detection during resize.
    _cacheLayoutForDrag();
    final hourHeight = _cachedHourHeight > 0
        ? _cachedHourHeight
        : (widget.hourHeight ?? 80.0);
    _ensureDragHandler.startResize(event, edge);
    _resizeEdgeOffset = edge == MCalResizeEdge.start
        ? timeToOffset(
            time: event.start,
            startHour: widget.startHour,
            hourHeight: hourHeight,
          )
        : timeToOffset(
            time: event.end,
            startHour: widget.startHour,
            hourHeight: hourHeight,
          );
    _isResizeActive = true;
    if (mounted) {
      final edgeLabel = edge == MCalResizeEdge.start
          ? 'start time'
          : 'end time';
      _announceScreenReader(
        context,
        'Resizing ${event.title}. Adjusting $edgeLabel. Drag up or down.',
      );
    }
    setState(() {});
  }

  /// Recomputes the proposed resize range from the current pointer position and
  /// live scroll offset, without requiring a pointer-move event.
  ///
  /// Called on every vertical scroll timer tick so the proposed start/end time
  /// updates as the viewport shifts beneath a stationary resize handle. Without
  /// this, the tile stays pinned to its pre-scroll offset while the content
  /// scrolls away beneath the pointer.
  void _reprocessResize() {
    if (!_isResizeActive) return;
    final event = _pendingResizeEvent;
    final edge = _pendingResizeEdge;
    final pointerGlobal = _lastResizePointerGlobal;
    if (event == null || edge == null || pointerGlobal == null) return;

    final sc = _scrollController;
    if (sc == null || !sc.hasClients) return;

    // viewport_screen_top is invariant: the fixed on-screen Y of the top edge
    // of the scroll viewport (computed at cache time, doesn't change as
    // content scrolls).
    final viewportTop = _cachedTimeGridGlobalTop + _cachedScrollOffset;

    // Pointer's absolute Y position within the time-grid content, accounting
    // for the current (possibly post-scroll) scroll offset.
    final newEdgeOffset = (pointerGlobal.dy - viewportTop) + sc.offset;

    final hourHeight = _cachedHourHeight > 0
        ? _cachedHourHeight
        : (widget.hourHeight ?? 80.0);
    final maxOffset = (widget.endHour - widget.startHour) * hourHeight;
    final clampedOffset = newEdgeOffset.clamp(0.0, maxOffset);

    // Minimum event duration in pixels.
    final eventMinDuration = widget.timeSlotDuration.inMinutes >= 15
        ? widget.timeSlotDuration
        : const Duration(minutes: 15);
    final minDurationPx = eventMinDuration.inMinutes * hourHeight / 60.0;

    // Effective start/end offsets on the current display day — clamped to the
    // day's visible range so multi-day events (where one edge is off-screen)
    // use the day boundary (0 or maxOffset) as the reference limit.
    final isStartOnCurrentDay =
        event.start.year == _displayDate.year &&
        event.start.month == _displayDate.month &&
        event.start.day == _displayDate.day;
    final isEndOnCurrentDay =
        event.end.year == _displayDate.year &&
        event.end.month == _displayDate.month &&
        event.end.day == _displayDate.day;

    final effectiveStartPx = isStartOnCurrentDay
        ? timeToOffset(
            time: event.start,
            startHour: widget.startHour,
            hourHeight: hourHeight,
          )
        : 0.0;
    final effectiveEndPx = isEndOnCurrentDay
        ? timeToOffset(
            time: event.end,
            startHour: widget.startHour,
            hourHeight: hourHeight,
          )
        : maxOffset;

    // Stop auto-scroll the moment the dragged edge would cross the minimum-
    // duration boundary imposed by the other edge.  Without this the timer
    // keeps firing after the proposed time is already clamped, producing the
    // visual effect of the handle "passing through" the opposite edge.
    if (edge == MCalResizeEdge.end &&
        clampedOffset <= effectiveStartPx + minDurationPx) {
      _cancelVerticalScrollTimer();
      return;
    }
    if (edge == MCalResizeEdge.start &&
        clampedOffset >= effectiveEndPx - minDurationPx) {
      _cancelVerticalScrollTimer();
      return;
    }

    // Apply the absolute offset then let _handleResizeUpdate (delta = 0.0)
    // recalculate the proposed times via the same snapping/validation logic.
    _resizeEdgeOffset = clampedOffset;
    _handleResizeUpdate(event, edge, 0.0);
  }

  /// Called during resize drag. Updates proposed range from accumulated offset.
  void _handleResizeUpdate(
    MCalCalendarEvent event,
    MCalResizeEdge edge,
    double deltaDy,
  ) {
    final dragHandler = _dragHandler;
    if (dragHandler == null || !dragHandler.isResizing) return;

    final hourHeight = _cachedHourHeight > 0
        ? _cachedHourHeight
        : (widget.hourHeight ?? 80.0);
    final minOffset = 0.0;
    final maxOffset = (widget.endHour - widget.startHour) * hourHeight;
    final eventMinDuration = widget.timeSlotDuration.inMinutes >= 15
        ? widget.timeSlotDuration
        : const Duration(minutes: 15);

    _resizeEdgeOffset += deltaDy;
    _resizeEdgeOffset = _resizeEdgeOffset.clamp(minOffset, maxOffset);

    DateTime proposedStart = event.start;
    DateTime proposedEnd = event.end;

    if (edge == MCalResizeEdge.start) {
      proposedStart = snapToTimeSlot(
        time: offsetToTime(
          offset: _resizeEdgeOffset,
          date: _displayDate,
          startHour: widget.startHour,
          hourHeight: hourHeight,
        ),
        timeSlotDuration: widget.timeSlotDuration,
      );
      final minimumEnd = proposedStart.add(eventMinDuration);
      if (proposedEnd.isBefore(minimumEnd) ||
          !proposedEnd.isAfter(proposedStart)) {
        proposedStart = proposedEnd.subtract(eventMinDuration);
      }
    } else {
      proposedEnd = snapToTimeSlot(
        time: offsetToTime(
          offset: _resizeEdgeOffset,
          date: _displayDate,
          startHour: widget.startHour,
          hourHeight: hourHeight,
        ),
        timeSlotDuration: widget.timeSlotDuration,
      );
      final minimumEnd = proposedStart.add(eventMinDuration);
      if (proposedEnd.isBefore(minimumEnd) ||
          !proposedEnd.isAfter(proposedStart)) {
        proposedEnd = minimumEnd;
      }
    }

    final isValid = _validateResize(event, proposedStart, proposedEnd, edge);
    dragHandler.updateResize(
      proposedStart: proposedStart,
      proposedEnd: proposedEnd,
      isValid: isValid,
      cells: const [],
    );
  }

  /// Called when resize drag ends. Completes resize and fires callback.
  void _handleResizeEnd() {
    final dragHandler = _dragHandler;
    if (dragHandler == null || !dragHandler.isResizing) {
      _isResizeActive = false;
      setState(() {});
      return;
    }

    // Read all resize state BEFORE completeResize() clears it via
    // _clearResizeState(). Reading these fields after completeResize()
    // returns null values, causing an early return and no controller update.
    final event = dragHandler.resizingEvent;
    final originalStart = dragHandler.resizeOriginalStart;
    final originalEnd = dragHandler.resizeOriginalEnd;
    final edge = dragHandler.resizeEdge;

    final result = dragHandler.completeResize();
    _isResizeActive = false;
    setState(() {});

    if (result == null) return;

    final (newStart, newEnd) = result;

    if (event == null ||
        originalStart == null ||
        originalEnd == null ||
        edge == null) {
      return;
    }

    final updatedEvent = event.copyWith(start: newStart, end: newEnd);

    final details = MCalEventResizedDetails(
      event: event,
      oldStartDate: originalStart,
      oldEndDate: originalEnd,
      newStartDate: newStart,
      newEndDate: newEnd,
      resizeEdge: edge,
      isRecurring: event.recurrenceRule != null,
    );

    // Handle recurring vs non-recurring events (matching Month View pattern)
    if (event.recurrenceRule != null) {
      // Recurring event: call callback first, only modify if accepted
      if (widget.onEventResized != null) {
        final shouldKeep = widget.onEventResized!(context, details);
        if (shouldKeep) {
          widget.controller.modifyOccurrence(
            event.id,
            originalStart,
            updatedEvent,
          );
        }
      } else {
        // No callback provided — auto-accept and modify occurrence
        widget.controller.modifyOccurrence(
          event.id,
          originalStart,
          updatedEvent,
        );
      }
    } else {
      // Non-recurring event: update controller first, then call callback
      widget.controller.addEvents([updatedEvent]);

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

    // Screen reader announcement for successful resize
    if (mounted) {
      final locale = widget.locale ?? Localizations.localeOf(context);
      final startStr = DateFormat.Hm(locale.toString()).format(newStart);
      final endStr = DateFormat.Hm(locale.toString()).format(newEnd);
      final duration = newEnd.difference(newStart);
      final hours = duration.inHours;
      final mins = duration.inMinutes % 60;
      final durationStr = hours > 0
          ? '$hours ${hours == 1 ? 'hour' : 'hours'}${mins > 0 ? ' $mins minutes' : ''}'
          : '$mins minutes';
      _announceScreenReader(
        context,
        'Resized ${event.title} to $startStr through $endStr, $durationStr',
      );
    }
  }

  /// Called when resize drag is cancelled.
  void _handleResizeCancel() {
    _dragHandler?.cancelResize();
    _isResizeActive = false;
    setState(() {});
  }

  /// Validates proposed resize against user callback and constraints.
  bool _validateResize(
    MCalCalendarEvent event,
    DateTime proposedStart,
    DateTime proposedEnd,
    MCalResizeEdge edge,
  ) {
    if (widget.onResizeWillAccept == null) return true;
    final details = MCalEventResizedDetails(
      event: event,
      oldStartDate: event.start,
      oldEndDate: event.end,
      newStartDate: proposedStart,
      newEndDate: proposedEnd,
      resizeEdge: edge,
      isRecurring: event.recurrenceRule != null,
    );
    return widget.onResizeWillAccept!(details);
  }

  /// Raw pointer tracking during an active drag.
  ///
  /// The parent [Listener] forwards every pointer-move event here.  When the
  /// DragTarget's `onMove` is still firing (normal case), `_latestDragDetails`
  /// is non-null and `_processDragMove` handles everything — we only use the
  /// raw pointer here for edge detection when the DragTarget has fired
  /// `onLeave` (e.g. the cursor has left the time grid).
  void _handleDragPointerMove(PointerMoveEvent event) {
    if (!_isDragActive || !_layoutCachedForDrag) return;

    // If DragTarget.onMove is still active, it drives _processDragMove which
    // already handles edge detection and drop preview. We only step in after
    // DragLeave.
    if (_isDragTargetActive) return;

    final globalPos = event.position;
    _lastFallbackCursorGlobal = globalPos;
    final feedbackGlobalX = globalPos.dx - _cachedGrabOffsetX;
    final feedbackGlobalY = globalPos.dy - _cachedGrabOffsetY;

    // Store the computed feedback position so _processDragMove can use it
    // instead of the stale _latestDragDetails.offset.  This allows the drop
    // preview, edge detection, and debug overlay to all stay in sync with the
    // live tile position even when the tile's left edge exits the DragTarget.
    _fallbackFeedbackGlobal = Offset(feedbackGlobalX, feedbackGlobalY);

    // Delegate all processing (edge detection, drop preview, debug overlay) to
    // _processDragMove via the debounce timer — same path as the DragTarget
    // onMove handler, but using _fallbackFeedbackGlobal for position.
    if (_dragMoveDebounceTimer == null || !_dragMoveDebounceTimer!.isActive) {
      _dragMoveDebounceTimer = Timer(
        const Duration(milliseconds: 16),
        _processDragMove,
      );
    }
  }

  /// Handles drag move events from the unified DragTarget.
  ///
  /// This method is called on every frame during drag. To maintain 60fps,
  /// we only store the latest position here and debounce the expensive
  /// calculations to run at most once per 16ms.
  void _handleDragMove(DragTargetDetails<MCalDragData> details) {
    _latestDragDetails = details;
    _isDragTargetActive = true;

    // Refresh feedback tile dimensions and grab offsets from drag data on every
    // move so that a new drag session always picks up the current tile size —
    // never a value left over from a previous drag.  feedbackWidth is a final
    // field on MCalDragData (set at long-press recognition time), so it is the
    // same value on every call within one session; updating unconditionally is
    // safe and eliminates the stale-width bug that appeared after dragging an
    // event between overlap and non-overlap slots.
    final data = details.data;
    if (data.feedbackWidth > 0) {
      _feedbackTileWidth = data.feedbackWidth;
      _feedbackTileHeight = data.feedbackHeight;
    }
    _cachedGrabOffsetX = data.grabOffsetX;
    _cachedGrabOffsetY = data.grabOffsetY;

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
  /// run at most once per 16ms frame.  The DragTarget wraps the entire
  /// interactive surface (all-day area + time grid), so this method
  /// handles both region detection and 4-zone edge detection in a single
  /// pass — matching the Month View's `_processDragMove` structure.
  void _processDragMove() {
    final details = _latestDragDetails;
    if (details == null) return;

    final dragHandler = _dragHandler;
    if (dragHandler == null) return;

    // Guard: if the drag/resize is no longer active (e.g. this is called by the
    // vertical-scroll timer after _handleDrop already called cancelDrag()), bail
    // out immediately.
    if (!dragHandler.isDragging && !dragHandler.isResizing) {
      debugPrint(
        '[DD] _processDragMove: bailing out — drag/resize not active (stale timer tick?)',
      );
      _cancelVerticalScrollTimer();
      return;
    }

    // Cache layout once per drag session.  After page navigation the cache is
    // invalidated (see _handleNavigatePrevious/_handleNavigateNext) so the next
    // tick re-captures the new page's layout.
    if (!_layoutCachedForDrag) {
      _cacheLayoutForDrag();
      if (!_layoutCachedForDrag) return; // RenderBoxes not ready
    }

    // Resolve the feedback widget's top-left in global coordinates.
    // When DragTarget is still active, use the live details.offset.
    // When in fallback mode (after DragLeave), use the position computed from
    // the raw pointer event so the drop preview and debug overlay continue
    // tracking the tile rather than freezing at the last DragTarget position.
    final dragData = details.data;
    final feedbackGlobal =
        (!_isDragTargetActive && _fallbackFeedbackGlobal != null)
        ? _fallbackFeedbackGlobal!
        : details.offset;
    final cursorGlobalY = feedbackGlobal.dy + dragData.grabOffsetY;
    final tileCenterX = feedbackGlobal.dx + _feedbackTileWidth / 2;
    final tileCenterY = feedbackGlobal.dy + _feedbackTileHeight / 2;

    // TEMPORARY DEBUG: always update tile center so the overlay tracks the
    // tile center regardless of whether we're in DragTarget-active or fallback
    // mode.  Both paths now provide accurate positions.
    _debugTileCenterGlobal = Offset(tileCenterX, tileCenterY);

    // Convert to grid-area-local Y coordinate (cursor-based for region detection).
    final localY = cursorGlobalY - _cachedDayContentOffset.dy;

    // --- Region detection ---
    // Everything above _cachedTimeGridTopInDayContent is the all-day area.
    // Everything at or below is the scrollable time grid.
    final bool isInTimeGrid = localY >= _cachedTimeGridTopInDayContent;

    // For drop-target time calculation, compute the feedback widget's
    // position within the time grid's content coordinate system.
    // We need a fresh lookup of the time grid box because its global
    // origin changes during vertical auto-scroll.
    final RenderBox? timeGridBox =
        _timeGridKey.currentContext?.findRenderObject() as RenderBox?;
    if (timeGridBox != null && timeGridBox.attached) {
      final feedbackLocal = timeGridBox.globalToLocal(feedbackGlobal);

      if (isInTimeGrid) {
        final bool wasAllDayEvent = dragData.event.isAllDay;
        if (wasAllDayEvent) {
          _handleAllDayToTimedConversion(feedbackLocal);
        } else {
          _handleSameTypeMove(feedbackLocal);
        }
      } else {
        _handleTimedToAllDayConversion(feedbackLocal);
      }
    } else {
      debugPrint(
        '[DD] ProcessDragMove: WARNING — timeGridBox null=${timeGridBox == null} attached=${timeGridBox?.attached}',
      );
    }

    // --- Edge detection ---
    // Horizontal: uses the tile's visual center against 25% edge zones within
    // the time grid. This triggers navigation when the tile center enters the
    // edge zone, not when the cursor does.
    // We can run this in both DragTarget-active mode and fallback mode because
    // feedbackGlobal is now accurate in both cases (fallback uses
    // _fallbackFeedbackGlobal which is computed from the live pointer position).
    // The only case where we must skip is when _latestDragDetails is stale and
    // no fallback position is available — but that cannot happen here since we
    // return early above if both sources are unavailable.
    if (widget.dragEdgeNavigationEnabled &&
        (_isDragTargetActive || _fallbackFeedbackGlobal != null)) {
      _checkEdgeProximity(tileCenterX);
    }

    // Vertical auto-scroll: uses tile's top/bottom edge proximity to the
    // visible scroll viewport. Only active in the time grid.
    if (isInTimeGrid) {
      _checkVerticalScrollEdge(feedbackGlobal.dy, reprocessDrag: true);
    } else {
      _cancelVerticalScrollTimer();
    }

    // TEMPORARY DEBUG: force rebuild so the tile center line overlay updates.
    if (mounted) setState(() {});
  }

  /// Handles conversion from all-day event to timed event during drag.
  ///
  /// Calculates the time slot from the Y position and creates a proposed
  /// drop range using the configured [allDayToTimedDuration].
  void _handleAllDayToTimedConversion(Offset localPosition) {
    final dragHandler = _dragHandler;
    if (dragHandler == null) return;

    // Convert pixel offset to time (pure, no slot rounding).
    // Snapping is applied separately by _applySnapping so that timeSlotDuration
    // and gridlineInterval remain fully independent concerns.
    final hourHeight = widget.hourHeight ?? 80.0;
    final proposedStart = offsetToTime(
      offset: localPosition.dy,
      date: _displayDate,
      startHour: widget.startHour,
      hourHeight: hourHeight,
    );

    // Apply snapping
    final snappedStart = _applySnapping(proposedStart);

    // Calculate end time using configured duration
    final proposedEnd = DateTime(
      snappedStart.year,
      snappedStart.month,
      snappedStart.day,
      snappedStart.hour,
      snappedStart.minute + widget.allDayToTimedDuration.inMinutes,
    );

    // Validate the drop
    final isValid = _validateDrop(
      proposedStart: snappedStart,
      proposedEnd: proposedEnd,
    );

    // Update drag handler with proposed range (preserveTime for day view)
    dragHandler.updateProposedDropRange(
      proposedStart: snappedStart,
      proposedEnd: proposedEnd,
      isValid: isValid,
      preserveTime: true,
    );
  }

  /// Handles conversion from timed event to all-day event during drag.
  ///
  /// Sets the proposed drop range to midnight-to-midnight for the display date,
  /// accounting for edge navigation.
  void _handleTimedToAllDayConversion(Offset localPosition) {
    final dragHandler = _dragHandler;
    if (dragHandler == null) return;

    // Use _displayDate for proposed date (accounts for edge navigation)
    final proposedStart = DateTime(
      _displayDate.year,
      _displayDate.month,
      _displayDate.day,
      0,
      0,
    );
    final proposedEnd = DateTime(
      _displayDate.year,
      _displayDate.month,
      _displayDate.day,
      0,
      0,
    );

    // Validate the drop
    final isValid = _validateDrop(
      proposedStart: proposedStart,
      proposedEnd: proposedEnd,
    );

    // Update drag handler (preserveTime for day view)
    dragHandler.updateProposedDropRange(
      proposedStart: proposedStart,
      proposedEnd: proposedEnd,
      isValid: isValid,
      preserveTime: true,
    );
  }

  /// Handles drag move within the same section type (all-day or timed).
  ///
  /// For timed events: calculates new time from Y position with snapping.
  /// For all-day events: maintains all-day status on current display date.
  void _handleSameTypeMove(Offset localPosition) {
    final dragHandler = _dragHandler;
    if (dragHandler == null) return;

    final dragData = _latestDragDetails?.data;
    if (dragData == null) return;

    final event = dragData.event;
    final originalDuration = event.end.difference(event.start);

    if (event.isAllDay) {
      final proposedStart = DateTime(
        _displayDate.year,
        _displayDate.month,
        _displayDate.day,
        0,
        0,
      );
      final proposedEnd = DateTime(
        _displayDate.year,
        _displayDate.month,
        _displayDate.day,
        0,
        0,
      );

      final isValid = _validateDrop(
        proposedStart: proposedStart,
        proposedEnd: proposedEnd,
      );

      dragHandler.updateProposedDropRange(
        proposedStart: proposedStart,
        proposedEnd: proposedEnd,
        isValid: isValid,
        preserveTime: true,
      );
    } else {
      final hourHeight = widget.hourHeight ?? 80.0;
      final proposedStart = offsetToTime(
        offset: localPosition.dy,
        date: _displayDate,
        startHour: widget.startHour,
        hourHeight: hourHeight,
      );

      final snappedStart = _applySnapping(proposedStart);

      final proposedEnd = DateTime(
        snappedStart.year,
        snappedStart.month,
        snappedStart.day,
        snappedStart.hour,
        snappedStart.minute + originalDuration.inMinutes,
      );

      final isValid = _validateDrop(
        proposedStart: snappedStart,
        proposedEnd: proposedEnd,
      );

      dragHandler.updateProposedDropRange(
        proposedStart: snappedStart,
        proposedEnd: proposedEnd,
        isValid: isValid,
        preserveTime: true,
      );
    }
  }

  /// Checks horizontal edge proximity for day navigation.
  ///
  /// Triggers navigation to previous/next day when pointer is within 50px
  /// of the left or right edge.
  /// Checks whether [globalY] (the pointer's global Y coordinate) falls inside
  /// the top or bottom edge zone of the visible timed-events viewport.
  ///
  /// When inside an edge zone a [Timer.periodic] is started (or kept running)
  /// that scrolls the [_scrollController] by [_verticalScrollDelta] pixels
  /// every 16 ms.  Speed scales linearly from 0 at the zone boundary to
  /// [_verticalScrollMaxSpeed] at the extreme edge.
  ///
  /// [reprocessDrag] controls whether each timer tick also re-runs
  /// [_processDragMove] to update the drop-target preview as content scrolls
  /// past the stationary pointer.  Pass `true` for drag-to-move (where the
  /// preview must follow the pointer) and `false` for resize (where the delta
  /// accumulator already tracks movement correctly).
  /// Checks whether the feedback tile's top or bottom edge is within
  /// [_vertEdgeThresholdPx] of the scroll viewport's top or bottom boundary.
  ///
  /// [feedbackGlobalY] is the feedback tile's top-left Y in global coordinates.
  /// The bottom edge is computed as `feedbackGlobalY + _feedbackTileHeight`.
  void _checkVerticalScrollEdge(
    double feedbackGlobalY, {
    bool reprocessDrag = false,
  }) {
    if (_dragStartTime != null &&
        DateTime.now().difference(_dragStartTime!) < _vertEdgeGracePeriod) {
      debugPrint('[DD] VertEdge: within grace period — skipping');
      return;
    }

    final sc = _scrollController;
    if (sc == null || !sc.hasClients) {
      debugPrint('[DD] VertEdge: no scroll controller — cancelling');
      _cancelVerticalScrollTimer();
      return;
    }

    if (!_layoutCachedForDrag) {
      debugPrint('[DD] VertEdge: layout not cached — cancelling');
      _cancelVerticalScrollTimer();
      return;
    }

    final viewportHeight = sc.position.viewportDimension;

    // _timeGridKey is on the scrollable *content* (a SizedBox spanning the
    // full time grid height), so its global Y shifts as the user scrolls.
    // We need the *viewport container's* fixed screen position instead.
    //
    // At cache time: _cachedTimeGridGlobalTop = viewport_screen_top - _cachedScrollOffset
    // Therefore:      viewport_screen_top     = _cachedTimeGridGlobalTop + _cachedScrollOffset
    //
    // This value is invariant for the lifetime of the drag even as the user
    // auto-scrolls, because the viewport container doesn't move on screen.
    final viewportTop = _cachedTimeGridGlobalTop + _cachedScrollOffset;
    final viewportBottom = viewportTop + viewportHeight;

    final tileTop = feedbackGlobalY;
    final tileBottom = feedbackGlobalY + _feedbackTileHeight;

    const maxSpeed = 10.0;

    // Tile's top edge within threshold of viewport top → scroll up.
    final distFromTop = tileTop - viewportTop;
    if (distFromTop < _vertEdgeThresholdPx && sc.offset > 0) {
      final proximity = (1.0 - distFromTop / _vertEdgeThresholdPx).clamp(
        0.0,
        1.0,
      );
      _startVerticalScrollTimer(
        -(maxSpeed * proximity).clamp(1.0, maxSpeed),
        reprocessDrag: reprocessDrag,
      );
    }
    // Tile's bottom edge within threshold of viewport bottom → scroll down.
    else if (viewportBottom - tileBottom < _vertEdgeThresholdPx &&
        sc.offset < sc.position.maxScrollExtent) {
      final distFromBottom = viewportBottom - tileBottom;
      final proximity = (1.0 - distFromBottom / _vertEdgeThresholdPx).clamp(
        0.0,
        1.0,
      );
      _startVerticalScrollTimer(
        (maxSpeed * proximity).clamp(1.0, maxSpeed),
        reprocessDrag: reprocessDrag,
      );
    } else {
      _cancelVerticalScrollTimer();
    }
  }

  /// Starts (or keeps running) the vertical auto-scroll timer.
  ///
  /// Always updates [_verticalScrollDelta] so a running timer immediately
  /// picks up speed changes without restarting.  A new timer is only created
  /// when none is currently active.
  void _startVerticalScrollTimer(
    double deltaPerFrame, {
    bool reprocessDrag = false,
  }) {
    _verticalScrollDelta = deltaPerFrame;
    _verticalScrollReprocessDrag = reprocessDrag;

    if (_verticalScrollTimer?.isActive == true) {
      // Timer already running — delta and reprocess flag updated above.
      return;
    }

    debugPrint(
      '[DD] VertScrollTimer: STARTED delta=$deltaPerFrame reprocessDrag=$reprocessDrag isDragActive=$_isDragActive',
    );
    _verticalScrollTimer = Timer.periodic(const Duration(milliseconds: 16), (
      _,
    ) {
      final sc = _scrollController;
      if (sc == null || !sc.hasClients) {
        debugPrint(
          '[DD] VertScrollTimer TICK: no scroll controller — cancelling',
        );
        _cancelVerticalScrollTimer();
        return;
      }
      final newOffset = (sc.offset + _verticalScrollDelta).clamp(
        0.0,
        sc.position.maxScrollExtent,
      );
      if (newOffset == sc.offset) {
        debugPrint('[DD] VertScrollTimer TICK: boundary reached — cancelling');
        _cancelVerticalScrollTimer();
        return;
      }

      if (!_isDragActive && !_isResizeActive) {
        debugPrint(
          '[DD] VertScrollTimer TICK: neither drag nor resize active — cancelling',
        );
        _cancelVerticalScrollTimer();
        return;
      }
      sc.jumpTo(newOffset);

      // Re-run drag-move processing so the drop-target preview updates as
      // the content shifts beneath the stationary pointer.
      if (_verticalScrollReprocessDrag && _latestDragDetails != null) {
        _processDragMove();
      }

      // Re-run resize processing so the proposed time updates as the viewport
      // scrolls beneath a stationary resize handle.
      if (_isResizeActive) {
        _reprocessResize();
      }
    });
  }

  /// Cancels the vertical auto-scroll timer and resets its state.
  void _cancelVerticalScrollTimer() {
    if (_verticalScrollTimer?.isActive == true) {
      debugPrint('[DD] VertScrollTimer: CANCELLED isDragActive=$_isDragActive');
    }
    _verticalScrollTimer?.cancel();
    _verticalScrollTimer = null;
    _verticalScrollDelta = 0.0;
    _verticalScrollReprocessDrag = false;
  }

  /// Checks horizontal edge proximity for day navigation using the **cursor
  /// (pointer) position**, matching the Month View pattern.
  ///
  /// The time grid is divided into three zones: the left [_edgeZoneFraction]
  /// (25%), a center safe zone (50%), and the right [_edgeZoneFraction] (25%).
  /// Navigation triggers when the cursor enters a side zone.
  ///
  /// [tileCenterGlobalX] is the tile's visual center horizontal position in
  /// global coordinates. Navigation triggers when this enters the 25% edge
  /// zones within the time grid.
  void _checkEdgeProximity(double tileCenterGlobalX) {
    final dragHandler = _dragHandler;
    if (dragHandler == null) return;

    if (_isProcessingDrop) return;

    final timeGridWidth =
        _cachedTimeGridGlobalRight - _cachedTimeGridGlobalLeft;
    if (timeGridWidth <= 0) {
      debugPrint(
        '[DD] EdgeProx: invalid time grid width ($timeGridWidth) — skipping',
      );
      return;
    }

    final edgeZoneWidth = timeGridWidth * _edgeZoneFraction;

    // Convert tile center to local-within-time-grid coordinates.
    final tileCenterLocalX = tileCenterGlobalX - _cachedTimeGridGlobalLeft;

    if (tileCenterLocalX < edgeZoneWidth) {
      debugPrint(
        '[DD] EdgeProx: NEAR LEFT (tileCenterGlobalX=$tileCenterGlobalX tileCenterLocalX=$tileCenterLocalX edgeZoneWidth=$edgeZoneWidth)',
      );
      dragHandler.handleEdgeProximity(
        true,
        true,
        _handleNavigatePrevious,
        delay: widget.dragEdgeNavigationDelay,
      );
    } else if (tileCenterLocalX > (timeGridWidth - edgeZoneWidth)) {
      debugPrint(
        '[DD] EdgeProx: NEAR RIGHT (tileCenterGlobalX=$tileCenterGlobalX tileCenterLocalX=$tileCenterLocalX edgeZoneWidth=$edgeZoneWidth)',
      );
      dragHandler.handleEdgeProximity(
        true,
        false,
        _handleNavigateNext,
        delay: widget.dragEdgeNavigationDelay,
      );
    } else {
      dragHandler.handleEdgeProximity(false, false, () {});
    }
  }

  /// Checks horizontal edge proximity during a resize gesture to trigger
  /// day navigation.
  ///
  /// Uses the same 25% edge zone as drag-to-move ([_edgeZoneFraction]).
  ///
  /// Primary directions (always active):
  ///   - Start handle → leading edge: navigate to previous day (extends event)
  ///   - End handle   → trailing edge: navigate to next day (extends event)
  ///
  /// Reverse directions (active only when the proposed range spans > 1 day,
  /// so single-day events cannot be shortened past their opposite edge):
  ///   - End handle   → leading edge: navigate to previous day (shortens event)
  ///   - Start handle → trailing edge: navigate to next day (shortens event)
  ///
  /// The time grid bounds are looked up fresh each call so no drag layout
  /// cache is required.
  void _checkResizeEdgeProximity(Offset pointerGlobal) {
    final dragHandler = _dragHandler;
    if (dragHandler == null || !dragHandler.isResizing) return;
    if (!widget.dragEdgeNavigationEnabled) return;

    final edge = _pendingResizeEdge;
    final event = _pendingResizeEvent;
    if (edge == null || event == null) return;

    // Fresh lookup — resize doesn't populate the drag layout cache.
    final RenderBox? timeGridBox =
        _timeGridKey.currentContext?.findRenderObject() as RenderBox?;
    if (timeGridBox == null || !timeGridBox.attached) return;

    final timeGridLeft = timeGridBox.localToGlobal(Offset.zero).dx;
    final timeGridWidth = timeGridBox.size.width;
    if (timeGridWidth <= 0) return;

    final edgeZoneWidth = timeGridWidth * _edgeZoneFraction;
    final pointerLocalX = pointerGlobal.dx - timeGridLeft;
    final isLayoutRTL = _isLayoutRTL(context);

    // Leading edge: left in LTR, right in RTL.
    final bool nearLeadingEdge = isLayoutRTL
        ? pointerLocalX > (timeGridWidth - edgeZoneWidth)
        : pointerLocalX < edgeZoneWidth;

    // Trailing edge: right in LTR, left in RTL.
    final bool nearTrailingEdge = isLayoutRTL
        ? pointerLocalX < edgeZoneWidth
        : pointerLocalX > (timeGridWidth - edgeZoneWidth);

    // Use the proposed range if already set (covers mid-resize multi-day
    // extension); fall back to the committed event times.
    final rangeStart = dragHandler.proposedStartDate ?? event.start;
    final rangeEnd = dragHandler.proposedEndDate ?? event.end;
    final isMultiDay =
        rangeStart.year != rangeEnd.year ||
        rangeStart.month != rangeEnd.month ||
        rangeStart.day != rangeEnd.day;

    if (edge == MCalResizeEdge.start && nearLeadingEdge) {
      // Extend start backward.
      debugPrint(
        '[DD] ResizeEdgeProx: NEAR LEADING (start handle) pointerLocalX=$pointerLocalX edgeZoneWidth=$edgeZoneWidth',
      );
      dragHandler.handleEdgeProximity(
        true,
        true,
        _handleResizeNavigatePrevious,
        delay: widget.dragEdgeNavigationDelay,
      );
    } else if (edge == MCalResizeEdge.start && isMultiDay && nearTrailingEdge) {
      // Shorten start forward — only valid for multi-day events.
      debugPrint(
        '[DD] ResizeEdgeProx: NEAR TRAILING (start handle, multi-day) pointerLocalX=$pointerLocalX edgeZoneWidth=$edgeZoneWidth',
      );
      dragHandler.handleEdgeProximity(
        true,
        false,
        _handleResizeNavigateNext,
        delay: widget.dragEdgeNavigationDelay,
      );
    } else if (edge == MCalResizeEdge.end && nearTrailingEdge) {
      // Extend end forward.
      debugPrint(
        '[DD] ResizeEdgeProx: NEAR TRAILING (end handle) pointerLocalX=$pointerLocalX edgeZoneWidth=$edgeZoneWidth',
      );
      dragHandler.handleEdgeProximity(
        true,
        false,
        _handleResizeNavigateNext,
        delay: widget.dragEdgeNavigationDelay,
      );
    } else if (edge == MCalResizeEdge.end && isMultiDay && nearLeadingEdge) {
      // Shorten end backward — only valid for multi-day events.
      debugPrint(
        '[DD] ResizeEdgeProx: NEAR LEADING (end handle, multi-day) pointerLocalX=$pointerLocalX edgeZoneWidth=$edgeZoneWidth',
      );
      dragHandler.handleEdgeProximity(
        true,
        true,
        _handleResizeNavigatePrevious,
        delay: widget.dragEdgeNavigationDelay,
      );
    } else {
      dragHandler.handleEdgeProximity(false, false, () {});
    }
  }

  /// Navigates to the previous day during a resize gesture and re-checks
  /// edge proximity after the new page lays out (pointer is stationary).
  void _handleResizeNavigatePrevious() {
    debugPrint(
      '[DD] ResizeNavigatePrevious CALLED at=${DateTime.now().toIso8601String()}',
    );
    final previousDay = DateTime(
      _displayDate.year,
      _displayDate.month,
      _displayDate.day - 1,
    );
    widget.controller.setDisplayDate(previousDay);
    _schedulePostResizeNavRefresh();
  }

  /// Navigates to the next day during a resize gesture and re-checks edge
  /// proximity after the new page lays out (pointer is stationary).
  void _handleResizeNavigateNext() {
    debugPrint(
      '[DD] ResizeNavigateNext CALLED at=${DateTime.now().toIso8601String()}',
    );
    final nextDay = DateTime(
      _displayDate.year,
      _displayDate.month,
      _displayDate.day + 1,
    );
    widget.controller.setDisplayDate(nextDay);
    _schedulePostResizeNavRefresh();
  }

  /// After day navigation during resize the pointer is stationary so no new
  /// pointer events arrive to re-arm the edge timer. Re-cache the layout for
  /// the new page, reprocess the resize offset with the fresh layout (so the
  /// proposed time is correct on the new day), then re-check edge proximity.
  void _schedulePostResizeNavRefresh([int attempt = 0]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isResizeActive) return;

      final timeGridBox =
          _timeGridKey.currentContext?.findRenderObject() as RenderBox?;
      final isReady =
          timeGridBox != null &&
          timeGridBox.attached &&
          timeGridBox.size.width > 0;

      debugPrint(
        '[DD] PostResizeNavRefresh(attempt=$attempt): isReady=$isReady',
      );

      if (!isReady && attempt < _maxPostNavRetries) {
        _schedulePostResizeNavRefresh(attempt + 1);
        return;
      }

      if (!isReady) {
        debugPrint(
          '[DD] PostResizeNavRefresh: EXHAUSTED retries — layout still not ready',
        );
        return;
      }

      // Re-cache with the new page's layout so subsequent reprocess and scroll
      // edge calculations use correct viewport bounds and scroll offset.
      _layoutCachedForDrag = false;
      _cacheLayoutForDrag();

      // Recalculate the proposed time from the live pointer position using the
      // freshly cached layout of the new page.
      _reprocessResize();

      // If the cursor landed on the wrong side of the anchored edge (e.g. end
      // handle navigated back to the start day and is now above the start time),
      // scroll the viewport so the anchor time is visible near the top.
      _scrollToShowResizeAnchorIfNeeded();

      // Re-arm the edge proximity timer — the pointer is stationary after
      // navigation so no new pointer events arrive to trigger this.
      final pos = _lastResizePointerGlobal;
      if (pos != null) {
        _checkResizeEdgeProximity(pos);
      }
    });
  }

  /// After resize day navigation, scrolls the viewport so that the "anchor"
  /// time (the opposite edge of the event from the handle being dragged) is
  /// near the top of the visible area when the cursor has landed on the wrong
  /// side of it.
  ///
  /// Scenarios:
  ///  - End handle navigated to the start day and cursor is above the event
  ///    start time → scroll to show the start time near the top.
  ///  - Start handle navigated to the end day and cursor is below the event
  ///    end time → scroll to show the end time near the top.
  void _scrollToShowResizeAnchorIfNeeded() {
    final edge = _pendingResizeEdge;
    final event = _pendingResizeEvent;
    final pointerGlobal = _lastResizePointerGlobal;
    if (edge == null || event == null || pointerGlobal == null) return;

    final sc = _scrollController;
    if (sc == null || !sc.hasClients) return;

    final hourHeight = _cachedHourHeight > 0
        ? _cachedHourHeight
        : (widget.hourHeight ?? 80.0);

    // Viewport screen-top is invariant for the current page.
    final viewportTop = _cachedTimeGridGlobalTop + _cachedScrollOffset;
    final cursorContentY = (pointerGlobal.dy - viewportTop) + sc.offset;

    DateTime? anchorTime;

    if (edge == MCalResizeEdge.end) {
      // End handle: anchor is the event start. Check if we're back on the
      // start day and the cursor is above the start time.
      final eventStartDay = DateTime(
        event.start.year,
        event.start.month,
        event.start.day,
      );
      final displayDay = DateTime(
        _displayDate.year,
        _displayDate.month,
        _displayDate.day,
      );
      if (displayDay == eventStartDay) {
        final startY = timeToOffset(
          time: event.start,
          startHour: widget.startHour,
          hourHeight: hourHeight,
        );
        if (cursorContentY < startY) anchorTime = event.start;
      }
    } else {
      // Start handle: anchor is the event end. Check if we're on the end day
      // and the cursor is below the end time.
      final eventEndDay = DateTime(
        event.end.year,
        event.end.month,
        event.end.day,
      );
      final displayDay = DateTime(
        _displayDate.year,
        _displayDate.month,
        _displayDate.day,
      );
      if (displayDay == eventEndDay) {
        final endY = timeToOffset(
          time: event.end,
          startHour: widget.startHour,
          hourHeight: hourHeight,
        );
        if (cursorContentY > endY) anchorTime = event.end;
      }
    }

    if (anchorTime == null) return;

    final anchorY = timeToOffset(
      time: anchorTime,
      startHour: widget.startHour,
      hourHeight: hourHeight,
    );
    // Show the anchor with one hour of padding above so there is context.
    final targetOffset = (anchorY - hourHeight).clamp(
      0.0,
      sc.position.maxScrollExtent,
    );

    // animateTo() releases _resizeScrollHold as a side-effect and takes
    // 300ms, during which _resizeEdgeOffset becomes stale relative to the
    // new scroll position.  After the animation settles, recompute the offset
    // from the absolute pointer position so subsequent pointer moves produce
    // correct deltas.  This mirrors what the vertical-scroll timer does on
    // each tick via _reprocessResize(), but skips that method's min-duration
    // early-return so the offset is always written (the delta-based
    // _handleResizeUpdate applies the clamping instead).
    sc
        .animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .then((_) {
          if (!mounted || !_isResizeActive) return;
          final resizeEvent = _pendingResizeEvent;
          final resizeEdge = _pendingResizeEdge;
          final ptr = _lastResizePointerGlobal;
          if (resizeEvent == null || resizeEdge == null || ptr == null) return;

          // viewportTop is invariant for this page (cached top + cached scroll
          // offset at cache time, which equals the fixed screen Y of the viewport).
          final viewportTop = _cachedTimeGridGlobalTop + _cachedScrollOffset;
          final newEdgeOffset = (ptr.dy - viewportTop) + sc.offset;
          final maxOffset = (widget.endHour - widget.startHour) * hourHeight;
          _resizeEdgeOffset = newEdgeOffset.clamp(0.0, maxOffset);

          // Apply via delta=0 so _handleResizeUpdate's validation and time
          // snapping runs without adding any extra offset.
          _handleResizeUpdate(resizeEvent, resizeEdge, 0.0);
        });
  }

  /// Validates a proposed drop position.
  ///
  /// Checks:
  /// 1. User onDragWillAccept callback (if provided)
  /// 2. Overlap with blockInteraction time regions
  /// 3. minDate and maxDate boundaries
  ///
  /// Returns true if the drop is valid, false otherwise.
  bool _validateDrop({
    required DateTime proposedStart,
    required DateTime proposedEnd,
  }) {
    final dragData = _latestDragDetails?.data;
    if (dragData == null) return false;

    // Check user validation callback if provided
    if (widget.onDragWillAccept != null) {
      // Build a temporary drop details for validation
      final event = dragData.event;

      // Determine type conversion
      String? typeConversion;
      if (event.isAllDay &&
          (proposedStart.hour != 0 || proposedStart.minute != 0)) {
        typeConversion = 'allDayToTimed';
      } else if (!event.isAllDay &&
          proposedStart.hour == 0 &&
          proposedStart.minute == 0) {
        typeConversion = 'timedToAllDay';
      }

      final details = MCalEventDroppedDetails(
        event: event,
        oldStartDate: event.start,
        oldEndDate: event.end,
        newStartDate: proposedStart,
        newEndDate: proposedEnd,
        isRecurring: event.recurrenceRule != null,
        seriesId: event.recurrenceRule != null ? event.id : null,
        typeConversion: typeConversion,
      );
      if (!widget.onDragWillAccept!(details)) {
        return false;
      }
    }

    // Check overlap with blocked time regions
    for (final region in widget.specialTimeRegions) {
      if (region.blockInteraction &&
          region.overlaps(proposedStart, proposedEnd)) {
        return false;
      }
    }

    // Check minDate boundary
    if (widget.minDate != null) {
      final minDate = DateTime(
        widget.minDate!.year,
        widget.minDate!.month,
        widget.minDate!.day,
      );
      final proposedDate = DateTime(
        proposedStart.year,
        proposedStart.month,
        proposedStart.day,
      );
      if (proposedDate.isBefore(minDate)) {
        return false;
      }
    }

    // Check maxDate boundary
    if (widget.maxDate != null) {
      final maxDate = DateTime(
        widget.maxDate!.year,
        widget.maxDate!.month,
        widget.maxDate!.day,
      );
      final proposedDate = DateTime(
        proposedStart.year,
        proposedStart.month,
        proposedStart.day,
      );
      if (proposedDate.isAfter(maxDate)) {
        return false;
      }
    }

    return true;
  }

  /// Applies configured snapping to a time.
  ///
  /// Checks snapping options in priority order:
  /// 1. snapToOtherEvents: snap to nearby event boundaries
  /// 2. snapToCurrentTime: snap to current time if within range
  /// 3. snapToTimeSlots: snap to time slot boundaries
  ///
  /// Returns the snapped time.
  DateTime _applySnapping(DateTime time) {
    // Priority 1: Snap to other event boundaries
    if (widget.snapToOtherEvents) {
      final nearbyBoundary = _findNearbyEventBoundary(time);
      if (nearbyBoundary != null) {
        return nearbyBoundary;
      }
    }

    // Priority 2: Snap to current time
    if (widget.snapToCurrentTime) {
      final now = DateTime.now();
      if (isWithinSnapRange(time, now, widget.snapRange)) {
        // Return snapped to current time on the same date
        return DateTime(time.year, time.month, time.day, now.hour, now.minute);
      }
    }

    // Priority 3: Snap to time slots
    if (widget.snapToTimeSlots) {
      return snapToTimeSlot(
        time: time,
        timeSlotDuration: widget.timeSlotDuration,
      );
    }

    // No snapping
    return time;
  }

  /// Finds a nearby event boundary within snap range.
  ///
  /// Searches all timed events for start/end times within [snapRange]
  /// of the given [time]. Returns the closest boundary or null if none found.
  DateTime? _findNearbyEventBoundary(DateTime time) {
    final nearbyTimes = <DateTime>[];

    // Collect all event start and end times from timed events
    for (final event in _timedEvents) {
      // Skip the event being dragged
      final dragData = _latestDragDetails?.data;
      if (dragData != null && event.id == dragData.event.id) {
        continue;
      }

      nearbyTimes.add(event.start);
      nearbyTimes.add(event.end);
    }

    // Use the snapToNearbyTime utility to find the closest
    if (nearbyTimes.isEmpty) return null;

    final snapped = snapToNearbyTime(
      time: time,
      nearbyTimes: nearbyTimes,
      snapRange: widget.snapRange,
    );

    // Return null if no snapping occurred
    return snapped == time ? null : snapped;
  }

  /// Handles drag leave events from the unified DragTarget.
  ///
  /// Cancels the debounce timer and clears stale drag details to prevent
  /// a pending [_processDragMove] from re-creating drop indicators after
  /// they've been cleared. Then clears the proposed drop range so drop
  /// indicators disappear.
  ///
  /// NOTE: DragTarget.onLeave fires BEFORE onAcceptWithDetails when a drop
  /// is accepted. This is safe because [_handleDrop] sets fresh
  /// [_latestDragDetails] and calls [_processDragMove] to recalculate
  /// the proposed range from scratch before reading proposed dates.
  void _handleDragLeave() {
    debugPrint('[DD] DragLeave: isDragActive=$_isDragActive');
    _isDragTargetActive = false;
    // Do NOT clear the proposed drop range here — the fallback pointer handler
    // will continue calling _processDragMove with live positions so the drop
    // preview keeps tracking the tile center even when the tile's left edge
    // exits the DragTarget boundary.

    if (!_isDragActive) {
      _dragMoveDebounceTimer?.cancel();
      _dragMoveDebounceTimer = null;
      _latestDragDetails = null;
    }
  }

  /// Handles drop events from the unified DragTarget.
  ///
  /// Processes the drop, invokes callbacks, and updates the controller with
  /// the new event position. Supports type conversion and recurring events.
  void _handleDrop(DragTargetDetails<MCalDragData> details) {
    final dragHandler = _dragHandler;

    debugPrint(
      '[DD] HandleDrop ENTRY: offset=${details.offset} isDragging=${dragHandler?.isDragging} isNearEdge=${dragHandler?.debugIsNearEdge} edgeTimerActive=${dragHandler?.debugEdgeTimerActive} vertScrollTimerActive=${_verticalScrollTimer?.isActive}',
    );

    // Cancel edge navigation and vertical scroll immediately.
    dragHandler?.cancelEdgeNavigation();
    _cancelVerticalScrollTimer();
    debugPrint(
      '[DD] HandleDrop: after cancel timers — edgeTimerActive=${dragHandler?.debugEdgeTimerActive}',
    );

    // Set drop-processing flag so _processDragMove skips edge detection.
    _isProcessingDrop = true;

    // Flush any pending local debounce timer and process immediately.
    // Force a fresh layout cache so the final time computation uses the
    // current page's coordinates (not stale values from before a page nav).
    if (_dragMoveDebounceTimer?.isActive ?? false) {
      _dragMoveDebounceTimer?.cancel();
    }
    _latestDragDetails = details;
    _layoutCachedForDrag = false;
    _processDragMove();
    debugPrint(
      '[DD] HandleDrop: after _processDragMove — edgeTimerActive=${dragHandler?.debugEdgeTimerActive} isNearEdge=${dragHandler?.debugIsNearEdge} vertScrollTimerActive=${_verticalScrollTimer?.isActive}',
    );

    // Check if drop is valid
    if (dragHandler != null && !dragHandler.isProposedDropValid) {
      debugPrint('[DD] HandleDrop: drop is INVALID — calling cancelDrag()');
      dragHandler.cancelDrag();
      _isProcessingDrop = false;
      return;
    }

    final dragData = details.data;
    final event = dragData.event;

    final proposedStart = dragHandler?.proposedStartDate;
    final proposedEnd = dragHandler?.proposedEndDate;

    if (proposedStart == null || proposedEnd == null) {
      debugPrint('[DD] HandleDrop: no proposed dates — cancelling');
      dragHandler?.cancelDrag();
      _isProcessingDrop = false;
      return;
    }

    // Sanity check: proposed date should match the currently displayed day.
    // If a stale edge navigation changed _displayDate after the last valid
    // _processDragMove, the proposed dates could belong to the wrong day.
    final proposedDay = DateTime(
      proposedStart.year,
      proposedStart.month,
      proposedStart.day,
    );
    if (!event.isAllDay && proposedDay != _displayDate) {
      debugPrint(
        '[DD] HandleDrop: proposed day $proposedDay ≠ displayDate $_displayDate — correcting to displayDate',
      );
      final correctedStart = DateTime(
        _displayDate.year,
        _displayDate.month,
        _displayDate.day,
        proposedStart.hour,
        proposedStart.minute,
      );
      final duration = proposedEnd.difference(proposedStart);
      final correctedEnd = correctedStart.add(duration);
      dragHandler?.updateProposedDropRange(
        proposedStart: correctedStart,
        proposedEnd: correctedEnd,
        isValid: _validateDrop(
          proposedStart: correctedStart,
          proposedEnd: correctedEnd,
        ),
        preserveTime: true,
      );
    }

    // Re-read proposed dates (may have been corrected above).
    final finalStart = dragHandler?.proposedStartDate ?? proposedStart;
    final finalEnd = dragHandler?.proposedEndDate ?? proposedEnd;

    String? typeConversion;
    if (event.isAllDay && (finalStart.hour != 0 || finalStart.minute != 0)) {
      typeConversion = 'allDayToTimed';
    } else if (!event.isAllDay &&
        finalStart.hour == 0 &&
        finalStart.minute == 0) {
      typeConversion = 'timedToAllDay';
    }

    final updatedEvent = MCalCalendarEvent(
      id: event.id,
      title: event.title,
      start: finalStart,
      end: finalEnd,
      isAllDay:
          typeConversion == 'timedToAllDay' ||
          (typeConversion == null && event.isAllDay),
      color: event.color,
      comment: event.comment,
      externalId: event.externalId,
      occurrenceId: event.occurrenceId,
      recurrenceRule: event.recurrenceRule,
    );

    final dropDetails = MCalEventDroppedDetails(
      event: event,
      oldStartDate: event.start,
      oldEndDate: event.end,
      newStartDate: finalStart,
      newEndDate: finalEnd,
      isRecurring: event.recurrenceRule != null,
      seriesId: event.recurrenceRule != null ? event.id : null,
      typeConversion: typeConversion,
    );

    debugPrint(
      '[DD] HandleDrop: finalStart=$finalStart finalEnd=$finalEnd displayDate=$_displayDate typeConversion=$typeConversion',
    );

    if (event.recurrenceRule != null) {
      if (widget.onEventDropped != null) {
        final shouldKeep = widget.onEventDropped!(context, dropDetails);
        if (shouldKeep) {
          widget.controller.modifyOccurrence(
            event.id,
            event.start,
            updatedEvent,
          );
        }
      } else {
        widget.controller.modifyOccurrence(event.id, event.start, updatedEvent);
      }
    } else {
      widget.controller.addEvents([updatedEvent]);

      if (widget.onEventDropped != null) {
        final shouldKeep = widget.onEventDropped!(context, dropDetails);
        if (!shouldKeep) {
          final revertedEvent = event.copyWith(
            start: event.start,
            end: event.end,
          );
          widget.controller.addEvents([revertedEvent]);
        }
      }
    }

    debugPrint(
      '[DD] HandleDrop: calling cancelDrag() to complete — edgeTimerActive=${dragHandler?.debugEdgeTimerActive} vertScrollTimerActive=${_verticalScrollTimer?.isActive}',
    );
    dragHandler?.cancelDrag();

    // Clear all drag state immediately so the overlays disappear in this frame.
    // _handleDragEnded will fire later via Flutter's gesture pipeline but will
    // see _isDragActive=false and return early — no double-reset.
    _resetDragState();

    debugPrint(
      '[DD] HandleDrop EXIT: after cancelDrag — edgeTimerActive=${dragHandler?.debugEdgeTimerActive} vertScrollTimerActive=${_verticalScrollTimer?.isActive}',
    );

    setState(() {});

    if (mounted) {
      final locale = widget.locale ?? Localizations.localeOf(context);
      final dateStr = DateFormat.yMMMMEEEEd(
        locale.toString(),
      ).format(finalStart);
      final timeStr = DateFormat.Hm(locale.toString()).format(finalStart);
      _announceScreenReader(
        context,
        'Moved ${event.title} to $timeStr on $dateStr',
      );
    }
  }

  /// Completes a drop using the last proposed range when the DragTarget's
  /// `onAcceptWithDetails` was not called (because the pointer left the
  /// target bounds). The proposed range was set by `_processDragMove` or
  /// `_handleDragPointerMove` and is still valid.
  void _completePendingDrop() {
    final dragHandler = _dragHandler;
    final dragData = _latestDragDetails?.data;
    if (dragHandler == null || dragData == null) {
      debugPrint(
        '[DD] CompletePendingDrop: no dragHandler or dragData — cancelling',
      );
      dragHandler?.cancelDrag();
      return;
    }

    final proposedStart = dragHandler.proposedStartDate;
    final proposedEnd = dragHandler.proposedEndDate;
    if (proposedStart == null || proposedEnd == null) {
      debugPrint('[DD] CompletePendingDrop: no proposed dates — cancelling');
      dragHandler.cancelDrag();
      return;
    }

    final event = dragData.event;

    // Correct proposed day to match displayed day if needed.
    final proposedDay = DateTime(
      proposedStart.year,
      proposedStart.month,
      proposedStart.day,
    );
    DateTime finalStart = proposedStart;
    DateTime finalEnd = proposedEnd;
    if (!event.isAllDay && proposedDay != _displayDate) {
      debugPrint(
        '[DD] CompletePendingDrop: proposed day $proposedDay ≠ displayDate $_displayDate — correcting',
      );
      finalStart = DateTime(
        _displayDate.year,
        _displayDate.month,
        _displayDate.day,
        proposedStart.hour,
        proposedStart.minute,
      );
      final duration = proposedEnd.difference(proposedStart);
      finalEnd = finalStart.add(duration);
    }

    String? typeConversion;
    if (event.isAllDay && (finalStart.hour != 0 || finalStart.minute != 0)) {
      typeConversion = 'allDayToTimed';
    } else if (!event.isAllDay &&
        finalStart.hour == 0 &&
        finalStart.minute == 0) {
      typeConversion = 'timedToAllDay';
    }

    final updatedEvent = MCalCalendarEvent(
      id: event.id,
      title: event.title,
      start: finalStart,
      end: finalEnd,
      isAllDay:
          typeConversion == 'timedToAllDay' ||
          (typeConversion == null && event.isAllDay),
      color: event.color,
      comment: event.comment,
      externalId: event.externalId,
      occurrenceId: event.occurrenceId,
      recurrenceRule: event.recurrenceRule,
    );

    final dropDetails = MCalEventDroppedDetails(
      event: event,
      oldStartDate: event.start,
      oldEndDate: event.end,
      newStartDate: finalStart,
      newEndDate: finalEnd,
      isRecurring: event.recurrenceRule != null,
      seriesId: event.recurrenceRule != null ? event.id : null,
      typeConversion: typeConversion,
    );

    debugPrint(
      '[DD] CompletePendingDrop: finalStart=$finalStart finalEnd=$finalEnd displayDate=$_displayDate typeConversion=$typeConversion',
    );

    if (event.recurrenceRule != null) {
      if (widget.onEventDropped != null) {
        final shouldKeep = widget.onEventDropped!(context, dropDetails);
        if (shouldKeep) {
          widget.controller.modifyOccurrence(
            event.id,
            event.start,
            updatedEvent,
          );
        }
      } else {
        widget.controller.modifyOccurrence(event.id, event.start, updatedEvent);
      }
    } else {
      widget.controller.addEvents([updatedEvent]);
      if (widget.onEventDropped != null) {
        final shouldKeep = widget.onEventDropped!(context, dropDetails);
        if (!shouldKeep) {
          widget.controller.addEvents([
            event.copyWith(start: event.start, end: event.end),
          ]);
        }
      }
    }

    dragHandler.cancelDrag();

    // Clear all drag state immediately so the overlays disappear in this frame.
    // The caller (_handleDragCancelled / _handleDragEnded) will also call
    // _resetDragState(), but those run later in Flutter's gesture pipeline and
    // will see _isDragActive=false and return early — no double-reset.
    _resetDragState();
    setState(() {});

    if (mounted) {
      final locale = widget.locale ?? Localizations.localeOf(context);
      final dateStr = DateFormat.yMMMMEEEEd(
        locale.toString(),
      ).format(finalStart);
      final timeStr = DateFormat.Hm(locale.toString()).format(finalStart);
      _announceScreenReader(
        context,
        'Moved ${event.title} to $timeStr on $dateStr',
      );
    }
  }

  // ============================================================================
  // Navigation Handlers
  // ============================================================================

  void _handleNavigatePrevious() {
    debugPrint(
      '[DD] NavigatePrevious CALLED at=${DateTime.now().toIso8601String()} from=${StackTrace.current.toString().split('\n').skip(1).take(3).join(' | ')}',
    );
    _layoutCachedForDrag = false;
    final previousDay = DateTime(
      _displayDate.year,
      _displayDate.month,
      _displayDate.day - 1,
    );
    widget.controller.setDisplayDate(previousDay);
    _schedulePostNavLayoutRefresh();
  }

  void _handleNavigateNext() {
    debugPrint(
      '[DD] NavigateNext CALLED at=${DateTime.now().toIso8601String()} from=${StackTrace.current.toString().split('\n').skip(1).take(3).join(' | ')}',
    );
    _layoutCachedForDrag = false;
    final nextDay = DateTime(
      _displayDate.year,
      _displayDate.month,
      _displayDate.day + 1,
    );
    widget.controller.setDisplayDate(nextDay);
    _schedulePostNavLayoutRefresh();
  }

  /// After a page navigation during drag, the new page's time grid
  /// hasn't laid out yet when `_cacheLayoutForDrag()` first runs. Schedule
  /// post-frame callbacks to invalidate the cache and retry until the new
  /// page's render objects are ready. The PageView animation can take several
  /// frames to complete, so we retry up to [_maxPostNavRetries] times.
  static const _maxPostNavRetries = 15;

  void _schedulePostNavLayoutRefresh([int attempt = 0]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isDragActive) return;
      _layoutCachedForDrag = false;

      final timeGridBox =
          _timeGridKey.currentContext?.findRenderObject() as RenderBox?;
      final isReady =
          timeGridBox != null &&
          timeGridBox.attached &&
          timeGridBox.size.width > 0;

      debugPrint(
        '[DD] PostNavLayoutRefresh(attempt=$attempt): isReady=$isReady timeGridSize=${timeGridBox?.size}',
      );

      if (!isReady && attempt < _maxPostNavRetries) {
        _schedulePostNavLayoutRefresh(attempt + 1);
        return;
      }

      if (!isReady) {
        debugPrint(
          '[DD] PostNavLayoutRefresh: EXHAUSTED retries — layout still not ready',
        );
        return;
      }

      if (_latestDragDetails != null) {
        _processDragMove();
      }

      // When the DragTarget has fired onLeave (e.g. leftward drag), the
      // stale _latestDragDetails can't supply a correct tileCenterX for edge
      // detection — _processDragMove guards against that. But the cursor is
      // typically stationary after navigation, so no new pointer events arrive
      // to trigger the fallback handler. Re-compute tileCenterX from the last
      // known fallback cursor position and explicitly re-check edge proximity.
      if (!_isDragTargetActive &&
          widget.dragEdgeNavigationEnabled &&
          _lastFallbackCursorGlobal != null &&
          _feedbackTileWidth > 0) {
        final cursorX = _lastFallbackCursorGlobal!.dx;
        final feedbackX = cursorX - _cachedGrabOffsetX;
        final tileCenterX = feedbackX + _feedbackTileWidth / 2;
        debugPrint(
          '[DD] PostNavEdgeRecheck: tileCenterX=$tileCenterX cursorX=$cursorX feedbackX=$feedbackX at=${DateTime.now().toIso8601String()}',
        );
        _checkEdgeProximity(tileCenterX);
      }
    });
  }

  void _handleNavigateToday() {
    // Navigate to today
    widget.controller.setDisplayDate(dateOnly(DateTime.now()));
  }

  // ============================================================================
  // Drop Target Preview and Overlay Layers (Task 21)
  // ============================================================================

  /// Builds the drop target preview layer (Layer 3).
  ///
  /// Shows a phantom event tile at the proposed drop position during drag.
  /// Uses [dropTargetTileBuilder] or default preview tile.
  /// Only visible when drag handler has valid proposed range.
  ///
  /// Wrapped in RepaintBoundary + IgnorePointer for performance and to avoid
  /// blocking gestures.
  Widget _buildDropTargetPreviewLayer(BuildContext context) {
    final dragHandler = _dragHandler;
    if (dragHandler == null ||
        dragHandler.proposedStartDate == null ||
        dragHandler.proposedEndDate == null) {
      return const SizedBox.shrink();
    }

    // During resize the real event tile already reflects the proposed bounds
    // (via _eventsForPageDate's copyWith replacement), so rendering a second
    // preview tile on top just creates visual noise.
    if (dragHandler.resizingEvent != null) {
      return const SizedBox.shrink();
    }

    final proposedStart = dragHandler.proposedStartDate!;
    final proposedEnd = dragHandler.proposedEndDate!;
    final draggedEvent = dragHandler.draggedEvent;
    final resizingEvent = dragHandler.resizingEvent;
    final event = draggedEvent ?? resizingEvent;

    if (event == null) {
      return const SizedBox.shrink();
    }

    // Calculate position using time utilities
    final topOffset = timeToOffset(
      time: proposedStart,
      startHour: widget.startHour,
      hourHeight: _cachedHourHeight > 0
          ? _cachedHourHeight
          : (widget.hourHeight ?? 80.0),
    );

    final height = durationToHeight(
      duration: proposedEnd.difference(proposedStart),
      hourHeight: _cachedHourHeight > 0
          ? _cachedHourHeight
          : (widget.hourHeight ?? 80.0),
    );

    // Create tile context for the phantom tile
    final tileContext = MCalTimedEventTileContext(
      event: event,
      displayDate: _displayDate,
      columnIndex: 0,
      totalColumns: 1,
      startTime: proposedStart,
      endTime: proposedEnd,
      isDropTargetPreview: true,
      dropValid: dragHandler.isProposedDropValid,
    );

    final defaultTile = Opacity(
      opacity: 0.5,
      child: Container(
        decoration: BoxDecoration(
          color: (event.color ?? Colors.blue).withValues(alpha: 0.3),
          border: Border.all(
            color: dragHandler.isProposedDropValid ? Colors.blue : Colors.red,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(4),
        child: Text(
          event.title,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    final tile = widget.dropTargetTileBuilder != null
        ? widget.dropTargetTileBuilder!(
            context,
            event,
            tileContext,
            defaultTile,
          )
        : defaultTile;

    return Stack(
      children: [
        Positioned(
          top: topOffset,
          left: 0,
          right: 0,
          height: height,
          child: tile,
        ),
      ],
    );
  }

  /// Builds the drop target overlay layer (Layer 4).
  ///
  /// Highlights the time slot range being targeted with a semi-transparent
  /// colored overlay (blue if valid, red if invalid).
  /// Uses [dropTargetOverlayBuilder] or default CustomPainter.
  ///
  /// Wrapped in RepaintBoundary + IgnorePointer for performance.
  Widget _buildDropTargetOverlayLayer(BuildContext context) {
    final dragHandler = _dragHandler;
    if (dragHandler == null) {
      return const SizedBox.shrink();
    }

    final proposedStart = dragHandler.proposedStartDate;
    final proposedEnd = dragHandler.proposedEndDate;

    if (proposedStart == null || proposedEnd == null) {
      return const SizedBox.shrink();
    }

    final isValid = dragHandler.isProposedDropValid;

    // Calculate position using time utilities
    final topOffset = timeToOffset(
      time: proposedStart,
      startHour: widget.startHour,
      hourHeight: _cachedHourHeight > 0
          ? _cachedHourHeight
          : (widget.hourHeight ?? 80.0),
    );

    final height = durationToHeight(
      duration: proposedEnd.difference(proposedStart),
      hourHeight: _cachedHourHeight > 0
          ? _cachedHourHeight
          : (widget.hourHeight ?? 80.0),
    );

    final defaultOverlay = Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: (isValid ? Colors.blue : Colors.red).withValues(alpha: 0.2),
          border: Border(
            left: BorderSide(
              color: isValid ? Colors.blue : Colors.red,
              width: 3,
            ),
          ),
        ),
      ),
    );

    final draggedEvent = dragHandler.draggedEvent;
    final sourceDate = dragHandler.sourceDate;

    final Widget overlay;
    if (widget.dropTargetOverlayBuilder != null &&
        draggedEvent != null &&
        sourceDate != null) {
      final overlayDetails = MCalDayViewDropOverlayDetails(
        highlightedTimeSlots: [
          MCalTimeSlotRange(
            startTime: proposedStart,
            endTime: proposedEnd,
            topOffset: topOffset,
            height: height,
          ),
        ],
        draggedEvent: draggedEvent,
        proposedStartDate: proposedStart,
        proposedEndDate: proposedEnd,
        isValid: isValid,
        sourceDate: sourceDate,
      );
      overlay = widget.dropTargetOverlayBuilder!(
        context,
        overlayDetails,
        defaultOverlay,
      );
    } else {
      overlay = defaultOverlay;
    }

    return Stack(children: [overlay]);
  }

  /// Builds the time grid with Stack and optional DragTarget.
  ///
  /// Returns a Stack containing:
  /// - Layer 1+2: Main content (gridlines + regions + events + current time)
  /// Builds the scrollable content row containing the time legend and time
  /// grid.  Extracted so the DragTarget (which now wraps this entire
  /// area) and the non-drag path share the same widget tree.
  Widget _buildScrollableTimeGridContent(
    BuildContext context,
    Locale locale,
    DateTime date,
    List<MCalCalendarEvent> timedEvents,
  ) {
    // Each page gets its own scroll controller via _DayPageScroller:
    //  - Current page: uses _scrollController (for API compat — scrollToTime,
    //    drag handling, etc.).
    //  - Adjacent pages: get a fresh controller initialised to
    //    _lastKnownScrollOffset so the user sees the same vertical position
    //    during a swipe, with no delayed jump.
    final isCurrentPage =
        date.year == _displayDate.year &&
        date.month == _displayDate.month &&
        date.day == _displayDate.day;
    return _DayPageScroller(
      primaryController: isCurrentPage ? _scrollController : null,
      initialOffset: _lastKnownScrollOffset,
      physics: widget.scrollPhysics,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isLayoutRTL(context))
            _TimeLegendColumn(
              startHour: widget.startHour,
              endHour: widget.endHour,
              hourHeight: widget.hourHeight ?? 80.0,
              timeLabelFormat: widget.timeLabelFormat,
              timeLabelBuilder: widget.timeLabelBuilder,
              theme: _resolveTheme(context),
              locale: locale,
              onTimeLabelTap: widget.onTimeLabelTap,
              onTimeLabelLongPress: widget.onTimeLabelLongPress,
              onTimeLabelDoubleTap: widget.onTimeLabelDoubleTap,
              onHoverTimeLabel: widget.onHoverTimeLabel,
              displayDate: date,
              showSubHourLabels: widget.showSubHourLabels,
              subHourLabelInterval: widget.subHourLabelInterval,
              subHourLabelBuilder: widget.subHourLabelBuilder,
            ),
          Expanded(child: _buildTimeGrid(context, locale, date, timedEvents)),
          if (_isLayoutRTL(context))
            _TimeLegendColumn(
              startHour: widget.startHour,
              endHour: widget.endHour,
              hourHeight: widget.hourHeight ?? 80.0,
              timeLabelFormat: widget.timeLabelFormat,
              timeLabelBuilder: widget.timeLabelBuilder,
              theme: _resolveTheme(context),
              locale: locale,
              onTimeLabelTap: widget.onTimeLabelTap,
              onTimeLabelLongPress: widget.onTimeLabelLongPress,
              onTimeLabelDoubleTap: widget.onTimeLabelDoubleTap,
              onHoverTimeLabel: widget.onHoverTimeLabel,
              displayDate: date,
              showSubHourLabels: widget.showSubHourLabels,
              subHourLabelInterval: widget.subHourLabelInterval,
              subHourLabelBuilder: widget.subHourLabelBuilder,
            ),
        ],
      ),
    );
  }

  /// - Layer 3: Drop target preview (phantom tiles) when [showDropTargetTiles]
  /// - Layer 4: Drop target overlay (highlighted time slots) when [showDropTargetOverlay]
  ///
  /// Layer order is controlled by [dropTargetTilesAboveOverlay].
  Widget _buildTimeGrid(
    BuildContext context,
    Locale locale,
    DateTime date,
    List<MCalCalendarEvent> timedEvents,
  ) {
    final hourHeight = widget.hourHeight ?? 80.0;
    final contentHeight =
        (widget.endHour - widget.startHour).clamp(0, 24) * hourHeight;

    // Layer 1+2: Main content (gridlines + regions + events + current time)
    // Wrap gridlines in IgnorePointer when empty slot callbacks exist so taps
    // pass through to the GestureDetector for onTimeSlotTap/onTimeSlotLongPress.
    final hasEmptySlotCallbacksForLayer =
        widget.onTimeSlotTap != null ||
        widget.onTimeSlotLongPress != null ||
        widget.onTimeSlotDoubleTap != null;
    final gridlinesLayer = hasEmptySlotCallbacksForLayer
        ? IgnorePointer(
            child: _GridlinesLayer(
              startHour: widget.startHour,
              endHour: widget.endHour,
              hourHeight: hourHeight,
              gridlineInterval: widget.gridlineInterval,
              displayDate: date,
              theme: _resolveTheme(context),
              locale: locale,
              gridlineBuilder: widget.gridlineBuilder,
            ),
          )
        : _GridlinesLayer(
            startHour: widget.startHour,
            endHour: widget.endHour,
            hourHeight: hourHeight,
            gridlineInterval: widget.gridlineInterval,
            displayDate: date,
            theme: _resolveTheme(context),
            locale: locale,
            gridlineBuilder: widget.gridlineBuilder,
          );
    final mainContent = Stack(
      children: [
        gridlinesLayer,
        // Disabled time slots overlay (rendered with 0.5 opacity)
        if (widget.timeSlotInteractivityCallback != null)
          _DisabledTimeSlotsLayer(
            startHour: widget.startHour,
            endHour: widget.endHour,
            hourHeight: hourHeight,
            timeSlotDuration: widget.timeSlotDuration,
            displayDate: date,
            interactivityCallback: widget.timeSlotInteractivityCallback!,
          ),
        if (widget.specialTimeRegions.isNotEmpty)
          _TimeRegionsLayer(
            regions: widget.specialTimeRegions,
            displayDate: date,
            startHour: widget.startHour,
            endHour: widget.endHour,
            hourHeight: hourHeight,
            theme: _resolveTheme(context),
            timeRegionBuilder: widget.timeRegionBuilder,
          ),
        _TimeGridEventsLayer(
          events: timedEvents,
          displayDate: date,
          startHour: widget.startHour,
          endHour: widget.endHour,
          hourHeight: hourHeight,
          theme: _resolveTheme(context),
          timedEventTileBuilder: widget.timedEventTileBuilder,
          dayLayoutBuilder: widget.dayLayoutBuilder,
          onEventTap: _handleEventTap,
          onEventLongPress: widget.onEventLongPress,
          onEventDoubleTap: widget.onEventDoubleTap,
          keyboardFocusedEventId: _focusedEvent?.id,
          enableDragToMove: widget.enableDragToMove,
          enableDragToResize: _resolveDragToResize(),
          draggedTileBuilder: widget.draggedTileBuilder,
          dragSourceTileBuilder: widget.dragSourceTileBuilder,
          dragLongPressDelay: widget.dragLongPressDelay,
          onDragStarted: _handleDragStarted,
          onDragEnded: _handleDragEnded,
          onDragCancelled: _handleDragCancelled,
          timeResizeHandleBuilder: widget.timeResizeHandleBuilder,
          resizeHandleInset: widget.resizeHandleInset,
          onResizePointerDown: _handleResizePointerDownFromChild,
          onResizeStart: _handleResizeStart,
          onResizeUpdate: _handleResizeUpdate,
          onResizeEnd: _handleResizeEnd,
          onResizeCancel: _handleResizeCancel,
        ),
        if (widget.showCurrentTimeIndicator && isToday(date))
          _CurrentTimeIndicator(
            startHour: widget.startHour,
            endHour: widget.endHour,
            hourHeight: hourHeight,
            displayDate: date,
            theme: _resolveTheme(context),
            locale: locale,
            builder: widget.currentTimeIndicatorBuilder,
          ),
      ],
    );

    Widget buildFeedbackLayer({
      required bool enabled,
      required Widget Function(BuildContext) layerBuilder,
    }) {
      if (!enabled) return const SizedBox.shrink();
      return Positioned.fill(
        child: ListenableBuilder(
          listenable: _dragHandler ?? ValueNotifier(null),
          builder: (ctx, _) {
            return RepaintBoundary(
              child: IgnorePointer(child: layerBuilder(ctx)),
            );
          },
        ),
      );
    }

    final tilesLayer = buildFeedbackLayer(
      enabled: widget.showDropTargetTiles,
      layerBuilder: _buildDropTargetPreviewLayer,
    );
    final overlayLayer = buildFeedbackLayer(
      enabled: widget.showDropTargetOverlay,
      layerBuilder: _buildDropTargetOverlayLayer,
    );

    final firstLayer = widget.dropTargetTilesAboveOverlay
        ? overlayLayer
        : tilesLayer;
    final secondLayer = widget.dropTargetTilesAboveOverlay
        ? tilesLayer
        : overlayLayer;

    final stack = Stack(children: [mainContent, firstLayer, secondLayer]);

    // Wrap in GestureDetector for empty time slot tap/long-press/double-tap (Task 28)
    final hasEmptySlotCallbacks =
        widget.onTimeSlotTap != null ||
        widget.onTimeSlotLongPress != null ||
        widget.onTimeSlotDoubleTap != null;
    final dateStr = DateFormat.yMMMMEEEEd(
      locale.toString(),
    ).format(_displayDate);
    final l10n = mcalL10n(context);
    final scheduleLabel = l10n.scheduleFor(dateStr);
    final doubleTapHint = l10n.doubleTapToCreateEvent;
    final gestureChild = hasEmptySlotCallbacks
        ? GestureDetector(
            key: const ValueKey('day_view_schedule'),
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) =>
                _lastDoubleTapDownPosition = details.localPosition,
            onTapUp: (details) =>
                _handleTimeSlotTap(details.localPosition, hourHeight),
            onLongPressStart: (details) =>
                _handleTimeSlotLongPress(details.localPosition, hourHeight),
            onDoubleTapDown: (details) =>
                _lastDoubleTapDownPosition = details.localPosition,
            onDoubleTap: () => _handleTimeSlotDoubleTap(hourHeight),
            child: Semantics(
              label: scheduleLabel,
              hint: doubleTapHint,
              child: ColoredBox(color: Colors.transparent, child: stack),
            ),
          )
        : Semantics(label: scheduleLabel, container: true, child: stack);

    // Attach _timeGridKey to this SizedBox which always has the full
    // time grid dimensions (contentHeight x full width), even when the page
    // has no events.  The key is only on the active page to avoid GlobalKey
    // duplication across PageView pre-built pages.
    final isCurrentPage =
        date.year == _displayDate.year &&
        date.month == _displayDate.month &&
        date.day == _displayDate.day;
    return SizedBox(
      key: isCurrentPage ? _timeGridKey : null,
      height: contentHeight,
      child: gestureChild,
    );
  }

  /// Builds the semantic label for the drop target when drag/resize is active.
  ///
  /// Announces the proposed time range and validity to screen readers.
  /// Returns null when there is no drop target state to announce.
  String? _buildDropTargetSemanticLabel(BuildContext context) {
    final dragHandler = _dragHandler;
    if (dragHandler == null) return null;

    final proposedStart = dragHandler.proposedStartDate;
    final proposedEnd = dragHandler.proposedEndDate;
    if (proposedStart == null || proposedEnd == null) return null;

    if (!_isDragActive && !_isResizeActive) return null;

    final locale = widget.locale ?? Localizations.localeOf(context);
    final l10n = mcalL10n(context);
    final prefix = l10n.dropTargetPrefix;
    final validStr = dragHandler.isProposedDropValid
        ? l10n.dropTargetValid
        : l10n.dropTargetInvalid;

    final startTimeStr = DateFormat.Hm(locale.toString()).format(proposedStart);
    final endTimeStr = DateFormat.Hm(locale.toString()).format(proposedEnd);

    return '$prefix, $startTimeStr to $endTimeStr, $validStr';
  }

  /// Handles tap on empty time slot area.
  ///
  /// Converts tap position to DateTime using [offsetToTime], checks that the
  /// tap did not hit an event (event taps take precedence), and fires
  /// [onTimeSlotTap] callback if provided.
  void _handleTimeSlotTap(Offset localPosition, double hourHeight) {
    if (widget.onTimeSlotTap == null) return;

    // Don't fire if tap hit an event (event tap takes precedence)
    if (_didTapHitEvent(localPosition, hourHeight)) return;

    final tappedTime = snapToTimeSlot(
      time: offsetToTime(
        offset: localPosition.dy,
        date: _displayDate,
        startHour: widget.startHour,
        hourHeight: hourHeight,
      ),
      timeSlotDuration: widget.timeSlotDuration,
    );

    // Check interactivity before processing tap
    if (widget.timeSlotInteractivityCallback != null) {
      final slotEndTime = tappedTime.add(widget.timeSlotDuration);
      final interactivityDetails = MCalTimeSlotInteractivityDetails(
        date: dateOnly(_displayDate),
        hour: tappedTime.hour,
        minute: tappedTime.minute,
        startTime: tappedTime,
        endTime: slotEndTime,
      );
      final isInteractive = widget.timeSlotInteractivityCallback!(
        context,
        interactivityDetails,
      );
      if (!isInteractive) return; // Early return if slot is not interactive
    }

    final slotContext = MCalTimeSlotContext(
      displayDate: _displayDate,
      hour: tappedTime.hour,
      minute: tappedTime.minute,
      offset: localPosition.dy,
      isAllDayArea: false,
    );

    widget.onTimeSlotTap!(context, slotContext);
  }

  /// Handles long-press on empty time slot area.
  ///
  /// Same logic as [_handleTimeSlotTap] but for long-press, firing
  /// [onTimeSlotLongPress] callback.
  void _handleTimeSlotLongPress(Offset localPosition, double hourHeight) {
    if (widget.onTimeSlotLongPress == null) return;

    if (_didTapHitEvent(localPosition, hourHeight)) return;

    final tappedTime = snapToTimeSlot(
      time: offsetToTime(
        offset: localPosition.dy,
        date: _displayDate,
        startHour: widget.startHour,
        hourHeight: hourHeight,
      ),
      timeSlotDuration: widget.timeSlotDuration,
    );

    // Check interactivity before processing long-press
    if (widget.timeSlotInteractivityCallback != null) {
      final slotEndTime = tappedTime.add(widget.timeSlotDuration);
      final interactivityDetails = MCalTimeSlotInteractivityDetails(
        date: dateOnly(_displayDate),
        hour: tappedTime.hour,
        minute: tappedTime.minute,
        startTime: tappedTime,
        endTime: slotEndTime,
      );
      final isInteractive = widget.timeSlotInteractivityCallback!(
        context,
        interactivityDetails,
      );
      if (!isInteractive) return; // Early return if slot is not interactive
    }

    final slotContext = MCalTimeSlotContext(
      displayDate: _displayDate,
      hour: tappedTime.hour,
      minute: tappedTime.minute,
      offset: localPosition.dy,
      isAllDayArea: false,
    );

    widget.onTimeSlotLongPress!(context, slotContext);
  }

  /// Handles double-tap on empty time slot area.
  ///
  /// Uses [_lastDoubleTapDownPosition] stored from [onDoubleTapDown] since
  /// [onDoubleTap] does not receive position. Converts position to DateTime
  /// using [offsetToTime], checks that the tap did not hit an event, and
  /// fires [onTimeSlotDoubleTap] callback.
  void _handleTimeSlotDoubleTap(double hourHeight) {
    if (widget.onTimeSlotDoubleTap == null) return;

    final localPosition = _lastDoubleTapDownPosition;
    if (localPosition == null) return;

    // Don't fire if tap hit an event (event tap takes precedence)
    if (_didTapHitEvent(localPosition, hourHeight)) return;

    final tappedTime = snapToTimeSlot(
      time: offsetToTime(
        offset: localPosition.dy,
        date: _displayDate,
        startHour: widget.startHour,
        hourHeight: hourHeight,
      ),
      timeSlotDuration: widget.timeSlotDuration,
    );

    // Check interactivity before processing double-tap
    if (widget.timeSlotInteractivityCallback != null) {
      final slotEndTime = tappedTime.add(widget.timeSlotDuration);
      final interactivityDetails = MCalTimeSlotInteractivityDetails(
        date: dateOnly(_displayDate),
        hour: tappedTime.hour,
        minute: tappedTime.minute,
        startTime: tappedTime,
        endTime: slotEndTime,
      );
      final isInteractive = widget.timeSlotInteractivityCallback!(
        context,
        interactivityDetails,
      );
      if (!isInteractive) return; // Early return if slot is not interactive
    }

    // Build full MCalTimeSlotContext
    final slotContext = MCalTimeSlotContext(
      displayDate: _displayDate,
      hour: tappedTime.hour,
      minute: tappedTime.minute,
      offset: localPosition.dy,
      isAllDayArea: false,
    );

    widget.onTimeSlotDoubleTap!(context, slotContext);
  }

  /// Checks if the tap position overlaps with any event tile.
  ///
  /// Event taps take precedence over empty slot taps. Events have their own
  /// GestureDetectors which typically consume taps, but this provides a
  /// fallback check for edge cases.
  bool _didTapHitEvent(Offset localPosition, double hourHeight) {
    if (_timedEvents.isEmpty) return false;

    final renderBox =
        _timeGridKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return false;

    final areaWidth = renderBox.size.width;
    final eventsWithColumns = detectOverlapsAndAssignColumns(_timedEvents);

    for (final eventWithColumn in eventsWithColumns) {
      final event = eventWithColumn.event;
      final totalColumns = eventWithColumn.totalColumns;
      final columnIndex = eventWithColumn.columnIndex;

      final topOffset = timeToOffset(
        time: event.start,
        startHour: widget.startHour,
        hourHeight: hourHeight,
      );
      final height = durationToHeight(
        duration: event.end.difference(event.start),
        hourHeight: hourHeight,
      );
      final columnWidth = areaWidth / totalColumns;
      final left = columnIndex * columnWidth;

      if (localPosition.dy >= topOffset &&
          localPosition.dy <= topOffset + height &&
          localPosition.dx >= left &&
          localPosition.dx <= left + columnWidth) {
        return true;
      }
    }
    return false;
  }

  /// Builds the default keyboard shortcuts map.
  Map<ShortcutActivator, Intent> _buildDefaultShortcuts() {
    return <ShortcutActivator, Intent>{
      // Cmd/Ctrl+N: Create new event
      const SingleActivator(LogicalKeyboardKey.keyN, control: true):
          MCalDayViewCreateEventIntent(),
      const SingleActivator(LogicalKeyboardKey.keyN, meta: true):
          MCalDayViewCreateEventIntent(),
      // Cmd/Ctrl+D: Delete focused event
      const SingleActivator(LogicalKeyboardKey.keyD, control: true):
          MCalDayViewDeleteEventIntent(),
      const SingleActivator(LogicalKeyboardKey.keyD, meta: true):
          MCalDayViewDeleteEventIntent(),
      // Cmd/Ctrl+E: Edit focused event
      const SingleActivator(LogicalKeyboardKey.keyE, control: true):
          MCalDayViewEditEventIntent(),
      const SingleActivator(LogicalKeyboardKey.keyE, meta: true):
          MCalDayViewEditEventIntent(),
      // Delete/Backspace: Delete focused event
      const SingleActivator(LogicalKeyboardKey.delete):
          MCalDayViewDeleteEventIntent(),
      const SingleActivator(LogicalKeyboardKey.backspace):
          MCalDayViewDeleteEventIntent(),
      // Ctrl/Cmd+M: Keyboard move mode
      const SingleActivator(LogicalKeyboardKey.keyM, control: true):
          MCalDayViewKeyboardMoveIntent(),
      const SingleActivator(LogicalKeyboardKey.keyM, meta: true):
          MCalDayViewKeyboardMoveIntent(),
      // Ctrl/Cmd+R: Keyboard resize mode
      const SingleActivator(LogicalKeyboardKey.keyR, control: true):
          MCalDayViewKeyboardResizeIntent(),
      const SingleActivator(LogicalKeyboardKey.keyR, meta: true):
          MCalDayViewKeyboardResizeIntent(),
    };
  }

  /// Builds the merged shortcuts map (defaults + user overrides).
  Map<ShortcutActivator, Intent> _buildShortcutsMap() {
    final shortcuts = Map<ShortcutActivator, Intent>.from(
      _buildDefaultShortcuts(),
    );
    if (widget.keyboardShortcuts != null) {
      shortcuts.addAll(widget.keyboardShortcuts!);
    }
    return shortcuts;
  }

  /// Builds the Actions map for keyboard shortcut intents.
  Map<Type, Action<Intent>> _buildActionsMap() {
    return <Type, Action<Intent>>{
      MCalDayViewCreateEventIntent:
          CallbackAction<MCalDayViewCreateEventIntent>(
            onInvoke: (_) {
              widget.onCreateEventRequested?.call();
              return null;
            },
          ),
      MCalDayViewDeleteEventIntent:
          CallbackAction<MCalDayViewDeleteEventIntent>(
            onInvoke: (_) {
              final event = _focusedEvent;
              if (event != null) {
                widget.onDeleteEventRequested?.call(event);
              }
              return null;
            },
          ),
      MCalDayViewEditEventIntent: CallbackAction<MCalDayViewEditEventIntent>(
        onInvoke: (_) {
          final event = _focusedEvent;
          if (event != null) {
            widget.onEditEventRequested?.call(event);
          }
          return null;
        },
      ),
      MCalDayViewKeyboardMoveIntent:
          CallbackAction<MCalDayViewKeyboardMoveIntent>(
            onInvoke: (_) {
              _enterKeyboardMoveMode();
              return null;
            },
          ),
      MCalDayViewKeyboardResizeIntent:
          CallbackAction<MCalDayViewKeyboardResizeIntent>(
            onInvoke: (_) {
              _enterKeyboardResizeMode();
              return null;
            },
          ),
    };
  }

  // ============================================================================
  // Default Builder Methods (Task 10)
  // ============================================================================

  /// Builds the default loading widget.
  Widget _buildDefaultLoading(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }

  /// Builds the default error widget.
  Widget _buildDefaultError(BuildContext context, Object error) {
    return Center(child: Text('Error: $error'));
  }

  // ============================================================================
  // Build Helper Methods (Task 8)
  // ============================================================================

  /// Builds the day view content for a specific date.
  ///
  /// This method is called either directly (when swipe navigation is disabled)
  /// or by the PageView.builder (when swipe navigation is enabled).
  ///
  /// [date] - The date to display
  /// [locale] - The locale for date/time formatting
  Widget _buildDayContent(DateTime date, Locale locale) {
    // Resolve events for this specific page date. Adjacent pages pre-built by
    // PageView must show their own day's events, not the cached display-date events.
    final pageEvents = _eventsForPageDate(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day Header
        _DayHeader(
          displayDate: date,
          showWeekNumbers: widget.showWeekNumbers,
          firstDayOfWeek: widget.controller.resolvedFirstDayOfWeek,
          theme: _resolveTheme(context),
          locale: locale,
          textDirection: Directionality.of(context),
          dayHeaderBuilder: widget.dayHeaderBuilder,
          weekNumberBuilder: widget.weekNumberBuilder,
          onTap: widget.onDayHeaderTap != null
              ? () => widget.onDayHeaderTap!(context, date)
              : null,
          onLongPress: widget.onDayHeaderLongPress != null
              ? () => widget.onDayHeaderLongPress!(context, date)
              : null,
          onDoubleTap: widget.onDayHeaderDoubleTap != null
              ? () => widget.onDayHeaderDoubleTap!(
                  context,
                  MCalDayHeaderContext(
                    date: date,
                    weekNumber: widget.showWeekNumbers
                        ? getWeekNumber(
                            date,
                            widget.controller.resolvedFirstDayOfWeek,
                          )
                        : null,
                  ),
                )
              : null,
          onHover: widget.onHoverDayHeader,
        ),

        // All-Day Events Section
        if (pageEvents.allDay.isNotEmpty)
          _AllDayEventsSection(
            events: pageEvents.allDay,
            displayDate: date,
            maxRows: widget.allDaySectionMaxRows,
            theme: _resolveTheme(context),
            locale: locale,
            allDayEventTileBuilder: widget.allDayEventTileBuilder,
            enableDragToMove: widget.enableDragToMove,
            dragHandler: _dragHandler,
            isDragActive: _isDragActive,
            onEventTap: _handleEventTap,
            onEventLongPress: widget.onEventLongPress,
            onEventDoubleTap: widget.onEventDoubleTap,
            keyboardFocusedEventId: _focusedEvent?.id,
            onOverflowTap: widget.onOverflowTap,
            onOverflowLongPress: widget.onOverflowLongPress,
            onOverflowDoubleTap: widget.onOverflowDoubleTap,
            onTimeSlotTap: widget.onTimeSlotTap,
            onTimeSlotLongPress: widget.onTimeSlotLongPress,
            onDragStarted: _handleDragStarted,
            onDragEnded: _handleDragEnded,
            onDragCancelled: _handleDragCancelled,
            draggedTileBuilder: widget.draggedTileBuilder,
            dragSourceTileBuilder: widget.dragSourceTileBuilder,
            dragLongPressDelay: widget.dragLongPressDelay,
          ),

        // Main content area with Time Legend and Events.
        Expanded(
          child: _buildScrollableTimeGridContent(
            context,
            locale,
            date,
            pageEvents.timed,
          ),
        ),
      ],
    );
  }

  /// Builds the main Column containing the navigator and day content.
  /// Extracted so both the DragTarget and non-drag paths can share it.
  Widget _buildMainColumn(Locale locale, Widget dayViewContent) {
    return Column(
      children: [
        if (widget.showNavigator)
          _DayNavigator(
            displayDate: _displayDate,
            minDate: widget.minDate,
            maxDate: widget.maxDate,
            theme: _resolveTheme(context),
            navigatorBuilder: widget.navigatorBuilder,
            locale: locale,
            onPrevious: _handleNavigatePrevious,
            onNext: _handleNavigateNext,
            onToday: _handleNavigateToday,
          ),
        Expanded(key: _dayContentKey, child: dayViewContent),
      ],
    );
  }

  /// Debug overlays: translucent green rectangles showing the left and right
  /// edge navigation trigger zones (each 25% of the time grid width).
  /// Day navigation arms when the tile's center enters a green zone.
  /// Only rendered when [_isDragActive] is true.
  /// [stackContext] is the [BuildContext] from the [DragTarget] builder —
  /// its [RenderBox] origin equals the Stack's top-left, which is the correct
  /// reference for all [Positioned] children inside the Stack.
  List<Widget> _buildEdgeZoneOverlays(BuildContext stackContext) {
    if (!_layoutCachedForDrag) return const [];

    // Use the DragTarget builder's RenderBox as the Stack coordinate origin.
    final stackBox = stackContext.findRenderObject() as RenderBox?;
    if (stackBox == null || !stackBox.attached) return const [];
    final stackGlobal = stackBox.localToGlobal(Offset.zero);
    final stackSize = stackBox.size;

    final timeGridWidth =
        _cachedTimeGridGlobalRight - _cachedTimeGridGlobalLeft;
    if (timeGridWidth <= 0) return const [];

    final edgeZoneWidth = timeGridWidth * _edgeZoneFraction;

    // Convert time grid global coords to Stack-local coords.
    final timeGridLocalLeft = _cachedTimeGridGlobalLeft - stackGlobal.dx;
    final timeGridLocalTop =
        (_cachedTimeGridGlobalTop + _cachedScrollOffset) - stackGlobal.dy;

    // Height spans from the top of the scroll viewport to the bottom of the
    // Stack (covers the entire visible time grid area).
    final overlayHeight = stackSize.height - timeGridLocalTop;

    const color = Color(0x3300CC00);

    return [
      // Left 25% zone — inside the time grid, left edge.
      Positioned(
        left: timeGridLocalLeft,
        top: timeGridLocalTop,
        width: edgeZoneWidth,
        height: overlayHeight,
        child: IgnorePointer(child: ColoredBox(color: color)),
      ),
      // Right 25% zone — inside the time grid, right edge.
      Positioned(
        left: timeGridLocalLeft + timeGridWidth - edgeZoneWidth,
        top: timeGridLocalTop,
        width: edgeZoneWidth,
        height: overlayHeight,
        child: IgnorePointer(child: ColoredBox(color: color)),
      ),
    ];
  }

  /// Debug overlays: translucent red rectangles showing the top and bottom
  /// vertical auto-scroll trigger zones (each [_vertEdgeThresholdPx] pixels
  /// tall, spanning the full time grid width).
  ///
  /// Scroll UP fires when the tile's **top** edge enters the top band.
  /// Scroll DOWN fires when the tile's **bottom** edge enters the bottom band.
  /// Only rendered when [_isDragActive] is true.
  ///
  /// [stackContext] is the [BuildContext] from the [DragTarget] builder —
  /// its [RenderBox] origin equals the Stack's top-left, which is the correct
  /// reference for all [Positioned] children inside the Stack.
  List<Widget> _buildScrollEdgeZoneOverlays(BuildContext stackContext) {
    if (!_layoutCachedForDrag) return const [];

    final sc = _scrollController;
    if (sc == null || !sc.hasClients) return const [];

    // Use the DragTarget builder's RenderBox as the Stack coordinate origin.
    // This is the correct origin for all Positioned children — it includes the
    // navigator height above _dayContentKey, which would otherwise shift bands.
    final stackBox = stackContext.findRenderObject() as RenderBox?;
    if (stackBox == null || !stackBox.attached) return const [];
    final stackGlobal = stackBox.localToGlobal(Offset.zero);

    final timeGridWidth =
        _cachedTimeGridGlobalRight - _cachedTimeGridGlobalLeft;
    if (timeGridWidth <= 0) return const [];

    final viewportHeight = sc.position.viewportDimension;

    // _timeGridKey sits on the scrollable content, so _cachedTimeGridGlobalTop
    // decreases as the user scrolls down. The viewport container is fixed:
    //   viewport_screen_top = _cachedTimeGridGlobalTop + _cachedScrollOffset
    // Convert that fixed global Y to Stack-local coords.
    final timeGridLocalLeft = _cachedTimeGridGlobalLeft - stackGlobal.dx;
    final viewportTopLocal =
        (_cachedTimeGridGlobalTop + _cachedScrollOffset) - stackGlobal.dy;
    final viewportBottomLocal = viewportTopLocal + viewportHeight;

    const color = Color(0x44FF0000);

    return [
      // Top threshold zone — tile's top edge entering here triggers scroll up.
      Positioned(
        left: timeGridLocalLeft,
        top: viewportTopLocal,
        width: timeGridWidth,
        height: _vertEdgeThresholdPx,
        child: IgnorePointer(child: ColoredBox(color: color)),
      ),
      // Bottom threshold zone — tile's bottom edge entering here triggers scroll down.
      Positioned(
        left: timeGridLocalLeft,
        top: viewportBottomLocal - _vertEdgeThresholdPx,
        width: timeGridWidth,
        height: _vertEdgeThresholdPx,
        child: IgnorePointer(child: ColoredBox(color: color)),
      ),
    ];
  }

  /// DEBUG: Draws a thick red vertical line at the tile center's horizontal
  /// position — this is the coordinate used for edge detection.
  /// The line spans the full day-content height.
  Widget? _buildTileCenterLine() {
    final center = _debugTileCenterGlobal;
    if (center == null || !_layoutCachedForDrag) return null;

    final dayContentBox =
        _dayContentKey.currentContext?.findRenderObject() as RenderBox?;
    if (dayContentBox == null || !dayContentBox.attached) return null;

    final dayContentGlobal = dayContentBox.localToGlobal(Offset.zero);
    final dayContentSize = dayContentBox.size;

    final localX = center.dx - dayContentGlobal.dx;
    final lineHeight = dayContentSize.height;

    return Positioned(
      left: localX - 1.5,
      top: 0.0,
      width: 3,
      height: lineHeight,
      child: IgnorePointer(child: ColoredBox(color: Color(0xFFFF0000))),
    );
  }

  // ============================================================================
  // Build Method
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale ?? Localizations.localeOf(context);
    // Resolve text and layout directions independently via the documented
    // priority chains. textDirection drives text rendering (the outer
    // Directionality wrapper). layoutDirection drives all visual layout logic
    // (time-legend side, navigation direction, drag edge detection) via the
    // MCalLayoutDirectionality InheritedWidget placed inside the wrapper.
    final textDirection = _resolveTextDirection(context);
    final layoutDirection = _resolveLayoutDirection(context);
    final enableKeyEvents =
        widget.enableKeyboardNavigation || widget.enableDragToMove;

    final enableResize = _resolveDragToResize();

    // Build the main day view content (with or without PageView)
    Widget dayViewContent;

    if (widget.enableSwipeNavigation && _swipePageController != null) {
      // Day view always uses horizontal swipe: vertical is already used
      // to scroll through hours of the day.
      // Disable PageView scrolling while a resize is active (matching Month View
      // pattern). During resize, raw Listener events are used instead of
      // LongPressDraggable, so the PageView would compete for horizontal pointer
      // events without this lock. For drag-to-move, LongPressDraggable already
      // claims the pointer exclusively so no lock is needed there.
      final isResizing = _dragHandler?.isResizing == true;
      dayViewContent = PageView.builder(
        controller: _swipePageController!,
        scrollDirection: Axis.horizontal,
        physics: isResizing
            ? const NeverScrollableScrollPhysics()
            : const MCalSnappyPageScrollPhysics(),
        // Never reverse: standard calendar convention (swipe left = next day,
        // swipe right = previous day) applies regardless of locale.
        reverse: false,
        scrollBehavior: const MCalMultiDeviceScrollBehavior(),
        onPageChanged: _onSwipePageChanged,
        itemBuilder: (context, index) {
          final pageDate = _pageIndexToDay(index);
          if (_isLoading) {
            final defaultWidget = _buildDefaultLoading(context);
            return widget.loadingBuilder != null
                ? widget.loadingBuilder!(context, defaultWidget)
                : defaultWidget;
          } else if (_error != null) {
            final defaultWidget = _buildDefaultError(context, _error!);
            return widget.errorBuilder != null
                ? widget.errorBuilder!(context, _error!, defaultWidget)
                : defaultWidget;
          } else {
            return _buildDayContent(pageDate, locale);
          }
        },
      );
    } else {
      // Default behavior: single day without swipe navigation
      if (_isLoading) {
        final defaultWidget = _buildDefaultLoading(context);
        dayViewContent = widget.loadingBuilder != null
            ? widget.loadingBuilder!(context, defaultWidget)
            : defaultWidget;
      } else if (_error != null) {
        final defaultWidget = _buildDefaultError(context, _error!);
        dayViewContent = widget.errorBuilder != null
            ? widget.errorBuilder!(context, _error!, defaultWidget)
            : defaultWidget;
      } else {
        dayViewContent = _buildDayContent(_displayDate, locale);
      }
    }

    final focusContent = Focus(
      focusNode: _focusNode,
      onKeyEvent: enableKeyEvents ? _handleKeyEvent : null,
      child: Listener(
        onPointerDown: (_) {
          if (enableKeyEvents && !_focusNode.hasFocus) {
            _focusNode.requestFocus();
          }
        },
        onPointerMove: (enableResize || widget.enableDragToMove)
            ? (event) {
                if (enableResize) {
                  _handleResizePointerMoveFromParent(event);
                }
                if (_isDragActive) {
                  _handleDragPointerMove(event);
                }
              }
            : null,
        onPointerUp: enableResize ? _handleResizePointerUpFromParent : null,
        onPointerCancel: (enableResize || widget.enableDragToMove)
            ? (event) {
                if (_isDragActive) {
                  _handleDragCancelled(isUserCancel: true);
                }
                if (enableResize) {
                  _handleResizePointerCancelFromParent(event);
                }
              }
            : null,
        // DragTarget wraps the ENTIRE interactive surface (navigator +
        // all-day area + time grid + time legend across all pages)
        // so that:
        //  1. The pointer never leaves the DragTarget bounds when dragging
        //     into the time legend or all-day area (no spurious DragLeave).
        //  2. Edge detection uses tile edges with margins for navigation.
        //  3. The DragTarget survives PageView page transitions.
        // This matches the Month View pattern of one DragTarget per grid.
        child: widget.enableDragToMove
            ? DragTarget<MCalDragData>(
                onMove: _handleDragMove,
                onLeave: (_) => _handleDragLeave(),
                onAcceptWithDetails: _handleDrop,
                builder: (context, candidateData, rejectedData) {
                  final content = _buildMainColumn(locale, dayViewContent);
                  final dropLabel = _buildDropTargetSemanticLabel(context);
                  final mainContent = dropLabel != null
                      ? Semantics(label: dropLabel, child: content)
                      : content;
                  final centerLine = _isDragActive
                      ? _buildTileCenterLine()
                      : null;
                  return Stack(
                    children: [
                      mainContent,
                      if (_isDragActive || _isResizeActive)
                        ..._buildEdgeZoneOverlays(context),
                      if (_isDragActive || _isResizeActive)
                        ..._buildScrollEdgeZoneOverlays(context),
                      if (centerLine != null) centerLine,
                    ],
                  );
                },
              )
            : _buildMainColumn(locale, dayViewContent),
      ),
    );

    final shortcutsContent = Shortcuts(
      shortcuts: _buildShortcutsMap(),
      child: Actions(actions: _buildActionsMap(), child: focusContent),
    );

    // Wrap in two layers:
    // • Outer Directionality(textDirection): drives text rendering direction
    //   for all Text widgets — event titles, time labels, day header, etc.
    // • Inner MCalLayoutDirectionality(isLayoutRTL): carries layout direction used
    //   by all explicit isLayoutRTL checks (time-legend side, nav arrow actions,
    //   drag/drop geometry). Row/Column widgets that rely on ambient
    //   Directionality for ordering (e.g., the navigator Row) use
    //   textDirection, which is expected for the common case where both are
    //   the same. When they differ the caller has chosen an unconventional
    //   combination and should expect some ordering to follow textDirection.
    return Directionality(
      textDirection: textDirection,
      child: MCalLayoutDirectionality(
        isLayoutRTL: layoutDirection == TextDirection.rtl,
        child: Semantics(
          label:
              widget.semanticsLabel ??
              'Day view for ${DateFormat.yMMMMEEEEd(locale.toString()).format(_displayDate)}',
          child: shortcutsContent,
        ),
      ),
    );
  }
}

// MCalLayoutDirectionality is defined in mcal_layout_directionality.dart and shared
// with mcal_month_view.dart and mcal_month_default_week_layout.dart.

// ============================================================================
// Day Navigator Component
// ============================================================================

/// Private widget for day-to-day navigation controls.
///
/// Displays Previous/Today/Next buttons with the current date label.
/// Supports RTL layouts and custom builder callbacks.
class _DayNavigator extends StatelessWidget {
  const _DayNavigator({
    required this.displayDate,
    this.minDate,
    this.maxDate,
    required this.theme,
    this.navigatorBuilder,
    required this.locale,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  final DateTime displayDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final MCalThemeData theme;
  final Widget Function(BuildContext, DateTime, Widget)? navigatorBuilder;
  final Locale locale;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  /// Check if we can navigate to the previous day.
  bool _canGoPrevious() {
    if (minDate == null) return true;
    final previousDay = DateTime(
      displayDate.year,
      displayDate.month,
      displayDate.day - 1,
    );
    return !previousDay.isBefore(minDate!);
  }

  /// Check if we can navigate to the next day.
  bool _canGoNext() {
    if (maxDate == null) return true;
    final nextDay = DateTime(
      displayDate.year,
      displayDate.month,
      displayDate.day + 1,
    );
    return !nextDay.isAfter(maxDate!);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = mcalL10n(context);
    // Use ambient Directionality (set to layoutDirection by the outer wrapper)
    // for RTL. Icons stay semantically consistent (← = previous, → = next);
    // the Row in RTL context automatically places previous on the right and
    // next on the left without any manual button-order swapping.

    // Calculate if navigation is allowed
    final canGoPrevious = _canGoPrevious();
    final canGoNext = _canGoNext();

    // Format date display using intl
    final dateFormat = DateFormat.yMMMMEEEEd(locale.toString());
    final formattedDate = dateFormat.format(displayDate);

    // Build default navigator — always use LTR button order and let the
    // ambient Directionality (layoutDirection) handle visual reversal for RTL.
    Widget navigator = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(color: theme.navigatorBackgroundColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _buildLTRButtons(
          canGoPrevious,
          canGoNext,
          formattedDate,
          l10n,
        ),
      ),
    );

    // Apply custom builder if provided
    if (navigatorBuilder != null) {
      navigator = navigatorBuilder!(context, displayDate, navigator);
    }

    return navigator;
  }

  /// Build buttons in LTR order: [Previous] [Date] [Today] [Next]
  List<Widget> _buildLTRButtons(
    bool canGoPrevious,
    bool canGoNext,
    String formattedDate,
    MCalLocalizations localizations,
  ) {
    return [
      // Previous day button
      Semantics(
        label: localizations.previousDay,
        button: true,
        enabled: canGoPrevious,
        child: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: canGoPrevious ? onPrevious : null,
          tooltip: localizations.previousDay,
        ),
      ),

      // Date label (centered, expandable)
      Expanded(
        child: Semantics(
          label: formattedDate,
          header: true,
          child: GestureDetector(
            onTap: () {
              // Optional: Could trigger date picker or other action
            },
            child: Text(
              formattedDate,
              style: theme.navigatorTextStyle,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),

      // Today button
      Semantics(
        label: localizations.today,
        button: true,
        child: IconButton(
          icon: const Icon(Icons.today),
          onPressed: onToday,
          tooltip: localizations.today,
        ),
      ),

      // Next day button
      Semantics(
        label: localizations.nextDay,
        button: true,
        enabled: canGoNext,
        child: IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: canGoNext ? onNext : null,
          tooltip: localizations.nextDay,
        ),
      ),
    ];
  }
}

// ============================================================================
// Day Header Component
// ============================================================================

/// Private widget for the day header with optional week number.
///
/// Displays day of week, date number, and optional week number.
/// Supports RTL layouts and custom builder callbacks.
class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.displayDate,
    required this.showWeekNumbers,
    required this.firstDayOfWeek,
    required this.theme,
    required this.locale,
    required this.textDirection,
    this.dayHeaderBuilder,
    this.weekNumberBuilder,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.onHover,
  });

  final DateTime displayDate;
  final bool showWeekNumbers;

  /// The first day of the week (0 = Sunday, 1 = Monday, … 6 = Saturday),
  /// matching [MCalEventController.resolvedFirstDayOfWeek]. Used to compute
  /// the week number consistently with the Month View.
  final int firstDayOfWeek;
  final MCalThemeData theme;
  final Locale locale;
  final TextDirection textDirection;
  final Widget Function(BuildContext, MCalDayHeaderContext, Widget)?
  dayHeaderBuilder;
  final Widget Function(BuildContext, MCalWeekNumberContext, Widget)?
  weekNumberBuilder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final void Function(BuildContext, MCalDayHeaderContext?)? onHover;

  @override
  Widget build(BuildContext context) {
    final weekNumber = getWeekNumber(displayDate, firstDayOfWeek);

    final headerContext = MCalDayHeaderContext(
      date: displayDate,
      weekNumber: showWeekNumbers ? weekNumber : null,
    );

    // Build semantic label
    final dayOfWeekFull = DateFormat(
      'EEEE',
      locale.toString(),
    ).format(displayDate);
    final monthDayYear = DateFormat(
      'MMMM d',
      locale.toString(),
    ).format(displayDate);
    final semanticLabel = showWeekNumbers
        ? '$dayOfWeekFull, $monthDayYear, Week $weekNumber'
        : '$dayOfWeekFull, $monthDayYear';

    // Build week number widget (custom or default)
    Widget? resolvedWeekNumWidget;
    if (showWeekNumbers) {
      final defaultWeekNumWidget = _buildWeekNumber(weekNumber);
      if (weekNumberBuilder != null) {
        // Compute the start of the week using the controller's firstDayOfWeek.
        final fDow = firstDayOfWeek == 0 ? 7 : firstDayOfWeek;
        final daysSince = (displayDate.weekday - fDow + 7) % 7;
        final weekStart = displayDate.subtract(Duration(days: daysSince));
        resolvedWeekNumWidget = weekNumberBuilder!(
          context,
          MCalWeekNumberContext(
            weekNumber: weekNumber,
            firstDayOfWeek: weekStart,
            defaultFormattedString: 'W$weekNumber',
          ),
          defaultWeekNumWidget,
        );
      } else {
        resolvedWeekNumWidget = defaultWeekNumWidget;
      }
    }

    // Build default header layout
    final defaultWidget = Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Week number (optional, left for LTR, right for RTL)
          if (showWeekNumbers && textDirection == TextDirection.ltr) ...[
            resolvedWeekNumWidget!,
            const SizedBox(width: 8),
          ],

          // Day of week and date
          _buildDayAndDate(),

          // Week number (optional, right for RTL)
          if (showWeekNumbers && textDirection == TextDirection.rtl) ...[
            const SizedBox(width: 8),
            resolvedWeekNumWidget!,
          ],
        ],
      ),
    );

    final headerWidget = dayHeaderBuilder != null
        ? dayHeaderBuilder!(context, headerContext, defaultWidget)
        : defaultWidget;

    return Semantics(
      label: semanticLabel,
      header: true,
      child: _wrapWithGestureDetector(headerWidget),
    );
  }

  Widget _buildWeekNumber(int weekNumber) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color:
            theme.weekNumberBackgroundColor ??
            Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'W$weekNumber',
        style:
            theme.weekNumberTextStyle ??
            TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: theme.dayTheme?.weekNumberTextColor ?? Colors.black54,
            ),
      ),
    );
  }

  Widget _buildDayAndDate() {
    final dayOfWeek = DateFormat('EEE', locale.toString()).format(displayDate);
    final dateNum = displayDate.day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dayOfWeek.toUpperCase(),
          style:
              theme.dayTheme?.dayHeaderDayOfWeekStyle ??
              TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
        ),
        Text(
          dateNum.toString(),
          style:
              theme.dayTheme?.dayHeaderDateStyle ??
              TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
      ],
    );
  }

  Widget _wrapWithGestureDetector(Widget child) {
    Widget result = child;

    // Wrap with GestureDetector if any gesture callbacks are provided
    if (onTap != null || onLongPress != null || onDoubleTap != null) {
      result = GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        onDoubleTap: onDoubleTap,
        child: result,
      );
    }

    // Wrap with MouseRegion for hover support (only if callback provided)
    if (onHover != null) {
      result = Builder(
        builder: (context) {
          return MouseRegion(
            onEnter: (_) {
              final weekNumber = getWeekNumber(displayDate, firstDayOfWeek);
              final headerContext = MCalDayHeaderContext(
                date: displayDate,
                weekNumber: showWeekNumbers ? weekNumber : null,
              );
              onHover!(context, headerContext);
            },
            onExit: (_) => onHover!(context, null),
            child: result,
          );
        },
      );
    }

    return result;
  }
}

// ============================================================================
// Time Legend Column Component
// ============================================================================

/// Private widget for the time legend column with hour labels.
///
/// Renders hour labels (e.g., "9 AM", "2 PM") at each hour boundary along the
/// left (LTR) or right (RTL) edge of the day view. Uses locale-aware time
/// formatting and supports custom builder callbacks.
class _TimeLegendColumn extends StatelessWidget {
  const _TimeLegendColumn({
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    this.timeLabelFormat,
    this.timeLabelBuilder,
    required this.theme,
    required this.locale,
    this.onTimeLabelTap,
    this.onTimeLabelLongPress,
    this.onTimeLabelDoubleTap,
    this.onHoverTimeLabel,
    required this.displayDate,
    this.showSubHourLabels = false,
    this.subHourLabelInterval,
    this.subHourLabelBuilder,
  });

  final int startHour;
  final int endHour;
  final double hourHeight;
  final DateFormat? timeLabelFormat;
  final Widget Function(BuildContext, MCalTimeLabelContext, Widget)?
  timeLabelBuilder;
  final MCalThemeData theme;
  final Locale locale;
  final void Function(BuildContext, MCalTimeLabelContext)? onTimeLabelTap;
  final void Function(BuildContext, MCalTimeLabelContext)? onTimeLabelLongPress;
  final void Function(BuildContext, MCalTimeLabelContext)? onTimeLabelDoubleTap;
  final void Function(BuildContext, MCalTimeLabelContext?)? onHoverTimeLabel;
  final DateTime displayDate;
  final bool showSubHourLabels;
  final Duration? subHourLabelInterval;
  final Widget Function(BuildContext, MCalTimeLabelContext, Widget)?
  subHourLabelBuilder;

  /// Estimated height for a single-line time label (12px font + line height).
  static const double _labelHeight = 20.0;

  @override
  Widget build(BuildContext context) {
    final totalHours = (endHour - startHour).clamp(0, 24);
    final columnHeight = hourHeight * totalHours;
    final legendWidth = theme.dayTheme?.timeLegendWidth ?? 60.0;

    // Check RTL for tick positioning — reads from the MCalLayoutDirectionality wrapper.
    final isLayoutRTL = MCalLayoutDirectionality.of(context);

    // Check if ticks should be shown
    final showTicks = theme.dayTheme?.showTimeLegendTicks ?? true;

    // Resolved label position (default: topTrailingBelow)
    final labelPosition =
        theme.dayTheme?.timeLabelPosition ??
        MCalTimeLabelPosition.topTrailingBelow;

    return Container(
      width: legendWidth,
      height: columnHeight,
      color: theme.dayTheme?.timeLegendBackgroundColor,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Tick marks layer (behind labels)
          if (showTicks)
            CustomPaint(
              size: Size(legendWidth, columnHeight),
              painter: _TimeLegendTickPainter(
                startHour: startHour,
                endHour: endHour,
                hourHeight: hourHeight,
                tickColor:
                    theme.dayTheme?.timeLegendTickColor ??
                    Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                tickWidth: theme.dayTheme?.timeLegendTickWidth ?? 1.0,
                tickLength: theme.dayTheme?.timeLegendTickLength ?? 8.0,
                isLayoutRTL: isLayoutRTL,
                displayDate: displayDate,
              ),
            ),
          // Hour labels layer
          for (int hour = startHour; hour <= endHour; hour++)
            _buildPositionedLabel(
              context,
              hour: hour,
              minute: 0,
              isSubHour: false,
              labelPosition: labelPosition,
            ),
          // Sub-hour labels layer
          if (showSubHourLabels && subHourLabelInterval != null)
            for (int hour = startHour; hour <= endHour; hour++)
              for (
                int minute = subHourLabelInterval!.inMinutes;
                minute < 60;
                minute += subHourLabelInterval!.inMinutes
              )
                _buildPositionedLabel(
                  context,
                  hour: hour,
                  minute: minute,
                  isSubHour: true,
                  labelPosition: labelPosition,
                ),
        ],
      ),
    );
  }

  /// Builds a [Positioned] label at the correct location based on [labelPosition].
  Widget _buildPositionedLabel(
    BuildContext context, {
    required int hour,
    required int minute,
    required bool isSubHour,
    required MCalTimeLabelPosition labelPosition,
  }) {
    // Reference gridline Y
    final isBottomRef =
        labelPosition == MCalTimeLabelPosition.bottomLeadingAbove ||
        labelPosition == MCalTimeLabelPosition.bottomTrailingAbove;

    final refMinute = isBottomRef ? 60 : 0;
    final refTime = DateTime(
      displayDate.year,
      displayDate.month,
      displayDate.day,
      hour,
      minute + refMinute,
    );
    final gridlineY = timeToOffset(
      time: refTime,
      startHour: startHour,
      hourHeight: hourHeight,
    );

    // Vertical top offset based on vertical positioning
    final isAbove = labelPosition.name.endsWith('Above');
    final isCentered = labelPosition.name.endsWith('Centered');
    double top;
    if (isAbove) {
      top = gridlineY - _labelHeight;
    } else if (isCentered) {
      top = gridlineY - _labelHeight / 2;
    } else {
      // Below
      top = gridlineY;
    }

    // Horizontal alignment based on leading/trailing
    final isLeading = labelPosition.name.contains('Leading');
    final alignment = isLeading
        ? AlignmentDirectional.centerStart
        : AlignmentDirectional.centerEnd;

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      height: _labelHeight,
      child: Align(
        alignment: alignment,
        child: isSubHour
            ? _buildSubHourLabel(context, hour: hour, minute: minute)
            : _buildHourLabel(context, hour: hour),
      ),
    );
  }

  Widget _buildHourLabel(BuildContext context, {required int hour}) {
    // Create time for this hour on the display date
    final time = DateTime(
      displayDate.year,
      displayDate.month,
      displayDate.day,
      hour,
      0,
    );

    // Determine format based on locale if not provided
    DateFormat format;
    if (timeLabelFormat != null) {
      format = timeLabelFormat!;
    } else {
      // Default: 12-hour for English-speaking locales, 24-hour for others
      format = _isEnglishLocale(locale)
          ? DateFormat('h:mm a', locale.toString()) // "9:00 AM", "2:00 PM"
          : DateFormat('HH:mm', locale.toString()); // "09:00", "14:00"
    }

    final formattedTime = format.format(time);

    // Create context for builder or callback
    final labelContext = MCalTimeLabelContext(
      hour: hour,
      minute: 0,
      time: time,
    );

    // Semantic label for accessibility
    final semanticLabel = DateFormat('h a', locale.toString()).format(time);

    final baseStyle =
        theme.dayTheme?.timeLegendTextStyle ??
        TextStyle(fontSize: 12, color: Colors.grey[600]);

    // Build default label
    final defaultWidget = Text(formattedTime, style: baseStyle);

    Widget label = timeLabelBuilder != null
        ? timeLabelBuilder!(context, labelContext, defaultWidget)
        : defaultWidget;

    // Wrap with gesture detector if any callback provided
    if (onTimeLabelTap != null ||
        onTimeLabelLongPress != null ||
        onTimeLabelDoubleTap != null) {
      label = GestureDetector(
        onTap: onTimeLabelTap != null
            ? () => onTimeLabelTap!(context, labelContext)
            : null,
        onLongPress: onTimeLabelLongPress != null
            ? () => onTimeLabelLongPress!(context, labelContext)
            : null,
        onDoubleTap: onTimeLabelDoubleTap != null
            ? () => onTimeLabelDoubleTap!(context, labelContext)
            : null,
        child: label,
      );
    }

    // Wrap with MouseRegion for hover support (only if callback provided)
    if (onHoverTimeLabel != null) {
      label = MouseRegion(
        onEnter: (_) => onHoverTimeLabel!(context, labelContext),
        onExit: (_) => onHoverTimeLabel!(context, null),
        child: label,
      );
    }

    // Wrap with semantic label
    return Semantics(
      label: semanticLabel,
      button:
          onTimeLabelTap != null ||
          onTimeLabelLongPress != null ||
          onTimeLabelDoubleTap != null,
      child: label,
    );
  }

  Widget _buildSubHourLabel(
    BuildContext context, {
    required int hour,
    required int minute,
  }) {
    final time = DateTime(
      displayDate.year,
      displayDate.month,
      displayDate.day,
      hour,
      minute,
    );

    DateFormat format;
    if (timeLabelFormat != null) {
      format = timeLabelFormat!;
    } else {
      format = _isEnglishLocale(locale)
          ? DateFormat('h:mm', locale.toString()) // "9:30"
          : DateFormat('HH:mm', locale.toString()); // "09:30"
    }

    final formattedTime = format.format(time);
    final labelContext = MCalTimeLabelContext(
      hour: hour,
      minute: minute,
      time: time,
    );

    final baseStyle = theme.dayTheme?.timeLegendTextStyle;
    final baseFontSize = baseStyle?.fontSize ?? 12.0;
    final baseColor = baseStyle?.color ?? Colors.grey[600]!;
    final subHourStyle = (baseStyle ?? const TextStyle()).copyWith(
      fontSize: baseFontSize * 0.8,
      color: baseColor.withValues(alpha: 0.5),
    );

    final defaultWidget = Text(formattedTime, style: subHourStyle);

    Widget label = subHourLabelBuilder != null
        ? subHourLabelBuilder!(context, labelContext, defaultWidget)
        : defaultWidget;

    // Sub-hour labels do not get gesture callbacks (hour labels only)
    return label;
  }

  /// Check if the locale is English-speaking (uses 12-hour format).
  bool _isEnglishLocale(Locale locale) {
    return locale.languageCode == 'en';
  }
}

/// Custom painter for drawing tick marks on the time legend.
///
/// Draws small horizontal lines at each hour boundary, extending from the
/// appropriate edge of the legend column (right edge for LTR, left edge for RTL).
class _TimeLegendTickPainter extends CustomPainter {
  const _TimeLegendTickPainter({
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    required this.tickColor,
    required this.tickWidth,
    required this.tickLength,
    required this.isLayoutRTL,
    required this.displayDate,
  });

  final int startHour;
  final int endHour;
  final double hourHeight;
  final Color tickColor;
  final double tickWidth;
  final double tickLength;
  final bool isLayoutRTL;
  final DateTime displayDate;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = tickColor
      ..strokeWidth = tickWidth
      ..style = PaintingStyle.stroke;

    // Draw tick mark at each hour
    for (int hour = startHour; hour <= endHour; hour++) {
      final time = DateTime(
        displayDate.year,
        displayDate.month,
        displayDate.day,
        hour,
        0,
      );

      final yOffset = timeToOffset(
        time: time,
        startHour: startHour,
        hourHeight: hourHeight,
      );

      // Draw tick extending from the appropriate edge
      if (isLayoutRTL) {
        // RTL: tick extends from left edge
        canvas.drawLine(Offset(0, yOffset), Offset(tickLength, yOffset), paint);
      } else {
        // LTR: tick extends from right edge
        canvas.drawLine(
          Offset(size.width - tickLength, yOffset),
          Offset(size.width, yOffset),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TimeLegendTickPainter oldDelegate) {
    return startHour != oldDelegate.startHour ||
        endHour != oldDelegate.endHour ||
        hourHeight != oldDelegate.hourHeight ||
        tickColor != oldDelegate.tickColor ||
        tickWidth != oldDelegate.tickWidth ||
        tickLength != oldDelegate.tickLength ||
        isLayoutRTL != oldDelegate.isLayoutRTL;
  }
}

// ============================================================================
// Current Time Indicator Component
// ============================================================================

/// Private StatefulWidget that displays the current time indicator with live updates.
///
/// Renders a horizontal line at the current time position with a leading dot (circle)
/// at the RTL-aware edge. The indicator updates every 60 seconds via a timer.
class _CurrentTimeIndicator extends StatefulWidget {
  const _CurrentTimeIndicator({
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    required this.displayDate,
    required this.theme,
    required this.locale,
    this.builder,
  });

  final int startHour;
  final int endHour;
  final double hourHeight;
  final DateTime displayDate;
  final MCalThemeData theme;
  final Locale locale;
  final Widget Function(BuildContext, MCalCurrentTimeContext, Widget)? builder;

  @override
  State<_CurrentTimeIndicator> createState() => _CurrentTimeIndicatorState();
}

class _CurrentTimeIndicatorState extends State<_CurrentTimeIndicator> {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    // Update every 60 seconds
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if current time is within the visible time range
    final currentHour = _currentTime.hour;

    // Don't show if current time is outside the startHour-endHour range
    if (currentHour < widget.startHour || currentHour > widget.endHour) {
      return const SizedBox.shrink();
    }

    // Calculate the vertical offset using timeToOffset utility
    final offset = timeToOffset(
      time: _currentTime,
      startHour: widget.startHour,
      hourHeight: widget.hourHeight,
    );

    // Check layout RTL — reads from the MCalLayoutDirectionality wrapper.
    final isLayoutRTL = MCalLayoutDirectionality.of(context);

    // Create context for custom builder
    final indicatorContext = MCalCurrentTimeContext(
      currentTime: _currentTime,
      offset: offset,
    );

    // Format time for semantic label
    final timeFormat = DateFormat('h:mm a', widget.locale.toString());
    final formattedTime = timeFormat.format(_currentTime);
    final l10n = mcalL10n(context);
    final semanticLabel = l10n.currentTime(formattedTime);

    // Default indicator: horizontal line with leading dot
    final indicatorColor =
        widget.theme.dayTheme?.currentTimeIndicatorColor ?? Colors.red;
    final indicatorWidth =
        widget.theme.dayTheme?.currentTimeIndicatorWidth ?? 2.0;
    final dotRadius =
        widget.theme.dayTheme?.currentTimeIndicatorDotRadius ?? 6.0;

    final defaultWidget = Row(
      children: [
        // Leading dot (left for LTR, right for RTL)
        if (!isLayoutRTL) _buildDot(dotRadius, indicatorColor),

        // Horizontal line
        Expanded(
          child: Container(height: indicatorWidth, color: indicatorColor),
        ),

        // Trailing dot (right for RTL)
        if (isLayoutRTL) _buildDot(dotRadius, indicatorColor),
      ],
    );

    final indicatorWidget = widget.builder != null
        ? widget.builder!(context, indicatorContext, defaultWidget)
        : defaultWidget;

    return Positioned(
      top: offset,
      left: 0,
      right: 0,
      child: Semantics(
        label: semanticLabel,
        readOnly: true,
        child: indicatorWidget,
      ),
    );
  }

  Widget _buildDot(double radius, Color color) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

// ============================================================================
// Time Regions Layer Component
// ============================================================================

/// Private widget for rendering special time regions (blocked time, lunch breaks, etc.).
///
/// Renders time regions as colored overlays positioned between gridlines and events (Layer 2).
/// Supports recurring regions via RRULE expansion and custom builder callbacks.
class _TimeRegionsLayer extends StatelessWidget {
  const _TimeRegionsLayer({
    required this.regions,
    required this.displayDate,
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    required this.theme,
    this.timeRegionBuilder,
  });

  final List<MCalTimeRegion> regions;
  final DateTime displayDate;
  final int startHour;
  final int endHour;
  final double hourHeight;
  final MCalThemeData theme;
  final Widget Function(BuildContext, MCalTimeRegionContext, Widget)?
  timeRegionBuilder;

  @override
  Widget build(BuildContext context) {
    // Filter regions to only those that apply to displayDate
    final applicableRegions = _getApplicableRegions();

    return Stack(
      children: [
        for (final region in applicableRegions)
          _buildTimeRegion(context, region),
      ],
    );
  }

  /// Filters and returns regions that apply to the display date.
  ///
  /// For non-recurring regions, checks if the region's date matches displayDate.
  /// For recurring regions, expands occurrences for the display date.
  List<MCalTimeRegion> _getApplicableRegions() {
    final result = <MCalTimeRegion>[];

    for (final region in regions) {
      // Check if non-recurring region applies to displayDate
      if (region.recurrenceRule == null &&
          _regionAppliesToDate(region, displayDate)) {
        result.add(region);
      }

      // If region has recurrence rule, expand occurrences
      // Note: Full RRULE expansion would use similar logic to event controller's
      // recurrence expansion. For now, we implement basic recurring region support.
      if (region.recurrenceRule != null) {
        final occurrences = _expandRecurringRegion(region, displayDate);
        result.addAll(occurrences);
      }
    }

    return result;
  }

  /// Checks if a non-recurring region applies to the given date.
  ///
  /// Returns true if the region's start date matches the display date (ignoring time).
  bool _regionAppliesToDate(MCalTimeRegion region, DateTime date) {
    // Check if region's date matches displayDate
    return region.startTime.year == date.year &&
        region.startTime.month == date.month &&
        region.startTime.day == date.day;
  }

  /// Expands recurring regions for the display date.
  ///
  /// This is a simplified implementation. Full RRULE support would use the
  /// same recurrence expansion logic as the event controller.
  ///
  /// For now, we support basic daily recurrence patterns.
  List<MCalTimeRegion> _expandRecurringRegion(
    MCalTimeRegion region,
    DateTime date,
  ) {
    final result = <MCalTimeRegion>[];

    // Basic implementation: Check if this date is within the recurrence range
    // A full implementation would parse and evaluate the RRULE string
    //
    // For now, we'll create a region for the display date if it matches
    // the recurrence pattern (simplified: just create occurrence on displayDate)
    //
    // In a production implementation, this would use the same RRULE parser
    // as MCalRecurrenceRule.getOccurrences()

    // Simple check: if the display date is >= start date, create an occurrence
    // with the same time-of-day as the original region
    if (!date.isBefore(
      DateTime(
        region.startTime.year,
        region.startTime.month,
        region.startTime.day,
      ),
    )) {
      // Calculate the duration of the region
      final duration = region.endTime.difference(region.startTime);

      // Create occurrence for the display date with same time-of-day
      final occurrenceStart = DateTime(
        date.year,
        date.month,
        date.day,
        region.startTime.hour,
        region.startTime.minute,
        region.startTime.second,
      );

      final occurrenceEnd = occurrenceStart.add(duration);

      // Create a new region instance for this occurrence
      result.add(
        MCalTimeRegion(
          id: '${region.id}_${date.toIso8601String().split('T')[0]}',
          startTime: occurrenceStart,
          endTime: occurrenceEnd,
          color: region.color,
          text: region.text,
          blockInteraction: region.blockInteraction,
          icon: region.icon,
          customData: region.customData,
          // Don't include recurrenceRule in the expanded occurrence
        ),
      );
    }

    return result;
  }

  /// Builds a positioned widget for a single time region.
  Widget _buildTimeRegion(BuildContext context, MCalTimeRegion region) {
    // Calculate vertical position and height
    final startOffset = _timeToOffset(region.startTime);
    final endOffset = _timeToOffset(region.endTime);
    final height = endOffset - startOffset;

    // Skip regions with invalid height
    if (height <= 0) return const SizedBox.shrink();

    final regionContext = MCalTimeRegionContext(
      region: region,
      displayDate: displayDate,
      startOffset: startOffset,
      height: height,
    );

    final defaultWidget = Container(
      decoration: BoxDecoration(
        color:
            region.color ??
            (region.blockInteraction
                ? theme.dayTheme?.blockedTimeRegionColor
                : theme.dayTheme?.specialTimeRegionColor),
        border: Border(
          top: BorderSide(
            color:
                theme.dayTheme?.timeRegionBorderColor ??
                Colors.grey.withValues(alpha: 0.3),
            width: 1,
          ),
          bottom: BorderSide(
            color:
                theme.dayTheme?.timeRegionBorderColor ??
                Colors.grey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: region.text != null || region.icon != null
          ? Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (region.icon != null) ...[
                    Icon(
                      region.icon,
                      size: 16,
                      color:
                          theme.dayTheme?.timeRegionTextColor ?? Colors.black54,
                    ),
                    if (region.text != null) const SizedBox(width: 4),
                  ],
                  if (region.text != null)
                    Text(
                      region.text!,
                      style:
                          theme.dayTheme?.timeRegionTextStyle ??
                          TextStyle(
                            fontSize: 12,
                            color:
                                theme.dayTheme?.timeRegionTextColor ??
                                Colors.black54,
                          ),
                    ),
                ],
              ),
            )
          : null,
    );

    final child = timeRegionBuilder != null
        ? timeRegionBuilder!(context, regionContext, defaultWidget)
        : defaultWidget;

    return Positioned(
      top: startOffset,
      left: 0,
      right: 0,
      height: height,
      child: child,
    );
  }

  /// Converts a DateTime to a vertical offset in pixels.
  double _timeToOffset(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final totalMinutes = (hour - startHour) * 60 + minute;
    return (totalMinutes / 60.0) * hourHeight;
  }
}

// ============================================================================
// Gridlines Layer Component
// ============================================================================

/// Private widget for rendering horizontal gridlines at configured intervals.
///
/// Displays gridlines at hour, major (30-min), and minor intervals based on
/// [gridlineInterval] (1, 5, 10, 15, 20, 30, or 60 minutes). Uses a CustomPainter
/// for optimal performance.
///
/// Gridlines are classified by type:
/// - Hour: Lines at the start of each hour (minute == 0)
/// - Major: Lines at 30-minute marks
/// - Minor: Lines at other configured intervals
///
/// Each type has different visual styling from the theme.
class _GridlinesLayer extends StatelessWidget {
  const _GridlinesLayer({
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    required this.gridlineInterval,
    required this.displayDate,
    required this.theme,
    required this.locale,
    this.gridlineBuilder,
  });

  final int startHour;
  final int endHour;
  final double hourHeight;
  final Duration gridlineInterval;
  final DateTime displayDate;
  final MCalThemeData theme;
  final Locale locale;
  final Widget Function(BuildContext, MCalGridlineContext, Widget)?
  gridlineBuilder;

  @override
  Widget build(BuildContext context) {
    // If custom builder is provided, build gridlines as widgets
    if (gridlineBuilder != null) {
      return _buildCustomGridlines(context);
    }

    // Default: Use CustomPainter for performance
    // Wrap in Semantics for accessibility (optional, design: can be noisy if per-line)
    final l10n = mcalL10n(context);
    final timeGridLabel = l10n.timeGrid;
    return Semantics(
      container: true,
      label: timeGridLabel,
      child: CustomPaint(
        painter: _GridlinesPainter(
          startHour: startHour,
          endHour: endHour,
          hourHeight: hourHeight,
          gridlineInterval: gridlineInterval,
          displayDate: displayDate,
          hourGridlineColor:
              theme.dayTheme?.hourGridlineColor ??
              Colors.grey.withValues(alpha: 0.2),
          hourGridlineWidth: theme.dayTheme?.hourGridlineWidth ?? 1.0,
          majorGridlineColor:
              theme.dayTheme?.majorGridlineColor ??
              Colors.grey.withValues(alpha: 0.15),
          majorGridlineWidth: theme.dayTheme?.majorGridlineWidth ?? 1.0,
          minorGridlineColor:
              theme.dayTheme?.minorGridlineColor ??
              Colors.grey.withValues(alpha: 0.08),
          minorGridlineWidth: theme.dayTheme?.minorGridlineWidth ?? 0.5,
        ),
        child:
            const SizedBox.expand(), // Fill available space so painter receives correct size
      ),
    );
  }

  /// Builds a default gridline widget for the given context.
  Widget _buildDefaultGridline(MCalGridlineContext gridline) {
    Color color;
    double width;
    switch (gridline.type) {
      case MCalGridlineType.hour:
        color =
            theme.dayTheme?.hourGridlineColor ??
            Colors.grey.withValues(alpha: 0.2);
        width = theme.dayTheme?.hourGridlineWidth ?? 1.0;
      case MCalGridlineType.major:
        color =
            theme.dayTheme?.majorGridlineColor ??
            Colors.grey.withValues(alpha: 0.15);
        width = theme.dayTheme?.majorGridlineWidth ?? 1.0;
      case MCalGridlineType.minor:
        color =
            theme.dayTheme?.minorGridlineColor ??
            Colors.grey.withValues(alpha: 0.08);
        width = theme.dayTheme?.minorGridlineWidth ?? 0.5;
    }
    return Container(height: width, color: color);
  }

  /// Builds gridlines using custom builder callback.
  Widget _buildCustomGridlines(BuildContext context) {
    final gridlines = _generateGridlines();

    return Stack(
      children: [
        for (final gridline in gridlines)
          Positioned(
            top: gridline.offset,
            left: 0,
            right: 0,
            child: gridlineBuilder!(
              context,
              gridline,
              _buildDefaultGridline(gridline),
            ),
          ),
      ],
    );
  }

  /// Generates a list of gridline contexts for all gridlines to render.
  List<MCalGridlineContext> _generateGridlines() {
    final gridlines = <MCalGridlineContext>[];
    final intervalMinutes = gridlineInterval.inMinutes;

    // Validate interval (must be 1, 5, 10, 15, 20, 30, or 60)
    if (![1, 5, 10, 15, 20, 30, 60].contains(intervalMinutes)) {
      return gridlines; // Return empty list if invalid
    }

    // Generate gridlines for each hour
    for (int hour = startHour; hour <= endHour; hour++) {
      // Generate gridlines within this hour at the configured interval
      for (int minute = 0; minute < 60; minute += intervalMinutes) {
        // Skip the gridline at the start of the next hour (endHour + 1)
        if (hour == endHour && minute > 0) break;

        final time = DateTime(
          displayDate.year,
          displayDate.month,
          displayDate.day,
          hour,
          minute,
        );
        final offset = timeToOffset(
          time: time,
          startHour: startHour,
          hourHeight: hourHeight,
        );

        // Classify gridline type
        final type = _classifyGridlineType(minute);

        gridlines.add(
          MCalGridlineContext(
            hour: hour,
            minute: minute,
            offset: offset,
            type: type,
            intervalMinutes: intervalMinutes,
          ),
        );
      }
    }

    return gridlines;
  }

  /// Classifies a gridline based on its minute offset within the hour.
  ///
  /// Per design: hour (minute==0), major (minute==30 when interval<=30), minor (other).
  MCalGridlineType _classifyGridlineType(int minute) {
    if (minute == 0) return MCalGridlineType.hour;
    if (minute == 30 && gridlineInterval.inMinutes <= 30) {
      return MCalGridlineType.major;
    }
    return MCalGridlineType.minor;
  }
}

// ============================================================================
// All-Day Events Section Component
// ============================================================================

/// Private widget for displaying all-day events in a flow layout.
///
/// Renders all-day events in horizontal rows with wrapping, respecting the
/// maximum rows constraint. Shows an overflow indicator when events exceed
/// the max rows limit. Supports drag-to-move and tap/long-press interactions.
class _AllDayEventsSection extends StatelessWidget {
  const _AllDayEventsSection({
    required this.events,
    required this.displayDate,
    required this.maxRows,
    required this.theme,
    required this.locale,
    this.allDayEventTileBuilder,
    required this.enableDragToMove,
    this.dragHandler,
    required this.isDragActive,
    this.onEventTap,
    this.onEventLongPress,
    this.onEventDoubleTap,
    this.keyboardFocusedEventId,
    this.onOverflowTap,
    this.onOverflowLongPress,
    this.onOverflowDoubleTap,
    this.onTimeSlotTap,
    this.onTimeSlotLongPress,
    this.onDragStarted,
    this.onDragEnded,
    this.onDragCancelled,
    this.draggedTileBuilder,
    this.dragSourceTileBuilder,
    this.dragLongPressDelay = const Duration(milliseconds: 200),
  });

  final List<MCalCalendarEvent> events;
  final DateTime displayDate;
  final int maxRows;
  final MCalThemeData theme;
  final Locale locale;
  final Widget Function(
    BuildContext,
    MCalCalendarEvent,
    MCalAllDayEventTileContext,
    Widget,
  )?
  allDayEventTileBuilder;
  final bool enableDragToMove;
  final MCalDragHandler? dragHandler;
  final bool isDragActive;
  final void Function(BuildContext, MCalEventTapDetails)? onEventTap;
  final void Function(BuildContext, MCalEventTapDetails)? onEventLongPress;
  final void Function(BuildContext, MCalEventTapDetails)? onEventDoubleTap;
  final String? keyboardFocusedEventId;
  final void Function(BuildContext, List<MCalCalendarEvent>, DateTime)?
  onOverflowTap;
  final void Function(BuildContext, List<MCalCalendarEvent>, DateTime)?
  onOverflowLongPress;
  final void Function(BuildContext, MCalOverflowTapDetails)?
  onOverflowDoubleTap;
  final void Function(BuildContext, MCalTimeSlotContext)? onTimeSlotTap;
  final void Function(BuildContext, MCalTimeSlotContext)? onTimeSlotLongPress;
  final void Function(MCalCalendarEvent, DateTime)? onDragStarted;
  final void Function(bool)? onDragEnded;
  final VoidCallback? onDragCancelled;
  final Widget Function(
    BuildContext,
    MCalCalendarEvent,
    MCalDraggedTileDetails,
    Widget,
  )?
  draggedTileBuilder;
  final Widget Function(
    BuildContext,
    MCalCalendarEvent,
    MCalDragSourceDetails,
    Widget,
  )?
  dragSourceTileBuilder;
  final Duration dragLongPressDelay;

  @override
  Widget build(BuildContext context) {
    final effectiveMaxRows = theme.dayTheme?.allDaySectionMaxRows ?? maxRows;

    // Estimate how many events fit per row
    final screenWidth = MediaQuery.of(context).size.width;
    final timeLegendWidth = theme.dayTheme?.timeLegendWidth ?? 60.0;
    final availableWidth = screenWidth - timeLegendWidth;
    final estimatedTilesPerRow = (availableWidth / 120).floor().clamp(1, 99);
    final maxVisibleEvents = effectiveMaxRows * estimatedTilesPerRow;

    final visibleEvents = events.take(maxVisibleEvents).toList();
    final overflowCount = (events.length - maxVisibleEvents).clamp(0, 999);
    final hasOverflow = overflowCount > 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final sectionWidth = constraints.maxWidth > 0
            ? constraints.maxWidth
            : availableWidth;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: theme.cellBackgroundColor,
            border: Border(
              bottom: BorderSide(
                color:
                    theme.cellBorderColor ?? Colors.grey.withValues(alpha: 0.2),
                width: 1.0,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // All-day label
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  'All-day',
                  style:
                      theme.dayTheme?.timeLegendTextStyle ??
                      TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              // Wrap layout for events
              Wrap(
                spacing: 4.0,
                runSpacing: 4.0,
                children: [
                  for (final event in visibleEvents)
                    _buildEventTile(context, event, sectionWidth),
                  if (hasOverflow)
                    _buildOverflowIndicator(context, overflowCount),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds a single all-day event tile.
  Widget _buildEventTile(
    BuildContext context,
    MCalCalendarEvent event,
    double sectionWidth,
  ) {
    final tileContext = MCalAllDayEventTileContext(
      event: event,
      displayDate: displayDate,
    );

    // Build the tile content
    final defaultWidget = _buildDefaultTile(context, event);
    Widget tile = allDayEventTileBuilder != null
        ? allDayEventTileBuilder!(context, event, tileContext, defaultWidget)
        : defaultWidget;

    // Add visual focus indicator when this event has keyboard focus
    if (keyboardFocusedEventId == event.id) {
      tile = Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: tile,
      );
    }

    // Add semantic label
    tile = Semantics(
      label: '${event.title}, All day',
      button: true,
      child: tile,
    );

    // Wrap with MCalDraggableEventTile when drag-to-move is enabled
    if (enableDragToMove && onDragStarted != null) {
      final hSpacing = theme.eventTileHorizontalSpacing ?? 2.0;
      // All-day tiles are intrinsically sized (minWidth: 80, maxWidth: 200).
      // Pass maxWidth so the drag feedback matches the source tile instead of
      // stretching to the full section width.
      const allDayTileMaxWidth = 200.0;
      tile = MCalDraggableEventTile(
        event: event,
        sourceDate: displayDate,
        dayWidth: allDayTileMaxWidth,
        horizontalSpacing: hSpacing,
        enabled: true,
        dragLongPressDelay: dragLongPressDelay,
        draggedTileBuilder: draggedTileBuilder != null
            ? (ctx, details, defaultWidget) =>
                  draggedTileBuilder!(ctx, event, details, defaultWidget)
            : null,
        dragSourceTileBuilder: dragSourceTileBuilder != null
            ? (ctx, details, defaultWidget) =>
                  dragSourceTileBuilder!(ctx, event, details, defaultWidget)
            : null,
        onDragStarted: () => onDragStarted!(event, displayDate),
        onDragEnded: onDragEnded,
        onDragCanceled: onDragCancelled,
        child: tile,
      );
    } else if (onEventTap != null ||
        onEventLongPress != null ||
        onEventDoubleTap != null) {
      // Wrap with gesture detector for tap/long-press/double-tap when drag is disabled
      tile = GestureDetector(
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
        onDoubleTap: onEventDoubleTap != null
            ? () => onEventDoubleTap!(
                context,
                MCalEventTapDetails(event: event, displayDate: displayDate),
              )
            : null,
        child: tile,
      );
    }

    return tile;
  }

  /// Builds the default all-day event tile appearance.
  Widget _buildDefaultTile(BuildContext context, MCalCalendarEvent event) {
    final tileColor = theme.ignoreEventColors
        ? (theme.allDayEventBackgroundColor ??
              theme.eventTileBackgroundColor ??
              Colors.blue)
        : (event.color ??
              theme.allDayEventBackgroundColor ??
              theme.eventTileBackgroundColor ??
              Colors.blue);

    return Container(
      constraints: const BoxConstraints(minWidth: 80, maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: tileColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(theme.eventTileCornerRadius ?? 3.0),
        border: Border.all(
          color: tileColor,
          width: theme.allDayEventBorderWidth ?? 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Color bar indicator
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(width: 6),

          // Event title
          Flexible(
            child: Text(
              event.title,
              style:
                  theme.allDayEventTextStyle ??
                  TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the overflow indicator showing how many events are hidden.
  Widget _buildOverflowIndicator(BuildContext context, int count) {
    final overflowEvents = events.skip(events.length - count).toList();

    return Semantics(
      label: '$count more all-day events',
      button: true,
      child: GestureDetector(
        onTap: onOverflowTap != null
            ? () => onOverflowTap!(context, overflowEvents, displayDate)
            : null,
        onLongPress: onOverflowLongPress != null
            ? () => onOverflowLongPress!(context, overflowEvents, displayDate)
            : null,
        onDoubleTap: onOverflowDoubleTap != null
            ? () {
                final visibleEvents = events
                    .take(events.length - count)
                    .toList();
                onOverflowDoubleTap!(
                  context,
                  MCalOverflowTapDetails(
                    date: displayDate,
                    hiddenEvents: overflowEvents,
                    visibleEvents: visibleEvents,
                  ),
                );
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color:
                theme.cellBorderColor?.withValues(alpha: 0.1) ??
                Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(
              theme.eventTileCornerRadius ?? 3.0,
            ),
            border: Border.all(
              color:
                  theme.cellBorderColor ?? Colors.grey.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          child: Text(
            '+$count more',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Disabled Time Slots Overlay
// ============================================================================

/// Private widget for rendering disabled time slots with reduced opacity.
///
/// Displays a semi-transparent overlay (0.5 opacity) over time slots that
/// return false from [timeSlotInteractivityCallback]. This provides visual
/// feedback to users about which time slots are non-interactive.
///
/// The overlay is positioned between gridlines and events in the layer stack.
class _DisabledTimeSlotsLayer extends StatelessWidget {
  const _DisabledTimeSlotsLayer({
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    required this.timeSlotDuration,
    required this.displayDate,
    required this.interactivityCallback,
  });

  final int startHour;
  final int endHour;
  final double hourHeight;
  final Duration timeSlotDuration;
  final DateTime displayDate;
  final bool Function(BuildContext, MCalTimeSlotInteractivityDetails)
  interactivityCallback;

  @override
  Widget build(BuildContext context) {
    // Build list of disabled time slots
    final disabledSlots = <Widget>[];
    final slotMinutes = timeSlotDuration.inMinutes;

    // Iterate through all time slots
    for (int hour = startHour; hour <= endHour; hour++) {
      for (int minute = 0; minute < 60; minute += slotMinutes) {
        // Skip slots that go beyond endHour
        if (hour == endHour && minute > 0) break;

        final slotStartTime = DateTime(
          displayDate.year,
          displayDate.month,
          displayDate.day,
          hour,
          minute,
        );
        final slotEndTime = slotStartTime.add(timeSlotDuration);

        // Check if this slot is interactive
        final details = MCalTimeSlotInteractivityDetails(
          date: dateOnly(displayDate),
          hour: hour,
          minute: minute,
          startTime: slotStartTime,
          endTime: slotEndTime,
        );

        final isInteractive = interactivityCallback(context, details);

        // If not interactive, add an overlay
        if (!isInteractive) {
          final topOffset = _timeToOffset(slotStartTime);
          final slotHeight = (slotMinutes / 60.0) * hourHeight;

          disabledSlots.add(
            Positioned(
              top: topOffset,
              left: 0,
              right: 0,
              height: slotHeight,
              child: IgnorePointer(
                child: Container(color: Colors.grey.withValues(alpha: 0.3)),
              ),
            ),
          );
        }
      }
    }

    if (disabledSlots.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(children: disabledSlots);
  }

  /// Converts a DateTime to a vertical offset in pixels.
  double _timeToOffset(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final totalMinutes = (hour - startHour) * 60 + minute;
    return (totalMinutes / 60.0) * hourHeight;
  }
}

// ============================================================================
// Gridlines Layer Component
// ============================================================================

/// Custom painter for rendering gridlines efficiently.
///
/// Uses Canvas drawing operations to paint horizontal lines at configured
/// intervals, with different colors and widths based on gridline type.
class _GridlinesPainter extends CustomPainter {
  _GridlinesPainter({
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    required this.gridlineInterval,
    required this.displayDate,
    required this.hourGridlineColor,
    required this.hourGridlineWidth,
    required this.majorGridlineColor,
    required this.majorGridlineWidth,
    required this.minorGridlineColor,
    required this.minorGridlineWidth,
  });

  final int startHour;
  final int endHour;
  final double hourHeight;
  final Duration gridlineInterval;
  final DateTime displayDate;
  final Color hourGridlineColor;
  final double hourGridlineWidth;
  final Color majorGridlineColor;
  final double majorGridlineWidth;
  final Color minorGridlineColor;
  final double minorGridlineWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final intervalMinutes = gridlineInterval.inMinutes;

    // Validate interval
    if (![1, 5, 10, 15, 20, 30, 60].contains(intervalMinutes)) {
      return; // Don't paint if invalid interval
    }

    // Paint gridlines for each hour
    for (int hour = startHour; hour <= endHour; hour++) {
      for (int minute = 0; minute < 60; minute += intervalMinutes) {
        // Skip gridlines beyond the end hour
        if (hour == endHour && minute > 0) break;

        final time = DateTime(
          displayDate.year,
          displayDate.month,
          displayDate.day,
          hour,
          minute,
        );
        final offset = timeToOffset(
          time: time,
          startHour: startHour,
          hourHeight: hourHeight,
        );

        // Determine gridline style based on type
        final Color color;
        final double width;

        if (minute == 0) {
          // Hour gridline
          color = hourGridlineColor;
          width = hourGridlineWidth;
        } else if (minute == 30 && intervalMinutes <= 30) {
          // Major gridline (30-minute mark, only when interval allows)
          color = majorGridlineColor;
          width = majorGridlineWidth;
        } else {
          // Minor gridline
          color = minorGridlineColor;
          width = minorGridlineWidth;
        }

        // Draw the gridline
        final paint = Paint()
          ..color = color
          ..strokeWidth = width
          ..style = PaintingStyle.stroke;

        canvas.drawLine(Offset(0, offset), Offset(size.width, offset), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridlinesPainter oldDelegate) {
    return startHour != oldDelegate.startHour ||
        endHour != oldDelegate.endHour ||
        hourHeight != oldDelegate.hourHeight ||
        gridlineInterval != oldDelegate.gridlineInterval ||
        hourGridlineColor != oldDelegate.hourGridlineColor ||
        hourGridlineWidth != oldDelegate.hourGridlineWidth ||
        majorGridlineColor != oldDelegate.majorGridlineColor ||
        majorGridlineWidth != oldDelegate.majorGridlineWidth ||
        minorGridlineColor != oldDelegate.minorGridlineColor ||
        minorGridlineWidth != oldDelegate.minorGridlineWidth;
  }
}

// ============================================================================
// Timed Events Layer Component
// ============================================================================

/// Private widget for rendering timed events with overlap-aware column layout.
///
/// This layer implements the core event display functionality for Day View,
/// including:
/// - Automatic overlap detection and side-by-side column layout
/// - Precise vertical positioning based on event start/end times
/// - Minimum height enforcement for usability
/// - Custom layout support via [dayLayoutBuilder]
/// - Tap and long-press interactions
///
/// The layout algorithm uses [detectOverlapsAndAssignColumns] to determine
/// optimal column positions for overlapping events. Events are rendered in
/// a Stack with Positioned widgets for precise pixel-level control.
///
/// This is a static rendering layer - drag-and-drop and resize functionality
/// are implemented separately in later tasks.
class _TimeGridEventsLayer extends StatelessWidget {
  const _TimeGridEventsLayer({
    required this.events,
    required this.displayDate,
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    required this.theme,
    this.timedEventTileBuilder,
    this.dayLayoutBuilder,
    this.onEventTap,
    this.onEventLongPress,
    this.onEventDoubleTap,
    this.keyboardFocusedEventId,
    this.enableDragToMove = false,
    this.enableDragToResize = false,
    this.draggedTileBuilder,
    this.dragSourceTileBuilder,
    this.dragLongPressDelay = const Duration(milliseconds: 200),
    this.onDragStarted,
    this.onDragEnded,
    this.onDragCancelled,
    this.timeResizeHandleBuilder,
    this.resizeHandleInset,
    this.onResizePointerDown,
    this.onResizeStart,
    this.onResizeUpdate,
    this.onResizeEnd,
    this.onResizeCancel,
  });

  final List<MCalCalendarEvent> events;
  final DateTime displayDate;
  final int startHour;
  final int endHour;
  final double hourHeight;
  final MCalThemeData theme;
  final Widget Function(
    BuildContext,
    MCalCalendarEvent,
    MCalTimedEventTileContext,
    Widget,
  )?
  timedEventTileBuilder;
  final Widget Function(BuildContext, MCalDayLayoutContext, Widget)?
  dayLayoutBuilder;
  final void Function(BuildContext, MCalEventTapDetails)? onEventTap;
  final void Function(BuildContext, MCalEventTapDetails)? onEventLongPress;
  final void Function(BuildContext, MCalEventTapDetails)? onEventDoubleTap;
  final String? keyboardFocusedEventId;
  final bool enableDragToMove;
  final bool enableDragToResize;
  final Widget Function(
    BuildContext,
    MCalCalendarEvent,
    MCalDraggedTileDetails,
    Widget,
  )?
  draggedTileBuilder;
  final Widget Function(
    BuildContext,
    MCalCalendarEvent,
    MCalDragSourceDetails,
    Widget,
  )?
  dragSourceTileBuilder;
  final Duration dragLongPressDelay;
  final void Function(MCalCalendarEvent, DateTime)? onDragStarted;
  final void Function(bool)? onDragEnded;
  final void Function()? onDragCancelled;
  final Widget Function(
    BuildContext,
    MCalCalendarEvent,
    MCalResizeEdge,
    Widget,
  )?
  timeResizeHandleBuilder;
  final double Function(MCalTimedEventTileContext, MCalResizeEdge)?
  resizeHandleInset;
  final void Function(MCalCalendarEvent, MCalResizeEdge, int)?
  onResizePointerDown;
  final void Function(MCalCalendarEvent, MCalResizeEdge)? onResizeStart;
  final void Function(MCalCalendarEvent, MCalResizeEdge, double)?
  onResizeUpdate;
  final VoidCallback? onResizeEnd;
  final VoidCallback? onResizeCancel;

  Widget _buildDefaultLayout(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    final eventsWithColumns = detectOverlapsAndAssignColumns(events);

    return LayoutBuilder(
      builder: (context, constraints) {
        final areaWidth = constraints.maxWidth;

        return Stack(
          children: [
            for (final eventWithColumn in eventsWithColumns)
              _buildPositionedEvent(context, eventWithColumn, areaWidth),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (dayLayoutBuilder != null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final layoutContext = MCalDayLayoutContext(
            events: events,
            displayDate: displayDate,
            startHour: startHour,
            endHour: endHour,
            hourHeight: hourHeight,
            areaWidth: constraints.maxWidth,
          );
          final defaultWidget = _buildDefaultLayout(context);
          return dayLayoutBuilder!(context, layoutContext, defaultWidget);
        },
      );
    }

    return _buildDefaultLayout(context);
  }

  /// Builds a positioned event tile with calculated layout.
  Widget _buildPositionedEvent(
    BuildContext context,
    DayViewEventWithColumn eventWithColumn,
    double areaWidth,
  ) {
    final event = eventWithColumn.event;
    final columnIndex = eventWithColumn.columnIndex;
    final totalColumns = eventWithColumn.totalColumns;

    // Compute the day's visible time window boundaries.
    // endHour=24 is handled by Duration arithmetic (gives midnight next day).
    final dayStart = DateTime(
      displayDate.year,
      displayDate.month,
      displayDate.day,
    ).add(Duration(hours: startHour));
    final dayEnd = DateTime(
      displayDate.year,
      displayDate.month,
      displayDate.day,
    ).add(Duration(hours: endHour));

    // Determine the event's position in a potential multi-day span.
    final isStartOnDisplayDate =
        event.start.year == displayDate.year &&
        event.start.month == displayDate.month &&
        event.start.day == displayDate.day;
    final isEndOnDisplayDate =
        event.end.year == displayDate.year &&
        event.end.month == displayDate.month &&
        event.end.day == displayDate.day;

    // Clamp the effective start/end to the visible day window so multi-day
    // events don't overflow the time grid and position correctly on each day.
    final effectiveStart = isStartOnDisplayDate ? event.start : dayStart;
    final effectiveEnd = isEndOnDisplayDate ? event.end : dayEnd;

    // Calculate vertical position and height
    final startOffset = timeToOffset(
      time: effectiveStart,
      startHour: startHour,
      hourHeight: hourHeight,
    );

    final rawHeight = durationToHeight(
      duration: effectiveEnd.difference(effectiveStart),
      hourHeight: hourHeight,
    );

    // Apply minimum height from theme
    final minHeight = theme.dayTheme?.timedEventMinHeight ?? 20.0;
    final height = rawHeight < minHeight ? minHeight : rawHeight;

    // Calculate horizontal position and width
    final columnWidth = areaWidth / totalColumns;
    final left = columnIndex * columnWidth;
    final width = columnWidth;

    // Create tile context with clamped times and day-position flags.
    final tileContext = MCalTimedEventTileContext(
      event: event,
      displayDate: displayDate,
      columnIndex: columnIndex,
      totalColumns: totalColumns,
      startTime: effectiveStart,
      endTime: effectiveEnd,
      isStartOnDisplayDate: isStartOnDisplayDate,
      isEndOnDisplayDate: isEndOnDisplayDate,
    );

    // Build the tile content
    Widget tile = _buildEventTile(context, event, tileContext);

    // Add visual focus indicator when this event has keyboard focus
    if (keyboardFocusedEventId == event.id) {
      tile = Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: tile,
      );
    }

    // Step 1 (INNER): Wrap with drag-and-drop or gesture detector.
    // MCalDraggableEventTile (LongPressDraggable) must be the inner layer so
    // that the resize handles placed on top in Step 2 receive pointer events
    // first. This mirrors Month View's layering: draggable tile is inner,
    // resize handles sit above it in the Stack — an opaque Listener on each
    // handle absorbs the press before it ever reaches LongPressDraggable.
    if (enableDragToMove) {
      final hSpacing = theme.eventTileHorizontalSpacing ?? 2.0;
      tile = MCalDraggableEventTile(
        event: event,
        sourceDate: displayDate,
        // dayWidth = column width (may be a fraction when events overlap).
        // This drives the feedback SizedBox so the dragged tile matches the
        // source tile width exactly — even for overlapping events.
        dayWidth: width,
        // tileHeight constrains the feedback to the exact pixel height of the
        // source tile so the dragged appearance matches the original.
        tileHeight: height,
        horizontalSpacing: hSpacing,
        enabled: enableDragToMove,
        draggedTileBuilder: draggedTileBuilder != null
            ? (context, details, defaultWidget) =>
                  draggedTileBuilder!(context, event, details, defaultWidget)
            : null,
        dragSourceTileBuilder: dragSourceTileBuilder != null
            ? (context, details, defaultWidget) =>
                  dragSourceTileBuilder!(context, event, details, defaultWidget)
            : null,
        dragLongPressDelay: dragLongPressDelay,
        onDragStarted: onDragStarted != null
            ? () => onDragStarted!(event, displayDate)
            : null,
        onDragEnded: onDragEnded,
        onDragCanceled: onDragCancelled,
        child: tile,
      );
    } else if (onEventTap != null ||
        onEventLongPress != null ||
        onEventDoubleTap != null) {
      tile = GestureDetector(
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
        onDoubleTap: onEventDoubleTap != null
            ? () => onEventDoubleTap!(
                context,
                MCalEventTapDetails(event: event, displayDate: displayDate),
              )
            : null,
        child: tile,
      );
    }

    // Step 2 (OUTER): Overlay resize handles on top via a Stack.
    // Because _TimeResizeHandle uses HitTestBehavior.opaque, a press on the
    // handle area is consumed here and never propagates to the LongPressDraggable
    // below — eliminating the gesture conflict without any code-level guards.
    if (enableDragToResize &&
        onResizeStart != null &&
        onResizeUpdate != null &&
        onResizeEnd != null &&
        onResizeCancel != null &&
        _shouldShowResizeHandles(event, tileContext)) {
      tile = _wrapWithResizeHandles(
        context,
        tile,
        event,
        tileContext,
        width,
        height,
      );
    }

    return Positioned(
      top: startOffset,
      left: left,
      width: width,
      height: height,
      child: tile,
    );
  }

  /// Returns true if at least one resize handle should be shown for this tile.
  ///
  /// A handle is suppressed when the corresponding edge falls on a different
  /// day (i.e. the tile is a continuation segment). Middle segments — where
  /// both edges are on other days — return false immediately so the resize
  /// overlay is skipped entirely.
  bool _shouldShowResizeHandles(
    MCalCalendarEvent event,
    MCalTimedEventTileContext tileContext,
  ) {
    // Middle segment of a multi-day event: neither edge is adjustable here.
    if (!tileContext.isStartOnDisplayDate && !tileContext.isEndOnDisplayDate) {
      return false;
    }
    final duration = event.end.difference(event.start);
    final minMinutes = theme.dayTheme?.minResizeDurationMinutes ?? 15;
    return duration.inMinutes >= minMinutes;
  }

  /// Wraps the event tile in a Stack with top and bottom resize handles.
  Widget _wrapWithResizeHandles(
    BuildContext context,
    Widget tile,
    MCalCalendarEvent event,
    MCalTimedEventTileContext tileContext,
    double width,
    double height,
  ) {
    final handleSize = theme.dayTheme?.resizeHandleSize ?? 8.0;
    final children = <Widget>[Positioned.fill(child: tile)];

    // Only add the start (top) handle when the event starts on this day.
    if (tileContext.isStartOnDisplayDate) {
      final startInset =
          resizeHandleInset?.call(tileContext, MCalResizeEdge.start) ?? 0.0;
      children.add(
        _TimeResizeHandle(
          edge: MCalResizeEdge.start,
          event: event,
          handleSize: handleSize,
          tileWidth: width,
          tileHeight: height,
          inset: startInset,
          visualBuilder: timeResizeHandleBuilder,
          onPointerDown: (e, edge, pointer) =>
              onResizePointerDown?.call(e, edge, pointer),
        ),
      );
    }

    // Only add the end (bottom) handle when the event ends on this day.
    if (tileContext.isEndOnDisplayDate) {
      final endInset =
          resizeHandleInset?.call(tileContext, MCalResizeEdge.end) ?? 0.0;
      children.add(
        _TimeResizeHandle(
          edge: MCalResizeEdge.end,
          event: event,
          handleSize: handleSize,
          tileWidth: width,
          tileHeight: height,
          inset: endInset,
          visualBuilder: timeResizeHandleBuilder,
          onPointerDown: (e, edge, pointer) =>
              onResizePointerDown?.call(e, edge, pointer),
        ),
      );
    }

    // Wrap in SizedBox to provide bounded constraints to the Stack.
    // All Stack children are Positioned, so the Stack cannot infer its own
    // size from children — it relies on parent constraints. In normal rendering
    // the outer Positioned(width, height) provides those bounds, but when the
    // tile is used as a drag-feedback widget it appears inside an overlay with
    // unbounded height (0..∞). The SizedBox fixes both cases.
    return SizedBox(
      width: width,
      height: height,
      child: Stack(clipBehavior: Clip.none, children: children),
    );
  }

  /// Builds the default timed event tile widget.
  Widget _buildDefaultTimedEventTile(
    MCalCalendarEvent event,
    MCalTimedEventTileContext tileContext,
    String timeRange,
  ) {
    final tileColor = theme.ignoreEventColors
        ? (theme.eventTileBackgroundColor ?? Colors.blue)
        : (event.color ?? theme.eventTileBackgroundColor ?? Colors.blue);

    final contrastColor = _getContrastColor(tileColor);
    final timeColor = contrastColor.withValues(alpha: 0.9);
    final showTimeRange =
        tileContext.endTime.difference(tileContext.startTime).inMinutes >= 30;

    // Square off the corners where the event continues beyond this day.
    final cornerRadius =
        theme.dayTheme?.timedEventBorderRadius ??
        theme.eventTileCornerRadius ??
        4.0;
    final topRadius = tileContext.isStartOnDisplayDate
        ? Radius.circular(cornerRadius)
        : Radius.zero;
    final bottomRadius = tileContext.isEndOnDisplayDate
        ? Radius.circular(cornerRadius)
        : Radius.zero;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: tileColor.withValues(alpha: 0.85),
        borderRadius: BorderRadius.only(
          topLeft: topRadius,
          topRight: topRadius,
          bottomLeft: bottomRadius,
          bottomRight: bottomRadius,
        ),
        border: Border.all(color: tileColor, width: 1.0),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tileHeight = constraints.maxHeight;
          final isCompact = tileHeight < 40;

          return ClipRect(
            child: isCompact
                ? _buildCompactTileContent(
                    event: event,
                    timeRange: timeRange,
                    showTimeRange: showTimeRange,
                    contrastColor: contrastColor,
                    timeColor: timeColor,
                    theme: theme,
                  )
                : _buildNormalTileContent(
                    event: event,
                    timeRange: timeRange,
                    showTimeRange: showTimeRange,
                    contrastColor: contrastColor,
                    timeColor: timeColor,
                    theme: theme,
                  ),
          );
        },
      ),
    );
  }

  /// Builds the event tile (custom or default).
  Widget _buildEventTile(
    BuildContext context,
    MCalCalendarEvent event,
    MCalTimedEventTileContext tileContext,
  ) {
    // Format time using the ambient locale so Arabic users get Arabic-script
    // AM/PM designators (ص/م) and Arabic-Indic numerals, which have the correct
    // Unicode BiDi categories for RTL paragraph rendering.
    final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en');
    final localeStr = locale.toString();

    // Build the time-range label shown inside the tile:
    //   • Same day: just start and end times — "3:00 PM – 4:15 PM"
    //   • 2–6 day span: day-of-week prefix on both edges — "Mon 3:00 PM – Wed 4:15 PM"
    //   • > 6 day span: short date prefix on both edges — "Feb 24 3:00 PM – Mar 2 4:15 PM"
    // The label always describes the full event range so every tile segment
    // is self-contained regardless of which day is currently displayed.
    final startTimeStr = DateFormat('h:mm a', localeStr).format(event.start);
    final endTimeStr = DateFormat('h:mm a', localeStr).format(event.end);

    final isSameDay =
        event.start.year == event.end.year &&
        event.start.month == event.end.month &&
        event.start.day == event.end.day;

    final String timeRange;
    if (isSameDay) {
      timeRange = '$startTimeStr – $endTimeStr';
    } else {
      final eventSpanDays = event.end.difference(event.start).inDays.abs();
      final useDates = eventSpanDays > 6;
      final startDayStr = useDates
          ? DateFormat('MMM d', localeStr).format(event.start)
          : DateFormat('EEE', localeStr).format(event.start);
      final endDayStr = useDates
          ? DateFormat('MMM d', localeStr).format(event.end)
          : DateFormat('EEE', localeStr).format(event.end);
      timeRange = '$startDayStr $startTimeStr – $endDayStr $endTimeStr';
    }

    // Calculate duration for semantic label
    final duration = event.end.difference(event.start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final durationStr = hours > 0
        ? (minutes > 0
              ? '$hours hour${hours > 1 ? 's' : ''} $minutes minute${minutes > 1 ? 's' : ''}'
              : '$hours hour${hours > 1 ? 's' : ''}')
        : '$minutes minute${minutes > 1 ? 's' : ''}';

    final semanticLabel =
        '${event.title}, $startTimeStr to $endTimeStr, $durationStr';

    // Build default tile
    final defaultWidget = _buildDefaultTimedEventTile(
      event,
      tileContext,
      timeRange,
    );

    final tileWidget = timedEventTileBuilder != null
        ? timedEventTileBuilder!(context, event, tileContext, defaultWidget)
        : defaultWidget;

    return Semantics(label: semanticLabel, button: true, child: tileWidget);
  }

  /// Builds compact tile content for small events (height < 40px).
  ///
  /// Combines title and time on one line, uses smaller font and clip overflow.
  Widget _buildCompactTileContent({
    required MCalCalendarEvent event,
    required String timeRange,
    required bool showTimeRange,
    required Color contrastColor,
    required Color timeColor,
    required MCalThemeData theme,
  }) {
    final titleStyle =
        theme.eventTileTextStyle?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: contrastColor,
        ) ??
        TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: contrastColor,
        );
    final displayText = showTimeRange
        ? '${event.title} · $timeRange'
        : event.title;
    return Text(
      displayText,
      style: titleStyle,
      overflow: TextOverflow.clip,
      maxLines: 1,
    );
  }

  /// Builds normal tile content for standard-sized events (height >= 40px).
  Widget _buildNormalTileContent({
    required MCalCalendarEvent event,
    required String timeRange,
    required bool showTimeRange,
    required Color contrastColor,
    required Color timeColor,
    required MCalThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          event.title,
          style:
              theme.eventTileTextStyle?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: contrastColor,
              ) ??
              TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: contrastColor,
              ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        if (showTimeRange)
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              timeRange,
              style:
                  theme.eventTileTextStyle?.copyWith(
                    fontSize: 10,
                    color: timeColor,
                  ) ??
                  TextStyle(fontSize: 10, color: timeColor),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
      ],
    );
  }

  /// Gets a contrasting text color for the given background color.
  Color _getContrastColor(Color backgroundColor) {
    // Calculate relative luminance
    final r = backgroundColor.r;
    final g = backgroundColor.g;
    final b = backgroundColor.b;
    final luminance = (0.299 * r + 0.587 * g + 0.114 * b);

    // Use white text for dark backgrounds, black for light backgrounds
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}

/// Vertical resize handle for timed event tiles in Day View.
///
/// Positioned at the top (start edge) or bottom (end edge) of an event tile.
/// Provides ~8dp hit area, semantic labels, and cursor feedback for resize.
/// Uses [Listener] for pointer-down so the parent can track the gesture
/// across scroll and navigation (see design doc "Resize Gesture Tracking").
class _TimeResizeHandle extends StatelessWidget {
  const _TimeResizeHandle({
    required this.edge,
    required this.event,
    required this.handleSize,
    required this.tileWidth,
    required this.tileHeight,
    this.inset = 0.0,
    this.visualBuilder,
    this.onPointerDown,
  });

  final MCalResizeEdge edge;
  final MCalCalendarEvent event;
  final double handleSize;
  final double tileWidth;
  final double tileHeight;
  final double inset;
  final Widget Function(
    BuildContext,
    MCalCalendarEvent,
    MCalResizeEdge,
    Widget,
  )?
  visualBuilder;
  final void Function(MCalCalendarEvent, MCalResizeEdge, int)? onPointerDown;

  @override
  Widget build(BuildContext context) {
    final defaultVisual = Container(
      width: tileWidth - 8,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(1),
      ),
    );

    final visual = visualBuilder != null
        ? visualBuilder!(context, event, edge, defaultVisual)
        : defaultVisual;

    final semanticLabel = edge == MCalResizeEdge.start
        ? 'Resize start time'
        : 'Resize end time';

    // Use Listener only (no GestureDetector) — parent Listener handles
    // move/up/cancel so resize survives scroll. Matches Month View pattern.
    Widget child = Semantics(
      container: true,
      label: semanticLabel,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeUpDown,
        child: Center(child: visual),
      ),
    );

    if (onPointerDown != null) {
      child = Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (pointerEvent) {
          onPointerDown!(event, edge, pointerEvent.pointer);
        },
        child: child,
      );
    }

    return Positioned(
      top: edge == MCalResizeEdge.start ? 0 : null,
      bottom: edge == MCalResizeEdge.end ? 0 : null,
      left: inset,
      right: inset,
      height: handleSize,
      child: child,
    );
  }
}

// ============================================================================
// _ResettableScrollController
// ============================================================================

/// A [ScrollController] whose initial offset can be updated between attach
/// cycles.  When the controller detaches from one [Scrollable] and is later
/// attached to another (e.g. after a page change in a [PageView]),
/// [createScrollPosition] uses [_nextInitialOffset] instead of the value
/// that was passed to the constructor.
class _ResettableScrollController extends ScrollController {
  double _nextInitialOffset;

  _ResettableScrollController({super.initialScrollOffset = 0.0})
      : _nextInitialOffset = initialScrollOffset;

  set nextInitialOffset(double value) => _nextInitialOffset = value;

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return ScrollPositionWithSingleContext(
      physics: physics,
      context: context,
      initialPixels: _nextInitialOffset,
      keepScrollOffset: false,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

// ============================================================================
// _DayPageScroller
// ============================================================================

/// Wraps a [SingleChildScrollView] so that every page in the [PageView] can
/// have the correct initial scroll offset without sharing a single controller.
///
/// * The **current** page receives [primaryController] (the one the rest of
///   the Day View code reads/writes for drag handling, scrollToTime, etc.).
/// * **Adjacent** pages ([primaryController] is null) get their own
///   [ScrollController] initialised to [initialOffset], so they appear at the
///   same vertical position as the current page during a swipe.
///
/// When a page transitions between current ↔ adjacent, the existing
/// [ScrollPosition] is simply re-attached to the new controller — the pixel
/// offset is preserved.
class _DayPageScroller extends StatefulWidget {
  const _DayPageScroller({
    required this.primaryController,
    required this.initialOffset,
    required this.physics,
    required this.child,
  });

  final ScrollController? primaryController;
  final double initialOffset;
  final ScrollPhysics? physics;
  final Widget child;

  @override
  State<_DayPageScroller> createState() => _DayPageScrollerState();
}

class _DayPageScrollerState extends State<_DayPageScroller> {
  ScrollController? _ownController;

  @override
  void initState() {
    super.initState();
    if (widget.primaryController == null) {
      _ownController = ScrollController(
        initialScrollOffset: widget.initialOffset,
      );
    }
  }

  @override
  void didUpdateWidget(_DayPageScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.primaryController != widget.primaryController) {
      if (oldWidget.primaryController != null &&
          widget.primaryController == null) {
        // Page became adjacent — create own controller.  The existing
        // ScrollPosition is re-attached by Scrollable.didUpdateWidget so the
        // current pixel offset is preserved automatically.
        _ownController = ScrollController(
          initialScrollOffset: widget.initialOffset,
        );
      } else if (oldWidget.primaryController == null &&
          widget.primaryController != null) {
        // Page became current — switch to the primary controller.
        // Defer disposal until after Scrollable detaches from it.
        final old = _ownController;
        _ownController = null;
        if (old != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
        }
      }
    }
  }

  @override
  void dispose() {
    _ownController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.primaryController ?? _ownController!,
      physics: widget.physics,
      child: widget.child,
    );
  }
}
