import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Высокопроизводительный рендерер атласа с поддержкой расширенных возможностей
abstract class AtlasPainter {
  AtlasPainter._();

  /// Set the atlas texture from bytes and return the painter.
  static Future<AtlasPainter> fromBytes({
    required web.WebGL2RenderingContext context,
    required Uint8List atlas,
    required double width,
    required double height,
    String type = 'image/webp',
    bool mipmap = false,
  }) async {
    final painter = _AtlasPainter(context);
    await painter._setAtlasFromBytes(
      atlas,
      type,
      mipmap: mipmap,
      width: width,
      height: height,
    );
    return painter;
  }

  /// Set the atlas texture from an html image and return the painter.
  static AtlasPainter fromImage(
    web.WebGL2RenderingContext context,
    web.HTMLImageElement image, {
    bool mipmap = false,
  }) =>
      _AtlasPainter(context).._setAtlasFromImage(image, mipmap: mipmap);

  /// Draw the atlas.
  void draw(
    Float32List instanceRects, // x, y, width, height для каждого спрайта
    Float32List atlasRects, // x, y, width, height в атласе (без нормализации)
    Float32List colorEffects, // gamma, alpha для каждого спрайта
    Float32List camera, // x, y, zoom
    Float32List resolution, // width, height экрана
  );

  /// Dispose the painter.
  void dispose();
}

class _AtlasPainter implements AtlasPainter {
  _AtlasPainter(web.WebGL2RenderingContext ctxGL) : _gl = ctxGL {
    _initShaders();
    _initBuffers();
  }

  final web.WebGL2RenderingContext _gl;
  late web.WebGLProgram _program;
  late web.WebGLBuffer _quadBuffer;
  late web.WebGLBuffer _instanceBuffer;
  late web.WebGLBuffer _colorBuffer;
  late web.WebGLBuffer _uvBuffer;
  late web.WebGLTexture _atlasTexture;

  double _atlasWidth = 1024; // Дефолтный размер
  double _atlasHeight = 1024; // Дефолтный размер

  // Шейдеры
  static const String _vertexShaderSource = '''
    #version 300 es

    layout(location = 0) in vec2 a_position;      // x, y
    layout(location = 1) in vec4 a_instanceRect;  // x, y, width, height
    layout(location = 2) in vec4 a_uvRect;        // x, y, width, height in atlas
    layout(location = 3) in vec4 a_colorEffect;   // gamma, alpha, hue, saturation

    uniform vec3 u_camera;        // x, y, zoom
    uniform vec2 u_resolution;    // width, height
    uniform vec2 u_atlasSize;     // Размер атласа

    out vec2 v_texCoord;          // Texture coordinates
    out vec4 v_colorEffect;       // Color effects

    void main() {
        // Compute world position of the vertex in the instance
        vec2 instancePos = a_instanceRect.xy;
        vec2 instanceSize = a_instanceRect.zw;

        // Apply camera position and zoom
        vec2 worldPos = (instancePos + a_position * instanceSize - u_camera.xy) * u_camera.z;

        // Calculate clip space
        vec2 clipSpace = (worldPos / u_resolution) * 2.0 - 1.0;
        gl_Position = vec4(clipSpace * vec2(1, -1), 0, 1);

        // Calculate texture coordinates
        // Нормализация UV-координат с учетом реального размера атласа
        vec2 uvPos = a_uvRect.xy / u_atlasSize;
        vec2 uvSize = a_uvRect.zw / u_atlasSize;
        v_texCoord = uvPos + a_position * uvSize;

        v_colorEffect = a_colorEffect;
    }
  ''';

  // Расширенный fragment shader с поддержкой цветовых эффектов
  static const String _fragmentShaderSource = '''
    #version 300 es
    precision highp float;

    uniform sampler2D u_atlas;

    in vec2 v_texCoord;
    in vec4 v_colorEffect;

    out vec4 outColor;

    // RGB to HSV conversion function
    vec3 rgb2hsv(vec3 c)
    {
        vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
        vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
        vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

        float d = q.x - min(q.w, q.y);
        float e = 1.0e-10;
        return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
    }

    // HSV to RGB conversion function
    vec3 hsv2rgb(vec3 c)
    {
        vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
        vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
        return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
    }

    void main() {
        vec4 texColor = texture(u_atlas, v_texCoord);

        // Apply color effects
        float gamma = v_colorEffect.x;
        float alpha = v_colorEffect.y;
        float hue = v_colorEffect.z;
        float saturation = v_colorEffect.w;

        // Gamma correction
        vec3 corrected = pow(texColor.rgb, vec3(1.0 / gamma));

        // Цветовая трансформация
        vec3 hsvColor = rgb2hsv(corrected);
        hsvColor.x += hue;  // Сдвиг оттенка
        hsvColor.y *= saturation;  // Изменение насыщенности
        vec3 finalColor = hsv2rgb(hsvColor);

        outColor = vec4(finalColor, texColor.a * alpha);
    }
  ''';

