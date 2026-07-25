# Security Policy

## Reporting a vulnerability

Please **do not open a public issue** for a security problem.

Report it privately through GitHub's
[private vulnerability reporting](https://github.com/aymanaboelela/Help-Me-App/security/advisories/new)
form. If that is unavailable to you, open a public issue containing only the
words "security report" and a way to reach you — no detail — and you will be
contacted for the rest.

You can expect an acknowledgement within **7 days** and an assessment within
**30 days**. This is a small, unfunded project; that is a realistic promise
rather than an ambitious one.

## Scope

This is a client-only application. There is no server, no account system, and no
API, which removes most of the usual mobile attack surface and concentrates what
remains in a few places:

| In scope | Why it matters |
| --- | --- |
| Health data at rest (`lib/services/secure_store.dart`) | Blood type, allergies, conditions and medicines for up to six named people. The one genuinely sensitive store in the app. |
| The emergency QR code | Deliberately plain text and deliberately user-triggered. A path that renders it without the user asking would be a real finding. |
| Android backup / data-extraction rules | `android/app/src/main/res/xml/` — anything that lets health data off the device. |
| First-aid content correctness | A wrong medical step is a safety bug. Report it the same way. |
| Deep links, intents, exported components | Anything that lets another app drive this one. |
| Build and release configuration | Signing, manifest merge, R8 rules. |

**Out of scope:** attacks that need physical access to an unlocked device;
attacks that need root or a jailbreak; the security of YouTube, the platform
maps application, or the user's dialler; and reports produced solely by an
automated scanner with no demonstrated impact.

## What the app already does

- **No server, no account, no analytics, no ads, no telemetry.** There is no
  network path that carries user data anywhere.
- **Health data is encrypted at rest** — the iOS Keychain, and AES-GCM with
  RSA-OAEP key wrapping in the Android Keystore. Never written to plain
  `SharedPreferences`.
- **Backup and device-transfer are both disabled** on Android, so health data
  cannot leave the device through Google's backup service.
- **Cleartext traffic is refused** on both platforms — an Android network
  security config with no exceptions, and iOS ATS with no arbitrary-loads
  escape.
- **No location permission is ever requested.** "Near me" hands a search string
  to the maps application, which already holds that permission.
- **No contacts permission is ever requested.** Importing an ICE contact uses
  the system picker, which runs outside the app and returns one contact.
- **Reminders keep their text off the lock screen** (`NotificationVisibility.private`),
  because a medicine name can disclose a diagnosis.
- **Signing material is never in the repository.** `key.properties` and every
  `*.jks` / `*.keystore` are ignored in two separate `.gitignore` files, a
  release build without them falls back to the debug key rather than failing
  open, and a gitleaks job scans the full history on every push.

## Supported versions

The latest release on `main` is the only supported version.
