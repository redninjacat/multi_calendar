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
                eventTileCornerRadius: 4,
                eventTileHorizontalSpacing: 6.0,
                monthTheme: MCalMonthThemeData(
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
                  eventTileHeight: 6.0,
                  eventTileVerticalSpacing: 3.0,
                  eventTileCornerRadius: 4,
                ),
              ),
              child: MCalMonthView(
                controller: eventController,
                showNavigator: true,
                enableSwipeNavigation: true,
                locale: locale,
                enableDragToMove: true,
                enableDragToResize: null,
                // Shift resize handles inward for timed (non-all-day) events
                // so they align with the narrower centered pill shape.
                resizeHandleInset: (tileContext, edge) {
                  if (tileContext.event.isAllDay) return 0.0;
                  final spanDays = tileContext.segment?.spanDays ?? 1;
                  final perDayWidth = (tileContext.width ?? 0.0) / spanDays;
                  return perDayWidth / 4;
                },
                eventTileBuilder: (context, tileContext, defaultTile) {
                  return _buildColorfulEventTile(context, tileContext);
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
                  final cornerRadius = theme.eventTileCornerRadius ?? theme.monthTheme?.eventTileCornerRadius ?? 4.0;
                  final tileHeight = theme.monthTheme?.eventTileHeight ?? 6.0;
                  final isAllDay = details.event.isAllDay;
                  final color =
                      details.event.color ??
                      Theme.of(context).colorScheme.primary;

                  // Timed events: inset each end by perDayWidth/4
                  // to match the pill geometry of the placed tiles.
                  final dayW = details.dayWidth ?? 0.0;
                  final tileW = details.tileWidth ?? 0.0;
                  final inset = isAllDay ? 0.0 : dayW / 4;
                  final pillWidth = tileW - (inset * 2);

                  return SizedBox(
                    width: tileW,
                    height: tileHeight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: inset),
                      child: Material(
                        elevation: 6.0,
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(cornerRadius),
                        child: Container(
                          width: pillWidth,
                          height: tileHeight,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.all(
                              Radius.circular(cornerRadius),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                dropTargetTileBuilder: (context, tileContext) {
                  return _buildColorfulDropTargetTile(context, tileContext);
                },
                dropTargetOverlayBuilder: (context, details) {
                  return Stack(
                    children: details.highlightedCells.map((cell) {
                      return Positioned.fromRect(
                        rect: cell.bounds,
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: details.isValid
                                  ? [
                                      gradientStart.withAlpha(80),
                                      gradientEnd.withAlpha(80),
                                    ]
                                  : [
                                      Colors.red.withAlpha(80),
                                      Colors.red.withAlpha(60),
                                    ],
                            ),
                            borderRadius: BorderRadius.horizontal(
                              left: cell.isFirst
                                  ? const Radius.circular(16)
                                  : Radius.zero,
                              right: cell.isLast
                                  ? const Radius.circular(16)
                                  : Radius.zero,
                            ),
                            boxShadow: details.isValid
                                ? [
                                    BoxShadow(
                                      color: gradientEnd.withAlpha(60),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  );
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
    final isFocused = ctx.isFocused;

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
            : isFocused
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  gradientStart.withAlpha(50),
                  gradientEnd.withAlpha(50),
                ],
              )
            : null,
        color: !ctx.isToday && !isSelected && !isFocused
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
            : isFocused
            ? [
                BoxShadow(
                  color: gradientEnd.withAlpha(60),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
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

  // ============================================================
  // Colorful Event Tile Helpers
  // ============================================================

  /// Computes the pill inset for one end of a timed (non-all-day) event.
  ///
  /// Single-day timed events are centered half-width pills so each side
  /// has an inset of `perDayWidth / 4`. Multi-day timed events use the
  /// same per-day inset on their first/last segments so the pill ends
  /// align with single-day pills.
  static double _timedPillInset(MCalEventTileContext ctx) {
    final spanDays = ctx.segment?.spanDays ?? 1;
    final perDayWidth = (ctx.width ?? 0) / spanDays;
    return perDayWidth / 4;
  }

  /// Builds a Colorful-style event tile.
  ///
  /// - **All-day events**: full-width pill with segment corner radii.
  /// - **Timed single-day events**: centered half-width pill.
  /// - **Timed multi-day events**: full-span pill inset on the first/last
  ///   segment ends so the edges align with single-day timed pills.
  Widget _buildColorfulEventTile(
    BuildContext context,
    MCalEventTileContext tileContext,
  ) {
    final segment = tileContext.segment;
    final isAllDay = tileContext.event.isAllDay;
    final MCalThemeData theme = MCalTheme.of(context);
    final cornerRadius = theme.eventTileCornerRadius ?? theme.monthTheme?.eventTileCornerRadius ?? 4.0;
    final color =
        tileContext.event.color ?? Theme.of(context).colorScheme.primary;

    final leftRadius = segment?.isFirstSegment == true
        ? Radius.circular(cornerRadius)
        : Radius.zero;
    final rightRadius = segment?.isLastSegment == true
        ? Radius.circular(cornerRadius)
        : Radius.zero;

    // All-day events: full width.
    if (isAllDay) {
      return Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: leftRadius,
            bottomLeft: leftRadius,
            topRight: rightRadius,
            bottomRight: rightRadius,
          ),
        ),
      );
    }

    // Timed events: inset the first/last segment ends to align with
    // single-day centered pills.
    final inset = _timedPillInset(tileContext);
    final isFirst = segment?.isFirstSegment ?? true;
    final isLast = segment?.isLastSegment ?? true;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: isFirst ? inset : 0,
        end: isLast ? inset : 0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: leftRadius,
            bottomLeft: leftRadius,
            topRight: rightRadius,
            bottomRight: rightRadius,
          ),
        ),
      ),
    );
  }

  /// Builds a Colorful-style drop target tile (border + softened fill).
  ///
  /// Uses the same geometry as [_buildColorfulEventTile] so the drop
  /// preview aligns perfectly with the source tile.
  Widget _buildColorfulDropTargetTile(
    BuildContext context,
    MCalEventTileContext tileContext,
  ) {
    final segment = tileContext.segment;
    final isAllDay = tileContext.event.isAllDay;
    final valid = tileContext.dropValid ?? true;
    final MCalThemeData theme = MCalTheme.of(context);
    final cornerRadius = theme.eventTileCornerRadius ?? theme.monthTheme?.eventTileCornerRadius ?? 4.0;

    final leftRadius = segment?.isFirstSegment == true
        ? Radius.circular(cornerRadius)
        : Radius.zero;
    final rightRadius = segment?.isLastSegment == true
        ? Radius.circular(cornerRadius)
        : Radius.zero;

    final tileColor = valid
        ? (tileContext.event.color ?? Theme.of(context).colorScheme.primary)
        : Colors.red.withValues(alpha: 0.5);
    final brightness = Theme.of(context).brightness;
    final fillColor = tileColor.soften(brightness);
    final borderSide = BorderSide(color: tileColor, width: 1.0);
    final isFirst = segment?.isFirstSegment ?? true;
    final isLast = segment?.isLastSegment ?? true;
    final tileBorder = Border(
      top: borderSide,
      bottom: borderSide,
      left: isFirst ? borderSide : BorderSide.none,
      right: isLast ? borderSide : BorderSide.none,
    );

    final decoration = BoxDecoration(
      color: fillColor,
      borderRadius: BorderRadius.only(
        topLeft: leftRadius,
        bottomLeft: leftRadius,
        topRight: rightRadius,
        bottomRight: rightRadius,
      ),
      border: tileBorder,
    );

    // All-day events: full width.
    if (isAllDay) {
      return Container(decoration: decoration);
    }

    // Timed events: same inset logic as the event tile.
    final inset = _timedPillInset(tileContext);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: isFirst ? inset : 0,
        end: isLast ? inset : 0,
      ),
      child: Container(decoration: decoration),
    );
  }
}
