#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
SRC="$TMP/ws/company"
TGT="$TMP/ws/narrow/solution"
mkdir -p "$SRC/docs/solution-slots" "$TGT/docs" "$TMP/src-agent" "$TMP/tgt-agent"
ln -s "$ROOT_DIR/agent/scripts" "$TMP/src-agent/scripts"
for repo in "$SRC" "$TGT"; do
  git -C "$repo" init -q
  git -C "$repo" remote add origin "https://example.com/$(basename "$repo").git"
  printf 'links: []\n' > "$repo/docs/knowledge-links.yaml"
done
printf 'AGENT_ROOT=%s\nAGENT_DIR=src-agent\nREPO_DIR=company\nDOC_DIR=docs\nKNOWLEDGE_TYPE=company\n' "$TMP" > "$SRC/.docsconfig"
printf 'WORK_SPACE=%s\n' "$TMP/ws" > "$TMP/src-agent/configs"
printf 'AGENT_ROOT=%s\nAGENT_DIR=tgt-agent\nREPO_DIR=solution\nDOC_DIR=docs\nKNOWLEDGE_TYPE=solution\n' "$TMP" > "$TGT/.docsconfig"
printf 'WORK_SPACE=%s\n' "$TMP/ws/narrow" > "$TMP/tgt-agent/configs"
cp "$SRC/docs/knowledge-links.yaml" "$TMP/source-before"
cp "$TGT/docs/knowledge-links.yaml" "$TMP/target-before"
if (cd "$SRC" && "$BASH" "$ROOT_DIR/agent/skills/docs-link/scripts/docs-link.sh" --link --target "$TGT") >"$TMP/out" 2>&1; then
  echo 'FAIL: target workspace must reject source'; exit 1
fi
grep -Fq WORK_SPACE "$TMP/out"
cmp "$TMP/source-before" "$SRC/docs/knowledge-links.yaml" || { echo 'FAIL: source modified before target validation'; exit 1; }
cmp "$TMP/target-before" "$TGT/docs/knowledge-links.yaml"
[[ ! -e "$SRC/docs/solution-slots/solution-solution" ]]
# 同一工作区，但目标清单仍含旧格式，也必须在建槽位前拒绝。
printf 'WORK_SPACE=%s\n' "$TMP/ws" > "$TMP/tgt-agent/configs"
mv "$TGT" "$TMP/ws/solution"
TGT="$TMP/ws/solution"
printf 'links:\n  - type: meta\n    path: "%s"\n    repository: "https://example.com/meta.git"\n' "$SRC" > "$TGT/docs/knowledge-links.yaml"
cp "$TGT/docs/knowledge-links.yaml" "$TMP/target-before"
if (cd "$SRC" && "$BASH" "$ROOT_DIR/agent/skills/docs-link/scripts/docs-link.sh" --link --target "$TGT") >"$TMP/out" 2>&1; then
  echo 'FAIL: accepted old target path'; exit 1
fi
grep -Fq WORK_SPACE "$TMP/out"
cmp "$TMP/source-before" "$SRC/docs/knowledge-links.yaml"
cmp "$TMP/target-before" "$TGT/docs/knowledge-links.yaml"
[[ ! -e "$SRC/docs/solution-slots/solution-solution" ]]
echo 'PASS: both sides validated before mutation'
