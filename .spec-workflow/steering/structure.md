# Project Structure

## Directory Organization

```
multi_calendar/
├── lib/
│   ├── src/
│   │   ├── models/              # Event data models
│   │   │   ├── mcal_calendar_event.dart
│   │   │   ├── rrule_data.dart
│   │   │   └── event_exception.dart
│   │   ├── views/                # Calendar view widgets
│   │   │   ├── mcal_day_view.dart
│   │   │   ├── mcal_multi_day_view.dart
│   │   │   └── mcal_month_view.dart
│   │   ├── controllers/          # Event controller
│   │   │   └── mcal_event_controller.dart
│   │   ├── widgets/              # Shared widgets
│   │   │   ├── event_tile.dart
│   │   │   ├── time_slot.dart
│   │   │   ├── day_header.dart
│   │   │   ├── navigator.dart    # Optional navigator widget
│   │   │   └── current_time_indicator.dart
│   │   ├── utils/                # Utilities
│   │   │   ├── rrule_parser.dart
│   │   │   ├── date_utils.dart
│   │   │   ├── event_expander.dart
│   │   │   └── accessibility.dart
│   │   └── styles/               # Style definitions
│   │       ├── mcal_theme.dart
│   │       ├── mcal_day_theme_data.dart
│   │       └── mcal_month_theme_data.dart
│   ├── l10n/                     # Package-level localization (gen-l10n ARB files)
│   │   ├── app_en.arb            # English translations (template)
│   │   ├── app_es.arb            # Spanish translations
│   │   ├── app_es_MX.arb         # Mexican Spanish translations
│   │   ├── app_fr.arb            # French translations
│   │   ├── app_ar.arb            # Arabic translations (RTL)
│   │   ├── app_he.arb            # Hebrew translations (RTL)
│   │   ├── mcal_localizations.dart       # Generated MCalLocalizations class
│   │   ├── mcal_localizations_en.dart    # Generated per-locale classes
│   │   └── ...                           # (one per locale)
│   └── multi_calendar.dart       # Main export file
├── test/
│   ├── models/
│   ├── views/
│   ├── controllers/
│   ├── utils/
│   └── integration/
├── example/
│   └── lib/
│       └── main.dart            # Example app demonstrating all views
├── .spec-workflow/              # Spec workflow documents
├── analysis_options.yaml
├── l10n.yaml                    # Flutter gen-l10n configuration
├── CHANGELOG.md
├── LICENSE
├── pubspec.yaml
└── README.md
```

## Naming Conventions

### Files
- **Widgets/Views**: `snake_case.dart` (e.g., `day_view.dart`, `event_tile.dart`)
- **Models**: `snake_case.dart` (e.g., `mc_calendar_event.dart`, `rrule_data.dart`)
- **Controllers**: `snake_case.dart` (e.g., `mc_event_controller.dart`)
- **Utilities**: `snake_case.dart` (e.g., `date_utils.dart`, `rrule_parser.dart`)
- **Tests**: `[filename]_test.dart` (e.g., `day_view_test.dart`)

### Code
- **Classes/Types**: `PascalCase` (e.g., `MCalDayView`, `MCalCalendarEvent`, `MCalEventController`)
- **Widgets**: `PascalCase` with "MCal" prefix for public calendar widgets (e.g., `MCalDayView`, `MCalMultiDayView`, `MCalMonthView`)
- **Theme Classes**: `PascalCase` with "MCal" prefix (e.g., `MCalThemeData`)
- **Functions/Methods**: `camelCase` (e.g., `loadEvents`, `expandRecurrence`)
- **Constants**: `lowerCamelCase` for public, `_lowerCamelCase` for private (e.g., `defaultTimeRange`, `_defaultTileHeight`)
- **Variables**: `camelCase` (e.g., `startDate`, `eventList`)
- **Private members**: Prefix with `_` (e.g., `_eventController`, `_visibleRange`)

## Import Patterns

### Import Order
1. Dart SDK imports (e.g., `dart:async`, `dart:math`)
2. Flutter SDK imports (e.g., `package:flutter/material.dart`)
3. External package imports (e.g., `package:rrule/rrule.dart`)
4. Internal package imports (e.g., `package:multi_calendar/src/models/mc_calendar_event.dart`)

### Module/Package Organization
- Use `package:multi_calendar/...` for internal imports
- Group related functionality in subdirectories
- Main export file (`lib/multi_calendar.dart`) exports public API only
- Internal implementation in `lib/src/` is not directly importable

