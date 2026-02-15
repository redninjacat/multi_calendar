import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../utils/date_formatters.dart';
import '../../../utils/event_colors.dart';
import '../../../widgets/day_events_bottom_sheet.dart';
import '../../../widgets/style_description.dart';

/// Modern style - rounded, colorful, contemporary design.
class ModernMonthStyle extends StatelessWidget {
  const ModernMonthStyle({
    super.key,
    required this.eventController,
    required this.locale,
    required this.isDarkMode,
    required this.selectedDate,
    required this.onDateSelected,
    required this.description,
  });

  final MCalEventController eventController;
  final Locale locale;
  final bool isDarkMode;
  final DateTime? selectedDate;
  final void Function(DateTime) onDateSelected;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        StyleDescription(description: description),
        Expanded(
          child: MCalTheme(
            data: MCalThemeData(
              cellBackgroundColor: colorScheme.surface,
              cellBorderColor: Colors.transparent,
              todayBackgroundColor: colorScheme.primary,
              todayTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              weekdayHeaderBackgroundColor: colorScheme.surfaceContainerHighest,
              weekdayHeaderTextStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            child: MCalMonthView(
              controller: eventController,
              showNavigator: true,
              enableSwipeNavigation: true,
              enableDragToMove: false,
              enableDragToResize: false,
              locale: locale,
              // Custom week layout builder that renders dots for events
              weekLayoutBuilder: (context, ctx) {
                return _buildDotsWeekLayout(context, ctx, colorScheme);
              },
              dayCellBuilder: (context, ctx, defaultCell) {
                return _buildDayCell(context, ctx, colorScheme);
              },
              navigatorBuilder: (context, ctx, defaultNavigator) {
                return _buildNavigator(context, ctx, colorScheme);
              },
              onCellTap: (context, details) {
                onDateSelected(details.date);
                showDayEventsBottomSheet(
                  context,
                  details.date,
                  details.events,
                  locale,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Custom week layout builder that renders colored dots for events.
  ///
  /// This replaces the default event tile layout with a dots-based visualization.
  /// Each day with events shows up to 3 colored dots plus a '+' indicator for more.
  Widget _buildDotsWeekLayout(
    BuildContext context,
    MCalMonthWeekLayoutContext ctx,
    ColorScheme colorScheme,
  ) {
    // Collect events for each day in the week
    final eventsPerDay = <int, List<MCalCalendarEvent>>{};
    for (final segment in ctx.segments) {
      // Add event to each day it spans
      for (
        int day = segment.startDayInWeek;
        day <= segment.endDayInWeek;
        day++
      ) {
        eventsPerDay.putIfAbsent(day, () => []);
        // Only add if not already present (avoid duplicates for multi-day events)
        if (!eventsPerDay[day]!.any((e) => e.id == segment.event.id)) {
          eventsPerDay[day]!.add(segment.event);
        }
      }
    }

    // Build dots for each day that has events
    final dotWidgets = <Widget>[];
    double leftOffset = 0;

    for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
      final columnWidth = ctx.columnWidths[dayIndex];
      final dayEvents = eventsPerDay[dayIndex] ?? [];

      if (dayEvents.isNotEmpty) {
        // Create dots row for this day
        final dots = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...dayEvents.take(3).map((event) {
              final color = event.color ?? getEventColor(event.id);
              return Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              );
            }),
            if (dayEvents.length > 3)
              Text(
                '+',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        );

        // Position dots in the center of the cell, below the date
        dotWidgets.add(
          Positioned(
            left: leftOffset,
            top:
                ctx.config.dateLabelHeight + 8, // Below date label with padding
            width: columnWidth,
            child: Center(child: dots),
          ),
        );
      }

      leftOffset += columnWidth;
    }

    // Return empty container if no events
    if (dotWidgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(children: dotWidgets);
  }

  Widget _buildDayCell(
    BuildContext context,
    MCalDayCellContext ctx,
    ColorScheme colorScheme,
  ) {
    final isSelected =
        selectedDate != null &&
        ctx.date.year == selectedDate!.year &&
        ctx.date.month == selectedDate!.month &&
        ctx.date.day == selectedDate!.day;

    // Day cell only renders background and date number
    // Dots are rendered by the weekLayoutBuilder in Layer 2
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primaryContainer
            : ctx.isToday
            ? colorScheme.primary
            : ctx.isCurrentMonth
            ? colorScheme.surface
            : colorScheme.surfaceContainerHighest.withAlpha(100),
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: colorScheme.primary, width: 2)
            : null,
        boxShadow: ctx.isToday
            ? [
                BoxShadow(
                  color: colorScheme.primary.withAlpha(60),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${ctx.date.day}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: ctx.isToday ? FontWeight.bold : FontWeight.w500,
              color: ctx.isToday
                  ? Colors.white
                  : ctx.isCurrentMonth
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withAlpha(100),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigator(
    BuildContext context,
    MCalNavigatorContext ctx,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: ctx.canGoPrevious ? ctx.onPrevious : null,
            icon: Icon(
              Icons.chevron_left_rounded,
              color: ctx.canGoPrevious
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withAlpha(60),
            ),
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              formatMonthYear(ctx.currentMonth, locale),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: ctx.canGoNext ? ctx.onNext : null,
            icon: Icon(
              Icons.chevron_right_rounded,
              color: ctx.canGoNext
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withAlpha(60),
            ),
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: ctx.onToday,
            icon: Icon(Icons.today_rounded, color: colorScheme.primary),
            tooltip: 'Today',
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
