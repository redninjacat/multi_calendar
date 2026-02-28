# Tasks Document

## Phase 0: Fix Compilation Errors (COMPLETED)

- [x] 0.1. Delete duplicate mcal_multi_day_renderer.dart file
  - File: lib/src/widgets/mcal_multi_day_renderer.dart (DELETE)
  - Delete the duplicate untracked file causing compilation errors
  - Purpose: Resolve compilation errors from incomplete Phase 0 of day-view spec
  - _Leverage: git status to verify file is untracked_
  - _Requirements: N/A (prerequisite fix)_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: DevOps Engineer | Task: Delete the duplicate file lib/src/widgets/mcal_multi_day_renderer.dart that was left over from previous refactoring, verify compilation succeeds | Restrictions: Do not modify mcal_month_multi_day_renderer.dart (the correct file), ensure analyzer reports no errors after deletion | Success: File deleted, dart analyze reports zero errors in lib/src/widgets/ | Instructions: Mark task 0.1 as [-] in tasks.md, implement changes, run dart analyze to verify, then use log-implementation to record the fix with artifacts, finally mark task as [x] in tasks.md_

## Phase 1: Time Legend Visual Enhancement (COMPLETED)

- [x] 1.1. Add theme properties for time legend tick marks
  - File: lib/src/styles/mcal_theme.dart
  - Add four new nullable properties: showTimeLegendTicks (bool), timeLegendTickColor (Color), timeLegendTickWidth (double), timeLegendTickLength (double)
  - Add properties to constructor, copyWith, lerp, and fromTheme methods
  - Purpose: Enable theme-based configuration of time legend tick marks
  - _Leverage: Existing Day View theme properties as patterns (timeLegendWidth, hourGridlineColor)_
  - _Requirements: 1_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Theme Developer | Task: Add four new theme properties for time legend tick marks following Requirement 1, using existing Day View properties as patterns, add comprehensive dartdoc comments with examples | Restrictions: Must follow existing theme property patterns, include properties in constructor/copyWith/lerp/fromTheme, use Material 3 defaults (outline color with 30% opacity, 1.0 width, 8.0 length) | Success: Properties added with full documentation, defaults set in fromTheme factory, lerp interpolates correctly, copyWith preserves null values | Instructions: Mark task 1.1 as [-] in tasks.md, add properties to MCalThemeData, ensure all methods updated, then use log-implementation with artifacts including the theme properties added, mark task as [x]_

- [x] 1.2. Create _TimeLegendTickPainter CustomPainter class
  - File: lib/src/widgets/mcal_day_view.dart (add after _TimeLegendColumn class, around line 4389)
  - Implement CustomPainter that draws horizontal tick marks at each hour boundary
  - Handle LTR (ticks from right edge) and RTL (ticks from left edge) positioning
  - Purpose: Efficiently render tick marks on time legend
  - _Leverage: timeToOffset utility function, CustomPainter pattern from _GridlinesPainter_
  - _Requirements: 1_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Graphics Developer | Task: Create CustomPainter class that draws time legend tick marks following Requirement 1, using timeToOffset utility to calculate positions, handle both LTR and RTL edge positioning | Restrictions: Must use CustomPainter for performance, do not rebuild on every frame, shouldRepaint must check all relevant properties | Success: Painter draws tick marks at exact hour boundaries, correct edge positioning for LTR/RTL, shouldRepaint optimized, no performance impact (<1ms paint time) | Instructions: Mark task 1.2 as [-], implement _TimeLegendTickPainter with paint and shouldRepaint methods, use log-implementation with class artifact details, mark as [x]_

- [x] 1.3. Integrate tick painter into _TimeLegendColumn widget
  - File: lib/src/widgets/mcal_day_view.dart (modify _TimeLegendColumn.build, lines 4263-4293)
  - Add CustomPaint layer to Stack with _TimeLegendTickPainter behind time labels
  - Check theme.showTimeLegendTicks and isRTL before rendering
  - Purpose: Display tick marks in time legend
  - _Leverage: _TimeLegendTickPainter from task 1.2, theme properties from task 1.1, MCalLocalizations.isRTL_
  - _Requirements: 1_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Widget Developer | Task: Integrate CustomPaint layer with _TimeLegendTickPainter into _TimeLegendColumn Stack following Requirement 1, conditionally render based on theme.showTimeLegendTicks, pass correct RTL flag | Restrictions: Painter must be first child in Stack (behind labels), must check isRTL using MCalLocalizations, must respect showTimeLegendTicks theme property | Success: Ticks render correctly behind labels, conditional rendering works, LTR/RTL positioning correct, theme customization effective | Instructions: Mark 1.3 as [-], modify build method to add CustomPaint conditionally, test with different themes, use log-implementation with integration artifact, mark as [x]_

## Phase 2: Modern Localization Infrastructure (COMPLETED)

- [x] 2.1. Configure Flutter gen-l10n in package
  - File: l10n.yaml (create at project root)
  - Create configuration file specifying arb-dir, template file, output class name
  - Purpose: Enable Flutter's official localization code generation
  - _Leverage: Flutter gen-l10n documentation, pubspec.yaml already has flutter: generate: true_
  - _Requirements: 2_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter i18n Developer | Task: Create l10n.yaml configuration file following Requirement 2 to enable gen-l10n code generation, specify arb-dir as lib/l10n, template as app_en.arb, output class as MCalLocalizations | Restrictions: Must use exact configuration format, arb-dir must match existing directory, nullable-getter should be false | Success: l10n.yaml exists at root, configuration is valid, flutter gen-l10n command succeeds | Instructions: Mark 2.1 as [-], create l10n.yaml with correct configuration, run flutter gen-l10n to verify, use log-implementation, mark as [x]_

