# Requirements: Example App Reorganization

## Introduction

The multi_calendar example app currently has asymmetric tab structures between the Month View (6 tabs) and Day View (9 tabs), with inconsistent control panels, mixed concerns between widget settings and theme settings, and many hardcoded English strings. This spec reorganizes the example app to use a unified 5-tab structure for both views, separates widget configuration from theme customization, adds missing showcase tabs (Stress Test and Accessibility for Month View), fully localizes all user-facing text, and produces a feature disparity analysis document.

## Alignment with Product Vision

The example app is the primary showcase for the multi_calendar package. A well-organized, consistent, and fully-localized example app:
- Demonstrates the package's capabilities effectively to potential adopters
- Serves as a reference implementation for common use patterns
- Validates the package's localization and accessibility features
- Highlights parity (and documented gaps) between Day View and Month View

## Requirements

### REQ-1: Unified Tab Structure

**User Story:** As a developer evaluating the package, I want both the Month View and Day View sections to have the same tab structure so that I can easily compare capabilities and find the showcase I need.

#### Acceptance Criteria

1. WHEN the user navigates to the Month View section, THEN the app SHALL display exactly 5 tabs: **Features**, **Theme**, **Styles**, **Stress Test**, **Accessibility**
2. WHEN the user navigates to the Day View section, THEN the app SHALL display exactly 5 tabs: **Features**, **Theme**, **Styles**, **Stress Test**, **Accessibility**
3. WHEN the user selects any tab, THEN the tab label and order SHALL be identical between Month View and Day View
4. WHEN the app is loaded, THEN the Comparison view SHALL remain unchanged as a third top-level navigation item

### REQ-2: Features Tab — Widget Settings Only

**User Story:** As a developer, I want the Features tab to showcase all widget-level (non-theme) configuration options so that I understand the behavioral capabilities of each view without conflating them with styling.

#### Acceptance Criteria

##### REQ-2.1: Month View Features Tab

1. WHEN the Features tab is displayed for Month View, THEN the control panel SHALL expose ONLY widget-level parameters, including but not limited to:
   - `enableDragToMove` (toggle)
   - `enableDragToResize` (toggle, null/true/false)
   - `enableSwipeNavigation` (toggle)
   - `swipeNavigationDirection` (dropdown: horizontal/vertical)
   - `enableAnimations` (toggle, null/true/false)
   - `animationDuration` (slider)
   - `animationCurve` (dropdown)
   - `showNavigator` (toggle)
   - `showWeekNumbers` (toggle)
   - `showDropTargetTiles` (toggle)
   - `showDropTargetOverlay` (toggle)
   - `dropTargetTilesAboveOverlay` (toggle)
   - `maxVisibleEventsPerDay` (slider)
   - `firstDayOfWeek` (dropdown)
   - `enableKeyboardNavigation` (toggle)
   - `autoFocusOnCellTap` (toggle)
   - `dragEdgeNavigationEnabled` (toggle)
   - `dragEdgeNavigationDelay` (slider)
   - `dragLongPressDelay` (slider)
   - Blackout days (toggle + day-of-week selection) — implemented via `cellInteractivityCallback` + `onDragWillAccept`
2. WHEN the Features tab is displayed for Month View, THEN theme-related settings (tile height, corner radius, border width, spacing, label height, overflow height, colors, text styles) SHALL NOT appear in the control panel
3. WHEN the Features tab is displayed, THEN keyboard navigation instructions SHALL NOT appear (moved to Accessibility tab per REQ-6)

##### REQ-2.2: Day View Features Tab

