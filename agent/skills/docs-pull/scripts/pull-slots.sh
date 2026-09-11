#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../../agent/scripts/config-bootstrap.sh"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/../../../../agent/scripts/federation-slot-symlink.sh"

APP=""
SYS_NAME=""
ALL=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app)
      shift
      [[ -n "${1:-}" ]] || { printf '缺少 --app 值\n' >&2; exit 2; }
      APP="$1"
      shift
      ;;
    --sys-name)
      shift
      [[ -n "${1:-}" ]] || { printf '缺少 --sys-name 值\n' >&2; exit 2; }
      SYS_NAME="$1"
      shift
      ;;
    --all)
      ALL=1
      shift
      ;;
    -h|--help)
      printf '%s\n' "Usage: $0 [--app <app_name> | --sys-name <sys_name> | --all]"
      exit 0
      ;;
    *)
      printf '未知参数: %s\n' "$1" >&2
      exit 2
      ;;
  esac
done

validate_bootstrap_docsconfig

MODE="${KNOWLEDGE_TYPE:-}"
[[ "$MODE" == "system" || "$MODE" == "company" ]] || { printf '不支持的 KNOWLEDGE_TYPE: %s\n' "$MODE" >&2; exit 1; }

LINKS_FILE="${DOC_ROOT%/}/knowledge-links.yaml"
[[ -f "$LINKS_FILE" ]] || { printf '缺少 knowledge-links.yaml: %s\n' "$LINKS_FILE" >&2; exit 1; }

declare -a paths=() repos=() doc_dirs=() names=() labels=() types=()
knowledge_links_load_into_arrays "$LINKS_FILE" paths repos doc_dirs names labels types

expected_target_type=""
slot_prefix=""
name_flag=""
name_value=""
slot_parent=""

if [[ "$MODE" == "system" ]]; then
  expected_target_type="application"
  slot_prefix="application"
  slot_parent="application-slots"
  name_flag="--app"
  name_value="$APP"
else
  expected_target_type="system"
  slot_prefix="system"
  slot_parent="system-slots"
  name_flag="--sys-name"
  name_value="$SYS_NAME"
fi

if [[ "$ALL" -eq 0 ]]; then
  [[ -n "$name_value" ]] || { printf '缺少 %s 值\n' "$name_flag" >&2; exit 2; }
fi

select_indices() {
  local -n _out="${1:?}"
  local i
  _out=()
  if [[ "$ALL" -eq 1 ]]; then
    for i in "${!paths[@]}"; do
      [[ "${types[i]:-child}" == "parent" || "${types[i]:-child}" == "meta" ]] && continue
      _out+=("$i")
    done
    return 0
  fi
  for i in "${!paths[@]}"; do
    [[ "${types[i]:-child}" == "parent" || "${types[i]:-child}" == "meta" ]] && continue
    [[ "${names[i]:-}" == "$name_value" ]] || continue
    _out+=("$i")
    return 0
  done
  return 1
}

validate_link_fields() {
  local idx="${1:?}"
  [[ -n "${repos[idx]:-}" ]] || { printf 'link 缺少 repository（必填）: idx=%s\n' "$idx" >&2; return 1; }
  [[ -n "${paths[idx]:-}" ]] || { printf 'link 缺少 path（必填）: idx=%s\n' "$idx" >&2; return 1; }
  [[ -n "${doc_dirs[idx]:-}" ]] || { printf 'link 缺少 doc_dir（必填，=目标 DOC_DIR）: idx=%s\n' "$idx" >&2; return 1; }
  [[ -n "${names[idx]:-}" ]] || { printf 'link 缺少 name（必填）: idx=%s\n' "$idx" >&2; return 1; }
  [[ -n "${labels[idx]:-}" ]] || { printf 'link 缺少 label（必填）: idx=%s\n' "$idx" >&2; return 1; }
  return 0
}

join_actions() {
  local out="" part
  for part in "$@"; do
    [[ -n "$part" ]] || continue
    if [[ -z "$out" ]]; then
      out="$part"
    else
      out="${out}+${part}"
    fi
  done
  printf '%s' "$out"
}

