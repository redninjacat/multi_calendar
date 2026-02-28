# Requirements Document

## Introduction

This specification defines the requirements for Month View Enhancements Part 2, which adds advanced animation, gesture-based navigation, contiguous multi-day event rendering, drag-and-drop functionality, and standardizes the callback API patterns across the package.

The enhancements include:

* **Callback API Standardization** using details objects for all callbacks with 3+ parameters
* **PageView-style swipe navigation** with peek preview of adjacent months
* **Simultaneous slide animations** where outgoing and incoming months animate together
* **Contiguous multi-day event tiles** that render as single visual blocks across days
* **Drag-and-drop event moving** with validation, visual feedback, and cross-month navigation

These features significantly improve the user experience by providing intuitive navigation gestures, professional calendar visuals matching industry-standard apps, and powerful event manipulation capabilities.

## Alignment with Product Vision

This enhancement specification directly supports the product principles:

* **Developer-Friendly**: Standardized callback API with consistent `(BuildContext, MCalXxxDetails)` signature
* **Mobile-First Design**: PageView-style swipe navigation is the expected mobile interaction pattern
* **Customization First**: Provides builders and boolean options for multi-day tile appearance
* **Performance Conscious**: Efficient animation implementation that maintains 60fps
* **Accessibility First**: Drag-and-drop provides appropriate accessibility alternatives

## Requirements

### Requirement 1: Callback API Standardization

**User Story:** As a developer, I want all callbacks to follow a consistent pattern with details objects, so that the API is predictable, easier to use, and extensible without breaking changes.

#### Acceptance Criteria

##### Callback Signature Pattern

1. WHEN any callback has more than 2 parameters (excluding BuildContext) THEN it SHALL be refactored to use a details object
2. WHEN a callback is a builder (returns Widget) THEN its signature SHALL be:
   * `Widget Function(BuildContext context, MCalXxxDetails details)` for simple builders, OR
   * `Widget Function(BuildContext context, MCalXxxDetails details, Widget defaultWidget)` for builders that provide a default
3. WHEN a callback is an event handler (returns void or bool) THEN its signature SHALL be:
   * `void Function(BuildContext context, MCalXxxDetails details)` for void callbacks
   * `bool Function(BuildContext context, MCalXxxDetails details)` for validation callbacks
4. WHEN I need theme data in a callback THEN I SHALL access it via `MCalTheme.of(context)` rather than receiving it in the details object

##### Theme Access API

5. WHEN I call `MCalTheme.of(context)` THEN it SHALL return the resolved `MCalThemeData`:
   * First checks for `MCalTheme` inherited widget in the tree
   * Falls back to `Theme.of(context).extension<MCalThemeData>()`
   * Falls back to `MCalThemeData.fromTheme(Theme.of(context))`
6. WHEN I call `MCalTheme.maybeOf(context)` THEN it SHALL return nullable `MCalThemeData?` without fallback

##### Existing Callbacks to Migrate

7. WHEN I examine `onCellTap` THEN it SHALL be migrated from:
   * OLD: `void Function(DateTime, List<MCalCalendarEvent>, bool)?`
   * NEW: `void Function(BuildContext context, MCalCellTapDetails details)?`
   * `MCalCellTapDetails` SHALL include: `date`, `events`, `isCurrentMonth`

8. WHEN I examine `onCellLongPress` THEN it SHALL be migrated from:
   * OLD: `void Function(DateTime, List<MCalCalendarEvent>, bool)?`
   * NEW: `void Function(BuildContext context, MCalCellTapDetails details)?`
   * Reuses `MCalCellTapDetails`

9. WHEN I examine `onEventTap` THEN it SHALL be migrated from:
   * OLD: `void Function(MCalCalendarEvent, DateTime)?`
   * NEW: `void Function(BuildContext context, MCalEventTapDetails details)?`
   * `MCalEventTapDetails` SHALL include: `event`, `displayDate`

10. WHEN I examine `onEventLongPress` THEN it SHALL be migrated from:
    * OLD: `void Function(MCalCalendarEvent, DateTime)?`
    * NEW: `void Function(BuildContext context, MCalEventTapDetails details)?`
    * Reuses `MCalEventTapDetails`

