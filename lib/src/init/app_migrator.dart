// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:async';
import 'dart:math';

import 'package:l/l.dart';
import 'package:roadmap/src/core/config.dart';
import 'package:roadmap/src/core/pubspec.yaml.g.dart';
import 'package:web/web.dart';

/// Migrate application when version is changed.
sealed class AppMigrator {
  static Future<void> migrate(Storage storage) async {
    try {
      int? getVersion(String key) {
        final value = storage.getItem(key);
        if (value == null) return null;
        return int.tryParse(value);
      }

      final prevMajor = getVersion(Config.versionMajorKey);
      final prevMinor = getVersion(Config.versionMinorKey);
      final prevPatch = getVersion(Config.versionPatchKey);
      if (prevMajor == null || prevMinor == null || prevPatch == null) {
        l.d('Initializing app for the first time');
        /* ... */
      } else if (Pubspec.version.major != prevMajor ||
          Pubspec.version.minor != prevMinor ||
          Pubspec.version.patch != prevPatch) {
        l.d('Migrating from $prevMajor.$prevMinor.$prevPatch to ${Pubspec.version.major}.${Pubspec.version.minor}.${Pubspec.version.patch}');
        /* ... */
      } else {
        l.d('App is up-to-date');
        return;
      }
      storage
        ..setItem(Config.versionMajorKey, Pubspec.version.major.toString())
        ..setItem(Config.versionMinorKey, Pubspec.version.minor.toString())
        ..setItem(Config.versionPatchKey, Pubspec.version.patch.toString());
    } on Object catch (error, stackTrace) {
      l.e('App migration failed: $e', stackTrace);
      rethrow;
    }
  }
}
