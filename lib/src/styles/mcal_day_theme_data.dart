import 'package:flutter/material.dart';
import '../widgets/mcal_day_view_contexts.dart';

/// Theme data for Day View specific styling.
///
/// This class contains all properties that apply exclusively to [MCalDayView],
/// such as time legend, gridlines, current time indicator, and time regions.
/// Use [MCalDayThemeData.defaults] to create a theme with Material 3 defaults.
///
/// Example:
/// ```dart
/// MCalThemeData(
///   dayTheme: MCalDayThemeData(
///     timeLegendWidth: 72.0,
///     hourGridlineColor: Colors.blue.withValues(alpha: 0.2),
///   ),
/// )
/// ```
class MCalDayThemeData {
  /// Text style for day of week in Day View header (e.g., "Monday").
  final TextStyle? dayHeaderDayOfWeekStyle;

  /// Text style for date number in Day View header (e.g., "14").
  final TextStyle? dayHeaderDateStyle;

  /// Text color for week numbers in Day View.
  final Color? weekNumberTextColor;

  /// Width of the time legend column in Day View (in pixels).
  final double? timeLegendWidth;

  /// Text style for time labels in Day View time legend.
  final TextStyle? timeLegendTextStyle;

  /// Background color for the time legend column in Day View.
  final Color? timeLegendBackgroundColor;

  /// Whether to show tick marks on the time legend in Day View.
  ///
  /// When true, horizontal tick marks are drawn at each hour boundary,
  /// extending from the time legend into the grid. Useful for visual alignment
  /// of hours. LTR: ticks extend from the right edge; RTL: from the left edge.
  final bool? showTimeLegendTicks;

  /// Color for time legend tick marks in Day View.
  ///
  /// Defaults to outline color at 30% opacity when null.
  final Color? timeLegendTickColor;

  /// Width (thickness) of time legend tick marks in Day View (in pixels).
  ///
  /// Defaults to 1.0 when null.
  final double? timeLegendTickWidth;

  /// Length of time legend tick marks in Day View (in pixels).
  ///
  /// Defaults to 8.0 when null.
  final double? timeLegendTickLength;

  /// Color for hour gridlines in Day View.
  final Color? hourGridlineColor;

  /// Width of hour gridlines in Day View (in pixels).
  final double? hourGridlineWidth;

  /// Color for major gridlines in Day View (e.g., 30-minute marks).
  final Color? majorGridlineColor;

  /// Width of major gridlines in Day View (in pixels).
  final double? majorGridlineWidth;

  /// Color for minor gridlines in Day View (e.g., 15-minute marks).
  final Color? minorGridlineColor;

  /// Width of minor gridlines in Day View (in pixels).
  final double? minorGridlineWidth;

  /// Color for the current time indicator line in Day View.
  final Color? currentTimeIndicatorColor;

  /// Width of the current time indicator line in Day View (in pixels).
  final double? currentTimeIndicatorWidth;

  /// Radius of the dot at the start of the current time indicator (in pixels).
  final double? currentTimeIndicatorDotRadius;

  /// Maximum number of rows to display in the Day View all-day events section.
  final int? allDaySectionMaxRows;

  /// Minimum height for timed event tiles in Day View (in pixels).
  final double? timedEventMinHeight;

  /// Border radius for timed event tiles in Day View (in pixels).
  final double? timedEventBorderRadius;

  /// Padding inside timed event tiles in Day View.
  final EdgeInsets? timedEventPadding;

  /// Background color for special (non-blocking) time regions in Day View.
  final Color? specialTimeRegionColor;

  /// Background color for blocked time regions in Day View.
  final Color? blockedTimeRegionColor;

  /// Border color for time region overlays in Day View.
  final Color? timeRegionBorderColor;

  /// Text color for labels inside time regions in Day View.
  final Color? timeRegionTextColor;

  /// Text style for labels inside time regions in Day View.
  final TextStyle? timeRegionTextStyle;

  /// Hit area size for resize handles on timed events (in logical pixels).
  final double? resizeHandleSize;

  /// Minimum event duration (in minutes) required to show resize handles.
  final int? minResizeDurationMinutes;

