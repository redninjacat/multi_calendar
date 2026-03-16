# Implementation Review Report: Theme Cascade Refactor

**Date:** 2025-03-14  
**Scope:** Code changes since last commit (theme-cascade-refactor tasks 1–20)  
**Directive:** Consistency, gaps, and bugs vs. requirements, design, and tasks.

---

## 1. Summary

| Category | Status |
|----------|--------|
| **Analyzer** | ✅ No issues |
| **Tests** | ⚠️ 3 failures (golden image tests) |
| **NFR Colors.*** | ⚠️ 1 violation |
| **NFR colorScheme** | ✅ No direct access in widget code |
| **theme_cascade_utils** | ✅ Not exported |
| **Spec alignment** | ⚠️ 2 gaps |

---

## 2. Test Failures

**3 golden image tests fail** in `test/widgets/time_legend_tick_test.dart`:

| Test | Diff |
|------|------|
| golden: LTR time legend with ticks | 1.80%, 8660px |
| golden: RTL time legend with ticks | 1.80%, 8618px |
| golden: time legend with ticks disabled | 2.38%, 11410px |

**Cause:** Theme refactor changed time legend styling (e.g. `timeLegendTickColor` from `colorScheme.outline` to `outlineVariant` via master defaults, `timeLegendTextStyle` from defaults). Visual output changed; goldens were not updated.

**Action:** Run `flutter test test/widgets/time_legend_tick_test.dart --update-goldens` to refresh goldens for the new appearance. AGENTS.md notes golden tests may fail due to font/rendering differences; these diffs are larger and reflect intentional theme changes.

---

## 3. NFR Violations

### 3.1 Hardcoded color in `time_legend_column.dart`

**Location:** `lib/src/widgets/day_subwidgets/time_legend_column.dart`, lines 287–292

```dart
final baseColor = baseStyle?.color ??
    MCalThemeData.fromTheme(Theme.of(context))
        .dayTheme!
        .timeLegendTextStyle
        ?.color ??
    const Color(0xFF9E9E9E);  // ← NFR violation: Colors.grey equivalent
```

**NFR:** "No `Colors.*` literal SHALL appear in widget or tile-building code outside these factories." `Color(0xFF9E9E9E)` is a grey fallback equivalent to `Colors.grey`.

**Fix:** Use master defaults only. If `defaults.dayTheme!.timeLegendTextStyle?.color` is null, use a value from defaults (e.g. ensure the defaults factory always sets a color on `timeLegendTextStyle`, or add a dedicated fallback in the factory).

---

### 3.2 Navigator widgets missing defaults fallback

**Locations:**
- `lib/src/widgets/day_subwidgets/day_navigator.dart` (lines 59, 101)
- `lib/src/widgets/month_subwidgets/month_navigator_widget.dart` (lines 58, 79)

**Current:** Both use `theme.navigatorBackgroundColor` and `theme.navigatorTextStyle` directly. When the consumer theme is `MCalThemeData()` (all nulls), the navigator has no background and no text style.

**Task 10:** "In day_navigator: obtain defaults; replace null fallbacks for navigatorBackgroundColor and navigatorTextStyle with theme.navigatorBackgroundColor ?? defaults.navigatorBackgroundColor and theme.navigatorTextStyle ?? defaults.navigatorTextStyle."

**Task 14:** "month_navigator_widget: navigatorBackgroundColor/TextStyle via shared theme.* ?? defaults.*"

**Gap:** Neither navigator obtains defaults or uses the `theme ?? defaults` pattern. When theme is all-null, they should fall back to master defaults so the navigator is visible.

**Fix:** In each navigator:
1. Add `final defaults = MCalThemeData.fromTheme(Theme.of(context));`
2. Use `theme.navigatorBackgroundColor ?? defaults.navigatorBackgroundColor!` for the container color
3. Use `theme.navigatorTextStyle ?? defaults.navigatorTextStyle!` for the text style

---

## 4. Spec Consistency Check

### 4.1 Theme data classes

- **MCalThemeData:** New properties `eventTileLightContrastColor`, `eventTileDarkContrastColor`, `hoverEventBackgroundColor` added. ✅
- **MCalDayThemeData:** 3 removed, 14 added. `focusedSlotBackgroundColor` populated in defaults. ✅
- **MCalMonthThemeData:** 10 removed, 5 added. `dropTargetCellValidColor`/`InvalidColor` use `colorScheme.tertiary`/`error`. ✅

