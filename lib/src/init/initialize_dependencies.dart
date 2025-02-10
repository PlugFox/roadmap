import 'dart:async';

import 'package:http/http.dart' as http_lib;
import 'package:l/l.dart';
import 'package:platform_info/platform_info.dart';
import 'package:roadmap/src/core/pubspec.yaml.g.dart';
import 'package:roadmap/src/init/app_metadata.dart';
import 'package:roadmap/src/init/app_migrator.dart';
import 'package:roadmap/src/init/dependencies.dart';
import 'package:roadmap/src/init/platform/platform_initialization.dart';
import 'package:web/web.dart';

/// Initializes the app and returns a [Dependencies] object
Future<Dependencies> $initializeDependencies({
  void Function(int progress, String message)? onProgress,
}) async {
  final dependencies = Dependencies();
  final totalSteps = _initializationSteps.length;
  var currentStep = 0;
  for (final step in _initializationSteps.entries) {
    try {
      currentStep++;
      final percent = (currentStep * 100 ~/ totalSteps).clamp(0, 100);
      onProgress?.call(percent, step.key);
      l.v6('Initialization | $currentStep/$totalSteps ($percent%) | "${step.key}"');
      await step.value(dependencies);
    } on Object catch (error, stackTrace) {
      l.e('Initialization failed at step "${step.key}": $error', stackTrace);
      Error.throwWithStackTrace('Initialization failed at step "${step.key}": $error', stackTrace);
    }
  }
  return dependencies;
}

typedef _InitializationStep = FutureOr<void> Function(Dependencies dependencies);
final Map<String, _InitializationStep> _initializationSteps = <String, _InitializationStep>{
  'Platform pre-initialization': (_) => $platformInitialization(),
  'Creating app metadata': (dependencies) => dependencies.metadata = AppMetadata(
        isWeb: platform.js,
        isRelease: platform.buildMode.release,
        appName: Pubspec.name,
        appVersion: Pubspec.version.representation,
        appVersionMajor: Pubspec.version.major,
        appVersionMinor: Pubspec.version.minor,
        appVersionPatch: Pubspec.version.patch,
        appBuildTimestamp:
            Pubspec.version.build.isNotEmpty ? (int.tryParse(Pubspec.version.build.firstOrNull ?? '-1') ?? -1) : -1,
        operatingSystem: platform.operatingSystem.name,
        processorsCount: platform.numberOfProcessors,
        appLaunchedTimestamp: DateTime.now(),
        locale: platform.locale,
        deviceVersion: platform.version,
        deviceScreenSize: '${window.screen.width}x${window.screen.height}',
      ),
  'Initializing analytics': (_) {},
  'Log app open': (_) {},
  'Get remote config': (_) {},
  'Restore settings': (_) {},
  'Receive storage': (dependencies) async => dependencies.storage = window.localStorage,
  'Migrate app from previous version': (dependencies) => AppMigrator.migrate(dependencies.storage),
  'Initialize HTTP client': (dependencies) => dependencies.http = http_lib.Client(),
  'Load roadmap data': (dependencies) async {},
  'Decode roadmap data': (dependencies) async {
    /* final bytes = await AssetsUtil.loadBytes('assets/roadmap/roadmap.bin');
    final roadmap = roadmapCodec.decode(bytes.buffer.asUint8List());
    dependencies.roadmap = roadmap; */
  },
  'Receive roadmap atlas': (dependencies) async {
    /* final atlas = await AssetsUtil.loadImage('assets/roadmap/atlas.webp');
    dependencies.atlas = atlas; */
  },
  'Initialize localization': (_) {},
  'Log app initialized': (_) {},
};
