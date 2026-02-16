import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../shared/widgets/day_events_bottom_sheet.dart';
import '../../../shared/widgets/event_detail_dialog.dart';
import '../../../shared/widgets/style_description.dart';

/// Default style - the MonthView with absolutely no customization.
///
/// This demonstrates the out-of-the-box appearance using only the
/// library's built-in defaults derived from the app's ThemeData.
///
/// The ONLY customization is the two basic interaction handlers:
/// - Tap event tile → opens event detail dialog
/// - Tap +N overflow indicator → opens bottom sheet with all events
///
/// Everything else (theme, builders, animations, gestures) uses
/// pure library defaults with no configuration.
class MonthDefaultStyle extends StatelessWidget {
  const MonthDefaultStyle({
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
          // and two basic interaction handlers
          child: MCalMonthView(
            controller: eventController,
            // All widget parameters use their defaults:
            // - showNavigator: defaults to false
            // - enableSwipeNavigation: defaults to true
            // - enableDragToMove: defaults to false
            // - enableDragToResize: defaults to false
            // - firstDayOfWeek: defaults to locale-based
            // - theme: automatically derived from app's ThemeData
            // - locale: uses system locale
            // - No custom builders
            // - No animation configuration
            // - No additional gesture handlers
            
            showNavigator: true, // Enable navigator to demonstrate default style
            locale: locale,
            
            // Basic interaction handlers (the ONLY customization):
            
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
            
            // Cell tap just focuses the cell (default behavior - no handler needed)
            // All other gestures use default behavior
          ),
        ),
      ],
    );
  }
}
