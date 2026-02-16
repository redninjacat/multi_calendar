import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/responsive_control_panel.dart';
import '../../../shared/widgets/control_panel_section.dart';
import '../../../shared/widgets/control_widgets.dart';
import '../../../shared/utils/theme_presets.dart';
import '../../../shared/utils/sample_events.dart';

/// Month View Theme customization tab.
///
/// Provides live theming controls for MCalMonthView with preset selection
/// and granular property customization organized into logical sections.
class MonthThemeTab extends StatefulWidget {
  const MonthThemeTab({super.key});

  @override
  State<MonthThemeTab> createState() => _MonthThemeTabState();
}

class _MonthThemeTabState extends State<MonthThemeTab> {
  late MCalEventController _controller;
  
  // Current preset selection
  ThemePreset _selectedPreset = ThemePreset.defaultPreset;
  
  // Theme properties - initialized from default preset
  late Color _cellBackgroundColor;
  late Color _cellBorderColor;
  late Color _todayBackgroundColor;
  late Color _eventTileBackgroundColor;
  late double _eventTileHeight;
  late double _eventTileCornerRadius;
  late double _eventTileHorizontalSpacing;
  late double _eventTileVerticalSpacing;
  late double _eventTileBorderWidth;
  bool _ignoreEventColors = false;
  late Color _weekdayHeaderBackgroundColor;
  late double _dateLabelHeight;
  DateLabelPosition _dateLabelPosition = DateLabelPosition.topLeft;
  late double _overflowIndicatorHeight;
  late Color _navigatorBackgroundColor;
  late Color _dropTargetCellValidColor;
  late Color _dropTargetCellInvalidColor;
  late double _dragSourceOpacity;
  late double _draggedTileElevation;
  late Color _hoverCellBackgroundColor;
  late Color _hoverEventBackgroundColor;
  late Color _weekNumberBackgroundColor;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _controller = MCalEventController(initialDate: now);
    _controller.addEvents(createSampleEvents());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize theme values from default preset
    _loadPreset(_selectedPreset);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadPreset(ThemePreset preset) {
    final theme = Theme.of(context);
    final presetTheme = getMonthThemePreset(preset, theme);
    final colorScheme = theme.colorScheme;
    
    setState(() {
      _selectedPreset = preset;
      _cellBackgroundColor = presetTheme.cellBackgroundColor ?? colorScheme.surface;
      _cellBorderColor = presetTheme.cellBorderColor ?? colorScheme.outline.withValues(alpha: 0.2);
      _todayBackgroundColor = presetTheme.monthTheme?.todayBackgroundColor ?? colorScheme.primary.withValues(alpha: 0.1);
      _eventTileBackgroundColor = presetTheme.eventTileBackgroundColor ?? colorScheme.primaryContainer;
      _eventTileHeight = presetTheme.monthTheme?.eventTileHeight ?? 20.0;
      _eventTileCornerRadius = presetTheme.eventTileCornerRadius ?? 3.0;
      _eventTileHorizontalSpacing = presetTheme.eventTileHorizontalSpacing ?? 1.0;
      _eventTileVerticalSpacing = presetTheme.monthTheme?.eventTileVerticalSpacing ?? 1.0;
      _eventTileBorderWidth = presetTheme.monthTheme?.eventTileBorderWidth ?? 0.0;
      _weekdayHeaderBackgroundColor = presetTheme.monthTheme?.weekdayHeaderBackgroundColor ?? colorScheme.surfaceContainerHighest;
      _dateLabelHeight = presetTheme.monthTheme?.dateLabelHeight ?? 18.0;
      _dateLabelPosition = presetTheme.monthTheme?.dateLabelPosition ?? DateLabelPosition.topLeft;
      _overflowIndicatorHeight = presetTheme.monthTheme?.overflowIndicatorHeight ?? 14.0;
      _navigatorBackgroundColor = presetTheme.navigatorBackgroundColor ?? colorScheme.surface;
      _dropTargetCellValidColor = presetTheme.monthTheme?.dropTargetCellValidColor ?? Colors.green.withValues(alpha: 0.3);
      _dropTargetCellInvalidColor = presetTheme.monthTheme?.dropTargetCellInvalidColor ?? Colors.red.withValues(alpha: 0.3);
      _dragSourceOpacity = presetTheme.monthTheme?.dragSourceOpacity ?? 0.5;
      _draggedTileElevation = presetTheme.monthTheme?.draggedTileElevation ?? 6.0;
      _hoverCellBackgroundColor = presetTheme.monthTheme?.hoverCellBackgroundColor ?? colorScheme.primary.withValues(alpha: 0.05);
      _hoverEventBackgroundColor = presetTheme.monthTheme?.hoverEventBackgroundColor ?? colorScheme.primaryContainer.withValues(alpha: 0.8);
      _weekNumberBackgroundColor = presetTheme.weekNumberBackgroundColor ?? colorScheme.surfaceContainerHighest;
    });
  }

