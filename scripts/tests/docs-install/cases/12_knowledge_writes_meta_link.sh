#!/usr/bin/env bash
# scope=knowledge 写入 type:meta；重装 upsert；dry-run 不落盘改 meta
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../test-lib.sh
source "$TEST_DIR/../test-lib.sh"

TMP_DIR="$(new_tmp_dir)"
PROJECT_DIR="$TMP_DIR/project"
DOCS_DIR="$PROJECT_DIR/docs"
OUT_FILE="$TMP_DIR/case12.out"
LINKS="$DOCS_DIR/knowledge-links.yaml"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$DOCS_DIR"
git -C "$PROJECT_DIR" init -q

META_REPO="$(git -C "$ROOT_DIR" remote get-url origin 2>/dev/null || true)"
[[ -n "$META_REPO" ]] || fail "测试依赖中央库 origin remote"

bash "$DOCS_INSTALL_SCRIPT" --scope=knowledge --type=application --target "$DOCS_DIR" \
  >"$OUT_FILE" 2>&1

assert_file_exists "$LINKS"
grep -Fq 'type: meta' "$LINKS" || fail "应写入 type: meta"
grep -Fq "repository: \"$META_REPO\"" "$LINKS" || fail "meta.repository 应为装机源仓 origin"
grep -Fq 'doc_dir: "application"' "$LINKS" || fail "meta.doc_dir 应为 application"

# 手改 meta 后重装应覆盖回当前源仓
cat >"$LINKS" <<EOF
links:
  - type: meta
    repository: "https://example.com/old-meta.git"
    path: "~/old-meta"
    doc_dir: "application"
  - type: meta
    repository: "https://example.com/extra-meta.git"
    path: "~/extra-meta"
    doc_dir: "application"
EOF

bash "$DOCS_INSTALL_SCRIPT" --scope=knowledge --type=application --force --target "$DOCS_DIR" \
  >"$OUT_FILE" 2>&1

meta_count="$(grep -c 'type: meta' "$LINKS" || true)"
[[ "$meta_count" -eq 1 ]] || fail "重装后应恰好一条 type: meta（实际 $meta_count）"
grep -Fq "repository: \"$META_REPO\"" "$LINKS" || fail "重装应覆盖 meta.repository"
grep -Fq 'https://example.com/extra-meta.git' "$LINKS" \
  && fail "多余 meta 应被丢弃"

# dry-run 不应改写已有 meta
printf '%s\n' 'links: []' >"$LINKS"
bash "$DOCS_INSTALL_SCRIPT" --scope=knowledge --type=application --dry-run --target "$DOCS_DIR" \
  >"$OUT_FILE" 2>&1
grep -Fq 'type: meta' "$LINKS" && fail "dry-run 不应落盘 type: meta"
grep -Fq '[dry-run] upsert type:meta' "$OUT_FILE" || fail "dry-run 应 log upsert meta"

pass "knowledge 写入/upsert type:meta；dry-run 不落盘"
