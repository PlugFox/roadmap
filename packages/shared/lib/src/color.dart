import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:shared/src/math.dart';

/// An immutable 32 bit color value in ARGB format.
///
/// Consider the light teal of the Flutter logo. It is fully opaque, with a red
/// channel value of 0x42 (66), a green channel value of 0xA5 (165), and a blue
/// channel value of 0xF5 (245). In the common "hash syntax" for color values,
/// it would be described as `#42A5F5`.
///
/// Here are some ways it could be constructed:
///
/// ```dart
/// Color c1 = const Color(0xFF42A5F5);
/// Color c2 = const Color.fromARGB(0xFF, 0x42, 0xA5, 0xF5);
/// Color c3 = const Color.fromARGB(255, 66, 165, 245);
/// Color c4 = const Color.fromRGBO(66, 165, 245, 1.0);
/// ```
///
/// If you are having a problem with `Color` wherein it seems your color is just
/// not painting, check to make sure you are specifying the full 8 hexadecimal
/// digits. If you only specify six, then the leading two digits are assumed to
/// be zero, which means fully-transparent:
///
/// ```dart
/// Color c1 = const Color(0xFFFFFF); // fully transparent white (invisible)
/// Color c2 = const Color(0xFFFFFFFF); // fully opaque white (visible)
/// ```
///
/// [Color]'s color components are stored as floating-point values. Care should
/// be taken if one does not want the literal equality provided by `operator==`.
/// To test equality inside of Flutter tests consider using `package:test`'s
/// `isSameColorAs`.
///
/// See also:
///
///  * [Colors](https://api.flutter.dev/flutter/material/Colors-class.html),
///    which defines the colors found in the Material Design specification.
///  * [`isSameColorAs`](https://api.flutter.dev/flutter/flutter_test/isSameColorAs.html),
///    a Matcher to handle floating-point deltas when checking [Color] equality.
@immutable
class Color {
  /// Construct an sRGB color from the lower 32 bits of an [int].
  ///
  /// The bits are interpreted as follows:
  ///
  /// * Bits 24-31 are the alpha value.
  /// * Bits 16-23 are the red value.
  /// * Bits 8-15 are the green value.
  /// * Bits 0-7 are the blue value.
  ///
  /// In other words, if AA is the alpha value in hex, RR the red value in hex,
  /// GG the green value in hex, and BB the blue value in hex, a color can be
  /// expressed as `const Color(0xAARRGGBB)`.
  ///
  /// For example, to get a fully opaque orange, you would use `const
  /// Color(0xFFFF9000)` (`FF` for the alpha, `FF` for the red, `90` for the
  /// green, and `00` for the blue).
  const Color(int value) : this._fromARGBC(value >> 24, value >> 16, value >> 8, value);

  /// Color from a string with a leading `#` character.
  /// For example:
  /// ```dart
  /// Color.fromHex('#42A5F5');
  /// Color.fromHex('#FF42A5F5');
  /// Color.fromHex('#F5');
  /// Color.fromHex('#FF');
  ///
  /// ```
  factory Color.fromHex(String hex) {
    switch (hex.length) {
      case 0 || 1:
        throw ArgumentError.value(hex, 'hex', 'Hex color must not be empty');
      // #AARRGGBB
      case 9 when hex[0] == '#':
        return Color.fromARGB(
          int.parse(hex.substring(1, 3), radix: 16),
          int.parse(hex.substring(3, 5), radix: 16),
          int.parse(hex.substring(5, 7), radix: 16),
          int.parse(hex.substring(7, 9), radix: 16),
        );
      // #RRGGBB
      case 7 when hex[0] == '#':
        return Color.fromARGB(
          0xFF,
          int.parse(hex.substring(1, 3), radix: 16),
          int.parse(hex.substring(3, 5), radix: 16),
          int.parse(hex.substring(5, 7), radix: 16),
        );
      // #ARGB
      case 5 when hex[0] == '#':
        return Color.fromARGB(
          int.parse(hex.substring(1, 2), radix: 16),
          int.parse(hex.substring(2, 3), radix: 16),
          int.parse(hex.substring(3, 4), radix: 16),
          int.parse(hex.substring(4, 5), radix: 16),
        );
      // #RGB
      case 4 when hex[0] == '#':
        return Color.fromARGB(
          0xFF,
          int.parse(hex.substring(1, 2), radix: 16),
          int.parse(hex.substring(2, 3), radix: 16),
          int.parse(hex.substring(3, 4), radix: 16),
        );
      default:
        throw ArgumentError.value(hex, 'hex', 'Hex color must be in the format #AARRGGBB, #RRGGBB, #ARGB or #RGB');
    }
  }

