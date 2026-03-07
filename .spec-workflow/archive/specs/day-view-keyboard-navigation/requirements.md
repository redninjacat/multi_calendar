# Requirements Document: Day View Keyboard Navigation

## Introduction

This specification covers a complete keyboard navigation system for `MCalDayView`, implementing the same four-mode state machine used in `MCalMonthView` (Navigation, Event, Move, Resize modes) but adapted for the Day View's time-slot-based layout with distinct all-day and time grid sections. The system replaces the current ad-hoc keyboard handling (scroll-based arrows, Ctrl/Cmd+modifier shortcuts via `Shortcuts`/`Actions`) with a modal, mode-aware raw key handler and configurable key bindings via `MCalDayKeyBindings`.

The Day View's keyboard navigation differs from the Month View's in several key ways:
- **Vertical navigation** through time slots rather than 2D cell navigation
- **Two-section layout**: An all-day events section and a scrollable time grid, with dedicated keys (A/T) to jump between them
- **Event type conversion**: A single toggle key (X) in Event Mode to request conversion of events between all-day and timed types via a delegation callback
- **Time-based movement and resizing**: Move and resize operations work in time-slot increments for timed events and day increments for all-day events

The keyboard navigation system enables desktop and web users to fully operate the Day View calendar without a mouse. It follows the same delegation pattern as the Month View: the library handles display and navigation; the consumer handles CRUD operations via callbacks.

## Alignment with Product Vision

**From product.md:**
- **Accessibility First**: Keyboard navigation is essential for users who cannot or prefer not to use a mouse. Combined with Semantics-based screen reader announcements, this enables WCAG 2.1 AA compliance for the Day View, matching the Month View's accessibility level.
- **Customization First**: Configurable key bindings (via `MCalDayKeyBindings`) allow consumers to adapt shortcuts to their application context, consistent with the Month View's `MCalMonthKeyBindings`.
- **Separation of Concerns**: The library never creates, edits, deletes, or type-converts events directly. All mutation operations fire callbacks; the consumer performs the actual mutation on the controller.
- **Platform Optimization**: Keyboard navigation is only relevant on platforms with hardware keyboards (desktop, web). The system is hidden on mobile platforms.

**From tech.md:**
- **Performance**: The raw key event handler short-circuits immediately based on current mode. Key bindings are resolved from a configuration object. Controller mutations support O(1) per-event operations with targeted change tracking.
- **Controller Pattern**: The `MCalEventController` provides `displayDate` and event data. Mode state is maintained in the view's `State` object.
- **Consistency**: The Day View keyboard system mirrors the Month View's patterns (state machine, key bindings model, callback signatures) so that developers learning one view can immediately use the other.

## Requirements

### Requirement 1: Four-Mode State Machine

**User Story:** As a keyboard user, I want distinct navigation modes so that the same keys can serve different purposes depending on what I'm doing (browsing time slots, cycling events, moving an event, or resizing an event).

#### Acceptance Criteria

1. The system SHALL support four keyboard modes: **Navigation Mode** (default), **Event Mode**, **Move Mode**, and **Resize Mode**.
2. WHEN the calendar first receives focus THEN it SHALL be in Navigation Mode.
3. WHEN the user presses Escape THEN the system SHALL transition one level back: Resize → Event, Move → Event, Event → Navigation.
4. WHEN in Event Mode and the user presses M THEN the system SHALL transition to Move Mode for the currently selected event.
5. WHEN in Event Mode and the user presses R THEN the system SHALL transition to Resize Mode for the currently selected event (only if resize is enabled).
6. WHEN transitioning between modes THEN the system SHALL announce the mode change via `SemanticsService.sendAnnouncement` for screen readers.
7. WHEN in any mode other than Navigation THEN arrow keys, Tab, Enter, Space, and mode-specific keys SHALL be captured (return `KeyEventResult.handled`) and SHALL NOT propagate to parent widgets or the Flutter `Shortcuts` system.
8. WHEN `enableKeyboardNavigation` is false THEN all keyboard handling (except Escape for cancelling active drags) SHALL be disabled.

### Requirement 2: Navigation Mode

**User Story:** As a keyboard user, I want to navigate between time slots and the all-day section using arrow keys, jump between sections, and enter Event Mode when I find events to interact with.

#### Acceptance Criteria

