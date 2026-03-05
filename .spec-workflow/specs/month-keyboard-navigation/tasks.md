# Tasks Document: Month View Keyboard Navigation

## Phase 1: State Machine & Mode Handlers (retroactive — already implemented)

- [x] 1. Implement keyboard state fields and Navigation Mode handler
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Added keyboard state fields (`_isKeyboardEventSelectionMode`, `_isKeyboardMoveMode`, `_isKeyboardResizeMode`, `_keyboardMoveEvent`, `_keyboardMoveEventIndex`, `_isKeyboardOverflowFocused`, etc.) and Navigation Mode key handling in `_handleKeyEvent` (arrow keys, Home/End, PageUp/PageDown, Enter/Space to enter Event Mode).
  - Purpose: Foundation state machine with Navigation Mode
  - _Leverage: Existing `Focus.onKeyEvent` pattern and `MCalEventController.focusedDate`/`displayDate`_
  - _Requirements: 1.1, 1.2, 1.7, 1.8, 2.1–2.9_

- [x] 2. Implement Event Mode handler
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Implemented `_handleKeyboardEventModeKey` with Tab/Shift+Tab/Arrow cycling through visible events and overflow indicator, Enter/Space activation (fires `onEventTap`/`onOverflowTap` and exits to Navigation Mode), M for Move Mode, R for Resize Mode, Escape to Navigation Mode.
  - Purpose: Event cycling, activation, and mode transitions
  - _Leverage: `_getSortedEventsForDate`, `_visibleCountForDate`, `_triggerKeyboardEventTap`, `_triggerKeyboardOverflowTap`_
  - _Requirements: 1.3, 1.4, 1.5, 1.6, 3.1–3.9_

- [x] 3. Implement visible-count-aware cycling with `layoutVisibleCounts`
  - File: `lib/src/widgets/mcal_month_view.dart`
  - File: `lib/src/widgets/mcal_month_default_week_layout.dart`
  - File: `lib/src/widgets/mcal_month_week_layout_contexts.dart`
  - Added `_layoutVisibleCounts` map, `_visibleCountForDate` helper, and `layoutVisibleCounts` on `MCalMonthWeekLayoutContext`. Default layout builder populates visible counts during build. Event Mode cycling respects visible counts so hidden events are unreachable.
  - Purpose: Height-aware event cycling in Event Mode
  - _Leverage: `MCalMonthDefaultWeekLayout.calculateOverflow`, `MCalMonthWeekLayoutContext`_
  - _Requirements: 3.10, 3.11_

- [x] 4. Implement Move Mode handler
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Implemented `_handleKeyboardMoveModeKey` with arrow keys for event movement, Enter to confirm, Escape to cancel (returns to Event Mode), R to switch to Resize Mode. Uses existing `MCalDragHandler` infrastructure.
  - Purpose: Keyboard-based event moving
  - _Leverage: `MCalDragHandler`, DST-safe `addDays()` from `date_utils.dart`_
  - _Requirements: 4.1–4.6_

- [x] 5. Implement Resize Mode handler
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Implemented `_handleKeyboardResizeModeKey` with S/E for edge switching, arrow keys for edge adjustment, Enter to confirm, Escape to cancel (returns to Event Mode), M to switch to Move Mode. Uses existing `MCalDragHandler` resize infrastructure.
  - Purpose: Keyboard-based event resizing
  - _Leverage: `MCalDragHandler` resize methods, DST-safe arithmetic_
  - _Requirements: 5.1–5.7_

## Phase 2: Delete Support (retroactive — already implemented)

- [x] 6. Add `onDeleteEventRequested` callback and Event Mode delete handling
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Added `onDeleteEventRequested` parameter with `FutureOr<bool> Function(BuildContext, MCalEventTapDetails)?` signature. Added D/Delete/Backspace handling in `_handleKeyboardEventModeKey`. Implemented `_handleDeleteResult` for sync and async results.
  - Purpose: Consumer-controlled event deletion via keyboard
  - _Leverage: `MCalEventTapDetails`, `FutureOr<bool>` pattern_
  - _Requirements: 7.1–7.6, 3.7, 3.8_

