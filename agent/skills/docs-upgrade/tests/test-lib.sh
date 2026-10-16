#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
DOCS_UPGRADE_SCRIPT="$ROOT_DIR/agent/skills/docs-upgrade/scripts/docs-upgrade.sh"
source "$ROOT_DIR/agent/scripts/test-core.sh"

new_tmp_dir() {
  mktemp -d "${TMPDIR:-/tmp}/docs-upgrade-tests.XXXXXX"
}

pin_workspace_for_repo() {
  local repo="${1:?}" agent_root="${2:?}" agent_dir="${3:-.agents}"
  mkdir -p "${agent_root}/${agent_dir}"
  printf 'WORK_SPACE=%s\n' "$(dirname "$repo")" >"${agent_root}/${agent_dir}/configs"
}

ensure_test_agent_home() {
  local tmp="${1:?}"
  local home="${tmp}/fake-home"
  mkdir -p "${home}/.agents/scripts"
  printf '%s\n' '#!/usr/bin/env bash' '# test stub' >"${home}/.agents/scripts/docs-core.sh"
  export HOME="$home"
}
