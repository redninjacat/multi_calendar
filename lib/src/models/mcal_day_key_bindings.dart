import 'package:flutter/services.dart';

import 'mcal_month_key_bindings.dart';

/// Configurable key bindings for [MCalDayView] keyboard navigation.
///
/// The day view uses a four-mode state machine (Navigation, Event, Move,
/// Resize). This class defines which keys trigger each action within each mode.
///
/// Each property is a [List] of [MCalKeyActivator]s — multiple keys can trigger
/// the same action (e.g., both Tab and ArrowDown cycle forward in Event Mode).
/// An empty list disables the action entirely.
///
/// There are 24 configurable action slots across the four modes — 3 more than
/// [MCalMonthKeyBindings]: [jumpToAllDay], [jumpToTimeGrid] (Navigation Mode),
/// and [convertEventType] (Event Mode).
///
/// ## Default bindings
///
/// The default constructor provides the standard bindings. Use [copyWith] to
/// override specific actions while keeping all other defaults.
///
/// ## Arrow keys
///
/// Arrow keys for directional navigation (slot movement in Navigation Mode,
/// event movement in Move Mode, edge adjustment in Resize Mode) are **not**
/// configurable — they are hardcoded because they are inherent to spatial,
/// directional UI.
///
/// ## Example — disabling keyboard delete
///
/// ```dart
/// MCalDayView(
///   keyBindings: const MCalDayKeyBindings(delete: []),
///   // ...
/// )
/// ```
///
/// ## Example — remapping section jump to a different key
///
/// ```dart
/// MCalDayView(
///   keyBindings: const MCalDayKeyBindings(
///     jumpToAllDay: [MCalKeyActivator(LogicalKeyboardKey.keyQ)],
///   ),
/// )
/// ```
class MCalDayKeyBindings {
  /// Creates key bindings with the given activator lists.
  ///
  /// All parameters default to the standard bindings. Pass an empty list `[]`
  /// for any action to disable it.
  const MCalDayKeyBindings({
    // Navigation Mode
    this.enterEventMode = const [
      MCalKeyActivator(LogicalKeyboardKey.enter),
      MCalKeyActivator(LogicalKeyboardKey.space),
    ],
    this.home = const [MCalKeyActivator(LogicalKeyboardKey.home)],
    this.end = const [MCalKeyActivator(LogicalKeyboardKey.end)],
    this.pageUp = const [MCalKeyActivator(LogicalKeyboardKey.pageUp)],
    this.pageDown = const [MCalKeyActivator(LogicalKeyboardKey.pageDown)],
    this.createEvent = const [MCalKeyActivator(LogicalKeyboardKey.keyN)],
    this.jumpToAllDay = const [MCalKeyActivator(LogicalKeyboardKey.keyA)],
    this.jumpToTimeGrid = const [MCalKeyActivator(LogicalKeyboardKey.keyT)],

    // Event Mode
    this.cycleForward = const [
      MCalKeyActivator(LogicalKeyboardKey.tab),
      MCalKeyActivator(LogicalKeyboardKey.arrowDown),
    ],
    this.cycleBackward = const [
      MCalKeyActivator(LogicalKeyboardKey.tab, shift: true),
      MCalKeyActivator(LogicalKeyboardKey.arrowUp),
    ],
    this.activate = const [
      MCalKeyActivator(LogicalKeyboardKey.enter),
      MCalKeyActivator(LogicalKeyboardKey.space),
    ],
    this.delete = const [
      MCalKeyActivator(LogicalKeyboardKey.keyD),
      MCalKeyActivator(LogicalKeyboardKey.delete),
      MCalKeyActivator(LogicalKeyboardKey.backspace),
    ],
    this.enterMoveMode = const [MCalKeyActivator(LogicalKeyboardKey.keyM)],
    this.enterResizeMode = const [MCalKeyActivator(LogicalKeyboardKey.keyR)],
    this.exitEventMode = const [MCalKeyActivator(LogicalKeyboardKey.escape)],
    this.convertEventType = const [MCalKeyActivator(LogicalKeyboardKey.keyX)],

    // Move Mode
    this.confirmMove = const [
      MCalKeyActivator(LogicalKeyboardKey.enter),
      MCalKeyActivator(LogicalKeyboardKey.space),
    ],
    this.cancelMove = const [MCalKeyActivator(LogicalKeyboardKey.escape)],
    this.switchToResize = const [MCalKeyActivator(LogicalKeyboardKey.keyR)],

    // Resize Mode
    this.switchToStartEdge = const [MCalKeyActivator(LogicalKeyboardKey.keyS)],
    this.switchToEndEdge = const [MCalKeyActivator(LogicalKeyboardKey.keyE)],
    this.confirmResize = const [
      MCalKeyActivator(LogicalKeyboardKey.enter),
      MCalKeyActivator(LogicalKeyboardKey.space),
    ],
    this.switchToMove = const [MCalKeyActivator(LogicalKeyboardKey.keyM)],
    this.cancelResize = const [MCalKeyActivator(LogicalKeyboardKey.escape)],
  });

