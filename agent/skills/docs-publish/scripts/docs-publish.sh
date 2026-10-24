#!/usr/bin/env bash
set -euo pipefail

[[ "${BASH_VERSINFO[0]:-0}" -ge 5 ]] || {
  echo 'docs-publish requires Bash 5+' >&2
  exit 1
}

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo 'must run inside git repo' >&2
  exit 1
}
cd "$ROOT"
source "$ROOT/agent/scripts/lib/version.sh"

MODE='default'
EXPECTED_PLAN=''
shopt -s inherit_errexit
usage() {
  cat <<'EOF'
用法: bash agent/skills/docs-publish/scripts/docs-publish.sh [--dry-run|--publish --expect-plan ID]

默认仅预览版本与允许发布文件；执行提交、推送、合并和创建下一分支必须显式传 --publish。
  --dry-run  仅展示版本计算与发布清单，不修改工作区或 Git 状态
  --publish  执行完整发布流程：更新版本、rebase、commit、推送、快进合并 main、创建下一 feature 分支
  --expect-plan ID  正式执行必须匹配已确认预览的 plan-id；标识不代替用户授权
  -h, --help 显示帮助
EOF
}

while (($#)); do
  case "$1" in
    --dry-run)
      [[ "$MODE" == 'default' ]] || { echo '--dry-run 与 --publish 互斥' >&2; exit 1; }
      MODE='dry-run'
      shift
      ;;
    --publish)
      [[ "$MODE" == 'default' ]] || { echo '--dry-run 与 --publish 互斥' >&2; exit 1; }
      MODE='publish'
      shift
      ;;
    --expect-plan)
      [[ -z "$EXPECTED_PLAN" && "${2:-}" =~ ^[a-f0-9]{64}$ ]] || { echo 'invalid or duplicate expected plan' >&2; exit 1; }
      EXPECTED_PLAN="$2"; shift 2 ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

remote_head="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)"
MAIN="${remote_head#origin/}"
MAIN="${MAIN:-main}"
branch="$(git branch --show-current)"
[[ -n "$branch" ]] || { echo 'detached HEAD is not supported' >&2; exit 1; }
[[ "$branch" != "$MAIN" ]] || { echo "cannot publish from main; checkout a feature branch first" >&2; exit 1; }

files=(application/DESIGN.md system/DESIGN.md solution/DESIGN.md company/DESIGN.md)
todo_files=(TODO-LIST.md application/TODO-LIST.md system/TODO-LIST.md solution/TODO-LIST.md company/TODO-LIST.md)
allowed=("${files[@]}" "${todo_files[@]}")

is_allowed_file() {
  local candidate="$1" allowed_file
  for allowed_file in "${allowed[@]}"; do
    [[ "$candidate" == "$allowed_file" ]] && return 0
  done
  return 1
}

check_worktree_scope() {
  local changed
  {
    git diff --cached --name-only -z -- || exit $?
    git diff --name-only -z -- || exit $?
    git ls-files --others --exclude-standard -z
  } | while IFS= read -r -d '' changed; do
    [[ -z "$changed" ]] && continue
    is_allowed_file "$changed" || {
      echo "unrelated working-tree change: $changed" >&2
      return 1
    }
  done
}

check_branch_scope() {
  local changed
  git diff --name-only -z "origin/$MAIN...HEAD" | while IFS= read -r -d '' changed; do
    [[ -z "$changed" ]] && continue
    is_allowed_file "$changed" || {
      echo "unrelated feature-branch commit: $changed" >&2
      return 1
    }
  done
}

todo_publish_files=()
collect_todo_files() {
  local changed todo_file
  local -A seen=()
  while IFS= read -r -d '' changed; do
    for todo_file in "${todo_files[@]}"; do
      if [[ "$changed" == "$todo_file" ]]; then
        if [[ -z "${seen[$todo_file]:-}" ]]; then
          todo_publish_files+=("$todo_file"); seen[$todo_file]=1
        fi
        break
      fi
    done
  done < <(
    git diff --cached --name-only -z --
    git diff --name-only -z --
    git ls-files --others --exclude-standard -z
  )
}

stage_todo_files() {
  local todo_file
  for todo_file in "${todo_publish_files[@]}"; do
    if [[ -f "$todo_file" ]] || git ls-files --error-unmatch -- "$todo_file" >/dev/null 2>&1; then
      git add -A -- "$todo_file"
    fi
  done
}

for file in "${files[@]}"; do
  [[ -f "$file" ]] || { echo "missing required file: $file" >&2; exit 1; }
  grep -q '^version:[[:space:]]*' "$file" || { echo "missing version field: $file" >&2; exit 1; }
done
check_worktree_scope || exit 1
collect_todo_files


