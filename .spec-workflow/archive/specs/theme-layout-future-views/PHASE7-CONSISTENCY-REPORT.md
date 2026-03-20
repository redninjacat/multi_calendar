# Phase 7 (Task 18) Consistency and Gaps Report

**Date:** 2025-03-18  
**Re-review:** 2025-03-18  
**Spec:** theme-layout-future-views  
**Scope:** 5 new theme properties, widget migrations, spec updates

---

## Executive Summary

The Phase 7 additions (Task 18) are **fully consistent** with the updated spec. All 5 properties are correctly defined, implemented in theme classes, migrated in widgets, covered by tests, and exposed in the example app control panels. **Re-review:** The previously identified gap (example app) has been resolved.

---

## 1. Property Implementation Consistency

### 1.1 MCalTimeGridThemeMixin — 2 new properties ✓

| Property | Spec | Implementation | Default |
|----------|------|-----------------|---------|
| `keyboardFocusBorderRadius` | Req 4.2, design table | `mcal_time_grid_theme_mixin.dart` line 190 | 4.0 ✓ |
| `timedEventTitleTimeGap` | Req 4.2, design table | `mcal_time_grid_theme_mixin.dart` line 144 | 2.0 ✓ |

**Property count:** Design: 50 (37 + 13). Mixin has both new getters. ✓

### 1.2 MCalAllDayThemeMixin — 2 new properties ✓

| Property | Spec | Implementation | Default |
|----------|------|-----------------|---------|
| `allDayOverflowIndicatorBorderWidth` | Req 5.1, design table | `mcal_all_day_theme_mixin.dart` line 108 | 1.0 ✓ |
| `allDaySectionLabelBottomPadding` | Req 5.1, design table | `mcal_all_day_theme_mixin.dart` line 115 | 4.0 ✓ |

**Property count:** Design: 19 (4+4+11). Mixin has both new getters. ✓

### 1.3 MCalThemeData — 1 new property ✓

| Property | Spec | Implementation | Default |
|----------|------|-----------------|---------|
| `cellBorderWidth` | Req 8.1, design table | `mcal_theme.dart` lines 134, 183, 214, 232, 243, 261, 280, 292 | 1.0 ✓ |

**Property count:** Design: 9. Implementation has 9 properties. ✓

### 1.4 MCalDayViewThemeData — 4 new @override fields ✓

All 4 mixin properties are implemented in `mcal_day_view_theme_data.dart`:
- `timedEventTitleTimeGap`, `keyboardFocusBorderRadius` (TimeGrid)
- `allDayOverflowIndicatorBorderWidth`, `allDaySectionLabelBottomPadding` (AllDay)

Present in: constructor, defaults, copyWith, lerp, ==, hashCode. ✓

**Property count:** Design: 93 (18+50+19+6). Implementation matches. ✓

---

## 2. Widget Migration Consistency

### 2.1 all_day_events_section.dart ✓

| Hardcoded value | Replaced with | Implementation |
|-----------------|---------------|-----------------|
| `BorderRadius.circular(4)` (keyboard focus) | `keyboardFocusBorderRadius` | Line 284–285: `theme.dayViewTheme?.keyboardFocusBorderRadius ?? kbDefaults.dayViewTheme!.keyboardFocusBorderRadius!` ✓ |
| `width: 1.0` (cell border) | `cellBorderWidth` | Line 162–163: `theme.cellBorderWidth ?? MCalThemeData.fromTheme(...).cellBorderWidth!` ✓ |
| `width: 1.0` (overflow indicator) | `allDayOverflowIndicatorBorderWidth` | Line 523–524: `theme.dayViewTheme?.allDayOverflowIndicatorBorderWidth ?? defaults.dayViewTheme!.allDayOverflowIndicatorBorderWidth!` ✓ |
| `EdgeInsets.only(bottom: 4.0)` | `allDaySectionLabelBottomPadding` | Line 173–174: `theme.dayViewTheme?.allDaySectionLabelBottomPadding ?? defaults.dayViewTheme!.allDaySectionLabelBottomPadding!` ✓ |

### 2.2 time_grid_events_layer.dart ✓

| Hardcoded value | Replaced with | Implementation |
|-----------------|---------------|-----------------|
| `BorderRadius.circular(4)` (keyboard focus) | `keyboardFocusBorderRadius` | Line 243–244: `theme.dayViewTheme?.keyboardFocusBorderRadius ?? kbDefaults.dayViewTheme!.keyboardFocusBorderRadius!` ✓ |
| `EdgeInsets.only(top: 2.0)` | `timedEventTitleTimeGap` | Line 657–658: `theme.dayViewTheme?.timedEventTitleTimeGap ?? defaults.dayViewTheme!.timedEventTitleTimeGap!` ✓ |

### 2.3 weekday_header_row_widget.dart ✓

| Change | Implementation |
|--------|----------------|
| Implicit `1.0` border width → `cellBorderWidth` | Line 49–50: `theme.monthViewTheme?.cellBorderWidth ?? weekdayHeaderDefaults.monthViewTheme!.cellBorderWidth!` ✓ |

