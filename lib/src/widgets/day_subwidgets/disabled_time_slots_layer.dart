import 'package:flutter/material.dart';

import '../../utils/date_utils.dart';
import '../mcal_callback_details.dart';

/// Widget for rendering disabled time slots with reduced opacity.
///
/// Displays a semi-transparent overlay (0.5 opacity) over time slots that
/// return false from [interactivityCallback]. This provides visual
/// feedback to users about which time slots are non-interactive.
///
/// The overlay is positioned between gridlines and events in the layer stack.
class DisabledTimeSlotsLayer extends StatelessWidget {
  const DisabledTimeSlotsLayer({
    super.key,
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    required this.timeSlotDuration,
    required this.displayDate,
    required this.interactivityCallback,
  });

  final int startHour;
  final int endHour;
  final double hourHeight;
  final Duration timeSlotDuration;
  final DateTime displayDate;
  final bool Function(BuildContext, MCalTimeSlotInteractivityDetails)
  interactivityCallback;

  @override
  Widget build(BuildContext context) {
    final disabledSlots = <Widget>[];
    final slotMinutes = timeSlotDuration.inMinutes;

    for (int hour = startHour; hour <= endHour; hour++) {
      for (int minute = 0; minute < 60; minute += slotMinutes) {
        if (hour == endHour && minute > 0) break;

        final slotStartTime = DateTime(
          displayDate.year,
          displayDate.month,
          displayDate.day,
          hour,
          minute,
        );
        final slotEndTime = slotStartTime.add(timeSlotDuration);

        final details = MCalTimeSlotInteractivityDetails(
          date: dateOnly(displayDate),
          hour: hour,
          minute: minute,
          startTime: slotStartTime,
          endTime: slotEndTime,
        );

        final isInteractive = interactivityCallback(context, details);

        if (!isInteractive) {
          final topOffset = _timeToOffset(slotStartTime);
          final slotHeight = (slotMinutes / 60.0) * hourHeight;

          disabledSlots.add(
            Positioned(
              top: topOffset,
              left: 0,
              right: 0,
              height: slotHeight,
              child: IgnorePointer(
                child: Container(color: Colors.grey.withValues(alpha: 0.3)),
              ),
            ),
          );
        }
      }
    }

    if (disabledSlots.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(children: disabledSlots);
  }

  double _timeToOffset(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final totalMinutes = (hour - startHour) * 60 + minute;
    return (totalMinutes / 60.0) * hourHeight;
  }
}
