# Help Me 4.0 · Phase B — Symptom Search & Accessibility

**Date:** 2026-07-25
**Status:** approved, ready for planning
**Branch:** `revamp/help-me-2.0`
**Siblings:** [`child & infant mode`](2026-07-25-child-infant-mode-design.md) ·
[`content as data`](2026-07-25-content-as-data-design.md) ·
[`visual system & platform fidelity`](2026-07-25-visual-system-and-platform-fidelity-design.md)

## Problem

**You have to already know the answer to find it.** Search matches the title, the summary, and
section headings, as plain case-insensitive substrings. So the app answers "الغصة" and does not
answer "شرق", "واقف في زوره", "مش بيتنفس", or "battery". A frightened person does not think in
clinical nouns; they describe what they are looking at.

Three concrete failures today:

1. **No colloquial vocabulary.** Nothing maps everyday Egyptian Arabic onto a clinical topic.
   "بينزف" finds nothing, because the topic is titled "النزيف".
2. **Arabic orthography is treated as exact.** "إختناق" does not match "اختناق" — different hamza.
   Neither does a word carrying tashkeel, or one typed with a tatweel. The user is punished for
   spelling a word the way it is normally typed on a phone.
3. **The catalogue grew to 20 topics** and the newest ones are the hardest to name. A parent whose
   child swallowed a watch battery searches "بطارية", not "ابتلاع جسم غريب".

Separately, the app is **effectively unusable with a screen reader**. Two files in the entire
codebase use `Semantics`. Icon-only controls — read aloud, favourite, back, SOS, the age switch —
announce as "button" with no name. Contrast is already handled by the visual-system work and is
not revisited here.

## Goals

- Let someone find the right topic by describing **what they see**, in the language and spelling
  they actually type.
- Make matching **predictable and testable** — data a reviewer can read, not a scoring heuristic.
- Give every control a name a screen reader can announce, and survive large text without
  losing content.
- No new dependencies, no network, no change to the offline guarantee.

## Non-goals

- No fuzzy or edit-distance matching. Under stress a wrong-but-plausible result is worse than no
  result, and "why did it show me that?" is unanswerable when the answer is a distance threshold.
- No symptom-picker screen. Considered and deferred: it is a second navigation surface and this
  phase is about making the surface that exists work.
- No triage or ranking by severity. Results keep catalogue order, as they do today.
- No third language.

## Part 1 — Symptom search

### Keywords are data on the topic

`FirstAidTopic` gains one field:

```dart
  /// Everyday words for this emergency, in both languages, as somebody would
  /// actually type them — "بينزف", "دم", "bleeding", "cut".
  ///
  /// Deliberately a flat list rather than paired [LocalizedText]: a symptom is
  /// not a translation of another symptom, and forcing 1:1 pairs would invent
  /// an Arabic phrase to sit opposite every English one.
  final List<String> keywords;
```

Defaulting to `const <String>[]`, so nothing existing breaks and coverage can grow a topic at a
time. It goes on the topic rather than in a side catalogue because the content-as-data migration
already serialises every topic field — a side catalogue would mean a whole extra JSON asset.

### Arabic normalisation

A new pure function in `lib/core/search_text.dart`:

```dart
String normalizeForSearch(String input);
```

Applied to **both** sides of every comparison. It performs, in order:

| Step | Why |
| --- | --- |
| Lowercase | English matching, unchanged behaviour |
| Strip tashkeel (`U+064B`–`U+0652`, `U+0670`) | Typed text rarely carries it; content sometimes does |
| Strip tatweel (`U+0640`) | Decorative elongation, never meaningful |
| `أ إ آ ٱ` → `ا` | The single most common Arabic spelling variation |
| `ة` → `ه` | "غصة" vs "غصه" — both are typed |
| `ى` → `ي` | "مبنى" vs "مبني" |
| Collapse runs of whitespace | Tolerates a double space, nothing more |

