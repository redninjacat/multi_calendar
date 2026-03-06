import 'package:flutter/material.dart';

import '../../models/mcal_calendar_event.dart';
import '../../models/mcal_region.dart';
import '../../styles/mcal_theme.dart';
import '../mcal_callback_details.dart';
import '../mcal_day_view_contexts.dart';
import '../mcal_drag_handler.dart';
import '../mcal_draggable_event_tile.dart';

/// Widget for displaying all-day events in a flow layout.
///
/// Renders all-day events in horizontal rows with wrapping, respecting the
/// maximum rows constraint. Shows an overflow indicator when events exceed
/// the max rows limit. Supports drag-to-move and tap/long-press interactions.
class AllDayEventsSection extends StatelessWidget {
  const AllDayEventsSection({
    super.key,
    required this.events,
    required this.displayDate,
    required this.maxRows,
    required this.theme,
    required this.locale,
    this.allDayEventTileBuilder,
    this.allDayOverflowBuilder,
    required this.enableDragToMove,
    this.dragHandler,
    required this.isDragActive,
    this.onEventTap,
    this.onEventLongPress,
    this.onEventDoubleTap,
    this.keyboardFocusedEventId,
    this.onOverflowTap,
    this.onOverflowLongPress,
    this.onOverflowDoubleTap,
    this.onHoverOverflow,
    this.onHoverEvent,
    this.onVisibleCountChanged,
    this.onTimeSlotTap,
    this.onTimeSlotLongPress,
    this.onDragStarted,
    this.onDragEnded,
    this.regions = const [],
    this.onDragCancelled,
    this.draggedTileBuilder,
    this.dragSourceTileBuilder,
    this.dragLongPressDelay = const Duration(milliseconds: 200),
  });

  final List<MCalCalendarEvent> events;
  final DateTime displayDate;
  final int maxRows;
  final MCalThemeData theme;
  final Locale locale;
  final Widget Function(
    BuildContext,
    MCalCalendarEvent,
    MCalAllDayEventTileContext,
    Widget,
  )?
  allDayEventTileBuilder;
  final Widget Function(
    BuildContext,
    MCalDayOverflowIndicatorContext,
    Widget,
  )?
  allDayOverflowBuilder;
  final bool enableDragToMove;
  final MCalDragHandler? dragHandler;
  final bool isDragActive;
  final void Function(BuildContext, MCalEventTapDetails)? onEventTap;
  final void Function(BuildContext, MCalEventTapDetails)? onEventLongPress;
  final void Function(BuildContext, MCalEventTapDetails)? onEventDoubleTap;
  final String? keyboardFocusedEventId;
  final void Function(BuildContext, List<MCalCalendarEvent>, DateTime)?
  onOverflowTap;
  final void Function(BuildContext, List<MCalCalendarEvent>, DateTime)?
  onOverflowLongPress;
  final void Function(BuildContext, MCalOverflowTapDetails)?
  onOverflowDoubleTap;
  final void Function(BuildContext, MCalOverflowTapDetails?)? onHoverOverflow;
  final void Function(BuildContext, MCalCalendarEvent?)? onHoverEvent;
  final void Function(int)? onVisibleCountChanged;
  final void Function(BuildContext, MCalTimeSlotContext)? onTimeSlotTap;
  final void Function(BuildContext, MCalTimeSlotContext)? onTimeSlotLongPress;
  final void Function(MCalCalendarEvent, DateTime)? onDragStarted;
  final void Function(bool)? onDragEnded;
  final VoidCallback? onDragCancelled;
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
  final List<MCalRegion> regions;

  static const _wrapSpacing = 4.0;
  static const _wrapRunSpacing = 4.0;
  static const _sectionHPadding = 8.0;

  static const _defaultTileWidth = 120.0;
  static const _defaultTileHeight = 28.0;
  static const _defaultOverflowWidth = 80.0;

