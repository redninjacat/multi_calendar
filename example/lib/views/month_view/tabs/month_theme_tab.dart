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
  bool? _enableEventColorOverrides;
  double? _cellBorderWidth;

  // ============================================================
  // Event Tile Properties
  // ============================================================
  Color? _eventTileBackgroundColor;
  double? _eventTileHeight;
  double? _eventTileCornerRadius;
  double? _eventTileHorizontalSpacing;
  double? _eventTileVerticalSpacing;
  double? _eventTileBorderWidth;
  Color? _eventTileBorderColor;
  double? _eventTilePadding;

  // ============================================================
  // Focused calendar cell (month grid)
  // ============================================================
  Color? _focusedCellBackgroundColor;
  Color? _focusedCellBorderColor;
  double? _focusedCellBorderWidth;

  // ============================================================
  // Keyboard (event tile focus rings)
  // ============================================================
  double? _keyboardSelectionBorderWidth;
  Color? _keyboardSelectionBorderColor;
  double? _keyboardSelectionBorderRadius;
  double? _keyboardHighlightBorderWidth;
  Color? _keyboardHighlightBorderColor;
  double? _keyboardHighlightBorderRadius;

  // ============================================================
  // All-Day Event Properties
  // ============================================================
  Color? _allDayEventBackgroundColor;
  Color? _allDayEventBorderColor;
  double? _allDayEventBorderWidth;
  double? _allDayEventPadding;

  // ============================================================
  // Cell Properties
  // ============================================================
  Color? _cellBackgroundColor;
  Color? _cellBorderColor;
  Color? _todayBackgroundColor;

  // ============================================================
  // Header Properties
  // ============================================================
  Color? _weekdayHeaderBackgroundColor;

  // ============================================================
  // Date Label Properties
  // ============================================================
  double? _dateLabelHeight;
  DateLabelPosition? _dateLabelPosition;

  // ============================================================
  // Overflow Properties
  // ============================================================
  double? _overflowIndicatorHeight;

  // ============================================================
  // Navigator Properties
  // ============================================================
  Color? _navigatorBackgroundColor;
  double? _navigatorPaddingH;
  double? _navigatorPaddingV;

  // ============================================================
  // Drag & Drop Properties
  // ============================================================
  Color? _dropTargetCellValidColor;
  Color? _dropTargetCellInvalidColor;
  double? _dragSourceOpacity;
  double? _draggedTileElevation;

  // ============================================================
  // Hover Properties
  // ============================================================
  Color? _hoverCellBackgroundColor;
  Color? _hoverEventBackgroundColor;

  // ============================================================
  // Week Number Properties
  // ============================================================
  Color? _weekNumberBackgroundColor;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _controller = MCalEventController(initialDate: now);
    _controller.addEvents(createSampleEvents());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadPreset(ThemePreset preset) {
    final theme = Theme.of(context);
    final presetTheme = getMonthThemePreset(preset, theme);
    
    setState(() {
      _selectedPreset = preset;

      if (preset == ThemePreset.defaultPreset) {
        _enableEventColorOverrides = null;
        _cellBackgroundColor = null;
        _cellBorderColor = null;
        _cellBorderWidth = null;
        _todayBackgroundColor = null;
        _eventTileBackgroundColor = null;
        _eventTileHeight = null;
        _eventTileCornerRadius = null;
        _eventTileHorizontalSpacing = null;
        _eventTileVerticalSpacing = null;
        _eventTileBorderWidth = null;
        _eventTileBorderColor = null;
        _eventTilePadding = null;
        _allDayEventBackgroundColor = null;
        _allDayEventBorderColor = null;
        _allDayEventBorderWidth = null;
        _allDayEventPadding = null;
        _weekdayHeaderBackgroundColor = null;
        _dateLabelHeight = null;
        _dateLabelPosition = null;
        _overflowIndicatorHeight = null;
        _navigatorBackgroundColor = null;
        _navigatorPaddingH = null;
        _navigatorPaddingV = null;
        _dropTargetCellValidColor = null;
        _dropTargetCellInvalidColor = null;
        _dragSourceOpacity = null;
        _draggedTileElevation = null;
        _hoverCellBackgroundColor = null;
        _hoverEventBackgroundColor = null;
        _weekNumberBackgroundColor = null;
        _keyboardSelectionBorderWidth = null;
        _keyboardSelectionBorderColor = null;
        _keyboardSelectionBorderRadius = null;
        _keyboardHighlightBorderWidth = null;
        _keyboardHighlightBorderColor = null;
        _keyboardHighlightBorderRadius = null;
        _focusedCellBackgroundColor = null;
        _focusedCellBorderColor = null;
        _focusedCellBorderWidth = null;
        return;
      }

      _enableEventColorOverrides = presetTheme.enableEventColorOverrides;
      _cellBackgroundColor = presetTheme.cellBackgroundColor;
      _cellBorderColor = presetTheme.cellBorderColor;
      _cellBorderWidth = presetTheme.cellBorderWidth;
      _todayBackgroundColor = presetTheme.monthViewTheme?.todayBackgroundColor;
      _eventTileBackgroundColor = presetTheme.monthViewTheme?.eventTileBackgroundColor;
      _eventTileHeight = presetTheme.monthViewTheme?.eventTileHeight;
      _eventTileCornerRadius = presetTheme.monthViewTheme?.eventTileCornerRadius;
      _eventTileHorizontalSpacing = presetTheme.monthViewTheme?.eventTileHorizontalSpacing;
      _eventTileVerticalSpacing = presetTheme.monthViewTheme?.eventTileVerticalSpacing;
      _eventTileBorderWidth = presetTheme.monthViewTheme?.eventTileBorderWidth;
      _eventTileBorderColor = presetTheme.monthViewTheme?.eventTileBorderColor;
      _eventTilePadding = presetTheme.monthViewTheme?.eventTilePadding?.left;
      _allDayEventBackgroundColor = presetTheme.monthViewTheme?.allDayEventBackgroundColor;
      _allDayEventBorderColor = presetTheme.monthViewTheme?.allDayEventBorderColor;
      _allDayEventBorderWidth = presetTheme.monthViewTheme?.allDayEventBorderWidth;
      _allDayEventPadding = presetTheme.monthViewTheme?.allDayEventPadding?.left;
      _weekdayHeaderBackgroundColor = presetTheme.monthViewTheme?.weekdayHeaderBackgroundColor;
      _dateLabelHeight = presetTheme.monthViewTheme?.dateLabelHeight;
      _dateLabelPosition = presetTheme.monthViewTheme?.dateLabelPosition;
      _overflowIndicatorHeight = presetTheme.monthViewTheme?.overflowIndicatorHeight;
      _navigatorBackgroundColor = presetTheme.navigatorBackgroundColor;
      final navPad = presetTheme.navigatorPadding?.resolve(TextDirection.ltr);
      _navigatorPaddingH = navPad?.left;
      _navigatorPaddingV = navPad?.top;
      _dropTargetCellValidColor = presetTheme.monthViewTheme?.dropTargetCellValidColor;
      _dropTargetCellInvalidColor = presetTheme.monthViewTheme?.dropTargetCellInvalidColor;
      _dragSourceOpacity = presetTheme.monthViewTheme?.dragSourceOpacity;
      _draggedTileElevation = presetTheme.monthViewTheme?.draggedTileElevation;
      _hoverCellBackgroundColor = presetTheme.monthViewTheme?.hoverCellBackgroundColor;
      _hoverEventBackgroundColor = presetTheme.monthViewTheme?.hoverEventBackgroundColor;
      _weekNumberBackgroundColor = presetTheme.monthViewTheme?.weekNumberBackgroundColor;
      final m = presetTheme.monthViewTheme;
      _keyboardSelectionBorderWidth = m?.keyboardSelectionBorderWidth;
      _keyboardSelectionBorderColor = m?.keyboardSelectionBorderColor;
      _keyboardSelectionBorderRadius = m?.keyboardSelectionBorderRadius;
      _keyboardHighlightBorderWidth = m?.keyboardHighlightBorderWidth;
      _keyboardHighlightBorderColor = m?.keyboardHighlightBorderColor;
      _keyboardHighlightBorderRadius = m?.keyboardHighlightBorderRadius;
      _focusedCellBackgroundColor = m?.focusedCellBackgroundColor;
      _focusedCellBorderColor = m?.focusedCellBorderColor;
      _focusedCellBorderWidth = m?.focusedCellBorderWidth;
    });
  }

  /// Build the current theme data from individual properties.
  ///
  /// Only non-null state variables are passed through; null values let the
  /// library's master defaults (from [MCalThemeData.fromTheme]) take effect.
  MCalThemeData _buildThemeData(ThemeData materialTheme) {
    final baseTheme = MCalThemeData.fromTheme(materialTheme);

    return baseTheme.copyWith(
      cellBackgroundColor: _cellBackgroundColor,
      cellBorderColor: _cellBorderColor,
      cellBorderWidth: _cellBorderWidth,
      enableEventColorOverrides: _enableEventColorOverrides,
      navigatorBackgroundColor: _navigatorBackgroundColor,
      navigatorPadding: (_navigatorPaddingH != null || _navigatorPaddingV != null)
          ? EdgeInsets.symmetric(
              horizontal: _navigatorPaddingH ?? baseTheme.navigatorPadding!.horizontal / 2,
              vertical: _navigatorPaddingV ?? baseTheme.navigatorPadding!.vertical / 2,
            )
          : null,
      monthViewTheme: MCalMonthViewThemeData(
        focusedCellBackgroundColor: _focusedCellBackgroundColor,
        focusedCellBorderColor: _focusedCellBorderColor,
        focusedCellBorderWidth: _focusedCellBorderWidth,
        eventTileBackgroundColor: _eventTileBackgroundColor,
        eventTileCornerRadius: _eventTileCornerRadius,
        eventTileHorizontalSpacing: _eventTileHorizontalSpacing,
        keyboardSelectionBorderWidth: _keyboardSelectionBorderWidth,
        keyboardSelectionBorderColor: _keyboardSelectionBorderColor,
        keyboardSelectionBorderRadius: _keyboardSelectionBorderRadius,
        keyboardHighlightBorderWidth: _keyboardHighlightBorderWidth,
        keyboardHighlightBorderColor: _keyboardHighlightBorderColor,
        keyboardHighlightBorderRadius: _keyboardHighlightBorderRadius,
        hoverEventBackgroundColor: _hoverEventBackgroundColor,
        weekNumberBackgroundColor: _weekNumberBackgroundColor,
        todayBackgroundColor: _todayBackgroundColor,
        eventTileHeight: _eventTileHeight,
        eventTileVerticalSpacing: _eventTileVerticalSpacing,
        eventTilePadding: _eventTilePadding != null
            ? EdgeInsets.symmetric(horizontal: _eventTilePadding!)
            : null,
        eventTileBorderWidth: _eventTileBorderWidth,
        eventTileBorderColor: _eventTileBorderColor,
        allDayEventBackgroundColor: _allDayEventBackgroundColor,
        allDayEventBorderColor: _allDayEventBorderColor,
        allDayEventBorderWidth: _allDayEventBorderWidth,
        allDayEventPadding: _allDayEventPadding != null
            ? EdgeInsets.symmetric(horizontal: _allDayEventPadding!, vertical: (_allDayEventPadding! / 2).clamp(0, 8))
            : null,
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
      case ThemePreset.rounded:
        return l10n.presetRounded;
      case ThemePreset.bordered:
        return l10n.presetBordered;
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
    final theme = Theme.of(context);
    final defaults = MCalThemeData.fromTheme(theme);
    final monthDefaults = defaults.monthViewTheme!;

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
              ControlWidgets.colorPicker(
                label: l10n.settingCellBackgroundColor,
                value: _cellBackgroundColor ?? defaults.cellBackgroundColor!,
                onChanged: (c) => setState(() => _cellBackgroundColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.colorPicker(
                label: l10n.settingCellBorderColor,
                value: _cellBorderColor ?? defaults.cellBorderColor!,
                onChanged: (c) => setState(() => _cellBorderColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.slider(
                label: l10n.settingCellBorderWidth,
                value: _cellBorderWidth ?? defaults.cellBorderWidth!,
                min: 0,
                max: 4,
                divisions: 16,
                onChanged: (v) =>
                    setState(() => _cellBorderWidth = v),
              ),
              ControlWidgets.colorPicker(
                label: l10n.settingNavigatorBackgroundColor,
                value: _navigatorBackgroundColor ?? defaults.navigatorBackgroundColor!,
                onChanged: (c) => setState(() => _navigatorBackgroundColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.slider(
                label: '${l10n.settingNavigatorPadding} H',
                value: _navigatorPaddingH ?? defaults.navigatorPadding!.horizontal / 2,
                min: 0,
                max: 24,
                divisions: 24,
                onChanged: (v) =>
                    setState(() => _navigatorPaddingH = v),
              ),
              ControlWidgets.slider(
                label: '${l10n.settingNavigatorPadding} V',
                value: _navigatorPaddingV ?? defaults.navigatorPadding!.vertical / 2,
                min: 0,
                max: 24,
                divisions: 24,
                onChanged: (v) =>
                    setState(() => _navigatorPaddingV = v),
              ),
            ],
          ),

          // ── All Events (shared across all-day + timed) ─────────────────────
          ControlPanelSection(
            title: l10n.sectionAllEvents,
            children: [
              ControlWidgets.toggle(
                label: l10n.settingEnableEventColorOverrides,
                value: _enableEventColorOverrides ?? defaults.enableEventColorOverrides,
                onChanged: (v) =>
                    setState(() => _enableEventColorOverrides = v),
              ),
              ControlWidgets.slider(
                label: l10n.settingEventTileCornerRadius,
                value: _eventTileCornerRadius ?? monthDefaults.eventTileCornerRadius!,
                min: 0,
                max: 12,
                divisions: 24,
                onChanged: (v) => setState(() => _eventTileCornerRadius = v),
              ),
              ControlWidgets.colorPicker(
                label: l10n.settingHoverEventBackgroundColor,
                value: _hoverEventBackgroundColor ?? monthDefaults.hoverEventBackgroundColor!,
                onChanged: (c) => setState(() => _hoverEventBackgroundColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.slider(
                label: l10n.settingEventTileHeight,
                value: _eventTileHeight ?? monthDefaults.eventTileHeight!,
                min: 12,
                max: 40,
                divisions: 28,
                onChanged: (v) => setState(() => _eventTileHeight = v),
              ),
              ControlWidgets.slider(
                label: l10n.settingEventTileHorizontalSpacing,
                value: _eventTileHorizontalSpacing ?? monthDefaults.eventTileHorizontalSpacing!,
                min: 0,
                max: 8,
                divisions: 16,
                onChanged: (v) => setState(() => _eventTileHorizontalSpacing = v),
              ),
              ControlWidgets.slider(
                label: l10n.settingEventTileVerticalSpacing,
                value: _eventTileVerticalSpacing ?? monthDefaults.eventTileVerticalSpacing!,
                min: 0,
                max: 8,
                divisions: 16,
                onChanged: (v) => setState(() => _eventTileVerticalSpacing = v),
              ),
            ],
          ),

          // ── All-Day Events ───────────────────────────────────────────────────
          ControlPanelSection(
            title: l10n.sectionAllDayEvents,
            children: [
              Opacity(
                opacity: (_enableEventColorOverrides ?? defaults.enableEventColorOverrides) ? 1.0 : 0.4,
                child: IgnorePointer(
                  ignoring: !(_enableEventColorOverrides ?? defaults.enableEventColorOverrides),
                  child: ControlWidgets.colorPicker(
                    label: l10n.settingAllDayEventBackgroundColor,
                    value: _allDayEventBackgroundColor ?? monthDefaults.allDayEventBackgroundColor!,
                    onChanged: (c) =>
                        setState(() => _allDayEventBackgroundColor = c),
                    cancelLabel: l10n.cancel,
                  ),
                ),
              ),
              ControlWidgets.colorPicker(
                label: l10n.settingAllDayEventBorderColor,
                value: _allDayEventBorderColor ?? monthDefaults.allDayEventBorderColor!,
                onChanged: (c) => setState(() => _allDayEventBorderColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.slider(
                label: l10n.settingAllDayEventBorderWidth,
                value: _allDayEventBorderWidth ?? monthDefaults.allDayEventBorderWidth!,
                min: 0,
                max: 4,
                divisions: 16,
                onChanged: (v) => setState(() => _allDayEventBorderWidth = v),
              ),
              ControlWidgets.slider(
                label: l10n.settingAllDayEventPadding,
                value: _allDayEventPadding ?? monthDefaults.allDayEventPadding!.left,
                min: 0,
                max: 12,
                divisions: 24,
                onChanged: (v) => setState(() => _allDayEventPadding = v),
              ),
            ],
          ),

          // ── Timed Events ────────────────────────────────────────────────────
          ControlPanelSection(
            title: l10n.sectionTimedEvents,
            children: [
              Opacity(
                opacity: (_enableEventColorOverrides ?? defaults.enableEventColorOverrides) ? 1.0 : 0.4,
                child: IgnorePointer(
                  ignoring: !(_enableEventColorOverrides ?? defaults.enableEventColorOverrides),
                  child: ControlWidgets.colorPicker(
                    label: l10n.settingEventTileBackgroundColor,
                    value: _eventTileBackgroundColor ?? monthDefaults.eventTileBackgroundColor!,
                    onChanged: (c) =>
                        setState(() => _eventTileBackgroundColor = c),
                    cancelLabel: l10n.cancel,
                  ),
                ),
              ),
              ControlWidgets.colorPicker(
                label: l10n.settingEventTileBorderColor,
                value: _eventTileBorderColor ?? monthDefaults.eventTileBorderColor ?? theme.colorScheme.outline,
                onChanged: (c) => setState(() => _eventTileBorderColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.slider(
                label: l10n.settingEventTileBorderWidth,
                value: _eventTileBorderWidth ?? monthDefaults.eventTileBorderWidth!,
                min: 0,
                max: 4,
                divisions: 16,
                onChanged: (v) => setState(() => _eventTileBorderWidth = v),
              ),
              ControlWidgets.slider(
                label: l10n.settingEventTilePadding,
                value: _eventTilePadding ?? monthDefaults.eventTilePadding!.left,
                min: 0,
                max: 12,
                divisions: 24,
                onChanged: (v) => setState(() => _eventTilePadding = v),
              ),
            ],
          ),

          // ── Month Header ───────────────────────────────────────────────────
          ControlPanelSection(
            title: l10n.sectionMonthHeader,
            children: [
              ControlWidgets.colorPicker(
                label: l10n.settingWeekdayHeaderBackgroundColor,
                value: _weekdayHeaderBackgroundColor ?? monthDefaults.weekdayHeaderBackgroundColor!,
                onChanged: (c) => setState(() => _weekdayHeaderBackgroundColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.colorPicker(
                label: l10n.settingTodayBackgroundColor,
                value: _todayBackgroundColor ?? monthDefaults.todayBackgroundColor!,
                onChanged: (c) => setState(() => _todayBackgroundColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.slider(
                label: l10n.settingDateLabelHeight,
                value: _dateLabelHeight ?? monthDefaults.dateLabelHeight!,
                min: 12,
                max: 36,
                divisions: 24,
                onChanged: (v) => setState(() => _dateLabelHeight = v),
              ),
              ControlWidgets.dropdown<DateLabelPosition>(
                label: l10n.settingDateLabelPosition,
                value: _dateLabelPosition ?? monthDefaults.dateLabelPosition!,
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

          // ── Month Grid ─────────────────────────────────────────────────────
          ControlPanelSection(
            title: l10n.sectionMonthGrid,
            children: [
              ControlWidgets.colorPicker(
                label: l10n.settingWeekNumberBackgroundColor,
                value: _weekNumberBackgroundColor ?? monthDefaults.weekNumberBackgroundColor!,
                onChanged: (c) => setState(() => _weekNumberBackgroundColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.slider(
                label: l10n.settingOverflowIndicatorHeight,
                value: _overflowIndicatorHeight ?? monthDefaults.overflowIndicatorHeight!,
                min: 8,
                max: 30,
                divisions: 22,
                onChanged: (v) => setState(() => _overflowIndicatorHeight = v),
              ),
              ControlWidgets.colorPicker(
                label: l10n.settingHoverCellBackgroundColor,
                value: _hoverCellBackgroundColor ?? monthDefaults.hoverCellBackgroundColor!,
                onChanged: (c) => setState(() => _hoverCellBackgroundColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.colorPicker(
                label: l10n.settingDropTargetCellValidColor,
                value: _dropTargetCellValidColor ?? monthDefaults.dropTargetCellValidColor!,
                onChanged: (c) => setState(() => _dropTargetCellValidColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.colorPicker(
                label: l10n.settingDropTargetCellInvalidColor,
                value: _dropTargetCellInvalidColor ?? monthDefaults.dropTargetCellInvalidColor!,
                onChanged: (c) => setState(() => _dropTargetCellInvalidColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.slider(
                label: l10n.settingDragSourceOpacity,
                value: _dragSourceOpacity ?? monthDefaults.dragSourceOpacity!,
                min: 0,
                max: 1,
                divisions: 20,
                onChanged: (v) => setState(() => _dragSourceOpacity = v),
              ),
              ControlWidgets.slider(
                label: l10n.settingDraggedTileElevation,
                value: _draggedTileElevation ?? monthDefaults.draggedTileElevation!,
                min: 0,
                max: 16,
                divisions: 16,
                onChanged: (v) => setState(() => _draggedTileElevation = v),
              ),
            ],
          ),

          // ── Focused cell (second-to-last) ────────────────────────────────
          ControlPanelSection(
            title: l10n.sectionFocused,
            children: [
              ControlWidgets.colorPicker(
                label: l10n.settingFocusedCellBackgroundColor,
                value: _focusedCellBackgroundColor ??
                    monthDefaults.focusedCellBackgroundColor!,
                onChanged: (c) =>
                    setState(() => _focusedCellBackgroundColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.colorPicker(
                label: l10n.settingFocusedCellBorderColor,
                value: _focusedCellBorderColor ??
                    monthDefaults.focusedCellBorderColor!,
                onChanged: (c) =>
                    setState(() => _focusedCellBorderColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.slider(
                label: l10n.settingFocusedCellBorderWidth,
                value: _focusedCellBorderWidth ??
                    monthDefaults.focusedCellBorderWidth!,
                min: 0,
                max: 6,
                divisions: 24,
                onChanged: (v) =>
                    setState(() => _focusedCellBorderWidth = v),
              ),
            ],
          ),

          // ── Keyboard event border (last section) ─────────────────────────
          ControlPanelSection(
            title: l10n.sectionKeyboardEventBorder,
            children: [
              ControlWidgets.slider(
                label: l10n.settingKeyboardSelectionBorderWidth,
                value: _keyboardSelectionBorderWidth ??
                    monthDefaults.keyboardSelectionBorderWidth!,
                min: 0,
                max: 6,
                divisions: 24,
                onChanged: (v) =>
                    setState(() => _keyboardSelectionBorderWidth = v),
              ),
              ControlWidgets.colorPicker(
                label: l10n.settingKeyboardSelectionBorderColor,
                value: _keyboardSelectionBorderColor ??
                    monthDefaults.keyboardSelectionBorderColor ??
                    theme.colorScheme.outline,
                onChanged: (c) =>
                    setState(() => _keyboardSelectionBorderColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.slider(
                label: l10n.settingKeyboardSelectionBorderRadius,
                value: _keyboardSelectionBorderRadius ??
                    monthDefaults.keyboardSelectionBorderRadius!,
                min: 0,
                max: 16,
                divisions: 32,
                onChanged: (v) =>
                    setState(() => _keyboardSelectionBorderRadius = v),
              ),
              ControlWidgets.slider(
                label: l10n.settingKeyboardHighlightBorderWidth,
                value: _keyboardHighlightBorderWidth ??
                    monthDefaults.keyboardHighlightBorderWidth!,
                min: 0,
                max: 6,
                divisions: 24,
                onChanged: (v) =>
                    setState(() => _keyboardHighlightBorderWidth = v),
              ),
              ControlWidgets.colorPicker(
                label: l10n.settingKeyboardHighlightBorderColor,
                value: _keyboardHighlightBorderColor ??
                    monthDefaults.keyboardHighlightBorderColor ??
                    theme.colorScheme.outline,
                onChanged: (c) =>
                    setState(() => _keyboardHighlightBorderColor = c),
                cancelLabel: l10n.cancel,
              ),
              ControlWidgets.slider(
                label: l10n.settingKeyboardHighlightBorderRadius,
                value: _keyboardHighlightBorderRadius ??
                    monthDefaults.keyboardHighlightBorderRadius!,
                min: 0,
                max: 16,
                divisions: 32,
                onChanged: (v) =>
                    setState(() => _keyboardHighlightBorderRadius = v),
              ),
            ],
          ),
        ],
      ),
      child: MCalTheme(
        data: _buildThemeData(theme),
        child: MCalMonthView(
          controller: _controller,
          showNavigator: true,
          showWeekNumbers: true,
          enableDragToMove: true,
          enableDragToResize: true,
          onEventDropped: (_, details) => true,
          onEventResized: (_, details) => true,
        ),
      ),
    );
  }
}
