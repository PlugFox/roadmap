import 'package:roadmap/src/core/engine.dart';
import 'package:roadmap/src/core/user_event.dart';
import 'package:shared/shared.dart' show Offset;

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

  @override
  bool hitTest(_) => true;

  @override
  bool onEvent(RenderContext context, UserEvent event) {
    switch (event) {
      case UserKeyEvent event:
        switch (event.key) {
          case UserKeys.up:
            _velocity = _velocity.copyWith(dy: event.down ? -_speed / context.camera.zoom : 0);
          case UserKeys.down:
            _velocity = _velocity.copyWith(dy: event.down ? _speed / context.camera.zoom : 0);
          case UserKeys.left:
            _velocity = _velocity.copyWith(dx: event.down ? -_speed / context.camera.zoom : 0);
          case UserKeys.right:
            _velocity = _velocity.copyWith(dx: event.down ? _speed / context.camera.zoom : 0);
          case UserKeys.space:
            _isSpaceDown = event.down;
          default:
            return false;
        }
        return true;
      case UserMouseEvent event:
        if (_isSpaceDown && event.primary) {
          _isDragging = true;
          //_lastMousePosition = event.position / context.camera.zoom;
          context.camera.moveTo(context.camera.position - event.delta / context.camera.zoom);
          return true;
        } else if (event.middle) {
          _isDragging = true;
          //_lastMousePosition = event.position / context.camera.zoom;
          context.camera.moveTo(context.camera.position - event.delta / context.camera.zoom);
          return true;
        } else {
          _isDragging = false;
          return false;
        }
      case UserZoomEvent event:
        context.camera.changeZoom(context.camera.zoom - event.zoom);
        return true;
      case UserClickEvent _:
        return false;
    }
  }

  @override
  void mount(RenderContext context) {}

  @override
  void unmount(RenderContext context) {}

  @override
  void update(RenderContext context, double delta) {
    if (_isDragging) {
      // Do nothing - dragging is handled in mouse or touch events
    } else if (_velocity != Offset.zero) {
      // Keyboard controls
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
