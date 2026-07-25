# Content as Data Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move all medical content out of Dart literals into JSON assets, behind an asynchronous repository, so non-programmers can edit content and an API can replace the asset source later without touching the app.

**Architecture:** Eight JSON files under `assets/content/` are parsed by `AssetContentRepository` into one immutable `AppContent` bundle. `main()` awaits that load and injects it into `ProviderScope` via `overrideWithValue`, exactly as it already does for `SharedPreferences` and `HealthSnapshot` — so every screen keeps reading content synchronously and no widget handles an `AsyncValue`. Icons and colours travel as names resolved through a closed registry, because Flutter's release-mode icon tree-shaking breaks dynamically constructed `IconData`.

**Tech Stack:** Flutter 3.41.9, Dart SDK `>=3.4.0 <4.0.0`, `flutter_riverpod` ^2.6.1, `dart:convert` for JSON. No new dependencies. No `build_runner`, no `json_serializable`.

**Spec:** [`docs/superpowers/specs/2026-07-25-content-as-data-design.md`](../specs/2026-07-25-content-as-data-design.md)

## Global Constraints

- **No new dependencies.** `pubspec.yaml` gains asset declarations only.
- **Riverpod ref type is `Ref`**, not `ProviderRef` — match the existing style in `lib/providers/learn_provider.dart`.
- **Never construct `IconData` from a code point.** Release builds run `--tree-shake-icons` and a dynamically built `IconData` renders as a blank box. Icons resolve only through `kContentIcons`.
- **Never put a raw hex colour in JSON.** Colours resolve only through `kContentColors`.
- **`toJson` must be deterministic** — fixed key order, fixed inclusion rules — because Task 8 compares its output byte-for-byte against the committed asset files.
- **JSON formatting:** `JsonEncoder.withIndent('  ')`, one trailing newline, Arabic left unescaped (Dart's `jsonEncode` does not escape non-ASCII).
- **Field inclusion rules, applied everywhere:** required fields always emitted; `null` optionals omitted; empty lists and empty maps omitted; **except** the three `FirstAidTopic` booleans (`showCallAmbulance`, `showMetronome`, `isPaediatric`), `FirstAidSection.steps`, and **every value inside `imagesByAge`**, which are always emitted so a content editor can see the field exists.
- **An empty `imagesByAge` entry is data, not absence.** `"cpr": {"imagesByAge": {"infant": []}}` means "no correct picture for an infant exists, show none". Dropping it as an empty list makes the loader fall back to the topic's own images, which puts adult CPR hand-position diagrams under an "Infant — under 1 year" banner. That is the exact failure the age switch exists to prevent. The empty list is load-bearing — emit it, round-trip it, and assert it.
- **Existing `badgesProvider` in `lib/providers/learn_provider.dart:203` returns `List<EarnedBadge>` and keeps that name.** The new content provider for the badge catalogue is `badgeCatalogueProvider`. Do not collide.
- **Content is never deleted before Task 15.** Tasks 1–14 are additive so the equivalence proof in Task 8 has both sides to compare.

## Test Baseline

> **Corrected 2026-07-25 after the child & infant mode work landed.** The baseline below replaces
> an earlier one that read "240 passing, 2 failing". Both of those failures are now fixed on this
> branch — `choking_infant.svg` is referenced through `kTopicImagesByAge`, and the gallery golden
> was regenerated. Do not restore either failure or treat a green suite as suspicious.

`flutter test` on this branch **before any change**: **308 passing, 0 failing**, and
`flutter analyze` reports `No issues found!`.

After Task 15 the suite must still be **fully green**, with the total rising by the tests this plan
adds. Any failure is a regression introduced by this work.

## File Structure

**Created**

| File | Responsibility |
| --- | --- |
| `lib/features/health/model/kit_item.dart` | `KitSection` enum + `KitItem` (moved out of the data file) |
| `lib/features/emergency/model/emergency_number.dart` | `EmergencyNumber` + `EmergencyCountry` (moved out of the data file) |
| `lib/core/content/content_registry.dart` | `ContentFormatException`, icon/colour name maps, `enumByName` |
| `lib/core/content/app_content.dart` | `AppContent` — the loaded bundle plus its lookups |
| `lib/core/content/content_repository.dart` | `abstract class ContentRepository` |
| `lib/core/content/asset_content_repository.dart` | Parses the eight assets out of an `AssetBundle` |
| `lib/providers/content_provider.dart` | `appContentProvider` + eight derived synchronous providers |
| `assets/content/*.json` | Eight generated content files |
| `test/support/test_content.dart` | `loadTestContent()` — reads the real assets from disk |
| `test/content_registry_test.dart` | Registry round-trip and uniqueness |
| `test/content_schema_test.dart` | Cross-file integrity over the real assets |
| `test/content_bundle_test.dart` | Assets are declared in `pubspec.yaml` and load through `rootBundle` |
| `test/content_export_test.dart` | **Temporary.** Writes the assets, then proves Dart ≡ JSON ≡ parsed. Deleted in Task 15. |

**Modified**

Sixteen model classes gain `fromJson`/`toJson`; `lib/main.dart`; `pubspec.yaml`; eighteen call sites across eleven files; ten test files.

**Deleted in Task 15**

`lib/features/conditions/data/{topics_original,topics_extended,topics_paediatric,first_aid_data,topic_media_data}.dart`,
`lib/features/learn/data/{lessons,daily_tips,quiz_bank}.dart`,
`lib/features/health/data/kit_catalogue.dart`,
`lib/features/emergency/data/emergency_numbers.dart`,
`test/content_export_test.dart`.

---

## Task 1: Move the three models out of their data files

`KitItem`, `EmergencyNumber` and `EmergencyCountry` are declared inside the data files Task 15 deletes. Move them first, as a pure move with no behaviour change, so the deletion cannot take the schema with it.

**Files:**
- Create: `lib/features/health/model/kit_item.dart`
- Create: `lib/features/emergency/model/emergency_number.dart`
- Modify: `lib/features/health/data/kit_catalogue.dart` (remove class + enum, add import)
- Modify: `lib/features/emergency/data/emergency_numbers.dart` (remove classes, add import)

**Interfaces:**
- Produces: `KitSection` enum, `KitItem` class, `EmergencyNumber` class, `EmergencyCountry` class — same public API as today, new import paths.

- [ ] **Step 1: Create `lib/features/health/model/kit_item.dart`**

Cut `KitSection` (currently `kit_catalogue.dart:4`) and `KitItem` (currently `kit_catalogue.dart:7-28`) verbatim, including their doc comments:

```dart
import 'package:flutter/foundation.dart';

import '../../../core/localized_text.dart';

/// How the checklist is grouped on screen.
enum KitSection { dressings, tools, medicines, protection, essentials }

/// One thing a home or car first-aid kit should contain.
@immutable
class KitItem {
  const KitItem({
    required this.id,
    required this.name,
    required this.section,
    this.note,
    this.perishable = false,
  });

  /// Stable id — this is what gets ticked and persisted, so renaming the
  /// English or Arabic text never loses somebody's progress.
  final String id;
  final LocalizedText name;
  final KitSection section;

  /// Why it is on the list, when that is not obvious.
  final LocalizedText? note;

  /// Has a shelf life. Items like these belong in the medicine cabinet too,
  /// which is where expiry dates and their reminders live.
  final bool perishable;
}
```

Note: `KitItem` was not annotated `@immutable` before. Adding it is correct — every other content model in this app carries it — and it compiles unchanged because all fields are already final.

- [ ] **Step 2: Create `lib/features/emergency/model/emergency_number.dart`**

Cut `EmergencyNumber` (`emergency_numbers.dart:5-21`) and `EmergencyCountry` (`emergency_numbers.dart:23-42`) verbatim with their doc comments:

```dart
import 'package:flutter/material.dart';

import '../../../core/localized_text.dart';

/// A single dialable emergency / utility hotline.
@immutable
class EmergencyNumber {
  const EmergencyNumber({
    required this.name,
    required this.number,
    required this.icon,
    this.critical = false,
  });

  final LocalizedText name;
  final String number;
  final IconData icon;

  /// Life-critical services (ambulance / police / fire) are surfaced first.
  final bool critical;
}

/// A country and its emergency numbers.
@immutable
class EmergencyCountry {
  const EmergencyCountry({
    required this.code,
    required this.name,
    required this.flag,
    required this.ambulance,
    required this.numbers,
  });

  final String code;
  final LocalizedText name;
  final String flag;

  /// The number dialed by the SOS button.
  final EmergencyNumber ambulance;

  /// The full list shown on the emergency screen (includes [ambulance]).
  final List<EmergencyNumber> numbers;
}
```

- [ ] **Step 3: Strip the moved code from both data files and re-export**

In `lib/features/health/data/kit_catalogue.dart`, delete the enum and class and put this at the top, keeping `export` so existing importers of the data file still see the types:

```dart
import '../../../core/localized_text.dart';
import '../model/kit_item.dart';

export '../model/kit_item.dart';
```

In `lib/features/emergency/data/emergency_numbers.dart`, delete both classes and put this at the top:

```dart
import 'package:flutter/material.dart';

import '../../../core/localized_text.dart';
import '../model/emergency_number.dart';

export '../model/emergency_number.dart';
```

The `export` lines are deliberate: they keep this task to a pure move with zero consumer edits. They disappear with the files in Task 15.

- [ ] **Step 4: Verify nothing broke**

Run: `flutter analyze && flutter test`
Expected: analyzer clean; **308 passing, 0 failing** — a fully green suite.

- [ ] **Step 5: Commit**

```bash
git add lib/features/health/model/kit_item.dart \
        lib/features/emergency/model/emergency_number.dart \
        lib/features/health/data/kit_catalogue.dart \
        lib/features/emergency/data/emergency_numbers.dart
git commit -m "refactor: move KitItem and emergency models out of their data files"
```

---

## Task 2: Content registry

**Files:**
- Create: `lib/core/content/content_registry.dart`
- Test: `test/content_registry_test.dart`

**Interfaces:**
- Produces:
  - `class ContentFormatException implements Exception` with `final String message`
  - `const Map<String, IconData> kContentIcons` — 40 entries
  - `const Map<String, Color> kContentColors` — 10 entries
  - `IconData iconByName(String name)` / `String nameOfIcon(IconData icon)`
  - `Color colorByName(String name)` / `String nameOfColor(Color color)`
  - `T enumByName<T extends Enum>(List<T> values, String name, String field)`

  Every one of these throws `ContentFormatException` on an unknown input. Nothing returns null.

- [ ] **Step 1: Write the failing test**

Create `test/content_registry_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/core/content/content_registry.dart';
import 'package:help_me/features/conditions/model/first_aid_topic.dart';

void main() {
  group('Icon registry', () {
    test('Given a known name, Then it resolves and names back', () {
      final IconData icon = iconByName('bloodtype');
      expect(icon, Icons.bloodtype);
      expect(nameOfIcon(icon), 'bloodtype');
    });

    test('Given an unknown name, Then it throws with the name in the message', () {
      expect(
        () => iconByName('not_a_real_icon'),
        throwsA(isA<ContentFormatException>().having(
          (ContentFormatException e) => e.message,
          'message',
          contains('not_a_real_icon'),
        )),
      );
    });

    test('Given the whole map, Then every icon is distinct', () {
      // nameOfIcon reverses the map, so two names sharing one IconData would
      // make the reverse lookup non-deterministic and break byte-comparison.
      expect(kContentIcons.values.toSet().length, kContentIcons.length);
    });

    test('Given every name, Then the round trip is stable', () {
      for (final String name in kContentIcons.keys) {
        expect(nameOfIcon(iconByName(name)), name);
      }
    });
  });

  group('Colour registry', () {
    test('Given a known name, Then it resolves and names back', () {
      final Color color = colorByName('accentTeal');
      expect(nameOfColor(color), 'accentTeal');
    });

    test('Given an unknown name, Then it throws', () {
      expect(() => colorByName('puce'), throwsA(isA<ContentFormatException>()));
    });

    test('Given the whole map, Then every colour is distinct', () {
      expect(kContentColors.values.toSet().length, kContentColors.length);
    });

    test('Given every name, Then the round trip is stable', () {
      for (final String name in kContentColors.keys) {
        expect(nameOfColor(colorByName(name)), name);
      }
    });
  });

  group('enumByName', () {
    test('Given a valid name, Then it returns the value', () {
      expect(
        enumByName(TopicCategory.values, 'breathing', 'topic.category'),
        TopicCategory.breathing,
      );
    });

    test('Given an invalid name, Then the error says which field', () {
      expect(
        () => enumByName(TopicCategory.values, 'nonsense', 'topic.category'),
        throwsA(isA<ContentFormatException>().having(
          (ContentFormatException e) => e.message,
          'message',
          allOf(contains('topic.category'), contains('nonsense')),
        )),
      );
    });
  });
}
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/content_registry_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:help_me/core/content/content_registry.dart'`.

- [ ] **Step 3: Write the registry**

Create `lib/core/content/content_registry.dart`:

```dart
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Thrown when content JSON names something the app does not know about.
///
/// Every failure carries the offending value and the field it came from, because
/// the person reading this message is editing a JSON file, not a Dart file.
class ContentFormatException implements Exception {
  const ContentFormatException(this.message);

  final String message;

  @override
  String toString() => 'ContentFormatException: $message';
}

/// Every icon content may name.
///
/// This map is not a convenience — it is required. Release builds run
/// `--tree-shake-icons`, which strips any glyph the compiler cannot see
/// referenced as a constant. An `IconData` built from a code point read out of
/// JSON renders as a blank box in a store build while working perfectly in
/// debug. Naming icons here keeps every glyph reachable.
///
/// Adding a new icon to content means adding one line here. That is the whole
/// cost, and it is the reason the app does not ship blank squares.
const Map<String, IconData> kContentIcons = <String, IconData>{
  'add_road': Icons.add_road,
  'air': Icons.air,
  'airline_seat_flat': Icons.airline_seat_flat,
  'airline_seat_individual_suite': Icons.airline_seat_individual_suite,
  'battery_alert': Icons.battery_alert,
  'bloodtype': Icons.bloodtype,
  'bolt': Icons.bolt,
  'calendar_month_outlined': Icons.calendar_month_outlined,
  'check_circle_outline': Icons.check_circle_outline,
  'electric_bolt': Icons.electric_bolt,
  'electrical_services': Icons.electrical_services,
  'emergency': Icons.emergency,
  'favorite': Icons.favorite,
  'fire_truck': Icons.fire_truck,
  'gas_meter': Icons.gas_meter,
  'local_fire_department': Icons.local_fire_department,
  'local_fire_department_outlined': Icons.local_fire_department_outlined,
  'local_police': Icons.local_police,
  'medical_services_outlined': Icons.medical_services_outlined,
  'monitor_heart': Icons.monitor_heart,
  'personal_injury': Icons.personal_injury,
  'pest_control': Icons.pest_control,
  'pool': Icons.pool,
  'psychology': Icons.psychology,
  'psychology_outlined': Icons.psychology_outlined,
  'school_outlined': Icons.school_outlined,
  'science': Icons.science,
  'security': Icons.security,
  'shopping_bag': Icons.shopping_bag,
  'sick': Icons.sick,
  'sos': Icons.sos,
  'thermostat': Icons.thermostat,
  'timer_outlined': Icons.timer_outlined,
  'traffic': Icons.traffic,
  'travel_explore': Icons.travel_explore,
  'vaccines': Icons.vaccines,
  'water_drop': Icons.water_drop,
  'water_drop_outlined': Icons.water_drop_outlined,
  'wb_sunny': Icons.wb_sunny,
  'workspace_premium_outlined': Icons.workspace_premium_outlined,
};

/// Every colour content may name.
///
/// Only the light-mode accent tokens. Content picks a *token*, and the theme
/// decides what that token looks like in light and dark — which is why content
/// may not specify a raw hex value. That restriction is what keeps 20 topics
/// from each inventing their own not-quite-right red.
const Map<String, Color> kContentColors = <String, Color>{
  'accentTeal': AppColors.accentTeal,
  'accentRed': AppColors.accentRed,
  'accentCrimson': AppColors.accentCrimson,
  'accentOrange': AppColors.accentOrange,
  'accentAmber': AppColors.accentAmber,
  'accentBlue': AppColors.accentBlue,
  'accentIndigo': AppColors.accentIndigo,
  'accentPurple': AppColors.accentPurple,
  'accentGreen': AppColors.accentGreen,
  'accentPink': AppColors.accentPink,
};

final Map<IconData, String> _iconNames = <IconData, String>{
  for (final MapEntry<String, IconData> e in kContentIcons.entries) e.value: e.key,
};

final Map<Color, String> _colorNames = <Color, String>{
  for (final MapEntry<String, Color> e in kContentColors.entries) e.value: e.key,
};

/// The icon named [name], or a [ContentFormatException] naming the culprit.
IconData iconByName(String name) {
  final IconData? icon = kContentIcons[name];
  if (icon == null) {
    throw ContentFormatException(
      'unknown icon "$name" — add it to kContentIcons in '
      'lib/core/content/content_registry.dart',
    );
  }
  return icon;
}

/// The registry name for [icon]. Used when writing content back out to JSON.
String nameOfIcon(IconData icon) {
  final String? name = _iconNames[icon];
  if (name == null) {
    throw ContentFormatException('icon $icon is not listed in kContentIcons');
  }
  return name;
}

/// The colour named [name], or a [ContentFormatException] naming the culprit.
Color colorByName(String name) {
  final Color? color = kContentColors[name];
  if (color == null) {
    throw ContentFormatException(
      'unknown colour "$name" — add it to kContentColors in '
      'lib/core/content/content_registry.dart',
    );
  }
  return color;
}

/// The registry name for [color]. Used when writing content back out to JSON.
String nameOfColor(Color color) {
  final String? name = _colorNames[color];
  if (name == null) {
    throw ContentFormatException('colour $color is not listed in kContentColors');
  }
  return name;
}

/// The value in [values] whose `name` is [name].
///
/// [field] is the JSON path being parsed, so the message points at the line to
/// fix rather than at the enum.
T enumByName<T extends Enum>(List<T> values, String name, String field) {
  for (final T value in values) {
    if (value.name == name) return value;
  }
  throw ContentFormatException(
    '$field: unknown value "$name" — expected one of '
    '${values.map((T v) => v.name).join(', ')}',
  );
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/content_registry_test.dart`
Expected: PASS, 10 tests.

If "every icon is distinct" fails, two registry names share one `IconData`. Remove the one the content does not use — do not keep both, because `nameOfIcon` would then be non-deterministic and Task 8's byte comparison would flake.

- [ ] **Step 5: Commit**

```bash
git add lib/core/content/content_registry.dart test/content_registry_test.dart
git commit -m "feat: add the content icon and colour registry"
```

---

## Task 3: Serialise the first-aid topic models

**Files:**
- Modify: `lib/core/localized_text.dart`
- Modify: `lib/features/conditions/model/first_aid_topic.dart`
- Test: `test/content_serialisation_test.dart`

**Interfaces:**
- Consumes: `iconByName`, `nameOfIcon`, `colorByName`, `nameOfColor`, `enumByName`, `ContentFormatException` from Task 2.
- Produces:
  - `LocalizedText.fromJson(Map<String, dynamic>)` / `Map<String, dynamic> toJson()`
  - `FirstAidCallout.fromJson` / `toJson`
  - `FirstAidSection.fromJson` / `toJson`
  - `FirstAidTopic.fromJson` / `toJson`

- [ ] **Step 1: Write the failing test**

Create `test/content_serialisation_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/app/theme/app_colors.dart';
import 'package:help_me/core/content/content_registry.dart';
import 'package:help_me/core/localized_text.dart';
import 'package:help_me/features/conditions/model/first_aid_topic.dart';

void main() {
  group('LocalizedText', () {
    test('Given both languages, Then it round-trips', () {
      const LocalizedText text = LocalizedText(en: 'Burns', ar: 'حروق');
      expect(LocalizedText.fromJson(text.toJson()), text);
      expect(text.toJson(), <String, dynamic>{'en': 'Burns', 'ar': 'حروق'});
    });
  });

  group('FirstAidCallout', () {
    test('Given a callout, Then the type is its enum name', () {
      const FirstAidCallout callout = FirstAidCallout(
        type: CalloutType.danger,
        text: LocalizedText(en: 'Call now', ar: 'اتصل حالًا'),
      );
      expect(callout.toJson()['type'], 'danger');
      final FirstAidCallout parsed = FirstAidCallout.fromJson(callout.toJson());
      expect(parsed.type, CalloutType.danger);
      expect(parsed.text, callout.text);
    });

    test('Given an unknown type, Then it throws naming the field', () {
      expect(
        () => FirstAidCallout.fromJson(<String, dynamic>{
          'type': 'mild_concern',
          'text': <String, dynamic>{'en': 'x', 'ar': 'س'},
        }),
        throwsA(isA<ContentFormatException>().having(
          (ContentFormatException e) => e.message,
          'message',
          contains('callout.type'),
        )),
      );
    });
  });

  group('FirstAidSection', () {
    test('Given steps and no callouts, Then callouts is omitted', () {
      const FirstAidSection section = FirstAidSection(
        title: LocalizedText(en: 'First aid', ar: 'الإسعافات'),
        steps: <LocalizedText>[LocalizedText(en: 'Sit down', ar: 'اقعد')],
      );
      final Map<String, dynamic> json = section.toJson();
      expect(json.containsKey('callouts'), isFalse);
      expect(json.keys.toList(), <String>['title', 'steps']);

      final FirstAidSection parsed = FirstAidSection.fromJson(json);
      expect(parsed.steps.single.ar, 'اقعد');
      expect(parsed.callouts, isEmpty);
    });

    test('Given no steps, Then steps is still emitted as an empty list', () {
      const FirstAidSection section = FirstAidSection(
        title: LocalizedText(en: 'Notes', ar: 'ملاحظات'),
      );
      expect(section.toJson()['steps'], <dynamic>[]);
    });
  });

  group('FirstAidTopic', () {
    const FirstAidTopic minimal = FirstAidTopic(
      id: 'sprain',
      title: LocalizedText(en: 'Sprain', ar: 'التواء'),
      summary: LocalizedText(en: 'Rest it', ar: 'ريّحه'),
      category: TopicCategory.trauma,
      icon: Icons.personal_injury,
      color: AppColors.accentBlue,
      sections: <FirstAidSection>[
        FirstAidSection(
          title: LocalizedText(en: 'Steps', ar: 'الخطوات'),
          steps: <LocalizedText>[LocalizedText(en: 'Ice it', ar: 'حط تلج')],
        ),
      ],
    );

    test('Given a minimal topic, Then key order is fixed and flags are explicit', () {
      expect(minimal.toJson().keys.toList(), <String>[
        'id',
        'category',
        'icon',
        'color',
        'title',
        'summary',
        'showCallAmbulance',
        'showMetronome',
        'isPaediatric',
        'sections',
      ]);
    });

    test('Given a minimal topic, Then it round-trips field for field', () {
      final FirstAidTopic parsed = FirstAidTopic.fromJson(minimal.toJson());
      expect(parsed.id, minimal.id);
      expect(parsed.title, minimal.title);
      expect(parsed.summary, minimal.summary);
      expect(parsed.category, minimal.category);
      expect(parsed.icon, minimal.icon);
      expect(parsed.color, minimal.color);
      expect(parsed.overview, isNull);
      expect(parsed.showCallAmbulance, isTrue);
      expect(parsed.showMetronome, isFalse);
      expect(parsed.isPaediatric, isFalse);
      expect(parsed.ageVariants, isEmpty);
      expect(parsed.sections.single.steps.single.ar, 'حط تلج');
    });

    test('Given age variants and an overview, Then both survive the trip', () {
      const FirstAidTopic full = FirstAidTopic(
        id: 'cpr',
        title: LocalizedText(en: 'CPR', ar: 'إنعاش'),
        summary: LocalizedText(en: 'Push hard', ar: 'اضغط بقوة'),
        category: TopicCategory.cardiac,
        icon: Icons.monitor_heart,
        color: AppColors.accentRed,
        overview: LocalizedText(en: 'Start now', ar: 'ابدأ حالًا'),
        showMetronome: true,
        sections: <FirstAidSection>[
          FirstAidSection(title: LocalizedText(en: 'Adult', ar: 'بالغ')),
        ],
        ageVariants: <AgeGroup, List<FirstAidSection>>{
          AgeGroup.infant: <FirstAidSection>[
            FirstAidSection(
              title: LocalizedText(en: 'Infant', ar: 'رضيع'),
              steps: <LocalizedText>[LocalizedText(en: 'Two fingers', ar: 'صباعين')],
            ),
          ],
        },
      );
      final Map<String, dynamic> json = full.toJson();
      expect((json['ageVariants'] as Map<String, dynamic>).keys, <String>['infant']);
      expect(json['showMetronome'], isTrue);

      final FirstAidTopic parsed = FirstAidTopic.fromJson(json);
      expect(parsed.ageOptions, <AgeGroup>[AgeGroup.adult, AgeGroup.infant]);
      expect(parsed.sectionsFor(AgeGroup.infant).single.steps.single.ar, 'صباعين');
      expect(parsed.overview!.en, 'Start now');
      expect(parsed.showMetronome, isTrue);
    });

    test('Given an unknown icon name, Then it throws', () {
      final Map<String, dynamic> json = minimal.toJson()
        ..['icon'] = 'no_such_icon';
      expect(
        () => FirstAidTopic.fromJson(json),
        throwsA(isA<ContentFormatException>()),
      );
    });
  });
}
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/content_serialisation_test.dart`
Expected: FAIL — `The method 'toJson' isn't defined for the type 'LocalizedText'`.

- [ ] **Step 3: Add serialisation to `LocalizedText`**

In `lib/core/localized_text.dart`, add inside the class, directly after the constructor:

```dart
  /// Parses `{"en": "…", "ar": "…"}`.
  factory LocalizedText.fromJson(Map<String, dynamic> json) => LocalizedText(
        en: json['en'] as String,
        ar: json['ar'] as String,
      );
```

and after `resolve`:

```dart
  Map<String, dynamic> toJson() => <String, dynamic>{'en': en, 'ar': ar};
```

- [ ] **Step 4: Add serialisation to the topic models**

In `lib/features/conditions/model/first_aid_topic.dart`, add these imports at the top:

```dart
import '../../../core/content/content_registry.dart';
```

Add to `FirstAidCallout`:

```dart
  factory FirstAidCallout.fromJson(Map<String, dynamic> json) => FirstAidCallout(
        type: enumByName(CalloutType.values, json['type'] as String, 'callout.type'),
        text: LocalizedText.fromJson(json['text'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type.name,
        'text': text.toJson(),
      };
```

Add to `FirstAidSection`:

```dart
  factory FirstAidSection.fromJson(Map<String, dynamic> json) => FirstAidSection(
        title: LocalizedText.fromJson(json['title'] as Map<String, dynamic>),
        steps: <LocalizedText>[
          for (final dynamic step in json['steps'] as List<dynamic>? ?? const <dynamic>[])
            LocalizedText.fromJson(step as Map<String, dynamic>),
        ],
        callouts: <FirstAidCallout>[
          for (final dynamic c in json['callouts'] as List<dynamic>? ?? const <dynamic>[])
            FirstAidCallout.fromJson(c as Map<String, dynamic>),
        ],
      );

  /// `steps` is always written, even when empty: a section without steps is
  /// unusual enough that a content editor should see the empty list rather than
  /// wonder whether the field exists.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title.toJson(),
        'steps': <Map<String, dynamic>>[
          for (final LocalizedText step in steps) step.toJson(),
        ],
        if (callouts.isNotEmpty)
          'callouts': <Map<String, dynamic>>[
            for (final FirstAidCallout c in callouts) c.toJson(),
          ],
      };
```

Add to `FirstAidTopic`:

```dart
  factory FirstAidTopic.fromJson(Map<String, dynamic> json) => FirstAidTopic(
        id: json['id'] as String,
        title: LocalizedText.fromJson(json['title'] as Map<String, dynamic>),
        summary: LocalizedText.fromJson(json['summary'] as Map<String, dynamic>),
        category: enumByName(
          TopicCategory.values,
          json['category'] as String,
          'topic.category',
        ),
        icon: iconByName(json['icon'] as String),
        color: colorByName(json['color'] as String),
        overview: json['overview'] == null
            ? null
            : LocalizedText.fromJson(json['overview'] as Map<String, dynamic>),
        sections: _sectionsFromJson(json['sections']),
        showCallAmbulance: json['showCallAmbulance'] as bool? ?? true,
        showMetronome: json['showMetronome'] as bool? ?? false,
        isPaediatric: json['isPaediatric'] as bool? ?? false,
        ageVariants: <AgeGroup, List<FirstAidSection>>{
          for (final MapEntry<String, dynamic> entry
              in (json['ageVariants'] as Map<String, dynamic>? ??
                      const <String, dynamic>{})
                  .entries)
            enumByName(AgeGroup.values, entry.key, 'topic.ageVariants'):
                _sectionsFromJson(entry.value),
        },
      );

  static List<FirstAidSection> _sectionsFromJson(dynamic raw) =>
      <FirstAidSection>[
        for (final dynamic s in raw as List<dynamic>? ?? const <dynamic>[])
          FirstAidSection.fromJson(s as Map<String, dynamic>),
      ];

  /// The three booleans are always written even at their defaults, so somebody
  /// editing a topic can see which switches exist without reading Dart.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'category': category.name,
        'icon': nameOfIcon(icon),
        'color': nameOfColor(color),
        'title': title.toJson(),
        'summary': summary.toJson(),
        if (overview != null) 'overview': overview!.toJson(),
        'showCallAmbulance': showCallAmbulance,
        'showMetronome': showMetronome,
        'isPaediatric': isPaediatric,
        'sections': <Map<String, dynamic>>[
          for (final FirstAidSection s in sections) s.toJson(),
        ],
        if (ageVariants.isNotEmpty)
          'ageVariants': <String, dynamic>{
            for (final MapEntry<AgeGroup, List<FirstAidSection>> e
                in ageVariants.entries)
              e.key.name: <Map<String, dynamic>>[
                for (final FirstAidSection s in e.value) s.toJson(),
              ],
          },
      };
```

Note the key order in `toJson`: `overview` sits between `summary` and the booleans. The test in Step 1 asserts the order for a topic *without* an overview, which is why `overview` does not appear in that expected list.

- [ ] **Step 5: Run the test to verify it passes**

Run: `flutter test test/content_serialisation_test.dart`
Expected: PASS, 9 tests.

- [ ] **Step 6: Commit**

```bash
git add lib/core/localized_text.dart \
        lib/features/conditions/model/first_aid_topic.dart \
        test/content_serialisation_test.dart
git commit -m "feat: serialise LocalizedText and the first-aid topic models"
```

---

## Task 4: Serialise the topic media models

**Files:**
- Modify: `lib/core/media/topic_media.dart`
- Test: `test/content_serialisation_test.dart` (append a group)

**Interfaces:**
- Consumes: `LocalizedText.fromJson`/`toJson` from Task 3.
- Produces: `PhotoCredit`, `TopicImage`, `TopicVideo`, `TopicMedia` each with `fromJson` / `toJson`. `TopicVideo.duration` travels as `durationSeconds` (an `int`).

- [ ] **Step 1: Write the failing test**

Append to `test/content_serialisation_test.dart`, and add `import 'package:help_me/core/media/topic_media.dart';` at the top:

```dart
  group('TopicMedia family', () {
    test('Given a drawing with no credit, Then credit is omitted', () {
      const TopicImage image = TopicImage(
        asset: 'assets/steps/cpr_head_tilt.svg',
        caption: LocalizedText(en: 'Tilt the head', ar: 'ميّل الراس'),
      );
      final Map<String, dynamic> json = image.toJson();
      expect(json.containsKey('credit'), isFalse);

      final TopicImage parsed = TopicImage.fromJson(json);
      expect(parsed.credit, isNull);
      expect(parsed.isDrawing, isTrue);
      expect(parsed.caption.ar, 'ميّل الراس');
    });

    test('Given a photograph, Then the credit survives', () {
      const TopicImage photo = TopicImage(
        asset: 'assets/photos/cpr.jpg',
        caption: LocalizedText(en: 'Hands on the chest', ar: 'الإيدين على الصدر'),
        credit: PhotoCredit(
          photographer: 'Tahir Xəlfəquliyev',
          photographerUrl: 'https://www.pexels.com/@tahir',
          sourceUrl: 'https://www.pexels.com/photo/33862096/',
        ),
      );
      final TopicImage parsed = TopicImage.fromJson(photo.toJson());
      expect(parsed.credit!.photographer, 'Tahir Xəlfəquliyev');
      expect(parsed.credit!.sourceUrl, 'https://www.pexels.com/photo/33862096/');
      expect(parsed.isDrawing, isFalse);
    });

    test('Given a video, Then the duration travels as whole seconds', () {
      const TopicVideo video = TopicVideo(
        youtubeId: 'ye3IJWHaVEo',
        title: LocalizedText(en: 'Hands-only CPR', ar: 'إنعاش باليدين'),
        channel: 'American Heart Association',
        languageCode: 'ar',
        duration: Duration(minutes: 1, seconds: 11),
      );
      expect(video.toJson()['durationSeconds'], 71);

      final TopicVideo parsed = TopicVideo.fromJson(video.toJson());
      expect(parsed.duration, const Duration(seconds: 71));
      expect(parsed.formattedDuration, '1:11');
      expect(parsed.youtubeId, 'ye3IJWHaVEo');
    });

    test('Given empty media, Then both lists are omitted', () {
      expect(const TopicMedia().toJson(), <String, dynamic>{});
      expect(TopicMedia.fromJson(<String, dynamic>{}).isEmpty, isTrue);
    });

    test('Given media with both kinds, Then it round-trips', () {
      const TopicMedia media = TopicMedia(
        images: <TopicImage>[
          TopicImage(
            asset: 'assets/steps/a.svg',
            caption: LocalizedText(en: 'A', ar: 'أ'),
          ),
        ],
        videos: <TopicVideo>[
          TopicVideo(
            youtubeId: 'abc',
            title: LocalizedText(en: 'V', ar: 'ف'),
            channel: 'St John Ambulance',
            languageCode: 'en',
            duration: Duration(seconds: 30),
          ),
        ],
      );
      final TopicMedia parsed = TopicMedia.fromJson(media.toJson());
      expect(parsed.images.single.asset, 'assets/steps/a.svg');
      expect(parsed.videos.single.channel, 'St John Ambulance');
    });
  });
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/content_serialisation_test.dart`
Expected: FAIL — `The method 'toJson' isn't defined for the type 'TopicImage'`.

- [ ] **Step 3: Add serialisation to the media models**

In `lib/core/media/topic_media.dart`, add to `PhotoCredit`:

```dart
  factory PhotoCredit.fromJson(Map<String, dynamic> json) => PhotoCredit(
        photographer: json['photographer'] as String,
        photographerUrl: json['photographerUrl'] as String,
        sourceUrl: json['sourceUrl'] as String,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'photographer': photographer,
        'photographerUrl': photographerUrl,
        'sourceUrl': sourceUrl,
      };
```

To `TopicImage`:

```dart
  factory TopicImage.fromJson(Map<String, dynamic> json) => TopicImage(
        asset: json['asset'] as String,
        caption: LocalizedText.fromJson(json['caption'] as Map<String, dynamic>),
        credit: json['credit'] == null
            ? null
            : PhotoCredit.fromJson(json['credit'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'asset': asset,
        'caption': caption.toJson(),
        if (credit != null) 'credit': credit!.toJson(),
      };
```

To `TopicVideo`:

```dart
  factory TopicVideo.fromJson(Map<String, dynamic> json) => TopicVideo(
        youtubeId: json['youtubeId'] as String,
        title: LocalizedText.fromJson(json['title'] as Map<String, dynamic>),
        channel: json['channel'] as String,
        languageCode: json['languageCode'] as String,
        duration: Duration(seconds: json['durationSeconds'] as int),
      );

  /// Whole seconds, not a structured object — `"durationSeconds": 71` is
  /// something a content editor can read and correct.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'youtubeId': youtubeId,
        'title': title.toJson(),
        'channel': channel,
        'languageCode': languageCode,
        'durationSeconds': duration.inSeconds,
      };
```

To `TopicMedia`:

```dart
  factory TopicMedia.fromJson(Map<String, dynamic> json) => TopicMedia(
        images: <TopicImage>[
          for (final dynamic i in json['images'] as List<dynamic>? ?? const <dynamic>[])
            TopicImage.fromJson(i as Map<String, dynamic>),
        ],
        videos: <TopicVideo>[
          for (final dynamic v in json['videos'] as List<dynamic>? ?? const <dynamic>[])
            TopicVideo.fromJson(v as Map<String, dynamic>),
        ],
        // Absent map and empty list mean different things here — see the
        // constraint above. Do not collapse them.
        imagesByAge: <AgeGroup, List<TopicImage>>{
          for (final MapEntry<String, dynamic> e
              in (json['imagesByAge'] as Map<String, dynamic>? ??
                      const <String, dynamic>{})
                  .entries)
            enumByName(AgeGroup.values, e.key, 'media.imagesByAge'):
                <TopicImage>[
              for (final dynamic i in e.value as List<dynamic>)
                TopicImage.fromJson(i as Map<String, dynamic>),
            ],
        },
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (images.isNotEmpty)
          'images': <Map<String, dynamic>>[
            for (final TopicImage i in images) i.toJson(),
          ],
        if (videos.isNotEmpty)
          'videos': <Map<String, dynamic>>[
            for (final TopicVideo v in videos) v.toJson(),
          ],
        // Emitted whenever the map has entries, and each entry emitted even
        // when its list is empty — the empty list is the instruction "show no
        // picture for this age", not an absence.
        if (imagesByAge.isNotEmpty)
          'imagesByAge': <String, dynamic>{
            for (final MapEntry<AgeGroup, List<TopicImage>> e
                in imagesByAge.entries)
              e.key.name: <Map<String, dynamic>>[
                for (final TopicImage i in e.value) i.toJson(),
              ],
          },
      };

  /// The illustrations to show at [age].
  ///
  /// An explicit by-age entry always wins, **including an empty one**;
  /// everything else falls back to [images]. Replaces the old top-level
  /// `imagesFor(topicId, age)` in `topic_media_data.dart`.
  List<TopicImage> imagesFor(AgeGroup age) => imagesByAge[age] ?? images;
```

`TopicMedia` also gains the field itself:

```dart
  /// Images that replace [images] when a particular age is selected.
  final Map<AgeGroup, List<TopicImage>> imagesByAge;
```

defaulting to `const <AgeGroup, List<TopicImage>>{}` in the constructor.

**Add these cases to the Task 4 test**, on top of the ones already listed:

```dart
    test('Given an empty by-age list, Then it survives a round trip', () {
      const TopicMedia media = TopicMedia(
        images: <TopicImage>[
          TopicImage(
            asset: 'assets/steps/cpr_hand_position.svg',
            caption: LocalizedText(en: 'Hands', ar: 'اليدان'),
          ),
        ],
        imagesByAge: <AgeGroup, List<TopicImage>>{
          AgeGroup.infant: <TopicImage>[],
        },
      );

      final Map<String, dynamic> json = media.toJson();
      expect((json['imagesByAge'] as Map<String, dynamic>)['infant'], isEmpty);

      final TopicMedia parsed = TopicMedia.fromJson(json);
      expect(parsed.imagesByAge.containsKey(AgeGroup.infant), isTrue);
      // The whole point: empty means show none, not fall back to the adult art.
      expect(parsed.imagesFor(AgeGroup.infant), isEmpty);
      expect(parsed.imagesFor(AgeGroup.adult), parsed.images);
      expect(parsed.imagesFor(AgeGroup.child), parsed.images);
    });
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/content_serialisation_test.dart`
Expected: PASS, 14 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/core/media/topic_media.dart test/content_serialisation_test.dart
git commit -m "feat: serialise the topic media models"
```

---

## Task 5: Serialise the learn models

**Files:**
- Modify: `lib/features/learn/model/learn_content.dart`
- Test: `test/content_serialisation_test.dart` (append a group)

**Interfaces:**
- Consumes: `LocalizedText` serialisation (Task 3), `iconByName`/`nameOfIcon`/`colorByName`/`nameOfColor` (Task 2).
- Produces: `DailyTip`, `LessonCard`, `QuizQuestion`, `Lesson`, `LearnBadge` each with `fromJson` / `toJson`.

- [ ] **Step 1: Write the failing test**

Append to `test/content_serialisation_test.dart`, adding `import 'package:help_me/features/learn/model/learn_content.dart';` at the top:

```dart
  group('Learn models', () {
    test('Given a tip with no topic, Then topicId is omitted', () {
      const DailyTip tip = DailyTip(
        id: 'tip_x',
        text: LocalizedText(en: 'Cool a burn', ar: 'برّد الحرق'),
      );
      expect(tip.toJson().containsKey('topicId'), isFalse);
      expect(DailyTip.fromJson(tip.toJson()).topicId, isNull);
    });

    test('Given a tip with a topic, Then topicId survives', () {
      const DailyTip tip = DailyTip(
        id: 'tip_cpr_rate',
        topicId: 'cpr',
        text: LocalizedText(en: '100–120 a minute', ar: '١٠٠–١٢٠ في الدقيقة'),
      );
      final DailyTip parsed = DailyTip.fromJson(tip.toJson());
      expect(parsed.topicId, 'cpr');
      expect(parsed.text.ar, '١٠٠–١٢٠ في الدقيقة');
    });

    test('Given a card with no image, Then image is omitted', () {
      const LessonCard card = LessonCard(
        title: LocalizedText(en: 'Look first', ar: 'بصّ الأول'),
        body: LocalizedText(en: 'Traffic, fire, wires.', ar: 'عربيات، حريقة، أسلاك.'),
      );
      expect(card.toJson().containsKey('image'), isFalse);
      expect(LessonCard.fromJson(card.toJson()).image, isNull);
    });

    test('Given a card with an image, Then the asset path survives', () {
      const LessonCard card = LessonCard(
        title: LocalizedText(en: 'Airway', ar: 'مجرى الهوا'),
        body: LocalizedText(en: 'Tilt the head.', ar: 'ميّل الراس.'),
        image: 'assets/steps/cpr_head_tilt.svg',
      );
      expect(
        LessonCard.fromJson(card.toJson()).image,
        'assets/steps/cpr_head_tilt.svg',
      );
    });

    test('Given a question, Then options and the answer index survive', () {
      const QuizQuestion question = QuizQuestion(
        id: 'q_burn_ice',
        topicId: 'burns',
        prompt: LocalizedText(en: 'Never on a burn?', ar: 'ماينفعش على الحرق؟'),
        options: <LocalizedText>[
          LocalizedText(en: 'Cool water', ar: 'ميّه باردة'),
          LocalizedText(en: 'Ice', ar: 'تلج'),
        ],
        answerIndex: 1,
        explanation: LocalizedText(en: 'Ice injures.', ar: 'التلج بيأذي.'),
      );
      final QuizQuestion parsed = QuizQuestion.fromJson(question.toJson());
      expect(parsed.options.map((LocalizedText o) => o.ar), <String>['ميّه باردة', 'تلج']);
      expect(parsed.answerIndex, 1);
      expect(parsed.isValid, isTrue);
      expect(parsed.explanation.en, 'Ice injures.');
    });

    test('Given a lesson, Then the icon, colour, cards and check survive', () {
      const Lesson lesson = Lesson(
        id: 'lesson_first_minute',
        topicId: 'cpr',
        icon: Icons.timer_outlined,
        color: AppColors.accentRed,
        title: LocalizedText(en: 'The first minute', ar: 'الدقيقة الأولى'),
        summary: LocalizedText(en: 'Sixty seconds.', ar: 'ستين ثانية.'),
        cards: <LessonCard>[
          LessonCard(
            title: LocalizedText(en: 'Look', ar: 'بصّ'),
            body: LocalizedText(en: 'Check for danger.', ar: 'شوف الخطر.'),
          ),
        ],
        check: QuizQuestion(
          id: 'lesson_first_minute_check',
          prompt: LocalizedText(en: 'First thing?', ar: 'أول حاجة؟'),
          options: <LocalizedText>[
            LocalizedText(en: 'Check danger', ar: 'شوف الخطر'),
            LocalizedText(en: 'Start CPR', ar: 'ابدأ إنعاش'),
          ],
          answerIndex: 0,
          explanation: LocalizedText(en: 'Safety first.', ar: 'الأمان الأول.'),
        ),
      );
      final Map<String, dynamic> json = lesson.toJson();
      expect(json['icon'], 'timer_outlined');
      expect(json['color'], 'accentRed');

      final Lesson parsed = Lesson.fromJson(json);
      expect(parsed.icon, Icons.timer_outlined);
      expect(parsed.color, AppColors.accentRed);
      expect(parsed.cards.single.title.ar, 'بصّ');
      expect(parsed.check.answerIndex, 0);
      expect(parsed.topicId, 'cpr');
    });

    test('Given a badge, Then it round-trips', () {
      const LearnBadge badge = LearnBadge(
        id: 'badge_first_lesson',
        icon: Icons.school_outlined,
        name: LocalizedText(en: 'First lesson', ar: 'أول درس'),
        description: LocalizedText(en: 'Finish any lesson.', ar: 'خلّص أي درس.'),
      );
      final LearnBadge parsed = LearnBadge.fromJson(badge.toJson());
      expect(parsed.id, 'badge_first_lesson');
      expect(parsed.icon, Icons.school_outlined);
      expect(parsed.description.ar, 'خلّص أي درس.');
    });
  });
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/content_serialisation_test.dart`
Expected: FAIL — `The method 'toJson' isn't defined for the type 'DailyTip'`.

- [ ] **Step 3: Add serialisation to the learn models**

In `lib/features/learn/model/learn_content.dart`, add this import:

```dart
import '../../../core/content/content_registry.dart';
```

To `DailyTip`:

```dart
  factory DailyTip.fromJson(Map<String, dynamic> json) => DailyTip(
        id: json['id'] as String,
        text: LocalizedText.fromJson(json['text'] as Map<String, dynamic>),
        topicId: json['topicId'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        if (topicId != null) 'topicId': topicId,
        'text': text.toJson(),
      };
```

To `LessonCard`:

```dart
  factory LessonCard.fromJson(Map<String, dynamic> json) => LessonCard(
        title: LocalizedText.fromJson(json['title'] as Map<String, dynamic>),
        body: LocalizedText.fromJson(json['body'] as Map<String, dynamic>),
        image: json['image'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title.toJson(),
        'body': body.toJson(),
        if (image != null) 'image': image,
      };
```

To `QuizQuestion`:

```dart
  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        id: json['id'] as String,
        prompt: LocalizedText.fromJson(json['prompt'] as Map<String, dynamic>),
        options: <LocalizedText>[
          for (final dynamic o in json['options'] as List<dynamic>)
            LocalizedText.fromJson(o as Map<String, dynamic>),
        ],
        answerIndex: json['answerIndex'] as int,
        explanation:
            LocalizedText.fromJson(json['explanation'] as Map<String, dynamic>),
        topicId: json['topicId'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        if (topicId != null) 'topicId': topicId,
        'prompt': prompt.toJson(),
        'options': <Map<String, dynamic>>[
          for (final LocalizedText o in options) o.toJson(),
        ],
        'answerIndex': answerIndex,
        'explanation': explanation.toJson(),
      };
```

To `Lesson`:

```dart
  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'] as String,
        title: LocalizedText.fromJson(json['title'] as Map<String, dynamic>),
        summary: LocalizedText.fromJson(json['summary'] as Map<String, dynamic>),
        icon: iconByName(json['icon'] as String),
        color: colorByName(json['color'] as String),
        cards: <LessonCard>[
          for (final dynamic c in json['cards'] as List<dynamic>)
            LessonCard.fromJson(c as Map<String, dynamic>),
        ],
        check: QuizQuestion.fromJson(json['check'] as Map<String, dynamic>),
        topicId: json['topicId'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        if (topicId != null) 'topicId': topicId,
        'icon': nameOfIcon(icon),
        'color': nameOfColor(color),
        'title': title.toJson(),
        'summary': summary.toJson(),
        'cards': <Map<String, dynamic>>[
          for (final LessonCard c in cards) c.toJson(),
        ],
        'check': check.toJson(),
      };
```

To `LearnBadge`:

```dart
  factory LearnBadge.fromJson(Map<String, dynamic> json) => LearnBadge(
        id: json['id'] as String,
        name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>),
        description:
            LocalizedText.fromJson(json['description'] as Map<String, dynamic>),
        icon: iconByName(json['icon'] as String),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'icon': nameOfIcon(icon),
        'name': name.toJson(),
        'description': description.toJson(),
      };
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/content_serialisation_test.dart`
Expected: PASS, 21 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/features/learn/model/learn_content.dart test/content_serialisation_test.dart
git commit -m "feat: serialise the learn content models"
```

---

## Task 6: Serialise the kit and emergency models

**Files:**
- Modify: `lib/features/health/model/kit_item.dart`
- Modify: `lib/features/emergency/model/emergency_number.dart`
- Test: `test/content_serialisation_test.dart` (append a group)

**Interfaces:**
- Consumes: `LocalizedText` serialisation (Task 3), registry helpers (Task 2), the moved models (Task 1).
- Produces: `KitItem`, `EmergencyNumber`, `EmergencyCountry` each with `fromJson` / `toJson`.

- [ ] **Step 1: Write the failing test**

Append to `test/content_serialisation_test.dart`, adding these imports:

```dart
import 'package:help_me/features/emergency/model/emergency_number.dart';
import 'package:help_me/features/health/model/kit_item.dart';
```

```dart
  group('Kit and emergency models', () {
    test('Given a plain kit item, Then note and perishable are omitted', () {
      const KitItem item = KitItem(
        id: 'scissors',
        name: LocalizedText(en: 'Scissors', ar: 'مقص'),
        section: KitSection.tools,
      );
      final Map<String, dynamic> json = item.toJson();
      expect(json.containsKey('note'), isFalse);
      expect(json.containsKey('perishable'), isFalse);
      expect(json['section'], 'tools');

      final KitItem parsed = KitItem.fromJson(json);
      expect(parsed.section, KitSection.tools);
      expect(parsed.note, isNull);
      expect(parsed.perishable, isFalse);
    });

    test('Given a perishable item with a note, Then both survive', () {
      const KitItem item = KitItem(
        id: 'antiseptic',
        name: LocalizedText(en: 'Antiseptic', ar: 'مطهّر'),
        section: KitSection.medicines,
        note: LocalizedText(en: 'Check the date.', ar: 'شوف التاريخ.'),
        perishable: true,
      );
      final KitItem parsed = KitItem.fromJson(item.toJson());
      expect(parsed.perishable, isTrue);
      expect(parsed.note!.ar, 'شوف التاريخ.');
    });

    test('Given an unknown section, Then it throws naming the field', () {
      expect(
        () => KitItem.fromJson(<String, dynamic>{
          'id': 'x',
          'name': <String, dynamic>{'en': 'x', 'ar': 'س'},
          'section': 'gadgets',
        }),
        throwsA(isA<ContentFormatException>().having(
          (ContentFormatException e) => e.message,
          'message',
          contains('kitItem.section'),
        )),
      );
    });

    test('Given a non-critical number, Then critical is omitted', () {
      const EmergencyNumber number = EmergencyNumber(
        name: LocalizedText(en: 'Traffic police', ar: 'شرطة المرور'),
        number: '128',
        icon: Icons.traffic,
      );
      final Map<String, dynamic> json = number.toJson();
      expect(json.containsKey('critical'), isFalse);
      expect(json['icon'], 'traffic');
      expect(EmergencyNumber.fromJson(json).critical, isFalse);
    });

    test('Given a country, Then the flag, ambulance and list survive', () {
      const EmergencyNumber ambulance = EmergencyNumber(
        name: LocalizedText(en: 'Ambulance', ar: 'الإسعاف'),
        number: '123',
        icon: Icons.emergency,
        critical: true,
      );
      const EmergencyCountry egypt = EmergencyCountry(
        code: 'EG',
        name: LocalizedText(en: 'Egypt', ar: 'مصر'),
        flag: '🇪🇬',
        ambulance: ambulance,
        numbers: <EmergencyNumber>[ambulance],
      );
      final EmergencyCountry parsed = EmergencyCountry.fromJson(egypt.toJson());
      expect(parsed.code, 'EG');
      expect(parsed.flag, '🇪🇬');
      expect(parsed.ambulance.number, '123');
      expect(parsed.ambulance.critical, isTrue);
      expect(parsed.numbers.single.name.ar, 'الإسعاف');
    });
  });
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/content_serialisation_test.dart`
Expected: FAIL — `The method 'toJson' isn't defined for the type 'KitItem'`.

- [ ] **Step 3: Add serialisation to `KitItem`**

In `lib/features/health/model/kit_item.dart`, add the import and the methods:

```dart
import '../../../core/content/content_registry.dart';
```

```dart
  factory KitItem.fromJson(Map<String, dynamic> json) => KitItem(
        id: json['id'] as String,
        name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>),
        section: enumByName(
          KitSection.values,
          json['section'] as String,
          'kitItem.section',
        ),
        note: json['note'] == null
            ? null
            : LocalizedText.fromJson(json['note'] as Map<String, dynamic>),
        perishable: json['perishable'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'section': section.name,
        'name': name.toJson(),
        if (note != null) 'note': note!.toJson(),
        if (perishable) 'perishable': true,
      };
```

- [ ] **Step 4: Add serialisation to the emergency models**

In `lib/features/emergency/model/emergency_number.dart`, add the import and the methods:

```dart
import '../../../core/content/content_registry.dart';
```

To `EmergencyNumber`:

```dart
  factory EmergencyNumber.fromJson(Map<String, dynamic> json) => EmergencyNumber(
        name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>),
        number: json['number'] as String,
        icon: iconByName(json['icon'] as String),
        critical: json['critical'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'number': number,
        'icon': nameOfIcon(icon),
        'name': name.toJson(),
        if (critical) 'critical': true,
      };
```

To `EmergencyCountry`:

```dart
  factory EmergencyCountry.fromJson(Map<String, dynamic> json) => EmergencyCountry(
        code: json['code'] as String,
        name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>),
        flag: json['flag'] as String,
        ambulance:
            EmergencyNumber.fromJson(json['ambulance'] as Map<String, dynamic>),
        numbers: <EmergencyNumber>[
          for (final dynamic n in json['numbers'] as List<dynamic>)
            EmergencyNumber.fromJson(n as Map<String, dynamic>),
        ],
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'code': code,
        'flag': flag,
        'name': name.toJson(),
        'ambulance': ambulance.toJson(),
        'numbers': <Map<String, dynamic>>[
          for (final EmergencyNumber n in numbers) n.toJson(),
        ],
      };
```

Note: `ambulance` is serialised in full rather than as a reference into `numbers`. It duplicates one entry, and that is deliberate — a reference would need an index or an id that content editors would have to keep in sync by hand.

- [ ] **Step 5: Run the test to verify it passes**

Run: `flutter test test/content_serialisation_test.dart`
Expected: PASS, 26 tests.

- [ ] **Step 6: Commit**

```bash
git add lib/features/health/model/kit_item.dart \
        lib/features/emergency/model/emergency_number.dart \
        test/content_serialisation_test.dart
git commit -m "feat: serialise the kit and emergency models"
```

---

## Task 7: `AppContent` and the repository

**Files:**
- Create: `lib/core/content/app_content.dart`
- Create: `lib/core/content/content_repository.dart`
- Create: `lib/core/content/asset_content_repository.dart`
- Test: `test/app_content_test.dart`

**Interfaces:**
- Consumes: every `fromJson` from Tasks 3–6.
- Produces:
  - `class AppContent` with fields `topics`, `media`, `lessons`, `dailyTips`, `quizExtras`, `kit`, `countries`, `badges`; methods `topicById(String) → FirstAidTopic?`, `topicsInCategory(TopicCategory) → List<FirstAidTopic>`, `countryByCode(String?) → EmergencyCountry`, `mediaFor(String) → TopicMedia`; getter `quizBank → List<QuizQuestion>`.
  - `abstract class ContentRepository { Future<AppContent> load(); }`
  - `class AssetContentRepository implements ContentRepository` with `const AssetContentRepository({AssetBundle? bundle})`.

- [ ] **Step 1: Write the failing test**

Create `test/app_content_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/app/theme/app_colors.dart';
import 'package:help_me/core/content/app_content.dart';
import 'package:help_me/core/localized_text.dart';
import 'package:help_me/core/media/topic_media.dart';
import 'package:help_me/features/conditions/model/first_aid_topic.dart';
import 'package:help_me/features/emergency/model/emergency_number.dart';
import 'package:help_me/features/learn/model/learn_content.dart';

FirstAidTopic _topic(String id, TopicCategory category) => FirstAidTopic(
      id: id,
      title: LocalizedText(en: id, ar: id),
      summary: const LocalizedText(en: 's', ar: 'س'),
      category: category,
      icon: Icons.favorite,
      color: AppColors.accentTeal,
      sections: const <FirstAidSection>[],
    );

QuizQuestion _question(String id) => QuizQuestion(
      id: id,
      prompt: LocalizedText(en: id, ar: id),
      options: const <LocalizedText>[
        LocalizedText(en: 'a', ar: 'أ'),
        LocalizedText(en: 'b', ar: 'ب'),
      ],
      answerIndex: 0,
      explanation: const LocalizedText(en: 'e', ar: 'ش'),
    );

EmergencyCountry _country(String code) => EmergencyCountry(
      code: code,
      name: LocalizedText(en: code, ar: code),
      flag: '🏳',
      ambulance: const EmergencyNumber(
        name: LocalizedText(en: 'Ambulance', ar: 'الإسعاف'),
        number: '123',
        icon: Icons.emergency,
        critical: true,
      ),
      numbers: const <EmergencyNumber>[],
    );

AppContent _content() => AppContent(
      topics: <FirstAidTopic>[
        _topic('cpr', TopicCategory.cardiac),
        _topic('burns', TopicCategory.environmental),
      ],
      media: <String, TopicMedia>{
        'cpr': const TopicMedia(
          images: <TopicImage>[
            TopicImage(
              asset: 'assets/steps/a.svg',
              caption: LocalizedText(en: 'A', ar: 'أ'),
            ),
          ],
        ),
      },
      lessons: <Lesson>[
        Lesson(
          id: 'lesson_a',
          title: const LocalizedText(en: 'A', ar: 'أ'),
          summary: const LocalizedText(en: 'a', ar: 'أ'),
          icon: Icons.timer_outlined,
          color: AppColors.accentRed,
          cards: const <LessonCard>[],
          check: _question('check_a'),
        ),
      ],
      dailyTips: const <DailyTip>[
        DailyTip(id: 'tip_a', text: LocalizedText(en: 'A', ar: 'أ')),
      ],
      quizExtras: <QuizQuestion>[_question('extra_a')],
      kit: const <KitItem>[],
      countries: <EmergencyCountry>[_country('EG'), _country('SA')],
      badges: const <LearnBadge>[],
    );

void main() {
  group('AppContent lookups', () {
    test('Given a known id, Then topicById finds it', () {
      expect(_content().topicById('burns')!.id, 'burns');
    });

    test('Given an unknown id, Then topicById returns null', () {
      expect(_content().topicById('nope'), isNull);
    });

    test('Given a category, Then only its topics come back in order', () {
      expect(
        _content().topicsInCategory(TopicCategory.cardiac).map((FirstAidTopic t) => t.id),
        <String>['cpr'],
      );
    });

    test('Given no code, Then countryByCode falls back to the first country', () {
      expect(_content().countryByCode(null).code, 'EG');
    });

    test('Given an unknown code, Then countryByCode falls back too', () {
      expect(_content().countryByCode('ZZ').code, 'EG');
    });

    test('Given a known code, Then countryByCode finds it', () {
      expect(_content().countryByCode('SA').code, 'SA');
    });

    test('Given a topic with no media, Then mediaFor returns empty media', () {
      expect(_content().mediaFor('burns').isEmpty, isTrue);
      expect(_content().mediaFor('cpr').images, hasLength(1));
    });

    test('Given lessons and extras, Then quizBank is checks then extras', () {
      expect(
        _content().quizBank.map((QuizQuestion q) => q.id),
        <String>['check_a', 'extra_a'],
      );
    });
  });
}
```

Add `import 'package:help_me/features/health/model/kit_item.dart';` for `KitItem`.

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/app_content_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:help_me/core/content/app_content.dart'`.

- [ ] **Step 3: Write `AppContent`**

Create `lib/core/content/app_content.dart`:

```dart
import 'package:flutter/foundation.dart';

import '../../features/conditions/model/first_aid_topic.dart';
import '../../features/emergency/model/emergency_number.dart';
import '../../features/health/model/kit_item.dart';
import '../../features/learn/model/learn_content.dart';
import '../media/topic_media.dart';

/// Every piece of medical content the app ships, loaded once.
///
/// One bundle rather than eight independently-loadable collections: partial
/// content is worse than no content in a first-aid app, so the whole thing is
/// present or the load failed.
@immutable
class AppContent {
  AppContent({
    required this.topics,
    required this.media,
    required this.lessons,
    required this.dailyTips,
    required this.quizExtras,
    required this.kit,
    required this.countries,
    required this.badges,
  })  : _topicsById = <String, FirstAidTopic>{
          for (final FirstAidTopic t in topics) t.id: t,
        },
        _countriesByCode = <String, EmergencyCountry>{
          for (final EmergencyCountry c in countries) c.code: c,
        };

  /// In catalogue order — this is the order the home grid renders.
  final List<FirstAidTopic> topics;

  /// Illustrations and videos, keyed by topic id. Coverage may be partial.
  final Map<String, TopicMedia> media;

  final List<Lesson> lessons;
  final List<DailyTip> dailyTips;

  /// Standalone questions, on top of the check question each lesson carries.
  final List<QuizQuestion> quizExtras;

  final List<KitItem> kit;

  /// Supported countries. The first is the default when none is stored.
  final List<EmergencyCountry> countries;

  final List<LearnBadge> badges;

  final Map<String, FirstAidTopic> _topicsById;
  final Map<String, EmergencyCountry> _countriesByCode;

  /// The topic with [id], or null. Indexed at load rather than scanned per call.
  FirstAidTopic? topicById(String id) => _topicsById[id];

  /// Topics belonging to [category], preserving catalogue order.
  List<FirstAidTopic> topicsInCategory(TopicCategory category) =>
      topics.where((FirstAidTopic t) => t.category == category).toList();

  /// The country for [code], defaulting to the first country (Egypt).
  EmergencyCountry countryByCode(String? code) =>
      _countriesByCode[code] ?? countries.first;

  /// Media for [topicId] — empty media rather than null, so callers need no
  /// fallback of their own.
  TopicMedia mediaFor(String topicId) => media[topicId] ?? const TopicMedia();

  /// Every question the quiz can draw from: the lesson checks, then the extras.
  List<QuizQuestion> get quizBank => <QuizQuestion>[
        for (final Lesson lesson in lessons) lesson.check,
        ...quizExtras,
      ];
}
```

- [ ] **Step 4: Write the repository interface and the asset implementation**

Create `lib/core/content/content_repository.dart`:

```dart
import 'app_content.dart';

/// Where medical content comes from.
///
/// One implementation today reads JSON bundled with the app. When content is
/// served over the network, that arrives as a second implementation and nothing
/// above this line changes — with one rule: the bundled assets stay the seed
/// that always succeeds and always opens instantly, and the network is a
/// refresh on top of it. Startup never waits on a connection.
abstract class ContentRepository {
  const ContentRepository();

  /// Loads the whole content bundle.
  ///
  /// Throws [ContentFormatException] if the content names something the app
  /// does not know. For bundled assets that is a build defect, caught in CI by
  /// `test/content_schema_test.dart` before it can ship.
  Future<AppContent> load();
}
```

Create `lib/core/content/asset_content_repository.dart`:

```dart
import 'dart:convert';

import 'package:flutter/services.dart';

import '../../features/conditions/model/first_aid_topic.dart';
import '../../features/emergency/model/emergency_number.dart';
import '../../features/health/model/kit_item.dart';
import '../../features/learn/model/learn_content.dart';
import '../media/topic_media.dart';
import 'app_content.dart';
import 'content_repository.dart';

/// Reads content from the JSON files bundled under `assets/content/`.
class AssetContentRepository implements ContentRepository {
  const AssetContentRepository({this.bundle});

  /// Defaults to [rootBundle]. Tests pass a bundle that reads from disk.
  final AssetBundle? bundle;

  static const String _dir = 'assets/content';

  @override
  Future<AppContent> load() async {
    final AssetBundle b = bundle ?? rootBundle;
    return AppContent(
      topics: <FirstAidTopic>[
        for (final dynamic e in await _list(b, 'topics.json'))
          FirstAidTopic.fromJson(e as Map<String, dynamic>),
      ],
      media: <String, TopicMedia>{
        for (final MapEntry<String, dynamic> e
            in (await _object(b, 'topic_media.json')).entries)
          e.key: TopicMedia.fromJson(e.value as Map<String, dynamic>),
      },
      lessons: <Lesson>[
        for (final dynamic e in await _list(b, 'lessons.json'))
          Lesson.fromJson(e as Map<String, dynamic>),
      ],
      dailyTips: <DailyTip>[
        for (final dynamic e in await _list(b, 'daily_tips.json'))
          DailyTip.fromJson(e as Map<String, dynamic>),
      ],
      quizExtras: <QuizQuestion>[
        for (final dynamic e in await _list(b, 'quiz.json'))
          QuizQuestion.fromJson(e as Map<String, dynamic>),
      ],
      kit: <KitItem>[
        for (final dynamic e in await _list(b, 'kit.json'))
          KitItem.fromJson(e as Map<String, dynamic>),
      ],
      countries: <EmergencyCountry>[
        for (final dynamic e in await _list(b, 'emergency_numbers.json'))
          EmergencyCountry.fromJson(e as Map<String, dynamic>),
      ],
      badges: <LearnBadge>[
        for (final dynamic e in await _list(b, 'badges.json'))
          LearnBadge.fromJson(e as Map<String, dynamic>),
      ],
    );
  }

  Future<List<dynamic>> _list(AssetBundle b, String file) async =>
      jsonDecode(await b.loadString('$_dir/$file')) as List<dynamic>;

  Future<Map<String, dynamic>> _object(AssetBundle b, String file) async =>
      jsonDecode(await b.loadString('$_dir/$file')) as Map<String, dynamic>;
}
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `flutter test test/app_content_test.dart`
Expected: PASS, 8 tests.

The analyzer will warn that `AppContent` is `@immutable` with a non-const constructor — that is expected and fine; the two index maps are built at construction. If `flutter analyze` errors rather than warns, keep `@immutable` and confirm the message is `must_be_immutable`-unrelated; all fields are final so it should be clean.

- [ ] **Step 6: Commit**

```bash
git add lib/core/content/app_content.dart \
        lib/core/content/content_repository.dart \
        lib/core/content/asset_content_repository.dart \
        test/app_content_test.dart
git commit -m "feat: add AppContent and the asset content repository"
```

---

## Task 8: Generate the assets and prove the migration lossless

This is the task that makes the whole change safe. The JSON is produced *from* the Dart data — never typed by hand — and then two comparisons prove the chain `Dart data ≡ JSON file ≡ parsed objects`.

The exporter is a **test**, not a `tool/` script: content models reference `Icons`, which needs `dart:ui`, and `dart run` cannot provide it. `flutter test` can.

**Files:**
- Create: `test/content_export_test.dart` (temporary — deleted in Task 15)
- Create: `test/support/test_content.dart`
- Create: `assets/content/{topics,topic_media,lessons,daily_tips,quiz,kit,emergency_numbers,badges}.json` (generated)
- Modify: `pubspec.yaml`

**Interfaces:**
- Consumes: every `toJson`/`fromJson` (Tasks 3–6), `AssetContentRepository` (Task 7), and the still-present Dart globals `kFirstAidTopics`, `kTopicMedia`, `kLessons`, `kDailyTips`, `kQuizExtras`, `kKitCatalogue`, `kCountries`, `kBadges`.
- Produces: `Future<AppContent> loadTestContent()` in `test/support/test_content.dart` — every later test and task uses this.

- [ ] **Step 1: Declare the asset directory**

In `pubspec.yaml`, add `- assets/content/` to the `assets:` list so it reads:

```yaml
  assets:
    - assets/branding/
    - assets/illustrations/
    - assets/steps/
    - assets/photos/
    - assets/content/
```

- [ ] **Step 2: Write the test-support bundle helper**

Create `test/support/test_content.dart`:

```dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:help_me/core/content/app_content.dart';
import 'package:help_me/core/content/asset_content_repository.dart';

/// Loads the real content assets for a test, reading them straight off disk.
///
/// Tests run with the package root as the working directory, so the asset keys
/// double as file paths. Reading from disk rather than `rootBundle` keeps this
/// usable from plain `test()` bodies that never initialise a test binding.
Future<AppContent> loadTestContent() =>
    const AssetContentRepository(bundle: DiskAssetBundle()).load();

/// An [AssetBundle] backed by the file system.
class DiskAssetBundle extends AssetBundle {
  const DiskAssetBundle();

  @override
  Future<ByteData> load(String key) async {
    final Uint8List bytes = await File(key).readAsBytes();
    return ByteData.sublistView(bytes);
  }

  @override
  Future<T> loadStructuredData<T>(
    String key,
    Future<T> Function(String value) parser,
  ) async =>
      parser(await loadString(key));
}
```

- [ ] **Step 3: Write the export + equivalence test**

Create `test/content_export_test.dart`:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/core/content/app_content.dart';
import 'package:help_me/features/conditions/data/first_aid_data.dart';
import 'package:help_me/features/conditions/data/topic_media_data.dart';
import 'package:help_me/features/conditions/model/first_aid_topic.dart';
import 'package:help_me/features/emergency/data/emergency_numbers.dart';
import 'package:help_me/features/emergency/model/emergency_number.dart';
import 'package:help_me/features/health/data/kit_catalogue.dart';
import 'package:help_me/features/health/model/kit_item.dart';
import 'package:help_me/features/learn/data/daily_tips.dart';
import 'package:help_me/features/learn/data/lessons.dart';
import 'package:help_me/features/learn/data/quiz_bank.dart';
import 'package:help_me/features/learn/model/learn_content.dart';
import 'package:help_me/providers/learn_provider.dart';

import 'support/test_content.dart';

/// The one encoder every content file goes through, so byte comparison is
/// meaningful. Two-space indent, and Dart's `jsonEncode` leaves Arabic
/// unescaped, which is the point of a hand-editable file.
const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

String _encode(Object? value) => '${_encoder.convert(value)}\n';

/// The by-age image overrides for one topic, lifted out of the flat
/// `'topicId:ageName'` keying that `kTopicImagesByAge` uses today.
///
/// Every topic id appearing in that map must also exist in [kTopicMedia];
/// a data test asserts it, so a missing entry here is a bug, not a silent skip.
Map<AgeGroup, List<TopicImage>> _byAgeFor(String topicId) =>
    <AgeGroup, List<TopicImage>>{
      for (final MapEntry<String, List<TopicImage>> e
          in kTopicImagesByAge.entries)
        if (e.key.startsWith('$topicId:'))
          enumByName(AgeGroup.values, e.key.split(':')[1], 'imagesByAge'):
              e.value,
    };

/// The eight files, each with the JSON its Dart source produces today.
Map<String, String> _expected() => <String, String>{
      'topics.json': _encode(<Map<String, dynamic>>[
        for (final FirstAidTopic t in kFirstAidTopics) t.toJson(),
      ]),
      // kTopicImagesByAge is a SEPARATE top-level map in topic_media_data.dart,
      // keyed 'topicId:ageName'. Exporting kTopicMedia alone silently drops it
      // and with it the infant illustrations — merge it in here, or the
      // equivalence proof passes while the app loses a safety behaviour.
      'topic_media.json': _encode(<String, dynamic>{
        for (final MapEntry<String, TopicMedia> e in kTopicMedia.entries)
          e.key: e.value.copyWith(imagesByAge: _byAgeFor(e.key)).toJson(),
      }),
      'lessons.json': _encode(<Map<String, dynamic>>[
        for (final Lesson l in kLessons) l.toJson(),
      ]),
      'daily_tips.json': _encode(<Map<String, dynamic>>[
        for (final DailyTip t in kDailyTips) t.toJson(),
      ]),
      'quiz.json': _encode(<Map<String, dynamic>>[
        for (final QuizQuestion q in kQuizExtras) q.toJson(),
      ]),
      'kit.json': _encode(<Map<String, dynamic>>[
        for (final KitItem i in kKitCatalogue) i.toJson(),
      ]),
      'emergency_numbers.json': _encode(<Map<String, dynamic>>[
        for (final EmergencyCountry c in kCountries) c.toJson(),
      ]),
      'badges.json': _encode(<Map<String, dynamic>>[
        for (final LearnBadge b in kBadges) b.toJson(),
      ]),
    };

void main() {
  final Directory dir = Directory('assets/content');

  test('Given CONTENT_EXPORT=1, Then the asset files are written', () {
    if (Platform.environment['CONTENT_EXPORT'] != '1') {
      markTestSkipped('set CONTENT_EXPORT=1 to regenerate assets/content');
      return;
    }
    dir.createSync(recursive: true);
    _expected().forEach((String name, String json) {
      File('${dir.path}/$name').writeAsStringSync(json);
    });
  });

  group('Export fidelity — the committed files say what the Dart data says', () {
    _expected().forEach((String name, String json) {
      test('Given $name, Then it matches the Dart source byte for byte', () {
        final File file = File('${dir.path}/$name');
        expect(file.existsSync(), isTrue,
            reason: 'run: CONTENT_EXPORT=1 flutter test test/content_export_test.dart');
        expect(file.readAsStringSync(), json);
      });
    });
  });

  group('Parse fidelity — parsing loses nothing', () {
    test('Given every asset, Then re-serialising reproduces the file', () async {
      final AppContent content = await loadTestContent();
      final Map<String, String> reserialised = <String, String>{
        'topics.json': _encode(<Map<String, dynamic>>[
          for (final FirstAidTopic t in content.topics) t.toJson(),
        ]),
        'topic_media.json': _encode(<String, dynamic>{
          for (final MapEntry<String, TopicMedia> e in content.media.entries)
            e.key: e.value.toJson(),
        }),
        'lessons.json': _encode(<Map<String, dynamic>>[
          for (final Lesson l in content.lessons) l.toJson(),
        ]),
        'daily_tips.json': _encode(<Map<String, dynamic>>[
          for (final DailyTip t in content.dailyTips) t.toJson(),
        ]),
        'quiz.json': _encode(<Map<String, dynamic>>[
          for (final QuizQuestion q in content.quizExtras) q.toJson(),
        ]),
        'kit.json': _encode(<Map<String, dynamic>>[
          for (final KitItem i in content.kit) i.toJson(),
        ]),
        'emergency_numbers.json': _encode(<Map<String, dynamic>>[
          for (final EmergencyCountry c in content.countries) c.toJson(),
        ]),
        'badges.json': _encode(<Map<String, dynamic>>[
          for (final LearnBadge b in content.badges) b.toJson(),
        ]),
      };
      reserialised.forEach((String name, String json) {
        expect(json, File('${dir.path}/$name').readAsStringSync(), reason: name);
      });
    });
  });
}
```

- [ ] **Step 4: Run the exporter to generate the assets**

Run: `CONTENT_EXPORT=1 flutter test test/content_export_test.dart`
Expected: the export test passes and the eight files now exist. The fidelity groups may fail on this first run, because the group bodies are built before the export test writes the files.

- [ ] **Step 5: Run again to verify both fidelity checks pass**

Run: `flutter test test/content_export_test.dart`
Expected: PASS — 1 skipped (the export), 8 export-fidelity tests, 1 parse-fidelity test.

This is the proof. Export fidelity says the committed JSON is exactly what the Dart data means. Parse fidelity says reading it back changes nothing. Together: no content was lost or altered.

- [ ] **Step 6: Eyeball one generated file**

Run: `head -40 assets/content/topics.json`
Expected: readable two-space-indented JSON with unescaped Arabic, e.g. `"ar": "بلع اللسان"`. If Arabic appears as `ب...`, the encoder is wrong — fix `_encode` before continuing, because the whole point is a file a human can edit.

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml assets/content test/support/test_content.dart test/content_export_test.dart
git commit -m "feat: generate the content JSON assets from the Dart data"
```

---

## Task 9: Wire content into the provider graph and `main()`

**Files:**
- Create: `lib/providers/content_provider.dart`
- Modify: `lib/main.dart`
- Test: `test/content_provider_test.dart`

**Interfaces:**
- Consumes: `AppContent`, `AssetContentRepository` (Task 7), `loadTestContent()` (Task 8).
- Produces:
  - `final Provider<AppContent> appContentProvider` — throws unless overridden
  - `topicsProvider`, `topicMediaProvider`, `lessonsProvider`, `dailyTipsProvider`, `quizExtrasProvider`, `quizBankProvider`, `kitProvider`, `countriesProvider`, `badgeCatalogueProvider`
  - All synchronous. **`badgeCatalogueProvider`, not `badgesProvider`** — `badgesProvider` already exists in `learn_provider.dart` and returns `List<EarnedBadge>`.

- [ ] **Step 1: Write the failing test**

Create `test/content_provider_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/core/content/app_content.dart';
import 'package:help_me/features/conditions/model/first_aid_topic.dart';
import 'package:help_me/providers/content_provider.dart';

import 'support/test_content.dart';

void main() {
  test('Given no override, Then reading appContentProvider throws', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    expect(() => container.read(appContentProvider), throwsStateError);
  });

  test('Given the real assets, Then every derived provider is populated', () async {
    final AppContent content = await loadTestContent();
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[appContentProvider.overrideWithValue(content)],
    );
    addTearDown(container.dispose);

    expect(container.read(topicsProvider), hasLength(17));
    expect(container.read(lessonsProvider), hasLength(8));
    expect(container.read(dailyTipsProvider), hasLength(47));
    expect(container.read(quizExtrasProvider), hasLength(16));
    expect(container.read(kitProvider), hasLength(25));
    expect(container.read(countriesProvider), hasLength(4));
    expect(container.read(badgeCatalogueProvider), hasLength(5));
    expect(container.read(topicMediaProvider), hasLength(17));
    expect(container.read(quizBankProvider), hasLength(8 + 16));
  });

  test('Given the real assets, Then cpr is present and Egypt is the default', () async {
    final AppContent content = await loadTestContent();
    expect(content.topicById('cpr'), isNotNull);
    expect(content.topicById('does_not_exist'), isNull);
    expect(content.countryByCode(null).code, 'EG');
  });
}
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/content_provider_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:help_me/providers/content_provider.dart'`.

