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
  pubspec.yaml pubspec.lock l10n.yaml lib/l10n/app_fr.arb build.yaml fonts/a.ttf \
  "lib/écran.dart" 'lib/a"b.dart' \
  .github/scripts/app-changed.sh .github/scripts/check_testflight_config.py \
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

# Paths git would quote or escape (non-ASCII, double quote): both the addition
# and the deletion of such a file in lib/ must be seen as an app change.
git config core.quotepath true
mkdir -p fonts
git reset -q --hard "$app"; start=$(git rev-parse HEAD)
for f in "lib/écran.dart" 'lib/a"b.dart' fonts/f.ttf; do
  git reset -q --hard "$start"; mkdir -p "$(dirname "$f")"; echo c > "$f"; git add .; git commit -qm "add $f"
  expect "diff added $f" app=true "$("$script" diff "$start" HEAD 2>/dev/null)"
done
git reset -q --hard "$start"; mkdir -p fonts
echo c > "lib/écran.dart"; echo c > 'lib/a"b.dart'; echo c > fonts/f.ttf
git add .; git commit -qm quoted; q=$(git rev-parse HEAD)
for f in "lib/écran.dart" 'lib/a"b.dart' fonts/f.ttf; do
  git reset -q --hard "$q"; base2=$(git rev-parse HEAD)
  git rm -q "$f"; git commit -qm "rm $f"
  expect "diff deleted $f" app=true "$("$script" diff "$base2" HEAD 2>/dev/null)"
done
# Only docs changed next to a quoted path that is not an app path: still false.
git reset -q --hard "$q"; mkdir -p docs; echo é > "docs/é \"x\".md"; git add .; git commit -qm d
expect "diff quoted path outside the app" app=false "$("$script" diff "$q" HEAD 2>/dev/null)"

# The list of the script and on.push.paths of the TestFlight workflow must agree
# (the script also lists android/ and ci.yml, which only the CI builds use).
cd "$here/../.."
from_script=$(sed -n '/^is_app_path()/,/return 0/p' "$script" | tr -d '\\' | tr ' |)' '\n\n\n\n' \
  | grep -E '^[A-Za-z.]' | grep -vE '^(is_app_path\(|case|in|return|0)$' | sed 's#/\*$#/**#' \
  | grep -vxE 'android/\*\*|\.github/workflows/ci\.yml' | sort)
from_workflow=$(sed -n '/^  push:/,/^  workflow_dispatch:/p' .github/workflows/ios-testflight.yml \
  | sed -n 's/^ *- //p' | sort)
if [ -n "$from_script" ] && [ "$from_script" = "$from_workflow" ]; then
  echo "ok   app-changed.sh list matches on.push.paths of ios-testflight.yml"
else
  echo "FAIL path lists diverge (script on the left, workflow on the right):"
  diff <(echo "$from_script") <(echo "$from_workflow") || true
  fail=1
fi
exit "$fail"
