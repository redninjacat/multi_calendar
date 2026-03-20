# Requirements Document: Focused Cell Theme Alignment

## Introduction

This spec aligns the "focused" theme properties across Day View and Month View so both views follow a consistent, symmetrical naming convention and resolution pattern. Day View already has a complete set of four `focusedSlot*` properties on `MCalTimeGridThemeMixin`. Month View currently has only two `focusedDate*` properties on `MCalMonthViewThemeData` — using inconsistent naming and missing border/decoration control. Additionally, the `WeekRowWidget` overflow indicator focus highlight in `week_row_widget.dart` uses `widget.theme.monthViewTheme?.focusedDateBackgroundColor` with no master defaults fallback, so the highlight is silently skipped when the consumer provides no `monthViewTheme`. (Note: `DayCellWidget._getCellDecoration` and `_buildDateLabel` were already fixed in a prior hotfix to use `defaults.monthViewTheme!.focusedDate*` correctly — this spec only renames those references to the new `focusedCell*` names.)

This spec renames the Month View properties from `focusedDate*` to `focusedCell*`, adds three new properties to match the Day View pattern, fixes the remaining overflow indicator cascade fallback in `week_row_widget.dart`, replaces the existing "Keyboard" example app sections with reorganized "Focused" and "Keyboard Event Border" sections, and adds adaptive keyboard border colors.

## Alignment with Product Vision

- **Customization First** (product.md Principle 4): Consumers can fully theme the focused cell/slot appearance without forking. Both views expose the same structure of properties (background, border color, border width, decoration) so learning one view's API transfers to the other.
- **Comprehensive Styling** (product.md Feature 11): Filling the gap in Month View's focused-cell theming (no border/decoration control) by adding the three missing properties.
- **Consistency**: The `focusedSlot*` / `focusedCell*` naming clearly scopes each property to its view while maintaining structural symmetry.

## Requirements

### Requirement 1: Rename Month View focused properties from `focusedDate*` to `focusedCell*`

**User Story:** As a package consumer, I want the focused theme properties to use consistent `focusedCell*` naming on `MCalMonthViewThemeData`, so that the naming convention is symmetrical with Day View's `focusedSlot*` and clearly conveys that the property styles the entire cell.

#### Acceptance Criteria

1.1. WHEN a consumer references `MCalMonthViewThemeData`, THEN the class SHALL expose `focusedCellBackgroundColor` (type `Color?`) instead of `focusedDateBackgroundColor`.

1.2. WHEN a consumer references `MCalMonthViewThemeData`, THEN the class SHALL expose `focusedCellTextStyle` (type `TextStyle?`) instead of `focusedDateTextStyle`.

1.3. WHEN `MCalMonthViewThemeData.defaults(ThemeData)` is called, THEN `focusedCellBackgroundColor` SHALL default to `colorScheme.primary.withValues(alpha: 0.2)` (same value as the old `focusedDateBackgroundColor` default).

1.4. WHEN `MCalMonthViewThemeData.defaults(ThemeData)` is called, THEN `focusedCellTextStyle` SHALL default to `bodyMedium` with `color: colorScheme.primary` and `fontWeight: FontWeight.w600` (same value as the old `focusedDateTextStyle` default).

1.5. WHEN the old property names `focusedDateBackgroundColor` or `focusedDateTextStyle` are used in code, THEN the build SHALL fail with a compile error — the old names are fully removed, not deprecated.

### Requirement 2: Add three new focused-cell properties to Month View

**User Story:** As a package consumer, I want border and decoration control for the Month View focused cell, so that I have the same level of customization as Day View's focused time slot.

#### Acceptance Criteria

2.1. WHEN a consumer references `MCalMonthViewThemeData`, THEN the class SHALL expose `focusedCellBorderColor` (type `Color?`).

2.2. WHEN a consumer references `MCalMonthViewThemeData`, THEN the class SHALL expose `focusedCellBorderWidth` (type `double?`).

2.3. WHEN a consumer references `MCalMonthViewThemeData`, THEN the class SHALL expose `focusedCellDecoration` (type `BoxDecoration?`).

2.4. WHEN `MCalMonthViewThemeData.defaults(ThemeData)` is called, THEN `focusedCellBorderColor` SHALL default to `colorScheme.primary`.

2.5. WHEN `MCalMonthViewThemeData.defaults(ThemeData)` is called, THEN `focusedCellBorderWidth` SHALL default to `2.0`.

2.6. WHEN `MCalMonthViewThemeData.defaults(ThemeData)` is called, THEN `focusedCellDecoration` SHALL default to `null` (composed from the individual properties at the point of use).

2.7. WHEN `focusedCellDecoration` is non-null, THEN the `DayCellWidget` SHALL use it as the complete cell decoration, ignoring `focusedCellBackgroundColor`, `focusedCellBorderColor`, and `focusedCellBorderWidth`.

