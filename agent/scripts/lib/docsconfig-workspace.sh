#!/usr/bin/env bash
# lib/docsconfig-workspace.sh — 配置发现、工作区定位与当前 shell 注入
# 由 docsconfig.sh 加载；不设独立哨兵，随聚合入口换根刷新。

docsconfig_repo_from_doc() {
  local doc_abs="${1:?doc_abs}" dr gr
  dr="$(cd -P "$doc_abs" 2>/dev/null && pwd)" || return 0
  gr="$(git -C "$dr" rev-parse --show-toplevel 2>/dev/null || true)"
  if [[ -n "$gr" && "$(dirname "$dr")" == "$gr" ]]; then
    printf '%s\n' "$gr"
    return 0
  fi
  cd -P "$(dirname "$doc_abs")" 2>/dev/null && pwd || true
}

docsconfig_find_repo_root() {
  local pwd_root d i
  pwd_root="$(git -C "${PWD}" rev-parse --show-toplevel 2>/dev/null || true)"
  d="$(cd -P "$PWD" 2>/dev/null && pwd)" || return 1

  for ((i = 0; i < 32; i++)); do
    [[ -f "$d/.docsconfig" ]] && {
      printf '%s' "$d"
      return 0
    }
    [[ -n "$pwd_root" && "$d" == "$pwd_root" ]] && break
    [[ "$d" == "/" ]] && break
    d="$(dirname "$d")"
  done
  return 1
}

docsconfig_find_path() {
  local repo_root
  repo_root="$(docsconfig_find_repo_root)" || return 1
  printf '%s/.docsconfig' "$repo_root"
}

docsconfig_validate_owner_matches_repo() {
  local config_owner_root="${1:?config_owner_root}"
  local repo_abs_in="${2:?repo_abs}"
  local owner_abs repo_abs

  owner_abs="$(cd -P "$config_owner_root" 2>/dev/null && pwd)" || return 1
  repo_abs="$(cd -P "$repo_abs_in" 2>/dev/null && pwd)" || return 1
  if [[ "$owner_abs" != "$repo_abs" ]]; then
    printf '[docsconfig] 配置漂移：.docsconfig 位于 %s，但仓库路径为 %s\n' \
      "$owner_abs" "$repo_abs" >&2
    return 1
  fi
}

