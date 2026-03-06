import 'package:flutter/material.dart';

import '../mcal_callback_details.dart';

/// CustomPainter for rendering drop target highlights efficiently.
///
/// This is the default highlight renderer used when neither
/// [MCalMonthView.dropTargetOverlayBuilder] nor [MCalMonthView.dropTargetCellBuilder]
/// is provided. It draws colored rounded rectangles for each highlighted cell.
///
/// [shouldRepaint] uses index-based comparison (drop start/end week row and cell
/// indices) instead of list reference or Rect comparison for better performance.
class DropTargetHighlightPainter extends CustomPainter {
  /// The list of cells to highlight.
  final List<MCalHighlightCellInfo> highlightedCells;

  /// Week row index of the first highlighted cell (for [shouldRepaint]).
  final int dropStartWeekRow;

  /// Cell index of the first highlighted cell (for [shouldRepaint]).
  final int dropStartCellIndex;

  /// Week row index of the last highlighted cell (for [shouldRepaint]).
  final int dropEndWeekRow;

  /// Cell index of the last highlighted cell (for [shouldRepaint]).
  final int dropEndCellIndex;

  /// Whether the drop target is valid.
  final bool isValid;

  /// Color for valid drop targets.
  final Color validColor;

  /// Color for invalid drop targets.
  final Color invalidColor;

  /// Border radius for the highlight rectangles.
  final double borderRadius;

  /// Creates a new [DropTargetHighlightPainter].
  DropTargetHighlightPainter({
    required this.highlightedCells,
    required this.dropStartWeekRow,
    required this.dropStartCellIndex,
    required this.dropEndWeekRow,
    required this.dropEndCellIndex,
    required this.isValid,
    this.validColor = const Color(0x4000FF00),
    this.invalidColor = const Color(0x40FF0000),
    this.borderRadius = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (highlightedCells.isEmpty) return;

    final paint = Paint()
      ..color = isValid ? validColor : invalidColor
      ..style = PaintingStyle.fill;

    for (final cell in highlightedCells) {
      final rrect = RRect.fromRectAndRadius(
        cell.bounds,
        Radius.circular(borderRadius),
      );
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(DropTargetHighlightPainter oldDelegate) {
    if (oldDelegate.isValid != isValid) return true;
    if (oldDelegate.validColor != validColor) return true;
    if (oldDelegate.invalidColor != invalidColor) return true;
    if (oldDelegate.borderRadius != borderRadius) return true;
    if (oldDelegate.highlightedCells.length != highlightedCells.length) {
      return true;
    }

    // Index-based comparison: repaint only when drop target cell indices change.
    if (oldDelegate.dropStartWeekRow != dropStartWeekRow ||
        oldDelegate.dropStartCellIndex != dropStartCellIndex ||
        oldDelegate.dropEndWeekRow != dropEndWeekRow ||
        oldDelegate.dropEndCellIndex != dropEndCellIndex) {
      return true;
    }

    return false;
  }
}