- [ ] **Step 3: Write the providers**

Create `lib/providers/content_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/content/app_content.dart';
import '../core/media/topic_media.dart';
import '../features/conditions/model/first_aid_topic.dart';
import '../features/emergency/model/emergency_number.dart';
import '../features/health/model/kit_item.dart';
import '../features/learn/model/learn_content.dart';

/// The loaded content bundle.
///
/// Overridden in `main()` with the result of an awaited load, the same way
/// [sharedPreferencesProvider] and [healthSnapshotProvider] are. That is what
/// lets every provider below stay synchronous: content is resolved before the
/// widget tree exists, so no screen ever handles an `AsyncValue`.
final Provider<AppContent> appContentProvider = Provider<AppContent>((Ref ref) {
  throw StateError(
    'appContentProvider must be overridden — in main() with '
    'AssetContentRepository().load(), or in tests with loadTestContent()',
  );
});

/// Every topic, in catalogue order.
final Provider<List<FirstAidTopic>> topicsProvider =
    Provider<List<FirstAidTopic>>((Ref ref) => ref.watch(appContentProvider).topics);

/// Illustrations and videos, keyed by topic id.
final Provider<Map<String, TopicMedia>> topicMediaProvider =
    Provider<Map<String, TopicMedia>>((Ref ref) => ref.watch(appContentProvider).media);

final Provider<List<Lesson>> lessonsProvider =
    Provider<List<Lesson>>((Ref ref) => ref.watch(appContentProvider).lessons);

final Provider<List<DailyTip>> dailyTipsProvider =
    Provider<List<DailyTip>>((Ref ref) => ref.watch(appContentProvider).dailyTips);

final Provider<List<QuizQuestion>> quizExtrasProvider =
    Provider<List<QuizQuestion>>((Ref ref) => ref.watch(appContentProvider).quizExtras);

/// Lesson checks followed by the standalone extras.
final Provider<List<QuizQuestion>> quizBankProvider =
    Provider<List<QuizQuestion>>((Ref ref) => ref.watch(appContentProvider).quizBank);

final Provider<List<KitItem>> kitProvider =
    Provider<List<KitItem>>((Ref ref) => ref.watch(appContentProvider).kit);

final Provider<List<EmergencyCountry>> countriesProvider =
    Provider<List<EmergencyCountry>>((Ref ref) => ref.watch(appContentProvider).countries);

/// The badge catalogue as content.
///
/// Named `badgeCatalogueProvider` because `badgesProvider` in
/// `learn_provider.dart` already means "badges with their earned state".
final Provider<List<LearnBadge>> badgeCatalogueProvider =
    Provider<List<LearnBadge>>((Ref ref) => ref.watch(appContentProvider).badges);
```

