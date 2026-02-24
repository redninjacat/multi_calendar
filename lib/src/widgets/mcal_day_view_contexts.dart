import '../models/mcal_calendar_event.dart';
import '../models/mcal_time_region.dart';

/// Position of time labels relative to hour gridlines in Day View.
///
/// Defines the 8 possible positions for time labels, combining:
/// - **Horizontal alignment** (leading/trailing):
///   - "Leading" = left edge in LTR layouts, right edge in RTL layouts
///   - "Trailing" = right edge in LTR layouts, left edge in RTL layouts
/// - **Vertical reference** (top/bottom):
///   - "Top" = positioned relative to the hour start gridline
///   - "Bottom" = positioned relative to the hour end gridline
/// - **Vertical alignment** (above/centered/below):
///   - "Above" = label bottom edge aligns with gridline
///   - "Centered" = label center aligns with gridline
///   - "Below" = label top edge aligns with gridline
///
/// The default position is [topTrailingBelow], which places labels in the
/// top-right corner of each hour slot in LTR layouts (top-left in RTL).
///
/// Example:
/// ```dart
/// MCalDayView(
///   theme: MCalDayThemeData(
///     timeLabelPosition: MCalTimeLabelPosition.topLeadingCentered,
///   ),
///   // Labels will appear on the left (LTR) / right (RTL), centered on hour lines
/// )
/// ```
enum MCalTimeLabelPosition {
  /// Label at hour start gridline, leading edge, bottom aligns with gridline.
  ///
  /// In LTR: top-left corner, label hangs above the hour start line.
  /// In RTL: top-right corner, label hangs above the hour start line.
  topLeadingAbove,

  /// Label at hour start gridline, leading edge, center aligns with gridline.
  ///
  /// In LTR: left edge, label center on the hour start line.
  /// In RTL: right edge, label center on the hour start line.
  topLeadingCentered,

  /// Label at hour start gridline, leading edge, top aligns with gridline.
  ///
  /// In LTR: top-left corner, label starts at the hour start line.
  /// In RTL: top-right corner, label starts at the hour start line.
  topLeadingBelow,

  /// Label at hour start gridline, trailing edge, bottom aligns with gridline.
  ///
  /// In LTR: top-right corner, label hangs above the hour start line.
  /// In RTL: top-left corner, label hangs above the hour start line.
  topTrailingAbove,

  /// Label at hour start gridline, trailing edge, center aligns with gridline.
  ///
  /// In LTR: right edge, label center on the hour start line.
  /// In RTL: left edge, label center on the hour start line.
  topTrailingCentered,

  /// Label at hour start gridline, trailing edge, top aligns with gridline.
  ///
  /// In LTR: top-right corner, label starts at the hour start line (default).
  /// In RTL: top-left corner, label starts at the hour start line (default).
  topTrailingBelow,

  /// Label at hour end gridline, leading edge, bottom aligns with gridline.
  ///
  /// In LTR: bottom-left corner, label ends at the hour end line.
  /// In RTL: bottom-right corner, label ends at the hour end line.
  bottomLeadingAbove,

  /// Label at hour end gridline, trailing edge, bottom aligns with gridline.
  ///
  /// In LTR: bottom-right corner, label ends at the hour end line.
  /// In RTL: bottom-left corner, label ends at the hour end line.
  bottomTrailingAbove,
}

/// Type of gridline being rendered in Day View.
///
/// Used by [MCalGridlineContext] to distinguish between hour boundaries,
/// major subdivisions (30-minute intervals), and minor subdivisions
/// (e.g., 15-minute intervals).
enum MCalGridlineType {
  /// Primary hour gridline (e.g., 9:00, 10:00).
  ///
  /// Rendered at the start of each hour (minute == 0).
  hour,

  /// Major subdivision gridline (e.g., 30-minute intervals).
  ///
  /// Rendered at half-hour boundaries when the gridline interval is less
  /// than 30 minutes.
  major,

  /// Minor subdivision gridline (e.g., 15-minute intervals).
  ///
  /// Rendered at other interval boundaries that are not hour or major marks.
  minor,
}

