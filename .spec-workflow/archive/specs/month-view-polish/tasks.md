# Tasks Document: Month View Polish

## Phase 1: Foundation (details classes, drag handler state, animation refactor)

- [x] 1. Add `MCalResizeEdge` enum and resize callback detail classes
  - File: `lib/src/widgets/mcal_callback_details.dart`
  - Create `MCalResizeEdge` enum with values: `start`, `end`
  - Create `MCalResizeWillAcceptDetails` class with fields: `event`, `proposedStartDate`, `proposedEndDate`, `resizeEdge`
  - Create `MCalEventResizedDetails` class with fields: `event`, `oldStartDate`, `oldEndDate`, `newStartDate`, `newEndDate`, `resizeEdge`, `isRecurring`, `seriesId`
  - Follow the exact same immutable pattern as existing `MCalEventDroppedDetails` and `MCalDragWillAcceptDetails`
  - Add full dartdoc with examples
  - Purpose: Establish type-safe detail objects for resize callbacks
  - _Leverage: Existing callback detail patterns in `lib/src/widgets/mcal_callback_details.dart` (e.g. `MCalEventDroppedDetails` at ~line 432, `MCalDragWillAcceptDetails` at ~line 467)_
  - _Requirements: 1.15, 1.16_
  - _Prompt: Implement the task for spec month-view-polish, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Dart Developer specializing in data modeling | Task: Add `MCalResizeEdge` enum and two new detail classes (`MCalResizeWillAcceptDetails`, `MCalEventResizedDetails`) to `lib/src/widgets/mcal_callback_details.dart`. Follow the design doc `.spec-workflow/specs/month-view-polish/design.md` section "Component 3: Resize Callback Details" exactly. Model them after the existing `MCalEventDroppedDetails` and `MCalDragWillAcceptDetails` in the same file. Add full dartdoc with usage examples. | Restrictions: Do NOT modify any existing classes. Append to end of file. Do NOT export from multi_calendar.dart yet (Task 6 handles that). | Success: `dart analyze` clean, new classes compile, follow existing patterns. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

- [x] 2. Add resize state machine to `MCalDragHandler`
  - File: `lib/src/widgets/mcal_drag_handler.dart`
  - Add private resize state fields: `_isResizing`, `_resizingEvent`, `_resizeEdge`, `_resizeOriginalStart`, `_resizeOriginalEnd`
  - Add public getters: `isResizing`, `resizingEvent`, `resizeEdge`
  - Implement `startResize(MCalCalendarEvent event, MCalResizeEdge edge)` — sets resize state, stores original dates, notifies listeners
  - Implement `updateResize({required DateTime proposedStart, required DateTime proposedEnd, required bool isValid, required List<MCalHighlightCellInfo> cells})` — updates shared proposed range fields and highlighted cells, notifies
  - Implement `completeResize()` — returns `(DateTime, DateTime)?` tuple of proposed dates if valid, clears state
  - Implement `cancelResize()` — clears all resize state, notifies
  - Implement private `_clearResizeState()` helper
  - Ensure mutual exclusivity: `startResize` asserts `!isDragging`, `startDrag` asserts `!isResizing`
  - The shared fields `_proposedStartDate`, `_proposedEndDate`, `_isProposedDropValid`, `_highlightedCells` are reused by both drag and resize (mutually exclusive states)
  - Purpose: Extend drag handler with resize lifecycle, reusing highlight infrastructure
  - _Leverage: Existing drag state pattern in `lib/src/widgets/mcal_drag_handler.dart` (`startDrag`, `updateDrag`, `completeDrag`, `cancelDrag`). Design doc section "Component 1: Resize State in MCalDragHandler"._
  - _Requirements: 1.7, 1.8, 1.9, 1.13, 1.14_
  - _Prompt: Implement the task for spec month-view-polish, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in state management | Task: Add resize state machine to `MCalDragHandler` in `lib/src/widgets/mcal_drag_handler.dart` following the design doc `.spec-workflow/specs/month-view-polish/design.md` section "Component 1" exactly. Add private fields (`_isResizing`, `_resizingEvent`, `_resizeEdge`, `_resizeOriginalStart`, `_resizeOriginalEnd`), public getters, and methods (`startResize`, `updateResize`, `completeResize`, `cancelResize`, `_clearResizeState`). Reuse the shared `_proposedStartDate`/`_proposedEndDate`/`_isProposedDropValid`/`_highlightedCells` fields. Add assertions for mutual exclusivity with drag state. Import `MCalResizeEdge` from `mcal_callback_details.dart`. | Restrictions: Do NOT modify existing drag methods. Drag and resize are mutually exclusive. | Success: `dart analyze` clean, existing drag tests pass, resize methods work independently. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

