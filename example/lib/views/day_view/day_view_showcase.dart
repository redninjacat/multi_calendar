import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/sample_events.dart';
import '../../widgets/day_view_event_form_dialog.dart';
import '../../widgets/event_detail_dialog.dart';
import '../../widgets/style_description.dart';
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
      name: l10n.styleFeaturesDemo,
      description: l10n.styleFeaturesDemoDescription,
    ),
    DayStyleTabInfo(
      name: l10n.styleStressTest,
      description: l10n.styleStressTestDescription,
    ),
    DayStyleTabInfo(
      name: l10n.styleRtlDemo,
      description: l10n.styleRtlDemoDescription,
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
    _tabController = TabController(length: 10, vsync: this);
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
              DefaultDayStyle(
                eventController: _eventController,
                locale: widget.currentLocale,
                isDarkMode: widget.isDarkMode,
                description: styles[0].description,
              ),
              ClassicDayStyle(
                eventController: _eventController,
                locale: widget.currentLocale,
                isDarkMode: widget.isDarkMode,
                description: styles[1].description,
              ),
              ModernDayStyle(
                eventController: _eventController,
                locale: widget.currentLocale,
                isDarkMode: widget.isDarkMode,
                description: styles[2].description,
              ),
              ColorfulDayStyle(
                eventController: _eventController,
                locale: widget.currentLocale,
                isDarkMode: widget.isDarkMode,
                description: styles[3].description,
              ),
              MinimalDayStyle(
                eventController: _eventController,
                locale: widget.currentLocale,
                isDarkMode: widget.isDarkMode,
                description: styles[4].description,
              ),
              FeaturesDemoDayStyle(
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
              RtlDemoDayStyle(
                eventController: _eventController,
                isDarkMode: widget.isDarkMode,
                description: styles[7].description,
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

/// RTL Demo Day View style - forces right-to-left layout with Arabic locale.
///
/// Wraps MCalDayView in [Directionality] with [TextDirection.rtl] and uses
/// Arabic locale. Demonstrates: time legend on right, navigator arrows flipped,
/// event tiles aligned for RTL. Use app language menu to select Arabic for
/// full app RTL, or this tab to test Day View RTL in isolation.
class RtlDemoDayStyle extends StatelessWidget {
  const RtlDemoDayStyle({
    super.key,
    required this.eventController,
    required this.isDarkMode,
    required this.description,
  });

  final MCalEventController eventController;
  final bool isDarkMode;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          StyleDescription(description: description),
          Expanded(
            child: _RtlDemoDayViewContent(
              eventController: eventController,
              isDarkMode: isDarkMode,
            ),
          ),
        ],
      ),
    );
  }
}

class _RtlDemoDayViewContent extends StatefulWidget {
  const _RtlDemoDayViewContent({
    required this.eventController,
    required this.isDarkMode,
  });

  final MCalEventController eventController;
  final bool isDarkMode;

  @override
  State<_RtlDemoDayViewContent> createState() => _RtlDemoDayViewContentState();
}

class _RtlDemoDayViewContentState extends State<_RtlDemoDayViewContent> {
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
    }
  }

  Future<void> _handleCreateEvent(DateTime time) async {
    final event = await showDayViewEventCreateDialog(
      context,
      displayDate: widget.eventController.displayDate,
      initialTime: time,
    );
    if (event != null && mounted) {
      widget.eventController.addEvents([event]);
      _showSnackBar(AppLocalizations.of(context)!.eventCreated(event.title));
    }
  }

  Future<void> _handleCreateEventAtDefaultTime() async {
    final d = widget.eventController.displayDate;
    final now = DateTime.now();
    final defaultTime = DateTime(d.year, d.month, d.day, now.hour + 1, 0);
    await _handleCreateEvent(defaultTime);
  }

  Future<void> _handleEditEvent(MCalCalendarEvent event) async {
    final edited = await showDayViewEventEditDialog(
      context,
      event: event,
      displayDate: widget.eventController.displayDate,
    );
    if (edited != null && mounted) {
      widget.eventController.removeEvents([event.id]);
      widget.eventController.addEvents([edited]);
      _showSnackBar(AppLocalizations.of(context)!.eventUpdated(edited.title));
    }
  }

  Future<void> _handleDeleteEvent(MCalCalendarEvent event) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteEvent),
        content: Text(l10n.deleteEventConfirm(event.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      widget.eventController.removeEvents([event.id]);
      _showSnackBar(AppLocalizations.of(context)!.eventDeleted(event.title));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MCalDayView(
      controller: widget.eventController,
      locale: const Locale('ar'),
      enableDragToMove: true,
      enableDragToResize: true,
      snapToTimeSlots: true,
      timeSlotDuration: const Duration(minutes: 15),
      startHour: 8,
      endHour: 20,
      showNavigator: true,
      showCurrentTimeIndicator: true,
      onEventTap: (context, details) {
        showEventDetailDialog(
          context,
          details.event,
          const Locale('ar'),
          onEdit: () => _handleEditEvent(details.event),
          onDelete: () => _handleDeleteEvent(details.event),
        );
      },
      onEventDropped: (details) {
        if (mounted) {
          final t = details.newStartDate;
          final timeStr = '${t.hour}:${t.minute.toString().padLeft(2, '0')}';
          _showSnackBar(
            AppLocalizations.of(
              context,
            )!.eventMoved(details.event.title, timeStr),
          );
        }
      },
      onEventResized: (details) {
        if (mounted) {
          final minutes = details.newEndDate
              .difference(details.newStartDate)
              .inMinutes;
          _showSnackBar(
            AppLocalizations.of(
              context,
            )!.eventResized(details.event.title, minutes),
          );
        }
      },
      onEmptySpaceDoubleTap: (time) => _handleCreateEvent(time),
      onCreateEventRequested: _handleCreateEventAtDefaultTime,
      onEditEventRequested: (event) => _handleEditEvent(event),
      onDeleteEventRequested: (event) => _handleDeleteEvent(event),
    );
  }
}
