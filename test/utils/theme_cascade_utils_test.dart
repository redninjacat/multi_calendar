import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/src/utils/theme_cascade_utils.dart';

void main() {
  const red = Color(0xFFFF0000);
  const blue = Color(0xFF0000FF);
  const green = Color(0xFF00FF00);
  const orange = Color(0xFFFFA500);
  const defaultColor = Color(0xFF808080);
  const white = Colors.white;
  const black = Colors.black;

  group('resolveEventTileColor', () {
    group('enableEventColorOverrides = false (event first)', () {
      test('event color wins when both event and theme colors are set', () {
        final result = resolveEventTileColor(
          themeColor: blue,
          eventColor: red,
          enableEventColorOverrides: false,
          defaultColor: defaultColor,
        );
        expect(result, red);
      });

      test('theme color used when event color is null', () {
        final result = resolveEventTileColor(
          themeColor: blue,
          eventColor: null,
          enableEventColorOverrides: false,
          defaultColor: defaultColor,
        );
        expect(result, blue);
      });

      test('allDayThemeColor used when event color is null and themeColor is null', () {
        final result = resolveEventTileColor(
          themeColor: null,
          allDayThemeColor: green,
          eventColor: null,
          enableEventColorOverrides: false,
          defaultColor: defaultColor,
        );
        expect(result, green);
      });

      test('allDayThemeColor used as second fallback after event color (enableEventColorOverrides=false)', () {
        // With enableEventColorOverrides=false: eventColor → allDayThemeColor → themeColor → default
        final result = resolveEventTileColor(
          themeColor: null,
          allDayThemeColor: green,
          eventColor: null,
          enableEventColorOverrides: false,
          defaultColor: defaultColor,
        );
        expect(result, green);
      });

      test('defaultColor used when all others are null', () {
        final result = resolveEventTileColor(
          themeColor: null,
          eventColor: null,
          enableEventColorOverrides: false,
          defaultColor: defaultColor,
        );
        expect(result, defaultColor);
      });

      test('event color takes priority over allDayThemeColor', () {
        final result = resolveEventTileColor(
          themeColor: blue,
          allDayThemeColor: green,
          eventColor: red,
          enableEventColorOverrides: false,
          defaultColor: defaultColor,
        );
        expect(result, red);
      });

      test('allDayThemeColor beats themeColor when event is null', () {
        final result = resolveEventTileColor(
          themeColor: blue,
          allDayThemeColor: green,
          eventColor: null,
          enableEventColorOverrides: false,
          defaultColor: defaultColor,
        );
        expect(result, green);
      });
    });

    group('enableEventColorOverrides = true (theme first)', () {
      test('allDayThemeColor wins when set', () {
        final result = resolveEventTileColor(
          themeColor: blue,
          allDayThemeColor: green,
          eventColor: red,
          enableEventColorOverrides: true,
          defaultColor: defaultColor,
        );
        expect(result, green);
      });

      test('themeColor wins over eventColor when allDayThemeColor is null', () {
        final result = resolveEventTileColor(
          themeColor: blue,
          eventColor: red,
          enableEventColorOverrides: true,
          defaultColor: defaultColor,
        );
        expect(result, blue);
      });

      test('eventColor used as fallback when theme colors are null', () {
        final result = resolveEventTileColor(
          themeColor: null,
          eventColor: red,
          enableEventColorOverrides: true,
          defaultColor: defaultColor,
        );
        expect(result, red);
      });

      test('defaultColor used when all others are null', () {
        final result = resolveEventTileColor(
          themeColor: null,
          eventColor: null,
          enableEventColorOverrides: true,
          defaultColor: defaultColor,
        );
        expect(result, defaultColor);
      });

      test('allDayThemeColor beats themeColor when both set', () {
        final result = resolveEventTileColor(
          themeColor: blue,
          allDayThemeColor: green,
          eventColor: null,
          enableEventColorOverrides: true,
          defaultColor: defaultColor,
        );
        expect(result, green);
      });
    });
  });

  group('resolveDropTargetTileColor', () {
    test('dropTargetThemeColor takes first priority regardless of other values', () {
      final result = resolveDropTargetTileColor(
        dropTargetThemeColor: orange,
        themeColor: blue,
        eventColor: red,
        enableEventColorOverrides: false,
        defaultColor: defaultColor,
      );
      expect(result, orange);
    });

    test('dropTargetThemeColor wins even when enableEventColorOverrides=true', () {
      final result = resolveDropTargetTileColor(
        dropTargetThemeColor: orange,
        themeColor: blue,
        eventColor: red,
        enableEventColorOverrides: true,
        defaultColor: defaultColor,
      );
      expect(result, orange);
    });

    test('falls through to resolveEventTileColor when dropTargetThemeColor is null (enableEventColorOverrides=false)', () {
      final result = resolveDropTargetTileColor(
        dropTargetThemeColor: null,
        themeColor: blue,
        eventColor: red,
        enableEventColorOverrides: false,
        defaultColor: defaultColor,
      );
      // enableEventColorOverrides=false → event wins
      expect(result, red);
    });

    test('falls through to resolveEventTileColor when dropTargetThemeColor is null (enableEventColorOverrides=true)', () {
      final result = resolveDropTargetTileColor(
        dropTargetThemeColor: null,
        themeColor: blue,
        eventColor: red,
        enableEventColorOverrides: true,
        defaultColor: defaultColor,
      );
      // enableEventColorOverrides=true → theme wins
      expect(result, blue);
    });

    test('allDayThemeColor passes through correctly when dropTargetThemeColor is null', () {
      final result = resolveDropTargetTileColor(
        dropTargetThemeColor: null,
        themeColor: blue,
        allDayThemeColor: green,
        eventColor: null,
        enableEventColorOverrides: false,
        defaultColor: defaultColor,
      );
      // event null → allDayThemeColor wins over themeColor
      expect(result, green);
    });

    test('defaultColor used when all colors are null', () {
      final result = resolveDropTargetTileColor(
        dropTargetThemeColor: null,
        themeColor: null,
        eventColor: null,
        enableEventColorOverrides: false,
        defaultColor: defaultColor,
      );
      expect(result, defaultColor);
    });
  });

  group('resolveContrastColor', () {
    test('dark background returns light contrast color', () {
      final result = resolveContrastColor(
        backgroundColor: black,
        lightContrastColor: white,
        darkContrastColor: black,
      );
      expect(result, white);
    });

    test('light background returns dark contrast color', () {
      final result = resolveContrastColor(
        backgroundColor: white,
        lightContrastColor: white,
        darkContrastColor: black,
      );
      expect(result, black);
    });

    test('pure red (dark by luminance) returns light contrast', () {
      // Red: luminance = 0.299 * 1.0 + 0.587 * 0 + 0.114 * 0 = 0.299 < 0.5 → light
      final result = resolveContrastColor(
        backgroundColor: const Color(0xFFFF0000),
        lightContrastColor: white,
        darkContrastColor: black,
      );
      expect(result, white);
    });

    test('pure green (bright by luminance) returns dark contrast', () {
      // Green: luminance = 0.299 * 0 + 0.587 * 1.0 + 0.114 * 0 = 0.587 > 0.5 → dark
      final result = resolveContrastColor(
        backgroundColor: const Color(0xFF00FF00),
        lightContrastColor: white,
        darkContrastColor: black,
      );
      expect(result, black);
    });

    test('pure blue (dark by luminance) returns light contrast', () {
      // Blue: luminance = 0.299 * 0 + 0.587 * 0 + 0.114 * 1.0 = 0.114 < 0.5 → light
      final result = resolveContrastColor(
        backgroundColor: const Color(0xFF0000FF),
        lightContrastColor: white,
        darkContrastColor: black,
      );
      expect(result, white);
    });

    test('threshold boundary: exactly 0.5 returns dark contrast', () {
      // luminance == 0.5 is NOT > 0.5, so returns lightContrastColor
      // Use a color close to threshold — mid-grey r=g=b≈0.5
      // luminance = 0.299*0.5 + 0.587*0.5 + 0.114*0.5 = 0.5
      const midGrey = Color(0xFF808080); // r=g=b=128/255 ≈ 0.502
      final result = resolveContrastColor(
        backgroundColor: midGrey,
        lightContrastColor: white,
        darkContrastColor: black,
      );
      // 0.502 > 0.5 → dark contrast
      expect(result, black);
    });

    test('custom contrast colors are returned correctly', () {
      const customLight = Color(0xFFFFF0F0);
      const customDark = Color(0xFF1A1A1A);

      final result = resolveContrastColor(
        backgroundColor: black,
        lightContrastColor: customLight,
        darkContrastColor: customDark,
      );
      expect(result, customLight);
    });

    test(
        'semi-transparent: dark at low alpha composites to light surface — darkContrastColor',
        () {
      final result = resolveContrastColor(
        backgroundColor: Colors.black.withValues(alpha: 0.1),
        lightContrastColor: white,
        darkContrastColor: black,
      );
      expect(result, black);
    });

    test(
        'semi-transparent: light at low alpha still reads as light — darkContrastColor',
        () {
      final result = resolveContrastColor(
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        lightContrastColor: white,
        darkContrastColor: black,
      );
      expect(result, black);
    });

    test(
        'semi-transparent: dark at high alpha still reads as dark — lightContrastColor',
        () {
      final result = resolveContrastColor(
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        lightContrastColor: white,
        darkContrastColor: black,
      );
      expect(result, white);
    });

    test('fully transparent color composites to white — darkContrastColor', () {
      final result = resolveContrastColor(
        backgroundColor: const Color(0x00FF0000),
        lightContrastColor: white,
        darkContrastColor: black,
      );
      expect(result, black);
    });
  });
}
