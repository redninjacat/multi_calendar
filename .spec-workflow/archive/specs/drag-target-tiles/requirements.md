# Requirements Document: Drop Target Tiles (Layer 3)

## Introduction

This specification implements the previously introduced but never wired-up `dropTargetTileBuilder` feature for MCalMonthView. The parameter exists and is passed through the widget tree but is never used to build any widget; the code path ends in Layer 1 (grid-only) day cells that do not render event tiles.

This feature adds a new **Layer 3** that renders "drop target tiles"—preview tiles showing where a dragged event would land—by **reusing the existing \[MCalWeekLayoutContext] and the same week layout builder as Layer 2** (developer-provided `weekLayoutBuilder` if set, otherwise the built-in default). No second layout builder is introduced; Layer 3 constructs a context with phantom segments and a tile builder that implements drop target tile logic (default or `dropTargetTileBuilder`). The same config (and thus the same date-label reserved space) is used, so drop target tiles do not cover date labels. For the default implementation, the `dateLabelBuilder` supplied in that context SHALL return a **SizedBox with the same dimensions** as the default date label (height \= config.dateLabelHeight, width as used in the default layout) so that layout space is reserved correctly. Date label height is already exposed via \[MCalThemeData.dateLabelHeight] and flows into \[MCalWeekLayoutConfig]; no new exposure is required for Layer 3. The current highlight overlay (colored cell rectangles) becomes **Layer 4**. Layer 3 displays at most one phantom event per week row (the proposed drop span), always in row 0. Drop target tiles can be disabled via `showDropTargetTiles`. The default tile looks like the default event tile but without text; customization is via new theme keys (with fallback to event tile theme) and optional `dropTargetTileBuilder`. **No new details type is introduced:** \[MCalEventTileContext] is extended with optional, drag-only fields (\[isDropTargetPreview], \[dropValid], \[proposedStartDate], \[proposedEndDate]) that are non-null only when building Layer 3. The public API uses the **same builder type** as event tiles: `dropTargetTileBuilder` is \[MCalEventTileBuilder]? (i.e. `Widget Function(BuildContext, MCalEventTileContext)?`). The internal `eventTileBuilder` passed into the week layout context for Layer 3 builds this context (with the drag-only fields set) and then calls `dropTargetTileBuilder(context, tileContext)` if provided, else the default no-text tile. API documentation SHALL clearly document the drag-only fields and when they are set. Existing drop-target theme keys are renamed to include "Cell" or "Tile" so that cell overlay (Layer 4) and tile (Layer 3) styling are unambiguous and no key is shared between both.

## Naming Convention (Drag vs Drop)

* **Drag** = the thing being dragged: dragged tile, source tile (e.g. `draggedTileBuilder`, `dragSourceTileBuilder`, `MCalDragData`). Keep "drag" in these names.
* **Drop** = the target where you drop: preview tiles (Layer 3), cell overlay (Layer 4). Use **dropTarget** for these (e.g. `dropTargetTileBuilder`, `showDropTargetTiles`, `dropTargetCellValidColor`, `dropTargetOverlayBuilder`).
* The existing type **MCalDragTargetDetails** (event, targetDate, isValid) is not used by this spec (the tile builder uses [MCalEventTileContext] with optional fields). If MCalDragTargetDetails is not used elsewhere, it SHALL be deleted. If it remains in use elsewhere, it SHOULD be renamed to **MCalDropTargetDetails** for consistency.

## Alignment with Product Vision

* **Customization First**: Exposes `dropTargetTileBuilder` and dropTargetTile\* theme/widget properties so developers can match app design.
* **Developer-Friendly**: Same week layout builder and segment semantics as Layer 2 reduce cognitive load and keep one layout stack.
* **Performance Conscious**: Layer 3 is non-interactive (IgnorePointer) and only visible during drag; reuse of existing layout avoids a second layout builder.

## Requirements

### Requirement 1: Layer Reorganization

**User Story:** As a Flutter developer, I want the drop target overlay and drop target tiles to live on distinct layers, so that I can style or disable them independently.

#### Acceptance Criteria

