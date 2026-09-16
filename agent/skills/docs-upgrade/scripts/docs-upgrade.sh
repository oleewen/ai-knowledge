#!/usr/bin/env bash
# docs-upgrade.sh — 知识库相对元库的升级清单 / 骨架写入（不清空 DOC_DIR）
# 结构重填与未落位确认由 /docs-upgrade Skill 编排；本脚本只做机械扫描与 scaffold。
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../../scripts/lib/docsconfig.sh
source "$SCRIPT_DIR/../../../scripts/lib/docsconfig.sh"
# knowledge-links / rewrite 等不在轻量 bootstrap 内
# shellcheck source=../../../scripts/docs-core.sh
source "$SCRIPT_DIR/../../../scripts/docs-core.sh"
# error/info/rewrite_* / knowledge_links_* 由 docs-core 聚合提供；无需再 source log-io

DRY_RUN=1
APPLY_SCAFFOLD=0
META_PATH_OVERRIDE=""
REF_OVERRIDE=""
UPGRADE_STAMP=""
BACKUP_ROOT=""
META_ROOT=""
META_SRC=""
META_DOC_DIR=""
META_CLEANUP=""

usage() {
  cat <<'EOF'
Usage: docs-upgrade.sh [--dry-run | --apply-scaffold] [--meta-path PATH] [--ref REF]

在含 .docsconfig 的工程内执行。读 DOC_ROOT/knowledge-links.yaml 的 type: meta，
对齐元库 {meta}/{doc_dir}/，输出变更清单；--apply-scaffold 时备份并写入「新增骨架」与根级 DESIGN 整文件覆盖。

  --dry-run          只打印清单（默认）
  --apply-scaffold   备份将动路径后写入新增骨架 + 根级 DESIGN.md 整文件覆盖；收尾将 agent/ 与 IDE Agent 路径重写为 ~/.agents/（同 docs-install）
  --meta-path PATH   覆盖 meta 本机 path（不改 yaml；规则同 yaml path）
  --ref REF          显式 git ref（优先于 path 当前 HEAD）；不传则：有效 git path 用当前 HEAD；
                     path 无效再 clone 时默认 main
  -h, --help         本帮助

禁止：不会调用 docs-install 清空 DOC_DIR；不会覆盖 knowledge-links.yaml；
不会把 README-s.md / README-c.md 当作目标文件名写入（README.md 映射除外）。
根级 CONTRIBUTING.md 按普通 md 进清单（本无则 scaffold；已改则结构重填）。
根级 DESIGN.md：本无则 scaffold；已改则进「整文件覆盖」桶（--apply-scaffold 时以元库为准覆盖，不走 H2 结构重填）。
忽略 DOC_ROOT 顶层遗留 application-* / system-*（不含 application-slots / system-slots）；
凡软链（文件或目录）一律跳过不跟随；application-slots / system-slots 根下真文件可升级；
*-slots/changelogs/** 本有则整文件本库胜（不重填），本无则可 scaffold。
--dry-run 不重写路径、不改 README；--apply-scaffold 即使新增骨架为空也跑全树重写。
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

normalize_text() {
  local f="$1"
  [[ -f "$f" ]] || return 1
  if command -v perl >/dev/null 2>&1; then
    perl -pe 's/\r\n/\n/g; s/\r/\n/g; s/[ \t]+$//g' "$f"
  else
    tr -d '\r' <"$f" | sed -E 's/[[:blank:]]+$//'
  fi
}

files_equal_normalized() {
  local a="$1" b="$2"
  [[ -f "$a" && -f "$b" ]] || return 1
  local ha hb
  ha="$(normalize_text "$a" | shasum -a 256 | awk '{print $1}')"
  hb="$(normalize_text "$b" | shasum -a 256 | awk '{print $1}')"
  [[ "$ha" == "$hb" ]]
}

# 顶层遗留联邦槽位名（不含 application-slots / system-slots）
is_legacy_federal_slot_rel() {
  local rel="$1"
  local top="${rel%%/*}"
  case "$top" in
    application-slots|system-slots) return 1 ;;
    application-*|system-*) return 0 ;;
  esac
  return 1
}

# *-slots/changelogs/**：本有整文件本库胜；本无可 scaffold
is_slots_changelog_rel() {
  case "$1" in
    application-slots/changelogs/*|system-slots/changelogs/*) return 0 ;;
  esac
  return 1
}

# 根级 DESIGN.md：元库模板 SSOT；已改则整文件覆盖（不走 H2 结构重填）
is_root_design_rel() {
  [[ "$1" == 'DESIGN.md' ]]
}

is_excluded_meta_rel() {
  local rel="$1"
  is_legacy_federal_slot_rel "$rel" && return 0
  case "$rel" in
    knowledge-links.yaml) return 0 ;;
    README-s.md|README-c.md) return 0 ;;
  esac
  return 1
}

note_ignored_legacy_slot_dir() {
  local rel="$1" top
  is_legacy_federal_slot_rel "$rel" || return 0
  top="${rel%%/*}"
  [[ -n "${IGNORED_SLOT_SEEN[$top]:-}" ]] && return 0
  IGNORED_SLOT_SEEN["$top"]=1
  IGNORED_SLOT_DIRS+=("$top")
}

# 路径自身或任一已存在祖先为软链 → 跳过
path_is_or_under_symlink() {
  local root="$1" rel="$2"
  local cur="${root%/}" part rest="$rel"
  [[ -z "$rel" ]] && return 1
  while [[ -n "$rest" ]]; do
    part="${rest%%/*}"
    if [[ "$rest" == */* ]]; then
      rest="${rest#*/}"
    else
      rest=""
    fi
    cur="${cur}/${part}"
    if [[ -L "$cur" ]]; then
      return 0
    fi
    [[ -e "$cur" ]] || return 1
  done
  return 1
}

