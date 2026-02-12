import 'dart:ui' show Offset, Rect, Size;
import 'package:flutter/painting.dart' show AxisDirection;
import 'package:flutter/foundation.dart' show VoidCallback;
import '../models/mcal_calendar_event.dart';

/// Details object for cell tap callbacks.
///
/// Provides all necessary data about a tap event on a day cell in the
/// month view calendar grid.
///
/// Example:
/// ```dart
/// onCellTap: (context, details) {
///   print('Tapped on ${details.date}');
///   print('Events: ${details.events.length}');
///   print('Is current month: ${details.isCurrentMonth}');
/// }
/// ```
class MCalCellTapDetails {
  /// The date of the tapped cell.
  final DateTime date;

  /// List of events occurring on this date.
  final List<MCalCalendarEvent> events;

  /// Whether this cell belongs to the currently displayed month.
  final bool isCurrentMonth;

  /// Creates a new [MCalCellTapDetails] instance.
  const MCalCellTapDetails({
    required this.date,
    required this.events,
    required this.isCurrentMonth,
  });
}

/// Details object for event tap callbacks.
///
/// Provides all necessary data about a tap event on an event tile in the
/// month view calendar.
///
/// Example:
/// ```dart
/// onEventTap: (context, details) {
///   print('Tapped event: ${details.event.title}');
///   print('Display date: ${details.displayDate}');
/// }
/// ```
class MCalEventTapDetails {
  /// The calendar event that was tapped.
  final MCalCalendarEvent event;

  /// The date context for this event tile.
  ///
  /// This may differ from [event.start] for multi-day events where the
  /// event tile is displayed on a different date than its start date.
  final DateTime displayDate;

  /// Creates a new [MCalEventTapDetails] instance.
  const MCalEventTapDetails({required this.event, required this.displayDate});
}

/// Details object for swipe navigation callbacks.
///
/// Provides information about month navigation triggered by swipe gestures.
///
/// Example:
/// ```dart
/// onSwipeNavigation: (context, details) {
///   print('Navigated from ${details.previousMonth} to ${details.newMonth}');
///   print('Direction: ${details.direction}');
/// }
/// ```
class MCalSwipeNavigationDetails {
  /// The month that was displayed before the navigation.
  final DateTime previousMonth;

  /// The month that is now displayed after the navigation.
  final DateTime newMonth;

  /// The direction of the swipe gesture.
  ///
  /// - [AxisDirection.left]: Swiped left (navigating to next month)
  /// - [AxisDirection.right]: Swiped right (navigating to previous month)
  final AxisDirection direction;

  /// Creates a new [MCalSwipeNavigationDetails] instance.
  const MCalSwipeNavigationDetails({
    required this.previousMonth,
    required this.newMonth,
    required this.direction,
  });
}

/// Details provided when an overflow indicator is tapped.
///
/// Overflow indicators appear when there are more events than can be
/// displayed in a day cell. This details object provides both the hidden
/// and visible events so handlers can display all events for the day.
///
/// **Note:** The overflow indicator does not support drag-and-drop. Only
/// visible event tiles can be dragged. Users must tap the overflow indicator
/// to reveal hidden events in a separate view if they need to drag them.
class MCalOverflowTapDetails {
  /// The date for which the overflow indicator was tapped.
  final DateTime date;

  /// The list of events that are hidden (not displayed in the cell).
  final List<MCalCalendarEvent> hiddenEvents;

  /// The list of events that are visible in the cell.
  final List<MCalCalendarEvent> visibleEvents;

  /// Creates a new [MCalOverflowTapDetails] instance.
  const MCalOverflowTapDetails({
    required this.date,
    required this.hiddenEvents,
    required this.visibleEvents,
  });

  /// The total count of hidden events.
  int get hiddenEventCount => hiddenEvents.length;

  /// All events for this date (visible + hidden).
  List<MCalCalendarEvent> get allEvents => [...visibleEvents, ...hiddenEvents];
}

/// Details object for date label tap callbacks.
///
/// Provides context about a tap event on a date label in the month view.
///
/// Example:
/// ```dart
/// onDateLabelTap: (context, details) {
///   print('Tapped date: ${details.date}');
///   print('Is today: ${details.isToday}');
/// }
/// ```
class MCalDateLabelTapDetails {
  /// The date of the tapped label.
  final DateTime date;

