#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if command -v swiftlint >/dev/null 2>&1; then
  exec swiftlint lint --config "$ROOT_DIR/.swiftlint.yml" "$@"
fi

if command -v docker >/dev/null 2>&1; then
  exec docker run --rm \
    -v "$ROOT_DIR:$ROOT_DIR" \
    -w "$ROOT_DIR" \
    ghcr.io/realm/swiftlint:latest \
    lint --config .swiftlint.yml "$@"
fi

echo "swiftlint is not installed and docker is unavailable" >&2
exit 127