/// Context object for day header builder callbacks in Day View.
///
/// Provides all necessary data for customizing the rendering of the day
/// header which displays the day of week, date, and optional ISO 8601
/// week number.
///
/// This context is provided to [MCalDayView.dayHeaderBuilder] when building
/// the header section at the top of the day view.
///
/// Example:
/// ```dart
/// dayHeaderBuilder: (context, ctx) {
///   return Column(
///     children: [
///       Text(
///         DateFormat.EEEE().format(ctx.date),
///         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
///       ),
///       Text(
///         '${ctx.date.day}',
///         style: TextStyle(fontSize: 24),
///       ),
///       if (ctx.weekNumber != null)
///         Text('Week ${ctx.weekNumber}', style: TextStyle(fontSize: 12)),
///     ],
///   );
/// }
/// ```
class MCalDayHeaderContext {
  /// The date being displayed in the day view.
  final DateTime date;

  /// The ISO 8601 week number (1-53) for this date.
  ///
  /// This field is optional and may be null if week numbers are not
  /// being displayed (`showWeekNumbers: false`).
  final int? weekNumber;

  /// Creates a new [MCalDayHeaderContext] instance.
  const MCalDayHeaderContext({required this.date, this.weekNumber});
}

/// Context object for time label builder callbacks in Day View.
///
/// Provides all necessary data for customizing the rendering of time labels
/// in the time legend column (e.g., "9 AM", "2 PM").
///
/// This context is provided to [MCalDayView.timeLabelBuilder] when building
/// each hour label in the time legend column.
///
/// Example:
/// ```dart
/// timeLabelBuilder: (context, ctx) {
///   final formatter = DateFormat.jm(); // Locale-aware time format
///   return Text(
///     formatter.format(ctx.time),
///     style: TextStyle(fontSize: 12, color: Colors.grey),
///   );
/// }
/// ```
class MCalTimeLabelContext {
  /// The hour being labeled (0-23).
  final int hour;

  /// The minute within the hour (typically 0 for hour labels).
  final int minute;

  /// A DateTime instance representing this time (date components are arbitrary).
  ///
  /// Use this with DateFormat for locale-aware time formatting.
  final DateTime time;

  /// Creates a new [MCalTimeLabelContext] instance.
  const MCalTimeLabelContext({
    required this.hour,
    required this.minute,
    required this.time,
  });
}

/// Context object for gridline builder callbacks in Day View.
///
/// Provides all necessary data for customizing the rendering of horizontal
/// gridlines at configured intervals (1, 5, 10, 15, 20, 30, or 60 minutes).
///
/// This context is provided to [MCalDayView.gridlineBuilder] when building
/// each gridline in the day view.
///
/// Example:
/// ```dart
/// gridlineBuilder: (context, ctx) {
///   final color = ctx.type == MCalGridlineType.hour
///       ? Colors.grey.shade400
///       : Colors.grey.shade200;
///   final width = ctx.type == MCalGridlineType.hour ? 1.5 : 0.5;
///
///   return Container(
///     height: width,
///     color: color,
///   );
/// }
/// ```
class MCalGridlineContext {
  /// The hour this gridline belongs to (0-23).
  final int hour;

  /// The minute offset within the hour (0-59).
  final int minute;

  /// Vertical offset in pixels from the top of the time range.
  ///
  /// This is the pixel position where this gridline should be rendered.
  final double offset;

  /// The type of gridline (hour, major, or minor).
  ///
  /// Use this to apply different styling based on gridline importance.
  final MCalGridlineType type;

  /// The configured gridline interval in minutes.
  ///
  /// This is the spacing between gridlines (e.g., 15 for 15-minute intervals).
  final int intervalMinutes;

  /// Creates a new [MCalGridlineContext] instance.
  const MCalGridlineContext({
    required this.hour,
    required this.minute,
    required this.offset,
    required this.type,
    required this.intervalMinutes,
  });

  /// True if this is an hour gridline (minute == 0).
  bool get isHour => type == MCalGridlineType.hour;

  /// True if this is a major subdivision (e.g., 30 minutes).
  bool get isMajor => type == MCalGridlineType.major;

