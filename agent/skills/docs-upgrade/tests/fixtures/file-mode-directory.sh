#!/usr/bin/env bash
# 创建供 Agent 文件模式评测使用的真实两侧目录；拒绝覆盖已有内容。
set -euo pipefail

[[ $# -eq 1 ]] || { printf 'Usage: %s EMPTY_OUTPUT_DIR\n' "$0" >&2; exit 2; }
fixture_output="$1"
if [[ -e "$fixture_output" || -L "$fixture_output" ]]; then
  [[ -d "$fixture_output" && ! -L "$fixture_output" ]] \
    || { printf '输出必须是普通空目录: %s\n' "$fixture_output" >&2; exit 1; }
  [[ -z "$(find "$fixture_output" -mindepth 1 -maxdepth 1 -print -quit)" ]] \
    || { printf '拒绝覆盖非空目录: %s\n' "$fixture_output" >&2; exit 1; }
fi
mkdir -p "$fixture_output"
fixture_root="$(cd "$fixture_output" && pwd -P)"
fixture_project="$fixture_root/project"
fixture_docs="$fixture_project/docs"
fixture_meta="$fixture_root/meta/company"
mkdir -p \
  "$fixture_docs/knowledge/business/BL" \
  "$fixture_docs/knowledge/product" \
  "$fixture_meta/knowledge/business/BL" \
  "$fixture_meta/knowledge/business/BD/BD-EXAMPLE" \
  "$fixture_root/agent-home/.agents"

cat >"$fixture_project/.docsconfig" <<EOF
REPO_DIR=project
DOC_DIR=docs
AGENT_ROOT=$fixture_root/agent-home
AGENT_DIR=.agents
KNOWLEDGE_TYPE=company
EOF
printf 'WORK_SPACE=%s\n' "$fixture_root" >"$fixture_root/agent-home/.agents/configs"
cat >"$fixture_docs/knowledge-links.yaml" <<'EOF'
links:
  - type: meta
    path: '${WORK_SPACE}/meta'
    dir: company
EOF
cat >"$fixture_docs/DESIGN.md" <<'EOF'
---
version: 2026.1020.1
---
# 本库设计
EOF
cat >"$fixture_meta/DESIGN.md" <<'EOF'
---
version: 2026.1021.0
---
# 元库设计
EOF
cat >"$fixture_docs/knowledge/business/README.md" <<'EOF'
# 业务导航

### 能力边界

本库业务正文：零售能力已确认。
EOF
cat >"$fixture_meta/knowledge/business/README.md" <<'EOF'
# 业务导航

## 能力边界

模板正文：填写能力范围。
EOF
cat >"$fixture_docs/knowledge/business/BL/BL-RETAIL.md" <<'EOF'
# 零售业务线

## 职责

保留此真实业务实例。
EOF
cat >"$fixture_meta/knowledge/business/BL/BL-EXAMPLE.md" <<'EOF'
# 业务线示例

## 职责

填写业务线职责。
EOF
cat >"$fixture_meta/knowledge/business/BD/BD-EXAMPLE/BD-EXAMPLE.md" <<'EOF'
# 业务域示例

## 边界

填写业务域边界。
EOF
cat >"$fixture_meta/knowledge/business/BD/BD-EXAMPLE/index.md" <<'EOF'
# 业务域索引

- [业务域示例](BD-EXAMPLE.md)
EOF
cat >"$fixture_docs/knowledge/product/outside.md" <<'EOF'
# 选区外知识

本轮不得修改。
EOF
printf '%s\n' "$fixture_root"
