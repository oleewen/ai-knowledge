#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALIDATOR="$TEST_DIR/../scripts/validate-dsd.sh"
FIXTURE="$TEST_DIR/fixtures/DSD-TEST-1.md"
# shellcheck source=../../../scripts/test-core.sh
source "$TEST_DIR/../../../scripts/test-core.sh"
TEST_BASH="$(test_bash5_command)" || test_fail '未找到 Bash 5+ 运行器'
TEST_TMP="$(mktemp -d /tmp/sdx-design-tests.XXXXXX)"
trap 'rm -rf "$TEST_TMP"' EXIT
PASSED=0
FAILED=0

mkdir -p "$TEST_TMP/project/docs/requirements" "$TEST_TMP/agent home/.agents" "$TEST_TMP/standalone dir"
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
  cp "$FIXTURE" "$TEST_TMP/project/docs/requirements/DSD-TEST-1.md"
}

DOCUMENT="$TEST_TMP/project/docs/requirements/DSD-TEST-1.md"

# 参数错误必须在读取配置之前报告，不得以 unbound variable 或配置错误代替。
check 'help does not need config' 0 "$TEST_TMP/standalone dir" '--file' --help
check 'missing file argument' 2 "$TEST_TMP/standalone dir" '--file' --file
check 'option cannot be file argument' 2 "$TEST_TMP/standalone dir" '--file' --file --help
check 'empty file argument' 2 "$TEST_TMP/standalone dir" '--file' --file ''
check 'unknown argument' 2 "$TEST_TMP/standalone dir" '未知参数' --unknown
check 'duplicate file option' 2 "$TEST_TMP/standalone dir" '--file' --file a --file b
check 'missing explicit file' 2 "$TEST_TMP/standalone dir" '不存在' --file missing.md
check 'scan without config fails' 2 "$TEST_TMP/standalone dir" '.docsconfig'

# 空扫描不能输出“通过”；配置和共享工作区文件不得被改写。
check 'empty requirements is skipped' 3 "$TEST_TMP/project" '未校验任何文件'
mkdir -p "$TEST_TMP/no requirements/docs"
sed 's/REPO_DIR=project/REPO_DIR=no requirements/' "$TEST_TMP/project/.docsconfig" > "$TEST_TMP/no requirements/.docsconfig"
check 'missing requirements is skipped' 3 "$TEST_TMP/no requirements" '未校验任何文件'

reset_document
check 'valid configured scan' 0 "$TEST_TMP/project/docs" '校验通过'
if grep -qF '[WARN]' "$TEST_TMP/result"; then
  FAILED=$((FAILED + 1))
  printf 'FAIL: standard template headings must not warn\n'
else
  PASSED=$((PASSED + 1))
  printf 'PASS: standard template headings must not warn\n'
fi
check 'relative file is resolved from caller cwd' 0 "$TEST_TMP/project/docs" '校验通过' --file requirements/DSD-TEST-1.md
cp "$FIXTURE" "$TEST_TMP/standalone dir/DSD-TEST-1.md"
check 'standalone file and spaces need no config' 0 "$TEST_TMP/standalone dir" '校验通过' --file DSD-TEST-1.md
check 'absolute file and spaces' 0 "$TEST_TMP" '校验通过' --file "$TEST_TMP/standalone dir/DSD-TEST-1.md"
printf 'DOC_DIR=invalid\n' > "$TEST_TMP/standalone dir/.docsconfig"
check 'explicit file ignores invalid local config' 0 "$TEST_TMP/standalone dir" '校验通过' --file DSD-TEST-1.md
# 在外部命令边界注入失败；验证工具故障不会伪装成文档内容错误。
mkdir -p "$TEST_TMP/failing-tools"
printf '#!/bin/sh\nexit 2\n' > "$TEST_TMP/failing-tools/awk"
chmod +x "$TEST_TMP/failing-tools/awk"
PATH="$TEST_TMP/failing-tools:$PATH" check 'awk failure is operational' 2 "$TEST_TMP/standalone dir" '执行或读取失败' --file DSD-TEST-1.md

# metadata 必须来自文首顶层字段，正文、注释、块字符串都不能补齐。
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
sed 's/^id:.*/id: "DSD-WRONG-1"/' "$FIXTURE" > "$DOCUMENT"
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
sed '13d' "$FIXTURE" > "$DOCUMENT"
check 'frontmatter must close' 1 "$TEST_TMP/project" 'frontmatter' --file "$DOCUMENT"

