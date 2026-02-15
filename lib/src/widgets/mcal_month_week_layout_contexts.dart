import 'package:flutter/material.dart';
import '../models/mcal_calendar_event.dart';
import '../styles/mcal_theme.dart';
import 'mcal_month_view_contexts.dart';

/// Position of the date label within a day cell.
///
/// Used by [MCalWeekLayoutConfig] to configure where date labels
/// are rendered relative to event tiles.
enum DateLabelPosition {
  /// Date label positioned at the top-left of the cell.
  topLeft,

  /// Date label positioned at the top-center of the cell.
  topCenter,

  /// Date label positioned at the top-right of the cell.
  topRight,

  /// Date label positioned at the bottom-left of the cell.
  bottomLeft,

  /// Date label positioned at the bottom-center of the cell.
  bottomCenter,

  /// Date label positioned at the bottom-right of the cell.
  bottomRight,
}

/// Represents a segment of an event within a single week row.
///
/// Events that span multiple days are split into segments, where each segment
/// represents the portion of the event visible within a specific week.
/// Single-day events have a segment with [spanDays] = 1.
///
/// This class is used by the layout algorithm to position event tiles
/// correctly across the calendar grid.
///
/// Example:
/// ```dart
/// final segment = MCalEventSegment(
///   event: myEvent,
///   weekRowIndex: 0,
///   startDayInWeek: 2, // Wednesday
///   endDayInWeek: 4,   // Friday
///   isFirstSegment: true,
///   isLastSegment: false, // Event continues next week
/// );
/// print(segment.spanDays); // 3
/// ```
class MCalMonthEventSegment {
  /// The calendar event this segment represents.
  final MCalCalendarEvent event;

  /// The row index within the week where this segment is positioned.
  ///
  /// Row 0 is typically the first row below the date labels.
  final int weekRowIndex;

  /// The starting day index within the week (0-6, where 0 is the first day).
  final int startDayInWeek;

  /// The ending day index within the week (0-6, where 6 is the last day).
  final int endDayInWeek;

  /// Whether this is the first segment of the event.
  ///
  /// True if this segment contains the actual start of the event.
  /// Used for rendering visual continuity (e.g., rounded left edge).
  final bool isFirstSegment;

  /// Whether this is the last segment of the event.
  ///
  /// True if this segment contains the actual end of the event.
  /// Used for rendering visual continuity (e.g., rounded right edge).
  final bool isLastSegment;

  /// Creates a new [MCalMonthEventSegment] instance.
  const MCalMonthEventSegment({
    required this.event,
    required this.weekRowIndex,
    required this.startDayInWeek,
    required this.endDayInWeek,
    required this.isFirstSegment,
    required this.isLastSegment,
  });

  /// The number of days this segment spans within the week.
  ///
  /// A value of 1 indicates a single-day event or the portion of a
  /// multi-day event within a single day.
  int get spanDays => endDayInWeek - startDayInWeek + 1;

  /// Whether this segment represents a complete single-day event.
  ///
  /// Returns true only if the segment spans exactly one day AND
  /// is both the first and last segment (i.e., the entire event).
  bool get isSingleDay => spanDays == 1 && isFirstSegment && isLastSegment;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MCalMonthEventSegment &&
        other.event == event &&
        other.weekRowIndex == weekRowIndex &&
        other.startDayInWeek == startDayInWeek &&
        other.endDayInWeek == endDayInWeek &&
        other.isFirstSegment == isFirstSegment &&
        other.isLastSegment == isLastSegment;
  }

  @override
  int get hashCode {
    return Object.hash(
      event,
      weekRowIndex,
      startDayInWeek,
      endDayInWeek,
      isFirstSegment,
      isLastSegment,
    );
  }

  @override
  String toString() {
    return 'MCalEventSegment('
        'event: ${event.id}, '
        'weekRowIndex: $weekRowIndex, '
        'startDayInWeek: $startDayInWeek, '
        'endDayInWeek: $endDayInWeek, '
        'isFirstSegment: $isFirstSegment, '
        'isLastSegment: $isLastSegment, '
        'spanDays: $spanDays, '
        'isSingleDay: $isSingleDay)';
  }
}