- [x] 2.2. Create and update ARB files for 5 languages
  - Files: lib/l10n/app_en.arb (update), app_es.arb (create), app_es_MX.arb (update), app_fr.arb (create), app_ar.arb (create), app_he.arb (create)
  - Extract all strings from mcal_localization.dart Maps
  - Add new strings for Day View navigation (previousDay, nextDay, currentTime, scheduleFor, timeGrid, doubleTapToCreateEvent)
  - Translate to Spanish, French, Arabic, Hebrew with proper locale-specific formatting
  - Purpose: Provide complete translations for all supported languages
  - _Leverage: Existing app_en.arb and app_es_MX.arb as starting point, example app ARB files for reference_
  - _Requirements: 2, 3_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Localization Engineer with multilingual expertise | Task: Create comprehensive ARB files for 5 languages following Requirements 2 and 3, extracting strings from mcal_localization.dart, adding new Day View strings, providing natural translations | Restrictions: All ARB files must have identical key sets, placeholder syntax must be correct, RTL languages must use natural phrasing, must include @placeholders metadata for parameterized strings | Success: 6 ARB files created (en, es, es_MX, fr, ar, he) with ~50 keys each, all keys present in all files, translations reviewed for naturalness, flutter gen-l10n generates without errors | Instructions: Mark 2.2 as [-], create/update all ARB files, run flutter gen-l10n to verify, use log-implementation with file list, mark as [x]_

- [x] 2.3. Update MCalLocalizations class with all 5 languages
  - File: lib/src/utils/mcal_localization.dart
  - Add French, Arabic, and Hebrew string Maps (_frenchStrings, _arabicStrings, _hebrewStrings)
  - Update _getLocalizedStrings method to handle all 5 languages
  - Update supportedLocales list to include all locales
  - Purpose: Temporary bridge until gen-l10n integration complete; support all languages in current system
  - _Leverage: Existing _englishStrings and _spanishStrings as templates_
  - _Requirements: 2, 3_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Extend MCalLocalizations class to support French, Arabic, and Hebrew following Requirements 2 and 3, add complete string Maps matching English keys, update locale detection logic | Restrictions: This is temporary code that will be deleted later, must maintain exact key parity with English, switch statement must handle all 5 languages | Success: All 5 languages supported, strings match ARB files, supportedLocales updated, locale detection works for all language codes | Instructions: Mark 2.3 as [-], add 3 new string Maps with all translations, update _getLocalizedStrings switch, update supportedLocales, use log-implementation, mark as [x]_

- [x] 2.4. Replace hardcoded strings in Day View with localized versions
  - File: lib/src/widgets/mcal_day_view.dart
  - Replace hardcoded strings: 'Previous day' (lines 3917, 3923, 3981, 3987, 4023, 4029, 4031, 4037)
  - Replace 'Next day' (lines 3959, 3965)
  - Replace 'Current time: $formattedTime' (line 4558)
  - Replace 'Schedule for $dateStr' (lines 3358, 3367)
  - Replace 'Double tap to create event' (line 3359)
  - Replace 'Time grid' (line 4902)
  - Purpose: Eliminate all hardcoded English text from core package
  - _Leverage: MCalLocalizations.getLocalizedString method, existing locale variables_
  - _Requirements: 2, 3_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter i18n Developer | Task: Replace all hardcoded English strings in Day View with localized versions following Requirements 2 and 3, use MCalLocalizations.getLocalizedString with proper parameter substitution for strings with placeholders | Restrictions: Must not hardcode any English text in Semantics labels or tooltips, must handle parameter substitution correctly (replaceAll for placeholders), must pass locale parameter consistently | Success: Zero hardcoded English strings in Day View, all labels use localization, parameter substitution works correctly, tooltips display in correct language | Instructions: Mark 2.4 as [-], search for all hardcoded strings, replace with getLocalizedString calls, verify in Arabic/Hebrew, use log-implementation with files modified, mark as [x]_

## Phase 3: RTL Layout Corrections (COMPLETED)

- [x] 3.1. Verify time legend positioning for RTL (already correct)
  - File: lib/src/widgets/mcal_day_view.dart (lines 3757-3797)
  - Verify conditional rendering places time legend on right for RTL (_isRTL check)
  - Purpose: Confirm RTL time legend positioning is correct
  - _Leverage: Existing _isRTL method, conditional rendering logic_
  - _Requirements: 4_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Layout Developer | Task: Verify time legend positioning follows Requirement 4 with RTL detection via _isRTL(context), ensure correct placement (left for LTR, right for RTL) | Restrictions: Do not break existing implementation, verify both LTR and RTL modes | Success: Time legend appears on right side when locale is Arabic or Hebrew, left side for English/Spanish/French, verified visually in example app | Instructions: Mark 3.1 as [-], review code to verify logic is correct, test in app with Arabic/Hebrew, use log-implementation noting verification, mark as [x]_

