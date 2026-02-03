import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../utils/date_formatters.dart';
import '../../../utils/event_colors.dart';
import '../../../widgets/day_events_bottom_sheet.dart';
import '../../../widgets/style_description.dart';

/// Colorful style - vibrant gradients and bold colors.
class ColorfulMonthStyle extends StatelessWidget {
  const ColorfulMonthStyle({
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

  // Gradient colors
  static const gradientStart = Color(0xFF667EEA);
  static const gradientEnd = Color(0xFF764BA2);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StyleDescription(description: description),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        const Color(0xFF1a1a2e),
                        const Color(0xFF16213e),
                      ]
                    : [
                        gradientStart.withAlpha(30),
                        gradientEnd.withAlpha(30),
                      ],
              ),
            ),
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
                weekdayHeaderBackgroundColor: Colors.transparent,
                weekdayHeaderTextStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white70 : gradientStart,
                ),
              ),
              dayCellBuilder: (context, ctx, defaultCell) {
                return _buildDayCell(context, ctx);
              },
              navigatorBuilder: (context, ctx, defaultNavigator) {
                return _buildNavigator(context, ctx);
              },
              onCellTap: (context, details) {
                onDateSelected(details.date);
                showDayEventsBottomSheet(context, details.date, details.events, locale);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayCell(BuildContext context, MCalDayCellContext ctx) {
    final isSelected = selectedDate != null &&
        ctx.date.year == selectedDate!.year &&
        ctx.date.month == selectedDate!.month &&
        ctx.date.day == selectedDate!.day;

    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: ctx.isToday
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [gradientStart, gradientEnd],
              )
            : isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      gradientStart.withAlpha(100),
                      gradientEnd.withAlpha(100),
                    ],
                  )
                : null,
        color: !ctx.isToday && !isSelected
            ? (isDarkMode
                ? Colors.white.withAlpha(10)
                : Colors.white.withAlpha(180))
            : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ctx.isToday
            ? [
                BoxShadow(
                  color: gradientEnd.withAlpha(100),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
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
              fontWeight: ctx.isToday ? FontWeight.bold : FontWeight.w600,
              color: ctx.isToday
                  ? Colors.white
                  : ctx.isCurrentMonth
                      ? (isDarkMode ? Colors.white : gradientStart)
                      : (isDarkMode
                          ? Colors.white38
                          : gradientStart.withAlpha(100)),
            ),
          ),
          if (ctx.events.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ctx.events.take(3).map((event) {
                  // Use event.color if available, fall back to hash-based color
                  final color = event.color ?? getEventColor(event.id);
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withAlpha(150),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigator(BuildContext context, MCalNavigatorContext ctx) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [gradientStart, gradientEnd],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: ctx.canGoPrevious ? ctx.onPrevious : null,
              icon: Icon(
                Icons.chevron_left_rounded,
                color: ctx.canGoPrevious ? Colors.white : Colors.white54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              formatMonthYear(ctx.currentMonth, locale),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [gradientStart, gradientEnd],
                  ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [gradientStart, gradientEnd],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: ctx.canGoNext ? ctx.onNext : null,
              icon: Icon(
                Icons.chevron_right_rounded,
                color: ctx.canGoNext ? Colors.white : Colors.white54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
