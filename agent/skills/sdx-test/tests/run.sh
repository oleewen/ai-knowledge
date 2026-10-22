#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALIDATOR="$TEST_DIR/../scripts/validate-test.sh"
FIXTURE="$TEST_DIR/fixtures/TDD-TEST-1.md"
# shellcheck source=../../../scripts/test-core.sh
source "$TEST_DIR/../../../scripts/test-core.sh"
TEST_BASH="$(test_bash5_command)" || test_fail '未找到 Bash 5+ 运行器'
TEST_TMP="$(mktemp -d /tmp/sdx-test-tests.XXXXXX)"
trap 'rm -rf "$TEST_TMP"' EXIT
PASSED=0
FAILED=0

mkdir -p "$TEST_TMP/project/docs/test plans/phase 1" "$TEST_TMP/agent home/.agents" "$TEST_TMP/standalone dir"
cat > "$TEST_TMP/project/.docsconfig" <<EOF
REPO_DIR=project
DOC_DIR=docs
AGENT_ROOT=$TEST_TMP/agent home
AGENT_DIR=.agents
KNOWLEDGE_TYPE=application
EOF
printf 'WORK_SPACE=%s\n' "$TEST_TMP" > "$TEST_TMP/agent home/.agents/configs"
cp "$TEST_TMP/project/.docsconfig" "$TEST_TMP/docsconfig.before"
cp "$TEST_TMP/agent home/.agents/configs" "$TEST_TMP/workspace.before"

check() {
  local name="$1" expected="$2" cwd="$3" needle="$4" status=0
  shift 4
  (cd "$cwd" && "$TEST_BASH" "$VALIDATOR" "$@") > "$TEST_TMP/result" 2>&1 || status=$?
  if [[ "$status" == "$expected" ]] && grep -qF -- "$needle" "$TEST_TMP/result"; then
    PASSED=$((PASSED + 1))
    printf 'PASS: %s\n' "$name"
  else
    FAILED=$((FAILED + 1))
    printf 'FAIL: %s (exit=%s, expected=%s, expected output=%s)\n' "$name" "$status" "$expected" "$needle"
    cat "$TEST_TMP/result"
  fi
}

reset_document() {
  cp "$FIXTURE" "$TEST_TMP/project/docs/test plans/phase 1/TDD-TEST-1.md"
}

set_reviewers() {
  local line
  while IFS= read -r line; do
    if [[ "$line" == reviewers:* ]]; then
      printf 'reviewers: %s\n' "$1"
    else
      printf '%s\n' "$line"
    fi
  done < "$FIXTURE" > "$DOCUMENT"
}

DOCUMENT="$TEST_TMP/project/docs/test plans/phase 1/TDD-TEST-1.md"

# 参数错误必须在读取配置之前报告，不得以 unbound variable 或配置错误代替。
check 'help does not need config' 0 "$TEST_TMP/standalone dir" '--file' --help
check 'missing file argument' 2 "$TEST_TMP/standalone dir" '--file' --file
check 'option cannot be file argument' 2 "$TEST_TMP/standalone dir" '--file' --file --help
check 'empty file argument' 2 "$TEST_TMP/standalone dir" '--file' --file ''
check 'unknown argument' 2 "$TEST_TMP/standalone dir" '未知参数' --unknown
check 'duplicate file option' 2 "$TEST_TMP/standalone dir" '--file' --file a --file b
check 'missing explicit file' 2 "$TEST_TMP/standalone dir" '不存在' --file missing.md
check 'scan without config fails' 2 "$TEST_TMP/standalone dir" '.docsconfig'
mkdir -p "$TEST_TMP/isolated/agent/skills/sdx-test/scripts"
ISOLATED_VALIDATOR="$TEST_TMP/isolated/agent/skills/sdx-test/scripts/validate-test.sh"
cp "$VALIDATOR" "$ISOLATED_VALIDATOR"
VALIDATOR="$ISOLATED_VALIDATOR" check 'missing shared library is operational' 2 "$TEST_TMP/project" 'docsconfig.sh'
VALIDATOR="$ISOLATED_VALIDATOR" check 'isolated explicit file needs no shared library' 0 "$TEST_TMP/project" '校验通过' --file "$FIXTURE"

