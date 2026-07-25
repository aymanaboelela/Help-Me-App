import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../features/conditions/model/first_aid_topic.dart';
import '../../features/conditions/presentation/condition_detail_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/favorites_provider.dart';
import 'accent_tile.dart';

/// A tappable card summarizing a [FirstAidTopic], with a favorite toggle.
/// Shared by the home list, search results, and favorites.
class TopicCard extends ConsumerWidget {
  const TopicCard({super.key, required this.topic});

  final FirstAidTopic topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Locale locale = context.locale;
    final bool isFavorite = ref.watch(favoritesProvider).contains(topic.id);

    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(ConditionDetailScreen.route(topic)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              AccentTile(icon: topic.icon, accent: topic.color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      topic.title.resolve(locale),
                      style: context.texts.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      topic.summary.resolve(locale),
                      style: context.texts.bodySmall?.copyWith(color: context.semantic.muted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => ref.read(favoritesProvider.notifier).toggle(topic.id),
                tooltip: isFavorite ? l10n.removeFavorite : l10n.addFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? context.colors.primary : context.semantic.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
