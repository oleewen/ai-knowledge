#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  run-docs-distill.sh --name NAME [--doc-dir RELATIVE_PATH] [--layer system|solution|company]
                      [--dry-run] [--root DIR]

Options:
  --name NAME       源名称；必填。--app 为兼容别名
  --doc-dir PATH    实际文档相对目录；优先级高于 DOC_DIR 和 .docsconfig
  --layer LAYER     知识层；优先级高于 KNOWLEDGE_TYPE 和 .docsconfig
  --dry-run         只校验并输出预览模式，不写 overview
  --root DIR        目标仓根；默认从当前目录向上查找 .docsconfig 或 .git
  -h, --help        显示帮助

本脚本只校验路径和前置条件，不生成 overview 正文，不写 DISTILL-LOG。
USAGE
}

name=""
doc_dir_arg=""
layer_arg=""
dry_run=false
root_arg=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name|--app)
      [[ $# -ge 2 ]] || { echo "[ERROR] $1 缺少值" >&2; usage >&2; exit 2; }
      name="$2"
      shift 2
      ;;
    --doc-dir)
      [[ $# -ge 2 ]] || { echo "[ERROR] --doc-dir 缺少值" >&2; usage >&2; exit 2; }
      doc_dir_arg="$2"
      shift 2
      ;;
    --layer)
      [[ $# -ge 2 ]] || { echo "[ERROR] --layer 缺少值" >&2; exit 2; }
      layer_arg="$2"
      shift 2
      ;;
    --dry-run)
      dry_run=true
      shift
      ;;
    --root)
      [[ $# -ge 2 ]] || { echo "[ERROR] --root 缺少值" >&2; usage >&2; exit 2; }
      root_arg="$2"
      shift 2
      ;;
    --since|--full)
      echo "[ERROR] 已废止参数: $1；本技能仅全量，且不写 DISTILL-LOG" >&2
      usage >&2
      exit 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[ERROR] 未知参数: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$name" ]]; then
  echo "[ERROR] --name 为必填参数" >&2
  usage >&2
  exit 2
fi
if [[ ! "$name" =~ ^[A-Za-z0-9][A-Za-z0-9_-]*$ ]]; then
  echo "[ERROR] --name 格式非法: $name" >&2
  exit 2
fi

find_root() {
  local current
  current="$(pwd -P)"
  while [[ "$current" != "/" ]]; do
    if [[ -f "$current/.docsconfig" || -e "$current/.git" ]]; then
      printf '%s' "$current"
      return 0
    fi
    current="$(dirname "$current")"
  done
  return 1
}

if [[ -n "$root_arg" ]]; then
  root_dir="$(cd "$root_arg" 2>/dev/null && pwd -P)" || {
    echo "[ERROR] 项目根目录不存在: $root_arg" >&2
    exit 1
  }
elif root_dir="$(find_root)"; then
  :
else
  echo "[ERROR] 无法从当前目录定位目标仓；请传 --root DIR" >&2
  exit 1
fi

if [[ ! -d "$root_dir" ]]; then
  echo "[ERROR] 项目根目录不是目录: $root_dir" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Shared parser reads values without executing configuration text.
source "$SCRIPT_DIR/../../../scripts/lib/docsconfig.sh"
config_repo='' config_doc='' config_agent='' config_type=''
if [[ -f "$root_dir/.docsconfig" ]]; then
  docsconfig_read_into "$root_dir/.docsconfig" config_repo config_doc config_agent config_type
fi
doc_dir="${doc_dir_arg:-${DOC_DIR:-$config_doc}}"
doc_dir="${doc_dir#./}"
doc_dir="${doc_dir%/}"
docsconfig_validate_doc_dir "$doc_dir" || exit 1
layer="${layer_arg:-${KNOWLEDGE_TYPE:-$config_type}}"
# Legacy standard directory names, including explicit meta-repository layers.
if [[ -z "$layer" || "$layer" == meta ]]; then
  case "$doc_dir" in
    system|solution|company) layer="$doc_dir" ;;
    *) echo "[ERROR] 自定义 DOC_DIR 须提供 KNOWLEDGE_TYPE 或 --layer，不能从目录名猜层" >&2; exit 1 ;;
  esac
fi
case "$layer" in
  system) slot_kind=application ;;
  solution) slot_kind=system ;;
  company) slot_kind=solution ;;
  *) echo "[ERROR] KNOWLEDGE_TYPE/--layer 须为 system|solution|company；DOC_DIR=$doc_dir" >&2; exit 1 ;;
