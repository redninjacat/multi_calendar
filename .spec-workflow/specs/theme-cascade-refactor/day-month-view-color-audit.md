# Day View vs Month View — Color Theme Audit

This report audits all color usage in Day View and Month View to ensure the spec covers every scenario and both views resolve colors consistently via theme.

---

## 1. Summary

| View | Widgets with Hardcoded Colors | Spec Coverage | Parity with Other View |
|------|------------------------------|---------------|------------------------|
| **Day View** | 10 widgets | ✅ All covered in design | — |
| **Month View** | 7 widgets | ✅ All covered in design | — |
| **Shared** | 2 widgets | ✅ Covered | — |

**Conclusion:** The spec covers all color scenarios. Implementation will replace hardcoded colors with theme cascade. Day View gains parity with Month View via Req 3, 4, and 9 (drop target tile, overlay, and remaining properties).

---

## 2. Day View — Color Usage by Widget

| Widget | Color Usage | Current Source | Spec Theme Property | Req |
|--------|-------------|----------------|---------------------|-----|
| **time_grid_events_layer** | Timed event tile background | theme → event.color → Colors.blue | `resolveEventTileColor` → eventTileBackgroundColor, event.color, defaults | 2, 7 |
| **time_grid_events_layer** | Tile text contrast | _getContrastColor → Colors.black87/white | eventTileLightContrastColor, eventTileDarkContrastColor | 10 |
| **time_grid_events_layer** | Keyboard focus border | colorScheme.primary | keyboardFocusBorderColor | 9 |
| **time_grid_events_layer** | Corner radius, border, etc. | theme.dayTheme, theme | timedEventBorderRadius, eventTileCornerRadius, defaults | 2.7 |
| **all_day_events_section** | All-day tile background | theme → event.color → Colors.blue | `resolveEventTileColor` (allDayThemeColor) | 2, 7 |
| **all_day_events_section** | Keyboard focus border | colorScheme.primary | keyboardFocusBorderColor | 9 |
| **all_day_events_section** | Cell border, overflow text | theme, Colors.grey, Colors.black87 | cellBorderColor, defaults | 2.7, 9 |
| **gridlines_layer** | Hour/major/minor gridline colors | theme → Colors.grey | hourGridlineColor, majorGridlineColor, minorGridlineColor, defaults | 2.7 |
| **time_legend_column** | Tick color, text style | theme → colorScheme.outline, Colors.grey[600] | timeLegendTickColor, timeLegendTextStyle, defaults | 2.7 |
| **time_regions_layer** | Region fill, border, text | theme, region.color, Colors.grey, Colors.black54 | specialTimeRegionColor, blockedTimeRegionColor, timeRegionBorderColor, timeRegionTextColor, defaults | 2.7 |
| **current_time_indicator** | Indicator color | theme → Colors.red | currentTimeIndicatorColor, defaults | 2.7 |
| **day_header** | Week number, day/date styles | theme → Colors.grey, Colors.black54/87 | weekNumberBackgroundColor, weekNumberTextColor, dayHeaderDayOfWeekStyle, dayHeaderDateStyle, defaults | 2.7 |
| **day_navigator** | Background, text style | theme.navigatorBackgroundColor, theme.navigatorTextStyle | navigatorBackgroundColor, navigatorTextStyle, defaults (when null) | 2.7 |
| **disabled_time_slots_layer** | Disabled slot overlay | Colors.grey | disabledTimeSlotColor | 9 |
| **time_resize_handle** | Handle bar color | Colors.white | resizeHandleColor | 9 |
| **mcal_day_view** | Drop target tile | event.color → theme → Colors.blue/red | dropTargetTile* → resolveEventTileColor | 3 |
| **mcal_day_view** | Drop target overlay | Colors.blue/red | dropTargetOverlayValidColor, dropTargetOverlayInvalidColor, etc. | 4 |
| **mcal_day_view** | Focused slot (Navigation Mode) | colorScheme.primary | focusedSlotBackgroundColor, focusedSlotBorderColor, focusedSlotBorderWidth | 9 |
| **mcal_day_view** | Debug overlays (edge zones, center line) | Color(0x3300CC00), Color(0x44FF0000), Color(0xFFFF0000) | Not in spec — debug-only | — |