- [x] 3.2. Update navigator button tooltips to use localized strings
  - File: lib/src/widgets/mcal_day_view.dart (lines 3907-4036, _buildLTRButtons and _buildRTLButtons)
  - Replace all 'Previous day' and 'Next day' hardcoded tooltip strings with localized versions
  - Purpose: Fix English tooltips appearing in RTL demos
  - _Leverage: MCalLocalizations.getLocalizedString, locale parameter available in methods_
  - _Requirements: 4_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter i18n Developer | Task: Replace hardcoded navigator button tooltips with localized versions following Requirement 4, update both _buildLTRButtons and _buildRTLButtons methods | Restrictions: Must localize all Semantics labels and tooltips, must use correct locale parameter, arrows must remain correct for direction (left=prev in LTR, left=next in RTL) | Success: All navigator tooltips use localization, Arabic tooltips display in Arabic, Hebrew tooltips in Hebrew, arrows work correctly in both directions | Instructions: Mark 3.2 as [-], update 6 tooltip strings to use getLocalizedString, verify in example app, use log-implementation, mark as [x]_

## Phase 4: Hebrew Language Support (COMPLETED)

- [x] 4.1. Add Hebrew translations to example app
  - Files: example/lib/l10n/app_he.arb (create), example/lib/screens/main_screen.dart (modify language menu)
  - Create comprehensive Hebrew ARB file with all ~80 example app strings
  - Add Hebrew option to language selection menu
  - Purpose: Enable Hebrew language in example app for testing
  - _Leverage: example/lib/l10n/app_ar.arb as RTL reference, existing language menu pattern_
  - _Requirements: 3_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Localization Specialist | Task: Create Hebrew translations for example app following Requirement 3, translate all strings naturally, add Hebrew to language menu with "(RTL)" indicator | Restrictions: Translations must be natural Hebrew, must include all keys from app_en.arb, menu item must indicate RTL status, locale must be Locale('he') | Success: app_he.arb created with all translations, Hebrew option appears in language menu, selecting Hebrew switches entire app to Hebrew with RTL layout | Instructions: Mark 4.1 as [-], create app_he.arb with ~80 keys, add menu item in main_screen.dart, test in app, use log-implementation, mark as [x]_

## Phase 5: Example App Organization (COMPLETED)

- [x] 5.1. Reorder Day View tabs (Features first)
  - File: example/lib/views/day_view/day_view_showcase.dart
  - Move Features Demo to first position in _buildStyles method
  - Update children list in TabBarView to match new order
  - Update TabController length from 10 to 9
  - Purpose: Improve example app UX by showcasing features first
  - _Leverage: Existing _buildStyles method and TabBarView structure_
  - _Requirements: 5_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter UI Developer | Task: Reorder Day View tabs following Requirement 5 to place Features first, update both _buildStyles array and TabBarView children array to match | Restrictions: Order must be: Features, Default, Classic, Modern, Colorful, Minimal, Stress Test, Theme Customization, Accessibility (9 tabs total), TabController length must match tab count | Success: Features tab is first, all tabs render correctly, tab navigation works, no IndexError | Instructions: Mark 5.1 as [-], reorder _buildStyles array, reorder TabBarView children, update TabController length, test tab navigation, use log-implementation, mark as [x]_

- [x] 5.2. Remove RTL Demo tab
  - File: example/lib/views/day_view/day_view_showcase.dart (remove RtlDemoDayStyle class and references)
  - Delete RtlDemoDayStyle class (lines ~193-227)
  - Delete _RtlDemoDayViewContent and _RtlDemoDayViewContentState classes (lines ~230-358)
  - Remove from _buildStyles and TabBarView
  - Purpose: Remove redundant RTL demo (users can test via app-wide locale selector)
  - _Leverage: N/A (deletion task)_
  - _Requirements: 5_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Developer | Task: Remove RTL Demo tab completely following Requirement 5, delete RtlDemoDayStyle class and all related code | Restrictions: Must not break other tabs, ensure TabController length updated in task 5.1, verify RTL still testable via language menu | Success: RtlDemoDayStyle class deleted, no references remain, app compiles without errors, RTL works when Arabic/Hebrew selected via language menu | Instructions: Mark 5.2 as [-], delete ~166 lines of RtlDemo code, verify app works, use log-implementation with filesModified/linesRemoved, mark as [x]_

## Phase 6: Enhanced Features Demo (COMPLETED)

- [x] 6.1. Create control panel state management
  - File: example/lib/views/day_view/styles/features_demo_style.dart (expand significantly)
  - Add StatefulWidget with state variables for all customizable options
  - State: hourHeight, gridlineInterval, snapToTimeSlots, showTimeLegendTicks, timeLegendTickColor, timeLegendTickLength, showLunchRegion, showAfterHoursRegion, enableDragDrop, enableResize, etc.
  - Purpose: Manage state for interactive control panel
  - _Leverage: example/lib/views/month_view/styles/features_demo_style.dart as comprehensive template (~2451 lines)_
  - _Requirements: 6_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter State Management Developer | Task: Create comprehensive state management for Features demo following Requirement 6, model after Month View's features_demo_style.dart with ~20 state variables for all customizable Day View properties | Restrictions: Must use StatefulWidget, state must be mutable and trigger rebuilds, initial values must match default theme, must organize state logically by category (theme, gridlines, interactions, regions) | Success: State class created with ~20 variables, setState triggers rebuilds, all Day View customization options have corresponding state, organized logically | Instructions: Mark 6.1 as [-], convert to StatefulWidget, add state variables, use log-implementation with component artifact, mark as [x]_

