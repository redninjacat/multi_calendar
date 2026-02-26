# Tasks Document

## Phase 1: Theme System & InheritedWidget

- [x] 1. Create MCalTheme InheritedWidget
  - File: lib/src/styles/mcal_theme.dart
  - Add `MCalTheme` InheritedWidget class wrapping `MCalThemeData`
  - Implement `MCalTheme.of(context)` with fallback chain: InheritedWidget → ThemeExtension → fromTheme()
  - Implement `MCalTheme.maybeOf(context)` returning nullable without fallback
  - Export from multi_calendar.dart
  - Purpose: Enable theme access via context without passing through widget tree
  - _Leverage: lib/src/styles/mcal_theme.dart existing MCalThemeData_
  - _Requirements: 1.4, 1.5, 1.6_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in InheritedWidget patterns | Task: Create MCalTheme InheritedWidget in mcal_theme.dart with of(context) and maybeOf(context) static methods, implementing fallback chain to ThemeExtension then MCalThemeData.fromTheme() | Restrictions: Do not modify MCalThemeData class structure, ensure updateShouldNotify is implemented correctly | _Leverage: lib/src/styles/mcal_theme.dart | _Requirements: 1.4, 1.5, 1.6 | Success: MCalTheme.of(context) returns correct theme with proper fallback chain, maybeOf returns null when no theme available | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 2. Write unit tests for MCalTheme
  - File: test/styles/mcal_theme_test.dart
  - Test MCalTheme.of() with MCalTheme ancestor
  - Test MCalTheme.of() fallback to ThemeExtension
  - Test MCalTheme.of() fallback to fromTheme()
  - Test MCalTheme.maybeOf() returning null
  - Test updateShouldNotify behavior
  - Purpose: Ensure theme inheritance chain works correctly
  - _Leverage: test/styles/mcal_theme_test.dart existing patterns_
  - _Requirements: 1.4, 1.5, 1.6_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Test Engineer | Task: Add unit tests for MCalTheme InheritedWidget covering of(), maybeOf(), and all fallback scenarios | Restrictions: Follow existing test patterns, test each fallback level independently | _Leverage: test/styles/mcal_theme_test.dart | _Requirements: 1.4, 1.5, 1.6 | Success: All fallback scenarios tested, updateShouldNotify behavior verified | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

## Phase 2: Callback API Standardization

