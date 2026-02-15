# MCalDayView Troubleshooting Guide

This guide helps you diagnose and fix common issues when using the Day View calendar widget in the `multi_calendar` package. Each section covers symptoms, causes, solutions with code examples, and prevention tips.

## Table of Contents

- [Events Not Appearing](#events-not-appearing)
- [Drag/Drop Not Working](#dragdrop-not-working)
- [Resize Handles Missing](#resize-handles-missing)
- [Theme Not Applying](#theme-not-applying)
- [Performance Issues](#performance-issues)
- [Overlap Layout Problems](#overlap-layout-problems)
- [Scroll Behavior Issues](#scroll-behavior-issues)
- [Keyboard Shortcuts Not Working](#keyboard-shortcuts-not-working)
- [RTL Layout Issues](#rtl-layout-issues)
- [Debugging Tips](#debugging-tips)

---

## Events Not Appearing

### Symptoms

- Day View renders but no events are visible
- All-day section is empty when you expect all-day events
- Timed events section shows only gridlines, no event tiles

### Common Causes

1. **Display date mismatch** — Events are on a different day than the controller's display date
2. **Events outside time range** — Events fall before `startHour` or after `endHour`
3. **Controller not shared or events added after build** — Events added to a different controller instance or after the widget has built
4. **All-day events with wrong date** — All-day events use `end` at midnight (same as start) but date doesn't match display date
5. **Empty or filtered event list** — Controller's `eventsForDate` returns nothing for the display date

### Solutions

**1. Ensure display date matches your events**

```dart
// BAD: Controller shows today, but events are on a specific date
final controller = MCalEventController(initialDate: DateTime.now());
controller.addEvents([
  MCalCalendarEvent(
    id: '1',
    title: 'Meeting',
    start: DateTime(2026, 2, 14, 10, 0),
    end: DateTime(2026, 2, 14, 11, 0),
  ),
]);
// If today is not 2026-02-14, event won't show

// GOOD: Set display date to match events
final controller = MCalEventController(initialDate: DateTime(2026, 2, 14));
controller.addEvents([...]);
// Or navigate after adding: controller.setDisplayDate(DateTime(2026, 2, 14));
```

**2. Expand time range to include your events**

```dart
MCalDayView(
  controller: controller,
  startHour: 0,   // Default 0 - show from midnight
  endHour: 23,    // Default 23 - show to 11 PM
  // If events are at 7 AM or 10 PM, ensure they're within range
)
```

**3. Add events before building and use the same controller**

```dart
// BAD: Creating new controller per build
Widget build(BuildContext context) {
  final ctrl = MCalEventController(initialDate: date);  // New instance each build!
  ctrl.addEvents(events);
  return MCalDayView(controller: ctrl);
}

// GOOD: Use StatefulWidget and keep controller in state
class _MyCalendarState extends State<MyCalendar> {
  late final MCalEventController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MCalEventController(initialDate: widget.initialDate);
    _controller.addEvents(widget.events);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MCalDayView(controller: _controller);
  }
}
```

**4. All-day events: use correct date normalization**

```dart
// All-day events: start and end should be on the display date
final d = DateTime(2026, 2, 14);
MCalCalendarEvent(
  id: 'holiday',
  title: 'Holiday',
  start: DateTime(d.year, d.month, d.day, 0, 0),
  end: DateTime(d.year, d.month, d.day, 0, 0),  // Same day, or 23:59:59
  isAllDay: true,
)
```

### Prevention Tips

- Use `controller.displayDate` when creating events to ensure they match
- Call `controller.addEvents()` in `initState` or before the first build
- Log `controller.eventsForDate(controller.displayDate)` to verify events are returned
- Use the example app's sample events as a reference for correct structure

---

## Drag/Drop Not Working

### Symptoms

- Long-press on event does nothing
- Events cannot be moved to a new time
- No drag preview or drop target overlay

### Common Causes

1. **`enableDragToMove` is false** — Default is `false`; must be explicitly enabled
2. **Gesture conflicts** — Scroll view or parent absorbs the long-press
3. **`onDragWillAccept` returning false** — Validation callback rejects all drops
4. **Controller not updating** — `onEventDropped` not persisting or controller not updating event

### Solutions

**1. Enable drag explicitly**

```dart
MCalDayView(
  controller: controller,
  enableDragToMove: true,  // Required! Default is false
)
```

**2. Avoid gesture conflicts in tests**

```dart
// In widget tests, use NeverScrollableScrollPhysics or custom ScrollBehavior
// so scroll doesn't win the gesture arena over drag
MCalDayView(
  controller: controller,
  enableDragToMove: true,
  scrollPhysics: const NeverScrollableScrollPhysics(),
)
```

**3. Ensure `onDragWillAccept` allows valid drops**

```dart
MCalDayView(
  controller: controller,
  enableDragToMove: true,
  onDragWillAccept: (details) {
    // Don't reject everything - return true for valid drops
    if (details.proposedStartDate.isBefore(DateTime.now())) {
      return false;
    }
    return true;
  },
)
```

**4. Persist in `onEventDropped` (controller updates automatically)**

```dart
MCalDayView(
  controller: controller,
  enableDragToMove: true,
  onEventDropped: (details) {
    // Controller updates the event automatically — no need to call updateEvent
    // Use the callback to persist to your backend
    api.updateEvent(details.event.id, details.newStartDate, details.newEndDate);
  },
)
```

### Prevention Tips

- Always set `enableDragToMove: true` when you want drag
- Use `dragLongPressDelay` (default 200ms) if taps are accidentally starting drags
- Test `onDragWillAccept` logic with valid and invalid drop targets

---

## Resize Handles Missing

### Symptoms

- Timed events show no top/bottom resize handles
- Cannot drag event edges to change duration

### Common Causes

1. **`enableDragToResize` is false** — On phones it defaults to false (platform auto-detect)
2. **`enableDragToMove` is false** — Resize requires drag to move to be enabled first
3. **Custom `timedEventTileBuilder` obscures handles** — Builder wraps content and hides resize affordances
4. **All-day events** — Resize only applies to timed events, not all-day

### Solutions

**1. Force enable resize on all platforms**

```dart
MCalDayView(
  controller: controller,
  enableDragToMove: true,   // Required for resize
  enableDragToResize: true, // Force enable (null = auto: desktop/tablet yes, phone no)
)
```

**2. Ensure drag-to-move is enabled**

```dart
// Resize depends on drag infrastructure
MCalDayView(
  controller: controller,
  enableDragToMove: true,  // Must be true
  enableDragToResize: true,
)
```

**3. Custom builders don't hide resize handles**

Resize handles are added by the Day View around your custom tile. Your builder only replaces the tile content. Ensure your custom tile doesn't use `IgnorePointer` or `AbsorbPointer` on the tile edges, which could block resize handle hits.

**4. Custom resize handle builder**

```dart
MCalDayView(
  controller: controller,
  enableDragToResize: true,
  timeResizeHandleBuilder: (context, event, edge) {
    return Container(
      height: 8,
      color: Colors.blue.withOpacity(0.5),
      child: Center(
        child: Icon(
          edge == MCalResizeEdge.start ? Icons.expand_less : Icons.expand_more,
          size: 16,
        ),
      ),
    );
  },
)
```

### Prevention Tips

- Use `enableDragToResize: true` when you need resize on mobile
- Always enable `enableDragToMove` when using resize
- In custom builders, include `defaultTile` as a child to preserve resize handles

---

## Theme Not Applying

### Symptoms

- Gridlines, colors, or fonts don't match your app theme
- `MCalThemeData` properties seem ignored
- Dark mode not reflected in Day View

### Common Causes

1. **Theme not wrapped correctly** — `MCalTheme` or `theme` parameter not applied
2. **Theme override order** — Per-widget `theme` overrides `MCalTheme`; later wins
3. **Missing `copyWith` for new properties** — Custom theme not including all fields
4. **Material `ThemeData` not inherited** — Some defaults come from `Theme.of(context)`

### Solutions

**1. Wrap with MCalTheme**

```dart
MCalTheme(
  data: MCalThemeData(
    hourGridlineColor: Colors.grey.shade300,
    currentTimeIndicatorColor: Colors.red,
    timedEventBorderRadius: 8,
  ),
  child: MCalDayView(controller: controller),
)
```

**2. Use per-widget theme for overrides**

```dart
MCalDayView(
  controller: controller,
  theme: MCalThemeData(
    currentTimeIndicatorColor: Colors.blue,
    // Only override what you need; rest comes from MCalTheme or defaults
  ),
)
```

**3. Use `MCalThemeData.fromTheme` for Material integration**

```dart
final mcalTheme = MCalThemeData.fromTheme(Theme.of(context));
// Then customize:
final customTheme = mcalTheme.copyWith(
  hourGridlineColor: Colors.blue.shade200,
);
MCalTheme(data: customTheme, child: MCalDayView(controller: controller));
```

**4. Dark mode**

```dart
MCalTheme(
  data: MCalThemeData.fromTheme(Theme.of(context)),
  child: MCalDayView(controller: controller),
)
// fromTheme uses Theme.of(context) which respects Brightness.dark
```

### Prevention Tips

- Prefer `MCalTheme` at app or screen level for consistent theming
- Use `MCalThemeData.fromTheme(Theme.of(context))` to align with Material theme
- Test both light and dark themes

---

## Performance Issues

### Symptoms

- Janky scrolling with many events
- Slow frame rate during drag
- High memory usage with 100+ events

### Common Causes

1. **Too many events without virtualization** — Day View uses a scrollable list; many overlapping events increase layout cost
2. **Heavy custom builders** — Builders that do expensive work per event
3. **Frequent rebuilds** — Controller or parent state changing often
4. **Large `hourHeight`** — Very tall hours mean more pixels to paint

### Solutions

**1. Limit visible events or use business hours**

```dart
MCalDayView(
  controller: controller,
  startHour: 8,
  endHour: 18,
  // Fewer hours = less content to render
)
```

**2. Keep builders lightweight**

```dart
// BAD: Expensive work in builder
timedEventTileBuilder: (context, event, ctx, defaultTile) {
  final image = decodeImage(event.imageUrl);  // Don't do I/O in build
  return ComplexWidget(data: image);
}

// GOOD: Simple decoration, defer heavy work
timedEventTileBuilder: (context, event, ctx, defaultTile) {
  return Container(
    decoration: BoxDecoration(color: event.color),
    child: defaultTile,
  );
}
```

**3. Use `RepaintBoundary` for complex custom painters**

```dart
// If you have a custom gridlineBuilder or similar that's expensive
gridlineBuilder: (context, ctx, defaultLine) {
  return RepaintBoundary(child: defaultLine);
}
```

**4. Debounce controller updates**

```dart
// If adding many events at once, batch them
controller.addEvents(allEvents);
// Rather than:
for (final e in allEvents) {
  controller.addEvents([e]);  // Triggers rebuild each time
}
```

### Prevention Tips

- Profile with Flutter DevTools (Performance tab)
- Use `hourHeight` to control density; smaller = more compact, less to paint
- Avoid async or I/O in builders
- Batch event updates

---

## Overlap Layout Problems

### Symptoms

- Overlapping events stack on top of each other
- Events appear too narrow or too wide
- Column assignment seems wrong for overlapping events

### Common Causes

1. **Events filtered incorrectly** — All-day events included in overlap detection (they shouldn't be)
2. **Date mismatch** — Overlap uses `displayDate`; events on other dates are excluded
3. **Custom builder ignoring `columnIndex` / `totalColumns`** — Custom tile doesn't use context for width
4. **Equal start/end times** — Zero-duration events can cause layout edge cases

### Solutions

**1. Ensure only timed events for display date are passed**

The Day View filters events by `displayDate` and `isAllDay`. Overlap detection runs on timed events only. If you're using a custom data source, ensure:

```dart
final timedEvents = controller.eventsForDate(controller.displayDate)
    .where((e) => !e.isAllDay)
    .toList();
```

**2. Use `columnIndex` and `totalColumns` in custom builders**

The Day View positions tiles with correct width based on `ctx.totalColumns`. If you need custom layout, use the context:

```dart
timedEventTileBuilder: (context, event, ctx) {
  // ctx.columnIndex and ctx.totalColumns describe overlap layout
  // Default positioning handles width; use these for styling (e.g. alternating colors)
  return Container(
    color: ctx.columnIndex.isEven ? Colors.blue : Colors.indigo,
    child: Text(event.title),
  );
}
```

**3. Avoid zero-duration timed events**

```dart
// BAD: Same start and end
MCalCalendarEvent(
  start: DateTime(2026, 2, 14, 10, 0),
  end: DateTime(2026, 2, 14, 10, 0),
  isAllDay: false,
)

// GOOD: At least 1 time slot
MCalCalendarEvent(
  start: DateTime(2026, 2, 14, 10, 0),
  end: DateTime(2026, 2, 14, 10, 15),
  isAllDay: false,
)
```

### Prevention Tips

- Use the default `timedEventTileBuilder` when possible; it handles overlap correctly
- Ensure event `start` < `end` for timed events
- Check `MCalTimedEventTileContext.columnIndex` and `totalColumns` in custom layouts

---

## Scroll Behavior Issues

### Symptoms

- Day View doesn't scroll to current time on load
- Initial scroll position is wrong
- Scroll controller doesn't work
- Can't scroll to see events at bottom of day

### Common Causes

1. **`autoScrollToCurrentTime`** — When true, scrolls to "now" which may be off-screen if outside `startHour`/`endHour`
2. **`initialScrollTime` not set** — When `autoScrollToCurrentTime` is false, no initial scroll target
3. **ScrollController attached to wrong scrollable** — Day View has internal scroll; external controller must be passed correctly
4. **`scrollPhysics`** — Custom physics (e.g. `NeverScrollableScrollPhysics`) can disable scrolling

### Solutions

**1. Control initial scroll**

```dart
MCalDayView(
  controller: controller,
  autoScrollToCurrentTime: false,
  initialScrollTime: const TimeOfDay(hour: 9, minute: 0),
  // Starts scrolled to 9 AM
)
```

**2. Use external ScrollController**

```dart
final scrollController = ScrollController();

MCalDayView(
  controller: controller,
  scrollController: scrollController,
)

// Later: scrollController.animateTo(offset, ...);
```

**3. Ensure scrollable area has height**

```dart
Scaffold(
  body: SizedBox(
    height: MediaQuery.of(context).size.height - kToolbarHeight,
    child: MCalDayView(controller: controller),
  ),
)
```

### Prevention Tips

- Use `initialScrollTime` when you want a specific start position
- Set `autoScrollToCurrentTime: false` if current time is outside your `startHour`/`endHour`
- Give Day View a bounded height (e.g. inside `Expanded` or `SizedBox`)

---

## Keyboard Shortcuts Not Working

### Symptoms

- Cmd/Ctrl+N doesn't create event
- Delete key doesn't delete focused event
- Tab doesn't move focus between events

### Common Causes

1. **`enableKeyboardNavigation` is false** — Default is true, but may be disabled
2. **Day View not focused** — Shortcuts only work when Day View has focus
3. **Callbacks not provided** — `onCreateEventRequested`, `onDeleteEventRequested`, `onEditEventRequested` must be set for shortcuts to do anything
4. **Focus stolen by another widget** — Dialog or text field captures focus

### Solutions

**1. Enable keyboard navigation and provide callbacks**

```dart
MCalDayView(
  controller: controller,
  enableKeyboardNavigation: true,
  onCreateEventRequested: () => showCreateEventDialog(context),
  onEditEventRequested: (event) => showEditEventDialog(context, event),
  onDeleteEventRequested: (event) => confirmAndDelete(context, event),
)
```

**2. Focus Day View before testing shortcuts**

```dart
// In tests or when opening the calendar screen
FocusScope.of(context).requestFocus(dayViewFocusNode);
// Or tap the Day View to give it focus
```

**3. Override keyboard shortcuts**

```dart
MCalDayView(
  controller: controller,
  keyboardShortcuts: {
    SingleActivator(LogicalKeyboardKey.keyN, meta: true): MCalDayViewCreateEventIntent(),
    SingleActivator(LogicalKeyboardKey.keyN, control: true): MCalDayViewCreateEventIntent(),
  },
  onCreateEventRequested: () => showCreateDialog(),
)
```

### Prevention Tips

- Ensure Day View is in the focus order (e.g. wrap in `Focus` with `autofocus: true` on first load)
- Provide all three callbacks if you want full shortcut support
- On web, use `meta` (Cmd) on Mac and `control` (Ctrl) on Windows/Linux

---

## RTL Layout Issues

### Symptoms

- Time legend on wrong side in RTL locale
- Events or navigator arrows not mirrored
- Drag/resize feels reversed

### Common Causes

1. **Locale not set** — RTL is inferred from `locale` or `Directionality`
2. **Directionality override** — Parent forces LTR
3. **Custom builders assuming LTR** — Hard-coded left/right positioning

### Solutions

**1. Pass RTL locale**

```dart
MaterialApp(
  locale: const Locale('ar'),
  home: MCalDayView(
    controller: controller,
    locale: const Locale('ar'),
  ),
)
```

**2. Wrap in Directionality for testing**

```dart
Directionality(
  textDirection: TextDirection.rtl,
  child: MCalDayView(controller: controller),
)
```

**3. Use logical (start/end) in custom builders**

```dart
// BAD: Assumes LTR
Align(alignment: Alignment.centerLeft, ...)

// GOOD: Respects RTL
Align(alignment: AlignmentDirectional.centerStart, ...)
```

### Prevention Tips

- Test with `Locale('ar')` or `Directionality(textDirection: TextDirection.rtl, ...)`
- Use `AlignmentDirectional` and `EdgeInsetsDirectional` in custom builders
- Check that navigator and time legend flip correctly

---

## Debugging Tips

### 1. Verify controller state

```dart
debugPrint('Display date: ${controller.displayDate}');
debugPrint('Events: ${controller.eventsForDate(controller.displayDate)}');
```

### 2. Check event date alignment

```dart
for (final e in controller.eventsForDate(controller.displayDate)) {
  debugPrint('${e.title}: ${e.start} - ${e.end}, isAllDay: ${e.isAllDay}');
}
```

### 3. Use Flutter DevTools

- **Widget Inspector** — Confirm `MCalDayView` is built and has correct constraints
- **Performance** — Profile scroll and drag for jank
- **Debugger** — Set breakpoints in `onEventDropped`, `onEventResized`, etc.

### 4. Minimal reproduction

Strip down to the smallest example that reproduces the issue:

```dart
final controller = MCalEventController(initialDate: DateTime(2026, 2, 14));
controller.addEvents([
  MCalCalendarEvent(
    id: '1',
    title: 'Test',
    start: DateTime(2026, 2, 14, 10, 0),
    end: DateTime(2026, 2, 14, 11, 0),
  ),
]);

runApp(MaterialApp(
  home: Scaffold(
    body: SizedBox(
      height: 600,
      child: MCalDayView(controller: controller),
    ),
  ),
));
```

### 5. Run tests

```bash
flutter test test/widgets/mcal_day_view_test.dart
flutter test test/widgets/mcal_day_view_events_test.dart
flutter test test/widgets/mcal_day_view_drag_test.dart
flutter test test/widgets/mcal_day_view_resize_test.dart
flutter test test/widgets/mcal_day_view_keyboard_test.dart
```

Tests document expected behavior and can help isolate configuration issues.

---

## Related Documentation

- [Day View Documentation](day_view.md) — Full feature guide and API reference
- [README](../README.md) — Package overview
- [Example app](../example/) — Working Day View implementations