2.8. WHEN `focusedCellDecoration` is null and the cell is focused, THEN the `DayCellWidget` SHALL compose a `BoxDecoration` from `focusedCellBackgroundColor`, `focusedCellBorderColor`, and `focusedCellBorderWidth`. The focused border **replaces** the normal grid border (`cellBorderColor` / `cellBorderWidth`) for that cell — they are not stacked.

2.9. All five focused-cell properties SHALL be included in `copyWith`, `lerp`, `==`, and `hashCode` on `MCalMonthViewThemeData`.

### Requirement 3: Fix cascade fallback for all focused properties in Month View widgets

**User Story:** As a package consumer who does not provide an explicit `MCalThemeData` with a `monthViewTheme`, I want the Month View focused cell to still render visibly using Material 3 defaults, so that focus feedback works out of the box.

#### Acceptance Criteria

3.1. `DayCellWidget._getCellDecoration` and `_buildDateLabel` already use the correct cascade pattern (`theme.monthViewTheme?.property ?? defaults.monthViewTheme!.property!`) as of the prior hotfix. This spec SHALL update those references from `focusedDate*` to `focusedCell*` and extend the decoration composition to include the new `focusedCellBorderColor` / `focusedCellBorderWidth` properties.

3.2. WHEN `widget.theme.monthViewTheme` is null, THEN the `WeekRowWidget` overflow indicator focus highlight (~line 443) SHALL fall back to `defaults.monthViewTheme!.focusedCellBackgroundColor!` — not silently skip rendering. Currently it uses only `widget.theme.monthViewTheme?.focusedDateBackgroundColor` with no defaults fallback, so the highlight is lost when the consumer provides no `monthViewTheme`.

3.3. All cascade fallbacks for focused-cell properties SHALL follow the established pattern: `consumer theme property → master defaults property` (`theme.monthViewTheme?.property ?? defaults.monthViewTheme!.property!`).

### Requirement 4: Confirm Day View focused-slot properties are unchanged

**User Story:** As a package consumer using Day View's `focusedSlot*` properties, I want my existing theming code to continue working without changes.

#### Acceptance Criteria

4.1. The four `focusedSlot*` properties on `MCalTimeGridThemeMixin` / `MCalDayViewThemeData` SHALL remain unchanged: `focusedSlotBackgroundColor`, `focusedSlotBorderColor`, `focusedSlotBorderWidth`, `focusedSlotDecoration`.

4.2. The defaults for `focusedSlotBackgroundColor` (`colorScheme.primary.withValues(alpha: 0.08)`), `focusedSlotBorderColor` (`colorScheme.primary`), `focusedSlotBorderWidth` (`3.0`), and `focusedSlotDecoration` (`null`) SHALL remain unchanged.

4.3. The cascade resolution in `mcal_day_view.dart` `_buildFocusedSlotIndicator` and the all-day section focus indicator SHALL continue to use the existing correct pattern.

### Requirement 5: Add "Focused" section to example app Theme tabs

**User Story:** As a developer exploring the example app, I want to see and adjust focused-cell and focused-slot theme properties in the Theme tab control panel, so that I can preview how these properties affect the calendar.

#### Acceptance Criteria

5.1. The **Month Theme Tab** SHALL include a new "Focused" section as the second-to-last section in the control panel (before the "Keyboard Event Border" section added by Requirement 9).

5.2. The Month "Focused" section SHALL expose controls for: `focusedCellBackgroundColor` (color picker), `focusedCellBorderColor` (color picker), `focusedCellBorderWidth` (slider, range 0–6).

5.3. The Month "Focused" section SHALL NOT expose `focusedCellTextStyle` or `focusedCellDecoration` (TextStyle is complex to surface; Decoration is an override).

5.4. The **Day Theme Tab** SHALL include a new "Focused" section as the second-to-last section in the control panel (before the "Keyboard Event Border" section added by Requirement 9).

5.5. The Day "Focused" section SHALL expose controls for: `focusedSlotBackgroundColor` (color picker), `focusedSlotBorderColor` (color picker), `focusedSlotBorderWidth` (slider, range 0–6).

5.6. The Day "Focused" section SHALL NOT expose `focusedSlotDecoration` (BoxDecoration is an override, not suitable for simple controls).

5.7. All control labels in the "Focused" sections SHALL be localized via `AppLocalizations` (example app ARB files for all 5 locales).

5.8. Theme presets (if applicable) SHALL include reasonable values for the new focused-cell properties.

### Requirement 6: Automated testing

**User Story:** As a package maintainer, I want automated tests covering focused-cell and focused-slot theme resolution, so that regressions like the missing-defaults bug are caught.

#### Acceptance Criteria

