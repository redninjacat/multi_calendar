# Design Document: Drop Target Tiles (Layer 3)

## Overview

This design implements the Drop Target Tiles feature by adding a new Layer 3 that shows preview tiles where a dragged event would land, reusing the existing week layout (MCalWeekLayoutContext and the same week layout builder as Layer 2). The current highlight overlay becomes Layer 4. Both layers can be toggled via `showDropTargetTiles` and `showDropTargetOverlay`. The implementation extends MCalEventTileContext with optional drop-target fields, uses MCalEventTileBuilder for `dropTargetTileBuilder`, renames theme keys to dropTargetCell* / dropTargetTile*, and removes or renames MCalDragTargetDetails.

## Steering Document Alignment

### Technical Standards (tech.md)

- **Widget-based Architecture**: Layer 3 and 4 are additional layers in the existing Stack; no new view type.
- **Builder Pattern**: `dropTargetTileBuilder` (MCalEventTileBuilder?), dropTargetOverlayBuilder, dropTargetCellBuilder unchanged; theme provides dropTargetTile* and dropTargetCell* styling.
- **Delegation Pattern**: Drop validation remains via onDragWillAccept; tile and overlay rendering delegate to builders or theme.
- **Performance**: Layer 3 built only when drag active and showDropTargetTiles true; reuse of week layout avoids duplicate layout logic; IgnorePointer on Layer 3.

### Project Structure (structure.md)

- **Naming**: dropTarget* for drop-target features; MCal prefix for public types; snake_case files.
- **Single Responsibility**: Layer 3 construction and phantom-segment building are scoped to helper(s); MCalEventTileContext extended in place.
- **Module Boundaries**: Public API on MCalMonthView; theme in MCalThemeData; context in mcal_month_view_contexts.dart; week layout in mcal_week_layout_contexts.dart and mcal_default_week_layout.dart.

## Code Reuse Analysis

### Existing Components to Leverage

- **MCalWeekLayoutContext / MCalWeekLayoutConfig**: Reuse as-is for Layer 3. Same config (from theme) yields same date-label height and layout.
- **MCalDefaultWeekLayoutBuilder.build** (or developer weekLayoutBuilder): Called with a context that has phantom segments and a drop-target `eventTileBuilder`; no second layout builder.
- **MCalMultiDayRenderer.calculateAllEventSegments**: Use to build phantom segments: create a synthetic event with start = proposedStartDate, end = proposedEndDate, pass list of one event; get back one segment per week row. When building MCalEventTileContext for Layer 3, use the **dragged** event (from MCalDragHandler) as context.event, not the synthetic event, so the builder receives the real event.
- **MCalDragHandler**: Source for proposedStartDate, proposedEndDate, isProposedDropValid, draggedEvent (and sourceDate). No API changes required.
- **MCalEventTileContext**: Extend with optional fields: isDropTargetPreview, dropValid, proposedStartDate, proposedEndDate.
- **MCalEventTileBuilder**: Same typedef for dropTargetTileBuilder; internal wrapper builds context and calls dropTargetTileBuilder or default tile.
- **Theme (MCalThemeData)**: Add dropTargetTile* properties; rename existing dragTarget* to dropTargetCell*.

### Components to Modify

- **_MonthPageWidget** (mcal_month_view.dart): Insert Layer 3 (drop target tiles) between week rows and Layer 4; gate Layer 4 with showDropTargetOverlay; add showDropTargetTiles, showDropTargetOverlay; rename parameter dragTargetTileBuilder → dropTargetTileBuilder; stop passing dropTargetTileBuilder into Layer 1 day cells.
- **_WeekRowWidget** (mcal_month_view.dart): Remove dropTargetTileBuilder (and any drop-target-tile-specific builder) from _DayCellWidget / Layer 1; keep passing through to _MonthPageWidget only where needed for Layer 3.
- **MCalMonthView** (mcal_month_view.dart): Add showDropTargetTiles (default true when enableDragAndDrop), showDropTargetOverlay (default true when enableDragAndDrop); rename dragTargetTileBuilder → dropTargetTileBuilder (type MCalEventTileBuilder?).
- **MCalEventTileContext** (mcal_month_view_contexts.dart): Add optional bool? isDropTargetPreview, bool? dropValid, DateTime? proposedStartDate, DateTime? proposedEndDate; document in dartdoc.
- **MCalThemeData** (mcal_theme.dart): Rename dragTargetValidColor → dropTargetCellValidColor, dragTargetInvalidColor → dropTargetCellInvalidColor, dragTargetBorderRadius → dropTargetCellBorderRadius. Add dropTargetTileBackgroundColor, dropTargetTileInvalidBackgroundColor, dropTargetTileCornerRadius, dropTargetTileBorderColor, dropTargetTileBorderWidth (with fallbacks to eventTile* then defaults).
- **mcal_callback_details.dart**: If MCalDragTargetDetails is unused after refactor, delete it; otherwise rename to MCalDropTargetDetails and update references.

