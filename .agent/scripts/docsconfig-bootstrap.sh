#!/usr/bin/env bash
# docsconfig-bootstrap.sh — 运行时装载目标工程根 .docsconfig（§4）
# 禁止 export DOC_ROOT / REPO_ROOT / DOC_DIR / AGENT_*（§2.2.2）；仅当前 shell 赋值。

# Source 成功后由本文件设置的变量（供 validate-*.sh 使用）：
#   DOC_ROOT    — 文档树根绝对路径（由 .docsconfig 解析并展开 ~/）
#   REPO_ROOT   — 目标工程 Git 仓库根绝对路径
#   DOC_DIR     — 相对 REPO_ROOT 的文档路径段
#   AGENT_ROOT  — Agent 安装父目录绝对路径（可选键；与 .docsconfig 一致）
#   AGENT_DIRS  — 空格分隔的 Agent 目录名（如 .cursor .claude，可选键）

# -----------------------------------------------------------------------------
# 路径：与 scripts/docs-config.sh 行为一致（目标工程未必附带该文件，故内联）
# -----------------------------------------------------------------------------
# 与 scripts/docs-config.sh expand_tilde 一致
_docsconfig_expand_tilde() {
  local p="${1:-}"
  if [[ "$p" == "~" ]]; then
    printf '%s\n' "${HOME:-}"
  elif [[ "$p" =~ ^~/ ]]; then
    printf '%s\n' "${HOME:-}/${p:2}"
  elif [[ "$p" =~ ^~[a-zA-Z] ]]; then
    printf '%s\n' "$p"
  else
    printf '%s\n' "$p"
  fi
}

