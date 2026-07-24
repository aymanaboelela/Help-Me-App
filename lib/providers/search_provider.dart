import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/conditions/data/first_aid_data.dart';
import '../features/conditions/model/first_aid_topic.dart';

/// The current search text on the home screen.
final StateProvider<String> searchQueryProvider =
    StateProvider<String>((ref) => '');

/// The selected category filter (`null` = all categories).
final StateProvider<TopicCategory?> selectedCategoryProvider =
    StateProvider<TopicCategory?>((ref) => null);

/// Topics filtered by the active search query and category.
final Provider<List<FirstAidTopic>> filteredTopicsProvider =
    Provider<List<FirstAidTopic>>((ref) {
  final String query = ref.watch(searchQueryProvider);
  final TopicCategory? category = ref.watch(selectedCategoryProvider);
  return kFirstAidTopics.where((FirstAidTopic topic) {
    final bool inCategory = category == null || topic.category == category;
    return inCategory && topic.matches(query);
  }).toList();
});
