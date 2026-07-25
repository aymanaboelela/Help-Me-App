import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/app/theme/app_theme.dart';
import 'package:help_me/core/media/topic_media.dart';
import 'package:help_me/features/conditions/data/topic_media_data.dart';
import 'package:help_me/features/conditions/presentation/widgets/topic_gallery.dart';
import 'package:help_me/l10n/app_localizations.dart';

/// Renders the condition gallery so the photo-then-diagram pairing can be
/// reviewed as an image rather than taken on trust.
/// Regenerate with `flutter test --update-goldens`.
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
  ]);
  await load('Cairo', <String>[
    'assets/fonts/Cairo-Regular.ttf',
    'assets/fonts/Cairo-SemiBold.ttf',
    'assets/fonts/Cairo-Bold.ttf',
  ]);
}

Future<void> _pumpGallery(
  WidgetTester tester, {
  required String topicId,
  required ThemeData theme,
  required Locale locale,
}) async {
  tester.view.physicalSize = const Size(824, 1000);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);

  final TopicMedia media = kTopicMedia[topicId]!;

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: theme,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: TopicGallery(
            images: media.images,
            accent: const Color(0xFFE63946),
          ),
        ),
      ),
    ),
  );

  // Bundled images decode off the platform thread, so the frame has to be
  // driven for real before anything is captured.
  await tester.runAsync(() async {
    for (final Element element in find.byType(Image).evaluate()) {
      final Image widget = element.widget as Image;
      await precacheImage(widget.image, element);
    }
  });
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('gallery — photo leads, light, English', (WidgetTester tester) async {
    await _pumpGallery(
      tester,
      topicId: 'cpr',
      theme: AppTheme.light,
      locale: const Locale('en'),
    );
    await expectLater(
      find.byType(TopicGallery),
      matchesGoldenFile('goldens/gallery_light.png'),
    );
  });

  testWidgets('gallery — dark, Arabic', (WidgetTester tester) async {
    await _pumpGallery(
      tester,
      topicId: 'bleeding',
      theme: AppTheme.dark,
      locale: const Locale('ar'),
    );
    await expectLater(
      find.byType(TopicGallery),
      matchesGoldenFile('goldens/gallery_dark_ar.png'),
    );
  });

  testWidgets('gallery — a topic with drawings only', (WidgetTester tester) async {
    await _pumpGallery(
      tester,
      topicId: 'choking',
      theme: AppTheme.light,
      locale: const Locale('ar'),
    );
    await expectLater(
      find.byType(TopicGallery),
      matchesGoldenFile('goldens/gallery_drawing_only.png'),
    );
  });
}