- [ ] **Step 4: Load content in `main()`**

In `lib/main.dart`, add these imports:

```dart
import 'core/content/app_content.dart';
import 'core/content/asset_content_repository.dart';
import 'providers/content_provider.dart';
```

After the `SharedPreferences` line, add:

```dart
  // Medical content is read once here so every screen can keep reading it
  // synchronously. Unlike health data this has no empty fallback: content that
  // fails to parse is a build defect, caught by test/content_schema_test.dart
  // long before a device sees it, and starting with no first-aid steps would be
  // worse than failing loudly.
  final AppContent content = await const AssetContentRepository().load();
```

And add to the `overrides` list, after `healthSnapshotProvider`:

```dart
        appContentProvider.overrideWithValue(content),
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `flutter test test/content_provider_test.dart`
Expected: PASS, 3 tests.

- [ ] **Step 6: Commit**

```bash
git add lib/providers/content_provider.dart lib/main.dart test/content_provider_test.dart
git commit -m "feat: wire content through Riverpod and load it in main"
```

---

## Task 10: Switch the topic consumers

**Files:**
- Modify: `lib/providers/search_provider.dart:19`
- Modify: `lib/providers/favorites_provider.dart:38`
- Modify: `lib/providers/recent_provider.dart:35`
- Modify: `lib/features/conditions/presentation/condition_detail_screen.dart:203`
- Modify: `lib/features/about/presentation/credits_screen.dart:24,30,36`

**Interfaces:**
- Consumes: `topicsProvider`, `topicMediaProvider`, `appContentProvider` (Task 9).

- [ ] **Step 1: Switch `search_provider.dart`**

Replace the import of `first_aid_data.dart` with `content_provider.dart`, and inside `filteredTopicsProvider` replace `kFirstAidTopics` with a watch:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/conditions/model/first_aid_topic.dart';
import 'content_provider.dart';
```

