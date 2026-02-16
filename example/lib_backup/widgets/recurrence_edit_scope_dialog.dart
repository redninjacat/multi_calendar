import 'package:flutter/material.dart';

/// The scope of an edit operation on a recurring event.
enum RecurrenceEditScope {
  /// Only modify this single occurrence.
  thisEvent,

  /// Modify this occurrence and all future occurrences (splits the series).
  thisAndFollowing,

  /// Modify every occurrence in the series.
  allEvents,
}

/// A Material Design 3 dialog that asks the user how a recurring-event edit
/// should be applied: to this event only, this and following, or all events.
///
/// Returns the selected [RecurrenceEditScope], or `null` if cancelled.
///
/// Usage:
/// ```dart
/// final scope = await RecurrenceEditScopeDialog.show(context);
/// if (scope != null) { /* apply edit with chosen scope */ }
/// ```
class RecurrenceEditScopeDialog extends StatelessWidget {
  const RecurrenceEditScopeDialog({super.key});

  /// Shows the dialog and returns the user's chosen [RecurrenceEditScope],
  /// or `null` if the dialog was dismissed or cancelled.
  static Future<RecurrenceEditScope?> show(BuildContext context) {
    return showDialog<RecurrenceEditScope>(
      context: context,
      builder: (_) => const RecurrenceEditScopeDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Edit recurring event'),
      contentPadding: const EdgeInsets.only(top: 12, bottom: 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.event, color: colorScheme.primary),
            title: const Text('This event only'),
            subtitle: const Text('Only change this occurrence'),
            onTap: () =>
                Navigator.of(context).pop(RecurrenceEditScope.thisEvent),
          ),
          ListTile(
            leading: Icon(Icons.arrow_forward, color: colorScheme.primary),
            title: const Text('This and following events'),
            subtitle: const Text('Change this and all future occurrences'),
            onTap: () => Navigator.of(context)
                .pop(RecurrenceEditScope.thisAndFollowing),
          ),
          ListTile(
            leading: Icon(Icons.repeat, color: colorScheme.primary),
            title: const Text('All events'),
            subtitle: const Text('Change every occurrence in the series'),
            onTap: () =>
                Navigator.of(context).pop(RecurrenceEditScope.allEvents),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
