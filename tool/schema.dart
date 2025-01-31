import 'dart:async';
import 'dart:io' as io;

/// Generate protobuf schema for the roadmap.
/// $ dart run tool/schema.dart
void main([List<String>? arguments]) => runZonedGuarded<void>(() async {
      protoc();
    }, (error, stackTrace) {
      io.stderr
        ..writeln(error)
        ..writeln(stackTrace)
        ..flush();
      io.exit(1);
    });

void protoc() {
  final currentDir = io.Directory.current;
  void output(io.ProcessResult result) {
    if (result.stdout != null) {
      io.stdout
        ..writeln(result.stdout)
        ..flush();
    }
    if (result.stderr != null) {
      io.stderr
        ..write(result.stderr)
        ..flush();
    }
  }

  final activateResult = io.Process.runSync(
    'dart',
    [
      'pub',
      'global',
      'activate',
      'protoc_plugin',
    ],
    workingDirectory: currentDir.path,
  );
  switch (activateResult.exitCode) {
    case > 0:
      output(activateResult);
      io.exit(activateResult.exitCode);
  }
  final genResult = io.Process.runSync(
    'protoc',
    [
      '--proto_path=packages/shared/lib/src/protobuf',
      '--dart_out=packages/shared/lib/src/protobuf',
      'packages/shared/lib/src/protobuf/roadmap.proto',
    ],
    workingDirectory: currentDir.path,
  );
  switch (genResult.exitCode) {
    case 0:
      // Rename the generated file.
      /* final generatedFile = io.Directory(p.join(
        currentDir.path,
        'lib/src/roadmap/codec',
      )).listSync(recursive: false, followLinks: false).firstWhere((file) => file.path.endsWith('_generated.dart'));
      generatedFile.renameSync(p.join(
        currentDir.path,
        'lib/src/roadmap/codec/roadmap_codec.fb.g.dart',
      )); */
      return;
    default:
      output(genResult);
      io.exit(genResult.exitCode);
  }
}
