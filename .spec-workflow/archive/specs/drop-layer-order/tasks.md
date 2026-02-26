# Tasks Document: Drop Layer Order

- [x] 1. Rename layer-numbered identifiers
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Rename all private identifiers that embed "Layer3" or "Layer4" to descriptive, number-free names:
    - `_buildLayer3DropTargetTiles` → `_buildDropTargetTilesLayer`
    - `_buildLayer4HighlightOverlay` → `_buildDropTargetOverlayLayer`
    - `_buildDropTargetTileBuilderForLayer3` → `_buildDropTargetTileEventBuilder`
    - `_buildLayer3DateLabelPlaceholder` (top-level function) → `_buildDropTargetDateLabelPlaceholder`
  - Update the stale comment at ~line 3415 referencing `_buildLayer3DropTargets` to use the new naming convention
  - Comments and dartdoc may continue to reference "Layer 3" and "Layer 4" as the conceptual default order
  - All call sites within the file must be updated
  - Purpose: Remove hard-coded layer numbers from identifiers so that the stacking order is a runtime choice, not baked into names
  - _Leverage: `lib/src/widgets/mcal_month_view.dart` (all changes are internal renames within this single file)_
  - _Requirements: 2.1, 2.2, 2.3, 2.4_
  - _Prompt: Implement the task for spec drop-layer-order, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in code refactoring | Task: Rename all private method/function identifiers in `lib/src/widgets/mcal_month_view.dart` that contain "Layer3" or "Layer4" to descriptive, number-free names as specified in spec `.spec-workflow/specs/drop-layer-order/requirements.md` Requirement 2 and design `.spec-workflow/specs/drop-layer-order/design.md`. The renames are: `_buildLayer3DropTargetTiles` → `_buildDropTargetTilesLayer`, `_buildLayer4HighlightOverlay` → `_buildDropTargetOverlayLayer`, `_buildDropTargetTileBuilderForLayer3` → `_buildDropTargetTileEventBuilder`, `_buildLayer3DateLabelPlaceholder` → `_buildDropTargetDateLabelPlaceholder`. Also update the stale comment at ~line 3415 that references `_buildLayer3DropTargets`. Comments and dartdoc referencing "Layer 3"/"Layer 4" as conceptual labels are fine to keep. | Restrictions: Do NOT rename any public API names. Do NOT change any logic, only identifiers and their call sites. Do NOT touch files other than `lib/src/widgets/mcal_month_view.dart`. | Success: All four methods/functions are renamed, all call sites are updated, `dart analyze` reports no errors, all existing month view tests pass. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

- [x] 2. Add `dropTargetTilesAboveOverlay` property to `MCalMonthView` and `_MonthPageWidget`
  - File: `lib/src/widgets/mcal_month_view.dart`
  - Add `final bool dropTargetTilesAboveOverlay;` field to `MCalMonthView` with dartdoc explaining default order and reversed behavior
  - Add `this.dropTargetTilesAboveOverlay = false,` to the `MCalMonthView` constructor (in the drag-and-drop parameter group, after `showDropTargetOverlay`)
  - Add the same field and constructor parameter to `_MonthPageWidget`
  - Pass the value through from `_MCalMonthViewState._buildPageView` → `_MonthPageWidget(...)` constructor call (~line 1179)
  - Purpose: Wire the new boolean from the public API to the internal widget that builds the Stack
  - _Leverage: Follow the exact same pattern used by `showDropTargetTiles` and `showDropTargetOverlay` in the same file_
  - _Requirements: 1.1, 1.4, 1.5_
  - _Prompt: Implement the task for spec drop-layer-order, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in widget API design | Task: Add a new `bool dropTargetTilesAboveOverlay` property (default `false`) to both `MCalMonthView` and `_MonthPageWidget` in `lib/src/widgets/mcal_month_view.dart`, following the spec at `.spec-workflow/specs/drop-layer-order/requirements.md` Requirement 1 and design at `.spec-workflow/specs/drop-layer-order/design.md`. Add dartdoc: "When true, the drop target tiles layer renders above the drop target overlay layer during drag-and-drop. When false (default), tiles render below the overlay. By default, drop target tiles are Layer 3 and the overlay is Layer 4. Setting this to true reverses their order." Add the field and constructor param to both widgets. Pass the value from `_MCalMonthViewState._buildPageView` to the `_MonthPageWidget` constructor, right after `showDropTargetOverlay`. | Restrictions: Do NOT change any rendering logic in this task — that is Task 3. Only add the field, constructor param, dartdoc, and pass-through. Do NOT touch files other than `lib/src/widgets/mcal_month_view.dart`. | Success: Both widgets have the new property, the value is threaded through, `dart analyze` reports no errors, all existing tests pass. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

