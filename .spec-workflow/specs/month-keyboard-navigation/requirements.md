# Requirements Document: Month View Keyboard Navigation

## Introduction

This specification covers the complete keyboard navigation system for `MCalMonthView`, including a modal state machine (Navigation, Event, Move, Resize modes), event deletion via keyboard, and configurable key bindings. The spec is partially retroactive — Requirements 1–5 document the system as already implemented, while Requirement 6 (configurable key bindings) is new work.

The keyboard navigation system enables desktop and web users to fully operate the Month View calendar without a mouse. It follows a four-mode state machine where each mode captures specific keys and provides mode-appropriate behavior. The system respects the delegation pattern: the library handles display and navigation; the consumer handles CRUD operations via callbacks.

## Alignment with Product Vision

**From product.md:**
- **Accessibility First**: Keyboard navigation is essential for users who cannot or prefer not to use a mouse. Combined with Semantics-based screen reader announcements, this enables WCAG 2.1 AA compliance.
- **Customization First**: Configurable key bindings allow consumers to adapt shortcuts to their application context, avoiding conflicts with app-level shortcuts.
- **Separation of Concerns**: The library never creates, edits, or deletes events directly. Delete and create operations fire callbacks; the consumer performs the actual mutation on the controller. Critically, this delegation must not compromise performance — the controller's mutation APIs (e.g., `removeEvents`) must support O(1) per-event operations with targeted change tracking (`MCalEventChangeInfo.affectedEventIds`) so that consumer-driven mutations produce minimal, surgical view rebuilds rather than full re-layouts.
- **Platform Optimization**: Keyboard navigation is only relevant on platforms with hardware keyboards (desktop, web). The system is hidden on mobile platforms.

**From tech.md:**
- **Performance**: The raw key event handler short-circuits immediately based on current mode, avoiding unnecessary computation. Key bindings are resolved from a configuration object, not a linear scan.
- **Controller Pattern**: The `MCalEventController` provides `focusedDate`, `displayDate`, and event data. Mode state is maintained in the view's `State` object, consistent with the existing drag/resize state pattern.

## Requirements

### Requirement 1: Four-Mode State Machine

**User Story:** As a keyboard user, I want distinct navigation modes so that the same keys can serve different purposes depending on what I'm doing (browsing cells, cycling events, moving an event, or resizing an event).

#### Acceptance Criteria

1. The system SHALL support four keyboard modes: **Navigation Mode** (default), **Event Mode**, **Move Mode**, and **Resize Mode**.
2. WHEN the calendar first receives focus THEN it SHALL be in Navigation Mode.
3. WHEN the user presses Escape THEN the system SHALL transition one level back: Resize → Event, Move → Event, Event → Navigation.
4. WHEN in Event Mode and the user presses M THEN the system SHALL transition to Move Mode for the currently selected event.
5. WHEN in Event Mode and the user presses R THEN the system SHALL transition to Resize Mode for the currently selected event (only if `enableDragToResize` is true).
6. WHEN transitioning between modes THEN the system SHALL announce the mode change via `SemanticsService.sendAnnouncement` for screen readers.
7. WHEN in any mode other than Navigation THEN arrow keys, Tab, Enter, Space, and mode-specific keys SHALL be captured (return `KeyEventResult.handled`) and SHALL NOT propagate to parent widgets or the Flutter `Shortcuts` system.
8. WHEN `enableKeyboardNavigation` is false THEN all keyboard handling (except Escape for cancelling active drags) SHALL be disabled.

### Requirement 2: Navigation Mode

**User Story:** As a keyboard user, I want to navigate between calendar cells using arrow keys, and enter Event Mode when I find a cell with events.

#### Acceptance Criteria