```dart
final Provider<List<FirstAidTopic>> filteredTopicsProvider =
    Provider<List<FirstAidTopic>>((ref) {
  final String query = ref.watch(searchQueryProvider);
  final TopicCategory? category = ref.watch(selectedCategoryProvider);
  final bool childrenOnly = ref.watch(childrenFilterProvider);
  return ref.watch(topicsProvider).where((FirstAidTopic topic) {
    final bool inCategory = category == null || topic.category == category;
    final bool forChildren = !childrenOnly || topic.concernsChildren;
    return inCategory && forChildren && topic.matches(query);
  }).toList();
});
```

- [ ] **Step 2: Switch `favorites_provider.dart`**

Replace the `first_aid_data.dart` import with `content_provider.dart` and rewrite `favoriteTopicsProvider`:

```dart
final Provider<List<FirstAidTopic>> favoriteTopicsProvider =
    Provider<List<FirstAidTopic>>((ref) {
  final Set<String> ids = ref.watch(favoritesProvider);
  return ref
      .watch(topicsProvider)
      .where((FirstAidTopic t) => ids.contains(t.id))
      .toList();
});
```

- [ ] **Step 3: Switch `recent_provider.dart`**

Replace the `first_aid_data.dart` import with `content_provider.dart` and rewrite `recentTopicsProvider`. `topicById` is now a method on the bundle, so the tear-off becomes a closure:

