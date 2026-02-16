import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/utils/stress_test_events.dart';
import '../../../shared/widgets/control_panel_section.dart';
import '../../../shared/widgets/control_widgets.dart';
import '../../../shared/widgets/event_detail_dialog.dart';
import '../../../shared/widgets/responsive_control_panel.dart';

/// Stress test event count options.
const List<int> _stressTestCounts = [100, 200, 300, 500];

/// Day View stress test tab - demonstrates performance with 100-500 events.
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
class DayStressTestTab extends StatefulWidget {
  const DayStressTestTab({
    super.key,
    required this.locale,
    required this.isDarkMode,
  });

  final Locale locale;
  final bool isDarkMode;

  @override
  State<DayStressTestTab> createState() => _DayStressTestTabState();
}

class _DayStressTestTabState extends State<DayStressTestTab> {
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
    // NOTE: Event titles 'Morning Meeting' and 'Lunch Break' are mock data for demonstration
    // Missing ARB keys: mockEventMorningMeeting, mockEventLunchBreak (could be added in task 10)
    _eventController.addEvents([
      MCalCalendarEvent(
        id: 'sample-1',
        title: 'Morning Meeting',
        start: DateTime(now.year, now.month, now.day, 9, 0),
        end: DateTime(now.year, now.month, now.day, 10, 0),
      ),
      MCalCalendarEvent(
        id: 'sample-2',
        title: 'Lunch Break',
        start: DateTime(now.year, now.month, now.day, 12, 0),
        end: DateTime(now.year, now.month, now.day, 13, 0),
      ),
    ]);
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
      if (mounted) {
        setState(() {
          _frameCount++;
          _frameTimeSum += totalMs;
          _avgFrameMs = _frameTimeSum / _frameCount;
          _fps = _avgFrameMs > 0 ? 1000 / _avgFrameMs : 0;
        });
      }
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
      // NOTE: Event titles are mock data for demonstration purposes
      _eventController.addEvents([
        MCalCalendarEvent(
          id: 'sample-1',
          title: 'Morning Meeting',
          start: DateTime(date.year, date.month, date.day, 9, 0),
          end: DateTime(date.year, date.month, date.day, 10, 0),
        ),
        MCalCalendarEvent(
          id: 'sample-2',
          title: 'Lunch Break',
          start: DateTime(date.year, date.month, date.day, 12, 0),
          end: DateTime(date.year, date.month, date.day, 13, 0),
        ),
      ]);
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
    final colorScheme = Theme.of(context).colorScheme;

    return ResponsiveControlPanel(
      controlPanelTitle: l10n.stressTestSettings,
      controlPanel: _buildControlPanel(l10n, colorScheme),
      child: _buildDayView(colorScheme),
    );
  }

  Widget _buildControlPanel(AppLocalizations l10n, ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stress Test Controls Section
        ControlPanelSection(
          title: l10n.stressTestControls,
          children: [
            ControlWidgets.toggle(
              label: l10n.stressTestMode,
              value: _stressTestEnabled,
              onChanged: _toggleStressTest,
            ),
            if (_stressTestEnabled) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.stressTestEventCount,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: SegmentedButton<int>(
                        segments: _stressTestCounts
                            .map((c) => ButtonSegment<int>(
                                  value: c,
                                  label: Text('$c'),
                                ))
                            .toList(),
                        selected: {_eventCount},
                        onSelectionChanged: (s) => _setEventCount(s.first),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            ControlWidgets.toggle(
              label: l10n.stressTestShowOverlay,
              value: _showPerformanceOverlay,
              onChanged: (v) => setState(() => _showPerformanceOverlay = v),
            ),
          ],
        ),

        // Performance Metrics Section
        if (_stressTestEnabled) ...[
          const SizedBox(height: 8),
          ControlPanelSection(
            title: l10n.stressTestMetrics,
            children: [
              _PerformanceMetrics(
                eventCount: _eventController.allEvents.length,
                avgFrameMs: _avgFrameMs,
                fps: _fps,
                l10n: l10n,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDayView(ColorScheme colorScheme) {
    return RepaintBoundary(
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
                  context,
                  details.event,
                  widget.locale,
                );
              },
              onEventDropped: (details) {
                if (mounted) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.snackbarEventDropped(
                          details.event.title,
                          '${details.newStartDate.hour}:${details.newStartDate.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
              onEventResized: (details) {
                if (mounted) {
                  final minutes = details.newEndDate
                      .difference(details.newStartDate)
                      .inMinutes;
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.snackbarEventResized(
                          details.event.title,
                          minutes.toString(),
                        ),
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
    );
  }
}

/// Displays performance metrics (event count, frame time, FPS).
class _PerformanceMetrics extends StatelessWidget {
  const _PerformanceMetrics({
    required this.eventCount,
    required this.avgFrameMs,
    required this.fps,
    required this.l10n,
  });

  final int eventCount;
  final double avgFrameMs;
  final double fps;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSmooth = fps >= 55 || avgFrameMs <= 18;

    return Padding(
      padding: const EdgeInsets.all(8),
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
                isSmooth
                    ? l10n.stressTestPerformanceGood
                    : l10n.stressTestPerformancePoor,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSmooth ? colorScheme.primary : colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.stressTestEventCountLabel(eventCount.toString()),
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.stressTestAvgFrameTime(avgFrameMs.toStringAsFixed(1)),
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.stressTestFps(fps.toStringAsFixed(0)),
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
