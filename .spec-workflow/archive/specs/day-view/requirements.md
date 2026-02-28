# Requirements Document: Day View

## Introduction

This specification defines the implementation of `MCalDayView` - the second major calendar view widget for the multi_calendar Flutter package. MCalDayView provides a vertical timeline display of a single day's events, showing both all-day events in a dedicated header section and timed events positioned proportionally to their start/end times.

The day view complements the existing MCalMonthView by providing detailed time-of-day visibility, overlap handling for concurrent events, and precise time-based drag-and-drop interactions. It follows all established patterns from MCalMonthView for consistency, including extensive customization via builders, comprehensive theme support, full accessibility features, and RTL layout support.

**Phase 0 - Code Organization**: Before implementing the remaining Day View features, Phase 0 addresses code organization by clearly separating month-view-specific components from shared components. This organizational phase renames month-view-specific files and classes (e.g., `MCalDefaultWeekLayoutBuilder` → `MCalMonthDefaultWeekLayoutBuilder`, `mcal_multi_day_tile.dart` → `mcal_month_multi_day_tile.dart`) to prevent confusion as Day View and future Multi-Day View are implemented. See Phase 0 tasks for details.

This implementation addresses developer needs for:
- **Detailed schedule viewing**: Hour-by-hour timeline with customizable time ranges
- **Event overlap visualization**: Column-based layout for concurrent events (like Google Calendar)
- **Time-based interactions**: Drag to change start times, resize to adjust duration, with time slot snapping
- **Complete customization**: Builder callbacks for every visual element
- **Accessibility**: Full keyboard navigation and screen reader support
- **Multi-platform support**: Optimized for mobile with desktop scaling

## Alignment with Product Vision

**From product.md:**
- **Modularity**: Day view is a separate widget (MCalDayView), allowing developers to use only what they need without monolithic dependencies
- **Flexibility**: Supports any event storage backend through the existing delegation pattern via MCalEventController
- **Standards Compliance**: Continues full RFC 5545 RRULE support for recurring events
- **Developer Experience**: API patterns mirror MCalMonthView for easy adoption
- **Customization First**: Extensive builder callbacks and theme properties
- **Performance**: Efficient rendering with viewport-based calculations, maintains 60fps with 50+ events
- **Accessibility First**: Complete keyboard navigation, screen reader semantic labels, reduced motion support
- **International Ready**: RTL support, localization via intl package, DST-safe time calculations
- **Mobile-First**: Touch-optimized with desktop enhancements (hover, precise resizing)

**From tech.md:**
- **Widget-based Architecture**: Stateful widget with controller pattern for state management
- **Flutter SDK compatibility**: Works with Flutter >=1.17.0, Dart ^3.10.4
- **Intl package integration**: Date/time formatting and localization
- **DST-safe calculations**: All time arithmetic uses `DateTime(y, m, d, h, m)` constructor pattern
- **Accessibility APIs**: Full `Semantics` widget integration
- **ChangeNotifier pattern**: Reuses existing MCalDragHandler for drag/resize state

## Requirements

### Requirement 1: Time Legend Display

**User Story:** As a calendar user, I want to see hour labels along the edge of the day view, so that I can quickly identify what time events occur without counting gridlines.

#### Acceptance Criteria

1. WHEN MCalDayView renders THEN it SHALL display a time legend column showing hour labels
2. WHEN the locale is LTR (left-to-right) THEN the time legend SHALL be positioned on the left side
3. WHEN the locale is RTL (right-to-left) THEN the time legend SHALL be positioned on the right side
4. WHEN `startHour` parameter is set THEN the time legend SHALL begin at the specified hour (0-23)
5. WHEN `endHour` parameter is set THEN the time legend SHALL end at the specified hour (0-23)
6. IF `startHour` is not provided THEN it SHALL default to 0 (midnight)
7. IF `endHour` is not provided THEN it SHALL default to 23 (11 PM)
8. WHEN rendering hour labels THEN they SHALL be formatted according to the locale's time format (12-hour vs 24-hour)
9. WHEN `timeLabelFormat` parameter is provided THEN hour labels SHALL be formatted using the specified format string
10. WHEN `timeLabelBuilder` callback is provided THEN it SHALL override default formatting and use the custom builder
11. WHEN the time legend is rendered THEN its width SHALL be configurable via `timeLegendWidth` theme property (default: 60dp)
12. WHEN the time legend background is themed THEN it SHALL respect `timeLegendBackgroundColor` and `timeLegendTextStyle` properties

### Requirement 2: Gridlines and Time Slots

**User Story:** As a calendar user, I want to see horizontal lines at hour and half-hour intervals, so that I can visually estimate event times and align new events to time boundaries.

#### Acceptance Criteria

