import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

/// Predefined theme presets for calendar views.
///
/// Each preset provides a distinct visual style that can be applied
/// to Month View or Day View. Presets are designed to showcase
/// different use cases: default Material 3 styling, compact layouts,
/// spacious layouts, high contrast for accessibility, and minimal styling.
enum ThemePreset {
  /// Default Material 3 theme with balanced spacing and colors.
  defaultPreset,

  /// Compact theme with reduced spacing and smaller elements for dense displays.
  compact,

  /// Spacious theme with increased padding and larger elements for comfortable viewing.
  spacious,

  /// High contrast theme with strong colors for improved accessibility.
  highContrast,

  /// Minimal theme with subtle styling and reduced visual elements.
  minimal,
}

/// Returns a [MCalThemeData] configured for Month View based on the given [preset].
///
/// The returned theme includes both shared properties and Month View-specific
/// properties in [monthTheme]. Use this with [MCalTheme] to apply the preset
/// to a [MCalMonthView].
///
/// Example:
/// ```dart
/// MCalTheme(
///   data: getMonthThemePreset(ThemePreset.compact, Theme.of(context)),
///   child: MCalMonthView(controller: controller),
/// )
/// ```
MCalThemeData getMonthThemePreset(ThemePreset preset, ThemeData materialTheme) {
  final colorScheme = materialTheme.colorScheme;
  final textTheme = materialTheme.textTheme;

  switch (preset) {
    case ThemePreset.defaultPreset:
      // Use library defaults
      return MCalThemeData.fromTheme(materialTheme);

    case ThemePreset.compact:
      return MCalThemeData(
        cellBackgroundColor: colorScheme.surface,
        cellBorderColor: colorScheme.outline.withValues(alpha: 0.15),
        eventTileBackgroundColor: colorScheme.primaryContainer,
        eventTileTextStyle: textTheme.labelSmall?.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontSize: 10,
        ),
        eventTileCornerRadius: 2.0,
        eventTileHorizontalSpacing: 0.5,
        navigatorTextStyle: textTheme.titleSmall?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        navigatorBackgroundColor: colorScheme.surfaceContainerHighest,
        weekNumberTextStyle: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.4),
          fontSize: 10,
        ),
        weekNumberBackgroundColor: colorScheme.surfaceContainer,
        monthTheme: MCalMonthThemeData(
          eventTileHeight: 18.0,
          eventTileVerticalSpacing: 1.0,
          dateLabelHeight: 20.0,
          overflowIndicatorHeight: 16.0,
          weekdayHeaderTextStyle: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

    case ThemePreset.spacious:
      return MCalThemeData(
        cellBackgroundColor: colorScheme.surface,
        cellBorderColor: colorScheme.outline.withValues(alpha: 0.25),
        eventTileBackgroundColor: colorScheme.primaryContainer,
        eventTileTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontSize: 14,
        ),
        eventTileCornerRadius: 6.0,
        eventTileHorizontalSpacing: 4.0,
        navigatorTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        navigatorBackgroundColor: colorScheme.surfaceContainerLow,
        weekNumberTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        weekNumberBackgroundColor: colorScheme.surfaceContainerHighest,
        monthTheme: MCalMonthThemeData(
          eventTileHeight: 32.0,
          eventTileVerticalSpacing: 4.0,
          dateLabelHeight: 32.0,
          overflowIndicatorHeight: 28.0,
          weekdayHeaderTextStyle: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      );

    case ThemePreset.highContrast:
      return MCalThemeData(
        cellBackgroundColor: colorScheme.surface,
        cellBorderColor: colorScheme.onSurface.withValues(alpha: 0.5),
        eventTileBackgroundColor: colorScheme.primary,
        eventTileTextStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
        eventTileCornerRadius: 4.0,
        eventTileHorizontalSpacing: 2.0,
        navigatorTextStyle: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        navigatorBackgroundColor: colorScheme.surfaceContainerHighest,
        weekNumberTextStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        weekNumberBackgroundColor: colorScheme.surfaceContainer,
        monthTheme: MCalMonthThemeData(
          eventTileHeight: 24.0,
          eventTileVerticalSpacing: 2.0,
          dateLabelHeight: 28.0,
          todayBackgroundColor: colorScheme.primaryContainer,
          todayTextStyle: textTheme.labelLarge?.copyWith(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
          cellTextStyle: textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          weekdayHeaderTextStyle: textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          hoverCellBackgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
          dropTargetCellValidColor: colorScheme.primary.withValues(alpha: 0.4),
          dropTargetCellInvalidColor: colorScheme.error.withValues(alpha: 0.4),
        ),
      );

    case ThemePreset.minimal:
      return MCalThemeData(
        cellBackgroundColor: Colors.transparent,
        cellBorderColor: colorScheme.outline.withValues(alpha: 0.1),
        eventTileBackgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.5),
        eventTileTextStyle: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.8),
        ),
        eventTileCornerRadius: 2.0,
        eventTileHorizontalSpacing: 1.0,
        navigatorTextStyle: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.8),
          fontWeight: FontWeight.normal,
        ),
        navigatorBackgroundColor: Colors.transparent,
        weekNumberTextStyle: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.3),
        ),
        weekNumberBackgroundColor: Colors.transparent,
        monthTheme: MCalMonthThemeData(
          eventTileHeight: 20.0,
          eventTileVerticalSpacing: 1.5,
          dateLabelHeight: 24.0,
          weekdayHeaderTextStyle: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.w400,
          ),
          weekdayHeaderBackgroundColor: Colors.transparent,
          todayBackgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          hoverCellBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.03),
        ),
      );
  }
}

