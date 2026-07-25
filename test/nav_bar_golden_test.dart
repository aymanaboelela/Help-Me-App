import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/app/theme/app_theme.dart';
import 'package:help_me/core/widgets/app_nav_bar.dart';

/// Renders the navigation bar to an image so its look can be reviewed directly
/// rather than guessed at. Regenerate with `flutter test --update-goldens`.
Widget _harness({
  required ThemeData theme,
  required TextDirection direction,
  required List<AppNavItem> items,
  int index = 0,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme,
    home: Directionality(
      textDirection: direction,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const SizedBox.expand(),
        bottomNavigationBar: AppNavBar(
          index: index,
          items: items,
          onSelected: (_) {},
        ),
      ),
    ),
  );
}

const List<AppNavItem> _english = <AppNavItem>[
  AppNavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
  AppNavItem(
    icon: Icons.emergency_outlined,
    activeIcon: Icons.emergency_rounded,
    label: 'Emergency',
  ),
  AppNavItem(
    icon: Icons.favorite_outline,
    activeIcon: Icons.favorite_rounded,
    label: 'Health',
  ),
  AppNavItem(
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings_rounded,
    label: 'Settings',
  ),
];

const List<AppNavItem> _arabic = <AppNavItem>[
  AppNavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'الرئيسية'),
  AppNavItem(
    icon: Icons.emergency_outlined,
    activeIcon: Icons.emergency_rounded,
    label: 'الطوارئ',
  ),
  AppNavItem(
    icon: Icons.favorite_outline,
    activeIcon: Icons.favorite_rounded,
    label: 'صحتي',
  ),
  AppNavItem(
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings_rounded,
    label: 'الإعدادات',
  ),
];

/// Loads the real icon and text fonts so the rendered image is what a user
/// would actually see, not a grid of tofu boxes.
Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final FontLoader loader = FontLoader(family);
    for (final String path in paths) {
      final File file = File(path);
      if (!file.existsSync()) continue;
      loader.addFont(
        file.readAsBytes().then((Uint8List b) => ByteData.view(b.buffer)),
      );
    }
    await loader.load();
  }

  final String flutterRoot = File(Platform.resolvedExecutable).parent.parent.path;
  await load('MaterialIcons', <String>[
    '$flutterRoot/artifacts/material_fonts/MaterialIcons-Regular.otf',
    '/Users/cairocamerarentals/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]);
  await load('Cairo', <String>[
    'assets/fonts/Cairo-Regular.ttf',
    'assets/fonts/Cairo-SemiBold.ttf',
    'assets/fonts/Cairo-Bold.ttf',
  ]);
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('nav bar — light, English', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(780, 400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _harness(theme: AppTheme.light, direction: TextDirection.ltr, items: _english),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(AppNavBar),
      matchesGoldenFile('goldens/nav_bar_light.png'),
    );
  });

  testWidgets('nav bar — dark, second tab selected', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(780, 400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _harness(
        theme: AppTheme.dark,
        direction: TextDirection.ltr,
        items: _english,
        index: 1,
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(AppNavBar),
      matchesGoldenFile('goldens/nav_bar_dark.png'),
    );
  });

  testWidgets('nav bar — dark, RTL, third tab selected', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(780, 400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _harness(
        theme: AppTheme.dark,
        direction: TextDirection.rtl,
        items: _arabic,
        index: 2,
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(AppNavBar),
      matchesGoldenFile('goldens/nav_bar_rtl.png'),
    );
  });
}
