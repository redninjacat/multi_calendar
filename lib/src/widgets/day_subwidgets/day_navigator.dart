import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../l10n/mcal_localizations.dart';
import '../../styles/mcal_theme.dart';
import '../../utils/date_utils.dart';
import '../../utils/mcal_l10n_helper.dart';

/// Widget for day-to-day navigation controls.
///
/// Displays Previous/Today/Next buttons with the current date label.
/// Supports RTL layouts and custom builder callbacks.
class DayNavigator extends StatelessWidget {
  const DayNavigator({
    super.key,
    required this.displayDate,
    this.minDate,
    this.maxDate,
    required this.theme,
    this.navigatorBuilder,
    required this.locale,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  final DateTime displayDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final MCalThemeData theme;
  final Widget Function(BuildContext, DateTime, Widget)? navigatorBuilder;
  final Locale locale;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  bool _canGoPrevious() {
    if (minDate == null) return true;
    return !addDays(displayDate, -1).isBefore(minDate!);
  }

  bool _canGoNext() {
    if (maxDate == null) return true;
    return !addDays(displayDate, 1).isAfter(maxDate!);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = mcalL10n(context);
    final defaults = MCalThemeData.fromTheme(Theme.of(context));

    final canGoPrevious = _canGoPrevious();
    final canGoNext = _canGoNext();

    final dateFormat = DateFormat.yMMMMEEEEd(locale.toString());
    final formattedDate = dateFormat.format(displayDate);

    final bgColor =
        theme.navigatorBackgroundColor ?? defaults.navigatorBackgroundColor!;
    final textStyle =
        theme.navigatorTextStyle ?? defaults.navigatorTextStyle!;

    Widget navigator = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(color: bgColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _buildLTRButtons(
          canGoPrevious,
          canGoNext,
          formattedDate,
          l10n,
          textStyle,
        ),
      ),
    );

    if (navigatorBuilder != null) {
      navigator = navigatorBuilder!(context, displayDate, navigator);
    }

    return navigator;
  }

  List<Widget> _buildLTRButtons(
    bool canGoPrevious,
    bool canGoNext,
    String formattedDate,
    MCalLocalizations localizations,
    TextStyle textStyle,
  ) {
    return [
      Semantics(
        label: localizations.previousDay,
        button: true,
        enabled: canGoPrevious,
        child: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: canGoPrevious ? onPrevious : null,
          tooltip: localizations.previousDay,
        ),
      ),
      Expanded(
        child: Semantics(
          label: formattedDate,
          header: true,
          child: Text(
            formattedDate,
            style: textStyle,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      Semantics(
        label: localizations.today,
        button: true,
        child: IconButton(
          icon: const Icon(Icons.today),
          onPressed: onToday,
          tooltip: localizations.today,
        ),
      ),
      Semantics(
        label: localizations.nextDay,
        button: true,
        enabled: canGoNext,
        child: IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: canGoNext ? onNext : null,
          tooltip: localizations.nextDay,
        ),
      ),
    ];
  }
}
