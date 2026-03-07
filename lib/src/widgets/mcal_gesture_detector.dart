import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A drop-in replacement for [GestureDetector] with a configurable double-tap
/// disambiguation window.
///
/// Flutter's built-in [GestureDetector] delays [onTap] by the fixed constant
/// [kDoubleTapTimeout] (300 ms) whenever [onDoubleTap] is also registered,
/// because it must wait to see if a second tap is coming. This widget replaces
/// that mechanism with a user-configurable [doubleTapTimeout], allowing shorter
/// windows (e.g. 200 ms) so single taps feel more responsive while double-tap
/// detection is still supported.
///
/// ## Tap recognition strategy
///
/// * [onTapDown] is forwarded **immediately** — ideal for instant visual
///   feedback (highlight, press state) regardless of whether a double-tap will
///   follow.
/// * [onTapUp] is forwarded **immediately**.
/// * After [onTapUp], a [doubleTapTimeout] timer is started.
///   * If a second [onTapDown] arrives **while the timer is still active**, the
///     pair is recognised as a double-tap: the timer is cancelled,
///     [onDoubleTapDown] is forwarded, and [onDoubleTap] fires on the second
///     [onTapUp].  [onTap] is **not** called.
///   * If the timer fires before a second tap, [onTap] is called.
/// * When [onDoubleTap] is `null`, no timer is used: [onTap] fires immediately
///   on [onTapUp], matching the standard [GestureDetector] zero-delay
///   behaviour.
///
/// All other gesture callbacks — long-press, drag, pan, scale, force-press —
/// are forwarded unchanged to the underlying [GestureDetector].
class MCalGestureDetector extends StatefulWidget {
  // ---------------------------------------------------------------------------
  // Primary tap
  // ---------------------------------------------------------------------------
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final GestureTapCallback? onTap;
  final GestureTapCancelCallback? onTapCancel;

  // ---------------------------------------------------------------------------
  // Secondary tap
  // ---------------------------------------------------------------------------
  final GestureTapCallback? onSecondaryTap;
  final GestureTapDownCallback? onSecondaryTapDown;
  final GestureTapUpCallback? onSecondaryTapUp;
  final GestureTapCancelCallback? onSecondaryTapCancel;

  // ---------------------------------------------------------------------------
  // Tertiary tap
  // ---------------------------------------------------------------------------
  final GestureTapDownCallback? onTertiaryTapDown;
  final GestureTapUpCallback? onTertiaryTapUp;
  final GestureTapCancelCallback? onTertiaryTapCancel;

  // ---------------------------------------------------------------------------
  // Double-tap
  // ---------------------------------------------------------------------------
  final GestureTapDownCallback? onDoubleTapDown;
  final GestureTapCallback? onDoubleTap;
  final GestureTapCancelCallback? onDoubleTapCancel;

  // ---------------------------------------------------------------------------
  // Long-press (primary)
  // ---------------------------------------------------------------------------
  final GestureLongPressDownCallback? onLongPressDown;
  final GestureLongPressCancelCallback? onLongPressCancel;
  final GestureLongPressCallback? onLongPress;
  final GestureLongPressStartCallback? onLongPressStart;
  final GestureLongPressMoveUpdateCallback? onLongPressMoveUpdate;
  final GestureLongPressUpCallback? onLongPressUp;
  final GestureLongPressEndCallback? onLongPressEnd;

  // ---------------------------------------------------------------------------
  // Long-press (secondary)
  // ---------------------------------------------------------------------------
  final GestureLongPressDownCallback? onSecondaryLongPressDown;
  final GestureLongPressCancelCallback? onSecondaryLongPressCancel;
  final GestureLongPressCallback? onSecondaryLongPress;
  final GestureLongPressStartCallback? onSecondaryLongPressStart;
  final GestureLongPressMoveUpdateCallback? onSecondaryLongPressMoveUpdate;
  final GestureLongPressUpCallback? onSecondaryLongPressUp;
  final GestureLongPressEndCallback? onSecondaryLongPressEnd;

