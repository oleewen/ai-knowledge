#!/usr/bin/env bash
set -euo pipefail
RUN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for f in "$RUN_DIR"/cases/*.sh; do
  printf '>>> %s\n' "$(basename "$f")"
  bash "$f"
done
