# Feature Disparity Analysis: MCalDayView vs MCalMonthView

## Executive Summary

This document provides a comprehensive comparison of `MCalDayView` and `MCalMonthView` widget APIs, identifying feature gaps, API inconsistencies, and opportunities for alignment. The analysis covers widget parameters, callbacks, builders, theme properties, and interaction patterns.

**Key Findings:**
- **Day View has 68 widget parameters**, Month View has **56 parameters** (as counted in constructors)
- **Critical gaps exist in both directions** affecting keyboard navigation, gesture handling, and customization patterns
- **API inconsistencies** in naming, callback signatures, and return types create developer confusion
- **Builder pattern inconsistencies** between views reduce code reusability

---

## 1. Complete Widget Parameter Comparison

### 1.1 MCalDayView Parameters (68 total)

#### Core & Controller
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `controller` | `MCalEventController` | required | Event controller managing calendar events and display date |
| `key` | `Key?` | null | Widget key |

#### Time Configuration (4 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `startHour` | `int` | 0 | Starting hour of day view (0-23) |
| `endHour` | `int` | 23 | Ending hour of day view (0-23) |
| `timeSlotDuration` | `Duration` | 15 min | Time slot granularity for snapping |
| `hourHeight` | `double?` | null | Pixel height of one hour (auto-calculated if null) |

#### Display Options (7 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `showNavigator` | `bool` | false | Show navigation bar with prev/today/next buttons |
| `showCurrentTimeIndicator` | `bool` | true | Show current time indicator line |
| `showWeekNumber` | `bool` | false | Show ISO 8601 week number in header |
| `gridlineInterval` | `Duration` | 15 min | Interval between gridlines |
| `dateFormat` | `DateFormat?` | null | Custom date format for day header |
| `timeLabelFormat` | `DateFormat?` | null | Custom time format for time legend |
| `locale` | `Locale?` | null | Locale for date/time formatting |

#### Scrolling (4 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `autoScrollToCurrentTime` | `bool` | true | Auto-scroll to current time on load |
| `initialScrollTime` | `TimeOfDay?` | null | Specific time to scroll to on load |
| `scrollPhysics` | `ScrollPhysics?` | null | Scroll physics for timed events area |
| `scrollController` | `ScrollController?` | null | External scroll controller |

#### All-Day Events (2 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `allDaySectionMaxRows` | `int` | 3 | Max rows for all-day events before overflow |
| `allDayToTimedDuration` | `Duration` | 1 hour | Default duration when converting all-day to timed |

#### Drag & Drop (8 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enableDragToMove` | `bool` | false | Enable drag-to-move events |
| `enableDragToResize` | `bool?` | null | Enable drag-to-resize (auto-detect platform) |
| `dragEdgeNavigationEnabled` | `bool` | true | Enable cross-day navigation at edges during drag |
| `dragLongPressDelay` | `Duration` | 200ms | Delay before drag initiates |
| `dragEdgeNavigationDelay` | `Duration` | 1200ms | Delay before edge navigation triggers |
| `showDropTargetPreview` | `bool` | true | Show preview tile at drop position |
| `showDropTargetOverlay` | `bool` | true | Show overlay highlighting drop target |
| `dropTargetTilesAboveOverlay` | `bool` | false | Z-order: tiles above overlay |

#### Snapping (4 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `snapToTimeSlots` | `bool` | true | Snap to time slot boundaries |
| `snapToOtherEvents` | `bool` | true | Magnetic snap to other event edges |
| `snapToCurrentTime` | `bool` | true | Magnetic snap to current time indicator |
| `snapRange` | `Duration` | 5 min | Range within which magnetic snapping occurs |

#### Special Time Regions (1 param)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `specialTimeRegions` | `List<MCalTimeRegion>` | [] | Time regions (lunch, blocked time, etc.) |

#### Keyboard Navigation (3 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enableKeyboardNavigation` | `bool` | true | Enable keyboard navigation |
| `autoFocusOnEventTap` | `bool` | true | Auto-focus event when tapped |
| `keyboardShortcuts` | `Map<ShortcutActivator, Intent>?` | null | **Custom/override keyboard shortcuts map** |

#### Animations (3 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enableAnimations` | `bool?` | null | Enable animations (null = respect system reduced motion) |
| `animationDuration` | `Duration` | 300ms | Animation duration |
| `animationCurve` | `Curve` | easeInOut | Animation curve |

#### Date Boundaries (2 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `minDate` | `DateTime?` | null | Minimum navigable date |
| `maxDate` | `DateTime?` | null | Maximum navigable date |

