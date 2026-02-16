import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/utils/sample_events.dart';
import '../styles/month_classic_style.dart';
import '../styles/month_colorful_style.dart';
import '../styles/month_default_style.dart';
import '../styles/month_minimal_style.dart';
import '../styles/month_modern_style.dart';

/// Month View Styles tab - demonstrates different visual styles.
///
/// This tab shows a dropdown selector with 5 style options:
/// - Default: Pure library defaults with zero customization
/// - Modern: Rounded, colorful, contemporary design with dots
/// - Classic: Traditional grid with borders
/// - Minimal: Clean with lots of whitespace
/// - Colorful: Vibrant gradients and bold colors
class MonthStylesTab extends StatefulWidget {
  const MonthStylesTab({
    super.key,
    required this.locale,
    required this.isDarkMode,
  });

  final Locale locale;
  final bool isDarkMode;

  @override
  State<MonthStylesTab> createState() => _MonthStylesTabState();
}

class _MonthStylesTabState extends State<MonthStylesTab> {
  late MCalEventController _eventController;
  DateTime? _selectedDate;
  
  // Available style options
  final _styleOptions = [
    'default',
    'modern',
    'classic',
    'minimal',
    'colorful',
  ];
  
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
    _eventController.addEvents(createSampleEvents());
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  String _getStyleName(String styleKey) {
    final l10n = AppLocalizations.of(context)!;
    switch (styleKey) {
      case 'default':
        return l10n.styleDefault;
      case 'modern':
        return l10n.styleModern;
      case 'classic':
        return l10n.styleClassic;
      case 'minimal':
        return l10n.styleMinimal;
      case 'colorful':
        return l10n.styleColorful;
      default:
        return styleKey;
    }
  }

  String _getStyleDescription(String styleKey) {
    final l10n = AppLocalizations.of(context)!;
    switch (styleKey) {
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
        return '';
    }
  }

  Widget _buildStyleWidget() {
    final description = _getStyleDescription(_selectedStyle);
    
    switch (_selectedStyle) {
      case 'default':
        return MonthDefaultStyle(
          eventController: _eventController,
          locale: widget.locale,
          description: description,
        );
      case 'modern':
        return MonthModernStyle(
          eventController: _eventController,
          locale: widget.locale,
          isDarkMode: widget.isDarkMode,
          selectedDate: _selectedDate,
          onDateSelected: _onDateSelected,
          description: description,
        );
      case 'classic':
        return MonthClassicStyle(
          eventController: _eventController,
          locale: widget.locale,
          isDarkMode: widget.isDarkMode,
          selectedDate: _selectedDate,
          onDateSelected: _onDateSelected,
          description: description,
        );
      case 'minimal':
        return MonthMinimalStyle(
          eventController: _eventController,
          locale: widget.locale,
          isDarkMode: widget.isDarkMode,
          selectedDate: _selectedDate,
          onDateSelected: _onDateSelected,
          description: description,
        );
      case 'colorful':
        return MonthColorfulStyle(
          eventController: _eventController,
          locale: widget.locale,
          isDarkMode: widget.isDarkMode,
          selectedDate: _selectedDate,
          onDateSelected: _onDateSelected,
          description: description,
        );
      default:
        return MonthDefaultStyle(
          eventController: _eventController,
          locale: widget.locale,
          description: description,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      items: _styleOptions.map((styleKey) {
                        return DropdownMenuItem(
                          value: styleKey,
                          child: Text(_getStyleName(styleKey)),
                        );
                      }).toList(),
                      onChanged: (newStyle) {
                        if (newStyle != null) {
                          setState(() {
                            _selectedStyle = newStyle;
                            // Reset selection when changing styles
                            _selectedDate = null;
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
        // Selected style widget
        Expanded(
          child: _buildStyleWidget(),
        ),
      ],
    );
  }
}
