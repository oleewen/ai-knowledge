#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
META_ROOT="$(cd "$TEST_ROOT/../../../.." && pwd)"
source "$META_ROOT/agent/scripts/test-core.sh"
VALIDATOR="$TEST_ROOT/../scripts/validate-solution.sh"

new_repo() {
  FIXTURE="$(mktemp -d "${TMPDIR:-/tmp}/sdx-solution-test.XXXXXX")"
  FIXTURE="$(cd "$FIXTURE" && pwd -P)"
  REPO="$FIXTURE/project space"
  SOLUTIONS="$REPO/docs/solutions"
  mkdir -p "$SOLUTIONS" "$FIXTURE/agents"
  printf 'WORK_SPACE=%s\n' "$FIXTURE" >"$FIXTURE/agents/configs"
  cat >"$REPO/.docsconfig" <<EOF
AGENT_ROOT=$FIXTURE
AGENT_DIR=agents
REPO_DIR=project space
DOC_DIR=docs
KNOWLEDGE_TYPE=solution
EOF
  OUTPUT="$FIXTURE/output"
}

body() {
  printf '## %s\n\n' '这次改了什么' '为什么这样切' '范围内外' '流程怎么串' '主数据主权' '技术例外'
}

document() {
  local name="$1" parent="${2:-\"\"}"
  {
    printf '%s\nid: "%s"\nparent: %s\n%s\n\n# 示例\n\n' '---' "$name" "$parent" '---'
    body
  } >"$SOLUTIONS/$name.md"
}

check() {
  local expected="$1" cwd="$2" code=0
  shift 2
  (cd "$cwd" && "$BASH" "$VALIDATOR" "$@") >"$OUTPUT" 2>&1 || code=$?
  if [[ "$code" -ne "$expected" ]]; then
    cat "$OUTPUT" >&2
    test_fail "期望 exit ${expected}，实际 ${code}；fixture=$FIXTURE"
  fi
}

case_cli() {
  new_repo
  check 0 "$FIXTURE" --help
  grep -Fq -- '--file' "$OUTPUT" || test_fail '帮助缺少 --file'
  check 1 "$FIXTURE" --file
  assert_not_contains 'unbound variable' "$OUTPUT"
  check 1 "$FIXTURE" --file ''
  check 1 "$FIXTURE" --file --help
  check 1 "$FIXTURE" --unknown
  check 1 "$FIXTURE" --file a --file b
}

case_relative() {
  new_repo
  document SOLUTION-261022-a
  check 0 "$SOLUTIONS" --file SOLUTION-261022-a.md
  check 0 "$REPO" --file docs/solutions/SOLUTION-261022-a.md
  check 0 "$REPO" --file "$SOLUTIONS/SOLUTION-261022-a.md"
  check 1 "$REPO" --file does-not-exist.md
}

case_valid_roots() {
  new_repo
  document SOLUTION-261022-a
  document SOLUTION-261022-b "'' # 第一份"
  document SOLUTION-261022-c 'null # 第一份'
  document SOLUTION-261022-d '~'
  check 0 "$REPO"
}

case_empty() {
  new_repo
  check 0 "$REPO"
  assert_contains '[WARN]' "$OUTPUT"
  mkdir -p "$REPO/other"
  sed 's/DOC_DIR=docs/DOC_DIR=other/' "$REPO/.docsconfig" >"$FIXTURE/config"
  cat "$FIXTURE/config" >"$REPO/.docsconfig"
  check 0 "$REPO"
  assert_contains '[WARN]' "$OUTPUT"
}

case_fork() {
  new_repo
  document SOLUTION-261022-a
  document SOLUTION-261022-b '"SOLUTION-261022-a"'
  document SOLUTION-261022-c '"SOLUTION-261022-a"'
  check 1 "$REPO"
  check 1 "$REPO" --file "$SOLUTIONS/SOLUTION-261022-c.md"
  assert_not_contains '[OK]    SOLUTION-261022-c.md' "$OUTPUT"
}

