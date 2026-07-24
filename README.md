<div align="center">

<img src="assets/branding/icon_1024.png" width="120" alt="Help Me logo" />

# Help Me · ساعِدني

**A free, offline, bilingual (Arabic / English) first-aid & emergency guide.**
Calm, clear, step-by-step help when it matters most.

</div>

---

## نظرة عامة | Overview

**عربي:** «ساعِدني» تطبيق إسعافات أولية مجاني يعمل **دون إنترنت** بالكامل، ويقدّم خطوات واضحة
وهادئة لأكثر من ١٥ حالة طارئة، بالإضافة إلى أرقام الطوارئ المصرية وزر اتصال سريع بالإسعاف.
التطبيق ثنائي اللغة (عربي/إنجليزي) ويدعم الوضع الليلي.

**English:** *Help Me* is a free first-aid app that works fully **offline** and gives clear,
calm, step-by-step guidance for 17 emergencies, plus Egyptian emergency numbers and a one-tap
ambulance button. It is fully bilingual (Arabic / English) with light & dark themes.

> ⚠️ **Medical disclaimer / تنبيه طبي:** This app is for **education only** and is **not** a
> substitute for professional medical care. In a real emergency call your local emergency number
> immediately. — التطبيق لأغراض تعليمية فقط ولا يُغني عن الرعاية الطبية المتخصصة؛ في الطوارئ اتصل
> برقم الطوارئ فورًا.

## المميزات | Features

- 🩹 **17 first-aid topics** — swallowed tongue, bleeding, fainting, burns, diabetic coma, snake
  bite, seizures, **CPR, choking, drowning, poisoning, electric shock, heat stroke, fractures,
  heart attack, stroke, and severe allergy (anaphylaxis)**.
- 🌍 **Fully bilingual** — Arabic & English with correct RTL/LTR layout. Every step is translated.
- 📴 **Works offline** — content and the Cairo font are bundled; no network needed.
- ❤️ **CPR metronome** — a heartbeat pulse with a click + haptic at 100–120 bpm to pace compressions.
- 🔊 **Read-aloud (TTS)** — the steps read out loud, bilingual, so your hands stay free.
- 🎯 **Focus mode** — one big step at a time, swipe through, easier under stress.
- ⏱️ **Emergency timer** — a stopwatch that alerts at 5 minutes (e.g. for seizures).
- ☎️ **Personal ICE contacts** — save up to 5 emergency contacts locally, one-tap to call.
- 🌎 **Multi-country numbers** — Egypt, Saudi Arabia, UAE, and international; switchable.
- 🏥 **Nearest hospital** — opens maps to hospitals near you (no location stored).
- 🔎 **Instant search** across all conditions in either language, plus **recently viewed**.
- ⭐ **Favorites** — save the conditions you care about for one-tap access in an emergency.
- 📌 **Home-screen quick actions** — long-press the app icon to call an ambulance or open numbers.
- 🚑 **SOS button** — a prominent call-ambulance button that respects your selected country.
- 🌗 **Light / dark / system theme** and a language switch.
- ⚕️ A first-launch **medical disclaimer** and a clear per-screen safety note.
- 🔒 **No ads, no tracking, no account, no data collection.**

## الرحلة | Screens

`Splash → Home (search + categories + SOS) → Condition detail (steps + callouts) → Emergency numbers → Favorites → Settings → About`

## Tech & architecture

| Area | Choice |
| --- | --- |
| Framework | Flutter 3.41 · Dart 3 (Material 3) |
| State | [Riverpod](https://riverpod.dev) (`Notifier` / `Provider`) |
| Persistence | `shared_preferences` (theme, language, favorites, disclaimer) |
| Localization | Flutter `gen_l10n` ARB files (UI) + typed `LocalizedText` (medical content) |
| Branding | Custom SVG logo → generated launcher icons & native splash |
| Font | Cairo (bundled, SIL OFL) |
| Calling / share / rating | `url_launcher` · `share_plus` · `in_app_review` |

```
lib/
├── main.dart                 # bootstrap (loads SharedPreferences)
├── app/                      # MaterialApp, theme, root scaffold (bottom nav)
├── core/                     # LocalizedText, dialer, shared widgets
├── l10n/                     # app_en.arb / app_ar.arb (+ generated)
├── features/
│   ├── splash · home · favorites · settings · about
│   ├── conditions/           # model + data (17 topics) + detail screen
│   └── emergency/            # Egyptian numbers + screen
└── providers/                # settings · favorites · search
```

**Design principle:** the 17 topics are **data, not screens**. Home, search, favorites, and the
detail view all read from one immutable catalogue (`kFirstAidTopics`), so adding a condition is a
single data entry — no new UI code.

## Getting started

```bash
flutter pub get
flutter gen-l10n          # generates AppLocalizations (also runs on build)
flutter run
```

Requires Flutter ≥ 3.4. The Android project uses **AGP 8.9.1 / Gradle 8.11.1 / Kotlin 2.2.20**
(JDK 17+).

## Quality

```bash
flutter analyze     # 0 issues (strict lints in analysis_options.yaml)
flutter test        # 29 tests: content integrity, providers, widgets
```

Tests cover: bilingual data completeness & unique ids, search matching (AR/EN), favorites &
settings persistence, category filtering, home rendering, search filtering, detail navigation,
RTL rendering, and the first-launch disclaimer.

## Publishing

The app is configured for the stores under the id **`com.helpme.help`** with generated icons,
native splash, and localized app names (Help Me / ساعِدني). See **[`store/`](store/)** for the
Google Play & App Store listing copy (AR + EN) and **[`store/PUBLISHING.md`](store/PUBLISHING.md)**
for the step-by-step checklist. Actual submission needs the owner's Apple Developer & Google Play
accounts and a signing keystore. Privacy policy: **[`PRIVACY_POLICY.md`](PRIVACY_POLICY.md)**
(the app collects **no** personal data).

## Credits

- Original concept: **Ayman Abo El Ela** · original UI: Salma Salama.
- 2.0 rebuild: new architecture, brand, bilingual content, expanded first-aid topics, and tests.
- First-aid guidance follows widely taught standards and is intentionally conservative.
- Cairo font © The Cairo Project Authors, [SIL Open Font License 1.1](assets/fonts/OFL.txt).

## License

Application code is released under the MIT License (see [`LICENSE`](LICENSE)).
