import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/learn_provider.dart';
import '../../conditions/data/first_aid_data.dart';
import '../../conditions/model/first_aid_topic.dart';
import '../../conditions/presentation/condition_detail_screen.dart';
import '../model/learn_content.dart';
import 'widgets/question_view.dart';

/// One lesson: swipe through its cards, then answer the check question.
class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, required this.lesson});

  final Lesson lesson;

  static Route<void> route(Lesson lesson) =>
      MaterialPageRoute<void>(builder: (_) => LessonScreen(lesson: lesson));

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  final PageController _controller = PageController();
  int _page = 0;
  int? _answer;

  int get _total => widget.lesson.cards.length + 1;
  bool get _onCheck => _page == widget.lesson.cards.length;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(learnProvider.notifier).touch();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _total - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _finish() async {
    final NavigatorState navigator = Navigator.of(context);
    await ref.read(learnProvider.notifier).completeLesson(widget.lesson.id);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Locale locale = context.locale;
    final Lesson lesson = widget.lesson;
    final FirstAidTopic? topic =
        lesson.topicId == null ? null : topicById(lesson.topicId!);

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title.resolve(locale)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: (_page + 1) / _total,
            minHeight: 3,
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: _total,
        onPageChanged: (int i) => setState(() => _page = i),
        itemBuilder: (BuildContext context, int i) {
          if (i == lesson.cards.length) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(l10n.lessonCheckTitle, style: context.texts.labelLarge),
                  const SizedBox(height: 12),
                  QuestionView(
                    question: lesson.check,
                    chosen: _answer,
                    onChoose: (int index) => setState(() => _answer = index),
                  ),
                ],
              ),
            );
          }
          return _CardView(card: lesson.cards[i], accent: lesson.color);
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 14),
        child: Row(
          children: <Widget>[
            Text(
              l10n.lessonCardOf(_page + 1, _total),
              style: context.texts.bodySmall?.copyWith(color: context.semantic.muted),
            ),
            const Spacer(),
            if (_onCheck && topic != null)
              TextButton(
                onPressed: () =>
                    Navigator.of(context).push(ConditionDetailScreen.route(topic)),
                child: Text(l10n.learnOpenTopic),
              ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _onCheck
                  ? (_answer == null ? null : _finish)
                  : _next,
              child: Text(_onCheck ? l10n.lessonDone : l10n.lessonNext),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardView extends StatelessWidget {
  const _CardView({required this.card, required this.accent});

  final LessonCard card;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final Locale locale = context.locale;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (card.image != null) ...<Widget>[
            Container(
              height: 190,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: SvgPicture.asset(card.image!, fit: BoxFit.contain),
            ),
            const SizedBox(height: 20),
          ],
          Text(card.title.resolve(locale), style: context.texts.headlineSmall),
          const SizedBox(height: 12),
          Text(
            card.body.resolve(locale),
            style: context.texts.bodyLarge?.copyWith(height: 1.55),
          ),
        ],
      ),
    );
  }
}