meta_src_for_local_rel() {
  local src_root="$1" local_rel="$2"
  if [[ "$local_rel" == 'README.md' ]]; then
    if [[ -f "$src_root/README-s.md" ]]; then
      printf '%s' "$src_root/README-s.md"
      return 0
    fi
    if [[ -f "$src_root/README.md" ]]; then
      printf '%s' "$src_root/README.md"
      return 0
    fi
    return 1
  fi
  if [[ -f "$src_root/$local_rel" ]]; then
    printf '%s' "$src_root/$local_rel"
    return 0
  fi
  return 1
}

meta_git_is_dirty() {
  local repo="$1"
  [[ -n "$(git -C "$repo" status --porcelain 2>/dev/null || true)" ]]
}

# ref 非空 = 显式 --ref；空 = 未传 --ref
resolve_meta_tree() {
  local meta_path="$1"
  local meta_repo="$2"
  local ref="$3"
  local work archive_ref clone_ref

  if [[ -d "$meta_path/.git" ]]; then
    if meta_git_is_dirty "$meta_path"; then
      error "meta path 工作区有未提交改动，拒绝升级: ${meta_path}（请先提交或清理）"
    fi
    work="$(mktemp -d "${TMPDIR:-/tmp}/docs-upgrade-meta.XXXXXX")"
    if [[ -n "$ref" ]]; then
      info ">>> git fetch @ ${meta_path} (ref=${ref})"
      git -C "$meta_path" fetch --quiet origin "$ref" 2>/dev/null \
        || git -C "$meta_path" fetch --quiet origin 2>/dev/null \
        || warn "git fetch 失败，将尝试本地 ref: ${ref}"
      if git -C "$meta_path" rev-parse --verify "origin/$ref" >/dev/null 2>&1; then
        archive_ref="origin/$ref"
      elif git -C "$meta_path" rev-parse --verify "$ref" >/dev/null 2>&1; then
        archive_ref="$ref"
      else
        rm -rf "$work"
        error "meta path 找不到 ref（origin/${ref} 与本地 ${ref} 均无）: ${meta_path}"
      fi
      info ">>> meta 结构源: git archive ${archive_ref} @ ${meta_path}"
      git -C "$meta_path" archive "$archive_ref" | tar -x -C "$work"
    else
      info ">>> meta 结构源: git archive HEAD @ ${meta_path} (当前分支，未传 --ref)"
      git -C "$meta_path" archive HEAD | tar -x -C "$work"
    fi
    META_ROOT="$work"
    META_CLEANUP="$work"
  elif [[ -d "$meta_path" && ( -d "$meta_path/application" || -d "$meta_path/system" || -d "$meta_path/company" ) ]]; then
    META_ROOT="$meta_path"
    META_CLEANUP=""
  elif [[ -n "$meta_repo" ]]; then
    clone_ref="${ref:-main}"
    work="$(mktemp -d "${TMPDIR:-/tmp}/docs-upgrade-clone.XXXXXX")"
    info ">>> clone ${meta_repo} @ ${clone_ref} -> ${work}"
    if ! git clone --depth 1 --branch "$clone_ref" "$meta_repo" "$work" 2>/dev/null; then
      git clone --depth 1 "$meta_repo" "$work"
    fi
    META_ROOT="$work"
    META_CLEANUP="$work"
  else
    error "meta path 不可用且无 repository: path=${meta_path}"
  fi
}