#### Builders (16 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `dayHeaderBuilder` | `Widget Function(BuildContext, MCalDayHeaderContext)?` | null | Custom day header |
| `timeLabelBuilder` | `Widget Function(BuildContext, MCalTimeLabelContext)?` | null | Custom time labels |
| `gridlineBuilder` | `Widget Function(BuildContext, MCalGridlineContext)?` | null | Custom gridlines |
| `allDayEventTileBuilder` | `Widget Function(BuildContext, MCalCalendarEvent, MCalAllDayEventTileContext)?` | null | Custom all-day event tiles |
| `timedEventTileBuilder` | `Widget Function(BuildContext, MCalCalendarEvent, MCalTimedEventTileContext)?` | null | Custom timed event tiles |
| `currentTimeIndicatorBuilder` | `Widget Function(BuildContext, MCalCurrentTimeContext)?` | null | Custom current time indicator |
| `navigatorBuilder` | `Widget Function(BuildContext, DateTime)?` | null | Custom navigator |
| `dayLayoutBuilder` | `Widget Function(BuildContext, MCalDayLayoutContext)?` | null | Custom day layout (advanced) |
| `draggedTileBuilder` | `Widget Function(BuildContext, MCalCalendarEvent, MCalDraggedTileDetails)?` | null | Custom dragged tile feedback |
| `dragSourceTileBuilder` | `Widget Function(BuildContext, MCalCalendarEvent, MCalDragSourceDetails)?` | null | Custom drag source placeholder |
| `dropTargetTileBuilder` | `Widget Function(BuildContext, MCalCalendarEvent, MCalTimedEventTileContext)?` | null | Custom drop target preview |
| `dropTargetOverlayBuilder` | `Widget Function(BuildContext, MCalDayViewDropOverlayDetails)?` | null | Custom drop target overlay |
| `timeResizeHandleBuilder` | `Widget Function(BuildContext, MCalCalendarEvent, MCalResizeEdge)?` | null | Custom resize handles |
| `loadingBuilder` | `Widget Function(BuildContext)?` | null | Custom loading state |
| `errorBuilder` | `Widget Function(BuildContext, Object)?` | null | Custom error state |
| `timeRegionBuilder` | `Widget Function(BuildContext, MCalTimeRegionContext)?` | null | Custom time regions |

#### Navigation Callbacks (3 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `onNavigatePrevious` | `VoidCallback?` | null | **Called when Previous button pressed** |
| `onNavigateNext` | `VoidCallback?` | null | **Called when Next button pressed** |
| `onNavigateToday` | `VoidCallback?` | null | **Called when Today button pressed** |

#### Interaction Callbacks (12 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `onDayHeaderTap` | `void Function(DateTime)?` | null | Day header tapped |
| `onDayHeaderLongPress` | `void Function(DateTime)?` | null | Day header long-pressed |
| `onTimeLabelTap` | `void Function(MCalTimeLabelContext)?` | null | Time label tapped |
| `onTimeSlotTap` | `void Function(MCalTimeSlotContext)?` | null | Empty time slot tapped |
| `onTimeSlotLongPress` | `void Function(MCalTimeSlotContext)?` | null | Empty time slot long-pressed |
| `onEmptySpaceDoubleTap` | `void Function(DateTime)?` | null | Empty space double-tapped |
| `onEventTap` | `void Function(BuildContext, MCalEventTapDetails)?` | null | Event tile tapped |
| `onEventLongPress` | `void Function(BuildContext, MCalEventTapDetails)?` | null | Event tile long-pressed |
| `onHoverEvent` | `void Function(MCalCalendarEvent)?` | null | Pointer hovers over event |
| `onHoverTimeSlot` | `void Function(MCalTimeSlotContext)?` | null | Pointer hovers over time slot |
| `onOverflowTap` | `void Function(List<MCalCalendarEvent>, DateTime)?` | null | Overflow indicator tapped |
| `onOverflowLongPress` | `void Function(List<MCalCalendarEvent>, DateTime)?` | null | Overflow indicator long-pressed |

#### Keyboard Shortcut Callbacks (3 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `onCreateEventRequested` | `VoidCallback?` | null | **Cmd/Ctrl+N to create new event** |
| `onDeleteEventRequested` | `void Function(MCalCalendarEvent)?` | null | **Delete/Backspace to delete focused event** |
| `onEditEventRequested` | `void Function(MCalCalendarEvent)?` | null | **Cmd/Ctrl+E to edit focused event** |

#### Drag & Drop Callbacks (4 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `onDragWillAccept` | `bool Function(MCalEventDroppedDetails)?` | null | Validate drop acceptance |
| `onEventDropped` | `void Function(MCalEventDroppedDetails)?` | null | **Event dropped (returns void)** |
| `onResizeWillAccept` | `bool Function(MCalEventResizedDetails)?` | null | Validate resize acceptance |
| `onEventResized` | `void Function(MCalEventResizedDetails)?` | null | **Event resized (returns void)** |

#### State Change Callbacks (2 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `onDisplayDateChanged` | `void Function(DateTime)?` | null | Display date changed |
| `onScrollChanged` | `void Function(double)?` | null | Scroll offset changed |

#### Accessibility (1 param)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `semanticsLabel` | `String?` | null | Semantic label for screen readers |

#### Theme (1 param)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `theme` | `MCalThemeData?` | null | Optional theme override |

---

### 1.2 MCalMonthView Parameters (56 total)

#### Core & Controller
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `controller` | `MCalEventController` | required | Event controller managing calendar events and display date |
| `key` | `Key?` | null | Widget key |

#### Date Boundaries & Display (4 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `minDate` | `DateTime?` | null | Minimum displayable date |
| `maxDate` | `DateTime?` | null | Maximum displayable date |
| `firstDayOfWeek` | `int?` | null | First day of week (0=Sunday, 1=Monday, etc.) |
| `showWeekNumbers` | `bool` | false | Show ISO 8601 week numbers |