- [x] 6.2. Build interactive control panel UI
  - File: example/lib/views/day_view/styles/features_demo_style.dart (continue from 6.1)
  - Create collapsible sections: Theme Properties, Gridlines & Intervals, Interactions, Special Time Regions, Presets
  - Add controls: Sliders (hourHeight 60-120, tickLength 4-16), ColorPicker widgets, Dropdowns (gridline interval), Toggles (boolean properties)
  - Purpose: Provide interactive UI for customizing all Day View properties
  - _Leverage: Month View's control panel as template, Material 3 components (Slider, Switch, DropdownButton, ExpansionPanel)_
  - _Requirements: 6_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter UI/UX Developer | Task: Build comprehensive control panel UI following Requirement 6, create collapsible sections with sliders, toggles, color pickers, dropdowns for all customization options, model after Month View's controls | Restrictions: Must use Material 3 components, controls must be clearly labeled, sections must be collapsible, layout must be responsive, must handle setState correctly | Success: Control panel renders with ~30 interactive controls organized in 5 collapsible sections, all controls update state and trigger Day View rebuilds, UI is intuitive and well-organized | Instructions: Mark 6.2 as [-], build ExpansionPanels with all controls, test interactivity, use log-implementation with component artifact, mark as [x]_

- [x] 6.3. Connect controls to Day View theme properties
  - File: example/lib/views/day_view/styles/features_demo_style.dart (continue from 6.2)
  - Create MCalThemeData from state variables
  - Pass theme to MCalDayView wrapped in MCalTheme widget
  - Handle special time regions and blocked time regions based on toggles
  - Purpose: Apply control panel settings to live Day View demonstration
  - _Leverage: MCalTheme widget, MCalThemeData.copyWith, special time region builders_
  - _Requirements: 6_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Integration Developer | Task: Connect control panel state to Day View theme and configuration following Requirement 6, build MCalThemeData from state, pass to MCalDayView via MCalTheme wrapper, conditionally render special regions | Restrictions: Must use MCalTheme wrapper (not inline theme), theme must rebuild when state changes, special regions must conditionally appear based on toggles, all theme properties must be configurable | Success: Changing any control immediately updates Day View, theme properties all configurable, special regions toggle on/off, no performance issues with frequent rebuilds | Instructions: Mark 6.3 as [-], wire state to theme, add MCalTheme wrapper, test all controls affect display, use log-implementation with integration artifact, mark as [x]_

- [x] 6.4. Add preset configurations dropdown
  - File: example/lib/views/day_view/styles/features_demo_style.dart (continue from 6.3)
  - Create preset configurations: Compact (60px height, 30min intervals), Standard (80px, 15min), Spacious (100px, 15min), Minimal (ticks off, minimal gridlines), High Contrast (bold colors, thick lines)
  - Add dropdown to select preset and setState to apply all preset values
  - Purpose: Allow users to quickly explore common configurations
  - _Leverage: Month View's preset pattern if it exists_
  - _Requirements: 6_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter UX Developer | Task: Create preset configurations dropdown following Requirement 6 with 5+ presets that set multiple theme values at once for common use cases | Restrictions: Presets must represent realistic use cases, must set multiple values per preset, dropdown must be prominent in control panel, applying preset must be smooth | Success: 5 presets created and functional, selecting preset updates all relevant state variables, UI updates smoothly, presets demonstrate range of customization | Instructions: Mark 6.4 as [-], define 5 preset configurations, add dropdown, wire to setState, test all presets, use log-implementation, mark as [x]_

- [x] 6.5. Add code snippet panel (optional)
  - File: example/lib/views/day_view/styles/features_demo_style.dart (continue from 6.4)
  - Add optional side panel or bottom sheet showing Dart code for current configuration
  - Generate MCalThemeData construction code from current state
  - Purpose: Help developers copy theme configuration code
  - _Leverage: String interpolation for code generation_
  - _Requirements: 6_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Developer Tools Engineer | Task: Add code snippet panel following Requirement 6 that shows generated Dart code for current theme configuration, allow copy to clipboard | Restrictions: Code must be valid Dart, only include non-null properties, format with proper indentation, keep panel non-intrusive (collapsible or in drawer) | Success: Code panel displays valid MCalThemeData construction, updates when state changes, code is properly formatted and copyable, panel doesn't obstruct view | Instructions: Mark 6.5 as [-], add code generation logic, create panel UI, add copy button, use log-implementation, mark as [x]_

## Phase 7: Refactor Theme Architecture (NEW WORK)

- [x] 7.1. Create MCalDayThemeData class
  - File: lib/src/styles/mcal_day_theme_data.dart (create new file)
  - Extract all Day View specific properties from MCalThemeData into new class
  - Implement constructor, copyWith, lerp methods
  - Add factory MCalDayThemeData.defaults(ThemeData) with Material 3 defaults
  - Purpose: Isolate Day View theme properties for better organization
  - _Leverage: Existing MCalThemeData structure as template_
  - _Requirements: 7_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Theme Architect | Task: Create MCalDayThemeData class following Requirement 7 with ~30 Day View properties (timeLegendWidth, hourGridlineColor, currentTimeIndicatorColor, etc.), implement all required methods | Restrictions: Must include all properties from design doc section, lerp must interpolate correctly, copyWith must handle null preservation, defaults must match existing MCalThemeData.fromTheme values | Success: MCalDayThemeData class fully functional, all methods implemented, defaults match current behavior, compiles without errors | Instructions: Mark 7.1 as [-], create new file with complete class, implement constructor/copyWith/lerp/defaults, use log-implementation with class artifact, mark as [x]_

