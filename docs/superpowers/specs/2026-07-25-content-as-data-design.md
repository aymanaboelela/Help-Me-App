# Content as Data — Moving Medical Content Out of Dart into JSON

**Date:** 2026-07-25
**Status:** approved, ready for planning
**Branch:** `revamp/help-me-2.0`
**Siblings:** [`2026-07-25-help-me-3.0-design.md`](2026-07-25-help-me-3.0-design.md) ·
[`2026-07-25-child-infant-mode-design.md`](2026-07-25-child-infant-mode-design.md) ·
[`2026-07-25-visual-system-and-platform-fidelity-design.md`](2026-07-25-visual-system-and-platform-fidelity-design.md)

## Problem

Every word of medical content in this app is a Dart literal. 3,762 lines across seven files hold
`LocalizedText(en: '…', ar: '…')` constructors interleaved with `IconData` references, `Color`
tokens, and enum values. Three consequences follow, and they are the reason for this work:

**1. Only a Dart programmer can change the content.** Correcting a first-aid step means opening
`topics_extended.dart`, matching Dart string-escaping rules for Arabic text containing apostrophes,
and not breaking the surrounding const expression. The people best placed to review medical
accuracy are the people least able to make the edit.

**2. Content review and code review are the same review.** A pull request that adds a burn step and
a pull request that changes the search algorithm look alike in the diff. A reviewer checking
clinical accuracy has to read past `const List<FirstAidTopic>` scaffolding, and a reviewer checking
code has to skim 300 lines of Arabic prose. Neither review gets the attention it needs.

**3. Serving this content from an API later means rewriting the app, not adding a layer.** Every
consumer reads a compile-time global (`kFirstAidTopics`, `kLessons`) synchronously. An API is
asynchronous by nature. Eighteen call sites across eleven files, plus five test files, are written
against the assumption that content is a `const` that cannot fail, and that assumption is
load-bearing in all of them.

A fourth, structural problem shows up once you try to move the content: three model classes are
declared *inside* the data files they describe — `KitItem` in `kit_catalogue.dart`, `EmergencyNumber`
and `EmergencyCountry` in `emergency_numbers.dart`. Data and schema live in the same file, so the
data cannot be removed without taking the schema with it.

UI strings are not part of this problem — they already live in
[`app_en.arb`](../../../lib/l10n/app_en.arb) / [`app_ar.arb`](../../../lib/l10n/app_ar.arb) and are
generated through `flutter gen-l10n`. ARB is Flutter's official localisation format and stays.
This spec is only about the medical content.

## Goals

- A non-programmer can edit any piece of medical content without opening a Dart file.
- Content changes produce diffs that are reviewable as content.
- Moving to an API later costs one new class, not a rewrite.
- The app opens instantly and works fully offline, before and after that move.
- The migration is provably lossless — not assumed lossless.

## Non-goals

- Migrating ARB UI strings. They are already correct.
- Adding a third language. The design does not obstruct it, but nothing here is built for it.
- Building the API. This spec makes the API cheap to add; it does not add it.
- A content editing UI or CMS. Content is edited as files, reviewed as pull requests.

## Content inventory

| New asset | Source | Volume |
| --- | --- | --- |
| `assets/content/topics.json` | `conditions/data/topics_original.dart` + `topics_extended.dart` | 17 topics (7 + 10) |
| `assets/content/topic_media.json` | `conditions/data/topic_media_data.dart` | 17 entries — images, videos, photo credits |
| `assets/content/lessons.json` | `learn/data/lessons.dart` | 8 lessons with cards and check questions |
| `assets/content/daily_tips.json` | `learn/data/daily_tips.dart` | 47 tips |
| `assets/content/quiz.json` | `learn/data/quiz_bank.dart` | 16 standalone questions |
| `assets/content/kit.json` | `health/data/kit_catalogue.dart` | 25 kit items |
| `assets/content/emergency_numbers.json` | `emergency/data/emergency_numbers.dart` | 4 countries (EG, SA, AE, International) |
| `assets/content/badges.json` | `providers/learn_provider.dart:157-198` | 5 badges |