#### Navigation (3 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `showNavigator` | `bool` | false | Show month navigator with prev/next buttons |
| `enableSwipeNavigation` | `bool` | false | **Enable swipe gestures for navigation** |
| `swipeNavigationDirection` | `MCalSwipeNavigationDirection` | horizontal | **Swipe direction (horizontal/vertical)** |

#### Builders (10 params - includes builder-with-default pattern)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `dayCellBuilder` | `Widget Function(BuildContext, MCalDayCellContext, Widget)?` | null | **Custom cell (receives default widget)** |
| `eventTileBuilder` | `Widget Function(BuildContext, MCalEventTileContext, Widget)?` | null | **Custom event tile (receives default widget)** |
| `dayHeaderBuilder` | `Widget Function(BuildContext, MCalMonthDayHeaderContext, Widget)?` | null | **Custom day header (receives default widget)** |
| `navigatorBuilder` | `Widget Function(BuildContext, MCalNavigatorContext, Widget)?` | null | **Custom navigator (receives default widget)** |
| `dateLabelBuilder` | `Widget Function(BuildContext, MCalDateLabelContext, String)?` | null | Custom date label (receives default string) |
| `weekNumberBuilder` | `Widget Function(BuildContext, MCalWeekNumberContext)?` | null | Custom week number |
| `weekLayoutBuilder` | `MCalWeekLayoutBuilder?` | null | Custom week row event layout |
| `overflowIndicatorBuilder` | `Widget Function(BuildContext, MCalMonthOverflowIndicatorContext, Widget)?` | null | **Custom overflow indicator (receives default widget)** |
| `loadingBuilder` | `Widget Function(BuildContext)?` | null | Custom loading state |
| `errorBuilder` | `Widget Function(BuildContext, MCalErrorDetails)?` | null | Custom error state |

#### Cell Interactivity (1 param)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `cellInteractivityCallback` | `bool Function(BuildContext, MCalCellInteractivityDetails)?` | null | **Determine if cell is interactive (unique to Month View)** |

#### Tap/Press Callbacks (9 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `onCellTap` | `void Function(BuildContext, MCalCellTapDetails)?` | null | Cell tapped |
| `onCellLongPress` | `void Function(BuildContext, MCalCellTapDetails)?` | null | Cell long-pressed |
| `onDateLabelTap` | `void Function(BuildContext, MCalDateLabelTapDetails)?` | null | Date label tapped |
| `onDateLabelLongPress` | `void Function(BuildContext, MCalDateLabelTapDetails)?` | null | Date label long-pressed |
| `onEventTap` | `void Function(BuildContext, MCalEventTapDetails)?` | null | Event tile tapped |
| `onEventLongPress` | `void Function(BuildContext, MCalEventTapDetails)?` | null | Event tile long-pressed |
| `onCellDoubleTap` | `void Function(BuildContext, MCalCellDoubleTapDetails)?` | null | Cell double-tapped |
| `onEventDoubleTap` | `void Function(BuildContext, MCalEventDoubleTapDetails)?` | null | **Event tile double-tapped (missing in Day View)** |
| `onSwipeNavigation` | `void Function(BuildContext, MCalSwipeNavigationDetails)?` | null | **Swipe navigation detected** |

#### Formatting (2 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `dateFormat` | `String?` | null | **Custom date format (String, not DateFormat)** |
| `locale` | `Locale?` | null | Locale for formatting |

#### Hover Callbacks (2 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `onHoverCell` | `ValueChanged<MCalDayCellContext?>?` | null | Pointer hovers over cell |
| `onHoverEvent` | `ValueChanged<MCalEventTileContext?>?` | null | Pointer hovers over event |

#### Keyboard Navigation (1 param)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enableKeyboardNavigation` | `bool` | true | Enable keyboard navigation |

#### State Change Callbacks (4 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `onDisplayDateChanged` | `ValueChanged<DateTime>?` | null | Display date changed |
| `onViewableRangeChanged` | `ValueChanged<DateTimeRange>?` | null | Viewable range changed |
| `onFocusedDateChanged` | `ValueChanged<DateTime?>?` | null | Focused date changed |
| `onFocusedRangeChanged` | `ValueChanged<DateTimeRange?>?` | null | Focused range changed |

#### Cell Behavior (1 param)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `autoFocusOnCellTap` | `bool` | true | Auto-focus cell when tapped |

#### Overflow Handling (2 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `onOverflowTap` | `void Function(BuildContext, MCalOverflowTapDetails)?` | null | Overflow indicator tapped |
| `onOverflowLongPress` | `void Function(BuildContext, MCalOverflowTapDetails)?` | null | Overflow indicator long-pressed |

#### Animations (3 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enableAnimations` | `bool?` | null | Enable animations (null = respect system reduced motion) |
| `animationDuration` | `Duration` | 300ms | Animation duration |
| `animationCurve` | `Curve` | easeInOut | Animation curve |

#### Event Display (1 param)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `maxVisibleEventsPerDay` | `int` | 5 | Max events before overflow indicator |

#### Accessibility (1 param)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `semanticsLabel` | `String?` | null | Semantic label for screen readers |

