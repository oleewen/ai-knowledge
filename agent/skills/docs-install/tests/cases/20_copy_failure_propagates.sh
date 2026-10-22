#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../test-lib.sh"
TMP_DIR="$(new_tmp_dir)"
trap 'rm -rf "$TMP_DIR"' EXIT
ensure_test_agent_home "$TMP_DIR"
META="$TMP_DIR/meta"
PROJECT="$TMP_DIR/project"
mkdir -p "$META/application/knowledge" "$PROJECT/docs" "$TMP_DIR/bin"
git -C "$META" init -q
git -C "$META" remote add origin https://example.com/meta.git
printf '# template\n' >"$META/application/knowledge/file.md"
printf '# readme\n' >"$META/application/README.md"
cat >"$TMP_DIR/bin/cp" <<'SH'
#!/usr/bin/env bash
case "$1" in */meta/application/*) printf 'injected-copy-failure\n' >&2; exit 73 ;; esac
exec /bin/cp "$@"
SH
chmod +x "$TMP_DIR/bin/cp"
if PATH="$TMP_DIR/bin:$PATH" "$BASH" "$DOCS_INSTALL_SCRIPT" --meta "$META" --target "$PROJECT/docs" >"$TMP_DIR/out" 2>&1; then
  fail '模板复制失败必须返回非零'
fi
assert_contains 'injected-copy-failure' "$TMP_DIR/out"
[[ ! -e "$PROJECT/.docsconfig" ]] || fail '复制失败不应继续写配置'
assert_not_contains '完成：docs-install' "$TMP_DIR/out"
pass '真实复制错误传播，不宣称成功或继续写配置'
