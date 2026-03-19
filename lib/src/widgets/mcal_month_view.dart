import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../controllers/mcal_event_controller.dart';
import '../models/mcal_calendar_event.dart';
import '../models/mcal_month_key_bindings.dart';
import '../models/mcal_recurrence_exception.dart';
import '../models/mcal_region.dart';
import '../models/mcal_recurrence_rule.dart';
import '../styles/mcal_theme.dart';
import '../utils/date_utils.dart';
import '../utils/mcal_date_format_utils.dart';
import '../utils/mcal_scroll_behavior.dart';
import '../utils/mcal_l10n_helper.dart';
import 'mcal_callback_details.dart';
import 'mcal_layout_directionality.dart';
import 'mcal_drag_handler.dart';
import 'mcal_month_view_contexts.dart';
import 'mcal_month_multi_day_renderer.dart';
import 'mcal_month_week_layout_contexts.dart';
import 'month_subwidgets/boundary_scroll_physics.dart';
import 'month_subwidgets/month_navigator_widget.dart';
import 'month_subwidgets/month_overlays.dart';
import 'month_subwidgets/month_page_widget.dart';
import 'month_subwidgets/weekday_header_row_widget.dart';

/// Builder callback for customizing week row event layout.
///
/// Receives [MCalMonthWeekLayoutContext] containing all events, dates, column widths,
/// and pre-wrapped builders for event tiles, date labels, and overflow indicators.
typedef MCalWeekLayoutBuilder =
    Widget Function(
      BuildContext context,
      MCalMonthWeekLayoutContext layoutContext,
    );

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

