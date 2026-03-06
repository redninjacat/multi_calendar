import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/event_detail_dialog.dart';
import '../../../shared/widgets/event_form_dialog.dart' show showEventCreateDialog, showEventEditDialog;
import '../../../shared/widgets/responsive_control_panel.dart';
import '../../../shared/widgets/snackbar_helper.dart';

/// Accessibility demo for Day View.
///
/// Demonstrates NFR-1 (Accessibility), WCAG 2.1 AA:
/// - Keyboard shortcut reference visible in UI
/// - Screen reader usage guide
/// - Accessibility checklist
/// - High contrast mode demonstration
/// - Keyboard navigation flow
class DayAccessibilityTab extends StatefulWidget {
  const DayAccessibilityTab({
    super.key,
    required this.locale,
    required this.isDarkMode,
  });

  final Locale locale;
  final bool isDarkMode;

  @override
  State<DayAccessibilityTab> createState() => _DayAccessibilityTabState();
}

class _DayAccessibilityTabState extends State<DayAccessibilityTab> {
  late MCalEventController _eventController;
  bool _highContrastMode = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _eventController = MCalEventController(initialDate: now);
    _eventController.addEvents([
      MCalCalendarEvent(
        id: 'demo-1',
        title: 'Team Standup',
        start: DateTime(now.year, now.month, now.day, 9, 0),
        end: DateTime(now.year, now.month, now.day, 9, 30),
        color: Colors.blue.shade600,
      ),
      MCalCalendarEvent(
        id: 'demo-2',
        title: 'Design Review',
        start: DateTime(now.year, now.month, now.day, 11, 0),
        end: DateTime(now.year, now.month, now.day, 12, 0),
        color: Colors.purple.shade600,
      ),
      MCalCalendarEvent(
        id: 'demo-3',
        title: 'Lunch Break',
        start: DateTime(now.year, now.month, now.day, 12, 30),
        end: DateTime(now.year, now.month, now.day, 13, 30),
        color: Colors.amber.shade600,
      ),
      MCalCalendarEvent(
        id: 'demo-4',
        title: 'Client Call',
        start: DateTime(now.year, now.month, now.day, 14, 0),
        end: DateTime(now.year, now.month, now.day, 15, 0),
        color: Colors.green.shade600,
      ),
      MCalCalendarEvent(
        id: 'demo-5',
        title: 'Planning Session',
        start: DateTime(now.year, now.month, now.day, 15, 30),
        end: DateTime(now.year, now.month, now.day, 17, 0),
        color: Colors.red.shade600,
      ),
    ]);
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateEvent(DateTime time) async {
    final l10n = AppLocalizations.of(context)!;
    final event = await showEventCreateDialog(
      context,
      displayDate: _eventController.displayDate,
      initialTime: time,
    );
    if (event != null && mounted) {
      _eventController.addEvents([event]);
      SnackBarHelper.show(
        context,
        l10n.snackbarEventCreated(event.title),
      );
    }
  }

  Future<void> _handleEditEvent(MCalCalendarEvent event) async {
    final l10n = AppLocalizations.of(context)!;
    final edited = await showEventEditDialog(
      context,
      event: event,
      displayDate: _eventController.displayDate,
    );
    if (edited != null && mounted) {
      _eventController.addEvents([edited]);
      SnackBarHelper.show(
        context,
        l10n.snackbarEventUpdated(edited.title),
      );
    }
  }

