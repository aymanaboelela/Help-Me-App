# Help Me 4.0 · Phase A — Child & Infant Mode

**Date:** 2026-07-25
**Status:** approved, ready for planning
**Branch:** `revamp/help-me-2.0`
**Predecessor:** [`2026-07-25-help-me-3.0-design.md`](2026-07-25-help-me-3.0-design.md) — all four phases shipped.

## Problem

Every one of the app's 17 topics is written for an adult casualty. `cpr` says so in its own
overview: *"Start CPR when an adult is unresponsive."* For several procedures the paediatric
technique is not a milder version of the adult one — it is a different procedure, and applying the
adult one to a baby causes injury:

- **Infant choking.** Abdominal thrusts on a child under one can rupture the liver. The correct
  sequence is back blows and *chest* thrusts. The app currently teaches abdominal thrusts.
- **Infant CPR.** Two fingers, roughly 4 cm, one third of chest depth — not two interlocked hands
  at 5–6 cm. Paediatric resuscitation also opens with five rescue breaths before compressions,
  because a child's arrest is usually respiratory in origin, where an adult's is usually cardiac.

Separately, three of the emergencies an Egyptian parent is most likely to face — febrile
convulsion, dehydration from gastroenteritis, and a swallowed object — are absent from the app
entirely.

The person most likely to install a first-aid app is a parent. The app currently cannot help them
with their own child.

## Goals

- Make every procedure that differs by age **say so, and teach the right one** for the age chosen.
- Add the child-specific emergencies that are missing.
- Make it impossible to read infant steps while treating an adult, or the reverse.
- Hold every existing guarantee: offline, no account, no tracking, no new permissions, and no
  regression in the 17 existing topics or the 173 passing tests.

## Non-goals

- No diagnosis or triage. Unchanged from 3.0: the app teaches procedures.
- No weight-based or age-in-months dosing calculator. Three bands only.
- No separate "kids app", no separate navigation branch, no new tab.

## Approach

A per-topic **age switch inside the condition screen**, not separate topics and not a global mode.

Separate topics (`cpr_child`, `cpr_infant`) were rejected: they triple the cardiac section of the
home grid, return three near-identical search results for "إنعاش", and duplicate prose that must
then be kept in sync by hand.

A global app-wide toggle was rejected on safety grounds: a switch left on from yesterday would
silently serve infant steps during an adult emergency, and the failure is invisible at the moment
it matters.

## Data model

One additive field on `FirstAidTopic`. Nothing existing changes.

```dart
/// Which casualty the steps are written for.
///
/// The bands are the ones resuscitation guidance itself uses: an infant is
/// under one year, a child is one year to puberty, and everyone else is an
/// adult. Age in months is deliberately not modelled — under pressure a
/// three-way choice is answerable and a numeric one is not.
enum AgeGroup { adult, child, infant }

class FirstAidTopic {
  const FirstAidTopic({
    ...
    this.ageVariants = const <AgeGroup, List<FirstAidSection>>{},
  });

  /// The steps as written for an adult.
  final List<FirstAidSection> sections;

  /// Replacements for [sections], by age. Absent ages fall back to [sections].
  final Map<AgeGroup, List<FirstAidSection>> ageVariants;

  /// Whether this topic is about children only, so it needs no age switch but
  /// still belongs behind the children filter.
  final bool isPaediatric;

  bool get hasAgeVariants => ageVariants.isNotEmpty;

  /// What the children filter selects.
  bool get concernsChildren => isPaediatric || hasAgeVariants;

  List<FirstAidSection> sectionsFor(AgeGroup group) =>
      ageVariants[group] ?? sections;

  List<LocalizedText> allStepsFor(AgeGroup group) =>
      <LocalizedText>[for (final s in sectionsFor(group)) ...s.steps];
}
```

Three properties of this shape matter:

1. **`sections` and `allSteps` keep their present meaning** — the adult steps. Every existing
   caller, test, and topic is untouched, so the change cannot regress the 17 topics.
2. **A variant replaces its sections wholly; it never merges.** Merging is how "5–6 cm deep" leaks
   from an adult section into an infant procedure. Replacement makes each age's text reviewable as
   one piece of medical prose.
3. **Coverage is optional and partial by design.** `ageVariants` empty means no switch is shown.
   Content can be added a topic at a time.

`AgeGroup.adult` is never a key in `ageVariants` — it resolves through the fallback. A data test
enforces this so the adult text has exactly one home.

## Behaviour

### The switch

A segmented control directly above the steps, rendered only when `topic.hasAgeVariants`. Labels:
بالغ / طفل / رضيع · Adult / Child / Infant.

**It always opens on Adult, and the choice is not persisted** — not to `SharedPreferences`, not
across a push and pop of the screen. This is the one place the design deliberately chooses friction
over convenience: a remembered "infant" from last week, applied to an adult in cardiac arrest, is a
fatal error that gives the user no signal it has happened. Under stress the choice must be made
consciously, and making it costs one tap.

### Confirming the choice

Selecting child or infant pins a banner above the steps for as long as that age is selected:

- **رضيع — أقل من سنة** · *Infant — under 1 year*
- **طفل — من سنة حتى البلوغ** · *Child — 1 year to puberty*

The banner is not a dismissible toast. The screen must never be ambiguous about which body the
steps in front of you describe.

### Tools follow the selection

`allSteps` is consumed by read-aloud and by focus mode. Both take the selected group:

- `FocusModeScreen.route(topic, age)` — the swipe-through steps are the selected age's.
- Read-aloud speaks `allStepsFor(age)`, and step highlighting indexes into that same list.
- **Changing the switch while read-aloud is speaking stops it immediately.** Continuing to speak
  adult steps under an infant banner is the exact confusion this feature exists to prevent.