  @override
  Widget build(BuildContext context) {
    final effectiveMaxRows = maxRows;
    final tileWidth = theme.dayTheme?.allDayTileWidth ?? _defaultTileWidth;
    final tileHeight = theme.dayTheme?.allDayTileHeight ?? _defaultTileHeight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: _sectionHPadding,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: theme.cellBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color:
                theme.cellBorderColor ?? Colors.grey.withValues(alpha: 0.2),
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              'All-day',
              style:
                  theme.dayTheme?.timeLegendTextStyle ??
                  TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = constraints.maxWidth;
              final tilesPerRow = _tilesPerRow(contentWidth, tileWidth);
              final totalSlots = effectiveMaxRows * tilesPerRow;
              final hasOverflow = events.length > totalSlots;

              final maxVisibleEvents =
                  hasOverflow ? totalSlots - 1 : events.length;
              final visibleEvents =
                  events.take(maxVisibleEvents).toList();
              final overflowCount = events.length - maxVisibleEvents;

              onVisibleCountChanged?.call(visibleEvents.length);

              return ConstrainedBox(
                constraints: BoxConstraints(minHeight: tileHeight),
                child: Wrap(
                  spacing: _wrapSpacing,
                  runSpacing: _wrapRunSpacing,
                  children: [
                    for (final event in visibleEvents)
                      _buildEventTile(context, event, tileWidth, tileHeight),
                    if (hasOverflow)
                      _buildOverflowIndicator(
                          context, overflowCount, tileHeight),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static int _tilesPerRow(double contentWidth, double tileWidth) {
    if (contentWidth <= 0 || tileWidth <= 0) return 1;
    return ((contentWidth + _wrapSpacing) / (tileWidth + _wrapSpacing))
        .floor()
        .clamp(1, 99);
  }

  Widget _buildEventTile(
    BuildContext context,
    MCalCalendarEvent event,
    double tileWidth,
    double tileHeight,
  ) {
    final tileContext = MCalAllDayEventTileContext(
      event: event,
      displayDate: displayDate,
      regions: regions,
    );

    final defaultWidget = _buildDefaultTile(context, event);
    Widget tile = allDayEventTileBuilder != null
        ? allDayEventTileBuilder!(context, event, tileContext, defaultWidget)
        : defaultWidget;

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

    tile = Semantics(
      label: '${event.title}, All day',
      button: true,
      child: tile,
    );

    final dragEnabled = enableDragToMove && onDragStarted != null;
    if (onEventTap != null ||
        (!dragEnabled && onEventLongPress != null) ||
        onEventDoubleTap != null) {
      tile = GestureDetector(
        onTap: onEventTap != null
            ? () => onEventTap!(
                context,
                MCalEventTapDetails(event: event, displayDate: displayDate),
              )
            : null,
        onLongPress: !dragEnabled && onEventLongPress != null
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

    if (dragEnabled) {
      final hSpacing = theme.eventTileHorizontalSpacing ?? 2.0;
      tile = MCalDraggableEventTile(
        event: event,
        sourceDate: displayDate,
        dayWidth: tileWidth,
        horizontalSpacing: hSpacing,
        enabled: true,
        dragLongPressDelay: dragLongPressDelay,
        draggedTileBuilder: draggedTileBuilder != null
            ? (ctx, details, defaultWidget) =>
                  draggedTileBuilder!(ctx, event, details, defaultWidget)
            : null,
        dragSourceTileBuilder: dragSourceTileBuilder != null
            ? (ctx, details, defaultWidget) =>
                  dragSourceTileBuilder!(ctx, event, details, defaultWidget)
            : null,
        onDragStarted: () => onDragStarted!(event, displayDate),
        onDragEnded: onDragEnded,
        onDragCanceled: onDragCancelled,
        child: tile,
      );
    }

    if (onHoverEvent != null) {
      tile = MouseRegion(
        onEnter: (_) => onHoverEvent!(context, event),
        onExit: (_) => onHoverEvent!(context, null),
        child: tile,
      );
    }

    return SizedBox(width: tileWidth, height: tileHeight, child: tile);
  }

  Widget _buildDefaultTile(BuildContext context, MCalCalendarEvent event) {
    final tileColor = theme.ignoreEventColors
        ? (theme.allDayEventBackgroundColor ??
              theme.eventTileBackgroundColor ??
              Colors.blue)
        : (event.color ??
              theme.allDayEventBackgroundColor ??
              theme.eventTileBackgroundColor ??
              Colors.blue);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: tileColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(theme.eventTileCornerRadius ?? 3.0),
        border: Border.all(
          color: tileColor,
          width: theme.allDayEventBorderWidth ?? 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              event.title,
              style:
                  theme.allDayEventTextStyle ??
                  TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverflowIndicator(
    BuildContext context,
    int count,
    double tileHeight,
  ) {
    final overflowWidth =
        theme.dayTheme?.allDayOverflowIndicatorWidth ?? _defaultOverflowWidth;
    final overflowEvents = events.skip(events.length - count).toList();
    final visibleEvts = events.take(events.length - count).toList();

    final overflowContext = MCalDayOverflowIndicatorContext(
      date: displayDate,
      hiddenEventCount: count,
      hiddenEvents: overflowEvents,
      visibleEvents: visibleEvts,
    );

    final defaultWidget = _buildDefaultOverflowIndicator(context, count);

    Widget indicator = allDayOverflowBuilder != null
        ? allDayOverflowBuilder!(context, overflowContext, defaultWidget)
        : defaultWidget;

    indicator = Semantics(
      label: '$count more all-day events',
      button: true,
      child: GestureDetector(
        onTap: onOverflowTap != null
            ? () => onOverflowTap!(context, overflowEvents, displayDate)
            : null,
        onLongPress: onOverflowLongPress != null
            ? () => onOverflowLongPress!(context, overflowEvents, displayDate)
            : null,
        onDoubleTap: onOverflowDoubleTap != null
            ? () {
                onOverflowDoubleTap!(
                  context,
                  MCalOverflowTapDetails(
                    date: displayDate,
                    hiddenEvents: overflowEvents,
                    visibleEvents: visibleEvts,
                  ),
                );
              }
            : null,
        child: indicator,
      ),
    );

    if (onHoverOverflow != null) {
      indicator = MouseRegion(
        onEnter: (_) => onHoverOverflow!(
          context,
          MCalOverflowTapDetails(
            date: displayDate,
            hiddenEvents: overflowEvents,
            visibleEvents: visibleEvts,
          ),
        ),
        onExit: (_) => onHoverOverflow!(context, null),
        child: indicator,
      );
    }

    return SizedBox(width: overflowWidth, height: tileHeight, child: indicator);
  }

  Widget _buildDefaultOverflowIndicator(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color:
            theme.cellBorderColor?.withValues(alpha: 0.1) ??
            Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
          theme.eventTileCornerRadius ?? 3.0,
        ),
        border: Border.all(
          color:
              theme.cellBorderColor ?? Colors.grey.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Text(
        '+$count more',
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