resolve_meta_root() {
  local links_file="$1"
  local -a paths=() repos=() doc_dirs=() apps=() labels=() types=()
  local i meta_idx=-1 meta_count=0
  local meta_path meta_repo meta_doc_dir ref

  if [[ -n "$META_PATH_OVERRIDE" ]]; then
    meta_path="$(abs_path "$META_PATH_OVERRIDE")"
    meta_repo=""
    meta_doc_dir="${KNOWLEDGE_TYPE}"
    ref="${REF_OVERRIDE:-}"
  else
    [[ -f "$links_file" ]] || error "缺少 knowledge-links.yaml: $links_file（请先装机或补 type: meta）"
    knowledge_links_load_into_arrays "$links_file" paths repos doc_dirs apps labels types
    for ((i = 0; i < ${#types[@]}; i++)); do
      if [[ "${types[i]}" == 'meta' ]]; then
        meta_count=$((meta_count + 1))
        meta_idx=$i
      fi
    done
    [[ "$meta_count" -eq 1 ]] || error "须恰好一条 type: meta（当前 ${meta_count}）。可 --meta-path 覆盖，或修复 links / 重跑 docs-install upsert"
    meta_path="$(knowledge_link_expand_stored_path "${paths[meta_idx]}")"
    meta_repo="${repos[meta_idx]}"
    meta_doc_dir="${doc_dirs[meta_idx]:-$KNOWLEDGE_TYPE}"
    ref="${REF_OVERRIDE:-}"
  fi

  resolve_meta_tree "$meta_path" "$meta_repo" "$ref"

  META_DOC_DIR="$meta_doc_dir"
  META_SRC="${META_ROOT%/}/${META_DOC_DIR}"
  [[ -d "$META_SRC" ]] || error "元库缺少模板目录: $META_SRC"
  info "结构源: $META_SRC"
}

backup_file_to_stamp() {
  local src="$1" rel="$2"
  [[ -f "$src" ]] || return 0
  local dst="${BACKUP_ROOT}/${rel}"
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
}

ensure_backup_root() {
  UPGRADE_STAMP="$(date +%Y-%m-%d_%H-%M-%S)"
  BACKUP_ROOT="${REPO_ROOT%/}/.docs-init/upgrade-${UPGRADE_STAMP}"
  mkdir -p "$BACKUP_ROOT"
  info "备份根: $BACKUP_ROOT"
}

cleanup() {
  if [[ -n "${META_CLEANUP:-}" && -d "$META_CLEANUP" ]]; then
    rm -rf "$META_CLEANUP"
  fi
}
trap cleanup EXIT

docsconfig_bootstrap_validate
[[ -n "${KNOWLEDGE_TYPE:-}" ]] || error ".docsconfig 缺少 KNOWLEDGE_TYPE"

LINKS_FILE="${DOC_ROOT%/}/knowledge-links.yaml"
resolve_meta_root "$LINKS_FILE"

declare -a ADD_LIST=() SKIP_LIST=() RESTRUCTURE_LIST=() OVERWRITE_LIST=() LOCAL_ONLY_LIST=()
declare -a IGNORED_SLOT_DIRS=() SKIP_SYMLINK_LIST=()
declare -A IGNORED_SLOT_SEEN=() SKIP_SYMLINK_SEEN=()

note_skip_symlink() {
  local rel="$1"
  [[ -n "${SKIP_SYMLINK_SEEN[$rel]:-}" ]] && return 0
  SKIP_SYMLINK_SEEN["$rel"]=1
  SKIP_SYMLINK_LIST+=("$rel")
}

# 本库软链清单（find 不跟随目录软链；另列 -type l）
while IFS= read -r -d '' rel; do
  rel="${rel#./}"
  [[ -z "$rel" ]] && continue
  if is_legacy_federal_slot_rel "$rel"; then
    note_ignored_legacy_slot_dir "$rel"
    continue
  fi
  note_skip_symlink "$rel"
done < <(cd "${DOC_ROOT}" && find . -type l -print0)

while IFS= read -r -d '' rel; do
  rel="${rel#./}"
  [[ -z "$rel" ]] && continue
  if is_legacy_federal_slot_rel "$rel"; then
    note_ignored_legacy_slot_dir "$rel"
    continue
  fi
  is_excluded_meta_rel "$rel" && continue

  local_rel="$rel"
  src_f="$META_SRC/$rel"
  dst_f="${DOC_ROOT%/}/$local_rel"

  if path_is_or_under_symlink "${DOC_ROOT%/}" "$local_rel"; then
    note_skip_symlink "$local_rel"
    continue
  fi

  if [[ ! -e "$dst_f" ]]; then
    ADD_LIST+=("$local_rel")
    continue
  fi
  if [[ -f "$dst_f" && -f "$src_f" ]]; then
    if is_slots_changelog_rel "$local_rel"; then
      SKIP_LIST+=("$local_rel (changelogs·本库胜)")
      continue
    fi
    if files_equal_normalized "$src_f" "$dst_f"; then
      SKIP_LIST+=("$local_rel")
    else
      if is_root_design_rel "$local_rel"; then
        OVERWRITE_LIST+=("$local_rel")
      elif [[ "$local_rel" == *.md ]]; then
        RESTRUCTURE_LIST+=("$local_rel")
      else
        SKIP_LIST+=("$local_rel (非 md 已改·本库胜)")
      fi
    fi
  fi
done < <(cd "$META_SRC" && find . -type f -print0)

if [[ "$KNOWLEDGE_TYPE" == 'application' ]]; then
  map_src="$(meta_src_for_local_rel "$META_SRC" 'README.md' || true)"
  if [[ -n "$map_src" && -f "${DOC_ROOT%/}/README.md" ]]; then
    already=0
    for x in "${RESTRUCTURE_LIST[@]+"${RESTRUCTURE_LIST[@]}"}" "${SKIP_LIST[@]+"${SKIP_LIST[@]}"}" "${ADD_LIST[@]+"${ADD_LIST[@]}"}"; do
      [[ "$x" == 'README.md' || "$x" == README.md* ]] && already=1
    done
    if [[ "$already" -eq 0 ]]; then
      if files_equal_normalized "$map_src" "${DOC_ROOT%/}/README.md"; then
        SKIP_LIST+=('README.md')
      else
        RESTRUCTURE_LIST+=('README.md')
      fi
    fi
  elif [[ -n "$map_src" && ! -e "${DOC_ROOT%/}/README.md" ]]; then
    ADD_LIST+=('README.md')
  fi
fi

declare -A META_RELS=()
while IFS= read -r -d '' rel; do
  rel="${rel#./}"
  [[ -z "$rel" ]] && continue
  if is_legacy_federal_slot_rel "$rel"; then
    note_ignored_legacy_slot_dir "$rel"
    continue
  fi
  is_excluded_meta_rel "$rel" && continue
  META_RELS["$rel"]=1
done < <(cd "$META_SRC" && find . -type f -print0)
META_RELS['README.md']=1

while IFS= read -r -d '' rel; do
  rel="${rel#./}"
  [[ -z "$rel" ]] && continue
  [[ "$rel" == 'knowledge-links.yaml' ]] && continue
  if is_legacy_federal_slot_rel "$rel"; then
    note_ignored_legacy_slot_dir "$rel"
    continue
  fi
  if path_is_or_under_symlink "${DOC_ROOT%/}" "$rel"; then
    note_skip_symlink "$rel"
    continue
  fi
  if [[ -z "${META_RELS[$rel]:-}" ]]; then
    LOCAL_ONLY_LIST+=("$rel")
  fi
done < <(cd "${DOC_ROOT}" && find . -type f -print0)

print_bucket() {
  local title="$1"
  shift
  local -a items=("$@")
  printf '\n== %s (%d) ==\n' "$title" "${#items[@]}"
  local it
  for it in "${items[@]+"${items[@]}"}"; do
    printf '  %s\n' "$it"
  done
}

info "DOC_ROOT=$DOC_ROOT  KNOWLEDGE_TYPE=$KNOWLEDGE_TYPE  dry_run=$DRY_RUN apply_scaffold=$APPLY_SCAFFOLD"
print_bucket '忽略遗留槽位' "${IGNORED_SLOT_DIRS[@]+"${IGNORED_SLOT_DIRS[@]}"}"
print_bucket '跳过软链' "${SKIP_SYMLINK_LIST[@]+"${SKIP_SYMLINK_LIST[@]}"}"
print_bucket '新增骨架' "${ADD_LIST[@]+"${ADD_LIST[@]}"}"
print_bucket '跳过' "${SKIP_LIST[@]+"${SKIP_LIST[@]}"}"
print_bucket '结构重填' "${RESTRUCTURE_LIST[@]+"${RESTRUCTURE_LIST[@]}"}"
print_bucket '整文件覆盖' "${OVERWRITE_LIST[@]+"${OVERWRITE_LIST[@]}"}"
print_bucket '本库独有(保留)' "${LOCAL_ONLY_LIST[@]+"${LOCAL_ONLY_LIST[@]}"}"

if [[ "$APPLY_SCAFFOLD" != '1' ]]; then
  info "dry-run 完成；实跑骨架写入请用 --apply-scaffold（须 Skill 已取得 C；含根级 DESIGN 整文件覆盖）"
  exit 0
fi

ensure_backup_root

for rel in "${RESTRUCTURE_LIST[@]+"${RESTRUCTURE_LIST[@]}"}"; do
  backup_file_to_stamp "${DOC_ROOT%/}/$rel" "$rel"
done

for rel in "${ADD_LIST[@]+"${ADD_LIST[@]}"}" "${OVERWRITE_LIST[@]+"${OVERWRITE_LIST[@]}"}"; do
  if is_legacy_federal_slot_rel "$rel"; then
    warn "跳过遗留槽位骨架（不应出现在新增/覆盖桶）: $rel"
    continue
  fi
  if path_is_or_under_symlink "${DOC_ROOT%/}" "$rel"; then
    warn "跳过软链路径骨架: $rel"
    continue
  fi
  src=""
  if [[ "$rel" == 'README.md' && "$KNOWLEDGE_TYPE" == 'application' ]]; then
    src="$(meta_src_for_local_rel "$META_SRC" 'README.md' || true)"
  else
    src="$META_SRC/$rel"
  fi
  [[ -n "$src" && -f "$src" ]] || continue
  dst="${DOC_ROOT%/}/$rel"
  if [[ -e "$dst" ]]; then
    backup_file_to_stamp "$dst" "$rel"
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  if is_root_design_rel "$rel"; then
    info "整文件覆盖: $rel"
  else
    info "写入骨架: $rel"
  fi
done

info "骨架/整文件覆盖写入完成。结构重填与未落位请由 /docs-upgrade Skill 继续。"

# 与 docs-install knowledge 同契约：扫整棵 DOC_ROOT → ~/.agents/ + README 注记
# （空骨架桶亦跑；dry-run 已在上方退出，不会到达此处）
rewrite_docs_agent_paths "${DOC_ROOT}"
info "agent/ 路径重写完成（与 docs-install 同实现）。"
