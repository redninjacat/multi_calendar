import 'package:flutter/material.dart';
import '../models/mcal_calendar_event.dart';
import 'mcal_callback_details.dart';
import 'mcal_draggable_event_tile.dart';
import 'mcal_month_view_contexts.dart';
import 'mcal_week_layout_contexts.dart';
import 'mcal_drag_handler.dart';

/// Utility class that wraps developer-provided builders with interaction handlers.
///
/// This separates visual customization (developer's responsibility) from
/// interaction handling (package's responsibility). The wrapped builders
/// are passed to weekLayoutBuilder so that interactions work automatically.
class MCalBuilderWrapper {
  MCalBuilderWrapper._(); // Prevent instantiation

  /// Wraps an event tile builder with tap, long-press, and drag handlers.
  ///
  /// The returned builder will:
  /// 1. Call the developer's builder (or default) to get the visual widget
  /// 2. Wrap it with GestureDetector for tap/long-press (if drag is disabled)
  /// 3. Wrap with MCalDraggableEventTile if drag is enabled
  static MCalEventTileBuilder wrapEventTileBuilder({
    required Widget Function(BuildContext, MCalEventTileContext, Widget)?
    developerBuilder,
    required Widget Function(BuildContext, MCalEventTileContext) defaultBuilder,
    void Function(BuildContext, MCalEventTapDetails)? onEventTap,
    void Function(BuildContext, MCalEventTapDetails)? onEventLongPress,
    bool enableDragAndDrop = false,
    MCalDragHandler? dragHandler,
    // Drag-related parameters
    Widget Function(BuildContext, MCalDraggedTileDetails)? draggedTileBuilder,
    Widget Function(BuildContext, MCalDragSourceDetails)? dragSourceTileBuilder,
    void Function(MCalCalendarEvent, DateTime)? onDragStartedCallback,
    void Function(bool)? onDragEndedCallback,
    VoidCallback? onDragCanceledCallback,
    // Tile sizing parameters for dragged feedback (required when drag enabled)
    required double dayWidth,
    double? tileHeight,
    double horizontalSpacing = 2.0,
  }) {
    return (BuildContext context, MCalEventTileContext tileContext) {
      // Get the default visual widget
      final defaultWidget = defaultBuilder(context, tileContext);

      // Let developer customize visuals if they provided a builder
      final visualWidget = developerBuilder != null
          ? developerBuilder(context, tileContext, defaultWidget)
          : defaultWidget;

      // If drag-and-drop is enabled, wrap with MCalDraggableEventTile
      if (enableDragAndDrop) {
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
          final syntheticSegment = MCalEventSegment(
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

        return MCalDraggableEventTile(
          event: event,
          sourceDate: displayDate,
          dayWidth: dayWidth,
          horizontalSpacing: horizontalSpacing,
          enabled: true,
          draggedTileBuilder: draggedTileBuilder,
          dragSourceTileBuilder: dragSourceTileBuilder,
          onDragStarted: onDragStartedCallback != null
              ? () => onDragStartedCallback(event, displayDate)
              : null,
          onDragEnded: onDragEndedCallback,
          onDragCanceled: onDragCanceledCallback,
          defaultFeedbackBuilder: defaultFeedbackBuilder,
          child: tileWithTapHandlers,
        );
      }

      // Drag is disabled - wrap with gesture detector for tap/long-press
      return GestureDetector(
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
        child: visualWidget,
      );
    };
  }

  /// Wraps a date label builder with optional tap/long-press handlers.
  ///
  /// If [onDateLabelTap] or [onDateLabelLongPress] is provided, the label
  /// is wrapped in a [GestureDetector] with the respective handlers.
  /// Otherwise, the label is wrapped in [IgnorePointer] so that taps
  /// pass through to Layer 1's cells, allowing [onCellTap] to be triggered.
  static MCalDateLabelBuilder wrapDateLabelBuilder({
    required Widget Function(BuildContext, MCalDateLabelContext, String)?
    developerBuilder,
    required Widget Function(BuildContext, MCalDateLabelContext) defaultBuilder,
    void Function(BuildContext, MCalDateLabelTapDetails)? onDateLabelTap,
    void Function(BuildContext, MCalDateLabelTapDetails)? onDateLabelLongPress,
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

      // If any handlers are provided, wrap in GestureDetector
      if (onDateLabelTap != null || onDateLabelLongPress != null) {
        return GestureDetector(
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
          child: visualWidget,
        );
      }

      // No handlers - wrap in IgnorePointer so taps pass through to Layer 1's cells
      return IgnorePointer(child: visualWidget);
    };
  }

  /// Wraps an overflow indicator builder with tap and long-press handlers.
  static MCalOverflowIndicatorBuilder wrapOverflowIndicatorBuilder({
    required Widget Function(
      BuildContext,
      MCalOverflowIndicatorContext,
      Widget,
    )?
    developerBuilder,
    required Widget Function(BuildContext, MCalOverflowIndicatorContext)
    defaultBuilder,
    void Function(BuildContext, MCalOverflowTapDetails)? onOverflowTap,
    void Function(BuildContext, MCalOverflowTapDetails)? onOverflowLongPress,
  }) {
    return (
      BuildContext context,
      MCalOverflowIndicatorContext overflowContext,
    ) {
      final defaultWidget = defaultBuilder(context, overflowContext);

      final visualWidget = developerBuilder != null
          ? developerBuilder(context, overflowContext, defaultWidget)
          : defaultWidget;

      // Wrap with gesture detector for tap and long-press
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
        child: visualWidget,
      );
    };
  }
}
