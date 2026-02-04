## [Unreleased]

### Breaking Changes

- **Renamed `maxVisibleEvents` to `maxVisibleEventsPerDay`** - Default changed from 3 to 5. Now correctly respects both height constraints AND this limit for overflow indicator display.
- **Removed `theme` parameter from `MCalMonthView`** - Theme must now be provided via `MCalTheme` widget wrapper, `Theme.of(context).extension<MCalThemeData>()`, or defaults. This is consistent with standard Flutter theming patterns.
- **Moved `initialDate` from `MCalMonthView` to `MCalEventController`** - The initial date is now set via the controller constructor: `MCalEventController(initialDate: DateTime(2024, 6, 1))`. This provides a single source of truth for the display date.
- **Removed `renderMultiDayEventsAsContiguous` parameter** - The new layered architecture always renders events contiguously. Use custom `weekLayoutBuilder` for alternative layouts like dots.
- **Removed `multiDayEventTileBuilder` parameter** - Replaced by unified `eventTileBuilder` that receives `MCalEventSegment` info for both single-day and multi-day events.
- **Changed `eventTileBuilder` signature** - Now receives `MCalEventTileContext` with segment information (isFirstSegment, isLastSegment, etc.)

### Added

- **3-Layer Stack Architecture** - MCalMonthView now uses Layer 1 (grid), Layer 2 (events/labels), Layer 3 (drag ghost)
- **`weekLayoutBuilder` parameter** - Complete control over event layout within week rows
- **`overflowIndicatorBuilder` parameter** - Customize overflow indicator appearance
- **`MCalWeekLayoutContext`** - Context object for week layout builders with segments, dates, and wrapped builders
- **`MCalEventSegment`** - Unified segment model for single-day and multi-day events
- **`MCalDefaultWeekLayoutBuilder`** - Default layout implementation (greedy first-fit algorithm)
- **`DateLabelPosition` enum** - 6 positions for date labels (topLeft, topCenter, topRight, bottomLeft, bottomCenter, bottomRight)
- **`MCalOverflowTapDetails`** - Details object for overflow tap callbacks with hidden and visible events
- **Theme properties** - `dateLabelHeight`, `dateLabelPosition`, `overflowIndicatorHeight`, `tileCornerRadius`

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