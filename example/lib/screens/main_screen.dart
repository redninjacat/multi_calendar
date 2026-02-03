import 'package:flutter/material.dart';

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

  // View types that will be available (Month, Week, Day, etc.)
  static const List<ViewTypeInfo> _viewTypes = [
    ViewTypeInfo(
      name: 'Month View',
      icon: Icons.calendar_view_month,
      description: 'Different styles for the month calendar view',
    ),
    // Future view types can be added here:
    // ViewTypeInfo(name: 'Week View', icon: Icons.view_week, description: '...'),
    // ViewTypeInfo(name: 'Day View', icon: Icons.view_day, description: '...'),
    // ViewTypeInfo(name: 'Schedule View', icon: Icons.schedule, description: '...'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        title: Text(
          'Multi Calendar',
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
            tooltip: 'Toggle theme',
          ),
          PopupMenuButton<Locale>(
            icon: Icon(Icons.translate, color: colorScheme.onSurface),
            tooltip: 'Change language',
            onSelected: widget.onLocaleChanged,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: const Locale('en'),
                child: Row(
                  children: [
                    if (widget.currentLocale.languageCode == 'en')
                      Icon(Icons.check, size: 18, color: colorScheme.primary),
                    if (widget.currentLocale.languageCode == 'en')
                      const SizedBox(width: 8),
                    const Text('English'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: const Locale('es', 'MX'),
                child: Row(
                  children: [
                    if (widget.currentLocale.languageCode == 'es')
                      Icon(Icons.check, size: 18, color: colorScheme.primary),
                    if (widget.currentLocale.languageCode == 'es')
                      const SizedBox(width: 8),
                    const Text('Español (México)'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
          children: [
            // Side navigation for view types (only show if more than one type)
            if (_viewTypes.length > 1)
              NavigationRail(
                selectedIndex: _selectedViewType,
                onDestinationSelected: (index) {
                  setState(() => _selectedViewType = index);
                },
                labelType: NavigationRailLabelType.all,
                destinations: _viewTypes
                    .map(
                      (type) => NavigationRailDestination(
                        icon: Icon(type.icon),
                        label: Text(type.name),
                      ),
                    )
                    .toList(),
              ),
            // Main content area
            Expanded(
              child: _buildViewTypeContent(),
            ),
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
      // Future view types:
      // case 1: return WeekViewShowcase(...);
      // case 2: return DayViewShowcase(...);
      default:
        return const Center(child: Text('Coming soon...'));
    }
  }
}
