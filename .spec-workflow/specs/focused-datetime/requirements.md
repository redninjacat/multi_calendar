# Requirements Document: Focused DateTime

## Introduction

This specification replaces `MCalEventController`'s date-only `focusedDate` (`DateTime?`) with `focusedDateTime` (`DateTime?`) — a full DateTime with time-of-day precision. This enables any view sharing the controller to map the focused datetime to its own local concept — a time slot index in Day View, a cell highlight in Month View, or whatever future views require.

The immediate consumer of the time component is the Day View, which gains tap-to-focus: tapping an empty time slot or the all-day section background focuses that position, displays the focused-slot indicator, and activates keyboard navigation so arrow keys work immediately.

## Alignment with Product Vision

**From product.md:**
- **Accessibility First**: Tap-to-focus provides a natural entry point into keyboard navigation, lowering the barrier for keyboard-only and assistive-technology users.
- **Event Controller Pattern**: Centralizing focused state on the controller maintains a single source of truth, enabling multi-view synchronization (e.g., a sidebar showing details for the focused time slot).
- **Customization First**: The controller-level API allows consumers to programmatically set focus for use cases like "jump to 9 AM" buttons.
- **Platform Optimization**: Tap-to-focus is most relevant on desktop/web (pointer + keyboard hybrid), but also benefits tablet users with hardware keyboards.

**From tech.md:**
- **Controller Pattern**: `focusedDateTime` follows the same `ChangeNotifier` pattern as `displayDate`. Views react via `_onControllerChanged`.
- **Performance**: Equality-guarded setter avoids spurious notifications. View-side slot index computation is O(1) arithmetic.
- **DST-safe arithmetic**: `dateOnly()` from `date_utils.dart` is used when extracting the date component for Month View compatibility.

## Requirements

### Requirement 1: Controller API — `focusedDateTime`

**User Story:** As a developer, I want a controller-level focused datetime with time precision so that all views sharing the controller can reflect the same focused position in their own way.

#### Acceptance Criteria

1. `MCalEventController` SHALL expose a `DateTime? get focusedDateTime` property, replacing the existing `focusedDate` getter.
2. `MCalEventController` SHALL expose a `bool get isFocusedOnAllDay` property (defaults to `false`). This flag disambiguates all-day section focus from a midnight time slot focus — necessary because `DateTime(y, m, d, 0, 0)` is a valid time grid slot when `startHour == 0`.
3. `MCalEventController` SHALL provide a `void setFocusedDateTime(DateTime? dateTime, {bool isAllDay = false})` method that updates `focusedDateTime` and `isFocusedOnAllDay`, and calls `notifyListeners()` only when either value changes (equality-guarded on both fields). This replaces the existing `setFocusedDate` method.
4. The existing `focusedDate` getter and `setFocusedDate` method SHALL be **removed** (not deprecated). All call sites SHALL be updated to use `focusedDateTime` and `setFocusedDateTime` directly. Backward compatibility is not required at this stage.
5. The existing `navigateToDate(DateTime date, {bool focus = true})` method SHALL be updated to atomically update `_displayDate`, `_focusedDateTime`, and `_isFocusedOnAllDay` in a single `notifyListeners()` call:
   - `_displayDate` SHALL be set to `dateOnly(date)` — the display date is always date-only because views are not more granular than a day.
   - When `focus` is true, `_focusedDateTime` SHALL be set to `date` (preserving whatever time precision the caller provides) and `_isFocusedOnAllDay` SHALL be set to `false`.
   - The method SHALL NOT call `setFocusedDateTime()` internally — it must assign fields directly to preserve the single-notification atomicity.
6. `focusedDateTime` SHALL be initialized to `null` (no focus). `isFocusedOnAllDay` SHALL be initialized to `false`.
7. `displayDate` SHALL remain date-only (`DateTime` with `hour=0, minute=0`). The controller and all views treat display at day granularity. Only `focusedDateTime` carries time-of-day precision.

#### Caller Conventions

