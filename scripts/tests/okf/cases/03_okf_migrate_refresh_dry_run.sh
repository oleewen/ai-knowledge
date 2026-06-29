#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/repo/agent/skills/docs-okf/scripts"
cp "$ROOT/agent/skills/docs-okf/scripts/resolve-okf-paths.sh" \
  "$TMP/repo/agent/skills/docs-okf/scripts/resolve-okf-paths.sh"

mkdir -p "$TMP/repo/agent/scripts"
cp "$ROOT/agent/scripts/config-bootstrap.sh" "$TMP/repo/agent/scripts/config-bootstrap.sh"
cp "$ROOT/agent/scripts/docs-core.sh" "$TMP/repo/agent/scripts/docs-core.sh"

mkdir -p "$TMP/repo/scripts/okf" "$TMP/repo/scripts"
cp "$ROOT/scripts/okf-migrate.sh" "$TMP/repo/scripts/okf-migrate.sh"

cat > "$TMP/repo/.docsconfig" <<EOF
DOC_ROOT=$TMP/repo/application
REPO_ROOT=$TMP/repo
DOC_DIR=application
KNOWLEDGE_TYPE=application
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

output="$(cd "$TMP/repo" && bash "$TMP/repo/scripts/okf-migrate.sh" --dry-run)"
printf '%s\n' "$output"

[[ "$output" == *"inject_frontmatter"* ]]
[[ "$output" == *"generate_index"* ]]
[[ "$output" == *"generate_knowledge_index"* ]]
[[ "$output" == *"visualize"* ]]
[[ "$output" == *"validate-okf"* ]]
[[ "$output" == *"validate-viz-index"* ]]
[[ "$output" != *"migrate_entities"* ]]

echo "[OK] okf-migrate dry-run uses refresh pipeline"
