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
          child: MCalMonthView(
            controller: eventController,
            initialDate: DateTime.now(),
            showNavigator: true,
            enableSwipeNavigation: true,
            locale: locale,
            // Disable contiguous multi-day tiles when using custom cell builder
            // that handles events differently (e.g., showing dots instead of tiles)
            renderMultiDayEventsAsContiguous: false,
            theme: MCalThemeData(
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
            dayCellBuilder: (context, ctx, defaultCell) {
              return _buildDayCell(context, ctx, colorScheme);
            },
            navigatorBuilder: (context, ctx, defaultNavigator) {
              return _buildNavigator(context, ctx, colorScheme);
            },
            onCellTap: (context, details) {
              onDateSelected(details.date);
              showDayEventsBottomSheet(context, details.date, details.events, locale);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    MCalDayCellContext ctx,
    ColorScheme colorScheme,
  ) {
    final isSelected = selectedDate != null &&
        ctx.date.year == selectedDate!.year &&
        ctx.date.month == selectedDate!.month &&
        ctx.date.day == selectedDate!.day;

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
          if (ctx.events.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...ctx.events.take(3).map((event) {
                    // Use event.color if available, fall back to hash-based color
                    final color = event.color ?? getEventColor(event.id);
                    return Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                  if (ctx.events.length > 3)
                    Text(
                      '+',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: ctx.isToday
                            ? Colors.white70
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
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
