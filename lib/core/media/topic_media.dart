import 'package:flutter/widgets.dart';

import '../localized_text.dart';

/// Who took a photograph, so the app can say so.
///
/// The Pexels licence does not demand attribution, but their API guidelines ask
/// for it and the photographers deserve it either way.
@immutable
class PhotoCredit {
  const PhotoCredit({
    required this.photographer,
    required this.photographerUrl,
    required this.sourceUrl,
  });

  final String photographer;
  final String photographerUrl;

  /// The photo's own page, so a curious reader can find the original.
  final String sourceUrl;
}

/// One picture attached to a topic: either a photograph of the real thing or a
/// diagram drawn for this app.
///
/// Both kinds live in the same list because a topic wants both — the photograph
/// says what the situation looks like, the diagram says what your hands should
/// do, and neither substitutes for the other. Drawings carry no [credit]
/// because they are original work; photographs always carry one.
@immutable
class TopicImage {
  const TopicImage({
    required this.asset,
    required this.caption,
    this.credit,
  });

  /// Asset path — `assets/steps/*.svg` for a drawing, `assets/photos/*.jpg`
  /// for a photograph.
  final String asset;

  /// What the picture shows. Read aloud by screen readers as the image label.
  final LocalizedText caption;

  final PhotoCredit? credit;

  bool get isDrawing => asset.endsWith('.svg');
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