- **Day View (time slot tap)** SHALL call `setFocusedDateTime(snappedTime)` with `isAllDay: false` (the default). Even for a midnight slot when `startHour == 0`, this correctly represents a time grid focus, not an all-day focus.
- **Day View (all-day section tap)** SHALL call `setFocusedDateTime(DateTime(y, m, d), isAllDay: true)`. The `isAllDay: true` flag distinguishes this from a midnight time slot.
- **Month View** SHALL call `setFocusedDateTime(dateOnly(date), isAllDay: true)` — always midnight with `isAllDay: true`. Month View focuses entire days (no time-slot concept), so all focus is inherently all-day. If a Day View shares the controller, a Month View cell tap will correctly highlight the Day View's all-day section.
- **Consumers** (app developers) MAY call `setFocusedDateTime()` or `navigateToDate()` with any precision. If a consumer passes a DateTime with time to `navigateToDate()`, the display will navigate to that day and the focus will include the time component — a Day View sharing the controller would map it to the corresponding time slot.

### Requirement 2: Day View — Tap-to-Focus (Time Grid)

**User Story:** As a desktop/web user, I want to click on a time slot and see it become focused with the keyboard navigation indicator, so I can immediately use arrow keys to navigate from that position.

#### Acceptance Criteria

1. WHEN the user taps an empty time slot in the time grid THEN the Day View SHALL set `controller.focusedDateTime` to the snapped time of the tapped slot (using the existing `snapToTimeSlot` + `offsetToTime` logic).
2. WHEN the user taps an empty time slot THEN the Day View SHALL set `_keyboardNavigationActive = true` so the focused-slot indicator becomes visible.
3. WHEN the user taps an empty time slot THEN `_focusedSlotIndex` SHALL be computed from the snapped time and stored internally.
4. WHEN the user taps an empty time slot THEN the focused-slot indicator SHALL appear at the tapped slot position without requiring a prior keyboard keypress.
5. WHEN the user taps an empty time slot and then presses Up or Down arrow THEN keyboard navigation SHALL work from the tapped position.
6. WHEN the tap hits an event tile (event tap takes precedence) THEN tap-to-focus SHALL NOT occur.
7. Tap-to-focus SHALL occur regardless of whether `onTimeSlotTap` is set. Focus update and callback firing are independent concerns.

### Requirement 3: Day View — Tap-to-Focus (All-Day Section)

**User Story:** As a user, I want to click on the all-day section background and have it become the focused area, consistent with how keyboard A-key navigation works.

#### Acceptance Criteria

1. WHEN the user taps the all-day section background (whitespace) THEN the Day View SHALL call `controller.setFocusedDateTime(DateTime(year, month, day, 0, 0), isAllDay: true)` — the `isAllDay: true` flag explicitly marks this as an all-day focus, distinguishing it from a midnight time slot tap.
2. WHEN the user taps the all-day section background THEN `_keyboardNavigationActive` SHALL be set to `true`.
3. WHEN the user taps the all-day section background THEN `_focusedSlotIndex` SHALL be set to `null` (matching keyboard behavior where `null` = all-day focused).
4. WHEN the user taps the all-day section background THEN the all-day focus indicator SHALL appear.
5. Tap-to-focus on the all-day section SHALL occur regardless of whether `onTimeSlotTap` is set.

### Requirement 4: Day View — Bidirectional Controller Sync

**User Story:** As a developer, I want the Day View's internal focus state and the controller's `focusedDateTime` to stay synchronized bidirectionally, so that programmatic focus changes and keyboard navigation both update the same state.

#### Acceptance Criteria

