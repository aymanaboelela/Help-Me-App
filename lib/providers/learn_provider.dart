import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/localized_text.dart';
import '../features/learn/data/lessons.dart';
import '../features/learn/data/quiz_bank.dart';
import '../features/learn/data/tip_of_day.dart';
import '../features/learn/model/learn_content.dart';
import '../services/reminder_plan.dart';
import 'preferences.dart';

abstract final class LearnKeys {
  static const String streak = 'learn.streak';
  static const String longest = 'learn.longest';
  static const String lastDay = 'learn.last_day';
  static const String lessons = 'learn.lessons_done';
  static const String quizBest = 'learn.quiz_best';
  static const String quizTaken = 'learn.quiz_taken';
  static const String tipMinute = 'learn.tip_minute';
}

/// What the reader has done so far. Not sensitive, so it lives in plain
/// preferences next to the theme and favourites.
@immutable
class LearnProgress {
  const LearnProgress({
    this.streak = 0,
    this.longestStreak = 0,
    this.lastDay,
    this.completedLessons = const <String>{},
    this.quizBest = 0,
    this.quizTaken = 0,
  });

  final int streak;
  final int longestStreak;

  /// Date-only, so a study session at 23:59 and one at 00:01 count as two days.
  final DateTime? lastDay;
  final Set<String> completedLessons;
  final int quizBest;
  final int quizTaken;

  bool get activeToday => lastDay != null && _sameDay(lastDay!, DateTime.now());

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  LearnProgress copyWith({
    int? streak,
    int? longestStreak,
    DateTime? lastDay,
    Set<String>? completedLessons,
    int? quizBest,
    int? quizTaken,
  }) {
    return LearnProgress(
      streak: streak ?? this.streak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastDay: lastDay ?? this.lastDay,
      completedLessons: completedLessons ?? this.completedLessons,
      quizBest: quizBest ?? this.quizBest,
      quizTaken: quizTaken ?? this.quizTaken,
    );
  }
}

/// Tracks the streak and what has been finished.
///
/// The streak is deliberately gentle: it grows by turning up and quietly resets
/// after a gap. There is no warning that it is about to break and no way to buy
/// it back. This is a first-aid app, not a habit casino.
class LearnNotifier extends Notifier<LearnProgress> {
  @override
  LearnProgress build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final String? raw = prefs.getString(LearnKeys.lastDay);
    return LearnProgress(
      streak: prefs.getInt(LearnKeys.streak) ?? 0,
      longestStreak: prefs.getInt(LearnKeys.longest) ?? 0,
      lastDay: raw == null ? null : DateTime.tryParse(raw),
      completedLessons:
          prefs.getStringList(LearnKeys.lessons)?.toSet() ?? <String>{},
      quizBest: prefs.getInt(LearnKeys.quizBest) ?? 0,
      quizTaken: prefs.getInt(LearnKeys.quizTaken) ?? 0,
    );
  }

  /// Call whenever the reader does something: opens a lesson, answers a quiz,
  /// reads the day's tip. Repeats on the same day are free.
  Future<void> touch() async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime? last = state.lastDay;
    if (last != null && LearnProgress._sameDay(last, today)) return;

    final bool consecutive = last != null &&
        LearnProgress._sameDay(last.add(const Duration(days: 1)), today);
    final int streak = consecutive ? state.streak + 1 : 1;

    state = state.copyWith(
      streak: streak,
      longestStreak: streak > state.longestStreak ? streak : state.longestStreak,
      lastDay: today,
    );
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(LearnKeys.streak, state.streak);
    await prefs.setInt(LearnKeys.longest, state.longestStreak);
    await prefs.setString(LearnKeys.lastDay, today.toIso8601String());
  }

  Future<void> completeLesson(String id) async {
    await touch();
    if (state.completedLessons.contains(id)) return;
    state = state.copyWith(
      completedLessons: <String>{...state.completedLessons, id},
    );
    await ref
        .read(sharedPreferencesProvider)
        .setStringList(LearnKeys.lessons, state.completedLessons.toList());
  }

  Future<void> recordQuiz(int score) async {
    await touch();
    state = state.copyWith(
      quizTaken: state.quizTaken + 1,
      quizBest: score > state.quizBest ? score : state.quizBest,
    );
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(LearnKeys.quizTaken, state.quizTaken);
    await prefs.setInt(LearnKeys.quizBest, state.quizBest);
  }
}

final NotifierProvider<LearnNotifier, LearnProgress> learnProvider =
    NotifierProvider<LearnNotifier, LearnProgress>(LearnNotifier.new);

/// The tip for today.
///
/// Shares [tipForDate] with the tip *notification*, which has to work out the
/// same answer for days that have not arrived yet — if these two ever disagreed,
/// the notification would announce a different tip from the one on screen.
final Provider<DailyTip> dailyTipProvider =
    Provider<DailyTip>((Ref ref) => tipForDate(DateTime.now()));

