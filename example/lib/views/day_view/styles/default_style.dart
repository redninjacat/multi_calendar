import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../l10n/app_localizations.dart';
import '../../../widgets/day_view_event_form_dialog.dart';
import '../../../widgets/event_detail_dialog.dart';
import '../../../widgets/style_description.dart';

/// Default Day View style - clean, neutral theme with default builders.
///
/// This demonstrates the out-of-the-box appearance using only the
/// library's built-in defaults derived from the app's ThemeData.
///
/// Features:
/// - No MCalTheme customization (uses library defaults)
/// - Full CRUD: double-tap to create, tap event to edit/delete, Cmd+N/E/D
/// - Drag-to-move and resize
/// - Sample events provided by showcase controller
class DefaultDayStyle extends StatefulWidget {
  const DefaultDayStyle({
    super.key,
    required this.eventController,
    required this.locale,
    required this.isDarkMode,
    required this.description,
  });

  final MCalEventController eventController;
  final Locale locale;
  final bool isDarkMode;
  final String description;

  @override
  State<DefaultDayStyle> createState() => _DefaultDayStyleState();
}

class _DefaultDayStyleState extends State<DefaultDayStyle> {
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
    return Column(
      children: [
        StyleDescription(description: widget.description),
        Expanded(
          child: MCalDayView(
            controller: widget.eventController,
            locale: widget.locale,
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
                widget.locale,
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
                  )!.eventResized(details.event.title, minutes.toString()),
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
    );
  }
}
