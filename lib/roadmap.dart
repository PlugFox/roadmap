import 'dart:async';

import 'package:l/l.dart';
import 'package:roadmap/src/app.dart' deferred as app;
import 'package:roadmap/src/core/engine.dart';
import 'package:roadmap/src/layers/clock_layer.dart';

/*
final now = DateTime.now();
final element = document.querySelector('#output') as HTMLElement
  ..text = 'The time is ${now.hour}:${now.minute} '
      'and your Dart web app is running!';
Timer.periodic(const Duration(seconds: 1), (timer) {
  final now = DateTime.now();
  element.text = 'The time is ${now.hour}:${now.minute}:${now.second} '
      'and your Dart web app is running!';
}); */

void main() => l.capture(
      () => runZonedGuarded<void>(
        () async {
          // Initialization ...
          // Skills ...
          // Minimap ...
          // UI Search ...
          // UI Buttons ...
          // UI Tooltips ...
          // UI Skill ...

          final _ = RenderingEngine.instance..start();
          l.i('Engine started');
          await _initialize();
          await app.loadLibrary();
          app.runApp();
        },
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

Future<void> _initialize() async {
  final clock = ClockLayer();
  void setTime() {
    final DateTime(:hour, :minute, :second) = DateTime.now();
    clock.setTime(hour: hour, minute: minute, second: second);
  }

  setTime();
  final timer = Timer.periodic(const Duration(seconds: 1), (_) => setTime());

  RenderingEngine.instance.addLayer(clock);
  await Future<void>.delayed(const Duration(milliseconds: 50));
  timer.cancel(); // Stop the clock
  RenderingEngine.instance.removeLayer(clock);
}
