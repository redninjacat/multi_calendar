import '../models/mcal_calendar_event.dart';
import '../utils/date_utils.dart';
import 'mcal_week_layout_contexts.dart';

/// Represents one segment of a multi-day event within a single week row.
///
/// Multi-day events may span multiple weeks in a month view. Each week row
/// that contains part of the event will have its own [MCalMultiDayRowSegment].
///
/// Example: An event spanning from Wednesday to Tuesday of the following week
/// would have two segments:
/// - First segment: Wednesday (day 3) to Saturday (day 6)
/// - Second segment: Sunday (day 0) to Tuesday (day 2)
class MCalMultiDayRowSegment {
  /// The week row index within the month grid (0-based).
  ///
  /// Week row 0 is the first week displayed in the month view,
  /// which may include days from the previous month.
  final int weekRowIndex;

  /// The starting day index within this week row (0-6).
  ///
  /// The value depends on [firstDayOfWeek]:
  /// - If Sunday is first: 0 = Sunday, 1 = Monday, ..., 6 = Saturday
  /// - If Monday is first: 0 = Monday, 1 = Tuesday, ..., 6 = Sunday
  final int startDayInRow;

  /// The ending day index within this week row (0-6), inclusive.
  ///
  /// The value uses the same convention as [startDayInRow].
  final int endDayInRow;

  /// Whether this is the first segment of the multi-day event.
  ///
  /// True for the segment that contains the event's start date.
  /// Used for rendering decisions like showing event title, left border radius.
  final bool isFirstSegment;

  /// Whether this is the last segment of the multi-day event.
  ///
  /// True for the segment that contains the event's end date.
  /// Used for rendering decisions like right border radius.
  final bool isLastSegment;

  /// Creates a new [MCalMultiDayRowSegment].
  const MCalMultiDayRowSegment({
    required this.weekRowIndex,
    required this.startDayInRow,
    required this.endDayInRow,
    required this.isFirstSegment,
    required this.isLastSegment,
  });

  /// The number of days this segment spans (1 to 7).
  int get spanDays => endDayInRow - startDayInRow + 1;

  @override
  String toString() {
    return 'MCalMultiDayRowSegment('
        'weekRowIndex: $weekRowIndex, '
        'startDayInRow: $startDayInRow, '
        'endDayInRow: $endDayInRow, '
        'isFirstSegment: $isFirstSegment, '
        'isLastSegment: $isLastSegment)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MCalMultiDayRowSegment &&
        other.weekRowIndex == weekRowIndex &&
        other.startDayInRow == startDayInRow &&
        other.endDayInRow == endDayInRow &&
        other.isFirstSegment == isFirstSegment &&
        other.isLastSegment == isLastSegment;
  }

  @override
  int get hashCode {
    return Object.hash(
      weekRowIndex,
      startDayInRow,
      endDayInRow,
      isFirstSegment,
      isLastSegment,
    );
  }
}

/// Layout information for one multi-day event in the month view.
///
/// Contains the event and all its row segments, representing how the event
/// should be laid out across week rows in the month grid.
class MCalMultiDayEventLayout {
  /// The calendar event this layout is for.
  final MCalCalendarEvent event;

  /// The list of row segments for this event.
  ///
  /// Each segment represents the portion of the event visible in one week row.
  /// Events spanning multiple weeks will have multiple segments.
  /// Segments are ordered by [MCalMultiDayRowSegment.weekRowIndex].
  final List<MCalMultiDayRowSegment> rowSegments;

  /// Creates a new [MCalMultiDayEventLayout].
  const MCalMultiDayEventLayout({
    required this.event,
    required this.rowSegments,
  });

