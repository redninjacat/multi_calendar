import 'package:flutter/material.dart';
import '../../models/mcal_calendar_event.dart';
import '../mcal_callback_details.dart';

/// Vertical resize handle for timed event tiles in Day View.
///
/// Positioned at the top (start edge) or bottom (end edge) of an event tile.
/// Provides ~8dp hit area, semantic labels, and cursor feedback for resize.
/// Uses [Listener] for pointer-down so the parent can track the gesture
/// across scroll and navigation (see design doc "Resize Gesture Tracking").
class TimeResizeHandle extends StatelessWidget {
  const TimeResizeHandle({
    super.key,
    required this.edge,
    required this.event,
    required this.handleSize,
    required this.tileWidth,
    required this.tileHeight,
    required this.resizeHandleColor,
    this.inset = 0.0,
    this.visualBuilder,
    this.onPointerDown,
  });

  final MCalResizeEdge edge;
  final MCalCalendarEvent event;
  final double handleSize;
  final double tileWidth;
  final double tileHeight;
  final Color resizeHandleColor;
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
        color: resizeHandleColor,
        borderRadius: BorderRadius.circular(1),
      ),
    );

    final visual = visualBuilder != null
        ? visualBuilder!(context, event, edge, defaultVisual)
        : defaultVisual;

    final semanticLabel = edge == MCalResizeEdge.start
        ? 'Resize start time'
        : 'Resize end time';

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