  void _initShaders() {
    // Создание и компиляция шейдеров
    final vertexShader = _createShader(web.WebGL2RenderingContext.VERTEX_SHADER, _vertexShaderSource);
    final fragmentShader = _createShader(web.WebGL2RenderingContext.FRAGMENT_SHADER, _fragmentShaderSource);

    // Создание программы
    final program = _gl.createProgram();

    if (program == null) throw Exception('Ошибка создания программы');

    _program = program;

    _gl
      ..attachShader(program, vertexShader)
      ..attachShader(program, fragmentShader)
      ..linkProgram(program);

    // ВАЖНАЯ ПРОВЕРКА: Используем getProgramParameter с правильной константой
    final linkStatus = _gl.getProgramParameter(program, web.WebGL2RenderingContext.LINK_STATUS);

    if (linkStatus.isUndefinedOrNull || linkStatus.not.toDart) {
      // Получаем информацию об ошибке линковки
      final infoLog = _gl.getProgramInfoLog(program);

      // Удаляем программу во избежание утечек
      _gl.deleteProgram(program);

      throw Exception('Ошибка линковки программы: $infoLog');
    }

    // Можно также добавить валидацию программы
    _gl.validateProgram(program);
    final validateStatus = _gl.getProgramParameter(program, web.WebGL2RenderingContext.VALIDATE_STATUS);

    if (validateStatus.isUndefinedOrNull || validateStatus.not.toDart) {
      final validateInfoLog = _gl.getProgramInfoLog(program);
      throw Exception('Ошибка валидации программы: $validateInfoLog');
    }
  }

  void _initBuffers() {
    // Создаем базовый квад
    final quadVertices = Float32List.fromList([
      0, 0, // верхний левый
      1, 0, // верхний правый
      0, 1, // нижний левый
      1, 1, // нижний правый
    ]).toJS;

    final quadBuffer = _gl.createBuffer();
    if (quadBuffer == null) throw Exception('Ошибка создания буфера');
    _quadBuffer = quadBuffer;

    _gl
      ..bindBuffer(web.WebGL2RenderingContext.ARRAY_BUFFER, quadBuffer)
      ..bufferData(web.WebGL2RenderingContext.ARRAY_BUFFER, quadVertices, web.WebGL2RenderingContext.STATIC_DRAW);

    // Создаем буферы для инстансов
    final instanceBuffer = _gl.createBuffer();
    if (instanceBuffer == null) throw Exception('Ошибка создания буфера');
    _instanceBuffer = instanceBuffer;

    final colorBuffer = _gl.createBuffer();
    if (colorBuffer == null) throw Exception('Ошибка создания буфера');
    _colorBuffer = colorBuffer;

    final uvBuffer = _gl.createBuffer();
    if (uvBuffer == null) throw Exception('Ошибка создания буфера');
    _uvBuffer = uvBuffer;
  }

  /// Set the atlas texture from bytes.
  ///
  /// For example:
  /// ```dart
  ///   final response = await http.get(Uri.base.resolve('atlas.png'));
  ///   if (response.statusCode != 200) throw Exception('Failed to load skills atlas: ${response.statusCode}');
  ///   await painter._setAtlasFromBytes(response.bodyBytes, 'image/png');
  /// ```
  Future<void> _setAtlasFromBytes(
    Uint8List bytes,
    String type, {
    bool mipmap = false,
    double width = 1024,
    double height = 1024,
  }) async {
    final atlasTexture = _gl.createTexture();
    if (atlasTexture == null) throw Exception('Ошибка создания текстуры');
    _atlasTexture = atlasTexture;

    _atlasWidth = width;
    _atlasHeight = height;

    final blob = web.Blob(<JSUint8Array>[bytes.toJS].toJS, web.BlobPropertyBag(type: type));

    final blobUrl = web.URL.createObjectURL(blob);

    try {
      final imageBitmap = await web.window.createImageBitmap(blob).toDart;

      _gl
        ..bindTexture(web.WebGL2RenderingContext.TEXTURE_2D, atlasTexture)

        // Установка параметров текстуры для пиксель-арта
        ..texParameteri(
          web.WebGL2RenderingContext.TEXTURE_2D,
          web.WebGL2RenderingContext.TEXTURE_MIN_FILTER,
          mipmap ? web.WebGL2RenderingContext.LINEAR_MIPMAP_LINEAR : web.WebGL2RenderingContext.NEAREST,
        )
        ..texParameteri(
          web.WebGL2RenderingContext.TEXTURE_2D,
          web.WebGL2RenderingContext.TEXTURE_MAG_FILTER,
          web.WebGL2RenderingContext.NEAREST,
        )
        ..texParameteri(
          web.WebGL2RenderingContext.TEXTURE_2D,
          web.WebGL2RenderingContext.TEXTURE_WRAP_S,
          web.WebGL2RenderingContext.CLAMP_TO_EDGE,
        )
        ..texParameteri(
          web.WebGL2RenderingContext.TEXTURE_2D,
          web.WebGL2RenderingContext.TEXTURE_WRAP_T,
          web.WebGL2RenderingContext.CLAMP_TO_EDGE,
        )

        // Загрузка изображения в текстуру
        ..texImage2D(
          web.WebGL2RenderingContext.TEXTURE_2D,
          0,
          web.WebGL2RenderingContext.RGBA,
          web.WebGL2RenderingContext.RGBA.toJS,
          web.WebGL2RenderingContext.UNSIGNED_BYTE.toJS,
          imageBitmap,
        );

      if (mipmap) _gl.generateMipmap(web.WebGL2RenderingContext.TEXTURE_2D);
    } finally {
      web.URL.revokeObjectURL(blobUrl);
    }
  }

