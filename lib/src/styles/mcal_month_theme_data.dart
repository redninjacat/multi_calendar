import 'package:flutter/material.dart';
import '../widgets/mcal_month_week_layout_contexts.dart' show DateLabelPosition;

/// Theme data for Month View specific styling.
///
/// This class contains all properties that apply exclusively to [MCalMonthView],
/// such as weekday headers, date labels, event tile layout, and drag-and-drop
/// styling. Use [MCalMonthThemeData.defaults] to create a theme with Material 3
/// defaults.
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
  /// Background color for calendar day cells.
  final Color? cellBackgroundColor;

  /// Border color for calendar day cells.
  final Color? cellBorderColor;

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

  /// Text style for week numbers.
  final TextStyle? weekNumberTextStyle;

  /// Background color for the week number column.
  final Color? weekNumberBackgroundColor;

  /// Background color for calendar cells on hover.
  final Color? hoverCellBackgroundColor;

  /// Background color for event tiles on hover.
  final Color? hoverEventBackgroundColor;

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

  /// Horizontal spacing around event tiles in pixels.
  final double? eventTileHorizontalSpacing;

  /// Vertical spacing between event tile rows in pixels.
  final double? eventTileVerticalSpacing;

  /// Height reserved for date labels in day cells.
  final double? dateLabelHeight;

  /// Position of date labels within day cells.
  final DateLabelPosition? dateLabelPosition;

  /// Height reserved for overflow indicators.
  final double? overflowIndicatorHeight;

  /// Corner radius for event tiles.
  final double? eventTileCornerRadius;

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

  /// Text style for the month navigator (month/year display and controls).
  final TextStyle? navigatorTextStyle;

  /// Background color for the month navigator.
  final Color? navigatorBackgroundColor;

  /// Background color for all-day event tiles.
  final Color? allDayEventBackgroundColor;

  /// Text style for all-day event tiles.
  final TextStyle? allDayEventTextStyle;

  /// Border color for all-day event tiles.
  final Color? allDayEventBorderColor;

  /// Border width for all-day event tiles.
  final double? allDayEventBorderWidth;

  /// Creates a new [MCalMonthThemeData] instance.
  const MCalMonthThemeData({
    this.cellBackgroundColor,
    this.cellBorderColor,
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
    this.weekNumberTextStyle,
    this.weekNumberBackgroundColor,
    this.hoverCellBackgroundColor,
    this.hoverEventBackgroundColor,
    this.dropTargetCellValidColor,
    this.dropTargetCellInvalidColor,
    this.dropTargetCellBorderRadius,
    this.dragSourceOpacity,
    this.draggedTileElevation,
    this.multiDayEventBackgroundColor,
    this.multiDayEventTextStyle,
    this.eventTileHeight,
    this.eventTileHorizontalSpacing,
    this.eventTileVerticalSpacing,
    this.dateLabelHeight,
    this.dateLabelPosition,
    this.overflowIndicatorHeight,
    this.eventTileCornerRadius,
    this.eventTileBorderColor,
    this.eventTileBorderWidth,
    this.dropTargetTileBackgroundColor,
    this.dropTargetTileInvalidBackgroundColor,
    this.dropTargetTileCornerRadius,
    this.dropTargetTileBorderColor,
    this.dropTargetTileBorderWidth,
    this.navigatorTextStyle,
    this.navigatorBackgroundColor,
    this.allDayEventBackgroundColor,
    this.allDayEventTextStyle,
    this.allDayEventBorderColor,
    this.allDayEventBorderWidth,
  });

  /// Creates a [MCalMonthThemeData] instance with default values derived
  /// from the provided [ThemeData].
  factory MCalMonthThemeData.defaults(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return MCalMonthThemeData(
      cellBackgroundColor: colorScheme.surface,
      cellBorderColor: colorScheme.outline.withValues(alpha: 0.2),
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
      focusedDateBackgroundColor: colorScheme.primary.withValues(alpha: 0.2),
      focusedDateTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      weekNumberTextStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      weekNumberBackgroundColor: colorScheme.surfaceContainerHighest,
      hoverCellBackgroundColor: colorScheme.primary.withValues(alpha: 0.05),
      hoverEventBackgroundColor: colorScheme.primaryContainer.withValues(
        alpha: 0.8,
      ),
      dropTargetCellValidColor: Colors.green.withValues(alpha: 0.3),
      dropTargetCellInvalidColor: Colors.red.withValues(alpha: 0.3),
      dropTargetCellBorderRadius: 4.0,
      dragSourceOpacity: 0.5,
      draggedTileElevation: 6.0,
      multiDayEventBackgroundColor: colorScheme.primary.withValues(alpha: 0.8),
      multiDayEventTextStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onPrimary,
        fontWeight: FontWeight.w500,
      ),
      eventTileHeight: 20.0,
      eventTileHorizontalSpacing: 1.0,
      eventTileVerticalSpacing: 1.0,
      dateLabelHeight: 18.0,
      dateLabelPosition: DateLabelPosition.topLeft,
      overflowIndicatorHeight: 14.0,
      eventTileCornerRadius: 3.0,
      navigatorTextStyle: textTheme.titleMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      navigatorBackgroundColor: colorScheme.surface,
      allDayEventBackgroundColor: colorScheme.secondaryContainer,
      allDayEventTextStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSecondaryContainer,
      ),
      allDayEventBorderColor: colorScheme.secondary.withValues(alpha: 0.3),
      allDayEventBorderWidth: 1.0,
    );
  }

  /// Creates a copy of this [MCalMonthThemeData] with the given fields replaced.
  MCalMonthThemeData copyWith({
    Color? cellBackgroundColor,
    Color? cellBorderColor,
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
    TextStyle? weekNumberTextStyle,
    Color? weekNumberBackgroundColor,
    Color? hoverCellBackgroundColor,
    Color? hoverEventBackgroundColor,
    Color? dropTargetCellValidColor,
    Color? dropTargetCellInvalidColor,
    double? dropTargetCellBorderRadius,
    double? dragSourceOpacity,
    double? draggedTileElevation,
    Color? multiDayEventBackgroundColor,
    TextStyle? multiDayEventTextStyle,
    double? eventTileHeight,
    double? eventTileHorizontalSpacing,
    double? eventTileVerticalSpacing,
    double? dateLabelHeight,
    DateLabelPosition? dateLabelPosition,
    double? overflowIndicatorHeight,
    double? eventTileCornerRadius,
    Color? eventTileBorderColor,
    double? eventTileBorderWidth,
    Color? dropTargetTileBackgroundColor,
    Color? dropTargetTileInvalidBackgroundColor,
    double? dropTargetTileCornerRadius,
    Color? dropTargetTileBorderColor,
    double? dropTargetTileBorderWidth,
    TextStyle? navigatorTextStyle,
    Color? navigatorBackgroundColor,
    Color? allDayEventBackgroundColor,
    TextStyle? allDayEventTextStyle,
    Color? allDayEventBorderColor,
    double? allDayEventBorderWidth,
  }) {
    return MCalMonthThemeData(
      cellBackgroundColor: cellBackgroundColor ?? this.cellBackgroundColor,
      cellBorderColor: cellBorderColor ?? this.cellBorderColor,
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
      weekNumberTextStyle: weekNumberTextStyle ?? this.weekNumberTextStyle,
      weekNumberBackgroundColor:
          weekNumberBackgroundColor ?? this.weekNumberBackgroundColor,
      hoverCellBackgroundColor:
          hoverCellBackgroundColor ?? this.hoverCellBackgroundColor,
      hoverEventBackgroundColor:
          hoverEventBackgroundColor ?? this.hoverEventBackgroundColor,
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
      eventTileHorizontalSpacing:
          eventTileHorizontalSpacing ?? this.eventTileHorizontalSpacing,
      eventTileVerticalSpacing:
          eventTileVerticalSpacing ?? this.eventTileVerticalSpacing,
      dateLabelHeight: dateLabelHeight ?? this.dateLabelHeight,
      dateLabelPosition: dateLabelPosition ?? this.dateLabelPosition,
      overflowIndicatorHeight:
          overflowIndicatorHeight ?? this.overflowIndicatorHeight,
      eventTileCornerRadius:
          eventTileCornerRadius ?? this.eventTileCornerRadius,
      eventTileBorderColor: eventTileBorderColor ?? this.eventTileBorderColor,
      eventTileBorderWidth: eventTileBorderWidth ?? this.eventTileBorderWidth,
      dropTargetTileBackgroundColor: dropTargetTileBackgroundColor ??
          this.dropTargetTileBackgroundColor,
      dropTargetTileInvalidBackgroundColor: dropTargetTileInvalidBackgroundColor ??
          this.dropTargetTileInvalidBackgroundColor,
      dropTargetTileCornerRadius: dropTargetTileCornerRadius ??
          this.dropTargetTileCornerRadius,
      dropTargetTileBorderColor:
          dropTargetTileBorderColor ?? this.dropTargetTileBorderColor,
      dropTargetTileBorderWidth: dropTargetTileBorderWidth ??
          this.dropTargetTileBorderWidth,
      navigatorTextStyle: navigatorTextStyle ?? this.navigatorTextStyle,
      navigatorBackgroundColor:
          navigatorBackgroundColor ?? this.navigatorBackgroundColor,
      allDayEventBackgroundColor:
          allDayEventBackgroundColor ?? this.allDayEventBackgroundColor,
      allDayEventTextStyle: allDayEventTextStyle ?? this.allDayEventTextStyle,
      allDayEventBorderColor:
          allDayEventBorderColor ?? this.allDayEventBorderColor,
      allDayEventBorderWidth:
          allDayEventBorderWidth ?? this.allDayEventBorderWidth,
    );
  }

  /// Linearly interpolates between this theme and [other] by [t].
  MCalMonthThemeData lerp(MCalMonthThemeData? other, double t) {
    if (other == null) return this;

    return MCalMonthThemeData(
      cellBackgroundColor: Color.lerp(
        cellBackgroundColor,
        other.cellBackgroundColor,
        t,
      ),
      cellBorderColor: Color.lerp(cellBorderColor, other.cellBorderColor, t),
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
      weekNumberTextStyle: TextStyle.lerp(
        weekNumberTextStyle,
        other.weekNumberTextStyle,
        t,
      ),
      weekNumberBackgroundColor: Color.lerp(
        weekNumberBackgroundColor,
        other.weekNumberBackgroundColor,
        t,
      ),
      hoverCellBackgroundColor: Color.lerp(
        hoverCellBackgroundColor,
        other.hoverCellBackgroundColor,
        t,
      ),
      hoverEventBackgroundColor: Color.lerp(
        hoverEventBackgroundColor,
        other.hoverEventBackgroundColor,
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
      eventTileHorizontalSpacing: _lerpDouble(
        eventTileHorizontalSpacing,
        other.eventTileHorizontalSpacing,
        t,
      ),
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
      eventTileCornerRadius: _lerpDouble(
        eventTileCornerRadius,
        other.eventTileCornerRadius,
        t,
      ),
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
      navigatorTextStyle: TextStyle.lerp(
        navigatorTextStyle,
        other.navigatorTextStyle,
        t,
      ),
      navigatorBackgroundColor: Color.lerp(
        navigatorBackgroundColor,
        other.navigatorBackgroundColor,
        t,
      ),
      allDayEventBackgroundColor: Color.lerp(
        allDayEventBackgroundColor,
        other.allDayEventBackgroundColor,
        t,
      ),
      allDayEventTextStyle: TextStyle.lerp(
        allDayEventTextStyle,
        other.allDayEventTextStyle,
        t,
      ),
      allDayEventBorderColor: Color.lerp(
        allDayEventBorderColor,
        other.allDayEventBorderColor,
        t,
      ),
      allDayEventBorderWidth: _lerpDouble(
        allDayEventBorderWidth,
        other.allDayEventBorderWidth,
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
          cellBackgroundColor == other.cellBackgroundColor &&
          cellBorderColor == other.cellBorderColor &&
          cellTextStyle == other.cellTextStyle &&
          todayBackgroundColor == other.todayBackgroundColor &&
          todayTextStyle == other.todayTextStyle &&
          leadingDatesTextStyle == other.leadingDatesTextStyle &&
          trailingDatesTextStyle == other.trailingDatesTextStyle &&
          leadingDatesBackgroundColor == other.leadingDatesBackgroundColor &&
          trailingDatesBackgroundColor == other.trailingDatesBackgroundColor &&
          weekdayHeaderTextStyle == other.weekdayHeaderTextStyle &&
          weekdayHeaderBackgroundColor == other.weekdayHeaderBackgroundColor &&
          focusedDateBackgroundColor == other.focusedDateBackgroundColor &&
          focusedDateTextStyle == other.focusedDateTextStyle &&
          weekNumberTextStyle == other.weekNumberTextStyle &&
          weekNumberBackgroundColor == other.weekNumberBackgroundColor &&
          hoverCellBackgroundColor == other.hoverCellBackgroundColor &&
          hoverEventBackgroundColor == other.hoverEventBackgroundColor &&
          dropTargetCellValidColor == other.dropTargetCellValidColor &&
          dropTargetCellInvalidColor == other.dropTargetCellInvalidColor &&
          dropTargetCellBorderRadius == other.dropTargetCellBorderRadius &&
          dragSourceOpacity == other.dragSourceOpacity &&
          draggedTileElevation == other.draggedTileElevation &&
          multiDayEventBackgroundColor == other.multiDayEventBackgroundColor &&
          multiDayEventTextStyle == other.multiDayEventTextStyle &&
          eventTileHeight == other.eventTileHeight &&
          eventTileHorizontalSpacing == other.eventTileHorizontalSpacing &&
          eventTileVerticalSpacing == other.eventTileVerticalSpacing &&
          dateLabelHeight == other.dateLabelHeight &&
          dateLabelPosition == other.dateLabelPosition &&
          overflowIndicatorHeight == other.overflowIndicatorHeight &&
          eventTileCornerRadius == other.eventTileCornerRadius &&
          eventTileBorderColor == other.eventTileBorderColor &&
          eventTileBorderWidth == other.eventTileBorderWidth &&
          dropTargetTileBackgroundColor == other.dropTargetTileBackgroundColor &&
          dropTargetTileInvalidBackgroundColor ==
              other.dropTargetTileInvalidBackgroundColor &&
          dropTargetTileCornerRadius == other.dropTargetTileCornerRadius &&
          dropTargetTileBorderColor == other.dropTargetTileBorderColor &&
          dropTargetTileBorderWidth == other.dropTargetTileBorderWidth &&
          navigatorTextStyle == other.navigatorTextStyle &&
          navigatorBackgroundColor == other.navigatorBackgroundColor &&
          allDayEventBackgroundColor == other.allDayEventBackgroundColor &&
          allDayEventTextStyle == other.allDayEventTextStyle &&
          allDayEventBorderColor == other.allDayEventBorderColor &&
          allDayEventBorderWidth == other.allDayEventBorderWidth;

  @override
  int get hashCode => Object.hashAll([
        cellBackgroundColor,
        cellBorderColor,
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
        weekNumberTextStyle,
        weekNumberBackgroundColor,
        hoverCellBackgroundColor,
        hoverEventBackgroundColor,
        dropTargetCellValidColor,
        dropTargetCellInvalidColor,
        dropTargetCellBorderRadius,
        dragSourceOpacity,
        draggedTileElevation,
        multiDayEventBackgroundColor,
        multiDayEventTextStyle,
        eventTileHeight,
        eventTileHorizontalSpacing,
        eventTileVerticalSpacing,
        dateLabelHeight,
        dateLabelPosition,
        overflowIndicatorHeight,
        eventTileCornerRadius,
        eventTileBorderColor,
        eventTileBorderWidth,
        dropTargetTileBackgroundColor,
        dropTargetTileInvalidBackgroundColor,
        dropTargetTileCornerRadius,
        dropTargetTileBorderColor,
        dropTargetTileBorderWidth,
        navigatorTextStyle,
        navigatorBackgroundColor,
        allDayEventBackgroundColor,
        allDayEventTextStyle,
        allDayEventBorderColor,
        allDayEventBorderWidth,
      ]);
}
