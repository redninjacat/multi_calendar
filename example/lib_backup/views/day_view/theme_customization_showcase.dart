import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../utils/sample_events.dart';
import '../../widgets/event_detail_dialog.dart';
import '../../widgets/style_description.dart';
import 'day_view_theme_settings.dart';

/// Showcase for Day View theme customization.
///
/// Demonstrates MCalTheme usage with a settings panel to customize:
/// - Hour height
/// - Gridline colors and widths
/// - Time slot duration
/// - All-day section max rows
/// - Event tile styling
/// - Resize handle size
///
/// Theme changes apply immediately. Includes presets for common configurations.
class ThemeCustomizationShowcase extends StatefulWidget {
  const ThemeCustomizationShowcase({
    super.key,
    required this.currentLocale,
    required this.isDarkMode,
  });

  final Locale currentLocale;
  final bool isDarkMode;

  @override
  State<ThemeCustomizationShowcase> createState() =>
      _ThemeCustomizationShowcaseState();
}

class _ThemeCustomizationShowcaseState extends State<ThemeCustomizationShowcase> {
  late MCalEventController _eventController;
  DayViewThemeSettings _settings = const DayViewThemeSettings();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _eventController = MCalEventController(initialDate: now);
    _eventController.addEvents(createDayViewSampleEvents(now));
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          // Day View with customizable theme
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StyleDescription(
                  description:
                      'Customize theme properties in the settings panel. '
                      'Changes apply immediately. Use presets for quick configurations.',
                ),
                Expanded(
                  child: MCalTheme(
                    data: _settings.toThemeData(theme),
                    child: MCalDayView(
                      controller: _eventController,
                      hourHeight: _settings.hourHeight,
                      timeSlotDuration: _settings.timeSlotDuration,
                      gridlineInterval: _settings.timeSlotDuration,
                      allDaySectionMaxRows: _settings.allDaySectionMaxRows,
                      enableDragToMove: true,
                      enableDragToResize: true,
                      snapToTimeSlots: true,
                      showNavigator: true,
                      showCurrentTimeIndicator: true,
                      startHour: 8,
                      endHour: 20,
                      locale: widget.currentLocale,
                      onEventTap: (context, details) {
                        showEventDetailDialog(
                            context, details.event, widget.currentLocale);
                      },
                      onEventDropped: (details) {
                        if (context.mounted) {
                          final t = details.newStartDate;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Moved: ${details.event.title} to '
                                '${t.hour}:${t.minute.toString().padLeft(2, '0')}',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      onEventResized: (details) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Resized: ${details.event.title} to '
                                '${details.newEndDate.difference(details.newStartDate).inMinutes} min',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      onEmptySpaceDoubleTap: (time) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Double-tap at ${time.hour}:${time.minute.toString().padLeft(2, '0')} - Create event',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Settings panel
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              border: Border(
                left: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: DayViewThemeSettingsPanel(
              settings: _settings,
              theme: theme,
              onSettingsChanged: (newSettings) {
                setState(() => _settings = newSettings);
              },
            ),
          ),
        ],
      ),
    );
  }
}
