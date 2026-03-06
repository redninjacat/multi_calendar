import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../models/mcal_calendar_event.dart';
import '../../models/mcal_region.dart';
import '../../styles/mcal_theme.dart';
import '../../utils/day_view_overlap.dart';
import '../../utils/time_utils.dart';
import '../mcal_callback_details.dart';
import '../mcal_day_view_contexts.dart';
import '../mcal_draggable_event_tile.dart';
import '../shared_subwidgets/time_resize_handle.dart';

/// Widget for rendering timed events with overlap-aware column layout.
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
class TimeGridEventsLayer extends StatelessWidget {
  const TimeGridEventsLayer({
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
    this.onEventDoubleTap,
    this.onHoverEvent,
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
    this.regions = const [],
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
  final void Function(BuildContext, MCalCalendarEvent?)? onHoverEvent;
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
  final List<MCalRegion> regions;

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

  Widget _buildPositionedEvent(
    BuildContext context,
    DayViewEventWithColumn eventWithColumn,
    double areaWidth,
  ) {
    final event = eventWithColumn.event;
    final columnIndex = eventWithColumn.columnIndex;
    final totalColumns = eventWithColumn.totalColumns;

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

    final isStartOnDisplayDate =
        event.start.year == displayDate.year &&
        event.start.month == displayDate.month &&
        event.start.day == displayDate.day;
    final isEndOnDisplayDate =
        event.end.year == displayDate.year &&
        event.end.month == displayDate.month &&
        event.end.day == displayDate.day;

    final effectiveStart = isStartOnDisplayDate ? event.start : dayStart;
    final effectiveEnd = isEndOnDisplayDate ? event.end : dayEnd;

    final startOffset = timeToOffset(
      time: effectiveStart,
      startHour: startHour,
      hourHeight: hourHeight,
    );

    final rawHeight = durationToHeight(
      duration: effectiveEnd.difference(effectiveStart),
      hourHeight: hourHeight,
    );

    final minHeight = theme.dayTheme?.timedEventMinHeight ?? 20.0;
    final height = rawHeight < minHeight ? minHeight : rawHeight;

    final columnWidth = areaWidth / totalColumns;
    final left = columnIndex * columnWidth;
    final width = columnWidth;

    final tileContext = MCalTimedEventTileContext(
      event: event,
      displayDate: displayDate,
      columnIndex: columnIndex,
      totalColumns: totalColumns,
      startTime: effectiveStart,
      endTime: effectiveEnd,
      isStartOnDisplayDate: isStartOnDisplayDate,
      isEndOnDisplayDate: isEndOnDisplayDate,
      regions: regions,
    );

    Widget tile = _buildEventTile(context, event, tileContext);

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

    if (onEventTap != null ||
        (!enableDragToMove && onEventLongPress != null) ||
        onEventDoubleTap != null) {
      tile = GestureDetector(
        onTap: onEventTap != null
            ? () => onEventTap!(
                context,
                MCalEventTapDetails(event: event, displayDate: displayDate),
              )
            : null,
        onLongPress: !enableDragToMove && onEventLongPress != null
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

    if (enableDragToMove) {
      final hSpacing = theme.eventTileHorizontalSpacing ?? 2.0;
      tile = MCalDraggableEventTile(
        event: event,
        sourceDate: displayDate,
        dayWidth: width,
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
    }

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

    if (onHoverEvent != null) {
      tile = MouseRegion(
        onEnter: (_) => onHoverEvent!(context, event),
        onExit: (_) => onHoverEvent!(context, null),
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

  bool _shouldShowResizeHandles(
    MCalCalendarEvent event,
    MCalTimedEventTileContext tileContext,
  ) {
    if (!tileContext.isStartOnDisplayDate && !tileContext.isEndOnDisplayDate) {
      return false;
    }
    final duration = event.end.difference(event.start);
    final minMinutes = theme.dayTheme?.minResizeDurationMinutes ?? 15;
    return duration.inMinutes >= minMinutes;
  }

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

    if (tileContext.isStartOnDisplayDate) {
      final startInset =
          resizeHandleInset?.call(tileContext, MCalResizeEdge.start) ?? 0.0;
      children.add(
        TimeResizeHandle(
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

    if (tileContext.isEndOnDisplayDate) {
      final endInset =
          resizeHandleInset?.call(tileContext, MCalResizeEdge.end) ?? 0.0;
      children.add(
        TimeResizeHandle(
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

    return SizedBox(
      width: width,
      height: height,
      child: Stack(clipBehavior: Clip.none, children: children),
    );
  }

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

  Widget _buildEventTile(
    BuildContext context,
    MCalCalendarEvent event,
    MCalTimedEventTileContext tileContext,
  ) {
    final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en');
    final localeStr = locale.toString();

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

  Color _getContrastColor(Color backgroundColor) {
    final r = backgroundColor.r;
    final g = backgroundColor.g;
    final b = backgroundColor.b;
    final luminance = (0.299 * r + 0.587 * g + 0.114 * b);

    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}
