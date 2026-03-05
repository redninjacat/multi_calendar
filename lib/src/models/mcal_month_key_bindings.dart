import 'package:flutter/services.dart';

/// A key activator that pairs a [LogicalKeyboardKey] with optional modifier
/// flags, enabling expression of key combinations such as Shift+Tab.
///
/// Each activator uses **strict modifier matching**: if a modifier flag is
/// `false`, the corresponding modifier key must NOT be pressed when the event
/// fires. This ensures that `MCalKeyActivator(LogicalKeyboardKey.tab)` (plain
/// Tab) does not accidentally match Shift+Tab.
///
/// ## Example
///
/// ```dart
/// // Plain Tab
/// const MCalKeyActivator(LogicalKeyboardKey.tab)
///
/// // Shift+Tab
/// const MCalKeyActivator(LogicalKeyboardKey.tab, shift: true)
///
/// // Ctrl+D
/// const MCalKeyActivator(LogicalKeyboardKey.keyD, control: true)
/// ```
class MCalKeyActivator {
  /// Creates a key activator for [key] with optional modifier constraints.
  ///
  /// Modifiers default to `false`, meaning the modifier must NOT be pressed
  /// for this activator to match.
  const MCalKeyActivator(
    this.key, {
    this.shift = false,
    this.control = false,
    this.meta = false,
    this.alt = false,
  });

  /// The logical key that must be pressed.
  final LogicalKeyboardKey key;

  /// Whether the Shift key must be pressed.
  final bool shift;

  /// Whether the Control key must be pressed.
  final bool control;

  /// Whether the Meta (Command on macOS, Windows key on Windows) key must be
  /// pressed.
  final bool meta;

  /// Whether the Alt (Option on macOS) key must be pressed.
  final bool alt;

  /// Returns `true` if this activator matches the given key and modifier state.
  ///
  /// All four modifier states are checked strictly: if [shift] is `false`,
  /// [isShiftPressed] must also be `false` for a match.
  bool matches(
    LogicalKeyboardKey eventKey, {
    required bool isShiftPressed,
    required bool isControlPressed,
    required bool isMetaPressed,
    required bool isAltPressed,
  }) {
    return eventKey == key &&
        isShiftPressed == shift &&
        isControlPressed == control &&
        isMetaPressed == meta &&
        isAltPressed == alt;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MCalKeyActivator &&
        other.key == key &&
        other.shift == shift &&
        other.control == control &&
        other.meta == meta &&
        other.alt == alt;
  }

  @override
  int get hashCode => Object.hash(key, shift, control, meta, alt);

  @override
  String toString() =>
      'MCalKeyActivator(key: $key, shift: $shift, control: $control, '
      'meta: $meta, alt: $alt)';
}

