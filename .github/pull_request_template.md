<!-- One idea per pull request. If the summary needs two sentences joined by
     "and", it is probably two pull requests. -->

## What this changes

<!-- One or two sentences, from the user's point of view. -->

## Why

<!-- What was wrong, or what became possible. -->

---

## Checks

- [ ] `dart format lib test` — clean
- [ ] `flutter analyze --fatal-infos` — 0 issues
- [ ] `flutter test` — all green
- [ ] Goldens updated **and the diff looked at**, or not touched

## If it changes user-facing text

- [ ] Arabic **and** English, both present
- [ ] Checked in RTL — layout, numerals and icon direction all mirror correctly
- [ ] Checked at a large system text scale
- [ ] Checked in dark theme

## If it changes medical content

- [ ] Source cited in `docs/medical_sources.md` (a recognised body, with the year)
- [ ] Age band the source covers is stated — adult / child / infant
- [ ] Where sources disagreed, the safer action was chosen
- [ ] No "call the emergency number" step was removed

## If it touches storage, permissions, or the build

- [ ] No new permission — or the PR explains why one is unavoidable
- [ ] No new network call — or the PR explains how the app behaves offline
- [ ] No credential, keystore, or `key.properties` in the diff

## Screenshots

<!-- For any visual change: before and after, in both languages if it affects layout. -->
