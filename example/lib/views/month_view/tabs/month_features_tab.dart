import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/utils/locale_utils.dart';
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
  const MonthFeaturesTab({super.key, required this.locale});

  final Locale locale;

  @override
  State<MonthFeaturesTab> createState() => _MonthFeaturesTabState();
}

class _MonthFeaturesTabState extends State<MonthFeaturesTab> {
  late MCalEventController _controller;

  // ============================================================
  // Navigation Settings
  // ============================================================
  bool _showNavigator = true;
  bool _enableSwipeNavigation = true;
  MCalSwipeNavigationDirection _swipeNavigationDirection =
      MCalSwipeNavigationDirection.horizontal;
  int _firstDayOfWeek = DateTime.sunday;

  // ============================================================
  // Display Settings
  // ============================================================
  bool _showWeekNumbers = false;
  int _maxVisibleEventsPerDay = 5;

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
  Curve _animationCurve = Curves.easeInOut;

  // ============================================================
  // Keyboard Settings
  // ============================================================
  bool _enableKeyboardNavigation = true;
  bool _autoFocusOnCellTap = true;

  // ============================================================
  // RTL Override Settings
  // ============================================================
  TextDirection? _textDirectionOverride;
  TextDirection? _layoutDirectionOverride;

  // ============================================================
  // Blackout Days Settings
  // ============================================================
  bool _enableBlackoutDays = false;
  final Set<int> _blackoutDaysOfWeek = {};
  late List<MCalDayRegion> _cachedDayRegions;

  // ============================================================
  // Status Label
  // ============================================================
  String _statusLabel = '—';

  @override
  void initState() {
    super.initState();
    _controller = MCalEventController(firstDayOfWeek: _firstDayOfWeek);
    _controller.addEvents(createSampleEvents());
    _cachedDayRegions = _buildDayRegions();
    // Async-update the first day of week from the current locale. The
    // controller starts with the default (Sunday) and is replaced once the
    // locale data resolves.
    _syncFirstDayOfWeekFromLocale(widget.locale);
  }

