import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../utils/date_formatters.dart';
import '../../../widgets/day_events_bottom_sheet.dart';
import '../../../widgets/event_detail_dialog.dart';
import '../../../widgets/style_description.dart';

/// Classic style - traditional grid with borders.
/// 
/// Interaction pattern (tile-based):
/// - Tap event tile → opens event detail dialog
/// - Tap +N overflow indicator → opens bottom sheet with all events
/// - Tap cell elsewhere → selects/focuses the cell (no dialog)
class ClassicMonthStyle extends StatelessWidget {
  const ClassicMonthStyle({
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
            theme: MCalThemeData(
              cellBackgroundColor: colorScheme.surface,
              cellBorderColor: colorScheme.outlineVariant,
              todayBackgroundColor: colorScheme.primaryContainer,
              todayTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
              weekdayHeaderBackgroundColor: colorScheme.surfaceContainerHighest,
              weekdayHeaderTextStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            dayCellBuilder: (context, ctx, defaultCell) {
              return _buildDayCell(context, ctx, colorScheme);
            },
            navigatorBuilder: (context, ctx, defaultNavigator) {
              return _buildNavigator(context, ctx, colorScheme);
            },
            // Tap event tile → show event detail dialog
            onEventTap: (context, details) {
              showEventDetailDialog(context, details.event, locale);
            },
            // Tap +N overflow → show bottom sheet with all events
            onOverflowTap: (context, details) {
              showDayEventsBottomSheet(context, details.date, details.allEvents, locale);
            },
            // Cell tap just focuses (no bottom sheet)
            onCellTap: (context, details) {
              onDateSelected(details.date);
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
    return Container(
      decoration: BoxDecoration(
        color: ctx.isToday
            ? colorScheme.primaryContainer
            : ctx.isCurrentMonth
                ? colorScheme.surface
                : colorScheme.surfaceContainerLow,
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              '${ctx.date.day}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: ctx.isToday ? FontWeight.bold : FontWeight.normal,
                color: ctx.isToday
                    ? colorScheme.primary
                    : ctx.isCurrentMonth
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withAlpha(100),
              ),
            ),
          ),
          if (ctx.events.isNotEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: ctx.events.take(2).map((event) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 1,
                      ),
                      color: colorScheme.primaryContainer,
                      child: Text(
                        event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          if (ctx.events.length > 2)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(
                '+${ctx.events.length - 2} more',
                style: TextStyle(
                  fontSize: 8,
                  color: colorScheme.onSurfaceVariant,
                ),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: ctx.canGoPrevious ? ctx.onPrevious : null,
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Prev'),
          ),
          Text(
            formatMonthYear(ctx.currentMonth, locale),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          TextButton.icon(
            onPressed: ctx.canGoNext ? ctx.onNext : null,
            icon: const Text('Next'),
            label: const Icon(Icons.arrow_forward, size: 16),
          ),
        ],
      ),
    );
  }
}
