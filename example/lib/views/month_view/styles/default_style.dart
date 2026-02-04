import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../widgets/day_events_bottom_sheet.dart';
import '../../../widgets/event_detail_dialog.dart';
import '../../../widgets/style_description.dart';

/// Default style - the MonthView with absolutely no customization.
///
/// This demonstrates the out-of-the-box appearance using only the
/// library's built-in defaults derived from the app's ThemeData.
///
/// Interaction pattern (tile-based):
/// - Tap event tile → opens event detail dialog
/// - Tap +N overflow indicator → opens bottom sheet with all events
/// - Tap cell elsewhere → selects/focuses the cell (no dialog)
class DefaultMonthStyle extends StatelessWidget {
  const DefaultMonthStyle({
    super.key,
    required this.eventController,
    required this.locale,
    required this.description,
  });

  final MCalEventController eventController;
  final Locale locale;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StyleDescription(description: description),
        Expanded(
          // The MonthView with NO customization - just the required controller
          child: MCalMonthView(
            controller: eventController,
            // All other parameters use their defaults:
            // - showNavigator: defaults to false
            // - enableSwipeNavigation: defaults to true
            // - theme: automatically derived from app's ThemeData
            // - locale: uses system locale
            // - No custom builders
            showNavigator:
                true, // Enable navigator to show default navigator style
            locale: locale,
            // Tap event tile → show event detail dialog
            onEventTap: (context, details) {
              showEventDetailDialog(context, details.event, locale);
            },
            // Tap +N overflow → show bottom sheet with all events
            onOverflowTap: (context, details) {
              showDayEventsBottomSheet(
                context,
                details.date,
                details.allEvents,
                locale,
              );
            },
            // Cell tap just focuses (no dialog) - handled by default behavior
          ),
        ),
      ],
    );
  }
}
