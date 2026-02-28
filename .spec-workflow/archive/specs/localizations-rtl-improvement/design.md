# Design: Localizations & RTL Improvement

## Overview

This design refactors the multi_calendar package's localization system from a non-standard context-free wrapper pattern to Flutter's standard `of(context)` pattern, fixes RTL keyboard navigation bugs in both MCalMonthView and MCalDayView, localizes all hardcoded English screen reader announcement strings, and completes the example app's localization by replacing remaining hardcoded strings with `AppLocalizations.of(context)` lookups.

## Steering Document Alignment

### Technical Standards (tech.md)

- **Localization**: tech.md currently documents the non-standard wrapper pattern. This design replaces it with the standard Flutter package localization approach: `gen-l10n` + `of(context)` + delegate wiring. The `l10n.yaml` will be updated with `synthetic-package: false` per Flutter 3.32+ requirements.
- **Accessibility**: tech.md requires WCAG accessibility and platform-specific screen reader support. This design ensures all SemanticsService announcements are localized and use correct TextDirection.
- **Widget-based Architecture**: The `of(context)` pattern integrates naturally with Flutter's InheritedWidget system, consistent with the controller pattern documented in tech.md.

### Project Structure (structure.md)

- **Naming Conventions**: The renamed utility class `MCalDateFormatUtils` follows the `MCal` prefix convention documented in structure.md.
- **File Size**: All changes stay within the 500-line file maximum; no new files exceed guidelines.
- **Single Responsibility**: Separating string localization (gen-l10n generated class) from date/time formatting (utility class) follows the documented single-responsibility principle.
- **Localization Notes**: structure.md currently describes the `getLocalizedString(key, locale)` pattern — this will be updated to document `MCalLocalizations.of(context)` instead.

## Code Reuse Analysis

### Existing Components to Leverage

- **Generated `MCalLocalizations`** (`lib/l10n/mcal_localizations.dart`): Already exists and is fully functional with `of(context)`, `delegate`, `supportedLocales`. Currently unused by the package widgets — this design activates it.
- **`Directionality.of(context)`**: Already used in many places throughout both views. This design standardizes its use as the sole RTL detection mechanism in widget code.
- **`AppLocalizations`** (example app): Already has 424 keys and is wired up in the example app. Some keys may need to be added for gaps found during the audit.
- **Existing package ARB files** (6 locales): `lib/l10n/app_en.arb` through `app_he.arb` — will be extended with ~17 new announcement keys.

### Integration Points

- **`MaterialApp.localizationsDelegates`**: Example app's `main.dart` will add `MCalLocalizations.delegate` alongside existing delegates.
- **Package widget `build()` methods**: All calls to `localizations.getLocalizedString('key', locale)` will be replaced with `MCalLocalizations.of(context).propertyName`.
- **Example app ARB files**: New keys will be added to all 5 example ARB files for any remaining hardcoded strings.

## Architecture

### Change Strategy

The refactoring follows a bottom-up approach to minimize breakage:

1. **Rename utility class** (no widget changes yet — just the class name and removal of `getLocalizedString`)
2. **Update `l10n.yaml`** (add `synthetic-package: false`)
3. **Add new ARB keys** to package (for announcement strings)
4. **Replace `getLocalizedString` calls** in package widgets with `of(context)` lookups
5. **Fix RTL keyboard** navigation in both views
6. **Fix SemanticsService** announcement text direction and localize strings
7. **Wire delegate** in example app
8. **Fix example app** hardcoded strings
9. **Update exports** and steering documents

### RTL Arrow Key Reversal Pattern

All keyboard handlers that use left/right arrow keys for day navigation will apply an RTL multiplier:

```dart
final isRTL = Directionality.of(context) == TextDirection.rtl;
final rtlMultiplier = isRTL ? -1 : 1;

if (key == LogicalKeyboardKey.arrowLeft) {
  dayDelta = -1 * rtlMultiplier;  // LTR: -1 (past), RTL: +1 (future)
} else if (key == LogicalKeyboardKey.arrowRight) {
  dayDelta = 1 * rtlMultiplier;   // LTR: +1 (future), RTL: -1 (past)
}
// Up/Down remain unchanged
```

