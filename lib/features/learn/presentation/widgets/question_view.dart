import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../model/learn_content.dart';

/// One multiple-choice question with its answer feedback.
///
/// The explanation appears after every answer, right or wrong. Being told why
/// you were right is what separates knowing from having guessed — and in first
/// aid the reason is the part you need under pressure.
class QuestionView extends StatelessWidget {
  const QuestionView({
    super.key,
    required this.question,
    required this.chosen,
    required this.onChoose,
  });

  final QuizQuestion question;
  final int? chosen;
  final ValueChanged<int> onChoose;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Locale locale = context.locale;
    final bool answered = chosen != null;
    final bool correct = chosen == question.answerIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          question.prompt.resolve(locale),
          style: context.texts.titleLarge?.copyWith(height: 1.4),
        ),
        const SizedBox(height: 18),
        for (int i = 0; i < question.options.length; i++) ...<Widget>[
          _Option(
            text: question.options[i].resolve(locale),
            state: !answered
                ? _OptionState.idle
                : i == question.answerIndex
                    ? _OptionState.correct
                    : i == chosen
                        ? _OptionState.wrong
                        : _OptionState.dimmed,
            onTap: answered ? null : () => onChoose(i),
          ),
          const SizedBox(height: 10),
        ],
        if (answered) ...<Widget>[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: (correct ? context.semantic.safe : context.semantic.urgent)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      correct ? Icons.check_circle : Icons.info_outline,
                      size: 18,
                      color: correct
                          ? context.semantic.safe
                          : context.semantic.urgent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      correct ? l10n.quizCorrect : l10n.quizWrong,
                      style: context.texts.labelLarge?.copyWith(
                        color: correct
                            ? context.semantic.safe
                            : context.semantic.urgent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  question.explanation.resolve(locale),
                  style: context.texts.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

enum _OptionState { idle, correct, wrong, dimmed }

class _Option extends StatelessWidget {
  const _Option({required this.text, required this.state, required this.onTap});

  final String text;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (Color border, Color fill, IconData? icon, Color? iconColour) =
        switch (state) {
      _OptionState.idle => (
          context.semantic.hairline,
          Colors.transparent,
          null,
          null,
        ),
      _OptionState.correct => (
          context.semantic.safe,
          context.semantic.safe.withValues(alpha: 0.12),
          Icons.check_circle,
          context.semantic.safe,
        ),
      _OptionState.wrong => (
          context.semantic.immediate,
          context.semantic.immediate.withValues(alpha: 0.10),
          Icons.cancel_outlined,
          context.semantic.immediate,
        ),
      _OptionState.dimmed => (
          context.semantic.hairline,
          Colors.transparent,
          null,
          null,
        ),
    };

    return Opacity(
      opacity: state == _OptionState.dimmed ? 0.5 : 1,
      child: Material(
        color: fill,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: border, width: 1.4),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              children: <Widget>[
                Expanded(child: Text(text, style: context.texts.bodyLarge)),
                if (icon != null) ...<Widget>[
                  const SizedBox(width: 10),
                  Icon(icon, size: 20, color: iconColour),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
