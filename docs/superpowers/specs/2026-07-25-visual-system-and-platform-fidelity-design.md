# Help Me 4.0 · Phase B — Visual System & Platform Fidelity

**Date:** 2026-07-25
**Status:** approved, ready for planning
**Branch:** `revamp/help-me-2.0`
**Siblings:** [`2026-07-25-help-me-3.0-design.md`](2026-07-25-help-me-3.0-design.md) ·
[`2026-07-25-child-infant-mode-design.md`](2026-07-25-child-infant-mode-design.md)

## Problem

The app is feature-complete and reads as generated rather than designed. Rendering every main
screen to a golden and looking at it turns that impression into five specific, verifiable defects.

**1. Red is the primary colour, so red carries no meaning.** `AppTheme` sets
`primary: AppColors.emergencyRed`, and Material sprays it everywhere: the ambulance banner, the
"All" filter chip, the notification switches, the selection checkmarks, the "Start" links on Learn,
the "Off" label, the tip card, the "Add contact" button, and the selected tab. In an app whose
entire job is to distinguish *call an ambulance now* from *read about a sprain*, the one colour
that must mean "act immediately" is spent on a filter chip.

**2. Dark mode is a single surface step over a black void.** `darkBackground #111317` and
`darkSurface #1B1E23` are 6% apart in luminance. Cards separate only by a 1px hairline that is
*darker* than the surface it borders. There is no elevation ladder and no tonal hierarchy, so the
settings screen reads as one flat black sheet. Three compounding faults:

- `ColorScheme.fromSeed(seedColor: emergencyRed)` red-tints every container role the theme does not
  explicitly override, so bottom sheets render maroon in dark and pink in light while the app's own
  tokens are neutral grey. Verified in the rendered disclaimer sheet.
- The SOS gradient (`#FF6B7E → #C1121F`) and the white "Call 123" pill keep their light-mode
  luminance in dark mode, so both glare.
- Category icon tiles are `accent` at low alpha composited over near-black, which turns every one
  of them muddy brown or maroon. Visible on Home, Emergency, and Learn simultaneously.

**3. The geometry and type systems are arbitrary.** Radii of 10/16/22/24/999 are used without a
rule, and nearly every element carries the same 1px border, so nothing has hierarchy. Cairo — an
Arabic typeface — sets all Latin text at one family and five weights, and every heading is `w800`.

**4. There are no skeletons at all.** `topic_gallery.dart:63` calls `Image.asset` bare: no
`frameBuilder`, no `errorBuilder`. The photo area on the condition detail screen is an empty box
until the decode completes, then pops in. The video player shows a spinner inside a black
rectangle. The four `LinearProgressIndicator`s in the codebase express real *progress* (lesson,
quiz, kit, focus mode) and are correct as they stand — they are not loading states.

**5. Platform fidelity is roughly a third done.** Present and good: adaptive date/time pickers,
`AlertDialog.adaptive`, Cupertino action sheets, `SwitchListTile.adaptive`, iOS-only nav-bar blur,
and haptics already differentiated by platform. Absent: explicit page transitions,
`CheckboxListTile` and `Slider` left non-adaptive, no edge-to-edge or `SystemUiOverlayStyle` at the
app root (it appears in exactly one screen), and `android:enableOnBackInvokedCallback` unset, so
Android 13+ predictive back does not work.

Two smaller defects are visible in the same renders: the category chip row clips mid-word
("Bleedin") with no edge treatment, and the selected nav-bar pill in dark mode is
`primary` at 24% alpha over near-black, which composites to a muddy maroon.

## Goals

- Make colour carry urgency information instead of decoration.
- Give dark mode a real elevation ladder and remove every glare and mud artefact.
- Replace arbitrary radii and one-family type with systems that have rules.
- Add skeletons **only** where something is genuinely asynchronous, with motion appropriate to a
  panic context.
- Split platform behaviour and controls so each platform gets its own.
- Hold every existing guarantee: offline, no account, no tracking, no new permissions, no
  regression in the existing test suite.

## Non-goals

- **No screen restructuring.** This is a token-and-treatment pass. Information architecture,
  navigation, copy, and content are unchanged. The one exception is the emergency-number card
  hierarchy (§4), which is a design defect, not a restructure.
- **No pull-to-refresh.** Nothing in the app fetches. A refresh control would be theatre.
- **No skeletons on synchronously-hydrated data.** Health profiles, medicines, and kit state are
  read in `main()` before `runApp`. A skeleton there would be a lie about latency that does not
  exist.
