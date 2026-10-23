#!/usr/bin/env bash
# 扫描器测试仅在自有消费仓运行，避免污染当前仓库。
TEST_SCRIPTS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$TEST_SCRIPTS_ROOT/test-core.sh"

new_scan_fixture() {
  local doc_dir="${1:-docs}"
  SCAN_TMP="$(mktemp -d)"
  SCAN_TMP="$(cd "$SCAN_TMP" && pwd -P)"
  trap 'rm -rf "$SCAN_TMP"' EXIT
  SCAN_REPO="$SCAN_TMP/workspace/project"
  mkdir -p "$SCAN_REPO/$doc_dir" "$SCAN_TMP/agent" "$SCAN_REPO/agent/scripts/tools"
  cp -R "$TEST_SCRIPTS_ROOT/lib" "$SCAN_REPO/agent/scripts/lib"
  cp "$TEST_SCRIPTS_ROOT/tools/forbidden-ref-outer.sh" "$SCAN_REPO/agent/scripts/tools/"
  printf 'WORK_SPACE=%s\n' "$SCAN_TMP/workspace" > "$SCAN_TMP/agent/configs"
  printf 'AGENT_ROOT=%s\nAGENT_DIR=agent\nREPO_DIR=project\nDOC_DIR=%s\nKNOWLEDGE_TYPE=application\n' \
    "$SCAN_TMP" "$doc_dir" > "$SCAN_REPO/.docsconfig"
}

named_spec_path() {
  # 分开日期组件，测试源码本身不能成为扫描器的违规样本。
  printf 'docs/superpowers/specs/%s-%s-%s-probe.md' 2026 01 01
}

run_scan_fixture() {
  SCAN_STATUS=0
  (cd "$SCAN_REPO" && "$BASH" agent/scripts/tools/forbidden-ref-outer.sh) \
    > "$SCAN_TMP/stdout" 2> "$SCAN_TMP/stderr" || SCAN_STATUS=$?
}
