import 'package:flutter/material.dart';
import '../controllers/mcal_event_controller.dart';
import '../models/mcal_calendar_event.dart';
import 'mcal_callback_details.dart';
import 'mcal_draggable_event_tile.dart';
import 'mcal_month_view_contexts.dart';
import 'mcal_month_week_layout_contexts.dart';
import 'mcal_drag_handler.dart';

/// Utility class that wraps developer-provided builders with interaction handlers.
///
/// This separates visual customization (developer's responsibility) from
/// interaction handling (package's responsibility). The wrapped builders
/// are passed to weekLayoutBuilder so that interactions work automatically.
class MCalBuilderWrapper {
  MCalBuilderWrapper._(); // Prevent instantiation

  /// Wraps an event tile builder with tap, long-press, hover, and drag handlers.
  ///
  /// The returned builder will:
  /// 1. Call the developer's builder (or default) to get the visual widget
  /// 2. Wrap it with GestureDetector for tap/long-press (if drag is disabled)
  /// 3. Wrap with MCalDraggableEventTile if drag is enabled
  /// 4. Wrap with MouseRegion for hover support (if [onHoverEvent] is provided)
  static MCalEventTileBuilder wrapEventTileBuilder({
    required Widget Function(BuildContext, MCalEventTileContext, Widget)?
    developerBuilder,
    required Widget Function(BuildContext, MCalEventTileContext) defaultBuilder,
    void Function(BuildContext, MCalEventTapDetails)? onEventTap,
    void Function(BuildContext, MCalEventTapDetails)? onEventLongPress,
    void Function(BuildContext, MCalEventDoubleTapDetails)? onEventDoubleTap,
    void Function(BuildContext, MCalEventTileContext?)? onHoverEvent,
    MCalEventController? controller,
    bool enableDragToMove = false,
    MCalDragHandler? dragHandler,
    // Drag-related parameters
    Widget Function(BuildContext, MCalDraggedTileDetails, Widget)? draggedTileBuilder,
    Widget Function(BuildContext, MCalDragSourceDetails, Widget)? dragSourceTileBuilder,
    void Function(MCalCalendarEvent, DateTime)? onDragStartedCallback,
    void Function(bool)? onDragEndedCallback,
    VoidCallback? onDragCanceledCallback,
    // Tile sizing parameters for dragged feedback (required when drag enabled)
    required double dayWidth,
    double? tileHeight,
    double horizontalSpacing = 2.0,
    Duration dragLongPressDelay = const Duration(milliseconds: 200),
  }) {
    // Store position from onDoubleTapDown for use in onDoubleTap (which doesn't receive position)
    Offset? lastDoubleTapLocal;
    Offset? lastDoubleTapGlobal;

    return (BuildContext context, MCalEventTileContext tileContext) {
      // Get the default visual widget
      final defaultWidget = defaultBuilder(context, tileContext);

      // Let developer customize visuals if they provided a builder
      final visualWidget = developerBuilder != null
          ? developerBuilder(context, tileContext, defaultWidget)
          : defaultWidget;

      // Helper: wraps a widget with MouseRegion for hover support.
      Widget wrapWithHover(Widget child) {
        if (onHoverEvent == null) return child;
        return MouseRegion(
          onEnter: (_) {
            final hoverContext = _buildHoverContext(
              tileContext,
              controller,
            );
            onHoverEvent(context, hoverContext);
          },
          onExit: (_) => onHoverEvent(context, null),
          child: child,
        );
      }

      // If drag-and-drop is enabled, wrap with MCalDraggableEventTile
      if (enableDragToMove) {
        // When drag is enabled, wrap with draggable widget
        // The MCalDraggableEventTile handles both dragging and passes through taps
        Widget tileWithTapHandlers = GestureDetector(
          onTap: onEventTap != null
              ? () => onEventTap(
                  context,
                  MCalEventTapDetails(
                    event: tileContext.event,
                    displayDate: tileContext.displayDate,
                  ),
                )
              : null,
          onDoubleTapDown: onEventDoubleTap != null
              ? (details) {
                  lastDoubleTapLocal = details.localPosition;
                  lastDoubleTapGlobal = details.globalPosition;
                }
              : null,
          onDoubleTap: onEventDoubleTap != null
              ? () {
                  final local = lastDoubleTapLocal;
                  final global = lastDoubleTapGlobal;
                  if (local != null && global != null) {
                    onEventDoubleTap(
                      context,
                      MCalEventDoubleTapDetails(
                        event: tileContext.event,
                        displayDate: tileContext.displayDate,
                        localPosition: local,
                        globalPosition: global,
                      ),
                    );
                  }
                }
              : null,
          // Note: onLongPress is NOT added here when drag is enabled
          // because the long-press initiates the drag
          child: visualWidget,
        );

        // Capture values for closures
        final event = tileContext.event;
        final displayDate = tileContext.displayDate;
        final effectiveTileHeight = tileHeight ?? tileContext.height;

        // Create a default feedback builder that reuses the existing tile builder
        // with a synthetic context treating it as a single non-continuation segment
        Widget defaultFeedbackBuilder(double tileWidth) {
          // Create a synthetic segment with isFirstSegment=true, isLastSegment=true
          // This ensures uniform corners and borders (no continuation styling)
          final syntheticSegment = MCalMonthEventSegment(
            event: event,
            weekRowIndex: 0,
            startDayInWeek: 0,
            endDayInWeek: 0,
            isFirstSegment: true,
            isLastSegment: true,
          );

          // Create context with full width and synthetic segment
          final feedbackContext = MCalEventTileContext(
            event: event,
            displayDate: displayDate,
            isAllDay: event.isAllDay,
            segment: syntheticSegment,
            width: tileWidth,
            height: effectiveTileHeight,
          );

          // Reuse the existing default tile builder
          return SizedBox(
            width: tileWidth,
            height: effectiveTileHeight,
            child: defaultBuilder(context, feedbackContext),
          );
        }

        return wrapWithHover(
          MCalDraggableEventTile(
            event: event,
            sourceDate: displayDate,
            dayWidth: dayWidth,
            horizontalSpacing: horizontalSpacing,
            enabled: true,
            dragLongPressDelay: dragLongPressDelay,
            draggedTileBuilder: draggedTileBuilder,
            dragSourceTileBuilder: dragSourceTileBuilder,
            onDragStarted: onDragStartedCallback != null
                ? () => onDragStartedCallback(event, displayDate)
                : null,
            onDragEnded: onDragEndedCallback,
            onDragCanceled: onDragCanceledCallback,
            defaultFeedbackBuilder: defaultFeedbackBuilder,
            child: tileWithTapHandlers,
          ),
        );
      }

      // Drag is disabled - wrap with gesture detector for tap/long-press/double-tap
      return wrapWithHover(
        GestureDetector(
          onTap: onEventTap != null
              ? () => onEventTap(
                  context,
                  MCalEventTapDetails(
                    event: tileContext.event,
                    displayDate: tileContext.displayDate,
                  ),
                )
              : null,
          onLongPress: onEventLongPress != null
              ? () => onEventLongPress(
                  context,
                  MCalEventTapDetails(
                    event: tileContext.event,
                    displayDate: tileContext.displayDate,
                  ),
                )
              : null,
          onDoubleTapDown: onEventDoubleTap != null
              ? (details) {
                  lastDoubleTapLocal = details.localPosition;
                  lastDoubleTapGlobal = details.globalPosition;
                }
              : null,
          onDoubleTap: onEventDoubleTap != null
              ? () {
                  final local = lastDoubleTapLocal;
                  final global = lastDoubleTapGlobal;
                  if (local != null && global != null) {
                    onEventDoubleTap(
                      context,
                      MCalEventDoubleTapDetails(
                        event: tileContext.event,
                        displayDate: tileContext.displayDate,
                        localPosition: local,
                        globalPosition: global,
                      ),
                    );
                  }
                }
              : null,
          child: visualWidget,
        ),
      );
    };
  }

