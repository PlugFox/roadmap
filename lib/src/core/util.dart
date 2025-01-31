/// Linearly interpolate between two doubles.
///
/// Same as [lerpDouble] but specialized for non-null `double` type.
double lerpDouble(double a, double b, double t) => a * (1.0 - t) + b * t;

/// Linearly interpolate between two integers.
///
/// Same as [lerpDouble] but specialized for non-null `int` type.
double lerpInt(int a, int b, double t) => a + (b - a) * t;