- [x] 7. Remove legacy `Shortcuts` system code (Cmd+D, Cmd+E)
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Removed `MCalMonthViewDeleteEventIntent`, `MCalMonthViewEditEventIntent`, `onEditEventRequested` parameter, and corresponding shortcut mappings and action handlers. `Shortcuts`/`Actions` now only handles Cmd+N (create).
  - Purpose: Consolidate mode-specific actions in raw key handler
  - _Leverage: Existing `_buildDefaultShortcuts` and `_buildActionsMap`_
  - _Requirements: 1.7 (Shortcuts system reserved for mode-independent actions)_

## Phase 3: Example App Updates (retroactive — already implemented)

- [x] 8. Reorganize Accessibility tab keyboard guide by mode
  - File: `example/lib/views/month_view/tabs/month_accessibility_tab.dart`
  - File: `example/lib/l10n/app_en.arb`, `app_es.arb`, `app_fr.arb`, `app_ar.arb`, `app_he.arb`
  - Replaced flat shortcut list with mode-organized sections (Navigation, Event, Move, Resize) using `_ModeSection` widget. Added 26 localization keys for mode headers, descriptions, and per-mode shortcut actions across all 5 languages.
  - Purpose: Clear, mode-organized keyboard shortcut documentation
  - _Requirements: NFR Accessibility (keyboard shortcut guide organized by mode with localized descriptions)_

- [x] 9. Add delete toggle to Features tab
  - File: `example/lib/views/month_view/tabs/month_features_tab.dart`
  - File: `example/lib/l10n/app_en.arb`, `app_es.arb`, `app_fr.arb`, `app_ar.arb`, `app_he.arb`
  - Added `_allowKeyboardDelete` toggle in the Keyboard control section. Wired `onDeleteEventRequested` callback that conditionally calls `controller.removeEvents` and shows a SnackBar.
  - Purpose: Demonstrate delete callback API with enable/disable toggle
  - _Requirements: 7.1–7.5_

- [x] 10. Reverse tab order in Month and Day view showcases
  - File: `example/lib/views/month_view/month_view_showcase.dart`
  - File: `example/lib/views/day_view/day_view_showcase.dart`
  - Swapped the order of Stress Test and Accessibility tabs in both TabBar and TabBarView.
  - Purpose: UX improvement — Accessibility tab is more frequently accessed

## Phase 4: Configurable Key Bindings (new work)

- [x] 11. Create `MCalKeyActivator` and `MCalMonthKeyBindings` classes
  - File: `lib/src/models/mcal_month_key_bindings.dart` (NEW)
  - Create `MCalKeyActivator` immutable class with `const` constructor: `key` (`LogicalKeyboardKey`), `shift` (bool, default false), `control` (bool, default false), `meta` (bool, default false), `alt` (bool, default false). Implement `matches()` method with strict modifier checking. Implement `==`, `hashCode`, `toString`.
  - Create `MCalMonthKeyBindings` immutable class with `const` default constructor. 20 named `Set<MCalKeyActivator>` properties across 4 modes (5 Navigation, 7 Event, 3 Move, 5 Resize). Default values match current hardcoded bindings. Implement `copyWith` for selective overrides.
  - Purpose: Data model for configurable key bindings
  - _Leverage: `MCalCalendarEvent` patterns for `==`/`hashCode`/`copyWith`. `SingleActivator` in Flutter's `Shortcuts` system for `matches()` inspiration._
  - _Requirements: 6.1, 6.2, 6.3, 6.8, 6.9_
  - _Prompt: Implement the task for spec month-keyboard-navigation, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Dart Developer specializing in immutable data models | Task: Create `MCalKeyActivator` and `MCalMonthKeyBindings` in a new file `lib/src/models/mcal_month_key_bindings.dart` as specified in the design doc `.spec-workflow/specs/month-keyboard-navigation/design.md` section "Components and Interfaces". `MCalKeyActivator` pairs a `LogicalKeyboardKey` with optional modifier flags. `matches()` checks both key identity and all four modifier states strictly — if `shift` is false, Shift must NOT be pressed. `MCalMonthKeyBindings` has 20 named `Set<MCalKeyActivator>` properties with `const` defaults matching the current hardcoded key bindings: Navigation Mode (enterEventMode, home, end, pageUp, pageDown), Event Mode (cycleForward, cycleBackward, activate, delete, enterMoveMode, enterResizeMode, exitEventMode), Move Mode (confirmMove, cancelMove, moveToResize), Resize Mode (switchToStartEdge, switchToEndEdge, confirmResize, resizeToMove, cancelResize). Add `copyWith` that returns a new instance with overridden properties. Import `package:flutter/services.dart` for `LogicalKeyboardKey`. Add comprehensive dartdoc for both classes. | Restrictions: Do NOT modify existing files. Do NOT export from `multi_calendar.dart` yet (Task 12). Arrow keys are NOT included — they are hardcoded for directional navigation. Both classes must have `const` constructors. | Success: `dart analyze` clean, `const MCalMonthKeyBindings()` compiles, `MCalKeyActivator(LogicalKeyboardKey.tab, shift: true).matches(...)` works correctly. After completion, set the task to in-progress in tasks.md, log implementation with log-implementation tool, then mark as complete._

