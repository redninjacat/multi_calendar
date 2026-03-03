# Design Document: Month View Keyboard Navigation

## Overview

This design covers the complete keyboard navigation system for `MCalMonthView`. The system uses a four-mode state machine (Navigation, Event, Move, Resize) implemented as raw key event handling in `_MCalMonthViewState`, with mode state tracked via boolean flags and index fields. The design is partially retroactive — the state machine, mode handlers, delete callback, and visible-count-aware cycling are already implemented. The new work is configurable key bindings via `MCalKeyActivator` and `MCalMonthKeyBindings`.

The keyboard navigation system sits between the Flutter focus system and the existing `Shortcuts`/`Actions` layer. Raw key events are intercepted via `Focus.onKeyEvent` before they reach `Shortcuts`, allowing the same physical key to trigger different behavior depending on the current mode. The `Shortcuts` system is reserved for mode-independent global shortcuts (currently only Cmd+N for create).

## Steering Document Alignment

### Technical Standards (tech.md)

- **Controller Pattern**: Keyboard navigation reads `focusedDate` and `displayDate` from `MCalEventController` and modifies them via controller setters. Mode state is maintained in `_MCalMonthViewState`, consistent with the existing drag/resize state pattern (e.g., `_draggedEvent`, `_resizeEvent`).
- **Performance**: Key handlers short-circuit immediately by mode — if we're in Navigation Mode, Event Mode handler code is never reached. `MCalMonthKeyBindings` supports `const` construction for zero runtime allocation. Controller mutations (e.g., `removeEvents` in delete callbacks) are O(1) per event with targeted `MCalEventChangeInfo` for surgical view rebuilds.
- **DST-safe arithmetic**: Move Mode and Resize Mode use `addDays()` from `date_utils.dart` for calendar-day shifts, never `Duration(days: n)`.
- **Accessibility**: Every mode transition and event cycle produces a `SemanticsService.sendAnnouncement`. The example app's Accessibility tab organizes keyboard shortcuts by mode with localized descriptions in all 5 languages.

### Project Structure (structure.md)

- **File placement**: The new `MCalKeyActivator` and `MCalMonthKeyBindings` classes go in `lib/src/models/mcal_month_key_bindings.dart`, following the models directory convention for pure data classes.
- **Naming**: Public classes use the `MCal` prefix: `MCalKeyActivator`, `MCalMonthKeyBindings`. File uses `snake_case`.
- **Export**: Added to `lib/multi_calendar.dart` alongside other model exports.
- **Code size**: The key bindings file is a pure data class with ~150 lines — well under the 500-line limit. The month view file is already large (~8500 lines) but the key handler methods are organized by mode and each stays under the 50-line function limit where possible.

## Code Reuse Analysis

### Existing Components to Leverage

- **`_MCalMonthViewState` keyboard fields** (lines 1100–1144): The complete set of mode state fields (`_isKeyboardEventSelectionMode`, `_isKeyboardMoveMode`, `_isKeyboardResizeMode`, `_keyboardMoveEvent`, `_keyboardMoveEventIndex`, `_isKeyboardOverflowFocused`, `_layoutVisibleCounts`, etc.) are already implemented and working.
- **`_handleKeyEvent`** (line 2005): The main key event router that dispatches to mode-specific handlers based on current state. Already implements the mode priority: Resize > Move > Event > Navigation.
- **`_handleKeyboardEventModeKey`** (line 2366): Event Mode handler with Tab/Arrow cycling, Enter/Space activation, D/Delete deletion, M/R mode transitions. Already respects `_layoutVisibleCounts` for visible-only cycling.
- **`_handleKeyboardMoveModeKey`** (line 2624): Move Mode handler using `MCalDragHandler` infrastructure.
- **`_handleKeyboardResizeModeKey`** (line 2969): Resize Mode handler using `MCalDragHandler` resize infrastructure.
- **`_exitKeyboardMoveMode`** (line 2291): Centralized cleanup that resets all keyboard state fields.
- **`_handleDeleteResult`** (line 2505): Handles `FutureOr<bool>` result from `onDeleteEventRequested`, supporting both sync and async consumers.
- **`_visibleCountForDate`** (line 2285): Reads from `_layoutVisibleCounts` map to determine how many events are actually visible on screen for a given date.
- **`_buildDefaultShortcuts`** (line 1792): Returns `Shortcuts` map for mode-independent global shortcuts (Cmd+N only).
- **`_buildActionsMap`** (line 1814): Returns `Actions` map for `MCalMonthViewCreateEventIntent`.