  // ── Navigation Mode ───────────────────────────────────────────────────────

  /// Keys that enter Event Mode when the current day has events.
  ///
  /// Default: Enter, Space.
  final List<MCalKeyActivator> enterEventMode;

  /// Keys that move focus to the first visible time slot of the day.
  ///
  /// Home never targets the all-day section — use Up arrow or [jumpToAllDay]
  /// to reach it.
  ///
  /// Default: Home.
  final List<MCalKeyActivator> home;

  /// Keys that move focus to the last visible time slot of the day.
  ///
  /// Default: End.
  final List<MCalKeyActivator> end;

  /// Keys that navigate to the previous day.
  ///
  /// Default: Page Up.
  final List<MCalKeyActivator> pageUp;

  /// Keys that navigate to the next day.
  ///
  /// Default: Page Down.
  final List<MCalKeyActivator> pageDown;

  /// Keys that invoke [MCalDayView.onCreateEventRequested] for the focused
  /// time slot. Only active in Navigation Mode.
  ///
  /// Pass an empty list `[]` to disable keyboard-triggered creation.
  ///
  /// Default: N.
  final List<MCalKeyActivator> createEvent;

  /// Keys that jump focus to the all-day section, regardless of the current
  /// focused slot. Day View-specific — has no Month View equivalent.
  ///
  /// Default: A.
  final List<MCalKeyActivator> jumpToAllDay;

  /// Keys that jump focus to the time grid. Restores the last focused time
  /// slot, or jumps to the slot nearest to the current time of day if focus
  /// has never been in the time grid. Day View-specific.
  ///
  /// Default: T.
  final List<MCalKeyActivator> jumpToTimeGrid;

  // ── Event Mode ────────────────────────────────────────────────────────────

  /// Keys that cycle forward through visible events (and overflow indicator).
  ///
  /// Default: Tab, Arrow Down.
  final List<MCalKeyActivator> cycleForward;

  /// Keys that cycle backward through visible events (and overflow indicator).
  ///
  /// Default: Shift+Tab, Arrow Up.
  final List<MCalKeyActivator> cycleBackward;

  /// Keys that activate the selected event (fires [MCalDayView.onEventTap])
  /// or the overflow indicator (fires [MCalDayView.onOverflowTap]) and exits
  /// all keyboard modes.
  ///
  /// Default: Enter, Space.
  final List<MCalKeyActivator> activate;

  /// Keys that request deletion of the selected event via
  /// [MCalDayView.onDeleteEventRequested]. Pass an empty list `[]` to disable
  /// keyboard deletion entirely.
  ///
  /// Default: D, Delete, Backspace.
  final List<MCalKeyActivator> delete;

  /// Keys that enter Move Mode for the selected event.
  ///
  /// Default: M.
  final List<MCalKeyActivator> enterMoveMode;

  /// Keys that enter Resize Mode for the selected event.
  ///
  /// Only active when drag-to-resize is enabled on the view.
  ///
  /// Default: R.
  final List<MCalKeyActivator> enterResizeMode;

  /// Keys that exit Event Mode and return to Navigation Mode.
  ///
  /// Default: Escape.
  final List<MCalKeyActivator> exitEventMode;

  /// Keys that invoke [MCalDayView.onEventTypeConversionRequested] to convert
  /// the selected event between all-day and timed types. Day View-specific.
  ///
  /// The conversion direction is determined automatically from the event's
  /// current [MCalCalendarEvent.isAllDay] state.
  ///
  /// Pass an empty list `[]` to disable keyboard-triggered type conversion.
  ///
  /// Default: X.
  final List<MCalKeyActivator> convertEventType;

  // ── Move Mode ─────────────────────────────────────────────────────────────

  /// Keys that confirm the current move and exit all keyboard modes.
  ///
  /// Default: Enter, Space.
  final List<MCalKeyActivator> confirmMove;

  /// Keys that cancel the current move (reverting to original position) and
  /// return to Event Mode.
  ///
  /// Default: Escape.
  final List<MCalKeyActivator> cancelMove;

  /// Keys that switch from Move Mode to Resize Mode for the same event,
  /// cancelling the current move first.
  ///
  /// Default: R.
  final List<MCalKeyActivator> switchToResize;

  // ── Resize Mode ───────────────────────────────────────────────────────────

  /// Keys that switch the active resize edge to the start edge.
  ///
  /// Default: S.
  final List<MCalKeyActivator> switchToStartEdge;

  /// Keys that switch the active resize edge to the end edge.
  ///
  /// Default: E.
  final List<MCalKeyActivator> switchToEndEdge;

  /// Keys that confirm the current resize and exit all keyboard modes.
  ///
  /// Default: Enter, Space.
  final List<MCalKeyActivator> confirmResize;

  /// Keys that switch from Resize Mode to Move Mode for the same event,
  /// cancelling the current resize first.
  ///
  /// Default: M.
  final List<MCalKeyActivator> switchToMove;

  /// Keys that cancel the current resize (reverting to original size) and
  /// return to Event Mode.
  ///
  /// Default: Escape.
  final List<MCalKeyActivator> cancelResize;

