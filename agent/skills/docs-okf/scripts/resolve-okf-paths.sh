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
  local agent_home bootstrap doc_abs

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

  doc_abs="$(docsconfig_doc_abs)"
  OKF_BUNDLE="$DOC_DIR"
  OKF_VIZ_OUT="${DOC_DIR%/}/viz.html"
  OKF_VIZ_NAME="${KNOWLEDGE_TYPE} OKF"
  # 脚本树：doc_abs/AGENT_DIR（即 {DOC_DIR}/{AGENT_DIR}，通常为软链 .agents）
  OKF_AGENT_TREE="${doc_abs%/}/${AGENT_DIR}"
  OKF_SCRIPTS="${OKF_AGENT_TREE}/skills/docs-okf/scripts"
}

# CLI 两种写法均须非空，避免 --bundle= 意外扫描整个仓库。
okf_require_bundle_value() {
  if [[ -z "${1:-}" || "$1" == -* ]]; then
    printf '[okf] 缺少 --bundle 参数值\n' >&2
    exit 1
  fi
}

# 默认与覆盖共享一个路径规则；脚本树始终来自配置。
resolve_okf_target() {
  local requested="${1:-}" target_abs default_abs
  resolve_okf_paths
  repo_abs="$(docsconfig_repo_abs)"
  BUNDLE="${requested:-$OKF_BUNDLE}"
  while [[ "$BUNDLE" != / && "$BUNDLE" == */ ]]; do
    BUNDLE="${BUNDLE%/}"
  done
  if ! target_abs="$(cd "$repo_abs" && cd "$BUNDLE" && pwd -P)"; then
    printf '[okf] bundle 不存在: %s\n' "$BUNDLE" >&2
    exit 1
  fi
  default_abs="$(docsconfig_doc_abs)"
  default_abs="$(cd "$default_abs" && pwd -P)"
  OKF_VIZ_OUT="${BUNDLE%/}/viz.html"
  if [[ "$target_abs" != "$default_abs" ]]; then
    OKF_VIZ_NAME="$(basename "$BUNDLE") OKF"
    printf '[okf] bundle 覆盖: %s；viz: %s\n' "$BUNDLE" "$OKF_VIZ_OUT" >&2
  fi
  OKF_DIR="${OKF_SCRIPTS:?}"
  if [[ ! -d "$OKF_DIR" ]]; then
    printf '[okf] 未找到 OKF 脚本目录: %s（请 docs-install 建软链或 /agent-install）\n' "$OKF_DIR" >&2
    exit 1
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  printf 'Usage: source %s && resolve_okf_paths\n' "$0" >&2
  exit 1
fi