11. WHEN I examine `onSwipeNavigation` THEN it SHALL be migrated from:
    * OLD: `void Function(DateTime, DateTime, MCalSwipeDirection)?`
    * NEW: `void Function(BuildContext context, MCalSwipeNavigationDetails details)?`
    * `MCalSwipeNavigationDetails` SHALL include: `previousMonth`, `newMonth`, `direction`

12. WHEN I examine `onOverflowTap` THEN it SHALL be migrated from:
    * OLD: `void Function(DateTime, List<MCalCalendarEvent>, int)?`
    * NEW: `void Function(BuildContext context, MCalOverflowTapDetails details)?`
    * `MCalOverflowTapDetails` SHALL include: `date`, `allEvents`, `hiddenCount`

13. WHEN I examine `onOverflowLongPress` THEN it SHALL be migrated from:
    * OLD: `void Function(DateTime, List<MCalCalendarEvent>, int)?`
    * NEW: `void Function(BuildContext context, MCalOverflowTapDetails details)?`
    * Reuses `MCalOverflowTapDetails`

14. WHEN I examine `cellInteractivityCallback` THEN it SHALL be migrated from:
    * OLD: `bool Function(DateTime, bool, bool)?`
    * NEW: `bool Function(BuildContext context, MCalCellInteractivityDetails details)?`
    * `MCalCellInteractivityDetails` SHALL include: `date`, `isCurrentMonth`, `isSelectable`

15. WHEN I examine `errorBuilder` THEN it SHALL be migrated from:
    * OLD: `Widget Function(BuildContext, Object, VoidCallback)?`
    * NEW: `Widget Function(BuildContext context, MCalErrorDetails details)?`
    * `MCalErrorDetails` SHALL include: `error`, `onRetry`

##### Existing Context Classes to Update

16. WHEN I examine existing context classes THEN `theme` property SHALL be removed from:
    * `MCalDayCellContext`
    * `MCalEventTileContext`
    * `MCalDayHeaderContext`
    * `MCalNavigatorContext`
    * `MCalWeekNumberContext`

### Requirement 2: PageView-Style Swipe Navigation

**User Story:** As a mobile user, I want to swipe left and right to navigate between months with a natural page-turning gesture, so that the calendar feels intuitive and responsive like other mobile apps.

#### Acceptance Criteria

1. WHEN I drag horizontally on the month grid THEN MCalMonthView SHALL show a preview of the adjacent month sliding into view (like PageView behavior)
2. WHEN I drag right (to go to previous month) THEN the previous month SHALL peek in from the left edge
3. WHEN I drag left (to go to next month) THEN the next month SHALL peek in from the right edge
4. WHEN I release the drag after crossing the swipe threshold THEN MCalMonthView SHALL complete the navigation animation
5. WHEN I release the drag before crossing the swipe threshold THEN MCalMonthView SHALL snap back to the current month
6. WHEN I configure MCalMonthView THEN it SHALL accept an `enableSwipeNavigation` parameter (defaults to true)
7. WHEN `enableSwipeNavigation` is false THEN swipe gestures SHALL not navigate between months
8. WHEN I swipe quickly (fling) THEN MCalMonthView SHALL navigate based on velocity, not just distance
9. WHEN the current month is at `minDate` boundary THEN swiping to previous month SHALL be prevented (bounce back)
10. WHEN the current month is at `maxDate` boundary THEN swiping to next month SHALL be prevented (bounce back)
11. WHEN swipe navigation occurs THEN `onSwipeNavigation` callback SHALL be called with `MCalSwipeNavigationDetails`

### Requirement 3: Simultaneous Slide Animation

**User Story:** As a user, I want month transitions to animate smoothly with both the old and new month sliding together, so that navigation feels natural like turning pages.

#### Acceptance Criteria

1. WHEN navigating to the next month with animation enabled THEN MCalMonthView SHALL:
   * Slide the current month out to the LEFT
   * Simultaneously slide the new month in from the RIGHT
2. WHEN navigating to the previous month with animation enabled THEN MCalMonthView SHALL:
   * Slide the current month out to the RIGHT
   * Simultaneously slide the new month in from the LEFT
3. WHEN `enableAnimations` is true THEN simultaneous slide animation SHALL apply to ALL navigation methods:
   * Swipe gestures
   * Navigator arrow buttons
   * Keyboard navigation (Page Up/Down)
   * Programmatic navigation via `controller.setDisplayDate()`
