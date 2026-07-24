import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/call_action.dart';
import '../../../core/widgets/callout_box.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/favorites_provider.dart';
import '../../emergency/data/emergency_numbers.dart';
import '../category_display.dart';
import '../model/first_aid_topic.dart';

/// Full first-aid instructions for a single [FirstAidTopic].
class ConditionDetailScreen extends ConsumerWidget {
  const ConditionDetailScreen({super.key, required this.topic});

  final FirstAidTopic topic;

  static Route<void> route(FirstAidTopic topic) => MaterialPageRoute<void>(
        builder: (_) => ConditionDetailScreen(topic: topic),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Locale locale = context.locale;
    final bool isFavorite = ref.watch(favoritesProvider).contains(topic.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(topic.title.resolve(locale)),
        actions: <Widget>[
          IconButton(
            onPressed: () => ref.read(favoritesProvider.notifier).toggle(topic.id),
            tooltip: isFavorite ? l10n.removeFavorite : l10n.addFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? context.colors.primary : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          _Header(topic: topic),
          if (topic.overview != null) ...<Widget>[
            const SizedBox(height: 16),
            Text(topic.overview!.resolve(locale), style: context.texts.bodyLarge),
          ],
          const SizedBox(height: 16),
          _DisclaimerNote(text: l10n.detailDisclaimer),
          for (final FirstAidSection section in topic.sections) ...<Widget>[
            const SizedBox(height: 20),
            _SectionView(section: section, accent: topic.color),
          ],
        ],
      ),
      bottomNavigationBar: topic.showCallAmbulance
          ? _CallAmbulanceBar(label: l10n.callAmbulance)
          : null,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.topic});

  final FirstAidTopic topic;

  @override
  Widget build(BuildContext context) {
    final Locale locale = context.locale;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: topic.color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(topic.icon, color: topic.color, size: 34),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                topic.category.label(AppLocalizations.of(context)),
                style: context.texts.labelMedium?.copyWith(color: topic.color),
              ),
              const SizedBox(height: 2),
              Text(topic.summary.resolve(locale), style: context.texts.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _DisclaimerNote extends StatelessWidget {
  const _DisclaimerNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(Icons.info_outline, size: 18, color: context.semantic.muted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: context.texts.bodySmall?.copyWith(
              color: context.semantic.muted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionView extends StatelessWidget {
  const _SectionView({required this.section, required this.accent});

  final FirstAidSection section;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final Locale locale = context.locale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(width: 4, height: 20, color: accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                section.title.resolve(locale),
                style: context.texts.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < section.steps.length; i++) ...<Widget>[
          _StepRow(number: i + 1, text: section.steps[i].resolve(locale), accent: accent),
          if (i != section.steps.length - 1) const SizedBox(height: 10),
        ],
        for (final FirstAidCallout callout in section.callouts) ...<Widget>[
          const SizedBox(height: 12),
          CalloutBox(type: callout.type, text: callout.text.resolve(locale)),
        ],
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text, required this.accent});

  final int number;
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: context.texts.labelLarge?.copyWith(color: accent),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(text, style: context.texts.bodyLarge),
          ),
        ),
      ],
    );
  }
}

class _CallAmbulanceBar extends StatelessWidget {
  const _CallAmbulanceBar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: FilledButton.icon(
        onPressed: () => callWithFeedback(context, kAmbulance.number),
        icon: const Icon(Icons.call),
        label: Text('$label · ${kAmbulance.number}'),
      ),
    );
  }
}