  /// Combine the foreground color as a transparent color over top
  /// of a background color, and return the resulting combined color.
  ///
  /// This uses standard alpha blending ("SRC over DST") rules to produce a
  /// blended color from two colors. This can be used as a performance
  /// enhancement when trying to avoid needless alpha blending compositing
  /// operations for two things that are solid colors with the same shape, but
  /// overlay each other: instead, just paint one with the combined color.
  factory Color.alphaBlend(Color foreground, Color background) {
    final alpha = foreground.a;
    if (alpha == 0) {
      // Foreground completely transparent.
      return background;
    }
    final invAlpha = 1 - alpha;
    var backAlpha = background.a;
    if (backAlpha == 1) {
      // Opaque background case
      return Color.from(
        alpha: 1,
        red: alpha * foreground.r + invAlpha * background.r,
        green: alpha * foreground.g + invAlpha * background.g,
        blue: alpha * foreground.b + invAlpha * background.b,
      );
    } else {
      // General case
      backAlpha = backAlpha * invAlpha;
      final outAlpha = alpha + backAlpha;
      assert(outAlpha != 0, 'Divide by zero');
      return Color.from(
        alpha: outAlpha,
        red: (foreground.r * alpha + background.r * backAlpha) / outAlpha,
        green: (foreground.g * alpha + background.g * backAlpha) / outAlpha,
        blue: (foreground.b * alpha + background.b * backAlpha) / outAlpha,
      );
    }
  }

  /// Construct a color with normalized color components.
  const Color.from({
    required double alpha,
    required double red,
    required double green,
    required double blue,
  })  : a = alpha,
        r = red,
        g = green,
        b = blue;

  /// Construct an sRGB color from the lower 8 bits of four integers.
  ///
  /// * `a` is the alpha value, with 0 being transparent and 255 being fully
  ///   opaque.
  /// * `r` is `red`, from 0 to 255.
  /// * `g` is `green`, from 0 to 255.
  /// * `b` is `blue`, from 0 to 255.
  ///
  /// Out of range values are brought into range using modulo 255.
  ///
  /// See also [fromRGBO], which takes the alpha value as a floating point
  /// value.
  const Color.fromARGB(int a, int r, int g, int b) : this._fromARGBC(a, r, g, b);

  const Color._fromARGBC(int alpha, int red, int green, int blue)
      : this._fromRGBOC(red, green, blue, (alpha & 0xff) / 255);

  /// Create an sRGB color from red, green, blue, and opacity, similar to
  /// `rgba()` in CSS.
  ///
  /// * `r` is `red`, from 0 to 255.
  /// * `g` is `green`, from 0 to 255.
  /// * `b` is `blue`, from 0 to 255.
  /// * `opacity` is alpha channel of this color as a double, with 0.0 being
  ///   transparent and 1.0 being fully opaque.
  ///
  /// Out of range values are brought into range using modulo 255.
  ///
  /// See also [fromARGB], which takes the opacity as an integer value.
  const Color.fromRGBO(int r, int g, int b, double opacity) : this._fromRGBOC(r, g, b, opacity);

  const Color._fromRGBOC(int r, int g, int b, double opacity)
      : a = opacity,
        r = (r & 0xff) / 255,
        g = (g & 0xff) / 255,
        b = (b & 0xff) / 255;