4. WHEN `enableAnimations` is false THEN month changes SHALL occur instantly without animation
5. WHEN I configure MCalEventController THEN it SHALL provide a method `navigateToDateWithoutAnimation(DateTime date)`:
   * This method SHALL update the display date without triggering animation
   * This method SHALL work even when `enableAnimations` is true on the view
6. WHEN I configure MCalEventController THEN `setDisplayDate()` SHALL accept an optional `animate` parameter:
   * `setDisplayDate(date, animate: true)` - uses animation if enabled on view (default)
   * `setDisplayDate(date, animate: false)` - skips animation regardless of view setting
7. WHEN animation is in progress AND user initiates a new navigation THEN the current animation SHALL be interrupted and new animation SHALL begin from current visual state
8. WHEN animation completes THEN there SHALL be no visual discontinuity or flicker
9. WHEN I examine the animation THEN it SHALL maintain 60fps on mid-range mobile devices
10. WHEN both months are sliding THEN the transition SHALL use the configured `animationDuration` and `animationCurve`

### Requirement 4: Contiguous Multi-Day Event Tiles

**User Story:** As a user, I want multi-day events to display as single contiguous tiles spanning across days, so that I can quickly identify events that span multiple days like professional calendar apps.

#### Acceptance Criteria

##### Default Rendering

1. WHEN a multi-day event spans multiple days within a week row THEN MCalMonthView SHALL render it as ONE contiguous tile by default (no gaps between days)
2. WHEN a multi-day event wraps to a new week row THEN MCalMonthView SHALL render:
   * First row segment: rounded corners on left (start), squared corners on right (continues)
   * Continuation row segments: squared corners on left (continued), rounded corners on right (ends)
   * Middle row segments (if event spans 3+ weeks): squared corners on both sides
3. WHEN I view multi-day events THEN they SHALL be visually distinct from single-day events
4. WHEN multi-day event tiles render THEN each day segment SHALL still be accessible as a tap/click target

##### Event Ordering

5. WHEN MCalMonthView renders events in a day cell THEN they SHALL be ordered:
   1. All-day multi-day events (sorted by start date, then title)
   2. Timed multi-day events (sorted by start date, then start time, then title)
   3. All-day single-day events (sorted by title)
   4. Timed single-day events (sorted by start time, then title)
6. WHEN determining if an event is "multi-day" THEN it SHALL be based on whether the event spans more than one calendar day (comparing date portions of start and end)

##### Configuration API

7. WHEN I configure MCalMonthView THEN it SHALL accept a `renderMultiDayEventsAsContiguous` parameter (defaults to true):
   * WHEN true THEN multi-day events render as contiguous tiles
   * WHEN false THEN multi-day events render as separate tiles per day (current behavior)
8. WHEN I configure MCalMonthView THEN it SHALL accept a `multiDayEventTileBuilder` callback:
   * Signature: `Widget Function(BuildContext context, MCalMultiDayTileDetails details, Widget defaultWidget)?`
   * `MCalMultiDayTileDetails` SHALL include:
     * `event`: The MCalCalendarEvent
     * `displayDate`: The date being rendered
     * `isFirstDayOfEvent`: Boolean indicating if this is the event's start date
     * `isLastDayOfEvent`: Boolean indicating if this is the event's end date
     * `isFirstDayInRow`: Boolean indicating if this is the first visible day of the event in this week row
     * `isLastDayInRow`: Boolean indicating if this is the last visible day of the event in this week row
     * `dayIndexInEvent`: Zero-based index of this day within the event span
     * `totalDaysInEvent`: Total number of days the event spans
     * `dayIndexInRow`: Zero-based index of this day within the current row segment
     * `totalDaysInRow`: Total days of this event visible in the current row
     * `rowIndex`: Which row segment this is (0 = first row, 1 = second row, etc.)
     * `totalRows`: Total number of row segments for this event
   * The builder SHALL take precedence over `renderMultiDayEventsAsContiguous` and default styling
9. WHEN using `multiDayEventTileBuilder` THEN the developer CAN create:
   * Squared corners with border outline and no border on continuation edges
   * Icon-based continuation indicators
   * Custom colors, gradients, or patterns for spanning tiles
   * Any other visual representation

