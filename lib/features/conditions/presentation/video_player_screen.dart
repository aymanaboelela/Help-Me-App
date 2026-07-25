import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/media/topic_media.dart';
import '../../../l10n/app_localizations.dart';

/// Plays a first-aid video inside the app rather than handing the user off to
/// YouTube.
///
/// Leaving the app mid-emergency is a good way to lose your place in the steps,
/// so the player stays here. Two consequences follow from that:
///
/// The back button is drawn over the video by [YoutubePlayer.controlsBuilder],
/// not by an app bar. An app bar disappears the moment the player goes
/// fullscreen, and a fullscreen video with no visible way out is a trap.
///
/// Transport controls live in a bar of our own below the player. YouTube's own
/// controls fade out and are sized for a thumb that is not currently busy;
/// these stay put, are large, and add the things that matter here — skip back
/// ten seconds to catch a step you missed, and slow the whole thing down.
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
        // YouTube's own controls stay on: they carry captions and quality,
        // which our bar deliberately does not duplicate.
        showControls: true,
        showFullscreenButton: true,
        interfaceLanguage: language,
        captionLanguage: language,
        enableCaption: true,
        strictRelatedVideos: true,
        showVideoAnnotations: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  void _leave(bool isFullscreen) {
    final YoutubePlayerController? controller = _controller;
    if (isFullscreen && controller != null) {
      controller.exitFullScreen();
      return;
    }
    Navigator.of(context).maybePop();
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
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ColoredBox(
              color: Colors.black,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: controller == null
                    ? const Center(child: CircularProgressIndicator.adaptive())
                    : YoutubePlayer(
                        controller: controller,
                        controlsBuilder: (BuildContext context, bool isFullscreen) {
                          return _BackOverlay(
                            tooltip: l10n.commonBack,
                            onPressed: () => _leave(isFullscreen),
                          );
                        },
                      ),
              ),
            ),
            if (controller != null) _TransportBar(controller: controller),
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
      ),
    );
  }
}

/// A back button floated over the player.
///
/// Only the button itself takes hits — the rest of the [Stack] is empty, so
/// taps anywhere else reach YouTube's controls underneath.
class _BackOverlay extends StatelessWidget {
  const _BackOverlay({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          PositionedDirectional(
            top: 6,
            start: 6,
            child: Material(
              color: Colors.black.withValues(alpha: 0.55),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                tooltip: tooltip,
                onPressed: onPressed,
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
                iconSize: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Play, scrub, skip and slow down — the controls someone following along with
/// their hands actually reaches for.
class _TransportBar extends StatefulWidget {
  const _TransportBar({required this.controller});

  final YoutubePlayerController controller;

  @override
  State<_TransportBar> createState() => _TransportBarState();
}

class _TransportBarState extends State<_TransportBar> {
  static const List<double> _speeds = <double>[0.5, 0.75, 1, 1.25, 1.5, 2];
  static const Duration _skip = Duration(seconds: 10);

  StreamSubscription<YoutubeVideoState>? _stateSub;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  /// Set while the user drags, so incoming positions do not fight the thumb.
  double? _scrubbing;

  @override
  void initState() {
    super.initState();
    _stateSub = widget.controller.videoStateStream.listen((YoutubeVideoState s) {
      if (!mounted) return;
      setState(() => _position = s.position);
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    super.dispose();
  }

  Future<void> _seekTo(Duration target) async {
    final Duration clamped = target < Duration.zero
        ? Duration.zero
        : (_duration > Duration.zero && target > _duration ? _duration : target);
    setState(() => _position = clamped);
    await widget.controller.seekTo(
      seconds: clamped.inMilliseconds / 1000,
      allowSeekAhead: true,
    );
  }

  Future<void> _pickSpeed(double current) async {
    final double? choice = await showModalBottomSheet<double>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final double speed in _speeds)
              ListTile(
                title: Text(_formatSpeed(speed)),
                trailing: speed == current ? const Icon(Icons.check) : null,
                selected: speed == current,
                onTap: () => Navigator.of(context).pop(speed),
              ),
          ],
        ),
      ),
    );
    if (choice != null) await widget.controller.setPlaybackRate(choice);
  }

  static String _formatSpeed(double speed) {
    final String text = speed == speed.roundToDouble()
        ? speed.toStringAsFixed(0)
        : speed.toString();
    return '$text×';
  }

  static String _formatTime(Duration d) {
    final int total = d.inSeconds;
    final String minutes = (total ~/ 60).toString();
    final String seconds = (total % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return YoutubeValueBuilder(
      controller: widget.controller,
      builder: (BuildContext context, YoutubePlayerValue value) {
        // Metadata duration arrives a beat after the video loads; until then
        // the slider has nothing meaningful to represent.
        _duration = value.metaData.duration;
        final bool ready = _duration > Duration.zero;
        final bool playing = value.playerState == PlayerState.playing ||
            value.playerState == PlayerState.buffering;
        final double maxSeconds = ready ? _duration.inMilliseconds / 1000 : 1;
        final double positionSeconds =
            (_scrubbing ?? _position.inMilliseconds / 1000).clamp(0, maxSeconds);

        return Container(
          color: context.semantic.cardBorder.withValues(alpha: 0.14),
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    _formatTime(Duration(milliseconds: (positionSeconds * 1000).round())),
                    style: context.texts.labelMedium,
                  ),
                  Expanded(
                    child: Slider(
                      value: positionSeconds,
                      max: maxSeconds,
                      onChanged: ready
                          ? (double v) => setState(() => _scrubbing = v)
                          : null,
                      onChangeEnd: (double v) {
                        setState(() => _scrubbing = null);
                        _seekTo(Duration(milliseconds: (v * 1000).round()));
                      },
                    ),
                  ),
                  Text(
                    _formatTime(_duration),
                    style: context.texts.labelMedium,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    tooltip: l10n.videoRestart,
                    onPressed: () => _seekTo(Duration.zero),
                    icon: const Icon(Icons.replay),
                  ),
                  IconButton(
                    tooltip: l10n.videoBackTen,
                    onPressed: () => _seekTo(_position - _skip),
                    icon: const Icon(Icons.replay_10),
                  ),
                  IconButton.filled(
                    tooltip: playing ? l10n.videoPause : l10n.videoPlay,
                    iconSize: 30,
                    onPressed: () => playing
                        ? widget.controller.pauseVideo()
                        : widget.controller.playVideo(),
                    icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                  ),
                  IconButton(
                    tooltip: l10n.videoForwardTen,
                    onPressed: () => _seekTo(_position + _skip),
                    icon: const Icon(Icons.forward_10),
                  ),
                  TextButton(
                    onPressed: () => _pickSpeed(value.playbackRate),
                    child: Text(_formatSpeed(value.playbackRate)),
                  ),
                  IconButton(
                    tooltip: l10n.videoFullscreen,
                    onPressed: widget.controller.enterFullScreen,
                    icon: const Icon(Icons.fullscreen),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