### Integration Points

- **MCalDragHandler**: Layer 3 reads proposedStartDate, proposedEndDate, isProposedDropValid, and the dragged event to build phantom segments and MCalEventTileContext.
- **Week layout**: Same entry point as Layer 2—widget.weekLayoutBuilder ?? MCalDefaultWeekLayoutBuilder.build—with a context that has segments = phantom segments for this month/week, eventTileBuilder = drop-target tile builder wrapper, dateLabelBuilder = SizedBox-placeholder builder (default layout only), overflowIndicatorBuilder = no-op.

## Architecture

### Layer Order and Gating

```
_MonthPageWidget (when enableDragAndDrop)
  `DragTarget<MCalDragData>`
    Stack
      [0] weekRowsColumn (Layer 1 + Layer 2 per week)
      [1] if showDropTargetTiles && _isDragActive → Layer 3 (drop target tiles, IgnorePointer)
      [2] if showDropTargetOverlay && _isDragActive → Layer 4 (highlight overlay, IgnorePointer)
```

- Layer 3: One widget that stacks per-week-row content. Each week row is built by the same week layout builder as Layer 2, with a context containing phantom segments (one per week for the proposed range) and an eventTileBuilder that produces the drop target tile (default or dropTargetTileBuilder). **Alignment with Layer 2:** Layer 3 is at _MonthPageWidget level (e.g. Positioned.fill over the Stack), but each _WeekRowWidget in Layer 2 uses a Row with an optional week number column (e.g. _WeekNumberCell.columnWidth = 36.0) and the calendar content inside an Expanded child. Because the week layout builder is layout-relative (it only sees the Expanded area), Layer 3 must replicate this Row structure for each week row—week number spacer when showWeekNumbers (same width and side as Layer 2, including RTL), then Expanded containing the week layout builder output—so that drop target tiles align pixel-perfectly with Layer 2. This is straightforward but must be done; otherwise Layer 3 content would be offset. Layer 4 sidesteps this because it uses absolute pixel Rect bounds from highlightedCells.
- Layer 4: Existing _buildLayer3HighlightOverlay (method can be renamed to _buildLayer4HighlightOverlay for clarity). Shown only when showDropTargetOverlay is true and _isDragActive.

### Phantom Segments and Context for Layer 3

- From MCalDragHandler: proposedStartDate, proposedEndDate, isProposedDropValid, and the dragged event.
- Build phantom segments: create a synthetic MCalCalendarEvent with start: proposedStartDate, end: proposedEndDate (and e.g. id: '', title: '', isAllDay: true) and call MCalMultiDayRenderer.calculateAllEventSegments([syntheticEvent], monthStart: current month, firstDayOfWeek). This yields one segment per week row that the proposed range spans.
- For each week row, build MCalWeekLayoutContext with: segments = [phantom segment for that week] (from the list above), same dates/columnWidths/rowHeight/config as Layer 2, eventTileBuilder = _buildDropTargetTileBuilderForLayer3 (see below), dateLabelBuilder = builder that returns `SizedBox(height: config.dateLabelHeight, width: dayWidth - 4)` (or same as default layout date label width), overflowIndicatorBuilder = `(context, _) => SizedBox.shrink()`.
- _buildDropTargetTileBuilderForLayer3: a function that returns an MCalEventTileBuilder. That builder, when called with (context, tileContext), ignores the tileContext.event from the segment (which is the synthetic event) and builds a new MCalEventTileContext with event = dragHandler.draggedEvent, segment = tileContext.segment, displayDate = tileContext.displayDate, isAllDay = draggedEvent.isAllDay, width/height = tileContext.width/height, and isDropTargetPreview = true, dropValid = dragHandler.isProposedDropValid, proposedStartDate = dragHandler.proposedStartDate, proposedEndDate = dragHandler.proposedEndDate. Then if widget.dropTargetTileBuilder != null, return dropTargetTileBuilder(context, newContext); else return _buildDefaultDropTargetTile(context, newContext).

### Default Drop Target Tile

- Match default event tile styling (shape, corners, border) but no text.
- Resolve colors: theme.dropTargetTileBackgroundColor ?? theme.dropTargetTileInvalidBackgroundColor (when !dropValid) ?? theme.eventTileBackgroundColor ?? event.color ?? fallback. Same for corner radius, border color/width from dropTargetTile* then eventTile* then defaults.
- Draw a Container/DecoratedBox with the resolved style, no child or empty child.

## Components and Interfaces

### MCalMonthView (public API)

- **New/renamed parameters**: showDropTargetTiles (bool, default true when enableDragAndDrop), showDropTargetOverlay (bool, default true when enableDragAndDrop), dropTargetTileBuilder (MCalEventTileBuilder?, was dragTargetTileBuilder with MCalDragTargetDetails).
- **Removed from Layer 1**: Do not pass dropTargetTileBuilder into _DayCellWidget; pass only through parent chain to where Layer 3 is built.

