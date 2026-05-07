#!/usr/bin/env bash
set -euo pipefail

APP="${1:-CodexMaxx.app}"
VERSION="${VERSION:-0.9.1}"
ZIP="${2:-CodexMaxx-$VERSION.zip}"

rm -f "$ZIP"
ditto -c -k --keepParent "$APP" "$ZIP"
shasum -a 256 "$ZIP" > "$ZIP.sha256"
echo "$ZIP"
