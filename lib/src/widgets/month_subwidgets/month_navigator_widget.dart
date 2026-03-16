import 'package:flutter/material.dart';

import '../../styles/mcal_theme.dart';
import '../../utils/mcal_date_format_utils.dart';
import '../../../l10n/mcal_localizations.dart';
import '../../utils/mcal_l10n_helper.dart';
import '../mcal_month_view_contexts.dart';

/// Widget for rendering month navigator with previous/next/today controls.
class MonthNavigatorWidget extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime? minDate;
  final DateTime? maxDate;
  final MCalThemeData theme;
  final Widget Function(BuildContext, MCalNavigatorContext, Widget)?
  navigatorBuilder;
  final Locale locale;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  const MonthNavigatorWidget({
    super.key,
    required this.currentMonth,
    this.minDate,
    this.maxDate,
    required this.theme,
    this.navigatorBuilder,
    required this.locale,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = mcalL10n(context);
    final defaults = MCalThemeData.fromTheme(Theme.of(context));

    // Use the ambient Directionality (set by the outer calendar wrapper) for
    // RTL detection. This is more reliable than a locale-string check and
    // ensures the navigator always agrees with the rest of the calendar.
    // Icons stay semantically consistent (← = previous, → = next); the Row
    // in RTL context automatically places the previous button on the right
    // and the next button on the left without any manual icon swapping.

    // Calculate if navigation is allowed
    final canGoPrevious = _canGoPrevious();
    final canGoNext = _canGoNext();

    // Format month/year display
    final monthName = _getMonthName(l10n);
    final year = currentMonth.year.toString();
    final monthYearText = '$monthName $year';

    final bgColor =
        theme.navigatorBackgroundColor ?? defaults.navigatorBackgroundColor!;
    final textStyle =
        theme.navigatorTextStyle ?? defaults.navigatorTextStyle!;

    // Build default navigator - use Expanded for text to prevent overflow
    Widget navigator = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(color: bgColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Semantics(
            label: l10n.previousMonth,
            button: true,
            enabled: canGoPrevious,
            child: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: canGoPrevious ? onPrevious : null,
              tooltip: l10n.previousMonth,
            ),
          ),
          Expanded(
            child: Semantics(
              label: monthYearText,
              header: true,
              child: Text(
                monthYearText,
                style: textStyle,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                label: l10n.nextMonth,
                button: true,
                enabled: canGoNext,
                child: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: canGoNext ? onNext : null,
                  tooltip: l10n.nextMonth,
                ),
              ),
              Semantics(
                label: l10n.today,
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.today),
                  onPressed: onToday,
                  tooltip: l10n.today,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // Apply builder callback if provided
    if (navigatorBuilder != null) {
      final contextObj = MCalNavigatorContext(
        currentMonth: currentMonth,
        onPrevious: onPrevious,
        onNext: onNext,
        onToday: onToday,
        canGoPrevious: canGoPrevious,
        canGoNext: canGoNext,
        locale: locale,
      );
      navigator = navigatorBuilder!(context, contextObj, navigator);
    }

    return navigator;
  }

  /// Checks if navigation to previous month is allowed.
  bool _canGoPrevious() {
    if (minDate == null) return true;
    final previousMonth = currentMonth.month == 1
        ? DateTime(currentMonth.year - 1, 12, 1)
        : DateTime(currentMonth.year, currentMonth.month - 1, 1);
    final minMonth = DateTime(minDate!.year, minDate!.month, 1);
    return !previousMonth.isBefore(minMonth);
  }

  /// Checks if navigation to next month is allowed.
  bool _canGoNext() {
    if (maxDate == null) return true;
    final nextMonth = currentMonth.month == 12
        ? DateTime(currentMonth.year + 1, 1, 1)
        : DateTime(currentMonth.year, currentMonth.month + 1, 1);
    final maxMonth = DateTime(maxDate!.year, maxDate!.month, 1);
    return !nextMonth.isAfter(maxMonth);
  }

  /// Gets the localized month name.
  String _getMonthName(MCalLocalizations l10n) {
    return MCalDateFormatUtils.monthName(l10n, currentMonth.month);
  }
}
