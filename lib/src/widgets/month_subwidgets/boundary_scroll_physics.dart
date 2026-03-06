import 'package:flutter/material.dart';

class MCalBoundaryScrollPhysics extends ScrollPhysics {
  /// The minimum allowed page index (based on minDate).
  final int? minPageIndex;

  /// The maximum allowed page index (based on maxDate).
  final int? maxPageIndex;

  /// The page controller's viewport fraction (typically 1.0).
  final double viewportFraction;

  const MCalBoundaryScrollPhysics({
    super.parent,
    this.minPageIndex,
    this.maxPageIndex,
    this.viewportFraction = 1.0,
  });

  @override
  MCalBoundaryScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return MCalBoundaryScrollPhysics(
      parent: buildParent(ancestor),
      minPageIndex: minPageIndex,
      maxPageIndex: maxPageIndex,
      viewportFraction: viewportFraction,
    );
  }

  /// Calculates the pixel position for a given page index.
  double _pageToPixels(int pageIndex, ScrollMetrics position) {
    return pageIndex * position.viewportDimension * viewportFraction;
  }

  /// Gets the minimum scroll extent based on minPageIndex.
  double? _getMinExtent(ScrollMetrics position) {
    if (minPageIndex == null) return null;
    return _pageToPixels(minPageIndex!, position);
  }

  /// Gets the maximum scroll extent based on maxPageIndex.
  double? _getMaxExtent(ScrollMetrics position) {
    if (maxPageIndex == null) return null;
    return _pageToPixels(maxPageIndex!, position);
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Get the calculated bounds
    final minExtent = _getMinExtent(position);
    final maxExtent = _getMaxExtent(position);

    // Check if we're trying to scroll before the minimum
    if (minExtent != null && value < minExtent) {
      // Return the amount of overscroll to clamp
      return value - minExtent;
    }

    // Check if we're trying to scroll past the maximum
    if (maxExtent != null && value > maxExtent) {
      // Return the amount of overscroll to clamp
      return value - maxExtent;
    }

    // No boundary conditions violated - allow the scroll
    return 0.0;
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // Get the calculated bounds
    final minExtent = _getMinExtent(position);
    final maxExtent = _getMaxExtent(position);

    // Check if we're out of bounds and need to snap back
    if (minExtent != null && position.pixels < minExtent) {
      // Snap back to minimum
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        minExtent,
        velocity,
      );
    }

    if (maxExtent != null && position.pixels > maxExtent) {
      // Snap back to maximum
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        maxExtent,
        velocity,
      );
    }

    // Use default page physics behavior
    return super.createBallisticSimulation(position, velocity);
  }

  /// Spring description for page settling animation.
  ///
  /// Uses a critically-damped spring for smooth settling without oscillation.
  /// Critical damping = 2 * sqrt(stiffness * mass)
  /// For mass=1.0, stiffness=100: critical damping ≈ 20
  /// Using slightly higher (over-damped) for faster settling.
  @override
  SpringDescription get spring =>
      const SpringDescription(mass: 1.0, stiffness: 100.0, damping: 20.0);
}
