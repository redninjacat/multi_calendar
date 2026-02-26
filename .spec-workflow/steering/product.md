# Product Overview

## Product Purpose

Multi Calendar is a Flutter package that provides flexible, customizable calendar views for displaying events with full RFC 5545 RRULE support. Unlike some other calendar packages, this package separates each view into its own widget, providing greater modularity and customization. The package focuses on event display and RRULE handling while delegating event storage and management to external systems, making it ideal for applications that need calendar UI without dictating data persistence strategies.

## Target Users

* **Flutter Developers**: Building calendar-based applications (scheduling apps, event management, task planners)
* **App Developers**: Needing flexible calendar views with recurring event support
* **Enterprise Applications**: Requiring RFC 5545 compliance for calendar interoperability

### User Needs

* Display calendar events across multiple view types (Day, Multi-day, Month)
* Support complex recurring event patterns via RRULE
* Customize appearance and behavior without being locked into a specific data model
* Handle drag-and-drop event manipulation
* Resize events to adjust duration/dates
* Integrate with existing event storage systems
* Support international users with localization and RTL
* Ensure accessibility for all users
* Work seamlessly on mobile and desktop platforms

### Pain Points Addressed

* **Leading Calendar Package Limitations**: Single widget approach limits customization; Multi Calendar provides separate widgets per view
* **Data Model Lock-in**: Many calendar packages force specific storage models; Multi Calendar delegates storage externally
* **RRULE Complexity**: Proper RRULE handling is complex; Multi Calendar handles this correctly
* **Styling Flexibility**: Limited styling options in existing packages; Multi Calendar exposes comprehensive styling APIs
* **Event Editing**: Many packages don't support resizing events; Multi Calendar supports resize for duration and dates
* **Internationalization**: Limited i18n support in existing packages; Multi Calendar provides full localization and RTL
* **Accessibility**: Many calendar packages lack proper accessibility; Multi Calendar prioritizes screen reader support
* **Platform Optimization**: One-size-fits-all approach; Multi Calendar is mobile-first with desktop scaling

## Key Features

1. **Multiple Calendar Views**: Separate widgets for Day, Multi-day (configurable day count), and Month views (MCalDayView, MCalMultiDayView, MCalMonthView - prefixed with "MCal" to avoid conflicts)
2. **RFC 5545 RRULE Support**: Full support for recurring event rules with exception handling
3. **Flexible Time Ranges**: Configurable time ranges for Day and Multi-day views (e.g., 8am-8pm)
4. **Event Controller Pattern**: Single controller that dynamically loads events based on visible date range, supporting all views
5. **Drag and Drop**: Move events between dates/times via drag-and-drop
6. **Event Resizing**: Resize event tiles to change duration:
   * On time views (Day/Multi-day): Resizing changes hours/duration
   * On Month view and All-Day sections: Resizing changes start or end day
7. **External Event Management**: Package handles display only; storage and CRUD operations delegated to external classes
8. **All-Day Event Support**: Events can be marked as all-day via the `isAllDay` field in `MCalCalendarEvent`. When `isAllDay` is true, time components of start and end dates are ignored. All-day events are displayed in the header section of Day and Multi-Day views.
9. **Customizable Event Tiles**: Builder callbacks for event tiles on all views, with separate handling for all-day vs timed events
10. **Time-Aware Interactions**: Tap and long-press handlers receive date/time context
10. **Hover Support**: onHover\* event handlers for platforms that support it, passing pertinent details about hovered elements
11. **Comprehensive Styling**: Expose styling properties and builder callbacks for cells, headers, fonts, colors, borders
12. **Dynamic Cell Customization**: Builder callbacks and styling to dynamically change cell visuals and disable interactivity (e.g., blackout days)
13. **Current Day/Time Indicators**: Visual indicators for current day (all views) and current time (time-based views)
14. **Customizable Date/Time Formats**: Support standard date/time format strings OR custom builder callbacks for date/time labels
15. **First Day of Week**: Configurable first day of the week (Sunday, Monday, etc.)
16. **Optional Navigators**: Each view provides option to display simple navigator at top for quick date range changes, customizable via builders with navigation callbacks
17. **Localization & Globalization**: Display dates/times using globalized formats, localize all static calendar text
18. **Accessibility**: Full screen reader support for easy calendar access
19. **Right-to-Left (RTL) Support**: RTL direction support for languages like Hebrew and Arabic
20. **Date Range Restrictions**: Minimum and maximum date support to restrict date navigation
21. **Mobile-First Design**: Optimized for mobile devices while scaling to larger screens (web, desktop)

## Business Objectives

* **Modularity**: Each view is a separate widget, allowing developers to use only what they need
* **Flexibility**: Support any event storage backend through delegation pattern
* **Standards Compliance**: Full RFC 5545 RRULE support for calendar interoperability
* **Developer Experience**: Easy integration with comprehensive customization options
* **Performance**: Efficient event loading via controller pattern that only loads visible date ranges

## Success Metrics

* **Adoption**: Package published to pub.dev with positive developer feedback
* **Performance**: Smooth scrolling and event loading for date ranges up to 3 months
* **Compatibility**: Successfully integrates with various event storage backends
* **RRULE Accuracy**: Correctly handles complex RRULE patterns matching industry-standard calendar applications
* **Customization**: Developers can achieve desired styling without forking the package

## Product Principles

1. **Separation of Concerns**: Display logic stays in the package; data management stays external
2. **Modularity Over Monolith**: Each view is independent, allowing selective use
3. **Standards Compliance**: RFC 5545 RRULE strings stored in standard compliant format, compatible with rrule Dart libraries for interoperability
4. **Customization First**: Expose styling and builder callbacks rather than hardcoding appearance
5. **Performance Conscious**: Load only visible events, support efficient rendering
6. **Developer-Friendly**: Clear APIs, comprehensive documentation, easy integration
7. **Accessibility First**: Ensure calendar is usable by all users, including screen reader users
8. **International Ready**: Support localization, globalization, and RTL from the start
9. **Mobile-First**: Optimize for mobile devices while ensuring desktop compatibility
10. **Flexible Interaction**: Support all interaction types (tap, long-press, drag, resize, hover) where platform-appropriate

## Monitoring & Visibility

* **Package Health**: pub.dev analytics, GitHub stars/issues
* **Developer Feedback**: GitHub discussions, issue tracking
* **Usage Patterns**: Track which views are most commonly used
* **Performance Metrics**: Monitor rendering performance in example apps

## Future Vision

### Potential Enhancements

* **Time Zone Support**: Handle events across multiple time zones
* **Additional Views**: Timeline view, agenda view, year view
* **Event Conflict Detection**: Visual indicators for overlapping events
* **Keyboard Navigation**: Enhanced keyboard navigation support
* **Animation**: Smooth transitions between views and dates
* **Export/Import**: Calendar file format support (ICS, etc.)

### Out of Scope (Explicitly)

* **Regions/Holidays**: Package does not handle regional calendars or holiday calendars
* **Built-in Event Editors**: Event creation/editing UI is external responsibility (though resize/edit gestures are supported)
* **Built-in Event Detail Views**: Event detail display is external responsibility