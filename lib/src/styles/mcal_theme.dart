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
  /// 1. First tries to find an [MCalTheme] ancestor via [dependOnInheritedWidgetOfExactType]
  /// 2. If not found, tries [Theme.of(context).extension<MCalThemeData>()]
  /// 3. If still not found, calls [MCalThemeData.fromTheme(Theme.of(context))]
  ///
  /// This method never returns null - it always provides a valid [MCalThemeData].
  ///
  /// Example:
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   final theme = MCalTheme.of(context);
  ///   return Container(
  ///     color: theme.eventTileBackgroundColor,
  ///   );
  /// }
  /// ```
  static MCalThemeData of(BuildContext context) {
    // Step 1: Try to find MCalTheme ancestor
    final inheritedTheme = context
        .dependOnInheritedWidgetOfExactType<MCalTheme>();
    if (inheritedTheme != null) {
      return inheritedTheme.data;
    }

    // Step 2: Try ThemeExtension
    final themeData = Theme.of(context);
    final extension = themeData.extension<MCalThemeData>();
    if (extension != null) {
      return extension;
    }

    // Step 3: Fallback to fromTheme()
    return MCalThemeData.fromTheme(themeData);
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
/// Example:
/// ```dart
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

  /// Shared: Whether to ignore individual event colors and use eventTileBackgroundColor.
  final bool ignoreEventColors;

  /// Month View specific theme data.
  ///
  /// When null, [MCalThemeData.fromTheme] creates default values.
  /// Access via [monthTheme] in [MCalMonthView].
  final MCalMonthThemeData? monthTheme;

  /// Day View specific theme data.
  ///
  /// When null, [MCalThemeData.fromTheme] creates default values.
  /// Access via [dayTheme] in [MCalDayView].
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
    this.monthTheme,
    this.dayTheme,
  });

  /// Creates a [MCalThemeData] instance with default values derived
  /// from the provided [ThemeData].
  ///
  /// This method provides sensible defaults based on the theme's color scheme
  /// and text styles, supporting both light and dark themes.
  /// Nested [monthTheme] and [dayTheme] are populated with their defaults.
  static MCalThemeData fromTheme(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return MCalThemeData(
      cellBackgroundColor: colorScheme.surface,
      cellBorderColor: colorScheme.outline.withValues(alpha: 0.2),
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

}

MCalMonthThemeData? _lerpMonthTheme(
  MCalMonthThemeData? a,
  MCalMonthThemeData? b,
  double t,
) {
  if (a == null && b == null) return null;
  a ??= MCalMonthThemeData.defaults(ThemeData.light());
  b ??= MCalMonthThemeData.defaults(ThemeData.light());
  return a.lerp(b, t);
}

MCalDayThemeData? _lerpDayTheme(
  MCalDayThemeData? a,
  MCalDayThemeData? b,
  double t,
) {
  if (a == null && b == null) return null;
  a ??= MCalDayThemeData.defaults(ThemeData.light());
  b ??= MCalDayThemeData.defaults(ThemeData.light());
  return a.lerp(b, t);
}
