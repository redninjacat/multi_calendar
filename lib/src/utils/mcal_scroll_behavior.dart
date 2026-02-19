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