version="$(version_next_from_files "${files[@]}")" || {
  echo 'DESIGN versions are missing, invalid, or inconsistent' >&2
  exit 1
}
old="$(sed -n 's/^version:[[:space:]]*\([^[:space:]]*\).*/\1/p' "${files[0]}" | head -1)"
next_patch=$((10#${version##*.} + 1))
next="feature-${version%.*}.${next_patch}"

# 预览和实跑采用同一发布前置；Git 读取失败不能当作空计划。
git remote get-url origin >/dev/null
remote_before="$(git rev-parse --verify "refs/remotes/origin/$MAIN")"
git show-ref --verify --quiet "refs/heads/$MAIN" || { echo 'local main branch not found' >&2; exit 1; }
check_branch_scope || exit 1
if git show-ref --verify --quiet "refs/heads/$next" || git show-ref --verify --quiet "refs/remotes/origin/$next"; then
  echo "next feature branch already exists: $next" >&2; exit 1
fi

plan_fingerprint() {
  {
    printf 'docs-publish-plan-v1\0%s\0%s\0%s\0%s\0' "$branch" "$MAIN" "$version" "$next"
    git rev-parse HEAD "refs/heads/$MAIN" "refs/remotes/origin/$MAIN"
    git remote get-url --all origin
    git remote get-url --push --all origin
    printf 'staged\n'
    git diff --binary --no-ext-diff --no-textconv --cached -- | git hash-object --stdin
    printf 'unstaged\n'
    git diff --binary --no-ext-diff --no-textconv -- | git hash-object --stdin
    local item
    for item in "${files[@]}" "${todo_publish_files[@]}"; do
      printf '\0%s\0' "$item"
      if [[ -f "$item" ]]; then git hash-object -- "$item"; else printf 'deleted\n'; fi
    done
  } | shasum -a 256 | awk '{print $1}'
}
plan_id="$(plan_fingerprint)"

if [[ "$MODE" != 'publish' ]]; then
  printf 'plan-id: %s\n' "$plan_id"
  printf 'HEAD: %s; remote: %s\n' "$(git rev-parse HEAD)" "$remote_before"
  printf 'docs-publish: %s -> %s\n' "${old:-none}" "$version"
  printf 'branch: %s\n' "$branch"
  printf 'base: origin/%s\n' "$MAIN"
  printf 'would update:\n'
  printf '  %s\n' "${files[@]}"
  for todo_file in "${todo_publish_files[@]}"; do
    printf '  %s\n' "$todo_file"
  done
  printf 'git plan: rebase origin/%s, commit, push %s, fast-forward merge %s, push %s, create %s\n' \
    "$MAIN" "$branch" "$MAIN" "$MAIN" "$next"
  exit 0
fi

[[ -n "$EXPECTED_PLAN" && "$EXPECTED_PLAN" == "$plan_id" ]] || { echo 'plan mismatch or missing --expect-plan; rerun preview and confirm' >&2; exit 1; }
git fetch origin "$MAIN"
plan_after_fetch="$(plan_fingerprint)"
[[ "$plan_after_fetch" == "$EXPECTED_PLAN" ]] || { echo 'plan changed after fetch; rerun preview and confirm' >&2; exit 1; }
git rebase --autostash "origin/$MAIN"
unmerged="$(git ls-files --unmerged)"
[[ -z "$unmerged" ]] || { echo 'unmerged files after rebase/autostash; preserve conflicts and stop' >&2; exit 1; }
check_branch_scope || exit 1
check_worktree_scope || exit 1
version_after_rebase="$(version_next_from_files "${files[@]}")"
[[ "$version_after_rebase" == "$version" ]] || { echo 'version changed during rebase; stop and preview again' >&2; exit 1; }

for file in "${files[@]}"; do
  sed -i.bak -E "s/^version:[[:space:]]*.*/version: $version/" "$file"
  rm -f "$file.bak"
done
for file in "${files[@]}"; do git add "$file"; done
stage_todo_files
git diff --cached --quiet && { echo 'no publish changes' >&2; exit 1; }

# 最终暂存区再次独立核对，不能因此前工作树检查通过而信任 index。
index_files="$(git diff --cached --name-only)"
while IFS= read -r file; do
  [[ -z "$file" ]] || is_allowed_file "$file" || { echo "unrelated staged file: $file" >&2; exit 1; }
done <<< "$index_files"
published_files="$index_files"
[[ -n "$published_files" ]] || { echo 'no publish files staged' >&2; exit 1; }
commit_body="Previous version: ${old:-none}
New version: $version
Published files:
$published_files"
git commit -m "docs-publish: version $version" -m "$commit_body"
git push -u origin "$branch"
git fetch origin "$MAIN"
git checkout "$MAIN"
git pull --ff-only origin "$MAIN"
git merge --ff-only "$branch"
git push origin "$MAIN"
git checkout -b "$next"
printf 'Published %s; switched to %s\n' "$version" "$next"
