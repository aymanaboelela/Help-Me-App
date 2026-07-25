import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/widgets/accent_tile.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/learn_provider.dart';
import '../../../providers/reminder_sync_provider.dart';
import '../../conditions/data/first_aid_data.dart';
import '../../conditions/model/first_aid_topic.dart';
import '../../conditions/presentation/condition_detail_screen.dart';
import '../data/lessons.dart';
import '../model/learn_content.dart';
import 'lesson_screen.dart';
import 'quiz_screen.dart';

/// The "learn" tab: the day's tip, the lessons, the quiz, and the streak.
///
/// This is the answer to "why would anyone open a first-aid app on a Tuesday".
class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LearnProgress progress = ref.watch(learnProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.learnTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: <Widget>[
          _StreakCard(progress: progress),
          const SizedBox(height: 16),
          const _TipCard(),
          const SizedBox(height: 22),
          _SectionHeader(
            title: l10n.lessonsTitle,
            trailing: l10n.lessonsProgress(
              progress.completedLessons.length,
              kLessons.length,
            ),
          ),
          const SizedBox(height: 10),
          for (final Lesson lesson in kLessons) ...<Widget>[
            _LessonTile(
              lesson: lesson,
              done: progress.completedLessons.contains(lesson.id),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 12),
          const _QuizCard(),
          const SizedBox(height: 22),
          _SectionHeader(title: l10n.badgesTitle),
          const SizedBox(height: 10),
          const _Badges(),
        ],
      ),
    );
  }
}

class _StreakCard extends ConsumerWidget {
  const _StreakCard({required this.progress});

  final LearnProgress progress;

  Future<void> _pickReminder(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final int? current = ref.read(tipReminderProvider);

    final TimeOfDay? picked = await showAdaptiveTime(
      context,
      initialTime: current == null
          ? const TimeOfDay(hour: 20, minute: 0)
          : TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked == null) return;
    await ref
        .read(tipReminderProvider.notifier)
        .setMinutes(picked.hour * 60 + picked.minute);
    final bool allowed = await ref
        .read(reminderSyncProvider)
        .rebuildAll(requestPermission: true);
    if (!allowed) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.notificationsBlocked)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int? reminder = ref.watch(tipReminderProvider);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.semantic.urgent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    color: context.semantic.urgent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.learnStreakDays(progress.streak),
                        style: context.texts.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        progress.longestStreak > 0
                            ? l10n.learnBestStreak(progress.longestStreak)
                            : l10n.learnIntro,
                        style: context.texts.bodySmall
                            ?.copyWith(color: context.semantic.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                Icon(
                  Icons.notifications_none,
                  size: 18,
                  color: context.semantic.muted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n.tipReminder, style: context.texts.bodyMedium),
                ),
                TextButton(
                  onPressed: () => _pickReminder(context, ref),
                  child: Text(
                    reminder == null
                        ? l10n.tipReminderOff
                        : '${(reminder ~/ 60).toString().padLeft(2, '0')}:${(reminder % 60).toString().padLeft(2, '0')}',
                  ),
                ),
                if (reminder != null)
                  IconButton(
                    tooltip: l10n.tipReminderOff,
                    iconSize: 18,
                    onPressed: () async {
                      await ref.read(tipReminderProvider.notifier).setMinutes(null);
                      await ref.read(reminderSyncProvider).rebuildAll();
                    },
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends ConsumerWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Locale locale = context.locale;
    final DailyTip tip = ref.watch(dailyTipProvider);
    final FirstAidTopic? topic =
        tip.topicId == null ? null : topicById(tip.topicId!);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.lightbulb_outline, size: 18, color: context.colors.primary),
              const SizedBox(width: 8),
              Text(
                l10n.tipOfTheDay,
                style: context.texts.labelLarge
                    ?.copyWith(color: context.colors.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(tip.text.resolve(locale), style: context.texts.bodyLarge),
          if (topic != null) ...<Widget>[
            const SizedBox(height: 6),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: () {
                  ref.read(learnProvider.notifier).touch();
                  Navigator.of(context).push(ConditionDetailScreen.route(topic));
                },
                child: Text(l10n.learnOpenTopic),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson, required this.done});

  final Lesson lesson;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Locale locale = context.locale;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => Navigator.of(context).push(LessonScreen.route(lesson)),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              AccentTile(
                icon: lesson.icon,
                accent: lesson.color,
                size: 44,
                iconSize: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(lesson.title.resolve(locale), style: context.texts.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      lesson.summary.resolve(locale),
                      style: context.texts.bodySmall
                          ?.copyWith(color: context.semantic.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (done)
                Icon(Icons.check_circle, color: context.semantic.safe, size: 22)
              else
                Text(
                  l10n.lessonStart,
                  style: context.texts.labelMedium
                      ?.copyWith(color: context.colors.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizCard extends ConsumerWidget {
  const _QuizCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LearnProgress progress = ref.watch(learnProvider);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.quiz_outlined, color: context.colors.primary),
                const SizedBox(width: 10),
                Expanded(child: Text(l10n.quizTitle, style: context.texts.titleMedium)),
                if (progress.quizTaken > 0)
                  Text(
                    l10n.quizBest(progress.quizBest),
                    style: context.texts.bodySmall
                        ?.copyWith(color: context.semantic.muted),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n.quizSubtitle,
              style: context.texts.bodyMedium?.copyWith(color: context.semantic.muted),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(QuizScreen.route()),
                child: Text(l10n.quizStart),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badges extends ConsumerWidget {
  const _Badges();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Locale locale = context.locale;
    final List<EarnedBadge> badges = ref.watch(badgesProvider);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: <Widget>[
        for (final EarnedBadge item in badges)
          Tooltip(
            message: item.badge.description.resolve(locale),
            child: Container(
              width: 96,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: item.earned
                    ? context.semantic.safe.withValues(alpha: 0.13)
                    : context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Column(
                children: <Widget>[
                  Icon(
                    item.badge.icon,
                    size: 26,
                    color: item.earned
                        ? context.semantic.safe
                        : context.semantic.muted,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.badge.name.resolve(locale),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: context.texts.labelMedium?.copyWith(
                      color: item.earned ? null : context.semantic.muted,
                    ),
                  ),
                  if (!item.earned) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      l10n.badgeLocked,
                      style: context.texts.labelSmall
                          ?.copyWith(color: context.semantic.muted),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(title, style: context.texts.titleLarge)),
        if (trailing != null)
          Text(
            trailing!,
            style: context.texts.bodySmall?.copyWith(color: context.semantic.muted),
          ),
      ],
    );
  }
}
