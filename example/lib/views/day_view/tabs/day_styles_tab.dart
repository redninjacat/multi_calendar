import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/utils/sample_events.dart';
import '../../../shared/widgets/style_description.dart';
import '../styles/day_classic_style.dart';
import '../styles/day_colorful_style.dart';
import '../styles/day_default_style.dart';
import '../styles/day_minimal_style.dart';
import '../styles/day_modern_style.dart';

/// Day View Styles tab - allows switching between different Day View style presets.
///
/// Each style demonstrates a different approach to Day View theming and customization.
/// Styles range from bare-bones defaults to highly customized themes with builders.
class DayStylesTab extends StatefulWidget {
  const DayStylesTab({
    super.key,
    required this.locale,
    required this.isDarkMode,
  });

  final Locale locale;
  final bool isDarkMode;

  @override
  State<DayStylesTab> createState() => _DayStylesTabState();
}

class _DayStylesTabState extends State<DayStylesTab> {
  late MCalEventController _eventController;
  String _selectedStyle = 'default';

  @override
  void initState() {
    super.initState();
    _eventController = MCalEventController();
    _loadSampleEvents();
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  void _loadSampleEvents() {
    // Import and use createDayViewSampleEvents from shared utils
    final events = createDayViewSampleEvents(DateTime.now());
    _eventController.addEvents(events);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Style selector dropdown
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            border: Border(
              bottom: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.palette_outlined,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Style:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border.all(
                      color: colorScheme.outline,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStyle,
                      isExpanded: true,
                      isDense: true,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'default',
                          child: Text(l10n.styleDefault),
                        ),
                        DropdownMenuItem(
                          value: 'modern',
                          child: Text(l10n.styleModern),
                        ),
                        DropdownMenuItem(
                          value: 'classic',
                          child: Text(l10n.styleClassic),
                        ),
                        DropdownMenuItem(
                          value: 'minimal',
                          child: Text(l10n.styleMinimal),
                        ),
                        DropdownMenuItem(
                          value: 'colorful',
                          child: Text(l10n.styleColorful),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedStyle = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Style description
        StyleDescription(
          description: _getStyleDescription(l10n),
        ),
        // Selected style widget
        Expanded(
          child: _buildSelectedStyle(),
        ),
      ],
    );
  }

  String _getStyleDescription(AppLocalizations l10n) {
    switch (_selectedStyle) {
      case 'default':
        return l10n.styleDefaultDescription;
      case 'modern':
        return l10n.styleModernDescription;
      case 'classic':
        return l10n.styleClassicDescription;
      case 'minimal':
        return l10n.styleMinimalDescription;
      case 'colorful':
        return l10n.styleColorfulDescription;
      default:
        return l10n.styleDefaultDescription;
    }
  }

  Widget _buildSelectedStyle() {
    switch (_selectedStyle) {
      case 'default':
        return DayDefaultStyle(
          eventController: _eventController,
          locale: widget.locale,
        );
      case 'modern':
        return DayModernStyle(
          eventController: _eventController,
          locale: widget.locale,
          isDarkMode: widget.isDarkMode,
        );
      case 'classic':
        return DayClassicStyle(
          eventController: _eventController,
          locale: widget.locale,
          isDarkMode: widget.isDarkMode,
        );
      case 'minimal':
        return DayMinimalStyle(
          eventController: _eventController,
          locale: widget.locale,
          isDarkMode: widget.isDarkMode,
        );
      case 'colorful':
        return DayColorfulStyle(
          eventController: _eventController,
          locale: widget.locale,
          isDarkMode: widget.isDarkMode,
        );
      default:
        return DayDefaultStyle(
          eventController: _eventController,
          locale: widget.locale,
        );
    }
  }
}