case_scalar_quotes() {
  new_repo
  document SOLUTION-261022-a
  document SOLUTION-261022-b "'SOLUTION-261022-a' # 上一份"
  check 0 "$REPO"
  document SOLUTION-261022-c 'SOLUTION-261022-a # 上一份'
  check 1 "$REPO"
}

case_crlf() {
  new_repo
  document SOLUTION-261022-a
  document SOLUTION-261022-b '"SOLUTION-261022-a" # 上一份'
  awk '{ printf "%s\r\n", $0 }' "$SOLUTIONS/SOLUTION-261022-b.md" >"$FIXTURE/crlf"
  cat "$FIXTURE/crlf" >"$SOLUTIONS/SOLUTION-261022-b.md"
  check 0 "$REPO"
  document SOLUTION-261022-c "'SOLUTION-261022-a'"
  check 1 "$REPO"
}

case_orphan() {
  new_repo
  document SOLUTION-261022-a '"SOLUTION-261022-missing"'
  check 1 "$REPO"
}

case_self_parent() {
  new_repo
  document SOLUTION-261022-a '"SOLUTION-261022-a"'
  check 1 "$REPO"
}

case_cycle() {
  new_repo
  document SOLUTION-261022-a '"SOLUTION-261022-b"'
  document SOLUTION-261022-b '"SOLUTION-261022-a"'
  check 1 "$REPO"
}

case_duplicate_id() {
  new_repo
  document SOLUTION-261022-a
  mkdir -p "$SOLUTIONS/nested"
  cp "$SOLUTIONS/SOLUTION-261022-a.md" "$SOLUTIONS/nested/SOLUTION-261022-a.md"
  check 1 "$REPO"
}

case_identity() {
  new_repo
  document SOLUTION-261022-a
  cp "$SOLUTIONS/SOLUTION-261022-a.md" "$SOLUTIONS/SOLUTION-261022-b.md"
  check 1 "$REPO"
}

case_frontmatter() {
  new_repo
  { printf 'parent: ""\n'; body; } >"$SOLUTIONS/SOLUTION-261022-a.md"
  check 1 "$REPO"
  { printf '%s\nparent: ""\n%s\n' '---' '---'; body; } >"$SOLUTIONS/SOLUTION-261022-a.md"
  check 1 "$REPO"
  { printf '%s\nid: "SOLUTION-261022-a"\n%s\nparent: ""\n' '---' '---'; body; } >"$SOLUTIONS/SOLUTION-261022-a.md"
  check 1 "$REPO"
}

case_complex_scalar() {
  new_repo
  local value
  for value in '[]' '{}' '|-' '>-' '*alias' '&anchor SOLUTION-261022-a' '"unterminated' '"SOLUTION-261022-a" trailing'; do
    document SOLUTION-261022-a "$value"
    check 1 "$REPO"
  done
}

case_complex_continuations() {
  new_repo
  local key continuation
  for key in id parent; do
    for continuation in '- SOLUTION-261022-missing' '? SOLUTION-261022-missing' ': SOLUTION-261022-missing'; do
      {
        printf '%s\n' '---'
        if [[ "$key" == id ]]; then
          printf 'id: "SOLUTION-261022-a"\n# 续行\n\n%s\nparent: ""\n' "$continuation"
        else
          printf 'id: "SOLUTION-261022-a"\nparent:\n# 续行\n\n%s\n' "$continuation"
        fi
        printf '%s\n' '---'
        body
      } >"$SOLUTIONS/SOLUTION-261022-a.md"
      check 1 "$REPO"
    done
  done
}

case_identity_key_syntax() {
  new_repo
  local metadata
  for metadata in $'id:SOLUTION-261022-a\nparent: null' $'id: SOLUTION-261022-a\nparent:null' $'id: SOLUTION-261022-a\nparent: null\n"parent": "SOLUTION-261022-missing"' $'id: SOLUTION-261022-a\nparent: null\n\047id\047: SOLUTION-261022-a'; do
    { printf '%s\n%s\n%s\n' '---' "$metadata" '---'; body; } >"$SOLUTIONS/SOLUTION-261022-a.md"
    check 1 "$REPO"
  done
}

