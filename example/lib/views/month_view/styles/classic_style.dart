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
          child: MCalTheme(
            data: MCalThemeData(
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
              // Classic style: uniform tile colors, square corners, subtle border
              eventTileBackgroundColor: colorScheme.primaryContainer,
              eventTileTextStyle: TextStyle(
                fontSize: 10,
                color: colorScheme.onPrimaryContainer,
              ),
              tileCornerRadius: 0.0, // Square corners
              ignoreEventColors: true, // Use uniform colors from theme
              eventTileBorderColor: colorScheme.onPrimaryContainer,
              eventTileBorderWidth: 0.5,
            ),
            child: MCalMonthView(
              controller: eventController,
              showNavigator: true,
              enableSwipeNavigation: true,
              locale: locale,
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
                showDayEventsBottomSheet(
                  context,
                  details.date,
                  details.allEvents,
                  locale,
                );
              },
              // Cell tap just focuses (no bottom sheet)
              onCellTap: (context, details) {
                onDateSelected(details.date);
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Builds Layer 1 day cell - only background and border styling.
  /// Date labels and events are rendered in Layer 2 by the default layout builder.
  Widget _buildDayCell(
    BuildContext context,
    MCalDayCellContext ctx,
    ColorScheme colorScheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: ctx.isToday
            ? colorScheme.primaryContainer.withValues(alpha: 0.5)
            : ctx.isCurrentMonth
            ? colorScheme.surface
            : colorScheme.surfaceContainerLow,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.5),
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
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
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
