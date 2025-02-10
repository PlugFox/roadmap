// ignore_for_file: prefer_constructors_over_static_methods
import 'dart:async';
import 'dart:js_interop';

import 'package:l/l.dart';
import 'package:meta/meta.dart';
import 'package:roadmap/src/core/camera.dart';
import 'package:roadmap/src/core/listenable.dart';
import 'package:roadmap/src/core/user_event.dart';
import 'package:shared/shared.dart' as g show Offset, Size;
import 'package:web/web.dart';

// Rendering context
class RenderContext {
  RenderContext._({
    required this.camera,
    required this.canvasGL,
    required this.ctxGL,
    required this.canvasUI,
    required this.ctx2D,
    required this.resources,
  });

  /// Camera for rendering.
  final Camera camera;

  /// WebGL canvas for rendering shaders.
  final HTMLCanvasElement canvasGL;

  /// WebGL2 context.
  final WebGL2RenderingContext ctxGL;

  /// 2D canvas for rendering UI.
  final HTMLCanvasElement canvasUI;

  /// 2D context.
  final CanvasRenderingContext2D ctx2D;

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

  /// Used to determine if the layer was hit by the given position.
  /// Returns true if the layer was hit, false otherwise.
  bool hitTest(g.Offset position);

  /// Called when the layer receives an event.
  bool onEvent(RenderContext context, UserEvent event);

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
  void onResize(double width, double height);
}

abstract class _RenderingEngineBase implements Listenable {
  const _RenderingEngineBase();

  /// Rendering context.
  abstract final RenderContext _context;

  /// Layers managed by the rendering engine.
  abstract final List<Layer> _layers;

  @mustCallSuper
  void start() {}

  @mustCallSuper
  void stop() {}

  /// Internal update method.
  /// Called by the rendering engine to update the scene.
  @mustCallSuper
  void _internalUpdate(double delta) {}
}