esac
if [[ ! -d "$root_dir/$doc_dir" ]]; then
  echo "[ERROR] DOC_DIR 目录不存在: $doc_dir" >&2
  exit 1
fi
doc_root="$(cd "$root_dir/$doc_dir" && pwd -P)"
case "$doc_root/" in
  "$root_dir/"*) ;;
  *) echo "[ERROR] DOC_DIR 越出目标仓: $doc_dir" >&2; exit 1 ;;
esac
slot_dir="$doc_root/$slot_kind-slots/$slot_kind-$name"
overview_dir="$doc_root/knowledge/overview"
# The source slot may be a federation symlink; the output tree may not escape.
if [[ -d "$overview_dir" ]]; then
  physical_overview="$(cd "$overview_dir" && pwd -P)"
  case "$physical_overview/" in
    "$doc_root/"*) ;;
    *) echo "[ERROR] overview 目录越出文档根: $overview_dir" >&2; exit 1 ;;
  esac
fi

template="$overview_dir/NAME-overview.md"
target="$overview_dir/$name-overview.md"
errors=0

if [[ ! -d "$slot_dir" ]]; then
  echo "[ERROR] 槽位不存在: ${slot_dir#$root_dir/}（先用普通 Git 工作流准备下级仓，再运行 docs-link --check / --repair --target）" >&2
  errors=$((errors + 1))
elif [[ -z "$(find -H "$slot_dir" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
  echo "[ERROR] 槽位为空: ${slot_dir#$root_dir/}（先检查下级文档目录内容，再运行 docs-link --check）" >&2
  errors=$((errors + 1))
elif [[ ! -f "$slot_dir/README.md" ]]; then
  echo "[ERROR] 槽位契约缺失: ${slot_dir#$root_dir/}/README.md（先补职责/粒度契约）" >&2
  errors=$((errors + 1))
else
  echo "[OK] 槽位: ${slot_dir#$root_dir/}"
fi

if [[ ! -f "$template" ]]; then
  echo "[ERROR] overview 模板缺失: ${template#$root_dir/}" >&2
  errors=$((errors + 1))
else
  echo "[OK] 模板: ${template#$root_dir/}"
fi

if [[ -L "$target" || ( -e "$target" && ! -f "$target" ) ]]; then
  echo "[ERROR] 目标冲突（须为普通文件或不存在）: ${target#$root_dir/}" >&2
  target_state="conflict"
  errors=$((errors + 1))
elif [[ -f "$target" ]]; then
  target_state="update"
  echo "[OK] 目标: ${target#$root_dir/}（更新）"
else
  target_state="create"
  echo "[INFO] 目标: ${target#$root_dir/}（从模板创建）"
fi

printf '\n=== docs-distill 校验摘要 ===\n'
printf ' root     : %s\n' "$root_dir"
printf ' doc_dir  : %s\n' "$doc_dir"
printf ' layer    : %s\n' "$layer"
printf ' name     : %s\n' "$name"
printf ' mode     : full\n'
printf ' target   : %s\n' "${slot_dir#$root_dir/} -> ${target#$root_dir/}"
printf ' state    : %s\n' "$target_state"
printf ' dry_run  : %s\n' "$dry_run"
printf ' write    : 本脚本不写 overview / DISTILL-LOG；正文由 Agent 执行\n'

if (( errors > 0 )); then
  echo "[FAIL] 校验未通过（${errors}）" >&2
  exit 1
fi

echo "[DONE] 校验通过；请 Agent 按 scope-clarity 与 federation-spec 继续。"