1. WHEN in Navigation Mode THEN Up and Down arrow keys SHALL move the focused slot one time-slot increment in the pressed direction.
2. The all-day section SHALL act as a single focusable slot above the first time slot. WHEN the focused slot is the first time slot and the user presses Up THEN focus SHALL move to the all-day section. WHEN the all-day section is focused and the user presses Down THEN focus SHALL move to the first time slot.
3. WHEN the user presses Home THEN the focused slot SHALL move to the first visible time slot of the day. The all-day section is not considered a time slot for Home; the user presses Up or A to reach it.
4. WHEN the user presses End THEN the focused slot SHALL move to the last visible time slot of the day.
5. WHEN the user presses Page Up THEN the calendar SHALL navigate to the previous day.
6. WHEN the user presses Page Down THEN the calendar SHALL navigate to the next day.
7. WHEN the user presses Enter or Space and the current day has events (all-day or timed) THEN the system SHALL transition to Event Mode with the first event in display order selected.
8. WHEN the user presses Enter or Space and the current day has no events THEN no mode transition SHALL occur.
9. WHEN the focused time slot is outside the visible scroll area THEN the view SHALL auto-scroll to reveal the focused slot.
10. The focused slot SHALL be visually indicated (e.g., via a background highlight or border), configurable through `MCalDayThemeData`.
11. WHEN the user presses A THEN focus SHALL jump to the all-day section, regardless of the current focused slot.
12. WHEN the user presses T THEN focus SHALL jump to the time grid. If focus was previously in the time grid, it SHALL return to the last focused time slot. If focus was never in the time grid, it SHALL focus the slot nearest to the current time of day (or the first visible slot if current time is outside the visible range).
13. Left and Right arrow keys in Navigation Mode SHALL NOT be handled — they SHALL pass through as `KeyEventResult.ignored`.

### Requirement 3: Event Mode

**User Story:** As a keyboard user, I want to cycle through visible events on the current day and activate, delete, move, resize, or convert them using keyboard shortcuts.

#### Acceptance Criteria

1. WHEN entering Event Mode THEN the first event in display order SHALL be immediately selected. Display order is: all-day events first (in their display order), then timed events (sorted by start time).
2. WHEN in Event Mode THEN Tab, Shift+Tab, Up arrow, and Down arrow SHALL cycle through events in display order. Cycling SHALL wrap around.
3. Tab and Down arrow SHALL cycle forward; Shift+Tab and Up arrow SHALL cycle backward.
4. Left and Right arrow keys SHALL be absorbed with no action (preventing unintended side effects while in Event Mode).
5. WHEN the user presses Enter or Space on a selected event THEN `onEventTap` SHALL be fired with the event details, and the system SHALL exit all keyboard modes (return to Navigation Mode).
6. WHEN the user presses D, Delete, or Backspace on a selected event THEN `onDeleteEventRequested` SHALL be called (if non-null). If the callback returns `true` (sync or async), the system SHALL exit all keyboard modes. If `false`, the system SHALL remain in Event Mode.
7. WHEN `onDeleteEventRequested` is null THEN D, Delete, and Backspace SHALL be absorbed with no action.
8. WHEN the user presses X on a selected event THEN `onEventTypeConversionRequested` SHALL be called (if non-null). The library SHALL determine the conversion direction from the event's current `isAllDay` state: if timed, `toAllDay` is `true`; if all-day, `toAllDay` is `false`. If the callback returns `true`, the system SHALL exit all keyboard modes. If `false`, the system SHALL remain in Event Mode.
9. WHEN converting from all-day to timed (X pressed on an all-day event) THEN the library SHALL provide a `suggestedStartTime` derived from the current time of day on the display date (or the start of the visible time range if current time is outside). WHEN converting from timed to all-day THEN `suggestedStartTime` SHALL be `null`.
10. WHEN `onEventTypeConversionRequested` is null THEN X SHALL be absorbed with no action.
11. WHEN the selected event changes (via Tab/Arrow cycling) THEN the view SHALL auto-scroll to reveal the selected event if it is a timed event outside the visible scroll area.
12. WHEN cycling reaches an all-day event THEN the all-day section SHALL be visible. WHEN cycling reaches a timed event THEN the time grid SHALL scroll to reveal it.
13. For the all-day section, only events that are actually displayed (not hidden behind the overflow indicator) SHALL be cyclable. The overflow indicator itself SHALL be cyclable (matching Month View behavior). For the time grid, all timed events on the day SHALL be cyclable regardless of scroll position — the view auto-scrolls to reveal them per criterion 11.
14. WHEN the user presses Enter or Space on the overflow indicator THEN `onOverflowTap` SHALL be fired, and the system SHALL exit all keyboard modes.

