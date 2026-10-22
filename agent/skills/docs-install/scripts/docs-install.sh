#!/usr/bin/env bash
# docs-install 入口：参数解析、纯预检、写入三个阶段。
set -euo pipefail
# 预检调用的 Python 也必须零写，包含解释器自动生成的字节码缓存。
export PYTHONDONTWRITEBYTECODE=1
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../scripts/lib/bash.sh"
# docs-config 保留源码/安装布局兼容的共享库与 Bash 5 守卫。
source "$SCRIPT_DIR/docs-config.sh"
source "$SCRIPT_DIR/lib/cli.sh"
source "$SCRIPT_DIR/lib/preflight.sh"
source "$SCRIPT_DIR/lib/install.sh"

declare -A CFG=(
  [repo_root]='' [docs_abs]='' [target_dir]=''
  [scope]="${SCOPE:-$KINIT_DEFAULT_SCOPE}"
  [type]="$KINIT_DEFAULT_TYPE" [type_explicit]=0
  [mode]="${MODE:-$KINIT_DEFAULT_MODE}"
  [dry_run]=0 [force]="${FORCE:-0}"
  [create_project_root]="${CREATE_PROJECT_ROOT:-0}"
)
DOC_INIT_STAMP=''

# 已经开始写入时发生错误：保留旧文档备份，临时 links 文件也留给操作者恢复。
docs_install_on_exit() {
  local status=$?
  if (( status != 0 )) && [[ -n "$DOC_INIT_STAMP" && "${CFG[dry_run]}" == 0 ]]; then
    warn "初始化未完成；已有备份（若有）位于: $(get_backup_root)"
    [[ -z "${_DOCS_INSTALL_LINKS_STASH:-}" ]] || warn "暂存建联清单: $_DOCS_INSTALL_LINKS_STASH"
  fi
}
trap docs_install_on_exit EXIT

docs_install_run() {
  docs_install_parse_args "$@"
  docs_install_preflight
  if [[ "${CFG[scope]}" == config ]]; then
    docs_install_write_docsconfig
  else
    DOC_INIT_STAMP="$(date +%Y-%m-%d_%H-%M-%S)"
    export IO_DRY_RUN="${CFG[dry_run]}" IO_FORCE=1
    have_perl || warn '未检测到 perl：将跳过文件内容替换，建议安装 perl。'
    docs_install_stash_knowledge_links
    reset_docs_dir_with_backup
    docs_install_copy_templates
    docs_install_restore_knowledge_links
    docs_install_write_docsconfig
    docs_install_upsert_knowledge_meta
    docs_install_rewrite_agent_paths
  fi
  if [[ "${CFG[dry_run]}" == 1 ]]; then
    info "预览完成，未写入: ${CFG[docs_abs]}"
  else
    info "完成：docs-install（--scope=${CFG[scope]}） 目标: ${CFG[docs_abs]}"
  fi
}

docs_install_run "$@"