  /// Builds an [MCalEventTileContext] enriched with recurrence metadata,
  /// suitable for the [onHoverEvent] callback.
  ///
  /// If [controller] is available, recurrence metadata (seriesId,
  /// recurrenceRule, masterEvent, isException) is resolved from the
  /// controller. Otherwise, the fields from the original [tileContext]
  /// are forwarded as-is.
  static MCalEventTileContext _buildHoverContext(
    MCalEventTileContext tileContext,
    MCalEventController? controller,
  ) {
    final event = tileContext.event;

    // If no controller or no occurrenceId, forward existing context fields.
    if (controller == null || event.occurrenceId == null) {
      return MCalEventTileContext(
        event: event,
        displayDate: tileContext.displayDate,
        isAllDay: tileContext.isAllDay,
        segment: tileContext.segment,
        width: tileContext.width,
        height: tileContext.height,
        isRecurring: tileContext.isRecurring,
        seriesId: tileContext.seriesId,
        recurrenceRule: tileContext.recurrenceRule,
        masterEvent: tileContext.masterEvent,
        isException: tileContext.isException,
      );
    }

    // Resolve recurrence metadata from controller.
    final occId = event.occurrenceId!;
    final seriesId = event.id.endsWith('_$occId')
        ? event.id.substring(0, event.id.length - occId.length - 1)
        : event.id;
    final masterEvent = controller.getEventById(seriesId);
    final exceptions = controller.getExceptions(seriesId);
    final normalizedOccDate = DateTime.tryParse(occId);
    final isException = normalizedOccDate != null &&
        exceptions.any((e) {
          final d = e.originalDate;
          return d.year == normalizedOccDate.year &&
              d.month == normalizedOccDate.month &&
              d.day == normalizedOccDate.day;
        });

    return MCalEventTileContext(
      event: event,
      displayDate: tileContext.displayDate,
      isAllDay: tileContext.isAllDay,
      segment: tileContext.segment,
      width: tileContext.width,
      height: tileContext.height,
      isRecurring: true,
      seriesId: seriesId,
      recurrenceRule: masterEvent?.recurrenceRule,
      masterEvent: masterEvent,
      isException: isException,
    );
  }