- [x] 7.2. Create MCalMonthThemeData class
  - File: lib/src/styles/mcal_month_theme_data.dart (create new file)
  - Extract all Month View specific properties from MCalThemeData into new class
  - Implement constructor, copyWith, lerp methods
  - Add factory MCalMonthThemeData.defaults(ThemeData) with Material 3 defaults
  - Purpose: Isolate Month View theme properties for better organization
  - _Leverage: Existing MCalThemeData structure, MCalDayThemeData from task 7.1 as template_
  - _Requirements: 7_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Theme Architect | Task: Create MCalMonthThemeData class following Requirement 7 with ~20 Month View properties (weekdayHeaderTextStyle, eventTileHeight, dateLabelPosition, overflowIndicatorHeight, etc.), implement all required methods | Restrictions: Must include all properties from design doc section, follow same patterns as MCalDayThemeData, lerp/copyWith must work identically, defaults must match existing behavior | Success: MCalMonthThemeData class fully functional, all methods implemented, defaults match current behavior, consistent with MCalDayThemeData patterns | Instructions: Mark 7.2 as [-], create new file mirroring MCalDayThemeData structure, implement all methods, use log-implementation with class artifact, mark as [x]_

- [x] 7.3. Refactor MCalThemeData to use nested theme classes
  - File: lib/src/styles/mcal_theme.dart (major refactoring)
  - Add monthTheme and dayTheme properties of types MCalMonthThemeData? and MCalDayThemeData?
  - Keep shared properties in root (cellBackgroundColor, eventTileBackgroundColor, navigatorTextStyle, etc.)
  - Update constructor to accept nested themes
  - Update copyWith to handle nested themes
  - Update lerp to interpolate nested themes
  - Update fromTheme to create nested default themes
  - Purpose: Organize theme properties into view-specific nested structure
  - _Leverage: MCalDayThemeData and MCalMonthThemeData from tasks 7.1-7.2_
  - _Requirements: 7_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Architecture Refactoring Specialist | Task: Refactor MCalThemeData to use nested theme classes following Requirement 7, add monthTheme and dayTheme properties, remove view-specific properties from root (they move to nested classes), update all methods | Restrictions: Shared properties stay in root, view-specific properties move to nested classes, must maintain all existing functionality through new structure, fromTheme must instantiate nested defaults | Success: MCalThemeData has nested monthTheme/dayTheme properties, all methods updated, no view-specific properties in root, compiles without errors | Instructions: Mark 7.3 as [-], add nested properties, update constructor/copyWith/lerp/fromTheme, use log-implementation with refactoring details, mark as [x]_

- [x] 7.4. Update MCalDayView to use nested theme properties
  - File: lib/src/widgets/mcal_day_view.dart
  - Replace all direct theme property access (theme.timeLegendWidth) with nested access (theme.dayTheme?.timeLegendWidth ?? theme.timeLegendWidth for transition)
  - Update all ~50 theme property references throughout file
  - Purpose: Adapt Day View to use new nested theme structure
  - _Leverage: Find/replace for common patterns, null coalescing for smooth transition_
  - _Requirements: 7_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Refactoring Engineer | Task: Update MCalDayView to access theme properties through theme.dayTheme following Requirement 7, update all theme property references throughout the 5000+ line file | Restrictions: Must use null coalescing (theme.dayTheme?.property ?? fallback), must not break existing functionality, must update all occurrences consistently, verify no missed references | Success: All theme properties accessed through dayTheme, null handling prevents crashes, Day View renders identically to before refactoring, analyzer reports no errors | Instructions: Mark 7.4 as [-], use grep to find all theme property access, update each to use nested structure, test Day View thoroughly, use log-implementation with statistics, mark as [x]_

- [x] 7.5. Update MCalMonthView to use nested theme properties
  - File: lib/src/widgets/mcal_month_view.dart
  - Replace all direct theme property access with nested access (theme.monthTheme?.property)
  - Update all ~40 theme property references throughout file
  - Purpose: Adapt Month View to use new nested theme structure
  - _Leverage: Patterns from task 7.4 (MCalDayView), grep to find all references_
  - _Requirements: 7_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Refactoring Engineer | Task: Update MCalMonthView to access theme properties through theme.monthTheme following Requirement 7, update all theme property references throughout the 7000+ line file | Restrictions: Must use null coalescing, must not break functionality, must update all occurrences consistently, verify no missed references | Success: All theme properties accessed through monthTheme, null handling prevents crashes, Month View renders identically to before, analyzer reports no errors | Instructions: Mark 7.5 as [-], grep for theme property access, update each reference, test Month View thoroughly, use log-implementation with statistics, mark as [x]_