  /// Whether this date is the current day.
  final bool isToday;

  /// Whether this date belongs to the currently displayed month.
  final bool isCurrentMonth;

  /// Creates a new [MCalDateLabelTapDetails] instance.
  const MCalDateLabelTapDetails({
    required this.date,
    required this.isToday,
    required this.isCurrentMonth,
  });
}

/// Details object for cell interactivity callbacks.
///
/// Provides information for determining whether a specific cell should be
/// interactive/selectable.
///
/// Example:
/// ```dart
/// cellInteractivityCallback: (context, details) {
///   // Disable past dates
///   if (details.date.isBefore(DateTime.now())) {
///     return false;
///   }
///   // Only allow current month dates
///   return details.isCurrentMonth;
/// }
/// ```
class MCalCellInteractivityDetails {
  /// The date of the cell being evaluated.
  final DateTime date;

  /// Whether this cell belongs to the currently displayed month.
  final bool isCurrentMonth;

  /// Whether this cell is selectable by default.
  ///
  /// This reflects the default interactivity state before any custom
  /// callback logic is applied.
  final bool isSelectable;

  /// Creates a new [MCalCellInteractivityDetails] instance.
  const MCalCellInteractivityDetails({
    required this.date,
    required this.isCurrentMonth,
    required this.isSelectable,
  });
}

/// Details object for error builder callbacks.
///
/// Provides information about an error that occurred, along with an
/// optional retry callback.
///
/// Example:
/// ```dart
/// errorBuilder: (context, details) {
///   return Center(
///     child: Column(
///       mainAxisAlignment: MainAxisAlignment.center,
///       children: [
///         Text('Error: ${details.error}'),
///         if (details.onRetry != null)
///           ElevatedButton(
///             onPressed: details.onRetry,
///             child: Text('Retry'),
///           ),
///       ],
///     ),
///   );
/// }
/// ```
class MCalErrorDetails {
  /// The error that occurred.
  final Object error;

  /// Optional callback to retry the failed operation.
  ///
  /// When provided, the error UI should display a retry option that
  /// invokes this callback.
  final VoidCallback? onRetry;

  /// Creates a new [MCalErrorDetails] instance.
  const MCalErrorDetails({required this.error, this.onRetry});
}

/// Details object for multi-day event tile builder callbacks.
///
/// Provides comprehensive context for rendering contiguous multi-day event
/// tiles that span across cells and potentially multiple week rows.
///
/// Example:
/// ```dart
/// multiDayEventTileBuilder: (context, details) {
///   // Customize corner radius based on position in row
///   final leftRadius = details.isFirstDayInRow ? 8.0 : 0.0;
///   final rightRadius = details.isLastDayInRow ? 8.0 : 0.0;
///
///   return Container(
///     decoration: BoxDecoration(
///       color: details.event.color,
///       borderRadius: BorderRadius.horizontal(
///         left: Radius.circular(leftRadius),
///         right: Radius.circular(rightRadius),
///       ),
///     ),
///     child: Text(
///       // Only show title on first day in row
///       details.isFirstDayInRow ? details.event.title : '',
///     ),
///   );
/// }
/// ```
class MCalMultiDayTileDetails {
  /// The calendar event being rendered.
  final MCalCalendarEvent event;

  /// The date context for this tile segment.
  ///
  /// Represents which day this particular tile segment is being rendered for.
  final DateTime displayDate;

  /// Whether this is the first day of the event.
  ///
  /// True if [displayDate] matches the event's start date.
  final bool isFirstDayOfEvent;

  /// Whether this is the last day of the event.
  ///
  /// True if [displayDate] matches the event's end date.
  final bool isLastDayOfEvent;

  /// Whether this is the first visible day in the current week row.
  ///
  /// True if this tile segment starts at the beginning of a week row,
  /// either because the event starts here or because it's a continuation
  /// from a previous row.
  final bool isFirstDayInRow;

  /// Whether this is the last visible day in the current week row.
  ///
  /// True if this tile segment ends at the end of a week row,
  /// either because the event ends here or because it continues
  /// to the next row.
  final bool isLastDayInRow;

