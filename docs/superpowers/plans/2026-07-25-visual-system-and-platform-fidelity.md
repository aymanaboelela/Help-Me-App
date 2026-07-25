# Visual System & Platform Fidelity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the app's sprayed-red, single-step-dark, one-font visual system with a triage-semantic palette, a five-rung dark elevation ladder, a real type pairing, honest skeletons, and per-platform behaviour — without restructuring a single screen.

**Architecture:** Almost all of the work lands in `lib/app/theme/`, which is why it can be broad without being risky. Tokens change first and screens inherit them; two new leaf widgets (`AppSkeleton`, `TriageRule`) are pure and provider-free; platform branching goes through the existing `context.isCupertino` extension so tests can drive both sides. Golden rendering is the acceptance gate at every step, not a final check.

**Tech Stack:** Flutter (Material 3), Riverpod, `flutter_test` golden tests, Barlow Semi Condensed + IBM Plex Sans + Cairo (bundled static TTFs).

**Spec:** [`2026-07-25-visual-system-and-platform-fidelity-design.md`](../specs/2026-07-25-visual-system-and-platform-fidelity-design.md)

## Global Constraints

- **Baseline: 179 tests pass** (`flutter test`). No task may land with fewer passing. Task 1 adds goldens; that count only grows.
- **Never regress to `Platform.isIOS`.** All platform branching keys off `ThemeData.platform` via `context.isCupertino` from `lib/core/platform/adaptive.dart`, so tests can drive both branches with `theme.copyWith(platform: ...)`.
- **`withValues(alpha:)`, never `withOpacity`.** The codebase has already migrated.
- **Explicit types and trailing commas.** The codebase writes `final Color x =`, `<Widget>[...]`, `<Color>[...]`. `flutter analyze` must be clean — `analysis_options.yaml` enforces trailing commas.
- **Offline is non-negotiable.** Every font is a bundled asset. No network calls, no `google_fonts` package.
- **No new runtime dependencies.** Only font assets are added to `pubspec.yaml`.
- **No new permissions.** `AndroidManifest.xml` gains one activity attribute and nothing else.
- **No screen restructuring.** Information architecture, navigation, and copy are unchanged. The only layout change permitted is the emergency-number card hierarchy (Task 11).
- **Every visual change is verified in RTL too.** Arabic is the app's default locale; a change that only looks right in English is not done.
- **Reduced motion is respected.** Any new animation checks `MediaQuery.disableAnimationsOf(context)`.

### Colour tokens (exact, measured — copy verbatim)

```
                 dark        light
bg               #0C0F13     #F4F6F8
surface          #14191F     #FFFFFF
raised           #1C232B     #EDF1F5
high             #252E38     #FFFFFF
hairline         #2C353F     #DDE3EA
ink              #E8EDF2     #10151A
muted            #96A3B1     #56626F

immediate        #FF7A85     #CB2635
urgent           #F0B357     #A05E00
safe             #4FC79B     #0F7857
structural       #96B2C9     #3A5570

sosGradientStart #A8323E     #C8404F
sosGradientEnd   #74121A     #8E1620
callPillFill     #E9EEF4     (light mode keeps Colors.white)
callPillText     #B3202E     (light mode keeps sosGradientEnd)
```

Every one of these was measured against WCAG 2.1 in the spec. Do not "improve" a value by eye — Task 2's test will reject it.

### Radius scale (replaces the current 10/16/22/24/999 sprawl)

```
xs    8   icon tiles
sm   12   buttons, inputs
md   18   cards
lg   28   sheets, nav bar
pill      chips only
```

---

## File Structure

| File | Responsibility |
|---|---|
| `lib/app/theme/app_colors.dart` | **modify** — the two ladders, the four triage roles, the ten accents' dark variants, and the accent resolver |
| `lib/app/theme/app_theme.dart` | **modify** — `primary: structural`, every container role explicit, the radius scale, per-platform transitions and scroll behaviour |
| `lib/app/theme/app_typography.dart` | **modify** — locale-driven family selection and the seven-step scale |
| `lib/core/widgets/app_skeleton.dart` | **new** — the breathing-pulse placeholder primitive |
| `lib/core/widgets/triage_rule.dart` | **new** — the 3px leading severity bar |
| `lib/core/widgets/fading_edge_row.dart` | **new** — direction-aware trailing fade for the chip row |
| `lib/core/platform/adaptive.dart` | **modify** — adaptive slider/checkbox helpers, and the haptics split extracted so call sites share it |
| `lib/app/app.dart` | **modify** — root `AnnotatedRegion<SystemUiOverlayStyle>`, edge-to-edge setup |
| `test/contrast_test.dart` | **new** — the WCAG gate on the palette |
| `test/screens_golden_test.dart` | **new** — the six-screen harness in light, dark, and dark-RTL |
| `test/skeleton_golden_test.dart` | **new** — each skeleton in its loading state |
| `test/adaptive_platform_test.dart` | **new** — both platform branches through the same call sites |

Consumers touched to adopt tokens, with no logic change: `sos_banner.dart`, `topic_card.dart`, `callout_box.dart`, `app_nav_bar.dart`, `topic_gallery.dart`, `video_player_screen.dart`, `emergency_screen.dart`, `home_screen.dart`, `kit_screen.dart`, `learn_screen.dart`, `question_view.dart`, `emergency_timer_sheet.dart`, `cpr_metronome_screen.dart`.

## Phasing

Four phases, each independently shippable and reviewable. Stop and look at goldens at the end of each.

- **Phase 1 — Foundation** (Tasks 1–6): goldens harness, contrast gate, tokens, theme wiring, dark fixes.
- **Phase 2 — Type** (Tasks 7–8): fonts and the scale.
- **Phase 3 — Skeletons** (Tasks 9–10).
- **Phase 4 — Polish & platform** (Tasks 11–15).

---

## Task 1: Golden harness (baseline)

Establishes the acceptance mechanism before anything changes, so every later task has a before/after. The goldens committed here capture the **current, unimproved** look on purpose — that is the baseline.

**Files:**
- Create: `test/screens_golden_test.dart`
- Create: `test/goldens/screens/*.png` (generated)

**Interfaces:**
- Consumes: nothing.
- Produces: `pumpScreen(WidgetTester tester, Widget child, String name, {required ThemeData theme, Locale locale, TargetPlatform platform})` and `loadAppFonts()`, both used by Tasks 9, 10 and 15. `loadAppFonts()` must load Cairo, MaterialIcons, and (from Task 7 onward) Barlow Semi Condensed and IBM Plex Sans.

- [ ] **Step 1: Write the harness**

Create `test/screens_golden_test.dart`. Note `'settings.disclaimer_accepted': true` — without it the disclaimer sheet covers every screen. The font path resolution tries the SDK-relative location first and falls back to the local cache.

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/app/root_scaffold.dart';
import 'package:help_me/app/theme/app_theme.dart';
import 'package:help_me/features/conditions/data/first_aid_data.dart';
import 'package:help_me/features/conditions/model/first_aid_topic.dart';
import 'package:help_me/features/conditions/presentation/condition_detail_screen.dart';
import 'package:help_me/features/emergency/presentation/emergency_screen.dart';
import 'package:help_me/features/health/presentation/health_screen.dart';
import 'package:help_me/features/learn/presentation/learn_screen.dart';
import 'package:help_me/features/settings/presentation/settings_screen.dart';
import 'package:help_me/l10n/app_localizations.dart';
import 'package:help_me/providers/health_provider.dart';
import 'package:help_me/providers/preferences.dart';
import 'package:help_me/services/reminder_service.dart';
import 'package:help_me/services/secure_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Loads the real text and icon fonts so a golden shows what a user would see
/// rather than a grid of tofu boxes.
Future<void> loadAppFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final FontLoader loader = FontLoader(family);
    bool found = false;
    for (final String path in paths) {
      final File file = File(path);
      if (!file.existsSync()) continue;
      found = true;
      loader.addFont(
        file.readAsBytes().then((Uint8List b) => ByteData.view(b.buffer)),
      );
    }
    if (!found) {
      throw StateError('No font file found for $family in: ${paths.join(", ")}');
    }
    await loader.load();
  }

  final String sdk = File(Platform.resolvedExecutable).parent.parent.path;
  await load('MaterialIcons', <String>[
    '$sdk/artifacts/material_fonts/MaterialIcons-Regular.otf',
    '${Platform.environment['HOME']}/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]);
  await load('Cairo', <String>[
    'assets/fonts/Cairo-Regular.ttf',
    'assets/fonts/Cairo-Medium.ttf',
    'assets/fonts/Cairo-SemiBold.ttf',
    'assets/fonts/Cairo-Bold.ttf',
    'assets/fonts/Cairo-ExtraBold.ttf',
  ]);
}

/// Renders [child] inside a fully-overridden ProviderScope and writes it to
/// `goldens/screens/<name>.png`. Regenerate with `flutter test --update-goldens`.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget child,
  String name, {
  required ThemeData theme,
  Locale locale = const Locale('en'),
  TargetPlatform platform = TargetPlatform.android,
}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues(<String, Object>{
    'settings.disclaimer_accepted': true,
  });
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        sharedPreferencesProvider.overrideWithValue(prefs),
        secureStoreProvider.overrideWithValue(InMemorySecureStore()),
        remindersProvider.overrideWithValue(FakeReminders()),
        healthSnapshotProvider.overrideWithValue(const HealthSnapshot()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: theme.copyWith(platform: platform),
        home: child,
      ),
    ),
  );
  // Two pumps rather than pumpAndSettle: the nav bar and gallery hold
  // indefinite implicit animations that pumpAndSettle would wait on forever.
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(seconds: 1));

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/screens/$name.png'),
  );
}

void main() {
  setUpAll(loadAppFonts);

  final FirstAidTopic topic = kFirstAidTopics.first;

  final List<(String, Widget)> screens = <(String, Widget)>[
    ('home', const RootScaffold()),
    ('emergency', const EmergencyScreen()),
    ('learn', const LearnScreen()),
    ('health', const HealthScreen()),
    ('settings', const SettingsScreen()),
    ('detail', ConditionDetailScreen(topic: topic)),
  ];

  for (final (String name, Widget screen) in screens) {
    testWidgets('$name — light', (WidgetTester tester) async {
      await pumpScreen(tester, screen, '${name}_light', theme: AppTheme.light);
    });

    testWidgets('$name — dark', (WidgetTester tester) async {
      await pumpScreen(tester, screen, '${name}_dark', theme: AppTheme.dark);
    });

    testWidgets('$name — dark RTL', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        screen,
        '${name}_dark_ar',
        theme: AppTheme.dark,
        locale: const Locale('ar'),
      );
    });
  }
}
```

- [ ] **Step 2: Generate the baseline goldens**

Run: `flutter test test/screens_golden_test.dart --update-goldens`
Expected: `+18: All tests passed!` and 18 files in `test/goldens/screens/`.

- [ ] **Step 3: Verify they are stable (not flaky)**

Run: `flutter test test/screens_golden_test.dart`
Expected: PASS with no diffs. If any test fails here, the pump sequence is non-deterministic — find the animation and pump past it rather than loosening the tolerance.

- [ ] **Step 4: Look at the images**

Open `test/goldens/screens/home_dark.png`, `settings_dark.png`, and `detail_dark.png`. Confirm: icons render as glyphs (not empty squares), no disclaimer sheet covers the screen, and Arabic renders in the `_dark_ar` variants. **If icons are squares, `loadAppFonts` did not find MaterialIcons — fix the path before continuing.** Every later task depends on these being readable.

- [ ] **Step 5: Commit**

```bash
git add test/screens_golden_test.dart test/goldens/screens
git commit -m "Add a golden harness for the six main screens