- [x] 7.6. Update example app theme configurations
  - Files: example/lib/views/day_view/styles/*.dart (all style files), example/lib/views/month_view/styles/*.dart (all style files)
  - Update all theme instantiations to use nested structure
  - Verify all examples still work with refactored theme API
  - Purpose: Ensure example app demonstrates new theme structure
  - _Leverage: Grep to find all MCalThemeData( instantiations_
  - _Requirements: 7_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Example Developer | Task: Update all example app theme configurations to use nested structure following Requirement 7, find all MCalThemeData instantiations and refactor to use monthTheme/dayTheme | Restrictions: Must update every theme instantiation, must test every example style, verify visual appearance unchanged | Success: All example styles updated, all tabs render correctly, no visual regressions, theme customizations still work | Instructions: Mark 7.6 as [-], grep for MCalThemeData\(, update ~20 instantiations across styles, test all tabs, use log-implementation with files modified, mark as [x]_

- [x] 7.7. Update main package export
  - File: lib/multi_calendar.dart
  - Export new MCalDayThemeData and MCalMonthThemeData classes
  - Verify all public API exports are correct
  - Purpose: Make nested theme classes available to package consumers
  - _Leverage: Existing export structure_
  - _Requirements: 7_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Package API Developer | Task: Export new theme classes following Requirement 7, add exports for MCalDayThemeData and MCalMonthThemeData | Restrictions: Must export from correct file paths, maintain alphabetical order if used, do not export internal implementation details | Success: Both new theme classes exported, package consumers can import them, no compilation errors | Instructions: Mark 7.7 as [-], add two export lines, verify imports work, use log-implementation, mark as [x]_

## Phase 8: Month View Double-Tap Handlers (NEW WORK)

- [x] 8.1. Add double-tap callback parameters to MCalMonthView
  - File: lib/src/widgets/mcal_month_view.dart
  - Add two new callback parameters: onCellDoubleTap and onEventDoubleTap
  - Add to constructor and as final properties
  - Purpose: Enable double-tap gesture handling in Month View API
  - _Leverage: Existing onCellTap and onEventTap as patterns for signature design_
  - _Requirements: 8_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter API Developer | Task: Add double-tap callback parameters to MCalMonthView following Requirement 8, create MCalCellDoubleTapDetails and MCalEventDoubleTapDetails classes with date/event/position/globalPosition fields | Restrictions: Callback signatures must match single-tap patterns, detail classes must include localPosition and globalPosition, must be optional (nullable), must include dartdoc comments with examples | Success: Two callback parameters added, detail classes created, parameters documented, compiles without errors | Instructions: Mark 8.1 as [-], add parameters and detail classes, document with dartdoc, use log-implementation with API changes, mark as [x]_

- [x] 8.2. Implement double-tap detection in month cells
  - File: lib/src/widgets/mcal_month_view.dart (find GestureDetector wrapping date cells)
  - Add onDoubleTapDown and onDoubleTap handlers to existing GestureDetector
  - Store tap position in State variable (_lastDoubleTapDownPosition)
  - Invoke onCellDoubleTap callback with MCalCellDoubleTapDetails
  - Purpose: Detect double-taps on empty date cells
  - _Leverage: Day View's double-tap implementation (mcal_day_view.dart lines 3344-3362) as exact template_
  - _Requirements: 8_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Gesture Developer | Task: Implement double-tap detection for date cells following Requirement 8, add onDoubleTapDown/onDoubleTap to GestureDetector, store position in State, invoke callback with details, use Day View implementation as exact template | Restrictions: Must not break existing tap/long-press handlers, must distinguish double-tap from single-tap timing, position must be captured from onDoubleTapDown (onDoubleTap doesn't provide position) | Success: Double-tapping empty cell triggers callback with correct date and position, single-tap still works, long-press still works, no gesture conflicts | Instructions: Mark 8.2 as [-], add State variable for position, add gesture handlers, test all gesture types, use log-implementation, mark as [x]_

- [x] 8.3. Implement double-tap detection on event tiles
  - File: lib/src/widgets/mcal_month_view.dart (find GestureDetector wrapping event tiles)
  - Add onDoubleTapDown and onDoubleTap to event tile GestureDetector
  - Invoke onEventDoubleTap callback with MCalEventDoubleTapDetails
  - Purpose: Detect double-taps on event tiles
  - _Leverage: Pattern from task 8.2, Day View's event double-tap if it exists_
  - _Requirements: 8_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Gesture Developer | Task: Implement double-tap detection for event tiles following Requirement 8, add gesture handlers to event tile GestureDetector, invoke callback with event and position details | Restrictions: Must not break existing onEventTap/onEventLongPress, must work with drag-and-drop enabled, position must be accurate, must handle multi-day events correctly | Success: Double-tapping event triggers callback with correct event and position, single-tap works, long-press works, drag still works, no conflicts | Instructions: Mark 8.3 as [-], add double-tap handlers to event tiles, test with various event types, use log-implementation, mark as [x]_

- [x] 8.4. Update example app to demonstrate double-tap
  - Files: example/lib/views/month_view/styles/features_demo_style.dart (or appropriate demo file)
  - Wire up onCellDoubleTap and onEventDoubleTap callbacks
  - Show snackbar or dialog when double-tap detected
  - Purpose: Demonstrate new double-tap functionality in example app
  - _Leverage: Day View examples showing double-tap usage_
  - _Requirements: 8_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Example Developer | Task: Demonstrate Month View double-tap handlers following Requirement 8, wire callbacks to show user feedback (snackbar/dialog), provide clear example code | Restrictions: Feedback must be clear and non-intrusive, must show both cell and event double-tap, example code should be instructive | Success: Double-tapping dates/events shows clear feedback, example demonstrates proper callback usage, developers can copy pattern | Instructions: Mark 8.4 as [-], add double-tap handlers with snackbar feedback, test in example app, use log-implementation, mark as [x]_

## Phase 9: Comprehensive Testing (NEW WORK)

- [x] 9.1. Create unit tests for MCalDayThemeData
  - File: test/styles/mcal_day_theme_data_test.dart (create)
  - Test constructor, copyWith, lerp, defaults factory
  - Test null handling, equality, property preservation
  - Purpose: Ensure Day View theme class works correctly
  - _Leverage: Existing theme tests if they exist, flutter_test framework_
  - _Requirements: 7_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Test Engineer | Task: Create comprehensive unit tests for MCalDayThemeData following Requirement 7, test all methods (constructor, copyWith, lerp, defaults), verify null handling and edge cases | Restrictions: Must achieve >90% code coverage, test all properties, verify lerp interpolation, test null preservation in copyWith | Success: 50+ test cases covering all methods, edge cases tested, 90%+ coverage, all tests pass | Instructions: Mark 9.1 as [-], write comprehensive test file, run flutter test, use log-implementation with test statistics, mark as [x]_

- [x] 9.2. Create unit tests for MCalMonthThemeData
  - File: test/styles/mcal_month_theme_data_test.dart (create)
  - Test constructor, copyWith, lerp, defaults factory
  - Test null handling, equality, property preservation
  - Purpose: Ensure Month View theme class works correctly
  - _Leverage: test/styles/mcal_day_theme_data_test.dart from task 9.1 as template_
  - _Requirements: 7_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Test Engineer | Task: Create comprehensive unit tests for MCalMonthThemeData following Requirement 7, mirror test structure from MCalDayThemeData tests | Restrictions: Must achieve >90% coverage, test patterns must match MCalDayThemeData tests for consistency, test all properties | Success: 40+ test cases covering all methods, edge cases tested, 90%+ coverage, all tests pass | Instructions: Mark 9.2 as [-], create test file using 9.1 as template, run tests, use log-implementation, mark as [x]_

- [x] 9.3. Create widget tests for time legend tick marks
  - File: test/widgets/time_legend_tick_test.dart (create)
  - Test tick marks render when showTimeLegendTicks = true
  - Test tick marks hidden when showTimeLegendTicks = false
  - Test tick mark customization (color, width, length)
  - Create golden tests for LTR and RTL rendering
  - Purpose: Verify tick marks render correctly in all configurations
  - _Leverage: flutter_test framework, existing widget test patterns, matchesGoldenFile_
  - _Requirements: 1_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Widget Test Engineer | Task: Create widget tests for time legend tick marks following Requirement 1, test rendering, visibility, customization, create golden files for visual regression | Restrictions: Must use testWidgets, verify CustomPaint renders, test both LTR and RTL modes, golden files must be pixel-perfect | Success: 10+ test cases, golden tests pass, ticks verified in LTR/RTL, theme customization tested, all tests pass | Instructions: Mark 9.3 as [-], write widget tests, create golden files, run flutter test, use log-implementation with test count, mark as [x]_

- [x] 9.4. Create widget tests for Month View double-tap handlers
  - File: test/widgets/month_view_double_tap_test.dart (create)
  - Test onCellDoubleTap fires on empty cell double-tap
  - Test onEventDoubleTap fires on event tile double-tap
  - Test single-tap and long-press still work alongside double-tap
  - Verify correct details passed (date, event, positions)
  - Purpose: Ensure double-tap gestures work correctly without conflicts
  - _Leverage: WidgetTester.tap with multiple calls for double-tap, GestureBinding.instance.handlePointerEvent_
  - _Requirements: 8_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Flutter Gesture Test Engineer | Task: Create widget tests for Month View double-tap handlers following Requirement 8, test both cell and event double-tap, verify no conflicts with existing gestures | Restrictions: Must use proper double-tap simulation (two quick taps within 300ms), verify callback arguments, test timing to ensure single-tap doesn't trigger double-tap | Success: 15+ test cases, double-tap callbacks verified, single-tap tested, long-press tested, no gesture conflicts, all tests pass | Instructions: Mark 9.4 as [-], write comprehensive gesture tests, test timing and conflicts, use log-implementation, mark as [x]_

- [x] 9.5. Create integration tests for localization system
  - File: test/integration/localization_test.dart (create)
  - Test all 5 languages render correctly (en, es, fr, ar, he)
  - Test ARB files have matching key sets
  - Test RTL layout for Arabic and Hebrew
  - Test locale fallback (es_MX → es → en)
  - Test parameter substitution in localized strings
  - Purpose: Verify localization infrastructure works end-to-end
  - _Leverage: flutter_test, flutter_localizations, generated MCalLocalizations class_
  - _Requirements: 2, 3, 4_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: i18n Test Engineer | Task: Create comprehensive localization integration tests following Requirements 2, 3, and 4, test all 5 languages, verify ARB completeness, test RTL layouts, verify fallback chain | Restrictions: Must test actual generated classes, verify RTL in real widget tree, test parameter substitution with actual values, must test all 6 locale codes | Success: 25+ test cases covering all languages, ARB key completeness verified, RTL layout tested, fallback verified, parameter substitution tested, all tests pass | Instructions: Mark 9.5 as [-], write integration tests, test all locales in widget tree, use log-implementation, mark as [x]_

- [x] 9.6. Create accessibility tests for localized semantics
  - File: test/accessibility/localized_semantics_test.dart (create)
  - Test semantic labels render in each language
  - Test navigation button tooltips are localized
  - Test screen reader announcements for all languages
  - Purpose: Verify accessibility works across all locales
  - _Leverage: flutter_test semantics testing, SemanticsController_
  - _Requirements: 2, 3, 4_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Accessibility Test Engineer | Task: Create accessibility tests for localized semantics following Requirements 2-4, test screen reader labels in all 5 languages, verify tooltips localized | Restrictions: Must use SemanticsController or tester.getSemantics, test actual semantic tree output, verify labels change with locale | Success: 20+ test cases for semantic labels across languages, tooltips tested, screen reader announcements verified, all tests pass | Instructions: Mark 9.6 as [-], write semantics tests for all locales, verify with SemanticsController, use log-implementation, mark as [x]_

- [x] 9.7. Update existing test suite for theme refactoring
  - Files: test/**/*.dart (all existing tests that use MCalThemeData)
  - Update all existing tests to use nested theme structure
  - Verify all tests still pass after refactoring
  - Purpose: Ensure refactoring doesn't break existing test suite
  - _Leverage: Grep to find all test files using MCalThemeData_
  - _Requirements: 7_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Test Maintenance Engineer | Task: Update all existing tests to use nested theme structure following Requirement 7, find all MCalThemeData usage in tests, update to use monthTheme/dayTheme | Restrictions: Must not change test intent, only update theme property access, must run full test suite to verify, fix any failing tests | Success: All existing tests updated, full test suite passes (998 tests), no test behavior changed (only syntax updated), analyzer reports no errors | Instructions: Mark 9.7 as [-], grep for MCalThemeData in test/, update all usages, run flutter test, use log-implementation with test results, mark as [x]_

