import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/media/topic_media.dart';
import '../../../l10n/app_localizations.dart';

/// Plays a first-aid video inside the app rather than handing the user off to
/// YouTube.
///
/// Leaving the app mid-emergency is a good way to lose your place in the steps,
/// so the player stays here and the steps are one back-tap away. The interface
/// and caption language follow the app's own language setting.
class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key, required this.video});

  final TopicVideo video;

  static Route<void> route(TopicVideo video) =>
      MaterialPageRoute<void>(builder: (_) => VideoPlayerScreen(video: video));

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  YoutubePlayerController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final String language = Localizations.localeOf(context).languageCode;
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.video.youtubeId,
      autoPlay: true,
      params: YoutubePlayerParams(
        showFullscreenButton: true,
        interfaceLanguage: language,
        captionLanguage: language,
        strictRelatedVideos: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  Future<void> _openExternally() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    bool opened = false;
    try {
      opened = await launchUrl(
        widget.video.watchUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
    if (!opened) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.videoOpenError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Locale locale = context.locale;
    final YoutubePlayerController? controller = _controller;
    final String language = widget.video.languageCode == 'ar'
        ? l10n.languageArabic
        : l10n.languageEnglish;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.watchTitle),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.videoOpenInYoutube,
            onPressed: _openExternally,
            icon: const Icon(Icons.open_in_new),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          ColoredBox(
            color: Colors.black,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: controller == null
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : YoutubePlayer(controller: controller),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.video.title.resolve(locale),
                  style: context.texts.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.video.channel} · $language · ${widget.video.formattedDuration}',
                  style: context.texts.bodyMedium
                      ?.copyWith(color: context.semantic.muted),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.info_outline, size: 18, color: context.semantic.muted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.videoSourceNote,
                        style: context.texts.bodySmall
                            ?.copyWith(color: context.semantic.muted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
