#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$TEST_DIR/.." && pwd)"
AGENT_HOME="$(cd "$SKILL_DIR/../.." && pwd)"
source "$AGENT_HOME/scripts/lib/bash.sh"

TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/sdx-analysis-tests.XXXXXX")"
REPO="$TEST_ROOT/project"
DOC="$REPO/docs"
SCRIPT="$SKILL_DIR/scripts/validate-analysis.sh"
mkdir -p "$DOC/analysis" "$REPO/sub" "$TEST_ROOT/agent-root/agent"
printf 'WORK_SPACE=%s\n' "$TEST_ROOT" > "$TEST_ROOT/agent-root/agent/configs"
cat > "$REPO/.docsconfig" <<EOF
AGENT_ROOT=$TEST_ROOT/agent-root
AGENT_DIR=agent
REPO_DIR=project
DOC_DIR=docs
KNOWLEDGE_TYPE=application
EOF

# Integration fixture follows the real template; each case mutates one behavior.
BASE="$DOC/analysis/ANALYSIS-BASE-1.md"
cat > "$BASE" <<'EOF'
---
id: ANALYSIS-BASE-1
title: 已确认的业务需求
version: 1.0.0
status: draft
created: 2026-10-22
updated: 2026-10-22
author: test
parent: ""
dependencies: []
tags: []
---
EOF
awk '/^#{2,4} / { print; print "业务内容已确认。"; if ($0 ~ /^### 1[.]3 /) print "G-1 降低处理时长。"; if ($0 ~ /^### 6[.]1 /) print "M1（试点）" }' \
  "$SKILL_DIR/assets/analysis-template.md" >> "$BASE"

PASS=0
FAIL=0
OUTPUT=''
STATUS=0
run() {
  local directory="$1"
  shift
  STATUS=0
  OUTPUT="$(cd "$directory" && "$BASH" "$SCRIPT" "$@" 2>&1)" || STATUS=$?
}
check() {
  local name="$1" expected="$2" pattern="${3:-}" excluded="${4:-}"
  if [[ "$STATUS" -eq "$expected" ]] &&
    { [[ -z "$pattern" ]] || [[ "$OUTPUT" == *"$pattern"* ]]; } &&
    { [[ -z "$excluded" ]] || [[ "$OUTPUT" != *"$excluded"* ]]; }; then
    printf '[PASS] %s\n' "$name"
    PASS=$((PASS + 1))
  else
    printf '[FAIL] %s: expected=%s actual=%s\n%s\n' "$name" "$expected" "$STATUS" "$OUTPUT"
    FAIL=$((FAIL + 1))
  fi
}
variant() {
  FILE="$DOC/analysis/ANALYSIS-$1.md"
  sed "s/id: ANALYSIS-BASE-1/id: ANALYSIS-$1/" "$BASE" > "$FILE"
}

run "$REPO" --file "$BASE"
check 'complete document passes' 0 '错误: 0  警告: 0'
EMPTY="$DOC/analysis/ANALYSIS-EMPTY-FILE.md"
: > "$EMPTY"
run "$REPO" --file "$EMPTY"
check 'empty file fails even without strict mode' 1 '缺少文首'
run "$REPO" --strict --file "$BASE"
check 'strict complete document passes' 0 '错误: 0  警告: 0'
run "$TEST_ROOT" --help
check 'help needs no configuration' 0 '--strict'
run "$REPO" --file
check 'missing value is a CLI error' 2 '缺少' 'unbound variable'
run "$REPO" --unknown
check 'unknown option is a CLI error' 2 '未知参数'
run "$REPO/sub" --file ../docs/analysis/ANALYSIS-BASE-1.md
check 'file path uses caller cwd' 0 '错误: 0  警告: 0'

variant COMMENT-1
{ sed -n '1,12p' "$FILE"; printf '<!--\n'; sed -n '13,$p' "$FILE"; printf '%s\n' '-->'; } > "$FILE.tmp"
cp "$FILE.tmp" "$FILE"
run "$REPO" --file "$FILE"
check 'comment headings cannot satisfy structure' 0 '缺少章节'
run "$REPO" --strict --file "$FILE"
check 'strict warnings fail' 1 '缺少章节'