**Day View gaps vs spec:** None. All production color paths are covered. Debug overlays use hex literals; spec NFR targets `Colors.*` and production widget code — debug overlays could remain as-is or be excluded.

---

## 3. Month View — Color Usage by Widget

| Widget | Color Usage | Current Source | Spec Theme Property | Req |
|--------|-------------|----------------|---------------------|-----|
| **week_row_widget** | Single-day event tile | theme → event.color → Colors.blue | `resolveEventTileColor` | 2, 7 |
| **week_row_widget** | Keyboard selection border | Colors.black/white | eventTileLightContrastColor, eventTileDarkContrastColor | 9.3 |
| **week_row_widget** | Date label, today circle, overflow | theme, Colors.black87, Colors.grey | cellTextStyle, todayTextStyle, todayBackgroundColor, overflowIndicatorTextStyle, defaults | 2.7, 9 |
| **week_row_widget** | Event tile text | theme.eventTileTextStyle ?? Colors.white | eventTileTextStyle, contrast colors | 10 |
| **mcal_month_multi_day_tile** | Multi-day tile background | event.color → theme → Colors.blue.shade100 | `resolveEventTileColor` (allDayThemeColor), ignoreEventColors | 5, 7 |
| **mcal_month_multi_day_tile** | Multi-day tile text | theme → Colors.black87 | allDayEventTextStyle, eventTileTextStyle, defaults | 2.7 |
| **month_page_widget** | Drop target tile | dropTargetTile* → event → theme → Colors.blue/red | `resolveDropTargetTileColor` | 2.4, 7 |
| **month_page_widget** | Drop target overlay (cell) | dropTargetCell* → Colors.green/red | dropTargetCellValidColor, dropTargetCellInvalidColor, defaults | 2.7 |
| **month_page_widget** | Resize handle (drop target) | Colors.white | resizeHandleColor | 9 |
| **day_cell_widget** | Cell border, background, region | theme, Colors.grey | cellBorderColor, todayBackgroundColor, defaultRegionColor, defaults | 2.7, 9 |
| **weekday_header_row_widget** | Header border | theme → Colors.grey.shade300 | cellBorderColor, defaults | 2.7 |
| **week_number_cell** | Border, text | theme → Colors.grey | cellBorderColor, weekNumberTextStyle, defaults | 2.7 |
| **month_navigator_widget** | Background, text | theme | navigatorBackgroundColor, navigatorTextStyle, defaults | 2.7 |
| **month_overlays** | Loading/error scrim, error icon | Colors.black, colorScheme.error | overlayScrimColor, errorIconColor | 9 |
| **month_resize_handle** | Handle bar | Colors.white | resizeHandleColor | 9 |
| **drop_target_highlight_painter** | Valid/invalid overlay | Color(0x4000FF00), Color(0x40FF0000) | required params from theme | NFR |

**Month View gaps vs spec:** None. All production color paths are covered.

---

## 4. Day View vs Month View — Parity Check

| Scenario | Month View | Day View | Parity |
|----------|------------|----------|--------|
| **Event tile (timed/single-day)** | week_row_widget, resolveEventTileColor | time_grid_events_layer, resolveEventTileColor | ✅ Same cascade |
| **Event tile (all-day)** | all_day in week_row (if any), multi-day | all_day_events_section, resolveEventTileColor | ✅ Same cascade |
| **Event tile (multi-day)** | mcal_month_multi_day_tile | N/A (Day View has no multi-day span) | — |
| **Drop target tile** | month_page_widget, dropTargetTile* | mcal_day_view, dropTargetTile* (Req 3) | ✅ Req 3 adds Day parity |
| **Drop target overlay** | dropTargetCellValidColor, dropTargetCellInvalidColor | dropTargetOverlayValidColor, dropTargetOverlayInvalidColor (Req 4) | ✅ Req 4 adds Day parity |
| **Keyboard focus border** | eventTileLightContrastColor/DarkContrastColor | keyboardFocusBorderColor (Req 9) | ✅ Both themeable (different UX: contrast vs primary) |
| **Resize handle** | month_resize_handle, resizeHandleColor | time_resize_handle, resizeHandleColor | ✅ Both in Req 9 |
| **Navigator** | month_navigator_widget | day_navigator | ✅ Both use theme.navigator* |
| **Cell/header borders** | day_cell_widget, weekday_header_row | all_day_events_section, day_header | ✅ Both use theme, defaults |
| **Week number** | week_number_cell | day_header (week number section) | ✅ Both use theme.weekNumber* |
| **Gridlines** | N/A (Month has no time grid) | gridlines_layer | Day-only, covered by dayTheme |
| **Time legend** | N/A | time_legend_column | Day-only, covered by dayTheme |
| **Time regions** | N/A (Month has day regions) | time_regions_layer | Day-only, covered by dayTheme |
| **Current time indicator** | N/A | current_time_indicator | Day-only, covered by dayTheme |
| **Disabled slots** | N/A | disabled_time_slots_layer | Day-only, covered by Req 9 |
| **Focused slot (Navigation Mode)** | N/A | mcal_day_view | Day-only, covered by Req 9 |
| **Overlay scrim, error icon** | month_overlays | N/A (Month has loading/error overlays) | Month-only, covered by Req 9 |
| **Region default color** | day_cell_widget (day regions) | time_regions_layer (region.color) | Different: Month uses defaultRegionColor; Day uses blocked/special from theme |