  /// Position for time labels in the Day View time legend.
  ///
  /// This determines where time labels (e.g., "9:00 AM", "10:00 AM") are
  /// positioned relative to the hour gridlines. The position consists of three
  /// components:
  ///
  /// - **Horizontal alignment**: "Leading" (left in LTR, right in RTL) or
  ///   "Trailing" (right in LTR, left in RTL)
  /// - **Vertical reference**: "Top" (hour start gridline) or "Bottom"
  ///   (hour end gridline)
  /// - **Vertical alignment**: "Above" (label bottom aligns with gridline),
  ///   "Centered" (label center aligns with gridline), or "Below"
  ///   (label top aligns with gridline)
  ///
  /// Available positions:
  /// - [MCalTimeLabelPosition.topLeadingAbove]
  /// - [MCalTimeLabelPosition.topLeadingCentered]
  /// - [MCalTimeLabelPosition.topLeadingBelow]
  /// - [MCalTimeLabelPosition.topTrailingAbove]
  /// - [MCalTimeLabelPosition.topTrailingCentered]
  /// - [MCalTimeLabelPosition.topTrailingBelow] (default)
  /// - [MCalTimeLabelPosition.bottomLeadingAbove]
  /// - [MCalTimeLabelPosition.bottomTrailingAbove]
  ///
  /// Defaults to [MCalTimeLabelPosition.topTrailingBelow] when null.
  final MCalTimeLabelPosition? timeLabelPosition;

  /// Background color when hovering over time slots on hover-capable platforms.
  ///
  /// This color is applied to time slot areas (empty spaces in the day grid)
  /// when the user hovers over them with a pointer device (mouse, trackpad).
  /// Only applies on platforms that support hover events (desktop, web).
  ///
  /// When null, no hover background is applied to time slots.
  final Color? hoverTimeSlotBackgroundColor;

  /// Background color when hovering over event tiles.
  ///
  /// This color is applied to event tiles when the user hovers over them
  /// with a pointer device (mouse, trackpad). Only applies on platforms
  /// that support hover events (desktop, web).
  ///
  /// When null, no hover background is applied to event tiles.
  final Color? hoverEventBackgroundColor;

  /// Creates a new [MCalDayThemeData] instance.
  const MCalDayThemeData({
    this.dayHeaderDayOfWeekStyle,
    this.dayHeaderDateStyle,
    this.weekNumberTextColor,
    this.timeLegendWidth,
    this.timeLegendTextStyle,
    this.timeLegendBackgroundColor,
    this.showTimeLegendTicks,
    this.timeLegendTickColor,
    this.timeLegendTickWidth,
    this.timeLegendTickLength,
    this.hourGridlineColor,
    this.hourGridlineWidth,
    this.majorGridlineColor,
    this.majorGridlineWidth,
    this.minorGridlineColor,
    this.minorGridlineWidth,
    this.currentTimeIndicatorColor,
    this.currentTimeIndicatorWidth,
    this.currentTimeIndicatorDotRadius,
    this.allDaySectionMaxRows,
    this.timedEventMinHeight,
    this.timedEventBorderRadius,
    this.timedEventPadding,
    this.specialTimeRegionColor,
    this.blockedTimeRegionColor,
    this.timeRegionBorderColor,
    this.timeRegionTextColor,
    this.timeRegionTextStyle,
    this.resizeHandleSize,
    this.minResizeDurationMinutes,
    this.timeLabelPosition,
    this.hoverTimeSlotBackgroundColor,
    this.hoverEventBackgroundColor,
  });

