import 'package:flutter/widgets.dart';

import '../../../core/localized_text.dart';

/// Broad grouping used for the home screen's category filter.
enum TopicCategory { breathing, cardiac, bleeding, trauma, environmental, medical }

/// The kind of highlighted callout shown inside a section.
enum CalloutType {
  /// Life-threatening — call emergency services now.
  danger,

  /// Important caution ("do NOT ...").
  warning,

  /// Helpful tip.
  tip,
}

/// A highlighted note attached to a [FirstAidSection].
@immutable
class FirstAidCallout {
  const FirstAidCallout({required this.type, required this.text});

  final CalloutType type;
  final LocalizedText text;
}

/// One block of a topic: a heading, an ordered list of steps, and optional callouts.
@immutable
class FirstAidSection {
  const FirstAidSection({
    required this.title,
    this.steps = const <LocalizedText>[],
    this.callouts = const <FirstAidCallout>[],
  });

  final LocalizedText title;
  final List<LocalizedText> steps;
  final List<FirstAidCallout> callouts;
}

/// A single first-aid topic (e.g. burns, CPR, snake bite).
///
/// Topics are immutable data — the single source of truth consumed by the home
/// grid, search, favorites, and the detail screen.
@immutable
class FirstAidTopic {
  const FirstAidTopic({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.icon,
    required this.color,
    required this.sections,
    this.overview,
    this.showCallAmbulance = true,
    this.showMetronome = false,
  });

  /// Stable identifier (also used as the favorites key and route argument).
  final String id;
  final LocalizedText title;
  final LocalizedText summary;
  final TopicCategory category;
  final IconData icon;
  final Color color;

  /// Optional short intro paragraph shown above the sections.
  final LocalizedText? overview;
  final List<FirstAidSection> sections;

  /// Whether the "Call ambulance" action is offered on the detail screen.
  final bool showCallAmbulance;

  /// Whether to show the CPR rhythm metronome tool on the detail screen.
  final bool showMetronome;

  /// All steps across sections, flattened — used by the read-aloud (TTS) tool.
  List<LocalizedText> get allSteps =>
      <LocalizedText>[for (final FirstAidSection s in sections) ...s.steps];

  /// Whether [query] matches this topic in either language (case-insensitive).
  bool matches(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    bool hit(String s) => s.toLowerCase().contains(q);
    if (hit(title.en) || hit(title.ar)) return true;
    if (hit(summary.en) || hit(summary.ar)) return true;
    for (final FirstAidSection s in sections) {
      if (hit(s.title.en) || hit(s.title.ar)) return true;
    }
    return false;
  }
}
