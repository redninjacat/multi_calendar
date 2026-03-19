import 'package:flutter/material.dart';
import '../widgets/mcal_month_week_layout_contexts.dart' show DateLabelPosition;
import 'mcal_all_day_tile_theme_mixin.dart';
import 'mcal_event_tile_theme_mixin.dart';

/// Theme data for Month View specific styling.
///
/// This class mixes in [MCalEventTileThemeMixin] for timed event tile
/// properties and [MCalAllDayTileThemeMixin] for all-day event tile
/// properties, and adds Month-View-specific properties (cell styling, date
/// labels, headers, multi-day tiles, drag & drop, overflow, regions, overlays).
///
/// Use [MCalMonthViewThemeData.defaults] to create a theme with Material 3 defaults.
///
/// Example:
/// ```dart
/// MCalThemeData(
///   monthViewTheme: MCalMonthViewThemeData(
///     eventTileHeight: 24.0,
///     dateLabelPosition: DateLabelPosition.topCenter,
///     keyboardSelectionBorderWidth: 2.5,
///   ),
/// )
/// ```
class MCalMonthViewThemeData with MCalEventTileThemeMixin, MCalAllDayTileThemeMixin {
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

  // ── AllDayTileThemeMixin fields ─────────────────────────────────────────────

  @override
  final Color? allDayEventBackgroundColor;

  @override
  final TextStyle? allDayEventTextStyle;

  @override
  final Color? allDayEventBorderColor;

  @override
  final double? allDayEventBorderWidth;

  @override
  final EdgeInsets? allDayEventPadding;

  // ── Month-View-specific retained properties ────────────────────────────────

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
  final EdgeInsets? eventTilePadding;

  /// Default color for region overlays when `region.color` is null.
  final Color? defaultRegionColor;

  /// Background scrim color for loading and error overlays.
  final Color? overlayScrimColor;

  /// Color for the error icon in the error overlay.
  final Color? errorIconColor;

  /// Text style for the "+N more" overflow indicator.
  final TextStyle? overflowIndicatorTextStyle;

  // ── New layout properties (19) ────────────────────────────────────────────

  /// Padding around the date label inside each day cell.
  ///
  /// Replaces the hardcoded `EdgeInsets.only(left: 4.0, top: 4.0, right: 4.0)`
  /// in `day_cell_widget.dart`.
  final EdgeInsets? dateLabelPadding;

  /// Width of cell borders (in pixels).
  ///
  /// Replaces the hardcoded `1.0` in `day_cell_widget.dart`.
  final double? cellBorderWidth;

  /// Padding inside region content areas within day cells.
  ///
  /// Replaces the hardcoded `EdgeInsets.only(bottom: 2.0)` in `day_cell_widget.dart`.
  final EdgeInsets? regionContentPadding;

  /// Icon size for icons displayed in region overlays (in pixels).
  ///
  /// Replaces the hardcoded `9.0` in `day_cell_widget.dart`.
  final double? regionIconSize;

  /// Horizontal gap between the region icon and its text label (in pixels).
  ///
  /// Replaces the hardcoded `2.0` (SizedBox) in `day_cell_widget.dart`.
  final double? regionIconGap;

  /// Font size for region label text (in pixels).
  ///
  /// Replaces the hardcoded `8.0` in `day_cell_widget.dart`.
  final double? regionFontSize;

  /// Border width for the keyboard focus ring when a cell is selected or
  /// being moved/resized (in pixels).
  ///
  /// Replaces the hardcoded `2.0` in `week_row_widget.dart`.
  final double? keyboardSelectionBorderWidth;

  /// Border width for the keyboard focus ring when a cell is highlighted
  /// during tab cycling (in pixels).
  ///
  /// Replaces the hardcoded `1.5` in `week_row_widget.dart`.
  final double? keyboardHighlightBorderWidth;

  /// Diameter of the circle drawn behind the date label for the current day
  /// or focused date (in pixels).
  ///
  /// Replaces the hardcoded `24.0` in `week_row_widget.dart`.
  final double? dateLabelCircleSize;

