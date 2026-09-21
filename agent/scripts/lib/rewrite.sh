#!/usr/bin/env bash
#
# lib/rewrite.sh — 知识库树内 agent/IDE 路径重写与 README 注记
# 依赖：lib/log-io.sh（info / have_*）
#

_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=log-io.sh
source "${_LIB_DIR}/log-io.sh"

if [[ -n "${_LIB_REWRITE_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
_LIB_REWRITE_LOADED=1

is_text_file() {
  local f="$1"
  case "$f" in
    *.md|*.yaml|*.yml|*.json|*.jsonl|*.txt|*.sh|*.gitignore|*.html|*.css|*.js|*.toml)
      return 0 ;;
  esac
  if have_cmd file; then
    local mt
    mt="$(file -b --mime-type "$f" 2>/dev/null || true)"
    [[ "$mt" == text/* || "$mt" == application/json || "$mt" == *yaml* || "$mt" == *json* ]] && return 0
  fi
  return 1
}

# 知识库路径重写目标（与 agent-install 实体树一致；字面 tilde，不展开 $HOME）
DOCS_AGENT_REWRITE_TARGET='~/.agents/'
# 与 agent-install AGENT_DIR_MAP 对齐的 IDE 段
DOCS_AGENT_IDE_DIR_RE='cursor|trae|claude|kiro|codex'

rewrite_agent_path_segment_in_file() {
  local file="$1"
  local target="${DOCS_AGENT_REWRITE_TARGET}"
  [[ -f "$file" ]] && is_text_file "$file" || return 0
  grep -qE "agent/|\\.(${DOCS_AGENT_IDE_DIR_RE})/" "$file" 2>/dev/null || return 0
  have_cmd perl || return 0
  if ! AGENT_SLASH="$target" IDE_DIR_RE="$DOCS_AGENT_IDE_DIR_RE" \
    perl -CSD -i -pe '
      BEGIN {
        die "AGENT_SLASH unset\n" unless defined $ENV{AGENT_SLASH} && length $ENV{AGENT_SLASH};
        die "IDE_DIR_RE unset\n" unless defined $ENV{IDE_DIR_RE} && length $ENV{IDE_DIR_RE};
        our $ide = $ENV{IDE_DIR_RE};
        our $upagent = qr/(?:\.\.\/)+agent\//;
      }
      s{\.(?:$ide)/}{$ENV{AGENT_SLASH}}g;
      s{$upagent}{$ENV{AGENT_SLASH}}g;
      s{\bagent/}{$ENV{AGENT_SLASH}}g;
    ' "$file" 2>/dev/null; then
    warn "重写 agent/ 路径失败：$file"
  fi
}

# 遍历 root 下待重写路径的文件：排除常见依赖/缓存/版本库目录，避免 ~/.cursor/skills 等目录残留导致 find 极慢或“假死”
rewrite_agent_path_segment_in_tree() {
  local root="$1"
  [[ -d "$root" ]] || return 0
  info "  重写 agent/ 与 IDE Agent 路径引用 → ${DOCS_AGENT_REWRITE_TARGET}（跳过 node_modules/.git 等）: ${root}"
  local f
  while IFS= read -r -d '' f; do
    rewrite_agent_path_segment_in_file "$f"
  done < <(
    find "$root" \
      \( -name node_modules -o -name .git -o -name __pycache__ -o -name .venv -o -name .cache -o -name dist -o -name build -o -name target \) \
      -prune -o -type f \( \
        -name '*.md' -o -name '*.yaml' -o -name '*.yml' -o -name '*.json' -o -name '*.jsonl' \
        -o -name '*.txt' -o -name '*.sh' -o -name '*.gitignore' -o -name '*.html' -o -name '*.css' \
        -o -name '*.js' -o -name '*.toml' \
      \) -print0 2>/dev/null || true
  )
}

# 在 README.md 注入或更新「Agent 路径」说明（HTML 注释标记块，幂等）
# 用法：inject_readme_agent_note <readme_path>
inject_readme_agent_note() {
  local readme="$1"
  [[ -f "$readme" ]] || return 0
  have_perl || return 0

  local note_tmp
  note_tmp="$(mktemp "${TMPDIR:-/tmp}/sdx-agent-readme-note.XXXXXX")" || return 0
  {
    printf '%s\n' '<!-- sdx-agent-dirs-note:begin -->'
    printf '%s\n' "> **Agent 路径**：知识库内指向中央库 **agent** 树及 IDE Agent 目录（\`.cursor\` / \`.trae\` / \`.claude\` / \`.kiro\` / \`.codex\`）的路径已重写为 \`${DOCS_AGENT_REWRITE_TARGET}\`（与 agent-install 实体树一致）。"
    printf '%s\n' "> **IDE 软链目录**：\`.cursor\`、\`.trae\`、\`.claude\`、\`.kiro\`、\`.codex\`（可通过 \`agent-install --agents=...\` 安装对应目录）。"
    printf '%s\n' '<!-- sdx-agent-dirs-note:end -->'
  } > "$note_tmp"

  NOTE_FILE="$note_tmp" perl -CSD -e '
    use strict;
    use warnings;
    use utf8;
    my $path = $ARGV[0];
    open my $fh, "<:encoding(UTF-8)", $path or exit 0;
    local $/;
    my $t = <$fh>;
    close $fh;
    open my $nf, "<:encoding(UTF-8)", $ENV{NOTE_FILE} or exit 0;
    my $nb = <$nf>;
    close $nf;
    chomp $nb;
    my $b = "<!-- sdx-agent-dirs-note:begin -->";
    my $e = "<!-- sdx-agent-dirs-note:end -->";
    if ($t =~ /\Q$b\E/s && $t =~ /\Q$e\E/s) {
      $t =~ s{\Q$b\E[\s\S]*?\Q$e\E}{$nb}s;
    } else {
      $t .= "\n\n" . $nb . "\n";
    }
    open $fh, ">:encoding(UTF-8)", $path or exit 0;
    print $fh $t;
    close $fh;
  ' "$readme" 2>/dev/null || true
  rm -f "$note_tmp"
}

# 将知识库树中 agent/（含 ../agent/、../../agent/ 等多层上跳）与已知 IDE Agent 路径重写为 ~/.agents/，并更新 README 注记（docs-install / docs-upgrade 共用）
# 用法：rewrite_docs_agent_paths <docs_abs> [ignored_legacy_arg]
rewrite_docs_agent_paths() {
  local docs_abs="${1:?}"
  [[ -d "$docs_abs" ]] || return 0

  info ">>> 重写知识库中的 agent/ 与 IDE Agent 路径段为 ${DOCS_AGENT_REWRITE_TARGET}"
  rewrite_agent_path_segment_in_tree "$docs_abs"

  local readme="${docs_abs%/}/README.md"
  if [[ -f "$readme" ]]; then
    inject_readme_agent_note "$readme"
  fi
}