1. WHEN the timed events area renders THEN it SHALL display horizontal gridlines at each full hour
2. WHEN `showHalfHourLines` is true (default) THEN gridlines SHALL also appear at 30-minute intervals
3. WHEN hour gridlines render THEN they SHALL use `hourGridlineColor` theme property (default: outline with 0.2 alpha)
4. WHEN half-hour gridlines render THEN they SHALL use `halfHourGridlineColor` theme property (default: outline with 0.1 alpha)
5. WHEN half-hour gridlines render THEN they SHALL be visually lighter/thinner than hour gridlines
6. WHEN `gridlineBuilder` callback is provided THEN it SHALL allow custom gridline rendering per hour/half-hour
7. WHEN calculating gridline positions THEN they SHALL be positioned based on `hourHeight` (auto-calculated or configured)
8. IF `hourHeight` is null THEN the system SHALL calculate it automatically as: `(viewport height - all-day section height) / (endHour - startHour + 1)`
9. WHEN rendering the timed events area THEN the total height SHALL be: `hourHeight × (endHour - startHour + 1)`

### Requirement 3: Day Header

**User Story:** As a calendar user, I want to see which day I'm viewing at the top of the calendar, so that I maintain context while scrolling through time slots.

#### Acceptance Criteria

1. WHEN MCalDayView renders THEN it SHALL display a day header showing the current date
2. WHEN in LTR mode THEN the day header SHALL be positioned at top-left of the events area
3. WHEN in RTL mode THEN the day header SHALL be positioned at top-right of the events area
4. WHEN the header displays by default THEN it SHALL show day-of-week and date number (e.g., "FRI 13")
5. WHEN `dateFormat` parameter is provided THEN the header SHALL format the date using the specified format string
6. WHEN `dayHeaderBuilder` callback is provided THEN it SHALL override default header rendering
7. WHEN the user taps the day header THEN `onDayHeaderTap` callback SHALL be invoked with `MCalDayHeaderContext`
8. WHEN the user long-presses the day header THEN `onDayHeaderLongPress` callback SHALL be invoked
9. WHEN the day header is themed THEN it SHALL respect relevant theme properties from MCalThemeData

### Requirement 4: All-Day Events Section with Drag and Resize

**User Story:** As a calendar user, I want all-day events displayed in a dedicated section at the top, so that they don't clutter the hourly timeline and are immediately visible, and I want to drag and resize them just like timed events.

#### Acceptance Criteria

##### Display and Layout

1. WHEN events with `isAllDay == true` exist for the displayed date THEN they SHALL render in the all-day section
2. WHEN the all-day section renders THEN it SHALL be positioned below the day header and above the timed events area
3. WHEN all-day events render THEN they SHALL be laid out horizontally (similar to month view multi-day tiles)
4. WHEN `allDaySectionMaxRows` is set (default: 3) THEN the section SHALL display at most that many rows of events
5. IF more all-day events exist than `allDaySectionMaxRows` THEN an overflow indicator SHALL be shown
6. WHEN the overflow indicator is tapped THEN `onOverflowTap` callback SHALL be invoked
7. WHEN `allDayEventTileBuilder` callback is provided THEN it SHALL be used to render all-day event tiles
8. WHEN an all-day event is tapped THEN `onEventTap` callback SHALL be invoked with `MCalEventTapDetails`
9. WHEN an all-day event is long-pressed THEN `onEventLongPress` callback SHALL be invoked
10. WHEN all-day section height is auto-calculated THEN it SHALL be: `(number of visible rows) × (tile height + spacing)` with a maximum based on `allDaySectionMaxRows`
11. IF `allDaySectionHeight` theme property is set THEN it SHALL override the auto-calculated height

##### Drag and Resize for All-Day Events

12. WHEN `enableDragToMove` is enabled for all-day events (per platform restrictions) AND the user long-presses an all-day event THEN a drag operation SHALL initiate
13. WHEN platform restrictions are evaluated for all-day events THEN they SHALL follow the same pattern as month view:
    - Enabled by default on: web, desktop (macOS, Windows, Linux), tablets (shortest side >= 600dp)
    - Disabled by default on: phones (shortest side < 600dp)
