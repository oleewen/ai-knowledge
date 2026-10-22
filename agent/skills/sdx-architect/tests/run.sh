#!/usr/bin/env bash
set -euo pipefail

# 行为回归：只在系统临时目录准备样例，逐次检查被校验工程未发生写入。
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALIDATOR="${SCRIPT_DIR}/../scripts/validate-asd.sh"
source "${SCRIPT_DIR}/../../../scripts/lib/bash.sh"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/sdx-architect-test.XXXXXX")"
PASSED=0
FAILED=0
CASE_REPO=''
CASE_CWD=''
OUTPUT=''
STATUS=0

new_case() {
  local name="$1" kind="${2:-application}"
  CASE_REPO="${TEST_ROOT}/${name}/repo space"
  CASE_CWD="$CASE_REPO"
  mkdir -p "$CASE_REPO/docs/requirements" "${TEST_ROOT}/${name}/agent"
  printf 'WORK_SPACE=%s\n' "${TEST_ROOT}/${name}" >"${TEST_ROOT}/${name}/agent/configs"
  cat >"$CASE_REPO/.docsconfig" <<EOF
AGENT_ROOT=${TEST_ROOT}/${name}
AGENT_DIR=agent
REPO_DIR=repo space
DOC_DIR=docs
KNOWLEDGE_TYPE=${kind}
EOF
}

write_valid() {
  cat >"${1:-$CASE_REPO/docs/requirements/ASD-CASE-1.md}" <<'EOF'
---
id: "ASD-CASE-1"
title: "测试架构"
version: "1.0.0"
status: "draft"
created: "2026-10-22"
updated: "2026-10-22"
author: "architect"
reviewers: []
parent: "PRD-CASE-1"
mvp_phase: "MVP-Phase-1"
---
# 架构设计
## 1. 设计概述
### 1.1 设计目标
关联 PRD-CASE-1。
### 1.2 设计约束
复用已确认的服务边界。
### 1.3 关键设计决策
| 决策编号 | 决策结果 |
| --- | --- |
| DD-001 | 复用现有服务 |
## 2. 架构设计
### 2.1 系统架构设计
服务边界和交互见当前段。
## 3. 需求规约
### 3.1 需求规约摘要
| 应用 | 规约文件 | 规约描述 |
| --- | --- | --- |
| APP-CASE | ./specs/spec-asd-CASE-1-app.md | 账户能力 |
EOF
}

snapshot() {
  local path
  while IFS= read -r -d '' path; do
    ls -ld "$path"
    if [[ -f "$path" && -r "$path" ]]; then cksum "$path"; fi
  done < <(find "$(dirname "$CASE_REPO")" -print0 2>/dev/null)
}

check() {
  local name="$1" expected="$2" pattern="$3" before after
  shift 3
  before="$(snapshot)"
  if OUTPUT="$(cd "$CASE_CWD" && "$BASH" "$VALIDATOR" "$@" 2>&1)"; then STATUS=0; else STATUS=$?; fi
  after="$(snapshot)"
  if [[ "$STATUS" == "$expected" && "$OUTPUT" == *"$pattern"* && "$before" == "$after" ]]; then
    printf 'PASS %s\n' "$name"
    PASSED=$((PASSED + 1))
  else
    printf 'FAIL %s (exit=%s，期望=%s；关键输出=%s)\n%s\n' "$name" "$STATUS" "$expected" "$pattern" "$OUTPUT"
    [[ "$before" == "$after" ]] || printf 'FAIL 校验器修改了输入工程\n'
    FAILED=$((FAILED + 1))
  fi
}

new_case baseline
write_valid
check '完整样例及空格路径' 0 '错误: 0  警告: 0' --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '完整样例严格模式' 0 '校验通过' --strict --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
CASE_CWD="$CASE_REPO/docs/requirements"
check '子目录相对路径' 0 '错误: 0  警告: 0' --file ASD-CASE-1.md
CASE_CWD="$TEST_ROOT"
check '帮助无需工程配置' 0 '--strict' --help
check '缺失参数值' 2 '--file 需要非空文件路径' --file
check '空参数值' 2 '--file 需要非空文件路径' --file ''
check '参数被下一选项占用' 2 '--file 需要非空文件路径' --file --strict
check '未知参数' 2 '未知参数' --unknown
check '重复文件参数' 2 '--file 不可重复指定' --file first.md --file second.md
check '校验仍要求配置' 1 '未找到当前工程的 .docsconfig' --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"

new_case crlf
write_valid
sed 's/$/\r/' "$CASE_REPO/docs/requirements/ASD-CASE-1.md" >"$CASE_REPO/docs/crlf.md"
cp "$CASE_REPO/docs/crlf.md" "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check 'CRLF' 0 '错误: 0  警告: 0' --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"