ensure_child_repo() {
  # stdout: action fragment (clone|pull|空); 失败 return 1
  local path_expanded="${1:?}" repo="${2:?}"
  local origin expect actual parent_dir
  local -a acts=()

  if [[ ! -e "$path_expanded" ]]; then
    parent_dir="$(dirname "$path_expanded")"
    mkdir -p "$parent_dir"
    if ! git clone --quiet "$repo" "$path_expanded" >/dev/null; then
      printf 'git clone 失败: %s → %s\n' "$repo" "$path_expanded" >&2
      return 1
    fi
    acts+=("clone")
    printf '%s' "$(join_actions "${acts[@]}")"
    return 0
  fi

  [[ -d "$path_expanded/.git" || -f "$path_expanded/.git" ]] \
    || { printf 'path 不是 Git 工作区: %s\n' "$path_expanded" >&2; return 1; }

  origin="$(federation_git_origin_url "$path_expanded")"
  [[ -n "$origin" ]] || { printf 'path 缺少 origin remote: %s\n' "$path_expanded" >&2; return 1; }
  expect="$(federation_normalize_git_url "$repo")"
  actual="$(federation_normalize_git_url "$origin")"
  [[ "$expect" == "$actual" ]] \
    || { printf 'origin 与 knowledge-links.repository 不匹配: origin=%s repository=%s\n' "$origin" "$repo" >&2; return 1; }

  if federation_git_is_dirty "$path_expanded"; then
    printf '工作区有未提交改动，拒绝 git pull: %s\n' "$path_expanded" >&2
    return 1
  fi

  local branch
  branch="$(git -C "$path_expanded" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  [[ -n "$branch" && "$branch" != "HEAD" ]] || branch="master"
  if ! git -C "$path_expanded" pull --ff-only origin "$branch" >/dev/null; then
    # 远端默认分支名可能不同：探测 origin/HEAD
    if git -C "$path_expanded" remote set-head origin -a >/dev/null 2>&1; then
      branch="$(git -C "$path_expanded" symbolic-ref -q refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || true)"
    fi
    [[ -n "$branch" ]] || { printf 'git pull 失败（无法解析远端分支）: %s\n' "$path_expanded" >&2; return 1; }
    if ! git -C "$path_expanded" pull --ff-only origin "$branch" >/dev/null; then
      printf 'git pull 失败: %s\n' "$path_expanded" >&2
      return 1
    fi
  fi
  acts+=("pull")
  printf '%s' "$(join_actions "${acts[@]}")"
  return 0
}

pull_one() {
  local idx="${1:?}"
  validate_link_fields "$idx" || return 1

  local repo path_expanded name label
  local source_dir slot_dir slots_dir shared_log_dir shared_change_log
  local commit action git_action link_action slot_key
  local target_cfg t_doc_root='' t_repo_root='' t_doc_dir='' t_agent_root='' t_agent_dirs='' t_ktype=''
  local saved_pwd

  repo="${repos[idx]}"
  path_expanded="$(knowledge_link_expand_stored_path "${paths[idx]}")"
  name="${names[idx]}"
  label="${labels[idx]}"

  slots_dir="${DOC_ROOT%/}/${slot_parent}"
  slot_dir="${slots_dir}/${slot_prefix}-${name}"
  shared_log_dir="${slots_dir}/changelogs"
  shared_change_log="${shared_log_dir}/CHANGE-LOG.md"
  federation_ensure_shared_changelogs "$slots_dir"

  git_action="$(ensure_child_repo "$path_expanded" "$repo")" || return 1

  target_cfg="${path_expanded%/}/.docsconfig"
  [[ -f "$target_cfg" ]] || { printf '目标仓库缺少 .docsconfig: %s\n' "$target_cfg" >&2; return 1; }

  saved_pwd="$PWD"
  cd "$path_expanded"
  docsconfig_read_into "$target_cfg" t_doc_root t_repo_root t_doc_dir t_agent_root t_agent_dirs t_ktype \
    || { cd "$saved_pwd"; printf '无法解析目标 .docsconfig: %s\n' "$target_cfg" >&2; return 1; }
  cd "$saved_pwd"
  [[ -n "$t_doc_root" && -n "$t_doc_dir" && -n "$t_ktype" ]] \
    || { printf '目标 .docsconfig 缺少 DOC_ROOT/DOC_DIR/KNOWLEDGE_TYPE: %s\n' "$target_cfg" >&2; return 1; }

  if [[ "$expected_target_type" == "application" ]]; then
    [[ "$t_ktype" == "application" ]] || { printf '目标 KNOWLEDGE_TYPE 不匹配（应为 application）: %s\n' "$t_ktype" >&2; return 1; }
  else
    [[ "$t_ktype" == "system" ]] || { printf '目标 KNOWLEDGE_TYPE 不匹配（应为 system）: %s\n' "$t_ktype" >&2; return 1; }
  fi

  source_dir="$(federation_resolve_doc_root "$path_expanded" "${doc_dirs[idx]}")" \
    || { printf '无法解析下级 DOC_ROOT: path=%s doc_dir=%s\n' "$path_expanded" "${doc_dirs[idx]}" >&2; return 1; }
  [[ -d "$source_dir" ]] || { printf '源目录不存在: %s\n' "$source_dir" >&2; return 1; }

  link_action="$(federation_ensure_slot_symlink "$slot_dir" "$source_dir" "$shared_log_dir" "$name")"
  action="$(join_actions "$git_action" "$link_action")"
  [[ -n "$action" ]] || action="pull"

  commit="$(git -C "$path_expanded" rev-parse --short HEAD 2>/dev/null || printf 'unknown')"
  slot_key="$([[ "$expected_target_type" == "application" ]] && printf 'app_name' || printf 'sys_name')"
  federation_append_pull_change_log "$shared_change_log" "$slot_key" "$name" "$repo" "$commit" "$action" || return 1

  printf 'SYNC_OK: %s (%s) action=%s\n' "$name" "$label" "$action"
  return 0
}

declare -a indices=()
if ! select_indices indices; then
  printf '未找到匹配的 link（target=%s, %s=%s）\n' "$expected_target_type" "$name_flag" "$name_value" >&2
  exit 1
fi

failures=()
for idx in "${indices[@]}"; do
  if ! pull_one "$idx"; then
    failures+=("$idx")
  fi
done

if [[ "${#failures[@]}" -gt 0 ]]; then
  printf 'FAILED: %s\n' "${failures[*]}" >&2
  exit 1
fi
