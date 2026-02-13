import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:multi_calendar/src/utils/color_utils.dart';

void main() {
  // ========================================================================
  // Helper: approximate channel equality (floating-point tolerance)
  // ========================================================================
  void expectColorClose(Color actual, Color expected, {double epsilon = 0.01}) {
    expect(actual.a, closeTo(expected.a, epsilon),
        reason: 'alpha: ${actual.a} != ${expected.a}');
    expect(actual.r, closeTo(expected.r, epsilon),
        reason: 'red: ${actual.r} != ${expected.r}');
    expect(actual.g, closeTo(expected.g, epsilon),
        reason: 'green: ${actual.g} != ${expected.g}');
    expect(actual.b, closeTo(expected.b, epsilon),
        reason: 'blue: ${actual.b} != ${expected.b}');
  }

  // ========================================================================
  // lighten
  // ========================================================================
  group('lighten', () {
    test('factor 0.0 returns the original colour', () {
      const color = Color(0xFF3366CC); // a medium blue
      final result = color.lighten(0.0);
      expectColorClose(result, color);
    });

    test('factor 1.0 returns white (preserving alpha)', () {
      const color = Color(0xFF3366CC);
      final result = color.lighten(1.0);
      expectColorClose(
        result,
        const Color.from(alpha: 1.0, red: 1.0, green: 1.0, blue: 1.0),
      );
    });

    test('default factor is 0.3', () {
      const color = Color(0xFF000000); // black
      final result = color.lighten(); // default 0.3
      // channel = 0.0 + (1.0 - 0.0) * 0.3 = 0.3
      expectColorClose(
        result,
        const Color.from(alpha: 1.0, red: 0.3, green: 0.3, blue: 0.3),
        epsilon: 0.02,
      );
    });

    test('lightening pure black by 0.5 equals 50% grey', () {
      const color = Color(0xFF000000);
      final result = color.lighten(0.5);
      // channel = 0.0 + (1.0 - 0.0) * 0.5 = 0.5
      expectColorClose(
        result,
        const Color.from(alpha: 1.0, red: 0.5, green: 0.5, blue: 0.5),
      );
    });

    test('lightening pure white has no effect', () {
      const color = Color(0xFFFFFFFF);
      final result = color.lighten(0.5);
      expectColorClose(
        result,
        const Color.from(alpha: 1.0, red: 1.0, green: 1.0, blue: 1.0),
      );
    });

    test('preserves alpha channel', () {
      final color = const Color(0xFF0000FF).withValues(alpha: 0.5);
      final result = color.lighten(0.5);
      expect(result.a, closeTo(0.5, 0.01));
    });

    test('result matches alpha compositing over white background', () {
      // For a colour with alpha=0.25 over white:
      //   composited_channel = original * 0.25 + 1.0 * 0.75
      // lighten(0.75) should produce the same:
      //   channel = original + (1.0 - original) * 0.75
      //           = original * 0.25 + 0.75
      const color = Color(0xFFCC0000); // red ≈ 0.8, green/blue = 0
      final lightened = color.lighten(0.75);
      // Red: 0.8 + (1.0 - 0.8) * 0.75 = 0.8 + 0.15 = 0.95
      // Green: 0.0 + 1.0 * 0.75 = 0.75
      // Blue: 0.0 + 1.0 * 0.75 = 0.75
      expect(lightened.r, closeTo(0.8 + 0.2 * 0.75, 0.02));
      expect(lightened.g, closeTo(0.75, 0.02));
      expect(lightened.b, closeTo(0.75, 0.02));
    });

    test('factors above 1.0 are clamped to 1.0', () {
      const color = Color(0xFF000000);
      final result = color.lighten(2.0);
      expectColorClose(
        result,
        const Color.from(alpha: 1.0, red: 1.0, green: 1.0, blue: 1.0),
      );
    });

    test('factors below 0.0 are clamped to 0.0', () {
      const color = Color(0xFF336699);
      final original = color;
      final result = color.lighten(-1.0);
      expectColorClose(result, original);
    });
  });

  // ========================================================================
  // darken
  // ========================================================================
  group('darken', () {
    test('factor 0.0 returns the original colour', () {
      const color = Color(0xFF3366CC);
      final result = color.darken(0.0);
      expectColorClose(result, color);
    });

    test('factor 1.0 returns black (preserving alpha)', () {
      const color = Color(0xFF3366CC);
      final result = color.darken(1.0);
      expectColorClose(
        result,
        const Color.from(alpha: 1.0, red: 0.0, green: 0.0, blue: 0.0),
      );
    });

    test('default factor is 0.3', () {
      const color = Color(0xFFFFFFFF); // white
      final result = color.darken(); // default 0.3
      // channel = 1.0 * (1.0 - 0.3) = 0.7
      expectColorClose(
        result,
        const Color.from(alpha: 1.0, red: 0.7, green: 0.7, blue: 0.7),
        epsilon: 0.02,
      );
    });

    test('darkening pure white by 0.5 equals 50% grey', () {
      const color = Color(0xFFFFFFFF);
      final result = color.darken(0.5);
      expectColorClose(
        result,
        const Color.from(alpha: 1.0, red: 0.5, green: 0.5, blue: 0.5),
      );
    });

    test('darkening pure black has no effect', () {
      const color = Color(0xFF000000);
      final result = color.darken(0.5);
      expectColorClose(
        result,
        const Color.from(alpha: 1.0, red: 0.0, green: 0.0, blue: 0.0),
      );
    });

    test('preserves alpha channel', () {
      final color = const Color(0xFFFF0000).withValues(alpha: 0.5);
      final result = color.darken(0.5);
      expect(result.a, closeTo(0.5, 0.01));
    });

    test('result matches alpha compositing over black background', () {
      // For a colour with alpha=0.25 over black:
      //   composited_channel = original * 0.25
      // darken(0.75) should produce:
      //   channel = original * (1.0 - 0.75) = original * 0.25
      const color = Color(0xFFFFFFFF);
      final darkened = color.darken(0.75);
      // All channels: 1.0 * 0.25 = 0.25
      expect(darkened.r, closeTo(0.25, 0.02));
      expect(darkened.g, closeTo(0.25, 0.02));
      expect(darkened.b, closeTo(0.25, 0.02));
    });

    test('factors above 1.0 are clamped to 1.0', () {
      const color = Color(0xFFFFFFFF);
      final result = color.darken(2.0);
      expectColorClose(
        result,
        const Color.from(alpha: 1.0, red: 0.0, green: 0.0, blue: 0.0),
      );
    });

    test('factors below 0.0 are clamped to 0.0', () {
      const color = Color(0xFF336699);
      final original = color;
      final result = color.darken(-1.0);
      expectColorClose(result, original);
    });
  });

  // ========================================================================
  // soften
  // ========================================================================
  group('soften', () {
    test('light mode delegates to lighten', () {
      const color = Color(0xFF3366CC);
      final softened = color.soften(Brightness.light, 0.5);
      final lightened = color.lighten(0.5);
      expectColorClose(softened, lightened);
    });

    test('dark mode delegates to darken', () {
      const color = Color(0xFF3366CC);
      final softened = color.soften(Brightness.dark, 0.5);
      final darkened = color.darken(0.5);
      expectColorClose(softened, darkened);
    });

    test('default factor is 0.75', () {
      const color = Color(0xFF000000);
      final softened = color.soften(Brightness.light);
      final lightened = color.lighten(0.75);
      expectColorClose(softened, lightened);
    });

    test('light mode softening produces a lighter colour', () {
      const color = Color(0xFF336699);
      final result = color.soften(Brightness.light);
      // All channels should be greater than or equal to original
      expect(result.r, greaterThanOrEqualTo(color.r));
      expect(result.g, greaterThanOrEqualTo(color.g));
      expect(result.b, greaterThanOrEqualTo(color.b));
    });

    test('dark mode softening produces a darker colour', () {
      const color = Color(0xFF336699);
      final result = color.soften(Brightness.dark);
      // All channels should be less than or equal to original
      expect(result.r, lessThanOrEqualTo(color.r + 0.001));
      expect(result.g, lessThanOrEqualTo(color.g + 0.001));
      expect(result.b, lessThanOrEqualTo(color.b + 0.001));
    });

    test('result is fully opaque', () {
      const color = Color(0xFF336699);
      final light = color.soften(Brightness.light);
      final dark = color.soften(Brightness.dark);
      expect(light.a, closeTo(1.0, 0.001));
      expect(dark.a, closeTo(1.0, 0.001));
    });
  });

  // ========================================================================
  // Edge cases
  // ========================================================================
  group('edge cases', () {
    test('lighten and darken are inverses at complementary factors', () {
      // lighten(0.5) on black = 0.5 grey
      // darken(0.5) on white = 0.5 grey
      const black = Color(0xFF000000);
      const white = Color(0xFFFFFFFF);
      final lightenedBlack = black.lighten(0.5);
      final darkenedWhite = white.darken(0.5);
      expectColorClose(lightenedBlack, darkenedWhite);
    });

    test('chaining lighten then darken does not return to original', () {
      // This verifies that lighten and darken are not simple inverses
      // when applied to the same colour
      const color = Color(0xFF336699);
      final roundTripped = color.lighten(0.5).darken(0.5);
      // The result should be different from the original
      // (lighten moves toward white, then darken moves toward black
      //  from the lightened position, which is not the same as the original)
      expect(roundTripped.r, isNot(closeTo(color.r, 0.001)));
    });

    test('works with fully transparent colour', () {
      final color = const Color(0xFF336699).withValues(alpha: 0.0);
      final result = color.lighten(0.5);
      // Alpha should remain 0
      expect(result.a, closeTo(0.0, 0.001));
      // Channels should still be lightened
      expect(result.r, greaterThan(color.r));
    });
  });
}
