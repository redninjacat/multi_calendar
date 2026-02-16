import 'package:flutter/material.dart';
import 'package:multi_calendar/multi_calendar.dart';

import '../../../shared/utils/sample_events.dart';
import '../../../shared/widgets/event_detail_dialog.dart';

/// Default Day View style - completely bare-bones with zero customization.
///
/// This style demonstrates the Day View with pure library defaults:
/// - No custom MCalThemeData
/// - No custom builders
/// - No drag handlers (drag functionality still enabled by widget params)
/// - ONLY onEventTap handler to show event details
///
/// The purpose is to showcase the calendar with zero styling effort,
/// letting developers see the out-of-the-box appearance and behavior.
class DayDefaultStyle extends StatefulWidget {
  const DayDefaultStyle({
    super.key,
    required this.eventController,
    required this.locale,
  });

  final MCalEventController eventController;
  final Locale locale;

  @override
  State<DayDefaultStyle> createState() => _DayDefaultStyleState();
}

class _DayDefaultStyleState extends State<DayDefaultStyle> {
  @override
  void initState() {
    super.initState();
    _loadSampleEvents();
  }

  void _loadSampleEvents() {
    // Load basic sample events for the default style
    final events = createDayViewSampleEvents(widget.eventController.displayDate);
    widget.eventController.addEvents(events);
  }

  @override
  Widget build(BuildContext context) {
    // Pure library defaults - no MCalTheme wrapper, no custom styling
    // Must provide bounded constraints using SizedBox.expand()
    return SizedBox.expand(
      child: MCalDayView(
        controller: widget.eventController,
        locale: widget.locale,
        // Only handle event tap to show details - no editing, no drag handlers
        onEventTap: (context, details) {
          showEventDetailDialog(
            context,
            details.event,
            widget.locale,
          );
        },
      ),
    );
  }
}
