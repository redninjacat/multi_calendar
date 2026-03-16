import 'package:flutter/material.dart';
import '../widgets/mcal_month_week_layout_contexts.dart' show DateLabelPosition;

/// Theme data for Month View specific styling.
///
/// This class contains all properties that apply exclusively to [MCalMonthView],
/// such as weekday headers, date labels, event tile layout, and drag-and-drop
/// styling. Use [MCalMonthThemeData.defaults] to create a theme with Material 3
/// defaults.
///
/// Properties previously duplicated from [MCalThemeData] have been removed.
/// Access the following through the shared parent instead:
/// `cellBackgroundColor`, `allDayEventBackgroundColor`, `allDayEventTextStyle`,
/// `allDayEventBorderColor`, `allDayEventBorderWidth`, `weekNumberTextStyle`,
/// `weekNumberBackgroundColor`, `eventTileCornerRadius`,
/// `eventTileHorizontalSpacing`, `hoverEventBackgroundColor`.
///
/// Example:
/// ```dart
/// MCalThemeData(
///   monthTheme: MCalMonthThemeData(
///     eventTileHeight: 24.0,
///     dateLabelPosition: DateLabelPosition.topCenter,
///   ),
/// )
/// ```
class MCalMonthThemeData {
  /// Text style for day numbers in calendar cells.
  final TextStyle? cellTextStyle;

  /// Background color for the current day indicator.
  final Color? todayBackgroundColor;

  /// Text style for the current day number.
  final TextStyle? todayTextStyle;

  /// Text style for leading dates (days from previous month).
  final TextStyle? leadingDatesTextStyle;

  /// Text style for trailing dates (days from next month).
  final TextStyle? trailingDatesTextStyle;

  /// Background color for leading dates (days from previous month).
  final Color? leadingDatesBackgroundColor;

  /// Background color for trailing dates (days from next month).
  final Color? trailingDatesBackgroundColor;

  /// Text style for weekday headers (Monday, Tuesday, etc.).
  final TextStyle? weekdayHeaderTextStyle;

  /// Background color for weekday headers.
  final Color? weekdayHeaderBackgroundColor;

  /// Background color for the focused/selected date.
  final Color? focusedDateBackgroundColor;

  /// Text style for the focused/selected date.
  final TextStyle? focusedDateTextStyle;

  /// Background color for calendar cells on hover.
  final Color? hoverCellBackgroundColor;

  /// Highlight color for valid drop target cell overlay during drag-and-drop.
  final Color? dropTargetCellValidColor;

  /// Highlight color for invalid drop target cell overlay during drag-and-drop.
  final Color? dropTargetCellInvalidColor;

  /// Border radius for drop target cell overlay highlights during drag-and-drop.
  final double? dropTargetCellBorderRadius;

  /// Opacity for the source placeholder during drag-and-drop.
  final double? dragSourceOpacity;

  /// Elevation for the dragged tile feedback widget.
  final double? draggedTileElevation;

  /// Background color for multi-day event tiles.
  final Color? multiDayEventBackgroundColor;

  /// Text style for multi-day event tiles.
  final TextStyle? multiDayEventTextStyle;

  /// Height of event tile slots (both single-day and multi-day).
  final double? eventTileHeight;

  /// Vertical spacing between event tile rows in pixels.
  final double? eventTileVerticalSpacing;

  /// Height reserved for date labels in day cells.
  final double? dateLabelHeight;

  /// Position of date labels within day cells.
  final DateLabelPosition? dateLabelPosition;

  /// Height reserved for overflow indicators.
  final double? overflowIndicatorHeight;

  /// Inner content padding for event tiles.
  ///
  /// Controls the space between the tile border and its text label.
  /// When null, the master defaults use `EdgeInsets.symmetric(horizontal: 4.0)`.
  final EdgeInsets? eventTilePadding;

  /// Border color for event tiles.
  final Color? eventTileBorderColor;

  /// Border width for event tiles in pixels.
  final double? eventTileBorderWidth;

  /// Background color for drop target preview tiles.
  final Color? dropTargetTileBackgroundColor;

