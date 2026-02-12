import 'package:flutter/material.dart' show DateTimeRange;

/// The type of change that occurred to calendar events.
///
/// Used by [MCalEventChangeInfo] to describe what kind of mutation
/// happened, enabling targeted view rebuilds.
enum MCalChangeType {
  /// A new event was added.
  eventAdded,

  /// An existing event was updated.
  eventUpdated,

  /// An event was removed.
  eventRemoved,

  /// A recurrence exception was added (e.g., deleted, rescheduled, or modified occurrence).
  exceptionAdded,

  /// A recurrence exception was removed, restoring the original occurrence.
  exceptionRemoved,

  /// A recurring series was split into two series at a given date.
  seriesSplit,

  /// Multiple changes occurred at once (e.g., batch load of events or exceptions).
  bulkChange,
}

/// Metadata describing a change to calendar events.
///
/// Produced by mutation methods on the event controller to enable
/// targeted view rebuilds. Consumers can inspect [type] to determine
/// what changed, [affectedEventIds] to know which events were involved,
/// and [affectedDateRange] to know which dates may need re-rendering.
///
/// Example:
/// ```dart
/// final changeInfo = MCalEventChangeInfo(
///   type: MCalChangeType.eventAdded,
///   affectedEventIds: {'event-1'},
///   affectedDateRange: DateTimeRange(
///     start: DateTime(2024, 1, 15),
///     end: DateTime(2024, 1, 15),
///   ),
/// );
/// ```
class MCalEventChangeInfo {
  /// The type of change that occurred.
  final MCalChangeType type;

  /// The IDs of events affected by this change.
  final Set<String> affectedEventIds;

  /// The date range affected by this change, if applicable.
  ///
  /// May be null for bulk changes or when the affected range
  /// cannot be determined.
  final DateTimeRange? affectedDateRange;

  /// Creates a new [MCalEventChangeInfo] instance.
  ///
  /// The [type] and [affectedEventIds] parameters are required.
  /// The [affectedDateRange] is optional.
  const MCalEventChangeInfo({
    required this.type,
    required this.affectedEventIds,
    this.affectedDateRange,
  });

  @override
  String toString() {
    return 'MCalEventChangeInfo(type: $type, affectedEventIds: $affectedEventIds, '
        'affectedDateRange: $affectedDateRange)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MCalEventChangeInfo) return false;
    if (other.type != type) return false;
    if (other.affectedDateRange != affectedDateRange) return false;
    if (other.affectedEventIds.length != affectedEventIds.length) return false;
    return other.affectedEventIds.containsAll(affectedEventIds);
  }

  @override
  int get hashCode {
    return Object.hash(
      type,
      Object.hashAllUnordered(affectedEventIds),
      affectedDateRange,
    );
  }
}
