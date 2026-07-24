import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/topic_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/favorites_provider.dart';
import '../../conditions/model/first_aid_topic.dart';

/// Saved conditions for quick access during an emergency.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<FirstAidTopic> favorites = ref.watch(favoriteTopicsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.favoritesTitle)),
      body: favorites.isEmpty
          ? _EmptyFavorites(
              title: l10n.favoritesEmptyTitle,
              body: l10n.favoritesEmptyBody,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: <Widget>[
                for (final FirstAidTopic topic in favorites)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TopicCard(topic: topic),
                  ),
              ],
            ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.favorite_border, size: 56, color: context.semantic.muted),
            const SizedBox(height: 16),
            Text(title, style: context.texts.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: context.texts.bodyMedium?.copyWith(color: context.semantic.muted),
            ),
          ],
        ),
      ),
    );
  }
}
