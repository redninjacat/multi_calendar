import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/src/widgets/mcal_gesture_detector.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _timeout = Duration(milliseconds: 200);
const _halfTimeout = Duration(milliseconds: 100);
const _afterTimeout = Duration(milliseconds: 210);

/// A stable key used to locate our test target regardless of how many
/// internal SizedBox widgets Flutter adds to the tree.
const _targetKey = Key('_mcal_gesture_detector_test_target');

/// Pumps a [MCalGestureDetector] centred in a [MaterialApp] and returns the
/// centre [Offset] of its child.
Future<Offset> _pumpDetector(
  WidgetTester tester, {
  Duration doubleTapTimeout = _timeout,
  GestureTapDownCallback? onTapDown,
  GestureTapUpCallback? onTapUp,
  GestureTapCallback? onTap,
  GestureTapCancelCallback? onTapCancel,
  GestureTapDownCallback? onDoubleTapDown,
  GestureTapCallback? onDoubleTap,
  GestureTapCancelCallback? onDoubleTapCancel,
  GestureLongPressCallback? onLongPress,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: MCalGestureDetector(
            doubleTapTimeout: doubleTapTimeout,
            onTapDown: onTapDown,
            onTapUp: onTapUp,
            onTap: onTap,
            onTapCancel: onTapCancel,
            onDoubleTapDown: onDoubleTapDown,
            onDoubleTap: onDoubleTap,
            onDoubleTapCancel: onDoubleTapCancel,
            onLongPress: onLongPress,
            // Container with a color is opaque to hit-testing; empty SizedBox
            // is not and would cause events to pass through the GestureDetector.
            child: Container(
              key: _targetKey,
              width: 100,
              height: 100,
              color: const Color(0xFF0000FF),
            ),
          ),
        ),
      ),
    ),
  );
  return tester.getCenter(find.byKey(_targetKey));
}

