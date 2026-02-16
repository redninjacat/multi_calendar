# Feature Disparities Analysis: MCalDayView vs MCalMonthView

## Document Overview

This document provides comprehensive analysis of API differences, feature gaps, and inconsistencies between `MCalDayView` and `MCalMonthView` widgets.

**Analysis Date:** February 15, 2026  
**Source Files:**
- `lib/src/widgets/mcal_day_view.dart` (68 public parameters)
- `lib/src/widgets/mcal_month_view.dart` (56 public parameters)
- `lib/src/styles/mcal_day_theme_data.dart` (30 theme properties)
- `lib/src/styles/mcal_month_theme_data.dart` (40 theme properties)

---

## 1. Complete Widget Parameter Comparison

### 1.1 MCalDayView Parameters (68 Total)

#### Core & Display (11)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `controller` | `MCalEventController` | required | Event controller |
| `startHour` | `int` | `0` | Starting hour (0-23) |
| `endHour` | `int` | `23` | Ending hour (0-23) |
| `timeSlotDuration` | `Duration` | `15 min` | Time slot granularity |
| `hourHeight` | `double?` | `null` | Pixel height per hour |
| `showNavigator` | `bool` | `false` | Show navigation bar |
| `showCurrentTimeIndicator` | `bool` | `true` | Show current time line |
| `showWeekNumber` | `bool` | `false` | Show ISO week number (SINGULAR) |
| `gridlineInterval` | `Duration` | `15 min` | Gridline interval |
| `dateFormat` | `DateFormat?` | `null` | Date format (intl object) |
| `timeLabelFormat` | `DateFormat?` | `null` | Time format |
| `locale` | `Locale?` | `null` | Locale |

#### Scrolling (4)
- `autoScrollToCurrentTime`, `initialScrollTime`, `scrollPhysics`, `scrollController`

#### All-Day Events (2)
- `allDaySectionMaxRows`, `allDayToTimedDuration`

#### Drag & Drop (8)
- `enableDragToMove`, `enableDragToResize`, `dragEdgeNavigationEnabled`
- `dragLongPressDelay`, `dragEdgeNavigationDelay`
- `showDropTargetPreview`, `showDropTargetOverlay`, `dropTargetTilesAboveOverlay`

#### Snapping (4)
- `snapToTimeSlots`, `snapToOtherEvents`, `snapToCurrentTime`, `snapRange`

#### Special Time Regions (1)
- `specialTimeRegions`

#### Keyboard (3)
- `enableKeyboardNavigation`, `autoFocusOnEventTap`
- **`keyboardShortcuts`** — Custom keyboard shortcut map

#### Animation (3)
- `enableAnimations`, `animationDuration`, `animationCurve`

#### Boundaries (2)
- `minDate`, `maxDate`

#### Builders (13)
- `dayHeaderBuilder`, `timeLabelBuilder`, `gridlineBuilder`
- `allDayEventTileBuilder`, `timedEventTileBuilder`
- `currentTimeIndicatorBuilder`, `navigatorBuilder`, `dayLayoutBuilder`
- `draggedTileBuilder`, `dragSourceTileBuilder`, `dropTargetTileBuilder`
- `dropTargetOverlayBuilder`, `timeResizeHandleBuilder`
- `loadingBuilder`, `errorBuilder`, `timeRegionBuilder`

**Note:** Day View builders do NOT receive default widget parameter

#### Navigation Callbacks (3)
- **`onNavigatePrevious`**, **`onNavigateNext`**, **`onNavigateToday`** — Per-button callbacks

#### Interaction Callbacks (12)
- `onDayHeaderTap`, `onDayHeaderLongPress`, `onTimeLabelTap`
- `onTimeSlotTap`, `onTimeSlotLongPress`, `onEmptySpaceDoubleTap`
- `onEventTap`, `onEventLongPress`, `onHoverEvent`, `onHoverTimeSlot`
- `onOverflowTap`, `onOverflowLongPress`

