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
            child: MCalTheme(
              data: MCalThemeData(
                cellBackgroundColor: Colors.transparent,
                cellBorderColor: Colors.transparent,
                // Today styling - used by default date label builder
                todayBackgroundColor: Colors.transparent,
                todayTextStyle: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                  fontSize: 18,
                ),
                // Non-today date styling
                cellTextStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface,
                  fontSize: 14,
                ),
                weekdayHeaderBackgroundColor: Colors.transparent,
                weekdayHeaderTextStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withAlpha(120),
                  letterSpacing: 1.2,
                ),
                // Center date labels for minimal style
                dateLabelPosition: DateLabelPosition.topCenter,
              ),
              child: MCalMonthView(
                controller: eventController,
                showNavigator: true,
                enableSwipeNavigation: true,
                locale: locale,
                weekLayoutBuilder: (context, layoutContext) {
                  // Minimal style: centered date labels + dot indicators
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final dayWidth = constraints.maxWidth / 7;
                      final rowHeight = constraints.maxHeight;
                      final children = <Widget>[];

                      for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
                        final date = layoutContext.dates[dayIndex];

                        // Build date label using the provided builder (respects theme)
                        final labelContext = MCalDateLabelContext(
                          date: date,
                          isCurrentMonth:
                              date.month == layoutContext.currentMonth.month,
                          isToday: _isToday(date),
                          defaultFormattedString: '${date.day}',
                          locale: Localizations.localeOf(context),
                          position: layoutContext.config.dateLabelPosition,
                        );

                        final labelWidget = layoutContext.dateLabelBuilder(
                          context,
                          labelContext,
                        );

                        // Center date label in cell
                        // IgnorePointer is applied by the core package's builder wrapper
                        children.add(
                          Positioned(
                            left: dayWidth * dayIndex,
                            top: 0,
                            width: dayWidth,
                            height: rowHeight - 12, // Leave room for dot
                            child: Center(child: labelWidget),
                          ),
                        );

                        // Check if any segments cover this day
                        final hasEvents = layoutContext.segments.any(
                          (segment) =>
                              dayIndex >= segment.startDayInWeek &&
                              dayIndex <= segment.endDayInWeek,
                        );

                        if (hasEvents) {
                          // Add a dot for this day (centered horizontally, near bottom)
                          children.add(
                            Positioned(
                              left: dayWidth * dayIndex + dayWidth / 2 - 2,
                              bottom: 4,
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorScheme.primary.withAlpha(180),
                                ),
                              ),
                            ),
                          );
                        }
                      }

                      return Stack(children: children);
                    },
                  );
                },
                dateLabelBuilder: (context, labelContext, defaultLabel) {
                  // Wrap default label with selection indicator
                  return _buildDateLabelWithSelection(
                    context,
                    labelContext,
                    defaultLabel,
                    colorScheme,
                  );
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
                    uniformEventColor: Theme.of(
                      context,
                    ).colorScheme.primary.withAlpha(180),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Helper to check if a date is today.
  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Wraps the default date label with selection indicator.
  Widget _buildDateLabelWithSelection(
    BuildContext context,
    MCalDateLabelContext labelContext,
    String defaultLabel,
    ColorScheme colorScheme,
  ) {
    final isSelected =
        selectedDate != null &&
        labelContext.date.year == selectedDate!.year &&
        labelContext.date.month == selectedDate!.month &&
        labelContext.date.day == selectedDate!.day;

    // Get text style from theme
    final theme = MCalTheme.of(context);
    final textStyle = labelContext.isToday
        ? (theme.todayTextStyle ??
              TextStyle(
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
                fontSize: 18,
              ))
        : (theme.cellTextStyle ??
              TextStyle(
                fontWeight: FontWeight.w400,
                color: labelContext.isCurrentMonth
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withAlpha(80),
                fontSize: 14,
              ));

    // Apply selection styling - white text on selected
    final effectiveTextStyle = isSelected
        ? textStyle.copyWith(color: Colors.white)
        : labelContext.isCurrentMonth
        ? textStyle
        : textStyle.copyWith(color: colorScheme.onSurface.withAlpha(80));

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? colorScheme.primary : Colors.transparent,
      ),
      child: Text(
        labelContext.defaultFormattedString,
        style: effectiveTextStyle,
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
