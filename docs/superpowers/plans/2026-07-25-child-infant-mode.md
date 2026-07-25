# Child & Infant Mode Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Teach the correct age-specific procedure for the emergencies where infant, child, and adult first aid genuinely differ, and add the three paediatric emergencies the app is missing.

**Architecture:** One additive field on the existing immutable `FirstAidTopic` — `ageVariants`, a map from `AgeGroup` to replacement sections — plus a segmented control on the condition screen that picks which set renders. `sections` keeps meaning "the adult steps", so the 17 existing topics and 173 existing tests are untouched. Content stays data, never screens, exactly as in 2.0 and 3.0.

**Tech Stack:** Flutter 3.41 · Dart 3 · Material 3 · Riverpod (`Notifier`/`Provider`) · `flutter_gen_l10n` ARB · `flutter_test`

**Spec:** [`docs/superpowers/specs/2026-07-25-child-infant-mode-design.md`](../specs/2026-07-25-child-infant-mode-design.md)

## Global Constraints

- **Every user-visible string is bilingual.** UI chrome goes in `lib/l10n/app_ar.arb` + `app_en.arb`; medical content goes in `LocalizedText(en: …, ar: …)`. A string in one language only is a build-blocking defect.
- **`flutter analyze` must report `No issues found!`** — strict lints from `analysis_options.yaml`. Explicit types on locals and collection literals, matching surrounding code.
- **`flutter test` must stay green.** The suite is at 173 passing before this plan starts; it only grows.
- **Never modify the `sections` field of an existing topic.** `sections` is the adult text and is protected by a regression test in Task 1.
- **`AgeGroup.adult` is never a key in `ageVariants`.** Adult resolves through the fallback.
- **The age choice is never persisted** — not to `SharedPreferences`, not across a route pop. Always opens on `AgeGroup.adult`.
- **No new dependencies, no new permissions, no network calls.** The offline guarantee holds.
- After editing any `.arb` file, run `flutter gen-l10n` and commit the regenerated `lib/l10n/app_localizations*.dart` — they are checked in.
- Medical content follows **ERC/AHA lay-rescuer** guidance. Every topic touched gets its source recorded in `docs/medical_sources.md` (Task 8).
- Commit after every task. Conventional-commit style, matching existing history (`Add …`, sentence case).

---

## File Structure

| File | Responsibility | Task |
| --- | --- | --- |
| `lib/features/conditions/model/first_aid_topic.dart` | Modify — add `AgeGroup`, `ageVariants`, `isPaediatric`, resolvers | 1 |
| `test/age_variants_test.dart` | Create — model semantics + variant content integrity | 1, 2, 5, 6 |
| `lib/features/conditions/data/topics_extended.dart` | Modify — variants for `cpr`, `choking`, `drowning`, `burns`, `anaphylaxis` | 2, 5 |
| `lib/features/conditions/data/topics_original.dart` | Modify — variant for `seizures` | 5 |
| `lib/features/conditions/data/topics_paediatric.dart` | Create — the three child-only topics | 6 |
| `lib/features/conditions/data/first_aid_data.dart` | Modify — append `kPaediatricTopics` | 6 |
| `lib/features/conditions/presentation/widgets/age_switch.dart` | Create — segmented control + banner | 3 |
| `lib/features/conditions/presentation/condition_detail_screen.dart` | Modify — hold selected age, swap sections, age-aware read-aloud | 3 |
| `lib/features/tools/focus_mode_screen.dart` | Modify — take an `AgeGroup` | 4 |
| `lib/features/conditions/data/topic_media_data.dart` | Modify — `kTopicImagesByAge` + `imagesFor` | 8 |
| `test/topic_media_test.dart` | Modify — age-specific illustration resolution | 8 |
| `lib/providers/search_provider.dart` | Modify — add `childrenFilterProvider` | 7 |
| `lib/features/home/home_screen.dart` | Modify — children chip in `_CategoryChips` | 7 |
| `lib/l10n/app_ar.arb`, `app_en.arb` | Modify — 6 new keys | 3, 7 |
| `test/age_switch_widget_test.dart` | Create — switch, banner, non-persistence, focus mode, RTL | 3, 4 |
| `test/providers_test.dart` | Modify — children filter | 7 |
| `docs/medical_sources.md` | Create — per-topic sources for clinician review | 8 |
| `README.md` | Modify — feature list | 8 |

---

## Task 1: The age model

**Files:**
- Modify: `lib/features/conditions/model/first_aid_topic.dart:48-96`
- Test: `test/age_variants_test.dart` (create)

**Interfaces:**
- Consumes: `FirstAidTopic`, `FirstAidSection`, `LocalizedText` (all existing).
- Produces: `enum AgeGroup { adult, child, infant }`; `FirstAidTopic.ageVariants` (`Map<AgeGroup, List<FirstAidSection>>`, default `const {}`); `FirstAidTopic.isPaediatric` (`bool`, default `false`); getters `hasAgeVariants`, `concernsChildren`, `ageOptions` (`List<AgeGroup>`); methods `sectionsFor(AgeGroup)` → `List<FirstAidSection>`, `allStepsFor(AgeGroup)` → `List<LocalizedText>`.

- [ ] **Step 1: Write the failing test**

Create `test/age_variants_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/core/localized_text.dart';
import 'package:help_me/features/conditions/data/first_aid_data.dart';
import 'package:help_me/features/conditions/model/first_aid_topic.dart';

const FirstAidSection _adultSection = FirstAidSection(
  title: LocalizedText(en: 'Steps', ar: 'الخطوات'),
  steps: <LocalizedText>[LocalizedText(en: 'Push hard', ar: 'اضغط بقوة')],
);

const FirstAidSection _infantSection = FirstAidSection(
  title: LocalizedText(en: 'Steps', ar: 'الخطوات'),
  steps: <LocalizedText>[LocalizedText(en: 'Two fingers', ar: 'إصبعان')],
);

FirstAidTopic _topic({
  Map<AgeGroup, List<FirstAidSection>> variants =
      const <AgeGroup, List<FirstAidSection>>{},
  bool paediatric = false,
}) =>
    FirstAidTopic(
      id: 't',
      title: const LocalizedText(en: 'T', ar: 'ت'),
      summary: const LocalizedText(en: 'S', ar: 'س'),
      category: TopicCategory.cardiac,
      icon: Icons.favorite,
      color: const Color(0xFF000000),
      sections: const <FirstAidSection>[_adultSection],
      ageVariants: variants,
      isPaediatric: paediatric,
    );

void main() {
  group('AgeGroup resolution', () {
    test('Given no variants, Then every age resolves to the adult sections', () {
      final FirstAidTopic topic = _topic();
      for (final AgeGroup group in AgeGroup.values) {
        expect(topic.sectionsFor(group), same(topic.sections), reason: group.name);
      }
      expect(topic.hasAgeVariants, isFalse);
    });

    test('Given an infant variant, Then infant resolves to it and adult does not', () {
      final FirstAidTopic topic = _topic(
        variants: const <AgeGroup, List<FirstAidSection>>{
          AgeGroup.infant: <FirstAidSection>[_infantSection],
        },
      );

      expect(topic.sectionsFor(AgeGroup.infant).first.steps.first.en, 'Two fingers');
      expect(topic.sectionsFor(AgeGroup.adult).first.steps.first.en, 'Push hard');
      expect(topic.sectionsFor(AgeGroup.child).first.steps.first.en, 'Push hard');
      expect(topic.hasAgeVariants, isTrue);
    });

    test('Given an infant variant, Then allStepsFor reads that variant', () {
      final FirstAidTopic topic = _topic(
        variants: const <AgeGroup, List<FirstAidSection>>{
          AgeGroup.infant: <FirstAidSection>[_infantSection],
        },
      );

      expect(topic.allStepsFor(AgeGroup.infant).single.ar, 'إصبعان');
      expect(topic.allStepsFor(AgeGroup.adult), topic.allSteps);
    });

    test('Given only an infant variant, Then the options are adult and infant', () {
      final FirstAidTopic topic = _topic(
        variants: const <AgeGroup, List<FirstAidSection>>{
          AgeGroup.infant: <FirstAidSection>[_infantSection],
        },
      );

      expect(topic.ageOptions, <AgeGroup>[AgeGroup.adult, AgeGroup.infant]);
    });

    test('Given both variants, Then the options run adult, child, infant', () {
      final FirstAidTopic topic = _topic(
        variants: const <AgeGroup, List<FirstAidSection>>{
          AgeGroup.infant: <FirstAidSection>[_infantSection],
          AgeGroup.child: <FirstAidSection>[_infantSection],
        },
      );

      expect(
        topic.ageOptions,
        <AgeGroup>[AgeGroup.adult, AgeGroup.child, AgeGroup.infant],
      );
    });

    test('Given a paediatric topic, Then it concerns children without a switch', () {
      final FirstAidTopic topic = _topic(paediatric: true);

      expect(topic.concernsChildren, isTrue);
      expect(topic.hasAgeVariants, isFalse);
      expect(topic.ageOptions, <AgeGroup>[AgeGroup.adult]);
    });
  });

  group('Catalogue age invariants', () {
    test('Given every topic, Then adult resolves to its own sections', () {
      for (final FirstAidTopic topic in kFirstAidTopics) {
        expect(
          topic.sectionsFor(AgeGroup.adult),
          same(topic.sections),
          reason: topic.id,
        );
      }
    });

    test('Given every topic, Then adult is never a variant key', () {
      for (final FirstAidTopic topic in kFirstAidTopics) {
        expect(
          topic.ageVariants.containsKey(AgeGroup.adult),
          isFalse,
          reason: topic.id,
        );
      }
    });

    test('Given every topic, Then paediatric and variants are disjoint', () {
      for (final FirstAidTopic topic in kFirstAidTopics) {
        expect(
          topic.isPaediatric && topic.hasAgeVariants,
          isFalse,
          reason: '${topic.id}: cannot be both paediatric-only and age-switched',
        );
      }
    });

    test('Given every variant, Then its sections and steps are non-empty', () {
      for (final FirstAidTopic topic in kFirstAidTopics) {
        topic.ageVariants.forEach((AgeGroup group, List<FirstAidSection> sections) {
          expect(sections, isNotEmpty, reason: '${topic.id}/${group.name}');
          for (final FirstAidSection section in sections) {
            expect(section.steps, isNotEmpty,
                reason: '${topic.id}/${group.name}: empty section');
          }
        });
      }
    });

    test('Given every variant, Then all its text is bilingual and complete', () {
      for (final FirstAidTopic topic in kFirstAidTopics) {
        topic.ageVariants.forEach((AgeGroup group, List<FirstAidSection> sections) {
          final String where = '${topic.id}/${group.name}';
          for (final FirstAidSection section in sections) {
            expect(section.title.isComplete, isTrue, reason: '$where: section title');
            for (final LocalizedText step in section.steps) {
              expect(step.isComplete, isTrue, reason: '$where: a step');
            }
            for (final FirstAidCallout callout in section.callouts) {
              expect(callout.text.isComplete, isTrue, reason: '$where: a callout');
            }
          }
        });
      }
    });
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/age_variants_test.dart`
Expected: compile failure — `Undefined name 'AgeGroup'`, `No named parameter with the name 'ageVariants'`.

- [ ] **Step 3: Add the model**

In `lib/features/conditions/model/first_aid_topic.dart`, add the enum directly under the existing `TopicCategory` enum (line 6):

```dart
/// Which casualty the steps are written for.
///
/// The bands are the ones resuscitation guidance itself uses: an infant is
/// under one year, a child is one year to puberty, everyone else is an adult.
/// Age in months is deliberately not modelled — under pressure a three-way
/// choice is answerable and a numeric one is not.
enum AgeGroup { adult, child, infant }
```

Then extend `FirstAidTopic`. Add to the constructor parameter list, after `this.showMetronome = false`:

```dart
    this.ageVariants = const <AgeGroup, List<FirstAidSection>>{},
    this.isPaediatric = false,
```

And add these members after the existing `showMetronome` field:

```dart
  /// Replacements for [sections], by age. An age with no entry falls back to
  /// [sections], so coverage can be partial and grow a topic at a time.
  ///
  /// A variant replaces its sections wholly and never merges with them.
  /// Merging is how "5 to 6 cm deep" leaks out of an adult procedure and into
  /// an infant one.
  final Map<AgeGroup, List<FirstAidSection>> ageVariants;

  /// Whether this topic is about children only. Such a topic needs no age
  /// switch — it is already paediatric — but still belongs behind the
  /// children filter on the home screen.
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
```