  @override
  void didUpdateWidget(MonthFeaturesTab oldWidget) {
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
      _controller.firstDayOfWeek = fdow;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _rruleDayNames = {
    DateTime.monday: 'MO',
    DateTime.tuesday: 'TU',
    DateTime.wednesday: 'WE',
    DateTime.thursday: 'TH',
    DateTime.friday: 'FR',
    DateTime.saturday: 'SA',
    DateTime.sunday: 'SU',
  };

  /// Builds the list of [MCalDayRegion]s for the currently selected blackout
  /// days of week.  Each selected weekday becomes a recurring weekly region.
  List<MCalDayRegion> _buildDayRegions() {
    if (!_enableBlackoutDays || _blackoutDaysOfWeek.isEmpty) return [];

    return _blackoutDaysOfWeek.map((weekday) {
      final byDay = _rruleDayNames[weekday]!;
      return MCalDayRegion(
        id: 'blackout-$weekday',
        // Anchor: 2025-01-01 is before any displayed month; BYDAY handles filtering.
        date: DateTime(2025, 1, 1),
        recurrenceRule: 'FREQ=WEEKLY;BYDAY=$byDay',
        color: Colors.grey.withValues(alpha: 0.25),
        text: 'Blocked',
        icon: Icons.block,
        blockInteraction: true,
      );
    }).toList();
  }

  void _setStatus(String message) {
    setState(() => _statusLabel = message);
  }

  Widget _buildStatusLabel(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _statusLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return ResponsiveControlPanel(
      controlPanelTitle: l10n.featureSettings,
      controlPanel: _buildControlPanel(l10n),
      child: Column(
        children: [
          _buildStatusLabel(context),
          Expanded(
            child: MCalMonthView(
              controller: _controller,
              // Navigation
              showNavigator: _showNavigator,
              onDisplayDateChanged: null,
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
              dragEdgeNavigationDelay: _dragEdgeNavigationDelay,
              dragLongPressDelay: _dragLongPressDelay,
              // Resize
              enableDragToResize: _enableDragToResize,
              // Animation
              enableAnimations: _enableAnimations,
              animationDuration: _animationDuration,
              animationCurve: _animationCurve,
              // Keyboard
              enableKeyboardNavigation: _enableKeyboardNavigation,
              autoFocusOnCellTap: _autoFocusOnCellTap,
              // RTL Override
              textDirection: _textDirectionOverride,
              layoutDirection: _layoutDirectionOverride,
              // Day regions (blackout days)
              dayRegions: _cachedDayRegions,
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
                  l10n.snackbarDateLabelLongPress(
                    _formatDate(details.date, locale),
                  ),
                );
              },
              onEventTap: (ctx, details) {
                showEventDetailDialog(context, details.event, locale);
              },
              onEventLongPress: (ctx, details) {
                SnackBarHelper.show(
                  context,
                  l10n.snackbarEventLongPress(details.event.title),
                );
              },
              onEventDoubleTap: (ctx, details) {
                SnackBarHelper.show(
                  context,
                  l10n.snackbarEventDoubleTap(details.event.title),
                );
              },
              onOverflowTap: (ctx, details) {
                showDayEventsBottomSheet(
                  context,
                  details.date,
                  details.allEvents,
                  locale,
                );
              },
              onOverflowLongPress: (ctx, details) {
                SnackBarHelper.show(
                  context,
                  l10n.snackbarOverflowLongPress(
                    _formatDate(details.date, locale),
                    details.hiddenEventCount,
                  ),
                );
              },
              onHoverCell: (context, cellContext) {
                if (cellContext != null) {
                  _setStatus('Cell: ${_formatDate(cellContext.date, locale)}');
                } else {
                  _setStatus('—');
                }
              },
              onHoverEvent: (context, eventContext) {
                if (eventContext != null) {
                  _setStatus('Event: ${eventContext.event.title}');
                } else {
                  _setStatus('—');
                }
              },
              onDragWillAccept: (ctx, details) {
                // Blocked days are rejected by the library before this callback is
                // reached, so any date arriving here is already allowed.
                _setStatus(
                  'Drop → ${_formatDate(details.proposedStartDate, locale)} (${details.event.title})',
                );
                return true;
              },
              onEventDropped: (ctx, details) {
                SnackBarHelper.show(
                  context,
                  l10n.snackbarEventDropped(
                    details.event.title,
                    _formatDate(details.newStartDate, locale),
                  ),
                );
                return true;
              },
              onResizeWillAccept: (ctx, details) {
                // Could add validation logic here
                return true;
              },
              onEventResized: (ctx, details) {
                final days =
                    details.newEndDate.difference(details.newStartDate).inDays +
                    1;
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
                SnackBarHelper.show(
                  context,
                  l10n.snackbarSwipeNavigation(details.direction.name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Navigation Section
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
                  setState(() {
                    _firstDayOfWeek = value;
                    _controller.firstDayOfWeek = value;
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
        // Drag & Drop Section
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
              label: l10n.settingDragEdgeNavigationEnabled,
              value: _dragEdgeNavigationEnabled,
              onChanged: (value) =>
                  setState(() => _dragEdgeNavigationEnabled = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingDragEdgeNavigationDelay,
              value: _dragEdgeNavigationDelay.inMilliseconds.toDouble(),
              min: 500,
              max: 2000,
              divisions: 12,
              onChanged: (value) => setState(
                () => _dragEdgeNavigationDelay = Duration(
                  milliseconds: value.toInt(),
                ),
              ),
              valueLabel: '${_dragEdgeNavigationDelay.inMilliseconds}ms',
            ),
            ControlWidgets.slider(
              label: l10n.settingDragLongPressDelay,
              value: _dragLongPressDelay.inMilliseconds.toDouble(),
              min: 100,
              max: 1000,
              divisions: 8,
              onChanged: (value) => setState(
                () =>
                    _dragLongPressDelay = Duration(milliseconds: value.toInt()),
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
              onChanged: (value) => setState(() => _enableDragToResize = value),
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
              onChanged: (value) => setState(() => _enableAnimations = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingAnimationDuration,
              value: _animationDuration.inMilliseconds.toDouble(),
              min: 100,
              max: 1000,
              divisions: 9,
              onChanged: (value) => setState(
                () =>
                    _animationDuration = Duration(milliseconds: value.toInt()),
              ),
              valueLabel: '${_animationDuration.inMilliseconds}ms',
            ),
            ControlWidgets.dropdown<Curve>(
              label: l10n.settingAnimationCurve,
              value: _animationCurve,
              items: const [
                DropdownMenuItem(
                  value: Curves.easeInOut,
                  child: Text(
                    'Ease In Out',
                  ), // TODO: Add ARB key valueEaseInOut
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
                  child: Text(
                    'Bounce In Out',
                  ), // TODO: Add ARB key valueBounceInOut
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
        // Keyboard Section
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
              onChanged: (value) => setState(() => _autoFocusOnCellTap = value),
            ),
          ],
        ),

        // RTL Override Section
        ControlPanelSection(
          title: 'RTL Override', // TODO: Add ARB key sectionRtlOverride
          children: [
            ControlWidgets.dropdown<TextDirection?>(
              label: 'Text Direction', // TODO: Add ARB key settingTextDirection
              value: _textDirectionOverride,
              items: const [
                DropdownMenuItem(value: null, child: Text('Inherit')),
                DropdownMenuItem(value: TextDirection.ltr, child: Text('LTR')),
                DropdownMenuItem(value: TextDirection.rtl, child: Text('RTL')),
              ],
              onChanged: (v) => setState(() => _textDirectionOverride = v),
            ),
            ControlWidgets.dropdown<TextDirection?>(
              label:
                  'Layout Direction', // TODO: Add ARB key settingLayoutDirection
              value: _layoutDirectionOverride,
              items: const [
                DropdownMenuItem(value: null, child: Text('Inherit')),
                DropdownMenuItem(value: TextDirection.ltr, child: Text('LTR')),
                DropdownMenuItem(value: TextDirection.rtl, child: Text('RTL')),
              ],
              onChanged: (v) => setState(() => _layoutDirectionOverride = v),
            ),
          ],
        ),

        // Blackout Days Section
        ControlPanelSection(
          title: l10n.sectionBlackoutDays,
          children: [
            ControlWidgets.toggle(
              label: l10n.settingEnableBlackoutDays,
              value: _enableBlackoutDays,
              onChanged: (value) {
                setState(() {
                  _enableBlackoutDays = value;
                  _cachedDayRegions = _buildDayRegions();
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
                        _buildDayCheckbox(
                          'Mon',
                          DateTime.monday,
                        ), // TODO: Need short day names in ARB
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
          _cachedDayRegions = _buildDayRegions();
        });
      },
    );
  }

  String _formatDate(DateTime date, Locale locale) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
