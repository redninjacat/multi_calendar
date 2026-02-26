# Technology Stack

## Project Type

Flutter package/library for displaying calendar views with event support. Published to pub.dev for use in Flutter applications.

## Core Technologies

### Primary Language(s)

* **Language**: Dart `3.10.4+`
* **Runtime**: Flutter SDK
* **Language-specific tools**: pub (package manager), dart analyzer, flutter\_lints

### Key Dependencies/Libraries

* **flutter**: SDK dependency (`>=1.17.0`)
* **flutter\_localizations**: SDK dependency for Flutter localization support (required for gen-l10n)
* **flutter\_test**: Testing framework (SDK)
* **flutter\_lints**: Code quality and linting (`^6.0.0`)
* **teno\_rrule**: RFC 5545 RRULE parsing and generation (`^0.0.8`)
* **intl**: Internationalization and localization (`^0.20.2`)
* **coverage**: Test coverage reporting (`^1.15.0`)
* **Date/Time handling**: Dart's built-in `DateTime` class, `intl` package for localization and formatting
* **Localization**: Two separate `gen-l10n` systems — one for the package, one for the example app:
  * **Package-level** (`lib/l10n/`, configured via root `l10n.yaml` with `synthetic-package: false`):
    * ARB files: `app_en.arb`, `app_es.arb`, `app_fr.arb`, `app_ar.arb`, `app_he.arb` (5 locales)
    * Generated class: `MCalLocalizations` in `lib/l10n/mcal_localizations.dart` — provides standard Flutter localization with `.of(context)` and `.delegate`
    * Utility class: `MCalDateFormatUtils` in `lib/src/utils/mcal_date_format_utils.dart` — provides date/time formatting helpers (`formatDate`, `formatTime`, `formatMonthYear`, `formatFullDateWithDayName`) and static helpers for weekday/month names
    * Usage pattern: Widgets use `MCalLocalizations.of(context).propertyName` for localized strings (standard Flutter pattern) — consuming apps must add `MCalLocalizations.delegate` to their `localizationsDelegates`
    * Contains calendar-specific strings: day/month names, navigation labels, accessibility labels, drop target semantics, screen reader announcements
  * **Example app-level** (`example/lib/l10n/`, configured via `example/l10n.yaml`):
    * ARB files: `app_en.arb`, `app_es.arb`, `app_fr.arb`, `app_ar.arb`, `app_he.arb` (5 locales)
    * Generated class: `AppLocalizations` in `example/lib/l10n/app_localizations.dart`
    * Usage pattern: `AppLocalizations.of(context)` — standard context-based lookup
    * Delegates wired in `MaterialApp` via `AppLocalizations.localizationsDelegates` plus `MCalLocalizations.delegate`
    * Contains example app UI strings: tab labels, style descriptions, dialog text, accessibility content, SnackBar messages
  * `intl` package for date/time formatting
  * Supported languages: English, Spanish, French, Arabic (RTL), Hebrew (RTL)
* **Accessibility**: Flutter's built-in `Semantics` widgets and accessibility APIs

### Application Architecture

**Widget-based Architecture**: Flutter widget tree with controller pattern for state management

* **Views**: Separate widget classes for each view type (MCalDayView, MCalMultiDayView, MCalMonthView) - prefixed with "MCal" to avoid conflicts
* **Controller**: MCalEventController manages event loading and view state
* **Models**: Event data models that interface with external systems. `MCalCalendarEvent` includes an `isAllDay` boolean field to indicate all-day events, where time components of start and end dates are ignored.
* **Delegation Pattern**: Event storage/management delegated to external classes via callbacks/events
* **Builder Pattern**: Extensive use of builder callbacks for customization
* **Responsive Design**: Mobile-first approach with adaptive layouts for larger screens
* **Accessibility Layer**: Semantics widgets and accessibility APIs throughout
* **Internationalization**: Dual i18n systems — package uses standard `MCalLocalizations.of(context)` pattern for localized strings; `MCalDateFormatUtils` provides date/time formatting utilities; example app uses standard `AppLocalizations.of(context)` pattern. Both use Flutter gen-l10n with separate ARB file sets. RTL layout support for Arabic and Hebrew uses `Directionality.of(context)` as the primary detection mechanism in widget build methods.

### Data Storage (if applicable)

* **Package Storage**: None - package does not persist events
* **External Storage**: Delegated to consuming application
* **Data formats**:
  * RRULE strings stored as-is (RFC 5545 format)
  * Event data models use Dart classes
  * Date/Time: Dart `DateTime` objects

