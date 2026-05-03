#!/usr/bin/env bash
# config-bootstrap.sh — 从目标工程根 .docsconfig 读入文档根与仓库根约定到当前 shell
# 禁止 export DOC_ROOT / REPO_ROOT / DOC_DIR / AGENT_*（仅当前 shell 赋值）。
#
# Source 成功后由本文件设置的变量（供 validate-*.sh 使用）：
#   DOC_ROOT         — 文档树根绝对路径（由 .docsconfig 解析并展开 ~/）
#   REPO_ROOT        — 目标工程 Git 仓库根绝对路径
#   DOC_DIR          — 相对 REPO_ROOT 的文档路径段
#   AGENT_ROOT       — 可选
#   AGENT_DIRS       — 可选
#   KNOWLEDGE_TYPE   — 可选：application | system | company（未写则为空）
#
# -----------------------------------------------------------------------------
# 依赖同目录 docs-core.sh（由 agent-install 安装）
# -----------------------------------------------------------------------------
_BOOTSTRAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_CFG_SH="${_BOOTSTRAP_DIR}/docs-core.sh"
if [[ ! -f "$_CFG_SH" ]]; then
  printf '[config] 未找到同目录 docs-core.sh（请执行 agent-install.sh 安装 Agent）: %s\n' "$_CFG_SH" >&2
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
  local gr last=''
  local pwd_root script_root
  pwd_root="$(git -C "${PWD}" rev-parse --show-toplevel 2>/dev/null || true)"
  script_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"
  for gr in "$pwd_root" "$script_root"; do
    [[ -n "$gr" && "$gr" == "$last" ]] && continue
    last="$gr"
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
  KNOWLEDGE_TYPE=""
  docsconfig_read_into "$path" DOC_ROOT REPO_ROOT DOC_DIR AGENT_ROOT AGENT_DIRS KNOWLEDGE_TYPE \
    || return 1
}

config_bootstrap_hint_docs_install() {
  cat >&2 <<'EOF'
[config] 请使用 docs-install.sh 初始化并写入 .docsconfig，例如：
  bash scripts/docs-install.sh --scope=config --target <目标工程文档目录>
（在已克隆 ai-knowledge 的仓库根执行；路径请按实际工程调整；仍兼容 --target=<目录>）
EOF
}

config_bootstrap_fail() {
  local msg="${1:-[config] 配置校验失败。}"
  echo "$msg" >&2
  config_bootstrap_hint_docs_install
  if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    exit 1
  fi
  return 1
}

# Usage: validate_bootstrap_docsconfig "<调用方脚本所在目录>"
# 成功：设置 DOC_ROOT、REPO_ROOT、DOC_DIR（不 export）；可选 AGENT_*。
# 失败：stderr 说明；被执行时 exit 1，被 source 时 return 1
validate_bootstrap_docsconfig() {
  local script_dir="${1:?script_dir}"

  local rr
  if ! rr="$(find_repo_root_for_docsconfig "$script_dir")"; then
    config_bootstrap_fail "[config] 未找到目标仓库根下的 .docsconfig。"
  fi

  docsconfig_parse_into_globals "$rr/.docsconfig" || {
    config_bootstrap_fail "[config] 解析 .docsconfig 失败。"
  }

  if [[ -z "${DOC_ROOT:-}" || -z "${REPO_ROOT:-}" || -z "${DOC_DIR:-}" ]]; then
    config_bootstrap_fail "[config] .docsconfig 缺少必需的 DOC_ROOT、REPO_ROOT 或 DOC_DIR。"
  fi
}
