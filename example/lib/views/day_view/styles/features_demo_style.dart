import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../widgets/event_detail_dialog.dart';
import '../../../widgets/day_view_crud_helper.dart';
import '../../../widgets/style_description.dart';

/// Preset configuration for Day View.
enum DayViewPreset {
  custom,
  compact,
  standard,
  spacious,
  minimal,
  highContrast,
}

/// Features Demo Day View - comprehensive showcase of ALL Day View capabilities.
///
/// Demonstrates:
/// - **Interactive control panel**: Sliders, toggles, dropdowns for all theme properties
/// - **Special time regions**: Lunch break (12–13), non-working hours (18–24), focus time (9–10)
/// - **Blocked time slots**: After-hours and focus regions block event drops
/// - **Custom time region builder**: Styled lunch and blocked zones
/// - **Drag-drop**: Move events; drops to blocked regions are rejected
/// - **Resize**: Resize from event edges
/// - **Snap-to-time**: Configurable 5/10/15/20/30/60-minute snapping
/// - **Preset configurations**: Compact, Standard, Spacious, Minimal, High Contrast
/// - **Code snippet panel**: Copy MCalThemeData construction code
/// - **Keyboard navigation**: Tab, arrows, Enter, Cmd+N/E/D
/// - **Full CRUD**: Double-tap create, tap edit/delete
class FeaturesDemoDayStyle extends StatefulWidget {
  const FeaturesDemoDayStyle({
    super.key,
    required this.eventController,
    required this.locale,
    required this.isDarkMode,
    required this.description,
  });

  final MCalEventController eventController;
  final Locale locale;
  final bool isDarkMode;
  final String description;

  @override
  State<FeaturesDemoDayStyle> createState() => _FeaturesDemoDayStyleState();
}

