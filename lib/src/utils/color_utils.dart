import 'dart:ui';

/// Utility extensions for lightening and darkening [Color] values
/// without using transparency.
///
/// The results are equivalent to painting the colour at the given
/// [factor] opacity over a white (lighten) or black (darken) background,
/// then flattening to a fully opaque colour.
extension MCalColorUtils on Color {
  /// Returns a lighter, fully opaque version of this colour.
  ///
  /// [factor] controls how much to lighten: 0.0 returns the original colour,
  /// 1.0 returns pure white. Values are clamped to [0, 1].
  ///
  /// The result is identical to painting the colour at `(1 - factor)` opacity
  /// over a white background:
  ///
  /// ```
  /// channel = original * (1 - factor) + 1.0 * factor
  /// ```
  Color lighten([double factor = 0.3]) {
    final f = factor.clamp(0.0, 1.0);
    return Color.from(
      alpha: a,
      red: r + (1.0 - r) * f,
      green: g + (1.0 - g) * f,
      blue: b + (1.0 - b) * f,
    );
  }

  /// Returns a darker, fully opaque version of this colour.
  ///
  /// [factor] controls how much to darken: 0.0 returns the original colour,
  /// 1.0 returns pure black. Values are clamped to [0, 1].
  ///
  /// The result is identical to painting the colour at `(1 - factor)` opacity
  /// over a black background:
  ///
  /// ```
  /// channel = original * (1 - factor)
  /// ```
  Color darken([double factor = 0.3]) {
    final f = factor.clamp(0.0, 1.0);
    return Color.from(
      alpha: a,
      red: r * (1.0 - f),
      green: g * (1.0 - f),
      blue: b * (1.0 - f),
    );
  }

  /// Returns a softened version of this colour appropriate for the given
  /// [brightness].
  ///
  /// In [Brightness.light] mode the colour is lightened (blended toward
  /// white); in [Brightness.dark] mode it is darkened (blended toward black).
  /// This makes the result visually recede against the current background
  /// regardless of the theme.
  ///
  /// [factor] controls the strength of the effect (0.0 = unchanged,
  /// 1.0 = fully white or fully black). Defaults to 0.75.
  Color soften(Brightness brightness, [double factor = 0.75]) {
    return brightness == Brightness.light ? lighten(factor) : darken(factor);
  }
}
