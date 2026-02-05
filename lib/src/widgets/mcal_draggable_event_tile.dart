import 'package:flutter/material.dart';

import '../models/mcal_calendar_event.dart';
import '../styles/mcal_theme.dart';
import 'mcal_callback_details.dart';

/// A widget that wraps an event tile with drag-and-drop functionality.
///
/// This widget uses [LongPressDraggable] to make event tiles draggable via
/// a long-press gesture. It supports customization of both the dragged tile
/// appearance and the source placeholder.
///
/// The drag operation is initiated after a 200ms long-press delay, allowing
/// users to still tap on event tiles for selection without accidentally
/// starting a drag.
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
///   dragSourceBuilder: (context, details) {
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
  final Widget Function(BuildContext, MCalDragSourceDetails)? dragSourceBuilder;

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
    this.draggedTileBuilder,
    this.dragSourceBuilder,
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

  /// The long-press delay before drag starts (in milliseconds).
  static const int _longPressDelayMs = 200;

  /// Current drag position, used for the feedback builder.
  Offset _currentDragPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    // If dragging is disabled, just return the child
    if (!widget.enabled) {
      return widget.child;
    }

    // Capture theme data from the current context before entering the overlay.
    // The overlay context doesn't have access to MCalTheme, so we capture it here.
    final themeData = MCalTheme.maybeOf(context);

    return LongPressDraggable<MCalDragData>(
      data: MCalDragData(event: widget.event, sourceDate: widget.sourceDate),
      delay: const Duration(milliseconds: _longPressDelayMs),
      feedback: _buildFeedback(context, themeData),
      childWhenDragging: _buildChildWhenDragging(context),
      onDragStarted: _handleDragStarted,
      onDragEnd: _handleDragEnd,
      onDraggableCanceled: _handleDraggableCanceled,
      onDragUpdate: _handleDragUpdate,
      child: widget.child,
    );
  }

  /// Builds the feedback widget shown while dragging.
  ///
  /// The [capturedTheme] is the theme data captured from the original context
  /// before entering the overlay. This is necessary because the overlay context
  /// doesn't have access to the MCalTheme InheritedWidget.
  Widget _buildFeedback(BuildContext context, MCalThemeData? capturedTheme) {
    // Calculate full event width
    final eventDurationDays = _calculateEventDurationDays();
    final tileWidth =
        (widget.dayWidth * eventDurationDays) - (widget.horizontalSpacing * 2);

    // If custom builder is provided, use it
    if (widget.draggedTileBuilder != null) {
      // Wrap in MCalTheme to provide theme data in the overlay context
      Widget feedback = Builder(
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
        feedback = MCalTheme(data: capturedTheme, child: feedback);
      }

      return feedback;
    }

    // Use default feedback builder if provided (reuses existing tile builder logic)
    if (widget.defaultFeedbackBuilder != null) {
      return Material(
        elevation: _defaultDraggedTileElevation,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4.0),
        child: widget.defaultFeedbackBuilder!(tileWidth),
      );
    }

    // Fallback: just use the child with elevation
    return Material(
      elevation: _defaultDraggedTileElevation,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(4.0),
      child: widget.child,
    );
  }

  /// Calculates the number of days the event spans.
  int _calculateEventDurationDays() {
    final startDate = DateTime(
      widget.event.start.year,
      widget.event.start.month,
      widget.event.start.day,
    );
    final endDate = DateTime(
      widget.event.end.year,
      widget.event.end.month,
      widget.event.end.day,
    );
    return endDate.difference(startDate).inDays + 1;
  }

  /// Builds the placeholder widget shown at the source position while dragging.
  Widget _buildChildWhenDragging(BuildContext context) {
    // If custom builder is provided, use it
    if (widget.dragSourceBuilder != null) {
      final details = MCalDragSourceDetails(
        event: widget.event,
        sourceDate: widget.sourceDate,
      );
      return widget.dragSourceBuilder!(context, details);
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
