import 'package:flutter/material.dart';

/// Resolves the background color for an event tile using the standard cascade.
///
/// [ignoreEventColors] controls the priority between event and theme colors:
/// - `false` (default): `eventColor` → `allDayThemeColor` → `themeColor` → `defaultColor`
/// - `true`: `allDayThemeColor` → `themeColor` → `eventColor` → `defaultColor`
///
/// In both modes, [eventColor] participates as a fallback — it is never
/// skipped entirely. This ensures a color is always resolved even when the
/// consumer theme has not set the relevant properties.
///
/// For all-day or multi-day tiles, pass [allDayThemeColor] (e.g.
/// `theme.allDayEventBackgroundColor`) as a higher-priority theme color and
/// [themeColor] as the secondary (e.g. `theme.eventTileBackgroundColor`).
Color resolveEventTileColor({
  required Color? themeColor,
  Color? allDayThemeColor,
  required Color? eventColor,
  required bool ignoreEventColors,
  required Color defaultColor,
}) {
  if (ignoreEventColors) {
    return allDayThemeColor ?? themeColor ?? eventColor ?? defaultColor;
  } else {
    return eventColor ?? allDayThemeColor ?? themeColor ?? defaultColor;
  }
}

/// Resolves the background color for a drop target tile.
///
/// [dropTargetThemeColor] (e.g. `theme.dayTheme?.dropTargetTileBackgroundColor`)
/// takes first priority. If null, falls through to the standard event tile
/// cascade via [resolveEventTileColor] (which respects [ignoreEventColors]).
///
/// Pass [allDayThemeColor] when the dragged event is all-day or multi-day
/// (e.g. `theme.allDayEventBackgroundColor`) so the full cascade is respected.
Color resolveDropTargetTileColor({
  required Color? dropTargetThemeColor,
  required Color? themeColor,
  Color? allDayThemeColor,
  required Color? eventColor,
  required bool ignoreEventColors,
  required Color defaultColor,
}) {
  if (dropTargetThemeColor != null) return dropTargetThemeColor;
  return resolveEventTileColor(
    themeColor: themeColor,
    allDayThemeColor: allDayThemeColor,
    eventColor: eventColor,
    ignoreEventColors: ignoreEventColors,
    defaultColor: defaultColor,
  );
}

/// Resolves a contrast color for text on a tile with the given [backgroundColor].
///
/// Uses luminance to choose between [lightContrastColor] (for dark backgrounds)
/// and [darkContrastColor] (for light backgrounds). The luminance threshold
/// follows the standard perceptual weighting (0.299 R, 0.587 G, 0.114 B).
Color resolveContrastColor({
  required Color backgroundColor,
  required Color lightContrastColor,
  required Color darkContrastColor,
}) {
  final luminance = 0.299 * backgroundColor.r +
      0.587 * backgroundColor.g +
      0.114 * backgroundColor.b;
  return luminance > 0.5 ? darkContrastColor : lightContrastColor;
}
