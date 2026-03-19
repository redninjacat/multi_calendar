import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../models/mcal_calendar_event.dart';
import '../../models/mcal_region.dart';
import '../../styles/mcal_theme.dart';
import '../../utils/day_view_overlap.dart';
import '../../utils/theme_cascade_utils.dart';
import '../../utils/time_utils.dart';
import '../mcal_callback_details.dart';
import '../mcal_day_view_contexts.dart';
import '../mcal_draggable_event_tile.dart';
import '../mcal_gesture_detector.dart';
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
    this.onEventSecondaryTap,
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
  final void Function(BuildContext, MCalEventTapDetails)? onEventSecondaryTap;
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
    final defaults = MCalThemeData.fromTheme(Theme.of(context));

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

    final minHeight = theme.dayViewTheme?.timedEventMinHeight ??
        defaults.dayViewTheme!.timedEventMinHeight!;
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
      final kbDefaults = MCalThemeData.fromTheme(Theme.of(context));
      final kbBorderColor = theme.dayViewTheme?.keyboardFocusBorderColor ??
          kbDefaults.dayViewTheme!.keyboardFocusBorderColor!;
      final kbBorderWidth =
          theme.dayViewTheme?.timedEventKeyboardFocusBorderWidth ??
          kbDefaults.dayViewTheme!.timedEventKeyboardFocusBorderWidth!;
      final kbBorderRadius =
          theme.dayViewTheme?.keyboardFocusBorderRadius ??
          kbDefaults.dayViewTheme!.keyboardFocusBorderRadius!;
      tile = Container(
        decoration: BoxDecoration(
          border: Border.all(color: kbBorderColor, width: kbBorderWidth),
          borderRadius: BorderRadius.circular(kbBorderRadius),
        ),
        child: tile,
      );
    }

    if (onEventTap != null ||
        (!enableDragToMove && onEventLongPress != null) ||
        onEventDoubleTap != null ||
        onEventSecondaryTap != null) {
      tile = MCalGestureDetector(
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
        onSecondaryTap: onEventSecondaryTap != null
            ? () => onEventSecondaryTap!(
                context,
                MCalEventTapDetails(event: event, displayDate: displayDate),
              )
            : null,
        child: tile,
      );
    }

    if (enableDragToMove) {
      final hSpacing = theme.dayViewTheme?.eventTileHorizontalSpacing ??
          defaults.dayViewTheme!.eventTileHorizontalSpacing!;
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
    final minMinutes = theme.dayViewTheme?.minResizeDurationMinutes ?? 15;
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
    final handleDefaults = MCalThemeData.fromTheme(Theme.of(context));
    final handleSize = theme.dayViewTheme?.resizeHandleSize ??
        handleDefaults.dayViewTheme!.resizeHandleSize!;
    final handleColor = theme.dayViewTheme?.resizeHandleColor ??
        handleDefaults.dayViewTheme!.resizeHandleColor!;
    final handleVisualHeight = theme.dayViewTheme?.resizeHandleVisualHeight ??
        handleDefaults.dayViewTheme!.resizeHandleVisualHeight!;
    final handleHMargin = theme.dayViewTheme?.resizeHandleHorizontalMargin ??
        handleDefaults.dayViewTheme!.resizeHandleHorizontalMargin!;
    final handleRadius = theme.dayViewTheme?.resizeHandleBorderRadius ??
        handleDefaults.dayViewTheme!.resizeHandleBorderRadius!;
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
          resizeHandleColor: handleColor,
          inset: startInset,
          resizeHandleVisualHeight: handleVisualHeight,
          resizeHandleHorizontalMargin: handleHMargin,
          resizeHandleBorderRadius: handleRadius,
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
          resizeHandleColor: handleColor,
          inset: endInset,
          resizeHandleVisualHeight: handleVisualHeight,
          resizeHandleHorizontalMargin: handleHMargin,
          resizeHandleBorderRadius: handleRadius,
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
    BuildContext context,
    MCalThemeData defaults,
    MCalCalendarEvent event,
    MCalTimedEventTileContext tileContext,
    String timeRange,
  ) {
    final tileColor = resolveEventTileColor(
      themeColor: theme.dayViewTheme?.eventTileBackgroundColor,
      eventColor: event.color,
      enableEventColorOverrides: theme.enableEventColorOverrides,
      defaultColor: defaults.dayViewTheme!.eventTileBackgroundColor!,
    );

    final lightContrast =
        theme.dayViewTheme?.eventTileLightContrastColor ??
        defaults.dayViewTheme!.eventTileLightContrastColor!;
    final darkContrast =
        theme.dayViewTheme?.eventTileDarkContrastColor ??
        defaults.dayViewTheme!.eventTileDarkContrastColor!;

    final textStyleColor = theme.enableEventColorOverrides
        ? theme.dayViewTheme?.eventTileTextStyle?.color
        : null;
    final contrastColor = textStyleColor ??
        resolveContrastColor(
          backgroundColor: tileColor,
          lightContrastColor: lightContrast,
          darkContrastColor: darkContrast,
        );
    final timeColor = contrastColor.withValues(alpha: 0.9);
    final showTimeRange =
        tileContext.endTime.difference(tileContext.startTime).inMinutes >= 30;

    final cornerRadius =
        theme.dayViewTheme?.eventTileCornerRadius ?? defaults.dayViewTheme!.eventTileCornerRadius!;
    final topRadius = tileContext.isStartOnDisplayDate
        ? Radius.circular(cornerRadius)
        : Radius.zero;
    final bottomRadius = tileContext.isEndOnDisplayDate
        ? Radius.circular(cornerRadius)
        : Radius.zero;

    final tileMargin = theme.dayViewTheme?.timedEventMargin ??
        defaults.dayViewTheme!.timedEventMargin!;
    final tilePadding = theme.dayViewTheme?.timedEventPadding ??
        defaults.dayViewTheme!.timedEventPadding!;
    final tileBorderWidth = theme.dayViewTheme?.eventTileBorderWidth ?? 0.0;
    final tileBorderColor = theme.dayViewTheme?.eventTileBorderColor;
    final tileBorder = (tileBorderWidth > 0 && tileBorderColor != null)
        ? Border.all(color: tileBorderColor, width: tileBorderWidth)
        : Border.all(color: tileColor, width: 0.0);

    return Container(
      margin: tileMargin,
      padding: tilePadding,
      decoration: BoxDecoration(
        color: tileColor.withValues(alpha: 0.85),
        borderRadius: BorderRadius.only(
          topLeft: topRadius,
          topRight: topRadius,
          bottomLeft: bottomRadius,
          bottomRight: bottomRadius,
        ),
        border: tileBorder,
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
                    defaults: defaults,
                  )
                : _buildNormalTileContent(
                    event: event,
                    timeRange: timeRange,
                    showTimeRange: showTimeRange,
                    contrastColor: contrastColor,
                    timeColor: timeColor,
                    theme: theme,
                    defaults: defaults,
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

    final defaults = MCalThemeData.fromTheme(Theme.of(context));
    final defaultWidget = _buildDefaultTimedEventTile(
      context,
      defaults,
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
    required MCalThemeData defaults,
  }) {
    final compactFontSize = theme.dayViewTheme?.timedEventCompactFontSize ??
        defaults.dayViewTheme!.timedEventCompactFontSize!;
    final titleStyle =
        theme.dayViewTheme?.eventTileTextStyle?.copyWith(
          fontSize: compactFontSize,
          fontWeight: FontWeight.w600,
          color: contrastColor,
        ) ??
        TextStyle(
          fontSize: compactFontSize,
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
    required MCalThemeData defaults,
  }) {
    final normalFontSize = theme.dayViewTheme?.timedEventNormalFontSize ??
        defaults.dayViewTheme!.timedEventNormalFontSize!;
    final compactFontSize = theme.dayViewTheme?.timedEventCompactFontSize ??
        defaults.dayViewTheme!.timedEventCompactFontSize!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          event.title,
          style:
              theme.dayViewTheme?.eventTileTextStyle?.copyWith(
                fontSize: normalFontSize,
                fontWeight: FontWeight.w600,
                color: contrastColor,
              ) ??
              TextStyle(
                fontSize: normalFontSize,
                fontWeight: FontWeight.w600,
                color: contrastColor,
              ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        if (showTimeRange)
          Padding(
            padding: EdgeInsets.only(
              top: theme.dayViewTheme?.timedEventTitleTimeGap ??
                  defaults.dayViewTheme!.timedEventTitleTimeGap!,
            ),
            child: Text(
              timeRange,
              style:
                  theme.dayViewTheme?.eventTileTextStyle?.copyWith(
                    fontSize: compactFontSize,
                    color: timeColor,
                  ) ??
                  TextStyle(fontSize: compactFontSize, color: timeColor),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
      ],
    );
  }

}
