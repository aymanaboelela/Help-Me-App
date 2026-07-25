/// App-wide constants that a maintainer may need to update for the stores.
abstract final class AppConfig {
  /// Displayed in the About screen; keep in sync with `pubspec.yaml` `version`.
  static const String version = '2.0.0';

  /// Android application id (also the Play Store listing id).
  static const String androidPackageId = 'com.helpme.help';

  /// Apple App Store numeric id — set this after registering in App Store
  /// Connect so in-app review can open the store listing on iOS.
  static const String appStoreId = '';
}