/// Returns a [MCalThemeData] configured for Day View based on the given [preset].
///
/// The returned theme includes both shared properties and Day View-specific
/// properties in [dayTheme]. Use this with [MCalTheme] to apply the preset
/// to a [MCalDayView].
///
/// Example:
/// ```dart
/// MCalTheme(
///   data: getDayThemePreset(ThemePreset.compact, Theme.of(context)),
///   child: MCalDayView(controller: controller),
/// )
/// ```
MCalThemeData getDayThemePreset(ThemePreset preset, ThemeData materialTheme) {
  final colorScheme = materialTheme.colorScheme;
  final textTheme = materialTheme.textTheme;

  switch (preset) {
    case ThemePreset.defaultPreset:
      // Use library defaults
      return MCalThemeData.fromTheme(materialTheme);

    case ThemePreset.compact:
      return MCalThemeData(
        cellBackgroundColor: colorScheme.surface,
        cellBorderColor: colorScheme.outline.withValues(alpha: 0.15),
        eventTileBackgroundColor: colorScheme.primaryContainer,
        eventTileTextStyle: textTheme.labelSmall?.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontSize: 10,
        ),
        eventTileCornerRadius: 2.0,
        navigatorTextStyle: textTheme.titleSmall?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        navigatorBackgroundColor: colorScheme.surfaceContainerHighest,
        allDayEventBackgroundColor: colorScheme.secondaryContainer,
        allDayEventTextStyle: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSecondaryContainer,
          fontSize: 10,
        ),
        allDayEventBorderWidth: 0.5,
        dayTheme: MCalDayThemeData(
          timeLegendWidth: 48.0,
          timeLegendTextStyle: textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: colorScheme.onSurfaceVariant,
          ),
          hourGridlineWidth: 0.5,
          majorGridlineWidth: 0.5,
          minorGridlineWidth: 0.25,
          timedEventMinHeight: 16.0,
          timedEventPadding: const EdgeInsets.symmetric(
            horizontal: 3,
            vertical: 1,
          ),
          timedEventBorderRadius: 2.0,
        ),
      );

    case ThemePreset.spacious:
      return MCalThemeData(
        cellBackgroundColor: colorScheme.surface,
        cellBorderColor: colorScheme.outline.withValues(alpha: 0.25),
        eventTileBackgroundColor: colorScheme.primaryContainer,
        eventTileTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontSize: 14,
        ),
        eventTileCornerRadius: 8.0,
        navigatorTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        navigatorBackgroundColor: colorScheme.surfaceContainerLow,
        allDayEventBackgroundColor: colorScheme.secondaryContainer,
        allDayEventTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSecondaryContainer,
        ),
        allDayEventBorderWidth: 2.0,
        dayTheme: MCalDayThemeData(
          timeLegendWidth: 80.0,
          timeLegendTextStyle: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          hourGridlineWidth: 1.5,
          majorGridlineWidth: 1.0,
          minorGridlineWidth: 0.5,
          currentTimeIndicatorWidth: 3.0,
          currentTimeIndicatorDotRadius: 5.0,
          timedEventMinHeight: 32.0,
          timedEventPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          timedEventBorderRadius: 8.0,
        ),
      );

    case ThemePreset.highContrast:
      return MCalThemeData(
        cellBackgroundColor: colorScheme.surface,
        cellBorderColor: colorScheme.onSurface.withValues(alpha: 0.5),
        eventTileBackgroundColor: colorScheme.primary,
        eventTileTextStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
        eventTileCornerRadius: 4.0,
        navigatorTextStyle: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        navigatorBackgroundColor: colorScheme.surfaceContainerHighest,
        allDayEventBackgroundColor: colorScheme.secondary,
        allDayEventTextStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSecondary,
          fontWeight: FontWeight.w600,
        ),
        allDayEventBorderColor: colorScheme.onSurface.withValues(alpha: 0.4),
        allDayEventBorderWidth: 2.0,
        dayTheme: MCalDayThemeData(
          timeLegendWidth: 64.0,
          timeLegendTextStyle: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          timeLegendBackgroundColor: colorScheme.surfaceContainerHighest,
          hourGridlineColor: colorScheme.onSurface.withValues(alpha: 0.3),
          hourGridlineWidth: 1.5,
          majorGridlineColor: colorScheme.onSurface.withValues(alpha: 0.2),
          majorGridlineWidth: 1.0,
          minorGridlineColor: colorScheme.onSurface.withValues(alpha: 0.1),
          minorGridlineWidth: 0.5,
          currentTimeIndicatorColor: colorScheme.error,
          currentTimeIndicatorWidth: 3.0,
          currentTimeIndicatorDotRadius: 4.0,
          timedEventMinHeight: 24.0,
          timedEventPadding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 3,
          ),
          timedEventBorderRadius: 4.0,
          showTimeLegendTicks: true,
          timeLegendTickColor: colorScheme.onSurface.withValues(alpha: 0.3),
          timeLegendTickWidth: 1.5,
          timeLegendTickLength: 10.0,
        ),
      );

    case ThemePreset.minimal:
      return MCalThemeData(
        cellBackgroundColor: Colors.transparent,
        cellBorderColor: colorScheme.outline.withValues(alpha: 0.1),
        eventTileBackgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.5),
        eventTileTextStyle: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.8),
        ),
        eventTileCornerRadius: 2.0,
        navigatorTextStyle: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.8),
          fontWeight: FontWeight.normal,
        ),
        navigatorBackgroundColor: Colors.transparent,
        allDayEventBackgroundColor: colorScheme.secondaryContainer.withValues(alpha: 0.5),
        allDayEventTextStyle: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.8),
        ),
        allDayEventBorderColor: colorScheme.outline.withValues(alpha: 0.2),
        allDayEventBorderWidth: 0.5,
        dayTheme: MCalDayThemeData(
          timeLegendWidth: 56.0,
          timeLegendTextStyle: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          timeLegendBackgroundColor: Colors.transparent,
          hourGridlineColor: colorScheme.outline.withValues(alpha: 0.1),
          hourGridlineWidth: 0.5,
          majorGridlineColor: colorScheme.outline.withValues(alpha: 0.05),
          majorGridlineWidth: 0.5,
          minorGridlineColor: colorScheme.outline.withValues(alpha: 0.03),
          minorGridlineWidth: 0.25,
          currentTimeIndicatorColor: colorScheme.primary.withValues(alpha: 0.6),
          currentTimeIndicatorWidth: 1.5,
          currentTimeIndicatorDotRadius: 3.0,
          timedEventMinHeight: 20.0,
          timedEventPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 2,
          ),
          timedEventBorderRadius: 2.0,
        ),
      );
  }
}
