import 'dart:async';

import 'package:roadmap/src/core/engine.dart';
import 'package:roadmap/src/core/geometry.dart';
import 'package:web/web.dart';

/// Component that represents the camera layer.
/// Responsible for rendering the camera view and updating the camera position.
class CameraLayer implements Layer {
  CameraLayer();

  @override
  bool get isVisible => true;

  Offset _velocity = Offset.zero;
  static const double _speed = 250;
  bool _isSpaceDown = false;
  bool _isDragging = false;
  Offset? _lastMousePosition;

  StreamSubscription<KeyboardEvent>? _onKeyDownSubscription;
  StreamSubscription<KeyboardEvent>? _onKeyUpSubscription;
  StreamSubscription<MouseEvent>? _onMouseDownSubscription;
  StreamSubscription<MouseEvent>? _onMouseMoveSubscription;
  StreamSubscription<MouseEvent>? _onMouseUpSubscription;
  StreamSubscription<WheelEvent>? _onWheelSubscription;

  @override
  void mount(RenderContext context) {
    _onKeyDownSubscription?.cancel();
    _onKeyDownSubscription = EventStreamProviders.keyDownEvent.forTarget(window).listen((event) {
      switch (event.key) {
        case ' ':
          _isSpaceDown = true;
          event.preventDefault();
        case 'ArrowUp':
        case 'w':
          _velocity = _velocity.copyWith(dy: -_speed / context.camera.zoom);
          event.preventDefault();
        case 'ArrowDown':
        case 's':
          _velocity = _velocity.copyWith(dy: _speed / context.camera.zoom);
          event.preventDefault();
        case 'ArrowLeft':
        case 'a':
          _velocity = _velocity.copyWith(dx: -_speed / context.camera.zoom);
          event.preventDefault();
        case 'ArrowRight':
        case 'd':
          _velocity = _velocity.copyWith(dx: _speed / context.camera.zoom);
          event.preventDefault();
      }
    }, cancelOnError: false);
    _onKeyUpSubscription?.cancel();
    _onKeyUpSubscription = EventStreamProviders.keyUpEvent.forTarget(window).listen((event) {
      switch (event.key) {
        case ' ':
          _isSpaceDown = false;
          event.preventDefault();
        case 'ArrowUp':
        case 'ArrowDown':
        case 'w':
        case 's':
          _velocity = _velocity.copyWith(dy: 0);
          event.preventDefault();
        case 'ArrowLeft':
        case 'ArrowRight':
        case 'a':
        case 'd':
          _velocity = _velocity.copyWith(dx: 0);
          event.preventDefault();
      }
    }, cancelOnError: false);

    // Mouse down - start dragging
    _onMouseDownSubscription?.cancel();
    _onMouseDownSubscription = EventStreamProviders.mouseDownEvent.forTarget(window).listen((event) {
      if (_isSpaceDown && (event.buttons & 0x01) != 0) {
        // Left mouse with space key pressed
        _isDragging = true;
        _lastMousePosition = Offset(
          event.clientX.toDouble() / context.camera.zoom,
          event.clientY.toDouble() / context.camera.zoom,
        );
        event.preventDefault();
      }
      if ((event.buttons & 0x04) != 0) {
        // Middle mouse
        _isDragging = true;
        _lastMousePosition = Offset(
          event.clientX.toDouble() / context.camera.zoom,
          event.clientY.toDouble() / context.camera.zoom,
        );
        event.preventDefault();
      }
    }, cancelOnError: false);

    // Mouse move - drag the camera
    _onMouseMoveSubscription?.cancel();
    _onMouseMoveSubscription = EventStreamProviders.mouseMoveEvent.forTarget(window).listen((event) {
      if (_isDragging && _lastMousePosition != null) {
        final newMousePosition = Offset(
          event.clientX.toDouble() / context.camera.zoom,
          event.clientY.toDouble() / context.camera.zoom,
        );
        final delta = newMousePosition - _lastMousePosition!;
        _lastMousePosition = newMousePosition;
        final camera = context.camera;
        camera.moveTo(camera.position - delta);
      }
    }, cancelOnError: false);

    // Mouse up - stop dragging
    _onMouseUpSubscription?.cancel();
    _onMouseUpSubscription = EventStreamProviders.mouseUpEvent.forTarget(window).listen((event) {
      _isDragging = false;
    });

    // Wheel events
    _onWheelSubscription?.cancel();
    _onWheelSubscription = EventStreamProviders.wheelEvent.forTarget(window).listen((event) {
      final camera = context.camera;
      camera.moveTo(
        camera.position +
            Offset(
              -event.deltaX / context.camera.zoom,
              -event.deltaY / context.camera.zoom,
            ),
      );
    });
  }

  @override
  void unmount(RenderContext context) {
    _onKeyDownSubscription?.cancel();
    _onKeyUpSubscription?.cancel();
    _onMouseDownSubscription?.cancel();
    _onMouseMoveSubscription?.cancel();
    _onMouseUpSubscription?.cancel();
    _onWheelSubscription?.cancel();
  }

  @override
  void update(RenderContext context, double delta) {
    if (!_isDragging && _velocity != Offset.zero) {
      final camera = context.camera;
      final newPos = camera.position + _velocity * delta;
      camera.moveTo(newPos);
    }
  }

  @override
  void render(RenderContext context, double delta) {
    // TODO: implement render
  }
}
