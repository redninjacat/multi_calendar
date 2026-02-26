# Tasks Document: Drop Target Tiles (Layer 3)

## Phase 1: Theme and context

- [x] 1. Rename theme keys to dropTargetCell*
  - Files: lib/src/styles/mcal_theme.dart, lib/src/widgets/mcal_month_view.dart
  - Rename dragTargetValidColor → dropTargetCellValidColor, dragTargetInvalidColor → dropTargetCellInvalidColor, dragTargetBorderRadius → dropTargetCellBorderRadius in MCalThemeData. Update copyWith, lerp, fromTheme, dartdoc. Update all usages in mcal_month_view.dart (e.g. _DropTargetHighlightPainter).
  - Purpose: Unambiguously scope theme to Layer 4 cell overlay.
  - _Leverage: Existing theme property patterns in mcal_theme.dart; _DropTargetHighlightPainter constructor._
  - _Requirements: 6.1, 6.4_
  - _Prompt: Implement the task for spec drag-target-tiles, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter/Dart developer. Task: Rename the three drag-target theme keys to dropTargetCell* (dropTargetCellValidColor, dropTargetCellInvalidColor, dropTargetCellBorderRadius) in MCalThemeData and update every usage (mcal_month_view.dart painter, copyWith, lerp, fromTheme, dartdoc). Restrictions: Do not change behavior; only rename. _Leverage: mcal_theme.dart, mcal_month_view.dart _DropTargetHighlightPainter. _Requirements: 6.1, 6.4. Success: All references updated, tests/analyzer pass. Before implementing: set this task to in-progress [-] in tasks.md. After completing: run log-implementation with artifacts, then set task to complete [x]._

- [x] 2. Add dropTargetTile* theme properties
  - File: lib/src/styles/mcal_theme.dart
  - Add dropTargetTileBackgroundColor, dropTargetTileInvalidBackgroundColor, dropTargetTileCornerRadius, dropTargetTileBorderColor, dropTargetTileBorderWidth. Implement copyWith, lerp, fromTheme with fallbacks to eventTile* then existing defaults.
  - Purpose: Allow styling default drop target tile (Layer 3).
  - _Leverage: Existing eventTile* properties and fromTheme defaults in mcal_theme.dart._
  - _Requirements: 6.2, 7.1, 7.3_
  - _Prompt: Implement the task for spec drag-target-tiles, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter theme developer. Task: Add five dropTargetTile* theme properties (dropTargetTileBackgroundColor, dropTargetTileInvalidBackgroundColor, dropTargetTileCornerRadius, dropTargetTileBorderColor, dropTargetTileBorderWidth) to MCalThemeData with copyWith, lerp, and fromTheme; fallbacks: dropTargetTile* → eventTile* → existing event tile defaults. Restrictions: Follow existing theme patterns; no breaking changes to existing APIs. _Leverage: mcal_theme.dart eventTile* and fromTheme. _Requirements: 6.2, 7.1, 7.3. Success: Theme compiles, fallback chain documented. Before implementing: set this task to [-] in tasks.md. After completing: log-implementation then set [x]._

- [x] 3. Extend MCalEventTileContext with drop-target fields
  - File: lib/src/widgets/mcal_month_view_contexts.dart
  - Add optional bool? isDropTargetPreview, bool? dropValid, DateTime? proposedStartDate, DateTime? proposedEndDate to MCalEventTileContext. Update constructor, equality, copyWith if present. Add dartdoc stating these are only set for Layer 3 (drop target tiles), null otherwise; explain proposedStartDate/proposedEndDate as full proposed drop range.
  - Purpose: Reuse same context type for dropTargetTileBuilder.
  - _Leverage: Existing MCalEventTileContext fields and dartdoc style._
  - _Requirements: 5.1, 5.2, 5.7_
  - _Prompt: Implement the task for spec drag-target-tiles, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Dart API developer. Task: Add four optional fields to MCalEventTileContext (isDropTargetPreview, dropValid, proposedStartDate, proposedEndDate) with clear dartdoc: only set for Layer 3, null for Layer 2; proposed dates = full drop range. Update constructor and any equality/copyWith. Restrictions: Backward compatible; do not remove existing fields. _Leverage: mcal_month_view_contexts.dart MCalEventTileContext. _Requirements: 5.1, 5.2, 5.7. Success: Context compiles, dartdoc clear. Before implementing: set task [-] in tasks.md. After completing: log-implementation then set [x]._

## Phase 2: Public API and parameter flow

