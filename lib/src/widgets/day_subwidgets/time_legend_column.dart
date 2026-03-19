import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../styles/mcal_theme.dart';
import '../../utils/time_utils.dart';
import '../mcal_day_view_contexts.dart';
import '../mcal_gesture_detector.dart';
import '../mcal_layout_directionality.dart';

/// Widget for the time legend column with hour labels.
///
/// Renders hour labels (e.g., "9 AM", "2 PM") at each hour boundary along the
/// left (LTR) or right (RTL) edge of the day view. Uses locale-aware time
/// formatting and supports custom builder callbacks.
class TimeLegendColumn extends StatelessWidget {
  const TimeLegendColumn({
    super.key,
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    this.timeLabelFormat,
    this.timeLabelBuilder,
    required this.theme,
    required this.locale,
    this.onTimeLabelTap,
    this.onTimeLabelLongPress,
    this.onTimeLabelDoubleTap,
    this.onTimeLabelSecondaryTap,
    this.onHoverTimeLabel,
    required this.displayDate,
    this.showSubHourLabels = false,
    this.subHourLabelInterval,
    this.subHourLabelBuilder,
  });

  final int startHour;
  final int endHour;
  final double hourHeight;
  final DateFormat? timeLabelFormat;
  final Widget Function(BuildContext, MCalTimeLabelContext, Widget)?
  timeLabelBuilder;
  final MCalThemeData theme;
  final Locale locale;
  final void Function(BuildContext, MCalTimeLabelContext)? onTimeLabelTap;
  final void Function(BuildContext, MCalTimeLabelContext)? onTimeLabelLongPress;
  final void Function(BuildContext, MCalTimeLabelContext)? onTimeLabelDoubleTap;
  final void Function(BuildContext, MCalTimeLabelContext)? onTimeLabelSecondaryTap;
  final void Function(BuildContext, MCalTimeLabelContext?)? onHoverTimeLabel;
  final DateTime displayDate;
  final bool showSubHourLabels;
  final Duration? subHourLabelInterval;
  final Widget Function(BuildContext, MCalTimeLabelContext, Widget)?
  subHourLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final defaults = MCalThemeData.fromTheme(Theme.of(context));
    final labelHeight = theme.dayViewTheme?.timeLegendLabelHeight ??
        defaults.dayViewTheme!.timeLegendLabelHeight!;
    final totalHours = (endHour - startHour).clamp(0, 24);
    final columnHeight = hourHeight * totalHours;
    final legendWidth = theme.dayViewTheme?.timeLegendWidth ??
        defaults.dayViewTheme!.timeLegendWidth!;

    final isLayoutRTL = MCalLayoutDirectionality.of(context);

    final showTicks = theme.dayViewTheme?.showTimeLegendTicks ?? true;

    final labelPosition =
        theme.dayViewTheme?.timeLabelPosition ??
        MCalTimeLabelPosition.topTrailingBelow;

