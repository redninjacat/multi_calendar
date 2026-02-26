# Requirements: Month/Day View API Alignment

## Introduction

The multi_calendar package has two primary calendar view widgets — `MCalDayView` (68 parameters) and `MCalMonthView` (56 parameters) — that were developed in separate specs over time. A comprehensive feature disparity analysis (`feature-disparities.md`) reveals significant API inconsistencies between the two views: naming differences (`showWeekNumber` vs `showWeekNumbers`), type mismatches (`DateFormat?` vs `String?`), missing callbacks (Day View lacks `onEventDoubleTap`, Month View lacks keyboard CRUD), inconsistent return types (`void` vs `bool` for drag callbacks), missing builder-with-default patterns, and inconsistent hover callback signatures.

This spec addresses these disparities to create a unified, consistent API surface across both views. The package is at version 0.0.1 and has not been published, so all changes — including breaking ones — are acceptable without migration concerns.

## Alignment with Product Vision

- **Developer-Friendly** (Principle #6): A consistent API across views reduces cognitive load — developers who learn one view's API can immediately use the other.
- **Customization First** (Principle #4): Adding builder-with-default pattern to Day View and time label positioning give developers more flexibility without forking.
- **Accessibility First** (Principle #7): Adding keyboard CRUD to Month View and consistent hover callbacks improve keyboard-only and assistive-technology usage.
- **Flexible Interaction** (Principle #10): Completing the handler matrix (tap, long-press, double-tap, hover for every interactive element) ensures every interaction type is available where platform-appropriate.
- **Mobile-First** (Principle #9): Adding swipe navigation to Day View brings it in line with Month View's touch-friendly UX.

## Requirements

### REQ-1: Month View Keyboard CRUD Operations

**User Story:** As a developer building an accessible calendar app, I want the Month View to support keyboard-based event creation, editing, and deletion so that keyboard-only users have the same CRUD capabilities as in the Day View.

#### Acceptance Criteria

1. WHEN a developer configures `MCalMonthView`, THEN it SHALL accept a `keyboardShortcuts: Map<ShortcutActivator, Intent>?` parameter matching the Day View's existing parameter
2. WHEN `keyboardShortcuts` is null, THEN the default keyboard shortcuts SHALL match Day View defaults: Cmd/Ctrl+N for create, Cmd/Ctrl+D / Delete / Backspace for delete, Cmd/Ctrl+E for edit
3. WHEN a developer configures `MCalMonthView`, THEN it SHALL accept `onCreateEventRequested`, `onDeleteEventRequested`, and `onEditEventRequested` callbacks with the same signatures as the Day View equivalents
4. WHEN the user presses the create shortcut (default: Cmd/Ctrl+N) with keyboard navigation enabled, THEN `onCreateEventRequested` SHALL be invoked with the currently focused date
5. WHEN the user presses the delete shortcut (default: Cmd/Ctrl+D, Delete, Backspace) with an event selected via keyboard, THEN `onDeleteEventRequested` SHALL be invoked with the selected event
6. WHEN the user presses the edit shortcut (default: Cmd/Ctrl+E) with an event selected via keyboard, THEN `onEditEventRequested` SHALL be invoked with the selected event
7. WHEN no event is selected AND the user presses delete or edit shortcuts, THEN the callbacks SHALL NOT fire

### REQ-2: Day View Drag Callback Return Types

**User Story:** As a developer, I want Day View drag callbacks to return `bool` so that I can confirm or revert drag-and-drop and resize operations, matching the Month View's behavior.

#### Acceptance Criteria

1. WHEN a developer configures `onEventDropped` on `MCalDayView`, THEN the callback type SHALL be `bool Function(BuildContext, MCalEventDroppedDetails)?` — matching Month View's signature
2. WHEN a developer configures `onEventResized` on `MCalDayView`, THEN the callback type SHALL be `bool Function(BuildContext, MCalEventResizedDetails)?` — matching Month View's signature
3. WHEN `onEventDropped` returns `false`, THEN the Day View SHALL revert the event to its original position/time
4. WHEN `onEventResized` returns `false`, THEN the Day View SHALL revert the event to its original duration
5. WHEN `onEventDropped` or `onEventResized` returns `true`, THEN the Day View SHALL accept the change
6. WHEN `onEventDropped` or `onEventResized` is null, THEN the Day View SHALL accept the change by default (same as returning `true`)

### REQ-3: Day View Complete Handler Coverage

**User Story:** As a developer, I want every interactive Day View sub-element to have a complete set of interaction handlers (tap, long-press, double-tap, hover) so that I can respond to all user gestures consistently.

#### Acceptance Criteria

##### Day Header Handlers
1. WHEN a developer configures `MCalDayView`, THEN it SHALL accept `onDayHeaderDoubleTap` with the same context details as `onDayHeaderTap`
2. WHEN a developer configures `MCalDayView`, THEN it SHALL accept `onHoverDayHeader` with appropriate context details and `BuildContext`

##### Time Label Handlers
3. WHEN a developer configures `MCalDayView`, THEN it SHALL accept `onTimeLabelLongPress` with the same context details as `onTimeLabelTap`
4. WHEN a developer configures `MCalDayView`, THEN it SHALL accept `onTimeLabelDoubleTap` with the same context details as `onTimeLabelTap`
5. WHEN a developer configures `MCalDayView`, THEN it SHALL accept `onHoverTimeLabel` with appropriate context details and `BuildContext`

##### Time Slot Handlers
6. WHEN a developer configures `MCalDayView`, THEN it SHALL accept `onTimeSlotDoubleTap` with the same context details as `onTimeSlotTap`

##### Event Handlers
7. WHEN a developer configures `MCalDayView`, THEN it SHALL accept `onEventDoubleTap` with the same context details as `onEventTap`, matching Month View's existing `onEventDoubleTap`

##### Overflow Handlers
8. WHEN a developer configures `MCalDayView`, THEN it SHALL accept `onOverflowDoubleTap` with the same context details as `onOverflowTap`
9. WHEN a developer configures `MCalDayView`, THEN it SHALL accept `onHoverOverflow` with appropriate context details and `BuildContext`

##### Empty Space Handlers
10. WHEN a developer configures `MCalDayView`, THEN it SHALL accept `onHoverEmptySpace` with appropriate context details and `BuildContext`

### REQ-4: Month View Complete Handler Coverage

**User Story:** As a developer, I want every interactive Month View sub-element to have a complete set of interaction handlers so that gesture handling is consistent across all elements.

#### Acceptance Criteria

##### Date Label Handlers
1. WHEN a developer configures `MCalMonthView`, THEN it SHALL accept `onDateLabelDoubleTap` with the same context details as `onDateLabelTap`
2. WHEN a developer configures `MCalMonthView`, THEN it SHALL accept `onHoverDateLabel` with appropriate context details and `BuildContext`

##### Overflow Handlers
3. WHEN a developer configures `MCalMonthView`, THEN it SHALL accept `onOverflowDoubleTap` with the same context details as `onOverflowTap`
4. WHEN a developer configures `MCalMonthView`, THEN it SHALL accept `onHoverOverflow` with appropriate context details and `BuildContext`

### REQ-5: Hover Callback Signature Consistency

**User Story:** As a developer, I want all hover callbacks across both views to include `BuildContext` as the first parameter so that I can access the widget tree (e.g., for showing tooltips, overlays, or accessing theme) when handling hover events.

#### Acceptance Criteria

1. WHEN `onHoverEvent` is defined on `MCalDayView`, THEN its signature SHALL be `void Function(BuildContext context, MCalCalendarEvent? event)?` — including `BuildContext` and nullable details (null on hover exit)
2. WHEN `onHoverTimeSlot` is defined on `MCalDayView`, THEN its signature SHALL be `void Function(BuildContext context, MCalTimeSlotContext? slotContext)?` — including `BuildContext`
3. WHEN `onHoverCell` is defined on `MCalMonthView`, THEN its signature SHALL be `void Function(BuildContext context, MCalDayCellContext? cellContext)?` — including `BuildContext`
4. WHEN `onHoverEvent` is defined on `MCalMonthView`, THEN its signature SHALL be `void Function(BuildContext context, MCalEventTileContext? tileContext)?` — including `BuildContext`
5. WHEN any new `onHover*` callback is added (per REQ-3 and REQ-4), THEN it SHALL follow the same signature pattern: `void Function(BuildContext context, T? details)?`
6. WHEN the pointer exits a hover target, THEN the callback SHALL be called with `null` details (preserving existing behavior)

### REQ-6: Day View Swipe Navigation

**User Story:** As a mobile user, I want to swipe left/right on the Day View to navigate between days so that the Day View feels as touch-friendly as the Month View.

#### Acceptance Criteria

1. WHEN a developer configures `MCalDayView`, THEN it SHALL accept `enableSwipeNavigation: bool` defaulting to `false`
2. WHEN a developer configures `MCalDayView`, THEN it SHALL accept `swipeNavigationDirection: MCalSwipeNavigationDirection?` matching the Month View's type
3. WHEN a developer configures `MCalDayView`, THEN it SHALL accept `onSwipeNavigation` callback that fires when the user completes a swipe gesture
4. WHEN `enableSwipeNavigation` is `true` AND the user swipes in the configured direction, THEN the Day View SHALL navigate to the adjacent day
5. WHEN the layout direction is RTL AND `enableSwipeNavigation` is `true`, THEN the swipe directions SHALL be reversed to match visual expectation
6. WHEN `enableSwipeNavigation` is `false` (default), THEN the Day View's existing scroll behavior SHALL be unaffected

### REQ-7: Day View Time Slot Interactivity Control

**User Story:** As a developer building a scheduling app, I want to disable interactions on specific time slots (e.g., no meetings before 9 AM, blocked lunch hours) so that business rules are enforced in the UI, matching the Month View's `cellInteractivityCallback`.

#### Acceptance Criteria

1. WHEN a developer configures `MCalDayView`, THEN it SHALL accept `timeSlotInteractivityCallback: bool Function(BuildContext, MCalTimeSlotInteractivityDetails)?`
2. WHEN the callback returns `false` for a time slot, THEN tap, long-press, and double-tap handlers SHALL NOT fire for that time slot
3. WHEN the callback returns `false` for a time slot, THEN drag-and-drop SHALL NOT accept drops into that time slot
4. WHEN the callback is null, THEN all time slots SHALL be interactive (preserving existing behavior)
5. WHEN `MCalTimeSlotInteractivityDetails` is provided, THEN it SHALL include the date, start time, and end time of the time slot

### REQ-8: Day View Builder-with-Default Pattern

**User Story:** As a developer customizing Day View tiles, I want my builder callbacks to receive the default widget as a parameter so that I can wrap or augment the defaults (add badges, borders, overlays) without recreating the entire widget from scratch, matching the Month View pattern.

#### Acceptance Criteria

1. WHEN `dayHeaderBuilder` is defined on `MCalDayView`, THEN it SHALL receive a third parameter: the default `Widget`
2. WHEN `timeLabelBuilder` is defined on `MCalDayView`, THEN it SHALL receive a third parameter: the default `Widget`
3. WHEN `gridlineBuilder` is defined on `MCalDayView`, THEN it SHALL receive a third parameter: the default `Widget`
4. WHEN `allDayEventTileBuilder` is defined on `MCalDayView`, THEN it SHALL receive an additional parameter: the default `Widget`
5. WHEN `timedEventTileBuilder` is defined on `MCalDayView`, THEN it SHALL receive an additional parameter: the default `Widget`
6. WHEN `currentTimeIndicatorBuilder` is defined on `MCalDayView`, THEN it SHALL receive a third parameter: the default `Widget`
7. WHEN `timeRegionBuilder` is defined on `MCalDayView`, THEN it SHALL receive a third parameter: the default `Widget`
8. WHEN `navigatorBuilder` is defined on `MCalDayView`, THEN it SHALL receive a third parameter: the default `Widget`
9. WHEN a builder is null, THEN the default widget SHALL be rendered (preserving existing behavior)
10. WHEN a builder returns the default widget unmodified, THEN the visual output SHALL be identical to the null-builder case
11. WHEN drag-related builders (`draggedTileBuilder`, `dragSourceTileBuilder`, `dropTargetTileBuilder`, `dropTargetOverlayBuilder`, `timeResizeHandleBuilder`) are defined, THEN they SHALL also receive the default widget parameter for consistency
12. WHEN `loadingBuilder` and `errorBuilder` are defined, THEN they SHALL also receive the default widget parameter for consistency

### REQ-9: Day View Resize Handle Inset

**User Story:** As a developer creating custom tile designs (e.g., centered pill shapes), I want to control the horizontal inset of resize handles so that handles align properly with my custom tile shapes, matching the Month View's `resizeHandleInset`.

#### Acceptance Criteria

1. WHEN a developer configures `MCalDayView`, THEN it SHALL accept `resizeHandleInset: double Function(MCalTimedEventTileContext, MCalResizeEdge)?` matching the conceptual equivalent of Month View's parameter
2. WHEN the callback is null, THEN resize handles SHALL be positioned at the tile edges (preserving existing behavior)
3. WHEN the callback returns a positive value, THEN the resize handle SHALL be inset from the tile edge by that amount

### REQ-10: API Naming Standardization

**User Story:** As a developer using both views, I want identically-functioning parameters to have identical names and types so that I do not have to remember view-specific naming quirks.

#### Acceptance Criteria

##### Week Number Naming
1. WHEN a developer configures `MCalDayView`, THEN the parameter SHALL be named `showWeekNumbers` (plural) — renaming from `showWeekNumber`
2. WHEN a developer uses the old name `showWeekNumber`, THEN it SHALL no longer compile (acceptable since package is unpublished at v0.0.1)

##### Drop Target Naming
3. WHEN a developer configures `MCalDayView`, THEN the parameter SHALL be named `showDropTargetTiles` — renaming from `showDropTargetPreview`
4. WHEN a developer configures `MCalDayView`, THEN the parameters `showDropTargetOverlay` and `dropTargetTilesAboveOverlay` SHALL continue to exist and match Month View's naming (these already match)

##### Date Format Type
5. WHEN a developer configures `dateFormat` on `MCalMonthView`, THEN the type SHALL be `DateFormat?` (from the `intl` package) — changing from `String?`
6. WHEN both views accept `dateFormat`, THEN the type SHALL be `DateFormat?` on both views

### REQ-11: Day View Week Number Builder

**User Story:** As a developer, I want to customize how the week number is displayed in the Day View so that I can match my app's visual style, just as Month View provides `weekNumberBuilder`.

#### Acceptance Criteria

1. WHEN a developer configures `MCalDayView`, THEN it SHALL accept `weekNumberBuilder: Widget Function(BuildContext, MCalWeekNumberContext, Widget)?` that receives the default widget
2. WHEN `weekNumberBuilder` is null AND `showWeekNumbers` is `true`, THEN the default week number display SHALL be rendered (preserving existing behavior)
3. WHEN `weekNumberBuilder` is provided AND `showWeekNumbers` is `true`, THEN the builder's return value SHALL be displayed

### REQ-12: Day View Navigation Callback Cleanup

**User Story:** As a developer, I want Day View to use the same navigation callback pattern as Month View (`onDisplayDateChanged`) instead of per-button callbacks so that handling navigation is consistent across views.

#### Acceptance Criteria

1. WHEN a developer configures `MCalDayView`, THEN `onNavigatePrevious`, `onNavigateNext`, and `onNavigateToday` SHALL be removed from the API
2. WHEN navigation occurs (via buttons, keyboard, or swipe), THEN `onDisplayDateChanged` SHALL fire with the new date — this callback already exists and SHALL remain
3. WHEN the built-in navigator's Previous/Next/Today buttons are pressed, THEN the Day View SHALL navigate automatically and fire `onDisplayDateChanged`

### REQ-13: firstDayOfWeek on Controller

**User Story:** As a developer, I want `firstDayOfWeek` to be defined on the `MCalEventController` rather than individual view widgets so that all views and the RRULE processor share a single source of truth for week start day.

#### Acceptance Criteria

1. WHEN a developer creates an `MCalEventController`, THEN it SHALL accept `firstDayOfWeek: int?` (0=Sunday, 1=Monday, ..., 6=Saturday)
2. WHEN `firstDayOfWeek` is null, THEN the controller SHALL default to the system locale's first day of week
3. WHEN `MCalMonthView` renders weekday headers and calendar grids, THEN it SHALL obtain `firstDayOfWeek` from the controller — the `firstDayOfWeek` parameter SHALL be removed from `MCalMonthView`
4. WHEN `MCalDayView` renders week numbers or any week-dependent layout, THEN it SHALL obtain `firstDayOfWeek` from the controller
5. WHEN the controller's `firstDayOfWeek` changes, THEN all connected views SHALL update their display

### REQ-14: Day View Time Label Position

**User Story:** As a developer, I want to control where time labels are positioned relative to the hour gridlines so that I can match my app's visual design, similar to how Month View offers `dateLabelPosition`.

#### Acceptance Criteria

1. WHEN a developer configures `MCalDayThemeData`, THEN it SHALL accept `timeLabelPosition: MCalTimeLabelPosition?`
2. WHEN `MCalTimeLabelPosition` is defined, THEN it SHALL be an enum with these values:
   - `topLeadingAbove` — leading-aligned, bottom of label aligned with the hour's top gridline
   - `topLeadingCentered` — leading-aligned, vertically centered with the hour's top gridline
   - `topLeadingBelow` — leading-aligned, top of label aligned with the hour's top gridline
   - `topTrailingAbove` — trailing-aligned, bottom of label aligned with the hour's top gridline
   - `topTrailingCentered` — trailing-aligned, vertically centered with the hour's top gridline
   - `topTrailingBelow` — trailing-aligned, top of label aligned with the hour's top gridline
   - `bottomLeadingAbove` — leading-aligned, bottom of label aligned with the hour's bottom gridline
   - `bottomTrailingAbove` — trailing-aligned, bottom of label aligned with the hour's bottom gridline
3. WHEN `timeLabelPosition` is null, THEN the default position SHALL be `topTrailingBelow` (matching current behavior: right-aligned, top of label at the gridline)
4. WHEN the layout direction is RTL, THEN "leading" SHALL mean right and "trailing" SHALL mean left (automatic via Flutter's `Directionality`)

### REQ-15: Day View Sub-Hour Time Labels

**User Story:** As a developer building a scheduling app with fine-grained time slots, I want to display time labels at sub-hour intervals (e.g., every 15 or 30 minutes) so that users can more easily identify specific time slots.

#### Acceptance Criteria

1. WHEN a developer configures `MCalDayView`, THEN it SHALL accept `showSubHourLabels: bool` defaulting to `false`
2. WHEN a developer configures `MCalDayView`, THEN it SHALL accept `subHourLabelInterval: Duration?` controlling the interval between sub-hour labels (e.g., 15 minutes, 30 minutes)
3. WHEN a developer configures `MCalDayView`, THEN it SHALL accept `subHourLabelBuilder: Widget Function(BuildContext, MCalTimeLabelContext, Widget)?` for customizing sub-hour label appearance
4. WHEN `showSubHourLabels` is `true` AND `subHourLabelInterval` is not null, THEN labels SHALL be displayed at the specified intervals within each hour
5. WHEN `subHourLabelBuilder` is null, THEN sub-hour labels SHALL use a default style (smaller/lighter than hour labels)
6. WHEN `showSubHourLabels` is `false` (default), THEN only hour-boundary labels SHALL be displayed (preserving existing behavior)

### REQ-16: Day View Theme Hover Colors

**User Story:** As a developer building a desktop calendar app, I want to style hover states for time slots and event tiles in the Day View so that the hover experience matches what Month View provides.

#### Acceptance Criteria

1. WHEN a developer configures `MCalDayThemeData`, THEN it SHALL accept `hoverTimeSlotBackgroundColor: Color?` for styling hovered time slot backgrounds
2. WHEN a developer configures `MCalDayThemeData`, THEN it SHALL accept `hoverEventBackgroundColor: Color?` for styling hovered event tile backgrounds
3. WHEN `hoverTimeSlotBackgroundColor` is non-null AND the user hovers over a time slot on a hover-capable platform, THEN the time slot SHALL display the specified background color
4. WHEN `hoverEventBackgroundColor` is non-null AND the user hovers over an event tile on a hover-capable platform, THEN the event tile SHALL display the specified background color
5. WHEN either hover color is null, THEN no hover background change SHALL occur (preserving existing behavior)

### REQ-17: Example App Updates

**User Story:** As a developer evaluating the package, I want the example app to showcase all newly added features and API changes so that I can understand how to use them.

#### Acceptance Criteria

1. WHEN the Day View Features tab is displayed, THEN it SHALL include controls for all new widget-level parameters: `enableSwipeNavigation`, `swipeNavigationDirection`, `timeSlotInteractivityCallback`, `showSubHourLabels`, `subHourLabelInterval`
2. WHEN the Day View Features tab fires gesture handlers, THEN it SHALL use all new handlers: `onEventDoubleTap`, `onDayHeaderDoubleTap`, `onTimeLabelLongPress`, `onTimeLabelDoubleTap`, `onTimeSlotDoubleTap`, `onOverflowDoubleTap`, and all new `onHover*` callbacks
3. WHEN the Month View Features tab fires gesture handlers, THEN it SHALL use all new handlers: `onDateLabelDoubleTap`, `onOverflowDoubleTap`, and all new `onHover*` callbacks
4. WHEN the Month View Features tab or Accessibility tab is displayed, THEN it SHALL showcase the new keyboard CRUD operations (`onCreateEventRequested`, `onDeleteEventRequested`, `onEditEventRequested`)
5. WHEN the Day View Theme tab is displayed, THEN it SHALL include controls for `timeLabelPosition`, `hoverTimeSlotBackgroundColor`, and `hoverEventBackgroundColor`
6. WHEN example app code references renamed parameters, THEN it SHALL use the new names (`showWeekNumbers`, `showDropTargetTiles`)
7. WHEN the Day View Features tab is displayed, THEN the per-button navigation callbacks (`onNavigatePrevious`, `onNavigateNext`, `onNavigateToday`) SHALL no longer be used — navigation SHALL rely on `onDisplayDateChanged`
8. WHEN example app ARB files need new localization keys for new features, THEN they SHALL be added to all 5 language files (en, es, fr, ar, he)
9. WHEN the example app configures `MCalEventController`, THEN `firstDayOfWeek` SHALL be set on the controller (not on individual views)

## Intentionally Deferred Items

The following disparities identified in `feature-disparities.md` are intentionally NOT addressed in this spec:

### Not Adding to Month View
1. **Per-button navigation callbacks** (`onNavigatePrevious`, `onNavigateNext`, `onNavigateToday`) — Instead of adding these to Month View, they are being *removed* from Day View (REQ-12) so both views use `onDisplayDateChanged` consistently.
2. **Scroll state tracking** (`onScrollChanged`) — Month View is page-based with no scrolling, so this is not applicable.
3. **Day header interactions** (`onDayHeaderTap`, `onDayHeaderLongPress`) — Month View has static weekday headers, not dynamic day headers. This is a domain-specific difference.

### Not Adding to Day View
4. **Date label interactions** (`onDateLabelTap`, `onDateLabelLongPress`) — Day View has a single day header, not per-cell date labels. This is a domain-specific difference.
5. **Advanced navigation state callbacks** (`onViewableRangeChanged`, `onFocusedDateChanged`, `onFocusedRangeChanged`) — Day View shows a single day with no range concept. These are domain-specific to Month View.
6. **`weekLayoutBuilder`** — The week layout builder controls multi-week grid layout logic specific to Month View's calendar grid. Day View does not have a multi-week layout.

## Non-Functional Requirements

### Code Architecture and Modularity

- **Consistent API Surface**: Parameters with identical purposes SHALL have identical names, types, and behavior across views
- **Single Responsibility**: New context/details classes for hover and interactivity callbacks SHALL follow the existing pattern of small, focused context objects
- **Builder Pattern Consistency**: All builders across both views SHALL follow the `(BuildContext, ContextData, Widget defaultWidget)` pattern
- **Controller Ownership**: Configuration that affects multiple views or the data layer (like `firstDayOfWeek`) SHALL live on the controller, not individual views

### Performance

- Adding `BuildContext` to hover callbacks SHALL NOT introduce additional widget rebuilds
- Builder-with-default pattern SHALL build the default widget lazily (only when the builder is non-null) to avoid constructing unused widgets
- Swipe navigation SHALL pre-load adjacent day content for smooth transitions, matching Month View's approach
- Sub-hour time labels SHALL be rendered efficiently using the same virtualization approach as existing time labels

### Backward Compatibility

- The package is at v0.0.1 and unpublished — all breaking changes (renamed parameters, changed callback signatures, removed parameters) are acceptable
- The `example/lib_backup/` directory from the previous reorganization spec may still exist and SHALL NOT be modified

### Reliability

- All existing tests SHALL be updated to reflect API changes (renamed parameters, new callback signatures)
- New tests SHALL verify: hover callbacks receive `BuildContext`, drag callbacks can return `false` to revert, builder-with-default receives the correct default widget, swipe navigation respects RTL, keyboard CRUD works in Month View
- `flutter analyze` SHALL report zero errors after all changes
- All 5 localization files (en, es, fr, ar, he) SHALL remain in sync after adding new keys

### Testing

- RTL behavior SHALL be tested for swipe navigation direction reversal
- Keyboard CRUD in Month View SHALL be tested with custom shortcut overrides
- Builder-with-default SHALL be tested to confirm the default widget matches the null-builder output
- Time label positioning SHALL be tested for all 8 positions in both LTR and RTL
