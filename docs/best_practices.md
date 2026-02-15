# Day View Best Practices and Patterns

This guide provides recommended patterns and practices for using `MCalDayView` effectively. It draws from the example app implementation, test patterns, and common integration scenarios.

---

## Table of Contents

1. [Event Controller Management](#event-controller-management)
2. [Theme Organization](#theme-organization)
3. [Custom Builders](#custom-builders)
4. [Performance Optimization](#performance-optimization)
5. [Accessibility Implementation](#accessibility-implementation)
6. [Localization Setup](#localization-setup)
7. [Testing Strategies](#testing-strategies)
8. [State Management with Day View](#state-management-with-day-view)
9. [Integration with Backends](#integration-with-backends)
10. [Error Handling](#error-handling)

---

## Event Controller Management

### Do's

**Create and dispose the controller in State lifecycle**

```dart
class _DayViewShowcaseState extends State<DayViewShowcase> {
  late MCalEventController _eventController;

  @override
  void initState() {
    super.initState();
    _eventController = MCalEventController(initialDate: DateTime.now());
    _eventController.addEvents(createSampleEvents());
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }
}
```

**Share a single controller across multiple views for synchronization**

```dart
// Month View and Day View stay in sync when sharing the same controller
final controller = MCalEventController(initialDate: DateTime.now());

MCalMonthView(controller: controller);
MCalDayView(controller: controller);

// Clicking a day in Month View updates controller.displayDate
// Day View automatically shows that date
```

**Use `controller.displayDate` for date-scoped operations**

```dart
onEmptySpaceDoubleTap: (time) async {
  final event = await showCreateDialog(
    context,
    displayDate: controller.displayDate,
    initialTime: time,
  );
  if (event != null) controller.addEvents([event]);
}
```

### Don'ts

**Don't create a new controller on every build**

```dart
// BAD: Controller recreated every frame
Widget build(BuildContext context) {
  final controller = MCalEventController(initialDate: DateTime.now());
  return MCalDayView(controller: controller);
}
```

**Don't forget to dispose the controller**

```dart
// BAD: Memory leak
class MyWidget extends StatefulWidget { ... }
class _MyWidgetState extends State<MyWidget> {
  final controller = MCalEventController(initialDate: DateTime.now());
  // Missing dispose() - controller never released
}
```

**Don't mutate events without going through the controller**

```dart
// BAD: Direct mutation bypasses reactivity
event.start = newStart;  // Won't update the UI

// GOOD: Use controller methods
controller.removeEvents([event.id]);
controller.addEvents([event.copyWith(start: newStart, end: newEnd)]);
```

### Rationale

The controller owns event state and display date. Proper lifecycle management prevents memory leaks and ensures the widget tree rebuilds correctly when events change. Sharing a controller between Month and Day views provides a seamless multi-view experience.

---

## Theme Organization

### Do's

**Use `MCalTheme` to scope theme over one or more Day Views**

```dart
MCalTheme(
  data: MCalThemeData(
    hourGridlineColor: colorScheme.outline,
    currentTimeIndicatorColor: colorScheme.primary,
    timedEventBorderRadius: 8.0,
    timedEventMinHeight: 24.0,
  ),
  child: MCalDayView(controller: controller),
)
```

**Derive theme from `ThemeData` for consistency**

```dart
MCalThemeData toThemeData(ThemeData baseTheme) {
  final colorScheme = baseTheme.colorScheme;
  final base = MCalThemeData.fromTheme(baseTheme);
  return base.copyWith(
    hourGridlineColor: colorScheme.outline,
    currentTimeIndicatorColor: colorScheme.primary,
    eventTileBackgroundColor: colorScheme.primaryContainer,
  );
}
```

**Use per-widget `theme` parameter for local overrides**

```dart
MCalDayView(
  controller: controller,
  theme: MCalThemeData(
    currentTimeIndicatorColor: Colors.red,
    // Only override what you need
  ),
)
```

### Don'ts

**Don't hardcode colors that ignore theme**

```dart
// BAD: Ignores dark mode
MCalThemeData(
  hourGridlineColor: Colors.grey,
  eventTileBackgroundColor: Colors.white,
)

// GOOD: Use colorScheme
MCalThemeData(
  hourGridlineColor: colorScheme.outline,
  eventTileBackgroundColor: colorScheme.surfaceContainerHighest,
)
```

**Don't nest conflicting `MCalTheme` widgets without clear intent**

```dart
// BAD: Inner theme may override outer unexpectedly
MCalTheme(data: themeA, child:
  MCalTheme(data: themeB, child: MCalDayView(...))
)
```

### Rationale

Theme inheritance from `ThemeData` ensures your Day View respects dark mode and Material Design. Scoped `MCalTheme` lets you reuse styles across multiple Day Views in the same screen (e.g., different style tabs).

---

## Custom Builders

### When to Use

| Builder | Use Case |
|--------|----------|
| `timedEventTileBuilder` | Custom event tile appearance (colors, icons, badges) |
| `allDayEventTileBuilder` | Custom all-day section styling |
| `gridlineBuilder` | Different line styles for hour vs. minor gridlines |
| `dayHeaderBuilder` | Custom header layout (date, weekday, week number) |
| `timeLabelBuilder` | Custom time format (24h, 12h, locale-specific) |
| `draggedTileBuilder` | Custom drag feedback |
| `dropTargetTileBuilder` | Custom drop target highlight |
| `timeResizeHandleBuilder` | Custom resize handle |

### Do's

**Wrap the default when you only need to extend**

```dart
timedEventTileBuilder: (context, ctx, defaultTile) {
  return Container(
    decoration: BoxDecoration(
      color: ctx.event.color ?? Colors.blue,
      borderRadius: BorderRadius.circular(8),
    ),
    child: defaultTile,  // Reuse default content
  );
}
```

**Use context objects for layout decisions**

```dart
timedEventTileBuilder: (context, ctx, defaultTile) {
  // ctx.columnIndex, ctx.totalColumns for overlap styling
  final isFirstInColumn = ctx.columnIndex == 0;
  return Container(
    margin: EdgeInsets.only(left: isFirstInColumn ? 0 : 4),
    child: defaultTile,
  );
}
```

**Keep builders pure and lightweight**

```dart
// GOOD: No heavy computation
timeLabelBuilder: (context, ctx, defaultLabel) {
  return defaultLabel;  // Or a simple Text with ctx.hour
}
```

### Don'ts

**Don't create new widgets in builders unnecessarily**

```dart
// BAD: New StatefulWidget every rebuild
timedEventTileBuilder: (context, ctx, defaultTile) {
  return MyHeavyEventTile(event: ctx.event);  // Avoid if not needed
}
```

**Don't perform async work in builders**

```dart
// BAD: Builders must be synchronous
timedEventTileBuilder: (context, ctx, defaultTile) async {
  final data = await fetchData(ctx.event.id);  // Never do this
  return Tile(data: data);
}
```

**Don't ignore `defaultTile` when you only need to wrap**

```dart
// BAD: Reimplementing what defaultTile already provides
timedEventTileBuilder: (context, ctx, defaultTile) {
  return Column(
    children: [
      Text(ctx.event.title),
      Text(formatTime(ctx.event.start)),
    ],
  );
}
```

### Rationale

Builders are called frequently during scroll and rebuild. Keeping them lightweight keeps the Day View performant. Reusing `defaultTile` avoids duplicating layout logic and accessibility semantics.

---

## Performance Optimization

### Do's

**Limit visible hour range when possible**

```dart
MCalDayView(
  controller: controller,
  startHour: 8,
  endHour: 18,
  // Fewer hours = less DOM, faster scroll
)
```

**Use `hourHeight` for predictable layout**

```dart
MCalDayView(
  controller: controller,
  hourHeight: 80.0,
  // Avoids layout thrashing from auto-sizing
)
```

**Debounce or throttle backend sync in callbacks**

```dart
Timer? _syncDebounce;
void _onEventDropped(MCalEventDroppedDetails details) {
  _syncDebounce?.cancel();
  _syncDebounce = Timer(const Duration(milliseconds: 500), () {
    persistToBackend(details.event, details.newStartDate, details.newEndDate);
  });
}
```

**Use `RepaintBoundary` for custom event tiles**

```dart
timedEventTileBuilder: (context, ctx, defaultTile) {
  return RepaintBoundary(
    child: MyCustomTile(event: ctx.event),
  );
}
```

### Don'ts

**Don't create hundreds of events without virtualization**

```dart
// BAD: 1000 events in one day
controller.addEvents(List.generate(1000, (i) => MCalCalendarEvent(...));

// BETTER: Limit to visible range or paginate
```

**Don't do heavy work in callbacks during drag**

```dart
// BAD: Network call on every drop
onEventDropped: (details) {
  await api.updateEvent(details.event.id, ...);  // Blocks UI
}

// GOOD: Optimistic update, then sync
onEventDropped: (details) {
  controller.updateEvent(...);  // Already done by controller
  unawaited(_syncToBackend(details));
}
```

### Rationale

Day View renders a scrollable list of hour rows and event tiles. Reducing the number of visible hours and keeping builders lightweight maintains 60fps during scroll and drag.

---

## Accessibility Implementation

### Do's

**Enable keyboard navigation (default)**

```dart
MCalDayView(
  controller: controller,
  enableKeyboardNavigation: true,  // Default
  onCreateEventRequested: () => showCreateDialog(),
  onEditEventRequested: (event) => showEditDialog(event),
  onDeleteEventRequested: (event) => confirmDelete(event),
)
```

**Provide semantic labels for custom builders**

```dart
timedEventTileBuilder: (context, ctx, defaultTile) {
  return Semantics(
    label: '${ctx.event.title}, ${formatTimeRange(ctx.event.start, ctx.event.end)}',
    child: defaultTile,
  );
}
```

**Respect reduced motion**

```dart
MCalDayView(
  controller: controller,
  enableAnimations: null,  // Default: respects MediaQuery.disableAnimations
)
```

**Test with screen readers**

```dart
// Use flutter_test with semantics
await tester.pumpWidget(
  MaterialApp(
    home: MCalDayView(controller: controller),
  ),
);
expect(find.bySemanticsLabel('Time grid'), findsOneWidget);
```

### Don'ts

**Don't disable keyboard shortcuts without providing alternatives**

```dart
// BAD: No way to create event without mouse
enableKeyboardNavigation: false,
// No onCreateEventRequested

// GOOD: Always provide keyboard path
onCreateEventRequested: () => showCreateDialog(),
```

**Don't hide focus indicators**

```dart
// BAD: Users can't see focus
Focus(
  skipTraversal: true,
  child: MCalDayView(...),
)
```

### Rationale

Day View includes semantic labels for events, time labels, and grid. Keyboard shortcuts (Cmd/Ctrl+N, E, D) and Tab/Enter navigation provide full keyboard access. Respecting reduced motion improves accessibility for users with vestibular disorders.

---

## Localization Setup

### Do's

**Pass `locale` to Day View**

```dart
MCalDayView(
  controller: controller,
  locale: Localizations.localeOf(context),
)
```

**Use Flutter l10n for app strings**

```dart
// l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

```dart
MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: MCalDayView(controller: controller, locale: locale),
)
```

**Use `intl` for date/time formatting in dialogs**

```dart
import 'package:intl/intl.dart';

final timeFormat = DateFormat.jm(locale.toString());
final dateFormat = DateFormat.yMd(locale.toString());
```

**Initialize date formatting for tests**

```dart
setUpAll(() async {
  await initializeDateFormatting('en', null);
  await initializeDateFormatting('ar', null);
});
```

### Don'ts

**Don't hardcode locale-specific strings**

```dart
// BAD
Text('Delete Event')
Text('9 AM')

// GOOD
Text(l10n.deleteEvent)
// Time labels use format from locale
```

**Don't forget RTL**

```dart
// For RTL languages (Arabic, Hebrew)
MCalDayView(
  controller: controller,
  locale: const Locale('ar'),
)
// Or wrap in Directionality(textDirection: TextDirection.rtl, ...)
```

### Rationale

Day View uses `intl` for time labels and respects `locale` for date/time formatting. Passing the app locale ensures consistency. RTL support is built-in when locale or `Directionality` indicates RTL.

---

## Testing Strategies

### Do's

**Use `MCalEventController` in setUp/tearDown**

```dart
late MCalEventController controller;

setUp(() {
  controller = MCalEventController(initialDate: DateTime(2026, 2, 14));
});

tearDown(() {
  controller.dispose();
});
```

**Wrap in `MaterialApp` and `SizedBox` for layout**

```dart
await tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: SizedBox(
        height: 600,
        child: MCalDayView(controller: controller),
      ),
    ),
  ),
);
await tester.pumpAndSettle();
```

**Use `pumpAndSettle` for async layout**

```dart
await tester.pumpWidget(...);
await tester.pumpAndSettle();
expect(find.text('9 AM'), findsOneWidget);
```

**Test semantics for accessibility**

```dart
expect(find.bySemanticsLabel('Time grid'), findsOneWidget);
expect(find.bySemanticsLabel('Previous day'), findsOneWidget);
```

**Test drag/resize with `tester.drag`**

```dart
await tester.longPress(find.text('Meeting'));
await tester.pump(const Duration(milliseconds: 300));
await tester.drag(find.byType(MCalDayView), const Offset(0, 100));
await tester.pumpAndSettle();
```

### Don'ts

**Don't skip `pumpAndSettle` for scroll-dependent assertions**

```dart
// BAD: May fail if layout not ready
await tester.pumpWidget(...);
expect(find.text('9 AM'), findsOneWidget);

// GOOD
await tester.pumpAndSettle();
expect(find.text('9 AM'), findsOneWidget);
```

**Don't forget to dispose the controller**

```dart
tearDown(() {
  controller.dispose();
});
```

### Rationale

Day View uses `ScrollController`, `AnimationController`, and async layout. Proper pump and dispose ensure tests are deterministic and don't leak resources.

---

## State Management with Day View

### Do's

**Keep event state in the controller**

```dart
// Controller is the source of truth
controller.addEvents([event]);
controller.removeEvents([eventId]);
controller.setDisplayDate(date);
```

**Use callbacks for side effects**

```dart
MCalDayView(
  controller: controller,
  onEventTap: (context, details) {
    setState(() => _selectedEvent = details.event);
    showEventDetailSheet(context, details.event);
  },
  onEventDropped: (details) {
    // Persist to backend; controller already updated
    persistEvent(details.event, details.newStartDate, details.newEndDate);
  },
)
```

**Check `mounted` before async callbacks**

```dart
onEventDropped: (details) async {
  await persistToBackend(details);
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event moved')),
    );
  }
}
```

### Don'ts

**Don't duplicate event state**

```dart
// BAD: Two sources of truth
class _MyState extends State<MyWidget> {
  final controller = MCalEventController(...);
  List<MCalCalendarEvent> events = [];  // Redundant
}
```

**Don't mutate controller events from outside**

```dart
// BAD: Controller doesn't know about change
final event = controller.events.first;
event.title = 'New Title';

// GOOD
controller.removeEvents([event.id]);
controller.addEvents([event.copyWith(title: 'New Title')]);
```

### Rationale

The controller is the single source of truth for events and display date. Callbacks are for side effects (navigation, persistence, dialogs). Checking `mounted` prevents calling `setState` after disposal.

---

## Integration with Backends

### Do's

**Use optimistic updates**

```dart
onEventDropped: (details) {
  // Controller already updated
  unawaited(_syncToBackend(details.event, details.newStartDate, details.newEndDate));
}
```

**Validate before persisting**

```dart
onDragWillAccept: (details) {
  if (details.proposedStartDate.isBefore(DateTime.now())) {
    return false;
  }
  return true;
}
```

**Handle errors gracefully**

```dart
Future<void> _syncToBackend(MCalCalendarEvent event, DateTime start, DateTime end) async {
  try {
    await api.updateEvent(event.id, start: start, end: end);
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
      // Optionally revert
      controller.removeEvents([event.id]);
      controller.addEvents([event]);
    }
  }
}
```

**Load events on display date change**

```dart
controller.addListener(() {
  if (controller.displayDate != _lastLoadedDate) {
    _loadEventsForDate(controller.displayDate);
    _lastLoadedDate = controller.displayDate;
  }
});
```

### Don'ts

**Don't block on network in callbacks**

```dart
// BAD: Blocks UI
onEventDropped: (details) async {
  await api.updateEvent(...);  // User waits
}
```

**Don't ignore `onDragWillAccept` for validation**

```dart
// BAD: Invalid drops still applied
onEventDropped: (details) {
  if (details.newStartDate.isBefore(DateTime.now())) {
    return;  // Too late - controller already updated
  }
}
```

### Rationale

Optimistic updates keep the UI responsive. Validation in `onDragWillAccept` prevents invalid state. Async errors should be surfaced to the user without blocking the UI.

---

## Error Handling

### Do's

**Validate in form dialogs**

```dart
bool _validate() {
  final title = _titleController.text.trim();
  if (title.isEmpty) {
    setState(() => _titleError = 'Title is required');
    return false;
  }
  if (!_isAllDay && _end.isBefore(_start)) {
    setState(() => _timeError = 'End must be after start');
    return false;
  }
  return true;
}
```

**Handle null from dialogs**

```dart
final event = await showCreateEventDialog(context, ...);
if (event != null && mounted) {
  controller.addEvents([event]);
}
```

**Use `onResizeWillAccept` and `onDragWillAccept`**

```dart
MCalDayView(
  controller: controller,
  onDragWillAccept: (details) {
    if (details.proposedStartDate.weekday == DateTime.saturday) return false;
    return true;
  },
  onResizeWillAccept: (details) {
    if (details.proposedEndDate.difference(details.proposedStartDate).inMinutes < 15) {
      return false;
    }
    return true;
  },
)
```

### Don'ts

**Don't let exceptions propagate unhandled**

```dart
// BAD
onEventDropped: (details) {
  persistEvent(details);  // May throw
}

// GOOD
onEventDropped: (details) {
  try {
    persistEvent(details);
  } catch (e) {
    if (mounted) showErrorSnackBar(e);
  }
}
```

**Don't forget to check `mounted` after async**

```dart
// BAD
onEventTap: (context, details) async {
  await showDialog(...);
  ScaffoldMessenger.of(context).showSnackBar(...);  // May throw if disposed
}

// GOOD
onEventTap: (context, details) async {
  await showDialog(...);
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(...);
  }
}
```

### Rationale

Validation catches errors before they reach the controller. Callbacks can fire after the widget is disposed; checking `mounted` prevents crashes. `onDragWillAccept` and `onResizeWillAccept` provide user-friendly validation before any state change.

---

## Summary

| Area | Key Takeaway |
|------|--------------|
| Controller | Create in `initState`, dispose in `dispose`, share across views |
| Theme | Use `MCalTheme` and `ColorScheme`, avoid hardcoded colors |
| Builders | Reuse `defaultTile`, keep lightweight, no async |
| Performance | Limit hours, debounce sync, use `RepaintBoundary` |
| Accessibility | Enable keyboard nav, provide semantic labels |
| Localization | Pass `locale`, use l10n, initialize date formatting in tests |
| Testing | Dispose controller, use `pumpAndSettle`, wrap in `MaterialApp` |
| State | Controller is source of truth, check `mounted` in callbacks |
| Backend | Optimistic updates, validate in `onDragWillAccept` |
| Errors | Validate in forms, handle null, check `mounted` |

For more details, see [Day View Documentation](day_view.md) and the [example app](../example/).