14. WHEN dragging an all-day event horizontally THEN it SHALL show a drop target preview on the target day
15. WHEN dragging an all-day event to the left/right edge THEN edge navigation SHALL trigger to move to previous/next day
16. WHEN the all-day event drag is released THEN `onEventDropped` SHALL be invoked with the new date
17. WHEN `enableDragToResize` is enabled for all-day events (per platform restrictions) AND the user drags the left edge (LTR) or right edge (RTL) THEN the start date SHALL change
18. WHEN the user drags the right edge (LTR) or left edge (RTL) THEN the end date SHALL change
19. WHEN resizing an all-day event THEN the minimum duration SHALL be 1 day
20. WHEN resizing an all-day event horizontally to the edge THEN edge navigation SHALL trigger to extend into previous/next day
21. WHEN an all-day event is resized THEN `onEventResized` SHALL be invoked with the new start/end dates
22. WHEN converting a timed event to all-day via drag THEN the system SHALL detect when the event is dragged into the all-day section, retain the drop date (accounting for any cross-day navigation), set start and end times to midnight (00:00:00), and set `isAllDay = true`
23. WHEN converting an all-day event to timed via drag THEN the system SHALL detect when the event is dragged into the timed events area, use the Y-position to determine start time, set duration via `allDayToTimedDuration` parameter (default: 1 hour), use the drop date (accounting for any cross-day navigation), and set `isAllDay = false`

### Requirement 5: Timed Events Layout and Positioning

**User Story:** As a calendar user, I want timed events positioned vertically according to their start and end times, with their height reflecting duration, so that I can quickly understand the schedule at a glance.

#### Acceptance Criteria

1. WHEN an event with `isAllDay == false` exists THEN it SHALL render in the timed events area
2. WHEN calculating an event's vertical position THEN it SHALL use: `topOffset = ((event.start.hour - startHour) * 60 + event.start.minute) / 60.0 * hourHeight`
3. WHEN calculating an event's height THEN it SHALL use: `height = (event.end - event.start).inMinutes / 60.0 * hourHeight`
4. WHEN an event's calculated height is less than `timedEventMinHeight` (default: 20dp) THEN it SHALL be clamped to the minimum
5. WHEN multiple events overlap in time THEN the system SHALL use an overlap detection algorithm to assign them to columns
6. WHEN events are assigned to columns THEN they SHALL be rendered side-by-side with equal column widths
7. WHEN rendering an event tile THEN it SHALL be positioned absolutely within the timed events stack using `Positioned` widget
8. WHEN `timedEventTileBuilder` callback is provided THEN it SHALL be used to render timed event tiles
9. WHEN `dayLayoutBuilder` callback is provided THEN it SHALL allow complete custom layout of overlapping events (similar to `weekLayoutBuilder` in month view)
10. WHEN an event tile is tapped THEN `onEventTap` callback SHALL be invoked
11. WHEN an event tile is long-pressed THEN `onEventLongPress` callback SHALL be invoked
12. WHEN hovering over an event tile on platforms with hover support THEN `onHoverEvent` callback SHALL be invoked

### Requirement 6: Overlap Detection Algorithm

**User Story:** As a developer integrating the day view, I want the system to automatically detect overlapping events and lay them out in columns, so that all concurrent events are visible without manual layout calculations.

#### Acceptance Criteria

1. WHEN determining if two events overlap THEN they SHALL be considered overlapping IF: `event1.start < event2.end AND event2.start < event1.end`
2. WHEN calculating layout THEN events SHALL first be sorted by start time, with ties broken by duration (longest first)
3. WHEN assigning columns THEN the system SHALL iterate through sorted events and assign each to the first available column where it doesn't overlap existing events in that column
4. WHEN calculating column widths THEN they SHALL be equal: `columnWidth = timedEventsAreaWidth / totalColumnsUsed`
5. WHEN an event spans multiple columns (no conflicts) THEN it MAY expand to fill available adjacent empty columns
6. WHEN `dayLayoutBuilder` is provided THEN it SHALL receive all events with their calculated layout assignments and MAY return a completely custom layout
7. WHEN the default layout is used THEN it SHALL produce a Google Calendar-style column layout
8. WHEN calculating layout THEN the algorithm SHALL complete in O(n²) time or better where n is the number of events

### Requirement 7: Current Time Indicator

**User Story:** As a calendar user, I want to see a line marking the current time, so that I can quickly identify "now" within the day's schedule.

#### Acceptance Criteria

1. WHEN the displayed date is today THEN a current time indicator SHALL be rendered
2. WHEN the current time indicator renders THEN it SHALL be a horizontal line spanning the width of the timed events area
3. WHEN in LTR mode THEN a circular dot SHALL appear on the left end of the indicator line
4. WHEN in RTL mode THEN a circular dot SHALL appear on the right end of the indicator line
5. WHEN calculating the indicator's vertical position THEN it SHALL use: `offset = ((now.hour - startHour) * 60 + now.minute) / 60.0 * hourHeight`
6. WHEN time changes THEN the indicator position SHALL update automatically via `Timer.periodic` every minute
7. WHEN `showCurrentTimeIndicator` is false THEN the indicator SHALL NOT render
8. IF `showCurrentTimeIndicator` is not provided THEN it SHALL default to true
9. WHEN the indicator is themed THEN it SHALL respect `currentTimeIndicatorColor`, `currentTimeIndicatorWidth`, and `currentTimeIndicatorDotRadius` theme properties
10. WHEN `currentTimeIndicatorBuilder` callback is provided THEN it SHALL allow complete custom rendering of the indicator
11. WHEN the widget is disposed THEN the timer SHALL be cancelled to prevent memory leaks

