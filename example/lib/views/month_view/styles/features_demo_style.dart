import 'package:example/widgets/day_events_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../utils/sample_events.dart';
import '../../../widgets/recurrence_edit_scope_dialog.dart';
import '../../../widgets/recurrence_editor_dialog.dart';
import '../../../widgets/style_description.dart';

/// Features Demo - showcases MCalMonthView features and configuration options.
///
/// This demonstrates:
/// - All theme-configurable properties via sliders and dropdowns
/// - Complete tap, long press, and hover handlers for all elements
/// - Multi-view synchronization
/// - Keyboard navigation
/// - Drag-and-drop
/// - Loading/error states
class FeaturesDemoStyle extends StatefulWidget {
  const FeaturesDemoStyle({
    super.key,
    required this.locale,
    required this.isDarkMode,
    required this.description,
  });

  final Locale locale;
  final bool isDarkMode;
  final String description;

  @override
  State<FeaturesDemoStyle> createState() => _FeaturesDemoStyleState();
}

class _FeaturesDemoStyleState extends State<FeaturesDemoStyle> {
  // Shared controller for multi-view sync demo
  late MCalEventController _sharedController;

  // ============================================================
  // Feature Toggles
  // ============================================================
  bool _showWeekNumbers = false;
  bool _enableAnimations = true;
  bool _enableDragToMove = true;
  bool _enableDragToResize = true;
  bool _useCustomDropTargetTile = false;
  bool _showDropTargetTiles = true;
  bool _showDropTargetOverlay = true;
  bool _dropTargetTilesAboveOverlay = false;
  bool _enableBlackoutDays = false;
  int _dragEdgeNavigationDelayMs = 900;
  final bool _dragEdgeNavigationEnabled = true;

  /// Blackout dates (2 in initial month, 2 in following month) that reject drops.
  /// Computed at init to avoid dates where sample events exist.
  late Set<DateTime> _blackoutDates;

  // ============================================================
  // Theme Settings (matching Layout POC levers)
  // ============================================================

  // Date label settings
  DateLabelPosition _dateLabelPosition = DateLabelPosition.topLeft;
  double _dateLabelHeight = 18.0;

  // Event tile settings
  int _maxVisibleEventsPerDay = 5;
  double _tileHeight = 18.0;
  double _tileVerticalSpacing = 2.0;
  double _tileHorizontalSpacing = 2.0;
  double _eventTileCornerRadius = 4.0;
  double _tileBorderWidth = 0.0;

  // Overflow indicator settings
  double _overflowIndicatorHeight = 14.0;

