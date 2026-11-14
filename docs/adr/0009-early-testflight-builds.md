# 0009. TestFlight builds from `main`, from lot 1b on

- Status: proposed. Early TestFlight builds are the maintainer's decision of 2026-11-14; the
  way they are built and uploaded is the choice this record proposes.
- Date: 2026-11-14

## Context

The plan put TestFlight in lot 8, after sync, encryption, the relay and the subscription. The
maintainer wants the app on iPhones much earlier: **internal and external TestFlight builds
from `main` once the maintainer enables it**, so that every merged lot, from the first usable
screens of lot 2, can be tried on a phone without Xcode. Lot 8 keeps the wider beta.

Constraints of the project that apply: no third-party action in CI, every action pinned to a
full commit SHA, `GITHUB_TOKEN` read only, zizmor clean
([ADR 0001](0001-flutter-stack-and-packages.md), lot 1); no account identifier is committed to
this public repository; a pull request never reaches a secret.

## Decision

**A separate lot, 1b**, between lots 1 and 2: it touches only CI, ships no app code, and is
reviewed as supply chain work, while lot 2 is already the largest lot of the plan. Merged before
lot 2 or alongside it, it puts lot 2's screens in a TestFlight build as soon as lot 2 is merged.

**One workflow, `.github/workflows/ios-testflight.yml`, two jobs**:

- `TestFlight plan`, on every event (pull request, merge queue, push to `main`, manual run):
  checks the committed export options (`.github/scripts/check_testflight_config.py`) and writes
  in the run summary whether the run uploads and why not. It reads no secret.
- `TestFlight upload`, only on `main` (push or manual run) and only when the repository
  variable `TESTFLIGHT_UPLOAD` is `true`. Until then it is **skipped**, not failed. It is the
  only job that enters the `testflight` environment. The gate is a variable rather than the
  presence of the secrets because a job cannot test an environment's secrets without entering
  it, and GitHub creates an environment that a job references and that does not exist: gating
  on the secrets would create an unprotected environment on the first push. Once enabled, a
  missing secret fails the job, so that a run never silently ships nothing.

Neither job is a required check of `main`.

**Signing by cloud signing, authenticated by an App Store Connect API key**: the archive is
built unsigned (`CODE_SIGNING_ALLOWED=NO`), then `xcodebuild -exportArchive` signs it with a
cloud-managed distribution certificate and uploads it, with `-allowProvisioningUpdates`,
`-authenticationKeyPath`, `-authenticationKeyID` and `-authenticationKeyIssuerID`. No
certificate, profile or keychain is stored as a secret or created on the runner. Archiving
with automatic signing instead would make Xcode create a new development certificate on each
fresh runner, whose private key is lost with the runner, until the account's limit stops every
build.

**Secrets**, in the `testflight` environment only: `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8`
(the text of the `.p8` file) and `APPLE_TEAM_ID`. The key is written with `umask 077` and mode
600 under `$RUNNER_TEMP`, removed by a `trap` at the end of its step and by a final step that
runs whatever happened; it is never printed. The team identifier is added to a copy of
`ios/ExportOptions-testflight.plist` at run time; the committed file holds none.

**Upload**: `destination` `upload` in the export options, so that `xcodebuild` signs and
uploads in one command, with the same key. Apple lists Xcode, `altool`, Transporter and the
App Store Connect API as the ways to upload a build
([Upload builds](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds),
read on 2026-11-14). `altool --upload-app`, the command most CI examples use, is marked
deprecated by Apple in favour of `--upload-package`
([Using altool](https://help.apple.com/asc/appsaltool/en.lproj/static.html)), which also needs
the numeric Apple ID of the app as one more value. The export with an API key is the flow shown
by Apple for automated distribution
([Distribute apps in Xcode with cloud signing, WWDC21](https://developer.apple.com/videos/play/wwdc2021/10204/)).
No gem and no other tool is installed.

**Xcode 26**: App Store Connect accepts iOS builds made with Xcode 26 or later (same Apple
page). The job runs on `macos-26` and selects `/Applications/Xcode_26.6.app` by its path, then
checks the major version.

**Build number** = `github.run_number` of this workflow, given to
`flutter build ios --config-only --build-number`; the job checks it in the archive, with the
bundle id `app.housecairn.mobile`. The version name is the one of `pubspec.yaml`.

**Export compliance**: `ITSAppUsesNonExemptEncryption` is `false` in `Info.plist`, the
maintainer's decision: until lot 5 no data leaves the phone and the stored data is encrypted by
the system ([ADR 0002](0002-local-storage-and-migrations.md)). **The value must be revisited
before lot 5 is merged**, when the app gets its own cryptography. With the key set, App Store
Connect does not ask the export compliance questions for each uploaded build; without it, it
does ([ITSAppUsesNonExemptEncryption](https://developer.apple.com/documentation/bundleresources/information-property-list/itsappusesnonexemptencryption),
[Provide export compliance information for beta builds](https://developer.apple.com/help/app-store-connect/test-a-beta-version/provide-export-compliance-information-for-beta-builds)).

**What a TestFlight build contains**: the build of a commit of `main`, with the app's data on the phone
only. Before lot 6 there is no relay, and the app makes no network call. A TestFlight build
never points at a hosted relay before lot 8 puts one in production.

## Consequences

- Every merge on `main` costs one macOS run once uploads are enabled; pull requests cost one
  short Linux job.
- A build is a pre-release: the database is migrated by the tested migrations of
  [ADR 0002](0002-local-storage-and-migrations.md), but the data of a pre-release build may be
  lost before 1.0.
- TestFlight builds expire after 90 days.
- Cloud signing needs an API key with a broad role. It lives only in the environment of the
  upload job, which runs only on `main`; its exposure is the main risk of this lot.
- A rerun of an upload that already reached App Store Connect is refused for its duplicate build
  number; a new run gets a new number.
- The unsigned iOS build of lot 1 runs on `macos-15` with that image's default Xcode, the upload
  on Xcode 26: a change that builds there may still fail here. Aligning the two is left to a
  later change of the lot 1 workflow.
- An unsigned archive carries no entitlements. When a lot adds one (push notifications, lot 6),
  the job embeds the entitlements file before the export.
- None of this is exercised before the first enabled run: the plan job runs on every pull
  request, the upload job has never run.
