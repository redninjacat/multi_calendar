import 'package:flutter/material.dart';

import '../../models/mcal_region.dart';
import '../../styles/mcal_day_theme_data.dart';
import '../../styles/mcal_theme.dart';
import '../../utils/mcal_l10n_helper.dart';
import '../../utils/time_utils.dart';
import '../mcal_day_view_contexts.dart';

/// Widget for rendering horizontal gridlines at configured intervals.
///
/// Displays gridlines at hour, major (30-min), and minor intervals based on
/// [gridlineInterval] (1, 5, 10, 15, 20, 30, or 60 minutes). Uses a CustomPainter
/// for optimal performance.
///
/// Gridlines are classified by type:
/// - Hour: Lines at the start of each hour (minute == 0)
/// - Major: Lines at 30-minute marks
/// - Minor: Lines at other configured intervals
///
/// Each type has different visual styling from the theme.
class GridlinesLayer extends StatelessWidget {
  const GridlinesLayer({
    super.key,
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    required this.gridlineInterval,
    required this.displayDate,
    required this.theme,
    required this.locale,
    this.gridlineBuilder,
    this.regions = const [],
  });

  final int startHour;
  final int endHour;
  final double hourHeight;
  final Duration gridlineInterval;
  final DateTime displayDate;
  final MCalThemeData theme;
  final Locale locale;
  final Widget Function(BuildContext, MCalGridlineContext, Widget)?
  gridlineBuilder;
  final List<MCalRegion> regions;

