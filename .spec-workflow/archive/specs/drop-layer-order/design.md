# Design Document: Drop Layer Order

## Overview

This feature adds a single boolean property (`dropTargetTilesAboveOverlay`) to `MCalMonthView` that controls the rendering order of the two drag-feedback layers in the month view's `Stack`. It also renames all internal identifiers that embed hard-coded layer numbers ("Layer3"/"Layer4") to descriptive, number-free names. The change is entirely within `mcal_month_view.dart` — no other source files are affected.

## Steering Document Alignment

### Technical Standards (tech.md)
- **Widget-based Architecture / Builder Pattern**: The new property follows the established pattern of boolean toggles on `MCalMonthView` (e.g., `showDropTargetTiles`, `showDropTargetOverlay`). It is a simple declarative configuration that the widget tree passes down to `_MonthPageWidget`.
- **Performance Conscious**: No additional widgets, layout passes, or rendering work — only the insertion order of two existing `Positioned.fill` children changes.

### Project Structure (structure.md)
- All changes are scoped to `lib/src/widgets/mcal_month_view.dart` (the private methods) and the public constructor of `MCalMonthView`. No new files are created.
- Test additions go into the existing `test/` directory alongside existing month view tests.

## Code Reuse Analysis

### Existing Components to Leverage
- **`MCalMonthView` constructor**: Already has `showDropTargetTiles` and `showDropTargetOverlay` boolean properties; the new `dropTargetTilesAboveOverlay` follows the identical pattern.
- **`_MonthPageWidget`**: Already receives both booleans and builds the `Stack` with conditionally-included layers. The Stack children list is the single place where order is determined.

### Integration Points
- **`MCalMonthView` → `_MonthPageWidget` parameter passing**: The property flows through `_buildPageView` → `_MonthPageWidget(...)` constructor, just like the existing drop-target booleans (see lines ~1178-1179, ~2059-2060 of `mcal_month_view.dart`).

## Architecture

The change is minimal and localized. The conceptual model:

```
MCalMonthView
  └── dropTargetTilesAboveOverlay: bool (default false)
        ↓ passed to
      _MonthPageWidget
        ↓ used in build()
      Stack children order:
        [0] weekRowsColumn (always first — base content)
        [1] tilesLayer or overlayLayer  ← order controlled by the bool
        [2] overlayLayer or tilesLayer
```

### Current Stack Order (default, `dropTargetTilesAboveOverlay: false`)
```
Stack:
  [0] weekRowsColumn          // Base grid + events
  [1] dropTargetTilesLayer    // Preview tiles (formerly "Layer 3")
  [2] dropTargetOverlayLayer  // Highlight overlay (formerly "Layer 4")
```

### Reversed Stack Order (`dropTargetTilesAboveOverlay: true`)
```
Stack:
  [0] weekRowsColumn          // Base grid + events
  [1] dropTargetOverlayLayer  // Highlight overlay rendered first (below)
  [2] dropTargetTilesLayer    // Preview tiles rendered second (above)
```

## Components and Interfaces

### MCalMonthView (public widget — modified)

- **Change**: Add `dropTargetTilesAboveOverlay` parameter to constructor.
- **Interface**:
  ```dart
  /// When true, the drop target tiles layer renders above the drop target
  /// overlay layer during drag-and-drop. When false (default), tiles render
  /// below the overlay.
  ///
  /// By default, drop target tiles are Layer 3 and the overlay is Layer 4.
  /// Setting this to true reverses their order.
  final bool dropTargetTilesAboveOverlay;
  ```
- **Default**: `false`
- **Dependencies**: None new; flows to `_MonthPageWidget`.

### _MonthPageWidget (private widget — modified)

- **Change 1**: Accept `dropTargetTilesAboveOverlay` parameter.
- **Change 2**: In the `build()` method's Stack, use the boolean to determine which layer widget is inserted first.
- **Implementation approach**:
  ```dart
  // Build both layer widgets (only if active)
  final tilesLayer = (widget.showDropTargetTiles && _isDragActive)
      ? Positioned.fill(
          child: RepaintBoundary(
            child: IgnorePointer(
              child: _buildDropTargetTilesLayer(context),
            ),
          ),
        )
      : null;

  final overlayLayer = (widget.showDropTargetOverlay && _isDragActive)
      ? Positioned.fill(
          child: RepaintBoundary(
            child: IgnorePointer(
              child: _buildDropTargetOverlayLayer(context),
            ),
          ),
        )
      : null;

  // Insert in order based on the toggle
  final first = widget.dropTargetTilesAboveOverlay ? overlayLayer : tilesLayer;
  final second = widget.dropTargetTilesAboveOverlay ? tilesLayer : overlayLayer;

  return Stack(
    children: [
      weekRowsColumn,
      if (first != null) first,
      if (second != null) second,
    ],
  );
  ```

### Identifier Renames (private methods — renamed)

| Current Name | New Name | Rationale |
|---|---|---|
| `_buildLayer3DropTargetTiles` | `_buildDropTargetTilesLayer` | Removes "Layer3"; "Layer" suffix indicates it builds a full stack layer |
| `_buildLayer4HighlightOverlay` | `_buildDropTargetOverlayLayer` | Removes "Layer4"; consistent naming with tiles layer |
| `_buildDropTargetTileBuilderForLayer3` | `_buildDropTargetTileEventBuilder` | Removes "ForLayer3"; "EventBuilder" clarifies it returns a `MCalEventTileBuilder` |
| `_buildLayer3DateLabelPlaceholder` (top-level) | `_buildDropTargetDateLabelPlaceholder` | Removes "Layer3"; top-level helper, same file |

All call sites within `mcal_month_view.dart` are updated to use the new names. No public API is affected.

## Data Models

No new data models. The only addition is a `bool` field on two existing widget classes.

## Error Handling

### Error Scenarios
1. **Invalid combination**: `dropTargetTilesAboveOverlay: true` with both `showDropTargetTiles` and `showDropTargetOverlay` set to `false`.
   - **Handling**: No error — the property is silently ignored because neither layer is built.
   - **User Impact**: None.

2. **Only one layer visible**: e.g. `showDropTargetTiles: true`, `showDropTargetOverlay: false`.
   - **Handling**: Only the visible layer is added to the Stack. `dropTargetTilesAboveOverlay` has no observable effect since there is only one layer.
   - **User Impact**: None.

## Testing Strategy

### Unit Testing
- **Default order preserved**: Verify that with `dropTargetTilesAboveOverlay: false` (or unset), the Stack children order matches current behavior (tiles before overlay).
- **Reversed order**: Verify that with `dropTargetTilesAboveOverlay: true`, the overlay widget appears before the tiles widget in the Stack children list.
- **Single layer visible**: Verify correct behavior when only one of the two layers is shown.

### Existing Tests
- All 121 existing month view tests must continue to pass unchanged, since the default value preserves current behavior.
- Renamed methods are private, so no test file references to update (tests interact via the public widget API).