    return Container(
      width: legendWidth,
      height: columnHeight,
      color: theme.dayViewTheme?.timeLegendBackgroundColor,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          if (showTicks)
            CustomPaint(
              size: Size(legendWidth, columnHeight),
              painter: TimeLegendTickPainter(
                startHour: startHour,
                endHour: endHour,
                hourHeight: hourHeight,
                tickColor:
                    theme.dayViewTheme?.timeLegendTickColor ??
                    defaults.dayViewTheme!.timeLegendTickColor!,
                tickWidth: theme.dayViewTheme?.timeLegendTickWidth ??
                    defaults.dayViewTheme!.timeLegendTickWidth!,
                tickLength: theme.dayViewTheme?.timeLegendTickLength ??
                    defaults.dayViewTheme!.timeLegendTickLength!,
                isLayoutRTL: isLayoutRTL,
                displayDate: displayDate,
              ),
            ),
          for (int hour = startHour; hour <= endHour; hour++)
            _buildPositionedLabel(
              context,
              hour: hour,
              minute: 0,
              isSubHour: false,
              labelPosition: labelPosition,
              labelHeight: labelHeight,
            ),
          if (showSubHourLabels && subHourLabelInterval != null)
            for (int hour = startHour; hour <= endHour; hour++)
              for (
                int minute = subHourLabelInterval!.inMinutes;
                minute < 60;
                minute += subHourLabelInterval!.inMinutes
              )
                _buildPositionedLabel(
                  context,
                  hour: hour,
                  minute: minute,
                  isSubHour: true,
                  labelPosition: labelPosition,
                  labelHeight: labelHeight,
                ),
        ],
      ),
    );
  }

  Widget _buildPositionedLabel(
    BuildContext context, {
    required int hour,
    required int minute,
    required bool isSubHour,
    required MCalTimeLabelPosition labelPosition,
    required double labelHeight,
  }) {
    final isBottomRef =
        labelPosition == MCalTimeLabelPosition.bottomLeadingAbove ||
        labelPosition == MCalTimeLabelPosition.bottomTrailingAbove;

    final refMinute = isBottomRef ? 60 : 0;
    final refTime = DateTime(
      displayDate.year,
      displayDate.month,
      displayDate.day,
      hour,
      minute + refMinute,
    );
    final gridlineY = timeToOffset(
      time: refTime,
      startHour: startHour,
      hourHeight: hourHeight,
    );

    final isAbove = labelPosition.name.endsWith('Above');
    final isCentered = labelPosition.name.endsWith('Centered');
    double top;
    if (isAbove) {
      top = gridlineY - labelHeight;
    } else if (isCentered) {
      top = gridlineY - labelHeight / 2;
    } else {
      top = gridlineY;
    }

    final isLeading = labelPosition.name.contains('Leading');
    final alignment = isLeading
        ? AlignmentDirectional.centerStart
        : AlignmentDirectional.centerEnd;

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      height: labelHeight,
      child: Align(
        alignment: alignment,
        child: isSubHour
            ? _buildSubHourLabel(context, hour: hour, minute: minute)
            : _buildHourLabel(context, hour: hour),
      ),
    );
  }

  Widget _buildHourLabel(BuildContext context, {required int hour}) {
    final time = DateTime(
      displayDate.year,
      displayDate.month,
      displayDate.day,
      hour,
      0,
    );

    DateFormat format;
    if (timeLabelFormat != null) {
      format = timeLabelFormat!;
    } else {
      format = _isEnglishLocale(locale)
          ? DateFormat('h:mm a', locale.toString())
          : DateFormat('HH:mm', locale.toString());
    }

    final formattedTime = format.format(time);

    final labelContext = MCalTimeLabelContext(
      hour: hour,
      minute: 0,
      time: time,
    );

    final semanticLabel = DateFormat('h a', locale.toString()).format(time);

    final baseStyle =
        theme.dayViewTheme?.timeLegendTextStyle ??
        MCalThemeData.fromTheme(Theme.of(context)).dayViewTheme!.timeLegendTextStyle;

    final defaultWidget = Text(formattedTime, style: baseStyle);

    Widget label = timeLabelBuilder != null
        ? timeLabelBuilder!(context, labelContext, defaultWidget)
        : defaultWidget;

    if (onTimeLabelTap != null ||
        onTimeLabelLongPress != null ||
        onTimeLabelDoubleTap != null ||
        onTimeLabelSecondaryTap != null) {
      label = MCalGestureDetector(
        onTap: onTimeLabelTap != null
            ? () => onTimeLabelTap!(context, labelContext)
            : null,
        onLongPress: onTimeLabelLongPress != null
            ? () => onTimeLabelLongPress!(context, labelContext)
            : null,
        onDoubleTap: onTimeLabelDoubleTap != null
            ? () => onTimeLabelDoubleTap!(context, labelContext)
            : null,
        onSecondaryTap: onTimeLabelSecondaryTap != null
            ? () => onTimeLabelSecondaryTap!(context, labelContext)
            : null,
        child: label,
      );
    }

    if (onHoverTimeLabel != null) {
      label = MouseRegion(
        onEnter: (_) => onHoverTimeLabel!(context, labelContext),
        onExit: (_) => onHoverTimeLabel!(context, null),
        child: label,
      );
    }

    return Semantics(
      label: semanticLabel,
      button:
          onTimeLabelTap != null ||
          onTimeLabelLongPress != null ||
          onTimeLabelDoubleTap != null ||
          onTimeLabelSecondaryTap != null,
      child: label,
    );
  }

  Widget _buildSubHourLabel(
    BuildContext context, {
    required int hour,
    required int minute,
  }) {
    final time = DateTime(
      displayDate.year,
      displayDate.month,
      displayDate.day,
      hour,
      minute,
    );

    DateFormat format;
    if (timeLabelFormat != null) {
      format = timeLabelFormat!;
    } else {
      format = _isEnglishLocale(locale)
          ? DateFormat('h:mm', locale.toString())
          : DateFormat('HH:mm', locale.toString());
    }

    final formattedTime = format.format(time);
    final labelContext = MCalTimeLabelContext(
      hour: hour,
      minute: minute,
      time: time,
    );

    final defaults = MCalThemeData.fromTheme(Theme.of(context));
    // defaults.dayViewTheme!.timeLegendTextStyle is guaranteed non-null by the factory.
    final effectiveStyle =
        theme.dayViewTheme?.timeLegendTextStyle ??
        defaults.dayViewTheme!.timeLegendTextStyle!;
    final baseFontSize = effectiveStyle.fontSize ?? 12.0;
    final baseColor = effectiveStyle.color!;
    final subHourStyle = effectiveStyle.copyWith(
      fontSize: baseFontSize * 0.8,
      color: baseColor.withValues(alpha: 0.5),
    );

    final defaultWidget = Text(formattedTime, style: subHourStyle);

    Widget label = subHourLabelBuilder != null
        ? subHourLabelBuilder!(context, labelContext, defaultWidget)
        : defaultWidget;

    return label;
  }

  bool _isEnglishLocale(Locale locale) {
    return locale.languageCode == 'en';
  }
}

