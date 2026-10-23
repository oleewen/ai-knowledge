#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  run-docs-distill.sh --name NAME [--doc-dir system|solution|company]
                      [--dry-run] [--root DIR]

Options:
  --name NAME       源名称；必填。--app 为兼容别名
  --doc-dir LAYER   目标层；优先级高于 DOC_DIR 和 .docsconfig
  --dry-run         只校验并输出预览模式，不写 overview
  --root DIR        目标仓根；默认从当前目录向上查找 .docsconfig 或 .git
  -h, --help        显示帮助

本脚本只校验路径和前置条件，不生成 overview 正文，不写 DISTILL-LOG。
USAGE
}

name=""
doc_dir_arg=""
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

read_doc_dir() {
  local candidate=""
  if [[ -n "$doc_dir_arg" ]]; then
    candidate="$doc_dir_arg"
  elif [[ -n "${DOC_DIR:-}" ]]; then
    candidate="$DOC_DIR"
  elif [[ -f "$root_dir/.docsconfig" ]]; then
    candidate="$(awk -F= '$1 == "DOC_DIR" {gsub(/["'"'"' ]/, "", $2); sub(/\r$/, "", $2); print $2; exit}' "$root_dir/.docsconfig")"
  fi
  candidate="${candidate#./}"
  candidate="${candidate%/}"
  printf '%s' "$candidate"
}

doc_dir="$(read_doc_dir)"
case "$doc_dir" in
  system|solution|company) ;;
  "")
    echo "[ERROR] 无法解析 DOC_DIR；请传 --doc-dir system|solution|company，或设置 DOC_DIR / .docsconfig" >&2
    exit 1
    ;;
  *)
    echo "[ERROR] DOC_DIR 须为 system|solution|company（当前: ${doc_dir}）；application overview 请走 docs-extract" >&2
    exit 1
    ;;
esac

case "$doc_dir" in
  system)
    slot_dir="$root_dir/system/application-slots/application-$name"
    overview_dir="$root_dir/system/knowledge/overview"
    ;;
  solution)
    slot_dir="$root_dir/solution/system-slots/system-$name"
    overview_dir="$root_dir/solution/knowledge/overview"
    ;;
  company)
    slot_dir="$root_dir/company/solution-slots/solution-$name"
    overview_dir="$root_dir/company/knowledge/overview"
    ;;
esac

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

if [[ -f "$target" ]]; then
  target_state="update"
  echo "[OK] 目标: ${target#$root_dir/}（更新）"
else
  target_state="create"
  echo "[INFO] 目标: ${target#$root_dir/}（从模板创建）"
fi

printf '\n=== docs-distill 校验摘要 ===\n'
printf ' root     : %s\n' "$root_dir"
printf ' doc_dir  : %s\n' "$doc_dir"
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
