#!/usr/bin/env bash
# resolve-okf-paths.sh — 从 .docsconfig 解析 OKF bundle 与 viz 路径
# Usage: source .../resolve-okf-paths.sh && resolve_okf_paths "<调用方脚本所在目录>"
set -euo pipefail

_resolve_okf_agent_home() {
  local resolve_dir
  resolve_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "$resolve_dir/../../.." && pwd
}

resolve_okf_paths() {
  local caller_script_dir="${1:?caller_script_dir}"
  local agent_home bootstrap

  agent_home="$(_resolve_okf_agent_home)"
  bootstrap="${agent_home}/scripts/config-bootstrap.sh"
  if [[ ! -f "$bootstrap" ]]; then
    printf '[okf] 未找到 config-bootstrap.sh: %s\n' "$bootstrap" >&2
    exit 1
  fi

  # shellcheck disable=SC1091
  source "$bootstrap"
  validate_bootstrap_docsconfig "$caller_script_dir" || exit 1

  if [[ -z "${KNOWLEDGE_TYPE:-}" ]]; then
    config_bootstrap_fail "[okf] .docsconfig 缺少 KNOWLEDGE_TYPE。请使用 docs-install.sh --scope=knowledge --target <目标工程文档目录> 写入 KNOWLEDGE_TYPE。"
  fi

  docsconfig_validate_knowledge_type "$KNOWLEDGE_TYPE" || exit 1

  OKF_BUNDLE="$DOC_DIR"
  OKF_VIZ_OUT="${KNOWLEDGE_TYPE}/viz.html"
  OKF_VIZ_NAME="${KNOWLEDGE_TYPE} OKF"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  printf 'Usage: source %s && resolve_okf_paths "<caller_script_dir>"\n' "$0" >&2
  exit 1
fi
