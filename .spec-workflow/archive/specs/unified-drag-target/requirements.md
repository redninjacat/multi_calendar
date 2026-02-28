# Requirements Document: Unified Drag Target Architecture

## Introduction

This feature refactors the MCalMonthView drag-and-drop implementation from per-cell DragTarget widgets to a single unified DragTarget that wraps all calendar layers. The current architecture uses individual DragTargets for each day cell, relying on `onWillAcceptWithDetails` to detect when a dragged event crosses cell boundaries. This approach is problematic for multi-day events because boundary detection becomes inconsistent when dragging from various positions within a multi-day event tile.

The new architecture uses a single DragTarget with `onMove` for continuous position tracking, mathematical cell detection based on pointer coordinates, and a flexible highlight overlay system. This provides more reliable drop target detection, smoother visual feedback, and better performance.

**Portability Note:** This architecture is designed to be portable to other calendar views (MCalDayView, MCalMultiDayView) in the future. The core concepts (unified DragTarget, mathematical cell/slot detection, debounced updates, flexible overlay builders) should be implemented in a way that can be extracted into shared utilities or base classes for reuse across views.

## Alignment with Product Vision

This feature directly supports several key product principles from product.md:

- **Performance Conscious**: The unified DragTarget with debounced `onMove` reduces widget tree complexity and improves rendering performance during drag operations
- **Customization First**: The new architecture exposes builder callbacks for the highlight overlay, allowing developers to fully customize drop target visuals
- **Developer-Friendly**: Mathematical cell detection provides consistent, predictable behavior regardless of where the user initiates the drag on a multi-day event
- **Mobile-First Design**: Touch-optimized drag-and-drop with smooth 60fps feedback

## Requirements

### Requirement 1: Unified DragTarget Wrapper

**User Story:** As a Flutter developer using MCalMonthView, I want drag-and-drop to work reliably for multi-day events, so that users can drag events from any position and see consistent drop target highlighting.

#### Acceptance Criteria

1. WHEN drag-and-drop is enabled on MCalMonthView THEN the system SHALL wrap all calendar layers (grid, events, overlay) in a single DragTarget widget
2. WHEN a drag operation begins THEN the system SHALL use the DragTarget's `onMove` callback for continuous position tracking instead of per-cell `onWillAcceptWithDetails`
3. WHEN a drag enters the calendar area THEN the system SHALL calculate the target cell(s) mathematically based on pointer position, dayWidth, and event duration

### Requirement 2: Mathematical Cell Detection

**User Story:** As a user dragging a multi-day event, I want the drop target highlighting to accurately reflect where my event will land based on the center of the dragged tile, so that I can precisely position events.

#### Acceptance Criteria

1. WHEN the user drags an event THEN the system SHALL calculate the drop start cell using a center-weighted formula: `floor((localX - grabOffsetX + dayWidth/2) / dayWidth)` (see Revision section for rationale)
2. WHEN the user drags an N-day event THEN the system SHALL highlight N consecutive cells starting from the calculated drop start cell
3. WHEN the calculated drop range extends beyond the current week THEN the system SHALL highlight cells across multiple week rows
4. WHEN the pointer position changes but the calculated drop cell remains the same THEN the system SHALL NOT trigger unnecessary UI updates

### Requirement 3: Debounced Position Updates with Change Detection

**User Story:** As a Flutter developer, I want drag operations to be performant even with frequent pointer movements, so that the calendar maintains smooth 60fps rendering.

#### Acceptance Criteria

1. WHEN `onMove` is called during a drag operation THEN the system SHALL debounce updates using a 16ms time-based threshold
2. WHEN the debounce timer fires THEN the system SHALL process the most recent pointer position (not intermediate positions)
3. WHEN the debounce timer fires THEN the system SHALL calculate the current target cell(s) from the pointer position
4. WHEN the calculated target cell(s) are the same as the previous calculation THEN the system SHALL NOT repaint or call overlay builders
5. WHEN the calculated target cell(s) differ from the previous calculation THEN the system SHALL update the highlight overlay and call builders if provided
6. The processing flow SHALL be: `onMove` → debounce → calculate target cells → compare with previous → paint/call builders only if changed

### Requirement 4: Drop Validation Callback

**User Story:** As a Flutter developer, I want to validate whether a proposed drop location is valid before the drop occurs, so that I can enforce business rules (e.g., no events on weekends).

#### Acceptance Criteria

1. WHEN the calculated drop range changes THEN the system SHALL call the `onDragWillAccept` callback (if provided) with `MCalDragWillAcceptDetails` containing the full proposed date range
2. IF `onDragWillAccept` returns false THEN the system SHALL mark all cells in the drop range as invalid (red highlighting)
3. IF `onDragWillAccept` returns true OR is not provided THEN the system SHALL mark all cells in the drop range as valid (green highlighting)
4. WHEN the user releases the drag over an invalid drop range THEN the system SHALL NOT move the event and SHALL clean up the drag state

### Requirement 5: Flexible Highlight Overlay with Dual Builder Support

**User Story:** As a Flutter developer, I want to customize how drop target cells are highlighted, so that the visual feedback matches my app's design system.

#### Acceptance Criteria

1. WHEN drag-and-drop is active THEN the system SHALL render a highlight overlay layer (Layer 3) above the event layer
2. The system SHALL support two builder callbacks with the following precedence:
   - `dropTargetOverlayBuilder`: Full overlay control (advanced) - if provided, this is used exclusively
   - `dropTargetCellBuilder`: Per-cell styling (simpler) - used if `dropTargetOverlayBuilder` is not provided
   - Default: CustomPainter implementation (most performant) - used if neither builder is provided
