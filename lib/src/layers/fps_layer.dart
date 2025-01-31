import 'package:l/l.dart';
import 'package:roadmap/src/core/engine.dart';
import 'package:web/web.dart' as web;

class FpsLayer implements Layer {
  FpsLayer();

  @override
  bool get isVisible => true;

  int _drawCalls = 0;
  double _lastFrameTime = 0;

  /// Metrics collection
  void _initMetrics() {
    _drawCalls = 0;
    _lastFrameTime = web.window.performance.now();
  }

  /// Log rendering metrics
  void logMetrics() {
    var currentTime = web.window.performance.now();
    var frameTime = currentTime - _lastFrameTime;
    l.i('Draw Calls: $_drawCalls | Frame Time: ${frameTime.toStringAsFixed(2)} ms');
    _lastFrameTime = currentTime;
    _drawCalls = 0;
  }

  @override
  void mount(RenderContext context) {
    _initMetrics();
  }

  @override
  void unmount(RenderContext context) {}

  @override
  void update(RenderContext context, double delta) {}

  @override
  void render(RenderContext context, double delta) {
    _drawCalls++;
  }
}
