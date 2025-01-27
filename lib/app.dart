import 'dart:async';

import 'package:l/l.dart';
import 'package:roadmap/src/core/engine.dart';
import 'package:roadmap/src/layers/clock_layer.dart';

void runApp() => l.capture(
      () => runZonedGuarded<void>(
        _initialize,
        l.e,
      ),
      LogOptions(
        outputInRelease: true,
        handlePrint: true,
        printColors: false,
        output: LogOutput.platform,
        overrideOutput: (message) => '[${message.level}] ${message.message}',
        messageFormatting: (message) => message,
      ),
    );

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

  l.i('Engine started');

  // Initialization ...
  // Skills ...
  // Minimap ...
  // UI Search ...
  // UI Buttons ...
  // UI Tooltips ...
  // UI Skill ...
}