  /// Set the atlas texture from an html image.
  ///
  /// For example:
  /// ```dart
  ///   final atlasImage = html.ImageElement();
  ///   atlasImage.src = 'atlas.png';
  ///   atlasImage.onLoad.listen((_) {
  ///     painter._setAtlasTexture(atlasImage);
  ///   });
  /// ```
  void _setAtlasFromImage(
    web.HTMLImageElement image, {
    bool mipmap = false,
  }) {
    final atlasTexture = _gl.createTexture();
    if (atlasTexture == null) throw Exception('Ошибка создания текстуры');
    _atlasTexture = atlasTexture;

    _atlasWidth = image.width.toDouble();
    _atlasHeight = image.height.toDouble();

    _gl
      ..bindTexture(web.WebGL2RenderingContext.TEXTURE_2D, atlasTexture)

      // Установка параметров текстуры для пиксель-арта
      ..texParameteri(
        web.WebGL2RenderingContext.TEXTURE_2D,
        web.WebGL2RenderingContext.TEXTURE_MIN_FILTER,
        mipmap ? web.WebGL2RenderingContext.LINEAR_MIPMAP_LINEAR : web.WebGL2RenderingContext.NEAREST,
      )
      ..texParameteri(
        web.WebGL2RenderingContext.TEXTURE_2D,
        web.WebGL2RenderingContext.TEXTURE_MAG_FILTER,
        web.WebGL2RenderingContext.NEAREST,
      )
      ..texParameteri(
        web.WebGL2RenderingContext.TEXTURE_2D,
        web.WebGL2RenderingContext.TEXTURE_WRAP_S,
        web.WebGL2RenderingContext.CLAMP_TO_EDGE,
      )
      ..texParameteri(
        web.WebGL2RenderingContext.TEXTURE_2D,
        web.WebGL2RenderingContext.TEXTURE_WRAP_T,
        web.WebGL2RenderingContext.CLAMP_TO_EDGE,
      )

      // Загрузка изображения в текстуру
      ..texImage2D(
        web.WebGL2RenderingContext.TEXTURE_2D,
        0,
        web.WebGL2RenderingContext.RGBA,
        web.WebGL2RenderingContext.RGBA.toJS,
        web.WebGL2RenderingContext.UNSIGNED_BYTE.toJS,
        image,
      );

    if (mipmap) _gl.generateMipmap(web.WebGL2RenderingContext.TEXTURE_2D);
  }

