#!/usr/bin/env bash
# push-specs.sh — 将 spec-{yyMMdd}-{n}-{app_name}.md 推送到 knowledge-links 登记路径下 {doc_dir}/specs/
# 子命令: copy | git（详见 agent/skills/docs-push/references/parameters.md）
set -euo pipefail

readonly _PS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# agent/skills/docs-push/scripts → 仓库根为 ../../../..
readonly _AIK_ROOT="$(cd "${_PS_SCRIPT_DIR}/../../../.." && pwd)"

# shellcheck source=../../../../scripts/lib/knowledge-links-read.sh
source "${_AIK_ROOT}/scripts/lib/knowledge-links-read.sh"

usage() {
  sed 's/^    //' <<'EOF'
    用法:
      push-specs.sh copy --specs-dir DIR --links FILE [--mode path|repo] [--branch NAME]
                         [--dry-run] [--strict] [--allow-dirty]
      push-specs.sh git  --specs-dir DIR --links FILE [--mode path|repo] [--branch NAME]
                         --git-op none|stage|commit|push [--message TEXT] [--remote NAME]
                         [--dry-run] [--strict] [--allow-dirty]

    必选:
      --specs-dir   源目录（内含 spec-*.md）
      --links       knowledge-links.yaml（相对仓库根或绝对路径）
    repo 模式:
      --mode repo   且 copy/git 均须在目标 path 上切换分支时提供 --branch
    git 子命令:
      --git-op      none | stage | commit | push
      commit/push  须配合 --message

    说明: --links 若为相对路径，则相对于中央知识库仓库根（本脚本所在 ai-knowledge 根: 见 _AIK_ROOT）。
EOF
}

sdx_warn() { printf '%s\n' "$*" >&2; }

CMD="${1:-}"
[[ "$CMD" == copy || "$CMD" == git ]] || {
  usage >&2
  exit 2
}
shift

SPECS_DIR=''
LINKS_FILE=''
MODE='path'
BRANCH=''
DRY_RUN=0
STRICT=0
ALLOW_DIRTY=0
GIT_OP=''
MESSAGE=''
REMOTE='origin'

while [[ $# -gt 0 ]]; do
  case "$1" in
    --specs-dir)
      SPECS_DIR="${2:?}"; shift 2 ;;
    --links)
      LINKS_FILE="${2:?}"; shift 2 ;;
    --mode)
      MODE="${2:?}"; shift 2 ;;
    --branch)
      BRANCH="${2:?}"; shift 2 ;;
    --dry-run)
      DRY_RUN=1; shift ;;
    --strict)
      STRICT=1; shift ;;
    --allow-dirty)
      ALLOW_DIRTY=1; shift ;;
    --git-op)
      GIT_OP="${2:?}"; shift 2 ;;
    --message)
      MESSAGE="${2:?}"; shift 2 ;;
    --remote)
      REMOTE="${2:?}"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      sdx_error "未知参数: $1" ;;
  esac
done

[[ -n "$SPECS_DIR" ]] || sdx_error "缺少 --specs-dir"
[[ -n "$LINKS_FILE" ]] || sdx_error "缺少 --links"
[[ -d "$SPECS_DIR" ]] || sdx_error "specs 目录不存在或不是目录: $SPECS_DIR"

