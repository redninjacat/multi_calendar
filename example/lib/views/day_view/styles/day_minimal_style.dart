import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/utils/sample_events.dart';
import '../../../shared/widgets/event_detail_dialog.dart';
import '../../../shared/widgets/event_form_dialog.dart';

/// Minimal Day View style - bare bones, text-only, maximum whitespace.
///
/// Features:
/// - Very subtle or hidden gridlines
/// - Minimal color palette, reduced visual noise
/// - Clean, spacious layout
/// - Business hours 8–18, 30-minute gridlines (fewer lines)
/// - Full CRUD: double-tap to create, tap event to edit/delete, Cmd+N/E/D
class DayMinimalStyle extends StatefulWidget {
  const DayMinimalStyle({
    super.key,
    required this.eventController,
    required this.locale,
    required this.isDarkMode,
    this.startHour = 8,
    this.endHour = 18,
    this.gridlineInterval = const Duration(minutes: 30),
  });

  final MCalEventController eventController;
  final Locale locale;
  final bool isDarkMode;
  final int startHour;
  final int endHour;
  final Duration gridlineInterval;

  @override
  State<DayMinimalStyle> createState() => _DayMinimalStyleState();
}

class _DayMinimalStyleState extends State<DayMinimalStyle>
    with EventCrudHelper<DayMinimalStyle> {
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
        allDayEventBackgroundColor:
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        allDayEventTextStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface.withValues(alpha: 0.8),
        ),
        allDayEventBorderColor: Colors.transparent,
        allDayEventBorderWidth: 0.0,
        ignoreEventColors: false,
        eventTileBackgroundColor:
            colorScheme.primaryContainer.withValues(alpha: 0.6),
        eventTileTextStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
        eventTileCornerRadius: 2.0,
        dayTheme: MCalDayThemeData(
          hourGridlineColor: colorScheme.outline.withValues(alpha: 0.08),
          hourGridlineWidth: 0.5,
          majorGridlineColor: colorScheme.outline.withValues(alpha: 0.04),
          majorGridlineWidth: 0.5,
          minorGridlineColor: Colors.transparent,
          minorGridlineWidth: 0.0,
          currentTimeIndicatorColor: colorScheme.primary.withValues(alpha: 0.6),
          currentTimeIndicatorWidth: 1.5,
          timeLegendBackgroundColor: Colors.transparent,
          timeLegendTextStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          timedEventBorderRadius: 2.0,
          timedEventPadding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 2,
          ),
          timedEventMinHeight: 20.0,
          dayHeaderDayOfWeekStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          dayHeaderDateStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
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
