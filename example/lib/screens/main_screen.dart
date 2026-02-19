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

  List<Widget> _buildAppBarActions(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return [
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
          _buildLocaleMenuItem(const Locale('en'), l10n.languageEnglish, colorScheme),
          _buildLocaleMenuItem(const Locale('es'), l10n.languageSpanish, colorScheme),
          _buildLocaleMenuItem(const Locale('fr'), l10n.languageFrench, colorScheme),
          _buildLocaleMenuItem(const Locale('ar'), l10n.languageArabic, colorScheme),
          _buildLocaleMenuItem(const Locale('he'), l10n.languageHebrew, colorScheme),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    // Use bottom nav on narrow screens, side rail on wider screens.
    final isNarrow = MediaQuery.sizeOf(context).width < 600;

    // On narrow screens the Comparison view is unavailable; clamp the index.
    final effectiveIndex = (isNarrow && _selectedViewType == 2) ? 0 : _selectedViewType;

    final viewTitle = switch (effectiveIndex) {
      1 => l10n.dayView,
      2 => l10n.comparisonView,
      _ => l10n.monthView,
    };

    final appBar = AppBar(
      elevation: 0,
      backgroundColor: colorScheme.surface,
      title: Text(
        viewTitle,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: _buildAppBarActions(context, colorScheme, l10n),
    );

    if (isNarrow) {
      return Scaffold(
        appBar: appBar,
        body: SafeArea(child: _buildViewTypeContent(effectiveIndex)),
        bottomNavigationBar: NavigationBar(
          // Comparison is index 2 in the stack but not present in narrow nav,
          // so clamp to 0 (Month View) if it was somehow selected.
          selectedIndex: effectiveIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedViewType = index),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.calendar_view_month_outlined),
              selectedIcon: const Icon(Icons.calendar_view_month),
              label: l10n.monthView,
            ),
            NavigationDestination(
              icon: const Icon(Icons.view_day_outlined),
              selectedIcon: const Icon(Icons.view_day),
              label: l10n.dayView,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: effectiveIndex,
              onDestinationSelected: (index) =>
                  setState(() => _selectedViewType = index),
              labelType: NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.calendar_view_month_outlined),
                  selectedIcon: const Icon(Icons.calendar_view_month),
                  label: Text(l10n.monthView),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.view_day_outlined),
                  selectedIcon: const Icon(Icons.view_day),
                  label: Text(l10n.dayView),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.compare_arrows),
                  label: Text(l10n.comparisonView),
                ),
              ],
            ),
            Expanded(child: _buildViewTypeContent(effectiveIndex)),
          ],
        ),
      ),
    );
  }

  Widget _buildViewTypeContent(int index) {
    // Use IndexedStack to keep all views alive and preserve their state
    // This ensures tab selections are remembered when switching between views
    return IndexedStack(
      index: index,
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