## Code Structure Patterns

### Widget Organization
```dart
// 1. Imports
import 'package:flutter/material.dart';
import 'package:multi_calendar/src/models/mc_calendar_event.dart';

// 2. Class definition with documentation
/// McDayView displays events in a single day with configurable time range.
class McDayView extends StatefulWidget {
  // 3. Constructor with required parameters
  const McDayView({
    required this.controller,
    this.timeRange,
    this.onEventTap,
    // ...
  });

  // 4. Public properties
  final McEventController controller;
  final TimeRange? timeRange;
  final void Function(McCalendarEvent event, DateTime dateTime)? onEventTap;

  // 5. State class
  @override
  State<McDayView> createState() => _McDayViewState();
}

// 6. State implementation
class _McDayViewState extends State<McDayView> {
  // Private fields
  // Lifecycle methods
  // Build method
  // Helper methods
}
```

### Model Organization
```dart
// 1. Imports
// 2. Class definition
class McCalendarEvent {
  // 3. Public properties
  // 4. Constructor
  // 5. Factory constructors
  // 6. Methods
  // 7. Overrides (toString, ==, hashCode)
}
```

### Controller Organization
```dart
// 1. Imports
// 2. Class definition
class McEventController extends ChangeNotifier {
  // 3. Private fields
  // 4. Public properties
  // 5. Constructor
  // 6. Public methods
  // 7. Private helper methods
}
```

## Code Organization Principles

1. **Single Responsibility**: Each widget/model/controller has one clear purpose
2. **Modularity**: Views are independent widgets that can be used separately
3. **Testability**: Models and utilities are easily testable without Flutter dependencies
4. **Consistency**: Follow Flutter/Dart conventions throughout
5. **Separation of Concerns**: Display logic in views, data logic in controller, models are pure data

## Module Boundaries

### Public API vs Internal
- **Public**: Exported from `lib/multi_calendar.dart`
  - View widgets (MCalDayView, MCalMultiDayView, MCalMonthView) - prefixed with "MCal" to avoid conflicts
  - MCalEventController
  - MCalCalendarEvent model (includes `isAllDay` field for all-day event support)
  - Style/theme classes (MCalThemeData) - prefixed with "MCal"
- **Internal**: In `lib/src/` - not directly importable
  - Implementation details
  - Utility functions
  - Internal widgets

### View Independence
- Each view (Day, Multi-day, Month) is a separate widget
- Views can be used independently
- Shared utilities in `utils/` directory
- Common widgets in `widgets/` directory

### External Integration Points
- **McEventController**: Interface for loading events from external systems
- **Builder Callbacks**: Allow external customization of event tiles, cells, navigators, date/time labels
- **Event Models**: Simple data classes that external systems can populate
- **Callbacks**: onTap, onLongPress, onEventDrop, onEventResize, onHover* for external handling
- **Cell Interactivity**: Callback to disable cell interactions (e.g., blackout days)
- **Date Formatting**: Standard format strings or custom builders for date/time labels
- **Localization**: Package provides `MCalLocalizations` (generated by gen-l10n) with `.delegate` for consuming apps to wire into `MaterialApp.localizationsDelegates`. Widgets use standard `MCalLocalizations.of(context)` pattern. Date/time formatting provided by `MCalDateFormatUtils` utility class. Package exports `MCalLocalizations.supportedLocales` and `.localizationsDelegates` for locale discovery and delegate wiring.

## Code Size Guidelines

- **File size**: Maximum 500 lines per file (aim for 200-300)
- **Function/Method size**: Maximum 50 lines (aim for 10-20)
- **Widget build methods**: Keep under 100 lines, extract to helper methods
- **Class complexity**: Maximum 10 public methods per class
- **Nesting depth**: Maximum 4 levels of nesting

## Package Structure Principles

### View Widgets
- Each view is self-contained
- Shared styling via theme/style classes
- Common event tile logic in shared widgets
- View-specific logic stays in view file
- Optional navigator widget can be included per view
- Current time indicator for time-based views
- Responsive layout handling (mobile-first)
- RTL layout support built-in

### Event Controller
- Single controller handles all views
- Manages visible date range
- Delegates event loading to callbacks
- Notifies listeners of changes

### Models
- Pure data classes
- No business logic
- Serializable for external storage
- Immutable where possible

