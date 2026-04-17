#!/usr/bin/env bash
#
# docs-bootstrap.sh — SDX 知识库初始化引导脚本
#
# 职责：
#   无需预先克隆 ai-knowledge：克隆到临时目录后调用 **docs-install.sh** 完成初始化。
#
# 依赖：Bash 5+、Git、网络连接（可访问 GitHub）
#
# 用法：
#   curl -sL https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/docs-bootstrap.sh \
#     | bash -s -- [选项] <目标工程文档目录>
#
# 配置项（默认值、GIT_REPO_URL/GIT_REF 读取）：**agent/scripts/docs-core.sh**
# —— 从本仓库根执行时可预载；**curl | bash** 时于下方内联回退（须与该文件保持一致）。
#
set -euo pipefail

# =============================================================================
# § 1  预载共享配置（仅从已克隆仓库运行时）
# =============================================================================

_BOOTSTRAP_SCRIPT_DIR=''
if [[ -n "${BASH_SOURCE[0]:-}" && "${BASH_SOURCE[0]}" != '-' ]]; then
  _BOOTSTRAP_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || true
fi
if [[ -n "$_BOOTSTRAP_SCRIPT_DIR" && -f "${_BOOTSTRAP_SCRIPT_DIR}/../agent/scripts/docs-core.sh" ]]; then
  # shellcheck source=/dev/null
  source "${_BOOTSTRAP_SCRIPT_DIR}/../agent/scripts/docs-core.sh"
fi

if ! declare -F require_bash5 >/dev/null 2>&1; then
  require_bash5() {
    if (( BASH_VERSINFO[0] < 5 )); then
      printf '[FATAL] 需要 Bash %s+，当前版本: %s\n' 5 "$BASH_VERSION" >&2
      exit 1
    fi
  }
fi
if ! declare -F sdx_docs_bootstrap_get_repo_url >/dev/null 2>&1; then
  _SDX_GIT_REPO_URL_FALLBACK='https://github.com/oleewen/ai-knowledge.git'
  _SDX_GIT_DEFAULT_REF_FALLBACK='HEAD'
  sdx_docs_bootstrap_get_repo_url() {
    printf '%s' "${GIT_REPO_URL:-$_SDX_GIT_REPO_URL_FALLBACK}"
  }
  sdx_docs_bootstrap_get_ref() {
    printf '%s' "${GIT_REF:-$_SDX_GIT_DEFAULT_REF_FALLBACK}"
  }
  sdx_docs_bootstrap_get_tmpdir() {
    local tmpdir="${TMPDIR:-/tmp}"
    [[ -d "$tmpdir" ]] || tmpdir='/tmp'
    printf '%s' "$tmpdir"
  }
  sdx_docs_bootstrap_gen_clone_dir() {
    printf '%s/ai-knowledge-%s' "${1:?tmpdir}" "$$"
  }
fi

# =============================================================================
# § 2  运行时状态
# =============================================================================

SDX_BS_CLONE_DIR=''
SDX_BS_TARGET_DIR="${PWD}"

# =============================================================================
# § 3  日志与错误处理（回退逻辑以支持 standalone curl | bash）
# =============================================================================

if ! declare -F sdx_log >/dev/null 2>&1; then
  sdx_log()   { printf '%s\n'       "$*" >&2; }
  sdx_info()  { printf '[INFO]  %s\n' "$*" >&2; }
  sdx_error() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }
fi

sdx_bs_die() {
  sdx_error "$1"
}

# =============================================================================
# § 4  环境检查（Bash 版本见 docs-core.sh 之 require_bash5；预载失败时 §1 回退已定义）
# =============================================================================

sdx_bs_has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

sdx_bs_check_deps() {
  sdx_bs_has_cmd git || sdx_bs_die "未找到 git 命令，请先安装 Git"
}

# =============================================================================
# § 5  Git
# =============================================================================

sdx_bs_clone_repo() {
  local repo_url="$1" ref="$2" dest_dir="$3"

  if [[ -d "$dest_dir" ]]; then
    sdx_info "清理已存在的临时目录: $dest_dir"
    rm -rf "$dest_dir"
  fi

  sdx_info "克隆仓库: $repo_url → $dest_dir"

  if [[ "$ref" == 'HEAD' || -z "$ref" ]]; then
    git clone --depth 1 "$repo_url" "$dest_dir" \
      || { sdx_error "克隆失败: $repo_url"; }
  else
    sdx_info "  分支/标签: $ref"
    git clone --depth 1 --single-branch -b "$ref" "$repo_url" "$dest_dir" \
      || { sdx_error "克隆失败: $repo_url (ref: $ref)"; }
  fi
}

sdx_bs_cleanup() {
  if [[ -n "$SDX_BS_CLONE_DIR" && -d "$SDX_BS_CLONE_DIR" ]]; then
    sdx_info "清理临时目录: $SDX_BS_CLONE_DIR"
    rm -rf "$SDX_BS_CLONE_DIR"
  fi
}

# =============================================================================
# § 6  参数解析（展示用）
# =============================================================================

sdx_bs_parse_target_dir() {
  local -a args=("$@")
  local target='' i

  for (( i = ${#args[@]} - 1; i >= 0; i-- )); do
    [[ "${args[$i]}" != -* ]] && { target="${args[$i]}"; break; }
  done

  printf '%s' "${target:-docs}"
}

# =============================================================================
# § 7  主流程
# =============================================================================

sdx_bs_main() {
  require_bash5
  sdx_bs_check_deps

  SDX_BS_TARGET_DIR="$(sdx_bs_parse_target_dir "$@")"

  local repo_url ref tmpdir
  repo_url="$(sdx_docs_bootstrap_get_repo_url)"
  ref="$(sdx_docs_bootstrap_get_ref)"
  tmpdir="$(sdx_docs_bootstrap_get_tmpdir)"

  SDX_BS_CLONE_DIR="$(sdx_docs_bootstrap_gen_clone_dir "$tmpdir")"
  trap sdx_bs_cleanup EXIT

  sdx_log ''
  sdx_log '=========================================='
  sdx_log 'docs-bootstrap'
  sdx_info "仓库: $repo_url"
  sdx_info "引用: $ref"
  sdx_info "目标: $SDX_BS_TARGET_DIR"
  sdx_log '=========================================='
  sdx_log ''

  sdx_bs_clone_repo "$repo_url" "$ref" "$SDX_BS_CLONE_DIR" || exit 1

  local docs_install="${SDX_BS_CLONE_DIR}/scripts/docs-install.sh"
  local shared_config="${SDX_BS_CLONE_DIR}/agent/scripts/docs-core.sh"
  [[ -f "$docs_install" ]] || sdx_bs_die "仓库中未找到 scripts/docs-install.sh"
  [[ -f "$shared_config" ]] || sdx_bs_die "仓库中未找到 agent/scripts/docs-core.sh"

  # 克隆后统一加载 SSOT（若预载阶段已 source，此处因 _AGENT_SHARED_DOCS_CONFIG_LOADED 短路）
  # shellcheck disable=SC1090
  source "$shared_config"

  sdx_log ''
  sdx_info "已加载共享配置（agent/scripts/docs-core.sh）"
  sdx_info '>>> 执行 docs-install.sh...'
  sdx_log ''

  export REPO_ROOT="$SDX_BS_CLONE_DIR"
  bash "$docs_install" "$@"
}

sdx_bs_main "$@"