  /// Transparent color (alpha 0, RGB 0x000000).
  static const Color transparent = Color(0x00000000);

  /// Fully opaque black.
  static const Color opaqueBlack = Color(0xFF000000);

  /// Fully opaque white.
  static const Color opaqueWhite = Color(0xFFFFFFFF);

  /// Fully opaque red.
  static const Color opaqueRed = Color(0xFFFF0000);

  /// Fully opaque green.
  static const Color opaqueGreen = Color(0xFF00FF00);

  /// Fully opaque blue.
  static const Color opaqueBlue = Color(0xFF0000FF);

  /// The alpha channel of this color.
  ///
  /// A value of 0.0 means this color is fully transparent. A value of 1.0 means
  /// this color is fully opaque.
  final double a;

  /// The red channel of this color.
  final double r;

  /// The green channel of this color.
  final double g;

  /// The blue channel of this color.
  final double b;

  static int _floatToInt8(double x) => (x * 255.0).round() & 0xff;

  /// A 32 bit value representing this color.
  ///
  /// The bits are assigned as follows:
  ///
  /// * Bits 24-31 are the alpha value.
  /// * Bits 16-23 are the red value.
  /// * Bits 8-15 are the green value.
  /// * Bits 0-7 are the blue value.
  int toARGB32() => _floatToInt8(a) << 24 | _floatToInt8(r) << 16 | _floatToInt8(g) << 8 | _floatToInt8(b) << 0;

  /// The alpha channel of this color in an 8 bit value.
  ///
  /// A value of 0 means this color is fully transparent. A value of 255 means
  /// this color is fully opaque.
  @Deprecated('Use .a.')
  int get alpha => (0xff000000 & toARGB32()) >> 24;

  /// The alpha channel of this color as a double.
  ///
  /// A value of 0.0 means this color is fully transparent. A value of 1.0 means
  /// this color is fully opaque.
  @Deprecated('Use .a.')
  double get opacity => alpha / 0xFF;

  /// The red channel of this color in an 8 bit value.
  @Deprecated('Use .r.')
  int get red => (0x00ff0000 & toARGB32()) >> 16;

  /// The green channel of this color in an 8 bit value.
  @Deprecated('Use .g.')
  int get green => (0x0000ff00 & toARGB32()) >> 8;

  /// The blue channel of this color in an 8 bit value.
  @Deprecated('Use .b.')
  int get blue => (0x000000ff & toARGB32()) >> 0;

  /// Returns a new color that matches this color with the passed in components
  /// changed.
  ///
  /// Changes to color components will be applied before applying changes to the
  /// color space.
  Color withValues({double? alpha, double? red, double? green, double? blue}) {
    Color? updatedComponents;
    if (alpha != null || red != null || green != null || blue != null) {
      updatedComponents = Color.from(alpha: alpha ?? a, red: red ?? r, green: green ?? g, blue: blue ?? b);
    }
    return updatedComponents ?? this;
  }

  /// Returns a new color that matches this color with the red channel replaced
  static Color scaleAlpha(Color x, double factor) => x.withValues(alpha: clampDouble(x.a * factor, 0, 1));

  /// Returns a new color that matches this color with the alpha channel
  /// replaced with `a` (which ranges from 0 to 255).
  ///
  /// Out of range values will have unexpected effects.
  Color withAlpha(int a) => //Color.fromARGB(a, red, green, blue);
      Color.from(alpha: a / 255, red: r, green: g, blue: b);

