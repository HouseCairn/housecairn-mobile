# 0001. Flutter stack and packages

- Status: proposed
- Date: 2026-11-14

## Context

The maintainer decided on one Flutter code base for iOS and Android, data on the phone in
SQLite, free use without network or account, and a paid end-to-end encrypted family sync.
Each package below is a dependency of an app that holds a household's data and keys: it must
be open source with a license compatible with AGPL-3.0, published by a known publisher,
maintained (a release in the last twelve months, unless noted), and support Android and iOS.
Rule 1 of the project applies: what a maintained library does well is not rewritten.

Facts were read on 2026-11-14 from the pub.dev API (`/api/packages/<name>`, `/score`,
`/publisher`) and the package pages linked below.

## Decision

**Flutter stable** (3.50 at the time of writing, <https://docs.flutter.dev/release/archive>),
Dart 3, Material 3 widgets with the Housecairn design tokens. No web or desktop build in v1.

| Need | Package | Version, date | Publisher | License | Platforms | Page |
| --- | --- | --- | --- | --- | --- | --- |
| Material and Cupertino widgets, outside the SDK since Flutter 3.47 | material_ui (with cupertino_ui) | 1.11.0, 2026-11-09; 1.1.6, 2026-11-03 | flutter.dev | BSD-3-Clause | all | <https://pub.dev/packages/material_ui> |
| Typed SQLite, migrations | drift | 2.35.4, 2026-11-08 | simonbinder.eu (verified), Flutter Favorite | MIT | Android, iOS, others | <https://pub.dev/packages/drift> |
| Opening the database in Flutter | drift_flutter | 0.3.1, 2026-07-11 | simonbinder.eu | MIT | Android, iOS, others | <https://pub.dev/packages/drift_flutter> |
| SQLite itself, bundled by build hooks | sqlite3 | 3.9.1, 2026-11-08 | simonbinder.eu | MIT | Android, iOS, others | <https://pub.dev/packages/sqlite3> |
| Cryptography (libsodium 1.0.22, built by hooks) | sodium | 4.1.2+1, 2026-10-27 | skycoder42.de (verified) | BSD-3-Clause, ISC | Android, iOS, others | <https://pub.dev/packages/sodium> |
| Keys at rest (Keychain, Android Keystore) | flutter_secure_storage | 11.2.0, 2026-09-16 | steenbakker.dev | BSD-3-Clause | Android, iOS, others | <https://pub.dev/packages/flutter_secure_storage> |
| Local notifications | flutter_local_notifications | 23.0.2, 2026-11-13 | dexterx.dev, Flutter Favorite | BSD-3-Clause | Android, iOS, others | <https://pub.dev/packages/flutter_local_notifications> |
| Time zone database | timezone | 0.11.2, 2026-10-12 | labs.dart.dev | BSD-2-Clause | all | <https://pub.dev/packages/timezone> |
| Time zone of the phone | flutter_timezone | 5.1.1, 2026-10-03 | wolverinebeach.net | Apache-2.0 | Android, iOS, others | <https://pub.dev/packages/flutter_timezone> |
| In-app purchases (StoreKit, Play Billing) | in_app_purchase | 3.3.1, 2026-09-18 | flutter.dev | BSD-3-Clause | Android, iOS, macOS | <https://pub.dev/packages/in_app_purchase> |
| Scanning the invitation QR code | mobile_scanner | 7.5.0, 2026-11-01 | steenbakker.dev | BSD-3-Clause | Android, iOS, macOS, web | <https://pub.dev/packages/mobile_scanner> |
| Making the QR code | qr (drawn by a small painter of ours) | 4.0.1, 2026-10-29 | kevmoo.com | BSD-3-Clause | all | <https://pub.dev/packages/qr> |
| Background sync | workmanager | 0.10.10, 2026-09-07 | fluttercommunity.dev | MIT | Android, iOS, macOS, web | <https://pub.dev/packages/workmanager> |
| Wake-up push on Android (store build) | firebase_messaging | 17.0.1, 2026-10-23 | firebase.google.com | BSD-3-Clause | Android, iOS, macOS, web | <https://pub.dev/packages/firebase_messaging> |
| Translations and formats | intl (with `flutter_localizations`) | 0.20.3, 2026-06-25 | dart.dev, Flutter Favorite | BSD-3-Clause | all | <https://pub.dev/packages/intl> |
| Amounts in decimal | decimal | 3.2.6, 2026-07-28 | unverified publisher | Apache-2.0 | all | <https://pub.dev/packages/decimal> |
| Identifiers (v4, v5) | uuid | 4.6.0, 2026-07-15 | yuli.dev | MIT | all | <https://pub.dev/packages/uuid> |
| Procedure in Markdown | flutter_markdown_plus | 1.0.12, 2026-07-10 | foresightmobile.com | BSD-3-Clause | all | <https://pub.dev/packages/flutter_markdown_plus> |
| Photos from camera and gallery | image_picker | 1.2.4, 2026-10-06 | flutter.dev | Apache-2.0, BSD-3-Clause | Android, iOS, others | <https://pub.dev/packages/image_picker> |
| Re-encoding photos (size, metadata), in Dart | image | 4.12.0, 2026-10-11 | taosengine.com | MIT | all | <https://pub.dev/packages/image> |
| The library of task templates (YAML) | yaml | 3.1.4, 2026-08-28 | tools.dart.dev | MIT | all | <https://pub.dev/packages/yaml> |
| Opening a link, a phone number, an address | url_launcher | 6.3.3, 2026-10-02 | flutter.dev | BSD-3-Clause | Android, iOS, others | <https://pub.dev/packages/url_launcher> |
| PDF picking, export file | file_picker, share_plus | 13.3.3, 2026-11-10; 13.3.1, 2026-10-01 | victorcarreras.dev; fluttercommunity.dev | MIT; BSD-3-Clause | Android, iOS, others | <https://pub.dev/packages/file_picker>, <https://pub.dev/packages/share_plus> |
| Backup archive (zip) | archive | 4.7.1, 2026-11-13 | taosengine.com | MIT | all | <https://pub.dev/packages/archive> |

**Choices within the table, and what was rejected:**

- **SQLite is bundled by `sqlite3` 3.x build hooks**; `sqlite3_flutter_libs` (0.6.0+eol) and
  `sqlcipher_flutter_libs` (0.7.0+eol) are end of life and not used. The `sqlite3` page says
  that SQLite3MultipleCiphers or SQLCipher can replace SQLite by a hook option: this keeps
  database encryption available later without a change of package ([ADR 0002](0002-local-storage-and-migrations.md)).
- **libsodium through `sodium`**, for audited, misuse-resistant constructions (XChaCha20-Poly1305,
  X25519 sealed boxes, Ed25519, Argon2id, secretstream). `sodium_libs` is discontinued and
  replaced by `sodium` 4, which builds libsodium with hooks. **Risk**: one maintainer, 27 likes.
  Fallback: `cryptography` 2.9.0 (Apache-2.0, dint.dev, <https://pub.dev/packages/cryptography>),
  which implements the same primitives; its last release is 2025-11-21, so it is not the
  first choice. The wire format uses only standard constructions, so a change of binding does
  not change the protocol.
- **Recurrence is ported, not taken from `rrule`** (0.2.18, Apache-2.0,
  <https://pub.dev/packages/rrule>). The rules of Housecairn are not plain RFC 5545: month ends
  clamp (`tasks/recurrence.py:152-173`), seasons move a date (`:132-138`), "after the last time"
  counts from the closing (`:221-222`). The port is the pure functions of
  `tasks/recurrence.py` (about 350 lines), and lot 2 checks it against **test vectors generated
  from the Python module**, so both applications give the same dates. A second library with
  its own semantics would give different dates on the phone and on the web.
- **QR code**: `qr_flutter` (last release 2023-05-14) is not maintained; the `qr` package
  gives the matrix and a 30-line painter draws it.
- **Markdown**: `flutter_markdown` is discontinued, replaced by `flutter_markdown_plus`. Images
  are disabled and only `http(s)` links are kept, as on the web (web ADR 0031).
- **Push wake-up**: on Android, Firebase Cloud Messaging through `firebase_messaging` (store
  build). On iOS, APNs directly through a small platform channel of the app (register, receive
  the token, wake the sync), so that Google does not see iOS tokens; `push` (MIT, last release
  2025-01-14) and `flutter_apns_only` (discontinued) were rejected. A build for phones without
  Google services would use `unifiedpush` (6.2.0, Apache-2.0, Android only,
  <https://pub.dev/packages/unifiedpush>) after version 1.0 (maintainer's decision).
- **Local notifications**: the plugin README says iOS keeps only 64 pending notifications, and
  that Android 14 restricts exact alarms
  (<https://github.com/MaikuB/flutter_local_notifications/tree/master/flutter_local_notifications>):
  the app schedules a rolling window and inexact alarms ([spec](../spec.md#reminders)).
- **Background sync**: `workmanager`; Android runs periodic work at most every 15 minutes
  (<https://developer.android.com/develop/background-work/background-tasks/persistent/getting-started/define-work>);
  iOS decides itself when background refresh runs. Sync on opening the app is the guaranteed
  path; background and push only shorten the wait.
- **No analytics, crash reporting or advertising SDK.** Of Firebase, only messaging is a
  dependency, on Android; lot 1 checks that no analytics package enters the dependency tree.

**Lot 2b, changes to the table.** `flutter_image_compress` is replaced by `image`, pure Dart:
the rule (upright, no metadata, 2560 px, quality 85, a 360 px thumbnail) is then the same on
the phone and in the tests, which run it on a fixture with GPS data; a native encoder would
only run on a device, and cannot be shown to strip the location. The cost is speed, so the
work runs in an isolate. `image` is pinned at 4.12.0 and not 4.13.x: the versions of
2026-11-14 are younger than the seven days of the rule below. `yaml` and `url_launcher` are
added. `dbus`, a transitive package of the Linux part of `flutter_local_notifications` that no
iOS or Android build contains, is MPL-2.0 and gets one named exception in
`tool/licenses/exceptions.txt`; the exception was accepted on 2026-11-15
([plan](../plan.md)).

## Consequences

- Every dependency is pinned in `pubspec.lock`, updated by Renovate or Dependabot with the
  seven-day delay of the web repository, and its license is checked in CI (lot 1).
- Native code is built by hooks (`sqlite3`, `sodium`): CI needs the Android NDK and, for iOS,
  a macOS runner.
- A package that loses its maintainer is replaced behind the app's own interfaces
  (`Db`, `Crypto`, `Notifier`, `Store`), which the lots define first. Lot 1 defines them in
  `lib/core/`: `Db` the local database (drift), `Crypto` the primitives of
  [protocol.md](../protocol.md) section 1 (sodium), `Notifier` the local notifications
  (flutter_local_notifications), `Store` the secrets at rest in the Keychain or Keystore
  (flutter_secure_storage); and `Clock`, the time of the phone, so that tests choose it.
- `firebase_messaging` brings Google Play services on Android; the store listing says so.
