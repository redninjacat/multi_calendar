import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/utils/locale_utils.dart';
import '../../../shared/utils/sample_events.dart';
import '../../../shared/widgets/control_panel_section.dart';
import '../../../shared/widgets/control_widgets.dart';
import '../../../shared/widgets/event_detail_dialog.dart';
import '../../../shared/widgets/event_form_dialog.dart'
    show showEventCreateDialog, showEventEditDialog;
import '../../../shared/widgets/responsive_control_panel.dart';
import '../../../shared/widgets/snackbar_helper.dart';

/// Day View Features tab - demonstrates ALL widget-level parameters and gestures.
///
/// Provides a comprehensive control panel exposing only MCalDayView widget
/// parameters (no theme settings). All gesture handlers are wired to show
/// SnackBars demonstrating the callbacks in action.
class DayFeaturesTab extends StatefulWidget {
  const DayFeaturesTab({
    super.key,
    required this.locale,
    required this.isDarkMode,
  });

  final Locale locale;
  final bool isDarkMode;

  @override
  State<DayFeaturesTab> createState() => _DayFeaturesTabState();
}

class _DayFeaturesTabState extends State<DayFeaturesTab> {
  late MCalEventController _eventController;

  // ============================================================
  // Navigation Settings
  // ============================================================
  bool _showNavigator = true;
  bool _autoScrollToCurrentTime = true;
  bool _enableSwipeNavigation = true;
  int _firstDayOfWeek = DateTime.sunday;

  // ============================================================
  // Display Settings
  // ============================================================
  bool _showCurrentTimeIndicator = true;
  bool _showWeekNumbers = false;
  bool _showSubHourLabels = false;
  Duration? _subHourLabelInterval = const Duration(minutes: 30);
  int _allDaySectionMaxRows = 3;
  Duration _allDayToTimedDuration = const Duration(hours: 1);

  // ============================================================
  // Drag & Drop Settings
  // ============================================================
  bool _enableDragToMove = true;
  bool _showDropTargetTiles = true;
  bool _showDropTargetOverlay = true;
  bool _dropTargetTilesAboveOverlay = false;
  bool _dragEdgeNavigationEnabled = true;
  Duration _dragEdgeNavigationDelay = const Duration(milliseconds: 1200);
  Duration _dragLongPressDelay = const Duration(milliseconds: 200);

  // ============================================================
  // Resize Settings
  // ============================================================
  bool? _enableDragToResize = true;

  // ============================================================
  // Animation Settings
  // ============================================================
  bool? _enableAnimations = true;
  Duration _animationDuration = const Duration(milliseconds: 300);

  // ============================================================
  // Keyboard Settings
  // ============================================================
  bool _enableKeyboardNavigation = true;
  bool _autoFocusOnEventTap = true;

  // ============================================================
  // Time Range Settings
  // ============================================================
  int _startHour = 6;
  int _endHour = 22;
  Duration _timeSlotDuration = const Duration(minutes: 15);
  Duration _gridlineInterval = const Duration(minutes: 15);
  double _hourHeight = 80.0;

  // ============================================================
  // Snapping Settings
  // ============================================================
  bool _snapToTimeSlots = true;
  bool _snapToOtherEvents = false;
  bool _snapToCurrentTime = false;
  Duration _snapRange = const Duration(minutes: 5);

