# Tasks Document: Unified Drag Target Architecture

## Phase 1: Data Models and Details Classes

- [x] 1. Create MCalHighlightCellInfo data class
  - File: lib/src/widgets/mcal_callback_details.dart
  - Add data class for individual highlighted cell information
  - Include: date, cellIndex, weekRowIndex, bounds, isFirst, isLast
  - Purpose: Represent a single cell to highlight during drag-and-drop
  - _Leverage: Existing pattern from MCalDragData in same file_
  - _Requirements: 5.3, 5.4_

- [x] 2. Create MCalDropOverlayDetails class
  - File: lib/src/widgets/mcal_callback_details.dart
  - Add details class for dropTargetOverlayBuilder callback
  - Include: highlightedCells list, isValid, dayWidth, calendarSize, dragData
  - Purpose: Provide full overlay context for advanced customization
  - _Leverage: Existing pattern from MCalDragWillAcceptDetails_
  - _Requirements: 5.2, 5.3_

- [x] 3. Create MCalDropTargetCellDetails class
  - File: lib/src/widgets/mcal_callback_details.dart
  - Add details class for dropTargetCellBuilder callback
  - Include: date, bounds, isValid, isFirst, isLast, cellIndex, weekRowIndex
  - Purpose: Provide per-cell context for simpler customization
  - _Leverage: Existing pattern from MCalCellTapDetails_
  - _Requirements: 5.4_

## Phase 2: Extend MCalDragHandler

- [x] 4. Add debounce state fields to MCalDragHandler
  - File: lib/src/widgets/mcal_drag_handler.dart
  - Add: _debounceTimer, _latestPosition, _debounceDuration constant
  - Add: _previousStartCellIndex, _previousEndCellIndex, _previousWeekRowIndex for change detection
  - Purpose: Support debounced position updates with change detection
  - _Leverage: Existing Timer pattern from _edgeNavigationTimer_
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 5. Add highlightedCells state to MCalDragHandler
  - File: lib/src/widgets/mcal_drag_handler.dart
  - Add: _highlightedCells list and public getter
  - Add: method to build cell info list from proposed date range
  - Purpose: Provide computed cell list for overlay rendering
  - _Leverage: Existing proposedStartDate/proposedEndDate fields_
  - _Requirements: 5.1_

- [x] 6. Implement handleDragMove method in MCalDragHandler
  - File: lib/src/widgets/mcal_drag_handler.dart
  - Create handleDragMove method that receives raw position data
  - Implement 16ms debounce timer logic (latest-position-wins)
  - Call internal _processPositionUpdate when timer fires
  - Purpose: Central entry point for onMove position tracking
  - _Leverage: Existing handleEdgeProximity pattern_
  - _Requirements: 1.2, 3.1, 3.2_

- [x] 7. Implement cell detection and change detection in MCalDragHandler
  - File: lib/src/widgets/mcal_drag_handler.dart
  - Implement _processPositionUpdate method
  - Calculate target cells: floor((pointerLocalX - grabOffsetX - horizontalSpacing) / dayWidth)
  - Compare with previous target cells, skip update if unchanged
  - Call validation callback if provided, update state if changed
  - Purpose: Mathematical cell detection with performance optimization
  - _Leverage: Existing updateProposedDropRange pattern_
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.3, 3.4, 3.5, 4.1, 4.2, 4.3_

- [x] 8. Add cleanup methods to MCalDragHandler
  - File: lib/src/widgets/mcal_drag_handler.dart
  - Add method to cancel debounce timer
  - Update _reset and dispose to cancel debounce timer
  - Add clearHighlightedCells method for onLeave handling
  - Purpose: Proper resource cleanup in all scenarios
  - _Leverage: Existing _cancelEdgeNavigationTimer pattern_
  - _Requirements: 8.1, 8.2, 8.3, 8.4_

## Phase 3: Create Default Highlight Painter

- [x] 9. Create DropTargetHighlightPainter class
  - File: lib/src/widgets/mcal_month_view.dart (private class)
  - Implement CustomPainter for efficient highlight rendering
  - Draw colored rounded rectangles for each highlighted cell
  - Implement shouldRepaint for efficient repainting
  - Purpose: Default performant highlight rendering
  - _Leverage: Flutter CustomPainter pattern_
  - _Requirements: 5.5_

## Phase 4: Refactor MonthPageWidget

- [x] 10. Add unified DragTarget wrapper to MonthPageWidget
  - File: lib/src/widgets/mcal_month_view.dart
  - Wrap Stack in single DragTarget widget
  - Add onMove, onLeave, onAcceptWithDetails handlers
  - Store calendar size and week row bounds for position calculations
  - Purpose: Single entry point for all drag events
  - _Leverage: Existing DragTarget pattern in _buildLayer3DropTargets_
  - _Requirements: 1.1, 1.2, 1.3_