### Requirement 4: Move Mode

**User Story:** As a keyboard user, I want to move a selected event to a different time slot or day using arrow keys.

#### Acceptance Criteria

1. WHEN entering Move Mode THEN the event's original position SHALL be recorded for potential cancellation.
2. WHEN in Move Mode and the selected event is a timed event THEN Up and Down arrow keys SHALL move the event by one time-slot increment.
3. WHEN in Move Mode and the selected event is an all-day event THEN Up and Down arrow keys SHALL be absorbed with no action (all-day events have no time component to adjust).
4. WHEN in Move Mode THEN Left and Right arrow keys SHALL move the event to the previous or next day, respecting RTL layout direction. For timed events, the time-of-day SHALL be preserved. For all-day events, only the date SHALL change.
5. WHEN the user presses Enter or Space THEN the move SHALL be confirmed and the system SHALL exit all keyboard modes.
6. WHEN the user presses Escape THEN the move SHALL be cancelled (event reverts to original position) and the system SHALL return to Event Mode (not Navigation Mode).
7. WHEN the user presses R THEN the system SHALL cancel the current move (reverting to original position) and transition to Resize Mode for the same event.
8. Move Mode SHALL use the existing `MCalDragHandler` infrastructure for validation and confirmation, consistent with the Month View's Move Mode.
9. WHEN a timed event is moved to a time outside the visible scroll area THEN the view SHALL auto-scroll to keep the event visible.

### Requirement 5: Resize Mode

**User Story:** As a keyboard user, I want to resize a selected event's start or end time using arrow keys.

#### Acceptance Criteria

1. WHEN entering Resize Mode THEN the default resize edge SHALL be the end edge.
2. WHEN in Resize Mode THEN the user SHALL be able to press S to switch to the start edge and E to switch to the end edge.
3. WHEN in Resize Mode and the selected event is a timed event THEN Up and Down arrow keys SHALL extend or shrink the selected edge by one time-slot increment.
4. WHEN in Resize Mode and the selected event is an all-day event THEN Up and Down arrow keys SHALL be absorbed with no action. Left and Right arrow keys SHALL extend or shrink the selected edge by one day, respecting RTL layout direction.
5. WHEN in Resize Mode and the selected event is a timed event THEN Left and Right arrow keys SHALL extend or shrink the selected edge by one day, respecting RTL layout direction.
6. WHEN the user presses Enter or Space THEN the resize SHALL be confirmed and the system SHALL exit all keyboard modes.
7. WHEN the user presses Escape THEN the resize SHALL be cancelled (event reverts to original size) and the system SHALL return to Event Mode.
8. WHEN the user presses M THEN the system SHALL cancel the current resize (reverting to original size) and transition to Move Mode for the same event.
9. Resize Mode SHALL use the existing `MCalDragHandler` resize infrastructure for validation and confirmation.

### Requirement 6: Configurable Key Bindings

**User Story:** As a developer, I want to customize which keys trigger which actions in each mode, so that I can avoid conflicts with my application's own keyboard shortcuts and adapt the calendar to my users' preferences.

#### Acceptance Criteria

