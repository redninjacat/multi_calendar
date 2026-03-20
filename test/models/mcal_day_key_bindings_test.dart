import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  group('MCalDayKeyBindings', () {
    group('default constructor', () {
      test('enterEventMode defaults to Enter and Space', () {
        const bindings = MCalDayKeyBindings();
        final keys = bindings.enterEventMode.map((a) => a.key).toList();
        expect(keys, contains(LogicalKeyboardKey.enter));
        expect(keys, contains(LogicalKeyboardKey.space));
      });

      test('home defaults to Home key', () {
        const bindings = MCalDayKeyBindings();
        expect(
          bindings.home.any((a) => a.key == LogicalKeyboardKey.home),
          isTrue,
        );
      });

      test('end defaults to End key', () {
        const bindings = MCalDayKeyBindings();
        expect(
          bindings.end.any((a) => a.key == LogicalKeyboardKey.end),
          isTrue,
        );
      });

      test('pageUp defaults to PageUp', () {
        const bindings = MCalDayKeyBindings();
        expect(
          bindings.pageUp.any((a) => a.key == LogicalKeyboardKey.pageUp),
          isTrue,
        );
      });

      test('pageDown defaults to PageDown', () {
        const bindings = MCalDayKeyBindings();
        expect(
          bindings.pageDown.any((a) => a.key == LogicalKeyboardKey.pageDown),
          isTrue,
        );
      });

      test('createEvent defaults to N', () {
        const bindings = MCalDayKeyBindings();
        expect(
          bindings.createEvent.any((a) => a.key == LogicalKeyboardKey.keyN),
          isTrue,
        );
      });

      // ── Day View-specific defaults ─────────────────────────────────────────

      test('jumpToAllDay defaults to A (Day View-specific)', () {
        const bindings = MCalDayKeyBindings();
        expect(
          bindings.jumpToAllDay.any((a) => a.key == LogicalKeyboardKey.keyA),
          isTrue,
        );
      });

      test('jumpToTimeGrid defaults to T (Day View-specific)', () {
        const bindings = MCalDayKeyBindings();
        expect(
          bindings.jumpToTimeGrid.any((a) => a.key == LogicalKeyboardKey.keyT),
          isTrue,
        );
      });

      test('jumpToEventMode defaults to E (Day View-specific)', () {
        const bindings = MCalDayKeyBindings();
        expect(
          bindings.jumpToEventMode.any((a) => a.key == LogicalKeyboardKey.keyE),
          isTrue,
        );
      });

      test('convertEventType defaults to X (Day View-specific)', () {
        const bindings = MCalDayKeyBindings();
        expect(
          bindings.convertEventType
              .any((a) => a.key == LogicalKeyboardKey.keyX),
          isTrue,
        );
      });

      // ── Event Mode defaults ────────────────────────────────────────────────

      test('cycleForward defaults to Tab and ArrowDown', () {
        const bindings = MCalDayKeyBindings();
        final keys = bindings.cycleForward.map((a) => a.key).toList();
        expect(keys, contains(LogicalKeyboardKey.tab));
        expect(keys, contains(LogicalKeyboardKey.arrowDown));
      });

      test('cycleBackward defaults to Shift+Tab and ArrowUp', () {
        const bindings = MCalDayKeyBindings();
        final shiftTab = bindings.cycleBackward.where(
          (a) => a.key == LogicalKeyboardKey.tab && a.shift,
        );
        expect(shiftTab, isNotEmpty);
        final arrowUp = bindings.cycleBackward.where(
          (a) => a.key == LogicalKeyboardKey.arrowUp,
        );
        expect(arrowUp, isNotEmpty);
      });

      test('activate defaults to Enter and Space', () {
        const bindings = MCalDayKeyBindings();
        final keys = bindings.activate.map((a) => a.key).toList();
        expect(keys, contains(LogicalKeyboardKey.enter));
        expect(keys, contains(LogicalKeyboardKey.space));
      });

      test('delete defaults to D, Delete, and Backspace', () {
        const bindings = MCalDayKeyBindings();
        final keys = bindings.delete.map((a) => a.key).toList();
        expect(keys, contains(LogicalKeyboardKey.keyD));
        expect(keys, contains(LogicalKeyboardKey.delete));
        expect(keys, contains(LogicalKeyboardKey.backspace));
      });

      test('enterMoveMode defaults to M', () {
        const bindings = MCalDayKeyBindings();
        expect(
          bindings.enterMoveMode.any((a) => a.key == LogicalKeyboardKey.keyM),
          isTrue,
        );
      });

      test('enterResizeMode defaults to R', () {
        const bindings = MCalDayKeyBindings();
        expect(
          bindings.enterResizeMode
              .any((a) => a.key == LogicalKeyboardKey.keyR),
          isTrue,
        );
      });

      test('exitEventMode defaults to Escape', () {
        const bindings = MCalDayKeyBindings();
        expect(
          bindings.exitEventMode.any((a) => a.key == LogicalKeyboardKey.escape),
          isTrue,
        );
      });

      // ── Move Mode defaults ─────────────────────────────────────────────────

      test('confirmMove defaults to Enter and Space', () {
        const bindings = MCalDayKeyBindings();
        final keys = bindings.confirmMove.map((a) => a.key).toList();
        expect(keys, contains(LogicalKeyboardKey.enter));
        expect(keys, contains(LogicalKeyboardKey.space));
      });

      test('cancelMove defaults to Escape', () {
        const bindings = MCalDayKeyBindings();
        expect(
          bindings.cancelMove.any((a) => a.key == LogicalKeyboardKey.escape),
          isTrue,
        );
      });

      test('switchToResize defaults to R', () {
        const bindings = MCalDayKeyBindings();
        expect(
          bindings.switchToResize.any((a) => a.key == LogicalKeyboardKey.keyR),
          isTrue,
        );
      });

      // ── Resize Mode defaults ───────────────────────────────────────────────

      test('switchToStartEdge defaults to S', () {
        const bindings = MCalDayKeyBindings();
        expect(
          bindings.switchToStartEdge
              .any((a) => a.key == LogicalKeyboardKey.keyS),
          isTrue,
        );
      });

      test('switchToEndEdge defaults to E', () {
        const bindings = MCalDayKeyBindings();
        expect(
          bindings.switchToEndEdge
              .any((a) => a.key == LogicalKeyboardKey.keyE),
          isTrue,
        );
      });

      test('confirmResize defaults to Enter and Space', () {
        const bindings = MCalDayKeyBindings();
        final keys = bindings.confirmResize.map((a) => a.key).toList();
        expect(keys, contains(LogicalKeyboardKey.enter));
        expect(keys, contains(LogicalKeyboardKey.space));
      });

      test('switchToMove defaults to M', () {
        const bindings = MCalDayKeyBindings();
        expect(
          bindings.switchToMove.any((a) => a.key == LogicalKeyboardKey.keyM),
          isTrue,
        );
      });

      test('cancelResize defaults to Escape', () {
        const bindings = MCalDayKeyBindings();
        expect(
          bindings.cancelResize.any((a) => a.key == LogicalKeyboardKey.escape),
          isTrue,
        );
      });

      test('createEvent can be disabled via empty list', () {
        const bindings = MCalDayKeyBindings(createEvent: []);
        expect(bindings.createEvent, isEmpty);
      });

      test('jumpToAllDay can be disabled via empty list', () {
        const bindings = MCalDayKeyBindings(jumpToAllDay: []);
        expect(bindings.jumpToAllDay, isEmpty);
      });
    });

    group('const construction', () {
      test('can be constructed as const', () {
        // Verifies const-constructibility at compile time.
        const bindings = MCalDayKeyBindings();
        expect(bindings, isNotNull);
      });

      test('two const instances are identical', () {
        const a = MCalDayKeyBindings();
        const b = MCalDayKeyBindings();
        expect(identical(a, b), isTrue);
      });
    });

    group('copyWith()', () {
      test('overrides createEvent while preserving pageDown', () {
        final custom = const MCalDayKeyBindings().copyWith(
          createEvent: const [MCalKeyActivator(LogicalKeyboardKey.keyC)],
        );
        expect(custom.createEvent.first.key, equals(LogicalKeyboardKey.keyC));
        expect(
          custom.pageDown.any((a) => a.key == LogicalKeyboardKey.pageDown),
          isTrue,
        );
      });

      test('overrides jumpToAllDay while preserving jumpToTimeGrid', () {
        final custom = const MCalDayKeyBindings().copyWith(
          jumpToAllDay: const [MCalKeyActivator(LogicalKeyboardKey.keyQ)],
        );
        expect(
          custom.jumpToAllDay.any((a) => a.key == LogicalKeyboardKey.keyQ),
          isTrue,
        );
        expect(
          custom.jumpToTimeGrid.any((a) => a.key == LogicalKeyboardKey.keyT),
          isTrue,
        );
      });

      test('overrides convertEventType while preserving delete', () {
        final custom = const MCalDayKeyBindings().copyWith(
          convertEventType: const [MCalKeyActivator(LogicalKeyboardKey.keyC)],
        );
        expect(
          custom.convertEventType
              .any((a) => a.key == LogicalKeyboardKey.keyC),
          isTrue,
        );
        expect(
          custom.delete.any((a) => a.key == LogicalKeyboardKey.keyD),
          isTrue,
        );
      });

      test('overrides delete binding while preserving enterEventMode', () {
        final original = const MCalDayKeyBindings();
        final custom = original.copyWith(
          delete: const [MCalKeyActivator(LogicalKeyboardKey.keyX)],
        );
        expect(custom.delete.length, equals(1));
        expect(custom.delete.first.key, equals(LogicalKeyboardKey.keyX));
        expect(
          custom.enterEventMode.any((a) => a.key == LogicalKeyboardKey.enter),
          isTrue,
        );
      });

      test('override with empty list disables action', () {
        final custom = const MCalDayKeyBindings().copyWith(delete: []);
        expect(custom.delete, isEmpty);
      });

      test('copyWith with null parameters preserves all defaults', () {
        final original = const MCalDayKeyBindings();
        final copy = original.copyWith();
        expect(copy.enterEventMode, equals(original.enterEventMode));
        expect(copy.jumpToAllDay, equals(original.jumpToAllDay));
        expect(copy.jumpToTimeGrid, equals(original.jumpToTimeGrid));
        expect(copy.jumpToEventMode, equals(original.jumpToEventMode));
        expect(copy.convertEventType, equals(original.convertEventType));
        expect(copy.confirmMove, equals(original.confirmMove));
        expect(copy.confirmResize, equals(original.confirmResize));
      });
    });

    group('equality', () {
      test('two default instances are equal', () {
        const a = MCalDayKeyBindings();
        const b = MCalDayKeyBindings();
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('instances with different overrides are not equal', () {
        const a = MCalDayKeyBindings();
        const b = MCalDayKeyBindings(createEvent: []);
        expect(a, isNot(equals(b)));
      });

      test('instances with different jumpToAllDay are not equal', () {
        const a = MCalDayKeyBindings();
        const b = MCalDayKeyBindings(jumpToAllDay: []);
        expect(a, isNot(equals(b)));
      });

      test('same instance equals itself', () {
        const a = MCalDayKeyBindings();
        expect(a, equals(a));
      });
    });

    group('toString()', () {
      test('includes class name', () {
        const bindings = MCalDayKeyBindings();
        expect(bindings.toString(), contains('MCalDayKeyBindings'));
      });

      test('includes jumpToAllDay field', () {
        const bindings = MCalDayKeyBindings();
        expect(bindings.toString(), contains('jumpToAllDay'));
      });

      test('includes convertEventType field', () {
        const bindings = MCalDayKeyBindings();
        expect(bindings.toString(), contains('convertEventType'));
      });

      test('includes jumpToEventMode field', () {
        const bindings = MCalDayKeyBindings();
        expect(bindings.toString(), contains('jumpToEventMode'));
      });
    });

    group('Day View-specific properties', () {
      test('jumpToAllDay exists and has correct type', () {
        const bindings = MCalDayKeyBindings();
        expect(bindings.jumpToAllDay, isA<List<MCalKeyActivator>>());
      });

      test('jumpToTimeGrid exists and has correct type', () {
        const bindings = MCalDayKeyBindings();
        expect(bindings.jumpToTimeGrid, isA<List<MCalKeyActivator>>());
      });

      test('convertEventType exists and has correct type', () {
        const bindings = MCalDayKeyBindings();
        expect(bindings.convertEventType, isA<List<MCalKeyActivator>>());
      });

      test('all four Day View-specific navigation properties are non-empty by default',
          () {
        const bindings = MCalDayKeyBindings();
        expect(bindings.jumpToAllDay, isNotEmpty);
        expect(bindings.jumpToTimeGrid, isNotEmpty);
        expect(bindings.jumpToEventMode, isNotEmpty);
        expect(bindings.convertEventType, isNotEmpty);
      });
    });
  });
}
