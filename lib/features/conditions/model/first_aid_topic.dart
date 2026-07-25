import 'package:flutter/widgets.dart';

import '../../../core/localized_text.dart';

/// Broad grouping used for the home screen's category filter.
enum TopicCategory { breathing, cardiac, bleeding, trauma, environmental, medical }

/// Which casualty the steps are written for.
///
/// The bands are the ones resuscitation guidance itself uses: an infant is
/// under one year, a child is one year to puberty, everyone else is an adult.
/// Age in months is deliberately not modelled — under pressure a three-way
/// choice is answerable and a numeric one is not.
enum AgeGroup { adult, child, infant }

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
    this.ageVariants = const <AgeGroup, List<FirstAidSection>>{},
    this.isPaediatric = false,
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

  /// Replacements for [sections], by age. An age with no entry falls back to
  /// [sections], so coverage can be partial and grow a topic at a time.
  ///
  /// A variant replaces its sections wholly and never merges with them.
  /// Merging is how "5 to 6 cm deep" leaks out of an adult procedure and into
  /// an infant one.
  final Map<AgeGroup, List<FirstAidSection>> ageVariants;

  /// Whether this topic is about children only. Such a topic needs no age
  /// switch — it is already paediatric — but still belongs behind the children
  /// filter on the home screen.
  final bool isPaediatric;

  bool get hasAgeVariants => ageVariants.isNotEmpty;

  /// What the children filter selects.
  bool get concernsChildren => isPaediatric || hasAgeVariants;

  /// The ages offered by the switch: adult, then whichever variants exist, in
  /// declaration order so the control never reshuffles between topics.
  List<AgeGroup> get ageOptions => <AgeGroup>[
        AgeGroup.adult,
        for (final AgeGroup group in AgeGroup.values)
          if (group != AgeGroup.adult && ageVariants.containsKey(group)) group,
      ];

  /// The sections to show for [group] — the variant if there is one, the adult
  /// text otherwise.
  List<FirstAidSection> sectionsFor(AgeGroup group) =>
      ageVariants[group] ?? sections;

  /// [allSteps], for a chosen age. Used by read-aloud and focus mode.
  List<LocalizedText> allStepsFor(AgeGroup group) => <LocalizedText>[
        for (final FirstAidSection s in sectionsFor(group)) ...s.steps,
      ];

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
