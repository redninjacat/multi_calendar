import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/utils/sample_events.dart';
import '../../../shared/widgets/day_events_bottom_sheet.dart';
import '../../../shared/widgets/event_detail_dialog.dart';
import '../../../shared/widgets/responsive_control_panel.dart';

/// Accessibility demo for Month View.
///
/// Demonstrates NFR-1 (Accessibility), WCAG 2.1 AA:
/// - Keyboard shortcut reference visible in UI
/// - Screen reader usage guide
/// - Accessibility checklist
/// - High contrast mode demonstration
/// - Keyboard navigation flow
class MonthAccessibilityTab extends StatefulWidget {
  const MonthAccessibilityTab({super.key});

  @override
  State<MonthAccessibilityTab> createState() => _MonthAccessibilityTabState();
}

class _MonthAccessibilityTabState extends State<MonthAccessibilityTab> {
  late MCalEventController _eventController;
  bool _highContrastMode = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _eventController = MCalEventController(initialDate: now);
    _eventController.addEvents(createSampleEvents());
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  /// True on platforms that have a hardware keyboard (desktop + web).
  static bool get _supportsKeyboard =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  Widget _buildDocPanel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final supportsKeyboard = _supportsKeyboard;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Keyboard shortcuts — hidden on platforms without a hardware keyboard
        if (supportsKeyboard) ...[
          _SectionHeader(icon: Icons.keyboard, title: l10n.accessibilityMonthKeyboardShortcuts),
          const SizedBox(height: 8),
          _ShortcutRow(keys: l10n.accessibilityShortcutArrows, action: l10n.accessibilityMonthShortcutArrows),
          _ShortcutRow(keys: l10n.accessibilityShortcutEnter, action: l10n.accessibilityMonthShortcutEnterSpace),
          _ShortcutRow(keys: l10n.accessibilityShortcutHome, action: l10n.accessibilityMonthShortcutHome),
          _ShortcutRow(keys: l10n.accessibilityShortcutEnd, action: l10n.accessibilityMonthShortcutEnd),
          _ShortcutRow(keys: l10n.accessibilityShortcutPageUp, action: l10n.accessibilityMonthShortcutPageUp),
          _ShortcutRow(keys: l10n.accessibilityShortcutPageDown, action: l10n.accessibilityMonthShortcutPageDown),
          _ShortcutRow(keys: l10n.accessibilityShortcutTab, action: l10n.accessibilityMonthShortcutTab),
          _ShortcutRow(keys: 'Enter (on event)', action: l10n.accessibilityMonthShortcutEnterConfirm),
          _ShortcutRow(keys: l10n.accessibilityShortcutEscape, action: l10n.accessibilityMonthShortcutEscape),
          _ShortcutRow(keys: l10n.accessibilityShortcutR, action: l10n.accessibilityMonthShortcutR),
          _ShortcutRow(keys: 'S / E', action: '${l10n.accessibilityMonthShortcutS} / ${l10n.accessibilityMonthShortcutE}'),
          _ShortcutRow(keys: l10n.accessibilityShortcutM, action: l10n.accessibilityMonthShortcutM),
          const SizedBox(height: 20),
        ],

        // Screen reader guide section
        _SectionHeader(icon: Icons.record_voice_over, title: l10n.accessibilityScreenReaderGuide),
        const SizedBox(height: 8),
        _InfoSection(
          title: 'Cell Labels',
          content: 'Each cell announces date, day of week, and number of events. Example: "Monday, February 10, 2026. 3 events."',
        ),
        const SizedBox(height: 8),
        _InfoSection(
          title: 'Event Labels',
          content: 'Events announce title, duration, and position. Example: "Team Meeting. February 10-12. Spans 3 days."',
        ),
        const SizedBox(height: 8),
        _InfoSection(
          title: 'Multi-day Events',
          content: 'Multi-day event spans are announced with clear start and end dates and total duration.',
        ),
        const SizedBox(height: 8),
        _InfoSection(
          title: 'Navigator',
          content: 'Navigation buttons announce current month/year and action. Example: "February 2026. Previous month button."',
        ),
        const SizedBox(height: 8),
        _InfoSection(
          title: 'Overflow Indicators',
          content: 'When a day has more events than can display, overflow indicator announces: "+3 more events. Tap to view all."',
        ),
        const SizedBox(height: 20),

