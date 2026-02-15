import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

/// Preset configurations for common Day View theme setups.
enum DayViewThemePreset {
  defaultPreset,
  compact,
  spacious,
  highContrast,
  minimal,
}

/// State for Day View theme customization.
///
/// Holds all customizable theme properties. Changes apply immediately
/// when passed to [MCalTheme] and [MCalDayView].
class DayViewThemeSettings {
  const DayViewThemeSettings({
    this.hourHeight = 80.0,
    this.timeSlotDuration = const Duration(minutes: 15),
    this.allDaySectionMaxRows = 3,
    this.hourGridlineColor,
    this.hourGridlineWidth = 1.0,
    this.majorGridlineColor,
    this.majorGridlineWidth = 1.0,
    this.minorGridlineColor,
    this.minorGridlineWidth = 0.5,
    this.timedEventBorderRadius = 4.0,
    this.timedEventMinHeight = 20.0,
    this.timedEventPadding = const EdgeInsets.all(2.0),
    this.resizeHandleSize = 8.0,
    this.eventTileBackgroundColor,
  });

  final double hourHeight;
  final Duration timeSlotDuration;
  final int allDaySectionMaxRows;
  final Color? hourGridlineColor;
  final double hourGridlineWidth;
  final Color? majorGridlineColor;
  final double majorGridlineWidth;
  final Color? minorGridlineColor;
  final double minorGridlineWidth;
  final double timedEventBorderRadius;
  final double timedEventMinHeight;
  final EdgeInsets timedEventPadding;
  final double resizeHandleSize;
  final Color? eventTileBackgroundColor;

  DayViewThemeSettings copyWith({
    double? hourHeight,
    Duration? timeSlotDuration,
    int? allDaySectionMaxRows,
    Color? hourGridlineColor,
    double? hourGridlineWidth,
    Color? majorGridlineColor,
    double? majorGridlineWidth,
    Color? minorGridlineColor,
    double? minorGridlineWidth,
    double? timedEventBorderRadius,
    double? timedEventMinHeight,
    EdgeInsets? timedEventPadding,
    double? resizeHandleSize,
    Color? eventTileBackgroundColor,
  }) {
    return DayViewThemeSettings(
      hourHeight: hourHeight ?? this.hourHeight,
      timeSlotDuration: timeSlotDuration ?? this.timeSlotDuration,
      allDaySectionMaxRows: allDaySectionMaxRows ?? this.allDaySectionMaxRows,
      hourGridlineColor: hourGridlineColor ?? this.hourGridlineColor,
      hourGridlineWidth: hourGridlineWidth ?? this.hourGridlineWidth,
      majorGridlineColor: majorGridlineColor ?? this.majorGridlineColor,
      majorGridlineWidth: majorGridlineWidth ?? this.majorGridlineWidth,
      minorGridlineColor: minorGridlineColor ?? this.minorGridlineColor,
      minorGridlineWidth: minorGridlineWidth ?? this.minorGridlineWidth,
      timedEventBorderRadius:
          timedEventBorderRadius ?? this.timedEventBorderRadius,
      timedEventMinHeight: timedEventMinHeight ?? this.timedEventMinHeight,
      timedEventPadding: timedEventPadding ?? this.timedEventPadding,
      resizeHandleSize: resizeHandleSize ?? this.resizeHandleSize,
      eventTileBackgroundColor:
          eventTileBackgroundColor ?? this.eventTileBackgroundColor,
    );
  }

  /// Build [MCalThemeData] from these settings, merging with base theme.
  MCalThemeData toThemeData(ThemeData baseTheme) {
    final colorScheme = baseTheme.colorScheme;
    final base = MCalThemeData.fromTheme(baseTheme);
    return base.copyWith(
      hourGridlineColor:
          hourGridlineColor ?? colorScheme.outline.withValues(alpha: 0.2),
      hourGridlineWidth: hourGridlineWidth,
      majorGridlineColor:
          majorGridlineColor ?? colorScheme.outline.withValues(alpha: 0.15),
      majorGridlineWidth: majorGridlineWidth,
      minorGridlineColor:
          minorGridlineColor ?? colorScheme.outline.withValues(alpha: 0.08),
      minorGridlineWidth: minorGridlineWidth,
      allDaySectionMaxRows: allDaySectionMaxRows,
      timedEventBorderRadius: timedEventBorderRadius,
      timedEventMinHeight: timedEventMinHeight,
      timedEventPadding: timedEventPadding,
      resizeHandleSize: resizeHandleSize,
      eventTileBackgroundColor:
          eventTileBackgroundColor ?? colorScheme.primaryContainer,
    );
  }

