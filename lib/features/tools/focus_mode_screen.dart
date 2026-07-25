import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/localized_text.dart';
import '../../l10n/app_localizations.dart';
import '../conditions/model/first_aid_topic.dart';

/// A distraction-free, one-step-at-a-time view of a topic's steps, with large
/// text and swipe/next navigation — easier to follow under stress.
class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({
    super.key,
    required this.topic,
    this.age = AgeGroup.adult,
  });

  final FirstAidTopic topic;

  /// Whose steps to show — carried in rather than read from a provider, so a
  /// pushed focus mode keeps the age it was opened with.
  final AgeGroup age;

  static Route<void> route(FirstAidTopic topic, {AgeGroup age = AgeGroup.adult}) =>
      MaterialPageRoute<void>(
        builder: (_) => FocusModeScreen(topic: topic, age: age),
      );

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int delta) {
    _controller.animateToPage(
      _index + delta,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Locale locale = context.locale;
    final List<LocalizedText> steps = widget.topic.allStepsFor(widget.age);
    final Color accent = widget.topic.color;
    final int total = steps.length;

    return Scaffold(
      appBar: AppBar(title: Text(widget.topic.title.resolve(locale))),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            LinearProgressIndicator(
              value: total == 0 ? 0 : (_index + 1) / total,
              color: accent,
              backgroundColor: accent.withValues(alpha: 0.12),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (int i) => setState(() => _index = i),
                itemCount: total,
                itemBuilder: (BuildContext context, int i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 64,
                          height: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${i + 1}',
                            style: context.texts.headlineMedium?.copyWith(color: accent),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          steps[i].resolve(locale),
                          textAlign: TextAlign.center,
                          style: context.texts.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: <Widget>[
                  IconButton.filledTonal(
                    onPressed: _index > 0 ? () => _go(-1) : null,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(
                      l10n.stepOf(_index + 1, total),
                      textAlign: TextAlign.center,
                      style: context.texts.titleMedium,
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: _index < total - 1 ? () => _go(1) : null,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
