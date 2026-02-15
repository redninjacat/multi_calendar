import '../models/mcal_calendar_event.dart';

/// Represents an event with its assigned column information for layout.
///
/// This is used by the overlap detection algorithm to determine how events
/// should be positioned side-by-side when they overlap in time.
class DayViewEventWithColumn {
  /// The calendar event.
  final MCalCalendarEvent event;

  /// The column index for this event (0-based).
  ///
  /// Events in the same overlap group are laid out side-by-side,
  /// with each event occupying a column. Column 0 is the leftmost
  /// (or rightmost in RTL layouts).
  final int columnIndex;

  /// The total number of columns in the overlap group.
  ///
  /// This determines how wide each event should be. For example,
  /// if totalColumns is 3, each event occupies approximately 1/3
  /// of the available width.
  final int totalColumns;

  const DayViewEventWithColumn({
    required this.event,
    required this.columnIndex,
    required this.totalColumns,
  });
}

/// Detects overlapping events and assigns them to columns for side-by-side layout.
///
/// This function implements an efficient sweep-line algorithm to detect event
/// overlaps and assign optimal column positions. The algorithm runs in O(n log n)
/// time complexity, where n is the number of events.
///
/// ## Algorithm Overview
///
/// 1. **Sort events**: Events are sorted by start time, with longer events first
///    when start times are equal.
/// 2. **Detect overlaps**: Two events overlap if `A.start < B.end && B.start < A.end`.
/// 3. **Assign columns**: Events are assigned to the first available column that
///    doesn't conflict with already-placed events in the same overlap group.
/// 4. **Handle nested overlaps**: The algorithm correctly handles complex scenarios
///    like A overlapping B, B overlapping C, where A and C don't directly overlap.
///
/// ## Parameters
///
/// - [events]: List of timed events for the day. All-day events should be
///   filtered out before calling this function.
///
/// ## Returns
///
/// A list of [DayViewEventWithColumn] objects in the same order as the input events,
/// each containing the original event plus its column assignment (columnIndex
/// and totalColumns).
///
/// ## Complexity
///
/// - Time: O(n log n) due to sorting
/// - Space: O(n) for the result list and temporary data structures
///
/// ## Pure Function
///
/// This function is pure and has no side effects. It does not modify the input
/// events or any external state.
List<DayViewEventWithColumn> detectOverlapsAndAssignColumns(
  List<MCalCalendarEvent> events,
) {
  // Handle empty list
  if (events.isEmpty) {
    return [];
  }

  // Handle single event
  if (events.length == 1) {
    return [
      DayViewEventWithColumn(event: events[0], columnIndex: 0, totalColumns: 1),
    ];
  }

  // Sort events by start time, with longer events first when times are equal
  final sortedEvents = List<MCalCalendarEvent>.from(events)
    ..sort((a, b) {
      final timeCompare = a.start.compareTo(b.start);
      if (timeCompare != 0) return timeCompare;
      // Longer events first (improves visual layout)
      final aDuration = a.end.difference(a.start);
      final bDuration = b.end.difference(b.start);
      return bDuration.compareTo(aDuration);
    });

  // Map to track original event to result index
  final eventToIndex = <MCalCalendarEvent, int>{};
  for (int i = 0; i < events.length; i++) {
    eventToIndex[events[i]] = i;
  }

  // Result list (in original order)
  final result = List<DayViewEventWithColumn?>.filled(events.length, null);

  // Process events in overlap groups
  int i = 0;
  while (i < sortedEvents.length) {
    // Find all events in this overlap group
    final overlapGroup = <MCalCalendarEvent>[sortedEvents[i]];
    DateTime groupEnd = sortedEvents[i].end;

    // Extend group while events overlap
    for (int j = i + 1; j < sortedEvents.length; j++) {
      final event = sortedEvents[j];

      // Check if this event overlaps with any event in the current group
      if (event.start.isBefore(groupEnd)) {
        overlapGroup.add(event);
        // Extend group end if this event ends later
        if (event.end.isAfter(groupEnd)) {
          groupEnd = event.end;
        }
      } else {
        // No more overlaps, this event starts a new group
        break;
      }
    }

    // Assign columns to events in this group
    final totalColumns = _assignColumnsToGroup(overlapGroup);

    // Store results in original order
    for (int j = 0; j < overlapGroup.length; j++) {
      final event = overlapGroup[j];
      final originalIndex = eventToIndex[event]!;
      result[originalIndex] = DayViewEventWithColumn(
        event: event,
        columnIndex: _getColumnIndex(event, overlapGroup),
        totalColumns: totalColumns,
      );
    }

    // Move to next group
    i += overlapGroup.length;
  }

  // Return non-null results (all should be assigned by now)
  return result.cast<DayViewEventWithColumn>();
}

/// Assigns columns to events within an overlap group and returns the total column count.
///
/// Uses a greedy algorithm: each event is placed in the first available column
/// that doesn't conflict with already-placed events.
int _assignColumnsToGroup(List<MCalCalendarEvent> groupEvents) {
  if (groupEvents.isEmpty) return 0;
  if (groupEvents.length == 1) return 1;

  // Track which events are assigned to which columns
  final columns = <List<MCalCalendarEvent>>[];

  for (final event in groupEvents) {
    // Find the first column where this event fits (no overlap)
    int assignedColumn = -1;

    for (int col = 0; col < columns.length; col++) {
      final columnEvents = columns[col];

      // Check if event overlaps with any event in this column
      bool hasOverlap = false;
      for (final colEvent in columnEvents) {
        if (_eventsOverlap(event, colEvent)) {
          hasOverlap = true;
          break;
        }
      }

      if (!hasOverlap) {
        assignedColumn = col;
        columnEvents.add(event);
        break;
      }
    }

    // If no column fits, create a new one
    if (assignedColumn == -1) {
      columns.add([event]);
    }
  }

  return columns.length;
}

/// Returns the column index for an event within its overlap group.
int _getColumnIndex(
  MCalCalendarEvent event,
  List<MCalCalendarEvent> groupEvents,
) {
  // Rebuild column assignment to find this event's column
  final columns = <List<MCalCalendarEvent>>[];

  for (final e in groupEvents) {
    // Find the first column where this event fits
    int assignedColumn = -1;

    for (int col = 0; col < columns.length; col++) {
      final columnEvents = columns[col];

      bool hasOverlap = false;
      for (final colEvent in columnEvents) {
        if (_eventsOverlap(e, colEvent)) {
          hasOverlap = true;
          break;
        }
      }

      if (!hasOverlap) {
        assignedColumn = col;
        columnEvents.add(e);
        break;
      }
    }

    if (assignedColumn == -1) {
      assignedColumn = columns.length;
      columns.add([e]);
    }

    // If this is the event we're looking for, return its column
    if (e == event) {
      return assignedColumn;
    }
  }

  // Should never reach here
  return 0;
}

/// Checks if two events overlap in time.
///
/// Two events overlap if: A.start < B.end && B.start < A.end
///
/// This is a standard interval overlap check that handles all cases:
/// - A contains B
/// - B contains A
/// - A and B partially overlap
/// - A and B are adjacent (touching) - these do NOT overlap
bool _eventsOverlap(MCalCalendarEvent a, MCalCalendarEvent b) {
  return a.start.isBefore(b.end) && b.start.isBefore(a.end);
}