#### Drag & Drop (11 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enableDragToMove` | `bool` | false | Enable drag-to-move events |
| `showDropTargetTiles` | `bool` | true | **Show drop target tiles (not "Preview")** |
| `showDropTargetOverlay` | `bool` | true | Show drop target overlay |
| `dropTargetTilesAboveOverlay` | `bool` | false | Z-order: tiles above overlay |
| `draggedTileBuilder` | `Widget Function(BuildContext, MCalDraggedTileDetails)?` | null | Custom dragged tile |
| `dragSourceTileBuilder` | `Widget Function(BuildContext, MCalDragSourceDetails)?` | null | Custom drag source placeholder |
| `dropTargetTileBuilder` | `MCalEventTileBuilder?` | null | Custom drop target preview |
| `dropTargetCellBuilder` | `Widget Function(BuildContext, MCalDropTargetCellDetails)?` | null | **Custom drop target cell appearance** |
| `dropTargetOverlayBuilder` | `Widget Function(BuildContext, MCalDropOverlayDetails)?` | null | Custom drop target overlay |
| `onDragWillAccept` | `bool Function(BuildContext, MCalDragWillAcceptDetails)?` | null | Validate drop acceptance |
| `onEventDropped` | `bool Function(BuildContext, MCalEventDroppedDetails)?` | null | **Event dropped (returns bool)** |

#### Event Resize (5 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enableDragToResize` | `bool?` | null | Enable drag-to-resize (auto-detect platform) |
| `onResizeWillAccept` | `bool Function(BuildContext, MCalResizeWillAcceptDetails)?` | null | Validate resize acceptance |
| `onEventResized` | `bool Function(BuildContext, MCalEventResizedDetails)?` | null | **Event resized (returns bool)** |
| `resizeHandleBuilder` | `Widget Function(BuildContext, MCalResizeHandleContext)?` | null | Custom resize handle visual |
| `resizeHandleInset` | `double Function(MCalEventTileContext, MCalResizeEdge)?` | null | **Resize handle inset positioning** |

#### Drag Timing (3 params)
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `dragEdgeNavigationEnabled` | `bool` | true | Enable cross-month navigation at edges during drag |
| `dragEdgeNavigationDelay` | `Duration` | 1200ms | Delay before edge navigation triggers |
| `dragLongPressDelay` | `Duration` | 200ms | Delay before drag initiates |

---

## 2. Features Day View Has But Month View Lacks

### 2.1 Critical Gaps (High Severity)

#### Keyboard Shortcut CRUD Operations
- **Missing:** `onCreateEventRequested` callback
- **Missing:** `onDeleteEventRequested` callback
- **Missing:** `onEditEventRequested` callback
- **Impact:** Month View cannot support keyboard-driven event creation/editing/deletion workflows
- **Severity:** **HIGH** — Accessibility and power-user feature gap

#### Custom Keyboard Shortcuts Map
- **Missing:** `keyboardShortcuts` parameter (`Map<ShortcutActivator, Intent>?`)
- **Impact:** Cannot override or customize keyboard shortcuts in Month View
- **Severity:** **HIGH** — Limits extensibility and localization of shortcuts

#### Per-Button Navigation Callbacks
- **Missing:** `onNavigatePrevious`, `onNavigateNext`, `onNavigateToday` individual callbacks
- **Impact:** Cannot intercept or customize behavior of individual navigator buttons
- **Month View has:** Only generic navigation via controller, no per-button hooks
- **Severity:** **MEDIUM** — Reduces flexibility for custom navigation logic

### 2.2 Time-Specific Features (Unique to Day View by Nature)

#### Time Configuration
- **Parameters:** `startHour`, `endHour`, `timeSlotDuration`, `hourHeight`
- **Reason:** Not applicable to Month View (no hourly timeline)

#### Gridlines & Time Labels
- **Parameters:** `gridlineInterval`, `timeLabelFormat`
- **Builders:** `timeLabelBuilder`, `gridlineBuilder`, `currentTimeIndicatorBuilder`
- **Callbacks:** `onTimeLabelTap`, `onTimeSlotTap`, `onTimeSlotLongPress`, `onHoverTimeSlot`
- **Reason:** Day View exclusive (no time grid in Month View)

#### Scrolling
- **Parameters:** `autoScrollToCurrentTime`, `initialScrollTime`, `scrollPhysics`, `scrollController`
- **Callbacks:** `onScrollChanged`
- **Reason:** Month View uses PageView (not scrolling timeline)

#### All-Day Event Configuration
- **Parameters:** `allDaySectionMaxRows`, `allDayToTimedDuration`
- **Reason:** Day View has dedicated all-day section; Month View treats all events uniformly

#### Snapping System
- **Parameters:** `snapToTimeSlots`, `snapToOtherEvents`, `snapToCurrentTime`, `snapRange`
- **Reason:** Time-based snapping only relevant for Day View's continuous timeline

#### Special Time Regions
- **Parameters:** `specialTimeRegions` (list of `MCalTimeRegion`)
- **Builder:** `timeRegionBuilder`
- **Reason:** Day View exclusive (blocked time, lunch breaks, etc.)