/// Rendering engine that manages layers and rendering.
class RenderingEngine extends _RenderingEngineBase
    with ChangeNotifier, _MouseBinding, _KeyboardBinding, _GamepadBinding {
  RenderingEngine._({
    required ShadowRoot shadow,
    required HTMLDivElement container,
    required List<Layer> layers,
    required RenderContext context,
  })  : _shadow = shadow,
        _container = container,
        _layers = layers,
        _context = context;

  static RenderingEngine? _instance;

  /// Singleton instance of the rendering engine.
  static RenderingEngine get instance => _instance ??= () {
        final terminalCanvas = document.querySelector('#terminal-canvas');
        if (terminalCanvas == null) throw StateError('Failed to find terminal canvas');
        {
          final collection = terminalCanvas.children;
          final length = collection.length;
          for (var i = length - 1; i >= 0; i--) collection.item(i)?.remove();
        }

        final shadow = terminalCanvas.attachShadow(ShadowRootInit(
          mode: 'open',
          clonable: false,
          serializable: false,
          delegatesFocus: false,
          slotAssignment: 'manual',
        ));

        final container = HTMLDivElement()
          ..id = 'engine'
          ..style.position = 'fixed'
          ..style.top = '0'
          ..style.left = '0'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.overflow = 'hidden';

        final width = window.innerWidth;
        final height = window.innerHeight;

        final layers = <Layer>[];
        // Initialize WebGL Canvas
        final canvasGL = document.createElement('canvas') as HTMLCanvasElement
          ..id = 'gl-canvas'
          ..width = width
          ..height = height
          ..style.position = 'absolute'
          ..style.top = '0'
          ..style.left = '0'
          ..style.zIndex = '0';

        // Get WebGL context with alpha for transparency
        final ctxGL = canvasGL.getContext(
          'webgl2',
          <String, Object?>{
            'alpha': false,
            'depth': false,
            'stencil': false,
            'antialias': false, // - for performance and pixel art
            'powerPreference': 'high-performance',
            'premultipliedAlpha': false,
            'preserveDrawingBuffer': false,
            'failIfMajorPerformanceCaveat': false, // true, - for performance
          }.jsify(),
        ) as WebGL2RenderingContext;

        // Initialize 2D Canvas
        final canvasUI = document.createElement('canvas') as HTMLCanvasElement
          ..id = 'ui-canvas'
          ..width = width
          ..height = height
          ..style.position = 'absolute'
          ..style.top = '0'
          ..style.left = '0'
          ..style.zIndex = '1';

        final ctx2D = canvasUI.getContext(
          '2d',
          <String, Object?>{
            'alpha': true,
            'willReadFrequently': false,
          }.jsify(),
        ) as CanvasRenderingContext2D;
        // Append canvases to the body
        shadow.append(container
          ..append(canvasGL)
          ..append(canvasUI));
        final viewport = g.Size(width.toDouble(), height.toDouble());
        final camera = Camera(
          position: g.Offset(viewport.width / 2, viewport.height / 2),
          viewport: viewport,
          zoom: .5,
        );
        final engine = RenderingEngine._(
          shadow: shadow,
          container: container,
          layers: layers,
          context: RenderContext._(
            camera: camera,
            canvasGL: canvasGL,
            ctxGL: ctxGL,
            canvasUI: canvasUI,
            ctx2D: ctx2D,
            resources: <String, Object>{},
          ),
        );
        return engine;
      }();

  final ShadowRoot _shadow;
  final HTMLDivElement _container;

  @override
  final List<Layer> _layers;

  bool _isClosed = false;
  bool _isRunning = false;
  double _lastFrameTime = 0;

  // Rendering context
  @override
  final RenderContext _context;
  RenderContext get context => _context;

  Timer? _healthCehckTimer;

  /// Resize the rendering engine.
  void _onResize(int width, int height) {
    if (_isClosed) return;
    final camera = _context.camera;
    final viewport = camera.viewport;
    final w = width.toDouble(), h = height.toDouble();
    if (viewport.width == w && viewport.height == h) return;
    l.d('Resize to $width x $height');
    _context.canvasGL
      ..width = width
      ..height = height;
    _context.canvasUI
      ..width = width
      ..height = height;
    camera.changeSize(w, h);
    // Notify layers about resize
    for (final layer in _layers) if (layer case ResizableLayer resizableLayer) resizableLayer.onResize(w, h);
  }

  late final JSExportedDartFunction _onResizeJS = ((Event event) {
    _onResize(window.innerWidth, window.innerHeight);
  }).toJS;

  /// Add a layer to the rendering engine.
  void addLayer(Layer layer) {
    _layers.add(layer);
    layer.mount(_context);
    final viewport = _context.camera.viewport;
    if (layer is ResizableLayer) layer.onResize(viewport.width, viewport.height);
  }

  /// Remove a layer from the rendering engine.
  void removeLayer(Layer layer) {
    if (_layers.remove(layer)) layer.unmount(_context);
  }

  /// Tick the rendering engine.
  void _renderFrame(num currentTime) {
    if (!_isRunning) return;

    /// Notify listeners about the new frame
    notifyListeners();

    // Calculate delta time
    final deltaTime = (currentTime - _lastFrameTime) / 1000.0;
    _lastFrameTime = currentTime.toDouble();

    // Clear both contexts
    //_webGl.clear(WebGL.COLOR_BUFFER_BIT | WebGL.DEPTH_BUFFER_BIT);
    //_ctx2d.clearRect(0, 0, _canvas.width, _canvas.height);

    _internalUpdate(deltaTime);

    // Update and render all visible layers
    for (final layer in _layers) {
      if (!layer.isVisible) continue;
      layer
        ..update(_context, deltaTime)
        ..render(_context, deltaTime);
    }

    window.requestAnimationFrame(_renderFrameJS);
  }

  late final JSExportedDartFunction _renderFrameJS = _renderFrame.toJS;

  /// Start the rendering engine.
  @override
  void start() {
    if (_isRunning) return;

    final container = _container;

    window.addEventListener('resize', _onResizeJS);

    super.start(); // Super call

    // Health check
    _healthCehckTimer?.cancel();
    _healthCehckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isClosed) timer.cancel();
      if (container.isConnected) return;
      l.w('Engine container is not connected');
      dispose();
    });

    // Start rendering
    _isRunning = true;
    _lastFrameTime = window.performance.now();
    window.requestAnimationFrame(_renderFrameJS);
  }

  /// Stop the rendering engine.
  @override
  void stop() {
    super.stop(); // Super call
    _isRunning = false;
    window.removeEventListener('resize', _onResizeJS);
    _healthCehckTimer?.cancel();
  }

  /// Dispose the rendering engine.
  @override
  void dispose() {
    super.dispose();
    stop();
    for (final layer in _layers) layer.unmount(_context);
    _layers.clear();
    _context
      ..canvasGL.remove()
      ..canvasUI.remove();
    final app = document.querySelector('#app');
    if (app != null) {
      app.removeChild(_shadow);
      final children = app.children;
      for (var i = children.length - 1; i >= 0; i--) children.item(i)!.remove();
    }
    _isClosed = true;
    _instance = null;
  }
}

