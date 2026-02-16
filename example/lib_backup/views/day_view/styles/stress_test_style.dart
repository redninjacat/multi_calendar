import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../utils/sample_events.dart';
import '../../../widgets/event_detail_dialog.dart';
import '../../../widgets/style_description.dart';

/// Stress test event count options.
const List<int> _stressTestCounts = [100, 200, 300, 500];

/// Day View stress test style - demonstrates performance with 100-500 events.
///
/// Features:
/// - Toggle to enable/disable stress test mode
/// - Event count selector (100, 200, 300, 500)
/// - Performance metrics display (FPS, event count, frame time)
/// - Optional PerformanceOverlay for frame visualization
/// - Many overlapping events to stress overlap detection and layout
/// - Wrapped in RepaintBoundary for efficient rendering
///
/// Demonstrates NFR-2 (Performance) - Day View handles large datasets smoothly.
class StressTestDayStyle extends StatefulWidget {
  const StressTestDayStyle({
    super.key,
    required this.locale,
    required this.isDarkMode,
    required this.description,
  });

  final Locale locale;
  final bool isDarkMode;
  final String description;

  @override
  State<StressTestDayStyle> createState() => _StressTestDayStyleState();
}

class _StressTestDayStyleState extends State<StressTestDayStyle> {
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
    _eventController.addEvents(createDayViewSampleEvents(now));
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
    final date = _eventController.displayDate;
    if (_stressTestEnabled) {
      _eventController.clearEvents();
      _eventController.addEvents(
        createDayViewStressTestEvents(date, count: _eventCount),
      );
      setState(() {
        _frameCount = 0;
        _frameTimeSum = 0;
        _avgFrameMs = 0;
        _fps = 0;
      });
    } else {
      _eventController.clearEvents();
      _eventController.addEvents(createDayViewSampleEvents(date));
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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        StyleDescription(description: widget.description),
        // Stress test controls
        _StressTestControls(
          stressTestEnabled: _stressTestEnabled,
          onToggle: _toggleStressTest,
          selectedEventCount: _eventCount,
          onEventCountChanged: _setEventCount,
          showPerformanceOverlay: _showPerformanceOverlay,
          onPerformanceOverlayChanged: (v) =>
              setState(() => _showPerformanceOverlay = v),
          avgFrameMs: _avgFrameMs,
          fps: _fps,
          displayedEventCount: _eventController.allEvents.length,
        ),
        Expanded(
          child: RepaintBoundary(
            child: Stack(
              children: [
                MCalTheme(
                  data: MCalThemeData(
                    dayTheme: MCalDayThemeData(
                      hourGridlineColor: colorScheme.outline.withValues(alpha: 0.2),
                      hourGridlineWidth: 1.0,
                      majorGridlineColor:
                          colorScheme.outline.withValues(alpha: 0.1),
                      majorGridlineWidth: 1.0,
                      minorGridlineColor:
                          colorScheme.outline.withValues(alpha: 0.05),
                      minorGridlineWidth: 0.5,
                      currentTimeIndicatorColor: colorScheme.primary,
                      currentTimeIndicatorWidth: 2.0,
                      timeLegendBackgroundColor:
                          colorScheme.surfaceContainerHighest,
                      timeLegendTextStyle: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      timedEventMinHeight: 20.0,
                      timedEventPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                    ),
                  ),
                  child: MCalDayView(
                    controller: _eventController,
                    startHour: 0,
                    endHour: 24,
                    timeSlotDuration: const Duration(minutes: 15),
                    enableDragToMove: true,
                    enableDragToResize: true,
                    snapToTimeSlots: true,
                    showNavigator: true,
                    showCurrentTimeIndicator: true,
                    locale: widget.locale,
                    onEventTap: (context, details) {
                      showEventDetailDialog(
                          context, details.event, widget.locale);
                    },
                    onEventDropped: (details) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Moved: ${details.event.title}',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    onEventResized: (details) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Resized: ${details.event.title}',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                  ),
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
        ),
      ],
    );
  }
}

/// Controls for stress test mode: toggle, event count, performance overlay.
class _StressTestControls extends StatelessWidget {
  const _StressTestControls({
    required this.stressTestEnabled,
    required this.onToggle,
    required this.selectedEventCount,
    required this.onEventCountChanged,
    required this.showPerformanceOverlay,
    required this.onPerformanceOverlayChanged,
    required this.avgFrameMs,
    required this.fps,
    required this.displayedEventCount,
  });

  final bool stressTestEnabled;
  final ValueChanged<bool> onToggle;
  final int selectedEventCount;
  final ValueChanged<int> onEventCountChanged;
  final bool showPerformanceOverlay;
  final ValueChanged<bool> onPerformanceOverlayChanged;
  final double avgFrameMs;
  final double fps;
  final int displayedEventCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: colorScheme.surfaceContainerHighest,
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
                value: stressTestEnabled,
                onChanged: onToggle,
              ),
              const Spacer(),
              if (stressTestEnabled) ...[
                Text(
                  'Events:',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                SegmentedButton<int>(
                  segments: _stressTestCounts
                      .map((c) => ButtonSegment<int>(
                            value: c,
                            label: Text('$c'),
                          ))
                      .toList(),
                  selected: {selectedEventCount},
                  onSelectionChanged: (s) =>
                      onEventCountChanged(s.first),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: showPerformanceOverlay,
                onChanged: (v) =>
                    onPerformanceOverlayChanged(v ?? false),
                tristate: false,
              ),
              GestureDetector(
                onTap: () =>
                    onPerformanceOverlayChanged(!showPerformanceOverlay),
                child: Text(
                  'Show frame overlay (green=OK, red=jank)',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          if (stressTestEnabled) ...[
            const SizedBox(height: 8),
            _PerformanceMetrics(
              eventCount: displayedEventCount,
              avgFrameMs: avgFrameMs,
              fps: fps,
            ),
          ],
        ],
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

    return Row(
      children: [
        Icon(
          isSmooth ? Icons.speed : Icons.warning_amber_rounded,
          size: 16,
          color: isSmooth
              ? colorScheme.primary
              : colorScheme.error,
        ),
        const SizedBox(width: 8),
        Text(
          '$eventCount events • '
          '${avgFrameMs.toStringAsFixed(1)} ms/frame • '
          '${fps.toStringAsFixed(0)} FPS',
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'monospace',
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
