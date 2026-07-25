<div align="center">

<img src="docs/banner.png" alt="Help Me · ساعِدني — first aid that works with no signal, in Arabic and English" width="100%" />

<br />

[![CI](https://github.com/aymanaboelela/Help-Me-App/actions/workflows/ci.yml/badge.svg)](https://github.com/aymanaboelela/Help-Me-App/actions/workflows/ci.yml)
[![Secret scan](https://github.com/aymanaboelela/Help-Me-App/actions/workflows/secret-scan.yml/badge.svg)](https://github.com/aymanaboelela/Help-Me-App/actions/workflows/secret-scan.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Tests](https://img.shields.io/badge/tests-308%20passing-2A9D8F)](#quality)
[![Analyzer](https://img.shields.io/badge/flutter%20analyze-0%20issues-2A9D8F)](analysis_options.yaml)
[![Offline](https://img.shields.io/badge/works-offline-E63946)](#offline-by-construction)
[![Permissions](https://img.shields.io/badge/permissions-4-E63946)](#the-permission-budget)
[![Privacy](https://img.shields.io/badge/tracking-none-111317)](PRIVACY_POLICY.md)
[![License](https://img.shields.io/badge/license-MIT-555)](LICENSE)

**A free, offline, bilingual first-aid and emergency guide for Android and iOS.**

**تطبيق إسعافات أولية مجاني يعمل دون إنترنت، بالعربية والإنجليزية.**

</div>

---

## Table of contents

**Understanding it** ·
[Overview](#overview--نظرة-عامة) ·
[Screenshots](#screenshots) ·
[What it does](#what-it-does) ·
[The 20 conditions](#the-20-conditions)

**How it is built** ·
[Architecture](#architecture) ·
[Content as data](#content-as-data) ·
[State](#state-how-a-tap-becomes-a-screen) ·
[Bilingual by construction](#bilingual-by-construction) ·
[Offline by construction](#offline-by-construction)

**Trusting it** ·
[Privacy & security](#privacy--security) ·
[The permission budget](#the-permission-budget) ·
[Quality](#quality)

**Working on it** ·
[Getting started](#getting-started) ·
[Project layout](#project-layout) ·
[Building for release](#building-for-release) ·
[Brand](#brand) ·
[Contributing](#contributing) ·
[Credits](#credits) ·
[License](#license)

---

## Overview · نظرة عامة

**English** — *Help Me* is a first-aid app for the minutes before help arrives. It gives clear,
calm, step-by-step guidance for 20 emergencies, works with the phone in aeroplane mode, and is
fully bilingual with correct right-to-left layout in Arabic. Around that emergency core it also
keeps the things you want *before* an emergency: a daily first-aid lesson, encrypted medical cards
for your family, a medicine cabinet that warns you before anything expires, and a first-aid kit
checklist.

**عربي** — «ساعِدني» تطبيق إسعافات أولية للدقائق التي تسبق وصول المساعدة. يقدّم خطوات واضحة وهادئة
لـ ٢٠ حالة طارئة، ويعمل والهاتف في وضع الطيران، وهو ثنائي اللغة بالكامل مع تخطيط صحيح من اليمين
لليسار في العربية. وحول هذا القلب الطارئ يحتفظ أيضًا بما تحتاجه *قبل* الطوارئ: درس إسعاف يومي،
وبطاقات طبية مشفّرة لعائلتك، وخزانة دواء تنبّهك قبل انتهاء الصلاحية، وقائمة مراجعة لحقيبة الإسعافات.

> [!WARNING]
> **Medical disclaimer · تنبيه طبي**
> This app is for **education only** and is **not** a substitute for professional medical care.
> In a real emergency, call your local emergency number immediately.
> التطبيق لأغراض تعليمية فقط ولا يُغني عن الرعاية الطبية المتخصصة؛ في الطوارئ اتصل برقم الطوارئ فورًا.
>
> First-aid guidance in this app follows widely taught standards and is deliberately conservative:
> where sources differ, it teaches the safer action.

### The app in one picture

```mermaid
mindmap
  root((Help Me · ساعِدني))
    In an emergency
      20 conditions
        Adult · Child · Infant
        Photo → diagram → steps
      CPR metronome
      Read aloud
      Focus mode
      Emergency timer
      Call
        ICE contacts
        Country numbers
      Near me
    Every other day
      Learn
        47 daily tips
        8 lessons
        16-question quiz
      Health
        Medical cards
        Medicine cabinet
        Kit checklist
        Blood donation
    Always
      Arabic + English
      Offline
      No account
      No tracking
```

---

## Screenshots

Every image below is rendered from the running widget tree by
[`test/tool/screenshots.dart`](test/tool/screenshots.dart) — they are the real screens, not mockups.

| Home — English, light | Home — العربية, dark | Condition — CPR |
| :---: | :---: | :---: |
| <img src="docs/screenshots/home_light_en.png" width="240" /> | <img src="docs/screenshots/home_dark_ar.png" width="240" /> | <img src="docs/screenshots/condition_cpr_light_en.png" width="240" /> |
| Search, categories, and a one-tap ambulance banner. | The same screen mirrored: layout, numerals and icons all flip. | A real photograph, then the diagram, then the steps. |

| Learn | Emergency — العربية | Condition — النزيف |
| :---: | :---: | :---: |
| <img src="docs/screenshots/learn_light_en.png" width="240" /> | <img src="docs/screenshots/emergency_dark_ar.png" width="240" /> | <img src="docs/screenshots/condition_bleeding_dark_ar.png" width="240" /> |
| A tip a day, eight lessons, a streak that never nags. | Country numbers, personal ICE contacts, "near me". | Dark theme, RTL, and the read-aloud control. |

Regenerate them after any UI change:

```bash
flutter test test/tool/screenshots.dart --update-goldens
```

---

## What it does

### In an emergency

| | |
| --- | --- |
| 🩹 **20 first-aid topics** | Each opens with what the emergency *looks* like, then what to *do*, then the steps — in the order a frightened person needs them. |
| 👶 **Child & infant mode** | CPR, choking, drowning, burns, anaphylaxis and seizures each carry the technique for that age — two fingers and 4 cm for a baby, chest thrusts instead of abdominal ones. A switch on the condition screen picks the age, always opening on **Adult** so it can never be left set to the wrong one. |
| 📷 **14 real photographs** | Bundled so they work offline, with the photographer credited on screen. Three topics carry none on purpose: no honest stock photo of choking, anaphylaxis or stroke recognition exists, and a photo that merely *looks* medical teaches the wrong thing. |
| 🖼️ **23 step illustrations** | Drawn for this app — hand position for CPR, the recovery position, abdominal thrusts, tourniquet placement. Original work, so no third-party copyright. |
| ▶️ **30 videos from recognised bodies** | St John Ambulance, the Red Cross, the American Heart Association (Arabic), Mayo Clinic and the NHS — played **inside the app**. Every id is verified against YouTube's public data, so the channel shown really did publish it. |
| ❤️ **CPR metronome** | A heartbeat pulse with a click and a haptic at 100–120 bpm — the rate you are meant to compress at. |
| 🔊 **Read-aloud** | The steps read out in the app's own language, following along step by step, so you can keep your hands on the casualty. |
| 🎯 **Focus mode** | One step, full screen, huge type. Nothing else on the display. |
| ⏱️ **Emergency timer** | For the things that are measured in minutes: cooling a burn, holding pressure. |
| ☎️ **ICE contacts** | Your own emergency contacts, callable in one tap. |
| 🌎 **Country numbers** | Egypt, Saudi Arabia, the UAE and an international fallback. |
| 📍 **Near me** | Hospitals, pharmacies, blood banks and clinics, opened in your own maps app. **No location permission is ever requested** — the search is handed to the maps app, which already has it. |

### Every other day

| | |
| --- | --- |
| 🎓 **Learn** | A daily first-aid tip drawn from a pool of 47, with no repeats within a month; eight short lessons; and a 16-question quiz that explains the reasoning behind every answer, right or wrong. |
| 🔥 **Streak & badges** | Deliberately gentle. It grows by turning up and quietly resets — no loss warnings, no guilt. |
| 🪪 **Medical cards** | Up to six people: blood type, allergies, conditions, medicines. The emergency view is high-contrast with large type and a plain-text QR code any paramedic can read with any camera — no app required at the other end. |
| 💊 **Medicine cabinet** | Warns 30 days before anything expires, with local daily dose reminders. |
| 🧰 **First-aid kit checklist** | 25 items with a readiness bar, so you find out what's missing before you need it. |
| 🩸 **Blood donation countdown** | 90 days from a recorded donation, with a nudge when you become eligible again. |

### Throughout

- **Fully bilingual** — Arabic and English, with correct RTL/LTR layout. Every medical step is
  translated; a build-time test fails if any string is missing on either side.
- **Works offline** — content, photographs, illustrations and fonts are all bundled. The network is
  used for exactly one thing: playing a video you chose to play.
- **Native on both platforms** — Cupertino pickers, sheets and dialogs on iOS; Material on Android.
- **Light, dark and system themes**, a language switch, and a one-time medical disclaimer.
- **Accessible** — semantic labels on every control, respects the system text scale, and the
  emergency surfaces are built for large type first rather than adapted to it.

---

## The 20 conditions

Grouped as the app groups them. The media column shows what each topic ships with.

| Category | Condition | الحالة | Photo | Diagram | Video | Ages |
| --- | --- | --- | :---: | :---: | :---: | :---: |
| Airway & breathing | Choking | الاختناق (الشرقة) | — | ✅ | ✅ | 👤👦👶 |
| Airway & breathing | Swallowed tongue | بلع اللسان | ✅ | ✅ | ✅ | 👤 |
| Heart | CPR (resuscitation) | الإنعاش القلبي الرئوي | ✅ | ✅ | ✅ | 👤👦👶 |
| Heart | Heart attack | الأزمة القلبية | ✅ | ✅ | ✅ | 👤 |
| Bleeding | Bleeding | النزيف | ✅ | ✅ | ✅ | 👤 |
| Injuries | Burns | الحروق | ✅ | ✅ | ✅ | 👤👦👶 |
| Injuries | Electric shock | الصعق الكهربائي | ✅ | ✅ | — | 👤 |
| Injuries | Fractures | الكسور | ✅ | ✅ | ✅ | 👤 |
| Environmental | Drowning | الغرق | ✅ | ✅ | — | 👤👦👶 |
| Environmental | Heat stroke | ضربة الشمس | ✅ | ✅ | ✅ | 👤 |
| Environmental | Snake bite | لدغة الثعبان | ✅ | ✅ | ✅ | 👤 |
| Medical | Diabetic coma | غيبوبة السكر | ✅ | ✅ | ✅ | 👤 |
| Medical | Epileptic seizures | نوبات الصرع | ✅ | ✅ | ✅ | 👤👦👶 |
| Medical | Fainting | الإغماء | ✅ | ✅ | ✅ | 👤 |
| Medical | Poisoning | التسمم | ✅ | ✅ | ✅ | 👤 |
| Medical | Severe allergic reaction | الحساسية الشديدة | — | ✅ | ✅ | 👤👦👶 |
| Medical | Stroke | الجلطة الدماغية | — | ✅ | ✅ | 👤 |
| Children | Febrile convulsion | تشنج الحرارة | — | — | — | 👦👶 |
| Children | Dehydration in children | الجفاف عند الأطفال | — | — | — | 👦👶 |
| Children | Swallowed object | ابتلاع جسم غريب | — | — | — | 👦👶 |

<sub>👤 adult · 👦 child · 👶 infant</sub>

Three carry no photograph on purpose, and two have no video because no verified upload from a
recognised body covers them. The three paediatric topics are new and carry no media yet — a named
test lists them, so a fourth uncovered topic fails the build rather than slipping in quietly.

See **[`docs/medical_sources.md`](docs/medical_sources.md)** for what each topic follows and what
a clinician should check.

---

## Architecture

A single Flutter target with a layered, feature-first structure. The rule is one arrow deep:
**nothing in `features/` may reach sideways into another feature.** Anything shared moves *down*
into `core/`; anything stateful moves *out* into a Riverpod provider.

```mermaid
flowchart TD
    subgraph APP["app/ — shell"]
        A1["MaterialApp<br/>theme · locale · routes"]
        A2["RootScaffold<br/>five-tab shell + disclaimer"]
    end

    subgraph FEATURES["features/ — one folder per product area"]
        F1[home]
        F2[conditions]
        F3[learn]
        F4[health]
        F5[emergency]
        F6["nearby · favorites<br/>settings · about · tools"]
    end

    subgraph PROVIDERS["providers/ — Riverpod state"]
        P1["settings · favorites · search<br/>health · learn · country<br/>contacts · reminders · recent"]
    end

    subgraph SERVICES["services/ — side effects at the edges"]
        S1[SecureStore]
        S2[Reminders]
        S3[QuickActions]
    end

    subgraph CORE["core/ — shared, feature-agnostic"]
        C1["LocalizedText · media<br/>speech · dialer · maps<br/>adaptive widgets"]
    end

    APP --> FEATURES
    FEATURES --> PROVIDERS
    FEATURES --> CORE
    PROVIDERS --> SERVICES
    PROVIDERS --> CORE
    SERVICES --> CORE

    F1 -.->|"❌ never"| F2

    style APP fill:#E63946,color:#fff,stroke:#C1121F
    style FEATURES fill:#1D9A8A,color:#fff,stroke:#177a6e
    style PROVIDERS fill:#457B9D,color:#fff,stroke:#35617c
    style SERVICES fill:#6D597A,color:#fff,stroke:#54455f
    style CORE fill:#2B2D42,color:#fff,stroke:#1d1f2e
```

| Area | Choice | Why |
| --- | --- | --- |
| Framework | Flutter 3.41 · Dart 3.11 · Material 3 | One codebase, two stores, real native feel on both. |
| State | [Riverpod](https://riverpod.dev) `Notifier` / `Provider` | Testable without a widget tree; every provider is overridable in tests. |
| Persistence | `shared_preferences` | Theme, language, favorites, streak, disclaimer — none of it sensitive. |
| Secure persistence | `flutter_secure_storage` | Health data only: iOS Keychain, Android AES-GCM in the Keystore. |
| Localization | Flutter `gen_l10n` (UI) + typed `LocalizedText` (content) | See [Bilingual by construction](#bilingual-by-construction). |
| Notifications | `flutter_local_notifications` + `timezone` | Scheduled entirely on-device; no push service, no server. |
| Video | `youtube_player_iframe` | In-app playback with no API key and no account. |
| Speech | `flutter_tts` | Reads the steps aloud in the app's current language. |
| Platform glue | `url_launcher` · `share_plus` · `in_app_review` · `qr_flutter` · `quick_actions` | Calling, sharing, rating, QR codes, home-screen shortcuts. |
| Branding | One SVG → every icon | See [Brand](#brand). |
| Font | Cairo, bundled (SIL OFL) | Reads well in both scripts; ships with the app so it works offline. |

---

## Content as data

The 20 topics are **data, not screens**. One immutable catalogue feeds every surface that shows a
condition — which is why adding a condition needs no UI code at all.

```mermaid
flowchart LR
    subgraph SOURCE["lib/features/conditions/data/"]
        D1["topics_original.dart"]
        D2["topics_extended.dart"]
        D3["topics_paediatric.dart"]
        D4["topic_media_data.dart"]
    end

    CAT[["kTopics<br/><i>one immutable catalogue</i>"]]

    D1 --> CAT
    D2 --> CAT
    D3 --> CAT
    D4 -.->|photos · diagrams · videos| CAT

    CAT --> U1[Home list]
    CAT --> U2[Search]
    CAT --> U3[Favorites]
    CAT --> U4[Category browse]
    CAT --> U5[Condition detail]
    CAT --> U6[Read-aloud]
    CAT --> U7[Focus mode]
    CAT --> U8[Quick actions]

    CAT ==>|asserted by| T{{"tests<br/>unique id · both languages<br/>non-empty steps<br/>assets exist on disk"}}

    style CAT fill:#E63946,color:#fff,stroke:#C1121F,stroke-width:3px
    style T fill:#2A9D8F,color:#fff,stroke:#1f7a70
    style SOURCE fill:#f5f6f9,stroke:#c8ccd8,color:#111317
```

```dart
const FirstAidTopic(
  id: 'cpr',
  title: LocalizedText(en: 'CPR (resuscitation)', ar: 'الإنعاش القلبي الرئوي'),
  summary: LocalizedText(
    en: 'Chest compressions and rescue breaths for someone not breathing.',
    ar: 'ضغطات الصدر والتنفس الإنقاذي لمن توقف تنفسه.',
  ),
  category: TopicCategory.cardiac,
  sections: <FirstAidSection>[ /* … steps and callouts … */ ],
);
```

Adding a condition is a single entry in the catalogue plus its media — **no new UI code** — and the
test suite immediately holds it to the same standard as every other topic.

---

## State: how a tap becomes a screen

Nothing is fetched, so every screen is a pure function of state that is already in memory. This is
what happens between tapping a condition and reading step one:

```mermaid
sequenceDiagram
    autonumber
    actor U as User
    participant H as HomeScreen
    participant P as Riverpod providers
    participant C as kTopics catalogue
    participant D as ConditionDetailScreen
    participant T as flutter_tts

    U->>H: taps "CPR"
    H->>P: recentProvider.record('cpr')
    H->>D: push(topic)
    D->>C: sections for topic + age
    Note over D,C: opens on Adult — never<br/>inherits a previous choice
    C-->>D: photo · diagram · steps
    D-->>U: what it looks like → what to do → steps

    opt user switches age
        U->>D: taps 👶 Infant
        D->>C: paediatric variant
        C-->>D: two fingers, 4 cm, 1:5 ratio
    end

    opt user taps read-aloud
        D->>T: speak(step, locale)
        T-->>U: audio, step by step
    end

    opt user taps focus
        D->>U: one step, full screen, huge type
    end
```

The catalogue is `const`, the providers are synchronous, and there is no loading state anywhere in
the emergency path — because a spinner is the last thing you want between someone and a chest
compression.

---

## Bilingual by construction

Two mechanisms, deliberately kept apart:

```mermaid
flowchart TB
    subgraph CHROME["UI chrome — buttons, labels, titles"]
        A1["lib/l10n/app_en.arb"]
        A2["lib/l10n/app_ar.arb"]
        GEN["gen_l10n"]
        A1 --> GEN
        A2 --> GEN
        GEN --> AL["AppLocalizations.of(context)"]
    end

    subgraph CONTENT["Medical content — steps, callouts, tips, quiz"]
        LT["LocalizedText(en: …, ar: …)<br/><i>both languages in one declaration</i>"]
        LT --> RES["text.resolve(locale)"]
    end

    AL --> SCREEN[["Screen"]]
    RES --> SCREEN

    LT ==>|"LocalizedText.isComplete<br/>asserted across every catalogue"| FAIL{{"missing translation<br/>= FAILS THE BUILD"}}

    style CHROME fill:#457B9D,color:#fff,stroke:#35617c
    style CONTENT fill:#1D9A8A,color:#fff,stroke:#177a6e
    style FAIL fill:#E63946,color:#fff,stroke:#C1121F,stroke-width:3px
    style SCREEN fill:#2B2D42,color:#fff
```

Keeping both languages inside a single `LocalizedText(en:, ar:)` declaration is the whole point: a
translation cannot silently drift away from the text it belongs to, because it is written on the
next line. A step, callout, tip, lesson, quiz answer or kit item missing either language **fails
the build** — it does not fall back silently, because a first-aid step that quietly appears in the
wrong language is worse than one that is obviously absent.

RTL is real, not a mirror trick: layout, nav bar, numerals and icon directions all flip, and a
golden test renders the nav bar right-to-left to prove it.

---

## Offline by construction

Everything the app needs in an emergency is in the bundle:

- All 20 topics and their steps — compiled into the binary as Dart data.
- 14 photographs, 23 step illustrations, 6 category illustrations.
- The Cairo font in five weights.
- Emergency numbers for four regions.

```mermaid
flowchart LR
    subgraph DEVICE["📱 the device — everything that matters"]
        direction TB
        BUNDLE["Bundled assets<br/>topics · photos · diagrams<br/>fonts · emergency numbers"]
        PREFS["shared_preferences<br/>theme · language · favorites<br/>streak · disclaimer"]
        KEY["🔒 Keychain / Keystore<br/>medical cards · medicines"]
        NOTIF["Local notifications<br/>scheduled on-device"]
    end

    NET(["🌐 network"])
    YT["YouTube iframe"]
    MAPS["Maps app"]
    DIAL["Dialer"]

    DEVICE -.->|"only when you tap a video"| NET
    NET --> YT
    DEVICE -->|"hands over a search string"| MAPS
    DEVICE -->|"hands over a number"| DIAL

    KEY x--x|"never leaves"| NET

    style DEVICE fill:#1D9A8A,color:#fff,stroke:#177a6e,stroke-width:3px
    style KEY fill:#C1121F,color:#fff,stroke:#8a0d16,stroke-width:2px
    style NET fill:#f5f6f9,stroke:#c8ccd8,color:#111317,stroke-dasharray: 5 5
```

There is no API, no backend, and no configuration to download — so the app behaves identically on a
dead signal, in aeroplane mode, and in a basement.

---

## Privacy & security

> The claim that this app has no server is load-bearing. It is in the store listing, in the privacy
> policy, and it is the reason some people install it at all.

- **No account, no analytics, no ads, no tracking, no telemetry.** There is no server to send
  anything to.
- **Health data is encrypted on-device** — the iOS Keychain, and AES-GCM with RSA-OAEP key wrapping
  in the Android Keystore — and never leaves the phone.
- **Backup and device-transfer are both disabled on Android.** Health data cannot be swept into
  Google's cloud backup. (It also *would not survive* one: the encryption key lives in the Keystore
  and Keystore material is deliberately not backed up, so a restore would produce ciphertext with
  no key. Disabling it is both the private answer and the correct one.)
- **Cleartext traffic is refused on both platforms** — an Android network security config with no
  exceptions and no debug override, and iOS ATS with no arbitrary-loads escape hatch.
- **Reminders keep their text off the lock screen.** A medicine name can disclose a diagnosis to
  anyone who glances at a phone on a desk, so notifications are `private`: you see that something
  is due, the detail waits until you unlock.
- **No location permission is ever requested.** "Near me" hands a search string to your maps app,
  which already has the permission and your trust.
- **No contacts permission is ever requested.** Importing an ICE contact opens the *system* picker,
  which runs outside the app and returns only the one contact you tapped.
- **The emergency QR code is plain text**, so it works with any camera and needs no app or network
  at the receiving end.
- **No signing material is in this repository.** `key.properties`, `*.jks` and `*.keystore` are
  ignored in two separate files, a release build without them falls back to the debug key rather
  than failing open, and a [gitleaks job](.github/workflows/secret-scan.yml) scans the full history
  on every push.

Full policy: [`PRIVACY_POLICY.md`](PRIVACY_POLICY.md) · Reporting: [`SECURITY.md`](SECURITY.md).

### The permission budget

Four permissions ship in the release bundle. That is the entire list, verified against the
packaged manifest rather than the source:

```mermaid
flowchart LR
    subgraph GRANTED["✅ what the app asks for"]
        direction TB
        I["INTERNET<br/><i>the YouTube player, nothing else</i>"]
        N["POST_NOTIFICATIONS<br/><i>medicine & expiry reminders</i>"]
        B["RECEIVE_BOOT_COMPLETED<br/><i>reminders survive a restart</i>"]
        V["VIBRATE<br/><i>the CPR metronome's haptic</i>"]
    end

    subgraph REFUSED["❌ what it deliberately does not"]
        direction TB
        L["ACCESS_FINE_LOCATION<br/><i>maps app already has it</i>"]
        C["READ_CONTACTS<br/><i>system picker instead</i>"]
        CAM["CAMERA · MICROPHONE"]
        S["SCHEDULE_EXACT_ALARM<br/><i>inexact is enough for a dose</i>"]
        ST["READ/WRITE storage"]
    end

    style GRANTED fill:#1D9A8A,color:#fff,stroke:#177a6e,stroke-width:2px
    style REFUSED fill:#f5f6f9,color:#111317,stroke:#c8ccd8,stroke-width:2px,stroke-dasharray: 5 5
```

```bash
# How to check it yourself, after a release build
M=build/app/intermediates/packaged_manifests/release/processReleaseManifestForPackage/AndroidManifest.xml
grep -oE 'uses-permission android:name="[^"]+"' $M | sort -u
```

If a fifth appears, a dependency added it. Find out why before shipping.

---

## Quality

```bash
flutter analyze --fatal-infos   # 0 issues — strict lints, see analysis_options.yaml
flutter test                    # 308 tests across 20 files
```

The suite is written Given–When–Then and is deliberately weighted towards the things that would
actually hurt someone if they broke:

| Area | What is asserted |
| --- | --- |
| **Content integrity** | Every topic, tip, lesson, quiz question and kit item has a unique id and complete Arabic **and** English text. Empty steps fail. |
| **Age variants** | Infant and child steps exist where they are promised, and the age switch always opens on Adult. |
| **Media** | Every referenced illustration exists on disk; every video id is well-formed and listed once; language ordering is correct. |
| **Providers** | Search, favorites, settings, country selection, streak and badge logic, blood-donation eligibility. |
| **Health** | Medicine expiry maths, medical card round-trips through the encrypted store, kit readiness. |
| **Reminders** | Reminder planning runs through a fake, so no real notification is ever scheduled by a test. |
| **Contrast** | Colour pairs are measured against WCAG in code, rather than judged by eye. |
| **Widgets** | Home, health and condition screens build and respond; RTL rendering is exercised, not assumed. |
| **Goldens** | Six main screens, the navigation bar (light, dark, RTL) and the condition gallery are rendered to images and compared. |

Golden images live in [`test/goldens/`](test/goldens/); update them deliberately with
`flutter test --update-goldens` and **look at the diff** before committing.

> **Note on formatting** — this codebase is written in the pre-3.8 Dart formatter style. Dart 3.8
> changed the default to "tall style", which would rewrite 73 of 106 files, so there is no
> `dart format` gate in CI. Match the surrounding code by hand.

---

## Getting started

**Requirements** — Flutter ≥ 3.41, JDK 17 for Android, Xcode 15+ for iOS.

```bash
git clone https://github.com/aymanaboelela/Help-Me-App.git
cd Help-Me-App
flutter pub get
flutter gen-l10n        # generates AppLocalizations (also runs on build)
flutter run
```

**Android toolchain** — AGP 8.9.1 · Gradle 8.11.1 · Kotlin 2.2.20 · minSdk 24 · targetSdk 36.

You do **not** need a signing key to build and run this. A release build without one falls back to
the debug key and says so — see [Building for release](#building-for-release).

---

## Project layout

```
lib/
├── main.dart                    # bootstrap: preferences, encrypted health store, timezone
├── app/
│   ├── app.dart                 # MaterialApp, locale & theme wiring
│   ├── root_scaffold.dart       # the five-tab shell + first-launch disclaimer
│   └── theme/                   # colours, semantic tokens, typography
├── core/
│   ├── localized_text.dart      # the bilingual value type
│   ├── media/                   # topic photo / illustration / video model
│   ├── platform/                # Cupertino-vs-Material adaptive widgets
│   ├── widgets/                 # AppLogo, AppNavBar, SosBanner, TopicCard, CalloutBox
│   ├── speech.dart · speech_text.dart   # TTS + text normalisation for both languages
│   └── dialer.dart · maps.dart · call_action.dart
├── l10n/                        # app_en.arb · app_ar.arb (+ generated)
├── features/
│   ├── splash · home · favorites · settings · about
│   ├── conditions/              # 20 topics, media catalogue, detail screen
│   ├── learn/                   # daily tip · 8 lessons · 16-question quiz
│   ├── health/                  # medical cards · medicines · first-aid kit
│   ├── nearby/                  # maps handoff + blood-donation countdown
│   ├── emergency/               # country numbers + ICE contacts
│   └── tools/                   # CPR metronome · emergency timer · focus mode
├── providers/                   # Riverpod state
└── services/                    # secure store · reminders · quick actions

android/app/
├── build.gradle                 # version from pubspec, signing fallback, R8
├── proguard-rules.pro           # keeps for local notifications, Tink, desugaring
└── src/main/res/xml/            # network security, backup & data-extraction rules

assets/branding/                 # SVG sources + generated 1024px PNGs
assets/photos/ · steps/ · illustrations/ · fonts/
docs/screenshots/                # generated by test/tool/screenshots.dart
docs/medical_sources.md          # what each topic follows, and what to re-check
store/                           # Play & App Store listing copy (AR + EN) + checklist
tool/                            # render_branding.sh — SVG → PNG rasteriser
test/                            # 308 tests + goldens + tool/screenshots.dart
.github/                         # CI, secret scanning, dependabot, issue templates
```

---

## Building for release

Version lives in **exactly one place** — `version:` in `pubspec.yaml`. Neither `build.gradle` nor
`Info.plist` holds a copy; both read it through generated build settings.

```mermaid
flowchart TD
    PUB["pubspec.yaml<br/><b>version: 2.0.0+7</b>"]

    PUB -->|flutter tool writes| LP["android/local.properties<br/>flutter.versionName / versionCode"]
    PUB -->|xcconfig| GX["ios/Flutter/Generated.xcconfig<br/>FLUTTER_BUILD_NAME / NUMBER"]

    LP --> BG["android/app/build.gradle<br/>versionCode 7 · versionName 2.0.0"]
    GX --> IP["Info.plist<br/>CFBundleVersion 7 · Short 2.0.0"]

    KP{"android/<br/>key.properties<br/>present?"}
    BG --> KP
    KP -->|yes| SIGN["signed with the upload key<br/>→ Play accepts"]
    KP -->|no| DEBUG["signed with the DEBUG key<br/>+ loud warning<br/>→ runs on a device, Play refuses"]

    SIGN --> AAB[["app-release.aab"]]
    DEBUG --> AAB
    IP --> IPA[["Runner.ipa"]]

    AAB --> PLAY(["Google Play"])
    IPA --> APPSTORE(["App Store"])

    style PUB fill:#E63946,color:#fff,stroke:#C1121F,stroke-width:3px
    style SIGN fill:#1D9A8A,color:#fff,stroke:#177a6e
    style DEBUG fill:#E9A23B,color:#111317,stroke:#c07f1d
    style KP fill:#2B2D42,color:#fff
    style PLAY fill:#457B9D,color:#fff
    style APPSTORE fill:#457B9D,color:#fff
```

```bash
# Android — Google Play
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols

# iOS — App Store
flutter build ipa --release --obfuscate --split-debug-info=build/symbols
```

`--obfuscate --split-debug-info` renames the Dart symbols and writes the mapping to
`build/symbols/` rather than into the binary. **Keep that directory** for whatever you shipped,
along with R8's `build/app/outputs/mapping/release/mapping.txt` — without both, a crash report from
a user is unreadable.

The full checklist, including generating the upload keystore and what each store's review team
asks, is in **[`store/PUBLISHING.md`](store/PUBLISHING.md)**.

> [!CAUTION]
> Google Play ties an app to its signing key permanently. Lose the keystore or its password and you
> can never update `com.helpme.help` again — not with a support ticket, not with proof of ownership.
> Back it up somewhere that outlives your laptop.

---

## Brand

<img src="assets/branding/icon_1024.png" width="88" align="left" hspace="16" vspace="4" alt="Help Me icon" />

The mark is a first-aid cross with an ECG trace cut through it — red inside the cross, white
outside, so the line reads as one continuous signal running edge to edge. It was chosen over a
heart because it is the only shape that still says *first aid* at 22 pixels, and because a **red
cross on a white ground is the emblem of the Red Cross**, protected by the Geneva Conventions;
both Apple and Google reject apps that use it. Keeping the mark white-on-red carries none of that
restriction.

<br clear="left" />

| Token | Value | Used for |
| --- | --- | --- |
| `emergencyRed` | `#E63946` | Primary seed colour, SOS surfaces |
| `emergencyRedBright` | `#FF6B7E` | Gradient start |
| `emergencyRedDeep` | `#C1121F` | Gradient end, pressed states |
| `medicalTeal` | `#1D9A8A` | Calm/secondary accent |
| `lightBackground` / `darkBackground` | `#F5F6F9` / `#111317` | App ground |
| Type | Cairo 400–800 | One family, both scripts |

**Everything is generated from vector.** The SVGs in [`assets/branding/`](assets/branding/) are the
source of truth; every PNG in the repository is output.

```mermaid
flowchart LR
    subgraph SRC["assets/branding/ — the source of truth"]
        S1["icon_full.svg"]
        S2["logo.svg"]
        S3["icon_foreground.svg<br/>+ icon_background.svg"]
        S4["icon_monochrome.svg"]
    end

    R["tool/render_branding.sh<br/><i>SVG → 1024px PNG</i>"]
    LI["flutter_launcher_icons"]
    NS["flutter_native_splash"]

    S1 --> R --> LI
    S3 --> R
    S4 --> R
    S2 --> R --> NS

    LI --> O1["iOS icon set"]
    LI --> O2["Android adaptive<br/>+ monochrome"]
    LI --> O3["web icons"]
    NS --> O4["light & dark<br/>native splash"]
    S2 --> O5["in-app AppLogo"]

    style SRC fill:#E63946,color:#fff,stroke:#C1121F,stroke-width:2px
    style R fill:#2B2D42,color:#fff
```

```bash
tool/render_branding.sh               # SVG → 1024px PNGs (needs Chrome)
dart run flutter_launcher_icons       # → iOS set, Android adaptive + monochrome, web icons
dart run flutter_native_splash:create # → light & dark native splash
```

---

## Contributing

Pull requests are welcome. Please read **[`CONTRIBUTING.md`](CONTRIBUTING.md)** first — the bar for
medical content is deliberately higher than the bar for code:

- **Any change to a first-aid step needs a citation** to a recognised body, recorded in
  [`docs/medical_sources.md`](docs/medical_sources.md).
- **Every user-facing string exists in both languages**, or the build fails.
- **Anything analytics-shaped will be declined.** So will an account system, a cloud sync for
  health data, and a location permission. Those are not oversights.

Participation is covered by [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md). Vulnerabilities go through
[`SECURITY.md`](SECURITY.md), privately — please do not open a public issue for one.

---

## Credits

- Original concept: **Ayman Abo El Ela**. Original UI: Salma Salama.
- 2.0 rebuild: new architecture, brand, bilingual content, expanded first-aid topics, and tests.
- First-aid guidance follows widely taught standards (St John Ambulance, the Red Cross, the
  American Heart Association, the NHS) and is intentionally conservative.
- Photographs from [Pexels](https://pexels.com), bundled under the Pexels licence with each
  photographer credited in the app and in [`assets/CREDITS.md`](assets/CREDITS.md).
- Category illustrations from [unDraw](https://undraw.co), recoloured to each category's accent.
  Step illustrations are original work for this app.
- Videos are **linked, not hosted**, and belong to the organisations that published them.
- Cairo font © The Cairo Project Authors, [SIL Open Font License 1.1](assets/fonts/OFL.txt).

---

## License

Application code is released under the MIT License — see [`LICENSE`](LICENSE).

Bundled third-party assets keep their own licences: the Cairo font under the SIL OFL, unDraw
illustrations under the unDraw licence, and photographs under the Pexels licence. See
[`assets/CREDITS.md`](assets/CREDITS.md).

<div align="center">
<br />
<sub>Built so that the minute before the ambulance arrives is not a wasted one.</sub>
</div>
