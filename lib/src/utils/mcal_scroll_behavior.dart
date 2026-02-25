import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A [ScrollBehavior] that enables drag-to-scroll for touch, mouse, and
/// trackpad pointer devices.
///
/// By default Flutter's [ScrollBehavior] only includes [PointerDeviceKind.touch]
/// in [dragDevices], which means [PageView] swipe navigation does not respond
/// to mouse drag or trackpad swipe gestures on desktop. This behavior adds
/// mouse and trackpad support so swipe navigation works on touch-screen laptops,
/// trackpads, and when using a mouse.
class MCalMultiDeviceScrollBehavior extends MaterialScrollBehavior {
  const MCalMultiDeviceScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

/// Custom [PageScrollPhysics] with snappy, non-bouncy settling and a lower
/// drag-distance threshold for page changes.
///
/// Used by both [MCalMonthView] and [MCalDayView] PageViews to provide
/// consistent swipe-navigation feel across all calendar views:
///
/// - A critically-damped spring eliminates post-snap oscillation.
/// - Only 30 % of the page width needs to be dragged to commit a page change
///   (vs the default 50 %).
/// - A lower [minFlingVelocity] (50 px/s vs the default ~365 px/s) means a
///   quick flick always triggers a page change.
class MCalSnappyPageScrollPhysics extends PageScrollPhysics {
  /// The fraction of the page width that must be dragged to trigger a page
  /// change when the user releases without enough fling velocity.
  static const double pageChangeThreshold = 0.3;

  const MCalSnappyPageScrollPhysics({super.parent});

  @override
  MCalSnappyPageScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      MCalSnappyPageScrollPhysics(parent: buildParent(ancestor));

  /// Critically-damped spring: smooth arrival with no oscillation.
  @override
  SpringDescription get spring =>
      const SpringDescription(mass: 1.0, stiffness: 100.0, damping: 20.0);

  /// Lower fling threshold so a quick swipe always flips the page.
  @override
  double get minFlingVelocity => 50.0;

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if (position.viewportDimension == 0) {
      return super.createBallisticSimulation(position, velocity);
    }

    final double pageSize = position.viewportDimension;
    final double currentPage = position.pixels / pageSize;
    final int currentPageFloor = currentPage.floor();
    final double pageFraction = currentPage - currentPageFloor;

    final int targetPage;
    if (velocity.abs() > minFlingVelocity) {
      targetPage = velocity > 0 ? currentPageFloor + 1 : currentPageFloor;
    } else if (pageFraction > (1.0 - pageChangeThreshold)) {
      targetPage = currentPageFloor + 1;
    } else if (pageFraction < pageChangeThreshold) {
      targetPage = currentPageFloor;
    } else {
      targetPage = currentPage.round();
    }

    final double targetPixels = targetPage * pageSize;
    final toleranceValue = toleranceFor(position);
    if ((position.pixels - targetPixels).abs() < toleranceValue.distance) {
      return null;
    }

    return ScrollSpringSimulation(
      spring,
      position.pixels,
      targetPixels,
      velocity,
      tolerance: toleranceValue,
    );
  }
}