- [x] 12. Export `MCalMonthKeyBindings` and `MCalKeyActivator` from `multi_calendar.dart`
  - File: `lib/multi_calendar.dart` (modify existing)
  - Add `export 'src/models/mcal_month_key_bindings.dart';` in alphabetical order with other model exports.
  - Purpose: Make key bindings classes part of the public API
  - _Leverage: Existing export pattern in `lib/multi_calendar.dart`_
  - _Requirements: 6.1 (public API availability)_
  - _Prompt: Implement the task for spec month-keyboard-navigation, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Dart Developer | Task: Add `export 'src/models/mcal_month_key_bindings.dart';` to `lib/multi_calendar.dart`, in alphabetical order with the other model exports. | Restrictions: Do NOT remove existing exports. Only add one line. | Success: `dart analyze` clean, `MCalKeyActivator` and `MCalMonthKeyBindings` importable via `package:multi_calendar/multi_calendar.dart`. After completion, set the task to in-progress in tasks.md, log implementation with log-implementation tool, then mark as complete._

- [x] 13. Add `keyBindings` parameter to `MCalMonthView` and refactor key handlers
  - File: `lib/src/widgets/mcal_month_view.dart` (modify existing)
  - Add `final MCalMonthKeyBindings? keyBindings;` parameter to `MCalMonthView` constructor.
  - In `_MCalMonthViewState`, add `MCalMonthKeyBindings get _keyBindings => widget.keyBindings ?? const MCalMonthKeyBindings();`.
  - Add helper method `bool _matchesAny(Set<MCalKeyActivator> activators, LogicalKeyboardKey key, KeyEvent event)` that extracts modifier state from `HardwareKeyboard.instance` and checks if any activator in the set matches.
  - Refactor `_handleKeyboardEventModeKey`: replace all `key == LogicalKeyboardKey.xxx` checks with `_matchesAny(_keyBindings.xxx, key, event)`. Preserve Shift+Tab detection via the activator's `shift` flag instead of manual `HardwareKeyboard.instance.isShiftPressed` check.
  - Refactor `_handleKeyboardMoveModeKey`: replace hardcoded Enter, Escape, R checks with `_matchesAny` calls.
  - Refactor `_handleKeyboardResizeModeKey`: replace hardcoded S, E, Enter, M, Escape checks with `_matchesAny` calls.
  - Refactor Navigation Mode section in `_handleKeyEvent`: replace hardcoded Home, End, PageUp, PageDown, Enter/Space checks with `_matchesAny` calls.
  - Arrow key checks for directional navigation remain hardcoded (NOT configurable).
  - Purpose: Wire configurable key bindings into existing mode handlers
  - _Leverage: Existing mode handlers, `HardwareKeyboard.instance` for modifier state, `MCalMonthKeyBindings` defaults_
  - _Requirements: 6.4, 6.5, 6.6, 6.7_
  - _Prompt: Implement the task for spec month-keyboard-navigation, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer with expertise in key event handling | Task: Add `keyBindings` parameter to `MCalMonthView` and refactor all four mode handlers to use configurable bindings as specified in the design doc `.spec-workflow/specs/month-keyboard-navigation/design.md` section "Component 3: MCalMonthView modifications". Add `final MCalMonthKeyBindings? keyBindings;` to `MCalMonthView` with `this.keyBindings,` in constructor. Add `MCalMonthKeyBindings get _keyBindings => widget.keyBindings ?? const MCalMonthKeyBindings();` to `_MCalMonthViewState`. Add `bool _matchesAny(Set<MCalKeyActivator> activators, LogicalKeyboardKey key, KeyEvent event)` that reads modifier state from `HardwareKeyboard.instance` and calls `activator.matches()` on each. Then refactor all four handlers: (1) Event Mode — replace `key == LogicalKeyboardKey.tab` with `_matchesAny(_keyBindings.cycleForward, ...)` and `_matchesAny(_keyBindings.cycleBackward, ...)`, replace Enter/Space with `_matchesAny(_keyBindings.activate, ...)`, D/Delete/Backspace with `_matchesAny(_keyBindings.delete, ...)`, M with `_matchesAny(_keyBindings.enterMoveMode, ...)`, R with `_matchesAny(_keyBindings.enterResizeMode, ...)`, Escape with `_matchesAny(_keyBindings.exitEventMode, ...)`; (2) Move Mode — replace Enter, Escape, R with corresponding `_matchesAny` calls; (3) Resize Mode — replace S, E, Enter, M, Escape with `_matchesAny` calls; (4) Navigation Mode in `_handleKeyEvent` — replace Home, End, PageUp, PageDown, Enter/Space with `_matchesAny` calls. Arrow keys for directional navigation MUST remain hardcoded. The Shift+Tab detection currently done via `HardwareKeyboard.instance.isShiftPressed` is now handled by `MCalKeyActivator(LogicalKeyboardKey.tab, shift: true)` in `cycleBackward`, so the explicit Shift check can be removed. | Restrictions: Do NOT change any behavior — with default `MCalMonthKeyBindings`, the refactored code must produce identical behavior to the current hardcoded version. Do NOT make arrow key directional navigation configurable. Keep `_buildDefaultShortcuts` and `_buildActionsMap` unchanged (Cmd+N is separate). | Success: `dart analyze` clean, all existing keyboard navigation tests pass without modification (proving behavioral equivalence), `MCalMonthView(keyBindings: ...)` compiles. After completion, set the task to in-progress in tasks.md, log implementation with log-implementation tool, then mark as complete._