```dart
final Provider<List<FirstAidTopic>> recentTopicsProvider =
    Provider<List<FirstAidTopic>>((ref) {
  final List<String> ids = ref.watch(recentProvider);
  final AppContent content = ref.watch(appContentProvider);
  return ids
      .map((String id) => content.topicById(id))
      .whereType<FirstAidTopic>()
      .toList();
});
```

Add `import '../core/content/app_content.dart';`.

- [ ] **Step 4: Switch `condition_detail_screen.dart:203`**

Replace `kTopicMedia[topic.id] ?? const TopicMedia()` with the bundle lookup, which already falls back to empty media:

```dart
    final TopicMedia media = ref.watch(appContentProvider).mediaFor(topic.id);
```

Swap the `topic_media_data.dart` import for `../../../providers/content_provider.dart` and `../../../core/content/app_content.dart`. If the enclosing method has no `ref` in scope, it is inside a `ConsumerWidget`/`ConsumerState` build path — confirm with `flutter analyze` and thread `ref` from the nearest build method rather than reading a global.

The **line below it** reads the age-resolved images through the old top-level function:

```dart
    final List<TopicImage> images = imagesFor(topic.id, _age);   // before
    final List<TopicImage> images = media.imagesFor(_age);       // after
```

`media` is the local you just introduced, so this needs no second lookup. Leave the rest of the
gallery block alone — it already renders `images`, and the widget test
`test/age_switch_widget_test.dart: Given choking, When the age changes, Then the illustration
changes with it` proves the wiring end to end. **That test must still pass**; if it goes red, the
by-age overrides were lost in the migration.

