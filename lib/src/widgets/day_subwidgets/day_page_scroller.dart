import 'package:flutter/material.dart';

/// A [ScrollController] whose initial offset can be updated between attach
/// cycles.  When the controller detaches from one [Scrollable] and is later
/// attached to another (e.g. after a page change in a [PageView]),
/// [createScrollPosition] uses [_nextInitialOffset] instead of the value
/// that was passed to the constructor.
class ResettableScrollController extends ScrollController {
  double _nextInitialOffset;

  ResettableScrollController({super.initialScrollOffset = 0.0})
      : _nextInitialOffset = initialScrollOffset;

  set nextInitialOffset(double value) => _nextInitialOffset = value;

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return ScrollPositionWithSingleContext(
      physics: physics,
      context: context,
      initialPixels: _nextInitialOffset,
      keepScrollOffset: false,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

/// Wraps a [SingleChildScrollView] so that every page in the [PageView] can
/// have the correct initial scroll offset without sharing a single controller.
///
/// * The **current** page receives [primaryController] (the one the rest of
///   the Day View code reads/writes for drag handling, scrollToTime, etc.).
/// * **Adjacent** pages ([primaryController] is null) get their own
///   [ScrollController] initialised to [initialOffset], so they appear at the
///   same vertical position as the current page during a swipe.
///
/// When a page transitions between current ↔ adjacent, the existing
/// [ScrollPosition] is simply re-attached to the new controller — the pixel
/// offset is preserved.
class DayPageScroller extends StatefulWidget {
  const DayPageScroller({
    super.key,
    required this.primaryController,
    required this.initialOffset,
    required this.physics,
    required this.child,
  });

  final ScrollController? primaryController;
  final double initialOffset;
  final ScrollPhysics? physics;
  final Widget child;

  @override
  State<DayPageScroller> createState() => DayPageScrollerState();
}

class DayPageScrollerState extends State<DayPageScroller> {
  ScrollController? _ownController;

  @override
  void initState() {
    super.initState();
    if (widget.primaryController == null) {
      _ownController = ScrollController(
        initialScrollOffset: widget.initialOffset,
      );
    }
  }

  @override
  void didUpdateWidget(DayPageScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.primaryController != widget.primaryController) {
      if (oldWidget.primaryController != null &&
          widget.primaryController == null) {
        _ownController = ScrollController(
          initialScrollOffset: widget.initialOffset,
        );
      } else if (oldWidget.primaryController == null &&
          widget.primaryController != null) {
        final old = _ownController;
        _ownController = null;
        if (old != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
        }
      }
    }
  }

  @override
  void dispose() {
    _ownController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.primaryController ?? _ownController!,
      physics: widget.physics,
      child: widget.child,
    );
  }
}