- **No Material 3 dynamic colour.** The palette carries triage meaning; letting the OS wallpaper
  recolour it would destroy that.
- **No separate icon sets per platform.** Rejected during brainstorming: it adds 80+ conditional
  call sites for a small gain.
- No change to the Arabic typeface.

---

## 1 · Colour: triage semantics

Emergency medicine already has a rigorous, universally-understood severity colour system, and this
app is literally a triage tool ("What happened?" → severity). Colour carries the severity.

| Role | Light | Dark | Used for |
|---|---|---|---|
| `immediate` | `#CB2635` | `#FF7A85` | SOS banner, call buttons, danger callout — **and nothing else** |
| `urgent` | `#A05E00` | `#F0B357` | warnings, medicine expiry |
| `safe` | `#0F7857` | `#4FC79B` | success, completed lesson, privacy note |
| `structural` | `#3A5570` | `#96B2C9` | the real `primary`: chips, switches, links, focus rings |

Every light value above is set at the darkest point of its hue that still reads as that colour,
because each must clear 4.5:1 against the *lightest three* rungs of the surface ladder, not just
against white. The first-pass values failed that test and were corrected — see Verification.

`structural` is a deliberately desaturated ink-blue so it competes with neither the brand red nor
any of the ten category accents. It is closest to `accentBlue #2F6FED`, and is kept markedly duller
so the two never read as the same colour.

Brand red is retained as brand: logo, app icon, SOS banner, call actions. It leaves `primary`.

**Implementation.** `AppSemanticColors` gains `immediate`/`onImmediate`, `urgent`, `safe`,
`structural`. The existing `danger`/`warning`/`success`/`info` names are folded into these rather
than kept alongside them — four near-synonyms for the same four roles is how the current sprawl
started. `ColorScheme` sets `primary: structural`, `error: immediate`, and **explicitly specifies
every container role** (`surfaceContainerLowest` through `surfaceContainerHighest`,
`secondaryContainer`, `errorContainer`, `surfaceTint: Colors.transparent`) so `fromSeed` can no
longer tint anything.

## 2 · Dark mode: an elevation ladder

Five steps, and a hairline **lighter** than the surface it borders — which is correct for dark and
the reverse of what the app does now.

```
                 dark        light
bg               #0C0F13     #F4F6F8    behind everything
surface          #14191F     #FFFFFF    cards
raised           #1C232B     #EDF1F5    inputs, nested content, sheets
high             #252E38     #FFFFFF    dialogs, menus, selected nav pill
hairline         #2C353F     #DDE3EA
ink              #E8EDF2     #10151A
muted            #96A3B1     #56626F
```

Measured contrast: `ink` on `surface` is 15.00:1 dark / 18.35:1 light. `muted` on `surface` is
6.87:1 dark / 6.23:1 light, and its worst case anywhere in the ladder is `muted` on `raised` at
6.17:1 dark / 5.49:1 light. All clear AA for body text, which matters more than usual for a
document read under stress in bad light.

Three targeted fixes on top of the ladder:

- **Luminance reduction, and an existing failure fixed.** The SOS banner sets white text over the
  gradient, and the current light end `#FF6B7E` gives white **2.74:1** — a real accessibility
  failure shipping today, found while verifying this palette. The gradient becomes
  `#C8404F → #8E1620` in light (white at 4.88:1 → 9.19:1) and `#A8323E → #74121A` in dark (6.58:1 →
  11.39:1), which fixes the failure and removes the dark-mode glare in one change. The "Call" pill
  in dark becomes `#E9EEF4` with `#B3202E` text (5.69:1) instead of pure white on saturated red.
- **Icon tiles.** In dark, the tile is `raised` with a 1px `accent` hairline at 24% alpha and the
  icon in a dark-mode-brightened accent — never `accent` at low alpha over near-black. Each of the
  ten category accents gains a dark variant. In light the current `accent @ 10%` on white is kept.
- **Nav-bar selected pill.** `high` surface with `structural` icon and label, replacing
  `primary @ 24%`.

`flutter_native_splash.yaml` `color_dark` and `icon_background_color_dark` move from `#111317` to
`#0C0F13`, and the splash is regenerated so launch does not flash the old background.

## 3 · Geometry and typography

**Radii**, tied to element size rather than chosen per call site:

```
xs    8   icon tiles
sm   12   buttons, inputs
md   18   cards
lg   28   sheets, nav bar
pill      chips only
```

Borders are reserved for interactive surfaces and inputs. Cards separate by tone in dark and by a
single soft shadow (y2, blur 8, 4% black) in light. This removes the "every element is a bordered
rounded rectangle" flatness.

