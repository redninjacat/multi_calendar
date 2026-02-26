# Requirements Document

## Introduction

This specification defines a new layered architecture for MCalMonthView that fundamentally restructures how calendar grids, events, date labels, and drag-and-drop interactions are rendered. The current implementation has flaws in how multi-day events are rendered versus single-day events, leading to inconsistent layouts and limited customization options. The new architecture uses a 3-layer Stack approach where each layer has a distinct responsibility, enabling more flexible and consistent event layouts while preserving extensive customization capabilities.

## Alignment with Product Vision

This feature directly supports the following product principles from product.md:

- **Customization First**: The layered architecture exposes builder callbacks at multiple levels (day cell, week layout, event tile, date label, overflow indicator), allowing developers to customize appearance without forking the package
- **Separation of Concerns**: Each layer has a single responsibility (grid, events, drag feedback), making the code more modular and maintainable
- **Flexibility**: The week layout builder pattern allows developers to implement completely custom event layouts (pile, dots, agenda style) while the package provides a sensible default
- **Mobile-First**: The architecture is designed for efficient rendering on mobile devices while scaling to larger screens

## Requirements

### Requirement 1: Three-Layer Stack Architecture

**User Story:** As a Flutter developer, I want the Month View to use a layered Stack architecture, so that calendar grids, events, and drag interactions are rendered independently and can be customized separately.

#### Acceptance Criteria

1. WHEN MCalMonthView renders THEN it SHALL use a Stack widget with three layers:
   - Layer 1 (bottom): Calendar grid with day cells
   - Layer 2 (middle): Event tiles, date labels, and overflow indicators
   - Layer 3 (top): Drop target layer for drag-and-drop ghost tiles
2. WHEN Layer 3 has no active drag operation THEN the system SHALL NOT render Layer 3 content
3. WHEN the calendar renders THEN Layer 1 and Layer 2 SHALL have matching dimensions for each week row
4. IF a developer provides a custom dayCellBuilder THEN Layer 1 SHALL use that builder to render cell backgrounds and borders

### Requirement 2: Layer 1 - Calendar Grid

**User Story:** As a Flutter developer, I want Layer 1 to render only the calendar grid structure, so that I can customize cell backgrounds, borders, and visual styling independently of events.

#### Acceptance Criteria

1. WHEN Layer 1 renders THEN it SHALL display a grid with the configured number of week rows and 7 day columns
2. IF dayCellBuilder is provided THEN each cell in Layer 1 SHALL be rendered using that builder
3. WHEN no dayCellBuilder is provided THEN the system SHALL use a default cell renderer with configurable border width and color
4. WHEN a drag operation is active THEN Layer 1 cells MAY display visual highlighting to indicate valid/invalid drop targets
5. IF showWeekNumbers is true THEN week numbers SHALL render outside the layer system (not in Layer 1) using the same height calculations for proper vertical alignment
6. WHEN the locale is RTL THEN week numbers SHALL render on the right side; otherwise on the left side

### Requirement 3: Layer 2 - Events, Date Labels, and Overflow Indicators

**User Story:** As a Flutter developer, I want Layer 2 to handle all event tile, date label, and overflow indicator rendering through a week layout builder, so that I have complete control over event positioning and layout algorithms.

#### Acceptance Criteria

1. WHEN Layer 2 renders THEN it SHALL consist of one row per visible week
2. WHEN a week row renders THEN it SHALL use the weekLayoutBuilder callback (if provided) or the default layout implementation
3. WHEN the weekLayoutBuilder is called THEN it SHALL receive:
   - All events (segments) for that week row
   - Column widths for each day
   - Day dates for the week
   - The eventTileBuilder callback (pre-wrapped with interaction handlers)
   - The dateLabelBuilder callback (pre-wrapped with interaction handlers)
   - The overflowIndicatorBuilder callback (pre-wrapped with interaction handlers)
   - Layout constraints (available height, width)
   - Configuration values (tile spacing, corner radius, etc.)
4. IF no weekLayoutBuilder is provided THEN the system SHALL use a default layout that matches the POC implementation (greedy first-fit, multi-week event continuity, overflow indicators)
5. WHEN an event spans multiple weeks THEN the weekLayoutBuilder SHALL receive segment information including isFirstSegment and isLastSegment flags
6. WHEN the default layout renders multi-week event segments THEN continuation edges (non-first, non-last) SHALL have no rounded corners, no border, and zero horizontal spacing