1. WHEN the Features tab is displayed for Day View, THEN the control panel SHALL expose ONLY widget-level parameters, including but not limited to:
   - `enableDragToMove` (toggle)
   - `enableDragToResize` (toggle, null/true/false)
   - `enableAnimations` (toggle, null/true/false)
   - `animationDuration` (slider)
   - `showNavigator` (toggle)
   - `showCurrentTimeIndicator` (toggle)
   - `showWeekNumber` (toggle)
   - `showDropTargetPreview` (toggle)
   - `showDropTargetOverlay` (toggle)
   - `dropTargetTilesAboveOverlay` (toggle)
   - `startHour` / `endHour` (sliders)
   - `timeSlotDuration` (dropdown: 5/10/15/20/30/60 min)
   - `gridlineInterval` (dropdown)
   - `hourHeight` (slider)
   - `allDaySectionMaxRows` (slider)
   - `allDayToTimedDuration` (slider)
   - `snapToTimeSlots` (toggle)
   - `snapToOtherEvents` (toggle)
   - `snapToCurrentTime` (toggle)
   - `snapRange` (slider)
   - `enableKeyboardNavigation` (toggle)
   - `autoFocusOnEventTap` (toggle)
   - `autoScrollToCurrentTime` (toggle)
   - `dragEdgeNavigationEnabled` (toggle)
   - `dragEdgeNavigationDelay` (slider)
   - `dragLongPressDelay` (slider)
   - Special time regions (toggle)
   - Blackout times (toggle + time range configuration) — implemented via `MCalTimeRegion` with `blockInteraction: true`
2. WHEN the Features tab is displayed for Day View, THEN theme-related settings (gridline colors/widths, time legend width, tick styling, event tile styling) SHALL NOT appear

##### REQ-2.3: Features Tab Interactions

1. WHEN the user interacts with events (tap, long-press, double-tap), THEN the app SHALL show a SnackBar message describing the gesture and event details
2. WHEN the user taps an event, THEN the event detail dialog SHALL open with edit and delete capabilities
3. WHEN the user double-taps an empty cell (Month) or empty space (Day), THEN a SnackBar SHALL confirm the gesture
4. WHEN the user hovers over a cell or event (on desktop), THEN a SnackBar SHALL display the hover target details
5. WHEN the user taps "+N more" overflow indicator (Month View), THEN a bottom sheet SHALL open showing all events for that day
6. WHEN any gesture handler fires that does not currently show a SnackBar, THEN a SnackBar message SHALL be added for that handler
7. WHEN the user changes a setting in the control panel, THEN the calendar SHALL update immediately to reflect the change

### REQ-3: Theme Tab — Theme Settings Only

**User Story:** As a developer, I want the Theme tab to showcase all theme customization options with live preview so that I understand how to style the calendar views.

#### Acceptance Criteria

##### REQ-3.1: Month View Theme Tab

1. WHEN the Theme tab is displayed for Month View, THEN the control panel SHALL expose a curated set of `MCalThemeData` and `MCalMonthThemeData` properties, organized into logical sections (e.g., Cells, Events, Headers, Navigator, Drag & Drop, etc.)
2. WHEN the Theme tab is displayed, THEN it SHALL include presets: **Default**, **Compact**, **Spacious**, **High Contrast**, **Minimal**
3. WHEN the user selects a preset, THEN all theme sliders/pickers SHALL update to reflect the preset values and the calendar SHALL re-render
4. WHEN the user adjusts any theme setting, THEN the calendar SHALL update immediately with the new styling

##### REQ-3.2: Day View Theme Tab

1. WHEN the Theme tab is displayed for Day View, THEN the control panel SHALL expose a curated set of `MCalThemeData` and `MCalDayThemeData` properties, organized into logical sections (e.g., Time Legend, Gridlines, Events, Current Time, Time Regions, Resize, etc.)
2. WHEN the Theme tab is displayed, THEN it SHALL include presets: **Default**, **Compact**, **Spacious**, **High Contrast**, **Minimal**
3. WHEN the user selects a preset, THEN all theme settings SHALL update and the calendar SHALL re-render
4. WHEN the user adjusts any theme setting, THEN the calendar SHALL update immediately

### REQ-4: Styles Tab — Pre-configured Styles with Dropdown

**User Story:** As a developer, I want to browse pre-built calendar styles so that I can see what is achievable with the package and use them as starting points.

#### Acceptance Criteria

1. WHEN the Styles tab is displayed, THEN a dropdown selector SHALL appear with options: **Default**, **Modern**, **Classic**, **Minimal**, **Colorful**
2. WHEN the user selects "Default", THEN the calendar SHALL render with NO custom theming, builders, or handlers (pure library defaults)
3. WHEN the user selects any other style (Modern, Classic, Minimal, Colorful), THEN the calendar SHALL render with the style's pre-configured theme, builders, and event handlers as currently implemented
4. WHEN the user switches between styles, THEN the transition SHALL be immediate
5. WHEN the Styles tab is displayed, THEN each style SHALL include a localized description of its visual characteristics