  // ---------------------------------------------------------------------------
  // Long-press (tertiary)
  // ---------------------------------------------------------------------------
  final GestureLongPressDownCallback? onTertiaryLongPressDown;
  final GestureLongPressCancelCallback? onTertiaryLongPressCancel;
  final GestureLongPressCallback? onTertiaryLongPress;
  final GestureLongPressStartCallback? onTertiaryLongPressStart;
  final GestureLongPressMoveUpdateCallback? onTertiaryLongPressMoveUpdate;
  final GestureLongPressUpCallback? onTertiaryLongPressUp;
  final GestureLongPressEndCallback? onTertiaryLongPressEnd;

  // ---------------------------------------------------------------------------
  // Vertical drag
  // ---------------------------------------------------------------------------
  final GestureDragDownCallback? onVerticalDragDown;
  final GestureDragStartCallback? onVerticalDragStart;
  final GestureDragUpdateCallback? onVerticalDragUpdate;
  final GestureDragEndCallback? onVerticalDragEnd;
  final GestureDragCancelCallback? onVerticalDragCancel;

  // ---------------------------------------------------------------------------
  // Horizontal drag
  // ---------------------------------------------------------------------------
  final GestureDragDownCallback? onHorizontalDragDown;
  final GestureDragStartCallback? onHorizontalDragStart;
  final GestureDragUpdateCallback? onHorizontalDragUpdate;
  final GestureDragEndCallback? onHorizontalDragEnd;
  final GestureDragCancelCallback? onHorizontalDragCancel;

  // ---------------------------------------------------------------------------
  // Pan
  // ---------------------------------------------------------------------------
  final GestureDragDownCallback? onPanDown;
  final GestureDragStartCallback? onPanStart;
  final GestureDragUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;
  final GestureDragCancelCallback? onPanCancel;

  // ---------------------------------------------------------------------------
  // Scale
  // ---------------------------------------------------------------------------
  final GestureScaleStartCallback? onScaleStart;
  final GestureScaleUpdateCallback? onScaleUpdate;
  final GestureScaleEndCallback? onScaleEnd;

  // ---------------------------------------------------------------------------
  // Force press
  // ---------------------------------------------------------------------------
  final GestureForcePressStartCallback? onForcePressStart;
  final GestureForcePressPeakCallback? onForcePressPeak;
  final GestureForcePressUpdateCallback? onForcePressUpdate;
  final GestureForcePressEndCallback? onForcePressEnd;

  // ---------------------------------------------------------------------------
  // Layout / config
  // ---------------------------------------------------------------------------
  final HitTestBehavior? behavior;
  final bool excludeFromSemantics;
  final DragStartBehavior dragStartBehavior;
  final bool trackpadScrollCausesScale;
  final Offset trackpadScrollToScaleFactor;
  final Set<PointerDeviceKind>? supportedDevices;
  final Widget? child;

  // ---------------------------------------------------------------------------
  // Our addition
  // ---------------------------------------------------------------------------
  /// The maximum interval between two taps for them to be recognised as a
  /// double-tap.
  ///
  /// Defaults to 200 ms, which is shorter than Flutter's built-in
  /// [kDoubleTapTimeout] (300 ms) and provides a better balance between
  /// tap responsiveness and double-tap reliability. Setting this too low
  /// (< ~100 ms) may make double-tap difficult to trigger on some hardware.
  ///
  /// Has no effect when [onDoubleTap] and [onDoubleTapDown] are both `null` —
  /// [onTap] fires immediately in that case.
  final Duration doubleTapTimeout;