  /// Creates a copy of these bindings with the given properties replaced.
  ///
  /// Properties not provided retain their current values.
  MCalDayKeyBindings copyWith({
    List<MCalKeyActivator>? enterEventMode,
    List<MCalKeyActivator>? home,
    List<MCalKeyActivator>? end,
    List<MCalKeyActivator>? pageUp,
    List<MCalKeyActivator>? pageDown,
    List<MCalKeyActivator>? createEvent,
    List<MCalKeyActivator>? jumpToAllDay,
    List<MCalKeyActivator>? jumpToTimeGrid,
    List<MCalKeyActivator>? cycleForward,
    List<MCalKeyActivator>? cycleBackward,
    List<MCalKeyActivator>? activate,
    List<MCalKeyActivator>? delete,
    List<MCalKeyActivator>? enterMoveMode,
    List<MCalKeyActivator>? enterResizeMode,
    List<MCalKeyActivator>? exitEventMode,
    List<MCalKeyActivator>? convertEventType,
    List<MCalKeyActivator>? confirmMove,
    List<MCalKeyActivator>? cancelMove,
    List<MCalKeyActivator>? switchToResize,
    List<MCalKeyActivator>? switchToStartEdge,
    List<MCalKeyActivator>? switchToEndEdge,
    List<MCalKeyActivator>? confirmResize,
    List<MCalKeyActivator>? switchToMove,
    List<MCalKeyActivator>? cancelResize,
  }) {
    return MCalDayKeyBindings(
      enterEventMode: enterEventMode ?? this.enterEventMode,
      home: home ?? this.home,
      end: end ?? this.end,
      pageUp: pageUp ?? this.pageUp,
      pageDown: pageDown ?? this.pageDown,
      createEvent: createEvent ?? this.createEvent,
      jumpToAllDay: jumpToAllDay ?? this.jumpToAllDay,
      jumpToTimeGrid: jumpToTimeGrid ?? this.jumpToTimeGrid,
      cycleForward: cycleForward ?? this.cycleForward,
      cycleBackward: cycleBackward ?? this.cycleBackward,
      activate: activate ?? this.activate,
      delete: delete ?? this.delete,
      enterMoveMode: enterMoveMode ?? this.enterMoveMode,
      enterResizeMode: enterResizeMode ?? this.enterResizeMode,
      exitEventMode: exitEventMode ?? this.exitEventMode,
      convertEventType: convertEventType ?? this.convertEventType,
      confirmMove: confirmMove ?? this.confirmMove,
      cancelMove: cancelMove ?? this.cancelMove,
      switchToResize: switchToResize ?? this.switchToResize,
      switchToStartEdge: switchToStartEdge ?? this.switchToStartEdge,
      switchToEndEdge: switchToEndEdge ?? this.switchToEndEdge,
      confirmResize: confirmResize ?? this.confirmResize,
      switchToMove: switchToMove ?? this.switchToMove,
      cancelResize: cancelResize ?? this.cancelResize,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MCalDayKeyBindings &&
        other.enterEventMode == enterEventMode &&
        other.home == home &&
        other.end == end &&
        other.pageUp == pageUp &&
        other.pageDown == pageDown &&
        other.createEvent == createEvent &&
        other.jumpToAllDay == jumpToAllDay &&
        other.jumpToTimeGrid == jumpToTimeGrid &&
        other.cycleForward == cycleForward &&
        other.cycleBackward == cycleBackward &&
        other.activate == activate &&
        other.delete == delete &&
        other.enterMoveMode == enterMoveMode &&
        other.enterResizeMode == enterResizeMode &&
        other.exitEventMode == exitEventMode &&
        other.convertEventType == convertEventType &&
        other.confirmMove == confirmMove &&
        other.cancelMove == cancelMove &&
        other.switchToResize == switchToResize &&
        other.switchToStartEdge == switchToStartEdge &&
        other.switchToEndEdge == switchToEndEdge &&
        other.confirmResize == confirmResize &&
        other.switchToMove == switchToMove &&
        other.cancelResize == cancelResize;
  }

  @override
  int get hashCode => Object.hashAll([
        enterEventMode,
        home,
        end,
        pageUp,
        pageDown,
        createEvent,
        jumpToAllDay,
        jumpToTimeGrid,
        cycleForward,
        cycleBackward,
        activate,
        delete,
        enterMoveMode,
        enterResizeMode,
        exitEventMode,
        convertEventType,
        confirmMove,
        cancelMove,
        switchToResize,
        switchToStartEdge,
        switchToEndEdge,
        confirmResize,
        switchToMove,
        cancelResize,
      ]);

  @override
  String toString() => 'MCalDayKeyBindings('
      'enterEventMode: $enterEventMode, '
      'createEvent: $createEvent, '
      'jumpToAllDay: $jumpToAllDay, '
      'jumpToTimeGrid: $jumpToTimeGrid, '
      'cycleForward: $cycleForward, '
      'cycleBackward: $cycleBackward, '
      'activate: $activate, '
      'delete: $delete, '
      'convertEventType: $convertEventType, '
      '...)';
}
