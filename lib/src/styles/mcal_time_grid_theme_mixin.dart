import 'package:flutter/material.dart';
import '../widgets/mcal_day_view_contexts.dart';

/// Mixin defining the abstract property contract for time-grid theming.
///
/// This covers the time legend, gridlines, current time indicator, time
/// regions, timed events, hover/focus slots, drop target overlays, and
/// related layout values. Properties in this mixin were previously declared
/// directly on `MCalDayViewThemeData`.
///
/// Currently mixed into [MCalDayViewThemeData]. Future time-grid-based views
/// (Multi-Day, Pivoted Multi-Day) should also mix in this contract.
///
/// Implementing classes declare matching `@override final` fields.
mixin MCalTimeGridThemeMixin {
  // ── Time legend ───────────────────────────────────────────────────────────

  /// Width of the time legend column (in pixels).
  double? get timeLegendWidth;

  /// Text style for time labels in the time legend.
  TextStyle? get timeLegendTextStyle;

  /// Background color for the time legend column.
  Color? get timeLegendBackgroundColor;

  /// Color for time legend tick marks.
  Color? get timeLegendTickColor;

  /// Width (thickness) of time legend tick marks (in pixels).
  double? get timeLegendTickWidth;

  /// Length of time legend tick marks (in pixels).
  double? get timeLegendTickLength;

  /// Whether to show tick marks on the time legend.
  bool? get showTimeLegendTicks;

  /// Position for time labels relative to hour gridlines.
  MCalTimeLabelPosition? get timeLabelPosition;

  /// Height of each time label slot in the time legend (in pixels).
  ///
  /// Replaces the hardcoded `20.0` value in `time_legend_column.dart`.
  double? get timeLegendLabelHeight;

  // ── Gridlines ─────────────────────────────────────────────────────────────

  /// Color for hour gridlines.
  Color? get hourGridlineColor;

  /// Width of hour gridlines (in pixels).
  double? get hourGridlineWidth;

  /// Color for major gridlines (e.g., 30-minute marks).
  Color? get majorGridlineColor;

  /// Width of major gridlines (in pixels).
  double? get majorGridlineWidth;

  /// Color for minor gridlines (e.g., 15-minute marks).
  Color? get minorGridlineColor;

  /// Width of minor gridlines (in pixels).
  double? get minorGridlineWidth;

  // ── Current time indicator ────────────────────────────────────────────────

  /// Color for the current time indicator line.
  Color? get currentTimeIndicatorColor;

  /// Width of the current time indicator line (in pixels).
  double? get currentTimeIndicatorWidth;

  /// Radius of the dot at the start of the current time indicator (in pixels).
  double? get currentTimeIndicatorDotRadius;

  // ── Time regions ──────────────────────────────────────────────────────────

  /// Background color for special (non-blocking) time regions.
  Color? get specialTimeRegionColor;

  /// Background color for blocked time regions.
  Color? get blockedTimeRegionColor;

  /// Border color for time region overlays.
  Color? get timeRegionBorderColor;

  /// Text color for labels inside time regions.
  Color? get timeRegionTextColor;

  /// Text style for labels inside time regions.
  TextStyle? get timeRegionTextStyle;

  /// Border width for time region overlays (in pixels).
  ///
  /// Replaces the hardcoded `1` value in `time_regions_layer.dart`.
  double? get timeRegionBorderWidth;

  /// Icon size for icons displayed inside time regions (in pixels).
  ///
  /// Replaces the hardcoded `16` value in `time_regions_layer.dart`.
  double? get timeRegionIconSize;

  /// Horizontal gap between the time region icon and its text label (in pixels).
  ///
  /// Replaces the hardcoded `4` (SizedBox width) in `time_regions_layer.dart`.
  double? get timeRegionIconGap;

  // ── Timed events ──────────────────────────────────────────────────────────

  /// Minimum height for timed event tiles (in pixels).
  double? get timedEventMinHeight;

  /// Padding inside timed event tiles.
  EdgeInsets? get timedEventPadding;

  /// Margin around each timed event tile in the grid (in pixels).
  ///
  /// Replaces the hardcoded `EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0)`
  /// in `time_grid_events_layer.dart`.
  EdgeInsets? get timedEventMargin;

  /// Border width for the keyboard focus ring on focused timed event tiles (in pixels).
  ///
  /// Replaces the hardcoded `2` in `time_grid_events_layer.dart`.
  double? get timedEventKeyboardFocusBorderWidth;

  /// Font size for timed event tile title text when the tile is compact (in pixels).
  ///
  /// Replaces the hardcoded `10` in `time_grid_events_layer.dart`.
  double? get timedEventCompactFontSize;

  /// Font size for timed event tile title text at normal size (in pixels).
  ///
  /// Replaces the hardcoded `12` in `time_grid_events_layer.dart`.
  double? get timedEventNormalFontSize;

  /// Vertical gap between the event title and time range text inside timed
  /// event tiles (in pixels).
  ///
  /// Replaces the hardcoded `2.0` (`EdgeInsets.only(top: 2.0)`) in
  /// `time_grid_events_layer.dart`.
  double? get timedEventTitleTimeGap;

  // ── Hover / Focus slots ────────────────────────────────────────────────────

  /// Background color when hovering over time slots on hover-capable platforms.
  Color? get hoverTimeSlotBackgroundColor;

  /// Background color for the focused time slot in Navigation Mode.
  Color? get focusedSlotBackgroundColor;

  /// Border color for the Navigation Mode focused time slot indicator.
  Color? get focusedSlotBorderColor;

  /// Border width for the Navigation Mode focused time slot indicator (in pixels).
  double? get focusedSlotBorderWidth;

  /// Full decoration for the focused time slot (takes precedence over color).
  BoxDecoration? get focusedSlotDecoration;

  // ── Drop target overlay ────────────────────────────────────────────────────

  /// Color for the valid drop target overlay.
  Color? get dropTargetOverlayValidColor;

  /// Color for the invalid drop target overlay.
  Color? get dropTargetOverlayInvalidColor;

  /// Width of the accent bar on the drop target overlay (in pixels).
  double? get dropTargetOverlayBorderWidth;

  /// Color of the accent bar on the drop target overlay.
  Color? get dropTargetOverlayBorderColor;

  // ── Other ─────────────────────────────────────────────────────────────────

  /// Color for the disabled time slot fill.
  Color? get disabledTimeSlotColor;

  /// Border color for the keyboard focus ring on focused event tiles.
  Color? get keyboardFocusBorderColor;

  /// Border radius of the keyboard focus ring on focused event tiles (in pixels).
  ///
  /// Applies to both timed event and all-day event keyboard focus indicators.
  /// Replaces the hardcoded `4` (`BorderRadius.circular(4)`) in
  /// `time_grid_events_layer.dart` and `all_day_events_section.dart`.
  double? get keyboardFocusBorderRadius;

  /// Hit area size for resize handles on timed events (in logical pixels).
  double? get resizeHandleSize;

  /// Minimum event duration (in minutes) required to show resize handles.
  int? get minResizeDurationMinutes;

  // ── Resize handle visual dimensions ───────────────────────────────────────

  /// Visual height of the resize handle bar (in pixels).
  ///
  /// Replaces the hardcoded `2` (height) in `time_resize_handle.dart`.
  double? get resizeHandleVisualHeight;

  /// Horizontal margin on each side of the resize handle bar (in pixels).
  ///
  /// The bar width is computed as `tileWidth - (resizeHandleHorizontalMargin * 2)`.
  /// Replaces the hardcoded `4` in `time_resize_handle.dart`.
  double? get resizeHandleHorizontalMargin;

  /// Border radius of the resize handle bar (in pixels).
  ///
  /// Replaces the hardcoded `1` in `time_resize_handle.dart`.
  double? get resizeHandleBorderRadius;
}
