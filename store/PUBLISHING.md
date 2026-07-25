# Publishing checklist — Help Me / ساعِدني

App id: **`com.helpme.help`** (Android and iOS) · current version: **`2.0.0 (build 7)`**.

The single source of truth for the version is `version:` in `pubspec.yaml`. Nothing else —
not `build.gradle`, not `Info.plist` — holds a copy. Both platforms read it through
generated build settings, so bumping `pubspec.yaml` is the whole job.

---

## 0. Before you start

- [ ] Apple Developer account ($99/yr) and/or Google Play Console account ($25 one-time).
- [ ] `PRIVACY_POLICY.md` hosted at a public URL (GitHub Pages is enough). Both stores
      require a link and both will reject the submission without one.
- [ ] Confirm the emergency numbers suit your target country — the shipped list covers
      Egypt, Saudi Arabia, the UAE and an international fallback.

---

## 1. Bump the version

In `pubspec.yaml`:

```yaml
version: 2.0.0+7
#        │     └── build number: MUST increase on every single upload to either store
#        └──────── user-facing version: 2.0.1, 2.1.0, …
```

Then keep `version` in `lib/core/app_config.dart` in sync — it is what the About screen shows.

---

## 2. The signing key (Android, once, and then never again)

> **Read this paragraph before you generate anything.** Google Play ties an app to its
> signing key permanently. Lose this keystore or its password and you cannot ship another
> update to `com.helpme.help` — ever. Not with a support ticket, not with proof of
> ownership. You would have to publish a new listing under a new id and abandon every
> existing install. Back it up somewhere that survives this laptop.

Generate it **outside the repository**, so that no `.gitignore` mistake and no `git add -f`
can ever reach it:

```bash
mkdir -p ~/keystores && chmod 700 ~/keystores

keytool -genkeypair -v \
  -keystore ~/keystores/help-me-upload.jks \
  -storetype PKCS12 \
  -keyalg RSA -keysize 4096 -validity 10000 \
  -alias upload \
  -dname "CN=Your Name, OU=Help Me, O=Help Me, L=Cairo, S=Cairo, C=EG"

chmod 600 ~/keystores/help-me-upload.jks
```

PKCS12 rather than the older JKS format, and 4096-bit rather than 2048 — a key with a
27-year validity is not one you want to be re-reading advice about in 2035.

Then create `android/key.properties`. It is ignored by **both** `/.gitignore` and
`android/.gitignore`, and a gitleaks job scans the whole history on every push:

```properties
storeFile=/Users/you/keystores/help-me-upload.jks
storePassword=…
keyAlias=upload
keyPassword=…
```

```bash
chmod 600 android/key.properties
git check-ignore -v android/key.properties    # must print a match. If it does not, STOP.
```

**Store the password in a password manager, not in a note next to the keystore.**

### What happens without it

`android/app/build.gradle` falls back to the debug signing key and prints a warning. The
build succeeds and installs on a device, which is what lets anyone clone this repository
and try it — but Play will refuse the upload. That is deliberate: the build fails loudly at
the store, not silently on your machine.

---

## 3. Android release

```bash
flutter build appbundle --release \
  --obfuscate --split-debug-info=build/symbols
```

Output: `build/app/outputs/bundle/release/app-release.aab`.

`--obfuscate --split-debug-info` renames the Dart symbols and writes the mapping out to
`build/symbols/` instead of into the binary. **Keep that directory** for the release you
shipped, alongside `build/app/outputs/mapping/release/mapping.txt` from R8 — without both,
a crash report from a user is unreadable.

Verify before you upload:

```bash
# Signed with your key, not the debug key
keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab | grep -E "Owner|SHA256"

# Version, permissions and the security flags that actually made it into the bundle
M=build/app/intermediates/packaged_manifests/release/processReleaseManifestForPackage/AndroidManifest.xml
grep -oE 'android:version(Code|Name)="[^"]+"' $M
grep -oE 'uses-permission android:name="[^"]+"' $M | sort -u
grep -oE 'android:(allowBackup|usesCleartextTraffic|debuggable)="[^"]*"' $M
```

Expect exactly four permissions — `INTERNET`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`,
`VIBRATE` — plus Flutter's own `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`. **No location, no
contacts, no exact-alarm.** If a new one appears, a dependency added it; find out why before
shipping, because the Play listing and the privacy policy both promise otherwise.

Then in Play Console: create the app → listing from [`listing_ar.md`](listing_ar.md) /
[`listing_en.md`](listing_en.md) → upload the `.aab` → screenshots and feature graphic →
privacy policy URL → **Data safety: no data collected, no data shared** → submit.

---

## 4. iOS release

1. Open `ios/Runner.xcworkspace` → *Signing & Capabilities* → select your Team.
   The bundle id is already `com.helpme.help`.
2. Register the app in App Store Connect, then set `AppConfig.appStoreId` in
   `lib/core/app_config.dart` — that is what enables the in-app "Rate" prompt on iOS.
3. Build:

   ```bash
   flutter build ipa --release \
     --obfuscate --split-debug-info=build/symbols
   ```

   Upload `build/ios/ipa/*.ipa` through Xcode Organizer, Transporter, or
   `xcrun altool`.

`ITSAppUsesNonExemptEncryption` is already declared `false` in `Info.plist`, so App Store
Connect will not stop and ask about export compliance on each upload. That is accurate: the
only cryptography in the app is the iOS Keychain and HTTPS, both exempt under Category 5
Part 2.

Then in App Store Connect: listing in Arabic and English → screenshots → privacy policy URL
→ **App Privacy: Data Not Collected** → submit.

---

## 5. Assets you still need to capture

- [ ] Phone screenshots for each store. `flutter test test/tool/screenshots.dart --update-goldens`
      renders the real screens into `docs/screenshots/`, but the stores want specific sizes
      from a device or simulator.
- [ ] Google Play feature graphic, 1024×500.
- The 1024×1024 icon is already generated at `assets/branding/icon_1024.png`.

---

## 6. Review notes

Both review teams ask more or less the same things, and the honest answers are short:

- The app is an **educational first-aid reference**. It shows a medical disclaimer on first
  launch, and it does not diagnose, prescribe, or offer telemedicine.
- It collects **no** personal data, has **no** account, and works fully offline. There is no
  server to send anything to.
- Health cards are entered by the user, encrypted on-device, and never transmitted.
- The videos are **linked, not hosted**, and belong to the organisations that published them.
- The app icon is a white cross on red. A **red cross on white** is the protected emblem of
  the Red Cross and both stores reject it; this is deliberately the inverse.

---

## 7. After shipping

- [ ] Tag the release: `git tag v2.0.0 && git push --tags`
- [ ] Archive `build/symbols/` and `mapping.txt` for that build number
- [ ] Keep the keystore backup somewhere that is not this laptop