**Typefaces:**

- **Barlow Semi Condensed** (600, 700) — headings and numerals, with tabular figures. Its lineage
  is road and safety signage; the condensed widths let a long English heading and a large number
  like `123` sit tight and confident.
- **IBM Plex Sans** (400, 500, 600) — body and UI. Its instrumentation character suits a clinical
  tool, and it is neither Inter nor a high-contrast serif — the two defaults that make a design
  read as generated.
- **Cairo** (400–700) — unchanged, all roles, Arabic.

Selection is by `Localizations.localeOf(context).languageCode`, resolved once in the theme rather
than per widget. Total added weight after subsetting: ~220KB, bundled, because the app must render
identically offline.

Scale: `display 34/700` · `h1 26/700` · `h2 21/600` · `title 17/600` · `body 15.5/400 lh1.55` ·
`label 14/600` · `caption 12.5/500`. Timer and metronome digits use tabular figures so they do not
jitter between frames.

## 4 · Signature: the number is the hero

On the emergency screen today, "Ambulance" is set large and "123" is small muted text beneath it —
the least important-looking element on a screen whose entire purpose is that number. Inverted: the
number becomes the hero of its card in Barlow Semi Condensed 700, tabular, ~30px, in `ink`, with
the service name above it as a 12.5 label.

One further deliberate flourish and no more: **the triage rule** — a 3px vertical bar in the
item's severity colour on the leading edge of exactly three things: the SOS banner, the section
headings on the condition detail screen, and the danger/warning callout boxes. The pattern already
exists once in the app (the teal bar beside "First aid"), so this makes an existing instinct into a
system with meaning rather than introducing a new ornament. Everything else stays quiet.

## 5 · Skeletons

**Motion.** The default skeleton — a grey block with a diagonal gradient sweeping across it — is
exactly the generated-looking pattern to avoid, and in a panic context a fast shimmer is noise.
Instead: a slow breathing pulse, opacity 0.55 → 1.0 over 1400ms on `Curves.easeInOut`, with no
translating gradient. It reads as waiting calmly. When
`MediaQuery.disableAnimationsOf(context)` is true the block renders static.

**Primitive.** `AppSkeleton` in `lib/core/widgets/`: a rounded block taking width, height or aspect
ratio, and radius from the `AppRadii` scale. Fill is `raised` in dark, `#E6EBF1` in light.

**The three honest sites:**

1. **Condition gallery photo** (`topic_gallery.dart:63`). `AppSkeleton` at the image's exact aspect
   ratio, replaced by a 220ms fade-in once the frame is available, plus an `errorBuilder` that
   shows the topic icon on `raised` rather than Flutter's broken-image glyph. `precacheImage` is
   called when a topic card is tapped, so by the time the detail screen builds the image is
   usually already decoded and no skeleton is shown at all.
2. **Video player** (`video_player_screen.dart:96`). The `CircularProgressIndicator.adaptive()` in
   a black rectangle becomes an `AppSkeleton` at 16:9 with a centred play affordance.
3. **Contact import.** A pending state on the button — not a skeleton, because the layout that
   follows is not known in advance.

Nothing else. Every other screen's data is available before its first frame.

## 6 · Platform fidelity: behaviour and controls

Scope confirmed during brainstorming: behaviour and controls diverge; screen layouts do not. All
branching keys off `ThemeData.platform` via the existing `context.isCupertino`, never
`Platform.isIOS`, so it stays overridable in tests.

**iOS / macOS**
- `pageTransitionsTheme`: explicit `CupertinoPageTransitionsBuilder`.
- `CupertinoScrollbar` via `ScrollBehavior`.
- `Slider.adaptive`, `CheckboxListTile.adaptive` (`kit_screen.dart:51`,
  `video_player_screen.dart:301`).
- Haptics extended to the call button, favourite toggle, and quiz answers, using the iOS side of
  the split already established in `app_nav_bar.dart`.

**Android**
- `pageTransitionsTheme`: `ZoomPageTransitionsBuilder`, which is predictive-back compatible.
- Edge-to-edge via `SystemChrome.setEnabledSystemUIMode`, plus an
  `AnnotatedRegion<SystemUiOverlayStyle>` at the app root driven by theme brightness. Today this
  exists only in `emergency_card_screen.dart`, hardcoded to `dark`.
- `android:enableOnBackInvokedCallback="true"` in `AndroidManifest.xml` for predictive back.
- Transparent system navigation bar.

**Both**
- Overscroll behaviour made explicit per platform (stretch on Android, bounce on iOS) rather than
  relying on the ambient default.