### REQ-5: Stress Test Tab

**User Story:** As a developer, I want to evaluate performance characteristics so that I can assess whether the package handles large event counts efficiently.

#### Acceptance Criteria

##### REQ-5.1: Day View Stress Test

1. WHEN the Stress Test tab is displayed for Day View, THEN it SHALL retain the existing stress test functionality: configurable event counts (100, 200, 300, 500), performance metrics (FPS, frame time), and optional performance overlay

##### REQ-5.2: Month View Stress Test

1. WHEN the Stress Test tab is displayed for Month View, THEN it SHALL provide configurable event counts (100, 200, 300, 500)
2. WHEN stress test events are generated for Month View, THEN they SHALL be distributed both across the month AND concentrated on individual days (testing overflow handling)
3. WHEN the Stress Test tab is displayed for Month View, THEN it SHALL display performance metrics: event count, average frame time, and estimated FPS
4. WHEN the user toggles stress test mode, THEN the calendar SHALL switch between sample events and stress test events
5. WHEN stress test is active, THEN the user SHALL be able to toggle a performance overlay

### REQ-6: Accessibility Tab

**User Story:** As a developer, I want to understand the accessibility capabilities of each view so that I can build accessible calendar applications.

#### Acceptance Criteria

##### REQ-6.1: Day View Accessibility Tab

1. WHEN the Accessibility tab is displayed for Day View, THEN it SHALL retain existing functionality: keyboard shortcuts reference, screen reader guide, high contrast mode toggle, accessibility checklist, and keyboard navigation flow
2. WHEN the Accessibility tab is displayed for Day View, THEN keyboard navigation instructions previously in the Features tab SHALL appear here

##### REQ-6.2: Month View Accessibility Tab

1. WHEN the Accessibility tab is displayed for Month View, THEN it SHALL include a keyboard shortcuts reference with Month View-specific shortcuts:
   - Arrow keys: Navigate between cells
   - Enter/Space: Select focused cell / enter event selection mode
   - Home/End: Jump to first/last day of month
   - Page Up/Down: Previous/next month
   - Tab/Shift+Tab: Cycle through events on a cell
   - Keyboard move mode: Enter to confirm selection, arrows to move, Enter to confirm, Escape to cancel
   - Keyboard resize mode: R to enter, S/E to switch edges, arrows to adjust, M to return to move, Enter to confirm, Escape to cancel
2. WHEN the Accessibility tab is displayed for Month View, THEN it SHALL include a screen reader guide describing semantic labels for cells, events, multi-day spans, navigator, and overflow indicators
3. WHEN the Accessibility tab is displayed for Month View, THEN it SHALL include a high contrast mode toggle that applies a high-contrast theme
4. WHEN the Accessibility tab is displayed for Month View, THEN it SHALL include an accessibility checklist equivalent to the Day View checklist
5. WHEN the Accessibility tab is displayed for Month View, THEN it SHALL include a keyboard navigation flow description

### REQ-7: Responsive Control Panel Layout

**User Story:** As a developer testing on various screen sizes, I want the control panels to adapt to my screen size so that the calendar remains the primary focus with controls easily accessible.

#### Acceptance Criteria

1. WHEN the app is running on a phone or tablet (width < 900dp), THEN control panels for ALL tabs SHALL appear at the TOP of the content area and be COLLAPSIBLE
2. WHEN the app is running on a larger screen (width >= 900dp), THEN control panels for ALL tabs SHALL appear as a sidebar on the RIGHT
3. WHEN control panels are displayed, THEN their visual style SHALL be consistent across all tabs (same border treatment, padding, section headers, and widget styling)
4. WHEN the control panel is in collapsed state (phone/tablet), THEN the calendar SHALL fill the available space

### REQ-8: Full Localization

**User Story:** As a developer building a multi-language app, I want all example app text to be localized so that I can verify the package works correctly in all supported languages.

#### Acceptance Criteria

1. WHEN the app is displayed in any of the 5 supported languages (en, es, fr, ar, he), THEN ALL user-facing text SHALL be translated, including:
   - Tab labels and descriptions
   - Control panel labels, section headers, and option text
   - SnackBar messages
   - Dialog labels (event detail, event form, recurrence editor, recurrence scope, delete confirmation)
   - Bottom sheet content
   - Style descriptions
   - Stress test labels and metrics
   - Accessibility content (shortcuts, guides, checklists)
   - Comparison view text
