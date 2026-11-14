# Plan: lots 1 to 9

- Status: proposed (lot 0), with the maintainer's decisions of 2026-11-14
- One lot is one pull request (or one per repository when a lot spans the app and the relay),
  reviewed by another model, merged by the maintainer. A lot starts when the lots it depends on
  are merged. No estimate in days.
- Repositories (decided): `HouseCairn/housecairn-mobile` (this one: app and documents) and
  `HouseCairn/housecairn-relay` (relay, from lot 6). Both public from their first commit, as
  the web repository, under `AGPL-3.0-only` with the `NOTICE` and CLA of the project
  ([ADR 0007](adr/0007-license.md)).
- Application id (decided): `app.housecairn.mobile`, as iOS bundle id and Android package.
- **Several homes in v1** ([ADR 0008](adr/0008-several-homes-one-family-space.md)): every lot
  from 2 on tests with **at least two homes**.
- **Three ways to use the app** ([ADR 0010](adr/0010-three-ways-to-use-the-app.md)): alone on
  the phone, family sync through the relay, a Housecairn server. The first-start screen and the
  transport interface come early (lot 2c); each way is turned on by its own lot (lot 7 for the
  family sync, lot 4b for a server).
- Each lot updates the documents it changes (spec, ADR, protocol) in the same pull request.
- **Device** below means a test that needs a real phone or a macOS machine, which CI cannot run;
  the maintainer runs it, and the lot lists the exact steps.

## Lot 1. Foundations

**Scope**: Flutter project for Android and iOS, `pubspec.lock`, the interfaces `Db`, `Crypto`,
`Notifier`, `Store`, `Clock`; app shell with navigation and empty screens; EN and FR ARB files
with `gen-l10n`; design tokens of Housecairn; CI (format, analyze, unit and widget tests,
Android build, iOS build on a macOS runner without signing, license check of every dependency,
pinned actions, Renovate or Dependabot with a seven-day delay); the CLA check; community files
(SECURITY, CODE_OF_CONDUCT; `LICENSE`, `NOTICE` and `CONTRIBUTING.md` come with lot 0);
application id `app.housecairn.mobile`; an About screen with the attribution of `NOTICE`.

**Acceptance**:
- `flutter analyze` and `flutter test` pass in CI; an Android APK and an unsigned iOS build are
  produced on every pull request.
- A test fails when a string shown to people is not in the ARB files.
- The license check lists every dependency with an allowed license and fails on any other; no
  analytics package in the tree.
- The empty database opens, migrates from schema 1 to 1, and `integrity_check` passes.
- The Android package and the iOS bundle id are `app.housecairn.mobile` (checked in CI from the
  build outputs).

**Device**: the app starts on an Android phone and an iPhone, in English and French, with the
system's large text size.

**Depends on**: lot 0 merged (licence and application id are decided).

## Lot 1b. TestFlight builds

**Scope**: internal and external TestFlight builds from `main` once the maintainer enables it
([ADR 0009](adr/0009-early-testflight-builds.md)): the workflow `ios-testflight.yml`, with a
`TestFlight plan` job on every event and a `TestFlight upload` job on `main` only; unsigned
archive, cloud signing and upload by `xcodebuild -exportArchive` with an App Store Connect API
key; Xcode 26 on a macOS 26 runner; build number from the run number; export options committed
without any account identifier, and checked on every pull request. No change to the app. A
separate lot rather than a part of lot 2: it is CI and supply chain work, reviewed as such, and
lot 2 is the largest lot.

**Acceptance**:
- On a pull request and in the merge queue, `TestFlight plan` passes and `TestFlight upload` is
  skipped, not failed; the run summary says why. No job of a pull request reads a secret.
- `TestFlight upload` runs only on `main` (push or manual run) and only when enabled; it is the
  only job that enters the `testflight` environment, and is not a required check.
- No third-party action and no cache in the upload job; every action pinned to a full commit SHA;
  zizmor passes.
- The API key is written with mode 600, removed at the end of its step and of the job, failed or
  not, and never printed.
- The job checks that the archive's bundle id is `app.housecairn.mobile` and its build number the
  run number.
- The unsigned iOS build of lot 1 is unchanged.