# 引用须位于指定字段并与当前 IDEA/MVP 对应，任意 PRD-/ASD- 文本不能兜底。
sed 's/^parent:.*/parent: "PRD-OTHER-1"/' "$FIXTURE" > "$DOCUMENT"
check 'wrong PRD identity fails' 1 "$TEST_TMP/project" 'parent' --file "$DOCUMENT"
sed 's/^architecture_ref:.*/architecture_ref: "ASD-TEST-2"/' "$FIXTURE" > "$DOCUMENT"
check 'wrong ASD phase fails' 1 "$TEST_TMP/project" 'architecture_ref' --file "$DOCUMENT"
sed 's/^mvp_phase:.*/mvp_phase: "MVP-Phase-2"/' "$FIXTURE" > "$DOCUMENT"
check 'wrong MVP phase fails' 1 "$TEST_TMP/project" 'mvp_phase' --file "$DOCUMENT"
sed 's/^architecture_ref:.*/architecture_ref: "spec-asd-TEST-2-payments"/' "$FIXTURE" > "$DOCUMENT"
check 'wrong spec-asd phase fails' 1 "$TEST_TMP/project" 'architecture_ref' --file "$DOCUMENT"
sed 's/^architecture_ref:.*/architecture_ref: "spec-asd-TEST-1-payments"/' "$FIXTURE" > "$DOCUMENT"
check 'matching spec-asd is accepted' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
sed 's|^architecture_ref:.*|architecture_ref: "specs/spec-asd-TEST-1-payments.md"|; s|^parent:.*|parent: "../PRD-TEST-1.md"|' "$FIXTURE" > "$DOCUMENT"
check 'local reference paths are accepted' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"

# HTTP 文件定位允许 query/fragment；这些片段不能伪装成同链文件名。
sed 's|^architecture_ref:.*|architecture_ref: "https://git.example/team/repo/blob/main/specs/spec-asd-TEST-1-payments.md?raw=1#section-2"|' "$FIXTURE" > "$DOCUMENT"
check 'HTTP spec-asd query and fragment are accepted' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
sed 's|^architecture_ref:.*|architecture_ref: "https://git.example/team/repo/blob/main/ASD-TEST-1.md#scope"|' "$FIXTURE" > "$DOCUMENT"
check 'HTTP ASD fragment is accepted' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
sed 's|^architecture_ref:.*|architecture_ref: "https://git.example/team/repo/blob/main/ASD-WRONG-1.md?file=/ASD-TEST-1.md"|' "$FIXTURE" > "$DOCUMENT"
check 'query cannot repair a wrong source identity' 1 "$TEST_TMP/project" 'architecture_ref' --file "$DOCUMENT"
sed 's|^architecture_ref:.*|architecture_ref: "https://git.example/team/repo/blob/main/ASD-TEST-2.md#ASD-TEST-1"|' "$FIXTURE" > "$DOCUMENT"
check 'HTTP wrong phase remains invalid' 1 "$TEST_TMP/project" 'architecture_ref' --file "$DOCUMENT"
# URL 路径百分号编码不改变同链文档身份。
for idea in '审批' '旧 ID'; do
  if [[ "$idea" == '审批' ]]; then encoded='%E5%AE%A1%E6%89%B9'; else encoded='旧%20ID'; fi
  encoded_doc="$TEST_TMP/standalone dir/DSD-$idea-1.md"
  sed "s/TEST/$idea/g; s|^architecture_ref:.*|architecture_ref: \"https://git.example/repo/ASD-$encoded-1.md?raw=1#scope\"|" "$FIXTURE" > "$encoded_doc"
  check "encoded identity $idea" 0 "$TEST_TMP/standalone dir" '校验通过' --file "$encoded_doc"
done
sed 's/TEST/审批/g; s|^architecture_ref:.*|architecture_ref: "https://git.example/repo/ASD-%E5%AE%A1%E6%89%B9-2.md?x=/ASD-审批-1.md"|' "$FIXTURE" > "$TEST_TMP/standalone dir/DSD-审批-1.md"
check 'encoded wrong phase still fails' 1 "$TEST_TMP/standalone dir" 'architecture_ref' --file "$TEST_TMP/standalone dir/DSD-审批-1.md"

