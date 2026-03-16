import 'package:flutter/material.dart';
// ignore: unused_import
import '../widgets/mcal_month_week_layout_contexts.dart' show DateLabelPosition;
import 'mcal_day_theme_data.dart';
import 'mcal_month_theme_data.dart';

// Re-export DateLabelPosition so it's accessible from this file's exports
export '../widgets/mcal_month_week_layout_contexts.dart' show DateLabelPosition;

/// An InheritedWidget that provides [MCalThemeData] to descendant widgets.
///
/// This widget enables calendar components to access theme data through the
/// widget tree without explicitly passing it through constructors.
///
/// Use [MCalTheme.of] to obtain the theme data with automatic fallback chain,
/// or [MCalTheme.maybeOf] to optionally retrieve the theme without fallbacks.
///
/// Example:
/// ```dart
/// MCalTheme(
///   data: MCalThemeData(
///     eventTileBackgroundColor: Colors.blue,
///     dayTheme: MCalDayThemeData(timeLegendWidth: 72.0),
///   ),
///   child: MCalMonthView(
///     controller: controller,
///   ),
/// )
/// ```
///
/// Within a calendar widget, access the theme via:
/// ```dart
/// final theme = MCalTheme.of(context);
/// ```
class MCalTheme extends InheritedWidget {
  /// Creates an [MCalTheme] widget.
  ///
  /// The [data] and [child] arguments must not be null.
  const MCalTheme({super.key, required this.data, required super.child});

  /// The theme data for calendar widgets.
  final MCalThemeData data;

  /// Returns the [MCalThemeData] from the closest [MCalTheme] ancestor,
  /// with a fallback chain if no ancestor is found.
  ///
  /// The fallback chain is:
  /// 1. Returns the consumer [MCalTheme] ancestor data as-is (nulls preserved).
  /// 2. Returns the [ThemeExtension<MCalThemeData>] from [Theme.of(context)] as-is.
  /// 3. Returns [MCalThemeData()] — all properties null — as a final fallback.
  ///
  /// **Master defaults**: Widgets resolve null properties by obtaining
  /// `MCalThemeData.fromTheme(Theme.of(context))` at the point of use.
  /// This ensures fallback values always reflect the app's current
  /// [ThemeData] (color scheme, text theme) rather than being injected as
  /// part of the consumer's theme.
  ///
  /// This method never returns null — it always provides a valid [MCalThemeData].
  ///
  /// Example:
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   final theme = MCalTheme.of(context);
  ///   final defaults = MCalThemeData.fromTheme(Theme.of(context));
  ///   final color = theme.eventTileBackgroundColor ?? defaults.eventTileBackgroundColor!;
  /// }
  /// ```
  static MCalThemeData of(BuildContext context) {
    // Step 1: Try to find MCalTheme ancestor — return as-is, nulls preserved.
    final inheritedTheme =
        context.dependOnInheritedWidgetOfExactType<MCalTheme>();
    if (inheritedTheme != null) return inheritedTheme.data;

    // Step 2: Try ThemeExtension — return as-is, nulls preserved.
    final extension = Theme.of(context).extension<MCalThemeData>();
    if (extension != null) return extension;

    // Step 3: No ancestor found — all-null fallback. Widgets use master
    // defaults (MCalThemeData.fromTheme) to resolve individual properties.
    return const MCalThemeData();
  }

  /// Returns the [MCalThemeData] from the closest [MCalTheme] ancestor,
  /// or null if there is no [MCalTheme] ancestor.
  ///
  /// Unlike [of], this method does not use the fallback chain and does not
  /// look for [MCalThemeData] in [ThemeExtension] or call [MCalThemeData.fromTheme].
  ///
  /// Use this method when you want to know if an explicit [MCalTheme] was
  /// provided in the widget tree.
  ///
  /// Example:
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   final theme = MCalTheme.maybeOf(context);
  ///   if (theme == null) {
  ///     // No MCalTheme ancestor found
  ///   }
  /// }
  /// ```
  static MCalThemeData? maybeOf(BuildContext context) {
    final inheritedTheme = context
        .dependOnInheritedWidgetOfExactType<MCalTheme>();
    return inheritedTheme?.data;
  }