- [x] 14. Create key bindings unit and widget tests
  - File: `test/models/mcal_month_key_bindings_test.dart` (NEW)
  - File: `test/widgets/mcal_month_view_key_bindings_test.dart` (NEW)
  - Unit tests for `MCalKeyActivator`: `matches()` for exact key, modifier match, modifier mismatch, multiple modifiers. `==`/`hashCode` for identical and differing instances.
  - Unit tests for `MCalMonthKeyBindings`: default constructor produces correct defaults, `copyWith` overrides specific properties while preserving others, `const` construction compiles.
  - Widget tests: custom key bindings that remap an action (e.g., change `enterMoveMode` from M to X) — verify X enters Move Mode and M does not. Disabled action (`delete: {}`) — verify D does nothing. Modifier-aware binding (`MCalKeyActivator(LogicalKeyboardKey.keyA, control: true)`) — verify Ctrl+A triggers but plain A does not. Default bindings — verify all existing behavior unchanged.
  - Purpose: Comprehensive testing of key bindings system
  - _Leverage: Existing keyboard navigation widget tests for test patterns, `flutter_test` `sendKeyEvent`/`simulateKeyDownEvent`_
  - _Requirements: 6.1–6.9_
  - _Prompt: Implement the task for spec month-keyboard-navigation, first run spec-workflow-guide to get the workflow guide then implement the task: Role: QA Engineer specializing in Dart/Flutter testing | Task: Create comprehensive tests for the key bindings system. (1) In `test/models/mcal_month_key_bindings_test.dart`: test `MCalKeyActivator.matches()` for exact key match with no modifiers, key match with Shift required, key match but wrong modifier (should fail), multiple modifiers. Test `==` and `hashCode`. Test `MCalMonthKeyBindings` default constructor has correct defaults for all 20 properties. Test `copyWith` overrides one property while preserving others. Test `const MCalMonthKeyBindings()` compiles in a const context. (2) In `test/widgets/mcal_month_view_key_bindings_test.dart`: create `MCalMonthView` with custom `keyBindings` parameter. Test remapped action: set `enterMoveMode: {MCalKeyActivator(LogicalKeyboardKey.keyX)}`, enter Event Mode, press X → verify Move Mode entered, press M → verify NOT handled. Test disabled action: set `delete: {}`, enter Event Mode, press D → verify no deletion. Test modifier binding: set `activate: {MCalKeyActivator(LogicalKeyboardKey.keyA, control: true)}`, enter Event Mode → verify Ctrl+A triggers activation but plain A does not. Test default bindings: create `MCalMonthView` without `keyBindings` → verify all standard keyboard navigation works identically. | Restrictions: Do NOT modify existing test files. Use existing test patterns from `test/widgets/` for widget test setup (controller, events, etc.). | Success: All tests pass with `flutter test test/models/mcal_month_key_bindings_test.dart` and `flutter test test/widgets/mcal_month_view_key_bindings_test.dart`. After completion, set the task to in-progress in tasks.md, log implementation with log-implementation tool, then mark as complete._