case_duplicate_key() {
  new_repo
  { printf '%s\nid: "SOLUTION-261022-a"\nparent: ""\nparent: null\n%s\n' '---' '---'; body; } >"$SOLUTIONS/SOLUTION-261022-a.md"
  check 1 "$REPO"
}

case_fenced_headings() {
  new_repo
  { printf '%s\nid: "SOLUTION-261022-a"\nparent: ""\n%s\n```md\n' '---' '---'; body; printf '```\n'; } >"$SOLUTIONS/SOLUTION-261022-a.md"
  check 1 "$REPO"
}

case_commented_headings() {
  new_repo
  { printf '%s\nid: "SOLUTION-261022-a"\nparent: ""\n%s\n<!--\n' '---' '---'; body; printf '%s\n' '-->'; } >"$SOLUTIONS/SOLUTION-261022-a.md"
  check 1 "$REPO"
}

case_comment_prefix() {
  new_repo
  {
    printf '%s\nid: "SOLUTION-261022-a"\nparent: ""\n%s\n' '---' '---'
    body | sed 's/^## /<!-- comment -->## /'
  } >"$SOLUTIONS/SOLUTION-261022-a.md"
  check 1 "$REPO"
}

case_heading_order() {
  new_repo
  document SOLUTION-261022-a
  printf '## 为什么这样切\n' >>"$SOLUTIONS/SOLUTION-261022-a.md"
  check 1 "$REPO"
  { printf '%s\nid: "SOLUTION-261022-a"\nparent: ""\n%s\n' '---' '---'; printf '## %s\n' '技术例外' '主数据主权' '流程怎么串' '范围内外' '为什么这样切' '这次改了什么'; } >"$SOLUTIONS/SOLUTION-261022-a.md"
  check 1 "$REPO"
}

case_heading_prefix() {
  new_repo
  { printf '%s\nid: "SOLUTION-261022-a"\nparent: ""\n%s\n' '---' '---'; body | sed 's/^## /### /'; } >"$SOLUTIONS/SOLUTION-261022-a.md"
  check 1 "$REPO"
}

case_empty_heading() {
  new_repo
  document SOLUTION-261022-a
  printf '##\n' >>"$SOLUTIONS/SOLUTION-261022-a.md"
  check 1 "$REPO"
}

case_indented_code_comment() {
  new_repo
  local indent
  for indent in '    ' $'\t' $'  \t'; do
    document SOLUTION-261022-a
    printf '\n%s<!-- SYS-ORDER -->\n' "$indent" >>"$SOLUTIONS/SOLUTION-261022-a.md"
    check 1 "$REPO"
  done
  document SOLUTION-261022-a
  printf '\n<!--\n    SYS-ORDER\n\tFR-001\n-->\n' >>"$SOLUTIONS/SOLUTION-261022-a.md"
  check 0 "$REPO"
  document SOLUTION-261022-a
  printf '\n正文继续\n    <!-- SYS-ORDER -->\n' >>"$SOLUTIONS/SOLUTION-261022-a.md"
  check 0 "$REPO"
}

case_thematic_code_boundary() {
  new_repo
  local divider
  for divider in '---' '***' '* * *' '_ _ _' '- - -' '  ***' '   - - -'; do
    document SOLUTION-261022-a
    printf '%s\n    <!-- SYS-ORDER -->\n' "$divider" >>"$SOLUTIONS/SOLUTION-261022-a.md"
    check 1 "$REPO"
  done
}

case_thematic_controls() {
  new_repo
  document SOLUTION-261022-a
  printf '%s\n' '---' '' '* * *' '' '    代码示例' '    ---' '    * * *' >>"$SOLUTIONS/SOLUTION-261022-a.md"
  check 0 "$REPO"
}

case_setext_heading() {
  new_repo
  local underline
  for underline in '---' '-' '  -----'; do
    document SOLUTION-261022-a
    printf '附加小结\n%s\n' "$underline" >>"$SOLUTIONS/SOLUTION-261022-a.md"
    check 1 "$REPO"
  done
  document SOLUTION-261022-a
  printf '%s\n' '```' '示例标题' '---' '```' '' '<!--' '注释标题' '---' '-->' '' '    代码标题' '    ---' '' '- 列表项' '---' >>"$SOLUTIONS/SOLUTION-261022-a.md"
  check 0 "$REPO"
}

