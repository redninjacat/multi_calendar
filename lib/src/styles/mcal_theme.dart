import 'package:flutter/material.dart';

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
///     cellBackgroundColor: Colors.white,
///     todayBackgroundColor: Colors.blue,
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
  const MCalTheme({
    super.key,
    required this.data,
    required super.child,
  });

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
  ///     color: theme.cellBackgroundColor,
  ///   );
  /// }
  /// ```
  static MCalThemeData of(BuildContext context) {
    // Step 1: Try to find MCalTheme ancestor
    final inheritedTheme =
        context.dependOnInheritedWidgetOfExactType<MCalTheme>();
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
/// theme properties that integrate seamlessly with Flutter's ThemeData system.
/// All properties are nullable to allow optional customization while providing
/// sensible defaults derived from the base ThemeData.
///
/// Example:
/// ```dart
/// ThemeData(
///   extensions: [
///     MCalThemeData(
///       cellBackgroundColor: Colors.white,
///       todayBackgroundColor: Colors.blue,
///       eventTileBackgroundColor: Colors.green,
///     ),
///   ],
/// )
/// ```
class MCalThemeData extends ThemeExtension<MCalThemeData> {
  /// Background color for calendar day cells.
  final Color? cellBackgroundColor;

  /// Border color for calendar day cells.
  final Color? cellBorderColor;

  /// Text style for day numbers in calendar cells.
  final TextStyle? cellTextStyle;

  /// Background color for the current day indicator.
  final Color? todayBackgroundColor;

  /// Text style for the current day number.
  final TextStyle? todayTextStyle;

  /// Text style for leading dates (days from previous month).
  final TextStyle? leadingDatesTextStyle;

  /// Text style for trailing dates (days from next month).
  final TextStyle? trailingDatesTextStyle;

  /// Background color for leading dates (days from previous month).
  final Color? leadingDatesBackgroundColor;

  /// Background color for trailing dates (days from next month).
  final Color? trailingDatesBackgroundColor;

  /// Text style for weekday headers (Monday, Tuesday, etc.).
  final TextStyle? weekdayHeaderTextStyle;

  /// Background color for weekday headers.
  final Color? weekdayHeaderBackgroundColor;

  /// Background color for event tiles.
  final Color? eventTileBackgroundColor;

  /// Text style for event tiles.
  final TextStyle? eventTileTextStyle;

  /// Text style for the month navigator (month/year display and controls).
  final TextStyle? navigatorTextStyle;

  /// Background color for the month navigator.
  final Color? navigatorBackgroundColor;

  /// Background color for the focused/selected date.
  final Color? focusedDateBackgroundColor;

  /// Text style for the focused/selected date.
  final TextStyle? focusedDateTextStyle;

  /// Background color for all-day event tiles.
  final Color? allDayEventBackgroundColor;

  /// Text style for all-day event tiles.
  final TextStyle? allDayEventTextStyle;

  /// Border color for all-day event tiles.
  final Color? allDayEventBorderColor;

  /// Border width for all-day event tiles.
  final double? allDayEventBorderWidth;

  /// Text style for week numbers.
  final TextStyle? weekNumberTextStyle;

  /// Background color for the week number column.
  final Color? weekNumberBackgroundColor;

  /// Background color for calendar cells on hover.
  final Color? hoverCellBackgroundColor;

  /// Background color for event tiles on hover.
  final Color? hoverEventBackgroundColor;

  /// Highlight color for valid drop target during drag-and-drop.
  final Color? dragTargetValidColor;

  /// Highlight color for invalid drop target during drag-and-drop.
  final Color? dragTargetInvalidColor;

  /// Opacity for the source placeholder during drag-and-drop.
  final double? dragSourceOpacity;

  /// Elevation for the dragged tile feedback widget.
  final double? draggedTileElevation;

  /// Background color for multi-day event tiles.
  final Color? multiDayEventBackgroundColor;

  /// Text style for multi-day event tiles.
  final TextStyle? multiDayEventTextStyle;

  /// Height of event tile slots (both single-day and multi-day).
  ///
  /// Defaults to 20.0 pixels. This is the total slot height including margins.
  /// The visible tile content is this height minus the vertical margins.
  final double? eventTileHeight;

  /// Horizontal spacing around event tiles in pixels.
  ///
  /// This creates visual gaps between tiles and cell edges.
  /// For multi-day tiles that span across days, this spacing is only applied
  /// at the actual start and end of the event (rounded edges), not at
  /// continuation points.
  ///
  /// Defaults to 1.0 pixel.
  final double? eventTileHorizontalSpacing;

  /// Vertical spacing between event tile rows in pixels.
  ///
  /// This creates visual gaps between stacked event tiles.
  /// Defaults to 1.0 pixel.
  final double? eventTileVerticalSpacing;

  /// Creates a new [MCalThemeData] instance.
  ///
  /// All parameters are optional, allowing partial customization.
  const MCalThemeData({
    this.cellBackgroundColor,
    this.cellBorderColor,
    this.cellTextStyle,
    this.todayBackgroundColor,
    this.todayTextStyle,
    this.leadingDatesTextStyle,
    this.trailingDatesTextStyle,
    this.leadingDatesBackgroundColor,
    this.trailingDatesBackgroundColor,
    this.weekdayHeaderTextStyle,
    this.weekdayHeaderBackgroundColor,
    this.eventTileBackgroundColor,
    this.eventTileTextStyle,
    this.navigatorTextStyle,
    this.navigatorBackgroundColor,
    this.focusedDateBackgroundColor,
    this.focusedDateTextStyle,
    this.allDayEventBackgroundColor,
    this.allDayEventTextStyle,
    this.allDayEventBorderColor,
    this.allDayEventBorderWidth,
    this.weekNumberTextStyle,
    this.weekNumberBackgroundColor,
    this.hoverCellBackgroundColor,
    this.hoverEventBackgroundColor,
    this.dragTargetValidColor,
    this.dragTargetInvalidColor,
    this.dragSourceOpacity,
    this.draggedTileElevation,
    this.multiDayEventBackgroundColor,
    this.multiDayEventTextStyle,
    this.eventTileHeight,
    this.eventTileHorizontalSpacing,
    this.eventTileVerticalSpacing,
  });

  /// Creates a [MCalThemeData] instance with default values derived
  /// from the provided [ThemeData].
  ///
  /// This method provides sensible defaults based on the theme's color scheme
  /// and text styles, supporting both light and dark themes.
  static MCalThemeData fromTheme(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return MCalThemeData(
      cellBackgroundColor: colorScheme.surface,
      cellBorderColor: colorScheme.outline.withValues(alpha: 0.2),
      cellTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
      todayBackgroundColor: colorScheme.primary.withValues(alpha: 0.1),
      todayTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
      leadingDatesTextStyle: textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      trailingDatesTextStyle: textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      leadingDatesBackgroundColor: colorScheme.surface,
      trailingDatesBackgroundColor: colorScheme.surface,
      weekdayHeaderTextStyle: textTheme.labelMedium?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.7),
        fontWeight: FontWeight.w500,
      ),
      weekdayHeaderBackgroundColor: colorScheme.surfaceContainerHighest,
      eventTileBackgroundColor: colorScheme.primaryContainer,
      eventTileTextStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onPrimaryContainer,
      ),
      navigatorTextStyle: textTheme.titleMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      navigatorBackgroundColor: colorScheme.surface,
      focusedDateBackgroundColor: colorScheme.primary.withValues(alpha: 0.2),
      focusedDateTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
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
      hoverCellBackgroundColor: colorScheme.primary.withValues(alpha: 0.05),
      hoverEventBackgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.8),
      dragTargetValidColor: Colors.green.withValues(alpha: 0.3),
      dragTargetInvalidColor: Colors.red.withValues(alpha: 0.3),
      dragSourceOpacity: 0.5,
      draggedTileElevation: 6.0,
      multiDayEventBackgroundColor: colorScheme.primary.withValues(alpha: 0.8),
      multiDayEventTextStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onPrimary,
        fontWeight: FontWeight.w500,
      ),
      eventTileHeight: 20.0,
      eventTileHorizontalSpacing: 1.0,
      eventTileVerticalSpacing: 1.0,
    );
  }

  @override
  MCalThemeData copyWith({
    Color? cellBackgroundColor,
    Color? cellBorderColor,
    TextStyle? cellTextStyle,
    Color? todayBackgroundColor,
    TextStyle? todayTextStyle,
    TextStyle? leadingDatesTextStyle,
    TextStyle? trailingDatesTextStyle,
    Color? leadingDatesBackgroundColor,
    Color? trailingDatesBackgroundColor,
    TextStyle? weekdayHeaderTextStyle,
    Color? weekdayHeaderBackgroundColor,
    Color? eventTileBackgroundColor,
    TextStyle? eventTileTextStyle,
    TextStyle? navigatorTextStyle,
    Color? navigatorBackgroundColor,
    Color? focusedDateBackgroundColor,
    TextStyle? focusedDateTextStyle,
    Color? allDayEventBackgroundColor,
    TextStyle? allDayEventTextStyle,
    Color? allDayEventBorderColor,
    double? allDayEventBorderWidth,
    TextStyle? weekNumberTextStyle,
    Color? weekNumberBackgroundColor,
    Color? hoverCellBackgroundColor,
    Color? hoverEventBackgroundColor,
    Color? dragTargetValidColor,
    Color? dragTargetInvalidColor,
    double? dragSourceOpacity,
    double? draggedTileElevation,
    Color? multiDayEventBackgroundColor,
    TextStyle? multiDayEventTextStyle,
    double? eventTileHeight,
    double? eventTileHorizontalSpacing,
    double? eventTileVerticalSpacing,
  }) {
    return MCalThemeData(
      cellBackgroundColor: cellBackgroundColor ?? this.cellBackgroundColor,
      cellBorderColor: cellBorderColor ?? this.cellBorderColor,
      cellTextStyle: cellTextStyle ?? this.cellTextStyle,
      todayBackgroundColor: todayBackgroundColor ?? this.todayBackgroundColor,
      todayTextStyle: todayTextStyle ?? this.todayTextStyle,
      leadingDatesTextStyle:
          leadingDatesTextStyle ?? this.leadingDatesTextStyle,
      trailingDatesTextStyle:
          trailingDatesTextStyle ?? this.trailingDatesTextStyle,
      leadingDatesBackgroundColor: leadingDatesBackgroundColor ??
          this.leadingDatesBackgroundColor,
      trailingDatesBackgroundColor: trailingDatesBackgroundColor ??
          this.trailingDatesBackgroundColor,
      weekdayHeaderTextStyle:
          weekdayHeaderTextStyle ?? this.weekdayHeaderTextStyle,
      weekdayHeaderBackgroundColor: weekdayHeaderBackgroundColor ??
          this.weekdayHeaderBackgroundColor,
      eventTileBackgroundColor:
          eventTileBackgroundColor ?? this.eventTileBackgroundColor,
      eventTileTextStyle: eventTileTextStyle ?? this.eventTileTextStyle,
      navigatorTextStyle: navigatorTextStyle ?? this.navigatorTextStyle,
      navigatorBackgroundColor:
          navigatorBackgroundColor ?? this.navigatorBackgroundColor,
      focusedDateBackgroundColor:
          focusedDateBackgroundColor ?? this.focusedDateBackgroundColor,
      focusedDateTextStyle:
          focusedDateTextStyle ?? this.focusedDateTextStyle,
      allDayEventBackgroundColor:
          allDayEventBackgroundColor ?? this.allDayEventBackgroundColor,
      allDayEventTextStyle:
          allDayEventTextStyle ?? this.allDayEventTextStyle,
      allDayEventBorderColor:
          allDayEventBorderColor ?? this.allDayEventBorderColor,
      allDayEventBorderWidth:
          allDayEventBorderWidth ?? this.allDayEventBorderWidth,
      weekNumberTextStyle:
          weekNumberTextStyle ?? this.weekNumberTextStyle,
      weekNumberBackgroundColor:
          weekNumberBackgroundColor ?? this.weekNumberBackgroundColor,
      hoverCellBackgroundColor:
          hoverCellBackgroundColor ?? this.hoverCellBackgroundColor,
      hoverEventBackgroundColor:
          hoverEventBackgroundColor ?? this.hoverEventBackgroundColor,
      dragTargetValidColor:
          dragTargetValidColor ?? this.dragTargetValidColor,
      dragTargetInvalidColor:
          dragTargetInvalidColor ?? this.dragTargetInvalidColor,
      dragSourceOpacity:
          dragSourceOpacity ?? this.dragSourceOpacity,
      draggedTileElevation:
          draggedTileElevation ?? this.draggedTileElevation,
      multiDayEventBackgroundColor:
          multiDayEventBackgroundColor ?? this.multiDayEventBackgroundColor,
      multiDayEventTextStyle:
          multiDayEventTextStyle ?? this.multiDayEventTextStyle,
      eventTileHeight:
          eventTileHeight ?? this.eventTileHeight,
      eventTileHorizontalSpacing:
          eventTileHorizontalSpacing ?? this.eventTileHorizontalSpacing,
      eventTileVerticalSpacing:
          eventTileVerticalSpacing ?? this.eventTileVerticalSpacing,
    );
  }

  @override
  MCalThemeData lerp(
    ThemeExtension<MCalThemeData>? other,
    double t,
  ) {
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
      cellTextStyle: TextStyle.lerp(
        cellTextStyle,
        other.cellTextStyle,
        t,
      ),
      todayBackgroundColor: Color.lerp(
        todayBackgroundColor,
        other.todayBackgroundColor,
        t,
      ),
      todayTextStyle: TextStyle.lerp(
        todayTextStyle,
        other.todayTextStyle,
        t,
      ),
      leadingDatesTextStyle: TextStyle.lerp(
        leadingDatesTextStyle,
        other.leadingDatesTextStyle,
        t,
      ),
      trailingDatesTextStyle: TextStyle.lerp(
        trailingDatesTextStyle,
        other.trailingDatesTextStyle,
        t,
      ),
      leadingDatesBackgroundColor: Color.lerp(
        leadingDatesBackgroundColor,
        other.leadingDatesBackgroundColor,
        t,
      ),
      trailingDatesBackgroundColor: Color.lerp(
        trailingDatesBackgroundColor,
        other.trailingDatesBackgroundColor,
        t,
      ),
      weekdayHeaderTextStyle: TextStyle.lerp(
        weekdayHeaderTextStyle,
        other.weekdayHeaderTextStyle,
        t,
      ),
      weekdayHeaderBackgroundColor: Color.lerp(
        weekdayHeaderBackgroundColor,
        other.weekdayHeaderBackgroundColor,
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
      focusedDateBackgroundColor: Color.lerp(
        focusedDateBackgroundColor,
        other.focusedDateBackgroundColor,
        t,
      ),
      focusedDateTextStyle: TextStyle.lerp(
        focusedDateTextStyle,
        other.focusedDateTextStyle,
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
      hoverCellBackgroundColor: Color.lerp(
        hoverCellBackgroundColor,
        other.hoverCellBackgroundColor,
        t,
      ),
      hoverEventBackgroundColor: Color.lerp(
        hoverEventBackgroundColor,
        other.hoverEventBackgroundColor,
        t,
      ),
      dragTargetValidColor: Color.lerp(
        dragTargetValidColor,
        other.dragTargetValidColor,
        t,
      ),
      dragTargetInvalidColor: Color.lerp(
        dragTargetInvalidColor,
        other.dragTargetInvalidColor,
        t,
      ),
      dragSourceOpacity: _lerpDouble(
        dragSourceOpacity,
        other.dragSourceOpacity,
        t,
      ),
      draggedTileElevation: _lerpDouble(
        draggedTileElevation,
        other.draggedTileElevation,
        t,
      ),
      multiDayEventBackgroundColor: Color.lerp(
        multiDayEventBackgroundColor,
        other.multiDayEventBackgroundColor,
        t,
      ),
      multiDayEventTextStyle: TextStyle.lerp(
        multiDayEventTextStyle,
        other.multiDayEventTextStyle,
        t,
      ),
      eventTileHeight: _lerpDouble(
        eventTileHeight,
        other.eventTileHeight,
        t,
      ),
      eventTileHorizontalSpacing: _lerpDouble(
        eventTileHorizontalSpacing,
        other.eventTileHorizontalSpacing,
        t,
      ),
      eventTileVerticalSpacing: _lerpDouble(
        eventTileVerticalSpacing,
        other.eventTileVerticalSpacing,
        t,
      ),
    );
  }

  /// Helper method to linearly interpolate between two nullable doubles.
  static double? _lerpDouble(double? a, double? b, double t) {
    if (a == null && b == null) return null;
    a ??= 0.0;
    b ??= 0.0;
    return a + (b - a) * t;
  }
}
