#!/usr/bin/env bash
# Says whether a change touches the delivered app, so that CI skips the
# Android and iOS builds (and the macOS minutes) for a change that cannot
# alter them: documentation, issue forms, other workflows, tests.
#
#   app-changed.sh classify          paths on stdin, one per line: prints
#                                    "app" or "other" for each
#   app-changed.sh diff <old> <new>  compares two commits, prints app=true or
#                                    app=false (and appends it to $GITHUB_OUTPUT)
#
# `diff` fails open: when the comparison cannot be made (unknown commit, first
# push, shallow history) the answer is app=true, so a build is never skipped
# by mistake. Git only, no third-party action.
#
# Keep the list in step with `on.push.paths` of
# .github/workflows/ios-testflight.yml (same list, plus android/ and ci.yml here
# because the Android build is checked too). test-app-changed.sh fails when the
# two lists diverge. This script and check_testflight_config.py are in the list
# because a change to either changes what is built or uploaded.
set -euo pipefail

is_app_path() {
  case "$1" in
    lib/* | ios/* | android/* | assets/* | fonts/* | \
      pubspec.yaml | pubspec.lock | l10n.yaml | build.yaml | \
      .github/scripts/install-flutter.sh | .github/scripts/app-changed.sh | \
      .github/scripts/check_testflight_config.py | \
      .github/workflows/ci.yml | .github/workflows/ios-testflight.yml)
      return 0 ;;
    *) return 1 ;;
  esac
}

classify() {
  local path
  while IFS= read -r path; do
    if is_app_path "$path"; then echo "app"; else echo "other"; fi
  done
}

emit() {
  echo "app=$1"
  if [ -n "${GITHUB_OUTPUT:-}" ]; then echo "app=$1" >> "$GITHUB_OUTPUT"; fi
}

diff_commits() {
  local old="$1" new="$2" list path count=0
  list=$(mktemp)
  # -z and quotepath=off: paths come out raw (NUL separated), never quoted or
  # escaped, so "lib/écran.dart" or a name with a quote still matches lib/*.
  if ! git -c core.quotepath=off diff -z --name-only --no-renames "$old" "$new" -- >"$list" 2>/dev/null; then
    rm -f "$list"
    echo "Cannot compare $old with $new: building." >&2
    emit true
    return
  fi
  while IFS= read -r -d '' path; do
    count=$((count + 1))
    if is_app_path "$path"; then
      rm -f "$list"
      echo "App file changed: $path" >&2
      emit true
      return
    fi
  done <"$list"
  rm -f "$list"
  echo "No file of the app changed ($count file(s) compared)." >&2
  emit false
}

case "${1:-}" in
  classify) classify ;;
  diff) diff_commits "${2:?old commit}" "${3:?new commit}" ;;
  *) echo "usage: $0 classify | diff <old> <new>" >&2; exit 2 ;;
esac