  const MCalGestureDetector({
    super.key,
    this.onTapDown,
    this.onTapUp,
    this.onTap,
    this.onTapCancel,
    this.onSecondaryTap,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onSecondaryTapCancel,
    this.onTertiaryTapDown,
    this.onTertiaryTapUp,
    this.onTertiaryTapCancel,
    this.onDoubleTapDown,
    this.onDoubleTap,
    this.onDoubleTapCancel,
    this.onLongPressDown,
    this.onLongPressCancel,
    this.onLongPress,
    this.onLongPressStart,
    this.onLongPressMoveUpdate,
    this.onLongPressUp,
    this.onLongPressEnd,
    this.onSecondaryLongPressDown,
    this.onSecondaryLongPressCancel,
    this.onSecondaryLongPress,
    this.onSecondaryLongPressStart,
    this.onSecondaryLongPressMoveUpdate,
    this.onSecondaryLongPressUp,
    this.onSecondaryLongPressEnd,
    this.onTertiaryLongPressDown,
    this.onTertiaryLongPressCancel,
    this.onTertiaryLongPress,
    this.onTertiaryLongPressStart,
    this.onTertiaryLongPressMoveUpdate,
    this.onTertiaryLongPressUp,
    this.onTertiaryLongPressEnd,
    this.onVerticalDragDown,
    this.onVerticalDragStart,
    this.onVerticalDragUpdate,
    this.onVerticalDragEnd,
    this.onVerticalDragCancel,
    this.onHorizontalDragDown,
    this.onHorizontalDragStart,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
    this.onHorizontalDragCancel,
    this.onPanDown,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onPanCancel,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.onForcePressStart,
    this.onForcePressPeak,
    this.onForcePressUpdate,
    this.onForcePressEnd,
    this.behavior,
    this.excludeFromSemantics = false,
    this.dragStartBehavior = DragStartBehavior.start,
    this.trackpadScrollCausesScale = false,
    this.trackpadScrollToScaleFactor = kDefaultTrackpadScrollToScaleFactor,
    this.supportedDevices,
    this.child,
    this.doubleTapTimeout = const Duration(milliseconds: 200),
  });

  @override
  State<MCalGestureDetector> createState() => _MCalGestureDetectorState();
}

class _MCalGestureDetectorState extends State<MCalGestureDetector> {
  /// Active while we are waiting to see if a second tap arrives.
  /// Its mere existence (non-null) signals "within the double-tap window".
  Timer? _pendingTapTimer;

  /// True after we received the second [onTapDown] of a double-tap pair but
  /// before the second [onTapUp] has arrived.
  bool _awaitingDoubleTapUp = false;

  /// Whether we need to manage tap/double-tap disambiguation ourselves.
  /// False when no double-tap callbacks are registered, which allows [onTap]
  /// to fire immediately with zero delay.
  bool get _intercept =>
      widget.onDoubleTap != null || widget.onDoubleTapDown != null;

  @override
  void dispose() {
    _pendingTapTimer?.cancel();
    super.dispose();
  }

  void _cancelPendingTimer() {
    _pendingTapTimer?.cancel();
    _pendingTapTimer = null;
  }

  void _resetTapState() {
    _cancelPendingTimer();
    _awaitingDoubleTapUp = false;
  }

  // ---------------------------------------------------------------------------
  // Tap handlers — we intercept these; everything else passes through directly.
  // ---------------------------------------------------------------------------