6.1. Widget tests SHALL verify that when no consumer theme is provided (default `MCalThemeData()`), a focused Month View cell renders with the master default `focusedCellBackgroundColor` (non-null, non-transparent).

6.2. Widget tests SHALL verify that when a consumer provides a custom `focusedCellBackgroundColor`, the focused cell uses the consumer's color.

6.3. Widget tests SHALL verify that `focusedCellDecoration` takes precedence over the individual `focusedCellBackgroundColor` / `focusedCellBorderColor` / `focusedCellBorderWidth` properties.

6.4. Unit tests SHALL verify that `MCalMonthViewThemeData.defaults(ThemeData)` populates `focusedCellBackgroundColor`, `focusedCellBorderColor`, and `focusedCellBorderWidth` with non-null values; `focusedCellTextStyle` with a non-null value when `ThemeData.textTheme.bodyMedium` is non-null (the standard Material `ThemeData()` always provides this); and `focusedCellDecoration` with null.

6.5. Unit tests SHALL verify that `MCalMonthViewThemeData.copyWith` correctly overrides each `focusedCell*` property.

6.6. Unit tests SHALL verify that `MCalMonthViewThemeData.lerp` correctly interpolates `focusedCellBackgroundColor`, `focusedCellBorderColor`, and `focusedCellBorderWidth`, and switches `focusedCellDecoration` at t=0.5.

6.7. Tests SHALL verify that the old property names `focusedDateBackgroundColor` and `focusedDateTextStyle` do not exist on `MCalMonthViewThemeData` (compile-time verified — no test needed, but integration tests that reference the new names provide implicit coverage).

6.8. Tests SHALL verify that Day View `focusedSlot*` properties continue to resolve correctly (existing `focusedSlot*` tests pass without modification). Note: existing tests and example code referencing the old `focusedDate*` names will require mechanical updates to `focusedCell*` as part of the rename — this is expected breakage, not a regression.

