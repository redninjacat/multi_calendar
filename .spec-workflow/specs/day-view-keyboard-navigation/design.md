# Design Document: Day View Keyboard Navigation

## Overview

This design covers the complete keyboard navigation system for `MCalDayView`, implementing the same four-mode state machine used in `MCalMonthView` (Navigation, Event, Move, Resize modes) but adapted for the Day View's time-slot-based layout with distinct all-day and time grid sections. The system replaces the current ad-hoc keyboard handling (scroll-based arrows, Ctrl/Cmd+modifier shortcuts via `Shortcuts`/`Actions`) with a modal, mode-aware raw key handler and configurable key bindings via `MCalDayKeyBindings`.

The Day View already has partial keyboard support: `_handleKeyEvent` handles scroll-based arrow navigation, Tab cycling through events, and move/resize modes triggered by `Shortcuts`/`Actions` (Ctrl+M, Ctrl+R). This design refactors that into a proper four-mode state machine, removes the `Shortcuts`/`Actions` layer, adds Navigation Mode with section jumping (A/T), adds event type conversion (X), updates callback signatures for consistency with the Month View, and introduces configurable key bindings via `MCalDayKeyBindings`.

## Steering Document Alignment

### Technical Standards (tech.md)

- **Controller Pattern**: Keyboard navigation reads `displayDate` from `MCalEventController` and modifies it via controller setters. Mode state is maintained in `_MCalDayViewState`, consistent with the existing drag/resize state pattern (e.g., `_isKeyboardMoveMode`, `_keyboardMoveEvent`).
- **Performance**: Key handlers short-circuit immediately by mode — if we're in Navigation Mode, Event Mode handler code is never reached. `MCalDayKeyBindings` supports `const` construction for zero runtime allocation. Controller mutations (e.g., `removeEvents` in delete callbacks) are O(1) per event with targeted `MCalEventChangeInfo` for surgical view rebuilds.
- **DST-safe arithmetic**: Move Mode uses `addDays()` from `date_utils.dart` for day shifts (Left/Right arrows), never `Duration(days: n)`. Time-slot shifts within a single day use `DateTime` constructor arithmetic: `DateTime(y, m, d, h, m + slotMinutes)` — the constructor handles overflow correctly.
- **Accessibility**: Every mode transition and event cycle produces a `SemanticsService.sendAnnouncement` using localized strings from `MCalLocalizations`. Section transitions (A/T) use localized announcement strings added to all 5 ARB files. The example app's Accessibility tab organizes keyboard shortcuts by mode with localized descriptions in all 5 languages.
- **Localization**: All announcement strings are added to the package-level ARB files (`lib/l10n/app_*.arb`) and accessed via `MCalLocalizations.of(context)`. The example app's accessibility tab strings are added to `example/lib/l10n/app_*.arb` and accessed via `AppLocalizations.of(context)`.

### Project Structure (structure.md)

- **File placement**: The new `MCalDayKeyBindings` class goes in `lib/src/models/mcal_day_key_bindings.dart`, following the models directory convention for pure data classes. It reuses `MCalKeyActivator` from `mcal_month_key_bindings.dart`.
- **Naming**: Public classes use the `MCal` prefix: `MCalDayKeyBindings`. File uses `snake_case`.
- **Export**: Added to `lib/multi_calendar.dart` alongside other model exports.
- **Code size**: The key bindings file is a pure data class with ~200 lines — well under the 500-line limit. The day view file is already large (~9000 lines) but the key handler methods are organized by mode and each stays under the 50-line function limit where possible.

## Code Reuse Analysis

### Existing Components to Leverage