2. WHEN the app displays RTL languages (Arabic, Hebrew), THEN all layouts SHALL correctly mirror
3. WHEN new localization keys are added, THEN they SHALL be added to all 5 ARB files (app_en.arb, app_es.arb, app_fr.arb, app_ar.arb, app_he.arb)

### REQ-9: Code Organization — Backup and New Files

**User Story:** As a maintainer, I want the old example code backed up and new files created from scratch so that I can compare and verify the new implementation before removing the old code.

#### Acceptance Criteria

1. WHEN implementation begins, THEN the existing `example/lib/` directory SHALL be backed up to `example/lib_backup/`
2. WHEN new example code is written, THEN it SHALL be created as new files (not edits to existing files)
3. WHEN the backup is created, THEN the new app SHALL NOT import from or depend on backed-up files
4. WHEN the new app builds and runs correctly, THEN the backup directory SHALL be available for the maintainer to manually delete after verification

### REQ-10: Feature Disparity Document

**User Story:** As a package maintainer, I want a comprehensive document highlighting feature disparities between Day View and Month View so that I can plan future alignment work.

#### Acceptance Criteria

1. WHEN the spec is complete, THEN a document SHALL be produced at `.spec-workflow/specs/example-app-reorganization/feature-disparities.md`
2. WHEN the document is produced, THEN it SHALL include:
   - Complete widget parameter comparison (all parameters for both views)
   - Features present in Day View but missing from Month View (with severity)
   - Features present in Month View but missing from Day View (with severity)
   - API inconsistencies between the two views (naming, signatures, patterns)
   - Theme property comparison (shared vs view-specific)
   - Recommendations for future alignment work
3. WHEN the document is produced, THEN it SHALL specifically highlight:
   - Day View missing a `DateLabelPosition`-equivalent setting
   - Day View missing configurable sub-hour time labels (options/builders for 10, 15, 20, 30 minute intervals)
   - Day View `onEventDropped`/`onEventResized` returning `void` vs Month View returning `bool`
   - Day View missing `onEventDoubleTap`
   - Day View builders not following the builder-with-default pattern
   - Month View missing keyboard CRUD callbacks (`onCreateEventRequested`, `onDeleteEventRequested`, `onEditEventRequested`)
   - Month View missing custom `keyboardShortcuts` map

### REQ-11: Shared Example Infrastructure

**User Story:** As a developer maintaining the example app, I want shared utilities and widgets to be reusable across both view showcases so that the codebase remains DRY and consistent.

#### Acceptance Criteria

1. WHEN the example app is reorganized, THEN shared widgets (event detail dialog, event form dialog, bottom sheet, recurrence editor, recurrence scope dialog, style description) SHALL be in a shared `widgets/` directory
2. WHEN the example app is reorganized, THEN shared utilities (sample events, date formatters, event colors) SHALL be in a shared `utils/` directory
3. WHEN the example app is reorganized, THEN the control panel widget SHALL be a reusable component that both Month View and Day View tabs can use, ensuring visual consistency (REQ-7)

## Non-Functional Requirements

### Code Architecture and Modularity

- **Single Responsibility Principle**: Each file should have a single, well-defined purpose (e.g., one tab per file, one dialog per file)
- **Modular Design**: Control panel, style presets, and sample data generators should be isolated and reusable
- **Dependency Management**: New example files should not depend on backed-up files
- **Clear Interfaces**: Shared widgets should have well-defined APIs with all text coming through localization

### Performance

- The example app shall start and navigate between tabs without noticeable lag
- Stress test tab shall accurately measure and display rendering performance
- Control panel changes shall apply without frame drops in normal (non-stress-test) mode

### Usability

- The example app shall be usable on phones, tablets, and desktops
- Control panels shall not obscure the calendar on any screen size
- Tab labels shall be concise enough to fit on phone screens without scrolling

### Reliability

- All 5 ARB files shall compile without errors after localization changes
- The backup process shall be non-destructive (copy, not move)
- The new example app shall pass `flutter analyze` with no errors