1. WHEN keyboard navigation changes `_focusedSlotIndex` (Up, Down, Home, End, A, T keys) THEN the Day View SHALL call `controller.setFocusedDateTime()` with the corresponding `DateTime` and `isAllDay: false`.
2. WHEN `_focusedSlotIndex` is set to `null` (all-day section) via keyboard THEN `controller.setFocusedDateTime()` SHALL be called with midnight of the display date and `isAllDay: true`.
3. WHEN `controller.focusedDateTime` or `controller.isFocusedOnAllDay` changes externally (e.g., programmatic call) THEN `_onControllerChanged` SHALL map the new values to `_focusedSlotIndex`:
   - If `focusedDateTime` is `null` → `_focusedSlotIndex = null`, `_keyboardNavigationActive = false`.
   - If `isFocusedOnAllDay` is `true` (on the display date) → `_focusedSlotIndex = null` (all-day), `_keyboardNavigationActive = true`.
   - If `isFocusedOnAllDay` is `false` and `focusedDateTime` is on the display date → compute slot index from time component (even if midnight when `startHour == 0`), set `_keyboardNavigationActive = true`.
   - If `focusedDateTime` is on a different date → ignore the time component for slot index (the day view only shows one day).
4. The sync SHALL NOT cause infinite loops — the equality guard on `setFocusedDateTime` (checking both `focusedDateTime` and `isFocusedOnAllDay`) prevents re-notification when the view writes back the same values it just read.

### Requirement 5: Month View — Backward Compatibility

**User Story:** As a developer using Month View, I want the existing `onFocusedDateChanged` callback and `autoFocusOnCellTap` behavior to continue working without changes.

#### Acceptance Criteria

1. Month View SHALL read focus state via `dateOnly(controller.focusedDateTime)` to extract the date component for cell highlighting.
2. `autoFocusOnCellTap` SHALL call `controller.setFocusedDateTime()` with midnight of the tapped date and `isAllDay: true` (Month View focuses entire days).
3. Keyboard navigation in Month View SHALL call `controller.setFocusedDateTime()` with midnight of the computed date and `isAllDay: true`.
4. `onFocusedDateChanged` SHALL continue to fire when the **date component** of `focusedDateTime` changes. It SHALL compare `dateOnly(previous)` vs `dateOnly(current)` so that time-only changes (e.g., Day View moving between time slots on the same day) do NOT trigger it.
5. Existing Month View tests SHALL pass (updating `focusedDate`/`setFocusedDate` references to `focusedDateTime`/`setFocusedDateTime` as needed).

### Requirement 6: Day View — `onFocusedDateTimeChanged` Callback

**User Story:** As a developer using Day View, I want to be notified when the focused datetime changes so I can update a sidebar, status bar, or other UI element.

#### Acceptance Criteria

1. `MCalDayView` SHALL expose an `onFocusedDateTimeChanged` parameter of type `ValueChanged<DateTime?>?`.
2. WHEN `controller.focusedDateTime` changes THEN the Day View SHALL fire `onFocusedDateTimeChanged` with the new value (including time precision).
3. WHEN `controller.focusedDateTime` changes to `null` THEN `onFocusedDateTimeChanged` SHALL fire with `null`.
4. `onFocusedDateTimeChanged` SHALL fire for both tap-initiated and keyboard-initiated focus changes.
5. `onFocusedDateTimeChanged` SHALL NOT fire when the value has not actually changed (deduplication via equality comparison).

### Requirement 7: Non-Functional Requirements

#### Code Architecture and Modularity
- `focusedDate` and `setFocusedDate` SHALL be removed and all call sites updated — no deprecated wrappers.
- Day View tap-to-focus logic SHALL reuse existing `snapToTimeSlot`, `offsetToTime`, and `_slotIndexToTime` utilities.
- The inverse mapping (time → slot index) SHALL be a single private utility method.

#### Performance
- `setFocusedDateTime` equality guard SHALL prevent unnecessary `notifyListeners()` calls.
- Slot index computation from DateTime SHALL be O(1) arithmetic.
- No additional per-frame work: focus state changes only on discrete user actions (tap, keypress, programmatic call).

#### Testing
- Controller unit tests for `focusedDateTime`, `isFocusedOnAllDay`, `setFocusedDateTime`, and `navigateToDate` update.
- Day View widget tests for tap-to-focus (time grid), tap-to-focus (all-day section), keyboard→controller sync, and controller→view sync.
- Month View tests confirming existing behavior with the new API (`focusedDateTime`/`setFocusedDateTime`).
- All existing tests SHALL pass.
