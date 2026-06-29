#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
DOCS_INSTALL_SCRIPT="$ROOT_DIR/scripts/docs-install.sh"
AGENT_INSTALL_SCRIPT="$ROOT_DIR/scripts/agent-install.sh"
source "$ROOT_DIR/agent/scripts/test-core.sh"

new_tmp_dir() {
  mktemp -d "${TMPDIR:-/tmp}/docs-install-tests.XXXXXX"
}
