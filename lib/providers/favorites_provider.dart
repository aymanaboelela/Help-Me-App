import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/conditions/data/first_aid_data.dart';
import '../features/conditions/model/first_aid_topic.dart';
import 'preferences.dart';

const String _kFavoritesKey = 'favorites.ids';

/// Persisted set of favorited topic ids.
class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return (prefs.getStringList(_kFavoritesKey) ?? const <String>[]).toSet();
  }

  bool isFavorite(String id) => state.contains(id);

  Future<void> toggle(String id) async {
    final Set<String> next = <String>{...state};
    if (!next.add(id)) {
      next.remove(id);
    }
    state = next;
    await ref
        .read(sharedPreferencesProvider)
        .setStringList(_kFavoritesKey, next.toList());
  }
}

final NotifierProvider<FavoritesNotifier, Set<String>> favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

/// The favorited topics, in catalogue order.
final Provider<List<FirstAidTopic>> favoriteTopicsProvider =
    Provider<List<FirstAidTopic>>((ref) {
  final Set<String> ids = ref.watch(favoritesProvider);
  return kFirstAidTopics
      .where((FirstAidTopic t) => ids.contains(t.id))
      .toList();
});
