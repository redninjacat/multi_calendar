# Manual Testing Guide — Day View Improvements and Localization

This document describes the manual testing steps to verify Phase 10 and all spec features in the example app.

## Prerequisites

- Run the example app: `cd example && flutter run`
- Use a device or simulator with sufficient screen size for calendar views

---

## 1. Language Switching (All 5 Languages)

### Steps

1. Launch the example app.
2. Open the language/locale selector (typically in app bar or settings).
3. For each language, verify:
   - **English (en)**: All UI text in English; LTR layout.
   - **Spanish (es)**: All UI text in Spanish; LTR layout.
   - **French (fr)**: All UI text in French; LTR layout.
   - **Arabic (ar)**: All UI text in Arabic; **RTL layout** (see Section 3).
   - **Hebrew (he)**: All UI text in Hebrew; **RTL layout** (see Section 3).

### Expected

- Day names, month names, navigation labels, and semantic labels switch correctly.
- No hardcoded English strings remain when a non-English language is selected.

---

## 2. RTL Layout Verification (Arabic and Hebrew)

### Steps

1. Select **Arabic** or **Hebrew** from the language menu.
2. Navigate to **Day View**.
3. Verify:
   - Time legend is on the **right** side (not left).
   - Navigator arrows are reversed (left = next day, right = previous day).
   - Time ticks (if enabled) extend from the correct edge.
4. Navigate to **Month View**.
5. Verify:
   - Weekday headers and date cells flow right-to-left.
   - Week numbers (if shown) are on the correct side.

### Expected

- Layout mirrors correctly for RTL; no overlapping or misaligned elements.

---

## 3. Time Legend Ticks (Day View)

### Steps

1. Go to **Day View** → **Features Demo** tab.
2. In the control panel, locate **Show Time Legend Ticks**.
3. Toggle **ON**: Tick marks should appear at each hour boundary on the time legend.
4. Toggle **OFF**: Tick marks should disappear.
5. Adjust **Tick Color**, **Tick Width**, and **Tick Length** sliders.
6. Verify ticks update visually.

### Expected

- Ticks render at hour boundaries.
- Customization controls affect appearance immediately.
- LTR: ticks extend from the right edge of the time legend.
- RTL: ticks extend from the left edge of the time legend.

---

## 4. Month View Double-Tap Handlers

### Steps

1. Go to **Month View** → **Features Demo** (or a demo that wires double-tap callbacks).
2. **Double-tap an empty date cell**:
   - A snackbar or dialog should appear indicating cell double-tap (e.g., date and position).
3. **Double-tap an event tile**:
   - A snackbar or dialog should appear indicating event double-tap (e.g., event title and position).
4. Verify **single-tap** and **long-press** still work as before (no gesture conflicts).

### Expected

- `onCellDoubleTap` fires for empty cells.
- `onEventDoubleTap` fires for event tiles.
- Single-tap and long-press behavior unchanged.

---

## 5. Nested Theme Structure

### Steps

1. In Day View and Month View style demos, verify themes still apply correctly.
2. Check that custom `MCalDayThemeData` and `MCalMonthThemeData` values are respected.
3. Use the **Features Demo** control panel to change theme properties (colors, fonts, etc.).
4. Verify no visual regressions compared to pre-refactor behavior.

### Expected

- All theme customizations work.
- Nested `dayTheme` and `monthTheme` are used correctly.

---

## 6. Tab Navigation and General UX

### Steps

1. Switch between all Day View tabs: Features, Default, Classic, Modern, Colorful, Minimal, Stress Test, Theme Customization, Accessibility.
2. Switch between all Month View tabs.
3. Verify no crashes, layout issues, or missing content.
4. Test with different screen sizes/orientations if possible.

### Expected

- All tabs load and render correctly.
- Features tab is first in Day View.
- No RTL Demo tab (removed in Phase 5).

---

## Summary Checklist

| Test Area              | Pass |
|------------------------|------|
| English localization   | ☐    |
| Spanish localization   | ☐    |
| French localization    | ☐    |
| Arabic localization    | ☐    |
| Hebrew localization    | ☐    |
| RTL layout (Arabic)    | ☐    |
| RTL layout (Hebrew)    | ☐    |
| Time legend ticks ON   | ☐    |
| Time legend ticks OFF  | ☐    |
| Tick customization     | ☐    |
| Cell double-tap        | ☐    |
| Event double-tap       | ☐    |
| Single-tap / long-press| ☐    |
| Nested themes          | ☐    |
| All tabs functional    | ☐    |
