#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

exec swift run \
  --package-path "$ROOT_DIR/.codex/police" \
  --quiet \
  police \
  --root "$ROOT_DIR" \
  "$@"
