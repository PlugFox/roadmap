/// Linearly interpolate between two doubles.
///
/// Same as [lerpDouble] but specialized for non-null `double` type.
double lerpDouble(double a, double b, double t) => a * (1.0 - t) + b * t;

/// Linearly interpolate between two integers.
///
/// Same as [lerpDouble] but specialized for non-null `int` type.
double lerpInt(int a, int b, double t) => a + (b - a) * t;

/// Same as [num.clamp] but optimized for a non-null [double].
///
/// This is faster because it avoids polymorphism, boxing, and special cases for
/// floating point numbers.
//
// See also: //dev/benchmarks/microbenchmarks/lib/foundation/clamp.dart
double clampDouble(double x, double min, double max) {
  assert(min <= max && !max.isNaN && !min.isNaN, 'min must be less than or equal to max');
  if (x < min) return min;
  if (x > max) return max;
  if (x.isNaN) return max;
  return x;
}
