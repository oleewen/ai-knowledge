#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
source "$ROOT_DIR/agent/scripts/docs-core.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/ws/owner/docs" "$TMP/agent" "$TMP/outside"
printf 'AGENT_ROOT=%s\nAGENT_DIR=agent\n' "$TMP" > "$TMP/ws/owner/.docsconfig"
printf 'WORK_SPACE=%s\n' "$TMP/ws" > "$TMP/agent/configs"
links="$TMP/ws/owner/docs/knowledge-links.yaml"
expected="$(cd "$TMP/ws" && pwd -P)/repo with space"
actual="$(WORK_SPACE=/wrong knowledge_link_expand_stored_path '${WORK_SPACE}/repo with space' "$links")"
[[ "$actual" == "$expected" ]] || { printf 'FAIL: expected %s, got %s\n' "$expected" "$actual"; exit 1; }
[[ "$(knowledge_link_stored_path_from_absolute "$expected" "$links")" == '${WORK_SPACE}/repo with space' ]]
for invalid in "$expected" '~/workspaces/repo' '${WORK_SPACE}/../outside' '${WORK_SPACE}/../../outside' '$OTHER/repo'; do
  if (knowledge_link_expand_stored_path "$invalid" "$links") >/dev/null 2>&1; then
    printf 'FAIL: accepted %s\n' "$invalid"; exit 1
  fi
done
ln -s "$TMP/outside" "$TMP/ws/escape"
if (knowledge_link_expand_stored_path '${WORK_SPACE}/escape/missing/repo' "$links") >/dev/null 2>&1; then
  printf 'FAIL: symlink escaped workspace\n'; exit 1
fi
if (knowledge_link_stored_path_from_absolute "$TMP/ws-other/repo" "$links") >/dev/null 2>&1; then
  printf 'FAIL: accepted sibling prefix\n'; exit 1
fi
printf 'AGENT_ROOT=%s\nAGENT_DIR=absent\n' "$TMP" > "$TMP/ws/owner/.docsconfig"
if (WORK_SPACE="$TMP/ws" knowledge_link_expand_stored_path '${WORK_SPACE}/repo' "$links") >/dev/null 2>&1; then
  printf 'FAIL: environment bypassed missing configs\n'; exit 1
fi
printf 'PASS: workspace path contract\n'