# 空扫描不能输出“通过”；配置和共享工作区文件不得被改写。
check 'empty document tree is skipped' 3 "$TEST_TMP/project" '未校验任何文件'
mkdir -p "$TEST_TMP/no docs"
sed 's/REPO_DIR=project/REPO_DIR=no docs/' "$TEST_TMP/project/.docsconfig" > "$TEST_TMP/no docs/.docsconfig"
check 'missing document tree is skipped' 3 "$TEST_TMP/no docs" '未校验任何文件'

reset_document
check 'configured scan includes files outside requirements' 0 "$TEST_TMP/project/docs" '校验通过'
check 'relative file is resolved from caller cwd' 0 "$TEST_TMP/project/docs" '校验通过' --file "test plans/phase 1/TDD-TEST-1.md"
cp "$FIXTURE" "$TEST_TMP/standalone dir/TDD-TEST-1.md"
check 'standalone file and spaces need no config' 0 "$TEST_TMP/standalone dir" '校验通过' --file TDD-TEST-1.md
check 'absolute file and spaces' 0 "$TEST_TMP" '校验通过' --file "$TEST_TMP/standalone dir/TDD-TEST-1.md"
printf 'DOC_DIR=invalid\n' > "$TEST_TMP/standalone dir/.docsconfig"
check 'explicit file ignores invalid local config' 0 "$TEST_TMP/standalone dir" '校验通过' --file TDD-TEST-1.md
# 在外部命令边界注入失败；验证工具故障不会伪装成文档内容错误。
mkdir -p "$TEST_TMP/failing-tools"
printf '#!/bin/sh\nexit 2\n' > "$TEST_TMP/failing-tools/awk"
chmod +x "$TEST_TMP/failing-tools/awk"
PATH="$TEST_TMP/failing-tools:$PATH" check 'awk failure is operational' 2 "$TEST_TMP/standalone dir" '执行或读取失败' --file TDD-TEST-1.md

# metadata 必须来自文首顶层字段，正文、注释、块字符串都不能补齐。
for field in id title version status created updated author reviewers parent mvp_phase; do
  sed "/^${field}:/d" "$FIXTURE" > "$DOCUMENT"
  check "missing required metadata: $field" 1 "$TEST_TMP/project" "$field" --file "$DOCUMENT"