- [x] 3. Use `dropTargetTilesAboveOverlay` to control Stack children order
  - File: `lib/src/widgets/mcal_month_view.dart`
  - In `_MonthPageWidgetState.build()` (the `DragTarget` builder block, ~lines 2860-2885), refactor the Stack children to use the boolean:
    - Build both layer widgets into local variables (`tilesLayer`, `overlayLayer`) as nullable `Widget?`
    - Determine insertion order: when `dropTargetTilesAboveOverlay` is false (default), tiles first then overlay; when true, overlay first then tiles
    - Add both (if non-null) to the Stack children list after `weekRowsColumn`
  - Update comments in the Stack to reflect the dynamic ordering
  - Purpose: Implement the core feature — the rendering order of the two drop layers is now controlled by the boolean
  - _Leverage: The design doc `.spec-workflow/specs/drop-layer-order/design.md` contains the exact implementation approach with code snippet. Use the renamed methods from Task 1 (`_buildDropTargetTilesLayer`, `_buildDropTargetOverlayLayer`)._
  - _Requirements: 1.2, 1.3, 1.4_
  - _Prompt: Implement the task for spec drop-layer-order, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in widget composition and Stack layout | Task: Refactor the Stack children in `_MonthPageWidgetState.build()` in `lib/src/widgets/mcal_month_view.dart` to use `widget.dropTargetTilesAboveOverlay` to control the order of the drop target tiles layer and the drop target overlay layer, following the design at `.spec-workflow/specs/drop-layer-order/design.md`. Build both layers into nullable local variables (`tilesLayer` and `overlayLayer`). Use `widget.dropTargetTilesAboveOverlay` to determine which is `first` and which is `second`. Add both (if non-null) to the Stack children. The methods to call are `_buildDropTargetTilesLayer(context)` and `_buildDropTargetOverlayLayer(context)` (renamed in Task 1). Update comments to reflect the dynamic ordering. | Restrictions: Do NOT change any logic inside the layer builder methods themselves. Do NOT change any other part of the build method. Do NOT touch files other than `lib/src/widgets/mcal_month_view.dart`. | Success: When `dropTargetTilesAboveOverlay` is false, the Stack order matches current behavior (tiles below overlay). When true, the order is reversed (tiles above overlay). `dart analyze` reports no errors, all existing tests pass. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

- [x] 4. Verify all existing tests pass and run analyzer
  - File: `test/widgets/mcal_month_view_test.dart` (read-only verification)
  - Run `dart analyze lib/src/widgets/mcal_month_view.dart` to verify no analysis errors
  - Run the full month view test suite to verify all 121+ existing tests pass with no changes
  - Purpose: Confirm that the default behavior is preserved and renames did not break anything
  - _Leverage: Existing test suite at `test/widgets/mcal_month_view_test.dart`_
  - _Requirements: 1.4 (no visible effect when not set), 2.3 (all call sites updated)_
  - _Prompt: Implement the task for spec drop-layer-order, first run spec-workflow-guide to get the workflow guide then implement the task: Role: QA Engineer specializing in Flutter testing | Task: Verify that all changes from Tasks 1-3 in spec drop-layer-order are correct by running `dart analyze` on `lib/src/widgets/mcal_month_view.dart` and running the full month view test suite. Check spec requirements at `.spec-workflow/specs/drop-layer-order/requirements.md` and design at `.spec-workflow/specs/drop-layer-order/design.md`. | Restrictions: Do NOT modify any source files. This is a verification-only task. If tests or analyzer fail, report the failures but do NOT fix them (that would be a separate task). | Success: `dart analyze` reports no errors for the file, and all existing month view tests pass (121+ tests). Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._

- [x] 5. Expose `dropTargetTilesAboveOverlay` as a toggle in the example app Features demo
  - File: `example/lib/views/month_view/styles/features_demo_style.dart`
  - Add a `bool _dropTargetTilesAboveOverlay = false;` state variable in the Feature Toggles section
  - Add a toggle in the desktop control panel (`_buildControlPanel`) after the "Custom drag target tile" toggle, labeled "Tiles above overlay"
  - Add a compact toggle in the mobile control panel (`_buildMobileControlPanel`) after the "Drop overlay" toggle, labeled "Tiles above"
  - Pass `dropTargetTilesAboveOverlay: _dropTargetTilesAboveOverlay` to both `MCalMonthView` instances (primary calendar in `_buildPrimaryCalendar` and mobile layout in `_buildMobileLayout`), after `showDropTargetOverlay`
  - Purpose: Allow interactive testing of the new property in the example app
  - _Leverage: Follow the exact same toggle pattern used by `_showDropTargetTiles` and `_showDropTargetOverlay` in the same file_
  - _Requirements: 1.1_
  - _Prompt: Implement the task for spec drop-layer-order, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Add a toggle for `dropTargetTilesAboveOverlay` in the Features demo example app at `example/lib/views/month_view/styles/features_demo_style.dart`. Add state variable, desktop toggle, mobile toggle, and pass to both MCalMonthView instances. Follow the pattern of existing toggles like `_showDropTargetTiles`. | Success: The toggle appears in both desktop and mobile control panels, and toggling it changes the `dropTargetTilesAboveOverlay` value on the calendar. Mark task as [-] in tasks.md before starting, log implementation with log-implementation tool after completion, then mark as [x]._