### Requirement 8: Vertical Scrolling

**User Story:** As a calendar user, I want to scroll vertically through the day's time range, so that I can view events outside the visible viewport and navigate to any time of day.

#### Acceptance Criteria

1. WHEN the timed events area height exceeds the viewport THEN the view SHALL be vertically scrollable
2. WHEN `autoScrollToCurrentTime` is true (default) AND the displayed date is today THEN the view SHALL automatically scroll to show the current time on initial render
3. WHEN auto-scrolling to current time THEN it SHALL position the current time indicator in the vertical center of the viewport (if possible)
4. WHEN `scrollPhysics` parameter is provided THEN the scroll view SHALL use the specified physics
5. IF `scrollPhysics` is not provided THEN it SHALL use default `ClampingScrollPhysics`
6. WHEN scrolling occurs THEN `onScrollChanged` callback SHALL be invoked with scroll position details
7. WHEN the controller method `scrollToTime(DateTime time)` is called THEN the view SHALL programmatically scroll to show the specified time
8. WHEN the controller method `scrollToEvent(MCalCalendarEvent event)` is called THEN the view SHALL scroll to show the event
9. WHEN scrolling near the top or bottom edge during a drag operation THEN it SHALL NOT trigger auto-navigation (edge navigation is horizontal-only)

### Requirement 9: Day Navigator

**User Story:** As a calendar user, I want navigation controls to move between days, so that I can quickly jump to yesterday, today, or tomorrow.

#### Acceptance Criteria

1. WHEN `showNavigator` is true THEN a navigator SHALL render at the top of the day view
2. IF `showNavigator` is not provided THEN it SHALL default to false
3. WHEN the navigator renders by default THEN it SHALL display: Previous button, date display, Today button, Next button
4. WHEN Previous button is tapped THEN the view SHALL navigate to the previous day
5. WHEN Next button is tapped THEN the view SHALL navigate to the next day
6. WHEN Today button is tapped THEN the view SHALL navigate to today's date
7. WHEN navigation occurs THEN `onDisplayDateChanged` callback SHALL be invoked with the new date
8. WHEN `minDate` is set AND the displayed date equals minDate THEN Previous button SHALL be disabled
9. WHEN `maxDate` is set AND the displayed date equals maxDate THEN Next button SHALL be disabled
10. WHEN `navigatorBuilder` callback is provided THEN it SHALL allow complete custom navigator rendering
11. WHEN the navigator builder is used THEN it SHALL receive `MCalNavigatorContext` with: `displayedDate`, `canGoPrevious`, `canGoNext`, navigation callbacks

### Requirement 10: Drag-to-Move Time-Based with Event Type Conversion

**User Story:** As a calendar user, I want to long-press and drag an event vertically to change its start time, and drag between all-day and timed sections to convert event types, so that I can quickly reschedule and change event characteristics without opening an editor.

#### Acceptance Criteria

##### Basic Timed Event Drag

1. WHEN `enableDragToMove` is true AND the user long-presses a timed event tile THEN a drag operation SHALL initiate
2. WHEN a drag is initiated THEN the system SHALL use the existing `MCalDragHandler` to manage drag state
3. WHEN dragging vertically within the timed section THEN the event's proposed start time SHALL update based on pointer Y position
4. WHEN calculating proposed start time from Y position THEN it SHALL use: `offsetToTime(yOffset, displayDate, startHour, hourHeight, timeSlotDuration)`
5. WHEN `timeSlotDuration` is set (default: 15 minutes) THEN proposed times SHALL snap to time slot boundaries
6. WHEN dragging THEN a drop target preview tile SHALL render at the proposed time position
7. WHEN dragging THEN highlighted time slots SHALL show the proposed time range
8. WHEN `onDragWillAccept` callback is provided THEN it SHALL be invoked to validate the proposed time range
9. IF `onDragWillAccept` returns false THEN the drop target SHALL show invalid visual feedback
10. WHEN the user releases the drag THEN `onEventDropped` callback SHALL be invoked with `MCalEventDroppedDetails`
11. IF `onEventDropped` returns true (or is not provided) THEN the event SHALL update to the new time
12. IF `onEventDropped` returns false THEN the event SHALL revert to its original time
13. WHEN dragging a recurring event occurrence THEN the controller SHALL create a `modified` exception with the updated event

##### Timed to All-Day Conversion

