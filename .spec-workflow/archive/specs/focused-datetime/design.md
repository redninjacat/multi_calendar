# Design Document: Focused DateTime

## Overview

This design replaces the controller's `focusedDate` (date-only) with `focusedDateTime` (full DateTime with time-of-day precision) and wires it bidirectionally to the Day View's internal `_focusedSlotIndex`. The Day View gains tap-to-focus: tapping a time slot or all-day section sets the controller's `focusedDateTime`, activates keyboard navigation, and shows the focus indicator. The Month View is updated to use the new API directly (no deprecated wrappers).

## Steering Document Alignment

### Technical Standards (tech.md)

- **Controller Pattern**: `focusedDateTime` follows the same `ChangeNotifier` / equality-guarded setter pattern as `displayDate`. Views react via `_onControllerChanged`.
- **Performance**: The setter is equality-guarded to prevent spurious rebuilds. Time-to-slot-index conversion is O(1) integer arithmetic. No per-frame overhead; focus changes only on discrete actions.
- **DST-safe arithmetic**: `dateOnly()` from `date_utils.dart` is used when extracting the date component for Month View compatibility. No `Duration`-based day arithmetic is involved.
- **Accessibility**: Tap-to-focus does not change the existing Semantics/announcement infrastructure — it merely activates the same state that keyboard navigation already activates, so all existing announcements fire naturally.

### Project Structure (structure.md)

- **Controller changes**: In `lib/src/controllers/mcal_event_controller.dart` — replacing `_focusedDate` with `_focusedDateTime` and adding `_isFocusedOnAllDay`, replacing `setFocusedDate` with `setFocusedDateTime`, removing `focusedDate` getter.
- **Day View changes**: In `lib/src/widgets/mcal_day_view.dart` — modifying `_onControllerChanged`, `_handleTimeSlotTap`, `_handleNavigationModeKey`, and adding one new utility method and one new callback parameter.
- **Month View changes**: In `lib/src/widgets/mcal_month_view.dart` — replacing `focusedDate`/`setFocusedDate` calls with `focusedDateTime`/`setFocusedDateTime`, updating `_onControllerChanged` to compare date parts only.
- **Naming**: `MCal` prefix for public API. `focusedDateTime` / `setFocusedDateTime` replaces the old `focusedDate` / `setFocusedDate`.
- **No new files**: All changes are additions/modifications to existing files.

## Code Reuse Analysis

### Existing Components to Leverage

- **`MCalEventController._focusedDate`** (line 112): Will be renamed to `_focusedDateTime` and retain `DateTime?` type. The old `focusedDate` getter and `setFocusedDate` method are removed entirely (no deprecation).
- **`MCalEventController.navigateToDate`** (line 321): Updated to set `_displayDate = dateOnly(date)` and, only when `focus` is true, also set `_focusedDateTime = date` and `_isFocusedOnAllDay = false` directly (preserving time precision for focus while keeping display date-only). When `focus` is false, `_focusedDateTime` and `_isFocusedOnAllDay` are left unchanged. Must NOT call `setFocusedDateTime()` — the existing atomic single-`notifyListeners()` pattern is preserved.
- **`_slotIndexToTime(int)`** (mcal_day_view.dart line 2757): Forward mapping (index → time). The inverse is a new `_timeToSlotIndex(DateTime)` method using the same arithmetic reversed.
- **`_buildFocusedSlotIndicator(hourHeight)`** (mcal_day_view.dart line 5893): Already renders the focus highlight. No changes needed — it reads `_focusedSlotIndex` which is now set by both tap and keyboard.
- **`_scrollToFocusedSlot()`** (mcal_day_view.dart line 2784): Already scrolls to reveal the focused slot. Called after tap-to-focus.
- **`snapToTimeSlot` + `offsetToTime`** (time_utils.dart): Already used by `_handleTimeSlotTap` to convert tap position to a snapped DateTime. Reused for tap-to-focus.
- **`_keyboardNavigationActive`** (mcal_day_view.dart line 1646): Gate flag for rendering focus indicators. Set to `true` by both keyboard and tap now.
- **`_handleTimeSlotTap`** (mcal_day_view.dart line 6185): Extended to also set focus state after its existing callback logic.
- **`_onControllerChanged`** (mcal_day_view.dart line 2011): Extended to read `focusedDateTime` and map to `_focusedSlotIndex`.
- **Month View `_onControllerChanged`** (mcal_month_view.dart line 1441): Updated to use `dateOnly(focusedDateTime)` for date-part comparison.