  /// Width of the week number column (in pixels).
  ///
  /// Replaces the hardcoded `36.0` in `week_number_cell.dart`.
  final double? weekNumberColumnWidth;

  /// Border width of the week number column separator (in pixels).
  ///
  /// Replaces the hardcoded `0.5` in `week_number_cell.dart`.
  final double? weekNumberBorderWidth;

  /// Padding inside the weekday header row.
  ///
  /// Replaces the hardcoded `EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0)`
  /// in `weekday_header_row_widget.dart`.
  final EdgeInsets? weekdayHeaderPadding;

  /// Inner content padding for multi-day event tile segments.
  ///
  /// Replaces the hardcoded `EdgeInsets.symmetric(horizontal: 4, vertical: 2)`
  /// in `mcal_month_multi_day_tile.dart`.
  final EdgeInsets? multiDayTilePadding;

  /// Corner radius for multi-day event tile segments (in pixels).
  ///
  /// Replaces the hardcoded `4.0` in `mcal_month_multi_day_tile.dart`.
  final double? multiDayTileBorderRadius;

  /// Padding between the date label and the first event row in the week layout.
  ///
  /// Replaces the hardcoded `2.0` (`dateLabelPadding` constant) in
  /// `mcal_month_default_week_layout.dart`.
  final double? weekLayoutDateLabelPadding;

  /// Base vertical margin between event tile rows in the week layout (in pixels).
  ///
  /// Replaces the hardcoded `2.0` (`baseMargin` constant) in
  /// `mcal_month_default_week_layout.dart`.
  final double? weekLayoutBaseMargin;

  /// Visual width of the resize handle bar on multi-day event tiles (in pixels).
  ///
  /// Month View uses a vertical bar resize handle, distinct from the Day View's
  /// horizontal bar. Replaces the hardcoded `width: 2` in `month_page_widget.dart`.
  final double? resizeHandleVisualWidth;

  /// Vertical margin on each side of the resize handle bar (in pixels).
  ///
  /// The bar height is computed as `tileHeight - (2 * resizeHandleVerticalMargin)`.
  /// With the default tile height of 18.0 this yields 16.0, matching the
  /// previously hardcoded `height: 16`. Analogous to Day View's
  /// `resizeHandleHorizontalMargin`. Replaces the hardcoded `height: 16` in
  /// `month_page_widget.dart`.
  final double? resizeHandleVerticalMargin;

  /// Border radius of the resize handle bar (in pixels).
  ///
  /// Replaces the hardcoded `BorderRadius.circular(1)` in `month_page_widget.dart`.
  final double? resizeHandleBorderRadius;

  /// Creates a new [MCalMonthViewThemeData] instance.
  const MCalMonthViewThemeData({
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
    // AllDayTileThemeMixin
    this.allDayEventBackgroundColor,
    this.allDayEventTextStyle,
    this.allDayEventBorderColor,
    this.allDayEventBorderWidth,
    this.allDayEventPadding,
    // Retained own
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
    this.eventTileHeight,
    this.eventTileVerticalSpacing,
    this.dateLabelHeight,
    this.dateLabelPosition,
    this.overflowIndicatorHeight,
    this.eventTilePadding,
    this.defaultRegionColor,
    this.overlayScrimColor,
    this.errorIconColor,
    this.overflowIndicatorTextStyle,
    // New layout own
    this.dateLabelPadding,
    this.cellBorderWidth,
    this.regionContentPadding,
    this.regionIconSize,
    this.regionIconGap,
    this.regionFontSize,
    this.keyboardSelectionBorderWidth,
    this.keyboardHighlightBorderWidth,
    this.dateLabelCircleSize,
    this.weekNumberColumnWidth,
    this.weekNumberBorderWidth,
    this.weekdayHeaderPadding,
    this.multiDayTilePadding,
    this.multiDayTileBorderRadius,
    this.weekLayoutDateLabelPadding,
    this.weekLayoutBaseMargin,
    this.resizeHandleVisualWidth,
    this.resizeHandleVerticalMargin,
    this.resizeHandleBorderRadius,
  });

