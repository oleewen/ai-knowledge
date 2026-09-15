#!/usr/bin/env bash
#
# lib/git-remote.sh — 解析 Git remote URL（供 knowledge-links / federation 共用）
# 依赖：无（仅读 .git/config）
#

if [[ -n "${_LIB_GIT_REMOTE_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
_LIB_GIT_REMOTE_LOADED=1

# 打印 origin 或第一个可用的 remote URL；若无则返回 1 且无输出
# 优先 git CLI；失败则手写解析 .git/config（worktree / 无 PATH 中 git 时兜底）
git_remote_url_prefer_origin() {
  local top="${1:?}" git_dir cfg url

  if command -v git >/dev/null 2>&1; then
    url="$(git -C "$top" remote get-url origin 2>/dev/null || true)"
    if [[ -n "$url" ]]; then
      printf '%s\n' "$url"
      return 0
    fi
  fi

  git_dir=''
  if [[ -d "$top/.git" ]]; then
    git_dir="$top/.git"
  elif [[ -f "$top/.git" ]]; then
    git_dir="$(sed -n 's/^gitdir: //p' "$top/.git" | head -n 1)"
    [[ -n "$git_dir" ]] || return 1
    [[ "$git_dir" == /* ]] || git_dir="$top/$git_dir"
  else
    return 1
  fi
  cfg="$git_dir/config"
  [[ -f "$cfg" ]] || return 1
  url="$(
    awk '
      BEGIN { in_remote=0; remote=""; first_url=""; }
      /^\[remote "[^"]+"\]$/ {
        in_remote=1;
        remote=$0;
        sub(/^\[remote "/, "", remote);
        sub(/"\]$/, "", remote);
        next;
      }
      /^\[.*\]$/ { in_remote=0; remote=""; next; }
      in_remote && /^[[:space:]]*url[[:space:]]*=[[:space:]]*/ {
        u=$0;
        sub(/^[[:space:]]*url[[:space:]]*=[[:space:]]*/, "", u);
        if (remote == "origin") { print u; exit 0; }
        if (first_url == "") { first_url=u; }
      }
      END { if (first_url != "") print first_url; }
    ' "$cfg"
  )"
  [[ -n "$url" ]] || return 1
  printf '%s\n' "$url"
}

# 兼容旧名（knowledge-links / docs-link / docs-install）
knowledge_link_git_remote_url_prefer_origin() {
  git_remote_url_prefer_origin "$@"
}
