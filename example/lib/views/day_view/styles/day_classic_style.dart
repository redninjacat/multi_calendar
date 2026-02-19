import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/utils/sample_events.dart';
import '../../../shared/widgets/event_detail_dialog.dart';
import '../../../shared/widgets/event_form_dialog.dart';

/// Classic Day View style - traditional grid with borders and minimal styling.
///
/// Features:
/// - Square corners on event tiles
/// - Visible gridlines at hour and interval marks
/// - Uniform event colors (ignoreEventColors)
/// - Business hours 8–18, 15-minute gridlines
/// - Full CRUD: double-tap to create, tap event to edit/delete, Cmd+N/E/D
class DayClassicStyle extends StatefulWidget {
  const DayClassicStyle({
    super.key,
    required this.eventController,
    required this.locale,
    required this.isDarkMode,
    this.startHour = 8,
    this.endHour = 18,
    this.gridlineInterval = const Duration(minutes: 15),
  });

  final MCalEventController eventController;
  final Locale locale;
  final bool isDarkMode;
  final int startHour;
  final int endHour;
  final Duration gridlineInterval;

  @override
  State<DayClassicStyle> createState() => _DayClassicStyleState();
}

class _DayClassicStyleState extends State<DayClassicStyle>
    with EventCrudHelper<DayClassicStyle> {
  @override
  MCalEventController get eventController => widget.eventController;

  @override
  Locale get locale => widget.locale;

  @override
  void initState() {
    super.initState();
    _loadSampleEvents();
  }

  void _loadSampleEvents() {
    final events = createDayViewSampleEvents(widget.eventController.displayDate);
    widget.eventController.addEvents(events);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox.expand(
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
        onEventDropped: (context, details) {
          if (mounted) {
            final t = details.newStartDate;
            final l10n = AppLocalizations.of(context)!;
            showCrudSnackBar(
              l10n.snackbarEventDropped(
                details.event.title,
                '${t.hour}:${t.minute.toString().padLeft(2, '0')}',
              ),
            );
          }
          return true;
        },
        onEventResized: (context, details) {
          if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            showCrudSnackBar(
              l10n.snackbarEventResized(
                details.event.title,
                '${details.newEndDate.difference(details.newStartDate).inMinutes}',
              ),
            );
          }
          return true;
        },
        onTimeSlotDoubleTap: (context, slotContext) {
          if (!slotContext.isAllDayArea) {
            handleCreateEvent(DateTime(slotContext.displayDate.year, slotContext.displayDate.month, slotContext.displayDate.day, slotContext.hour ?? 0, slotContext.minute ?? 0));
          }
        },
        onCreateEventRequested: handleCreateEventAtDefaultTime,
        onEditEventRequested: (event) => handleEditEvent(event),
        onDeleteEventRequested: (event) => handleDeleteEvent(event),
      ),
      ),
    );
  }
}