#### Keyboard CRUD Callbacks (3)
- **`onCreateEventRequested`** — Cmd/Ctrl+N
- **`onDeleteEventRequested`** — Cmd/Ctrl+D, Delete, Backspace
- **`onEditEventRequested`** — Cmd/Ctrl+E

#### Drag Callbacks (4)
- `onDragWillAccept`
- **`onEventDropped`** — Returns **void**
- `onResizeWillAccept`
- **`onEventResized`** — Returns **void**

#### State Callbacks (2)
- `onDisplayDateChanged`, `onScrollChanged`

#### Accessibility & Theme (2)
- `semanticsLabel`, `theme`

---

### 1.2 MCalMonthView Parameters (56 Total)

#### Core & Display (7)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `controller` | `MCalEventController` | required | Event controller |
| `minDate` | `DateTime?` | `null` | Min navigable date |
| `maxDate` | `DateTime?` | `null` | Max navigable date |
| `firstDayOfWeek` | `int?` | `null` | First day of week (0-6) |
| `showNavigator` | `bool` | `false` | Show navigation bar |
| `dateFormat` | `String?` | `null` | Date format (STRING, not DateFormat) |
| `locale` | `Locale?` | `null` | Locale |

#### Swipe Navigation (2)
- **`enableSwipeNavigation`**, **`swipeNavigationDirection`**

#### Builders (9)
- **`dayCellBuilder`** — Receives default widget
- **`eventTileBuilder`** — Receives default widget
- **`dayHeaderBuilder`** — Receives default widget
- `navigatorBuilder`
- **`dateLabelBuilder`** — Receives default string
- `weekNumberBuilder`, `weekLayoutBuilder`
- **`overflowIndicatorBuilder`** — Receives default widget
- `loadingBuilder`, `errorBuilder`

**Note:** Month View builders follow builder-with-default pattern

#### Cell Interactivity (1)
- **`cellInteractivityCallback`** — Determine if cell is interactive

#### Interaction Callbacks (10)
- `onCellTap`, `onCellLongPress`, **`onCellDoubleTap`**
- `onDateLabelTap`, `onDateLabelLongPress`
- `onEventTap`, `onEventLongPress`, **`onEventDoubleTap`**
- **`onSwipeNavigation`**
- `onOverflowTap`, `onOverflowLongPress`

#### Hover Callbacks (2)
- `onHoverCell`, `onHoverEvent`

#### Keyboard (2)
- `enableKeyboardNavigation`, `autoFocusOnCellTap`

#### Navigation State Callbacks (4)
- `onDisplayDateChanged`, `onViewableRangeChanged`
- `onFocusedDateChanged`, `onFocusedRangeChanged`

#### Animation (3)
- `enableAnimations`, `animationDuration`, `animationCurve`

#### Event Display (2)
- `maxVisibleEventsPerDay`, `showWeekNumbers` (PLURAL)

#### Accessibility (1)
- `semanticsLabel`

#### Drag & Drop (13)
- `enableDragToMove`, `enableDragToResize`
- `dragEdgeNavigationEnabled`, `dragLongPressDelay`, `dragEdgeNavigationDelay`
- `showDropTargetTiles`, `showDropTargetOverlay`, `dropTargetTilesAboveOverlay`
- `draggedTileBuilder`, `dragSourceTileBuilder`, `dropTargetTileBuilder`
- `dropTargetCellBuilder`, `dropTargetOverlayBuilder`
- `onDragWillAccept`
- **`onEventDropped`** — Returns **bool**

#### Event Resize (3)
- `onResizeWillAccept`
- **`onEventResized`** — Returns **bool**
- `resizeHandleBuilder`
- **`resizeHandleInset`** — Horizontal inset function

---

## 2. Features Day View Has but Month View Lacks