variant FENCE-1
{ sed -n '1,12p' "$FILE"; printf '\140\140\140markdown\n'; sed -n '13,$p' "$FILE"; printf '\140\140\140\n'; } > "$FILE.tmp"
cp "$FILE.tmp" "$FILE"
run "$REPO" --file "$FILE"
check 'fenced headings cannot satisfy structure' 0 '缺少章节'

variant EMPTY-1
awk 'NR <= 12 || /^#{2,4} /' "$FILE" > "$FILE.tmp"
cp "$FILE.tmp" "$FILE"
run "$REPO" --file "$FILE"
check 'headings alone are empty' 0 '无内容'

variant TECH-1
sed '/^### 7[.]3 /a\
Redis（待研发确认）
' "$FILE" > "$FILE.tmp"
cp "$FILE.tmp" "$FILE"
run "$REPO" --strict --file "$FILE"
check 'internal technical references are allowed' 0 '错误: 0  警告: 0'
printf '<!--\nRedis\n-->\n' >> "$FILE"
run "$REPO" --strict --file "$FILE"
check 'multiline comments are ignored' 0 '错误: 0  警告: 0'
printf '\nRedis\n' >> "$FILE"
run "$REPO" --file "$FILE"
check 'business technical wording warns' 0 '技术词'

variant ID-1
sed 's/id: ANALYSIS-ID-1/id: XXX-ANALYSIS-ID-1/' "$FILE" > "$FILE.tmp"
cp "$FILE.tmp" "$FILE"
run "$REPO" --file "$FILE"
check 'id must equal filename' 0 'id 与文件名不一致'
variant STATUS-1
sed 's/status: draft/status: disapproved/' "$FILE" > "$FILE.tmp"
cp "$FILE.tmp" "$FILE"
run "$REPO" --file "$FILE"
check 'status is an exact enum' 0 'status 值异常'
variant QUOTED-1
sed 's/title: 已确认的业务需求/title: "业务 # 1"/' "$FILE" > "$FILE.tmp"
cp "$FILE.tmp" "$FILE"
run "$REPO" --strict --file "$FILE"
check 'quoted scalar may contain a hash' 0 '错误: 0  警告: 0'
for scalar_value in '[]' '{}' '|' '>' 'null' 'NULL' '~' '# 待补充'; do
  variant SCALAR-1
  awk -v value="$scalar_value" '/^title:/ { print "title: " value; next } { print }' "$FILE" > "$FILE.tmp"
  cp "$FILE.tmp" "$FILE"
  run "$REPO" --strict --file "$FILE"
  check "required scalar rejects $scalar_value" 1 '元字段为空或不是单行标量: title'
done
variant QUOTED-NULL-1
sed 's/title: 已确认的业务需求/title: "null"/' "$FILE" > "$FILE.tmp"
cp "$FILE.tmp" "$FILE"
run "$REPO" --strict --file "$FILE"
check 'quoted null remains a nonempty string' 0 '错误: 0  警告: 0'
variant UNCLOSED-1
sed '12d' "$FILE" > "$FILE.tmp"
cp "$FILE.tmp" "$FILE"
run "$REPO" --file "$FILE"
check 'unclosed frontmatter fails' 1 '未闭合'
variant TABLE-1
awk '/^### 1[.]1 / { print; print "| 原因 | 影响 |\n| --- | --- |\n| | |"; skip=1; next } skip { skip=0; next } { print }' "$FILE" > "$FILE.tmp"
cp "$FILE.tmp" "$FILE"
run "$REPO" --file "$FILE"
check 'empty table is not substantive content' 0 '无内容'
variant CODE-1
awk '/^### 3[.]3 / { print; print "```text\n<!-- literal inside a code block\n```"; next } { print }' "$FILE" > "$FILE.tmp"
cp "$FILE.tmp" "$FILE"
run "$REPO" --strict --file "$FILE"
check 'code comments do not swallow following sections' 0 '错误: 0  警告: 0'
variant NO-NEWLINE-1
awk 'NR > 1 { print previous } { previous=$0 } END { printf "%s", previous }' "$FILE" > "$FILE.tmp"
cp "$FILE.tmp" "$FILE"
run "$REPO" --strict --file "$FILE"
check 'final line does not require newline' 0 '错误: 0  警告: 0'
variant MILESTONE-1
sed 's/M1（试点）/已确认。/' "$FILE" > "$FILE.tmp"
cp "$FILE.tmp" "$FILE"
printf '\nM1（附录示例）\n' >> "$FILE"
run "$REPO" --file "$FILE"
check 'milestone must be in section 6.1' 0 '未发现 M{n}'

