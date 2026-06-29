#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHANGE_SCRIPT="$ROOT_DIR/agent/skills/docs-change/scripts/change-indexing.sh"
source "$ROOT_DIR/agent/scripts/test-core.sh"

new_tmp_dir() { mktemp -d "${TMPDIR:-/tmp}/docs-change-tests.XXXXXX"; }
