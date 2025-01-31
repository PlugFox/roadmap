import 'dart:js_interop';

import 'package:roadmap/src/core/camera.dart';
import 'package:roadmap/src/core/engine.dart';
import 'package:web/web.dart';

class SkillsLayer implements Layer {
  SkillsLayer({
    required CameraView camera,
  }) : _camera = camera;

  @override
  bool get isVisible => true;
  bool _dirty = false;

  final CameraView _camera;

  @override
  void mount(RenderContext context) {
    _camera.addListener(_onCameraChange);
    _dirty = true;
  }

  @override
  void unmount(RenderContext context) {
    _camera.removeListener(_onCameraChange);
  }

  void _onCameraChange() {
    _dirty = true;
  }

  @override
  void update(RenderContext context, double delta) {
    // TODO: implement update
  }

  @override
  void render(RenderContext context, double delta) {
    if (!_dirty) return; // Skip rendering if not dirty
    _dirty = false;

    final ctxGL = context.ctxGL;
    final ctx2D = context.ctx2D;
    final viewport = _camera.viewport;

    // Очищаем и подготавливаем GL
    ctxGL
      ..viewport(0, 0, viewport.width.ceil(), viewport.height.ceil())
      ..clear(WebGL2RenderingContext.COLOR_BUFFER_BIT);

    // Очищаем и подготавливаем 2D
    ctx2D
      ..clearRect(0, 0, viewport.width, viewport.height)
      ..font = '16px Arial'
      ..fillStyle = 'white'.toJS
      ..textAlign = 'center'
      ..textBaseline = 'middle';

    final center = _camera.globalToLocal(0, 0);

    ctx2D.fillRect(center.dx - 10, center.dy - 10, 20, 20);
  }
}
