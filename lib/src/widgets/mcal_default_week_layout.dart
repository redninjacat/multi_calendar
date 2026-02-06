import 'package:flutter/material.dart';
import '../models/mcal_calendar_event.dart';
import 'mcal_month_view_contexts.dart';
import 'mcal_week_layout_contexts.dart';

/// Assignment of an event segment to a row index.
class MCalSegmentRowAssignment {
  final MCalEventSegment segment;
  final int row;

  const MCalSegmentRowAssignment({required this.segment, required this.row});
}

/// Overflow information for a single day column.
class MCalOverflowInfo {
  final int hiddenCount;
  final List<MCalCalendarEvent> hiddenEvents;
  final List<MCalCalendarEvent> visibleEvents;

  const MCalOverflowInfo({
    required this.hiddenCount,
    required this.hiddenEvents,
    required this.visibleEvents,
  });
}

/// Default week layout builder implementation.
///
/// Uses a greedy first-fit algorithm to assign events to rows:
/// 1. Sort segments by span length (longer first) then by start day
/// 2. For each segment, find the first row where it fits without overlap
/// 3. Multi-day events maintain visual continuity across week boundaries
class MCalDefaultWeekLayoutBuilder {
  MCalDefaultWeekLayoutBuilder._();

  /// Assigns row indices to segments using greedy first-fit algorithm.
  ///
  /// Segments should be pre-sorted (longer spans first, then by start day).
  static List<MCalSegmentRowAssignment> assignRows(
    List<MCalEventSegment> segments,
  ) {
    final assignments = <MCalSegmentRowAssignment>[];
    // Track which columns are occupied at each row
    // rowOccupancy[row] = Set of occupied column indices
    final rowOccupancy = <int, Set<int>>{};

    for (final segment in segments) {
      int assignedRow = 0;

      // Find first row where all columns in segment's range are free
      while (true) {
        final occupiedCols = rowOccupancy[assignedRow] ?? <int>{};
        bool rowIsFree = true;

        for (
          int col = segment.startDayInWeek;
          col <= segment.endDayInWeek;
          col++
        ) {
          if (occupiedCols.contains(col)) {
            rowIsFree = false;
            break;
          }
        }

        if (rowIsFree) break;
        assignedRow++;
      }

      // Mark columns as occupied in this row
      rowOccupancy[assignedRow] ??= <int>{};
      for (
        int col = segment.startDayInWeek;
        col <= segment.endDayInWeek;
        col++
      ) {
        rowOccupancy[assignedRow]!.add(col);
      }

      assignments.add(
        MCalSegmentRowAssignment(segment: segment, row: assignedRow),
      );
    }

    return assignments;
  }

  /// Calculates overflow info per day column.
  ///
  /// Correctly counts hidden EVENTS per day, not hidden rows.
  static Map<int, MCalOverflowInfo> calculateOverflow({
    required List<MCalSegmentRowAssignment> assignments,
    required int maxVisibleRows,
  }) {
    final result = <int, MCalOverflowInfo>{};

    // Group by day column
    final visibleByDay = <int, List<MCalCalendarEvent>>{};
    final hiddenByDay = <int, List<MCalCalendarEvent>>{};

    for (int day = 0; day < 7; day++) {
      visibleByDay[day] = [];
      hiddenByDay[day] = [];
    }

    for (final assignment in assignments) {
      final segment = assignment.segment;
      final isVisible = assignment.row < maxVisibleRows;

      // Add event to each day it spans
      for (
        int day = segment.startDayInWeek;
        day <= segment.endDayInWeek;
        day++
      ) {
        if (isVisible) {
          visibleByDay[day]!.add(segment.event);
        } else {
          hiddenByDay[day]!.add(segment.event);
        }
      }
    }

    // Build overflow info for days with hidden events
    for (int day = 0; day < 7; day++) {
      final hidden = hiddenByDay[day]!;
      if (hidden.isNotEmpty) {
        result[day] = MCalOverflowInfo(
          hiddenCount: hidden.length,
          hiddenEvents: hidden,
          visibleEvents: visibleByDay[day]!,
        );
      }
    }

    return result;
  }