### MCalEventTileContext (extended)

- **New optional fields**: bool? isDropTargetPreview, bool? dropValid, DateTime? proposedStartDate, DateTime? proposedEndDate. All null when used for Layer 2; set when used for Layer 3.
- **dartdoc**: State clearly that these are only set for drop target tile (Layer 3) builds; null for normal event tiles. Explain proposedStartDate/proposedEndDate as the full proposed drop range across all weeks.

### _MonthPageWidget

- **New state/params**: showDropTargetTiles, showDropTargetOverlay, dropTargetTileBuilder (MCalEventTileBuilder?).
- **Stack children**: After weekRowsColumn, add Layer 3 (when showDropTargetTiles && _isDragActive), then Layer 4 (when showDropTargetOverlay && _isDragActive). Layer 3 is a single widget that lays out one row per week (matching week row layout) and uses the week layout builder with phantom segments and drop-target eventTileBuilder; wrap in IgnorePointer.
- **Layer 4**: Only build when showDropTargetOverlay is true; otherwise omit the overlay even when _isDragActive.

### Helper: Phantom segments for proposed range

- **Purpose**: Given proposedStartDate, proposedEndDate, monthStart, firstDayOfWeek, return `List<List<MCalEventSegment>>` (same shape as calculateAllEventSegments) with one synthetic event so that each week row has at most one segment.
- **Implementation**: Synthetic event with start: proposedStartDate, end: proposedEndDate; call MCalMultiDayRenderer.calculateAllEventSegments([syntheticEvent], monthStart, firstDayOfWeek). Return that list.

### Helper: Layer 3 date label placeholder builder

- **Purpose**: For default week layout, dateLabelBuilder in Layer 3 context must return a SizedBox with same dimensions as default date label.
- **Implementation**: Return SizedBox(height: config.dateLabelHeight, width: dayWidth - 4) (or the same width used in MCalDefaultWeekLayoutBuilder for date labels).

### Theme renames and new properties

- **Rename**: dragTargetValidColor → dropTargetCellValidColor, dragTargetInvalidColor → dropTargetCellInvalidColor, dragTargetBorderRadius → dropTargetCellBorderRadius. Update all usages (e.g. _DropTargetHighlightPainter), copyWith, lerp, fromTheme, dartdoc.
- **New**: dropTargetTileBackgroundColor, dropTargetTileInvalidBackgroundColor, dropTargetTileCornerRadius, dropTargetTileBorderColor, dropTargetTileBorderWidth. Fallbacks: dropTargetTile* → eventTile* → existing event tile defaults. Add to copyWith, lerp, fromTheme.

### MCalDragTargetDetails

- **Action**: If no remaining references after switching to MCalEventTileContext for the tile builder, delete the class and any imports. If still referenced elsewhere, rename to MCalDropTargetDetails and update references.

## Data Models

### MCalEventTileContext (additions)

```dart
// Optional; non-null only when building Layer 3 (drop target tiles).
final bool? isDropTargetPreview;
final bool? dropValid;
final DateTime? proposedStartDate;  // Full proposed drop range start
final DateTime? proposedEndDate;    // Full proposed drop range end
```

### MCalThemeData (drop target)

- **Cell (Layer 4)**: dropTargetCellValidColor, dropTargetCellInvalidColor, dropTargetCellBorderRadius (renamed from dragTarget*).
- **Tile (Layer 3)**: dropTargetTileBackgroundColor, dropTargetTileInvalidBackgroundColor, dropTargetTileCornerRadius, dropTargetTileBorderColor, dropTargetTileBorderWidth.

## Error Handling

1. **Proposed range null or invalid**: When proposedStartDate/proposedEndDate are null or drag is inactive, do not build Layer 3 (no tiles). No exception; simply omit the layer.
2. **Widget disposed during drag**: Existing cleanup in MCalDragHandler and _MonthPageWidget; Layer 3 is stateless from drag state so no extra disposal.
3. **Missing theme values**: Fallback chain (dropTargetTile* → eventTile* → default) prevents null; dropTargetCell* already have defaults in fromTheme.

## Testing Strategy

- **Unit**: Phantom segment helper—given proposed range and month, returns correct segments per week. MCalEventTileContext equality/copyWith with new optional fields.
- **Widget**: Layer 3 visibility when showDropTargetTiles true/false; Layer 4 visibility when showDropTargetOverlay true/false; default tile appearance; dropTargetTileBuilder called with context having isDropTargetPreview true and dropValid set; no dropTargetTileBuilder passed to Layer 1 day cells.
- **Theme**: Renamed dropTargetCell* used by overlay; new dropTargetTile* used by default tile; fallbacks when theme values null.
- **Integration**: Drag event → Layer 3 shows tiles in correct week positions; Layer 4 overlay still works when enabled; both off, tiles only, overlay only, both.
