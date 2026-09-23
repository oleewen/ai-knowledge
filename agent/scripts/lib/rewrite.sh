#!/usr/bin/env bash
#
# lib/rewrite.sh — 知识库树内 agent 路径重写与 README 注记
# 依赖：lib/log-io.sh（info / have_*）
#
# 消费库：收敛为相对 DOC_DIR/.agents 的深度相对路径
# 云库 meta：收敛为相对 DOC_DIR 视角下深度相对的 agent/
#

_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=path.sh
source "${_LIB_DIR}/path.sh"
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

# 文件相对 docs_root 的目录深度 → 前缀（如 "" / "../" / "../../"）
# 用法：rewrite_docs_rel_prefix <docs_abs> <file_abs> → 打印前缀（不含段名）
rewrite_docs_rel_prefix() {
  local docs_abs="${1:?}"
  local file_abs="${2:?}"
  local docs_n file_dir rel depth=0
  docs_n="$(cd -P "$docs_abs" 2>/dev/null && pwd -P)" || docs_n="$(abs_path "$docs_abs")"
  file_dir="$(cd -P "$(dirname "$file_abs")" 2>/dev/null && pwd -P)" \
    || file_dir="$(abs_path "$(dirname "$file_abs")")"
  if [[ "$file_dir" == "$docs_n" ]]; then
    printf ''
    return 0
  fi
  case "$file_dir" in
    "$docs_n"/*)
      rel="${file_dir#"$docs_n"/}"
      ;;
    *)
      printf ''
      return 0
      ;;
  esac
  [[ -z "$rel" || "$rel" == '.' ]] && { printf ''; return 0; }
  depth="$(awk -F'/' '{print NF}' <<<"$rel")"
  local i prefix=''
  for ((i = 0; i < depth; i++)); do
    prefix="../${prefix}"
  done
  printf '%s' "$prefix"
}

# mode=consumer|meta；段名 consumer→.agents/ meta→agent/
rewrite_agent_path_segment_in_file() {
  local file="$1"
  local docs_abs="$2"
  local mode="${3:-consumer}"
  local seg prefix target
  [[ -f "$file" ]] && is_text_file "$file" || return 0
  grep -qE 'agent/|~/\.agents/' "$file" 2>/dev/null || return 0
  have_cmd perl || return 0

  case "$mode" in
    meta) seg='agent/' ;;
    *) seg='.agents/' ;;
  esac
  prefix="$(rewrite_docs_rel_prefix "$docs_abs" "$file")"
  target="${prefix}${seg}"

  if ! AGENT_SLASH="$target" \
    perl -CSD -i -pe '
      BEGIN {
        die "AGENT_SLASH unset\n" unless defined $ENV{AGENT_SLASH} && length $ENV{AGENT_SLASH};
        our $upagent = qr/(?:\.\.\/)*agent\//;
        our $updotagents = qr/(?:\.\.\/)*\.agents\//;
        our $tilde = qr/~\/\.agents\//;
      }
      s{$tilde}{$ENV{AGENT_SLASH}}g;
      s{$updotagents}{$ENV{AGENT_SLASH}}g;
      s{$upagent}{$ENV{AGENT_SLASH}}g;
      # 行首/空白后裸 agent/（非 .agents 内）
      s{(?<!\.)\bagent/}{$ENV{AGENT_SLASH}}g;
    ' "$file" 2>/dev/null; then
    warn "重写 agent/ 路径失败：$file"
  fi
}

rewrite_agent_path_segment_in_tree() {
  local root="$1"
  local mode="${2:-consumer}"
  local seg
  case "$mode" in
    meta) seg='agent/' ;;
    *) seg='.agents/' ;;
  esac
  [[ -d "$root" ]] || return 0
  info "  重写 agent 路径引用 → 深度相对 ${seg}（模式=${mode}；跳过 node_modules/.git 等）: ${root}"
  local f
  while IFS= read -r -d '' f; do
    rewrite_agent_path_segment_in_file "$f" "$root" "$mode"
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

# 用法：inject_readme_agent_note <readme_path> [mode]
inject_readme_agent_note() {
  local readme="$1"
  local mode="${2:-consumer}"
  [[ -f "$readme" ]] || return 0
  have_perl || return 0

  local note_tmp note_line
  note_tmp="$(mktemp "${TMPDIR:-/tmp}/sdx-agent-readme-note.XXXXXX")" || return 0
  if [[ "$mode" == 'meta' ]]; then
    note_line='> **Agent 路径**：云库（KNOWLEDGE_TYPE=meta）内指向 agent 树的路径已按相对当前文件深度重写为 `agent/`（相对文档根）。'
  else
    note_line='> **Agent 路径**：知识库内指向 Agent 树的路径已按相对当前文件深度重写为 `.agents/`（文档目录下 `.agents` 软链 → `$AGENT_ROOT/$AGENT_DIR`）。'
  fi
  {
    printf '%s\n' '<!-- sdx-agent-dirs-note:begin -->'
    printf '%s\n' "$note_line"
    printf '%s\n' '<!-- sdx-agent-dirs-note:end -->'
  } >"$note_tmp"

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

# 用法：rewrite_docs_agent_paths <docs_abs> [mode=consumer|meta]
rewrite_docs_agent_paths() {
  local docs_abs="${1:?}"
  local mode="${2:-consumer}"
  [[ -d "$docs_abs" ]] || return 0

  info ">>> 重写知识库 agent 路径（模式=${mode}）"
  rewrite_agent_path_segment_in_tree "$docs_abs" "$mode"

  local readme="${docs_abs%/}/README.md"
  if [[ -f "$readme" ]]; then
    inject_readme_agent_note "$readme" "$mode"
  fi
}