- The CPR metronome is unchanged: 100–120 per minute is the rate for every age.
- Step illustrations resolve per age where an age-specific asset exists (`choking_infant.svg`
  already ships), and fall back to the topic's existing images otherwise.

## Content

The content is the substance of this phase; the code above is a day's work and the prose is not.

### Variants on existing topics

| Topic | What differs |
| --- | --- |
| `cpr` | **Infant:** two fingers, ~4 cm (one third of chest depth). **Child:** one or two hands, ~5 cm. **Both:** five initial rescue breaths before compressions; 30:2 thereafter for a lone lay rescuer. |
| `choking` | **Infant:** five back blows, then five **chest** thrusts, head down along the forearm. Abdominal thrusts are contraindicated and the variant says so explicitly. **Child:** five back blows, then five abdominal thrusts. |
| `drowning` | Five initial rescue breaths for a child or infant before compressions. |
| `burns` | Greater surface-area-to-mass ratio: cool for 20 minutes but watch for hypothermia; a burn that is minor on an adult may not be on a small child. |
| `anaphylaxis` | Auto-injector strength by weight — the 0.15 mg junior device under 30 kg. |
| `seizures` | How a febrile convulsion differs from epilepsy and what changes in the response — the recognition only, pointing at the `febrile_seizure` topic for the full procedure rather than restating it. |

### New topics

Three, each written to the same structure as the existing 17 and passing the same integrity tests.
Each is child-specific, so each is authored directly in paediatric terms rather than as a variant.

- **`febrile_seizure` — تشنج الحرارة.** The most frightening thing a parent sees and one of the
  most commonly mishandled: do not restrain, put nothing in the mouth, place on the side, time it,
  ambulance past five minutes.
- **`child_dehydration` — الجفاف والنزلة المعوية.** Oral rehydration salts, how to give them, the
  signs that mean hospital now. Dehydration from gastroenteritis still kills Egyptian children.
- **`swallowed_object` — ابتلاع جسم غريب.** Button batteries (an oesophageal emergency measured in
  hours, not days), coins, magnets, peanuts. Danger signs and when hospital is immediate.

### Finding it all

A **👶 للأطفال · For children** filter chip on Home, alongside the existing category chips. It
selects every topic whose `concernsChildren` is true — the three paediatric topics plus the six
that carry variants. It is a filter over the one catalogue — the 2.0 principle holds, no new
screen, no new list.

Because it is not a body-system grouping, it is **not** a new `TopicCategory` value; it is a
separate boolean filter in `search_provider.dart`, so the existing category taxonomy stays honest.

### Medical sourcing

Content follows current European Resuscitation Council and American Heart Association **lay
rescuer** guidance, and stays deliberately conservative — where guidance differs between bodies,
the app teaches the simpler action that is safe under both.

**This is written by a developer, not a clinician.** A paediatrician should review the paediatric
text before release. Every new and modified topic will carry its source references in
`docs/medical_sources.md` so that review has something concrete to check against, rather than a
reviewer having to reverse-engineer intent from prose.

## Error handling

| Situation | Behaviour |
| --- | --- |
| Topic has no variants | No switch renders. The screen is exactly as it is today. |
| Variant exists for one age only | Only that age appears in the switch, plus Adult. A missing age is never a blank screen. |
| Read-aloud running when age changes | Speech stops immediately; the highlight clears. |
| Focus mode open when age changes | Focus mode is a pushed route holding its own age; it is unaffected until reopened. |
| Age-specific illustration missing | Falls back to the topic's existing images. Imagery stays optional, as in 3.0. |

## Testing

Extends the 173-test suite along its existing three layers.

**Data integrity**
- Every variant section is bilingual and complete; no empty step lists; no empty strings.
- `AgeGroup.adult` never appears as a key in `ageVariants`.
- For every topic, `sectionsFor(AgeGroup.adult)` is identical to `sections` — the regression guard
  that proves the 17 existing topics are untouched.
- The three new topics pass every check the existing 17 pass: unique ids, bilingual throughout,
  valid category, non-empty sections.
- Every topic with `isPaediatric` set has no `ageVariants`, and vice versa — the two ways of
  concerning children stay disjoint, so a topic cannot arrive with both a switch and a paediatric-
  only claim.

**Providers**
- The children filter returns exactly the expected id set, and composes correctly with the search
  query and with a category selection.

**Widgets**
- The switch renders only for topics with variants.
- Selecting infant changes the rendered step text, and the banner appears.
- Reopening a topic after selecting infant shows Adult — the non-persistence guarantee, asserted
  rather than assumed.
- Focus mode opened from an infant selection shows infant steps.
- The switch renders correctly in RTL.

## Risks

| Risk | Mitigation |
| --- | --- |
| **Medical accuracy of paediatric content.** The highest-stakes text in the app. | Conservative lay-rescuer guidance, sources recorded per topic in `docs/medical_sources.md`, clinician review requested before release. |
| **Wrong age selected under stress.** | Always opens on Adult; persistent banner while a non-adult age is selected; the choice is one tap and one glance to verify. |
| **Content volume.** Six variants plus three topics is a lot of reviewed prose. | Each topic is independent data. The phase can ship in content batches — the switch appears on whatever has variants, and the app is never broken between batches. |
| **Home grid growth.** 17 topics becomes 20. | The children filter chip lands in the same change, so the fuller grid gains a way to be narrowed as it grows. |

## Out of scope for this phase

Phases B (symptom search & accessibility), C (SOS sharing with family), and D (home-screen and
lock-screen widgets) are agreed but separately specified. Nothing here depends on them, and
nothing in them depends on this beyond reading whatever topics exist.
