import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../controllers/mcal_event_controller.dart';
import '../models/mcal_calendar_event.dart';
import '../models/mcal_time_region.dart';
import '../styles/mcal_theme.dart';
import '../utils/mcal_localization.dart';
import '../utils/day_view_overlap.dart';
import '../utils/time_utils.dart';
import 'mcal_callback_details.dart';
import 'mcal_day_view_contexts.dart';
import 'mcal_drag_handler.dart';
import 'mcal_draggable_event_tile.dart';

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
///   onEventDropped: (details) => print('Dropped at ${details.newStartDate}'),
///   onEventResized: (details) => print('Resized to ${details.newDuration}'),
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
    this.showWeekNumber = false,
    this.gridlineInterval = const Duration(minutes: 15),
    this.dateFormat,
    this.timeLabelFormat,
    this.locale,

    // Scrolling
    this.autoScrollToCurrentTime = true,
    this.initialScrollTime,
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
    this.showDropTargetPreview = true,
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
    this.loadingBuilder,
    this.errorBuilder,
    this.timeRegionBuilder,

    // Navigation callbacks
    this.onNavigatePrevious,
    this.onNavigateNext,
    this.onNavigateToday,

    // Interaction callbacks
    this.onDayHeaderTap,
    this.onDayHeaderLongPress,
    this.onTimeLabelTap,
    this.onTimeSlotTap,
    this.onTimeSlotLongPress,
    this.onEmptySpaceDoubleTap,
    this.onEventTap,
    this.onEventLongPress,
    this.onHoverEvent,
    this.onHoverTimeSlot,
    this.onOverflowTap,
    this.onOverflowLongPress,

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
  });

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
  /// Events before this hour will not be displayed in the timed events area.
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
  /// Events after this hour will not be displayed in the timed events area.
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
  final bool showWeekNumber;

  /// The interval between gridlines in the timed events area.
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

  // ============================================================================
  // Scrolling
  // ============================================================================

  /// Whether to automatically scroll to the current time on initial load.
  ///
  /// When true, the view will scroll to position the current time in the center
  /// of the viewport when first displayed.
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

  /// The scroll physics for the timed events area.
  ///
  /// If null, uses platform-appropriate default physics.
  final ScrollPhysics? scrollPhysics;

  /// Optional external scroll controller for the timed events area.
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
  /// When dragging an all-day event into the timed area, it will be given this duration.
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
  final bool showDropTargetPreview;

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
  /// They are rendered as colored overlays in the timed events area.
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
  )?
  timeLabelBuilder;

  /// Builder for gridlines in the timed events area.
  ///
  /// If null, uses default gridline rendering.
  ///
  /// Receives [MCalGridlineContext] with gridline type (hour/major/minor) and position.
  final Widget Function(
    BuildContext context,
    MCalGridlineContext gridlineContext,
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
  )?
  currentTimeIndicatorBuilder;

  /// Builder for the navigation bar.
  ///
  /// If null, uses default navigator rendering (prev/today/next buttons).
  ///
  /// Receives the current display date.
  final Widget Function(BuildContext context, DateTime displayDate)?
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
  )?
  timeResizeHandleBuilder;

  /// Builder for loading state.
  ///
  /// Displayed while events are being loaded from the controller.
  /// If null, shows a centered [CircularProgressIndicator].
  final Widget Function(BuildContext context)? loadingBuilder;

  /// Builder for error state.
  ///
  /// Displayed when event loading fails.
  /// If null, shows a centered error message.
  ///
  /// Receives the error object.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Builder for special time regions.
  ///
  /// If null, uses default region rendering (colored overlay with optional text).
  ///
  /// Receives [MCalTimeRegionContext] with region data and position.
  final Widget Function(
    BuildContext context,
    MCalTimeRegionContext regionContext,
  )?
  timeRegionBuilder;

  // ============================================================================
  // Navigation Callbacks
  // ============================================================================

  /// Called when the "Previous Day" button is pressed.
  ///
  /// If null, the day is automatically navigated backward by 1 day.
  final VoidCallback? onNavigatePrevious;

  /// Called when the "Next Day" button is pressed.
  ///
  /// If null, the day is automatically navigated forward by 1 day.
  final VoidCallback? onNavigateNext;

  /// Called when the "Today" button is pressed.
  ///
  /// If null, the day is automatically navigated to today.
  final VoidCallback? onNavigateToday;

  // ============================================================================
  // Interaction Callbacks
  // ============================================================================

  /// Called when the day header is tapped.
  ///
  /// Receives the display date.
  final void Function(DateTime date)? onDayHeaderTap;

  /// Called when the day header is long-pressed.
  ///
  /// Receives the display date.
  final void Function(DateTime date)? onDayHeaderLongPress;

  /// Called when a time label in the time legend is tapped.
  ///
  /// Receives [MCalTimeLabelContext].
  final void Function(MCalTimeLabelContext labelContext)? onTimeLabelTap;

  /// Called when an empty time slot is tapped.
  ///
  /// Receives [MCalTimeSlotContext] with the date and time of the tapped slot.
  ///
  /// Useful for creating new events at the tapped time.
  final void Function(MCalTimeSlotContext slotContext)? onTimeSlotTap;

  /// Called when an empty time slot is long-pressed.
  ///
  /// Receives [MCalTimeSlotContext] with the date and time of the pressed slot.
  ///
  /// Useful for creating new events at the pressed time.
  final void Function(MCalTimeSlotContext slotContext)? onTimeSlotLongPress;

  /// Called when empty time slot space is double-tapped.
  ///
  /// Receives the [DateTime] at the double-tap position (snapped to time slot).
  /// Typical use case: Show create event dialog at the tapped time.
  ///
  /// Double-tap does not conflict with single tap; Flutter's gesture arena
  /// ensures only one gesture wins.
  final void Function(DateTime time)? onEmptySpaceDoubleTap;

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

  /// Called when the pointer hovers over an event.
  ///
  /// Only fires on platforms with hover support (desktop/web).
  ///
  /// Receives the event being hovered.
  final void Function(MCalCalendarEvent event)? onHoverEvent;

  /// Called when the pointer hovers over an empty time slot.
  ///
  /// Only fires on platforms with hover support (desktop/web).
  ///
  /// Receives [MCalTimeSlotContext].
  final void Function(MCalTimeSlotContext slotContext)? onHoverTimeSlot;

  /// Called when the all-day section overflow indicator is tapped.
  ///
  /// The overflow indicator appears when there are more all-day events than [allDaySectionMaxRows].
  ///
  /// Receives the list of overflowing events and the display date.
  final void Function(List<MCalCalendarEvent> events, DateTime date)?
  onOverflowTap;

  /// Called when the all-day section overflow indicator is long-pressed.
  ///
  /// Receives the list of overflowing events and the display date.
  final void Function(List<MCalCalendarEvent> events, DateTime date)?
  onOverflowLongPress;

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
  /// Receives [MCalEventDroppedDetails] with old and new dates.
  /// The [typeConversion] field indicates if the event was converted between all-day and timed.
  ///
  /// You are responsible for updating the event in your data source.
  /// The controller will automatically update if you call its modification methods.
  final void Function(MCalEventDroppedDetails details)? onEventDropped;

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
  /// Receives [MCalEventResizedDetails] with old and new times/durations.
  ///
  /// You are responsible for updating the event in your data source.
  final void Function(MCalEventResizedDetails details)? onEventResized;

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
/// - [scrollToTime] — Programmatically scroll the timed events area to a
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
  bool _isResizeActive = false;

  // Drag debouncing (matches Month View lines 3915-3922)
  DragTargetDetails<MCalDragData>? _latestDragDetails;
  Timer? _dragMoveDebounceTimer;
  bool _layoutCachedForDrag = false;

  // Resize state: offset of the edge being dragged (from top of timed area)
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

  static const double _resizeDragThreshold = 8.0;

  // ============================================================================
  // Scroll State
  // ============================================================================

  ScrollController? _scrollController;
  bool _autoScrollDone = false;

  // ============================================================================
  // Layout Cache
  // ============================================================================

  final double _cachedHourHeight = 0.0;

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
  // Keys for Layout Access
  // ============================================================================

  final GlobalKey _timedEventsAreaKey = GlobalKey();

  /// Position from the most recent [GestureDetector.onDoubleTapDown].
  /// Used by [onDoubleTap] since it does not receive position.
  Offset? _lastDoubleTapDownPosition;

  // ============================================================================
  // Lifecycle Methods
  // ============================================================================

  @override
  void initState() {
    super.initState();
    _displayDate = widget.controller.displayDate;
    _scrollController = widget.scrollController ?? ScrollController();
    _focusNode = FocusNode();
    widget.controller.addListener(_onControllerChanged);
    _loadEvents();
    _startCurrentTimeTimer();
  }

  @override
  void dispose() {
    _currentTimeTimer?.cancel();
    _dragMoveDebounceTimer?.cancel();
    _dragHandler?.dispose();
    _focusNode.dispose();
    if (widget.scrollController == null) {
      _scrollController?.dispose();
    }
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
      _displayDate = widget.controller.displayDate;
      _loadEvents();
    }

    // Update scroll controller if changed
    if (widget.scrollController != oldWidget.scrollController) {
      if (oldWidget.scrollController == null) {
        _scrollController?.dispose();
      }
      _scrollController = widget.scrollController ?? ScrollController();
    }

    // Reload events if display date changed
    if (widget.controller.displayDate != _displayDate) {
      _displayDate = widget.controller.displayDate;
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

  /// Checks if the current layout direction is RTL.
  bool _isRTL(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl;
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
  // Private Methods (Placeholder implementations)
  // ============================================================================

  void _onControllerChanged() {
    if (!mounted) return;

    if (widget.controller.displayDate != _displayDate) {
      setState(() {
        _displayDate = widget.controller.displayDate;
      });
      _loadEvents();
      widget.onDisplayDateChanged?.call(_displayDate);
    }
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  // ============================================================================
  // Drag Handling (Placeholder - will be implemented in Tasks 19-20)
  // ============================================================================

  /// Gets or creates the drag handler instance.
  ///
  /// The handler is created lazily to avoid overhead when drag-and-drop
  /// is not enabled. A listener is automatically added on first access to
  /// trigger rebuilds when drag state changes.
  MCalDragHandler get _ensureDragHandler {
    if (_dragHandler == null) {
      _dragHandler = MCalDragHandler();
      _dragHandler!.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    }
    return _dragHandler!;
  }

  /// Caches layout dimensions for drag operations.
  ///
  /// Called when a drag starts to capture the current layout metrics
  /// for use during the drag operation. This ensures consistent calculations
  /// even if the layout changes during the drag.
  void _cacheLayoutForDrag() {
    // Cache will be populated during build when dimensions are available
    // The cached value (_cachedHourHeight) is already
    // defined in the state and will be set during layout measurement.
    _layoutCachedForDrag = true;
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

    _isDragActive = true;
    _cacheLayoutForDrag();
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
  /// Cleans up drag state and resets cached layout flag. When the drop was
  /// accepted, _handleDrop already ran and called cancelDrag(); we only need
  /// to clean up when the drop was rejected (released outside valid target).
  void _handleDragEnded(bool wasAccepted) {
    _isDragActive = false;
    _layoutCachedForDrag = false;

    if (!wasAccepted) {
      _dragHandler?.cancelDrag();
    }

    setState(() {});
  }

  /// Called when a drag operation is cancelled.
  ///
  /// Cleans up drag state and cancels any pending edge navigation.
  /// This is called when the user presses Escape or when the system
  /// cancels the drag gesture.
  void _handleDragCancelled() {
    _ensureDragHandler.cancelDrag();
    _isDragActive = false;
    _layoutCachedForDrag = false;

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
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
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
        _keyboardMoveByDays(-1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
        _keyboardMoveByDays(1);
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

    _cacheLayoutForDrag();
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
    if (dragHandler == null || ev == null || start == null || end == null) return;

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
      if (proposedStart.isBefore(other.end) && other.start.isBefore(proposedEnd)) {
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
    final maxOffset = (widget.endHour - widget.startHour + 1) * hourHeight;
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
          _keyboardMoveOriginalEnd!.difference(_keyboardMoveOriginalStart!).inMinutes,
    );
    _updateKeyboardMovePreview();
    if (mounted) {
      final locale = widget.locale ?? Localizations.localeOf(context);
      final timeStr = DateFormat.Hm(locale.toString())
          .format(_keyboardMoveProposedStart!);
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

    start = DateTime(start.year, start.month, start.day + deltaDays,
        start.hour, start.minute);
    end = DateTime(end.year, end.month, end.day + deltaDays, end.hour, end.minute);

    _keyboardMoveProposedStart = start;
    _keyboardMoveProposedEnd = end;
    widget.controller.setDisplayDate(
      DateTime(start.year, start.month, start.day),
    );

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

    final sourceDate = DateTime(
      ev.start.year,
      ev.start.month,
      ev.start.day,
    );
    final dragData = MCalDragData(
      event: ev,
      sourceDate: sourceDate,
      grabOffsetHolder: MCalGrabOffsetHolder(),
      horizontalSpacing: 0,
    );
    final hourHeight = _cachedHourHeight > 0
        ? _cachedHourHeight
        : (widget.hourHeight ?? 80.0);
    final localY = timeToOffset(
      time: proposedStart,
      startHour: widget.startHour,
      hourHeight: hourHeight,
    );
    final timedBox = _timedEventsAreaKey.currentContext?.findRenderObject();
    final globalOffset = timedBox is RenderBox
        ? timedBox.localToGlobal(Offset(0, localY))
        : Offset.zero;
    final details = DragTargetDetails<MCalDragData>(
      data: dragData,
      offset: globalOffset,
    );
    _latestDragDetails = details;
    _layoutCachedForDrag = false;
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
    _layoutCachedForDrag = false;
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
        ? offsetToTime(
            offset: _keyboardResizeEdgeOffset,
            date: _displayDate,
            startHour: widget.startHour,
            hourHeight: hourHeight,
            timeSlotDuration: widget.gridlineInterval,
          )
        : event.start;
    final proposedEnd = edge == MCalResizeEdge.end
        ? offsetToTime(
            offset: _keyboardResizeEdgeOffset,
            date: _displayDate,
            startHour: widget.startHour,
            hourHeight: hourHeight,
            timeSlotDuration: widget.gridlineInterval,
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
    final maxOffset = (widget.endHour - widget.startHour + 1) * hourHeight;
    _keyboardResizeEdgeOffset =
        (_keyboardResizeEdgeOffset + deltaPx).clamp(minOffset, maxOffset);
    _updateKeyboardResizePreview();
    if (mounted) {
      final edge = _keyboardResizeEdge == MCalResizeEdge.start ? 'start' : 'end';
      _announceScreenReader(
        context,
        'Adjusted $edge time',
      );
    }
    setState(() {});
  }

  /// Switches keyboard resize edge (Tab).
  void _keyboardResizeSwitchEdge() {
    final dragHandler = _dragHandler;
    if (dragHandler == null || !dragHandler.isResizing) return;

    final event = dragHandler.resizingEvent!;
    final edge = _keyboardResizeEdge ?? MCalResizeEdge.end;
    final newEdge =
        edge == MCalResizeEdge.start ? MCalResizeEdge.end : MCalResizeEdge.start;
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
      _announceScreenReader(
        context,
        'Now adjusting $edgeLabel time',
      );
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
    final position = _scrollController?.position;
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

    // Resize in progress — pass delta to update
    _handleResizeUpdate(
      _pendingResizeEvent!,
      _pendingResizeEdge!,
      pointerEvent.delta.dy,
    );
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
    _releaseResizeScrollHold();

    if (_isResizeActive) {
      _isResizeActive = false;
      setState(() {});
    }
  }

  /// Called when resize drag starts. Initializes resize state.
  void _handleResizeStart(MCalCalendarEvent event, MCalResizeEdge edge) {
    if (!_resolveDragToResize()) return;
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
    final maxOffset = (widget.endHour - widget.startHour + 1) * hourHeight;
    final eventMinDuration = widget.timeSlotDuration.inMinutes >= 15
        ? widget.timeSlotDuration
        : const Duration(minutes: 15);

    _resizeEdgeOffset += deltaDy;
    _resizeEdgeOffset = _resizeEdgeOffset.clamp(minOffset, maxOffset);

    DateTime proposedStart = event.start;
    DateTime proposedEnd = event.end;

    if (edge == MCalResizeEdge.start) {
      proposedStart = offsetToTime(
        offset: _resizeEdgeOffset,
        date: _displayDate,
        startHour: widget.startHour,
        hourHeight: hourHeight,
        timeSlotDuration: widget.gridlineInterval,
      );
      final minimumEnd = proposedStart.add(eventMinDuration);
      if (proposedEnd.isBefore(minimumEnd) ||
          !proposedEnd.isAfter(proposedStart)) {
        proposedStart = proposedEnd.subtract(eventMinDuration);
      }
    } else {
      proposedEnd = offsetToTime(
        offset: _resizeEdgeOffset,
        date: _displayDate,
        startHour: widget.startHour,
        hourHeight: hourHeight,
        timeSlotDuration: widget.gridlineInterval,
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

    final result = dragHandler.completeResize();
    _isResizeActive = false;
    setState(() {});

    if (result == null) return;

    final (newStart, newEnd) = result;
    final event = dragHandler.resizingEvent;
    final originalStart = dragHandler.resizeOriginalStart;
    final originalEnd = dragHandler.resizeOriginalEnd;
    final edge = dragHandler.resizeEdge;

    if (event == null ||
        originalStart == null ||
        originalEnd == null ||
        edge == null) {
      return;
    }

    final details = MCalEventResizedDetails(
      event: event,
      oldStartDate: originalStart,
      oldEndDate: originalEnd,
      newStartDate: newStart,
      newEndDate: newEnd,
      resizeEdge: edge,
      isRecurring: event.recurrenceRule != null,
    );

    widget.onEventResized?.call(details);

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

    final updatedEvent = event.copyWith(start: newStart, end: newEnd);
    if (event.recurrenceRule != null) {
      widget.controller.modifyOccurrence(event.id, originalStart, updatedEvent);
    } else {
      widget.controller.addEvents([updatedEvent]);
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

    final dragHandler = _dragHandler;
    if (dragHandler == null) return;

    // Cache layout once at drag start - layout doesn't change during drag
    if (!_layoutCachedForDrag) {
      _cacheLayoutForDrag();
    }

    // Get the timed events area RenderBox to convert global to local coordinates
    final RenderBox? timedEventsBox =
        _timedEventsAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (timedEventsBox == null) return;

    // Convert global position to local coordinates relative to timed events area
    final globalPosition = details.offset;
    final localPosition = timedEventsBox.globalToLocal(globalPosition);

    // Detect section crossing: all-day ↔ timed
    // If localPosition.dy < 0, pointer is above the timed events area (in all-day section)
    final bool isInAllDaySection = localPosition.dy < 0;
    final dragData = details.data;
    final bool wasAllDayEvent = dragData.event.isAllDay;

    if (wasAllDayEvent && !isInAllDaySection) {
      // Dragging from all-day section into timed section
      _handleAllDayToTimedConversion(localPosition);
    } else if (!wasAllDayEvent && isInAllDaySection) {
      // Dragging from timed section into all-day section
      _handleTimedToAllDayConversion(localPosition);
    } else {
      // Moving within the same section type
      _handleSameTypeMove(localPosition);
    }

    // Check horizontal edge proximity for day navigation
    if (widget.dragEdgeNavigationEnabled) {
      _checkHorizontalEdgeProximity(localPosition.dx);
    }
  }

  /// Handles conversion from all-day event to timed event during drag.
  ///
  /// Calculates the time slot from the Y position and creates a proposed
  /// drop range using the configured [allDayToTimedDuration].
  void _handleAllDayToTimedConversion(Offset localPosition) {
    final dragHandler = _dragHandler;
    if (dragHandler == null) return;

    // Calculate time from Y position using offsetToTime utility
    // Use gridlineInterval for snap-to-grid alignment with visible gridlines
    final hourHeight = widget.hourHeight ?? 80.0;
    final proposedStart = offsetToTime(
      offset: localPosition.dy,
      date: _displayDate,
      startHour: widget.startHour,
      hourHeight: hourHeight,
      timeSlotDuration: widget.gridlineInterval,
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
      // All-day event: just update the date to current display date
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
      // Timed event: calculate new time from Y offset
      // Use gridlineInterval for snap-to-grid alignment with visible gridlines
      final hourHeight = widget.hourHeight ?? 80.0;
      final proposedStart = offsetToTime(
        offset: localPosition.dy,
        date: _displayDate,
        startHour: widget.startHour,
        hourHeight: hourHeight,
        timeSlotDuration: widget.gridlineInterval,
      );

      // Apply snapping
      final snappedStart = _applySnapping(proposedStart);

      // Calculate end maintaining duration (DST-safe)
      final proposedEnd = DateTime(
        snappedStart.year,
        snappedStart.month,
        snappedStart.day,
        snappedStart.hour,
        snappedStart.minute + originalDuration.inMinutes,
      );

      // Validate the drop
      final isValid = _validateDrop(
        proposedStart: snappedStart,
        proposedEnd: proposedEnd,
      );

      // Update drag handler (preserveTime for day view)
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
  void _checkHorizontalEdgeProximity(double localX) {
    final dragHandler = _dragHandler;
    if (dragHandler == null) return;

    // Get the width of the timed events area
    final RenderBox? timedEventsBox =
        _timedEventsAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (timedEventsBox == null) return;

    final width = timedEventsBox.size.width;
    const edgeThreshold = 50.0; // pixels

    // Check left edge (previous day)
    if (localX < edgeThreshold) {
      dragHandler.handleEdgeProximity(
        true,
        true, // isLeftEdge
        _handleNavigatePrevious,
        delay: widget.dragEdgeNavigationDelay,
      );
    }
    // Check right edge (next day)
    else if (localX > width - edgeThreshold) {
      dragHandler.handleEdgeProximity(
        true,
        false, // isLeftEdge = false (right edge)
        _handleNavigateNext,
        delay: widget.dragEdgeNavigationDelay,
      );
    }
    // Not near edge - cancel navigation
    else {
      dragHandler.handleEdgeProximity(false, false, () {});
    }
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

  /// Handles onWillAcceptWithDetails from the unified DragTarget.
  ///
  /// Called when a draggable enters or moves over the target. Calculates the
  /// proposed drop position from the offset using [offsetToTime], updates
  /// [MCalDragHandler.proposedRange], and returns whether the drop location
  /// is valid. This controls the accept/reject visual feedback.
  ///
  /// Distinguishes between move and resize operations (resize uses different
  /// handler path). Supports all-day ↔ timed conversions.
  bool _handleDragWillAcceptWithDetails(
    DragTargetDetails<MCalDragData> details,
  ) {
    final dragHandler = _dragHandler;
    if (dragHandler == null) return false;

    // Resize operations use a different flow - don't gate on willAccept
    if (dragHandler.isResizing) return true;

    // Process the position to update proposed range
    _latestDragDetails = details;
    _layoutCachedForDrag = false;
    _processDragMove();

    return dragHandler.isProposedDropValid;
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
    // Cancel pending debounce timer to prevent it from re-creating
    // drop indicators with stale position data after we clear them.
    _dragMoveDebounceTimer?.cancel();
    _dragMoveDebounceTimer = null;
    _latestDragDetails = null;

    // Do not cancel edge navigation during drag leave
    // to allow edge navigation to complete.

    // Clear the proposed drop range to remove any stale drop indicators.
    _dragHandler?.clearProposedDropRange();
  }

  /// Handles drop events from the unified DragTarget.
  ///
  /// Processes the drop, invokes callbacks, and updates the controller with
  /// the new event position. Supports type conversion and recurring events.
  void _handleDrop(DragTargetDetails<MCalDragData> details) {
    final dragHandler = _dragHandler;

    // Cancel edge navigation immediately
    dragHandler?.cancelEdgeNavigation();

    // Flush any pending local debounce timer and process immediately.
    // If the day changed during drag (edge nav) without an onMove, we may have
    // stale proposed dates from the previous page. Use the drop position to
    // recalculate with this page's layout so the drop lands on the visible day.
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

    // Determine if type conversion occurred
    String? typeConversion;
    if (event.isAllDay &&
        (proposedStart.hour != 0 || proposedStart.minute != 0)) {
      typeConversion = 'allDayToTimed';
    } else if (!event.isAllDay &&
        proposedStart.hour == 0 &&
        proposedStart.minute == 0) {
      typeConversion = 'timedToAllDay';
    }

    // Build drop details for callback
    final dropDetails = MCalEventDroppedDetails(
      event: event,
      oldStartDate: event.start,
      oldEndDate: event.end,
      newStartDate: proposedStart,
      newEndDate: proposedEnd,
      isRecurring: event.recurrenceRule != null,
      seriesId: event.recurrenceRule != null ? event.id : null,
      typeConversion: typeConversion,
    );

    // Call user callback if provided (returns true to accept, false to reject)
    if (widget.onEventDropped != null) {
      widget.onEventDropped!(dropDetails);
    }

    // Update the controller with the new event
    final updatedEvent = MCalCalendarEvent(
      id: event.id,
      title: event.title,
      start: proposedStart,
      end: proposedEnd,
      isAllDay:
          typeConversion == 'timedToAllDay' ||
          (typeConversion == null && event.isAllDay),
      color: event.color,
      comment: event.comment,
      externalId: event.externalId,
      occurrenceId: event.occurrenceId,
      recurrenceRule: event.recurrenceRule,
    );

    // Handle recurring events by creating an exception
    if (event.recurrenceRule != null) {
      // For recurring events, modify this occurrence only
      widget.controller.modifyOccurrence(
        event.id,
        event.start, // original date
        updatedEvent,
      );
    } else {
      // For non-recurring events, add/replace the event
      widget.controller.addEvents([updatedEvent]);
    }

    // Mark drag as complete - this clears all drag state including isDragging.
    // This prevents the microtask in _handleDragEnded from doing redundant cleanup.
    dragHandler?.cancelDrag();

    // Screen reader announcement for successful drop
    if (mounted) {
      final locale = widget.locale ?? Localizations.localeOf(context);
      final dateStr = DateFormat.yMMMMEEEEd(
        locale.toString(),
      ).format(proposedStart);
      final timeStr = DateFormat.Hm(locale.toString()).format(proposedStart);
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
    if (widget.onNavigatePrevious != null) {
      widget.onNavigatePrevious!();
    } else {
      // Default: Navigate to previous day (DST-safe)
      final previousDay = DateTime(
        _displayDate.year,
        _displayDate.month,
        _displayDate.day - 1,
      );
      widget.controller.setDisplayDate(previousDay);
    }
  }

  void _handleNavigateNext() {
    if (widget.onNavigateNext != null) {
      widget.onNavigateNext!();
    } else {
      // Default: Navigate to next day (DST-safe)
      final nextDay = DateTime(
        _displayDate.year,
        _displayDate.month,
        _displayDate.day + 1,
      );
      widget.controller.setDisplayDate(nextDay);
    }
  }

  void _handleNavigateToday() {
    if (widget.onNavigateToday != null) {
      widget.onNavigateToday!();
    } else {
      // Default: Navigate to today
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      widget.controller.setDisplayDate(todayDate);
    }
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

    // Build the tile
    final Widget tile;
    if (widget.dropTargetTileBuilder != null) {
      // Use custom builder
      tile = widget.dropTargetTileBuilder!(context, event, tileContext);
    } else {
      // Use default preview tile - semi-transparent with border
      tile = Opacity(
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
    }

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

    // Build overlay details for custom builder (requires drag data)
    final draggedEvent = dragHandler.draggedEvent;
    final sourceDate = dragHandler.sourceDate;

    // Build the overlay
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
      // Use custom builder
      overlay = widget.dropTargetOverlayBuilder!(context, overlayDetails);
    } else {
      // Use default overlay - semi-transparent colored band
      overlay = Positioned(
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
    }

    return Stack(children: [overlay]);
  }

  /// Builds the timed events area with Stack and optional DragTarget.
  ///
  /// Returns a Stack containing:
  /// - Layer 1+2: Main content (gridlines + regions + events + current time)
  /// - Layer 3: Drop target preview (phantom tiles) when [showDropTargetPreview]
  /// - Layer 4: Drop target overlay (highlighted time slots) when [showDropTargetOverlay]
  ///
  /// When [enableDragToMove] is true, wraps in DragTarget for drag-and-drop support.
  /// Layer order is controlled by [dropTargetTilesAboveOverlay].
  Widget _buildTimedEventsArea(BuildContext context, Locale locale) {
    final hourHeight = widget.hourHeight ?? 80.0;
    final contentHeight = (widget.endHour - widget.startHour + 1) * hourHeight;

    // Layer 1+2: Main content (gridlines + regions + events + current time)
    // Wrap gridlines in IgnorePointer when empty slot callbacks exist so taps
    // pass through to the GestureDetector for onTimeSlotTap/onTimeSlotLongPress.
    final hasEmptySlotCallbacksForLayer =
        widget.onTimeSlotTap != null ||
        widget.onTimeSlotLongPress != null ||
        widget.onEmptySpaceDoubleTap != null;
    final gridlinesLayer = hasEmptySlotCallbacksForLayer
        ? IgnorePointer(
            child: _GridlinesLayer(
              startHour: widget.startHour,
              endHour: widget.endHour,
              hourHeight: hourHeight,
              gridlineInterval: widget.gridlineInterval,
              displayDate: _displayDate,
              theme: _resolveTheme(context),
              gridlineBuilder: widget.gridlineBuilder,
            ),
          )
        : _GridlinesLayer(
            startHour: widget.startHour,
            endHour: widget.endHour,
            hourHeight: hourHeight,
            gridlineInterval: widget.gridlineInterval,
            displayDate: _displayDate,
            theme: _resolveTheme(context),
            gridlineBuilder: widget.gridlineBuilder,
          );
    final mainContent = Stack(
      children: [
        gridlinesLayer,
        if (widget.specialTimeRegions.isNotEmpty)
          _TimeRegionsLayer(
            regions: widget.specialTimeRegions,
            displayDate: _displayDate,
            startHour: widget.startHour,
            endHour: widget.endHour,
            hourHeight: hourHeight,
            theme: _resolveTheme(context),
            timeRegionBuilder: widget.timeRegionBuilder,
          ),
        _TimedEventsLayer(
          key: _timedEventsAreaKey,
          events: _timedEvents,
          displayDate: _displayDate,
          startHour: widget.startHour,
          endHour: widget.endHour,
          hourHeight: hourHeight,
          theme: _resolveTheme(context),
          timedEventTileBuilder: widget.timedEventTileBuilder,
          dayLayoutBuilder: widget.dayLayoutBuilder,
          onEventTap: _handleEventTap,
          onEventLongPress: widget.onEventLongPress,
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
          onResizePointerDown: _handleResizePointerDownFromChild,
          onResizeStart: _handleResizeStart,
          onResizeUpdate: _handleResizeUpdate,
          onResizeEnd: _handleResizeEnd,
          onResizeCancel: _handleResizeCancel,
        ),
        if (widget.showCurrentTimeIndicator)
          _CurrentTimeIndicator(
            startHour: widget.startHour,
            endHour: widget.endHour,
            hourHeight: hourHeight,
            displayDate: _displayDate,
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
      enabled: widget.showDropTargetPreview,
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
        widget.onEmptySpaceDoubleTap != null;
    final dateStr = DateFormat.yMMMMEEEEd(
      locale.toString(),
    ).format(_displayDate);
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
              label: 'Schedule for $dateStr',
              hint: 'Double tap to create event',
              child: ColoredBox(
                color: Colors.transparent,
                child: stack,
              ),
            ),
          )
        : Semantics(
            label: 'Schedule for $dateStr',
            container: true,
            child: stack,
          );

    if (!widget.enableDragToMove) {
      return SizedBox(height: contentHeight, child: gestureChild);
    }

    return SizedBox(
      height: contentHeight,
      child: DragTarget<MCalDragData>(
        onWillAcceptWithDetails: _handleDragWillAcceptWithDetails,
        onMove: _handleDragMove,
        onLeave: (_) => _handleDragLeave(),
        onAcceptWithDetails: _handleDrop,
        builder: (context, candidateData, rejectedData) {
          final dropTargetLabel = _buildDropTargetSemanticLabel(context);
          if (dropTargetLabel != null) {
            return Semantics(label: dropTargetLabel, child: gestureChild);
          }
          return gestureChild;
        },
      ),
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
    final localizations = MCalLocalizations();
    final prefix = localizations.getLocalizedString('dropTargetPrefix', locale);
    final validStr = localizations.getLocalizedString(
      dragHandler.isProposedDropValid ? 'dropTargetValid' : 'dropTargetInvalid',
      locale,
    );

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

    final tappedTime = offsetToTime(
      offset: localPosition.dy,
      date: _displayDate,
      startHour: widget.startHour,
      hourHeight: hourHeight,
      timeSlotDuration: widget.timeSlotDuration,
    );

    final slotContext = MCalTimeSlotContext(
      displayDate: _displayDate,
      hour: tappedTime.hour,
      minute: tappedTime.minute,
      offset: localPosition.dy,
      isAllDayArea: false,
    );

    widget.onTimeSlotTap!(slotContext);
  }

  /// Handles long-press on empty time slot area.
  ///
  /// Same logic as [_handleTimeSlotTap] but for long-press, firing
  /// [onTimeSlotLongPress] callback.
  void _handleTimeSlotLongPress(Offset localPosition, double hourHeight) {
    if (widget.onTimeSlotLongPress == null) return;

    if (_didTapHitEvent(localPosition, hourHeight)) return;

    final tappedTime = offsetToTime(
      offset: localPosition.dy,
      date: _displayDate,
      startHour: widget.startHour,
      hourHeight: hourHeight,
      timeSlotDuration: widget.timeSlotDuration,
    );

    final slotContext = MCalTimeSlotContext(
      displayDate: _displayDate,
      hour: tappedTime.hour,
      minute: tappedTime.minute,
      offset: localPosition.dy,
      isAllDayArea: false,
    );

    widget.onTimeSlotLongPress!(slotContext);
  }

  /// Handles double-tap on empty time slot area.
  ///
  /// Uses [_lastDoubleTapDownPosition] stored from [onDoubleTapDown] since
  /// [onDoubleTap] does not receive position. Converts position to DateTime
  /// using [offsetToTime], checks that the tap did not hit an event, and
  /// fires [onEmptySpaceDoubleTap] callback.
  void _handleTimeSlotDoubleTap(double hourHeight) {
    if (widget.onEmptySpaceDoubleTap == null) return;

    final localPosition = _lastDoubleTapDownPosition;
    if (localPosition == null) return;

    // Don't fire if tap hit an event (event tap takes precedence)
    if (_didTapHitEvent(localPosition, hourHeight)) return;

    final tappedTime = offsetToTime(
      offset: localPosition.dy,
      date: _displayDate,
      startHour: widget.startHour,
      hourHeight: hourHeight,
      timeSlotDuration: widget.timeSlotDuration,
    );

    widget.onEmptySpaceDoubleTap!(tappedTime);
  }

  /// Checks if the tap position overlaps with any event tile.
  ///
  /// Event taps take precedence over empty slot taps. Events have their own
  /// GestureDetectors which typically consume taps, but this provides a
  /// fallback check for edge cases.
  bool _didTapHitEvent(Offset localPosition, double hourHeight) {
    if (_timedEvents.isEmpty) return false;

    final renderBox =
        _timedEventsAreaKey.currentContext?.findRenderObject() as RenderBox?;
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
  // Build Method
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale ?? Localizations.localeOf(context);
    final enableKeyEvents =
        widget.enableKeyboardNavigation || widget.enableDragToMove;

    final enableResize = _resolveDragToResize();
    final focusContent = Focus(
      focusNode: _focusNode,
      onKeyEvent: enableKeyEvents ? _handleKeyEvent : null,
      child: Listener(
        onPointerDown: (_) {
          if (enableKeyEvents && !_focusNode.hasFocus) {
            _focusNode.requestFocus();
          }
        },
        onPointerMove: enableResize ? _handleResizePointerMoveFromParent : null,
        onPointerUp: enableResize ? _handleResizePointerUpFromParent : null,
        onPointerCancel: (enableResize || widget.enableDragToMove)
            ? (event) {
                if (_isDragActive) {
                  _handleDragCancelled();
                }
                if (enableResize) {
                  _handleResizePointerCancelFromParent(event);
                }
              }
            : null,
        child: Column(
          children: [
            // Navigator (if enabled)
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

            // Expanded area for day view content
            Expanded(
              child: _isLoading
                  ? (widget.loadingBuilder?.call(context) ??
                        const Center(child: CircularProgressIndicator()))
                  : _error != null
                  ? (widget.errorBuilder?.call(context, _error!) ??
                        Center(child: Text('Error: $_error')))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Day Header
                        _DayHeader(
                          displayDate: _displayDate,
                          showWeekNumber: widget.showWeekNumber,
                          theme: _resolveTheme(context),
                          locale: locale,
                          textDirection: Directionality.of(context),
                          dayHeaderBuilder: widget.dayHeaderBuilder,
                          onTap: widget.onDayHeaderTap != null
                              ? () => widget.onDayHeaderTap!(_displayDate)
                              : null,
                          onLongPress: widget.onDayHeaderLongPress != null
                              ? () => widget.onDayHeaderLongPress!(_displayDate)
                              : null,
                        ),

                        // All-Day Events Section
                        if (_allDayEvents.isNotEmpty)
                          _AllDayEventsSection(
                            events: _allDayEvents,
                            displayDate: _displayDate,
                            maxRows: widget.allDaySectionMaxRows,
                            theme: _resolveTheme(context),
                            locale: locale,
                            allDayEventTileBuilder:
                                widget.allDayEventTileBuilder,
                            enableDragToMove: widget.enableDragToMove,
                            dragHandler: _dragHandler,
                            isDragActive: _isDragActive,
                            onEventTap: _handleEventTap,
                            onEventLongPress: widget.onEventLongPress,
                            keyboardFocusedEventId: _focusedEvent?.id,
                            onOverflowTap: widget.onOverflowTap,
                            onOverflowLongPress: widget.onOverflowLongPress,
                            onTimeSlotTap: widget.onTimeSlotTap,
                            onTimeSlotLongPress: widget.onTimeSlotLongPress,
                            onDragStarted: _handleDragStarted,
                            onDragEnded: _handleDragEnded,
                            onDragCancelled: _handleDragCancelled,
                            draggedTileBuilder: widget.draggedTileBuilder,
                            dragSourceTileBuilder: widget.dragSourceTileBuilder,
                            dragLongPressDelay: widget.dragLongPressDelay,
                          ),

                        // Main content area with Time Legend and Events
                        // Time legend and events scroll together (Row inside SingleChildScrollView)
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: widget.scrollPhysics,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Time Legend (left in LTR, scrolls with events)
                                if (!_isRTL(context))
                                  _TimeLegendColumn(
                                    startHour: widget.startHour,
                                    endHour: widget.endHour,
                                    hourHeight: widget.hourHeight ?? 80.0,
                                    timeLabelFormat: widget.timeLabelFormat,
                                    timeLabelBuilder: widget.timeLabelBuilder,
                                    theme: _resolveTheme(context),
                                    locale: locale,
                                    onTimeLabelTap: widget.onTimeLabelTap,
                                    displayDate: _displayDate,
                                  ),

                                // Timed events area with gridlines
                                Expanded(
                                  child: _buildTimedEventsArea(context, locale),
                                ),

                                // Time Legend (right side for RTL, scrolls with events)
                                if (_isRTL(context))
                                  _TimeLegendColumn(
                                    startHour: widget.startHour,
                                    endHour: widget.endHour,
                                    hourHeight: widget.hourHeight ?? 80.0,
                                    timeLabelFormat: widget.timeLabelFormat,
                                    timeLabelBuilder: widget.timeLabelBuilder,
                                    theme: _resolveTheme(context),
                                    locale: locale,
                                    onTimeLabelTap: widget.onTimeLabelTap,
                                    displayDate: _displayDate,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );

    final shortcutsContent = Shortcuts(
      shortcuts: _buildShortcutsMap(),
      child: Actions(actions: _buildActionsMap(), child: focusContent),
    );

    return Semantics(
      label:
          widget.semanticsLabel ??
          'Day view for ${DateFormat.yMMMMEEEEd(locale.toString()).format(_displayDate)}',
      child: shortcutsContent,
    );
  }
}

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
  final Widget Function(BuildContext, DateTime)? navigatorBuilder;
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
    final localizations = MCalLocalizations();
    final isRTL = localizations.isRTL(locale);

    // Calculate if navigation is allowed
    final canGoPrevious = _canGoPrevious();
    final canGoNext = _canGoNext();

    // Format date display using intl
    final dateFormat = DateFormat.yMMMMEEEEd(locale.toString());
    final formattedDate = dateFormat.format(displayDate);

    // Build default navigator
    Widget navigator = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(color: theme.navigatorBackgroundColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: isRTL
            ? _buildRTLButtons(
                canGoPrevious,
                canGoNext,
                formattedDate,
                localizations,
              )
            : _buildLTRButtons(
                canGoPrevious,
                canGoNext,
                formattedDate,
                localizations,
              ),
      ),
    );

    // Apply custom builder if provided
    if (navigatorBuilder != null) {
      navigator = navigatorBuilder!(context, displayDate);
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
        label: 'Previous day',
        button: true,
        enabled: canGoPrevious,
        child: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: canGoPrevious ? onPrevious : null,
          tooltip: 'Previous day',
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
        label: localizations.getLocalizedString('today', locale),
        button: true,
        child: IconButton(
          icon: const Icon(Icons.today),
          onPressed: onToday,
          tooltip: localizations.getLocalizedString('today', locale),
        ),
      ),

      // Next day button
      Semantics(
        label: 'Next day',
        button: true,
        enabled: canGoNext,
        child: IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: canGoNext ? onNext : null,
          tooltip: 'Next day',
        ),
      ),
    ];
  }

  /// Build buttons in RTL order: [Next] [Today] [Date] [Previous]
  List<Widget> _buildRTLButtons(
    bool canGoPrevious,
    bool canGoNext,
    String formattedDate,
    MCalLocalizations localizations,
  ) {
    return [
      // Next day button (on left in RTL)
      Semantics(
        label: 'Next day',
        button: true,
        enabled: canGoNext,
        child: IconButton(
          icon: const Icon(Icons.chevron_left), // Left arrow for next in RTL
          onPressed: canGoNext ? onNext : null,
          tooltip: 'Next day',
        ),
      ),

      // Today button
      Semantics(
        label: localizations.getLocalizedString('today', locale),
        button: true,
        child: IconButton(
          icon: const Icon(Icons.today),
          onPressed: onToday,
          tooltip: localizations.getLocalizedString('today', locale),
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

      // Previous day button (on right in RTL)
      Semantics(
        label: 'Previous day',
        button: true,
        enabled: canGoPrevious,
        child: IconButton(
          icon: const Icon(
            Icons.chevron_right,
          ), // Right arrow for previous in RTL
          onPressed: canGoPrevious ? onPrevious : null,
          tooltip: 'Previous day',
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
/// Displays day of week, date number, and optional ISO 8601 week number.
/// Supports RTL layouts and custom builder callbacks.
class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.displayDate,
    required this.showWeekNumber,
    required this.theme,
    required this.locale,
    required this.textDirection,
    this.dayHeaderBuilder,
    this.onTap,
    this.onLongPress,
  });

  final DateTime displayDate;
  final bool showWeekNumber;
  final MCalThemeData theme;
  final Locale locale;
  final TextDirection textDirection;
  final Widget Function(BuildContext, MCalDayHeaderContext)? dayHeaderBuilder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final weekNumber = _calculateISOWeekNumber(displayDate);

    final headerContext = MCalDayHeaderContext(
      date: displayDate,
      weekNumber: showWeekNumber ? weekNumber : null,
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
    final semanticLabel = showWeekNumber
        ? '$dayOfWeekFull, $monthDayYear, Week $weekNumber'
        : '$dayOfWeekFull, $monthDayYear';

    // Custom builder takes precedence
    if (dayHeaderBuilder != null) {
      return Semantics(
        label: semanticLabel,
        header: true,
        child: _wrapWithGestureDetector(
          dayHeaderBuilder!(context, headerContext),
        ),
      );
    }

    // Default header layout
    return Semantics(
      label: semanticLabel,
      header: true,
      child: _wrapWithGestureDetector(
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Week number (optional, left for LTR, right for RTL)
              if (showWeekNumber && textDirection == TextDirection.ltr) ...[
                _buildWeekNumber(weekNumber),
                const SizedBox(width: 8),
              ],

              // Day of week and date
              _buildDayAndDate(),

              // Week number (optional, right for RTL)
              if (showWeekNumber && textDirection == TextDirection.rtl) ...[
                const SizedBox(width: 8),
                _buildWeekNumber(weekNumber),
              ],
            ],
          ),
        ),
      ),
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
              color: theme.weekNumberTextColor ?? Colors.black54,
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
              theme.dayHeaderDayOfWeekStyle ??
              TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
        ),
        Text(
          dateNum.toString(),
          style:
              theme.dayHeaderDateStyle ??
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
    if (onTap == null && onLongPress == null) return child;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }
}

/// Calculates the ISO 8601 week number for a given date.
///
/// ISO 8601 standard:
/// - Week 1 is the first week with Thursday in it (i.e., the week containing January 4th)
/// - Weeks start on Monday and end on Sunday
/// - The first and last week of a year may contain days from the previous/next year
///
/// Returns a week number between 1 and 53.
///
/// Examples:
/// - January 1, 2026 (Thursday) → Week 1
/// - December 28, 2026 (Monday) → Week 53
/// - January 1, 2025 (Wednesday) → Week 1 (of 2025, as it contains Thursday Jan 2)
int _calculateISOWeekNumber(DateTime date) {
  // ISO 8601 week date calculation
  // Week 1 is the week containing the first Thursday of the year

  // Find the Thursday of the current week
  // weekday: Monday=1, Sunday=7
  final weekDay = date.weekday;
  final thursday = date.add(Duration(days: 4 - weekDay));

  // Find the first Thursday of the year (which is in week 1)
  final jan4 = DateTime(thursday.year, 1, 4);
  final jan4Thursday = jan4.add(Duration(days: 4 - jan4.weekday));

  // Calculate the week number
  final weekNumber =
      1 + ((thursday.difference(jan4Thursday).inDays) / 7).floor();

  return weekNumber;
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
    required this.displayDate,
  });

  final int startHour;
  final int endHour;
  final double hourHeight;
  final DateFormat? timeLabelFormat;
  final Widget Function(BuildContext, MCalTimeLabelContext)? timeLabelBuilder;
  final MCalThemeData theme;
  final Locale locale;
  final void Function(MCalTimeLabelContext)? onTimeLabelTap;
  final DateTime displayDate;

  @override
  Widget build(BuildContext context) {
    final totalHours = endHour - startHour + 1;
    final columnHeight = hourHeight * totalHours;

    return Container(
      width: theme.timeLegendWidth ?? 60.0,
      height: columnHeight,
      color: theme.timeLegendBackgroundColor,
      child: Stack(
        children: [
          for (int hour = startHour; hour <= endHour; hour++)
            Positioned(
              top: timeToOffset(
                time: DateTime(
                  displayDate.year,
                  displayDate.month,
                  displayDate.day,
                  hour,
                  0,
                ),
                startHour: startHour,
                hourHeight: hourHeight,
              ),
              left: 0,
              right: 0,
              child: _buildHourLabel(context, hour),
            ),
        ],
      ),
    );
  }

  Widget _buildHourLabel(BuildContext context, int hour) {
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
          ? DateFormat('h a', locale.toString()) // "9 AM", "2 PM"
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

    // Custom builder takes precedence
    Widget label;
    if (timeLabelBuilder != null) {
      label = timeLabelBuilder!(context, labelContext);
    } else {
      // Default label
      label = Center(
        child: Text(
          formattedTime,
          style:
              theme.timeLegendTextStyle ??
              TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      );
    }

    // Wrap with gesture detector if tap callback provided
    if (onTimeLabelTap != null) {
      label = GestureDetector(
        onTap: () => onTimeLabelTap!(labelContext),
        child: label,
      );
    }

    // Wrap with semantic label
    return Semantics(
      label: semanticLabel,
      button: onTimeLabelTap != null,
      child: label,
    );
  }

  /// Check if the locale is English-speaking (uses 12-hour format).
  bool _isEnglishLocale(Locale locale) {
    return locale.languageCode == 'en';
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
  final Widget Function(BuildContext, MCalCurrentTimeContext)? builder;

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

    // Check RTL
    final localizations = MCalLocalizations();
    final isRTL = localizations.isRTL(widget.locale);

    // Create context for custom builder
    final indicatorContext = MCalCurrentTimeContext(
      currentTime: _currentTime,
      offset: offset,
    );

    // Format time for semantic label
    final timeFormat = DateFormat('h:mm a', widget.locale.toString());
    final formattedTime = timeFormat.format(_currentTime);
    final semanticLabel = 'Current time: $formattedTime';

    // Use custom builder if provided
    if (widget.builder != null) {
      return Positioned(
        top: offset,
        left: 0,
        right: 0,
        child: Semantics(
          label: semanticLabel,
          readOnly: true,
          child: widget.builder!(context, indicatorContext),
        ),
      );
    }

    // Default indicator: horizontal line with leading dot
    final indicatorColor = widget.theme.currentTimeIndicatorColor ?? Colors.red;
    final indicatorWidth = widget.theme.currentTimeIndicatorWidth ?? 2.0;
    final dotRadius = widget.theme.currentTimeIndicatorDotRadius ?? 6.0;

    return Positioned(
      top: offset,
      left: 0,
      right: 0,
      child: Semantics(
        label: semanticLabel,
        readOnly: true,
        child: Row(
          children: [
            // Leading dot (left for LTR, right for RTL)
            if (!isRTL) _buildDot(dotRadius, indicatorColor),

            // Horizontal line
            Expanded(
              child: Container(height: indicatorWidth, color: indicatorColor),
            ),

            // Trailing dot (right for RTL)
            if (isRTL) _buildDot(dotRadius, indicatorColor),
          ],
        ),
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
  final Widget Function(BuildContext, MCalTimeRegionContext)? timeRegionBuilder;

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

    // Custom builder takes precedence
    if (timeRegionBuilder != null) {
      return Positioned(
        top: startOffset,
        left: 0,
        right: 0,
        height: height,
        child: timeRegionBuilder!(context, regionContext),
      );
    }

    // Default region appearance
    return Positioned(
      top: startOffset,
      left: 0,
      right: 0,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color:
              region.color ??
              (region.blockInteraction
                  ? theme.blockedTimeRegionColor
                  : theme.specialTimeRegionColor),
          border: Border(
            top: BorderSide(
              color:
                  theme.timeRegionBorderColor ??
                  Colors.grey.withValues(alpha: 0.3),
              width: 1,
            ),
            bottom: BorderSide(
              color:
                  theme.timeRegionBorderColor ??
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
                        color: theme.timeRegionTextColor ?? Colors.black54,
                      ),
                      if (region.text != null) const SizedBox(width: 4),
                    ],
                    if (region.text != null)
                      Text(
                        region.text!,
                        style:
                            theme.timeRegionTextStyle ??
                            TextStyle(
                              fontSize: 12,
                              color:
                                  theme.timeRegionTextColor ?? Colors.black54,
                            ),
                      ),
                  ],
                ),
              )
            : null,
      ),
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
    this.gridlineBuilder,
  });

  final int startHour;
  final int endHour;
  final double hourHeight;
  final Duration gridlineInterval;
  final DateTime displayDate;
  final MCalThemeData theme;
  final Widget Function(BuildContext, MCalGridlineContext)? gridlineBuilder;

  @override
  Widget build(BuildContext context) {
    // If custom builder is provided, build gridlines as widgets
    if (gridlineBuilder != null) {
      return _buildCustomGridlines(context);
    }

    // Default: Use CustomPainter for performance
    // Wrap in Semantics for accessibility (optional, design: can be noisy if per-line)
    return Semantics(
      container: true,
      label: 'Time grid',
      child: CustomPaint(
        painter: _GridlinesPainter(
          startHour: startHour,
          endHour: endHour,
          hourHeight: hourHeight,
          gridlineInterval: gridlineInterval,
          displayDate: displayDate,
          hourGridlineColor:
              theme.hourGridlineColor ?? Colors.grey.withValues(alpha: 0.2),
          hourGridlineWidth: theme.hourGridlineWidth ?? 1.0,
          majorGridlineColor:
              theme.majorGridlineColor ?? Colors.grey.withValues(alpha: 0.15),
          majorGridlineWidth: theme.majorGridlineWidth ?? 1.0,
          minorGridlineColor:
              theme.minorGridlineColor ?? Colors.grey.withValues(alpha: 0.08),
          minorGridlineWidth: theme.minorGridlineWidth ?? 0.5,
        ),
        child:
            const SizedBox.expand(), // Fill available space so painter receives correct size
      ),
    );
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
            child: gridlineBuilder!(context, gridline),
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
    this.keyboardFocusedEventId,
    this.onOverflowTap,
    this.onOverflowLongPress,
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
  )?
  allDayEventTileBuilder;
  final bool enableDragToMove;
  final MCalDragHandler? dragHandler;
  final bool isDragActive;
  final void Function(BuildContext, MCalEventTapDetails)? onEventTap;
  final void Function(BuildContext, MCalEventTapDetails)? onEventLongPress;
  final String? keyboardFocusedEventId;
  final void Function(List<MCalCalendarEvent>, DateTime)? onOverflowTap;
  final void Function(List<MCalCalendarEvent>, DateTime)? onOverflowLongPress;
  final void Function(MCalTimeSlotContext)? onTimeSlotTap;
  final void Function(MCalTimeSlotContext)? onTimeSlotLongPress;
  final void Function(MCalCalendarEvent, DateTime)? onDragStarted;
  final void Function(bool)? onDragEnded;
  final VoidCallback? onDragCancelled;
  final Widget Function(
    BuildContext,
    MCalCalendarEvent,
    MCalDraggedTileDetails,
  )?
  draggedTileBuilder;
  final Widget Function(BuildContext, MCalCalendarEvent, MCalDragSourceDetails)?
  dragSourceTileBuilder;
  final Duration dragLongPressDelay;

  @override
  Widget build(BuildContext context) {
    // Calculate how many events can be shown (similar to Month View overflow pattern)
    final effectiveMaxRows = theme.allDaySectionMaxRows ?? maxRows;

    // Estimate how many events fit per row
    final screenWidth = MediaQuery.of(context).size.width;
    final timeLegendWidth = theme.timeLegendWidth ?? 60.0;
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
                      theme.timeLegendTextStyle ??
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
    Widget tile;
    if (allDayEventTileBuilder != null) {
      tile = allDayEventTileBuilder!(context, event, tileContext);
    } else {
      tile = _buildDefaultTile(context, event);
    }

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
      tile = MCalDraggableEventTile(
        event: event,
        sourceDate: displayDate,
        dayWidth: sectionWidth,
        horizontalSpacing: hSpacing,
        enabled: true,
        dragLongPressDelay: dragLongPressDelay,
        draggedTileBuilder: draggedTileBuilder != null
            ? (ctx, details) => draggedTileBuilder!(ctx, event, details)
            : null,
        dragSourceTileBuilder: dragSourceTileBuilder != null
            ? (ctx, details) => dragSourceTileBuilder!(ctx, event, details)
            : null,
        onDragStarted: () => onDragStarted!(event, displayDate),
        onDragEnded: onDragEnded,
        onDragCanceled: onDragCancelled,
        child: tile,
      );
    } else if (onEventTap != null || onEventLongPress != null) {
      // Wrap with gesture detector for tap/long-press when drag is disabled
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
            ? () => onOverflowTap!(overflowEvents, displayDate)
            : null,
        onLongPress: onOverflowLongPress != null
            ? () => onOverflowLongPress!(overflowEvents, displayDate)
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
class _TimedEventsLayer extends StatelessWidget {
  const _TimedEventsLayer({
    super.key,
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
  )?
  timedEventTileBuilder;
  final Widget Function(BuildContext, MCalDayLayoutContext)? dayLayoutBuilder;
  final void Function(BuildContext, MCalEventTapDetails)? onEventTap;
  final void Function(BuildContext, MCalEventTapDetails)? onEventLongPress;
  final String? keyboardFocusedEventId;
  final bool enableDragToMove;
  final bool enableDragToResize;
  final Widget Function(
    BuildContext,
    MCalCalendarEvent,
    MCalDraggedTileDetails,
  )?
  draggedTileBuilder;
  final Widget Function(BuildContext, MCalCalendarEvent, MCalDragSourceDetails)?
  dragSourceTileBuilder;
  final Duration dragLongPressDelay;
  final void Function(MCalCalendarEvent, DateTime)? onDragStarted;
  final void Function(bool)? onDragEnded;
  final void Function()? onDragCancelled;
  final Widget Function(BuildContext, MCalCalendarEvent, MCalResizeEdge)?
  timeResizeHandleBuilder;
  final void Function(MCalCalendarEvent, MCalResizeEdge, int)?
  onResizePointerDown;
  final void Function(MCalCalendarEvent, MCalResizeEdge)? onResizeStart;
  final void Function(MCalCalendarEvent, MCalResizeEdge, double)?
  onResizeUpdate;
  final VoidCallback? onResizeEnd;
  final VoidCallback? onResizeCancel;

  @override
  Widget build(BuildContext context) {
    // If custom layout builder is provided, use it
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
          return dayLayoutBuilder!(context, layoutContext);
        },
      );
    }

    // Default layout: column-based overlap detection
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    // Run overlap detection to assign columns
    final eventsWithColumns = detectOverlapsAndAssignColumns(events);

    // Build the event tiles in a Stack
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

  /// Builds a positioned event tile with calculated layout.
  Widget _buildPositionedEvent(
    BuildContext context,
    DayViewEventWithColumn eventWithColumn,
    double areaWidth,
  ) {
    final event = eventWithColumn.event;
    final columnIndex = eventWithColumn.columnIndex;
    final totalColumns = eventWithColumn.totalColumns;

    // Calculate vertical position and height
    final startOffset = timeToOffset(
      time: event.start,
      startHour: startHour,
      hourHeight: hourHeight,
    );

    final rawHeight = durationToHeight(
      duration: event.end.difference(event.start),
      hourHeight: hourHeight,
    );

    // Apply minimum height from theme
    final minHeight = theme.timedEventMinHeight ?? 20.0;
    final height = rawHeight < minHeight ? minHeight : rawHeight;

    // Calculate horizontal position and width
    final columnWidth = areaWidth / totalColumns;
    final left = columnIndex * columnWidth;
    final width = columnWidth;

    // Create tile context
    final tileContext = MCalTimedEventTileContext(
      event: event,
      displayDate: displayDate,
      columnIndex: columnIndex,
      totalColumns: totalColumns,
      startTime: event.start,
      endTime: event.end,
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

    // Wrap with resize handles when enabled and event meets minimum duration
    if (enableDragToResize &&
        onResizeStart != null &&
        onResizeUpdate != null &&
        onResizeEnd != null &&
        onResizeCancel != null &&
        _shouldShowResizeHandles(event)) {
      tile = _wrapWithResizeHandles(context, tile, event, width, height);
    }

    // Wrap with drag-and-drop or gesture detector for interactions
    if (enableDragToMove) {
      // Capture spacing from theme
      final hSpacing = theme.eventTileHorizontalSpacing ?? 2.0;

      // When drag is enabled, wrap with MCalDraggableEventTile
      // which handles both dragging and passes through taps
      // For Day View, we use the tile width as dayWidth
      tile = MCalDraggableEventTile(
        event: event,
        sourceDate: displayDate,
        dayWidth: width,
        horizontalSpacing: hSpacing,
        enabled: enableDragToMove,
        draggedTileBuilder: draggedTileBuilder != null
            ? (context, details) => draggedTileBuilder!(context, event, details)
            : null,
        dragSourceTileBuilder: dragSourceTileBuilder != null
            ? (context, details) =>
                  dragSourceTileBuilder!(context, event, details)
            : null,
        dragLongPressDelay: dragLongPressDelay,
        onDragStarted: onDragStarted != null
            ? () => onDragStarted!(event, displayDate)
            : null,
        onDragEnded: onDragEnded,
        onDragCanceled: onDragCancelled,
        child: tile,
      );
    } else if (onEventTap != null || onEventLongPress != null) {
      // When drag is disabled, use GestureDetector for taps
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
        child: tile,
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

  /// Returns true if the event duration meets the minimum for showing resize handles.
  bool _shouldShowResizeHandles(MCalCalendarEvent event) {
    final duration = event.end.difference(event.start);
    final minMinutes = theme.minResizeDurationMinutes ?? 15;
    return duration.inMinutes >= minMinutes;
  }

  /// Wraps the event tile in a Stack with top and bottom resize handles.
  Widget _wrapWithResizeHandles(
    BuildContext context,
    Widget tile,
    MCalCalendarEvent event,
    double width,
    double height,
  ) {
    final handleSize = theme.resizeHandleSize ?? 8.0;
    final children = <Widget>[Positioned.fill(child: tile)];

    children.add(
      _TimeResizeHandle(
        edge: MCalResizeEdge.start,
        event: event,
        handleSize: handleSize,
        tileWidth: width,
        tileHeight: height,
        visualBuilder: timeResizeHandleBuilder,
        onPointerDown: (e, edge, pointer) =>
            onResizePointerDown?.call(e, edge, pointer),
      ),
    );
    children.add(
      _TimeResizeHandle(
        edge: MCalResizeEdge.end,
        event: event,
        handleSize: handleSize,
        tileWidth: width,
        tileHeight: height,
        visualBuilder: timeResizeHandleBuilder,
        onPointerDown: (e, edge, pointer) =>
            onResizePointerDown?.call(e, edge, pointer),
      ),
    );

    return Stack(clipBehavior: Clip.none, children: children);
  }

  /// Builds the event tile (custom or default).
  Widget _buildEventTile(
    BuildContext context,
    MCalCalendarEvent event,
    MCalTimedEventTileContext tileContext,
  ) {
    // Format time for display
    final startTimeStr = DateFormat('h:mm a').format(event.start);
    final endTimeStr = DateFormat('h:mm a').format(event.end);
    final timeRange = '$startTimeStr - $endTimeStr';

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

    // Use custom builder if provided
    if (timedEventTileBuilder != null) {
      return Semantics(
        label: semanticLabel,
        button: true,
        child: timedEventTileBuilder!(context, event, tileContext),
      );
    }

    // Default tile
    final tileColor = theme.ignoreEventColors
        ? (theme.eventTileBackgroundColor ?? Colors.blue)
        : (event.color ?? theme.eventTileBackgroundColor ?? Colors.blue);

    final contrastColor = _getContrastColor(tileColor);
    final timeColor = contrastColor.withValues(alpha: 0.9);
    final showTimeRange = tileContext.endTime
            .difference(tileContext.startTime)
            .inMinutes >=
        30;

    return Semantics(
      label: semanticLabel,
      button: true,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: tileColor.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(
            theme.eventTileCornerRadius ?? 4.0,
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
      ),
    );
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
    final titleStyle = theme.eventTileTextStyle?.copyWith(
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
    this.visualBuilder,
    this.onPointerDown,
  });

  final MCalResizeEdge edge;
  final MCalCalendarEvent event;
  final double handleSize;
  final double tileWidth;
  final double tileHeight;
  final Widget Function(BuildContext, MCalCalendarEvent, MCalResizeEdge)?
  visualBuilder;
  final void Function(MCalCalendarEvent, MCalResizeEdge, int)? onPointerDown;

  @override
  Widget build(BuildContext context) {
    // Build visual: custom builder or default horizontal line
    final visual = visualBuilder != null
        ? visualBuilder!(context, event, edge)
        : Container(
            width: tileWidth - 8,
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(1),
            ),
          );

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
      left: 0,
      right: 0,
      height: handleSize,
      child: child,
    );
  }
}
