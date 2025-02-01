/* @immutable
class Optional<T extends Object?> {
  const Optional(this.value);

  final T value;

  bool get isPresent => value != null;

  T get orElse => value;

  T? getOrElse(T Function() orElse) => isPresent ? value : orElse();

  T? getOrNull() => value;

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Optional<T> && value == other.value;

  @override
  String toString() => 'Optional{value: $value}';
} */

import 'package:meta/meta.dart';

@immutable
final class Optional<V extends Object> {
  factory Optional(V? value) => value == null ? const Optional.absent() : Optional<V>._(value);

  const Optional.absent()
      : value = null,
        present = false;

  const Optional._(this.value) : present = true;

  final V? value;

  final bool present;

  /// Returns the value if it is present, otherwise returns [other].
  V valueOrElse(V Function() other) => value ?? other();

  /// Calls the consumer with the value if it is present.
  void ifPresent(void Function(V) consumer) {
    if (value case V v) consumer(v);
  }

  @override
  int get hashCode => present.hashCode ^ value.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Optional<V> && other.value == value;

  @override
  String toString() => present ? 'Optional<$V>{$value}' : 'Optional<$V>.absent{}';
}