  /// Zero-based index of this day within the event's total span.
  ///
  /// For a 5-day event, this ranges from 0 to 4.
  final int dayIndexInEvent;

  /// Total number of days the event spans.
  ///
  /// Calculated as the difference between start and end dates, inclusive.
  final int totalDaysInEvent;

  /// Zero-based index within the current row segment.
  ///
  /// For a multi-day event that spans 3 days in the current row,
  /// this ranges from 0 to 2.
  final int dayIndexInRow;

  /// Total days of the event visible in the current row.
  ///
  /// This may be less than [totalDaysInEvent] if the event spans
  /// multiple week rows.
  final int totalDaysInRow;

  /// Which row segment this tile belongs to.
  ///
  /// Zero-based index where 0 is the first row the event appears in,
  /// 1 is the second row (if the event wraps), etc.
  final int rowIndex;

  /// Total number of row segments for this event.
  ///
  /// A single-week event has 1 row, while an event spanning
  /// Monday to the following Wednesday might have 2 rows.
  final int totalRows;

  /// Creates a new [MCalMultiDayTileDetails] instance.
  const MCalMultiDayTileDetails({
    required this.event,
    required this.displayDate,
    required this.isFirstDayOfEvent,
    required this.isLastDayOfEvent,
    required this.isFirstDayInRow,
    required this.isLastDayInRow,
    required this.dayIndexInEvent,
    required this.totalDaysInEvent,
    required this.dayIndexInRow,
    required this.totalDaysInRow,
    required this.rowIndex,
    required this.totalRows,
  });
}

/// Details object for the dragged event tile builder.
///
/// Provides context for building the visual representation of an event tile
/// while it is being dragged. This is used by the [draggedTileBuilder] callback
/// to create a custom drag feedback widget.
///
/// Example:
/// ```dart
/// draggedTileBuilder: (context, details) {
///   return Material(
///     elevation: 8.0,
///     borderRadius: BorderRadius.circular(8),
///     child: Container(
///       padding: EdgeInsets.all(8),
///       decoration: BoxDecoration(
///         color: details.event.color,
///         borderRadius: BorderRadius.circular(8),
///       ),
///       child: Text(details.event.title),
///     ),
///   );
/// }
/// ```
class MCalDraggedTileDetails {
  /// The calendar event being dragged.
  final MCalCalendarEvent event;

  /// The original date from which the event is being dragged.
  ///
  /// For multi-day events, this represents the specific day cell where
  /// the drag was initiated.
  final DateTime sourceDate;

  /// The current position of the drag pointer.
  ///
  /// This can be used to create dynamic effects based on drag position,
  /// such as rotation or scaling based on movement.
  final Offset currentPosition;

  /// The width of a single day cell/column in the calendar grid.
  final double dayWidth;

  /// The horizontal spacing applied to event tiles.
  ///
  /// The full tile width can be calculated as:
  /// `(dayWidth * eventDurationDays) - (horizontalSpacing * 2)`
  final double horizontalSpacing;

  /// The number of days this event spans.
  final int eventDurationDays;

  /// Calculates the tile width based on day width, duration, and spacing.
  double get tileWidth =>
      (dayWidth * eventDurationDays) - (horizontalSpacing * 2);

  /// Creates a new [MCalDraggedTileDetails] instance.
  const MCalDraggedTileDetails({
    required this.event,
    required this.sourceDate,
    required this.currentPosition,
    required this.dayWidth,
    required this.horizontalSpacing,
    required this.eventDurationDays,
  });
}

/// Details object for the drag source placeholder builder.
///
/// Provides context for building the placeholder widget that appears in place
/// of the original event tile while it is being dragged. This is used by the
/// [dragSourceTileBuilder] callback to customize the source cell appearance.
///
/// Example:
/// ```dart
/// dragSourceTileBuilder: (context, details) {
///   // Show a ghost outline where the event was
///   return Container(
///     decoration: BoxDecoration(
///       border: Border.all(
///         color: details.event.color.withOpacity(0.5),
///         style: BorderStyle.dashed,
///       ),
///       borderRadius: BorderRadius.circular(4),
///     ),
///   );
/// }
/// ```
class MCalDragSourceDetails {
  /// The calendar event being dragged.
  final MCalCalendarEvent event;