  /// True if this is a minor subdivision.
  bool get isMinor => type == MCalGridlineType.minor;
}

/// Context object for timed event tile builder callbacks in Day View.
///
/// Provides all necessary data for customizing the rendering of timed
/// (non-all-day) event tiles in the day view.
///
/// This context is provided to [MCalDayView.timedEventTileBuilder] when
/// building each timed event tile. It's also used when building drop target
/// preview tiles during drag operations (when [isDropTargetPreview] is true).
///
/// Example:
/// ```dart
/// timedEventTileBuilder: (context, ctx, defaultTile) {
///   if (ctx.isDropTargetPreview == true) {
///     return Opacity(
///       opacity: ctx.dropValid == true ? 0.6 : 0.3,
///       child: defaultTile,
///     );
///   }
///
///   return Container(
///     decoration: BoxDecoration(
///       color: ctx.event.color,
///       borderRadius: BorderRadius.circular(4),
///       border: Border.all(
///         color: ctx.event.color.withOpacity(0.5),
///         width: 2,
///       ),
///     ),
///     child: Padding(
///       padding: EdgeInsets.all(4),
///       child: Text(
///         ctx.event.title,
///         style: TextStyle(fontSize: 12),
///       ),
///     ),
///   );
/// }
/// ```
class MCalTimedEventTileContext {
  /// The calendar event being displayed.
  final MCalCalendarEvent event;

  /// The date being displayed in the day view.
  ///
  /// For multi-day events, this may differ from [event.start].
  final DateTime displayDate;

  /// The column index for this event in the overlap layout.
  ///
  /// When multiple events overlap, they are arranged side-by-side in columns.
  /// This is the zero-based index of this event's column.
  final int columnIndex;

  /// The total number of columns in this overlap group.
  ///
  /// Use this with [columnIndex] to calculate the width of this event tile.
  final int totalColumns;

  /// The start time of this event occurrence on [displayDate].
  final DateTime startTime;

  /// The end time of this event occurrence on [displayDate].
  final DateTime endTime;

  /// Whether the event starts on [displayDate].
  ///
  /// False when this tile represents a continuation segment — the event
  /// started on a previous day. In that case [startTime] is clamped to the
  /// beginning of the visible time window and no start (top) resize handle
  /// should be shown.
  final bool isStartOnDisplayDate;

  /// Whether the event ends on [displayDate].
  ///
  /// False when this tile represents a segment that continues to the next
  /// day. In that case [endTime] is clamped to the end of the visible time
  /// window and no end (bottom) resize handle should be shown.
  final bool isEndOnDisplayDate;

  /// True when this context is used to build a drop target preview tile.
  ///
  /// During drag operations, a semi-transparent preview tile is shown at
  /// the proposed drop location. This flag is null or false for normal
  /// event tiles.
  final bool? isDropTargetPreview;

  /// True when the proposed drop is valid; false when invalid.
  ///
  /// Only set when [isDropTargetPreview] is true. Use this to style
  /// the preview differently for valid vs invalid drops.
  final bool? dropValid;

  /// Creates a new [MCalTimedEventTileContext] instance.
  const MCalTimedEventTileContext({
    required this.event,
    required this.displayDate,
    required this.columnIndex,
    required this.totalColumns,
    required this.startTime,
    required this.endTime,
    this.isStartOnDisplayDate = true,
    this.isEndOnDisplayDate = true,
    this.isDropTargetPreview,
    this.dropValid,
  });
}

/// Context object for all-day event tile builder callbacks in Day View.
///
/// Provides all necessary data for customizing the rendering of all-day
/// event tiles in the all-day section at the top of the day view.
///
/// This context is provided to [MCalDayView.allDayEventTileBuilder] when
/// building each all-day event tile. It's also used when building drop target
/// preview tiles during drag operations (when [isDropTargetPreview] is true).
///
/// Example:
/// ```dart
/// allDayEventTileBuilder: (context, ctx, defaultTile) {
///   if (ctx.isDropTargetPreview == true) {
///     return Container(
///       decoration: BoxDecoration(
///         color: ctx.dropValid == true
///             ? Colors.green.withOpacity(0.3)
///             : Colors.red.withOpacity(0.3),
///         borderRadius: BorderRadius.circular(4),
///       ),
///       child: defaultTile,
///     );
///   }
///
///   return Chip(
///     label: Text(ctx.event.title),
///     backgroundColor: ctx.event.color,
///   );
/// }
/// ```
class MCalAllDayEventTileContext {
  /// The calendar event being displayed.
  final MCalCalendarEvent event;

