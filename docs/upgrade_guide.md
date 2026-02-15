# Upgrade Guide — multi_calendar

This guide helps you upgrade from previous versions of the `multi_calendar` package. It documents breaking changes, API migrations, new features, and provides code examples to minimize friction during upgrades.

## Table of Contents

- [Version Compatibility Matrix](#version-compatibility-matrix)
- [Upgrading to Unreleased (Day View + Month View Updates)](#upgrading-to-unreleased-day-view--month-view-updates)
- [Breaking Changes](#breaking-changes)
- [Shared Component API Changes](#shared-component-api-changes)
- [Day View Additions](#day-view-additions)
- [New Dependencies](#new-dependencies)
- [Deprecation Notices](#deprecation-notices)
- [Migration Timeline](#migration-timeline)
- [Quick Migration Checklist](#quick-migration-checklist)

---

## Version Compatibility Matrix

| Package Version | Flutter SDK | Dart SDK | Month View | Day View |
|-----------------|-------------|----------|------------|----------|
| **0.0.1**      | ≥1.17.0     | ^3.10.4  | ✅ Basic   | ❌ N/A   |
| **Unreleased** | ≥1.17.0     | ^3.10.4  | ✅ Full    | ✅ Full  |

### SDK Requirements

- **Flutter**: `>=1.17.0`
- **Dart**: `^3.10.4`
- **intl**: `^0.20.2`
- **teno_rrule**: `^0.0.8`

---

## Upgrading to Unreleased (Day View + Month View Updates)

The unreleased version introduces:

1. **Day View** — New `MCalDayView` widget for time-based daily schedules
2. **Month View updates** — Theme changes, layout architecture, renamed parameters
3. **Code organization** — Month-view-specific classes renamed with `MCalMonth*` prefix

### Step 1: Update pubspec.yaml

```yaml
dependencies:
  multi_calendar: ^0.0.2  # or latest when published
```

No new dependencies are required. The package continues to use `flutter`, `flutter_localizations`, `intl`, and `teno_rrule`.

### Step 2: Run pub get

```bash
flutter pub get
```

### Step 3: Apply breaking change migrations (see below)

---

## Breaking Changes

### 1. Theme Parameter Removed from MCalMonthView

**Before (0.0.1):**

```dart
MCalMonthView(
  controller: controller,
  theme: myCustomTheme,
  // ...
)
```

**After (Unreleased):**

```dart
MCalTheme(
  data: myCustomTheme,
  child: MCalMonthView(
    controller: controller,
    // ...
  ),
)
```

Theme must now be provided via the `MCalTheme` widget wrapper, `Theme.of(context).extension<MCalThemeData>()`, or package defaults.

---

### 2. initialDate Moved to MCalEventController

**Before (0.0.1):**

```dart
final controller = MCalEventController();

MCalMonthView(
  controller: controller,
  initialDate: DateTime(2024, 6, 1),
  // ...
)
```

**After (Unreleased):**

```dart
final controller = MCalEventController(initialDate: DateTime(2024, 6, 1));

MCalMonthView(
  controller: controller,
  // ...
)
```

The display date is now a single source of truth in the controller.

---

### 3. maxVisibleEvents Renamed to maxVisibleEventsPerDay

**Before (0.0.1):**

```dart
MCalMonthView(
  controller: controller,
  maxVisibleEvents: 3,
  // ...
)
```

**After (Unreleased):**

```dart
MCalMonthView(
  controller: controller,
  maxVisibleEventsPerDay: 5,  // default changed from 3 to 5
  // ...
)
```

---

### 4. renderMultiDayEventsAsContiguous Removed

**Before (0.0.1):**

```dart
MCalMonthView(
  controller: controller,
  renderMultiDayEventsAsContiguous: false,
  // ...
)
```

**After (Unreleased):**

The new layered architecture always renders multi-day events contiguously. This parameter has been removed. For alternative layouts (e.g., dots), use a custom `weekLayoutBuilder`.

---

### 5. multiDayEventTileBuilder Removed — Use eventTileBuilder

**Before (0.0.1):**

```dart
MCalMonthView(
  controller: controller,
  eventTileBuilder: (context, event, displayDate) => MyTimedTile(event),
  multiDayEventTileBuilder: (context, event, displayDate, isFirst, isLast) =>
      MyMultiDayTile(event, isFirst: isFirst, isLast: isLast),
)
```

**After (Unreleased):**

```dart
MCalMonthView(
  controller: controller,
  eventTileBuilder: (context, tileContext) {
    final segment = tileContext.segment;
    if (segment != null) {
      // Multi-day or single-day with segment info
      return MyEventTile(
        event: tileContext.event,
        isFirstSegment: segment.isFirstSegment,
        isLastSegment: segment.isLastSegment,
      );
    }
    return MyEventTile(event: tileContext.event);
  },
)
```

The unified `eventTileBuilder` receives `MCalEventTileContext` with optional `MCalMonthEventSegment` for segment information.

---

### 6. eventTileBuilder Signature Changed

**Before (0.0.1):**

```dart
typedef EventTileBuilder = Widget Function(
  BuildContext context,
  MCalCalendarEvent event,
  DateTime displayDate,
);
```

**After (Unreleased):**

```dart
// Now receives MCalEventTileContext
eventTileBuilder: (context, tileContext) {
  final event = tileContext.event;
  final displayDate = tileContext.displayDate;
  final segment = tileContext.segment;  // MCalMonthEventSegment? with isFirstSegment, isLastSegment, etc.
  // ...
}
```

---

## Shared Component API Changes

### MCalEventController

The controller is shared between Month View and Day View. Changes that affect both:

| Change | Description |
|--------|-------------|
| `initialDate` constructor param | **New** — Set initial display date: `MCalEventController(initialDate: DateTime(2024, 6, 1))` |
| `displayDate` getter | **Existing** — The currently displayed date |
| `focusedDate` getter | **Existing** — The focused date (e.g., user selection) |
| `setDisplayDate(date, {animate})` | **Existing** — Update display date with optional animation |
| `navigateToDate(date, {focus})` | **Existing** — Navigate and optionally focus |
| `shouldAnimateNextChange` | **Existing** — Check before animating; call `consumeAnimationFlag()` after reading |
| `loadEvents`, `retryLoad` | **Existing** — Override for custom event loading |

**No breaking changes** to `MCalEventController` for existing Month View users. The `initialDate` parameter is additive.

### MCalCalendarEvent

No changes. The model remains the same for both views.

### Month View Class Renames (Code Organization)

If you imported or referenced these types directly, update your code:

| Old Name (0.0.1) | New Name (Unreleased) |
|------------------|------------------------|
| `MCalDefaultWeekLayoutBuilder` | `MCalMonthDefaultWeekLayoutBuilder` |
| `MCalSegmentRowAssignment` | `MCalMonthSegmentRowAssignment` |
| `MCalOverflowInfo` | `MCalMonthOverflowInfo` |
| `MCalEventSegment` | `MCalMonthEventSegment` |
| `MCalWeekLayoutContext` | `MCalMonthWeekLayoutContext` |
| `MCalWeekLayoutConfig` | `MCalMonthWeekLayoutConfig` |
| `MCalOverflowIndicatorContext` | `MCalMonthOverflowIndicatorContext` |

**Example:**

```dart
// Before
import 'package:multi_calendar/multi_calendar.dart';
// MCalEventSegment, MCalWeekLayoutContext used in custom weekLayoutBuilder

// After
import 'package:multi_calendar/multi_calendar.dart';
// MCalMonthEventSegment, MCalMonthWeekLayoutContext
```

---

## Day View Additions

The unreleased version adds `MCalDayView` for time-based daily schedules. Use the same `MCalEventController` as Month View for synchronized multi-view apps.

### Adding Day View to Your App

```dart
import 'package:multi_calendar/multi_calendar.dart';

// Shared controller for Month + Day View
final controller = MCalEventController(initialDate: DateTime.now());

// Day View — time-based daily schedule
MCalDayView(
  controller: controller,
  startHour: 8,
  endHour: 18,
  showNavigator: true,
  enableDragToMove: true,
  enableResize: true,
  onTimeSlotTap: (slotContext) => _createEventAt(slotContext),
  onEventTap: (context, details) => _showEventDetails(details.event),
)
```

### Day View Features

| Feature | Description |
|---------|-------------|
| All-day events | Section at top; supports overflow indicator |
| Timed events | Overlap detection, side-by-side layout |
| Drag and drop | Move within day, across days, all-day ↔ timed conversion |
| Resize | Drag event edges to change duration |
| Time regions | `MCalTimeRegion` for blocked time, lunch breaks |
| Keyboard navigation | Tab, arrows, Enter, Cmd+N/E/D |
| Custom builders | `eventTileBuilder`, `timeRegionBuilder`, `gridlineBuilder`, etc. |

See [day_view.md](day_view.md) and [day_view_migration.md](day_view_migration.md) for full documentation.

---

## New Dependencies

**None.** The unreleased version does not add new package dependencies. Existing dependencies remain:

- `flutter` (sdk)
- `flutter_localizations` (sdk)
- `intl: ^0.20.2`
- `teno_rrule: ^0.0.8`

---

## Deprecation Notices

| Deprecated | Replacement | Notes |
|------------|-------------|-------|
| `theme` on `MCalMonthView` | `MCalTheme` widget | Removed in unreleased |
| `initialDate` on `MCalMonthView` | `MCalEventController(initialDate: ...)` | Removed in unreleased |
| `maxVisibleEvents` | `maxVisibleEventsPerDay` | Renamed in unreleased |
| `renderMultiDayEventsAsContiguous` | N/A (always contiguous) | Removed in unreleased |
| `multiDayEventTileBuilder` | `eventTileBuilder` with `segment` | Removed in unreleased |

---

## Migration Timeline

| Phase | Action | When |
|-------|--------|------|
| **1. Preparation** | Review this guide and CHANGELOG | Before upgrading |
| **2. Update** | Bump `multi_calendar` version, run `flutter pub get` | Upgrade step |
| **3. Theme** | Wrap `MCalMonthView` with `MCalTheme` if using custom theme | Immediate |
| **4. Controller** | Move `initialDate` to `MCalEventController` constructor | Immediate |
| **5. Parameters** | Rename `maxVisibleEvents` → `maxVisibleEventsPerDay` | Immediate |
| **6. Builders** | Merge `multiDayEventTileBuilder` into `eventTileBuilder` | Immediate |
| **7. Imports** | Update any direct references to renamed Month View classes | If applicable |
| **8. Verify** | Run `dart analyze` and `flutter test` | Before commit |

---

## Quick Migration Checklist

- [ ] Update `multi_calendar` version in `pubspec.yaml`
- [ ] Run `flutter pub get`
- [ ] Replace `MCalMonthView(theme: x)` with `MCalTheme(data: x, child: MCalMonthView(...))`
- [ ] Move `initialDate` from `MCalMonthView` to `MCalEventController(initialDate: ...)`
- [ ] Rename `maxVisibleEvents` to `maxVisibleEventsPerDay` (default now 5)
- [ ] Remove `renderMultiDayEventsAsContiguous` if used
- [ ] Merge `multiDayEventTileBuilder` logic into `eventTileBuilder` using `tileContext.segment`
- [ ] Update `eventTileBuilder` signature to accept `(context, tileContext)`
- [ ] Update any custom `weekLayoutBuilder` to use `MCalMonthEventSegment`, `MCalMonthWeekLayoutContext`
- [ ] Run `dart analyze` and fix any remaining issues
- [ ] Run `flutter test` to verify no regressions

---

## Additional Resources

- [CHANGELOG.md](../CHANGELOG.md) — Full release notes
- [docs/day_view.md](day_view.md) — Day View documentation
- [docs/day_view_migration.md](day_view_migration.md) — Migrating from other calendar packages to MCalDayView
- [docs/troubleshooting.md](troubleshooting.md) — Common issues and solutions
- [docs/best_practices.md](best_practices.md) — Recommended usage patterns
