import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/conditions/data/first_aid_data.dart';
import '../features/conditions/model/first_aid_topic.dart';
import 'preferences.dart';

/// Most-recently-opened topic ids (newest first), persisted locally.
class RecentNotifier extends Notifier<List<String>> {
  static const String _key = 'recent.ids';
  static const int maxItems = 6;

  @override
  List<String> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getStringList(_key) ?? const <String>[];
  }

  Future<void> touch(String id) async {
    final List<String> next = <String>[
      id,
      ...state.where((String e) => e != id),
    ].take(maxItems).toList();
    state = next;
    await ref.read(sharedPreferencesProvider).setStringList(_key, next);
  }
}

final NotifierProvider<RecentNotifier, List<String>> recentProvider =
    NotifierProvider<RecentNotifier, List<String>>(RecentNotifier.new);

/// The recently-viewed topics, newest first (missing ids are skipped).
final Provider<List<FirstAidTopic>> recentTopicsProvider =
    Provider<List<FirstAidTopic>>((ref) {
  final List<String> ids = ref.watch(recentProvider);
  return ids.map(topicById).whereType<FirstAidTopic>().toList();
});
