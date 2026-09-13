#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
DOCS_UPGRADE_SCRIPT="$ROOT_DIR/agent/skills/docs-upgrade/scripts/docs-upgrade.sh"
source "$ROOT_DIR/agent/scripts/test-core.sh"

new_tmp_dir() {
  mktemp -d "${TMPDIR:-/tmp}/docs-upgrade-tests.XXXXXX"
}
