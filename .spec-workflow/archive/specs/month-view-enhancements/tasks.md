# Tasks Document

## Phase 1: Controller Enhancements

- [x] 1. Add displayDate and focusedDate to MCalEventController
  - File: lib/src/controllers/mcal_event_controller.dart
  - Add `_displayDate` field (non-null, defaults to today)
  - Add `_focusedDate` field (nullable)
  - Add getters: `displayDate`, `focusedDate`
  - Add methods: `setDisplayDate()`, `setFocusedDate()`, `navigateToDate()`
  - Update `notifyListeners()` calls appropriately
  - Purpose: Enable programmatic navigation and focused date management across views
  - _Leverage: Existing ChangeNotifier pattern in mcal_event_controller.dart_
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in state management and ChangeNotifier | Task: Add displayDate (non-null DateTime, defaults to today) and focusedDate (nullable DateTime) properties to MCalEventController with setters that call notifyListeners(), plus a navigateToDate() convenience method per the design document | Restrictions: Do not break existing API, maintain backward compatibility, ensure notifyListeners() is called only when values actually change | _Leverage: lib/src/controllers/mcal_event_controller.dart existing patterns | _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6 | Success: Controller has displayDate/focusedDate properties, setters notify listeners, navigateToDate works correctly, all existing tests pass | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 2. Add loading and error state to MCalEventController
  - File: lib/src/controllers/mcal_event_controller.dart
  - Add `_isLoading` field (bool, defaults to false)
  - Add `_error` field (Object?, nullable)
  - Add getters: `isLoading`, `error`, `hasError`
  - Add methods: `setLoading()`, `setError()`, `clearError()`, `retryLoad()`
  - Purpose: Enable loading indicators and error handling in views
  - _Leverage: Existing loadEvents() method in mcal_event_controller.dart_
  - _Requirements: 8.13, 8.14_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer with expertise in async state management | Task: Add isLoading (bool) and error (Object?) state to MCalEventController with appropriate setters and a retryLoad() method that clears error and reloads events for the current displayDate range | Restrictions: Do not modify existing loadEvents() signature, ensure setLoading/setError call notifyListeners() | _Leverage: lib/src/controllers/mcal_event_controller.dart existing loadEvents() method | _Requirements: 8.13, 8.14 | Success: Controller exposes loading/error state, retryLoad() works correctly, views can react to state changes | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 3. Write unit tests for controller enhancements
  - File: test/controllers/mcal_event_controller_test.dart
  - Test displayDate/focusedDate getters and setters
  - Test navigateToDate() with focus=true and focus=false
  - Test loading/error state transitions
  - Test retryLoad() behavior
  - Purpose: Ensure controller enhancements work correctly
  - _Leverage: Existing test patterns in test/controllers/mcal_event_controller_test.dart_
  - _Requirements: 3.1-3.6, 8.13, 8.14_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Test Engineer specializing in unit testing | Task: Add comprehensive unit tests for new displayDate, focusedDate, loading, and error state in MCalEventController, testing all setters, getters, and the navigateToDate() method | Restrictions: Follow existing test patterns, test notification behavior, test edge cases | _Leverage: test/controllers/mcal_event_controller_test.dart existing patterns | _Requirements: 3.1-3.6, 8.13, 8.14 | Success: All new controller functionality is tested with good coverage, tests verify notification behavior | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

## Phase 2: Theme Extensions