class _FeaturesDemoDayStyleState extends State<FeaturesDemoDayStyle>
    with DayViewCrudHelper<FeaturesDemoDayStyle> {
  @override
  MCalEventController get eventController => widget.eventController;

  @override
  Locale get locale => widget.locale;

  // ============================================================
  // Control Panel State - Theme Properties
  // ============================================================
  double _hourHeight = 80.0;
  double _timeLegendWidth = 60.0;
  bool _showTimeLegendTicks = true;
  Color _timeLegendTickColor = Colors.grey.withValues(alpha: 0.5);
  double _timeLegendTickWidth = 1.0;
  double _timeLegendTickLength = 8.0;
  Color _hourGridlineColor = Colors.grey.withValues(alpha: 0.2);
  double _hourGridlineWidth = 1.0;
  Color _majorGridlineColor = Colors.grey.withValues(alpha: 0.15);
  Color _currentTimeIndicatorColor = Colors.blue;
  double _currentTimeIndicatorWidth = 2.5;
  Color _specialTimeRegionColor = Colors.blue.withValues(alpha: 0.1);
  Color _blockedTimeRegionColor = Colors.red.withValues(alpha: 0.2);

  // ============================================================
  // Control Panel State - Gridlines & Intervals
  // ============================================================
  int _gridlineIntervalMinutes = 15;

  // ============================================================
  // Control Panel State - Interactions
  // ============================================================
  bool _enableDragToMove = true;
  bool _enableDragToResize = true;
  bool _snapToTimeSlots = true;
  bool _showCurrentTimeIndicator = true;
  bool _showNavigator = true;

  // ============================================================
  // Control Panel State - Special Time Regions
  // ============================================================
  bool _showLunchRegion = true;
  bool _showAfterHoursRegion = true;
  bool _showFocusTimeRegion = true;

  // ============================================================
  // Control Panel UI State
  // ============================================================
  DayViewPreset _selectedPreset = DayViewPreset.standard;
  bool _showControls = true;
  bool _showCodeSnippet = false;

  static const List<int> _gridlineIntervalOptions = [5, 10, 15, 20, 30, 60];

  /// Build special time regions for the display date based on toggles.
  List<MCalTimeRegion> _buildTimeRegions() {
    final d = eventController.displayDate;
    final regions = <MCalTimeRegion>[];

    if (_showLunchRegion) {
      regions.add(
        MCalTimeRegion(
          id: 'lunch',
          startTime: DateTime(d.year, d.month, d.day, 12, 0),
          endTime: DateTime(d.year, d.month, d.day, 13, 0),
          color: Colors.amber.withValues(alpha: 0.25),
          text: 'Lunch Break',
          icon: Icons.restaurant,
          blockInteraction: false,
        ),
      );
    }

    if (_showAfterHoursRegion) {
      regions.add(
        MCalTimeRegion(
          id: 'after-hours',
          startTime: DateTime(d.year, d.month, d.day, 18, 0),
          endTime: DateTime(d.year, d.month, d.day, 24, 0),
          color: Colors.grey.withValues(alpha: 0.4),
          text: 'After Hours (blocked)',
          icon: Icons.block,
          blockInteraction: true,
        ),
      );
    }

    if (_showFocusTimeRegion) {
      regions.add(
        MCalTimeRegion(
          id: 'focus-time',
          startTime: DateTime(d.year, d.month, d.day, 9, 0),
          endTime: DateTime(d.year, d.month, d.day, 10, 0),
          color: Colors.blue.withValues(alpha: 0.15),
          text: 'Focus Time (no meetings)',
          icon: Icons.psychology,
          blockInteraction: true,
        ),
      );
    }

    return regions;
  }

  /// Build MCalThemeData from current state (uses nested theme.dayTheme).
  MCalThemeData _buildTheme(ColorScheme colorScheme) {
    return MCalThemeData(
      dayTheme: MCalDayThemeData(
        timeLegendWidth: _timeLegendWidth,
        showTimeLegendTicks: _showTimeLegendTicks,
        timeLegendTickColor: _timeLegendTickColor,
        timeLegendTickWidth: _timeLegendTickWidth,
        timeLegendTickLength: _timeLegendTickLength,
        hourGridlineColor: _hourGridlineColor,
        hourGridlineWidth: _hourGridlineWidth,
        majorGridlineColor: _majorGridlineColor,
        majorGridlineWidth: 1.0,
        minorGridlineColor: colorScheme.outline.withValues(alpha: 0.08),
        minorGridlineWidth: 0.5,
        currentTimeIndicatorColor: _currentTimeIndicatorColor,
        currentTimeIndicatorWidth: _currentTimeIndicatorWidth,
        timeLegendBackgroundColor: colorScheme.surfaceContainerHighest,
        timeLegendTextStyle: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
        ),
        blockedTimeRegionColor: _blockedTimeRegionColor,
        specialTimeRegionColor: _specialTimeRegionColor,
      ),
    );
  }

  void _applyPreset(DayViewPreset preset) {
    setState(() {
      _selectedPreset = preset;
      switch (preset) {
        case DayViewPreset.compact:
          _hourHeight = 60.0;
          _gridlineIntervalMinutes = 30;
          _timeLegendTickLength = 4.0;
          _showTimeLegendTicks = true;
          _hourGridlineWidth = 1.0;
          break;
        case DayViewPreset.standard:
          _hourHeight = 80.0;
          _gridlineIntervalMinutes = 15;
          _timeLegendTickLength = 8.0;
          _showTimeLegendTicks = true;
          _hourGridlineWidth = 1.0;
          break;
        case DayViewPreset.spacious:
          _hourHeight = 100.0;
          _gridlineIntervalMinutes = 15;
          _timeLegendTickLength = 12.0;
          _showTimeLegendTicks = true;
          _hourGridlineWidth = 1.0;
          break;
        case DayViewPreset.minimal:
          _hourHeight = 80.0;
          _gridlineIntervalMinutes = 30;
          _showTimeLegendTicks = false;
          _timeLegendTickLength = 0.0;
          _hourGridlineColor = Colors.grey.withValues(alpha: 0.08);
          _majorGridlineColor = Colors.grey.withValues(alpha: 0.05);
          _currentTimeIndicatorColor = Colors.grey;
          _currentTimeIndicatorWidth = 1.5;
          break;
        case DayViewPreset.highContrast:
          _hourHeight = 80.0;
          _gridlineIntervalMinutes = 15;
          _timeLegendTickLength = 16.0;
          _showTimeLegendTicks = true;
          _timeLegendTickWidth = 2.0;
          _hourGridlineWidth = 2.0;
          _hourGridlineColor = Colors.black.withValues(alpha: 0.4);
          _majorGridlineColor = Colors.black.withValues(alpha: 0.3);
          _currentTimeIndicatorColor = Colors.red;
          _currentTimeIndicatorWidth = 4.0;
          break;
        case DayViewPreset.custom:
          break;
      }
    });
  }

  String _generateCodeSnippet(ColorScheme colorScheme) {
    final sb = StringBuffer();
    sb.writeln('MCalThemeData(');
    sb.writeln('  dayTheme: MCalDayThemeData(');
    sb.writeln('    timeLegendWidth: $_timeLegendWidth,');
    sb.writeln('    showTimeLegendTicks: $_showTimeLegendTicks,');
    sb.writeln('    timeLegendTickColor: Color(0x${_timeLegendTickColor.toARGB32().toRadixString(16)}),');
    sb.writeln('    timeLegendTickWidth: $_timeLegendTickWidth,');
    sb.writeln('    timeLegendTickLength: $_timeLegendTickLength,');
    sb.writeln('    hourGridlineColor: Color(0x${_hourGridlineColor.toARGB32().toRadixString(16)}),');
    sb.writeln('    hourGridlineWidth: $_hourGridlineWidth,');
    sb.writeln('    majorGridlineColor: Color(0x${_majorGridlineColor.toARGB32().toRadixString(16)}),');
    sb.writeln('    currentTimeIndicatorColor: Color(0x${_currentTimeIndicatorColor.toARGB32().toRadixString(16)}),');
    sb.writeln('    currentTimeIndicatorWidth: $_currentTimeIndicatorWidth,');
    sb.writeln('    blockedTimeRegionColor: Color(0x${_blockedTimeRegionColor.toARGB32().toRadixString(16)}),');
    sb.writeln('    specialTimeRegionColor: Color(0x${_specialTimeRegionColor.toARGB32().toRadixString(16)}),');
    sb.writeln('  ),');
    sb.writeln(')');
    return sb.toString();
  }

  void _copyCodeToClipboard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final code = _generateCodeSnippet(colorScheme);
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;
        final isDesktop = constraints.maxWidth > 900;

        return Column(
          children: [
            StyleDescription(description: widget.description),
            // Keyboard shortcuts hint bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              child: Wrap(
                spacing: 10,
                runSpacing: 2,
                alignment: WrapAlignment.center,
                children: [
                  _shortcutChip('Tab', 'Focus events', colorScheme),
                  _shortcutChip('↑↓', 'Move event', colorScheme),
                  _shortcutChip('R', 'Resize mode', colorScheme),
                  _shortcutChip('Cmd+N', 'Create', colorScheme),
                  _shortcutChip('Cmd+E', 'Edit', colorScheme),
                  _shortcutChip('Cmd+D', 'Delete', colorScheme),
                  _shortcutChip('Double-tap', 'Create at slot', colorScheme),
                ],
              ),
            ),
            // Control panel
            _buildControlPanel(colorScheme, isDesktop),
            Expanded(
              child: isWideScreen
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildDayView(colorScheme),
                        ),
                        if (_showCodeSnippet && isDesktop)
                          Container(
                            width: 320,
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerLow,
                              border: Border.all(
                                color: colorScheme.outlineVariant,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _buildCodeSnippetPanel(colorScheme),
                          ),
                      ],
                    )
                  : _buildDayView(colorScheme),
            ),
            if (_showCodeSnippet && !isDesktop)
              Container(
                height: 180,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  border: Border.all(color: colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildCodeSnippetPanel(colorScheme),
              ),
          ],
        );
      },
    );
  }

  Widget _buildControlPanel(ColorScheme colorScheme, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(100),
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row: expand toggle + preset dropdown + code snippet toggle - scrollable to prevent overflow
          ClipRect(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _showControls ? Icons.expand_less : Icons.tune,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    onPressed: () =>
                        setState(() => _showControls = !_showControls),
                    tooltip: _showControls ? 'Hide controls' : 'Show controls',
                  ),
                  const SizedBox(width: 8),
                  // Preset dropdown
                  Container(
                    width: 160,
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.outline),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButton<DayViewPreset>(
                      value: _selectedPreset,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: DayViewPreset.values
                          .map((preset) => DropdownMenuItem(
                                value: preset,
                                child: Text(
                                  _presetLabel(preset),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) _applyPreset(v);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Code snippet toggle
                  _buildCompactToggle(
                    'Code',
                    _showCodeSnippet,
                    (v) => setState(() => _showCodeSnippet = v),
                    colorScheme,
                    fontSize: 11,
                  ),
                ],
              ),
            ),
          ),
          if (_showControls) ...[
            const SizedBox(height: 12),
            // Collapsible sections
            Column(
              children: [
                _buildSection(
                  'Theme Properties',
                  Icons.palette_outlined,
                  [
                    _buildSliderRow(
                      'Hour height',
                      _hourHeight,
                      60,
                      120,
                      12,
                      (v) => setState(() {
                            _hourHeight = v;
                            _selectedPreset = DayViewPreset.custom;
                          }),
                      colorScheme,
                      suffix: 'px',
                    ),
                    _buildSliderRow(
                      'Time legend width',
                      _timeLegendWidth,
                      40,
                      100,
                      12,
                      (v) => setState(() {
                            _timeLegendWidth = v;
                            _selectedPreset = DayViewPreset.custom;
                          }),
                      colorScheme,
                      suffix: 'px',
                    ),
                    _buildCompactToggle(
                      'Time legend ticks',
                      _showTimeLegendTicks,
                      (v) => setState(() {
                            _showTimeLegendTicks = v;
                            _selectedPreset = DayViewPreset.custom;
                          }),
                      colorScheme,
                    ),
                    _buildSliderRow(
                      'Tick length',
                      _timeLegendTickLength,
                      4,
                      16,
                      12,
                      (v) => setState(() {
                            _timeLegendTickLength = v;
                            _selectedPreset = DayViewPreset.custom;
                          }),
                      colorScheme,
                      suffix: 'px',
                    ),
                    _buildSliderRow(
                      'Current time width',
                      _currentTimeIndicatorWidth,
                      1,
                      5,
                      8,
                      (v) => setState(() {
                            _currentTimeIndicatorWidth = v;
                            _selectedPreset = DayViewPreset.custom;
                          }),
                      colorScheme,
                      suffix: 'px',
                    ),
                    _buildColorRow(
                      'Tick color',
                      _timeLegendTickColor,
                      (v) => setState(() {
                            _timeLegendTickColor = v;
                            _selectedPreset = DayViewPreset.custom;
                          }),
                      colorScheme,
                    ),
                    _buildColorRow(
                      'Current time',
                      _currentTimeIndicatorColor,
                      (v) => setState(() {
                            _currentTimeIndicatorColor = v;
                            _selectedPreset = DayViewPreset.custom;
                          }),
                      colorScheme,
                    ),
                  ],
                  colorScheme,
                ),
                _buildSection(
                  'Gridlines & Intervals',
                  Icons.grid_on,
                  [
                    _buildDropdownRow(
                      'Gridline interval',
                      _gridlineIntervalMinutes,
                      _gridlineIntervalOptions,
                      (v) => setState(() {
                            _gridlineIntervalMinutes = v;
                            _selectedPreset = DayViewPreset.custom;
                      }),
                  colorScheme,
                  (v) => '$v min',
                ),
                    _buildSliderRow(
                      'Hour gridline width',
                      _hourGridlineWidth,
                      0.5,
                      3,
                      5,
                      (v) => setState(() {
                            _hourGridlineWidth = v;
                            _selectedPreset = DayViewPreset.custom;
                          }),
                      colorScheme,
                      suffix: 'px',
                    ),
                    _buildColorRow(
                      'Hour gridline',
                      _hourGridlineColor,
                      (v) => setState(() {
                            _hourGridlineColor = v;
                            _selectedPreset = DayViewPreset.custom;
                          }),
                      colorScheme,
                    ),
                  ],
                  colorScheme,
                ),
                _buildSection(
                  'Interactions',
                  Icons.touch_app,
                  [
                    _buildCompactToggle(
                      'Drag to move',
                      _enableDragToMove,
                      (v) => setState(() => _enableDragToMove = v),
                      colorScheme,
                    ),
                    _buildCompactToggle(
                      'Drag to resize',
                      _enableDragToResize,
                      (v) => setState(() => _enableDragToResize = v),
                      colorScheme,
                    ),
                    _buildCompactToggle(
                      'Snap to slots',
                      _snapToTimeSlots,
                      (v) => setState(() => _snapToTimeSlots = v),
                      colorScheme,
                    ),
                    _buildCompactToggle(
                      'Current time indicator',
                      _showCurrentTimeIndicator,
                      (v) => setState(() => _showCurrentTimeIndicator = v),
                      colorScheme,
                    ),
                    _buildCompactToggle(
                      'Navigator',
                      _showNavigator,
                      (v) => setState(() => _showNavigator = v),
                      colorScheme,
                    ),
                  ],
                  colorScheme,
                ),
                _buildSection(
                  'Special Time Regions',
                  Icons.schedule,
                  [
                    _buildCompactToggle(
                      'Lunch (12–13)',
                      _showLunchRegion,
                      (v) => setState(() => _showLunchRegion = v),
                      colorScheme,
                    ),
                    _buildCompactToggle(
                      'After hours (18–24)',
                      _showAfterHoursRegion,
                      (v) => setState(() => _showAfterHoursRegion = v),
                      colorScheme,
                    ),
                    _buildCompactToggle(
                      'Focus time (9–10)',
                      _showFocusTimeRegion,
                      (v) => setState(() => _showFocusTimeRegion = v),
                      colorScheme,
                    ),
                    _buildColorRow(
                      'Special region',
                      _specialTimeRegionColor,
                      (v) => setState(() => _specialTimeRegionColor = v),
                      colorScheme,
                    ),
                    _buildColorRow(
                      'Blocked region',
                      _blockedTimeRegionColor,
                      (v) => setState(() => _blockedTimeRegionColor = v),
                      colorScheme,
                    ),
                  ],
                  colorScheme,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    IconData icon,
    List<Widget> children,
    ColorScheme colorScheme,
  ) {
    return ExpansionTile(
      leading: Icon(icon, size: 20, color: colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children
                .map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: c,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDayView(ColorScheme colorScheme) {
    final regions = _buildTimeRegions();
    final gridlineInterval =
        Duration(minutes: _gridlineIntervalMinutes);

    return ListenableBuilder(
      listenable: eventController,
      builder: (context, _) {
        return MCalTheme(
          data: _buildTheme(colorScheme),
          child: MCalDayView(
            controller: widget.eventController,
            startHour: 6,
            endHour: 24,
            hourHeight: _hourHeight,
            gridlineInterval: gridlineInterval,
            timeSlotDuration: gridlineInterval,
            enableDragToMove: _enableDragToMove,
            enableDragToResize: _enableDragToResize,
            snapToTimeSlots: _snapToTimeSlots,
            showNavigator: _showNavigator,
            showCurrentTimeIndicator: _showCurrentTimeIndicator,
            enableKeyboardNavigation: true,
            specialTimeRegions: regions,
            timeRegionBuilder: (context, ctx) => _buildTimeRegion(ctx),
            locale: widget.locale,
            onEventTap: (context, details) {
              showEventDetailDialog(
                context,
                details.event,
                widget.locale,
                onEdit: () => handleEditEvent(details.event),
                onDelete: () => handleDeleteEvent(details.event),
              );
            },
            onEventDropped: (details) {
              if (mounted) {
                final t = details.newStartDate;
                showCrudSnackBar(
                  'Moved: ${details.event.title} to '
                  '${t.hour}:${t.minute.toString().padLeft(2, '0')}',
                );
              }
            },
            onEventResized: (details) {
              if (mounted) {
                showCrudSnackBar(
                  'Resized: ${details.event.title} to '
                  '${details.newEndDate.difference(details.newStartDate).inMinutes} min',
                );
              }
            },
            onEmptySpaceDoubleTap: (time) => handleCreateEvent(time),
            onCreateEventRequested: handleCreateEventAtDefaultTime,
            onEditEventRequested: (event) => handleEditEvent(event),
            onDeleteEventRequested: (event) => handleDeleteEvent(event),
          ),
        );
      },
    );
  }

  Widget _buildCodeSnippetPanel(ColorScheme colorScheme) {
    final code = _generateCodeSnippet(colorScheme);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(80),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.code, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Theme Code',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () => _copyCodeToClipboard(context),
                tooltip: 'Copy to clipboard',
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(4),
                  minimumSize: const Size(32, 32),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              code,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeRegion(MCalTimeRegionContext ctx) {
    final colorScheme = Theme.of(context).colorScheme;
    final region = ctx.region;
    final isBlocked = region.blockInteraction;
    final bgColor = region.color ??
        (isBlocked
            ? (colorScheme.error.withValues(alpha: 0.15))
            : colorScheme.primaryContainer.withValues(alpha: 0.2));

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          left: BorderSide(
            color: isBlocked
                ? colorScheme.error.withValues(alpha: 0.5)
                : colorScheme.primary.withValues(alpha: 0.4),
            width: 3,
          ),
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (region.icon != null)
              Icon(
                region.icon,
                size: 16,
                color: isBlocked
                    ? colorScheme.error.withValues(alpha: 0.8)
                    : colorScheme.primary.withValues(alpha: 0.8),
              ),
            if (region.icon != null) const SizedBox(width: 6),
            if (region.text != null && region.text!.isNotEmpty)
              Text(
                region.text!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isBlocked
                      ? colorScheme.error.withValues(alpha: 0.9)
                      : colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _presetLabel(DayViewPreset preset) {
    return switch (preset) {
      DayViewPreset.compact => 'Compact',
      DayViewPreset.standard => 'Standard',
      DayViewPreset.spacious => 'Spacious',
      DayViewPreset.minimal => 'Minimal',
      DayViewPreset.highContrast => 'High Contrast',
      DayViewPreset.custom => 'Custom',
    };
  }

  Widget _shortcutChip(String key, String action, ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            key,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          action,
          style: TextStyle(
            fontSize: 10,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // Helper widgets for control panel
  Widget _buildCompactToggle(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
    ColorScheme colorScheme, {
    double fontSize = 13,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 4),
        Switch(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }

  Widget _buildSliderRow(
    String label,
    double value,
    double min,
    double max,
    int divisions,
    ValueChanged<double> onChanged,
    ColorScheme colorScheme, {
    String suffix = 'px',
  }) {
    final displayValue =
        suffix.isEmpty ? value.toStringAsFixed(1) : '${value.toInt()}$suffix';
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(
            '$label: $displayValue',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownRow<T>(
    String label,
    T value,
    List<T> items,
    ValueChanged<T> onChanged,
    ColorScheme colorScheme,
    String Function(T) itemLabel,
  ) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<T>(
            value: value,
            isDense: true,
            isExpanded: true,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface,
            ),
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        itemLabel(item),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorRow(
    String label,
    Color color,
    ValueChanged<Color> onChanged,
    ColorScheme colorScheme,
  ) {
    final colors = [
      Colors.grey,
      Colors.blue,
      Colors.red,
      Colors.amber,
      Colors.green,
      Colors.purple,
      Colors.orange,
      colorScheme.outline,
    ];
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: colors.map((c) {
            final isSelected = _colorsClose(color, c);
            return GestureDetector(
              onTap: () => onChanged(c.withValues(
                alpha: color.a,
              )),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: colorScheme.primary,
                          width: 2,
                        )
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  bool _colorsClose(Color a, Color b) {
    final aRed = (a.r * 255.0).round();
    final bRed = (b.r * 255.0).round();
    final aGreen = (a.g * 255.0).round();
    final bGreen = (b.g * 255.0).round();
    final aBlue = (a.b * 255.0).round();
    final bBlue = (b.b * 255.0).round();
    return (aRed - bRed).abs() < 30 &&
        (aGreen - bGreen).abs() < 30 &&
        (aBlue - bBlue).abs() < 30;
  }
}
