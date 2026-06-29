#!/usr/bin/env bash
# config-bootstrap.sh — 从目标工程根 .docsconfig 读入文档根与仓库根约定到当前 shell
# 禁止 export DOC_ROOT / REPO_ROOT / DOC_DIR / AGENT_*（仅当前 shell 赋值）。
# 依赖同目录 docs-core.sh（由 agent-install 安装）

_BOOTSTRAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_CFG_SH="${_BOOTSTRAP_DIR}/docs-core.sh"
if [[ ! -f "$_CFG_SH" ]]; then
  printf '[config] 未找到同目录 docs-core.sh（请执行 agent-install.sh 安装 Agent）: %s\n' "$_CFG_SH" >&2
  if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then exit 1; else return 1; fi
fi
# shellcheck source=/dev/null
source "$_CFG_SH"

resolve_repo_doc_root() {
  printf '%s' "${DOC_ROOT:-}"
}

config_bootstrap_fail() {
  local msg="${1:-[config] 配置校验失败。}"
  printf '%s\n' "$msg" >&2
  cat >&2 <<'EOF'
[config] 请使用 docs-install.sh 初始化并写入 .docsconfig，例如：
  bash scripts/docs-install.sh --scope=config --target <目标工程文档目录>
（在已克隆 ai-knowledge 的仓库根执行；路径请按实际工程调整；仍兼容 --target=<目录>）
EOF
  if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    exit 1
  fi
  return 1
}

# Usage: validate_bootstrap_docsconfig
validate_bootstrap_docsconfig() {
  local cfg_path config_owner_root
  if [[ $# -gt 0 ]]; then
    # 过渡兼容：旧调用方仍可能传入 caller_script_dir，但已不再参与查找决策。
    :
  fi

  if ! cfg_path="$(docsconfig_find_path)"; then
    config_bootstrap_fail "[config] 未找到当前工程的 .docsconfig。"
    return 1
  fi
  config_owner_root="$(dirname "$cfg_path")"

  KNOWLEDGE_TYPE=""
  DOCSCONFIG_PATH="$cfg_path"
  CONFIG_OWNER_ROOT="$config_owner_root"
  docsconfig_read_into "$cfg_path" DOC_ROOT REPO_ROOT DOC_DIR AGENT_ROOT AGENT_DIRS KNOWLEDGE_TYPE \
    || {
      config_bootstrap_fail "[config] 解析 .docsconfig 失败。"
      return 1
    }

  if [[ -z "${DOC_ROOT:-}" || -z "${REPO_ROOT:-}" || -z "${DOC_DIR:-}" ]]; then
    config_bootstrap_fail "[config] .docsconfig 缺少必需的 DOC_ROOT、REPO_ROOT 或 DOC_DIR。"
    return 1
  fi

  docsconfig_validate_owner_matches_repo_root "$config_owner_root" "$REPO_ROOT" \
    || {
      config_bootstrap_fail "[config] .docsconfig 与 REPO_ROOT 不一致。请重新执行 docs-install。"
      return 1
    }
}
