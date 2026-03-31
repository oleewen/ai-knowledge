#!/usr/bin/env bash
#
# knowledge-init-bootstrap.sh — SDX 知识库初始化引导脚本
#
# 目的:
#   允许用户无需预先克隆 ai-sdd-knowledge 仓库即可执行初始化。
#   自动从 Git 拉取仓库到临时目录，然后调用 knowledge-init.sh 完成初始化。
#
# 意图:
#   - 零依赖启动：仅需 bash 和 git，无需预先下载任何文件
#   - 一键体验：单条 curl 命令即可在任意目录初始化知识库
#   - 透传参数：所有额外参数原样传递给 knowledge-init.sh
#
# 依赖:
#   - Bash 5+ (用于高级参数处理和错误捕获)
#   - Git (用于克隆远程仓库)
#   - 网络连接 (可访问 GitHub/GitLab)
#
# Usage:
#   # 远程执行（推荐）
#   curl -sL https://raw.githubusercontent.com/oleewen/ai-sdd-knowledge/main/scripts/knowledge-init-bootstrap.sh | bash -s -- [选项] <目标工程文档目录>
#
#   # 本地执行
#   bash scripts/knowledge-init-bootstrap.sh [选项] <目标工程文档目录>
#
# 环境变量:
#   GIT_REPO_URL    Git 仓库地址（默认: https://github.com/oleewen/ai-sdd-knowledge.git）
#   GIT_REF         Git 分支或标签（默认: HEAD，即默认分支）
#   TMPDIR          临时目录（默认: /tmp）
#
# Example:
#   # 基础用法：初始化到 ~/myproject/docs 目录
#   curl -sL https://raw.githubusercontent.com/oleewen/ai-sdd-knowledge/main/scripts/knowledge-init-bootstrap.sh | bash -s -- ~/myproject/docs
#
#   # Central 模式：同时登记到中央知识库
#   curl -sL https://raw.githubusercontent.com/oleewen/ai-sdd-knowledge/main/scripts/knowledge-init-bootstrap.sh | bash -s -- --mode=central ~/myproject/docs
#
#   # 多 Agent 支持：安装 cursor 和 trea 的 Agent 配置
#   curl -sL https://raw.githubusercontent.com/oleewen/ai-sdd-knowledge/main/scripts/knowledge-init-bootstrap.sh | bash -s -- --agents=cursor,trea ~/myproject/docs
#
#   # 指定分支
#   GIT_REF=develop curl -sL https://raw.githubusercontent.com/oleewen/ai-sdd-knowledge/main/scripts/knowledge-init-bootstrap.sh | bash -s -- ~/myproject/docs
#

set -euo pipefail

# -----------------------------------------------------------------------------
# 常量定义
# -----------------------------------------------------------------------------

readonly SDX_BS_VERSION='2.0.0'
readonly SDX_BS_MIN_BASH=5

# 默认配置
readonly SDX_BS_DEFAULT_REPO='https://github.com/oleewen/ai-sdd-knowledge.git'
readonly SDX_BS_DEFAULT_REF='HEAD'
readonly SDX_BS_DEFAULT_TMPDIR='${TMPDIR:-/tmp}'

# 状态变量
SDX_BS_CLONE_DIR=''
SDX_BS_TARGET_DIR="${PWD}"

# -----------------------------------------------------------------------------
# 日志与错误处理
# -----------------------------------------------------------------------------

sdx_bs_log()  { printf '%s\n' "$*" >&2; }
sdx_bs_err()  { sdx_bs_log "[ERROR] $*"; }
sdx_bs_info() { sdx_bs_log "[INFO] $*"; }

sdx_bs_die() {
    local code="${2:-1}"
    sdx_bs_err "$1"
    exit "$code"
}

# -----------------------------------------------------------------------------
# 环境检查（纯函数）
# -----------------------------------------------------------------------------

# 检查 Bash 版本
sdx_bs_check_bash() {
    if (( BASH_VERSINFO[0] < SDX_BS_MIN_BASH )); then
        sdx_bs_die "需要 Bash ${SDX_BS_MIN_BASH}+，当前版本: ${BASH_VERSION}"
    fi
}

# 检查命令是否存在
# Usage: sdx_bs_has_cmd <cmd>
sdx_bs_has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

# 检查必要依赖
sdx_bs_check_deps() {
    sdx_bs_has_cmd git || sdx_bs_die "未找到 git 命令，请先安装 Git"
}

# -----------------------------------------------------------------------------
# 配置获取（纯函数）
# -----------------------------------------------------------------------------

# 获取 Git 仓库 URL
sdx_bs_get_repo_url() {
    echo "${GIT_REPO_URL:-${SDX_BS_DEFAULT_REPO}}"
}

# 获取 Git 引用（分支/标签）
sdx_bs_get_ref() {
    echo "${GIT_REF:-${SDX_BS_DEFAULT_REF}}"
}

# 获取临时目录
sdx_bs_get_tmpdir() {
    local tmpdir="${TMPDIR:-/tmp}"
    # 确保目录存在
    [[ -d "$tmpdir" ]] || tmpdir='/tmp'
    echo "$tmpdir"
}

