# Localization Alignment Analysis

> **Status**: For future processing. Identified during the `example-app-reorganization` spec but out of scope for that implementation. This should become its own spec.

## Problem Statement

The multi_calendar package and its example app use two different localization approaches, with the package using a non-standard context-free wrapper pattern while the example app uses the standard `of(context)` pattern. These should be aligned to follow Flutter's standard localization approach consistently.

## Current State

### Package-Level Localization (`lib/`)

**ARB files**: `lib/l10n/app_en.arb`, `app_es.arb`, `app_es_MX.arb`, `app_fr.arb`, `app_ar.arb`, `app_he.arb` (6 locales)

**gen-l10n config** (`l10n.yaml` at project root):
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: mcal_localizations.dart
output-class: MCalLocalizations
nullable-getter: false
```

**Generated class**: `MCalLocalizations` in `lib/l10n/mcal_localizations.dart` — this is a standard gen-l10n generated class with:
- `MCalLocalizations.of(context)` for context-based lookup
- `MCalLocalizations.delegate` for the `LocalizationsDelegate`
- `MCalLocalizations.localizationsDelegates` (includes Material + Widgets + Cupertino delegates)
- `MCalLocalizations.supportedLocales`

**Wrapper class**: `MCalLocalizations` in `lib/src/utils/mcal_localization.dart` — this is a **custom class with the same name** that wraps the generated class. It provides:
- `getLocalizedString(String key, Locale locale)` — a string-key-based lookup (essentially a big switch statement mapping string keys to generated getter calls)
- `formatDate()`, `formatTime()`, `formatMonthYear()`, `formatFullDateWithDayName()` — date/time formatting via `intl`
- `isRTL(locale)` — RTL detection
- `formatMultiDaySpanLabel()` — convenience method
- Uses `lookupMCalLocalizations(locale)` internally — bypasses the `of(context)` pattern entirely

**How widgets use it**: Widgets instantiate the wrapper directly:
```dart
final localizations = MCalLocalizations(); // The wrapper class, NOT the generated class
final label = localizations.getLocalizedString('today', locale);
```

This means the package **does not participate in Flutter's standard localization tree**. It never calls `MCalLocalizations.of(context)`. Instead, it gets the locale from widget parameters and does direct lookups.

### Example App-Level Localization (`example/lib/`)

**ARB files**: `example/lib/l10n/app_en.arb`, `app_es.arb`, `app_fr.arb`, `app_ar.arb`, `app_he.arb` (5 locales, no es_MX)

**gen-l10n config** (`example/l10n.yaml`):
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

**Generated class**: `AppLocalizations` in `example/lib/l10n/app_localizations.dart` — standard gen-l10n output

**How the example app uses it**: Standard Flutter pattern:
```dart
// In MaterialApp
localizationsDelegates: AppLocalizations.localizationsDelegates,
supportedLocales: AppLocalizations.supportedLocales,

