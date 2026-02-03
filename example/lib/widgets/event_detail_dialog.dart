import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../utils/event_colors.dart';

/// Shows a dialog with details for a specific event.
/// 
/// [colorOverride] - If provided, uses this color for the header instead of
/// the event's color. Useful for minimal/monochrome styles.
void showEventDetailDialog(
  BuildContext context,
  MCalCalendarEvent event,
  Locale locale, {
  Color? colorOverride,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  // Use override color if provided, otherwise event.color, then fallback
  final eventColor = colorOverride ?? event.color ?? getEventColor(event.id);
  final dateFormat = DateFormat.yMMMMd(locale.toString());
  final timeFormat = DateFormat.jm(locale.toString());

  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Colored header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: eventColor,
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
                        event.isAllDay ? Icons.wb_sunny : Icons.event,
                        color: Colors.white,
                        size: 24,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Event details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and time
                  _buildDetailRow(
                    context,
                    Icons.calendar_today,
                    event.isAllDay
                        ? _formatAllDayDateRange(event, dateFormat)
                        : dateFormat.format(event.start),
                    colorScheme,
                  ),
                  if (!event.isAllDay) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      Icons.access_time,
                      '${timeFormat.format(event.start)} - ${timeFormat.format(event.end)}',
                      colorScheme,
                    ),
                  ],
                  // Duration
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    Icons.timelapse,
                    _formatDuration(event),
                    colorScheme,
                  ),
                  // Comment if available
                  if (event.comment != null && event.comment!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.comment!,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                  // IDs for debugging
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Event ID: ${event.id}',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: colorScheme.onSurfaceVariant.withAlpha(150),
                    ),
                  ),
                  if (event.externalId != null)
                    Text(
                      'External ID: ${event.externalId}',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: colorScheme.onSurfaceVariant.withAlpha(150),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildDetailRow(
  BuildContext context,
  IconData icon,
  String text,
  ColorScheme colorScheme,
) {
  return Row(
    children: [
      Icon(
        icon,
        size: 20,
        color: colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    ],
  );
}

String _formatAllDayDateRange(MCalCalendarEvent event, DateFormat dateFormat) {
  final startDate = DateTime(event.start.year, event.start.month, event.start.day);
  final endDate = DateTime(event.end.year, event.end.month, event.end.day);
  
  if (startDate == endDate) {
    return '${dateFormat.format(event.start)} (All day)';
  } else {
    return '${dateFormat.format(event.start)} - ${dateFormat.format(event.end)} (All day)';
  }
}

String _formatDuration(MCalCalendarEvent event) {
  if (event.isAllDay) {
    final days = event.end.difference(event.start).inDays + 1;
    return days == 1 ? 'All day' : '$days days';
  }
  
  final duration = event.end.difference(event.start);
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  
  if (hours > 0 && minutes > 0) {
    return '$hours hr $minutes min';
  } else if (hours > 0) {
    return '$hours hr';
  } else {
    return '$minutes min';
  }
}
