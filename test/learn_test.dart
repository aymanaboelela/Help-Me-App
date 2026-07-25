import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/features/conditions/data/first_aid_data.dart';
import 'package:help_me/features/conditions/model/first_aid_topic.dart';
import 'package:help_me/features/learn/data/daily_tips.dart';
import 'package:help_me/features/learn/data/lessons.dart';
import 'package:help_me/features/learn/data/quiz_bank.dart';
import 'package:help_me/features/learn/data/tip_of_day.dart';
import 'package:help_me/features/learn/model/learn_content.dart';
import 'package:help_me/providers/learn_provider.dart';
import 'package:help_me/providers/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container([
  Map<String, Object> seed = const <String, Object>{},
]) async {
  SharedPreferences.setMockInitialValues(seed);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

String _day(DateTime d) => DateTime(d.year, d.month, d.day).toIso8601String();

void main() {
  final Set<String> topicIds =
      kFirstAidTopics.map((FirstAidTopic t) => t.id).toSet();

  group('Daily tips', () {
    test('Given the catalogue, Then every id is unique', () {
      final List<String> ids = kDailyTips.map((DailyTip t) => t.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('Given every tip, Then its text is bilingual and complete', () {
      for (final DailyTip tip in kDailyTips) {
        expect(tip.text.isComplete, isTrue, reason: tip.id);
      }
    });

    test('Given a tip that names a topic, Then the topic exists', () {
      for (final DailyTip tip in kDailyTips) {
        if (tip.topicId == null) continue;
        expect(topicIds, contains(tip.topicId), reason: tip.id);
      }
    });

    test('Given more than a month of tips, Then none repeats within a month', () {
      expect(kDailyTips.length, greaterThan(31));
      final DateTime start = DateTime.utc(2026, 3, 1);
      final Set<String> seen = <String>{};
      for (int i = 0; i < 31; i++) {
        seen.add(tipForDate(start.add(Duration(days: i))).id);
      }
      expect(seen.length, 31);
    });

    test('Given the same date, Then the tip is always the same', () {
      final DateTime date = DateTime.utc(2026, 7, 25);
      expect(tipForDate(date).id, tipForDate(date).id);
    });
  });

  group('Lessons', () {
    test('Given the catalogue, Then every id is unique', () {
      final List<String> ids = kLessons.map((Lesson l) => l.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('Given every lesson, Then all of its text is bilingual', () {
      for (final Lesson lesson in kLessons) {
        expect(lesson.title.isComplete, isTrue, reason: lesson.id);
        expect(lesson.summary.isComplete, isTrue, reason: lesson.id);
        expect(lesson.cards, isNotEmpty, reason: lesson.id);
        for (final LessonCard card in lesson.cards) {
          expect(card.title.isComplete, isTrue, reason: lesson.id);
          expect(card.body.isComplete, isTrue, reason: lesson.id);
        }
      }
    });

    test('Given a lesson card with art, Then it points at a bundled drawing', () {
      for (final Lesson lesson in kLessons) {
        for (final LessonCard card in lesson.cards) {
          if (card.image == null) continue;
          expect(
            card.image!.startsWith('assets/steps/'),
            isTrue,
            reason: '${lesson.id}: ${card.image}',
          );
        }
      }
    });

    test('Given a lesson that names a topic, Then the topic exists', () {
      for (final Lesson lesson in kLessons) {
        if (lesson.topicId == null) continue;
        expect(topicIds, contains(lesson.topicId), reason: lesson.id);
      }
    });
  });

  group('Quiz bank', () {
    test('Given every question, Then its answer index is in range', () {
      for (final QuizQuestion q in kQuizBank) {
        expect(q.isValid, isTrue, reason: q.id);
        expect(q.answerIndex, lessThan(q.options.length), reason: q.id);
      }
    });

    test('Given every question, Then prompt, options and reason are bilingual', () {
      for (final QuizQuestion q in kQuizBank) {
        expect(q.prompt.isComplete, isTrue, reason: q.id);
        expect(q.explanation.isComplete, isTrue, reason: q.id);
        for (final option in q.options) {
          expect(option.isComplete, isTrue, reason: q.id);
        }
      }
    });

    test('Given the bank, Then ids are unique and it can fill a round', () {
      final List<String> ids = kQuizBank.map((QuizQuestion q) => q.id).toList();
      expect(ids.toSet().length, ids.length);
      expect(kQuizBank.length, greaterThanOrEqualTo(kQuizLength));
    });

    test('Given every question, Then no two options read the same', () {
      for (final QuizQuestion q in kQuizBank) {
        final List<String> english =
            q.options.map((dynamic o) => o.en as String).toList();
        expect(english.toSet().length, english.length, reason: q.id);
      }
    });
  });

  group('Streak', () {
    test('Given a first visit, Then the streak starts at one', () async {
      final ProviderContainer container = await _container();
      await container.read(learnProvider.notifier).touch();
      expect(container.read(learnProvider).streak, 1);
      expect(container.read(learnProvider).longestStreak, 1);
    });

    test('Given two visits the same day, Then the streak does not double', () async {
      final ProviderContainer container = await _container();
      await container.read(learnProvider.notifier).touch();
      await container.read(learnProvider.notifier).touch();
      expect(container.read(learnProvider).streak, 1);
    });

    test('Given a visit yesterday, Then today continues the streak', () async {
      final DateTime yesterday =
          DateTime.now().subtract(const Duration(days: 1));
      final ProviderContainer container = await _container(<String, Object>{
        LearnKeys.streak: 4,
        LearnKeys.longest: 4,
        LearnKeys.lastDay: _day(yesterday),
      });

      await container.read(learnProvider.notifier).touch();

      expect(container.read(learnProvider).streak, 5);
      expect(container.read(learnProvider).longestStreak, 5);
    });

    test('Given a gap, Then the streak restarts but the best is kept', () async {
      final DateTime old = DateTime.now().subtract(const Duration(days: 4));
      final ProviderContainer container = await _container(<String, Object>{
        LearnKeys.streak: 9,
        LearnKeys.longest: 9,
        LearnKeys.lastDay: _day(old),
      });

      await container.read(learnProvider.notifier).touch();

      expect(container.read(learnProvider).streak, 1);
      expect(container.read(learnProvider).longestStreak, 9);
    });

    test('Given a touch, Then it survives a reload', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final ProviderContainer first = ProviderContainer(
        overrides: <Override>[sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      await first.read(learnProvider.notifier).touch();
      first.dispose();

      final ProviderContainer second = ProviderContainer(
        overrides: <Override>[sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(second.dispose);
      expect(second.read(learnProvider).streak, 1);
      expect(second.read(learnProvider).activeToday, isTrue);
    });
  });

  group('Lessons and quiz progress', () {
    test('Given a finished lesson, Then it is recorded once', () async {
      final ProviderContainer container = await _container();
      final LearnNotifier notifier = container.read(learnProvider.notifier);

      await notifier.completeLesson('lesson_cpr');
      await notifier.completeLesson('lesson_cpr');

      expect(container.read(learnProvider).completedLessons, <String>{'lesson_cpr'});
    });

    test('Given quiz rounds, Then the best score is kept and rounds counted', () async {
      final ProviderContainer container = await _container();
      final LearnNotifier notifier = container.read(learnProvider.notifier);

      await notifier.recordQuiz(5);
      await notifier.recordQuiz(3);

      expect(container.read(learnProvider).quizBest, 5);
      expect(container.read(learnProvider).quizTaken, 2);
    });
  });

  group('Badges', () {
    test('Given a fresh reader, Then nothing is earned', () async {
      final ProviderContainer container = await _container();
      expect(
        container.read(badgesProvider).where((EarnedBadge b) => b.earned),
        isEmpty,
      );
    });

    test('Given a week-long streak, Then the seven-day badge is earned', () async {
      final ProviderContainer container = await _container(<String, Object>{
        LearnKeys.longest: 7,
      });
      final EarnedBadge week = container
          .read(badgesProvider)
          .firstWhere((EarnedBadge b) => b.badge.id == 'badge_week');
      expect(week.earned, isTrue);
    });

    test('Given a perfect quiz, Then the full-marks badge is earned', () async {
      final ProviderContainer container = await _container(<String, Object>{
        LearnKeys.quizBest: kQuizLength,
      });
      final EarnedBadge perfect = container
          .read(badgesProvider)
          .firstWhere((EarnedBadge b) => b.badge.id == 'badge_perfect_quiz');
      expect(perfect.earned, isTrue);
    });

    test('Given every lesson finished, Then the completion badge is earned', () async {
      final ProviderContainer container = await _container(<String, Object>{
        LearnKeys.lessons: kLessons.map((Lesson l) => l.id).toList(),
      });
      final EarnedBadge all = container
          .read(badgesProvider)
          .firstWhere((EarnedBadge b) => b.badge.id == 'badge_all_lessons');
      expect(all.earned, isTrue);
    });
  });

  group('Quiz round', () {
    test('Given a round, Then it holds the right number of distinct questions',
        () async {
      final ProviderContainer container = await _container();
      final List<QuizQuestion> round = container.read(quizRoundProvider);

      expect(round.length, kQuizLength);
      expect(round.map((QuizQuestion q) => q.id).toSet().length, kQuizLength);
    });

    test('Given more rounds taken, Then the questions move on', () async {
      final ProviderContainer first = await _container();
      final ProviderContainer second = await _container(<String, Object>{
        LearnKeys.quizTaken: 1,
      });

      expect(
        first.read(quizRoundProvider).first.id,
        isNot(second.read(quizRoundProvider).first.id),
      );
    });
  });

  group('Tip reminder', () {
    test('Given no setting, Then it is off', () async {
      final ProviderContainer container = await _container();
      expect(container.read(tipReminderProvider), isNull);
    });

    test('Given a time, Then it is stored and can be cleared', () async {
      final ProviderContainer container = await _container();
      final TipReminderNotifier notifier =
          container.read(tipReminderProvider.notifier);

      await notifier.setMinutes(9 * 60);
      expect(container.read(tipReminderProvider), 540);

      await notifier.setMinutes(null);
      expect(container.read(tipReminderProvider), isNull);
    });
  });
}
