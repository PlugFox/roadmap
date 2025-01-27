// ignore_for_file: cascade_invocations

import 'dart:js_interop';
import 'dart:math' as math;
import 'dart:typed_data' as td;

import 'package:roadmap/src/core/engine.dart';
import 'package:web/web.dart';

class ClockLayer implements ResizableLayer {
  bool _initialized = false;
  late WebGLProgram _program;
  late WebGLBuffer _vertexBuffer;
  late WebGLBuffer _colorBuffer;

  // Shader locations
  late int _positionLocation;
  late int _colorLocation;
  late WebGLUniformLocation _resolutionLocation;

  int _width = window.innerWidth;
  int _height = window.innerHeight;
  late double _centerX;
  late double _centerY;
  late double _radius;

  /// Римские цифры для часов
  static const List<String> _romanNumerals = [
    'XII',
    'I',
    'II',
    'III',
    'IV',
    'V',
    'VI',
    'VII',
    'VIII',
    'IX',
    'X',
    'XI',
  ];

  @override
  bool get isVisible => true;

  void _initializeGL(RenderContext context) {
    if (_initialized) return;

    final gl = context.gl;

    // Vertex shader для позиции и цвета
    final vertexShader = gl.createShader(WebGL2RenderingContext.VERTEX_SHADER)!;
    gl.shaderSource(vertexShader, '''
      attribute vec2 a_position;
      attribute vec4 a_color;
      uniform vec2 u_resolution;
      varying vec4 v_color;

      void main() {
        vec2 zeroToOne = a_position / u_resolution;
        vec2 zeroToTwo = zeroToOne * 2.0;
        vec2 clipSpace = zeroToTwo - 1.0;
        gl_Position = vec4(clipSpace * vec2(1, -1), 0, 1);
        v_color = a_color;
      }
    ''');
    gl.compileShader(vertexShader);

    // Fragment shader для цвета
    final fragmentShader = gl.createShader(WebGL2RenderingContext.FRAGMENT_SHADER)!;
    gl.shaderSource(fragmentShader, '''
      precision mediump float;
      varying vec4 v_color;

      void main() {
        gl_FragColor = v_color;
      }
    ''');
    gl.compileShader(fragmentShader);

    // Создаем и линкуем программу
    _program = gl.createProgram()!;
    gl.attachShader(_program, vertexShader);
    gl.attachShader(_program, fragmentShader);
    gl.linkProgram(_program);

    // Получаем локации атрибутов и uniform-переменных
    _positionLocation = gl.getAttribLocation(_program, 'a_position');
    _colorLocation = gl.getAttribLocation(_program, 'a_color');
    _resolutionLocation = gl.getUniformLocation(_program, 'u_resolution')!;

    // Создаем буферы
    _vertexBuffer = gl.createBuffer()!;
    _colorBuffer = gl.createBuffer()!;

    _initialized = true;
  }

  void _drawLines(RenderContext context, List<double> vertices, List<double> colors) {
    final gl = context.gl;

    // Устанавливаем вершины
    gl.bindBuffer(WebGL2RenderingContext.ARRAY_BUFFER, _vertexBuffer);
    gl.bufferData(
      WebGL2RenderingContext.ARRAY_BUFFER,
      td.Float32List.fromList(vertices).toJS,
      WebGL2RenderingContext.STATIC_DRAW,
    );
    gl.enableVertexAttribArray(_positionLocation);
    gl.vertexAttribPointer(_positionLocation, 2, WebGL2RenderingContext.FLOAT, false, 0, 0);

    // Устанавливаем цвета
    gl.bindBuffer(WebGL2RenderingContext.ARRAY_BUFFER, _colorBuffer);
    gl.bufferData(
      WebGL2RenderingContext.ARRAY_BUFFER,
      td.Float32List.fromList(colors).toJS,
      WebGL2RenderingContext.STATIC_DRAW,
    );
    gl.enableVertexAttribArray(_colorLocation);
    gl.vertexAttribPointer(_colorLocation, 4, WebGL2RenderingContext.FLOAT, false, 0, 0);

    // Рисуем линии
    gl.drawArrays(WebGL2RenderingContext.LINES, 0, vertices.length ~/ 2);
  }

