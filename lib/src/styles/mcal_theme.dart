import 'package:flutter/material.dart';
import '../widgets/mcal_month_week_layout_contexts.dart' show DateLabelPosition;

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
  ///     color: theme.cellBackgroundColor,
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

  /// Highlight color for valid drop target cell overlay during drag-and-drop (Layer 4).
  final Color? dropTargetCellValidColor;

  /// Highlight color for invalid drop target cell overlay during drag-and-drop (Layer 4).
  final Color? dropTargetCellInvalidColor;

  /// Border radius for drop target cell overlay highlights during drag-and-drop (Layer 4).
  final double? dropTargetCellBorderRadius;

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

  /// Height reserved for date labels in day cells.
  /// Defaults to 18.0 pixels.
  final double? dateLabelHeight;

  /// Position of date labels within day cells.
  /// Defaults to DateLabelPosition.topLeft.
  final DateLabelPosition? dateLabelPosition;

  /// Height reserved for overflow indicators.
  /// Defaults to 14.0 pixels.
  final double? overflowIndicatorHeight;

  /// Corner radius for event tiles.
  /// Defaults to 3.0 pixels.
  final double? eventTileCornerRadius;

  /// Whether to ignore individual event colors and use [eventTileBackgroundColor] instead.
  ///
  /// When true, all event tiles use [eventTileBackgroundColor] regardless of
  /// the event's individual color property. This is useful for styles that
  /// want uniform event tile colors (e.g., classic calendar styles).
  ///
  /// Defaults to false (individual event colors are respected).
  final bool ignoreEventColors;

  /// Border color for event tiles.
  ///
  /// When set along with [eventTileBorderWidth], adds a border around event tiles.
  /// Defaults to null (no border).
  final Color? eventTileBorderColor;

  /// Border width for event tiles in pixels.
  ///
  /// When set to a value greater than 0 along with [eventTileBorderColor],
  /// adds a border around event tiles.
  /// Defaults to 0.0 (no border).
  final double? eventTileBorderWidth;

  /// Background color for drop target preview tiles (Layer 3).
  /// Falls back to [eventTileBackgroundColor] then theme default when null.
  final Color? dropTargetTileBackgroundColor;

  /// Background color for invalid drop target preview tiles (Layer 3).
  /// Falls back to [eventTileBackgroundColor] or a red tint when null.
  final Color? dropTargetTileInvalidBackgroundColor;

  /// Corner radius for drop target preview tiles (Layer 3).
  /// Falls back to [eventTileCornerRadius] then 3.0 when null.
  final double? dropTargetTileCornerRadius;

  /// Border color for drop target preview tiles (Layer 3).
  /// Falls back to [eventTileBorderColor] when null.
  final Color? dropTargetTileBorderColor;

  /// Border width for drop target preview tiles (Layer 3).
  /// Falls back to [eventTileBorderWidth] then 0.0 when null.
  final double? dropTargetTileBorderWidth;

  // ===== Day View Theme Properties =====

  /// Text style for day of week in Day View header (e.g., "Monday").
  ///
  /// Used by the Day View day header component to display the day name.
  /// Defaults to Material 3 labelMedium with medium weight.
  final TextStyle? dayHeaderDayOfWeekStyle;

  /// Text style for date number in Day View header (e.g., "14").
  ///
  /// Used by the Day View day header component to display the date.
  /// Defaults to Material 3 headlineMedium with bold weight.
  final TextStyle? dayHeaderDateStyle;

  /// Text color for week numbers in Day View.
  ///
  /// Used when [showWeekNumber] is true in Day View.
  /// Defaults to Material 3 onSurfaceVariant color.
  final Color? weekNumberTextColor;

  /// Width of the time legend column in Day View (in pixels).
  ///
  /// The time legend displays hour labels (e.g., "9 AM", "2 PM") along the
  /// left edge of the Day View. This width should accommodate the formatted
  /// time strings in the current locale.
  /// Defaults to 60.0 pixels.
  final double? timeLegendWidth;

  /// Text style for time labels in Day View time legend.
  ///
  /// Used for hour labels in the time legend column.
  /// Defaults to Material 3 labelSmall with onSurfaceVariant color.
  final TextStyle? timeLegendTextStyle;

  /// Background color for the time legend column in Day View.
  ///
  /// Defaults to Material 3 surfaceContainerLow.
  final Color? timeLegendBackgroundColor;

  /// Color for hour gridlines in Day View (lines at top of each hour).
  ///
  /// Hour gridlines are the most prominent gridlines, drawn at the start of
  /// each hour (e.g., 9:00, 10:00, 11:00).
  /// Defaults to Material 3 outline with 20% opacity.
  final Color? hourGridlineColor;

  /// Width of hour gridlines in Day View (in pixels).
  ///
  /// Defaults to 1.0 pixel.
  final double? hourGridlineWidth;

  /// Color for major gridlines in Day View (e.g., 30-minute marks).
  ///
  /// Major gridlines are drawn at significant intervals within the hour,
  /// typically at the 30-minute mark.
  /// Defaults to Material 3 outline with 15% opacity.
  final Color? majorGridlineColor;

  /// Width of major gridlines in Day View (in pixels).
  ///
  /// Defaults to 1.0 pixel.
  final double? majorGridlineWidth;

  /// Color for minor gridlines in Day View (e.g., 15-minute marks).
  ///
  /// Minor gridlines are the most subtle, drawn at smaller intervals
  /// (e.g., every 15 minutes) to help with time estimation.
  /// Defaults to Material 3 outline with 8% opacity.
  final Color? minorGridlineColor;

  /// Width of minor gridlines in Day View (in pixels).
  ///
  /// Defaults to 0.5 pixels.
  final double? minorGridlineWidth;

  /// Color for the current time indicator line in Day View.
  ///
  /// The current time indicator is a horizontal line that shows the current
  /// time of day with a leading dot indicator.
  /// Defaults to Material 3 primary color.
  final Color? currentTimeIndicatorColor;

  /// Width of the current time indicator line in Day View (in pixels).
  ///
  /// Defaults to 2.0 pixels.
  final double? currentTimeIndicatorWidth;

  /// Radius of the dot at the start of the current time indicator (in pixels).
  ///
  /// The dot appears at the leading edge (RTL-aware) of the current time line.
  /// Defaults to 6.0 pixels.
  final double? currentTimeIndicatorDotRadius;

  /// Maximum number of rows to display in the Day View all-day events section.
  ///
  /// When the number of all-day events exceeds this limit, an overflow
  /// indicator is shown. Users can typically tap the overflow to see more events.
  /// Defaults to 3 rows.
  final int? allDaySectionMaxRows;

  /// Minimum height for timed event tiles in Day View (in pixels).
  ///
  /// Even very short events (e.g., 5 minutes) will be rendered at least this
  /// tall to ensure they are visible and tappable.
  /// Defaults to 20.0 pixels.
  final double? timedEventMinHeight;

  /// Border radius for timed event tiles in Day View (in pixels).
  ///
  /// Rounds the corners of timed event tile rectangles.
  /// Defaults to 4.0 pixels.
  final double? timedEventBorderRadius;

  /// Padding inside timed event tiles in Day View.
  ///
  /// Controls spacing between the tile border and the event content (title, time).
  /// Defaults to EdgeInsets.all(2.0).
  final EdgeInsets? timedEventPadding;

  /// Background color for special (non-blocking) time regions in Day View.
  ///
  /// Special time regions are visual indicators for specific time periods
  /// (e.g., lunch break, focus time) that don't prevent event interactions.
  /// When [blockInteraction] is false on a time region, this color is used.
  /// Defaults to Material 3 surfaceContainer with 50% opacity.
  final Color? specialTimeRegionColor;

  /// Background color for blocked time regions in Day View.
  ///
  /// Blocked time regions indicate time periods where events cannot be placed
  /// or moved (e.g., past time, holidays, non-working hours).
  /// When [blockInteraction] is true on a time region, this color is used.
  /// Defaults to Material 3 surfaceContainerHighest with 70% opacity.
  final Color? blockedTimeRegionColor;

  /// Border color for time region overlays in Day View.
  ///
  /// Draws a border around time region rectangles to distinguish them from
  /// the background.
  /// Defaults to Material 3 outline with 30% opacity.
  final Color? timeRegionBorderColor;

  /// Text color for labels inside time regions in Day View.
  ///
  /// Used when time regions display text (e.g., "Lunch", "Blocked").
  /// Defaults to Material 3 onSurfaceVariant with 60% opacity.
  final Color? timeRegionTextColor;

  /// Text style for labels inside time regions in Day View.
  ///
  /// Used when time regions display text.
  /// Defaults to Material 3 labelSmall with onSurfaceVariant color at 60% opacity.
  final TextStyle? timeRegionTextStyle;

  /// Hit area size for resize handles on timed events (in logical pixels).
  ///
  /// The resize handle provides an ~8dp hit area at the top and bottom edges
  /// of event tiles for drag-to-resize. Defaults to 8.0.
  final double? resizeHandleSize;

  /// Minimum event duration (in minutes) required to show resize handles.
  ///
  /// Events shorter than this duration will not display resize handles,
  /// since resizing them could violate the minimum duration constraint.
  /// Defaults to 15 minutes.
  final int? minResizeDurationMinutes;

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
    this.dropTargetCellValidColor,
    this.dropTargetCellInvalidColor,
    this.dropTargetCellBorderRadius,
    this.dragSourceOpacity,
    this.draggedTileElevation,
    this.multiDayEventBackgroundColor,
    this.multiDayEventTextStyle,
    this.eventTileHeight,
    this.eventTileHorizontalSpacing,
    this.eventTileVerticalSpacing,
    this.dateLabelHeight,
    this.dateLabelPosition,
    this.overflowIndicatorHeight,
    this.eventTileCornerRadius,
    this.ignoreEventColors = false,
    this.eventTileBorderColor,
    this.eventTileBorderWidth,
    this.dropTargetTileBackgroundColor,
    this.dropTargetTileInvalidBackgroundColor,
    this.dropTargetTileCornerRadius,
    this.dropTargetTileBorderColor,
    this.dropTargetTileBorderWidth,
    // Day View properties
    this.dayHeaderDayOfWeekStyle,
    this.dayHeaderDateStyle,
    this.weekNumberTextColor,
    this.timeLegendWidth,
    this.timeLegendTextStyle,
    this.timeLegendBackgroundColor,
    this.hourGridlineColor,
    this.hourGridlineWidth,
    this.majorGridlineColor,
    this.majorGridlineWidth,
    this.minorGridlineColor,
    this.minorGridlineWidth,
    this.currentTimeIndicatorColor,
    this.currentTimeIndicatorWidth,
    this.currentTimeIndicatorDotRadius,
    this.allDaySectionMaxRows,
    this.timedEventMinHeight,
    this.timedEventBorderRadius,
    this.timedEventPadding,
    this.specialTimeRegionColor,
    this.blockedTimeRegionColor,
    this.timeRegionBorderColor,
    this.timeRegionTextColor,
    this.timeRegionTextStyle,
    this.resizeHandleSize,
    this.minResizeDurationMinutes,
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
      hoverEventBackgroundColor: colorScheme.primaryContainer.withValues(
        alpha: 0.8,
      ),
      dropTargetCellValidColor: Colors.green.withValues(alpha: 0.3),
      dropTargetCellInvalidColor: Colors.red.withValues(alpha: 0.3),
      dropTargetCellBorderRadius: 4.0,
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
      dateLabelHeight: 18.0,
      dateLabelPosition: DateLabelPosition.topLeft,
      overflowIndicatorHeight: 14.0,
      eventTileCornerRadius: 3.0,
      ignoreEventColors: false,
      // Day View properties
      dayHeaderDayOfWeekStyle: textTheme.labelMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
      dayHeaderDateStyle: textTheme.headlineMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      weekNumberTextColor: colorScheme.onSurfaceVariant,
      timeLegendWidth: 60.0,
      timeLegendTextStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      timeLegendBackgroundColor: colorScheme.surfaceContainerLow,
      hourGridlineColor: colorScheme.outline.withValues(alpha: 0.2),
      hourGridlineWidth: 1.0,
      majorGridlineColor: colorScheme.outline.withValues(alpha: 0.15),
      majorGridlineWidth: 1.0,
      minorGridlineColor: colorScheme.outline.withValues(alpha: 0.08),
      minorGridlineWidth: 0.5,
      currentTimeIndicatorColor: colorScheme.primary,
      currentTimeIndicatorWidth: 2.0,
      currentTimeIndicatorDotRadius: 6.0,
      allDaySectionMaxRows: 3,
      timedEventMinHeight: 20.0,
      timedEventBorderRadius: 4.0,
      timedEventPadding: const EdgeInsets.all(2.0),
      specialTimeRegionColor: colorScheme.surfaceContainer.withValues(alpha: 0.5),
      blockedTimeRegionColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
      timeRegionBorderColor: colorScheme.outline.withValues(alpha: 0.3),
      timeRegionTextColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      timeRegionTextStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      ),
    );
  }

  /// Creates a copy of this [MCalThemeData] with the given fields replaced.
  ///
  /// All parameters are optional; omitted fields retain their current values.
  /// Use this for incremental theme customization.
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
    Color? dropTargetCellValidColor,
    Color? dropTargetCellInvalidColor,
    double? dropTargetCellBorderRadius,
    double? dragSourceOpacity,
    double? draggedTileElevation,
    Color? multiDayEventBackgroundColor,
    TextStyle? multiDayEventTextStyle,
    double? eventTileHeight,
    double? eventTileHorizontalSpacing,
    double? eventTileVerticalSpacing,
    double? dateLabelHeight,
    DateLabelPosition? dateLabelPosition,
    double? overflowIndicatorHeight,
    double? eventTileCornerRadius,
    bool? ignoreEventColors,
    Color? eventTileBorderColor,
    double? eventTileBorderWidth,
    Color? dropTargetTileBackgroundColor,
    Color? dropTargetTileInvalidBackgroundColor,
    double? dropTargetTileCornerRadius,
    Color? dropTargetTileBorderColor,
    double? dropTargetTileBorderWidth,
    // Day View parameters
    TextStyle? dayHeaderDayOfWeekStyle,
    TextStyle? dayHeaderDateStyle,
    Color? weekNumberTextColor,
    double? timeLegendWidth,
    TextStyle? timeLegendTextStyle,
    Color? timeLegendBackgroundColor,
    Color? hourGridlineColor,
    double? hourGridlineWidth,
    Color? majorGridlineColor,
    double? majorGridlineWidth,
    Color? minorGridlineColor,
    double? minorGridlineWidth,
    Color? currentTimeIndicatorColor,
    double? currentTimeIndicatorWidth,
    double? currentTimeIndicatorDotRadius,
    int? allDaySectionMaxRows,
    double? timedEventMinHeight,
    double? timedEventBorderRadius,
    EdgeInsets? timedEventPadding,
    Color? specialTimeRegionColor,
    Color? blockedTimeRegionColor,
    Color? timeRegionBorderColor,
    Color? timeRegionTextColor,
    TextStyle? timeRegionTextStyle,
    double? resizeHandleSize,
    int? minResizeDurationMinutes,
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
      leadingDatesBackgroundColor:
          leadingDatesBackgroundColor ?? this.leadingDatesBackgroundColor,
      trailingDatesBackgroundColor:
          trailingDatesBackgroundColor ?? this.trailingDatesBackgroundColor,
      weekdayHeaderTextStyle:
          weekdayHeaderTextStyle ?? this.weekdayHeaderTextStyle,
      weekdayHeaderBackgroundColor:
          weekdayHeaderBackgroundColor ?? this.weekdayHeaderBackgroundColor,
      eventTileBackgroundColor:
          eventTileBackgroundColor ?? this.eventTileBackgroundColor,
      eventTileTextStyle: eventTileTextStyle ?? this.eventTileTextStyle,
      navigatorTextStyle: navigatorTextStyle ?? this.navigatorTextStyle,
      navigatorBackgroundColor:
          navigatorBackgroundColor ?? this.navigatorBackgroundColor,
      focusedDateBackgroundColor:
          focusedDateBackgroundColor ?? this.focusedDateBackgroundColor,
      focusedDateTextStyle: focusedDateTextStyle ?? this.focusedDateTextStyle,
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
      hoverCellBackgroundColor:
          hoverCellBackgroundColor ?? this.hoverCellBackgroundColor,
      hoverEventBackgroundColor:
          hoverEventBackgroundColor ?? this.hoverEventBackgroundColor,
      dropTargetCellValidColor:
          dropTargetCellValidColor ?? this.dropTargetCellValidColor,
      dropTargetCellInvalidColor:
          dropTargetCellInvalidColor ?? this.dropTargetCellInvalidColor,
      dropTargetCellBorderRadius:
          dropTargetCellBorderRadius ?? this.dropTargetCellBorderRadius,
      dragSourceOpacity: dragSourceOpacity ?? this.dragSourceOpacity,
      draggedTileElevation: draggedTileElevation ?? this.draggedTileElevation,
      multiDayEventBackgroundColor:
          multiDayEventBackgroundColor ?? this.multiDayEventBackgroundColor,
      multiDayEventTextStyle:
          multiDayEventTextStyle ?? this.multiDayEventTextStyle,
      eventTileHeight: eventTileHeight ?? this.eventTileHeight,
      eventTileHorizontalSpacing:
          eventTileHorizontalSpacing ?? this.eventTileHorizontalSpacing,
      eventTileVerticalSpacing:
          eventTileVerticalSpacing ?? this.eventTileVerticalSpacing,
      dateLabelHeight: dateLabelHeight ?? this.dateLabelHeight,
      dateLabelPosition: dateLabelPosition ?? this.dateLabelPosition,
      overflowIndicatorHeight:
          overflowIndicatorHeight ?? this.overflowIndicatorHeight,
      eventTileCornerRadius:
          eventTileCornerRadius ?? this.eventTileCornerRadius,
      ignoreEventColors: ignoreEventColors ?? this.ignoreEventColors,
      eventTileBorderColor: eventTileBorderColor ?? this.eventTileBorderColor,
      eventTileBorderWidth: eventTileBorderWidth ?? this.eventTileBorderWidth,
      dropTargetTileBackgroundColor: dropTargetTileBackgroundColor ??
          this.dropTargetTileBackgroundColor,
      dropTargetTileInvalidBackgroundColor: dropTargetTileInvalidBackgroundColor ??
          this.dropTargetTileInvalidBackgroundColor,
      dropTargetTileCornerRadius: dropTargetTileCornerRadius ??
          this.dropTargetTileCornerRadius,
      dropTargetTileBorderColor: dropTargetTileBorderColor ??
          this.dropTargetTileBorderColor,
      dropTargetTileBorderWidth: dropTargetTileBorderWidth ??
          this.dropTargetTileBorderWidth,
      // Day View properties
      dayHeaderDayOfWeekStyle: dayHeaderDayOfWeekStyle ?? this.dayHeaderDayOfWeekStyle,
      dayHeaderDateStyle: dayHeaderDateStyle ?? this.dayHeaderDateStyle,
      weekNumberTextColor: weekNumberTextColor ?? this.weekNumberTextColor,
      timeLegendWidth: timeLegendWidth ?? this.timeLegendWidth,
      timeLegendTextStyle: timeLegendTextStyle ?? this.timeLegendTextStyle,
      timeLegendBackgroundColor: timeLegendBackgroundColor ?? this.timeLegendBackgroundColor,
      hourGridlineColor: hourGridlineColor ?? this.hourGridlineColor,
      hourGridlineWidth: hourGridlineWidth ?? this.hourGridlineWidth,
      majorGridlineColor: majorGridlineColor ?? this.majorGridlineColor,
      majorGridlineWidth: majorGridlineWidth ?? this.majorGridlineWidth,
      minorGridlineColor: minorGridlineColor ?? this.minorGridlineColor,
      minorGridlineWidth: minorGridlineWidth ?? this.minorGridlineWidth,
      currentTimeIndicatorColor: currentTimeIndicatorColor ?? this.currentTimeIndicatorColor,
      currentTimeIndicatorWidth: currentTimeIndicatorWidth ?? this.currentTimeIndicatorWidth,
      currentTimeIndicatorDotRadius: currentTimeIndicatorDotRadius ?? this.currentTimeIndicatorDotRadius,
      allDaySectionMaxRows: allDaySectionMaxRows ?? this.allDaySectionMaxRows,
      timedEventMinHeight: timedEventMinHeight ?? this.timedEventMinHeight,
      timedEventBorderRadius: timedEventBorderRadius ?? this.timedEventBorderRadius,
      timedEventPadding: timedEventPadding ?? this.timedEventPadding,
      specialTimeRegionColor: specialTimeRegionColor ?? this.specialTimeRegionColor,
      blockedTimeRegionColor: blockedTimeRegionColor ?? this.blockedTimeRegionColor,
      timeRegionBorderColor: timeRegionBorderColor ?? this.timeRegionBorderColor,
      timeRegionTextColor: timeRegionTextColor ?? this.timeRegionTextColor,
      timeRegionTextStyle: timeRegionTextStyle ?? this.timeRegionTextStyle,
      resizeHandleSize: resizeHandleSize ?? this.resizeHandleSize,
      minResizeDurationMinutes: minResizeDurationMinutes ?? this.minResizeDurationMinutes,
    );
  }

  /// Linearly interpolates between this theme and [other] by [t].
  ///
  /// Used for animated theme transitions. Returns this instance unchanged
  /// if [other] is not an [MCalThemeData].
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
      cellBorderColor: Color.lerp(cellBorderColor, other.cellBorderColor, t),
      cellTextStyle: TextStyle.lerp(cellTextStyle, other.cellTextStyle, t),
      todayBackgroundColor: Color.lerp(
        todayBackgroundColor,
        other.todayBackgroundColor,
        t,
      ),
      todayTextStyle: TextStyle.lerp(todayTextStyle, other.todayTextStyle, t),
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
      dropTargetCellValidColor: Color.lerp(
        dropTargetCellValidColor,
        other.dropTargetCellValidColor,
        t,
      ),
      dropTargetCellInvalidColor: Color.lerp(
        dropTargetCellInvalidColor,
        other.dropTargetCellInvalidColor,
        t,
      ),
      dropTargetCellBorderRadius: _lerpDouble(
        dropTargetCellBorderRadius,
        other.dropTargetCellBorderRadius,
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
      eventTileHeight: _lerpDouble(eventTileHeight, other.eventTileHeight, t),
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
      dateLabelHeight: _lerpDouble(dateLabelHeight, other.dateLabelHeight, t),
      dateLabelPosition: t < 0.5 ? dateLabelPosition : other.dateLabelPosition,
      overflowIndicatorHeight: _lerpDouble(
        overflowIndicatorHeight,
        other.overflowIndicatorHeight,
        t,
      ),
      eventTileCornerRadius: _lerpDouble(
        eventTileCornerRadius,
        other.eventTileCornerRadius,
        t,
      ),
      ignoreEventColors: t < 0.5 ? ignoreEventColors : other.ignoreEventColors,
      eventTileBorderColor: Color.lerp(
        eventTileBorderColor,
        other.eventTileBorderColor,
        t,
      ),
      eventTileBorderWidth: _lerpDouble(
        eventTileBorderWidth,
        other.eventTileBorderWidth,
        t,
      ),
      dropTargetTileBackgroundColor: Color.lerp(
        dropTargetTileBackgroundColor,
        other.dropTargetTileBackgroundColor,
        t,
      ),
      dropTargetTileInvalidBackgroundColor: Color.lerp(
        dropTargetTileInvalidBackgroundColor,
        other.dropTargetTileInvalidBackgroundColor,
        t,
      ),
      dropTargetTileCornerRadius: _lerpDouble(
        dropTargetTileCornerRadius,
        other.dropTargetTileCornerRadius,
        t,
      ),
      dropTargetTileBorderColor: Color.lerp(
        dropTargetTileBorderColor,
        other.dropTargetTileBorderColor,
        t,
      ),
      dropTargetTileBorderWidth: _lerpDouble(
        dropTargetTileBorderWidth,
        other.dropTargetTileBorderWidth,
        t,
      ),
      // Day View properties
      dayHeaderDayOfWeekStyle: TextStyle.lerp(
        dayHeaderDayOfWeekStyle,
        other.dayHeaderDayOfWeekStyle,
        t,
      ),
      dayHeaderDateStyle: TextStyle.lerp(
        dayHeaderDateStyle,
        other.dayHeaderDateStyle,
        t,
      ),
      weekNumberTextColor: Color.lerp(
        weekNumberTextColor,
        other.weekNumberTextColor,
        t,
      ),
      timeLegendWidth: _lerpDouble(timeLegendWidth, other.timeLegendWidth, t),
      timeLegendTextStyle: TextStyle.lerp(
        timeLegendTextStyle,
        other.timeLegendTextStyle,
        t,
      ),
      timeLegendBackgroundColor: Color.lerp(
        timeLegendBackgroundColor,
        other.timeLegendBackgroundColor,
        t,
      ),
      hourGridlineColor: Color.lerp(
        hourGridlineColor,
        other.hourGridlineColor,
        t,
      ),
      hourGridlineWidth: _lerpDouble(
        hourGridlineWidth,
        other.hourGridlineWidth,
        t,
      ),
      majorGridlineColor: Color.lerp(
        majorGridlineColor,
        other.majorGridlineColor,
        t,
      ),
      majorGridlineWidth: _lerpDouble(
        majorGridlineWidth,
        other.majorGridlineWidth,
        t,
      ),
      minorGridlineColor: Color.lerp(
        minorGridlineColor,
        other.minorGridlineColor,
        t,
      ),
      minorGridlineWidth: _lerpDouble(
        minorGridlineWidth,
        other.minorGridlineWidth,
        t,
      ),
      currentTimeIndicatorColor: Color.lerp(
        currentTimeIndicatorColor,
        other.currentTimeIndicatorColor,
        t,
      ),
      currentTimeIndicatorWidth: _lerpDouble(
        currentTimeIndicatorWidth,
        other.currentTimeIndicatorWidth,
        t,
      ),
      currentTimeIndicatorDotRadius: _lerpDouble(
        currentTimeIndicatorDotRadius,
        other.currentTimeIndicatorDotRadius,
        t,
      ),
      allDaySectionMaxRows: t < 0.5 ? allDaySectionMaxRows : other.allDaySectionMaxRows,
      timedEventMinHeight: _lerpDouble(
        timedEventMinHeight,
        other.timedEventMinHeight,
        t,
      ),
      timedEventBorderRadius: _lerpDouble(
        timedEventBorderRadius,
        other.timedEventBorderRadius,
        t,
      ),
      timedEventPadding: EdgeInsets.lerp(
        timedEventPadding,
        other.timedEventPadding,
        t,
      ),
      specialTimeRegionColor: Color.lerp(
        specialTimeRegionColor,
        other.specialTimeRegionColor,
        t,
      ),
      blockedTimeRegionColor: Color.lerp(
        blockedTimeRegionColor,
        other.blockedTimeRegionColor,
        t,
      ),
      timeRegionBorderColor: Color.lerp(
        timeRegionBorderColor,
        other.timeRegionBorderColor,
        t,
      ),
      timeRegionTextColor: Color.lerp(
        timeRegionTextColor,
        other.timeRegionTextColor,
        t,
      ),
      timeRegionTextStyle: TextStyle.lerp(
        timeRegionTextStyle,
        other.timeRegionTextStyle,
        t,
      ),
      resizeHandleSize: _lerpDouble(
        resizeHandleSize,
        other.resizeHandleSize,
        t,
      ),
      minResizeDurationMinutes: t < 0.5 ? minResizeDurationMinutes : other.minResizeDurationMinutes,
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