1. The system SHALL provide an `MCalDayKeyBindings` class with named properties for each action in each mode.
2. Each property SHALL hold a `List<MCalKeyActivator>` defining which keys trigger that action, reusing the existing `MCalKeyActivator` class from `mcal_month_key_bindings.dart`.
3. `MCalDayKeyBindings` SHALL provide a `const` default constructor that populates all properties with the default keys.
4. `MCalDayView` SHALL accept an optional `keyBindings` parameter of type `MCalDayKeyBindings`. If null, the default bindings SHALL be used.
5. WHEN a developer provides custom key bindings THEN the raw key event handler SHALL check keys against the configured bindings instead of hardcoded `LogicalKeyboardKey` comparisons.
6. The following action slots SHALL be configurable:
   - **Navigation Mode**: `enterEventMode` (default: Enter, Space), `home` (default: Home), `end` (default: End), `pageUp` (default: PageUp), `pageDown` (default: PageDown), `createEvent` (default: N), `jumpToAllDay` (default: A), `jumpToTimeGrid` (default: T)
   - **Event Mode**: `cycleForward` (default: Tab, ArrowDown), `cycleBackward` (default: Shift+Tab, ArrowUp), `activate` (default: Enter, Space), `delete` (default: D, Delete, Backspace), `enterMoveMode` (default: M), `enterResizeMode` (default: R), `exitEventMode` (default: Escape), `convertEventType` (default: X)
   - **Move Mode**: `confirmMove` (default: Enter, Space), `cancelMove` (default: Escape), `switchToResize` (default: R)
   - **Resize Mode**: `switchToStartEdge` (default: S), `switchToEndEdge` (default: E), `confirmResize` (default: Enter, Space), `switchToMove` (default: M), `cancelResize` (default: Escape)
7. Arrow keys for directional navigation (Navigation Mode slot movement, Move Mode event movement, Resize Mode edge adjustment) SHALL NOT be configurable — they are inherent to directional navigation.
8. `MCalDayKeyBindings` SHALL provide a `copyWith` method for selective overrides.

### Requirement 7: Delete Callback Contract

**User Story:** As a developer, I want a delete callback that lets me confirm or cancel the deletion, so that I can show a confirmation dialog or enforce business rules before removing an event.

#### Acceptance Criteria

1. `MCalDayView` SHALL update its `onDeleteEventRequested` parameter to type `FutureOr<bool> Function(BuildContext, MCalEventTapDetails)?`, matching the Month View's signature.
2. WHEN the callback returns `true` (synchronously or asynchronously) THEN the system SHALL exit all keyboard modes.
3. WHEN the callback returns `false` THEN the system SHALL remain in the current mode.
4. WHEN the callback is `null` THEN the delete key SHALL be absorbed with no action.
5. The library SHALL NOT remove events from the controller. The consumer is responsible for calling `controller.removeEvents()` within the callback.
6. For synchronous deletes, the consumer SHALL be able to return `true` directly (no `Future` wrapping required) for optimal performance.
7. The legacy `onDeleteEventRequested: void Function(MCalCalendarEvent event)?` signature SHALL be replaced.
8. The legacy `onEditEventRequested` parameter SHALL be removed — edit functionality is covered by `onEventTap`.

### Requirement 8: Create Event Callback

**User Story:** As a keyboard user, I want to press N while browsing the calendar to create a new event at the focused time, without needing to hold modifier keys.

#### Acceptance Criteria

1. WHEN in Navigation Mode and the user presses N THEN `onCreateEventRequested` SHALL be called with the current `BuildContext` and a `DateTime` representing the focused time slot's start time (or the display date at midnight if focus is on the all-day section).
2. The callback signature SHALL be `FutureOr<bool> Function(BuildContext, DateTime)?`, matching the Month View's signature.
3. WHEN `onCreateEventRequested` is null THEN N SHALL be absorbed with no action.
4. N SHALL only be active in Navigation Mode. Pressing N in Event Mode, Move Mode, or Resize Mode SHALL NOT trigger `onCreateEventRequested`.
5. The legacy `onCreateEventRequested: VoidCallback?` parameter SHALL be replaced with the new signature.
6. WHEN `onCreateEventRequested` is called THEN the calendar SHALL remain in Navigation Mode regardless of the return value.

### Requirement 9: Event Type Conversion Callback

**User Story:** As a keyboard user, I want to convert a timed event to all-day or vice versa using a single keypress, so that I can quickly change an event's type without leaving the keyboard.

#### Acceptance Criteria

1. `MCalDayView` SHALL provide an `onEventTypeConversionRequested` parameter of type `FutureOr<bool> Function(BuildContext, MCalCalendarEvent event, bool toAllDay, DateTime? suggestedStartTime)?`.
2. The library SHALL determine the conversion direction automatically from the event's `isAllDay` state. `toAllDay` SHALL be `true` when the event is currently timed, and `false` when the event is currently all-day.
3. WHEN converting from all-day to timed (`toAllDay: false`) THEN `suggestedStartTime` SHALL be a `DateTime` representing the current time of day on the display date (or the start of the visible time range if current time is outside the range). WHEN converting from timed to all-day (`toAllDay: true`) THEN `suggestedStartTime` SHALL be `null`.
4. WHEN the callback returns `true` (synchronously or asynchronously) THEN the system SHALL exit all keyboard modes.
5. WHEN the callback returns `false` THEN the system SHALL remain in Event Mode.
6. WHEN the callback is `null` THEN the X key SHALL be absorbed with no action.
7. The library SHALL NOT modify events directly. The consumer is responsible for updating the event's `isAllDay` flag and adjusting start/end times within the callback.