- [x] 4. Add new theme properties to MCalThemeData
  - File: lib/src/styles/mcal_theme.dart
  - Add focused date styling: `focusedDateBackgroundColor`, `focusedDateTextStyle`
  - Add all-day event styling: `allDayEventBackgroundColor`, `allDayEventTextStyle`, `allDayEventBorderColor`, `allDayEventBorderWidth`
  - Add week number styling: `weekNumberTextStyle`, `weekNumberBackgroundColor`
  - Add hover styling: `hoverCellBackgroundColor`, `hoverEventBackgroundColor`
  - Update `copyWith()` and `lerp()` methods
  - Update `fromTheme()` to provide sensible defaults
  - Purpose: Enable customization of new visual features
  - _Leverage: Existing MCalThemeData patterns in lib/src/styles/mcal_theme.dart_
  - _Requirements: 3.24, 6.3, 6.4, 9.8_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in theming and ThemeExtension | Task: Add new theme properties for focused date, all-day events, week numbers, and hover states to MCalThemeData, updating copyWith(), lerp(), and fromTheme() methods | Restrictions: Maintain backward compatibility, provide sensible defaults in fromTheme(), follow existing property patterns | _Leverage: lib/src/styles/mcal_theme.dart existing patterns | _Requirements: 3.24, 6.3, 6.4, 9.8 | Success: All new theme properties are added with proper defaults, copyWith and lerp work correctly | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 5. Write unit tests for theme extensions
  - File: test/styles/mcal_theme_test.dart
  - Test new properties in copyWith()
  - Test lerp() interpolation for new properties
  - Test fromTheme() default values
  - Purpose: Ensure theme extensions work correctly
  - _Leverage: Existing test patterns in test/styles/mcal_theme_test.dart_
  - _Requirements: 3.24, 6.3, 6.4, 9.8_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Test Engineer | Task: Add unit tests for new MCalThemeData properties covering copyWith, lerp, and fromTheme methods | Restrictions: Follow existing test patterns | _Leverage: test/styles/mcal_theme_test.dart existing patterns | _Requirements: 3.24, 6.3, 6.4, 9.8 | Success: All new theme properties are tested | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

## Phase 3: Context Updates

- [x] 6. Add isFocused to MCalDayCellContext
  - File: lib/src/widgets/mcal_month_view_contexts.dart
  - Add `isFocused` boolean field to MCalDayCellContext
  - Update constructor with optional isFocused parameter (default false)
  - Purpose: Allow dayCellBuilder to know if cell is focused
  - _Leverage: Existing MCalDayCellContext in lib/src/widgets/mcal_month_view_contexts.dart_
  - _Requirements: 3.25_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Add isFocused boolean field to MCalDayCellContext class with default value of false | Restrictions: Maintain backward compatibility with existing usage | _Leverage: lib/src/widgets/mcal_month_view_contexts.dart | _Requirements: 3.25 | Success: MCalDayCellContext has isFocused property | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 7. Add MCalWeekNumberContext class
  - File: lib/src/widgets/mcal_month_view_contexts.dart
  - Create new MCalWeekNumberContext class
  - Fields: weekNumber (int), firstDayOfWeek (DateTime), defaultFormattedString (String), theme (MCalThemeData)
  - Export from multi_calendar.dart
  - Purpose: Provide context for week number builder callback
  - _Leverage: Existing context patterns in lib/src/widgets/mcal_month_view_contexts.dart_
  - _Requirements: 9.6_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Create MCalWeekNumberContext class following existing context patterns, with weekNumber, firstDayOfWeek, defaultFormattedString, and theme fields | Restrictions: Follow existing naming conventions and documentation patterns | _Leverage: lib/src/widgets/mcal_month_view_contexts.dart existing patterns | _Requirements: 9.6 | Success: MCalWeekNumberContext class is created and exported | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

## Phase 4: ISO Week Number Utility

- [x] 8. Add ISO week number calculation utility
  - File: lib/src/utils/date_utils.dart
  - Add `getISOWeekNumber(DateTime date)` function
  - Implement ISO 8601 week numbering (week 1 contains first Thursday)
  - Handle edge cases: week 0 (last week of previous year), week 53
  - Purpose: Calculate correct ISO week numbers for display
  - _Leverage: Existing date utilities in lib/src/utils/date_utils.dart_
  - _Requirements: 9.3_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer with date/time expertise | Task: Implement getISOWeekNumber() function following ISO 8601 standard where week 1 contains the first Thursday of the year, handling edge cases for week 0 (maps to last week of previous year) and week 53 | Restrictions: Use only Dart DateTime, no external packages, handle all edge cases | _Leverage: lib/src/utils/date_utils.dart existing patterns | _Requirements: 9.3 | Success: Function returns correct ISO week numbers for all dates including year boundaries | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 9. Write unit tests for ISO week number calculation
  - File: test/utils/date_utils_test.dart
  - Test standard week numbers
  - Test year boundary cases (week 1, week 52/53)
  - Test edge cases (Jan 1-3, Dec 29-31)
  - Purpose: Ensure ISO week numbers are calculated correctly
  - _Leverage: Existing test patterns in test/utils/date_utils_test.dart_
  - _Requirements: 9.3_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Test Engineer | Task: Write comprehensive unit tests for getISOWeekNumber() covering standard weeks, year boundaries, and edge cases | Restrictions: Test known ISO week numbers from reliable sources | _Leverage: test/utils/date_utils_test.dart existing patterns | _Requirements: 9.3 | Success: All edge cases are tested, function behavior matches ISO 8601 standard | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

