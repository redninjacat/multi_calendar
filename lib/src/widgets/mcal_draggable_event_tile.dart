import 'package:flutter/material.dart';

import '../models/mcal_calendar_event.dart';
import '../styles/mcal_theme.dart';
import '../utils/date_utils.dart';
import 'mcal_callback_details.dart';

/// A widget that wraps an event tile with drag-and-drop functionality.
///
/// This widget uses [LongPressDraggable] to make event tiles draggable via
/// a long-press gesture. It supports customization of both the dragged tile
/// appearance and the source placeholder.
///
/// The drag operation is initiated after a configurable long-press delay
/// (default 200ms), allowing users to still tap on event tiles for selection
/// without accidentally starting a drag.
///
/// Example:
/// ```dart
/// MCalDraggableEventTile(
///   event: myEvent,
///   sourceDate: DateTime(2024, 2, 15),
///   onDragStarted: () => print('Drag started'),
///   onDragEnded: (accepted) => print('Drag ended, accepted: $accepted'),
///   child: EventTileWidget(event: myEvent),
/// )
/// ```
///
/// With custom builders:
/// ```dart
/// MCalDraggableEventTile(
///   event: myEvent,
///   sourceDate: DateTime(2024, 2, 15),
///   draggedTileBuilder: (context, details) {
///     return Material(
///       elevation: 12,
///       child: Container(
///         padding: EdgeInsets.all(8),
///         color: details.event.color,
///         child: Text(details.event.title),
///       ),
///     );
///   },
///   dragSourceTileBuilder: (context, details) {
///     return Container(
///       decoration: BoxDecoration(
///         border: Border.all(
///           color: Colors.grey,
///           style: BorderStyle.dashed,
///         ),
///       ),
///     );
///   },
///   child: EventTileWidget(event: myEvent),
/// )
/// ```
class MCalDraggableEventTile extends StatefulWidget {
  /// The event tile widget to wrap.
  ///
  /// This is the visual representation of the event that will be
  /// displayed normally and used as the basis for the drag feedback.
  final Widget child;

  /// The calendar event associated with this tile.
  ///
  /// This event is passed as the drag data and used in the
  /// details objects for custom builders.
  final MCalCalendarEvent event;

  /// The date where this tile is rendered.
  ///
  /// This represents the source date for the drag operation and is
  /// used to calculate the day delta when the event is dropped.
  final DateTime sourceDate;

  /// Whether dragging is enabled for this tile.
  ///
  /// When set to false, the tile behaves like a normal widget and
  /// does not respond to long-press drag gestures.
  ///
  /// Defaults to true.
  final bool enabled;

  /// Custom builder for the dragged tile feedback widget.
  ///
  /// When provided, this builder is called to create the visual
  /// representation of the tile while it's being dragged.
  ///
  /// The [MCalDraggedTileDetails] provides:
  /// - [event]: The calendar event being dragged
  /// - [sourceDate]: The original date of the tile
  /// - [currentPosition]: The current drag position
  ///
  /// If not provided, the default feedback is the child widget wrapped
  /// in a [Material] with elevation from the theme.
  final Widget Function(BuildContext, MCalDraggedTileDetails)?
  draggedTileBuilder;

  /// Custom builder for the source placeholder widget.
  ///
  /// When provided, this builder is called to create the placeholder
  /// widget that appears in place of the original tile while it's
  /// being dragged.
  ///
  /// The [MCalDragSourceDetails] provides:
  /// - [event]: The calendar event being dragged
  /// - [sourceDate]: The original date of the tile
  ///
  /// If not provided, the default placeholder is the child widget
  /// with 50% opacity (ghost effect).
  final Widget Function(BuildContext, MCalDragSourceDetails)?
  dragSourceTileBuilder;

  /// Callback invoked when a drag operation starts.
  ///
  /// This is called after the long-press delay has elapsed and the
  /// drag has begun.
  final VoidCallback? onDragStarted;

  /// Callback invoked when a drag operation ends.
  ///
  /// The [wasAccepted] parameter indicates whether the drag was
  /// accepted by a [DragTarget]. This is useful for handling
  /// successful vs cancelled drags differently.
  final void Function(bool wasAccepted)? onDragEnded;

  /// Callback invoked when a drag operation is cancelled.
  ///
  /// This is called when the drag ends without being accepted by
  /// any [DragTarget], such as when the user releases outside of
  /// a valid drop zone.
  final VoidCallback? onDragCanceled;