- [x] 3. Refactor `enableAnimations` from `bool` to `bool?` with reduced motion detection
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Change `final bool enableAnimations` to `final bool? enableAnimations` (line ~378)
  - Change constructor default from `this.enableAnimations` with a value of `true` to `this.enableAnimations` with no default (null default) (line ~672)
  - Update dartdoc to explain: `null` follows OS reduced motion preference, `true` forces on, `false` forces off
  - Add private `bool _resolveAnimationsEnabled(BuildContext context)` method that checks `widget.enableAnimations` first, then falls back to `!MediaQuery.accessibilityFeaturesOf(context).reduceMotion`
  - Replace all `widget.enableAnimations` usages (currently ~line 1059) with the resolved value
  - Purpose: Automatically respect OS reduced motion while preserving developer override
  - _Leverage: Existing `enableAnimations` usage pattern in `mcal_month_view.dart`. Design doc section "Component 6: Refactored Animation Control"._
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8_
  - _Prompt: Implement the task for spec month-view-polish, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in accessibility | Task: Refactor `enableAnimations` from `bool` to `bool?` in `MCalMonthView` at `lib/src/widgets/mcal_month_view.dart`. Change the parameter type and default. Add `_resolveAnimationsEnabled(BuildContext context)` that checks explicit override first, then `MediaQuery.accessibilityFeaturesOf(context).reduceMotion`. Replace all `widget.enableAnimations` usages with the resolved value. Update dartdoc per design doc `.spec-workflow/specs/month-view-polish/design.md` section "Component 6". | Restrictions: `true` and `false` must retain their exact previous behavior. `setDisplayDate(animate: false)` must still bypass all animation logic. Do NOT change the controller's `shouldAnimateNextChange` mechanism. | Success: `dart analyze` clean, existing animation tests pass with `enableAnimations: true`, reduced motion correctly disables animation when `enableAnimations` is null. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

## Phase 2: Multi-Day Semantic Span Labels (independent, quick win)

- [x] 4. Add multi-day span localization keys
  - File: `lib/src/utils/mcal_localization.dart`
  - Add `formatMultiDaySpanLabel(int spanLength, int dayPosition, Locale locale)` method to `MCalLocalizations`
  - Add localization template keys:
    - English (`_enStrings`): `'multiDaySpanLabel': '{days}-day event, day {position} of {days}'`
    - Spanish (`_esMxStrings`): `'multiDaySpanLabel': 'evento de {days} días, día {position} de {days}'`
  - The method does `{days}` → `spanLength.toString()` and `{position}` → `dayPosition.toString()` replacement
  - Purpose: Localizable span label infrastructure
  - _Leverage: Existing `_enStrings`/`_esMxStrings` maps and `getLocalizedString` pattern in `lib/src/utils/mcal_localization.dart`_
  - _Requirements: 5.5_
  - _Prompt: Implement the task for spec month-view-polish, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in i18n | Task: Add `formatMultiDaySpanLabel(int spanLength, int dayPosition, Locale locale)` to `MCalLocalizations` in `lib/src/utils/mcal_localization.dart`. Add template string keys `'multiDaySpanLabel'` to both `_enStrings` and `_esMxStrings`. The method gets the template via `getLocalizedString`, then replaces `{days}` and `{position}` placeholders. Follow design doc `.spec-workflow/specs/month-view-polish/design.md` section "Component 9". | Restrictions: Do NOT modify existing localization keys. Append new keys. | Success: `dart analyze` clean, method returns correct formatted strings for both locales. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

- [x] 5. Enrich `_EventTileWidget._getSemanticLabel` with multi-day span info
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Modify `_EventTileWidget._getSemanticLabel()` (currently at ~line 4773) to check `spanLength > 1`
  - When multi-day, calculate day position using `daysBetween` (DST-safe) between event start and display date
  - Append localized span label from `MCalLocalizations.formatMultiDaySpanLabel`
  - Result format: `"Team Offsite, All day, 3-day event, day 2 of 3"`
  - Single-day events remain unchanged
  - Purpose: Screen reader users get full span context for multi-day events
  - _Leverage: `_EventTileWidget` at ~line 4538 in `mcal_month_view.dart`. `daysBetween` from `lib/src/utils/date_utils.dart`. `MCalLocalizations` from Task 4._
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.6_
  - _Prompt: Implement the task for spec month-view-polish, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in accessibility | Task: Modify `_EventTileWidget._getSemanticLabel()` in `lib/src/widgets/mcal_month_view.dart` (~line 4773). When `spanLength > 1`, calculate `dayPosition` using DST-safe `daysBetween(eventStartDate, cellDate) + 1`, then append `MCalLocalizations().formatMultiDaySpanLabel(spanLength, dayPosition, locale)`. Single-day events (spanLength is 1 or less) keep current label. Follow design doc section "Component 9". | Restrictions: Do NOT change single-day event labels. Use `daysBetween` (not Duration arithmetic) for DST safety. | Success: `dart analyze` clean. Multi-day event semantic label includes span info. Single-day unchanged. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

## Phase 3: Edge-Drag Resizing