## Phase 5: New MCalMonthView Parameters

- [x] 10. Add new parameters to MCalMonthView widget
  - File: lib/src/widgets/mcal_month_view.dart
  - Add hover callbacks: `onHoverCell`, `onHoverEvent`
  - Add keyboard parameter: `enableKeyboardNavigation` (default true)
  - Add navigation callbacks: `onDisplayDateChanged`, `onViewableRangeChanged`, `onFocusedDateChanged`, `onFocusedRangeChanged`
  - Add `autoFocusOnCellTap` (default true)
  - Add overflow callbacks: `onOverflowTap`, `onOverflowLongPress`
  - Add animation parameters: `enableAnimations`, `animationDuration`, `animationCurve`
  - Add `maxVisibleEvents` (default 3)
  - Add state builders: `loadingBuilder`, `errorBuilder`
  - Add week numbers: `showWeekNumbers`, `weekNumberBuilder`
  - Add `semanticsLabel`
  - Purpose: Expose new features to developers
  - _Leverage: Existing MCalMonthView parameters in lib/src/widgets/mcal_month_view.dart_
  - _Requirements: 1.1, 1.3, 2.13, 3.14-3.17, 3.19, 4.4, 4.7, 5.4, 5.6, 5.9, 7.1, 8.2, 8.6, 9.1, 9.5, 11.12_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Add all new parameters to MCalMonthView widget class as specified in the design document, with appropriate defaults and documentation | Restrictions: Do not implement functionality yet (just add parameters), maintain backward compatibility, add dartdoc comments | _Leverage: lib/src/widgets/mcal_month_view.dart existing parameter patterns | _Requirements: 1.1, 1.3, 2.13, 3.14-3.17, 3.19, 4.4, 4.7, 5.4, 5.6, 5.9, 7.1, 8.2, 8.6, 9.1, 9.5, 11.12 | Success: All new parameters are added with correct types and defaults | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

## Phase 6: Controller Integration in View

- [x] 11. Integrate displayDate/focusedDate with MCalMonthView
  - File: lib/src/widgets/mcal_month_view.dart
  - Update `_MCalMonthViewState` to use controller.displayDate instead of internal _currentMonth
  - React to displayDate changes from controller
  - Update swipe navigation to call controller.setDisplayDate()
  - Update navigator to call controller.setDisplayDate()
  - Fire onDisplayDateChanged, onViewableRangeChanged, onFocusedRangeChanged callbacks
  - Purpose: Synchronize view with controller state
  - _Leverage: Existing controller listener pattern in _MCalMonthViewState_
  - _Requirements: 3.7, 3.8, 3.9, 3.14, 3.15, 3.17, 3.20_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer specializing in state management | Task: Update MCalMonthView to use controller.displayDate as the source of truth for which month is displayed, update swipe and navigator to call controller.setDisplayDate(), and fire the new callbacks when dates/ranges change | Restrictions: Maintain backward compatibility, handle initialDate properly (set controller.displayDate in initState if provided), ensure callbacks fire at appropriate times | _Leverage: lib/src/widgets/mcal_month_view.dart existing _onControllerChanged pattern | _Requirements: 3.7, 3.8, 3.9, 3.14, 3.15, 3.17, 3.20 | Success: View displays month based on controller.displayDate, swipe/navigator update controller, callbacks fire correctly | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 12. Add focused date highlighting to day cells
  - File: lib/src/widgets/mcal_month_view.dart
  - Pass isFocused to MCalDayCellContext
  - Apply focusedDateBackgroundColor and focusedDateTextStyle from theme
  - Update cell tap to call controller.setFocusedDate() when autoFocusOnCellTap is true
  - Fire onFocusedDateChanged callback
  - Purpose: Visually highlight the focused date and respond to taps
  - _Leverage: Existing _DayCellWidget styling in lib/src/widgets/mcal_month_view.dart_
  - _Requirements: 3.10, 3.18, 3.22, 3.23, 3.25_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Add focused date highlighting to _DayCellWidget by checking if date matches controller.focusedDate, applying theme styling, passing isFocused to MCalDayCellContext, and updating cell tap to set focusedDate when autoFocusOnCellTap is true | Restrictions: Only show highlight if focusedDate is within viewable range, let dayCellBuilder override styling if provided | _Leverage: lib/src/widgets/mcal_month_view.dart existing _DayCellWidget | _Requirements: 3.10, 3.18, 3.22, 3.23, 3.25 | Success: Focused date is visually highlighted, tap sets focus, callback fires | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