        // High contrast toggle
        _SectionHeader(icon: Icons.contrast, title: l10n.accessibilityHighContrast),
        const SizedBox(height: 8),
        Semantics(
          label: l10n.accessibilityHighContrastDescription,
          child: SwitchListTile(
            value: _highContrastMode,
            onChanged: (v) => setState(() => _highContrastMode = v),
            title: Text(l10n.accessibilityHighContrastDescription, style: textTheme.bodySmall),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        const SizedBox(height: 20),

        // Accessibility checklist
        _SectionHeader(icon: Icons.checklist, title: l10n.accessibilityChecklist),
        const SizedBox(height: 8),
        _ChecklistItem(text: l10n.accessibilityChecklistItem1),
        _ChecklistItem(text: 'Full keyboard navigation support'),
        _ChecklistItem(text: l10n.accessibilityChecklistItem6),
        _ChecklistItem(text: l10n.accessibilityChecklistItem5),
        _ChecklistItem(text: l10n.accessibilityChecklistItem4),
        _ChecklistItem(text: 'Respects reduced motion preferences'),
        const SizedBox(height: 20),

        // Keyboard navigation flow + instructions — hidden on non-keyboard platforms
        if (supportsKeyboard) ...[
          _SectionHeader(icon: Icons.keyboard_double_arrow_down, title: l10n.accessibilityKeyboardNavFlow),
          const SizedBox(height: 8),
          _FlowStep(
            step: 1,
            text: 'Use arrow keys to navigate between calendar cells. Focus indicator shows current cell.',
          ),
          _FlowStep(
            step: 2,
            text: 'Press Enter or Space on a cell to select it. If the cell has events, press Tab to cycle through them.',
          ),
          _FlowStep(
            step: 3,
            text: 'With an event focused, press Enter to start move mode. Use arrows to navigate to target cell, Enter to confirm, or Escape to cancel.',
          ),
          _FlowStep(
            step: 4,
            text: 'Press R to enter resize mode. Use S/E to switch which edge to resize, arrows to resize, Enter to confirm, or M to return to move mode.',
          ),
          const SizedBox(height: 20),

          // Keyboard navigation instructions
          _SectionHeader(icon: Icons.tips_and_updates, title: l10n.accessibilityKeyboardNavInstructions),
          const SizedBox(height: 8),
          Text(
            l10n.accessibilityMonthKeyboardNavInstructionsDetail,
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.5),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    // High contrast theme when enabled
    final effectiveTheme = _highContrastMode
        ? MCalThemeData(
            eventTileBackgroundColor: Colors.black,
            monthTheme: MCalMonthThemeData(
              cellBackgroundColor: Colors.white,
              cellBorderColor: Colors.black,
              todayBackgroundColor: Colors.blue.shade50,
              weekdayHeaderBackgroundColor: Colors.grey.shade100,
              navigatorBackgroundColor: Colors.grey.shade200,
              dropTargetCellValidColor: Colors.green.shade100,
              dropTargetCellInvalidColor: Colors.red.shade100,
              hoverCellBackgroundColor: Colors.yellow.shade50,
              hoverEventBackgroundColor: Colors.yellow.shade100,
            ),
          )
        : null;

    final calendar = MCalTheme(
      data: effectiveTheme ?? MCalThemeData(),
      child: MCalMonthView(
        controller: _eventController,
        enableDragToMove: true,
        enableDragToResize: true,
        enableKeyboardNavigation: true,
        showNavigator: true,
        locale: locale,
        onEventTap: (ctx, details) {
          showEventDetailDialog(context, details.event, locale);
        },
        onOverflowTap: (ctx, details) {
          showDayEventsBottomSheet(
            context,
            details.date,
            details.allEvents,
            locale,
          );
        },
      ),
    );

    return ResponsiveControlPanel(
      controlPanelTitle: l10n.accessibilitySettings,
      controlPanel: _buildDocPanel(context),
      child: calendar,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({required this.keys, required this.action});

  final String keys;
  final String action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Text(
              keys,
              style: theme.textTheme.labelSmall?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                action,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowStep extends StatelessWidget {
  const _FlowStep({required this.step, required this.text});

  final int step;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$step',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