#### Advanced Layout Control
- **Builder:** `dayLayoutBuilder` (custom day event layout)
- **Reason:** Day View supports advanced column-based overlap layout customization

#### Day Header Interaction
- **Callbacks:** `onDayHeaderTap`, `onDayHeaderLongPress`
- **Reason:** Day View has prominent day header; Month View has per-cell structure

### 2.3 Specialized Builders
- **Missing in Month View:** `allDayEventTileBuilder`, `timedEventTileBuilder` (Month View has unified `eventTileBuilder`)
- **Missing in Month View:** `timeResizeHandleBuilder` (Month View has `resizeHandleBuilder` only)

---

## 3. Features Month View Has But Day View Lacks

### 3.1 Critical Gaps (High Severity)

#### Event Double-Tap Callback
- **Missing in Day View:** `onEventDoubleTap`
- **Present in Month View:** `onEventDoubleTap` callback with `MCalEventDoubleTapDetails`
- **Impact:** Day View users cannot open event editors via double-tap gesture
- **Severity:** **HIGH** — Common UX pattern missing

#### Swipe Navigation
- **Missing in Day View:** `enableSwipeNavigation`, `swipeNavigationDirection`, `onSwipeNavigation`
- **Impact:** Day View requires button presses for navigation; no gesture-based day switching
- **Severity:** **HIGH** — Mobile UX gap

#### Cell Interactivity Control
- **Missing in Day View:** `cellInteractivityCallback`
- **Impact:** Cannot programmatically disable individual cells (e.g., disable past dates, weekends)
- **Month View use case:** Return false to make cells non-interactive
- **Severity:** **MEDIUM** — Flexibility gap for business logic

#### Builder-with-Default Pattern
- **Missing in Day View:** Builders that receive the default widget as third parameter
- **Month View pattern:** `dayCellBuilder`, `eventTileBuilder`, `dayHeaderBuilder`, `navigatorBuilder`, `overflowIndicatorBuilder` all receive `Widget defaultWidget` parameter
- **Impact:** Day View builders must fully recreate widgets; cannot wrap or augment defaults
- **Severity:** **HIGH** — Code reuse and customization flexibility gap

### 3.2 Cell-Specific Features

#### Date Label Interaction
- **Missing in Day View:** `onDateLabelTap`, `onDateLabelLongPress` callbacks
- **Reason:** Day View has single date in header; Month View has per-cell date labels
- **Severity:** **LOW** (by nature of views)

#### Cell Double-Tap
- **Missing in Day View:** `onCellDoubleTap` callback
- **Day View has:** `onEmptySpaceDoubleTap` (similar concept, different context)
- **Severity:** **LOW** (different interaction models)

#### Cell Hover
- **Missing in Day View:** `onHoverCell` callback
- **Day View has:** `onHoverTimeSlot` (roughly equivalent)
- **Severity:** **LOW** (different contexts)

### 3.3 Navigation & State Tracking

#### First Day of Week
- **Missing in Day View:** `firstDayOfWeek` parameter
- **Reason:** Day View shows single day; Month View shows week grid
- **Severity:** **LOW** (by nature)

#### Viewable Range & Focused Range Callbacks
- **Missing in Day View:** `onViewableRangeChanged`, `onFocusedRangeChanged`
- **Reason:** Day View has single date; Month View spans multiple weeks
- **Severity:** **LOW** (by nature)

### 3.4 Event Display

#### Max Visible Events Configuration
- **Missing in Day View:** `maxVisibleEventsPerDay` parameter
- **Reason:** Day View has all-day max rows, but timed events use vertical space dynamically
- **Month View use case:** Limits events per cell before "+N more" overflow
- **Severity:** **LOW** (different overflow models)

#### Week Layout Customization
- **Missing in Day View:** `weekLayoutBuilder` parameter
- **Reason:** Day View doesn't have week rows
- **Severity:** **LOW** (by nature)

#### Week Numbers
- **Missing in Day View:** `weekNumberBuilder` parameter (Day View has `showWeekNumber` bool only)
- **Impact:** Day View shows week number but cannot customize its appearance
- **Severity:** **LOW** — Minor customization gap

### 3.5 Drag & Drop Enhancements

#### Drop Target Cell Builder
- **Missing in Day View:** `dropTargetCellBuilder`
- **Impact:** Day View cannot customize individual drop target cell appearance during drag
- **Severity:** **MEDIUM** — Customization gap

#### Resize Handle Inset
- **Missing in Day View:** `resizeHandleInset` parameter
- **Month View use case:** Position resize handles inward for non-full-width tiles
- **Impact:** Day View resize handles always at tile edges
- **Severity:** **LOW** — Edge case customization

---

## 4. API Inconsistencies

### 4.1 Naming Inconsistencies

#### Week Number (Singular vs Plural)
- **Day View:** `showWeekNumber` (singular)
- **Month View:** `showWeekNumbers` (plural)
- **Impact:** Inconsistent API surface; developers must remember which view uses which name
- **Recommendation:** Standardize on `showWeekNumbers` (plural makes more sense for Month View showing multiple weeks)

#### Drop Target Preview vs Tiles
- **Day View:** `showDropTargetPreview` (conceptual name)
- **Month View:** `showDropTargetTiles` (implementation name)
- **Impact:** Same feature with different names
- **Recommendation:** Standardize on `showDropTargetTiles` (more concrete)

