import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import 'day_view_event_form_dialog.dart';

/// Helper for Day View CRUD operations. Use with StatefulWidgets that have
/// an [MCalEventController] and need create/edit/delete dialogs.
mixin DayViewCrudHelper<T extends StatefulWidget> on State<T> {
  MCalEventController get eventController;
  Locale get locale;

  void showCrudSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
    }
  }

  Future<void> handleCreateEvent(DateTime time) async {
    final event = await showDayViewEventCreateDialog(
      context,
      displayDate: eventController.displayDate,
      initialTime: time,
    );
    if (event != null && mounted) {
      eventController.addEvents([event]);
      showCrudSnackBar('Created: ${event.title}');
    }
  }

  Future<void> handleCreateEventAtDefaultTime() async {
    final d = eventController.displayDate;
    final now = DateTime.now();
    final defaultTime = DateTime(d.year, d.month, d.day, now.hour + 1, 0);
    await handleCreateEvent(defaultTime);
  }

  Future<void> handleEditEvent(MCalCalendarEvent event) async {
    final edited = await showDayViewEventEditDialog(
      context,
      event: event,
      displayDate: eventController.displayDate,
    );
    if (edited != null && mounted) {
      eventController.removeEvents([event.id]);
      eventController.addEvents([edited]);
      showCrudSnackBar('Updated: ${edited.title}');
    }
  }

  Future<void> handleDeleteEvent(MCalCalendarEvent event) async {
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
      eventController.removeEvents([event.id]);
      showCrudSnackBar('Deleted: ${event.title}');
    }
  }
}