## Phase 7: Keyboard Navigation

- [x] 13. Implement keyboard navigation in MCalMonthView
  - File: lib/src/widgets/mcal_month_view.dart
  - Add FocusNode to _MCalMonthViewState
  - Wrap widget in Focus widget with onKeyEvent handler
  - Implement arrow key navigation (left/right = day, up/down = week)
  - Implement Home/End (first/last day of month)
  - Implement Page Up/Down (previous/next month)
  - Implement Enter/Space (trigger onCellTap)
  - Respect minDate/maxDate restrictions
  - Update displayDate when focus moves outside visible month
  - Purpose: Enable keyboard-only calendar navigation
  - _Leverage: Flutter Focus system, existing controller methods_
  - _Requirements: 2.1-2.15_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer with accessibility expertise | Task: Add keyboard navigation to MCalMonthView using Flutter's Focus widget and onKeyEvent, implementing all key handlers per requirements (arrows, Home, End, Page Up/Down, Enter/Space), respecting minDate/maxDate, and updating displayDate when focus moves outside visible month | Restrictions: Only process keys when enableKeyboardNavigation is true, respect Tab/Shift+Tab for standard focus behavior | _Leverage: Flutter Focus system, lib/src/widgets/mcal_month_view.dart | _Requirements: 2.1-2.15 | Success: All keyboard shortcuts work correctly, focus stays within bounds, displayDate follows when needed | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 14. Write widget tests for keyboard navigation
  - File: test/widgets/mcal_month_view_test.dart
  - Test arrow key navigation
  - Test Home/End keys
  - Test Page Up/Down keys
  - Test Enter/Space activation
  - Test minDate/maxDate boundary behavior
  - Test enableKeyboardNavigation=false disables shortcuts
  - Purpose: Ensure keyboard navigation works correctly
  - _Leverage: Existing widget test patterns in test/widgets/mcal_month_view_test.dart_
  - _Requirements: 2.1-2.15_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Test Engineer | Task: Write widget tests for keyboard navigation covering all key handlers, boundary conditions, and the enableKeyboardNavigation toggle | Restrictions: Use sendKeyEvent for keyboard simulation, verify controller state changes | _Leverage: test/widgets/mcal_month_view_test.dart existing patterns | _Requirements: 2.1-2.15 | Success: All keyboard navigation scenarios are tested | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

## Phase 8: Hover Support

- [x] 15. Add hover support to day cells
  - File: lib/src/widgets/mcal_month_view.dart
  - Wrap _DayCellWidget content in MouseRegion
  - Call onHoverCell callback on enter/exit
  - Pass hover callbacks through widget hierarchy
  - Purpose: Enable hover interactions on desktop/web
  - _Leverage: Flutter MouseRegion widget_
  - _Requirements: 1.1, 1.2, 1.5, 1.6, 1.9, 1.10_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Add MouseRegion to _DayCellWidget to detect hover enter/exit, calling onHoverCell callback with date, events, isCurrentMonth, and isEntering boolean | Restrictions: Only wrap in MouseRegion if onHoverCell is provided, gracefully handle platforms without hover support | _Leverage: Flutter MouseRegion | _Requirements: 1.1, 1.2, 1.5, 1.6, 1.9, 1.10 | Success: onHoverCell fires correctly on desktop/web, no errors on mobile | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 16. Add hover support to event tiles
  - File: lib/src/widgets/mcal_month_view.dart
  - Wrap _EventTileWidget content in MouseRegion
  - Call onHoverEvent callback on enter/exit
  - Purpose: Enable hover interactions on event tiles
  - _Leverage: Flutter MouseRegion widget_
  - _Requirements: 1.3, 1.4, 1.7, 1.8, 1.9, 1.10_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Add MouseRegion to _EventTileWidget to detect hover enter/exit, calling onHoverEvent callback with event, displayDate, and isEntering boolean | Restrictions: Only wrap in MouseRegion if onHoverEvent is provided | _Leverage: Flutter MouseRegion | _Requirements: 1.3, 1.4, 1.7, 1.8, 1.9, 1.10 | Success: onHoverEvent fires correctly on desktop/web | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