new_case empty
printf '%s\n' '---' '---' >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '警告默认保持成功退出' 0 '存在警告' --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '严格模式拒绝空结构' 1 '缺少章节' --strict --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"

new_case fenced
write_valid "$CASE_REPO/docs/original.md"
awk 'NR <= 13 {print; next} NR == 14 {print "```markdown"} {print} END {print "```"}' "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '代码围栏中的标题不算章节' 0 "缺少章节 '## 1. 设计概述'" --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
sed 's/```/~~~~/g' "$CASE_REPO/docs/requirements/ASD-CASE-1.md" >"$CASE_REPO/docs/tilde.md"
cp "$CASE_REPO/docs/tilde.md" "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '波浪线围栏中的标题不算章节' 1 '缺少章节' --strict --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"

new_case comments
write_valid "$CASE_REPO/docs/original.md"
awk 'NR <= 13 {print; next} NR == 14 {print "<!--"} {print} END {print "-->"}' "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check 'HTML 注释中的标题不算章节' 0 '缺少章节' --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
sed 's/^## 1\. /<!-- note -->## 1. /' "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '剥除行首注释不能制造标题' 1 "缺少章节 '## 1. 设计概述'" --strict --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"

new_case heading_depth
write_valid "$CASE_REPO/docs/original.md"
sed 's/^## 1\. /#### 1. /; s/^## 2\. /正文 ## 2. /' "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '标题层级与行首必须准确' 0 "缺少章节 '## 1. 设计概述'" --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"

new_case metadata
write_valid "$CASE_REPO/docs/original.md"
for field in id title version status created updated author parent mvp_phase; do
  sed "s/^${field}:.*/${field}: \"\"/" "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
  check "空元数据 ${field}" 0 "${field} 为空" --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
done
sed 's/^id:.*/id: "ASD-OTHER-1"/' "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check 'ID 与文件名一致' 0 'id 与文件名不一致' --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
sed 's/^parent:.*/parent: "PRD-OTHER-1"/' "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check 'parent 同需求链' 0 'parent 应为 PRD-CASE-1' --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
sed 's/^mvp_phase:.*/mvp_phase: "MVP-Phase-2"/' "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check 'mvp_phase 同阶段' 0 'mvp_phase 应为 MVP-Phase-1' --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
sed 's/^title:.*/title: [unterminated/' "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '非模板元数据表达需人工核对' 0 '需人工核对' --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
awk '/^reviewers:/ {print "reviewers:"; print "  - architect"; next} {print}' "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check 'reviewers 多行列表' 0 '错误: 0  警告: 0' --strict --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
sed "s/\"/'/g" "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '单引号元数据' 0 '错误: 0  警告: 0' --strict --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
sed 's/^id:.*/id: "ASD-CASE-1" # 来源 "已确认"/' "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '双引号标量不吞注释中的引号' 0 '错误: 0  警告: 0' --strict --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
sed "s/^id:.*/id: 'ASD-CASE-1' # 来源 '已确认'/" "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '单引号标量不吞注释中的引号' 0 '错误: 0  警告: 0' --strict --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
awk '/^reviewers:/ {print "reviewers:"; next} {print}' "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '空 reviewers 不等同空列表' 0 'reviewers 为空' --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
awk '/^title:/ {print "title: |"; print "  合法的多行标题"; next} {print}' "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '非链字段允许多行文本' 0 '错误: 0  警告: 0' --strict --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
sed 's/^parent:.*/parent: PRD-CASE-1 # 关联需求/' "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '裸标量尾部注释' 0 '错误: 0  警告: 0' --strict --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
awk '/^id:/ {print} {print}' "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '重复元数据不静默覆盖' 0 'id 重复' --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"

new_case fence_info
write_valid "$CASE_REPO/docs/original.md"
awk '/^## 1\./ {print "~~~```"; print "代码示例"; print "~~~"} {print}' "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '波浪线围栏信息串可含反引号' 0 '错误: 0  警告: 0' --strict --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
awk '/^## 1\./ {print ""; print "    <!-- 示例代码中的注释起点"; print ""} {print}' "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '缩进代码中的注释不影响后续正文' 0 '错误: 0  警告: 0' --strict --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
awk '/^## 1\./ {print "示例：`<!--` 是注释起点。"; print ""} {print}' "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '行内代码中的注释不影响后续正文' 0 '错误: 0  警告: 0' --strict --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
awk '/^## 1\./ {print "```html <!-- 示例"; print "代码"; print "```"; print ""} {print}' "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '围栏信息串中的注释不影响后续正文' 0 '错误: 0  警告: 0' --strict --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
awk '/^## 1\./ {print "```术语示例```"; print ""} {print}' "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '行首三反引号行内代码不是围栏' 0 '错误: 0  警告: 0' --strict --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"

