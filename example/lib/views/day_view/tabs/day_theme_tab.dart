import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/responsive_control_panel.dart';
import '../../../shared/widgets/control_panel_section.dart';
import '../../../shared/widgets/control_widgets.dart';
import '../../../shared/utils/theme_presets.dart';
import '../../../shared/utils/sample_events.dart';

/// Day View Theme customization tab.
///
/// Provides preset chips and organized sections for all Day View theme properties.
/// Changes apply immediately to the calendar preview.
class DayThemeTab extends StatefulWidget {
  const DayThemeTab({super.key});

  @override
  State<DayThemeTab> createState() => _DayThemeTabState();
}

class _DayThemeTabState extends State<DayThemeTab> {
  // ============================================================
  // Preset Selection
  // ============================================================
  ThemePreset _selectedPreset = ThemePreset.defaultPreset;

  // ============================================================
  // Global Properties
  // ============================================================
  bool? _enableEventColorOverrides;
  Color? _cellBackgroundColor;
  Color? _cellBorderColor;
  double? _cellBorderWidth;
  double? _timedEventTitleTimeGap;
  double? _allDayOverflowIndicatorBorderWidth;
  double? _allDaySectionLabelBottomPadding;

  // ============================================================
  // Event Properties
  // ============================================================
  Color? _eventTileBackgroundColor;
  double? _eventTileBorderWidth;
  Color? _eventTileBorderColor;
  double? _eventTileCornerRadius;
  double? _eventTileHorizontalSpacing;
  double? _timedEventMinHeight;
  EdgeInsets? _timedEventPadding;
  Color? _hoverEventBackgroundColor;

  // ============================================================
  // Focused time slot (keyboard focus on grid)
  // ============================================================
  Color? _focusedSlotBackgroundColor;
  Color? _focusedSlotBorderColor;
  double? _focusedSlotBorderWidth;

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
  EdgeInsets? _allDayEventPadding;

  // ============================================================
  // Navigator Properties
  // ============================================================
  Color? _navigatorBackgroundColor;
  double? _navigatorPaddingH;
  double? _navigatorPaddingV;

  // ============================================================
  // Time Legend Properties
  // ============================================================
  double? _timeLegendWidth;
  double? _timeLegendLabelHeight;
  bool? _showTimeLegendTicks;
  Color? _timeLegendTickColor;
  double? _timeLegendTickWidth;
  double? _timeLegendTickLength;

  // ============================================================
  // Gridline Properties
  // ============================================================
  Color? _hourGridlineColor;
  double? _hourGridlineWidth;
  Color? _majorGridlineColor;
  double? _majorGridlineWidth;
  Color? _minorGridlineColor;
  double? _minorGridlineWidth;

  // ============================================================
  // Current Time Indicator Properties
  // ============================================================
  Color? _currentTimeIndicatorColor;
  double? _currentTimeIndicatorWidth;
  double? _currentTimeIndicatorDotRadius;

  // ============================================================
  // Day Header Properties
  // ============================================================
  double? _dayHeaderPaddingAll;
  double? _dayHeaderSpacing;

  // ============================================================
  // Timed Event Layout
  // ============================================================
  double? _timedEventMarginH;
  double? _timedEventMarginV;

  // ============================================================
  // Resize Properties
  // ============================================================
  double? _resizeHandleVisualHeight;

  // ============================================================
  // Time Region Properties
  // ============================================================
  Color? _specialTimeRegionColor;
  Color? _blockedTimeRegionColor;
  Color? _timeRegionBorderColor;
  Color? _timeRegionTextColor;

  // ============================================================
  // Resize Properties
  // ============================================================
  double? _resizeHandleSize;
  int? _minResizeDurationMinutes;