##### Interaction Behavior

10. WHEN I tap on any day segment of a contiguous multi-day tile THEN `onEventTap` SHALL be called with `MCalEventTapDetails`
11. WHEN I long-press on any day segment of a contiguous multi-day tile THEN `onEventLongPress` SHALL be called with `MCalEventTapDetails`
12. WHEN rendering contiguous tiles THEN they SHALL NOT interfere with other events on the same days (proper z-ordering and layout)

### Requirement 5: Drag-and-Drop Event Moving

**User Story:** As a user, I want to drag events to different dates to reschedule them, so that I can quickly reorganize my calendar without opening an event editor.

#### Acceptance Criteria

##### Enabling Drag-and-Drop

1. WHEN I configure MCalMonthView THEN it SHALL accept an `enableDragAndDrop` parameter (defaults to false)
2. WHEN `enableDragAndDrop` is true THEN event tiles SHALL be draggable via long-press and drag
3. WHEN `enableDragAndDrop` is false THEN event tiles SHALL NOT be draggable

##### Initiating a Drag

4. WHEN I long-press on an event tile THEN MCalMonthView SHALL initiate a drag operation after a short delay
5. WHEN drag initiates THEN the event tile being dragged SHALL follow the user's finger/pointer
6. WHEN drag initiates on a multi-day event THEN the entire event SHALL be selected for dragging (all days move together)
7. WHEN an event is hidden in the "+N more" overflow indicator THEN it SHALL NOT be draggable from the overflow (drag is not supported from overflow)

##### Visual Feedback During Drag

8. WHEN I configure MCalMonthView THEN it SHALL accept a `draggedTileBuilder` callback:
   * Signature: `Widget Function(BuildContext context, MCalDraggedTileDetails details)?`
   * `MCalDraggedTileDetails` SHALL include: `event`, `sourceDate`, `currentPosition`
   * Returns the widget to display following the user's finger
   * Default: renders the same as a normal event tile
9. WHEN I configure MCalMonthView THEN it SHALL accept a `dragSourceBuilder` callback:
   * Signature: `Widget Function(BuildContext context, MCalDragSourceDetails details)?`
   * `MCalDragSourceDetails` SHALL include: `event`, `sourceDate`
   * Returns the widget to display at the original location
   * Default: renders a semi-transparent "ghost" of the event (50% opacity)
10. WHEN I configure MCalMonthView THEN it SHALL accept a `dragTargetBuilder` callback:
    * Signature: `Widget Function(BuildContext context, MCalDragTargetDetails details)?`
    * `MCalDragTargetDetails` SHALL include: `event`, `targetDate`, `isValid`
    * Returns the widget to display previewing where the event will land
    * Default: renders a semi-transparent "ghost" of the event (50% opacity)
11. WHEN dragging over a valid drop target THEN the target cell SHALL provide visual feedback (highlight)
12. WHEN dragging over an invalid drop target THEN the target cell SHALL provide different visual feedback (e.g., red tint or no highlight)

##### Drop Validation

13. WHEN I configure MCalMonthView THEN it SHALL accept an `onDragWillAccept` callback:
    * Signature: `bool Function(BuildContext context, MCalDragWillAcceptDetails details)?`
    * `MCalDragWillAcceptDetails` SHALL include: `event`, `proposedStartDate`, `proposedEndDate`
    * Returns: `true` to allow drop, `false` to reject drop
    * Default: all drops are accepted if callback not provided
14. WHEN `onDragWillAccept` returns false THEN:
    * The drop target SHALL show "invalid" visual feedback
    * Releasing the drag SHALL cancel the operation and return event to original position
15. WHEN I configure MCalMonthView THEN it SHALL accept a `dropTargetCellBuilder` callback:
    * Signature: `Widget Function(BuildContext context, MCalDropTargetCellDetails details)?`
    * `MCalDropTargetCellDetails` SHALL include: `date`, `isValid`, `draggedEvent`
    * Returns the widget to render as the cell background
    * Can be used for custom valid/invalid highlighting

##### Completing the Drop