This pattern is applied in 5 locations:
1. Month View cell navigation (`_handleKeyEvent`)
2. Month View keyboard move mode (`_handleKeyboardMoveModeKey`)
3. Month View keyboard resize mode (`_handleKeyboardResizeModeKey`)
4. Day View navigation (`_handleKeyEvent` arrow left/right for prev/next day)
5. Day View keyboard move mode (`_handleKeyboardMoveKey`)

### Weekday/Month Name Lookup Pattern

The current pattern uses dynamic string keys:
```dart
// OLD: fragile string-key lookup
localizations.getLocalizedString(weekdayKeys[dayIndex], locale)
```

Since `MCalLocalizations.of(context)` provides typed getters (`.daySunday`, `.dayMonday`, etc.), dynamic lookup requires a helper. The renamed `MCalDateFormatUtils` will provide index-based accessors:

```dart
class MCalDateFormatUtils {
  /// Returns localized weekday name for the given day index (0=Sunday..6=Saturday)
  static String weekdayName(MCalLocalizations l10n, int dayOfWeek) {
    switch (dayOfWeek) {
      case 0: return l10n.daySunday;
      case 1: return l10n.dayMonday;
      // ...
    }
  }

  /// Returns localized short weekday name (0=Sun..6=Sat)
  static String weekdayShortName(MCalLocalizations l10n, int dayOfWeek) { ... }

  /// Returns localized month name (1=January..12=December)
  static String monthName(MCalLocalizations l10n, int month) { ... }
}
```

This preserves type safety while supporting the dynamic lookup pattern needed by the weekday header and navigator widgets.

## Components and Interfaces

### Component 1: MCalDateFormatUtils (renamed from MCalLocalizations wrapper)

- **File**: `lib/src/utils/mcal_date_format_utils.dart` (renamed from `mcal_localization.dart`)
- **Purpose**: Date/time formatting utilities and index-based localization accessors. No longer performs string-key-based localization lookup.
- **Interfaces**:
  - `String formatDate(DateTime date, Locale locale)` — retained
  - `String formatTime(DateTime time, Locale locale)` — retained
  - `String formatMonthYear(DateTime date, Locale locale)` — retained
  - `String formatFullDateWithDayName(DateTime date, Locale locale)` — retained
  - `String formatMultiDaySpanLabel(MCalLocalizations l10n, int spanLength, int dayPosition)` — updated to take l10n instance instead of locale
  - `bool isRTL(Locale locale)` — retained for context-free use cases
  - `static String weekdayName(MCalLocalizations l10n, int dayOfWeek)` — NEW
  - `static String weekdayShortName(MCalLocalizations l10n, int dayOfWeek)` — NEW
  - `static String monthName(MCalLocalizations l10n, int month)` — NEW
  - `static List<Locale> get supportedLocales` — retained
- **Removed**:
  - `getLocalizedString(String key, Locale locale)` — deleted
  - `_lookup(Locale locale)` — deleted (no longer bypasses widget tree)
- **Dependencies**: `intl` package for date formatting, `MCalLocalizations` generated class for index-based accessors
- **Reuses**: All existing formatting logic, just removes the string lookup layer

### Component 2: Package ARB Files (expanded)

- **Files**: `lib/l10n/app_en.arb`, `app_es.arb`, `app_es_MX.arb`, `app_fr.arb`, `app_ar.arb`, `app_he.arb`
- **Purpose**: Add ~17 new localization keys for screen reader announcement strings
- **New keys** (parameterized where needed):