  @override
  void draw(
    Float32List instanceRects, // x, y, width, height для каждого спрайта
    Float32List atlasRects, // x, y, width, height в атласе
    Float32List colorEffects, // gamma, alpha для каждого спрайта
    Float32List camera, // x, y, zoom
    Float32List resolution, // width, height экрана
  ) {
    final instanceCount = instanceRects.length ~/ 4;

    assert(instanceCount * 4 == instanceRects.length, 'Неверное количество элементов в instanceRects');
    assert(instanceCount * 4 == atlasRects.length, 'Неверное количество элементов в atlasRects');
    assert(instanceCount * 4 == colorEffects.length, 'Неверное количество элементов в colorEffects');
    assert(camera.length == 3, 'Неверное количество элементов в camera');
    assert(resolution.length == 2, 'Неверное количество элементов в resolution');

    _gl.useProgram(_program);

    // Установка uniform переменных
    final cameraLoc = _gl.getUniformLocation(_program, 'u_camera');
    final resolutionLoc = _gl.getUniformLocation(_program, 'u_resolution');
    final atlasSizeLoc = _gl.getUniformLocation(_program, 'u_atlasSize');

    _gl
      ..uniform3fv(cameraLoc, camera.toJS)
      ..uniform2fv(resolutionLoc, resolution.toJS)
      ..uniform2f(atlasSizeLoc, _atlasWidth, _atlasHeight)

      // Привязка текстуры
      ..activeTexture(web.WebGL2RenderingContext.TEXTURE0)
      ..bindTexture(web.WebGL2RenderingContext.TEXTURE_2D, _atlasTexture)
      ..uniform1i(_gl.getUniformLocation(_program, 'u_atlas'), 0)

      // Настройка атрибутов
      // 1. Позиции вершин квада
      ..bindBuffer(web.WebGL2RenderingContext.ARRAY_BUFFER, _quadBuffer)
      ..enableVertexAttribArray(0)
      ..vertexAttribPointer(0, 2, web.WebGL2RenderingContext.FLOAT, false, 0, 0)

      // 2. Данные инстансов
      ..bindBuffer(web.WebGL2RenderingContext.ARRAY_BUFFER, _instanceBuffer)
      ..bufferData(
        web.WebGL2RenderingContext.ARRAY_BUFFER,
        instanceRects.toJS,
        web.WebGL2RenderingContext.DYNAMIC_DRAW,
      )
      ..enableVertexAttribArray(1)
      ..vertexAttribPointer(1, 4, web.WebGL2RenderingContext.FLOAT, false, 0, 0)
      ..vertexAttribDivisor(1, 1)

      // 3. UV координаты
      ..bindBuffer(web.WebGL2RenderingContext.ARRAY_BUFFER, _uvBuffer)
      ..bufferData(
        web.WebGL2RenderingContext.ARRAY_BUFFER,
        atlasRects.toJS,
        web.WebGL2RenderingContext.DYNAMIC_DRAW,
      )
      ..enableVertexAttribArray(2)
      ..vertexAttribPointer(2, 4, web.WebGL2RenderingContext.FLOAT, false, 0, 0)
      ..vertexAttribDivisor(2, 1)

      // 4. Цветовые эффекты
      ..bindBuffer(web.WebGL2RenderingContext.ARRAY_BUFFER, _colorBuffer)
      ..bufferData(
        web.WebGL2RenderingContext.ARRAY_BUFFER,
        colorEffects.toJS,
        web.WebGL2RenderingContext.DYNAMIC_DRAW,
      )
      ..enableVertexAttribArray(3)
      ..vertexAttribPointer(3, 4, web.WebGL2RenderingContext.FLOAT, false, 0, 0)
      ..vertexAttribDivisor(3, 1)

      // Включаем смешивание для прозрачности
      ..enable(web.WebGL2RenderingContext.BLEND)
      ..blendFunc(web.WebGL2RenderingContext.SRC_ALPHA, web.WebGL2RenderingContext.ONE_MINUS_SRC_ALPHA)

      // Отрисовка
      ..drawArraysInstanced(web.WebGL2RenderingContext.TRIANGLE_STRIP, 0, 4, instanceCount)

      // Отключаем атрибуты
      ..disableVertexAttribArray(0)
      ..disableVertexAttribArray(1)
      ..disableVertexAttribArray(2)
      ..disableVertexAttribArray(3);
  }

  web.WebGLShader _createShader(int type, String source) {
    final shader = _gl.createShader(type);

    if (shader == null || shader.isUndefinedOrNull)
      throw Exception(
          'Ошибка создания ${type == web.WebGL2RenderingContext.VERTEX_SHADER ? "vertex" : "fragment"} шейдера');

    _gl
      ..shaderSource(shader, source)
      ..compileShader(shader);

    if (_gl.getShaderParameter(shader, web.WebGL2RenderingContext.COMPILE_STATUS).isUndefinedOrNull)
      throw Exception(
          'Ошибка компиляции ${type == web.WebGL2RenderingContext.VERTEX_SHADER ? "vertex" : "fragment"} шейдера: '
          '${_gl.getShaderInfoLog(shader)}');

    return shader;
  }

  @override
  void dispose() {
    _gl
      ..deleteProgram(_program)
      ..deleteBuffer(_quadBuffer)
      ..deleteBuffer(_instanceBuffer)
      ..deleteBuffer(_colorBuffer)
      ..deleteBuffer(_uvBuffer)
      ..deleteTexture(_atlasTexture);
  }
}