### Requirement 4: Builder Wrapping Pattern

**User Story:** As a Flutter developer, I want my custom builders to control visual appearance while the package handles tap, drag, and other interactions, so that I don't have to reimplement interaction logic.

#### Acceptance Criteria

1. WHEN a developer provides an eventTileBuilder THEN the package SHALL wrap it internally before passing to the weekLayoutBuilder
2. WHEN the wrapped eventTileBuilder is invoked THEN the package SHALL:
   - Call the developer's builder to get the visual widget
   - Wrap the result with GestureDetector, LongPressDraggable, or other interaction handlers as needed
   - Return the wrapped widget to the weekLayoutBuilder
3. WHEN a developer provides a dateLabelBuilder THEN the package SHALL wrap it similarly with any required interaction handlers before passing to the weekLayoutBuilder
4. WHEN a developer provides an overflowIndicatorBuilder THEN the package SHALL wrap it with tap handlers for onOverflowTap before passing to the weekLayoutBuilder
5. IF a developer provides a custom weekLayoutBuilder THEN they SHALL receive all three pre-wrapped builders (eventTileBuilder, dateLabelBuilder, overflowIndicatorBuilder)
6. WHEN the weekLayoutBuilder invokes any of the provided builders THEN interaction handling SHALL work automatically without additional developer code

### Requirement 5: Unified Event Tile Builder

**User Story:** As a Flutter developer, I want a single eventTileBuilder that handles both single-day and multi-day events, so that I have a consistent API for customizing event appearance.

#### Acceptance Criteria

1. WHEN eventTileBuilder is called THEN it SHALL receive an event tile context containing:
   - The event data (MCalCalendarEvent)
   - Segment information (start day in week, end day in week, span days)
   - Position flags (isFirstSegment, isLastSegment)
   - Visual dimensions (width, height)
2. WHEN no eventTileBuilder is provided THEN the system SHALL use a default tile renderer
3. IF the old multiDayEventTileBuilder parameter is used THEN the system SHALL NOT compile (clean break - removed API)
4. WHEN rendering a multi-week event segment THEN the builder SHALL apply appropriate styling based on isFirstSegment and isLastSegment flags
5. WHEN the developer's eventTileBuilder returns a widget THEN the package SHALL wrap it with interaction handlers (see Requirement 4)

### Requirement 6: Date Label Builder Integration

**User Story:** As a Flutter developer, I want the dateLabelBuilder to be passed into the week layout builder, so that the layout builder can position date labels alongside events.

#### Acceptance Criteria

1. WHEN dateLabelBuilder is provided as a top-level parameter THEN it SHALL be wrapped and passed to the weekLayoutBuilder
2. WHEN the weekLayoutBuilder renders THEN it MAY use the wrapped dateLabelBuilder to render date labels at any position
3. WHEN no dateLabelBuilder is provided THEN the system SHALL use a default date label renderer
4. IF a developer wants date labels in Layer 1 instead THEN they MAY render them via dayCellBuilder and the weekLayoutBuilder can ignore the dateLabelBuilder
5. WHEN the default layout renders date labels THEN it SHALL support configurable positions (top-left, top-center, top-right, bottom-left, bottom-center, bottom-right)
6. WHEN the developer's dateLabelBuilder returns a widget THEN the package SHALL wrap it with any required interaction handlers

### Requirement 7: Overflow Indicator Builder

**User Story:** As a Flutter developer, I want to customize the appearance of overflow indicators, so that they match my app's design language.

#### Acceptance Criteria

1. WHEN overflowIndicatorBuilder is provided as a top-level parameter THEN it SHALL be wrapped and passed to the weekLayoutBuilder
2. WHEN the overflowIndicatorBuilder is called THEN it SHALL receive a context containing:
   - The date for this indicator
   - The count of hidden events
   - The list of hidden events (MCalCalendarEvent objects)
   - The list of visible events (MCalCalendarEvent objects)
   - Visual dimensions (width, height)
