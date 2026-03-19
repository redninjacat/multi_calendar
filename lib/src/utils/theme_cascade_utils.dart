import 'package:flutter/material.dart';

/// Resolves the background color for an event tile using the standard cascade.
///
/// [enableEventColorOverrides] controls the priority between event and theme colors:
/// - `false` (default): `eventColor` → `allDayThemeColor` → `themeColor` → `defaultColor`
/// - `true`: `allDayThemeColor` → `themeColor` → `eventColor` → `defaultColor`
///
/// In both modes, [eventColor] participates as a fallback — it is never
/// skipped entirely. This ensures a color is always resolved even when the
/// consumer theme has not set the relevant properties.
///
/// For all-day or multi-day tiles, pass [allDayThemeColor] (e.g.
/// `theme.dayViewTheme?.allDayEventBackgroundColor`) as a higher-priority
/// theme color and [themeColor] as the secondary (e.g.
/// `theme.dayViewTheme?.eventTileBackgroundColor`).
Color resolveEventTileColor({
  required Color? themeColor,
  Color? allDayThemeColor,
  required Color? eventColor,
  required bool enableEventColorOverrides,
  required Color defaultColor,
}) {
  if (enableEventColorOverrides) {
    return allDayThemeColor ?? themeColor ?? eventColor ?? defaultColor;
  } else {
    return eventColor ?? allDayThemeColor ?? themeColor ?? defaultColor;
  }
}

/// Resolves the background color for a drop target tile.
///
/// [dropTargetThemeColor] (e.g. `theme.dayViewTheme?.dropTargetTileBackgroundColor`)
/// takes first priority. If null, falls through to the standard event tile
/// cascade via [resolveEventTileColor] (which respects [enableEventColorOverrides]).
///
/// Pass [allDayThemeColor] when the dragged event is all-day or multi-day
/// (e.g. `theme.dayViewTheme?.allDayEventBackgroundColor`) so the full cascade
/// is respected.
Color resolveDropTargetTileColor({
  required Color? dropTargetThemeColor,
  required Color? themeColor,
  Color? allDayThemeColor,
  required Color? eventColor,
  required bool enableEventColorOverrides,
  required Color defaultColor,
}) {
  if (dropTargetThemeColor != null) return dropTargetThemeColor;
  return resolveEventTileColor(
    themeColor: themeColor,
    allDayThemeColor: allDayThemeColor,
    eventColor: eventColor,
    enableEventColorOverrides: enableEventColorOverrides,
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
  // Alpha-composite against white to get the effective visual color,
  // so semi-transparent colors on light surfaces resolve correctly.
  final a = backgroundColor.a;
  final effectiveR = backgroundColor.r * a + (1.0 - a);
  final effectiveG = backgroundColor.g * a + (1.0 - a);
  final effectiveB = backgroundColor.b * a + (1.0 - a);
  final luminance = 0.299 * effectiveR + 0.587 * effectiveG + 0.114 * effectiveB;
  return luminance > 0.5 ? darkContrastColor : lightContrastColor;
}