- [ ] **Step 5: Switch `credits_screen.dart:24,30,36`**

All three loops iterate `kTopicMedia.values`. Read it once from the provider at the top of the build method and use that local in all three places:

```dart
    final Iterable<TopicMedia> allMedia = ref.watch(topicMediaProvider).values;
```

Then replace each `kTopicMedia.values` with `allMedia`. Swap the `topic_media_data.dart` import for `../../../providers/content_provider.dart`.

- [ ] **Step 6: Verify**

Run: `flutter analyze && flutter test test/content_provider_test.dart test/app_content_test.dart`
Expected: analyzer clean on the five modified files; both tests pass.

`flutter test` as a whole will now fail in the widget tests that build a `ProviderScope` without a content override. That is expected and is Task 13's job. Do not fix those here.

- [ ] **Step 7: Commit**

```bash
git add lib/providers/search_provider.dart lib/providers/favorites_provider.dart \
        lib/providers/recent_provider.dart \
        lib/features/conditions/presentation/condition_detail_screen.dart \
        lib/features/about/presentation/credits_screen.dart
git commit -m "refactor: read topics and media from the content providers"
```

---

## Task 11: Switch the learn consumers and change `tipForDate`

**Files:**
- Modify: `lib/features/learn/data/tip_of_day.dart`
- Modify: `lib/providers/learn_provider.dart:138-144, 210, 215, 225`
- Modify: `lib/features/learn/presentation/learn_screen.dart:41, 45, 188`
- Modify: `lib/features/learn/presentation/lesson_screen.dart:70`

