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

### In an emergency
- 🩹 **17 first-aid topics** — swallowed tongue, bleeding, fainting, burns, diabetic coma, snake
  bite, seizures, **CPR, choking, drowning, poisoning, electric shock, heat stroke, fractures,
  heart attack, stroke, and severe allergy (anaphylaxis)**.
- 🖼️ **23 step illustrations** drawn for this app — hand position for CPR, the recovery position,
  abdominal thrusts, tourniquet placement and more. Original work, so no third-party copyright.
- ▶️ **30 videos from recognised bodies** — St John Ambulance, the Red Cross, the American Heart
  Association (Arabic), Mayo Clinic and the NHS — played **inside the app**, every id verified
  against YouTube's public data so the channel shown is the one that published it.
- ❤️ **CPR metronome** — a heartbeat pulse with a click + haptic at 100–120 bpm.
- 🔊 **Read-aloud** — the steps read out in the app's own language, following along step by step.
- 🎯 **Focus mode** · ⏱️ **emergency timer** · ☎️ **personal ICE contacts** · 🌎 **multi-country numbers**.
- 📍 **Near me** — hospitals, pharmacies, blood banks and clinics in your own maps app. **No
  location permission is ever requested.**

### Every other day
- 🎓 **Learn** — a daily first-aid tip (one per day, no repeats within a month), eight short
  lessons, and a quiz that explains the reason behind every answer, right or wrong.
- 🔥 **Streak & badges** — gentle: it grows by turning up and quietly resets. No loss warnings.
- 🪪 **Medical cards** for up to six people, with an emergency view — high contrast, large type,
  and a plain-text QR code a paramedic can read with any camera.
- 💊 **Medicine cabinet** — warns 30 days before anything expires, plus daily dose reminders.
- 🧰 **First-aid kit checklist** — 25 items with a readiness bar.
- 🩸 **Blood donation countdown** — 90 days from a recorded donation, with a nudge when eligible.

### Throughout
- 🌍 **Fully bilingual** — Arabic & English with correct RTL/LTR layout. Every step is translated.
- 📴 **Works offline** — content, illustrations and fonts are bundled. Internet is only used for video.
- 📱 **Native on both platforms** — Cupertino pickers, sheets and dialogs on iOS; Material on Android.
- 🔒 **Health data is encrypted on-device** (iOS Keychain / Android encrypted storage) and never
  leaves the phone. **No ads, no tracking, no account, no data collection.**
- 🌍 **Light / dark / system theme**, a language switch, and a first-launch medical disclaimer.

## الرحلة | Screens

`Splash → Home (search + categories + SOS + favorites) → Condition detail (illustrations + steps + video)`
`Learn (tip + lessons + quiz) · Emergency (numbers + ICE + near me) · Health (cards + medicines + kit) · Settings`

## Tech & architecture

| Area | Choice |
| --- | --- |
| Framework | Flutter 3.41 · Dart 3 (Material 3) |
| State | [Riverpod](https://riverpod.dev) (`Notifier` / `Provider`) |
| Persistence | `shared_preferences` (theme, language, favorites, disclaimer) |
| Localization | Flutter `gen_l10n` ARB files (UI) + typed `LocalizedText` (medical content) |
| Branding | Custom SVG logo → generated launcher icons & native splash |
| Font | Cairo (bundled, SIL OFL) |
| Secure storage | `flutter_secure_storage` (Keychain / Android encrypted storage) |
| Notifications | `flutter_local_notifications` + `timezone`, all scheduled locally |
| Video | `youtube_player_iframe`, in-app, no API key |
| Calling / share / rating / QR | `url_launcher` · `share_plus` · `in_app_review` · `qr_flutter` |

```
lib/
├── main.dart                 # bootstrap (preferences + encrypted health data)
├── app/                      # MaterialApp, theme, root scaffold (5 tabs)
├── core/                     # LocalizedText, media, speech, maps, platform-adaptive UI
├── l10n/                     # app_en.arb / app_ar.arb (+ generated)
├── features/
│   ├── splash · home · favorites · settings · about
│   ├── conditions/           # 17 topics + media catalogue + detail screen
│   ├── learn/                # tips · lessons · quiz
│   ├── health/               # medical cards · medicines · first-aid kit
│   ├── nearby/               # maps searches + blood donation
│   └── emergency/            # country numbers + ICE contacts
├── services/                 # secure store · reminders + reminder planning
└── providers/                # settings · favorites · search · health · learn
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
flutter test        # 173 tests: content integrity, providers, widgets, goldens
```

Tests cover: bilingual completeness and unique ids across every catalogue (topics, media, tips,
lessons, quiz, kit), that each referenced illustration exists on disk, video id format and language
ordering, medicine expiry maths, reminder planning through a fake so no real notification fires,
encrypted-store round-trips, streak and badge logic, blood-donation eligibility, RTL rendering, and
the navigation bar rendered to golden images.

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
- Category illustrations from [unDraw](https://undraw.co) (free for commercial use), recolored
  to each category's accent. Step illustrations are original work for this app — see
  [`assets/CREDITS.md`](assets/CREDITS.md).
- Videos are linked, not hosted, and belong to the organisations that published them.

## License

Application code is released under the MIT License (see [`LICENSE`](LICENSE)).
