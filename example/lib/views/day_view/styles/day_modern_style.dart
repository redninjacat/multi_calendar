import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/utils/sample_events.dart';
import '../../../shared/widgets/event_detail_dialog.dart';
import '../../../shared/widgets/event_form_dialog.dart';

/// Modern Day View style - clean, rounded, contemporary design.
///
/// Features:
/// - Rounded corners on event tiles
/// - Subtle gridlines
/// - Colorful event indicators (respects event colors)
/// - Extended hours 7–21, 30-minute major gridlines
/// - Full CRUD: double-tap to create, tap event to edit/delete, Cmd+N/E/D
class DayModernStyle extends StatefulWidget {
  const DayModernStyle({
    super.key,
    required this.eventController,
    required this.locale,
    required this.isDarkMode,
    this.startHour = 7,
    this.endHour = 21,
    this.gridlineInterval = const Duration(minutes: 30),
  });

  final MCalEventController eventController;
  final Locale locale;
  final bool isDarkMode;
  final int startHour;
  final int endHour;
  final Duration gridlineInterval;

  @override
  State<DayModernStyle> createState() => _DayModernStyleState();
}

class _DayModernStyleState extends State<DayModernStyle>
    with EventCrudHelper<DayModernStyle> {
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
