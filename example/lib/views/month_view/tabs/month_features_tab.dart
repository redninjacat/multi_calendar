import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/utils/sample_events.dart';
import '../../../shared/widgets/control_panel_section.dart';
import '../../../shared/widgets/control_widgets.dart';
import '../../../shared/widgets/day_events_bottom_sheet.dart';
import '../../../shared/widgets/event_detail_dialog.dart';
import '../../../shared/widgets/responsive_control_panel.dart';
import '../../../shared/widgets/snackbar_helper.dart';

/// Month View Features tab demonstrating widget-level settings and gesture handlers.
///
/// Shows a responsive control panel with organized sections for:
/// - Navigation settings
/// - Display settings
/// - Drag & Drop settings
/// - Resize settings
/// - Animation settings
/// - Keyboard settings
/// - Blackout days
///
/// All gesture handlers are wired with SnackBar messages for demonstration.
class MonthFeaturesTab extends StatefulWidget {
  const MonthFeaturesTab({super.key});

  @override
  State<MonthFeaturesTab> createState() => _MonthFeaturesTabState();
}

class _MonthFeaturesTabState extends State<MonthFeaturesTab> {
  late MCalEventController _controller;
  DateTime _currentMonth = DateTime.now();

  // Navigation settings
  bool _showNavigator = true;
  bool _enableSwipeNavigation = true;
  MCalSwipeNavigationDirection _swipeNavigationDirection =
      MCalSwipeNavigationDirection.horizontal;
  int _firstDayOfWeek = DateTime.monday;

  // Display settings
  bool _showWeekNumbers = false;
  int _maxVisibleEventsPerDay = 5;

  // Drag & Drop settings
  bool _enableDragToMove = true;
  bool _showDropTargetTiles = true;
  bool _showDropTargetOverlay = true;
  bool _dropTargetTilesAboveOverlay = false;
  bool _dragEdgeNavigationEnabled = true;
  int _dragEdgeNavigationDelay = 900;
  int _dragLongPressDelay = 500;

  // Resize settings
  bool? _enableDragToResize = true;

  // Animation settings
  bool? _enableAnimations = true;
  int _animationDuration = 300;
  Curve _animationCurve = Curves.easeInOut;

  // Keyboard settings
  bool _enableKeyboardNavigation = true;
  bool _autoFocusOnCellTap = true;

  // Blackout days settings
  bool _enableBlackoutDays = false;
  Set<int> _blackoutDaysOfWeek = {};
  late Set<DateTime> _blackoutDates;

