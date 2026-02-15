## [Unreleased]

### Day View Release (version TBD)

The Day View (`MCalDayView`) is a new vertical timeline calendar view displaying a single day's schedule. It complements the existing Month View with hour-by-hour visibility, overlap handling for concurrent events, and precise time-based drag-and-drop interactions.

#### Added

**Core Day View Widget and Components**

- **`MCalDayView`** - Main day view widget with configurable time range (startHour/endHour), day header, all-day section, and timed events area
- **`MCalDayViewState`** - State object with `scrollToTime()`, `scrollToEvent()`, and `MCalDayViewCreateEventIntent`/`MCalDayViewEditEventIntent`/`MCalDayViewDeleteEventIntent` for Actions
- **`MCalTimeRegion`** - Model for special time regions (lunch breaks, non-working hours) with optional interaction blocking and RFC 5545 RRULE recurrence support

**Context Objects** (for builder callbacks)

- `MCalDayHeaderContext` - Day of week, date, optional ISO 8601 week number
- `MCalTimeLabelContext` - Hour, minute, formatted time string for time legend
- `MCalGridlineContext` - Hour, minute, offset, `MCalGridlineType` (hour/major/minor)
- `MCalTimedEventTileContext` - Event, column index, total columns, start/end time, drop preview state
- `MCalAllDayEventTileContext` - Event, display date, drop preview state
- `MCalCurrentTimeContext` - Current time and vertical offset
- `MCalTimeSlotContext` - Display date, hour, minute, offset, isAllDayArea for empty slot gestures
- `MCalTimeRegionContext` - Region data, display date, positioning, isBlocked
- `MCalDayLayoutContext` - Events, date, time range, dimensions for custom layout builders

**Callback Detail Classes**

- `MCalDropOverlayDetails` - Highlighted time slots, dragged event, proposed times, validation state
- `MCalTimeSlotRange` - Start/end time, top offset, height for overlay
- `MCalDragSourceDetails` - Event, source date/time, isAllDay
- `MCalDraggedTileDetails` - Event, source date, position, isAllDay
- `MCalEventDroppedDetails.typeConversion` - `'allDayToTimed'` or `'timedToAllDay'` when event type changes during drag

**Time Utilities**

- `lib/src/utils/time_utils.dart` - `timeToOffset()`, `offsetToTime()`, `durationToHeight()`, `snapToTimeSlot()`, `snapToNearbyTime()`, `isWithinSnapRange()`
- `lib/src/utils/day_view_overlap.dart` - Overlap detection for concurrent timed events (column assignment algorithm)

**Features (FR-1 through FR-16)**

- **FR-1 Time Legend** - Hour labels with locale-aware formatting, RTL support, configurable width
- **FR-2 Gridlines** - Hour and half-hour gridlines with theme customization
- **FR-3 Day Header** - Date/day-of-week display, optional week number, tap/long-press callbacks
- **FR-4 All-Day Events** - Dedicated section with drag-to-move, resize, overflow indicator, event type conversion
- **FR-5 Timed Events Layout** - Vertical positioning by time, overlap detection, column-based layout (Google Calendar-style)
- **FR-6 Overlap Detection** - O(n²) algorithm, equal column widths, `dayLayoutBuilder` for custom layouts
- **FR-7 Current Time Indicator** - Horizontal line with dot, auto-update every minute, themed
- **FR-8 Vertical Scrolling** - Auto-scroll to current time, `scrollToTime()`/`scrollToEvent()`, configurable physics
- **FR-9 Day Navigator** - Previous/Today/Next buttons, minDate/maxDate, `navigatorBuilder`
- **FR-10 Drag-to-Move** - Time-based with snap-to-slots, event type conversion (all-day ↔ timed)
- **FR-11 Cross-Day Navigation** - Edge drag to previous/next day during drag
- **FR-12 Drag-to-Resize** - Top/bottom edges, cross-day navigation, `timeResizeHandleBuilder`
- **FR-13 Keyboard Navigation** - Arrow keys for day/event focus, Home/PageUp/PageDown
- **FR-14 Keyboard Move Mode** - Enter/Space to move, arrows to adjust, Enter to confirm, Escape to cancel
- **FR-15 Keyboard Resize Mode** - R to resize, S/E for edge, arrows to adjust
- **FR-16 Empty Time Slot Interactions** - `onTimeSlotTap`, `onTimeSlotLongPress`, `onTimeLabelTap`, `onHoverTimeSlot`

**Additional Features**