/// Configuration for week layout rendering.
///
/// Contains all layout-related values needed for positioning event tiles,
/// date labels, and overflow indicators within a week row.
///
/// Use [MCalWeekLayoutConfig.fromTheme] to create a configuration that
/// inherits values from [MCalThemeData] with sensible defaults.
///
/// Example:
/// ```dart
/// final config = MCalWeekLayoutConfig.fromTheme(theme);
/// // Or with custom overrides:
/// final customConfig = MCalMonthWeekLayoutConfig(
///   tileHeight: 24.0,
///   dateLabelPosition: DateLabelPosition.topCenter,
/// );
/// ```
class MCalMonthWeekLayoutConfig {
  /// Height of event tiles in pixels.
  ///
  /// Defaults to 18.0 when using [fromTheme].
  final double tileHeight;

  /// Vertical spacing between event tile rows in pixels.
  ///
  /// Defaults to 2.0 when using [fromTheme].
  final double tileVerticalSpacing;

  /// Horizontal spacing around event tiles in pixels.
  ///
  /// For multi-day tiles, this spacing is only applied at the actual
  /// start and end of the event, not at continuation points.
  ///
  /// Defaults to 2.0 when using [fromTheme].
  final double tileHorizontalSpacing;

  /// Corner radius for event tiles in pixels.
  ///
  /// Defaults to 3.0 when using [fromTheme].
  final double eventTileCornerRadius;

  /// Border width for event tiles in pixels.
  ///
  /// Defaults to 0.0 when using [fromTheme].
  final double tileBorderWidth;

  /// Height of the date label area in pixels.
  ///
  /// Defaults to 18.0 when using [fromTheme].
  final double dateLabelHeight;

  /// Position of date labels within day cells.
  ///
  /// Defaults to [DateLabelPosition.topLeft] when using [fromTheme].
  final DateLabelPosition dateLabelPosition;

  /// Height of the overflow indicator in pixels.
  ///
  /// Defaults to 14.0 when using [fromTheme].
  final double overflowIndicatorHeight;

  /// Maximum number of visible events per day.
  ///
  /// If the number of events exceeds this limit OR exceeds what fits by height,
  /// an overflow indicator is shown. Defaults to 5.
  final int maxVisibleEventsPerDay;

  /// Creates a new [MCalWeekLayoutConfig] instance.
  const MCalMonthWeekLayoutConfig({
    required this.tileHeight,
    required this.tileVerticalSpacing,
    required this.tileHorizontalSpacing,
    required this.eventTileCornerRadius,
    required this.tileBorderWidth,
    required this.dateLabelHeight,
    required this.dateLabelPosition,
    required this.overflowIndicatorHeight,
    this.maxVisibleEventsPerDay = 5,
  });