  /// Create settings from a preset.
  static DayViewThemeSettings fromPreset(
    DayViewThemePreset preset,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;
    switch (preset) {
      case DayViewThemePreset.defaultPreset:
        return DayViewThemeSettings(
          hourHeight: 80.0,
          timeSlotDuration: const Duration(minutes: 15),
          allDaySectionMaxRows: 3,
          hourGridlineWidth: 1.0,
          majorGridlineWidth: 1.0,
          minorGridlineWidth: 0.5,
          timedEventBorderRadius: 4.0,
          timedEventMinHeight: 20.0,
          timedEventPadding: const EdgeInsets.all(2.0),
          resizeHandleSize: 8.0,
        );
      case DayViewThemePreset.compact:
        return DayViewThemeSettings(
          hourHeight: 48.0,
          timeSlotDuration: const Duration(minutes: 15),
          allDaySectionMaxRows: 2,
          hourGridlineWidth: 0.5,
          majorGridlineWidth: 0.5,
          minorGridlineWidth: 0.25,
          timedEventBorderRadius: 2.0,
          timedEventMinHeight: 16.0,
          timedEventPadding: const EdgeInsets.symmetric(
            horizontal: 2,
            vertical: 1,
          ),
          resizeHandleSize: 6.0,
        );
      case DayViewThemePreset.spacious:
        return DayViewThemeSettings(
          hourHeight: 120.0,
          timeSlotDuration: const Duration(minutes: 30),
          allDaySectionMaxRows: 5,
          hourGridlineWidth: 1.5,
          majorGridlineWidth: 1.0,
          minorGridlineWidth: 0.5,
          timedEventBorderRadius: 8.0,
          timedEventMinHeight: 32.0,
          timedEventPadding: const EdgeInsets.all(8.0),
          resizeHandleSize: 12.0,
        );
      case DayViewThemePreset.highContrast:
        return DayViewThemeSettings(
          hourHeight: 80.0,
          timeSlotDuration: const Duration(minutes: 15),
          allDaySectionMaxRows: 3,
          hourGridlineColor: colorScheme.outline,
          hourGridlineWidth: 2.0,
          majorGridlineColor: colorScheme.outline.withValues(alpha: 0.7),
          majorGridlineWidth: 1.5,
          minorGridlineColor: colorScheme.outline.withValues(alpha: 0.4),
          minorGridlineWidth: 1.0,
          timedEventBorderRadius: 2.0,
          timedEventMinHeight: 24.0,
          timedEventPadding: const EdgeInsets.all(4.0),
          resizeHandleSize: 10.0,
          eventTileBackgroundColor: colorScheme.primary,
        );
      case DayViewThemePreset.minimal:
        return DayViewThemeSettings(
          hourHeight: 72.0,
          timeSlotDuration: const Duration(minutes: 30),
          allDaySectionMaxRows: 2,
          hourGridlineColor: colorScheme.outline.withValues(alpha: 0.08),
          hourGridlineWidth: 0.5,
          majorGridlineColor: colorScheme.outline.withValues(alpha: 0.05),
          majorGridlineWidth: 0.5,
          minorGridlineColor: Colors.transparent,
          minorGridlineWidth: 0.0,
          timedEventBorderRadius: 6.0,
          timedEventMinHeight: 24.0,
          timedEventPadding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 4,
          ),
          resizeHandleSize: 8.0,
        );
    }
  }
}

/// A settings panel for customizing Day View theme properties.
///
/// Provides sliders and dropdowns for all major theme properties.
/// Changes apply immediately via [onSettingsChanged] callback.
class DayViewThemeSettingsPanel extends StatelessWidget {
  const DayViewThemeSettingsPanel({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    required this.theme,
  });