mixin _MouseBinding on _RenderingEngineBase {
  StreamSubscription<MouseEvent>? _onMouseDownSubscription;
  StreamSubscription<MouseEvent>? _onMouseMoveSubscription;
  StreamSubscription<MouseEvent>? _onMouseUpSubscription;
  StreamSubscription<WheelEvent>? _onWheelSubscription;
  StreamSubscription<TouchEvent>? _onTouchMoveSubscription;

  /// Check if the mouse event is above the canvas.
  bool _isAboveCanvas(UserPointerEvent event) {
    final topElement = document.elementFromPoint(event.position.dx, event.position.dy);
    if (topElement == null) return false;
    return topElement.isA<HTMLCanvasElement>() || topElement.id == 'terminal-canvas';
  }

  /// Emit the event to the layers.
  bool _emitMouseEvent(UIEvent ui, UserEvent user) {
    var handled = false;
    for (final layer in _layers.reversed) {
      if (!layer.isVisible) continue;
      if (user case UserPointerEvent pointer) {
        if (!_isAboveCanvas(pointer)) continue;
        if (!layer.hitTest(pointer.position)) continue;
      }
      handled |= layer.onEvent(_context, user);
      if (handled) break; // Stop event propagation
    }
    if (handled) {
      ui
        ..preventDefault()
        ..stopPropagation();
    }
    return handled;
  }

  /// Subscribe to mouse events.
  void _resubscribeToMouseEvents() {
    _unsubscribeFromMouseEvents();
    final w = window;

    // Mouse down - start dragging
    _onMouseDownSubscription = EventStreamProviders.mouseDownEvent.forTarget(w).listen((event) {
      final e = UserClickEvent(
        position: g.Offset(event.clientX.toDouble(), event.clientY.toDouble()),
        primary: (event.buttons & 0x01) != 0, // Left mouse button
      );
      _emitMouseEvent(event, e);
    }, cancelOnError: false);

    // Mouse move - drag the camera
    _onMouseMoveSubscription = EventStreamProviders.mouseMoveEvent.forTarget(w).listen((event) {
      final e = UserMouseEvent(
        position: g.Offset(event.clientX.toDouble(), event.clientY.toDouble()),
        delta: g.Offset(event.movementX.toDouble(), event.movementY.toDouble()),
        primary: (event.buttons & 0x01) != 0, // Left mouse button
        secondary: (event.buttons & 0x02) != 0, // Right mouse button
        middle: (event.buttons & 0x04) != 0, // Middle mouse button
      );
      _emitMouseEvent(event, e);
    }, cancelOnError: false);

    // Mouse up - stop dragging
    _onMouseUpSubscription = EventStreamProviders.mouseUpEvent.forTarget(w).listen((event) {
      final e = UserMouseEvent(
        position: g.Offset(event.clientX.toDouble(), event.clientY.toDouble()),
        delta: g.Offset(event.movementX.toDouble(), event.movementY.toDouble()),
        primary: (event.buttons & 0x01) != 0, // Left mouse button
        secondary: (event.buttons & 0x02) != 0, // Right mouse button
        middle: (event.buttons & 0x04) != 0, // Middle mouse button
      );
      _emitMouseEvent(event, e);
    }, cancelOnError: false);

    // Wheel events
    _onWheelSubscription = EventStreamProviders.wheelEvent.forTarget(w).listen((event) {
      if (event.ctrlKey) {
        final e = UserZoomEvent(zoom: event.deltaY / 1000);
        _emitMouseEvent(event, e);
      } else {
        final e = UserMouseEvent(
          position: g.Offset(event.clientX.toDouble(), event.clientY.toDouble()),
          delta: g.Offset(-event.deltaX.toDouble(), -event.deltaY.toDouble()),
          primary: false,
          secondary: false,
          middle: true,
        );
        _emitMouseEvent(event, e);
      }
    }, cancelOnError: false);

    // Touch move events
    _onTouchMoveSubscription = EventStreamProviders.touchMoveEvent.forTarget(w).listen((event) {
      final length = event.touches.length;
      if (length != 1) return;
      final touch = event.touches.item(0);
      if (touch == null) return;
      final e = UserClickEvent(
        position: g.Offset(touch.clientX.toDouble(), touch.clientY.toDouble()),
        primary: true,
      );
      _emitMouseEvent(event, e);
    }, cancelOnError: false);
  }

  /// Unsubscribe from mouse events.
  void _unsubscribeFromMouseEvents() {
    _onMouseDownSubscription?.cancel();
    _onMouseMoveSubscription?.cancel();
    _onMouseUpSubscription?.cancel();
    _onWheelSubscription?.cancel();
    _onTouchMoveSubscription?.cancel();
  }

  @override
  void start() {
    super.start();
    _resubscribeToMouseEvents();
  }

  @override
  void stop() {
    super.stop();
    _unsubscribeFromMouseEvents();
  }
}