done
sed '/^title:/d' "$FIXTURE" > "$DOCUMENT"
printf '\ntitle: 正文伪字段\n' >> "$DOCUMENT"
check 'body cannot provide missing metadata' 1 "$TEST_TMP/project" 'title' --file "$DOCUMENT"
sed 's/^author:.*/author: # 待补充/' "$FIXTURE" > "$DOCUMENT"
check 'empty metadata value fails' 1 "$TEST_TMP/project" 'author' --file "$DOCUMENT"
sed 's/^title:.*/title: "   "/' "$FIXTURE" > "$DOCUMENT"
check 'whitespace-only metadata value fails' 1 "$TEST_TMP/project" 'title' --file "$DOCUMENT"
sed "s/^reviewers:.*/reviewers:\n  - '  '/" "$FIXTURE" > "$DOCUMENT"
check 'whitespace-only reviewer fails' 1 "$TEST_TMP/project" 'reviewers' --file "$DOCUMENT"
sed 's/^author:.*/author: *reviewer/' "$FIXTURE" > "$DOCUMENT"
check 'YAML aliases are outside supported subset' 1 "$TEST_TMP/project" 'author' --file "$DOCUMENT"
sed 's/^title:.*/title: "未闭合/' "$FIXTURE" > "$DOCUMENT"
check 'unclosed scalar quote fails' 1 "$TEST_TMP/project" 'title' --file "$DOCUMENT"
sed 's/^id:.*/id: "TDD-WRONG-1"/' "$FIXTURE" > "$DOCUMENT"
check 'identity must match filename' 1 "$TEST_TMP/project" 'id' --file "$DOCUMENT"
sed '/^title:/a\
title: "重复标题"' "$FIXTURE" > "$DOCUMENT"
check 'duplicate metadata is rejected' 1 "$TEST_TMP/project" 'title' --file "$DOCUMENT"
sed '/^reviewers:/a\
reviewers: []' "$FIXTURE" > "$DOCUMENT"
check 'duplicate reviewers key is rejected' 1 "$TEST_TMP/project" 'reviewers' --file "$DOCUMENT"
sed 's/^title:.*/title: |\n  author: "块字符串伪字段"/; /^author:/d' "$FIXTURE" > "$DOCUMENT"
check 'block content cannot provide metadata' 1 "$TEST_TMP/project" 'author' --file "$DOCUMENT"
tail -n +2 "$FIXTURE" > "$DOCUMENT"
check 'frontmatter must start on first line' 1 "$TEST_TMP/project" 'frontmatter' --file "$DOCUMENT"
sed '12d' "$FIXTURE" > "$DOCUMENT"
check 'frontmatter must close' 1 "$TEST_TMP/project" 'frontmatter' --file "$DOCUMENT"

# PRD 引用须位于 parent 字段并与当前 IDEA/MVP 对应，正文引用不能兜底。
sed 's/^parent:.*/parent: "PRD-OTHER-1"/' "$FIXTURE" > "$DOCUMENT"
check 'wrong PRD identity fails' 1 "$TEST_TMP/project" 'parent' --file "$DOCUMENT"
sed 's/^mvp_phase:.*/mvp_phase: "MVP-Phase-2"/' "$FIXTURE" > "$DOCUMENT"
check 'wrong MVP phase fails' 1 "$TEST_TMP/project" 'mvp_phase' --file "$DOCUMENT"
sed 's|^parent:.*|parent: "../PRD-TEST-1.md"|' "$FIXTURE" > "$DOCUMENT"
check 'local PRD reference path is accepted' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
sed 's/^parent:.*/parent: ""/' "$FIXTURE" > "$DOCUMENT"
printf '\nPRD-TEST-1\n' >> "$DOCUMENT"
check 'body cannot repair empty parent reference' 1 "$TEST_TMP/project" 'parent' --file "$DOCUMENT"
reset_document
check 'missing DSD and optional reference fields remain valid' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"

# 真实标题可使用常见 Markdown 空白和闭合 #；伪标题必须失败。
required_headings=(
  '## 1. 概述' '## 2. 测试用例' '## 3. 测试数据' '## 4. 测试环境'
  '## 5. 测试进出标准' '## 6. 附录'
  '### 1.1 测试目标' '### 1.2 测试范围' '### 1.3 测试策略'
  '### 2.1 功能测试用例' '### 2.2 接口测试用例' '### 2.3 业务规则测试用例'
  '### 2.4 异常场景测试用例' '### 2.6 回归测试用例'
  '### 5.1 进入标准' '### 5.2 退出标准'
)
for heading in "${required_headings[@]}"; do
  awk -v omitted="$heading" '$0 != omitted' "$FIXTURE" > "$DOCUMENT"
  check "missing required heading: $heading" 1 "$TEST_TMP/project" "${heading#* }" --file "$DOCUMENT"