14. WHEN dragging a timed event into the all-day section THEN the system SHALL detect the section boundary crossing
15. WHEN the drop occurs in the all-day section THEN the system SHALL:
    - Use the drop date (accounting for any cross-day edge navigation during the drag)
    - Set start time to midnight (00:00:00) on the drop date
    - Set end time to midnight (00:00:00) on the drop date
    - Set `isAllDay = true`
16. WHEN converting timed to all-day THEN the original event duration SHALL be discarded (all-day events span full days, not hours)

##### All-Day to Timed Conversion

17. WHEN dragging an all-day event into the timed events section THEN the system SHALL detect the section boundary crossing
18. WHEN the drop occurs in the timed section THEN the system SHALL:
    - Use the drop date (accounting for any cross-day edge navigation during the drag)
    - Calculate start time from the Y-position of the drop: `offsetToTime(yOffset, ...)`
    - Calculate end time as: `start time + allDayToTimedDuration`
    - Set `isAllDay = false`
19. WHEN `allDayToTimedDuration` parameter is set THEN it SHALL be used for the converted event duration
20. IF `allDayToTimedDuration` is not provided THEN it SHALL default to `Duration(hours: 1)`
21. WHEN the calculated end time would exceed the `endHour` boundary THEN the end time SHALL be clamped to `endHour:00` or the event duration shall be reduced to fit

##### Validation for Conversions

22. WHEN converting event types THEN `onDragWillAccept` callback SHALL be invoked with the proposed converted event details
23. WHEN converting event types THEN `MCalEventDroppedDetails` SHALL include a field indicating the event type changed

### Requirement 11: Drag-to-Move Cross-Day Navigation

**User Story:** As a calendar user, I want to drag an event to the left or right edge to move it to the previous or next day, so that I can reschedule across days in one gesture.

#### Acceptance Criteria

