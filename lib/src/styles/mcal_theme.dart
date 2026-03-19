import 'package:flutter/material.dart';
import 'mcal_day_view_theme_data.dart';
import 'mcal_month_view_theme_data.dart';

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
///     enableEventColorOverrides: true,
///     dayViewTheme: MCalDayViewThemeData(timeLegendWidth: 72.0),
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
  static MCalThemeData of(BuildContext context) {
    final inheritedTheme =
        context.dependOnInheritedWidgetOfExactType<MCalTheme>();
    if (inheritedTheme != null) return inheritedTheme.data;

    final extension = Theme.of(context).extension<MCalThemeData>();
    if (extension != null) return extension;

    return const MCalThemeData();
  }

  /// Returns the [MCalThemeData] from the closest [MCalTheme] ancestor,
  /// or null if there is no [MCalTheme] ancestor.
  static MCalThemeData? maybeOf(BuildContext context) {
    final inheritedTheme =
        context.dependOnInheritedWidgetOfExactType<MCalTheme>();
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
/// theme properties. It is slimmed to 8 global properties — properties that
/// apply identically across all views. Per-view event tile, contrast, hover,
/// week number, and all-day properties have moved to the respective view
/// theme classes via mixins ([MCalDayViewThemeData], [MCalMonthViewThemeData]).
///
/// ## Three-tier cascade model
///
/// Calendar widgets resolve visual properties through a three-tier cascade:
///
/// 1. **Event color** — the color carried on the [MCalCalendarEvent] itself.
/// 2. **Consumer theme** — the [MCalThemeData] provided via [MCalTheme] or
///    `ThemeData.extensions`.
/// 3. **Master defaults** — `MCalThemeData.fromTheme(Theme.of(context))`,
///    computed once per build from the current [ThemeData].
///
/// The [enableEventColorOverrides] flag switches the priority between tiers 1 and 2:
///
/// * `enableEventColorOverrides: false` (default):
///   `event color → allDayThemeColor → consumer theme → master defaults`
/// * `enableEventColorOverrides: true`:
///   `allDayThemeColor → consumer theme → event color → master defaults`
///
/// Setting [enableEventColorOverrides] to `true` lets the consumer theme fully
/// control tile colours regardless of per-event [MCalCalendarEvent.color] values.
///
/// ## Usage
///
/// ```dart
/// // As an InheritedWidget (preferred for subtree-scoped theming):
/// MCalTheme(
///   data: MCalThemeData(
///     enableEventColorOverrides: true,
///     dayViewTheme: MCalDayViewThemeData(timeLegendWidth: 72.0),
///     monthViewTheme: MCalMonthViewThemeData(eventTileHeight: 24.0),
///   ),
///   child: MCalMonthView(controller: controller),
/// )
///
/// // As a ThemeData extension (global theming):
/// ThemeData(
///   extensions: [
///     MCalThemeData(
///       dayViewTheme: MCalDayViewThemeData(timeLegendWidth: 72.0),
///       monthViewTheme: MCalMonthViewThemeData(eventTileHeight: 24.0),
///     ),
///   ],
/// )
/// ```
class MCalThemeData extends ThemeExtension<MCalThemeData> {
  /// Background color for calendar cells (shared across all views).
  final Color? cellBackgroundColor;

  /// Border color for calendar cells (shared across all views).
  final Color? cellBorderColor;

  /// Border width for calendar cells (shared across all views).
  final double? cellBorderWidth;

  /// Background color for the navigator (month/year display and controls).
  ///
  /// Shared across Day View and Month View navigators.
  final Color? navigatorBackgroundColor;

  /// Text style for the navigator (month/year display and controls).
  ///
  /// Shared across Day View and Month View navigators.
  final TextStyle? navigatorTextStyle;

  /// Padding inside the navigator container.
  ///
  /// Shared across Day View and Month View navigators. Replaces the
  /// previously hardcoded `EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)`.
  final EdgeInsets? navigatorPadding;

  /// Whether to override per-event colors with the consumer theme colors.
  ///
  /// When `false` (default), the cascade order is:
  /// `event color → allDayThemeColor → consumer theme → master defaults`.
  ///
  /// When `true`, the cascade order is:
  /// `allDayThemeColor → consumer theme → event color → master defaults`.
  ///
  /// Renamed from `ignoreEventColors` for clarity; semantics are identical.
  final bool enableEventColorOverrides;

  /// Day View specific theme data.
  ///
  /// When `null`, widgets resolve individual sub-theme properties through the
  /// master defaults — `MCalThemeData.fromTheme(Theme.of(context)).dayViewTheme` —
  /// which are derived from the current [ThemeData] color scheme and text theme.
  final MCalDayViewThemeData? dayViewTheme;

  /// Month View specific theme data.
  ///
  /// When `null`, widgets resolve individual sub-theme properties through the
  /// master defaults — `MCalThemeData.fromTheme(Theme.of(context)).monthViewTheme` —
  /// which are derived from the current [ThemeData] color scheme and text theme.
  final MCalMonthViewThemeData? monthViewTheme;

  /// Creates a new [MCalThemeData] instance.
  ///
  /// All parameters are optional, allowing partial customization.
  const MCalThemeData({
    this.cellBackgroundColor,
    this.cellBorderColor,
    this.cellBorderWidth,
    this.navigatorBackgroundColor,
    this.navigatorTextStyle,
    this.navigatorPadding,
    this.enableEventColorOverrides = false,
    this.dayViewTheme,
    this.monthViewTheme,
  });

  /// Creates the **master defaults** for calendar theming from [theme].
  ///
  /// This factory is the single source of truth for all computed fallback
  /// values in the cascade. Widgets call it at build time so defaults always
  /// reflect the app's current [ThemeData]:
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   final theme = MCalTheme.of(context);
  ///   final defaults = MCalThemeData.fromTheme(Theme.of(context));
  ///   final color = theme.cellBackgroundColor ?? defaults.cellBackgroundColor!;
  ///   final tileColor = theme.dayViewTheme?.eventTileBackgroundColor
  ///       ?? defaults.dayViewTheme!.eventTileBackgroundColor!;
  /// }
  /// ```
  static MCalThemeData fromTheme(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return MCalThemeData(
      cellBackgroundColor: colorScheme.surface,
      cellBorderColor: colorScheme.outlineVariant,
      cellBorderWidth: 1.0,
      navigatorBackgroundColor: colorScheme.surface,
      navigatorTextStyle: textTheme.titleMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      navigatorPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      enableEventColorOverrides: false,
      dayViewTheme: MCalDayViewThemeData.defaults(theme),
      monthViewTheme: MCalMonthViewThemeData.defaults(theme),
    );
  }

  /// Creates a copy of this [MCalThemeData] with the given fields replaced.
  @override
  MCalThemeData copyWith({
    Color? cellBackgroundColor,
    Color? cellBorderColor,
    double? cellBorderWidth,
    Color? navigatorBackgroundColor,
    TextStyle? navigatorTextStyle,
    EdgeInsets? navigatorPadding,
    bool? enableEventColorOverrides,
    MCalDayViewThemeData? dayViewTheme,
    MCalMonthViewThemeData? monthViewTheme,
  }) {
    return MCalThemeData(
      cellBackgroundColor: cellBackgroundColor ?? this.cellBackgroundColor,
      cellBorderColor: cellBorderColor ?? this.cellBorderColor,
      cellBorderWidth: cellBorderWidth ?? this.cellBorderWidth,
      navigatorBackgroundColor: navigatorBackgroundColor ?? this.navigatorBackgroundColor,
      navigatorTextStyle: navigatorTextStyle ?? this.navigatorTextStyle,
      navigatorPadding: navigatorPadding ?? this.navigatorPadding,
      enableEventColorOverrides: enableEventColorOverrides ?? this.enableEventColorOverrides,
      dayViewTheme: dayViewTheme ?? this.dayViewTheme,
      monthViewTheme: monthViewTheme ?? this.monthViewTheme,
    );
  }

  /// Linearly interpolates between this theme and [other] by [t].
  @override
  MCalThemeData lerp(ThemeExtension<MCalThemeData>? other, double t) {
    if (other is! MCalThemeData) return this;

    return MCalThemeData(
      cellBackgroundColor: Color.lerp(cellBackgroundColor, other.cellBackgroundColor, t),
      cellBorderColor: Color.lerp(cellBorderColor, other.cellBorderColor, t),
      cellBorderWidth: (cellBorderWidth == null && other.cellBorderWidth == null)
          ? null
          : ((cellBorderWidth ?? 1.0) + ((other.cellBorderWidth ?? 1.0) - (cellBorderWidth ?? 1.0)) * t),
      navigatorBackgroundColor: Color.lerp(navigatorBackgroundColor, other.navigatorBackgroundColor, t),
      navigatorTextStyle: TextStyle.lerp(navigatorTextStyle, other.navigatorTextStyle, t),
      navigatorPadding: EdgeInsets.lerp(navigatorPadding, other.navigatorPadding, t),
      enableEventColorOverrides: t < 0.5 ? enableEventColorOverrides : other.enableEventColorOverrides,
      dayViewTheme: _lerpDayViewTheme(dayViewTheme, other.dayViewTheme, t),
      monthViewTheme: _lerpMonthTheme(monthViewTheme, other.monthViewTheme, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MCalThemeData &&
          runtimeType == other.runtimeType &&
          cellBackgroundColor == other.cellBackgroundColor &&
          cellBorderColor == other.cellBorderColor &&
          cellBorderWidth == other.cellBorderWidth &&
          navigatorBackgroundColor == other.navigatorBackgroundColor &&
          navigatorTextStyle == other.navigatorTextStyle &&
          navigatorPadding == other.navigatorPadding &&
          enableEventColorOverrides == other.enableEventColorOverrides &&
          dayViewTheme == other.dayViewTheme &&
          monthViewTheme == other.monthViewTheme;

  @override
  int get hashCode => Object.hashAll([
        cellBackgroundColor,
        cellBorderColor,
        cellBorderWidth,
        navigatorBackgroundColor,
        navigatorTextStyle,
        navigatorPadding,
        enableEventColorOverrides,
        dayViewTheme,
        monthViewTheme,
      ]);
}

MCalMonthViewThemeData? _lerpMonthTheme(
  MCalMonthViewThemeData? a,
  MCalMonthViewThemeData? b,
  double t,
) {
  if (a == null && b == null) return null;
  if (a == null) return b;
  if (b == null) return a;
  return a.lerp(b, t);
}

MCalDayViewThemeData? _lerpDayViewTheme(
  MCalDayViewThemeData? a,
  MCalDayViewThemeData? b,
  double t,
) {
  if (a == null && b == null) return null;
  if (a == null) return b;
  if (b == null) return a;
  return a.lerp(b, t);
}
