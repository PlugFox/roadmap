import 'dart:async';

import 'package:http/http.dart' as http_lib;
import 'package:meta/meta.dart';
import 'package:roadmap/src/init/app_metadata.dart';
import 'package:shared/shared.dart';
import 'package:web/web.dart';

/// {@template dependencies}
/// Application dependencies.
/// {@endtemplate}
class Dependencies {
  /// {@macro dependencies}
  Dependencies();

  /// The state from the closest instance of this class.
  ///
  /// {@macro dependencies}
  factory Dependencies.zoned() => Zone.current[#dependencies] as Dependencies;

  /// Injest dependencies to the widget tree.
  void inject(void Function() fn) => runZoned(fn, zoneValues: <Object?, Object?>{#dependencies: this});

  /// App metadata
  late final AppMetadata metadata;

  /// Shared preferences
  late final Storage storage;

  /// Current immutable roadmap data to paint.
  late final Roadmap roadmap;

  /// HTTP client
  late final http_lib.Client http;

  @override
  String toString() => 'Dependencies{}';
}

/// Fake Dependencies
@visibleForTesting
class FakeDependencies extends Dependencies {
  FakeDependencies();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    // ... implement fake dependencies
    throw UnimplementedError();
  }
}