- [x] 3. Create callback details classes
  - File: lib/src/widgets/mcal_callback_details.dart (new file)
  - Create MCalCellTapDetails class (date, events, isCurrentMonth)
  - Create MCalEventTapDetails class (event, displayDate)
  - Create MCalSwipeNavigationDetails class (previousMonth, newMonth, direction)
  - Create MCalOverflowTapDetails class (date, allEvents, hiddenCount)
  - Create MCalCellInteractivityDetails class (date, isCurrentMonth, isSelectable)
  - Create MCalErrorDetails class (error, onRetry)
  - Export from multi_calendar.dart
  - Purpose: Standardized details objects for all callbacks
  - _Leverage: lib/src/widgets/mcal_month_view_contexts.dart patterns_
  - _Requirements: 1.1, 1.2, 1.3, 1.7-1.15_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Create new file mcal_callback_details.dart with all details classes per the design document, following existing context class patterns | Restrictions: All classes must be immutable with const constructors, do not include theme property | _Leverage: lib/src/widgets/mcal_month_view_contexts.dart | _Requirements: 1.1, 1.2, 1.3, 1.7-1.15 | Success: All 6 details classes created with proper documentation | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 4. Update existing context classes to remove theme
  - File: lib/src/widgets/mcal_month_view_contexts.dart
  - Remove `theme` property from MCalDayCellContext
  - Remove `theme` property from MCalEventTileContext
  - Remove `theme` property from MCalDayHeaderContext
  - Remove `theme` property from MCalWeekNumberContext
  - Update constructors and documentation
  - Purpose: Theme now accessed via MCalTheme.of(context)
  - _Leverage: lib/src/widgets/mcal_month_view_contexts.dart_
  - _Requirements: 1.16_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Remove theme property from all existing context classes in mcal_month_view_contexts.dart, update constructors | Restrictions: Maintain all other properties, update documentation to reference MCalTheme.of(context) | _Leverage: lib/src/widgets/mcal_month_view_contexts.dart | _Requirements: 1.16 | Success: All context classes updated, no theme property, docs updated | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 5. Migrate existing callbacks to new signatures
  - File: lib/src/widgets/mcal_month_view.dart
  - Update onCellTap signature: `void Function(BuildContext, MCalCellTapDetails)?`
  - Update onCellLongPress signature: `void Function(BuildContext, MCalCellTapDetails)?`
  - Update onEventTap signature: `void Function(BuildContext, MCalEventTapDetails)?`
  - Update onEventLongPress signature: `void Function(BuildContext, MCalEventTapDetails)?`
  - Update onSwipeNavigation signature: `void Function(BuildContext, MCalSwipeNavigationDetails)?`
  - Update onOverflowTap signature: `void Function(BuildContext, MCalOverflowTapDetails)?`
  - Update onOverflowLongPress signature: `void Function(BuildContext, MCalOverflowTapDetails)?`
  - Update cellInteractivityCallback signature: `bool Function(BuildContext, MCalCellInteractivityDetails)?`
  - Update errorBuilder signature: `Widget Function(BuildContext, MCalErrorDetails)?`
  - Update all call sites to create and pass details objects
  - Update all internal widgets that use theme to use MCalTheme.of(context)
  - Purpose: Standardize all callbacks to (BuildContext, Details) pattern
  - _Leverage: lib/src/widgets/mcal_month_view.dart, lib/src/widgets/mcal_callback_details.dart_
  - _Requirements: 1.7-1.15_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Migrate all existing callbacks in MCalMonthView to new (BuildContext, Details) signatures, update all call sites to create details objects, update internal widgets to use MCalTheme.of(context) | Restrictions: Ensure all callback invocations pass BuildContext and correct details object, test that existing functionality still works | _Leverage: lib/src/widgets/mcal_month_view.dart, lib/src/widgets/mcal_callback_details.dart | _Requirements: 1.7-1.15 | Success: All callbacks use new signatures, all call sites updated, widget compiles without errors | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 6. Write tests for callback API changes
  - File: test/widgets/mcal_month_view_test.dart
  - Test onCellTap receives correct MCalCellTapDetails
  - Test onEventTap receives correct MCalEventTapDetails
  - Test onSwipeNavigation receives correct MCalSwipeNavigationDetails
  - Test onOverflowTap receives correct MCalOverflowTapDetails
  - Test cellInteractivityCallback receives correct details
  - Test errorBuilder receives correct MCalErrorDetails
  - Test MCalTheme.of(context) access from within builders
  - Purpose: Verify callback migration works correctly
  - _Leverage: test/widgets/mcal_month_view_test.dart existing patterns_
  - _Requirements: 1.7-1.15_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Test Engineer | Task: Add/update widget tests to verify all migrated callbacks receive correct details objects and BuildContext | Restrictions: Test each callback type, verify details object properties are populated correctly | _Leverage: test/widgets/mcal_month_view_test.dart | _Requirements: 1.7-1.15 | Success: All callbacks tested with correct details, MCalTheme.of access verified | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

## Phase 3: Animation & PageView Navigation

