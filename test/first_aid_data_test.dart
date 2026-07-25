import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/core/localized_text.dart';
import 'package:help_me/features/conditions/data/first_aid_data.dart';
import 'package:help_me/features/conditions/model/first_aid_topic.dart';
import 'package:help_me/features/emergency/data/emergency_numbers.dart';

void main() {
  group('First-aid catalogue integrity', () {
    test('Given the catalogue, Then it holds at least 15 topics', () {
      expect(kFirstAidTopics.length, greaterThanOrEqualTo(15));
    });

    test('Given the catalogue, Then every topic id is unique', () {
      final List<String> ids =
          kFirstAidTopics.map((FirstAidTopic t) => t.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('Given every topic, Then all text is bilingual and non-empty', () {
      for (final FirstAidTopic topic in kFirstAidTopics) {
        expect(topic.title.isComplete, isTrue, reason: '${topic.id}: title');
        expect(topic.summary.isComplete, isTrue, reason: '${topic.id}: summary');
        expect(topic.sections, isNotEmpty, reason: '${topic.id}: no sections');
        if (topic.overview != null) {
          expect(topic.overview!.isComplete, isTrue, reason: '${topic.id}: overview');
        }
        for (final FirstAidSection section in topic.sections) {
          expect(section.title.isComplete, isTrue, reason: '${topic.id}: section title');
          for (final LocalizedText step in section.steps) {
            expect(step.isComplete, isTrue, reason: '${topic.id}: a step');
          }
          for (final FirstAidCallout callout in section.callouts) {
            expect(callout.text.isComplete, isTrue, reason: '${topic.id}: a callout');
          }
        }
      }
    });

    test('Given lookup helpers, Then they resolve correctly', () {
      expect(topicById('cpr'), isNotNull);
      expect(topicById('does_not_exist'), isNull);
      expect(
        topicsInCategory(TopicCategory.cardiac)
            .every((FirstAidTopic t) => t.category == TopicCategory.cardiac),
        isTrue,
      );
    });
  });

  group('FirstAidTopic.matches', () {
    test('Given an English query, Then it matches by title', () {
      final FirstAidTopic burns = topicById('burns')!;
      expect(burns.matches('burn'), isTrue);
      expect(burns.matches('BURNS'), isTrue);
      expect(burns.matches('snake'), isFalse);
    });

    test('Given an Arabic query, Then it matches by title', () {
      final FirstAidTopic burns = topicById('burns')!;
      expect(burns.matches('حروق'), isTrue);
    });

    test('Given an empty query, Then it matches everything', () {
      expect(topicById('cpr')!.matches('   '), isTrue);
    });
  });

  group('Emergency numbers', () {
    test('Given every number, Then names are bilingual and digits only', () {
      final RegExp digits = RegExp(r'^[0-9]+$');
      for (final EmergencyNumber item in kEmergencyNumbers) {
        expect(item.name.isComplete, isTrue);
        expect(digits.hasMatch(item.number), isTrue, reason: item.number);
      }
    });

    test('Given the list, Then ambulance (123) comes first', () {
      expect(kEmergencyNumbers.first.number, '123');
      expect(kAmbulance.number, '123');
    });
  });
}