3. WHEN no overflowIndicatorBuilder is provided THEN the system SHALL use a default "+N more" text renderer
4. WHEN the developer's overflowIndicatorBuilder returns a widget THEN the package SHALL wrap it with a tap handler for onOverflowTap
5. WHEN an overflow indicator is tapped THEN the system SHALL invoke onOverflowTap callback with the date, hidden events, and visible events

### Requirement 8: Layer 3 - Drag-and-Drop Ghost Layer

**User Story:** As a Flutter developer, I want a dedicated layer for drag-and-drop feedback, so that ghost tiles are rendered above static events with clear visual separation.

#### Acceptance Criteria

1. WHEN a drag operation begins THEN Layer 3 SHALL become visible
2. WHEN Layer 3 renders THEN it SHALL use the same weekLayoutBuilder as Layer 2 but with only the dragged event
3. WHEN the dragged event moves THEN the ghost tile in Layer 3 SHALL update position to show the drop target location
4. WHEN the drag operation ends THEN Layer 3 content SHALL be hidden
5. WHEN a valid drop target is hovered THEN the cell highlighting in Layer 1 MAY indicate validity
6. IF the ghost tile position is invalid THEN the system SHALL provide visual feedback (e.g., different styling or opacity)

### Requirement 9: Overflow Indicator Logic

**User Story:** As a Flutter developer, I want the calendar to correctly calculate and display overflow indicators, so that users know there are hidden events.

#### Acceptance Criteria

1. WHEN the number of events in a day column exceeds the displayable rows THEN the system SHALL show an overflow indicator
2. WHEN calculating hidden event count THEN the system SHALL count hidden events per day column, not hidden rows
3. WHEN a multi-day event creates blank areas above other events THEN those blank areas SHALL NOT count toward the hidden event count
4. WHEN a multi-day event spans days with different overflow states THEN each day column SHALL independently calculate and display its hidden count

### Requirement 10: Week Layout Builder API

**User Story:** As a Flutter developer, I want a well-defined weekLayoutBuilder API, so that I can implement custom event layout algorithms while leveraging the package's tile and label builders.

#### Acceptance Criteria

1. WHEN weekLayoutBuilder is defined THEN it SHALL have the signature: `Widget Function(BuildContext context, MCalWeekLayoutContext layoutContext)?`
2. WHEN MCalWeekLayoutContext is instantiated THEN it SHALL contain:
   - `List<MCalEventSegment> segments` - Event segments for this week
   - `List<DateTime> dates` - The 7 dates in this week row
   - `List<double> columnWidths` - Width of each day column
   - `double rowHeight` - Total height available for this week row
   - `Widget Function(BuildContext, MCalEventTileContext) eventTileBuilder` - Pre-wrapped callback to build event tiles (includes interaction handlers)
   - `Widget Function(BuildContext, MCalDateLabelContext) dateLabelBuilder` - Pre-wrapped callback to build date labels
   - `Widget Function(BuildContext, MCalOverflowIndicatorContext) overflowIndicatorBuilder` - Pre-wrapped callback to build overflow indicators
   - `MCalWeekLayoutConfig config` - Configuration values (spacing, styling parameters)
3. WHEN the default weekLayoutBuilder renders THEN it SHALL implement greedy first-fit row assignment matching the POC
4. IF a developer provides a custom weekLayoutBuilder THEN they SHALL have full control over event positioning and may ignore provided builders
5. WHEN the weekLayoutBuilder invokes any provided builder THEN interaction handlers SHALL be automatically included

### Requirement 11: Breaking API Changes

**User Story:** As a Flutter developer using this unreleased package, I want a clean API without backward compatibility cruft, so that the codebase remains simple and maintainable.

#### Acceptance Criteria

1. WHEN the new architecture is implemented THEN the following parameters SHALL be removed:
   - `multiDayEventTileBuilder` - replaced by unified `eventTileBuilder` with segment info
   - `renderMultiDayEventsAsContiguous` - no longer needed; the weekLayoutBuilder pattern provides complete flexibility for how events are rendered (contiguous tiles, dots, pills, etc.)
2. WHEN the new architecture is implemented THEN the eventTileBuilder parameter SHALL accept the new unified signature with segment info
3. WHEN the new architecture is implemented THEN new parameters SHALL be added: weekLayoutBuilder, overflowIndicatorBuilder
4. WHEN breaking changes are made THEN the CHANGELOG SHALL document all removed, modified, and new parameters
5. WHEN developers previously used renderMultiDayEventsAsContiguous:false for dots-style rendering THEN they SHALL migrate to a custom weekLayoutBuilder or eventTileBuilder that renders dots/pills