16. WHEN I release a drag over a valid drop target THEN MCalMonthView SHALL:
    * Calculate the new start and end dates (shifting by the day delta)
    * Update the event in MCalEventController with the new dates (auto-update)
    * Call `onEventDropped` callback with drop details
17. WHEN I configure MCalMonthView THEN it SHALL accept an `onEventDropped` callback:
    * Signature: `bool Function(BuildContext context, MCalEventDroppedDetails details)?`
    * `MCalEventDroppedDetails` SHALL include: `event`, `oldStartDate`, `oldEndDate`, `newStartDate`, `newEndDate`
    * Returns: `true` to confirm the update, `false` to reject and revert
    * Default: if callback not provided, update is confirmed
18. WHEN `onEventDropped` returns false THEN:
    * The event SHALL be reverted to its original position
    * The controller's event data SHALL be restored to original dates
19. WHEN the drop is successful THEN the event SHALL animate to its new position (if animations enabled)

##### Cross-Month Drag Navigation

20. WHEN I drag an event to the left edge of the calendar THEN:
    * MCalMonthView SHALL auto-navigate to the previous month after a short hover delay
    * The drag operation SHALL continue seamlessly into the new month
21. WHEN I drag an event to the right edge of the calendar THEN:
    * MCalMonthView SHALL auto-navigate to the next month after a short hover delay
    * The drag operation SHALL continue seamlessly into the new month
22. WHEN auto-navigating during drag THEN `minDate` and `maxDate` restrictions SHALL be respected
23. WHEN I configure MCalMonthView THEN it SHALL accept a `dragEdgeNavigationDelay` parameter:
    * Duration to wait at edge before navigating (defaults to 500ms)
    * Can be set to `Duration.zero` to disable edge navigation

##### Multi-Day Event Drag Behavior

24. WHEN I drag a multi-day event THEN all days of the event SHALL move together by the same delta
25. WHEN I drag a multi-day event THEN the drop preview SHALL show the full span at the new location
26. WHEN a multi-day event is dragged across week row boundaries THEN it SHALL continue to render correctly with appropriate row wrapping
27. WHEN calculating new dates for a multi-day event drop THEN:
    * The delta SHALL be calculated based on which day of the event was grabbed
    * Both start and end dates SHALL shift by the same number of days

##### Drag Cancellation

28. WHEN I drag an event outside the calendar bounds (not at navigable edge) THEN the drag SHALL be cancelled
29. WHEN I press Escape key during drag (on platforms that support it) THEN the drag SHALL be cancelled
30. WHEN drag is cancelled THEN the event SHALL animate back to its original position

## Non-Functional Requirements

### Code Architecture and Modularity

* **Single Responsibility**: Drag-and-drop logic should be encapsulated in dedicated handler classes/mixins
* **Modular Design**: Multi-day tile rendering should be separable from single-day tile rendering
* **Animation System**: Animation implementation should be reusable for future view types
* **Builder Pattern**: All new builders should follow the standardized callback pattern
* **Details Objects**: All details classes should be immutable and well-documented

### Performance

* Animations SHALL maintain 60fps on mid-range mobile devices
* Drag operations SHALL have less than 16ms latency for smooth following
* Multi-day tile rendering SHALL not significantly impact render time compared to current implementation
* Edge navigation during drag SHALL pre-load adjacent month events

### Usability

* Swipe gestures SHALL feel natural and responsive (matching PageView behavior)
* Drag-and-drop SHALL be discoverable (long-press hint or visual cue)
* Visual feedback during drag SHALL clearly indicate valid/invalid drop targets
* Multi-day tiles SHALL be easily tappable despite spanning multiple cells

### Accessibility

* Drag-and-drop SHALL have keyboard alternatives (select + arrow keys + confirm)
* Screen readers SHALL announce drag state and drop target validity
* Animations SHALL respect system reduced motion preferences
* Multi-day event announcements SHALL include span information ("3-day event starting today")

## Out of Scope

The following are explicitly out of scope for this specification:

* **Event resizing via drag** (edge-dragging to change duration) - future spec for desktop/web
* **Drag from overflow indicator** - events in "+N more" cannot be dragged
* **Multi-select drag** (dragging multiple events at once)
* **Drag to create new events**
* **Drag between different calendar views** (e.g., from month to day view)
* **Undo/redo for drag operations**