| Key | English Value | Parameters |
|-----|--------------|------------|
| `announcementResizeCancelled` | "Resize cancelled" | — |
| `announcementMoveCancelled` | "Move cancelled for {title}" | title |
| `announcementEventSelectionCancelled` | "Event selection cancelled" | — |
| `announcementEventsHighlighted` | "{count} events. {title} highlighted. Tab to cycle, Enter to confirm." | count, title |
| `announcementEventSelected` | "Selected {title}. Arrow keys to move, Enter to confirm, Escape to cancel." | title |
| `announcementEventCycled` | "{title}. {index} of {total}." | title, index, total |
| `announcementMovingEvent` | "Moving {title} to {date}" | title, date |
| `announcementResizeModeEntered` | "Resize mode. Adjusting end edge. Arrow keys to resize, S for start, E for end, M for move mode, Enter to confirm." | — |
| `announcementResizingStartEdge` | "Resizing start edge" | — |
| `announcementResizingEndEdge` | "Resizing end edge" | — |
| `announcementMoveMode` | "Move mode" | — |
| `announcementMoveInvalidTarget` | "Move cancelled. Invalid target." | — |
| `announcementEventMoved` | "Moved {title} to {date}" | title, date |
| `announcementResizingProgress` | "Resizing {title} {edge} to {date}, {days} days" | title, edge, date, days |
| `announcementResizeInvalid` | "Resize cancelled. Invalid resize." | — |
| `announcementEventResized` | "Resized {title} to {start} through {end}" | title, start, end |

### Component 3: MCalMonthView (localization + RTL fixes)

- **File**: `lib/src/widgets/mcal_month_view.dart`
- **Changes**:
  1. Replace all `MCalLocalizations()` instantiations with `MCalLocalizations.of(context)` from gen-l10n import (11 instances)
  2. Replace all `getLocalizedString('key', locale)` calls with typed getters: `l10n.today`, `l10n.calendar`, `l10n.dropTargetPrefix`, etc. (14 calls)
  3. Replace `localizations.isRTL(locale)` with `Directionality.of(context) == TextDirection.rtl` in all widget build methods (keep `isRTL()` only in the navigator/header widgets that have their own locale parameter and no parent Directionality)
  4. Fix `_announceMonthChange`: replace hardcoded `TextDirection.ltr` with `Directionality.of(context)`
  5. Localize all hardcoded SemanticsService announcement strings using new ARB keys
  6. Fix `_handleKeyEvent` keyboard navigation: apply RTL multiplier to arrowLeft/arrowRight day delta
  7. Fix `_handleKeyboardMoveModeKey`: apply RTL multiplier to arrowLeft/arrowRight day delta
  8. Fix `_handleKeyboardResizeModeKey`: apply RTL multiplier to arrowLeft/arrowRight day delta
  9. Use `MCalDateFormatUtils.weekdayShortName(l10n, dayIndex)` for weekday header names (replacing `getLocalizedString(weekdayKeys[dayIndex], locale)`)
  10. Use `MCalDateFormatUtils.monthName(l10n, month)` for navigator month name
- **Dependencies**: `MCalLocalizations` (gen-l10n generated), `MCalDateFormatUtils`
- **RTL locations to fix**:
  - `_handleKeyEvent` ~line 1823 (cell navigation)
  - `_handleKeyboardMoveModeKey` ~line 2159 (move mode)
  - `_handleKeyboardResizeModeKey` ~line 2556 (resize mode)

### Component 4: MCalDayView (localization + RTL fixes)

- **File**: `lib/src/widgets/mcal_day_view.dart`
- **Changes**:
  1. Replace all `MCalLocalizations()` instantiations with `MCalLocalizations.of(context)` (6 instances)
  2. Replace all `getLocalizedString('key', locale)` calls with typed getters (14 calls)
  3. Replace `localizations.isRTL(locale)` with `Directionality.of(context) == TextDirection.rtl` in widget build methods
  4. Fix keyboard navigation ~line 1545-1553: reverse arrowLeft/arrowRight for prev/next day in RTL
  5. Fix keyboard move mode ~line 1596-1600: reverse arrowLeft/arrowRight day delta in RTL
  6. Navigator widget already handles RTL for button layout — verify it works correctly with `Directionality.of(context)` instead of `isRTL(locale)`
- **Dependencies**: `MCalLocalizations` (gen-l10n generated), `MCalDateFormatUtils`
- **RTL locations to fix**:
  - `_handleNormalKeyEvent` ~line 1548 (arrowLeft/arrowRight navigation)
  - `_handleKeyboardMoveKey` ~line 1596 (move mode arrowLeft/arrowRight)

