import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'preferences.dart';

const String _kThemeKey = 'settings.theme_mode';
const String _kLocaleKey = 'settings.locale_code';
const String _kDisclaimerKey = 'settings.disclaimer_accepted';

/// Immutable snapshot of user preferences.
@immutable
class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.localeCode,
    required this.disclaimerAccepted,
  });

  final ThemeMode themeMode;

  /// `null` means "follow the system language"; otherwise `'ar'` or `'en'`.
  final String? localeCode;

  final bool disclaimerAccepted;

  Locale? get locale => localeCode == null ? null : Locale(localeCode!);
}

/// Reads and persists [AppSettings] (theme, language, disclaimer acceptance).
class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final int? themeIndex = prefs.getInt(_kThemeKey);
    final ThemeMode theme =
        (themeIndex != null && themeIndex >= 0 && themeIndex < ThemeMode.values.length)
            ? ThemeMode.values[themeIndex]
            : ThemeMode.system;
    return AppSettings(
      themeMode: theme,
      localeCode: prefs.getString(_kLocaleKey),
      disclaimerAccepted: prefs.getBool(_kDisclaimerKey) ?? false,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = AppSettings(
      themeMode: mode,
      localeCode: state.localeCode,
      disclaimerAccepted: state.disclaimerAccepted,
    );
    await ref.read(sharedPreferencesProvider).setInt(_kThemeKey, mode.index);
  }

  /// Pass `null` to follow the system language.
  Future<void> setLocaleCode(String? code) async {
    state = AppSettings(
      themeMode: state.themeMode,
      localeCode: code,
      disclaimerAccepted: state.disclaimerAccepted,
    );
    final prefs = ref.read(sharedPreferencesProvider);
    if (code == null) {
      await prefs.remove(_kLocaleKey);
    } else {
      await prefs.setString(_kLocaleKey, code);
    }
  }

  Future<void> acceptDisclaimer() async {
    state = AppSettings(
      themeMode: state.themeMode,
      localeCode: state.localeCode,
      disclaimerAccepted: true,
    );
    await ref.read(sharedPreferencesProvider).setBool(_kDisclaimerKey, true);
  }
}

final NotifierProvider<SettingsNotifier, AppSettings> settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