done
for style in fenced tilde comment indented quote suffix wrong-level comment-prefix inline-before-comment unpaired-code-before-comment backtick-tilde-info tilde-backtick-info backtick-info-not-close tilde-info-not-close; do
  sed '/^### 2\.4 异常场景测试用例/d' "$FIXTURE" > "$DOCUMENT"
  case "$style" in
    fenced) printf '\n````markdown\n```\n### 2.4 异常场景测试用例\n````\n' >> "$DOCUMENT" ;;
    tilde) printf '\n~~~markdown\n### 2.4 异常场景测试用例\n~~~\n' >> "$DOCUMENT" ;;
    comment) printf '\n<!--\n### 2.4 异常场景测试用例\n-->\n' >> "$DOCUMENT" ;;
    indented) printf '\n    ### 2.4 异常场景测试用例\n' >> "$DOCUMENT" ;;
    quote) printf '\n> ### 2.4 异常场景测试用例\n' >> "$DOCUMENT" ;;
    suffix) printf '\n### 2.4 异常场景测试用例示例\n' >> "$DOCUMENT" ;;
    wrong-level) printf '\n#### 2.4 异常场景测试用例\n' >> "$DOCUMENT" ;;
    comment-prefix) printf '\n<!-- 示例 -->### 2.4 异常场景测试用例\n' >> "$DOCUMENT" ;;
    inline-before-comment) printf '\n`文字` <!--\n### 2.4 异常场景测试用例\n-->\n' >> "$DOCUMENT" ;;
    unpaired-code-before-comment) printf '\n`未闭合 <!--\n### 2.4 异常场景测试用例\n-->\n' >> "$DOCUMENT" ;;
    backtick-tilde-info) printf '\n```~example\n### 2.4 异常场景测试用例\n```\n' >> "$DOCUMENT" ;;
    tilde-backtick-info) printf '\n~~~`example\n### 2.4 异常场景测试用例\n~~~\n' >> "$DOCUMENT" ;;
    backtick-info-not-close) printf '\n```example\n```~suffix\n### 2.4 异常场景测试用例\n```\n' >> "$DOCUMENT" ;;
    tilde-info-not-close) printf '\n~~~example\n~~~`suffix\n### 2.4 异常场景测试用例\n~~~\n' >> "$DOCUMENT" ;;
  esac
  check "$style cannot supply a required heading" 1 "$TEST_TMP/project" '2.4 异常场景测试用例' --file "$DOCUMENT"
done
sed 's/^### 2.4 异常场景测试用例/  ###   2.4 异常场景测试用例 ### <!-- 注释 -->/' "$FIXTURE" > "$DOCUMENT"
check 'Markdown heading whitespace is accepted' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
sed '/^# 测试设计样本/a\
<!-- intro\
    -->' "$FIXTURE" > "$DOCUMENT"