### Requirement 12: Example App Updates

**User Story:** As a Flutter developer evaluating this package, I want to see examples demonstrating different layout styles, so that I understand the flexibility of the weekLayoutBuilder pattern.

#### Acceptance Criteria

1. WHEN the example app is updated THEN the Layout POC tab SHALL remain in place as a reference implementation
2. WHEN the example app is updated THEN at least one existing tab that currently shows dots SHALL be changed to use elongated pills (~3px height) without labels to represent multi-day events
3. WHEN the elongated pill style renders THEN it SHALL demonstrate:
   - Multi-day events spanning multiple columns as continuous pills
   - Visual continuity across week boundaries (matching the POC behavior)
   - Configurable pill color based on event properties
4. WHEN the example app tabs are viewed THEN they SHALL collectively demonstrate:
   - Default pile layout (matching POC)
   - Dot indicators style
   - Elongated pill style (new)
   - Custom weekLayoutBuilder implementation
5. WHEN a developer reviews the example app THEN they SHALL understand how to implement custom layouts using the weekLayoutBuilder API

### Requirement 13: Configuration and Theming

**User Story:** As a Flutter developer, I want configurable layout parameters via theme or explicit configuration, so that I can fine-tune the visual appearance without implementing a custom layout builder.

#### Acceptance Criteria

1. WHEN MCalThemeData is defined THEN it SHALL support these layout values with sensible defaults:
   - `double tileHeight` - Height of event tiles (default: ~18.0)
   - `double tileVerticalSpacing` - Vertical space between tiles (default: ~2.0)
   - `double tileHorizontalSpacing` - Horizontal space between tiles (default: ~2.0)
   - `double tileCornerRadius` - Corner radius for tile borders (default: ~3.0)
   - `double tileBorderWidth` - Border width for tiles (default: 0.0)
   - `double dateLabelHeight` - Height reserved for date labels (default: ~18.0)
   - `DateLabelPosition dateLabelPosition` - Position enum (default: topLeft)
   - `double overflowIndicatorHeight` - Height reserved for overflow indicators (default: ~14.0)
2. WHEN MCalWeekLayoutConfig is instantiated THEN it SHALL inherit values from MCalThemeData when not explicitly set
3. IF a developer explicitly sets a value in MCalWeekLayoutConfig THEN it SHALL override the theme value
4. WHEN configuration or theme values are changed THEN the layout SHALL rebuild to reflect changes
5. WHEN the default builders (eventTileBuilder, dateLabelBuilder, overflowIndicatorBuilder) render THEN they SHALL respect the configured/themed values

## Non-Functional Requirements

### Code Architecture and Modularity

- **Single Responsibility Principle**: Each layer has one purpose (Layer 1: grid, Layer 2: events/labels, Layer 3: drag feedback)
- **Modular Design**: The weekLayoutBuilder pattern allows complete replacement of the event layout algorithm
- **Dependency Management**: Layer 2 and Layer 3 share layout builder logic to ensure consistency
- **Clear Interfaces**: MCalWeekLayoutContext and MCalEventSegment provide well-defined contracts

### Performance

- The layered architecture SHALL NOT significantly degrade rendering performance compared to the current implementation
- Event segment calculations SHALL be performed once per layout pass, not per build
- The greedy first-fit algorithm SHALL have O(n*m) complexity where n is events and m is max rows
- Layer 3 SHALL only render during active drag operations to avoid unnecessary widget tree complexity

### Accessibility

- Event tiles SHALL maintain semantic labels for screen reader support
- Overflow indicators SHALL announce the number of hidden events
- Date labels SHALL be accessible via semantics
- Drag-and-drop feedback SHALL include audio/haptic feedback where platform-appropriate

### Usability

- The default layout SHALL match user expectations from common calendar applications (Google Calendar, Apple Calendar)
- Multi-week events SHALL be visually continuous across week boundaries
- Overflow indicators SHALL be clearly visible and tappable
- The API SHALL be intuitive for developers familiar with Flutter builder patterns