Baseline images of the current look, so the visual system pass that
follows can be reviewed as a diff rather than taken on trust."
```

---

## Task 2: The contrast gate

Written before the tokens exist, so it fails first. This test is what caught four real failures in the design phase, including one shipping today.

**Files:**
- Create: `test/contrast_test.dart`
- Modify: `lib/app/theme/app_colors.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `AppColors.contrastRatio(Color a, Color b)` — a static returning the WCAG 2.1 ratio, used by this test and nothing else in production code. It lives in `app_colors.dart` rather than the test so a future palette edit cannot avoid it.

- [ ] **Step 1: Write the failing test**

Create `test/contrast_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/app/theme/app_colors.dart';

/// The palette carries triage meaning, so it has to stay legible everywhere it
/// is allowed to appear — not merely on the one background it was picked
/// against. Every (foreground, surface) pair the design permits is checked.
void main() {
  const double aa = 4.5;

  test('contrastRatio matches known WCAG values', () {
    expect(
      AppColors.contrastRatio(const Color(0xFFFFFFFF), const Color(0xFF000000)),
      closeTo(21.0, 0.01),
    );
    expect(
      AppColors.contrastRatio(const Color(0xFF777777), const Color(0xFFFFFFFF)),
      closeTo(4.48, 0.01),
    );
  });

  for (final (String mode, AppSurfaces s, AppSemanticColors sem) in <(String, AppSurfaces, AppSemanticColors)>[
    ('dark', AppSurfaces.dark, AppSemanticColors.dark),
    ('light', AppSurfaces.light, AppSemanticColors.light),
  ]) {
    final Map<String, Color> backgrounds = <String, Color>{
      'bg': s.bg,
      'surface': s.surface,
      'raised': s.raised,
      'high': s.high,
    };
    final Map<String, Color> foregrounds = <String, Color>{
      'ink': s.ink,
      'muted': s.muted,
      'immediate': sem.immediate,
      'urgent': sem.urgent,
      'safe': sem.safe,
      'structural': sem.structural,
    };

    backgrounds.forEach((String bgName, Color bg) {
      foregrounds.forEach((String fgName, Color fg) {
        test('$mode: $fgName on $bgName clears AA', () {
          expect(
            AppColors.contrastRatio(fg, bg),
            greaterThanOrEqualTo(aa),
            reason: '$mode $fgName on $bgName is too low',
          );
        });
      });
    });

    test('$mode: white on both ends of the SOS gradient clears AA', () {
      // The shipping palette failed this at 2.74:1 on the light end.
      expect(
        AppColors.contrastRatio(Colors.white, sem.sosGradientStart),
        greaterThanOrEqualTo(aa),
      );
      expect(
        AppColors.contrastRatio(Colors.white, sem.sosGradientEnd),
        greaterThanOrEqualTo(aa),
      );
    });
  }

  test('dark: the call pill text clears AA on its own fill', () {
    expect(
      AppColors.contrastRatio(
        AppSemanticColors.dark.callPillText,
        AppSemanticColors.dark.callPillFill,
      ),
      greaterThanOrEqualTo(4.5),
    );
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

Run: `flutter test test/contrast_test.dart`
Expected: FAIL — `AppSurfaces` is undefined, `contrastRatio` is undefined, `immediate`/`urgent`/`safe`/`structural`/`callPillFill`/`callPillText` are not members of `AppSemanticColors`.

- [ ] **Step 3: Add `contrastRatio` to `app_colors.dart`**

Append to the `AppColors` class body:

```dart
  /// The WCAG 2.1 contrast ratio between two opaque colours, 1.0–21.0.
  ///
  /// Lives here rather than in the test so that a future palette edit cannot
  /// quietly skip the check that guards it.
  static double contrastRatio(Color a, Color b) {
    final double la = _relativeLuminance(a);
    final double lb = _relativeLuminance(b);
    final double hi = la > lb ? la : lb;
    final double lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }

  static double _relativeLuminance(Color c) {
    double channel(double v) =>
        v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
  }
```

Add `import 'dart:math' as math;` as the first import of the file.

> `Color.r`/`.g`/`.b` are the wide-gamut doubles (0.0–1.0) that replaced `.red`/`.green`/`.blue`. They are already correct for this formula — do not divide by 255.

- [ ] **Step 4: Run again**

Run: `flutter test test/contrast_test.dart --plain-name "contrastRatio matches known WCAG values"`
Expected: PASS. The rest still fail — `AppSurfaces` arrives in Task 3.

- [ ] **Step 5: Commit**

```bash
git add lib/app/theme/app_colors.dart test/contrast_test.dart
git commit -m "Add a WCAG contrast gate over the palette

Checks every (foreground, surface) pair the design permits, not just the
one background each colour was picked against. The shipping SOS gradient
puts white text at 2.74:1; this is the test that catches that class of bug."
```

---

## Task 3: The surface ladders and triage roles

**Files:**
- Modify: `lib/app/theme/app_colors.dart`
- Test: `test/contrast_test.dart` (already written)

**Interfaces:**
- Consumes: `AppColors.contrastRatio` (Task 2).
- Produces:
  - `class AppSurfaces` with `const AppSurfaces.dark` / `.light` statics and fields `bg`, `surface`, `raised`, `high`, `hairline`, `ink`, `muted` — all `Color`.
  - `AppSemanticColors` fields: `immediate`, `onImmediate`, `urgent`, `safe`, `structural`, `muted`, `hairline`, `sosGradientStart`, `sosGradientEnd`, `callPillFill`, `callPillText`. The old `danger`, `onDanger`, `warning`, `success`, `info`, `cardBorder` are **removed**.
  - `AppColors.darkAccent(Color lightAccent)` → `Color`, and `BuildContext.accent(Color)` → `Color`, resolving a topic's baked-in light accent to its dark-mode variant.

- [ ] **Step 1: Replace the palette section of `app_colors.dart`**

Replace the `// ---- Light scheme ----` and `// ---- Dark scheme ----` blocks with a single `AppSurfaces` class, and add the accent dark variants. The ten light accents keep their current values so the topic data files never change.

```dart
/// One rung-by-rung surface ladder for a brightness.
///
/// Dark mode needs more than the one surface step the app used to have: with
/// background and surface only 6% apart, cards separated by nothing but a
/// hairline and the whole screen read as a single black sheet. Five rungs, and
/// a hairline *lighter* than the surface it borders, which is correct for dark
/// and the reverse of what a light theme wants.
@immutable
class AppSurfaces {
  const AppSurfaces({
    required this.bg,
    required this.surface,
    required this.raised,
    required this.high,
    required this.hairline,
    required this.ink,
    required this.muted,
  });

  /// Behind everything.
  final Color bg;
  /// Cards.
  final Color surface;
  /// Inputs, nested content, sheets.
  final Color raised;
  /// Dialogs, menus, the selected nav pill.
  final Color high;
  final Color hairline;
  final Color ink;
  final Color muted;

  static const AppSurfaces dark = AppSurfaces(
    bg: Color(0xFF0C0F13),
    surface: Color(0xFF14191F),
    raised: Color(0xFF1C232B),
    high: Color(0xFF252E38),
    hairline: Color(0xFF2C353F),
    ink: Color(0xFFE8EDF2),
    muted: Color(0xFF96A3B1),
  );

  static const AppSurfaces light = AppSurfaces(
    bg: Color(0xFFF4F6F8),
    surface: Color(0xFFFFFFFF),
    raised: Color(0xFFEDF1F5),
    high: Color(0xFFFFFFFF),
    hairline: Color(0xFFDDE3EA),
    ink: Color(0xFF10151A),
    muted: Color(0xFF56626F),
  );
}
```

Inside `AppColors`, keep the brand and the ten light accents, and add the dark variants plus the resolver:

```dart
  // ---- Category accents, dark-mode variants ----
  //
  // A topic's colour is baked into its data as a light-mode constant. Rather
  // than edit 17 data entries, the theme resolves the pair here. Each dark
  // variant is the same hue lifted in lightness and dropped in saturation so
  // it reads as itself against #14191F instead of going muddy.
  static const Color accentTealDark = Color(0xFF3FC9B4);
  static const Color accentRedDark = Color(0xFFFF7A85);
  static const Color accentCrimsonDark = Color(0xFFFF6B6B);
  static const Color accentOrangeDark = Color(0xFFFF9A5C);
  static const Color accentAmberDark = Color(0xFFF0B357);
  static const Color accentBlueDark = Color(0xFF7BA9FF);
  static const Color accentIndigoDark = Color(0xFF9A9AF0);
  static const Color accentPurpleDark = Color(0xFFC08AD8);
  static const Color accentGreenDark = Color(0xFF4FC79B);
  static const Color accentPinkDark = Color(0xFFF07AA8);

  static const Map<int, Color> _darkAccents = <int, Color>{
    0xFF12A594: accentTealDark,
    0xFFE63946: accentRedDark,
    0xFFD00000: accentCrimsonDark,
    0xFFE8590C: accentOrangeDark,
    0xFFE08600: accentAmberDark,
    0xFF2F6FED: accentBlueDark,
    0xFF5B5BD6: accentIndigoDark,
    0xFF8E44AD: accentPurpleDark,
    0xFF2A9D8F: accentGreenDark,
    0xFFD6336C: accentPinkDark,
  };

  /// The dark-mode counterpart of a light category accent, or the accent
  /// itself if it is not one of the ten (which should not happen).
  static Color darkAccent(Color lightAccent) =>
      _darkAccents[lightAccent.toARGB32()] ?? lightAccent;
```

Now replace both `AppSemanticColors` statics with the triage roles, remove the old fields, and update `copyWith` and `lerp` to match. The full replacement:

```dart
/// Semantic colours that Material's [ColorScheme] does not cover.
///
/// These are *triage* roles, not decoration. Emergency medicine already has a
/// rigorous severity colour system and this app is a triage tool, so colour
/// carries the severity: `immediate` appears only where the answer is "call
/// now", which is what makes it legible as urgency at all. `structural` is the
/// deliberately dull ink-blue that does the ordinary interface work red used
/// to do.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.immediate,
    required this.onImmediate,
    required this.urgent,
    required this.safe,
    required this.structural,
    required this.muted,
    required this.hairline,
    required this.sosGradientStart,
    required this.sosGradientEnd,
    required this.callPillFill,
    required this.callPillText,
  });

  /// Life-threatening. The SOS banner, call actions, the danger callout — and
  /// nothing else, ever.
  final Color immediate;
  final Color onImmediate;
  /// Urgent but not immediate: warnings, medicine expiry.
  final Color urgent;
  /// Non-urgent, done, safe: success, a finished lesson, the privacy note.
  final Color safe;
  /// The real interface accent: chips, switches, links, focus rings.
  final Color structural;
  final Color muted;
  final Color hairline;
  final Color sosGradientStart;
  final Color sosGradientEnd;
  final Color callPillFill;
  final Color callPillText;

  static const AppSemanticColors light = AppSemanticColors(
    immediate: Color(0xFFCB2635),
    onImmediate: Color(0xFFFFFFFF),
    urgent: Color(0xFFA05E00),
    safe: Color(0xFF0F7857),
    structural: Color(0xFF3A5570),
    muted: Color(0xFF56626F),
    hairline: Color(0xFFDDE3EA),
    sosGradientStart: Color(0xFFC8404F),
    sosGradientEnd: Color(0xFF8E1620),
    callPillFill: Color(0xFFFFFFFF),
    callPillText: Color(0xFF8E1620),
  );

  static const AppSemanticColors dark = AppSemanticColors(
    immediate: Color(0xFFFF7A85),
    onImmediate: Color(0xFF10151A),
    urgent: Color(0xFFF0B357),
    safe: Color(0xFF4FC79B),
    structural: Color(0xFF96B2C9),
    muted: Color(0xFF96A3B1),
    hairline: Color(0xFF2C353F),
    sosGradientStart: Color(0xFFA8323E),
    sosGradientEnd: Color(0xFF74121A),
    callPillFill: Color(0xFFE9EEF4),
    callPillText: Color(0xFFB3202E),
  );

  @override
  AppSemanticColors copyWith({
    Color? immediate,
    Color? onImmediate,
    Color? urgent,
    Color? safe,
    Color? structural,
    Color? muted,
    Color? hairline,
    Color? sosGradientStart,
    Color? sosGradientEnd,
    Color? callPillFill,
    Color? callPillText,
  }) {
    return AppSemanticColors(
      immediate: immediate ?? this.immediate,
      onImmediate: onImmediate ?? this.onImmediate,
      urgent: urgent ?? this.urgent,
      safe: safe ?? this.safe,
      structural: structural ?? this.structural,
      muted: muted ?? this.muted,
      hairline: hairline ?? this.hairline,
      sosGradientStart: sosGradientStart ?? this.sosGradientStart,
      sosGradientEnd: sosGradientEnd ?? this.sosGradientEnd,
      callPillFill: callPillFill ?? this.callPillFill,
      callPillText: callPillText ?? this.callPillText,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      immediate: Color.lerp(immediate, other.immediate, t)!,
      onImmediate: Color.lerp(onImmediate, other.onImmediate, t)!,
      urgent: Color.lerp(urgent, other.urgent, t)!,
      safe: Color.lerp(safe, other.safe, t)!,
      structural: Color.lerp(structural, other.structural, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      sosGradientStart: Color.lerp(sosGradientStart, other.sosGradientStart, t)!,
      sosGradientEnd: Color.lerp(sosGradientEnd, other.sosGradientEnd, t)!,
      callPillFill: Color.lerp(callPillFill, other.callPillFill, t)!,
      callPillText: Color.lerp(callPillText, other.callPillText, t)!,
    );
  }
}
```