- [x] 15. Update Accessibility tab guide to reflect configurable bindings (documentation only)
  - File: `example/lib/views/month_view/tabs/month_accessibility_tab.dart`
  - File: `example/lib/l10n/app_en.arb`, `app_es.arb`, `app_fr.arb`, `app_ar.arb`, `app_he.arb`
  - Add a note to the keyboard shortcut guide indicating that key bindings are configurable via `MCalMonthKeyBindings`. This is informational only — the guide displays the default bindings and notes that developers can customize them.
  - Purpose: Documentation awareness of configurable bindings
  - _Leverage: Existing `_ModeSection` and `_ShortcutRow` widgets, existing localization keys_
  - _Requirements: 6.1 (developer awareness), NFR Accessibility_
  - _Prompt: Implement the task for spec month-keyboard-navigation, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Add a brief informational note to the keyboard shortcut guide in `month_accessibility_tab.dart` indicating that key bindings are configurable via `MCalMonthKeyBindings`. Add it as a small `Text` widget below the keyboard shortcuts section header, styled as a subtitle/caption. Add a new localization key (e.g., `accessibilityMonthKeyBindingsNote`) to all 5 ARB files with text like "Key bindings shown are defaults. Developers can customize via MCalMonthKeyBindings." translated to each language. | Restrictions: Do NOT change existing shortcut rows. Do NOT change the mode section structure. Keep it brief — one line of text. | Success: The note appears below the "Keyboard Shortcuts" header, is localized in all 5 languages, and does not affect layout spacing. After completion, set the task to in-progress in tasks.md, log implementation with log-implementation tool, then mark as complete._

## Phase 5: Navigation Mode — Create Event (Requirement 8)

