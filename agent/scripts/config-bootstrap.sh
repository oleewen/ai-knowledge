#!/usr/bin/env bash
# config-bootstrap.sh — 从目标工程根 .docsconfig 读入文档根与仓库根约定到当前 shell
# 禁止 export DOC_ROOT / REPO_ROOT / DOC_DIR / AGENT_*（仅当前 shell 赋值）。
#
# Source 成功后由本文件设置的变量（供 validate-*.sh 使用）：
#   DOC_ROOT    — 文档树根绝对路径（由 .docsconfig 解析并展开 ~/）
#   REPO_ROOT   — 目标工程 Git 仓库根绝对路径
#   DOC_DIR     — 相对 REPO_ROOT 的文档路径段
#   AGENT_ROOT  — 可选
#   AGENT_DIRS  — 可选
#
# -----------------------------------------------------------------------------
# 依赖同目录 docs-config.sh（由 agent-install 安装）
# -----------------------------------------------------------------------------
_BOOTSTRAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_CFG_SH="${_BOOTSTRAP_DIR}/docs-config.sh"
if [[ ! -f "$_CFG_SH" ]]; then
  printf '[config] 未找到同目录 docs-config.sh（请执行 agent-install.sh 安装 Agent）: %s\n' "$_CFG_SH" >&2
  if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then exit 1; else return 1; fi
fi
# shellcheck source=/dev/null
source "$_CFG_SH"

# -----------------------------------------------------------------------------
# 返回已加载的 DOC_ROOT（与 .docsconfig 一致）；无 override。
# -----------------------------------------------------------------------------
resolve_repo_doc_root() {
  printf '%s' "${DOC_ROOT:-}"
}

# 解析承载 .docsconfig 的 REPO_ROOT（目标工程仓库根）
find_repo_root_for_docsconfig() {
  local script_dir="${1:?script_dir}"
  local gr
  for gr in "$(git -C "${PWD}" rev-parse --show-toplevel 2>/dev/null)" \
            "$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null)"; do
    [[ -n "$gr" && -f "$gr/.docsconfig" ]] && {
      printf '%s' "$gr"
      return 0
    }
  done
  local d i
  d="$(pwd)"
  for ((i = 0; i < 32; i++)); do
    [[ -f "$d/.docsconfig" ]] && {
      printf '%s' "$d"
      return 0
    }
    [[ "$d" == "/" ]] && break
    d="$(dirname "$d")"
  done
  return 1
}

docsconfig_parse_into_globals() {
  local path="${1:?}"
  docsconfig_read_into "$path" DOC_ROOT REPO_ROOT DOC_DIR AGENT_ROOT AGENT_DIRS \
    || return 1
}

_config_bootstrap_hint_knowledge_init() {
  cat >&2 <<'EOF'
[config] 请使用 knowledge-init.sh 初始化并写入 .docsconfig，例如：
  bash scripts/knowledge-init.sh --scope=config <目标工程文档目录>
（在已克隆 ai-knowledge 的仓库根执行；路径请按实际工程调整。）
EOF
}

# Usage: validate_bootstrap_docsconfig "<调用方脚本所在目录>"
# 成功：设置 DOC_ROOT、REPO_ROOT、DOC_DIR（不 export）；可选 AGENT_*。
# 失败：stderr 说明并 exit 1
validate_bootstrap_docsconfig() {
  local script_dir="${1:?script_dir}"
  local rr=""

  if ! rr="$(find_repo_root_for_docsconfig "$script_dir")"; then
    echo "[config] 未找到目标仓库根下的 .docsconfig。" >&2
    _config_bootstrap_hint_knowledge_init
    exit 1
  fi

  local cfg="$rr/.docsconfig"
  [[ -f "$cfg" ]] || {
    echo "[config] 内部错误：预期存在 $cfg" >&2
    exit 1
  }

  docsconfig_parse_into_globals "$cfg" || {
    _config_bootstrap_hint_knowledge_init
    exit 1
  }

  if [[ -z "${DOC_ROOT:-}" || -z "${REPO_ROOT:-}" || -z "${DOC_DIR:-}" ]]; then
    echo "[config] .docsconfig 缺少必需的 DOC_ROOT、REPO_ROOT 或 DOC_DIR。" >&2
    _config_bootstrap_hint_knowledge_init
    exit 1
  fi
}