  @override
  bool updateShouldNotify(MCalTheme oldWidget) {
    return data != oldWidget.data;
  }
}

/// A theme extension for customizing calendar-specific styling.
///
/// This class extends Flutter's ThemeExtension to provide calendar-specific
/// theme properties that integrate seamlessly with Flutter's ThemeData system.
/// View-specific properties are organized in [monthTheme] and [dayTheme].
/// Shared properties used by multiple views remain in the root.
///
/// ## Three-tier cascade model
///
/// Calendar widgets resolve visual properties through a three-tier cascade:
///
/// 1. **Event color** — the color carried on the [MCalCalendarEvent] itself.
/// 2. **Consumer theme** — the [MCalThemeData] provided via [MCalTheme] or
///    `ThemeData.extensions`.
/// 3. **Master defaults** — `MCalThemeData.fromTheme(Theme.of(context))`,
///    computed once per build from the current [ThemeData]. Widgets fall back
///    to these only when the consumer theme leaves a property `null`.
///
/// The [ignoreEventColors] flag switches the priority between tiers 1 and 2:
///
/// * `ignoreEventColors: false` (default):
///   `event color → allDayThemeColor → consumer theme → master defaults`
/// * `ignoreEventColors: true`:
///   `allDayThemeColor → consumer theme → event color → master defaults`
///
/// Setting [ignoreEventColors] to `true` lets the consumer theme fully control
/// tile colours regardless of per-event [MCalCalendarEvent.color] values.
///
/// ## Usage
///
/// ```dart
/// // As an InheritedWidget (preferred for subtree-scoped theming):
/// MCalTheme(
///   data: MCalThemeData(
///     eventTileBackgroundColor: Colors.green,
///     dayTheme: MCalDayThemeData(timeLegendWidth: 72.0),
///     monthTheme: MCalMonthThemeData(eventTileHeight: 24.0),
///   ),
///   child: MCalMonthView(controller: controller),
/// )
///
/// // As a ThemeData extension (global theming):
/// ThemeData(
///   extensions: [
///     MCalThemeData(
///       eventTileBackgroundColor: Colors.green,
///       dayTheme: MCalDayThemeData(timeLegendWidth: 72.0),
///       monthTheme: MCalMonthThemeData(eventTileHeight: 24.0),
///     ),
///   ],
/// )
/// ```
class MCalThemeData extends ThemeExtension<MCalThemeData> {
  /// Shared: Background color for calendar cells.
  final Color? cellBackgroundColor;

  /// Shared: Border color for calendar cells.
  final Color? cellBorderColor;

  /// Shared: Background color for event tiles.
  final Color? eventTileBackgroundColor;

  /// Shared: Text style for event tiles.
  final TextStyle? eventTileTextStyle;

  /// Shared: Text style for the month navigator (month/year display and controls).
  final TextStyle? navigatorTextStyle;

  /// Shared: Background color for the month navigator.
  final Color? navigatorBackgroundColor;

  /// Shared: Background color for all-day event tiles.
  final Color? allDayEventBackgroundColor;

  /// Shared: Text style for all-day event tiles.
  final TextStyle? allDayEventTextStyle;

  /// Shared: Border color for all-day event tiles.
  final Color? allDayEventBorderColor;

  /// Shared: Border width for all-day event tiles.
  final double? allDayEventBorderWidth;

  /// Shared: Text style for week numbers.
  final TextStyle? weekNumberTextStyle;

  /// Shared: Background color for the week number column.
  final Color? weekNumberBackgroundColor;

  /// Shared: Corner radius for event tiles.
  final double? eventTileCornerRadius;

  /// Shared: Horizontal spacing around event tiles in pixels.
  final double? eventTileHorizontalSpacing;

  /// Shared: Whether to ignore individual event colors and use [eventTileBackgroundColor].
  ///
  /// When `false` (default), the cascade order is:
  /// `event color → allDayThemeColor → theme color → master defaults`.
  ///
  /// When `true`, the cascade order is:
  /// `allDayThemeColor → theme color → event color → master defaults`.
  ///
  /// This allows the consumer theme to fully control tile colours
  /// regardless of per-event [MCalCalendarEvent.color] values.
  final bool ignoreEventColors;