- [ ] **Step 2: Run the contrast test — it must now pass in full**

Run: `flutter test test/contrast_test.dart`
Expected: PASS, 51 tests. If any pair fails, **darken the light value or lighten the dark value until it passes** — do not lower the threshold and do not change the test.

- [ ] **Step 3: Add the accent resolver extension**

In `lib/app/theme/app_theme.dart`, extend the existing `AppThemeX`:

```dart
  /// A topic's accent, resolved for the current brightness. Topic colours are
  /// baked into the data as light-mode constants.
  Color accent(Color lightAccent) =>
      isDark ? AppColors.darkAccent(lightAccent) : lightAccent;
```

- [ ] **Step 4: Confirm the tree does not yet compile, and see exactly where**

Run: `flutter analyze`
Expected: errors at the ~59 call sites using the removed `danger`/`warning`/`success`/`info`/`cardBorder`. **This list is the Task 4 worklist — save it:**

```bash
flutter analyze 2>&1 | grep -E "danger|warning|success|info|cardBorder" > /tmp/rename-worklist.txt
wc -l /tmp/rename-worklist.txt
```

- [ ] **Step 5: Commit (tree does not compile yet; Task 4 completes the rename)**

```bash
git add lib/app/theme/app_colors.dart lib/app/theme/app_theme.dart
git commit -m "Replace the palette with surface ladders and triage roles

Five rungs per brightness instead of dark mode's single 6% step, and four
triage roles instead of four near-synonyms for the same jobs. Every value is
measured against WCAG rather than picked by eye; three of the first-pass
colours failed and were corrected.

The tree does not compile until the call sites are renamed."
```

---

## Task 4: Rename the semantic colour call sites

A pure rename across ~59 sites. No behaviour changes. Do it mechanically and let the analyzer confirm completeness.

**Files:**
- Modify: `callout_box.dart`, `learn_screen.dart`, `question_view.dart`, `emergency_timer_sheet.dart`, `cpr_metronome_screen.dart`, `app_nav_bar.dart`, `app_theme.dart`, `nearby_screen.dart`, and any other file the analyzer names.
- Modify: existing tests that assert on the old names.

**Interfaces:**
- Consumes: `AppSemanticColors` from Task 3.
- Produces: a compiling tree. No new API.

- [ ] **Step 1: Apply the mapping**

The mapping is one-to-one. Work through `/tmp/rename-worklist.txt`:

| Old | New | Why |
|---|---|---|
| `semantic.danger` | `semantic.immediate` | same role, honest name |
| `semantic.onDanger` | `semantic.onImmediate` | |
| `semantic.warning` | `semantic.urgent` | |
| `semantic.success` | `semantic.safe` | |
| `semantic.info` | `semantic.structural` | the tip callout is informational, not urgent — this is the whole point of the change |
| `semantic.cardBorder` | `semantic.hairline` | |

One judgement call, in `callout_box.dart:22`: `CalloutType.tip` moves from `info` to `structural`. That is correct — a tip is not an alert, and giving it its own quiet colour is what stops the app looking like everything is shouting.

- [ ] **Step 2: Verify the rename is complete**

Run: `flutter analyze`
Expected: **No issues found.** If any `danger`/`warning`/`success`/`info`/`cardBorder` reference remains, it is a miss — fix it.

- [ ] **Step 3: Run the whole suite**

Run: `flutter test`
Expected: failures **only** in `screens_golden_test.dart` (the colours genuinely changed) and possibly in tests asserting on colour values. Every non-golden test must pass. Update any test asserting an old colour constant to the new one — a rename, not a behaviour change.

- [ ] **Step 4: Regenerate the goldens and look at them**

```bash
flutter test test/screens_golden_test.dart --update-goldens
```

Open `test/goldens/screens/home_dark.png`, `settings_dark.png`, `emergency_dark.png`. Confirm: cards now separate from the background by tone; switches and the "All" chip are ink-blue rather than red; the SOS banner is still unmistakably red. **The icon tiles will still look muddy — that is Task 6.**

Then check the diff is what you intended:
```bash
git diff --stat test/goldens/screens
```

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "Rename the semantic colour call sites to their triage roles

Mechanical, one-to-one, no behaviour change, except that the tip callout
moves from the alert palette to the structural one — a tip is not an alert,
and that distinction is the point of the rename."
```

---

## Task 5: Theme wiring — kill the seed tint, install the radius scale

**Files:**
- Modify: `lib/app/theme/app_theme.dart`
- Test: `test/theme_test.dart` (create)

**Interfaces:**
- Consumes: `AppSurfaces`, `AppSemanticColors` (Task 3).
- Produces: `AppRadii.xs/sm/md/lg/pill` (replacing `sm/md/lg/pill`). `AppTheme.light` / `AppTheme.dark` unchanged in signature.

- [ ] **Step 1: Write the failing test**

Create `test/theme_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/app/theme/app_colors.dart';
import 'package:help_me/app/theme/app_theme.dart';

void main() {
  test('primary is structural, not the emergency red', () {
    // Red on every chip and switch is why red stopped meaning anything.
    expect(AppTheme.light.colorScheme.primary, AppSemanticColors.light.structural);
    expect(AppTheme.dark.colorScheme.primary, AppSemanticColors.dark.structural);
    expect(AppTheme.dark.colorScheme.primary, isNot(AppColors.emergencyRed));
  });

  test('error is the immediate triage colour', () {
    expect(AppTheme.light.colorScheme.error, AppSemanticColors.light.immediate);
    expect(AppTheme.dark.colorScheme.error, AppSemanticColors.dark.immediate);
  });

  test('no container role is tinted by the seed', () {
    // ColorScheme.fromSeed red-tints every role the theme does not override,
    // which is why bottom sheets rendered maroon in dark and pink in light.
    // Each container must come from the surface ladder instead.
    for (final ThemeData theme in <ThemeData>[AppTheme.light, AppTheme.dark]) {
      final AppSurfaces s = theme.brightness == Brightness.dark
          ? AppSurfaces.dark
          : AppSurfaces.light;
      final ColorScheme c = theme.colorScheme;
      expect(c.surface, s.surface);
      expect(c.surfaceContainerLowest, s.bg);
      expect(c.surfaceContainerLow, s.surface);
      expect(c.surfaceContainer, s.raised);
      expect(c.surfaceContainerHigh, s.raised);
      expect(c.surfaceContainerHighest, s.high);
      expect(c.surfaceTint, Colors.transparent);
      expect(c.outline, s.hairline);
    }
  });

  test('the scaffold sits on bg, not on surface', () {
    expect(AppTheme.dark.scaffoldBackgroundColor, AppSurfaces.dark.bg);
    expect(AppTheme.light.scaffoldBackgroundColor, AppSurfaces.light.bg);
  });

  test('the radius scale has five steps in ascending order', () {
    expect(AppRadii.xs, 8);
    expect(AppRadii.sm, 12);
    expect(AppRadii.md, 18);
    expect(AppRadii.lg, 28);
    expect(AppRadii.pill, 999);
  });

  test('cards carry no border in dark — they separate by tone', () {
    // A hairline round every element is why nothing had hierarchy.
    final ShapeBorder? shape = AppTheme.dark.cardTheme.shape;
    expect(shape, isA<RoundedRectangleBorder>());
    expect((shape! as RoundedRectangleBorder).side.style, BorderStyle.none);
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

Run: `flutter test test/theme_test.dart`
Expected: FAIL — `AppRadii.xs` undefined, `primary` is still `emergencyRed`, containers still seeded.

- [ ] **Step 3: Rewrite `AppRadii` and `_build`**

Replace `AppRadii`:

```dart
/// Radii tied to element size rather than chosen per call site. The old set
/// (10/16/22/24/999) was used without a rule, so nothing had hierarchy.
abstract final class AppRadii {
  /// Icon tiles.
  static const double xs = 8;
  /// Buttons and inputs.
  static const double sm = 12;
  /// Cards.
  static const double md = 18;
  /// Sheets and the nav bar.
  static const double lg = 28;
  /// Chips only.
  static const double pill = 999;
}
```

In `_build`, replace the `ColorScheme` construction. Every container role is explicit so `fromSeed` cannot tint anything:

```dart
    final AppSurfaces surfaces = isDark ? AppSurfaces.dark : AppSurfaces.light;
    final AppSemanticColors semantic =
        isDark ? AppSemanticColors.dark : AppSemanticColors.light;

    // Built from the ladder rather than from a seed. `fromSeed` derives every
    // container role from the seed hue, so seeding with the emergency red
    // tinted sheets maroon in dark and pink in light while the app's own
    // tokens stayed neutral. Specifying each role removes that entirely.
    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: semantic.structural,
      onPrimary: isDark ? surfaces.bg : Colors.white,
      primaryContainer: surfaces.raised,
      onPrimaryContainer: surfaces.ink,
      secondary: AppColors.medicalTeal,
      onSecondary: Colors.white,
      secondaryContainer: surfaces.raised,
      onSecondaryContainer: surfaces.ink,
      tertiary: semantic.safe,
      onTertiary: isDark ? surfaces.bg : Colors.white,
      error: semantic.immediate,
      onError: semantic.onImmediate,
      errorContainer: surfaces.raised,
      onErrorContainer: semantic.immediate,
      surface: surfaces.surface,
      onSurface: surfaces.ink,
      onSurfaceVariant: surfaces.muted,
      surfaceContainerLowest: surfaces.bg,
      surfaceContainerLow: surfaces.surface,
      surfaceContainer: surfaces.raised,
      surfaceContainerHigh: surfaces.raised,
      surfaceContainerHighest: surfaces.high,
      surfaceTint: Colors.transparent,
      outline: surfaces.hairline,
      outlineVariant: surfaces.hairline,
      inverseSurface: surfaces.ink,
      onInverseSurface: surfaces.bg,
      shadow: Colors.black,
      scrim: Colors.black,
    );

    final Color background = surfaces.bg;
```

Then update the component themes: `cardTheme` drops its border and, in light only, gains a single soft shadow; inputs move to `AppRadii.sm`; `dialogTheme` and `bottomSheetTheme` take `surfaces.high` / `surfaces.raised` explicitly.

```dart
      cardTheme: CardThemeData(
        // Cards separate by tone in dark and by one soft shadow in light.
        // A hairline round everything is what made the old UI read flat.
        elevation: 0,
        color: surfaces.surface,
        shadowColor: Colors.black.withValues(alpha: 0.04),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide.none,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaces.high,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        clipBehavior: Clip.antiAlias,
        backgroundColor: surfaces.raised,
        surfaceTintColor: Colors.transparent,
      ),
```

Update every remaining `AppRadii.md` in this file that decorates a button or input to `AppRadii.sm`, and the input borders from `AppRadii.pill` to `AppRadii.sm`. The `inputDecorationTheme` `fillColor` becomes `surfaces.raised` in both modes.

- [ ] **Step 4: Run the theme test**

Run: `flutter test test/theme_test.dart`
Expected: PASS, 6 tests.

- [ ] **Step 5: Run everything and regenerate goldens**

```bash
flutter analyze && flutter test
flutter test test/screens_golden_test.dart --update-goldens
```
Expected: analyze clean; all non-golden tests pass.

- [ ] **Step 6: Look at the goldens**

Open `settings_dark.png` and the disclaimer in `home_light.png`. Confirm: **no maroon or pink tint anywhere** — sheets and dialogs are neutral. Cards read as raised by tone in dark. Search fields are rounded rectangles, not full pills.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "Build the ColorScheme from the ladder instead of a seed

Every container role is now explicit, so fromSeed can no longer tint sheets
maroon in dark and pink in light. Also installs the five-step radius scale
and drops the hairline that used to circle every element."
```

---

## Task 6: Icon tiles, nav pill, and the SOS banner

The three targeted dark-mode fixes. Each is a small edit with a large visual effect.

**Files:**
- Modify: `lib/core/widgets/topic_card.dart:68-88` (`_IconBadge`)
- Modify: `lib/core/widgets/app_nav_bar.dart:176-193` (`_NavButton`)
- Modify: `lib/core/widgets/sos_banner.dart`
- Modify: `lib/features/emergency/presentation/emergency_screen.dart:310-318`
- Create: `lib/core/widgets/accent_tile.dart`

**Interfaces:**
- Consumes: `context.accent(Color)` (Task 3), `AppRadii.xs` (Task 5).
- Produces: `AccentTile({required IconData icon, required Color accent, double size = 52, double iconSize = 26})` — the one icon-tile implementation, replacing the three near-identical copies in `topic_card.dart`, `emergency_screen.dart`, and `learn_screen.dart`.

- [ ] **Step 1: Write the failing test**

Create `test/accent_tile_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/app/theme/app_colors.dart';
import 'package:help_me/app/theme/app_theme.dart';
import 'package:help_me/core/widgets/accent_tile.dart';

Future<Container> _pumpTile(WidgetTester tester, ThemeData theme) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: const Scaffold(
        body: AccentTile(icon: Icons.healing, accent: AppColors.accentTeal),
      ),
    ),
  );
  return tester.widget<Container>(
    find.descendant(of: find.byType(AccentTile), matching: find.byType(Container)),
  );
}