---

## 5. Consistency Findings

### 5.1 Cascade Consistency

- **Event tiles:** Both views use `resolveEventTileColor` with the same cascade (Req 2.3, 7).
- **Drop target tiles:** Both use `resolveDropTargetTileColor` with dropTargetTile* → event cascade → defaults (Req 2.4, 3).
- **Drop target overlays:** Month uses dropTargetCell*; Day uses dropTargetOverlay* (Req 4). Both are themeable and achieve parity.

### 5.2 Day View–Specific Properties (No Month Equivalent)

These are correctly in `MCalDayThemeData`:

- Gridlines (hour, major, minor)
- Time legend (tick, text)
- Time regions (special, blocked, border, text)
- Current time indicator
- Disabled time slots
- Focused slot (Navigation Mode)
- Keyboard focus border (Day uses primary; Month uses contrast)

### 5.3 Month View–Specific Properties (No Day Equivalent)

These are correctly in `MCalMonthThemeData`:

- dropTargetCellValidColor, dropTargetCellInvalidColor (cell overlay)
- defaultRegionColor (day regions in cells)
- overlayScrimColor, errorIconColor (LoadingOverlay, ErrorOverlay)
- overflowIndicatorTextStyle

### 5.4 Shared Properties (MCalThemeData Root)

- eventTileBackgroundColor, allDayEventBackgroundColor
- eventTileTextStyle, allDayEventTextStyle
- eventTileCornerRadius, eventTileHorizontalSpacing
- ignoreEventColors
- navigatorBackgroundColor, navigatorTextStyle
- cellBackgroundColor, cellBorderColor
- weekNumberBackgroundColor, weekNumberTextStyle
- eventTileLightContrastColor, eventTileDarkContrastColor

---

## 6. Items Not in Spec

| Item | Location | Notes |
|------|----------|-------|
| Debug edge zone overlays | mcal_day_view (Color 0x3300CC00, 0x44FF0000) | Debug-only; likely excluded from theme |
| Debug tile center line | mcal_day_view (Color 0xFFFF0000) | Debug-only |
| Colors.transparent | mcal_draggable_event_tile, week_row_widget | Semantic "no fill"; typically acceptable |
| Dartdoc examples | mcal_day_view_contexts, mcal_month_view_contexts, mcal_callback_details | Documentation only |

---

## 7. Conclusion

The spec covers all production color usage in Day View and Month View. After implementation:

1. **Day View** will use theme (or master defaults) for all colors, with no hardcoded `Colors.*` or direct `colorScheme` access.
2. **Month View** will use theme (or master defaults) for all colors, with no hardcoded `Colors.*` or direct `colorScheme` access.
3. **Parity** is achieved via Req 3 (Day drop target tile), Req 4 (Day drop target overlay), and Req 9 (remaining hardcoded colors in both views).
4. **Cascade** is consistent: both views use `resolveEventTileColor` / `resolveDropTargetTileColor` with the same rules.

Debug overlays in mcal_day_view use hex literals and are not mentioned in the spec; they can remain as debug-only code or be explicitly excluded from the NFR.