## 7 · The two visible defects

- **Chip row.** The category row clips mid-word with a hard edge. A `ShaderMask` fade on the
  trailing edge (direction-aware, so it fades on the correct side in RTL), and the row scrolls to
  bring the selected chip into view.
- **Nav pill in dark.** Covered in §2.

---

## Architecture

The work is almost entirely in the theme layer, which is why it can be broad without being risky.

| File | Change |
|---|---|
| `lib/app/theme/app_colors.dart` | five-step ladders both modes; dark variants for the ten accents; triage roles replace `danger`/`warning`/`success`/`info` |
| `lib/app/theme/app_theme.dart` | `primary: structural`; every container role explicit; radius scale; borders only where interactive; per-platform `pageTransitionsTheme` and `ScrollBehavior` |
| `lib/app/theme/app_typography.dart` | locale-driven family selection; the seven-step scale; tabular figures |
| `lib/core/widgets/app_skeleton.dart` | **new** — the breathing-pulse primitive |
| `lib/core/widgets/triage_rule.dart` | **new** — the 3px leading bar |
| `lib/core/platform/adaptive.dart` | adaptive slider and checkbox helpers; the haptics split extracted from `app_nav_bar.dart` so call sites share it |
| `lib/app/app.dart` | root `AnnotatedRegion`; edge-to-edge setup |
| `lib/core/widgets/sos_banner.dart`, `topic_card.dart`, `callout_box.dart`, `app_nav_bar.dart` | consume the new tokens |
| `topic_gallery.dart`, `video_player_screen.dart` | skeleton sites |
| `emergency_screen.dart` | number-as-hero card |
| `home_screen.dart` | chip row fade and scroll-into-view |
| `kit_screen.dart` | adaptive checkbox |
| `pubspec.yaml`, `assets/fonts/` | Barlow Semi Condensed + IBM Plex Sans |
| `flutter_native_splash.yaml` | dark colours; regenerate |
| `android/app/src/main/AndroidManifest.xml` | predictive back |

Each unit stays independently testable: `AppSkeleton` and `TriageRule` are pure widgets with no
provider dependencies; the token changes are data; the platform helpers take a `BuildContext` and
branch on `Theme.of(context).platform`, so a test can drive both branches by wrapping in a themed
subtree.

## Verification

Golden rendering is the acceptance mechanism, not a nice-to-have: **no visual change is done until
its golden has been rendered and looked at.**

- `test/screens_golden_test.dart` — a permanent harness (promoted from the throwaway
  `_scratch_screens_golden_test.dart` used to diagnose this work) rendering Home, Emergency,
  Learn, Health, Settings, and Condition detail in light, dark, and dark-RTL.
- `test/skeleton_golden_test.dart` — each skeleton site in its loading state, both modes.
- A contrast test computing the real WCAG ratio for every (foreground, surface) pair the design
  permits — `ink`, `muted`, and the four triage roles against all five ladder rungs in both modes,
  plus white against both ends of both banner gradients — and asserting each clears 4.5:1. This
  test is what caught three failures in the first-pass palette: light `urgent #B26A00` at 4.24:1 on
  white, light `immediate #D42B3A` at 4.40:1 on `raised`, light `safe #12805F` at 4.32:1 on
  `raised`, and the shipping `#FF6B7E` banner end at 2.74:1. The corrected values in §1 and §2 are
  measured, and the test exists so the next palette edit cannot reintroduce the same class of bug.
- Widget tests driving `TargetPlatform.iOS` and `TargetPlatform.android` through the same
  adaptive call sites, asserting each renders its own control.
- The existing suite must stay green. Tests asserting on removed semantic colour names
  (`danger`/`warning`/`success`/`info`) are updated to the triage names — a rename, not a
  behaviour change.

## Risks

- **Removing `primary: emergencyRed` touches every screen.** This is the point of the change, and
  goldens across six screens in three configurations are what make it safe to land.
- **Two new font families change every text metric.** Line heights and any hardcoded height or
  width near text need re-checking against goldens, RTL included. Arabic is unaffected — Cairo
  does not change.
- **Barlow Semi Condensed and IBM Plex Sans licensing.** Both are OFL. Licence files ship in
  `assets/fonts/` and are recorded in `assets/CREDITS.md` alongside Cairo.
- **Edge-to-edge can push content under the system bars.** Every screen needs a `SafeArea` or
  inset check; the nav bar's existing bespoke inset maths in `app_nav_bar.dart:87-88` is the most
  likely thing to break and must be re-rendered on a device with a home indicator.