- [x] 4. Add showDropTargetTiles, showDropTargetOverlay; rename to dropTargetTileBuilder (MCalEventTileBuilder?)
  - File: lib/src/widgets/mcal_month_view.dart
  - On MCalMonthView: add showDropTargetTiles (default true when enableDragAndDrop), showDropTargetOverlay (default true when enableDragAndDrop). Rename dragTargetTileBuilder to dropTargetTileBuilder and change type to MCalEventTileBuilder? (Widget Function(BuildContext, MCalEventTileContext)?). Pass new params through to _MonthPageWidget.
  - Purpose: Public API for toggles and builder signature. Must run before task 5 so the builder type is switched and MCalDragTargetDetails can be removed or renamed.
  - _Leverage: Existing MCalMonthView constructor and parameter forwarding._
  - _Requirements: 3.1, 3.2, 5.4_
  - _Prompt: Implement the task for spec drag-target-tiles, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter widget API developer. Task: Add showDropTargetTiles and showDropTargetOverlay (bool, default true when enableDragAndDrop) to MCalMonthView; rename dragTargetTileBuilder to dropTargetTileBuilder with type MCalEventTileBuilder?. Pass all three through to _MonthPageWidget. Restrictions: Keep backward compatibility for existing callers (rename parameter; they must update to new signature). _Leverage: mcal_month_view.dart MCalMonthView and constructor. _Requirements: 3.1, 3.2, 5.4. Success: API compiles; params flow to _MonthPageWidget. Before implementing: set task [-] in tasks.md. After completing: log-implementation then set [x]._

- [x] 5. Delete or rename MCalDragTargetDetails
  - Files: lib/src/widgets/mcal_callback_details.dart, example app, README if it references the type
  - Run after task 4 (dropTargetTileBuilder is now MCalEventTileBuilder?). If MCalDragTargetDetails has no remaining usages, delete the class and fix imports; update the example in this task or in task 10 if it was the only caller. If still used elsewhere, rename to MCalDropTargetDetails and update references.
  - Purpose: Align naming (drop) and avoid dead type once the builder signature has changed.
  - _Leverage: mcal_callback_details.dart; grep for MCalDragTargetDetails and dropTargetTileBuilder._
  - _Requirements: Naming convention (MCalDragTargetDetails)_
  - _Prompt: Implement the task for spec drag-target-tiles, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Dart codebase maintainer. Task: After task 4, dropTargetTileBuilder uses MCalEventTileBuilder. Determine if MCalDragTargetDetails is used anywhere. If not used: delete the class and remove/update imports; update example if it was the only caller. If used: rename to MCalDropTargetDetails and update all references. Restrictions: Do not break call sites; update example and README if they reference the type. _Leverage: mcal_callback_details.dart, grep for usages. _Requirements: Spec naming convention. Success: No references to old name or type removed if unused. Before implementing: set task [-] in tasks.md. After completing: log-implementation then set [x]._

- [x] 6. Remove dropTargetTileBuilder from Layer 1 (day cells)
  - File: lib/src/widgets/mcal_month_view.dart
  - In _WeekRowWidget / _DayCellWidget (Layer 1 grid): remove dropTargetTileBuilder (and any drop-target-tile-specific builder) from the list of parameters passed into _DayCellWidget. Continue passing showDropTargetTiles, showDropTargetOverlay, dropTargetTileBuilder only through parents that need them for Layer 3 (e.g. _MonthPageWidget).
  - Purpose: No dead parameter in Layer 1.
  - _Leverage: Current parameter lists in _WeekRowWidget and _DayCellWidget._
  - _Requirements: 8.1, 8.2_
  - _Prompt: Implement the task for spec drag-target-tiles, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter refactoring. Task: Stop passing dropTargetTileBuilder into _DayCellWidget (Layer 1). Remove it from _DayCellWidget's parameters and from the call site in _WeekRowWidget's Layer 1 grid. Keep passing it only through _MonthPageWidget / _WeekRowWidget where Layer 3 will be built. Restrictions: Do not remove from _MonthPageWidget or where Layer 3 is built. _Leverage: mcal_month_view.dart _WeekRowWidget, _DayCellWidget. _Requirements: 8.1, 8.2. Success: Layer 1 does not receive dropTargetTileBuilder. Before implementing: set task [-] in tasks.md. After completing: log-implementation then set [x]._

## Phase 3: Layer 3 implementation

