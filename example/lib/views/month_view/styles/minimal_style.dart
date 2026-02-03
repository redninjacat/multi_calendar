import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../utils/date_formatters.dart';
import '../../../widgets/day_events_bottom_sheet.dart';
import '../../../widgets/style_description.dart';

/// Minimal style - clean with lots of whitespace.
class MinimalMonthStyle extends StatelessWidget {
  const MinimalMonthStyle({
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
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                cellBackgroundColor: Colors.transparent,
                cellBorderColor: Colors.transparent,
                todayBackgroundColor: Colors.transparent,
                todayTextStyle: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                  fontSize: 18,
                ),
                weekdayHeaderBackgroundColor: Colors.transparent,
                weekdayHeaderTextStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withAlpha(120),
                  letterSpacing: 1.2,
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
                // Use the same color as the minimal dot for consistency
                showDayEventsBottomSheet(
                  context, 
                  details.date, 
                  details.events, 
                  locale,
                  uniformEventColor: Theme.of(context).colorScheme.primary.withAlpha(180),
                );
              },
            ),
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
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? colorScheme.primary : Colors.transparent,
            ),
            child: Text(
              '${ctx.date.day}',
              style: TextStyle(
                fontSize: ctx.isToday ? 18 : 14,
                fontWeight: ctx.isToday ? FontWeight.w900 : FontWeight.w400,
                color: isSelected
                    ? Colors.white
                    : ctx.isToday
                        ? colorScheme.primary
                        : ctx.isCurrentMonth
                            ? colorScheme.onSurface
                            : colorScheme.onSurface.withAlpha(80),
              ),
            ),
          ),
          if (ctx.events.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withAlpha(180),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: ctx.canGoPrevious ? ctx.onPrevious : null,
            icon: Icon(
              Icons.chevron_left,
              color: ctx.canGoPrevious
                  ? colorScheme.onSurface.withAlpha(150)
                  : colorScheme.onSurface.withAlpha(40),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            formatMonthYear(ctx.currentMonth, locale).toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              letterSpacing: 3,
              color: colorScheme.onSurface.withAlpha(180),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: ctx.canGoNext ? ctx.onNext : null,
            icon: Icon(
              Icons.chevron_right,
              color: ctx.canGoNext
                  ? colorScheme.onSurface.withAlpha(150)
                  : colorScheme.onSurface.withAlpha(40),
            ),
          ),
        ],
      ),
    );
  }
}