### Component 5: l10n.yaml Update

- **File**: `l10n.yaml`
- **Change**: Add `synthetic-package: false`
- **Result**:
  ```yaml
  arb-dir: lib/l10n
  template-arb-file: app_en.arb
  output-localization-file: mcal_localizations.dart
  output-class: MCalLocalizations
  nullable-getter: false
  synthetic-package: false
  ```

### Component 6: Package Exports Update

- **File**: `lib/multi_calendar.dart`
- **Changes**:
  1. Replace `export 'src/utils/mcal_localization.dart'` with `export 'src/utils/mcal_date_format_utils.dart'`
  2. Add `export 'l10n/mcal_localizations.dart'` to export the generated class (`MCalLocalizations` with `of`, `delegate`, `supportedLocales`, `localizationsDelegates`)
- **Result**: Consuming apps can import both `MCalLocalizations` and `MCalDateFormatUtils` from the single package import

### Component 7: Example App Delegate Wiring

- **File**: `example/lib/main.dart`
- **Changes**:
  1. Import `package:multi_calendar/multi_calendar.dart` (or just the generated localizations file)
  2. Add `MCalLocalizations.delegate` to `localizationsDelegates`:
     ```dart
     localizationsDelegates: [
       ...AppLocalizations.localizationsDelegates,
       MCalLocalizations.delegate,
     ],
     ```
  3. Localize the app title: `title: AppLocalizations.of(context)?.appTitle ?? 'Multi Calendar Examples'` (or use `onGenerateTitle`)

### Component 8: Example App Hardcoded String Fixes

14 files need modifications. The changes are grouped by type:

#### 8a. Control Panel Labels (month_features_tab.dart, day_features_tab.dart, day_theme_tab.dart)

Replace all hardcoded section headers and setting labels with `AppLocalizations.of(context)!` lookups. These files already import AppLocalizations but have sections where the localization calls were missed. Existing ARB keys from the 424 already cover most section and setting labels (e.g., `sectionNavigation`, `settingShowNavigator`, etc.). For `day_theme_tab.dart`, remove the null-check fallback pattern and use `AppLocalizations.of(context)!` directly.

#### 8b. SnackBar Messages (month_features_tab.dart, day_features_tab.dart, day_*_style.dart files)

Replace hardcoded SnackBar messages with parameterized `AppLocalizations` lookups. Existing keys like `snackbarCellTap`, `snackbarEventDropped`, etc. should already be in the ARB files — verify and add any missing ones.

#### 8c. Accessibility Content (month_accessibility_tab.dart)

Replace all hardcoded keyboard shortcut labels, screen reader guide text, checklist items, and navigation flow descriptions with `AppLocalizations.of(context)!` lookups. This requires the most new ARB keys — approximately 40-50 strings. Check existing keys (the `accessibility*` prefix group has 68 keys) and add any that are missing.

#### 8d. Style Widget Text (month_classic_style.dart, month_modern_style.dart)

Replace "Prev", "Next", and "Today" with `AppLocalizations.of(context)!` lookups or use package-level localized strings from `MCalLocalizations.of(context)`.

#### 8e. Sample/Stress Test Data (sample_events.dart, stress_test_events.dart, day_stress_test_tab.dart)

These are mock data event titles. Per REQ-12.5, the maintainer may choose to keep them in English as realistic mock data. If localization is desired, the generator functions would need to accept a `BuildContext` or localized title list parameter. The design recommendation is to **keep sample event titles in English** (they represent real-world event data from English-speaking organizations) and add a code comment documenting this decision.

#### 8f. App Title (main.dart)

Use `onGenerateTitle` callback:
```dart
onGenerateTitle: (context) => AppLocalizations.of(context)?.appTitle ?? 'Multi Calendar Examples',
```

### Component 9: Locale Alignment