  /// Builder for creating the default dragged tile feedback.
  ///
  /// This builder is used when [draggedTileBuilder] is not provided.
  /// It receives the full tile width (calculated from event duration and day width)
  /// and should return a widget matching the original tile's styling.
  ///
  /// The builder should treat the tile as a single non-continuation segment
  /// (isFirstSegment=true, isLastSegment=true) for uniform corners and borders.
  final Widget Function(double tileWidth)? defaultFeedbackBuilder;

  /// The width of a single day cell.
  ///
  /// Used to calculate the full tile width for the dragged feedback.
  final double dayWidth;

  /// The horizontal spacing around the tile.
  final double horizontalSpacing;

  /// The long-press delay before a drag operation starts.
  ///
  /// Defaults to 200 milliseconds. Only used when the tile is enabled for dragging.
  final Duration dragLongPressDelay;

  /// Creates a new [MCalDraggableEventTile] widget.
  ///
  /// The [child], [event], [sourceDate], [dayWidth], and [horizontalSpacing]
  /// parameters are required.
  const MCalDraggableEventTile({
    super.key,
    required this.child,
    required this.event,
    required this.sourceDate,
    required this.dayWidth,
    required this.horizontalSpacing,
    this.enabled = true,
    this.dragLongPressDelay = const Duration(milliseconds: 200),
    this.draggedTileBuilder,
    this.dragSourceTileBuilder,
    this.onDragStarted,
    this.onDragEnded,
    this.onDragCanceled,
    this.defaultFeedbackBuilder,
  });

  @override
  State<MCalDraggableEventTile> createState() => _MCalDraggableEventTileState();
}

class _MCalDraggableEventTileState extends State<MCalDraggableEventTile> {
  /// Default elevation for the dragged tile feedback.
  ///
  /// This is used when no custom draggedTileBuilder is provided and
  /// the theme doesn't specify draggedTileElevation.
  static const double _defaultDraggedTileElevation = 6.0;

  /// Default opacity for the source placeholder ghost effect.
  static const double _defaultSourceOpacity = 0.5;

  /// Current drag position, used for the feedback builder.
  Offset _currentDragPosition = Offset.zero;

  /// Mutable holder for the grab offset.
  ///
  /// This is used instead of a simple double because the LongPressDraggable
  /// captures the data at build time, but we need to update the grab offset
  /// when the pointer down event fires. Using a holder allows the MCalDragData
  /// to always read the current value.
  final MCalGrabOffsetHolder _grabOffsetHolder = MCalGrabOffsetHolder();

  /// The offset for the drag feedback to position the tile under the pointer.
  ///
  /// Uses the raw tap position so the tile follows the pointer naturally
  /// at the point where the user grabbed it.
  Offset _feedbackOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    // If dragging is disabled, just return the child
    if (!widget.enabled) {
      return widget.child;
    }

    // Capture theme data from the current context before entering the overlay.
    // The overlay context doesn't have access to MCalTheme, so we capture it here.
    final themeData = MCalTheme.maybeOf(context);