## Phase 10: Cleanup and Final Integration (NEW WORK)

- [x] 10.1. Delete old mcal_localization.dart file
  - File: lib/src/utils/mcal_localization.dart (DELETE)
  - Remove the file entirely
  - Verify no imports remain pointing to it
  - Purpose: Clean up deprecated manual localization system
  - _Leverage: Grep to find any remaining imports: grep -r "mcal_localization" lib/_
  - _Requirements: 2_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Code Cleanup Engineer | Task: Delete lib/src/utils/mcal_localization.dart following Requirement 2, verify no remaining imports, confirm generated classes are used everywhere | Restrictions: Must verify no imports remain before deleting, must check both lib/ and test/ directories, must run full analyzer to confirm | Success: File deleted, zero import references remain, analyzer reports no errors, all code uses generated MCalLocalizations | Instructions: Mark 10.1 as [-], grep for imports, delete file if none found, run analyzer, use log-implementation with deletion confirmation, mark as [x]_

- [x] 10.2. Run full test suite and analyzer
  - Files: All project files
  - Run complete test suite: flutter test
  - Run analyzer: dart analyze --fatal-infos
  - Fix any errors or warnings
  - Purpose: Verify all changes work correctly together
  - _Leverage: flutter test, dart analyze, coverage tools_
  - _Requirements: All_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: QA Integration Engineer | Task: Run complete test suite and analyzer covering all requirements, verify 998+ tests pass, verify zero analyzer errors, fix any issues found | Restrictions: Must run with --fatal-infos to catch all issues, must achieve 80%+ test coverage, all tests must pass, zero analyzer errors/warnings | Success: All tests pass (expecting 1050+ with new tests), analyzer reports zero errors, coverage >80%, no regressions detected | Instructions: Mark 10.2 as [-], run flutter test and dart analyze, fix any issues, verify coverage, use log-implementation with test statistics, mark as [x]_

