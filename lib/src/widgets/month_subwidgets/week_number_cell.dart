import 'package:flutter/material.dart';

import '../../styles/mcal_theme.dart';
import '../mcal_month_view_contexts.dart';

/// Widget for rendering a week number cell.
///
/// Displays the ISO week number for a given week. Supports custom rendering
/// via the optional [weekNumberBuilder] callback.
class WeekNumberCell extends StatelessWidget {
  /// The ISO week number (1-53).
  final int weekNumber;

  /// The first day of this week.
  final DateTime firstDayOfWeek;

  /// The theme data for styling.
  final MCalThemeData theme;

  /// Optional builder for custom week number rendering.
  final Widget Function(BuildContext, MCalWeekNumberContext)? weekNumberBuilder;

  const WeekNumberCell({
    super.key,
    required this.weekNumber,
    required this.firstDayOfWeek,
    required this.theme,
    this.weekNumberBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // Create the context object
    final defaultFormattedString = 'W$weekNumber';
    final weekContext = MCalWeekNumberContext(
      weekNumber: weekNumber,
      firstDayOfWeek: firstDayOfWeek,
      defaultFormattedString: defaultFormattedString,
    );

    final defaults = MCalThemeData.fromTheme(Theme.of(context));
    final columnWidth = theme.monthViewTheme?.weekNumberColumnWidth ??
        defaults.monthViewTheme!.weekNumberColumnWidth!;
    final borderWidth = theme.monthViewTheme?.weekNumberBorderWidth ??
        defaults.monthViewTheme!.weekNumberBorderWidth!;

    // Use custom builder if provided
    if (weekNumberBuilder != null) {
      return SizedBox(
        width: columnWidth,
        child: weekNumberBuilder!(context, weekContext),
      );
    }

    // Default rendering
    final cellBorderColor = theme.cellBorderColor ??
        defaults.cellBorderColor!;
    return Container(
      width: columnWidth,
      decoration: BoxDecoration(
        color: theme.monthViewTheme?.weekNumberBackgroundColor,
        border: Border.all(color: cellBorderColor, width: borderWidth),
      ),
      child: Center(
        child: Text(
          '$weekNumber',
          style: theme.monthViewTheme?.weekNumberTextStyle,
        ),
      ),
    );
  }
}