  /// Creates a [MCalWeekLayoutConfig] with values from [MCalThemeData].
  ///
  /// Inherits values from the theme where available, using sensible
  /// defaults for values not specified in the theme:
  /// - tileHeight: theme.eventTileHeight ?? 18.0
  /// - tileVerticalSpacing: theme.eventTileVerticalSpacing ?? 2.0
  /// - tileHorizontalSpacing: theme.eventTileHorizontalSpacing ?? 2.0
  /// - eventTileCornerRadius: 3.0
  /// - tileBorderWidth: 0.0
  /// - dateLabelHeight: 18.0
  /// - dateLabelPosition: DateLabelPosition.topLeft
  /// - overflowIndicatorHeight: 14.0
  /// - maxVisibleEventsPerDay: defaults to 5
  factory MCalMonthWeekLayoutConfig.fromTheme(
    MCalThemeData theme, {
    int maxVisibleEventsPerDay = 5,
  }) {
    return MCalMonthWeekLayoutConfig(
      tileHeight: theme.eventTileHeight ?? 18.0,
      tileVerticalSpacing: theme.eventTileVerticalSpacing ?? 2.0,
      tileHorizontalSpacing: theme.eventTileHorizontalSpacing ?? 2.0,
      eventTileCornerRadius: theme.eventTileCornerRadius ?? 3.0,
      tileBorderWidth: 0.0,
      dateLabelHeight: theme.dateLabelHeight ?? 18.0,
      dateLabelPosition: theme.dateLabelPosition ?? DateLabelPosition.topLeft,
      overflowIndicatorHeight: theme.overflowIndicatorHeight ?? 14.0,
      maxVisibleEventsPerDay: maxVisibleEventsPerDay,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MCalMonthWeekLayoutConfig &&
        other.tileHeight == tileHeight &&
        other.tileVerticalSpacing == tileVerticalSpacing &&
        other.tileHorizontalSpacing == tileHorizontalSpacing &&
        other.eventTileCornerRadius == eventTileCornerRadius &&
        other.tileBorderWidth == tileBorderWidth &&
        other.dateLabelHeight == dateLabelHeight &&
        other.dateLabelPosition == dateLabelPosition &&
        other.overflowIndicatorHeight == overflowIndicatorHeight &&
        other.maxVisibleEventsPerDay == maxVisibleEventsPerDay;
  }

  @override
  int get hashCode {
    return Object.hash(
      tileHeight,
      tileVerticalSpacing,
      tileHorizontalSpacing,
      eventTileCornerRadius,
      tileBorderWidth,
      dateLabelHeight,
      dateLabelPosition,
      overflowIndicatorHeight,
      maxVisibleEventsPerDay,
    );
  }

  @override
  String toString() {
    return 'MCalMonthWeekLayoutConfig('
        'tileHeight: $tileHeight, '
        'tileVerticalSpacing: $tileVerticalSpacing, '
        'tileHorizontalSpacing: $tileHorizontalSpacing, '
        'eventTileCornerRadius: $eventTileCornerRadius, '
        'tileBorderWidth: $tileBorderWidth, '
        'dateLabelHeight: $dateLabelHeight, '
        'dateLabelPosition: $dateLabelPosition, '
        'overflowIndicatorHeight: $overflowIndicatorHeight, '
        'maxVisibleEventsPerDay: $maxVisibleEventsPerDay)';
  }
}

/// Context object for overflow indicator builder callbacks.
///
/// Provides all necessary data for customizing the rendering of overflow
/// indicators that appear when more events exist than can be displayed
/// within a day cell.
///
/// Theme data is accessed via `MCalTheme.of(context)` from within the builder
/// callback, rather than being passed through this context object.
///
/// Example:
/// ```dart
/// overflowIndicatorBuilder: (context, ctx) {
///   return GestureDetector(
///     onTap: () => showEventList(ctx.date, ctx.hiddenEvents),
///     child: Container(
///       width: ctx.width,
///       height: ctx.height,
///       child: Text('+${ctx.hiddenEventCount} more'),
///     ),
///   );
/// }
/// ```
///
/// **Note:** The overflow indicator does not support drag-and-drop. Only
/// visible event tiles can be dragged. Use [onOverflowTap] or [onOverflowLongPress]
/// to let users view hidden events in a separate UI.
class MCalMonthOverflowIndicatorContext {
  /// The date for which overflow is occurring.
  final DateTime date;

  /// The number of events that are hidden due to space constraints.
  final int hiddenEventCount;

  /// List of events that are hidden and not displayed.
  final List<MCalCalendarEvent> hiddenEvents;

  /// List of events that are currently visible/displayed.
  final List<MCalCalendarEvent> visibleEvents;

  /// The available width for the overflow indicator in pixels.
  final double width;

  /// The height for the overflow indicator in pixels.
  final double height;

