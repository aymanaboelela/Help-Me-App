import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/splash/splash_screen.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import 'theme/app_theme.dart';

/// Root widget: wires theme, locale (with Arabic as the default fallback) and
/// the initial splash route.
class HelpMeApp extends ConsumerWidget {
  const HelpMeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings settings = ref.watch(settingsProvider);

    return MaterialApp(
      onGenerateTitle: (BuildContext context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeResolutionCallback: (Locale? deviceLocale, Iterable<Locale> supported) {
        if (deviceLocale != null) {
          for (final Locale locale in supported) {
            if (locale.languageCode == deviceLocale.languageCode) return locale;
          }
        }
        return const Locale('ar');
      },
      home: const SplashScreen(),
    );
  }
}
