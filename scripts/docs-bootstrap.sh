#!/usr/bin/env bash
#
# docs-bootstrap.sh — SDX 知识库初始化引导脚本
#
# 职责：
#   允许用户无需预先克隆 ai-knowledge 仓库即可执行初始化。
#   自动从 Git 拉取仓库到临时目录，然后调用 docs-init.sh 完成初始化。
#
# 设计原则：
#   - 零依赖启动：仅需 bash 和 git，无需预先下载任何文件
#   - 一键体验：单条 curl 命令即可在任意目录初始化知识库
#   - 透传参数：所有额外参数原样传递给 docs-init.sh
#
# 依赖：Bash 5+、Git、网络连接（可访问 GitHub）
#
# 用法：
#   # 远程执行（推荐）
#   curl -sL https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/docs-bootstrap.sh \
#     | bash -s -- [选项] <目标工程文档目录>
#
#   # 本地执行
#   bash scripts/docs-bootstrap.sh [选项] <目标工程文档目录>
#
# 环境变量：
#   GIT_REPO_URL    Git 仓库地址（默认: https://github.com/oleewen/ai-knowledge.git）
#   GIT_REF         Git 分支或标签（默认: HEAD，即默认分支）
#   TMPDIR          临时目录（默认: /tmp）
#
# 示例：
#   # 基础用法
#   curl -sL https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/docs-bootstrap.sh | bash -s -- ~/myproject/docs
#
#   # Central 模式
#   curl -sL https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/docs-bootstrap.sh | bash -s -- --mode=central ~/myproject/docs
#
#   # 多 Agent 支持
#   curl -sL https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/docs-bootstrap.sh | bash -s -- --agents=cursor,trea ~/myproject/docs
#
#   # 指定分支
#   GIT_REF=develop curl -sL https://raw.githubusercontent.com/oleewen/ai-knowledge/main/scripts/docs-bootstrap.sh | bash -s -- ~/myproject/docs
#

set -euo pipefail

# =============================================================================
# § 1  常量
# =============================================================================

readonly SDX_BS_VERSION='2.0.0'
readonly SDX_BS_MIN_BASH=5

readonly SDX_BS_DEFAULT_REPO='https://github.com/oleewen/ai-knowledge.git'
readonly SDX_BS_DEFAULT_REF='HEAD'

# =============================================================================
# § 2  运行时状态（全局，供 trap 清理使用）
# =============================================================================

SDX_BS_CLONE_DIR=''
SDX_BS_TARGET_DIR="${PWD}"

# =============================================================================
# § 3  日志与错误处理
# =============================================================================

sdx_bs_log()  { printf '%s\n'        "$*" >&2; }
sdx_bs_info() { printf '[INFO]  %s\n' "$*" >&2; }
sdx_bs_err()  { printf '[ERROR] %s\n' "$*" >&2; }

# 打印错误并退出
# 用法：sdx_bs_die <message> [exit_code]
sdx_bs_die() {
  sdx_bs_err "$1"
  exit "${2:-1}"
}

# =============================================================================
# § 4  环境检查（纯函数）
# =============================================================================

# 校验 Bash 版本 ≥ SDX_BS_MIN_BASH
sdx_bs_check_bash() {
  (( BASH_VERSINFO[0] >= SDX_BS_MIN_BASH )) \
    || sdx_bs_die "需要 Bash ${SDX_BS_MIN_BASH}+，当前版本: ${BASH_VERSION}"
}

# 检查命令是否存在
# 用法：sdx_bs_has_cmd <cmd>
sdx_bs_has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

# 校验必要依赖（git）
sdx_bs_check_deps() {
  sdx_bs_has_cmd git || sdx_bs_die "未找到 git 命令，请先安装 Git"
}

# =============================================================================
# § 5  配置读取（纯函数）
# =============================================================================

# 获取 Git 仓库 URL（优先环境变量）
sdx_bs_get_repo_url() { printf '%s' "${GIT_REPO_URL:-${SDX_BS_DEFAULT_REPO}}"; }

# 获取 Git 引用（优先环境变量）
sdx_bs_get_ref()      { printf '%s' "${GIT_REF:-${SDX_BS_DEFAULT_REF}}"; }

# 获取有效的临时目录
sdx_bs_get_tmpdir() {
  local tmpdir="${TMPDIR:-/tmp}"
  [[ -d "$tmpdir" ]] || tmpdir='/tmp'
  printf '%s' "$tmpdir"
}

# 生成唯一的克隆目录路径
# 用法：sdx_bs_gen_clone_dir <tmpdir>
sdx_bs_gen_clone_dir() {
  printf '%s/ai-knowledge-%s' "$1" "$$"
}

# =============================================================================
# § 6  Git 操作（副作用函数）
# =============================================================================

# 克隆仓库到指定目录（已存在则先清理）
# 用法：sdx_bs_clone_repo <repo_url> <ref> <dest_dir>
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

# EXIT trap：清理临时克隆目录
sdx_bs_cleanup() {
  if [[ -n "$SDX_BS_CLONE_DIR" && -d "$SDX_BS_CLONE_DIR" ]]; then
    sdx_bs_info "清理临时目录: $SDX_BS_CLONE_DIR"
    rm -rf "$SDX_BS_CLONE_DIR"
  fi
}

# =============================================================================
# § 7  参数解析
# =============================================================================

# 从参数列表中提取目标目录（最后一个非选项参数）
# 用法：sdx_bs_parse_target_dir "$@"
# 输出：目标目录路径；未找到时输出 'docs'
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
  # 前置检查
  sdx_bs_check_bash
  sdx_bs_check_deps

  # 解析目标目录（仅用于展示；实际透传给 docs-init.sh）
  SDX_BS_TARGET_DIR="$(sdx_bs_parse_target_dir "$@")"

  # 读取配置
  local repo_url ref tmpdir
  repo_url="$(sdx_bs_get_repo_url)"
  ref="$(sdx_bs_get_ref)"
  tmpdir="$(sdx_bs_get_tmpdir)"

  # 设置克隆目录并注册清理 trap
  SDX_BS_CLONE_DIR="$(sdx_bs_gen_clone_dir "$tmpdir")"
  trap sdx_bs_cleanup EXIT

  # 启动信息
  sdx_bs_log ''
  sdx_bs_log '=========================================='
  sdx_bs_log "docs-bootstrap v${SDX_BS_VERSION}"
  sdx_bs_log '=========================================='
  sdx_bs_info "仓库: $repo_url"
  sdx_bs_info "引用: $ref"
  sdx_bs_info "目标: $SDX_BS_TARGET_DIR"
  sdx_bs_log '=========================================='
  sdx_bs_log ''

  # 克隆仓库
  sdx_bs_clone_repo "$repo_url" "$ref" "$SDX_BS_CLONE_DIR" || exit 1

  # 校验必要脚本存在
  local init_script="${SDX_BS_CLONE_DIR}/scripts/docs-init.sh"
  local config_script="${SDX_BS_CLONE_DIR}/scripts/docs-config.sh"
  [[ -f "$init_script"   ]] || sdx_bs_die "仓库中未找到 scripts/docs-init.sh"
  [[ -f "$config_script" ]] || sdx_bs_die "仓库中未找到 scripts/docs-config.sh"

  # 透传所有参数给 docs-init.sh
  sdx_bs_log ''
  sdx_bs_info '>>> 执行 docs-init.sh...'
  sdx_bs_log ''

  export REPO_ROOT="$SDX_BS_CLONE_DIR"
  bash "$init_script" "$@"
}

sdx_bs_main "$@"