check 'indented comment closer preserves later headings' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
sed '/^# 测试设计样本/a\
```example<!--\
代码围栏中的注释符不改变正文状态\
```' "$FIXTURE" > "$DOCUMENT"
check 'fence info cannot start an HTML comment' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
sed '/^# 测试设计样本/a\
```~example\
代码内容\
````' "$FIXTURE" > "$DOCUMENT"
check 'backtick fence with tilde info closes before real headings' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
sed '/^# 测试设计样本/a\
~~~`example\
代码内容\
~~~~' "$FIXTURE" > "$DOCUMENT"
check 'tilde fence with backtick info closes before real headings' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
sed '/^### 2.3 业务规则测试用例/a\
输入包含 `<!--`，期望原样保存。' "$FIXTURE" > "$DOCUMENT"
check 'inline code cannot start an HTML comment' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
sed '/^### 2.3 业务规则测试用例/a\
输入包含 ``<!-- ` 字符``，期望原样保存。' "$FIXTURE" > "$DOCUMENT"
check 'equal-length backtick spans protect comment literals' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
sed '/^### 2.3 业务规则测试用例/a\
```<!--```' "$FIXTURE" > "$DOCUMENT"
check 'standalone triple-backtick code span is not a fence' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
sed '/^### 2.3 业务规则测试用例/a\
```输入 ` 字符```' "$FIXTURE" > "$DOCUMENT"
check 'triple-backtick span can contain a shorter backtick run' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
sed "s/\"/'/g; s/^reviewers:.*/reviewers:\n  - 'reviewer' /" "$FIXTURE" > "$DOCUMENT"
check 'single quotes and reviewer block sequence' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
sed 's/^reviewers:.*/reviewers: ["评审人 #1"]/' "$FIXTURE" > "$DOCUMENT"
check 'quoted reviewer hash is part of the name' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
sed "s/^reviewers:.*/reviewers: ['评审人 #2'] # 外部注释/" "$FIXTURE" > "$DOCUMENT"
check 'reviewer comment stripping respects single quotes' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
set_reviewers '["张三 [QA]"]'
check 'quoted reviewer brackets are literal' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
set_reviewers '["张三, #1 [QA]", "李四 \"维护\"", "路径 \\QA"]'
check 'quoted reviewer punctuation and escapes stay in their members' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
set_reviewers "['O''Brien, [QA] #1', '李四'] # 外部注释"
check 'single-quoted reviewer escape does not split the member' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
set_reviewers '[张三, 李四, ]'
check 'plain reviewer members and trailing comma are accepted' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
set_reviewers "[O'Connor, 张三] # 外部注释"
check 'apostrophe in a plain reviewer is not a quote delimiter' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
set_reviewers '["张三]'
check 'unclosed reviewer quote is rejected' 1 "$TEST_TMP/project" 'reviewers' --file "$DOCUMENT"
set_reviewers '["  "]'
check 'whitespace-only inline reviewer is rejected' 1 "$TEST_TMP/project" 'reviewers' --file "$DOCUMENT"
set_reviewers '[{name: "张三"}]'
check 'reviewer mapping is outside scalar list subset' 1 "$TEST_TMP/project" 'reviewers' --file "$DOCUMENT"
set_reviewers '[张三,,李四]'
check 'missing reviewer member is rejected' 1 "$TEST_TMP/project" 'reviewers' --file "$DOCUMENT"
set_reviewers '["张三" "李四"]'
check 'missing reviewer separator is rejected' 1 "$TEST_TMP/project" 'reviewers' --file "$DOCUMENT"
set_reviewers '["张三", null]'
check 'null reviewer member is rejected' 1 "$TEST_TMP/project" 'reviewers' --file "$DOCUMENT"
sed 's/^title:.*/title: "标题 # 不是注释" # 行尾注释/; s/^author:.*/author: architect # 行尾注释/' "$FIXTURE" > "$DOCUMENT"
check 'quoted hashes and trailing comments are accepted' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
sed 's/$/\r/' "$FIXTURE" > "$DOCUMENT"
check 'CRLF document is accepted' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
reset_document
printf '\nTC-010 TC-API-200 TC-BR-033 TC-EX-051 TC-PERF-900 TC-REG-004\n' >> "$DOCUMENT"
check 'all TC prefixes and gaps are allowed' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"

check 'TC identifiers do not prove execution or coverage' 0 "$TEST_TMP/project" '不代表用例执行或业务覆盖通过' --file "$DOCUMENT"
reset_document
check 'optional performance section is not required' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"

# 混合扫描中一个失败文件必须使整次扫描失败。
cp "$FIXTURE" "$TEST_TMP/project/docs/test plans/phase 1/TDD-OTHER-1.md"
check 'scan reports any invalid file' 1 "$TEST_TMP/project" 'TDD-OTHER-1.md'
if cmp -s "$TEST_TMP/docsconfig.before" "$TEST_TMP/project/.docsconfig" && cmp -s "$TEST_TMP/workspace.before" "$TEST_TMP/agent home/.agents/configs"; then
  PASSED=$((PASSED + 1))
  printf 'PASS: configuration remains unchanged\n'
else
  FAILED=$((FAILED + 1))
  printf 'FAIL: configuration was modified\n'
fi

printf '\n总计: %d, 通过: %d, 失败: %d\n' "$((PASSED + FAILED))" "$PASSED" "$FAILED"
[[ "$FAILED" -eq 0 ]]
