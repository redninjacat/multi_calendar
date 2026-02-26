# Month View Implementation vs Specs Review

**Date:** 2026-02-12  
**Scope:** MCalMonthView only (Day and Multi-day views ignored per request)  
**Specs reviewed:** month-view-polish (active), month-view, month-view-enhancements, month-view-enhancements-part-2, month-view-layered-architecture (all archived)

---

## Executive Summary

The month view implementation is **substantially complete** relative to the active **month-view-polish** spec and the archived month-view specs. All five month-view-polish requirements (edge-drag resize, reduced motion, keyboard move, keyboard resize, multi-day semantics) are implemented. A few **minor gaps and documentation updates** are noted below; no blocking missing features were found.

---

## 1. Month View Polish (Active Spec) — Implementation Status

| Requirement | Status | Notes |
|-------------|--------|--------|
| **R1: Event edge-drag resizing** | Done | `enableEventResize`, `onResizeWillAccept`, `onEventResized`, `_ResizeHandle`, `_handleResizeEnd`, platform auto-detect, min 1 day, DST-safe arithmetic, recurring → `modified` exception, no cross-month resize. |
| **R2: System reduced motion** | Done | `enableAnimations` is `bool?`; `_resolveAnimationsEnabled()` uses `MediaQuery.disableAnimationsOf(context)` (Flutter’s equivalent to “reduce motion”). `setDisplayDate(animate: false)` still bypasses. |
| **R3: Keyboard event moving** | Done | Enter/Space → selection mode, Tab/Shift+Tab cycle, arrow keys move, Enter confirms via `_handleDrop`, Escape cancels, `SemanticsService.sendAnnouncement` at each step, month boundary navigation, min/max date respected. |
| **R4: Keyboard event resizing** | Done | R → resize mode, S/E switch edge, M → move mode, arrow keys adjust edge, Enter → `_handleResizeEnd`, Escape cancels, announcements present. |
| **R5: Multi-day semantic span** | Done | `formatMultiDaySpanLabel` in MCalLocalizations; `_EventTileWidget._getSemanticLabel()` appends span when `spanLength > 1`. |

**Polish spec — minor note**

- **Reduced motion API:** Spec text says “`MediaQuery.accessibilityFeaturesOf(context).reduceMotion`”. Implementation uses `MediaQuery.disableAnimationsOf(context)`, which is the correct Flutter API for the same user preference. No code change needed.

---

## 2. Archived Specs — Cross-Check

### 2.1 month-view (archived)

- Grid, events, theme, builders, cell interactivity, controller, navigator, min/max, first day of week, localization, RTL, accessibility, swipe (as option), tap/long-press, etc. are present.
- **showNavigator:** Spec said “defaults to false”; code uses `showNavigator = false`. Match.

### 2.2 month-view-enhancements (archived)

- **Hover:** `onHoverCell`, `onHoverEvent` implemented.
- **Keyboard:** Arrow keys, Home, End, Page Up/Down, Enter/Space, `enableKeyboardNavigation`, `onFocusedDateChanged` implemented.
- **Programmatic navigation:** `displayDate`, `focusedDate`, `setDisplayDate`, `setFocusedDate`, `navigateToDate`, `navigateToDateWithoutAnimation` implemented.
- **Overflow:** `onOverflowTap`, `onOverflowLongPress`; when `onOverflowTap` is null, default bottom sheet is shown (`_showDefaultBottomSheet`). Match.
- **Animations:** `enableAnimations`, `animationDuration`, `animationCurve` implemented (now `bool?` per polish).
- **Week numbers:** `showWeekNumbers`, `weekNumberBuilder` implemented.
- **Focus/callbacks:** `onDisplayDateChanged`, `onViewableRangeChanged`, `onFocusedRangeChanged`, `autoFocusOnCellTap` implemented.
- **Theme:** `focusedDateBackgroundColor`, `focusedDateTextStyle` in MCalThemeData implemented.
- **maxVisibleEvents:** Spec said “maxVisibleEvents (defaults to 3)”. Code has `maxVisibleEventsPerDay` (default 5). Same concept; different name and default. Acceptable.

### 2.3 month-view-enhancements-part-2 (archived)