  MCalThemeData _buildThemeData() {
    return MCalThemeData(
      cellBackgroundColor: _cellBackgroundColor,
      cellBorderColor: _cellBorderColor,
      eventTileBackgroundColor: _eventTileBackgroundColor,
      eventTileCornerRadius: _eventTileCornerRadius,
      eventTileHorizontalSpacing: _eventTileHorizontalSpacing,
      ignoreEventColors: _ignoreEventColors,
      navigatorBackgroundColor: _navigatorBackgroundColor,
      weekNumberBackgroundColor: _weekNumberBackgroundColor,
      monthTheme: MCalMonthThemeData(
        todayBackgroundColor: _todayBackgroundColor,
        eventTileHeight: _eventTileHeight,
        eventTileVerticalSpacing: _eventTileVerticalSpacing,
        eventTileBorderWidth: _eventTileBorderWidth,
        weekdayHeaderBackgroundColor: _weekdayHeaderBackgroundColor,
        dateLabelHeight: _dateLabelHeight,
        dateLabelPosition: _dateLabelPosition,
        overflowIndicatorHeight: _overflowIndicatorHeight,
        dropTargetCellValidColor: _dropTargetCellValidColor,
        dropTargetCellInvalidColor: _dropTargetCellInvalidColor,
        dragSourceOpacity: _dragSourceOpacity,
        draggedTileElevation: _draggedTileElevation,
        hoverCellBackgroundColor: _hoverCellBackgroundColor,
        hoverEventBackgroundColor: _hoverEventBackgroundColor,
      ),
    );
  }

  String _getPresetLabel(ThemePreset preset) {
    final l10n = AppLocalizations.of(context)!;
    switch (preset) {
      case ThemePreset.defaultPreset:
        return l10n.presetDefault;
      case ThemePreset.compact:
        return l10n.presetCompact;
      case ThemePreset.spacious:
        return l10n.presetSpacious;
      case ThemePreset.highContrast:
        return l10n.presetHighContrast;
      case ThemePreset.minimal:
        return l10n.presetMinimal;
    }
  }