### External Integrations (if applicable)

* **Event Sources**: Via McEventController callbacks - any backend can provide events
* **Protocols**: None directly - consuming app handles API calls
* **Authentication**: None - handled by consuming application

## Development Environment

### Build & Development Tools

* **Build System**: Flutter build system (`flutter build`)
* **Package Management**: pub (via `pubspec.yaml`)
* **Development workflow**: Hot reload via Flutter, watch mode for tests

### Code Quality Tools

* **Static Analysis**: dart analyzer, flutter\_lints
* **Formatting**: `dart format` (built-in)
* **Testing Framework**: flutter\_test for widget and unit tests
* **Documentation**: dartdoc for API documentation

### Version Control & Collaboration

* **VCS**: Git
* **Branching Strategy**: Standard Git Flow or feature branches
* **Code Review Process**: GitHub PR reviews

## Deployment & Distribution

* **Target Platform(s)**: All Flutter-supported platforms (iOS, Android, Web, Desktop)
* **Distribution Method**: pub.dev package repository
* **Installation Requirements**: Flutter SDK, Dart `3.10.4+`
* **Update Mechanism**: Standard pub.dev versioning and `flutter pub upgrade`

## Technical Requirements & Constraints

### Performance Requirements

* **Rendering**: Smooth scrolling at `60fps` on mid-range mobile devices
* **Event Loading**: McEventController loads events for visible date range PLUS previous and next ranges (for swipe preview)
* **Event Lookup Performance**: O(log n) or better for event lookups by date range where n is the number of cached ranges
* **Event Storage**: O(n) space complexity where n is the number of events in loaded ranges
* **Memory Management**: McEventController retains events from adjacent ranges but eventually removes old events using efficient cleanup (O(n) or better)
* **Memory Usage**: Typically holds 3 months worth of events (current + previous + next) for smooth swipe navigation
* **Memory**: Efficient handling of large event sets (`1000+` events) on mobile devices with optimal time/space complexity
* **RRULE Processing**: Efficient recurrence expansion for visible date ranges
* **Startup Time**: Views should render within `100ms` of widget build on mobile
* **Touch Responsiveness**: Gesture recognition (drag, resize, swipe) should feel responsive (`<50ms` feedback)
* **Swipe Navigation**: Pre-loaded adjacent month events enable instant swipe navigation without async loading delays
* **Mobile Optimization**: Prioritize mobile performance; desktop should scale efficiently

### Compatibility Requirements

* **Platform Support**: iOS `12+`, Android API `21+`, Web, macOS, Windows, Linux
* **Dependency Versions**:
  * Flutter: `>=1.17.0`
  * Dart SDK: `^3.10.4`
  * intl: `^0.19.0` (for localization)
* **Standards Compliance**:
  * RFC 5545 RRULE specification compliance
  * WCAG accessibility guidelines (where applicable)
  * Platform-specific accessibility standards (iOS VoiceOver, Android TalkBack)

### Security & Compliance

* **Security Requirements**: No sensitive data stored by package; consuming app responsible
* **Compliance Standards**: None specific to package (delegated to consuming app)
* **Threat Model**: Package is display-only; security concerns in consuming application

### Scalability & Reliability

* **Expected Load**: Support calendars with `1000+` events efficiently
* **Availability Requirements**: Package reliability depends on Flutter framework
* **Growth Projections**: Support for additional views and features over time

## Technical Decisions & Rationale

### Decision Log

1. **Separate Widgets per View**: Unlike the popular single widget approach, each view (Day, Multi-day, Month) is its own widget
   * **Rationale**: Better modularity, allows selective use, easier customization
   * **Trade-off**: More files to maintain, but clearer separation of concerns
2. **Event Controller Pattern**: Single controller manages events for all views
   * **Rationale**: Consistent API, efficient loading, single source of truth
   * **Trade-off**: Controller must handle different view requirements
   * **Performance Requirements**:
     * Loads events for visible range PLUS previous and next ranges (for swipe preview)
     * Event lookups: O(log n) or better where n is number of cached date ranges
     * Event storage: O(n) space complexity where n is number of events in loaded ranges
     * Memory management: Retains adjacent range events but eventually removes old events using efficient cleanup (O(n) or better)
     * Typically holds 3 months worth of events (current + previous + next) for smooth swipe navigation