mixin _KeyboardBinding on _RenderingEngineBase {
  StreamSubscription<KeyboardEvent>? _onKeyDownSubscription;
  StreamSubscription<KeyboardEvent>? _onKeyUpSubscription;

  /// Emit the event to the layers.
  bool _emitKeyboardEvent(UIEvent ui, UserEvent user) {
    var handled = false;
    for (final layer in _layers.reversed) {
      if (!layer.isVisible) continue;
      handled |= layer.onEvent(_context, user);
      if (handled) break; // Stop event propagation
    }
    if (handled) {
      ui
        ..preventDefault()
        ..stopPropagation();
    }
    return handled;
  }

  /// Subscribe to keyboard events.
  void _resubscribeToKeyboardEvents() {
    _unsubscribeFromKeyboardEvents();
    _onKeyDownSubscription = EventStreamProviders.keyDownEvent.forTarget(window).listen((event) {
      switch (event.key) {
        case ' ':
          // Handle space key
          const e = UserKeyEvent.down(key: UserKeys.space);
          _emitKeyboardEvent(event, e);
        case 'ArrowUp':
          // Handle arrow up key
          const e = UserKeyEvent.down(key: UserKeys.up);
          _emitKeyboardEvent(event, e);
        case 'ArrowDown':
          // Handle arrow down key
          const e = UserKeyEvent.down(key: UserKeys.down);
          _emitKeyboardEvent(event, e);
        case 'ArrowLeft':
          // Handle arrow left key
          const e = UserKeyEvent.down(key: UserKeys.left);
          _emitKeyboardEvent(event, e);
        case 'ArrowRight':
          // Handle arrow right key
          const e = UserKeyEvent.down(key: UserKeys.right);
          _emitKeyboardEvent(event, e);
      }
    }, cancelOnError: false);
    _onKeyUpSubscription = EventStreamProviders.keyUpEvent.forTarget(window).listen((event) {
      switch (event.key) {
        case ' ':
          const e = UserKeyEvent.up(key: UserKeys.space);
          _emitKeyboardEvent(event, e);
        case 'ArrowUp':
          const e = UserKeyEvent.up(key: UserKeys.up);
          _emitKeyboardEvent(event, e);
        case 'ArrowDown':
          const e = UserKeyEvent.up(key: UserKeys.down);
          _emitKeyboardEvent(event, e);
        case 'ArrowLeft':
          const e = UserKeyEvent.up(key: UserKeys.left);
          _emitKeyboardEvent(event, e);
        case 'ArrowRight':
          const e = UserKeyEvent.up(key: UserKeys.right);
          _emitKeyboardEvent(event, e);
      }
    }, cancelOnError: false);
  }

  /// Unsubscribe from keyboard events.
  void _unsubscribeFromKeyboardEvents() {
    _onKeyDownSubscription?.cancel();
    _onKeyUpSubscription?.cancel();
  }

  @override
  void start() {
    super.start();
    _resubscribeToKeyboardEvents();
  }

  @override
  void stop() {
    super.stop();
    _unsubscribeFromKeyboardEvents();
  }
}

mixin _GamepadBinding on _RenderingEngineBase {
  /// Emit the event to the layers.
  bool _emitGamepadEvent(UserEvent user) {
    var handled = false;
    for (final layer in _layers.reversed) {
      if (!layer.isVisible) continue;
      handled |= layer.onEvent(_context, user);
      if (handled) break; // Stop event propagation
    }
    return handled;
  }

  void _stickHandler(Gamepad gamepad, double dx, double dy, double delta) {
    const deadZoneMin = .5, deadZoneMax = 1; // Dead zone values
    const speed = 250;
    if (dx.abs() < deadZoneMin && dy.abs() < deadZoneMin) return;
    final offsetX = deadZoneMax * dx.abs() + deadZoneMin * (1 - dx.abs()); // Normalize the value
    final offsetY = deadZoneMax * dy.abs() + deadZoneMin * (1 - dy.abs()); // Normalize the value
    if (offsetX == 0 && offsetY == 0) return;
    final e = UserMouseEvent(
      position: g.Offset.zero,
      delta: g.Offset(
        -1 * offsetX * speed * delta * dx.sign, // Delta X
        -1 * offsetY * speed * delta * dy.sign, // Delta Y
      ),
      primary: false,
      secondary: false,
      middle: true, // Move it as a middle button
    );
    _emitGamepadEvent(e);
  }

  @override
  void _internalUpdate(double delta) {
    super._internalUpdate(delta);
    // Gamepad controls
    final gamepads = window.navigator.getGamepads().toDart;
    if (gamepads.isEmpty) return;
    for (final gamepad in gamepads) {
      if (gamepad == null) continue; // Skip null gamepads
      if (!gamepad.connected) continue; // Skip disconnected gamepads
      final axes = gamepad.axes;
      // Left stick
      _stickHandler(gamepad, axes[0].toDartDouble, axes[1].toDartDouble, delta);
      // Right stick
      _stickHandler(gamepad, axes[2].toDartDouble, axes[3].toDartDouble, delta);
    }
  }
}