- [x] 7. Add animation support to MCalEventController
  - File: lib/src/controllers/mcal_event_controller.dart
  - Add `_animateNextChange` private field (bool, default true)
  - Add `shouldAnimateNextChange` getter
  - Add `consumeAnimationFlag()` method to reset flag after use
  - Update `setDisplayDate()` to accept optional `animate` parameter
  - Add `navigateToDateWithoutAnimation()` convenience method
  - Purpose: Allow programmatic control over navigation animation
  - _Leverage: lib/src/controllers/mcal_event_controller.dart_
  - _Requirements: 3.5, 3.6_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Add animation control to MCalEventController with animate parameter on setDisplayDate() and navigateToDateWithoutAnimation() method | Restrictions: Default behavior should remain animated, flag must be consumable | _Leverage: lib/src/controllers/mcal_event_controller.dart | _Requirements: 3.5, 3.6 | Success: Controller supports animate:false parameter, views can check shouldAnimateNextChange | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 8. Refactor MCalMonthView to use PageView
  - File: lib/src/widgets/mcal_month_view.dart
  - Add PageController with initial index (10000 for "infinite" scrolling)
  - Replace AnimatedSwitcher with PageView.builder
  - Implement _pageIndexToMonth() and _monthToPageIndex() conversion methods
  - Extract month grid to _MonthPage widget for PageView itemBuilder
  - Implement _onPageChanged() to update controller and fire callbacks
  - Update _navigateToMonth() to use PageController.animateToPage/jumpToPage
  - Consume controller's shouldAnimateNextChange flag
  - Wrap content in MCalTheme InheritedWidget
  - Purpose: Enable PageView-style swipe navigation with peek preview
  - _Leverage: lib/src/widgets/mcal_month_view.dart, Flutter PageView_
  - _Requirements: 2.1-2.11, 3.1-3.4, 3.7-3.10_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer with animation expertise | Task: Refactor MCalMonthView to use PageView.builder instead of AnimatedSwitcher, implementing infinite scrolling pattern with index offset, consuming controller animation flag | Restrictions: Maintain all existing functionality, ensure smooth 60fps animations, handle physics based on enableSwipeNavigation | _Leverage: lib/src/widgets/mcal_month_view.dart | _Requirements: 2.1-2.11, 3.1-3.4, 3.7-3.10 | Success: Swipe navigation works with peek preview, all navigation methods animate correctly, no visual glitches | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 9. Implement swipe boundary handling
  - File: lib/src/widgets/mcal_month_view.dart
  - Add boundary detection in PageView physics
  - Implement bounce-back behavior at minDate/maxDate boundaries
  - Prevent page changes beyond boundaries
  - Purpose: Respect minDate/maxDate restrictions during swipe
  - _Leverage: lib/src/widgets/mcal_month_view.dart, Flutter ClampingScrollPhysics_
  - _Requirements: 2.9, 2.10_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Implement boundary handling for PageView swipe navigation, preventing navigation beyond minDate/maxDate with visual bounce-back feedback | Restrictions: Allow visual overscroll but snap back, don't allow page changes at boundaries | _Leverage: lib/src/widgets/mcal_month_view.dart | _Requirements: 2.9, 2.10 | Success: Swipe at boundaries shows bounce-back, cannot navigate past min/max dates | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 10. Write tests for animation and navigation
  - File: test/widgets/mcal_month_view_test.dart
  - Test PageView swipe navigation
  - Test swipe callback fires with correct details
  - Test boundary behavior at minDate/maxDate
  - Test programmatic navigation with animate:true/false
  - Test controller.navigateToDateWithoutAnimation()
  - Test animation interruption on rapid navigation
  - File: test/controllers/mcal_event_controller_test.dart
  - Test setDisplayDate with animate parameter
  - Test shouldAnimateNextChange flag behavior
  - Test consumeAnimationFlag() resets to true
  - Purpose: Verify PageView navigation and animation control
  - _Leverage: test/widgets/mcal_month_view_test.dart, test/controllers/mcal_event_controller_test.dart_
  - _Requirements: 2.1-2.11, 3.1-3.10_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Test Engineer | Task: Add tests for PageView navigation, swipe gestures, boundary handling, and controller animation flag | Restrictions: Test both animated and instant navigation, verify callback details | _Leverage: test/widgets/mcal_month_view_test.dart, test/controllers/mcal_event_controller_test.dart | _Requirements: 2.1-2.11, 3.1-3.10 | Success: All navigation scenarios tested, animation control verified | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