/// Custom painter for drawing tick marks on the time legend.
///
/// Draws small horizontal lines at each hour boundary, extending from the
/// appropriate edge of the legend column (right edge for LTR, left edge for RTL).
class TimeLegendTickPainter extends CustomPainter {
  const TimeLegendTickPainter({
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    required this.tickColor,
    required this.tickWidth,
    required this.tickLength,
    required this.isLayoutRTL,
    required this.displayDate,
  });

  final int startHour;
  final int endHour;
  final double hourHeight;
  final Color tickColor;
  final double tickWidth;
  final double tickLength;
  final bool isLayoutRTL;
  final DateTime displayDate;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = tickColor
      ..strokeWidth = tickWidth
      ..style = PaintingStyle.stroke;

    for (int hour = startHour; hour <= endHour; hour++) {
      final time = DateTime(
        displayDate.year,
        displayDate.month,
        displayDate.day,
        hour,
        0,
      );

      final yOffset = timeToOffset(
        time: time,
        startHour: startHour,
        hourHeight: hourHeight,
      );

      if (isLayoutRTL) {
        canvas.drawLine(Offset(0, yOffset), Offset(tickLength, yOffset), paint);
      } else {
        canvas.drawLine(
          Offset(size.width - tickLength, yOffset),
          Offset(size.width, yOffset),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant TimeLegendTickPainter oldDelegate) {
    return startHour != oldDelegate.startHour ||
        endHour != oldDelegate.endHour ||
        hourHeight != oldDelegate.hourHeight ||
        tickColor != oldDelegate.tickColor ||
        tickWidth != oldDelegate.tickWidth ||
        tickLength != oldDelegate.tickLength ||
        isLayoutRTL != oldDelegate.isLayoutRTL;
  }
}