**Note:** `cellBorderWidth` is read from `monthViewTheme` here because the weekday header is part of the Month View grid. `MCalMonthViewThemeData` defines its own `cellBorderWidth` for grid structure. The global `MCalThemeData.cellBorderWidth` is used in `all_day_events_section.dart` for the all-day section container. Both uses are correct.

---

## 3. Test Coverage ✓

`mcal_theme_layout_defaults_test.dart` includes:

| Property | Test |
|----------|------|
| `allDayOverflowIndicatorBorderWidth` | Lines 75–76, 158 |
| `allDaySectionLabelBottomPadding` | Lines 78–79, 159 |
| `timedEventTitleTimeGap` | Lines 101–102, 172 |
| `keyboardFocusBorderRadius` | Lines 128–129, 171 |
| `cellBorderWidth` (MCalThemeData) | Lines 227–228, 276, 309–311, 348–349 |

Defaults, copyWith, and structure tests cover the new properties. ✓

---

## 4. Spec Document Consistency

### 4.1 requirements.md ✓

- Req 4.2: `keyboardFocusBorderRadius`, `timedEventTitleTimeGap` listed in MCalTimeGridThemeMixin ✓
- Req 5.1: `allDayOverflowIndicatorBorderWidth`, `allDaySectionLabelBottomPadding` listed in MCalAllDayThemeMixin ✓
- Req 8.1: `cellBorderWidth` on MCalThemeData ✓
- Req 10.1/10.2: Global section includes `cellBorderWidth`; Time Grid includes `keyboardFocusBorderRadius`, `timedEventTitleTimeGap`; All-Day includes `allDayOverflowIndicatorBorderWidth`, `allDaySectionLabelBottomPadding` ✓

### 4.2 design.md ✓

- Property counts: 50/19/93/9 ✓
- MCalTimeGridThemeMixin table: `timedEventTitleTimeGap`, `keyboardFocusBorderRadius` ✓
- MCalAllDayThemeMixin table: `allDayOverflowIndicatorBorderWidth`, `allDaySectionLabelBottomPadding` ✓
- MCalThemeData table: `cellBorderWidth` ✓
- Widget Migration: `all_day_events_section`, `time_grid_events_layer`, `weekday_header_row_widget` ✓
- Example App sections list the new properties ✓

### 4.3 tasks.md ✓

- Task 18 documents the 5 properties, files, defaults, and updated counts ✓
- Task 1: MCalTimeGridThemeMixin 50 getters, MCalAllDayThemeMixin 19 getters ✓
- Task 2: MCalDayViewThemeData 93 properties ✓
- Task 4: MCalThemeData 9 properties (Task 4 text still says "8 properties" in one place — minor inconsistency) ✓

---

## 5. Gaps

### 5.1 Example app control panels (Req 10) — Resolved ✓

**Requirement 10.1/10.2:** Each theme tab must expose controls for all applicable theme properties.

**Re-review state:** All 5 new properties are now exposed in the example app:

| Property | Tab | Implementation |
|----------|-----|----------------|
| `cellBorderWidth` | day_theme_tab, month_theme_tab | State vars, preset load, _buildThemeData, slider controls ✓ |
| `keyboardFocusBorderRadius` | day_theme_tab | State var, preset load, dayViewTheme, slider ✓ |
| `timedEventTitleTimeGap` | day_theme_tab | State var, preset load, dayViewTheme, slider ✓ |
| `allDayOverflowIndicatorBorderWidth` | day_theme_tab | State var, preset load, dayViewTheme, slider ✓ |
| `allDaySectionLabelBottomPadding` | day_theme_tab | State var, preset load, dayViewTheme, slider ✓ |

---

## 6. Tooling Status

| Check | Result |
|-------|--------|
| `flutter analyze` | ✓ No issues |
| `flutter test` | ✓ 1859 tests pass |

---

## 7. Summary Table

| Area | Status | Notes |
|------|--------|------|
| MCalTimeGridThemeMixin | ✓ | 2 new properties, 50 total |
| MCalAllDayThemeMixin | ✓ | 2 new properties, 19 total |
| MCalThemeData | ✓ | 1 new property, 9 total |
| MCalDayViewThemeData | ✓ | 4 new fields, 93 total |
| all_day_events_section.dart | ✓ | 4 hardcoded values migrated |
| time_grid_events_layer.dart | ✓ | 2 hardcoded values migrated |
| weekday_header_row_widget.dart | ✓ | 1 implicit value migrated |
| Tests | ✓ | 7 new assertions |
| requirements.md | ✓ | Updated |
| design.md | ✓ | Updated |
| tasks.md | ✓ | Task 18 added |
| Example app | ✓ | 5 properties exposed in day_theme_tab and month_theme_tab |

---

## 8. Conclusion

Phase 7 (Task 18) is **fully implemented** and matches the spec. Property definitions, widget migrations, tests, and example app controls are all consistent. All gaps identified in the initial review have been resolved.
