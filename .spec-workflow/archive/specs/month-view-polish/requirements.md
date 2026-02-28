# Requirements Document: Month View Polish

## Introduction

This specification addresses four remaining gaps in the MCalMonthView implementation: event resizing via edge-dragging, system reduced-motion preference integration, keyboard-based event moving as a drag-and-drop accessibility alternative, and enriched semantic labels for multi-day events. These items were identified during a comprehensive audit of all steering documents, archived specs, and the active recurring-events spec against the current implementation.

Event resizing was explicitly deferred by the month-view and month-view-enhancements-part-2 specs ("future spec for desktop/web") and is now ready for implementation. The remaining three items are accessibility and polish requirements from the month-view-enhancements-part-2 non-functional requirements that were not implemented during that spec's lifecycle.

## Alignment with Product Vision

* **Customization First**: Event resizing is configurable per platform and overridable by the developer. The animation behavior respects system preferences by default but remains developer-overridable.
* **Accessibility First**: Keyboard-based event moving provides a drag-and-drop alternative for users who cannot use pointer-based dragging. Multi-day semantic labels give screen reader users full context about event spans. Reduced motion respects system accessibility settings.
* **Mobile-First Design**: Event resizing defaults to disabled on phones (small touch targets) but enabled on tablets, desktops, and web — matching platform conventions.
* **Developer-Friendly**: The animation API is refactored to co-exist cleanly with the system accessibility preference, with a clear precedence model that is easy to understand.
* **Performance Conscious**: Edge-drag resizing uses the same debounced position tracking as the existing unified DragTarget architecture to maintain 60fps.

## Requirements

### Requirement 1: Event Edge-Drag Resizing

**User Story:** As a user, I want to drag the left or right edge of an event tile to change its start or end date, so that I can quickly adjust event durations without opening an editor.

#### Acceptance Criteria

##### Enabling and Disabling

1. WHEN configuring MCalMonthView THEN it SHALL accept an `enableEventResize` parameter of type `bool?` (nullable).
2. WHEN `enableEventResize` is `true` THEN edge-drag resizing SHALL be enabled regardless of platform.
3. WHEN `enableEventResize` is `false` THEN edge-drag resizing SHALL be disabled regardless of platform.
4. WHEN `enableEventResize` is `null` (the default) THEN the system SHALL auto-detect the platform and enable resizing on web, desktop (macOS, Windows, Linux), and tablets, but disable it on phones.
5. WHEN `enableDragAndDrop` is `false` THEN edge-drag resizing SHALL also be disabled, regardless of `enableEventResize`, because the resize interaction requires the drag infrastructure.
6. The system SHALL determine phone vs tablet using a width-based heuristic (e.g., shortest side at least 600dp indicates tablet) consistent with Material Design breakpoints. This is a rough heuristic and does not need to be exact.

##### Resize Interaction

7. WHEN the user drags the leading edge (left in LTR, right in RTL) of an event tile THEN the system SHALL adjust the event's **start date** while keeping the end date fixed.
8. WHEN the user drags the trailing edge (right in LTR, left in RTL) of an event tile THEN the system SHALL adjust the event's **end date** while keeping the start date fixed.
9. WHEN resizing THEN the system SHALL enforce a minimum event duration of 1 calendar day. The start date SHALL NOT be dragged past the end date, and vice versa.
10. WHEN calculating new dates during resize THEN the system SHALL use calendar-day arithmetic (`DateTime(year, month, day + delta)`) rather than `Duration`-based arithmetic, to avoid DST-related bugs (consistent with existing DST workarounds in keyboard navigation and drag-and-drop).
11. WHEN the user initiates a resize drag THEN the system SHALL provide a visual resize handle at the event tile edges. The handle SHALL be a small drag affordance (e.g., a vertical line or grip indicator) visible on hover or always visible, depending on platform.
12. WHEN the resize handle area is too small for reliable touch interaction on mobile THEN this is acceptable because `enableEventResize` defaults to `false` on phones. On tablets, event tiles are generally large enough for edge interaction.

##### Visual Feedback

13. WHEN a resize operation is in progress THEN the system SHALL show a preview of the new event span (similar to drop target tiles) that updates in real-time as the user drags.
14. WHEN a resize would result in an invalid state (e.g., less than 1 day, or rejected by validation callback) THEN the system SHALL show invalid visual feedback (consistent with existing drag-and-drop invalid styling).

##### Resize Validation and Completion