  @override
  String toString() {
    return 'MCalMultiDayEventLayout(event: ${event.id}, segments: ${rowSegments.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MCalMultiDayEventLayout) return false;
    if (other.event != event) return false;
    if (other.rowSegments.length != rowSegments.length) return false;
    for (int i = 0; i < rowSegments.length; i++) {
      if (other.rowSegments[i] != rowSegments[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(event, Object.hashAll(rowSegments));
}

/// Represents a single event's position assignment within a week's layout grid.
///
/// Each assignment specifies which row the event occupies and which columns
/// (days) it spans within that row. This is the output of the greedy first-fit
/// row assignment algorithm.
class MCalEventLayoutAssignment {
  /// The event being positioned.
  final MCalCalendarEvent event;

  /// The segment of this event within the week.
  final MCalMultiDayRowSegment segment;

  /// The row index this event is assigned to (0-based).
  ///
  /// Row 0 is the topmost row in the week's multi-day event area.
  final int row;

  /// The starting column (day) index within the week (0-6).
  final int startColumn;

  /// The ending column (day) index within the week (0-6), inclusive.
  final int endColumn;

  /// Creates a new [MCalEventLayoutAssignment].
  const MCalEventLayoutAssignment({
    required this.event,
    required this.segment,
    required this.row,
    required this.startColumn,
    required this.endColumn,
  });

  /// The number of columns (days) this assignment spans.
  int get columnSpan => endColumn - startColumn + 1;

  @override
  String toString() {
    return 'MCalEventLayoutAssignment('
        'event: ${event.id}, '
        'row: $row, '
        'columns: $startColumn-$endColumn)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MCalEventLayoutAssignment &&
        other.event == event &&
        other.segment == segment &&
        other.row == row &&
        other.startColumn == startColumn &&
        other.endColumn == endColumn;
  }

  @override
  int get hashCode => Object.hash(event, segment, row, startColumn, endColumn);
}

/// Layout frame for a single week row containing positioned multi-day events.
///
/// This is the result of running the greedy first-fit algorithm on all
/// multi-day events that overlap with a specific week. It contains:
/// - All event position assignments
/// - The total number of rows needed
/// - Per-column (day) row occupancy information for single-day event offsetting
class MCalWeekEventLayoutFrame {
  /// The index of this week row within the month grid (0-based).
  final int weekRowIndex;

  /// The dates for each day in this week (always 7 elements).
  final List<DateTime> weekDates;

  /// All event layout assignments for this week, sorted by row then column.
  final List<MCalEventLayoutAssignment> assignments;

  /// The total number of rows needed to display all events.
  ///
  /// This is `max(assignment.row) + 1` for all assignments, or 0 if empty.
  final int totalRows;

  /// The highest row index used at each column (day) index.
  ///
  /// Map from column index (0-6) to the highest row index used at that column.
  /// If a column has no events, it won't be in this map.
  /// Used by day cells to know how many rows to offset single-day events by.
  final Map<int, int> columnMaxRows;

  /// Creates a new [MCalWeekEventLayoutFrame].
  const MCalWeekEventLayoutFrame({
    required this.weekRowIndex,
    required this.weekDates,
    required this.assignments,
    required this.totalRows,
    required this.columnMaxRows,
  });

  /// Returns an empty layout frame for a week with no multi-day events.
  factory MCalWeekEventLayoutFrame.empty({
    required int weekRowIndex,
    required List<DateTime> weekDates,
  }) {
    return MCalWeekEventLayoutFrame(
      weekRowIndex: weekRowIndex,
      weekDates: weekDates,
      assignments: const [],
      totalRows: 0,
      columnMaxRows: const {},
    );
  }

  /// Gets the maximum row index used at the given column (day) index.
  ///
  /// Returns -1 if no events occupy that column, meaning single-day events
  /// can start at row 0.
  int maxRowAtColumn(int column) => columnMaxRows[column] ?? -1;

  /// Gets the number of rows occupied at the given column (day) index.
  ///
  /// Returns 0 if no events occupy that column.
  int rowCountAtColumn(int column) {
    final maxRow = columnMaxRows[column];
    return maxRow != null ? maxRow + 1 : 0;
  }

  @override
  String toString() {
    return 'MCalWeekEventLayoutFrame('
        'weekRowIndex: $weekRowIndex, '
        'assignments: ${assignments.length}, '
        'totalRows: $totalRows)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MCalWeekEventLayoutFrame) return false;
    if (other.weekRowIndex != weekRowIndex) return false;
    if (other.totalRows != totalRows) return false;
    if (other.assignments.length != assignments.length) return false;
    for (int i = 0; i < assignments.length; i++) {
      if (other.assignments[i] != assignments[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        weekRowIndex,
        totalRows,
        Object.hashAll(assignments),
      );
}

/// Static utility class for calculating multi-day event layouts.
///
/// Provides methods to determine if an event spans multiple days and to
/// calculate the row segments needed to render multi-day events correctly
/// across week rows in the month view.
///
/// Example:
/// ```dart
/// final events = [event1, event2, event3];
/// final layouts = MCalMultiDayRenderer.calculateLayouts(
///   events: events,
///   monthStart: DateTime(2024, 2, 1),
///   firstDayOfWeek: 0, // Sunday
/// );
/// ```
class MCalMultiDayRenderer {
  // Private constructor to prevent instantiation
  MCalMultiDayRenderer._();

  /// Returns true if the event spans multiple calendar days.
  ///
  /// An event is considered multi-day if its start and end dates fall on
  /// different calendar days (ignoring time components).
  ///
  /// Note: All-day events that start and end on the same day are NOT
  /// considered multi-day by this method.
  static bool isMultiDay(MCalCalendarEvent event) {
    // Normalize to start of day for comparison
    final startDay = DateTime(event.start.year, event.start.month, event.start.day);
    final endDay = DateTime(event.end.year, event.end.month, event.end.day);
    return startDay.isBefore(endDay);
  }

  /// Comparator for sorting events in month view rendering order.
  ///
  /// Sort order (highest priority first):
  /// 1. All-day multi-day events
  /// 2. Timed multi-day events
  /// 3. All-day single-day events
  /// 4. Timed single-day events
  ///
  /// Within each category, events are sorted by:
  /// - Start time (earliest first)
  /// - Event duration (longest first, for tie-breaking)
  /// - Event ID (for stable sorting)
  static int multiDayEventComparator(MCalCalendarEvent a, MCalCalendarEvent b) {
    // Determine categories for each event
    final aIsMultiDay = isMultiDay(a);
    final bIsMultiDay = isMultiDay(b);

    // Calculate priority: lower number = higher priority
    int getPriority(MCalCalendarEvent event, bool isMulti) {
      if (isMulti && event.isAllDay) return 0; // All-day multi-day
      if (isMulti) return 1; // Timed multi-day
      if (event.isAllDay) return 2; // All-day single-day
      return 3; // Timed single-day
    }

    final aPriority = getPriority(a, aIsMultiDay);
    final bPriority = getPriority(b, bIsMultiDay);

    // Compare by priority first
    if (aPriority != bPriority) {
      return aPriority.compareTo(bPriority);
    }

    // Same priority, compare by start time
    final startComparison = a.start.compareTo(b.start);
    if (startComparison != 0) {
      return startComparison;
    }

    // Same start time, prefer longer events (for visual stability)
    final aDuration = a.end.difference(a.start);
    final bDuration = b.end.difference(b.start);
    final durationComparison = bDuration.compareTo(aDuration); // Longer first
    if (durationComparison != 0) {
      return durationComparison;
    }

    // Stable sort by ID
    return a.id.compareTo(b.id);
  }

  /// Calculates layout information for all multi-day events in the given month.
  ///
  /// Returns a list of [MCalMultiDayEventLayout] objects, one for each
  /// multi-day event that overlaps with the visible month grid.
  ///
  /// Parameters:
  /// - [events]: The list of all events to process
  /// - [monthStart]: The first day of the month being displayed
  /// - [firstDayOfWeek]: Which day starts the week (0 = Sunday, 1 = Monday, etc.)
  ///
  /// The method:
  /// 1. Filters to only multi-day events
  /// 2. Sorts using [multiDayEventComparator]
  /// 3. Calculates which week rows each event spans
  /// 4. Creates segments for each week row
  /// 5. Handles events that start before or end after the visible month grid
  static List<MCalMultiDayEventLayout> calculateLayouts({
    required List<MCalCalendarEvent> events,
    required DateTime monthStart,
    required int firstDayOfWeek,
  }) {
    // Generate the month grid dates
    final monthDates = generateMonthDates(monthStart, firstDayOfWeek);
    if (monthDates.isEmpty) return [];

    final gridStart = monthDates.first;
    final gridEnd = monthDates.last;

    // Filter to multi-day events only
    final multiDayEvents = events.where(isMultiDay).toList();

    // Sort events
    multiDayEvents.sort(multiDayEventComparator);

    final layouts = <MCalMultiDayEventLayout>[];

    for (final event in multiDayEvents) {
      // Normalize event dates to start of day
      final eventStartDay = DateTime(event.start.year, event.start.month, event.start.day);
      final eventEndDay = DateTime(event.end.year, event.end.month, event.end.day);

      // Check if event overlaps with the visible grid
      if (eventEndDay.isBefore(gridStart) ||
          eventStartDay.isAfter(gridEnd)) {
        continue; // Event is completely outside the visible grid
      }

      // Clamp event to visible grid
      final visibleStart = eventStartDay.isBefore(gridStart) ? gridStart : eventStartDay;
      final visibleEnd = eventEndDay.isAfter(gridEnd) ? gridEnd : eventEndDay;

      // Calculate segments
      final segments = <MCalMultiDayRowSegment>[];

      // Find the grid index for the visible start
      int startGridIndex = _daysBetween(gridStart, visibleStart);
      int endGridIndex = _daysBetween(gridStart, visibleEnd);

      // Iterate through week rows
      int currentGridIndex = startGridIndex;

      while (currentGridIndex <= endGridIndex) {
        final weekRowIndex = currentGridIndex ~/ 7;
        final dayInRow = currentGridIndex % 7;

        // Calculate end day in this row
        final weekRowEnd = (weekRowIndex + 1) * 7 - 1;
        final segmentEndGridIndex = endGridIndex < weekRowEnd ? endGridIndex : weekRowEnd;
        final endDayInRow = segmentEndGridIndex % 7;

        // Determine if this is first/last segment
        final isFirstSegment = currentGridIndex == startGridIndex && visibleStart == eventStartDay;
        final isLastSegment = segmentEndGridIndex == endGridIndex && visibleEnd == eventEndDay;

        segments.add(MCalMultiDayRowSegment(
          weekRowIndex: weekRowIndex,
          startDayInRow: dayInRow,
          endDayInRow: endDayInRow,
          isFirstSegment: isFirstSegment,
          isLastSegment: isLastSegment,
        ));

        // Move to next week row
        currentGridIndex = (weekRowIndex + 1) * 7;
      }

      if (segments.isNotEmpty) {
        layouts.add(MCalMultiDayEventLayout(
          event: event,
          rowSegments: segments,
        ));
      }
    }

    return layouts;
  }

  /// Calculates a week layout frame with greedy first-fit row assignment.
  ///
  /// This implements the core algorithm for positioning multi-day events
  /// within a single week row. Events are assigned to rows using a greedy
  /// first-fit algorithm:
  ///
  /// 1. Events are sorted by priority (multi-day > single-day, longer > shorter)
  /// 2. For each event segment in this week:
  ///    - Find the columns (days 0-6) this segment spans
  ///    - Find the first row where no existing segment overlaps those columns
  ///    - Assign the segment to that row
  ///    - Mark those columns as occupied in that row
  ///
  /// Parameters:
  /// - [multiDayLayouts]: Pre-computed multi-day layouts from [calculateLayouts]
  /// - [weekDates]: The 7 dates for this week row
  /// - [weekRowIndex]: The index of this week row within the month grid
  ///
  /// Returns a [MCalWeekEventLayoutFrame] containing all assignments and
  /// occupancy information for this week.
  static MCalWeekEventLayoutFrame calculateWeekLayout({
    required List<MCalMultiDayEventLayout> multiDayLayouts,
    required List<DateTime> weekDates,
    required int weekRowIndex,
  }) {
    // Collect all segments for this week row
    final segmentsForWeek = <_SegmentWithEvent>[];

    for (final layout in multiDayLayouts) {
      for (final segment in layout.rowSegments) {
        if (segment.weekRowIndex == weekRowIndex) {
          segmentsForWeek.add(_SegmentWithEvent(
            event: layout.event,
            segment: segment,
          ));
        }
      }
    }

    // If no segments, return empty frame
    if (segmentsForWeek.isEmpty) {
      return MCalWeekEventLayoutFrame.empty(
        weekRowIndex: weekRowIndex,
        weekDates: weekDates,
      );
    }

    // Segments are already sorted via multiDayLayouts (from calculateLayouts)
    // which sorts by multiDayEventComparator

    // Track which rows are occupied at each column
    // rowOccupancy[column] = Set of row indices that are occupied at that column
    final rowOccupancy = List<Set<int>>.generate(7, (_) => <int>{});

    final assignments = <MCalEventLayoutAssignment>[];
    int maxRowUsed = -1;

    for (final item in segmentsForWeek) {
      final segment = item.segment;
      final startCol = segment.startDayInRow;
      final endCol = segment.endDayInRow;

      // Find the first row where all columns in range are free
      int assignedRow = 0;
      while (true) {
        bool rowIsFree = true;
        for (int col = startCol; col <= endCol; col++) {
          if (rowOccupancy[col].contains(assignedRow)) {
            rowIsFree = false;
            break;
          }
        }
        if (rowIsFree) break;
        assignedRow++;
      }

      // Mark the columns as occupied in this row
      for (int col = startCol; col <= endCol; col++) {
        rowOccupancy[col].add(assignedRow);
      }

      // Track max row used
      if (assignedRow > maxRowUsed) {
        maxRowUsed = assignedRow;
      }

      // Create the assignment
      assignments.add(MCalEventLayoutAssignment(
        event: item.event,
        segment: segment,
        row: assignedRow,
        startColumn: startCol,
        endColumn: endCol,
      ));
    }

    // Build columnMaxRows map
    final columnMaxRows = <int, int>{};
    for (int col = 0; col < 7; col++) {
      if (rowOccupancy[col].isNotEmpty) {
        columnMaxRows[col] = rowOccupancy[col].reduce((a, b) => a > b ? a : b);
      }
    }

    // Sort assignments by row then column for consistent rendering order
    assignments.sort((a, b) {
      final rowCompare = a.row.compareTo(b.row);
      if (rowCompare != 0) return rowCompare;
      return a.startColumn.compareTo(b.startColumn);
    });

    return MCalWeekEventLayoutFrame(
      weekRowIndex: weekRowIndex,
      weekDates: weekDates,
      assignments: assignments,
      totalRows: maxRowUsed + 1,
      columnMaxRows: columnMaxRows,
    );
  }

  /// Calculates event segments for ALL events (single-day and multi-day) in a month.
  ///
  /// Unlike [calculateLayouts] which only handles multi-day events, this method
  /// creates [MCalEventSegment] objects for every event, making it suitable for
  /// the unified layered architecture.
  ///
  /// Single-day events get a segment with spanDays=1 and both isFirstSegment
  /// and isLastSegment set to true.
  static List<List<MCalEventSegment>> calculateAllEventSegments({
    required List<MCalCalendarEvent> events,
    required DateTime monthStart,
    required int firstDayOfWeek,
  }) {
    // Generate the month grid dates
    final monthDates = generateMonthDates(monthStart, firstDayOfWeek);
    if (monthDates.isEmpty) return [];

    final gridStart = monthDates.first;
    final gridEnd = monthDates.last;
    final weekCount = (monthDates.length / 7).ceil();

    // Initialize per-week segment lists
    final weekSegments = List.generate(weekCount, (_) => <MCalEventSegment>[]);

    // Sort all events: multi-day first, then by start time, then by duration
    final sortedEvents = List<MCalCalendarEvent>.from(events)
      ..sort(multiDayEventComparator);

    for (final event in sortedEvents) {
      // Normalize event dates to start of day
      final eventStartDay = DateTime(event.start.year, event.start.month, event.start.day);
      final eventEndDay = DateTime(event.end.year, event.end.month, event.end.day);

      // Check if event overlaps with the visible grid
      if (eventEndDay.isBefore(gridStart) || eventStartDay.isAfter(gridEnd)) {
        continue;
      }

      // Clamp to visible grid
      final visibleStart = eventStartDay.isBefore(gridStart) ? gridStart : eventStartDay;
      final visibleEnd = eventEndDay.isAfter(gridEnd) ? gridEnd : eventEndDay;

      // Calculate grid indices
      final startGridIndex = _daysBetween(gridStart, visibleStart);
      final endGridIndex = _daysBetween(gridStart, visibleEnd);

      // Generate segments for each week this event spans
      int currentGridIndex = startGridIndex;

      while (currentGridIndex <= endGridIndex) {
        final weekRowIndex = currentGridIndex ~/ 7;
        final dayInRow = currentGridIndex % 7;

        // Calculate end day in this row
        final weekRowEnd = (weekRowIndex + 1) * 7 - 1;
        final segmentEndGridIndex = endGridIndex < weekRowEnd ? endGridIndex : weekRowEnd;
        final endDayInRow = segmentEndGridIndex % 7;

        // Determine if this is first/last segment
        final isFirstSegment = currentGridIndex == startGridIndex && visibleStart == eventStartDay;
        final isLastSegment = segmentEndGridIndex == endGridIndex && visibleEnd == eventEndDay;

        if (weekRowIndex < weekCount) {
          weekSegments[weekRowIndex].add(MCalEventSegment(
            event: event,
            weekRowIndex: weekRowIndex,
            startDayInWeek: dayInRow,
            endDayInWeek: endDayInRow,
            isFirstSegment: isFirstSegment,
            isLastSegment: isLastSegment,
          ));
        }

        // Move to next week row
        currentGridIndex = (weekRowIndex + 1) * 7;
      }
    }

    return weekSegments;
  }

  /// Calculates the number of days between two dates (ignoring time).
  static int _daysBetween(DateTime from, DateTime to) {
    final fromDay = DateTime(from.year, from.month, from.day);
    final toDay = DateTime(to.year, to.month, to.day);
    return toDay.difference(fromDay).inDays;
  }
}

/// Helper class to pair an event with its segment for layout calculation.
class _SegmentWithEvent {
  final MCalCalendarEvent event;
  final MCalMultiDayRowSegment segment;

  const _SegmentWithEvent({
    required this.event,
    required this.segment,
  });
}