## Phase 9: Animation System

- [x] 17. Add month transition animations
  - File: lib/src/widgets/mcal_month_view.dart
  - Track last swipe direction in state
  - Wrap month grid in AnimatedSwitcher
  - Apply slide/fade transition based on navigation direction
  - Use animationDuration and animationCurve parameters
  - Disable animations when enableAnimations is false
  - Purpose: Provide smooth visual transitions between months
  - _Leverage: Flutter AnimatedSwitcher, existing _buildMonthGrid()_
  - _Requirements: 5.1-5.10_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer with animation expertise | Task: Add month transition animations using AnimatedSwitcher with slide/fade transitions, tracking navigation direction for correct slide direction, using the animationDuration and animationCurve parameters, and respecting enableAnimations toggle | Restrictions: Use KeyedSubtree with ValueKey for proper widget identity, ensure animations don't block UI | _Leverage: Flutter AnimatedSwitcher, lib/src/widgets/mcal_month_view.dart | _Requirements: 5.1-5.10 | Success: Smooth slide/fade animations on month navigation, instant transitions when disabled | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

## Phase 10: Overflow Indicator Enhancements

- [x] 18. Make overflow indicator interactive
  - File: lib/src/widgets/mcal_month_view.dart
  - Update _OverflowIndicatorWidget to accept onOverflowTap and onOverflowLongPress
  - Add GestureDetector for tap/long-press
  - Implement default bottom sheet showing all events for the day
  - Add semantic label for accessibility
  - Purpose: Allow users to view all events when overflow occurs
  - _Leverage: Existing _OverflowIndicatorWidget in lib/src/widgets/mcal_month_view.dart_
  - _Requirements: 4.1-4.11_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Make _OverflowIndicatorWidget interactive by adding GestureDetector for tap/long-press, calling provided callbacks or showing a default bottom sheet with all events for the day, and adding appropriate semantic labels | Restrictions: Pass all events for the day (not just hidden ones), include count of hidden events | _Leverage: lib/src/widgets/mcal_month_view.dart existing _OverflowIndicatorWidget | _Requirements: 4.1-4.11 | Success: Tapping overflow shows all events, callbacks fire correctly, accessible via keyboard | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 19. Implement configurable maxVisibleEvents
  - File: lib/src/widgets/mcal_month_view.dart
  - Use maxVisibleEvents parameter instead of hardcoded 3
  - Handle maxVisibleEvents=0 (show all, no overflow)
  - Purpose: Allow developers to customize overflow threshold
  - _Leverage: Existing event tile rendering logic_
  - _Requirements: 7.1-7.8_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Update _DayCellWidget to use widget.maxVisibleEvents instead of hardcoded 3, handling 0 as "show all events without overflow" | Restrictions: Maintain existing overflow indicator behavior | _Leverage: lib/src/widgets/mcal_month_view.dart existing _buildEventTiles | _Requirements: 7.1-7.8 | Success: maxVisibleEvents controls overflow threshold correctly | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

## Phase 11: Week Number Display

- [x] 20. Implement week number column
  - File: lib/src/widgets/mcal_month_view.dart
  - Add _WeekNumberCell widget
  - Modify grid layout to include week number column when showWeekNumbers is true
  - Position on left for LTR, right for RTL
  - Support weekNumberBuilder callback
  - Apply weekNumberTextStyle and weekNumberBackgroundColor from theme
  - Purpose: Display ISO week numbers for international users
  - _Leverage: Existing grid layout, getISOWeekNumber utility_
  - _Requirements: 9.1-9.10_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Create _WeekNumberCell widget and integrate into month grid when showWeekNumbers is true, positioning on left for LTR and right for RTL, using getISOWeekNumber utility, applying theme styling, and supporting weekNumberBuilder callback | Restrictions: Grid must adjust to accommodate week number column, maintain RTL support | _Leverage: lib/src/widgets/mcal_month_view.dart, lib/src/utils/date_utils.dart getISOWeekNumber | _Requirements: 9.1-9.10 | Success: Week numbers display correctly, positioned based on text direction, styled from theme | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