### 2.1 Time-Specific Features (N/A - Domain-Specific)
These are specific to Day View's time-based vertical layout:
- Time configuration: `startHour`, `endHour`, `timeSlotDuration`, `hourHeight`
- Current time indicator: `showCurrentTimeIndicator`
- Time legend: `timeLabelFormat`, `timeLabelBuilder`, `onTimeLabelTap`
- Vertical scrolling: `autoScrollToCurrentTime`, `initialScrollTime`, `scrollPhysics`, `scrollController`
- Time regions: `specialTimeRegions`, `timeRegionBuilder`
- Snapping: `snapToTimeSlots`, `snapToOtherEvents`, `snapToCurrentTime`, `snapRange`
- Time-specific builders: `currentTimeIndicatorBuilder`, `gridlineBuilder`, `timeResizeHandleBuilder`
- Time slot interactions: `onTimeSlotTap`, `onTimeSlotLongPress`, `onHoverTimeSlot`, `onEmptySpaceDoubleTap`
- Day layout: `dayLayoutBuilder`

### 2.2 Keyboard CRUD Operations (**Severity: HIGH**)

**Missing in Month View:**
1. **`keyboardShortcuts: Map<ShortcutActivator, Intent>?`** — Customizable keyboard shortcut map
2. **`onCreateEventRequested`** — Callback for Cmd/Ctrl+N (create event)
3. **`onDeleteEventRequested`** — Callback for Cmd/Ctrl+D, Delete, Backspace (delete event)
4. **`onEditEventRequested`** — Callback for Cmd/Ctrl+E (edit event)

**Impact:**
- Month View users cannot create, edit, or delete events via keyboard shortcuts
- Accessibility gap for keyboard-only users
- No standardized CRUD workflow in Month View

**Recommendation:** **HIGH PRIORITY** — Add these 4 parameters to Month View

### 2.3 Per-Button Navigation Callbacks (**Severity: MEDIUM**)

**Missing in Month View:**
1. **`onNavigatePrevious: VoidCallback?`**
2. **`onNavigateNext: VoidCallback?`**
3. **`onNavigateToday: VoidCallback?`**

**Current Alternative:** Month View only has `onDisplayDateChanged` for all navigation

**Impact:**
- Cannot differentiate navigation triggers (button vs swipe vs keyboard)
- Cannot implement analytics or custom behavior per navigation action
- Less granular control

**Recommendation:** **MEDIUM PRIORITY** — Add per-button callbacks to Month View

### 2.4 Scroll State Tracking (**Severity: LOW**)

**Missing in Month View:**
- `onScrollChanged: ValueChanged<double>?`

**Impact:** Month View has no scrolling (page-based), so not directly applicable

**Recommendation:** Consider adding `onPageChanged(int pageIndex)` to Month View

### 2.5 Day Header Interactions (**Severity: LOW**)

**Missing in Month View:**
- `onDayHeaderTap`, `onDayHeaderLongPress`

**Impact:** Not applicable — Month View has static weekday headers, not dynamic day headers

**Recommendation:** Not needed (domain difference)

---

## 3. Features Month View Has but Day View Lacks

### 3.1 Double-Tap Interactions (**Severity: HIGH**)

**Missing in Day View:**
1. **`onEventDoubleTap`** — Event double-tap callback with tap position
2. `onCellDoubleTap` — Cell double-tap (Month View specific)

**Note:** Day View has `onEmptySpaceDoubleTap` for empty time slots, but **NO `onEventDoubleTap`**

**Impact:**
- Common UX pattern: double-tap to edit event
- Month View supports it, Day View doesn't
- Inconsistent interaction model

**Recommendation:** **HIGH PRIORITY** — Add `onEventDoubleTap` to Day View

### 3.2 Swipe Navigation (**Severity: MEDIUM**)

**Missing in Day View:**
1. **`enableSwipeNavigation: bool`**
2. **`swipeNavigationDirection: MCalSwipeNavigationDirection`** (horizontal/vertical)
3. **`onSwipeNavigation`** callback

**Impact:**
- Month View has touch-friendly swipe navigation
- Day View only has button-based navigation
- Inconsistent mobile UX

**Recommendation:** **MEDIUM PRIORITY** — Add swipe navigation to Day View

