#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
DOCS_INSTALL_SCRIPT="$ROOT_DIR/agent/skills/docs-install/scripts/docs-install.sh"
AGENT_INSTALL_SCRIPT="$ROOT_DIR/agent/skills/agent-install/scripts/agent-install.sh"
source "$ROOT_DIR/agent/scripts/test-core.sh"

new_tmp_dir() {
  mktemp -d "${TMPDIR:-/tmp}/docs-install-tests.XXXXXX"
}

# 把 WORK_SPACE 写到 agent 安装树的 configs。同一 agent 树只保留最后一次写入的工作区。
# 用法：pin_workspace_for_repo <repo_abs> <agent_root> [agent_dir]
pin_workspace_for_repo() {
  local repo="${1:?}" agent_root="${2:?}" agent_dir="${3:-.agents}"
  mkdir -p "${agent_root}/${agent_dir}"
  printf 'WORK_SPACE=%s\n' "$(dirname "$repo")" >"${agent_root}/${agent_dir}/configs"
}

# 在 TMP 下造可探测的 Agent 安装树，并 export HOME（须在 new_tmp_dir 之后调用）
# 用法：ensure_test_agent_home <tmp_dir>
ensure_test_agent_home() {
  local tmp="${1:?}"
  local home="${tmp}/fake-home"
  mkdir -p "${home}/.agents/scripts"
  # 探测只要求存在 docs-core.sh；内容可空桩
  printf '%s\n' '#!/usr/bin/env bash' '# test stub' >"${home}/.agents/scripts/docs-core.sh"
  printf 'WORK_SPACE=/\n' >"${home}/.agents/configs"
  export HOME="$home"
}