_docsconfig_abs_path() {
  local p
  p="$(_docsconfig_expand_tilde "${1:-}")"
  if [[ "$p" != /* ]]; then
    p="${PWD}/$p"
  fi
  if [[ -d "$p" ]]; then
    (cd -P "$p" 2>/dev/null && pwd)
  else
    local dir base orig_dir
    dir="$(dirname "$p")"
    orig_dir="$dir"
    base="$(basename "$p")"
    if dir="$(cd -P "$dir" 2>/dev/null && pwd)"; then
      :
    else
      dir="$orig_dir"
    fi
    echo "$dir/$base"
  fi
}

# *_ROOT 原始行值 → 绝对路径（_docsconfig_abs_path 内含 ~ 展开）
_docsconfig_normalize_root_value() {
  local v="${1:-}"
  v="${v%$'\r'}"
  printf '%s' "$(_docsconfig_abs_path "$v")"
}

# -----------------------------------------------------------------------------
# 返回 validate_bootstrap_docsconfig 已加载的 DOC_ROOT（与 .docsconfig 一致）；无 override。
# -----------------------------------------------------------------------------
resolve_repo_doc_root() {
  printf '%s' "${DOC_ROOT:-}"
}

# §4.1.1：解析承载 .docsconfig 的 REPO_ROOT（目标工程仓库根）
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
  local line k v
  DOC_ROOT=""
  REPO_ROOT=""
  DOC_DIR=""
  AGENT_ROOT=""
  AGENT_DIRS=""
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    case "$line" in
      DOC_ROOT=* | REPO_ROOT=* | DOC_DIR=* | AGENT_ROOT=* | AGENT_DIRS=*)
        k="${line%%=*}"
        v="${line#*=}"
        v="${v%$'\r'}"
        v="${v#"${v%%[![:space:]]*}"}"
        v="${v%"${v##*[![:space:]]}"}"
        if [[ "$k" == "AGENT_DIRS" && ${#v} -ge 2 && "${v:0:1}" == '"' && "${v: -1}" == '"' ]]; then
          v="${v:1:${#v}-2}"
        fi
        case "$k" in
          DOC_ROOT) DOC_ROOT="$v" ;;
          REPO_ROOT) REPO_ROOT="$v" ;;
          DOC_DIR) DOC_DIR="$v" ;;
          AGENT_ROOT) AGENT_ROOT="$v" ;;
          AGENT_DIRS) AGENT_DIRS="$v" ;;
        esac
        ;;
    esac
  done <"$path"
  if [[ -n "${DOC_ROOT:-}" ]]; then
    DOC_ROOT="$(_docsconfig_normalize_root_value "$DOC_ROOT")"
  fi
  if [[ -n "${REPO_ROOT:-}" ]]; then
    REPO_ROOT="$(_docsconfig_normalize_root_value "$REPO_ROOT")"
  fi
  if [[ -n "${AGENT_ROOT:-}" ]]; then
    AGENT_ROOT="$(_docsconfig_normalize_root_value "$AGENT_ROOT")"
  fi
}

# 定位本仓库 scripts/docs-init.sh（模板库根下），供 §4.2 / §4.2.1 代为执行
find_docs_init_script() {
  local boot_dir
  boot_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local agent_root repo_root
  agent_root="$(cd "$boot_dir/.." && pwd)"
  repo_root="$(cd "$agent_root/.." && pwd)"
  if [[ -f "$repo_root/scripts/docs-init.sh" ]]; then
    printf '%s' "$repo_root/scripts/docs-init.sh"
    return 0
  fi
  if command -v docs-init.sh >/dev/null 2>&1; then
    command -v docs-init.sh
    return 0
  fi
  return 1
}

# §4.2 策略 D：无 .docsconfig
docsconfig_strategy_d_missing_file() {
  local hint="${1:-$(pwd)}"
  local init_script
  cat >&2 <<EOF
[docsconfig] 未找到目标仓库根下的 .docsconfig（运行时策略 D）。

请在目标工程文档根已确定后执行（示例）：
  bash scripts/docs-init.sh --scope=c $(printf '%q' "$hint")
  # 或: docs-init.sh --scope=config $(printf '%q' "$hint")

若从 ai-knowledge 模板仓库克隆，scripts/docs-init.sh 位于该仓库根下。
EOF
  [[ -t 0 ]] || return 1
  read -r -p "是否立即代为执行 docs-init（--scope=c）？ [y/N] " ans
  case "${ans,,}" in
    y | yes) ;;
    *) return 1 ;;
  esac
  if ! init_script="$(find_docs_init_script)"; then
    echo "[docsconfig] 无法自动定位 docs-init.sh，请手动执行上述命令。" >&2
    return 1
  fi
  echo "[docsconfig] 执行: bash $(printf '%q' "$init_script") --scope=c $(printf '%q' "$hint")" >&2
  bash "$init_script" --scope=c "$hint"
}

# §4.2.1：有文件但 DOC_DIR 缺失或为空
docsconfig_strategy_missing_doc_dir() {
  local doc_root_hint="${1:?}"
  local init_script
  cat >&2 <<EOF
[docsconfig] .docsconfig 存在但缺少有效 DOC_DIR（§4.2.1）。

须通过 docs-init 回写三键，例如：
  bash scripts/docs-init.sh --scope=c $(printf '%q' "$doc_root_hint")
EOF
  [[ -t 0 ]] || return 1
  read -r -p "是否立即代为执行 docs-init（--scope=c）？ [y/N] " ans
  case "${ans,,}" in
    y | yes) ;;
    *) return 1 ;;
  esac
  if ! init_script="$(find_docs_init_script)"; then
    echo "[docsconfig] 无法自动定位 docs-init.sh，请手动执行上述命令。" >&2
    return 1
  fi
  bash "$init_script" --scope=c "$doc_root_hint"
}

# Usage: validate_bootstrap_docsconfig "<调用方脚本所在目录>"
# 成功：设置 DOC_ROOT、REPO_ROOT、DOC_DIR（不 export）
# 失败：stderr 说明并 exit 1
validate_bootstrap_docsconfig() {
  local script_dir="${1:?script_dir}"
  local rr=""

  if ! rr="$(find_repo_root_for_docsconfig "$script_dir")"; then
    if ! docsconfig_strategy_d_missing_file "$(pwd)"; then
      exit 1
    fi
    rr="$(find_repo_root_for_docsconfig "$script_dir")" || {
      echo "[docsconfig] 仍无法定位 .docsconfig，请确认 docs-init 已成功写入目标仓库根。" >&2
      exit 1
    }
  fi

  local cfg="$rr/.docsconfig"
  [[ -f "$cfg" ]] || {
    echo "[docsconfig] 内部错误：预期存在 $cfg" >&2
    exit 1
  }

  docsconfig_parse_into_globals "$cfg"

  if [[ -z "${DOC_DIR:-}" ]]; then
    local hint
    hint="${DOC_ROOT:-$(pwd)}"
    [[ -n "$DOC_ROOT" ]] || hint="$(pwd)"
    if ! docsconfig_strategy_missing_doc_dir "$hint"; then
      exit 1
    fi
    docsconfig_parse_into_globals "$cfg"
    if [[ -z "${DOC_DIR:-}" ]]; then
      echo "[docsconfig] DOC_DIR 仍为空，已中止。" >&2
      exit 1
    fi
  fi

  if [[ -z "${DOC_ROOT:-}" || -z "${REPO_ROOT:-}" ]]; then
    echo "[docsconfig] .docsconfig 中 DOC_ROOT 或 REPO_ROOT 缺失，无法继续。" >&2
    exit 1
  fi
}