1. WHEN the month calendar is built with drag-and-drop enabled THEN the system SHALL order layers as: Layer 1 (grid), Layer 2 (events and date labels), Layer 3 (drop target tiles, when enabled and shown), Layer 4 (drop target overlay, when enabled and shown).
2. WHEN a drag is active and Layer 4 is shown THEN the system SHALL render Layer 4 above Layer 3 so that the overlay appears on top of the tiles.
3. WHEN both drop target tiles and the highlight overlay are enabled THEN the system SHALL show both during drag (tiles under overlay).

### Requirement 2: New Layer 3 — Drop Target Tiles

**User Story:** As a user dragging an event, I want to see preview tiles that match the week layout (same position and span as real events), so that the drop preview aligns with where events actually render.

#### Acceptance Criteria

1. WHEN `showDropTargetTiles` is true AND a drag is active AND a proposed drop range exists THEN the system SHALL render a new Layer 3 that displays drop target tiles for the proposed range.
2. WHEN rendering Layer 3 THEN the system SHALL use the **same context type \[MCalWeekLayoutContext] and the same week layout builder** as Layer 2 (developer-provided `weekLayoutBuilder` if set, otherwise the built-in default). The system SHALL NOT introduce a second or different layout builder for Layer 3.
3. WHEN building the \[MCalWeekLayoutContext] for Layer 3 THEN the system SHALL supply exactly one phantom segment per week row (the portion of the proposed drop range in that week) and SHALL supply an `eventTileBuilder` that implements the drop target tile logic (default tile or `dropTargetTileBuilder`). The context SHALL use the same \[MCalWeekLayoutConfig] (and thus the same date label height and layout values) as Layer 2; date label height is already configurable via \[MCalThemeData.dateLabelHeight] and requires no new API.
4. WHEN using the **default** week layout implementation for Layer 3 THEN the `dateLabelBuilder` passed in the context SHALL return a **SizedBox with the same dimensions as the default date label** (height \= config.dateLabelHeight, width as used for date labels in the default layout) so that date-label space is reserved correctly and the placeholder matches the default label size.
5. WHEN Layer 3 is rendered THEN the system SHALL reserve the same date-label space as Layer 2 (using the same theme/config) so that drop target tiles do not cover date labels.
6. WHEN Layer 3 is rendered THEN the phantom tile(s) SHALL be placed in the first event row (row 0) under the date label area; there is at most one phantom event per week so row assignment always yields row 0.
7. WHEN Layer 3 is visible THEN the system SHALL wrap the layer in `IgnorePointer` so that pointer events pass through to the underlying DragTarget.
8. WHEN no drag is active OR `showDropTargetTiles` is false THEN the system SHALL not render Layer 3.
9. WHEN Layer 3 is rendered THEN the system SHALL align pixel-perfectly with Layer 2. Because Layer 3 is built at the _MonthPageWidget level (e.g. Positioned.fill) while each week row in Layer 2 is a Row with an optional week number column (e.g. fixed width) and an Expanded child containing the layout, the implementation SHALL replicate that same Row structure for each week row in Layer 3 (week number spacer when showWeekNumbers, then Expanded with the week layout builder output) so that drop target tiles line up with event tiles. Layer 4 does not need this because it uses absolute pixel bounds from highlightedCells.

### Requirement 3: showDropTargetTiles, showDropTargetOverlay, and Independence

**User Story:** As a developer, I want to control drop target tiles and the drop target overlay independently, so that I can show overlay only, tiles only, both, or neither.

#### Acceptance Criteria

1. WHEN configuring MCalMonthView THEN the system SHALL provide a boolean property `showDropTargetTiles` (default true when drag-and-drop is enabled) to enable or disable Layer 3 (drop target tiles).
2. WHEN configuring MCalMonthView THEN the system SHALL provide a boolean property `showDropTargetOverlay` (default true when drag-and-drop is enabled) to enable or disable Layer 4 (the cell highlight overlay). **Today there is no such parameter**—Layer 4 is always shown when a drag is active; this spec introduces the parameter so developers can choose overlay only, tiles only, both, or neither.
3. WHEN `showDropTargetTiles` is false THEN the system SHALL not render Layer 3 regardless of overlay configuration.
4. WHEN `showDropTargetOverlay` is false THEN the system SHALL not render Layer 4 (no cell highlight overlay, and no call to dropTargetOverlayBuilder or dropTargetCellBuilder or default CustomPainter for the overlay) regardless of tile configuration.
5. The two parameters SHALL be independent: either layer can be on or off, allowing overlay only, tiles only, both, or neither during drag.