- **`MCalKeyActivator`** (`lib/src/models/mcal_month_key_bindings.dart`): Shared between Month and Day views. Pairs a `LogicalKeyboardKey` with modifier flags. `matches()` checks key identity and all four modifier states strictly.
- **`_MCalDayViewState` keyboard fields** (lines 1544–1560): Existing `_focusNode`, `_focusedEvent`, `_isKeyboardMoveMode`, `_keyboardMoveEvent`, `_keyboardMoveOriginalStart/End`, `_keyboardMoveProposedStart/End`, `_isKeyboardResizeMode`, `_keyboardResizeEdge`, `_keyboardResizeEdgeOffset`.
- **`_handleKeyEvent`** (line 2368): Existing key event router — currently handles escape, move mode, resize mode, and scroll navigation. Will be refactored into the four-mode state machine.
- **`_handleKeyboardMoveKey`** (line 2492): Existing Move Mode handler with arrow-key movement, Enter confirm, Escape cancel. Will be extended with R→Resize transition and configurable key bindings.
- **`_handleKeyboardResizeKey`** (line 2532): Existing Resize Mode handler with edge switching, arrow-key adjustment, Enter confirm, Escape cancel. Will be extended with M→Move transition and configurable key bindings.
- **`_handleTabNavigation`** (line 3014): Existing Tab cycling through events (respects `_allDayVisibleCount` for visible-only cycling). Will become part of Event Mode.
- **`_handleEventTap`** (line 3034): Existing event tap handler that sets `_focusedEvent` when `autoFocusOnEventTap` is true.
- **`MCalDragHandler`**: Move Mode and Resize Mode delegate validation and confirmation to the existing drag handler infrastructure, ensuring consistency between mouse-based and keyboard-based operations.
- **`_allDayVisibleCount`** (line 1391): Tracks visible all-day event count reported by `_AllDayEventsSection`. Used for visible-only event cycling in Event Mode (matching Month View's `_layoutVisibleCounts` pattern).
- **Month View keyboard patterns**: The Month View's state machine (`_handleKeyEvent`, `_handleKeyboardEventModeKey`, `_handleKeyboardMoveModeKey`, `_handleKeyboardResizeModeKey`, `_matchesAny`, `_handleDeleteResult`) provides the architectural template.

### Existing Code to Remove

- **Intent classes** (lines 26–77): `MCalDayViewCreateEventIntent`, `MCalDayViewDeleteEventIntent`, `MCalDayViewEditEventIntent`, `MCalDayViewKeyboardMoveIntent`, `MCalDayViewKeyboardResizeIntent`.
- **`_buildDefaultShortcuts`** (line 5755): Cmd/Ctrl+N/D/E/M/R shortcut map.
- **`_buildShortcutsMap`** (line 5792): Merges defaults with user overrides.
- **`_buildActionsMap`** (line 5803): Maps intents to callbacks.
- **`Shortcuts`/`Actions` widgets** (line 6268): Widget wrappers in build.
- **`keyboardShortcuts` parameter** (line 219): User-provided shortcut overrides.
- **`onEditEventRequested` parameter** (line 1236): Replaced by `onEventTap`.
- **Legacy callback signatures**: `onCreateEventRequested: VoidCallback?` → `FutureOr<bool> Function(BuildContext, DateTime)?`, `onDeleteEventRequested: void Function(MCalCalendarEvent)?` → `FutureOr<bool> Function(BuildContext, MCalEventTapDetails)?`.
- **`multi_calendar.dart` exports**: Remove `MCalDayViewCreateEventIntent`, `MCalDayViewDeleteEventIntent`, `MCalDayViewEditEventIntent`, `MCalDayViewKeyboardMoveIntent`, `MCalDayViewKeyboardResizeIntent` from the `show` clause.

### Integration Points

- **`MCalEventController`**: Provides `displayDate`, event queries via `getEventsForDate`. The controller's `setDisplayDate` navigates between days (PageUp/PageDown in Navigation Mode, Left/Right in Move Mode).
- **`MCalDragHandler`**: Move Mode and Resize Mode delegate validation and confirmation to the existing drag handler infrastructure, ensuring consistency between mouse-based and keyboard-based operations.
- **`_allDayVisibleCount` pipeline**: `_AllDayEventsSection` reports visible event count during build via the `onVisibleCountChanged` callback. Event Mode uses this to cycle only through visible all-day events and the overflow indicator.
- **`Focus.onKeyEvent`**: Raw key events intercepted before `Shortcuts` widget (the `Shortcuts` widget will be removed). The mode handlers get first priority.
- **`offsetToTime` / `snapToTimeSlot`**: Existing utilities used for converting between pixel offsets and time slots. Navigation Mode uses these to determine which time slot is focused.
- **`timeToOffset`**: Existing utility used for auto-scrolling to reveal focused time slots and selected events.
- **`ScrollController`**: The time grid's scroll controller enables auto-scrolling to reveal focused slots and events when they move outside the visible area.

## Architecture

### State Machine

```
┌──────────────────────┐
│   Navigation Mode    │◄─── Escape ───┐
│  (default, on focus) │               │
│                      │               │
│  A: jump to all-day  │               │
│  T: jump to time grid│               │
│  N: create event     │               │
│  ↑↓: move focus slot │               │
│  PgUp/Dn: prev/next  │               │
└──────────┬───────────┘               │
           │ Enter/Space               │
           │ (day has events)          │
           ▼                           │
┌──────────────────────┐               │
│     Event Mode       │───────────────┘
│  (cycling events)    │
│                      │
│  Tab/↑↓: cycle       │
│  Enter: activate     │
│  D: delete           │
│  X: convert type     │
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
  │                                       (except Escape for active drag cancel)
  │
  ├─ _isKeyboardResizeMode?  → _handleKeyboardResizeModeKey()
  │
  ├─ _isKeyboardMoveMode?    → _handleKeyboardMoveModeKey()
  │
  ├─ _isKeyboardEventMode?   → _handleKeyboardEventModeKey()
  │
  ├─ Navigation Mode keys    → handle ↑↓, Home/End, PgUp/PgDn,
  │                             Enter/Space, N, A, T
  │
  └─ Not handled → KeyEventResult.ignored
```

### Navigation Mode Focus Model

```
┌──────────────────────────────────────┐
│  All-Day Section (focusable as one   │
│  slot — A key jumps here)            │
├──────────────────────────────────────┤
│  Time Slot: startHour:00             │  ← T key jumps here (or last focused)
│  Time Slot: startHour:15             │
│  Time Slot: startHour:30             │
│  ...                                 │
│  Time Slot: endHour-1:45             │  ← ↑↓ moves between slots
├──────────────────────────────────────┤
│  Home = first time slot              │
│  End  = last time slot              │
└──────────────────────────────────────┘
```

The focused slot is tracked as a nullable `int? _focusedSlotIndex` where:
- `null` = all-day section focused
- `0` = first time slot (`startHour:00`)
- `N` = slot at `startHour + (N * timeSlotDuration.inMinutes) / 60`

The total number of slots is: `((endHour - startHour) * 60) ~/ timeSlotDuration.inMinutes`.

## Components and Interfaces

### Component 1: `MCalDayKeyBindings` (NEW — Requirement 6)

- **Purpose**: Holds named `List<MCalKeyActivator>` properties for every configurable action across all four modes. Provides a `const` default constructor with the default key bindings. Mirrors `MCalMonthKeyBindings` with Day View-specific additions.
- **File**: `lib/src/models/mcal_day_key_bindings.dart`
- **Interfaces**:
  ```dart
  class MCalDayKeyBindings {
    const MCalDayKeyBindings({
      // Navigation Mode
      this.enterEventMode = const [
        MCalKeyActivator(LogicalKeyboardKey.enter),
        MCalKeyActivator(LogicalKeyboardKey.space),
      ],
      this.home = const [MCalKeyActivator(LogicalKeyboardKey.home)],
      this.end = const [MCalKeyActivator(LogicalKeyboardKey.end)],
      this.pageUp = const [MCalKeyActivator(LogicalKeyboardKey.pageUp)],
      this.pageDown = const [MCalKeyActivator(LogicalKeyboardKey.pageDown)],
      this.createEvent = const [MCalKeyActivator(LogicalKeyboardKey.keyN)],
      this.jumpToAllDay = const [MCalKeyActivator(LogicalKeyboardKey.keyA)],
      this.jumpToTimeGrid = const [MCalKeyActivator(LogicalKeyboardKey.keyT)],

      // Event Mode
      this.cycleForward = const [
        MCalKeyActivator(LogicalKeyboardKey.tab),
        MCalKeyActivator(LogicalKeyboardKey.arrowDown),
      ],
      this.cycleBackward = const [
        MCalKeyActivator(LogicalKeyboardKey.tab, shift: true),
        MCalKeyActivator(LogicalKeyboardKey.arrowUp),
      ],
      this.activate = const [
        MCalKeyActivator(LogicalKeyboardKey.enter),
        MCalKeyActivator(LogicalKeyboardKey.space),
      ],
      this.delete = const [
        MCalKeyActivator(LogicalKeyboardKey.keyD),
        MCalKeyActivator(LogicalKeyboardKey.delete),
        MCalKeyActivator(LogicalKeyboardKey.backspace),
      ],
      this.enterMoveMode = const [MCalKeyActivator(LogicalKeyboardKey.keyM)],
      this.enterResizeMode = const [MCalKeyActivator(LogicalKeyboardKey.keyR)],
      this.exitEventMode = const [MCalKeyActivator(LogicalKeyboardKey.escape)],
      this.convertEventType = const [MCalKeyActivator(LogicalKeyboardKey.keyX)],

      // Move Mode
      this.confirmMove = const [
        MCalKeyActivator(LogicalKeyboardKey.enter),
        MCalKeyActivator(LogicalKeyboardKey.space),
      ],
      this.cancelMove = const [MCalKeyActivator(LogicalKeyboardKey.escape)],
      this.switchToResize = const [MCalKeyActivator(LogicalKeyboardKey.keyR)],

      // Resize Mode
      this.switchToStartEdge = const [MCalKeyActivator(LogicalKeyboardKey.keyS)],
      this.switchToEndEdge = const [MCalKeyActivator(LogicalKeyboardKey.keyE)],
      this.confirmResize = const [
        MCalKeyActivator(LogicalKeyboardKey.enter),
        MCalKeyActivator(LogicalKeyboardKey.space),
      ],
      this.switchToMove = const [MCalKeyActivator(LogicalKeyboardKey.keyM)],
      this.cancelResize = const [MCalKeyActivator(LogicalKeyboardKey.escape)],
    });

    // Navigation Mode (8 bindings — 3 more than Month View)
    final List<MCalKeyActivator> enterEventMode;
    final List<MCalKeyActivator> home;
    final List<MCalKeyActivator> end;
    final List<MCalKeyActivator> pageUp;
    final List<MCalKeyActivator> pageDown;
    final List<MCalKeyActivator> createEvent;
    final List<MCalKeyActivator> jumpToAllDay;   // Day View only
    final List<MCalKeyActivator> jumpToTimeGrid; // Day View only

    // Event Mode (8 bindings — 1 more than Month View)
    final List<MCalKeyActivator> cycleForward;
    final List<MCalKeyActivator> cycleBackward;
    final List<MCalKeyActivator> activate;
    final List<MCalKeyActivator> delete;
    final List<MCalKeyActivator> enterMoveMode;
    final List<MCalKeyActivator> enterResizeMode;
    final List<MCalKeyActivator> exitEventMode;
    final List<MCalKeyActivator> convertEventType; // Day View only

    // Move Mode (3 bindings — same as Month View)
    final List<MCalKeyActivator> confirmMove;
    final List<MCalKeyActivator> cancelMove;
    final List<MCalKeyActivator> switchToResize;

    // Resize Mode (5 bindings — same as Month View)
    final List<MCalKeyActivator> switchToStartEdge;
    final List<MCalKeyActivator> switchToEndEdge;
    final List<MCalKeyActivator> confirmResize;
    final List<MCalKeyActivator> switchToMove;
    final List<MCalKeyActivator> cancelResize;

    MCalDayKeyBindings copyWith({ ... });
  }
  ```
- **Dependencies**: `MCalKeyActivator` (from `mcal_month_key_bindings.dart`)
- **Reuses**: `MCalKeyActivator` for key+modifier pairing. Default key assignments match the Month View where applicable.
- **Design decisions**:
  - `const` default constructor: allows `const MCalDayKeyBindings()` with zero allocation.
  - `List<MCalKeyActivator>` per action (not `Set`, because Dart `const` sets have restrictions).
  - Arrow keys for directional navigation are NOT in the bindings — they are hardcoded because they are inherent to directional UI.
  - 24 total bindings (vs Month View's 21): 3 Day View-specific additions (`jumpToAllDay`, `jumpToTimeGrid`, `convertEventType`).
  - `copyWith` enables selective overrides.

### Component 2: `MCalDayView` modifications (Requirements 1–10)

- **Purpose**: Refactor the existing keyboard handling into a proper four-mode state machine, remove legacy `Shortcuts`/`Actions`, add Navigation Mode, Event Mode, and configurable key bindings.
- **File**: `lib/src/widgets/mcal_day_view.dart`

#### New state fields

```dart
// Navigation Mode
bool _isKeyboardEventMode = false;  // replaces ad-hoc _focusedEvent != null checks
int? _focusedSlotIndex;              // null = all-day section, 0..N = time slots
int? _lastTimeGridSlotIndex;         // remembers last time-grid slot for T key
bool _isKeyboardOverflowFocused = false; // overflow indicator has keyboard focus

// Event Mode
int _keyboardEventIndex = 0;         // current event index in display-order list
```

The existing `_focusedEvent`, `_isKeyboardMoveMode`, `_keyboardMoveEvent`, `_isKeyboardResizeMode`, `_keyboardResizeEdge`, `_keyboardResizeEdgeOffset` fields are retained.

**`_isKeyboardOverflowFocused` usage**: In Event Mode, `_isKeyboardOverflowFocused` tracks whether the overflow indicator (rather than an event) currently has keyboard focus. When cycling through events in Event Mode via Tab/Arrow, the cycle order is: visible all-day events → overflow indicator (if present) → timed events, wrapping around. When `_isKeyboardOverflowFocused` is `true`:
- Enter/Space fires `widget.onOverflowTap` and exits all keyboard modes (per Requirement 3, AC 14).
- D/Delete, X, M, R are absorbed with no action (they apply to events, not the overflow indicator).
- The overflow indicator receives a visual focus ring (matching the Month View's overflow focus behavior).
When cycling past the overflow indicator (forward or backward), `_isKeyboardOverflowFocused` is set back to `false` and `_focusedEvent` is updated to the next event in the display-order list.

#### Removed items

- `MCalDayViewCreateEventIntent`, `MCalDayViewDeleteEventIntent`, `MCalDayViewEditEventIntent`, `MCalDayViewKeyboardMoveIntent`, `MCalDayViewKeyboardResizeIntent` classes
- `_buildDefaultShortcuts()`, `_buildShortcutsMap()`, `_buildActionsMap()` methods
- `Shortcuts` and `Actions` widget wrappers in `build()`
- `keyboardShortcuts` parameter
- `onEditEventRequested` parameter

#### Updated callback signatures

```dart
// Old:
final VoidCallback? onCreateEventRequested;
final void Function(MCalCalendarEvent event)? onDeleteEventRequested;
final void Function(MCalCalendarEvent event)? onEditEventRequested;

// New:
final FutureOr<bool> Function(BuildContext, DateTime)? onCreateEventRequested;
final FutureOr<bool> Function(BuildContext, MCalEventTapDetails)? onDeleteEventRequested;
// onEditEventRequested removed — use onEventTap
```

**`onCreateEventRequested` return value contract**: The signature is `FutureOr<bool>` for forward-compatibility and consistency with other callbacks, but per Requirement 8 AC 6, the return value is **ignored** — the calendar always remains in Navigation Mode regardless of whether `true` or `false` is returned. The library awaits the result if a `Future` is returned but takes no action based on it.

#### New callback

```dart
final FutureOr<bool> Function(
  BuildContext context,
  MCalCalendarEvent event,
  bool toAllDay,
  DateTime? suggestedStartTime,
)? onEventTypeConversionRequested;
```

#### New parameter

```dart
final MCalDayKeyBindings? keyBindings;
```

#### Refactored `_handleKeyEvent`

The existing method is refactored to follow the Month View's pattern:

```dart
KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
  if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
    return KeyEventResult.ignored;
  }

  final key = event.logicalKey;

  // Escape always works (even with enableKeyboardNavigation == false)
  // for cancelling active drags/resizes
  if (key == LogicalKeyboardKey.escape) {
    // ... existing escape handling (resize > move > drag cancel)
  }

  if (!widget.enableKeyboardNavigation) return KeyEventResult.ignored;

  // Mode priority: Resize > Move > Event > Navigation
  if (_isKeyboardResizeMode) {
    return _handleKeyboardResizeModeKey(key, event);
  }
  if (_isKeyboardMoveMode) {
    return _handleKeyboardMoveModeKey(key, event);
  }
  if (_isKeyboardEventMode) {
    return _handleKeyboardEventModeKey(key, event);
  }
  return _handleNavigationModeKey(key, event);
}
```

#### New: `_handleNavigationModeKey`

Handles all Navigation Mode keys: ↑↓ (slot movement), Home/End, PageUp/PageDown, Enter/Space (→ Event Mode), N (create), A (jump to all-day), T (jump to time grid). Home always targets the first time slot (`_focusedSlotIndex = 0`), never the all-day section — the user presses Up from the first time slot or A to reach the all-day section. End targets the last time slot.

#### New: `_handleKeyboardEventModeKey`

Handles Event Mode: Tab/↑↓ (cycle events using `_allDayVisibleCount` for visible-only cycling), ←→ (absorbed), Enter/Space (activate → exit), D/Delete/Backspace (delete), M (→ Move), R (→ Resize), Escape (→ Navigation), X (convert event type).

#### Refactored: `_handleKeyboardMoveModeKey`

Extends existing Move Mode handler: adds R→Resize transition, configurable key bindings via `_matchesAny`, Left/Right day shifts using `addDays`, time-slot increments for Up/Down.

#### Refactored: `_handleKeyboardResizeModeKey`

Extends existing Resize Mode handler: adds M→Move transition, configurable key bindings via `_matchesAny`.

#### Helper: `_matchesAny`

```dart
bool _matchesAny(List<MCalKeyActivator> activators, LogicalKeyboardKey key) {
  final isShift = HardwareKeyboard.instance.isShiftPressed;
  final isControl = HardwareKeyboard.instance.isControlPressed;
  final isMeta = HardwareKeyboard.instance.isMetaPressed;
  final isAlt = HardwareKeyboard.instance.isAltPressed;
  return activators.any((a) => a.matches(
    key,
    isShiftPressed: isShift,
    isControlPressed: isControl,
    isMetaPressed: isMeta,
    isAltPressed: isAlt,
  ));
}
```

#### Helper: `_handleDeleteResult`

Mirrors Month View's pattern: processes `FutureOr<bool>` from `onDeleteEventRequested`. Sync `true` exits immediately; async `true` exits after future completes (checks `mounted`).

#### Helper: `_handleConversionResult`

Same `FutureOr<bool>` handling pattern as `_handleDeleteResult`: sync `true` exits all keyboard modes immediately; async `true` exits after the future completes (checks `mounted`); `false` keeps the calendar in Event Mode. This satisfies Requirement 9, AC 4–5.

#### Note on `_handleCreateResult`

`onCreateEventRequested` also returns `FutureOr<bool>`, but per Requirement 8 AC 6 the return value is **always ignored** — the calendar remains in Navigation Mode regardless. The implementation awaits the future (if returned) to avoid dangling unawaited futures, but takes no action on the result. No dedicated helper is needed; an inline `.then((_) {})` (or simply ignoring the sync value) suffices.

#### Helper: `_exitAllKeyboardModes`

Resets all mode flags and state fields to defaults.

#### Auto-scroll

When a focused slot or selected event moves outside the visible scroll area, the time grid's `ScrollController` is used to animate to the target position. `timeToOffset` converts the target time to a pixel offset.

#### Focused slot visual indicator

Navigation Mode renders a visual indicator on the focused time slot. The indicator style is configurable via `MCalDayThemeData`:

```dart
// New theme properties
final Color? focusedSlotBackgroundColor;
final BoxDecoration? focusedSlotDecoration;
```

The all-day section uses a similar but distinct indicator when focused (as it represents a whole section, not a single time slot).

### Component 3: Localization additions

- **File**: `lib/l10n/app_en.arb` (and `app_ar.arb`, `app_es.arb`, `app_fr.arb`, `app_he.arb`)
- **New strings**: Announcement strings for mode transitions, section jumps, event cycling, and event type conversion. Following the Month View's `announcement*` naming pattern:
  - `announcementDayNavigationMode` — "Navigation mode"
  - `announcementDayEventMode` — "Event mode, {count} events"
  - `announcementDayEventCycled` — "{title}, {position} of {total}"
  - `announcementDayEventSelected` — "Selected {title}"
  - `announcementDayMoveMode` — "Move mode for {title}"
  - `announcementDayResizeMode` — "Resize mode for {title}"
  - `announcementDayMoveCancelled` — "Move cancelled for {title}"
  - `announcementDayResizeCancelled` — "Resize cancelled"
  - `announcementDayMovingEvent` — "Moving {title} to {time}"
  - `announcementDayResizingEvent` — "Resizing {title}, {edge} edge at {time}"
  - `announcementDayEventMoved` — "{title} moved to {time}"
  - `announcementDayEventResized` — "{title} resized"
  - `announcementDayAllDaySection` — "All-day section"
  - `announcementDayTimeGrid` — "Time grid, {time}"
  - `announcementDayMoveInvalidTarget` — "Cannot move here"
  - `announcementDayEventDeleted` — "{title} deleted"
  - `announcementDayEventConversionRequested` — "Converting {title} to {type}"

### Component 4: Example app changes

- **File**: `example/lib/views/day_view/tabs/day_accessibility_tab.dart`
- **Changes**: Update keyboard shortcut guide to reflect the new four-mode system, organized by mode. Remove legacy Cmd/Ctrl shortcuts. Add localized descriptions for all 24 key bindings in all 5 ARB files.

- **File**: `example/lib/views/day_view/tabs/day_features_tab.dart`
- **Changes**: Wire up new callback signatures. Add `onDeleteEventRequested` with `FutureOr<bool>` signature. Add `onCreateEventRequested` with `(BuildContext, DateTime)` signature. Add `onEventTypeConversionRequested` with conversion handling. Remove `onEditEventRequested`.

### Component 5: Export updates

- **File**: `lib/multi_calendar.dart`
- **Changes**:
  - Add `export 'src/models/mcal_day_key_bindings.dart';`
  - Remove `MCalDayViewCreateEventIntent`, `MCalDayViewDeleteEventIntent`, `MCalDayViewEditEventIntent`, `MCalDayViewKeyboardMoveIntent`, `MCalDayViewKeyboardResizeIntent` from the `show` clause of `mcal_day_view.dart` export.

## Data Models

### MCalDayKeyBindings

```dart
class MCalDayKeyBindings {
  // 8 Navigation Mode bindings
  // 8 Event Mode bindings
  // 3 Move Mode bindings
  // 5 Resize Mode bindings
  // = 24 named List<MCalKeyActivator> properties
}
```

Day View-specific additions (vs Month View's 21):
- `jumpToAllDay` (default: A) — Navigation Mode
- `jumpToTimeGrid` (default: T) — Navigation Mode
- `convertEventType` (default: X) — Event Mode

### Existing models reused

- **`MCalKeyActivator`**: `{ key, shift, control, meta, alt }` — shared with Month View.
- **`MCalEventTapDetails`**: `{ event: MCalCalendarEvent, displayDate: DateTime }` — passed to `onEventTap` and `onDeleteEventRequested`.
- **`MCalCalendarEvent`**: The event model, identified by `id: String`. The `isAllDay` field determines conversion direction for the X key.
- **`MCalResizeEdge`**: `{ start, end }` enum — used in Resize Mode for S/E edge switching.

### Removed models

- **`MCalDayViewCreateEventIntent`**: Replaced by N key in Navigation Mode.
- **`MCalDayViewDeleteEventIntent`**: Replaced by D/Delete/Backspace in Event Mode.
- **`MCalDayViewEditEventIntent`**: Replaced by Enter/Space activation in Event Mode (fires `onEventTap`).
- **`MCalDayViewKeyboardMoveIntent`**: Replaced by M key in Event Mode.
- **`MCalDayViewKeyboardResizeIntent`**: Replaced by R key in Event Mode.

## Error Handling

### Error Scenarios

1. **Delete callback throws**
   - **Handling**: The `FutureOr<bool>` pattern means synchronous exceptions propagate normally. For `Future<bool>` returns, unhandled exceptions surface as uncaught async errors (standard Dart behavior). The library does not catch exceptions from consumer callbacks.
   - **User Impact**: Event remains in Event Mode (no state transition on failure).

2. **Delete callback returns Future that never completes**
   - **Handling**: The library holds no reference to the future after `.then()`. The keyboard state remains in Event Mode. The user can press Escape to return to Navigation Mode.
   - **User Impact**: No visible hang — the calendar remains interactive.

3. **Event type conversion callback throws or never completes**
   - **Handling**: Same pattern as delete — sync exceptions propagate, async futures are fire-and-forget after `.then()`. The user can press Escape.
   - **User Impact**: Event remains in Event Mode.

4. **Key binding conflict (same key in multiple actions within one mode)**
   - **Handling**: The handler checks actions in a defined order within each mode. The first match wins. This is documented behavior.
   - **User Impact**: The first-matched action fires; others are unreachable for that key.

5. **Empty key binding list for an action**
   - **Handling**: If a consumer provides an empty list for an action (e.g., `delete: []`), that action becomes unreachable by keyboard. This is intentional — it's how consumers disable specific shortcuts.
   - **User Impact**: The action is not triggered by any key.

6. **Move to blocked region or time**
   - **Handling**: Move Mode delegates to `MCalDragHandler` which validates against regions. Invalid moves are announced via `SemanticsService` and the event remains at its current position.
   - **User Impact**: Screen reader announces "Cannot move here"; event stays put.

7. **Resize below minimum duration**
   - **Handling**: Resize Mode delegates to `MCalDragHandler` which enforces minimum duration. The edge stops moving when the minimum is reached.
   - **User Impact**: The edge does not move further; no error shown.

8. **`_allDayVisibleCount` not populated**
   - **Handling**: Falls back to the full all-day events list length, treating all events as visible. This is safe but may allow cycling through events that are visually hidden behind the overflow indicator.
   - **User Impact**: Keyboard may cycle through events not visible on screen.

9. **Create callback invoked when all-day section is focused**
   - **Handling**: `onCreateEventRequested` receives the display date at midnight (`DateTime(y, m, d)`) when `_focusedSlotIndex == null`. The consumer decides whether to create an all-day or timed event.
   - **User Impact**: Consumer's creation dialog opens with the date pre-populated.

## Testing Strategy

### Unit Testing

- **`MCalDayKeyBindings`**: Test default constructor produces correct default bindings for all 24 actions. Test `copyWith` produces correct overrides while preserving other bindings. Verify `const MCalDayKeyBindings()` compiles (const-correctness).

### Widget Testing

#### Navigation Mode
- ↑↓ arrow keys move focused slot index up/down by one slot
- ↑ from first time slot focuses all-day section (`_focusedSlotIndex` → null)
- ↓ from all-day section focuses first time slot
- Home jumps to first time slot; End jumps to last time slot
- PageUp navigates to previous day; PageDown navigates to next day
- Enter/Space with events → enters Event Mode with first event selected
- Enter/Space without events → no mode change
- N calls `onCreateEventRequested` with focused time; null callback absorbs N
- A jumps to all-day section; T jumps to time grid (or last focused slot)
- ←→ are ignored (return `KeyEventResult.ignored`)
- Auto-scroll triggers when focused slot is outside visible area

#### Event Mode
- Tab/↓ cycle forward through events; Shift+Tab/↑ cycle backward; wraps around
- Only visible all-day events are cyclable (respects `_allDayVisibleCount`)
- Overflow indicator is cyclable (matching Month View behavior)
- Enter/Space on event fires `onEventTap` and exits all modes
- Enter/Space on overflow fires `onOverflowTap` and exits all modes
- D/Delete/Backspace calls `onDeleteEventRequested`; `true` → exits, `false` → stays
- X calls `onEventTypeConversionRequested`; `true` → exits, `false` → stays
- X with `isAllDay: true` event → `toAllDay: false`, `suggestedStartTime` ≠ null
- X with `isAllDay: false` event → `toAllDay: true`, `suggestedStartTime` = null
- M → Move Mode; R → Resize Mode (only if resize enabled)
- Escape → Navigation Mode
- ←→ absorbed

#### Move Mode
- ↑↓ for timed events: move by time-slot increment
- ↑↓ for all-day events: absorbed
- ←→: move by one day (respects RTL)
- Enter/Space confirms move, exits all modes
- Escape cancels move (reverts), returns to Event Mode
- R cancels move, enters Resize Mode for same event
- Auto-scroll when moved event is outside visible area

#### Resize Mode
- S switches to start edge; E switches to end edge
- ↑↓ for timed events: adjust selected edge by time-slot increment
- ↑↓ for all-day events: absorbed
- ←→: adjust selected edge by one day (respects RTL)
- Enter/Space confirms resize, exits all modes
- Escape cancels resize (reverts), returns to Event Mode
- M cancels resize, enters Move Mode for same event

#### Custom key bindings
- Remap an action (e.g., `enterMoveMode` to X) → verify X triggers Move Mode, M does not
- Disable an action (e.g., `delete: []`) → verify D does nothing
- Modifier-aware binding → verify Ctrl+A works but plain A does not

#### Legacy removal
- Verify `MCalDayViewCreateEventIntent` no longer exists (compile-time)
- Verify `keyboardShortcuts` parameter no longer exists
- Verify `onEditEventRequested` parameter no longer exists

#### Accessibility
- Mode transitions produce `SemanticsService.sendAnnouncement` with localized strings
- Event cycling announces event title and position
- Section jumps (A/T) announce section name
- Announcements use `MCalLocalizations.of(context)` strings