  // ============================================================
  // Time Regions Settings
  // ============================================================
  bool _enableSpecialTimeRegions = true;
  bool _enableBlackoutTimes = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _eventController = MCalEventController(
      initialDate: now,
      firstDayOfWeek: _firstDayOfWeek,
    );
    _eventController.addEvents(createDayViewSampleEvents(now));
    // Async-update the first day of week from the current locale.
    _syncFirstDayOfWeekFromLocale(widget.locale);
  }

  @override
  void didUpdateWidget(DayFeaturesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locale.languageCode != widget.locale.languageCode) {
      _syncFirstDayOfWeekFromLocale(widget.locale);
    }
  }

  /// Loads the first day of week from CLDR locale data and updates the
  /// controller if the value differs from the current setting.
  Future<void> _syncFirstDayOfWeekFromLocale(Locale locale) async {
    final fdow = await firstDayOfWeekForLocale(locale);
    if (!mounted || fdow == _firstDayOfWeek) return;
    setState(() {
      _firstDayOfWeek = fdow;
      _eventController.firstDayOfWeek = fdow;
    });
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  List<MCalTimeRegion> _buildTimeRegions() {
    final d = _eventController.displayDate;
    final regions = <MCalTimeRegion>[];

    if (_enableSpecialTimeRegions) {
      // Lunch break (special region)
      // NOTE: 'Lunch Break' is mock data for demonstration purposes
      // Missing ARB key: timeRegionLunchBreak (needs to be added in task 10)
      regions.add(
        MCalTimeRegion(
          id: 'lunch',
          startTime: DateTime(d.year, d.month, d.day, 12, 0),
          endTime: DateTime(d.year, d.month, d.day, 13, 0),
          color: Colors.amber.withValues(alpha: 0.2),
          text: 'Lunch Break',
          icon: Icons.restaurant,
          blockInteraction: false,
        ),
      );
    }

    if (_enableBlackoutTimes) {
      // After-hours (blocked region)
      // NOTE: 'After Hours (blocked)' is mock data for demonstration purposes
      // Missing ARB key: timeRegionAfterHoursBlocked (needs to be added in task 10)
      regions.add(
        MCalTimeRegion(
          id: 'after-hours',
          startTime: DateTime(d.year, d.month, d.day, 18, 0),
          endTime: DateTime(d.year, d.month, d.day, 22, 0),
          color: Colors.red.withValues(alpha: 0.15),
          text: 'After Hours (blocked)',
          icon: Icons.block,
          blockInteraction: true,
        ),
      );
    }

    return regions;
  }

  void _handleEventTap(BuildContext context, MCalEventTapDetails details) {
    showEventDetailDialog(
      context,
      details.event,
      widget.locale,
      onEdit: () {
        Navigator.of(context).pop();
        _handleEditEvent(details.event);
      },
      onDelete: () {
        Navigator.of(context).pop();
        _handleDeleteEvent(details.event);
      },
    );
  }

  Future<void> _handleCreateEvent(DateTime time) async {
    final l10n = AppLocalizations.of(context)!;
    final newEvent = await showEventCreateDialog(
      context,
      displayDate: _eventController.displayDate,
      initialTime: time,
    );
    if (newEvent != null && mounted) {
      _eventController.addEvents([newEvent]);
      SnackBarHelper.show(context, l10n.snackbarEventCreated(newEvent.title));
    }
  }

  Future<void> _handleEditEvent(MCalCalendarEvent event) async {
    final l10n = AppLocalizations.of(context)!;
    final updatedEvent = await showEventEditDialog(
      context,
      event: event,
      displayDate: _eventController.displayDate,
    );
    if (updatedEvent != null && mounted) {
      _eventController.addEvents([updatedEvent]);
      SnackBarHelper.show(
        context,
        l10n.snackbarEventUpdated(updatedEvent.title),
      );
    }
  }

  void _handleDeleteEvent(MCalCalendarEvent event) {
    final l10n = AppLocalizations.of(context)!;
    _eventController.removeEvents([event.id]);
    SnackBarHelper.show(context, l10n.snackbarEventDeleted(event.title));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ResponsiveControlPanel(
      controlPanelTitle: l10n.featureSettings,
      controlPanel: _buildControlPanel(l10n),
      child: _buildDayView(l10n),
    );
  }

  Widget _buildControlPanel(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Shared sections (same order as Month View) ──────────────────────

        // Navigation Section
        ControlPanelSection(
          showTopDivider: false,
          title: l10n.sectionNavigation,
          children: [
            ControlWidgets.toggle(
              label: l10n.settingShowNavigator,
              value: _showNavigator,
              onChanged: (v) => setState(() => _showNavigator = v),
            ),
            ControlWidgets.toggle(
              label: l10n.settingAutoScrollToCurrentTime,
              value: _autoScrollToCurrentTime,
              onChanged: (v) => setState(() => _autoScrollToCurrentTime = v),
            ),
            ControlWidgets.toggle(
              label: l10n.settingEnableSwipeNavigation,
              value: _enableSwipeNavigation,
              onChanged: (v) => setState(() => _enableSwipeNavigation = v),
            ),
            ControlWidgets.dropdown<int>(
              label: l10n.settingFirstDayOfWeek,
              value: _firstDayOfWeek,
              items: [
                DropdownMenuItem(
                  value: DateTime.monday,
                  child: Text(l10n.dayMonday),
                ),
                DropdownMenuItem(
                  value: DateTime.sunday,
                  child: Text(l10n.daySunday),
                ),
                DropdownMenuItem(
                  value: DateTime.saturday,
                  child: Text(l10n.daySaturday),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _firstDayOfWeek = value;
                    _eventController.firstDayOfWeek = value;
                  });
                }
              },
            ),
          ],
        ),

        // Display Section
        ControlPanelSection(
          title: l10n.sectionDisplay,
          children: [
            ControlWidgets.toggle(
              label: l10n.settingShowCurrentTimeIndicator,
              value: _showCurrentTimeIndicator,
              onChanged: (v) => setState(() => _showCurrentTimeIndicator = v),
            ),
            ControlWidgets.toggle(
              label: l10n.settingShowWeekNumbers,
              value: _showWeekNumbers,
              onChanged: (v) => setState(() => _showWeekNumbers = v),
            ),
            ControlWidgets.toggle(
              label: l10n.settingShowSubHourLabels,
              value: _showSubHourLabels,
              onChanged: (v) => setState(() => _showSubHourLabels = v),
            ),
            ControlWidgets.dropdown<int>(
              label: l10n.settingSubHourLabelInterval,
              value: _subHourLabelInterval?.inMinutes ?? 30,
              items: [15, 20, 30]
                  .map(
                    (m) => DropdownMenuItem(
                      value: m,
                      child: Text(l10n.valueMinutes(m)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _subHourLabelInterval = Duration(minutes: v));
                }
              },
            ),
            ControlWidgets.slider(
              label: l10n.settingAllDaySectionMaxRows,
              value: _allDaySectionMaxRows.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (v) =>
                  setState(() => _allDaySectionMaxRows = v.toInt()),
            ),
            ControlWidgets.dropdown<int>(
              label: l10n.settingAllDayToTimedDuration,
              value: _allDayToTimedDuration.inMinutes,
              items: [30, 60, 90, 120]
                  .map(
                    (minutes) => DropdownMenuItem(
                      value: minutes,
                      child: Text(l10n.valueMinutes(minutes)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _allDayToTimedDuration = Duration(minutes: v));
                }
              },
            ),
          ],
        ),

        // Drag & Drop Section
        ControlPanelSection(
          title: l10n.sectionDragDrop,
          children: [
            ControlWidgets.toggle(
              label: l10n.settingEnableDragToMove,
              value: _enableDragToMove,
              onChanged: (v) => setState(() => _enableDragToMove = v),
            ),
            ControlWidgets.toggle(
              label: l10n.settingShowDropTargetTiles,
              value: _showDropTargetTiles,
              onChanged: (v) => setState(() => _showDropTargetTiles = v),
            ),
            ControlWidgets.toggle(
              label: l10n.settingShowDropTargetOverlay,
              value: _showDropTargetOverlay,
              onChanged: (v) => setState(() => _showDropTargetOverlay = v),
            ),
            ControlWidgets.toggle(
              label: l10n.settingDropTargetTilesAboveOverlay,
              value: _dropTargetTilesAboveOverlay,
              onChanged: (v) =>
                  setState(() => _dropTargetTilesAboveOverlay = v),
            ),
            ControlWidgets.toggle(
              label: l10n.settingDragEdgeNavigationEnabled,
              value: _dragEdgeNavigationEnabled,
              onChanged: (v) => setState(() => _dragEdgeNavigationEnabled = v),
            ),
            ControlWidgets.slider(
              label: l10n.settingDragEdgeNavigationDelay,
              value: _dragEdgeNavigationDelay.inMilliseconds.toDouble(),
              min: 100,
              max: 1000,
              divisions: 9,
              onChanged: (v) => setState(
                () => _dragEdgeNavigationDelay = Duration(
                  milliseconds: v.toInt(),
                ),
              ),
              valueLabel: '${_dragEdgeNavigationDelay.inMilliseconds}ms',
            ),
            ControlWidgets.slider(
              label: l10n.settingDragLongPressDelay,
              value: _dragLongPressDelay.inMilliseconds.toDouble(),
              min: 100,
              max: 500,
              divisions: 8,
              onChanged: (v) => setState(
                () => _dragLongPressDelay = Duration(milliseconds: v.toInt()),
              ),
              valueLabel: '${_dragLongPressDelay.inMilliseconds}ms',
            ),
          ],
        ),

        // Resize Section
        ControlPanelSection(
          title: l10n.sectionResize,
          children: [
            ControlWidgets.triStateToggle(
              label: l10n.settingEnableDragToResize,
              value: _enableDragToResize,
              onChanged: (v) => setState(() => _enableDragToResize = v),
            ),
          ],
        ),

        // Animation Section
        ControlPanelSection(
          title: l10n.sectionAnimation,
          children: [
            ControlWidgets.triStateToggle(
              label: l10n.settingEnableAnimations,
              value: _enableAnimations,
              onChanged: (v) => setState(() => _enableAnimations = v),
            ),
            ControlWidgets.slider(
              label: l10n.settingAnimationDuration,
              value: _animationDuration.inMilliseconds.toDouble(),
              min: 100,
              max: 800,
              divisions: 14,
              onChanged: (v) => setState(
                () => _animationDuration = Duration(milliseconds: v.toInt()),
              ),
              valueLabel: '${_animationDuration.inMilliseconds}ms',
            ),
          ],
        ),

        // Keyboard Section
        ControlPanelSection(
          title: l10n.sectionKeyboard,
          children: [
            ControlWidgets.toggle(
              label: l10n.settingEnableKeyboardNavigation,
              value: _enableKeyboardNavigation,
              onChanged: (v) => setState(() => _enableKeyboardNavigation = v),
            ),
            ControlWidgets.toggle(
              label: l10n.settingAutoFocusOnEventTap,
              value: _autoFocusOnEventTap,
              onChanged: (v) => setState(() => _autoFocusOnEventTap = v),
            ),
          ],
        ),

        // ── Day View-only sections ───────────────────────────────────────────

        // Time Range Section
        ControlPanelSection(
          title: l10n.sectionTimeRange,
          children: [
            ControlWidgets.slider(
              label: l10n.settingStartHour,
              value: _startHour.toDouble(),
              min: 0,
              max: 23,
              divisions: 23,
              onChanged: (v) => setState(() => _startHour = v.toInt()),
              valueLabel: '$_startHour:00',
            ),
            ControlWidgets.slider(
              label: l10n.settingEndHour,
              value: _endHour.toDouble(),
              min: 1,
              max: 24,
              divisions: 23,
              onChanged: (v) => setState(() => _endHour = v.toInt()),
              valueLabel: '$_endHour:00',
            ),
            ControlWidgets.dropdown<int>(
              label: l10n.settingTimeSlotDuration,
              value: _timeSlotDuration.inMinutes,
              items: [5, 10, 15, 20, 30, 60]
                  .map(
                    (minutes) => DropdownMenuItem(
                      value: minutes,
                      child: Text(l10n.valueMinutes(minutes)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _timeSlotDuration = Duration(minutes: v));
                }
              },
            ),
            ControlWidgets.dropdown<int>(
              label: l10n.settingGridlineInterval,
              value: _gridlineInterval.inMinutes,
              items: [5, 10, 15, 20, 30, 60]
                  .map(
                    (minutes) => DropdownMenuItem(
                      value: minutes,
                      child: Text(l10n.valueMinutes(minutes)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _gridlineInterval = Duration(minutes: v));
                }
              },
            ),
            ControlWidgets.slider(
              label: l10n.settingHourHeight,
              value: _hourHeight,
              min: 60,
              max: 120,
              divisions: 12,
              onChanged: (v) => setState(() => _hourHeight = v),
              valueLabel: '${_hourHeight.toInt()}px',
            ),
          ],
        ),

        // Snapping Section
        ControlPanelSection(
          title: l10n.sectionSnapping,
          children: [
            ControlWidgets.toggle(
              label: l10n.settingSnapToTimeSlots,
              value: _snapToTimeSlots,
              onChanged: (v) => setState(() => _snapToTimeSlots = v),
            ),
            ControlWidgets.toggle(
              label: l10n.settingSnapToOtherEvents,
              value: _snapToOtherEvents,
              onChanged: (v) => setState(() => _snapToOtherEvents = v),
            ),
            ControlWidgets.toggle(
              label: l10n.settingSnapToCurrentTime,
              value: _snapToCurrentTime,
              onChanged: (v) => setState(() => _snapToCurrentTime = v),
            ),
            ControlWidgets.slider(
              label: l10n.settingSnapRange,
              value: _snapRange.inMinutes.toDouble(),
              min: 1,
              max: 15,
              divisions: 14,
              onChanged: (v) =>
                  setState(() => _snapRange = Duration(minutes: v.toInt())),
              valueLabel: l10n.valueMinutes(_snapRange.inMinutes),
            ),
          ],
        ),

        // Time Regions Section
        ControlPanelSection(
          title: l10n.sectionTimeRegions,
          children: [
            ControlWidgets.toggle(
              label: l10n.settingEnableSpecialTimeRegions,
              value: _enableSpecialTimeRegions,
              onChanged: (v) => setState(() => _enableSpecialTimeRegions = v),
            ),
            ControlWidgets.toggle(
              label: l10n.settingEnableBlackoutTimes,
              value: _enableBlackoutTimes,
              onChanged: (v) => setState(() => _enableBlackoutTimes = v),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDayView(AppLocalizations l10n) {
    return ListenableBuilder(
      listenable: _eventController,
      builder: (context, _) {
        return MCalDayView(
          controller: _eventController,
          startHour: _startHour,
          endHour: _endHour,
          timeSlotDuration: _timeSlotDuration,
          gridlineInterval: _gridlineInterval,
          hourHeight: _hourHeight,
          showNavigator: _showNavigator,
          autoScrollToCurrentTime: _autoScrollToCurrentTime,
          showCurrentTimeIndicator: _showCurrentTimeIndicator,
          showWeekNumbers: _showWeekNumbers,
          showSubHourLabels: _showSubHourLabels,
          subHourLabelInterval: _showSubHourLabels
              ? _subHourLabelInterval
              : null,
          allDaySectionMaxRows: _allDaySectionMaxRows,
          allDayToTimedDuration: _allDayToTimedDuration,
          enableDragToMove: _enableDragToMove,
          showDropTargetTiles: _showDropTargetTiles,
          showDropTargetOverlay: _showDropTargetOverlay,
          dropTargetTilesAboveOverlay: _dropTargetTilesAboveOverlay,
          dragEdgeNavigationEnabled: _dragEdgeNavigationEnabled,
          dragEdgeNavigationDelay: _dragEdgeNavigationDelay,
          dragLongPressDelay: _dragLongPressDelay,
          enableDragToResize: _enableDragToResize,
          snapToTimeSlots: _snapToTimeSlots,
          snapToOtherEvents: _snapToOtherEvents,
          snapToCurrentTime: _snapToCurrentTime,
          snapRange: _snapRange,
          enableAnimations: _enableAnimations,
          animationDuration: _animationDuration,
          enableKeyboardNavigation: _enableKeyboardNavigation,
          autoFocusOnEventTap: _autoFocusOnEventTap,
          enableSwipeNavigation: _enableSwipeNavigation,
          specialTimeRegions: _buildTimeRegions(),
          locale: widget.locale,
          // Gesture Handlers - All wired to SnackBars
          onDayHeaderTap: (context, date) {
            SnackBarHelper.show(
              context,
              l10n.snackbarDayHeaderTap(date.toString().split(' ')[0]),
            );
          },
          onDayHeaderLongPress: (context, date) {
            SnackBarHelper.show(
              context,
              l10n.snackbarDayHeaderLongPress(date.toString().split(' ')[0]),
            );
          },
          onTimeLabelTap: (context, labelContext) {
            final t = labelContext.time;
            SnackBarHelper.show(
              context,
              l10n.snackbarTimeLabelTap(
                '${t.hour}:${t.minute.toString().padLeft(2, '0')}',
              ),
            );
          },
          onTimeSlotTap: (context, slotContext) {
            final hour = slotContext.hour ?? 0;
            final minute = slotContext.minute ?? 0;
            SnackBarHelper.show(
              context,
              l10n.snackbarTimeSlotTap(
                '$hour:${minute.toString().padLeft(2, '0')}',
              ),
            );
          },
          onTimeSlotLongPress: (context, slotContext) {
            final hour = slotContext.hour ?? 0;
            final minute = slotContext.minute ?? 0;
            SnackBarHelper.show(
              context,
              l10n.snackbarTimeSlotLongPress(
                '$hour:${minute.toString().padLeft(2, '0')}',
              ),
            );
          },
          onTimeSlotDoubleTap: (context, slotContext) {
            if (!slotContext.isAllDayArea) {
              final time = DateTime(
                slotContext.displayDate.year,
                slotContext.displayDate.month,
                slotContext.displayDate.day,
                slotContext.hour ?? 0,
                slotContext.minute ?? 0,
              );
              SnackBarHelper.show(
                context,
                l10n.snackbarEmptySpaceDoubleTap(
                  '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                ),
              );
              _handleCreateEvent(time);
            }
          },
          onEventTap: (context, details) => _handleEventTap(context, details),
          onEventLongPress: (context, details) {
            SnackBarHelper.show(
              context,
              l10n.snackbarEventLongPress(details.event.title),
            );
          },
          onEventDoubleTap: (context, details) {
            SnackBarHelper.show(
              context,
              l10n.snackbarEventDoubleTap(details.event.title),
            );
          },
          onHoverEvent: (context, event) {
            if (event != null) {
              SnackBarHelper.show(
                context,
                l10n.snackbarHoverEvent(event.title),
              );
            }
          },
          onHoverTimeSlot: (context, slotContext) {
            if (slotContext != null) {
              final hour = slotContext.hour ?? 0;
              final minute = slotContext.minute ?? 0;
              SnackBarHelper.show(
                context,
                l10n.snackbarHoverTimeSlot(
                  '$hour:${minute.toString().padLeft(2, '0')}',
                ),
              );
            }
          },
          onOverflowTap: (context, events, date) {
            SnackBarHelper.show(
              context,
              l10n.snackbarOverflowTap(events.length),
            );
          },
          onDragWillAccept: (details) {
            final time = details.newStartDate;
            SnackBarHelper.show(
              context,
              l10n.snackbarDragWillAccept(
                details.event.title,
                '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
              ),
            );
            return true;
          },
          onEventDropped: (context, details) {
            final time = details.newStartDate;
            SnackBarHelper.show(
              context,
              l10n.snackbarEventDropped(
                details.event.title,
                '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
              ),
            );
            return true;
          },
          onResizeWillAccept: (details) {
            final duration = details.newEndDate.difference(
              details.newStartDate,
            );
            SnackBarHelper.show(
              context,
              l10n.snackbarResizeWillAccept(
                details.event.title,
                duration.inMinutes.toString(),
              ),
            );
            return true;
          },
          onEventResized: (context, details) {
            final duration = details.newEndDate.difference(
              details.newStartDate,
            );
            SnackBarHelper.show(
              context,
              l10n.snackbarEventResized(
                details.event.title,
                duration.inMinutes.toString(),
              ),
            );
            return true;
          },
          onSwipeNavigation: (context, details) {
            SnackBarHelper.show(
              context,
              l10n.snackbarSwipeNavigation(details.direction.name),
            );
          },
          // Keyboard CRUD Handlers
          onCreateEventRequested: () {
            final now = DateTime.now();
            final nextHour = DateTime(
              now.year,
              now.month,
              now.day,
              now.hour + 1,
            );
            _handleCreateEvent(nextHour);
          },
          onEditEventRequested: (event) {
            _handleEditEvent(event);
          },
          onDeleteEventRequested: (event) {
            _handleDeleteEvent(event);
          },
        );
      },
    );
  }
}
