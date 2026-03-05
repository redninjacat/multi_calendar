import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/multi_calendar.dart';

void main() {
  group('MCalKeyActivator', () {
    group('matches()', () {
      test('matches exact key with no modifiers required', () {
        const activator = MCalKeyActivator(LogicalKeyboardKey.enter);
        expect(
          activator.matches(
            LogicalKeyboardKey.enter,
            isShiftPressed: false,
            isControlPressed: false,
            isMetaPressed: false,
            isAltPressed: false,
          ),
          isTrue,
        );
      });

      test('does not match different key', () {
        const activator = MCalKeyActivator(LogicalKeyboardKey.enter);
        expect(
          activator.matches(
            LogicalKeyboardKey.space,
            isShiftPressed: false,
            isControlPressed: false,
            isMetaPressed: false,
            isAltPressed: false,
          ),
          isFalse,
        );
      });

      test('matches key with shift required when shift is pressed', () {
        const activator = MCalKeyActivator(LogicalKeyboardKey.tab, shift: true);
        expect(
          activator.matches(
            LogicalKeyboardKey.tab,
            isShiftPressed: true,
            isControlPressed: false,
            isMetaPressed: false,
            isAltPressed: false,
          ),
          isTrue,
        );
      });

      test('does not match Shift+Tab activator when shift is NOT pressed', () {
        const activator = MCalKeyActivator(LogicalKeyboardKey.tab, shift: true);
        expect(
          activator.matches(
            LogicalKeyboardKey.tab,
            isShiftPressed: false,
            isControlPressed: false,
            isMetaPressed: false,
            isAltPressed: false,
          ),
          isFalse,
        );
      });

      test('plain Tab activator does not match when shift IS pressed', () {
        const activator = MCalKeyActivator(LogicalKeyboardKey.tab);
        expect(
          activator.matches(
            LogicalKeyboardKey.tab,
            isShiftPressed: true,
            isControlPressed: false,
            isMetaPressed: false,
            isAltPressed: false,
          ),
          isFalse,
        );
      });

      test('matches key with control required', () {
        const activator = MCalKeyActivator(
          LogicalKeyboardKey.keyD,
          control: true,
        );
        expect(
          activator.matches(
            LogicalKeyboardKey.keyD,
            isShiftPressed: false,
            isControlPressed: true,
            isMetaPressed: false,
            isAltPressed: false,
          ),
          isTrue,
        );
      });

      test('does not match when unexpected modifier is pressed', () {
        const activator = MCalKeyActivator(LogicalKeyboardKey.keyD);
        expect(
          activator.matches(
            LogicalKeyboardKey.keyD,
            isShiftPressed: false,
            isControlPressed: true,
            isMetaPressed: false,
            isAltPressed: false,
          ),
          isFalse,
        );
      });

      test('matches with multiple modifiers all required', () {
        const activator = MCalKeyActivator(
          LogicalKeyboardKey.keyA,
          control: true,
          shift: true,
        );
        expect(
          activator.matches(
            LogicalKeyboardKey.keyA,
            isShiftPressed: true,
            isControlPressed: true,
            isMetaPressed: false,
            isAltPressed: false,
          ),
          isTrue,
        );
      });

      test('does not match with multiple modifiers when one is missing', () {
        const activator = MCalKeyActivator(
          LogicalKeyboardKey.keyA,
          control: true,
          shift: true,
        );
        expect(
          activator.matches(
            LogicalKeyboardKey.keyA,
            isShiftPressed: false,
            isControlPressed: true,
            isMetaPressed: false,
            isAltPressed: false,
          ),
          isFalse,
        );
      });
    });

    group('equality and hashCode', () {
      test('identical activators are equal', () {
        const a = MCalKeyActivator(LogicalKeyboardKey.tab);
        const b = MCalKeyActivator(LogicalKeyboardKey.tab);
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('activators with different keys are not equal', () {
        const a = MCalKeyActivator(LogicalKeyboardKey.tab);
        const b = MCalKeyActivator(LogicalKeyboardKey.enter);
        expect(a, isNot(equals(b)));
      });

      test('activators with different modifiers are not equal', () {
        const a = MCalKeyActivator(LogicalKeyboardKey.tab);
        const b = MCalKeyActivator(LogicalKeyboardKey.tab, shift: true);
        expect(a, isNot(equals(b)));
      });

      test('same activator is identical to itself', () {
        const a = MCalKeyActivator(LogicalKeyboardKey.enter);
        expect(a, equals(a));
      });
    });

    group('toString()', () {
      test('includes key and modifier info', () {
        const a = MCalKeyActivator(
          LogicalKeyboardKey.tab,
          shift: true,
        );
        final str = a.toString();
        expect(str, contains('shift: true'));
        expect(str, contains('control: false'));
      });
    });
  });

  group('MCalMonthKeyBindings', () {
    group('default constructor', () {
      test('enterEventMode defaults to Enter and Space', () {
        const bindings = MCalMonthKeyBindings();
        final keys = bindings.enterEventMode.map((a) => a.key).toList();
        expect(keys, contains(LogicalKeyboardKey.enter));
        expect(keys, contains(LogicalKeyboardKey.space));
      });

      test('cycleForward defaults to Tab and ArrowDown', () {
        const bindings = MCalMonthKeyBindings();
        final keys = bindings.cycleForward.map((a) => a.key).toList();
        expect(keys, contains(LogicalKeyboardKey.tab));
        expect(keys, contains(LogicalKeyboardKey.arrowDown));
      });

      test('cycleBackward defaults to Shift+Tab and ArrowUp', () {
        const bindings = MCalMonthKeyBindings();
        // Shift+Tab
        final shiftTab = bindings.cycleBackward.where(
          (a) => a.key == LogicalKeyboardKey.tab && a.shift,
        );
        expect(shiftTab, isNotEmpty);
        // ArrowUp
        final arrowUp = bindings.cycleBackward.where(
          (a) => a.key == LogicalKeyboardKey.arrowUp,
        );
        expect(arrowUp, isNotEmpty);
      });

      test('delete defaults to D, Delete, and Backspace', () {
        const bindings = MCalMonthKeyBindings();
        final keys = bindings.delete.map((a) => a.key).toList();
        expect(keys, contains(LogicalKeyboardKey.keyD));
        expect(keys, contains(LogicalKeyboardKey.delete));
        expect(keys, contains(LogicalKeyboardKey.backspace));
      });

      test('enterMoveMode defaults to M', () {
        const bindings = MCalMonthKeyBindings();
        expect(
          bindings.enterMoveMode.any(
            (a) => a.key == LogicalKeyboardKey.keyM,
          ),
          isTrue,
        );
      });

      test('home defaults to Home key', () {
        const bindings = MCalMonthKeyBindings();
        expect(
          bindings.home.any((a) => a.key == LogicalKeyboardKey.home),
          isTrue,
        );
      });

      test('pageUp defaults to PageUp', () {
        const bindings = MCalMonthKeyBindings();
        expect(
          bindings.pageUp.any((a) => a.key == LogicalKeyboardKey.pageUp),
          isTrue,
        );
      });

      test('createEvent defaults to N', () {
        const bindings = MCalMonthKeyBindings();
        expect(
          bindings.createEvent.any((a) => a.key == LogicalKeyboardKey.keyN),
          isTrue,
        );
      });

      test('createEvent can be disabled via empty list', () {
        const bindings = MCalMonthKeyBindings(createEvent: []);
        expect(bindings.createEvent, isEmpty);
      });

      test('copyWith overrides createEvent while preserving pageDown', () {
        final custom = const MCalMonthKeyBindings().copyWith(
          createEvent: const [MCalKeyActivator(LogicalKeyboardKey.keyC)],
        );
        expect(custom.createEvent.first.key, equals(LogicalKeyboardKey.keyC));
        expect(
          custom.pageDown.any((a) => a.key == LogicalKeyboardKey.pageDown),
          isTrue,
        );
      });

      test('can be constructed as const', () {
        // This test verifies const-constructibility at compile time.
        const bindings = MCalMonthKeyBindings();
        expect(bindings, isNotNull);
      });
    });

    group('copyWith()', () {
      test('overrides delete binding while preserving others', () {
        final original = const MCalMonthKeyBindings();
        final custom = original.copyWith(
          delete: const [MCalKeyActivator(LogicalKeyboardKey.keyX)],
        );

        // Delete is overridden
        expect(custom.delete.length, equals(1));
        expect(custom.delete.first.key, equals(LogicalKeyboardKey.keyX));

        // Others are preserved
        expect(
          custom.enterEventMode.any(
            (a) => a.key == LogicalKeyboardKey.enter,
          ),
          isTrue,
        );
        expect(
          custom.cycleForward.any((a) => a.key == LogicalKeyboardKey.tab),
          isTrue,
        );
      });

      test('disabling delete with empty list', () {
        const bindings = MCalMonthKeyBindings(delete: []);
        expect(bindings.delete, isEmpty);
      });

      test('overrides enterMoveMode while preserving enterResizeMode', () {
        final custom = const MCalMonthKeyBindings().copyWith(
          enterMoveMode: const [MCalKeyActivator(LogicalKeyboardKey.keyX)],
        );
        expect(custom.enterMoveMode.first.key, equals(LogicalKeyboardKey.keyX));
        expect(
          custom.enterResizeMode.any(
            (a) => a.key == LogicalKeyboardKey.keyR,
          ),
          isTrue,
        );
      });

      test('copyWith with no args produces equivalent bindings', () {
        const original = MCalMonthKeyBindings();
        final copy = original.copyWith();

        // Check a sampling of fields
        expect(
          copy.enterEventMode.map((a) => a.key).toList(),
          equals(original.enterEventMode.map((a) => a.key).toList()),
        );
        expect(
          copy.delete.map((a) => a.key).toList(),
          equals(original.delete.map((a) => a.key).toList()),
        );
      });
    });

    group('toString()', () {
      test('includes key field names', () {
        const bindings = MCalMonthKeyBindings();
        final str = bindings.toString();
        expect(str, contains('enterEventMode'));
        expect(str, contains('cycleForward'));
      });
    });
  });
}