  // ============================================================
  // Calendar Controller
  // ============================================================
  late final MCalEventController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MCalEventController(
      initialDate: DateTime.now(),
    );
    // Add sample events to the controller
    final sampleEvents = createDayViewSampleEvents(DateTime.now());
    _controller.addEvents(sampleEvents);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Apply a theme preset and update all individual properties
  void _applyPreset(ThemePreset preset, ThemeData materialTheme) {
    setState(() {
      _selectedPreset = preset;

      // Get the preset theme data
      final presetTheme = getDayThemePreset(preset, materialTheme);
      final dayViewTheme = presetTheme.dayViewTheme;

      // Reset all individual properties to preset values
      _timeLegendWidth = dayViewTheme?.timeLegendWidth;
      _showTimeLegendTicks = dayViewTheme?.showTimeLegendTicks;
      _timeLegendTickColor = dayViewTheme?.timeLegendTickColor;
      _timeLegendTickWidth = dayViewTheme?.timeLegendTickWidth;
      _timeLegendTickLength = dayViewTheme?.timeLegendTickLength;

      _hourGridlineColor = dayViewTheme?.hourGridlineColor;
      _hourGridlineWidth = dayViewTheme?.hourGridlineWidth;
      _majorGridlineColor = dayViewTheme?.majorGridlineColor;
      _majorGridlineWidth = dayViewTheme?.majorGridlineWidth;
      _minorGridlineColor = dayViewTheme?.minorGridlineColor;
      _minorGridlineWidth = dayViewTheme?.minorGridlineWidth;

      _currentTimeIndicatorColor = dayViewTheme?.currentTimeIndicatorColor;
      _currentTimeIndicatorWidth = dayViewTheme?.currentTimeIndicatorWidth;
      _currentTimeIndicatorDotRadius = dayViewTheme?.currentTimeIndicatorDotRadius;

      _enableEventColorOverrides = presetTheme.enableEventColorOverrides;
      _cellBackgroundColor = presetTheme.cellBackgroundColor;
      _cellBorderColor = presetTheme.cellBorderColor;
      _eventTileBackgroundColor = dayViewTheme?.eventTileBackgroundColor;
      _eventTileBorderWidth = dayViewTheme?.eventTileBorderWidth;
      _eventTileBorderColor = dayViewTheme?.eventTileBorderColor;
      _eventTileCornerRadius = dayViewTheme?.eventTileCornerRadius;
      _eventTileHorizontalSpacing = dayViewTheme?.eventTileHorizontalSpacing;
      _timedEventMinHeight = dayViewTheme?.timedEventMinHeight;
      _timedEventPadding = dayViewTheme?.timedEventPadding;
      _hoverEventBackgroundColor = dayViewTheme?.hoverEventBackgroundColor;

      _allDayEventBackgroundColor = dayViewTheme?.allDayEventBackgroundColor;
      _allDayEventBorderColor = dayViewTheme?.allDayEventBorderColor;
      _allDayEventBorderWidth = dayViewTheme?.allDayEventBorderWidth;
      _allDayEventPadding = dayViewTheme?.allDayEventPadding;

      _navigatorBackgroundColor = presetTheme.navigatorBackgroundColor;
      final navPad = presetTheme.navigatorPadding?.resolve(TextDirection.ltr);
      _navigatorPaddingH = navPad?.left;
      _navigatorPaddingV = navPad?.top;

      _timeLegendLabelHeight = dayViewTheme?.timeLegendLabelHeight;
      final headerPad = dayViewTheme?.dayHeaderPadding?.resolve(TextDirection.ltr);
      _dayHeaderPaddingAll = headerPad?.left;
      _dayHeaderSpacing = dayViewTheme?.dayHeaderSpacing;
      final timedMargin = dayViewTheme?.timedEventMargin?.resolve(TextDirection.ltr);
      _timedEventMarginH = timedMargin?.left;
      _timedEventMarginV = timedMargin?.top;
      _resizeHandleVisualHeight = dayViewTheme?.resizeHandleVisualHeight;

      _specialTimeRegionColor = dayViewTheme?.specialTimeRegionColor;
      _blockedTimeRegionColor = dayViewTheme?.blockedTimeRegionColor;
      _timeRegionBorderColor = dayViewTheme?.timeRegionBorderColor;
      _timeRegionTextColor = dayViewTheme?.timeRegionTextColor;

      _resizeHandleSize = dayViewTheme?.resizeHandleSize;
      _minResizeDurationMinutes = dayViewTheme?.minResizeDurationMinutes?.toInt();

      _cellBorderWidth = presetTheme.cellBorderWidth;
      _keyboardSelectionBorderWidth = dayViewTheme?.keyboardSelectionBorderWidth;
      _keyboardSelectionBorderColor = dayViewTheme?.keyboardSelectionBorderColor;
      _keyboardSelectionBorderRadius = dayViewTheme?.keyboardSelectionBorderRadius;
      _keyboardHighlightBorderWidth = dayViewTheme?.keyboardHighlightBorderWidth;
      _keyboardHighlightBorderColor = dayViewTheme?.keyboardHighlightBorderColor;
      _keyboardHighlightBorderRadius = dayViewTheme?.keyboardHighlightBorderRadius;
      _focusedSlotBackgroundColor = dayViewTheme?.focusedSlotBackgroundColor;
      _focusedSlotBorderColor = dayViewTheme?.focusedSlotBorderColor;
      _focusedSlotBorderWidth = dayViewTheme?.focusedSlotBorderWidth;
      _timedEventTitleTimeGap = dayViewTheme?.timedEventTitleTimeGap;
      _allDayOverflowIndicatorBorderWidth = dayViewTheme?.allDayOverflowIndicatorBorderWidth;
      _allDaySectionLabelBottomPadding = dayViewTheme?.allDaySectionLabelBottomPadding;
    });
  }

