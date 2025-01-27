import 'dart:js_interop';

import 'package:roadmap/src/core/engine.dart';
import 'package:roadmap/src/layers/clock_layer.dart';
import 'package:web/web.dart';

void runApp() {
  // Check if document is already complete
  if (document.readyState == 'complete') {
    _initialize();
  } else {
    // Wait for document to be ready
    document.onreadystatechange = _initialize.toJS;
  }
}

void _initialize() {
  /* final now = DateTime.now();
  final element = document.querySelector('#output') as HTMLElement
    ..text = 'The time is ${now.hour}:${now.minute} '
        'and your Dart web app is running!';
  Timer.periodic(const Duration(seconds: 1), (timer) {
    final now = DateTime.now();
    element.text = 'The time is ${now.hour}:${now.minute}:${now.second} '
        'and your Dart web app is running!';
  }); */

  final engine = RenderingEngine.instance
    ..addLayer(ClockLayer())
    ..start();

  // Initialization ...
  // Skills ...
  // Minimap ...
  // UI Search ...
  // UI Buttons ...
  // UI Tooltips ...
  // UI Skill ...
}