### Requirement 4: Default Drop Target Tile (No Text)

**User Story:** As a developer, I want the default drop target tile to look like the default event tile but without text, so that the preview is recognizable and unobtrusive.

#### Acceptance Criteria

1. WHEN Layer 3 is rendered AND `dropTargetTileBuilder` is not provided THEN the system SHALL render a default tile that matches the default event tile styling (shape, corners, border) but SHALL NOT display event title or other text.
2. WHEN resolving default tile styling THEN the system SHALL use dropTargetTile* theme properties when present; when absent, SHALL fall back to the corresponding event tile theme properties (e.g. eventTileBackgroundColor, eventTileCornerRadius); when those are absent, SHALL use the same fallbacks as the regular event tile builder (e.g. event color or theme default).

### Requirement 5: dropTargetTileBuilder and MCalEventTileContext (Reuse, No New Type)

**User Story:** As a developer, I want to customize the drop target tile per segment via the same builder signature as event tiles, with context that indicates drag state and proposed range, so that I can match my app’s design without learning a second type.

#### Acceptance Criteria

1. The system SHALL **reuse \[MCalEventTileContext]** for the drop target tile builder; the system SHALL NOT introduce a new type (e.g. MCalDropTargetTileDetails).
2. The system SHALL extend \[MCalEventTileContext] with optional, **drag-only** fields that are non-null only when building Layer 3: `bool? isDropTargetPreview`, `bool? dropValid`, `DateTime? proposedStartDate`, `DateTime? proposedEndDate`. When building a normal event tile (Layer 2), these fields SHALL be null.
3. `proposedStartDate` and `proposedEndDate` SHALL represent the **full proposed drop range** (where the event would land if dropped now, across all weeks). The \[segment] and \[displayDate] already describe this week’s slice; the proposed dates are for builders that need the full range (e.g. tooltips, validation).
4. The public API SHALL use the **same builder type** as event tiles: `dropTargetTileBuilder` SHALL have type \[MCalEventTileBuilder]? (i.e. `Widget Function(BuildContext, MCalEventTileContext)?`).
5. WHEN building Layer 3 THEN the system SHALL pass an `eventTileBuilder` into \[MCalWeekLayoutContext] that: builds an \[MCalEventTileContext] with the drag-only fields set (and \[event], \[segment], \[displayDate], etc. from the phantom segment); THEN calls `dropTargetTileBuilder(context, tileContext)` if provided, else builds the default no-text tile.
6. WHEN the developer provides `dropTargetTileBuilder` THEN the system SHALL use the returned widget for that segment in place of the default tile; widget-level styling overrides SHALL follow the same pattern as event tiles (widget overrides theme when provided).
7. **API documentation (dartdoc)** SHALL make the usage of the drag-only fields very clear: when they are set (only for Layer 3 / drop target tiles), that they are null for normal event tiles, what `proposedStartDate`/`proposedEndDate` represent (full drop range), and how to check `isDropTargetPreview` and `dropValid` in a shared builder if used for both events and drop targets.

### Requirement 6: Theme Key Renames (Cell vs Tile)

**User Story:** As a developer, I want theme key names to clearly indicate whether they apply to the cell overlay (Layer 4) or the event-style tile (Layer 3), so that I can style each without ambiguity.

#### Acceptance Criteria

1. WHEN a theme property is used only for the cell highlight overlay (Layer 4) THEN its name SHALL include "Cell" (e.g. dropTargetCellValidColor, dropTargetCellInvalidColor, dropTargetCellBorderRadius).
2. WHEN a theme property applies to the drop target tile (Layer 3) THEN its name SHALL include "Tile" (e.g. dropTargetTileBackgroundColor, dropTargetTileCornerRadius).
3. The system SHALL NOT use the same theme key for both the cell overlay and the tile; each key SHALL apply to exactly one of Layer 3 or Layer 4.
4. Existing keys `dragTargetValidColor`, `dragTargetInvalidColor`, and `dragTargetBorderRadius` are used in code only by the cell overlay (CustomPainter); the system SHALL rename them to `dropTargetCellValidColor`, `dropTargetCellInvalidColor`, and `dropTargetCellBorderRadius` respectively (using "drop" for the drop-target overlay), and SHALL update all usages and theme defaults/copyWith/lerp/documentation accordingly.

