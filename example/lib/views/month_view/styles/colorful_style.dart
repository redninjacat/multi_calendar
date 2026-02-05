import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../utils/date_formatters.dart';
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
                    ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                    : [gradientStart.withAlpha(30), gradientEnd.withAlpha(30)],
              ),
            ),
            child: MCalTheme(
              data: MCalThemeData(
                cellBackgroundColor: Colors.transparent,
                cellBorderColor: Colors.transparent,
                dateLabelHeight: 24.0,
                todayBackgroundColor: Colors.transparent,
                weekdayHeaderBackgroundColor: Colors.transparent,
                weekdayHeaderTextStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white70 : gradientStart,
                ),
                // Thin pills for elongated event display
                eventTileHeight: 6.0,
                eventTileVerticalSpacing: 3.0,
                eventTileHorizontalSpacing: 6.0,
                eventTileCornerRadius: 4,
              ),
              child: MCalMonthView(
                controller: eventController,
                showNavigator: true,
                enableSwipeNavigation: true,
                locale: locale,
                enableDragAndDrop: true,
                eventTileBuilder: (context, tileContext, defaultTile) {
                  final segment = tileContext.segment;
                  final isAllDay = tileContext.isAllDay;
                  final MCalThemeData theme = MCalTheme.of(context);
                  final eventTileCornerRadius =
                      theme.eventTileCornerRadius ?? 4.0;

                  // Determine corner radius based on segment position
                  final leftRadius = segment?.isFirstSegment == true
                      ? Radius.circular(eventTileCornerRadius)
                      : Radius.zero;
                  final rightRadius = segment?.isLastSegment == true
                      ? Radius.circular(eventTileCornerRadius)
                      : Radius.zero;

                  final pill = Container(
                    // Timed events use half width, all-day events use full width
                    width: isAllDay ? null : (tileContext.width ?? 0) / 2,
                    decoration: BoxDecoration(
                      color:
                          tileContext.event.color ??
                          Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.only(
                        topLeft: leftRadius,
                        bottomLeft: leftRadius,
                        topRight: rightRadius,
                        bottomRight: rightRadius,
                      ),
                    ),
                  );

                  // For timed events, align to the left (start)
                  if (!isAllDay) {
                    return Align(
                      alignment: AlignmentDirectional.center,
                      child: pill,
                    );
                  }

                  return pill;
                },
                dateLabelBuilder: (context, labelContext, defaultLabel) {
                  return _buildDateLabel(context, labelContext);
                },
                dayCellBuilder: (context, ctx, defaultCell) {
                  return _buildDayCell(context, ctx);
                },
                navigatorBuilder: (context, ctx, defaultNavigator) {
                  return _buildNavigator(context, ctx);
                },
                draggedTileBuilder: (context, details) {
                  final theme = MCalTheme.of(context);
                  final cornerRadius = theme.eventTileCornerRadius ?? 4.0;
                  final tileHeight = theme.eventTileHeight ?? 6.0;
                  final isAllDay = details.event.isAllDay;

                  // Build the pill with Material wrapper for drop shadow
                  final pill = Material(
                    elevation: 6.0,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(cornerRadius),
                    child: Container(
                      // Timed events use half width, all-day events use full width
                      width: isAllDay
                          ? details.tileWidth
                          : details.tileWidth / 2,
                      height: tileHeight,
                      decoration: BoxDecoration(
                        color:
                            details.event.color ??
                            Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.all(
                          Radius.circular(cornerRadius),
                        ),
                      ),
                    ),
                  );

                  // For timed events, center within a sized container
                  if (!isAllDay) {
                    return SizedBox(
                      width: details.tileWidth,
                      height: tileHeight,
                      child: Center(child: pill),
                    );
                  }

                  return pill;
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
        ),
      ],
    );
  }

  /// Layer 1: Cell background only. Date labels are in Layer 2.
  Widget _buildDayCell(BuildContext context, MCalDayCellContext ctx) {
    final isSelected =
        selectedDate != null &&
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
    );
  }

  /// Layer 2: Custom date label with gradient styling.
  Widget _buildDateLabel(BuildContext context, MCalDateLabelContext ctx) {
    return Center(
      child: Text(
        ctx.defaultFormattedString,
        style: TextStyle(
          fontSize: 16,
          fontWeight: ctx.isToday ? FontWeight.bold : FontWeight.w600,
          color: ctx.isToday
              ? Colors.white
              : ctx.isCurrentMonth
              ? (isDarkMode ? Colors.white : gradientStart)
              : (isDarkMode ? Colors.white38 : gradientStart.withAlpha(100)),
        ),
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