  String _getDateLabelPositionLabel(DateLabelPosition position) {
    final l10n = AppLocalizations.of(context)!;
    switch (position) {
      case DateLabelPosition.topLeft:
        return l10n.dateLabelPositionTopLeft;
      case DateLabelPosition.topCenter:
        return l10n.dateLabelPositionTopCenter;
      case DateLabelPosition.topRight:
        return l10n.dateLabelPositionTopRight;
      case DateLabelPosition.bottomLeft:
        return l10n.dateLabelPositionBottomLeft;
      case DateLabelPosition.bottomCenter:
        return l10n.dateLabelPositionBottomCenter;
      case DateLabelPosition.bottomRight:
        return l10n.dateLabelPositionBottomRight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ResponsiveControlPanel(
      controlPanelTitle: l10n.themeSettings,
      child: MCalTheme(
        data: _buildThemeData(),
        child: MCalMonthView(
          controller: _controller,
        ),
      ),
      controlPanel: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Preset chips at top
          ControlWidgets.presetChips<ThemePreset>(
            label: l10n.themePresets,
            selected: _selectedPreset,
            presets: ThemePreset.values,
            labelBuilder: _getPresetLabel,
            onChanged: _loadPreset,
          ),
          const SizedBox(height: 16),
          
          // Cells section
          ControlPanelSection(
            title: l10n.sectionCells,
            children: [
              ControlWidgets.colorPicker(
                label: l10n.settingCellBackgroundColor,
                value: _cellBackgroundColor,
                onChanged: (c) => setState(() => _cellBackgroundColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.colorPicker(
                label: l10n.settingCellBorderColor,
                value: _cellBorderColor,
                onChanged: (c) => setState(() => _cellBorderColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.colorPicker(
                label: l10n.settingTodayBackgroundColor,
                value: _todayBackgroundColor,
                onChanged: (c) => setState(() => _todayBackgroundColor = c),
                cancelLabel: l10n.cancel,
              ),
            ],
          ),
          
          // Event Tiles section
          ControlPanelSection(
            title: l10n.sectionEventTiles,
            children: [
              ControlWidgets.colorPicker(
                label: l10n.settingEventTileBackgroundColor,
                value: _eventTileBackgroundColor,
                onChanged: (c) => setState(() => _eventTileBackgroundColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.slider(
                label: l10n.settingEventTileHeight,
                value: _eventTileHeight,
                min: 12,
                max: 40,
                divisions: 28,
                onChanged: (v) => setState(() => _eventTileHeight = v),
              ),
              ControlWidgets.slider(
                label: l10n.settingEventTileCornerRadius,
                value: _eventTileCornerRadius,
                min: 0,
                max: 12,
                divisions: 24,
                onChanged: (v) => setState(() => _eventTileCornerRadius = v),
              ),
              ControlWidgets.slider(
                label: l10n.settingEventTileHorizontalSpacing,
                value: _eventTileHorizontalSpacing,
                min: 0,
                max: 8,
                divisions: 16,
                onChanged: (v) => setState(() => _eventTileHorizontalSpacing = v),
              ),
              ControlWidgets.slider(
                label: l10n.settingEventTileVerticalSpacing,
                value: _eventTileVerticalSpacing,
                min: 0,
                max: 8,
                divisions: 16,
                onChanged: (v) => setState(() => _eventTileVerticalSpacing = v),
              ),
              ControlWidgets.slider(
                label: l10n.settingEventTileBorderWidth,
                value: _eventTileBorderWidth,
                min: 0,
                max: 4,
                divisions: 16,
                onChanged: (v) => setState(() => _eventTileBorderWidth = v),
              ),
              ControlWidgets.toggle(
                label: l10n.settingIgnoreEventColors,
                value: _ignoreEventColors,
                onChanged: (v) => setState(() => _ignoreEventColors = v),
              ),
            ],
          ),
          
          // Headers section
          ControlPanelSection(
            title: l10n.sectionHeaders,
            children: [
              ControlWidgets.colorPicker(
                label: l10n.settingWeekdayHeaderBackgroundColor,
                value: _weekdayHeaderBackgroundColor,
                onChanged: (c) => setState(() => _weekdayHeaderBackgroundColor = c),
                cancelLabel: l10n.cancel,
              ),
            ],
          ),
          
          // Date Labels section
          ControlPanelSection(
            title: l10n.sectionDateLabels,
            children: [
              ControlWidgets.slider(
                label: l10n.settingDateLabelHeight,
                value: _dateLabelHeight,
                min: 12,
                max: 36,
                divisions: 24,
                onChanged: (v) => setState(() => _dateLabelHeight = v),
              ),
              ControlWidgets.dropdown<DateLabelPosition>(
                label: l10n.settingDateLabelPosition,
                value: _dateLabelPosition,
                items: DateLabelPosition.values
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(_getDateLabelPositionLabel(p)),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _dateLabelPosition = v);
                  }
                },
              ),
            ],
          ),
          
          // Overflow section
          ControlPanelSection(
            title: l10n.sectionOverflow,
            children: [
              ControlWidgets.slider(
                label: l10n.settingOverflowIndicatorHeight,
                value: _overflowIndicatorHeight,
                min: 8,
                max: 24,
                divisions: 16,
                onChanged: (v) => setState(() => _overflowIndicatorHeight = v),
              ),
            ],
          ),
          
          // Navigator section
          ControlPanelSection(
            title: l10n.sectionNavigator,
            children: [
              ControlWidgets.colorPicker(
                label: l10n.settingNavigatorBackgroundColor,
                value: _navigatorBackgroundColor,
                onChanged: (c) => setState(() => _navigatorBackgroundColor = c),
                cancelLabel: l10n.cancel,
              ),
            ],
          ),
          
          // Drag & Drop section
          ControlPanelSection(
            title: l10n.sectionDragAndDrop,
            children: [
              ControlWidgets.colorPicker(
                label: l10n.settingDropTargetCellValidColor,
                value: _dropTargetCellValidColor,
                onChanged: (c) => setState(() => _dropTargetCellValidColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.colorPicker(
                label: l10n.settingDropTargetCellInvalidColor,
                value: _dropTargetCellInvalidColor,
                onChanged: (c) => setState(() => _dropTargetCellInvalidColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.slider(
                label: l10n.settingDragSourceOpacity,
                value: _dragSourceOpacity,
                min: 0,
                max: 1,
                divisions: 20,
                onChanged: (v) => setState(() => _dragSourceOpacity = v),
              ),
              ControlWidgets.slider(
                label: l10n.settingDraggedTileElevation,
                value: _draggedTileElevation,
                min: 0,
                max: 16,
                divisions: 16,
                onChanged: (v) => setState(() => _draggedTileElevation = v),
              ),
            ],
          ),
          
          // Hover section
          ControlPanelSection(
            title: l10n.sectionHover,
            children: [
              ControlWidgets.colorPicker(
                label: l10n.settingHoverCellBackgroundColor,
                value: _hoverCellBackgroundColor,
                onChanged: (c) => setState(() => _hoverCellBackgroundColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.colorPicker(
                label: l10n.settingHoverEventBackgroundColor,
                value: _hoverEventBackgroundColor,
                onChanged: (c) => setState(() => _hoverEventBackgroundColor = c),
                cancelLabel: l10n.cancel,
              ),
            ],
          ),
          
          // Week Numbers section
          ControlPanelSection(
            title: l10n.sectionWeekNumbers,
            children: [
              ControlWidgets.colorPicker(
                label: l10n.settingWeekNumberBackgroundColor,
                value: _weekNumberBackgroundColor,
                onChanged: (c) => setState(() => _weekNumberBackgroundColor = c),
                cancelLabel: l10n.cancel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