  @override
  void initState() {
    super.initState();
    _controller = MCalEventController(firstDayOfWeek: _firstDayOfWeek);
    _controller.addEvents(createSampleEvents());
    _blackoutDates = _computeBlackoutDates();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Computes blackout dates based on selected days of week for current and next month
  Set<DateTime> _computeBlackoutDates() {
    if (!_enableBlackoutDays || _blackoutDaysOfWeek.isEmpty) {
      return {};
    }

    final dates = <DateTime>{};
    final start = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    final end = DateTime(nextMonth.year, nextMonth.month + 1, 0);

    for (var date = start;
        date.isBefore(end) || date.isAtSameMomentAs(end);
        date = date.add(const Duration(days: 1))) {
      if (_blackoutDaysOfWeek.contains(date.weekday)) {
        dates.add(DateTime(date.year, date.month, date.day));
      }
    }

    return dates;
  }

  void _updateBlackoutDates() {
    setState(() {
      _blackoutDates = _computeBlackoutDates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return ResponsiveControlPanel(
      controlPanelTitle: l10n.featureSettings,
      controlPanel: _buildControlPanel(l10n),
      child: MCalMonthView(
        controller: _controller,
        // Navigation
        showNavigator: _showNavigator,
        onDisplayDateChanged: (month) {
          setState(() {
            _currentMonth = month;
            _blackoutDates = _computeBlackoutDates();
          });
        },
        enableSwipeNavigation: _enableSwipeNavigation,
        swipeNavigationDirection: _swipeNavigationDirection,
        // Display
        showWeekNumbers: _showWeekNumbers,
        maxVisibleEventsPerDay: _maxVisibleEventsPerDay,
        // Drag & Drop
        enableDragToMove: _enableDragToMove,
        showDropTargetTiles: _showDropTargetTiles,
        showDropTargetOverlay: _showDropTargetOverlay,
        dropTargetTilesAboveOverlay: _dropTargetTilesAboveOverlay,
        dragEdgeNavigationEnabled: _dragEdgeNavigationEnabled,
        dragEdgeNavigationDelay:
            Duration(milliseconds: _dragEdgeNavigationDelay),
        dragLongPressDelay: Duration(milliseconds: _dragLongPressDelay),
        // Resize
        enableDragToResize: _enableDragToResize,
        // Animation
        enableAnimations: _enableAnimations,
        animationDuration: Duration(milliseconds: _animationDuration),
        animationCurve: _animationCurve,
        // Keyboard
        enableKeyboardNavigation: _enableKeyboardNavigation,
        autoFocusOnCellTap: _autoFocusOnCellTap,
        // Gesture handlers
        onCellTap: (ctx, details) {
          SnackBarHelper.show(
            context,
            l10n.snackbarCellTap(_formatDate(details.date, locale)),
          );
        },
        onCellLongPress: (ctx, details) {
          SnackBarHelper.show(
            context,
            l10n.snackbarCellLongPress(_formatDate(details.date, locale)),
          );
        },
        onCellDoubleTap: (ctx, details) {
          SnackBarHelper.show(
            context,
            l10n.snackbarCellDoubleTap(_formatDate(details.date, locale)),
          );
        },
        onDateLabelTap: (ctx, details) {
          SnackBarHelper.show(
            context,
            l10n.snackbarDateLabelTap(_formatDate(details.date, locale)),
          );
        },
        onDateLabelLongPress: (ctx, details) {
          SnackBarHelper.show(
            context,
            l10n.snackbarDateLabelLongPress(_formatDate(details.date, locale)),
          );
        },
        onEventTap: (ctx, details) {
          showEventDetailDialog(context, details.event, locale);
        },
        onEventLongPress: (ctx, details) {
          SnackBarHelper.show(
              context, l10n.snackbarEventLongPress(details.event.title));
        },
        onEventDoubleTap: (ctx, details) {
          SnackBarHelper.show(
              context, l10n.snackbarEventDoubleTap(details.event.title));
        },
        onOverflowTap: (ctx, details) {
          showDayEventsBottomSheet(
              context, details.date, details.allEvents, locale);
        },
        onOverflowLongPress: (ctx, details) {
          SnackBarHelper.show(
            context,
            l10n.snackbarOverflowLongPress(_formatDate(details.date, locale), details.hiddenEventCount),
          );
        },
        onHoverCell: (context, cellContext) {
          // Note: Hover events can be very frequent, so we don't show a SnackBar
          // to avoid overwhelming the UI. In a real app, you might update a status bar.
        },
        onHoverEvent: (context, eventContext) {
          // Note: Similar to hover cell, these are very frequent
        },
        onDragWillAccept: (ctx, details) {
          // Validate against blackout days
          if (_enableBlackoutDays &&
              _blackoutDates.contains(details.proposedStartDate)) {
            SnackBarHelper.show(
              context,
              l10n.snackbarDropRejected(_formatDate(details.proposedStartDate, locale)),
            );
            return false;
          }
          return true;
        },
        onEventDropped: (ctx, details) {
          SnackBarHelper.show(
            context,
            l10n.snackbarEventDropped(details.event.title, _formatDate(details.newStartDate, locale)),
          );
          return true;
        },
        onResizeWillAccept: (ctx, details) {
          // Could add validation logic here
          return true;
        },
        onEventResized: (ctx, details) {
          final days =
              details.newEndDate.difference(details.newStartDate).inDays + 1;
          SnackBarHelper.show(
            context,
            l10n.snackbarEventResizedDays(details.event.title, days),
          );
          return true;
        },
        onFocusedDateChanged: (date) {
          if (date != null) {
            SnackBarHelper.show(
              context,
              l10n.snackbarFocusedDateChanged(_formatDate(date, locale)),
            );
          }
        },
        onSwipeNavigation: (ctx, details) {
          SnackBarHelper.show(context, l10n.snackbarSwipeNavigation(details.direction.name));
        },
      ),
    );
  }

  Widget _buildControlPanel(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
          // Navigation section
          ControlPanelSection(
            showTopDivider: false,
            title: l10n.sectionNavigation,
            children: [
              ControlWidgets.toggle(
                label: l10n.settingShowNavigator,
                value: _showNavigator,
                onChanged: (value) => setState(() => _showNavigator = value),
              ),
              ControlWidgets.toggle(
                label: l10n.settingEnableSwipeNavigation,
                value: _enableSwipeNavigation,
                onChanged: (value) =>
                    setState(() => _enableSwipeNavigation = value),
              ),
              ControlWidgets.dropdown<MCalSwipeNavigationDirection>(
                label: l10n.settingSwipeDirection,
                value: _swipeNavigationDirection,
                items: [
                  DropdownMenuItem(
                    value: MCalSwipeNavigationDirection.horizontal,
                    child: Text(l10n.swipeDirectionHorizontal),
                  ),
                  DropdownMenuItem(
                    value: MCalSwipeNavigationDirection.vertical,
                    child: Text(l10n.swipeDirectionVertical),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _swipeNavigationDirection = value);
                  }
                },
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
                    final events = _controller.allEvents;
                    _controller.dispose();
                    _controller = MCalEventController(firstDayOfWeek: value);
                    _controller.addEvents(events);
                    setState(() => _firstDayOfWeek = value);
                  }
                },
              ),
            ],
          ),
          // Display section
          ControlPanelSection(
            title: l10n.sectionDisplay,
            children: [
              ControlWidgets.toggle(
                label: l10n.settingShowWeekNumbers,
                value: _showWeekNumbers,
                onChanged: (value) => setState(() => _showWeekNumbers = value),
              ),
              ControlWidgets.slider(
                label: l10n.settingMaxVisibleEventsPerDay,
                value: _maxVisibleEventsPerDay.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (value) =>
                    setState(() => _maxVisibleEventsPerDay = value.toInt()),
              ),
            ],
          ),
          // Drag & Drop section
          ControlPanelSection(
            title: l10n.sectionDragAndDrop,
            children: [
              ControlWidgets.toggle(
                label: l10n.settingEnableDragToMove,
                value: _enableDragToMove,
                onChanged: (value) => setState(() => _enableDragToMove = value),
              ),
              ControlWidgets.toggle(
                label: l10n.settingShowDropTargetTiles,
                value: _showDropTargetTiles,
                onChanged: (value) =>
                    setState(() => _showDropTargetTiles = value),
              ),
              ControlWidgets.toggle(
                label: l10n.settingShowDropTargetOverlay,
                value: _showDropTargetOverlay,
                onChanged: (value) =>
                    setState(() => _showDropTargetOverlay = value),
              ),
              ControlWidgets.toggle(
                label: l10n.settingDropTargetTilesAboveOverlay,
                value: _dropTargetTilesAboveOverlay,
                onChanged: (value) =>
                    setState(() => _dropTargetTilesAboveOverlay = value),
              ),
              ControlWidgets.toggle(
                label: l10n.settingDragEdgeNavigationDelay,
                value: _dragEdgeNavigationEnabled,
                onChanged: (value) =>
                    setState(() => _dragEdgeNavigationEnabled = value),
              ),
              ControlWidgets.slider(
                label: l10n.settingDragEdgeNavigationDelay,
                value: _dragEdgeNavigationDelay.toDouble(),
                min: 300,
                max: 1500,
                divisions: 12,
                onChanged: (value) =>
                    setState(() => _dragEdgeNavigationDelay = value.toInt()),
              ),
              ControlWidgets.slider(
                label: l10n.settingDragLongPressDelay,
                value: _dragLongPressDelay.toDouble(),
                min: 200,
                max: 1000,
                divisions: 8,
                onChanged: (value) =>
                    setState(() => _dragLongPressDelay = value.toInt()),
              ),
            ],
          ),
          // Resize section
          ControlPanelSection(
            title: l10n.sectionResize,
            children: [
              ControlWidgets.triStateToggle(
                label: l10n.settingEnableDragToResize,
                value: _enableDragToResize,
                onChanged: (value) =>
                    setState(() => _enableDragToResize = value),
              ),
            ],
          ),
          // Animation section
          ControlPanelSection(
            title: l10n.sectionAnimation,
            children: [
              ControlWidgets.triStateToggle(
                label: l10n.settingEnableAnimations,
                value: _enableAnimations,
                onChanged: (value) => setState(() => _enableAnimations = value),
              ),
              ControlWidgets.slider(
                label: l10n.settingAnimationDuration,
                value: _animationDuration.toDouble(),
                min: 100,
                max: 1000,
                divisions: 9,
                onChanged: (value) =>
                    setState(() => _animationDuration = value.toInt()),
              ),
              ControlWidgets.dropdown<Curve>(
                label: l10n.settingAnimationCurve,
                value: _animationCurve,
                items: const [
                  DropdownMenuItem(
                    value: Curves.easeInOut,
                    child: Text('Ease In Out'), // TODO: Add ARB key valueEaseInOut
                  ),
                  DropdownMenuItem(
                    value: Curves.linear,
                    child: Text('Linear'), // TODO: Add ARB key valueLinear
                  ),
                  DropdownMenuItem(
                    value: Curves.easeIn,
                    child: Text('Ease In'), // TODO: Add ARB key valueEaseIn
                  ),
                  DropdownMenuItem(
                    value: Curves.easeOut,
                    child: Text('Ease Out'), // TODO: Add ARB key valueEaseOut
                  ),
                  DropdownMenuItem(
                    value: Curves.bounceInOut,
                    child: Text('Bounce In Out'), // TODO: Add ARB key valueBounceInOut
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _animationCurve = value);
                  }
                },
              ),
            ],
          ),
          // Keyboard section
          ControlPanelSection(
            title: l10n.sectionKeyboard,
            children: [
              ControlWidgets.toggle(
                label: l10n.settingEnableKeyboardNavigation,
                value: _enableKeyboardNavigation,
                onChanged: (value) =>
                    setState(() => _enableKeyboardNavigation = value),
              ),
              ControlWidgets.toggle(
                label: l10n.settingAutoFocusOnCellTap,
                value: _autoFocusOnCellTap,
                onChanged: (value) =>
                    setState(() => _autoFocusOnCellTap = value),
              ),
            ],
          ),
          // Blackout Days section
          ControlPanelSection(
            title: l10n.sectionBlackoutDays,
            children: [
              ControlWidgets.toggle(
                label: l10n.settingEnableBlackoutDays,
                value: _enableBlackoutDays,
                onChanged: (value) {
                  setState(() {
                    _enableBlackoutDays = value;
                    _updateBlackoutDates();
                  });
                },
              ),
              if (_enableBlackoutDays) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select days of week to block:', // TODO: Add ARB key for this instruction text
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildDayCheckbox('Mon', DateTime.monday), // TODO: Need short day names in ARB
                          _buildDayCheckbox('Tue', DateTime.tuesday),
                          _buildDayCheckbox('Wed', DateTime.wednesday),
                          _buildDayCheckbox('Thu', DateTime.thursday),
                          _buildDayCheckbox('Fri', DateTime.friday),
                          _buildDayCheckbox('Sat', DateTime.saturday),
                          _buildDayCheckbox('Sun', DateTime.sunday),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildDayCheckbox(String label, int weekday) {
    final isSelected = _blackoutDaysOfWeek.contains(weekday);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _blackoutDaysOfWeek.add(weekday);
          } else {
            _blackoutDaysOfWeek.remove(weekday);
          }
          _updateBlackoutDates();
        });
      },
    );
  }

  String _formatDate(DateTime date, Locale locale) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