## Phase 4: Multi-Day Event Rendering

- [x] 11. Create MCalMultiDayRenderer utility
  - File: lib/src/widgets/mcal_multi_day_renderer.dart (new file)
  - Create MCalMultiDayEventLayout class (event, rowSegments)
  - Create MCalMultiDayRowSegment class (weekRowIndex, startDayInRow, endDayInRow, flags)
  - Implement _isMultiDay() helper to check if event spans multiple days
  - Implement _multiDayEventComparator() for sorting (all-day multi → timed multi → all-day single → timed single)
  - Implement calculateLayouts() to compute row segments for all multi-day events
  - Purpose: Calculate layout information for contiguous multi-day tiles
  - _Leverage: lib/src/utils/date_utils.dart_
  - _Requirements: 4.5, 4.6_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Create MCalMultiDayRenderer utility class with layout calculation for multi-day events spanning week rows | Restrictions: Handle events spanning multiple weeks correctly, calculate row segment indices accurately | _Leverage: lib/src/utils/date_utils.dart | _Requirements: 4.5, 4.6 | Success: Layout calculations handle all edge cases (week wrap, month boundaries) | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 12. Create multi-day tile details class
  - File: lib/src/widgets/mcal_callback_details.dart
  - Add MCalMultiDayTileDetails class with all properties per design
  - Purpose: Context for multi-day event tile builder
  - _Leverage: lib/src/widgets/mcal_callback_details.dart_
  - _Requirements: 4.8_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Add MCalMultiDayTileDetails class to mcal_callback_details.dart with all properties specified in design | Restrictions: Follow existing details class patterns, immutable with const constructor | _Leverage: lib/src/widgets/mcal_callback_details.dart | _Requirements: 4.8 | Success: MCalMultiDayTileDetails class created with all 12 properties | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 13. Create MCalMultiDayTile widget
  - File: lib/src/widgets/mcal_multi_day_tile.dart (new file)
  - Create widget that renders contiguous multi-day event tile
  - Implement smart border radius calculation based on row position
  - Support multiDayEventTileBuilder callback
  - Implement tap/long-press with MCalEventTapDetails
  - Purpose: Render individual multi-day event tile segment
  - _Leverage: lib/src/widgets/mcal_month_view.dart _EventTileWidget patterns_
  - _Requirements: 4.1-4.4, 4.7-4.9, 4.10, 4.11_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Create MCalMultiDayTile widget rendering contiguous tiles with smart corner radius, supporting custom builder | Restrictions: Use MCalTheme.of(context) for theme, handle RTL correctly, call callbacks with proper details | _Leverage: lib/src/widgets/mcal_month_view.dart | _Requirements: 4.1-4.4, 4.7-4.9, 4.10, 4.11 | Success: Tiles render with correct corners, builder receives all details, tap/long-press work | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 14. Integrate multi-day rendering into month grid
  - File: lib/src/widgets/mcal_month_view.dart
  - Add renderMultiDayEventsAsContiguous parameter (default true)
  - Add multiDayEventTileBuilder parameter
  - Create _MultiDayEventRowsWidget to render spanning tiles at top of each week
  - Update _WeekRowWidget to exclude multi-day events from regular cell rendering
  - Integrate MCalMultiDayRenderer for layout calculations
  - Update event sorting to use new ordering (per requirement 4.5)
  - Purpose: Render multi-day events as contiguous tiles spanning cells
  - _Leverage: lib/src/widgets/mcal_month_view.dart, lib/src/widgets/mcal_multi_day_renderer.dart_
  - _Requirements: 4.1-4.12_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Integrate multi-day rendering into MCalMonthView, adding parameters and _MultiDayEventRowsWidget, updating event sorting and filtering | Restrictions: Maintain z-ordering so multi-day tiles don't overlap other content, preserve existing single-day rendering | _Leverage: lib/src/widgets/mcal_month_view.dart, lib/src/widgets/mcal_multi_day_renderer.dart | _Requirements: 4.1-4.12 | Success: Multi-day events render as contiguous tiles, event ordering correct, toggle works | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 15. Write tests for multi-day events
  - File: test/widgets/mcal_multi_day_renderer_test.dart (new file)
  - Test _isMultiDay() with various event spans
  - Test event ordering comparator
  - Test layout calculation for single-week events
  - Test layout calculation for week-wrapping events
  - Test layout calculation for month-boundary events
  - File: test/widgets/mcal_month_view_test.dart
  - Test renderMultiDayEventsAsContiguous true/false
  - Test multiDayEventTileBuilder receives correct details
  - Test tap on multi-day tile fires callback correctly
  - Purpose: Verify multi-day rendering logic
  - _Leverage: test/widgets/mcal_month_view_test.dart_
  - _Requirements: 4.1-4.12_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Test Engineer | Task: Create tests for MCalMultiDayRenderer and multi-day tile rendering in MCalMonthView | Restrictions: Test edge cases (week wrap, month boundary), verify builder details | _Leverage: test/widgets/ | _Requirements: 4.1-4.12 | Success: All layout calculations tested, rendering toggle verified, builder tested | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