- [x] 7. Phantom segment helper and Layer 3 date label placeholder
  - File: lib/src/widgets/mcal_month_view.dart
  - Add a helper that, given proposedStartDate, proposedEndDate, monthStart, firstDayOfWeek, returns List of List of MCalEventSegment (one synthetic event → MCalMultiDayRenderer.calculateAllEventSegments). Add a builder that returns SizedBox with height config.dateLabelHeight and width matching default date label (e.g. dayWidth - 4) for Layer 3 dateLabelBuilder.
  - Purpose: Supply phantom segments and placeholder for date label area in Layer 3.
  - _Leverage: MCalMultiDayRenderer.calculateAllEventSegments; MCalDefaultWeekLayoutBuilder date label positioning._
  - _Requirements: 2.3, 2.4, Design phantom segments and date label placeholder_
  - _Prompt: Implement the task for spec drag-target-tiles, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Dart layout developer. Task: (1) Implement phantom segment helper: synthetic MCalCalendarEvent(proposedStartDate, proposedEndDate), call calculateAllEventSegments([synthetic], monthStart, firstDayOfWeek), return result. (2) Implement Layer 3 date label placeholder builder returning SizedBox(height: config.dateLabelHeight, width: dayWidth - 4 or same as default layout). Restrictions: Reuse MCalMultiDayRenderer; do not change Layer 2. _Leverage: mcal_multi_day_renderer.dart, mcal_default_week_layout.dart date label width. _Requirements: 2.3, 2.4. Success: Helper returns correct segments; placeholder has correct dimensions. Before implementing: set task [-] in tasks.md. After completing: log-implementation then set [x]._

- [x] 8. Drop-target tile builder wrapper and default tile
  - File: lib/src/widgets/mcal_month_view.dart
  - Implement _buildDropTargetTileBuilderForLayer3: returns MCalEventTileBuilder that, given (context, tileContext), builds MCalEventTileContext with event = dragHandler.draggedEvent, segment/displayDate/width/height from tileContext, isDropTargetPreview=true, dropValid, proposedStartDate, proposedEndDate from handler; then calls dropTargetTileBuilder(context, newContext) if non-null, else _buildDefaultDropTargetTile. Implement _buildDefaultDropTargetTile: same shape as default event tile, no text; resolve style from dropTargetTile* then eventTile* then event.color/fallback.
  - Purpose: Wire dropTargetTileBuilder and default tile for Layer 3.
  - _Leverage: Default event tile styling in _buildDefaultEventTile; MCalEventTileContext; theme dropTargetTile*._
  - _Requirements: 4.1, 4.2, 5.5, 5.6, 7.1_
  - _Prompt: Implement the task for spec drag-target-tiles, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter widget developer. Task: Add _buildDropTargetTileBuilderForLayer3 returning an MCalEventTileBuilder that builds MCalEventTileContext with dragged event and drop-only fields from dragHandler, then calls dropTargetTileBuilder or _buildDefaultDropTargetTile. Add _buildDefaultDropTargetTile using dropTargetTile* then eventTile* then event.color for style; no text. Restrictions: Use existing theme and context; do not add new public types. _Leverage: _buildDefaultEventTile, mcal_theme dropTargetTile*, MCalDragHandler. _Requirements: 4.1, 4.2, 5.5, 5.6, 7.1. Success: Builder and default tile compile and are used from Layer 3. Before implementing: set task [-] in tasks.md. After completing: log-implementation then set [x]._

- [x] 9. Build Layer 3 widget and integrate into Stack; gate Layer 4
  - File: lib/src/widgets/mcal_month_view.dart
  - In _MonthPageWidget: (1) Add Layer 3 as Positioned.fill between weekRowsColumn and the overlay: when showDropTargetTiles && _isDragActive, build a widget that replicates the per-week-row Row structure (week number spacer when showWeekNumbers, same width/side as Layer 2 including RTL, then Expanded with week layout builder output). Use phantom segments per week, same config/dates/columnWidths/rowHeight as Layer 2, eventTileBuilder = drop-target wrapper, dateLabelBuilder = placeholder, overflowIndicatorBuilder = no-op. Wrap Layer 3 in IgnorePointer. (2) Gate Layer 4: only build the highlight overlay when showDropTargetOverlay && _isDragActive. Optionally rename _buildLayer3HighlightOverlay to _buildLayer4HighlightOverlay.
  - Purpose: Layer 3 visible and aligned; Layer 4 optional.
  - _Leverage: _WeekRowWidget Row structure (week number + Expanded); MCalDefaultWeekLayoutBuilder or weekLayoutBuilder; phantom segment helper; drop-target eventTileBuilder wrapper._
  - _Requirements: 1.1, 1.2, 2.1, 2.2, 2.9, 3.3, 3.4, Design Layer 3 alignment (Row structure)_
  - _Prompt: Implement the task for spec drag-target-tiles, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter layout engineer. Task: In _MonthPageWidget builder: (1) Insert Layer 3 between weekRowsColumn and overlay. Layer 3 = Positioned.fill + IgnorePointer, when showDropTargetTiles && _isDragActive. Content = column of rows, each row = same Row as _WeekRowWidget (week number spacer when showWeekNumbers, then Expanded with week layout builder). Use phantom segments per week, same config as Layer 2, drop-target eventTileBuilder, date label placeholder, no-op overflow. (2) Build Layer 4 overlay only when showDropTargetOverlay && _isDragActive. Restrictions: Reuse week layout builder; replicate Row for pixel-perfect alignment. _Leverage: _WeekRowWidget build, phantom helper, task 7–8. _Requirements: 1.1, 1.2, 2.1, 2.2, 2.9, 3.3, 3.4. Success: Layer 3 and 4 render correctly and are gated. Before implementing: set task [-] in tasks.md. After completing: log-implementation then set [x]._

