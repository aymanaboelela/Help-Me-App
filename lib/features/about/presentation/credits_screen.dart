import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/media/topic_media.dart';
import '../../../features/conditions/data/topic_media_data.dart';
import '../../../l10n/app_localizations.dart';

/// Where every image and video in the app comes from.
///
/// The step drawings are original work and carry no outside copyright, so this
/// screen exists less as a legal obligation than as a plain statement of it —
/// alongside the list of channels whose videos the app links to.
class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const CreditsScreen());

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final Set<String> channels = <String>{
      for (final TopicMedia media in kTopicMedia.values)
        for (final TopicVideo video in media.videos) video.channel,
    };
    final List<String> sortedChannels = channels.toList()..sort();

    final int illustrations = <String>{
      for (final TopicMedia media in kTopicMedia.values)
        for (final TopicImage image in media.images) image.asset,
    }.length;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.creditsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        children: <Widget>[
          _Section(
            icon: Icons.draw_outlined,
            title: '${l10n.creditsIllustrationsTitle} · $illustrations',
            body: l10n.creditsIllustrationsBody,
          ),
          const SizedBox(height: 12),
          _Section(
            icon: Icons.image_outlined,
            title: l10n.creditsCategoryArtTitle,
            body: l10n.creditsCategoryArtBody,
          ),
          const SizedBox(height: 12),
          _Section(
            icon: Icons.play_circle_outline,
            title: l10n.creditsVideosTitle,
            body: l10n.creditsVideosBody,
            bullets: sortedChannels,
          ),
          const SizedBox(height: 12),
          _Section(
            icon: Icons.text_fields_outlined,
            title: l10n.creditsFontTitle,
            body: l10n.creditsFontBody,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.body,
    this.bullets = const <String>[],
  });

  final IconData icon;
  final String title;
  final String body;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, color: context.colors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: context.texts.titleMedium)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: context.texts.bodyMedium?.copyWith(color: context.semantic.muted),
            ),
            for (final String bullet in bullets) ...<Widget>[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.circle, size: 6, color: context.semantic.muted),
                  const SizedBox(width: 8),
                  Expanded(child: Text(bullet, style: context.texts.bodyMedium)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