15. WHEN configuring MCalMonthView THEN it SHALL accept an `onResizeWillAccept` callback:
    * Signature: `bool Function(BuildContext context, MCalResizeWillAcceptDetails details)?`
    * `MCalResizeWillAcceptDetails` SHALL include: `event`, `proposedStartDate`, `proposedEndDate`, `resizeEdge` (enum: `start`, `end`)
    * Returns `true` to allow the resize, `false` to reject
    * Default: if callback not provided, resize is accepted
16. WHEN configuring MCalMonthView THEN it SHALL accept an `onEventResized` callback:
    * Signature: `bool Function(BuildContext context, MCalEventResizedDetails details)?`
    * `MCalEventResizedDetails` SHALL include: `event`, `oldStartDate`, `oldEndDate`, `newStartDate`, `newEndDate`, `resizeEdge`, `isRecurring`, `seriesId`
    * Returns `true` to confirm the resize, `false` to reject and revert
    * Default: if callback not provided, resize is confirmed
17. WHEN `onEventResized` returns `true` (or is not provided) THEN the controller SHALL update the event with the new dates.
18. WHEN `onEventResized` returns `false` THEN the event SHALL revert to its original dates.

##### Recurring Event Integration

19. WHEN the user resizes an occurrence of a recurring event THEN the controller SHALL create a `modified` exception for that occurrence (with the updated start/end dates), consistent with how drag-and-drop creates `rescheduled` exceptions for moves.
20. WHEN building `MCalEventResizedDetails` for a recurring occurrence THEN the system SHALL populate `isRecurring` and `seriesId` fields so the consuming app can handle recurring resizes differently if needed.

##### Cross-Week and Cross-Month Resize Behavior

21. WHEN the user drags an event edge past a week row boundary THEN the resize preview SHALL extend into the adjacent week row(s), consistent with how multi-day events already render across rows.
22. WHEN the user drags an event's end edge to the right boundary of the visible calendar grid THEN the system SHALL auto-navigate to the next month, allowing the resize to continue across month boundaries. Similarly, dragging the start edge to the left boundary SHALL auto-navigate to the previous month. Directional constraints apply: the end edge can only trigger forward navigation, the start edge can only trigger backward navigation.
23. WHEN auto-navigation occurs during a resize THEN the resize gesture SHALL persist across the page transition — the user SHALL NOT need to re-initiate the drag.
24. WHEN a resize is in progress THEN the PageView SHALL NOT respond to user-initiated swipe gestures. Only programmatic navigation (auto-navigation) SHALL be allowed during resize.
25. WHEN auto-navigation completes during resize THEN the system SHALL recompute the resize preview (highlighted cells) using the pointer's current position on the new month's grid.

##### RTL Support

26. WHEN the calendar is in RTL mode THEN the start edge SHALL be on the right and the end edge SHALL be on the left, consistent with the visual direction.

### Requirement 2: System Reduced Motion Preference

**User Story:** As a user with motion sensitivity, I want the calendar to automatically respect my system's reduced motion preference, so that animations are disabled without manual configuration.

#### Acceptance Criteria

##### Automatic Detection

1. WHEN the system's reduced motion accessibility setting is enabled THEN MCalMonthView SHALL automatically disable all animations (month transitions, drag feedback, etc.) without requiring the developer to set any property.
2. WHEN the system's reduced motion setting is disabled THEN MCalMonthView SHALL use animations normally (subject to the developer's configuration).
3. The system SHALL detect reduced motion via `MediaQuery.accessibilityFeaturesOf(context).reduceMotion` (or equivalent Flutter API).

##### Refactored Animation Control

4. The existing `enableAnimations` parameter SHALL be refactored to be a nullable `bool?` (from non-nullable `bool`):
   * WHEN `enableAnimations` is `null` (the new default) THEN the system SHALL respect the OS reduced motion preference: animations enabled when OS says normal, disabled when OS says reduce motion.
   * WHEN `enableAnimations` is `true` THEN animations SHALL be force-enabled regardless of OS setting (developer override).
   * WHEN `enableAnimations` is `false` THEN animations SHALL be force-disabled regardless of OS setting (developer override, backward compatible with current `false` usage).
5. The `animationDuration` and `animationCurve` parameters SHALL continue to work as before — they configure the animation when animations are active.
6. The `setDisplayDate(date, animate: true/false)` and `navigateToDateWithoutAnimation()` methods on the controller SHALL continue to work as before — `animate: false` always skips animation regardless of the `enableAnimations` setting.

##### Behavioral Impact

7. WHEN animations are disabled (by any mechanism) THEN month transitions SHALL be instant (jump, no slide).
8. WHEN animations are disabled THEN all other animated behaviors in MCalMonthView SHALL also be affected (consistent behavior).