## Phase 5: Drag-and-Drop

- [x] 16. Create drag-related details classes
  - File: lib/src/widgets/mcal_callback_details.dart
  - Add MCalDraggedTileDetails class (event, sourceDate, currentPosition)
  - Add MCalDragSourceDetails class (event, sourceDate)
  - Add MCalDragTargetDetails class (event, targetDate, isValid)
  - Add MCalDragWillAcceptDetails class (event, proposedStartDate, proposedEndDate)
  - Add MCalDropTargetCellDetails class (date, isValid, draggedEvent)
  - Add MCalEventDroppedDetails class (event, oldStartDate, oldEndDate, newStartDate, newEndDate)
  - Purpose: Details objects for all drag-and-drop callbacks
  - _Leverage: lib/src/widgets/mcal_callback_details.dart_
  - _Requirements: 5.8-5.10, 5.13, 5.15, 5.17_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Add all drag-related details classes to mcal_callback_details.dart | Restrictions: Follow existing patterns, immutable const constructors | _Leverage: lib/src/widgets/mcal_callback_details.dart | _Requirements: 5.8-5.10, 5.13, 5.15, 5.17 | Success: All 6 drag details classes created | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 17. Create MCalDragHandler state manager
  - File: lib/src/widgets/mcal_drag_handler.dart (new file)
  - Create MCalDragHandler extending ChangeNotifier
  - Implement drag state fields (draggedEvent, sourceDate, targetDate, isValid, position)
  - Implement startDrag(), updateDrag(), completeDrag(), cancelDrag() methods
  - Implement handleEdgeProximity() with Timer for edge navigation
  - Implement delta calculation for multi-day event drops
  - Purpose: Manage drag-and-drop state
  - _Leverage: Flutter ChangeNotifier_
  - _Requirements: 5.4-5.7, 5.16-5.19, 5.24-5.27, 5.28-5.30_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer with state management expertise | Task: Create MCalDragHandler ChangeNotifier managing drag state, edge navigation timer, and drop calculations | Restrictions: Properly dispose timer, calculate day delta correctly for multi-day events | _Leverage: Flutter ChangeNotifier | _Requirements: 5.4-5.7, 5.16-5.19, 5.24-5.27, 5.28-5.30 | Success: Drag state management complete, delta calculations correct | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 18. Create MCalDraggableEventTile wrapper
  - File: lib/src/widgets/mcal_draggable_event_tile.dart (new file)
  - Create widget wrapping event tiles with LongPressDraggable
  - Support draggedTileBuilder for custom feedback widget
  - Support dragSourceBuilder for custom source placeholder
  - Implement default feedback (normal tile with elevation)
  - Implement default source (50% opacity ghost)
  - Purpose: Make event tiles draggable
  - _Leverage: Flutter LongPressDraggable_
  - _Requirements: 5.2-5.7, 5.8, 5.9_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Create MCalDraggableEventTile wrapping tiles with LongPressDraggable, supporting custom builders for feedback and source | Restrictions: Use 200ms delay for long-press, provide sensible defaults | _Leverage: Flutter LongPressDraggable | _Requirements: 5.2-5.7, 5.8, 5.9 | Success: Tiles are draggable via long-press, custom builders work, defaults look good | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 19. Integrate DragTarget into day cells
  - File: lib/src/widgets/mcal_month_view.dart
  - Add enableDragAndDrop parameter (default false)
  - Add draggedTileBuilder, dragSourceBuilder, dragTargetBuilder parameters
  - Add onDragWillAccept, dropTargetCellBuilder, onEventDropped parameters
  - Wrap _DayCellWidget content with DragTarget when enabled
  - Implement onWillAcceptWithDetails with validation callback
  - Implement visual feedback for valid/invalid targets
  - Implement onAcceptWithDetails to complete drop
  - Update event in controller and fire callback
  - Handle callback return false to revert
  - Purpose: Enable drop targets on day cells
  - _Leverage: lib/src/widgets/mcal_month_view.dart, Flutter DragTarget_
  - _Requirements: 5.1-5.3, 5.10-5.19_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Add DragTarget integration to _DayCellWidget, implementing validation, visual feedback, and drop handling with controller update | Restrictions: Only enable when enableDragAndDrop is true, handle callback return values correctly | _Leverage: lib/src/widgets/mcal_month_view.dart, Flutter DragTarget | _Requirements: 5.1-5.3, 5.10-5.19 | Success: Drops work, validation callback respected, controller updated, revert on false | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 20. Implement cross-month drag navigation
  - File: lib/src/widgets/mcal_month_view.dart
  - Add dragEdgeNavigationDelay parameter (default 500ms)
  - Detect drag position near left/right edges
  - Start timer when hovering at edge
  - Navigate to previous/next month when timer fires
  - Continue drag operation across month boundary
  - Respect minDate/maxDate during edge navigation
  - Handle drag cancellation at boundaries
  - Purpose: Enable dragging events across month boundaries
  - _Leverage: lib/src/widgets/mcal_month_view.dart, lib/src/widgets/mcal_drag_handler.dart_
  - _Requirements: 5.20-5.23_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Implement edge detection and auto-navigation during drag, with configurable delay and boundary respect | Restrictions: Continue drag seamlessly across months, cancel timer when leaving edge, respect min/max dates | _Leverage: lib/src/widgets/mcal_month_view.dart, lib/src/widgets/mcal_drag_handler.dart | _Requirements: 5.20-5.23 | Success: Edge navigation works, delay configurable, boundaries respected | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 21. Add drag cancellation handling
  - File: lib/src/widgets/mcal_month_view.dart
  - Detect Escape key press during drag
  - Detect drag outside calendar bounds (non-navigable edge)
  - Animate tile back to original position on cancel
  - Clean up drag state
  - Purpose: Allow users to cancel drag operations
  - _Leverage: lib/src/widgets/mcal_month_view.dart, lib/src/widgets/mcal_drag_handler.dart_
  - _Requirements: 5.28-5.30_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Implement drag cancellation via Escape key and drag-out-of-bounds, with animated return to source | Restrictions: Clean up all drag state, ensure no memory leaks | _Leverage: lib/src/widgets/mcal_month_view.dart, lib/src/widgets/mcal_drag_handler.dart | _Requirements: 5.28-5.30 | Success: Escape cancels drag, out-of-bounds cancels, tile animates back | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 22. Write tests for drag-and-drop
  - File: test/widgets/mcal_drag_handler_test.dart (new file)
  - Test drag state transitions (start, update, complete, cancel)
  - Test day delta calculation for drops
  - Test multi-day event delta calculation
  - Test edge navigation timer behavior
  - File: test/widgets/mcal_month_view_test.dart
  - Test enableDragAndDrop toggle
  - Test long-press initiates drag
  - Test onDragWillAccept validation
  - Test onEventDropped receives correct details
  - Test onEventDropped return false reverts event
  - Test custom builders receive correct details
  - Test cross-month drag navigation
  - Test drag cancellation (escape, out-of-bounds)
  - Purpose: Verify drag-and-drop functionality
  - _Leverage: test/widgets/, Flutter test gesture utilities_
  - _Requirements: 5.1-5.30_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Test Engineer | Task: Create comprehensive tests for MCalDragHandler and drag-and-drop functionality in MCalMonthView | Restrictions: Test all drag states, validation, callbacks, edge navigation, cancellation | _Leverage: test/widgets/ | _Requirements: 5.1-5.30 | Success: All drag scenarios tested, edge cases covered | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

