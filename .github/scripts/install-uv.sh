#!/usr/bin/env bash
# Installs the pinned uv from its official release archive, without a
# third-party action, for tool/web_alignment.py (it builds the environment of
# the web application to generate the recurrence vectors).
#
# Usage: .github/scripts/install-uv.sh <archive directory>
#
# The archive is downloaded into <archive directory>, checked against the
# SHA-256 written below, extracted into $RUNNER_TEMP/uv and added to
# $GITHUB_PATH. The version is the one of the web repository's CI
# (astral-sh/setup-uv with version 0.13.7); the checksum is the `.sha256` file
# of that release, read on 2026-11-14:
#   https://github.com/astral-sh/uv/releases/download/0.13.7/uv-x86_64-unknown-linux-gnu.tar.gz.sha256
# To update: change VERSION and the checksum together, in one pull request.
set -euo pipefail

VERSION=0.13.7
ARCHIVE=uv-x86_64-unknown-linux-gnu.tar.gz
SHA256=c5221ff41b7892bfc223543883600125f6a47fe845093e0f5bdff4f359196d83

[ "$#" -eq 1 ] || { echo "usage: install-uv.sh <archive directory>" >&2; exit 2; }
[ "$(uname -s)-$(uname -m)" = Linux-x86_64 ] || { echo "install-uv.sh: Linux x86_64 only" >&2; exit 1; }
dir=$1
mkdir -p "$dir"
file="$dir/$ARCHIVE"
curl --fail --silent --show-error --location --retry 4 --retry-all-errors \
  --proto '=https' --tlsv1.2 --output "$file" \
  "https://github.com/astral-sh/uv/releases/download/$VERSION/$ARCHIVE"
echo "$SHA256  $file" | sha256sum --check --strict

dest="${RUNNER_TEMP:?}/uv"
rm -rf "$dest"
mkdir -p "$dest"
tar -xzf "$file" -C "$dest" --strip-components=1
echo "$dest" >> "${GITHUB_PATH:?}"
actual=$("$dest/uv" --version | cut -d' ' -f2)
[ "$actual" = "$VERSION" ] || { echo "install-uv.sh: got uv $actual, expected $VERSION" >&2; exit 1; }
echo "uv $actual installed in $dest"
