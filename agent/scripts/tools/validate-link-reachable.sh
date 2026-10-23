#!/usr/bin/env bash
# validate-link-reachable.sh — 校验 agent 下 Markdown 链接：agent 内互链须存在；跨出 agent 须落在
# 仓库路径或文档路径下（且非 .git），落实 link-reachability §1.1 强校验。
# 在仓库根执行：bash agent/scripts/tools/validate-link-reachable.sh
# 文档路径来自 .docsconfig 与工作区文件（见 lib/docsconfig.sh；不向子进程 export，仅前缀传参）。
# 只检查可点链接；测试夹具由所属测试校验，输出模板按最终文件位置解析。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/docsconfig.sh"
docsconfig_bootstrap_validate

repo_abs="$(docsconfig_repo_abs)"
doc_abs="$(docsconfig_doc_abs)"
AGENT_TREE="$repo_abs/agent"

readonly EXIT_FAIL=1

require_agent_dir() {
  [[ -d "$AGENT_TREE" ]] || {
    echo "[ERROR] 未找到 ${AGENT_TREE}（仓库路径=$repo_abs）" >&2
    exit "$EXIT_FAIL"
  }
}

# §2.2.2：不 export；仅对本次 python3 进程传入环境变量
run_link_check() {
  DOC_ABS="$doc_abs" REPO_ABS="$repo_abs" AGENT_TREE="$AGENT_TREE" python3 "$SCRIPT_DIR/validate_link_reachable.py"
}

main() {
  require_agent_dir
  run_link_check
}

main "$@"