### 3.3 Cell Interactivity Control (**Severity: MEDIUM**)

**Missing in Day View:**
- **`cellInteractivityCallback: bool Function(BuildContext, MCalCellInteractivityDetails)?`**

**Impact:**
- Month View can disable interaction on specific cells (past dates, weekends, etc.)
- Day View cannot disable specific time slots
- Useful for business rules (e.g., no meetings before 9 AM)

**Recommendation:** **MEDIUM PRIORITY** — Add `timeSlotInteractivityCallback` to Day View

### 3.4 Builder-with-Default Pattern (**Severity: MEDIUM**)

**Missing in Day View:**
- Day View builders do NOT receive `Widget defaultWidget` parameter
- Month View builders receive default for wrapping/augmenting:
  - `dayCellBuilder(context, cellContext, defaultWidget)`
  - `eventTileBuilder(context, eventContext, defaultWidget)`
  - `dayHeaderBuilder(context, headerContext, defaultWidget)`
  - `dateLabelBuilder(context, labelContext, defaultString)`
  - `overflowIndicatorBuilder(context, overflowContext, defaultWidget)`

**Impact:**
- Month View builders can wrap/augment defaults (add badge, border)
- Day View builders must recreate entire widget from scratch
- Inconsistent API, more work for Day View developers

**Recommendation:** **MEDIUM PRIORITY** — Add default widget parameter to Day View builders (breaking change)

### 3.5 Date Label Interactions (**Severity: LOW**)

**Missing in Day View:**
- `onDateLabelTap`, `onDateLabelLongPress`

**Impact:** Not applicable — Day View has single day header, not per-cell date labels

**Recommendation:** Not needed (domain difference)

### 3.6 Advanced Navigation State Callbacks (**Severity: LOW**)

**Missing in Day View:**
- `onViewableRangeChanged`, `onFocusedRangeChanged`

**Impact:** Not applicable — Day View shows one day, no range concept

**Recommendation:** Not needed (domain difference)

### 3.7 Resize Handle Inset Customization (**Severity: LOW**)

**Missing in Day View:**
- **`resizeHandleInset: double Function(MCalEventTileContext, MCalResizeEdge)?`**

**Impact:**
- Month View allows custom resize handle positioning
- Day View handles always at tile edges
- Useful for custom tile shapes (centered pill with inset handles)

**Recommendation:** **LOW PRIORITY** — Add `resizeHandleInset` to Day View

### 3.8 Week Numbers & Layout (N/A - Domain-Specific)

**Missing in Day View:**
- `showWeekNumbers`, `weekNumberBuilder`, `weekLayoutBuilder`, `firstDayOfWeek`

**Impact:** Not applicable — Month View specific

**Recommendation:** Not needed (domain difference)

---

## 4. API Inconsistencies

### 4.1 Naming Inconsistencies (**Severity: MEDIUM**)

| Feature | Day View | Month View | Issue |
|---------|----------|------------|-------|
| Week number | `showWeekNumber` (singular) | `showWeekNumbers` (plural) | Inconsistent pluralization |
| Drop target | `showDropTargetPreview` | `showDropTargetTiles` | Different terminology |
| Date format | `DateFormat?` (intl object) | `String?` | Different types |

**Recommendation:**
- Standardize to `showWeekNumbers` (plural)
- Use consistent terminology: `showDropTargetPreview` OR `showDropTargetTiles`
- Change Month View to `DateFormat?` (breaking change)

### 4.2 Callback Return Type Inconsistencies (**Severity: HIGH**)

| Callback | Day View | Month View | Issue |
|----------|----------|------------|-------|
| `onEventDropped` | **void** | **bool** | Day View cannot revert drops |
| `onEventResized` | **void** | **bool** | Day View cannot revert resizes |

**Impact:**
- Month View can confirm/revert by returning true/false
- Day View cannot revert (void return)
- Error recovery only works in Month View
- Migration between views requires callback rewrite

