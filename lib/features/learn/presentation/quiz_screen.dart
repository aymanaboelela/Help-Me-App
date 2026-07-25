import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/learn_provider.dart';
import '../model/learn_content.dart';
import 'widgets/question_view.dart';

/// A round of quiz questions, scored, with the reason shown after each answer.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const QuizScreen());

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late final List<QuizQuestion> _questions;
  int _index = 0;
  int _score = 0;
  int? _answer;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _questions = ref.read(quizRoundProvider);
  }

  void _choose(int i) {
    setState(() {
      _answer = i;
      if (i == _questions[_index].answerIndex) _score++;
    });
  }

  Future<void> _advance() async {
    if (_index < _questions.length - 1) {
      setState(() {
        _index++;
        _answer = null;
      });
      return;
    }
    await ref.read(learnProvider.notifier).recordQuiz(_score);
    if (mounted) setState(() => _finished = true);
  }

  void _restart() {
    setState(() {
      _index = 0;
      _score = 0;
      _answer = null;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (_finished) {
      return _Result(
        score: _score,
        total: _questions.length,
        onRetry: _restart,
      );
    }

    final bool answered = _answer != null;
    final bool last = _index == _questions.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quizTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: (_index + 1) / _questions.length,
            minHeight: 3,
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.quizQuestionOf(_index + 1, _questions.length),
              style: context.texts.labelLarge?.copyWith(color: context.semantic.muted),
            ),
            const SizedBox(height: 14),
            QuestionView(
              question: _questions[_index],
              chosen: _answer,
              onChoose: _choose,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 14),
        child: FilledButton(
          onPressed: answered ? _advance : null,
          child: Text(last ? l10n.quizSeeResult : l10n.quizNext),
        ),
      ),
    );
  }
}

class _Result extends ConsumerWidget {
  const _Result({required this.score, required this.total, required this.onRetry});

  final int score;
  final int total;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final double ratio = total == 0 ? 0 : score / total;
    final String verdict = ratio == 1
        ? l10n.quizPerfect
        : ratio >= 0.6
            ? l10n.quizGood
            : l10n.quizKeepGoing;
    final Color accent = ratio == 1
        ? context.semantic.success
        : ratio >= 0.6
            ? context.colors.primary
            : context.semantic.warning;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.quizTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 128,
                height: 128,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$score',
                  style: context.texts.displaySmall
                      ?.copyWith(color: accent, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 18),
              Text(l10n.quizScore(score, total), style: context.texts.titleLarge),
              const SizedBox(height: 8),
              Text(
                verdict,
                textAlign: TextAlign.center,
                style: context.texts.bodyLarge?.copyWith(color: context.semantic.muted),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: onRetry, child: Text(l10n.quizAgain)),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.commonDone),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
