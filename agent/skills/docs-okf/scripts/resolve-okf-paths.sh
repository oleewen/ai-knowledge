#!/usr/bin/env bash
# resolve-okf-paths.sh — 从当前工程的 .docsconfig 解析 OKF bundle 与 viz 路径
# Usage: source .../resolve-okf-paths.sh && resolve_okf_paths
set -euo pipefail

_resolve_okf_agent_home() {
  local resolve_dir
  resolve_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "$resolve_dir/../../.." && pwd
}

resolve_okf_paths() {
  local agent_home bootstrap

  agent_home="$(_resolve_okf_agent_home)"
  bootstrap="${agent_home}/scripts/lib/docsconfig.sh"
  if [[ ! -f "$bootstrap" ]]; then
    printf '[okf] 未找到 docsconfig.sh: %s\n' "$bootstrap" >&2
    exit 1
  fi

  # shellcheck disable=SC1091
  source "$bootstrap"
  docsconfig_bootstrap_validate || exit 1

  if [[ -z "${KNOWLEDGE_TYPE:-}" ]]; then
    docsconfig_bootstrap_fail "[okf] .docsconfig 缺少 KNOWLEDGE_TYPE。请使用 docs-install.sh --scope=knowledge --target <目标工程文档目录> 写入 KNOWLEDGE_TYPE。"
  fi

  if [[ -z "${AGENT_DIR:-}" ]]; then
    docsconfig_bootstrap_fail "[okf] .docsconfig 缺少 AGENT_DIR。OKF 脚本依赖 {DOC_DIR}/{AGENT_DIR}/skills/docs-okf/；请 docs-install --scope=config 补齐。"
  fi

  docsconfig_validate_knowledge_type "$KNOWLEDGE_TYPE" || exit 1

  OKF_BUNDLE="$DOC_DIR"
  OKF_VIZ_OUT="${DOC_DIR%/}/viz.html"
  OKF_VIZ_NAME="${KNOWLEDGE_TYPE} OKF"
  # 脚本树：DOC_ROOT/AGENT_DIR（即 {DOC_DIR}/{AGENT_DIR}，通常为软链 .agents）
  OKF_AGENT_TREE="${DOC_ROOT%/}/${AGENT_DIR}"
  OKF_SCRIPTS="${OKF_AGENT_TREE}/skills/docs-okf/scripts"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  printf 'Usage: source %s && resolve_okf_paths\n' "$0" >&2
  exit 1
fi
