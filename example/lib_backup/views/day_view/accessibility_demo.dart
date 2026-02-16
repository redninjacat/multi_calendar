import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/sample_events.dart';
import '../../widgets/day_view_event_form_dialog.dart';
import '../../widgets/event_detail_dialog.dart';
import '../../widgets/style_description.dart';

/// Accessibility demo for Day View.
///
/// Demonstrates NFR-1 (Accessibility), WCAG 2.1 AA:
/// - Keyboard shortcut reference visible in UI
/// - Screen reader usage guide
/// - Accessibility checklist
/// - High contrast mode demonstration
/// - Keyboard navigation flow
class AccessibilityDemo extends StatefulWidget {
  const AccessibilityDemo({
    super.key,
    required this.currentLocale,
    required this.isDarkMode,
  });

  final Locale currentLocale;
  final bool isDarkMode;

  @override
  State<AccessibilityDemo> createState() => _AccessibilityDemoState();
}

class _AccessibilityDemoState extends State<AccessibilityDemo> {
  late MCalEventController _eventController;
  bool _highContrastMode = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _eventController = MCalEventController(initialDate: now);
    _eventController.addEvents(createDayViewSampleEvents(now));
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

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
      displayDate: _eventController.displayDate,
      initialTime: time,
    );
    if (event != null && mounted) {
      _eventController.addEvents([event]);
      _showSnackBar(AppLocalizations.of(context)!.eventCreated(event.title));
    }
  }

  Future<void> _handleCreateEventAtDefaultTime() async {
    final d = _eventController.displayDate;
    final now = DateTime.now();
    final defaultTime = DateTime(d.year, d.month, d.day, now.hour + 1, 0);
    await _handleCreateEvent(defaultTime);
  }

  Future<void> _handleEditEvent(MCalCalendarEvent event) async {
    final edited = await showDayViewEventEditDialog(
      context,
      event: event,
      displayDate: _eventController.displayDate,
    );
    if (edited != null && mounted) {
      _eventController.removeEvents([event.id]);
      _eventController.addEvents([edited]);
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
      _eventController.removeEvents([event.id]);
      _showSnackBar(AppLocalizations.of(context)!.eventDeleted(event.title));
    }
  }

  /// Returns modifier key string for keyboard shortcut display.
  /// MCalDayView supports both Cmd (macOS) and Ctrl (Windows/Linux).
  String get _modifierKey => 'Cmd/Ctrl';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final modifier = _modifierKey;

    // High contrast theme when enabled
    final effectiveTheme = _highContrastMode
        ? theme.copyWith(
            colorScheme: colorScheme.copyWith(
              primary: Colors.blue.shade900,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
              outline: Colors.black,
              outlineVariant: Colors.black54,
            ),
            visualDensity: VisualDensity.comfortable,
          )
        : theme;

    return Theme(
      data: effectiveTheme,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: Day View
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StyleDescription(
                  description: l10n.styleAccessibilityDescription,
                ),
                Expanded(
                  child: MCalDayView(
                    controller: _eventController,
                    enableDragToMove: true,
                    enableDragToResize: true,
                    snapToTimeSlots: true,
                    timeSlotDuration: const Duration(minutes: 15),
                    startHour: 8,
                    endHour: 20,
                    showNavigator: true,
                    showCurrentTimeIndicator: true,
                    locale: widget.currentLocale,
                    onEventTap: (context, details) {
                      showEventDetailDialog(
                        context,
                        details.event,
                        widget.currentLocale,
                        onEdit: () => _handleEditEvent(details.event),
                        onDelete: () => _handleDeleteEvent(details.event),
                      );
                    },
                    onEventDropped: (details) {
                      if (mounted) {
                        final t = details.newStartDate;
                        final timeStr =
                            '${t.hour}:${t.minute.toString().padLeft(2, '0')}';
                        _showSnackBar(
                          l10n.eventMoved(details.event.title, timeStr),
                        );
                      }
                    },
                    onEventResized: (details) {
                      if (mounted) {
                        final minutes = details.newEndDate
                            .difference(details.newStartDate)
                            .inMinutes;
                        _showSnackBar(
                          l10n.eventResized(
                            details.event.title,
                            minutes,
                          ),
                        );
                      }
                    },
                    onEmptySpaceDoubleTap: (time) => _handleCreateEvent(time),
                    onCreateEventRequested: _handleCreateEventAtDefaultTime,
                    onEditEventRequested: (event) => _handleEditEvent(event),
                    onDeleteEventRequested: (event) => _handleDeleteEvent(event),
                  ),
                ),
              ],
            ),
          ),
          // Right: Accessibility documentation panel
          Container(
            width: 320,
            constraints: const BoxConstraints(minWidth: 280),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                left: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Keyboard shortcuts
                _SectionHeader(
                  icon: Icons.keyboard,
                  title: l10n.accessibilityKeyboardShortcuts,
                ),
                _ShortcutRow(
                  keys: '$modifier+N',
                  action: l10n.accessibilityShortcutCreate,
                ),
                _ShortcutRow(
                  keys: '$modifier+E',
                  action: l10n.accessibilityShortcutEdit,
                ),
                _ShortcutRow(
                  keys: '$modifier+D, Del, Bksp',
                  action: l10n.accessibilityShortcutDelete,
                ),
                const SizedBox(height: 20),

                // Screen reader guide
                _SectionHeader(
                  icon: Icons.record_voice_over,
                  title: l10n.accessibilityScreenReaderGuide,
                ),
                Text(
                  l10n.accessibilityScreenReaderInstructions,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
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
                      l10n.accessibilityHighContrastDescription,
                      style: textTheme.bodySmall,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Accessibility checklist
                _SectionHeader(
                  icon: Icons.checklist,
                  title: l10n.accessibilityChecklist,
                ),
                _ChecklistItem(text: l10n.accessibilityChecklistItem1),
                _ChecklistItem(text: l10n.accessibilityChecklistItem2),
                _ChecklistItem(text: l10n.accessibilityChecklistItem3),
                _ChecklistItem(text: l10n.accessibilityChecklistItem4),
                _ChecklistItem(text: l10n.accessibilityChecklistItem5),
                _ChecklistItem(text: l10n.accessibilityChecklistItem6),
                const SizedBox(height: 20),

                // Keyboard navigation flow
                _SectionHeader(
                  icon: Icons.keyboard_double_arrow_down,
                  title: l10n.accessibilityKeyboardNavFlow,
                ),
                _FlowStep(1, l10n.accessibilityKeyboardNavStep1),
                _FlowStep(2, l10n.accessibilityKeyboardNavStep2),
                _FlowStep(3, l10n.accessibilityKeyboardNavStep3),
                _FlowStep(4, l10n.accessibilityKeyboardNavStep4),
              ],
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.only(bottom: 8),
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

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({
    required this.keys,
    required this.action,
  });

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
  const _FlowStep(this.step, this.text);

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