- [x] 6. Add resize parameters to `MCalMonthView` and export new types
  - Files: `lib/src/widgets/mcal_month_view.dart`, `lib/multi_calendar.dart`
  - Add parameters to `MCalMonthView`:
    - `bool? enableEventResize` (nullable, default null for auto-detect)
    - `bool Function(BuildContext, MCalResizeWillAcceptDetails)? onResizeWillAccept`
    - `bool Function(BuildContext, MCalEventResizedDetails)? onEventResized`
  - Add these to the constructor with dartdoc
  - Add private `bool _resolveEnableResize(BuildContext context)` method (platform detection: web enabled, desktop enabled, tablet enabled, phone disabled)
  - Export `MCalResizeEdge`, `MCalResizeWillAcceptDetails`, `MCalEventResizedDetails` from `lib/multi_calendar.dart`
  - Purpose: Public API surface for event resizing
  - _Leverage: Existing drag-and-drop parameter pattern in `MCalMonthView` (~line 467-702). Design doc section "Component 5: Platform-Aware Auto-Enable"._
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.15, 1.16_
  - _Prompt: Implement the task for spec month-view-polish, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in widget API design | Task: Add three new parameters to `MCalMonthView` in `lib/src/widgets/mcal_month_view.dart`: `enableEventResize` (bool?), `onResizeWillAccept`, `onEventResized`. Add `_resolveEnableResize(BuildContext)` method per design doc `.spec-workflow/specs/month-view-polish/design.md` section "Component 5". Export `MCalResizeEdge`, `MCalResizeWillAcceptDetails`, `MCalEventResizedDetails` from `lib/multi_calendar.dart`. | Restrictions: Do NOT implement resize interaction yet (Tasks 7-8). Just the parameter declarations, constructor entries, platform detection, and exports. | Success: `dart analyze` clean, new types importable from `package:multi_calendar/multi_calendar.dart`, existing tests pass. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

