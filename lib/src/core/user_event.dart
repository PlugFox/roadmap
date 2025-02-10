import 'package:meta/meta.dart';
import 'package:shared/shared.dart' show Offset;

@immutable
sealed class UserEvent {
  const UserEvent();
}

abstract interface class UserPointerEvent {
  /// Global position of the pointer.
  abstract final Offset position;
}

/// A user click event.
final class UserClickEvent extends UserEvent implements UserPointerEvent {
  const UserClickEvent({
    required this.primary,
    required this.position,
  });

  /// Whether the primary button was pressed.
  /// e.g. left mouse button or touch contact.
  final bool primary;

  /// Whether the secondary button was pressed.
  /// e.g. right mouse button or touch contact.
  bool get secondary => !primary;

  /// Global position of the pointer.
  @override
  final Offset position;
}

/// A user drag event.
final class UserMouseEvent extends UserEvent implements UserPointerEvent {
  /// A user drag event.
  const UserMouseEvent({
    required this.primary,
    required this.secondary,
    required this.middle,
    required this.position,
    required this.delta,
  });

  /// Whether the primary button was pressed.
  /// e.g. left mouse button or touch contact.
  final bool primary;

  /// Whether the secondary button was pressed.
  /// e.g. right mouse button or touch contact.
  final bool secondary;

  /// Whether the middle button was pressed.
  /// e.g. middle mouse button or touch contact.
  final bool middle;

  /// Global position of the pointer.
  @override
  final Offset position;

  /// The distance the pointer has moved since the last event.
  final Offset delta;
}

/// A user zoom event.
final class UserZoomEvent extends UserEvent {
  const UserZoomEvent({
    required this.zoom,
  });

  /// The zoom factor.
  final double zoom;
}

/// A user key event.
final class UserKeyEvent extends UserEvent {
  const UserKeyEvent.down({
    required this.key,
  }) : down = true;

  const UserKeyEvent.up({
    required this.key,
  }) : down = false;

  /// The key that was pressed or released.
  final UserKeys key;

  /// Whether the key was pressed.
  final bool down;

  /// Whether the key was released.
  bool get up => !down;
}

enum UserKeys {
  unknown, // For unknown keys
  up,
  down,
  left,
  right,
  space,
}
