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

mkdir -p "$DOCS/knowledge" "$DOCS/changelogs" "$PROJECT/agent/scripts" "$DOCS/.agents"
git -C "$PROJECT" init -q

{
  printf 'DOC_ROOT=%s\n' "$DOCS"
  printf 'REPO_ROOT=%s\n' "$PROJECT"
  printf 'DOC_DIR=docs\n'
  printf 'KNOWLEDGE_TYPE=company\n'
  printf 'AGENT_ROOT=~\n'
  printf 'AGENT_DIR=.agents\n'
} >"$PROJECT/.docsconfig"

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

(cd "$PROJECT" && "$INDEXING_SCRIPT" --mode full --depth 3)

grep -q '^# company INDEX-GUIDE$' "$DOCS/INDEX-GUIDE.md" || fail "既有 H1 被冲掉"
grep -q 'docs-build:entity-index:begin' "$DOCS/INDEX-GUIDE.md" || fail "docs-build 块被冲掉"
grep -q 'okf:begin' "$DOCS/INDEX-GUIDE.md" || fail "OKF 块被冲掉"
if grep -q 'docs-indexing:begin' "$DOCS/INDEX-GUIDE.md"; then
  fail "默认模式不应追加生成块"
fi
grep -q '| 999 |' "$DOCS/INDEX-GUIDE.md" || fail "未启用 rewrite 时不应改既有统计"

base=$(python3 "$ROOT_DIR/agent/skills/docs-indexing/scripts/indexing_log.py" read-baseline "$DOCS/changelogs/INDEXING-LOG.md")
[[ "$base" != 0 ]] || fail "INDEX 成功后应写 LOG"

(cd "$PROJECT" && "$INDEXING_SCRIPT" --mode full --depth 3 --rewrite)

grep -q 'docs-indexing:begin' "$DOCS/INDEX-GUIDE.md" || fail "rewrite 未写入生成块"
grep -q 'docs-build:entity-index:begin' "$DOCS/INDEX-GUIDE.md" || fail "rewrite 冲掉 docs-build 块"
grep -q 'okf:begin' "$DOCS/INDEX-GUIDE.md" || fail "rewrite 冲掉 OKF 块"
if grep -q 'should-not-index.txt' "$DOCS/INDEX-GUIDE.md"; then
  fail "根外或隐藏目录被索引"
fi

pass "默认保护既有九章；rewrite 保留实体块并只扫 DOC_ROOT"