sed 's/^architecture_ref:.*/architecture_ref: ""/' "$FIXTURE" > "$DOCUMENT"
printf '\nASD-TEST-1 PRD-TEST-1\n' >> "$DOCUMENT"
check 'body cannot repair empty reference' 1 "$TEST_TMP/project" 'architecture_ref' --file "$DOCUMENT"

# 真实标题可使用常见 Markdown 空白和闭合 #；伪标题必须失败。
sed '/^## 2\. 详细设计/d' "$FIXTURE" > "$DOCUMENT"
check 'missing required chapter fails' 1 "$TEST_TMP/project" '2. 详细设计' --file "$DOCUMENT"
for style in fenced tilde comment indented quote suffix wrong-level comment-prefix; do
  sed '/^### 2\.4 数据访问设计/d' "$FIXTURE" > "$DOCUMENT"
  case "$style" in
    fenced) printf '\n````markdown\n```\n### 2.4 数据访问设计\n````\n' >> "$DOCUMENT" ;;
    tilde) printf '\n~~~markdown\n### 2.4 数据访问设计\n~~~\n' >> "$DOCUMENT" ;;
    comment) printf '\n<!--\n### 2.4 数据访问设计\n-->\n' >> "$DOCUMENT" ;;
    indented) printf '\n    ### 2.4 数据访问设计\n' >> "$DOCUMENT" ;;
    quote) printf '\n> ### 2.4 数据访问设计\n' >> "$DOCUMENT" ;;
    suffix) printf '\n### 2.4 数据访问设计示例\n' >> "$DOCUMENT" ;;
    wrong-level) printf '\n#### 2.4 数据访问设计\n' >> "$DOCUMENT" ;;
    comment-prefix) printf '\n<!-- 示例 -->### 2.4 数据访问设计\n' >> "$DOCUMENT" ;;
  esac
  check "$style cannot supply a required heading" 1 "$TEST_TMP/project" '2.4 数据访问设计' --file "$DOCUMENT"
done
sed 's/非功能性设计/非功能设计/' "$FIXTURE" > "$DOCUMENT"
check 'legacy nonfunctional title remains valid' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
sed 's/^### 2.4 数据访问设计/  ###   2.4 数据访问设计 ### <!-- 注释 -->/' "$FIXTURE" > "$DOCUMENT"
check 'Markdown heading whitespace is accepted' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
sed '/^# 测试详设/a\
<!-- intro\
    -->' "$FIXTURE" > "$DOCUMENT"
check 'indented comment closer preserves later headings' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
sed '/^# 测试详设/a\
```example<!--\
代码围栏中的注释符不改变正文状态\
```' "$FIXTURE" > "$DOCUMENT"
check 'fence info cannot start an HTML comment' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
sed "s/\"/'/g; s/^reviewers:.*/reviewers:\n  - 'reviewer' /" "$FIXTURE" > "$DOCUMENT"
check 'single quotes and reviewer block sequence' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
sed 's/^title:.*/title: "标题 # 不是注释" # 行尾注释/; s/^author:.*/author: architect # 行尾注释/' "$FIXTURE" > "$DOCUMENT"
check 'quoted hashes and trailing comments are accepted' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
sed 's/$/\r/' "$FIXTURE" > "$DOCUMENT"
check 'CRLF document is accepted' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"
reset_document
printf '\n#### API-010：接口\n#### LOGIC-900：逻辑\n#### TBL-021：表\n' >> "$DOCUMENT"
check 'item numbers need not be consecutive' 0 "$TEST_TMP/project" '校验通过' --file "$DOCUMENT"

# 混合扫描中一个失败文件必须使整次扫描失败。
cp "$FIXTURE" "$TEST_TMP/project/docs/requirements/DSD-OTHER-1.md"
check 'scan reports any invalid file' 1 "$TEST_TMP/project" 'DSD-OTHER-1.md'
if cmp -s "$TEST_TMP/docsconfig.before" "$TEST_TMP/project/.docsconfig" && cmp -s "$TEST_TMP/workspace.before" "$TEST_TMP/agent home/.agents/configs"; then
  PASSED=$((PASSED + 1))
  printf 'PASS: configuration remains unchanged\n'
else
  FAILED=$((FAILED + 1))
  printf 'FAIL: configuration was modified\n'
fi

printf '\n总计: %d, 通过: %d, 失败: %d\n' "$((PASSED + FAILED))" "$PASSED" "$FAILED"
[[ "$FAILED" -eq 0 ]]
