import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../utils/event_colors.dart';
import 'event_detail_dialog.dart';

/// Shows a bottom sheet with events for a specific day.
/// 
/// Tapping an event in the list will close the bottom sheet and open
/// the event detail dialog.
/// 
/// [uniformEventColor] - If provided, all events will use this color instead
/// of their individual colors. Useful for minimal/monochrome styles.
void showDayEventsBottomSheet(
  BuildContext context,
  DateTime date,
  List<MCalCalendarEvent> events,
  Locale locale, {
  Color? uniformEventColor,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final dateFormat = DateFormat.yMMMMd(locale.toString());

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withAlpha(100),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          dateFormat.format(date),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        '${events.length} event${events.length == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Hint text
                if (events.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Tap an event to see details',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withAlpha(150),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                // Event list
                Expanded(
                  child: events.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 48,
                                color: colorScheme.onSurfaceVariant.withAlpha(100),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No events',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            final isAllDay = event.isAllDay;
                            final timeFormat = DateFormat.jm(locale.toString());
                            
                            // Use uniform color if provided, otherwise event.color, then fallback
                            final eventColor = uniformEventColor ?? 
                                event.color ?? 
                                getEventColor(event.id);
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                onTap: () {
                                  // Close bottom sheet first, then show dialog
                                  Navigator.of(sheetContext).pop();
                                  showEventDetailDialog(
                                    context, 
                                    event, 
                                    locale,
                                    colorOverride: uniformEventColor,
                                  );
                                },
                                leading: Container(
                                  width: 4,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: eventColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                title: Text(event.title),
                                subtitle: Text(
                                  isAllDay
                                      ? 'All day'
                                      : '${timeFormat.format(event.start)} - ${timeFormat.format(event.end)}',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