- **Callback API:** All callbacks use `(BuildContext, MCalXxxDetails)`; theme via `MCalTheme.of(context)`. Match.
- **PageView-style swipe:** Implemented; `enableSwipeNavigation` exists.
- **enableSwipeNavigation default:** Part-2 spec said “defaults to true”. Code uses `enableSwipeNavigation = false`. **Discrepancy:** intentional product choice (swipe off by default) vs spec. Document or align as needed.
- **Simultaneous slide animation:** Month transitions use single PageView; behavior matches.
- **Contiguous multi-day tiles:** Multi-day events render as contiguous tiles in the layered layout.
- **renderMultiDayEventsAsContiguous:** Spec had a boolean (default true). Not present as a parameter; multi-day is always contiguous. **Optional gap:** if “per-day tiles” mode is ever desired, a follow-up could add this toggle.
- **multiDayEventTileBuilder:** Spec had a separate builder with `MCalMultiDayTileDetails`. Current design uses a single `eventTileBuilder` with segment info (e.g. `isFirstSegment`, `isLastSegment`, `segment`). `MCalMultiDayTileDetails` exists in callback_details/multi_day_tile but is not a top-level month view parameter. Functionality is covered by the unified event tile builder; no blocking gap.
- **Drag-and-drop:** Full DnD with validation, visuals, cross-month edge navigation, recurring → `rescheduled` exception. Match.
- **NFR “keyboard alternatives” and “reduced motion” and “multi-day span announcements”:** Addressed by month-view-polish (keyboard move/resize, `enableAnimations` null, multi-day semantics). Match.

### 2.4 month-view-layered-architecture (archived)

- Three-layer stack (grid, events/labels/overflow, drag layer), week layout builder, wrapped builders, unified event tile context with segment info. Implemented.

---

## 3. Gaps and Recommendations

### 3.1 Documentation (non-blocking)

1. **README — enableAnimations**  
   - Current text implies default `true` and only “false for reduced motion.”  
   - Update to: `enableAnimations` is `bool?`; `null` (default) = follow OS reduced motion; `true` = force on; `false` = force off.

2. **README — Event resizing**  
   - Document `enableEventResize`, `onResizeWillAccept`, `onEventResized`, and that resize is off on phones by default when `enableEventResize` is null.

3. **README — Keyboard move/resize**  
   - Document that when drag-and-drop and keyboard navigation are enabled, Enter/Space on a cell with events enters selection; arrow keys move; R for resize, S/E for edge, M for move mode; Enter/Escape confirm/cancel.

### 3.2 Spec vs code (optional / product choice)

| Item | Spec | Code | Recommendation |
|------|------|------|-----------------|
| **enableSwipeNavigation default** | true (part-2) | false | Either update archived spec to “default false” or document the product decision in README/steering. |
| **renderMultiDayEventsAsContiguous** | Parameter (default true) | Always contiguous, no parameter | Acceptable; add a parameter only if “separate tiles per day” mode is required later. |

### 3.3 No blocking gaps

- No month-view features from the reviewed specs were found that are **required** and **missing** in code.
- Remaining work for month-view-polish is **task 13** (widget tests in progress) and **task 14** (full test suite and analyzer).

---

## 4. Verification Commands (for task 14)

- `dart analyze` (project root)
- Full test suite (including `mcal_month_view_polish_test.dart`, `mcal_drag_handler_resize_test.dart`)
- `flutter build web` in `example/`

---

## 5. Summary Table — Specs vs Implementation

| Spec | Focus | Status |
|------|--------|--------|
| month-view | Initial month grid, events, theme, nav, gestures, a11y, RTL | Implemented |
| month-view-enhancements | Hover, keyboard, programmatic nav, overflow, animations, week numbers, focus | Implemented |
| month-view-enhancements-part-2 | Callbacks, swipe, animation, multi-day tiles, DnD | Implemented (swipe default false; no toggle for contiguous) |
| month-view-layered-architecture | 3-layer stack, week layout, unified tile builder | Implemented |
| month-view-polish | Resize, reduced motion, keyboard move/resize, multi-day semantics | Implemented |

**Conclusion:** Month view is complete relative to the active and archived specs, with only documentation and optional/spec-default items to tidy. Proceeding to finish task 13 (polish widget tests) and task 14 (verification) is appropriate.