**Not** normalised: `ؤ`/`ئ`, which carry meaning often enough that folding them creates false
matches. This is a judgement call and the spec records it so a reviewer can disagree deliberately.

### Matching

`FirstAidTopic.matches(query)` compares the **normalised** query as a substring against the
normalised title, summary, section titles, and now keywords. Substring, not token-AND: it makes
"مش بيتنفس" match the keyword "مش بيتنفس" and "بيتنفس" match it too, and it stays explainable —
every match is a literal containment a reader can verify by eye.

Step text stays out of the searchable set. Steps are long and full of common words; including them
turns almost any query into almost every topic.

### Coverage

Every one of the 20 topics gets keywords — roughly 6–12 each, Egyptian colloquial plus English,
including the words that describe the *situation* rather than the condition ("وقع من على السلم",
"اتخبط", "swallowed", "battery"). A data test asserts each topic has at least four, with at least
one Arabic and one English.

## Part 2 — Accessibility

Scoped to what is missing, not to a general audit.

### Names for controls

Every icon-only control gets a `tooltip` (which Flutter surfaces to screen readers) or an explicit
`Semantics` label: read-aloud, favourite toggle, focus mode, timer, metronome, SOS, the country
picker, and the home favourites button. Several already have tooltips; the work is the gaps.

### The age banner is announced

Changing the age switch changes what the steps mean, and a screen-reader user gets no visual
banner. `AgeBanner` becomes a `Semantics(liveRegion: true, …)` so the change is spoken when it
happens, rather than only being discoverable by exploring.

### Large text

The app must remain usable at the largest OS text setting. Widget tests pump the main screens at
`TextScaler.linear(2.0)` and assert no overflow. Where a fixed height causes overflow — the
category chip strip and the gallery are the likely candidates — the fix is to let the box grow,
not to clamp the user's text scale.

### Tap targets

Interactive controls meet the 48×48 minimum. A test walks the main screens and asserts it, which
is cheaper and more honest than eyeballing each one.

## Error handling

| Situation | Behaviour |
| --- | --- |
| Query matches nothing | The existing empty state, unchanged. |
| Query is only whitespace | Normalises to empty; every topic matches, as today. |
| Topic has no keywords | Matching falls back to title/summary/sections — exactly today's behaviour. |
| Screen reader absent | `Semantics` and tooltips cost nothing visually. |
| Text scale beyond 2.0 | Layout grows and scrolls; content is never clipped. |

## Testing

- **Normalisation** — a table of inputs and expected outputs, including tashkeel, all four alifs,
  ة/ه, ى/ي, tatweel, mixed Arabic/English, and the deliberate non-folding of ؤ/ئ.
- **Matching** — the worked examples from this spec asserted directly: "بينزف" → bleeding,
  "مش بيتنفس" → CPR/choking/drowning, "إختناق" → choking, "battery" → swallowed object.
- **Data integrity** — every topic has ≥4 keywords, at least one Arabic and one English, no empty
  strings, no duplicates within a topic, and every keyword normalises to something non-empty.
- **Accessibility** — main screens render at `TextScaler.linear(2.0)` with no overflow; icon-only
  controls expose a label; the age banner is a live region.

## Risks

| Risk | Mitigation |
| --- | --- |
| **Keyword bloat makes search useless** — a topic listing "ألم" matches half the catalogue. | Keywords name the *emergency*, not any symptom it might share. Enforced concretely: a test asserts that none of the vague words "ألم", "تعب", "دوخة", "pain", "sick", "hurt" appears as a keyword on any topic, and that no single-word query returns more than 6 of the 20 topics. |
| **Normalisation creates false matches.** | Only the well-established Arabic foldings, ؤ/ئ deliberately excluded, and the whole table is asserted. |
| **Colloquial coverage is a judgement call** and mine is one person's. | The keywords are plain data in one place, reviewable and correctable without touching code — and they migrate to JSON with the rest of the content. |
| Another session is mid-migration on the same files. | `keywords` is one additive field; the content-as-data plan needs one line for it, added as part of this work rather than left to collide. |
