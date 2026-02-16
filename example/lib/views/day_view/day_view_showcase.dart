import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'tabs/day_accessibility_tab.dart';
import 'tabs/day_features_tab.dart';
import 'tabs/day_stress_test_tab.dart';
import 'tabs/day_styles_tab.dart';
import 'tabs/day_theme_tab.dart';

/// Showcase for Day View with 5 tabs demonstrating different aspects.
///
/// Provides a comprehensive exploration of the Day View widget through:
/// - Features tab: Widget parameters and gesture handling
/// - Theme tab: Theme customization and presets
/// - Styles tab: Pre-built style examples
/// - Stress Test tab: Performance testing with many events
/// - Accessibility tab: Keyboard navigation and screen reader support
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Tab bar for different aspects
        Container(
          color: colorScheme.surfaceContainerHighest,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: l10n.tabFeatures),
              Tab(text: l10n.tabTheme),
              Tab(text: l10n.tabStyles),
              Tab(text: l10n.tabStressTest),
              Tab(text: l10n.tabAccessibility),
            ],
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              DayFeaturesTab(
                locale: widget.currentLocale,
                isDarkMode: widget.isDarkMode,
              ),
              // Theme tab
              const DayThemeTab(),
              // Styles tab
              DayStylesTab(
                locale: widget.currentLocale,
                isDarkMode: widget.isDarkMode,
              ),
              // Stress Test tab
              DayStressTestTab(
                locale: widget.currentLocale,
                isDarkMode: widget.isDarkMode,
              ),
              // Accessibility tab
              DayAccessibilityTab(
                locale: widget.currentLocale,
                isDarkMode: widget.isDarkMode,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