### Integration Points

- **`MCalEventController`**: Provides `focusedDate`, `displayDate`, event queries. Delete callbacks trigger `removeEvents()` which sets `lastChange` with `affectedEventIds` for targeted rebuilds.
- **`MCalDragHandler`**: Move Mode and Resize Mode delegate validation and confirmation to the existing drag handler infrastructure, ensuring consistency between mouse-based and keyboard-based operations.
- **`layoutVisibleCounts` pipeline**: The default week layout builder (`mcal_month_default_week_layout.dart`, line 260) populates `_layoutVisibleCounts` during build. Custom `weekLayoutBuilder` implementations can also populate it via `MCalMonthWeekLayoutContext.layoutVisibleCounts`. The key format is `'${year}-${month}-${day}'`.
- **`Focus.onKeyEvent`**: Raw key events intercepted before `Shortcuts` widget, giving mode handlers first priority.

## Architecture

### State Machine

```
┌──────────────────────┐
│   Navigation Mode    │◄─── Escape ───┐
│  (default, on focus) │               │
└──────────┬───────────┘               │
           │ Enter/Space               │
           │ (cell has events)         │
           ▼                           │
┌──────────────────────┐               │
│     Event Mode       │───────────────┘
│  (cycling events)    │
└──┬────────────┬──────┘
   │ M          │ R
   ▼            ▼
┌──────────┐ ┌──────────┐
│Move Mode │ │Resize    │
│          │◄►│Mode      │
│  R ──────┘ │  M ──────┘
└──────────┘ └──────────┘
   Escape→Event  Escape→Event
   Enter→Nav     Enter→Nav
```

### Key Event Propagation

```
Focus.onKeyEvent
  │
  ├─ enableKeyboardNavigation == false? → KeyEventResult.ignored
  │
  ├─ _isKeyboardResizeMode?  → _handleKeyboardResizeModeKey()
  │
  ├─ _isKeyboardMoveMode?    → _handleKeyboardMoveModeKey()
  │
  ├─ _isKeyboardEventSelectionMode? → _handleKeyboardEventModeKey()
  │
  ├─ Navigation Mode keys    → handle arrows, Home/End, PgUp/PgDn, Enter/Space
  │
  └─ Not handled → KeyEventResult.ignored
                     │
                     ▼
              Shortcuts/Actions (Cmd+N → Create)
```

## Components and Interfaces

### Component 1: `MCalKeyActivator` (NEW — Requirement 6)

- **Purpose**: Pairs a `LogicalKeyboardKey` with optional modifier flags (Shift, Control, Meta, Alt). Enables expressing key combinations like Shift+Tab as a single activator object.
- **File**: `lib/src/models/mcal_month_key_bindings.dart`
- **Interfaces**:
  ```dart
  class MCalKeyActivator {
    const MCalKeyActivator(this.key, {
      this.shift = false,
      this.control = false,
      this.meta = false,
      this.alt = false,
    });

    final LogicalKeyboardKey key;
    final bool shift;
    final bool control;
    final bool meta;
    final bool alt;

    bool matches(LogicalKeyboardKey eventKey, {
      required bool isShiftPressed,
      required bool isControlPressed,
      required bool isMetaPressed,
      required bool isAltPressed,
    });
  }
  ```
- **Dependencies**: `package:flutter/services.dart` for `LogicalKeyboardKey`
- **Reuses**: None — new class, but `matches()` pattern is similar to `SingleActivator.accepts()` in Flutter's `Shortcuts` system.
- **Design decisions**:
  - `const` constructor for zero-allocation defaults.
  - `matches()` checks both the key and all modifier states. For activators where a modifier is `false`, the corresponding modifier key must NOT be pressed (strict matching). This prevents Shift+Tab from also matching plain Tab.
  - Implements `==` and `hashCode` for use in `Set<MCalKeyActivator>`.