### Requirement 3: Keyboard-Based Event Moving

**User Story:** As a keyboard user or screen reader user, I want to move events between dates using keyboard shortcuts, so that I have an accessible alternative to drag-and-drop.

#### Acceptance Criteria

##### Activation and Flow

1. WHEN `enableDragAndDrop` is `true` AND `enableKeyboardNavigation` is `true` THEN the keyboard event-move feature SHALL be available.
2. WHEN the user presses Enter or Space on a focused day cell containing events THEN the system SHALL enter "event selection mode" if there are movable events in the cell.
3. WHEN in event selection mode THEN the system SHALL visually highlight the selected event and provide a screen reader announcement ("Selected [event title], use arrow keys to move, Enter to confirm, Escape to cancel").
4. IF the cell contains multiple events THEN the system SHALL allow cycling through events with Tab/Shift+Tab before confirming selection with Enter.
5. WHEN an event is selected for moving THEN arrow keys SHALL move the event by one day (Left/Right) or one week (Up/Down), showing a preview of the new position (reusing the existing drop target tile and overlay system).
6. WHEN the user presses Enter THEN the move SHALL be confirmed (following the same `onEventDropped` callback flow as drag-and-drop).
7. WHEN the user presses Escape THEN the move SHALL be cancelled and the event SHALL return to its original position.
8. WHEN a keyboard move is confirmed for a recurring event occurrence THEN the system SHALL create a `modified` exception with the full updated event object, preserving any prior modifications (e.g., resizes). This is consistent with drag-and-drop behavior.

##### Validation

9. WHEN the user moves an event via keyboard to a new date THEN the system SHALL call `onDragWillAccept` (if provided) with the proposed new date range, reusing the same validation flow as drag-and-drop.
10. WHEN `onDragWillAccept` returns `false` THEN the move preview SHALL show invalid feedback and Enter SHALL not confirm the move.

##### Boundaries

11. WHEN keyboard-moving an event past the visible month boundary THEN the system SHALL navigate to the adjacent month (similar to edge navigation in drag-and-drop) and continue the move operation.
12. WHEN keyboard-moving an event THEN `minDate` and `maxDate` restrictions SHALL be respected.

##### Accessibility Announcements

13. WHEN the user moves an event via keyboard THEN the screen reader SHALL announce each proposed position ("Moving [event title] to [date]").
14. WHEN the move is confirmed THEN the screen reader SHALL announce "Moved [event title] to [date]".
15. WHEN the move is cancelled THEN the screen reader SHALL announce "Move cancelled".

### Requirement 4: Keyboard-Based Event Resizing

**User Story:** As a keyboard user or screen reader user, I want to resize events using keyboard shortcuts, so that I have an accessible alternative to edge-drag resizing.

#### Acceptance Criteria

##### Activation and Flow

