#!/usr/bin/env bash
#
# docs-bootstrap.sh — SDX 知识库初始化引导脚本
#
# 职责：
#   无需预先克隆 ai-knowledge：克隆到临时目录后调用 **knowledge-init.sh** 完成初始化。
#
# 依赖：Bash 5+、Git、网络连接（可访问 GitHub）
#
# 用法：
#   curl -sL https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/docs-bootstrap.sh \
#     | bash -s -- [选项] <目标工程文档目录>
#
set -euo pipefail

# =============================================================================
# § 1  常量（预克隆阶段；须与 docs-config.sh 中 SDX_GIT_REPO_URL 一致，见集成测试）
# =============================================================================

readonly SDX_BS_FALLBACK_REPO='https://github.com/oleewen/ai-knowledge.git'
readonly SDX_BS_DEFAULT_REF='HEAD'

# =============================================================================
# § 2  运行时状态
# =============================================================================

SDX_BS_CLONE_DIR=''
SDX_BS_TARGET_DIR="${PWD}"

# =============================================================================
# § 3  日志与错误处理
# =============================================================================

sdx_bs_log()  { printf '%s\n'        "$*" >&2; }
sdx_bs_info() { printf '[INFO]  %s\n' "$*" >&2; }
sdx_bs_err()  { printf '[ERROR] %s\n' "$*" >&2; }

sdx_bs_die() {
  sdx_bs_err "$1"
  exit "${2:-1}"
}

# =============================================================================
# § 4  环境检查
# =============================================================================

sdx_bs_check_bash() {
  (( BASH_VERSINFO[0] >= 5 )) \
    || sdx_bs_die "需要 Bash 5+，当前版本: ${BASH_VERSION}"
}

sdx_bs_has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

sdx_bs_check_deps() {
  sdx_bs_has_cmd git || sdx_bs_die "未找到 git 命令，请先安装 Git"
}

# =============================================================================
# § 5  配置读取
# =============================================================================

sdx_bs_get_repo_url() { printf '%s' "${GIT_REPO_URL:-$SDX_BS_FALLBACK_REPO}"; }
sdx_bs_get_ref()      { printf '%s' "${GIT_REF:-$SDX_BS_DEFAULT_REF}"; }

sdx_bs_get_tmpdir() {
  local tmpdir="${TMPDIR:-/tmp}"
  [[ -d "$tmpdir" ]] || tmpdir='/tmp'
  printf '%s' "$tmpdir"
}

sdx_bs_gen_clone_dir() {
  printf '%s/ai-knowledge-%s' "$1" "$$"
}

# =============================================================================
# § 6  Git
# =============================================================================

sdx_bs_clone_repo() {
  local repo_url="$1" ref="$2" dest_dir="$3"

  if [[ -d "$dest_dir" ]]; then
    sdx_bs_info "清理已存在的临时目录: $dest_dir"
    rm -rf "$dest_dir"
  fi

  sdx_bs_info "克隆仓库: $repo_url → $dest_dir"

  if [[ "$ref" == 'HEAD' || -z "$ref" ]]; then
    git clone --depth 1 "$repo_url" "$dest_dir" \
      || { sdx_bs_err "克隆失败: $repo_url"; return 1; }
  else
    sdx_bs_info "  分支/标签: $ref"
    git clone --depth 1 --single-branch -b "$ref" "$repo_url" "$dest_dir" \
      || { sdx_bs_err "克隆失败: $repo_url (ref: $ref)"; return 1; }
  fi
}

sdx_bs_cleanup() {
  if [[ -n "$SDX_BS_CLONE_DIR" && -d "$SDX_BS_CLONE_DIR" ]]; then
    sdx_bs_info "清理临时目录: $SDX_BS_CLONE_DIR"
    rm -rf "$SDX_BS_CLONE_DIR"
  fi
}

# =============================================================================
# § 7  参数解析（展示用）
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
# § 8  主流程
# =============================================================================

sdx_bs_main() {
  sdx_bs_check_bash
  sdx_bs_check_deps

  SDX_BS_TARGET_DIR="$(sdx_bs_parse_target_dir "$@")"

  local repo_url ref tmpdir
  repo_url="$(sdx_bs_get_repo_url)"
  ref="$(sdx_bs_get_ref)"
  tmpdir="$(sdx_bs_get_tmpdir)"

  SDX_BS_CLONE_DIR="$(sdx_bs_gen_clone_dir "$tmpdir")"
  trap sdx_bs_cleanup EXIT

  sdx_bs_log ''
  sdx_bs_log '=========================================='
  sdx_bs_log 'docs-bootstrap'
  sdx_bs_info "仓库: $repo_url"
  sdx_bs_info "引用: $ref"
  sdx_bs_info "目标: $SDX_BS_TARGET_DIR"
  sdx_bs_log '=========================================='
  sdx_bs_log ''

  sdx_bs_clone_repo "$repo_url" "$ref" "$SDX_BS_CLONE_DIR" || exit 1

  local knowledge_init="${SDX_BS_CLONE_DIR}/scripts/knowledge-init.sh"
  local config_script="${SDX_BS_CLONE_DIR}/scripts/docs-config.sh"
  [[ -f "$knowledge_init" ]] || sdx_bs_die "仓库中未找到 scripts/knowledge-init.sh"
  [[ -f "$config_script" ]] || sdx_bs_die "仓库中未找到 scripts/docs-config.sh"

  # shellcheck disable=SC1090
  source "$config_script"

  sdx_bs_info "已加载模板库 SDX_VERSION=${SDX_VERSION}"

  sdx_bs_log ''
  sdx_bs_info '>>> 执行 knowledge-init.sh...'
  sdx_bs_log ''

  export REPO_ROOT="$SDX_BS_CLONE_DIR"
  bash "$knowledge_init" "$@"
}

sdx_bs_main "$@"