void main() {
  testWidgets('in light the tile is a wash of its own accent', (WidgetTester tester) async {
    final Container tile = await _pumpTile(tester, AppTheme.light);
    final BoxDecoration d = tile.decoration! as BoxDecoration;
    expect(d.color, AppColors.accentTeal.withValues(alpha: 0.10));
  });

  testWidgets('in dark the tile is a raised surface, not a tinted wash',
      (WidgetTester tester) async {
    // accent-at-low-alpha over near-black composites to mud. This is why every
    // icon tile in the app used to look brown.
    final Container tile = await _pumpTile(tester, AppTheme.dark);
    final BoxDecoration d = tile.decoration! as BoxDecoration;
    expect(d.color, AppSurfaces.dark.raised);
    expect(d.border, isNotNull);
  });

  testWidgets('the icon uses the dark accent variant in dark mode',
      (WidgetTester tester) async {
    await _pumpTile(tester, AppTheme.dark);
    final Icon icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.color, AppColors.accentTealDark);
    expect(icon.color, isNot(AppColors.accentTeal));
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

Run: `flutter test test/accent_tile_test.dart`
Expected: FAIL — `accent_tile.dart` does not exist.

- [ ] **Step 3: Create `AccentTile`**

```dart
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';

/// The coloured square behind a topic, service, or lesson icon.
///
/// In light mode a wash of the accent works. In dark mode it does not: the
/// accent at low alpha composited over a near-black surface goes muddy brown,
/// which is what made every icon in the app look dirty. So in dark the tile is
/// a raised neutral with a faint accent hairline, and the accent goes on the
/// glyph — lifted to its dark-mode variant so it reads as itself.
class AccentTile extends StatelessWidget {
  const AccentTile({
    super.key,
    required this.icon,
    required this.accent,
    this.size = 52,
    this.iconSize = 26,
  });

  final IconData icon;

  /// The topic's light-mode accent, as stored in its data.
  final Color accent;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final bool dark = context.isDark;
    final Color resolved = context.accent(accent);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: dark ? AppSurfaces.dark.raised : accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.xs),
        border: dark
            ? Border.all(color: resolved.withValues(alpha: 0.24))
            : null,
      ),
      child: Icon(icon, color: resolved, size: iconSize),
    );
  }
}
```

- [ ] **Step 4: Run the test**

Run: `flutter test test/accent_tile_test.dart`
Expected: PASS, 3 tests.

- [ ] **Step 5: Replace the three copies**

- `topic_card.dart`: delete the private `_IconBadge` class entirely and replace its usage with `AccentTile(icon: topic.icon, accent: topic.color)`.
- `emergency_screen.dart:310-318`: replace the inline `leading: Container(...)` with `AccentTile(icon: item.icon, accent: accent, size: 46, iconSize: 24)`.
- `learn_screen.dart`: find the equivalent inline tile and replace it the same way.

Then fix `_NavButton` in `app_nav_bar.dart` — the selected pill:

```dart
    final Color active = context.semantic.structural;
    // `primary` at 24% over a near-black surface composites to a muddy maroon.
    // A real ladder rung reads as a raised pill instead.
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: Material(
        color: selected
            ? (context.isDark
                ? AppSurfaces.dark.high
                : active.withValues(alpha: 0.10))
            : Colors.transparent,
```

and in `sos_banner.dart` the call pill:

```dart
            FilledButton(
              onPressed: () => callWithFeedback(context, number),
              style: FilledButton.styleFrom(
                // Pure white on saturated red is the brightest thing on a dark
                // screen at 3am. The dark variant softens the fill without
                // costing the button any affordance.
                backgroundColor: semantic.callPillFill,
                foregroundColor: semantic.callPillText,
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
              ),
```

The gradient in `sos_banner.dart` needs no edit — it already reads `semantic.sosGradientStart`/`End`, which Task 3 corrected.

- [ ] **Step 6: Run everything, regenerate, and look**

```bash
flutter analyze && flutter test
flutter test test/screens_golden_test.dart --update-goldens
```

Open `home_dark.png`, `emergency_dark.png`, `learn_dark.png`. Confirm: **no muddy brown or maroon tiles anywhere**; the nav pill is a clean raised rectangle; the SOS banner is deeper but still clearly red, and its white heading is comfortably readable.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "Fix the three dark-mode artefacts: tiles, nav pill, call button

Accent-at-low-alpha over near-black composites to mud, which is why every
icon tile looked brown and the selected nav pill looked maroon. Tiles become
raised neutrals with the accent on the glyph, and the three near-identical
tile implementations collapse into one AccentTile."
```

> **Phase 1 is complete.** Look at all 18 goldens side by side against the Task 1 baseline before starting Phase 2.

---

## Task 7: Bundle the fonts

**Files:**
- Create: `assets/fonts/BarlowSemiCondensed-SemiBold.ttf`, `BarlowSemiCondensed-Bold.ttf`, `IBMPlexSans-Regular.ttf`, `IBMPlexSans-SemiBold.ttf`, `OFL-Barlow.txt`, `LICENSE-IBMPlex.txt`
- Modify: `pubspec.yaml`, `assets/CREDITS.md`

**Interfaces:**
- Consumes: nothing.
- Produces: font families `'Barlow Semi Condensed'` and `'IBM Plex Sans'`, declared with weights 600/700 and 400/600 respectively. Task 8 consumes these exact family strings.

- [ ] **Step 1: Download the files**

All four URLs were verified to return real TTFs (not LFS pointers). The IBM Plex path is pinned to `v6.4.0` because `master` restructured and 404s.

```bash
cd assets/fonts
B="https://raw.githubusercontent.com/google/fonts/main/ofl/barlowsemicondensed"
P="https://raw.githubusercontent.com/IBM/plex/v6.4.0"
curl -sL -o BarlowSemiCondensed-SemiBold.ttf "$B/BarlowSemiCondensed-SemiBold.ttf"
curl -sL -o BarlowSemiCondensed-Bold.ttf     "$B/BarlowSemiCondensed-Bold.ttf"
curl -sL -o OFL-Barlow.txt                   "$B/OFL.txt"
curl -sL -o IBMPlexSans-Regular.ttf  "$P/IBM-Plex-Sans/fonts/complete/ttf/IBMPlexSans-Regular.ttf"
curl -sL -o IBMPlexSans-SemiBold.ttf "$P/IBM-Plex-Sans/fonts/complete/ttf/IBMPlexSans-SemiBold.ttf"
curl -sL -o LICENSE-IBMPlex.txt      "$P/LICENSE.txt"
cd ../..
```

- [ ] **Step 2: Verify they are fonts, not error pages**

```bash
file -b assets/fonts/BarlowSemiCondensed-Bold.ttf assets/fonts/IBMPlexSans-Regular.ttf
ls -l assets/fonts/*.ttf
```
Expected: both report `TrueType Font data`. Barlow ≈112KB each, Plex ≈200KB each. **If either is a few hundred bytes it is an HTML error page — stop and re-download.**

- [ ] **Step 3 (optional): Subset to Latin**

Plex ships Greek and Cyrillic that this app cannot render. Subsetting cuts ~624KB to roughly a third. Skip this step if `pip` is unavailable — the unsubsetted files are acceptable.

```bash
python3 -m venv /tmp/fontenv && /tmp/fontenv/bin/pip -q install fonttools
for f in assets/fonts/IBMPlexSans-Regular.ttf assets/fonts/IBMPlexSans-SemiBold.ttf \
         assets/fonts/BarlowSemiCondensed-SemiBold.ttf assets/fonts/BarlowSemiCondensed-Bold.ttf; do
  /tmp/fontenv/bin/pyftsubset "$f" --output-file="$f.sub" \
    --unicodes="U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+2000-206F,U+2074,U+20AC,U+2122,U+2191,U+2193,U+2212,U+2215" \
    --layout-features="kern,liga,tnum" --flavor=""
  mv "$f.sub" "$f"
done
ls -l assets/fonts/*.ttf
```

Note `tnum` is retained deliberately — Task 8 needs tabular figures for the emergency numbers and timers.

- [ ] **Step 4: Declare them in `pubspec.yaml`**

Add to the `fonts:` list, after the existing Cairo block:

```yaml
    - family: Barlow Semi Condensed
      fonts:
        - asset: assets/fonts/BarlowSemiCondensed-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/BarlowSemiCondensed-Bold.ttf
          weight: 700
    - family: IBM Plex Sans
      fonts:
        - asset: assets/fonts/IBMPlexSans-Regular.ttf
          weight: 400
        - asset: assets/fonts/IBMPlexSans-SemiBold.ttf
          weight: 600
```

- [ ] **Step 5: Record the licences**

Append to `assets/CREDITS.md`:

```markdown
## Typefaces

- **Cairo** — Mohamed Gaber and contributors. SIL Open Font License 1.1
  (`assets/fonts/OFL.txt`). Arabic text, all roles.
- **Barlow Semi Condensed** — Jeremy Tribby. SIL Open Font License 1.1
  (`assets/fonts/OFL-Barlow.txt`). Latin headings and numerals.
- **IBM Plex Sans** — IBM Corp. SIL Open Font License 1.1
  (`assets/fonts/LICENSE-IBMPlex.txt`). Latin body and interface text.
```

- [ ] **Step 6: Confirm the fonts resolve**

Run: `flutter pub get && flutter test test/screens_golden_test.dart`
Expected: PASS with no diffs — nothing uses the new families yet, so nothing may change. **A golden diff here means something is resolving the new font by accident; investigate before continuing.**

- [ ] **Step 7: Commit**

```bash
git add assets/fonts pubspec.yaml assets/CREDITS.md
git commit -m "Bundle Barlow Semi Condensed and IBM Plex Sans

Both OFL, both bundled rather than fetched, because the app has to render
identically offline. Nothing consumes them yet."
```

---

## Task 8: The type system

**Files:**
- Modify: `lib/app/theme/app_typography.dart`
- Modify: `lib/app/theme/app_theme.dart` (pass the locale through)
- Modify: `lib/app/app.dart` (rebuild the theme when the locale changes)
- Test: `test/typography_test.dart` (create)

**Interfaces:**
- Consumes: the family strings from Task 7.
- Produces:
  - `AppTypography.forLocale(TextTheme base, Locale locale)` → `TextTheme`
  - `AppTypography.bodyFamily(Locale)` → `String`, `AppTypography.displayFamily(Locale)` → `String`
  - `AppTypography.tabularFigures` → `List<FontFeature>`, for timers and dialled numbers
  - `AppTheme.light`/`.dark` gain a required positional `Locale`: **`AppTheme.light(locale)`**. Every existing call site — `app.dart` and ~8 test files — must pass one.

- [ ] **Step 1: Write the failing test**

Create `test/typography_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/app/theme/app_typography.dart';

void main() {
  const Locale ar = Locale('ar');
  const Locale en = Locale('en');

  test('Arabic keeps Cairo for both display and body', () {
    expect(AppTypography.displayFamily(ar), 'Cairo');
    expect(AppTypography.bodyFamily(ar), 'Cairo');
  });

  test('Latin pairs a condensed display face with a humanist body face', () {
    // Cairo is an Arabic typeface; its Latin is why the English UI read bland.
    expect(AppTypography.displayFamily(en), 'Barlow Semi Condensed');
    expect(AppTypography.bodyFamily(en), 'IBM Plex Sans');
  });

  test('headings take the display face and body takes the body face', () {
    final TextTheme t = AppTypography.forLocale(ThemeData.light().textTheme, en);
    expect(t.headlineSmall?.fontFamily, 'Barlow Semi Condensed');
    expect(t.titleLarge?.fontFamily, 'Barlow Semi Condensed');
    expect(t.bodyLarge?.fontFamily, 'IBM Plex Sans');
    expect(t.bodyMedium?.fontFamily, 'IBM Plex Sans');
    expect(t.labelLarge?.fontFamily, 'IBM Plex Sans');
  });

  test('Arabic uses one family throughout', () {
    final TextTheme t = AppTypography.forLocale(ThemeData.light().textTheme, ar);
    expect(t.headlineSmall?.fontFamily, 'Cairo');
    expect(t.bodyLarge?.fontFamily, 'Cairo');
  });

  test('the scale is the seven declared steps', () {
    final TextTheme t = AppTypography.forLocale(ThemeData.light().textTheme, en);
    expect(t.displaySmall?.fontSize, 34);
    expect(t.headlineMedium?.fontSize, 26);
    expect(t.headlineSmall?.fontSize, 21);
    expect(t.titleMedium?.fontSize, 17);
    expect(t.bodyLarge?.fontSize, 15.5);
    expect(t.bodyLarge?.height, 1.55);
    expect(t.labelLarge?.fontSize, 14);
    expect(t.bodySmall?.fontSize, 12.5);
  });

  test('tabular figures are available for numbers that must not jitter', () {
    // A countdown whose digits change width shifts the layout every second.
    expect(
      AppTypography.tabularFigures,
      contains(const FontFeature.tabularFigures()),
    );
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

Run: `flutter test test/typography_test.dart`
Expected: FAIL — `forLocale`, `displayFamily`, `bodyFamily`, `tabularFigures` are all undefined.

- [ ] **Step 3: Rewrite `app_typography.dart`**

```dart
import 'package:flutter/material.dart';

/// The app's two type systems: one for Arabic, one for Latin.
///
/// Cairo is an Arabic typeface and stays the whole system for Arabic. Setting
/// English in it too — which the app used to do — gave every Latin heading the
/// same bland, uniform look. Latin gets a real pairing instead: Barlow Semi
/// Condensed for headings and numerals, whose lineage is road and safety
/// signage and whose condensed widths let a long English heading and a number
/// like 123 sit tight; and IBM Plex Sans for body and interface text, whose
/// instrumentation character suits a clinical tool.
abstract final class AppTypography {
  static const String cairo = 'Cairo';
  static const String barlow = 'Barlow Semi Condensed';
  static const String plex = 'IBM Plex Sans';

  /// Figures that keep a fixed advance width, so a running timer or a dialled
  /// number does not shift the layout as its digits change.
  static const List<FontFeature> tabularFigures = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  static bool _isArabic(Locale locale) => locale.languageCode == 'ar';

  /// Headings and numerals.
  static String displayFamily(Locale locale) =>
      _isArabic(locale) ? cairo : barlow;

  /// Body and interface text.
  static String bodyFamily(Locale locale) => _isArabic(locale) ? cairo : plex;

  /// Builds the app's text theme for [locale] on top of [base], which supplies
  /// the brightness-correct text colours.
  static TextTheme forLocale(TextTheme base, Locale locale) {
    final String display = displayFamily(locale);
    final String body = bodyFamily(locale);
    final Color? ink = base.bodyLarge?.color;

    TextStyle d(double size, FontWeight weight, double height) => TextStyle(
          fontFamily: display,
          fontSize: size,
          fontWeight: weight,
          height: height,
          color: ink,
        );

    TextStyle b(double size, FontWeight weight, double height) => TextStyle(
          fontFamily: body,
          fontSize: size,
          fontWeight: weight,
          height: height,
          color: ink,
        );

    return base.copyWith(
      displayLarge: d(44, FontWeight.w700, 1.05),
      displayMedium: d(38, FontWeight.w700, 1.08),
      displaySmall: d(34, FontWeight.w700, 1.1),
      headlineLarge: d(30, FontWeight.w700, 1.12),
      headlineMedium: d(26, FontWeight.w700, 1.15),
      headlineSmall: d(21, FontWeight.w600, 1.2),
      titleLarge: d(19, FontWeight.w600, 1.25),
      titleMedium: d(17, FontWeight.w600, 1.3),
      titleSmall: b(15, FontWeight.w600, 1.35),
      bodyLarge: b(15.5, FontWeight.w400, 1.55),
      bodyMedium: b(14.5, FontWeight.w400, 1.55),
      bodySmall: b(12.5, FontWeight.w400, 1.45),
      labelLarge: b(14, FontWeight.w600, 1.2),
      labelMedium: b(13, FontWeight.w600, 1.2),
      labelSmall: b(12, FontWeight.w600, 1.2),
    );
  }
}
```

- [ ] **Step 4: Thread the locale through the theme**

In `app_theme.dart`, change the getters to take a locale and drop the now-wrong global `fontFamily`:

```dart
  static ThemeData light(Locale locale) => _build(Brightness.light, locale);
  static ThemeData dark(Locale locale) => _build(Brightness.dark, locale);

  static ThemeData _build(Brightness brightness, Locale locale) {
```

and inside:

```dart
    final TextTheme textTheme = AppTypography.forLocale(
      (isDark ? ThemeData.dark() : ThemeData.light()).textTheme.apply(
            bodyColor: surfaces.ink,
            displayColor: surfaces.ink,
          ),
      locale,
    );
```

Remove the `fontFamily: AppTypography.fontFamily,` line from the `ThemeData(...)` call — a single global family would override the per-role families above.

In `app.dart`, pass the resolved locale. It must be the *effective* locale, not the setting, so a system-default user still gets the right family:

```dart
    final AppSettings settings = ref.watch(settingsProvider);
    // The theme carries locale-specific typefaces, so it has to be rebuilt when
    // the locale changes. `settings.locale` is null on "system default", in
    // which case Arabic is the app's fallback.
    final Locale locale = settings.locale ??
        (AppLocalizations.supportedLocales.any(
          (Locale l) =>
              l.languageCode ==
              PlatformDispatcher.instance.locale.languageCode,
        )
            ? Locale(PlatformDispatcher.instance.locale.languageCode)
            : const Locale('ar'));

    return MaterialApp(
      ...
      theme: AppTheme.light(locale),
      darkTheme: AppTheme.dark(locale),
```

Add `import 'dart:ui' show PlatformDispatcher;` to `app.dart`.

- [ ] **Step 5: Fix every `AppTheme.light` / `AppTheme.dark` call site**

Run: `flutter analyze`
Expected: errors wherever `AppTheme.light` is used as a getter — `app.dart` and the test files. Pass `const Locale('en')` in tests unless the test is specifically Arabic, in which case pass `const Locale('ar')`.

```bash
grep -rln "AppTheme.light\|AppTheme.dark" lib test
```

In `screens_golden_test.dart`, the theme must match the locale being rendered — change the `screens` loop to build `AppTheme.dark(locale)` from the same `locale` it passes to `MaterialApp`, otherwise the Arabic goldens render Arabic text in a Latin theme.

- [ ] **Step 6: Add the fonts to the golden loader**

In `screens_golden_test.dart`'s `loadAppFonts`, add:

```dart
  await load('Barlow Semi Condensed', <String>[
    'assets/fonts/BarlowSemiCondensed-SemiBold.ttf',
    'assets/fonts/BarlowSemiCondensed-Bold.ttf',
  ]);
  await load('IBM Plex Sans', <String>[
    'assets/fonts/IBMPlexSans-Regular.ttf',
    'assets/fonts/IBMPlexSans-SemiBold.ttf',
  ]);
```

- [ ] **Step 7: Run everything**

```bash
flutter analyze && flutter test
```
Expected: analyze clean; `typography_test.dart` passes 6; only golden tests fail.

- [ ] **Step 8: Regenerate and look carefully**

```bash
flutter test test/screens_golden_test.dart --update-goldens
```

Open every `_light`, `_dark` and `_dark_ar` golden. Check specifically:
- English headings are visibly condensed; body text is visibly not Cairo.
- **Arabic is unchanged** — compare `home_dark_ar.png` against the Task 1 baseline; only colour should differ, never the letterforms.
- **No clipped or overflowing text.** Two new families change every metric; anything with a hardcoded height near text is the likely casualty. Check the nav bar labels in both scripts and the chip row.
- No tofu boxes.

- [ ] **Step 9: Commit**

```bash
git add -A
git commit -m "Pair a Latin type system alongside Cairo

Cairo is an Arabic typeface and stays the whole system for Arabic; setting
English in it too gave every Latin heading the same bland weight. Latin now
gets Barlow Semi Condensed for headings and numerals and IBM Plex Sans for
body, selected from the effective locale."
```

> **Phase 2 is complete.**

---

## Task 9: The skeleton primitive

**Files:**
- Create: `lib/core/widgets/app_skeleton.dart`
- Test: `test/app_skeleton_test.dart`

**Interfaces:**
- Consumes: `AppSurfaces` (Task 3), `AppRadii` (Task 5).
- Produces: `AppSkeleton({double? width, double? height, double? aspectRatio, double radius = AppRadii.md})`. Exactly one of `height` or `aspectRatio` must be given; asserted.

- [ ] **Step 1: Write the failing test**

Create `test/app_skeleton_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/app/theme/app_colors.dart';
import 'package:help_me/app/theme/app_theme.dart';
import 'package:help_me/core/widgets/app_skeleton.dart';

Future<void> _pump(
  WidgetTester tester, {
  bool reduceMotion = false,
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: MaterialApp(
        theme: theme ?? AppTheme.dark(const Locale('en')),
        home: const Scaffold(
          body: AppSkeleton(width: 100, height: 40),
        ),
      ),
    ),
  );
}

double _opacity(WidgetTester tester) =>
    tester.widget<Opacity>(find.byType(Opacity)).opacity;

void main() {
  testWidgets('the block fills with the raised rung in dark', (WidgetTester tester) async {
    await _pump(tester);
    final Container box = tester.widget<Container>(
      find.descendant(of: find.byType(AppSkeleton), matching: find.byType(Container)),
    );
    expect((box.decoration! as BoxDecoration).color, AppSurfaces.dark.raised);
  });

  testWidgets('it breathes rather than shimmering', (WidgetTester tester) async {
    // A translating gradient sweep is the stock loading look, and a fast
    // shimmer is noise in an app someone opens while panicking. A slow opacity
    // pulse reads as waiting calmly.
    await _pump(tester);
    final double first = _opacity(tester);
    await tester.pump(const Duration(milliseconds: 700));
    final double mid = _opacity(tester);
    expect(mid, isNot(closeTo(first, 0.01)));
    expect(mid, inInclusiveRange(0.55, 1.0));
  });

  testWidgets('reduced motion renders a static block', (WidgetTester tester) async {
    await _pump(tester, reduceMotion: true);
    final double first = _opacity(tester);
    await tester.pump(const Duration(milliseconds: 700));
    expect(_opacity(tester), first);
    expect(first, 1.0);
  });

  testWidgets('an aspect ratio sizes the block without an explicit height',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(const Locale('en')),
        home: const Scaffold(
          body: SizedBox(width: 320, child: AppSkeleton(aspectRatio: 16 / 9)),
        ),
      ),
    );
    expect(tester.getSize(find.byType(AppSkeleton)).height, closeTo(180, 0.5));
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

Run: `flutter test test/app_skeleton_test.dart`
Expected: FAIL — `app_skeleton.dart` does not exist.

- [ ] **Step 3: Implement it**

```dart
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';

/// A placeholder standing in for content that is genuinely still loading.
///
/// The stock skeleton is a grey block with a gradient sweeping across it. This
/// one breathes instead: a slow opacity pulse, no translation. Two reasons —
/// a diagonal shimmer is the single most recognisable "generated UI" tic, and
/// more importantly this is a first-aid app, where a fast, urgent-looking
/// animation is noise at exactly the moment someone can least afford it. A
/// 1.4s ease-in-out pulse reads as waiting calmly.
///
/// A skeleton is a promise about the layout that is coming, so give it the
/// real dimensions of the content it replaces. Use [aspectRatio] when the
/// content's height follows its width, as an image's does.
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    super.key,
    this.width,
    this.height,
    this.aspectRatio,
    this.radius = AppRadii.md,
  }) : assert(
          (height == null) != (aspectRatio == null),
          'Give exactly one of height or aspectRatio.',
        );

  final double? width;
  final double? height;
  final double? aspectRatio;
  final double radius;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  static const Duration _period = Duration(milliseconds: 1400);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _period,
  );

  late final Animation<double> _pulse = Tween<double>(
    begin: 1.0,
    end: 0.55,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read reduced-motion here rather than in initState: it can change while
    // the widget is alive, and an animation nobody asked for is worse than
    // none.
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget block = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: context.isDark
            ? AppSurfaces.dark.raised
            : const Color(0xFFE6EBF1),
        borderRadius: BorderRadius.circular(widget.radius),
      ),
    );

    final Widget sized = widget.aspectRatio == null
        ? block
        : AspectRatio(aspectRatio: widget.aspectRatio!, child: block);

    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (BuildContext context, Widget? child) =>
            Opacity(opacity: _pulse.value, child: child),
        child: sized,
      ),
    );
  }
}
```

- [ ] **Step 4: Run the test**

Run: `flutter test test/app_skeleton_test.dart`
Expected: PASS, 4 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/app_skeleton.dart test/app_skeleton_test.dart
git commit -m "Add a breathing skeleton placeholder

Pulses opacity rather than sweeping a gradient: the shimmer is the stock
generated-UI tic, and a fast urgent animation is the wrong texture for an
app opened during an emergency. Respects reduced motion."
```

---

## Task 10: Put skeletons where loading is real

Only two sites qualify. Everything else in the app has its data before its first frame, and a skeleton there would be a lie about latency that does not exist.

**Files:**
- Modify: `lib/features/conditions/presentation/widgets/topic_gallery.dart:40-70`
- Modify: `lib/features/conditions/presentation/video_player_screen.dart:96`
- Modify: `lib/core/widgets/topic_card.dart` (precache on tap)
- Test: `test/skeleton_golden_test.dart`

**Interfaces:**
- Consumes: `AppSkeleton` (Task 9), `pumpScreen`/`loadAppFonts` (Task 1).
- Produces: no new API.

- [ ] **Step 1: Write the failing test**

Create `test/skeleton_golden_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/app/theme/app_theme.dart';
import 'package:help_me/core/widgets/app_skeleton.dart';

import 'screens_golden_test.dart' show loadAppFonts;

void main() {
  setUpAll(loadAppFonts);

  for (final (String name, ThemeData theme) in <(String, ThemeData)>[
    ('dark', AppTheme.dark(const Locale('en'))),
    ('light', AppTheme.light(const Locale('en'))),
  ]) {
    testWidgets('the gallery and video skeletons — $name',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 1400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const <Widget>[
                  AppSkeleton(height: 196, radius: AppRadii.md),
                  SizedBox(height: 20),
                  AppSkeleton(aspectRatio: 16 / 9, radius: AppRadii.md),
                ],
              ),
            ),
          ),
        ),
      );
      // Land mid-pulse so the golden shows the dimmed state, which is the one
      // worth reviewing — a skeleton at full opacity looks like content.
      await tester.pump(const Duration(milliseconds: 700));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/skeletons_$name.png'),
      );
    });
  }
}
```

- [ ] **Step 2: Generate and look**

```bash
flutter test test/skeleton_golden_test.dart --update-goldens
```

Open `test/goldens/skeletons_dark.png` and `skeletons_light.png`. Confirm the blocks read as placeholders — present but recessive, clearly not content.

- [ ] **Step 3: Give the gallery a skeleton and a fade**

In `topic_gallery.dart`, replace the bare `Image.asset` (currently lines 63-68) with:

```dart
                    : Image.asset(
                        image.asset,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        // A bare Image.asset shows nothing at all until the
                        // decode finishes, then snaps in. The skeleton holds
                        // the frame's shape and the fade makes the arrival
                        // calm instead of abrupt.
                        frameBuilder: (
                          BuildContext context,
                          Widget child,
                          int? frame,
                          bool wasSynchronouslyLoaded,
                        ) {
                          if (wasSynchronouslyLoaded) return child;
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: frame == null
                                ? const AppSkeleton(
                                    aspectRatio: 1,
                                    radius: AppRadii.lg,
                                  )
                                : child,
                          );
                        },
                        errorBuilder: (
                          BuildContext context,
                          Object error,
                          StackTrace? stack,
                        ) {
                          // A missing photo must not look like a crash: fall
                          // back to the topic's own icon rather than Flutter's
                          // broken-image glyph.
                          return ColoredBox(
                            color: context.isDark
                                ? AppSurfaces.dark.raised
                                : AppSurfaces.light.raised,
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: context.semantic.muted,
                                size: 32,
                              ),
                            ),
                          );
                        },
                      ),
```

Also change the container's placeholder fill (line 43) from `widget.accent.withValues(alpha: 0.08)` to the resolved dark-safe form:

```dart
            color: context.isDark
                ? AppSurfaces.dark.raised
                : widget.accent.withValues(alpha: 0.06),
```

Add the needed imports: `app_skeleton.dart` and `app_colors.dart`.

- [ ] **Step 4: Precache on tap**

In `topic_card.dart`, make the tap warm the images so the skeleton usually never appears:

```dart
        onTap: () {
          // Warm the detail screen's photos while the push transition runs, so
          // the gallery is usually already decoded by the time it is visible.
          for (final TopicImage image in kTopicMedia[topic.id]?.images ??
              const <TopicImage>[]) {
            if (!image.isDrawing) {
              precacheImage(AssetImage(image.asset), context);
            }
          }
          Navigator.of(context).push(ConditionDetailScreen.route(topic));
        },
```

Add imports for `topic_media.dart` and `topic_media_data.dart`. Check the real member names in `lib/core/media/topic_media.dart` before writing this — use whatever the `TopicMedia` class actually calls its image list and the drawing flag.

- [ ] **Step 5: Replace the video spinner**

In `video_player_screen.dart:96`, replace `const Center(child: CircularProgressIndicator.adaptive())` with:

```dart
                    ? const AppSkeleton(aspectRatio: 16 / 9, radius: AppRadii.md)
```

- [ ] **Step 6: Run everything**

```bash
flutter analyze && flutter test
```
Expected: analyze clean, all tests pass. Regenerate `screens_golden_test.dart` goldens if the detail screen's placeholder colour shifted, and look at `detail_dark.png` to confirm.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "Give the two genuinely async surfaces skeletons

The gallery called Image.asset bare, so the photo area was an empty box until
the decode finished and then snapped in; the video showed a spinner in a black
rectangle. Both now hold their shape and fade in, and tapping a topic card
precaches its photos so the skeleton usually never appears.

Nothing else gets one: the rest of the app's data is read before first frame,
so a skeleton there would be theatre."
```

> **Phase 3 is complete.**

---

## Task 11: The number is the hero

**Files:**
- Modify: `lib/features/emergency/presentation/emergency_screen.dart:295-333` (`_NumberTile`)
- Test: `test/emergency_number_test.dart`

**Interfaces:**
- Consumes: `AppTypography.tabularFigures` (Task 8), `AccentTile` (Task 6).
- Produces: no new API.

- [ ] **Step 1: Write the failing test**

Create `test/emergency_number_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/app/theme/app_theme.dart';
import 'package:help_me/features/emergency/presentation/emergency_screen.dart';
import 'package:help_me/l10n/app_localizations.dart';
import 'package:help_me/providers/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('the dialled number is the largest text on its card',
      (WidgetTester tester) async {
    // The whole point of this screen is the number. It used to be the
    // smallest, greyest thing on the card.
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.light(const Locale('en')),
          home: const EmergencyScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    final Text number = tester.widget<Text>(find.text('123').first);
    final Text name = tester.widget<Text>(find.text('Ambulance').first);

    expect(
      number.style!.fontSize!,
      greaterThan(name.style!.fontSize!),
      reason: 'the number must outrank the service name',
    );
    expect(number.style!.fontFeatures, isNotNull);
    expect(number.textDirection, TextDirection.ltr);
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

Run: `flutter test test/emergency_number_test.dart`
Expected: FAIL — the number currently uses `bodyMedium` and the name `titleMedium`, so the assertion inverts.

- [ ] **Step 3: Invert the hierarchy**

Replace `_NumberTile`'s `ListTile` title/subtitle with a `Column` that puts the label above and the number below:

```dart
          // The number is the payload of this entire screen, so it gets the
          // display face at display size. The service name becomes its label.
          title: Text(
            item.name.resolve(context.locale),
            style: context.texts.labelMedium?.copyWith(
              color: context.semantic.muted,
            ),
          ),
          subtitle: Text(
            item.number,
            // Always LTR: a phone number is not reordered by the UI's
            // direction, and tabular figures keep the digits from shifting.
            textDirection: TextDirection.ltr,
            style: context.texts.headlineSmall?.copyWith(
              fontFamily: AppTypography.displayFamily(context.locale),
              fontFeatures: AppTypography.tabularFigures,
              color: context.colors.onSurface,
              height: 1.1,
            ),
          ),
```

Add `import '../../../app/theme/app_typography.dart';`.

- [ ] **Step 4: Run the test**

Run: `flutter test test/emergency_number_test.dart`
Expected: PASS.

- [ ] **Step 5: Regenerate, look, commit**

```bash
flutter analyze && flutter test
flutter test test/screens_golden_test.dart --update-goldens
```

Open `emergency_light.png`, `emergency_dark.png`, and `emergency_dark_ar.png`. Confirm the numbers now dominate their cards and read LTR even in the Arabic render.

```bash
git add -A
git commit -m "Make the emergency number the hero of its card

The number is what the screen exists to deliver and it was the smallest,
greyest element on the card. It now takes the display face at display size
with tabular figures, and the service name becomes its label."
```

---

## Task 12: The chip row stops clipping

**Files:**
- Create: `lib/core/widgets/fading_edge_row.dart`
- Modify: `lib/features/home/home_screen.dart:144-174` (`_CategoryChips`)
- Test: `test/fading_edge_row_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `FadingEdgeRow({required List<Widget> children, double height, ScrollController? controller})`.

- [ ] **Step 1: Write the failing test**

Create `test/fading_edge_row_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/core/widgets/fading_edge_row.dart';

Future<void> _pump(WidgetTester tester, TextDirection direction) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: FadingEdgeRow(
            children: <Widget>[
              for (int i = 0; i < 12; i++)
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Chip(label: Text('Category $i')),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('the row masks its overflowing edge in LTR', (WidgetTester tester) async {
    // A row of chips cut off mid-word reads as broken rather than scrollable.
    await _pump(tester, TextDirection.ltr);
    expect(find.byType(ShaderMask), findsOneWidget);
  });

  testWidgets('the row scrolls horizontally', (WidgetTester tester) async {
    await _pump(tester, TextDirection.ltr);
    final ScrollableState scrollable = tester.state(find.byType(Scrollable));
    expect(scrollable.position.axis, Axis.horizontal);
    expect(scrollable.position.maxScrollExtent, greaterThan(0));
  });

  testWidgets('it masks the leading edge in RTL', (WidgetTester tester) async {
    await _pump(tester, TextDirection.rtl);
    final ShaderMask mask = tester.widget<ShaderMask>(find.byType(ShaderMask));
    expect(mask.shaderCallback, isNotNull);
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

Run: `flutter test test/fading_edge_row_test.dart`
Expected: FAIL — `fading_edge_row.dart` does not exist.

- [ ] **Step 3: Implement it**

```dart
import 'package:flutter/material.dart';

/// A horizontally scrolling row whose overflowing edge fades out.
///
/// A hard cut through the middle of a word — "Bleedin" — reads as a layout bug
/// rather than an invitation to scroll. The fade says "there is more this way"
/// without adding a control. The masked edge follows the reading direction, so
/// it lands on the correct side in Arabic.
class FadingEdgeRow extends StatelessWidget {
  const FadingEdgeRow({
    super.key,
    required this.children,
    this.height = 40,
    this.controller,
  });

  final List<Widget> children;
  final double height;
  final ScrollController? controller;

  static const double _fadeFraction = 0.06;

  @override
  Widget build(BuildContext context) {
    final bool rtl = Directionality.of(context) == TextDirection.rtl;

    return SizedBox(
      height: height,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            begin: rtl ? Alignment.centerRight : Alignment.centerLeft,
            end: rtl ? Alignment.centerLeft : Alignment.centerRight,
            colors: const <Color>[Colors.white, Colors.white, Colors.transparent],
            stops: <double>[0, 1 - _fadeFraction, 1],
          ).createShader(bounds);
        },
        child: ListView(
          controller: controller,
          scrollDirection: Axis.horizontal,
          children: children,
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run the test**

Run: `flutter test test/fading_edge_row_test.dart`
Expected: PASS, 3 tests.

- [ ] **Step 5: Adopt it in `_CategoryChips`**

Replace the `SizedBox(height: 40, child: ListView(...))` with `FadingEdgeRow(children: <Widget>[...])`, keeping the chip children exactly as they are. Also give the selected chip the pill radius and the structural colour:

```dart
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        showCheckmark: false,
        selectedColor: context.semantic.structural,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        labelStyle: context.texts.labelLarge?.copyWith(
          color: selected ? context.colors.onPrimary : context.colors.onSurface,
        ),
      ),
```

- [ ] **Step 6: Run, regenerate, look, commit**

```bash
flutter analyze && flutter test
flutter test test/screens_golden_test.dart --update-goldens
```

Open `home_light.png` and `home_dark_ar.png`. Confirm the chip row fades on the trailing edge in English and on the **leading** edge in Arabic.

```bash
git add -A
git commit -m "Fade the chip row's overflowing edge

A row cut off mid-word reads as broken rather than scrollable. The mask
follows the reading direction so it lands correctly in Arabic."
```

---

## Task 13: The triage rule

**Files:**
- Create: `lib/core/widgets/triage_rule.dart`
- Modify: `lib/core/widgets/callout_box.dart`, `lib/core/widgets/sos_banner.dart`
- Modify: `lib/features/conditions/presentation/condition_detail_screen.dart` (the section heading)
- Test: `test/triage_rule_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `TriageRule({required Color color, double? height, double width = 3})`.

- [ ] **Step 1: Write the failing test**

Create `test/triage_rule_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/core/widgets/triage_rule.dart';

void main() {
  testWidgets('the rule is a 3px bar in the colour it is given',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: TriageRule(color: Color(0xFFCB2635), height: 40)),
        ),
      ),
    );
    expect(tester.getSize(find.byType(TriageRule)).width, 3);
    expect(tester.getSize(find.byType(TriageRule)).height, 40);
  });

  testWidgets('it is invisible to assistive technology', (WidgetTester tester) async {
    // It encodes severity that the adjacent label already states, so a screen
    // reader announcing it would be noise.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TriageRule(color: Color(0xFFCB2635), height: 40),
        ),
      ),
    );
    expect(find.byType(ExcludeSemantics), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

Run: `flutter test test/triage_rule_test.dart`
Expected: FAIL — `triage_rule.dart` does not exist.

- [ ] **Step 3: Implement it**

```dart
import 'package:flutter/material.dart';

/// A short vertical bar in a triage colour, sitting on the leading edge of the
/// thing it qualifies.
///
/// This is the app's one piece of deliberate ornament, and it is used in
/// exactly three places: the SOS banner, the section headings on a condition,
/// and the danger/caution callouts. The pattern was already in the app once —
/// the bar beside "First aid" — so this makes an existing instinct into a
/// system with meaning rather than adding a new decoration. Everything around
/// it stays quiet, which is what lets it read as emphasis at all.
class TriageRule extends StatelessWidget {
  const TriageRule({
    super.key,
    required this.color,
    this.height,
    this.width = 3,
  });

  final Color color;
  final double? height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(width / 2),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run the test**

Run: `flutter test test/triage_rule_test.dart`
Expected: PASS, 2 tests.

- [ ] **Step 5: Apply it at the three sites**

In `callout_box.dart`, put the rule at the leading edge of the `Row` and drop the full border, so the box is defined by its rule rather than outlined:

```dart
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(0, 14, 14, 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TriageRule(color: color),
          const SizedBox(width: 14),
          Icon(icon, color: color, size: 22),
          // ...the rest of the row unchanged
```

Note `CrossAxisAlignment.stretch` — that is what lets the rule take the row's full height without being given one.

In `sos_banner.dart`, add `TriageRule(color: Colors.white.withValues(alpha: 0.5))` as the first child of the `Row`, wrapping the `Row` in `crossAxisAlignment: CrossAxisAlignment.stretch` and adjusting the padding to `EdgeInsetsDirectional.fromSTEB(0, 16, 16, 16)`.

In `condition_detail_screen.dart`, find the existing section heading that already draws a coloured bar and replace that inline `Container` with `TriageRule(color: ...)` so there is one implementation.

- [ ] **Step 6: Run, regenerate, look, commit**

```bash
flutter analyze && flutter test
flutter test test/screens_golden_test.dart --update-goldens
```

Open `detail_dark.png` and `detail_dark_ar.png`. Confirm the rule sits on the **leading** edge in both scripts — i.e. on the right in Arabic. If it is on the left in the Arabic render, an `EdgeInsets` somewhere needs to be `EdgeInsetsDirectional`.

```bash
git add -A
git commit -m "Make the leading severity bar a system

The bar beside 'First aid' was already the app's instinct; it now has one
implementation, a meaning (triage severity), and exactly three call sites."
```

---

## Task 14: Platform behaviour and controls

**Files:**
- Modify: `lib/app/theme/app_theme.dart` (`pageTransitionsTheme`)
- Modify: `lib/core/platform/adaptive.dart` (haptics + adaptive control helpers)
- Modify: `lib/core/widgets/app_nav_bar.dart` (use the shared haptics helper)
- Modify: `lib/features/health/presentation/kit_screen.dart:51`
- Modify: `lib/features/conditions/presentation/video_player_screen.dart:301`
- Modify: `lib/core/call_action.dart` (haptic on call)
- Test: `test/adaptive_platform_test.dart`

**Interfaces:**
- Consumes: `context.isCupertino` (existing).
- Produces:
  - `void platformSelectionHaptic(BuildContext context)` — `HapticFeedback.selectionClick` on iOS, `lightImpact` on Android.
  - `void platformActionHaptic(BuildContext context)` — `mediumImpact` on iOS, `heavyImpact` on Android. For the call button.
  - `Widget adaptiveSlider({required BuildContext context, required double value, required ValueChanged<double> onChanged, double min, double max})`
  - `Widget adaptiveCheckboxTile({required BuildContext context, required bool value, required ValueChanged<bool?> onChanged, required Widget title, Widget? subtitle})`

- [ ] **Step 1: Write the failing test**

Create `test/adaptive_platform_test.dart`:

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:help_me/app/theme/app_theme.dart';
import 'package:help_me/core/platform/adaptive.dart';

Future<void> _pumpWith(
  WidgetTester tester,
  TargetPlatform platform,
  Widget Function(BuildContext) builder,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(const Locale('en')).copyWith(platform: platform),
      home: Scaffold(body: Builder(builder: builder)),
    ),
  );
}

void main() {
  group('page transitions', () {
    test('iOS gets the Cupertino builder and Android the zoom builder', () {
      // Zoom is also what predictive back animates against on Android.
      final ThemeData ios =
          AppTheme.light(const Locale('en')).copyWith(platform: TargetPlatform.iOS);
      expect(
        ios.pageTransitionsTheme.builders[TargetPlatform.iOS],
        isA<CupertinoPageTransitionsBuilder>(),
      );
      expect(
        ios.pageTransitionsTheme.builders[TargetPlatform.android],
        isA<ZoomPageTransitionsBuilder>(),
      );
    });
  });

  group('adaptive slider', () {
    testWidgets('iOS renders a CupertinoSlider', (WidgetTester tester) async {
      await _pumpWith(
        tester,
        TargetPlatform.iOS,
        (BuildContext c) => adaptiveSlider(
          context: c,
          value: 0.5,
          onChanged: (_) {},
        ),
      );
      expect(find.byType(CupertinoSlider), findsOneWidget);
    });

    testWidgets('Android renders a Material Slider', (WidgetTester tester) async {
      await _pumpWith(
        tester,
        TargetPlatform.android,
        (BuildContext c) => adaptiveSlider(
          context: c,
          value: 0.5,
          onChanged: (_) {},
        ),
      );
      expect(find.byType(Slider), findsOneWidget);
      expect(find.byType(CupertinoSlider), findsNothing);
    });
  });

  group('adaptive checkbox tile', () {
    testWidgets('iOS uses the Cupertino checkbox', (WidgetTester tester) async {
      await _pumpWith(
        tester,
        TargetPlatform.iOS,
        (BuildContext c) => adaptiveCheckboxTile(
          context: c,
          value: true,
          onChanged: (_) {},
          title: const Text('Gauze'),
        ),
      );
      final CheckboxListTile tile =
          tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
      expect(tile.checkboxSemanticLabel, isNull);
      expect(find.byType(CheckboxListTile), findsOneWidget);
    });
  });

  group('haptics', () {
    testWidgets('the two platforms fire different feedback for an action',
        (WidgetTester tester) async {
      final List<String> calls = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            calls.add('${call.arguments}');
          }
          return null;
        },
      );
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null));

      for (final TargetPlatform p in <TargetPlatform>[
        TargetPlatform.iOS,
        TargetPlatform.android,
      ]) {
        await _pumpWith(tester, p, (BuildContext c) {
          platformActionHaptic(c);
          return const SizedBox.shrink();
        });
        await tester.pump();
      }

      expect(calls.length, 2);
      expect(calls[0], isNot(calls[1]));
    });
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

Run: `flutter test test/adaptive_platform_test.dart`
Expected: FAIL — `adaptiveSlider`, `adaptiveCheckboxTile`, `platformActionHaptic` undefined, and `pageTransitionsTheme` is not set.

- [ ] **Step 3: Add the transitions to `app_theme.dart`**

Inside `ThemeData(...)`:

```dart
      // Set explicitly rather than left to the ambient default: the Android
      // entry must be the zoom builder, which is what the platform's
      // predictive-back gesture animates against.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        },
      ),
```

- [ ] **Step 4: Add the helpers to `adaptive.dart`**

```dart
/// The feedback each platform expects when a selection changes.
///
/// iOS and Android disagree about intensity: iOS's selection click is lighter
/// than Android's, and matching each is a large part of what makes a Flutter
/// app stop feeling ported.
void platformSelectionHaptic(BuildContext context) {
  if (context.isCupertino) {
    HapticFeedback.selectionClick();
  } else {
    HapticFeedback.lightImpact();
  }
}

/// The feedback for a consequential action — placing a call, above all.
void platformActionHaptic(BuildContext context) {
  if (context.isCupertino) {
    HapticFeedback.mediumImpact();
  } else {
    HapticFeedback.heavyImpact();
  }
}

/// A slider in the platform's own style. Flutter ships no adaptive
/// constructor for this one.
Widget adaptiveSlider({
  required BuildContext context,
  required double value,
  required ValueChanged<double> onChanged,
  double min = 0.0,
  double max = 1.0,
}) {
  if (context.isCupertino) {
    return CupertinoSlider(
      value: value,
      min: min,
      max: max,
      onChanged: onChanged,
    );
  }
  return Slider(value: value, min: min, max: max, onChanged: onChanged);
}

/// A checkable row in the platform's own style.
Widget adaptiveCheckboxTile({
  required BuildContext context,
  required bool value,
  required ValueChanged<bool?> onChanged,
  required Widget title,
  Widget? subtitle,
}) {
  return CheckboxListTile.adaptive(
    value: value,
    onChanged: onChanged,
    title: title,
    subtitle: subtitle,
    controlAffinity: context.isCupertino
        ? ListTileControlAffinity.trailing
        : ListTileControlAffinity.leading,
  );
}
```

Add `import 'package:flutter/services.dart';` for `HapticFeedback`.

> `controlAffinity` is the substantive difference here, not just the glyph: iOS puts a checkmark on the trailing edge of a list row, Android a checkbox on the leading edge.

- [ ] **Step 5: Adopt the helpers**

- `app_nav_bar.dart:68-76`: replace the inline `if (context.isCupertino)` haptics block with `platformSelectionHaptic(context)`.
- `kit_screen.dart:51`: replace `CheckboxListTile(...)` with `adaptiveCheckboxTile(context: context, ...)`.
- `video_player_screen.dart:301`: replace `Slider(...)` with `adaptiveSlider(context: context, ...)`, passing the existing min/max.
- `call_action.dart`: add `platformActionHaptic(context);` immediately before the dial is launched.

- [ ] **Step 6: Run everything**

```bash
flutter analyze && flutter test test/adaptive_platform_test.dart
flutter test
```
Expected: analyze clean; adaptive tests pass; full suite green.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "Split page transitions, sliders, checkboxes and haptics by platform

Each platform gets its own transition, control affinity and feedback
intensity. Everything branches on ThemeData.platform, so a test can drive
both sides."
```

---

## Task 15: Android edge-to-edge, predictive back, and the splash

The last of the platform work, and the one piece that cannot be fully verified by a golden — it needs a device or emulator.

**Files:**
- Modify: `lib/app/app.dart`
- Modify: `lib/main.dart`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `flutter_native_splash.yaml`

**Interfaces:**
- Consumes: `AppSurfaces` (Task 3).
- Produces: no new API.

- [ ] **Step 1: Enable edge-to-edge in `main.dart`**

After `WidgetsFlutterBinding.ensureInitialized();`:

```dart
  // Draw behind the system bars. Android 15 removed the opt-out, so an app
  // that does not handle this gets it done to it anyway — better to control it.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
```

Add `import 'package:flutter/services.dart';`.

- [ ] **Step 2: Drive the overlay style from the theme in `app.dart`**

Wrap the `MaterialApp` so the status-bar icons follow the effective brightness. Today this is set in exactly one screen and hardcoded to `dark`, which is wrong the moment the theme is dark.

```dart
    final Brightness platformBrightness =
        MediaQuery.platformBrightnessOf(context);
    final bool dark = switch (settings.themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => platformBrightness == Brightness.dark,
    };

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            dark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: MaterialApp(
        // ...unchanged
      ),
    );
```

While here, remove the hardcoded `SystemUiOverlayStyle.dark` from `emergency_card_screen.dart:62-63` **only if** that screen is not deliberately forcing a light-on-dark card. Read the surrounding code first: if the card is always a light surface regardless of theme, the override is correct and should stay.

- [ ] **Step 3: Enable predictive back**

In `android/app/src/main/AndroidManifest.xml`, add to the `<application>` element:

```xml
        android:enableOnBackInvokedCallback="true"
```

- [ ] **Step 4: Update the splash colours**

In `flutter_native_splash.yaml`, change both dark colours from the retired `#111317` to the new `bg`:

```yaml
  color_dark: "#0C0F13"
  android_12:
    image: assets/branding/icon_1024.png
    icon_background_color: "#FFFFFF"
    icon_background_color_dark: "#0C0F13"
```

Then regenerate:
```bash
dart run flutter_native_splash:create
```

- [ ] **Step 5: Verify on a device — goldens cannot cover this**

```bash
flutter devices
flutter run -d <android-device>
```

Check, in the running app:
1. **No content trapped under the status bar or the gesture pill.** The nav bar's bespoke inset maths (`app_nav_bar.dart:87-88`) is the most likely casualty; it clamps to a third of the bottom view padding, which edge-to-edge changes.
2. **Status-bar icons are legible in both themes.** Toggle Settings → Appearance → Light/Dark and watch them invert.
3. **Predictive back works:** start a back swipe from a condition detail screen and hold — the screen behind should be revealed rather than nothing happening.
4. **Launch shows no white or pale flash** in dark mode.

Then on iOS, confirm the swipe-back gesture works from a detail screen and that transitions slide horizontally rather than zooming.

- [ ] **Step 6: Run the full suite and commit**

```bash
flutter analyze && flutter test
```

```bash
git add -A
git commit -m "Go edge-to-edge on Android, with predictive back

The overlay style now follows the effective theme brightness from the app
root; it was previously set in one screen and hardcoded to dark, which was
wrong as soon as the theme was. Also updates the splash to the new
background so launch does not flash the retired colour."
```

---

## Task 16: Final review pass

**Files:** none — this is the read-through.

- [ ] **Step 1: Full suite and analyzer**

```bash
flutter analyze
flutter test
```
Expected: analyze clean; **at least 179 + the new tests** passing. Record the number.

- [ ] **Step 2: Look at all 18 screen goldens against the Task 1 baseline**

```bash
git log --oneline --all -- test/goldens/screens | tail -1   # the baseline commit
git show <baseline-sha>:test/goldens/screens/home_dark.png > /tmp/home_dark_before.png
```

Open before and after side by side for `home_dark`, `settings_dark`, `emergency_dark`, `detail_dark`, `learn_dark`, and the three `_dark_ar` variants. For each, confirm against the spec:
- no muddy or maroon fills anywhere
- cards separate from the background by tone
- red appears only on the SOS banner, call actions, and danger callouts
- Arabic letterforms are unchanged from the baseline
- nothing is clipped or overflowing

- [ ] **Step 3: Check the one thing goldens cannot show**

Run the app on a physical device in a dark room and confirm the SOS banner and call button do not glare. That is the reason the luminance reduction exists, and it cannot be measured from a PNG.

- [ ] **Step 4: Confirm the guarantees still hold**

```bash
grep -rn "Platform.isIOS\|Platform.isAndroid" lib --include="*.dart"   # expect: nothing
grep -rn "withOpacity" lib --include="*.dart"                          # expect: nothing
grep -rn "google_fonts" pubspec.yaml                                   # expect: nothing
git diff main --stat android/app/src/main/AndroidManifest.xml          # expect: one attribute
```

- [ ] **Step 5: Commit anything outstanding**

```bash
git status --short
```
Expected: clean.

---

## Self-Review

**Spec coverage:** §1 triage colour → Tasks 3, 4. §2 dark ladder → Tasks 3, 5, 6, and the splash in 15. §3 geometry → Task 5; typography → Tasks 7, 8. §4 number-as-hero → Task 11; triage rule → Task 13. §5 skeletons → Tasks 9, 10. §6 platform → Tasks 14, 15. §7 chip row → Task 12; nav pill → Task 6. Verification section → Tasks 1, 2, 16. Every spec section maps to a task.

**Type consistency:** `AppSurfaces` fields (`bg`/`surface`/`raised`/`high`/`hairline`/`ink`/`muted`) are used identically in Tasks 2, 3, 5, 6, 9, 10, 15. `AppSemanticColors` triage fields are consistent across Tasks 2, 3, 4, 6, 11, 12, 13. `AppTheme.light(Locale)` is introduced in Task 8 and every later task's test code passes a locale. `AppRadii.xs/sm/md/lg/pill` is defined in Task 5 and consumed from Task 6 onward — note Task 6 depends on Task 5 for `AppRadii.xs`, so they must run in order.

**Known ordering constraint:** Task 3 deliberately leaves the tree non-compiling and Task 4 repairs it. These two must not be reordered or run in parallel.
