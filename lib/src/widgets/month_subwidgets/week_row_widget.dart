import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../controllers/mcal_event_controller.dart';
import '../../models/mcal_calendar_event.dart';
import '../../styles/mcal_theme.dart';
import '../../utils/theme_cascade_utils.dart';
import '../../utils/date_utils.dart';
import '../mcal_builder_wrapper.dart';
import '../mcal_callback_details.dart';
import '../mcal_drag_handler.dart';
import '../mcal_layout_directionality.dart';
import '../mcal_month_default_week_layout.dart';
import '../mcal_month_multi_day_renderer.dart';
import '../mcal_month_view.dart';
import '../mcal_month_view_contexts.dart';
import '../mcal_month_week_layout_contexts.dart';
import '../shared_subwidgets/month_resize_handle.dart';
import 'day_cell_widget.dart';
import 'week_number_cell.dart';

/// Widget for rendering a single week row in the calendar grid.
class WeekRowWidget extends StatefulWidget {
  final List<DateTime> dates;
  final DateTime currentMonth;
  final List<MCalCalendarEvent> events;
  final MCalThemeData theme;
  final DateTime? focusedDate;
  final bool autoFocusOnCellTap;
  final ValueChanged<DateTime>? onSetFocusedDate;
  final Widget Function(BuildContext, MCalDayCellContext, Widget)?
  dayCellBuilder;
  final Widget Function(BuildContext, MCalEventTileContext, Widget)?
  eventTileBuilder;
  final Widget Function(BuildContext, MCalDateLabelContext, String)?
  dateLabelBuilder;
  final DateFormat? dateFormat;
  final bool Function(BuildContext, MCalCellInteractivityDetails)?
  cellInteractivityCallback;
  final void Function(BuildContext, MCalCellTapDetails)? onCellTap;
  final void Function(BuildContext, MCalCellTapDetails)? onCellLongPress;
  final void Function(BuildContext, MCalCellTapDetails)? onCellSecondaryTap;
  final void Function(BuildContext, MCalDateLabelTapDetails)? onDateLabelTap;
  final void Function(BuildContext, MCalDateLabelTapDetails)?
  onDateLabelLongPress;
  final void Function(BuildContext, MCalDateLabelTapDetails)?
  onDateLabelSecondaryTap;
  final void Function(BuildContext, MCalEventTapDetails)? onEventTap;
  final void Function(BuildContext, MCalEventTapDetails)? onEventLongPress;
  final void Function(BuildContext, MCalEventTapDetails)? onEventSecondaryTap;
  final void Function(BuildContext, MCalCellDoubleTapDetails)? onCellDoubleTap;
  final void Function(BuildContext, MCalEventDoubleTapDetails)?
  onEventDoubleTap;
  final void Function(BuildContext, MCalDayCellContext?)? onHoverCell;
  final void Function(BuildContext, MCalEventTileContext?)? onHoverEvent;
  final void Function(BuildContext, MCalDateLabelContext?)? onHoverDateLabel;
  final void Function(BuildContext, MCalOverflowTapDetails?)? onHoverOverflow;
  final void Function(BuildContext, MCalDateLabelTapDetails)?
  onDateLabelDoubleTap;
  final Locale locale;
  final int maxVisibleEventsPerDay;
  final void Function(BuildContext, MCalOverflowTapDetails)? onOverflowTap;
  final void Function(BuildContext, MCalOverflowTapDetails)?
  onOverflowLongPress;
  final void Function(BuildContext, MCalOverflowTapDetails)?
  onOverflowDoubleTap;
  final void Function(BuildContext, MCalOverflowTapDetails)?
  onOverflowSecondaryTap;
  final bool showWeekNumbers;
  final Widget Function(BuildContext, MCalWeekNumberContext)? weekNumberBuilder;

  /// Builder callback for customizing week row event layout.
  final MCalWeekLayoutBuilder? weekLayoutBuilder;

  /// Builder callback for customizing overflow indicator rendering.
  final Widget Function(
    BuildContext,
    MCalMonthOverflowIndicatorContext,
    Widget,
  )?
  overflowIndicatorBuilder;

  /// The index of this week row within the month grid.
  final int weekRowIndex;

