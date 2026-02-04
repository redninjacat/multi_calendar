import 'dart:math';
import 'package:flutter/material.dart';

/// A list of 10 popular colors for event tiles.
const List<Color> _eventColors = [
  Color(0xFF4285F4), // Google Blue
  Color(0xFF34A853), // Google Green
  Color(0xFFFBBC05), // Google Yellow
  Color(0xFFEA4335), // Google Red
  Color(0xFF9C27B0), // Purple
  Color(0xFF00BCD4), // Cyan
  Color(0xFFFF9800), // Orange
  Color(0xFF795548), // Brown
  Color(0xFF607D8B), // Blue Grey
  Color(0xFFE91E63), // Pink
];

/// Position options for the date label within a cell.
enum DateLabelPosition {
  topLeft,
  topCenter,
  topRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

/// Proof of concept for the new 2-layer Stack-based calendar layout.
///
/// This demonstrates:
/// - Layer 1: Calendar grid with day cells
/// - Layer 2: Event tiles using Stack layout with greedy first-fit row assignment
/// - Multi-week events that visually wrap across week rows
class LayoutPocStyle extends StatefulWidget {
  const LayoutPocStyle({super.key, required this.description});

  final String description;

  @override
  State<LayoutPocStyle> createState() => _LayoutPocStyleState();
}

class _LayoutPocStyleState extends State<LayoutPocStyle> {
  final Random _random = Random(42); // Fixed seed for reproducible colors

  // Sample event data - events use absolute day indices (0-27 for 4 weeks)
  late List<_PocEvent> _events;

  // ============================================================
  // Configurable Settings
  // ============================================================

  // Layer 1: Cell grid settings
  double _cellBorderWidth = 0.5;
  Color _cellBorderColor = Colors.grey;

  // Layer 2: Date label settings
  DateLabelPosition _dateLabelPosition = DateLabelPosition.topLeft;

  // Layer 2: Event tile settings
  double _tileVerticalSpacing = 2.0;
  double _tileHorizontalSpacing = 2.0;
  double _eventTileCornerRadius = 3.0;
  double _tileBorderWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _generateSampleEvents();
  }

  void _generateSampleEvents() {
    final events = <_PocEvent>[];
    int eventId = 1;

    // Generate events across all 4 weeks
    // Some events will span multiple weeks
    for (int i = 0; i < 15; i++) {
      final startDay = _random.nextInt(28); // 0-27 (4 weeks * 7 days)
      final maxSpan = 28 - startDay;
      // Allow spans up to 10 days to create multi-week events
      final maxAllowedSpan = min(maxSpan, 10);
      final span = 1 + _random.nextInt(maxAllowedSpan);
      final color = _eventColors[_random.nextInt(_eventColors.length)];

      events.add(
        _PocEvent(
          id: eventId++,
          startDayIndex: startDay,
          spanDays: span,
          color: color,
          title: 'Event $eventId',
        ),
      );
    }

    _events = events;
  }