  Future<void> _handleDeleteEvent(MCalCalendarEvent event) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dialogDeleteEventTitle),
        content: Text(l10n.dialogDeleteEventConfirm(event.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.buttonDelete),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      _eventController.removeEvents([event.id]);
      SnackBarHelper.show(
        context,
        l10n.snackbarEventDeleted(event.title),
      );
    }
  }

  /// True on platforms that have a hardware keyboard (desktop + web).
  static bool get _supportsKeyboard =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  Widget _buildDocPanel(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final supportsKeyboard = _supportsKeyboard;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Keyboard shortcuts organized by mode — hidden on non-keyboard platforms
        if (supportsKeyboard) ...[
          _SectionHeader(
            icon: Icons.keyboard,
            title: l10n.accessibilityDayKeyboardShortcuts,
          ),
          const SizedBox(height: 8),

          // Navigation Mode
          _ModeSection(
            title: l10n.accessibilityDayModeNavigation,
            description: l10n.accessibilityDayModeNavigationDesc,
          ),
          _ShortcutRow(
            keys: '↑ / ↓',
            action: l10n.accessibilityDayNavUpDown,
          ),
          _ShortcutRow(
            keys: l10n.accessibilityShortcutEnter,
            action: l10n.accessibilityDayNavEnterSpace,
          ),
          _ShortcutRow(
            keys: l10n.accessibilityShortcutHome,
            action: l10n.accessibilityDayNavHome,
          ),
          _ShortcutRow(
            keys: l10n.accessibilityShortcutEnd,
            action: l10n.accessibilityDayNavEnd,
          ),
          _ShortcutRow(
            keys: l10n.accessibilityShortcutPageUp,
            action: l10n.accessibilityDayNavPageUp,
          ),
          _ShortcutRow(
            keys: l10n.accessibilityShortcutPageDown,
            action: l10n.accessibilityDayNavPageDown,
          ),
          _ShortcutRow(
            keys: 'N',
            action: l10n.accessibilityDayNavN,
          ),
          _ShortcutRow(
            keys: 'A',
            action: l10n.accessibilityDayNavA,
          ),
          _ShortcutRow(
            keys: 'T',
            action: l10n.accessibilityDayNavT,
          ),
          const SizedBox(height: 12),

          // Event Mode
          _ModeSection(
            title: l10n.accessibilityDayModeEvent,
            description: l10n.accessibilityDayModeEventDesc,
          ),
          _ShortcutRow(
            keys: '${l10n.accessibilityShortcutTab} / ↑↓',
            action: l10n.accessibilityDayEventUpDown,
          ),
          _ShortcutRow(
            keys: l10n.accessibilityShortcutEnter,
            action: l10n.accessibilityDayEventEnterSpace,
          ),
          _ShortcutRow(
            keys: 'D / Delete',
            action: l10n.accessibilityDayEventD,
          ),
          _ShortcutRow(
            keys: 'X',
            action: l10n.accessibilityDayEventX,
          ),
          _ShortcutRow(
            keys: l10n.accessibilityShortcutM,
            action: l10n.accessibilityDayEventM,
          ),
          _ShortcutRow(
            keys: l10n.accessibilityShortcutR,
            action: l10n.accessibilityDayEventR,
          ),
          _ShortcutRow(
            keys: l10n.accessibilityShortcutEscape,
            action: l10n.accessibilityDayEventEscape,
          ),
          const SizedBox(height: 12),

          // Move Mode
          _ModeSection(
            title: l10n.accessibilityDayModeMove,
            description: l10n.accessibilityDayModeMoveDesc,
          ),
          _ShortcutRow(
            keys: l10n.accessibilityShortcutArrows,
            action: l10n.accessibilityDayMoveArrows,
          ),
          _ShortcutRow(
            keys: l10n.accessibilityShortcutEnter,
            action: l10n.accessibilityDayMoveEnter,
          ),
          _ShortcutRow(
            keys: l10n.accessibilityShortcutR,
            action: l10n.accessibilityDayMoveR,
          ),
          _ShortcutRow(
            keys: l10n.accessibilityShortcutEscape,
            action: l10n.accessibilityDayMoveEscape,
          ),
          const SizedBox(height: 12),

          // Resize Mode
          _ModeSection(
            title: l10n.accessibilityDayModeResize,
            description: l10n.accessibilityDayModeResizeDesc,
          ),
          _ShortcutRow(
            keys: 'S / E',
            action: l10n.accessibilityDayResizeSE,
          ),
          _ShortcutRow(
            keys: l10n.accessibilityShortcutArrows,
            action: l10n.accessibilityDayResizeArrows,
          ),
          _ShortcutRow(
            keys: l10n.accessibilityShortcutEnter,
            action: l10n.accessibilityDayResizeEnter,
          ),
          _ShortcutRow(
            keys: l10n.accessibilityShortcutM,
            action: l10n.accessibilityDayResizeM,
          ),
          _ShortcutRow(
            keys: l10n.accessibilityShortcutEscape,
            action: l10n.accessibilityDayResizeEscape,
          ),
          const SizedBox(height: 12),

          // Configurable bindings note
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
                width: 0.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.tune,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.accessibilityDayKeyBindingsNote,
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Screen reader guide
        _SectionHeader(icon: Icons.record_voice_over, title: l10n.accessibilityScreenReaderGuide),
        const SizedBox(height: 8),
        Text(
          l10n.accessibilityScreenReaderInstructions,
          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.5),
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
        _ChecklistItem(text: l10n.accessibilityChecklistItem2),
        _ChecklistItem(text: l10n.accessibilityChecklistItem3),
        _ChecklistItem(text: l10n.accessibilityChecklistItem4),
        _ChecklistItem(text: l10n.accessibilityChecklistItem5),
        _ChecklistItem(text: l10n.accessibilityChecklistItem6),
        const SizedBox(height: 20),

        // Keyboard navigation flow — hidden on platforms without a hardware keyboard
        if (supportsKeyboard) ...[
          _SectionHeader(icon: Icons.keyboard_double_arrow_down, title: l10n.accessibilityKeyboardNavFlow),
          const SizedBox(height: 8),
          _FlowStep(1, l10n.accessibilityKeyboardNavStep1),
          _FlowStep(2, l10n.accessibilityKeyboardNavStep2),
          _FlowStep(3, l10n.accessibilityKeyboardNavStep3),
          _FlowStep(4, l10n.accessibilityKeyboardNavStep4),
          const SizedBox(height: 20),

          // Keyboard navigation instructions
          _SectionHeader(icon: Icons.tips_and_updates, title: l10n.accessibilityKeyboardNavInstructions),
          const SizedBox(height: 8),
          Text(
            l10n.accessibilityKeyboardNavInstructionsDetail,
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.5),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

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

    final calendar = Theme(
      data: effectiveTheme,
      child: MCalDayView(
        controller: _eventController,
        enableDragToMove: true,
        enableDragToResize: true,
        enableKeyboardNavigation: true,
        snapToTimeSlots: true,
        timeSlotDuration: const Duration(minutes: 15),
        startHour: 8,
        endHour: 20,
        showNavigator: true,
        showCurrentTimeIndicator: true,
        locale: widget.locale,
        onEventTap: (ctx, details) {
          showEventDetailDialog(
            context,
            details.event,
            widget.locale,
            onEdit: () {
              Navigator.of(ctx).pop();
              _handleEditEvent(details.event);
            },
            onDelete: () {
              Navigator.of(ctx).pop();
              _handleDeleteEvent(details.event);
            },
          );
        },
        onEventDropped: (ctx, details) {
          if (mounted) {
            final t = details.newStartDate;
            final timeStr = '${t.hour}:${t.minute.toString().padLeft(2, '0')}';
            SnackBarHelper.show(ctx, l10n.snackbarEventDropped(details.event.title, timeStr));
          }
          return true;
        },
        onEventResized: (ctx, details) {
          if (mounted) {
            final minutes = details.newEndDate.difference(details.newStartDate).inMinutes;
            SnackBarHelper.show(ctx, l10n.snackbarEventResized(details.event.title, minutes.toString()));
          }
          return true;
        },
        onTimeSlotDoubleTap: (ctx, slotContext) {
          if (!slotContext.isAllDayArea) {
            _handleCreateEvent(DateTime(
              slotContext.displayDate.year,
              slotContext.displayDate.month,
              slotContext.displayDate.day,
              slotContext.hour ?? 0,
              slotContext.minute ?? 0,
            ));
          }
        },
        onCreateEventRequested: (ctx, startTime) {
          _handleCreateEvent(startTime);
          return true;
        },
        onDeleteEventRequested: (ctx, details) {
          _handleDeleteEvent(details.event);
          return true;
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
  const _SectionHeader({
    required this.icon,
    required this.title,
  });

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

class _ModeSection extends StatelessWidget {
  const _ModeSection({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
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