### Integration Points

- **`MCalEventController`**: Central integration point. Day View and Month View both read and write `focusedDateTime`.
- **`AllDayEventsSection`**: Already has `onTimeSlotTap` wired. Tap-to-focus adds internal state updates in the Day View's handler that receives this callback.
- **`MCalGestureDetector`**: No changes needed — tap detection already works. Focus update is purely in the callback handler.
- **`multi_calendar.dart`**: No new exports needed (the controller's API surface changes are on existing classes).

## Architecture

### Data Flow

```
┌─────────────────────────────────────────────────────┐
│              MCalEventController                     │
│                                                      │
│  DateTime  _displayDate        (date-only, no time)  │
│  DateTime? _focusedDateTime    (full DateTime w/ time)│
│  bool      _isFocusedOnAllDay  (disambiguates        │
│                                 midnight vs all-day)  │
│                                                      │
│  ├── get focusedDateTime → _focusedDateTime          │
│  ├── get isFocusedOnAllDay → _isFocusedOnAllDay      │
│  ├── setFocusedDateTime(dt, {isAllDay})               │
│  │    → equality guard on BOTH fields                │
│  │    → notifyListeners                              │
│  ├── navigateToDate(date, focus:true) → ATOMIC:      │
│  │    _displayDate = dateOnly(date)                  │
│  │    _focusedDateTime = date  (time preserved)      │
│  │    _isFocusedOnAllDay = false                     │
│  │    → single notifyListeners()                     │
│  ├── navigateToDate(date, focus:false) → ATOMIC:     │
│  │    _displayDate = dateOnly(date)                  │
│  │    _focusedDateTime unchanged                     │
│  │    _isFocusedOnAllDay unchanged                   │
│  │    → single notifyListeners()                     │
│  (focusedDate / setFocusedDate removed — no deprecation)│
└──────────────┬──────────────────────┬────────────────┘
               │                      │
       notifyListeners          notifyListeners
               │                      │
               ▼                      ▼
┌──────────────────────┐  ┌─────────────────────────┐
│   MCalDayView        │  │   MCalMonthView          │
│   _onControllerChgd  │  │   _onControllerChgd      │
│                      │  │                           │
│ READ:                │  │ READ:                     │
│  controller          │  │  dateOnly(controller      │
│   .focusedDateTime   │  │   .focusedDateTime)       │
│   .isFocusedOnAllDay │  │  → cell highlight         │
│  → _timeToSlotIndex  │  │                           │
│  → _focusedSlotIndex │  │ WRITE:                    │
│  → _keyboardNavActve │  │  setFocusedDateTime       │
│                      │  │   (midnight,              │
│ WRITE (time slot):   │  │    isAllDay: true)        │
│  snapToTimeSlot      │  │  on cell tap / keyboard   │
│  → setFocusedDateTime│  │                           │
│    (isAllDay: false) │  │ CALLBACK:                 │
│                      │  │  onFocusedDateChanged     │
│                      │  │  (date-part diff only)    │
│ WRITE (all-day tap): │  │                           │
│  → setFocusedDateTime│  └─────────────────────────┘
│    (isAllDay: true)  │
│                      │
│ WRITE (keyboard       │
│  ↑↓ Home End A T):  │
│  _slotIndexToTime    │
│  → setFocusedDateTime│
│    (isAllDay per key)│
│                      │
│ WRITE (keyboard ←→): │
│  addDays(±1) [DST]   │
│  setDisplayDate      │
│  → setFocusedDateTime│
│    (same slot/allday)│
│                      │
│ CALLBACK:            │
│  onFocusedDateTime   │
│   Changed            │
└──────────────────────┘
```

## Components and Interfaces

### Component 1: MCalEventController — focusedDateTime

- **Purpose:** Centralized focus state with time-of-day precision, shared across all views. `displayDate` remains date-only because views are not more granular than a day — only `focusedDateTime` carries time precision. The companion `isFocusedOnAllDay` flag disambiguates an all-day section focus from a midnight time slot focus (needed when `startHour == 0`).
- **File:** `lib/src/controllers/mcal_event_controller.dart`
- **Changes:**
  - Rename `_focusedDate` → `_focusedDateTime` (line 112)
  - Add `bool _isFocusedOnAllDay = false;` (new)
  - Add `DateTime? get focusedDateTime => _focusedDateTime;` (new)
  - Add `bool get isFocusedOnAllDay => _isFocusedOnAllDay;` (new)
  - Add `void setFocusedDateTime(DateTime? dateTime, {bool isAllDay = false})` — equality-guarded on both `_focusedDateTime` and `_isFocusedOnAllDay`, calls `notifyListeners()` only when either changes (new)
  - Remove `focusedDate` getter and `setFocusedDate` method entirely (no deprecation — all call sites updated)
  - Update `navigateToDate` (line 321) — atomic update preserved:
    - `_displayDate = dateOnly(date)` (display is always date-only)
    - `_focusedDateTime = date` when `focus` is true (preserves caller's time precision)
    - `_isFocusedOnAllDay = false` when `focus` is true (navigating to a date is never an all-day focus)
    - Single `notifyListeners()` call — does NOT call `setFocusedDateTime()` internally, to avoid a double notification. The direct field assignment maintains the existing atomic semantics.
- **Reuses:** Existing `ChangeNotifier` infrastructure, `dateOnly()` from `date_utils.dart`.

- **Caller Conventions:**
  - Day View time slot tap: `setFocusedDateTime(snappedTime)` — `isAllDay` defaults to `false`, even for midnight when `startHour == 0`
  - Day View all-day tap: `setFocusedDateTime(DateTime(y, m, d), isAllDay: true)` — explicit all-day flag
  - Day View keyboard A-key (all-day): `setFocusedDateTime(midnight, isAllDay: true)`
  - Day View keyboard arrows/Home/End/T: `setFocusedDateTime(slotTime)` — `isAllDay` defaults to `false`
  - Month View: `setFocusedDateTime(dateOnly(date), isAllDay: true)` — always midnight, always all-day (Month View focuses entire days)
  - Consumers may call `navigateToDate(dateTimeWithTime)` — display navigates to the day, focus includes the time

### Component 2: Day View — Tap-to-Focus

- **Purpose:** Allow users to click a time slot or all-day section to set focus and activate keyboard navigation.
- **File:** `lib/src/widgets/mcal_day_view.dart`
- **Changes:**

  **New private utility — `_timeToSlotIndex(DateTime time)`:**
  Inverse of `_slotIndexToTime`. Computes `((time.hour * 60 + time.minute) - startHour * 60) ~/ slotDurationMinutes`, clamped to `[0, totalSlots - 1]`. This method no longer uses midnight as a sentinel — all-day detection is handled by the separate `isFocusedOnAllDay` flag on the controller.

  **Modified — `_handleTimeSlotTap(Offset, double)`** (line 6185):
  After existing callback logic, add tap-to-focus:
  ```
  // Tap-to-focus: set controller and activate keyboard nav
  final slotIndex = _timeToSlotIndex(tappedTime);
  _focusedSlotIndex = slotIndex;
  _lastTimeGridSlotIndex = slotIndex;
  _keyboardNavigationActive = true;
  widget.controller.setFocusedDateTime(tappedTime);
  _scrollToFocusedSlot();
  setState(() {});
  ```
  This runs regardless of whether `onTimeSlotTap` is set — the early return on line 6186 must be removed and the callback firing made conditional instead.

  **Modified — All-day section tap handler:**
  The all-day section background taps fire `onTimeSlotTap` via `AllDayEventsSection`'s `MCalGestureDetector`. The Day View's handler checks `slotContext.isAllDayArea` — after firing the callback, add:
  ```
  _focusedSlotIndex = null;
  _keyboardNavigationActive = true;
  widget.controller.setFocusedDateTime(
    DateTime(displayDate.year, displayDate.month, displayDate.day),
    isAllDay: true,
  );
  setState(() {});
  ```
  The `isAllDay: true` flag distinguishes this from a midnight time slot tap (which would pass `isAllDay: false`). Since the all-day section tap comes through the same `onTimeSlotTap` path from the `AllDayEventsSection` widget, the Day View needs to intercept it. However, `AllDayEventsSection` constructs its own `MCalTimeSlotContext` and calls `onTimeSlotTap` directly. The tap-to-focus logic must be added inside the closure that builds the `AllDayEventsSection`, not in `_handleTimeSlotTap` (which only handles time grid taps). The approach: the `AllDayEventsSection` `onTimeSlotTap` parameter already points to `widget.onTimeSlotTap`. We need to wrap it with a closure that also does the focus update.

  **Modified — `_handleNavigationModeKey`** (line 2596):
  After each slot index mutation (Up, Down, Home, End, A, T), add `widget.controller.setFocusedDateTime(...)` with the computed time. For `null` (all-day), use midnight with `isAllDay: true`. For time grid slots, use `isAllDay: false` (the default). The equality guard prevents redundant notifications.

  **New — Left/Right day navigation (RTL-aware):**
  The current code returns `KeyEventResult.ignored` for Left/Right keys. This is replaced with RTL-aware, DST-safe day navigation that preserves the current focus position. Mirrors the Month View's `rtlMult` pattern:

  ```
  // ── ← / → Navigate Between Days (RTL-aware) ──────────────────────────
  if (key == arrowLeft || key == arrowRight) {
    final isRTL = _isLayoutRTL(context);
    final dayOffset = (isLeft ? -1 : 1) * (isRTL ? -1 : 1);
    // LTR: left = −1, right = +1. RTL: left = +1, right = −1.
    _navigateToDayPreservingFocus(dayOffset) → handled
  }
  ```

  **New private helper — `_navigateToDayPreservingFocus(int dayOffset)`:**
  ```
  void _navigateToDayPreservingFocus(int dayOffset) {
    final newDate = addDays(_displayDate, dayOffset);   // DST-safe
    widget.controller.setDisplayDate(newDate);
    if (_focusedSlotIndex == null) {
      // All-day section — stay in all-day on new day
      widget.controller.setFocusedDateTime(
        DateTime(newDate.year, newDate.month, newDate.day),
        isAllDay: true,
      );
    } else {
      // Time grid — same slot index (= same hour:minute) on new day
      // DateTime constructor arithmetic is DST-safe (not Duration-based).
      final slotMinutes = widget.timeSlotDuration.inMinutes;
      final totalMinutes = widget.startHour * 60 + _focusedSlotIndex! * slotMinutes;
      widget.controller.setFocusedDateTime(
        DateTime(
          newDate.year, newDate.month, newDate.day,
          totalMinutes ~/ 60, totalMinutes % 60,
        ),
      );
    }
  }
  ```

  **DST safety:** `addDays` from `date_utils.dart` shifts by calendar day (preserving time-of-day across DST boundaries). The hour/minute for the new slot is computed from the slot index via integer arithmetic, then passed to the `DateTime` constructor — not added via `Duration`, so DST boundaries do not cause the wrong calendar day to be produced.

  **Slot index preservation:** The `_focusedSlotIndex` (stored as an integer within `[0, totalSlots-1]`) represents a relative position in the time grid. Since `startHour` and `timeSlotDuration` are fixed per widget, the same slot index always maps to the same hour:minute pair on any day. There is no need to update `_focusedSlotIndex` itself — only `controller.focusedDateTime` (the date part) changes.

  **New parameter — `onFocusedDateTimeChanged`:**
  `ValueChanged<DateTime?>?` on `MCalDayView`. Fired from `_onControllerChanged` when `focusedDateTime` changes.

  **Modified — `_onControllerChanged()`** (line 2011):
  After existing display-date sync, add focused-datetime sync:
  ```
  final currentFocusedDateTime = widget.controller.focusedDateTime;
  final currentIsAllDay = widget.controller.isFocusedOnAllDay;
  if (currentFocusedDateTime != _previousFocusedDateTime ||
      currentIsAllDay != _previousIsFocusedOnAllDay) {
    _previousFocusedDateTime = currentFocusedDateTime;
    _previousIsFocusedOnAllDay = currentIsAllDay;
    widget.onFocusedDateTimeChanged?.call(currentFocusedDateTime);

    // Map controller focus to internal slot index (only if on current day)
    if (currentFocusedDateTime == null) {
      _focusedSlotIndex = null;
      _keyboardNavigationActive = false;
    } else {
      final focusDate = dateOnly(currentFocusedDateTime);
      if (focusDate == _displayDate) {
        if (currentIsAllDay) {
          _focusedSlotIndex = null; // all-day section
        } else {
          _focusedSlotIndex = _timeToSlotIndex(currentFocusedDateTime);
        }
        _keyboardNavigationActive = true;
      }
    }
    setState(() {});
  }
  ```

  **New fields:**
  - `DateTime? _previousFocusedDateTime` — for deduplication in `_onControllerChanged`, initialized from `widget.controller.focusedDateTime` in `initState`.
  - `bool _previousIsFocusedOnAllDay` — tracks the previous `isFocusedOnAllDay` value, initialized from `widget.controller.isFocusedOnAllDay` in `initState`.

- **Reuses:** `snapToTimeSlot`, `offsetToTime`, `_slotIndexToTime`, `_scrollToFocusedSlot`, `_buildFocusedSlotIndicator`.

### Component 3: Month View — Backward Compatibility

- **Purpose:** Maintain existing Month View behavior with minimal changes.
- **File:** `lib/src/widgets/mcal_month_view.dart`
- **Changes:**

  **Modified — `_onControllerChanged()`** (line 1441):
  Replace `widget.controller.focusedDate` reads with `widget.controller.focusedDateTime` (the old getter is removed, not deprecated). For `focusedDateChanged` comparison, compare `dateOnly(previous)` vs `dateOnly(current)` so time-only changes on the same day don't trigger `onFocusedDateChanged`.

  **Modified — Keyboard navigation** (line 2171):
  Replace `widget.controller.setFocusedDate(newFocusedDate)` calls with `widget.controller.setFocusedDateTime(newFocusedDate, isAllDay: true)`. Month View always passes date-only values (midnight) with `isAllDay: true` — it focuses entire days, not time slots.

  **Modified — `autoFocusOnCellTap` handler:**
  Replace `widget.controller.setFocusedDate(date)` with `widget.controller.setFocusedDateTime(dateOnly(date), isAllDay: true)`. The `dateOnly()` call ensures only the date component is written, and `isAllDay: true` ensures a shared Day View highlights its all-day section.

  **Modified — `_previousFocusedDate` tracking:**
  Store `DateTime?` from `controller.focusedDateTime` but compare using `dateOnly()` for the `onFocusedDateChanged` diff.

### Component 4: Example App — Day Features Tab

- **Purpose:** Demonstrate `onFocusedDateTimeChanged` in the status bar.
- **File:** `example/lib/views/day_view/tabs/day_features_tab.dart`
- **Changes:**
  Add `onFocusedDateTimeChanged` handler that updates the status label. Use `controller.isFocusedOnAllDay` to distinguish all-day from midnight:
  ```dart
  onFocusedDateTimeChanged: (dateTime) {
    if (dateTime == null) {
      _setStatus('Focus cleared');
    } else if (controller.isFocusedOnAllDay) {
      _setStatus('Focused: all-day section');
    } else {
      _setStatus(
        'Focused: ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}',
      );
    }
  },
  ```

## Error Handling

### Error Scenarios

1. **Infinite loop — view writes back what it reads:**
   - **Handling:** `setFocusedDateTime` is equality-guarded on both `focusedDateTime` and `isFocusedOnAllDay`. When `_onControllerChanged` reads values, maps to slot index, and the keyboard/tap handler writes back the same DateTime and isAllDay flag, no notification fires.
   - **User Impact:** None.

2. **Focus on a different day than displayed:**
   - **Handling:** If `focusedDateTime` is on a date other than `_displayDate`, the Day View ignores the time component for slot index mapping (it only maps times for the current display date). The date component may trigger a display date change elsewhere.
   - **User Impact:** No focus indicator appears for a mismatched date.

3. **Focus time outside visible range (before startHour or after endHour):**
   - **Handling:** `_timeToSlotIndex` clamps to `[0, totalSlots-1]`.
   - **User Impact:** Focus snaps to the nearest visible slot boundary.

## Testing Strategy

### Unit Testing
- **Controller tests** (`test/controllers/mcal_event_controller_test.dart`):
  - `focusedDateTime` starts `null`, `isFocusedOnAllDay` starts `false`
  - `setFocusedDateTime(dt)` updates value and notifies
  - `setFocusedDateTime(dt, isAllDay: true)` updates both fields and notifies
  - `setFocusedDateTime` with same value and same isAllDay does not notify
  - `setFocusedDateTime` with same DateTime but different isAllDay DOES notify
  - `focusedDate` getter and `setFocusedDate` method no longer exist (removed)
  - `navigateToDate(date, focus: true)` sets `focusedDateTime` and `isFocusedOnAllDay = false`
  - `navigateToDate(date, focus: false)` leaves `focusedDateTime` unchanged

### Widget Testing
- **Day View tap-to-focus** (`test/widgets/mcal_day_view_tap_test.dart` or new file):
  - Tap empty time slot → `_focusedSlotIndex` set, indicator visible, `onFocusedDateTimeChanged` fires
  - Tap all-day section → `_focusedSlotIndex` null, `isFocusedOnAllDay` true, all-day indicator visible, `onFocusedDateTimeChanged` fires with midnight
  - Tap time slot then press arrow → focus moves from tapped position
  - Tap event tile → no focus change (event tap takes precedence)
  - Programmatic `setFocusedDateTime` → indicator appears at correct slot

- **Day View keyboard sync** (`test/widgets/mcal_day_view_key_bindings_test.dart` or existing):
  - Press Down → `controller.focusedDateTime` updated with correct time
  - Press A → `controller.focusedDateTime` set to midnight, `isFocusedOnAllDay` true
  - Press T → `controller.focusedDateTime` set to time grid slot

- **Day View left/right day navigation** (`test/widgets/mcal_day_view_focus_test.dart`):
  - Focus time slot, press Left → `controller.displayDate` moves to previous day, `controller.focusedDateTime` same hour:minute on new day
  - Focus time slot, press Right → `controller.displayDate` moves to next day, `controller.focusedDateTime` same hour:minute on new day
  - Focus all-day section, press Left → all-day on previous day (`isFocusedOnAllDay == true`)
  - Focus all-day section, press Right → all-day on next day (`isFocusedOnAllDay == true`)
  - Multiple consecutive Left presses → navigates correctly across multiple days

- **Month View backward compat** (`test/widgets/mcal_month_view_test.dart`):
  - Cell tap with `autoFocusOnCellTap` → `controller.focusedDateTime` set to midnight, `isFocusedOnAllDay` true
  - `onFocusedDateChanged` fires on date changes, NOT on time-only changes
  - Keyboard navigation updates `controller.focusedDateTime`
