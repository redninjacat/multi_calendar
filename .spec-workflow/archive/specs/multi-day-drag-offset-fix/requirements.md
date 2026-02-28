# Requirements Document: Multi-Day Drag Offset Fix

## Introduction

This specification addresses a bug fix for multi-day event drag-and-drop functionality in MCalMonthView. When dragging multi-day events, the grab position (where the user touched the tile) was not being correctly tracked, causing events to drop in incorrect positions. The tile's left edge determines where the event lands, but the system was not correctly calculating the offset from the grab point to the tile's left edge.

The root cause was a timing issue with Flutter's `LongPressDraggable` widget, where the `data` parameter is captured at build time, but the grab offset is only known after the `onPointerDown` event fires. This resulted in stale grab offset values being used during drop calculations.

## Alignment with Product Vision

This fix directly supports the product vision for **Drag and Drop** functionality (Key Feature #5) and the principle of **Developer-Friendly** APIs. The multi-calendar package promises intuitive drag-and-drop event manipulation, and this fix ensures that multi-day events land exactly where users expect based on where they grabbed the tile.

## Requirements

### Requirement 1: Accurate Grab Position Tracking

**User Story:** As a calendar user, I want the event to land on the date where I visually dropped it, so that drag-and-drop behaves intuitively regardless of where I grabbed the event tile.

#### Acceptance Criteria

1. WHEN a user touches anywhere on a multi-day event tile THEN the system SHALL record the exact horizontal position of the touch relative to the tile's left edge
2. WHEN the user drags the event to a new position THEN the system SHALL calculate the drop position based on where the tile's left edge would land, not where the cursor is
3. IF the user grabs the middle of a 5-day event and drags it THEN the tile's left edge SHALL land on the cell that is appropriately offset from the cursor position
4. WHEN the same tile is dragged multiple times THEN the system SHALL correctly track the grab position for each drag operation independently

### Requirement 2: Multi-Day Event Highlighting During Drag

**User Story:** As a calendar user, I want to see which cells will be occupied by the event when I drop it, so that I can position it accurately.

#### Acceptance Criteria

1. WHEN dragging a multi-day event THEN the system SHALL highlight all cells that will be occupied by the event after drop
2. WHEN the cursor is over a cell THEN the highlighted range SHALL be calculated based on the grab offset, not the cursor position
3. IF the user grabbed day 3 of a 5-day event and the cursor is over Wednesday THEN the highlight SHALL show Monday through Friday (not Wednesday through Sunday)

### Requirement 3: Timing-Safe Drag Data Transfer

**User Story:** As a developer, I want the drag data to always contain accurate grab offset information, so that drop calculations work correctly regardless of Flutter's widget rebuild timing.

#### Acceptance Criteria

1. WHEN a drag operation begins THEN the MCalDragData SHALL contain the grab offset value captured at pointer-down time
2. IF the widget rebuilds between pointer-down and drag-start THEN the grab offset value SHALL still be correct
3. WHEN the drop target reads the grab offset from MCalDragData THEN the value SHALL match the position where the user actually touched

## Non-Functional Requirements

### Code Architecture and Modularity
- **Timing Safety**: The solution must work around Flutter's `LongPressDraggable` timing where `data` is captured at build time
- **Mutable Reference Pattern**: Use a holder pattern to allow grab offset updates after data capture
- **Minimal API Changes**: The fix should not change the public API surface

### Performance
- No additional frame rebuilds required during drag operations
- Direct mutation of holder object avoids unnecessary widget rebuilds

### Reliability
- Solution must work consistently across repeated drag operations
- Must handle edge cases (rapid consecutive drags, drags at tile boundaries)

### Backward Compatibility
- Existing single-day event drag behavior must remain unchanged
- All existing drag-and-drop tests must continue to pass