  /// The original date from which the event is being dragged.
  ///
  /// For multi-day events, this represents the specific day cell where
  /// the drag was initiated.
  final DateTime sourceDate;

  /// Creates a new [MCalDragSourceDetails] instance.
  const MCalDragSourceDetails({required this.event, required this.sourceDate});
}

/// Details object for the drop validation callback.
///
/// Provides context for determining whether a drag operation should be
/// accepted at a particular target location. This is used by the
/// [onDragWillAccept] callback to implement custom validation logic.
///
/// The proposed dates represent where the event would be placed if dropped,
/// with the duration preserved from the original event.
///
/// Example:
/// ```dart
/// onDragWillAccept: (context, details) {
///   // Don't allow dropping on past dates
///   if (details.proposedStartDate.isBefore(DateTime.now())) {
///     return false;
///   }
///   // Don't allow dropping on weekends
///   if (details.proposedStartDate.weekday == DateTime.saturday ||
///       details.proposedStartDate.weekday == DateTime.sunday) {
///     return false;
///   }
///   return true;
/// }
/// ```
class MCalDragWillAcceptDetails {
  /// The calendar event being dragged.
  final MCalCalendarEvent event;

  /// The proposed new start date for the event if dropped.
  ///
  /// This is calculated by applying the day delta from the drag operation
  /// to the event's original start date.
  final DateTime proposedStartDate;

  /// The proposed new end date for the event if dropped.
  ///
  /// This is calculated by applying the same day delta to the event's
  /// original end date, preserving the event's duration.
  final DateTime proposedEndDate;

  /// Creates a new [MCalDragWillAcceptDetails] instance.
  const MCalDragWillAcceptDetails({
    required this.event,
    required this.proposedStartDate,
    required this.proposedEndDate,
  });
}

/// Details for building a custom drop target cell.
///
/// Passed to [MCalMonthView.dropTargetCellBuilder] for each highlighted cell
/// during a drag operation. This provides per-cell customization.
///
/// Example:
/// ```dart
/// dropTargetCellBuilder: (context, details) {
///   return Container(
///     decoration: BoxDecoration(
///       color: details.isValid ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
///       borderRadius: BorderRadius.horizontal(
///         left: details.isFirst ? Radius.circular(8) : Radius.zero,
///         right: details.isLast ? Radius.circular(8) : Radius.zero,
///       ),
///     ),
///   );
/// }
/// ```
class MCalDropTargetCellDetails {
  /// The date of this cell.
  final DateTime date;

  /// The bounds of this cell in local coordinates.
  final Rect bounds;

  /// Whether this cell represents a valid drop target.
  final bool isValid;

  /// Whether this is the first cell in the highlighted range.
  final bool isFirst;

  /// Whether this is the last cell in the highlighted range.
  final bool isLast;

  /// The cell's index within the week (0 = first day based on firstDayOfWeek).
  final int cellIndex;

  /// The week row index within the month grid.
  final int weekRowIndex;

  /// Creates a new [MCalDropTargetCellDetails] instance.
  const MCalDropTargetCellDetails({
    required this.date,
    required this.bounds,
    required this.isValid,
    required this.isFirst,
    required this.isLast,
    required this.cellIndex,
    required this.weekRowIndex,
  });
}

/// Details object for the drop completed callback.
///
/// Provides comprehensive context about a completed drag-and-drop operation,
/// including the original and new dates for the event. This is used by the
/// [onEventDropped] callback to handle the drop action.
///
/// The callback can return `false` to indicate that the drop should be
/// reverted (e.g., if a backend update fails), in which case the event
/// will be restored to its original position.
///
/// Example:
/// ```dart
/// onEventDropped: (context, details) async {
///   // Calculate the day difference
///   final daysDelta = details.newStartDate.difference(details.oldStartDate).inDays;
///   print('Event moved by $daysDelta days');
///
///   // Update backend
///   try {
///     await eventService.updateEvent(
///       details.event.id,
///       start: details.newStartDate,
///       end: details.newEndDate,
///     );
///     return true; // Confirm the drop
///   } catch (e) {
///     showErrorSnackbar('Failed to update event');
///     return false; // Revert the drop
///   }
/// }
/// ```
class MCalEventDroppedDetails {
  /// The calendar event that was dropped.
  final MCalCalendarEvent event;

