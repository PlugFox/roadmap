import 'package:roadmap/src/core/geometry.dart' as g;
import 'package:roadmap/src/core/listenable.dart';

/// View interface for the camera.
abstract interface class CameraView {
  /// Camera position.
  g.Offset get position;

  /// Size of the viewport.
  g.Size get viewport;

  /// Camera position in the world coordinates.
  g.Rect get bound;

  /// Camera zoom.
  /// The zoom is between 0 and 1.
  double get zoom;

  /// Convert the global position to the local position.
  g.Offset globalToLocal(double x, double y);

  /// Convert the local position to the global position.
  g.Offset localToGlobal(double x, double y);
}

/// Camera position and zoom.
class Camera with ChangeNotifier implements CameraView {
  /// Create a new camera with the specified parameters.
  Camera({
    g.Size viewport = g.Size.zero,
    g.Offset position = g.Offset.zero,
    double zoom = .5,
  })  : _position = position,
        _viewport = viewport,
        _halfViewport = viewport / 2,
        _bound = g.Rect.zero,
        _zoom = zoom.clamp(0, 1) {
    _calculateBound();
  }

  @override
  g.Size get viewport => _viewport;
  g.Size _viewport;
  g.Size _halfViewport;

  @override
  g.Offset get position => _position;
  g.Offset _position;

  @override
  g.Rect get bound => _bound;
  g.Rect _bound;

  @override
  double get zoom => _zoom;
  double _zoom;

  @override
  g.Offset globalToLocal(double x, double y) => _zoom == 1
      ? g.Offset(x - _bound.left, y - _bound.top)
      : g.Offset((x - _bound.left) * _zoom, (y - _bound.top) * _zoom);

  @override
  g.Offset localToGlobal(double x, double y) => _zoom == 1
      ? g.Offset(x + _bound.left, y + _bound.top)
      : g.Offset(x / _zoom + _bound.left, y / _zoom + _bound.top);

  /// Move to the specified global position.
  bool moveTo(g.Offset position) {
    if (_position == position) return false;
    _position = position;
    _calculateBound();
    notifyListeners();
    return true;
  }

  /// Change the size of viewport.
  bool changeSize(double width, double height) {
    if (_viewport.width == width && _viewport.height == height) return false;
    _viewport = g.Size(width, height);
    _halfViewport = _viewport / 2;
    _calculateBound();
    notifyListeners();
    return true;
  }

  /// Change the zoom of the camera.
  /// The zoom level is between 0 and 1.
  bool changeZoom(double zoom) {
    final newZoom = zoom.clamp(.0, 1.0);
    if (_zoom == newZoom) return false;
    _zoom = newZoom;
    _calculateBound();
    notifyListeners();
    return true;
  }

  /// Zoom in the camera.
  void zoomIn() {
    changeZoom(_zoom + .1);
  }

  /// Zoom out the camera.
  void zoomOut() {
    changeZoom(_zoom - .1);
  }

  /// Reset the zoom to the default value.
  void zoomReset() {
    changeZoom(.5);
  }

  @pragma('vm:prefer-inline')
  void _calculateBound() {
    if (_zoom == 1) {
      _bound = g.Rect.fromLTRB(
        _position.dx - _halfViewport.width,
        _position.dy - _halfViewport.height,
        _position.dx + _halfViewport.width,
        _position.dy + _halfViewport.height,
      );
    } else {
      _bound = g.Rect.fromLTRB(
        _position.dx - _halfViewport.width / _zoom,
        _position.dy - _halfViewport.height / _zoom,
        _position.dx + _halfViewport.width / _zoom,
        _position.dy + _halfViewport.height / _zoom,
      );
    }
  }
}