  /// Shared: Background color for event tiles on hover.
  ///
  /// Applied when the user hovers over an event tile with a pointer device.
  /// Setting this on the shared parent applies the same hover color to both
  /// Day View and Month View.
  ///
  /// When `null`, the master defaults (`MCalThemeData.fromTheme`) derive this
  /// from `colorScheme.primaryContainer.withValues(alpha: 0.8)`.
  final Color? hoverEventBackgroundColor;

  /// Shared: Contrast text color used on **dark**-background event tiles.
  ///
  /// The calendar computes tile luminance at render time and picks either
  /// [eventTileLightContrastColor] (for dark tiles) or
  /// [eventTileDarkContrastColor] (for light tiles) for legible text.
  ///
  /// When `null`, the master defaults use `Colors.white` (per M3 on-dark
  /// contrast guidance).
  ///
  /// When [ignoreEventColors] is `true` and [eventTileTextStyle] carries a
  /// non-null `color`, that color takes precedence over the contrast resolver
  /// (Req 10.3).
  final Color? eventTileLightContrastColor;

  /// Shared: Contrast text color used on **light**-background event tiles.
  ///
  /// The calendar computes tile luminance at render time and picks either
  /// [eventTileLightContrastColor] (for dark tiles) or
  /// [eventTileDarkContrastColor] (for light tiles) for legible text.
  ///
  /// When `null`, the master defaults derive this from
  /// `colorScheme.onSurface` (full opacity per M3).
  ///
  /// When [ignoreEventColors] is `true` and [eventTileTextStyle] carries a
  /// non-null `color`, that color takes precedence over the contrast resolver
  /// (Req 10.3).
  final Color? eventTileDarkContrastColor;

  /// Month View specific theme data.
  ///
  /// When `null`, widgets resolve individual sub-theme properties through the
  /// master defaults — `MCalThemeData.fromTheme(Theme.of(context)).monthTheme` —
  /// which are derived from the current [ThemeData] color scheme and text theme.
  ///
  /// Set this to a [MCalMonthThemeData] instance to override specific Month
  /// View properties; any property left `null` on the sub-theme falls back to
  /// the master defaults.
  final MCalMonthThemeData? monthTheme;

  /// Day View specific theme data.
  ///
  /// When `null`, widgets resolve individual sub-theme properties through the
  /// master defaults — `MCalThemeData.fromTheme(Theme.of(context)).dayTheme` —
  /// which are derived from the current [ThemeData] color scheme and text theme.
  ///
  /// Set this to a [MCalDayThemeData] instance to override specific Day View
  /// properties; any property left `null` on the sub-theme falls back to the
  /// master defaults.
  final MCalDayThemeData? dayTheme;

  /// Creates a new [MCalThemeData] instance.
  ///
  /// All parameters are optional, allowing partial customization.
  const MCalThemeData({
    this.cellBackgroundColor,
    this.cellBorderColor,
    this.eventTileBackgroundColor,
    this.eventTileTextStyle,
    this.navigatorTextStyle,
    this.navigatorBackgroundColor,
    this.allDayEventBackgroundColor,
    this.allDayEventTextStyle,
    this.allDayEventBorderColor,
    this.allDayEventBorderWidth,
    this.weekNumberTextStyle,
    this.weekNumberBackgroundColor,
    this.eventTileCornerRadius,
    this.eventTileHorizontalSpacing,
    this.ignoreEventColors = false,
    this.hoverEventBackgroundColor,
    this.eventTileLightContrastColor,
    this.eventTileDarkContrastColor,
    this.monthTheme,
    this.dayTheme,
  });