  /// The original start date of the event before the drop.
  final DateTime oldStartDate;

  /// The original end date of the event before the drop.
  final DateTime oldEndDate;

  /// The new start date of the event after the drop.
  final DateTime newStartDate;

  /// The new end date of the event after the drop.
  ///
  /// The event's duration is preserved, so the difference between
  /// [newEndDate] and [newStartDate] equals the difference between
  /// [oldEndDate] and [oldStartDate].
  final DateTime newEndDate;

  /// Creates a new [MCalEventDroppedDetails] instance.
  const MCalEventDroppedDetails({
    required this.event,
    required this.oldStartDate,
    required this.oldEndDate,
    required this.newStartDate,
    required this.newEndDate,
  });
}

/// Mutable holder for grab offset used during drag operations.
///
/// This class is used to work around a timing issue with Flutter's
/// LongPressDraggable where the data parameter is captured at build time
/// before the pointer down event updates the grab offset. By using a
/// mutable holder, we can update the offset after the drag data is created.
class MCalGrabOffsetHolder {
  /// The X offset in pixels from the tile's left edge where the user tapped.
  double grabOffsetX = 0.0;
}

/// Data object passed during drag-and-drop operations.
///
/// This class bundles the event being dragged with the source date
/// (the cell where the drag was initiated). This allows the drop target
/// to calculate the correct day delta based on where the user grabbed
/// the event, not just the event's start date.
///
/// The drop position is determined by where the tile's LEFT EDGE lands,
/// not where the cursor is. This provides intuitive behavior where the
/// event starts on the cell where the tile visually begins.
class MCalDragData {
  /// The calendar event being dragged.
  final MCalCalendarEvent event;

  /// The date of the segment where the drag was initiated.
  ///
  /// This is the start date of the visible segment, which may differ
  /// from [event.start] for multi-week events.
  final DateTime sourceDate;

  /// Mutable holder for the grab offset.
  ///
  /// This is used instead of a final value because the LongPressDraggable
  /// captures data at build time, but we need to update grabOffsetX when
  /// the pointer down event fires (after build).
  final MCalGrabOffsetHolder _grabOffsetHolder;

  /// The X offset in pixels from the tile's left edge where the user tapped.
  ///
  /// This is used to calculate which cell the tile's left edge is over
  /// when determining drop targets. The tile's left edge position relative
  /// to the cursor is: cursor_x - grabOffsetX
  double get grabOffsetX => _grabOffsetHolder.grabOffsetX;

  /// The horizontal spacing (margin) applied to event tiles.
  ///
  /// This is used in drop target calculations to account for the margin
  /// between the cell edge and the tile edge.
  final double horizontalSpacing;

  /// Creates a new [MCalDragData] instance with a holder for grab offset.
  MCalDragData({
    required this.event,
    required this.sourceDate,
    required MCalGrabOffsetHolder grabOffsetHolder,
    required this.horizontalSpacing,
  }) : _grabOffsetHolder = grabOffsetHolder;
}

/// Information about a single cell to highlight during drag-and-drop.
///
/// Used by the unified drag overlay system to communicate which cells should be
/// visually highlighted as potential drop targets. This class is passed within
/// [MCalDropOverlayDetails.highlightedCells] to the [MCalMonthView.dropTargetOverlayBuilder].
///
/// For multi-day events, multiple [MCalHighlightCellInfo] instances are created,
/// one for each day the event spans. The [isFirst] and [isLast] flags indicate
/// the event's visual boundaries, useful for applying rounded corners.
///
/// Example usage in a custom overlay builder:
/// ```dart
/// dropTargetOverlayBuilder: (context, details) {
///   return Stack(
///     children: details.highlightedCells.map((cell) {
///       return Positioned.fromRect(
///         rect: cell.bounds,
///         child: Container(
///           decoration: BoxDecoration(
///             color: Colors.blue.withOpacity(0.3),
///             borderRadius: BorderRadius.horizontal(
///               left: cell.isFirst ? Radius.circular(8) : Radius.zero,
///               right: cell.isLast ? Radius.circular(8) : Radius.zero,
///             ),
///           ),
///         ),
///       );
///     }).toList(),
///   );
/// }
/// ```
class MCalHighlightCellInfo {
  /// The date of this cell.
  ///
  /// Represents the calendar date for this highlighted cell.
  final DateTime date;

