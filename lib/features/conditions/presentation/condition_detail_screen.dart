import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/call_action.dart';
import '../../../core/localized_text.dart';
import '../../../core/media/topic_media.dart';
import '../../../core/widgets/callout_box.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/country_provider.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/recent_provider.dart';
import '../../tools/cpr_metronome_screen.dart';
import '../../tools/emergency_timer_sheet.dart';
import '../../tools/focus_mode_screen.dart';
import '../category_display.dart';
import '../data/topic_media_data.dart';
import '../model/first_aid_topic.dart';
import 'widgets/topic_gallery.dart';
import 'widgets/topic_videos.dart';

/// Full first-aid instructions for a single [FirstAidTopic], with read-aloud,
/// focus mode, an emergency timer, and (for CPR) a compression metronome.
class ConditionDetailScreen extends ConsumerStatefulWidget {
  const ConditionDetailScreen({super.key, required this.topic});

  final FirstAidTopic topic;

  static Route<void> route(FirstAidTopic topic) => MaterialPageRoute<void>(
        builder: (_) => ConditionDetailScreen(topic: topic),
      );

  @override
  ConsumerState<ConditionDetailScreen> createState() => _ConditionDetailScreenState();
}

class _ConditionDetailScreenState extends ConsumerState<ConditionDetailScreen> {
  FlutterTts? _tts;
  bool _speaking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(recentProvider.notifier).touch(widget.topic.id);
    });
  }

  Future<void> _toggleSpeech(Locale locale) async {
    if (_speaking) {
      await _tts?.stop();
      if (mounted) setState(() => _speaking = false);
      return;
    }
    final FlutterTts tts = _tts ??= FlutterTts();
    tts.setCompletionHandler(() {
      if (mounted) setState(() => _speaking = false);
    });
    await tts.setLanguage(locale.languageCode == 'ar' ? 'ar-SA' : 'en-US');
    await tts.setSpeechRate(0.5);
    await tts.speak(_speech(locale));
    if (mounted) setState(() => _speaking = true);
  }

  String _speech(Locale locale) {
    final FirstAidTopic t = widget.topic;
    final StringBuffer buffer = StringBuffer()
      ..writeln(t.title.resolve(locale))
      ..writeln(t.summary.resolve(locale));
    if (t.overview != null) buffer.writeln(t.overview!.resolve(locale));
    int i = 1;
    for (final LocalizedText step in t.allSteps) {
      buffer.writeln('$i. ${step.resolve(locale)}');
      i++;
    }
    return buffer.toString();
  }

  @override
  void dispose() {
    _tts?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Locale locale = context.locale;
    final FirstAidTopic topic = widget.topic;
    final bool isFavorite = ref.watch(favoritesProvider).contains(topic.id);
    final String ambulance = ref.watch(countryProvider).ambulance.number;
    final TopicMedia media = kTopicMedia[topic.id] ?? const TopicMedia();

    return Scaffold(
      appBar: AppBar(
        title: Text(topic.title.resolve(locale)),
        actions: <Widget>[
          IconButton(
            onPressed: () => _toggleSpeech(locale),
            tooltip: _speaking ? l10n.stopListening : l10n.listen,
            icon: Icon(_speaking ? Icons.stop_circle : Icons.volume_up_outlined),
          ),
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
          if (media.images.isEmpty)
            _HeroIllustration(topic: topic)
          else
            TopicGallery(images: media.images, accent: topic.color),
          const SizedBox(height: 4),
          _Header(topic: topic),
          if (topic.overview != null) ...<Widget>[
            const SizedBox(height: 16),
            Text(topic.overview!.resolve(locale), style: context.texts.bodyLarge),
          ],
          const SizedBox(height: 16),
          _ToolsRow(topic: topic),
          const SizedBox(height: 16),
          _DisclaimerNote(text: l10n.detailDisclaimer),
          for (final FirstAidSection section in topic.sections) ...<Widget>[
            const SizedBox(height: 20),
            _SectionView(section: section, accent: topic.color),
          ],
          if (media.videos.isNotEmpty) ...<Widget>[
            const SizedBox(height: 24),
            TopicVideos(videos: media.videos, accent: topic.color),
          ],
        ],
      ),
      bottomNavigationBar: topic.showCallAmbulance
          ? _CallAmbulanceBar(label: l10n.callAmbulance, number: ambulance)
          : null,
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration({required this.topic});

  final FirstAidTopic topic;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: topic.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      padding: const EdgeInsets.all(16),
      child: SvgPicture.asset(
        topic.category.illustration,
        height: 138,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _ToolsRow extends StatelessWidget {
  const _ToolsRow({required this.topic});

  final FirstAidTopic topic;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        ActionChip(
          avatar: const Icon(Icons.view_carousel_outlined, size: 18),
          label: Text(l10n.focusMode),
          onPressed: () => Navigator.of(context).push(FocusModeScreen.route(topic)),
        ),
        ActionChip(
          avatar: const Icon(Icons.timer_outlined, size: 18),
          label: Text(l10n.timerTitle),
          onPressed: () => showEmergencyTimer(context),
        ),
        if (topic.showMetronome)
          ActionChip(
            avatar: const Icon(Icons.favorite, size: 18),
            label: Text(l10n.metronomeTitle),
            onPressed: () => Navigator.of(context).push(CprMetronomeScreen.route()),
          ),
      ],
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
  const _CallAmbulanceBar({required this.label, required this.number});

  final String label;
  final String number;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: FilledButton.icon(
        onPressed: () => callWithFeedback(context, number),
        icon: const Icon(Icons.call),
        label: Text('$label · $number'),
      ),
    );
  }
}