/// A badge and whether it has been earned.
@immutable
class EarnedBadge {
  const EarnedBadge({required this.badge, required this.earned});

  final LearnBadge badge;
  final bool earned;
}

const List<LearnBadge> kBadges = <LearnBadge>[
  LearnBadge(
    id: 'badge_first_lesson',
    icon: Icons.school_outlined,
    name: LocalizedText(en: 'First lesson', ar: 'أول درس'),
    description: LocalizedText(en: 'Finish any lesson.', ar: 'خلّص أي درس.'),
  ),
  LearnBadge(
    id: 'badge_week',
    icon: Icons.local_fire_department_outlined,
    name: LocalizedText(en: 'Seven days', ar: 'سبع أيام'),
    description: LocalizedText(
      en: 'Come back seven days in a row.',
      ar: 'ترجع سبع أيام ورا بعض.',
    ),
  ),
  LearnBadge(
    id: 'badge_month',
    icon: Icons.calendar_month_outlined,
    name: LocalizedText(en: 'A month', ar: 'شهر كامل'),
    description: LocalizedText(
      en: 'Thirty days in a row.',
      ar: 'تلاتين يوم ورا بعض.',
    ),
  ),
  LearnBadge(
    id: 'badge_all_lessons',
    icon: Icons.workspace_premium_outlined,
    name: LocalizedText(en: 'Every lesson', ar: 'كل الدروس'),
    description: LocalizedText(
      en: 'Finish all of them.',
      ar: 'تخلّص الدروس كلها.',
    ),
  ),
  LearnBadge(
    id: 'badge_perfect_quiz',
    icon: Icons.check_circle_outline,
    name: LocalizedText(en: 'Full marks', ar: 'الدرجة كاملة'),
    description: LocalizedText(
      en: 'Answer a whole quiz correctly.',
      ar: 'تجاوب اختبار كامل صح.',
    ),
  ),
];

/// How many questions one round of the quiz asks.
const int kQuizLength = 8;

final Provider<List<EarnedBadge>> badgesProvider = Provider<List<EarnedBadge>>(
  (Ref ref) {
    final LearnProgress p = ref.watch(learnProvider);
    bool earned(String id) => switch (id) {
          'badge_first_lesson' => p.completedLessons.isNotEmpty,
          'badge_week' => p.longestStreak >= 7,
          'badge_month' => p.longestStreak >= 30,
          'badge_all_lessons' => p.completedLessons.length >= kLessons.length,
          'badge_perfect_quiz' => p.quizBest >= kQuizLength,
          _ => false,
        };
    return <EarnedBadge>[
      for (final LearnBadge badge in kBadges)
        EarnedBadge(badge: badge, earned: earned(badge.id)),
    ];
  },
);

/// The questions for one round, rotated by day so the same eight are not asked
/// every time, but the order is stable within a day.
final Provider<List<QuizQuestion>> quizRoundProvider = Provider<List<QuizQuestion>>(
  (Ref ref) {
    final List<QuizQuestion> bank = kQuizBank;
    final int taken = ref.watch(learnProvider).quizTaken;
    final DateTime now = DateTime.now();
    final int offset =
        (now.difference(DateTime(now.year)).inDays + taken * kQuizLength) %
            bank.length;
    return <QuizQuestion>[
      for (int i = 0; i < kQuizLength && i < bank.length; i++)
        bank[(offset + i) % bank.length],
    ];
  },
);

/// The time of day the daily-tip notification fires, as minutes after midnight,
/// or null when the reader has not asked for one.
class TipReminderNotifier extends Notifier<int?> {
  /// Shared with the reminder planner, which rebuilds this same notification on
  /// every launch so it survives a reinstall or a restored backup.
  static final int notificationId = tipReminderNotificationId;

  @override
  int? build() {
    final int value =
        ref.watch(sharedPreferencesProvider).getInt(LearnKeys.tipMinute) ?? -1;
    return value < 0 ? null : value;
  }

  /// Stores the time, or null to switch the tip off.
  ///
  /// Only stores it. Putting the phone's pending notifications back in line is
  /// `reminderSyncProvider`'s job, so every path that changes a reminder — a
  /// switch, a medicine, a language change, an app launch — ends at the same
  /// rebuild instead of each editing the schedule its own way.
  Future<void> setMinutes(int? minutes) async {
    state = minutes;
    await ref
        .read(sharedPreferencesProvider)
        .setInt(LearnKeys.tipMinute, minutes ?? -1);
  }
}

final NotifierProvider<TipReminderNotifier, int?> tipReminderProvider =
    NotifierProvider<TipReminderNotifier, int?>(TipReminderNotifier.new);