- [x] 10.3. Manual testing in example app (all 5 languages)
  - Files: Example app running on device/simulator
  - Test each language: English, Spanish, French, Arabic, Hebrew
  - Verify RTL layouts for Arabic and Hebrew (time legend right, arrows reversed)
  - Test time legend ticks visible and customizable
  - Test all tabs work correctly in all languages
  - Test Month View double-tap in Features demo
  - Purpose: Verify end-to-end functionality with real user interaction
  - _Leverage: Example app, physical device or simulator_
  - _Requirements: All_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: QA Manual Test Engineer | Task: Perform comprehensive manual testing covering all requirements, test all 5 languages, verify RTL layouts, test all gesture interactions, verify theme customizations work | Restrictions: Must test on actual device or simulator, must test every language thoroughly, must verify visual correctness of RTL, must test all new features (ticks, double-tap, nested themes) | Success: All 5 languages display correctly, RTL layouts correct (time legend right, navigation reversed), time ticks visible, double-tap works in Month View, no visual bugs, smooth performance | Instructions: Mark 10.3 as [-], launch example app, test each language, document findings, take screenshots if issues found, use log-implementation with test results, mark as [x]_

- [x] 10.4. Update package documentation
  - Files: README.md, lib/multi_calendar.dart (dartdoc comments)
  - Document nested theme structure with migration examples
  - Document all 5 supported languages and how to add new ones
  - Document double-tap handlers in Month View
  - Add examples for time legend tick customization
  - Purpose: Ensure developers understand new features and APIs
  - _Leverage: Existing README structure, dartdoc format_
  - _Requirements: All_
  - _Prompt: Implement the task for spec day-view-improvements-and-localization, first run spec-workflow-guide to get the workflow guide then implement the task: Role: Technical Documentation Writer | Task: Update package documentation covering all new features from all requirements, provide clear examples for nested themes, localization, double-tap handlers, theme migration guide | Restrictions: Must include code examples for each major feature, migration guide must be clear for theme refactoring, supported languages must be listed, examples must be copy-pasteable and work | Success: README updated with all new features documented, migration guide clear, code examples provided and tested, dartdoc comments comprehensive | Instructions: Mark 10.4 as [-], update README sections, add dartdoc to new classes, provide examples, use log-implementation, mark as [x]_