## Phase 12: All-Day Event Styling

- [x] 21. Enhance all-day event styling
  - File: lib/src/widgets/mcal_month_view.dart
  - Apply allDayEventBackgroundColor, allDayEventTextStyle from theme
  - Apply allDayEventBorderColor, allDayEventBorderWidth from theme
  - Ensure all-day events are sorted before timed events
  - Add visual indicator distinguishing all-day from timed events
  - Purpose: Make all-day events visually distinct
  - _Leverage: Existing _EventTileWidget, MCalThemeData_
  - _Requirements: 6.1-6.10_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Enhance _EventTileWidget to use all-day specific styling from theme (background, text, border) when event.isAllDay is true, ensure all-day events are sorted before timed events in _buildEventTiles, and add a visual indicator | Restrictions: Builder callback should take precedence over theme styling, isAllDay already available in MCalEventTileContext | _Leverage: lib/src/widgets/mcal_month_view.dart _EventTileWidget, lib/src/styles/mcal_theme.dart | _Requirements: 6.1-6.10 | Success: All-day events are visually distinct, sorted first, styled from theme | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

## Phase 13: Loading and Error States

- [x] 22. Implement loading and error overlays
  - File: lib/src/widgets/mcal_month_view.dart
  - Create _LoadingOverlay widget
  - Create _ErrorOverlay widget with retry button
  - Display overlay based on controller.isLoading and controller.hasError
  - Support loadingBuilder and errorBuilder callbacks
  - Calendar grid should remain visible under overlays
  - Purpose: Provide visual feedback during loading and error states
  - _Leverage: Controller isLoading/error state, existing widget patterns_
  - _Requirements: 8.1-8.12_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Create _LoadingOverlay and _ErrorOverlay widgets, display them based on controller state, support custom builders, ensure calendar grid remains visible underneath, and wire retry button to controller.retryLoad() | Restrictions: Use Stack to overlay, apply semi-transparent background to overlays | _Leverage: lib/src/widgets/mcal_month_view.dart, lib/src/controllers/mcal_event_controller.dart | _Requirements: 8.1-8.12 | Success: Loading indicator shows during load, error overlay shows on error with working retry | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

## Phase 14: Accessibility Enhancements

- [x] 23. Enhance day cell semantic labels
  - File: lib/src/widgets/mcal_month_view.dart
  - Update _getSemanticLabel() in _DayCellWidget to include:
    - Whether date is focused
    - Localized date format
    - Hints for keyboard navigation
  - Purpose: Improve screen reader experience
  - _Leverage: Existing Semantics usage, MCalLocalizations_
  - _Requirements: 11.1, 11.4, 11.5, 11.6, 11.11_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer with accessibility expertise | Task: Enhance _DayCellWidget semantic label to include focused state, use Semantics properties (selected for focused, hint for interaction), and ensure labels are localized | Restrictions: Keep labels concise but comprehensive | _Leverage: lib/src/widgets/mcal_month_view.dart _getSemanticLabel, lib/src/utils/mcal_localization.dart | _Requirements: 11.1, 11.4, 11.5, 11.6, 11.11 | Success: Screen readers announce focused state and navigation hints | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 24. Add semanticsLabel to MCalMonthView
  - File: lib/src/widgets/mcal_month_view.dart
  - Wrap entire widget in Semantics with provided semanticsLabel
  - Announce month/year on navigation
  - Purpose: Provide overall calendar context for screen readers
  - _Leverage: Flutter Semantics widget_
  - _Requirements: 11.3, 11.9, 11.12_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer with accessibility expertise | Task: Add Semantics wrapper to MCalMonthView using semanticsLabel parameter, and use SemanticsService.announce() to announce month/year on navigation | Restrictions: Respect existing semantic labels on children | _Leverage: Flutter Semantics, SemanticsService | _Requirements: 11.3, 11.9, 11.12 | Success: Screen readers announce overall calendar label and month changes | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

## Phase 15: Performance Optimizations