`learn/data/tip_of_day.dart` stays in Dart. `tipForDate` is selection logic, not content, and its
day-of-year arithmetic belongs in code. Its signature changes, though: it currently reads the
`kDailyTips` global directly, so it becomes `tipForDate(DateTime date, List<DailyTip> tips)` and the
caller supplies the list. One caller —
[`learn_provider.dart:144`](../../../lib/providers/learn_provider.dart#L144). (The doc comment above
it claims the notification path shares the function; it does not, and the comment should go.)

One file per content type, not one file per topic. Order is itself data — the catalogue order of
`kFirstAidTopics` is the order the home grid renders — and a JSON array preserves it without an
invented `order` field, loads in one read, and matches a `GET /topics` response one-to-one.

### Models move out of the data files

`KitItem`, `EmergencyNumber` and `EmergencyCountry` are declared inside the data files being
deleted. They move to `health/model/kit_item.dart` and `emergency/model/emergency_number.dart`,
matching where every other model in the app already lives. This is step 1 of the migration and
lands on its own — otherwise deleting the data takes the schema with it.

## JSON shape

Bilingual text stays as one object with both languages side by side:

```json
{
  "id": "swallowed_tongue",
  "category": "breathing",
  "icon": "airline_seat_flat",
  "color": "accentTeal",
  "title": { "en": "Swallowed tongue", "ar": "بلع اللسان" },
  "summary": { "en": "Clearing the airway…", "ar": "تأمين مجرى الهواء…" },
  "showCallAmbulance": true,
  "showMetronome": false,
  "isPaediatric": false,
  "sections": [
    {
      "title": { "en": "First aid", "ar": "الإسعافات الأولية" },
      "steps": [
        { "en": "Tilt the head back…", "ar": "إمالة الرأس إلى الخلف…" }
      ],
      "callouts": [
        { "type": "danger", "text": { "en": "…", "ar": "…" } }
      ]
    }
  ],
  "ageVariants": {
    "child": [ { "title": {…}, "steps": [ … ] } ]
  }
}
```

Not one file per language. Two reasons: a translator seeing both variants on one line notices
drift, and separate files can silently diverge — a step added to English and forgotten in Arabic.
A single object makes that structurally impossible for required fields. It also maps exactly onto
the existing [`LocalizedText`](../../../lib/core/localized_text.dart) class, so no model changes.

Enum values are their Dart names: `TopicCategory.breathing` → `"breathing"`, `CalloutType.danger` →
`"danger"`, `AgeGroup.child` → `"child"`, `KitSection.dressings` → `"dressings"`.

`Duration` is encoded as `"durationSeconds": 71`, not as a structured object.

### Icons and colours are names resolved through a registry

`lib/core/content/content_registry.dart` holds two closed maps:

```dart
const Map<String, IconData> kContentIcons = <String, IconData>{
  'airline_seat_flat': Icons.airline_seat_flat,
  'bloodtype': Icons.bloodtype,
  // …one entry per icon the content uses
};

const Map<String, Color> kContentColors = <String, Color>{
  'accentTeal': AppColors.accentTeal,
  // …
};
```

**The icon registry is mandatory, not stylistic.** Flutter's release builds run
`--tree-shake-icons`, which strips any glyph not referenced as a compile-time constant. An
`IconData` constructed from a code point read out of JSON renders as a blank box in a store build
while working perfectly in debug — a defect that only appears after shipping.

The practical consequence: a content editor may use any icon already in the registry without a
programmer. A genuinely new icon needs one line from a programmer. That limit is real and is stated
rather than hidden; the alternative is an app that breaks in release only.

The colour registry carries the same constraint, and there it is a feature. Preventing content from
specifying a raw hex value is what keeps the app visually consistent and dark-mode correct.

## Loading layer

New files under `lib/core/content/`:

| File | Responsibility |
| --- | --- |
| `content_registry.dart` | name → `IconData` / `Color` maps |
| `app_content.dart` | `AppContent` — the whole loaded bundle |
| `content_repository.dart` | `abstract class ContentRepository { Future<AppContent> load(); }` |
| `asset_content_repository.dart` | reads the JSON assets through `rootBundle` |

`fromJson` and `toJson` go **on the models themselves**, in the existing model files. Not for style:
when the parser sits far from the field list, a new field can be added to the model and missed in
the parser without either reviewer seeing both at once. Adjacent, the omission is visible.

