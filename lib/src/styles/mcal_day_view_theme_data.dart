import 'package:flutter/material.dart';
import '../widgets/mcal_day_view_contexts.dart';
import 'mcal_all_day_section_theme_mixin.dart';
import 'mcal_all_day_tile_theme_mixin.dart';
import 'mcal_event_tile_theme_mixin.dart';
import 'mcal_time_grid_theme_mixin.dart';

/// Theme data for Day View specific styling.
///
/// This class composes all three theme mixins plus its own Day-View-specific
/// properties (day header layout), providing a complete, flat constructor API
/// for Day View theming.
///
/// - [MCalEventTileThemeMixin] — event tile appearance, hover, contrast, drop
///   target tiles, resize handle, week numbers, keyboard focus rings (23 props)
/// - [MCalTimeGridThemeMixin] — time legend, gridlines, current time, time
///   regions, timed events, focus/hover slots, drop target overlay (50 props)
/// - [MCalAllDayTileThemeMixin] — all-day event tile appearance: background,
///   text style, border, padding (5 props)
/// - [MCalAllDaySectionThemeMixin] — all-day section layout: tile sizing,
///   wrap spacing, overflow handle styling (14 props)
/// - Own — day header padding, spacing, styles (6 props)
///
/// Use [MCalDayViewThemeData.defaults] to create a theme with Material 3
/// defaults derived from the app's [ThemeData].
///
/// Example:
/// ```dart
/// MCalThemeData(
///   dayViewTheme: MCalDayViewThemeData(
///     timeLegendWidth: 72.0,
///     hourGridlineColor: Colors.blue.withValues(alpha: 0.2),
///     dayHeaderPadding: EdgeInsets.all(12.0),
///   ),
/// )
/// ```
class MCalDayViewThemeData
    with MCalEventTileThemeMixin, MCalTimeGridThemeMixin, MCalAllDayTileThemeMixin, MCalAllDaySectionThemeMixin {
  // ── EventTileThemeMixin fields ────────────────────────────────────────────

  @override
  final Color? eventTileBackgroundColor;

  @override
  final TextStyle? eventTileTextStyle;

  @override
  final double? eventTileCornerRadius;

  @override
  final double? eventTileHorizontalSpacing;

  @override
  final double? eventTileBorderWidth;

  @override
  final Color? eventTileBorderColor;

  @override
  final Color? hoverEventBackgroundColor;

  @override
  final Color? eventTileLightContrastColor;

  @override
  final Color? eventTileDarkContrastColor;

  @override
  final TextStyle? weekNumberTextStyle;

  @override
  final Color? weekNumberBackgroundColor;

  @override
  final Color? dropTargetTileBackgroundColor;

  @override
  final Color? dropTargetTileInvalidBackgroundColor;

  @override
  final double? dropTargetTileCornerRadius;

  @override
  final Color? dropTargetTileBorderColor;

  @override
  final double? dropTargetTileBorderWidth;

  @override
  final Color? resizeHandleColor;

  @override
  final double? keyboardSelectionBorderWidth;

  @override
  final Color? keyboardSelectionBorderColor;

  @override
  final double? keyboardSelectionBorderRadius;

  @override
  final double? keyboardHighlightBorderWidth;

  @override
  final Color? keyboardHighlightBorderColor;

  @override
  final double? keyboardHighlightBorderRadius;

  // ── TimeGridThemeMixin fields ─────────────────────────────────────────────

  @override
  final double? timeLegendWidth;

  @override
  final TextStyle? timeLegendTextStyle;

  @override
  final Color? timeLegendBackgroundColor;

  @override
  final Color? timeLegendTickColor;

  @override
  final double? timeLegendTickWidth;

  @override
  final double? timeLegendTickLength;

  @override
  final bool? showTimeLegendTicks;

  @override
  final MCalTimeLabelPosition? timeLabelPosition;

  @override
  final double? timeLegendLabelHeight;

  @override
  final Color? hourGridlineColor;

  @override
  final double? hourGridlineWidth;

  @override
  final Color? majorGridlineColor;

  @override
  final double? majorGridlineWidth;

  @override
  final Color? minorGridlineColor;

  @override
  final double? minorGridlineWidth;

  @override
  final Color? currentTimeIndicatorColor;

  @override
  final double? currentTimeIndicatorWidth;

  @override
  final double? currentTimeIndicatorDotRadius;

  @override
  final Color? specialTimeRegionColor;

  @override
  final Color? blockedTimeRegionColor;

  @override
  final Color? timeRegionBorderColor;

  @override
  final Color? timeRegionTextColor;

  @override
  final TextStyle? timeRegionTextStyle;

  @override
  final double? timeRegionBorderWidth;

  @override
  final double? timeRegionIconSize;

  @override
  final double? timeRegionIconGap;

  @override
  final double? timedEventMinHeight;

  @override
  final EdgeInsets? timedEventPadding;

  @override
  final EdgeInsets? timedEventMargin;

  @override
  final double? timedEventCompactFontSize;

  @override
  final double? timedEventNormalFontSize;

  @override
  final double? timedEventTitleTimeGap;

  @override
  final Color? hoverTimeSlotBackgroundColor;

  @override
  final Color? focusedSlotBackgroundColor;

  @override
  final Color? focusedSlotBorderColor;

  @override
  final double? focusedSlotBorderWidth;

  @override
  final BoxDecoration? focusedSlotDecoration;

  @override
  final Color? dropTargetOverlayValidColor;

  @override
  final Color? dropTargetOverlayInvalidColor;

  @override
  final double? dropTargetOverlayBorderWidth;

  @override
  final Color? dropTargetOverlayBorderColor;

  @override
  final Color? disabledTimeSlotColor;

  @override
  final double? resizeHandleSize;

  @override
  final int? minResizeDurationMinutes;

  @override
  final double? resizeHandleVisualHeight;

  @override
  final double? resizeHandleHorizontalMargin;

  @override
  final double? resizeHandleBorderRadius;

  // ── AllDayTileThemeMixin + AllDaySectionThemeMixin fields ─────────────────

  @override
  final Color? allDayEventBackgroundColor;

  @override
  final TextStyle? allDayEventTextStyle;

  @override
  final Color? allDayEventBorderColor;

  @override
  final double? allDayEventBorderWidth;

  @override
  final double? allDayTileWidth;

  @override
  final double? allDayTileHeight;

  @override
  final EdgeInsets? allDayEventPadding;

  @override
  final double? allDayOverflowIndicatorWidth;

  @override
  final double? allDayWrapSpacing;

  @override
  final double? allDayWrapRunSpacing;

  @override
  final EdgeInsets? allDaySectionPadding;

  @override
  final double? allDayOverflowHandleWidth;

  @override
  final double? allDayOverflowHandleHeight;

  @override
  final double? allDayOverflowHandleBorderRadius;

  @override
  final double? allDayOverflowHandleGap;

  @override
  final double? allDayOverflowIndicatorFontSize;

  @override
  final double? allDayOverflowIndicatorBorderWidth;

  @override
  final double? allDaySectionLabelBottomPadding;

  // ── Day-View-specific own properties ──────────────────────────────────────

  /// Text style for day of week in Day View header (e.g., "Monday").
  final TextStyle? dayHeaderDayOfWeekStyle;

  /// Text style for date number in Day View header (e.g., "14").
  final TextStyle? dayHeaderDateStyle;

  /// Padding inside the day header container.
  ///
  /// Replaces the hardcoded `EdgeInsets.all(8.0)` in `day_header.dart`.
  final EdgeInsets? dayHeaderPadding;

  /// Padding around the week number badge in the day header.
  ///
  /// Replaces the hardcoded `EdgeInsets.symmetric(horizontal: 6, vertical: 2)`
  /// in `day_header.dart`.
  final EdgeInsets? dayHeaderWeekNumberPadding;

  /// Border radius for the week number badge in the day header (in pixels).
  ///
  /// Replaces the hardcoded `4` (`BorderRadius.circular(4)`) in `day_header.dart`.
  final double? dayHeaderWeekNumberBorderRadius;

  /// Horizontal spacing between elements in the day header (in pixels).
  ///
  /// Replaces the hardcoded `SizedBox(width: 8)` in `day_header.dart`.
  final double? dayHeaderSpacing;

  /// Creates a new [MCalDayViewThemeData] instance.
  ///
  /// All parameters are optional; omitted properties fall back to master
  /// defaults resolved from the app's [ThemeData] at build time.
  const MCalDayViewThemeData({
    // EventTileThemeMixin
    this.eventTileBackgroundColor,
    this.eventTileTextStyle,
    this.eventTileCornerRadius,
    this.eventTileHorizontalSpacing,
    this.eventTileBorderWidth,
    this.eventTileBorderColor,
    this.hoverEventBackgroundColor,
    this.eventTileLightContrastColor,
    this.eventTileDarkContrastColor,
    this.weekNumberTextStyle,
    this.weekNumberBackgroundColor,
    this.dropTargetTileBackgroundColor,
    this.dropTargetTileInvalidBackgroundColor,
    this.dropTargetTileCornerRadius,
    this.dropTargetTileBorderColor,
    this.dropTargetTileBorderWidth,
    this.resizeHandleColor,
    this.keyboardSelectionBorderWidth,
    this.keyboardSelectionBorderColor,
    this.keyboardSelectionBorderRadius,
    this.keyboardHighlightBorderWidth,
    this.keyboardHighlightBorderColor,
    this.keyboardHighlightBorderRadius,
    // TimeGridThemeMixin
    this.timeLegendWidth,
    this.timeLegendTextStyle,
    this.timeLegendBackgroundColor,
    this.timeLegendTickColor,
    this.timeLegendTickWidth,
    this.timeLegendTickLength,
    this.showTimeLegendTicks,
    this.timeLabelPosition,
    this.timeLegendLabelHeight,
    this.hourGridlineColor,
    this.hourGridlineWidth,
    this.majorGridlineColor,
    this.majorGridlineWidth,
    this.minorGridlineColor,
    this.minorGridlineWidth,
    this.currentTimeIndicatorColor,
    this.currentTimeIndicatorWidth,
    this.currentTimeIndicatorDotRadius,
    this.specialTimeRegionColor,
    this.blockedTimeRegionColor,
    this.timeRegionBorderColor,
    this.timeRegionTextColor,
    this.timeRegionTextStyle,
    this.timeRegionBorderWidth,
    this.timeRegionIconSize,
    this.timeRegionIconGap,
    this.timedEventMinHeight,
    this.timedEventPadding,
    this.timedEventMargin,
    this.timedEventCompactFontSize,
    this.timedEventNormalFontSize,
    this.timedEventTitleTimeGap,
    this.hoverTimeSlotBackgroundColor,
    this.focusedSlotBackgroundColor,
    this.focusedSlotBorderColor,
    this.focusedSlotBorderWidth,
    this.focusedSlotDecoration,
    this.dropTargetOverlayValidColor,
    this.dropTargetOverlayInvalidColor,
    this.dropTargetOverlayBorderWidth,
    this.dropTargetOverlayBorderColor,
    this.disabledTimeSlotColor,
    this.resizeHandleSize,
    this.minResizeDurationMinutes,
    this.resizeHandleVisualHeight,
    this.resizeHandleHorizontalMargin,
    this.resizeHandleBorderRadius,
    // AllDayTileThemeMixin
    this.allDayEventBackgroundColor,
    this.allDayEventTextStyle,
    this.allDayEventBorderColor,
    this.allDayEventBorderWidth,
    this.allDayTileWidth,
    this.allDayTileHeight,
    this.allDayEventPadding,
    this.allDayOverflowIndicatorWidth,
    this.allDayWrapSpacing,
    this.allDayWrapRunSpacing,
    this.allDaySectionPadding,
    this.allDayOverflowHandleWidth,
    this.allDayOverflowHandleHeight,
    this.allDayOverflowHandleBorderRadius,
    this.allDayOverflowHandleGap,
    this.allDayOverflowIndicatorFontSize,
    this.allDayOverflowIndicatorBorderWidth,
    this.allDaySectionLabelBottomPadding,
    // Day-View-specific own
    this.dayHeaderDayOfWeekStyle,
    this.dayHeaderDateStyle,
    this.dayHeaderPadding,
    this.dayHeaderWeekNumberPadding,
    this.dayHeaderWeekNumberBorderRadius,
    this.dayHeaderSpacing,
  });

  /// Creates the **master defaults** for Day View theming from [theme].
  ///
  /// Called by [MCalThemeData.fromTheme] to populate [MCalThemeData.dayViewTheme].
  /// All returned properties are non-null and are derived from the theme's
  /// [ColorScheme] and [TextTheme] following Material 3 color roles. New
  /// layout property defaults match the values previously hardcoded in widgets,
  /// preserving the current visual appearance.
  factory MCalDayViewThemeData.defaults(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return MCalDayViewThemeData(
      // EventTileThemeMixin defaults
      eventTileBackgroundColor: colorScheme.primaryContainer,
      eventTileTextStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onPrimaryContainer,
      ),
      eventTileCornerRadius: 3.0,
      eventTileHorizontalSpacing: 1.0,
      eventTileBorderWidth: 0.0,
      hoverEventBackgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.8),
      eventTileLightContrastColor: Colors.white,
      eventTileDarkContrastColor: colorScheme.onSurface,
      weekNumberTextStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      weekNumberBackgroundColor: colorScheme.surfaceContainerHighest,
      dropTargetTileBackgroundColor: colorScheme.primaryContainer,
      dropTargetTileInvalidBackgroundColor: colorScheme.errorContainer,
      dropTargetTileCornerRadius: 3.0,
      dropTargetTileBorderColor: colorScheme.primary,
      dropTargetTileBorderWidth: 2.0,
      resizeHandleColor: Colors.white.withValues(alpha: 0.7),
      keyboardSelectionBorderWidth: 2.0,
      keyboardSelectionBorderColor: colorScheme.primary,
      keyboardSelectionBorderRadius: 4.0,
      keyboardHighlightBorderWidth: 1.5,
      keyboardHighlightBorderColor: colorScheme.outline,
      keyboardHighlightBorderRadius: 4.0,
      // TimeGridThemeMixin defaults — existing
      timeLegendWidth: 60.0,
      timeLegendTextStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      timeLegendBackgroundColor: colorScheme.surfaceContainerLow,
      timeLegendTickColor: colorScheme.outlineVariant,
      timeLegendTickWidth: 1.0,
      timeLegendTickLength: 8.0,
      showTimeLegendTicks: true,
      hourGridlineColor: colorScheme.outlineVariant,
      hourGridlineWidth: 1.0,
      majorGridlineColor: colorScheme.outlineVariant.withValues(alpha: 0.7),
      majorGridlineWidth: 1.0,
      minorGridlineColor: colorScheme.outlineVariant.withValues(alpha: 0.4),
      minorGridlineWidth: 0.5,
      currentTimeIndicatorColor: colorScheme.primary,
      currentTimeIndicatorWidth: 2.0,
      currentTimeIndicatorDotRadius: 6.0,
      specialTimeRegionColor: colorScheme.surfaceContainer.withValues(alpha: 0.5),
      blockedTimeRegionColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
      timeRegionBorderColor: colorScheme.outlineVariant,
      timeRegionTextColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      timeRegionTextStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      ),
      timedEventMinHeight: 20.0,
      timedEventPadding: const EdgeInsets.all(2.0),
      focusedSlotBackgroundColor: colorScheme.primary.withValues(alpha: 0.08),
      focusedSlotBorderColor: colorScheme.primary,
      focusedSlotBorderWidth: 3.0,
      dropTargetOverlayValidColor: colorScheme.primary.withValues(alpha: 0.2),
      dropTargetOverlayInvalidColor: colorScheme.error.withValues(alpha: 0.2),
      dropTargetOverlayBorderWidth: 3.0,
      dropTargetOverlayBorderColor: colorScheme.primary,
      disabledTimeSlotColor: colorScheme.onSurface.withValues(alpha: 0.12),
      resizeHandleSize: 8.0,
      minResizeDurationMinutes: 15,
      // TimeGridThemeMixin defaults — new layout (match current hardcoded values)
      timeLegendLabelHeight: 20.0,
      timedEventMargin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
      timedEventCompactFontSize: 10.0,
      timedEventNormalFontSize: 12.0,
      timedEventTitleTimeGap: 2.0,
      timeRegionBorderWidth: 1.0,
      timeRegionIconSize: 16.0,
      timeRegionIconGap: 4.0,
      resizeHandleVisualHeight: 2.0,
      resizeHandleHorizontalMargin: 4.0,
      resizeHandleBorderRadius: 1.0,
      // AllDayTileThemeMixin defaults
      allDayEventBackgroundColor: colorScheme.secondaryContainer,
      allDayEventTextStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSecondaryContainer,
      ),
      allDayEventBorderColor: colorScheme.secondary.withValues(alpha: 0.3),
      allDayEventBorderWidth: 1.0,
      // AllDaySectionThemeMixin defaults — sizing
      allDayTileWidth: 120.0,
      allDayTileHeight: 28.0,
      allDayEventPadding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      allDayOverflowIndicatorWidth: 80.0,
      // AllDaySectionThemeMixin defaults — layout
      allDayWrapSpacing: 4.0,
      allDayWrapRunSpacing: 4.0,
      allDaySectionPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      allDayOverflowHandleWidth: 3.0,
      allDayOverflowHandleHeight: 16.0,
      allDayOverflowHandleBorderRadius: 1.5,
      allDayOverflowHandleGap: 4.0,
      allDayOverflowIndicatorFontSize: 11.0,
      allDayOverflowIndicatorBorderWidth: 1.0,
      allDaySectionLabelBottomPadding: 4.0,
      // Day-View-specific own defaults — existing
      dayHeaderDayOfWeekStyle: textTheme.labelMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
      dayHeaderDateStyle: textTheme.headlineMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      // Day-View-specific own defaults — new layout (match current hardcoded values)
      dayHeaderPadding: const EdgeInsets.all(8.0),
      dayHeaderWeekNumberPadding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      dayHeaderWeekNumberBorderRadius: 4.0,
      dayHeaderSpacing: 8.0,
    );
  }

  /// Creates a copy of this [MCalDayViewThemeData] with the given fields replaced.
  MCalDayViewThemeData copyWith({
    // EventTileThemeMixin
    Color? eventTileBackgroundColor,
    TextStyle? eventTileTextStyle,
    double? eventTileCornerRadius,
    double? eventTileHorizontalSpacing,
    double? eventTileBorderWidth,
    Color? eventTileBorderColor,
    Color? hoverEventBackgroundColor,
    Color? eventTileLightContrastColor,
    Color? eventTileDarkContrastColor,
    TextStyle? weekNumberTextStyle,
    Color? weekNumberBackgroundColor,
    Color? dropTargetTileBackgroundColor,
    Color? dropTargetTileInvalidBackgroundColor,
    double? dropTargetTileCornerRadius,
    Color? dropTargetTileBorderColor,
    double? dropTargetTileBorderWidth,
    Color? resizeHandleColor,
    double? keyboardSelectionBorderWidth,
    Color? keyboardSelectionBorderColor,
    double? keyboardSelectionBorderRadius,
    double? keyboardHighlightBorderWidth,
    Color? keyboardHighlightBorderColor,
    double? keyboardHighlightBorderRadius,
    // TimeGridThemeMixin
    double? timeLegendWidth,
    TextStyle? timeLegendTextStyle,
    Color? timeLegendBackgroundColor,
    Color? timeLegendTickColor,
    double? timeLegendTickWidth,
    double? timeLegendTickLength,
    bool? showTimeLegendTicks,
    MCalTimeLabelPosition? timeLabelPosition,
    double? timeLegendLabelHeight,
    Color? hourGridlineColor,
    double? hourGridlineWidth,
    Color? majorGridlineColor,
    double? majorGridlineWidth,
    Color? minorGridlineColor,
    double? minorGridlineWidth,
    Color? currentTimeIndicatorColor,
    double? currentTimeIndicatorWidth,
    double? currentTimeIndicatorDotRadius,
    Color? specialTimeRegionColor,
    Color? blockedTimeRegionColor,
    Color? timeRegionBorderColor,
    Color? timeRegionTextColor,
    TextStyle? timeRegionTextStyle,
    double? timeRegionBorderWidth,
    double? timeRegionIconSize,
    double? timeRegionIconGap,
    double? timedEventMinHeight,
    EdgeInsets? timedEventPadding,
    EdgeInsets? timedEventMargin,
    double? timedEventCompactFontSize,
    double? timedEventNormalFontSize,
    double? timedEventTitleTimeGap,
    Color? hoverTimeSlotBackgroundColor,
    Color? focusedSlotBackgroundColor,
    Color? focusedSlotBorderColor,
    double? focusedSlotBorderWidth,
    BoxDecoration? focusedSlotDecoration,
    Color? dropTargetOverlayValidColor,
    Color? dropTargetOverlayInvalidColor,
    double? dropTargetOverlayBorderWidth,
    Color? dropTargetOverlayBorderColor,
    Color? disabledTimeSlotColor,
    double? resizeHandleSize,
    int? minResizeDurationMinutes,
    double? resizeHandleVisualHeight,
    double? resizeHandleHorizontalMargin,
    double? resizeHandleBorderRadius,
    // AllDayTileThemeMixin + AllDaySectionThemeMixin
    Color? allDayEventBackgroundColor,
    TextStyle? allDayEventTextStyle,
    Color? allDayEventBorderColor,
    double? allDayEventBorderWidth,
    double? allDayTileWidth,
    double? allDayTileHeight,
    EdgeInsets? allDayEventPadding,
    double? allDayOverflowIndicatorWidth,
    double? allDayWrapSpacing,
    double? allDayWrapRunSpacing,
    EdgeInsets? allDaySectionPadding,
    double? allDayOverflowHandleWidth,
    double? allDayOverflowHandleHeight,
    double? allDayOverflowHandleBorderRadius,
    double? allDayOverflowHandleGap,
    double? allDayOverflowIndicatorFontSize,
    double? allDayOverflowIndicatorBorderWidth,
    double? allDaySectionLabelBottomPadding,
    // Day-View-specific own
    TextStyle? dayHeaderDayOfWeekStyle,
    TextStyle? dayHeaderDateStyle,
    EdgeInsets? dayHeaderPadding,
    EdgeInsets? dayHeaderWeekNumberPadding,
    double? dayHeaderWeekNumberBorderRadius,
    double? dayHeaderSpacing,
  }) {
    return MCalDayViewThemeData(
      // EventTileThemeMixin
      eventTileBackgroundColor: eventTileBackgroundColor ?? this.eventTileBackgroundColor,
      eventTileTextStyle: eventTileTextStyle ?? this.eventTileTextStyle,
      eventTileCornerRadius: eventTileCornerRadius ?? this.eventTileCornerRadius,
      eventTileHorizontalSpacing: eventTileHorizontalSpacing ?? this.eventTileHorizontalSpacing,
      eventTileBorderWidth: eventTileBorderWidth ?? this.eventTileBorderWidth,
      eventTileBorderColor: eventTileBorderColor ?? this.eventTileBorderColor,
      hoverEventBackgroundColor: hoverEventBackgroundColor ?? this.hoverEventBackgroundColor,
      eventTileLightContrastColor: eventTileLightContrastColor ?? this.eventTileLightContrastColor,
      eventTileDarkContrastColor: eventTileDarkContrastColor ?? this.eventTileDarkContrastColor,
      weekNumberTextStyle: weekNumberTextStyle ?? this.weekNumberTextStyle,
      weekNumberBackgroundColor: weekNumberBackgroundColor ?? this.weekNumberBackgroundColor,
      dropTargetTileBackgroundColor: dropTargetTileBackgroundColor ?? this.dropTargetTileBackgroundColor,
      dropTargetTileInvalidBackgroundColor: dropTargetTileInvalidBackgroundColor ?? this.dropTargetTileInvalidBackgroundColor,
      dropTargetTileCornerRadius: dropTargetTileCornerRadius ?? this.dropTargetTileCornerRadius,
      dropTargetTileBorderColor: dropTargetTileBorderColor ?? this.dropTargetTileBorderColor,
      dropTargetTileBorderWidth: dropTargetTileBorderWidth ?? this.dropTargetTileBorderWidth,
      resizeHandleColor: resizeHandleColor ?? this.resizeHandleColor,
      keyboardSelectionBorderWidth:
          keyboardSelectionBorderWidth ?? this.keyboardSelectionBorderWidth,
      keyboardSelectionBorderColor:
          keyboardSelectionBorderColor ?? this.keyboardSelectionBorderColor,
      keyboardSelectionBorderRadius:
          keyboardSelectionBorderRadius ?? this.keyboardSelectionBorderRadius,
      keyboardHighlightBorderWidth:
          keyboardHighlightBorderWidth ?? this.keyboardHighlightBorderWidth,
      keyboardHighlightBorderColor:
          keyboardHighlightBorderColor ?? this.keyboardHighlightBorderColor,
      keyboardHighlightBorderRadius:
          keyboardHighlightBorderRadius ?? this.keyboardHighlightBorderRadius,
      // TimeGridThemeMixin
      timeLegendWidth: timeLegendWidth ?? this.timeLegendWidth,
      timeLegendTextStyle: timeLegendTextStyle ?? this.timeLegendTextStyle,
      timeLegendBackgroundColor: timeLegendBackgroundColor ?? this.timeLegendBackgroundColor,
      timeLegendTickColor: timeLegendTickColor ?? this.timeLegendTickColor,
      timeLegendTickWidth: timeLegendTickWidth ?? this.timeLegendTickWidth,
      timeLegendTickLength: timeLegendTickLength ?? this.timeLegendTickLength,
      showTimeLegendTicks: showTimeLegendTicks ?? this.showTimeLegendTicks,
      timeLabelPosition: timeLabelPosition ?? this.timeLabelPosition,
      timeLegendLabelHeight: timeLegendLabelHeight ?? this.timeLegendLabelHeight,
      hourGridlineColor: hourGridlineColor ?? this.hourGridlineColor,
      hourGridlineWidth: hourGridlineWidth ?? this.hourGridlineWidth,
      majorGridlineColor: majorGridlineColor ?? this.majorGridlineColor,
      majorGridlineWidth: majorGridlineWidth ?? this.majorGridlineWidth,
      minorGridlineColor: minorGridlineColor ?? this.minorGridlineColor,
      minorGridlineWidth: minorGridlineWidth ?? this.minorGridlineWidth,
      currentTimeIndicatorColor: currentTimeIndicatorColor ?? this.currentTimeIndicatorColor,
      currentTimeIndicatorWidth: currentTimeIndicatorWidth ?? this.currentTimeIndicatorWidth,
      currentTimeIndicatorDotRadius: currentTimeIndicatorDotRadius ?? this.currentTimeIndicatorDotRadius,
      specialTimeRegionColor: specialTimeRegionColor ?? this.specialTimeRegionColor,
      blockedTimeRegionColor: blockedTimeRegionColor ?? this.blockedTimeRegionColor,
      timeRegionBorderColor: timeRegionBorderColor ?? this.timeRegionBorderColor,
      timeRegionTextColor: timeRegionTextColor ?? this.timeRegionTextColor,
      timeRegionTextStyle: timeRegionTextStyle ?? this.timeRegionTextStyle,
      timeRegionBorderWidth: timeRegionBorderWidth ?? this.timeRegionBorderWidth,
      timeRegionIconSize: timeRegionIconSize ?? this.timeRegionIconSize,
      timeRegionIconGap: timeRegionIconGap ?? this.timeRegionIconGap,
      timedEventMinHeight: timedEventMinHeight ?? this.timedEventMinHeight,
      timedEventPadding: timedEventPadding ?? this.timedEventPadding,
      timedEventMargin: timedEventMargin ?? this.timedEventMargin,
      timedEventCompactFontSize: timedEventCompactFontSize ?? this.timedEventCompactFontSize,
      timedEventNormalFontSize: timedEventNormalFontSize ?? this.timedEventNormalFontSize,
      timedEventTitleTimeGap: timedEventTitleTimeGap ?? this.timedEventTitleTimeGap,
      hoverTimeSlotBackgroundColor: hoverTimeSlotBackgroundColor ?? this.hoverTimeSlotBackgroundColor,
      focusedSlotBackgroundColor: focusedSlotBackgroundColor ?? this.focusedSlotBackgroundColor,
      focusedSlotBorderColor: focusedSlotBorderColor ?? this.focusedSlotBorderColor,
      focusedSlotBorderWidth: focusedSlotBorderWidth ?? this.focusedSlotBorderWidth,
      focusedSlotDecoration: focusedSlotDecoration ?? this.focusedSlotDecoration,
      dropTargetOverlayValidColor: dropTargetOverlayValidColor ?? this.dropTargetOverlayValidColor,
      dropTargetOverlayInvalidColor: dropTargetOverlayInvalidColor ?? this.dropTargetOverlayInvalidColor,
      dropTargetOverlayBorderWidth: dropTargetOverlayBorderWidth ?? this.dropTargetOverlayBorderWidth,
      dropTargetOverlayBorderColor: dropTargetOverlayBorderColor ?? this.dropTargetOverlayBorderColor,
      disabledTimeSlotColor: disabledTimeSlotColor ?? this.disabledTimeSlotColor,
      resizeHandleSize: resizeHandleSize ?? this.resizeHandleSize,
      minResizeDurationMinutes: minResizeDurationMinutes ?? this.minResizeDurationMinutes,
      resizeHandleVisualHeight: resizeHandleVisualHeight ?? this.resizeHandleVisualHeight,
      resizeHandleHorizontalMargin: resizeHandleHorizontalMargin ?? this.resizeHandleHorizontalMargin,
      resizeHandleBorderRadius: resizeHandleBorderRadius ?? this.resizeHandleBorderRadius,
      // AllDayTileThemeMixin + AllDaySectionThemeMixin
      allDayEventBackgroundColor: allDayEventBackgroundColor ?? this.allDayEventBackgroundColor,
      allDayEventTextStyle: allDayEventTextStyle ?? this.allDayEventTextStyle,
      allDayEventBorderColor: allDayEventBorderColor ?? this.allDayEventBorderColor,
      allDayEventBorderWidth: allDayEventBorderWidth ?? this.allDayEventBorderWidth,
      allDayTileWidth: allDayTileWidth ?? this.allDayTileWidth,
      allDayTileHeight: allDayTileHeight ?? this.allDayTileHeight,
      allDayEventPadding: allDayEventPadding ?? this.allDayEventPadding,
      allDayOverflowIndicatorWidth: allDayOverflowIndicatorWidth ?? this.allDayOverflowIndicatorWidth,
      allDayWrapSpacing: allDayWrapSpacing ?? this.allDayWrapSpacing,
      allDayWrapRunSpacing: allDayWrapRunSpacing ?? this.allDayWrapRunSpacing,
      allDaySectionPadding: allDaySectionPadding ?? this.allDaySectionPadding,
      allDayOverflowHandleWidth: allDayOverflowHandleWidth ?? this.allDayOverflowHandleWidth,
      allDayOverflowHandleHeight: allDayOverflowHandleHeight ?? this.allDayOverflowHandleHeight,
      allDayOverflowHandleBorderRadius: allDayOverflowHandleBorderRadius ?? this.allDayOverflowHandleBorderRadius,
      allDayOverflowHandleGap: allDayOverflowHandleGap ?? this.allDayOverflowHandleGap,
      allDayOverflowIndicatorFontSize: allDayOverflowIndicatorFontSize ?? this.allDayOverflowIndicatorFontSize,
      allDayOverflowIndicatorBorderWidth: allDayOverflowIndicatorBorderWidth ?? this.allDayOverflowIndicatorBorderWidth,
      allDaySectionLabelBottomPadding: allDaySectionLabelBottomPadding ?? this.allDaySectionLabelBottomPadding,
      // Day-View-specific own
      dayHeaderDayOfWeekStyle: dayHeaderDayOfWeekStyle ?? this.dayHeaderDayOfWeekStyle,
      dayHeaderDateStyle: dayHeaderDateStyle ?? this.dayHeaderDateStyle,
      dayHeaderPadding: dayHeaderPadding ?? this.dayHeaderPadding,
      dayHeaderWeekNumberPadding: dayHeaderWeekNumberPadding ?? this.dayHeaderWeekNumberPadding,
      dayHeaderWeekNumberBorderRadius: dayHeaderWeekNumberBorderRadius ?? this.dayHeaderWeekNumberBorderRadius,
      dayHeaderSpacing: dayHeaderSpacing ?? this.dayHeaderSpacing,
    );
  }

  /// Linearly interpolates between this theme and [other] by [t].
  MCalDayViewThemeData lerp(MCalDayViewThemeData? other, double t) {
    if (other == null) return this;

    return MCalDayViewThemeData(
      // EventTileThemeMixin
      eventTileBackgroundColor: Color.lerp(eventTileBackgroundColor, other.eventTileBackgroundColor, t),
      eventTileTextStyle: TextStyle.lerp(eventTileTextStyle, other.eventTileTextStyle, t),
      eventTileCornerRadius: _lerpDouble(eventTileCornerRadius, other.eventTileCornerRadius, t),
      eventTileHorizontalSpacing: _lerpDouble(eventTileHorizontalSpacing, other.eventTileHorizontalSpacing, t),
      eventTileBorderWidth: _lerpDouble(eventTileBorderWidth, other.eventTileBorderWidth, t),
      eventTileBorderColor: Color.lerp(eventTileBorderColor, other.eventTileBorderColor, t),
      hoverEventBackgroundColor: Color.lerp(hoverEventBackgroundColor, other.hoverEventBackgroundColor, t),
      eventTileLightContrastColor: Color.lerp(eventTileLightContrastColor, other.eventTileLightContrastColor, t),
      eventTileDarkContrastColor: Color.lerp(eventTileDarkContrastColor, other.eventTileDarkContrastColor, t),
      weekNumberTextStyle: TextStyle.lerp(weekNumberTextStyle, other.weekNumberTextStyle, t),
      weekNumberBackgroundColor: Color.lerp(weekNumberBackgroundColor, other.weekNumberBackgroundColor, t),
      dropTargetTileBackgroundColor: Color.lerp(dropTargetTileBackgroundColor, other.dropTargetTileBackgroundColor, t),
      dropTargetTileInvalidBackgroundColor: Color.lerp(dropTargetTileInvalidBackgroundColor, other.dropTargetTileInvalidBackgroundColor, t),
      dropTargetTileCornerRadius: _lerpDouble(dropTargetTileCornerRadius, other.dropTargetTileCornerRadius, t),
      dropTargetTileBorderColor: Color.lerp(dropTargetTileBorderColor, other.dropTargetTileBorderColor, t),
      dropTargetTileBorderWidth: _lerpDouble(dropTargetTileBorderWidth, other.dropTargetTileBorderWidth, t),
      resizeHandleColor: Color.lerp(resizeHandleColor, other.resizeHandleColor, t),
      keyboardSelectionBorderWidth:
          _lerpDouble(keyboardSelectionBorderWidth, other.keyboardSelectionBorderWidth, t),
      keyboardSelectionBorderColor:
          Color.lerp(keyboardSelectionBorderColor, other.keyboardSelectionBorderColor, t),
      keyboardSelectionBorderRadius:
          _lerpDouble(keyboardSelectionBorderRadius, other.keyboardSelectionBorderRadius, t),
      keyboardHighlightBorderWidth:
          _lerpDouble(keyboardHighlightBorderWidth, other.keyboardHighlightBorderWidth, t),
      keyboardHighlightBorderColor:
          Color.lerp(keyboardHighlightBorderColor, other.keyboardHighlightBorderColor, t),
      keyboardHighlightBorderRadius:
          _lerpDouble(keyboardHighlightBorderRadius, other.keyboardHighlightBorderRadius, t),
      // TimeGridThemeMixin
      timeLegendWidth: _lerpDouble(timeLegendWidth, other.timeLegendWidth, t),
      timeLegendTextStyle: TextStyle.lerp(timeLegendTextStyle, other.timeLegendTextStyle, t),
      timeLegendBackgroundColor: Color.lerp(timeLegendBackgroundColor, other.timeLegendBackgroundColor, t),
      timeLegendTickColor: Color.lerp(timeLegendTickColor, other.timeLegendTickColor, t),
      timeLegendTickWidth: _lerpDouble(timeLegendTickWidth, other.timeLegendTickWidth, t),
      timeLegendTickLength: _lerpDouble(timeLegendTickLength, other.timeLegendTickLength, t),
      showTimeLegendTicks: t < 0.5 ? showTimeLegendTicks : other.showTimeLegendTicks,
      timeLabelPosition: t < 0.5 ? timeLabelPosition : other.timeLabelPosition,
      timeLegendLabelHeight: _lerpDouble(timeLegendLabelHeight, other.timeLegendLabelHeight, t),
      hourGridlineColor: Color.lerp(hourGridlineColor, other.hourGridlineColor, t),
      hourGridlineWidth: _lerpDouble(hourGridlineWidth, other.hourGridlineWidth, t),
      majorGridlineColor: Color.lerp(majorGridlineColor, other.majorGridlineColor, t),
      majorGridlineWidth: _lerpDouble(majorGridlineWidth, other.majorGridlineWidth, t),
      minorGridlineColor: Color.lerp(minorGridlineColor, other.minorGridlineColor, t),
      minorGridlineWidth: _lerpDouble(minorGridlineWidth, other.minorGridlineWidth, t),
      currentTimeIndicatorColor: Color.lerp(currentTimeIndicatorColor, other.currentTimeIndicatorColor, t),
      currentTimeIndicatorWidth: _lerpDouble(currentTimeIndicatorWidth, other.currentTimeIndicatorWidth, t),
      currentTimeIndicatorDotRadius: _lerpDouble(currentTimeIndicatorDotRadius, other.currentTimeIndicatorDotRadius, t),
      specialTimeRegionColor: Color.lerp(specialTimeRegionColor, other.specialTimeRegionColor, t),
      blockedTimeRegionColor: Color.lerp(blockedTimeRegionColor, other.blockedTimeRegionColor, t),
      timeRegionBorderColor: Color.lerp(timeRegionBorderColor, other.timeRegionBorderColor, t),
      timeRegionTextColor: Color.lerp(timeRegionTextColor, other.timeRegionTextColor, t),
      timeRegionTextStyle: TextStyle.lerp(timeRegionTextStyle, other.timeRegionTextStyle, t),
      timeRegionBorderWidth: _lerpDouble(timeRegionBorderWidth, other.timeRegionBorderWidth, t),
      timeRegionIconSize: _lerpDouble(timeRegionIconSize, other.timeRegionIconSize, t),
      timeRegionIconGap: _lerpDouble(timeRegionIconGap, other.timeRegionIconGap, t),
      timedEventMinHeight: _lerpDouble(timedEventMinHeight, other.timedEventMinHeight, t),
      timedEventPadding: EdgeInsets.lerp(timedEventPadding, other.timedEventPadding, t),
      timedEventMargin: EdgeInsets.lerp(timedEventMargin, other.timedEventMargin, t),
      timedEventCompactFontSize: _lerpDouble(timedEventCompactFontSize, other.timedEventCompactFontSize, t),
      timedEventNormalFontSize: _lerpDouble(timedEventNormalFontSize, other.timedEventNormalFontSize, t),
      timedEventTitleTimeGap: _lerpDouble(timedEventTitleTimeGap, other.timedEventTitleTimeGap, t),
      hoverTimeSlotBackgroundColor: Color.lerp(hoverTimeSlotBackgroundColor, other.hoverTimeSlotBackgroundColor, t),
      focusedSlotBackgroundColor: Color.lerp(focusedSlotBackgroundColor, other.focusedSlotBackgroundColor, t),
      focusedSlotBorderColor: Color.lerp(focusedSlotBorderColor, other.focusedSlotBorderColor, t),
      focusedSlotBorderWidth: _lerpDouble(focusedSlotBorderWidth, other.focusedSlotBorderWidth, t),
      focusedSlotDecoration: t < 0.5 ? focusedSlotDecoration : other.focusedSlotDecoration,
      dropTargetOverlayValidColor: Color.lerp(dropTargetOverlayValidColor, other.dropTargetOverlayValidColor, t),
      dropTargetOverlayInvalidColor: Color.lerp(dropTargetOverlayInvalidColor, other.dropTargetOverlayInvalidColor, t),
      dropTargetOverlayBorderWidth: _lerpDouble(dropTargetOverlayBorderWidth, other.dropTargetOverlayBorderWidth, t),
      dropTargetOverlayBorderColor: Color.lerp(dropTargetOverlayBorderColor, other.dropTargetOverlayBorderColor, t),
      disabledTimeSlotColor: Color.lerp(disabledTimeSlotColor, other.disabledTimeSlotColor, t),
      resizeHandleSize: _lerpDouble(resizeHandleSize, other.resizeHandleSize, t),
      minResizeDurationMinutes: t < 0.5 ? minResizeDurationMinutes : other.minResizeDurationMinutes,
      resizeHandleVisualHeight: _lerpDouble(resizeHandleVisualHeight, other.resizeHandleVisualHeight, t),
      resizeHandleHorizontalMargin: _lerpDouble(resizeHandleHorizontalMargin, other.resizeHandleHorizontalMargin, t),
      resizeHandleBorderRadius: _lerpDouble(resizeHandleBorderRadius, other.resizeHandleBorderRadius, t),
      // AllDayTileThemeMixin + AllDaySectionThemeMixin
      allDayEventBackgroundColor: Color.lerp(allDayEventBackgroundColor, other.allDayEventBackgroundColor, t),
      allDayEventTextStyle: TextStyle.lerp(allDayEventTextStyle, other.allDayEventTextStyle, t),
      allDayEventBorderColor: Color.lerp(allDayEventBorderColor, other.allDayEventBorderColor, t),
      allDayEventBorderWidth: _lerpDouble(allDayEventBorderWidth, other.allDayEventBorderWidth, t),
      allDayTileWidth: _lerpDouble(allDayTileWidth, other.allDayTileWidth, t),
      allDayTileHeight: _lerpDouble(allDayTileHeight, other.allDayTileHeight, t),
      allDayEventPadding: EdgeInsets.lerp(allDayEventPadding, other.allDayEventPadding, t),
      allDayOverflowIndicatorWidth: _lerpDouble(allDayOverflowIndicatorWidth, other.allDayOverflowIndicatorWidth, t),
      allDayWrapSpacing: _lerpDouble(allDayWrapSpacing, other.allDayWrapSpacing, t),
      allDayWrapRunSpacing: _lerpDouble(allDayWrapRunSpacing, other.allDayWrapRunSpacing, t),
      allDaySectionPadding: EdgeInsets.lerp(allDaySectionPadding, other.allDaySectionPadding, t),
      allDayOverflowHandleWidth: _lerpDouble(allDayOverflowHandleWidth, other.allDayOverflowHandleWidth, t),
      allDayOverflowHandleHeight: _lerpDouble(allDayOverflowHandleHeight, other.allDayOverflowHandleHeight, t),
      allDayOverflowHandleBorderRadius: _lerpDouble(allDayOverflowHandleBorderRadius, other.allDayOverflowHandleBorderRadius, t),
      allDayOverflowHandleGap: _lerpDouble(allDayOverflowHandleGap, other.allDayOverflowHandleGap, t),
      allDayOverflowIndicatorFontSize: _lerpDouble(allDayOverflowIndicatorFontSize, other.allDayOverflowIndicatorFontSize, t),
      allDayOverflowIndicatorBorderWidth: _lerpDouble(allDayOverflowIndicatorBorderWidth, other.allDayOverflowIndicatorBorderWidth, t),
      allDaySectionLabelBottomPadding: _lerpDouble(allDaySectionLabelBottomPadding, other.allDaySectionLabelBottomPadding, t),
      // Day-View-specific own
      dayHeaderDayOfWeekStyle: TextStyle.lerp(dayHeaderDayOfWeekStyle, other.dayHeaderDayOfWeekStyle, t),
      dayHeaderDateStyle: TextStyle.lerp(dayHeaderDateStyle, other.dayHeaderDateStyle, t),
      dayHeaderPadding: EdgeInsets.lerp(dayHeaderPadding, other.dayHeaderPadding, t),
      dayHeaderWeekNumberPadding: EdgeInsets.lerp(dayHeaderWeekNumberPadding, other.dayHeaderWeekNumberPadding, t),
      dayHeaderWeekNumberBorderRadius: _lerpDouble(dayHeaderWeekNumberBorderRadius, other.dayHeaderWeekNumberBorderRadius, t),
      dayHeaderSpacing: _lerpDouble(dayHeaderSpacing, other.dayHeaderSpacing, t),
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
      other is MCalDayViewThemeData &&
          runtimeType == other.runtimeType &&
          // EventTileThemeMixin
          eventTileBackgroundColor == other.eventTileBackgroundColor &&
          eventTileTextStyle == other.eventTileTextStyle &&
          eventTileCornerRadius == other.eventTileCornerRadius &&
          eventTileHorizontalSpacing == other.eventTileHorizontalSpacing &&
          eventTileBorderWidth == other.eventTileBorderWidth &&
          eventTileBorderColor == other.eventTileBorderColor &&
          hoverEventBackgroundColor == other.hoverEventBackgroundColor &&
          eventTileLightContrastColor == other.eventTileLightContrastColor &&
          eventTileDarkContrastColor == other.eventTileDarkContrastColor &&
          weekNumberTextStyle == other.weekNumberTextStyle &&
          weekNumberBackgroundColor == other.weekNumberBackgroundColor &&
          dropTargetTileBackgroundColor == other.dropTargetTileBackgroundColor &&
          dropTargetTileInvalidBackgroundColor == other.dropTargetTileInvalidBackgroundColor &&
          dropTargetTileCornerRadius == other.dropTargetTileCornerRadius &&
          dropTargetTileBorderColor == other.dropTargetTileBorderColor &&
          dropTargetTileBorderWidth == other.dropTargetTileBorderWidth &&
          resizeHandleColor == other.resizeHandleColor &&
          keyboardSelectionBorderWidth == other.keyboardSelectionBorderWidth &&
          keyboardSelectionBorderColor == other.keyboardSelectionBorderColor &&
          keyboardSelectionBorderRadius == other.keyboardSelectionBorderRadius &&
          keyboardHighlightBorderWidth == other.keyboardHighlightBorderWidth &&
          keyboardHighlightBorderColor == other.keyboardHighlightBorderColor &&
          keyboardHighlightBorderRadius == other.keyboardHighlightBorderRadius &&
          // TimeGridThemeMixin
          timeLegendWidth == other.timeLegendWidth &&
          timeLegendTextStyle == other.timeLegendTextStyle &&
          timeLegendBackgroundColor == other.timeLegendBackgroundColor &&
          timeLegendTickColor == other.timeLegendTickColor &&
          timeLegendTickWidth == other.timeLegendTickWidth &&
          timeLegendTickLength == other.timeLegendTickLength &&
          showTimeLegendTicks == other.showTimeLegendTicks &&
          timeLabelPosition == other.timeLabelPosition &&
          timeLegendLabelHeight == other.timeLegendLabelHeight &&
          hourGridlineColor == other.hourGridlineColor &&
          hourGridlineWidth == other.hourGridlineWidth &&
          majorGridlineColor == other.majorGridlineColor &&
          majorGridlineWidth == other.majorGridlineWidth &&
          minorGridlineColor == other.minorGridlineColor &&
          minorGridlineWidth == other.minorGridlineWidth &&
          currentTimeIndicatorColor == other.currentTimeIndicatorColor &&
          currentTimeIndicatorWidth == other.currentTimeIndicatorWidth &&
          currentTimeIndicatorDotRadius == other.currentTimeIndicatorDotRadius &&
          specialTimeRegionColor == other.specialTimeRegionColor &&
          blockedTimeRegionColor == other.blockedTimeRegionColor &&
          timeRegionBorderColor == other.timeRegionBorderColor &&
          timeRegionTextColor == other.timeRegionTextColor &&
          timeRegionTextStyle == other.timeRegionTextStyle &&
          timeRegionBorderWidth == other.timeRegionBorderWidth &&
          timeRegionIconSize == other.timeRegionIconSize &&
          timeRegionIconGap == other.timeRegionIconGap &&
          timedEventMinHeight == other.timedEventMinHeight &&
          timedEventPadding == other.timedEventPadding &&
          timedEventMargin == other.timedEventMargin &&
          timedEventCompactFontSize == other.timedEventCompactFontSize &&
          timedEventNormalFontSize == other.timedEventNormalFontSize &&
          timedEventTitleTimeGap == other.timedEventTitleTimeGap &&
          hoverTimeSlotBackgroundColor == other.hoverTimeSlotBackgroundColor &&
          focusedSlotBackgroundColor == other.focusedSlotBackgroundColor &&
          focusedSlotBorderColor == other.focusedSlotBorderColor &&
          focusedSlotBorderWidth == other.focusedSlotBorderWidth &&
          focusedSlotDecoration == other.focusedSlotDecoration &&
          dropTargetOverlayValidColor == other.dropTargetOverlayValidColor &&
          dropTargetOverlayInvalidColor == other.dropTargetOverlayInvalidColor &&
          dropTargetOverlayBorderWidth == other.dropTargetOverlayBorderWidth &&
          dropTargetOverlayBorderColor == other.dropTargetOverlayBorderColor &&
          disabledTimeSlotColor == other.disabledTimeSlotColor &&
          resizeHandleSize == other.resizeHandleSize &&
          minResizeDurationMinutes == other.minResizeDurationMinutes &&
          resizeHandleVisualHeight == other.resizeHandleVisualHeight &&
          resizeHandleHorizontalMargin == other.resizeHandleHorizontalMargin &&
          resizeHandleBorderRadius == other.resizeHandleBorderRadius &&
          // AllDayTileThemeMixin + AllDaySectionThemeMixin
          allDayEventBackgroundColor == other.allDayEventBackgroundColor &&
          allDayEventTextStyle == other.allDayEventTextStyle &&
          allDayEventBorderColor == other.allDayEventBorderColor &&
          allDayEventBorderWidth == other.allDayEventBorderWidth &&
          allDayTileWidth == other.allDayTileWidth &&
          allDayTileHeight == other.allDayTileHeight &&
          allDayEventPadding == other.allDayEventPadding &&
          allDayOverflowIndicatorWidth == other.allDayOverflowIndicatorWidth &&
          allDayWrapSpacing == other.allDayWrapSpacing &&
          allDayWrapRunSpacing == other.allDayWrapRunSpacing &&
          allDaySectionPadding == other.allDaySectionPadding &&
          allDayOverflowHandleWidth == other.allDayOverflowHandleWidth &&
          allDayOverflowHandleHeight == other.allDayOverflowHandleHeight &&
          allDayOverflowHandleBorderRadius == other.allDayOverflowHandleBorderRadius &&
          allDayOverflowHandleGap == other.allDayOverflowHandleGap &&
          allDayOverflowIndicatorFontSize == other.allDayOverflowIndicatorFontSize &&
          allDayOverflowIndicatorBorderWidth == other.allDayOverflowIndicatorBorderWidth &&
          allDaySectionLabelBottomPadding == other.allDaySectionLabelBottomPadding &&
          // Day-View-specific own
          dayHeaderDayOfWeekStyle == other.dayHeaderDayOfWeekStyle &&
          dayHeaderDateStyle == other.dayHeaderDateStyle &&
          dayHeaderPadding == other.dayHeaderPadding &&
          dayHeaderWeekNumberPadding == other.dayHeaderWeekNumberPadding &&
          dayHeaderWeekNumberBorderRadius == other.dayHeaderWeekNumberBorderRadius &&
          dayHeaderSpacing == other.dayHeaderSpacing;

  @override
  int get hashCode => Object.hashAll([
        // EventTileThemeMixin
        eventTileBackgroundColor,
        eventTileTextStyle,
        eventTileCornerRadius,
        eventTileHorizontalSpacing,
        eventTileBorderWidth,
        eventTileBorderColor,
        hoverEventBackgroundColor,
        eventTileLightContrastColor,
        eventTileDarkContrastColor,
        weekNumberTextStyle,
        weekNumberBackgroundColor,
        dropTargetTileBackgroundColor,
        dropTargetTileInvalidBackgroundColor,
        dropTargetTileCornerRadius,
        dropTargetTileBorderColor,
        dropTargetTileBorderWidth,
        resizeHandleColor,
        keyboardSelectionBorderWidth,
        keyboardSelectionBorderColor,
        keyboardSelectionBorderRadius,
        keyboardHighlightBorderWidth,
        keyboardHighlightBorderColor,
        keyboardHighlightBorderRadius,
        // TimeGridThemeMixin
        timeLegendWidth,
        timeLegendTextStyle,
        timeLegendBackgroundColor,
        timeLegendTickColor,
        timeLegendTickWidth,
        timeLegendTickLength,
        showTimeLegendTicks,
        timeLabelPosition,
        timeLegendLabelHeight,
        hourGridlineColor,
        hourGridlineWidth,
        majorGridlineColor,
        majorGridlineWidth,
        minorGridlineColor,
        minorGridlineWidth,
        currentTimeIndicatorColor,
        currentTimeIndicatorWidth,
        currentTimeIndicatorDotRadius,
        specialTimeRegionColor,
        blockedTimeRegionColor,
        timeRegionBorderColor,
        timeRegionTextColor,
        timeRegionTextStyle,
        timeRegionBorderWidth,
        timeRegionIconSize,
        timeRegionIconGap,
        timedEventMinHeight,
        timedEventPadding,
        timedEventMargin,
        timedEventCompactFontSize,
        timedEventNormalFontSize,
        timedEventTitleTimeGap,
        hoverTimeSlotBackgroundColor,
        focusedSlotBackgroundColor,
        focusedSlotBorderColor,
        focusedSlotBorderWidth,
        focusedSlotDecoration,
        dropTargetOverlayValidColor,
        dropTargetOverlayInvalidColor,
        dropTargetOverlayBorderWidth,
        dropTargetOverlayBorderColor,
        disabledTimeSlotColor,
        resizeHandleSize,
        minResizeDurationMinutes,
        resizeHandleVisualHeight,
        resizeHandleHorizontalMargin,
        resizeHandleBorderRadius,
        // AllDayTileThemeMixin + AllDaySectionThemeMixin
        allDayEventBackgroundColor,
        allDayEventTextStyle,
        allDayEventBorderColor,
        allDayEventBorderWidth,
        allDayTileWidth,
        allDayTileHeight,
        allDayEventPadding,
        allDayOverflowIndicatorWidth,
        allDayWrapSpacing,
        allDayWrapRunSpacing,
        allDaySectionPadding,
        allDayOverflowHandleWidth,
        allDayOverflowHandleHeight,
        allDayOverflowHandleBorderRadius,
        allDayOverflowHandleGap,
        allDayOverflowIndicatorFontSize,
        allDayOverflowIndicatorBorderWidth,
        allDaySectionLabelBottomPadding,
        // Day-View-specific own
        dayHeaderDayOfWeekStyle,
        dayHeaderDateStyle,
        dayHeaderPadding,
        dayHeaderWeekNumberPadding,
        dayHeaderWeekNumberBorderRadius,
        dayHeaderSpacing,
      ]);
}