- [x] 25. Add RepaintBoundary to day cells
  - File: lib/src/widgets/mcal_month_view.dart
  - Wrap each _DayCellWidget in RepaintBoundary
  - Purpose: Isolate cell repaints for better performance
  - _Leverage: Flutter RepaintBoundary_
  - _Requirements: 10.2_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer with performance expertise | Task: Wrap each _DayCellWidget in RepaintBoundary to isolate repaints | Restrictions: Keep widget tree depth minimal | _Leverage: Flutter RepaintBoundary | _Requirements: 10.2 | Success: Cell repaints are isolated, no visual regressions | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 26. Cache theme resolution and date calculations
  - File: lib/src/widgets/mcal_month_view.dart
  - Cache theme resolution in build() and pass to children
  - Cache month grid dates (only recalculate when month changes)
  - Use const constructors where possible
  - Purpose: Reduce unnecessary calculations during rebuilds
  - _Leverage: Existing _resolveTheme() method_
  - _Requirements: 10.4, 10.8, 10.11, 10.12_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer with performance expertise | Task: Cache theme resolution at the top of build() and pass to children instead of resolving multiple times, cache generateMonthDates result in state (only recalculate when displayDate month changes), and add const to constructors where possible | Restrictions: Maintain correct behavior when theme or month changes | _Leverage: lib/src/widgets/mcal_month_view.dart _resolveTheme, date_utils | _Requirements: 10.4, 10.8, 10.11, 10.12 | Success: Reduced calculations per build, no functional regressions | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

## Phase 16: Integration Testing

- [x] 27. Write integration tests for multi-view synchronization
  - File: test/integration/mcal_month_view_integration_test.dart
  - Test two MCalMonthViews sharing one controller
  - Test displayDate synchronization
  - Test focusedDate synchronization
  - Test navigation affects both views
  - Purpose: Ensure multi-view architecture works correctly
  - _Leverage: Existing integration test patterns_
  - _Requirements: 3.26, 3.27, 3.28_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Test Engineer | Task: Write integration tests with two MCalMonthView widgets sharing one MCalEventController, verifying that displayDate and focusedDate changes affect both views | Restrictions: Test realistic scenarios from requirements | _Leverage: test/integration/mcal_month_view_integration_test.dart | _Requirements: 3.26, 3.27, 3.28 | Success: Multi-view synchronization is verified through tests | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 28. Write accessibility integration tests
  - File: test/accessibility/mcal_month_view_accessibility_test.dart
  - Test semantic labels are present and correct
  - Test keyboard navigation accessibility
  - Test focus announcements
  - Purpose: Ensure calendar is accessible
  - _Leverage: Existing accessibility test patterns, Flutter test semantics_
  - _Requirements: 11.1-11.13_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Test Engineer with accessibility expertise | Task: Write accessibility tests verifying semantic labels, keyboard navigation accessibility, and focus state announcements | Restrictions: Use Flutter's semantics testing APIs | _Leverage: test/accessibility/mcal_month_view_accessibility_test.dart | _Requirements: 11.1-11.13 | Success: Accessibility requirements are verified through tests | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

## Phase 17: Example App Updates

- [x] 29. Update example app to demonstrate new features
  - File: example/lib/main.dart, example/lib/screens/main_screen.dart
  - Add keyboard navigation demonstration
  - Add hover feedback demonstration (desktop/web)
  - Add week numbers toggle
  - Add maxVisibleEvents slider
  - Add animation toggle
  - Demonstrate multi-view synchronization
  - Purpose: Showcase new features for developers
  - _Leverage: Existing example app structure_
  - _Requirements: All_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Update example app to demonstrate new features: keyboard navigation, hover callbacks, week numbers, maxVisibleEvents, animations, and multi-view synchronization with two calendars sharing a controller | Restrictions: Keep example clear and educational | _Leverage: example/lib existing structure | _Requirements: All | Success: Example app demonstrates all new features | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_

- [x] 30. Update package README with new features
  - File: README.md
  - Document new parameters and their usage
  - Add keyboard navigation section
  - Add hover support section
  - Add multi-view synchronization example
  - Add week numbers example
  - Purpose: Help developers understand and use new features
  - _Leverage: Existing README structure_
  - _Requirements: All_
  - _Prompt: Implement the task for spec month-view-enhancements, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Technical Writer | Task: Update README.md to document all new features with code examples, including keyboard navigation, hover support, displayDate/focusedDate, week numbers, animations, and loading/error states | Restrictions: Follow existing README style, keep examples concise | _Leverage: README.md existing structure | _Requirements: All | Success: README documents all new features clearly | After completing the implementation, mark this task as in-progress in tasks.md, log the implementation with log-implementation tool, then mark as complete_
