import 'package:flutter/material.dart';

/// Mixin defining the abstract property contract for event tile appearance,
/// hover, contrast, drop target tiles, resize handle, week number, and
/// multi-day event theming.
///
/// This mixin is shared by [MCalDayViewThemeData] and [MCalMonthViewThemeData],
/// ensuring each view can independently theme its event tiles without
/// duplicating property definitions. Future view theme classes (e.g.,
/// MCalMultiDayViewThemeData) should also mix in this contract.
///
/// Implementing classes declare matching `@override final` fields.
mixin MCalEventTileThemeMixin {
  // ── Event tile appearance ─────────────────────────────────────────────────

  /// Background color for standard event tiles.
  ///
  /// This is the cascade-eligible color: when [enableEventColorOverrides] is
  /// false, per-event colors take precedence. When true, this overrides them.
  Color? get eventTileBackgroundColor;

  /// Text style for event title text inside tiles.
  TextStyle? get eventTileTextStyle;

  /// Corner radius for event tile borders (in pixels).
  double? get eventTileCornerRadius;

  /// Horizontal spacing between adjacent event tiles in the same row (in pixels).
  double? get eventTileHorizontalSpacing;

  /// Border width for event tiles (in pixels). Defaults to 0.0 (no border).
  double? get eventTileBorderWidth;

  /// Border color for event tiles. Only visible when [eventTileBorderWidth] > 0.
  Color? get eventTileBorderColor;

  // ── Hover ─────────────────────────────────────────────────────────────────

  /// Background color applied to event tiles when hovered on pointer devices.
  Color? get hoverEventBackgroundColor;

  // ── Contrast ──────────────────────────────────────────────────────────────

  /// Text color used when the event tile background is light.
  ///
  /// The cascade utility selects this color when the tile background
  /// is determined to be light (high luminance).
  Color? get eventTileLightContrastColor;

  /// Text color used when the event tile background is dark.
  ///
  /// The cascade utility selects this color when the tile background
  /// is determined to be dark (low luminance).
  Color? get eventTileDarkContrastColor;

  // ── Week number ───────────────────────────────────────────────────────────

  /// Text style for the week number label displayed in some views.
  TextStyle? get weekNumberTextStyle;

  /// Background color for the week number badge.
  Color? get weekNumberBackgroundColor;

  // ── Drop target tile ──────────────────────────────────────────────────────

  /// Background color for valid drop target preview tiles.
  Color? get dropTargetTileBackgroundColor;

  /// Background color for invalid drop target preview tiles.
  Color? get dropTargetTileInvalidBackgroundColor;

  /// Corner radius for drop target preview tiles (in pixels).
  double? get dropTargetTileCornerRadius;

  /// Border color for drop target preview tiles.
  Color? get dropTargetTileBorderColor;

  /// Border width for drop target preview tiles (in pixels).
  double? get dropTargetTileBorderWidth;

  // ── Resize handle ─────────────────────────────────────────────────────────

  /// Color for event tile resize handles.
  Color? get resizeHandleColor;

  // ── Multi-day events ──────────────────────────────────────────────────────

  /// Background color for multi-day event tiles.
  ///
  /// This is the cascade-eligible color for multi-day event tiles. In Month
  /// View this colors the horizontal bar segments; in Day View it colors
  /// multi-day events that appear in the all-day section or as timed tiles.
  Color? get multiDayEventBackgroundColor;
}
