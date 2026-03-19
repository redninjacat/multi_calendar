import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../styles/mcal_theme.dart';
import '../../utils/date_utils.dart';
import '../mcal_day_view_contexts.dart';
import '../mcal_gesture_detector.dart';
import '../mcal_month_view_contexts.dart' show MCalWeekNumberContext;


/// Widget for the day header with optional week number.
///
/// Displays day of week, date number, and optional week number.
/// Supports RTL layouts and custom builder callbacks.
class DayHeader extends StatelessWidget {
  const DayHeader({
    super.key,
    required this.displayDate,
    required this.showWeekNumbers,
    required this.firstDayOfWeek,
    required this.theme,
    required this.locale,
    required this.textDirection,
    this.dayHeaderBuilder,
    this.weekNumberBuilder,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.onSecondaryTap,
    this.onHover,
  });

  final DateTime displayDate;
  final bool showWeekNumbers;

  /// The first day of the week (0 = Sunday, 1 = Monday, … 6 = Saturday),
  /// matching [MCalEventController.resolvedFirstDayOfWeek]. Used to compute
  /// the week number consistently with the Month View.
  final int firstDayOfWeek;
  final MCalThemeData theme;
  final Locale locale;
  final TextDirection textDirection;
  final Widget Function(BuildContext, MCalDayHeaderContext, Widget)?
  dayHeaderBuilder;
  final Widget Function(BuildContext, MCalWeekNumberContext, Widget)?
  weekNumberBuilder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onSecondaryTap;
  final void Function(BuildContext, MCalDayHeaderContext?)? onHover;

  @override
  Widget build(BuildContext context) {
    final weekNumber = getWeekNumber(displayDate, firstDayOfWeek);

    final headerContext = MCalDayHeaderContext(
      date: displayDate,
      weekNumber: showWeekNumbers ? weekNumber : null,
    );

    final dayOfWeekFull = DateFormat(
      'EEEE',
      locale.toString(),
    ).format(displayDate);
    final monthDayYear = DateFormat(
      'MMMM d',
      locale.toString(),
    ).format(displayDate);
    final semanticLabel = showWeekNumbers
        ? '$dayOfWeekFull, $monthDayYear, Week $weekNumber'
        : '$dayOfWeekFull, $monthDayYear';

    final defaults = MCalThemeData.fromTheme(Theme.of(context));

    Widget? resolvedWeekNumWidget;
    if (showWeekNumbers) {
      final defaultWeekNumWidget = _buildWeekNumber(weekNumber, defaults);
      if (weekNumberBuilder != null) {
        final fDow = firstDayOfWeek == 0 ? 7 : firstDayOfWeek;
        final daysSince = (displayDate.weekday - fDow + 7) % 7;
        final weekStart = displayDate.subtract(Duration(days: daysSince));
        resolvedWeekNumWidget = weekNumberBuilder!(
          context,
          MCalWeekNumberContext(
            weekNumber: weekNumber,
            firstDayOfWeek: weekStart,
            defaultFormattedString: 'W$weekNumber',
          ),
          defaultWeekNumWidget,
        );
      } else {
        resolvedWeekNumWidget = defaultWeekNumWidget;
      }
    }

    final headerPadding =
        theme.dayViewTheme?.dayHeaderPadding ?? defaults.dayViewTheme!.dayHeaderPadding!;
    final headerSpacing =
        theme.dayViewTheme?.dayHeaderSpacing ?? defaults.dayViewTheme!.dayHeaderSpacing!;

    final defaultWidget = Container(
      padding: headerPadding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showWeekNumbers && textDirection == TextDirection.ltr) ...[
            resolvedWeekNumWidget!,
            SizedBox(width: headerSpacing),
          ],
          _buildDayAndDate(defaults),
          if (showWeekNumbers && textDirection == TextDirection.rtl) ...[
            SizedBox(width: headerSpacing),
            resolvedWeekNumWidget!,
          ],
        ],
      ),
    );

    final headerWidget = dayHeaderBuilder != null
        ? dayHeaderBuilder!(context, headerContext, defaultWidget)
        : defaultWidget;

    return Semantics(
      label: semanticLabel,
      header: true,
      child: _wrapWithGestureDetector(context, headerContext, headerWidget),
    );
  }

  Widget _buildWeekNumber(int weekNumber, MCalThemeData defaults) {
    final wnPadding = theme.dayViewTheme?.dayHeaderWeekNumberPadding ??
        defaults.dayViewTheme!.dayHeaderWeekNumberPadding!;
    final wnRadius = theme.dayViewTheme?.dayHeaderWeekNumberBorderRadius ??
        defaults.dayViewTheme!.dayHeaderWeekNumberBorderRadius!;
    return Container(
      padding: wnPadding,
      decoration: BoxDecoration(
        color:
            theme.dayViewTheme?.weekNumberBackgroundColor ??
            defaults.dayViewTheme!.weekNumberBackgroundColor,
        borderRadius: BorderRadius.circular(wnRadius),
      ),
      child: Text(
        'W$weekNumber',
        style: theme.dayViewTheme?.weekNumberTextStyle ?? defaults.dayViewTheme!.weekNumberTextStyle,
      ),
    );
  }

  Widget _buildDayAndDate(MCalThemeData defaults) {
    final dayOfWeek = DateFormat('EEE', locale.toString()).format(displayDate);
    final dateNum = displayDate.day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dayOfWeek.toUpperCase(),
          style:
              theme.dayViewTheme?.dayHeaderDayOfWeekStyle ??
              defaults.dayViewTheme!.dayHeaderDayOfWeekStyle,
        ),
        Text(
          dateNum.toString(),
          style:
              theme.dayViewTheme?.dayHeaderDateStyle ??
              defaults.dayViewTheme!.dayHeaderDateStyle,
        ),
      ],
    );
  }

  Widget _wrapWithGestureDetector(
    BuildContext context,
    MCalDayHeaderContext headerContext,
    Widget child,
  ) {
    Widget result = child;

    if (onTap != null ||
        onLongPress != null ||
        onDoubleTap != null ||
        onSecondaryTap != null) {
      result = MCalGestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        onDoubleTap: onDoubleTap,
        onSecondaryTap: onSecondaryTap,
        child: result,
      );
    }

    if (onHover != null) {
      result = MouseRegion(
        onEnter: (_) => onHover!(context, headerContext),
        onExit: (_) => onHover!(context, null),
        child: result,
      );
    }

    return result;
  }
}