// ============================================================================
// MCalMonthView Widget
// ============================================================================

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
  /// Receives the build context, [MCalMonthDayHeaderContext] with header data, and
  /// the default header widget. Return a custom widget to override the default.
  final Widget Function(BuildContext, MCalMonthDayHeaderContext, Widget)?
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

  /// Callback invoked when a date label is double-tapped.
  ///
  /// When set, date labels respond to double-tap with this handler.
  /// Receives [BuildContext] and [MCalDateLabelTapDetails] with the date
  /// information.
  ///
  /// **Tap delay:** When set alongside [onDateLabelTap], the tap handler waits
  /// up to 200 ms before firing to allow double-tap disambiguation. Omit this
  /// callback if you do not need double-tap and want [onDateLabelTap] to fire
  /// immediately.
  final void Function(BuildContext, MCalDateLabelTapDetails)?
  onDateLabelDoubleTap;

  /// Callback invoked when an event tile is tapped.
  ///
  /// Receives the [BuildContext] and [MCalEventTapDetails] containing the
  /// tapped event and the date context for the tile.
  final void Function(BuildContext, MCalEventTapDetails)? onEventTap;

  /// Callback invoked when an event tile is long-pressed.
  ///
  /// Receives the [BuildContext] and [MCalEventTapDetails] containing the
  /// long-pressed event and the date context for the tile.
  ///
  /// **Note:** This callback is mutually exclusive with [enableDragToMove].
  /// When drag-to-move is enabled, the long-press gesture is consumed by the
  /// drag recognizer and this callback will not fire. Use [onEventTap] or
  /// [onEventDoubleTap] instead for event interactions when drag is enabled.
  final void Function(BuildContext, MCalEventTapDetails)? onEventLongPress;

  /// Callback invoked when a day cell is double-tapped.
  ///
  /// Receives the [BuildContext] and [MCalCellDoubleTapDetails] containing the
  /// double-tapped date, events, and tap position. Use this to create new
  /// events at the tapped location.
  ///
  /// **Tap delay:** When set alongside [onCellTap], the tap handler waits up
  /// to 200 ms before firing to allow double-tap disambiguation. Omit this
  /// callback if you do not need double-tap and want [onCellTap] to fire
  /// immediately.
  final void Function(BuildContext, MCalCellDoubleTapDetails)? onCellDoubleTap;

  /// Callback invoked when an event tile is double-tapped.
  ///
  /// Receives the [BuildContext] and [MCalEventDoubleTapDetails] containing the
  /// double-tapped event and tap position. Use this to open event editors.
  ///
  /// **Tap delay:** When set alongside [onEventTap], the tap handler waits up
  /// to 200 ms before firing to allow double-tap disambiguation. Omit this
  /// callback if you do not need double-tap and want [onEventTap] to fire
  /// immediately.
  final void Function(BuildContext, MCalEventDoubleTapDetails)?
  onEventDoubleTap;

  /// Callback invoked when a swipe navigation gesture is detected.
  ///
  /// Receives the [BuildContext] and [MCalSwipeNavigationDetails] containing
  /// the previous month, new month, and swipe direction.
  final void Function(BuildContext, MCalSwipeNavigationDetails)?
  onSwipeNavigation;

  /// Custom date format for date labels.
  ///
  /// If not provided, default formatting is used based on locale.
  final DateFormat? dateFormat;

  /// Locale for date formatting and localization.
  ///
  /// If not provided, the locale from the widget tree is used.
  final Locale? locale;

  /// Controls the direction used to render text within the calendar (event
  /// titles, day numbers, month names, etc.).
  ///
  /// This only affects text rendering — it does **not** control the visual
  /// layout of columns, navigation buttons, date cell sequencing, or swipe
  /// direction. Use [layoutDirection] for those concerns.
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
  /// calendar grid and navigation in an LTR layout.
  final TextDirection? textDirection;

  /// Controls the visual layout direction of the calendar — column ordering,
  /// navigation button positions, date cell sequencing, swipe direction, and
  /// event / date-label positioning within each week row.
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
  /// calendar grid and navigation in an LTR layout.
  final TextDirection? layoutDirection;

  // ============ Hover callbacks ============

  /// Callback invoked when the mouse hovers over a day cell.
  ///
  /// Receives the [BuildContext] and [MCalDayCellContext] for the hovered cell,
  /// or null when the mouse exits the cell. Useful for showing preview information or
  /// highlighting related elements.
  final void Function(BuildContext, MCalDayCellContext?)? onHoverCell;

  /// Callback invoked when the mouse hovers over an event tile.
  ///
  /// Receives the [BuildContext] and [MCalEventTileContext] for the hovered event,
  /// or null when the mouse exits the event tile. Useful for showing event details in a
  /// tooltip or preview panel.
  final void Function(BuildContext, MCalEventTileContext?)? onHoverEvent;

  /// Callback invoked when the mouse hovers over a date label.
  ///
  /// Receives the [BuildContext] and [MCalDateLabelContext] for the hovered date label,
  /// or null when the mouse exits the date label. Useful for showing preview information
  /// or highlighting related elements.
  final void Function(BuildContext, MCalDateLabelContext?)? onHoverDateLabel;

  /// Callback invoked when the mouse hovers over an overflow indicator.
  ///
  /// Receives the [BuildContext] and [MCalOverflowTapDetails] for the hovered overflow,
  /// or null when the mouse exits the overflow indicator. Useful for showing preview
  /// of hidden events or tooltip information.
  final void Function(BuildContext, MCalOverflowTapDetails?)? onHoverOverflow;

  /// Callback invoked when the mouse hovers over a day-of-week header
  /// (e.g. "Mon", "Tue").
  ///
  /// Receives [BuildContext] and [MCalMonthDayHeaderContext] for the hovered
  /// header, or null when the mouse exits. Useful for highlighting or tooltips.
  final void Function(BuildContext, MCalMonthDayHeaderContext?)?
  onHoverDayOfWeekHeader;

  // ============ Keyboard navigation ============

  /// Whether keyboard navigation is enabled.
  ///
  /// When true, users can navigate between cells using arrow keys, Enter to
  /// select, and other keyboard shortcuts. Defaults to true.
  final bool enableKeyboardNavigation;

  // keyboardShortcuts removed — global Shortcuts/Actions wiring for Month View
  // was replaced by the four-mode key event handler. Use [keyBindings] to
  // configure which keys trigger each action.

  /// Custom key bindings for the four-mode keyboard navigation state machine.
  ///
  /// When null, the default bindings from [MCalMonthKeyBindings] are used.
  /// Use [MCalMonthKeyBindings.copyWith] to override specific actions while
  /// keeping all other defaults.
  ///
  /// ## Example — disabling keyboard delete
  ///
  /// ```dart
  /// MCalMonthView(
  ///   keyBindings: const MCalMonthKeyBindings(delete: []),
  /// )
  /// ```
  final MCalMonthKeyBindings? keyBindings;

  // ============ Keyboard CRUD callbacks ============

  /// Called when the user presses N (or the configured [MCalMonthKeyBindings.createEvent]
  /// key) while in Navigation Mode.
  ///
  /// The [BuildContext] passed is the calendar's build context — use it to show
  /// a dialog or navigate. The [DateTime] is the currently focused date
  /// (falling back to the displayed month's first day when no date is focused).
  ///
  /// The `bool` return is reserved for future library behaviour (e.g.
  /// auto-navigating focus to a newly created event). The library currently
  /// ignores the value but **awaits** the [Future] if one is returned, keeping
  /// the API path open without a breaking change.
  ///
  /// Return `true` synchronously for best performance; return a `Future<bool>`
  /// when an async confirmation dialog is involved.
  ///
  /// When `null`, the N key is absorbed with no action.
  ///
  /// **Only active in Navigation Mode.** Pressing the configured key in Event,
  /// Move, or Resize modes does not trigger this callback.
  final FutureOr<bool> Function(BuildContext context, DateTime date)?
      onCreateEventRequested;

  /// Called when the user requests to delete the focused event via keyboard
  /// (D, Delete, or Backspace while in Event Mode).
  ///
  /// The library never deletes events itself — the consumer must perform the
  /// actual removal (e.g. call [MCalEventController.removeEvent]).
  ///
  /// Return `true` if the event was deleted (the library exits the current
  /// keyboard mode). Return `false` to cancel (stays in the current mode).
  ///
  /// For synchronous deletes, return `true` directly for best performance.
  /// For async operations (e.g. confirmation dialogs), return a `Future<bool>`.
  ///
  /// If `null`, the keyboard delete shortcuts are disabled.
  final FutureOr<bool> Function(BuildContext context, MCalEventTapDetails details)?
      onDeleteEventRequested;

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

  /// Callback invoked when the overflow indicator ("+N more") is double-tapped.
  ///
  /// Receives the [BuildContext] and [MCalOverflowTapDetails] containing the
  /// date of the cell, the complete list of events for that date, and the
  /// number of hidden events. Useful for alternative interaction patterns.
  ///
  /// **Note:** The overflow indicator does not support drag-and-drop. Only
  /// visible event tiles can be dragged.
  ///
  /// **Tap delay:** When set alongside [onOverflowTap], the tap handler waits
  /// up to 200 ms before firing to allow double-tap disambiguation. Omit this
  /// callback if you do not need double-tap and want [onOverflowTap] to fire
  /// immediately.
  final void Function(BuildContext, MCalOverflowTapDetails)?
  onOverflowDoubleTap;

  /// Callback invoked when a day cell is right-clicked or two-finger tapped.
  ///
  /// Receives the [BuildContext] and [MCalCellTapDetails] containing the
  /// date, list of events, and whether the date is in the current month.
  final void Function(BuildContext, MCalCellTapDetails)? onCellSecondaryTap;

  /// Callback invoked when a date label is right-clicked or two-finger tapped.
  ///
  /// Receives the [BuildContext] and [MCalDateLabelTapDetails] containing the
  /// date information for the label that was secondary-tapped.
  final void Function(BuildContext, MCalDateLabelTapDetails)?
  onDateLabelSecondaryTap;

  /// Callback invoked when an event tile is right-clicked or two-finger tapped.
  ///
  /// Receives the [BuildContext] and [MCalEventTapDetails] containing the
  /// event and the date context for the tile.
  final void Function(BuildContext, MCalEventTapDetails)? onEventSecondaryTap;

  /// Callback invoked when the overflow indicator ("+N more") is right-clicked
  /// or two-finger tapped.
  ///
  /// Receives the [BuildContext] and [MCalOverflowTapDetails] containing the
  /// date, hidden events, and visible events.
  final void Function(BuildContext, MCalOverflowTapDetails)?
  onOverflowSecondaryTap;

  /// Callback invoked when a day-of-week header is tapped.
  ///
  /// Receives [BuildContext] and [MCalMonthDayHeaderContext] with the day of
  /// week index and the localized day name.
  final void Function(BuildContext, MCalMonthDayHeaderContext)?
  onDayOfWeekHeaderTap;

  /// Callback invoked when a day-of-week header is long-pressed.
  ///
  /// Receives [BuildContext] and [MCalMonthDayHeaderContext] with the day of
  /// week index and the localized day name.
  final void Function(BuildContext, MCalMonthDayHeaderContext)?
  onDayOfWeekHeaderLongPress;

  /// Callback invoked when a day-of-week header is double-tapped.
  ///
  /// Receives [BuildContext] and [MCalMonthDayHeaderContext] with the day of
  /// week index and the localized day name.
  ///
  /// **Tap delay:** When set alongside [onDayOfWeekHeaderTap], the tap handler
  /// waits up to 200 ms before firing to allow double-tap disambiguation. Omit
  /// this callback if you do not need double-tap and want
  /// [onDayOfWeekHeaderTap] to fire immediately.
  final void Function(BuildContext, MCalMonthDayHeaderContext)?
  onDayOfWeekHeaderDoubleTap;

  /// Callback invoked when a day-of-week header is right-clicked or
  /// two-finger tapped.
  ///
  /// Receives [BuildContext] and [MCalMonthDayHeaderContext] with the day of
  /// week index and the localized day name.
  final void Function(BuildContext, MCalMonthDayHeaderContext)?
  onDayOfWeekHeaderSecondaryTap;

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
  /// Receives the build context, [MCalMonthOverflowIndicatorContext] with overflow data,
  /// and the default indicator widget. Return a custom widget to override the default.
  ///
  /// **Note:** The overflow indicator does not support drag-and-drop. Only
  /// visible event tiles can be dragged.
  final Widget Function(
    BuildContext,
    MCalMonthOverflowIndicatorContext,
    Widget,
  )?
  overflowIndicatorBuilder;

  // ============ Day Regions ============

  /// Builder callback for customizing how a day region overlay is rendered.
  ///
  /// When provided, called for each [MCalRegion] (with `isAllDay: true`) that
  /// applies to a visible cell. The builder receives a [MCalRegionContext]
  /// describing the region and the cell, plus the [defaultWidget] produced by
  /// the built-in renderer. Return [defaultWidget] to keep the default
  /// appearance.
  ///
  /// Regions are added to the controller via [MCalEventController.addRegions].
  ///
  /// If null, the built-in renderer is used for all regions.
  final Widget Function(
    BuildContext context,
    MCalRegionContext regionContext,
    Widget defaultWidget,
  )?
  dayRegionBuilder;

  // ============ Drag-and-Drop ============

  /// Whether drag-and-drop functionality is enabled for event tiles.
  ///
  /// When true, event tiles can be dragged to other day cells using a
  /// long-press gesture. Day cells become drop targets that accept events.
  ///
  /// Defaults to false.
  final bool enableDragToMove;

  /// Builder callback for customizing the dragged tile feedback widget.
  ///
  /// When provided, this builder creates the visual representation of the
  /// tile while it's being dragged. Receives [MCalDraggedTileDetails] with
  /// the event, source date, and current drag position.
  ///
  /// If not provided, the default feedback is the tile with elevation.
  ///
  /// Only used when [enableDragToMove] is true.
  final Widget Function(BuildContext, MCalDraggedTileDetails, Widget)?
  draggedTileBuilder;

  /// Builder callback for customizing the drag source placeholder widget.
  ///
  /// When provided, this builder creates the placeholder widget shown at
  /// the original tile position while dragging. Receives [MCalDragSourceDetails]
  /// with the event and source date.
  ///
  /// If not provided, the default placeholder is the tile with 50% opacity.
  ///
  /// Only used when [enableDragToMove] is true.
  final Widget Function(BuildContext, MCalDragSourceDetails, Widget)?
  dragSourceTileBuilder;

  /// Builder callback for customizing the drag target preview widget.
  ///
  /// When true (and [enableDragToMove] is true), drop target preview tiles
  /// (Layer 3) are shown during drag. Defaults to true.
  final bool showDropTargetTiles;

  /// When true (and [enableDragToMove] is true), the drop target cell overlay
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
  /// are true and [enableDragToMove] is true.
  final bool dropTargetTilesAboveOverlay;

  /// Optional builder for drop target preview tiles (Layer 3).
  ///
  /// When provided, this builder creates a preview widget shown when
  /// hovering over a potential drop target. Receives [MCalEventTileContext]
  /// with [isDropTargetPreview] true and [dropValid], [proposedStartDate],
  /// [proposedEndDate] set. If null, a default tile (same shape, no text) is used.
  ///
  /// Only used when [enableDragToMove] and [showDropTargetTiles] are true.
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
  /// Only used when [enableDragToMove] is true.
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
  /// Only used when [enableDragToMove] is true.
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
  /// Only used when [enableDragToMove] is true.
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
  /// Only used when [enableDragToMove] is true.
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
  /// Resize is independent of [enableDragToMove] — events can have resize
  /// handles without drag-to-move being enabled.
  final bool? enableDragToResize;

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

  /// Optional builder for the visual part of resize handles.
  ///
  /// When provided, replaces the default 2x16px semi-transparent white bar
  /// on both event tile handles and drop-target preview tile handles.
  /// The framework still handles hit testing, cursor feedback, and
  /// positioning — this builder only controls the visual indicator.
  ///
  /// The [MCalResizeHandleContext] tells the builder which edge
  /// ([MCalResizeEdge.start] or [MCalResizeEdge.end]) the handle
  /// represents and whether it is on a drop-target preview tile.
  ///
  /// Only used when [enableDragToResize] resolves to `true`.
  final Widget Function(BuildContext context, MCalResizeHandleContext)?
  resizeHandleBuilder;

  /// Optional callback that returns a horizontal inset (in logical pixels)
  /// for a resize handle.
  ///
  /// Positive values shift the handle (both visual and interactive hit area)
  /// inward from the tile edge. This is useful for custom tile builders
  /// where the visual content is narrower than the tile slot — for example,
  /// a centered half-width pill where the handles should align with the pill
  /// edges rather than the outer tile boundaries.
  ///
  /// The callback receives the full [MCalEventTileContext] so it can
  /// differentiate (e.g.) all-day events from timed events, and the
  /// [MCalResizeEdge] indicating which edge is being positioned.
  ///
  /// Returns `0.0` equivalent when `null` (no inset).
  ///
  /// Only used when [enableDragToResize] resolves to `true`.
  final double Function(MCalEventTileContext, MCalResizeEdge)?
  resizeHandleInset;

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
  /// Only used when [enableDragToMove] is true.
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
  /// Only used when [enableDragToMove] and [dragEdgeNavigationEnabled] are true.
  final Duration dragEdgeNavigationDelay;

  /// The long-press delay before a drag operation starts.
  ///
  /// The delay before initiating a long-press drag.
  ///
  /// Controls how long the user must hold down on an event tile before a drag
  /// begins. A shorter delay makes drags start faster; a longer delay reduces
  /// accidental drags when tapping.
  ///
  /// When [enableDragToMove] is true, the long-press gesture is reserved for
  /// drag initiation and [onEventLongPress] will not fire. Use [onEventTap] or
  /// [onEventDoubleTap] for event interactions when drag is enabled.
  ///
  /// Defaults to 200 milliseconds. Only used when [enableDragToMove] is true.
  final Duration dragLongPressDelay;

  /// Creates a new [MCalMonthView] widget.
  ///
  /// The [controller] parameter is required. All other parameters are optional.
  const MCalMonthView({
    super.key,
    required this.controller,
    this.minDate,
    this.maxDate,
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
    this.onDateLabelDoubleTap,
    this.onEventTap,
    this.onEventLongPress,
    this.onCellDoubleTap,
    this.onEventDoubleTap,
    this.onSwipeNavigation,
    this.dateFormat,
    this.locale,
    this.textDirection,
    this.layoutDirection,
    // Hover callbacks
    this.onHoverCell,
    this.onHoverEvent,
    this.onHoverDateLabel,
    this.onHoverOverflow,
    this.onHoverDayOfWeekHeader,
    // Keyboard navigation
    this.enableKeyboardNavigation = true,
    this.keyBindings,
    // Keyboard CRUD callbacks
    this.onCreateEventRequested,
    this.onDeleteEventRequested,
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
    this.onOverflowDoubleTap,
    // Secondary tap handlers
    this.onCellSecondaryTap,
    this.onDateLabelSecondaryTap,
    this.onEventSecondaryTap,
    this.onOverflowSecondaryTap,
    // Day-of-week header tap handlers
    this.onDayOfWeekHeaderTap,
    this.onDayOfWeekHeaderLongPress,
    this.onDayOfWeekHeaderDoubleTap,
    this.onDayOfWeekHeaderSecondaryTap,
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
    // Day regions
    this.dayRegionBuilder,
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
    // Event resize
    this.enableDragToResize,
    this.onResizeWillAccept,
    this.onEventResized,
    this.resizeHandleBuilder,
    this.resizeHandleInset,
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
  // Resize Pointer Tracking State (parent-level, survives page changes)
  // ============================================================

  /// GlobalKey for the grid area (the Expanded wrapping the PageView) to
  /// obtain its render box for position-to-date conversion during resize.
  final GlobalKey _gridAreaKey = GlobalKey();

  /// The pointer ID currently involved in a resize gesture, or null.
  int? _resizeActivePointer;

  /// Whether the drag threshold has been crossed and the resize has started.
  bool _resizeGestureStarted = false;

  /// Accumulated horizontal movement during the threshold phase.
  double _resizeDxAccumulated = 0.0;

  /// The event targeted by the pending/active resize.
  MCalCalendarEvent? _pendingResizeEvent;

  /// The edge targeted by the pending/active resize.
  MCalResizeEdge? _pendingResizeEdge;

  /// Scroll hold controller that freezes the [PageView] during resize.
  ScrollHoldController? _resizeScrollHold;

  /// Whether a resize is in progress, used to set NeverScrollableScrollPhysics
  /// on the PageView to prevent user swiping during the gesture.
  bool _isResizeInProgress = false;

  /// The last known global pointer position during resize, used to
  /// recompute the resize preview after cross-month edge navigation.
  Offset? _lastResizePointerPosition;

  /// Minimum pointer movement (in logical pixels) before a resize starts.
  static const double _resizeDragThreshold = 4.0;

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

  /// Whether the overflow indicator is currently keyboard-focused in Event Mode.
  bool _isKeyboardOverflowFocused = false;

  /// Caches the actual visible event count per date as computed by the layout.
  ///
  /// Updated by [WeekRowWidgetState._buildLayer2Events] during build.
  /// Only contains entries for dates with overflow (visible count < total).
  /// Dates without an entry are assumed to have all events visible.
  final Map<String, int> _layoutVisibleCounts = {};

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
    _previousFocusedDate = widget.controller.focusedDateTime;

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
    // Clean up resize pointer tracking state
    _cleanupResizePointerState();
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
  /// Reacts to displayDate and focusedDateTime changes.
  void _onControllerChanged() {
    if (!mounted) return;

    final currentDisplayDate = _currentMonth;
    final currentFocusedDateTime = widget.controller.focusedDateTime;

    // Check if display date changed
    final displayDateChanged =
        _previousDisplayDate == null ||
        currentDisplayDate.year != _previousDisplayDate!.year ||
        currentDisplayDate.month != _previousDisplayDate!.month;

    // Check if focused DATE changed (ignore time-only changes from Day View).
    // dateOnly() takes non-nullable DateTime, so use a null-safe pattern.
    final previousDateOnly =
        _previousFocusedDate != null ? dateOnly(_previousFocusedDate!) : null;
    final currentDateOnly =
        currentFocusedDateTime != null ? dateOnly(currentFocusedDateTime) : null;
    final focusedDateChanged = previousDateOnly != currentDateOnly;

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
      // Store full precision for accurate future diffs.
      _previousFocusedDate = currentFocusedDateTime;

      // Fire onFocusedDateChanged with the date-only value (existing API).
      widget.onFocusedDateChanged?.call(currentDateOnly);

      // Fire onFocusedRangeChanged callback (single date range when focused)
      if (currentDateOnly != null) {
        final focusedRange = DateTimeRange(
          start: currentDateOnly,
          end: DateTime(
            currentDateOnly.year,
            currentDateOnly.month,
            currentDateOnly.day,
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
  /// [MCalMonthView.enableDragToResize] setting and platform detection.
  ///
  /// - If [MCalMonthView.enableDragToResize] is explicitly `true` or `false`,
  ///   that value is returned directly (developer override).
  /// - If `null` (the default), auto-detection enables resize on web,
  ///   desktop (macOS, Windows, Linux), and tablets (shortest side >= 600dp),
  ///   but disables it on phones.
  ///
  /// Consistent with [MCalDayView._resolveDragToResize], which also resolves
  /// independently of drag-to-move.
  bool _resolveDragToResize(BuildContext context) {
    // Explicit override takes precedence
    if (widget.enableDragToResize != null) return widget.enableDragToResize!;

    // Auto-detect: enabled on web (when not phone-sized), desktop, and tablets; disabled on phones
    final size = MediaQuery.sizeOf(context);
    if (kIsWeb) return size.shortestSide >= 600;

    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.macOS ||
        platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux) {
      return true;
    }

    // Mobile: enabled on tablets (shortest side >= 600dp)
    return size.shortestSide >= 600;
  }

  /// Always null — Event Mode uses `selected` state directly (no highlighted phase).
  String? get _keyboardHighlightedEventId => null;

  /// The event ID currently selected in Event Mode or keyboard move/resize mode.
  ///
  /// In Event Mode (`_isKeyboardEventSelectionMode && !_isKeyboardMoveMode`),
  /// returns the event at the current cycle index (null when overflow is focused).
  /// In Move/Resize Mode, returns the event being moved/resized.
  String? get _keyboardSelectedEventId {
    if (_isKeyboardMoveMode) return _keyboardMoveEvent?.id;
    if (!_isKeyboardEventSelectionMode) return null;
    if (_isKeyboardOverflowFocused) return null;
    final focusedDate = widget.controller.focusedDateTime != null
        ? dateOnly(widget.controller.focusedDateTime!)
        : widget.controller.displayDate;
    final dayEvents = _getSortedEventsForDate(focusedDate);
    final visibleCount = _visibleCountForDate(focusedDate, dayEvents);
    if (dayEvents.isEmpty || visibleCount == 0) return null;
    final index = _keyboardMoveEventIndex.clamp(0, visibleCount - 1);
    return dayEvents[index].id;
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
    final localizations = MCalDateFormatUtils();
    final monthYearText = localizations.formatMonthYear(month, locale);

    // Announce the new month to screen readers
    // Use sendAnnouncement for compatibility with multiple windows
    final view = View.of(context);
    SemanticsService.sendAnnouncement(
      view,
      monthYearText,
      Directionality.of(context),
    );
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
    final firstDayOfWeek = widget.controller.resolvedFirstDayOfWeek;
    final gridRange = getVisibleGridRange(month, firstDayOfWeek);
    return widget.controller.getEventsForRange(gridRange);
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
    bool isLayoutRTL,
  ) {
    // Task 9: Determine scroll physics based on swipe navigation setting and boundaries.
    // During an active resize, use NeverScrollableScrollPhysics to prevent the
    // PageView from stealing the horizontal drag gesture. Programmatic navigation
    // (jumpToPage) still works regardless of the physics setting.
    final ScrollPhysics physics;
    if (_isResizeInProgress) {
      physics = const NeverScrollableScrollPhysics();
    } else if (widget.enableSwipeNavigation) {
      // Use custom boundary physics with snappy (non-bouncy) page snapping
      physics = MCalBoundaryScrollPhysics(
        parent: const MCalSnappyPageScrollPhysics(),
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
      scrollBehavior: const MCalMultiDeviceScrollBehavior(),
      onPageChanged: _onPageChanged,
      // Determine scroll direction based on swipe navigation direction setting
      scrollDirection:
          widget.swipeNavigationDirection ==
              MCalSwipeNavigationDirection.vertical
          ? Axis.vertical
          : Axis.horizontal,
      // Never reverse: standard calendar convention (swipe left = next month,
      // swipe right = previous month) applies regardless of locale. Reversing
      // for RTL would also flip programmatic animateToPage() calls, making
      // the button-triggered slide animation go the wrong way.
      reverse: false,
      itemBuilder: (context, pageIndex) {
        // Convert page index to month and build the grid for that month
        final month = _pageIndexToMonth(pageIndex);
        return MonthPageWidget(
          month: month,
          currentDisplayMonth: _currentMonth,
          events: _events,
          theme: resolvedTheme,
          locale: resolvedLocale,
          controller: widget.controller,
          getRecurrenceMetadata: _getRecurrenceMetadata,
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
          onCellDoubleTap: widget.onCellDoubleTap,
          onEventDoubleTap: widget.onEventDoubleTap,
          onHoverCell: widget.onHoverCell,
          onHoverEvent: widget.onHoverEvent,
          onHoverDateLabel: widget.onHoverDateLabel,
          onHoverOverflow: widget.onHoverOverflow,
          maxVisibleEventsPerDay: widget.maxVisibleEventsPerDay,
          onOverflowTap: widget.onOverflowTap,
          onOverflowLongPress: widget.onOverflowLongPress,
          onOverflowDoubleTap: null, // Not used in PageView mode yet
          onOverflowSecondaryTap: widget.onOverflowSecondaryTap,
          onDateLabelDoubleTap: null, // Not used in PageView mode yet
          onCellSecondaryTap: widget.onCellSecondaryTap,
          onDateLabelSecondaryTap: widget.onDateLabelSecondaryTap,
          onEventSecondaryTap: widget.onEventSecondaryTap,
          showWeekNumbers: widget.showWeekNumbers,
          weekNumberBuilder: widget.weekNumberBuilder,
          autoFocusOnCellTap: widget.autoFocusOnCellTap,
          getEventsForMonth: _getEventsForMonth,
          // Week layout customization
          weekLayoutBuilder: widget.weekLayoutBuilder,
          overflowIndicatorBuilder: widget.overflowIndicatorBuilder,
          // Drag-and-drop
          enableDragToMove: widget.enableDragToMove,
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
          dragHandler: widget.enableDragToMove ? _ensureDragHandler : null,
          enableDragToResize: _resolveDragToResize(context),
          onResizeWillAccept: widget.onResizeWillAccept,
          onEventResized: widget.onEventResized,
          resizeHandleBuilder: widget.resizeHandleBuilder,
          resizeHandleInset: widget.resizeHandleInset,
          onResizePointerDownCallback: _handleResizePointerDownFromChild,
          // Keyboard selection state
          keyboardHighlightedEventId: _keyboardHighlightedEventId,
          keyboardSelectedEventId: _keyboardSelectedEventId,
          keyboardOverflowFocusedDate:
              (_isKeyboardEventSelectionMode && _isKeyboardOverflowFocused)
                  ? (widget.controller.focusedDateTime != null
                        ? dateOnly(widget.controller.focusedDateTime!)
                        : widget.controller.displayDate)
                  : null,
          layoutVisibleCounts: _layoutVisibleCounts,
          // Day regions
          dayRegionBuilder: widget.dayRegionBuilder,
        );
      },
    );

    return pageView;
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

  /// Resolves the effective text [TextDirection] for the calendar using the
  /// priority chain documented on [MCalMonthView.textDirection].
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
  /// priority chain documented on [MCalMonthView.layoutDirection].
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

  // ============================================================================
  // Keyboard Shortcut Helpers
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    // Resolve theme and locale ONCE at the top of build() and pass down
    // to avoid multiple resolutions in child widgets
    final theme = _resolveTheme(context);
    final locale = widget.locale ?? Localizations.localeOf(context);
    final firstDayOfWeek = widget.controller.resolvedFirstDayOfWeek;
    // Resolve text and layout directions independently via the documented
    // priority chains. textDirection drives text rendering (the outer
    // Directionality wrapper). layoutDirection drives all visual layout logic
    // (column ordering, navigation direction, swipe, drag edge detection) via
    // the MCalLayoutDirectionality InheritedWidget placed inside the wrapper.
    final textDirection = _resolveTextDirection(context);
    final layoutDirection = _resolveLayoutDirection(context);
    final isLayoutRTL = layoutDirection == TextDirection.rtl;

    // Build the main calendar content (ClipRect prevents overflow errors)
    final calendarContent = ClipRect(
      child: Column(
        children: [
          if (widget.showNavigator)
            MonthNavigatorWidget(
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
          WeekdayHeaderRowWidget(
            firstDayOfWeek: firstDayOfWeek,
            theme: theme,
            dayHeaderBuilder: widget.dayHeaderBuilder,
            locale: locale,
            showWeekNumbers: widget.showWeekNumbers,
            onHoverDayOfWeekHeader: widget.onHoverDayOfWeekHeader,
            onDayOfWeekHeaderTap: widget.onDayOfWeekHeaderTap,
            onDayOfWeekHeaderLongPress: widget.onDayOfWeekHeaderLongPress,
            onDayOfWeekHeaderDoubleTap: widget.onDayOfWeekHeaderDoubleTap,
            onDayOfWeekHeaderSecondaryTap:
                widget.onDayOfWeekHeaderSecondaryTap,
          ),
          Expanded(
            key: _gridAreaKey,
            child: _buildMonthGridWithRTL(context, theme, locale, isLayoutRTL),
          ),
        ],
      ),
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
        overlay = ErrorOverlay(
          error: error,
          onRetry: retryCallback,
          theme: theme,
        );
      }
    } else if (widget.controller.isLoading) {
      if (widget.loadingBuilder != null) {
        overlay = widget.loadingBuilder!(context);
      } else {
        overlay = LoadingOverlay(theme: theme);
      }
    }

    // Use Stack to layer overlays on top of the calendar
    final content = Stack(
      children: [calendarContent, if (overlay != null) overlay],
    );

    // Alias for readability — no Shortcuts/Actions wrapper needed because the
    // Focus.onKeyEvent handler in the four-mode state machine now owns all
    // keyboard routing for Month View.
    final shortcutsContent = content;

    // Generate default semantics label if not provided
    final l10n = mcalL10n(context);
    final localizations = MCalDateFormatUtils();
    final defaultSemanticsLabel =
        '${l10n.calendar}, ${localizations.formatMonthYear(_currentMonth, locale)}';
    final semanticsLabel = widget.semanticsLabel ?? defaultSemanticsLabel;

    // Wrap in Focus widget for keyboard navigation and drag cancellation (Task 21)
    // Use Listener to capture pointer events and request focus without
    // competing with child gesture detectors
    // Wrap entire widget tree with MCalTheme so descendants can access theme via MCalTheme.of(context)
    // Use LayoutBuilder to get the calendar size for edge detection during drag
    // Enable key events if keyboard navigation OR drag-and-drop is enabled
    // (drag-and-drop needs Escape key for cancellation)
    final enableKeyEvents =
        widget.enableKeyboardNavigation || widget.enableDragToMove;

    // Wrap the entire calendar in two layers:
    // • Outer Directionality(textDirection): drives text rendering direction
    //   for all Text widgets — event titles, date labels, month names, etc.
    // • Inner MCalLayoutDirectionality(isLayoutRTL): carries layout direction used
    //   by all explicit isLayoutRTL checks (column ordering, nav arrow actions,
    //   drag/drop geometry, week-number placement). Row/Column widgets that
    //   rely on ambient Directionality for ordering use textDirection, which
    //   is expected for the common case where both are the same. When they
    //   differ the caller has explicitly chosen an unconventional combination.
    return Directionality(
      textDirection: textDirection,
      child: MCalLayoutDirectionality(
        isLayoutRTL: isLayoutRTL,
        child: MCalTheme(
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
                      if (widget.enableDragToMove && _isDragActive) {
                        _handleDragPositionUpdate(event.position, calendarSize);
                      }
                      // Track resize pointer events at parent level so the
                      // gesture survives across page transitions.
                      _handleResizePointerMoveFromParent(event);
                    },
                    onPointerUp: (event) {
                      // Handle resize pointer up at parent level.
                      // Note: drag-to-move cleanup uses LongPressDraggable.onDragEnd,
                      // not onPointerUp, so this doesn't interfere.
                      _handleResizePointerUpFromParent(event);
                    },
                    onPointerCancel: (event) {
                      // Clean up drag state when pointer is cancelled
                      if (_isDragActive) {
                        _handleDragCancelled();
                      }
                      // Clean up resize state when pointer is cancelled
                      _handleResizePointerCancelFromParent(event);
                    },
                    child: shortcutsContent,
                  );
                },
              ),
            ),
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

    // Obtain localization for announcements
    final l10n = mcalL10n(context);

    // Handle Escape key — works even if keyboard navigation is disabled.
    // Priority: keyboard resize mode > keyboard move mode > Event Mode > pointer drag.
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (_isKeyboardResizeMode) {
        // Cancel resize, return to Event Mode (not Move Mode)
        _returnToEventMode();
        _isKeyboardEventSelectionMode = true;
        setState(() {});
        SemanticsService.sendAnnouncement(
          View.of(context),
          l10n.announcementResizeCancelled,
          Directionality.of(context),
        );
        return KeyEventResult.handled;
      }
      if (_isKeyboardMoveMode) {
        // Cancel move, return to Event Mode (not Navigation Mode)
        final title = _keyboardMoveEvent?.title ?? 'event';
        _returnToEventMode();
        _isKeyboardEventSelectionMode = true;
        setState(() {});
        SemanticsService.sendAnnouncement(
          View.of(context),
          l10n.announcementMoveCancelled(title),
          Directionality.of(context),
        );
        return KeyEventResult.handled;
      }
      if (_isKeyboardEventSelectionMode) {
        _exitKeyboardMoveMode();
        setState(() {});
        SemanticsService.sendAnnouncement(
          View.of(context),
          l10n.announcementEventSelectionCancelled,
          Directionality.of(context),
        );
        return KeyEventResult.handled;
      }
      if (widget.enableDragToMove && _isDragActive) {
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

    // Handle Event Mode (cycle events, Enter fires tap, M/R enter Move/Resize)
    if (_isKeyboardEventSelectionMode && !_isKeyboardMoveMode) {
      return _handleKeyboardEventModeKey(event);
    }

    // Handle keyboard move mode (arrow keys move, Enter confirms, R enters resize)
    if (_isKeyboardMoveMode) {
      return _handleKeyboardMoveModeKey(event);
    }

    // Get or initialize the focused date (date-only; Month View has no time concept)
    DateTime focusedDate = widget.controller.focusedDateTime != null
        ? dateOnly(widget.controller.focusedDateTime!)
        : widget.controller.displayDate;

    // If no focused date-time was set, set it now (Month View always passes isAllDay: true)
    if (widget.controller.focusedDateTime == null) {
      widget.controller.setFocusedDateTime(focusedDate, isAllDay: true);
    }

    final key = event.logicalKey;
    DateTime? newFocusedDate;
    bool handled = false;

    // RTL support: reverse arrow keys in RTL layout mode
    final isLayoutRTL = MCalLayoutDirectionality.of(context);
    final rtlMult = isLayoutRTL ? -1 : 1;

    // Arrow key navigation
    // Use calendar-day arithmetic (not Duration) to avoid DST issues.
    // On DST fall-back (e.g. Nov 2, 2025 US), Duration(days: 1) = 24h can
    // land on the same calendar day at 23:00 instead of the next day.
    if (key == LogicalKeyboardKey.arrowLeft) {
      newFocusedDate = addDays(focusedDate, -1 * rtlMult);
      handled = true;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      newFocusedDate = addDays(focusedDate, 1 * rtlMult);
      handled = true;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      newFocusedDate = addDays(focusedDate, -7);
      handled = true;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      newFocusedDate = addDays(focusedDate, 7);
      handled = true;
    }
    // Home - first day of current month
    else if (_matchesAny(_keyBindings.home, key)) {
      newFocusedDate = DateTime(focusedDate.year, focusedDate.month, 1);
      handled = true;
    }
    // End - last day of current month
    else if (_matchesAny(_keyBindings.end, key)) {
      newFocusedDate = DateTime(focusedDate.year, focusedDate.month + 1, 0);
      handled = true;
    }
    // Page Up - previous month
    else if (_matchesAny(_keyBindings.pageUp, key)) {
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
    else if (_matchesAny(_keyBindings.pageDown, key)) {
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
    // Enter/Space - enter Event Mode if drag-and-drop is enabled and the
    // focused cell has events; otherwise trigger normal cell tap.
    else if (_matchesAny(_keyBindings.enterEventMode, key) ||
        key == LogicalKeyboardKey.numpadEnter) {
      if (widget.enableDragToMove) {
        final dayEvents = _getSortedEventsForDate(focusedDate);
        if (dayEvents.isNotEmpty) {
          _enterKeyboardEventMode(focusedDate);
          return KeyEventResult.handled;
        }
      }
      // No events or drag-and-drop disabled: fall through to cell tap
      _triggerCellTapForFocusedDate(focusedDate);
      return KeyEventResult.handled;
    }

    // N (or configured createEvent key): invoke onCreateEventRequested
    if (_matchesAny(_keyBindings.createEvent, key)) {
      final callback = widget.onCreateEventRequested;
      if (callback != null) {
        final result = callback(context, focusedDate);
        if (result is Future<bool>) {
          result.ignore();
        }
      }
      // Absorb the key even when the callback is null so the key event does
      // not propagate to ancestor widgets (e.g. browser shortcuts).
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

      // Preserve the existing time component and isFocusedOnAllDay so that a
      // shared Day View continues to highlight the same time slot on the new
      // day. If no prior focus exists the values default to midnight / true.
      final existingFocused = widget.controller.focusedDateTime;
      widget.controller.setFocusedDateTime(
        DateTime(
          newFocusedDate.year,
          newFocusedDate.month,
          newFocusedDate.day,
          existingFocused?.hour ?? 0,
          existingFocused?.minute ?? 0,
        ),
        isAllDay: widget.controller.isFocusedOnAllDay,
      );

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
      final eventStart = dateOnly(event.start);
      final eventEnd = dateOnly(event.end);
      final checkDate = dateOnly(focusedDate);
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
    final checkDate = dateOnly(date);
    return _events.where((event) {
      final eventStart = dateOnly(event.start);
      final eventEnd = dateOnly(event.end);
      return (checkDate.isAtSameMomentAs(eventStart) ||
          checkDate.isAtSameMomentAs(eventEnd) ||
          (checkDate.isAfter(eventStart) && checkDate.isBefore(eventEnd)));
    }).toList();
  }

  /// Returns events for [date] sorted by [MCalMultiDayRenderer.multiDayEventComparator].
  ///
  /// Produces the same display order used by [WeekRowWidgetState._getEventsForDate],
  /// ensuring keyboard cycling matches the visual order on screen.
  List<MCalCalendarEvent> _getSortedEventsForDate(DateTime date) {
    final events = _getEventsForDate(date);
    events.sort(MCalMultiDayRenderer.multiDayEventComparator);
    return events;
  }

  /// Returns the layout-computed visible event count for [date].
  ///
  /// Falls back to [allEvents].length when no layout data is available
  /// (e.g. before the first build or for dates whose row has no overflow).
  int _visibleCountForDate(DateTime date, List<MCalCalendarEvent> allEvents) {
    final key = '${date.year}-${date.month}-${date.day}';
    return _layoutVisibleCounts[key] ?? allEvents.length;
  }

  /// Returns the effective key bindings, falling back to defaults when
  /// [MCalMonthView.keyBindings] is null.
  MCalMonthKeyBindings get _keyBindings =>
      widget.keyBindings ?? const MCalMonthKeyBindings();

  /// Returns true if any activator in [activators] matches [eventKey] and the
  /// current modifier state from [HardwareKeyboard.instance].
  bool _matchesAny(
    List<MCalKeyActivator> activators,
    LogicalKeyboardKey eventKey,
  ) {
    final hw = HardwareKeyboard.instance;
    return activators.any(
      (a) => a.matches(
        eventKey,
        isShiftPressed: hw.isShiftPressed,
        isControlPressed: hw.isControlPressed,
        isMetaPressed: hw.isMetaPressed,
        isAltPressed: hw.isAltPressed,
      ),
    );
  }

  /// Clears all keyboard-move state fields (and keyboard-resize sub-mode).
  void _exitKeyboardMoveMode() {
    _exitKeyboardResizeMode();
    _isKeyboardMoveMode = false;
    _isKeyboardEventSelectionMode = false;
    _isKeyboardOverflowFocused = false;
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

  /// Enters Event Mode for [date].
  ///
  /// Immediately selects the first visible event (no intermediate highlighted
  /// phase). All Tab, arrow, and Enter keys are captured within the widget.
  void _enterKeyboardEventMode(DateTime date) {
    final events = _getSortedEventsForDate(date);
    if (events.isEmpty) return;
    final l10n = mcalL10n(context);
    _isKeyboardEventSelectionMode = true;
    _keyboardMoveEventIndex = 0;
    _isKeyboardOverflowFocused = false;
    setState(() {});
    SemanticsService.sendAnnouncement(
      View.of(context),
      l10n.announcementEventsHighlighted(
        events.length.toString(),
        events.first.title,
      ),
      Directionality.of(context),
    );
  }

  /// Selects the given [event] for keyboard move mode.
  ///
  /// Sets up the move state with the event's original dates and the proposed
  /// date initialized to the event's normalized start date.
  void _selectKeyboardMoveEvent(MCalCalendarEvent event) {
    final l10n = mcalL10n(context);
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
      l10n.announcementEventSelected(event.title),
      Directionality.of(context),
    );
  }

  /// Handles key events during Event Mode (cycling through events/overflow).
  ///
  /// - Up/Down/Tab/Shift+Tab: cycle through visible events + overflow indicator.
  /// - Left/Right: absorbed (no action).
  /// - Enter/Space on event: fires [onEventTap], stays in Event Mode.
  /// - Enter/Space on overflow: fires [onOverflowTap], exits to Navigation Mode.
  /// - M on event: enters Move Mode for that event.
  /// - R on event: enters Resize Mode directly for that event.
  /// - Escape: handled by the top-level handler.
  KeyEventResult _handleKeyboardEventModeKey(KeyEvent event) {
    final l10n = mcalL10n(context);
    final key = event.logicalKey;
    final focusedDate = widget.controller.focusedDateTime != null
        ? dateOnly(widget.controller.focusedDateTime!)
        : widget.controller.displayDate;
    final allEvents = _getSortedEventsForDate(focusedDate);

    if (allEvents.isEmpty) {
      _exitKeyboardMoveMode();
      setState(() {});
      return KeyEventResult.handled;
    }

    final visibleCount = _visibleCountForDate(focusedDate, allEvents);
    final hasOverflow = visibleCount < allEvents.length;
    final totalItems = visibleCount + (hasOverflow ? 1 : 0);

    // Left/Right: absorbed, no action
    if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight) {
      return KeyEventResult.handled;
    }

    // Up/Down/Tab/Shift+Tab: cycle forward or backward
    final isForward = _matchesAny(_keyBindings.cycleForward, key);
    final isBackward = _matchesAny(_keyBindings.cycleBackward, key);

    if (isForward || isBackward) {
      // currentIndex: 0..visibleCount-1 = events; visibleCount = overflow
      final currentIndex =
          _isKeyboardOverflowFocused ? visibleCount : _keyboardMoveEventIndex;
      final newIndex = isForward
          ? (currentIndex + 1) % totalItems
          : (currentIndex - 1 + totalItems) % totalItems;

      _isKeyboardOverflowFocused = hasOverflow && (newIndex == visibleCount);
      if (!_isKeyboardOverflowFocused) {
        _keyboardMoveEventIndex = newIndex.clamp(0, visibleCount - 1);
      }

      setState(() {});

      if (_isKeyboardOverflowFocused) {
        SemanticsService.sendAnnouncement(
          View.of(context),
          l10n.announcementEventCycled(
            'overflow indicator',
            (visibleCount + 1).toString(),
            totalItems.toString(),
          ),
          Directionality.of(context),
        );
      } else {
        final selected = allEvents[_keyboardMoveEventIndex];
        SemanticsService.sendAnnouncement(
          View.of(context),
          l10n.announcementEventCycled(
            selected.title,
            (_keyboardMoveEventIndex + 1).toString(),
            totalItems.toString(),
          ),
          Directionality.of(context),
        );
      }
      return KeyEventResult.handled;
    }

    // Enter/Space: activate the current item
    if (_matchesAny(_keyBindings.activate, key) ||
        key == LogicalKeyboardKey.numpadEnter) {
      if (_isKeyboardOverflowFocused) {
        _triggerKeyboardOverflowTap(focusedDate, allEvents, visibleCount);
        _exitKeyboardMoveMode();
        setState(() {});
      } else {
        final selectedIndex = _keyboardMoveEventIndex.clamp(
          0,
          visibleCount - 1,
        );
        _triggerKeyboardEventTap(allEvents[selectedIndex], focusedDate);
        _exitKeyboardMoveMode();
        setState(() {});
      }
      return KeyEventResult.handled;
    }

    // M: enter Move Mode for the currently selected event
    if (_matchesAny(_keyBindings.enterMoveMode, key) &&
        !_isKeyboardOverflowFocused) {
      final selectedIndex = _keyboardMoveEventIndex.clamp(0, visibleCount - 1);
      _selectKeyboardMoveEvent(allEvents[selectedIndex]);
      return KeyEventResult.handled;
    }

    // R: enter Resize Mode directly for the currently selected event
    if (_matchesAny(_keyBindings.enterResizeMode, key) &&
        !_isKeyboardOverflowFocused &&
        _resolveDragToResize(context)) {
      final selectedIndex = _keyboardMoveEventIndex.clamp(0, visibleCount - 1);
      _enterResizeModeFromEventMode(allEvents[selectedIndex]);
      return KeyEventResult.handled;
    }

    // D / Delete / Backspace: request event deletion
    if (_matchesAny(_keyBindings.delete, key) &&
        !_isKeyboardOverflowFocused &&
        widget.onDeleteEventRequested != null) {
      final selectedIndex = _keyboardMoveEventIndex.clamp(0, visibleCount - 1);
      final event = allEvents[selectedIndex];
      _handleDeleteResult(
        widget.onDeleteEventRequested!(
          context,
          MCalEventTapDetails(event: event, displayDate: focusedDate),
        ),
      );
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  /// Fires [onEventTap] for [event] at [date], replicating pointer-tap behaviour.
  void _triggerKeyboardEventTap(MCalCalendarEvent event, DateTime date) {
    widget.onEventTap?.call(
      context,
      MCalEventTapDetails(event: event, displayDate: date),
    );
  }

  /// Processes the [FutureOr<bool>] result from [onDeleteEventRequested].
  ///
  /// If `true` (sync or async), exits all keyboard modes. If `false`, stays
  /// in the current mode.
  void _handleDeleteResult(FutureOr<bool> result) {
    if (result is Future<bool>) {
      result.then((confirmed) {
        if (confirmed && mounted) {
          _exitKeyboardMoveMode();
          setState(() {});
        }
      });
    } else if (result) {
      _exitKeyboardMoveMode();
      setState(() {});
    }
  }

  /// Fires [onOverflowTap] using the visible/hidden split for [date].
  void _triggerKeyboardOverflowTap(
    DateTime date,
    List<MCalCalendarEvent> allEvents,
    int visibleCount,
  ) {
    if (widget.onOverflowTap == null) return;
    final safeVisible = visibleCount.clamp(0, allEvents.length);
    widget.onOverflowTap!(
      context,
      MCalOverflowTapDetails(
        date: date,
        visibleEvents: allEvents.sublist(0, safeVisible),
        hiddenEvents: allEvents.sublist(safeVisible),
      ),
    );
  }

  /// Returns to Event Mode from Move or Resize Mode on Escape.
  ///
  /// Cancels any active drag/resize in the drag handler, clears Move/Resize
  /// state, but keeps [_isKeyboardEventSelectionMode], [_keyboardMoveEventIndex],
  /// and [_isKeyboardOverflowFocused] intact so focus stays on the same item.
  void _returnToEventMode() {
    final dh = _dragHandler;
    if (dh != null) {
      if (dh.isResizing) dh.cancelResize();
      if (dh.isDragging) dh.cancelDrag();
    }
    _isDragActive = false;
    _isKeyboardMoveMode = false;
    _isKeyboardResizeMode = false;
    _keyboardResizeEdge = MCalResizeEdge.end;
    _keyboardResizeProposedStart = null;
    _keyboardResizeProposedEnd = null;
    _keyboardMoveProposedDate = null;
    _keyboardMoveEvent = null;
    _keyboardMoveOriginalStart = null;
    _keyboardMoveOriginalEnd = null;
  }

  /// Enters Resize Mode directly from Event Mode for [event].
  ///
  /// Sets up Move + Resize state without going through Move Mode entry,
  /// mirroring the R-key logic in [_handleKeyboardMoveModeKey].
  void _enterResizeModeFromEventMode(MCalCalendarEvent event) {
    final l10n = mcalL10n(context);
    final dragHandler = _ensureDragHandler;

    // Transition out of Event Mode, into Move+Resize Mode
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

    // Enter resize sub-mode
    _isKeyboardResizeMode = true;
    _keyboardResizeEdge = MCalResizeEdge.end;
    _keyboardResizeProposedStart = DateTime(
      event.start.year,
      event.start.month,
      event.start.day,
    );
    _keyboardResizeProposedEnd = DateTime(
      event.end.year,
      event.end.month,
      event.end.day,
    );

    dragHandler.startResize(event, MCalResizeEdge.end);

    final isValid = _validateKeyboardResize(event);
    dragHandler.updateResize(
      proposedStart: _keyboardResizeProposedStart!,
      proposedEnd: _keyboardResizeProposedEnd!,
      isValid: isValid,
      cells: [],
    );

    setState(() {});
    SemanticsService.sendAnnouncement(
      View.of(context),
      l10n.announcementResizeModeEntered,
      Directionality.of(context),
    );
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
    final l10n = mcalL10n(context);
    final key = event.logicalKey;
    final moveEvent = _keyboardMoveEvent;
    if (moveEvent == null) return KeyEventResult.ignored;

    // RTL support: reverse arrow keys in RTL layout mode
    final isLayoutRTL = MCalLayoutDirectionality.of(context);
    final rtlMult = isLayoutRTL ? -1 : 1;

    // Determine arrow-key day delta
    int dayDelta = 0;
    if (key == LogicalKeyboardKey.arrowRight) {
      dayDelta = 1 * rtlMult;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      dayDelta = -1 * rtlMult;
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
      final newProposed = addDays(_keyboardMoveProposedDate!, dayDelta);
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

      final proposedEnd = addDays(newProposed, eventDurationDays - 1);

      // Validate against regions via controller (library-level block).
      // If any day in the proposed range is covered by a blocking region,
      // reject the drop without calling onDragWillAccept.
      // Calendar-day arithmetic avoids DST edge cases (24 h ≠ 1 calendar day).
      bool isValid = true;
      for (
        DateTime d = newProposed;
        !d.isAfter(proposedEnd);
        d = addDays(d, 1)
      ) {
        if (widget.controller.isDateBlocked(d)) {
          isValid = false;
          break;
        }
      }

      // Cross-view enforcement: check timed regions for non-all-day events.
      if (isValid && !moveEvent.isAllDay) {
        final eventDuration = moveEvent.end.difference(moveEvent.start);
        final projectedStart = DateTime(
          newProposed.year,
          newProposed.month,
          newProposed.day,
          moveEvent.start.hour,
          moveEvent.start.minute,
        );
        final projectedEnd = projectedStart.add(eventDuration);
        if (widget.controller.isTimeRangeBlocked(projectedStart, projectedEnd)) {
          isValid = false;
        }
      }

      // Only call consumer's onDragWillAccept when the library-level check passes.
      if (isValid && widget.onDragWillAccept != null) {
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

      // Track focus on the proposed date (Month View always passes isAllDay: true)
      widget.controller.setFocusedDateTime(newProposed, isAllDay: true);

      // Screen reader announcement
      final dateStr = DateFormat.yMMMd().format(newProposed);
      SemanticsService.sendAnnouncement(
        View.of(context),
        l10n.announcementMovingEvent(moveEvent.title, dateStr),
        Directionality.of(context),
      );

      setState(() {});
      return KeyEventResult.handled;
    }

    // R key: enter resize mode (if resize is enabled)
    if (_matchesAny(_keyBindings.switchToResize, key) &&
        _resolveDragToResize(context)) {
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
        l10n.announcementResizeModeEntered,
        Directionality.of(context),
      );
      return KeyEventResult.handled;
    }

    // Enter: confirm the move
    if (_matchesAny(_keyBindings.confirmMove, key) ||
        key == LogicalKeyboardKey.numpadEnter) {
      _handleKeyboardDrop();
      return KeyEventResult.handled;
    }

    // Tab has no defined action in move mode — consume it so focus stays within
    // the calendar rather than escaping to the next focusable widget.
    if (key == LogicalKeyboardKey.tab) {
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  /// Confirms the keyboard-initiated event move.
  ///
  /// Mirrors the logic of [MonthPageWidgetState._handleDrop], reusing the
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
      final l10n = mcalL10n(context);
      dragHandler.cancelDrag();
      _isDragActive = false;
      _exitKeyboardMoveMode();
      setState(() {});
      SemanticsService.sendAnnouncement(
        View.of(context),
        l10n.announcementMoveInvalidTarget,
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
    final newStartDate = addDays(oldStartDate, dayDelta);
    final newEndDate = addDays(oldEndDate, dayDelta);

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
    final l10n = mcalL10n(context);
    final dateStr = DateFormat.yMMMd().format(newStartDate);
    SemanticsService.sendAnnouncement(
      View.of(context),
      l10n.announcementEventMoved(event.title, dateStr),
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
    final l10n = mcalL10n(context);
    final key = event.logicalKey;
    final resizeEvent = _keyboardMoveEvent;
    if (resizeEvent == null) return KeyEventResult.ignored;

    final dragHandler = _ensureDragHandler;

    // RTL support: reverse arrow keys in RTL layout mode
    final isLayoutRTL = MCalLayoutDirectionality.of(context);
    final rtlMult = isLayoutRTL ? -1 : 1;

    // S key: switch to start edge
    if (_matchesAny(_keyBindings.switchToStartEdge, key)) {
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
        l10n.announcementResizingStartEdge,
        Directionality.of(context),
      );
      return KeyEventResult.handled;
    }

    // E key: switch to end edge
    if (_matchesAny(_keyBindings.switchToEndEdge, key)) {
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
        l10n.announcementResizingEndEdge,
        Directionality.of(context),
      );
      return KeyEventResult.handled;
    }

    // M key: cancel resize, return to move mode
    if (_matchesAny(_keyBindings.switchToMove, key)) {
      dragHandler.cancelResize();
      _exitKeyboardResizeMode();
      setState(() {});
      SemanticsService.sendAnnouncement(
        View.of(context),
        l10n.announcementMoveMode,
        Directionality.of(context),
      );
      return KeyEventResult.handled;
    }

    // Arrow keys: adjust active edge
    final int delta;
    if (key == LogicalKeyboardKey.arrowRight) {
      delta = 1 * rtlMult;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      delta = -1 * rtlMult;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      delta = 7;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      delta = -7;
    } else {
      delta = 0;
    }

    if (delta != 0) {
      if (_keyboardResizeEdge == MCalResizeEdge.end) {
        final newEnd = addDays(_keyboardResizeProposedEnd!, delta);
        // Clamp: end cannot be before start (minimum 1 day)
        _keyboardResizeProposedEnd =
            newEnd.isBefore(_keyboardResizeProposedStart!)
            ? dateOnly(_keyboardResizeProposedStart!)
            : newEnd;
      } else {
        final newStart = addDays(_keyboardResizeProposedStart!, delta);
        // Clamp: start cannot be after end (minimum 1 day)
        _keyboardResizeProposedStart =
            newStart.isAfter(_keyboardResizeProposedEnd!)
            ? dateOnly(_keyboardResizeProposedEnd!)
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
        l10n.announcementResizingProgress(
          resizeEvent.title,
          _keyboardResizeEdge.name,
          dateStr,
          spanDays.toString(),
        ),
        Directionality.of(context),
      );

      // Navigate to new month if active edge date leaves the visible month
      final activeMonth = DateTime(activeDate.year, activeDate.month, 1);
      if (activeMonth.year != _currentMonth.year ||
          activeMonth.month != _currentMonth.month) {
        _navigateToMonth(activeMonth);
      }

      // Track focus on the active edge date (Month View always passes isAllDay: true)
      widget.controller.setFocusedDateTime(activeDate, isAllDay: true);

      setState(() {});
      return KeyEventResult.handled;
    }

    // Enter: confirm resize
    if (_matchesAny(_keyBindings.confirmResize, key) ||
        key == LogicalKeyboardKey.numpadEnter) {
      _handleKeyboardResizeEnd();
      return KeyEventResult.handled;
    }

    // Escape: cancel resize, stay in move mode
    if (_matchesAny(_keyBindings.cancelResize, key)) {
      dragHandler.cancelResize();
      _exitKeyboardResizeMode();
      setState(() {});
      SemanticsService.sendAnnouncement(
        View.of(context),
        l10n.announcementResizeCancelled,
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
  /// Mirrors the logic of [_handleResizeEndFromParent], reusing
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
      final l10n = mcalL10n(context);
      _exitKeyboardResizeMode();
      setState(() {});
      SemanticsService.sendAnnouncement(
        View.of(context),
        l10n.announcementResizeInvalid,
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
      final dayDelta = daysBetween(dateOnly(originalStart), proposedStart);
      newStartDate = addDays(originalStart, dayDelta);
      newEndDate = originalEnd;
    } else {
      // End edge changed
      final dayDelta = daysBetween(dateOnly(originalEnd), proposedEnd);
      newEndDate = addDays(originalEnd, dayDelta);
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
      // Recurring occurrence: create a modified exception with the full
      // updated event so both start and end date changes are preserved.
      final exception = MCalRecurrenceException.modified(
        originalDate: DateTime.parse(event.occurrenceId!),
        modifiedEvent: updatedEvent,
      );

      if (widget.onEventResized != null) {
        final shouldKeep = widget.onEventResized!(context, details);
        if (shouldKeep) {
          widget.controller.addException(seriesId, exception);
        }
      } else {
        // No callback — auto-create exception
        widget.controller.addException(seriesId, exception);
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
    final l10n = mcalL10n(context);
    final startStr = DateFormat.yMMMd().format(newStartDate);
    final endStr = DateFormat.yMMMd().format(newEndDate);
    SemanticsService.sendAnnouncement(
      View.of(context),
      l10n.announcementEventResized(event.title, startStr, endStr),
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
    if (!widget.enableDragToMove) return;

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
    if (!widget.enableDragToMove || !_isDragActive) return;

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

  // ============================================================
  // Parent-Level Resize Pointer Tracking
  // ============================================================
  //
  // Resize pointer events are handled at the _MCalMonthViewState level
  // (not MonthPageWidgetState) so the gesture survives across page
  // transitions during edge auto-navigation.  The parent Listener wraps
  // the entire calendar content and is in the hit-test from pointer-down,
  // so it receives move/up/cancel events even after the PageView changes
  // its child page.

  /// Called by [MonthPageWidgetState._handleResizePointerDown] via a
  /// callback on [MonthPageWidget] when the user presses on a resize handle.
  void _handleResizePointerDownFromChild(
    MCalCalendarEvent event,
    MCalResizeEdge edge,
    int pointer,
  ) {
    _resizeActivePointer = pointer;
    _resizeGestureStarted = false;
    _resizeDxAccumulated = 0.0;
    _pendingResizeEvent = event;
    _pendingResizeEdge = edge;

    // Disable PageView scrolling by switching to NeverScrollableScrollPhysics.
    // This prevents the PageView's gesture recognizer from stealing the
    // horizontal drag. The scroll hold provides immediate protection for the
    // current frame while the physics change takes effect next frame.
    if (!_isResizeInProgress) {
      _isResizeInProgress = true;
      setState(() {});
    }

    // Acquire scroll hold as belt-and-suspenders for the current frame.
    _releaseResizeScrollHold();
    try {
      _resizeScrollHold = _pageController.position.hold(() {
        _resizeScrollHold = null;
      });
    } catch (e) {
      // Scroll hold failed, but resize can still proceed
    }
  }

  /// Releases the scroll hold that freezes the [PageView] during resize.
  void _releaseResizeScrollHold() {
    _resizeScrollHold?.cancel();
    _resizeScrollHold = null;
  }

  /// Called by the parent [Listener.onPointerMove].
  /// Implements a manual drag threshold, then delegates to
  /// [_processResizeUpdateFromParent].
  void _handleResizePointerMoveFromParent(PointerMoveEvent pointerEvent) {
    if (pointerEvent.pointer != _resizeActivePointer) return;

    if (!_resizeGestureStarted) {
      _resizeDxAccumulated += pointerEvent.delta.dx;
      if (_resizeDxAccumulated.abs() < _resizeDragThreshold) return;

      _resizeGestureStarted = true;
      final event = _pendingResizeEvent;
      final edge = _pendingResizeEdge;
      if (event == null || edge == null) return;

      _ensureDragHandler.startResize(event, edge);
      return;
    }

    // Resize in progress — use absolute pointer position to find date
    _lastResizePointerPosition = pointerEvent.position;
    _processResizeUpdateFromParent(pointerEvent.position);
  }

  /// Called by the parent [Listener.onPointerUp].
  void _handleResizePointerUpFromParent(PointerUpEvent pointerEvent) {
    if (pointerEvent.pointer != _resizeActivePointer) return;

    if (_resizeGestureStarted) {
      _handleResizeEndFromParent();
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
    _lastResizePointerPosition = null;
    _releaseResizeScrollHold();

    // Re-enable PageView scrolling
    if (_isResizeInProgress) {
      _isResizeInProgress = false;
      setState(() {});
    }
  }

  /// Converts the pointer's global position to a calendar date using
  /// the grid area's render box and the current month's date grid.
  void _processResizeUpdateFromParent(Offset globalPosition) {
    final dragHandler = _dragHandler;
    if (dragHandler == null || !dragHandler.isResizing) return;

    // Get the grid area render box via GlobalKey
    final gridRenderBox =
        _gridAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (gridRenderBox == null || !gridRenderBox.hasSize) return;

    final gridSize = gridRenderBox.size;
    final gridOffset = gridRenderBox.localToGlobal(Offset.zero);

    // Compute layout values
    final resizeTheme = MCalTheme.of(context);
    final resizeDefaults = MCalThemeData.fromTheme(Theme.of(context));
    final weekNumColWidth = resizeTheme.monthViewTheme?.weekNumberColumnWidth ??
        resizeDefaults.monthViewTheme!.weekNumberColumnWidth!;
    final weekNumberWidth = widget.showWeekNumbers ? weekNumColWidth : 0.0;
    final isLayoutRTL = MCalLayoutDirectionality.of(context);
    final contentOffsetX = isLayoutRTL ? 0.0 : weekNumberWidth;
    final contentWidth = gridSize.width - weekNumberWidth;
    final dayWidth = contentWidth / 7;

    // Get current month's dates
    final dates = generateMonthDates(
      _currentMonth,
      widget.controller.resolvedFirstDayOfWeek,
    );
    final weeks = <List<DateTime>>[];
    for (int i = 0; i < dates.length; i += 7) {
      weeks.add(dates.sublist(i, i + 7));
    }
    if (weeks.isEmpty) return;
    final weekRowHeight = gridSize.height / weeks.length;

    if (dayWidth <= 0 || weekRowHeight <= 0) return;

    // Convert global position to local within the grid
    final localX = globalPosition.dx - gridOffset.dx - contentOffsetX;
    final localY = globalPosition.dy - gridOffset.dy;

    // Compute raw (unclamped) row and column indices for extrapolation
    final rawWeekRowIndex = (localY / weekRowHeight).floor();
    int rawLogicalCol;
    if (isLayoutRTL) {
      rawLogicalCol = 6 - (localX / dayWidth).floor();
    } else {
      rawLogicalCol = (localX / dayWidth).floor();
    }

    // Compute linear day index (0-based from dates.first)
    final rawDayIndex = rawWeekRowIndex * 7 + rawLogicalCol;

    // Resolve the pointer date — within grid or extrapolated
    final DateTime pointerDate;
    if (rawDayIndex >= 0 && rawDayIndex < dates.length) {
      final d = dates[rawDayIndex];
      pointerDate = dateOnly(d);
    } else {
      pointerDate = addDays(dates.first, rawDayIndex);
    }

    final originalStart = dragHandler.resizeOriginalStart!;
    final originalEnd = dragHandler.resizeOriginalEnd!;
    final edge = dragHandler.resizeEdge!;

    DateTime proposedStart;
    DateTime proposedEnd;

    if (edge == MCalResizeEdge.start) {
      proposedStart =
          pointerDate.isBefore(originalEnd) ||
              pointerDate.isAtSameMomentAs(originalEnd)
          ? pointerDate
          : dateOnly(originalEnd);
      proposedEnd = originalEnd;
    } else {
      proposedEnd =
          pointerDate.isAfter(originalStart) ||
              pointerDate.isAtSameMomentAs(originalStart)
          ? pointerDate
          : dateOnly(originalStart);
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

    // Build highlighted cells (only for dates visible in the current grid)
    final cells = _buildHighlightCellsFromParent(
      proposedStart,
      proposedEnd,
      weeks,
      dayWidth,
      weekRowHeight,
      contentOffsetX,
    );

    dragHandler.updateResize(
      proposedStart: proposedStart,
      proposedEnd: proposedEnd,
      isValid: isValid,
      cells: cells,
    );

    // Edge proximity detection for cross-month navigation.
    // Uses 10% inset threshold matching drag-to-move.
    // When the timer fires, the month navigates but the resize CONTINUES
    // because the parent-level Listener survives page changes.
    _checkResizeEdgeProximityFromParent(
      localX,
      localY,
      contentWidth,
      gridSize.height,
      edge,
    );
  }

  /// Builds [MCalHighlightCellInfo] list for cells visible in the current grid.
  List<MCalHighlightCellInfo> _buildHighlightCellsFromParent(
    DateTime start,
    DateTime end,
    List<List<DateTime>> weeks,
    double dayWidth,
    double weekRowHeight,
    double contentOffsetX,
  ) {
    final cells = <MCalHighlightCellInfo>[];
    if (weeks.isEmpty || dayWidth <= 0 || weekRowHeight <= 0) return cells;

    final normalizedStart = dateOnly(start);
    final normalizedEnd = dateOnly(end);
    final totalDays = daysBetween(normalizedStart, normalizedEnd) + 1;
    int cellNumber = 0;

    for (int weekRowIndex = 0; weekRowIndex < weeks.length; weekRowIndex++) {
      final weekDates = weeks[weekRowIndex];
      for (int cellIndex = 0; cellIndex < weekDates.length; cellIndex++) {
        final cellDate = weekDates[cellIndex];
        final normalizedCell = dateOnly(cellDate);
        if (!normalizedCell.isBefore(normalizedStart) &&
            !normalizedCell.isAfter(normalizedEnd)) {
          final cellLeft = contentOffsetX + (cellIndex * dayWidth);
          final cellTop = weekRowIndex * weekRowHeight;
          cells.add(
            MCalHighlightCellInfo(
              date: normalizedCell,
              cellIndex: cellIndex,
              weekRowIndex: weekRowIndex,
              bounds: Rect.fromLTWH(cellLeft, cellTop, dayWidth, weekRowHeight),
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

  /// Edge proximity detection during resize.
  ///
  /// Uses the same 10% inset threshold as drag-to-move. When the timer
  /// fires, the month navigates and the resize continues on the new page
  /// because the parent-level Listener survives page transitions.
  void _checkResizeEdgeProximityFromParent(
    double localX,
    double localY,
    double contentWidth,
    double gridHeight,
    MCalResizeEdge edge,
  ) {
    final dragHandler = _dragHandler;
    if (dragHandler == null || !dragHandler.isResizing) return;
    if (!widget.dragEdgeNavigationEnabled) return;

    final edgeThreshold = contentWidth * 0.1;

    // Detect boundary proximity
    final nearLeadingEdge = localX < edgeThreshold || localY < 0;
    final nearTrailingEdge =
        localX > contentWidth - edgeThreshold || localY > gridHeight;

    if (edge == MCalResizeEdge.start &&
        nearLeadingEdge &&
        _canNavigateToPreviousMonth()) {
      dragHandler.handleEdgeProximity(true, true, () {
        if (!mounted) return;
        _navigateToPreviousMonth();
        // Recompute resize overlay for the new month's grid on the next frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _resizeActivePointer == null) return;
          if (_lastResizePointerPosition != null) {
            _processResizeUpdateFromParent(_lastResizePointerPosition!);
          }
        });
      }, delay: widget.dragEdgeNavigationDelay);
    } else if (edge == MCalResizeEdge.end &&
        nearTrailingEdge &&
        _canNavigateToNextMonth()) {
      dragHandler.handleEdgeProximity(true, false, () {
        if (!mounted) return;
        _navigateToNextMonth();
        // Recompute resize overlay for the new month's grid on the next frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _resizeActivePointer == null) return;
          if (_lastResizePointerPosition != null) {
            _processResizeUpdateFromParent(_lastResizePointerPosition!);
          }
        });
      }, delay: widget.dragEdgeNavigationDelay);
    } else {
      dragHandler.handleEdgeProximity(false, false, () {});
    }
  }

  /// Completes the resize operation at the parent level.
  void _handleResizeEndFromParent() {
    final dragHandler = _dragHandler;
    if (dragHandler == null || !dragHandler.isResizing) return;

    final event = dragHandler.resizingEvent!;
    final originalStart = dragHandler.resizeOriginalStart!;
    final originalEnd = dragHandler.resizeOriginalEnd!;
    final edge = dragHandler.resizeEdge!;

    final result = dragHandler.completeResize();
    if (result == null) return;

    final (proposedStart, proposedEnd) = result;

    // Calculate new dates preserving time components (DST-safe)
    final DateTime newStartDate;
    final DateTime newEndDate;

    if (edge == MCalResizeEdge.start) {
      final dayDelta = daysBetween(dateOnly(originalStart), proposedStart);
      newStartDate = addDays(originalStart, dayDelta);
      newEndDate = originalEnd;
    } else {
      final dayDelta = daysBetween(dateOnly(originalEnd), proposedEnd);
      newEndDate = addDays(originalEnd, dayDelta);
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

    final updatedEvent = event.copyWith(start: newStartDate, end: newEndDate);

    if (isRecurring && seriesId != null) {
      final exception = MCalRecurrenceException.modified(
        originalDate: DateTime.parse(event.occurrenceId!),
        modifiedEvent: updatedEvent,
      );
      if (widget.onEventResized != null) {
        final shouldKeep = widget.onEventResized!(context, details);
        if (shouldKeep) {
          widget.controller.addException(seriesId, exception);
        }
      } else {
        widget.controller.addException(seriesId, exception);
      }
    } else {
      widget.controller.addEvents([updatedEvent]);
      if (widget.onEventResized != null) {
        final shouldKeep = widget.onEventResized!(context, details);
        if (!shouldKeep) {
          final revertedEvent = event.copyWith(
            start: originalStart,
            end: originalEnd,
          );
          widget.controller.addEvents([revertedEvent]);
          return;
        }
      }
    }

    // Auto-navigate to show the resized edge date
    final activeEdgeDate = edge == MCalResizeEdge.end
        ? newEndDate
        : newStartDate;
    final targetMonth = DateTime(activeEdgeDate.year, activeEdgeDate.month, 1);
    if (targetMonth.year != _currentMonth.year ||
        targetMonth.month != _currentMonth.month) {
      _navigateToMonth(targetMonth);
    }
  }
}

// MCalLayoutDirectionality is defined in mcal_layout_directionality.dart and shared
// with mcal_day_view.dart and mcal_month_default_week_layout.dart.

