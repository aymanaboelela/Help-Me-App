import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/media/topic_media.dart';
import '../../../../l10n/app_localizations.dart';
import '../video_player_screen.dart';

/// Links to first-aid videos published by recognised health bodies.
///
/// Deliberately placed below the written steps: in an emergency you read, you do
/// not watch. These are for the quiet evening when someone decides to learn.
class TopicVideos extends StatelessWidget {
  const TopicVideos({super.key, required this.videos, required this.accent});

  final List<TopicVideo> videos;
  final Color accent;

  void _open(BuildContext context, TopicVideo video) {
    Navigator.of(context).push(VideoPlayerScreen.route(video));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Locale locale = context.locale;
    final List<TopicVideo> ordered = <TopicVideo>[
      ...videos.where((TopicVideo v) => v.languageCode == locale.languageCode),
      ...videos.where((TopicVideo v) => v.languageCode != locale.languageCode),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(width: 4, height: 20, color: accent),
            const SizedBox(width: 8),
            Expanded(child: Text(l10n.watchTitle, style: context.texts.titleLarge)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          l10n.watchNote,
          style: context.texts.bodySmall?.copyWith(color: context.semantic.muted),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 216,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: ordered.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (BuildContext context, int i) => _VideoCard(
              video: ordered[i],
              accent: accent,
              onTap: () => _open(context, ordered[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video, required this.accent, required this.onTap});

  final TopicVideo video;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Locale locale = context.locale;
    final String language =
        video.languageCode == 'ar' ? l10n.languageArabic : l10n.languageEnglish;

    return SizedBox(
      width: 236,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.network(
                      video.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _ThumbnailFallback(
                        accent: accent,
                        message: l10n.videoNeedsInternet,
                      ),
                      loadingBuilder: (
                        BuildContext context,
                        Widget child,
                        ImageChunkEvent? progress,
                      ) {
                        if (progress == null) return child;
                        return Container(color: accent.withValues(alpha: 0.08));
                      },
                    ),
                  ),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        video.formattedDuration,
                        style: context.texts.labelSmall?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              video.title.resolve(locale),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.texts.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              '${video.channel} · $language',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.texts.bodySmall?.copyWith(color: context.semantic.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback({required this.accent, required this.message});

  final Color accent;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: accent.withValues(alpha: 0.1),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.wifi_off_outlined, color: context.semantic.muted, size: 22),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.texts.bodySmall?.copyWith(color: context.semantic.muted),
          ),
        ],
      ),
    );
  }
}