  /// Creates the **master defaults** for calendar theming from the provided [ThemeData].
  ///
  /// This factory is the single source of truth for all computed fallback
  /// values in the cascade. Widgets call it at build time (inside their
  /// `build` method) so defaults always reflect the app's current [ThemeData]:
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   final theme = MCalTheme.of(context);          // consumer theme (nulls preserved)
  ///   final defaults = MCalThemeData.fromTheme(Theme.of(context)); // master defaults
  ///   final color = theme.eventTileBackgroundColor ?? defaults.eventTileBackgroundColor!;
  /// }
  /// ```
  ///
  /// All returned properties are non-null and are derived from the theme's
  /// [ColorScheme] and [TextTheme] following Material 3 roles. Nested
  /// [monthTheme] and [dayTheme] are populated via their own `defaults()` factories.
  static MCalThemeData fromTheme(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return MCalThemeData(
      cellBackgroundColor: colorScheme.surface,
      cellBorderColor: colorScheme.outlineVariant,
      eventTileBackgroundColor: colorScheme.primaryContainer,
      eventTileTextStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onPrimaryContainer,
      ),
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
      weekNumberTextStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      weekNumberBackgroundColor: colorScheme.surfaceContainerHighest,
      eventTileCornerRadius: 3.0,
      eventTileHorizontalSpacing: 1.0,
      ignoreEventColors: false,
      hoverEventBackgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.8),
      eventTileLightContrastColor: Colors.white,
      eventTileDarkContrastColor: colorScheme.onSurface,
      monthTheme: MCalMonthThemeData.defaults(theme),
      dayTheme: MCalDayThemeData.defaults(theme),
    );
  }

  /// Creates a copy of this [MCalThemeData] with the given fields replaced.
  @override
  MCalThemeData copyWith({
    Color? cellBackgroundColor,
    Color? cellBorderColor,
    Color? eventTileBackgroundColor,
    TextStyle? eventTileTextStyle,
    TextStyle? navigatorTextStyle,
    Color? navigatorBackgroundColor,
    Color? allDayEventBackgroundColor,
    TextStyle? allDayEventTextStyle,
    Color? allDayEventBorderColor,
    double? allDayEventBorderWidth,
    TextStyle? weekNumberTextStyle,
    Color? weekNumberBackgroundColor,
    double? eventTileCornerRadius,
    double? eventTileHorizontalSpacing,
    bool? ignoreEventColors,
    Color? hoverEventBackgroundColor,
    Color? eventTileLightContrastColor,
    Color? eventTileDarkContrastColor,
    MCalMonthThemeData? monthTheme,
    MCalDayThemeData? dayTheme,
  }) {
    return MCalThemeData(
      cellBackgroundColor: cellBackgroundColor ?? this.cellBackgroundColor,
      cellBorderColor: cellBorderColor ?? this.cellBorderColor,
      eventTileBackgroundColor:
          eventTileBackgroundColor ?? this.eventTileBackgroundColor,
      eventTileTextStyle: eventTileTextStyle ?? this.eventTileTextStyle,
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
      weekNumberTextStyle: weekNumberTextStyle ?? this.weekNumberTextStyle,
      weekNumberBackgroundColor:
          weekNumberBackgroundColor ?? this.weekNumberBackgroundColor,
      eventTileCornerRadius:
          eventTileCornerRadius ?? this.eventTileCornerRadius,
      eventTileHorizontalSpacing:
          eventTileHorizontalSpacing ?? this.eventTileHorizontalSpacing,
      ignoreEventColors: ignoreEventColors ?? this.ignoreEventColors,
      hoverEventBackgroundColor:
          hoverEventBackgroundColor ?? this.hoverEventBackgroundColor,
      eventTileLightContrastColor:
          eventTileLightContrastColor ?? this.eventTileLightContrastColor,
      eventTileDarkContrastColor:
          eventTileDarkContrastColor ?? this.eventTileDarkContrastColor,
      monthTheme: monthTheme ?? this.monthTheme,
      dayTheme: dayTheme ?? this.dayTheme,
    );
  }

  /// Linearly interpolates between this theme and [other] by [t].
  @override
  MCalThemeData lerp(ThemeExtension<MCalThemeData>? other, double t) {
    if (other is! MCalThemeData) {
      return this;
    }

    return MCalThemeData(
      cellBackgroundColor: Color.lerp(
        cellBackgroundColor,
        other.cellBackgroundColor,
        t,
      ),
      cellBorderColor: Color.lerp(
        cellBorderColor,
        other.cellBorderColor,
        t,
      ),
      eventTileBackgroundColor: Color.lerp(
        eventTileBackgroundColor,
        other.eventTileBackgroundColor,
        t,
      ),
      eventTileTextStyle: TextStyle.lerp(
        eventTileTextStyle,
        other.eventTileTextStyle,
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
      eventTileCornerRadius: _lerpDouble(
        eventTileCornerRadius,
        other.eventTileCornerRadius,
        t,
      ),
      eventTileHorizontalSpacing: _lerpDouble(
        eventTileHorizontalSpacing,
        other.eventTileHorizontalSpacing,
        t,
      ),
      ignoreEventColors: t < 0.5 ? ignoreEventColors : other.ignoreEventColors,
      hoverEventBackgroundColor: Color.lerp(
        hoverEventBackgroundColor,
        other.hoverEventBackgroundColor,
        t,
      ),
      eventTileLightContrastColor: Color.lerp(
        eventTileLightContrastColor,
        other.eventTileLightContrastColor,
        t,
      ),
      eventTileDarkContrastColor: Color.lerp(
        eventTileDarkContrastColor,
        other.eventTileDarkContrastColor,
        t,
      ),
      monthTheme: _lerpMonthTheme(monthTheme, other.monthTheme, t),
      dayTheme: _lerpDayTheme(dayTheme, other.dayTheme, t),
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
      other is MCalThemeData &&
          runtimeType == other.runtimeType &&
          cellBackgroundColor == other.cellBackgroundColor &&
          cellBorderColor == other.cellBorderColor &&
          eventTileBackgroundColor == other.eventTileBackgroundColor &&
          eventTileTextStyle == other.eventTileTextStyle &&
          navigatorTextStyle == other.navigatorTextStyle &&
          navigatorBackgroundColor == other.navigatorBackgroundColor &&
          allDayEventBackgroundColor == other.allDayEventBackgroundColor &&
          allDayEventTextStyle == other.allDayEventTextStyle &&
          allDayEventBorderColor == other.allDayEventBorderColor &&
          allDayEventBorderWidth == other.allDayEventBorderWidth &&
          weekNumberTextStyle == other.weekNumberTextStyle &&
          weekNumberBackgroundColor == other.weekNumberBackgroundColor &&
          eventTileCornerRadius == other.eventTileCornerRadius &&
          eventTileHorizontalSpacing == other.eventTileHorizontalSpacing &&
          ignoreEventColors == other.ignoreEventColors &&
          hoverEventBackgroundColor == other.hoverEventBackgroundColor &&
          eventTileLightContrastColor == other.eventTileLightContrastColor &&
          eventTileDarkContrastColor == other.eventTileDarkContrastColor &&
          monthTheme == other.monthTheme &&
          dayTheme == other.dayTheme;

  @override
  int get hashCode => Object.hashAll([
        cellBackgroundColor,
        cellBorderColor,
        eventTileBackgroundColor,
        eventTileTextStyle,
        navigatorTextStyle,
        navigatorBackgroundColor,
        allDayEventBackgroundColor,
        allDayEventTextStyle,
        allDayEventBorderColor,
        allDayEventBorderWidth,
        weekNumberTextStyle,
        weekNumberBackgroundColor,
        eventTileCornerRadius,
        eventTileHorizontalSpacing,
        ignoreEventColors,
        hoverEventBackgroundColor,
        eventTileLightContrastColor,
        eventTileDarkContrastColor,
        monthTheme,
        dayTheme,
      ]);

}

MCalMonthThemeData? _lerpMonthTheme(
  MCalMonthThemeData? a,
  MCalMonthThemeData? b,
  double t,
) {
  if (a == null && b == null) return null;
  if (a == null) return b;
  if (b == null) return a;
  return a.lerp(b, t);
}

MCalDayThemeData? _lerpDayTheme(
  MCalDayThemeData? a,
  MCalDayThemeData? b,
  double t,
) {
  if (a == null && b == null) return null;
  if (a == null) return b;
  if (b == null) return a;
  return a.lerp(b, t);
}