#### Date Format Type Inconsistency
- **Day View:** `dateFormat` is `DateFormat?` (intl package type)
- **Month View:** `dateFormat` is `String?` (format pattern string)
- **Impact:** Different parameter types for same concept; Month View must parse string internally
- **Recommendation:** Standardize on `DateFormat?` type for type safety

### 4.2 Callback Signature Inconsistencies

#### BuildContext Presence
- **Day View:** Most interaction callbacks include `BuildContext` as first parameter
  - Example: `void Function(BuildContext, MCalEventTapDetails)? onEventTap`
- **Month View:** All callbacks include `BuildContext`
  - Example: `void Function(BuildContext, MCalEventTapDetails)? onEventTap`
- **Day View exceptions:** `onHoverEvent`, `onHoverTimeSlot`, `onNavigatePrevious/Next/Today`, `onCreateEventRequested`, `onDeleteEventRequested`, `onEditEventRequested` do NOT include BuildContext
- **Impact:** Inconsistent callback signatures make it harder to reuse callback logic across views
- **Recommendation:** Always include `BuildContext` as first parameter for all callbacks

#### Return Type Inconsistencies (Critical)

##### Drag & Drop Callbacks
- **Day View `onEventDropped`:** `void Function(MCalEventDroppedDetails)?`
- **Month View `onEventDropped`:** `bool Function(BuildContext, MCalEventDroppedDetails)?`
- **Impact:** Month View can revert drop by returning false; Day View cannot
- **Severity:** **HIGH** — Feature capability mismatch

##### Resize Callbacks
- **Day View `onEventResized`:** `void Function(MCalEventResizedDetails)?`
- **Month View `onEventResized`:** `bool Function(BuildContext, MCalEventResizedDetails)?`
- **Impact:** Month View can revert resize by returning false; Day View cannot
- **Severity:** **HIGH** — Feature capability mismatch

**Recommendation:** Align to `bool Function(BuildContext, ...)` pattern for both callbacks in both views

### 4.3 Builder Pattern Inconsistencies

#### Builder-with-Default vs Builder-from-Scratch
- **Month View pattern:** Many builders receive `Widget defaultWidget` as third parameter
  - `dayCellBuilder(BuildContext, MCalDayCellContext, Widget defaultWidget)`
  - `eventTileBuilder(BuildContext, MCalEventTileContext, Widget defaultWidget)`
  - Allows wrapping or augmenting default widget
- **Day View pattern:** Builders do NOT receive default widget
  - `timedEventTileBuilder(BuildContext, MCalCalendarEvent, MCalTimedEventTileContext)`
  - Must fully recreate widget from scratch
- **Impact:** Month View builders are more flexible and code-reusable
- **Severity:** **HIGH** — Significant DX and code reuse gap
- **Recommendation:** Adopt builder-with-default pattern for ALL builders in both views

#### Event Tile Builder Signatures
- **Day View:** Separate `allDayEventTileBuilder` and `timedEventTileBuilder`
  - `allDayEventTileBuilder(BuildContext, MCalCalendarEvent, MCalAllDayEventTileContext)`
  - `timedEventTileBuilder(BuildContext, MCalCalendarEvent, MCalTimedEventTileContext)`
- **Month View:** Single unified `eventTileBuilder`
  - `eventTileBuilder(BuildContext, MCalEventTileContext, Widget)`
  - Context contains `isAllDay` bool to differentiate