## Phase 6: Example App & Polish

- [x] 23. Add drag-and-drop theme properties
  - File: lib/src/styles/mcal_theme.dart
  - Add dragTargetValidColor property
  - Add dragTargetInvalidColor property
  - Add dragSourceOpacity property
  - Add draggedTileElevation property
  - Add multiDayEventBackgroundColor property
  - Add multiDayEventTextStyle property
  - Update copyWith() and lerp() methods
  - Update fromTheme() with defaults
  - Purpose: Theme support for new features
  - _Leverage: lib/src/styles/mcal_theme.dart_
  - _Requirements: Design document theme properties_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Add new theme properties for drag-and-drop and multi-day events to MCalThemeData | Restrictions: Follow existing property patterns, provide sensible defaults in fromTheme() | _Leverage: lib/src/styles/mcal_theme.dart | _Requirements: Design document | Success: All new theme properties added with proper defaults | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 24. Update example app with new features
  - File: example/lib/main.dart, example/lib/screens/
  - Add toggle for renderMultiDayEventsAsContiguous
  - Add toggle for enableDragAndDrop
  - Add sample multi-day events
  - Demonstrate custom multiDayEventTileBuilder
  - Demonstrate drag-and-drop with visual feedback
  - Add slider for dragEdgeNavigationDelay
  - Demonstrate cross-month drag
  - Purpose: Showcase all new features
  - _Leverage: example/lib existing structure_
  - _Requirements: All_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Update example app to demonstrate all new features: PageView swipe, multi-day tiles, drag-and-drop, toggles | Restrictions: Keep example clear and educational | _Leverage: example/lib | _Requirements: All | Success: Example demonstrates all features, toggles work, looks polished | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 25. Update README documentation
  - File: README.md
  - Document new callback API pattern (BuildContext, Details)
  - Document MCalTheme.of(context) usage
  - Document swipe navigation
  - Document multi-day event rendering
  - Document drag-and-drop API
  - Add code examples for each feature
  - Purpose: Help developers use new features
  - _Leverage: README.md existing structure_
  - _Requirements: All_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Technical Writer | Task: Update README with documentation for all new features including callback pattern, theme access, swipe, multi-day tiles, and drag-and-drop | Restrictions: Follow existing README style, include code examples | _Leverage: README.md | _Requirements: All | Success: All new features documented with examples | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 26. Final integration testing
  - File: test/integration/mcal_month_view_integration_test.dart
  - Test full user flow: swipe navigation with multi-day events
  - Test full user flow: drag event across months
  - Test callback API consistency across all interaction types
  - Test theme inheritance with nested widgets
  - Purpose: Verify all features work together
  - _Leverage: test/integration/_
  - _Requirements: All_
  - _Prompt: Implement the task for spec month-view-enhancements-part-2, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Test Engineer | Task: Add integration tests verifying all new features work together: swipe + multi-day + drag-and-drop | Restrictions: Test realistic user scenarios, verify no regressions | _Leverage: test/integration/ | _Requirements: All | Success: All features work together, no regressions | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_