**Recommendation:** **HIGH PRIORITY** — Change Day View callbacks to return `bool` (breaking change, major version bump)

### 4.3 BuildContext in Callbacks (**Severity: LOW**)

- Generally consistent: most callbacks receive `BuildContext` as first parameter
- Hover callbacks use `ValueChanged<T?>` (no context)

**Recommendation:** Current consistency is acceptable, document pattern

### 4.4 Builder Parameter Order (**Severity: LOW**)

- Both views use `(BuildContext, Data, [Widget?])` pattern
- Month View adds default widget where appropriate

**Recommendation:** Already consistent, document patterns

---

## 5. Theme Property Comparison

### 5.1 Shared Theme Properties

Both views share parent `MCalThemeData` properties:
- Event tile colors, text styles, borders
- Common UI colors (focus, hover, selection)
- Typography, spacing, padding
- Drag-and-drop visual styling

### 5.2 Day View Theme (30 properties in `MCalDayThemeData`)

**Categories:**
- **Time Legend (7):** width, text style, background, ticks (show, color, width, length)
- **Gridlines (6):** hour, major, minor (color, width for each)
- **Current Time Indicator (3):** color, width, dot radius
- **Day Header (3):** day of week style, date style, week number color
- **Timed Events (3):** min height, border radius, padding
- **Time Regions (5):** special/blocked colors, border, text color/style
- **Resize Handles (2):** size, min duration for handles
- **All-Day Section (1):** max rows

### 5.3 Month View Theme (40 properties in `MCalMonthThemeData`)

**Categories:**
- **Cell Styling (10):** background, border, text, today, leading/trailing dates, focused, hover
- **Weekday Headers (2):** text style, background
- **Week Numbers (2):** text style, background
- **Event Tiles (11):** height, spacing, corner radius, border, multi-day/all-day colors/styles, hover
- **Date Labels (2):** height, **position (enum: topLeft, topCenter, topRight)**
- **Overflow (1):** indicator height
- **Drag-and-Drop (9):** drop target cell/tile colors, drag source opacity, dragged elevation
- **Navigator (2):** text style, background

### 5.4 Theme Property Gaps

| Feature | Gap | Severity |
|---------|-----|----------|
| Date label positioning | Day View missing `DateLabelPosition` equivalent | **MEDIUM** |
| Sub-hour time labels | Day View cannot configure 10/15/20/30-min labels | LOW |
| Cell hover | Day View missing `hoverCellBackgroundColor` for time slots | LOW |
| Event hover | Day View missing `hoverEventBackgroundColor` | LOW |

**Recommendation:** Add date label/time label positioning to Day View theme

---

## 6. Specific Gaps to Highlight

### 6.1 Day View Missing DateLabelPosition Equivalent (**MEDIUM**)

- **Month View:** `dateLabelPosition` enum (topLeft, topCenter, topRight)
- **Day View:** No equivalent

**Recommendation:** Add time label alignment option

### 6.2 Day View Missing Configurable Sub-Hour Time Labels (**LOW**)

- Day View shows time labels only at hour boundaries
- No control over sub-hour label visibility (10/15/20/30-minute marks)

**Recommendation:** Add `showSubHourLabels`, `subHourLabelBuilder`, `subHourLabelInterval`

### 6.3 Day View onEventDropped/onEventResized Return Void (**HIGH**)

- **Month View:** Returns `bool` to confirm/revert
- **Day View:** Returns `void` (cannot revert)

**Recommendation:** **HIGH PRIORITY** — Change to `bool` return (breaking change)

### 6.4 Day View Missing onEventDoubleTap (**HIGH**)

- **Month View:** Has `onEventDoubleTap`
- **Day View:** Has `onEmptySpaceDoubleTap` but NO `onEventDoubleTap`

**Recommendation:** **HIGH PRIORITY** — Add `onEventDoubleTap`

### 6.5 Day View Builders Not Following Builder-with-Default Pattern (**MEDIUM**)

- **Month View:** Builders receive default widget
- **Day View:** Builders must recreate from scratch