  /// Creates a new [MCalOverflowIndicatorContext] instance.
  const MCalMonthOverflowIndicatorContext({
    required this.date,
    required this.hiddenEventCount,
    required this.hiddenEvents,
    required this.visibleEvents,
    required this.width,
    required this.height,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MCalMonthOverflowIndicatorContext) return false;
    if (other.date != date ||
        other.hiddenEventCount != hiddenEventCount ||
        other.width != width ||
        other.height != height) {
      return false;
    }
    if (other.hiddenEvents.length != hiddenEvents.length ||
        other.visibleEvents.length != visibleEvents.length) {
      return false;
    }
    for (int i = 0; i < hiddenEvents.length; i++) {
      if (other.hiddenEvents[i] != hiddenEvents[i]) return false;
    }
    for (int i = 0; i < visibleEvents.length; i++) {
      if (other.visibleEvents[i] != visibleEvents[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      date,
      hiddenEventCount,
      Object.hashAll(hiddenEvents),
      Object.hashAll(visibleEvents),
      width,
      height,
    );
  }

  @override
  String toString() {
    return 'MCalMonthOverflowIndicatorContext('
        'date: $date, '
        'hiddenEventCount: $hiddenEventCount, '
        'hiddenEvents: ${hiddenEvents.length} items, '
        'visibleEvents: ${visibleEvents.length} items, '
        'width: $width, '
        'height: $height)';
  }
}

/// Builder function signature for event tiles.
///
/// Returns a widget representing the event tile for the given context.
typedef MCalEventTileBuilder =
    Widget Function(BuildContext context, MCalEventTileContext tileContext);

/// Builder function signature for date labels.
///
/// Returns a widget representing the date label for the given context.
typedef MCalDateLabelBuilder =
    Widget Function(BuildContext context, MCalDateLabelContext labelContext);

/// Builder function signature for overflow indicators.
///
/// Returns a widget representing the overflow indicator for the given context.
typedef MCalOverflowIndicatorBuilder =
    Widget Function(
      BuildContext context,
      MCalMonthOverflowIndicatorContext overflowContext,
    );

/// Context object for week layout builder callbacks.
///
/// Provides all necessary data for customizing the rendering of an entire
/// week row in the calendar, including event segments, date information,
/// and pre-configured builder functions.
///
/// This is the main context object passed to the `weekLayoutBuilder` callback
/// on [MCalMonthView].
///
/// Theme data is accessed via `MCalTheme.of(context)` from within the builder
/// callback, rather than being passed through this context object.
///
/// Example:
/// ```dart
/// weekLayoutBuilder: (context, ctx) {
///   return Stack(
///     children: [
///       // Build date labels
///       for (int i = 0; i < 7; i++)
///         Positioned(
///           left: _calculateLeft(i, ctx.columnWidths),
///           child: ctx.dateLabelBuilder(context, dateLabelContext),
///         ),
///       // Build event tiles
///       for (final segment in ctx.segments)
///         Positioned(
///           left: _calculateLeft(segment.startDayInWeek, ctx.columnWidths),
///           top: _calculateTop(segment.weekRowIndex, ctx.config),
///           child: ctx.eventTileBuilder(context, tileContext),
///         ),
///     ],
///   );
/// }
/// ```
class MCalMonthWeekLayoutContext {
  /// List of event segments to render within this week row.
  ///
  /// Each segment represents either a complete single-day event or
  /// a portion of a multi-day event visible within this week.
  final List<MCalMonthEventSegment> segments;

  /// The seven dates represented by this week row.
  ///
  /// Always contains exactly 7 items, ordered from the first day
  /// of the week to the last.
  final List<DateTime> dates;

  /// The width of each day column in pixels.
  ///
  /// Always contains exactly 7 items, corresponding to [dates].
  final List<double> columnWidths;

  /// The total height of the week row in pixels.
  final double rowHeight;

  /// The index of this week row within the month (0-based).
  final int weekRowIndex;

  /// The first day of the currently displayed month.
  ///
  /// Used to determine which dates belong to the current month
  /// vs. leading/trailing dates from adjacent months.
  final DateTime currentMonth;

  /// Configuration for layout values (tile heights, spacing, etc.).
  final MCalMonthWeekLayoutConfig config;

  /// Builder function for rendering event tiles.
  ///
  /// This builder is pre-wrapped with interaction handlers (tap, long-press,
  /// drag-and-drop) and should be called to create each event tile widget.
  final MCalEventTileBuilder eventTileBuilder;

  /// Builder function for rendering date labels.
  ///
  /// This builder should be called to create the date label widget
  /// for each day in the week.
  final MCalDateLabelBuilder dateLabelBuilder;

  /// Builder function for rendering overflow indicators.
  ///
  /// This builder is pre-wrapped with tap handlers and should be called
  /// to create overflow indicator widgets when events are hidden.
  final MCalOverflowIndicatorBuilder overflowIndicatorBuilder;

  /// Creates a new [MCalWeekLayoutContext] instance.
  const MCalMonthWeekLayoutContext({
    required this.segments,
    required this.dates,
    required this.columnWidths,
    required this.rowHeight,
    required this.weekRowIndex,
    required this.currentMonth,
    required this.config,
    required this.eventTileBuilder,
    required this.dateLabelBuilder,
    required this.overflowIndicatorBuilder,
  });

  @override
  String toString() {
    return 'MCalMonthWeekLayoutContext('
        'segments: ${segments.length} items, '
        'dates: ${dates.isNotEmpty ? "${dates.first} - ${dates.last}" : "empty"}, '
        'columnWidths: ${columnWidths.length} items, '
        'rowHeight: $rowHeight, '
        'weekRowIndex: $weekRowIndex, '
        'currentMonth: $currentMonth, '
        'config: $config)';
  }
}