## Phase 4: Example, tests, documentation

- [x] 10. Update example app for dropTargetTileBuilder and new params
  - File: example/lib/views/month_view/styles/features_demo_style.dart (and any other example usages)
  - Update dragTargetTileBuilder to dropTargetTileBuilder with signature (BuildContext, MCalEventTileContext) → Widget. Use context.isDropTargetPreview / context.dropValid for styling. Add toggles or demo for showDropTargetTiles and showDropTargetOverlay if appropriate.
  - Purpose: Demonstrate new API.
  - _Leverage: Existing example eventTileBuilder and toggle patterns._
  - _Requirements: 5.6, 7.2_
  - _Prompt: Implement the task for spec drag-target-tiles, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Example app developer. Task: Update example to use dropTargetTileBuilder (MCalEventTileBuilder) with MCalEventTileContext; check isDropTargetPreview and dropValid. Optionally expose showDropTargetTiles / showDropTargetOverlay. Restrictions: Do not break existing example flows. _Leverage: features_demo_style.dart. _Requirements: 5.6, 7.2. Success: Example compiles and demonstrates drop target tiles. Before implementing: set task [-] in tasks.md. After completing: log-implementation then set [x]._

- [x] 11. Add tests for Layer 3, Layer 4 gating, and theme
  - Files: test/widgets/mcal_month_view_test.dart, test/styles/mcal_theme_test.dart (or appropriate test files)
  - Add widget tests: Layer 3 visibility when showDropTargetTiles true/false; Layer 4 visibility when showDropTargetOverlay true/false; dropTargetTileBuilder invoked with context having isDropTargetPreview and dropValid; no dropTargetTileBuilder passed to Layer 1. Add theme tests for dropTargetCell* and dropTargetTile* renames and new properties.
  - Purpose: Prevent regressions.
  - _Leverage: Existing mcal_month_view_test and theme test patterns._
  - _Requirements: Design Testing Strategy_
  - _Prompt: Implement the task for spec drag-target-tiles, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Test developer. Task: Add tests for showDropTargetTiles/showDropTargetOverlay gating, Layer 3 visibility, dropTargetTileBuilder context (isDropTargetPreview, dropValid), and theme dropTargetCell* / dropTargetTile*. Restrictions: Use existing test patterns; keep tests maintainable. _Leverage: mcal_month_view_test.dart, mcal_theme_test.dart. _Requirements: Design testing. Success: New tests pass. Before implementing: set task [-] in tasks.md. After completing: log-implementation then set [x]._

- [x] 12. Dartdoc and README updates
  - Files: lib/src/widgets/mcal_month_view.dart, lib/src/widgets/mcal_month_view_contexts.dart, lib/src/styles/mcal_theme.dart, README.md if it documents drag/drop
  - Ensure dartdoc for MCalEventTileContext drop-target fields, dropTargetTileBuilder, showDropTargetTiles, showDropTargetOverlay, and theme dropTargetCell* / dropTargetTile* is clear. Update README if it references drag target builder or theme.
  - Purpose: Clear API documentation.
  - _Leverage: Existing dartdoc style in the package._
  - _Requirements: 5.7, 6.4, 7_
  - _Prompt: Implement the task for spec drag-target-tiles, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Technical writer / API doc. Task: Add or update dartdoc for MCalEventTileContext (drop-target fields), dropTargetTileBuilder, showDropTargetTiles, showDropTargetOverlay, and theme dropTargetCell* / dropTargetTile*. Update README if it mentions drag target or theme. Restrictions: Match existing doc style. _Leverage: Current dartdoc in lib. _Requirements: 5.7, 6.4, 7. Success: Docs are clear and accurate. Before implementing: set task [-] in tasks.md. After completing: log-implementation then set [x]._
