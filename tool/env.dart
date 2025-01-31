import 'dart:collection';
import 'dart:io' as io;

/// Represents the environment variables.
extension type const Env._(Map<String, String> _map) {
  /// Returns the platform environment variables.
  factory Env.platform() {
    final map = HashMap<String, String>.of(
      <String, String>{
        for (final MapEntry<String, String>(key: String k, value: String v) in io.Platform.environment.entries)
          if (k.isNotEmpty && v.isNotEmpty) k.trim().toLowerCase(): v.trim(),
      },
    );
    return Env._(map);
  }

  /// Returns the environment variables from the given [map].
  factory Env.map(Map<String, String> map) => map.isEmpty ? const Env.empty() : Env._(HashMap<String, String>.of(map));

  /// Returns an empty environment.
  const Env.empty() : _map = const {};

  /// Returns the environment variables from the given [args].
  factory Env.args(List<String> args) {
    if (args.isEmpty) return const Env.empty();
    final map = HashMap<String, String>();
    for (final arg in args) {
      final parts = arg.split('=');
      if (parts.length == 2) {
        final [key, value] = parts;
        map[key.trim().toLowerCase()] = value.trim();
      } else if (parts.length == 1) {
        map[parts.first.trim().toLowerCase()] = '';
      }
    }
    return Env._(map);
  }

  /// Returns the environment variables from the given [path].
  factory Env.file(String path) {
    final file = io.File(path);
    if (!file.existsSync()) return const Env.empty();
    final map = HashMap<String, String>();
    for (final line in file.readAsLinesSync()) {
      final parts = line.split('=');
      if (parts.length == 2) {
        final [key, value] = parts;
        map[key.trim().toLowerCase()] = value.trim();
      } else if (parts.length == 1) {
        map[parts.first.trim().toLowerCase()] = '';
      }
    }
    return Env._(map);
  }

  /// Merge the given [envs] into a single environment.
  factory Env.merge(Iterable<Env> envs) {
    final map = HashMap<String, String>();
    for (final env in envs) {
      for (final entry in env._map.entries) {
        map[entry.key] = entry.value;
      }
    }
    return Env._(map);
  }

  /// Returns the value associated with the given [key] as a [T] or `null` if the
  /// key is not present or the value cannot be converted to [T].
  T? get<T>(String key) {
    final k = key.trim().toLowerCase();
    return switch (T) {
      const (String) => _map[k] as T?,
      const (int) => switch (_map[k]) {
          String value => int.tryParse(value) as T?,
          _ => null,
        },
      const (double) => switch (_map[k]) {
          String value => double.tryParse(value) as T?,
          _ => null,
        },
      const (num) => switch (_map[k]) {
          String value => num.tryParse(value) as T?,
          _ => null,
        },
      const (bool) => switch (_map[k]) {
          'true' || 'yes' || 'y' => true as T?,
          'false' || 'no' || 'n' => false as T?,
          _ => null,
        },
      const (List<String>) => _map[k]?.split(',') as T?,
      _ => null,
    };
  }
}
