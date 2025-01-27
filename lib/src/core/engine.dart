// ignore_for_file: prefer_constructors_over_static_methods

import 'dart:js_interop';

import 'package:web/web.dart';

// Rendering context
class RenderContext {
  RenderContext._({
    required int width,
    required int height,
    required this.canvas,
    required this.gl,
    required this.resources,
  })  : _width = width,
        _height = height;

  /// Width of the canvas.
  int get width => _width;
  int _width;

  /// Height of the canvas.
  int get height => _height;
  int _height;

  /// Canvas element.
  final HTMLCanvasElement canvas;

  /// WebGL context.
  final WebGL2RenderingContext gl;

  /// Resources for rendering, such as textures, shaders and buffers.
  final Map<String, Object?> resources;

  /// Get a resource from the context.
  T getResource<T>(String key) => resources[key] as T;

  /// Set a resource in the context.
  void setResource<T>(String key, T value) => resources[key] = value;

  /// Remove a resource from the context.
  void delResource(String key) => resources.remove(key);
}

// Core rendering infrastructure
abstract interface class Layer {
  /// Whether the layer is visible.
  bool get isVisible;

  /// Called when the layer is mounted.
  void mount(RenderContext context);

  /// Update the layer with the given delta time.
  void update(RenderContext context, double delta);

  /// Render the layer with the given context and delta time.
  void render(RenderContext context, double delta);

  /// Called when the layer is unmounted.
  void unmount(RenderContext context);
}

/// Layer that can be resized.
abstract interface class ResizableLayer implements Layer {
  /// Called when the layer is resized.
  void onResize(int width, int height);
}

/// Rendering engine that manages layers and rendering.
class RenderingEngine {
  RenderingEngine._({
    required List<Layer> layers,
    required RenderContext context,
  })  : _layers = layers,
        _context = context;

  static RenderingEngine? _instance;

  /// Singleton instance of the rendering engine.
  static RenderingEngine get instance => _instance ??= () {
        final layers = <Layer>[];
        // Initialize WebGL Canvas
        final canvas = document.createElement('canvas') as HTMLCanvasElement
          ..id = 'webgl-canvas'
          ..width = window.innerWidth
          ..height = window.innerHeight;
        //..style.position = 'absolute'
        //..style.top = '0'
        //..style.left = '0'
        //..style.pointerEvents = 'none';
        // Get WebGL context with alpha for transparency
        final gl = canvas.getContext(
          'webgl2',
          <String, Object?>{
            'alpha': false,
            'depth': false,
            'antialias': false,
            'powerPreference': 'high-performance',
            'preserveDrawingBuffer': false,
          }.jsify(),
        ) as WebGL2RenderingContext;
        document.body?.append(canvas);
        final engine = RenderingEngine._(
          layers: layers,
          context: RenderContext._(
            width: window.innerWidth,
            height: window.innerHeight,
            canvas: canvas,
            gl: gl,
            resources: <String, Object>{},
          ),
        );

        window.onresize = () {
          engine._onResize(window.innerWidth, window.innerHeight);
        }.toJS;
        return engine;
      }();

  final List<Layer> _layers;

  bool _isClosed = false;
  bool _isRunning = false;
  double _lastFrameTime = 0;

  // Rendering context
  final RenderContext _context;

  /// Resize the rendering engine.
  void _onResize(int width, int height) {
    if (_isClosed) return;
    if (_context.width == width && _context.height == height) return;
    _context
      .._width = width
      .._height = height;
    _context.canvas
      ..width = width
      ..height = height;
    // Notify layers about resize
    for (final layer in _layers) {
      if (layer case ResizableLayer resizableLayer) {
        resizableLayer.onResize(width, height);
      }
    }
  }

  /// Add a layer to the rendering engine.
  void addLayer(Layer layer) {
    _layers.add(layer);
    layer.mount(_context);
    if (layer is ResizableLayer) layer.onResize(_context.width, _context.height);
  }

  /// Remove a layer from the rendering engine.
  void removeLayer(Layer layer) {
    if (_layers.remove(layer)) layer.unmount(_context);
  }

  /// Tick the rendering engine.
  void _renderFrame(num currentTime) {
    if (!_isRunning) return;

    // Calculate delta time
    final deltaTime = (currentTime - _lastFrameTime) / 1000.0;
    _lastFrameTime = currentTime.toDouble();

    // Clear both contexts
    //_webGl.clear(WebGL.COLOR_BUFFER_BIT | WebGL.DEPTH_BUFFER_BIT);
    //_ctx2d.clearRect(0, 0, _canvas.width, _canvas.height);

    // Update and render all visible layers
    for (final layer in _layers) {
      if (!layer.isVisible) continue;
      layer
        ..update(_context, deltaTime)
        ..render(_context, deltaTime);
    }

    window.requestAnimationFrame(_renderFrame.toJS);
  }

  /// Start the rendering engine.
  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _lastFrameTime = window.performance.now();
    window.requestAnimationFrame(_renderFrame.toJS);
  }

  /// Stop the rendering engine.
  void stop() {
    _isRunning = false;
  }

  /// Dispose the rendering engine.
  void dispose() {
    stop();
    for (final layer in _layers) layer.unmount(_context);
    _layers.clear();
    _context.canvas.remove();
    _isClosed = true;
    _instance = null;
  }
}
