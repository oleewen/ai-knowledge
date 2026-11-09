#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
VALIDATE_SCRIPT="$ROOT/agent/skills/docs-okf/scripts/okf-validate.sh"
fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/project/docs/knowledge/business/VC-TEST" "$fixture/home/.agents"
ln -s "$ROOT/agent" "$fixture/project/docs/.agents"
printf 'WORK_SPACE=%s\n' "$fixture" >"$fixture/home/.agents/configs"
cat >"$fixture/project/.docsconfig" <<EOF
REPO_DIR=project
DOC_DIR=docs
KNOWLEDGE_TYPE=meta
AGENT_ROOT=$fixture/home
AGENT_DIR=.agents
EOF
cat >"$fixture/project/docs/index.md" <<'EOF'
---
okf_version: "0.1"
---
# Root
EOF
cat >"$fixture/project/docs/knowledge/business/VC-TEST/VC-TEST.md" <<'EOF'
---
type: Value Chain
title: Test
description: Fixture
tags: [business, VC]
timestamp: "2026-11-07T00:00:00+08:00"
id: VC-TEST
perspective: business
hierarchy: VC
layer_scope: company
---
<!-- markdownlint-disable-next-line MD025 -->
# Test

## 关系
- (none)
## 跨视角
- (none)
## 详细说明
Fixture.
## 依据与证据
待核实。
EOF
cd "$fixture/project"
if "$BASH" "$VALIDATE_SCRIPT" --bundle docs >"$fixture/missing-layer" 2>&1; then
  echo '元库缺少 --layer 应失败' >&2
  exit 1
fi
out="$("$BASH" "$VALIDATE_SCRIPT" --bundle docs --layer company 2>&1)" || {
  echo "$out"
  echo '受控有效 bundle 应无 FAIL' >&2
  exit 1
}
[[ "$out" == *INCOMPLETE* ]] || {
  echo "$out"
  echo '未执行事实核验不得宣称完整通过' >&2
  exit 1
}
echo '[OK] validate_bundle 显式逻辑层与分项状态'