case_reference_definition() {
  new_repo
  document SOLUTION-261022-a
  printf '%s\n' '[ref]: /path' '附加小结' '---' >>"$SOLUTIONS/SOLUTION-261022-a.md"
  check 1 "$REPO"
  document SOLUTION-261022-a
  printf '%s\n' '[ref]: /path' '---' >>"$SOLUTIONS/SOLUTION-261022-a.md"
  check 0 "$REPO"
  document SOLUTION-261022-a
  printf '%s\n' '[ref]: /path trailing junk' '---' >>"$SOLUTIONS/SOLUTION-261022-a.md"
  check 1 "$REPO"
}

case_reference_definition_context() {
  new_repo
  document SOLUTION-261022-a
  printf '%s\n' '普通正文' '[ref]: /path' '---' >>"$SOLUTIONS/SOLUTION-261022-a.md"
  check 1 "$REPO"
  document SOLUTION-261022-a
  printf '%s\n' '- 列表项' '[ref]: /path' '---' '' '> 引用' '[ref]: /path' '---' >>"$SOLUTIONS/SOLUTION-261022-a.md"
  check 0 "$REPO"
}

case_reference_continuation() {
  new_repo
  document SOLUTION-261022-a
  printf '%s\n' '[ref]: /path' '    <!-- SYS-ORDER -->' >>"$SOLUTIONS/SOLUTION-261022-a.md"
  check 0 "$REPO"
  document SOLUTION-261022-a
  printf '%s\n' '[ref]: /path' '[next]: /next' '    <!-- MVP -->' '附加小结' '---' >>"$SOLUTIONS/SOLUTION-261022-a.md"
  check 1 "$REPO"
  assert_contains 'Setext H2' "$OUTPUT"
  document SOLUTION-261022-a
  printf '%s\n' '[ref]: /path' '' '    <!-- SYS-ORDER -->' >>"$SOLUTIONS/SOLUTION-261022-a.md"
  check 1 "$REPO"
  assert_contains '正文出现 SYS' "$OUTPUT"
}

case_reference_empty_label() {
  new_repo
  local label
  for label in ' ' $'\t' $' \t '; do
    document SOLUTION-261022-a
    printf '[%s]: /path\n---\n' "$label" >>"$SOLUTIONS/SOLUTION-261022-a.md"
    check 1 "$REPO"
    assert_contains 'Setext H2' "$OUTPUT"
  done
}

case_inline_multiline_comment() {
  new_repo
  document SOLUTION-261022-a
  printf '%s\n' '正文 <!--' 'comment -->' '    <!-- SYS-ORDER -->' >>"$SOLUTIONS/SOLUTION-261022-a.md"
  check 0 "$REPO"
}

case_block_multiline_comment() {
  new_repo
  document SOLUTION-261022-a
  printf '%s\n' '正文' '<!--' 'comment -->' '    <!-- SYS-ORDER -->' >>"$SOLUTIONS/SOLUTION-261022-a.md"
  check 1 "$REPO"
}

case_inline_comment_boundaries() {
  new_repo
  local boundary
  for boundary in '' '## 额外章节' '```' '***' '* * *'; do
    document SOLUTION-261022-a
    printf '%s\n' '正文 <!--' "$boundary" 'MVP' '-->' >>"$SOLUTIONS/SOLUTION-261022-a.md"
    check 1 "$REPO"
    assert_contains '歧义' "$OUTPUT"
  done
  document SOLUTION-261022-a
  printf '%s\n' '<!--' '' '## 额外章节' 'MVP' '-->' >>"$SOLUTIONS/SOLUTION-261022-a.md"
  check 0 "$REPO"
}

case_body_tokens() {
  new_repo
  local token
  for token in 'SYS-ORDER' 'FR-001' 'MVP' '里程碑'; do
    document SOLUTION-261022-a
    printf '%s\n' "$token" >>"$SOLUTIONS/SOLUTION-261022-a.md"
    check 1 "$REPO"
    assert_not_contains '[OK]    SOLUTION-261022-a.md' "$OUTPUT"
  done
}

