#!/usr/bin/env bash
# Installs the pinned Flutter SDK from its official archive, without a
# third-party action (the actions allowed in the organisation are GitHub's own
# and a few named ones).
#
# Usage: .github/scripts/install-flutter.sh <archive directory>
#
# The archive is downloaded into <archive directory> unless it is already
# there (restored by actions/cache), then checked against the SHA-256 written
# below, on every run, cached or not: a cache entry is never trusted as is.
# The SDK is extracted into $RUNNER_TEMP/flutter and its bin directory added
# to $GITHUB_PATH. The version and the checksums come from the official
# release lists, read on 2026-11-14:
#   https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json
#   https://storage.googleapis.com/flutter_infra_release/releases/releases_macos.json
# (entry "3.50.0", channel stable, Dart 3.14.0). To update: change VERSION and
# the two checksums together, from those files, in one pull request; the
# version is also the `flutter:` constraint of pubspec.yaml.
set -euo pipefail

VERSION=3.50.0
BASE=https://storage.googleapis.com/flutter_infra_release/releases
LINUX_ARCHIVE=stable/linux/flutter_linux_${VERSION}-stable.tar.xz
LINUX_SHA256=6ea2d806fd57269ae783e6788e2a81fc26eaad782f1e0d0ff38623bb765ff9f5
MACOS_ARM64_ARCHIVE=stable/macos/flutter_macos_arm64_${VERSION}-stable.zip
MACOS_ARM64_SHA256=ed2d08a3e3c023e84cbe9316d21bd88fda6ee9552f90c1eb4da41a07c170fb35

[ "$#" -eq 1 ] || { echo "usage: install-flutter.sh <archive directory>" >&2; exit 2; }
dir=$1
mkdir -p "$dir"

case "$(uname -s)-$(uname -m)" in
  Linux-x86_64) archive=$LINUX_ARCHIVE; sha256=$LINUX_SHA256 ;;
  Darwin-arm64) archive=$MACOS_ARM64_ARCHIVE; sha256=$MACOS_ARM64_SHA256 ;;
  *) echo "install-flutter.sh: no pinned archive for $(uname -s) $(uname -m)" >&2; exit 1 ;;
esac
file="$dir/$(basename "$archive")"

if [ ! -f "$file" ]; then
  echo "Downloading $BASE/$archive"
  curl --fail --silent --show-error --location --retry 4 --retry-all-errors \
    --proto '=https' --tlsv1.2 --output "$file.part" "$BASE/$archive"
  mv "$file.part" "$file"
else
  echo "Using the cached archive $file"
fi

echo "$sha256  $file" > "$dir/SHA256SUMS"
if command -v sha256sum >/dev/null; then
  (cd "$dir" && sha256sum --check --strict SHA256SUMS)
else
  (cd "$dir" && shasum --algorithm 256 --check --strict SHA256SUMS)
fi

dest="${RUNNER_TEMP:?}"
rm -rf "$dest/flutter"
case "$file" in
  *.tar.xz) tar -xJf "$file" -C "$dest" ;;
  *.zip) unzip -q "$file" -d "$dest" ;;
esac
# The archive is a Git checkout owned by another user than the runner's.
git config --global --add safe.directory "$dest/flutter"
echo "$dest/flutter/bin" >> "${GITHUB_PATH:?}"

export PATH="$dest/flutter/bin:$PATH"
# No analytics from the tools themselves, then a check of the version.
flutter config --no-analytics --no-cli-animations >/dev/null
dart --disable-analytics >/dev/null
actual=$(flutter --version --machine | python3 -c 'import json, sys; print(json.load(sys.stdin)["frameworkVersion"])')
[ "$actual" = "$VERSION" ] || { echo "install-flutter.sh: got Flutter $actual, expected $VERSION" >&2; exit 1; }
echo "Flutter $actual installed in $dest/flutter"