mkdir -p "$DOC/adr" "$DOC/analysis/nested"
printf '| 分类 | 决策编号 |\n| --- | --- |\n| 模块 | ADR-10 |\n' > "$DOC/adr/CONTEXT.md"
printf '# ADR-1\n' > "$DOC/adr/ADR-1-test.md"
variant ADR-1
printf '\n[CONTEXT](../adr/CONTEXT.md)\nADR-1\n' >> "$FILE"
run "$REPO" --file "$FILE"
check 'ADR-10 cannot register ADR-1' 0 'CONTEXT 未登记 ADR-1'
printf '| 模块 | ADR-1 |\n' >> "$DOC/adr/CONTEXT.md"
sed 's@(../adr/CONTEXT.md)@(../../adr/CONTEXT.md)@' "$FILE" > "$DOC/analysis/nested/ANALYSIS-ADR-1.md"
run "$REPO" --strict --file "$DOC/analysis/nested/ANALYSIS-ADR-1.md"
check 'nested analysis uses configured ADR root' 0 '错误: 0  警告: 0'
cp "$DOC/adr/CONTEXT.md" "$TEST_ROOT/context-before-column-tests.md"
printf '| 分类 | 决策编号 | 决策要点 |\n| --- | --- | --- |\n| 模块 | ADR-2 | 替代 ADR-1 的方案 |\n' > "$DOC/adr/CONTEXT.md"
run "$REPO" --strict --file "$FILE"
check 'ADR mentions outside the decision ID column do not register it' 1 'CONTEXT 未登记 ADR-1'
printf '| 决策要点 | **决策编号** | 分类 |\n| --- | --- | --- |\n| 方案 | **[ADR-1](ADR-1-test.md)** | 模块 |\n' > "$DOC/adr/CONTEXT.md"
run "$REPO" --strict --file "$FILE"
check 'decision ID column supports reordered columns and Markdown labels' 0 '错误: 0  警告: 0'
cp "$TEST_ROOT/context-before-column-tests.md" "$DOC/adr/CONTEXT.md"
variant 中文ADR-1
printf '\n**技术决策索引**：[CONTEXT](../adr/CONTEXT.md)；复用已确认的 [ADR-1：审批事件留痕](../adr/ADR-1-审批事件留痕.md)。\n' >> "$FILE"
printf '# ADR-1：审批事件留痕\n' > "$DOC/adr/ADR-1-审批事件留痕.md"
run "$REPO" --strict --file "$FILE"
check 'Chinese text around multiple ADR links does not crash awk' 0 '错误: 0  警告: 0'
variant 中文里程碑-1
sed 's/M1（试点）/M1（审批上线）/' "$FILE" > "$FILE.tmp"
cp "$FILE.tmp" "$FILE"
LC_ALL=C run "$REPO" --strict --file "$FILE"
check 'Chinese milestone works with byte-oriented awk matching' 0 '错误: 0  警告: 0'
variant BAD-LINK-1
printf '\n[CONTEXT](../missing/CONTEXT.md)\nADR-1\n' >> "$FILE"
run "$REPO" --strict --file "$FILE"
check 'context link must resolve to the configured ledger' 1 '未有效链接'
mkdir -p "$DOC/other"
cp "$DOC/adr/CONTEXT.md" "$DOC/other/CONTEXT.md"
variant WRONG-LEDGER-1
printf '\n[CONTEXT](../other/CONTEXT.md)\nADR-1\n' >> "$FILE"
run "$REPO" --strict --file "$FILE"
check 'a different existing context file does not satisfy the link' 1 '未有效链接'
variant TITLED-LINK-1
printf '\n[CONTEXT](../adr/CONTEXT.md "技术决策索引")\nADR-1\n' >> "$FILE"
run "$REPO" --strict --file "$FILE"
check 'context link accepts an optional title' 0 '错误: 0  警告: 0'
variant REF-LINK-1
printf '\n[技术决策索引][ledger]\nADR-1\n\n[ledger]: ../adr/CONTEXT.md "技术决策索引"\n' >> "$FILE"
run "$REPO" --strict --file "$FILE"
check 'context link accepts a reference definition' 0 '错误: 0  警告: 0'
variant UNUSED-REF-1
printf '\nADR-1\n\n[ledger]: ../adr/CONTEXT.md\n' >> "$FILE"
run "$REPO" --strict --file "$FILE"
check 'unused reference definition is not a link' 1 '未有效链接'

