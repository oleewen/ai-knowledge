#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
DOCS_INSTALL_SCRIPT="$ROOT_DIR/agent/skills/docs-install/scripts/docs-install.sh"
AGENT_INSTALL_SCRIPT="$ROOT_DIR/agent/skills/agent-install/scripts/agent-install.sh"
source "$ROOT_DIR/agent/scripts/test-core.sh"

new_tmp_dir() {
  mktemp -d "${TMPDIR:-/tmp}/docs-install-tests.XXXXXX"
}

# 在 TMP 下造可探测的 Agent 安装树，并 export HOME（须在 new_tmp_dir 之后调用）
# 用法：ensure_test_agent_home <tmp_dir>
ensure_test_agent_home() {
  local tmp="${1:?}"
  local home="${tmp}/fake-home"
  mkdir -p "${home}/.agents/scripts"
  # 探测只要求存在 docs-core.sh；内容可空桩
  printf '%s\n' '#!/usr/bin/env bash' '# test stub' >"${home}/.agents/scripts/docs-core.sh"
  export HOME="$home"
}
