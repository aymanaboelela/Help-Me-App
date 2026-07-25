import 'package:flutter/widgets.dart';

import '../../../core/localized_text.dart';

/// One short, actionable fact — the thing the app shows you on an ordinary day.
@immutable
class DailyTip {
  const DailyTip({required this.id, required this.text, this.topicId});

  final String id;
  final LocalizedText text;

  /// The first-aid topic this belongs to, so the tip can link somewhere useful.
  final String? topicId;
}

/// A single card inside a lesson: one idea, stated once.
@immutable
class LessonCard {
  const LessonCard({required this.title, required this.body, this.image});

  final LocalizedText title;
  final LocalizedText body;

  /// An optional step illustration from `assets/steps/`.
  final String? image;
}

/// A multiple-choice question.
///
/// The explanation shows after *every* answer, right and wrong — being told why
/// you were right is what turns a lucky guess into knowledge.
@immutable
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.answerIndex,
    required this.explanation,
    this.topicId,
  });

  final String id;
  final LocalizedText prompt;
  final List<LocalizedText> options;
  final int answerIndex;
  final LocalizedText explanation;
  final String? topicId;

  bool get isValid =>
      options.length >= 2 && answerIndex >= 0 && answerIndex < options.length;
}

/// A few cards and one check question — short enough to finish while the kettle
/// boils, which is the only length anybody actually completes.
@immutable
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.summary,
    required this.icon,
    required this.color,
    required this.cards,
    required this.check,
    this.topicId,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText summary;
  final IconData icon;
  final Color color;
  final List<LessonCard> cards;

  /// The question asked at the end.
  final QuizQuestion check;

  final String? topicId;
}

/// Something earned by turning up. Deliberately gentle: no streak-loss warnings,
/// no shaming copy. This is a first-aid app, not a habit casino.
@immutable
class Badge {
  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  final String id;
  final LocalizedText name;
  final LocalizedText description;
  final IconData icon;
}