**Device**: once enabled, a build of `main` installs from TestFlight on an iPhone and starts in
English and French; the build number shown in TestFlight is the run number.

**Depends on**: lot 1. Lot 2 does not wait for it; from lot 2 on, the iPhone part of each
Device test may use the TestFlight build of `main`.

## Lot 2. Core: rooms, items, tasks, occurrences, today

**Scope**: tables and repository for homes, rooms, items, photos, contractors, tasks,
occurrences, with `field_clock` written on every change and the home of every row; the Dart
port of `tasks/recurrence.py`; done, skip, postpone, undo; **several homes**: create, rename,
archive, unarchive, delete, the home selector, the current home, All homes on Today
([spec](spec.md#homes)); screens Today, Task, Rooms, Room, Item, Contractors, Homes, Add from a
template; reminders by local notifications, naming their home; photos re-encoded without
metadata.

**Acceptance**:
- The recurrence port passes **every vector of a file generated from the Python module** of the
  web application (a script in this repository runs `housecairn.tasks.recurrence` on a fixed set
  of rules and dates: month ends, 29 February, seasons in both hemispheres, `after_last`, fixed
  series begun decades ago); the file and the script are committed.
- Property tests: a task that repeats always has exactly one open occurrence after any sequence of
  done, skip, postpone, undo; undo restores the occurrence field by field.
- A task with only a title is saved; done is one tap and the undo bar takes it back.
- A stored photo has no EXIF block (test on a fixture with GPS data), its longest side is at
  most 2560 px, and its thumbnail 360 px.
- Reminders: with 100 open occurrences spread over two homes, at most 60 notifications are
  pending and the rest is in the daily summary, grouped by home.
- **Two homes** (fixture: two homes, each with rooms, tasks and photos):
  - the selector is shown with two active homes and hidden with one (the other archived);
  - Today on All homes lists the tasks of both, each row naming its home; on one home, only
    that home's;
  - every reminder title names its home; with one active home, none does;
  - the current home survives a restart; when it is archived or deleted, the app opens on the
    first active home by name;
  - an archived home has no pending notification and is read only; unarchived, it is back as
    it was;
  - deleting a home is refused until its exact name is typed, refused for the last active home,
    and then leaves no row and no file of it, while a dump of the other home's tables is
    unchanged byte for byte.
- Golden-free widget tests for each screen at 360 px; no screenshot in the repository.

**Device**: a reminder appears at the set time on Android (screen off) and iOS (app killed);
camera capture; a change of time zone moves "today" and not the due dates.

**Delivered in two pull requests**: **2a**, the tables, the repository, the recurrence port
and its vectors (`tool/recurrence_vectors.py`, `test/fixtures/recurrence_vectors.json`), done,
skip, postpone, undo, several homes, and the screens Today, Task and Homes; **2b**, the
screens Rooms, Room, Item, Contractors and Add from a template, photos, reminders and the
Device steps.

**Depends on**: lot 1.

## Lot 2c. First start: three ways to use the app

**Scope**: the first-start screen of [ADR 0010](adr/0010-three-ways-to-use-the-app.md), with
the three ways: **Alone on this phone**, selected and the only one active; **Family sync** and
**My Housecairn server** shown, disabled, with "Coming later". The way is stored in
`local_settings` (`sync_mode`, no migration). Settings shows the way in use and the other two,
disabled. The interface `SyncTransport` of ADR 0010 in `lib/sync/transport.dart`, **defined
only**, as lot 1 did for `Store`, with a fake in the tests. The texts of ADR 0010 in the EN and
FR ARB files, the sentence that the server reads the homes included. No network code, no
package added.

**Why a lot of its own, and why here**: lot 2b is already the larger half of lot 2 (five
screens, photos, reminders, Device steps), and this lot is reviewed on other grounds (what the
screen promises, an interface the sync engine will be written against). It needs only what lot
2a brings (`local_settings`, the first start of the repository), it touches new files and only
adds to the shared ones (app start, ARB files), so it can run next to lot 2b or lot 3 without
changing the order 2a, 2b, 3. Earlier than the sync lots because the TestFlight builds of lot 1b
put the app in people's hands before any sync exists: the screen says from the first builds
what is coming and what each way shows to whom, and the interface is settled before lot 4.

**Acceptance**:
- First start on an empty database: the screen shows the three ways, Alone selected; the two
  others are disabled, say "Coming later", and a tap on them opens nothing (widget test).
- Choosing Alone stores `sync_mode = alone`, then the first home is made as in lot 2a; after a
  restart the app opens on that home and the screen is not shown again.
- An install of a lot 2 build, with homes and no `sync_mode`, opens on its homes without the
  screen, and Settings shows it as Alone.
- The texts of the three ways exist in both ARB files; the server's text says that the server
  stores and can read the homes (a test on the keys, in both languages).
- `SyncTransport` has the members of ADR 0010 and no implementation in `lib/`; nothing in
  `lib/` opens a socket or an HTTP client (a test lists the imports of `lib/`).
- Widget tests of the screen at 360 px and with the largest system text size.

**Device**: first start on an Android phone and an iPhone, in English and French, with large
text; a phone that ran a lot 2 build is updated and does not see the screen.

**Depends on**: lot 2a (the first pull request of lot 2).

## Lot 3. Budget, stock, projects, reports

**Scope**: stock articles, suppliers, movements, task materials and draws; projects, budget
lines, quotes, project tasks, links, files, annual envelope; budget views (year, rooms, projects,
upkeep); reports and "make a task".

**Acceptance**:
- Budget figures of a fixed home equal those of the web application for the same data: a
  fixture loaded in both, figures compared by a script (planned, committed, paid, gap, still to
  pay, projection of a year).
- Amounts never pass through `double`: a lint rule or test forbids it in the budget code.
- Stock: the level is the sum of movements; an inventory line's effect is recomputed from the
  movements before it; draws never exceed `wanted`.
- An accepted quote cannot be saved without a budget line on one phone.
- Two homes in two currencies (EUR and CHF): budget figures, envelopes and stock are per home
  and never added together; each amount is formatted in its home's currency.

**Device**: PDF of a quote attached from the Files app (iOS) and the document picker (Android).

**Depends on**: lot 2.

## Lot 4. Sync engine (without network, without crypto)

**Scope**: operations, HLC, apply and merge rules, deterministic ids, repair rules, schema
versions (`sv`, `extra`, `pending`, `min_sv`), snapshots, behind the `SyncTransport` of lot 2c,
against in-memory doubles of it.

**Acceptance**:
- Property tests: random histories of 2 to 5 devices **over at least two homes**, applied in
  random orders and with duplicates, give identical databases (compared row by row and field by
  field).
- Homes: the same deterministic name (`envelope:2027`) in two homes gives two rows; a reference
  to a row of another home is read as empty; `archived_at` merges as last writer wins; a
  **purge** of one home (a log record, given by the relay double), mixed in random order with
  offline edits of that home carrying later clocks, always ends with no row of it and the other
  home unchanged.
- The cases of [ADR 0003](adr/0003-sync-protocol.md) each have a named test: two closings of
  one occurrence, postpone against done, undo against an edit of the successor, the same article
  drawn twice, deletion against edit, restore, a device on an older `sv` that keeps unknown
  fields.
- A new device that starts from a snapshot and the batches after it equals one that replayed
  everything.
- HLC: a device whose clock is a day ahead does not move the others' clocks.
- The engine knows no transport: the same property tests pass with a double of the relay
  (batches and positions) and a double of a server (a cursor, and an answer that gives the value
  that won for each field), as [ADR 0010](adr/0010-three-ways-to-use-the-app.md) describes.

**Device**: none.

**Depends on**: lot 3 (every entity exists) and lot 2c (the transport interface).

## Lot 4b. Sync with a Housecairn server

**Scope**: the third way of [ADR 0010](adr/0010-three-ways-to-use-the-app.md): `ServerTransport`
on the sync API of a Housecairn server (the web application or the Home Assistant add-on); the
screens address, token and confirmation, with the sentence that the server reads the homes; the
token in `Store`, HTTPS only; the moves alone to server (send this phone's homes into empty
homes, or take the server's homes after an export is offered) and server to alone; the files of
photos and attachments; the server's members of each home, read only, for assignment; the
choice **My Housecairn server** of the first-start screen turned on; the threat model gains the
server as an adversary.

**Acceptance**:
- Against a Housecairn instance started in CI from its image, at the web release that brings the
  sync API: a change made on the phone is read through the web API, and a change made through
  the web API reaches the phone.
- The cases of [ADR 0003](adr/0003-sync-protocol.md) each have a named test with one side on the
  phone offline and the other on the web: the phone and the server end equal, field by field.
- Deletions made on the web reach the phone, those that the web makes without `updated_at` or
  without a row left included (the list of ADR 0010); an erased home is erased from the phone as
  a purge.
- Send with **two homes**: every id on the server is the phone's; a send cut in the middle and
  repeated creates no duplicate. Take: the local homes are removed only after the export was
  offered and the confirmation typed; cancelling leaves the phone as it was.
- Disconnect removes the token from `Store`; unsent changes are listed first.
- No request goes to another host than the address typed; `http://` is refused (unless the
  maintainer decides otherwise, [open questions](#open-questions)); a certificate error is shown
  and cannot be skipped; the token is never in a log, the database or an export (tests).
- A server too old for the sync API is refused with a message that names the version needed.

**Device**: a phone against the Home Assistant add-on and against the web application on a home
server; a day in airplane mode with edits on both sides, then sync.

**Depends on**: lot 4; and a lot of the web repository, `HouseCairn/housecairn`, that brings the
sync API with the needs listed in ADR 0010, merged and released. Not on lots 5 to 7: no crypto,
no relay, no subscription. Whether lot 8 waits for it is the maintainer's call
([open questions](#open-questions)).

## Lot 5. Encryption and family

**Scope**: device keys in secure storage; epochs; batch, snapshot and blob formats of
[protocol.md](protocol.md); membership log; invitation by QR code with the six-digit code;
removal and rotation; recovery code; members and assignment; encrypted export and import.

**Acceptance**:
- Test vectors for every byte format (batch, snapshot, blob, record, envelope, invitation,
  backup) are committed and checked by the Dart code; the relay (lot 6) checks the same file.
- Tampering tests: a changed byte of a header, a ciphertext or a signature is rejected; a record
  signed by a non-admin is rejected, a `purge` of a home included; a batch of a removed device
  above `last_seq` is rejected.
- Blob format: a blob checked against the wrong blob id or space (swapped blobs), cut before its
  `FINAL` chunk, or of another size than its reference, is rejected.
- With **two homes**: an invited phone receives both homes and their photos; after a removal, the
  removed device's keys open no batch of the new epoch, for either home.
- Recovery: from the code alone, a new install gets every row and photo of both homes back
  (in-memory relay).
- Export with two homes, then import into a fresh install, gives the same rows and files; import
  as a copy of one home of the file adds that home with new ids next to the existing ones; a
  wrong passphrase gives a clear error and no partial data.
- Export compliance revisited: `ITSAppUsesNonExemptEncryption` and the store declarations match
  the cryptography of this lot ([ADR 0009](adr/0009-early-testflight-builds.md)).

**Device**: QR invitation between an Android phone and an iPhone; keys survive an app update and
are gone after uninstall; the export file is shared to and imported from the Files app.

**Depends on**: lot 4. Before it starts: a review of the protocol by someone with cryptography
experience is requested (it may run in parallel with lot 5, it must end before lot 8).

## Lot 6. Relay

**Scope**: repository `HouseCairn/housecairn-relay`: Django app `housecairn_relay` and project; every route
of [protocol.md](protocol.md) section 3; storage on SQLite or PostgreSQL and files; quotas;
challenge and token; push to APNs and FCM and the gateway mode; Docker image (amd64, arm64,
non-root, one volume), published by digest with provenance and SBOM; conformance suite; the
app's network client (`RelayTransport`, [ADR 0010](adr/0010-three-ways-to-use-the-app.md)) and
background sync.

**Acceptance**:
- The conformance suite, run against the relay in CI, covers every route, error code and quota.
- The relay verifies the committed byte vectors of lot 5.
- Photos: a photo taken on one phone appears on the other (CI, Android emulators); an upload
  over the quota answers 413 and the photo stays marked "not synced" on its phone; the usage of
  `head` counts batches, snapshots and blobs of both homes; after a purge of a home, its blobs
  are gone from the relay and `usage` went down by their size; orphan blobs older than 7 days are
  deleted by a phone, referenced ones never.
- The push gateway enforces its rate limit per relay and per push token (conformance test).
- The relay never imports a decryption function: a test fails if the code calls any `aead`,
  `seal` open or `stream` pull.
- `docker run` with one volume starts a relay that two app builds sync through (CI, Android
  emulator).
- Logs contain no token, no body, no push token; a test checks it.

**Device**: two phones on different networks sync through a self-hosted relay on a home
server; a wake-up push arrives on iOS (background) and Android; sync resumes after a day
offline.

**Depends on**: lot 5.

## Lot 7. Subscription

**Scope**: products in App Store Connect and Google Play Console (by the maintainer); purchase
and restore in the app; `entitlement` route, Apple JWS verification, Google
`subscriptionsv2`, App Store Server Notifications V2 and Real-time developer notifications;
states active, grace, expired, refunded; read-only period and deletion; relay address field for
self-hosting; the choice **Family sync** of the first-start screen (lot 2c) turned on.

**Acceptance**:
- Unit tests with Apple's and Google's sample payloads: valid, wrong bundle, expired, refunded,
  replayed.
- The relay stores only the fields of [ADR 0006](adr/0006-subscription.md); a test lists the
  columns of the table.
- With `RELAY_REQUIRE_ENTITLEMENT=false` no store call is made.
- One subscription covers a family with two homes: both sync; no route takes a home.

**Device**: purchase, renewal, cancellation and restore in the App Store sandbox and with a
Google Play licence tester; refund seen by the relay.

**Depends on**: lot 6; products created by the maintainer in App Store Connect and Google
Play Console; price and trial decided ([open questions](#open-questions)).

## Lot 8. Beta

**Scope**: the wider beta, several households for a month, on the TestFlight builds of lot 1b
and on Google Play closed testing; hosted relay and push gateway in production, in the European
Union; privacy policy and store data declarations (App Privacy, Data safety); onboarding of sync
with the recovery code step; in-app explanation of what the relay can see; an optional app
lock (biometrics or the phone's code); the findings of the external review fixed.

**Acceptance**:
- The store declarations match the threat model (no data collected beyond purchase and
  identifiers needed for push).
- The hosted relay passes the conformance suite and has a tested backup and restore.
- A checklist of OWASP MASVS level 1 is filled, each item with its proof.

**Device**: the beta used by at least two households for a month, with a written report of
conflicts, lost reminders and sync delays.

**Depends on**: lot 7, lot 1b and the external review of the protocol.

## Lot 9. Publication

**Scope**: store listings in English and French, without screenshots of real homes; version
1.0.0 of the app and of the relay; release notes; documentation of self-hosting the relay;
announcement.

**Acceptance**:
- Signed release builds produced by CI from a tag, with provenance; reproducible Android build
  checked once.
- The protocol document is marked `version 1, stable`.
- Trademark checks done by the maintainer before the announcement.

**Device**: install from the stores on a clean phone, create two homes, invite a second phone,
subscribe, remove the second phone.

**Depends on**: lot 8.

## After v1

Decided by the maintainer as later work, not to be made impossible: reading a web archive
(format 3) in the app; an Android build without Google services (UnifiedPush, F-Droid), after
1.0; a home shared with someone outside the family (a second space on one phone).

Proposed as later work by [ADR 0010](adr/0010-three-ways-to-use-the-app.md), for the maintainer
to confirm ([open questions](#open-questions)): merging the homes of a phone with those
of a server when both have data; a direct move between family sync and a server, without going
through Alone; a phone in two ways at once.

A Housecairn instance acting as the relay, listed here before, is replaced by lot 4b, which
means something else: the server reads the data, where the relay never can.

## Open questions

Choices of the maintainer, still open. Nothing in these documents sets a price.

1. **Price** of the hosted family sync, monthly and yearly.
2. **Free trial**: whether there is one, and how long.
3. **End of a subscription**: proposed in [ADR 0006](adr/0006-subscription.md), 30 days during
   which the space is read only, then deletion, with notices at 7 days and 1 day; to confirm
   or change.
