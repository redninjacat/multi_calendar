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

  /// Rounded theme with pill-shaped tiles, large corner radii, and soft colors.
  rounded,

  /// Bordered theme with visible tile borders and structured, clean styling.
  bordered,
}

/// Returns a [MCalThemeData] configured for Month View based on the given [preset].
///
/// The returned theme includes both shared properties and Month View-specific
/// properties in [monthViewTheme]. Use this with [MCalTheme] to apply the preset
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
        enableEventColorOverrides: true,
        cellBackgroundColor: colorScheme.surface,
        cellBorderColor: colorScheme.outline.withValues(alpha: 0.15),
        cellBorderWidth: 0.5,
        navigatorTextStyle: textTheme.titleSmall?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        navigatorBackgroundColor: colorScheme.surfaceContainerHighest,
        monthViewTheme: MCalMonthViewThemeData(
          eventTileBackgroundColor: const Color(0xFF06B6D4),
          eventTileTextStyle: textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontSize: 10,
          ),
          eventTileCornerRadius: 2.0,
          eventTileHorizontalSpacing: 0.5,
          weekNumberTextStyle: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            fontSize: 10,
          ),
          weekNumberBackgroundColor: colorScheme.surfaceContainer,
          eventTileHeight: 18.0,
          eventTileVerticalSpacing: 1.0,
          eventTilePadding: const EdgeInsets.symmetric(horizontal: 2.0),
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
        enableEventColorOverrides: true,
        cellBackgroundColor: colorScheme.surface,
        cellBorderColor: colorScheme.outline.withValues(alpha: 0.25),
        cellBorderWidth: 1.5,
        navigatorTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        navigatorBackgroundColor: colorScheme.surfaceContainerLow,
        navigatorPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        monthViewTheme: MCalMonthViewThemeData(
          eventTileBackgroundColor: const Color(0xFFF59E0B),
          eventTileTextStyle: textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF451A03),
            fontSize: 14,
          ),
          eventTileCornerRadius: 6.0,
          eventTileHorizontalSpacing: 4.0,
          weekNumberTextStyle: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          weekNumberBackgroundColor: colorScheme.surfaceContainerHighest,
          eventTileHeight: 32.0,
          eventTileVerticalSpacing: 4.0,
          eventTilePadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
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
        enableEventColorOverrides: true,
        cellBackgroundColor: colorScheme.surface,
        cellBorderColor: colorScheme.onSurface.withValues(alpha: 0.5),
        cellBorderWidth: 2.0,
        navigatorTextStyle: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        navigatorBackgroundColor: colorScheme.surfaceContainerHighest,
        monthViewTheme: MCalMonthViewThemeData(
          eventTileBackgroundColor: colorScheme.primary,
          eventTileTextStyle: textTheme.labelMedium?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
          eventTileCornerRadius: 4.0,
          eventTileHorizontalSpacing: 2.0,
          eventTileBorderWidth: 1.5,
          eventTileBorderColor: colorScheme.onSurface.withValues(alpha: 0.3),
          allDayEventBackgroundColor: colorScheme.secondary,
          allDayEventBorderColor: colorScheme.onSurface.withValues(alpha: 0.4),
          allDayEventBorderWidth: 1.5,
          weekNumberTextStyle: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          weekNumberBackgroundColor: colorScheme.surfaceContainer,
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
        enableEventColorOverrides: true,
        cellBackgroundColor: Colors.transparent,
        cellBorderColor: colorScheme.outline.withValues(alpha: 0.1),
        cellBorderWidth: 0.5,
        navigatorTextStyle: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.8),
          fontWeight: FontWeight.normal,
        ),
        navigatorBackgroundColor: Colors.transparent,
        monthViewTheme: MCalMonthViewThemeData(
          eventTileBackgroundColor: const Color(0xFF14B8A6).withValues(alpha: 0.35),
          eventTileTextStyle: textTheme.labelSmall?.copyWith(
            color: const Color(0xFF0F766E),
          ),
          eventTileCornerRadius: 2.0,
          eventTileHorizontalSpacing: 1.0,
          weekNumberTextStyle: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          weekNumberBackgroundColor: Colors.transparent,
          eventTileHeight: 20.0,
          eventTileVerticalSpacing: 1.5,
          dateLabelHeight: 24.0,
          weekdayHeaderTextStyle: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.w400,
          ),
          weekdayHeaderBackgroundColor: Colors.transparent,
          todayBackgroundColor: const Color(0xFF14B8A6).withValues(alpha: 0.1),
          hoverCellBackgroundColor: const Color(0xFF14B8A6).withValues(alpha: 0.05),
        ),
      );

    case ThemePreset.rounded:
      return MCalThemeData(
        enableEventColorOverrides: true,
        cellBackgroundColor: colorScheme.surface,
        cellBorderColor: colorScheme.outline.withValues(alpha: 0.12),
        cellBorderWidth: 0.5,
        navigatorTextStyle: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        navigatorBackgroundColor: colorScheme.surfaceContainerLow,
        navigatorPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        monthViewTheme: MCalMonthViewThemeData(
          eventTileBackgroundColor: const Color(0xFF10B981),
          eventTileTextStyle: textTheme.labelMedium?.copyWith(
            color: Colors.white,
          ),
          eventTileCornerRadius: 10.0,
          eventTileHorizontalSpacing: 2.0,
          eventTileVerticalSpacing: 3.0,
          eventTileHeight: 24.0,
          eventTilePadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          allDayEventBackgroundColor: const Color(0xFF10B981).withValues(alpha: 0.25),
          allDayEventBorderWidth: 0.0,
          allDayEventPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          weekNumberTextStyle: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          weekNumberBackgroundColor: colorScheme.surfaceContainerLow,
          dateLabelHeight: 26.0,
          overflowIndicatorHeight: 20.0,
          weekdayHeaderTextStyle: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
          weekdayHeaderBackgroundColor: colorScheme.surfaceContainerLow,
          todayBackgroundColor: const Color(0xFF10B981).withValues(alpha: 0.12),
          hoverCellBackgroundColor: const Color(0xFF10B981).withValues(alpha: 0.08),
        ),
      );

    case ThemePreset.bordered:
      return MCalThemeData(
        enableEventColorOverrides: true,
        cellBackgroundColor: colorScheme.surface,
        cellBorderColor: colorScheme.outline.withValues(alpha: 0.3),
        cellBorderWidth: 1.5,
        navigatorTextStyle: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        navigatorBackgroundColor: colorScheme.surfaceContainerHighest,
        monthViewTheme: MCalMonthViewThemeData(
          eventTileBackgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
          eventTileTextStyle: textTheme.labelMedium?.copyWith(
            color: const Color(0xFF5B21B6),
            fontWeight: FontWeight.w500,
          ),
          eventTileCornerRadius: 4.0,
          eventTileBorderWidth: 2.0,
          eventTileBorderColor: const Color(0xFF5B21B6),
          eventTileHorizontalSpacing: 2.0,
          eventTileVerticalSpacing: 2.0,
          eventTileHeight: 22.0,
          eventTilePadding: const EdgeInsets.symmetric(horizontal: 6.0),
          allDayEventBackgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
          allDayEventBorderColor: const Color(0xFF5B21B6),
          allDayEventBorderWidth: 2.0,
          allDayEventPadding: const EdgeInsets.symmetric(horizontal: 6.0),
          weekNumberTextStyle: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.w500,
          ),
          weekNumberBackgroundColor: colorScheme.surfaceContainer,
          dateLabelHeight: 22.0,
          overflowIndicatorHeight: 18.0,
          weekdayHeaderTextStyle: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
          todayBackgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
          hoverCellBackgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.05),
        ),
      );
  }
}

