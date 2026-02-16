import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../widgets/event_detail_dialog.dart';
import '../../../widgets/day_view_crud_helper.dart';
import '../../../widgets/style_description.dart';

/// Classic Day View style - traditional grid with borders and minimal styling.
///
/// Features:
/// - Square corners on event tiles
/// - Visible gridlines at hour and interval marks
/// - Uniform event colors (ignoreEventColors)
/// - Business hours 8–18, 15-minute gridlines
/// - Full CRUD: double-tap to create, tap event to edit/delete, Cmd+N/E/D
class ClassicDayStyle extends StatefulWidget {
  const ClassicDayStyle({
    super.key,
    required this.eventController,
    required this.locale,
    required this.isDarkMode,
    required this.description,
    this.startHour = 8,
    this.endHour = 18,
    this.gridlineInterval = const Duration(minutes: 15),
  });

  final MCalEventController eventController;
  final Locale locale;
  final bool isDarkMode;
  final String description;
  final int startHour;
  final int endHour;
  final Duration gridlineInterval;

  @override
  State<ClassicDayStyle> createState() => _ClassicDayStyleState();
}

class _ClassicDayStyleState extends State<ClassicDayStyle>
    with DayViewCrudHelper<ClassicDayStyle> {
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
                fontSize: 11,
                fontFamily: 'serif',
                color: colorScheme.onPrimaryContainer,
              ),
              allDayEventBorderColor: colorScheme.outlineVariant,
              allDayEventBorderWidth: 0.5,
              ignoreEventColors: true,
              eventTileBackgroundColor: colorScheme.primaryContainer,
              eventTileTextStyle: TextStyle(
                fontSize: 11,
                fontFamily: 'serif',
                color: colorScheme.onPrimaryContainer,
              ),
              eventTileCornerRadius: 0.0,
              dayTheme: MCalDayThemeData(
                hourGridlineColor: colorScheme.outline,
                hourGridlineWidth: 1.0,
                majorGridlineColor: colorScheme.outline.withValues(alpha: 0.5),
                majorGridlineWidth: 1.0,
                minorGridlineColor: colorScheme.outline.withValues(alpha: 0.25),
                minorGridlineWidth: 0.5,
                currentTimeIndicatorColor: colorScheme.primary,
                currentTimeIndicatorWidth: 2.0,
                timeLegendBackgroundColor: colorScheme.surfaceContainerHighest,
                timeLegendTextStyle: TextStyle(
                  fontSize: 12,
                  fontFamily: 'serif',
                  color: colorScheme.onSurfaceVariant,
                ),
                timedEventBorderRadius: 0.0,
                timedEventPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                timedEventMinHeight: 24.0,
                dayHeaderDayOfWeekStyle: TextStyle(
                  fontSize: 14,
                  fontFamily: 'serif',
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
                dayHeaderDateStyle: TextStyle(
                  fontSize: 24,
                  fontFamily: 'serif',
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
              timeSlotDuration: widget.gridlineInterval,
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
