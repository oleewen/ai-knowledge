#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
bash "$ROOT/scripts/check-docs-meta-naming.sh"
echo "01_clean_repo: OK"