  /// Wraps a date label builder with optional tap/long-press/hover handlers.
  ///
  /// If [onDateLabelTap] or [onDateLabelLongPress] is provided, the label
  /// is wrapped in a [GestureDetector] with the respective handlers.
  /// If [onHoverDateLabel] is provided, the label is wrapped in a [MouseRegion]
  /// for hover support.
  /// If no gesture handlers are provided, the label is wrapped in [IgnorePointer]
  /// so that taps pass through to Layer 1's cells, allowing [onCellTap] to be triggered.
  static MCalDateLabelBuilder wrapDateLabelBuilder({
    required Widget Function(BuildContext, MCalDateLabelContext, String)?
    developerBuilder,
    required Widget Function(BuildContext, MCalDateLabelContext) defaultBuilder,
    void Function(BuildContext, MCalDateLabelTapDetails)? onDateLabelTap,
    void Function(BuildContext, MCalDateLabelTapDetails)? onDateLabelLongPress,
    void Function(BuildContext, MCalDateLabelTapDetails)? onDateLabelDoubleTap,
    void Function(BuildContext, MCalDateLabelContext?)? onHoverDateLabel,
  }) {
    return (BuildContext context, MCalDateLabelContext labelContext) {
      final defaultWidget = defaultBuilder(context, labelContext);

      final visualWidget = developerBuilder != null
          ? developerBuilder(
              context,
              labelContext,
              labelContext.defaultFormattedString,
            )
          : defaultWidget;

      Widget result = visualWidget;

      // If any gesture handlers are provided, wrap in GestureDetector
      if (onDateLabelTap != null || onDateLabelLongPress != null || onDateLabelDoubleTap != null) {
        result = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onDateLabelTap != null
              ? () => onDateLabelTap(
                  context,
                  MCalDateLabelTapDetails(
                    date: labelContext.date,
                    isToday: labelContext.isToday,
                    isCurrentMonth: labelContext.isCurrentMonth,
                  ),
                )
              : null,
          onLongPress: onDateLabelLongPress != null
              ? () => onDateLabelLongPress(
                  context,
                  MCalDateLabelTapDetails(
                    date: labelContext.date,
                    isToday: labelContext.isToday,
                    isCurrentMonth: labelContext.isCurrentMonth,
                  ),
                )
              : null,
          onDoubleTap: onDateLabelDoubleTap != null
              ? () => onDateLabelDoubleTap(
                  context,
                  MCalDateLabelTapDetails(
                    date: labelContext.date,
                    isToday: labelContext.isToday,
                    isCurrentMonth: labelContext.isCurrentMonth,
                  ),
                )
              : null,
          child: result,
        );
      } else {
        // No gesture handlers - wrap in IgnorePointer so taps pass through to Layer 1's cells
        result = IgnorePointer(child: result);
      }

      // Wrap in MouseRegion for hover support (only if callback provided)
      if (onHoverDateLabel != null) {
        result = MouseRegion(
          onEnter: (_) => onHoverDateLabel(context, labelContext),
          onExit: (_) => onHoverDateLabel(context, null),
          child: result,
        );
      }

      return result;
    };
  }

  /// Wraps an overflow indicator builder with tap, long-press, and double-tap handlers.
  static MCalOverflowIndicatorBuilder wrapOverflowIndicatorBuilder({
    required Widget Function(
      BuildContext,
      MCalMonthOverflowIndicatorContext,
      Widget,
    )?
    developerBuilder,
    required Widget Function(BuildContext, MCalMonthOverflowIndicatorContext)
    defaultBuilder,
    void Function(BuildContext, MCalOverflowTapDetails)? onOverflowTap,
    void Function(BuildContext, MCalOverflowTapDetails)? onOverflowLongPress,
    void Function(BuildContext, MCalOverflowTapDetails)? onOverflowDoubleTap,
  }) {
    return (
      BuildContext context,
      MCalMonthOverflowIndicatorContext overflowContext,
    ) {
      final defaultWidget = defaultBuilder(context, overflowContext);

      final visualWidget = developerBuilder != null
          ? developerBuilder(context, overflowContext, defaultWidget)
          : defaultWidget;

      // Wrap with gesture detector for tap, long-press, and double-tap
      return GestureDetector(
        onTap: onOverflowTap != null
            ? () => onOverflowTap(
                context,
                MCalOverflowTapDetails(
                  date: overflowContext.date,
                  hiddenEvents: overflowContext.hiddenEvents,
                  visibleEvents: overflowContext.visibleEvents,
                ),
              )
            : null,
        onLongPress: onOverflowLongPress != null
            ? () => onOverflowLongPress(
                context,
                MCalOverflowTapDetails(
                  date: overflowContext.date,
                  hiddenEvents: overflowContext.hiddenEvents,
                  visibleEvents: overflowContext.visibleEvents,
                ),
              )
            : null,
        onDoubleTap: onOverflowDoubleTap != null
            ? () => onOverflowDoubleTap(
                context,
                MCalOverflowTapDetails(
                  date: overflowContext.date,
                  hiddenEvents: overflowContext.hiddenEvents,
                  visibleEvents: overflowContext.visibleEvents,
                ),
              )
            : null,
        child: visualWidget,
      );
    };
  }
}