### Requirement 7: New Theme and Widget Properties for Tiles

**User Story:** As a developer, I want to style drop target tiles via theme and optional widget overrides, so that I can match event tile styling or differentiate it without a custom builder.

#### Acceptance Criteria

1. WHEN styling the default drop target tile (Layer 3) THEN the system SHALL support theme properties that mirror event tile styling, with fallback to event tile theme when not set. At minimum: background color (valid and invalid), corner radius, border color, border width. Naming SHALL use the "Tile" suffix (e.g. dropTargetTileBackgroundColor, dropTargetTileInvalidBackgroundColor, dropTargetTileCornerRadius, dropTargetTileBorderColor, dropTargetTileBorderWidth).
2. WHEN both theme and widget-level overrides exist for a drop-target tile property THEN the widget-level value SHALL take precedence, consistent with event tile behavior.
3. Default values or fallback chain for tile theme SHALL be: dropTargetTile* if set, else eventTile\* if set, else the same fallbacks used by the default event tile (e.g. event.color, then theme default).

### Requirement 8: Remove Dead dropTargetTileBuilder Wiring from Layer 1

**User Story:** As a maintainer, I want the only use of `dropTargetTileBuilder` to be in Layer 3, so that there is no dead parameter passing through Layer 1 day cells.

#### Acceptance Criteria

1. WHEN building Layer 1 (grid day cells) THEN the system SHALL NOT pass `dropTargetTileBuilder` (or any drag-target-tile-specific builder) into the day cell widget for use in Layer 1; the parameter SHALL only be used where Layer 3 is built (e.g. at the week/month page level).
2. The system MAY continue to pass `dropTargetTileBuilder` through parent widgets only as needed to reach the Layer 3 construction site; it SHALL NOT be passed into widgets that do not participate in building Layer 3.

## Non-Functional Requirements

### Code Architecture and Modularity

* Layer 3 SHALL reuse \[MCalWeekLayoutContext] and the same week layout builder as Layer 2 (no second layout builder). The context is populated with phantom segments and an `eventTileBuilder` that implements drop target tile behavior. Implementation SHALL replicate the same per-week-row Row structure as Layer 2 (week number column/spacer when showWeekNumbers, then Expanded) so Layer 3 aligns pixel-perfectly with Layer 2.
* In the default implementation, the `dateLabelBuilder` used for Layer 3 SHALL return a SizedBox with the same height and width as the default date label (config.dateLabelHeight and the width used in the default layout) so that reserved space is consistent.
* Single responsibility: Layer 3 construction and phantom segment preparation should be clearly scoped (e.g. one method or helper that builds the context and invokes the same week layout builder).
* Clear interfaces: The extended \[MCalEventTileContext] (including drag-only fields) and any new theme properties must be documented (dartdoc) and consistent with existing callback/details patterns. The dartdoc for the drag-only fields SHALL clearly state that they are only set when building Layer 3 (drop target tiles), are null otherwise, and SHALL explain the meaning of \[proposedStartDate]/\[proposedEndDate] (full proposed drop range).

### Performance

* Layer 3 SHALL only be built when drag is active and `showDropTargetTiles` is true.
* Reuse of Layer 2 layout logic SHALL avoid duplicate layout calculations where possible (e.g. shared config, same row-assignment algorithm).

### Reliability

* When proposed drop range is empty or invalid, Layer 3 SHALL show nothing (no tiles).
* Layer 3 SHALL not affect hit-testing for the unified DragTarget; IgnorePointer SHALL be applied so drops and move events are unchanged.

### Usability

* Default tiles SHALL be visually consistent with event tiles (no text) so users recognize the preview. Custom builders and theme allow full customization.