import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/conditions/data/first_aid_data.dart';
import '../features/conditions/model/first_aid_topic.dart';

/// The current search text on the home screen.
final StateProvider<String> searchQueryProvider =
    StateProvider<String>((ref) => '');

/// The selected category filter (`null` = all categories).
final StateProvider<TopicCategory?> selectedCategoryProvider =
    StateProvider<TopicCategory?>((ref) => null);

/// Whether the home list is narrowed to what a parent needs.
///
/// Kept separate from [selectedCategoryProvider] rather than added to
/// [TopicCategory]: "for children" is not a body system, and folding it into
/// that enum would make the category taxonomy mean two different things.
final StateProvider<bool> childrenFilterProvider =
    StateProvider<bool>((ref) => false);

/// Topics filtered by the active search query, category, and children filter.
final Provider<List<FirstAidTopic>> filteredTopicsProvider =
    Provider<List<FirstAidTopic>>((ref) {
  final String query = ref.watch(searchQueryProvider);
  final TopicCategory? category = ref.watch(selectedCategoryProvider);
  final bool childrenOnly = ref.watch(childrenFilterProvider);
  return kFirstAidTopics.where((FirstAidTopic topic) {
    final bool inCategory = category == null || topic.category == category;
    final bool forChildren = !childrenOnly || topic.concernsChildren;
    return inCategory && forChildren && topic.matches(query);
  }).toList();
});
