import '../model/first_aid_topic.dart';
import 'topics_extended.dart';
import 'topics_original.dart';

/// The single source of truth for every first-aid topic in the app.
final List<FirstAidTopic> kFirstAidTopics = <FirstAidTopic>[
  ...kOriginalTopics,
  ...kExtendedTopics,
];

/// Returns the topic with the given [id], or `null` if none exists.
FirstAidTopic? topicById(String id) {
  for (final FirstAidTopic topic in kFirstAidTopics) {
    if (topic.id == id) return topic;
  }
  return null;
}

/// Topics belonging to [category], preserving catalogue order.
List<FirstAidTopic> topicsInCategory(TopicCategory category) =>
    kFirstAidTopics.where((FirstAidTopic t) => t.category == category).toList();