### Component 2: `MCalMonthKeyBindings` (NEW — Requirement 6)

- **Purpose**: Holds named `Set<MCalKeyActivator>` properties for every configurable action across all four modes. Provides a `const` default constructor with the current hardcoded bindings as defaults.
- **File**: `lib/src/models/mcal_month_key_bindings.dart` (same file as `MCalKeyActivator`)
- **Interfaces**:
  ```dart
  class MCalMonthKeyBindings {
    const MCalMonthKeyBindings({
      // Navigation Mode
      this.enterEventMode = const { MCalKeyActivator(LogicalKeyboardKey.enter), MCalKeyActivator(LogicalKeyboardKey.space) },
      this.home = const { MCalKeyActivator(LogicalKeyboardKey.home) },
      this.end = const { MCalKeyActivator(LogicalKeyboardKey.end) },
      this.pageUp = const { MCalKeyActivator(LogicalKeyboardKey.pageUp) },
      this.pageDown = const { MCalKeyActivator(LogicalKeyboardKey.pageDown) },

      // Event Mode
      this.cycleForward = const { MCalKeyActivator(LogicalKeyboardKey.tab), MCalKeyActivator(LogicalKeyboardKey.arrowDown) },
      this.cycleBackward = const { MCalKeyActivator(LogicalKeyboardKey.tab, shift: true), MCalKeyActivator(LogicalKeyboardKey.arrowUp) },
      this.activate = const { MCalKeyActivator(LogicalKeyboardKey.enter), MCalKeyActivator(LogicalKeyboardKey.space) },
      this.delete = const { MCalKeyActivator(LogicalKeyboardKey.keyD), MCalKeyActivator(LogicalKeyboardKey.delete), MCalKeyActivator(LogicalKeyboardKey.backspace) },
      this.enterMoveMode = const { MCalKeyActivator(LogicalKeyboardKey.keyM) },
      this.enterResizeMode = const { MCalKeyActivator(LogicalKeyboardKey.keyR) },
      this.exitEventMode = const { MCalKeyActivator(LogicalKeyboardKey.escape) },

      // Move Mode
      this.confirmMove = const { MCalKeyActivator(LogicalKeyboardKey.enter) },
      this.cancelMove = const { MCalKeyActivator(LogicalKeyboardKey.escape) },
      this.moveToResize = const { MCalKeyActivator(LogicalKeyboardKey.keyR) },

      // Resize Mode
      this.switchToStartEdge = const { MCalKeyActivator(LogicalKeyboardKey.keyS) },
      this.switchToEndEdge = const { MCalKeyActivator(LogicalKeyboardKey.keyE) },
      this.confirmResize = const { MCalKeyActivator(LogicalKeyboardKey.enter) },
      this.resizeToMove = const { MCalKeyActivator(LogicalKeyboardKey.keyM) },
      this.cancelResize = const { MCalKeyActivator(LogicalKeyboardKey.escape) },
    });

    // Navigation Mode
    final Set<MCalKeyActivator> enterEventMode;
    final Set<MCalKeyActivator> home;
    final Set<MCalKeyActivator> end;
    final Set<MCalKeyActivator> pageUp;
    final Set<MCalKeyActivator> pageDown;

    // Event Mode
    final Set<MCalKeyActivator> cycleForward;
    final Set<MCalKeyActivator> cycleBackward;
    final Set<MCalKeyActivator> activate;
    final Set<MCalKeyActivator> delete;
    final Set<MCalKeyActivator> enterMoveMode;
    final Set<MCalKeyActivator> enterResizeMode;
    final Set<MCalKeyActivator> exitEventMode;

    // Move Mode
    final Set<MCalKeyActivator> confirmMove;
    final Set<MCalKeyActivator> cancelMove;
    final Set<MCalKeyActivator> moveToResize;

    // Resize Mode
    final Set<MCalKeyActivator> switchToStartEdge;
    final Set<MCalKeyActivator> switchToEndEdge;
    final Set<MCalKeyActivator> confirmResize;
    final Set<MCalKeyActivator> resizeToMove;
    final Set<MCalKeyActivator> cancelResize;

    MCalMonthKeyBindings copyWith({ ... });
  }
  ```
