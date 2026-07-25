import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/core/localized_text.dart';
import 'package:help_me/features/conditions/data/first_aid_data.dart';
import 'package:help_me/features/conditions/model/first_aid_topic.dart';

const FirstAidSection _adultSection = FirstAidSection(
  title: LocalizedText(en: 'Steps', ar: 'الخطوات'),
  steps: <LocalizedText>[LocalizedText(en: 'Push hard', ar: 'اضغط بقوة')],
);

const FirstAidSection _infantSection = FirstAidSection(
  title: LocalizedText(en: 'Steps', ar: 'الخطوات'),
  steps: <LocalizedText>[LocalizedText(en: 'Two fingers', ar: 'إصبعان')],
);

FirstAidTopic _topic({
  Map<AgeGroup, List<FirstAidSection>> variants =
      const <AgeGroup, List<FirstAidSection>>{},
  bool paediatric = false,
}) =>
    FirstAidTopic(
      id: 't',
      title: const LocalizedText(en: 'T', ar: 'ت'),
      summary: const LocalizedText(en: 'S', ar: 'س'),
      category: TopicCategory.cardiac,
      icon: Icons.favorite,
      color: const Color(0xFF000000),
      sections: const <FirstAidSection>[_adultSection],
      ageVariants: variants,
      isPaediatric: paediatric,
    );

void main() {
  group('AgeGroup resolution', () {
    test('Given no variants, Then every age resolves to the adult sections', () {
      final FirstAidTopic topic = _topic();
      for (final AgeGroup group in AgeGroup.values) {
        expect(topic.sectionsFor(group), same(topic.sections), reason: group.name);
      }
      expect(topic.hasAgeVariants, isFalse);
    });

    test('Given an infant variant, Then infant resolves to it and adult does not', () {
      final FirstAidTopic topic = _topic(
        variants: const <AgeGroup, List<FirstAidSection>>{
          AgeGroup.infant: <FirstAidSection>[_infantSection],
        },
      );

      expect(topic.sectionsFor(AgeGroup.infant).first.steps.first.en, 'Two fingers');
      expect(topic.sectionsFor(AgeGroup.adult).first.steps.first.en, 'Push hard');
      expect(topic.sectionsFor(AgeGroup.child).first.steps.first.en, 'Push hard');
      expect(topic.hasAgeVariants, isTrue);
    });

    test('Given an infant variant, Then allStepsFor reads that variant', () {
      final FirstAidTopic topic = _topic(
        variants: const <AgeGroup, List<FirstAidSection>>{
          AgeGroup.infant: <FirstAidSection>[_infantSection],
        },
      );

      expect(topic.allStepsFor(AgeGroup.infant).single.ar, 'إصبعان');
      expect(topic.allStepsFor(AgeGroup.adult), topic.allSteps);
    });

    test('Given only an infant variant, Then the options are adult and infant', () {
      final FirstAidTopic topic = _topic(
        variants: const <AgeGroup, List<FirstAidSection>>{
          AgeGroup.infant: <FirstAidSection>[_infantSection],
        },
      );

      expect(topic.ageOptions, <AgeGroup>[AgeGroup.adult, AgeGroup.infant]);
    });

    test('Given both variants, Then the options run adult, child, infant', () {
      final FirstAidTopic topic = _topic(
        variants: const <AgeGroup, List<FirstAidSection>>{
          AgeGroup.infant: <FirstAidSection>[_infantSection],
          AgeGroup.child: <FirstAidSection>[_infantSection],
        },
      );

      expect(
        topic.ageOptions,
        <AgeGroup>[AgeGroup.adult, AgeGroup.child, AgeGroup.infant],
      );
    });

    test('Given a paediatric topic, Then it concerns children without a switch', () {
      final FirstAidTopic topic = _topic(paediatric: true);

      expect(topic.concernsChildren, isTrue);
      expect(topic.hasAgeVariants, isFalse);
      expect(topic.ageOptions, <AgeGroup>[AgeGroup.adult]);
    });
  });

  group('Catalogue age invariants', () {
    test('Given every topic, Then adult resolves to its own sections', () {
      for (final FirstAidTopic topic in kFirstAidTopics) {
        expect(
          topic.sectionsFor(AgeGroup.adult),
          same(topic.sections),
          reason: topic.id,
        );
      }
    });

    test('Given every topic, Then adult is never a variant key', () {
      for (final FirstAidTopic topic in kFirstAidTopics) {
        expect(
          topic.ageVariants.containsKey(AgeGroup.adult),
          isFalse,
          reason: topic.id,
        );
      }
    });

    test('Given every topic, Then paediatric and variants are disjoint', () {
      for (final FirstAidTopic topic in kFirstAidTopics) {
        expect(
          topic.isPaediatric && topic.hasAgeVariants,
          isFalse,
          reason: '${topic.id}: cannot be both paediatric-only and age-switched',
        );
      }
    });

    test('Given every variant, Then its sections and steps are non-empty', () {
      for (final FirstAidTopic topic in kFirstAidTopics) {
        topic.ageVariants.forEach((AgeGroup group, List<FirstAidSection> sections) {
          expect(sections, isNotEmpty, reason: '${topic.id}/${group.name}');
          for (final FirstAidSection section in sections) {
            expect(
              section.steps,
              isNotEmpty,
              reason: '${topic.id}/${group.name}: empty section',
            );
          }
        });
      }
    });

    test('Given every variant, Then all its text is bilingual and complete', () {
      for (final FirstAidTopic topic in kFirstAidTopics) {
        topic.ageVariants.forEach((AgeGroup group, List<FirstAidSection> sections) {
          final String where = '${topic.id}/${group.name}';
          for (final FirstAidSection section in sections) {
            expect(section.title.isComplete, isTrue, reason: '$where: section title');
            for (final LocalizedText step in section.steps) {
              expect(step.isComplete, isTrue, reason: '$where: a step');
            }
            for (final FirstAidCallout callout in section.callouts) {
              expect(callout.text.isComplete, isTrue, reason: '$where: a callout');
            }
          }
        });
      }
    });
  });
}
