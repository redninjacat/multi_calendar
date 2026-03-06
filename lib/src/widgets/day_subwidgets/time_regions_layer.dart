import 'package:flutter/material.dart';

import '../../models/mcal_region.dart';
import '../../styles/mcal_theme.dart';
import '../mcal_day_view_contexts.dart';

/// Widget for rendering special time regions (blocked time, lunch breaks, etc.).
///
/// Renders time regions as colored overlays positioned between gridlines and events (Layer 2).
/// Supports recurring regions via RRULE expansion and custom builder callbacks.
class TimeRegionsLayer extends StatelessWidget {
  const TimeRegionsLayer({
    super.key,
    required this.regions,
    required this.displayDate,
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    required this.theme,
    this.timeRegionBuilder,
  });

  final List<MCalRegion> regions;
  final DateTime displayDate;
  final int startHour;
  final int endHour;
  final double hourHeight;
  final MCalThemeData theme;
  final Widget Function(BuildContext, MCalTimeRegionContext, Widget)?
  timeRegionBuilder;

  @override
  Widget build(BuildContext context) {
    final applicableRegions = _getApplicableRegions();

    return Stack(
      children: [
        for (final region in applicableRegions)
          _buildTimeRegion(context, region),
      ],
    );
  }

  /// Filters and returns regions that apply to [displayDate], each expanded
  /// to a concrete (non-recurring) instance for that date.
  ///
  /// Delegates to [MCalRegion.expandedForDate] which uses the full
  /// RFC 5545 [MCalRecurrenceRule] engine — the same engine used for calendar
  /// events.  Regions that do not apply to [displayDate] are omitted.
  List<MCalRegion> _getApplicableRegions() {
    final result = <MCalRegion>[];
    for (final region in regions) {
      final expanded = region.expandedForDate(displayDate);
      if (expanded != null) {
        result.add(expanded);
      }
    }
    return result;
  }

  Widget _buildTimeRegion(BuildContext context, MCalRegion region) {
    final startOffset = _timeToOffset(region.start);
    final endOffset = _timeToOffset(region.end);
    final height = endOffset - startOffset;

    if (height <= 0) return const SizedBox.shrink();

    final regionContext = MCalTimeRegionContext(
      region: region,
      displayDate: displayDate,
      startOffset: startOffset,
      height: height,
    );

    final defaultWidget = Container(
      decoration: BoxDecoration(
        color:
            region.color ??
            (region.blockInteraction
                ? theme.dayTheme?.blockedTimeRegionColor
                : theme.dayTheme?.specialTimeRegionColor),
        border: Border(
          top: BorderSide(
            color:
                theme.dayTheme?.timeRegionBorderColor ??
                Colors.grey.withValues(alpha: 0.3),
            width: 1,
          ),
          bottom: BorderSide(
            color:
                theme.dayTheme?.timeRegionBorderColor ??
                Colors.grey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: region.text != null || region.icon != null
          ? Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (region.icon != null) ...[
                    Icon(
                      region.icon,
                      size: 16,
                      color:
                          theme.dayTheme?.timeRegionTextColor ?? Colors.black54,
                    ),
                    if (region.text != null) const SizedBox(width: 4),
                  ],
                  if (region.text != null)
                    Text(
                      region.text!,
                      style:
                          theme.dayTheme?.timeRegionTextStyle ??
                          TextStyle(
                            fontSize: 12,
                            color:
                                theme.dayTheme?.timeRegionTextColor ??
                                Colors.black54,
                          ),
                    ),
                ],
              ),
            )
          : null,
    );

    final child = timeRegionBuilder != null
        ? timeRegionBuilder!(context, regionContext, defaultWidget)
        : defaultWidget;

    return Positioned(
      top: startOffset,
      left: 0,
      right: 0,
      height: height,
      child: child,
    );
  }

  double _timeToOffset(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final totalMinutes = (hour - startHour) * 60 + minute;
    return (totalMinutes / 60.0) * hourHeight;
  }
}
