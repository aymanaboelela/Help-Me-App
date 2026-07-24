# Publishing checklist — Help Me / ساعِدني

App id: **`com.helpme.help`** · current version: **`2.0.0 (build 7)`** (see `pubspec.yaml`).

This app is store-ready in configuration. The steps below require the owner's paid developer
accounts and signing keys, which only the owner can create.

## 0. Before you start
- [ ] Apple Developer account ($99/yr) and/or Google Play Console account ($25 one-time).
- [ ] Host `PRIVACY_POLICY.md` at a public URL (e.g. GitHub Pages) — both stores require a link.
- [ ] Confirm the emergency numbers suit your target country (current list is for **Egypt**).

## 1. Bump the version for each release
In `pubspec.yaml`: `version: 2.0.0+7` → increase the build number (`+8`, …) every upload, and the
name (`2.0.1`, `2.1.0`, …) for user-facing releases. Keep `lib/core/app_config.dart` `version` in
sync.

## 2. Android (Google Play)
1. Create an upload keystore (once):
   ```bash
   keytool -genkey -v -keystore ~/help-me-upload.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Create `android/key.properties` (already wired in `android/app/build.gradle`, and **git-ignored**):
   ```
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload
   storeFile=/absolute/path/to/help-me-upload.jks
   ```
3. Build the release bundle:
   ```bash
   flutter build appbundle --release
   ```
   Output: `build/app/outputs/bundle/release/app-release.aab`.
4. In Play Console: create the app → fill the listing from [`listing_ar.md`](listing_ar.md) /
   [`listing_en.md`](listing_en.md) → upload the `.aab` → add screenshots + feature graphic →
   set the privacy policy URL → complete the Data safety form (**No data collected**) → submit.

## 3. iOS (App Store)
1. Open `ios/Runner.xcworkspace` in Xcode → Signing & Capabilities → select your Team
   (bundle id is already `com.helpme.help`).
2. Register the app in App Store Connect and set `AppConfig.appStoreId` in
   `lib/core/app_config.dart` (enables in-app "Rate" on iOS).
3. Build & upload:
   ```bash
   flutter build ipa --release
   ```
   then upload `build/ios/ipa/*.ipa` via Xcode Organizer or `xcrun altool` / Transporter.
4. In App Store Connect: fill the listing (AR + EN) → screenshots → privacy policy URL →
   App Privacy = **Data Not Collected** → submit for review.

## 4. Assets you still need to capture
- [ ] Phone screenshots (light & dark) for each store — run the app and capture Home, a condition
      detail, and the emergency-numbers screen.
- [ ] Google Play feature graphic (1024×500).
- The app icon (1024×1024) is generated at `assets/branding/icon_1024.png`.

## 5. Review notes (helps approval)
- The app is an **educational first-aid reference**; it shows a medical disclaimer on first launch
  and does not provide diagnosis or telemedicine.
- It collects **no** personal data and works fully offline.
