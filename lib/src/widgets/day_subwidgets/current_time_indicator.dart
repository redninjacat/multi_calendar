import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../styles/mcal_theme.dart';
import '../../utils/mcal_l10n_helper.dart';
import '../../utils/time_utils.dart';
import '../mcal_day_view_contexts.dart';
import '../mcal_layout_directionality.dart';

/// StatefulWidget that displays the current time indicator with live updates.
///
/// Renders a horizontal line at the current time position with a leading dot (circle)
/// at the RTL-aware edge. The indicator updates every 60 seconds via a timer.
class CurrentTimeIndicator extends StatefulWidget {
  const CurrentTimeIndicator({
    super.key,
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    required this.displayDate,
    required this.theme,
    required this.locale,
    this.builder,
  });

  final int startHour;
  final int endHour;
  final double hourHeight;
  final DateTime displayDate;
  final MCalThemeData theme;
  final Locale locale;
  final Widget Function(BuildContext, MCalCurrentTimeContext, Widget)? builder;

  @override
  State<CurrentTimeIndicator> createState() => CurrentTimeIndicatorState();
}

class CurrentTimeIndicatorState extends State<CurrentTimeIndicator> {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentHour = _currentTime.hour;

    if (currentHour < widget.startHour || currentHour > widget.endHour) {
      return const SizedBox.shrink();
    }

    final offset = timeToOffset(
      time: _currentTime,
      startHour: widget.startHour,
      hourHeight: widget.hourHeight,
    );

    final isLayoutRTL = MCalLayoutDirectionality.of(context);

    final indicatorContext = MCalCurrentTimeContext(
      currentTime: _currentTime,
      offset: offset,
    );

    final timeFormat = DateFormat('h:mm a', widget.locale.toString());
    final formattedTime = timeFormat.format(_currentTime);
    final l10n = mcalL10n(context);
    final semanticLabel = l10n.currentTime(formattedTime);

    final defaults = MCalThemeData.fromTheme(Theme.of(context));
    final indicatorColor =
        widget.theme.dayTheme?.currentTimeIndicatorColor ??
        defaults.dayTheme!.currentTimeIndicatorColor!;
    final indicatorWidth =
        widget.theme.dayTheme?.currentTimeIndicatorWidth ?? 2.0;
    final dotRadius =
        widget.theme.dayTheme?.currentTimeIndicatorDotRadius ?? 6.0;

    final defaultWidget = Row(
      children: [
        if (!isLayoutRTL) _buildDot(dotRadius, indicatorColor),
        Expanded(
          child: Container(height: indicatorWidth, color: indicatorColor),
        ),
        if (isLayoutRTL) _buildDot(dotRadius, indicatorColor),
      ],
    );

    final indicatorWidget = widget.builder != null
        ? widget.builder!(context, indicatorContext, defaultWidget)
        : defaultWidget;

    return Positioned(
      top: offset,
      left: 0,
      right: 0,
      child: Semantics(
        label: semanticLabel,
        readOnly: true,
        child: indicatorWidget,
      ),
    );
  }

  Widget _buildDot(double radius, Color color) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
