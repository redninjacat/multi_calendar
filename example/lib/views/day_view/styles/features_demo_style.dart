import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../widgets/event_detail_dialog.dart';
import '../../../widgets/day_view_crud_helper.dart';
import '../../../widgets/style_description.dart';

/// Features Demo Day View - comprehensive showcase of ALL Day View capabilities.
///
/// Demonstrates:
/// - **Special time regions**: Lunch break (12–13), non-working hours (18–24)
/// - **Blocked time slots**: After-hours region blocks event drops
/// - **Custom time region builder**: Styled lunch and blocked zones
/// - **Drag-drop**: Move events; drops to blocked regions are rejected
/// - **Resize**: Resize from event edges
/// - **Snap-to-time**: 15-minute snapping
/// - **Keyboard navigation**: Tab, arrows, Enter, Cmd+N/E/D
/// - **Full CRUD**: Double-tap create, tap edit/delete
/// - **All-day and timed events**: Both types with type conversion on drag
class FeaturesDemoDayStyle extends StatefulWidget {
  const FeaturesDemoDayStyle({
    super.key,
    required this.eventController,
    required this.locale,
    required this.isDarkMode,
    required this.description,
  });

  final MCalEventController eventController;
  final Locale locale;
  final bool isDarkMode;
  final String description;

  @override
  State<FeaturesDemoDayStyle> createState() => _FeaturesDemoDayStyleState();
}

class _FeaturesDemoDayStyleState extends State<FeaturesDemoDayStyle>
    with DayViewCrudHelper<FeaturesDemoDayStyle> {
  @override
  MCalEventController get eventController => widget.eventController;

  @override
  Locale get locale => widget.locale;

  /// Build special time regions for the display date.
  /// Uses recurrence so regions apply when user navigates to other days.
  List<MCalTimeRegion> _buildTimeRegions() {
    final d = eventController.displayDate;
    return [
      // Lunch break 12:00–13:00 - visual only, allows drops
      MCalTimeRegion(
        id: 'lunch',
        startTime: DateTime(d.year, d.month, d.day, 12, 0),
        endTime: DateTime(d.year, d.month, d.day, 13, 0),
        color: Colors.amber.withValues(alpha: 0.25),
        text: 'Lunch Break',
        icon: Icons.restaurant,
        blockInteraction: false,
      ),
      // After-hours 18:00–24:00 - blocked, rejects drops
      MCalTimeRegion(
        id: 'after-hours',
        startTime: DateTime(d.year, d.month, d.day, 18, 0),
        endTime: DateTime(d.year, d.month, d.day, 24, 0),
        color: Colors.grey.withValues(alpha: 0.4),
        text: 'After Hours (blocked)',
        icon: Icons.block,
        blockInteraction: true,
      ),
      // Morning focus zone 9:00–10:00 - blocked, no-meeting zone
      MCalTimeRegion(
        id: 'focus-time',
        startTime: DateTime(d.year, d.month, d.day, 9, 0),
        endTime: DateTime(d.year, d.month, d.day, 10, 0),
        color: Colors.blue.withValues(alpha: 0.15),
        text: 'Focus Time (no meetings)',
        icon: Icons.psychology,
        blockInteraction: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: eventController,
      builder: (context, _) {
        final regions = _buildTimeRegions();
        return Column(
          children: [
            StyleDescription(description: widget.description),
            // Keyboard shortcuts hint bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              child: Wrap(
                spacing: 10,
                runSpacing: 2,
                alignment: WrapAlignment.center,
                children: [
                  _shortcutChip('Tab', 'Focus events', colorScheme),
                  _shortcutChip('↑↓', 'Move event', colorScheme),
                  _shortcutChip('R', 'Resize mode', colorScheme),
                  _shortcutChip('Cmd+N', 'Create', colorScheme),
                  _shortcutChip('Cmd+E', 'Edit', colorScheme),
                  _shortcutChip('Cmd+D', 'Delete', colorScheme),
                  _shortcutChip('Double-tap', 'Create at slot', colorScheme),
                ],
              ),
            ),
            Expanded(
              child: MCalTheme(
                data: MCalThemeData(
                  hourGridlineColor: colorScheme.outline.withValues(alpha: 0.2),
                  hourGridlineWidth: 1.0,
                  majorGridlineColor: colorScheme.outline.withValues(alpha: 0.15),
                  majorGridlineWidth: 1.0,
                  minorGridlineColor: colorScheme.outline.withValues(alpha: 0.08),
                  minorGridlineWidth: 0.5,
                  currentTimeIndicatorColor: colorScheme.primary,
                  currentTimeIndicatorWidth: 2.5,
                  timeLegendBackgroundColor: colorScheme.surfaceContainerHighest,
                  timeLegendTextStyle: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  blockedTimeRegionColor: colorScheme.error.withValues(alpha: 0.2),
                  specialTimeRegionColor: colorScheme.primary.withValues(alpha: 0.1),
                ),
                child: MCalDayView(
                  controller: widget.eventController,
                  startHour: 6,
                  endHour: 24,
                  gridlineInterval: const Duration(minutes: 15),
                  timeSlotDuration: const Duration(minutes: 15),
                  enableDragToMove: true,
                  enableDragToResize: true,
                  snapToTimeSlots: true,
                  showNavigator: true,
                  showCurrentTimeIndicator: true,
                  enableKeyboardNavigation: true,
                  specialTimeRegions: regions,
                  timeRegionBuilder: (context, ctx) => _buildTimeRegion(ctx),
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
      },
    );
  }

  Widget _buildTimeRegion(MCalTimeRegionContext ctx) {
    final colorScheme = Theme.of(context).colorScheme;
    final region = ctx.region;
    final isBlocked = region.blockInteraction;
    final bgColor = region.color ??
        (isBlocked
            ? (colorScheme.error.withValues(alpha: 0.15))
            : colorScheme.primaryContainer.withValues(alpha: 0.2));

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          left: BorderSide(
            color: isBlocked
                ? colorScheme.error.withValues(alpha: 0.5)
                : colorScheme.primary.withValues(alpha: 0.4),
            width: 3,
          ),
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (region.icon != null)
              Icon(
                region.icon,
                size: 16,
                color: isBlocked
                    ? colorScheme.error.withValues(alpha: 0.8)
                    : colorScheme.primary.withValues(alpha: 0.8),
              ),
            if (region.icon != null) const SizedBox(width: 6),
            if (region.text != null && region.text!.isNotEmpty)
              Text(
                region.text!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isBlocked
                      ? colorScheme.error.withValues(alpha: 0.9)
                      : colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _shortcutChip(String key, String action, ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            key,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          action,
          style: TextStyle(
            fontSize: 10,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
