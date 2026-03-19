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
  double? _keyboardFocusBorderRadius;
  double? _timedEventTitleTimeGap;
  double? _allDayOverflowIndicatorBorderWidth;
  double? _allDaySectionLabelBottomPadding;

  // ============================================================
  // Event Properties
  // ============================================================
  Color? _eventTileBackgroundColor;
  double? _eventTileCornerRadius;
  double? _eventTileHorizontalSpacing;
  double? _timedEventMinHeight;
  EdgeInsets? _timedEventPadding;
  Color? _hoverEventBackgroundColor;

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
      _keyboardFocusBorderRadius = dayViewTheme?.keyboardFocusBorderRadius;
      _timedEventTitleTimeGap = dayViewTheme?.timedEventTitleTimeGap;
      _allDayOverflowIndicatorBorderWidth = dayViewTheme?.allDayOverflowIndicatorBorderWidth;
      _allDaySectionLabelBottomPadding = dayViewTheme?.allDaySectionLabelBottomPadding;
    });
  }

  /// Build the current theme data from individual properties
  MCalThemeData _buildThemeData(ThemeData materialTheme) {
    final colorScheme = materialTheme.colorScheme;
    final baseTheme = MCalThemeData.fromTheme(materialTheme);

    final navPaddingH = _navigatorPaddingH ?? 8.0;
    final navPaddingV = _navigatorPaddingV ?? 8.0;

    return baseTheme.copyWith(
      enableEventColorOverrides: _enableEventColorOverrides,
      cellBackgroundColor: _cellBackgroundColor,
      cellBorderColor: _cellBorderColor,
      cellBorderWidth: _cellBorderWidth,
      navigatorBackgroundColor: _navigatorBackgroundColor,
      navigatorPadding: EdgeInsets.symmetric(
          horizontal: navPaddingH, vertical: navPaddingV),
      dayViewTheme: MCalDayViewThemeData(
        eventTileBackgroundColor: _eventTileBackgroundColor,
        hoverEventBackgroundColor: _hoverEventBackgroundColor,
        allDayEventBackgroundColor: _allDayEventBackgroundColor,
        allDayEventBorderColor: _allDayEventBorderColor,
        allDayEventBorderWidth: _allDayEventBorderWidth,
        eventTileCornerRadius: _eventTileCornerRadius,
        eventTileHorizontalSpacing: _eventTileHorizontalSpacing,
        timeLegendWidth: _timeLegendWidth ?? 60.0,
        timeLegendLabelHeight: _timeLegendLabelHeight,
        showTimeLegendTicks: _showTimeLegendTicks ?? false,
        timeLegendTickColor: _timeLegendTickColor ?? colorScheme.outline.withValues(alpha: 0.3),
        timeLegendTickWidth: _timeLegendTickWidth ?? 1.0,
        timeLegendTickLength: _timeLegendTickLength ?? 8.0,
        hourGridlineColor: _hourGridlineColor ?? colorScheme.outline.withValues(alpha: 0.2),
        hourGridlineWidth: _hourGridlineWidth ?? 1.0,
        majorGridlineColor: _majorGridlineColor ?? colorScheme.outline.withValues(alpha: 0.15),
        majorGridlineWidth: _majorGridlineWidth ?? 1.0,
        minorGridlineColor: _minorGridlineColor ?? colorScheme.outline.withValues(alpha: 0.08),
        minorGridlineWidth: _minorGridlineWidth ?? 0.5,
        currentTimeIndicatorColor: _currentTimeIndicatorColor ?? colorScheme.primary,
        currentTimeIndicatorWidth: _currentTimeIndicatorWidth ?? 2.0,
        currentTimeIndicatorDotRadius: _currentTimeIndicatorDotRadius ?? 4.0,
        allDayEventPadding: _allDayEventPadding ?? const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
        timedEventMinHeight: _timedEventMinHeight ?? 20.0,
        timedEventPadding: _timedEventPadding ?? const EdgeInsets.all(4.0),
        timedEventMargin: (_timedEventMarginH != null || _timedEventMarginV != null)
            ? EdgeInsets.symmetric(
                horizontal: _timedEventMarginH ?? 2.0,
                vertical: _timedEventMarginV ?? 1.0,
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
        resizeHandleSize: _resizeHandleSize ?? 8.0,
        minResizeDurationMinutes: _minResizeDurationMinutes ?? 15,
        keyboardFocusBorderRadius: _keyboardFocusBorderRadius,
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
    final colorScheme = theme.colorScheme;

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
            }
          },
          onChanged: (preset) => _applyPreset(preset, theme),
        ),

        const SizedBox(height: 16),

        // ── Global (MCalThemeData) ─────────────────────────────────────────
        ControlPanelSection(
          title: l10n.sectionGlobal,
          children: [
            ControlWidgets.toggle(
              label: l10n.settingEnableEventColorOverrides,
              value: _enableEventColorOverrides ?? false,
              onChanged: (value) =>
                  setState(() => _enableEventColorOverrides = value),
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingCellBackgroundColor,
              value: _cellBackgroundColor ?? colorScheme.surface,
              onChanged: (value) =>
                  setState(() => _cellBackgroundColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingCellBorderColor,
              value: _cellBorderColor ??
                  colorScheme.outlineVariant,
              onChanged: (value) =>
                  setState(() => _cellBorderColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingNavigatorBackgroundColor,
              value: _navigatorBackgroundColor ?? colorScheme.surface,
              onChanged: (value) =>
                  setState(() => _navigatorBackgroundColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.slider(
              label: '${l10n.settingNavigatorPadding} H',
              value: _navigatorPaddingH ?? 8.0,
              min: 0,
              max: 24,
              divisions: 24,
              onChanged: (value) =>
                  setState(() => _navigatorPaddingH = value),
            ),
            ControlWidgets.slider(
              label: '${l10n.settingNavigatorPadding} V',
              value: _navigatorPaddingV ?? 8.0,
              min: 0,
              max: 24,
              divisions: 24,
              onChanged: (value) =>
                  setState(() => _navigatorPaddingV = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingCellBorderWidth,
              value: _cellBorderWidth ?? 1.0,
              min: 0,
              max: 4,
              divisions: 16,
              onChanged: (value) =>
                  setState(() => _cellBorderWidth = value),
            ),
          ],
        ),

        // ── Event Tiles (MCalEventTileThemeMixin) ────────────────────────────
        ControlPanelSection(
          title: l10n.sectionEventTiles,
          children: [
            Opacity(
              opacity: (_enableEventColorOverrides ?? false) ? 1.0 : 0.4,
              child: IgnorePointer(
                ignoring: !(_enableEventColorOverrides ?? false),
                child: ControlWidgets.colorPicker(
                  label: l10n.settingEventTileBackgroundColor,
                  value: _eventTileBackgroundColor ??
                      colorScheme.primaryContainer,
                  onChanged: (value) =>
                      setState(() => _eventTileBackgroundColor = value),
                  cancelLabel: l10n.cancel,
                ),
              ),
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingHoverEventBackgroundColor,
              value: _hoverEventBackgroundColor ??
                  colorScheme.primaryContainer.withValues(alpha: 0.8),
              onChanged: (value) =>
                  setState(() => _hoverEventBackgroundColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.slider(
              label: l10n.settingEventTileCornerRadius,
              value: _eventTileCornerRadius ?? 4.0,
              min: 0,
              max: 16,
              divisions: 16,
              onChanged: (value) => setState(() => _eventTileCornerRadius = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingEventTileHorizontalSpacing,
              value: _eventTileHorizontalSpacing ?? 2.0,
              min: 0,
              max: 8,
              divisions: 16,
              onChanged: (value) => setState(() => _eventTileHorizontalSpacing = value),
            ),
          ],
        ),

        // ── Time Grid (MCalTimeGridThemeMixin) ───────────────────────────────
        ControlPanelSection(
          title: l10n.sectionTimeGrid,
          children: [
            ControlWidgets.slider(
              label: l10n.settingTimeLegendWidth,
              value: _timeLegendWidth ?? 60.0,
              min: 40,
              max: 100,
              divisions: 60,
              onChanged: (value) => setState(() => _timeLegendWidth = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingTimeLegendLabelHeight,
              value: _timeLegendLabelHeight ?? 20.0,
              min: 12,
              max: 32,
              divisions: 20,
              onChanged: (value) =>
                  setState(() => _timeLegendLabelHeight = value),
            ),
            ControlWidgets.toggle(
              label: l10n.settingShowTimeLegendTicks,
              value: _showTimeLegendTicks ?? false,
              onChanged: (value) => setState(() => _showTimeLegendTicks = value),
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingTimeLegendTickColor,
              value: _timeLegendTickColor ?? colorScheme.outline.withValues(alpha: 0.3),
              onChanged: (value) => setState(() => _timeLegendTickColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.slider(
              label: l10n.settingTimeLegendTickWidth,
              value: _timeLegendTickWidth ?? 1.0,
              min: 0.5,
              max: 3,
              divisions: 25,
              onChanged: (value) => setState(() => _timeLegendTickWidth = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingTimeLegendTickLength,
              value: _timeLegendTickLength ?? 8.0,
              min: 4,
              max: 16,
              divisions: 12,
              onChanged: (value) => setState(() => _timeLegendTickLength = value),
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingHourGridlineColor,
              value: _hourGridlineColor ?? colorScheme.outline.withValues(alpha: 0.2),
              onChanged: (value) => setState(() => _hourGridlineColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.slider(
              label: l10n.settingHourGridlineWidth,
              value: _hourGridlineWidth ?? 1.0,
              min: 0,
              max: 3,
              divisions: 30,
              onChanged: (value) => setState(() => _hourGridlineWidth = value),
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingMajorGridlineColor,
              value: _majorGridlineColor ?? colorScheme.outline.withValues(alpha: 0.15),
              onChanged: (value) => setState(() => _majorGridlineColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.slider(
              label: l10n.settingMajorGridlineWidth,
              value: _majorGridlineWidth ?? 1.0,
              min: 0,
              max: 3,
              divisions: 30,
              onChanged: (value) => setState(() => _majorGridlineWidth = value),
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingMinorGridlineColor,
              value: _minorGridlineColor ?? colorScheme.outline.withValues(alpha: 0.08),
              onChanged: (value) => setState(() => _minorGridlineColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.slider(
              label: l10n.settingMinorGridlineWidth,
              value: _minorGridlineWidth ?? 0.5,
              min: 0,
              max: 2,
              divisions: 20,
              onChanged: (value) => setState(() => _minorGridlineWidth = value),
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingCurrentTimeIndicatorColor,
              value: _currentTimeIndicatorColor ?? colorScheme.primary,
              onChanged: (value) => setState(() => _currentTimeIndicatorColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.slider(
              label: l10n.settingCurrentTimeIndicatorWidth,
              value: _currentTimeIndicatorWidth ?? 2.0,
              min: 1,
              max: 5,
              divisions: 8,
              onChanged: (value) => setState(() => _currentTimeIndicatorWidth = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingCurrentTimeIndicatorDotRadius,
              value: _currentTimeIndicatorDotRadius ?? 4.0,
              min: 2,
              max: 8,
              divisions: 12,
              onChanged: (value) => setState(() => _currentTimeIndicatorDotRadius = value),
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingSpecialTimeRegionColor,
              value: _specialTimeRegionColor ?? colorScheme.tertiaryContainer.withValues(alpha: 0.3),
              onChanged: (value) => setState(() => _specialTimeRegionColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingBlockedTimeRegionColor,
              value: _blockedTimeRegionColor ?? colorScheme.errorContainer.withValues(alpha: 0.3),
              onChanged: (value) => setState(() => _blockedTimeRegionColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingTimeRegionBorderColor,
              value: _timeRegionBorderColor ?? colorScheme.outline,
              onChanged: (value) => setState(() => _timeRegionBorderColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingTimeRegionTextColor,
              value: _timeRegionTextColor ?? colorScheme.onSurface.withValues(alpha: 0.6),
              onChanged: (value) => setState(() => _timeRegionTextColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.slider(
              label: l10n.settingTimedEventMinHeight,
              value: _timedEventMinHeight ?? 20.0,
              min: 12,
              max: 48,
              divisions: 36,
              onChanged: (value) => setState(() => _timedEventMinHeight = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingTimedEventPadding,
              value: (_timedEventPadding?.left ?? 4.0),
              min: 0,
              max: 12,
              divisions: 12,
              onChanged: (value) => setState(() => _timedEventPadding = EdgeInsets.all(value)),
            ),
            ControlWidgets.slider(
              label: l10n.settingTimedEventMarginH,
              value: _timedEventMarginH ?? 2.0,
              min: 0,
              max: 8,
              divisions: 16,
              onChanged: (value) =>
                  setState(() => _timedEventMarginH = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingTimedEventMarginV,
              value: _timedEventMarginV ?? 1.0,
              min: 0,
              max: 6,
              divisions: 12,
              onChanged: (value) =>
                  setState(() => _timedEventMarginV = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingTimedEventTitleTimeGap,
              value: _timedEventTitleTimeGap ?? 2.0,
              min: 0,
              max: 8,
              divisions: 16,
              onChanged: (value) =>
                  setState(() => _timedEventTitleTimeGap = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingKeyboardFocusBorderRadius,
              value: _keyboardFocusBorderRadius ?? 4.0,
              min: 0,
              max: 12,
              divisions: 24,
              onChanged: (value) =>
                  setState(() => _keyboardFocusBorderRadius = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingResizeHandleHeight,
              value: _resizeHandleVisualHeight ?? 2.0,
              min: 1,
              max: 8,
              divisions: 14,
              onChanged: (value) =>
                  setState(() => _resizeHandleVisualHeight = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingResizeHandleSize,
              value: _resizeHandleSize ?? 8.0,
              min: 4,
              max: 20,
              divisions: 16,
              onChanged: (value) => setState(() => _resizeHandleSize = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingMinResizeDurationMinutes,
              value: (_minResizeDurationMinutes ?? 15).toDouble(),
              min: 5,
              max: 60,
              divisions: 11,
              onChanged: (value) => setState(() => _minResizeDurationMinutes = value.round()),
            ),
          ],
        ),

        // ── All-Day Events (MCalAllDayThemeMixin) ────────────────────────────
        ControlPanelSection(
          title: l10n.sectionAllDayEvents,
          children: [
            Opacity(
              opacity: (_enableEventColorOverrides ?? false) ? 1.0 : 0.4,
              child: IgnorePointer(
                ignoring: !(_enableEventColorOverrides ?? false),
                child: ControlWidgets.colorPicker(
                  label: l10n.settingAllDayEventBackgroundColor,
                  value: _allDayEventBackgroundColor ??
                      colorScheme.secondaryContainer,
                  onChanged: (value) =>
                      setState(() => _allDayEventBackgroundColor = value),
                  cancelLabel: l10n.cancel,
                ),
              ),
            ),
            ControlWidgets.colorPicker(
              label: l10n.settingAllDayEventBorderColor,
              value: _allDayEventBorderColor ?? colorScheme.outline,
              onChanged: (value) => setState(() => _allDayEventBorderColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.slider(
              label: l10n.settingAllDayEventBorderWidth,
              value: _allDayEventBorderWidth ?? 1.0,
              min: 0,
              max: 4,
              divisions: 16,
              onChanged: (value) => setState(() => _allDayEventBorderWidth = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingAllDayEventPadding,
              value: (_allDayEventPadding?.left ?? 6.0),
              min: 0,
              max: 16,
              divisions: 16,
              onChanged: (value) => setState(
                () => _allDayEventPadding = EdgeInsets.symmetric(horizontal: value, vertical: value / 3),
              ),
            ),
            ControlWidgets.slider(
              label: l10n.settingAllDayOverflowIndicatorBorderWidth,
              value: _allDayOverflowIndicatorBorderWidth ?? 1.0,
              min: 0,
              max: 4,
              divisions: 16,
              onChanged: (value) =>
                  setState(() => _allDayOverflowIndicatorBorderWidth = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingAllDaySectionLabelBottomPadding,
              value: _allDaySectionLabelBottomPadding ?? 4.0,
              min: 0,
              max: 16,
              divisions: 16,
              onChanged: (value) =>
                  setState(() => _allDaySectionLabelBottomPadding = value),
            ),
          ],
        ),

        // ── Day Header (MCalDayViewThemeData-specific) ───────────────────────
        ControlPanelSection(
          title: l10n.sectionDayHeader,
          children: [
            ControlWidgets.slider(
              label: l10n.settingDayHeaderPadding,
              value: _dayHeaderPaddingAll ?? 8.0,
              min: 0,
              max: 20,
              divisions: 20,
              onChanged: (value) =>
                  setState(() => _dayHeaderPaddingAll = value),
            ),
            ControlWidgets.slider(
              label: l10n.settingDayHeaderSpacing,
              value: _dayHeaderSpacing ?? 8.0,
              min: 0,
              max: 20,
              divisions: 20,
              onChanged: (value) =>
                  setState(() => _dayHeaderSpacing = value),
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
