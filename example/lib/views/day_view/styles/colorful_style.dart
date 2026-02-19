import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../widgets/event_detail_dialog.dart';
import '../../../widgets/day_view_crud_helper.dart';
import '../../../widgets/style_description.dart';

/// Colorful Day View style - vibrant gradients and bold colors.
///
/// Features:
/// - Gradient background
/// - Bold event colors with rounded pills
/// - Full 24-hour range, 15-minute gridlines
/// - Playful, creative aesthetic
/// - Full CRUD: double-tap to create, tap event to edit/delete, Cmd+N/E/D
class ColorfulDayStyle extends StatefulWidget {
  const ColorfulDayStyle({
    super.key,
    required this.eventController,
    required this.locale,
    required this.isDarkMode,
    required this.description,
    this.startHour = 0,
    this.endHour = 24,
    this.gridlineInterval = const Duration(minutes: 15),
  });

  final MCalEventController eventController;
  final Locale locale;
  final bool isDarkMode;
  final String description;
  final int startHour;
  final int endHour;
  final Duration gridlineInterval;

  static const gradientStart = Color(0xFF667EEA);
  static const gradientEnd = Color(0xFF764BA2);

  @override
  State<ColorfulDayStyle> createState() => _ColorfulDayStyleState();
}

class _ColorfulDayStyleState extends State<ColorfulDayStyle>
    with DayViewCrudHelper<ColorfulDayStyle> {
  @override
  MCalEventController get eventController => widget.eventController;

  @override
  Locale get locale => widget.locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StyleDescription(description: widget.description),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isDarkMode
                    ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                    : [
                        ColorfulDayStyle.gradientStart.withValues(alpha: 0.08),
                        ColorfulDayStyle.gradientEnd.withValues(alpha: 0.08),
                      ],
              ),
            ),
            child: MCalTheme(
              data: MCalThemeData(
                allDayEventBackgroundColor: ColorfulDayStyle.gradientStart,
                allDayEventTextStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                allDayEventBorderColor: ColorfulDayStyle.gradientEnd.withValues(alpha: 0.5),
                allDayEventBorderWidth: 1.0,
                ignoreEventColors: false,
                dayTheme: MCalDayThemeData(
                  hourGridlineColor: (widget.isDarkMode ? Colors.white : ColorfulDayStyle.gradientStart)
                      .withValues(alpha: 0.2),
                  hourGridlineWidth: 1.0,
                  majorGridlineColor: (widget.isDarkMode ? Colors.white : ColorfulDayStyle.gradientStart)
                      .withValues(alpha: 0.12),
                  majorGridlineWidth: 1.0,
                  minorGridlineColor: (widget.isDarkMode ? Colors.white : ColorfulDayStyle.gradientStart)
                      .withValues(alpha: 0.06),
                  minorGridlineWidth: 0.5,
                  currentTimeIndicatorColor: ColorfulDayStyle.gradientEnd,
                  currentTimeIndicatorWidth: 3.0,
                  currentTimeIndicatorDotRadius: 8.0,
                  timeLegendBackgroundColor: (widget.isDarkMode ? Colors.white : ColorfulDayStyle.gradientStart)
                      .withValues(alpha: 0.1),
                  timeLegendTextStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.isDarkMode ? Colors.white70 : ColorfulDayStyle.gradientStart,
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
                    color: widget.isDarkMode ? Colors.white70 : ColorfulDayStyle.gradientStart,
                  ),
                  dayHeaderDateStyle: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [ColorfulDayStyle.gradientStart, ColorfulDayStyle.gradientEnd],
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
                    showCrudSnackBar(
                      'Moved: ${details.event.title} to '
                      '${t.hour}:${t.minute.toString().padLeft(2, '0')}',
                    );
                  }
                  return true;
                },
                onEventResized: (context, details) {
                  if (mounted) {
                    showCrudSnackBar(
                      'Resized: ${details.event.title} to '
                      '${details.newEndDate.difference(details.newStartDate).inMinutes} min',
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
        ),
      ],
    );
  }
}