// In widgets
final l10n = AppLocalizations.of(context);
l10n.appTitle;
```

**Problem**: Many example app strings are still hardcoded English (dialogs, control panels, SnackBars, style descriptions, etc.)

## Issues Identified

### Issue 1: Name Collision

The generated class and the wrapper class are both called `MCalLocalizations`. The wrapper imports the generated class with an alias:
```dart
import '../../l10n/mcal_localizations.dart' as l10n;
```
This creates confusion — importing `MCalLocalizations` gives you different things depending on which file you import from. The public export (`multi_calendar.dart`) exports the wrapper, shadowing the generated class.

### Issue 2: Context-Free Anti-Pattern

The package widgets bypass Flutter's localization tree entirely. They take a `locale` parameter and do direct lookups via `lookupMCalLocalizations(locale)`. This means:
- The package's `MCalLocalizations.delegate` is never used by the package itself
- Consuming apps don't need to add the package's delegate to their `localizationsDelegates` for the package to work (it works without it)
- But the generated class still exports `delegate` and `localizationsDelegates`, creating the impression that apps should wire them up
- The locale used by the package comes from widget parameters, not from the widget tree's `Locale`

### Issue 3: String-Key-Based Lookup

The wrapper uses `getLocalizedString(String key, Locale locale)` with a switch statement — this is fragile and loses the type safety that gen-l10n provides. If a key is misspelled, it silently returns the key string instead of failing at compile time.

### Issue 4: Locale Mismatch

Package supports 6 locales (en, es, es_MX, fr, ar, he). Example app supports 5 locales (en, es, fr, ar, he — no es_MX). These should be aligned.

### Issue 5: Formatting Utilities Mixed In

The wrapper class mixes localization lookup with date/time formatting utilities (`formatDate`, `formatTime`, etc.) and RTL detection. These are separate concerns.

## Flutter Standard Approach

### For Packages

The standard approach for Flutter packages that provide localized text (as seen in `syncfusion_flutter_calendar`, `flutter_localizations`, etc.):

1. **Use gen-l10n** to generate a `LocalizationsDelegate` and localization class
2. **Export the delegate** so consuming apps can add it to their `localizationsDelegates`
3. **Use `YourLocalizations.of(context)`** inside package widgets to get localized strings from the widget tree
4. **Set `synthetic-package: false`** in `l10n.yaml` (required as of Flutter 3.32+)
5. **Consuming apps** add the package delegate alongside their own:
   ```dart
   MaterialApp(
     localizationsDelegates: [
       ...AppLocalizations.localizationsDelegates,
       MCalLocalizations.delegate,  // Package delegate
     ],
   )
   ```

### For the Example App

The example app already follows the standard pattern with `AppLocalizations.of(context)`. It just needs:
1. All hardcoded strings moved to ARB files
2. Locale parity with the package (add es_MX or decide to drop it)

## Recommended Changes

### Phase 1: Rename to Eliminate Collision

- Rename the wrapper class from `MCalLocalizations` to something like `MCalLocalizationUtils` or `MCalDateFormatUtils`
- Keep only the formatting and RTL utilities in it (these are legitimately useful as context-free helpers)
- Remove the `getLocalizedString()` switch-based lookup

### Phase 2: Switch Package Widgets to Standard Pattern

- Package widgets should use `MCalLocalizations.of(context)` (the generated class) instead of instantiating the wrapper
- This requires that consuming apps add `MCalLocalizations.delegate` to their `localizationsDelegates`
- Add a fallback for when the delegate is not wired up (either throw a helpful error or use English defaults)

### Phase 3: Align Locale Support

- Decide on the canonical set of supported locales
- Ensure both package and example app ARB files cover the same locales
- If es_MX is kept, add it to the example app; if not, remove from the package

### Phase 4: Clean Up Exports

- Export the generated `MCalLocalizations` class (delegate, supportedLocales, localizationsDelegates)
- Export the renamed utility class for formatting helpers
- Update README and dartdoc to show the correct wiring pattern

### Phase 5: Example App Localization Completion

- Move all hardcoded English strings to ARB files
- Translate all 5 (or 6) languages
- This is being addressed in the `example-app-reorganization` spec (REQ-8)

## Impact Assessment

### Breaking Changes

- **Renaming `MCalLocalizations`**: Any consuming app that imports and uses the wrapper class will need to update imports. Since this is v0.0.1 and likely has no external consumers yet, this is low risk.
- **Requiring delegate wiring**: Consuming apps would need to add `MCalLocalizations.delegate` to their `localizationsDelegates`. If they don't, the package would need a graceful fallback.

### Migration Path

1. Deprecate `getLocalizedString()` and the wrapper's localization lookup functionality
2. Add migration guide showing old vs new pattern
3. Provide a transition period where both patterns work

## File Reference

| File | Role | Issue |
|------|------|-------|
| `lib/l10n/mcal_localizations.dart` | Generated localization class | Name collision with wrapper |
| `lib/src/utils/mcal_localization.dart` | Custom wrapper class | Non-standard pattern, name collision |
| `lib/multi_calendar.dart` | Package exports | Exports wrapper, shadows generated class |
| `l10n.yaml` | Package gen-l10n config | Correct |
| `example/l10n.yaml` | Example gen-l10n config | Missing es_MX |
| `example/lib/main.dart` | Example app entry | Only wires AppLocalizations, not MCalLocalizations |
| `lib/l10n/app_*.arb` | Package ARB files (6) | Correct |
| `example/lib/l10n/app_*.arb` | Example ARB files (5) | Missing es_MX, many strings hardcoded |
