import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/utils/sample_events.dart';
import '../../shared/widgets/event_detail_dialog.dart';

/// Comparison view showing Month View and Day View side by side.
///
/// Demonstrates:
/// - Shared [MCalEventController] for both views
/// - Clicking a day in Month View navigates Day View to that date
/// - Synchronized event updates (changes in one view reflect in the other)
/// - Split layout on desktop/tablet, stacked on mobile
/// - When to use each view (documented in UI)
class ComparisonView extends StatefulWidget {
  const ComparisonView({
    super.key,
    required this.currentLocale,
    required this.isDarkMode,
  });

  final Locale currentLocale;
  final bool isDarkMode;

  @override
  State<ComparisonView> createState() => _ComparisonViewState();
}

class _ComparisonViewState extends State<ComparisonView> {
  late MCalEventController _controller;

  /// Breakpoint for split view (desktop/tablet) vs stacked (mobile).
  static const double _splitBreakpoint = 600;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _controller = MCalEventController(initialDate: now);
    // Use sample events that work for both Month and Day views
    _controller.addEvents(createSampleEvents());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onMonthCellTap(BuildContext context, MCalCellTapDetails details) {
    // Navigate Day View to the tapped date
    _controller.navigateToDate(details.date);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.comparisonDaySelected(
              _formatDate(details.date),
            ),
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;
    final useSplitView = width >= _splitBreakpoint;

    return Column(
      children: [
        // Header with usage guidance
        _ComparisonHeader(
          useMonthView: l10n.comparisonUseMonthView,
          useDayView: l10n.comparisonUseDayView,
        ),
        // Main content: split or stacked
        Expanded(
          child: useSplitView ? _buildSplitLayout() : _buildStackedLayout(),
        ),
      ],
    );
  }

  Widget _buildSplitLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _MonthViewPanel(
            controller: _controller,
            locale: widget.currentLocale,
            onCellTap: _onMonthCellTap,
          ),
        ),
        Container(
          width: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        Expanded(
          child: _DayViewPanel(
            controller: _controller,
            locale: widget.currentLocale,
            isDarkMode: widget.isDarkMode,
          ),
        ),
      ],
    );
  }

  Widget _buildStackedLayout() {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: _MonthViewPanel(
            controller: _controller,
            locale: widget.currentLocale,
            onCellTap: _onMonthCellTap,
          ),
        ),
        Container(
          height: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        Expanded(
          flex: 1,
          child: _DayViewPanel(
            controller: _controller,
            locale: widget.currentLocale,
            isDarkMode: widget.isDarkMode,
          ),
        ),
      ],
    );
  }
}

/// Header explaining when to use each view.
class _ComparisonHeader extends StatelessWidget {
  const _ComparisonHeader({
    required this.useMonthView,
    required this.useDayView,
  });

  final String useMonthView;
  final String useDayView;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${l10n.monthView}: $useMonthView',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.dayView}: $useDayView',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Month View panel in the comparison.
class _MonthViewPanel extends StatelessWidget {
  const _MonthViewPanel({
    required this.controller,
    required this.locale,
    required this.onCellTap,
  });

  final MCalEventController controller;
  final Locale locale;
  final void Function(BuildContext, MCalCellTapDetails) onCellTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            l10n.monthView,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Expanded(
          child: MCalMonthView(
            controller: controller,
            locale: locale,
            showNavigator: true,
            enableSwipeNavigation: true,
            onCellTap: onCellTap,
            onEventTap: (context, details) {
              showEventDetailDialog(context, details.event, locale);
            },
          ),
        ),
      ],
    );
  }
}

/// Day View panel in the comparison.
class _DayViewPanel extends StatelessWidget {
  const _DayViewPanel({
    required this.controller,
    required this.locale,
    required this.isDarkMode,
  });

  final MCalEventController controller;
  final Locale locale;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            l10n.dayView,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Expanded(
          child: MCalDayView(
            controller: controller,
            locale: locale,
            startHour: 6,
            endHour: 22,
            showNavigator: true,
            showCurrentTimeIndicator: true,
            enableDragToMove: true,
            enableDragToResize: true,
            snapToTimeSlots: true,
            timeSlotDuration: const Duration(minutes: 15),
            onEventTap: (context, details) {
              showEventDetailDialog(context, details.event, locale);
            },
          ),
        ),
      ],
    );
  }
}
