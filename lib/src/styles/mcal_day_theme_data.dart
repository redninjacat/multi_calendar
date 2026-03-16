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

  /// Fixed width for all-day event tiles in the Day View (in pixels).
  ///
  /// Using a fixed width enables deterministic layout: the number of tiles
  /// per row is computed as `(availableWidth + spacing) / (tileWidth + spacing)`,
  /// eliminating dependence on font metrics or content length.
  ///
  /// Defaults to 120.0.
  final double? allDayTileWidth;

  /// Fixed height for all-day event tiles in the Day View (in pixels).
  ///
  /// Defaults to 28.0.
  final double? allDayTileHeight;

  /// Inner content padding for all-day event tiles in the Day View.
  ///
  /// Controls the space between the tile border and its content.
  /// When null, the master defaults use
  /// `EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0)`.
  final EdgeInsets? allDayEventPadding;

  /// Fixed width for the all-day overflow indicator in the Day View (in pixels).
  ///
  /// The overflow indicator occupies one tile slot in the Wrap layout.
  /// Its height matches [allDayTileHeight].
  ///
  /// Defaults to 80.0.
  final double? allDayOverflowIndicatorWidth;

  /// Minimum height for timed event tiles in Day View (in pixels).
  final double? timedEventMinHeight;

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

  /// Background color for the focused time slot in Navigation Mode.
  ///
  /// Applied to the time slot that currently holds keyboard focus when the user
  /// is navigating with the keyboard in Navigation Mode. Provides a simple way
  /// to indicate focus without a full [BoxDecoration].
  ///
  /// When both [focusedSlotBackgroundColor] and [focusedSlotDecoration] are
  /// set, [focusedSlotDecoration] takes precedence.
  ///
  /// When null, the master defaults derive this from
  /// `colorScheme.primary.withValues(alpha: 0.08)`.
  final Color? focusedSlotBackgroundColor;

  /// Decoration for the focused time slot in Navigation Mode.
  ///
  /// Applied to the time slot that currently holds keyboard focus when the user
  /// is navigating with the keyboard in Navigation Mode. Provides full control
  /// over the focus indicator via [BoxDecoration] (border, gradient, etc.).
  ///
  /// Takes precedence over [focusedSlotBackgroundColor] when both are set.
  ///
  /// When null, falls back to [focusedSlotBackgroundColor] or the default focus
  /// indicator.
  final BoxDecoration? focusedSlotDecoration;

  // ── Drop target tile properties (Req 3) ──────────────────────────────────

  /// Background color for valid drop target preview tiles in Day View.
  ///
  /// When null, the master defaults use `colorScheme.primaryContainer`.
  final Color? dropTargetTileBackgroundColor;

  /// Background color for invalid drop target preview tiles in Day View.
  ///
  /// Uses M3's `colorScheme.errorContainer` (less-emphasized error role) to
  /// signal invalid drops without full error weight. When null, the master
  /// defaults derive this from the app's color scheme.
  final Color? dropTargetTileInvalidBackgroundColor;

  /// Corner radius for drop target preview tiles in Day View (in pixels).
  ///
  /// When null, the master defaults fall through to the shared
  /// `eventTileCornerRadius` on [MCalThemeData] per Req 3.3.
  final double? dropTargetTileCornerRadius;

  /// Border color for drop target preview tiles in Day View.
  ///
  /// When null, the master defaults use `colorScheme.primary`.
  final Color? dropTargetTileBorderColor;

  /// Border width for drop target preview tiles in Day View (in pixels).
  ///
  /// When null, the master defaults use `2.0`.
  final double? dropTargetTileBorderWidth;

  // ── Drop target overlay properties (Req 4) ───────────────────────────────

  /// Color for the valid drop target overlay in Day View (Layer 4).
  ///
  /// Applied as a semi-transparent fill over the time slot column during
  /// a valid drag. When null, the master defaults use
  /// `colorScheme.primary.withValues(alpha: 0.2)`.
  final Color? dropTargetOverlayValidColor;

  /// Color for the invalid drop target overlay in Day View (Layer 4).
  ///
  /// Applied as a semi-transparent fill during an invalid drag. When null,
  /// the master defaults use `colorScheme.error.withValues(alpha: 0.2)`.
  final Color? dropTargetOverlayInvalidColor;

  /// Width of the left accent bar on the drop target overlay (in pixels).
  ///
  /// When null, the master defaults use `3.0`.
  final double? dropTargetOverlayBorderWidth;

  /// Color of the left accent bar on the drop target overlay.
  ///
  /// When null, the master defaults use `colorScheme.primary`.
  final Color? dropTargetOverlayBorderColor;

  // ── Remaining hardcoded color replacements (Req 9) ───────────────────────

  /// Color for the disabled time slot fill in Day View.
  ///
  /// Replaces the previously hardcoded `Colors.grey.withValues(alpha: 0.3)`.
  /// When null, the master defaults use
  /// `colorScheme.onSurface.withValues(alpha: 0.12)` (M3 disabled container).
  final Color? disabledTimeSlotColor;

  /// Color for resize handle indicators on timed event tiles.
  ///
  /// When null, the master defaults use `Colors.white.withValues(alpha: 0.7)`.
  final Color? resizeHandleColor;

  /// Border color for the keyboard focus ring on focused event tiles.
  ///
  /// Replaces direct `colorScheme.primary` access in tile builders.
  /// When null, the master defaults use `colorScheme.primary`.
  final Color? keyboardFocusBorderColor;

  /// Border color for the Navigation Mode focused time slot indicator.
  ///
  /// Replaces direct `colorScheme.primary` access in `_buildFocusedSlotIndicator`.
  /// When null, the master defaults use `colorScheme.primary`.
  final Color? focusedSlotBorderColor;

  /// Border width for the Navigation Mode focused time slot indicator (in pixels).
  ///
  /// When null, the master defaults use `3.0`.
  final double? focusedSlotBorderWidth;

  /// Creates a new [MCalDayThemeData] instance.
  const MCalDayThemeData({
    this.dayHeaderDayOfWeekStyle,
    this.dayHeaderDateStyle,
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
    this.allDayTileWidth,
    this.allDayTileHeight,
    this.allDayEventPadding,
    this.allDayOverflowIndicatorWidth,
    this.timedEventMinHeight,
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
    this.focusedSlotBackgroundColor,
    this.focusedSlotDecoration,
    this.dropTargetTileBackgroundColor,
    this.dropTargetTileInvalidBackgroundColor,
    this.dropTargetTileCornerRadius,
    this.dropTargetTileBorderColor,
    this.dropTargetTileBorderWidth,
    this.dropTargetOverlayValidColor,
    this.dropTargetOverlayInvalidColor,
    this.dropTargetOverlayBorderWidth,
    this.dropTargetOverlayBorderColor,
    this.disabledTimeSlotColor,
    this.resizeHandleColor,
    this.keyboardFocusBorderColor,
    this.focusedSlotBorderColor,
    this.focusedSlotBorderWidth,
  });

  /// Creates the **master defaults** for Day View theming from the provided [ThemeData].
  ///
  /// Called by [MCalThemeData.fromTheme] to populate [MCalThemeData.dayTheme].
  /// All returned properties are non-null and are derived from the theme's
  /// [ColorScheme] and [TextTheme] following Material 3 color roles.
  ///
  /// Do not call this directly in widget code — use
  /// `MCalThemeData.fromTheme(Theme.of(context)).dayTheme!` and the
  /// `theme.dayTheme?.property ?? defaults.dayTheme!.property!` pattern instead.
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
      timeLegendWidth: 60.0,
      timeLegendTextStyle:
          textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant) ??
          TextStyle(color: colorScheme.onSurfaceVariant),
      timeLegendBackgroundColor: colorScheme.surfaceContainerLow,
      showTimeLegendTicks: true,
      timeLegendTickColor: colorScheme.outlineVariant,
      timeLegendTickWidth: 1.0,
      timeLegendTickLength: 8.0,
      hourGridlineColor: colorScheme.outlineVariant,
      hourGridlineWidth: 1.0,
      majorGridlineColor: colorScheme.outlineVariant.withValues(alpha: 0.7),
      majorGridlineWidth: 1.0,
      minorGridlineColor: colorScheme.outlineVariant.withValues(alpha: 0.4),
      minorGridlineWidth: 0.5,
      currentTimeIndicatorColor: colorScheme.primary,
      currentTimeIndicatorWidth: 2.0,
      currentTimeIndicatorDotRadius: 6.0,
      allDayEventPadding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      timedEventMinHeight: 20.0,
      timedEventPadding: const EdgeInsets.all(2.0),
      specialTimeRegionColor:
          colorScheme.surfaceContainer.withValues(alpha: 0.5),
      blockedTimeRegionColor:
          colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
      timeRegionBorderColor: colorScheme.outlineVariant,
      timeRegionTextColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      timeRegionTextStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      ),
      resizeHandleSize: 8.0,
      minResizeDurationMinutes: 15,
      focusedSlotBackgroundColor:
          colorScheme.primary.withValues(alpha: 0.08),
      dropTargetTileBackgroundColor: colorScheme.primaryContainer,
      dropTargetTileInvalidBackgroundColor: colorScheme.errorContainer,
      dropTargetTileCornerRadius: 3.0,
      dropTargetTileBorderColor: colorScheme.primary,
      dropTargetTileBorderWidth: 2.0,
      dropTargetOverlayValidColor:
          colorScheme.primary.withValues(alpha: 0.2),
      dropTargetOverlayInvalidColor:
          colorScheme.error.withValues(alpha: 0.2),
      dropTargetOverlayBorderWidth: 3.0,
      dropTargetOverlayBorderColor: colorScheme.primary,
      disabledTimeSlotColor:
          colorScheme.onSurface.withValues(alpha: 0.12),
      resizeHandleColor: Colors.white.withValues(alpha: 0.7),
      keyboardFocusBorderColor: colorScheme.primary,
      focusedSlotBorderColor: colorScheme.primary,
      focusedSlotBorderWidth: 3.0,
    );
  }

  /// Creates a copy of this [MCalDayThemeData] with the given fields replaced.
  MCalDayThemeData copyWith({
    TextStyle? dayHeaderDayOfWeekStyle,
    TextStyle? dayHeaderDateStyle,
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
    double? allDayTileWidth,
    double? allDayTileHeight,
    EdgeInsets? allDayEventPadding,
    double? allDayOverflowIndicatorWidth,
    double? timedEventMinHeight,
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
    Color? focusedSlotBackgroundColor,
    BoxDecoration? focusedSlotDecoration,
    Color? dropTargetTileBackgroundColor,
    Color? dropTargetTileInvalidBackgroundColor,
    double? dropTargetTileCornerRadius,
    Color? dropTargetTileBorderColor,
    double? dropTargetTileBorderWidth,
    Color? dropTargetOverlayValidColor,
    Color? dropTargetOverlayInvalidColor,
    double? dropTargetOverlayBorderWidth,
    Color? dropTargetOverlayBorderColor,
    Color? disabledTimeSlotColor,
    Color? resizeHandleColor,
    Color? keyboardFocusBorderColor,
    Color? focusedSlotBorderColor,
    double? focusedSlotBorderWidth,
  }) {
    return MCalDayThemeData(
      dayHeaderDayOfWeekStyle:
          dayHeaderDayOfWeekStyle ?? this.dayHeaderDayOfWeekStyle,
      dayHeaderDateStyle: dayHeaderDateStyle ?? this.dayHeaderDateStyle,
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
      allDayTileWidth: allDayTileWidth ?? this.allDayTileWidth,
      allDayTileHeight: allDayTileHeight ?? this.allDayTileHeight,
      allDayEventPadding: allDayEventPadding ?? this.allDayEventPadding,
      allDayOverflowIndicatorWidth:
          allDayOverflowIndicatorWidth ?? this.allDayOverflowIndicatorWidth,
      timedEventMinHeight: timedEventMinHeight ?? this.timedEventMinHeight,
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
      focusedSlotBackgroundColor:
          focusedSlotBackgroundColor ?? this.focusedSlotBackgroundColor,
      focusedSlotDecoration:
          focusedSlotDecoration ?? this.focusedSlotDecoration,
      dropTargetTileBackgroundColor:
          dropTargetTileBackgroundColor ?? this.dropTargetTileBackgroundColor,
      dropTargetTileInvalidBackgroundColor: dropTargetTileInvalidBackgroundColor ??
          this.dropTargetTileInvalidBackgroundColor,
      dropTargetTileCornerRadius:
          dropTargetTileCornerRadius ?? this.dropTargetTileCornerRadius,
      dropTargetTileBorderColor:
          dropTargetTileBorderColor ?? this.dropTargetTileBorderColor,
      dropTargetTileBorderWidth:
          dropTargetTileBorderWidth ?? this.dropTargetTileBorderWidth,
      dropTargetOverlayValidColor:
          dropTargetOverlayValidColor ?? this.dropTargetOverlayValidColor,
      dropTargetOverlayInvalidColor:
          dropTargetOverlayInvalidColor ?? this.dropTargetOverlayInvalidColor,
      dropTargetOverlayBorderWidth:
          dropTargetOverlayBorderWidth ?? this.dropTargetOverlayBorderWidth,
      dropTargetOverlayBorderColor:
          dropTargetOverlayBorderColor ?? this.dropTargetOverlayBorderColor,
      disabledTimeSlotColor:
          disabledTimeSlotColor ?? this.disabledTimeSlotColor,
      resizeHandleColor: resizeHandleColor ?? this.resizeHandleColor,
      keyboardFocusBorderColor:
          keyboardFocusBorderColor ?? this.keyboardFocusBorderColor,
      focusedSlotBorderColor:
          focusedSlotBorderColor ?? this.focusedSlotBorderColor,
      focusedSlotBorderWidth:
          focusedSlotBorderWidth ?? this.focusedSlotBorderWidth,
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
      showTimeLegendTicks:
          t < 0.5 ? showTimeLegendTicks : other.showTimeLegendTicks,
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
      allDayTileWidth: _lerpDouble(
        allDayTileWidth,
        other.allDayTileWidth,
        t,
      ),
      allDayTileHeight: _lerpDouble(
        allDayTileHeight,
        other.allDayTileHeight,
        t,
      ),
      allDayEventPadding: EdgeInsets.lerp(
        allDayEventPadding,
        other.allDayEventPadding,
        t,
      ),
      allDayOverflowIndicatorWidth: _lerpDouble(
        allDayOverflowIndicatorWidth,
        other.allDayOverflowIndicatorWidth,
        t,
      ),
      timedEventMinHeight: _lerpDouble(
        timedEventMinHeight,
        other.timedEventMinHeight,
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
      focusedSlotBackgroundColor: Color.lerp(
        focusedSlotBackgroundColor,
        other.focusedSlotBackgroundColor,
        t,
      ),
      focusedSlotDecoration:
          t < 0.5 ? focusedSlotDecoration : other.focusedSlotDecoration,
      dropTargetTileBackgroundColor: Color.lerp(
        dropTargetTileBackgroundColor,
        other.dropTargetTileBackgroundColor,
        t,
      ),
      dropTargetTileInvalidBackgroundColor: Color.lerp(
        dropTargetTileInvalidBackgroundColor,
        other.dropTargetTileInvalidBackgroundColor,
        t,
      ),
      dropTargetTileCornerRadius: _lerpDouble(
        dropTargetTileCornerRadius,
        other.dropTargetTileCornerRadius,
        t,
      ),
      dropTargetTileBorderColor: Color.lerp(
        dropTargetTileBorderColor,
        other.dropTargetTileBorderColor,
        t,
      ),
      dropTargetTileBorderWidth: _lerpDouble(
        dropTargetTileBorderWidth,
        other.dropTargetTileBorderWidth,
        t,
      ),
      dropTargetOverlayValidColor: Color.lerp(
        dropTargetOverlayValidColor,
        other.dropTargetOverlayValidColor,
        t,
      ),
      dropTargetOverlayInvalidColor: Color.lerp(
        dropTargetOverlayInvalidColor,
        other.dropTargetOverlayInvalidColor,
        t,
      ),
      dropTargetOverlayBorderWidth: _lerpDouble(
        dropTargetOverlayBorderWidth,
        other.dropTargetOverlayBorderWidth,
        t,
      ),
      dropTargetOverlayBorderColor: Color.lerp(
        dropTargetOverlayBorderColor,
        other.dropTargetOverlayBorderColor,
        t,
      ),
      disabledTimeSlotColor: Color.lerp(
        disabledTimeSlotColor,
        other.disabledTimeSlotColor,
        t,
      ),
      resizeHandleColor: Color.lerp(
        resizeHandleColor,
        other.resizeHandleColor,
        t,
      ),
      keyboardFocusBorderColor: Color.lerp(
        keyboardFocusBorderColor,
        other.keyboardFocusBorderColor,
        t,
      ),
      focusedSlotBorderColor: Color.lerp(
        focusedSlotBorderColor,
        other.focusedSlotBorderColor,
        t,
      ),
      focusedSlotBorderWidth: _lerpDouble(
        focusedSlotBorderWidth,
        other.focusedSlotBorderWidth,
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
          currentTimeIndicatorDotRadius ==
              other.currentTimeIndicatorDotRadius &&
          allDayTileWidth == other.allDayTileWidth &&
          allDayTileHeight == other.allDayTileHeight &&
          allDayEventPadding == other.allDayEventPadding &&
          allDayOverflowIndicatorWidth ==
              other.allDayOverflowIndicatorWidth &&
          timedEventMinHeight == other.timedEventMinHeight &&
          timedEventPadding == other.timedEventPadding &&
          specialTimeRegionColor == other.specialTimeRegionColor &&
          blockedTimeRegionColor == other.blockedTimeRegionColor &&
          timeRegionBorderColor == other.timeRegionBorderColor &&
          timeRegionTextColor == other.timeRegionTextColor &&
          timeRegionTextStyle == other.timeRegionTextStyle &&
          resizeHandleSize == other.resizeHandleSize &&
          minResizeDurationMinutes == other.minResizeDurationMinutes &&
          timeLabelPosition == other.timeLabelPosition &&
          hoverTimeSlotBackgroundColor ==
              other.hoverTimeSlotBackgroundColor &&
          focusedSlotBackgroundColor == other.focusedSlotBackgroundColor &&
          focusedSlotDecoration == other.focusedSlotDecoration &&
          dropTargetTileBackgroundColor ==
              other.dropTargetTileBackgroundColor &&
          dropTargetTileInvalidBackgroundColor ==
              other.dropTargetTileInvalidBackgroundColor &&
          dropTargetTileCornerRadius == other.dropTargetTileCornerRadius &&
          dropTargetTileBorderColor == other.dropTargetTileBorderColor &&
          dropTargetTileBorderWidth == other.dropTargetTileBorderWidth &&
          dropTargetOverlayValidColor == other.dropTargetOverlayValidColor &&
          dropTargetOverlayInvalidColor ==
              other.dropTargetOverlayInvalidColor &&
          dropTargetOverlayBorderWidth ==
              other.dropTargetOverlayBorderWidth &&
          dropTargetOverlayBorderColor ==
              other.dropTargetOverlayBorderColor &&
          disabledTimeSlotColor == other.disabledTimeSlotColor &&
          resizeHandleColor == other.resizeHandleColor &&
          keyboardFocusBorderColor == other.keyboardFocusBorderColor &&
          focusedSlotBorderColor == other.focusedSlotBorderColor &&
          focusedSlotBorderWidth == other.focusedSlotBorderWidth;

  @override
  int get hashCode => Object.hashAll([
        dayHeaderDayOfWeekStyle,
        dayHeaderDateStyle,
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
        allDayTileWidth,
        allDayTileHeight,
        allDayEventPadding,
        allDayOverflowIndicatorWidth,
        timedEventMinHeight,
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
        focusedSlotBackgroundColor,
        focusedSlotDecoration,
        dropTargetTileBackgroundColor,
        dropTargetTileInvalidBackgroundColor,
        dropTargetTileCornerRadius,
        dropTargetTileBorderColor,
        dropTargetTileBorderWidth,
        dropTargetOverlayValidColor,
        dropTargetOverlayInvalidColor,
        dropTargetOverlayBorderWidth,
        dropTargetOverlayBorderColor,
        disabledTimeSlotColor,
        resizeHandleColor,
        keyboardFocusBorderColor,
        focusedSlotBorderColor,
        focusedSlotBorderWidth,
      ]);
}