1. WHEN `dragEdgeNavigationEnabled` is true (default) AND dragging horizontally near the left edge THEN the view SHALL navigate to the previous day after a delay
2. WHEN dragging horizontally near the right edge THEN the view SHALL navigate to the next day after a delay
3. WHEN edge navigation is triggered THEN the delay SHALL be configurable (default: matching month view's 1200ms)
4. WHEN edge navigation occurs during drag THEN the drag gesture SHALL persist and continue on the new day
5. WHEN edge proximity is calculated THEN the threshold SHALL be consistent with month view (10% of viewport width or 50px, whichever is larger)
6. WHEN navigating at `minDate` boundary THEN backward navigation SHALL be prevented
7. WHEN navigating at `maxDate` boundary THEN forward navigation SHALL be prevented
8. WHEN navigation completes THEN the proposed drop time SHALL be recalculated for the new day at the same time-of-day
9. WHEN edge navigation repeats (user holds near edge) THEN it SHALL use a self-repeating timer pattern (similar to month view)

### Requirement 12: Drag-to-Resize Top and Bottom Edges with Cross-Day Navigation

**User Story:** As a calendar user, I want to drag the top or bottom edge of a timed event to change its start or end time, including across day boundaries, so that I can adjust event duration without opening an editor.

#### Acceptance Criteria

##### Basic Resize Interaction

1. WHEN `enableDragToResize` is true AND the user drags the top edge of a timed event tile THEN the start time SHALL change
2. WHEN the user drags the bottom edge of a timed event tile THEN the end time SHALL change
3. WHEN resize handles render THEN they SHALL be visible on hover (desktop/web) or always visible (configurable)
4. WHEN a resize handle is hovered THEN the cursor SHALL change to `SystemMouseCursors.resizeUpDown`
5. WHEN resizing THEN the proposed new time SHALL snap to `timeSlotDuration` boundaries
6. WHEN resizing would result in an event shorter than `timeSlotDuration` THEN the minimum duration SHALL be enforced (cannot shrink below 1 slot)
7. WHEN resizing THEN a drop target preview SHALL show the proposed new event bounds
8. WHEN `onResizeWillAccept` callback is provided THEN it SHALL be invoked to validate the proposed times
9. IF `onResizeWillAccept` returns false THEN the preview SHALL show invalid visual feedback
10. WHEN the user releases the resize THEN `onEventResized` callback SHALL be invoked with `MCalEventResizedDetails`
11. IF `onEventResized` returns true (or is not provided) THEN the event SHALL update to the new times
12. IF `onEventResized` returns false THEN the event SHALL revert to its original times
13. WHEN resizing a recurring event occurrence THEN the controller SHALL create a `modified` exception with updated times
14. WHEN `timeResizeHandleBuilder` callback is provided THEN it SHALL allow custom resize handle rendering

##### Cross-Day Resize with Edge Navigation

15. WHEN `dragEdgeNavigationEnabled` is true (default) AND resizing the start edge (top) horizontally near the left edge THEN the view SHALL navigate to the previous day after a delay
16. WHEN resizing the start edge horizontally near the right edge THEN the view SHALL navigate to the next day after a delay
17. WHEN resizing the end edge (bottom) horizontally near the left edge THEN the view SHALL navigate to the previous day after a delay
18. WHEN resizing the end edge horizontally near the right edge THEN the view SHALL navigate to the next day after a delay
19. WHEN edge navigation occurs during resize THEN the resize gesture SHALL persist across the page transition
20. WHEN edge navigation completes during resize THEN the proposed time SHALL be recalculated for the new day at the same time-of-day
21. WHEN navigating at `minDate` boundary THEN backward navigation SHALL be prevented
22. WHEN navigating at `maxDate` boundary THEN forward navigation SHALL be prevented
23. WHEN edge navigation repeats during resize THEN it SHALL use the same self-repeating timer pattern as drag-to-move

### Requirement 13: Keyboard Navigation Day and Event Focus

**User Story:** As a keyboard user, I want to navigate the calendar using arrow keys, so that I can use the day view without a mouse.

#### Acceptance Criteria

1. WHEN `enableKeyboardNavigation` is true (default) THEN the day view SHALL handle keyboard input
2. WHEN Left Arrow is pressed THEN the view SHALL navigate to the previous day
3. WHEN Right Arrow is pressed THEN the view SHALL navigate to the next day
4. WHEN Up Arrow is pressed THEN focus SHALL move to the previous event in the day (by start time)
5. WHEN Down Arrow is pressed THEN focus SHALL move to the next event in the day (by start time)
6. WHEN Home key is pressed THEN the view SHALL navigate to today
7. WHEN PageUp is pressed THEN the view SHALL navigate back 7 days
8. WHEN PageDown is pressed THEN the view SHALL navigate forward 7 days
9. WHEN Tab is pressed THEN focus SHALL move to the next focusable element (standard behavior)
10. WHEN an event has focus THEN it SHALL have visual focus indication (themed via `focusedEventBorderColor` or similar)
11. WHEN keyboard navigation is disabled THEN Escape key SHALL still be handled (for canceling drags)

### Requirement 14: Keyboard Event Move Mode

**User Story:** As a keyboard user, I want to move events using arrow keys, so that I have an accessible alternative to drag-and-drop.

#### Acceptance Criteria

1. WHEN an event is focused AND Enter or Space is pressed THEN the system SHALL enter keyboard event move mode
2. WHEN in move mode THEN Up/Down arrows SHALL change the proposed start time by 1 time slot
3. WHEN in move mode THEN Left/Right arrows SHALL change the proposed day by 1 day
4. WHEN in move mode THEN the drop target preview SHALL show the proposed new position
5. WHEN in move mode AND Enter is pressed THEN the move SHALL be confirmed via the `onEventDropped` callback
6. WHEN in move mode AND Escape is pressed THEN the move SHALL be cancelled
7. WHEN in move mode THEN `onDragWillAccept` validation SHALL apply
8. WHEN confirming a keyboard move THEN the same logic as mouse-based drop SHALL be used
9. WHEN in move mode THEN screen reader SHALL announce each proposed time change
10. WHEN move is confirmed or cancelled THEN screen reader SHALL announce the result

### Requirement 15: Keyboard Event Resize Mode

**User Story:** As a keyboard user, I want to resize events using keyboard shortcuts, so that I have an accessible alternative to edge-drag resizing.

#### Acceptance Criteria

1. WHEN an event is selected in keyboard move mode AND R key is pressed THEN the system SHALL enter resize mode
2. WHEN entering resize mode THEN the active edge SHALL default to the end edge (bottom)
3. WHEN in resize mode AND S key is pressed THEN the active edge SHALL switch to the start edge (top)
4. WHEN in resize mode AND E key is pressed THEN the active edge SHALL switch to the end edge (bottom)
5. WHEN in resize mode THEN Up/Down arrows SHALL adjust the active edge by 1 time slot
6. WHEN in resize mode THEN Left/Right arrows SHALL have no effect (day changes not applicable during resize)
7. WHEN in resize mode AND Enter is pressed THEN the resize SHALL be confirmed via `onEventResized` callback
8. WHEN in resize mode AND Escape is pressed THEN the resize SHALL be cancelled
9. WHEN in resize mode AND M key is pressed THEN the system SHALL return to move mode (exit resize)
10. WHEN in resize mode THEN minimum duration SHALL be enforced (cannot shrink below 1 time slot)
11. WHEN in resize mode THEN `onResizeWillAccept` validation SHALL apply
12. WHEN in resize mode THEN screen reader SHALL announce each edge adjustment
13. WHEN resize is confirmed or cancelled THEN screen reader SHALL announce the result

### Requirement 16: Empty Time Slot Interactions

**User Story:** As a calendar user, I want to tap on empty time slots to create new events, so that I can quickly add events at specific times.

#### Acceptance Criteria

1. WHEN the user taps an empty area in the timed events section THEN `onTimeSlotTap` callback SHALL be invoked
2. WHEN the callback is invoked THEN it SHALL receive `MCalTimeSlotContext` with: `date`, `time` (calculated from Y position), `isAllDayArea` (false)
3. WHEN the user long-presses an empty time slot THEN `onTimeSlotLongPress` callback SHALL be invoked
4. WHEN the user taps the time legend THEN `onTimeLabelTap` callback SHALL be invoked with the hour
5. WHEN the user hovers over an empty time slot on hover-capable platforms THEN `onHoverTimeSlot` callback SHALL be invoked
6. WHEN the user taps an empty area in the all-day section THEN `onTimeSlotTap` SHALL be invoked with `isAllDayArea` set to true

### Requirement 17: Theme Integration and Customization

**User Story:** As a developer, I want to customize all visual aspects of the day view via theme properties, so that I can match my app's design system.

#### Acceptance Criteria

1. WHEN MCalDayView renders THEN it SHALL apply theme properties from `MCalTheme.of(context)`
2. WHEN theme properties are not found in `MCalTheme` THEN they SHALL fall back to `Theme.of(context).extension<MCalThemeData>()`
3. IF no MCalThemeData extension exists THEN theme SHALL be generated via `MCalThemeData.fromTheme(Theme.of(context))`
4. WHEN the following theme properties are set THEN they SHALL be applied:
   - `timeLegendWidth`, `timeLegendTextStyle`, `timeLegendBackgroundColor`
   - `hourGridlineColor`, `halfHourGridlineColor`
   - `currentTimeIndicatorColor`, `currentTimeIndicatorWidth`, `currentTimeIndicatorDotRadius`
   - `allDaySectionHeight`, `allDaySectionMaxRows`
   - `hourHeight`, `timedEventMinHeight`, `timedEventBorderRadius`, `timedEventPadding`
   - All existing event tile theme properties from month view
5. WHEN day view specific properties are added to `MCalThemeData` THEN they SHALL follow the nullable pattern with sensible defaults
6. WHEN light/dark mode changes THEN all theme properties SHALL adapt automatically via `ColorScheme`

### Requirement 18: Builder Callback Customization

**User Story:** As a developer, I want builder callbacks for all visual elements, so that I can completely customize the day view appearance without forking the package.

#### Acceptance Criteria

1. WHEN the following builder callbacks are provided THEN they SHALL override default rendering:
   - `dayHeaderBuilder`: Custom day header rendering
   - `timeLabelBuilder`: Custom time legend labels
   - `allDayEventTileBuilder`: Custom all-day event tiles
   - `timedEventTileBuilder`: Custom timed event tiles
   - `currentTimeIndicatorBuilder`: Custom time indicator
   - `gridlineBuilder`: Custom gridline rendering per hour
   - `navigatorBuilder`: Custom navigator
   - `dayLayoutBuilder`: Custom overlap layout algorithm
   - `draggedTileBuilder`: Custom dragged tile feedback
   - `dropTargetTileBuilder`: Custom drop preview tiles
   - `timeResizeHandleBuilder`: Custom resize handles
2. WHEN a builder callback is invoked THEN it SHALL receive a context object (e.g., `MCalTimeLabelContext`, `MCalTimedEventTileContext`) with all relevant data
3. WHEN a builder returns a widget THEN it SHALL replace the default widget in that position
4. WHEN a builder returns null (if allowed) THEN the default widget SHALL be used

### Requirement 19: RTL (Right-to-Left) Layout Support

**User Story:** As a user of RTL languages (Arabic, Hebrew), I want the day view to fully support RTL layout, so that the interface feels natural in my language.

#### Acceptance Criteria

1. WHEN the locale is RTL THEN the time legend SHALL be positioned on the right side
2. WHEN the locale is RTL THEN the day header SHALL be positioned at top-right
3. WHEN the locale is RTL THEN the current time indicator dot SHALL be on the right end of the line
4. WHEN the locale is RTL THEN drag edge navigation directions SHALL be reversed (left edge = next day, right edge = previous day)
5. WHEN the locale is RTL THEN all builder callbacks SHALL receive correct `isRTL` information in their context objects
6. WHEN the locale is RTL THEN navigator buttons SHALL render in reversed order (Next, Today, Previous)
7. WHEN testing in RTL mode THEN all interactions (tap, drag, resize, keyboard) SHALL work correctly

## Non-Functional Requirements

### Code Architecture and Modularity

- **Single Responsibility**: Separate widgets for time legend, gridlines, all-day section, timed events, current time indicator, navigator - each with a single purpose
- **Modular Design**: Overlap detection algorithm in dedicated utility class for testability
- **Component Reuse**: Reuse `MCalDragHandler` from month view for all drag/resize operations
- **Clean Interfaces**: Context objects (`MCalTimeSlotContext`, `MCalTimedEventTileContext`, etc.) provide clean contracts between view and builders
- **State Management**: Controller pattern with `MCalEventController` for event data, widget state for UI concerns
- **DST Safety**: All time calculations use `DateTime(y, m, d, h, m)` constructor pattern, never `Duration(days:)` or `Duration(hours:)` arithmetic
- **Time Zone Neutrality**: Times are treated in local device time; time zone handling is out of scope (consistent with month view)

### Performance

- **Rendering**: Maintain 60fps during scrolling with 50+ events
- **Overlap Detection**: Algorithm shall complete in O(n²) time or better where n = number of events
- **Viewport Optimization**: Only render events visible in current scroll position (with small buffer)
- **Time Calculation**: All time-to-offset and offset-to-time calculations shall use simple arithmetic (no expensive operations)
- **Drag Updates**: Position updates during drag shall be debounced to 16ms intervals (60fps)
- **Timer Efficiency**: Current time indicator timer shall fire once per minute, not continuously
- **Memory**: View shall efficiently dispose timers, listeners, and resources when widget is disposed

### Reliability

- **Edge Cases**: Handle empty days, single event, 50+ overlapping events, midnight-spanning events, all-day conversion
- **DST Boundaries**: Correctly handle dates near DST transitions using safe date arithmetic
- **Boundary Enforcement**: Respect `minDate` and `maxDate` in all navigation and drag operations
- **Error Recovery**: Gracefully handle invalid drag/resize operations by reverting to original state
- **Controller Integration**: Handle controller updates (events added/removed/modified) and rebuild efficiently
- **Recurring Events**: Correctly expand recurring events for displayed date, handle exceptions

### Usability

- **Touch Targets**: All interactive elements shall have minimum 44×44dp touch targets (iOS) or 48×48dp (Material)
- **Visual Feedback**: All interactions (tap, drag, resize, hover) shall provide immediate visual feedback
- **Drag Affordance**: Long-press delay (default: 200ms) shall feel natural, not too fast or too slow
- **Snap Feedback**: Time slot snapping during drag/resize shall feel smooth, not jarring
- **Scroll Inertia**: Vertical scrolling shall feel natural with platform-appropriate physics
- **Loading States**: Display loading indicator when controller is fetching events
- **Error States**: Display error message if controller reports loading failure
- **Empty States**: Display helpful message when no events exist for the day

### Accessibility

- **Screen Reader**: All interactive elements shall have semantic labels
- **Semantic Announcements**: Drag, resize, and navigation operations shall announce via `SemanticsService`
- **Focus Management**: Keyboard focus shall be visually indicated and follow logical order
- **Focus Trap Prevention**: Focus shall not get trapped in any part of the view
- **Reduced Motion**: Respect `MediaQuery.disableAnimationsOf(context)` for users with motion sensitivity
- **Color Contrast**: Default theme shall meet WCAG AA contrast ratios (4.5:1 for text)
- **Keyboard Complete**: All mouse interactions shall have keyboard equivalents
- **Touch Accommodations**: Support larger touch targets when accessibility features request it

### Localization

- **Date Formatting**: Use intl package for date formatting in day header
- **Time Formatting**: Use locale-appropriate 12/24-hour format in time legend
- **RTL Layouts**: Full RTL support as specified in Requirement 19
- **Localized Strings**: All UI text (today button, overflow indicators) shall use `MCalLocalizations`
- **Number Formatting**: Hour numbers shall be formatted per locale (e.g., Arabic numerals in Arabic locales)

### Consistency with MCalMonthView

- **API Patterns**: Parameter naming, callback signatures, builder patterns shall mirror month view
- **Theme Structure**: Day view theme properties shall extend existing `MCalThemeData` consistently
- **Drag Handler Integration**: Reuse same `MCalDragHandler` patterns for drag/resize state management
- **Controller Integration**: Use same `MCalEventController` with same event loading patterns
- **Context Objects**: Follow same pattern as `MCalDayCellContext`, `MCalEventTileContext` from month view
- **Callback Details**: Follow same pattern as `MCalEventDroppedDetails`, `MCalEventResizedDetails` from month view
- **Keyboard Navigation**: Key mappings and interaction patterns shall be consistent
- **Documentation Style**: API docs shall follow same dartdoc patterns as month view