  void _handleTapDown(TapDownDetails details) {
    // Always forward immediately — caller can use this for instant highlights.
    widget.onTapDown?.call(details);

    if (!_intercept) return;

    if (_pendingTapTimer != null) {
      // Timer is active, meaning we are within the double-tap window.
      // Cancel it so it cannot fire onTap before the second onTapUp arrives.
      _cancelPendingTimer();
      _awaitingDoubleTapUp = true;
      widget.onDoubleTapDown?.call(details);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    // Always forward immediately.
    widget.onTapUp?.call(details);

    if (!_intercept) {
      // No double-tap handler: fire onTap immediately, no delay.
      widget.onTap?.call();
      return;
    }

    if (_awaitingDoubleTapUp) {
      // This is the second lift of a confirmed double-tap.
      _resetTapState();
      widget.onDoubleTap?.call();
      return;
    }

    // First lift — start the disambiguation timer.
    // If a second tap arrives before it fires, _handleTapDown will cancel it.
    // If it fires, we know it was a lone single tap.
    _pendingTapTimer = Timer(widget.doubleTapTimeout, () {
      _pendingTapTimer = null;
      if (mounted) widget.onTap?.call();
    });
  }

  void _handleTapCancel() {
    if (_awaitingDoubleTapUp) {
      // The second tap was started but cancelled (e.g. finger moved too far).
      widget.onDoubleTapCancel?.call();
    }
    _resetTapState();
    widget.onTapCancel?.call();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // --- primary tap (managed by us; onTap / onDoubleTap NOT forwarded) ---
      onTapDown: (widget.onTapDown != null || _intercept)
          ? _handleTapDown
          : null,
      onTapUp: (widget.onTapUp != null || widget.onTap != null || _intercept)
          ? _handleTapUp
          : null,
      onTapCancel: (widget.onTapCancel != null || _intercept)
          ? _handleTapCancel
          : null,
      // onTap: intentionally null — we call widget.onTap from our timer/handler
      // onDoubleTap: intentionally null — we detect it ourselves via _pendingTapTimer

      // --- secondary / tertiary tap (pass through untouched) ---
      onSecondaryTap: widget.onSecondaryTap,
      onSecondaryTapDown: widget.onSecondaryTapDown,
      onSecondaryTapUp: widget.onSecondaryTapUp,
      onSecondaryTapCancel: widget.onSecondaryTapCancel,
      onTertiaryTapDown: widget.onTertiaryTapDown,
      onTertiaryTapUp: widget.onTertiaryTapUp,
      onTertiaryTapCancel: widget.onTertiaryTapCancel,

      // --- long press (pass through untouched) ---
      onLongPressDown: widget.onLongPressDown,
      onLongPressCancel: widget.onLongPressCancel,
      onLongPress: widget.onLongPress,
      onLongPressStart: widget.onLongPressStart,
      onLongPressMoveUpdate: widget.onLongPressMoveUpdate,
      onLongPressUp: widget.onLongPressUp,
      onLongPressEnd: widget.onLongPressEnd,
      onSecondaryLongPressDown: widget.onSecondaryLongPressDown,
      onSecondaryLongPressCancel: widget.onSecondaryLongPressCancel,
      onSecondaryLongPress: widget.onSecondaryLongPress,
      onSecondaryLongPressStart: widget.onSecondaryLongPressStart,
      onSecondaryLongPressMoveUpdate: widget.onSecondaryLongPressMoveUpdate,
      onSecondaryLongPressUp: widget.onSecondaryLongPressUp,
      onSecondaryLongPressEnd: widget.onSecondaryLongPressEnd,
      onTertiaryLongPressDown: widget.onTertiaryLongPressDown,
      onTertiaryLongPressCancel: widget.onTertiaryLongPressCancel,
      onTertiaryLongPress: widget.onTertiaryLongPress,
      onTertiaryLongPressStart: widget.onTertiaryLongPressStart,
      onTertiaryLongPressMoveUpdate: widget.onTertiaryLongPressMoveUpdate,
      onTertiaryLongPressUp: widget.onTertiaryLongPressUp,
      onTertiaryLongPressEnd: widget.onTertiaryLongPressEnd,

      // --- drag (pass through untouched) ---
      onVerticalDragDown: widget.onVerticalDragDown,
      onVerticalDragStart: widget.onVerticalDragStart,
      onVerticalDragUpdate: widget.onVerticalDragUpdate,
      onVerticalDragEnd: widget.onVerticalDragEnd,
      onVerticalDragCancel: widget.onVerticalDragCancel,
      onHorizontalDragDown: widget.onHorizontalDragDown,
      onHorizontalDragStart: widget.onHorizontalDragStart,
      onHorizontalDragUpdate: widget.onHorizontalDragUpdate,
      onHorizontalDragEnd: widget.onHorizontalDragEnd,
      onHorizontalDragCancel: widget.onHorizontalDragCancel,

      // --- pan / scale / force (pass through untouched) ---
      onPanDown: widget.onPanDown,
      onPanStart: widget.onPanStart,
      onPanUpdate: widget.onPanUpdate,
      onPanEnd: widget.onPanEnd,
      onPanCancel: widget.onPanCancel,
      onScaleStart: widget.onScaleStart,
      onScaleUpdate: widget.onScaleUpdate,
      onScaleEnd: widget.onScaleEnd,
      onForcePressStart: widget.onForcePressStart,
      onForcePressPeak: widget.onForcePressPeak,
      onForcePressUpdate: widget.onForcePressUpdate,
      onForcePressEnd: widget.onForcePressEnd,

      // --- config ---
      behavior: widget.behavior,
      excludeFromSemantics: widget.excludeFromSemantics,
      dragStartBehavior: widget.dragStartBehavior,
      trackpadScrollCausesScale: widget.trackpadScrollCausesScale,
      trackpadScrollToScaleFactor: widget.trackpadScrollToScaleFactor,
      supportedDevices: widget.supportedDevices,
      child: widget.child,
    );
  }
}