  List<double> _createHandVertices(double angle, double length) => [
        _centerX,
        _centerY,
        _centerX + length * math.cos(angle),
        _centerY + length * math.sin(angle),
      ];

  List<double> _createCircleVertices(int segments) {
    final vertices = <double>[];

    for (var i = 0; i < segments; i++) {
      final angle1 = i * 2 * math.pi / segments;
      final angle2 = (i + 1) * 2 * math.pi / segments;

      vertices.addAll([
        _centerX + _radius * math.cos(angle1),
        _centerY + _radius * math.sin(angle1),
        _centerX + _radius * math.cos(angle2),
        _centerY + _radius * math.sin(angle2),
      ]);
    }

    return vertices;
  }

  @override
  void mount(RenderContext context) {
    _initializeGL(context);
    _updateDimensions();
  }

  void _updateDimensions() {
    _centerX = _width / 2;
    _centerY = _height / 2;
    _radius = math.min(_width, _height) * 0.4;
  }

  @override
  void onResize(int width, int height) {
    _width = width;
    _height = height;
    _updateDimensions();
  }

  @override
  void update(RenderContext context, double delta) {}

  @override
  void render(RenderContext context, double delta) {
    final gl = context.gl;

    // Очищаем и подготавливаем GL
    gl.viewport(0, 0, _width, _height);
    gl.clear(WebGL2RenderingContext.COLOR_BUFFER_BIT);
    gl.useProgram(_program);
    gl.uniform2f(_resolutionLocation, _width.toDouble(), _height.toDouble());

    // Рисуем циферблат (окружность)
    final circleVertices = _createCircleVertices(60);
    final circleColors = List<double>.filled(circleVertices.length ~/ 2 * 4, 1);
    _drawLines(context, circleVertices, circleColors);

    // Получаем текущее время
    final now = DateTime.now();
    final hours = now.hour % 12;
    final minutes = now.minute;
    final seconds = now.second;

    // Рисуем часовую стрелку
    final hourAngle = (hours + minutes / 60) * 2 * math.pi / 12 - math.pi / 2;
    final hourVertices = _createHandVertices(hourAngle, _radius * 0.5);
    final hourColors = [0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, 1.0]; // Синий цвет
    _drawLines(context, hourVertices, hourColors);

    // Рисуем минутную стрелку
    final minuteAngle = minutes * 2 * math.pi / 60 - math.pi / 2;
    final minuteVertices = _createHandVertices(minuteAngle, _radius * 0.7);
    final minuteColors = [0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0]; // Зеленый цвет
    _drawLines(context, minuteVertices, minuteColors);

    // Рисуем секундную стрелку
    final secondAngle = seconds * 2 * math.pi / 60 - math.pi / 2;
    final secondVertices = _createHandVertices(secondAngle, _radius * 0.8);
    final secondColors = [1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0]; // Красный цвет
    _drawLines(context, secondVertices, secondColors);

    // Рисуем деления часов
    for (var i = 0; i < 12; i++) {
      final angle = i * 2 * math.pi / 12;
      final outerRadius = _radius;
      final innerRadius = _radius * 0.9;

      final markVertices = [
        _centerX + innerRadius * math.cos(angle),
        _centerY + innerRadius * math.sin(angle),
        _centerX + outerRadius * math.cos(angle),
        _centerY + outerRadius * math.sin(angle),
      ];

      // Серый цвет
      final markColors = [0.5, 0.5, 0.5, 1.0, 0.5, 0.5, 0.5, 1.0];
      _drawLines(context, markVertices, markColors);
    }
  }

  @override
  void unmount(RenderContext context) {
    if (_initialized) {
      final gl = context.gl;
      gl.deleteProgram(_program);
      gl.deleteBuffer(_vertexBuffer);
      gl.deleteBuffer(_colorBuffer);
    }
  }
}