### 4.2 MCalTheme.of()

- `_fillNullSubThemes` removed. ✅
- Step 3 returns `MCalThemeData()` (or `const MCalThemeData()`). ✅
- Lerp helpers: both null → null, one null → non-null. ✅

### 4.3 Cascade utility

- `theme_cascade_utils.dart` exists with `resolveEventTileColor`, `resolveDropTargetTileColor`, `resolveContrastColor`. ✅
- Not exported from `multi_calendar.dart`. ✅
- Cascade order matches design (ignoreEventColors false: event → allDay → theme → default; true: allDay → theme → event → default). ✅

### 4.4 Widget updates

- Day View: time_grid_events_layer, all_day_events_section, gridlines_layer, time_regions_layer, time_legend_column, current_time_indicator, day_header, disabled_time_slots_layer, time_resize_handle updated. ✅
- day_navigator: ⚠️ Missing defaults fallback (see §3.2).
- Month View: week_row_widget, day_cell_widget, weekday_header_row_widget, week_number_cell, month_overlays, mcal_month_multi_day_tile, month_resize_handle, month_navigator_widget updated. ✅
- month_navigator_widget: ⚠️ Missing defaults fallback (see §3.2).
- DropTargetHighlightPainter: `validColor` and `invalidColor` required. ✅

### 4.5 Property deduplication (Req 11)

- Widgets use `theme.property ?? defaults.property` for deduplicated properties (cellBackgroundColor, weekNumberTextStyle, etc.). ✅
- `timedEventBorderRadius` removed; code uses `theme.eventTileCornerRadius ?? defaults.eventTileCornerRadius!`. ✅
- `weekNumberTextColor` removed; code uses `theme.weekNumberTextStyle ?? defaults.weekNumberTextStyle!`. ✅

### 4.6 Example app

- `cellBackgroundColor`, `hoverEventBackgroundColor` moved to `MCalThemeData`. ✅
- `timedEventBorderRadius` replaced with `eventTileCornerRadius` on `MCalThemeData`. ✅
- `eventTileCornerRadius` removed from `monthTheme` where parent sets it. ✅

---

## 5. Colors.* Audit (lib/src)

| File | Usage | Status |
|------|-------|--------|
| mcal_day_view.dart | dartdoc examples, `Colors.transparent` | ✅ Exempt |
| mcal_month_theme_data.dart | dartdoc, `defaults()` factory | ✅ Allowed |
| mcal_day_theme_data.dart | dartdoc, `defaults()` factory | ✅ Allowed |
| mcal_theme.dart | dartdoc, `fromTheme()` factory | ✅ Allowed |
| week_row_widget.dart | `Colors.transparent` | ✅ Exempt |
| day_cell_widget.dart | `Colors.transparent` | ✅ Exempt |
| mcal_draggable_event_tile.dart | `Colors.transparent` | ✅ Exempt |
| time_legend_column.dart | `Color(0xFF9E9E9E)` | ❌ Violation |

All other `Colors.*` references are in dartdoc examples or callback-detail examples (not executed widget code).

---

## 6. Recommendations

1. **Fix time_legend_column.dart:** Replace `const Color(0xFF9E9E9E)` with a value from master defaults (e.g. `defaults.dayTheme!.timeLegendTextStyle!.color!` if the factory always sets it, or add a fallback in the defaults factory).
2. **Fix day_navigator.dart:** Obtain defaults and use `theme.navigatorBackgroundColor ?? defaults.navigatorBackgroundColor!` and `theme.navigatorTextStyle ?? defaults.navigatorTextStyle!`.
3. **Fix month_navigator_widget.dart:** Same pattern as day_navigator.
4. **Update golden images:** Run `flutter test test/widgets/time_legend_tick_test.dart --update-goldens` to capture the new time legend appearance.

---

## 7. Conclusion

The implementation is largely consistent with the spec. Two gaps need correction:

1. **NFR violation:** Hardcoded `Color(0xFF9E9E9E)` in `time_legend_column.dart`.
2. **Task gap:** Navigator widgets (day and month) do not use the `theme ?? defaults` pattern for `navigatorBackgroundColor` and `navigatorTextStyle`.

The 3 golden test failures are expected after theme changes and should be resolved by updating the goldens.