  /// Builds the default week layout widget.
  static Widget build(
    BuildContext context,
    MCalWeekLayoutContext layoutContext,
  ) {
    final config = layoutContext.config;
    final segments = layoutContext.segments;

    // Sort segments: longer spans first, then by start day
    final sortedSegments = List<MCalEventSegment>.from(segments)
      ..sort((a, b) {
        final spanCompare = b.spanDays.compareTo(a.spanDays);
        if (spanCompare != 0) return spanCompare;
        return a.startDayInWeek.compareTo(b.startDayInWeek);
      });

    // Assign rows
    final assignments = assignRows(sortedSegments);

    return LayoutBuilder(
      builder: (context, constraints) {
        final dayWidth = constraints.maxWidth / 7;
        final rowHeight = constraints.maxHeight;

        // Calculate layout metrics
        final bool dateLabelAtTop =
            config.dateLabelPosition == DateLabelPosition.topLeft ||
            config.dateLabelPosition == DateLabelPosition.topCenter ||
            config.dateLabelPosition == DateLabelPosition.topRight;

        // Equal spacing above and below the date label (2px each = 4px total)
        const dateLabelPadding = 2.0;
        final dateLabelReservedSpace =
            config.dateLabelHeight + (dateLabelPadding * 2);
        final eventsTopOffset = dateLabelAtTop
            ? dateLabelReservedSpace
            : config.tileVerticalSpacing;

        // Calculate available space for events
        final tileSlotHeight = config.tileHeight + config.tileVerticalSpacing;
        const baseMargin = 2.0;

        // First, calculate how many rows could fit WITHOUT the overflow indicator
        final availableWithoutOverflow =
            rowHeight - dateLabelReservedSpace - baseMargin;
        final maxRowsWithoutOverflow =
            (availableWithoutOverflow / tileSlotHeight).floor().clamp(1, 100);

        // Find the maximum row used by any assignment
        final maxUsedRow = assignments.isEmpty
            ? 0
            : assignments.map((a) => a.row).reduce((a, b) => a > b ? a : b) + 1;

        // Apply maxVisibleEventsPerDay limit
        final configLimit = config.maxVisibleEventsPerDay > 0
            ? config.maxVisibleEventsPerDay
            : maxRowsWithoutOverflow;

        // Check if there would be overflow WITHOUT reserving overflow indicator space
        final wouldOverflowByConfig = maxUsedRow > configLimit;
        final wouldOverflowByHeight = maxUsedRow > maxRowsWithoutOverflow;
        final hasOverflow = wouldOverflowByConfig || wouldOverflowByHeight;

        // Only reserve space for overflow indicator if there actually IS overflow
        final int maxVisibleRows;
        if (hasOverflow) {
          // Recalculate with overflow indicator space reserved
          final availableWithOverflow =
              rowHeight -
              dateLabelReservedSpace -
              config.overflowIndicatorHeight -
              baseMargin;
          final maxRowsWithOverflow = (availableWithOverflow / tileSlotHeight)
              .floor()
              .clamp(1, 100);

          // Use the minimum of height-based and config limits
          maxVisibleRows = maxRowsWithOverflow < configLimit
              ? maxRowsWithOverflow
              : configLimit;
        } else {
          // No overflow - use full available space
          maxVisibleRows = maxRowsWithoutOverflow < configLimit
              ? maxRowsWithoutOverflow
              : configLimit;
        }

        // Separate visible and hidden
        final visibleAssignments = assignments
            .where((a) => a.row < maxVisibleRows)
            .toList();
        final overflowMap = calculateOverflow(
          assignments: assignments,
          maxVisibleRows: maxVisibleRows,
        );

        // Build widgets
        final children = <Widget>[];

        // Date labels
        for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
          final date = layoutContext.dates[dayIndex];
          final labelContext = MCalDateLabelContext(
            date: date,
            isCurrentMonth: date.month == layoutContext.currentMonth.month,
            isToday: _isToday(date),
            defaultFormattedString: '${date.day}',
            locale: Localizations.localeOf(context),
            position: config.dateLabelPosition,
          );

          final labelWidget = layoutContext.dateLabelBuilder(
            context,
            labelContext,
          );

          children.add(
            Positioned(
              left: dayWidth * dayIndex + 2,
              top: dateLabelAtTop
                  ? dateLabelPadding
                  : rowHeight - config.dateLabelHeight - dateLabelPadding,
              width: dayWidth - 4,
              height: config.dateLabelHeight,
              child: labelWidget,
            ),
          );
        }

        // Event tiles
        for (final assignment in visibleAssignments) {
          final segment = assignment.segment;
          final row = assignment.row;

          final leftSpacing = segment.isFirstSegment
              ? config.tileHorizontalSpacing
              : 0.0;
          final rightSpacing = segment.isLastSegment
              ? config.tileHorizontalSpacing
              : 0.0;

          final left = dayWidth * segment.startDayInWeek + leftSpacing;
          final top = eventsTopOffset + (row * tileSlotHeight);
          final tileWidth =
              dayWidth * segment.spanDays - leftSpacing - rightSpacing;

          // DEBUG: Log layout builder dayWidth for comparison
          debugPrint(
            'LAYOUT DEBUG: "${segment.event.title}" dayWidth=$dayWidth, '
            'tileWidth=$tileWidth, spanDays=${segment.spanDays}, '
            'leftSpacing=$leftSpacing, rightSpacing=$rightSpacing',
          );

          final tileContext = MCalEventTileContext(
            event: segment.event,
            displayDate: layoutContext.dates[segment.startDayInWeek],
            isAllDay: segment.event.isAllDay,
            segment: segment,
            width: tileWidth,
            height: config.tileHeight,
          );

          children.add(
            Positioned(
              left: left,
              top: top,
              width: tileWidth,
              height: config.tileHeight,
              child: layoutContext.eventTileBuilder(context, tileContext),
            ),
          );
        }

        // Overflow indicators
        for (final entry in overflowMap.entries) {
          final dayIndex = entry.key;
          final info = entry.value;

          final overflowContext = MCalOverflowIndicatorContext(
            date: layoutContext.dates[dayIndex],
            hiddenEventCount: info.hiddenCount,
            hiddenEvents: info.hiddenEvents,
            visibleEvents: info.visibleEvents,
            width: dayWidth - 8,
            height: config.overflowIndicatorHeight,
          );

          final top = eventsTopOffset + (maxVisibleRows * tileSlotHeight);

          children.add(
            Positioned(
              left: dayWidth * dayIndex + 4,
              top: top,
              width: dayWidth - 8,
              height: config.overflowIndicatorHeight,
              child: layoutContext.overflowIndicatorBuilder(
                context,
                overflowContext,
              ),
            ),
          );
        }

        return Stack(clipBehavior: Clip.hardEdge, children: children);
      },
    );
  }

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