/// Configurable key bindings for [MCalMonthView] keyboard navigation.
///
/// The month view uses a four-mode state machine (Navigation, Event, Move,
/// Resize). This class defines which keys trigger each action within each mode.
///
/// Each property is a [List] of [MCalKeyActivator]s — multiple keys can trigger
/// the same action (e.g., both Tab and ArrowDown cycle forward in Event Mode).
/// An empty list disables the action entirely.
///
/// There are 21 configurable action slots across the four modes.
///
/// ## Default bindings
///
/// The default constructor provides the standard bindings. Use [copyWith] to
/// override specific actions while keeping all other defaults.
///
/// ## Arrow keys
///
/// Arrow keys for directional navigation (cell movement in Navigation Mode,
/// event movement in Move Mode, edge adjustment in Resize Mode) are **not**
/// configurable — they are hardcoded because they are inherent to spatial,
/// directional UI.
///
/// ## Example — disabling keyboard delete
///
/// ```dart
/// MCalMonthView(
///   keyBindings: const MCalMonthKeyBindings(delete: []),
///   // ...
/// )
/// ```
///
/// ## Example — remapping Move Mode entry to X
///
/// ```dart
/// MCalMonthView(
///   keyBindings: const MCalMonthKeyBindings(
///     enterMoveMode: [MCalKeyActivator(LogicalKeyboardKey.keyX)],
///   ),
/// )
/// ```
class MCalMonthKeyBindings {
  /// Creates key bindings with the given activator lists.
  ///
  /// All parameters default to the standard bindings. Pass an empty list `[]`
  /// for any action to disable it.
  const MCalMonthKeyBindings({
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

  /// Keys that enter Event Mode when a focused cell has events.
  ///
  /// Default: Enter, Space.
  final List<MCalKeyActivator> enterEventMode;

  /// Keys that move focus to the first day of the current month.
  ///
  /// Default: Home.
  final List<MCalKeyActivator> home;

  /// Keys that move focus to the last day of the current month.
  ///
  /// Default: End.
  final List<MCalKeyActivator> end;

  /// Keys that navigate to the previous month.
  ///
  /// Default: Page Up.
  final List<MCalKeyActivator> pageUp;

  /// Keys that navigate to the next month.
  ///
  /// Default: Page Down.
  final List<MCalKeyActivator> pageDown;

  /// Keys that invoke [MCalMonthView.onCreateEventRequested] for the focused
  /// date. Only active in Navigation Mode — other modes already capture all
  /// keys.
  ///
  /// Pass an empty list `[]` to disable keyboard-triggered creation.
  ///
  /// Default: N.
  final List<MCalKeyActivator> createEvent;

  // ── Event Mode ────────────────────────────────────────────────────────────

  /// Keys that cycle forward through visible events (and overflow indicator).
  ///
  /// Default: Tab, Arrow Down.
  final List<MCalKeyActivator> cycleForward;

  /// Keys that cycle backward through visible events (and overflow indicator).
  ///
  /// Default: Shift+Tab, Arrow Up.
  final List<MCalKeyActivator> cycleBackward;

  /// Keys that activate the selected event (fires [MCalMonthView.onEventTap])
  /// or the overflow indicator (fires [MCalMonthView.onOverflowTap]) and exits
  /// all keyboard modes.
  ///
  /// Default: Enter, Space.
  final List<MCalKeyActivator> activate;

  /// Keys that request deletion of the selected event via
  /// [MCalMonthView.onDeleteEventRequested]. Pass an empty list `[]` to disable
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

  /// Keys that switch from Move Mode to Resize Mode.
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

  /// Keys that switch from Resize Mode to Move Mode.
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
  MCalMonthKeyBindings copyWith({
    List<MCalKeyActivator>? enterEventMode,
    List<MCalKeyActivator>? home,
    List<MCalKeyActivator>? end,
    List<MCalKeyActivator>? pageUp,
    List<MCalKeyActivator>? pageDown,
    List<MCalKeyActivator>? createEvent,
    List<MCalKeyActivator>? cycleForward,
    List<MCalKeyActivator>? cycleBackward,
    List<MCalKeyActivator>? activate,
    List<MCalKeyActivator>? delete,
    List<MCalKeyActivator>? enterMoveMode,
    List<MCalKeyActivator>? enterResizeMode,
    List<MCalKeyActivator>? exitEventMode,
    List<MCalKeyActivator>? confirmMove,
    List<MCalKeyActivator>? cancelMove,
    List<MCalKeyActivator>? switchToResize,
    List<MCalKeyActivator>? switchToStartEdge,
    List<MCalKeyActivator>? switchToEndEdge,
    List<MCalKeyActivator>? confirmResize,
    List<MCalKeyActivator>? switchToMove,
    List<MCalKeyActivator>? cancelResize,
  }) {
    return MCalMonthKeyBindings(
      enterEventMode: enterEventMode ?? this.enterEventMode,
      home: home ?? this.home,
      end: end ?? this.end,
      pageUp: pageUp ?? this.pageUp,
      pageDown: pageDown ?? this.pageDown,
      createEvent: createEvent ?? this.createEvent,
      cycleForward: cycleForward ?? this.cycleForward,
      cycleBackward: cycleBackward ?? this.cycleBackward,
      activate: activate ?? this.activate,
      delete: delete ?? this.delete,
      enterMoveMode: enterMoveMode ?? this.enterMoveMode,
      enterResizeMode: enterResizeMode ?? this.enterResizeMode,
      exitEventMode: exitEventMode ?? this.exitEventMode,
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
  String toString() => 'MCalMonthKeyBindings(enterEventMode: $enterEventMode, '
      'createEvent: $createEvent, cycleForward: $cycleForward, '
      'cycleBackward: $cycleBackward, activate: $activate, delete: $delete, ...)';
}