- **Dependencies**: `MCalKeyActivator`
- **Reuses**: Default key mappings mirror the current hardcoded `LogicalKeyboardKey` comparisons in the four mode handlers.
- **Design decisions**:
  - `const` default constructor: allows `const MCalMonthKeyBindings()` to produce the same behavior as the current hardcoded system with zero allocation.
  - `Set<MCalKeyActivator>` per action: multiple keys can trigger the same action (e.g., Tab and ArrowDown both cycle forward).
  - Arrow keys for directional navigation (Navigation Mode cell movement, Move Mode event movement, Resize Mode edge adjustment) are NOT in the bindings — they are hardcoded because they are inherent to directional UI and remapping them would break spatial expectations.
  - `copyWith` enables selective overrides: `MCalMonthKeyBindings(delete: {MCalKeyActivator(LogicalKeyboardKey.keyX)})` replaces only the delete binding.

### Component 3: `MCalMonthView` modifications (Requirement 6)

- **Purpose**: Accept optional `keyBindings` parameter and refactor key handlers to use it.
- **File**: `lib/src/widgets/mcal_month_view.dart`
- **Changes**:
  - Add `final MCalMonthKeyBindings? keyBindings;` parameter to `MCalMonthView`.
  - In `_MCalMonthViewState`, resolve effective bindings: `MCalMonthKeyBindings get _keyBindings => widget.keyBindings ?? const MCalMonthKeyBindings();`
  - Add a helper method `bool _matchesAny(Set<MCalKeyActivator> activators, LogicalKeyboardKey key, KeyEvent event)` that checks if any activator in the set matches the current key + modifier state.
  - Refactor each mode handler to replace hardcoded `key == LogicalKeyboardKey.xxx` checks with `_matchesAny(_keyBindings.xxx, key, event)`.
- **Dependencies**: `MCalMonthKeyBindings`, `MCalKeyActivator`
- **Reuses**: All existing mode handler logic, state fields, and helper methods remain unchanged — only the key-matching expressions change.

### Component 4: Existing mode handlers (retroactive — Requirements 1–5, 7)

These are already implemented. Documenting for completeness:

- **`_handleKeyEvent`** (line 2005): Router that checks mode flags in priority order and dispatches to the appropriate handler.
- **`_handleKeyboardEventModeKey`** (line 2366): Event Mode — cycles visible events + overflow via Tab/Arrow, activates via Enter/Space (fires `onEventTap`/`onOverflowTap` and exits), deletes via D/Delete/Backspace (calls `onDeleteEventRequested`), enters Move/Resize via M/R, exits via Escape.
- **`_handleKeyboardMoveModeKey`** (line 2624): Move Mode — arrow keys move event, Enter confirms, Escape cancels (returns to Event Mode), R switches to Resize.
- **`_handleKeyboardResizeModeKey`** (line 2969): Resize Mode — S/E switch edge, arrow keys adjust, Enter confirms, Escape cancels (returns to Event Mode), M switches to Move.
- **`_exitKeyboardMoveMode`** (line 2291): Resets all keyboard state fields to defaults.
- **`_handleDeleteResult`** (line 2505): Processes `FutureOr<bool>` from `onDeleteEventRequested`. Sync `true` exits immediately in same frame; async `true` exits after future completes (checks `mounted`).
- **`_visibleCountForDate`** (line 2285): Reads `_layoutVisibleCounts` map for height-constrained visible event counts. Falls back to `allEvents.length` if layout hasn't reported (custom builders that don't populate the map).

## Data Models

### MCalKeyActivator

```dart
class MCalKeyActivator {
  final LogicalKeyboardKey key;
  final bool shift;    // default: false
  final bool control;  // default: false
  final bool meta;     // default: false
  final bool alt;      // default: false
}
```

### MCalMonthKeyBindings

```dart
class MCalMonthKeyBindings {
  // 5 Navigation Mode bindings
  // 7 Event Mode bindings
  // 3 Move Mode bindings
  // 5 Resize Mode bindings
  // = 20 named Set<MCalKeyActivator> properties
}
```