    // Wrap in Listener to capture pointer down position before drag starts.
    // This allows us to calculate where within the tile the user tapped,
    // which is needed to determine where the tile's left edge is for drop targeting.
    return Listener(
      onPointerDown: (event) {
        // Calculate grabOffsetX: the position from the container's left edge.
        // The tile content starts at horizontalSpacing from the cell edge,
        // so we add that to get the position within the full container.
        final newGrabOffsetX =
            event.localPosition.dx + widget.horizontalSpacing;

        // Feedback offset positions the feedback so the grabbed point is under
        // the cursor. We add horizontalSpacing to account for the tile's offset
        // from the cell edge.
        final newFeedbackOffset = Offset(
          -(event.localPosition.dx + widget.horizontalSpacing),
          -event.localPosition.dy,
        );

        // Update the holder directly - no setState needed since MCalDragData
        // reads from the holder. The holder pattern solves the timing issue
        // where LongPressDraggable captures data at build time.
        _grabOffsetHolder.grabOffsetX = newGrabOffsetX;

        // Still need setState for feedbackOffset since it's used in the build
        if (_feedbackOffset != newFeedbackOffset) {
          setState(() {
            _feedbackOffset = newFeedbackOffset;
          });
        }
      },
      child: LongPressDraggable<MCalDragData>(
        data: MCalDragData(
          event: widget.event,
          sourceDate: widget.sourceDate,
          grabOffsetHolder: _grabOffsetHolder,
          horizontalSpacing: widget.horizontalSpacing,
        ),
        delay: widget.dragLongPressDelay,
        feedbackOffset: _feedbackOffset,
        feedback: _buildFeedback(context, themeData),
        childWhenDragging: _buildChildWhenDragging(context),
        onDragStarted: _handleDragStarted,
        onDragEnd: _handleDragEnd,
        onDraggableCanceled: _handleDraggableCanceled,
        onDragUpdate: _handleDragUpdate,
        child: widget.child,
      ),
    );
  }

  /// Builds the feedback widget shown while dragging.
  ///
  /// The [capturedTheme] is the theme data captured from the original context
  /// before entering the overlay. This is necessary because the overlay context
  /// doesn't have access to the MCalTheme InheritedWidget.
  ///
  /// All feedback widgets are wrapped in a [SizedBox] with a fixed width of
  /// `dayWidth * eventDuration`. This ensures reliable positioning math
  /// regardless of how the actual tile content is styled (e.g., half-width
  /// timed events in some styles).
  Widget _buildFeedback(BuildContext context, MCalThemeData? capturedTheme) {
    // Calculate the container width: exactly dayWidth * eventDuration
    // This is the "logical" width of the event span, not accounting for spacing.
    // Using this consistent width makes grabOffsetX math reliable.
    final eventDurationDays = _calculateEventDurationDays();
    final containerWidth = widget.dayWidth * eventDurationDays;

    // The actual tile content width (with spacing removed)
    final tileWidth = containerWidth - (widget.horizontalSpacing * 2);

    Widget feedbackContent;

    // If custom builder is provided, use it
    if (widget.draggedTileBuilder != null) {
      feedbackContent = Builder(
        builder: (innerContext) {
          final details = MCalDraggedTileDetails(
            event: widget.event,
            sourceDate: widget.sourceDate,
            currentPosition: _currentDragPosition,
            dayWidth: widget.dayWidth,
            horizontalSpacing: widget.horizontalSpacing,
            eventDurationDays: eventDurationDays,
          );
          return widget.draggedTileBuilder!(innerContext, details);
        },
      );

      // Wrap with MCalTheme if we captured theme data from the original context
      if (capturedTheme != null) {
        feedbackContent = MCalTheme(
          data: capturedTheme,
          child: feedbackContent,
        );
      }
    } else if (widget.defaultFeedbackBuilder != null) {
      // Use default feedback builder if provided (reuses existing tile builder logic)
      feedbackContent = Material(
        elevation: _defaultDraggedTileElevation,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(
          capturedTheme?.eventTileCornerRadius ?? 4.0,
        ),
        child: widget.defaultFeedbackBuilder!(tileWidth),
      );
    } else {
      // Fallback: just use the child with elevation
      feedbackContent = Material(
        elevation: _defaultDraggedTileElevation,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(
          capturedTheme?.eventTileCornerRadius ?? 4.0,
        ),
        child: widget.child,
      );
    }

    // Wrap in a SizedBox with the exact container width.
    // This ensures the feedback widget has a consistent logical size that
    // matches the event's day span, making grabOffsetX calculations reliable.
    // The content is left-aligned within this container.
    return SizedBox(
      width: containerWidth,
      child: Align(
        alignment: AlignmentDirectional.center,
        child: feedbackContent,
      ),
    );
  }

  /// Calculates the number of days the event spans.
  int _calculateEventDurationDays() {
    // Use DST-safe daysBetween for accurate day calculation
    return daysBetween(widget.event.start, widget.event.end) + 1;
  }

  /// Builds the placeholder widget shown at the source position while dragging.
  Widget _buildChildWhenDragging(BuildContext context) {
    // If custom builder is provided, use it
    if (widget.dragSourceTileBuilder != null) {
      final details = MCalDragSourceDetails(
        event: widget.event,
        sourceDate: widget.sourceDate,
      );
      return widget.dragSourceTileBuilder!(context, details);
    }

    // Build default: child with 50% opacity (ghost effect)
    return Opacity(opacity: _defaultSourceOpacity, child: widget.child);
  }

  /// Handles the drag start event.
  void _handleDragStarted() {
    widget.onDragStarted?.call();
  }

  /// Handles the drag end event.
  void _handleDragEnd(DraggableDetails details) {
    widget.onDragEnded?.call(details.wasAccepted);
  }

  /// Handles the drag cancelled event.
  void _handleDraggableCanceled(Velocity velocity, Offset offset) {
    widget.onDragCanceled?.call();
  }

  /// Updates the current drag position.
  void _handleDragUpdate(DragUpdateDetails details) {
    _currentDragPosition = details.globalPosition;
  }
}
