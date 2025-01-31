import 'package:roadmap/src/core/engine.dart';
import 'package:roadmap/src/layers/camera_layer.dart';
import 'package:roadmap/src/layers/skills_layer.dart';

void runApp() => Future<void>(() async {
      final engine = RenderingEngine.instance;
      final camera = engine.context.camera;
      final skillsLayer = SkillsLayer(camera: camera); // Root layer of the skills roadmap
      final cameraLayer = CameraLayer(); // Camera layer for panning and zooming
      engine
        ..addLayer(skillsLayer)
        ..addLayer(cameraLayer);
      await Future<void>.delayed(const Duration(seconds: 5));
    });