- [x] 16. Add `createEvent` property to `MCalMonthKeyBindings`
  - File: `lib/src/models/mcal_month_key_bindings.dart`
  - Add a new `createEvent` property to `MCalMonthKeyBindings` in the Navigation Mode section, with default `[MCalKeyActivator(LogicalKeyboardKey.keyN)]`. Add it to the `const` default constructor, to all named field declarations, to `copyWith`, and to `toString`. Update dartdoc to document the new property (default: N, Navigation Mode only, pass `[]` to disable). Update the property count in the class-level dartdoc comment from 20 to 21.
  - Purpose: Make the N key for create configurable and disableable, consistent with all other action bindings
  - _Leverage: Existing `MCalMonthKeyBindings` pattern — mirror any other Navigation Mode property (e.g., `home`, `end`)_
  - _Requirements: 8.5, 6.6 (Navigation Mode binding slot)_
  - _Prompt: Implement the task for spec month-keyboard-navigation, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Dart Developer | Task: Add a `createEvent` property to `MCalMonthKeyBindings` in `lib/src/models/mcal_month_key_bindings.dart`. It belongs in the Navigation Mode group of properties. Default value: `[MCalKeyActivator(LogicalKeyboardKey.keyN)]`. Follow the exact same pattern as existing Navigation Mode properties: add to the `const` constructor parameter list with a default, add as a `final List<MCalKeyActivator>` field, add to `copyWith` as an optional named parameter, and include in `toString`. Add dartdoc explaining it is Navigation Mode only, default is N, and pass `[]` to disable. Update the class-level comment from "20" to "21" named properties. | Restrictions: Do NOT modify any other file. Do NOT change any existing property. | Success: `flutter analyze lib/src/models/mcal_month_key_bindings.dart` clean. `const MCalMonthKeyBindings()` still compiles. `const MCalMonthKeyBindings(createEvent: []).createEvent.isEmpty` evaluates to true. After completion, set the task to in-progress in tasks.md, log implementation with log-implementation tool, then mark as complete._

- [x] 17. Refactor `MCalMonthView`: remove legacy Shortcuts system, update `onCreateEventRequested` signature, add N key in Navigation Mode
  - File: `lib/src/widgets/mcal_month_view.dart`
  - **Remove:**
    - `MCalMonthViewCreateEventIntent` class and its dartdoc
    - `final Map<ShortcutActivator, Intent>? keyboardShortcuts;` field, constructor parameter, and all dartdoc references to it
    - `_buildDefaultShortcuts()`, `_buildShortcutsMap()`, and `_buildActionsMap()` private methods
    - The `Shortcuts` and `Actions` widget wrappers in `build()` that reference these methods (the calendar widget they wrap becomes the direct return value instead)
    - Import of `package:flutter/services.dart` `ShortcutActivator`/`Intent`/`SingleActivator`/`CallbackAction` if no longer needed (verify first — `LogicalKeyboardKey` is in `services.dart` too, so the import likely stays)
  - **Modify:**
    - `onCreateEventRequested` parameter type: from `VoidCallback?` to `FutureOr<bool> Function(BuildContext, DateTime)?`
    - Update dartdoc for `onCreateEventRequested` to document the new signature, that `BuildContext` enables `showDialog`, that `DateTime` is the focused cell's date (no time component), that the `bool` return is currently ignored by the library but the `Future` is awaited, and that returning `true`/`false` is idiomatic for sync consumers
  - **Add:**
    - In `_handleKeyEvent`, inside the Navigation Mode block (after the Enter/Space handler), add: `if (_matchesAny(_keyBindings.createEvent, key)) { widget.onCreateEventRequested?.call(context, focusedDate); return KeyEventResult.handled; }`. If the callback returns `FutureOr<bool>`, handle it inline similarly to `_handleDeleteResult` but without the mode-exit: if a `Future`, call `.then((_) {})` to discard the result; if sync, do nothing further. The calendar stays in Navigation Mode regardless.
  - Purpose: Complete removal of legacy Shortcuts/Actions wiring; migrate create to raw key handler; update callback API
  - _Leverage: `_matchesAny` and `_keyBindings` already in place from Task 13; `_handleDeleteResult` as reference for `FutureOr` handling pattern; `focusedDate` already resolved in the Navigation Mode block_
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.6, 8.7_
  - _Prompt: Implement the task for spec month-keyboard-navigation, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: In `lib/src/widgets/mcal_month_view.dart`, perform three coordinated changes: (1) REMOVE the legacy Shortcuts system — delete the `MCalMonthViewCreateEventIntent` class (~line 137), the `keyboardShortcuts` field and constructor parameter (~line 420 and ~line 939), `_buildDefaultShortcuts()`, `_buildShortcutsMap()`, and `_buildActionsMap()` methods (~lines 1808–1841), and the `Shortcuts`/`Actions` widget wrappers in `build()` that wrap the calendar — the child they wrap should become the direct return instead. (2) UPDATE `onCreateEventRequested`: change its type from `VoidCallback?` to `FutureOr<bool> Function(BuildContext, DateTime)?`. Update its dartdoc to explain `BuildContext` enables dialog display, `DateTime` is the focused cell date (midnight, no time), `bool` return is currently ignored by the library but `Future` is awaited, sync consumers return `true` or `false` directly. (3) ADD N key handler in `_handleKeyEvent` Navigation Mode block: after the `enterEventMode` check, add `if (_matchesAny(_keyBindings.createEvent, key)) { final result = widget.onCreateEventRequested?.call(context, focusedDate); if (result is Future) result.then((_) {}); return KeyEventResult.handled; }`. Keep the null guard — if `onCreateEventRequested` is null, still return `handled` to absorb the key. | Restrictions: Do NOT change any other keyboard handler. Do NOT change how the calendar renders or how drag/resize works. Keep all existing `focusedDate` resolution logic in the Navigation Mode block unchanged. Run `flutter analyze` and fix any issues before logging. | Success: `flutter analyze` clean, `flutter test` all pass. `MCalMonthView(onCreateEventRequested: (ctx, date) { showDialog(...); return true; })` compiles. `MCalMonthViewCreateEventIntent` no longer exists. After completion, set the task to in-progress in tasks.md, log implementation with log-implementation tool, then mark as complete._