new_case missing_decision
write_valid "$CASE_REPO/docs/original.md"
sed 's/| DD-001 |/| 待确认 |/' "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
printf '\n<!-- DD-999 -->\n```text\nDD-888\n```\n' >>"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check 'DD 必须出现于可见正文' 0 '未发现设计决策编号' --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"

new_case summary
write_valid "$CASE_REPO/docs/original.md"
awk '/^### 3\.1 / {print $0 " <!-- 摘要标题 -->"; next} /^\|/ {sub(/^\|[ ]*/, ""); sub(/[ ]*\|$/, "")} {print}' "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '摘要表可省略外管道且标题可带尾注释' 0 '错误: 0  警告: 0' --strict --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
sed '/^| APP-CASE /d' "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '摘要表必须有数据行' 0 '规约摘要表缺少数据行' --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
awk '/^\| APP-CASE / {print "```text"; print "示例代码"; print "```"} {print}' "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '围栏两侧管道行不能拼成摘要表' 1 '规约摘要表缺少数据行' --strict --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
awk '/^\| APP-CASE / {print "    示例代码"} {print}' "$CASE_REPO/docs/original.md" >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '缩进代码两侧管道行不能拼成摘要表' 1 '规约摘要表缺少数据行' --strict --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"

new_case system system
write_valid
check 'system 概要只要求原五小节' 0 '错误: 0  警告: 0' --strict --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
sed 's@./specs/spec-asd-CASE-1-app.md@后续补充@' "$CASE_REPO/docs/requirements/ASD-CASE-1.md" >"$CASE_REPO/docs/no-pointer.md"
cp "$CASE_REPO/docs/no-pointer.md" "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
printf '\n<!-- spec-asd-HIDDEN-1-app.md -->\n' >>"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check 'system 需要可见下游文件指针' 0 '未发现下游承接指针' --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"

for kind in solution company; do
  new_case "$kind" "$kind"
  write_valid
  check "拒绝 ${kind} 库写 ASD" 1 '不支持 ASD' --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
done

new_case no_files
check '空扫描默认不失败' 0 '未找到 ASD 文档'
check '空扫描严格模式不冒充完成' 1 '未找到 ASD 文档' --strict
check '不存在的显式文件' 1 '指定文件不存在' --file missing.md

new_case missing_directory
printf '\nDOC_DIR=missing\n' >>"$CASE_REPO/.docsconfig"
check '文档目录缺席默认警告' 0 'requirements/ 目录不存在'
check '文档目录缺席严格失败' 1 'requirements/ 目录不存在' --strict

new_case unreadable
write_valid
chmod a-r "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
if [[ ! -r "$CASE_REPO/docs/requirements/ASD-CASE-1.md" ]]; then
  check '不可读文件是错误' 1 '无法读取文件' --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
else
  printf 'SKIP 当前用户可绕过文件读取权限\n'
fi
chmod u+r "$CASE_REPO/docs/requirements/ASD-CASE-1.md"

new_case scan_failure
write_valid
mkdir "$CASE_REPO/docs/requirements/hidden"
chmod a-r "$CASE_REPO/docs/requirements/hidden"
if [[ ! -r "$CASE_REPO/docs/requirements/hidden" ]]; then
  check 'find 读取失败必须传播' 1 '无法完整扫描目录'
else
  printf 'SKIP 当前用户可绕过目录读取权限\n'
fi
chmod u+r "$CASE_REPO/docs/requirements/hidden"

new_case unclosed
printf '%s\n' '---' 'id: ASD-CASE-1' >"$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '未闭合 frontmatter 是错误' 1 'frontmatter 未闭合' --file "$CASE_REPO/docs/requirements/ASD-CASE-1.md"

new_case aggregate
write_valid
printf '无 frontmatter\n' >"$CASE_REPO/docs/requirements/ASD-BROKEN-1.md"
check '多文件扫描汇总错误' 1 '错误: 1'
check '多文件扫描仍处理正常文件' 1 'ASD-CASE-1.md'

new_case valid_symlink
write_valid "$CASE_REPO/docs/original.md"
ln -s ../original.md "$CASE_REPO/docs/requirements/ASD-CASE-1.md"
check '扫描包含有效 ASD 文件软链' 0 '错误: 0  警告: 0' --strict

new_case broken_symlink
write_valid
ln -s missing.md "$CASE_REPO/docs/requirements/ASD-BROKEN-1.md"
check '正常文件不能掩盖失效 ASD 文件软链' 1 '失效文件软链' --strict

printf '\n结果: %s 通过，%s 失败；fixture: %s\n' "$PASSED" "$FAILED" "$TEST_ROOT"
[[ "$FAILED" -eq 0 ]]