  /// The date being displayed in the day view.
  ///
  /// For multi-day all-day events, this may differ from [event.start].
  final DateTime displayDate;

  /// True when this context is used to build a drop target preview tile.
  ///
  /// During drag operations, a preview tile is shown in the all-day section
  /// when an event is being dragged to become an all-day event. This flag
  /// is null or false for normal all-day event tiles.
  final bool? isDropTargetPreview;

  /// True when the proposed drop is valid; false when invalid.
  ///
  /// Only set when [isDropTargetPreview] is true. Use this to style
  /// the preview differently for valid vs invalid drops.
  final bool? dropValid;

  /// Creates a new [MCalAllDayEventTileContext] instance.
  const MCalAllDayEventTileContext({
    required this.event,
    required this.displayDate,
    this.isDropTargetPreview,
    this.dropValid,
  });
}

/// Context object for current time indicator builder callbacks in Day View.
///
/// Provides all necessary data for customizing the rendering of the current
/// time indicator (horizontal line with optional dot at the leading edge).
///
/// This context is provided to [MCalDayView.currentTimeIndicatorBuilder]
/// when building the current time indicator.
///
/// Example:
/// ```dart
/// currentTimeIndicatorBuilder: (context, ctx) {
///   return Row(
///     children: [
///       Container(
///         width: 8,
///         height: 8,
///         decoration: BoxDecoration(
///           color: Colors.red,
///           shape: BoxShape.circle,
///         ),
///       ),
///       Expanded(
///         child: Container(
///           height: 2,
///           color: Colors.red,
///         ),
///       ),
///     ],
///   );
/// }
/// ```
class MCalCurrentTimeContext {
  /// The current time being indicated.
  final DateTime currentTime;

  /// Vertical offset in pixels from the top of the time range.
  ///
  /// This is the pixel position where the indicator line should be rendered.
  final double offset;

  /// Creates a new [MCalCurrentTimeContext] instance.
  const MCalCurrentTimeContext({
    required this.currentTime,
    required this.offset,
  });
}

/// Context object for time slot tap/long-press callbacks in Day View.
///
/// Provides all necessary data about the time slot that was tapped or
/// long-pressed, enabling event creation gestures on empty time areas.
///
/// This context is provided to [MCalDayView.onTimeSlotTap] and
/// [MCalDayView.onTimeSlotLongPress] callbacks when an empty time slot
/// is interacted with.
///
/// Example:
/// ```dart
/// onTimeSlotTap: (ctx) {
///   if (ctx.isAllDayArea) {
///     // Create an all-day event
///     createEvent(
///       start: DateTime(ctx.displayDate.year, ctx.displayDate.month, ctx.displayDate.day),
///       isAllDay: true,
///     );
///   } else {
///     // Create a timed event at the tapped time
///     final eventTime = DateTime(
///       ctx.displayDate.year,
///       ctx.displayDate.month,
///       ctx.displayDate.day,
///       ctx.hour!,
///       ctx.minute!,
///     );
///     createEvent(start: eventTime, duration: Duration(hours: 1));
///   }
/// }
/// ```
class MCalTimeSlotContext {
  /// The date being displayed in the day view.
  final DateTime displayDate;

  /// The hour of the tapped time slot (0-23).
  ///
  /// This is null when [isAllDayArea] is true.
  final int? hour;

  /// The minute of the tapped time slot (0-59).
  ///
  /// This is null when [isAllDayArea] is true.
  final int? minute;

  /// Vertical offset in pixels from the top of the time range.
  ///
  /// This is the pixel position that was tapped. It's 0.0 when
  /// [isAllDayArea] is true.
  final double offset;