1. WHEN in Navigation Mode THEN arrow keys SHALL move the focused date one cell in the pressed direction, respecting RTL layout direction for Left/Right.
2. WHEN the focused date moves beyond the visible month THEN the calendar SHALL navigate to the appropriate month and update `displayDate`.
3. WHEN the user presses Home THEN the focused date SHALL move to the first day of the current month.
4. WHEN the user presses End THEN the focused date SHALL move to the last day of the current month.
5. WHEN the user presses Page Up THEN the calendar SHALL navigate to the previous month.
6. WHEN the user presses Page Down THEN the calendar SHALL navigate to the next month.
7. WHEN the user presses Enter or Space on a cell that has events THEN the system SHALL transition to Event Mode with the first visible event selected.
8. WHEN the user presses Enter or Space on a cell that has no events THEN no mode transition SHALL occur.
9. The focused cell SHALL be visually indicated by `focusedDateBackgroundColor` from `MCalMonthThemeData`, which SHALL have a non-null default in `MCalThemeData`.

### Requirement 3: Event Mode

**User Story:** As a keyboard user, I want to cycle through visible events in a cell and activate, delete, move, or resize them using keyboard shortcuts.

#### Acceptance Criteria

1. WHEN entering Event Mode THEN the first visible event in display order SHALL be immediately selected (no intermediate "highlighted" state).
2. WHEN in Event Mode THEN Tab, Shift+Tab, Up arrow, and Down arrow SHALL cycle through visible events and the overflow indicator (if present) in display order.
3. Tab and Down arrow SHALL cycle forward; Shift+Tab and Up arrow SHALL cycle backward. Cycling SHALL wrap around.
4. Left and Right arrow keys SHALL be absorbed with no action (preventing cell navigation while in Event Mode).
5. WHEN the user presses Enter or Space on a selected event THEN `onEventTap` SHALL be fired with the event and display date, and the system SHALL exit all keyboard modes (return to Navigation Mode).
6. WHEN the user presses Enter or Space on the overflow indicator THEN `onOverflowTap` SHALL be fired, and the system SHALL exit all keyboard modes.
7. WHEN the user presses D, Delete, or Backspace on a selected event THEN `onDeleteEventRequested` SHALL be called (if non-null). If the callback returns `true` (sync or async), the system SHALL exit all keyboard modes. If `false`, the system SHALL remain in Event Mode.
8. WHEN `onDeleteEventRequested` is null THEN D, Delete, and Backspace SHALL be absorbed with no action.
9. The overflow indicator SHALL be visually indicated as focused/selected when keyboard-focused, matching the visual treatment of selected events.
10. Only events that are actually visible on screen (considering both `maxVisibleEventsPerDay` and cell height constraints) SHALL be cyclable. Hidden events SHALL NOT be reachable.
11. Custom `weekLayoutBuilder` implementations SHALL be able to report visible event counts via `MCalMonthWeekLayoutContext.layoutVisibleCounts`. If not reported, the system SHALL fall back to treating all events as visible.

### Requirement 4: Move Mode

**User Story:** As a keyboard user, I want to move a selected event to a different date cell using arrow keys.

#### Acceptance Criteria

1. WHEN entering Move Mode THEN the event's original position SHALL be recorded for potential cancellation.
2. WHEN in Move Mode THEN arrow keys SHALL move the event to adjacent cells, respecting RTL layout and date constraints.
3. WHEN the user presses Enter THEN the move SHALL be confirmed and the system SHALL exit all keyboard modes.
4. WHEN the user presses Escape THEN the move SHALL be cancelled (event reverts to original position) and the system SHALL return to Event Mode (not Navigation Mode).
5. WHEN the user presses R THEN the system SHALL transition from Move Mode to Resize Mode for the same event.
6. Move Mode SHALL use the existing `MCalDragHandler` infrastructure for validation and confirmation.

### Requirement 5: Resize Mode

**User Story:** As a keyboard user, I want to resize a selected event's start or end date using arrow keys.

#### Acceptance Criteria

