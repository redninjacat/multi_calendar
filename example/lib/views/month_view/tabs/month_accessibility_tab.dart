import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/utils/sample_events.dart';
import '../../../shared/widgets/day_events_bottom_sheet.dart';
import '../../../shared/widgets/event_detail_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left: Month View
        Expanded(
          flex: 3,
          child: MCalTheme(
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
          ),
        ),
        // Right: Accessibility documentation panel
        Container(
          width: 340,
          constraints: const BoxConstraints(minWidth: 300),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            border: Border(
              left: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Keyboard shortcuts section
              _SectionHeader(
                icon: Icons.keyboard,
                title: l10n.accessibilityMonthKeyboardShortcuts,
              ),
              _ShortcutTable(shortcuts: [
                _KeyboardShortcut(
                  keys: l10n.accessibilityShortcutArrows,
                  action: l10n.accessibilityMonthShortcutArrows,
                ),
                _KeyboardShortcut(
                  keys: l10n.accessibilityShortcutEnter,
                  action: l10n.accessibilityMonthShortcutEnterSpace,
                ),
                _KeyboardShortcut(
                  keys: l10n.accessibilityShortcutHome,
                  action: l10n.accessibilityMonthShortcutHome,
                ),
                _KeyboardShortcut(
                  keys: l10n.accessibilityShortcutEnd,
                  action: l10n.accessibilityMonthShortcutEnd,
                ),
                _KeyboardShortcut(
                  keys: l10n.accessibilityShortcutPageUp,
                  action: l10n.accessibilityMonthShortcutPageUp,
                ),
                _KeyboardShortcut(
                  keys: l10n.accessibilityShortcutPageDown,
                  action: l10n.accessibilityMonthShortcutPageDown,
                ),
                _KeyboardShortcut(
                  keys: l10n.accessibilityShortcutTab,
                  action: l10n.accessibilityMonthShortcutTab,
                ),
                _KeyboardShortcut(
                  keys: 'Enter (on event)', // TODO: Need specific key for this
                  action: l10n.accessibilityMonthShortcutEnterConfirm,
                ),
                _KeyboardShortcut(
                  keys: l10n.accessibilityShortcutEscape,
                  action: l10n.accessibilityMonthShortcutEscape,
                ),
                _KeyboardShortcut(
                  keys: l10n.accessibilityShortcutR,
                  action: l10n.accessibilityMonthShortcutR,
                ),
                _KeyboardShortcut(
                  keys: 'S / E', // TODO: Need specific keys for S and E
                  action: l10n.accessibilityMonthShortcutS + ' / ' + l10n.accessibilityMonthShortcutE,
                ),
                _KeyboardShortcut(
                  keys: l10n.accessibilityShortcutM,
                  action: l10n.accessibilityMonthShortcutM,
                ),
              ]),
              const SizedBox(height: 20),

              // Screen reader guide section
              _SectionHeader(
                icon: Icons.record_voice_over,
                title: l10n.accessibilityScreenReaderGuide,
              ),
              _InfoSection(
                title: 'Cell Labels', // TODO: Add ARB key accessibilityScreenReaderCellLabels
                content:
                    'Each cell announces date, day of week, and number of events. Example: "Monday, February 10, 2026. 3 events."', // TODO: Add ARB key
              ),
              const SizedBox(height: 8),
              _InfoSection(
                title: 'Event Labels', // TODO: Add ARB key accessibilityScreenReaderEventLabels
                content:
                    'Events announce title, duration, and position. Example: "Team Meeting. February 10-12. Spans 3 days."', // TODO: Add ARB key
              ),
              const SizedBox(height: 8),
              _InfoSection(
                title: 'Multi-day Events', // TODO: Add ARB key accessibilityScreenReaderMultiDayEvents
                content:
                    'Multi-day event spans are announced with clear start and end dates and total duration.', // TODO: Add ARB key
              ),
              const SizedBox(height: 8),
              _InfoSection(
                title: 'Navigator', // TODO: Add ARB key accessibilityScreenReaderNavigator
                content:
                    'Navigation buttons announce current month/year and action. Example: "February 2026. Previous month button."', // TODO: Add ARB key
              ),
              const SizedBox(height: 8),
              _InfoSection(
                title: 'Overflow Indicators', // TODO: Add ARB key accessibilityScreenReaderOverflow
                content:
                    'When a day has more events than can display, overflow indicator announces: "+3 more events. Tap to view all."', // TODO: Add ARB key
              ),
              const SizedBox(height: 20),

              // High contrast toggle
              _SectionHeader(
                icon: Icons.contrast,
                title: l10n.accessibilityHighContrast,
              ),
              Semantics(
                label: l10n.accessibilityHighContrastDescription,
                child: SwitchListTile(
                  value: _highContrastMode,
                  onChanged: (v) => setState(() => _highContrastMode = v),
                  title: Text(
                    'Enable High Contrast', // TODO: Add ARB key settingEnableHighContrast
                    style: textTheme.bodySmall,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 20),

              // Accessibility checklist
              _SectionHeader(
                icon: Icons.checklist,
                title: l10n.accessibilityChecklist,
              ),
              _ChecklistItem(
                text: l10n.accessibilityChecklistItem1,
              ),
              _ChecklistItem(
                text: 'Full keyboard navigation support', // TODO: Add ARB key accessibilityChecklistItem7
              ),
              _ChecklistItem(
                text: l10n.accessibilityChecklistItem6,
              ),
              _ChecklistItem(
                text: l10n.accessibilityChecklistItem5,
              ),
              _ChecklistItem(
                text: l10n.accessibilityChecklistItem4,
              ),
              _ChecklistItem(
                text: 'Respects reduced motion preferences', // TODO: Add ARB key accessibilityChecklistItem8
              ),
              const SizedBox(height: 20),

              // Keyboard navigation flow
              _SectionHeader(
                icon: Icons.keyboard_double_arrow_down,
                title: l10n.accessibilityKeyboardNavFlow,
              ),
              _FlowStep(
                step: 1,
                text:
                    'Use arrow keys to navigate between calendar cells. Focus indicator shows current cell.', // TODO: Add ARB key accessibilityKeyboardNavFlowStep1
              ),
              _FlowStep(
                step: 2,
                text:
                    'Press Enter or Space on a cell to select it. If the cell has events, press Tab to cycle through them.', // TODO: Add ARB key accessibilityKeyboardNavFlowStep2
              ),
              _FlowStep(
                step: 3,
                text:
                    'With an event focused, press Enter to start move mode. Use arrows to navigate to target cell, Enter to confirm, or Escape to cancel.', // TODO: Add ARB key accessibilityKeyboardNavFlowStep3
              ),
              _FlowStep(
                step: 4,
                text:
                    'Press R to enter resize mode. Use S/E to switch which edge to resize, arrows to resize, Enter to confirm, or M to return to move mode.', // TODO: Add ARB key accessibilityKeyboardNavFlowStep4
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
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
      ),
    );
  }
}

class _KeyboardShortcut {
  const _KeyboardShortcut({
    required this.keys,
    required this.action,
  });

  final String keys;
  final String action;
}

class _ShortcutTable extends StatelessWidget {
  const _ShortcutTable({required this.shortcuts});

  final List<_KeyboardShortcut> shortcuts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          for (var i = 0; i < shortcuts.length; i++) ...[
            if (i > 0) Divider(height: 1, color: theme.colorScheme.outlineVariant),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Text(
                      shortcuts[i].keys,
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
                        shortcuts[i].action,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 18,
            color: theme.colorScheme.primary,
          ),
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
  const _FlowStep({
    required this.step,
    required this.text,
  });

  final int step;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$step',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
