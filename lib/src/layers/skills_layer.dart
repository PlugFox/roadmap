import 'dart:async';
import 'dart:js_interop';
import 'dart:math' as math;
import 'dart:typed_data' as td;

import 'package:http/http.dart' as http;
import 'package:l/l.dart';
import 'package:roadmap/src/core/atlas_painter.dart';
import 'package:roadmap/src/core/engine.dart';
import 'package:roadmap/src/core/quadtree.dart';
import 'package:shared/shared.dart';
import 'package:web/web.dart';

class SkillsLayer implements Layer {
  SkillsLayer();

  @override
  bool get isVisible => true;
  bool _dirty = false;
  bool _needRelayout = false;
  _SkillsLayout? _layout;

  AtlasPainter? _atlasPainter;

  @override
  void mount(RenderContext context) {
    // TODO(plugfox): Get boundary from roadmap
    // Mike Matiunin <plugfox@gmail.com>, 01 February 2025
    _layout = _SkillsLayout(boundary: context.camera.bound);
    context.camera.addListener(_onCameraChange);
    _dirty = true;
    _loadAtlas(context.ctxGL);
  }

  @override
  void unmount(RenderContext context) {
    _layout?.clear();
    context.camera.removeListener(_onCameraChange);
  }

  Future<void> _loadAtlas(WebGL2RenderingContext context) async {
    try {
      if (_atlasPainter != null) return;
      final response = await http.get(Uri.base.resolve('assets/atlas.webp'));
      if (response.statusCode != 200) throw Exception('Failed to load skills atlas: ${response.statusCode}');
      _atlasPainter = await AtlasPainter.fromBytes(
        context: context,
        width: 600,
        height: 100,
        atlas: response.bodyBytes,
        type: 'image/webp' /* 'image/png' */,
      );
      _dirty = true;
    } on Object catch (error, stackTrace) {
      l.w('Failed to load skills atlas: $error', stackTrace);
      Timer(const Duration(seconds: 5), () => _loadAtlas(context));
    }
  }

  void _onCameraChange() {
    _needRelayout = true;
  }

  /// Execute relayout if needed, and mark as dirty
  /// For example, when camera changes -
  /// we need to relayout and extract objects from the QuadTree
  void _relayout(RenderContext context) {
    _needRelayout = false;
    _dirty = true;
  }

  @override
  void update(RenderContext context, double delta) {
    if (_needRelayout) _relayout(context);
  }

  @override
  void render(RenderContext context, double delta) {
    if (!_dirty) return; // Skip rendering if not dirty
    _dirty = false;

    final ctxGL = context.ctxGL;
    final ctx2D = context.ctx2D;
    final camera = context.camera;
    final viewport = camera.viewport;

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

    final center = camera.globalToLocal(0, 0);

    ctx2D.fillRect(center.dx - 10, center.dy - 10, 20, 20);

    // Рисуем спрайты
    final painter = _atlasPainter;
    if (painter == null) {
      // TODO(plugfox): Draw loading indicator
      return;
    }

    // Подготовка данных для отрисовки

    // Координаты объектов
    // x, y, width, height
    /* final instanceRects = td.Float32List.fromList([
      10, 20, 1000, 1000, // Первый объект
      300, 40, 1000, 1000, // Второй объект
      50, 200, 1000, 1000, // Третий объект
      for (var i = 3; i < 500; i++) 0, 0, 1000, 1000, // Объекты 4-500
    ]); */
    const count = 500;
    final instanceRects = td.Float32List(count * 4);
    var sqrtCount = math.sqrt(count).ceil();
    for (var i = 0; i < count; i++) {
      final row = i ~/ sqrtCount;
      final col = i % sqrtCount;
      const spacing = 200.0, startX = 100.0, startY = 100.0, width = 500.0, height = 500.0;
      instanceRects[i * 4 + 0] = startX + col * spacing;
      instanceRects[i * 4 + 1] = startY + row * spacing;
      instanceRects[i * 4 + 2] = width;
      instanceRects[i * 4 + 3] = height;
    }

    // TODO(plugfox): Move to shader or painter
    final ms = DateTime.now().millisecondsSinceEpoch ~/ 250; // Animation frame
    double anim(int i) => ((ms + i) % 6) * 100.0;

    // Нормализация координат спрайтов в атласе
    // x, y, width, height
    final atlasRects = td.Float32List.fromList([
      anim(0), 0, 100, 100, // спрайт 1
      anim(1), 0, 100, 100, // спрайт 2
      anim(2), 0, 100, 100, // спрайт 2
      for (var i = 3; i < count; i++) ...<double>[anim(i), 0, 100, 100], // спрайты 4-count
    ]);

    // Эффекты цвета
    // gamma, alpha, hue, saturation
    final colorEffects = td.Float32List.fromList([
      1.0, 1.0, 1.0, 1.0, // Первый: нормальная гамма (1.0), полностью непрозрачный (1.0)
      1.0, 0.5, 1.0, 1.0, // Второй: нормальная гамма (1.0), полупрозрачный (0.5)
      0.5, 1.0, 1.0, 1.0, // Третий: низкая гамма (0.5), полностью непрозрачный (1.0)
      for (var i = 3; i < count; i++) ...<double>[1, 1, 1, 1], // Спрайты 4-count
    ]);

    // Рендеринг
    painter.draw(
      instanceRects,
      atlasRects,
      colorEffects,
      td.Float32List.fromList([camera.bound.left, camera.bound.top, camera.zoom]),
      td.Float32List.fromList([viewport.width, viewport.height]),
    );
  }
}

class _SkillsLayout {
  _SkillsLayout({
    required Rect boundary,
  }) : _quadTree = QuadTree(boundary: boundary);

  final QuadTree _quadTree;

  void clear() => _quadTree.clear();
}

// TODO(plugfox): QuadTree for object extraction
// Mike Matiunin <plugfox@gmail.com>, 31 January 2025