Sixteen classes need them: `LocalizedText`, `FirstAidCallout`, `FirstAidSection`, `FirstAidTopic`,
`PhotoCredit`, `TopicImage`, `TopicVideo`, `TopicMedia`, `DailyTip`, `LessonCard`, `QuizQuestion`,
`Lesson`, `LearnBadge`, `KitItem`, `EmergencyNumber`, `EmergencyCountry`.

No `json_serializable` and no `build_runner`. These models need custom handling anyway —
`Map<AgeGroup, List<FirstAidSection>>`, registry-resolved icons, `Duration` — and those converters
would be most of the work. Adding a codegen pipeline here is more machinery than it saves.

```dart
@immutable
class AppContent {
  final List<FirstAidTopic> topics;
  final Map<String, TopicMedia> media;
  final List<Lesson> lessons;
  final List<DailyTip> dailyTips;
  final List<QuizQuestion> quizExtras;
  final List<KitItem> kit;
  final List<EmergencyCountry> countries;
  final List<LearnBadge> badges;

  FirstAidTopic? topicById(String id);
}
```

`topicById` currently linear-scans the catalogue on every call
([`first_aid_data.dart:12-17`](../../../lib/features/conditions/data/first_aid_data.dart#L12-L17)).
`AppContent` builds an index map once at load — a free improvement that comes with the move.

### Consumers stay synchronous

Loading is asynchronous; the consumers are not. This follows the pattern `main.dart` already uses
for `SharedPreferences` and `HealthSnapshot`:

```dart
final AppContent content = await const AssetContentRepository().load();

runApp(ProviderScope(
  overrides: <Override>[
    sharedPreferencesProvider.overrideWithValue(prefs),
    secureStoreProvider.overrideWithValue(store),
    healthSnapshotProvider.overrideWithValue(health),
    appContentProvider.overrideWithValue(content),   // new
  ],
  child: const HelpMeApp(),
));
```

`appContentProvider` is a `Provider<AppContent>` that throws unless overridden. Derived providers
are plain synchronous `Provider`s:

```dart
final Provider<List<FirstAidTopic>> topicsProvider =
    Provider((ref) => ref.watch(appContentProvider).topics);
```

So `ref.watch(topicsProvider)` returns a `List<FirstAidTopic>`, not an `AsyncValue`. No screen
handles a loading or error state, and each consumer changes by one line.

The eighteen call sites, in full:

| File | Line | Global read |
| --- | --- | --- |
| [`providers/search_provider.dart`](../../../lib/providers/search_provider.dart#L19) | 19 | `kFirstAidTopics` |
| [`providers/favorites_provider.dart`](../../../lib/providers/favorites_provider.dart#L38) | 38 | `kFirstAidTopics` |
| [`providers/recent_provider.dart`](../../../lib/providers/recent_provider.dart#L35) | 35 | `topicById` |
| [`providers/learn_provider.dart`](../../../lib/providers/learn_provider.dart#L144) | 144 | `tipForDate` |
| [`providers/learn_provider.dart`](../../../lib/providers/learn_provider.dart#L210) | 210 | `kLessons` |
| [`providers/learn_provider.dart`](../../../lib/providers/learn_provider.dart#L215) | 215 | `kBadges` |
| [`learn/presentation/learn_screen.dart`](../../../lib/features/learn/presentation/learn_screen.dart#L41) | 41, 45 | `kLessons` |
| [`learn/presentation/learn_screen.dart`](../../../lib/features/learn/presentation/learn_screen.dart#L188) | 188 | `topicById` |
| [`learn/presentation/lesson_screen.dart`](../../../lib/features/learn/presentation/lesson_screen.dart#L70) | 70 | `topicById` |
| [`health/presentation/kit_screen.dart`](../../../lib/features/health/presentation/kit_screen.dart#L42) | 42 | `kKitCatalogue` |
| [`emergency/presentation/country_picker.dart`](../../../lib/features/emergency/presentation/country_picker.dart#L23) | 23 | `kCountries` |
| [`providers/country_provider.dart`](../../../lib/providers/country_provider.dart#L13) | 13, 17 | `countryByCode` |
| [`about/presentation/credits_screen.dart`](../../../lib/features/about/presentation/credits_screen.dart#L24) | 24, 30, 36 | `kTopicMedia` |
| [`conditions/presentation/condition_detail_screen.dart`](../../../lib/features/conditions/presentation/condition_detail_screen.dart#L203) | 203 | `kTopicMedia` |

`countryByCode` ([`emergency_numbers.dart:134`](../../../lib/features/emergency/data/emergency_numbers.dart#L134))
is a top-level lookup over `kCountries`; it moves onto `AppContent` alongside `topicById`. Same for
`topicsInCategory`.

### The rule that keeps the API safe to add

Bundled content is the seed. It always succeeds and the app always opens instantly from it. When the
API arrives it is a **refresh on top of the seed** — fetched in the background, cached for next
launch. Startup never waits on the network. The abstract interface above permits this without change.

This is not a future nicety. It is what stops a first-aid app from showing a spinner to someone
holding a bleeding arm on a bad connection.

### Failure of the bundled assets

Malformed bundled JSON is a build defect, not a runtime condition. The mitigation is the CI schema
test below: if the assets parse in CI they parse on device, because the bundle is the same bytes.

On device, a parse failure throws with a clear message rather than degrading quietly to partial
content. A fallback path for a condition CI makes impossible is untested code that grants false
confidence, and in a safety-critical app false confidence is worse than a crash.

## Validation and tests

New `test/content_schema_test.dart` asserts, over every asset:

- every `icon` and `color` name resolves in the registry
- every enum name is valid (`TopicCategory`, `CalloutType`, `AgeGroup`, `KitSection`)
- every `LocalizedText` is complete in both languages — `isComplete` already exists at
  [`localized_text.dart:21`](../../../lib/core/localized_text.dart#L21)
- every `topicId` referenced from lessons, tips, quiz questions and media resolves to a real topic
- every question's `answerIndex` is in range — `isValid` already exists
- ids are unique within each collection

A second, smaller test loads every asset **through `rootBundle`** rather than from disk. A JSON file
present on disk but not declared in `pubspec.yaml` passes a `File`-based test and fails on device;
this closes that gap.

The five existing tests that import the Dart globals —
[`first_aid_data_test.dart`](../../../test/first_aid_data_test.dart),
[`learn_test.dart`](../../../test/learn_test.dart),
[`topic_media_test.dart`](../../../test/topic_media_test.dart),
[`age_variants_test.dart`](../../../test/age_variants_test.dart),
[`reminders_test.dart`](../../../test/reminders_test.dart) — load content in `setUpAll` instead.
Their assertions do not change.

## Migration

The one real risk is content changing unnoticed. 3,762 lines of Arabic medical prose transcribed by
hand means a missing step in some condition, and a missing step can hurt someone. Therefore:

**The JSON is generated from the Dart. It is never hand-written.**

1. Move `KitItem`, `EmergencyNumber` and `EmergencyCountry` out of their data files into
   `model/` directories. Pure move, no behaviour change, so it lands and is reviewed on its own.
2. Add `fromJson`/`toJson` to the sixteen model classes, plus the registry, `AppContent` and the
   repository. Purely additive; nothing is removed yet.
3. `tool/export_content.dart` — a one-off script that imports the existing Dart data and writes the
   JSON through `toJson`. Zero manual transcription.
4. Run the export script to produce the eight asset files, and declare `assets/content/` in
   `pubspec.yaml`.
5. **Equivalence proof:** parse the JSON, re-serialise it, and compare byte-for-byte against the
   file the Dart export produced. Passing means the move is lossless — demonstrated, not assumed.
   This test is temporary and is deleted once the migration lands.
6. Change `tipForDate` to take its tip list as a parameter.
7. Switch the eighteen call sites to the providers.
8. Update the five test files; add the schema and bundle tests.
9. Delete the Dart data files and `tool/export_content.dart`.
10. Run the existing golden tests to confirm the UI is pixel-identical.

Step 5 is what makes this safe. Without it, this change is a gamble on medical content.

## Consequences

**Better.** Content is editable by non-programmers and reviewable as content. `topicById` gains an
index. Three model classes stop living in data files. The API becomes one new class. Content errors
that previously could not be expressed — a dangling `topicId`, an out-of-range answer index — are
now caught by a schema test that also guards against future hand edits.

**Worse.** Content errors move from compile time to test time; the CI gate is what compensates.
A brand-new icon or colour now needs a one-line registry addition alongside the content edit.
Sixteen model classes carry serialisation code they did not carry before, roughly doubling the size
of the model files.