- **Special Time Regions** - `MCalTimeRegion` with visual styling, `blockInteraction`, recurrence rules
- **Snap-to-Time** - Snap to time slots, nearby events, current time during drag/resize
- **Empty Slot Gestures** - Tap/long-press for event creation, `MCalTimeSlotContext`
- **Theme Integration** - `timeLegendWidth`, `hourGridlineColor`, `currentTimeIndicatorColor`, `allDaySectionHeight`, etc.
- **Builder Callbacks** - `dayHeaderBuilder`, `timeLabelBuilder`, `allDayEventTileBuilder`, `timedEventTileBuilder`, `currentTimeIndicatorBuilder`, `gridlineBuilder`, `dayLayoutBuilder`, `draggedTileBuilder`, `dropTargetTileBuilder`, `timeRegionBuilder`, `timeResizeHandleBuilder`
- **RTL Support** - Full right-to-left layout for Arabic, Hebrew

**Accessibility**

- Full keyboard navigation (arrows, Home, PageUp/PageDown, Tab)
- Keyboard event move and resize modes
- Screen reader semantic labels
- Focus indicators for events

**Documentation**

- `docs/day_view.md` - Comprehensive Day View guide
- `docs/day_view_migration.md` - Migration from third-party widgets
- `docs/best_practices.md` - Event controller, theme, builders, performance, accessibility
- `docs/troubleshooting.md` - Common issues and solutions
- Dartdoc on all public APIs

#### Changed

- **Month View code organization** - Renamed month-view-specific files/classes (Phase 0): `MCalDefaultWeekLayoutBuilder` → `MCalMonthDefaultWeekLayoutBuilder`, `MCalMultiDayTile` → `MCalMonthMultiDayTile`, etc. See Migration Guide for details.

#### Performance

- Viewport-based calculations for efficient rendering
- Overlap detection algorithm optimized for typical event counts
- Timer cancellation on dispose to prevent memory leaks

---

### Breaking Changes (Month View - existing)

- **Renamed `maxVisibleEvents` to `maxVisibleEventsPerDay`** - Default changed from 3 to 5. Now correctly respects both height constraints AND this limit for overflow indicator display.
- **Removed `theme` parameter from `MCalMonthView`** - Theme must now be provided via `MCalTheme` widget wrapper, `Theme.of(context).extension<MCalThemeData>()`, or defaults. This is consistent with standard Flutter theming patterns.
- **Moved `initialDate` from `MCalMonthView` to `MCalEventController`** - The initial date is now set via the controller constructor: `MCalEventController(initialDate: DateTime(2024, 6, 1))`. This provides a single source of truth for the display date.
- **Removed `renderMultiDayEventsAsContiguous` parameter** - The new layered architecture always renders events contiguously. Use custom `weekLayoutBuilder` for alternative layouts like dots.
- **Removed `multiDayEventTileBuilder` parameter** - Replaced by unified `eventTileBuilder` that receives `MCalEventSegment` info for both single-day and multi-day events.
- **Changed `eventTileBuilder` signature** - Now receives `MCalEventTileContext` with segment information (isFirstSegment, isLastSegment, etc.) via `MCalMonthEventSegment`

### Added

- **3-Layer Stack Architecture** - MCalMonthView now uses Layer 1 (grid), Layer 2 (events/labels), Layer 3 (drag ghost)
- **`weekLayoutBuilder` parameter** - Complete control over event layout within week rows
- **`overflowIndicatorBuilder` parameter** - Customize overflow indicator appearance
- **`MCalMonthWeekLayoutContext`** - Context object for week layout builders with segments, dates, and wrapped builders
- **`MCalMonthEventSegment`** - Unified segment model for single-day and multi-day events
- **`MCalMonthDefaultWeekLayoutBuilder`** - Default layout implementation (greedy first-fit algorithm)
- **`DateLabelPosition` enum** - 6 positions for date labels (topLeft, topCenter, topRight, bottomLeft, bottomCenter, bottomRight)
- **`MCalOverflowTapDetails`** - Details object for overflow tap callbacks with hidden and visible events
- **Theme properties** - `dateLabelHeight`, `dateLabelPosition`, `overflowIndicatorHeight`, `eventTileCornerRadius`

### Migration Guide

1. Replace `MCalMonthView(theme: myTheme)` with `MCalTheme(data: myTheme, child: MCalMonthView(...))`
2. Move `initialDate` from `MCalMonthView` to `MCalEventController` constructor
3. Remove `renderMultiDayEventsAsContiguous` - use `weekLayoutBuilder` for custom layouts
4. Move `multiDayEventTileBuilder` logic into `eventTileBuilder` using `segment.isFirstSegment`/`isLastSegment`
5. For dots-style calendars, provide a custom `weekLayoutBuilder` (see minimal_style.dart example)

## 0.0.1

* Initial release with foundation scaffolding
* MCalCalendarEvent model with all required fields (id, title, start, end, isAllDay, comment, externalId, occurrenceId)
* MCalEventController skeleton with placeholder methods
* MCalLocalizations scaffolding with English and Mexican Spanish support
* Basic example application demonstrating package usage
* All-day event support via `isAllDay` field in MCalCalendarEvent