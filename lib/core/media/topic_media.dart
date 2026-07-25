import 'package:flutter/widgets.dart';

import '../localized_text.dart';

/// A step illustration bundled with the app.
///
/// Every illustration was drawn for Help Me, carries no third-party copyright,
/// and contains no text — so one file serves both languages.
@immutable
class TopicImage {
  const TopicImage({required this.asset, required this.caption});

  /// Asset path, e.g. `assets/steps/recovery_position.svg`.
  final String asset;

  /// What the drawing shows. Read aloud by screen readers as the image label.
  final LocalizedText caption;
}

/// A publicly available video published by a recognised first-aid or health body.
///
/// The app links to the video; it never hosts or re-uploads it. Every [youtubeId]
/// was checked against YouTube's public oEmbed endpoint before being added here,
/// which is also where [channel] comes from — so the attribution shown in the app
/// is the channel that actually published the video, not a guess.
@immutable
class TopicVideo {
  const TopicVideo({
    required this.youtubeId,
    required this.title,
    required this.channel,
    required this.languageCode,
    required this.duration,
  });

  final String youtubeId;

  /// A short description of what the video covers, in both languages. This is a
  /// label, not a translation of the video's own title — YouTube shows that.
  final LocalizedText title;

  /// The publishing channel, exactly as YouTube reports it.
  final String channel;

  /// The language spoken in the video: `ar` or `en`.
  final String languageCode;

  final Duration duration;

  Uri get watchUrl => Uri.parse('https://www.youtube.com/watch?v=$youtubeId');

  /// Still frame served by YouTube's image host — no API key, no quota.
  String get thumbnailUrl => 'https://i.ytimg.com/vi/$youtubeId/hqdefault.jpg';

  String get formattedDuration {
    final int minutes = duration.inMinutes;
    final int seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// The illustrations and videos attached to one first-aid topic.
///
/// Media is looked up by topic id rather than stored on [FirstAidTopic] itself,
/// so imagery can be added to a condition without touching a word of its medical
/// text — and a topic with no media yet simply renders without it.
@immutable
class TopicMedia {
  const TopicMedia({
    this.images = const <TopicImage>[],
    this.videos = const <TopicVideo>[],
  });

  final List<TopicImage> images;
  final List<TopicVideo> videos;

  bool get isEmpty => images.isEmpty && videos.isEmpty;

  /// Videos spoken in the reader's own language first; relative order preserved.
  List<TopicVideo> videosFor(Locale locale) {
    final String preferred = locale.languageCode;
    return <TopicVideo>[
      ...videos.where((TopicVideo v) => v.languageCode == preferred),
      ...videos.where((TopicVideo v) => v.languageCode != preferred),
    ];
  }
}