3. WHEN `dropTargetOverlayBuilder` is provided THEN the system SHALL call it once with `MCalDropOverlayDetails` containing:
   - List of highlighted cells (each with cellIndex, weekRowIndex, bounds, date)
   - Validity state (isValid)
   - dayWidth, calendarSize, dragData
4. WHEN `dropTargetCellBuilder` is provided (and `dropTargetOverlayBuilder` is not) THEN the system SHALL call it for each highlighted cell with `MCalDropTargetCellDetails` containing:
   - Cell date, bounds, isValid
   - Position flags: isFirst, isLast (for styling rounded corners, etc.)
5. WHEN neither builder is provided THEN the system SHALL use a performant CustomPainter that draws colored rectangles for each highlighted cell
6. The overlay layer SHALL be wrapped in `IgnorePointer` to allow drag events to pass through to the underlying DragTarget

### Requirement 6: Drop Handling

**User Story:** As a user, I want to drop an event and have it move to exactly where the highlighting indicated, so that the visual feedback matches the actual result.

#### Acceptance Criteria

1. WHEN the user releases a drag THEN the system SHALL immediately cancel any pending edge navigation timers
2. WHEN the user releases a drag over a valid drop target THEN the system SHALL move the event to the highlighted date range
3. WHEN the user releases a drag over an invalid drop target THEN the system SHALL NOT move the event and SHALL restore the original state
4. WHEN the drop is processed THEN the system SHALL call `onEventDropped` callback (if provided) with the old and new date ranges

### Requirement 7: Edge Navigation Integration

**User Story:** As a user dragging an event near the screen edge, I want the calendar to navigate to the previous/next month after a delay, so that I can drop events on dates not currently visible.

#### Acceptance Criteria

1. WHEN the pointer is near the left edge during drag AND `dragEdgeNavigationEnabled` is true THEN the system SHALL start the edge navigation timer for previous month
2. WHEN the pointer is near the right edge during drag AND `dragEdgeNavigationEnabled` is true THEN the system SHALL start the edge navigation timer for next month
3. WHEN the pointer moves away from the edge THEN the system SHALL cancel the edge navigation timer
4. WHEN the edge navigation timer fires THEN the system SHALL navigate to the appropriate month while maintaining the drag state

### Requirement 8: Drag State Cleanup

**User Story:** As a developer, I want drag state to be properly cleaned up in all scenarios, so that the calendar remains in a consistent state.

#### Acceptance Criteria

1. WHEN the drag leaves the calendar area (`onLeave`) THEN the system SHALL clear all highlight overlays
2. WHEN the drag is cancelled (e.g., Escape key) THEN the system SHALL clear all drag state and highlights
3. WHEN the drag completes (valid or invalid) THEN the system SHALL clear all drag state and highlights
4. WHEN the widget is disposed during an active drag THEN the system SHALL cancel timers and clear state

## Non-Functional Requirements

### Code Architecture and Modularity

- **Single Responsibility Principle**: The drag handling logic should be encapsulated in `MCalDragHandler`, separate from the view widget
- **Modular Design**: The highlight overlay should be a separate component that can be replaced via builder
- **Dependency Management**: The unified DragTarget should not require changes to existing event tile or layout code
- **Clear Interfaces**: New callbacks (`dropTargetOverlayBuilder`, `dropTargetCellBuilder`) should have well-documented type signatures
- **Portability**: Core drag-and-drop utilities (debouncing, cell detection math, overlay rendering) should be designed for reuse across MCalDayView and MCalMultiDayView in future releases

### Performance

- Drag operations SHALL maintain 60fps rendering on mid-range mobile devices
- The debounce mechanism SHALL limit `onMove` processing to maximum 60 times per second
- The change detection mechanism SHALL prevent unnecessary repaints when the target cell hasn't changed
- The highlight overlay SHALL use efficient rendering (CustomPainter for default, or efficient widget tree for custom)
- Cell detection calculations SHALL be O(1) complexity
- Builder callbacks SHALL only be invoked when the highlight state actually changes

### Reliability

- The system SHALL handle edge cases: drags that start/end outside the calendar, rapid month navigation during drag, widget disposal during drag
- The system SHALL maintain consistent behavior across iOS, Android, Web, and Desktop platforms

### Usability

- Visual feedback SHALL update within one frame (16ms) of the pointer crossing a cell boundary
- The highlighted cells SHALL exactly match where the event will land when dropped
- Invalid drop targets SHALL be clearly distinguished from valid ones (default: red vs green)

---

## Revision (Post-Implementation)

*Appended after implementation review. The implementation intentionally uses a center-weighted cell formula for improved UX; the original left-edge formula was updated.*

### Cell Detection Formula (Req 2) — Revised

**Original:** `(pointerLocalX - grabOffsetX - horizontalSpacing) / dayWidth`

**Current implementation (center-weighted):** The drop target is the cell containing >50% of the first day of the dragged tile. Formula:

```
dropStartCellIndex = floor((localX - grabOffsetX + dayWidth/2) / dayWidth)
```

Adding `dayWidth/2` shifts the calculation from left-edge to center-of-first-day, so the drop aligns with where the user visually perceives the tile center. The `horizontalSpacing` parameter was removed; `grabOffsetX` already accounts for tile layout when the drag started.

**Req 2.1 revised:** WHEN the user drags an event THEN the system SHALL calculate the drop start cell using: `floor((localX - grabOffsetX + dayWidth/2) / dayWidth)` where `localX` is the pointer's X position relative to the week row, `grabOffsetX` is the offset from the tile left edge where the drag started, and `dayWidth` is the width of each day cell.
