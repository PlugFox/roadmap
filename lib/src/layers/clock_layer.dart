// ignore_for_file: cascade_invocations

import 'dart:js_interop';
import 'dart:math' as math;
import 'dart:typed_data' as td;

import 'package:intl/intl.dart' as intl;
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
  static const int _circleSegments = 24;
  static const List<String> _romanNumerals = ['XII', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI'];
  static final td.Float32List _hourColors = td.Float32List.fromList(<double>[0, 0, 1, 1, 0, 0, 1, 1]); // Синий цвет
  static final td.Float32List _minuteColors = td.Float32List.fromList(<double>[0, 1, 0, 1, 0, 1, 0, 1]); // Зеленый цвет
  static final td.Float32List _secondColors = td.Float32List.fromList(<double>[1, 0, 0, 1, 1, 0, 0, 1]); // Красный цвет
  static final td.Float32List _markColors = td.Float32List.fromList(<double>[0.5, 0.5, 0.5, 1, 0.5, 0.5, 0.5, 1]);
  static final td.Float32List _circleColors = td.Float32List.fromList(List.filled(_circleSegments ~/ 2 * 4 * 4, 1));

  @override
  bool get isVisible => true;

  DateTime _now = DateTime(0);

  void _initializeGL(RenderContext context) {
    if (_initialized) return;

    final gl = context.ctxGL;

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

  /// Рисует линии на экране
  void _drawLines(RenderContext context, td.Float32List vertices, td.Float32List colors) {
    final gl = context.ctxGL;

    // Устанавливаем вершины
    gl.bindBuffer(WebGL2RenderingContext.ARRAY_BUFFER, _vertexBuffer);
    gl.bufferData(
      WebGL2RenderingContext.ARRAY_BUFFER,
      vertices.toJS,
      WebGL2RenderingContext.STATIC_DRAW,
    );
    gl.enableVertexAttribArray(_positionLocation);
    gl.vertexAttribPointer(_positionLocation, 2, WebGL2RenderingContext.FLOAT, false, 0, 0);

    // Устанавливаем цвета
    gl.bindBuffer(WebGL2RenderingContext.ARRAY_BUFFER, _colorBuffer);
    gl.bufferData(
      WebGL2RenderingContext.ARRAY_BUFFER,
      colors.toJS,
      WebGL2RenderingContext.STATIC_DRAW,
    );
    gl.enableVertexAttribArray(_colorLocation);
    gl.vertexAttribPointer(_colorLocation, 4, WebGL2RenderingContext.FLOAT, false, 0, 0);

    // Рисуем линии
    gl.drawArrays(WebGL2RenderingContext.LINES, 0, vertices.length ~/ 2);
  }

  /// Создает вершины для стрелок часов
  td.Float32List _createHandVertices(double angle, double length) => td.Float32List(4)
    ..[0] = _centerX // Начальная точка (центр циферблата)
    ..[1] = _centerY // Начальная точка (центр циферблата)
    ..[2] = _centerX + length * math.cos(angle) // Конечная точка (конец стрелки)
    ..[3] = _centerY + length * math.sin(angle); // Конечная точка (конец стрелки)

  /// Создает вершины для циферблата
  td.Float32List _createCircleVertices(int segments) {
    final vertices = td.Float32List(segments * 4);

    for (var i = 0; i < segments; i++) {
      final angle1 = i * 2 * math.pi / segments;
      final angle2 = (i + 1) * 2 * math.pi / segments;
      vertices
        ..[i * 4 + 0] = _centerX + _radius * math.cos(angle1)
        ..[i * 4 + 1] = _centerY + _radius * math.sin(angle1)
        ..[i * 4 + 2] = _centerX + _radius * math.cos(angle2)
        ..[i * 4 + 3] = _centerY + _radius * math.sin(angle2);
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
    _updateTimeVertices();
  }

  td.Float32List _hourVertices = td.Float32List(4),
      _minuteVertices = td.Float32List(4),
      _secondVertices = td.Float32List(4);

  void _updateTimeVertices() {
    final now = DateTime.now();
    final hours = now.hour % 12;
    final minutes = now.minute;
    final seconds = now.second;

    final hourAngle = (hours + minutes / 60) * 2 * math.pi / 12 - math.pi / 2;
    final minuteAngle = minutes * 2 * math.pi / 60 - math.pi / 2;
    final secondAngle = seconds * 2 * math.pi / 60 - math.pi / 2;

    _hourVertices = _createHandVertices(hourAngle, _radius * 0.5);
    _minuteVertices = _createHandVertices(minuteAngle, _radius * 0.7);
    _secondVertices = _createHandVertices(secondAngle, _radius * 0.8);
  }

  @override
  void update(RenderContext context, double delta) {
    // Обновляем стрелки часов, минут и секунд если изменилось время
    final now = DateTime.now();
    if (now.second != _now.second || now.minute != _now.minute || now.hour != _now.hour) _updateTimeVertices();
    _now = now;
  }

  @override
  void render(RenderContext context, double delta) {
    final gl = context.ctxGL;

    // Очищаем и подготавливаем GL
    gl.viewport(0, 0, _width, _height);
    //gl.clearColor(0.1, 0.1, 0.1, 1.0); // Фон WebGL
    gl.clear(WebGL2RenderingContext.COLOR_BUFFER_BIT);

    // Прорисовываем текст
    context.ctx2D
      ..clearRect(0, 0, context.width, context.height)
      ..font = '32px Arial'
      ..fillStyle = 'white'.toJS
      ..fillText(intl.DateFormat('HH:mm:ss').format(_now), 50, 100);

    gl.useProgram(_program);
    gl.uniform2f(_resolutionLocation, _width.toDouble(), _height.toDouble());

    // Рисуем циферблат (окружность)
    final circleVertices = _createCircleVertices(_circleSegments);
    _drawLines(context, circleVertices, _circleColors);

    // Рисуем часовую стрелку
    _drawLines(context, _hourVertices, _hourColors);

    // Рисуем минутную стрелку
    _drawLines(context, _minuteVertices, _minuteColors);

    // Рисуем секундную стрелку
    _drawLines(context, _secondVertices, _secondColors);

    // Рисуем деления часов
    for (var i = 0; i < 12; i++) {
      final angle = i * 2 * math.pi / 12;
      final outerRadius = _radius;
      final innerRadius = _radius * 0.9;

      final markVertices = td.Float32List(4)
        ..[0] = _centerX + innerRadius * math.cos(angle)
        ..[1] = _centerY + innerRadius * math.sin(angle)
        ..[2] = _centerX + outerRadius * math.cos(angle)
        ..[3] = _centerY + outerRadius * math.sin(angle);

      _drawLines(context, markVertices, _markColors);
    }
  }

  @override
  void unmount(RenderContext context) {
    if (_initialized) {
      final gl = context.ctxGL;
      gl.deleteProgram(_program);
      gl.deleteBuffer(_vertexBuffer);
      gl.deleteBuffer(_colorBuffer);
    }
  }
}
