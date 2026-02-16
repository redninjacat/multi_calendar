import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../views/comparison/comparison_view.dart';
import '../views/day_view/day_view_showcase.dart';
import '../views/month_view/month_view_showcase.dart';

/// Information about a view type for navigation
class ViewTypeInfo {
  final String name;
  final IconData icon;
  final String description;

  const ViewTypeInfo({
    required this.name,
    required this.icon,
    required this.description,
  });
}

/// Main screen with navigation to different view type sections
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

  static const List<IconData> _viewTypeIcons = [
    Icons.calendar_view_month,
    Icons.view_day,
    Icons.compare_arrows,
  ];

  List<ViewTypeInfo> _buildViewTypes(AppLocalizations l10n) => [
    ViewTypeInfo(
      name: l10n.monthView,
      icon: _viewTypeIcons[0],
      description: l10n.monthViewDescription,
    ),
    ViewTypeInfo(
      name: l10n.dayView,
      icon: _viewTypeIcons[1],
      description: l10n.dayViewDescription,
    ),
    ViewTypeInfo(
      name: l10n.comparisonView,
      icon: _viewTypeIcons[2],
      description: l10n.comparisonViewDescription,
    ),
  ];

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
    final viewTypes = _buildViewTypes(l10n);

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
            // Side navigation for view types (only show if more than one type)
            if (viewTypes.length > 1)
              NavigationRail(
                selectedIndex: _selectedViewType,
                onDestinationSelected: (index) {
                  setState(() => _selectedViewType = index);
                },
                labelType: NavigationRailLabelType.all,
                destinations: viewTypes
                    .map(
                      (type) => NavigationRailDestination(
                        icon: Icon(type.icon),
                        label: Text(type.name),
                      ),
                    )
                    .toList(),
              ),
            // Main content area
            Expanded(child: _buildViewTypeContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildViewTypeContent() {
    switch (_selectedViewType) {
      case 0:
        return MonthViewShowcase(
          currentLocale: widget.currentLocale,
          isDarkMode: widget.isDarkMode,
        );
      case 1:
        return DayViewShowcase(
          currentLocale: widget.currentLocale,
          isDarkMode: widget.isDarkMode,
        );
      case 2:
        return ComparisonView(
          currentLocale: widget.currentLocale,
          isDarkMode: widget.isDarkMode,
        );
      default:
        return Center(child: Text(AppLocalizations.of(context)!.comingSoon));
    }
  }
}
