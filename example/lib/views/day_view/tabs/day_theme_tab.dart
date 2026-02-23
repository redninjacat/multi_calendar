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
  // Event Properties
  // ============================================================
  Color? _eventTileBackgroundColor;
  double? _timedEventBorderRadius;
  double? _timedEventMinHeight;
  EdgeInsets? _timedEventPadding;
  bool? _ignoreEventColors;

  // ============================================================
  // All-Day Event Properties
  // ============================================================
  Color? _allDayEventBackgroundColor;
  Color? _allDayEventBorderColor;
  double? _allDayEventBorderWidth;

  // ============================================================
  // Time Legend Properties
  // ============================================================
  double? _timeLegendWidth;
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
      final dayTheme = presetTheme.dayTheme;

      // Reset all individual properties to preset values
      _timeLegendWidth = dayTheme?.timeLegendWidth;
      _showTimeLegendTicks = dayTheme?.showTimeLegendTicks;
      _timeLegendTickColor = dayTheme?.timeLegendTickColor;
      _timeLegendTickWidth = dayTheme?.timeLegendTickWidth;
      _timeLegendTickLength = dayTheme?.timeLegendTickLength;

      _hourGridlineColor = dayTheme?.hourGridlineColor;
      _hourGridlineWidth = dayTheme?.hourGridlineWidth;
      _majorGridlineColor = dayTheme?.majorGridlineColor;
      _majorGridlineWidth = dayTheme?.majorGridlineWidth;
      _minorGridlineColor = dayTheme?.minorGridlineColor;
      _minorGridlineWidth = dayTheme?.minorGridlineWidth;

      _currentTimeIndicatorColor = dayTheme?.currentTimeIndicatorColor;
      _currentTimeIndicatorWidth = dayTheme?.currentTimeIndicatorWidth;
      _currentTimeIndicatorDotRadius = dayTheme?.currentTimeIndicatorDotRadius;

      _eventTileBackgroundColor = presetTheme.eventTileBackgroundColor;
      _timedEventBorderRadius = dayTheme?.timedEventBorderRadius;
      _timedEventMinHeight = dayTheme?.timedEventMinHeight;
      _timedEventPadding = dayTheme?.timedEventPadding;
      _ignoreEventColors = presetTheme.ignoreEventColors;

      _allDayEventBackgroundColor = presetTheme.allDayEventBackgroundColor;
      _allDayEventBorderColor = presetTheme.allDayEventBorderColor;
      _allDayEventBorderWidth = presetTheme.allDayEventBorderWidth;

      _specialTimeRegionColor = dayTheme?.specialTimeRegionColor;
      _blockedTimeRegionColor = dayTheme?.blockedTimeRegionColor;
      _timeRegionBorderColor = dayTheme?.timeRegionBorderColor;
      _timeRegionTextColor = dayTheme?.timeRegionTextColor;

      _resizeHandleSize = dayTheme?.resizeHandleSize;
      _minResizeDurationMinutes = dayTheme?.minResizeDurationMinutes?.toInt();
    });
  }

  /// Build the current theme data from individual properties
  MCalThemeData _buildThemeData(ThemeData materialTheme) {
    final colorScheme = materialTheme.colorScheme;
    final baseTheme = MCalThemeData.fromTheme(materialTheme);

    return baseTheme.copyWith(
      eventTileBackgroundColor: _eventTileBackgroundColor,
      ignoreEventColors: _ignoreEventColors,
      allDayEventBackgroundColor: _allDayEventBackgroundColor,
      allDayEventBorderColor: _allDayEventBorderColor,
      allDayEventBorderWidth: _allDayEventBorderWidth,
      dayTheme: MCalDayThemeData(
        timeLegendWidth: _timeLegendWidth ?? 60.0,
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
        timedEventBorderRadius: _timedEventBorderRadius ?? 4.0,
        timedEventMinHeight: _timedEventMinHeight ?? 20.0,
        timedEventPadding: _timedEventPadding ?? const EdgeInsets.all(4.0),
        specialTimeRegionColor: _specialTimeRegionColor,
        blockedTimeRegionColor: _blockedTimeRegionColor,
        timeRegionBorderColor: _timeRegionBorderColor,
        timeRegionTextColor: _timeRegionTextColor,
        resizeHandleSize: _resizeHandleSize ?? 8.0,
        minResizeDurationMinutes: _minResizeDurationMinutes ?? 15,
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

        // ── Shared sections (same position as Month View's Event Tiles) ────────

        // Events section
        ControlPanelSection(
          title: l10n.sectionEvents,
          children: [
            ControlWidgets.colorPicker(
              label: l10n.settingEventTileBackgroundColor,
              value: _eventTileBackgroundColor ?? colorScheme.primaryContainer,
              onChanged: (value) => setState(() => _eventTileBackgroundColor = value),
              cancelLabel: l10n.cancel,
            ),
            ControlWidgets.slider(
              label: l10n.settingTimedEventBorderRadius,
              value: _timedEventBorderRadius ?? 4.0,
              min: 0,
              max: 16,
              divisions: 16,
              onChanged: (value) => setState(() => _timedEventBorderRadius = value),
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
            ControlWidgets.toggle(
              label: l10n.settingIgnoreEventColors,
              value: _ignoreEventColors ?? false,
              onChanged: (value) => setState(() => _ignoreEventColors = value),
            ),
          ],
        ),

        // ── Day View-only sections ───────────────────────────────────────────

        // All-Day Events section
        ControlPanelSection(
          title: l10n.sectionAllDayEvents,
          children: [
            ControlWidgets.colorPicker(
              label: l10n.settingAllDayEventBackgroundColor,
              value: _allDayEventBackgroundColor ?? colorScheme.secondaryContainer,
              onChanged: (value) => setState(() => _allDayEventBackgroundColor = value),
              cancelLabel: l10n.cancel,
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
          ],
        ),

        // Time Legend section
        ControlPanelSection(
          title: l10n.sectionTimeLegend,
          children: [
            ControlWidgets.slider(
              label: l10n.settingTimeLegendWidth,
              value: _timeLegendWidth ?? 60.0,
              min: 40,
              max: 100,
              divisions: 60,
              onChanged: (value) => setState(() => _timeLegendWidth = value),
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
          ],
        ),

        // Gridlines section
        ControlPanelSection(
          title: l10n.sectionGridlines,
          children: [
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
          ],
        ),

        // Current Time section
        ControlPanelSection(
          title: l10n.sectionCurrentTime,
          children: [
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
          ],
        ),

        // Time Regions section
        ControlPanelSection(
          title: l10n.sectionTimeRegions,
          children: [
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
          ],
        ),

        // Resize section
        ControlPanelSection(
          title: l10n.sectionResize,
          children: [
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