  /// Cell index within its week row (0-6).
  ///
  /// 0 represents the first day of the week (based on [MCalMonthView.firstDayOfWeek]).
  final int cellIndex;

  /// Week row index within the month grid.
  ///
  /// 0 is the first week row of the visible month page.
  final int weekRowIndex;

  /// Bounds of this cell in calendar-local coordinates.
  ///
  /// The [Rect] is relative to the calendar widget's coordinate space
  /// and can be used directly with [Positioned.fromRect].
  final Rect bounds;

  /// Whether this is the first cell in the event's span.
  ///
  /// True for the leftmost cell of the dragged event.
  /// Use this to apply left-side rounded corners.
  final bool isFirst;

  /// Whether this is the last cell in the event's span.
  ///
  /// True for the rightmost cell of the dragged event.
  /// Use this to apply right-side rounded corners.
  final bool isLast;

  /// Creates a new [MCalHighlightCellInfo] instance.
  const MCalHighlightCellInfo({
    required this.date,
    required this.cellIndex,
    required this.weekRowIndex,
    required this.bounds,
    required this.isFirst,
    required this.isLast,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MCalHighlightCellInfo &&
          date == other.date &&
          cellIndex == other.cellIndex &&
          weekRowIndex == other.weekRowIndex &&
          bounds == other.bounds &&
          isFirst == other.isFirst &&
          isLast == other.isLast;

  @override
  int get hashCode =>
      Object.hash(date, cellIndex, weekRowIndex, bounds, isFirst, isLast);
}

/// Details for building a custom drop target overlay.
///
/// Passed to [MCalMonthView.dropTargetOverlayBuilder] when a drag is active.
/// This provides full control over the entire overlay rendering, including
/// access to all highlighted cells, validation state, and calendar dimensions.
///
/// ## Precedence
///
/// When [MCalMonthView.dropTargetOverlayBuilder] is provided, it takes precedence
/// over [MCalMonthView.dropTargetCellBuilder] and the default [CustomPainter]
/// implementation. Only one will be used:
///
/// 1. [dropTargetOverlayBuilder] (highest priority)
/// 2. [dropTargetCellBuilder]
/// 3. Default [CustomPainter] (lowest priority)
///
/// ## When to Use
///
/// Use [dropTargetOverlayBuilder] when you need:
/// - Custom animations across all highlighted cells
/// - Connected/unified highlight rendering
/// - Access to the complete cell list for complex calculations
/// - Full control over the paint order
///
/// For simpler per-cell customization, prefer [MCalMonthView.dropTargetCellBuilder].
///
/// ## Example
///
/// ```dart
/// dropTargetOverlayBuilder: (context, details) {
///   return CustomPaint(
///     painter: MyCustomHighlightPainter(
///       cells: details.highlightedCells,
///       isValid: details.isValid,
///       dayWidth: details.dayWidth,
///     ),
///   );
/// }
/// ```
class MCalDropOverlayDetails {
  /// List of cells that should be highlighted.
  ///
  /// Contains [MCalHighlightCellInfo] for each day the dragged event
  /// would span if dropped at the current position. For multi-day events,
  /// this list contains multiple entries.
  final List<MCalHighlightCellInfo> highlightedCells;

  /// Whether the current drop position is valid.
  ///
  /// Determined by [MCalMonthView.onDragWillAccept] callback if provided,
  /// otherwise defaults to `true`. Use this to render different colors
  /// or styles for valid vs. invalid drop targets.
  final bool isValid;

  /// Width of each day cell in pixels.
  ///
  /// Useful for calculating positions or sizing custom highlight elements.
  final double dayWidth;

  /// Total size of the calendar area.
  ///
  /// The dimensions of the calendar widget where the overlay is rendered.
  final Size calendarSize;

  /// The drag data for the event being dragged.
  ///
  /// Contains the [MCalCalendarEvent] being dragged, the source date,
  /// and grab offset information for precise positioning.
  final MCalDragData dragData;

  /// Creates a new [MCalDropOverlayDetails] instance.
  const MCalDropOverlayDetails({
    required this.highlightedCells,
    required this.isValid,
    required this.dayWidth,
    required this.calendarSize,
    required this.dragData,
  });
}