  /// Multi-day event layouts for this week row.
  final List<MCalMultiDayEventLayout>? multiDayLayouts;

  // Drag-and-drop parameters
  final bool enableDragToMove;
  final Widget Function(BuildContext, MCalDraggedTileDetails, Widget)?
  draggedTileBuilder;
  final Widget Function(BuildContext, MCalDragSourceDetails, Widget)?
  dragSourceTileBuilder;
  final MCalEventTileBuilder? dropTargetTileBuilder;
  final Widget Function(BuildContext, MCalDropTargetCellDetails)?
  dropTargetCellBuilder;
  final bool Function(BuildContext, MCalDragWillAcceptDetails)?
  onDragWillAccept;
  final bool Function(BuildContext, MCalEventDroppedDetails)? onEventDropped;
  final MCalEventController controller;

  // Drag lifecycle callbacks (Task 21)
  final void Function(MCalCalendarEvent event, DateTime sourceDate)?
  onDragStartedCallback;
  final void Function(bool wasAccepted)? onDragEndedCallback;
  final VoidCallback? onDragCanceledCallback;

  /// The drag handler for coordinating drag state across week rows.
  final MCalDragHandler? dragHandler;

  /// Long-press delay before drag starts.
  final Duration dragLongPressDelay;

  /// Whether event resize handles should be shown on multi-day event tiles.
  final bool enableDragToResize;

  /// Optional custom builder for the visual part of resize handles.
  final Widget Function(BuildContext, MCalResizeHandleContext)?
  resizeHandleBuilder;

  /// Optional callback returning horizontal inset for a resize handle.
  final double Function(MCalEventTileContext, MCalResizeEdge)?
  resizeHandleInset;

  /// Called when a pointer goes down on a resize handle.
  /// The parent [MonthPageWidgetState] uses this to register the resize
  /// target and acquire a scroll hold before the gesture arena resolves.
  final void Function(
    MCalCalendarEvent event,
    MCalResizeEdge edge,
    int pointer,
  )?
  onResizeHandlePointerDown;

  /// The event ID currently highlighted during keyboard event cycling.
  final String? keyboardHighlightedEventId;

  /// The event ID currently selected for keyboard move/resize.
  final String? keyboardSelectedEventId;

  /// The date whose overflow indicator is keyboard-focused in Event Mode.
  final DateTime? keyboardOverflowFocusedDate;

  /// Shared map for layout-computed visible event counts per date.
  final Map<String, int>? layoutVisibleCounts;

  /// Optional custom builder for day region overlays.
  final Widget Function(BuildContext, MCalRegionContext, Widget)?
  dayRegionBuilder;

  const WeekRowWidget({
    super.key,
    required this.dates,
    required this.currentMonth,
    required this.events,
    required this.theme,
    this.focusedDate,
    this.autoFocusOnCellTap = true,
    this.onSetFocusedDate,
    this.dayCellBuilder,
    this.eventTileBuilder,
    this.dateLabelBuilder,
    this.dateFormat,
    this.cellInteractivityCallback,
    this.onCellTap,
    this.onCellLongPress,
    this.onCellSecondaryTap,
    this.onDateLabelTap,
    this.onDateLabelLongPress,
    this.onDateLabelDoubleTap,
    this.onDateLabelSecondaryTap,
    this.onEventTap,
    this.onEventLongPress,
    this.onEventSecondaryTap,
    this.onCellDoubleTap,
    this.onEventDoubleTap,
    this.onHoverCell,
    this.onHoverEvent,
    this.onHoverDateLabel,
    this.onHoverOverflow,
    required this.locale,
    this.maxVisibleEventsPerDay = 5,
    this.onOverflowTap,
    this.onOverflowLongPress,
    this.onOverflowDoubleTap,
    this.onOverflowSecondaryTap,
    this.showWeekNumbers = false,
    this.weekNumberBuilder,
    // Week layout customization
    this.weekLayoutBuilder,
    this.overflowIndicatorBuilder,
    this.weekRowIndex = 0,
    this.multiDayLayouts,
    // Drag-and-drop
    this.enableDragToMove = false,
    this.draggedTileBuilder,
    this.dragSourceTileBuilder,
    this.dropTargetTileBuilder,
    this.dropTargetCellBuilder,
    this.onDragWillAccept,
    this.onEventDropped,
    required this.controller,
    // Drag lifecycle callbacks (Task 21)
    this.onDragStartedCallback,
    this.onDragEndedCallback,
    this.onDragCanceledCallback,
    this.dragHandler,
    this.dragLongPressDelay = const Duration(milliseconds: 200),
    // Resize
    this.enableDragToResize = false,
    this.resizeHandleBuilder,
    this.resizeHandleInset,
    this.onResizeHandlePointerDown,
    // Keyboard selection state
    this.keyboardHighlightedEventId,
    this.keyboardSelectedEventId,
    this.keyboardOverflowFocusedDate,
    this.layoutVisibleCounts,
    // Day regions
    this.dayRegionBuilder,
  });