### Utilities
- Pure functions where possible
- No side effects
- Well-tested
- Reusable across views
- Date/time formatting via intl package
- Accessibility helpers for semantic labels
- RTL-aware layout utilities
- Date/time formatting utility via `MCalDateFormatUtils` class (`lib/src/utils/mcal_date_format_utils.dart`):
  - Provides date/time formatting: `formatDate()`, `formatTime()`, `formatMonthYear()`, `formatFullDateWithDayName()`
  - Provides static helpers for weekday/month names: `weekdayName()`, `weekdayShortName()`, `monthName()`
  - Provides RTL detection: `isRTL(locale)`
  - Provides multi-day span label formatting: `formatMultiDaySpanLabel()`

## Documentation Standards

- **Public API**: All public classes, methods, properties must have dartdoc comments
- **Complex Logic**: Inline comments for RRULE parsing, event expansion algorithms, gesture handling
- **Examples**: Code examples in README and dartdoc
- **README**: Comprehensive usage examples for each view, including localization, accessibility, RTL
- **CHANGELOG**: Maintained for each release
- **Accessibility**: Document semantic labels and accessibility features
- **Localization**: Document supported locales (en, es, fr, ar, he) and how to add new languages via ARB files and gen-l10n. Note the dual-system architecture: package-level `MCalLocalizations` (standard Flutter localization with `.of(context)` and `.delegate`) and example app-level `AppLocalizations` (standard context-based). Consuming apps must add `MCalLocalizations.delegate` to their `localizationsDelegates`. Package widgets use `MCalLocalizations.of(context)` for localized strings and `MCalDateFormatUtils` for date/time formatting.
- **Naming Convention**: Public calendar widgets and theme classes use "MCal" prefix (e.g., `MCalMonthView`, `MCalThemeData`) to avoid conflicts with other calendar packages

## Testing Structure

- **Unit Tests**: For models, utilities, controllers (in `test/`)
- **Widget Tests**: For view widgets (in `test/views/`)
- **Integration Tests**: For full calendar workflows (in `test/integration/`)
- **Test Coverage**: Aim for 80%+ coverage on core functionality
- **Test Data**: Shared test fixtures in `test/fixtures/`
- **Accessibility Tests**: Test semantic labels and screen reader compatibility
- **Localization Tests**: Test ARB file completeness, gen-l10n generation for both package and example app, date/time formatting, RTL layout (via `Directionality.of(context)`), all supported language strings (5 locales for both package and example app), `MCalLocalizations.of(context)` usage pattern
- **Gesture Tests**: Test drag-and-drop, resize, tap, long-press, double-tap interactions
- **Platform Tests**: Test mobile and desktop-specific features (hover, etc.)

## Example App Structure

```
example/
├── lib/
│   ├── main.dart                 # Main app entry (MaterialApp, locale, theme state)
│   ├── l10n/                     # Example app-level localization
│   │   ├── app_en.arb            # English (template, 5 locales total)
│   │   ├── app_es.arb            # Spanish
│   │   ├── app_fr.arb            # French
│   │   ├── app_ar.arb            # Arabic (RTL)
│   │   ├── app_he.arb            # Hebrew (RTL)
│   │   ├── app_localizations.dart       # Generated AppLocalizations class
│   │   └── ...                          # Generated per-locale classes
│   ├── screens/
│   │   └── main_screen.dart      # NavigationRail with Month/Day/Comparison
│   ├── views/
│   │   ├── month_view/           # Month view tabs and styles
│   │   ├── day_view/             # Day view tabs and styles
│   │   └── comparison/           # Side-by-side Month + Day comparison
│   ├── widgets/                  # Shared widgets (dialogs, bottom sheets, etc.)
│   └── utils/                    # Shared utilities (sample events, colors, formatters)
├── l10n.yaml                     # gen-l10n config (generates AppLocalizations)
├── pubspec.yaml                  # Example app dependencies (depends on multi_calendar via path)
└── README.md                     # Example app documentation
```

**Localization notes:**
- The example app has its own separate `gen-l10n` pipeline (configured via `example/l10n.yaml`)
- Example app uses `AppLocalizations.of(context)` for context-based locale lookup
- Package-level strings (day names, navigation labels, accessibility announcements) are accessed via `MCalLocalizations.of(context)` (standard Flutter localization pattern)
- The example app wires delegates in `MaterialApp` via `AppLocalizations.localizationsDelegates` plus `MCalLocalizations.delegate`
- Both package and example app support the same 5 locales (en, es, fr, ar, he)
