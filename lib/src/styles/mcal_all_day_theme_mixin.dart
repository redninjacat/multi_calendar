import 'package:flutter/material.dart';

/// Mixin defining the abstract property contract for all-day event section
/// theming: colors, tile sizing, section layout, and overflow handle styling.
///
/// Properties in this mixin come from three sources:
/// - 4 moved from `MCalThemeData` (parent): color and style properties
/// - 4 moved from `MCalDayViewThemeData`: sizing properties
/// - 9 new layout properties replacing hardcoded values in `all_day_events_section.dart`
///
/// Currently mixed into [MCalDayViewThemeData]. Future views with all-day
/// sections (e.g., Multi-Day View) should also mix in this contract.
///
/// Implementing classes declare matching `@override final` fields.
mixin MCalAllDayThemeMixin {
  // ── Colors / styles (moved from MCalThemeData parent) ────────────────────

  /// Background color for all-day event tiles.
  ///
  /// This is the cascade-eligible color for all-day event tiles: when
  /// [enableEventColorOverrides] is false, per-event colors take precedence.
  Color? get allDayEventBackgroundColor;

  /// Text style for the event title inside all-day event tiles.
  TextStyle? get allDayEventTextStyle;

  /// Border color for all-day event tiles.
  Color? get allDayEventBorderColor;

  /// Border width for all-day event tiles (in pixels).
  double? get allDayEventBorderWidth;

  // ── Sizing (moved from MCalDayViewThemeData) ──────────────────────────────

  /// Fixed width for all-day event tiles (in pixels).
  ///
  /// Using a fixed width enables deterministic layout: the number of tiles per
  /// row is computed as `(availableWidth + spacing) / (tileWidth + spacing)`,
  /// eliminating dependence on font metrics or content length.
  double? get allDayTileWidth;

  /// Fixed height for all-day event tiles (in pixels).
  double? get allDayTileHeight;

  /// Inner content padding for all-day event tiles.
  ///
  /// Controls the space between the tile border and its content.
  EdgeInsets? get allDayEventPadding;

  /// Fixed width for the all-day overflow indicator tile (in pixels).
  ///
  /// The overflow indicator occupies one tile slot in the Wrap layout.
  /// Its height matches [allDayTileHeight].
  double? get allDayOverflowIndicatorWidth;

  // ── New layout properties ─────────────────────────────────────────────────

  /// Horizontal spacing between all-day event tiles in the Wrap layout (in pixels).
  ///
  /// Replaces the hardcoded `4.0` in `all_day_events_section.dart`.
  double? get allDayWrapSpacing;

  /// Vertical run spacing between rows in the all-day Wrap layout (in pixels).
  ///
  /// Replaces the hardcoded `4.0` in `all_day_events_section.dart`.
  double? get allDayWrapRunSpacing;

  /// Padding around the all-day section container.
  ///
  /// Replaces the hardcoded `EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0)`
  /// in `all_day_events_section.dart`.
  EdgeInsets? get allDaySectionPadding;

  /// Border width for the keyboard focus ring on focused all-day tiles (in pixels).
  ///
  /// Replaces the hardcoded `2` in `all_day_events_section.dart`.
  double? get allDayKeyboardFocusBorderWidth;

  /// Visual width of the overflow handle bar (in pixels).
  ///
  /// Replaces the hardcoded `3` (width) in `all_day_events_section.dart`.
  double? get allDayOverflowHandleWidth;

  /// Visual height of the overflow handle bar (in pixels).
  ///
  /// Replaces the hardcoded `16` (height) in `all_day_events_section.dart`.
  double? get allDayOverflowHandleHeight;

  /// Border radius of the overflow handle bar (in pixels).
  ///
  /// Replaces the hardcoded `1.5` in `all_day_events_section.dart`.
  double? get allDayOverflowHandleBorderRadius;

  /// Horizontal gap between the overflow handle bar and the indicator text (in pixels).
  ///
  /// Replaces the hardcoded `4` (SizedBox width) in `all_day_events_section.dart`.
  double? get allDayOverflowHandleGap;

  /// Font size for the overflow count text ('+N more') in the overflow indicator (in pixels).
  ///
  /// Replaces the hardcoded `11` in `all_day_events_section.dart`.
  double? get allDayOverflowIndicatorFontSize;

  /// Border width of the all-day overflow indicator container (in pixels).
  ///
  /// Replaces the hardcoded `1.0` (border width) in
  /// `all_day_events_section.dart`.
  double? get allDayOverflowIndicatorBorderWidth;

  /// Bottom padding below the "All-day" label text (in pixels).
  ///
  /// Controls the spacing between the label and the tile wrap layout.
  /// Replaces the hardcoded `4.0` (`EdgeInsets.only(bottom: 4.0)`) in
  /// `all_day_events_section.dart`.
  double? get allDaySectionLabelBottomPadding;
}