  @override
  Widget build(BuildContext context) {
    final defaults = MCalThemeData.fromTheme(Theme.of(context));
    final dayDefaults = defaults.dayTheme!;
    if (gridlineBuilder != null) {
      return _buildCustomGridlines(context, dayDefaults);
    }

    final l10n = mcalL10n(context);
    final timeGridLabel = l10n.timeGrid;
    return Semantics(
      container: true,
      label: timeGridLabel,
      child: CustomPaint(
        painter: GridlinesPainter(
          startHour: startHour,
          endHour: endHour,
          hourHeight: hourHeight,
          gridlineInterval: gridlineInterval,
          displayDate: displayDate,
          hourGridlineColor: theme.dayTheme?.hourGridlineColor ??
              dayDefaults.hourGridlineColor!,
          hourGridlineWidth: theme.dayTheme?.hourGridlineWidth ??
              dayDefaults.hourGridlineWidth!,
          majorGridlineColor: theme.dayTheme?.majorGridlineColor ??
              dayDefaults.majorGridlineColor!,
          majorGridlineWidth: theme.dayTheme?.majorGridlineWidth ??
              dayDefaults.majorGridlineWidth!,
          minorGridlineColor: theme.dayTheme?.minorGridlineColor ??
              dayDefaults.minorGridlineColor!,
          minorGridlineWidth: theme.dayTheme?.minorGridlineWidth ??
              dayDefaults.minorGridlineWidth!,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildDefaultGridline(
    MCalGridlineContext gridline,
    MCalDayThemeData dayDefaults,
  ) {
    Color color;
    double width;
    switch (gridline.type) {
      case MCalGridlineType.hour:
        color = theme.dayTheme?.hourGridlineColor ?? dayDefaults.hourGridlineColor!;
        width = theme.dayTheme?.hourGridlineWidth ?? dayDefaults.hourGridlineWidth!;
      case MCalGridlineType.major:
        color = theme.dayTheme?.majorGridlineColor ?? dayDefaults.majorGridlineColor!;
        width = theme.dayTheme?.majorGridlineWidth ?? dayDefaults.majorGridlineWidth!;
      case MCalGridlineType.minor:
        color = theme.dayTheme?.minorGridlineColor ?? dayDefaults.minorGridlineColor!;
        width = theme.dayTheme?.minorGridlineWidth ?? dayDefaults.minorGridlineWidth!;
    }
    return Container(height: width, color: color);
  }

  Widget _buildCustomGridlines(BuildContext context, MCalDayThemeData dayDefaults) {
    final gridlines = _generateGridlines();

    return Stack(
      children: [
        for (final gridline in gridlines)
          Positioned(
            top: gridline.offset,
            left: 0,
            right: 0,
            child: gridlineBuilder!(
              context,
              gridline,
              _buildDefaultGridline(gridline, dayDefaults),
            ),
          ),
      ],
    );
  }

  List<MCalGridlineContext> _generateGridlines() {
    final gridlines = <MCalGridlineContext>[];
    final intervalMinutes = gridlineInterval.inMinutes;

    if (![1, 5, 10, 15, 20, 30, 60].contains(intervalMinutes)) {
      return gridlines;
    }

    for (int hour = startHour; hour <= endHour; hour++) {
      for (int minute = 0; minute < 60; minute += intervalMinutes) {
        if (hour == endHour && minute > 0) break;

        final time = DateTime(
          displayDate.year,
          displayDate.month,
          displayDate.day,
          hour,
          minute,
        );
        final offset = timeToOffset(
          time: time,
          startHour: startHour,
          hourHeight: hourHeight,
        );

        final type = _classifyGridlineType(minute);

        gridlines.add(
          MCalGridlineContext(
            hour: hour,
            minute: minute,
            offset: offset,
            type: type,
            intervalMinutes: intervalMinutes,
            regions: regions,
          ),
        );
      }
    }

    return gridlines;
  }

  /// Classifies a gridline based on its minute offset within the hour.
  ///
  /// Per design: hour (minute==0), major (minute==30 when interval<=30), minor (other).
  MCalGridlineType _classifyGridlineType(int minute) {
    if (minute == 0) return MCalGridlineType.hour;
    if (minute == 30 && gridlineInterval.inMinutes <= 30) {
      return MCalGridlineType.major;
    }
    return MCalGridlineType.minor;
  }
}

/// Custom painter for rendering gridlines efficiently.
///
/// Uses Canvas drawing operations to paint horizontal lines at configured
/// intervals, with different colors and widths based on gridline type.
class GridlinesPainter extends CustomPainter {
  GridlinesPainter({
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    required this.gridlineInterval,
    required this.displayDate,
    required this.hourGridlineColor,
    required this.hourGridlineWidth,
    required this.majorGridlineColor,
    required this.majorGridlineWidth,
    required this.minorGridlineColor,
    required this.minorGridlineWidth,
  });

  final int startHour;
  final int endHour;
  final double hourHeight;
  final Duration gridlineInterval;
  final DateTime displayDate;
  final Color hourGridlineColor;
  final double hourGridlineWidth;
  final Color majorGridlineColor;
  final double majorGridlineWidth;
  final Color minorGridlineColor;
  final double minorGridlineWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final intervalMinutes = gridlineInterval.inMinutes;

    if (![1, 5, 10, 15, 20, 30, 60].contains(intervalMinutes)) {
      return;
    }

    for (int hour = startHour; hour <= endHour; hour++) {
      for (int minute = 0; minute < 60; minute += intervalMinutes) {
        if (hour == endHour && minute > 0) break;

        final time = DateTime(
          displayDate.year,
          displayDate.month,
          displayDate.day,
          hour,
          minute,
        );
        final offset = timeToOffset(
          time: time,
          startHour: startHour,
          hourHeight: hourHeight,
        );

        final Color color;
        final double width;

        if (minute == 0) {
          color = hourGridlineColor;
          width = hourGridlineWidth;
        } else if (minute == 30 && intervalMinutes <= 30) {
          color = majorGridlineColor;
          width = majorGridlineWidth;
        } else {
          color = minorGridlineColor;
          width = minorGridlineWidth;
        }

        final paint = Paint()
          ..color = color
          ..strokeWidth = width
          ..style = PaintingStyle.stroke;

        canvas.drawLine(Offset(0, offset), Offset(size.width, offset), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant GridlinesPainter oldDelegate) {
    return startHour != oldDelegate.startHour ||
        endHour != oldDelegate.endHour ||
        hourHeight != oldDelegate.hourHeight ||
        gridlineInterval != oldDelegate.gridlineInterval ||
        hourGridlineColor != oldDelegate.hourGridlineColor ||
        hourGridlineWidth != oldDelegate.hourGridlineWidth ||
        majorGridlineColor != oldDelegate.majorGridlineColor ||
        majorGridlineWidth != oldDelegate.majorGridlineWidth ||
        minorGridlineColor != oldDelegate.minorGridlineColor ||
        minorGridlineWidth != oldDelegate.minorGridlineWidth;
  }
}
