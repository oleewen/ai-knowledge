#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
"${BASH:-$(command -v bash)}" "$ROOT/agent/scripts/tools/forbidden-ref-outer.sh"
echo "01_clean_repo: OK"
