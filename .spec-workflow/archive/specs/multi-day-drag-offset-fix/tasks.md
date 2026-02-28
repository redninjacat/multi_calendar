# Tasks Document: Multi-Day Drag Offset Fix

## Summary
This document captures the tasks completed to fix the multi-day event drag offset timing issue. All tasks have been implemented and tested.

## Tasks

- [x] 1. Create MCalGrabOffsetHolder class
  - File: lib/src/widgets/mcal_callback_details.dart
  - Create new mutable holder class for grab offset value
  - Add documentation explaining the timing issue it solves
  - Purpose: Provide mutable storage that can be updated after MCalDragData creation
  - _Leverage: Existing MCalDragData class structure_
  - _Requirements: 3.1_
  - _Prompt: Implement the task for spec multi-day-drag-offset-fix, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in widget state management | Task: Create MCalGrabOffsetHolder class in mcal_callback_details.dart with mutable grabOffsetX property and documentation explaining LongPressDraggable timing issue | Restrictions: Keep class simple, do not add unnecessary complexity, maintain existing file organization | _Leverage: Existing class patterns in mcal_callback_details.dart | _Requirements: Requirement 3.1 (Timing-Safe Drag Data Transfer) | Success: Class is created with proper documentation, compiles without errors, follows existing code style. After completion, mark task as in-progress in tasks.md, log implementation with log-implementation tool, then mark as complete._

- [x] 2. Modify MCalDragData to use holder pattern
  - File: lib/src/widgets/mcal_callback_details.dart
  - Change grabOffsetX from final field to getter reading from holder
  - Update constructor to accept MCalGrabOffsetHolder parameter
  - Remove const from constructor (holder is mutable)
  - Purpose: Allow grab offset to be updated after MCalDragData is created
  - _Leverage: MCalGrabOffsetHolder from task 1_
  - _Requirements: 3.1_
  - _Prompt: Implement the task for spec multi-day-drag-offset-fix, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer with expertise in data modeling | Task: Modify MCalDragData class to use holder pattern - replace final grabOffsetX field with getter that reads from private MCalGrabOffsetHolder, update constructor signature | Restrictions: Do not change event or sourceDate fields, maintain backward-compatible getter API for grabOffsetX, update documentation | _Leverage: MCalGrabOffsetHolder created in task 1 | _Requirements: Requirement 3.1 (Timing-Safe Drag Data Transfer) | Success: MCalDragData.grabOffsetX getter returns holder's current value, constructor accepts grabOffsetHolder parameter, existing code reading grabOffsetX works unchanged. After completion, mark task as in-progress in tasks.md, log implementation with log-implementation tool, then mark as complete._

- [x] 3. Update MCalDraggableEventTile state to use holder
  - File: lib/src/widgets/mcal_draggable_event_tile.dart
  - Replace double _grabOffsetX with MCalGrabOffsetHolder instance
  - Create holder as final instance variable (persists across rebuilds)
  - Purpose: Maintain single holder instance that MCalDragData references
  - _Leverage: MCalGrabOffsetHolder, existing _MCalDraggableEventTileState structure_
  - _Requirements: 1.1, 3.1_
  - _Prompt: Implement the task for spec multi-day-drag-offset-fix, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in StatefulWidget implementation | Task: Replace _grabOffsetX double with final MCalGrabOffsetHolder _grabOffsetHolder instance in _MCalDraggableEventTileState | Restrictions: Keep holder as final instance (not recreated on rebuild), maintain existing _feedbackOffset handling, do not change widget parameters | _Leverage: Existing state structure in mcal_draggable_event_tile.dart | _Requirements: Requirements 1.1 (Accurate Grab Position Tracking), 3.1 (Timing-Safe Drag Data Transfer) | Success: Holder is created once per state instance, persists across widget rebuilds, no memory leaks. After completion, mark task as in-progress in tasks.md, log implementation with log-implementation tool, then mark as complete._

