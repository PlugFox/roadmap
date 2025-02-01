import 'dart:async';
import 'dart:js_interop';

import 'package:roadmap/src/core/camera.dart';
import 'package:roadmap/src/core/engine.dart';
import 'package:shared/shared.dart' show Offset;
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
  StreamSubscription<TouchEvent>? _onTouchMoveSubscription;

  @override
  void mount(RenderContext context) {
    final element = document.getElementById('terminal-canvas');
    if (element == null) return;

    bool isAboveCanvas(MouseEvent event) {
      final topElement = document.elementFromPoint(event.clientX, event.clientY);
      if (topElement == null) return false;
      return topElement.isA<HTMLCanvasElement>() || topElement.id == 'terminal-canvas';
    }

    _onKeyDownSubscription?.cancel();
    _onKeyDownSubscription = EventStreamProviders.keyDownEvent.forTarget(window).listen((event) {
      switch (event.key) {
        case ' ':
          _isSpaceDown = true;
        /* event.preventDefault(); */
        case 'ArrowUp':
          /* case 'w': */
          _velocity = _velocity.copyWith(dy: -_speed / context.camera.zoom);
        //event.preventDefault();
        case 'ArrowDown':
          /* case 's': */
          _velocity = _velocity.copyWith(dy: _speed / context.camera.zoom);
        //event.preventDefault();
        case 'ArrowLeft':
          /* case 'a': */
          _velocity = _velocity.copyWith(dx: -_speed / context.camera.zoom);
        //event.preventDefault();
        case 'ArrowRight':
          /* case 'd': */
          _velocity = _velocity.copyWith(dx: _speed / context.camera.zoom);
        //event.preventDefault();
      }
    }, cancelOnError: false);
    _onKeyUpSubscription?.cancel();
    _onKeyUpSubscription = EventStreamProviders.keyUpEvent.forTarget(window).listen((event) {
      switch (event.key) {
        case ' ':
          _isSpaceDown = false;
        //event.preventDefault();
        case 'ArrowUp':
        case 'ArrowDown':
          /* case 'w':
        case 's': */
          _velocity = _velocity.copyWith(dy: 0);
        //event.preventDefault();
        case 'ArrowLeft':
        case 'ArrowRight':
          /* case 'a':
        case 'd': */
          _velocity = _velocity.copyWith(dx: 0);
        //event.preventDefault();
      }
    }, cancelOnError: false);

    // Mouse down - start dragging
    _onMouseDownSubscription?.cancel();
    _onMouseDownSubscription = EventStreamProviders.mouseDownEvent.forTarget(element).listen((event) {
      if (!isAboveCanvas(event)) return;
      if (_isSpaceDown && (event.buttons & 0x01) != 0) {
        // Left mouse with space key pressed
        _isDragging = true;
        _lastMousePosition = Offset(
          event.clientX.toDouble() / context.camera.zoom,
          event.clientY.toDouble() / context.camera.zoom,
        );
        //event.preventDefault();
        //event.stopPropagation();
      }
      if ((event.buttons & 0x04) != 0) {
        // Middle mouse
        _isDragging = true;
        _lastMousePosition = Offset(
          event.clientX.toDouble() / context.camera.zoom,
          event.clientY.toDouble() / context.camera.zoom,
        );
        //event.preventDefault();
        //event.stopPropagation();
      }
    }, cancelOnError: false);

    // Mouse move - drag the camera
    _onMouseMoveSubscription?.cancel();
    _onMouseMoveSubscription = EventStreamProviders.mouseMoveEvent.forTarget(element).listen((event) {
      if (!isAboveCanvas(event)) return;
      if (_isDragging && _lastMousePosition != null) {
        final newMousePosition = Offset(
          event.clientX.toDouble() / context.camera.zoom,
          event.clientY.toDouble() / context.camera.zoom,
        );
        final delta = newMousePosition - _lastMousePosition!;
        _lastMousePosition = newMousePosition;
        final camera = context.camera;
        camera.moveTo(camera.position - delta);
        //event.preventDefault();
        //event.stopPropagation();
      }
    }, cancelOnError: false);

    // Mouse up - stop dragging
    _onMouseUpSubscription?.cancel();
    _onMouseUpSubscription = EventStreamProviders.mouseUpEvent.forTarget(element).listen((event) {
      _isDragging = false;
      //event.preventDefault();
      //event.stopPropagation();
      //l.i('Mouse up');
    }, cancelOnError: false);

    // Wheel events
    _onWheelSubscription?.cancel();
    _onWheelSubscription = EventStreamProviders.wheelEvent.forTarget(element).listen((event) {
      if (!isAboveCanvas(event)) return;
      final camera = context.camera;
      if (event.ctrlKey) {
        camera.changeZoom(camera.zoom - event.deltaY / 1000);
        //event.preventDefault();
        //event.stopPropagation();
      } else {
        final deltaX = event.deltaX, deltaY = event.deltaY;
        //if (deltaX.abs() < .1 && deltaY.abs() < .1) return;
        final offset = Offset(
          -deltaX / context.camera.zoom,
          -deltaY / context.camera.zoom,
        );
        if (offset == Offset.zero) return;
        //if (offset.distanceSquared < 1) return;
        //l.i('Wheel: ${event.deltaX}, ${event.deltaY}');
        camera.moveTo(camera.position + offset);
        //event.preventDefault();
        //event.stopPropagation();
      }
    }, cancelOnError: false);

    _onTouchMoveSubscription?.cancel();
    _onTouchMoveSubscription = EventStreamProviders.touchMoveEvent.forTarget(element).listen((event) {
      if (event.touches.length == 0) return;
      //l.i('Touch move: ${event.touches.length}');
      //event.preventDefault();
    }, cancelOnError: false);
  }

  @override
  void unmount(RenderContext context) {
    _onKeyDownSubscription?.cancel();
    _onKeyUpSubscription?.cancel();
    _onMouseDownSubscription?.cancel();
    _onMouseMoveSubscription?.cancel();
    _onMouseUpSubscription?.cancel();
    _onWheelSubscription?.cancel();
    _onTouchMoveSubscription?.cancel();
  }

  void _gamepadHandler(Camera camera, Gamepad gamepad, double dx, double dy, double delta) {
    const deadZoneMin = .3, deadZoneMax = 1; // Dead zone values
    if (dx.abs() < deadZoneMin && dy.abs() < deadZoneMin) return;
    final offsetX = deadZoneMax * dx.abs() + deadZoneMin * (1 - dx.abs()); // Normalize the value
    final offsetY = deadZoneMax * dy.abs() + deadZoneMin * (1 - dy.abs()); // Normalize the value
    final offset = Offset(
      offsetX * _speed * delta / camera.zoom * dx.sign,
      offsetY * _speed * delta / camera.zoom * dy.sign,
    );
    if (offset == Offset.zero) return;
    camera.moveTo(camera.position + offset);
  }

  @override
  void update(RenderContext context, double delta) {
    if (_isDragging) {
      // Do nothing - dragging is handled in mouse or touch events
    } else if (_velocity != Offset.zero) {
      // Keyboard controls
      final camera = context.camera;
      final newPos = camera.position + _velocity * delta;
      camera.moveTo(newPos);
    } else {
      // Gamepad controls
      final gamepads = window.navigator.getGamepads().toDart;
      for (final gamepad in gamepads) {
        if (gamepad == null) continue; // Skip null gamepads
        if (!gamepad.connected) continue; // Skip disconnected gamepads
        final axes = gamepad.axes;
        final camera = context.camera;
        // Left stick
        _gamepadHandler(camera, gamepad, axes[0].toDartDouble, axes[1].toDartDouble, delta);
        // Right stick
        _gamepadHandler(camera, gamepad, axes[2].toDartDouble, axes[3].toDartDouble, delta);
      }
    }
  }

  @override
  void render(RenderContext context, double delta) {
    // TODO: implement render
  }
}