docsconfig_doc_dir_from_roots() {
  local repo_root="${1:?repo_root}" doc_root="${2:?doc_root}"
  local rr dr
  rr="$(cd -P "$repo_root" 2>/dev/null && pwd)" || {
    printf '[docsconfig] 无法解析仓库路径: %s\n' "$repo_root" >&2
    return 1
  }
  dr="$(cd -P "$doc_root" 2>/dev/null && pwd)" || {
    printf '[docsconfig] 无法解析文档路径: %s\n' "$doc_root" >&2
    return 1
  }
  case "$dr" in
    "$rr") printf '.\n' ;;
    "$rr"/*) printf '%s\n' "${dr#"$rr"/}" ;;
    *)
      printf '[docsconfig] 文档路径不在仓库路径下: %s vs %s\n' "$dr" "$rr" >&2
      return 1
      ;;
  esac
}

docsconfig_configs_file() {
  local agent_root="${1:?}" agent_dir="${2:?}"
  local root
  root="$(strip_trailing_slash "$(docsconfig_normalize_root_value "$agent_root")")"
  printf '%s/%s/configs' "$root" "$agent_dir"
}

docsconfig_read_workspace_raw() {
  local path="${1:?}" line v
  [[ -f "$path" ]] || return 1
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" == WORK_SPACE=* ]] || continue
    v="${line#*=}"
    v="${v%$'\r'}"
    v="${v#\"}"
    v="${v%\"}"
    v="${v#\'}"
    v="${v%\'}"
    printf '%s' "$v"
    return 0
  done <"$path"
  return 1
}

docsconfig_workspace_fail() {
  local msg="${1:-[config] 未找到工作区文件。}"
  printf '%s\n' "$msg" >&2
  cat >&2 <<'EOF'
[config] 请执行 /agent-install，并传入 --workspace <工作区目录>。例如：
  bash agent/skills/agent-install/scripts/agent-install.sh --workspace ~/workspaces
EOF
  if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    exit 1
  fi
  return 1
}

docsconfig_load_workspace_abs() {
  local agent_root="${1:?}" agent_dir="${2:?}"
  local path raw
  path="$(docsconfig_configs_file "$agent_root" "$agent_dir")"
  if [[ ! -f "$path" ]]; then
    docsconfig_workspace_fail "[config] 未找到工作区文件: ${path}"
    return 1
  fi
  raw="$(docsconfig_read_workspace_raw "$path" || true)"
  if [[ -z "$raw" ]]; then
    docsconfig_workspace_fail "[config] 工作区文件缺少 WORK_SPACE: ${path}"
    return 1
  fi
  docsconfig_normalize_root_value "$raw"
}

docsconfig_compose_repo_abs() {
  local ws="${1:?}" repo_dir="${2:?}"
  docsconfig_normalize_root_value "${ws%/}/${repo_dir}"
}

docsconfig_compose_doc_abs() {
  local ws="${1:?}" repo_dir="${2:?}" doc_dir="${3:?}"
  local repo_abs
  repo_abs="$(docsconfig_compose_repo_abs "$ws" "$repo_dir")"
  docsconfig_normalize_root_value "${repo_abs%/}/${doc_dir}"
}

docsconfig_repo_abs() {
  docsconfig_compose_repo_abs "${WORK_SPACE:?WORK_SPACE 未注入}" "${REPO_DIR:?REPO_DIR 未注入}"
}

docsconfig_doc_abs() {
  docsconfig_compose_doc_abs "${WORK_SPACE:?WORK_SPACE 未注入}" "${REPO_DIR:?REPO_DIR 未注入}" "${DOC_DIR:?DOC_DIR 未注入}"
}

# 从一份 .docsconfig 拼出仓库路径与文档路径。不改当前 shell 的 WORK_SPACE。
# Usage: docsconfig_abs_for_config <cfg> <repo_var> <doc_var> <ddir_var> [aroot_var [ktype_var [adir_var]]]
docsconfig_abs_for_config() {
  local path="${1:?}"
  local rd='' dd='' ar='' kt='' ad=''
  local ws repo_abs doc_abs
  docsconfig_read_into "$path" rd dd ar kt ad || return 1
  if [[ -z "$rd" || -z "$dd" ]]; then
    _docsconfig_err "[config] .docsconfig 缺少 REPO_DIR 或 DOC_DIR: ${path}"
    _docsconfig_err "[config] 请重新执行 docs-install。"
    return 1
  fi
  docsconfig_validate_repo_dir "$rd" || return 1
  docsconfig_validate_doc_dir "$dd" || return 1
  if [[ -z "$ar" || -z "$ad" ]]; then
    _docsconfig_err "[config] .docsconfig 缺少 AGENT_ROOT 或 AGENT_DIR，无法定位工作区文件: ${path}"
    return 1
  fi
  ws="$(docsconfig_load_workspace_abs "$ar" "$ad")" || return 1
  repo_abs="$(docsconfig_compose_repo_abs "$ws" "$rd")"
  doc_abs="$(docsconfig_compose_doc_abs "$ws" "$rd" "$dd")"
  printf -v "${2:?}" '%s' "$repo_abs"
  printf -v "${3:?}" '%s' "$doc_abs"
  printf -v "${4:?}" '%s' "$dd"
  if (( $# >= 5 )); then printf -v "${5:?}" '%s' "$ar"; fi
  if (( $# >= 6 )); then printf -v "${6:?}" '%s' "$kt"; fi
  if (( $# >= 7 )); then printf -v "${7:?}" '%s' "$ad"; fi
}

docsconfig_bootstrap_fail() {
  local msg="${1:-[config] 配置校验失败。}"
  printf '%s\n' "$msg" >&2
  cat >&2 <<'EOF'
[config] 请使用 /docs-install 或 docs-install.sh 初始化并写入 .docsconfig，例如：
  bash agent/skills/docs-install/scripts/docs-install.sh --scope=config --target <目标工程文档目录>
（在已克隆 ai-knowledge 的仓库根执行；路径请按实际工程调整）
EOF
  if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    exit 1
  fi
  return 1
}

# 自 cwd 上溯查找 .docsconfig，注入当前 shell 的 WORK_SPACE / REPO_DIR / DOC_DIR 及 Agent 字段。
docsconfig_bootstrap_validate() {
  local cfg_path config_owner_root repo_abs

  cfg_path="$(docsconfig_find_path)" || {
    docsconfig_bootstrap_fail "[config] 未找到当前工程的 .docsconfig。"
    return 1
  }
  config_owner_root="$(dirname "$cfg_path")"

  KNOWLEDGE_TYPE=""
  AGENT_DIR=""
  AGENT_ROOT=""
  REPO_DIR=""
  DOC_DIR=""
  WORK_SPACE=""
  DOCSCONFIG_PATH="$cfg_path"
  CONFIG_OWNER_ROOT="$config_owner_root"
  docsconfig_read_into "$cfg_path" REPO_DIR DOC_DIR AGENT_ROOT KNOWLEDGE_TYPE AGENT_DIR || {
    docsconfig_bootstrap_fail "[config] 解析 .docsconfig 失败。"
    return 1
  }

  if [[ -z "${REPO_DIR:-}" || -z "${DOC_DIR:-}" ]]; then
    docsconfig_bootstrap_fail "[config] .docsconfig 缺少必需的 REPO_DIR 或 DOC_DIR。"
    return 1
  fi
  docsconfig_validate_repo_dir "$REPO_DIR" || {
    docsconfig_bootstrap_fail "[config] REPO_DIR 非法。"
    return 1
  }
  docsconfig_validate_doc_dir "$DOC_DIR" || {
    docsconfig_bootstrap_fail "[config] DOC_DIR 非法。"
    return 1
  }

  if [[ -z "${AGENT_ROOT:-}" || -z "${AGENT_DIR:-}" ]]; then
    docsconfig_bootstrap_fail "[config] .docsconfig 缺少 AGENT_ROOT 或 AGENT_DIR，无法定位工作区文件。"
    return 1
  fi

  if declare -F docsconfig_agent_root_looks_like_entity_tree >/dev/null 2>&1; then
    if docsconfig_agent_root_looks_like_entity_tree "$AGENT_ROOT"; then
      docsconfig_bootstrap_fail "[config] AGENT_ROOT 不能指向实体树。请改为 ~（或家目录）并设置 AGENT_DIR。"
      return 1
    fi
  fi

  WORK_SPACE="$(docsconfig_load_workspace_abs "$AGENT_ROOT" "$AGENT_DIR")" || return 1
  repo_abs="$(docsconfig_repo_abs)"
  docsconfig_validate_owner_matches_repo "$config_owner_root" "$repo_abs" || {
    docsconfig_bootstrap_fail "[config] .docsconfig 与仓库路径不一致。请重新执行 docs-install。"
    return 1
  }
}