# 生成唯一的克隆目录名
# Usage: sdx_bs_gen_clone_dir <tmpdir> <pid>
sdx_bs_gen_clone_dir() {
    local tmpdir="$1"
    local pid="${2:-$$}"
    echo "${tmpdir}/ai-sdd-knowledge-${pid}"
}

# -----------------------------------------------------------------------------
# Git 操作（副作用函数）
# -----------------------------------------------------------------------------

# 克隆仓库
# Usage: sdx_bs_clone_repo <repo_url> <ref> <dest_dir>
sdx_bs_clone_repo() {
    local repo_url="$1" ref="$2" dest_dir="$3"

    # 清理已存在的目录
    if [[ -d "$dest_dir" ]]; then
        sdx_bs_info "清理已存在的临时目录: $dest_dir"
        rm -rf "$dest_dir"
    fi

    sdx_bs_info "克隆仓库: $repo_url"
    sdx_bs_info "  目标: $dest_dir"

    if [[ "$ref" == 'HEAD' || -z "$ref" ]]; then
        git clone --depth 1 "$repo_url" "$dest_dir" || {
            sdx_bs_err "克隆失败: $repo_url"
            return 1
        }
    else
        sdx_bs_info "  分支/标签: $ref"
        git clone --depth 1 --single-branch -b "$ref" "$repo_url" "$dest_dir" || {
            sdx_bs_err "克隆失败: $repo_url (ref: $ref)"
            return 1
        }
    fi
}

# 清理临时目录（trap 处理函数）
sdx_bs_cleanup() {
    if [[ -n "$SDX_BS_CLONE_DIR" && -d "$SDX_BS_CLONE_DIR" ]]; then
        sdx_bs_info "清理临时目录: $SDX_BS_CLONE_DIR"
        rm -rf "$SDX_BS_CLONE_DIR"
    fi
}

# -----------------------------------------------------------------------------
# 参数解析
# -----------------------------------------------------------------------------

# 解析目标目录（最后一个参数）
# Usage: sdx_bs_parse_target_dir "$@"
sdx_bs_parse_target_dir() {
    local -a args=("$@")

    # 最后一个非选项参数作为目标目录
    local target=''
    local i
    for (( i = $# - 1; i >= 0; i-- )); do
        local arg="${args[$i]}"
        # 跳过选项和选项值
        if [[ "$arg" != -* ]]; then
            target="$arg"
            break
        fi
    done

    # 如果没有找到目标目录，使用当前目录
    if [[ -z "$target" ]]; then
        target='docs'
    fi

    echo "$target"
}

# -----------------------------------------------------------------------------
# 主流程
# -----------------------------------------------------------------------------

sdx_bs_main() {
    # 环境检查
    sdx_bs_check_bash
    sdx_bs_check_deps

    # 解析目标目录
    local target_dir
    target_dir="$(sdx_bs_parse_target_dir "$@")"
    [[ -n "$target_dir" ]] && SDX_BS_TARGET_DIR="$target_dir"

    # 获取配置
    local repo_url ref tmpdir
    repo_url="$(sdx_bs_get_repo_url)"
    ref="$(sdx_bs_get_ref)"
    tmpdir="$(sdx_bs_get_tmpdir)"

    # 设置克隆目录
    SDX_BS_CLONE_DIR="$(sdx_bs_gen_clone_dir "$tmpdir")"

    # 注册清理函数
    trap sdx_bs_cleanup EXIT

    # 输出启动信息
    sdx_bs_info ""
    sdx_bs_info "=========================================="
    sdx_bs_info "knowledge-init bootstrap v${SDX_BS_VERSION}"
    sdx_bs_info "=========================================="
    sdx_bs_info "仓库: $repo_url"
    sdx_bs_info "引用: $ref"
    sdx_bs_info "目标: $SDX_BS_TARGET_DIR"
    sdx_bs_info "=========================================="
    sdx_bs_info ""

    # 克隆仓库
    sdx_bs_clone_repo "$repo_url" "$ref" "$SDX_BS_CLONE_DIR" || exit 1

    # 验证主脚本存在
    local init_script="${SDX_BS_CLONE_DIR}/scripts/knowledge-init.sh"
    [[ -f "$init_script" ]] || sdx_bs_die "仓库中未找到 scripts/knowledge-init.sh"

    # 验证配置脚本存在
    local config_script="${SDX_BS_CLONE_DIR}/scripts/knowledge-config.sh"
    [[ -f "$config_script" ]] || sdx_bs_die "仓库中未找到 scripts/knowledge-config.sh"

    # 设置环境变量并执行主脚本
    # 额外参数 ($@) 原样透传
    sdx_bs_info ""
    sdx_bs_info ">>> 执行 knowledge-init.sh..."
    sdx_bs_info ""

    export REPO_ROOT="$SDX_BS_CLONE_DIR"

    bash "$init_script" "$@"
}

# 执行主流程（将所有参数透传）
sdx_bs_main "$@"