**Interfaces:**
- Consumes: `lessonsProvider`, `dailyTipsProvider`, `quizBankProvider`, `badgeCatalogueProvider`, `appContentProvider` (Task 9).
- Produces: `DailyTip tipForDate(DateTime date, List<DailyTip> tips)` — signature change, one existing caller.

- [ ] **Step 1: Change `tipForDate` to take its list**

Rewrite `lib/features/learn/data/tip_of_day.dart` in full. Note the import of `daily_tips.dart` goes away:

```dart
import '../model/learn_content.dart';

/// The tip for [date] out of [tips] — the same one on every device, with no
/// server deciding it and no history to store.
///
/// Keyed off the day of the year, so a tip cannot come back inside a month while
/// [tips] stays longer than a month. The day is worked out in UTC because local
/// arithmetic across a daylight-saving change can land a day either side.
DailyTip tipForDate(DateTime date, List<DailyTip> tips) {
  final int dayOfYear = DateTime.utc(date.year, date.month, date.day)
      .difference(DateTime.utc(date.year))
      .inDays;
  return tips[dayOfYear % tips.length];
}
```

- [ ] **Step 2: Update `learn_provider.dart`**

Replace the `lessons.dart` and `quiz_bank.dart` imports with `content_provider.dart`, and delete the `kBadges` list (lines 155–198) — it now lives in `assets/content/badges.json`. Keep `EarnedBadge` and `kQuizLength`.

Fix the stale doc comment above `dailyTipProvider` and pass the list in:

```dart
/// The tip for today.
///
/// Day-of-year selection, so the answer is the same on every device and can be
/// worked out for a day that has not arrived yet — which is what the tip
/// notification needs when it is scheduled ahead of time.
final Provider<DailyTip> dailyTipProvider = Provider<DailyTip>(
  (Ref ref) => tipForDate(DateTime.now(), ref.watch(dailyTipsProvider)),
);
```

In `badgesProvider`, read both lists from content:

```dart
final Provider<List<EarnedBadge>> badgesProvider = Provider<List<EarnedBadge>>(
  (Ref ref) {
    final LearnProgress p = ref.watch(learnProvider);
    final int lessonCount = ref.watch(lessonsProvider).length;
    bool earned(String id) => switch (id) {
          'badge_first_lesson' => p.completedLessons.isNotEmpty,
          'badge_week' => p.longestStreak >= 7,
          'badge_month' => p.longestStreak >= 30,
          'badge_all_lessons' => p.completedLessons.length >= lessonCount,
          'badge_perfect_quiz' => p.quizBest >= kQuizLength,
          _ => false,
        };
    return <EarnedBadge>[
      for (final LearnBadge badge in ref.watch(badgeCatalogueProvider))
        EarnedBadge(badge: badge, earned: earned(badge.id)),
    ];
  },
);
```

In `quizRoundProvider`, replace `kQuizBank` with the provider:

```dart
    final List<QuizQuestion> bank = ref.watch(quizBankProvider);
```

The `import 'package:flutter/material.dart';` at the top of `learn_provider.dart` may become unused once `kBadges` and its `Icons` references are gone. Let `flutter analyze` tell you; remove it if it flags it.

- [ ] **Step 3: Update `learn_screen.dart`**

At line 41 and 45 the screen reads `kLessons`. Read it once in the build method:

```dart
    final List<Lesson> lessons = ref.watch(lessonsProvider);
```

then use `lessons.length` at line 41 and `for (final Lesson lesson in lessons)` at line 45.

At line 188, `topicById(tip.topicId!)` becomes a bundle call:

```dart
    final FirstAidTopic? topic = tip.topicId == null
        ? null
        : ref.watch(appContentProvider).topicById(tip.topicId!);
```

Swap the `first_aid_data.dart` and `lessons.dart` imports for `../../../providers/content_provider.dart` and `../../../core/content/app_content.dart`.

- [ ] **Step 4: Update `lesson_screen.dart:70`**

Same change:

```dart
    final FirstAidTopic? topic = lesson.topicId == null
        ? null
        : ref.watch(appContentProvider).topicById(lesson.topicId!);
```

Swap the `first_aid_data.dart` import for the two content imports.

- [ ] **Step 5: Verify**

Run: `flutter analyze`
Expected: clean. Any "unused import" is a leftover — remove it.

Run: `flutter test test/content_provider_test.dart`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/learn/data/tip_of_day.dart lib/providers/learn_provider.dart \
        lib/features/learn/presentation/learn_screen.dart \
        lib/features/learn/presentation/lesson_screen.dart
git commit -m "refactor: read learn content from the content providers"
```

---

## Task 12: Switch the kit and emergency consumers

**Files:**
- Modify: `lib/features/health/presentation/kit_screen.dart:42`
- Modify: `lib/features/emergency/presentation/country_picker.dart:23`
- Modify: `lib/providers/country_provider.dart:13, 17`

**Interfaces:**
- Consumes: `kitProvider`, `countriesProvider`, `appContentProvider` (Task 9).

- [ ] **Step 1: Switch `kit_screen.dart`**

Replace `kKitCatalogue.length` with the provider. The screen already iterates the catalogue elsewhere; read it once in the build method and use the local throughout:

```dart
    final List<KitItem> catalogue = ref.watch(kitProvider);
```

Then `_Progress(done: checked.length, total: catalogue.length)`, and replace every other `kKitCatalogue` in the file with `catalogue`. Swap the `kit_catalogue.dart` import for `../../../providers/content_provider.dart` and `../model/kit_item.dart`.

- [ ] **Step 2: Switch `country_picker.dart`**

```dart
            for (final EmergencyCountry c in ref.watch(countriesProvider))
```

Swap the `emergency_numbers.dart` import for `../../../providers/content_provider.dart` and `../model/emergency_number.dart`.

- [ ] **Step 3: Switch `country_provider.dart`**

`countryByCode` is now a method on the bundle. `CountryNotifier.build` already has `ref`, and `select` uses `ref.read`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/emergency/model/emergency_number.dart';
import 'content_provider.dart';
import 'preferences.dart';

const String _kCountryKey = 'settings.country_code';

/// The user's selected country for emergency numbers (persisted; default Egypt).
class CountryNotifier extends Notifier<EmergencyCountry> {
  @override
  EmergencyCountry build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return ref
        .watch(appContentProvider)
        .countryByCode(prefs.getString(_kCountryKey));
  }

  Future<void> select(String code) async {
    state = ref.read(appContentProvider).countryByCode(code);
    await ref.read(sharedPreferencesProvider).setString(_kCountryKey, state.code);
  }
}

final NotifierProvider<CountryNotifier, EmergencyCountry> countryProvider =
    NotifierProvider<CountryNotifier, EmergencyCountry>(CountryNotifier.new);
```

- [ ] **Step 4: Verify**

Run: `flutter analyze`
Expected: clean. No file under `lib/` should still import a deleted-in-Task-15 data file except the data files themselves.

Confirm with: `grep -rn "data/first_aid_data\|data/topic_media_data\|data/lessons\|data/daily_tips\|data/quiz_bank\|data/kit_catalogue\|data/emergency_numbers" lib --include="*.dart"`
Expected: only matches inside `lib/features/*/data/` itself.

- [ ] **Step 5: Commit**

```bash
git add lib/features/health/presentation/kit_screen.dart \
        lib/features/emergency/presentation/country_picker.dart \
        lib/providers/country_provider.dart
git commit -m "refactor: read kit and emergency content from the content providers"
```

---

## Task 13: Update the existing tests

Ten test files import content data or build a `ProviderScope` that now needs a content override.

**Files:**
- Modify: `test/first_aid_data_test.dart`, `test/age_variants_test.dart`, `test/topic_media_test.dart`, `test/learn_test.dart`, `test/reminders_test.dart`, `test/providers_test.dart`, `test/features_test.dart`, `test/widget_test.dart`, `test/health_test.dart`, `test/health_widget_test.dart`, `test/age_switch_widget_test.dart`, `test/gallery_golden_test.dart`

**Interfaces:**
- Consumes: `loadTestContent()` (Task 8), `appContentProvider` (Task 9).

- [ ] **Step 1: Replace data-global reads with loaded content**

In each test that imports a data file, load the content once in `setUpAll` and use it. Pattern, applied to `test/first_aid_data_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/core/content/app_content.dart';
import 'package:help_me/core/localized_text.dart';
import 'package:help_me/features/conditions/model/first_aid_topic.dart';
import 'package:help_me/features/emergency/model/emergency_number.dart';

import 'support/test_content.dart';

void main() {
  late AppContent content;

  setUpAll(() async {
    content = await loadTestContent();
  });

  // …then in each test: content.topics instead of kFirstAidTopics,
  // content.topicById(…) instead of topicById(…).
}
```

Mechanical substitutions across all of these files:

| Was | Becomes |
| --- | --- |
| `kFirstAidTopics` | `content.topics` |
| `topicById(x)` | `content.topicById(x)` |
| `topicsInCategory(x)` | `content.topicsInCategory(x)` |
| `kTopicMedia` | `content.media` |
| `kLessons` | `content.lessons` |
| `kDailyTips` | `content.dailyTips` |
| `kQuizExtras` | `content.quizExtras` |
| `kQuizBank` | `content.quizBank` |
| `kKitCatalogue` | `content.kit` |
| `kCountries` | `content.countries` |
| `kBadges` | `content.badges` |
| `countryByCode(x)` | `content.countryByCode(x)` |
| `kEmergencyNumbers` | `content.countryByCode('EG').numbers` |
| `kAmbulance` | `content.countryByCode('EG').ambulance` |
| `tipForDate(d)` | `tipForDate(d, content.dailyTips)` |

`kEmergencyNumbers` and `kAmbulance` appear only at `test/first_aid_data_test.dart:71,78,79`.

- [ ] **Step 2: Add the content override to every `ProviderScope` and `ProviderContainer`**

Ten override blocks across eight files (`test/age_switch_widget_test.dart:26`, `test/features_test.dart:19`, `test/learn_test.dart:20,187` and one more, `test/health_test.dart:30`, `test/health_widget_test.dart`, `test/providers_test.dart`, `test/widget_test.dart`, `test/reminders_test.dart`). Each becomes:

```dart
    overrides: <Override>[
      sharedPreferencesProvider.overrideWithValue(prefs),
      appContentProvider.overrideWithValue(content),
    ],
```

with `content` loaded in that file's `setUpAll` as in Step 1. Add `import 'package:help_me/providers/content_provider.dart';` and `import 'support/test_content.dart';`.

- [ ] **Step 3: Run the whole suite**

Run: `flutter test`
Expected: the **two baseline failures only** — `gallery_golden_test.dart: gallery — a topic with drawings only` and `topic_media_test.dart: Given every drawing in assets/steps, Then some topic uses it`. Total passing count is higher than 240 because of the tests Tasks 2–9 added.

If a widget test fails with `StateError: appContentProvider must be overridden`, a `ProviderScope` was missed. Find them with:

`grep -rn "ProviderScope(\|ProviderContainer(" test/*.dart`

- [ ] **Step 4: Commit**

```bash
git add test/
git commit -m "test: load content from assets instead of Dart globals"
```

---

## Task 14: Schema and bundle tests

The CI gate. These are what make "content errors moved from compile time to test time" an acceptable trade.

**Files:**
- Create: `test/content_schema_test.dart`
- Create: `test/content_bundle_test.dart`

**Interfaces:**
- Consumes: `loadTestContent()` (Task 8), `kContentIcons`/`kContentColors` (Task 2).

- [ ] **Step 1: Write the schema test**