case_body_selection() {
  new_repo
  document SOLUTION-261022-a
  document SOLUTION-261022-b '"SOLUTION-261022-a"'
  printf 'MVP\n' >>"$SOLUTIONS/SOLUTION-261022-a.md"
  check 0 "$REPO" --file "$SOLUTIONS/SOLUTION-261022-b.md"
  check 1 "$REPO"
}

case_body_scope() {
  new_repo
  { printf '%s\nid: "SOLUTION-261022-a"\nparent: ""\ntitle: "SYS MVP FR 里程碑"\n%s\n' '---' '---'; body; printf '<!-- SYS FR MVP 里程碑 -->\n'; } >"$SOLUTIONS/SOLUTION-261022-a.md"
  check 0 "$REPO"
}

case_inline_code_comments() {
  new_repo
  local content
  for content in '`<!--` SYS-ORDER' '``<!--`` FR-001' '`<!-- SYS-ORDER -->`' '\<!-- SYS-ORDER' '``text ` <!--`` MVP'; do
    document SOLUTION-261022-a
    printf '%s\n' "$content" >>"$SOLUTIONS/SOLUTION-261022-a.md"
    check 1 "$REPO"
  done
  document SOLUTION-261022-a
  printf '%s\n' '`<!--` <!-- SYS-ORDER -->' '\` <!-- FR-001 -->' >>"$SOLUTIONS/SOLUTION-261022-a.md"
  check 0 "$REPO"
}

case_literal_backticks() {
  new_repo
  document SOLUTION-261022-a
  printf '%s\n' '`code' >>"$SOLUTIONS/SOLUTION-261022-a.md"
  check 0 "$REPO"
  document SOLUTION-261022-a
  printf '%s\n' '``code `' >>"$SOLUTIONS/SOLUTION-261022-a.md"
  check 0 "$REPO"
}

case_ambiguous_code_comment() {
  new_repo
  document SOLUTION-261022-a
  printf '%s\n' 'text `code' '<!-- SYS-ORDER -->' 'end`' >>"$SOLUTIONS/SOLUTION-261022-a.md"
  check 1 "$REPO"
  assert_contains '歧义' "$OUTPUT"
}

case_mixed_fence() {
  new_repo
  { printf '%s\nid: "SOLUTION-261022-a"\nparent: ""\n%s\n```md\n````~\n' '---' '---'; body; printf '```\n'; } >"$SOLUTIONS/SOLUTION-261022-a.md"
  check 1 "$REPO"
}

case_valid_fences() {
  new_repo
  {
    printf '%s\nid: "SOLUTION-261022-a"\nparent: ""\n%s\n' '---' '---'
    printf '```md\n## 伪标题\n``\n## 仍在代码块\n```\n'
    printf '~~~md\n## 伪标题\n~~~~\n'
    printf '<!-- ## 伪标题 -->\n'
    body
  } >"$SOLUTIONS/SOLUTION-261022-a.md"
  check 0 "$REPO"
}

case_invalid_fence_info() {
  new_repo
  document SOLUTION-261022-a
  printf '%s\n\n## 额外标题\n' '```foo`bar' >>"$SOLUTIONS/SOLUTION-261022-a.md"
  check 1 "$REPO"
}

case_linked_solutions() {
  new_repo
  document SOLUTION-261022-a
  mv "$SOLUTIONS" "$FIXTURE/actual-solutions"
  ln -s "$FIXTURE/actual-solutions" "$SOLUTIONS"
  check 0 "$REPO"
  document SOLUTION-261022-a '"SOLUTION-261022-b"'
  document SOLUTION-261022-b '"SOLUTION-261022-a"'
  check 1 "$REPO"
}

case_linked_successor() {
  new_repo
  document SOLUTION-261022-a
  document SOLUTION-261022-b '"SOLUTION-261022-a"'
  document SOLUTION-261022-c '"SOLUTION-261022-a"'
  mv "$SOLUTIONS/SOLUTION-261022-c.md" "$FIXTURE/SOLUTION-261022-c.md"
  ln -s "$FIXTURE/SOLUTION-261022-c.md" "$SOLUTIONS/SOLUTION-261022-c.md"
  check 1 "$REPO"
}

