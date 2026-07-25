import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/splash/splash_screen.dart';
import '../l10n/app_localizations.dart';
import '../providers/reminder_sync_provider.dart';
import '../providers/settings_provider.dart';
import 'theme/app_theme.dart';

/// Root widget: wires theme, locale (with Arabic as the default fallback) and
/// the initial splash route.
class HelpMeApp extends ConsumerStatefulWidget {
  const HelpMeApp({super.key});

  @override
  ConsumerState<HelpMeApp> createState() => _HelpMeAppState();
}

class _HelpMeAppState extends ConsumerState<HelpMeApp> {
  @override
  void initState() {
    super.initState();
    // Top up the reminder schedule on every launch: daily tips are only booked a
    // week ahead, and a reinstall or a restored backup starts with none at all.
    // No permission is requested here — that only happens where the user asks
    // for a reminder.
    Future<void>.microtask(() => ref.read(reminderSyncProvider).rebuildAll());
  }

  @override
  Widget build(BuildContext context) {
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