/// Sends a pointer down followed immediately by a pointer up at [position].
Future<void> _tap(WidgetTester tester, Offset position) async {
  final gesture = await tester.startGesture(position);
  await tester.pump();
  await gesture.up();
  await tester.pump();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('MCalGestureDetector — no double-tap handler', () {
    testWidgets('onTap fires immediately on tap up (zero delay)', (tester) async {
      int tapCount = 0;
      final center = await _pumpDetector(
        tester,
        onTap: () => tapCount++,
        // onDoubleTap intentionally absent
      );

      await _tap(tester, center);

      // No pump needed — onTap should have fired synchronously on tap up.
      expect(tapCount, 1);
    });

    testWidgets('onTap fires on every tap when no double-tap handler', (tester) async {
      int tapCount = 0;
      final center = await _pumpDetector(tester, onTap: () => tapCount++);

      await _tap(tester, center);
      await _tap(tester, center);
      await _tap(tester, center);

      expect(tapCount, 3);
    });

    testWidgets('onTapDown fires immediately (before onTap)', (tester) async {
      final log = <String>[];
      final center = await _pumpDetector(
        tester,
        onTapDown: (_) => log.add('down'),
        onTap: () => log.add('tap'),
      );

      final gesture = await tester.startGesture(center);
      await tester.pump();

      // Down fires before up.
      expect(log, ['down']);

      await gesture.up();
      await tester.pump();

      expect(log, ['down', 'tap']);
    });

    testWidgets('onTapUp fires immediately', (tester) async {
      final log = <String>[];
      final center = await _pumpDetector(
        tester,
        onTapUp: (_) => log.add('up'),
        onTap: () => log.add('tap'),
      );

      await _tap(tester, center);

      expect(log, ['up', 'tap']);
    });
  });

  // -------------------------------------------------------------------------

  group('MCalGestureDetector — single tap with double-tap handler', () {
    testWidgets('onTap fires after timeout when onDoubleTap is registered', (tester) async {
      int tapCount = 0;
      int doubleTapCount = 0;
      final center = await _pumpDetector(
        tester,
        doubleTapTimeout: _timeout,
        onTap: () => tapCount++,
        onDoubleTap: () => doubleTapCount++,
      );

      await _tap(tester, center);

      // Immediately after the tap: timer is pending, onTap has NOT fired yet.
      expect(tapCount, 0);
      expect(doubleTapCount, 0);

      // Advance past the timeout.
      await tester.pump(_afterTimeout);

      expect(tapCount, 1);
      expect(doubleTapCount, 0);
    });

    testWidgets('onTapDown fires immediately even when onDoubleTap is registered', (tester) async {
      final log = <String>[];
      final center = await _pumpDetector(
        tester,
        doubleTapTimeout: _timeout,
        onTapDown: (_) => log.add('down'),
        onTap: () => log.add('tap'),
        onDoubleTap: () => log.add('double'),
      );

      final gesture = await tester.startGesture(center);
      await tester.pump();

      // Down fires immediately.
      expect(log, ['down']);

      await gesture.up();
      await tester.pump();

      // tap is still pending.
      expect(log, ['down']);

      await tester.pump(_afterTimeout);

      expect(log, ['down', 'tap']);
    });

    testWidgets('onTapUp fires immediately even when onDoubleTap is registered', (tester) async {
      final log = <String>[];
      final center = await _pumpDetector(
        tester,
        doubleTapTimeout: _timeout,
        onTapUp: (_) => log.add('up'),
        onTap: () => log.add('tap'),
        onDoubleTap: () => log.add('double'),
      );

      await _tap(tester, center);

      // up fires before the timer.
      expect(log, contains('up'));
      expect(log, isNot(contains('tap')));

      await tester.pump(_afterTimeout);
      expect(log, containsAllInOrder(['up', 'tap']));
    });

    testWidgets('multiple single taps each fire onTap after their own timeout', (tester) async {
      int tapCount = 0;
      final center = await _pumpDetector(
        tester,
        doubleTapTimeout: _timeout,
        onTap: () => tapCount++,
        onDoubleTap: () {},
      );

      // First tap.
      await _tap(tester, center);
      await tester.pump(_afterTimeout);
      expect(tapCount, 1);

      // Second tap (after a long pause — well past timeout).
      await tester.pump(const Duration(seconds: 1));
      await _tap(tester, center);
      await tester.pump(_afterTimeout);
      expect(tapCount, 2);
    });
  });

  // -------------------------------------------------------------------------

  group('MCalGestureDetector — double tap', () {
    testWidgets('fires onDoubleTap, not onTap, on rapid double tap', (tester) async {
      int tapCount = 0;
      int doubleTapCount = 0;
      final center = await _pumpDetector(
        tester,
        doubleTapTimeout: _timeout,
        onTap: () => tapCount++,
        onDoubleTap: () => doubleTapCount++,
      );

      // First tap.
      await _tap(tester, center);
      // Wait less than the timeout before second tap.
      await tester.pump(_halfTimeout);
      // Second tap.
      await _tap(tester, center);
      // Advance well past the timeout.
      await tester.pump(_afterTimeout);

      expect(doubleTapCount, 1);
      expect(tapCount, 0);
    });

    testWidgets('onDoubleTapDown fires on the second tap down', (tester) async {
      final log = <String>[];
      final center = await _pumpDetector(
        tester,
        doubleTapTimeout: _timeout,
        onDoubleTapDown: (_) => log.add('doubleTapDown'),
        onDoubleTap: () => log.add('doubleTap'),
      );

      // First tap (no doubleTapDown yet).
      await _tap(tester, center);
      expect(log, isEmpty);

      // Second tap down — should fire doubleTapDown.
      await tester.pump(_halfTimeout);
      final gesture2 = await tester.startGesture(center);
      await tester.pump();

      expect(log, ['doubleTapDown']);

      // Second tap up — should fire doubleTap.
      await gesture2.up();
      await tester.pump();

      expect(log, ['doubleTapDown', 'doubleTap']);
    });

    testWidgets('second tap after timeout is treated as a new single tap', (tester) async {
      int tapCount = 0;
      int doubleTapCount = 0;
      final center = await _pumpDetector(
        tester,
        doubleTapTimeout: _timeout,
        onTap: () => tapCount++,
        onDoubleTap: () => doubleTapCount++,
      );

      // First tap.
      await _tap(tester, center);
      // Let the first tap's timer fire.
      await tester.pump(_afterTimeout);
      expect(tapCount, 1);

      // Second tap — now outside the window; treated as a fresh single tap.
      await _tap(tester, center);
      await tester.pump(_afterTimeout);
      expect(tapCount, 2);
      expect(doubleTapCount, 0);
    });

    testWidgets('custom timeout shorter than kDoubleTapTimeout works', (tester) async {
      int tapCount = 0;
      int doubleTapCount = 0;
      const shortTimeout = Duration(milliseconds: 100);

      final center = await _pumpDetector(
        tester,
        doubleTapTimeout: shortTimeout,
        onTap: () => tapCount++,
        onDoubleTap: () => doubleTapCount++,
      );

      // Tap within the short window — double tap.
      await _tap(tester, center);
      await tester.pump(const Duration(milliseconds: 50)); // within window
      await _tap(tester, center);
      await tester.pump(const Duration(milliseconds: 150));

      expect(doubleTapCount, 1);
      expect(tapCount, 0);

      // Tap outside the short window — single tap.
      await _tap(tester, center);
      await tester.pump(const Duration(milliseconds: 110)); // past short window
      await _tap(tester, center);
      await tester.pump(const Duration(milliseconds: 150));

      expect(tapCount, 2); // both are single taps
      expect(doubleTapCount, 1); // still just one double tap
    });
  });

  // -------------------------------------------------------------------------

  group('MCalGestureDetector — cancellation', () {
    testWidgets('pending onTap timer is cancelled on tap cancel', (tester) async {
      int tapCount = 0;
      int cancelCount = 0;
      final center = await _pumpDetector(
        tester,
        doubleTapTimeout: _timeout,
        onTap: () => tapCount++,
        onTapCancel: () => cancelCount++,
        onDoubleTap: () {},
      );

      // Start a tap but cancel it (pointer moves far away).
      final gesture = await tester.startGesture(center);
      await tester.pump();
      // Drag far enough to cancel the tap.
      await gesture.moveBy(const Offset(200, 200));
      await tester.pump();
      await gesture.up();
      // Advance past where the timer would have fired.
      await tester.pump(_afterTimeout);

      expect(tapCount, 0);
      expect(cancelCount, 1);
    });

    testWidgets('onDoubleTapCancel fires when second tap is cancelled', (tester) async {
      int doubleTapCount = 0;
      int doubleTapCancelCount = 0;

      final center = await _pumpDetector(
        tester,
        doubleTapTimeout: _timeout,
        onDoubleTap: () => doubleTapCount++,
        onDoubleTapCancel: () => doubleTapCancelCount++,
      );

      // First tap (sets pending timer).
      await _tap(tester, center);

      // Second tap down (enters double-tap mode) then cancel.
      await tester.pump(_halfTimeout);
      final gesture2 = await tester.startGesture(center);
      await tester.pump();
      await gesture2.moveBy(const Offset(200, 200));
      await tester.pump();
      await gesture2.up();
      await tester.pump(_afterTimeout);

      expect(doubleTapCount, 0);
      expect(doubleTapCancelCount, 1);
    });
  });

  // -------------------------------------------------------------------------

  group('MCalGestureDetector — long press', () {
    testWidgets('onLongPress fires correctly (passed through to GestureDetector)', (tester) async {
      int longPressCount = 0;
      final center = await _pumpDetector(
        tester,
        onLongPress: () => longPressCount++,
      );

      // Hold down for longer than the long-press threshold (500ms).
      final gesture = await tester.startGesture(center);
      await tester.pump(const Duration(milliseconds: 600));
      await gesture.up();
      await tester.pump();

      expect(longPressCount, 1);
    });

    testWidgets('long press does not trigger onTap even when both are registered', (tester) async {
      int tapCount = 0;
      int longPressCount = 0;

      final center = await _pumpDetector(
        tester,
        onTap: () => tapCount++,
        onLongPress: () => longPressCount++,
      );

      final gesture = await tester.startGesture(center);
      await tester.pump(const Duration(milliseconds: 600));
      await gesture.up();
      await tester.pump(_afterTimeout);

      expect(longPressCount, 1);
      expect(tapCount, 0);
    });
  });

  // -------------------------------------------------------------------------

  group('MCalGestureDetector — event ordering', () {
    testWidgets('single tap event order: down → up → (timer) → tap', (tester) async {
      final log = <String>[];
      final center = await _pumpDetector(
        tester,
        doubleTapTimeout: _timeout,
        onTapDown: (_) => log.add('down'),
        onTapUp: (_) => log.add('up'),
        onTap: () => log.add('tap'),
        onDoubleTap: () => log.add('double'),
      );

      await _tap(tester, center);
      expect(log, ['down', 'up']); // tap not yet

      await tester.pump(_afterTimeout);
      expect(log, ['down', 'up', 'tap']);
    });

    testWidgets('double tap event order: down1 → up1 → down2 → doubleTapDown → up2 → doubleTap', (tester) async {
      final log = <String>[];
      final center = await _pumpDetector(
        tester,
        doubleTapTimeout: _timeout,
        onTapDown: (_) => log.add('down'),
        onTapUp: (_) => log.add('up'),
        onTap: () => log.add('tap'),
        onDoubleTapDown: (_) => log.add('doubleTapDown'),
        onDoubleTap: () => log.add('doubleTap'),
      );

      // First tap.
      await _tap(tester, center);
      expect(log, ['down', 'up']);

      // Second tap within window.
      await tester.pump(_halfTimeout);
      final gesture2 = await tester.startGesture(center);
      await tester.pump();
      expect(log, ['down', 'up', 'down', 'doubleTapDown']);

      await gesture2.up();
      await tester.pump(_afterTimeout);
      expect(log, ['down', 'up', 'down', 'doubleTapDown', 'up', 'doubleTap']);

      // Crucially, 'tap' must never appear.
      expect(log, isNot(contains('tap')));
    });
  });

  // -------------------------------------------------------------------------

  group('MCalGestureDetector — widget disposal', () {
    testWidgets('pending timer does not fire after widget is disposed', (tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MCalGestureDetector(
                doubleTapTimeout: _timeout,
                onTap: () => tapCount++,
                onDoubleTap: () {},
                child: Container(
              key: _targetKey,
              width: 100,
              height: 100,
              color: const Color(0xFF0000FF),
            ),
              ),
            ),
          ),
        ),
      );

      final center = tester.getCenter(find.byKey(_targetKey));
      await _tap(tester, center);

      // Replace the widget tree before the timer fires.
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // Advance past where the timer would fire.
      await tester.pump(_afterTimeout);

      // onTap must not have been called (mounted guard in timer callback).
      expect(tapCount, 0);
    });
  });
}