  /// Returns a new color that matches this color with the alpha channel
  /// replaced with the given `opacity` (which ranges from 0.0 to 1.0).
  ///
  /// Out of range values will have unexpected effects.
  @Deprecated('Use .withValues() to avoid precision loss.')
  Color withOpacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0, 'Opacity must be in the range of [0.0, 1.0]');
    return withAlpha((255.0 * opacity).round());
  }

  /// Returns a new color that matches this color with the red channel replaced
  /// with `r` (which ranges from 0 to 255).
  ///
  /// Out of range values will have unexpected effects.
  Color withRed(int r) => Color.from(alpha: a, red: r / 255, green: g, blue: b);

  /// Returns a new color that matches this color with the green channel
  /// replaced with `g` (which ranges from 0 to 255).
  ///
  /// Out of range values will have unexpected effects.
  Color withGreen(int g) => Color.from(alpha: a, red: r, green: g / 255, blue: b);

  /// Returns a new color that matches this color with the blue channel replaced
  /// with `b` (which ranges from 0 to 255).
  ///
  /// Out of range values will have unexpected effects.
  Color withBlue(int b) => Color.from(alpha: a, red: r, green: g, blue: b / 255);

  // See <https://www.w3.org/TR/WCAG20/#relativeluminancedef>
  static double _linearizeColorComponent(double component) {
    if (component <= 0.03928) {
      return component / 12.92;
    }
    return math.pow((component + 0.055) / 1.055, 2.4) as double;
  }

  /// Returns a brightness value between 0 for darkest and 1 for lightest.
  ///
  /// Represents the relative luminance of the color. This value is computationally
  /// expensive to calculate.
  ///
  /// See <https://en.wikipedia.org/wiki/Relative_luminance>.
  double computeLuminance() {
    // See <https://www.w3.org/TR/WCAG20/#relativeluminancedef>
    final R = _linearizeColorComponent(r);
    final G = _linearizeColorComponent(g);
    final B = _linearizeColorComponent(b);
    return 0.2126 * R + 0.7152 * G + 0.0722 * B;
  }

  /// Linearly interpolate between two colors.
  ///
  /// This is intended to be fast but as a result may be ugly. Consider
  /// [HSVColor] or writing custom logic for interpolating colors.
  ///
  /// If either color is null, this function linearly interpolates from a
  /// transparent instance of the other color. This is usually preferable to
  /// interpolating from [material.Colors.transparent] (`const
  /// Color(0x00000000)`), which is specifically transparent _black_.
  ///
  /// The `t` argument represents position on the timeline, with 0.0 meaning
  /// that the interpolation has not started, returning `a` (or something
  /// equivalent to `a`), 1.0 meaning that the interpolation has finished,
  /// returning `b` (or something equivalent to `b`), and values in between
  /// meaning that the interpolation is at the relevant point on the timeline
  /// between `a` and `b`. The interpolation can be extrapolated beyond 0.0 and
  /// 1.0, so negative values and values greater than 1.0 are valid (and can
  /// easily be generated by curves such as [Curves.elasticInOut]). Each channel
  /// will be clamped to the range 0 to 255.
  ///
  /// Values for `t` are usually obtained from an [Animation<double>], such as
  /// an [AnimationController].
  static Color? lerp(Color? x, Color? y, double t) {
    if (y == null) {
      if (x == null) {
        return null;
      } else {
        return scaleAlpha(x, 1.0 - t);
      }
    } else {
      if (x == null) {
        return scaleAlpha(y, t);
      } else {
        return Color.from(
          alpha: clampDouble(lerpDouble(x.a, y.a, t), 0, 1),
          red: clampDouble(lerpDouble(x.r, y.r, t), 0, 1),
          green: clampDouble(lerpDouble(x.g, y.g, t), 0, 1),
          blue: clampDouble(lerpDouble(x.b, y.b, t), 0, 1),
        );
      }
    }
  }

  /// Returns an alpha value representative of the provided [opacity] value.
  ///
  /// The [opacity] value may not be null.
  static int getAlphaFromOpacity(double opacity) => (clampDouble(opacity, 0, 1) * 255).round();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Color && other.a == a && other.r == r && other.g == g && other.b == b;
  }

  @override
  int get hashCode => Object.hash(a, r, g, b);

  @override
  String toString() =>
      'Color(alpha: ${a.toStringAsFixed(4)}, red: ${r.toStringAsFixed(4)}, green: ${g.toStringAsFixed(4)}, blue: ${b.toStringAsFixed(4)})';
}