  /// Creates a [MCalDayThemeData] instance with default values derived
  /// from the provided [ThemeData].
  factory MCalDayThemeData.defaults(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return MCalDayThemeData(
      dayHeaderDayOfWeekStyle: textTheme.labelMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
      dayHeaderDateStyle: textTheme.headlineMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      weekNumberTextColor: colorScheme.onSurfaceVariant,
      timeLegendWidth: 60.0,
      timeLegendTextStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      timeLegendBackgroundColor: colorScheme.surfaceContainerLow,
      showTimeLegendTicks: true,
      timeLegendTickColor: colorScheme.outline.withValues(alpha: 0.3),
      timeLegendTickWidth: 1.0,
      timeLegendTickLength: 8.0,
      hourGridlineColor: colorScheme.outline.withValues(alpha: 0.2),
      hourGridlineWidth: 1.0,
      majorGridlineColor: colorScheme.outline.withValues(alpha: 0.15),
      majorGridlineWidth: 1.0,
      minorGridlineColor: colorScheme.outline.withValues(alpha: 0.08),
      minorGridlineWidth: 0.5,
      currentTimeIndicatorColor: colorScheme.primary,
      currentTimeIndicatorWidth: 2.0,
      currentTimeIndicatorDotRadius: 6.0,
      allDaySectionMaxRows: 3,
      timedEventMinHeight: 20.0,
      timedEventBorderRadius: 4.0,
      timedEventPadding: const EdgeInsets.all(2.0),
      specialTimeRegionColor: colorScheme.surfaceContainer.withValues(alpha: 0.5),
      blockedTimeRegionColor:
          colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
      timeRegionBorderColor: colorScheme.outline.withValues(alpha: 0.3),
      timeRegionTextColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      timeRegionTextStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      ),
      resizeHandleSize: 8.0,
      minResizeDurationMinutes: 15,
    );
  }

  /// Creates a copy of this [MCalDayThemeData] with the given fields replaced.
  MCalDayThemeData copyWith({
    TextStyle? dayHeaderDayOfWeekStyle,
    TextStyle? dayHeaderDateStyle,
    Color? weekNumberTextColor,
    double? timeLegendWidth,
    TextStyle? timeLegendTextStyle,
    Color? timeLegendBackgroundColor,
    bool? showTimeLegendTicks,
    Color? timeLegendTickColor,
    double? timeLegendTickWidth,
    double? timeLegendTickLength,
    Color? hourGridlineColor,
    double? hourGridlineWidth,
    Color? majorGridlineColor,
    double? majorGridlineWidth,
    Color? minorGridlineColor,
    double? minorGridlineWidth,
    Color? currentTimeIndicatorColor,
    double? currentTimeIndicatorWidth,
    double? currentTimeIndicatorDotRadius,
    int? allDaySectionMaxRows,
    double? timedEventMinHeight,
    double? timedEventBorderRadius,
    EdgeInsets? timedEventPadding,
    Color? specialTimeRegionColor,
    Color? blockedTimeRegionColor,
    Color? timeRegionBorderColor,
    Color? timeRegionTextColor,
    TextStyle? timeRegionTextStyle,
    double? resizeHandleSize,
    int? minResizeDurationMinutes,
    MCalTimeLabelPosition? timeLabelPosition,
    Color? hoverTimeSlotBackgroundColor,
    Color? hoverEventBackgroundColor,
  }) {
    return MCalDayThemeData(
      dayHeaderDayOfWeekStyle:
          dayHeaderDayOfWeekStyle ?? this.dayHeaderDayOfWeekStyle,
      dayHeaderDateStyle: dayHeaderDateStyle ?? this.dayHeaderDateStyle,
      weekNumberTextColor: weekNumberTextColor ?? this.weekNumberTextColor,
      timeLegendWidth: timeLegendWidth ?? this.timeLegendWidth,
      timeLegendTextStyle: timeLegendTextStyle ?? this.timeLegendTextStyle,
      timeLegendBackgroundColor:
          timeLegendBackgroundColor ?? this.timeLegendBackgroundColor,
      showTimeLegendTicks: showTimeLegendTicks ?? this.showTimeLegendTicks,
      timeLegendTickColor: timeLegendTickColor ?? this.timeLegendTickColor,
      timeLegendTickWidth: timeLegendTickWidth ?? this.timeLegendTickWidth,
      timeLegendTickLength: timeLegendTickLength ?? this.timeLegendTickLength,
      hourGridlineColor: hourGridlineColor ?? this.hourGridlineColor,
      hourGridlineWidth: hourGridlineWidth ?? this.hourGridlineWidth,
      majorGridlineColor: majorGridlineColor ?? this.majorGridlineColor,
      majorGridlineWidth: majorGridlineWidth ?? this.majorGridlineWidth,
      minorGridlineColor: minorGridlineColor ?? this.minorGridlineColor,
      minorGridlineWidth: minorGridlineWidth ?? this.minorGridlineWidth,
      currentTimeIndicatorColor:
          currentTimeIndicatorColor ?? this.currentTimeIndicatorColor,
      currentTimeIndicatorWidth:
          currentTimeIndicatorWidth ?? this.currentTimeIndicatorWidth,
      currentTimeIndicatorDotRadius:
          currentTimeIndicatorDotRadius ?? this.currentTimeIndicatorDotRadius,
      allDaySectionMaxRows: allDaySectionMaxRows ?? this.allDaySectionMaxRows,
      timedEventMinHeight: timedEventMinHeight ?? this.timedEventMinHeight,
      timedEventBorderRadius:
          timedEventBorderRadius ?? this.timedEventBorderRadius,
      timedEventPadding: timedEventPadding ?? this.timedEventPadding,
      specialTimeRegionColor:
          specialTimeRegionColor ?? this.specialTimeRegionColor,
      blockedTimeRegionColor:
          blockedTimeRegionColor ?? this.blockedTimeRegionColor,
      timeRegionBorderColor:
          timeRegionBorderColor ?? this.timeRegionBorderColor,
      timeRegionTextColor: timeRegionTextColor ?? this.timeRegionTextColor,
      timeRegionTextStyle: timeRegionTextStyle ?? this.timeRegionTextStyle,
      resizeHandleSize: resizeHandleSize ?? this.resizeHandleSize,
      minResizeDurationMinutes:
          minResizeDurationMinutes ?? this.minResizeDurationMinutes,
      timeLabelPosition: timeLabelPosition ?? this.timeLabelPosition,
      hoverTimeSlotBackgroundColor:
          hoverTimeSlotBackgroundColor ?? this.hoverTimeSlotBackgroundColor,
      hoverEventBackgroundColor:
          hoverEventBackgroundColor ?? this.hoverEventBackgroundColor,
    );
  }

  /// Linearly interpolates between this theme and [other] by [t].
  MCalDayThemeData lerp(MCalDayThemeData? other, double t) {
    if (other == null) return this;

    return MCalDayThemeData(
      dayHeaderDayOfWeekStyle: TextStyle.lerp(
        dayHeaderDayOfWeekStyle,
        other.dayHeaderDayOfWeekStyle,
        t,
      ),
      dayHeaderDateStyle: TextStyle.lerp(
        dayHeaderDateStyle,
        other.dayHeaderDateStyle,
        t,
      ),
      weekNumberTextColor: Color.lerp(
        weekNumberTextColor,
        other.weekNumberTextColor,
        t,
      ),
      timeLegendWidth: _lerpDouble(timeLegendWidth, other.timeLegendWidth, t),
      timeLegendTextStyle: TextStyle.lerp(
        timeLegendTextStyle,
        other.timeLegendTextStyle,
        t,
      ),
      timeLegendBackgroundColor: Color.lerp(
        timeLegendBackgroundColor,
        other.timeLegendBackgroundColor,
        t,
      ),
      showTimeLegendTicks: t < 0.5 ? showTimeLegendTicks : other.showTimeLegendTicks,
      timeLegendTickColor: Color.lerp(
        timeLegendTickColor,
        other.timeLegendTickColor,
        t,
      ),
      timeLegendTickWidth: _lerpDouble(
        timeLegendTickWidth,
        other.timeLegendTickWidth,
        t,
      ),
      timeLegendTickLength: _lerpDouble(
        timeLegendTickLength,
        other.timeLegendTickLength,
        t,
      ),
      hourGridlineColor: Color.lerp(
        hourGridlineColor,
        other.hourGridlineColor,
        t,
      ),
      hourGridlineWidth: _lerpDouble(
        hourGridlineWidth,
        other.hourGridlineWidth,
        t,
      ),
      majorGridlineColor: Color.lerp(
        majorGridlineColor,
        other.majorGridlineColor,
        t,
      ),
      majorGridlineWidth: _lerpDouble(
        majorGridlineWidth,
        other.majorGridlineWidth,
        t,
      ),
      minorGridlineColor: Color.lerp(
        minorGridlineColor,
        other.minorGridlineColor,
        t,
      ),
      minorGridlineWidth: _lerpDouble(
        minorGridlineWidth,
        other.minorGridlineWidth,
        t,
      ),
      currentTimeIndicatorColor: Color.lerp(
        currentTimeIndicatorColor,
        other.currentTimeIndicatorColor,
        t,
      ),
      currentTimeIndicatorWidth: _lerpDouble(
        currentTimeIndicatorWidth,
        other.currentTimeIndicatorWidth,
        t,
      ),
      currentTimeIndicatorDotRadius: _lerpDouble(
        currentTimeIndicatorDotRadius,
        other.currentTimeIndicatorDotRadius,
        t,
      ),
      allDaySectionMaxRows: t < 0.5 ? allDaySectionMaxRows : other.allDaySectionMaxRows,
      timedEventMinHeight: _lerpDouble(
        timedEventMinHeight,
        other.timedEventMinHeight,
        t,
      ),
      timedEventBorderRadius: _lerpDouble(
        timedEventBorderRadius,
        other.timedEventBorderRadius,
        t,
      ),
      timedEventPadding: EdgeInsets.lerp(
        timedEventPadding,
        other.timedEventPadding,
        t,
      ),
      specialTimeRegionColor: Color.lerp(
        specialTimeRegionColor,
        other.specialTimeRegionColor,
        t,
      ),
      blockedTimeRegionColor: Color.lerp(
        blockedTimeRegionColor,
        other.blockedTimeRegionColor,
        t,
      ),
      timeRegionBorderColor: Color.lerp(
        timeRegionBorderColor,
        other.timeRegionBorderColor,
        t,
      ),
      timeRegionTextColor: Color.lerp(
        timeRegionTextColor,
        other.timeRegionTextColor,
        t,
      ),
      timeRegionTextStyle: TextStyle.lerp(
        timeRegionTextStyle,
        other.timeRegionTextStyle,
        t,
      ),
      resizeHandleSize: _lerpDouble(
        resizeHandleSize,
        other.resizeHandleSize,
        t,
      ),
      minResizeDurationMinutes:
          t < 0.5 ? minResizeDurationMinutes : other.minResizeDurationMinutes,
      timeLabelPosition: t < 0.5 ? timeLabelPosition : other.timeLabelPosition,
      hoverTimeSlotBackgroundColor: Color.lerp(
        hoverTimeSlotBackgroundColor,
        other.hoverTimeSlotBackgroundColor,
        t,
      ),
      hoverEventBackgroundColor: Color.lerp(
        hoverEventBackgroundColor,
        other.hoverEventBackgroundColor,
        t,
      ),
    );
  }

  static double? _lerpDouble(double? a, double? b, double t) {
    if (a == null && b == null) return null;
    a ??= 0.0;
    b ??= 0.0;
    return a + (b - a) * t;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MCalDayThemeData &&
          runtimeType == other.runtimeType &&
          dayHeaderDayOfWeekStyle == other.dayHeaderDayOfWeekStyle &&
          dayHeaderDateStyle == other.dayHeaderDateStyle &&
          weekNumberTextColor == other.weekNumberTextColor &&
          timeLegendWidth == other.timeLegendWidth &&
          timeLegendTextStyle == other.timeLegendTextStyle &&
          timeLegendBackgroundColor == other.timeLegendBackgroundColor &&
          showTimeLegendTicks == other.showTimeLegendTicks &&
          timeLegendTickColor == other.timeLegendTickColor &&
          timeLegendTickWidth == other.timeLegendTickWidth &&
          timeLegendTickLength == other.timeLegendTickLength &&
          hourGridlineColor == other.hourGridlineColor &&
          hourGridlineWidth == other.hourGridlineWidth &&
          majorGridlineColor == other.majorGridlineColor &&
          majorGridlineWidth == other.majorGridlineWidth &&
          minorGridlineColor == other.minorGridlineColor &&
          minorGridlineWidth == other.minorGridlineWidth &&
          currentTimeIndicatorColor == other.currentTimeIndicatorColor &&
          currentTimeIndicatorWidth == other.currentTimeIndicatorWidth &&
          currentTimeIndicatorDotRadius == other.currentTimeIndicatorDotRadius &&
          allDaySectionMaxRows == other.allDaySectionMaxRows &&
          timedEventMinHeight == other.timedEventMinHeight &&
          timedEventBorderRadius == other.timedEventBorderRadius &&
          timedEventPadding == other.timedEventPadding &&
          specialTimeRegionColor == other.specialTimeRegionColor &&
          blockedTimeRegionColor == other.blockedTimeRegionColor &&
          timeRegionBorderColor == other.timeRegionBorderColor &&
          timeRegionTextColor == other.timeRegionTextColor &&
          timeRegionTextStyle == other.timeRegionTextStyle &&
          resizeHandleSize == other.resizeHandleSize &&
          minResizeDurationMinutes == other.minResizeDurationMinutes &&
          timeLabelPosition == other.timeLabelPosition &&
          hoverTimeSlotBackgroundColor == other.hoverTimeSlotBackgroundColor &&
          hoverEventBackgroundColor == other.hoverEventBackgroundColor;

  @override
  int get hashCode => Object.hashAll([
        dayHeaderDayOfWeekStyle,
        dayHeaderDateStyle,
        weekNumberTextColor,
        timeLegendWidth,
        timeLegendTextStyle,
        timeLegendBackgroundColor,
        showTimeLegendTicks,
        timeLegendTickColor,
        timeLegendTickWidth,
        timeLegendTickLength,
        hourGridlineColor,
        hourGridlineWidth,
        majorGridlineColor,
        majorGridlineWidth,
        minorGridlineColor,
        minorGridlineWidth,
        currentTimeIndicatorColor,
        currentTimeIndicatorWidth,
        currentTimeIndicatorDotRadius,
        allDaySectionMaxRows,
        timedEventMinHeight,
        timedEventBorderRadius,
        timedEventPadding,
        specialTimeRegionColor,
        blockedTimeRegionColor,
        timeRegionBorderColor,
        timeRegionTextColor,
        timeRegionTextStyle,
        resizeHandleSize,
        minResizeDurationMinutes,
        timeLabelPosition,
        hoverTimeSlotBackgroundColor,
        hoverEventBackgroundColor,
      ]);
}