  /// True if the tap occurred in the all-day event section at the top.
  ///
  /// When true, [hour] and [minute] are null and [offset] is 0.0.
  final bool isAllDayArea;

  /// Creates a new [MCalTimeSlotContext] instance.
  const MCalTimeSlotContext({
    required this.displayDate,
    required this.hour,
    required this.minute,
    required this.offset,
    required this.isAllDayArea,
  });
}

/// Context object for time region builder callbacks in Day View.
///
/// Provides all necessary data for customizing the rendering of special
/// time regions (e.g., lunch breaks, non-working hours, blocked time slots).
///
/// This context is provided to [MCalDayView.timeRegionBuilder] when building
/// each visible time region in the day view.
///
/// Example:
/// ```dart
/// timeRegionBuilder: (context, ctx) {
///   return Container(
///     decoration: BoxDecoration(
///       color: ctx.isBlocked
///           ? Colors.red.withOpacity(0.1)
///           : Colors.grey.withOpacity(0.05),
///       border: Border.all(
///         color: ctx.isBlocked ? Colors.red : Colors.grey,
///         width: 1,
///       ),
///     ),
///     child: ctx.region.text != null
///         ? Center(
///             child: Text(
///               ctx.region.text!,
///               style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
///             ),
///           )
///         : null,
///   );
/// }
/// ```
class MCalTimeRegionContext {
  /// The time region being rendered.
  final MCalTimeRegion region;

  /// The date this region is being rendered for.
  ///
  /// For recurring regions, this is the specific date occurrence.
  final DateTime displayDate;

  /// Vertical offset in pixels from the top of the time range.
  ///
  /// This is the pixel position where this region should be rendered.
  final double startOffset;

  /// Height in pixels for this region.
  ///
  /// This is the vertical extent of the region on the display.
  final double height;

  /// Creates a new [MCalTimeRegionContext] instance.
  const MCalTimeRegionContext({
    required this.region,
    required this.displayDate,
    required this.startOffset,
    required this.height,
  });

  /// Whether this region blocks user interaction.
  ///
  /// When true, drag-and-drop operations should be prevented in this region.
  bool get isBlocked => region.blockInteraction;

  /// Start time for this region occurrence on [displayDate].
  DateTime get startTime => region.startTime;

  /// End time for this region occurrence on [displayDate].
  DateTime get endTime => region.endTime;
}

/// Context object for custom day layout builder callbacks in Day View.
///
/// Provides all necessary data for implementing a completely custom layout
/// algorithm for timed events, bypassing the default overlap detection and
/// column-based layout.
///
/// This context is provided to [MCalDayView.dayLayoutBuilder] when building
/// the entire timed events layer. Use this for advanced layout scenarios
/// like calendar-style stacking, custom overlap patterns, or alternative
/// visual representations.
///
/// Example:
/// ```dart
/// dayLayoutBuilder: (context, ctx) {
///   // Custom vertical stacking layout
///   return Stack(
///     children: [
///       for (int i = 0; i < ctx.events.length; i++)
///         Positioned(
///           top: _calculateTop(ctx.events[i], ctx),
///           left: i * 10.0, // Cascade effect
///           right: 10,
///           height: _calculateHeight(ctx.events[i], ctx),
///           child: _buildEventTile(ctx.events[i]),
///         ),
///     ],
///   );
/// }
/// ```
class MCalDayLayoutContext {
  /// All timed events to be laid out for [displayDate].
  final List<MCalCalendarEvent> events;

  /// The date being displayed in the day view.
  final DateTime displayDate;

  /// The starting hour for the visible time range (0-23).
  final int startHour;

  /// The ending hour for the visible time range (0-23).
  final int endHour;

  /// The height in pixels allocated for each hour.
  ///
  /// Use this to calculate vertical positions: `offset = hour * hourHeight`.
  final double hourHeight;

  /// The width in pixels of the timed events area.
  ///
  /// Use this to calculate horizontal positions and event tile widths.
  final double areaWidth;

  /// Creates a new [MCalDayLayoutContext] instance.
  const MCalDayLayoutContext({
    required this.events,
    required this.displayDate,
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    required this.areaWidth,
  });
}