1. WHEN entering Resize Mode THEN the default resize edge SHALL be the end edge.
2. WHEN in Resize Mode THEN the user SHALL be able to press S to switch to the start edge and E to switch to the end edge.
3. WHEN in Resize Mode THEN arrow keys SHALL extend or shrink the selected edge by one day.
4. WHEN the user presses Enter THEN the resize SHALL be confirmed and the system SHALL exit all keyboard modes.
5. WHEN the user presses Escape THEN the resize SHALL be cancelled (event reverts to original size) and the system SHALL return to Event Mode.
6. WHEN the user presses M THEN the system SHALL transition from Resize Mode to Move Mode for the same event.
7. Resize Mode SHALL use the existing `MCalDragHandler` resize infrastructure for validation and confirmation.

### Requirement 6: Configurable Key Bindings

**User Story:** As a developer, I want to customize which keys trigger which actions in each mode, so that I can avoid conflicts with my application's own keyboard shortcuts and adapt the calendar to my users' preferences.

#### Acceptance Criteria

1. The system SHALL provide an `MCalMonthKeyBindings` class with named properties for each action in each mode.
2. Each property SHALL hold a `Set<MCalKeyActivator>` defining which keys trigger that action.
3. `MCalMonthKeyBindings` SHALL provide a `const` default constructor that populates all properties with the current default keys.
4. `MCalMonthView` SHALL accept an optional `keyBindings` parameter of type `MCalMonthKeyBindings`. If null, the default bindings SHALL be used.
5. WHEN a developer provides custom key bindings THEN the raw key event handler SHALL check keys against the configured bindings instead of hardcoded `LogicalKeyboardKey` comparisons.
6. The following action slots SHALL be configurable:
   - **Navigation Mode**: `enterEventMode` (default: Enter, Space), `home` (default: Home), `end` (default: End), `pageUp` (default: PageUp), `pageDown` (default: PageDown)
   - **Event Mode**: `cycleForward` (default: Tab, ArrowDown), `cycleBackward` (default: Shift+Tab, ArrowUp), `activate` (default: Enter, Space), `delete` (default: D, Delete, Backspace), `enterMoveMode` (default: M), `enterResizeMode` (default: R), `exitEventMode` (default: Escape)
   - **Move Mode**: `confirmMove` (default: Enter, Space), `cancelMove` (default: Escape), `switchToResize` (default: R)
   - **Resize Mode**: `switchToStartEdge` (default: S), `switchToEndEdge` (default: E), `confirmResize` (default: Enter, Space), `switchToMove` (default: M), `cancelResize` (default: Escape)
7. Arrow keys for navigation (Navigation Mode cell movement, Move Mode event movement, Resize Mode edge adjustment) SHALL NOT be configurable — they are inherent to directional navigation.
8. `MCalMonthKeyBindings` SHALL provide a `copyWith` method for selective overrides.
9. Key bindings that require modifier detection (Shift+Tab) SHALL be handled via a `Set<MCalKeyActivator>` where `MCalKeyActivator` pairs a `LogicalKeyboardKey` with optional modifier flags, rather than a plain `Set<LogicalKeyboardKey>`.

### Requirement 7: Delete Callback Contract

**User Story:** As a developer, I want a delete callback that lets me confirm or cancel the deletion, so that I can show a confirmation dialog or enforce business rules before removing an event.

#### Acceptance Criteria

1. `MCalMonthView` SHALL provide an `onDeleteEventRequested` parameter of type `FutureOr<bool> Function(BuildContext, MCalEventTapDetails)?`.
2. WHEN the callback returns `true` (synchronously or asynchronously) THEN the system SHALL exit all keyboard modes.
3. WHEN the callback returns `false` THEN the system SHALL remain in the current mode.
4. WHEN the callback is `null` THEN the delete key SHALL be absorbed with no action.
5. The library SHALL NOT remove events from the controller. The consumer is responsible for calling `controller.removeEvents()` within the callback.
6. For synchronous deletes, the consumer SHALL be able to return `true` directly (no `Future` wrapping required) for optimal performance.

### Requirement 8: Navigation Mode — Create Event

**User Story:** As a keyboard user, I want to press N while browsing the calendar to create a new event on the focused date, without needing to hold modifier keys.

#### Acceptance Criteria

