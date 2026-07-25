// Renders the real screens to docs/screenshots/ so the README shows the app as
// it is, not as it is described. Named without the _test suffix so a bare
// `flutter test` never collects it — run it by hand when the UI changes.
//
//   flutter test test/tool/screenshots.dart --update-goldens
//
// Everything is seeded in memory: no shared_preferences on disk, no Keychain,
// no notifications, no network. Videos are never played, only listed.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/app/root_scaffold.dart';
import 'package:help_me/app/theme/app_theme.dart';
import 'package:help_me/core/widgets/app_nav_bar.dart';
import 'package:help_me/features/conditions/data/first_aid_data.dart';
import 'package:help_me/features/conditions/presentation/condition_detail_screen.dart';
import 'package:help_me/l10n/app_localizations.dart';
import 'package:help_me/providers/health_provider.dart';
import 'package:help_me/providers/preferences.dart';
import 'package:help_me/services/reminder_service.dart';
import 'package:help_me/services/secure_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A phone-shaped canvas at 2x, close to a 390pt-wide device.
const Size _phone = Size(780, 1560);

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final FontLoader loader = FontLoader(family);
    var any = false;
    for (final String path in paths) {
      final File file = File(path);
      if (!file.existsSync()) continue;
      any = true;
      loader.addFont(
        file.readAsBytes().then((Uint8List b) => ByteData.view(b.buffer)),
      );
    }
    if (any) await loader.load();
  }

  // Walk up from the dart binary (…/bin/cache/dart-sdk/bin/dart) until the
  // bundled icon font turns up, rather than hard-coding a depth that changes
  // between Flutter versions.
  String? icons;
  Directory dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 6 && icons == null; i++) {
    final String candidate =
        '${dir.path}/artifacts/material_fonts/MaterialIcons-Regular.otf';
    if (File(candidate).existsSync()) icons = candidate;
    dir = dir.parent;
  }
  if (icons == null) {
    throw StateError('MaterialIcons font not found — screenshots would show '
        'empty boxes instead of icons.');
  }
  await load('MaterialIcons', <String>[icons]);
  await load('Cairo', <String>[
    'assets/fonts/Cairo-Regular.ttf',
    'assets/fonts/Cairo-Medium.ttf',
    'assets/fonts/Cairo-SemiBold.ttf',
    'assets/fonts/Cairo-Bold.ttf',
    'assets/fonts/Cairo-ExtraBold.ttf',
  ]);
}

Future<void> _shoot(
  WidgetTester tester,
  Widget home, {
  required String name,
  required ThemeData theme,
  required Locale locale,
  int tab = 0,
}) async {
  tester.view.physicalSize = _phone;
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);

  // The disclaimer sheet is a first-launch event; these shots show the app in
  // its settled state, so mark it accepted.
  SharedPreferences.setMockInitialValues(<String, Object>{
    'settings.disclaimer_accepted': true,
  });
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      sharedPreferencesProvider.overrideWithValue(prefs),
      secureStoreProvider.overrideWithValue(InMemorySecureStore()),
      healthSnapshotProvider.overrideWithValue(const HealthSnapshot()),
      remindersProvider.overrideWithValue(FakeReminders()),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: theme,
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();

  if (tab > 0) {
    // Labels shift with locale and the selected slot is wider than the rest,
    // so tap the nth tappable region rather than an nth of the bar's width.
    // Widget order follows the item list, not the visual order, so this is
    // also correct under RTL.
    final Finder slots = find.descendant(
      of: find.byType(AppNavBar),
      matching: find.byType(InkWell),
    );
    expect(slots, findsNWidgets(5), reason: 'nav bar slots for $name');
    await tester.tap(slots.at(tab));
    await tester.pumpAndSettle();
  }

  // Widget tests fake out the clock and the I/O loop, so bundled photographs
  // never finish decoding and would shoot as empty placeholders. runAsync gives
  // them a real event loop for long enough to land in the image cache.
  await tester.runAsync(() async {
    for (final Element element in find.byType(Image).evaluate()) {
      await precacheImage((element.widget as Image).image, element);
    }
  });
  await tester.pumpAndSettle();

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../docs/screenshots/$name.png'),
  );
}

void main() {
  setUpAll(_loadFonts);

  const Locale en = Locale('en');
  const Locale ar = Locale('ar');

  testWidgets('home — light, English', (WidgetTester tester) async {
    await _shoot(
      tester,
      const RootScaffold(),
      name: 'home_light_en',
      theme: AppTheme.light,
      locale: en,
    );
  });

  testWidgets('home — dark, Arabic', (WidgetTester tester) async {
    await _shoot(
      tester,
      const RootScaffold(),
      name: 'home_dark_ar',
      theme: AppTheme.dark,
      locale: ar,
    );
  });

  testWidgets('learn — light, English', (WidgetTester tester) async {
    await _shoot(
      tester,
      const RootScaffold(),
      name: 'learn_light_en',
      theme: AppTheme.light,
      locale: en,
      tab: 1,
    );
  });

  testWidgets('emergency — dark, Arabic', (WidgetTester tester) async {
    await _shoot(
      tester,
      const RootScaffold(),
      name: 'emergency_dark_ar',
      theme: AppTheme.dark,
      locale: ar,
      tab: 2,
    );
  });

  testWidgets('health — light, English', (WidgetTester tester) async {
    await _shoot(
      tester,
      const RootScaffold(),
      name: 'health_light_en',
      theme: AppTheme.light,
      locale: en,
      tab: 3,
    );
  });

  testWidgets('condition detail — CPR, light, English', (
    WidgetTester tester,
  ) async {
    await _shoot(
      tester,
      ConditionDetailScreen(topic: topicById('cpr')!),
      name: 'condition_cpr_light_en',
      theme: AppTheme.light,
      locale: en,
    );
  });

  testWidgets('condition detail — bleeding, dark, Arabic', (
    WidgetTester tester,
  ) async {
    await _shoot(
      tester,
      ConditionDetailScreen(topic: topicById('bleeding')!),
      name: 'condition_bleeding_dark_ar',
      theme: AppTheme.dark,
      locale: ar,
    );
  });
}
