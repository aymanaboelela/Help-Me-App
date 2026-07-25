import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/core/localized_text.dart';
import 'package:help_me/core/media/topic_media.dart';
import 'package:help_me/features/conditions/data/first_aid_data.dart';
import 'package:help_me/features/conditions/data/topic_media_data.dart';
import 'package:help_me/features/conditions/model/first_aid_topic.dart';

void main() {
  final Set<String> topicIds =
      kFirstAidTopics.map((FirstAidTopic t) => t.id).toSet();

  group('Topic media catalogue', () {
    test('Given every media entry, Then its key is a real topic id', () {
      for (final String id in kTopicMedia.keys) {
        expect(topicIds, contains(id), reason: '"$id" is not a topic');
      }
    });

    test('Given every image, Then the asset file exists on disk', () {
      for (final MapEntry<String, TopicMedia> entry in kTopicMedia.entries) {
        for (final TopicImage image in entry.value.images) {
          expect(
            image.asset.startsWith('assets/steps/') ||
                image.asset.startsWith('assets/photos/'),
            isTrue,
            reason: '${entry.key}: ${image.asset} is in neither asset folder',
          );
          expect(
            File(image.asset).existsSync(),
            isTrue,
            reason: '${entry.key}: missing asset ${image.asset}',
          );
        }
      }
    });

    test('Given a photograph, Then it carries a credit and a drawing does not', () {
      for (final MapEntry<String, TopicMedia> entry in kTopicMedia.entries) {
        for (final TopicImage image in entry.value.images) {
          if (image.isDrawing) {
            expect(
              image.credit,
              isNull,
              reason: '${entry.key}: ${image.asset} is original work',
            );
            continue;
          }
          final PhotoCredit? credit = image.credit;
          expect(credit, isNotNull, reason: '${entry.key}: ${image.asset}');
          expect(credit!.photographer.trim(), isNotEmpty, reason: image.asset);
          expect(credit.sourceUrl, startsWith('https://'), reason: image.asset);
          expect(
            credit.photographerUrl,
            startsWith('https://'),
            reason: image.asset,
          );
        }
      }
    });

    test('Given a photograph, Then it leads its topic\'s gallery', () {
      for (final MapEntry<String, TopicMedia> entry in kTopicMedia.entries) {
        final List<TopicImage> images = entry.value.images;
        final int photo = images.indexWhere((TopicImage i) => !i.isDrawing);
        if (photo == -1) continue;
        expect(
          photo,
          0,
          reason: '${entry.key}: the scene should come before the diagrams',
        );
      }
    });

    test('Given every bundled photo, Then some topic uses it', () {
      final Set<String> used = <String>{
        for (final TopicMedia media in kTopicMedia.values)
          for (final TopicImage image in media.images) image.asset,
      };
      final List<String> onDisk = Directory('assets/photos')
          .listSync()
          .whereType<File>()
          .map((File f) => 'assets/photos/${f.uri.pathSegments.last}')
          .where((String path) => path.endsWith('.jpg'))
          .toList();

      expect(onDisk, isNotEmpty);
      for (final String path in onDisk) {
        expect(used, contains(path), reason: '$path is bundled but never shown');
      }
    });

    test('Given every image, Then its caption is bilingual and non-empty', () {
      for (final MapEntry<String, TopicMedia> entry in kTopicMedia.entries) {
        for (final TopicImage image in entry.value.images) {
          expect(
            image.caption.isComplete,
            isTrue,
            reason: '${entry.key}: caption for ${image.asset}',
          );
        }
      }
    });

    test('Given every drawing in assets/steps, Then some topic uses it', () {
      final Set<String> used = <String>{
        for (final TopicMedia media in kTopicMedia.values)
          for (final TopicImage image in media.images) image.asset,
      };
      final List<String> onDisk = Directory('assets/steps')
          .listSync()
          .whereType<File>()
          .map((File f) => 'assets/steps/${f.uri.pathSegments.last}')
          .where((String path) => path.endsWith('.svg'))
          .toList();

      expect(onDisk, isNotEmpty);
      for (final String path in onDisk) {
        expect(used, contains(path), reason: '$path is bundled but never shown');
      }
    });

    test('Given every video, Then its id, channel and language are well formed', () {
      final RegExp youtubeId = RegExp(r'^[A-Za-z0-9_-]{11}$');
      for (final MapEntry<String, TopicMedia> entry in kTopicMedia.entries) {
        for (final TopicVideo video in entry.value.videos) {
          expect(
            youtubeId.hasMatch(video.youtubeId),
            isTrue,
            reason: '${entry.key}: bad video id "${video.youtubeId}"',
          );
          expect(video.title.isComplete, isTrue, reason: '${entry.key}: video title');
          expect(video.channel.trim(), isNotEmpty, reason: '${entry.key}: video channel');
          expect(
            <String>['ar', 'en'],
            contains(video.languageCode),
            reason: '${entry.key}: language "${video.languageCode}"',
          );
          expect(
            video.duration.inSeconds,
            greaterThan(0),
            reason: '${entry.key}: duration',
          );
        }
      }
    });

    test('Given every video id, Then it appears only once across the catalogue', () {
      final List<String> ids = <String>[
        for (final TopicMedia media in kTopicMedia.values)
          for (final TopicVideo video in media.videos) video.youtubeId,
      ];
      expect(ids.toSet().length, ids.length, reason: 'a video is listed twice');
    });

    test('Given the catalogue, Then most topics carry at least one illustration', () {
      final int covered = topicIds
          .where((String id) => (kTopicMedia[id]?.images ?? const <TopicImage>[]).isNotEmpty)
          .length;
      expect(covered, greaterThanOrEqualTo(topicIds.length - 1));
    });
  });

  group('TopicVideo formatting and links', () {
    const TopicVideo video = TopicVideo(
      youtubeId: 'BQNNOh8c8ks',
      title: LocalizedText(en: 'How to do CPR on an adult', ar: 'الإنعاش القلبي للبالغين'),
      channel: 'St John Ambulance',
      languageCode: 'en',
      duration: Duration(minutes: 3, seconds: 5),
    );

    test('Given a duration, Then seconds are zero padded', () {
      expect(video.formattedDuration, '3:05');
    });

    test('Given a video, Then the watch and thumbnail links carry its id', () {
      expect(video.watchUrl.toString(), contains('BQNNOh8c8ks'));
      expect(video.thumbnailUrl, 'https://i.ytimg.com/vi/BQNNOh8c8ks/hqdefault.jpg');
    });
  });

  group('TopicMedia.videosFor', () {
    test('Given a locale, Then videos in that language come first', () {
      final TopicMedia cpr = kTopicMedia['cpr']!;
      final List<TopicVideo> arabicFirst = cpr.videosFor(const Locale('ar'));
      final List<TopicVideo> englishFirst = cpr.videosFor(const Locale('en'));

      expect(arabicFirst.first.languageCode, 'ar');
      expect(englishFirst.first.languageCode, 'en');
      expect(arabicFirst.length, cpr.videos.length);
      expect(englishFirst.toSet(), arabicFirst.toSet());
    });
  });
}
