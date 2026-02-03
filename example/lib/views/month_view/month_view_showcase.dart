import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../utils/sample_events.dart';
import 'styles/default_style.dart';
import 'styles/modern_style.dart';
import 'styles/classic_style.dart';
import 'styles/minimal_style.dart';
import 'styles/colorful_style.dart';
import 'styles/features_demo_style.dart';

/// Information about a style tab.
class StyleTabInfo {
  final String name;
  final String description;

  const StyleTabInfo({
    required this.name,
    required this.description,
  });
}

/// Showcase for Month View with multiple style tabs.
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
  late MCalEventController _eventController;
  DateTime? _selectedDate;

  static const List<StyleTabInfo> _styles = [
    StyleTabInfo(
      name: 'Features',
      description:
          'Interactive demo of all features: swipe navigation with peek preview, multi-day events with contiguous rendering, drag-and-drop with cross-month navigation, keyboard navigation, hover feedback, week numbers, and more.',
    ),
    StyleTabInfo(
      name: 'Default',
      description:
          'The out-of-the-box MonthView with no customization. Uses the library\'s built-in theme derived from your app\'s ThemeData.',
    ),
    StyleTabInfo(
      name: 'Modern',
      description:
          'A clean, modern design with rounded corners, subtle shadows, and colorful event indicators. Great for contemporary apps.',
    ),
    StyleTabInfo(
      name: 'Classic',
      description:
          'A traditional calendar look with grid borders and minimal styling. Familiar and functional.',
    ),
    StyleTabInfo(
      name: 'Minimal',
      description:
          'Ultra-clean design with maximum whitespace. Perfect for apps that prioritize content over chrome.',
    ),
    StyleTabInfo(
      name: 'Colorful',
      description:
          'Bold, vibrant colors with gradient backgrounds. Ideal for playful, creative applications.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _styles.length, vsync: this);
    _eventController = MCalEventController();
    _eventController.addEvents(createSampleEvents());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _eventController.dispose();
    super.dispose();
  }

  void _onDateSelected(DateTime date) {
    setState(() => _selectedDate = date);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Tab bar for different styles
        Container(
          color: colorScheme.surfaceContainerHighest,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: _styles.map((style) => Tab(text: style.name)).toList(),
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              FeaturesDemoStyle(
                locale: widget.currentLocale,
                isDarkMode: widget.isDarkMode,
                description: _styles[0].description,
              ),
              DefaultMonthStyle(
                eventController: _eventController,
                locale: widget.currentLocale,
                description: _styles[1].description,
              ),
              ModernMonthStyle(
                eventController: _eventController,
                locale: widget.currentLocale,
                isDarkMode: widget.isDarkMode,
                selectedDate: _selectedDate,
                onDateSelected: _onDateSelected,
                description: _styles[2].description,
              ),
              ClassicMonthStyle(
                eventController: _eventController,
                locale: widget.currentLocale,
                isDarkMode: widget.isDarkMode,
                selectedDate: _selectedDate,
                onDateSelected: _onDateSelected,
                description: _styles[3].description,
              ),
              MinimalMonthStyle(
                eventController: _eventController,
                locale: widget.currentLocale,
                isDarkMode: widget.isDarkMode,
                selectedDate: _selectedDate,
                onDateSelected: _onDateSelected,
                description: _styles[4].description,
              ),
              ColorfulMonthStyle(
                eventController: _eventController,
                locale: widget.currentLocale,
                isDarkMode: widget.isDarkMode,
                selectedDate: _selectedDate,
                onDateSelected: _onDateSelected,
                description: _styles[5].description,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
