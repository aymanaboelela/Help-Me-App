import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/sos_banner.dart';
import '../../core/widgets/topic_card.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/recent_provider.dart';
import '../../providers/search_provider.dart';
import '../conditions/category_display.dart';
import '../conditions/model/first_aid_topic.dart';
import '../conditions/presentation/condition_detail_screen.dart';
import '../favorites/presentation/favorites_screen.dart';

/// The main screen: greeting, SOS banner, search, category filter, and the
/// list of first-aid topics.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<FirstAidTopic> topics = ref.watch(filteredTopicsProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: <Widget>[
            const _HomeHeader(),
            const SizedBox(height: 18),
            const SosBanner(),
            const SizedBox(height: 18),
            const _SearchField(),
            const SizedBox(height: 12),
            const _CategoryChips(),
            const _RecentSection(),
            const SizedBox(height: 18),
            Text(
              l10n.conditionsCount(topics.length),
              style: context.texts.titleSmall?.copyWith(color: context.semantic.muted),
            ),
            const SizedBox(height: 10),
            if (topics.isEmpty)
              _EmptyResults(message: l10n.searchNoResults)
            else
              for (final FirstAidTopic topic in topics)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TopicCard(topic: topic),
                ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const AppLogo(size: 40),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.appName,
                style: context.texts.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            // Filled, unlike the outlined toggle on each card: this opens the
            // saved list rather than adding to it.
            IconButton(
              tooltip: l10n.favoritesTitle,
              onPressed: () => Navigator.of(context).push(FavoritesScreen.route()),
              icon: const Icon(Icons.favorite),
              color: context.colors.primary,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(l10n.homeGreetingTitle, style: context.texts.headlineSmall),
        const SizedBox(height: 4),
        Text(
          l10n.homeGreetingSubtitle,
          style: context.texts.bodyMedium?.copyWith(color: context.semantic.muted),
        ),
      ],
    );
  }
}

class _SearchField extends ConsumerStatefulWidget {
  const _SearchField();

  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String query = ref.watch(searchQueryProvider);

    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      onChanged: (String value) =>
          ref.read(searchQueryProvider.notifier).state = value,
      decoration: InputDecoration(
        hintText: l10n.searchHint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _controller.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                },
              ),
      ),
    );
  }
}

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TopicCategory? selected = ref.watch(selectedCategoryProvider);

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          _Chip(
            label: l10n.categoryAll,
            selected: selected == null,
            onSelected: () =>
                ref.read(selectedCategoryProvider.notifier).state = null,
          ),
          for (final TopicCategory category in TopicCategory.values)
            _Chip(
              label: category.label(l10n),
              selected: selected == category,
              onSelected: () =>
                  ref.read(selectedCategoryProvider.notifier).state = category,
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        showCheckmark: false,
        selectedColor: context.colors.primary,
        labelStyle: context.texts.labelLarge?.copyWith(
          color: selected ? context.colors.onPrimary : context.colors.onSurface,
        ),
      ),
    );
  }
}

class _RecentSection extends ConsumerWidget {
  const _RecentSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String query = ref.watch(searchQueryProvider);
    final TopicCategory? category = ref.watch(selectedCategoryProvider);
    final List<FirstAidTopic> recent = ref.watch(recentTopicsProvider);
    if (query.isNotEmpty || category != null || recent.isEmpty) {
      return const SizedBox.shrink();
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Locale locale = context.locale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 16),
        Text(
          l10n.recentTitle,
          style: context.texts.titleSmall?.copyWith(color: context.semantic.muted),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              for (final FirstAidTopic topic in recent)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ActionChip(
                    avatar: Icon(topic.icon, size: 18, color: topic.color),
                    label: Text(topic.title.resolve(locale)),
                    onPressed: () => Navigator.of(context)
                        .push(ConditionDetailScreen.route(topic)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: <Widget>[
          Icon(Icons.search_off, size: 48, color: context.semantic.muted),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.texts.bodyLarge?.copyWith(color: context.semantic.muted),
          ),
        ],
      ),
    );
  }
}
