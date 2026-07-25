import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/app/root_scaffold.dart';
import 'package:help_me/app/theme/app_theme.dart';
import 'package:help_me/features/conditions/data/first_aid_data.dart';
import 'package:help_me/features/conditions/model/first_aid_topic.dart';
import 'package:help_me/features/conditions/presentation/condition_detail_screen.dart';
import 'package:help_me/features/emergency/presentation/emergency_screen.dart';
import 'package:help_me/features/health/presentation/health_screen.dart';
import 'package:help_me/features/learn/presentation/learn_screen.dart';
import 'package:help_me/features/settings/presentation/settings_screen.dart';
import 'package:help_me/l10n/app_localizations.dart';
import 'package:help_me/providers/health_provider.dart';
import 'package:help_me/providers/preferences.dart';
import 'package:help_me/services/reminder_service.dart';
import 'package:help_me/services/secure_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Renders every main screen to an image so the way the app looks can be
/// reviewed directly instead of guessed at. Regenerate with
/// `flutter test test/screens_golden_test.dart --update-goldens`.

/// Loads the real text and icon fonts, so a golden shows what a user would see
/// rather than a grid of tofu boxes.
///
/// Throws rather than silently rendering empty squares: a golden reviewed with
/// missing glyphs is worse than no golden, because it looks like a finding.
Future<void> loadAppFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final FontLoader loader = FontLoader(family);
    bool found = false;
    for (final String path in paths) {
      final File file = File(path);
      if (!file.existsSync()) continue;
      found = true;
      loader.addFont(
        file.readAsBytes().then((Uint8List b) => ByteData.view(b.buffer)),
      );
    }
    if (!found) {
      throw StateError('No font file found for $family in: ${paths.join(", ")}');
    }
    await loader.load();
  }

  final String sdk = File(Platform.resolvedExecutable).parent.parent.path;
  final String home = Platform.environment['HOME'] ?? '';
  await load('MaterialIcons', <String>[
    '$sdk/artifacts/material_fonts/MaterialIcons-Regular.otf',
    '$home/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]);
  await load('Cairo', <String>[
    'assets/fonts/Cairo-Regular.ttf',
    'assets/fonts/Cairo-Medium.ttf',
    'assets/fonts/Cairo-SemiBold.ttf',
    'assets/fonts/Cairo-Bold.ttf',
    'assets/fonts/Cairo-ExtraBold.ttf',
  ]);
}

/// Renders [child] inside a fully-overridden [ProviderScope] and writes it to
/// `goldens/screens/<name>.png`.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget child,
  String name, {
  required ThemeData theme,
  Locale locale = const Locale('en'),
  TargetPlatform platform = TargetPlatform.android,
}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  // Without this the one-time disclaimer sheet covers every screen.
  SharedPreferences.setMockInitialValues(<String, Object>{
    'settings.disclaimer_accepted': true,
  });
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        sharedPreferencesProvider.overrideWithValue(prefs),
        secureStoreProvider.overrideWithValue(InMemorySecureStore()),
        remindersProvider.overrideWithValue(FakeReminders()),
        healthSnapshotProvider.overrideWithValue(const HealthSnapshot()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: theme.copyWith(platform: platform),
        home: child,
      ),
    ),
  );

  // Two explicit pumps rather than pumpAndSettle: the nav bar and the gallery
  // hold indefinite implicit animations that pumpAndSettle would wait on for
  // ever.
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(seconds: 1));

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/screens/$name.png'),
  );
}

void main() {
  setUpAll(loadAppFonts);

  final FirstAidTopic topic = kFirstAidTopics.first;

  final List<(String, Widget)> screens = <(String, Widget)>[
    ('home', const RootScaffold()),
    ('emergency', const EmergencyScreen()),
    ('learn', const LearnScreen()),
    ('health', const HealthScreen()),
    ('settings', const SettingsScreen()),
    ('detail', ConditionDetailScreen(topic: topic)),
  ];

  for (final (String name, Widget screen) in screens) {
    testWidgets('$name — light', (WidgetTester tester) async {
      await pumpScreen(tester, screen, '${name}_light', theme: AppTheme.light);
    });

    testWidgets('$name — dark', (WidgetTester tester) async {
      await pumpScreen(tester, screen, '${name}_dark', theme: AppTheme.dark);
    });

    testWidgets('$name — dark RTL', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        screen,
        '${name}_dark_ar',
        theme: AppTheme.dark,
        locale: const Locale('ar'),
      );
    });
  }
}