variant ORDER-1
printf '\n## 1. 背景与目标\n业务内容。\n' >> "$FILE"
run "$REPO" --file "$FILE"
check 'duplicate headings warn' 0 '重复标题'
variant CRLF-1
awk '{ printf "%s\r\n", $0 }' "$FILE" > "$FILE.tmp"
cp "$FILE.tmp" "$FILE"
run "$REPO" --strict --file "$FILE"
check 'CRLF document passes' 0 '错误: 0  警告: 0'

mkdir -p "$REPO/agent/skills/sdx-analysis" "$REPO/agent/scripts/lib"
cp -R "$SKILL_DIR/scripts" "$SKILL_DIR/assets" "$REPO/agent/skills/sdx-analysis/"
cp "$AGENT_HOME/scripts/lib/"{docsconfig,docsconfig-fields,docsconfig-workspace,docsconfig-store,backup,path,bash}.sh "$REPO/agent/scripts/lib/"
ORIGINAL_SCRIPT="$SCRIPT"
SCRIPT='../agent/skills/sdx-analysis/scripts/validate-analysis.sh'
run "$REPO/sub" --strict --file ../docs/analysis/ANALYSIS-BASE-1.md
check 'relative installed entrypoint works' 0 '错误: 0  警告: 0'
SCRIPT="$ORIGINAL_SCRIPT"

# 权限故障使用真实 find；root 无法制造不可读目录时显式跳过此环境用例。
mkdir -p "$REPO/scan/analysis/blocked"
cp "$BASE" "$REPO/scan/analysis/ANALYSIS-BASE-1.md"
sed 's/DOC_DIR=docs/DOC_DIR=scan/' "$REPO/.docsconfig" > "$REPO/.docsconfig.tmp"
cp "$REPO/.docsconfig.tmp" "$REPO/.docsconfig"
chmod 000 "$REPO/scan/analysis/blocked"
if [[ ! -r "$REPO/scan/analysis/blocked" || ! -x "$REPO/scan/analysis/blocked" ]]; then
  run "$REPO" --strict
  check 'strict scan fails when a subtree is unreadable despite valid files' 1 '目录扫描失败'
  run "$REPO"
  check 'default scan also fails on traversal errors' 1 '目录扫描失败'
else
  printf '[SKIP] 当前用户可绕过目录权限，无法构造不可读子目录\n'
fi
chmod 700 "$REPO/scan/analysis/blocked"
sed 's/DOC_DIR=scan/DOC_DIR=docs/' "$REPO/.docsconfig" > "$REPO/.docsconfig.tmp"
cp "$REPO/.docsconfig.tmp" "$REPO/.docsconfig"

sed 's/DOC_DIR=docs/DOC_DIR=empty/' "$REPO/.docsconfig" > "$REPO/.docsconfig.tmp"
cp "$REPO/.docsconfig.tmp" "$REPO/.docsconfig"
run "$REPO"
check 'no documents remains a successful default no-op' 0 '未找到'
run "$REPO" --strict
check 'strict mode cannot pass with no documents' 1 '未找到'

printf '\npassed=%s failed=%s\n临时证据: %s\n' "$PASS" "$FAIL" "$TEST_ROOT"
[[ "$FAIL" -eq 0 ]]