  final DayViewThemeSettings settings;
  final ValueChanged<DayViewThemeSettings> onSettingsChanged;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Theme Presets',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DayViewThemePreset.values.map((preset) {
            final label = _presetLabel(preset);
            return FilterChip(
              label: Text(label),
              selected: _isPresetActive(preset),
              onSelected: (_) {
                onSettingsChanged(
                  DayViewThemeSettings.fromPreset(preset, theme),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text(
          'Layout',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        _SliderSetting(
          label: 'Hour height',
          value: settings.hourHeight,
          min: 40,
          max: 150,
          divisions: 11,
          onChanged: (v) => onSettingsChanged(settings.copyWith(hourHeight: v)),
        ),
        _DropdownSetting<int>(
          label: 'Time slot duration',
          value: settings.timeSlotDuration.inMinutes,
          items: const [
            (5, '5 min'),
            (10, '10 min'),
            (15, '15 min'),
            (20, '20 min'),
            (30, '30 min'),
            (60, '60 min'),
          ],
          onChanged: (v) => onSettingsChanged(
            settings.copyWith(timeSlotDuration: Duration(minutes: v)),
          ),
        ),
        _SliderSetting(
          label: 'All-day section max rows',
          value: settings.allDaySectionMaxRows.toDouble(),
          min: 1,
          max: 8,
          divisions: 7,
          onChanged: (v) => onSettingsChanged(
            settings.copyWith(allDaySectionMaxRows: v.round()),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Gridlines',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        _SliderSetting(
          label: 'Hour gridline width',
          value: settings.hourGridlineWidth,
          min: 0,
          max: 3,
          divisions: 30,
          onChanged: (v) =>
              onSettingsChanged(settings.copyWith(hourGridlineWidth: v)),
        ),
        _SliderSetting(
          label: 'Major gridline width',
          value: settings.majorGridlineWidth,
          min: 0,
          max: 3,
          divisions: 30,
          onChanged: (v) =>
              onSettingsChanged(settings.copyWith(majorGridlineWidth: v)),
        ),
        _SliderSetting(
          label: 'Minor gridline width',
          value: settings.minorGridlineWidth,
          min: 0,
          max: 2,
          divisions: 20,
          onChanged: (v) =>
              onSettingsChanged(settings.copyWith(minorGridlineWidth: v)),
        ),
        const SizedBox(height: 24),
        Text(
          'Event Tiles',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        _SliderSetting(
          label: 'Border radius',
          value: settings.timedEventBorderRadius,
          min: 0,
          max: 16,
          divisions: 16,
          onChanged: (v) =>
              onSettingsChanged(settings.copyWith(timedEventBorderRadius: v)),
        ),
        _SliderSetting(
          label: 'Min height',
          value: settings.timedEventMinHeight,
          min: 12,
          max: 48,
          divisions: 36,
          onChanged: (v) =>
              onSettingsChanged(settings.copyWith(timedEventMinHeight: v)),
        ),
        const SizedBox(height: 24),
        Text(
          'Resize Handle',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        _SliderSetting(
          label: 'Handle size',
          value: settings.resizeHandleSize,
          min: 4,
          max: 20,
          divisions: 16,
          onChanged: (v) =>
              onSettingsChanged(settings.copyWith(resizeHandleSize: v)),
        ),
      ],
    );
  }

  String _presetLabel(DayViewThemePreset preset) {
    switch (preset) {
      case DayViewThemePreset.defaultPreset:
        return 'Default';
      case DayViewThemePreset.compact:
        return 'Compact';
      case DayViewThemePreset.spacious:
        return 'Spacious';
      case DayViewThemePreset.highContrast:
        return 'High contrast';
      case DayViewThemePreset.minimal:
        return 'Minimal';
    }
  }

  bool _isPresetActive(DayViewThemePreset preset) {
    final p = DayViewThemeSettings.fromPreset(preset, theme);
    return p.hourHeight == settings.hourHeight &&
        p.timeSlotDuration == settings.timeSlotDuration &&
        p.allDaySectionMaxRows == settings.allDaySectionMaxRows &&
        p.hourGridlineWidth == settings.hourGridlineWidth &&
        p.timedEventBorderRadius == settings.timedEventBorderRadius &&
        p.resizeHandleSize == settings.resizeHandleSize;
  }
}

class _SliderSetting extends StatelessWidget {
  const _SliderSetting({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: textTheme.bodyMedium),
              Text(
                value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1),
                style: textTheme.bodySmall,
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _DropdownSetting<T> extends StatelessWidget {
  const _DropdownSetting({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<(T value, String label)> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.bodyMedium),
          const SizedBox(height: 4),
          DropdownButtonFormField<T>(
            initialValue: value,
            isExpanded: true,
            items: items
                .map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2)))
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}