  /// Creates the **master defaults** for Month View theming from [theme].
  ///
  /// Called by [MCalThemeData.fromTheme] to populate [MCalThemeData.monthViewTheme].
  /// All returned properties are non-null and are derived from the theme's
  /// [ColorScheme] and [TextTheme] following Material 3 color roles. New
  /// layout property defaults match the values previously hardcoded in widgets.
  factory MCalMonthViewThemeData.defaults(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return MCalMonthViewThemeData(
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
      dropTargetTileBorderWidth: 1.5,
      resizeHandleColor: Colors.white.withValues(alpha: 0.5),
      // AllDayTileThemeMixin defaults
      allDayEventBackgroundColor: colorScheme.secondaryContainer,
      allDayEventTextStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSecondaryContainer,
      ),
      allDayEventBorderColor: colorScheme.secondary.withValues(alpha: 0.3),
      allDayEventBorderWidth: 1.0,
      allDayEventPadding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      // Retained own defaults
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
      hoverCellBackgroundColor: colorScheme.primary.withValues(alpha: 0.05),
      dropTargetCellValidColor: colorScheme.tertiary.withValues(alpha: 0.3),
      dropTargetCellInvalidColor: colorScheme.error.withValues(alpha: 0.3),
      dropTargetCellBorderRadius: 4.0,
      dragSourceOpacity: 0.5,
      draggedTileElevation: 6.0,
      eventTileHeight: 20.0,
      eventTileVerticalSpacing: 1.0,
      eventTilePadding: const EdgeInsets.symmetric(horizontal: 4.0),
      dateLabelHeight: 18.0,
      dateLabelPosition: DateLabelPosition.topLeft,
      overflowIndicatorHeight: 14.0,
      defaultRegionColor: colorScheme.outlineVariant,
      overlayScrimColor: colorScheme.scrim.withValues(alpha: 0.3),
      errorIconColor: colorScheme.error,
      overflowIndicatorTextStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      // New layout defaults (match current hardcoded values)
      dateLabelPadding: const EdgeInsets.only(left: 4.0, top: 4.0, right: 4.0),
      cellBorderWidth: 1.0,
      regionContentPadding: const EdgeInsets.only(bottom: 2.0),
      regionIconSize: 9.0,
      regionIconGap: 2.0,
      regionFontSize: 8.0,
      keyboardSelectionBorderWidth: 2.0,
      keyboardHighlightBorderWidth: 1.5,
      dateLabelCircleSize: 24.0,
      weekNumberColumnWidth: 36.0,
      weekNumberBorderWidth: 0.5,
      weekdayHeaderPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
      multiDayTilePadding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      multiDayTileBorderRadius: 4.0,
      weekLayoutDateLabelPadding: 2.0,
      weekLayoutBaseMargin: 2.0,
      resizeHandleVisualWidth: 2.0,
      resizeHandleVerticalMargin: 1.0,
      resizeHandleBorderRadius: 1.0,
    );
  }

  /// Creates a copy of this [MCalMonthViewThemeData] with the given fields replaced.
  MCalMonthViewThemeData copyWith({
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
    // AllDayTileThemeMixin
    Color? allDayEventBackgroundColor,
    TextStyle? allDayEventTextStyle,
    Color? allDayEventBorderColor,
    double? allDayEventBorderWidth,
    EdgeInsets? allDayEventPadding,
    // Retained own
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
    double? eventTileHeight,
    double? eventTileVerticalSpacing,
    double? dateLabelHeight,
    DateLabelPosition? dateLabelPosition,
    double? overflowIndicatorHeight,
    EdgeInsets? eventTilePadding,
    Color? defaultRegionColor,
    Color? overlayScrimColor,
    Color? errorIconColor,
    TextStyle? overflowIndicatorTextStyle,
    // New layout own
    EdgeInsets? dateLabelPadding,
    double? cellBorderWidth,
    EdgeInsets? regionContentPadding,
    double? regionIconSize,
    double? regionIconGap,
    double? regionFontSize,
    double? keyboardSelectionBorderWidth,
    double? keyboardHighlightBorderWidth,
    double? dateLabelCircleSize,
    double? weekNumberColumnWidth,
    double? weekNumberBorderWidth,
    EdgeInsets? weekdayHeaderPadding,
    EdgeInsets? multiDayTilePadding,
    double? multiDayTileBorderRadius,
    double? weekLayoutDateLabelPadding,
    double? weekLayoutBaseMargin,
    double? resizeHandleVisualWidth,
    double? resizeHandleVerticalMargin,
    double? resizeHandleBorderRadius,
  }) {
    return MCalMonthViewThemeData(
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
      // AllDayTileThemeMixin
      allDayEventBackgroundColor: allDayEventBackgroundColor ?? this.allDayEventBackgroundColor,
      allDayEventTextStyle: allDayEventTextStyle ?? this.allDayEventTextStyle,
      allDayEventBorderColor: allDayEventBorderColor ?? this.allDayEventBorderColor,
      allDayEventBorderWidth: allDayEventBorderWidth ?? this.allDayEventBorderWidth,
      allDayEventPadding: allDayEventPadding ?? this.allDayEventPadding,
      // Retained own
      cellTextStyle: cellTextStyle ?? this.cellTextStyle,
      todayBackgroundColor: todayBackgroundColor ?? this.todayBackgroundColor,
      todayTextStyle: todayTextStyle ?? this.todayTextStyle,
      leadingDatesTextStyle: leadingDatesTextStyle ?? this.leadingDatesTextStyle,
      trailingDatesTextStyle: trailingDatesTextStyle ?? this.trailingDatesTextStyle,
      leadingDatesBackgroundColor: leadingDatesBackgroundColor ?? this.leadingDatesBackgroundColor,
      trailingDatesBackgroundColor: trailingDatesBackgroundColor ?? this.trailingDatesBackgroundColor,
      weekdayHeaderTextStyle: weekdayHeaderTextStyle ?? this.weekdayHeaderTextStyle,
      weekdayHeaderBackgroundColor: weekdayHeaderBackgroundColor ?? this.weekdayHeaderBackgroundColor,
      focusedDateBackgroundColor: focusedDateBackgroundColor ?? this.focusedDateBackgroundColor,
      focusedDateTextStyle: focusedDateTextStyle ?? this.focusedDateTextStyle,
      hoverCellBackgroundColor: hoverCellBackgroundColor ?? this.hoverCellBackgroundColor,
      dropTargetCellValidColor: dropTargetCellValidColor ?? this.dropTargetCellValidColor,
      dropTargetCellInvalidColor: dropTargetCellInvalidColor ?? this.dropTargetCellInvalidColor,
      dropTargetCellBorderRadius: dropTargetCellBorderRadius ?? this.dropTargetCellBorderRadius,
      dragSourceOpacity: dragSourceOpacity ?? this.dragSourceOpacity,
      draggedTileElevation: draggedTileElevation ?? this.draggedTileElevation,
      eventTileHeight: eventTileHeight ?? this.eventTileHeight,
      eventTileVerticalSpacing: eventTileVerticalSpacing ?? this.eventTileVerticalSpacing,
      dateLabelHeight: dateLabelHeight ?? this.dateLabelHeight,
      dateLabelPosition: dateLabelPosition ?? this.dateLabelPosition,
      overflowIndicatorHeight: overflowIndicatorHeight ?? this.overflowIndicatorHeight,
      eventTilePadding: eventTilePadding ?? this.eventTilePadding,
      defaultRegionColor: defaultRegionColor ?? this.defaultRegionColor,
      overlayScrimColor: overlayScrimColor ?? this.overlayScrimColor,
      errorIconColor: errorIconColor ?? this.errorIconColor,
      overflowIndicatorTextStyle: overflowIndicatorTextStyle ?? this.overflowIndicatorTextStyle,
      // New layout own
      dateLabelPadding: dateLabelPadding ?? this.dateLabelPadding,
      cellBorderWidth: cellBorderWidth ?? this.cellBorderWidth,
      regionContentPadding: regionContentPadding ?? this.regionContentPadding,
      regionIconSize: regionIconSize ?? this.regionIconSize,
      regionIconGap: regionIconGap ?? this.regionIconGap,
      regionFontSize: regionFontSize ?? this.regionFontSize,
      keyboardSelectionBorderWidth: keyboardSelectionBorderWidth ?? this.keyboardSelectionBorderWidth,
      keyboardHighlightBorderWidth: keyboardHighlightBorderWidth ?? this.keyboardHighlightBorderWidth,
      dateLabelCircleSize: dateLabelCircleSize ?? this.dateLabelCircleSize,
      weekNumberColumnWidth: weekNumberColumnWidth ?? this.weekNumberColumnWidth,
      weekNumberBorderWidth: weekNumberBorderWidth ?? this.weekNumberBorderWidth,
      weekdayHeaderPadding: weekdayHeaderPadding ?? this.weekdayHeaderPadding,
      multiDayTilePadding: multiDayTilePadding ?? this.multiDayTilePadding,
      multiDayTileBorderRadius: multiDayTileBorderRadius ?? this.multiDayTileBorderRadius,
      weekLayoutDateLabelPadding: weekLayoutDateLabelPadding ?? this.weekLayoutDateLabelPadding,
      weekLayoutBaseMargin: weekLayoutBaseMargin ?? this.weekLayoutBaseMargin,
      resizeHandleVisualWidth: resizeHandleVisualWidth ?? this.resizeHandleVisualWidth,
      resizeHandleVerticalMargin: resizeHandleVerticalMargin ?? this.resizeHandleVerticalMargin,
      resizeHandleBorderRadius: resizeHandleBorderRadius ?? this.resizeHandleBorderRadius,
    );
  }

  /// Linearly interpolates between this theme and [other] by [t].
  MCalMonthViewThemeData lerp(MCalMonthViewThemeData? other, double t) {
    if (other == null) return this;

    return MCalMonthViewThemeData(
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
      // AllDayTileThemeMixin
      allDayEventBackgroundColor: Color.lerp(allDayEventBackgroundColor, other.allDayEventBackgroundColor, t),
      allDayEventTextStyle: TextStyle.lerp(allDayEventTextStyle, other.allDayEventTextStyle, t),
      allDayEventBorderColor: Color.lerp(allDayEventBorderColor, other.allDayEventBorderColor, t),
      allDayEventBorderWidth: _lerpDouble(allDayEventBorderWidth, other.allDayEventBorderWidth, t),
      allDayEventPadding: EdgeInsets.lerp(allDayEventPadding, other.allDayEventPadding, t),
      // Retained own
      cellTextStyle: TextStyle.lerp(cellTextStyle, other.cellTextStyle, t),
      todayBackgroundColor: Color.lerp(todayBackgroundColor, other.todayBackgroundColor, t),
      todayTextStyle: TextStyle.lerp(todayTextStyle, other.todayTextStyle, t),
      leadingDatesTextStyle: TextStyle.lerp(leadingDatesTextStyle, other.leadingDatesTextStyle, t),
      trailingDatesTextStyle: TextStyle.lerp(trailingDatesTextStyle, other.trailingDatesTextStyle, t),
      leadingDatesBackgroundColor: Color.lerp(leadingDatesBackgroundColor, other.leadingDatesBackgroundColor, t),
      trailingDatesBackgroundColor: Color.lerp(trailingDatesBackgroundColor, other.trailingDatesBackgroundColor, t),
      weekdayHeaderTextStyle: TextStyle.lerp(weekdayHeaderTextStyle, other.weekdayHeaderTextStyle, t),
      weekdayHeaderBackgroundColor: Color.lerp(weekdayHeaderBackgroundColor, other.weekdayHeaderBackgroundColor, t),
      focusedDateBackgroundColor: Color.lerp(focusedDateBackgroundColor, other.focusedDateBackgroundColor, t),
      focusedDateTextStyle: TextStyle.lerp(focusedDateTextStyle, other.focusedDateTextStyle, t),
      hoverCellBackgroundColor: Color.lerp(hoverCellBackgroundColor, other.hoverCellBackgroundColor, t),
      dropTargetCellValidColor: Color.lerp(dropTargetCellValidColor, other.dropTargetCellValidColor, t),
      dropTargetCellInvalidColor: Color.lerp(dropTargetCellInvalidColor, other.dropTargetCellInvalidColor, t),
      dropTargetCellBorderRadius: _lerpDouble(dropTargetCellBorderRadius, other.dropTargetCellBorderRadius, t),
      dragSourceOpacity: _lerpDouble(dragSourceOpacity, other.dragSourceOpacity, t),
      draggedTileElevation: _lerpDouble(draggedTileElevation, other.draggedTileElevation, t),
      eventTileHeight: _lerpDouble(eventTileHeight, other.eventTileHeight, t),
      eventTileVerticalSpacing: _lerpDouble(eventTileVerticalSpacing, other.eventTileVerticalSpacing, t),
      dateLabelHeight: _lerpDouble(dateLabelHeight, other.dateLabelHeight, t),
      dateLabelPosition: t < 0.5 ? dateLabelPosition : other.dateLabelPosition,
      overflowIndicatorHeight: _lerpDouble(overflowIndicatorHeight, other.overflowIndicatorHeight, t),
      eventTilePadding: EdgeInsets.lerp(eventTilePadding, other.eventTilePadding, t),
      defaultRegionColor: Color.lerp(defaultRegionColor, other.defaultRegionColor, t),
      overlayScrimColor: Color.lerp(overlayScrimColor, other.overlayScrimColor, t),
      errorIconColor: Color.lerp(errorIconColor, other.errorIconColor, t),
      overflowIndicatorTextStyle: TextStyle.lerp(overflowIndicatorTextStyle, other.overflowIndicatorTextStyle, t),
      // New layout own
      dateLabelPadding: EdgeInsets.lerp(dateLabelPadding, other.dateLabelPadding, t),
      cellBorderWidth: _lerpDouble(cellBorderWidth, other.cellBorderWidth, t),
      regionContentPadding: EdgeInsets.lerp(regionContentPadding, other.regionContentPadding, t),
      regionIconSize: _lerpDouble(regionIconSize, other.regionIconSize, t),
      regionIconGap: _lerpDouble(regionIconGap, other.regionIconGap, t),
      regionFontSize: _lerpDouble(regionFontSize, other.regionFontSize, t),
      keyboardSelectionBorderWidth: _lerpDouble(keyboardSelectionBorderWidth, other.keyboardSelectionBorderWidth, t),
      keyboardHighlightBorderWidth: _lerpDouble(keyboardHighlightBorderWidth, other.keyboardHighlightBorderWidth, t),
      dateLabelCircleSize: _lerpDouble(dateLabelCircleSize, other.dateLabelCircleSize, t),
      weekNumberColumnWidth: _lerpDouble(weekNumberColumnWidth, other.weekNumberColumnWidth, t),
      weekNumberBorderWidth: _lerpDouble(weekNumberBorderWidth, other.weekNumberBorderWidth, t),
      weekdayHeaderPadding: EdgeInsets.lerp(weekdayHeaderPadding, other.weekdayHeaderPadding, t),
      multiDayTilePadding: EdgeInsets.lerp(multiDayTilePadding, other.multiDayTilePadding, t),
      multiDayTileBorderRadius: _lerpDouble(multiDayTileBorderRadius, other.multiDayTileBorderRadius, t),
      weekLayoutDateLabelPadding: _lerpDouble(weekLayoutDateLabelPadding, other.weekLayoutDateLabelPadding, t),
      weekLayoutBaseMargin: _lerpDouble(weekLayoutBaseMargin, other.weekLayoutBaseMargin, t),
      resizeHandleVisualWidth: _lerpDouble(resizeHandleVisualWidth, other.resizeHandleVisualWidth, t),
      resizeHandleVerticalMargin: _lerpDouble(resizeHandleVerticalMargin, other.resizeHandleVerticalMargin, t),
      resizeHandleBorderRadius: _lerpDouble(resizeHandleBorderRadius, other.resizeHandleBorderRadius, t),
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
      other is MCalMonthViewThemeData &&
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
          // AllDayTileThemeMixin
          allDayEventBackgroundColor == other.allDayEventBackgroundColor &&
          allDayEventTextStyle == other.allDayEventTextStyle &&
          allDayEventBorderColor == other.allDayEventBorderColor &&
          allDayEventBorderWidth == other.allDayEventBorderWidth &&
          allDayEventPadding == other.allDayEventPadding &&
          // Retained own
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
          hoverCellBackgroundColor == other.hoverCellBackgroundColor &&
          dropTargetCellValidColor == other.dropTargetCellValidColor &&
          dropTargetCellInvalidColor == other.dropTargetCellInvalidColor &&
          dropTargetCellBorderRadius == other.dropTargetCellBorderRadius &&
          dragSourceOpacity == other.dragSourceOpacity &&
          draggedTileElevation == other.draggedTileElevation &&
          eventTileHeight == other.eventTileHeight &&
          eventTileVerticalSpacing == other.eventTileVerticalSpacing &&
          dateLabelHeight == other.dateLabelHeight &&
          dateLabelPosition == other.dateLabelPosition &&
          overflowIndicatorHeight == other.overflowIndicatorHeight &&
          eventTilePadding == other.eventTilePadding &&
          defaultRegionColor == other.defaultRegionColor &&
          overlayScrimColor == other.overlayScrimColor &&
          errorIconColor == other.errorIconColor &&
          overflowIndicatorTextStyle == other.overflowIndicatorTextStyle &&
          // New layout own
          dateLabelPadding == other.dateLabelPadding &&
          cellBorderWidth == other.cellBorderWidth &&
          regionContentPadding == other.regionContentPadding &&
          regionIconSize == other.regionIconSize &&
          regionIconGap == other.regionIconGap &&
          regionFontSize == other.regionFontSize &&
          keyboardSelectionBorderWidth == other.keyboardSelectionBorderWidth &&
          keyboardHighlightBorderWidth == other.keyboardHighlightBorderWidth &&
          dateLabelCircleSize == other.dateLabelCircleSize &&
          weekNumberColumnWidth == other.weekNumberColumnWidth &&
          weekNumberBorderWidth == other.weekNumberBorderWidth &&
          weekdayHeaderPadding == other.weekdayHeaderPadding &&
          multiDayTilePadding == other.multiDayTilePadding &&
          multiDayTileBorderRadius == other.multiDayTileBorderRadius &&
          weekLayoutDateLabelPadding == other.weekLayoutDateLabelPadding &&
          weekLayoutBaseMargin == other.weekLayoutBaseMargin &&
          resizeHandleVisualWidth == other.resizeHandleVisualWidth &&
          resizeHandleVerticalMargin == other.resizeHandleVerticalMargin &&
          resizeHandleBorderRadius == other.resizeHandleBorderRadius;

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
        // AllDayTileThemeMixin
        allDayEventBackgroundColor,
        allDayEventTextStyle,
        allDayEventBorderColor,
        allDayEventBorderWidth,
        allDayEventPadding,
        // Retained own
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
        eventTileHeight,
        eventTileVerticalSpacing,
        dateLabelHeight,
        dateLabelPosition,
        overflowIndicatorHeight,
        eventTilePadding,
        defaultRegionColor,
        overlayScrimColor,
        errorIconColor,
        overflowIndicatorTextStyle,
        // New layout own
        dateLabelPadding,
        cellBorderWidth,
        regionContentPadding,
        regionIconSize,
        regionIconGap,
        regionFontSize,
        keyboardSelectionBorderWidth,
        keyboardHighlightBorderWidth,
        dateLabelCircleSize,
        weekNumberColumnWidth,
        weekNumberBorderWidth,
        weekdayHeaderPadding,
        multiDayTilePadding,
        multiDayTileBorderRadius,
        weekLayoutDateLabelPadding,
        weekLayoutBaseMargin,
        resizeHandleVisualWidth,
        resizeHandleVerticalMargin,
        resizeHandleBorderRadius,
      ]);
}