### Requirement 10: Legacy Shortcuts System Removal

**User Story:** As a developer, I want a consistent keyboard API across Month and Day views, with no legacy Cmd/Ctrl+key shortcuts remaining.

#### Acceptance Criteria

1. The following SHALL be removed from `MCalDayView`:
   - `MCalDayViewCreateEventIntent` class
   - `MCalDayViewDeleteEventIntent` class
   - `MCalDayViewEditEventIntent` class
   - `MCalDayViewKeyboardMoveIntent` class
   - `MCalDayViewKeyboardResizeIntent` class
   - `keyboardShortcuts` parameter
   - `onEditEventRequested` parameter
   - `_buildDefaultShortcuts()`, `_buildShortcutsMap()`, `_buildActionsMap()` methods
   - The `Shortcuts` and `Actions` widget wrappers in `build()`
2. The removal SHALL be coordinated so that the new state machine replaces the old system without a gap in functionality.
3. The `lib/multi_calendar.dart` export list SHALL be updated to remove the deleted intent classes from the `show` clause.
4. Existing consumers using `Cmd+N`, `Cmd+D`, `Cmd+E`, `Ctrl+M`, `Ctrl+R` SHALL migrate to the new configurable key bindings or handle those modifier combinations at the app level.

## Non-Functional Requirements

### Code Architecture and Modularity
- The `MCalDayKeyBindings` class SHALL be in a separate file (`lib/src/models/mcal_day_key_bindings.dart`), not embedded in the day view file.
- The `MCalDayKeyBindings` class SHALL be exported from `lib/multi_calendar.dart`.
- The `MCalKeyActivator` class SHALL be shared between Month and Day views — it remains in `mcal_month_key_bindings.dart` (or is extracted to a shared file if the design phase determines that is cleaner).
- The state machine logic SHALL remain in `_MCalDayViewState` (the public `MCalDayViewState`) as raw key event handling (not the Flutter `Shortcuts`/`Actions` system), matching the Month View's approach.

### Performance
- Key event handling SHALL short-circuit immediately based on the current mode, avoiding evaluation of bindings for irrelevant modes.
- `MCalDayKeyBindings` SHALL support `const` construction so default bindings incur no runtime allocation.
- The `FutureOr<bool>` pattern on callbacks allows synchronous consumers to return `true` directly, avoiding `Future` microtask overhead.

### Accessibility
- Every mode transition SHALL produce a `SemanticsService.sendAnnouncement` using localized strings from `MCalLocalizations` so screen readers announce the change.
- Every event cycle (Tab/Up/Down in Event Mode) SHALL announce the event title and position using localized strings (e.g., "Team Meeting, 2 of 5").
- Section transitions (A/T keys in Navigation Mode) SHALL announce the section name using localized strings from `MCalLocalizations` (e.g., "All-day section" or "Time grid, 10:00 AM"). Announcement strings SHALL be added to all 5 supported language ARB files (`en`, `ar`, `es`, `fr`, `he`).
- The keyboard shortcut guide in the example app's Day View Accessibility tab SHALL be organized by mode with localized descriptions in all 5 supported languages.

### Consistency with Month View
- The four-mode state machine SHALL follow the same transition rules as the Month View.
- Key bindings that are conceptually identical across views (Enter to confirm, Escape to cancel, M for Move, R for Resize, D for Delete, N for Create, S/E for edge switching) SHALL use the same default keys.
- Callback signatures SHALL match the Month View's patterns (`FutureOr<bool>` for destructive/mutative actions, `MCalEventTapDetails` for event context).

### Usability
- The keyboard navigation system SHALL only be active on platforms with hardware keyboards (desktop, web). On mobile platforms, the keyboard shortcut guide SHALL be hidden.
