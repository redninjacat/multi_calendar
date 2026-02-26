# Design Document

## Overview

This design reorganizes the multi_calendar example app from its current asymmetric structure (6 Month View tabs, 9 Day View tabs) into a unified 5-tab structure per view (Features, Theme, Styles, Stress Test, Accessibility). It introduces a shared responsive control panel component, separates widget configuration from theme customization, fully localizes all user-facing text across 5 languages, and adds new tabs (Month View Stress Test and Accessibility). The Comparison view remains unchanged.

## Steering Document Alignment

### Product Vision (product.md)

The example app reorganization directly supports several product principles and key features:
- **Customization First** (Principle #4): The Theme tab showcases the full extent of theming APIs; the Styles tab shows pre-built configurations as starting points
- **Accessibility First** (Principle #7): Dedicated Accessibility tab per view with keyboard shortcuts, screen reader guide, high contrast mode, and checklist (WCAG 2.1 AA)
- **International Ready** (Principle #8): Full localization of all example text across 5 languages (en, es, fr, ar, he) with RTL support
- **Mobile-First** (Principle #9): Responsive control panel (top on mobile, sidebar on desktop) follows mobile-first design
- **Flexible Interaction** (Principle #10): Features tab exposes all gesture handlers with SnackBar feedback demonstrating every interaction type
- **Developer Experience** (Business Objective): Unified tab structure makes it easy for developers to compare capabilities between views and find what they need

### Technical Standards (tech.md)

The design follows documented technical standards:
- **Widget-based Architecture**: Each tab is a StatefulWidget following the controller pattern (tech.md Architecture section)
- **Builder Pattern**: Style widgets use builder callbacks extensively for customization (tech.md Decision #5)
- **Localization**: Uses Flutter's official `gen-l10n` system with ARB files as documented (tech.md Key Dependencies)
- **Accessibility**: Leverages Flutter's built-in `Semantics` widgets (tech.md Key Dependencies)
- **Performance**: Stress test tab validates 60fps rendering target on mid-range devices (tech.md Performance Requirements)
- **MCal Prefix Convention**: All package references use MCal prefix to avoid conflicts (tech.md Decision #1)
- **Dart `3.10.4+`**: Code targets documented SDK version

### Project Structure (structure.md)

The design follows documented project organization conventions:
- **File Naming**: `snake_case.dart` for all files (structure.md Naming Conventions)
- **Code Naming**: `PascalCase` for classes, `camelCase` for functions/variables (structure.md Code Naming)
- **Import Order**: Dart SDK, Flutter SDK, external packages, internal imports (structure.md Import Patterns)
- **File Size**: Maximum 500 lines per file, aim for 200-300 (structure.md Code Size Guidelines)
- **Function Size**: Maximum 50 lines per function, aim for 10-20 (structure.md Code Size Guidelines)
- **Build Methods**: Under 100 lines, extract helpers (structure.md Code Size Guidelines)
- **Single Responsibility**: Each file has one clear purpose (structure.md Code Organization Principles)
- **Example App Structure**: Lives under `example/lib/` with screens and shared utilities (structure.md Example App Structure)

## Code Reuse Analysis

### Existing Components to Leverage

- **`MCalEventController`**: Used as-is across all tabs for event management
- **`MCalTheme` / `MCalThemeData`**: Used for theme customization in Theme tabs and style showcase
- **`MCalMonthThemeData` / `MCalDayThemeData`**: View-specific theme settings exposed in Theme tabs
- **`createSampleEvents()`**: Reused for standard sample data across Features, Theme, Styles, and Accessibility tabs
- **`createDayViewSampleEvents()`**: Reused for Day View sample data
- **`createDayViewStressTestEvents()`**: Reused for Day View stress test
- **`getEventColor()` / `eventColors`**: Reused for consistent event coloring
- **`showEventDetailDialog()`**: Reused across all tabs with event tap handlers
- **`showDayEventsBottomSheet()`**: Reused for Month View overflow indicators
- **`DayViewCrudHelper` mixin**: Reused for Day View CRUD operations
- **`showDayViewEventCreateDialog()` / `showDayViewEventEditDialog()`**: Reused for Day View event forms
- **`RecurrenceEditorDialog`**: Reused for recurring event editing
- **`RecurrenceEditScopeDialog`**: Reused for recurring event scope selection
- **Existing style widgets** (Modern, Classic, Minimal, Colorful for both views): Retained with minimal modification in Styles tabs

### Integration Points

- **ARB localization system**: All new strings added to existing ARB infrastructure
- **`MCalLocalizations`** (package-level): Used for calendar-specific strings
- **`AppLocalizations`** (example-level): Extended with ~200+ new keys for full localization
- **`NavigationRail`**: Existing main screen navigation retained

## Architecture

### Modular Design Principles

- **Single File Responsibility**: Each tab is a single file; each style is a single file; each dialog is a single file
- **Component Isolation**: The responsive control panel is a standalone widget reusable across all tabs
- **Separation of Concerns**: Features tab handles widget params only; Theme tab handles theme params only; Styles tab handles pre-built configurations
- **Utility Modularity**: Sample data generators, date formatters, and event colors remain isolated utilities

### Directory Structure

```
example/lib/
  main.dart
  l10n/
    app_en.arb
    app_es.arb
    app_fr.arb
    app_ar.arb
    app_he.arb
    app_localizations.dart          (generated)
  screens/
    main_screen.dart
  shared/
    widgets/
      responsive_control_panel.dart    # Responsive layout shell
      control_panel_section.dart       # Collapsible section with header
      control_widgets.dart             # Toggle, slider, dropdown, color picker helpers
      event_detail_dialog.dart         # Localized event detail dialog
      event_form_dialog.dart           # Localized create/edit event dialog
      day_events_bottom_sheet.dart     # Localized overflow bottom sheet
      recurrence_editor_dialog.dart    # Localized RRULE editor
      recurrence_edit_scope_dialog.dart  # Localized scope chooser
      style_description.dart           # Style description banner
      snackbar_helper.dart             # Consistent SnackBar display helper
    utils/
      sample_events.dart               # Month + Day sample events
      stress_test_events.dart          # Month + Day stress test event generators
      date_formatters.dart             # Locale-aware date formatting
      event_colors.dart                # Event color palette
      theme_presets.dart               # Shared theme preset definitions
  views/
    month_view/
      month_view_showcase.dart         # 5-tab controller
      tabs/
        month_features_tab.dart        # Widget settings + interactions
        month_theme_tab.dart           # Theme settings + presets
        month_styles_tab.dart          # Dropdown style switcher
        month_stress_test_tab.dart     # Performance testing
        month_accessibility_tab.dart   # Keyboard + screen reader + high contrast
      styles/
        month_default_style.dart
        month_modern_style.dart
        month_classic_style.dart
        month_minimal_style.dart
        month_colorful_style.dart
    day_view/
      day_view_showcase.dart           # 5-tab controller
      tabs/
        day_features_tab.dart          # Widget settings + interactions
        day_theme_tab.dart             # Theme settings + presets
        day_styles_tab.dart            # Dropdown style switcher
        day_stress_test_tab.dart       # Performance testing
        day_accessibility_tab.dart     # Keyboard + screen reader + high contrast
      styles/
        day_default_style.dart
        day_modern_style.dart
        day_classic_style.dart
        day_minimal_style.dart
        day_colorful_style.dart
    comparison/
      comparison_view.dart             # Unchanged from current
```

### Component Relationship Diagram

```
MainScreen
  NavigationRail [Month View | Day View | Comparison]
    MonthViewShowcase
      TabBar [Features | Theme | Styles | Stress Test | Accessibility]
        MonthFeaturesTab
          ResponsiveControlPanel (widget settings)
          MCalMonthView (configured by settings)
        MonthThemeTab
          ResponsiveControlPanel (theme settings + presets)
          MCalTheme + MCalMonthView
        MonthStylesTab
          Dropdown (style selector)
          StyleDescription
          SelectedStyle widget (Default/Modern/Classic/Minimal/Colorful)
        MonthStressTestTab
          ResponsiveControlPanel (stress controls)
          MCalMonthView (stress events)
        MonthAccessibilityTab
          Keyboard shortcuts reference
          Screen reader guide
          High contrast toggle
          MCalMonthView (accessible config)
    DayViewShowcase
      TabBar [Features | Theme | Styles | Stress Test | Accessibility]
        (mirrors Month structure with Day View specifics)
    ComparisonView (unchanged)
```

## Components and Interfaces

### Component 1: ResponsiveControlPanel

- **Purpose**: Provides a responsive layout shell that positions a control panel either at the top (collapsible, phone/tablet) or as a right sidebar (desktop)
- **Interfaces**:
  - `ResponsiveControlPanel({required Widget child, required Widget controlPanel, double sidebarWidth = 300, double breakpoint = 900})`
  - The `child` is the calendar widget
  - The `controlPanel` is the settings content
- **Dependencies**: `MediaQuery` for responsive breakpoint detection
- **Reuses**: N/A (new shared component)
- **Behavior**:
  - Width >= `breakpoint`: `Row` with `[child (Expanded), controlPanel (fixed width)]`
  - Width < `breakpoint`: `Column` with `[ExpansionTile controlPanel, child (Expanded)]`
  - Consistent border/padding treatment regardless of layout mode

### Component 2: ControlPanelSection

- **Purpose**: A collapsible section within a control panel with a styled header
- **Interfaces**:
  - `ControlPanelSection({required String title, required List<Widget> children, bool initiallyExpanded = true})`
- **Dependencies**: Material `ExpansionTile`
- **Reuses**: N/A (new shared component)
- **Behavior**: Groups related settings under a titled, collapsible section

### Component 3: ControlWidgets (static helpers)

- **Purpose**: Consistent building blocks for control panel settings
- **Interfaces**:
  - `ControlWidgets.toggle({required String label, required bool value, required ValueChanged<bool> onChanged})`
  - `ControlWidgets.slider({required String label, required double value, required double min, required double max, int? divisions, required ValueChanged<double> onChanged})`
  - `ControlWidgets.dropdown<T>({required String label, required T value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged})`
  - `ControlWidgets.colorPicker({required String label, required Color value, required ValueChanged<Color> onChanged})`
  - `ControlWidgets.presetChips<T>({required String label, required T selected, required List<T> presets, required String Function(T) labelBuilder, required ValueChanged<T> onChanged})`
- **Dependencies**: Material widgets
- **Reuses**: N/A (new shared component)

### Component 4: SnackBarHelper

- **Purpose**: Consistent SnackBar display with localized messages
- **Interfaces**:
  - `SnackBarHelper.show(BuildContext context, String message)`
  - Clears previous SnackBar before showing new one
  - Consistent duration, styling, and dismissal behavior
- **Dependencies**: `ScaffoldMessenger`
- **Reuses**: N/A (new shared component)

### Component 5: MonthViewShowcase / DayViewShowcase

- **Purpose**: Tab controller host for each view's 5 tabs
- **Interfaces**:
  - `MonthViewShowcase()` / `DayViewShowcase()`
  - Internal `TabController` with 5 tabs
  - Tab labels loaded from `AppLocalizations`
- **Dependencies**: Tab widgets, `AppLocalizations`
- **Reuses**: Existing showcase pattern (simplified from current)

### Component 6: Features Tabs (MonthFeaturesTab / DayFeaturesTab)

- **Purpose**: Interactive showcase of all widget-level parameters with live control panel
- **Interfaces**:
  - Stateful widgets managing all widget parameter state
  - `ResponsiveControlPanel` wrapping the calendar and settings
  - All gesture handlers wired with SnackBar feedback
  - Event tap opens detail dialog; overflow opens bottom sheet
- **Dependencies**: `ResponsiveControlPanel`, `ControlPanelSection`, `ControlWidgets`, `SnackBarHelper`, `MCalEventController`, sample events, shared dialogs
- **Reuses**: Event detail dialog, bottom sheet, event form dialog, sample events, CRUD helper

**Month View Features Settings (widget params only):**

| Section | Settings |
|---------|----------|
| Navigation | `showNavigator`, `enableSwipeNavigation`, `swipeNavigationDirection`, `firstDayOfWeek` |
| Display | `showWeekNumbers`, `maxVisibleEventsPerDay` |
| Drag & Drop | `enableDragToMove`, `showDropTargetTiles`, `showDropTargetOverlay`, `dropTargetTilesAboveOverlay`, `dragEdgeNavigationEnabled`, `dragEdgeNavigationDelay`, `dragLongPressDelay` |
| Resize | `enableDragToResize` |
| Animation | `enableAnimations`, `animationDuration`, `animationCurve` |
| Keyboard | `enableKeyboardNavigation`, `autoFocusOnCellTap` |
| Blackout Days | Toggle + day-of-week multi-select (drives `cellInteractivityCallback` + `onDragWillAccept`) |

**Day View Features Settings (widget params only):**

| Section | Settings |
|---------|----------|
| Time Range | `startHour`, `endHour`, `timeSlotDuration`, `gridlineInterval`, `hourHeight` |
| Navigation | `showNavigator`, `autoScrollToCurrentTime` |
| Display | `showCurrentTimeIndicator`, `showWeekNumber`, `allDaySectionMaxRows`, `allDayToTimedDuration` |
| Drag & Drop | `enableDragToMove`, `showDropTargetPreview`, `showDropTargetOverlay`, `dropTargetTilesAboveOverlay`, `dragEdgeNavigationEnabled`, `dragEdgeNavigationDelay`, `dragLongPressDelay` |
| Resize | `enableDragToResize` |
| Snapping | `snapToTimeSlots`, `snapToOtherEvents`, `snapToCurrentTime`, `snapRange` |
| Animation | `enableAnimations`, `animationDuration` |
| Keyboard | `enableKeyboardNavigation`, `autoFocusOnEventTap` |
| Time Regions | Toggle special time regions, toggle blackout times |

### Component 7: Theme Tabs (MonthThemeTab / DayThemeTab)

- **Purpose**: Live theme customization with presets and granular controls
- **Interfaces**:
  - Stateful widgets managing theme property state
  - Preset selector (chips) at top
  - Organized sections of theme controls
  - `MCalTheme` wrapping the calendar with live-updated `MCalThemeData`
- **Dependencies**: `ResponsiveControlPanel`, `ControlWidgets`, `MCalThemeData`, `MCalMonthThemeData`/`MCalDayThemeData`

**Month View Theme Settings (curated subset):**

| Section | Properties |
|---------|-----------|
| Cells | `cellBackgroundColor`, `cellBorderColor`, `todayBackgroundColor`, `todayTextStyle` (weight/size) |
| Event Tiles | `eventTileBackgroundColor`, `eventTileHeight`, `eventTileCornerRadius`, `eventTileHorizontalSpacing`, `eventTileVerticalSpacing`, `eventTileBorderWidth`, `ignoreEventColors` |
| Headers | `weekdayHeaderTextStyle` (weight/size), `weekdayHeaderBackgroundColor` |
| Date Labels | `dateLabelHeight`, `dateLabelPosition` |
| Overflow | `overflowIndicatorHeight` |
| Navigator | `navigatorTextStyle` (weight/size), `navigatorBackgroundColor` |
| Drag & Drop | `dropTargetCellValidColor`, `dropTargetCellInvalidColor`, `dragSourceOpacity`, `draggedTileElevation` |
| Hover | `hoverCellBackgroundColor`, `hoverEventBackgroundColor` |
| Week Numbers | `weekNumberTextStyle`, `weekNumberBackgroundColor` |

**Day View Theme Settings (curated subset):**

| Section | Properties |
|---------|-----------|
| Time Legend | `timeLegendWidth`, `timeLegendTextStyle` (weight/size), `showTimeLegendTicks`, `timeLegendTickColor`, `timeLegendTickWidth`, `timeLegendTickLength` |
| Gridlines | `hourGridlineColor`, `hourGridlineWidth`, `majorGridlineColor`, `majorGridlineWidth`, `minorGridlineColor`, `minorGridlineWidth` |
| Current Time | `currentTimeIndicatorColor`, `currentTimeIndicatorWidth`, `currentTimeIndicatorDotRadius` |
| Events | `eventTileBackgroundColor`, `timedEventBorderRadius`, `timedEventMinHeight`, `timedEventPadding`, `ignoreEventColors` |
| All-Day Events | `allDayEventBackgroundColor`, `allDayEventBorderColor`, `allDayEventBorderWidth` |
| Time Regions | `specialTimeRegionColor`, `blockedTimeRegionColor`, `timeRegionBorderColor`, `timeRegionTextColor` |
| Resize | `resizeHandleSize`, `minResizeDurationMinutes` |

**Theme Presets (both views):**

| Preset | Description |
|--------|-------------|
| Default | Library defaults from `MCalThemeData.fromTheme()` |
| Compact | Reduced spacing, smaller tiles, tighter layout |
| Spacious | Increased spacing, larger tiles, more whitespace |
| High Contrast | High contrast colors, thicker borders, bold text |
| Minimal | Transparent/subtle backgrounds, minimal borders, light gridlines |

### Component 8: Styles Tabs (MonthStylesTab / DayStylesTab)

- **Purpose**: Showcase pre-configured style variations via dropdown selector
- **Interfaces**:
  - Dropdown at top to select style: Default, Modern, Classic, Minimal, Colorful
  - `StyleDescription` banner below dropdown showing localized description
  - Selected style widget renders below
- **Dependencies**: Style widgets, `StyleDescription`, `AppLocalizations`
- **Reuses**: Existing style widgets from current codebase (migrated to new paths)

### Component 9: Stress Test Tabs (MonthStressTestTab / DayStressTestTab)

- **Purpose**: Performance testing with large event counts
- **Interfaces**:
  - Control panel with: stress mode toggle, event count selector (100/200/300/500), performance overlay toggle
  - Metrics display: event count, avg frame time, FPS estimate
- **Dependencies**: `ResponsiveControlPanel`, `MCalEventController`, stress test event generators
- **Reuses**: Existing Day View stress test logic; new Month View stress test event generator

**Month View Stress Test Event Generation:**
- Distributes events across the visible month using random distribution
- Clusters extra events on 3-5 random days (10-20 events each) to test overflow
- Mix of single-day and multi-day events
- Uses seeded RNG for reproducibility

### Component 10: Accessibility Tabs (MonthAccessibilityTab / DayAccessibilityTab)

- **Purpose**: Showcase accessibility features with documentation and interactive demo
- **Interfaces**:
  - Split layout: calendar on left/top, documentation panel on right/bottom
  - Documentation sections: Keyboard Shortcuts, Screen Reader Guide, Accessibility Checklist, Keyboard Navigation Flow
  - High contrast mode toggle
  - Interactive calendar with accessibility features enabled
- **Dependencies**: `MCalThemeData`, `AppLocalizations`
- **Reuses**: Existing Day View accessibility demo structure; new Month View equivalent

**Month View Keyboard Shortcuts:**

| Shortcut | Action |
|----------|--------|
| Arrow keys | Navigate between cells |
| Enter / Space | Select focused cell / enter event selection |
| Home | First day of month |
| End | Last day of month |
| Page Up | Previous month |
| Page Down | Next month |
| Tab / Shift+Tab | Cycle events on cell |
| R | Enter resize mode |
| S / E | Switch resize edge |
| M | Return to move mode |
| Escape | Cancel operation |

## Data Models

### ThemePreset

```dart
enum ThemePreset { defaultPreset, compact, spacious, highContrast, minimal }
```

### MonthViewFeatureSettings

```dart
class MonthViewFeatureSettings {
  bool showNavigator;
  bool enableSwipeNavigation;
  MCalSwipeNavigationDirection swipeDirection;
  int firstDayOfWeek;
  bool showWeekNumbers;
  int maxVisibleEventsPerDay;
  bool enableDragToMove;
  bool? enableDragToResize;
  bool showDropTargetTiles;
  bool showDropTargetOverlay;
  bool dropTargetTilesAboveOverlay;
  bool dragEdgeNavigationEnabled;
  Duration dragEdgeNavigationDelay;
  Duration dragLongPressDelay;
  bool? enableAnimations;
  Duration animationDuration;
  Curve animationCurve;
  bool enableKeyboardNavigation;
  bool autoFocusOnCellTap;
  bool enableBlackoutDays;
  Set<int> blackoutWeekdays;
}
```

### DayViewFeatureSettings

```dart
class DayViewFeatureSettings {
  int startHour;
  int endHour;
  Duration timeSlotDuration;
  Duration gridlineInterval;
  double? hourHeight;
  bool showNavigator;
  bool showCurrentTimeIndicator;
  bool showWeekNumber;
  int allDaySectionMaxRows;
  Duration allDayToTimedDuration;
  bool enableDragToMove;
  bool? enableDragToResize;
  bool showDropTargetPreview;
  bool showDropTargetOverlay;
  bool dropTargetTilesAboveOverlay;
  bool dragEdgeNavigationEnabled;
  Duration dragEdgeNavigationDelay;
  Duration dragLongPressDelay;
  bool snapToTimeSlots;
  bool snapToOtherEvents;
  bool snapToCurrentTime;
  Duration snapRange;
  bool? enableAnimations;
  Duration animationDuration;
  bool enableKeyboardNavigation;
  bool autoFocusOnEventTap;
  bool autoScrollToCurrentTime;
  bool enableSpecialTimeRegions;
  bool enableBlackoutTimes;
}
```

### MonthThemeSettings / DayThemeSettings

State classes holding all curated theme property values with `toThemeData()` methods that return configured `MCalThemeData` instances. Include `applyPreset(ThemePreset)` to load preset values.

## Error Handling

### Error Scenarios

1. **Missing localization key**
   - **Handling**: Flutter's gen-l10n will catch missing keys at compile time. All 5 ARB files must be kept in sync.
   - **User Impact**: Build failure with clear error message identifying the missing key.

2. **Invalid control panel value**
   - **Handling**: Sliders have min/max bounds; dropdowns have fixed options; toggles are boolean. No freeform input.
   - **User Impact**: Cannot enter invalid values due to constrained inputs.

3. **Stress test performance degradation**
   - **Handling**: Event counts capped at 500. Performance overlay available for diagnosis.
   - **User Impact**: App may slow down during stress test (expected behavior being measured).

## Testing Strategy

### Unit Testing

- No new unit tests required for the example app (it is a showcase, not a library)
- Existing package tests remain unchanged

### Integration Testing

- Verify the example app builds and runs: `cd example && flutter build apk --debug`
- Verify `flutter analyze` passes with no errors
- Verify all 5 ARB files are in sync (gen-l10n produces no errors)

### End-to-End Testing

- Manual testing: navigate all tabs for both Month and Day views
- Verify control panel responsiveness at phone, tablet, and desktop widths
- Verify all 5 languages display correctly (especially RTL for Arabic and Hebrew)
- Verify gesture SnackBars fire for all handlers
- Verify stress test metrics display and update
- Verify accessibility tab keyboard shortcuts match actual behavior

## Localization Strategy

### Key Naming Convention

All new ARB keys follow a prefix convention for organization:

| Prefix | Area |
|--------|------|
| `tab*` | Tab labels (e.g., `tabFeatures`, `tabTheme`, `tabStyles`, `tabStressTest`, `tabAccessibility`) |
| `section*` | Control panel section headers (e.g., `sectionNavigation`, `sectionDragDrop`) |
| `setting*` | Individual setting labels (e.g., `settingDragToMove`, `settingShowNavigator`) |
| `style*` | Style names and descriptions (reuse existing where possible) |
| `stress*` | Stress test labels (e.g., `stressEventCount`, `stressToggle`) |
| `a11y*` | Accessibility content (reuse existing `accessibility*` keys where possible) |
| `snackbar*` | SnackBar messages (e.g., `snackbarCellTap`, `snackbarEventDoubleTap`) |
| `dialog*` | Dialog labels (e.g., `dialogEventTitle`, `dialogStartDate`) |
| `preset*` | Theme preset names (e.g., `presetDefault`, `presetCompact`) |

### Translation Approach

- English (en) ARB is the source of truth
- Spanish (es), French (fr), Arabic (ar), Hebrew (he) translations provided for all keys
- RTL languages (ar, he) tested for layout correctness
