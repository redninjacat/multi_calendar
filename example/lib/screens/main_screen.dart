import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../views/comparison/comparison_view.dart';
import '../views/day_view/day_view_showcase.dart';
import '../views/month_view/month_view_showcase.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    required this.onLocaleChanged,
    required this.onThemeToggle,
    required this.currentLocale,
    required this.isDarkMode,
  });

  final void Function(Locale) onLocaleChanged;
  final VoidCallback onThemeToggle;
  final Locale currentLocale;
  final bool isDarkMode;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedViewType = 0;

  PopupMenuItem<Locale> _buildLocaleMenuItem(
    Locale locale,
    String label,
    ColorScheme colorScheme,
  ) {
    final isSelected = widget.currentLocale.languageCode == locale.languageCode;
    return PopupMenuItem<Locale>(
      value: locale,
      child: Row(
        children: [
          if (isSelected)
            Icon(Icons.check, size: 18, color: colorScheme.primary),
          if (isSelected) const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        title: Text(
          l10n.appTitle,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: colorScheme.onSurface,
            ),
            onPressed: widget.onThemeToggle,
            tooltip: l10n.toggleTheme,
          ),
          PopupMenuButton<Locale>(
            icon: Icon(Icons.translate, color: colorScheme.onSurface),
            tooltip: l10n.changeLanguage,
            onSelected: widget.onLocaleChanged,
            itemBuilder: (context) => [
              _buildLocaleMenuItem(
                const Locale('en'),
                l10n.languageEnglish,
                colorScheme,
              ),
              _buildLocaleMenuItem(
                const Locale('es'),
                l10n.languageSpanish,
                colorScheme,
              ),
              _buildLocaleMenuItem(
                const Locale('fr'),
                l10n.languageFrench,
                colorScheme,
              ),
              _buildLocaleMenuItem(
                const Locale('ar'),
                l10n.languageArabic,
                colorScheme,
              ),
              _buildLocaleMenuItem(
                const Locale('he'),
                l10n.languageHebrew,
                colorScheme,
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedViewType,
              onDestinationSelected: (index) {
                setState(() => _selectedViewType = index);
              },
              labelType: NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.calendar_view_month),
                  label: Text(l10n.monthView),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.view_day),
                  label: Text(l10n.dayView),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.compare_arrows),
                  label: Text(l10n.comparisonView),
                ),
              ],
            ),
            Expanded(child: _buildViewTypeContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildViewTypeContent() {
    // Use IndexedStack to keep all views alive and preserve their state
    // This ensures tab selections are remembered when switching between views
    return IndexedStack(
      index: _selectedViewType,
      children: [
        MonthViewShowcase(
          currentLocale: widget.currentLocale,
          isDarkMode: widget.isDarkMode,
        ),
        DayViewShowcase(
          currentLocale: widget.currentLocale,
          isDarkMode: widget.isDarkMode,
        ),
        ComparisonView(
          currentLocale: widget.currentLocale,
          isDarkMode: widget.isDarkMode,
        ),
      ],
    );
  }
}