  /// Splits events into per-week segments for rendering.
  List<List<_EventSegment>> _splitEventsIntoWeekSegments() {
    const int weekCount = 4;
    final weekSegments = List.generate(weekCount, (_) => <_EventSegment>[]);

    for (final event in _events) {
      final startWeek = event.startDayIndex ~/ 7;
      final endDayIndex = event.startDayIndex + event.spanDays - 1;
      final endWeek = endDayIndex ~/ 7;

      for (int week = startWeek; week <= endWeek && week < weekCount; week++) {
        // Calculate the segment's start and end within this week (0-6)
        final segmentStartInWeek = (week == startWeek)
            ? event.startDayIndex % 7
            : 0;
        final segmentEndInWeek = (week == endWeek) ? endDayIndex % 7 : 6;

        final isFirstSegment = (week == startWeek);
        final isLastSegment = (week == endWeek);

        weekSegments[week].add(
          _EventSegment(
            event: event,
            weekIndex: week,
            startDayInWeek: segmentStartInWeek,
            endDayInWeek: segmentEndInWeek,
            isFirstSegment: isFirstSegment,
            isLastSegment: isLastSegment,
          ),
        );
      }
    }

    return weekSegments;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final calendarHeight = screenHeight * 0.6;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            child: Text(
              widget.description,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
            ),
          ),
          // Controls Panel
          _buildControlsPanel(context),
          // The POC calendar with fixed height
          SizedBox(
            height: calendarHeight,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outline),
              ),
              child: _buildCalendarStack(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsPanel(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Regenerate button and Date Label Position
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _generateSampleEvents();
                  });
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Regenerate'),
              ),
              const SizedBox(width: 16),
              const Text('Date Label: ', style: TextStyle(fontSize: 12)),
              DropdownButton<DateLabelPosition>(
                value: _dateLabelPosition,
                isDense: true,
                items: DateLabelPosition.values.map((pos) {
                  return DropdownMenuItem(
                    value: pos,
                    child: Text(
                      pos.name.replaceAllMapped(
                        RegExp(r'([A-Z])'),
                        (m) => ' ${m.group(1)}',
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _dateLabelPosition = value);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: Cell Border Settings
          Row(
            children: [
              const Text('Cell Border: ', style: TextStyle(fontSize: 12)),
              SizedBox(
                width: 100,
                child: Slider(
                  value: _cellBorderWidth,
                  min: 0,
                  max: 3,
                  divisions: 6,
                  label: _cellBorderWidth.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() => _cellBorderWidth = value);
                  },
                ),
              ),
              Text(
                '${_cellBorderWidth.toStringAsFixed(1)}px',
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(width: 12),
              const Text('Color: ', style: TextStyle(fontSize: 12)),
              _buildColorChip(Colors.grey, _cellBorderColor == Colors.grey, () {
                setState(() => _cellBorderColor = Colors.grey);
              }),
              _buildColorChip(
                Colors.black,
                _cellBorderColor == Colors.black,
                () {
                  setState(() => _cellBorderColor = Colors.black);
                },
              ),
              _buildColorChip(Colors.blue, _cellBorderColor == Colors.blue, () {
                setState(() => _cellBorderColor = Colors.blue);
              }),
              _buildColorChip(
                Colors.transparent,
                _cellBorderColor == Colors.transparent,
                () {
                  setState(() => _cellBorderColor = Colors.transparent);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 3: Tile Spacing Settings
          Row(
            children: [
              const Text('V-Space: ', style: TextStyle(fontSize: 12)),
              SizedBox(
                width: 80,
                child: Slider(
                  value: _tileVerticalSpacing,
                  min: 0,
                  max: 8,
                  divisions: 8,
                  onChanged: (value) {
                    setState(() => _tileVerticalSpacing = value);
                  },
                ),
              ),
              Text(
                '${_tileVerticalSpacing.toStringAsFixed(0)}px',
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(width: 8),
              const Text('H-Space: ', style: TextStyle(fontSize: 12)),
              SizedBox(
                width: 80,
                child: Slider(
                  value: _tileHorizontalSpacing,
                  min: 0,
                  max: 8,
                  divisions: 8,
                  onChanged: (value) {
                    setState(() => _tileHorizontalSpacing = value);
                  },
                ),
              ),
              Text(
                '${_tileHorizontalSpacing.toStringAsFixed(0)}px',
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 4: Tile Border and Corner Settings
          Row(
            children: [
              const Text('Corner: ', style: TextStyle(fontSize: 12)),
              SizedBox(
                width: 80,
                child: Slider(
                  value: _eventTileCornerRadius,
                  min: 0,
                  max: 12,
                  divisions: 12,
                  onChanged: (value) {
                    setState(() => _eventTileCornerRadius = value);
                  },
                ),
              ),
              Text(
                '${_eventTileCornerRadius.toStringAsFixed(0)}px',
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(width: 8),
              const Text('Border: ', style: TextStyle(fontSize: 12)),
              SizedBox(
                width: 80,
                child: Slider(
                  value: _tileBorderWidth,
                  min: 0,
                  max: 3,
                  divisions: 6,
                  onChanged: (value) {
                    setState(() => _tileBorderWidth = value);
                  },
                ),
              ),
              Text(
                '${_tileBorderWidth.toStringAsFixed(1)}px',
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorChip(Color color, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 20,
        height: 20,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: selected ? Colors.blue : Colors.grey,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: color == Colors.transparent
            ? const Icon(Icons.close, size: 12, color: Colors.grey)
            : null,
      ),
    );
  }

  Widget _buildCalendarStack() {
    return Stack(
      children: [
        // Layer 1: Calendar grid (day cells)
        _buildLayer1Grid(),
        // Layer 2: Event tiles
        _buildLayer2Events(),
      ],
    );
  }

  /// Layer 1: Calendar grid with day cells (just the grid, no labels)
  Widget _buildLayer1Grid() {
    const int weekCount = 4;

    return Column(
      children: List.generate(weekCount, (weekIndex) {
        return Expanded(
          child: Row(
            children: List.generate(7, (dayIndex) {
              return Expanded(child: _buildDayCell());
            }),
          ),
        );
      }),
    );
  }

  Widget _buildDayCell() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _cellBorderColor.withValues(alpha: 0.3),
          width: _cellBorderWidth,
        ),
      ),
    );
  }

  /// Layer 2: Date labels and event tiles positioned using a Stack in each week row
  Widget _buildLayer2Events() {
    const int weekCount = 4;
    const double tileHeight = 18.0;
    const double dateLabelHeight = 18.0;
    const double dateLabelPadding = 2.0;
    const double overflowIndicatorHeight = 14.0;

    final bool dateLabelAtTop =
        _dateLabelPosition == DateLabelPosition.topLeft ||
        _dateLabelPosition == DateLabelPosition.topCenter ||
        _dateLabelPosition == DateLabelPosition.topRight;

    // When date label is at top, events start below it
    // When date label is at bottom, events start with vertical spacing from top
    final double eventsTopOffset = dateLabelAtTop
        ? dateLabelPadding + dateLabelHeight
        : _tileVerticalSpacing;

    // Split all events into per-week segments
    final weekSegments = _splitEventsIntoWeekSegments();

    return Column(
      children: List.generate(weekCount, (weekIndex) {
        final segments = weekSegments[weekIndex];

        // Sort segments: longer spans first, then by start day
        final sortedSegments = List<_EventSegment>.from(segments)
          ..sort((a, b) {
            final spanA = a.endDayInWeek - a.startDayInWeek + 1;
            final spanB = b.endDayInWeek - b.startDayInWeek + 1;
            final spanCompare = spanB.compareTo(spanA);
            if (spanCompare != 0) return spanCompare;
            return a.startDayInWeek.compareTo(b.startDayInWeek);
          });

        // Assign rows using greedy first-fit algorithm
        final assignments = _assignSegmentRows(sortedSegments);

        return Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final actualDayWidth = constraints.maxWidth / 7;
              final rowHeight = constraints.maxHeight;
              final colorScheme = Theme.of(context).colorScheme;

              final dateLabelReservedSpace = dateLabelPadding + dateLabelHeight;
              final availableHeightForEvents =
                  rowHeight -
                  dateLabelReservedSpace -
                  overflowIndicatorHeight -
                  2;
              final tileSlotHeight = tileHeight + _tileVerticalSpacing;
              final maxVisibleRows = (availableHeightForEvents / tileSlotHeight)
                  .floor()
                  .clamp(1, 100);

              // Separate visible and hidden assignments
              final visibleAssignments = <_SegmentRowAssignment>[];
              final hiddenAssignments = <_SegmentRowAssignment>[];

              for (final assignment in assignments) {
                if (assignment.row < maxVisibleRows) {
                  visibleAssignments.add(assignment);
                } else {
                  hiddenAssignments.add(assignment);
                }
              }

              // Count hidden events per day column
              final hiddenCountPerDay = List<int>.filled(7, 0);
              for (final assignment in hiddenAssignments) {
                final segment = assignment.segment;
                for (
                  int day = segment.startDayInWeek;
                  day <= segment.endDayInWeek;
                  day++
                ) {
                  hiddenCountPerDay[day]++;
                }
              }

              // Build date label widgets
              final dateLabels = List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex + 1;
                return _buildDateLabel(
                  dayNumber: dayNumber,
                  dayIndex: dayIndex,
                  dayWidth: actualDayWidth,
                  rowHeight: rowHeight,
                  dateLabelHeight: dateLabelHeight,
                  dateLabelPadding: dateLabelPadding,
                  colorScheme: colorScheme,
                );
              });

              // Build event tile widgets (only visible ones)
              final eventTiles = visibleAssignments.map((assignment) {
                final segment = assignment.segment;
                final row = assignment.row;

                // Determine spacing based on segment position
                final leftSpacing = segment.isFirstSegment
                    ? _tileHorizontalSpacing
                    : 0.0;
                final rightSpacing = segment.isLastSegment
                    ? _tileHorizontalSpacing
                    : 0.0;

                // Calculate position
                final left =
                    actualDayWidth * segment.startDayInWeek + leftSpacing;
                final top =
                    eventsTopOffset +
                    (row * (tileHeight + _tileVerticalSpacing));
                final spanDays =
                    segment.endDayInWeek - segment.startDayInWeek + 1;
                final tileWidth =
                    actualDayWidth * spanDays - leftSpacing - rightSpacing;

                return Positioned(
                  left: left,
                  top: top,
                  width: tileWidth,
                  height: tileHeight,
                  child: _buildEventTile(segment: segment),
                );
              }).toList();

              // Build "+N more" indicators for days with hidden events
              final overflowIndicators = <Widget>[];
              for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
                final hiddenCount = hiddenCountPerDay[dayIndex];
                if (hiddenCount > 0) {
                  final left = actualDayWidth * dayIndex + 4;
                  final double top;
                  if (dateLabelAtTop) {
                    top =
                        eventsTopOffset +
                        (maxVisibleRows * (tileHeight + _tileVerticalSpacing));
                  } else {
                    top = maxVisibleRows * (tileHeight + _tileVerticalSpacing);
                  }

                  overflowIndicators.add(
                    Positioned(
                      left: left,
                      top: top,
                      width: actualDayWidth - 8,
                      height: overflowIndicatorHeight,
                      child: Text(
                        '+$hiddenCount more',
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }
              }

              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [...dateLabels, ...eventTiles, ...overflowIndicators],
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildDateLabel({
    required int dayNumber,
    required int dayIndex,
    required double dayWidth,
    required double rowHeight,
    required double dateLabelHeight,
    required double dateLabelPadding,
    required ColorScheme colorScheme,
  }) {
    double left;
    Alignment textAlignment;

    switch (_dateLabelPosition) {
      case DateLabelPosition.topLeft:
      case DateLabelPosition.bottomLeft:
        left = dayWidth * dayIndex + 4;
        textAlignment = Alignment.centerLeft;
        break;
      case DateLabelPosition.topCenter:
      case DateLabelPosition.bottomCenter:
        left = dayWidth * dayIndex;
        textAlignment = Alignment.center;
        break;
      case DateLabelPosition.topRight:
      case DateLabelPosition.bottomRight:
        left = dayWidth * dayIndex;
        textAlignment = Alignment.centerRight;
        break;
    }

    double top;
    switch (_dateLabelPosition) {
      case DateLabelPosition.topLeft:
      case DateLabelPosition.topCenter:
      case DateLabelPosition.topRight:
        top = dateLabelPadding;
        break;
      case DateLabelPosition.bottomLeft:
      case DateLabelPosition.bottomCenter:
      case DateLabelPosition.bottomRight:
        top = rowHeight - dateLabelHeight - dateLabelPadding;
        break;
    }

    final width =
        (_dateLabelPosition == DateLabelPosition.topLeft ||
            _dateLabelPosition == DateLabelPosition.bottomLeft)
        ? null
        : dayWidth - 8;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: dateLabelHeight,
      child: Container(
        padding: width != null
            ? const EdgeInsets.symmetric(horizontal: 4)
            : EdgeInsets.zero,
        alignment: textAlignment,
        child: Text(
          '$dayNumber',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  /// Assigns row indices to segments using greedy first-fit algorithm.
  List<_SegmentRowAssignment> _assignSegmentRows(List<_EventSegment> segments) {
    final assignments = <_SegmentRowAssignment>[];
    final rowOccupancy = <int, Set<int>>{};

    for (final segment in segments) {
      int assignedRow = 0;
      while (true) {
        final occupiedCols = rowOccupancy[assignedRow] ?? <int>{};
        bool rowIsFree = true;
        for (
          int col = segment.startDayInWeek;
          col <= segment.endDayInWeek;
          col++
        ) {
          if (occupiedCols.contains(col)) {
            rowIsFree = false;
            break;
          }
        }
        if (rowIsFree) break;
        assignedRow++;
      }

      rowOccupancy[assignedRow] ??= <int>{};
      for (
        int col = segment.startDayInWeek;
        col <= segment.endDayInWeek;
        col++
      ) {
        rowOccupancy[assignedRow]!.add(col);
      }

      assignments.add(
        _SegmentRowAssignment(segment: segment, row: assignedRow),
      );
    }

    return assignments;
  }

  Widget _buildEventTile({required _EventSegment segment}) {
    // Determine corner radius based on segment position
    final leftRadius = segment.isFirstSegment
        ? Radius.circular(_eventTileCornerRadius)
        : Radius.zero;
    final rightRadius = segment.isLastSegment
        ? Radius.circular(_eventTileCornerRadius)
        : Radius.zero;

    // Determine border based on segment position
    Border? border;
    if (_tileBorderWidth > 0) {
      final borderSide = BorderSide(
        color: Colors.white.withValues(alpha: 0.5),
        width: _tileBorderWidth,
      );
      final noBorderSide = BorderSide.none;

      border = Border(
        top: borderSide,
        bottom: borderSide,
        left: segment.isFirstSegment ? borderSide : noBorderSide,
        right: segment.isLastSegment ? borderSide : noBorderSide,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: segment.event.color,
        borderRadius: BorderRadius.only(
          topLeft: leftRadius,
          bottomLeft: leftRadius,
          topRight: rightRadius,
          bottomRight: rightRadius,
        ),
        border: border,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.centerLeft,
      child: Text(
        segment.event.title,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Event data using absolute day indices (0-27 for 4 weeks).
class _PocEvent {
  final int id;
  final int startDayIndex; // 0-27 (absolute day in the 4-week grid)
  final int spanDays; // 1-28
  final Color color;
  final String title;

  const _PocEvent({
    required this.id,
    required this.startDayIndex,
    required this.spanDays,
    required this.color,
    required this.title,
  });

  int get endDayIndex => startDayIndex + spanDays - 1;
}

/// A segment of an event within a single week.
class _EventSegment {
  final _PocEvent event;
  final int weekIndex;
  final int startDayInWeek; // 0-6
  final int endDayInWeek; // 0-6
  final bool isFirstSegment; // Is this the first segment of the event?
  final bool isLastSegment; // Is this the last segment of the event?

  const _EventSegment({
    required this.event,
    required this.weekIndex,
    required this.startDayInWeek,
    required this.endDayInWeek,
    required this.isFirstSegment,
    required this.isLastSegment,
  });

  int get spanDays => endDayInWeek - startDayInWeek + 1;
}

/// Assignment of an event segment to a row index within a week.
class _SegmentRowAssignment {
  final _EventSegment segment;
  final int row;

  const _SegmentRowAssignment({required this.segment, required this.row});
}