/// Returns a [MCalThemeData] configured for Day View based on the given [preset].
///
/// The returned theme includes both shared properties and Day View-specific
/// properties in [dayViewTheme]. Use this with [MCalTheme] to apply the preset
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
        enableEventColorOverrides: true,
        cellBackgroundColor: colorScheme.surface,
        cellBorderColor: colorScheme.outline.withValues(alpha: 0.15),
        cellBorderWidth: 0.5,
        navigatorTextStyle: textTheme.titleSmall?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        navigatorBackgroundColor: colorScheme.surfaceContainerHighest,
        dayViewTheme: MCalDayViewThemeData(
          eventTileBackgroundColor: const Color(0xFF06B6D4),
          eventTileTextStyle: textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontSize: 10,
          ),
          eventTileCornerRadius: 2.0,
          keyboardSelectionBorderRadius: 2.0,
          keyboardHighlightBorderRadius: 2.0,
          allDayEventBackgroundColor: const Color(0xFF06B6D4).withValues(alpha: 0.2),
          allDayEventTextStyle: textTheme.labelSmall?.copyWith(
            color: const Color(0xFF0E7490),
            fontSize: 10,
          ),
          allDayEventBorderWidth: 0.5,
          allDaySectionLabelBottomPadding: 2.0,
          timeLegendWidth: 48.0,
          timeLegendTextStyle: textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: colorScheme.onSurfaceVariant,
          ),
          hourGridlineWidth: 0.5,
          majorGridlineWidth: 0.5,
          minorGridlineWidth: 0.25,
          allDayEventPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 1,
          ),
          timedEventMinHeight: 16.0,
          timedEventPadding: const EdgeInsets.symmetric(
            horizontal: 3,
            vertical: 1,
          ),
          timedEventTitleTimeGap: 1.0,
          timedEventMargin: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 0.5),
          dayHeaderPadding: const EdgeInsets.all(4.0),
          dayHeaderSpacing: 4.0,
        ),
      );

    case ThemePreset.spacious:
      return MCalThemeData(
        enableEventColorOverrides: true,
        cellBackgroundColor: colorScheme.surface,
        cellBorderColor: colorScheme.outline.withValues(alpha: 0.25),
        cellBorderWidth: 1.5,
        navigatorTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        navigatorBackgroundColor: colorScheme.surfaceContainerLow,
        navigatorPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        dayViewTheme: MCalDayViewThemeData(
          eventTileBackgroundColor: const Color(0xFFF59E0B),
          eventTileTextStyle: textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF451A03),
            fontSize: 14,
          ),
          eventTileCornerRadius: 8.0,
          keyboardSelectionBorderRadius: 8.0,
          keyboardHighlightBorderRadius: 8.0,
          allDayEventBackgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.2),
          allDayEventTextStyle: textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF92400E),
          ),
          allDayEventBorderWidth: 2.0,
          allDaySectionLabelBottomPadding: 8.0,
          allDayOverflowIndicatorBorderWidth: 1.5,
          timeLegendWidth: 80.0,
          timeLegendTextStyle: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          hourGridlineWidth: 1.5,
          majorGridlineWidth: 1.0,
          minorGridlineWidth: 0.5,
          currentTimeIndicatorWidth: 3.0,
          currentTimeIndicatorDotRadius: 5.0,
          allDayEventPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          timedEventMinHeight: 32.0,
          timedEventPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          timedEventTitleTimeGap: 4.0,
          timedEventMargin: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 2.0),
          dayHeaderPadding: const EdgeInsets.all(12.0),
          dayHeaderSpacing: 12.0,
        ),
      );

    case ThemePreset.highContrast:
      return MCalThemeData(
        enableEventColorOverrides: true,
        cellBackgroundColor: colorScheme.surface,
        cellBorderColor: colorScheme.onSurface.withValues(alpha: 0.5),
        cellBorderWidth: 2.0,
        navigatorTextStyle: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        navigatorBackgroundColor: colorScheme.surfaceContainerHighest,
        dayViewTheme: MCalDayViewThemeData(
          eventTileBackgroundColor: colorScheme.primary,
          eventTileTextStyle: textTheme.labelMedium?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
          eventTileCornerRadius: 4.0,
          eventTileBorderWidth: 1.5,
          eventTileBorderColor: colorScheme.onSurface.withValues(alpha: 0.3),
          allDayEventBackgroundColor: colorScheme.secondary,
          allDayEventTextStyle: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSecondary,
            fontWeight: FontWeight.w600,
          ),
          allDayEventBorderColor: colorScheme.onSurface.withValues(alpha: 0.4),
          allDayEventBorderWidth: 2.0,
          allDayOverflowIndicatorBorderWidth: 2.0,
          allDaySectionLabelBottomPadding: 6.0,
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
          timedEventTitleTimeGap: 3.0,
          showTimeLegendTicks: true,
          timeLegendTickColor: colorScheme.onSurface.withValues(alpha: 0.3),
          timeLegendTickWidth: 1.5,
          timeLegendTickLength: 10.0,
        ),
      );

    case ThemePreset.minimal:
      return MCalThemeData(
        enableEventColorOverrides: true,
        cellBackgroundColor: Colors.transparent,
        cellBorderColor: colorScheme.outline.withValues(alpha: 0.1),
        cellBorderWidth: 0.5,
        navigatorTextStyle: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.8),
          fontWeight: FontWeight.normal,
        ),
        navigatorBackgroundColor: Colors.transparent,
        dayViewTheme: MCalDayViewThemeData(
          eventTileBackgroundColor: const Color(0xFF14B8A6).withValues(alpha: 0.35),
          eventTileTextStyle: textTheme.labelSmall?.copyWith(
            color: const Color(0xFF0F766E),
          ),
          eventTileCornerRadius: 2.0,
          keyboardSelectionBorderRadius: 2.0,
          keyboardHighlightBorderRadius: 2.0,
          allDayEventBackgroundColor: const Color(0xFF14B8A6).withValues(alpha: 0.18),
          allDayEventTextStyle: textTheme.labelSmall?.copyWith(
            color: const Color(0xFF0F766E),
          ),
          allDayEventBorderColor: colorScheme.outline.withValues(alpha: 0.2),
          allDayEventBorderWidth: 0.5,
          allDayOverflowIndicatorBorderWidth: 0.5,
          allDaySectionLabelBottomPadding: 2.0,
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
          currentTimeIndicatorColor: const Color(0xFF14B8A6),
          currentTimeIndicatorWidth: 1.5,
          currentTimeIndicatorDotRadius: 3.0,
          timedEventMinHeight: 20.0,
          timedEventPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 2,
          ),
        ),
      );

    case ThemePreset.rounded:
      return MCalThemeData(
        enableEventColorOverrides: true,
        cellBackgroundColor: colorScheme.surface,
        cellBorderColor: colorScheme.outline.withValues(alpha: 0.12),
        cellBorderWidth: 0.5,
        navigatorTextStyle: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        navigatorBackgroundColor: colorScheme.surfaceContainerLow,
        navigatorPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        dayViewTheme: MCalDayViewThemeData(
          eventTileBackgroundColor: const Color(0xFF10B981),
          eventTileTextStyle: textTheme.labelMedium?.copyWith(
            color: Colors.white,
          ),
          eventTileCornerRadius: 12.0,
          keyboardSelectionBorderRadius: 12.0,
          keyboardHighlightBorderRadius: 12.0,
          allDayEventBackgroundColor: const Color(0xFF10B981).withValues(alpha: 0.25),
          allDayEventTextStyle: textTheme.labelMedium?.copyWith(
            color: const Color(0xFF065F46),
          ),
          allDayEventBorderWidth: 0.0,
          allDaySectionLabelBottomPadding: 6.0,
          timeLegendWidth: 64.0,
          timeLegendTextStyle: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          hourGridlineColor: colorScheme.outline.withValues(alpha: 0.12),
          hourGridlineWidth: 1.0,
          majorGridlineColor: colorScheme.outline.withValues(alpha: 0.08),
          minorGridlineColor: colorScheme.outline.withValues(alpha: 0.04),
          minorGridlineWidth: 0.5,
          allDayEventPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          timedEventMinHeight: 28.0,
          timedEventPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          timedEventTitleTimeGap: 4.0,
          timedEventMargin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
          dayHeaderPadding: const EdgeInsets.all(12.0),
          dayHeaderSpacing: 12.0,
        ),
      );

    case ThemePreset.bordered:
      return MCalThemeData(
        enableEventColorOverrides: true,
        cellBackgroundColor: colorScheme.surface,
        cellBorderColor: colorScheme.outline.withValues(alpha: 0.3),
        cellBorderWidth: 1.5,
        navigatorTextStyle: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        navigatorBackgroundColor: colorScheme.surfaceContainerHighest,
        dayViewTheme: MCalDayViewThemeData(
          eventTileBackgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
          eventTileTextStyle: textTheme.labelMedium?.copyWith(
            color: const Color(0xFF5B21B6),
            fontWeight: FontWeight.w500,
          ),
          eventTileCornerRadius: 4.0,
          eventTileBorderWidth: 2.0,
          eventTileBorderColor: const Color(0xFF5B21B6),
          allDayEventBackgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
          allDayEventTextStyle: textTheme.labelMedium?.copyWith(
            color: const Color(0xFF5B21B6),
            fontWeight: FontWeight.w500,
          ),
          allDayEventBorderColor: const Color(0xFF5B21B6),
          allDayEventBorderWidth: 2.0,
          allDayOverflowIndicatorBorderWidth: 1.5,
          allDaySectionLabelBottomPadding: 6.0,
          timeLegendWidth: 64.0,
          timeLegendTextStyle: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          hourGridlineColor: colorScheme.outline.withValues(alpha: 0.25),
          hourGridlineWidth: 1.0,
          majorGridlineColor: colorScheme.outline.withValues(alpha: 0.15),
          majorGridlineWidth: 1.0,
          minorGridlineColor: colorScheme.outline.withValues(alpha: 0.08),
          minorGridlineWidth: 0.5,
          timedEventMinHeight: 22.0,
          timedEventPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          timedEventTitleTimeGap: 3.0,
        ),
      );
  }
}
