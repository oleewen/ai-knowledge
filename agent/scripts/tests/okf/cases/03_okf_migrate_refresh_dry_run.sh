#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Agent 树装在 repo/.agents；DOC_DIR/.agents 软链指向它（契约：DOC_DIR/AGENT_DIR）
mkdir -p "$TMP/repo/.agents/skills/docs-okf/scripts"
cp "$ROOT/agent/skills/docs-okf/scripts/resolve-okf-paths.sh" \
  "$TMP/repo/.agents/skills/docs-okf/scripts/resolve-okf-paths.sh"
cp "$ROOT/agent/skills/docs-okf/scripts/okf-indexing.sh" \
  "$TMP/repo/.agents/skills/docs-okf/scripts/okf-indexing.sh"
cp "$ROOT/agent/skills/docs-okf/scripts/okf-validate.sh" \
  "$TMP/repo/.agents/skills/docs-okf/scripts/okf-validate.sh"
cp "$ROOT/agent/skills/docs-okf/scripts/"*.py \
  "$TMP/repo/.agents/skills/docs-okf/scripts/"

mkdir -p "$TMP/repo/.agents/scripts"
cp "$ROOT/agent/scripts/docs-core.sh" "$TMP/repo/.agents/scripts/docs-core.sh"
cp -R "$ROOT/agent/scripts/lib" "$TMP/repo/.agents/scripts/lib"

mkdir -p "$TMP/repo/application"
ln -sfn ../.agents "$TMP/repo/application/.agents"

cat > "$TMP/repo/.docsconfig" <<EOF
DOC_ROOT=$TMP/repo/application
REPO_ROOT=$TMP/repo
DOC_DIR=application
KNOWLEDGE_TYPE=application
AGENT_ROOT=$TMP/repo
AGENT_DIR=.agents
EOF

mkdir -p "$TMP/repo/application/knowledge/business"
cat > "$TMP/repo/application/index.md" <<'EOF'
---
okf_version: "0.1"
---
# Root
EOF
cat > "$TMP/repo/application/knowledge/index.md" <<'EOF'
# 知识索引
EOF
cat > "$TMP/repo/application/knowledge/business/index.md" <<'EOF'
# business
EOF

OKF_SH="$TMP/repo/application/.agents/skills/docs-okf/scripts/okf-indexing.sh"
output="$(cd "$TMP/repo" && bash "$OKF_SH" --dry-run)"
printf '%s\n' "$output"

[[ "$output" == *"inject_frontmatter"* ]]
[[ "$output" == *"generate_index"* ]]
[[ "$output" != *"generate_knowledge_index"* ]]
[[ "$output" == *"visualize"* ]]
[[ "$output" == *"validate-okf"* ]]
[[ "$output" == *"validate-viz-index"* ]]
[[ "$output" != *"migrate_entities"* ]]
[[ "$output" == *"OKF_SCRIPTS:"* ]]
[[ "$output" == *"/application/.agents/skills/docs-okf/scripts"* ]]

echo "[OK] okf-migrate dry-run uses refresh pipeline (no knowledge-index step)"