  @override
  State<WeekRowWidget> createState() => WeekRowWidgetState();
}

class WeekRowWidgetState extends State<WeekRowWidget> {
  @override
  Widget build(BuildContext context) {
    // Determine layout direction for RTL support
    final isLayoutRTL = MCalLayoutDirectionality.of(context);

    // Calculate week number for week number column using the controller's
    // firstDayOfWeek so that Month View and Day View always agree.
    final firstDayOfWeekDate = widget.dates.first;
    final weekNumber = getWeekNumber(
      firstDayOfWeekDate,
      widget.controller.resolvedFirstDayOfWeek,
    );

    // Build week number cell if needed
    Widget? weekNumberCell;
    if (widget.showWeekNumbers) {
      weekNumberCell = WeekNumberCell(
        weekNumber: weekNumber,
        firstDayOfWeek: firstDayOfWeekDate,
        theme: widget.theme,
        weekNumberBuilder: widget.weekNumberBuilder,
      );
    }

    // Build the 2-layer Stack architecture
    // Note: Layer 3 (drop targets) has been moved to MonthPageWidget
    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate column widths (excluding week number column)
          final weekNumberWidth = widget.showWeekNumbers
              ? WeekNumberCell.columnWidth
              : 0.0;
          final availableWidth = constraints.maxWidth - weekNumberWidth;
          final dayWidth = availableWidth / 7;
          final columnWidths = List.filled(7, dayWidth);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Week number column (positioned outside the Stack)
              if (weekNumberCell != null && !isLayoutRTL) weekNumberCell,

              // Main calendar content with 2-layer Stack
              Expanded(
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // Layer 1: Grid cells (just backgrounds/borders, NO events)
                    _buildLayer1Grid(context, isLayoutRTL),

                    // Layer 2: Events, date labels, overflow indicators
                    Positioned.fill(
                      child: _buildLayer2Events(
                        context,
                        columnWidths,
                        constraints.maxHeight,
                      ),
                    ),
                  ],
                ),
              ),

              // Week number column for RTL
              if (weekNumberCell != null && isLayoutRTL) weekNumberCell,
            ],
          );
        },
      ),
    );
  }

  /// Layer 1: Grid cells with just backgrounds/borders, NO events.
  Widget _buildLayer1Grid(BuildContext context, bool isLayoutRTL) {
    final dayCells = widget.dates.asMap().entries.map((entry) {
      final date = entry.value;
      final isCurrentMonth =
          date.year == widget.currentMonth.year &&
          date.month == widget.currentMonth.month;
      final isTodayDate = isToday(date);

      // Get events for this date (for callbacks, not rendering)
      final allDayEvents = _getEventsForDate(date);

      // Check if this date is focused
      final isFocused =
          widget.focusedDate != null &&
          date.year == widget.focusedDate!.year &&
          date.month == widget.focusedDate!.month &&
          date.day == widget.focusedDate!.day;

      return Expanded(
        child: DayCellWidget(
          date: date,
          displayMonth: widget.currentMonth,
          isCurrentMonth: isCurrentMonth,
          isToday: isTodayDate,
          isSelectable: true,
          isFocused: isFocused,
          autoFocusOnCellTap: widget.autoFocusOnCellTap,
          onSetFocusedDate: widget.onSetFocusedDate,
          events: allDayEvents,
          theme: widget.theme,
          dayCellBuilder: widget.dayCellBuilder,
          dateLabelBuilder: widget.dateLabelBuilder,
          showDateLabel: false,
          dateFormat: widget.dateFormat,
          cellInteractivityCallback: widget.cellInteractivityCallback,
          onCellTap: widget.onCellTap,
          onCellLongPress: widget.onCellLongPress,
          onCellSecondaryTap: widget.onCellSecondaryTap,
          onDateLabelTap: widget.onDateLabelTap,
          onDateLabelLongPress: widget.onDateLabelLongPress,
          onDateLabelDoubleTap: widget.onDateLabelDoubleTap,
          onDateLabelSecondaryTap: widget.onDateLabelSecondaryTap,
          onCellDoubleTap: widget.onCellDoubleTap,
          onHoverCell: widget.onHoverCell,
          onHoverDateLabel: widget.onHoverDateLabel,
          locale: widget.locale,
          controller: widget.controller,
          dayRegionBuilder: widget.dayRegionBuilder,
        ),
      );
    }).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: dayCells,
    );
  }

  /// Layer 2: Events, date labels, and overflow indicators.
  Widget _buildLayer2Events(
    BuildContext context,
    List<double> columnWidths,
    double rowHeight,
  ) {
    // Create layout config from theme, passing maxVisibleEventsPerDay
    final config = MCalMonthWeekLayoutConfig.fromTheme(
      widget.theme,
      maxVisibleEventsPerDay: widget.maxVisibleEventsPerDay,
    );

    // Calculate event segments for this week using the dates' first day to determine week start
    final firstDayOfWeekValue = widget.dates.first.weekday == DateTime.sunday
        ? 0
        : widget.dates.first.weekday;
    final allSegments = MCalMultiDayRenderer.calculateAllEventSegments(
      events: widget.events,
      monthStart: widget.currentMonth,
      firstDayOfWeek: firstDayOfWeekValue,
    );

    // Get segments for this specific week row
    final weekSegments = widget.weekRowIndex < allSegments.length
        ? allSegments[widget.weekRowIndex]
        : <MCalMonthEventSegment>[];

    // Get day width for dragged tile sizing
    final dayWidth = columnWidths.isNotEmpty ? columnWidths[0] : 0.0;

    // Create wrapped builders using MCalBuilderWrapper
    final wrappedEventTileBuilder = MCalBuilderWrapper.wrapEventTileBuilder(
      developerBuilder: widget.eventTileBuilder,
      defaultBuilder: _buildDefaultEventTile,
      onEventTap: widget.onEventTap,
      onEventLongPress: widget.onEventLongPress,
      onEventDoubleTap: widget.onEventDoubleTap,
      onEventSecondaryTap: widget.onEventSecondaryTap,
      onHoverEvent: widget.onHoverEvent,
      controller: widget.controller,
      enableDragToMove: widget.enableDragToMove,
      dragHandler: null,
      // Drag-related parameters
      draggedTileBuilder: widget.draggedTileBuilder,
      dragSourceTileBuilder: widget.dragSourceTileBuilder,
      onDragStartedCallback: widget.onDragStartedCallback,
      onDragEndedCallback: widget.onDragEndedCallback,
      onDragCanceledCallback: widget.onDragCanceledCallback,
      dragLongPressDelay: widget.dragLongPressDelay,
      // Tile sizing for dragged feedback (styling comes from theme via defaultBuilder)
      dayWidth: dayWidth,
      tileHeight: widget.theme.monthTheme?.eventTileHeight,
      horizontalSpacing: widget.theme.eventTileHorizontalSpacing ?? 2.0,
    );

    final wrappedDateLabelBuilder = MCalBuilderWrapper.wrapDateLabelBuilder(
      developerBuilder: widget.dateLabelBuilder,
      defaultBuilder: _buildDefaultDateLabel,
      onDateLabelTap: widget.onDateLabelTap,
      onDateLabelLongPress: widget.onDateLabelLongPress,
      onDateLabelDoubleTap: widget.onDateLabelDoubleTap,
      onDateLabelSecondaryTap: widget.onDateLabelSecondaryTap,
      onHoverDateLabel: widget.onHoverDateLabel,
    );

    final baseOverflowIndicatorBuilder =
        MCalBuilderWrapper.wrapOverflowIndicatorBuilder(
          developerBuilder: widget.overflowIndicatorBuilder,
          defaultBuilder: _buildDefaultOverflowIndicator,
          onOverflowTap: widget.onOverflowTap,
          onOverflowLongPress: widget.onOverflowLongPress,
          onOverflowDoubleTap: widget.onOverflowDoubleTap,
          onOverflowSecondaryTap: widget.onOverflowSecondaryTap,
        );

    // Wrap overflow builder to add a keyboard-focus highlight when the
    // overflow indicator for this cell is focused via keyboard in Event Mode.
    final overflowFocusedDate = widget.keyboardOverflowFocusedDate;
    final Widget Function(BuildContext, MCalMonthOverflowIndicatorContext)
    wrappedOverflowIndicatorBuilder;
    if (overflowFocusedDate != null) {
      final focusColor = widget.theme.monthTheme?.focusedDateBackgroundColor;
      wrappedOverflowIndicatorBuilder =
          (BuildContext ctx, MCalMonthOverflowIndicatorContext overflowCtx) {
            final child = baseOverflowIndicatorBuilder(ctx, overflowCtx);
            if (focusColor != null &&
                overflowCtx.date.year == overflowFocusedDate.year &&
                overflowCtx.date.month == overflowFocusedDate.month &&
                overflowCtx.date.day == overflowFocusedDate.day) {
              return DecoratedBox(
                decoration: BoxDecoration(color: focusColor),
                child: child,
              );
            }
            return child;
          };
    } else {
      wrappedOverflowIndicatorBuilder = baseOverflowIndicatorBuilder;
    }

    // Optionally wrap event tile builder with resize handles for all events
    final MCalEventTileBuilder finalEventTileBuilder;
    if (widget.enableDragToResize) {
      finalEventTileBuilder = (BuildContext ctx, MCalEventTileContext tileCtx) {
        final segment = tileCtx.segment;

        // Skip if no segment info (shouldn't happen in normal flow)
        if (segment == null) return wrappedEventTileBuilder(ctx, tileCtx);

        // Pass handle flags so the tile can add inner content padding (rectangle
        // stays full size; text shifts inward).
        final contextWithHandles = MCalEventTileContext(
          event: tileCtx.event,
          displayDate: tileCtx.displayDate,
          isAllDay: tileCtx.isAllDay,
          segment: tileCtx.segment,
          width: tileCtx.width,
          height: tileCtx.height,
          isDropTargetPreview: tileCtx.isDropTargetPreview,
          dropValid: tileCtx.dropValid,
          proposedStartDate: tileCtx.proposedStartDate,
          proposedEndDate: tileCtx.proposedEndDate,
          isRecurring: tileCtx.isRecurring,
          seriesId: tileCtx.seriesId,
          recurrenceRule: tileCtx.recurrenceRule,
          masterEvent: tileCtx.masterEvent,
          isException: tileCtx.isException,
          hasLeadingResizeHandle: segment.isFirstSegment,
          hasTrailingResizeHandle: segment.isLastSegment,
          keyboardState: tileCtx.keyboardState,
          regions: tileCtx.regions,
        );
        final tileWithPadding = wrappedEventTileBuilder(
          ctx,
          contextWithHandles,
        );

        final children = <Widget>[Positioned.fill(child: tileWithPadding)];
        final handleColor = () {
          final t = widget.theme;
          final d = MCalThemeData.fromTheme(Theme.of(ctx));
          return t.dayTheme?.resizeHandleColor ??
              d.dayTheme!.resizeHandleColor!;
        }();
        if (segment.isFirstSegment) {
          final startInset =
              widget.resizeHandleInset?.call(
                contextWithHandles,
                MCalResizeEdge.start,
              ) ??
              0.0;
          children.add(
            MonthResizeHandle(
              edge: MCalResizeEdge.start,
              event: tileCtx.event,
              visualBuilder: widget.resizeHandleBuilder,
              resizeHandleColor: handleColor,
              inset: startInset,
              onPointerDown: (event, edge, pointer) =>
                  widget.onResizeHandlePointerDown?.call(event, edge, pointer),
            ),
          );
        }
        if (segment.isLastSegment) {
          final endInset =
              widget.resizeHandleInset?.call(
                contextWithHandles,
                MCalResizeEdge.end,
              ) ??
              0.0;
          children.add(
            MonthResizeHandle(
              edge: MCalResizeEdge.end,
              event: tileCtx.event,
              visualBuilder: widget.resizeHandleBuilder,
              resizeHandleColor: handleColor,
              inset: endInset,
              onPointerDown: (event, edge, pointer) =>
                  widget.onResizeHandlePointerDown?.call(event, edge, pointer),
            ),
          );
        }

        // Only wrap in Stack if we actually added handles
        if (children.length > 1) {
          return Stack(clipBehavior: Clip.none, children: children);
        }
        return tileWithPadding;
      };
    } else {
      finalEventTileBuilder = wrappedEventTileBuilder;
    }

    // Wrap the final tile builder to inject keyboard selection state.
    // This runs after resize-handle wrapping so the context enrichment
    // reaches both the default and custom builders.
    final highlightedId = widget.keyboardHighlightedEventId;
    final selectedId = widget.keyboardSelectedEventId;
    final MCalEventTileBuilder keyboardAwareBuilder;
    if (highlightedId != null || selectedId != null) {
      keyboardAwareBuilder = (BuildContext ctx, MCalEventTileContext tileCtx) {
        final eventId = tileCtx.event.id;
        MCalEventKeyboardState state = MCalEventKeyboardState.none;
        if (eventId == selectedId) {
          state = MCalEventKeyboardState.selected;
        } else if (eventId == highlightedId) {
          state = MCalEventKeyboardState.highlighted;
        }
        if (state != MCalEventKeyboardState.none) {
          final enriched = MCalEventTileContext(
            event: tileCtx.event,
            displayDate: tileCtx.displayDate,
            isAllDay: tileCtx.isAllDay,
            segment: tileCtx.segment,
            width: tileCtx.width,
            height: tileCtx.height,
            isDropTargetPreview: tileCtx.isDropTargetPreview,
            dropValid: tileCtx.dropValid,
            proposedStartDate: tileCtx.proposedStartDate,
            proposedEndDate: tileCtx.proposedEndDate,
            isRecurring: tileCtx.isRecurring,
            seriesId: tileCtx.seriesId,
            recurrenceRule: tileCtx.recurrenceRule,
            masterEvent: tileCtx.masterEvent,
            isException: tileCtx.isException,
            hasLeadingResizeHandle: tileCtx.hasLeadingResizeHandle,
            hasTrailingResizeHandle: tileCtx.hasTrailingResizeHandle,
            keyboardState: state,
            regions: tileCtx.regions,
          );
          return finalEventTileBuilder(ctx, enriched);
        }
        return finalEventTileBuilder(ctx, tileCtx);
      };
    } else {
      keyboardAwareBuilder = finalEventTileBuilder;
    }

    // Create the week layout context
    final layoutContext = MCalMonthWeekLayoutContext(
      segments: weekSegments,
      dates: widget.dates,
      columnWidths: columnWidths,
      rowHeight: rowHeight,
      weekRowIndex: widget.weekRowIndex,
      currentMonth: widget.currentMonth,
      config: config,
      eventTileBuilder: keyboardAwareBuilder,
      dateLabelBuilder: wrappedDateLabelBuilder,
      overflowIndicatorBuilder: wrappedOverflowIndicatorBuilder,
      layoutVisibleCounts: widget.layoutVisibleCounts,
    );

    // Use custom weekLayoutBuilder if provided, otherwise use default
    if (widget.weekLayoutBuilder != null) {
      return widget.weekLayoutBuilder!(context, layoutContext);
    }

    // Use default week layout builder
    return MCalMonthDefaultWeekLayoutBuilder.build(context, layoutContext);
  }

  /// Builds the default event tile widget.
  ///
  /// Renders a coloured rectangle with the event title, respecting theme
  /// settings for colour, border, corner radius, and text style.
  ///
  /// Visual adjustments:
  /// - Extra horizontal padding when resize handles are present
  ///   ([MCalEventTileContext.hasLeadingResizeHandle] /
  ///   [MCalEventTileContext.hasTrailingResizeHandle]).
  /// - High-contrast border indicator when the tile is involved in
  ///   keyboard navigation ([MCalEventTileContext.keyboardState]):
  ///   * [MCalEventKeyboardState.highlighted]: 1.5px contrasting border.
  ///   * [MCalEventKeyboardState.selected]: 2px contrasting border with a
  ///     subtle background tint shift.
  Widget _buildDefaultEventTile(
    BuildContext context,
    MCalEventTileContext tileContext,
  ) {
    final event = tileContext.event;
    final segment = tileContext.segment;
    final theme = widget.theme;

    // Determine corner radius based on segment position
    final cornerRadius = theme.eventTileCornerRadius ?? 4.0;
    final leftRadius = segment?.isFirstSegment ?? true ? cornerRadius : 0.0;
    final rightRadius = segment?.isLastSegment ?? true ? cornerRadius : 0.0;

    final defaults = MCalThemeData.fromTheme(Theme.of(context));
    // Determine tile color - respect ignoreEventColors theme setting
    final tileColor = resolveEventTileColor(
      themeColor: theme.eventTileBackgroundColor,
      allDayThemeColor: theme.allDayEventBackgroundColor,
      eventColor: event.color,
      ignoreEventColors: theme.ignoreEventColors,
      defaultColor: defaults.eventTileBackgroundColor!,
    );

    // Determine border - only add if both color and width are specified
    // For continuation segments, omit border on the continuation edge
    final borderWidth = theme.monthTheme?.eventTileBorderWidth ?? 0.0;
    final hasBorder =
        borderWidth > 0 && theme.monthTheme?.eventTileBorderColor != null;
    final isFirstSegment = segment?.isFirstSegment ?? true;
    final isLastSegment = segment?.isLastSegment ?? true;

    // Build border with individual sides based on segment position
    Border? tileBorder;
    if (hasBorder) {
      final borderColor = theme.monthTheme!.eventTileBorderColor!;
      final topBorder = BorderSide(color: borderColor, width: borderWidth);
      final bottomBorder = BorderSide(color: borderColor, width: borderWidth);
      // Only add left border if this is the first segment (event starts here)
      final leftBorder = isFirstSegment
          ? BorderSide(color: borderColor, width: borderWidth)
          : BorderSide.none;
      // Only add right border if this is the last segment (event ends here)
      final rightBorder = isLastSegment
          ? BorderSide(color: borderColor, width: borderWidth)
          : BorderSide.none;
      tileBorder = Border(
        top: topBorder,
        bottom: bottomBorder,
        left: leftBorder,
        right: rightBorder,
      );
    }

    // Extra horizontal padding when resize handles are shown so text does not
    // sit under the handles (rectangle stays full size; content shifts inward).
    final tilePadding = theme.monthTheme?.eventTilePadding ??
        defaults.monthTheme!.eventTilePadding!;
    const double handleInset = 4.0;
    final startPadding =
        tilePadding.left + (tileContext.hasLeadingResizeHandle ? handleInset : 0);
    final endPadding =
        tilePadding.right + (tileContext.hasTrailingResizeHandle ? handleInset : 0);
    final contentPadding = EdgeInsetsDirectional.only(
      top: tilePadding.top,
      bottom: tilePadding.bottom,
      start: startPadding,
      end: endPadding,
    );

    // Keyboard selection indicator: override the border to show selection state.
    // - highlighted (cycling): 1.5px border in a contrasting colour
    // - selected (move/resize): 2px border in a contrasting colour with a
    //   subtle background tint shift
    final keyboardState = tileContext.keyboardState;
    BoxDecoration decoration;
    if (keyboardState != MCalEventKeyboardState.none) {
      // Use a high-contrast border: white or black depending on tile luminance
      final lightContrast =
          theme.eventTileLightContrastColor ?? defaults.eventTileLightContrastColor!;
      final darkContrast =
          theme.eventTileDarkContrastColor ?? defaults.eventTileDarkContrastColor!;
      final indicatorColor = resolveContrastColor(
        backgroundColor: tileColor,
        lightContrastColor: lightContrast,
        darkContrastColor: darkContrast,
      );
      final indicatorWidth = keyboardState == MCalEventKeyboardState.selected
          ? 2.0
          : 1.5;

      final kbBorderSide = BorderSide(
        color: indicatorColor,
        width: indicatorWidth,
      );
      final kbLeftBorder = isFirstSegment ? kbBorderSide : BorderSide.none;
      final kbRightBorder = isLastSegment ? kbBorderSide : BorderSide.none;
      final kbBorder = Border(
        top: kbBorderSide,
        bottom: kbBorderSide,
        left: kbLeftBorder,
        right: kbRightBorder,
      );

      // For selected state, slightly shift the background to reinforce
      final effectiveColor = keyboardState == MCalEventKeyboardState.selected
          ? Color.lerp(tileColor, indicatorColor, 0.10)!
          : tileColor;

      decoration = BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(leftRadius),
          right: Radius.circular(rightRadius),
        ),
        border: kbBorder,
      );
    } else {
      decoration = BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(leftRadius),
          right: Radius.circular(rightRadius),
        ),
        border: tileBorder,
      );
    }

    return Container(
      decoration: decoration,
      padding: contentPadding,
      alignment: Alignment.centerLeft,
      child: Text(
        event.title,
        style:
            theme.eventTileTextStyle ??
            defaults.eventTileTextStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Builds the default date label widget.
  Widget _buildDefaultDateLabel(
    BuildContext context,
    MCalDateLabelContext labelContext,
  ) {
    final theme = widget.theme;
    final isCurrentMonth = labelContext.isCurrentMonth;
    final isToday = labelContext.isToday;

    final dateLabelDefaults = MCalThemeData.fromTheme(Theme.of(context));
    final monthDateDefaults = dateLabelDefaults.monthTheme!;
    // Text style - today uses bold but keeps readable color
    final textStyle = isToday
        ? (theme.monthTheme?.todayTextStyle ??
              monthDateDefaults.todayTextStyle)
        : (theme.monthTheme?.cellTextStyle ??
              (isCurrentMonth
                  ? monthDateDefaults.cellTextStyle
                  : monthDateDefaults.leadingDatesTextStyle));

    final dateText = Text(
      labelContext.defaultFormattedString,
      style: textStyle,
      textAlign: TextAlign.center,
    );

    // Get alignment from the DateLabelPosition
    final alignment = labelContext.horizontalAlignment;

    // Use a fixed-size container for ALL dates to ensure uniform spacing.
    // For today, the circle is visible; for other days, it's transparent.
    // This prevents alignment shifts when using left/right aligned labels.
    final circleContainer = Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // Only show the background color for today
        color: isToday
            ? (theme.monthTheme?.todayBackgroundColor ??
                monthDateDefaults.todayBackgroundColor!)
            : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: dateText,
    );

    // Align the container according to DateLabelPosition
    return SizedBox(
      height: 24,
      child: Align(alignment: alignment, child: circleContainer),
    );
  }

  /// Builds the default overflow indicator widget.
  Widget _buildDefaultOverflowIndicator(
    BuildContext context,
    MCalMonthOverflowIndicatorContext overflowContext,
  ) {
    final theme = widget.theme;
    final overflowDefaults = MCalThemeData.fromTheme(Theme.of(context));
    return Center(
      child: Text(
        '+${overflowContext.hiddenEventCount} more',
        style: theme.monthTheme?.overflowIndicatorTextStyle ??
            overflowDefaults.monthTheme!.overflowIndicatorTextStyle,
      ),
    );
  }

  // isToday() is in date_utils.dart

  List<MCalCalendarEvent> _getEventsForDate(DateTime date) {
    final matchingEvents = widget.events.where((event) {
      final eventStart = dateOnly(event.start);
      final eventEnd = dateOnly(event.end);
      final checkDate = dateOnly(date);
      return (checkDate.isAtSameMomentAs(eventStart) ||
          checkDate.isAtSameMomentAs(eventEnd) ||
          (checkDate.isAfter(eventStart) && checkDate.isBefore(eventEnd)));
    }).toList();

    // Sort events using the standard multi-day comparator
    // Order: all-day multi → timed multi → all-day single → timed single
    matchingEvents.sort(MCalMultiDayRenderer.multiDayEventComparator);

    return matchingEvents;
  }
}