if [[ "$LINKS_FILE" != /* ]]; then
  LINKS_FILE="${_AIK_ROOT}/${LINKS_FILE}"
fi
[[ -f "$LINKS_FILE" ]] || sdx_error "knowledge-links 文件不存在: $LINKS_FILE"

SPECS_DIR="$(cd "$SPECS_DIR" && pwd)"

[[ "$MODE" == path || "$MODE" == repo ]] || sdx_error "--mode 须为 path 或 repo: $MODE"
if [[ "$MODE" == repo ]]; then
  [[ -n "$BRANCH" ]] || sdx_error "repo 模式必须提供 --branch"
fi

if [[ "$CMD" == git ]]; then
  [[ -n "$GIT_OP" ]] || sdx_error "git 子命令必须提供 --git-op"
  [[ "$GIT_OP" == none || "$GIT_OP" == stage || "$GIT_OP" == commit || "$GIT_OP" == push ]] || \
    sdx_error "--git-op 须为 none|stage|commit|push: $GIT_OP"
  if [[ "$GIT_OP" == commit || "$GIT_OP" == push ]]; then
    [[ -n "$MESSAGE" ]] || sdx_error "git-op=$GIT_OP 时必须提供 --message"
  fi
fi

# shellcheck disable=SC2034
paths=() repos=() doc_dirs=() app_names=() app_labels=()
knowledge_links_load_into_arrays "$LINKS_FILE" paths repos doc_dirs app_names app_labels

find_link_index_for_app() {
  local want="${1:?}" i
  for ((i = 0; i < ${#app_names[@]}; i++)); do
    if [[ "${app_names[i]:-}" == "$want" ]]; then
      printf '%s' "$i"
      return 0
    fi
  done
  return 1
}

# 写入计划文件：每行 src_abs<TAB>dest_abs<TAB>repo_root_expanded
# 严格模式：任一条目解析失败则不写任何行并返回 1
write_validated_plan() {
  local out="${1:?}"
  local f base spec_re='^spec-([0-9]{6})-([0-9]+)-([a-zA-Z0-9_.-]+)\.md$'
  local idx doc_dir exp_root dest app
  local had_skip=0
  : >"$out"
  shopt -s nullglob
  for f in "$SPECS_DIR"/*.md; do
    base="$(basename "$f")"
    if [[ ! "$base" =~ $spec_re ]]; then
      sdx_warn "[skip] 文件名不符合 spec-{yyMMdd}-{n}-{app_name}.md: $base"
      had_skip=1
      continue
    fi
    app="${BASH_REMATCH[3]}"
    if ! idx="$(find_link_index_for_app "$app")"; then
      sdx_warn "[skip] 未在 knowledge-links 中找到 app_name=$app: $base"
      had_skip=1
      continue
    fi
    doc_dir="${doc_dirs[idx]:-application}"
    exp_root="$(knowledge_link_expand_stored_path "${paths[idx]}")"
    exp_root="$(cd "$exp_root" 2>/dev/null && pwd)" || sdx_error "无法进入 path 目录: ${paths[idx]} → $exp_root"
    dest="${exp_root}/${doc_dir}/specs/${base}"
    printf '%s\t%s\t%s\n' "$f" "$dest" "$exp_root" >>"$out"
  done
  shopt -u nullglob
  if [[ "$STRICT" -eq 1 && "$had_skip" -ne 0 ]]; then
    : >"$out"
    return 1
  fi
  return 0
}

# 检查工作区：除 planned_rel 中路径外不得有其它变更
check_worktree_clean_for_plan() {
  local root="${1:?}"
  shift
  local -a planned=("$@")
  local line xy p path rest
  [[ "$ALLOW_DIRTY" -eq 1 ]] && return 0
  git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "${line//[[:space:]]/}" ]] && continue
    xy="${line:0:2}"
    rest="${line:3}"
    local -a candidates=()
    if [[ "$rest" == *" -> "* ]]; then
      candidates+=("${rest%% -> *}")
      candidates+=("${rest##* -> }")
    else
      candidates+=("$rest")
    fi
    local p ok q
    for p in "${candidates[@]}"; do
      [[ -z "$p" ]] && continue
      ok=0
      for q in "${planned[@]}"; do
        if [[ "$p" == "$q" ]]; then
          ok=1
          break
        fi
      done
      if [[ "$ok" -eq 0 ]]; then
        sdx_error "Git 工作区存在与本次推送无关的变更（path=$root 文件: $p）。请先提交或清理，或使用 --allow-dirty。"
      fi
    done
  done < <(git -C "$root" status --porcelain)
}

rel_under_root() {
  local dest="${1:?}" root="${2:?}"
  if [[ "$dest" != "$root"/* ]]; then
    sdx_error "目标路径不在仓库根下: dest=$dest root=$root"
  fi
  printf '%s' "${dest#"${root}"/}"
}

run_copy() {
  local plan_line src dest root
  local -a roots_order=()
  local -A root_done=()

  local plan_file
  plan_file="$(mktemp)"
  if ! write_validated_plan "$plan_file"; then
    rm -f "$plan_file"
    sdx_error "strict 模式：存在无法路由的 spec，已中止（未写任何目标文件）"
  fi
  if [[ ! -s "$plan_file" ]]; then
    rm -f "$plan_file"
    sdx_error "没有可复制的 spec 文件（检查命名与 app_name 登记）"
  fi

  # repo 模式：按 root 分组，首次遇到 root 时 dirty + checkout
  while IFS= read -r plan_line || [[ -n "$plan_line" ]]; do
    [[ -z "$plan_line" ]] && continue
    IFS=$'\t' read -r src dest root <<<"$plan_line"

    if [[ "$MODE" == repo ]]; then
      if [[ -z "${root_done[$root]:-}" ]]; then
        root_done["$root"]=1
        roots_order+=("$root")
      fi
    fi
  done <"$plan_file"

  if [[ "$MODE" == repo ]]; then
    local r
    for r in "${roots_order[@]}"; do
      local -a planned_for_r=()
      while IFS= read -r plan_line || [[ -n "$plan_line" ]]; do
        [[ -z "$plan_line" ]] && continue
        IFS=$'\t' read -r src dest root <<<"$plan_line"
        [[ "$root" != "$r" ]] && continue
        planned_for_r+=("$(rel_under_root "$dest" "$root")")
      done <"$plan_file"
      if [[ "$DRY_RUN" -eq 1 ]]; then
        printf '[dry-run] git -C %q checkout -B %q\n' "$r" "$BRANCH" >&2
      else
        check_worktree_clean_for_plan "$r" "${planned_for_r[@]}"
        git -C "$r" rev-parse --is-inside-work-tree >/dev/null 2>&1 || \
          sdx_error "repo 模式要求 path 为 Git 工作区: $r"
        git -C "$r" checkout -B "$BRANCH"
      fi
    done
  fi

  while IFS= read -r plan_line || [[ -n "$plan_line" ]]; do
    [[ -z "$plan_line" ]] && continue
    IFS=$'\t' read -r src dest root <<<"$plan_line"
    if [[ "$DRY_RUN" -eq 1 ]]; then
      printf '[dry-run] install %q %q\n' "$src" "$dest" >&2
      continue
    fi
    mkdir -p "$(dirname "$dest")"
    install -m 0644 "$src" "$dest"
    printf '已复制: %s -> %s\n' "$src" "$dest"
  done <"$plan_file"

  rm -f "$plan_file"
}

# 按仓库根聚合 rel 路径，对每个根执行一次 add / commit / push
run_git() {
  local plan_file plan_line src dest root r
  local -A root_done=()
  local -a roots_order=()

  plan_file="$(mktemp)"
  if ! write_validated_plan "$plan_file"; then
    rm -f "$plan_file"
    sdx_error "strict 模式：存在无法路由的 spec，已中止"
  fi
  [[ -s "$plan_file" ]] || {
    rm -f "$plan_file"
    sdx_error "没有可处理的 spec 文件"
  }

  while IFS= read -r plan_line || [[ -n "$plan_line" ]]; do
    [[ -z "$plan_line" ]] && continue
    IFS=$'\t' read -r src dest root <<<"$plan_line"
    if [[ "$MODE" == repo ]]; then
      if [[ -z "${root_done[$root]:-}" ]]; then
        root_done["$root"]=1
        roots_order+=("$root")
      fi
    fi
  done <"$plan_file"

  if [[ "$MODE" == repo ]]; then
    for r in "${roots_order[@]}"; do
      local -a planned_for_r=()
      while IFS= read -r plan_line || [[ -n "$plan_line" ]]; do
        [[ -z "$plan_line" ]] && continue
        IFS=$'\t' read -r src dest root <<<"$plan_line"
        [[ "$root" != "$r" ]] && continue
        planned_for_r+=("$(rel_under_root "$dest" "$r")")
      done <"$plan_file"
      if [[ "$DRY_RUN" -eq 1 ]]; then
        printf '[dry-run] git -C %q checkout -B %q\n' "$r" "$BRANCH" >&2
      else
        check_worktree_clean_for_plan "$r" "${planned_for_r[@]}"
        git -C "$r" rev-parse --is-inside-work-tree >/dev/null 2>&1 || \
          sdx_error "repo 模式要求 path 为 Git 工作区: $r"
        git -C "$r" checkout -B "$BRANCH"
      fi
    done
  fi

  # 聚合: root -> rel 列表
  local -a uniq_roots=()
  while IFS= read -r plan_line || [[ -n "$plan_line" ]]; do
    [[ -z "$plan_line" ]] && continue
    IFS=$'\t' read -r src dest root <<<"$plan_line"
    if ! git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      sdx_warn "[skip] 非 Git 目录，跳过 git 操作: $root"
      continue
    fi
    local found=0 u
    for u in "${uniq_roots[@]}"; do
      if [[ "$u" == "$root" ]]; then found=1; break; fi
    done
    [[ "$found" -eq 0 ]] && uniq_roots+=("$root")
  done <"$plan_file"

  for root in "${uniq_roots[@]}"; do
    local -a rels=()
    while IFS= read -r plan_line || [[ -n "$plan_line" ]]; do
      [[ -z "$plan_line" ]] && continue
      IFS=$'\t' read -r src dest r <<<"$plan_line"
      [[ "$r" != "$root" ]] && continue
      rels+=("$(rel_under_root "$dest" "$root")")
    done <"$plan_file"

    case "$GIT_OP" in
      none)
        if [[ "$DRY_RUN" -eq 1 ]]; then
          printf '[dry-run] git -C %q status -sb\n' "$root" >&2
        else
          git -C "$root" status -sb || true
        fi
        ;;
      stage)
        if [[ "$DRY_RUN" -eq 1 ]]; then
          printf '[dry-run] git -C %q add --' "$root" >&2
          printf ' %q' "${rels[@]}" >&2
          printf '\n' >&2
        else
          [[ "${#rels[@]}" -gt 0 ]] && git -C "$root" add -- "${rels[@]}"
        fi
        ;;
      commit)
        if [[ "$DRY_RUN" -eq 1 ]]; then
          printf '[dry-run] git -C %q add --' "$root" >&2
          printf ' %q' "${rels[@]}" >&2
          printf ' && git -C %q commit -m %q\n' "$root" "$MESSAGE" >&2
        else
          [[ "${#rels[@]}" -gt 0 ]] && git -C "$root" add -- "${rels[@]}"
          if git -C "$root" diff-index --cached --quiet HEAD -- 2>/dev/null; then
            sdx_warn "无暂存变更，跳过 commit: $root"
          else
            git -C "$root" commit -m "$MESSAGE"
          fi
        fi
        ;;
      push)
        if [[ "$DRY_RUN" -eq 1 ]]; then
          printf '[dry-run] git -C %q add --' "$root" >&2
          printf ' %q' "${rels[@]}" >&2
          printf ' && git -C %q commit -m %q && git -C %q push %q HEAD\n' \
            "$root" "$MESSAGE" "$root" "$REMOTE" >&2
        else
          [[ "${#rels[@]}" -gt 0 ]] && git -C "$root" add -- "${rels[@]}"
          if git -C "$root" diff-index --cached --quiet HEAD -- 2>/dev/null; then
            sdx_warn "无暂存变更，跳过 commit/push: $root"
          else
            git -C "$root" commit -m "$MESSAGE"
            git -C "$root" push "$REMOTE" HEAD
          fi
        fi
        ;;
    esac
  done

  rm -f "$plan_file"
}

case "$CMD" in
  copy) run_copy ;;
  git) run_git ;;
esac
