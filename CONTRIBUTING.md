# Contributing to Help Me · ساعِدني

Thank you for wanting to help. Please read the section that matches what you
want to change — the bar for medical content is deliberately higher than the bar
for code.

---

## Before anything else

```bash
git clone https://github.com/aymanaboelela/Help-Me-App.git
cd Help-Me-App
flutter pub get
flutter test        # everything must be green before you start
```

Requirements: Flutter ≥ 3.41, JDK 17 for Android, Xcode 15+ for iOS.

Every pull request must pass:

```bash
flutter analyze --fatal-infos    # zero issues, no exceptions
flutter test                     # 308 tests
```

CI runs exactly these two, plus an Android and an iOS build.

**Please do not run `dart format` over the repository.** This codebase is written
in the pre-3.8 formatter style, and Dart 3.8 changed the default to "tall
style" — running the current formatter rewrites 73 of 106 files. Match the
surrounding code by hand instead. If we ever adopt tall style it will be one
commit that does nothing else.

---

## Changing medical content

This is the part that can hurt someone, so it has its own rules.

A change to any first-aid step, callout, quiz answer, lesson, or age-specific
technique **must** come with a citation to a recognised body — St John Ambulance,
the Red Cross or Red Crescent, the American Heart Association, the Resuscitation
Council, the NHS, or the WHO. A link to a hospital blog, a news article, or a
YouTube video is not a source.

1. Add or update the entry in `docs/medical_sources.md`, naming the organisation
   and the guideline.
2. Where sources disagree, **teach the safer action** and say so in the PR.
3. Never remove a "call the emergency number" step to make a flow shorter.
4. Anything age-specific — infant, child, adult — must state which age band the
   source covers. An adult technique applied to a baby is a specific and
   well-documented way to cause harm.

Content lives in `lib/features/conditions/data/` and is plain Dart data. Adding
a condition needs no new UI code — one catalogue entry, plus its media.

### Both languages, always

Every user-facing string exists in Arabic **and** English:

- **UI chrome** → `lib/l10n/app_en.arb` and `app_ar.arb`.
- **Medical content** → a `LocalizedText(en:, ar:)` value, both languages in the
  same declaration.

The test suite asserts `LocalizedText.isComplete` across every catalogue. A
missing translation **fails the build**; it does not fall back silently, because
a first-aid step that silently appears in the wrong language is worse than one
that is obviously missing.

If you can only write one of the two languages, open the PR anyway and say so.
Someone will pair with you on the other.

---

## Changing code

- **Feature-first layout.** Nothing in `features/` may import from another
  feature. Anything shared moves down into `core/`.
- **State lives in a Riverpod provider**, not in a widget, and every provider is
  overridable so tests never need a real keychain, a real notification, or a
  real network.
- **Write the test first.** The suite is Given–When–Then and is weighted towards
  what would actually hurt someone.
- **Comments explain why, not what.** The codebase is consistent about this;
  please match it.

### Accessibility and RTL are not optional

Any new screen has to survive all four of these before it is done:

- Arabic, right-to-left — layout, numerals and icon direction all mirror.
- The system text scale turned up.
- Dark theme.
- A screen reader — every control carries a semantic label.

There is a contrast test (`test/contrast_test.dart`) that measures colour pairs
in code rather than trusting anyone's eye. If you add a colour, add it there.

### Goldens

`flutter test --update-goldens` regenerates the golden images. **Look at the
diff before you commit it.** A golden updated without being examined is a golden
that no longer tests anything.

---

## Security

Never commit signing material. `key.properties`, `*.jks` and `*.keystore` are
ignored in two places and a gitleaks job scans the full history — but the
ignore file is a safety net, not a plan.

To report a vulnerability, see [`SECURITY.md`](SECURITY.md). Please do not open
a public issue for one.

---

## Commit messages and pull requests

Write the subject line as what the change does to the app, in the imperative and
without a type prefix — the existing history is the reference:

```
Add the for-children filter to the home screen
Measure contrast in code instead of judging it by eye
Stop the dark-mode mud, and put the red back on the red services
```

Keep a pull request to one idea. If you cannot describe it in one sentence, it
is probably two pull requests.

---

## What is unlikely to be merged

- Analytics, crash reporting, advertising, or any other network call. The claim
  that this app has no server is load-bearing; it is in the store listing, the
  privacy policy, and the reason some people install it at all.
- An account system, or a cloud sync for health data.
- A location permission. "Near me" works without one on purpose.
- A dependency that duplicates something already in the tree.
- Medical content without a source.

If you think one of these is genuinely right, open an issue and make the
argument before writing the code.

---

## Code of conduct

Participation is covered by [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).