Create `test/content_schema_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/core/content/app_content.dart';
import 'package:help_me/core/localized_text.dart';
import 'package:help_me/core/media/topic_media.dart';
import 'package:help_me/features/conditions/model/first_aid_topic.dart';
import 'package:help_me/features/emergency/model/emergency_number.dart';
import 'package:help_me/features/health/model/kit_item.dart';
import 'package:help_me/features/learn/model/learn_content.dart';

import 'support/test_content.dart';

void main() {
  late AppContent content;

  setUpAll(() async {
    content = await loadTestContent();
  });

  group('Content parses', () {
    test('Given the assets, Then every collection is non-empty', () {
      // A silently empty collection is the failure mode a schema test exists
      // to catch: the app would open, look fine, and have no first-aid steps.
      expect(content.topics, isNotEmpty);
      expect(content.lessons, isNotEmpty);
      expect(content.dailyTips, isNotEmpty);
      expect(content.quizExtras, isNotEmpty);
      expect(content.kit, isNotEmpty);
      expect(content.countries, isNotEmpty);
      expect(content.badges, isNotEmpty);
      expect(content.media, isNotEmpty);
    });
  });

  group('Ids are unique', () {
    void expectUnique(Iterable<String> ids, String what) {
      final List<String> list = ids.toList();
      expect(list.toSet().length, list.length, reason: 'duplicate $what id');
    }

    test('Given every collection, Then no id repeats', () {
      expectUnique(content.topics.map((FirstAidTopic t) => t.id), 'topic');
      expectUnique(content.lessons.map((Lesson l) => l.id), 'lesson');
      expectUnique(content.dailyTips.map((DailyTip t) => t.id), 'tip');
      expectUnique(content.quizBank.map((QuizQuestion q) => q.id), 'question');
      expectUnique(content.kit.map((KitItem i) => i.id), 'kit item');
      expectUnique(content.badges.map((LearnBadge b) => b.id), 'badge');
      expectUnique(content.countries.map((EmergencyCountry c) => c.code), 'country');
    });
  });

  group('Every string is bilingual', () {
    test('Given every localised string, Then both languages are filled in', () {
      final List<String> incomplete = <String>[];
      void check(LocalizedText? text, String where) {
        if (text != null && !text.isComplete) incomplete.add(where);
      }

      for (final FirstAidTopic t in content.topics) {
        check(t.title, 'topic ${t.id}.title');
        check(t.summary, 'topic ${t.id}.summary');
        check(t.overview, 'topic ${t.id}.overview');
        for (final FirstAidSection s in <FirstAidSection>[
          ...t.sections,
          ...t.ageVariants.values.expand((List<FirstAidSection> v) => v),
        ]) {
          check(s.title, 'topic ${t.id} section title');
          for (final LocalizedText step in s.steps) {
            check(step, 'topic ${t.id} step');
          }
          for (final FirstAidCallout c in s.callouts) {
            check(c.text, 'topic ${t.id} callout');
          }
        }
      }
      for (final Lesson l in content.lessons) {
        check(l.title, 'lesson ${l.id}.title');
        check(l.summary, 'lesson ${l.id}.summary');
        for (final LessonCard c in l.cards) {
          check(c.title, 'lesson ${l.id} card title');
          check(c.body, 'lesson ${l.id} card body');
        }
      }
      for (final DailyTip t in content.dailyTips) {
        check(t.text, 'tip ${t.id}');
      }
      for (final QuizQuestion q in content.quizBank) {
        check(q.prompt, 'question ${q.id}.prompt');
        check(q.explanation, 'question ${q.id}.explanation');
        for (final LocalizedText o in q.options) {
          check(o, 'question ${q.id} option');
        }
      }
      for (final KitItem i in content.kit) {
        check(i.name, 'kit ${i.id}.name');
        check(i.note, 'kit ${i.id}.note');
      }
      for (final EmergencyCountry c in content.countries) {
        check(c.name, 'country ${c.code}.name');
        for (final EmergencyNumber n in c.numbers) {
          check(n.name, 'country ${c.code} number ${n.number}');
        }
      }
      for (final LearnBadge b in content.badges) {
        check(b.name, 'badge ${b.id}.name');
        check(b.description, 'badge ${b.id}.description');
      }
      for (final MapEntry<String, TopicMedia> e in content.media.entries) {
        for (final TopicImage i in e.value.images) {
          check(i.caption, 'media ${e.key} image caption');
        }
        for (final TopicVideo v in e.value.videos) {
          check(v.title, 'media ${e.key} video title');
        }
      }

      expect(incomplete, isEmpty);
    });
  });

  group('Cross-references resolve', () {
    test('Given every topicId reference, Then the topic exists', () {
      final List<String> dangling = <String>[];
      void check(String? id, String where) {
        if (id != null && content.topicById(id) == null) {
          dangling.add('$where → "$id"');
        }
      }

      for (final Lesson l in content.lessons) {
        check(l.topicId, 'lesson ${l.id}');
      }
      for (final DailyTip t in content.dailyTips) {
        check(t.topicId, 'tip ${t.id}');
      }
      for (final QuizQuestion q in content.quizBank) {
        check(q.topicId, 'question ${q.id}');
      }
      for (final String id in content.media.keys) {
        check(id, 'media entry');
      }

      expect(dangling, isEmpty);
    });
  });

  group('Questions are answerable', () {
    test('Given every question, Then it has options and a valid answer', () {
      for (final QuizQuestion q in content.quizBank) {
        expect(q.isValid, isTrue, reason: 'question ${q.id} is unanswerable');
      }
    });
  });

  group('Age-specific illustrations survived the migration', () {
    test('Given the loaded media, Then the infant choking drawing is there', () {
      final TopicMedia choking = content.media['choking']!;

      expect(
        choking.imagesFor(AgeGroup.infant).map((TopicImage i) => i.asset),
        <String>['assets/steps/choking_infant.svg'],
      );
      expect(
        choking.imagesFor(AgeGroup.adult).map((TopicImage i) => i.asset),
        isNot(contains('assets/steps/choking_infant.svg')),
      );
    });

    test('Given CPR, Then no adult diagram is offered for a child or infant', () {
      final TopicMedia cpr = content.media['cpr']!;

      for (final AgeGroup age in <AgeGroup>[AgeGroup.child, AgeGroup.infant]) {
        expect(cpr.imagesFor(age), isEmpty, reason: age.name);
      }
      expect(cpr.imagesFor(AgeGroup.adult), isNotEmpty);
    });

    test('Given every by-age override, Then its topic and assets exist', () {
      for (final MapEntry<String, TopicMedia> e in content.media.entries) {
        e.value.imagesByAge.forEach((AgeGroup age, List<TopicImage> images) {
          for (final TopicImage image in images) {
            expect(
              File(image.asset).existsSync(),
              isTrue,
              reason: '${e.key}/${age.name}: ${image.asset}',
            );
            expect(image.caption.isComplete, isTrue, reason: image.asset);
          }
        });
      }
    });
  });

  group('Emergency numbers', () {
    test('Given every country, Then its ambulance is in its number list', () {
      for (final EmergencyCountry c in content.countries) {
        expect(
          c.numbers.map((EmergencyNumber n) => n.number),
          contains(c.ambulance.number),
          reason: 'country ${c.code} ambulance is not in its list',
        );
      }
    });

    test('Given no stored country, Then Egypt is the default', () {
      expect(content.countryByCode(null).code, 'EG');
    });
  });
}
```

- [ ] **Step 2: Run it**

Run: `flutter test test/content_schema_test.dart`
Expected: PASS, 8 tests.

If "every country ambulance is in its list" fails, check `assets/content/emergency_numbers.json` for the country named in the reason — the original Dart data satisfies this for all four countries, so a failure means the export dropped something and Task 8's proof should be re-run.

- [ ] **Step 3: Write the bundle test**

Create `test/content_bundle_test.dart`:

```dart
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The eight content files the app loads at startup.
const List<String> _files = <String>[
  'topics.json',
  'topic_media.json',
  'lessons.json',
  'daily_tips.json',
  'quiz.json',
  'kit.json',
  'emergency_numbers.json',
  'badges.json',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Given pubspec.yaml, Then assets/content is declared', () {
    // A JSON file on disk but missing from pubspec passes every File-based test
    // in this suite and then fails on a real device. This is that guard.
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains('- assets/content/'),
    );
  });

  test('Given every content file, Then it exists on disk', () {
    for (final String name in _files) {
      expect(
        File('assets/content/$name').existsSync(),
        isTrue,
        reason: 'assets/content/$name is missing',
      );
    }
  });

  test('Given every content file, Then rootBundle can load it', () async {
    for (final String name in _files) {
      final String contents = await rootBundle.loadString('assets/content/$name');
      expect(contents, isNotEmpty, reason: name);
    }
  });
}
```

- [ ] **Step 4: Run it**

Run: `flutter test test/content_bundle_test.dart`
Expected: PASS, 3 tests.

If the `rootBundle` test fails with `Unable to load asset`, the asset declaration has not been picked up: run `flutter pub get` and re-run. If it still fails, delete that third test and keep the first two — the pubspec declaration plus the on-disk check cover the same failure mode, and a harness limitation is not worth blocking on. Say so in the commit message if you do.

- [ ] **Step 5: Commit**

```bash
git add test/content_schema_test.dart test/content_bundle_test.dart
git commit -m "test: gate content integrity and asset declaration in CI"
```

---

## Task 15: Delete the Dart content and verify nothing moved

**Files:**
- Delete: `lib/features/conditions/data/topics_original.dart`, `topics_extended.dart`, `first_aid_data.dart`, `topic_media_data.dart`
- Delete: `lib/features/learn/data/lessons.dart`, `daily_tips.dart`, `quiz_bank.dart`
- Delete: `lib/features/health/data/kit_catalogue.dart`
- Delete: `lib/features/emergency/data/emergency_numbers.dart`
- Delete: `test/content_export_test.dart`
- Modify: `lib/features/learn/data/tip_of_day.dart` → move to `lib/features/learn/model/tip_of_day.dart`

- [ ] **Step 1: Confirm nothing still imports the data files**

Run:

```bash
grep -rn "data/first_aid_data\|data/topics_original\|data/topics_extended\|data/topic_media_data\|data/lessons\|data/daily_tips\|data/quiz_bank\|data/kit_catalogue\|data/emergency_numbers" lib test --include="*.dart"
```

Expected: only `test/content_export_test.dart` (about to go) and the data files' own imports of each other. If anything under `lib/` or another test appears, fix it before deleting.

- [ ] **Step 2: Move `tip_of_day.dart` out of the emptying data directory**

`tip_of_day.dart` holds selection logic, not content, and `lib/features/learn/data/` is about to contain nothing else. Move it to `lib/features/learn/model/tip_of_day.dart` and update its two importers (`lib/providers/learn_provider.dart` and whichever tests import it) to `../features/learn/model/tip_of_day.dart`.

- [ ] **Step 3: Delete**

```bash
git rm lib/features/conditions/data/topics_original.dart \
       lib/features/conditions/data/topics_extended.dart \
       lib/features/conditions/data/first_aid_data.dart \
       lib/features/conditions/data/topic_media_data.dart \
       lib/features/learn/data/lessons.dart \
       lib/features/learn/data/daily_tips.dart \
       lib/features/learn/data/quiz_bank.dart \
       lib/features/health/data/kit_catalogue.dart \
       lib/features/emergency/data/emergency_numbers.dart \
       test/content_export_test.dart
```

The export test goes with them: it exists only to compare the two representations, and one side is gone. Its proof is in the git history where it belongs.

- [ ] **Step 4: Analyze**

Run: `flutter analyze`
Expected: clean, zero issues.

- [ ] **Step 5: Run the whole suite**

Run: `flutter test`
Expected: **exactly the two baseline failures** and nothing else:
- `test/gallery_golden_test.dart: gallery — a topic with drawings only`
- `test/topic_media_test.dart: Topic media catalogue Given every drawing in assets/steps, Then some topic uses it`

Any third failure is a regression from this work. Do not proceed until the count is two.

- [ ] **Step 6: Confirm the UI did not move**

The golden tests are the check that content survived the round trip visually, not just structurally.

Run: `flutter test test/gallery_golden_test.dart test/nav_bar_golden_test.dart`
Expected: the one known gallery failure at ~0.12% and nothing new. **Do not run with `--update-goldens`.** A golden that needs updating means the content changed, which is exactly the outcome this plan exists to prevent — investigate instead.

- [ ] **Step 7: Verify the app actually starts**

Run: `flutter run -d macos` (or any available device; `flutter devices` to list)
Expected: the app opens to the home screen with the condition grid populated. This is the one check the test suite cannot make — `main()`'s await of the real `rootBundle` only happens on a device.

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "refactor: delete the Dart content data now that JSON is the source"
```

- [ ] **Step 9: Confirm the deliverable**

Open `assets/content/topics.json`, change one Arabic word in a summary, run `flutter test test/content_schema_test.dart`, and confirm it still passes. Then revert the edit.

This is the whole point of the plan: content edited without opening a Dart file, with the integrity gate still standing behind it.

---

## Self-Review

**Spec coverage.** Every spec section maps to a task: content inventory → Tasks 8, 15; JSON shape → Tasks 3–6; icon/colour registry → Task 2; loading layer → Task 7; consumers stay synchronous → Tasks 9–12; the seed-then-refresh rule → documented in `content_repository.dart` (Task 7 Step 4); bundled-asset failure behaviour → Task 9 Step 4 comment plus the Task 14 gate; validation and tests → Task 14; models out of data files → Task 1; `tipForDate` signature → Task 11; migration order and the equivalence proof → Task 8, with deletion in Task 15.

**Two gaps found and closed while reviewing:**
- The spec did not mention `tip_of_day.dart` being stranded in an otherwise-empty `learn/data/` directory. Added as Task 15 Step 2.
- The spec's failure-handling section had no verification that `main()`'s real `rootBundle` load works — every test uses `DiskAssetBundle`. Added as Task 15 Step 7.

**Naming consistency check.** `badgeCatalogueProvider` (new content) is distinct from the pre-existing `badgesProvider` (earned state) everywhere it appears — Task 9 defines it, Task 11 consumes it. `loadTestContent()` is defined in Task 8 and used in Tasks 9, 13, 14 under that exact name. `DiskAssetBundle` is public, not `_DiskBundle`, because Task 13's tests import it from another file.