- **Decision**: Remove `es_MX` from the package to align with the example app's 5-locale set (en, es, fr, ar, he). Mexican Spanish is a minor variant that adds maintenance burden without significant value at this stage.
- **Files affected**: Delete `lib/l10n/app_es_MX.arb`, update `l10n.yaml` if needed
- **Alternative**: If maintaining es_MX is preferred, add `example/lib/l10n/app_es_MX.arb` instead. The design defers this decision to the maintainer.

### Component 10: Steering Documents

- **`tech.md`**: Update the "Localization" section under Key Dependencies to describe the `of(context)` pattern. Replace references to `getLocalizedString(key, locale)` with `MCalLocalizations.of(context).propertyName`. Update the `MCalLocalizations` description to say it's the gen-l10n generated class. Note that `MCalDateFormatUtils` handles formatting only. Update RTL description to note `Directionality.of(context)` as primary mechanism.
- **`structure.md`**: Update the Utilities section to describe `MCalDateFormatUtils` instead of the old `MCalLocalizations` wrapper. Remove mention of `getLocalizedString`. Update the localization notes under External Integration Points.

## Data Models

No new data models are introduced. The only model-level change is adding new string keys to ARB files (JSON format), which are compiled into the existing generated `MCalLocalizations` class by `gen-l10n`.

## Error Handling

### Error Scenarios

1. **Consuming app does not wire `MCalLocalizations.delegate`**
   - **Handling**: `MCalLocalizations.of(context)` will throw a `FlutterError` with a message like: "No MCalLocalizations found. Please add MCalLocalizations.delegate to your app's localizationsDelegates."
   - **User Impact**: Clear crash with actionable error message during development. This is consistent with how `MaterialLocalizations.of(context)` behaves.
   - **Note**: The generated class already throws when the delegate is missing (via the `!` operator on `Localizations.of<MCalLocalizations>(context, MCalLocalizations)!`). We just need to ensure the error message is clear.

2. **Locale not supported by the package**
   - **Handling**: gen-l10n's delegate automatically falls back to the closest supported locale. If the app's locale is `de` (German, not supported), it falls back to `en`.
   - **User Impact**: English strings appear instead of the unsupported language. No crash.

3. **Missing ARB key in translation file**
   - **Handling**: `flutter gen-l10n` will fail at compile time if a key exists in the template (`app_en.arb`) but not in a translation file.
   - **User Impact**: Build error with clear message identifying the missing key and file.

## Testing Strategy

### Unit Testing

- Update `test/utils/localization_test.dart` to test `MCalDateFormatUtils` (renamed class) — verify `formatDate`, `formatTime`, `formatMonthYear`, `weekdayName`, `weekdayShortName`, `monthName`
- Add tests for `isRTL()` utility method

### Widget Testing

- **RTL keyboard navigation tests** (new):
  - Month View: Verify arrowLeft = +1 day when wrapped in `Directionality(textDirection: TextDirection.rtl)`
  - Month View: Verify arrowRight = -1 day in RTL
  - Month View: Verify arrowLeft = -1 day in LTR (regression)
  - Month View: Verify arrowUp/arrowDown unaffected by RTL
  - Day View: Verify arrowLeft = next day in RTL
  - Day View: Verify arrowRight = previous day in RTL
  - Day View keyboard move: Verify day shift reversal in RTL
  - Month View keyboard move: Verify day shift reversal in RTL
  - Month View keyboard resize: Verify delta reversal in RTL

- **Localization pattern tests** (update existing):
  - Verify `MCalLocalizations.of(context)` works when delegate is wired
  - Verify correct locale-specific strings appear

### Integration Testing

- `flutter gen-l10n` passes for both package and example app
- `flutter analyze` passes for both package and example app
- `flutter build apk --debug` passes for example app
- Grep for `getLocalizedString` in `lib/src/` returns zero results
- Grep for hardcoded English user-facing strings in new example app files returns zero results (excluding intentional mock data)

### End-to-End Testing

- Manual: Run example app in Arabic (ar) — verify all text is Arabic, layout is RTL
- Manual: Use keyboard navigation in Arabic locale — verify arrow keys move in visual direction
- Manual: Switch between all 5 languages — verify no missing strings or fallback text
- Manual: Verify screen reader announcements use correct language (test via accessibility inspector)