3. **Delegation for Storage**: Package does not handle event persistence
   * **Rationale**: Maximum flexibility, no lock-in to specific storage solutions
   * **Trade-off**: Consuming apps must implement storage layer
4. **RRULE String Storage**: Store RRULE strings in RFC 5545 compliant format, compatible with standard rrule Dart libraries
   * **Rationale**: RFC 5545 is the industry standard for calendar recurrence rules; compatibility with existing rrule Dart packages ensures interoperability
   * **Trade-off**: Must ensure exact RFC 5545 string format compliance and compatibility with chosen rrule library
5. **Builder Callbacks for Customization**: Extensive use of builder callbacks
   * **Rationale**: Maximum flexibility without requiring package forks
   * **Trade-off**: More complex API surface, but necessary for customization needs
6. **Event Time Model**: Use start DateTime and end DateTime (no Duration field)
   * **Rationale**: Simpler model, end DateTime is more intuitive and matches common calendar data formats
   * **Trade-off**: Duration must be calculated when needed (end - start), but avoids dual representation complexity
7. **All-Day Event Field**: `MCalCalendarEvent` includes explicit `isAllDay` boolean field
   * **Rationale**: Explicit field is clearer than inferring from time components, allows external systems to set all-day status directly
   * **Trade-off**: Requires external systems to set the field correctly, but provides better API clarity and supports future Day/Multi-Day view header display
7. **Optional Built-in Navigators**: Each view can optionally display a navigator
   * **Rationale**: Convenience for common use cases while maintaining customization via builders
   * **Trade-off**: More UI code in package, but provides good defaults with customization options
8. **Mobile-First Design**: Optimize for mobile devices first
   * **Rationale**: Most calendar usage is on mobile; ensure excellent mobile experience
   * **Trade-off**: May require additional work for desktop optimization, but ensures mobile quality
9. **Comprehensive Localization**: Full i18n support from the start
   * **Rationale**: Calendar apps are used globally; localization is essential
   * **Trade-off**: More complex code, but necessary for international adoption
10. **Accessibility First**: Screen reader support built-in
    * **Rationale**: Calendar is a critical UI component; must be accessible to all users
    * **Trade-off**: Additional semantic widgets and testing, but essential for inclusive design

## Known Limitations

* **Time Zone Support**: Not in initial release (future enhancement)
* **Regions/Holidays**: Explicitly out of scope - will not be implemented
* **Event Editors**: Out of scope - external responsibility (though resize/edit gestures supported)
* **Event Detail Views**: Out of scope - external responsibility
* **RRULE Library Dependency**: Need to evaluate and potentially contribute to Dart RRULE libraries if none meet requirements
* **Hover Events**: Only available on platforms that support hover (desktop/web), not on mobile

## Flutter-Specific Considerations

### Widget Lifecycle

* Views must efficiently rebuild only when necessary
* McEventController should use ValueNotifier or similar for reactive updates
* McEventController must use efficient data structures (e.g., SortedMap, TreeMap, or similar) for O(log n) date range lookups
* McEventController should implement memory-efficient caching with automatic cleanup of old events
* Consider using `const` constructors where possible for performance

### State Management

* Controller pattern for view state (current date, visible range)
* Event loading via callbacks/streams
* Consider Provider/Riverpod integration examples in documentation

### Rendering Performance

* Use `ListView.builder` or `CustomScrollView` for efficient scrolling
* Implement viewport-based event loading with pre-loading of adjacent ranges for smooth swipe navigation
* McEventController should use efficient in-memory data structures with optimal Big O complexity (O(log n) lookups, O(n) storage)
* Consider `RepaintBoundary` widgets for complex event tiles
* **Mobile Optimization**: Minimize widget rebuilds, use `const` constructors where possible
* **Lazy Loading**: Load events and render cells only when visible
* **Gesture Performance**: Optimize drag-and-drop and resize gesture handling for smooth 60fps

### Platform Considerations

* **Mobile-First**: Optimize touch interactions, gesture recognition, and performance for mobile
* **Desktop/Web**: Support hover events, mouse interactions, keyboard navigation
* **Cross-Platform Gestures**: Handle drag-and-drop, resize gestures consistently across platforms
* **Screen Sizes**: Responsive design from small mobile (`320px`) to large desktop (`4K`)
* **Orientations**: Support portrait and landscape on mobile
* **RTL Support**: Proper layout direction handling for RTL languages
* **Accessibility**: Platform-specific accessibility APIs (iOS VoiceOver, Android TalkBack, Web ARIA)