  // Control panel expansion state for mobile
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    _sharedController = MCalEventController();
    final sampleEvents = createSampleEvents();
    _sharedController.addEvents(sampleEvents);
    _blackoutDates = _computeBlackoutDates();
  }

  /// Computes 2 blackout days in the current month and 2 in the following month,
  /// excluding any dates where events exist (including recurring occurrences).
  Set<DateTime> _computeBlackoutDates() {
    final now = DateTime.now();
    final rangeStart = DateTime(now.year, now.month, 1);
    final rangeEnd = DateTime(now.year, now.month + 2, 0);
    final expandedEvents = _sharedController.getEventsForRange(
      DateTimeRange(start: rangeStart, end: rangeEnd),
    );

    final datesWithEvents = <DateTime>{};
    for (final event in expandedEvents) {
      var d = DateTime(event.start.year, event.start.month, event.start.day);
      final endDay = DateTime(event.end.year, event.end.month, event.end.day);
      while (d.isBefore(endDay) || _isSameDay(d, endDay)) {
        datesWithEvents.add(DateTime(d.year, d.month, d.day));
        d = DateTime(d.year, d.month, d.day + 1);
      }
    }

    final lastDayCurrent = DateTime(now.year, now.month + 1, 0).day;
    final lastDayNext = DateTime(now.year, now.month + 2, 0).day;

    final result = <DateTime>{};
    for (int day = 1; day <= lastDayCurrent && result.length < 2; day++) {
      final dt = DateTime(now.year, now.month, day);
      if (!datesWithEvents.any((e) => _isSameDay(e, dt))) {
        result.add(dt);
      }
    }
    for (int day = 1; day <= lastDayNext && result.length < 4; day++) {
      final dt = DateTime(now.year, now.month + 1, day);
      if (!datesWithEvents.any((e) => _isSameDay(e, dt))) {
        result.add(dt);
      }
    }
    return result;
  }

  bool _isBlackoutDate(DateTime date) {
    return _blackoutDates.any((d) => _isSameDay(d, date));
  }

  bool _proposedRangeOverlapsBlackout(
    DateTime proposedStart,
    DateTime proposedEnd,
  ) {
    var d = DateTime(
      proposedStart.year,
      proposedStart.month,
      proposedStart.day,
    );
    final endDay = DateTime(
      proposedEnd.year,
      proposedEnd.month,
      proposedEnd.day,
    );
    while (d.isBefore(endDay) || _isSameDay(d, endDay)) {
      if (_isBlackoutDate(d)) return true;
      d = DateTime(d.year, d.month, d.day + 1);
    }
    return false;
  }

  @override
  void dispose() {
    _sharedController.dispose();
    super.dispose();
  }

  // ============================================================
  // Alert Helpers
  // ============================================================

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  /// Builds a day cell with blackout styling when the date is a blackout day.
  Widget _buildDayCellWithBlackout(
    BuildContext context,
    MCalDayCellContext ctx,
    Widget defaultCell,
    ColorScheme colorScheme,
  ) {
    if (!_isBlackoutDate(ctx.date)) return defaultCell;
    return Stack(
      fit: StackFit.expand,
      children: [
        defaultCell,
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.75,
              ),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.block,
                size: 20,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a custom drop target tile: same look as default (color, border,
  /// rounded corners) but without text. Used when "Custom drag target tile" is on.
  Widget _buildCustomDropTargetTile(
    BuildContext context,
    MCalEventTileContext tileContext,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final valid = tileContext.dropValid ?? true;
    return Container(
      decoration: BoxDecoration(
        color: valid
            ? colorScheme.primary.withValues(alpha: 0.3)
            : colorScheme.error.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: valid ? colorScheme.primary : colorScheme.error,
          width: 2,
        ),
      ),
    );
  }

  // ============================================================
  // Handler Callbacks
  // ============================================================

  void _onCellTap(BuildContext context, MCalCellTapDetails details) {
    final dateStr = _formatDate(details.date);
    final isToday = _isSameDay(details.date, DateTime.now());
    _showSnackBar(
      context,
      'Cell Tapped: You tapped the cell for $dateStr. '
      'Events: ${details.events.length}. '
      'Is today: $isToday. Is current month: ${details.isCurrentMonth}',
    );
  }

  void _onCellLongPress(BuildContext context, MCalCellTapDetails details) {
    final dateStr = _formatDate(details.date);
    _showSnackBar(
      context,
      'Cell Long-Pressed: You long-pressed the cell for $dateStr. '
      'Events: ${details.events.length}',
    );
  }

  void _onDateLabelTap(BuildContext context, MCalDateLabelTapDetails details) {
    final dateStr = _formatDate(details.date);
    _showSnackBar(
      context,
      'Date Label Tapped: You tapped the date label for $dateStr. '
      'Is today: ${details.isToday}. Is current month: ${details.isCurrentMonth}',
    );
  }

  void _onDateLabelLongPress(
    BuildContext context,
    MCalDateLabelTapDetails details,
  ) {
    final dateStr = _formatDate(details.date);
    _showSnackBar(
      context,
      'Date Label Long-Pressed: You long-pressed the date label for $dateStr',
    );
  }

  void _onEventTap(BuildContext context, MCalEventTapDetails details) {
    _showEventActionMenu(context, details.event);
  }

  void _onEventLongPress(BuildContext context, MCalEventTapDetails details) {
    final event = details.event;
    final dateStr = _formatDate(details.displayDate);
    final isRecurring = event.occurrenceId != null;
    _showSnackBar(
      context,
      'Event Long-Pressed: "${event.title}" on $dateStr. '
      'All-day: ${event.isAllDay}. Recurring: $isRecurring',
    );
  }

  /// Shows a bottom sheet with Edit and Delete options for the tapped event.
  void _showEventActionMenu(
    BuildContext outerContext,
    MCalCalendarEvent event,
  ) {
    final isRecurring = event.occurrenceId != null;
    showModalBottomSheet(
      context: outerContext,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isRecurring)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.repeat,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Recurring event',
                              style: Theme.of(ctx).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.edit_outlined, color: colorScheme.primary),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  if (isRecurring) {
                    _handleRecurringEventTap(outerContext, event);
                  } else {
                    _handleNonRecurringEventEdit(outerContext, event);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: colorScheme.error),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  if (isRecurring) {
                    _handleRecurringEventDelete(outerContext, event);
                  } else {
                    _handleNonRecurringEventDelete(outerContext, event);
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// Handles edit for a non-recurring event.
  Future<void> _handleNonRecurringEventEdit(
    BuildContext context,
    MCalCalendarEvent event,
  ) async {
    final edited = await _showEventEditDialog(context, event);
    if (edited != null && mounted) {
      _sharedController.removeEvents([event.id]);
      _sharedController.addEvents([edited]);
    }
  }

  // ============================================================
  // Recurring Event Helpers
  // ============================================================

  /// Extracts the series (master) ID from a recurring occurrence's event ID.
  ///
  /// Occurrence IDs follow the pattern `"{masterId}_{iso8601Date}"`, so we
  /// strip the last `_<iso8601>` suffix to recover the master ID.
  String _extractSeriesId(MCalCalendarEvent event) {
    final occId = event.occurrenceId!;
    final suffix = '_$occId';
    final id = event.id;
    if (id.endsWith(suffix)) {
      return id.substring(0, id.length - suffix.length);
    }
    return id;
  }

  /// Parses the occurrence date from an occurrence's [occurrenceId].
  DateTime _parseOccurrenceDate(String occurrenceId) {
    return DateTime.parse(occurrenceId);
  }

  // ── Add Recurring Event ────────────────────────────────────────────────

  Future<void> _onAddRecurringEvent(BuildContext context) async {
    final rule = await RecurrenceEditorDialog.show(context);
    if (rule == null || !mounted) return;

    final now = DateTime.now();
    final newId = 'recurring-user-${now.millisecondsSinceEpoch}';
    final event = MCalCalendarEvent(
      id: newId,
      title: 'New Recurring Event',
      start: DateTime(now.year, now.month, now.day, now.hour + 1, 0),
      end: DateTime(now.year, now.month, now.day, now.hour + 2, 0),
      isAllDay: false,
      color: const Color(0xFF6366F1),
      recurrenceRule: rule,
    );
    _sharedController.addEvents([event]);
  }

  // ── Recurring Event Tap (Edit) — Google Calendar "edit-then-prompt" ────

  Future<void> _handleRecurringEventTap(
    BuildContext context,
    MCalCalendarEvent event,
  ) async {
    final seriesId = _extractSeriesId(event);
    final occurrenceDate = _parseOccurrenceDate(event.occurrenceId!);
    final master = _sharedController.getEventById(seriesId);

    // Detect whether this occurrence is an existing exception
    final exceptions = _sharedController.getExceptions(seriesId);
    final normalizedOccDate = DateTime(
      occurrenceDate.year,
      occurrenceDate.month,
      occurrenceDate.day,
    );
    final isException = exceptions.any((ex) {
      final d = ex.originalDate;
      return DateTime(d.year, d.month, d.day) == normalizedOccDate;
    });

    // Step 1: Open edit dialog IMMEDIATELY (shows occurrence data)
    final result = await _showRecurringEventEditDialog(
      context,
      occurrence: event,
      masterRule: master?.recurrenceRule,
      isException: isException,
    );
    if (result == null || !mounted) return;

    final (editedEvent, editedRule) = result;

    // Step 2: Ask scope AFTER editing (Google Calendar pattern)
    if (!mounted) return;
    final scope = await RecurrenceEditScopeDialog.show(this.context);
    if (scope == null || !mounted) return;

    // Step 3: Apply based on scope
    switch (scope) {
      case RecurrenceEditScope.thisEvent:
        // Apply title/color only as modified exception (RRULE changes ignored)
        _sharedController.modifyOccurrence(
          seriesId,
          occurrenceDate,
          editedEvent,
        );

      case RecurrenceEditScope.thisAndFollowing:
        final newSeriesId = _sharedController.splitSeries(
          seriesId,
          occurrenceDate,
        );
        final newMaster = _sharedController.getEventById(newSeriesId);
        if (newMaster != null && mounted) {
          _sharedController.updateRecurringEvent(
            newMaster.copyWith(
              title: editedEvent.title,
              color: editedEvent.color,
              recurrenceRule: editedRule ?? newMaster.recurrenceRule,
            ),
          );
        }

      case RecurrenceEditScope.allEvents:
        if (master != null && mounted) {
          _sharedController.updateRecurringEvent(
            master.copyWith(
              title: editedEvent.title,
              color: editedEvent.color,
              recurrenceRule: editedRule ?? master.recurrenceRule,
            ),
          );
        }
    }
  }

  // ── Recurring Event Long-Press (Delete) ─────────────────────────────────

  Future<void> _handleRecurringEventDelete(
    BuildContext context,
    MCalCalendarEvent event,
  ) async {
    final seriesId = _extractSeriesId(event);
    final occurrenceDate = _parseOccurrenceDate(event.occurrenceId!);

    // Ask scope
    final scope = await _showDeleteScopeDialog(context, event.title);
    if (scope == null || !mounted) return;

    switch (scope) {
      case RecurrenceEditScope.thisEvent:
        _sharedController.addException(
          seriesId,
          MCalRecurrenceException.deleted(originalDate: occurrenceDate),
        );

      case RecurrenceEditScope.thisAndFollowing:
        final newSeriesId = _sharedController.splitSeries(
          seriesId,
          occurrenceDate,
        );
        _sharedController.deleteRecurringEvent(newSeriesId);

      case RecurrenceEditScope.allEvents:
        _sharedController.deleteRecurringEvent(seriesId);
    }
  }

  /// Handles delete for a non-recurring event.
  Future<void> _handleNonRecurringEventDelete(
    BuildContext context,
    MCalCalendarEvent event,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      _sharedController.removeEvents([event.id]);
    }
  }

  /// Shows a delete-scope dialog for recurring events, combining the scope
  /// choice with a delete confirmation.
  Future<RecurrenceEditScope?> _showDeleteScopeDialog(
    BuildContext context,
    String eventTitle,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return showDialog<RecurrenceEditScope>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete recurring event'),
        contentPadding: const EdgeInsets.only(top: 12, bottom: 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'How would you like to delete "$eventTitle"?',
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.event_busy, color: colorScheme.error),
              title: const Text('This event only'),
              subtitle: const Text('Remove just this occurrence'),
              onTap: () => Navigator.of(ctx).pop(RecurrenceEditScope.thisEvent),
            ),
            ListTile(
              leading: Icon(Icons.arrow_forward, color: colorScheme.error),
              title: const Text('This and following events'),
              subtitle: const Text('Remove this and all future occurrences'),
              onTap: () =>
                  Navigator.of(ctx).pop(RecurrenceEditScope.thisAndFollowing),
            ),
            ListTile(
              leading: Icon(Icons.delete_forever, color: colorScheme.error),
              title: const Text('All events'),
              subtitle: const Text('Remove the entire series'),
              onTap: () => Navigator.of(ctx).pop(RecurrenceEditScope.allEvents),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Shows a recurring-event edit dialog following the Google Calendar
  /// "edit-then-prompt" pattern.
  ///
  /// Displays the tapped [occurrence]'s data (title, color, date/time) along
  /// with a recurrence context banner. When [isException] is true the banner
  /// indicates a modified occurrence and the recurrence-rule editor is hidden.
  ///
  /// Returns a record of (editedEvent, rule) or null if cancelled.
  /// - `editedEvent` contains the edited title/color.
  /// - `rule` is the (possibly changed) recurrence rule, or the unchanged
  ///   [masterRule] if the user didn't interact with the recurrence editor.
  Future<(MCalCalendarEvent, MCalRecurrenceRule?)?>
  _showRecurringEventEditDialog(
    BuildContext context, {
    required MCalCalendarEvent occurrence,
    required MCalRecurrenceRule? masterRule,
    required bool isException,
  }) {
    final titleController = TextEditingController(text: occurrence.title);
    final colors = <Color>[
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFFEC4899), // Pink
      const Color(0xFF0EA5E9), // Sky
      const Color(0xFFF97316), // Orange
      const Color(0xFFD946EF), // Fuchsia
    ];
    Color selectedColor = occurrence.color ?? colors.first;
    MCalRecurrenceRule? currentRule = masterRule;

    return showDialog<(MCalCalendarEvent, MCalRecurrenceRule?)>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final colorScheme = Theme.of(ctx).colorScheme;
            final textTheme = Theme.of(ctx).textTheme;

            return AlertDialog(
              titlePadding: EdgeInsets.zero,
              title: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isException
                      ? colorScheme.errorContainer.withAlpha(100)
                      : colorScheme.primaryContainer.withAlpha(100),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isException ? Icons.edit_note : Icons.repeat,
                          size: 20,
                          color: isException
                              ? colorScheme.error
                              : colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isException
                                ? 'Modified Occurrence'
                                : 'Edit Recurring Event',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isException
                                  ? colorScheme.onErrorContainer
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isException
                          ? 'This occurrence has been individually modified'
                          : masterRule != null
                          ? _describeRule(masterRule)
                          : 'Recurring event',
                      style: textTheme.bodySmall?.copyWith(
                        color: isException
                            ? colorScheme.onErrorContainer.withAlpha(180)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Date / time display ───────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withAlpha(
                          60,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _formatEventRange(occurrence),
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ── Title field ───────────────────────────────────
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ── Color picker ──────────────────────────────────
                    Text(
                      'Color',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: colors.map((c) {
                        final isSelected = c == selectedColor;
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedColor = c),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: colorScheme.onSurface,
                                      width: 3,
                                    )
                                  : null,
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    size: 18,
                                    color:
                                        ThemeData.estimateBrightnessForColor(
                                              c,
                                            ) ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    // ── Recurrence section (hidden for exceptions) ───
                    if (!isException) ...[
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Recurrence',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withAlpha(
                            80,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentRule != null
                                  ? _describeRule(currentRule!)
                                  : 'No recurrence',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      final newRule =
                                          await RecurrenceEditorDialog.show(
                                            ctx,
                                            existing: currentRule,
                                          );
                                      if (newRule != null) {
                                        setDialogState(
                                          () => currentRule = newRule,
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: Text(
                                      currentRule != null
                                          ? 'Change Rule'
                                          : 'Add Rule',
                                    ),
                                  ),
                                ),
                                if (currentRule != null) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      setDialogState(() => currentRule = null);
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      size: 18,
                                      color: colorScheme.error,
                                    ),
                                    tooltip: 'Remove recurrence',
                                    style: IconButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final edited = occurrence.copyWith(
                      title: titleController.text.trim().isNotEmpty
                          ? titleController.text.trim()
                          : occurrence.title,
                      color: selectedColor,
                    );
                    Navigator.of(ctx).pop((edited, currentRule));
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Shows a simple event-editing dialog for non-recurring events (title and
  /// color only).
  Future<MCalCalendarEvent?> _showEventEditDialog(
    BuildContext context,
    MCalCalendarEvent event,
  ) {
    final titleController = TextEditingController(text: event.title);
    final colors = <Color>[
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFFEC4899), // Pink
      const Color(0xFF0EA5E9), // Sky
      const Color(0xFFF97316), // Orange
      const Color(0xFFD946EF), // Fuchsia
    ];
    Color selectedColor = event.color ?? colors.first;

    return showDialog<MCalCalendarEvent>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final colorScheme = Theme.of(ctx).colorScheme;
            return AlertDialog(
              title: const Text('Edit Event'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 18,
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formatEventRange(event),
                          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(ctx).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Color',
                    style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: colors.map((c) {
                      final isSelected = c == selectedColor;
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedColor = c),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: colorScheme.onSurface,
                                    width: 3,
                                  )
                                : null,
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  size: 18,
                                  color:
                                      ThemeData.estimateBrightnessForColor(c) ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final edited = event.copyWith(
                      title: titleController.text.trim().isNotEmpty
                          ? titleController.text.trim()
                          : event.title,
                      color: selectedColor,
                    );
                    Navigator.of(ctx).pop(edited);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Produces a human-readable summary of a recurrence rule.
  String _describeRule(MCalRecurrenceRule rule) {
    final freq = switch (rule.frequency) {
      MCalFrequency.daily => 'Daily',
      MCalFrequency.weekly => 'Weekly',
      MCalFrequency.monthly => 'Monthly',
      MCalFrequency.yearly => 'Yearly',
    };
    final buffer = StringBuffer(freq);

    if (rule.interval > 1) {
      buffer.write(' (every ${rule.interval})');
    }

    if (rule.byWeekDays != null && rule.byWeekDays!.isNotEmpty) {
      final dayNames = rule.byWeekDays!
          .map((wd) {
            return switch (wd.dayOfWeek) {
              DateTime.monday => 'Mon',
              DateTime.tuesday => 'Tue',
              DateTime.wednesday => 'Wed',
              DateTime.thursday => 'Thu',
              DateTime.friday => 'Fri',
              DateTime.saturday => 'Sat',
              DateTime.sunday => 'Sun',
              _ => '?',
            };
          })
          .join(', ');
      buffer.write(' on $dayNames');
    }

    if (rule.byMonthDays != null && rule.byMonthDays!.isNotEmpty) {
      buffer.write(' on day ${rule.byMonthDays!.join(", ")}');
    }

    if (rule.byYearDays != null && rule.byYearDays!.isNotEmpty) {
      buffer.write(' on year-day ${rule.byYearDays!.join(", ")}');
    }

    if (rule.byWeekNumbers != null && rule.byWeekNumbers!.isNotEmpty) {
      buffer.write(' in week ${rule.byWeekNumbers!.join(", ")}');
    }

    if (rule.count != null) {
      buffer.write(' \u00d7${rule.count}');
    } else if (rule.until != null) {
      buffer.write(
        ' until ${rule.until!.month}/${rule.until!.day}/${rule.until!.year}',
      );
    }

    return buffer.toString();
  }

  void _onOverflowLongPress(
    BuildContext context,
    MCalOverflowTapDetails details,
  ) {
    _showSnackBar(
      context,
      'Overflow Indicator Long-Pressed: Date: ${_formatDate(details.date)}. '
      'Hidden: ${details.hiddenEventCount} events. '
      'Total: ${details.allEvents.length} events',
    );
  }

  // ============================================================
  // Hover Callbacks (with Tooltip in status bar)
  // ============================================================
  String _hoverStatus = 'Hover over cells, date labels, or events';

  void _onHoverCell(MCalDayCellContext? ctx) {
    setState(() {
      if (ctx == null) {
        _hoverStatus = 'Hover over cells, date labels, or events';
      } else {
        final dateStr = _formatDate(ctx.date);
        _hoverStatus =
            'CELL: $dateStr | Events: ${ctx.events.length} | '
            'Today: ${ctx.isToday} | Focused: ${ctx.isFocused} | '
            'Current month: ${ctx.isCurrentMonth}';
      }
    });
  }

  void _onHoverEvent(MCalEventTileContext? ctx) {
    setState(() {
      if (ctx == null) {
        _hoverStatus = 'Hover over cells, date labels, or events';
      } else {
        _hoverStatus =
            'EVENT: "${ctx.event.title}" | '
            'Date: ${_formatDate(ctx.displayDate)} | '
            'All-day: ${ctx.isAllDay} | '
            'Start: ${_formatDate(ctx.event.start)} | '
            'End: ${_formatDate(ctx.event.end)}';
      }
    });
  }

  // ============================================================
  // Build Theme from Settings
  // ============================================================

  MCalThemeData _buildTheme(ColorScheme colorScheme) {
    return MCalThemeData(
      // Date label styling
      dateLabelPosition: _dateLabelPosition,
      dateLabelHeight: _dateLabelHeight,

      // Event tile styling
      eventTileHeight: _tileHeight,
      eventTileVerticalSpacing: _tileVerticalSpacing,
      eventTileHorizontalSpacing: _tileHorizontalSpacing,
      eventTileCornerRadius: _eventTileCornerRadius,
      eventTileBorderWidth: _tileBorderWidth,
      eventTileBorderColor: _tileBorderWidth > 0 ? colorScheme.outline : null,

      // Overflow indicator
      overflowIndicatorHeight: _overflowIndicatorHeight,

      // Focused date styling (for keyboard navigation)
      focusedDateBackgroundColor: colorScheme.primary.withValues(alpha: 0.2),
      focusedDateTextStyle: TextStyle(
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;
        final isDesktop = constraints.maxWidth > 900;
        final isMobile = !isWideScreen;

        if (isMobile) {
          return _buildMobileLayout(colorScheme);
        }

        // Tablet/Desktop: Full feature layout
        return Column(
          children: [
            StyleDescription(
              description: widget.description,
              compact: isDesktop,
            ),
            if (isDesktop) _buildKeyboardShortcutsBar(colorScheme),
            _buildControlPanel(colorScheme, isDesktop),
            if (isDesktop) _buildHoverStatusBar(colorScheme),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildPrimaryCalendar(colorScheme, isDesktop),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildSecondaryCalendar(colorScheme, isDesktop),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // Mobile Layout
  // ============================================================

  Widget _buildMobileLayout(ColorScheme colorScheme) {
    final screenHeight = MediaQuery.of(context).size.height;
    final calendarHeight = screenHeight * 0.65;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Compact header with settings toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(80),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Features Demo',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _showControls ? Icons.expand_less : Icons.tune,
                    color: colorScheme.primary,
                  ),
                  onPressed: () =>
                      setState(() => _showControls = !_showControls),
                  tooltip: 'Toggle settings',
                ),
              ],
            ),
          ),
          if (_showControls) _buildMobileControlPanel(colorScheme),
          // Calendar with fixed height
          SizedBox(
            height: calendarHeight,
            child: MCalTheme(
              data: _buildTheme(colorScheme),
              child: MCalMonthView(
                controller: _sharedController,
                showNavigator: true,
                enableSwipeNavigation: true,
                locale: widget.locale,
                showWeekNumbers: _showWeekNumbers,
                enableAnimations: _enableAnimations,
                maxVisibleEventsPerDay: _maxVisibleEventsPerDay,
                enableKeyboardNavigation: false,
                enableDragToMove: _enableDragToMove,
                // On mobile, let the library auto-detect (disabled by default
                // on phones). On desktop/tablet the toggle controls it.
                enableDragToResize: null,
                showDropTargetTiles: _showDropTargetTiles,
                showDropTargetOverlay: _showDropTargetOverlay,
                dropTargetTilesAboveOverlay: _dropTargetTilesAboveOverlay,
                dragEdgeNavigationEnabled: _dragEdgeNavigationEnabled,
                dragEdgeNavigationDelay: Duration(
                  milliseconds: _dragEdgeNavigationDelayMs,
                ),
                // Tap/LongPress handlers
                onCellTap: _onCellTap,
                onCellLongPress: _onCellLongPress,
                onDateLabelTap: _onDateLabelTap,
                onDateLabelLongPress: _onDateLabelLongPress,
                onEventTap: _onEventTap,
                onEventLongPress: _onEventLongPress,
                onOverflowTap: (context, details) {
                  showDayEventsBottomSheet(
                    context,
                    details.date,
                    details.allEvents,
                    widget.locale,
                  );
                },
                onOverflowLongPress: _onOverflowLongPress,
                dayCellBuilder: _enableBlackoutDays
                    ? (context, ctx, defaultCell) => _buildDayCellWithBlackout(
                        context,
                        ctx,
                        defaultCell,
                        colorScheme,
                      )
                    : null,
                onDragWillAccept: _enableDragToMove && _enableBlackoutDays
                    ? (context, details) => !_proposedRangeOverlapsBlackout(
                        details.proposedStartDate,
                        details.proposedEndDate,
                      )
                    : null,
                // Drag-and-drop callback
                onEventDropped: _enableDragToMove
                    ? (context, details) {
                        return true;
                      }
                    : null,
                // Resize callbacks
                onResizeWillAccept: _enableDragToResize
                    ? (context, details) {
                        // Accept all resizes in the demo
                        return true;
                      }
                    : null,
                onEventResized: _enableDragToResize
                    ? (context, details) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Resized "${details.event.title}" '
                              '${details.resizeEdge.name} edge: '
                              '${_formatDate(details.newStartDate)} to '
                              '${_formatDate(details.newEndDate)}'
                              '${details.isRecurring ? ' (recurring)' : ''}',
                            ),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        return true;
                      }
                    : null,
                dropTargetTileBuilder:
                    _enableDragToMove && _useCustomDropTargetTile
                    ? (context, tileContext) =>
                          _buildCustomDropTargetTile(context, tileContext)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ============================================================
  // Mobile Control Panel
  // ============================================================

  Widget _buildMobileControlPanel(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Toggles (Wrap avoids overflow on narrow screens)
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildCompactToggle(
                'Week #',
                _showWeekNumbers,
                (v) => setState(() => _showWeekNumbers = v),
                colorScheme,
              ),
              _buildCompactToggle(
                'Animate',
                _enableAnimations,
                (v) => setState(() => _enableAnimations = v),
                colorScheme,
              ),
              _buildCompactToggle(
                'Drag',
                _enableDragToMove,
                (v) => setState(() => _enableDragToMove = v),
                colorScheme,
              ),
              _buildCompactToggle(
                'Custom drop tile',
                _useCustomDropTargetTile,
                (v) => setState(() => _useCustomDropTargetTile = v),
                colorScheme,
              ),
              _buildCompactToggle(
                'Drop tiles',
                _showDropTargetTiles,
                (v) => setState(() => _showDropTargetTiles = v),
                colorScheme,
              ),
              _buildCompactToggle(
                'Drop overlay',
                _showDropTargetOverlay,
                (v) => setState(() => _showDropTargetOverlay = v),
                colorScheme,
              ),
              _buildCompactToggle(
                'Tiles above',
                _dropTargetTilesAboveOverlay,
                (v) => setState(() => _dropTargetTilesAboveOverlay = v),
                colorScheme,
              ),
              _buildCompactToggle(
                'Blackout days',
                _enableBlackoutDays,
                (v) => setState(() => _enableBlackoutDays = v),
                colorScheme,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Date label position
          _buildDropdownRow(
            'Label:',
            _dateLabelPosition,
            DateLabelPosition.values,
            (v) => setState(() => _dateLabelPosition = v),
            colorScheme,
          ),
          const SizedBox(height: 8),
          // Sliders
          _buildSliderRow(
            'Events',
            _maxVisibleEventsPerDay.toDouble(),
            1,
            10,
            9,
            (v) => setState(() => _maxVisibleEventsPerDay = v.round()),
            colorScheme,
            suffix: '',
          ),
          _buildSliderRow(
            'Tile H',
            _tileHeight,
            10,
            30,
            20,
            (v) => setState(() => _tileHeight = v),
            colorScheme,
          ),
          _buildSliderRow(
            'Corner',
            _eventTileCornerRadius,
            0,
            10,
            10,
            (v) => setState(() => _eventTileCornerRadius = v),
            colorScheme,
          ),
          _buildSliderRow(
            'Border',
            _tileBorderWidth,
            0,
            3,
            6,
            (v) => setState(() => _tileBorderWidth = v),
            colorScheme,
          ),
          _buildSliderRow(
            'V-Space',
            _tileVerticalSpacing,
            0,
            6,
            6,
            (v) => setState(() => _tileVerticalSpacing = v),
            colorScheme,
          ),
          _buildSliderRow(
            'H-Space',
            _tileHorizontalSpacing,
            0,
            6,
            6,
            (v) => setState(() => _tileHorizontalSpacing = v),
            colorScheme,
          ),
          _buildSliderRow(
            'Label H',
            _dateLabelHeight,
            12,
            28,
            16,
            (v) => setState(() => _dateLabelHeight = v),
            colorScheme,
          ),
          _buildSliderRow(
            'Overflow',
            _overflowIndicatorHeight,
            10,
            20,
            10,
            (v) => setState(() => _overflowIndicatorHeight = v),
            colorScheme,
          ),
          const SizedBox(height: 12),
          // ── Action buttons ──────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _onAddRecurringEvent(context),
                  icon: const Icon(Icons.repeat, size: 18),
                  label: const Text('Add Recurring Event'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Desktop Control Panel
  // ============================================================

  Widget _buildControlPanel(ColorScheme colorScheme, bool isDesktop) {
    final padding = isDesktop
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    final toggleSpacing = isDesktop ? 14.0 : 24.0;
    final rowGap = isDesktop ? 4.0 : 8.0;
    final sliderWidth = isDesktop ? 72.0 : 100.0;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(100),
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Feature toggles
          Wrap(
            spacing: toggleSpacing,
            runSpacing: rowGap,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildToggle(
                isDesktop ? 'Week #' : 'Week Numbers',
                _showWeekNumbers,
                (v) => setState(() => _showWeekNumbers = v),
                colorScheme,
              ),
              _buildToggle('Animations', _enableAnimations, (v) {
                setState(() => _enableAnimations = v);
              }, colorScheme),
              _buildToggle(
                isDesktop ? 'Drag' : 'Drag & Drop',
                _enableDragToMove,
                (v) => setState(() => _enableDragToMove = v),
                colorScheme,
              ),
              _buildToggle('Resize', _enableDragToResize, (v) {
                setState(() => _enableDragToResize = v);
              }, colorScheme),
              _buildToggle(
                isDesktop ? 'Custom drop tile' : 'Custom drop target tile',
                _useCustomDropTargetTile,
                (v) => setState(() => _useCustomDropTargetTile = v),
                colorScheme,
              ),
              _buildToggle(
                isDesktop ? 'Tiles above' : 'Tiles above overlay',
                _dropTargetTilesAboveOverlay,
                (v) => setState(() => _dropTargetTilesAboveOverlay = v),
                colorScheme,
              ),
              _buildToggle(
                isDesktop ? 'Blackout' : 'Blackout days',
                _enableBlackoutDays,
                (v) => setState(() => _enableBlackoutDays = v),
                colorScheme,
              ),
              // Loading/Error demo buttons
              FilledButton.tonal(
                onPressed: () {
                  _sharedController.setLoading(true);
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) _sharedController.setLoading(false);
                  });
                },
                child: Text(isDesktop ? 'Loading' : 'Show Loading'),
              ),
              FilledButton.tonal(
                onPressed: () {
                  _sharedController.setError(
                    'Demo error: Something went wrong!',
                  );
                },
                child: Text(isDesktop ? 'Error' : 'Show Error'),
              ),
              OutlinedButton(
                onPressed: () {
                  _sharedController.clearError();
                  _sharedController.setLoading(false);
                },
                child: const Text('Clear'),
              ),
              // Recurring event creation
              FilledButton.icon(
                onPressed: () => _onAddRecurringEvent(context),
                icon: Icon(Icons.repeat, size: isDesktop ? 16 : 18),
                label: Text(
                  isDesktop ? 'Add Recurring' : 'Add Recurring Event',
                ),
              ),
            ],
          ),
          SizedBox(height: rowGap),
          // Row 2: Theme settings
          Wrap(
            spacing: isDesktop ? 10.0 : 16.0,
            runSpacing: rowGap,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Date label position
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Label:',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<DateLabelPosition>(
                    value: _dateLabelPosition,
                    isDense: true,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface,
                    ),
                    items: DateLabelPosition.values.map((pos) {
                      return DropdownMenuItem(
                        value: pos,
                        child: Text(pos.name),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _dateLabelPosition = v);
                    },
                  ),
                ],
              ),
              // Max events slider
              _buildCompactSlider(
                'Max Events',
                _maxVisibleEventsPerDay.toDouble(),
                1,
                10,
                9,
                (v) => setState(() => _maxVisibleEventsPerDay = v.round()),
                colorScheme,
                showValue: _maxVisibleEventsPerDay.toString(),
                sliderWidth: sliderWidth,
              ),
              // Tile height slider
              _buildCompactSlider(
                'Tile Height',
                _tileHeight,
                10,
                30,
                20,
                (v) => setState(() => _tileHeight = v),
                colorScheme,
                showValue: '${_tileHeight.toInt()}px',
                sliderWidth: sliderWidth,
              ),
              // Corner radius slider
              _buildCompactSlider(
                'Corner',
                _eventTileCornerRadius,
                0,
                10,
                10,
                (v) => setState(() => _eventTileCornerRadius = v),
                colorScheme,
                showValue: '${_eventTileCornerRadius.toInt()}px',
                sliderWidth: sliderWidth,
              ),
              // Border width slider
              _buildCompactSlider(
                'Border',
                _tileBorderWidth,
                0,
                3,
                6,
                (v) => setState(() => _tileBorderWidth = v),
                colorScheme,
                showValue: '${_tileBorderWidth.toStringAsFixed(1)}px',
                sliderWidth: sliderWidth,
              ),
              // Vertical spacing slider
              _buildCompactSlider(
                'V-Space',
                _tileVerticalSpacing,
                0,
                6,
                6,
                (v) => setState(() => _tileVerticalSpacing = v),
                colorScheme,
                showValue: '${_tileVerticalSpacing.toInt()}px',
                sliderWidth: sliderWidth,
              ),
              // Horizontal spacing slider
              _buildCompactSlider(
                'H-Space',
                _tileHorizontalSpacing,
                0,
                6,
                6,
                (v) => setState(() => _tileHorizontalSpacing = v),
                colorScheme,
                showValue: '${_tileHorizontalSpacing.toInt()}px',
                sliderWidth: sliderWidth,
              ),
              // Label height slider
              _buildCompactSlider(
                'Label H',
                _dateLabelHeight,
                12,
                28,
                16,
                (v) => setState(() => _dateLabelHeight = v),
                colorScheme,
                showValue: '${_dateLabelHeight.toInt()}px',
                sliderWidth: sliderWidth,
              ),
              // Overflow indicator height slider
              _buildCompactSlider(
                'Overflow H',
                _overflowIndicatorHeight,
                10,
                20,
                10,
                (v) => setState(() => _overflowIndicatorHeight = v),
                colorScheme,
                showValue: '${_overflowIndicatorHeight.toInt()}px',
                sliderWidth: sliderWidth,
              ),
            ],
          ),
          // Row 3: Drag edge delay (only when drag enabled)
          if (_enableDragToMove)
            Padding(
              padding: EdgeInsets.only(top: rowGap),
              child: _buildCompactSlider(
                'Edge Delay',
                _dragEdgeNavigationDelayMs.toDouble(),
                200,
                1400,
                12,
                (v) => setState(() => _dragEdgeNavigationDelayMs = v.round()),
                colorScheme,
                showValue: '${_dragEdgeNavigationDelayMs}ms',
                sliderWidth: sliderWidth,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // Keyboard Shortcuts Bar
  // ============================================================

  Widget _buildKeyboardShortcutsBar(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      color: colorScheme.primaryContainer.withAlpha(100),
      child: Wrap(
        spacing: 10,
        runSpacing: 2,
        alignment: WrapAlignment.center,
        children: [
          _shortcutChip('←→↑↓', 'Navigate cells', colorScheme),
          _shortcutChip('Enter/Space', 'Select cell', colorScheme),
          _shortcutChip('Home', 'First day', colorScheme),
          _shortcutChip('End', 'Last day', colorScheme),
          _shortcutChip('PgUp/PgDn', 'Prev/Next month', colorScheme),
          if (_enableDragToMove) ...[
            _shortcutChip('Enter/Space', 'Select event', colorScheme),
            _shortcutChip('Arrows', 'Move event', colorScheme),
            if (_enableDragToResize) ...[
              _shortcutChip('R', 'Resize mode', colorScheme),
              _shortcutChip('S/E', 'Start/end edge', colorScheme),
              _shortcutChip('M', 'Move mode', colorScheme),
            ],
            _shortcutChip('Enter', 'Confirm', colorScheme),
            _shortcutChip('Esc', 'Cancel', colorScheme),
          ],
        ],
      ),
    );
  }

  Widget _shortcutChip(String key, String action, ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: colorScheme.outline.withAlpha(100)),
          ),
          child: Text(
            key,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          action,
          style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  // ============================================================
  // Hover Status Bar
  // ============================================================

  Widget _buildHoverStatusBar(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      color: colorScheme.surfaceContainerLow,
      child: Row(
        children: [
          Icon(Icons.mouse, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _hoverStatus,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Primary Calendar
  // ============================================================

  Widget _buildPrimaryCalendar(ColorScheme colorScheme, bool isDesktop) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withAlpha(100),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: ClipRect(
              child: Row(
                children: [
                  Icon(Icons.calendar_month, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      isDesktop
                          ? 'Primary View (Click to focus, then use keyboard)'
                          : 'Calendar',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: MCalTheme(
              data: _buildTheme(colorScheme),
              child: MCalMonthView(
                controller: _sharedController,
                showNavigator: true,
                enableSwipeNavigation: true,
                locale: widget.locale,
                showWeekNumbers: _showWeekNumbers,
                enableAnimations: _enableAnimations,
                maxVisibleEventsPerDay: _maxVisibleEventsPerDay,
                enableKeyboardNavigation: isDesktop,
                enableDragToMove: _enableDragToMove,
                enableDragToResize: _enableDragToResize,
                showDropTargetTiles: _showDropTargetTiles,
                showDropTargetOverlay: _showDropTargetOverlay,
                dropTargetTilesAboveOverlay: _dropTargetTilesAboveOverlay,
                dragEdgeNavigationEnabled: _dragEdgeNavigationEnabled,
                dragEdgeNavigationDelay: Duration(
                  milliseconds: _dragEdgeNavigationDelayMs,
                ),
                // Hover handlers
                onHoverCell: isDesktop ? _onHoverCell : null,
                onHoverEvent: isDesktop ? _onHoverEvent : null,
                // Tap/LongPress handlers
                onCellTap: _onCellTap,
                onCellLongPress: _onCellLongPress,
                onDateLabelTap: _onDateLabelTap,
                onDateLabelLongPress: _onDateLabelLongPress,
                onEventTap: _onEventTap,
                onEventLongPress: _onEventLongPress,
                onOverflowTap: (context, details) {
                  showDayEventsBottomSheet(
                    context,
                    details.date,
                    details.allEvents,
                    widget.locale,
                  );
                },
                onOverflowLongPress: _onOverflowLongPress,
                dayCellBuilder: _enableBlackoutDays
                    ? (context, ctx, defaultCell) => _buildDayCellWithBlackout(
                        context,
                        ctx,
                        defaultCell,
                        colorScheme,
                      )
                    : null,
                onDragWillAccept: _enableDragToMove && _enableBlackoutDays
                    ? (context, details) => !_proposedRangeOverlapsBlackout(
                        details.proposedStartDate,
                        details.proposedEndDate,
                      )
                    : null,
                // Drag-and-drop callback
                onEventDropped: _enableDragToMove
                    ? (context, details) {
                        return true;
                      }
                    : null,
                // Resize callbacks
                onResizeWillAccept: _enableDragToResize
                    ? (context, details) {
                        // Accept all resizes in the demo
                        return true;
                      }
                    : null,
                onEventResized: _enableDragToResize
                    ? (context, details) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Resized "${details.event.title}" '
                              '${details.resizeEdge.name} edge: '
                              '${_formatDate(details.newStartDate)} to '
                              '${_formatDate(details.newEndDate)}'
                              '${details.isRecurring ? ' (recurring)' : ''}',
                            ),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        return true;
                      }
                    : null,
                // Custom drop target cell builder - highlights cells during drag
                dropTargetCellBuilder: _enableDragToMove
                    ? (context, details) {
                        return Container(
                          decoration: BoxDecoration(
                            color: details.isValid
                                ? colorScheme.primary.withValues(alpha: 0.3)
                                : colorScheme.error.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.horizontal(
                              left: details.isFirst
                                  ? const Radius.circular(8)
                                  : Radius.zero,
                              right: details.isLast
                                  ? const Radius.circular(8)
                                  : Radius.zero,
                            ),
                          ),
                        );
                      }
                    : null,
                dropTargetTileBuilder:
                    _enableDragToMove && _useCustomDropTargetTile
                    ? (context, tileContext) =>
                          _buildCustomDropTargetTile(context, tileContext)
                    : null,
                // Example of advanced overlay customization (commented out)
                // dropTargetOverlayBuilder takes precedence over dropTargetCellBuilder
                // when both are provided. Use it for custom painting across all cells.
                // dropTargetOverlayBuilder: (context, details) {
                //   return CustomPaint(
                //     painter: _DropHighlightPainter(
                //       cells: details.highlightedCells,
                //       isValid: details.isValid,
                //       color: colorScheme.primary,
                //     ),
                //   );
                // },
                onFocusedDateChanged: isDesktop
                    ? (date) {
                        if (date != null) {
                          setState(() {
                            _hoverStatus = 'FOCUSED: ${_formatDate(date)}';
                          });
                        }
                      }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Secondary Calendar (Synced)
  // ============================================================

  Widget _buildSecondaryCalendar(ColorScheme colorScheme, bool isDesktop) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withAlpha(100),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: ClipRect(
              child: Row(
                children: [
                  Icon(Icons.sync, color: colorScheme.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Synced View',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: MCalTheme(
              data: MCalThemeData(
                cellBackgroundColor: colorScheme.surfaceContainerLow,
                cellTextStyle: const TextStyle(fontSize: 12),
                dateLabelPosition: _dateLabelPosition,
                eventTileHeight: _tileHeight,
                eventTileCornerRadius: _eventTileCornerRadius,
              ),
              child: MCalMonthView(
                controller: _sharedController,
                showNavigator: false,
                locale: widget.locale,
                showWeekNumbers: _showWeekNumbers,
                enableAnimations: _enableAnimations,
                maxVisibleEventsPerDay: 2,
                enableKeyboardNavigation: false,
                enableDragToMove: false,
                onHoverCell: isDesktop ? _onHoverCell : null,
                onHoverEvent: isDesktop ? _onHoverEvent : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Helper Widgets
  // ============================================================

  Widget _buildToggle(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
        ),
        const SizedBox(width: 8),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildCompactToggle(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
        ),
        const SizedBox(width: 4),
        Switch(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }

  Widget _buildCompactSlider(
    String label,
    double value,
    double min,
    double max,
    int divisions,
    ValueChanged<double> onChanged,
    ColorScheme colorScheme, {
    required String showValue,
    double sliderWidth = 100,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: $showValue',
          style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
        ),
        SizedBox(
          width: sliderWidth,
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSliderRow(
    String label,
    double value,
    double min,
    double max,
    int divisions,
    ValueChanged<double> onChanged,
    ColorScheme colorScheme, {
    String suffix = 'px',
  }) {
    final displayValue = suffix.isEmpty
        ? value.toInt().toString()
        : '${value.toInt()}$suffix';
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label: $displayValue',
            style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownRow<T>(
    String label,
    T value,
    List<T> items,
    ValueChanged<T> onChanged,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<T>(
            value: value,
            isDense: true,
            isExpanded: true,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item.toString().split('.').last,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour == 0
        ? 12
        : dt.hour > 12
        ? dt.hour - 12
        : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  /// Read-only full range string for an event (single-day or multi-day).
  String _formatEventRange(MCalCalendarEvent event) {
    final start = event.start;
    final end = event.end;
    if (_isSameDay(start, end)) {
      return '${_formatDate(start)} ${_formatTime(start)} \u2013 ${_formatTime(end)}';
    }
    return '${_formatDate(start)} ${_formatTime(start)} \u2013 ${_formatDate(end)} ${_formatTime(end)}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
