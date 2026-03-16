import 'package:flutter/material.dart';

import '../../styles/mcal_theme.dart';
import '../../utils/mcal_date_format_utils.dart';
import '../../utils/mcal_l10n_helper.dart';
import '../mcal_gesture_detector.dart';
import '../mcal_layout_directionality.dart';
import '../mcal_month_view_contexts.dart';
import 'week_number_cell.dart';

/// Widget for rendering weekday header row.
class WeekdayHeaderRowWidget extends StatelessWidget {
  final int firstDayOfWeek;
  final MCalThemeData theme;
  final Widget Function(BuildContext, MCalMonthDayHeaderContext, Widget)?
  dayHeaderBuilder;
  final Locale locale;
  final bool showWeekNumbers;
  final void Function(BuildContext, MCalMonthDayHeaderContext?)?
  onHoverDayOfWeekHeader;
  final void Function(BuildContext, MCalMonthDayHeaderContext)?
  onDayOfWeekHeaderTap;
  final void Function(BuildContext, MCalMonthDayHeaderContext)?
  onDayOfWeekHeaderLongPress;
  final void Function(BuildContext, MCalMonthDayHeaderContext)?
  onDayOfWeekHeaderDoubleTap;
  final void Function(BuildContext, MCalMonthDayHeaderContext)?
  onDayOfWeekHeaderSecondaryTap;

  const WeekdayHeaderRowWidget({
    super.key,
    required this.firstDayOfWeek,
    required this.theme,
    this.dayHeaderBuilder,
    required this.locale,
    this.showWeekNumbers = false,
    this.onHoverDayOfWeekHeader,
    this.onDayOfWeekHeaderTap,
    this.onDayOfWeekHeaderLongPress,
    this.onDayOfWeekHeaderDoubleTap,
    this.onDayOfWeekHeaderSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = mcalL10n(context);
    final cellBorderColor = theme.cellBorderColor ??
        MCalThemeData.fromTheme(Theme.of(context)).cellBorderColor!;
    // Use layout direction from MCalLayoutDirectionality rather than the ambient
    // Directionality (which carries textDirection) to avoid any mismatch.
    final isLayoutRTL = MCalLayoutDirectionality.of(context);

    // Generate weekday names in logical first-day-of-week order.
    // Do NOT reverse for RTL: the Row widget is already in RTL context (first
    // child appears on the RIGHT), so the logical order [firstDay … lastDay]
    // is automatically displayed right-to-left. Reversing here would
    // double-flip the order and produce an incorrect LTR result.
    final weekdayNames = <String>[];
    for (int i = 0; i < 7; i++) {
      final dayIndex = (firstDayOfWeek + i) % 7;
      weekdayNames.add(MCalDateFormatUtils.weekdayShortName(l10n, dayIndex));
    }

    // Build the day headers
    final dayHeaders = List.generate(7, (index) {
      final dayOfWeek = (firstDayOfWeek + index) % 7;
      final dayName = weekdayNames[index];

      // Default header content (without Expanded - that's added at the end)
      Widget headerContent = Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
        decoration: BoxDecoration(
          color:
              theme.monthTheme?.weekdayHeaderBackgroundColor ??
              theme.weekNumberBackgroundColor,
          border: Border(
            bottom: BorderSide(color: cellBorderColor),
          ),
        ),
        child: Center(
          child: Text(
            dayName,
            style: theme.monthTheme?.weekdayHeaderTextStyle,
            textAlign: TextAlign.center,
            overflow: TextOverflow.clip,
            maxLines: 1,
          ),
        ),
      );

      final headerContextObj = MCalMonthDayHeaderContext(
        dayOfWeek: dayOfWeek,
        dayName: dayName,
      );

      if (dayHeaderBuilder != null) {
        headerContent =
            dayHeaderBuilder!(context, headerContextObj, headerContent);
      }

      if (onDayOfWeekHeaderTap != null ||
          onDayOfWeekHeaderLongPress != null ||
          onDayOfWeekHeaderDoubleTap != null ||
          onDayOfWeekHeaderSecondaryTap != null) {
        headerContent = MCalGestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onDayOfWeekHeaderTap != null
              ? () => onDayOfWeekHeaderTap!(context, headerContextObj)
              : null,
          onLongPress: onDayOfWeekHeaderLongPress != null
              ? () => onDayOfWeekHeaderLongPress!(context, headerContextObj)
              : null,
          onDoubleTap: onDayOfWeekHeaderDoubleTap != null
              ? () => onDayOfWeekHeaderDoubleTap!(context, headerContextObj)
              : null,
          onSecondaryTap: onDayOfWeekHeaderSecondaryTap != null
              ? () => onDayOfWeekHeaderSecondaryTap!(context, headerContextObj)
              : null,
          child: headerContent,
        );
      }

      if (onHoverDayOfWeekHeader != null) {
        headerContent = MouseRegion(
          onEnter: (_) =>
              onHoverDayOfWeekHeader!(context, headerContextObj),
          onExit: (_) => onHoverDayOfWeekHeader!(context, null),
          child: headerContent,
        );
      }

      return Expanded(child: headerContent);
    });

    // If not showing week numbers, return simple row
    if (!showWeekNumbers) {
      return Row(children: dayHeaders);
    }

    // Build week number header cell
    final weekNumberHeader = Container(
      width: WeekNumberCell.columnWidth,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color:
            theme.weekNumberBackgroundColor ??
            theme.monthTheme?.weekdayHeaderBackgroundColor,
          border: Border(
          bottom: BorderSide(color: cellBorderColor),
        ),
      ),
      child: Center(
        child: Text(
          'Wk',
          style:
              theme.weekNumberTextStyle ??
              theme.monthTheme?.weekdayHeaderTextStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );

    // Position based on text direction
    // LTR: week number on LEFT, RTL: week number on RIGHT
    return Row(
      children: isLayoutRTL
          ? [...dayHeaders, weekNumberHeader]
          : [weekNumberHeader, ...dayHeaders],
    );
  }
}
