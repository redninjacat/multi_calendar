import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/utils/sample_events.dart';
import '../../../shared/widgets/event_detail_dialog.dart';
import '../../../shared/widgets/event_form_dialog.dart';

/// Colorful Day View style - vibrant gradients and bold colors.
///
/// Features:
/// - Gradient background
/// - Bold event colors with rounded pills
/// - Full 24-hour range, 15-minute gridlines
/// - Playful, creative aesthetic
/// - Full CRUD: double-tap to create, tap event to edit/delete, Cmd+N/E/D
class DayColorfulStyle extends StatefulWidget {
  const DayColorfulStyle({
    super.key,
    required this.eventController,
    required this.locale,
    required this.isDarkMode,
    this.startHour = 0,
    this.endHour = 24,
    this.gridlineInterval = const Duration(minutes: 15),
  });

  final MCalEventController eventController;
  final Locale locale;
  final bool isDarkMode;
  final int startHour;
  final int endHour;
  final Duration gridlineInterval;

  static const gradientStart = Color(0xFF667EEA);
  static const gradientEnd = Color(0xFF764BA2);

  @override
  State<DayColorfulStyle> createState() => _DayColorfulStyleState();
}

class _DayColorfulStyleState extends State<DayColorfulStyle>
    with EventCrudHelper<DayColorfulStyle> {
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
    return SizedBox.expand(
      child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isDarkMode
              ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
              : [
                  DayColorfulStyle.gradientStart.withValues(alpha: 0.08),
                  DayColorfulStyle.gradientEnd.withValues(alpha: 0.08),
                ],
        ),
      ),
      child: MCalTheme(
        data: MCalThemeData(
          allDayEventBackgroundColor: DayColorfulStyle.gradientStart,
          allDayEventTextStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          allDayEventBorderColor: DayColorfulStyle.gradientEnd.withValues(alpha: 0.5),
          allDayEventBorderWidth: 1.0,
          ignoreEventColors: false,
          dayTheme: MCalDayThemeData(
            hourGridlineColor: (widget.isDarkMode ? Colors.white : DayColorfulStyle.gradientStart)
                .withValues(alpha: 0.2),
            hourGridlineWidth: 1.0,
            majorGridlineColor: (widget.isDarkMode ? Colors.white : DayColorfulStyle.gradientStart)
                .withValues(alpha: 0.12),
            majorGridlineWidth: 1.0,
            minorGridlineColor: (widget.isDarkMode ? Colors.white : DayColorfulStyle.gradientStart)
                .withValues(alpha: 0.06),
            minorGridlineWidth: 0.5,
            currentTimeIndicatorColor: DayColorfulStyle.gradientEnd,
            currentTimeIndicatorWidth: 3.0,
            currentTimeIndicatorDotRadius: 8.0,
            timeLegendBackgroundColor: (widget.isDarkMode ? Colors.white : DayColorfulStyle.gradientStart)
                .withValues(alpha: 0.1),
            timeLegendTextStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode ? Colors.white70 : DayColorfulStyle.gradientStart,
            ),
            timedEventBorderRadius: 12.0,
            timedEventPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            timedEventMinHeight: 32.0,
            dayHeaderDayOfWeekStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode ? Colors.white70 : DayColorfulStyle.gradientStart,
            ),
            dayHeaderDateStyle: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [DayColorfulStyle.gradientStart, DayColorfulStyle.gradientEnd],
                ).createShader(const Rect.fromLTWH(0, 0, 100, 50)),
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
      ),
    );
  }
}
