import 'package:flutter/material.dart';

/// Mixin defining the abstract property contract for the Day View all-day
/// event *section* layout: tile sizing, wrap spacing, overflow handle styling,
/// and section-level padding.
///
/// Tile appearance properties (background color, text style, border, padding)
/// live in [MCalAllDayTileThemeMixin], which is shared with Month View.
///
/// This mixin is specific to views that render a dedicated all-day section
/// with a Wrap layout (currently [MCalDayViewThemeData]). Future views with
/// similar sections (e.g., Multi-Day View) should also mix in this contract.
///
/// Implementing classes declare matching `@override final` fields.
mixin MCalAllDaySectionThemeMixin {
  // ── Sizing ─────────────────────────────────────────────────────────────────

  /// Fixed width for all-day event tiles (in pixels).
  ///
  /// Using a fixed width enables deterministic layout: the number of tiles per
  /// row is computed as `(availableWidth + spacing) / (tileWidth + spacing)`,
  /// eliminating dependence on font metrics or content length.
  double? get allDayTileWidth;

  /// Fixed height for all-day event tiles (in pixels).
  double? get allDayTileHeight;

  /// Fixed width for the all-day overflow indicator tile (in pixels).
  ///
  /// The overflow indicator occupies one tile slot in the Wrap layout.
  /// Its height matches [allDayTileHeight].
  double? get allDayOverflowIndicatorWidth;

  // ── Layout ─────────────────────────────────────────────────────────────────

  /// Horizontal spacing between all-day event tiles in the Wrap layout (in pixels).
  double? get allDayWrapSpacing;

  /// Vertical run spacing between rows in the all-day Wrap layout (in pixels).
  double? get allDayWrapRunSpacing;

  /// Padding around the all-day section container.
  EdgeInsets? get allDaySectionPadding;

  // ── Overflow handle ────────────────────────────────────────────────────────

  /// Visual width of the overflow handle bar (in pixels).
  double? get allDayOverflowHandleWidth;

  /// Visual height of the overflow handle bar (in pixels).
  double? get allDayOverflowHandleHeight;

  /// Border radius of the overflow handle bar (in pixels).
  double? get allDayOverflowHandleBorderRadius;

  /// Horizontal gap between the overflow handle bar and the indicator text (in pixels).
  double? get allDayOverflowHandleGap;

  /// Font size for the overflow count text ('+N more') in the overflow indicator (in pixels).
  double? get allDayOverflowIndicatorFontSize;

  /// Border width of the all-day overflow indicator container (in pixels).
  double? get allDayOverflowIndicatorBorderWidth;

  /// Bottom padding below the "All-day" label text (in pixels).
  ///
  /// Controls the spacing between the label and the tile wrap layout.
  double? get allDaySectionLabelBottomPadding;
}
