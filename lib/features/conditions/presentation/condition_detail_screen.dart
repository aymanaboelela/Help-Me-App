import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/call_action.dart';
import '../../../core/media/topic_media.dart';
import '../../../core/speech.dart';
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
import 'widgets/age_switch.dart';
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

/// One utterance, plus the step it belongs to so the screen can follow along.
///
/// Headings carry the step they follow rather than null: while a section's
/// closing warning is being read, keeping the last step lit reads as "still
/// here" instead of "stopped".
class _SpokenLine {
  const _SpokenLine(this.text, this.step);

  final String text;
  final int? step;
}

class _ConditionDetailScreenState extends ConsumerState<ConditionDetailScreen> {
  Speech? _speech;
  bool _speaking = false;

  /// Index into [FirstAidTopic.allSteps] of the step being read, if any.
  int? _activeStep;

  /// Whose steps are showing. Deliberately not persisted and reset on every
  /// mount: a remembered "infant" applied to an adult in cardiac arrest is a
  /// fatal error that gives no signal it has happened.
  AgeGroup _age = AgeGroup.adult;

  /// One per step, so the step being read can be scrolled into view.
  final Map<int, GlobalKey> _stepKeys = <int, GlobalKey>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(recentProvider.notifier).touch(widget.topic.id);
    });
  }

  Future<void> _toggleSpeech(Locale locale) async {
    if (_speaking) {
      await _speech?.stop();
      return;
    }
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<_SpokenLine> lines = _script(locale, l10n);
    final Speech speech = _speech ??= Speech();

    setState(() {
      _speaking = true;
      _activeStep = null;
    });

    final bool spoke = await speech.speakLines(
      lines.map((_SpokenLine l) => l.text).toList(),
      locale,
      onLine: (int i) => _onLineStarted(lines[i].step),
    );

    if (!mounted) return;
    setState(() {
      _speaking = false;
      _activeStep = null;
    });
    if (!spoke) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.ttsUnavailable)));
    }
  }

  void _onLineStarted(int? step) {
    if (!mounted || step == _activeStep) return;
    setState(() => _activeStep = step);
    if (step == null) return;
    final BuildContext? target = _stepKeys[step]?.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      alignment: 0.25,
    );
  }

  /// Changes whose steps are shown, and stops read-aloud if it is running.
  ///
  /// Continuing to speak adult steps under an infant banner is the exact
  /// confusion this feature exists to prevent.
  void _setAge(AgeGroup group) {
    if (group == _age) return;
    _speech?.stop();
    setState(() {
      _age = group;
      _activeStep = null;
      _stepKeys.clear();
    });
  }

  /// Builds the read-aloud script, one utterance per line.
  ///
  /// Sentences are handed over separately rather than as one block so the
  /// engine breathes between them — and so a listener kneeling over someone can
  /// tell which step they are on. Callouts are included because a section's
  /// "do NOT" warning is the last thing that should be skipped.
  List<_SpokenLine> _script(Locale locale, AppLocalizations l10n) {
    final FirstAidTopic topic = widget.topic;
    final List<_SpokenLine> lines = <_SpokenLine>[
      _SpokenLine(topic.title.resolve(locale), null),
      _SpokenLine(topic.summary.resolve(locale), null),
      if (topic.overview != null) _SpokenLine(topic.overview!.resolve(locale), null),
    ];

    int step = 0;
    for (final FirstAidSection section in topic.sectionsFor(_age)) {
      lines.add(_SpokenLine(section.title.resolve(locale), null));
      for (int i = 0; i < section.steps.length; i++) {
        // Numbered within the section, matching the screen — the section title
        // was just read, so "step one" is unambiguous.
        lines.add(
          _SpokenLine(
            '${l10n.speechStep(i + 1)} ${section.steps[i].resolve(locale)}',
            step,
          ),
        );
        step++;
      }
      for (final FirstAidCallout callout in section.callouts) {
        lines.add(_SpokenLine(callout.text.resolve(locale), step - 1));
      }
    }
    return lines;
  }

  /// The section list, handing each one the index its first step occupies in
  /// [FirstAidTopic.allSteps] so highlighting can be addressed topic-wide.
  List<Widget> _sections(FirstAidTopic topic) {
    final List<Widget> widgets = <Widget>[];
    int offset = 0;
    for (final FirstAidSection section in topic.sectionsFor(_age)) {
      widgets
        ..add(const SizedBox(height: 20))
        ..add(
          _SectionView(
            section: section,
            accent: topic.color,
            firstStep: offset,
            activeStep: _activeStep,
            stepKeys: _stepKeys,
          ),
        );
      offset += section.steps.length;
    }
    return widgets;
  }

  @override
  void dispose() {
    _speech?.stop();
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
          if (topic.hasAgeVariants) ...<Widget>[
            const SizedBox(height: 16),
            AgeSwitch(
              options: topic.ageOptions,
              selected: _age,
              onChanged: _setAge,
              accent: topic.color,
            ),
            if (_age != AgeGroup.adult) ...<Widget>[
              const SizedBox(height: 12),
              AgeBanner(group: _age, accent: topic.color),
            ],
          ],
          ..._sections(topic),
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
  const _SectionView({
    required this.section,
    required this.accent,
    required this.firstStep,
    required this.activeStep,
    required this.stepKeys,
  });

  final FirstAidSection section;
  final Color accent;

  /// Index of this section's first step within [FirstAidTopic.allSteps].
  final int firstStep;

  /// The step currently being read aloud, topic-wide.
  final int? activeStep;

  final Map<int, GlobalKey> stepKeys;

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
          _StepRow(
            key: stepKeys.putIfAbsent(firstStep + i, GlobalKey.new),
            number: i + 1,
            text: section.steps[i].resolve(locale),
            accent: accent,
            speaking: activeStep == firstStep + i,
          ),
          if (i != section.steps.length - 1) const SizedBox(height: 4),
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
  const _StepRow({
    super.key,
    required this.number,
    required this.text,
    required this.accent,
    this.speaking = false,
  });

  final int number;
  final String text;
  final Color accent;

  /// Whether the read-aloud is on this step right now.
  final bool speaking;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: speaking ? accent.withValues(alpha: 0.10) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: speaking ? accent.withValues(alpha: 0.45) : Colors.transparent,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: speaking ? accent : accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: speaking
                ? const Icon(Icons.volume_up, size: 16, color: Colors.white)
                : Text(
                    '$number',
                    style: context.texts.labelLarge?.copyWith(color: accent),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: context.texts.bodyLarge?.copyWith(
                  fontWeight: speaking ? FontWeight.w600 : null,
                ),
              ),
            ),
          ),
        ],
      ),
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