6.9. Widget tests SHALL verify that the Day View keyboard border renders as a single border (no double-border gap) around time-grid event tiles and all-day event tiles. (Month View's `week_row_widget.dart` already builds a single merged `BoxDecoration` for keyboard borders — no double-border fix is needed there.)

6.10. Widget tests SHALL verify that when keyboard border color is null (default), the event tile border color is computed adaptively via `resolveContrastColor`.

### Requirement 7: Fix Day View double border on keyboard-highlighted/selected event tiles

**User Story:** As a user navigating events with the keyboard in Day View, I want the highlight/selection border to render as a single clean border around the event tile — not as a double border with a visible gap — so that the focus indicator looks polished.

Note: This issue is specific to **Day View** only. Month View's `week_row_widget.dart` already builds keyboard borders as part of a single merged `BoxDecoration` (no outer wrapping `Container`), so no fix is needed there.

#### Acceptance Criteria

7.1. WHEN a timed event tile in Day View is keyboard-highlighted or keyboard-selected, THEN `time_grid_events_layer.dart` SHALL render a single border by merging the keyboard border into the tile's own `BoxDecoration` — not by wrapping in an outer `Container`.

7.2. WHEN a timed event tile in Day View is keyboard-highlighted or keyboard-selected, THEN there SHALL be no visible gap between the keyboard border and the tile's background color.

7.3. WHEN an all-day event tile in Day View is keyboard-highlighted or keyboard-selected, THEN `all_day_events_section.dart` SHALL apply the same single-border approach (merge into tile decoration, no wrapping `Container`).

7.4. The keyboard border color, width, and radius SHALL continue to be resolved from the `keyboardSelectionBorder*` / `keyboardHighlightBorder*` theme properties on `MCalEventTileThemeMixin`.

### Requirement 8: Restore adaptive keyboard event-tile border colors via null defaults

**User Story:** As a user navigating events with the keyboard, I want the default keyboard highlight and selection borders to adaptively contrast with the event tile color (light border on dark tiles, dark border on light tiles), so that the focus ring is always visible and harmonious — matching the pre-refactor behavior.

#### Acceptance Criteria

8.1. WHEN `MCalDayViewThemeData.defaults(ThemeData)` is called, THEN `keyboardHighlightBorderColor` SHALL default to `null` (not `colorScheme.outline`).

8.2. WHEN `MCalDayViewThemeData.defaults(ThemeData)` is called, THEN `keyboardSelectionBorderColor` SHALL default to `null` (not `colorScheme.primary`).

8.3. WHEN `MCalMonthViewThemeData.defaults(ThemeData)` is called, THEN `keyboardHighlightBorderColor` SHALL default to `null` (not `colorScheme.outline`).

8.4. WHEN `MCalMonthViewThemeData.defaults(ThemeData)` is called, THEN `keyboardSelectionBorderColor` SHALL default to `null` (not `colorScheme.primary`).

8.5. WHEN the resolved `keyboardHighlightBorderColor` is null (neither consumer theme nor master defaults provide a value), THEN the widget SHALL compute the border color adaptively using `resolveContrastColor(backgroundColor: tileColor, lightContrastColor: ..., darkContrastColor: ...)` — the same utility already used throughout the codebase.

8.6. WHEN the resolved `keyboardSelectionBorderColor` is null, THEN the widget SHALL apply the same adaptive `resolveContrastColor` fallback as for highlight.

8.7. WHEN a consumer explicitly sets `keyboardSelectionBorderColor` or `keyboardHighlightBorderColor` to a non-null value, THEN the widget SHALL use that explicit value — the adaptive fallback only applies when null.

8.8. This null-default + adaptive-fallback pattern follows the same precedent as `focusedSlotDecoration` / `focusedCellDecoration`, where `null` means "compose from other values at point of use."

8.9. The adaptive fallback SHALL apply consistently in both Day View (`time_grid_events_layer.dart`, `all_day_events_section.dart`) and Month View (`week_row_widget.dart`).

### Requirement 9: Replace existing "Keyboard" section with "Keyboard Event Border" section in example app Theme tabs

**User Story:** As a developer exploring the example app, I want to see and adjust keyboard highlight and selection border properties in the Theme tab control panel, so that I can preview how these properties affect event tile keyboard focus appearance.

Note: Both Day and Month Theme tabs already have a "Keyboard" section (`sectionKeyboard`) containing the same six keyboard border controls. This requirement **replaces** that existing section with a renamed "Keyboard Event Border" section positioned as the last section (after "Focused"). The controls are the same — only the section title and position change. This avoids duplicating the same six controls in two sections.

#### Acceptance Criteria

9.1. The **Month Theme Tab** SHALL **replace** the existing "Keyboard" section with a "Keyboard Event Border" section positioned after the "Focused" section (making it the very last section). The existing six keyboard border controls SHALL be moved into this section.

9.2. The Month "Keyboard Event Border" section SHALL expose the same six controls currently in the "Keyboard" section: `keyboardHighlightBorderColor` (color picker), `keyboardHighlightBorderWidth` (slider, range 0–6), `keyboardHighlightBorderRadius` (slider, range 0–16), `keyboardSelectionBorderColor` (color picker), `keyboardSelectionBorderWidth` (slider, range 0–6), `keyboardSelectionBorderRadius` (slider, range 0–16).

9.3. The **Day Theme Tab** SHALL **replace** the existing "Keyboard" section with a "Keyboard Event Border" section positioned after the "Focused" section (making it the very last section).

9.4. The Day "Keyboard Event Border" section SHALL expose the same six controls as the Month section.

9.5. The section title label SHALL be localized via `AppLocalizations` as `sectionKeyboardEventBorder` (example app ARB files for all 5 locales). Individual control labels reuse the existing `settingKeyboardSelectionBorder*` and `settingKeyboardHighlightBorder*` ARB keys.

9.6. WHEN a keyboard border color control has a null value (reflecting the adaptive default from Requirement 8), THEN the color picker SHALL show a visually distinct "auto/adaptive" state — e.g., a null/empty indicator — to communicate that the default is computed at runtime rather than being a fixed color.

## Non-Functional Requirements

### Code Architecture and Modularity

- Properties are defined on `MCalMonthViewThemeData` (Month View's own class), not on a mixin, since focused-cell properties are view-specific and not shared across views.
- Day View's `focusedSlot*` properties remain on `MCalTimeGridThemeMixin` as they are time-grid-specific.
- The cascade resolution pattern (`consumer theme → master defaults`) is the project-wide standard established by the theme-cascade-refactor spec.

### Performance

- No performance impact. Property resolution adds no new computation — it's the same null-coalescing pattern used throughout the codebase.

### Backward Compatibility

- This is a **breaking change** for consumers who reference `focusedDateBackgroundColor` or `focusedDateTextStyle` by name. The rename requires a find-and-replace in consuming code. This is acceptable because:
  1. These properties are rarely customized (they have sensible defaults).
  2. The compile error clearly indicates the new name.
  3. The spec explicitly chooses rename over deprecation to avoid maintaining two names indefinitely.

### Naming Distinction

- `focusedCell*` / `focusedSlot*` are **theme properties** that control visual appearance.
- `MCalEventController.focusedDateTime` is a **controller state** property that tracks which date is focused.
- The rename from `focusedDate*` to `focusedCell*` reduces ambiguity: "date" could refer to the date value or the controller state, while "cell" unambiguously refers to the Month View UI element being styled.

### Future Considerations

- Month View multi-day event tiles (`mcal_month_multi_day_tile.dart`) do not currently have keyboard selection/highlight support. If keyboard styling is extended to multi-day bars in the future, the same null-default + `resolveContrastColor` pattern from Requirement 8 should be applied there for consistency.