- [x] 18. Update example app for create callback
  - File: `example/lib/views/month_view/tabs/month_features_tab.dart`
  - File: `example/lib/views/month_view/tabs/month_accessibility_tab.dart`
  - File: `example/lib/l10n/app_en.arb`, `app_es.arb`, `app_fr.arb`, `app_ar.arb`, `app_he.arb`
  - **Features tab** (`month_features_tab.dart`): The existing `onCreateEventRequested` call (if present) uses `VoidCallback` — update to `(context, date) { showDialog or SnackBar showing the date; return true; }`. If there is no wiring yet, add it. Add a `_allowKeyboardCreate` bool state field and a toggle in the Keyboard section of the control panel (alongside the existing `_allowKeyboardDelete` toggle). When disabled, pass `null` for `onCreateEventRequested`; when enabled, show a `SnackBar` with the date and return `true`. Add a localization key `settingAllowKeyboardCreate` to all 5 ARB files.
  - **Accessibility tab** (`month_accessibility_tab.dart`): Add an `N` shortcut row to the Navigation Mode section (between the Enter/Space row and the Home row). Add a localization key `accessibilityMonthNavN` to all 5 ARB files with text like "Create new event on focused date". The key string should reuse the existing `accessibilityShortcutN` key if it exists, or use the literal string `'N'`.
  - Purpose: Demonstrate the new create callback in the example app and document it in the keyboard guide
  - _Leverage: Existing `_allowKeyboardDelete` toggle pattern in Features tab; existing `_ShortcutRow` pattern in Accessibility tab; existing ARB structure_
  - _Requirements: 8.1, 8.2, NFR Accessibility (keyboard guide updated)_
  - _Prompt: Implement the task for spec month-keyboard-navigation, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Update the example app in two places. (1) In `month_features_tab.dart`: add a `bool _allowKeyboardCreate` state field (default false). Add a toggle row in the Keyboard control panel section for it, using localization key `settingAllowKeyboardCreate` (text: "Allow Keyboard Create"). Wire `MCalMonthView.onCreateEventRequested` to `_allowKeyboardCreate ? (context, date) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Create event on \${DateFormat.yMd().format(date)}'))); return true; } : null`. Add `settingAllowKeyboardCreate` to all 5 ARB files (en: "Allow Keyboard Create", translate to es/fr/ar/he). (2) In `month_accessibility_tab.dart`: in the Navigation Mode `_ShortcutRow` list, add a row after the Enter/Space row using the key label `'N'` (or `l10n.accessibilityShortcutN` if it exists — check the ARB file first) and a new localization key `accessibilityMonthNavN`. Add `accessibilityMonthNavN` to all 5 ARB files (en: "Create new event on focused date", translate). | Restrictions: Do NOT restructure the control panel. Do NOT change any other callbacks. Check whether `accessibilityShortcutN` already exists in the ARB before adding a duplicate. | Success: `flutter analyze example/` clean. Keyboard Create toggle appears in the Features tab Keyboard section. N key row appears in Navigation Mode in Accessibility tab. After completion, set the task to in-progress in tasks.md, log implementation with log-implementation tool, then mark as complete._

