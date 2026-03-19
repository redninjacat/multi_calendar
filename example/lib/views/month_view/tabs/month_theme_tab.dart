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
  
  // ============================================================
  // Preset Selection
  // ============================================================
  ThemePreset _selectedPreset = ThemePreset.defaultPreset;

  // ============================================================
  // Global Properties
  // ============================================================
  bool _enableEventColorOverrides = false;
  double? _cellBorderWidth;

  // ============================================================
  // Event Tile Properties
  // ============================================================
  late Color _eventTileBackgroundColor;
  late double _eventTileHeight;
  late double _eventTileCornerRadius;
  late double _eventTileHorizontalSpacing;
  late double _eventTileVerticalSpacing;
  late double _eventTileBorderWidth;
  Color? _eventTileBorderColor;
  late double _eventTilePadding;

  // ============================================================
  // Multi-Day Event Properties
  // ============================================================
  Color? _multiDayEventBackgroundColor;

  // ============================================================
  // Cell Properties
  // ============================================================
  late Color _cellBackgroundColor;
  late Color _cellBorderColor;
  late Color _todayBackgroundColor;

  // ============================================================
  // Header Properties
  // ============================================================
  late Color _weekdayHeaderBackgroundColor;

  // ============================================================
  // Date Label Properties
  // ============================================================
  late double _dateLabelHeight;
  DateLabelPosition _dateLabelPosition = DateLabelPosition.topLeft;

  // ============================================================
  // Overflow Properties
  // ============================================================
  late double _overflowIndicatorHeight;

  // ============================================================
  // Navigator Properties
  // ============================================================
  late Color _navigatorBackgroundColor;
  double? _navigatorPaddingH;
  double? _navigatorPaddingV;

  // ============================================================
  // Drag & Drop Properties
  // ============================================================
  late Color _dropTargetCellValidColor;
  late Color _dropTargetCellInvalidColor;
  late double _dragSourceOpacity;
  late double _draggedTileElevation;

  // ============================================================
  // Hover Properties
  // ============================================================
  late Color _hoverCellBackgroundColor;
  late Color _hoverEventBackgroundColor;

  // ============================================================
  // Week Number Properties
  // ============================================================
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
      _enableEventColorOverrides = presetTheme.enableEventColorOverrides;
      _cellBackgroundColor = presetTheme.cellBackgroundColor ?? colorScheme.surface;
      _cellBorderColor = presetTheme.cellBorderColor ?? colorScheme.outline.withValues(alpha: 0.2);
      _cellBorderWidth = presetTheme.cellBorderWidth;
      _todayBackgroundColor = presetTheme.monthViewTheme?.todayBackgroundColor ?? colorScheme.primary.withValues(alpha: 0.1);
      _eventTileBackgroundColor = presetTheme.monthViewTheme?.eventTileBackgroundColor ?? colorScheme.primaryContainer;
      _eventTileHeight = presetTheme.monthViewTheme?.eventTileHeight ?? 20.0;
      _eventTileCornerRadius = presetTheme.monthViewTheme?.eventTileCornerRadius ?? 3.0;
      _eventTileHorizontalSpacing = presetTheme.monthViewTheme?.eventTileHorizontalSpacing ?? 1.0;
      _eventTileVerticalSpacing = presetTheme.monthViewTheme?.eventTileVerticalSpacing ?? 1.0;
      _eventTileBorderWidth = presetTheme.monthViewTheme?.eventTileBorderWidth ?? 0.0;
      _eventTileBorderColor = presetTheme.monthViewTheme?.eventTileBorderColor;
      _eventTilePadding = presetTheme.monthViewTheme?.eventTilePadding?.left ?? 4.0;
      _multiDayEventBackgroundColor = presetTheme.monthViewTheme?.multiDayEventBackgroundColor;
      _weekdayHeaderBackgroundColor = presetTheme.monthViewTheme?.weekdayHeaderBackgroundColor ?? colorScheme.surfaceContainerHighest;
      _dateLabelHeight = presetTheme.monthViewTheme?.dateLabelHeight ?? 18.0;
      _dateLabelPosition = presetTheme.monthViewTheme?.dateLabelPosition ?? DateLabelPosition.topLeft;
      _overflowIndicatorHeight = presetTheme.monthViewTheme?.overflowIndicatorHeight ?? 14.0;
      _navigatorBackgroundColor = presetTheme.navigatorBackgroundColor ?? colorScheme.surface;
      final navPad = presetTheme.navigatorPadding?.resolve(TextDirection.ltr);
      _navigatorPaddingH = navPad?.left;
      _navigatorPaddingV = navPad?.top;
      _dropTargetCellValidColor = presetTheme.monthViewTheme?.dropTargetCellValidColor ?? Colors.green.withValues(alpha: 0.3);
      _dropTargetCellInvalidColor = presetTheme.monthViewTheme?.dropTargetCellInvalidColor ?? Colors.red.withValues(alpha: 0.3);
      _dragSourceOpacity = presetTheme.monthViewTheme?.dragSourceOpacity ?? 0.5;
      _draggedTileElevation = presetTheme.monthViewTheme?.draggedTileElevation ?? 6.0;
      _hoverCellBackgroundColor = presetTheme.monthViewTheme?.hoverCellBackgroundColor ?? colorScheme.primary.withValues(alpha: 0.05);
      _hoverEventBackgroundColor = presetTheme.monthViewTheme?.hoverEventBackgroundColor ?? colorScheme.primaryContainer.withValues(alpha: 0.8);
      _weekNumberBackgroundColor = presetTheme.monthViewTheme?.weekNumberBackgroundColor ?? colorScheme.surfaceContainerHighest;
    });
  }

  MCalThemeData _buildThemeData() {
    final navPaddingH = _navigatorPaddingH ?? 8.0;
    final navPaddingV = _navigatorPaddingV ?? 8.0;
    return MCalThemeData(
      cellBackgroundColor: _cellBackgroundColor,
      cellBorderColor: _cellBorderColor,
      cellBorderWidth: _cellBorderWidth,
      enableEventColorOverrides: _enableEventColorOverrides,
      navigatorBackgroundColor: _navigatorBackgroundColor,
      navigatorPadding: EdgeInsets.symmetric(
          horizontal: navPaddingH, vertical: navPaddingV),
      monthViewTheme: MCalMonthViewThemeData(
        eventTileBackgroundColor: _eventTileBackgroundColor,
        eventTileCornerRadius: _eventTileCornerRadius,
        eventTileHorizontalSpacing: _eventTileHorizontalSpacing,
        hoverEventBackgroundColor: _hoverEventBackgroundColor,
        weekNumberBackgroundColor: _weekNumberBackgroundColor,
        todayBackgroundColor: _todayBackgroundColor,
        eventTileHeight: _eventTileHeight,
        eventTileVerticalSpacing: _eventTileVerticalSpacing,
        eventTilePadding: EdgeInsets.symmetric(horizontal: _eventTilePadding),
        eventTileBorderWidth: _eventTileBorderWidth,
        eventTileBorderColor: _eventTileBorderColor,
        multiDayEventBackgroundColor: _multiDayEventBackgroundColor,
        weekdayHeaderBackgroundColor: _weekdayHeaderBackgroundColor,
        dateLabelHeight: _dateLabelHeight,
        dateLabelPosition: _dateLabelPosition,
        overflowIndicatorHeight: _overflowIndicatorHeight,
        dropTargetCellValidColor: _dropTargetCellValidColor,
        dropTargetCellInvalidColor: _dropTargetCellInvalidColor,
        dragSourceOpacity: _dragSourceOpacity,
        draggedTileElevation: _draggedTileElevation,
        hoverCellBackgroundColor: _hoverCellBackgroundColor,
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
    final colorScheme = Theme.of(context).colorScheme;

    return ResponsiveControlPanel(
      controlPanelTitle: l10n.themeSettings,
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
          
          // ── Global (MCalThemeData) ─────────────────────────────────────────
          ControlPanelSection(
            title: l10n.sectionGlobal,
            children: [
              ControlWidgets.toggle(
                label: l10n.settingEnableEventColorOverrides,
                value: _enableEventColorOverrides,
                onChanged: (v) =>
                    setState(() => _enableEventColorOverrides = v),
              ),
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
              ControlWidgets.slider(
                label: l10n.settingCellBorderWidth,
                value: _cellBorderWidth ?? 1.0,
                min: 0,
                max: 4,
                divisions: 16,
                onChanged: (v) =>
                    setState(() => _cellBorderWidth = v),
              ),
              ControlWidgets.colorPicker(
                label: l10n.settingNavigatorBackgroundColor,
                value: _navigatorBackgroundColor,
                onChanged: (c) => setState(() => _navigatorBackgroundColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.slider(
                label: '${l10n.settingNavigatorPadding} H',
                value: _navigatorPaddingH ?? 8.0,
                min: 0,
                max: 24,
                divisions: 24,
                onChanged: (v) =>
                    setState(() => _navigatorPaddingH = v),
              ),
              ControlWidgets.slider(
                label: '${l10n.settingNavigatorPadding} V',
                value: _navigatorPaddingV ?? 8.0,
                min: 0,
                max: 24,
                divisions: 24,
                onChanged: (v) =>
                    setState(() => _navigatorPaddingV = v),
              ),
            ],
          ),

          // ── Event Tiles (MCalEventTileThemeMixin) ────────────────────────────
          ControlPanelSection(
            title: l10n.sectionEventTiles,
            children: [
              Opacity(
                opacity: _enableEventColorOverrides ? 1.0 : 0.4,
                child: IgnorePointer(
                  ignoring: !_enableEventColorOverrides,
                  child: ControlWidgets.colorPicker(
                    label: l10n.settingEventTileBackgroundColor,
                    value: _eventTileBackgroundColor,
                    onChanged: (c) =>
                        setState(() => _eventTileBackgroundColor = c),
                    cancelLabel: l10n.cancel,
                  ),
                ),
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
              ControlWidgets.colorPicker(
                label: l10n.settingEventTileBorderColor,
                value: _eventTileBorderColor ?? colorScheme.outline,
                onChanged: (c) => setState(() => _eventTileBorderColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.slider(
                label: l10n.settingEventTileBorderWidth,
                value: _eventTileBorderWidth,
                min: 0,
                max: 4,
                divisions: 16,
                onChanged: (v) => setState(() => _eventTileBorderWidth = v),
              ),
              ControlWidgets.slider(
                label: l10n.settingEventTilePadding,
                value: _eventTilePadding,
                min: 0,
                max: 12,
                divisions: 24,
                onChanged: (v) => setState(() => _eventTilePadding = v),
              ),
              Opacity(
                opacity: _enableEventColorOverrides ? 1.0 : 0.4,
                child: IgnorePointer(
                  ignoring: !_enableEventColorOverrides,
                  child: ControlWidgets.colorPicker(
                    label: l10n.settingMultiDayEventBackgroundColor,
                    value: _multiDayEventBackgroundColor ??
                        colorScheme.primary.withValues(alpha: 0.8),
                    onChanged: (c) =>
                        setState(() => _multiDayEventBackgroundColor = c),
                    cancelLabel: l10n.cancel,
                  ),
                ),
              ),
              ControlWidgets.colorPicker(
                label: l10n.settingHoverEventBackgroundColor,
                value: _hoverEventBackgroundColor,
                onChanged: (c) => setState(() => _hoverEventBackgroundColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.colorPicker(
                label: l10n.settingWeekNumberBackgroundColor,
                value: _weekNumberBackgroundColor,
                onChanged: (c) => setState(() => _weekNumberBackgroundColor = c),
                cancelLabel: l10n.cancel,
              ),
            ],
          ),

          // ── Month View (MCalMonthViewThemeData-specific) ─────────────────────
          ControlPanelSection(
            title: l10n.sectionMonthView,
            children: [
              ControlWidgets.colorPicker(
                label: l10n.settingTodayBackgroundColor,
                value: _todayBackgroundColor,
                onChanged: (c) => setState(() => _todayBackgroundColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.colorPicker(
                label: l10n.settingWeekdayHeaderBackgroundColor,
                value: _weekdayHeaderBackgroundColor,
                onChanged: (c) => setState(() => _weekdayHeaderBackgroundColor = c),
                cancelLabel: l10n.cancel,
              ),
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
              ControlWidgets.slider(
                label: l10n.settingOverflowIndicatorHeight,
                value: _overflowIndicatorHeight,
                min: 8,
                max: 30,
                divisions: 22,
                onChanged: (v) => setState(() => _overflowIndicatorHeight = v),
              ),
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
              ControlWidgets.colorPicker(
                label: l10n.settingHoverCellBackgroundColor,
                value: _hoverCellBackgroundColor,
                onChanged: (c) => setState(() => _hoverCellBackgroundColor = c),
                cancelLabel: l10n.cancel,
              ),
            ],
          ),
        ],
      ),
      child: MCalTheme(
        data: _buildThemeData(),
        child: MCalMonthView(
          controller: _controller,
          showNavigator: true,
        ),
      ),
    );
  }
}