- [x] 4. Update onPointerDown to update holder directly
  - File: lib/src/widgets/mcal_draggable_event_tile.dart
  - Modify onPointerDown callback to update _grabOffsetHolder.grabOffsetX directly
  - Remove setState for grabOffsetX (holder mutation doesn't need rebuild)
  - Keep setState for _feedbackOffset (still needed for visual feedback positioning)
  - Purpose: Update grab offset value immediately without waiting for rebuild
  - _Leverage: Existing onPointerDown handler logic_
  - _Requirements: 1.1, 3.1_
  - _Prompt: Implement the task for spec multi-day-drag-offset-fix, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer with expertise in pointer event handling | Task: Update onPointerDown callback to update _grabOffsetHolder.grabOffsetX directly instead of using setState, keep setState only for _feedbackOffset | Restrictions: Do not remove feedbackOffset setState (needed for visual positioning), maintain grab offset calculation logic, remove debug logging | _Leverage: Existing onPointerDown implementation | _Requirements: Requirements 1.1 (Accurate Grab Position Tracking), 3.1 (Timing-Safe Drag Data Transfer) | Success: Holder is updated immediately on pointer down, no unnecessary widget rebuilds for grab offset, feedbackOffset still updates correctly. After completion, mark task as in-progress in tasks.md, log implementation with log-implementation tool, then mark as complete._

- [x] 5. Update LongPressDraggable data parameter
  - File: lib/src/widgets/mcal_draggable_event_tile.dart
  - Change MCalDragData constructor call to pass grabOffsetHolder instead of grabOffsetX
  - MCalDragData now holds reference to holder, reads current value when accessed
  - Purpose: Ensure drop target always receives current grab offset value
  - _Leverage: Modified MCalDragData constructor from task 2_
  - _Requirements: 3.1_
  - _Prompt: Implement the task for spec multi-day-drag-offset-fix, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer with expertise in drag-and-drop implementation | Task: Update LongPressDraggable data parameter to pass _grabOffsetHolder to MCalDragData constructor | Restrictions: Do not change other MCalDragData parameters (event, sourceDate), maintain existing feedback and childWhenDragging logic | _Leverage: Modified MCalDragData from task 2 | _Requirements: Requirement 3.1 (Timing-Safe Drag Data Transfer) | Success: MCalDragData is created with holder reference, drop targets receive current grab offset value regardless of rebuild timing. After completion, mark task as in-progress in tasks.md, log implementation with log-implementation tool, then mark as complete._

- [x] 6. Remove debug logging
  - Files: lib/src/widgets/mcal_draggable_event_tile.dart, lib/src/widgets/mcal_month_view.dart
  - Remove debugPrint statements added during investigation
  - Clean up any temporary diagnostic code
  - Purpose: Production-ready code without debug output
  - _Leverage: N/A_
  - _Requirements: Non-functional (Code Quality)_
  - _Prompt: Implement the task for spec multi-day-drag-offset-fix, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Remove all debugPrint statements and temporary diagnostic code from mcal_draggable_event_tile.dart and mcal_month_view.dart | Restrictions: Only remove debug code, do not modify functional logic, verify no debug output in production | _Leverage: N/A | _Requirements: Non-functional (Code Quality) | Success: No debugPrint or diagnostic code remains, code is production-ready, all tests still pass. After completion, mark task as in-progress in tasks.md, log implementation with log-implementation tool, then mark as complete._

- [x] 7. Verify existing tests pass
  - Files: test/widgets/mcal_month_view_test.dart
  - Run all drag-and-drop tests to ensure no regressions
  - Verify multi-day event drag test passes with correct grab offset
  - Verify "dragging same event twice" test passes
  - Purpose: Confirm fix works and doesn't break existing functionality
  - _Leverage: Existing test infrastructure_
  - _Requirements: All_
  - _Prompt: Implement the task for spec multi-day-drag-offset-fix, first run spec-workflow-guide to get the workflow guide then implement the task: Role: QA Engineer with Flutter testing expertise | Task: Run all drag-and-drop tests in mcal_month_view_test.dart, verify all 18 tests pass including multi-day event drag and repeated drag tests | Restrictions: Do not modify tests unless they have bugs, only verify existing tests pass | _Leverage: Existing test suite | _Requirements: All requirements | Success: All 18 drag-and-drop tests pass, no regressions in other tests, multi-day drag offset is correctly tracked. After completion, mark task as in-progress in tasks.md, log implementation with log-implementation tool, then mark as complete._

## Implementation Summary

All tasks have been completed. The fix introduces:

1. **MCalGrabOffsetHolder**: A simple mutable class that holds the grab offset value
2. **Modified MCalDragData**: Now holds a reference to the holder and reads the current value via a getter
3. **Updated drag handling**: onPointerDown updates the holder directly without requiring a widget rebuild

This pattern solves the timing issue where Flutter's `LongPressDraggable` captures its `data` parameter at build time, but the grab offset is only known after `onPointerDown` fires.

**Test Results**: All 18 drag-and-drop tests pass, confirming the fix works correctly for both single-day and multi-day events.