  /// Build the current theme data from individual properties.
  ///
  /// Only non-null state variables are passed through; null values let the
  /// library's master defaults (from [MCalThemeData.fromTheme]) take effect.
  MCalThemeData _buildThemeData(ThemeData materialTheme) {
    final baseTheme = MCalThemeData.fromTheme(materialTheme);

    return baseTheme.copyWith(
      enableEventColorOverrides: _enableEventColorOverrides,
      cellBackgroundColor: _cellBackgroundColor,
      cellBorderColor: _cellBorderColor,
      cellBorderWidth: _cellBorderWidth,
      navigatorBackgroundColor: _navigatorBackgroundColor,
      navigatorPadding: (_navigatorPaddingH != null || _navigatorPaddingV != null)
          ? EdgeInsets.symmetric(
              horizontal: _navigatorPaddingH ?? baseTheme.navigatorPadding!.horizontal / 2,
              vertical: _navigatorPaddingV ?? baseTheme.navigatorPadding!.vertical / 2,
            )
          : null,
      dayViewTheme: MCalDayViewThemeData(
        focusedSlotBackgroundColor: _focusedSlotBackgroundColor,
        focusedSlotBorderColor: _focusedSlotBorderColor,
        focusedSlotBorderWidth: _focusedSlotBorderWidth,
        eventTileBackgroundColor: _eventTileBackgroundColor,
        eventTileBorderWidth: _eventTileBorderWidth,
        eventTileBorderColor: _eventTileBorderColor,
        hoverEventBackgroundColor: _hoverEventBackgroundColor,
        allDayEventBackgroundColor: _allDayEventBackgroundColor,
        allDayEventBorderColor: _allDayEventBorderColor,
        allDayEventBorderWidth: _allDayEventBorderWidth,
        allDayEventPadding: _allDayEventPadding,
        eventTileCornerRadius: _eventTileCornerRadius,
        eventTileHorizontalSpacing: _eventTileHorizontalSpacing,
        keyboardSelectionBorderWidth: _keyboardSelectionBorderWidth,
        keyboardSelectionBorderColor: _keyboardSelectionBorderColor,
        keyboardSelectionBorderRadius: _keyboardSelectionBorderRadius,
        keyboardHighlightBorderWidth: _keyboardHighlightBorderWidth,
        keyboardHighlightBorderColor: _keyboardHighlightBorderColor,
        keyboardHighlightBorderRadius: _keyboardHighlightBorderRadius,
        timeLegendWidth: _timeLegendWidth,
        timeLegendLabelHeight: _timeLegendLabelHeight,
        showTimeLegendTicks: _showTimeLegendTicks,
        timeLegendTickColor: _timeLegendTickColor,
        timeLegendTickWidth: _timeLegendTickWidth,
        timeLegendTickLength: _timeLegendTickLength,
        hourGridlineColor: _hourGridlineColor,
        hourGridlineWidth: _hourGridlineWidth,
        majorGridlineColor: _majorGridlineColor,
        majorGridlineWidth: _majorGridlineWidth,
        minorGridlineColor: _minorGridlineColor,
        minorGridlineWidth: _minorGridlineWidth,
        currentTimeIndicatorColor: _currentTimeIndicatorColor,
        currentTimeIndicatorWidth: _currentTimeIndicatorWidth,
        currentTimeIndicatorDotRadius: _currentTimeIndicatorDotRadius,
        timedEventMinHeight: _timedEventMinHeight,
        timedEventPadding: _timedEventPadding,
        timedEventMargin: (_timedEventMarginH != null || _timedEventMarginV != null)
            ? EdgeInsets.symmetric(
                horizontal: _timedEventMarginH ?? baseTheme.dayViewTheme!.timedEventMargin!.left,
                vertical: _timedEventMarginV ?? baseTheme.dayViewTheme!.timedEventMargin!.top,
              )
            : null,
        dayHeaderPadding: _dayHeaderPaddingAll != null
            ? EdgeInsets.all(_dayHeaderPaddingAll!)
            : null,
        dayHeaderSpacing: _dayHeaderSpacing,
        resizeHandleVisualHeight: _resizeHandleVisualHeight,
        specialTimeRegionColor: _specialTimeRegionColor,
        blockedTimeRegionColor: _blockedTimeRegionColor,
        timeRegionBorderColor: _timeRegionBorderColor,
        timeRegionTextColor: _timeRegionTextColor,
        resizeHandleSize: _resizeHandleSize,
        minResizeDurationMinutes: _minResizeDurationMinutes,
        timedEventTitleTimeGap: _timedEventTitleTimeGap,
        allDayOverflowIndicatorBorderWidth: _allDayOverflowIndicatorBorderWidth,
        allDaySectionLabelBottomPadding: _allDaySectionLabelBottomPadding,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final defaults = MCalThemeData.fromTheme(theme);
    final dayDefaults = defaults.dayViewTheme!;

    // Build control panel
    final controlPanel = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Preset chips
        // NOTE: Missing ARB key: presetLabel (needs to be added in task 10)
        // Using themePresets as fallback for now
        ControlWidgets.presetChips<ThemePreset>(
          label: l10n.themePresets,
          selected: _selectedPreset,
          presets: ThemePreset.values,
          labelBuilder: (preset) {
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
          },
          onChanged: (preset) => _applyPreset(preset, theme),
        ),

        const SizedBox(height: 16),

        // ── Global (MCalThemeData) ─────────────────────────────────────────
        ControlPanelSection(
          title: l10n.sectionGlobal,
          children: [
            ControlWidgets.colorPicker(
              label: l10n.settingCellBackgroundColor,
              value: _cellBackgroundColor ?? defaults.cellBackgroundColor!,
              onChanged: (value) =>
                  setState(() => _cellBackgroundColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingCellBorderColor,
              value: _cellBorderColor ?? defaults.cellBorderColor!,
              onChanged: (value) =>
                  setState(() => _cellBorderColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.slider(
              label: l10n.settingCellBorderWidth,
              value: _cellBorderWidth ?? defaults.cellBorderWidth!,
              min: 0,
              max: 4,
              divisions: 16,
              onChanged: (value) =>
                  setState(() => _cellBorderWidth = value),
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingNavigatorBackgroundColor,
              value: _navigatorBackgroundColor ?? defaults.navigatorBackgroundColor!,
              onChanged: (value) =>
                  setState(() => _navigatorBackgroundColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.slider(
              label: '${l10n.settingNavigatorPadding} H',
              value: _navigatorPaddingH ?? defaults.navigatorPadding!.horizontal / 2,
              min: 0,
              max: 24,
              divisions: 24,
              onChanged: (value) =>
                  setState(() => _navigatorPaddingH = value),
            ),
            ControlWidgets.slider(
              label: '${l10n.settingNavigatorPadding} V',
              value: _navigatorPaddingV ?? defaults.navigatorPadding!.vertical / 2,
              min: 0,
              max: 24,
              divisions: 24,
              onChanged: (value) =>
                  setState(() => _navigatorPaddingV = value),
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
              onChanged: (value) =>
                  setState(() => _enableEventColorOverrides = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingEventTileCornerRadius,
              value: _eventTileCornerRadius ?? dayDefaults.eventTileCornerRadius!,
              min: 0,
              max: 16,
              divisions: 16,
              onChanged: (value) => setState(() => _eventTileCornerRadius = value),
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingHoverEventBackgroundColor,
              value: _hoverEventBackgroundColor ?? dayDefaults.hoverEventBackgroundColor!,
              onChanged: (value) =>
                  setState(() => _hoverEventBackgroundColor = value),
              cancelLabel: l10n.cancel,
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
                  value: _allDayEventBackgroundColor ?? dayDefaults.allDayEventBackgroundColor!,
                  onChanged: (value) =>
                      setState(() => _allDayEventBackgroundColor = value),
                  cancelLabel: l10n.cancel,
                ),
              ),
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingAllDayEventBorderColor,
              value: _allDayEventBorderColor ?? dayDefaults.allDayEventBorderColor!,
              onChanged: (value) => setState(() => _allDayEventBorderColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.slider(
              label: l10n.settingAllDayEventBorderWidth,
              value: _allDayEventBorderWidth ?? dayDefaults.allDayEventBorderWidth!,
              min: 0,
              max: 4,
              divisions: 16,
              onChanged: (value) => setState(() => _allDayEventBorderWidth = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingAllDayEventPadding,
              value: (_allDayEventPadding?.left ?? dayDefaults.allDayEventPadding!.left),
              min: 0,
              max: 16,
              divisions: 16,
              onChanged: (value) => setState(
                () => _allDayEventPadding = EdgeInsets.symmetric(horizontal: value, vertical: value / 3),
              ),
            ),
            ControlWidgets.slider(
              label: l10n.settingAllDayOverflowIndicatorBorderWidth,
              value: _allDayOverflowIndicatorBorderWidth ?? dayDefaults.allDayOverflowIndicatorBorderWidth!,
              min: 0,
              max: 4,
              divisions: 16,
              onChanged: (value) =>
                  setState(() => _allDayOverflowIndicatorBorderWidth = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingAllDaySectionLabelBottomPadding,
              value: _allDaySectionLabelBottomPadding ?? dayDefaults.allDaySectionLabelBottomPadding!,
              min: 0,
              max: 16,
              divisions: 16,
              onChanged: (value) =>
                  setState(() => _allDaySectionLabelBottomPadding = value),
            ),
          ],
        ),

        // ── Timed Events ──────────────────────────────────────────────────────
        ControlPanelSection(
          title: l10n.sectionTimedEvents,
          children: [
            Opacity(
              opacity: (_enableEventColorOverrides ?? defaults.enableEventColorOverrides) ? 1.0 : 0.4,
              child: IgnorePointer(
                ignoring: !(_enableEventColorOverrides ?? defaults.enableEventColorOverrides),
                child: ControlWidgets.colorPicker(
                  label: l10n.settingEventTileBackgroundColor,
                  value: _eventTileBackgroundColor ?? dayDefaults.eventTileBackgroundColor!,
                  onChanged: (value) =>
                      setState(() => _eventTileBackgroundColor = value),
                  cancelLabel: l10n.cancel,
                ),
              ),
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingEventTileBorderColor,
              value: _eventTileBorderColor ?? dayDefaults.eventTileBorderColor ?? theme.colorScheme.outline,
              onChanged: (value) =>
                  setState(() => _eventTileBorderColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.slider(
              label: l10n.settingEventTileBorderWidth,
              value: _eventTileBorderWidth ?? dayDefaults.eventTileBorderWidth!,
              min: 0,
              max: 4,
              divisions: 16,
              onChanged: (value) =>
                  setState(() => _eventTileBorderWidth = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingEventTileHorizontalSpacing,
              value: _eventTileHorizontalSpacing ?? dayDefaults.eventTileHorizontalSpacing!,
              min: 0,
              max: 8,
              divisions: 16,
              onChanged: (value) => setState(() => _eventTileHorizontalSpacing = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingTimedEventMinHeight,
              value: _timedEventMinHeight ?? dayDefaults.timedEventMinHeight!,
              min: 12,
              max: 48,
              divisions: 36,
              onChanged: (value) => setState(() => _timedEventMinHeight = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingTimedEventPadding,
              value: (_timedEventPadding?.left ?? dayDefaults.timedEventPadding!.left),
              min: 0,
              max: 12,
              divisions: 12,
              onChanged: (value) => setState(() => _timedEventPadding = EdgeInsets.all(value)),
            ),
            ControlWidgets.slider(
              label: l10n.settingTimedEventMarginH,
              value: _timedEventMarginH ?? dayDefaults.timedEventMargin!.left,
              min: 0,
              max: 8,
              divisions: 16,
              onChanged: (value) =>
                  setState(() => _timedEventMarginH = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingTimedEventMarginV,
              value: _timedEventMarginV ?? dayDefaults.timedEventMargin!.top,
              min: 0,
              max: 6,
              divisions: 12,
              onChanged: (value) =>
                  setState(() => _timedEventMarginV = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingTimedEventTitleTimeGap,
              value: _timedEventTitleTimeGap ?? dayDefaults.timedEventTitleTimeGap!,
              min: 0,
              max: 8,
              divisions: 16,
              onChanged: (value) =>
                  setState(() => _timedEventTitleTimeGap = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingResizeHandleHeight,
              value: _resizeHandleVisualHeight ?? dayDefaults.resizeHandleVisualHeight!,
              min: 1,
              max: 8,
              divisions: 14,
              onChanged: (value) =>
                  setState(() => _resizeHandleVisualHeight = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingResizeHandleSize,
              value: _resizeHandleSize ?? dayDefaults.resizeHandleSize!,
              min: 4,
              max: 20,
              divisions: 16,
              onChanged: (value) => setState(() => _resizeHandleSize = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingMinResizeDurationMinutes,
              value: (_minResizeDurationMinutes ?? dayDefaults.minResizeDurationMinutes!).toDouble(),
              min: 5,
              max: 60,
              divisions: 11,
              onChanged: (value) => setState(() => _minResizeDurationMinutes = value.round()),
            ),
          ],
        ),

        // ── Day Header (MCalDayViewThemeData-specific) ───────────────────────
        ControlPanelSection(
          title: l10n.sectionDayHeader,
          children: [
            ControlWidgets.slider(
              label: l10n.settingDayHeaderPadding,
              value: _dayHeaderPaddingAll ?? dayDefaults.dayHeaderPadding!.left,
              min: 0,
              max: 20,
              divisions: 20,
              onChanged: (value) =>
                  setState(() => _dayHeaderPaddingAll = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingDayHeaderSpacing,
              value: _dayHeaderSpacing ?? dayDefaults.dayHeaderSpacing!,
              min: 0,
              max: 20,
              divisions: 20,
              onChanged: (value) =>
                  setState(() => _dayHeaderSpacing = value),
            ),
          ],
        ),

        // ── Time Grid ────────────────────────────────────────────────────────
        ControlPanelSection(
          title: l10n.sectionTimeGrid,
          children: [
            ControlWidgets.slider(
              label: l10n.settingTimeLegendWidth,
              value: _timeLegendWidth ?? dayDefaults.timeLegendWidth!,
              min: 40,
              max: 100,
              divisions: 60,
              onChanged: (value) => setState(() => _timeLegendWidth = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingTimeLegendLabelHeight,
              value: _timeLegendLabelHeight ?? dayDefaults.timeLegendLabelHeight!,
              min: 12,
              max: 32,
              divisions: 20,
              onChanged: (value) =>
                  setState(() => _timeLegendLabelHeight = value),
            ),
            ControlWidgets.toggle(
              label: l10n.settingShowTimeLegendTicks,
              value: _showTimeLegendTicks ?? dayDefaults.showTimeLegendTicks!,
              onChanged: (value) => setState(() => _showTimeLegendTicks = value),
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingTimeLegendTickColor,
              value: _timeLegendTickColor ?? dayDefaults.timeLegendTickColor!,
              onChanged: (value) => setState(() => _timeLegendTickColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.slider(
              label: l10n.settingTimeLegendTickWidth,
              value: _timeLegendTickWidth ?? dayDefaults.timeLegendTickWidth!,
              min: 0.5,
              max: 3,
              divisions: 25,
              onChanged: (value) => setState(() => _timeLegendTickWidth = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingTimeLegendTickLength,
              value: _timeLegendTickLength ?? dayDefaults.timeLegendTickLength!,
              min: 4,
              max: 16,
              divisions: 12,
              onChanged: (value) => setState(() => _timeLegendTickLength = value),
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingHourGridlineColor,
              value: _hourGridlineColor ?? dayDefaults.hourGridlineColor!,
              onChanged: (value) => setState(() => _hourGridlineColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.slider(
              label: l10n.settingHourGridlineWidth,
              value: _hourGridlineWidth ?? dayDefaults.hourGridlineWidth!,
              min: 0,
              max: 3,
              divisions: 30,
              onChanged: (value) => setState(() => _hourGridlineWidth = value),
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingMajorGridlineColor,
              value: _majorGridlineColor ?? dayDefaults.majorGridlineColor!,
              onChanged: (value) => setState(() => _majorGridlineColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.slider(
              label: l10n.settingMajorGridlineWidth,
              value: _majorGridlineWidth ?? dayDefaults.majorGridlineWidth!,
              min: 0,
              max: 3,
              divisions: 30,
              onChanged: (value) => setState(() => _majorGridlineWidth = value),
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingMinorGridlineColor,
              value: _minorGridlineColor ?? dayDefaults.minorGridlineColor!,
              onChanged: (value) => setState(() => _minorGridlineColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.slider(
              label: l10n.settingMinorGridlineWidth,
              value: _minorGridlineWidth ?? dayDefaults.minorGridlineWidth!,
              min: 0,
              max: 2,
              divisions: 20,
              onChanged: (value) => setState(() => _minorGridlineWidth = value),
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingCurrentTimeIndicatorColor,
              value: _currentTimeIndicatorColor ?? dayDefaults.currentTimeIndicatorColor!,
              onChanged: (value) => setState(() => _currentTimeIndicatorColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.slider(
              label: l10n.settingCurrentTimeIndicatorWidth,
              value: _currentTimeIndicatorWidth ?? dayDefaults.currentTimeIndicatorWidth!,
              min: 1,
              max: 5,
              divisions: 8,
              onChanged: (value) => setState(() => _currentTimeIndicatorWidth = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingCurrentTimeIndicatorDotRadius,
              value: _currentTimeIndicatorDotRadius ?? dayDefaults.currentTimeIndicatorDotRadius!,
              min: 2,
              max: 8,
              divisions: 12,
              onChanged: (value) => setState(() => _currentTimeIndicatorDotRadius = value),
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingSpecialTimeRegionColor,
              value: _specialTimeRegionColor ?? dayDefaults.specialTimeRegionColor!,
              onChanged: (value) => setState(() => _specialTimeRegionColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingBlockedTimeRegionColor,
              value: _blockedTimeRegionColor ?? dayDefaults.blockedTimeRegionColor!,
              onChanged: (value) => setState(() => _blockedTimeRegionColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingTimeRegionBorderColor,
              value: _timeRegionBorderColor ?? dayDefaults.timeRegionBorderColor!,
              onChanged: (value) => setState(() => _timeRegionBorderColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingTimeRegionTextColor,
              value: _timeRegionTextColor ?? dayDefaults.timeRegionTextColor!,
              onChanged: (value) => setState(() => _timeRegionTextColor = value),
              cancelLabel: l10n.cancel,
            ),
          ],
        ),

        // ── Focused slot (second-to-last) ───────────────────────────────────
        ControlPanelSection(
          title: l10n.sectionFocused,
          children: [
            ControlWidgets.colorPicker(
              label: l10n.settingFocusedSlotBackgroundColor,
              value: _focusedSlotBackgroundColor ??
                  dayDefaults.focusedSlotBackgroundColor!,
              onChanged: (value) =>
                  setState(() => _focusedSlotBackgroundColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingFocusedSlotBorderColor,
              value: _focusedSlotBorderColor ??
                  dayDefaults.focusedSlotBorderColor!,
              onChanged: (value) =>
                  setState(() => _focusedSlotBorderColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.slider(
              label: l10n.settingFocusedSlotBorderWidth,
              value: _focusedSlotBorderWidth ??
                  dayDefaults.focusedSlotBorderWidth!,
              min: 0,
              max: 6,
              divisions: 24,
              onChanged: (value) =>
                  setState(() => _focusedSlotBorderWidth = value),
            ),
          ],
        ),

        // ── Keyboard event border (last section) ─────────────────────────────
        ControlPanelSection(
          title: l10n.sectionKeyboardEventBorder,
          children: [
            ControlWidgets.slider(
              label: l10n.settingKeyboardSelectionBorderWidth,
              value: _keyboardSelectionBorderWidth ??
                  dayDefaults.keyboardSelectionBorderWidth!,
              min: 0,
              max: 6,
              divisions: 24,
              onChanged: (value) =>
                  setState(() => _keyboardSelectionBorderWidth = value),
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingKeyboardSelectionBorderColor,
              value: _keyboardSelectionBorderColor ??
                  dayDefaults.keyboardSelectionBorderColor ??
                  theme.colorScheme.outline,
              onChanged: (value) =>
                  setState(() => _keyboardSelectionBorderColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.slider(
              label: l10n.settingKeyboardSelectionBorderRadius,
              value: _keyboardSelectionBorderRadius ??
                  dayDefaults.keyboardSelectionBorderRadius!,
              min: 0,
              max: 16,
              divisions: 32,
              onChanged: (value) =>
                  setState(() => _keyboardSelectionBorderRadius = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingKeyboardHighlightBorderWidth,
              value: _keyboardHighlightBorderWidth ??
                  dayDefaults.keyboardHighlightBorderWidth!,
              min: 0,
              max: 6,
              divisions: 24,
              onChanged: (value) =>
                  setState(() => _keyboardHighlightBorderWidth = value),
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingKeyboardHighlightBorderColor,
              value: _keyboardHighlightBorderColor ??
                  dayDefaults.keyboardHighlightBorderColor ??
                  theme.colorScheme.outline,
              onChanged: (value) =>
                  setState(() => _keyboardHighlightBorderColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.slider(
              label: l10n.settingKeyboardHighlightBorderRadius,
              value: _keyboardHighlightBorderRadius ??
                  dayDefaults.keyboardHighlightBorderRadius!,
              min: 0,
              max: 16,
              divisions: 32,
              onChanged: (value) =>
                  setState(() => _keyboardHighlightBorderRadius = value),
            ),
          ],
        ),
      ],
    );

    // Build calendar view
    final calendar = MCalTheme(
      data: _buildThemeData(theme),
      child: MCalDayView(
        controller: _controller,
        startHour: 8,
        endHour: 18,
        showCurrentTimeIndicator: true,
        showNavigator: true,
        showWeekNumbers: true,
        enableDragToMove: true,
        enableDragToResize: true,
        onEventDropped: (_, details) => true,
        onEventResized: (_, details) => true,
      ),
    );

    // NOTE: Missing ARB key: sectionTheme (needs to be added in task 10)
    // Using themeSettings as fallback for now
    return ResponsiveControlPanel(
      controlPanelTitle: l10n.themeSettings,
      controlPanel: controlPanel,
      child: calendar,
    );
  }
}