- [x] 7. Implement `_ResizeHandle` widget and integrate into event tiles
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Create private `_ResizeHandle` StatelessWidget with:
    - `edge` (MCalResizeEdge), `handleWidth` (double, default 8.0)
    - `onResizeStart`, `onResizeUpdate` (double dx), `onResizeEnd`, `onResizeCancel` callbacks
    - Renders a `Positioned` child at the leading or trailing edge (RTL-aware using `Directionality`)
    - Uses `SystemMouseCursors.resizeColumn` on hover-capable platforms
    - Visual: subtle vertical line/grip that appears on hover (desktop) or is always subtly visible (tablet)
    - Wraps in `GestureDetector` with `onHorizontalDragStart`/`Update`/`End`/`Cancel`
  - Modify event tile rendering in Layer 2 (the week layout builder's `eventTileBuilder`):
    - When resize is enabled and the segment is start-of-span: add leading `_ResizeHandle`
    - When resize is enabled and the segment is end-of-span: add trailing `_ResizeHandle`
    - Single-day events: no resize handles (already minimum duration)
    - Wrap the tile content and handles in a `Stack`
  - Handles should have semantic labels: "Resize start edge" / "Resize end edge"
  - Purpose: Visible, interactive resize affordance on event tile edges
  - _Leverage: `_EventTileWidget` at ~line 4538. `MCalDraggableEventTile` pattern. Week layout context `eventTileBuilder`. Design doc section "Component 2: Resize Handle Affordance"._
  - _Requirements: 1.7, 1.8, 1.11, 1.12, 1.23_
  - _Prompt: Implement the task for spec month-view-polish, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in gesture handling and UI | Task: Create `_ResizeHandle` widget and integrate it into event tiles in `lib/src/widgets/mcal_month_view.dart`. Follow design doc `.spec-workflow/specs/month-view-polish/design.md` section "Component 2" exactly. The handle is a thin (8dp) draggable zone on the start or end edge, RTL-aware via `Directionality`, with `GestureDetector` horizontal drag handlers. Add handles to the Layer 2 event tile builder: leading handle on start-of-span, trailing on end-of-span. No handles on single-day events. Use `SystemMouseCursors.resizeColumn`. Add semantic labels. | Restrictions: Do NOT implement the resize logic (date calculation, handler updates) yet — that is Task 8. Just wire up the visual handles and their gesture callbacks to placeholder functions. | Success: `dart analyze` clean, handles render on multi-day event edges, cursor changes on hover, handles are visually subtle. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

- [x] 8. Implement resize interaction logic (gestures, preview, completion)
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Wire the `_ResizeHandle` callbacks to the drag handler:
    - `onResizeStart`: call `dragHandler.startResize(event, edge)`
    - `onResizeUpdate(dx)`: accumulate dx, calculate day delta using `(dxAccumulated / dayWidth).round()`, compute proposed start/end using DST-safe `DateTime(y, m, d + delta)`, enforce minimum 1 day, call `onResizeWillAccept` for validation, call `dragHandler.updateResize(...)` to show Layer 3/4 preview
    - `onResizeEnd`: call `_handleResizeEnd()` — mirror `_handleDrop` flow: get final dates from `dragHandler.completeResize()`, call `onEventResized` callback, update controller
    - `onResizeCancel`: call `dragHandler.cancelResize()`
  - Implement `_handleResizeEnd()` method:
    - Get proposed dates from `dragHandler.completeResize()`
    - If null (invalid), return
    - Calculate new start/end preserving time components using calendar-day arithmetic
    - Build `MCalEventResizedDetails` with old/new dates, edge, isRecurring, seriesId
    - Call `onEventResized` callback — if returns false, revert
    - For non-recurring: `controller.addEvents([updatedEvent])`
    - For recurring: `controller.modifyOccurrence(seriesId, originalDate, updatedEvent)`
  - No cross-month edge navigation during resize
  - Purpose: Complete resize interaction with validation, preview, and event mutation
  - _Leverage: `_handleDrop` method (~line 2550) for the completion flow pattern. `daysBetween` for DST-safe delta. Design doc section "Component 4: Resize Interaction in Month View"._
  - _Requirements: 1.7, 1.8, 1.9, 1.10, 1.13, 1.14, 1.15, 1.16, 1.17, 1.18, 1.19, 1.20, 1.21, 1.22_
  - _Prompt: Implement the task for spec month-view-polish, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in drag gestures and state management | Task: Wire `_ResizeHandle` callbacks to `MCalDragHandler` resize state in `lib/src/widgets/mcal_month_view.dart`. Implement the full resize interaction: gesture → day delta calculation (DST-safe) → minimum enforcement → validation → preview update → completion → event mutation. Implement `_handleResizeEnd()` mirroring `_handleDrop()` (~line 2550). For recurring events, use `controller.modifyOccurrence`. Follow design doc section "Component 4" exactly. | Restrictions: All date arithmetic MUST use `DateTime(y, m, d + delta)` form, NEVER `Duration(days:)`. No cross-month edge navigation. Minimum 1 day duration. | Success: `dart analyze` clean, edge-drag resizing works end-to-end: drag edge → preview shows → release → event updates. Recurring creates modified exception. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

## Phase 4: Keyboard Event Moving

- [x] 9. Implement keyboard event selection and move mode
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Add private state fields: `_isKeyboardMoveMode`, `_keyboardMoveEvent`, `_keyboardMoveOriginalStart`, `_keyboardMoveOriginalEnd`, `_keyboardMoveEventIndex` (for multi-event cycling)
  - Modify `_handleKeyEvent` (~line 1442):
    - When Enter/Space is pressed on a focused cell AND `enableDragAndDrop` is true AND cell has events: enter event selection mode
    - If one event: select immediately. If multiple: highlight first event, Tab/Shift+Tab cycles, Enter confirms selection
    - Once selected: Arrow keys compute move delta (+1/-1 day, +/-7 days for Up/Down)
    - Use `dragHandler.startDrag(event, originalDate)` on first arrow key (reusing drag state)
    - Update `dragHandler` proposed range and highlighted cells at each step
    - Call `onDragWillAccept` for validation
    - Enter: call existing `_handleDrop` flow. Announce "Moved {title} to {date}"
    - Escape: `dragHandler.cancelDrag()`, exit mode. Announce "Move cancelled"
  - Add `SemanticsService.announce` calls at each step (selection, each move, confirm, cancel)
  - Handle month boundary: when proposed date leaves visible month, navigate via `controller.setDisplayDate`
  - Purpose: Accessible keyboard alternative to drag-and-drop
  - _Leverage: Existing `_handleKeyEvent` at ~line 1442. `MCalDragHandler.startDrag/updateDrag/completeDrag`. `_handleDrop` at ~line 2550. Design doc section "Component 7: Keyboard Event Moving"._
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10, 3.11, 3.12, 3.13, 3.14, 3.15_
  - _Prompt: Implement the task for spec month-view-polish, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in keyboard accessibility | Task: Implement keyboard event selection and move mode in `_handleKeyEvent` in `lib/src/widgets/mcal_month_view.dart`. Add state fields for keyboard-move mode. When Enter/Space on a cell with events and `enableDragAndDrop` is true: enter selection mode. Tab/Shift+Tab cycles events, Enter selects. Arrow keys move the event using `dragHandler.startDrag/updateDrag`. Enter confirms via `_handleDrop`, Escape cancels. Add `SemanticsService.announce` at each step. Handle month boundary navigation. Follow design doc section "Component 7" exactly. | Restrictions: Reuse existing `MCalDragHandler` and `_handleDrop` flow — do NOT duplicate the drop logic. Use DST-safe arithmetic for date calculations. | Success: `dart analyze` clean, keyboard move works end-to-end with announcements: select → arrow keys → preview shown → Enter confirms → event moves. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

## Phase 5: Keyboard Event Resizing

- [x] 10. Implement keyboard resize mode (extends keyboard move)
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Add state fields: `_isKeyboardResizeMode`, `_keyboardResizeEdge` (MCalResizeEdge, default `.end`)
  - Extend `_handleKeyEvent`:
    - When an event is selected (keyboard-move mode active), pressing `R` enters resize mode:
      - Set `_isKeyboardResizeMode` to `true`, call `dragHandler.startResize(event, MCalResizeEdge.end)`
      - Announce: "Resize mode. Adjusting end edge. Arrow keys to resize, S for start, E for end, Enter to confirm, Escape to cancel."
    - `S` key: switch to start edge. `E` key: switch to end edge. Announce edge change.
    - `M` key: cancel resize, return to move mode for same event
    - Arrow keys: adjust active edge by delta (+1/-1 day, +/-7 days), enforce minimum 1 day, update `dragHandler.updateResize(...)`, call `onResizeWillAccept`, announce "Resizing {title} end to {date}, {N} days"
    - Enter: call `_handleResizeEnd()` (from Task 8). Announce "Resized {title} to {start} through {end}"
    - Escape: `dragHandler.cancelResize()`, exit resize mode. Announce "Resize cancelled"
  - Purpose: Accessible keyboard alternative to edge-drag resizing
  - _Leverage: Keyboard move mode from Task 9. `MCalDragHandler.startResize/updateResize/completeResize` from Task 2. `_handleResizeEnd` from Task 8. Design doc section "Component 8: Keyboard Event Resizing"._
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9, 4.10, 4.11, 4.12, 4.13, 4.14_
  - _Prompt: Implement the task for spec month-view-polish, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in keyboard accessibility | Task: Extend keyboard event handling in `lib/src/widgets/mcal_month_view.dart` to support resize mode. When event is selected and user presses `R`: enter resize mode using `dragHandler.startResize`. S/E switch edge, M returns to move mode, Arrow keys adjust edge date (DST-safe), Enter confirms via `_handleResizeEnd`, Escape cancels. Add `SemanticsService.announce` at each step. Follow design doc section "Component 8" exactly. | Restrictions: Reuse `MCalDragHandler` resize state machine and `_handleResizeEnd` from Task 8. Do NOT duplicate resize completion logic. Enforce minimum 1 day. | Success: `dart analyze` clean, keyboard resize works: R → arrow keys → preview → Enter confirms. S/E switch edges. M returns to move mode. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

## Phase 6: Example App Integration

- [x] 11. Update Features Demo to showcase resize and keyboard interactions
  - File: `example/lib/views/month_view/styles/features_demo_style.dart`
  - Add toggle for `enableEventResize` in the control panel (both desktop and mobile layouts)
  - Wire `onResizeWillAccept` and `onEventResized` callbacks with console output / snackbar feedback
  - Ensure sample events include multi-day events that can be resized
  - Add descriptive text/tooltip about keyboard shortcuts (R for resize, M for move, etc.)
  - Purpose: Demonstrate resize and keyboard features to developers evaluating the package
  - _Leverage: Existing drag-and-drop toggles and callbacks in `features_demo_style.dart`_
  - _Requirements: 1.1-1.23, 3.1-3.15, 4.1-4.14_
  - _Prompt: Implement the task for spec month-view-polish, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in example apps | Task: Update `example/lib/views/month_view/styles/features_demo_style.dart` to showcase resize. Add a toggle for `enableEventResize` in the control panel. Wire `onResizeWillAccept` (reject weekends) and `onEventResized` (show snackbar with details). Ensure multi-day sample events exist. Add a help text about keyboard shortcuts (Enter to select, arrows to move, R for resize, S/E to switch edge, M for move mode). | Restrictions: Do NOT modify package code. All UI is in example/. | Success: Example app demonstrates resize with toggle, validation feedback, and keyboard shortcut help. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

## Phase 7: Testing

- [x] 12. Unit tests for drag handler resize state machine
  - File: `test/widgets/mcal_drag_handler_resize_test.dart` (NEW)
  - Test `startResize`: sets state correctly, notifies listeners
  - Test `updateResize`: updates proposed range and highlighted cells
  - Test `completeResize`: returns proposed dates when valid, null when invalid
  - Test `cancelResize`: clears all state, notifies
  - Test mutual exclusivity: `startResize` while dragging → assertion error, and vice versa
  - Test shared field reuse: after `updateResize`, `highlightedCells` and `proposedStartDate`/`End` are readable
  - Purpose: Validate resize state machine independently
  - _Leverage: Existing drag handler patterns. `flutter_test` package._
  - _Requirements: 1.7-1.14_
  - _Prompt: Implement the task for spec month-view-polish, first run spec-workflow-guide to get the workflow guide then implement the task: Role: QA Engineer specializing in Dart unit testing | Task: Create `test/widgets/mcal_drag_handler_resize_test.dart`. Test groups: (1) startResize sets fields and notifies, (2) updateResize updates proposed range, (3) completeResize returns dates or null, (4) cancelResize clears state, (5) mutual exclusivity with drag state (assertion errors), (6) shared field reuse. | Restrictions: Use flutter_test. Test the handler in isolation. | Success: All tests pass. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

- [x] 13. Widget tests for reduced motion, multi-day semantics, resize, and keyboard interactions
  - File: `test/widgets/mcal_month_view_polish_test.dart` (NEW)
  - Test groups:
    - **Reduced motion**: `enableAnimations: null` + `reduceMotion: true` → verify `jumpToPage` used; `enableAnimations: true` + `reduceMotion: true` → verify `animateToPage` still used; `enableAnimations: false` → always `jumpToPage`
    - **Multi-day semantics**: Multi-day event tile → verify semantic label includes span info ("3-day event, day 2 of 3"); single-day event → no span info
    - **Edge-drag resize**: Simulate horizontal drag on resize handle → verify handler state → verify preview → verify callback with correct details; test minimum 1-day enforcement; test recurring event creates modified exception
    - **Platform auto-detect**: `enableEventResize: null` on different platforms → verify correct resolution
    - **Keyboard move**: Focus cell → Enter → Arrow → Enter → verify event moved; Escape → verify cancelled; Tab cycles events
    - **Keyboard resize**: Select event → R → Arrow → Enter → verify resized; S/E switch edges; M returns to move; minimum duration enforced
    - **RTL resize**: In RTL context, leading edge is right, trailing is left
  - Purpose: Comprehensive widget-level verification of all new features
  - _Leverage: Existing test patterns in `test/widgets/mcal_month_view_test.dart`. `flutter_test`, `WidgetTester`._
  - _Requirements: All_
  - _Prompt: Implement the task for spec month-view-polish, first run spec-workflow-guide to get the workflow guide then implement the task: Role: QA Engineer specializing in Flutter widget testing | Task: Create `test/widgets/mcal_month_view_polish_test.dart` with comprehensive widget tests for all new features. Groups: (1) Reduced motion — test enableAnimations null/true/false with MediaQuery reduceMotion. (2) Multi-day semantics — find Semantics widget on multi-day tile, verify label. (3) Edge-drag resize — simulate drag on handle, verify handler state and callbacks. (4) Platform auto-detect — mock platforms, verify enableEventResize resolution. (5) Keyboard move — send key events, verify event movement. (6) Keyboard resize — send R, arrows, Enter, verify resize. (7) RTL resize. | Restrictions: Use flutter_test. Create test events and controller in setUp. | Success: All tests pass. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

## Phase 8: Verification

- [x] 14. Run full test suite and analyzer
  - Run `dart analyze` on the full project
  - Run all tests (existing + new)
  - Verify no regressions in existing 800+ tests
  - Verify all new tests pass
  - Verify example app compiles
  - Purpose: Final verification that everything works together
  - _Requirements: All_
  - _Prompt: Implement the task for spec month-view-polish, first run spec-workflow-guide to get the workflow guide then implement the task: Role: QA Engineer | Task: Run `dart analyze` on the full project and run the complete test suite. Verify: (1) dart analyze reports no errors, (2) all existing tests pass (800+), (3) all new tests pass, (4) example app compiles with `flutter build web` in example/. Report results. | Restrictions: Do NOT modify any source files. Verification only. | Success: Zero analyzer errors, all tests pass, example compiles. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

## Phase 9: Cross-Month Resize and Gesture Persistence

- [x] 15. Move resize gesture tracking from child to parent state for cross-month persistence
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Move all resize pointer state fields (`_resizeActivePointer`, `_resizeGestureStarted`, `_resizeDxAccumulated`, `_pendingResizeEvent`, `_pendingResizeEdge`, `_isResizeInProgress`, `_lastResizePointerPosition`) from `_MonthPageWidgetState` to `_MCalMonthViewState`
  - Add `_gridAreaKey` (`GlobalKey`) to the parent state, assigned to the `Expanded` widget wrapping the `PageView`, for obtaining the grid's `RenderBox` dimensions
  - Add parent-level `Listener` widget to capture `onPointerMove`, `onPointerUp`, `onPointerCancel` for resize events
  - Delegate `_ResizeHandle.onPointerDown` from child to parent via `onResizePointerDownCallback`
  - Implement parent-level methods: `_handleResizePointerDownFromChild`, `_handleResizePointerMoveFromParent`, `_handleResizePointerUpFromParent`, `_handleResizePointerCancelFromParent`
  - Implement `_processResizeUpdateFromParent` for pointer-to-date conversion using `_gridAreaKey`
  - Implement `_buildHighlightCellsFromParent` for computing resize overlay cells
  - Implement `_handleResizeEndFromParent` mirroring `_handleDrop` flow
  - Implement `_cleanupResizePointerState` for parent-level cleanup
  - Remove all child-level resize state fields and methods from `_MonthPageWidgetState`
  - Remove the Layer 5 `Listener` from the child's `Stack`
  - Purpose: Ensure the resize gesture survives across page transitions during cross-month navigation
  - _Leverage: Design doc Component 10. Existing parent-level state patterns in `_MCalMonthViewState`._
  - _Requirements: 1.22, 1.23, 1.24, 1.25_

- [x] 16. Implement cross-month edge proximity detection and auto-navigation during resize
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Implement `_checkResizeEdgeProximityFromParent` in `_MCalMonthViewState` with 10% inset threshold from grid edges
  - Apply directional constraints: end edge → next month only; start edge → previous month only
  - On edge detection, call `_navigateToMonth(targetMonth)` for programmatic page navigation
  - Use `WidgetsBinding.instance.addPostFrameCallback` after navigation to recompute highlights via `_processResizeUpdateFromParent(_lastResizePointerPosition!)`
  - Purpose: Allow resize to extend events across month boundaries with auto-navigation
  - _Leverage: Existing edge proximity detection from drag-to-move. Design doc Component 10._
  - _Requirements: 1.22, 1.25_

- [x] 17. Disable PageView user scrolling during resize with `NeverScrollableScrollPhysics`
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Add `_isResizeInProgress` flag, set to `true` when resize starts, `false` when resize ends or is cancelled
  - Modify `PageView.builder` physics to use `NeverScrollableScrollPhysics()` when `_isResizeInProgress` is `true`
  - Ensure programmatic navigation (`jumpToPage`) still works during resize
  - Purpose: Prevent the PageView from stealing the resize gesture and causing visual glitches
  - _Leverage: Design doc Component 10. Existing PageView physics configuration._
  - _Requirements: 1.24_

## Phase 10: Recurring Event Controller Fixes

- [x] 18. Fix `_getExpandedOccurrences` to include cross-range `modified` exceptions
  - File: `lib/src/controllers/mcal_event_controller.dart`
  - In `_getExpandedOccurrences`, in the loop processing exceptions whose original date falls outside the query range (`!processedDateKeys.contains(entry.key)`)
  - Add an `else if (exception.type == MCalExceptionType.modified)` block that checks if the `modifiedEvent`'s dates overlap the query range
  - If overlapping, add the modified event (with `occurrenceId` set from `entry.key`) to the expanded list
  - This mirrors the existing logic for `rescheduled` exceptions in the same loop
  - Purpose: Ensure resized recurring events are visible in adjacent months when their modified dates span across month boundaries
  - _Leverage: Existing `rescheduled` cross-range logic in `_getExpandedOccurrences`. Design doc Component 11._
  - _Requirements: 7.1, 7.2_

- [x] 19. Change drag-to-move handlers to use `modified` instead of `rescheduled` exceptions for recurring events
  - File: `lib/src/widgets/mcal_month_view.dart`
  - In `_handleKeyboardDrop` (parent state): replace `MCalRecurrenceException.rescheduled(originalDate: ..., newDate: newStartDate)` with `MCalRecurrenceException.modified(originalDate: ..., modifiedEvent: updatedEvent)`
  - In `_handleDrop` (child `_MonthPageWidgetState`): same replacement
  - The `updatedEvent` is already computed as `event.copyWith(start: newStartDate, end: newEndDate)` which preserves the full event state including any prior modifications
  - Purpose: Preserve prior event modifications (e.g., resized duration) when moving recurring event occurrences
  - _Leverage: Design doc Component 12. Existing `_handleResizeEndFromParent` which already uses `modified`._
  - _Requirements: 6.1, 6.2, 6.3_

## Phase 11: Color Utilities and Drop Target Tile Styling

- [x] 20. Create color utility extension with `lighten`, `darken`, and `soften` methods
  - File: `lib/src/utils/color_utils.dart` (NEW)
  - Create `MCalColorUtils` extension on `Color` with:
    - `lighten([double factor = 0.3])`: blend toward white using `channel = original + (1.0 - original) * factor`
    - `darken([double factor = 0.3])`: blend toward black using `channel = original * (1.0 - factor)`
    - `soften(Brightness brightness, [double factor = 0.75])`: lightens in `Brightness.light`, darkens in `Brightness.dark`
  - All methods produce fully opaque results (no alpha transparency)
  - All methods clamp factor to [0, 1]
  - Export from `lib/multi_calendar.dart`
  - Purpose: Provide opaque color manipulation for drop target styling and consumer use
  - _Leverage: Design doc Component 13._
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [x] 21. Update default drop target tile to use border + softened fill
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Modify `_buildDefaultDropTargetTile` to:
    - When no explicit theme border is configured: use 1px solid border in the tile color, with `tileColor.soften(Theme.of(context).brightness)` as the fill
    - When explicit theme border settings exist: honour them with tile color as-is for fill (backward compatible)
  - Import `color_utils.dart` in `mcal_month_view.dart`
  - Purpose: Make drop target tile visually distinct from original event tile in both light and dark modes
  - _Leverage: Design doc Component 14. `MCalColorUtils.soften` from Task 20._
  - _Requirements: 8.6, 8.7, 8.8_

## Phase 12: Final Verification

- [x] 22. Run full test suite after all post-spec changes
  - Run `dart analyze` on the full project
  - Run all tests (922 tests)
  - Verify no regressions
  - Purpose: Final verification after all post-spec enhancements
  - _Requirements: All_

## Phase 13: Automated Test Coverage for Post-Spec Changes

- [x] 23. Create unit tests for `MCalColorUtils` extension (`lighten`, `darken`, `soften`)
  - File: `test/utils/color_utils_test.dart` (NEW)
  - Test groups:
    - **lighten**: factor 0.0 returns original, factor 1.0 returns white, default factor 0.3, pure black by 0.5 equals 50% grey, pure white unchanged, preserves alpha, matches alpha compositing over white, clamping above 1.0 and below 0.0
    - **darken**: factor 0.0 returns original, factor 1.0 returns black, default factor 0.3, pure white by 0.5 equals 50% grey, pure black unchanged, preserves alpha, matches alpha compositing over black, clamping above 1.0 and below 0.0
    - **soften**: light mode delegates to lighten, dark mode delegates to darken, default factor 0.75, light mode produces lighter colour, dark mode produces darker colour, result is fully opaque
    - **edge cases**: lighten/darken are inverses at complementary factors (black lighten 0.5 == white darken 0.5), chaining is not a round-trip, works with fully transparent colour
  - 27 tests total
  - Purpose: Full unit test coverage for the color utility extension
  - _Leverage: Existing `test/utils/date_utils_test.dart` for test style and patterns_
  - _Requirements: 8.1, 8.2, 8.3, 8.4_

- [x] 24. Add controller tests for modified exception cross-range visibility
  - File: `test/controllers/mcal_event_controller_recurrence_test.dart` (APPEND)
  - Added test group "Modified exception cross-range visibility" with tests:
    - Modified occurrence whose original date is outside query range but modified event overlaps is included (Feb 1 occurrence modified to start Jan 22, querying January finds it)
    - Modified occurrence that does NOT overlap the query range is excluded (Feb 1 modified to Feb 5, querying January does not find it)
    - Modified occurrence in query range from earlier month (Jan 1 modified to span into Feb, querying February finds it)
    - Modified occurrence has correct occurrenceId (set from original date)
    - Modified exception replaces previous exception for same date (second modification overwrites first)
    - Move after resize preserves duration using modified exception (resize to 2-day, move preserving duration via modified exception, verify dates correct)
  - 6 tests total
  - Purpose: Test the controller fix that includes cross-range modified exceptions in query results, and verify the resize-then-move workflow at the controller level
  - _Leverage: Existing test helpers `_weeklyEvent`, `_singleEvent` and range constants in the same file_
  - _Requirements: 6.1, 6.2, 7.1, 7.2_

- [x] 25. Run full test suite after adding new automated tests
  - Run all tests (955 total: 922 original + 27 color_utils + 6 controller cross-range)
  - All 955 tests pass
  - Zero analyzer errors
  - Purpose: Verify all new tests pass and no regressions
  - _Requirements: All_

## Phase 14: API Renames and Custom Resize Handle Builders

- [x] 26. Rename `enableDragAndDrop` to `enableDragToMove` and `enableEventResize` to `enableDragToResize`
  - Files: `lib/src/widgets/mcal_month_view.dart`, `lib/src/widgets/mcal_builder_wrapper.dart`, all test files, all example styles, `README.md`
  - Rename public parameter `enableDragAndDrop` → `enableDragToMove` on `MCalMonthView`
  - Rename public parameter `enableEventResize` → `enableDragToResize` on `MCalMonthView`
  - Rename internal method `_resolveEnableResize` → `_resolveDragToResize`
  - Rename internal computed fields `_enableDragAndDrop` → `_enableDragToMove`, `_enableResize` → `_enableDragToResize`
  - Rename parameter in `MCalBuilderWrapper` and all internal widgets that pass these through
  - Update all test files to use the new parameter names
  - Update all example styles (modern, classic, minimal, colorful, features_demo) to use the new names
  - Update README.md documentation
  - Purely cosmetic rename — no behavioral changes, types, or defaults change
  - Purpose: Consistent `enableDragTo*` naming pattern for drag-based interactions
  - _Requirements: 9.1, 9.2, 9.3, 9.4_

- [x] 27. Add `MCalResizeHandleContext` class and export
  - Files: `lib/src/widgets/mcal_month_view_contexts.dart`, `lib/multi_calendar.dart`
  - Create `MCalResizeHandleContext` class with fields: `edge` (`MCalResizeEdge`), `event` (`MCalCalendarEvent`), `isDropTargetPreview` (`bool`, default `false`)
  - Add full dartdoc with usage context explanation
  - Export from `lib/multi_calendar.dart`
  - Purpose: Type-safe context for custom resize handle builders
  - _Requirements: 9.8, 9.9_

- [x] 28. Add `resizeHandleBuilder` and `resizeHandleInset` parameters to `MCalMonthView`
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Add `resizeHandleBuilder` parameter of type `Widget Function(BuildContext, MCalResizeHandleContext)?`
  - Add `resizeHandleInset` parameter of type `double Function(MCalEventTileContext, MCalResizeEdge)?`
  - Thread both parameters through internal widgets: `_MonthPageWidget`, `_WeekRowWidget`, `_DayCellWidget`
  - Purpose: Allow developers to customize resize handle visuals and positioning
  - _Requirements: 9.5, 9.6, 9.7, 9.10, 9.11, 9.12, 9.13, 9.14_

- [x] 29. Update `_ResizeHandle` widget to accept `visualBuilder` and `inset`
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Add `visualBuilder` parameter (`Widget Function(BuildContext, MCalResizeHandleContext)?`) to `_ResizeHandle`
  - Add `inset` parameter (`double`, default 0.0) to `_ResizeHandle`
  - When `visualBuilder` is provided, use it instead of the default `Container(width: 2, height: 16, ...)` white bar
  - Apply `inset` to the `Positioned` widget's start/end offset
  - Pass `visualBuilder` and computed `inset` when instantiating `_ResizeHandle` in Layer 2 (event tiles)
  - Purpose: Wire custom builder and inset into the handle widget
  - _Requirements: 9.5, 9.6, 9.7, 9.10, 9.11, 9.15_

- [x] 30. Update drop target tile handles to use `resizeHandleBuilder` and `resizeHandleInset`
  - File: `lib/src/widgets/mcal_month_view.dart`
  - In `_buildDefaultDropTargetTile`, use `widget.resizeHandleBuilder` for drop-target preview handles with `MCalResizeHandleContext(isDropTargetPreview: true)`
  - Use `widget.resizeHandleInset` to compute inset for drop-target preview handles
  - Purpose: Ensure consistent custom handle visuals between event tiles and drop-target preview tiles
  - _Requirements: 9.6, 9.15_

- [x] 31. Widget tests for `resizeHandleBuilder`, `resizeHandleInset`, and API renames
  - File: `test/widgets/mcal_resize_handle_customization_test.dart` (NEW)
  - Test groups:
    - **API renames**: `enableDragToMove: true` enables drag-and-drop, `enableDragToResize: true` enables resize, verify both work correctly
    - **Custom resize handle builder**: Provide `resizeHandleBuilder` → verify custom widget renders on multi-day event tile handles; verify `MCalResizeHandleContext.edge` is correct for start/end; verify `isDropTargetPreview` is `false` for event tiles
    - **Custom resize handle inset**: Provide `resizeHandleInset` → verify handles are shifted inward; test returning different insets based on `event.isAllDay`
    - **Default behavior**: When `resizeHandleBuilder` and `resizeHandleInset` are null, verify default white bar at tile edge renders
  - Purpose: Verify custom resize handle API works correctly
  - _Requirements: 9.1-9.15_

- [x] 32. Run full test suite after custom resize handle changes
  - Run `dart analyze` on the full project
  - Run all tests
  - Verify no regressions
  - Purpose: Final verification after API renames and custom handle builders
  - _Requirements: All_
