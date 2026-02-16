import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'tabs/month_accessibility_tab.dart';
import 'tabs/month_features_tab.dart';
import 'tabs/month_stress_test_tab.dart';
import 'tabs/month_styles_tab.dart';
import 'tabs/month_theme_tab.dart';

/// Month View showcase with 5 tabs demonstrating different aspects of MCalMonthView.
///
/// Tabs:
/// - Features: Widget-level settings and gesture handlers
/// - Theme: Theme customization with presets
/// - Styles: Pre-built style examples
/// - Stress Test: Performance testing with many events
/// - Accessibility: Keyboard navigation and screen reader support
class MonthViewShowcase extends StatefulWidget {
  const MonthViewShowcase({
    super.key,
    required this.currentLocale,
    required this.isDarkMode,
  });

  final Locale currentLocale;
  final bool isDarkMode;

  @override
  State<MonthViewShowcase> createState() => _MonthViewShowcaseState();
}

class _MonthViewShowcaseState extends State<MonthViewShowcase>
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
        // Tab bar
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
              // Features tab
              const MonthFeaturesTab(),
              // Theme tab
              const MonthThemeTab(),
              // Styles tab
              MonthStylesTab(
                locale: widget.currentLocale,
                isDarkMode: widget.isDarkMode,
              ),
              // Stress Test tab
              const MonthStressTestTab(),
              // Accessibility tab
              const MonthAccessibilityTab(),
            ],
          ),
        ),
      ],
    );
  }
}
