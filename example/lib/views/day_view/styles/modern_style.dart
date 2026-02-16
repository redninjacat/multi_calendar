import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../widgets/event_detail_dialog.dart';
import '../../../widgets/day_view_crud_helper.dart';
import '../../../widgets/style_description.dart';

/// Modern Day View style - clean, rounded, contemporary design.
///
/// Features:
/// - Rounded corners on event tiles
/// - Subtle gridlines
/// - Colorful event indicators (respects event colors)
/// - Extended hours 7–21, 30-minute major gridlines
/// - Full CRUD: double-tap to create, tap event to edit/delete, Cmd+N/E/D
class ModernDayStyle extends StatefulWidget {
  const ModernDayStyle({
    super.key,
    required this.eventController,
    required this.locale,
    required this.isDarkMode,
    required this.description,
    this.startHour = 7,
    this.endHour = 21,
    this.gridlineInterval = const Duration(minutes: 30),
  });

  final MCalEventController eventController;
  final Locale locale;
  final bool isDarkMode;
  final String description;
  final int startHour;
  final int endHour;
  final Duration gridlineInterval;

  @override
  State<ModernDayStyle> createState() => _ModernDayStyleState();
}

class _ModernDayStyleState extends State<ModernDayStyle>
    with DayViewCrudHelper<ModernDayStyle> {
  @override
  MCalEventController get eventController => widget.eventController;

  @override
  Locale get locale => widget.locale;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        StyleDescription(description: widget.description),
        Expanded(
          child: MCalTheme(
            data: MCalThemeData(
              allDayEventBackgroundColor: colorScheme.primaryContainer,
              allDayEventTextStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.onPrimaryContainer,
              ),
              ignoreEventColors: false,
              dayTheme: MCalDayThemeData(
                hourGridlineColor: colorScheme.outline.withValues(alpha: 0.15),
                hourGridlineWidth: 1.0,
                majorGridlineColor: colorScheme.outline.withValues(alpha: 0.1),
                majorGridlineWidth: 1.0,
                minorGridlineColor: colorScheme.outline.withValues(alpha: 0.05),
                minorGridlineWidth: 0.5,
                currentTimeIndicatorColor: colorScheme.primary,
                currentTimeIndicatorWidth: 3.0,
                currentTimeIndicatorDotRadius: 8.0,
                timeLegendBackgroundColor: colorScheme.surface,
                timeLegendTextStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
                timedEventBorderRadius: 8.0,
                timedEventPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                timedEventMinHeight: 28.0,
                dayHeaderDayOfWeekStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
                dayHeaderDateStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            child: MCalDayView(
              controller: widget.eventController,
              startHour: widget.startHour,
              endHour: widget.endHour,
              gridlineInterval: widget.gridlineInterval,
              timeSlotDuration: const Duration(minutes: 15),
              enableDragToMove: true,
              enableDragToResize: true,
              snapToTimeSlots: true,
              showNavigator: true,
              showCurrentTimeIndicator: true,
              locale: widget.locale,
              onEventTap: (context, details) {
                showEventDetailDialog(
                  context,
                  details.event,
                  widget.locale,
                  onEdit: () => handleEditEvent(details.event),
                  onDelete: () => handleDeleteEvent(details.event),
                );
              },
              onEventDropped: (details) {
                if (mounted) {
                  final t = details.newStartDate;
                  showCrudSnackBar(
                    'Moved: ${details.event.title} to '
                    '${t.hour}:${t.minute.toString().padLeft(2, '0')}',
                  );
                }
              },
              onEventResized: (details) {
                if (mounted) {
                  showCrudSnackBar(
                    'Resized: ${details.event.title} to '
                    '${details.newEndDate.difference(details.newStartDate).inMinutes} min',
                  );
                }
              },
              onEmptySpaceDoubleTap: (time) => handleCreateEvent(time),
              onCreateEventRequested: handleCreateEventAtDefaultTime,
              onEditEventRequested: (event) => handleEditEvent(event),
              onDeleteEventRequested: (event) => handleDeleteEvent(event),
            ),
          ),
        ),
      ],
    );
  }
}