1. WHEN an event is selected in keyboard event-move mode (Requirement 3) THEN the user SHALL be able to switch to resize mode by pressing `R` (for "resize").
2. WHEN resize mode activates THEN the system SHALL default to resizing the **end edge** (extending or shrinking the event's end date).
3. WHEN in resize mode THEN pressing `S` SHALL switch to resizing the **start edge**, and pressing `E` SHALL switch back to the **end edge**.
4. WHEN in resize mode THEN Left/Right arrow keys SHALL adjust the active edge by 1 day, and Up/Down arrow keys SHALL adjust it by 7 days.
5. WHEN the user presses Enter THEN the resize SHALL be confirmed (following the same `onEventResized` callback flow as edge-drag resizing).
6. WHEN the user presses Escape THEN the resize SHALL be cancelled and the event SHALL return to its original dates.
7. WHEN a keyboard resize is confirmed for a recurring event occurrence THEN the system SHALL create a `modified` exception, consistent with edge-drag resizing behavior.

##### Validation and Constraints

8. WHEN keyboard resizing THEN the minimum event duration of 1 day SHALL be enforced. Attempting to shrink past 1 day SHALL have no effect (the edge stops moving).
9. WHEN keyboard resizing THEN the system SHALL call `onResizeWillAccept` (if provided) with the proposed new dates at each step, reusing the same validation flow as edge-drag resizing.
10. WHEN `onResizeWillAccept` returns `false` THEN the resize preview SHALL show invalid feedback and Enter SHALL not confirm the resize.

##### Visual and Auditory Feedback

11. WHEN the user adjusts the event edge via keyboard THEN the system SHALL show the same preview (Layer 3/4) as edge-drag resizing.
12. WHEN the user adjusts the event edge via keyboard THEN the screen reader SHALL announce each proposed change ("Resizing [event title] end to [date], [N] days").
13. WHEN the resize is confirmed THEN the screen reader SHALL announce "Resized [event title] to [start date] through [end date]".
14. WHEN the resize is cancelled THEN the screen reader SHALL announce "Resize cancelled".

### Requirement 5: Multi-Day Event Semantic Span Information

**User Story:** As a screen reader user, I want multi-day event tiles to announce their span information (e.g., "3-day event, day 2 of 3"), so that I understand the full context of events that span multiple days.

#### Acceptance Criteria

1. WHEN a screen reader reads a multi-day event tile THEN the semantic label SHALL include span information in addition to the event title and time.
2. The span information SHALL include:
   * Total duration in days (e.g., "3-day event")
   * Position within the span (e.g., "day 2 of 3")
   * Whether this is the start, continuation, or end of the event
3. WHEN building the semantic label for a multi-day event THEN the system SHALL follow a similar pattern to the existing drop target semantic labels (`_buildDropTargetSemanticLabel`), which already include date range information for multi-day drags. Specifically, the label format SHALL be: `"{event title}, {time info}, {N}-day event, day {M} of {N}"` — e.g., "Team Offsite, All day, 3-day event, day 2 of 3".
4. WHEN a single-day event tile is read by a screen reader THEN the semantic label SHALL remain unchanged (no span info added).
5. The span information SHALL be localized using the existing `MCalLocalizations` infrastructure.
6. The `isStartOfSpan`, `isEndOfSpan`, and `spanLength` fields already available on `_EventTileWidget` SHALL be used to construct the span label — no new data plumbing is needed.

### Requirement 6: Recurring Event Move Preserves Modifications

**User Story:** As a user, I want to drag-and-drop a recurring event occurrence that I previously resized and have it keep the resized duration, so that moving an event does not undo my earlier modifications.

#### Acceptance Criteria

1. WHEN a recurring event occurrence has been previously modified (e.g., resized from 1 day to 3 days) and the user drag-and-drops it to a new date THEN the system SHALL preserve all prior modifications (duration, times, etc.) in the new position.
2. WHEN moving a recurring event occurrence via drag-and-drop THEN the system SHALL create a `modified` exception (not `rescheduled`) with the full updated event object, ensuring the complete event state is carried forward.
3. WHEN moving a recurring event occurrence via keyboard THEN the same behavior as criterion 2 SHALL apply.

### Requirement 7: Modified Recurring Event Visibility Across Months

**User Story:** As a user, I want to see a recurring event occurrence that was resized to span into an adjacent month appear correctly on both months, so that cross-month modifications are fully visible.

#### Acceptance Criteria

1. WHEN a `modified` recurrence exception changes an occurrence such that it spans into an adjacent month (e.g., original date Feb 1, modified to start Jan 22) THEN the controller SHALL include the modified event in query results for both the original month and the adjacent month.
2. WHEN querying events for a month range THEN the controller SHALL check `modified` exceptions whose original occurrence date falls outside the query range but whose modified event's dates overlap the range, and include them in the results.

### Requirement 8: Color Utilities and Drop Target Tile Styling

**User Story:** As a developer, I want the default drop target tile to be visually distinct from the original event tile, and I want color manipulation utilities available for custom styling.

#### Acceptance Criteria

##### Color Utilities

1. The system SHALL provide an `MCalColorUtils` extension on `Color` with `lighten`, `darken`, and `soften` methods.
2. `lighten(factor)` SHALL blend the color toward white, producing a fully opaque result equivalent to painting the color at `(1 - factor)` opacity over a white background.
3. `darken(factor)` SHALL blend the color toward black, producing a fully opaque result equivalent to painting the color at `(1 - factor)` opacity over a black background.
4. `soften(brightness, factor)` SHALL lighten the color in `Brightness.light` mode and darken it in `Brightness.dark` mode, adapting the visual softening to the current theme.
5. The color utilities SHALL be exported from the package barrel file for consumer use.

##### Drop Target Tile Default Styling

6. WHEN no explicit theme border is configured THEN the default drop target tile SHALL render with a 1-pixel solid border in the tile's applicable color and a softened (lightened in light mode, darkened in dark mode) opaque fill.
7. WHEN explicit theme border settings (`dropTargetTileBorderWidth`, `dropTargetTileBorderColor`) are configured THEN the system SHALL honour them and use the tile color as-is for the fill.
8. The drop target tile SHALL NOT use transparency for its fill color — all colors SHALL be fully opaque.

### Requirement 9: API Renames and Custom Resize Handle Builders

**User Story:** As a developer, I want consistent naming for drag-related parameters and the ability to customize resize handle visuals and positioning, so that I can build custom calendar styles where events have non-standard shapes.

#### Acceptance Criteria

##### API Renames

1. The `enableDragAndDrop` parameter SHALL be renamed to `enableDragToMove` across all public API surfaces, internal code, tests, examples, and documentation.
2. The `enableEventResize` parameter SHALL be renamed to `enableDragToResize` across all public API surfaces, internal code, tests, examples, and documentation.
3. Internal identifiers SHALL follow the rename: `_resolveEnableResize` → `_resolveDragToResize`, `enableResize` → `enableDragToResize`, `_enableDragAndDrop` → `_enableDragToMove`, `_enableResize` → `_enableDragToResize`.
4. The renames SHALL be purely cosmetic — no behavioral changes. Default values and types remain the same.

##### Custom Resize Handle Builder

5. WHEN configuring MCalMonthView THEN it SHALL accept a `resizeHandleBuilder` parameter of type `Widget Function(BuildContext, MCalResizeHandleContext)?`.
6. WHEN `resizeHandleBuilder` is provided THEN it SHALL replace the default 2×16px semi-transparent white bar visual indicator on both event tile handles AND drop-target preview tile handles.
7. The framework SHALL continue to handle hit testing, cursor feedback (`SystemMouseCursors.resizeColumn`), and `Positioned` layout — the builder only controls the visual indicator.
8. A new `MCalResizeHandleContext` class SHALL be provided containing: `edge` (`MCalResizeEdge`), `event` (`MCalCalendarEvent`), and `isDropTargetPreview` (`bool`).
9. The `MCalResizeHandleContext` SHALL be exported from the package barrel file.

##### Custom Resize Handle Inset

10. WHEN configuring MCalMonthView THEN it SHALL accept a `resizeHandleInset` parameter of type `double Function(MCalEventTileContext, MCalResizeEdge)?`.
11. WHEN `resizeHandleInset` is provided THEN the returned value (in logical pixels) SHALL shift both the visual handle AND the interactive hit area inward from the tile edge.
12. The callback SHALL receive the full `MCalEventTileContext` so it can differentiate all-day events from timed events, single-day from multi-day, etc.
13. The callback SHALL also receive the `MCalResizeEdge` indicating which edge is being positioned.
14. WHEN `resizeHandleInset` is `null` (the default) THEN handles SHALL be positioned at the tile edge (inset of 0).
15. The inset SHALL apply to both Layer 2 event tile handles and Layer 3 drop-target preview tile handles.

## Non-Functional Requirements

### Code Architecture and Modularity

* **Single Responsibility**: Resize logic SHALL be encapsulated in dedicated handler methods (or a resize handler class/mixin), separate from the drag-and-drop move logic in `MCalDragHandler`.
* **Modular Design**: The resize visual feedback (preview tiles, handle affordance) SHALL reuse existing infrastructure (drop target tiles, overlay system) where possible.
* **DST Safety**: All date arithmetic for resizing SHALL use `DateTime(year, month, day + delta)` constructor form, never `Duration(days: N)` addition, consistent with established DST-safe patterns throughout the codebase.
* **Backward Compatibility**: The `enableAnimations` refactor from `bool` to `bool?` SHALL not break existing code that passes `true` or `false` — both values retain their current meaning.

### Performance

* Resize interactions SHALL maintain 60fps rendering on mid-range mobile devices.
* Resize position updates SHALL use the same debounced approach as drag-and-drop (16ms threshold).
* Reduced motion detection via `MediaQuery` SHALL not cause additional rebuilds beyond what already occurs from the accessibility framework.

### Reliability

* Resize operations SHALL handle all edge cases: events at month boundaries, events on the first/last visible day, events spanning 1 day (at minimum), and rapid resize gestures.
* Keyboard event moving SHALL handle month boundary transitions seamlessly.
* All existing drag-and-drop tests SHALL continue to pass unchanged.

### Usability

* Resize handles SHALL be discoverable — visible on hover for pointer devices, or as a subtle visual indicator for touch.
* The keyboard event-move flow SHALL be intuitive and follow platform conventions for keyboard-based item manipulation.
* Screen reader announcements SHALL be concise but complete, avoiding excessive verbosity.

### Accessibility

* All new interactions (resize, keyboard move, keyboard resize) SHALL have appropriate semantic labels and announcements.
* Reduced motion SHALL be the default behavior when the OS setting is enabled — users should not need to configure anything.
* Keyboard event moving and keyboard event resizing provide complete alternatives to mouse/touch drag-and-drop and edge-drag resizing for users who cannot use pointer-based interactions.
