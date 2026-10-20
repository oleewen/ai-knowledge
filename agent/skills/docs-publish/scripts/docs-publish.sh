#!/usr/bin/env bash
set -euo pipefail
[[ "${BASH_VERSINFO[0]:-0}" -ge 5 ]] || { echo 'docs-publish requires Bash 5+' >&2; exit 1; }
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo 'must run inside git repo' >&2; exit 1; }
source "$ROOT/agent/scripts/lib/version.sh"
DRY_RUN=0
while (($#)); do case "$1" in --dry-run) DRY_RUN=1; shift;; -h|--help) sed -n '1,80p' "$0"; exit 0;; *) echo "unknown option: $1" >&2; exit 1;; esac; done
MAIN="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##' || true)"; MAIN="${MAIN:-main}"
branch="$(git branch --show-current)"; [[ -n "$branch" ]] || { echo 'detached HEAD is not supported' >&2; exit 1; }
files=(application/DESIGN.md system/DESIGN.md solution/DESIGN.md company/DESIGN.md)
allowed=("${files[@]}" TODO-LIST.md)
for changed in $(git status --porcelain=v1 | sed -E 's/^.. //'); do
  ok=0; for file in "${allowed[@]}"; do [[ "$changed" == "$file" ]] && ok=1; done
  ((ok)) || { echo "unrelated working-tree change: $changed" >&2; exit 1; }
done
version="$(version_next_from_files "${files[@]}")" || { echo 'DESIGN versions are missing, invalid, or inconsistent' >&2; exit 1; }
old="$(sed -n 's/^version:[[:space:]]*\([^[:space:]]*\).*/\1/p' "${files[0]}" | head -1)"
if ((DRY_RUN)); then
  echo "docs-publish: ${old:-none} -> $version"
  printf 'would update: %s\n' "${files[@]}"
  exit 0
fi
for file in "${files[@]}"; do sed -i.bak -E "s/^version:[[:space:]]*.*/version: $version/" "$file"; rm -f "$file.bak"; done
for file in "${files[@]}"; do git add "$file"; done
[[ -f TODO-LIST.md ]] && git add TODO-LIST.md
git diff --cached --quiet && { echo 'no publish changes'; exit 1; }
git fetch origin "$MAIN"
git rebase --autostash "origin/$MAIN"
for file in "${files[@]}"; do git add "$file"; done
[[ -f TODO-LIST.md ]] && git add TODO-LIST.md
git commit -m "docs-publish: version $version" -m "Previous version: ${old:-none}\nPublished files: ${files[*]}"
git push -u origin "$branch"
git fetch origin "$MAIN"
git checkout "$MAIN"
git pull --ff-only origin "$MAIN"
git merge --ff-only "$branch"
git push origin "$MAIN"
next="feature-$version"
git checkout -b "$next"
echo "Published $version; switched to $next"
