import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/sample_events.dart';
import 'accessibility_demo.dart';
import 'styles/classic_style.dart';
import 'styles/colorful_style.dart';
import 'styles/default_style.dart';
import 'styles/features_demo_style.dart';
import 'styles/minimal_style.dart';
import 'styles/modern_style.dart';
import 'styles/stress_test_style.dart';
import 'theme_customization_showcase.dart';

/// Information about a Day View style tab.
class DayStyleTabInfo {
  final String name;
  final String description;

  const DayStyleTabInfo({required this.name, required this.description});
}

/// Showcase for Day View with multiple style tabs and drag-and-drop.
///
/// Demonstrates FR-1 through FR-16:
/// - All-day events and timed events
/// - Drag-to-move and resize
/// - Different configurations (hour range, gridline intervals)
/// - Multiple visual styles (classic, modern, colorful)
class DayViewShowcase extends StatefulWidget {
  const DayViewShowcase({
    super.key,
    required this.currentLocale,
    required this.isDarkMode,
  });

  final Locale currentLocale;
  final bool isDarkMode;

  @override
  State<DayViewShowcase> createState() => _DayViewShowcaseState();
}

class _DayViewShowcaseState extends State<DayViewShowcase>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MCalEventController _eventController;

  List<DayStyleTabInfo> _buildStyles(AppLocalizations l10n) => [
    DayStyleTabInfo(
      name: l10n.styleFeaturesDemo,
      description: l10n.styleFeaturesDemoDescription,
    ),
    DayStyleTabInfo(
      name: l10n.styleDefault,
      description: l10n.styleDefaultDescription,
    ),
    DayStyleTabInfo(
      name: l10n.styleClassic,
      description: l10n.styleClassicDescription,
    ),
    DayStyleTabInfo(
      name: l10n.styleModern,
      description: l10n.styleModernDescription,
    ),
    DayStyleTabInfo(
      name: l10n.styleColorful,
      description: l10n.styleColorfulDescription,
    ),
    DayStyleTabInfo(
      name: l10n.styleMinimal,
      description: l10n.styleMinimalDescription,
    ),
    DayStyleTabInfo(
      name: l10n.styleStressTest,
      description: l10n.styleStressTestDescription,
    ),
    DayStyleTabInfo(
      name: l10n.styleThemeCustomization,
      description: l10n.styleThemeCustomizationDescription,
    ),
    DayStyleTabInfo(
      name: l10n.styleAccessibility,
      description: l10n.styleAccessibilityDescription,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    final now = DateTime.now();
    _eventController = MCalEventController(initialDate: now);
    _eventController.addEvents(createDayViewSampleEvents(now));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _eventController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final styles = _buildStyles(l10n);

    return Column(
      children: [
        // Tab bar for different styles
        Container(
          color: colorScheme.surfaceContainerHighest,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: styles.map((style) => Tab(text: style.name)).toList(),
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              FeaturesDemoDayStyle(
                eventController: _eventController,
                locale: widget.currentLocale,
                isDarkMode: widget.isDarkMode,
                description: styles[0].description,
              ),
              DefaultDayStyle(
                eventController: _eventController,
                locale: widget.currentLocale,
                isDarkMode: widget.isDarkMode,
                description: styles[1].description,
              ),
              ClassicDayStyle(
                eventController: _eventController,
                locale: widget.currentLocale,
                isDarkMode: widget.isDarkMode,
                description: styles[2].description,
              ),
              ModernDayStyle(
                eventController: _eventController,
                locale: widget.currentLocale,
                isDarkMode: widget.isDarkMode,
                description: styles[3].description,
              ),
              ColorfulDayStyle(
                eventController: _eventController,
                locale: widget.currentLocale,
                isDarkMode: widget.isDarkMode,
                description: styles[4].description,
              ),
              MinimalDayStyle(
                eventController: _eventController,
                locale: widget.currentLocale,
                isDarkMode: widget.isDarkMode,
                description: styles[5].description,
              ),
              StressTestDayStyle(
                locale: widget.currentLocale,
                isDarkMode: widget.isDarkMode,
                description: styles[6].description,
              ),
              ThemeCustomizationShowcase(
                currentLocale: widget.currentLocale,
                isDarkMode: widget.isDarkMode,
              ),
              AccessibilityDemo(
                currentLocale: widget.currentLocale,
                isDarkMode: widget.isDarkMode,
              ),
            ],
          ),
        ),
      ],
    );
  }
}