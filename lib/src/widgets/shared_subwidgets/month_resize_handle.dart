import 'package:flutter/material.dart';
import '../mcal_callback_details.dart';
import '../mcal_layout_directionality.dart';
import '../../models/mcal_calendar_event.dart';
import '../../styles/mcal_month_view_theme_data.dart';
import '../../styles/mcal_theme.dart';
import '../mcal_month_view_contexts.dart';

/// A thin draggable zone on the leading or trailing edge of an event tile
/// that allows the user to resize the event by dragging.
///
/// The handle is positioned as a narrow vertical strip (default 8dp wide)
/// at the start or end edge of the event tile. It provides:
/// - A `SystemMouseCursors.resizeColumn` cursor on hover
/// - Horizontal drag gesture callbacks for resize interaction
/// - RTL-aware positioning using `MCalLayoutDirectionality.of(context)`
/// - Semantic labels for accessibility ("Resize start edge" / "Resize end edge")
///
/// Visual-only resize handle positioned on the edge of an event tile.
///
/// This widget must be placed inside a [Stack] alongside the event tile.
/// It shows a thin visual indicator and a resize cursor on hover.
///
/// **All gesture handling has been moved to a separate Layer 5 overlay**
/// (see [_buildResizeGestureLayer]) that uses raw [Listener] pointer events.
/// This architecture is immune to widget rebuilds — even if the event tile
/// tree is recreated during resize, the Layer 5 [Listener] continues
/// tracking the active pointer because it lives in a stable sibling branch
/// of the widget tree.
///
/// The [onPointerDown] callback is fired when the user presses on this
/// handle, allowing the parent to register which event/edge is targeted
/// and acquire a scroll hold on the [PageView].
class MonthResizeHandle extends StatelessWidget {
  const MonthResizeHandle({
    super.key,
    required this.edge,
    required this.event,
    required this.onPointerDown,
    required this.resizeHandleColor,
    this.theme,
    this.visualBuilder,
    this.inset = 0.0,
  });

  /// Which edge this handle is positioned on.
  final MCalResizeEdge edge;

  /// The event this handle belongs to.
  final MCalCalendarEvent event;

  /// Called when a pointer goes down on this handle.
  /// The parent uses this to register the resize target and acquire a
  /// scroll hold before the gesture arena resolves.
  final void Function(MCalCalendarEvent event, MCalResizeEdge edge, int pointer)
  onPointerDown;

  /// Color for the default resize handle visual indicator.
  final Color resizeHandleColor;

  /// Month view theme for resolving resize handle dimensions.
  final MCalMonthViewThemeData? theme;

  /// Optional custom builder for the visual indicator.
  ///
  /// When provided, replaces the default themed semi-transparent white bar.
  /// The framework still handles hit testing, cursor feedback, and positioning.
  final Widget Function(BuildContext, MCalResizeHandleContext)? visualBuilder;

  /// Horizontal inset from the tile edge in logical pixels.
  ///
  /// Shifts the handle (both visual and interactive hit area) inward.
  /// Defaults to 0.0 (no inset).
  final double inset;

  /// The width of the interactive handle zone in logical pixels.
  static const double handleWidth = 8.0;

  @override
  Widget build(BuildContext context) {
    final isLayoutRTL = MCalLayoutDirectionality.of(context);

    // In LTR: start edge is on the left, end edge is on the right
    // In RTL: start edge is on the right, end edge is on the left
    final isLeading = (edge == MCalResizeEdge.start) != isLayoutRTL;

    // Build the visual child — custom builder or default white bar.
    final handleContext = MCalResizeHandleContext(
      edge: edge,
      event: event,
      isDropTargetPreview: false,
    );
    final Widget visual;
    if (visualBuilder != null) {
      visual = visualBuilder!(context, handleContext);
    } else {
      final defaults = MCalThemeData.fromTheme(Theme.of(context));
      final handleWidth = theme?.resizeHandleVisualWidth ??
          defaults.monthViewTheme!.resizeHandleVisualWidth!;
      final vMargin = theme?.resizeHandleVerticalMargin ??
          defaults.monthViewTheme!.resizeHandleVerticalMargin!;
      final handleRadius = theme?.resizeHandleBorderRadius ??
          defaults.monthViewTheme!.resizeHandleBorderRadius!;
      final tileH = theme?.eventTileHeight ??
          defaults.monthViewTheme!.eventTileHeight!;
      final handleHeight = tileH - (2 * vMargin);
      visual = Container(
        width: handleWidth,
        height: handleHeight > 0 ? handleHeight : 0,
        decoration: BoxDecoration(
          color: resizeHandleColor,
          borderRadius: BorderRadius.circular(handleRadius),
        ),
      );
    }

    return Positioned(
      left: isLeading ? inset : null,
      right: isLeading ? null : inset,
      top: 0,
      bottom: 0,
      width: MonthResizeHandle.handleWidth,
      child: Semantics(
        container: true,
        label: edge == MCalResizeEdge.start
            ? 'Resize start edge'
            : 'Resize end edge',
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeColumn,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (pointerEvent) {
              onPointerDown(event, edge, pointerEvent.pointer);
            },
            child: Center(child: visual),
          ),
        ),
      ),
    );
  }
}