case_linked_target() {
  new_repo
  document SOLUTION-261022-a
  mkdir "$FIXTURE/aliases"
  ln -s "$SOLUTIONS/SOLUTION-261022-a.md" "$FIXTURE/aliases/SOLUTION-261022-a.md"
  check 0 "$REPO" --file "$FIXTURE/aliases/SOLUTION-261022-a.md"
  printf 'SYS-ORDER\n' >>"$SOLUTIONS/SOLUTION-261022-a.md"
  check 1 "$REPO" --file "$FIXTURE/aliases/SOLUTION-261022-a.md"
}

case_linked_alias_identity() {
  new_repo
  document SOLUTION-261022-a
  mkdir "$SOLUTIONS/aliases"
  ln -s "$SOLUTIONS/SOLUTION-261022-a.md" "$SOLUTIONS/aliases/SOLUTION-261022-a.md"
  check 0 "$REPO"
  ln -s "$SOLUTIONS/SOLUTION-261022-a.md" "$SOLUTIONS/SOLUTION-261022-wrong.md"
  check 1 "$REPO"
}

case_link_cycle() {
  new_repo
  document SOLUTION-261022-a
  ln -s "$SOLUTIONS" "$SOLUTIONS/cycle"
  check 1 "$REPO"
}

case_broken_links() {
  new_repo
  document SOLUTION-261022-a
  ln -s "$FIXTURE/missing.md" "$SOLUTIONS/SOLUTION-261022-missing.md"
  check 1 "$REPO"
  new_repo
  ln -s "$FIXTURE/missing-directory" "$SOLUTIONS/unmounted"
  check 1 "$REPO"
  new_repo
  mv "$SOLUTIONS" "$FIXTURE/original-solutions"
  ln -s "$FIXTURE/missing-directory" "$SOLUTIONS"
  check 1 "$REPO"
}

case_configuration() {
  new_repo
  document SOLUTION-261022-a
  sed 's/KNOWLEDGE_TYPE=solution/KNOWLEDGE_TYPE=sln/' "$REPO/.docsconfig" >"$FIXTURE/config"
  cat "$FIXTURE/config" >"$REPO/.docsconfig"
  check 0 "$REPO"
  sed 's/KNOWLEDGE_TYPE=sln/KNOWLEDGE_TYPE=company/' "$REPO/.docsconfig" >"$FIXTURE/config"
  cat "$FIXTURE/config" >"$REPO/.docsconfig"
  check 1 "$REPO"
  check 1 "$FIXTURE"
}

case_read_only() {
  new_repo
  document SOLUTION-261022-a
  local before after
  before="$(find "$REPO" -type f -exec cksum {} + | sort)"
  check 0 "$REPO"
  after="$(find "$REPO" -type f -exec cksum {} + | sort)"
  [[ "$before" == "$after" ]] || test_fail '校验修改了工程文件'
}

CASES=(cli relative valid_roots empty fork scalar_quotes crlf orphan self_parent cycle duplicate_id identity frontmatter complex_scalar complex_continuations identity_key_syntax duplicate_key fenced_headings commented_headings comment_prefix heading_order heading_prefix empty_heading indented_code_comment thematic_code_boundary thematic_controls setext_heading reference_definition reference_definition_context reference_continuation reference_empty_label inline_multiline_comment block_multiline_comment inline_comment_boundaries body_tokens body_selection body_scope inline_code_comments literal_backticks ambiguous_code_comment mixed_fence valid_fences invalid_fence_info linked_solutions linked_successor linked_target linked_alias_identity link_cycle broken_links configuration read_only)
if [[ "${1:-}" == --case ]]; then
  "case_${2:?case name}"
  test_pass "$2"
  exit 0
fi

failed=0
for name in "${CASES[@]}"; do
  if ! "$BASH" "$0" --case "$name"; then
    failed=$((failed + 1))
  fi
done
printf 'sdx-solution: %d cases, %d failed\n' "${#CASES[@]}" "$failed"
[[ "$failed" -eq 0 ]]