1. WHEN in Navigation Mode and the user presses N THEN `onCreateEventRequested` SHALL be called with the current `BuildContext` and the focused date (falling back to `displayDate` if no date is focused).
2. The callback signature SHALL be `FutureOr<bool> Function(BuildContext, DateTime)?` — the `BuildContext` allows the consumer to show a dialog; the `DateTime` is the focused cell's date; the `bool` return is reserved for future library behavior (e.g., auto-navigating focus to a newly created event). The library currently ignores the return value but SHALL await the `Future` if one is returned, keeping the path open for future use without a breaking API change.
3. WHEN `onCreateEventRequested` is null THEN N SHALL be absorbed with no action.
4. The N key for create SHALL only be active in Navigation Mode. Pressing N in Event Mode, Move Mode, or Resize Mode SHALL NOT trigger `onCreateEventRequested` (those modes already capture all keys to prevent unintended actions).
5. The N binding SHALL be configurable via `MCalMonthKeyBindings` as a new `createEvent` property (default: `[MCalKeyActivator(LogicalKeyboardKey.keyN)]`).
6. The existing `onCreateEventRequested: VoidCallback?` parameter SHALL be replaced with the new `FutureOr<bool> Function(BuildContext, DateTime)?` signature. The old `Cmd/Ctrl+N` global `Shortcuts`/`Actions` wiring (using `MCalMonthViewCreateEventIntent`) SHALL be removed entirely. Consumers who previously used `Cmd+N` via `keyboardShortcuts` should migrate to the new `createEvent` binding or handle it at the app level.
7. WHEN `onCreateEventRequested` is called THEN the calendar SHALL remain in Navigation Mode regardless of the return value. The `bool` return has no behavioral effect in the current version; this is intentional and documented to avoid surprising consumers.

## Non-Functional Requirements

### Code Architecture and Modularity
- The key bindings configuration class SHALL be in a separate file (`lib/src/models/mcal_month_key_bindings.dart`), not embedded in the 8000+ line month view file.
- The key bindings class SHALL be exported from `lib/multi_calendar.dart`.
- The state machine logic SHALL remain in `_MCalMonthViewState` as raw key event handling (not the Flutter `Shortcuts`/`Actions` system), because the same key triggers different behavior depending on the current mode.

### Performance
- Key event handling SHALL short-circuit immediately based on the current mode, avoiding evaluation of bindings for irrelevant modes.
- `MCalMonthKeyBindings` SHALL support `const` construction so default bindings incur no runtime allocation.
- **Callback-driven mutations must be efficient end-to-end.** While the library delegates CRUD operations to the consumer via callbacks (e.g., `onDeleteEventRequested`), the controller APIs that the consumer calls within those callbacks must support surgical mutations. Specifically:
  - `MCalEventController.removeEvents()` removes events by ID from a `Map`-based store — O(1) per event, no full cache rebuild.
  - Every mutation on the controller sets `lastChange` with `MCalEventChangeInfo` containing the `affectedEventIds` set and change type, enabling views to perform targeted rebuilds rather than full re-layouts.
  - The `FutureOr<bool>` return type on `onDeleteEventRequested` allows synchronous consumers to return `true` directly, avoiding `Future` microtask overhead and enabling the state transition (exit keyboard modes) to happen within the same frame.
  - A single `removeEvents` call triggers exactly one `notifyListeners()`, producing exactly one rebuild cycle — not multiple sequential redraws.

### Accessibility
- Every mode transition SHALL produce a `SemanticsService.sendAnnouncement` so screen readers announce the change.
- Every event cycle (Tab/Up/Down in Event Mode) SHALL announce the event title and position (e.g., "Team Meeting, 2 of 5").
- The keyboard shortcut guide in the example app's Accessibility tab SHALL be organized by mode with localized descriptions in all 5 supported languages.

### Usability
- The keyboard navigation system SHALL only be active on platforms with hardware keyboards (desktop, web). On mobile platforms, the keyboard shortcut guide SHALL be hidden.
