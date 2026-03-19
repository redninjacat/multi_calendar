import 'package:flutter/material.dart';

/// Mixin defining the abstract property contract for all-day event tile
/// appearance: background color, text style, border, and padding.
///
/// These properties allow consumers to style all-day events differently from
/// timed events in any view. The cascade logic mirrors [MCalEventTileThemeMixin]:
/// when [enableEventColorOverrides] is false, per-event colors take precedence;
/// when true, these theme colors override them.
///
/// Mixed into both [MCalMonthViewThemeData] and [MCalDayViewThemeData].
/// Future view theme classes (e.g., MCalMultiDayViewThemeData) should also
/// mix in this contract.
///
/// Implementing classes declare matching `@override final` fields.
mixin MCalAllDayTileThemeMixin {
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

  /// Inner content padding for all-day event tiles.
  ///
  /// Controls the space between the tile border and its content.
  EdgeInsets? get allDayEventPadding;
}