- [x] 19. Tests for Navigation Mode create event
  - File: `test/widgets/mcal_month_view_create_event_test.dart` (NEW)
  - Write widget tests covering:
    1. **N key triggers callback in Navigation Mode**: pump calendar with `onCreateEventRequested` callback, focus, press N → verify callback called with correct `BuildContext` and focused date.
    2. **N key absorbed when callback is null**: press N with `onCreateEventRequested: null` → verify no crash and key is absorbed (no focus escape or other side effect).
    3. **N key does NOT trigger in Event Mode**: enter Event Mode (press Enter on a cell with events), press N → verify callback NOT called.
    4. **Async callback**: provide a callback that returns a `Future<bool>` (using a `Completer`) → verify calendar stays interactive while the future is pending, verify no crash when future completes.
    5. **Remapped createEvent binding**: provide `keyBindings: MCalMonthKeyBindings(createEvent: [MCalKeyActivator(LogicalKeyboardKey.keyC)])` → verify C triggers callback, N does not.
    6. **Disabled createEvent binding**: provide `keyBindings: MCalMonthKeyBindings(createEvent: [])` → verify N does not trigger callback.
    7. **Focused date passed correctly**: set `controller.setFocusedDate(DateTime(2025, 3, 15))`, press N → verify callback receives `DateTime(2025, 3, 15)`.
  - Purpose: Verify behavioral correctness of Requirement 8
  - _Leverage: Existing widget test patterns from `test/widgets/mcal_keyboard_selection_test.dart` (controller setup, `pumpCalendar` helper, `focusAndSendKey` helper)_
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.7_
  - _Prompt: Implement the task for spec month-keyboard-navigation, first run spec-workflow-guide to get the workflow guide then implement the task: Role: QA Engineer specializing in Flutter widget testing | Task: Create `test/widgets/mcal_month_view_create_event_test.dart` with a test group "Navigation Mode create event". Follow the exact test setup pattern from `test/widgets/mcal_keyboard_selection_test.dart`: create `_TestController extends MCalEventController`, `setUpAll` with `initializeDateFormatting`, `setUp`/`tearDown` for controller lifecycle, a `pumpCalendar` helper that pumps `MCalMonthView` in `MaterialApp > Scaffold > SizedBox(600x400)`, and a `focusAndSendKey` helper that taps then sends a key. Write the 7 test cases described in this task's bullet points. For the async test use a `Completer<bool>` and verify the calendar remains interactive (pump and settle with a short timeout). For "N does not trigger in Event Mode", add a sample event on the focused date, press Enter to enter Event Mode, then press N. | Restrictions: Do NOT modify existing test files. Mirror the existing test structure precisely — same helper signatures, same MaterialApp wrapping, same controller pattern. | Success: All 7 tests pass with `flutter test test/widgets/mcal_month_view_create_event_test.dart`. After completion, set the task to in-progress in tasks.md, log implementation with log-implementation tool, then mark as complete._