  /// Background color for invalid drop target preview tiles.
  final Color? dropTargetTileInvalidBackgroundColor;

  /// Corner radius for drop target preview tiles.
  final double? dropTargetTileCornerRadius;

  /// Border color for drop target preview tiles.
  final Color? dropTargetTileBorderColor;

  /// Border width for drop target preview tiles.
  final double? dropTargetTileBorderWidth;

  // ── New properties (Req 9) ────────────────────────────────────────────────

  /// Default color for region overlays when `region.color` is null.
  ///
  /// When null, the master defaults use `colorScheme.outlineVariant`.
  final Color? defaultRegionColor;

  /// Color for resize handle indicators on multi-day event tiles.
  ///
  /// When null, the master defaults use `Colors.white.withValues(alpha: 0.5)`.
  final Color? resizeHandleColor;

  /// Background scrim color for loading and error overlays.
  ///
  /// When null, the master defaults use
  /// `colorScheme.scrim.withValues(alpha: 0.3)`.
  final Color? overlayScrimColor;

  /// Color for the error icon in the error overlay.
  ///
  /// When null, the master defaults use `colorScheme.error`.
  final Color? errorIconColor;

  /// Text style for the "+N more" overflow indicator.
  ///
  /// Replaces the previous hack that reused `leadingDatesTextStyle`.
  /// When null, the master defaults derive this from
  /// `textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)`.
  final TextStyle? overflowIndicatorTextStyle;

  /// Creates a new [MCalMonthThemeData] instance.
  const MCalMonthThemeData({
    this.cellTextStyle,
    this.todayBackgroundColor,
    this.todayTextStyle,
    this.leadingDatesTextStyle,
    this.trailingDatesTextStyle,
    this.leadingDatesBackgroundColor,
    this.trailingDatesBackgroundColor,
    this.weekdayHeaderTextStyle,
    this.weekdayHeaderBackgroundColor,
    this.focusedDateBackgroundColor,
    this.focusedDateTextStyle,
    this.hoverCellBackgroundColor,
    this.dropTargetCellValidColor,
    this.dropTargetCellInvalidColor,
    this.dropTargetCellBorderRadius,
    this.dragSourceOpacity,
    this.draggedTileElevation,
    this.multiDayEventBackgroundColor,
    this.multiDayEventTextStyle,
    this.eventTileHeight,
    this.eventTileVerticalSpacing,
    this.dateLabelHeight,
    this.dateLabelPosition,
    this.overflowIndicatorHeight,
    this.eventTilePadding,
    this.eventTileBorderColor,
    this.eventTileBorderWidth,
    this.dropTargetTileBackgroundColor,
    this.dropTargetTileInvalidBackgroundColor,
    this.dropTargetTileCornerRadius,
    this.dropTargetTileBorderColor,
    this.dropTargetTileBorderWidth,
    this.defaultRegionColor,
    this.resizeHandleColor,
    this.overlayScrimColor,
    this.errorIconColor,
    this.overflowIndicatorTextStyle,
  });

