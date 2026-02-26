# Month View Polish — Re-Review (Amended Spec)

**Date:** 2026-02-12  
**Scope:** Amended Month View Polish spec (requirements, design, tasks)  
**Purpose:** Confirm spec consistency and implementation coverage after amendments.

---

## 1. Amended Spec Summary

The amended spec adds **three new requirements** (R6–R8) and **extends R1** with cross-month resize behavior. R3 is updated so recurring moves use `modified` (not `rescheduled`).

| Req | Title | Change |
|-----|--------|--------|
| **R1** | Event Edge-Drag Resizing | **Extended:** Criteria 21–26 add cross-month resize (auto-navigate at grid boundary, gesture persists across page, PageView no swipe during resize, recompute highlights after navigation, RTL). Original 22 said "resizing is bounded to the visible month"; amended 22–25 replace that with cross-month auto-navigation. |
| **R2** | System Reduced Motion | Unchanged |
| **R3** | Keyboard Event Moving | **Updated:** Criterion 8 now requires a `modified` exception with full updated event (preserving prior modifications), not `rescheduled`. |
| **R4** | Keyboard Event Resizing | Unchanged |
| **R5** | Multi-Day Event Semantic Span | Unchanged |
| **R6** | **NEW** Recurring Event Move Preserves Modifications | Drag/keyboard move must preserve prior modifications (e.g. resized duration); use `modified` exception with full event, not `rescheduled`. |
| **R7** | **NEW** Modified Recurring Event Visibility Across Months | Controller must include `modified` exceptions in query results when modified event dates overlap the range, even if original occurrence date is outside the range. |
| **R8** | **NEW** Color Utilities and Drop Target Tile Styling | MCalColorUtils (lighten, darken, soften); default drop target tile: 1px border in tile color + softened opaque fill; honour theme border when set; no transparency. |

---

## 2. Requirements ↔ Design ↔ Tasks Alignment

### R1 (incl. cross-month resize)

- **Design:** Component 4 references Component 10; **Component 10** describes parent-level resize state, Listener, edge proximity, post-frame recompute, PageView physics.
- **Tasks:** Phase 9 — Task 15 (move state to parent, Listener, callbacks), Task 16 (edge proximity + auto-navigate), Task 17 (NeverScrollableScrollPhysics). All [x].
- **Implementation:** Present: `_isResizeInProgress`, `NeverScrollableScrollPhysics()` when resize active, `_checkResizeEdgeProximityFromParent`, `_processResizeUpdateFromParent`, `_lastResizePointerPosition`, post-frame callback.

### R3 (recurring move → modified) & R6

- **Design:** **Component 12** — use `modified(originalDate, modifiedEvent: updatedEvent)` instead of `rescheduled` in both `_handleDrop` and `_handleKeyboardDrop`.
- **Tasks:** Phase 10 — Task 19 (replace rescheduled with modified in both handlers). [x].
- **Implementation:** Comments in month_view reference "rescheduled would revert"; handlers use `MCalRecurrenceException.modified(...)` with full `updatedEvent`.

### R7 (modified visibility across months)

- **Design:** **Component 11** — in `_getExpandedOccurrences`, for exceptions whose original date is outside the query range, add `else if (exception.type == MCalExceptionType.modified)` and include modified event when its dates overlap the range.
- **Tasks:** Phase 10 — Task 18. [x].
- **Implementation:** Controller has the block at ~818: `else if (exception.type == MCalExceptionType.modified)` with overlap check and `expanded.add(modEvent)`.

### R8 (color utils + drop target styling)

- **Design:** **Component 13** (MCalColorUtils), **Component 14** (default drop target: border + soften fill, theme override, opaque).
- **Tasks:** Phase 11 — Task 20 (color utils), Task 21 (default drop target tile). [x]. Phase 13 — Tasks 23–25 (tests, controller tests, final run). [x].
- **Implementation:** `lib/src/utils/color_utils.dart` with lighten/darken/soften; exported from barrel; `_buildDefaultDropTargetTile` uses `tileColor.soften(brightness)` when no explicit theme border, 1px border in tile color, theme `dropTargetTileBorderWidth`/`dropTargetTileBorderColor` honoured when set.

---

## 3. Internal Consistency Notes

### Design doc overview (minor)

- **Current:** "This design covers **four** enhancements" and lists five bullet points (resize, reduced motion, keyboard move, keyboard resize, multi-day semantics). It does not mention R6, R7, or R8.
- **Recommendation:** Update the overview to state that the design covers **eight** requirements (or list R6–R8) so the design doc matches the amended requirements. Optional wording: "This design covers the Month View Polish enhancements: event edge-drag resizing (including cross-month), reduced motion, keyboard event moving and resizing, multi-day semantic labels, recurring move preservation (modified exceptions), modified exception visibility across months, and color utilities with drop target tile styling."

### Requirements doc

- **R1.22–1.25:** Clearly specify end-edge → next month, start-edge → previous month, gesture persistence, and PageView no-swipe during resize. No ambiguity.
- **R3.8 / R6:** Aligned: both require `modified` with full event for recurring moves (keyboard and drag).

### Tasks doc

- Task 8 text still says "No cross-month edge navigation during resize" in the task body; the **amendments** added cross-month in a later phase (Phase 9). So Task 8 is correct as originally scoped; Phase 9 adds cross-month. No change needed; optional: add a one-line note in Task 8 that cross-month is added in Phase 9.

---

## 4. Implementation Coverage (Amended Parts)

| Amended requirement | Implementation status |
|---------------------|------------------------|
| R1.21–1.26 Cross-month resize | ✅ Parent state, Listener, edge proximity, auto-navigate, post-frame recompute, NeverScrollableScrollPhysics during resize. |
| R3.8 / R6 Recurring move → modified | ✅ Both _handleDrop and _handleKeyboardDrop use modified(originalDate, modifiedEvent: updatedEvent). |
| R7 Modified visibility across months | ✅ Controller _getExpandedOccurrences includes modified exceptions when modified event overlaps range. |
| R8 Color utils | ✅ MCalColorUtils (lighten, darken, soften), exported. |
| R8 Drop target default styling | ✅ Default: 1px border in tile color, fill = tileColor.soften(brightness); theme border honoured when set; opaque. |

---

## 5. Conclusion

- **Requirements:** Amended spec is consistent: R1 extended, R3.8/R6 aligned, R7 and R8 clearly specified.
- **Design:** Components 10–14 correctly describe cross-month resize, controller visibility, move→modified, color utils, and drop target styling.
- **Tasks:** Phases 9–13 and Tasks 15–25 map to the amended requirements and are all marked [x].
- **Implementation:** Cross-month resize, recurring move preservation, controller cross-range modified visibility, color utils, and drop target styling are implemented as specified.

**Single doc fix suggested:** Update the design document’s opening overview to reflect eight requirements (or list R6–R8) so it matches the amended scope.
