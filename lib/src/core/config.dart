/// Config for app.
abstract final class Config {
  // --- Key storage namespace --- //

  /// Namespace for all version keys
  static const String storageNamespace = 'keys';

  /// Keys for storing the current version of the app
  static const String versionMajorKey = '$storageNamespace.version.major';

  /// Keys for storing the current version of the app
  static const String versionMinorKey = '$storageNamespace.version.minor';

  /// Keys for storing the current version of the app
  static const String versionPatchKey = '$storageNamespace.version.patch';
}
