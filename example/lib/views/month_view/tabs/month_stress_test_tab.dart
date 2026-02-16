import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/utils/sample_events.dart';
import '../../../shared/utils/stress_test_events.dart';
import '../../../shared/widgets/day_events_bottom_sheet.dart';
import '../../../shared/widgets/event_detail_dialog.dart';
import '../../../shared/widgets/responsive_control_panel.dart';

/// Stress test event count options.
const List<int> _stressTestCounts = [100, 200, 300, 500];

/// Month View stress test tab - demonstrates performance with 100-500 events.
///
/// Features:
/// - Toggle to enable/disable stress test mode
/// - Event count selector (100, 200, 300, 500)
/// - Performance metrics display (FPS, event count, frame time)
/// - Optional PerformanceOverlay for frame visualization
/// - Clustered events on multiple days to stress multi-day layout and overflow
/// - Wrapped in RepaintBoundary for efficient rendering
///
/// Demonstrates NFR-2 (Performance) - Month View handles large datasets smoothly.
class MonthStressTestTab extends StatefulWidget {
  const MonthStressTestTab({super.key});

  @override
  State<MonthStressTestTab> createState() => _MonthStressTestTabState();
}

class _MonthStressTestTabState extends State<MonthStressTestTab> {
  late MCalEventController _eventController;
  bool _stressTestEnabled = false;
  int _eventCount = 200;
  bool _showPerformanceOverlay = false;

  // Performance metrics
  double _avgFrameMs = 0;
  double _fps = 0;
  int _frameCount = 0;
  double _frameTimeSum = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _eventController = MCalEventController(initialDate: now);
    _eventController.addEvents(createSampleEvents());
    _registerFrameTimingCallback();
  }

  void _registerFrameTimingCallback() {
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    if (!mounted || !_stressTestEnabled) return;
    for (final timing in timings) {
      final totalMs = (timing.buildDuration + timing.rasterDuration)
              .inMicroseconds /
          1000.0;
      setState(() {
        _frameCount++;
        _frameTimeSum += totalMs;
        _avgFrameMs = _frameTimeSum / _frameCount;
        _fps = _avgFrameMs > 0 ? 1000 / _avgFrameMs : 0;
      });
    }
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  void _applyEvents() {
    final month = _eventController.displayDate;
    if (_stressTestEnabled) {
      _eventController.clearEvents();
      _eventController.addEvents(
        createMonthViewStressTestEvents(month, count: _eventCount),
      );
      setState(() {
        _frameCount = 0;
        _frameTimeSum = 0;
        _avgFrameMs = 0;
        _fps = 0;
      });
    } else {
      _eventController.clearEvents();
      _eventController.addEvents(createSampleEvents());
    }
  }

  void _toggleStressTest(bool enabled) {
    setState(() {
      _stressTestEnabled = enabled;
      _applyEvents();
    });
  }

  void _setEventCount(int count) {
    setState(() {
      _eventCount = count;
      if (_stressTestEnabled) _applyEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return ResponsiveControlPanel(
      controlPanelTitle: l10n.styleStressTest,
      controlPanel: _buildControlPanel(l10n),
      child: RepaintBoundary(
        child: Stack(
          children: [
            MCalMonthView(
              controller: _eventController,
              showNavigator: true,
              enableDragToMove: true,
              enableDragToResize: true,
              locale: locale,
              onDisplayDateChanged: (month) {
                setState(() {
                  if (_stressTestEnabled) {
                    _eventController.clearEvents();
                    _eventController.addEvents(
                      createMonthViewStressTestEvents(month, count: _eventCount),
                    );
                  }
                });
              },
              onEventTap: (ctx, details) {
                showEventDetailDialog(context, details.event, locale);
              },
              onOverflowTap: (ctx, details) {
                showDayEventsBottomSheet(
                  context,
                  details.date,
                  details.allEvents,
                  locale,
                );
              },
            ),
            if (_showPerformanceOverlay)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: const PerformanceOverlay(
                  optionsMask: 0,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle row
            Row(
              children: [
                Text(
                  'Stress Test Mode',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 12),
                Switch(
                  value: _stressTestEnabled,
                  onChanged: _toggleStressTest,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Event count selector
            if (_stressTestEnabled) ...[
              Text(
                'Event Count:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: _stressTestCounts
                    .map((c) => ButtonSegment<int>(
                          value: c,
                          label: Text('$c'),
                        ))
                    .toList(),
                selected: {_eventCount},
                onSelectionChanged: (s) => _setEventCount(s.first),
              ),
              const SizedBox(height: 16),
            ],
            // Performance overlay checkbox
            Row(
              children: [
                Checkbox(
                  value: _showPerformanceOverlay,
                  onChanged: (v) =>
                      setState(() => _showPerformanceOverlay = v ?? false),
                  tristate: false,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(
                        () => _showPerformanceOverlay = !_showPerformanceOverlay),
                    child: Text(
                      'Show frame overlay (green=OK, red=jank)',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Performance metrics
            if (_stressTestEnabled) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _PerformanceMetrics(
                eventCount: _eventController.allEvents.length,
                avgFrameMs: _avgFrameMs,
                fps: _fps,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Displays performance metrics (event count, frame time, FPS).
class _PerformanceMetrics extends StatelessWidget {
  const _PerformanceMetrics({
    required this.eventCount,
    required this.avgFrameMs,
    required this.fps,
  });

  final int eventCount;
  final double avgFrameMs;
  final double fps;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSmooth = fps >= 55 || avgFrameMs <= 18;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSmooth ? Icons.speed : Icons.warning_amber_rounded,
                size: 20,
                color: isSmooth ? colorScheme.primary : colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(
                'Performance Metrics',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MetricRow(
            label: 'Events',
            value: '$eventCount',
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 8),
          _MetricRow(
            label: 'Avg Frame Time',
            value: '${avgFrameMs.toStringAsFixed(1)} ms',
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 8),
          _MetricRow(
            label: 'FPS Estimate',
            value: '${fps.toStringAsFixed(0)} FPS',
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  final String label;
  final String value;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
