#!/usr/bin/env bash
# 知识库升级：脚本负责来源、清单与 scaffold；正文重填由 Skill 编排。
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../../scripts/docs-core.sh
source "$SCRIPT_DIR/../../../scripts/docs-core.sh"
# shellcheck source=../../../scripts/lib/version.sh
source "$SCRIPT_DIR/../../../scripts/lib/version.sh"
source "$SCRIPT_DIR/lib/source.sh"
source "$SCRIPT_DIR/lib/scan.sh"
source "$SCRIPT_DIR/lib/apply.sh"

DRY_RUN=1
APPLY_SCAFFOLD=0
META_PATH_OVERRIDE=""
REF_OVERRIDE=""
UPGRADE_STAMP=""
BACKUP_ROOT=""
BACKUP_SCAN_FILE=""
META_ROOT=""
META_SRC=""
META_DOC_DIR=""
META_CLEANUP=""
META_CLONE_CLEANUP=""
META_GIT_REPO=""
META_REVISION=""
META_ORIGIN=""
VERSION_FROM=""
VERSION_TO=""
VERSION_FROM_SHA=""
VERSION_TO_SHA=""

usage() {
  cat <<'EOF'
Usage: docs-upgrade.sh [--dry-run | --apply-scaffold] [--meta-path PATH] [--ref REF]

在目标工程内读取 .docsconfig，对齐 knowledge-links.yaml 唯一 type: meta 的同层模板。
依赖 Bash 5+、Git 和 Agent 共享脚本；正文结构重填由 Skill/Agent 执行。

  --dry-run          只打印清单（默认）；不备份、不写盘、不建链、不重写路径
  --apply-scaffold   先备份，再复制新增骨架、整文件覆盖根 DESIGN.md；不自动合正文
  --meta-path PATH   本次覆盖 meta 路径，不修改登记；使用 KNOWLEDGE_TYPE 目录
  --ref REF          显式 Git ref；不传时有效 Git path 用当前 HEAD，回退 clone 用 main
  -h, --help         本帮助

meta.dir 缺省为 KNOWLEDGE_TYPE；显式错配在扫描前停止。Git path 有未提交改动即停止。
目标 DESIGN.md 有 version 时，仅处理所选 ref 可达历史中当前/最新发布点的模板差异，
内容固定为目标发布快照；缺基线即停止。无 version 的旧库扫描整树。
scaffold 保留当前版本；Agent 完成全部重填、未落位处理与校核后才推进版本。

apply 前备份现有文本安全超集及待重填/覆盖文件到唯一 .docs-init/upgrade-* 目录。
同次目录内保留 .source-*/templates 与 source.txt，供 Agent 重填和中断恢复；不自动清理。
源文件与目标目录或非目录祖先冲突时，预览和实跑均在写入前失败。
收尾将 agent 路径按深度重写为相对 .agents/（meta 为 agent/），不改 IDE 段；
非 meta 建 DOC_DIR/.agents 软链，普通根 README 更新注记；空骨架桶也收尾。
不清空 DOC_DIR、不用元库覆盖 knowledge-links.yaml、不删除本库独有文件、不跟随软链。
整树缺失 EXAMPLE 遇同目录真实同类实例则跳过；指定路径模式由 Skill 编排，无 --path。
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; APPLY_SCAFFOLD=0; shift ;;
    --apply-scaffold) APPLY_SCAFFOLD=1; DRY_RUN=0; shift ;;
    --meta-path)
      shift
      [[ -n "${1:-}" ]] || error "缺少 --meta-path 值"
      META_PATH_OVERRIDE="$1"
      shift
      ;;
    --ref)
      shift
      [[ -n "${1:-}" ]] || error "缺少 --ref 值"
      REF_OVERRIDE="$1"
      shift
      ;;
    -h|--help) usage; exit 0 ;;
    *) error "未知参数: $1" ;;
  esac
done

trap cleanup EXIT

docsconfig_bootstrap_validate
repo_abs="$(docsconfig_repo_abs)"
doc_abs="$(docsconfig_doc_abs)"
[[ -n "${KNOWLEDGE_TYPE:-}" ]] || error ".docsconfig 缺少 KNOWLEDGE_TYPE"

LINKS_FILE="${doc_abs%/}/knowledge-links.yaml"
declare -a ADD_LIST=() SKIP_LIST=() RESTRUCTURE_LIST=() OVERWRITE_LIST=() LOCAL_ONLY_LIST=()
declare -a IGNORED_SLOT_DIRS=() SKIP_SYMLINK_LIST=()
declare -a TYPE_CONFLICT_LIST=()
declare -A IGNORED_SLOT_SEEN=() SKIP_SYMLINK_SEEN=()

resolve_meta_root "$LINKS_FILE"
scan_upgrade_tree
print_upgrade_plan
[[ ${#TYPE_CONFLICT_LIST[@]} -eq 0 ]] || error '路径类型冲突；请先决定迁移方案，本次未写入'

if [[ "$APPLY_SCAFFOLD" != '1' ]]; then
  info "dry-run 完成；实跑骨架写入请用 --apply-scaffold（须 Skill 已取得 C；含根级 DESIGN 整文件覆盖）"
  exit 0
fi

apply_scaffold
finish_scaffold