  /// Creates the **master defaults** for Month View theming from the provided [ThemeData].
  ///
  /// Called by [MCalThemeData.fromTheme] to populate [MCalThemeData.monthTheme].
  /// All returned properties are non-null and are derived from the theme's
  /// [ColorScheme] and [TextTheme] following Material 3 color roles.
  ///
  /// Do not call this directly in widget code — use
  /// `MCalThemeData.fromTheme(Theme.of(context)).monthTheme!` and the
  /// `theme.monthTheme?.property ?? defaults.monthTheme!.property!` pattern instead.
  factory MCalMonthThemeData.defaults(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return MCalMonthThemeData(
      cellTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
      todayBackgroundColor: colorScheme.primary.withValues(alpha: 0.1),
      todayTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
      leadingDatesTextStyle: textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      trailingDatesTextStyle: textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      leadingDatesBackgroundColor: colorScheme.surface,
      trailingDatesBackgroundColor: colorScheme.surface,
      weekdayHeaderTextStyle: textTheme.labelMedium?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.7),
        fontWeight: FontWeight.w500,
      ),
      weekdayHeaderBackgroundColor: colorScheme.surfaceContainerHighest,
      focusedDateBackgroundColor:
          colorScheme.primary.withValues(alpha: 0.2),
      focusedDateTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      hoverCellBackgroundColor:
          colorScheme.primary.withValues(alpha: 0.05),
      dropTargetCellValidColor:
          colorScheme.tertiary.withValues(alpha: 0.3),
      dropTargetCellInvalidColor:
          colorScheme.error.withValues(alpha: 0.3),
      dropTargetCellBorderRadius: 4.0,
      dragSourceOpacity: 0.5,
      draggedTileElevation: 6.0,
      multiDayEventBackgroundColor:
          colorScheme.primary.withValues(alpha: 0.8),
      multiDayEventTextStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onPrimary,
        fontWeight: FontWeight.w500,
      ),
      eventTileHeight: 20.0,
      eventTileVerticalSpacing: 1.0,
      eventTilePadding: const EdgeInsets.symmetric(horizontal: 4.0),
      dateLabelHeight: 18.0,
      dateLabelPosition: DateLabelPosition.topLeft,
      overflowIndicatorHeight: 14.0,
      defaultRegionColor: colorScheme.outlineVariant,
      resizeHandleColor: Colors.white.withValues(alpha: 0.5),
      overlayScrimColor: colorScheme.scrim.withValues(alpha: 0.3),
      errorIconColor: colorScheme.error,
      overflowIndicatorTextStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  /// Creates a copy of this [MCalMonthThemeData] with the given fields replaced.
  MCalMonthThemeData copyWith({
    TextStyle? cellTextStyle,
    Color? todayBackgroundColor,
    TextStyle? todayTextStyle,
    TextStyle? leadingDatesTextStyle,
    TextStyle? trailingDatesTextStyle,
    Color? leadingDatesBackgroundColor,
    Color? trailingDatesBackgroundColor,
    TextStyle? weekdayHeaderTextStyle,
    Color? weekdayHeaderBackgroundColor,
    Color? focusedDateBackgroundColor,
    TextStyle? focusedDateTextStyle,
    Color? hoverCellBackgroundColor,
    Color? dropTargetCellValidColor,
    Color? dropTargetCellInvalidColor,
    double? dropTargetCellBorderRadius,
    double? dragSourceOpacity,
    double? draggedTileElevation,
    Color? multiDayEventBackgroundColor,
    TextStyle? multiDayEventTextStyle,
    double? eventTileHeight,
    double? eventTileVerticalSpacing,
    double? dateLabelHeight,
    DateLabelPosition? dateLabelPosition,
    double? overflowIndicatorHeight,
    EdgeInsets? eventTilePadding,
    Color? eventTileBorderColor,
    double? eventTileBorderWidth,
    Color? dropTargetTileBackgroundColor,
    Color? dropTargetTileInvalidBackgroundColor,
    double? dropTargetTileCornerRadius,
    Color? dropTargetTileBorderColor,
    double? dropTargetTileBorderWidth,
    Color? defaultRegionColor,
    Color? resizeHandleColor,
    Color? overlayScrimColor,
    Color? errorIconColor,
    TextStyle? overflowIndicatorTextStyle,
  }) {
    return MCalMonthThemeData(
      cellTextStyle: cellTextStyle ?? this.cellTextStyle,
      todayBackgroundColor: todayBackgroundColor ?? this.todayBackgroundColor,
      todayTextStyle: todayTextStyle ?? this.todayTextStyle,
      leadingDatesTextStyle:
          leadingDatesTextStyle ?? this.leadingDatesTextStyle,
      trailingDatesTextStyle:
          trailingDatesTextStyle ?? this.trailingDatesTextStyle,
      leadingDatesBackgroundColor:
          leadingDatesBackgroundColor ?? this.leadingDatesBackgroundColor,
      trailingDatesBackgroundColor:
          trailingDatesBackgroundColor ?? this.trailingDatesBackgroundColor,
      weekdayHeaderTextStyle:
          weekdayHeaderTextStyle ?? this.weekdayHeaderTextStyle,
      weekdayHeaderBackgroundColor:
          weekdayHeaderBackgroundColor ?? this.weekdayHeaderBackgroundColor,
      focusedDateBackgroundColor:
          focusedDateBackgroundColor ?? this.focusedDateBackgroundColor,
      focusedDateTextStyle: focusedDateTextStyle ?? this.focusedDateTextStyle,
      hoverCellBackgroundColor:
          hoverCellBackgroundColor ?? this.hoverCellBackgroundColor,
      dropTargetCellValidColor:
          dropTargetCellValidColor ?? this.dropTargetCellValidColor,
      dropTargetCellInvalidColor:
          dropTargetCellInvalidColor ?? this.dropTargetCellInvalidColor,
      dropTargetCellBorderRadius:
          dropTargetCellBorderRadius ?? this.dropTargetCellBorderRadius,
      dragSourceOpacity: dragSourceOpacity ?? this.dragSourceOpacity,
      draggedTileElevation: draggedTileElevation ?? this.draggedTileElevation,
      multiDayEventBackgroundColor:
          multiDayEventBackgroundColor ?? this.multiDayEventBackgroundColor,
      multiDayEventTextStyle:
          multiDayEventTextStyle ?? this.multiDayEventTextStyle,
      eventTileHeight: eventTileHeight ?? this.eventTileHeight,
      eventTileVerticalSpacing:
          eventTileVerticalSpacing ?? this.eventTileVerticalSpacing,
      dateLabelHeight: dateLabelHeight ?? this.dateLabelHeight,
      dateLabelPosition: dateLabelPosition ?? this.dateLabelPosition,
      overflowIndicatorHeight:
          overflowIndicatorHeight ?? this.overflowIndicatorHeight,
      eventTilePadding: eventTilePadding ?? this.eventTilePadding,
      eventTileBorderColor: eventTileBorderColor ?? this.eventTileBorderColor,
      eventTileBorderWidth: eventTileBorderWidth ?? this.eventTileBorderWidth,
      dropTargetTileBackgroundColor: dropTargetTileBackgroundColor ??
          this.dropTargetTileBackgroundColor,
      dropTargetTileInvalidBackgroundColor:
          dropTargetTileInvalidBackgroundColor ??
              this.dropTargetTileInvalidBackgroundColor,
      dropTargetTileCornerRadius:
          dropTargetTileCornerRadius ?? this.dropTargetTileCornerRadius,
      dropTargetTileBorderColor:
          dropTargetTileBorderColor ?? this.dropTargetTileBorderColor,
      dropTargetTileBorderWidth:
          dropTargetTileBorderWidth ?? this.dropTargetTileBorderWidth,
      defaultRegionColor: defaultRegionColor ?? this.defaultRegionColor,
      resizeHandleColor: resizeHandleColor ?? this.resizeHandleColor,
      overlayScrimColor: overlayScrimColor ?? this.overlayScrimColor,
      errorIconColor: errorIconColor ?? this.errorIconColor,
      overflowIndicatorTextStyle:
          overflowIndicatorTextStyle ?? this.overflowIndicatorTextStyle,
    );
  }

  /// Linearly interpolates between this theme and [other] by [t].
  MCalMonthThemeData lerp(MCalMonthThemeData? other, double t) {
    if (other == null) return this;

    return MCalMonthThemeData(
      cellTextStyle: TextStyle.lerp(cellTextStyle, other.cellTextStyle, t),
      todayBackgroundColor: Color.lerp(
        todayBackgroundColor,
        other.todayBackgroundColor,
        t,
      ),
      todayTextStyle: TextStyle.lerp(todayTextStyle, other.todayTextStyle, t),
      leadingDatesTextStyle: TextStyle.lerp(
        leadingDatesTextStyle,
        other.leadingDatesTextStyle,
        t,
      ),
      trailingDatesTextStyle: TextStyle.lerp(
        trailingDatesTextStyle,
        other.trailingDatesTextStyle,
        t,
      ),
      leadingDatesBackgroundColor: Color.lerp(
        leadingDatesBackgroundColor,
        other.leadingDatesBackgroundColor,
        t,
      ),
      trailingDatesBackgroundColor: Color.lerp(
        trailingDatesBackgroundColor,
        other.trailingDatesBackgroundColor,
        t,
      ),
      weekdayHeaderTextStyle: TextStyle.lerp(
        weekdayHeaderTextStyle,
        other.weekdayHeaderTextStyle,
        t,
      ),
      weekdayHeaderBackgroundColor: Color.lerp(
        weekdayHeaderBackgroundColor,
        other.weekdayHeaderBackgroundColor,
        t,
      ),
      focusedDateBackgroundColor: Color.lerp(
        focusedDateBackgroundColor,
        other.focusedDateBackgroundColor,
        t,
      ),
      focusedDateTextStyle: TextStyle.lerp(
        focusedDateTextStyle,
        other.focusedDateTextStyle,
        t,
      ),
      hoverCellBackgroundColor: Color.lerp(
        hoverCellBackgroundColor,
        other.hoverCellBackgroundColor,
        t,
      ),
      dropTargetCellValidColor: Color.lerp(
        dropTargetCellValidColor,
        other.dropTargetCellValidColor,
        t,
      ),
      dropTargetCellInvalidColor: Color.lerp(
        dropTargetCellInvalidColor,
        other.dropTargetCellInvalidColor,
        t,
      ),
      dropTargetCellBorderRadius: _lerpDouble(
        dropTargetCellBorderRadius,
        other.dropTargetCellBorderRadius,
        t,
      ),
      dragSourceOpacity: _lerpDouble(
        dragSourceOpacity,
        other.dragSourceOpacity,
        t,
      ),
      draggedTileElevation: _lerpDouble(
        draggedTileElevation,
        other.draggedTileElevation,
        t,
      ),
      multiDayEventBackgroundColor: Color.lerp(
        multiDayEventBackgroundColor,
        other.multiDayEventBackgroundColor,
        t,
      ),
      multiDayEventTextStyle: TextStyle.lerp(
        multiDayEventTextStyle,
        other.multiDayEventTextStyle,
        t,
      ),
      eventTileHeight: _lerpDouble(eventTileHeight, other.eventTileHeight, t),
      eventTileVerticalSpacing: _lerpDouble(
        eventTileVerticalSpacing,
        other.eventTileVerticalSpacing,
        t,
      ),
      dateLabelHeight: _lerpDouble(dateLabelHeight, other.dateLabelHeight, t),
      dateLabelPosition: t < 0.5 ? dateLabelPosition : other.dateLabelPosition,
      overflowIndicatorHeight: _lerpDouble(
        overflowIndicatorHeight,
        other.overflowIndicatorHeight,
        t,
      ),
      eventTilePadding: EdgeInsets.lerp(eventTilePadding, other.eventTilePadding, t),
      eventTileBorderColor: Color.lerp(
        eventTileBorderColor,
        other.eventTileBorderColor,
        t,
      ),
      eventTileBorderWidth: _lerpDouble(
        eventTileBorderWidth,
        other.eventTileBorderWidth,
        t,
      ),
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
      defaultRegionColor: Color.lerp(
        defaultRegionColor,
        other.defaultRegionColor,
        t,
      ),
      resizeHandleColor: Color.lerp(
        resizeHandleColor,
        other.resizeHandleColor,
        t,
      ),
      overlayScrimColor: Color.lerp(
        overlayScrimColor,
        other.overlayScrimColor,
        t,
      ),
      errorIconColor: Color.lerp(
        errorIconColor,
        other.errorIconColor,
        t,
      ),
      overflowIndicatorTextStyle: TextStyle.lerp(
        overflowIndicatorTextStyle,
        other.overflowIndicatorTextStyle,
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
      other is MCalMonthThemeData &&
          runtimeType == other.runtimeType &&
          cellTextStyle == other.cellTextStyle &&
          todayBackgroundColor == other.todayBackgroundColor &&
          todayTextStyle == other.todayTextStyle &&
          leadingDatesTextStyle == other.leadingDatesTextStyle &&
          trailingDatesTextStyle == other.trailingDatesTextStyle &&
          leadingDatesBackgroundColor == other.leadingDatesBackgroundColor &&
          trailingDatesBackgroundColor ==
              other.trailingDatesBackgroundColor &&
          weekdayHeaderTextStyle == other.weekdayHeaderTextStyle &&
          weekdayHeaderBackgroundColor ==
              other.weekdayHeaderBackgroundColor &&
          focusedDateBackgroundColor == other.focusedDateBackgroundColor &&
          focusedDateTextStyle == other.focusedDateTextStyle &&
          hoverCellBackgroundColor == other.hoverCellBackgroundColor &&
          dropTargetCellValidColor == other.dropTargetCellValidColor &&
          dropTargetCellInvalidColor == other.dropTargetCellInvalidColor &&
          dropTargetCellBorderRadius == other.dropTargetCellBorderRadius &&
          dragSourceOpacity == other.dragSourceOpacity &&
          draggedTileElevation == other.draggedTileElevation &&
          multiDayEventBackgroundColor ==
              other.multiDayEventBackgroundColor &&
          multiDayEventTextStyle == other.multiDayEventTextStyle &&
          eventTileHeight == other.eventTileHeight &&
          eventTileVerticalSpacing == other.eventTileVerticalSpacing &&
          dateLabelHeight == other.dateLabelHeight &&
          dateLabelPosition == other.dateLabelPosition &&
          overflowIndicatorHeight == other.overflowIndicatorHeight &&
          eventTilePadding == other.eventTilePadding &&
          eventTileBorderColor == other.eventTileBorderColor &&
          eventTileBorderWidth == other.eventTileBorderWidth &&
          dropTargetTileBackgroundColor ==
              other.dropTargetTileBackgroundColor &&
          dropTargetTileInvalidBackgroundColor ==
              other.dropTargetTileInvalidBackgroundColor &&
          dropTargetTileCornerRadius == other.dropTargetTileCornerRadius &&
          dropTargetTileBorderColor == other.dropTargetTileBorderColor &&
          dropTargetTileBorderWidth == other.dropTargetTileBorderWidth &&
          defaultRegionColor == other.defaultRegionColor &&
          resizeHandleColor == other.resizeHandleColor &&
          overlayScrimColor == other.overlayScrimColor &&
          errorIconColor == other.errorIconColor &&
          overflowIndicatorTextStyle == other.overflowIndicatorTextStyle;

  @override
  int get hashCode => Object.hashAll([
        cellTextStyle,
        todayBackgroundColor,
        todayTextStyle,
        leadingDatesTextStyle,
        trailingDatesTextStyle,
        leadingDatesBackgroundColor,
        trailingDatesBackgroundColor,
        weekdayHeaderTextStyle,
        weekdayHeaderBackgroundColor,
        focusedDateBackgroundColor,
        focusedDateTextStyle,
        hoverCellBackgroundColor,
        dropTargetCellValidColor,
        dropTargetCellInvalidColor,
        dropTargetCellBorderRadius,
        dragSourceOpacity,
        draggedTileElevation,
        multiDayEventBackgroundColor,
        multiDayEventTextStyle,
        eventTileHeight,
        eventTileVerticalSpacing,
        dateLabelHeight,
        dateLabelPosition,
        overflowIndicatorHeight,
        eventTilePadding,
        eventTileBorderColor,
        eventTileBorderWidth,
        dropTargetTileBackgroundColor,
        dropTargetTileInvalidBackgroundColor,
        dropTargetTileCornerRadius,
        dropTargetTileBorderColor,
        dropTargetTileBorderWidth,
        defaultRegionColor,
        resizeHandleColor,
        overlayScrimColor,
        errorIconColor,
        overflowIndicatorTextStyle,
      ]);
}