**Recommendation:** Add default widget parameter (breaking change)

### 6.6 Month View Missing Keyboard CRUD Callbacks (**HIGH**)

- **Day View:** Has `onCreateEventRequested`, `onDeleteEventRequested`, `onEditEventRequested`
- **Month View:** No keyboard CRUD support

**Recommendation:** **HIGH PRIORITY** — Add keyboard CRUD to Month View

### 6.7 Month View Missing keyboardShortcuts Map (**HIGH**)

- **Day View:** `keyboardShortcuts` allows custom Intent/Activator mapping
- **Month View:** No customizable shortcuts

**Recommendation:** **HIGH PRIORITY** — Add `keyboardShortcuts` to Month View

---

## 7. Recommendations for Future Alignment

### 7.1 High Priority (User Experience Gaps)

1. **Add keyboard CRUD to Month View**
   - `onCreateEventRequested`, `onDeleteEventRequested`, `onEditEventRequested`, `keyboardShortcuts`
   - Effort: Medium

2. **Add `onEventDoubleTap` to Day View**
   - Effort: Low

3. **Standardize drag callback return types**
   - Change Day View `onEventDropped`/`onEventResized` to return `bool`
   - **Breaking change** — major version bump
   - Effort: Low (implementation) + Medium (migration guide)

4. **Add swipe navigation to Day View**
   - `enableSwipeNavigation`, `swipeNavigationDirection`, `onSwipeNavigation`
   - Effort: Medium

### 7.2 Medium Priority (API Consistency)

5. **Adopt builder-with-default pattern in Day View**
   - **Breaking change** — major version bump
   - Effort: Medium

6. **Add per-button navigation callbacks to Month View**
   - `onNavigatePrevious`, `onNavigateNext`, `onNavigateToday`
   - Effort: Low

7. **Add `timeSlotInteractivityCallback` to Day View**
   - Equivalent to Month View's `cellInteractivityCallback`
   - Effort: Medium

8. **Add `resizeHandleInset` to Day View**
   - Effort: Low

9. **Standardize naming**
   - `showWeekNumbers` (plural), consistent drop target naming, `DateFormat?` type
   - **Breaking changes**
   - Effort: Low

### 7.3 Low Priority (Enhancements)

10. **Add sub-hour time label customization to Day View**
    - `showSubHourLabels`, `subHourLabelBuilder`, `subHourLabelInterval`
    - Effort: Medium

11. **Add time label positioning to Day View theme**
    - Effort: Low

12. **Add hover styling to Day View**
    - `hoverCellBackgroundColor`, `hoverEventBackgroundColor`
    - Effort: Low

### 7.4 Documentation

13. **Document builder patterns**
    - Explain builder-with-default vs builder-only
    - Migration guides
    - Effort: Low

14. **API consistency checklist**
    - Process for ensuring parity in future features
    - Effort: Low

---

## 8. Summary Statistics

| Metric | Day View | Month View |
|--------|----------|------------|
| Constructor parameters | 68 | 56 |
| Builders | 13 | 9 |
| Callbacks | 21 | 17 |
| Theme properties | 30 | 40 |
| View-specific features | 21 | 8 |
| High-severity gaps | 3 | 3 |
| Medium-severity gaps | 4 | 3 |
| Low-severity gaps | 4 | 1 |

---

## 9. Conclusion

Critical gaps requiring attention:

**Day View HIGH Priority:**
- Add `onEventDoubleTap`
- Change drag callbacks to return `bool` (breaking)
- Add swipe navigation

**Month View HIGH Priority:**
- Add keyboard CRUD callbacks (`onCreateEventRequested`, `onDeleteEventRequested`, `onEditEventRequested`)
- Add `keyboardShortcuts` map

**Both Views:**
- Standardize naming (showWeekNumbers, dateFormat type)
- Standardize callback signatures (return types)
- Consider builder-with-default pattern for Day View (breaking)

Addressing these will significantly improve API consistency, developer experience, and accessibility.

---

**End of Analysis**