- [x] 11. Implement _handleDragMove in MonthPageWidget
  - File: lib/src/widgets/mcal_month_view.dart
  - Convert details.offset to pointer position (add grabOffsetX)
  - Call dragHandler.handleDragMove with all required parameters
  - Handle edge proximity for month navigation
  - Purpose: Bridge between DragTarget and MCalDragHandler
  - _Leverage: Existing onWillAcceptWithDetails logic_
  - _Requirements: 1.2, 7.1, 7.2, 7.3, 7.4_

- [x] 12. Implement _handleDragLeave in MonthPageWidget
  - File: lib/src/widgets/mcal_month_view.dart
  - Clear highlight state via dragHandler
  - Cancel any pending debounce timers
  - Purpose: Clean up when drag leaves calendar area
  - _Leverage: Existing onLeave pattern_
  - _Requirements: 8.1_

- [x] 13. Update _handleDrop (onAcceptWithDetails) in MonthPageWidget
  - File: lib/src/widgets/mcal_month_view.dart
  - Check isProposedDropValid, return early if false
  - Use proposedStartDate/proposedEndDate for drop location
  - Clean up all drag state after drop
  - Purpose: Ensure drop matches visual feedback, handle invalid drops
  - _Leverage: Existing onAcceptWithDetails logic_
  - _Requirements: 6.1, 6.2, 6.3, 6.4_

## Phase 5: Implement Highlight Overlay Layer

- [x] 14. Create _buildLayer3HighlightOverlay method
  - File: lib/src/widgets/mcal_month_view.dart
  - Implement builder precedence: overlayBuilder > cellBuilder > default
  - Wrap in IgnorePointer for pass-through
  - Only render when drag is active
  - Purpose: Flexible highlight overlay with customization support
  - _Leverage: Existing _buildLayer3DropTargets structure_
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_

- [x] 15. Add dropTargetOverlayBuilder parameter to MCalMonthView
  - File: lib/src/widgets/mcal_month_view.dart
  - Add optional builder parameter with MCalDropOverlayDetails signature
  - Pass through to MonthPageWidget
  - Document in class dartdoc
  - Purpose: Enable advanced overlay customization
  - _Leverage: Existing builder parameter patterns_
  - _Requirements: 5.2, 5.3_

- [x] 16. Update dropTargetCellBuilder parameter signature
  - File: lib/src/widgets/mcal_month_view.dart
  - Update signature to use MCalDropTargetCellDetails
  - Update any existing usages in example app
  - Document breaking change
  - Purpose: Enhanced per-cell customization with position flags
  - _Leverage: Existing dropTargetCellBuilder_
  - _Requirements: 5.4_

## Phase 6: Remove Old Per-Cell DragTargets

- [x] 17. Remove per-cell DragTargets from WeekRowWidget
  - File: lib/src/widgets/mcal_month_view.dart
  - Remove _buildLayer3DropTargets method from WeekRowWidget
  - Remove _hoveredDropTarget state
  - Remove _shouldHighlightCell method
  - Purpose: Clean up old implementation
  - _Leverage: N/A (removal task)_
  - _Requirements: 1.1_

- [x] 18. Update WeekRowWidget build method
  - File: lib/src/widgets/mcal_month_view.dart
  - Remove Layer 3 from week row Stack
  - Simplify to only Layer 1 (grid) and Layer 2 (events)
  - Purpose: WeekRowWidget now only handles grid and events
  - _Leverage: Existing build structure_
  - _Requirements: 1.1_

## Phase 7: Testing

- [x] 19. Add unit tests for MCalDragHandler debouncing
  - File: test/widgets/mcal_drag_handler_test.dart
  - Test debounce timer behavior
  - Test latest-position-wins semantics
  - Test change detection (no update when same cell)
  - Purpose: Verify debounce and change detection logic
  - _Leverage: Existing test patterns_
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 20. Add unit tests for cell detection math
  - File: test/widgets/mcal_drag_handler_test.dart
  - Test calculation: floor((pointerLocalX - grabOffsetX - horizontalSpacing) / dayWidth)
  - Test edge cases: negative indices, beyond week bounds
  - Test multi-day event spanning multiple weeks
  - Purpose: Verify mathematical cell detection accuracy
  - _Leverage: Existing test patterns_
  - _Requirements: 2.1, 2.2, 2.3_