### Existing models used

- **`MCalEventTapDetails`**: `{ event: MCalCalendarEvent, displayDate: DateTime }` — passed to `onEventTap` and `onDeleteEventRequested`.
- **`MCalCalendarEvent`**: The event model, identified by `id: String`.
- **`MCalEventChangeInfo`**: `{ type: MCalChangeType, affectedEventIds: Set<String> }` — set by controller mutations for targeted view rebuilds.

## Error Handling

### Error Scenarios

1. **Delete callback throws**
   - **Handling**: The `FutureOr<bool>` pattern means synchronous exceptions propagate normally. For `Future<bool>` returns, unhandled exceptions in the future will surface as uncaught async errors (standard Dart behavior). The library does not catch exceptions from consumer callbacks.
   - **User Impact**: Event remains in Event Mode (no state transition on failure).

2. **Delete callback returns Future that never completes**
   - **Handling**: The library holds no reference to the future after `.then()`. The keyboard state remains in Event Mode. The user can press Escape to return to Navigation Mode.
   - **User Impact**: No visible hang — the calendar remains interactive.

3. **Key binding conflict (same key in multiple actions within one mode)**
   - **Handling**: The handler checks actions in a defined order within each mode. The first match wins. This is documented behavior — consumers should avoid assigning the same key to multiple actions in one mode.
   - **User Impact**: The first-matched action fires; others are unreachable for that key.

4. **Empty key binding set for an action**
   - **Handling**: If a consumer provides an empty set for an action (e.g., `delete: {}`), that action becomes unreachable by keyboard. This is intentional — it's how consumers disable specific shortcuts.
   - **User Impact**: The action is not triggered by any key.

5. **`layoutVisibleCounts` not populated (custom builder)**
   - **Handling**: `_visibleCountForDate` falls back to `allEvents.length`, treating all events as visible. This is safe but may allow cycling through events that are visually hidden.
   - **User Impact**: Keyboard may cycle through events not visible on screen. Custom builder developers are encouraged to populate `layoutVisibleCounts`.

## Testing Strategy

### Unit Testing

- **`MCalKeyActivator`**: Test `matches()` for exact key match, modifier match, modifier mismatch, multiple modifiers.
- **`MCalKeyActivator` equality**: Test `==` and `hashCode` for identical and differing instances.
- **`MCalMonthKeyBindings`**: Test default constructor produces correct default bindings. Test `copyWith` produces correct overrides while preserving other bindings.
- **`MCalMonthKeyBindings` const**: Verify `const MCalMonthKeyBindings()` compiles (const-correctness).

### Widget Testing

- **Custom key bindings**: Create `MCalMonthView` with custom `keyBindings` that remap an action (e.g., change `enterMoveMode` from M to X). Simulate pressing X in Event Mode → verify Move Mode is entered. Simulate pressing M → verify it is NOT handled.
- **Disabled action**: Create `MCalMonthView` with `keyBindings` where `delete: {}`. Simulate pressing D in Event Mode → verify no deletion occurs.
- **Modifier-aware binding**: Create a binding with `MCalKeyActivator(LogicalKeyboardKey.keyA, control: true)`. Verify Ctrl+A triggers the action but plain A does not.
- **Default bindings**: Verify all existing keyboard navigation tests pass without providing `keyBindings` (defaults match current hardcoded behavior).

### Retroactive coverage (existing tests)

The keyboard navigation state machine is covered by existing tests. New key bindings tests extend coverage without replacing existing tests. Key existing test areas:
- Navigation Mode: arrow key movement, Home/End, PageUp/PageDown, Enter/Space to Event Mode
- Event Mode: Tab/Arrow cycling, visible-count-aware cycling, overflow indicator, Enter/Space activation, D/Delete deletion, M/R mode transitions, Escape exit
- Move Mode: arrow key movement, Enter confirm, Escape cancel
- Resize Mode: S/E edge switching, arrow key adjustment, Enter confirm, Escape cancel
- `layoutVisibleCounts`: default and custom layout builder visible count reporting
