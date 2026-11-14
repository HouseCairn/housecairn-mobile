# Contributing to Housecairn mobile

Thank you for your interest. This repository is at an early stage: the app has its
foundations (lot 1 of the [plan](docs/plan.md)) and no feature yet. Before starting
significant work, please open an issue to discuss it.

By participating, you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Before your pull request can be merged

1. **Sign the CLA.** This repository is part of the Housecairn project and uses the same
   [Contributor License Agreement](https://github.com/HouseCairn/housecairn/blob/main/CLA.md)
   as the web application. You keep the copyright of your work; the agreement lets the
   maintainer distribute contributions under the project's license (AGPL-3.0-only) and
   under other licenses, which publishing the app on the App Store and Google Play needs
   ([ADR 0007](docs/adr/0007-license.md)). On your first pull request, the CLA check posts
   a comment; read the CLA, then sign it by posting this comment on the pull request,
   exactly as written, with nothing else in the comment:

   ```text
   I have read the CLA Document and I hereby sign the CLA
   ```

   The `CLA` check then turns green. Your signature is recorded in this repository, on
   the `cla-signatures` branch, with your GitHub account id and the fingerprint of the CLA
   text, and covers all your later pull requests here. A comment signs only for its own
   author. The check requires a signature from the author of every commit and from the
   person who opens the pull request, so each commit must be authored with an email
   address linked to a GitHub account (or its noreply address). If the check does not
   update, comment `recheck`. The CLA is still a draft pending legal review: until that
   review is done, external contributions cannot be merged.
2. **Sign off every commit** with the
   [Developer Certificate of Origin](https://developercertificate.org/):

   ```sh
   git commit -s -m "docs: fix a typo in the protocol"
   ```

   This adds a `Signed-off-by: Your Name <you@example.com>` line, with the same address as
   the commit author.

## Local development

Requirements: Flutter 3.50.0 stable (the version pinned in
`.github/scripts/install-flutter.sh`), with the Android SDK for Android builds and Xcode on
macOS for iOS builds.

```sh
flutter pub get --enforce-lockfile         # the locked packages; also regenerates lib/l10n
dart format lib test tool                  # format
flutter analyze --fatal-infos              # static analysis
flutter test                               # unit and widget tests
dart run tool/check_licenses.dart          # licence of every dependency
flutter run                                # on a connected phone or an emulator
```

After a change to the database schema (`lib/data/database.dart`), regenerate the drift files
and the migration tests, then commit them:

```sh
dart run build_runner build
dart run drift_dev make-migrations
dart run drift_dev schema generate drift_schemas/housecairn/ test/drift/housecairn/generated/
```

The recurrence vectors (`test/fixtures/recurrence_vectors.json`), the task templates
(`assets/task_templates.yaml`) and the web values of `design/tokens.json` come from a release of
the web application, pinned in `tool/web_alignment.json`
([plan](docs/plan.md#alignment-with-the-web-application)); CI fails when they are not what that
release gives. Never edit them by hand: move the pin, which regenerates them. This needs git, a
clone of the web repository and [uv](https://docs.astral.sh/uv/) 0.13.7 (the version of
`.github/scripts/install-uv.sh`):

```sh
git clone https://github.com/HouseCairn/housecairn ../housecairn
python3 tool/web_alignment.py check --web ../housecairn                    # what CI runs
python3 tool/web_alignment.py update --web ../housecairn --release vX.Y.Z  # move the pin
flutter test                                                               # a red test: port the rule in Dart
```

The `Web alignment` workflow does the same every day and opens the pull request itself.

Every string shown to people goes in `lib/l10n/app_en.arb` (with a description) and
`lib/l10n/app_fr.arb`; a test fails when a screen shows a string that is in neither. A new
dependency must have a licence listed in `tool/licenses/allowed-licenses.txt`, and no
analytics, crash reporting or advertising package may enter the tree
(`tool/licenses/forbidden-packages.txt`).

## Conventions

- English is the language of the repository: code, documents, commit messages.
- One pull request per subject; documents change in the same pull request as the code they
  describe.
- Declare the AI tool and model you used, if any, in the pull request.
- Report security issues privately, as described in the [security policy](SECURITY.md),
  never in a public issue.
