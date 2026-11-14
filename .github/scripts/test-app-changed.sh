#!/usr/bin/env bash
# Tests of app-changed.sh: classification of paths, and `diff` on a throwaway
# repository (docs only, app file, unknown commit). No network.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
script="$here/app-changed.sh"
fail=0
expect() { # <name> <expected> <actual>
  if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1: expected '$2', got '$3'"; fail=1; fi
}

for p in lib/main.dart ios/Runner/Info.plist android/app/build.gradle.kts assets/x.yaml \
  pubspec.yaml pubspec.lock l10n.yaml lib/l10n/app_fr.arb build.yaml \
  .github/scripts/install-flutter.sh .github/workflows/ci.yml .github/workflows/ios-testflight.yml; do
  expect "app: $p" app "$(echo "$p" | "$script" classify)"
done
for p in docs/plan.md README.md .github/ISSUE_TEMPLATE/bug.yml .github/workflows/cla.yml \
  .github/workflows/zizmor.yml test/app_test.dart tool/generate_icons.py design/tokens.json; do
  expect "other: $p" other "$(echo "$p" | "$script" classify)"
done

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"
git init -q .
git config user.email t@example.com
git config user.name t
mkdir docs lib
echo a > docs/a.md; echo a > lib/a.dart
git add .; git commit -qm base; base=$(git rev-parse HEAD)
echo b > docs/a.md; git commit -qam docs; docs=$(git rev-parse HEAD)
echo b > lib/a.dart; git commit -qam app; app=$(git rev-parse HEAD)
expect "diff docs only" app=false "$("$script" diff "$base" "$docs" 2>/dev/null)"
expect "diff with app file" app=true "$("$script" diff "$base" "$app" 2>/dev/null)"
expect "diff unknown commit fails open" app=true \
  "$("$script" diff 0000000000000000000000000000000000000000 "$app" 2>/dev/null)"
exit "$fail"