Leave `sections`, `allSteps`, and `matches` exactly as they are.

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/age_variants_test.dart`
Expected: PASS, 11 tests.

- [ ] **Step 5: Verify nothing regressed**

Run: `flutter analyze && flutter test`
Expected: `No issues found!` and `All tests passed!` with the count now 184.

- [ ] **Step 6: Commit**

```bash
git add lib/features/conditions/model/first_aid_topic.dart test/age_variants_test.dart
git commit -m "Add the age-group model for first-aid topics"
```

---

## Task 2: Infant and child variants for CPR and choking

The two procedures where the adult technique injures a baby. Content first, so the UI in Task 3 has something real to render.

**Files:**
- Modify: `lib/features/conditions/data/topics_extended.dart:12` (`cpr`), `:78` (`choking`)
- Test: `test/age_variants_test.dart` (append a group)

**Interfaces:**
- Consumes: `AgeGroup`, `ageVariants` from Task 1.
- Produces: `topicById('cpr')!.ageVariants` and `topicById('choking')!.ageVariants`, each with `AgeGroup.child` and `AgeGroup.infant` keys.

- [ ] **Step 1: Write the failing test**

Append to `test/age_variants_test.dart`, inside `main()`:

```dart
  group('CPR and choking paediatric content', () {
    test('Given CPR, Then it has both a child and an infant variant', () {
      final FirstAidTopic cpr = topicById('cpr')!;
      expect(cpr.ageVariants.keys.toSet(),
          <AgeGroup>{AgeGroup.child, AgeGroup.infant});
    });

    test('Given infant CPR, Then it teaches two fingers, not two hands', () {
      final String text = topicById('cpr')!
          .allStepsFor(AgeGroup.infant)
          .map((LocalizedText t) => t.en.toLowerCase())
          .join(' ');

      expect(text, contains('two fingers'));
      expect(text, isNot(contains('interlock')));
    });

    test('Given paediatric CPR, Then it opens with five rescue breaths', () {
      for (final AgeGroup group in <AgeGroup>[AgeGroup.child, AgeGroup.infant]) {
        final String text = topicById('cpr')!
            .allStepsFor(group)
            .map((LocalizedText t) => t.en.toLowerCase())
            .join(' ');
        expect(text, contains('five rescue breaths'), reason: group.name);
      }
    });

    test('Given infant choking, Then abdominal thrusts are never instructed', () {
      final FirstAidTopic choking = topicById('choking')!;
      final String steps = choking
          .allStepsFor(AgeGroup.infant)
          .map((LocalizedText t) => t.en.toLowerCase())
          .join(' ');

      // The phrase may appear only inside a "never do this" callout, so the
      // steps themselves must be clean and the warning must be present.
      expect(steps, isNot(contains('abdominal thrust')));
      expect(steps, contains('chest thrust'));

      final String callouts = choking.ageVariants[AgeGroup.infant]!
          .expand((FirstAidSection s) => s.callouts)
          .map((FirstAidCallout c) => c.text.en.toLowerCase())
          .join(' ');
      expect(callouts, contains('never'));
      expect(callouts, contains('abdominal thrust'));
    });

    test('Given child choking, Then abdominal thrusts follow back blows', () {
      final String text = topicById('choking')!
          .allStepsFor(AgeGroup.child)
          .map((LocalizedText t) => t.en.toLowerCase())
          .join(' ');

      expect(text, contains('back blow'));
      expect(text, contains('abdominal thrust'));
    });
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/age_variants_test.dart --plain-name 'CPR and choking paediatric content'`
Expected: FAIL — `Expected: {<AgeGroup.child>, <AgeGroup.infant>}  Actual: {}`.

- [ ] **Step 3: Add the CPR variants**

In `lib/features/conditions/data/topics_extended.dart`, inside the `cpr` topic literal, add after its `sections: <FirstAidSection>[ … ],` closing bracket:

```dart
    ageVariants: <AgeGroup, List<FirstAidSection>>{
      AgeGroup.child: <FirstAidSection>[
        FirstAidSection(
          title: LocalizedText(
            en: 'Steps — child (1 year to puberty)',
            ar: 'الخطوات — طفل (من سنة حتى البلوغ)',
          ),
          steps: <LocalizedText>[
            LocalizedText(
              en: 'Check for a response: call the child\'s name and tap their shoulder. Shout for help and put your phone on speaker while you call an ambulance (123).',
              ar: 'تحقق من الاستجابة: نادِ الطفل باسمه واربت على كتفه. اطلب المساعدة، وضع هاتفك على مكبر الصوت أثناء اتصالك بالإسعاف (123).',
            ),
            LocalizedText(
              en: 'Open the airway: tilt the head back gently and lift the chin. Check breathing for no more than 10 seconds.',
              ar: 'افتح مجرى الهواء: أمِل الرأس للخلف برفق وارفع الذقن. افحص التنفس لمدة لا تزيد عن 10 ثوانٍ.',
            ),
            LocalizedText(
              en: 'Give five rescue breaths first, before any compressions: pinch the nose, seal your mouth over theirs, and blow steadily for about 1 second until the chest rises.',
              ar: 'أعطِ خمسة أنفاس إنقاذية أولًا قبل أي ضغطات: اقرص الأنف، وأطبق فمك على فمه، وانفخ بثبات لمدة ثانية تقريبًا حتى يرتفع الصدر.',
            ),
            LocalizedText(
              en: 'Then start compressions: the heel of one hand in the centre of the chest — use two hands if the child is large or you cannot press deep enough with one.',
              ar: 'ثم ابدأ الضغطات: كعب يد واحدة في منتصف الصدر — استخدم يدين إذا كان الطفل كبيرًا أو لم تستطع الضغط بعمق كافٍ بيد واحدة.',
            ),
            LocalizedText(
              en: 'Press about 5 cm deep — roughly one third of the depth of the chest — at 100 to 120 compressions a minute, letting the chest come all the way back up each time.',
              ar: 'اضغط بعمق 5 سم تقريبًا — نحو ثلث عمق الصدر — بمعدل 100 إلى 120 ضغطة في الدقيقة، مع السماح للصدر بالعودة بالكامل بعد كل ضغطة.',
            ),
            LocalizedText(
              en: 'Continue cycles of 30 compressions to 2 breaths without stopping until the child responds or help arrives.',
              ar: 'استمر في دورات من 30 ضغطة مقابل نفسين دون توقف حتى يستجيب الطفل أو يصل المسعفون.',
            ),
            LocalizedText(
              en: 'If an AED arrives, use paediatric pads if it has them. If it only has adult pads, use those rather than nothing.',
              ar: 'إذا وصل جهاز الصدمات (AED) فاستخدم لصقات الأطفال إن وُجدت، وإذا لم تتوفر سوى لصقات البالغين فاستخدمها بدلًا من عدم استخدام الجهاز.',
            ),
          ],
          callouts: <FirstAidCallout>[
            FirstAidCallout(
              type: CalloutType.danger,
              text: LocalizedText(
                en: 'A child\'s heart usually stops because breathing stopped first. That is why the five rescue breaths come before compressions — do not skip them.',
                ar: 'قلب الطفل يتوقف عادةً لأن التنفس توقف أولًا، ولهذا تأتي الأنفاس الخمسة قبل الضغطات — لا تتجاوزها.',
              ),
            ),
            FirstAidCallout(
              type: CalloutType.tip,
              text: LocalizedText(
                en: 'If you are alone with no phone, do CPR for one minute before leaving to get help.',
                ar: 'إذا كنت وحدك بلا هاتف، فقم بالإنعاش لمدة دقيقة واحدة قبل أن تترك الطفل لطلب المساعدة.',
              ),
            ),
          ],
        ),
      ],
      AgeGroup.infant: <FirstAidSection>[
        FirstAidSection(
          title: LocalizedText(
            en: 'Steps — infant (under 1 year)',
            ar: 'الخطوات — رضيع (أقل من سنة)',
          ),
          steps: <LocalizedText>[
            LocalizedText(
              en: 'Check for a response: tap the sole of the foot and call out. Never shake a baby.',
              ar: 'تحقق من الاستجابة: اربت على باطن القدم ونادِ عليه. لا تهزّ الرضيع أبدًا.',
            ),
            LocalizedText(
              en: 'Shout for help and call an ambulance (123) on speaker. Open the airway by keeping the head in a neutral position — level, not tilted back — and lifting the chin.',
              ar: 'اطلب المساعدة واتصل بالإسعاف (123) على مكبر الصوت. افتح مجرى الهواء بإبقاء الرأس في وضع محايد — مستوٍ وغير مائل للخلف — مع رفع الذقن.',
            ),
            LocalizedText(
              en: 'Check breathing for no more than 10 seconds.',
              ar: 'افحص التنفس لمدة لا تزيد عن 10 ثوانٍ.',
            ),
            LocalizedText(
              en: 'Give five rescue breaths first: cover the baby\'s mouth and nose with your mouth and give gentle puffs of about 1 second each — just enough to see the chest rise.',
              ar: 'أعطِ خمسة أنفاس إنقاذية أولًا: غطِّ فم الرضيع وأنفه معًا بفمك وانفخ نفخات لطيفة مدة كل منها ثانية تقريبًا — بقدر ما ترى الصدر يرتفع فقط.',
            ),
            LocalizedText(
              en: 'Then start compressions with two fingers in the centre of the chest, just below an imaginary line between the nipples.',
              ar: 'ثم ابدأ الضغطات بإصبعين في منتصف الصدر، أسفل خط وهمي يصل بين الحلمتين مباشرةً.',
            ),
            LocalizedText(
              en: 'Press about 4 cm deep — roughly one third of the depth of the chest — at 100 to 120 compressions a minute.',
              ar: 'اضغط بعمق 4 سم تقريبًا — نحو ثلث عمق الصدر — بمعدل 100 إلى 120 ضغطة في الدقيقة.',
            ),
            LocalizedText(
              en: 'Continue cycles of 30 compressions to 2 breaths without stopping until the baby responds or help arrives.',
              ar: 'استمر في دورات من 30 ضغطة مقابل نفسين دون توقف حتى يستجيب الرضيع أو يصل المسعفون.',
            ),
          ],
          callouts: <FirstAidCallout>[
            FirstAidCallout(
              type: CalloutType.warning,
              text: LocalizedText(
                en: 'Do not tilt a baby\'s head far back. Their airway is soft and tilting it too far closes the airway instead of opening it.',
                ar: 'لا تُمِل رأس الرضيع كثيرًا للخلف؛ فمجرى الهواء لديه ليّن، والإمالة الزائدة تغلقه بدلًا من أن تفتحه.',
              ),
            ),
            FirstAidCallout(
              type: CalloutType.warning,
              text: LocalizedText(
                en: 'Blow gently. A baby\'s lungs hold a fraction of what yours do — you are looking for the chest to rise, nothing more.',
                ar: 'انفخ برفق؛ فرئتا الرضيع تسعان جزءًا يسيرًا مما تسعه رئتاك — المطلوب أن يرتفع الصدر فقط لا أكثر.',
              ),
            ),
          ],
        ),
      ],
    },
```

Add `AgeGroup` to the file's existing import of `../model/first_aid_topic.dart` — it is exported from the same file, so no new import line is needed.

- [ ] **Step 4: Add the choking variants**

In the same file, inside the `choking` topic literal, after its `sections:` list:

```dart
    ageVariants: <AgeGroup, List<FirstAidSection>>{
      AgeGroup.child: <FirstAidSection>[
        FirstAidSection(
          title: LocalizedText(
            en: 'Steps — child (1 year to puberty)',
            ar: 'الخطوات — طفل (من سنة حتى البلوغ)',
          ),
          steps: <LocalizedText>[
            LocalizedText(
              en: 'If the child can cough loudly, cry, or speak, the blockage is partial. Encourage them to keep coughing and stay with them — do not hit them on the back.',
              ar: 'إذا كان الطفل يستطيع السعال بصوت عالٍ أو البكاء أو الكلام فالانسداد جزئي. شجّعه على مواصلة السعال وابقَ معه — ولا تضربه على ظهره.',
            ),
            LocalizedText(
              en: 'If the cough goes silent, they cannot breathe, or they turn blue, act now and have someone call an ambulance (123).',
              ar: 'إذا صار السعال صامتًا أو عجز عن التنفس أو ازرقّ لونه فتصرّف فورًا، واطلب من أحد الاتصال بالإسعاف (123).',
            ),
            LocalizedText(
              en: 'Lean the child forward and give five sharp back blows between the shoulder blades with the heel of your hand.',
              ar: 'أمِل الطفل للأمام وأعطِه خمس ضربات حازمة على الظهر بين لوحي الكتف بكعب يدك.',
            ),
            LocalizedText(
              en: 'If that fails, give five abdominal thrusts: stand or kneel behind them, make a fist just above the navel and below the ribs, grasp it with your other hand and pull sharply inwards and upwards.',
              ar: 'إذا لم تنجح، أعطِ خمس ضغطات على البطن: قف أو اركع خلفه، واجعل قبضتك فوق السرة وأسفل الأضلاع، وأمسكها بيدك الأخرى واسحب بقوة للداخل وللأعلى.',
            ),
            LocalizedText(
              en: 'Keep alternating five back blows and five abdominal thrusts until the object comes out or the child stops responding.',
              ar: 'واصل التبديل بين خمس ضربات على الظهر وخمس ضغطات على البطن حتى يخرج الجسم أو يفقد الطفل استجابته.',
            ),
            LocalizedText(
              en: 'Look in the mouth between rounds and remove an object only if you can see it clearly and grasp it. Never sweep a finger around blindly.',
              ar: 'انظر داخل الفم بين الجولات، ولا تُخرج الجسم إلا إذا رأيته بوضوح وأمكنك الإمساك به. لا تُدخل إصبعك للبحث عشوائيًا أبدًا.',
            ),
            LocalizedText(
              en: 'If the child stops responding, start CPR for a child: five rescue breaths, then cycles of 30 compressions to 2 breaths.',
              ar: 'إذا فقد الطفل استجابته فابدأ الإنعاش الخاص بالأطفال: خمسة أنفاس إنقاذية، ثم دورات من 30 ضغطة مقابل نفسين.',
            ),
          ],
          callouts: <FirstAidCallout>[
            FirstAidCallout(
              type: CalloutType.warning,
              text: LocalizedText(
                en: 'Any child who has received abdominal thrusts must be seen by a doctor afterwards, even if they seem completely fine — the thrusts can injure organs inside.',
                ar: 'أي طفل تلقّى ضغطات على البطن يجب أن يفحصه طبيب بعدها حتى لو بدا بخير تمامًا؛ فهذه الضغطات قد تُصيب أعضاء الداخل.',
              ),
            ),
          ],
        ),
      ],
      AgeGroup.infant: <FirstAidSection>[
        FirstAidSection(
          title: LocalizedText(
            en: 'Steps — infant (under 1 year)',
            ar: 'الخطوات — رضيع (أقل من سنة)',
          ),
          steps: <LocalizedText>[
            LocalizedText(
              en: 'If the baby is coughing forcefully or crying loudly, let them keep coughing and watch closely. A crying baby is moving air.',
              ar: 'إذا كان الرضيع يسعل بقوة أو يبكي بصوت عالٍ فدعه يواصل السعال وراقبه عن قرب؛ فالرضيع الذي يبكي يدخل الهواء إلى صدره.',
            ),
            LocalizedText(
              en: 'If the cough is silent, the cry is weak, or the baby is going blue, act now and have someone call an ambulance (123).',
              ar: 'إذا كان السعال صامتًا أو البكاء ضعيفًا أو بدأ لون الرضيع يزرقّ فتصرّف فورًا، واطلب من أحد الاتصال بالإسعاف (123).',
            ),
            LocalizedText(
              en: 'Lay the baby face down along your forearm with the head lower than the chest, supporting the jaw with your fingers — do not press on the soft throat.',
              ar: 'ضع الرضيع على بطنه فوق ساعدك ورأسه أخفض من صدره، وادعم فكه بأصابعك — ولا تضغط على مقدمة الرقبة الليّنة.',
            ),
            LocalizedText(
              en: 'Give five back blows between the shoulder blades with the heel of your hand.',
              ar: 'أعطِ خمس ضربات على الظهر بين لوحي الكتف بكعب يدك.',
            ),
            LocalizedText(
              en: 'If that fails, turn the baby face up along your other forearm and give five chest thrusts: two fingers on the breastbone just below the nipple line, pressed sharper and slower than CPR compressions — about one a second.',
              ar: 'إذا لم تنجح، اقلب الرضيع على ظهره فوق ساعدك الآخر وأعطِ خمس ضغطات على الصدر: بإصبعين على عظمة الصدر أسفل خط الحلمتين مباشرةً، أحدّ وأبطأ من ضغطات الإنعاش — نحو ضغطة كل ثانية.',
            ),
            LocalizedText(
              en: 'Keep alternating five back blows and five chest thrusts until the object comes out or the baby stops responding.',
              ar: 'واصل التبديل بين خمس ضربات على الظهر وخمس ضغطات على الصدر حتى يخرج الجسم أو يفقد الرضيع استجابته.',
            ),
            LocalizedText(
              en: 'Look in the mouth between rounds and remove an object only if you can see it and grasp it. Never sweep a finger around blindly — it pushes the object deeper.',
              ar: 'انظر داخل الفم بين الجولات، ولا تُخرج الجسم إلا إذا رأيته وأمكنك الإمساك به. لا تُدخل إصبعك للبحث عشوائيًا أبدًا؛ فذلك يدفع الجسم إلى الداخل.',
            ),
            LocalizedText(
              en: 'If the baby stops responding, start CPR for an infant: five rescue breaths, then cycles of 30 compressions to 2 breaths with two fingers.',
              ar: 'إذا فقد الرضيع استجابته فابدأ الإنعاش الخاص بالرضّع: خمسة أنفاس إنقاذية، ثم دورات من 30 ضغطة مقابل نفسين بإصبعين.',
            ),
          ],
          callouts: <FirstAidCallout>[
            FirstAidCallout(
              type: CalloutType.danger,
              text: LocalizedText(
                en: 'Never give abdominal thrusts to a baby under one year. They can tear the liver or spleen. Chest thrusts, not abdominal thrusts.',
                ar: 'لا تُعطِ أبدًا ضغطات على البطن لرضيع أقل من سنة؛ فقد تُمزّق الكبد أو الطحال. ضغطات على الصدر، لا على البطن.',
              ),
            ),
            FirstAidCallout(
              type: CalloutType.warning,
              text: LocalizedText(
                en: 'Even if the object comes out and the baby seems fine, have a doctor check them the same day.',
                ar: 'حتى لو خرج الجسم وبدا الرضيع بخير، اعرضه على طبيب في اليوم نفسه.',
              ),
            ),
          ],
        ),
      ],
    },
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `flutter test test/age_variants_test.dart`
Expected: PASS, 16 tests.

- [ ] **Step 6: Verify the whole suite and analyzer**

Run: `flutter analyze && flutter test`
Expected: `No issues found!` · `All tests passed!`

- [ ] **Step 7: Commit**

```bash
git add lib/features/conditions/data/topics_extended.dart test/age_variants_test.dart
git commit -m "Add infant and child steps for CPR and choking"
```

---

## Task 3: The age switch on the condition screen

**Files:**
- Create: `lib/features/conditions/presentation/widgets/age_switch.dart`
- Modify: `lib/features/conditions/presentation/condition_detail_screen.dart:50-233`
- Modify: `lib/l10n/app_ar.arb`, `lib/l10n/app_en.arb`
- Test: `test/age_switch_widget_test.dart` (create)

**Interfaces:**
- Consumes: `AgeGroup`, `topic.ageOptions`, `topic.sectionsFor`, `topic.hasAgeVariants` from Task 1; the `cpr` variants from Task 2.
- Produces: `AgeSwitch({required List<AgeGroup> options, required AgeGroup selected, required ValueChanged<AgeGroup> onChanged, required Color accent})`; `AgeBanner({required AgeGroup group, required Color accent})`; new l10n keys `ageAdult`, `ageChild`, `ageInfant`, `ageChildBanner`, `ageInfantBanner`.

- [ ] **Step 1: Add the l10n strings**

In `lib/l10n/app_en.arb`, after the `"categoryMedical"` line:

```json
  "ageAdult": "Adult",
  "ageChild": "Child",
  "ageInfant": "Infant",
  "ageChildBanner": "Child — 1 year to puberty",
  "ageInfantBanner": "Infant — under 1 year",
```

In `lib/l10n/app_ar.arb`, in the same position:

```json
  "ageAdult": "بالغ",
  "ageChild": "طفل",
  "ageInfant": "رضيع",
  "ageChildBanner": "طفل — من سنة حتى البلوغ",
  "ageInfantBanner": "رضيع — أقل من سنة",
```

Run: `flutter gen-l10n`
Expected: `lib/l10n/app_localizations*.dart` regenerate with the five getters.

- [ ] **Step 2: Write the failing test**

Create `test/age_switch_widget_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/features/conditions/data/first_aid_data.dart';
import 'package:help_me/features/conditions/model/first_aid_topic.dart';
import 'package:help_me/features/conditions/presentation/condition_detail_screen.dart';
import 'package:help_me/l10n/app_localizations.dart';
import 'package:help_me/providers/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> _app(Widget home, {Locale locale = const Locale('en')}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: <Override>[sharedPreferencesProvider.overrideWithValue(prefs)],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

void main() {
  final FirstAidTopic cpr = topicById('cpr')!;
  final FirstAidTopic bleeding = topicById('bleeding')!;

  testWidgets('Given a topic with variants, Then the switch is shown',
      (WidgetTester tester) async {
    await tester.pumpWidget(await _app(ConditionDetailScreen(topic: cpr)));
    await tester.pumpAndSettle();

    expect(find.text('Adult'), findsOneWidget);
    expect(find.text('Child'), findsOneWidget);
    expect(find.text('Infant'), findsOneWidget);
  });

  testWidgets('Given a topic without variants, Then no switch is shown',
      (WidgetTester tester) async {
    await tester.pumpWidget(await _app(ConditionDetailScreen(topic: bleeding)));
    await tester.pumpAndSettle();

    expect(find.text('Adult'), findsNothing);
    expect(find.text('Infant'), findsNothing);
  });

  testWidgets('Given the screen opens, Then adult steps render',
      (WidgetTester tester) async {
    await tester.pumpWidget(await _app(ConditionDetailScreen(topic: cpr)));
    await tester.pumpAndSettle();

    expect(find.textContaining('heel of one hand in the centre'), findsOneWidget);
    expect(find.textContaining('two fingers'), findsNothing);
  });

  testWidgets('Given infant is selected, Then infant steps and the banner render',
      (WidgetTester tester) async {
    await tester.pumpWidget(await _app(ConditionDetailScreen(topic: cpr)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Infant'));
    await tester.pumpAndSettle();

    expect(find.text('Infant — under 1 year'), findsOneWidget);
    expect(find.textContaining('two fingers in the centre'), findsOneWidget);
    expect(find.textContaining('heel of one hand in the centre'), findsNothing);
  });

  testWidgets('Given adult is selected, Then no banner is shown',
      (WidgetTester tester) async {
    await tester.pumpWidget(await _app(ConditionDetailScreen(topic: cpr)));
    await tester.pumpAndSettle();

    expect(find.text('Infant — under 1 year'), findsNothing);
    expect(find.text('Child — 1 year to puberty'), findsNothing);
  });

  testWidgets('Given infant was selected, When the screen is reopened, Then it is adult again',
      (WidgetTester tester) async {
    await tester.pumpWidget(await _app(ConditionDetailScreen(topic: cpr)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Infant'));
    await tester.pumpAndSettle();
    expect(find.text('Infant — under 1 year'), findsOneWidget);

    // A fresh mount stands in for leaving the screen and coming back.
    await tester.pumpWidget(await _app(ConditionDetailScreen(topic: cpr)));
    await tester.pumpAndSettle();

    expect(find.text('Infant — under 1 year'), findsNothing);
    expect(find.textContaining('heel of one hand in the centre'), findsOneWidget);
  });

  testWidgets('Given Arabic, Then the switch renders right-to-left',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      await _app(ConditionDetailScreen(topic: cpr), locale: const Locale('ar')),
    );
    await tester.pumpAndSettle();

    expect(find.text('رضيع'), findsOneWidget);
    expect(Directionality.of(tester.element(find.text('رضيع'))),
        TextDirection.rtl);
  });
}
```

- [ ] **Step 3: Run the test to verify it fails**

Run: `flutter test test/age_switch_widget_test.dart`
Expected: FAIL — `Expected: exactly one matching candidate  Actual: _TextFinder:<zero widgets with text "Adult">`.

- [ ] **Step 4: Build the widget**

Create `lib/features/conditions/presentation/widgets/age_switch.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../model/first_aid_topic.dart';

/// Localized labels for [AgeGroup].
extension AgeGroupDisplay on AgeGroup {
  String label(AppLocalizations l10n) {
    switch (this) {
      case AgeGroup.adult:
        return l10n.ageAdult;
      case AgeGroup.child:
        return l10n.ageChild;
      case AgeGroup.infant:
        return l10n.ageInfant;
    }
  }
}

/// Picks which body the steps below describe.
///
/// Shown only for topics that actually differ by age, so its presence is itself
/// the signal that this is a procedure where age changes the answer.
class AgeSwitch extends StatelessWidget {
  const AgeSwitch({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.accent,
  });

  final List<AgeGroup> options;
  final AgeGroup selected;
  final ValueChanged<AgeGroup> onChanged;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return SegmentedButton<AgeGroup>(
      segments: <ButtonSegment<AgeGroup>>[
        for (final AgeGroup group in options)
          ButtonSegment<AgeGroup>(value: group, label: Text(group.label(l10n))),
      ],
      selected: <AgeGroup>{selected},
      showSelectedIcon: false,
      onSelectionChanged: (Set<AgeGroup> picked) => onChanged(picked.single),
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: accent.withValues(alpha: 0.14),
        selectedForegroundColor: accent,
      ),
    );
  }
}

/// States plainly whose steps are on screen, for as long as they are not the
/// adult ones.
///
/// Not a toast and not dismissible: the screen must never be ambiguous about
/// which body the instructions in front of you describe.
class AgeBanner extends StatelessWidget {
  const AgeBanner({super.key, required this.group, required this.accent});

  final AgeGroup group;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String text = group == AgeGroup.infant
        ? l10n.ageInfantBanner
        : l10n.ageChildBanner;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.child_care, size: 20, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: context.texts.labelLarge?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Wire it into the condition screen**

In `lib/features/conditions/presentation/condition_detail_screen.dart`:

Add the import beside the other `widgets/` imports:

```dart
import 'widgets/age_switch.dart';
```

Add the state field after `int? _activeStep;`:

```dart
  /// Whose steps are showing. Deliberately not persisted and reset on every
  /// mount: a remembered "infant" applied to an adult in cardiac arrest is a
  /// fatal error that gives no signal it has happened.
  AgeGroup _age = AgeGroup.adult;
```

Add the change handler after `_onLineStarted`:

```dart
  /// Changes whose steps are shown, and stops read-aloud if it is running.
  ///
  /// Continuing to speak adult steps under an infant banner is the exact
  /// confusion this feature exists to prevent.
  void _setAge(AgeGroup group) {
    if (group == _age) return;
    _speech?.stop();
    setState(() {
      _age = group;
      _activeStep = null;
      _stepKeys.clear();
    });
  }
```

In `_script`, replace `for (final FirstAidSection section in topic.sections) {` with:

```dart
    for (final FirstAidSection section in topic.sectionsFor(_age)) {
```

In `_sections`, replace `for (final FirstAidSection section in topic.sections) {` with:

```dart
    for (final FirstAidSection section in topic.sectionsFor(_age)) {
```

In `build`, replace the `_DisclaimerNote` line and the `..._sections(topic)` line with:

```dart
          _DisclaimerNote(text: l10n.detailDisclaimer),
          if (topic.hasAgeVariants) ...<Widget>[
            const SizedBox(height: 16),
            AgeSwitch(
              options: topic.ageOptions,
              selected: _age,
              onChanged: _setAge,
              accent: topic.color,
            ),
            if (_age != AgeGroup.adult) ...<Widget>[
              const SizedBox(height: 12),
              AgeBanner(group: _age, accent: topic.color),
            ],
          ],
          ..._sections(topic),
```

- [ ] **Step 6: Run the tests to verify they pass**

Run: `flutter test test/age_switch_widget_test.dart`
Expected: PASS, 7 tests.

- [ ] **Step 7: Verify the whole suite and analyzer**

Run: `flutter analyze && flutter test`
Expected: `No issues found!` · `All tests passed!`

- [ ] **Step 8: Commit**

```bash
git add lib/features/conditions/presentation/widgets/age_switch.dart \
        lib/features/conditions/presentation/condition_detail_screen.dart \
        lib/l10n/ test/age_switch_widget_test.dart
git commit -m "Add the adult / child / infant switch to the condition screen"
```

---

## Task 4: Focus mode follows the selected age

**Files:**
- Modify: `lib/features/tools/focus_mode_screen.dart:10-46`
- Modify: `lib/features/conditions/presentation/condition_detail_screen.dart:259-290` (`_ToolsRow`)
- Test: `test/age_switch_widget_test.dart` (append)

**Interfaces:**
- Consumes: `AgeGroup`, `allStepsFor` from Task 1; `_age` from Task 3.
- Produces: `FocusModeScreen({required FirstAidTopic topic, AgeGroup age = AgeGroup.adult})` and `FocusModeScreen.route(FirstAidTopic topic, {AgeGroup age = AgeGroup.adult})`.

- [ ] **Step 1: Write the failing test**

Append to `test/age_switch_widget_test.dart`, inside `main()`:

```dart
  testWidgets('Given infant is selected, When focus mode opens, Then it shows infant steps',
      (WidgetTester tester) async {
    await tester.pumpWidget(await _app(ConditionDetailScreen(topic: cpr)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Infant'));
    await tester.pumpAndSettle();

    // The focus-mode chip in _ToolsRow.
    await tester.tap(find.byIcon(Icons.view_carousel_outlined));
    await tester.pumpAndSettle();

    expect(find.textContaining('tap the sole of the foot'), findsOneWidget);
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/age_switch_widget_test.dart --plain-name 'focus mode opens'`
Expected: FAIL — the adult first step renders instead of the infant one.

- [ ] **Step 3: Teach focus mode about age**

In `lib/features/tools/focus_mode_screen.dart`, replace the constructor and route:

```dart
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
```

In `build`, replace line 44:

```dart
    final List<LocalizedText> steps = widget.topic.allStepsFor(widget.age);
```

- [ ] **Step 4: Pass the age from the condition screen**

In `condition_detail_screen.dart`, `_ToolsRow` currently takes only a topic. Give it the age.

Change its declaration:

```dart
class _ToolsRow extends StatelessWidget {
  const _ToolsRow({required this.topic, required this.age});

  final FirstAidTopic topic;
  final AgeGroup age;
```

Change the focus-mode push inside it:

```dart
          onPressed: () =>
              Navigator.of(context).push(FocusModeScreen.route(topic, age: age)),
```

And in `build`, change the call site:

```dart
          _ToolsRow(topic: topic, age: _age),
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `flutter test test/age_switch_widget_test.dart`
Expected: PASS, 8 tests.

- [ ] **Step 6: Verify the whole suite and analyzer**

Run: `flutter analyze && flutter test`
Expected: `No issues found!` · `All tests passed!`

- [ ] **Step 7: Commit**

```bash
git add lib/features/tools/focus_mode_screen.dart \
        lib/features/conditions/presentation/condition_detail_screen.dart \
        test/age_switch_widget_test.dart
git commit -m "Carry the chosen age into focus mode"
```

---

## Task 5: The remaining four variants

**Files:**
- Modify: `lib/features/conditions/data/topics_extended.dart` — `drowning` (`:127`), `burns` is in `topics_original.dart`, `anaphylaxis` (`:486`)
- Modify: `lib/features/conditions/data/topics_original.dart` — `burns` (`:204`), `seizures` (`:413`)
- Test: `test/age_variants_test.dart` (append)

**Interfaces:**
- Consumes: `AgeGroup`, `ageVariants` from Task 1.
- Produces: `ageVariants` on `drowning`, `burns`, `anaphylaxis`, `seizures`.

- [ ] **Step 1: Write the failing test**

Append to `test/age_variants_test.dart`, inside `main()`:

```dart
  group('Remaining paediatric variants', () {
    test('Given the catalogue, Then six topics carry age variants', () {
      final Set<String> withVariants = kFirstAidTopics
          .where((FirstAidTopic t) => t.hasAgeVariants)
          .map((FirstAidTopic t) => t.id)
          .toSet();

      expect(withVariants, <String>{
        'cpr',
        'choking',
        'drowning',
        'burns',
        'anaphylaxis',
        'seizures',
      });
    });

    test('Given paediatric drowning, Then rescue breaths come first', () {
      for (final AgeGroup group in <AgeGroup>[AgeGroup.child, AgeGroup.infant]) {
        final String text = topicById('drowning')!
            .allStepsFor(group)
            .map((LocalizedText t) => t.en.toLowerCase())
            .join(' ');
        expect(text, contains('five rescue breaths'), reason: group.name);
      }
    });

    test('Given paediatric burns, Then hypothermia is warned about', () {
      final String text = topicById('burns')!
          .ageVariants[AgeGroup.infant]!
          .expand((FirstAidSection s) => s.callouts)
          .map((FirstAidCallout c) => c.text.en.toLowerCase())
          .join(' ');

      expect(text, contains('cold'));
    });

    test('Given child anaphylaxis, Then the junior dose is named', () {
      final String text = topicById('anaphylaxis')!
          .allStepsFor(AgeGroup.child)
          .map((LocalizedText t) => t.en.toLowerCase())
          .join(' ');

      expect(text, contains('0.15'));
      expect(text, contains('30 kg'));
    });

    test('Given child seizures, Then it points at the febrile seizure topic', () {
      final String text = topicById('seizures')!
          .allStepsFor(AgeGroup.child)
          .map((LocalizedText t) => t.en.toLowerCase())
          .join(' ');

      expect(text, contains('febrile'));
    });
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/age_variants_test.dart --plain-name 'Remaining paediatric variants'`
Expected: FAIL — the set holds only `cpr` and `choking`.

- [ ] **Step 3: Add the drowning variants**

In `topics_extended.dart`, inside the `drowning` topic, after its `sections:` list. Both ages share
one section body because the difference from the adult procedure is the same for both:

```dart
    ageVariants: <AgeGroup, List<FirstAidSection>>{
      AgeGroup.child: <FirstAidSection>[_paediatricDrowning],
      AgeGroup.infant: <FirstAidSection>[_paediatricDrowning],
    },
```

And add this private constant at the bottom of `topics_extended.dart`, outside the list:

```dart
/// Shared by the child and infant drowning variants: what changes from the
/// adult procedure is identical for both, and duplicating it would mean two
/// places to keep correct.
const FirstAidSection _paediatricDrowning = FirstAidSection(
  title: LocalizedText(
    en: 'Steps — child or infant',
    ar: 'الخطوات — طفل أو رضيع',
  ),
  steps: <LocalizedText>[
    LocalizedText(
      en: 'Get them out of the water safely without putting yourself in danger, and call an ambulance (123).',
      ar: 'أخرجه من الماء بأمان دون أن تعرّض نفسك للخطر، واتصل بالإسعاف (123).',
    ),
    LocalizedText(
      en: 'Lay them on their back on a firm surface and check whether they are breathing, for no more than 10 seconds.',
      ar: 'ضعه على ظهره على سطح صلب، وافحص تنفسه لمدة لا تزيد عن 10 ثوانٍ.',
    ),
    LocalizedText(
      en: 'If they are not breathing normally, give five rescue breaths before any chest compressions — drowning stops the breathing first, so the breaths matter most.',
      ar: 'إذا لم يكن تنفسه طبيعيًا فأعطِ خمسة أنفاس إنقاذية قبل أي ضغطات على الصدر؛ فالغرق يوقف التنفس أولًا، ولذلك تكون الأنفاس هي الأهم.',
    ),
    LocalizedText(
      en: 'Then continue with cycles of 30 compressions to 2 breaths, using the technique for their age.',
      ar: 'ثم واصل بدورات من 30 ضغطة مقابل نفسين، بالأسلوب المناسب لعمره.',
    ),
    LocalizedText(
      en: 'Do not try to press water out of the lungs or turn them upside down. It wastes time and causes vomiting.',
      ar: 'لا تحاول إخراج الماء من الرئتين أو قلبه رأسًا على عقب؛ فذلك يضيّع الوقت ويسبب القيء.',
    ),
    LocalizedText(
      en: 'Once they are breathing, place them on their side, keep them warm with dry clothing or a blanket, and stay with them.',
      ar: 'بمجرد أن يتنفس، ضعه على جانبه، ودفّئه بملابس جافة أو بطانية، وابقَ معه.',
    ),
  ],
  callouts: <FirstAidCallout>[
    FirstAidCallout(
      type: CalloutType.danger,
      text: LocalizedText(
        en: 'Every child who has been rescued from water must be seen at hospital, even if they seem completely recovered. Water in the lungs can cause trouble hours later.',
        ar: 'كل طفل أُنقذ من الماء يجب عرضه على المستشفى حتى لو بدا أنه تعافى تمامًا؛ فالماء في الرئتين قد يسبب مشكلة بعد ساعات.',
      ),
    ),
    FirstAidCallout(
      type: CalloutType.warning,
      text: LocalizedText(
        en: 'A small child gets cold very quickly. Dry them and cover them as soon as they are breathing.',
        ar: 'الطفل الصغير يبرد بسرعة كبيرة؛ جفّفه وغطّه فور أن يتنفس.',
      ),
    ),
  ],
);
```

- [ ] **Step 4: Add the burns variant**

In `topics_original.dart`, inside the `burns` topic, after its `sections:` list. One shared section,
keyed for both ages:

```dart
    ageVariants: <AgeGroup, List<FirstAidSection>>{
      AgeGroup.child: <FirstAidSection>[_paediatricBurns],
      AgeGroup.infant: <FirstAidSection>[_paediatricBurns],
    },
```

And at the bottom of `topics_original.dart`, outside the list:

```dart
/// Shared by the child and infant burn variants. What changes is the same for
/// both: a small body loses heat fast, and the same burn is proportionally
/// far larger than it would be on an adult.
const FirstAidSection _paediatricBurns = FirstAidSection(
  title: LocalizedText(
    en: 'Steps — child or infant',
    ar: 'الخطوات — طفل أو رضيع',
  ),
  steps: <LocalizedText>[
    LocalizedText(
      en: 'Stop the burning: move them away from the heat and take off any clothing or nappy soaked in hot liquid, unless it is stuck to the skin.',
      ar: 'أوقف الحرق: أبعده عن مصدر الحرارة وانزع أي ملابس أو حفاض مبلل بسائل ساخن، إلا إذا كان ملتصقًا بالجلد.',
    ),
    LocalizedText(
      en: 'Cool the burn under cool — not cold — running water for 20 minutes. Cool the burn only, and keep the rest of the body covered and warm.',
      ar: 'برّد الحرق تحت ماء جارٍ فاتر — لا بارد — لمدة 20 دقيقة. برّد موضع الحرق فقط، وأبقِ باقي الجسم مغطى ودافئًا.',
    ),
    LocalizedText(
      en: 'While cooling, watch for shivering or a cold body. If they start to shiver, stop cooling and wrap them up.',
      ar: 'أثناء التبريد راقب الارتعاش أو برودة الجسم. إذا بدأ يرتعش فأوقف التبريد ولفّه بغطاء.',
    ),
    LocalizedText(
      en: 'Cover the burn loosely with cling film laid on lengthways, or a clean non-fluffy cloth. Never wrap it tightly around a limb.',
      ar: 'غطِّ الحرق برفق بشريحة بلاستيك مطبخي موضوعة بالطول أو بقطعة قماش نظيفة غير وبرية، ولا تلفّه بإحكام حول طرف أبدًا.',
    ),
    LocalizedText(
      en: 'Take any child with a burn larger than the palm of their own hand to hospital, and any burn at all on the face, hands, feet, or genitals.',
      ar: 'اذهب بالطفل إلى المستشفى إذا كان الحرق أكبر من كف يده هو، وكذلك أي حرق مهما كان صغيرًا في الوجه أو اليدين أو القدمين أو المنطقة التناسلية.',
    ),
    LocalizedText(
      en: 'Take any burn on a baby under one year to hospital, whatever its size.',
      ar: 'اذهب بأي حرق يصيب رضيعًا أقل من سنة إلى المستشفى مهما كان حجمه.',
    ),
  ],
  callouts: <FirstAidCallout>[
    FirstAidCallout(
      type: CalloutType.danger,
      text: LocalizedText(
        en: 'A small body goes cold during cooling far faster than an adult\'s. Cool the burn, but keep the child warm — a burn that has been cooled into hypothermia is a second emergency.',
        ar: 'الجسم الصغير يبرد أثناء التبريد أسرع بكثير من جسم البالغ. برّد الحرق وأبقِ الطفل دافئًا؛ فالتبريد الذي يؤدي إلى انخفاض حرارة الجسم يصنع حالة طارئة ثانية.',
      ),
    ),
    FirstAidCallout(
      type: CalloutType.warning,
      text: LocalizedText(
        en: 'Never use ice, iced water, butter, toothpaste, or flour. On a child\'s thin skin they cause further damage.',
        ar: 'لا تستخدم أبدًا ثلجًا أو ماءً مثلجًا أو زبدة أو معجون أسنان أو دقيقًا؛ فهي تسبب ضررًا إضافيًا على جلد الطفل الرقيق.',
      ),
    ),
  ],
);
```

- [ ] **Step 5: Add the anaphylaxis variant**

In `topics_extended.dart`, inside the `anaphylaxis` topic, after its `sections:` list:

```dart
    ageVariants: <AgeGroup, List<FirstAidSection>>{
      AgeGroup.child: <FirstAidSection>[
        FirstAidSection(
          title: LocalizedText(
            en: 'Steps — child or infant',
            ar: 'الخطوات — طفل أو رضيع',
          ),
          steps: <LocalizedText>[
            LocalizedText(
              en: 'Call an ambulance (123) straight away and say the word "anaphylaxis".',
              ar: 'اتصل بالإسعاف (123) فورًا وقل كلمة «تحسس تأقي» أو «حساسية شديدة».',
            ),
            LocalizedText(
              en: 'Use their adrenaline auto-injector without waiting: the junior 0.15 mg device for a child under 30 kg, the 0.3 mg device for a child over 30 kg.',
              ar: 'استخدم حاقن الأدرينالين الخاص به دون انتظار: جهاز الأطفال 0.15 مجم لمن يقل وزنه عن 30 كجم، وجهاز 0.3 مجم لمن يزيد وزنه عن 30 كجم.',
            ),
            LocalizedText(
              en: 'Inject into the outer thigh, through clothing if necessary, and hold it in place for the time printed on the device. Hold the leg still — a struggling child can tear the skin on the needle.',
              ar: 'احقن في الجانب الخارجي للفخذ، من فوق الملابس إن لزم، وثبّته للمدة المكتوبة على الجهاز. ثبّت الساق جيدًا؛ فحركة الطفل قد تُمزّق الجلد بالإبرة.',
            ),
            LocalizedText(
              en: 'Lay them flat with their legs raised. If they are struggling to breathe, let them sit up. If they are vomiting or drowsy, place them on their side.',
              ar: 'أضجعه على ظهره وارفع ساقيه. وإذا كان يجد صعوبة في التنفس فدعه يجلس، وإذا كان يتقيأ أو يميل للنعاس فضعه على جانبه.',
            ),
            LocalizedText(
              en: 'If there is no improvement after 5 minutes, give a second dose in the other thigh.',
              ar: 'إذا لم يتحسّن خلال 5 دقائق فأعطِ جرعة ثانية في الفخذ الآخر.',
            ),
            LocalizedText(
              en: 'Stay with them until the ambulance arrives, even if they look much better.',
              ar: 'ابقَ معه حتى وصول الإسعاف، حتى لو بدا أنه تحسّن كثيرًا.',
            ),
          ],
          callouts: <FirstAidCallout>[
            FirstAidCallout(
              type: CalloutType.danger,
              text: LocalizedText(
                en: 'Never stand a child up or sit them upright suddenly during anaphylaxis, and never let them walk. It can stop the heart.',
                ar: 'لا تُوقِف الطفل أبدًا ولا تُجلسه فجأة أثناء نوبة الحساسية الشديدة، ولا تدعه يمشي؛ فقد يؤدي ذلك إلى توقف القلب.',
              ),
            ),
            FirstAidCallout(
              type: CalloutType.warning,
              text: LocalizedText(
                en: 'Antihistamine syrup does not treat anaphylaxis. Adrenaline first, always.',
                ar: 'شراب مضاد الهيستامين لا يعالج الحساسية الشديدة. الأدرينالين أولًا دائمًا.',
              ),
            ),
          ],
        ),
      ],
    },
```

Note: anaphylaxis gets a **child** variant only. The auto-injector guidance is the same for an
infant over 7.5 kg, and below that the dose is a clinician's decision the app must not make. The
`ageOptions` getter shows Adult and Child, and the test in Task 1 already permits partial coverage.

- [ ] **Step 6: Add the seizures variant**

In `topics_original.dart`, inside the `seizures` topic, after its `sections:` list:

```dart
    ageVariants: <AgeGroup, List<FirstAidSection>>{
      AgeGroup.child: <FirstAidSection>[
        FirstAidSection(
          title: LocalizedText(
            en: 'Steps — child (1 year to puberty)',
            ar: 'الخطوات — طفل (من سنة حتى البلوغ)',
          ),
          steps: <LocalizedText>[
            LocalizedText(
              en: 'Note the time the fit started. How long it lasts is the single most useful thing you can tell a doctor.',
              ar: 'سجّل وقت بداية التشنج؛ فمدة استمراره هي أهم ما يمكنك إخبار الطبيب به.',
            ),
            LocalizedText(
              en: 'Put them on the floor on their side, clear of furniture and anything hard or sharp. Put nothing under the head that could cover the face.',
              ar: 'ضعه على الأرض على جانبه بعيدًا عن الأثاث وأي شيء صلب أو حاد، ولا تضع تحت رأسه شيئًا قد يغطي وجهه.',
            ),
            LocalizedText(
              en: 'Loosen anything tight around the neck and stay with them. Do not hold them down and do not put anything in their mouth.',
              ar: 'فُكّ أي شيء ضاغط حول الرقبة وابقَ معه. لا تُمسكه بالقوة ولا تضع أي شيء في فمه.',
            ),
            LocalizedText(
              en: 'If the child has a fever with the fit and is between 6 months and 5 years old, this is most likely a febrile convulsion — open the "Febrile convulsion" topic, which covers it in full.',
              ar: 'إذا كان التشنج مصحوبًا بارتفاع في الحرارة وكان عمر الطفل بين 6 شهور و5 سنوات فالأرجح أنه تشنج حراري — افتح حالة «تشنج الحرارة» فهي تشرحه بالكامل.',
            ),
            LocalizedText(
              en: 'When the fit stops, keep them on their side and let them sleep. Being drowsy and confused afterwards is normal.',
              ar: 'عند توقف التشنج أبقِه على جانبه ودعه ينام؛ فالنعاس والتشوش بعده أمر طبيعي.',
            ),
            LocalizedText(
              en: 'Call an ambulance (123) if the fit lasts more than 5 minutes, another starts before they wake, it is their first ever fit, they are hurt, or they do not wake up properly afterwards.',
              ar: 'اتصل بالإسعاف (123) إذا استمر التشنج أكثر من 5 دقائق، أو بدأ تشنج آخر قبل أن يفيق، أو كان أول تشنج في حياته، أو أُصيب، أو لم يستعد وعيه بشكل طبيعي بعده.',
            ),
          ],
          callouts: <FirstAidCallout>[
            FirstAidCallout(
              type: CalloutType.danger,
              text: LocalizedText(
                en: 'Never put a finger, spoon, cloth, or anything else in the mouth of a child having a fit. They cannot swallow their tongue, and you will break teeth or be bitten.',
                ar: 'لا تضع أبدًا إصبعًا أو ملعقة أو قطعة قماش أو أي شيء في فم طفل يتشنج؛ فهو لا يستطيع ابتلاع لسانه، وستكسر أسنانه أو يعضّك.',
              ),
            ),
          ],
        ),
      ],
    },
```

- [ ] **Step 7: Run the tests to verify they pass**

Run: `flutter test test/age_variants_test.dart`
Expected: PASS, 21 tests.

- [ ] **Step 8: Verify the whole suite and analyzer**

Run: `flutter analyze && flutter test`
Expected: `No issues found!` · `All tests passed!`

- [ ] **Step 9: Commit**

```bash
git add lib/features/conditions/data/ test/age_variants_test.dart
git commit -m "Add paediatric steps for drowning, burns, anaphylaxis and seizures"
```

---

## Task 6: The three paediatric topics

**Files:**
- Create: `lib/features/conditions/data/topics_paediatric.dart`
- Modify: `lib/features/conditions/data/first_aid_data.dart:1-11`
- Test: `test/age_variants_test.dart` (append)

**Interfaces:**
- Consumes: `FirstAidTopic`, `isPaediatric` from Task 1.
- Produces: `const List<FirstAidTopic> kPaediatricTopics`, holding ids `febrile_seizure`, `child_dehydration`, `swallowed_object`, appended to `kFirstAidTopics`.

- [ ] **Step 1: Write the failing test**

Append to `test/age_variants_test.dart`, inside `main()`:

```dart
  group('Paediatric topics', () {
    test('Given the catalogue, Then the three child topics are present', () {
      for (final String id in <String>[
        'febrile_seizure',
        'child_dehydration',
        'swallowed_object',
      ]) {
        expect(topicById(id), isNotNull, reason: id);
        expect(topicById(id)!.isPaediatric, isTrue, reason: id);
      }
    });

    test('Given the catalogue, Then it now holds 20 topics', () {
      expect(kFirstAidTopics.length, 20);
    });

    test('Given the febrile seizure topic, Then it warns against restraining', () {
      final String text = topicById('febrile_seizure')!
          .allSteps
          .map((LocalizedText t) => t.en.toLowerCase())
          .join(' ');

      expect(text, contains('do not hold'));
      expect(text, contains('nothing in'));
    });

    test('Given the dehydration topic, Then oral rehydration salts are the first action', () {
      final String first = topicById('child_dehydration')!.allSteps.first.en.toLowerCase();
      expect(first, contains('oral rehydration'));
    });

    test('Given the swallowed object topic, Then button batteries are called urgent', () {
      final String text = topicById('swallowed_object')!
          .allSteps
          .map((LocalizedText t) => t.en.toLowerCase())
          .join(' ');

      expect(text, contains('button battery'));
    });
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/age_variants_test.dart --plain-name 'Paediatric topics'`
Expected: FAIL — `Expected: not null  Actual: <null>` for `febrile_seizure`.

- [ ] **Step 3: Create the topics file**

Create `lib/features/conditions/data/topics_paediatric.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/localized_text.dart';
import '../model/first_aid_topic.dart';

/// Emergencies that only happen to children, so they carry no age switch —
/// they are already written for a child throughout.
const List<FirstAidTopic> kPaediatricTopics = <FirstAidTopic>[
  FirstAidTopic(
    id: 'febrile_seizure',
    category: TopicCategory.medical,
    icon: Icons.thermostat,
    color: AppColors.accentOrange,
    isPaediatric: true,
    title: LocalizedText(en: 'Febrile convulsion', ar: 'تشنج الحرارة'),
    summary: LocalizedText(
      en: 'A fit brought on by fever in a young child.',
      ar: 'تشنج يحدث بسبب ارتفاع الحرارة عند الأطفال الصغار.',
    ),
    overview: LocalizedText(
      en: 'A febrile convulsion happens to otherwise healthy children between 6 months and 5 years when their temperature rises quickly. It is terrifying to watch and almost always harmless. Your job is to keep them safe and time it.',
      ar: 'يحدث تشنج الحرارة للأطفال الأصحاء بين 6 شهور و5 سنوات عندما ترتفع حرارتهم بسرعة. منظره مُفزع لكنه في الغالب غير مؤذٍ. مهمتك أن تحافظ على سلامته وأن تحسب مدته.',
    ),
    sections: <FirstAidSection>[
      FirstAidSection(
        title: LocalizedText(en: 'During the fit', ar: 'أثناء التشنج'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Look at the clock and note the time it started.',
            ar: 'انظر إلى الساعة وسجّل وقت البداية.',
          ),
          LocalizedText(
            en: 'Lay the child on the floor on their side, away from furniture, stairs, and anything hard or hot.',
            ar: 'ضع الطفل على الأرض على جانبه بعيدًا عن الأثاث والسلالم وأي شيء صلب أو ساخن.',
          ),
          LocalizedText(
            en: 'Loosen tight clothing around the neck and remove extra layers — the room should be comfortable, not cold.',
            ar: 'فُكّ الملابس الضيقة حول الرقبة وانزع الطبقات الزائدة؛ فالغرفة يجب أن تكون مريحة لا باردة.',
          ),
          LocalizedText(
            en: 'Do not hold the child down or try to stop the shaking. Do not put anything in their mouth — not a finger, a spoon, a cloth, or water.',
            ar: 'لا تُمسك الطفل بالقوة ولا تحاول إيقاف الرجفة. ولا تضع أي شيء في فمه — لا إصبعًا ولا ملعقة ولا قماشًا ولا ماءً.',
          ),
          LocalizedText(
            en: 'Do not put them in a cold or iced bath and do not pour cold water over them.',
            ar: 'لا تضعه في حمام بارد أو مثلج ولا تصبّ عليه ماءً باردًا.',
          ),
          LocalizedText(
            en: 'Stay beside them and keep watching the clock. Most fits stop on their own within 2 to 3 minutes.',
            ar: 'ابقَ بجانبه وواصل مراقبة الساعة؛ فمعظم التشنجات تتوقف وحدها خلال دقيقتين إلى ثلاث.',
          ),
        ],
        callouts: <FirstAidCallout>[
          FirstAidCallout(
            type: CalloutType.danger,
            text: LocalizedText(
              en: 'Call an ambulance (123) if the fit lasts more than 5 minutes, a second fit starts before the child wakes, they go blue or stop breathing, or they are under 6 months or over 5 years old.',
              ar: 'اتصل بالإسعاف (123) إذا استمر التشنج أكثر من 5 دقائق، أو بدأ تشنج ثانٍ قبل أن يفيق الطفل، أو ازرقّ لونه أو توقف تنفسه، أو كان عمره أقل من 6 شهور أو أكثر من 5 سنوات.',
            ),
          ),
        ],
      ),
      FirstAidSection(
        title: LocalizedText(en: 'After the fit', ar: 'بعد التشنج'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Keep them on their side and let them sleep. Being deeply drowsy and confused for up to an hour afterwards is normal.',
            ar: 'أبقِه على جانبه ودعه ينام؛ فالنعاس الشديد والتشوش لمدة تصل إلى ساعة بعده أمر طبيعي.',
          ),
          LocalizedText(
            en: 'Once they are fully awake, give paracetamol at the dose for their weight to bring the fever down and make them comfortable.',
            ar: 'بعد أن يستيقظ تمامًا، أعطِه الباراسيتامول بالجرعة المناسبة لوزنه لخفض الحرارة وراحته.',
          ),
          LocalizedText(
            en: 'Offer small sips of fluid once they are awake enough to swallow safely.',
            ar: 'قدّم له رشفات صغيرة من السوائل بعد أن يستيقظ بما يكفي للبلع بأمان.',
          ),
          LocalizedText(
            en: 'Have a doctor see them the same day, even if they seem completely back to normal — the fever still needs a cause.',
            ar: 'اعرضه على طبيب في اليوم نفسه حتى لو عاد إلى طبيعته تمامًا؛ فسبب الحرارة ما زال يحتاج إلى تشخيص.',
          ),
        ],
        callouts: <FirstAidCallout>[
          FirstAidCallout(
            type: CalloutType.danger,
            text: LocalizedText(
              en: 'Go to hospital now if the child has a stiff neck, a rash that does not fade when pressed, repeated vomiting, or does not wake properly. These are signs of meningitis, not a simple febrile convulsion.',
              ar: 'اذهب إلى المستشفى فورًا إذا كان لدى الطفل تيبّس في الرقبة، أو طفح جلدي لا يختفي بالضغط عليه، أو قيء متكرر، أو لم يستعد وعيه بشكل صحيح. هذه علامات التهاب سحائي وليست تشنج حرارة بسيطًا.',
            ),
          ),
          FirstAidCallout(
            type: CalloutType.tip,
            text: LocalizedText(
              en: 'Fever medicine does not prevent febrile convulsions. Give it to make a feverish child comfortable, not out of fear of another fit.',
              ar: 'خافض الحرارة لا يمنع تشنج الحرارة. أعطِه لراحة الطفل المحموم، لا خوفًا من تشنج آخر.',
            ),
          ),
        ],
      ),
    ],
  ),
  FirstAidTopic(
    id: 'child_dehydration',
    category: TopicCategory.medical,
    icon: Icons.water_drop,
    color: AppColors.accentBlue,
    isPaediatric: true,
    title: LocalizedText(
      en: 'Dehydration in children',
      ar: 'الجفاف عند الأطفال',
    ),
    summary: LocalizedText(
      en: 'Fluid loss from diarrhoea or vomiting — dangerous fast in small children.',
      ar: 'فقدان السوائل بسبب الإسهال أو القيء — يصبح خطيرًا بسرعة عند الأطفال الصغار.',
    ),
    overview: LocalizedText(
      en: 'A small child loses fluid far faster than an adult and has far less in reserve. Most deaths from gastroenteritis are from dehydration, not from the infection — and oral rehydration salts prevent almost all of them.',
      ar: 'الطفل الصغير يفقد السوائل أسرع بكثير من البالغ ومخزونه أقل بكثير. معظم الوفيات الناتجة عن النزلة المعوية سببها الجفاف لا العدوى نفسها — ومحلول معالجة الجفاف يمنع معظمها.',
    ),
    sections: <FirstAidSection>[
      FirstAidSection(
        title: LocalizedText(en: 'Signs to look for', ar: 'العلامات التي تبحث عنها'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'A dry mouth and tongue, and crying without tears.',
            ar: 'جفاف الفم واللسان، والبكاء بلا دموع.',
          ),
          LocalizedText(
            en: 'Fewer wet nappies than usual — fewer than four in a day, or none at all for 6 to 8 hours.',
            ar: 'عدد حفاضات مبللة أقل من المعتاد — أقل من أربع في اليوم، أو لا شيء لمدة 6 إلى 8 ساعات.',
          ),
          LocalizedText(
            en: 'Sunken eyes, and in a baby a sunken soft spot on the top of the head.',
            ar: 'غؤور العينين، وعند الرضيع غؤور اليافوخ في أعلى الرأس.',
          ),
          LocalizedText(
            en: 'Unusual sleepiness, floppiness, or irritability.',
            ar: 'نعاس غير معتاد أو ارتخاء أو تهيّج شديد.',
          ),
        ],
      ),
      FirstAidSection(
        title: LocalizedText(en: 'What to do', ar: 'ماذا تفعل'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'Start oral rehydration salts straight away. Buy the sachets from any pharmacy and mix one sachet into exactly 1 litre of clean drinking water.',
            ar: 'ابدأ بمحلول معالجة الجفاف فورًا. اشترِ الأكياس من أي صيدلية وأذب كيسًا واحدًا في لتر واحد بالضبط من مياه الشرب النظيفة.',
          ),
          LocalizedText(
            en: 'Use the whole sachet and the full litre. A stronger or weaker mix does harm, not good.',
            ar: 'استخدم الكيس كاملًا واللتر كاملًا؛ فالخلطة الأقوى أو الأضعف تضر ولا تنفع.',
          ),
          LocalizedText(
            en: 'Give it in small amounts, often: a teaspoon or two every one to two minutes. Big gulps come straight back up.',
            ar: 'أعطِه بكميات صغيرة ومتكررة: ملعقة صغيرة أو اثنتين كل دقيقة إلى دقيقتين؛ فالكميات الكبيرة تعود بالقيء فورًا.',
          ),
          LocalizedText(
            en: 'If they vomit, wait 10 minutes and start again more slowly. Do not give up — slow and steady still gets fluid in.',
            ar: 'إذا تقيأ فانتظر 10 دقائق ثم ابدأ من جديد ببطء أكثر. لا تستسلم؛ فالبطء والثبات يُدخلان السوائل فعلًا.',
          ),
          LocalizedText(
            en: 'Keep breastfeeding or giving milk, more often and for shorter times. Never stop a baby\'s milk because of diarrhoea.',
            ar: 'واصل الرضاعة الطبيعية أو إعطاء الحليب، بمرات أكثر ولمدة أقصر. ولا توقف حليب الرضيع أبدًا بسبب الإسهال.',
          ),
          LocalizedText(
            en: 'Give another drink of the solution after every loose stool, and go on offering normal food as soon as they will take it.',
            ar: 'أعطِه شربة أخرى من المحلول بعد كل إخراج لين، وواصل تقديم الطعام المعتاد بمجرد أن يقبله.',
          ),
        ],
        callouts: <FirstAidCallout>[
          FirstAidCallout(
            type: CalloutType.danger,
            text: LocalizedText(
              en: 'Go to hospital now if there is blood in the stool, green vomit, no urine for 8 hours, the child cannot keep any fluid down, they are very drowsy or floppy, or the child is under 6 months old.',
              ar: 'اذهب إلى المستشفى فورًا إذا كان هناك دم في البراز، أو قيء أخضر، أو انقطاع البول 8 ساعات، أو عجز الطفل عن الاحتفاظ بأي سائل، أو كان شديد النعاس أو مرتخيًا، أو كان عمره أقل من 6 شهور.',
            ),
          ),
          FirstAidCallout(
            type: CalloutType.warning,
            text: LocalizedText(
              en: 'Do not give anti-diarrhoea medicines to a child. They trap the infection instead of clearing it.',
              ar: 'لا تعطِ الطفل أدوية إيقاف الإسهال؛ فهي تحبس العدوى بدلًا من التخلص منها.',
            ),
          ),
          FirstAidCallout(
            type: CalloutType.warning,
            text: LocalizedText(
              en: 'Plain water, fizzy drinks, and fruit juice are not substitutes. Juice and soft drinks make diarrhoea worse.',
              ar: 'الماء وحده والمشروبات الغازية والعصائر ليست بديلًا؛ بل العصير والمشروبات الغازية تزيد الإسهال سوءًا.',
            ),
          ),
        ],
      ),
    ],
  ),
  FirstAidTopic(
    id: 'swallowed_object',
    category: TopicCategory.medical,
    icon: Icons.battery_alert,
    color: AppColors.accentPurple,
    isPaediatric: true,
    title: LocalizedText(
      en: 'Swallowed object',
      ar: 'ابتلاع جسم غريب',
    ),
    summary: LocalizedText(
      en: 'A battery, magnet, coin, or sharp object swallowed by a child.',
      ar: 'ابتلاع الطفل لبطارية أو مغناطيس أو عملة أو جسم حاد.',
    ),
    overview: LocalizedText(
      en: 'Most swallowed objects pass on their own. Four do not, and one of them — the flat button battery — burns through the food pipe in hours. Knowing which is which is the whole of this topic.',
      ar: 'معظم الأجسام المبتلعة تخرج وحدها. أربعة لا تخرج، وأحدها — بطارية القرص المسطحة — تحرق المريء خلال ساعات. معرفة الفرق بينها هي كل ما في هذه الحالة.',
    ),
    sections: <FirstAidSection>[
      FirstAidSection(
        title: LocalizedText(en: 'What to do first', ar: 'ماذا تفعل أولًا'),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'If the child cannot breathe, is coughing silently, or is turning blue, the object is in the airway — go to the "Choking" topic and act now.',
            ar: 'إذا كان الطفل لا يستطيع التنفس أو يسعل بصمت أو يزرقّ لونه فالجسم في مجرى الهواء — افتح حالة «الغصة» وتصرّف فورًا.',
          ),
          LocalizedText(
            en: 'Do not make the child vomit, and do not give food or drink until a doctor has said it is safe.',
            ar: 'لا تجعل الطفل يتقيأ، ولا تعطه طعامًا أو شرابًا حتى يؤكد الطبيب أن ذلك آمن.',
          ),
          LocalizedText(
            en: 'If you have the packet or an identical object, take it with you to the hospital — it tells the doctor exactly what they are dealing with.',
            ar: 'إذا كانت العبوة أو جسم مطابق متاحًا فخذه معك إلى المستشفى؛ فهو يخبر الطبيب بما يتعامل معه بالضبط.',
          ),
        ],
      ),
      FirstAidSection(
        title: LocalizedText(
          en: 'Go to hospital immediately for these',
          ar: 'اذهب للمستشفى فورًا في هذه الحالات',
        ),
        steps: <LocalizedText>[
          LocalizedText(
            en: 'A button battery — the flat, round kind from a watch, remote, toy, or hearing aid. This is an emergency measured in hours, not days, and it must be removed even if the child seems perfectly well.',
            ar: 'بطارية قرص — النوع المسطح الدائري من الساعة أو الريموت أو اللعبة أو سماعة الأذن. هذه حالة طارئة تُقاس بالساعات لا بالأيام، ويجب إخراجها حتى لو بدا الطفل بخير تمامًا.',
          ),
          LocalizedText(
            en: 'Two or more magnets, or one magnet with any metal object. They pull towards each other through the walls of the bowel and cut through them.',
            ar: 'مغناطيسان أو أكثر، أو مغناطيس مع أي جسم معدني. فهي تنجذب لبعضها عبر جدران الأمعاء وتقطعها.',
          ),
          LocalizedText(
            en: 'Anything sharp — a needle, pin, bone, or piece of broken glass.',
            ar: 'أي شيء حاد — إبرة أو دبوس أو عظمة أو قطعة زجاج مكسور.',
          ),
          LocalizedText(
            en: 'A coin, which needs an x-ray: one that has stopped in the food pipe has to be taken out.',
            ar: 'عملة معدنية، فهي تحتاج أشعة؛ لأن العملة التي توقفت في المريء يجب إخراجها.',
          ),
          LocalizedText(
            en: 'A nut or seed that was inhaled while eating, if the child has been coughing or wheezing since — it may be in the lung.',
            ar: 'مكسرات أو بذرة استُنشقت أثناء الأكل إذا ظل الطفل يسعل أو يصفر صدره بعدها — فقد تكون في الرئة.',
          ),
        ],
        callouts: <FirstAidCallout>[
          FirstAidCallout(
            type: CalloutType.danger,
            text: LocalizedText(
              en: 'Drooling, refusing to eat, pain on swallowing, chest or tummy pain, vomiting, or noisy breathing after swallowing something all mean hospital now.',
              ar: 'سيلان اللعاب أو رفض الأكل أو ألم عند البلع أو ألم في الصدر أو البطن أو القيء أو تنفس مصحوب بصوت بعد ابتلاع شيء — كلها تعني المستشفى فورًا.',
            ),
          ),
          FirstAidCallout(
            type: CalloutType.tip,
            text: LocalizedText(
              en: 'A small, smooth, blunt object in a well child often just passes. Let a doctor make that call rather than deciding at home.',
              ar: 'الجسم الصغير الأملس غير الحاد كثيرًا ما يخرج وحده عند طفل بحالة جيدة. اترك هذا القرار للطبيب بدلًا من تقريره في البيت.',
            ),
          ),
        ],
      ),
    ],
  ),
];
```

- [ ] **Step 4: Append them to the catalogue**

In `lib/features/conditions/data/first_aid_data.dart`, add the import and the spread:

```dart
import '../model/first_aid_topic.dart';
import 'topics_extended.dart';
import 'topics_original.dart';
import 'topics_paediatric.dart';

/// The single source of truth for every first-aid topic in the app.
final List<FirstAidTopic> kFirstAidTopics = <FirstAidTopic>[
  ...kOriginalTopics,
  ...kExtendedTopics,
  ...kPaediatricTopics,
];
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `flutter test test/age_variants_test.dart`
Expected: PASS, 26 tests.

- [ ] **Step 6: Verify the whole suite and analyzer**

Run: `flutter analyze && flutter test`
Expected: `No issues found!` · `All tests passed!` — including `first_aid_data_test.dart`, whose
bilingual and unique-id checks now cover the three new topics automatically.

- [ ] **Step 7: Commit**

```bash
git add lib/features/conditions/data/ test/age_variants_test.dart
git commit -m "Add febrile convulsion, child dehydration and swallowed object"
```

---

## Task 7: The children filter on Home

**Files:**
- Modify: `lib/providers/search_provider.dart:1-23`
- Modify: `lib/features/home/home_screen.dart:144-174`
- Modify: `lib/l10n/app_ar.arb`, `lib/l10n/app_en.arb`
- Test: `test/providers_test.dart` (append a group)

**Interfaces:**
- Consumes: `concernsChildren` from Task 1; the six variant topics and three paediatric topics from Tasks 2, 5, 6.
- Produces: `final StateProvider<bool> childrenFilterProvider`; l10n key `categoryChildren`.

- [ ] **Step 1: Add the l10n strings**

In `lib/l10n/app_en.arb`, after `"categoryMedical"`:

```json
  "categoryChildren": "For children",
```

In `lib/l10n/app_ar.arb`, in the same position:

```json
  "categoryChildren": "للأطفال",
```

Run: `flutter gen-l10n`

- [ ] **Step 2: Write the failing test**

Append to `test/providers_test.dart`, inside `main()`. The file already defines
`makeContainer([seed])` at the top of `main()` and already declares `late ProviderContainer
container` — reuse both rather than writing a second helper:

```dart
  group('Children filter', () {
    test('Given the filter is on, Then only child-relevant topics remain', () async {
      container = await makeContainer();

      container.read(childrenFilterProvider.notifier).state = true;
      final List<FirstAidTopic> topics = container.read(filteredTopicsProvider);

      expect(
        topics.map((FirstAidTopic t) => t.id).toSet(),
        <String>{
          'cpr',
          'choking',
          'drowning',
          'burns',
          'anaphylaxis',
          'seizures',
          'febrile_seizure',
          'child_dehydration',
          'swallowed_object',
        },
      );
    });

    test('Given the filter is off, Then every topic is listed', () async {
      container = await makeContainer();

      expect(container.read(filteredTopicsProvider).length, kFirstAidTopics.length);
    });

    test('Given the filter and a search query, Then both apply', () async {
      container = await makeContainer();

      container.read(childrenFilterProvider.notifier).state = true;
      container.read(searchQueryProvider.notifier).state = 'dehydration';

      expect(
        container.read(filteredTopicsProvider).map((FirstAidTopic t) => t.id),
        <String>['child_dehydration'],
      );
    });
  });
```

`providers_test.dart` already imports `search_provider.dart`; add this import for the catalogue:

```dart
import 'package:help_me/features/conditions/data/first_aid_data.dart';
```

- [ ] **Step 3: Run the test to verify it fails**

Run: `flutter test test/providers_test.dart --plain-name 'Children filter'`
Expected: compile failure — `Undefined name 'childrenFilterProvider'`.

- [ ] **Step 4: Add the provider**

In `lib/providers/search_provider.dart`, add after `selectedCategoryProvider`:

```dart
/// Whether the home list is narrowed to what a parent needs.
///
/// Kept separate from [selectedCategoryProvider] rather than added to
/// [TopicCategory]: "for children" is not a body system, and folding it into
/// that enum would make the category taxonomy mean two different things.
final StateProvider<bool> childrenFilterProvider = StateProvider<bool>((ref) => false);
```

And extend `filteredTopicsProvider`:

```dart
final Provider<List<FirstAidTopic>> filteredTopicsProvider =
    Provider<List<FirstAidTopic>>((ref) {
  final String query = ref.watch(searchQueryProvider);
  final TopicCategory? category = ref.watch(selectedCategoryProvider);
  final bool childrenOnly = ref.watch(childrenFilterProvider);
  return kFirstAidTopics.where((FirstAidTopic topic) {
    final bool inCategory = category == null || topic.category == category;
    final bool forChildren = !childrenOnly || topic.concernsChildren;
    return inCategory && forChildren && topic.matches(query);
  }).toList();
});
```

- [ ] **Step 5: Add the chip**

In `lib/features/home/home_screen.dart`, replace the body of `_CategoryChips.build`:

```dart
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TopicCategory? selected = ref.watch(selectedCategoryProvider);
    final bool childrenOnly = ref.watch(childrenFilterProvider);

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          _Chip(
            label: l10n.categoryAll,
            selected: selected == null && !childrenOnly,
            onSelected: () {
              ref.read(selectedCategoryProvider.notifier).state = null;
              ref.read(childrenFilterProvider.notifier).state = false;
            },
          ),
          // Sits second, ahead of the body-system categories: a parent looking
          // for it under stress should not have to scroll past six chips.
          _Chip(
            label: '👶 ${l10n.categoryChildren}',
            selected: childrenOnly,
            onSelected: () => ref.read(childrenFilterProvider.notifier).state =
                !childrenOnly,
          ),
          for (final TopicCategory category in TopicCategory.values)
            _Chip(
              label: category.label(l10n),
              selected: selected == category,
              onSelected: () =>
                  ref.read(selectedCategoryProvider.notifier).state = category,
            ),
        ],
      ),
    );
  }
```

- [ ] **Step 6: Run the tests to verify they pass**

Run: `flutter test test/providers_test.dart`
Expected: PASS.

- [ ] **Step 7: Verify the whole suite and analyzer**

Run: `flutter analyze && flutter test`
Expected: `No issues found!` · `All tests passed!`

- [ ] **Step 8: Commit**

```bash
git add lib/providers/search_provider.dart lib/features/home/home_screen.dart \
        lib/l10n/ test/providers_test.dart
git commit -m "Add the for-children filter to the home screen"
```

---

## Task 8: Illustrations follow the selected age

Today `choking` shows `assets/steps/choking_infant.svg` to everyone, including someone treating an
adult. And `cpr`'s diagrams are adult hand positions — showing them under an infant banner would
teach the exact thing this feature exists to prevent.

**Files:**
- Modify: `lib/features/conditions/data/topic_media_data.dart` — add the by-age map, remove the infant image from adult `choking`
- Modify: `lib/features/conditions/presentation/condition_detail_screen.dart` — resolve images by age
- Test: `test/topic_media_test.dart` (append)

**Interfaces:**
- Consumes: `AgeGroup` from Task 1; `_age` from Task 3; existing `kTopicMedia`, `TopicImage`.
- Produces: `const Map<String, List<TopicImage>> kTopicImagesByAge` keyed `'<topicId>:<age.name>'`; `List<TopicImage> imagesFor(String topicId, AgeGroup age)`.

- [ ] **Step 1: Write the failing test**

Append to `test/topic_media_test.dart`, inside `main()`:

```dart
  group('Age-specific illustrations', () {
    test('Given adult choking, Then the infant drawing is not shown', () {
      final List<String> assets = imagesFor('choking', AgeGroup.adult)
          .map((TopicImage i) => i.asset)
          .toList();

      expect(assets, isNot(contains('assets/steps/choking_infant.svg')));
    });

    test('Given infant choking, Then the infant drawing is the one shown', () {
      final List<String> assets = imagesFor('choking', AgeGroup.infant)
          .map((TopicImage i) => i.asset)
          .toList();

      expect(assets, <String>['assets/steps/choking_infant.svg']);
    });

    test('Given infant CPR, Then no adult hand-position drawing is shown', () {
      expect(imagesFor('cpr', AgeGroup.infant), isEmpty);
    });

    test('Given a topic with no by-age entry, Then it falls back to its own images', () {
      expect(
        imagesFor('bleeding', AgeGroup.infant),
        kTopicMedia['bleeding']!.images,
      );
    });

    test('Given every by-age key, Then it names a real topic and age', () {
      final Set<String> topicIds =
          kFirstAidTopics.map((FirstAidTopic t) => t.id).toSet();
      final Set<String> ageNames =
          AgeGroup.values.map((AgeGroup g) => g.name).toSet();

      for (final String key in kTopicImagesByAge.keys) {
        final List<String> parts = key.split(':');
        expect(parts.length, 2, reason: key);
        expect(topicIds, contains(parts[0]), reason: key);
        expect(ageNames, contains(parts[1]), reason: key);
      }
    });

    test('Given every by-age image, Then its asset is under assets/', () {
      for (final List<TopicImage> images in kTopicImagesByAge.values) {
        for (final TopicImage image in images) {
          expect(image.asset, startsWith('assets/'), reason: image.asset);
          expect(image.caption.isComplete, isTrue, reason: image.asset);
        }
      }
    });
  });
```

Add whatever of these imports the file does not already have:

```dart
import 'package:help_me/core/media/topic_media.dart';
import 'package:help_me/features/conditions/data/first_aid_data.dart';
import 'package:help_me/features/conditions/data/topic_media_data.dart';
import 'package:help_me/features/conditions/model/first_aid_topic.dart';
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/topic_media_test.dart --plain-name 'Age-specific illustrations'`
Expected: compile failure — `Undefined name 'imagesFor'`.

- [ ] **Step 3: Add the by-age map and lookup**

At the bottom of `lib/features/conditions/data/topic_media_data.dart`, after `kTopicMedia`:

```dart
/// Images that replace a topic's own when a particular age is selected.
///
/// Keyed `'<topicId>:<age.name>'`, matching the by-id keying of [kTopicMedia].
///
/// An **empty list is meaningful and is not the same as no entry**: it says "no
/// correct picture for this age exists yet, so show none". Falling back would
/// put adult hand-position diagrams under an infant banner, which teaches the
/// wrong thing more convincingly than words could.
const Map<String, List<TopicImage>> kTopicImagesByAge = <String, List<TopicImage>>{
  'cpr:child': <TopicImage>[],
  'cpr:infant': <TopicImage>[],
  'choking:infant': <TopicImage>[
    TopicImage(
      asset: 'assets/steps/choking_infant.svg',
      caption: LocalizedText(
        en: 'Back blows and chest thrusts for a baby under one year',
        ar: 'ضربات الظهر وضغطات الصدر لرضيع أقل من سنة',
      ),
    ),
  ],
};

/// The illustrations to show for [topicId] at [age].
///
/// An explicit by-age entry always wins, including an empty one. Everything
/// else falls back to the topic's own images, which is right for age-neutral
/// pictures like cooling a burn.
List<TopicImage> imagesFor(String topicId, AgeGroup age) =>
    kTopicImagesByAge['$topicId:${age.name}'] ??
    kTopicMedia[topicId]?.images ??
    const <TopicImage>[];
```

Add the import for `AgeGroup` at the top of the file if it is not already present:

```dart
import '../model/first_aid_topic.dart';
```

- [ ] **Step 4: Take the infant drawing out of the adult choking gallery**

In the same file, in the `'choking'` entry, delete the `TopicImage` whose asset is
`assets/steps/choking_infant.svg` (around line 96) together with its caption. It now lives in
`kTopicImagesByAge` under `'choking:infant'`.

- [ ] **Step 5: Resolve images by age on the condition screen**

In `condition_detail_screen.dart`, `build` currently reads:

```dart
    final TopicMedia media = kTopicMedia[topic.id] ?? const TopicMedia();
```

Add the age-resolved image list beneath it:

```dart
    final List<TopicImage> images = imagesFor(topic.id, _age);
```

And change the gallery block from `media.images` to `images`:

```dart
          if (images.isEmpty)
            _HeroIllustration(topic: topic)
          else
            TopicGallery(images: images, accent: topic.color),
```

`media` stays in use for `media.videos` further down — leave that alone.

- [ ] **Step 6: Run the tests to verify they pass**

Run: `flutter test test/topic_media_test.dart`
Expected: PASS.

- [ ] **Step 7: Verify the whole suite and analyzer**

Run: `flutter analyze && flutter test`
Expected: `No issues found!` · `All tests passed!`

- [ ] **Step 8: Commit**

```bash
git add lib/features/conditions/data/topic_media_data.dart \
        lib/features/conditions/presentation/condition_detail_screen.dart \
        test/topic_media_test.dart
git commit -m "Show the illustration that matches the chosen age"
```

---

## Task 9: Sources and documentation

The clinician review named in the spec needs something concrete to check against.

**Files:**
- Create: `docs/medical_sources.md`
- Modify: `README.md:29-50` (features list), `README.md:80-83` (design principle paragraph)

**Interfaces:**
- Consumes: every topic id touched in Tasks 2, 5, 6.
- Produces: nothing code-facing.

- [ ] **Step 1: Write the sources file**

Create `docs/medical_sources.md`:

```markdown
# Medical sources

Every piece of first-aid guidance in this app traces to a published lay-rescuer standard. This
file exists so a clinician reviewing the content has something concrete to check against, rather
than having to infer intent from prose.

**The app is written by a developer, not a clinician.** Where guidance differs between bodies, the
app teaches the simpler action that is safe under both.

## Standards followed

- **ERC** — European Resuscitation Council Guidelines, Basic Life Support and Paediatric Life
  Support chapters.
- **AHA** — American Heart Association Guidelines for CPR and ECC, lay-rescuer sequences.
- **WHO** — oral rehydration therapy for diarrhoea in children.

## Paediatric content added in 4.0 phase A

| Topic / variant | Standard | Key points a reviewer should check |
| --- | --- | --- |
| `cpr` · child | ERC Paediatric BLS | Five initial rescue breaths; one or two hands; ~5 cm, one third of chest depth; 30:2 for a lone lay rescuer; paediatric AED pads preferred, adult pads acceptable. |
| `cpr` · infant | ERC Paediatric BLS | Neutral head position; mouth-and-nose seal; two fingers; ~4 cm, one third of chest depth; five initial breaths; 30:2. |
| `choking` · child | ERC / AHA | Five back blows then five abdominal thrusts; no blind finger sweep; medical review after abdominal thrusts. |
| `choking` · infant | ERC / AHA | Back blows and **chest** thrusts only; abdominal thrusts contraindicated under one year. |
| `drowning` · child & infant | ERC | Five initial rescue breaths; no attempt to drain water; hospital assessment for every rescued child. |
| `burns` · child & infant | ERC / burn-care consensus | 20 minutes cool running water; hypothermia risk during cooling; palm-size threshold; any burn on an infant reviewed. |
| `anaphylaxis` · child | ERC / auto-injector labelling | 0.15 mg under 30 kg, 0.3 mg over; outer thigh; supine with legs raised; second dose at 5 minutes. |
| `seizures` · child | ERC / epilepsy first-aid consensus | Time it; side position; no restraint; nothing in the mouth; five-minute ambulance threshold. |
| `febrile_seizure` | Paediatric febrile-convulsion consensus | 6 months to 5 years; no restraint; no cooling baths; five-minute threshold; meningitis red flags; antipyretics do not prevent recurrence. |
| `child_dehydration` | WHO oral rehydration therapy | One sachet per 1 litre clean water, exactly; small frequent volumes; continue breastfeeding; no anti-diarrhoeals in children. |
| `swallowed_object` | Paediatric GI foreign-body consensus | Button battery as a same-day emergency; multiple magnets; sharps; coin needing imaging; nothing by mouth. |

## Review status

- [ ] Reviewed by a paediatrician before store release.
```

- [ ] **Step 2: Update the README**

In `README.md`, add to the features list after the "17 first-aid topics" bullet:

```markdown
- 👶 **Child & infant mode** — CPR, choking, drowning, burns, anaphylaxis and seizures each carry
  the correct technique for an infant (under 1) and a child, chosen with a switch on the condition
  screen. Plus three paediatric emergencies of their own: febrile convulsion, dehydration, and a
  swallowed object.
```

Then make these three exact replacements in `README.md`:

| Line | From | To |
| --- | --- | --- |
| ~21 (Arabic overview) | `لأكثر من ١٥ حالة طارئة` | `لأكثر من ٢٠ حالة طارئة` |
| ~21-22 (English overview) | `guidance for 17 emergencies` | `guidance for 20 emergencies` |
| ~31 (features list) | `**17 first-aid topics**` | `**20 first-aid topics**` |

Also append to the topic list on line 31-33, after `severe allergy (anaphylaxis)`:
`, febrile convulsion, child dehydration, and swallowed objects`.

- [ ] **Step 3: Verify**

Run: `flutter analyze && flutter test`
Expected: `No issues found!` · `All tests passed!`

- [ ] **Step 4: Commit**

```bash
git add docs/medical_sources.md README.md
git commit -m "Record medical sources and document child and infant mode"
```

---

## Done when

- `flutter analyze` → `No issues found!`
- `flutter test` → all passing, roughly 200 tests
- `cpr` and `choking` offer Adult / Child / Infant; `bleeding` offers no switch
- Opening any topic shows Adult, every time
- The 👶 chip narrows Home to nine topics
- Selecting Infant on `choking` shows the infant drawing; selecting Adult does not
- `docs/medical_sources.md` exists with its review checkbox unticked