- **Impact:** Different approaches to event type handling
- **Recommendation:** Evaluate which pattern is more ergonomic (likely Month View's unified approach)

#### Resize Handle Builder
- **Day View:** `timeResizeHandleBuilder` (specific name)
- **Month View:** `resizeHandleBuilder` (generic name)
- **Impact:** Naming inconsistency for same concept
- **Recommendation:** Standardize on `resizeHandleBuilder`

### 4.4 Context Object Inconsistencies

#### Error Builder Context
- **Day View:** `errorBuilder(BuildContext, Object error)`
- **Month View:** `errorBuilder(BuildContext, MCalErrorDetails)`
- **Impact:** Month View provides structured error context; Day View only passes raw error
- **Recommendation:** Adopt `MCalErrorDetails` pattern in Day View for consistency

---

## 5. Theme Property Comparison

### 5.1 Shared Theme Properties (via `MCalThemeData`)

Both views inherit these common theme properties from `MCalThemeData`:

- `eventTileBackgroundColor`
- `eventTileBorderColor`
- `eventTileBorderWidth`
- `eventTileTextStyle`
- `ignoreEventColors` (bool)
- `navigatorButtonBackgroundColor`
- `navigatorButtonForegroundColor`
- `navigatorButtonIconSize`
- `navigatorButtonSpacing`
- `allDayEventBackgroundColor`
- `allDayEventTextStyle`
- `allDayEventBorderColor`
- `allDayEventBorderWidth`

### 5.2 Day View Exclusive Theme Properties (via `MCalDayThemeData`)

#### Day Header (2 properties)
- `dayHeaderDayOfWeekStyle`
- `dayHeaderDateStyle`
- `weekNumberTextColor`

#### Time Legend (10 properties)
- `timeLegendWidth`
- `timeLegendTextStyle`
- `timeLegendBackgroundColor`
- `showTimeLegendTicks`
- `timeLegendTickColor`
- `timeLegendTickWidth`
- `timeLegendTickLength`

#### Gridlines (6 properties)
- `hourGridlineColor`
- `hourGridlineWidth`
- `majorGridlineColor`
- `majorGridlineWidth`
- `minorGridlineColor`
- `minorGridlineWidth`

#### Current Time Indicator (3 properties)
- `currentTimeIndicatorColor`
- `currentTimeIndicatorWidth`
- `currentTimeIndicatorDotRadius`

#### Timed Event Tiles (4 properties)
- `timedEventMinHeight`
- `timedEventBorderRadius`
- `timedEventPadding`

#### Time Regions (5 properties)
- `specialTimeRegionColor`
- `blockedTimeRegionColor`
- `timeRegionBorderColor`
- `timeRegionTextColor`
- `timeRegionTextStyle`

#### Resize Handles (2 properties)
- `resizeHandleSize`
- `minResizeDurationMinutes`

#### All-Day Section (1 property)
- `allDaySectionMaxRows`

**Total: 33 Day View exclusive theme properties**

### 5.3 Month View Exclusive Theme Properties (via `MCalMonthThemeData`)

#### Cell Styling (11 properties)
- `cellBackgroundColor`
- `cellBorderColor`
- `cellTextStyle`
- `todayBackgroundColor`
- `todayTextStyle`
- `leadingDatesTextStyle`
- `trailingDatesTextStyle`
- `leadingDatesBackgroundColor`
- `trailingDatesBackgroundColor`
- `focusedDateBackgroundColor`
- `focusedDateTextStyle`

#### Weekday Headers (2 properties)
- `weekdayHeaderTextStyle`
- `weekdayHeaderBackgroundColor`

#### Week Numbers (2 properties)
- `weekNumberTextStyle`
- `weekNumberBackgroundColor`

#### Hover States (2 properties)
- `hoverCellBackgroundColor`
- `hoverEventBackgroundColor`

#### Drag & Drop Visual Feedback (7 properties)
- `dropTargetCellValidColor`
- `dropTargetCellInvalidColor`
- `dropTargetCellBorderRadius`
- `dragSourceOpacity`
- `draggedTileElevation`

#### Event Tiles (9 properties)
- `multiDayEventBackgroundColor`
- `multiDayEventTextStyle`
- `eventTileHeight`
- `eventTileHorizontalSpacing`
- `eventTileVerticalSpacing`
- `eventTileCornerRadius`
- `eventTileBorderColor` (duplicate in shared, but Month-specific override)
- `eventTileBorderWidth` (duplicate in shared, but Month-specific override)

#### Date Labels (2 properties)
- `dateLabelHeight`
- `dateLabelPosition` (enum: `DateLabelPosition`)

#### Overflow Indicator (1 property)
- `overflowIndicatorHeight`

#### Drop Target Tiles (5 properties)
- `dropTargetTileBackgroundColor`
- `dropTargetTileInvalidBackgroundColor`
- `dropTargetTileCornerRadius`
- `dropTargetTileBorderColor`
- `dropTargetTileBorderWidth`

#### Navigator (2 properties)
- `navigatorTextStyle`
- `navigatorBackgroundColor`

**Total: 43 Month View exclusive theme properties**

### 5.4 Theme Property Gaps

#### Day View Missing (present in Month View)
- **DateLabelPosition:** Day View has no equivalent to `dateLabelPosition` (topLeft, topCenter, topRight, bottomLeft, bottomCenter, bottomRight, centerLeft, centerCenter, centerRight)
  - **Impact:** Day View date label position is fixed; Month View allows per-theme positioning
  - **Severity:** **MEDIUM** — Theme flexibility gap

- **Configurable Sub-Hour Time Labels:** Day View has no builder or theme properties for customizing minor time labels (10/15/20/30 min intervals with custom styles/builders)
  - **Month View equivalent:** `dateLabelBuilder` allows full customization of date labels
  - **Impact:** Day View time labels less customizable than Month View date labels
  - **Severity:** **MEDIUM** — Customization gap

---

## 6. Specific Gaps to Highlight

### 6.1 Day View Missing DateLabelPosition Equivalent
- **Month View has:** `dateLabelPosition` theme property (9 position options)
- **Day View:** Date in day header is fixed position (no configuration)
- **Severity:** **MEDIUM**
- **Use case:** Allow developers to position date number in different corners/centers of day header

### 6.2 Day View Missing Configurable Sub-Hour Time Labels
- **Current behavior:** Time labels are rendered at hour boundaries with fixed format
- **Missing:** Ability to render labels at 10/15/20/30-minute intervals with custom builders
- **Month View equivalent:** `dateLabelBuilder` provides full customization of date labels
- **Severity:** **MEDIUM**
- **Use case:** Compact layouts need fewer labels; detailed layouts want labels every 15 min

### 6.3 Return Type Mismatch: onEventDropped / onEventResized
- **Day View:** Both return `void`
- **Month View:** Both return `bool` (true = confirm, false = revert)
- **Impact:** Month View supports transactional drag/resize with backend validation; Day View cannot revert
- **Severity:** **HIGH**
- **Recommendation:** Add `bool` return type to Day View for consistency

### 6.4 Day View Missing onEventDoubleTap
- **Month View has:** `onEventDoubleTap` callback
- **Day View has:** `onEmptySpaceDoubleTap` but NOT `onEventDoubleTap`
- **Impact:** Common UX pattern for opening event editor is missing in Day View
- **Severity:** **HIGH**
- **Use case:** Double-tap event to open edit dialog

### 6.5 Day View Builders Not Following Builder-with-Default Pattern
- **Month View pattern:** Builders receive default widget as third parameter for wrapping/augmentation
- **Day View pattern:** Builders must recreate widgets from scratch
- **Impact:** Month View encourages composition; Day View requires full reimplementation
- **Severity:** **HIGH** — DX and code reuse gap
- **Recommendation:** Adopt Month View pattern across all builders

### 6.6 Month View Missing Keyboard CRUD Callbacks
- **Day View has:** `onCreateEventRequested`, `onDeleteEventRequested`, `onEditEventRequested`
- **Month View:** Must implement these via generic `onCellDoubleTap` or `onEventDoubleTap`
- **Impact:** No standardized keyboard-driven CRUD in Month View
- **Severity:** **HIGH** — Accessibility and power-user gap

### 6.7 Month View Missing keyboardShortcuts Map
- **Day View has:** `keyboardShortcuts` map for custom/override shortcuts
- **Month View:** No equivalent (relies on built-in shortcuts only)
- **Impact:** Cannot customize keyboard shortcuts in Month View
- **Severity:** **HIGH** — Extensibility gap

---

## 7. Recommendations for Future Alignment

### 7.1 API Naming Alignment
1. **Standardize on plural:** `showWeekNumbers` (both views)
2. **Standardize drop target naming:** `showDropTargetTiles` (both views)
3. **Standardize resize handle naming:** `resizeHandleBuilder` (both views)
4. **Unify dateFormat type:** Use `DateFormat?` type in both views (not `String?`)

### 7.2 Callback Signature Alignment
1. **Always include BuildContext:** Add `BuildContext` as first parameter to ALL callbacks in both views
2. **Adopt bool return pattern:** Change Day View `onEventDropped` and `onEventResized` to return `bool` (matching Month View)
3. **Standardize error handling:** Use `MCalErrorDetails` in Day View `errorBuilder` (matching Month View)

### 7.3 Builder Pattern Alignment
1. **Adopt builder-with-default pattern universally:** All builders in both views should receive default widget as last parameter
2. **Evaluate unified event tile builder:** Consider Day View adopting Month View's single `eventTileBuilder` with `isAllDay` context flag

### 7.4 Feature Parity
1. **Add to Day View:**
   - `onEventDoubleTap` callback (HIGH priority)
   - `cellInteractivityCallback` (MEDIUM priority)
   - `enableSwipeNavigation`, `swipeNavigationDirection`, `onSwipeNavigation` (MEDIUM priority for mobile UX)
   - `dropTargetCellBuilder` (LOW priority)

2. **Add to Month View:**
   - `onCreateEventRequested`, `onDeleteEventRequested`, `onEditEventRequested` callbacks (HIGH priority)
   - `keyboardShortcuts` map (HIGH priority)
   - `onNavigatePrevious`, `onNavigateNext`, `onNavigateToday` callbacks (MEDIUM priority)

3. **Theme Enhancements:**
   - Add `dateLabelPosition` equivalent to Day View for header positioning (MEDIUM priority)
   - Add sub-hour time label builder to Day View (MEDIUM priority)

### 7.5 Documentation & Migration
1. **Create API migration guide** documenting differences between views
2. **Provide code examples** showing how to achieve similar results in both views
3. **Establish naming conventions** for future parameters (plural vs singular, conceptual vs implementation names)
4. **Document "why not present" reasoning** for parameters that are intentionally view-specific

### 7.6 Testing & Validation
1. **Create unified test suite** covering both views with same test scenarios
2. **Validate callback parity** ensuring both views handle all common gestures (tap, long press, double tap, hover)
3. **Verify theme property coverage** ensuring both views support equivalent styling capabilities where appropriate

---

## Conclusion

This analysis reveals **significant feature and API inconsistencies** between `MCalDayView` and `MCalMonthView`. While some differences are justified by the nature of each view (e.g., time-based features in Day View, week layout in Month View), **critical gaps exist in both directions** that affect usability, accessibility, and developer experience.

### Priority Actions:
1. **HIGH:** Align callback return types (`onEventDropped`, `onEventResized` to `bool`)
2. **HIGH:** Add keyboard CRUD callbacks to Month View
3. **HIGH:** Add `onEventDoubleTap` to Day View
4. **HIGH:** Adopt builder-with-default pattern universally
5. **MEDIUM:** Standardize API naming (week numbers, drop targets, date format type)
6. **MEDIUM:** Add swipe navigation to Day View
7. **LOW:** Evaluate unified event tile builder pattern

Addressing these gaps will improve API consistency, enhance code reusability across views, and provide feature parity for common interaction patterns.
