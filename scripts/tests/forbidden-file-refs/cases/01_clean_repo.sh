#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
bash "$ROOT/scripts/check-forbidden-file-refs.sh"
echo "01_clean_repo: OK"
