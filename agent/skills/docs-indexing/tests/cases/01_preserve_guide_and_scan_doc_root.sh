#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
PROJECT="$TMP_DIR/project"
DOCS="$PROJECT/docs"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

mkdir -p "$DOCS/knowledge" "$PROJECT/agent/scripts" "$DOCS/.agents"
git -C "$PROJECT" init -q

{
  printf 'REPO_DIR=%s\n' "$(basename "$PROJECT")"
  printf 'DOC_DIR=docs\n'
  printf 'KNOWLEDGE_TYPE=company\n'
  printf 'AGENT_ROOT=%s\n' "$TMP_DIR/agent-home"
  printf 'AGENT_DIR=.agents\n'
} >"$PROJECT/.docsconfig"
pin_workspace_for_repo "$PROJECT" "$TMP_DIR/agent-home" .agents

printf 'root-agent\n' >"$PROJECT/agent/scripts/should-not-index.txt"
printf 'docs-agent\n' >"$DOCS/.agents/should-not-index.txt"
printf 'knowledge\n' >"$DOCS/knowledge/knowledge.md"
printf 'viz\n' >"$DOCS/viz.html"
printf 'ds\n' >"$DOCS/.DS_Store"

{
  printf -- '---\ntype: Documentation\ntitle: company INDEX-GUIDE\n---\n'
  printf '<!-- okf:begin -->\n## OKF 渐进披露\n\n* [README.md](README.md)\n<!-- okf:end -->\n\n'
  printf '# company INDEX-GUIDE\n\n'
  printf '| 文件总数 |\n|---:|\n| 999 |\n\n'
  printf '<!-- docs-build:entity-index:begin -->\n### 视角入口\n\n- [业务](knowledge/business/README.md)\n<!-- docs-build:entity-index:end -->\n\n'
  printf '## 八、索引边界\n\n| 项 | 值 |\n|----|----|\n| 文件总数 | 999 |\n'
} >"$DOCS/INDEX-GUIDE.md"
cp "$DOCS/INDEX-GUIDE.md" "$TMP_DIR/original.md"

(cd "$PROJECT" && "$BASH" "$INDEXING_SCRIPT" --mode full --depth 3)

cmp "$TMP_DIR/original.md" "$DOCS/INDEX-GUIDE.md" || fail "默认扫描须保持指南逐字节不变"

grep -q '^# company INDEX-GUIDE$' "$DOCS/INDEX-GUIDE.md" || fail "既有 H1 被冲掉"
grep -q 'docs-build:entity-index:begin' "$DOCS/INDEX-GUIDE.md" || fail "docs-build 块被冲掉"
grep -q 'okf:begin' "$DOCS/INDEX-GUIDE.md" || fail "OKF 块被冲掉"
if grep -q 'docs-indexing:begin' "$DOCS/INDEX-GUIDE.md"; then
  fail "默认模式不应追加生成块"
fi
grep -q '| 999 |' "$DOCS/INDEX-GUIDE.md" || fail "未启用 rewrite 时不应改既有统计"

base=$(python3 "$INDEXING_LOG_PY" read-baseline "$DOCS/INDEX-GUIDE.md")
[[ "$base" == 0 ]] || fail "扫描不得写入完成锚点"

(cd "$PROJECT" && "$BASH" "$INDEXING_SCRIPT" --mode full --depth 3 --rewrite)

grep -q 'docs-indexing:begin' "$DOCS/INDEX-GUIDE.md" || fail "rewrite 未写入生成块"
grep -q 'docs-build:entity-index:begin' "$DOCS/INDEX-GUIDE.md" || fail "rewrite 冲掉 docs-build 块"
grep -q 'okf:begin' "$DOCS/INDEX-GUIDE.md" || fail "rewrite 冲掉 OKF 块"
grep -Fq '| 文件总数 | `2` |' "$DOCS/INDEX-GUIDE.md" || fail "候选集应仅包含指南与知识文档"
if grep -q 'sdx-indexing:indexing_finished_ms=' "$DOCS/INDEX-GUIDE.md"; then
  fail "rewrite 不得写入完成锚点"
fi

pass "默认保护既有九章；rewrite 保留实体块并只扫文档目录"