- [x] 21. Add widget tests for unified DragTarget
  - File: test/widgets/mcal_month_view_test.dart
  - Test onMove receives correct data
  - Test builder precedence (overlay > cell > default)
  - Test drop matches highlighted position
  - Purpose: Verify widget integration
  - _Leverage: Existing mcal_month_view_test.dart patterns_
  - _Requirements: 1.1, 1.2, 5.2, 6.2_

- [x] 22. Update existing drag-and-drop tests
  - File: test/widgets/mcal_month_view_test.dart
  - Update tests to work with new unified DragTarget
  - Remove tests for per-cell DragTarget behavior
  - Add tests for invalid drop handling
  - Purpose: Maintain test coverage after refactor
  - _Leverage: Existing test structure_
  - _Requirements: 6.3, 8.1, 8.2, 8.3_

## Phase 8: Documentation and Example

- [x] 23. Update example app to use new builders
  - File: example/lib/views/month_view/styles/features_demo_style.dart
  - Update dropTargetCellBuilder usage if present
  - Add example of dropTargetOverlayBuilder usage
  - Purpose: Demonstrate new API usage
  - _Leverage: Existing example patterns_
  - _Requirements: 5.2, 5.4_

- [x] 24. Add dartdoc for new public APIs
  - Files: mcal_callback_details.dart, mcal_month_view.dart
  - Document MCalHighlightCellInfo, MCalDropOverlayDetails, MCalDropTargetCellDetails
  - Document dropTargetOverlayBuilder parameter
  - Document builder precedence
  - Purpose: Complete API documentation
  - _Leverage: Existing dartdoc patterns_
  - _Requirements: NFR - Clear Interfaces_

## Phase 9: Post-Implementation Improvements

- [x] 25. Fix drop handling race condition
  - File: lib/src/widgets/mcal_month_view.dart
  - Issue: `onPointerUp` listener was calling `_handleDragEnded(false)` before the drop handler
  - Fix: Removed `onPointerUp` handler; `LongPressDraggable.onDragEnd` handles cleanup correctly
  - Simplified `_handleDragEnded`: if `wasAccepted=true`, drop handler already cleaned up; only cleanup on `wasAccepted=false`
  - Purpose: Ensure drop handler has valid state when processing drops

- [x] 26. Optimize drag move debouncing
  - File: lib/src/widgets/mcal_month_view.dart
  - Added proper debounce in `_handleDragMove`: stores latest details, starts 16ms timer
  - Created `_processDragMove` method containing all expensive calculations
  - Ensures expensive work runs at most once per 16ms (~60fps)
  - Purpose: Reduce CPU usage during drag operations

- [x] 27. Cache layout at drag start
  - File: lib/src/widgets/mcal_month_view.dart
  - Added `_layoutCachedForDrag` flag
  - `findRenderObject()` and `_updateLayoutCache()` now only called once per drag operation
  - Reset flag when new drag starts (different `_cachedDragData`)
  - Purpose: Eliminate redundant layout calculations during drag

- [x] 28. Remove redundant second debounce
  - File: lib/src/widgets/mcal_drag_handler.dart
  - `handleDragMove` now calls `_processPositionUpdate()` immediately (no internal debounce)
  - Removed unused `_debounceDuration` constant
  - Removed `flushPendingUpdate()` method (no longer needed)
  - Purpose: Reduce latency from 32ms (two debounces) to 16ms (one debounce)

- [x] 29. Fix double-subtraction of horizontalSpacing
  - File: lib/src/widgets/mcal_drag_handler.dart
  - Issue: `horizontalSpacing` was subtracted twice (once in `grabOffsetX`, once in drop calculation)
  - Fix: Removed `_cachedHorizontalSpacing` from drop calculation
  - Removed `horizontalSpacing` parameter from `handleDragMove`
  - Purpose: Correct drop position calculation for all layouts

- [x] 30. Add center-weighted drop target calculation
  - File: lib/src/widgets/mcal_drag_handler.dart
  - Changed: `dropStartCellIndex = floor((localX - grabOffsetX + dayWidth/2) / dayWidth)`
  - Drop target is now the cell containing >50% of the first day of the dragged tile
  - Purpose: More intuitive drop behavior - tile "snaps" to cell with majority of first day

- [x] 31. Make dragTargetBorderRadius themeable
  - File: lib/src/styles/mcal_theme.dart
  - Added `dragTargetBorderRadius` field to MCalTheme
  - Default value: 4.0 (in `defaultLight` factory)
  - Added to `copyWith` and `lerp` methods
  - Updated `_DropTargetHighlightPainter` to use theme value
  - Purpose: Allow customization of drop target highlight corner radius
