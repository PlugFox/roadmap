import 'dart:async';

import 'package:l/l.dart';
import 'package:roadmap/src/app.dart' deferred as app;
import 'package:roadmap/src/core/engine.dart';
import 'package:roadmap/src/init/initialize_dependencies.dart';
import 'package:web/web.dart';

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
          l.d('Engine started');
          try {
            final dependencies = await $initializeDependencies(
              onProgress: (progress, message) {/* ... */},
            );
            await app.loadLibrary();
            dependencies.inject(app.runApp);
          } on Object catch (error, stackTrace) {
            l.e('Failed to initialize app: $error', stackTrace);
            window.alert('Failed to initialize app: $error');
            return;
          }
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
