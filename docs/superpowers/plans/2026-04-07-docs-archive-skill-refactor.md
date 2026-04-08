# Docs Archive Skill Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 重构 `docs-archive` 技能与配套脚本/参考文档，完成应用知识库到系统知识库的归档流程统一（`*-LOG.md` 命名、增量锚点、`--dry-run` 预览、`--full` 受管区块策略）。

**Architecture:** 以 `SKILL.md` 定义执行契约，以 `reference/*` 定义规则细则，以 `scripts/*` 实现可复用日志写入动作。流程采用“系统日志先写、应用归档锚点后写”的原子顺序，默认增量基于应用 `ARCHIVE-LOG.md`，并通过 dry-run 输出可读预览而不落盘。

**Tech Stack:** Markdown, Bash 5+, ripgrep (`rg`), Git

---

## File Structure

- **Create:** `system/architecture/BUSINESS-ARCHITECTURE.md`
- **Create:** `system/architecture/TECHNICAL-ARCHITECTURE.md`
- **Create:** `system/architecture/DATA-ARCHITECTURE.md`
- **Create:** `system/architecture/PRODUCT-ARCHITECTURE.md`
- **Create:** `.agent/skills/docs-archive/scripts/update-application-archive-log.sh`
- **Create:** `.agent/skills/docs-archive/scripts/append-system-change-log.sh`
- **Modify:** `.agent/skills/docs-archive/SKILL.md`
- **Modify:** `.agent/skills/docs-archive/reference/archive-spec.md`
- **Modify:** `.agent/skills/docs-archive/reference/archive-log-spec.md`
- **Modify:** `.agent/skills/docs-archive/reference/README.md`
- **Modify:** `system/changelogs/README.md`
- **Modify:** `system/architecture/README.md`
- **Delete:** `.agent/skills/docs-archive/scripts/fetch-log-legacy.sh`（历史入口，已迁移）
- **Delete:** `.agent/skills/docs-archive/scripts/archive-log-legacy.sh`（历史入口，已迁移）
- **Search/Update References:** 全仓旧命名与旧脚本引用

---

### Task 1: 创建 system/architecture 四视角模板文件

**Files:**
- Create: `system/architecture/BUSINESS-ARCHITECTURE.md`
- Create: `system/architecture/TECHNICAL-ARCHITECTURE.md`
- Create: `system/architecture/DATA-ARCHITECTURE.md`
- Create: `system/architecture/PRODUCT-ARCHITECTURE.md`
- Test: `system/architecture/README.md`

- [ ] **Step 1: 先写结构测试（文件存在与受管区块标记）**

```bash
for f in BUSINESS TECHNICAL DATA PRODUCT; do
  test -f "system/architecture/${f}-ARCHITECTURE.md" && echo "ok:${f}" || echo "missing:${f}"
done
rg -n "BEGIN MANAGED BLOCK|END MANAGED BLOCK" system/architecture/*-ARCHITECTURE.md
```

Expected: 初次应显示 `missing:*` 或受管区块不存在（FAIL 态）。

- [ ] **Step 2: 写入最小模板实现（每个文件都带受管区块）**

```markdown
# BUSINESS ARCHITECTURE

> 本文件由 docs-archive 在受管区块内维护；区块外允许人工补充。

<!-- BEGIN MANAGED BLOCK: business -->
## 归档条目

_暂无内容。_
<!-- END MANAGED BLOCK: business -->
```

同样结构复制到其余三个文件，区块 key 分别替换为 `technical/data/product`。

- [ ] **Step 3: 运行测试验证模板创建成功**

Run:
```bash
for f in BUSINESS TECHNICAL DATA PRODUCT; do
  test -f "system/architecture/${f}-ARCHITECTURE.md" && echo "ok:${f}" || exit 1
done
rg -n "BEGIN MANAGED BLOCK|END MANAGED BLOCK" system/architecture/*-ARCHITECTURE.md
```

Expected: 全部 `ok:*` 且每个文件都命中受管区块标记（PASS）。

- [ ] **Step 4: 更新目录说明**

```markdown
本目录四个标准归档文件：
- BUSINESS-ARCHITECTURE.md
- TECHNICAL-ARCHITECTURE.md
- DATA-ARCHITECTURE.md
- PRODUCT-ARCHITECTURE.md
```

- [ ] **Step 5: Commit**

```bash
git add system/architecture/README.md system/architecture/*-ARCHITECTURE.md
git commit -m "docs(system): 新增 architecture 四视角标准模板"
```

---

### Task 2: 重写 docs-archive SKILL.md 触发与流程契约

**Files:**
- Modify: `.agent/skills/docs-archive/SKILL.md`
- Test: `.agent/skills/docs-archive/SKILL.md`

- [ ] **Step 1: 写失败测试（关键语义必须出现）**

```bash
rg -n "CHANGE-LOG.md|ARCHIVE-LOG.md|--dry-run|--full|受管区块|/docs-archive|同步一下|更新主库" \
  .agent/skills/docs-archive/SKILL.md
```

Expected: 当前命中不完整或命名不一致（FAIL）。

- [ ] **Step 2: 写最小实现（重写 frontmatter + 工作流）**

```markdown
---
name: docs-archive
description: >
  将应用知识库（system/application-{name}）已核实内容归档到 system/architecture/。
  必须在 /docs-archive、"归档"、"同步应用知识到系统"、"同步一下"、
  "把应用侧内容推上去"、"更新主库" 等请求下触发。
---
```

并在正文明确：
- 三日志职责：应用 `CHANGE-LOG.md`、应用 `ARCHIVE-LOG.md`、系统 `CHANGE-LOG.md`
- 原子顺序：先系统日志，后应用归档锚点
- `--dry-run` 输出三层预览
- `--full` 仅覆盖受管区块

- [ ] **Step 3: 运行测试验证语义齐全**

Run:
```bash
rg -n "CHANGE-LOG.md|ARCHIVE-LOG.md|--dry-run|--full|受管区块|/docs-archive|同步一下|更新主库" \
  .agent/skills/docs-archive/SKILL.md
```

Expected: 所有关键词均命中（PASS）。

- [ ] **Step 4: 补一段执行示例命令**

```bash
/docs-archive --app billing --dry-run
/docs-archive --app billing --since v1.2.0
/docs-archive --app billing --full
```

- [ ] **Step 5: Commit**

```bash
git add .agent/skills/docs-archive/SKILL.md
git commit -m "docs(skill): 重写 docs-archive 触发语义与归档流程契约"
```

---

### Task 3: 更新 reference 规范（archive-spec/archive-log-spec/README）

**Files:**
- Modify: `.agent/skills/docs-archive/reference/archive-spec.md`
- Modify: `.agent/skills/docs-archive/reference/archive-log-spec.md`
- Modify: `.agent/skills/docs-archive/reference/README.md`
- Test: `.agent/skills/docs-archive/reference/*.md`

- [ ] **Step 1: 写失败测试（旧命名与旧路径不应保留）**

```bash
rg -n "ARCHIVE-LOG.md|CHANGE-LOG.md|ARCHITECTURE|append-system-change-log.sh|update-application-archive-log.sh" \
  .agent/skills/docs-archive/reference
```

Expected: 命中旧命名/旧脚本（FAIL）。

- [ ] **Step 2: 写最小实现（统一术语与命名）**

```markdown
- 应用变更日志：system/application-{name}/changelogs/CHANGE-LOG.md
- 应用归档锚点：system/application-{name}/changelogs/ARCHIVE-LOG.md
- 系统变更日志：system/changelogs/CHANGE-LOG.md
```

并在 `archive-log-spec.md` 增加：
- 增量判定优先级：`--full` > `--since` > `ARCHIVE-LOG` last marker
- dry-run 不更新任何日志文件

- [ ] **Step 3: 运行测试验证旧命名已清理**

Run:
```bash
rg -n "ARCHITECTURE|append-system-change-log.sh|update-application-archive-log.sh" \
  .agent/skills/docs-archive/reference
```

Expected: 0 matches（PASS）。

- [ ] **Step 4: 交叉一致性检查（SKILL 与 reference 不矛盾）**

Run:
```bash
rg -n "CHANGE-LOG.md|ARCHIVE-LOG.md|--dry-run|--full|受管区块" \
  .agent/skills/docs-archive/SKILL.md .agent/skills/docs-archive/reference/*.md
```

Expected: 两侧术语一致且都命中。

- [ ] **Step 5: Commit**

```bash
git add .agent/skills/docs-archive/reference/*.md
git commit -m "docs(reference): 统一 docs-archive 日志命名与增量规范"
```

---

### Task 4: 新增日志脚本并删除旧脚本

**Files:**
- Create: `.agent/skills/docs-archive/scripts/update-application-archive-log.sh`
- Create: `.agent/skills/docs-archive/scripts/append-system-change-log.sh`
- Delete: `.agent/skills/docs-archive/scripts/fetch-log-legacy.sh`（历史入口，已迁移）
- Delete: `.agent/skills/docs-archive/scripts/archive-log-legacy.sh`（历史入口，已迁移）
- Test: `.agent/skills/docs-archive/scripts/*.sh`

- [ ] **Step 1: 写失败测试（新脚本不存在）**

```bash
test -f .agent/skills/docs-archive/scripts/update-application-archive-log.sh || echo "missing app script"
test -f .agent/skills/docs-archive/scripts/append-system-change-log.sh || echo "missing system script"
```

Expected: 显示 missing（FAIL）。

- [ ] **Step 2: 写最小实现（应用 ARCHIVE-LOG 更新脚本）**

```bash
#!/usr/bin/env bash
set -euo pipefail
APP=""
CHANGELOG_ID=""
CHANGELOG_TIME=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --app) APP="$2"; shift 2 ;;
    --changelog-id) CHANGELOG_ID="$2"; shift 2 ;;
    --changelog-time) CHANGELOG_TIME="$2"; shift 2 ;;
    *) echo "[ERROR] Unknown option: $1"; exit 1 ;;
  esac
done
LOG_FILE="system/application-${APP}/changelogs/ARCHIVE-LOG.md"
NOW_ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
mkdir -p "$(dirname "$LOG_FILE")"
test -f "$LOG_FILE" || { echo "# ARCHIVE LOG - ${APP}"; echo; echo "| changelog_id | changelog_time | archived_at |"; echo "|---|---|---|"; } > "$LOG_FILE"
echo "| ${CHANGELOG_ID} | ${CHANGELOG_TIME} | ${NOW_ISO} |" >> "$LOG_FILE"
```

- [ ] **Step 3: 写最小实现（系统 CHANGE-LOG 追加脚本）**

```bash
#!/usr/bin/env bash
set -euo pipefail
APP=""
CHANGELOG_ID=""
CHANGELOG_TIME=""
ARCHIVED_AT=""
SUMMARY=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --app) APP="$2"; shift 2 ;;
    --changelog-id) CHANGELOG_ID="$2"; shift 2 ;;
    --changelog-time) CHANGELOG_TIME="$2"; shift 2 ;;
    --archived-at) ARCHIVED_AT="$2"; shift 2 ;;
    --summary) SUMMARY="$2"; shift 2 ;;
    *) echo "[ERROR] Unknown option: $1"; exit 1 ;;
  esac
done
LOG_FILE="system/changelogs/CHANGE-LOG.md"
NOW_ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
[[ -z "${ARCHIVED_AT}" ]] && ARCHIVED_AT="${NOW_ISO}"
mkdir -p "$(dirname "$LOG_FILE")"
test -f "$LOG_FILE" || { echo "# CHANGE LOG - system"; echo; echo "| app | changelog_id | changelog_time | archived_at | summary |"; echo "|---|---|---|---|---|"; } > "$LOG_FILE"
echo "| ${APP} | ${CHANGELOG_ID} | ${CHANGELOG_TIME} | ${ARCHIVED_AT} | ${SUMMARY} |" >> "$LOG_FILE"
```

- [ ] **Step 4: 删除旧脚本并做语法检查**

Run:
```bash
rm .agent/skills/docs-archive/scripts/fetch-log-legacy.sh
rm .agent/skills/docs-archive/scripts/archive-log-legacy.sh
bash -n .agent/skills/docs-archive/scripts/update-application-archive-log.sh
bash -n .agent/skills/docs-archive/scripts/append-system-change-log.sh
```

Expected: `bash -n` 无输出即 PASS。

- [ ] **Step 5: Commit**

```bash
git add .agent/skills/docs-archive/scripts
git commit -m "refactor(scripts): 新增归档日志脚本并移除旧脚本入口"
```

---

### Task 5: 更新 system/changelogs 与全仓引用迁移

**Files:**
- Modify/Create: `system/changelogs/CHANGE-LOG.md`
- Modify: `system/changelogs/README.md`
- Test: 全仓 `*.md`, `*.sh`

- [ ] **Step 1: 写失败测试（旧命名残留）**

```bash
rg -n "ARCHIVE-LOG.md|CHANGE-LOG.md|ARCHITECTURE|append-system-change-log.sh|update-application-archive-log.sh" .
```

Expected: 会有大量命中（FAIL 基线）。

- [ ] **Step 2: 写最小实现（系统 changelog README 与主文件）**

```markdown
- [CHANGE-LOG.md](CHANGE-LOG.md) — 系统知识库变更日志（批次级）
```

并创建 `system/changelogs/CHANGE-LOG.md` 初始化头：

```markdown
# CHANGE LOG - system

| app | changelog_id | changelog_time | archived_at | summary |
|---|---|---|---|---|
```

- [ ] **Step 3: 执行全仓引用替换与验证**

Run:
```bash
rg -n "append-system-change-log.sh|update-application-archive-log.sh|ARCHITECTURE" .
rg -n "CHANGELOG.md|ARCHIVELOG.md" .agent/skills/docs-archive system/changelogs
```

Expected: 旧脚本/旧拼写在目标范围内 0 命中（PASS）。

- [ ] **Step 4: 归档流程演练（先 dry-run 再实跑）**

Run:
```bash
# dry-run（仅示例，按 skill 实际命令执行）
echo "/docs-archive --app demo --dry-run"

# 实跑后的日志验证（示例检查）
rg -n "^\| demo \|" system/changelogs/CHANGE-LOG.md
test -f system/application-demo/changelogs/ARCHIVE-LOG.md && echo "archive log ok"
```

Expected: dry-run 有预览输出；实跑后系统日志与应用归档日志都有新增记录。

- [ ] **Step 5: Commit**

```bash
git add system/changelogs/README.md system/changelogs/CHANGE-LOG.md
git commit -m "docs(system): 统一系统变更日志为 CHANGE-LOG 并完成引用迁移"
```

---

### Task 6: 最终质量门与交付检查

**Files:**
- Modify: `.agent/skills/docs-archive/gotchas.md`（如需补充新风险）
- Test: 全量改动文件

- [ ] **Step 1: 运行最终校验命令**

Run:
```bash
bash -n .agent/skills/docs-archive/scripts/*.sh
rg -n "ARCHITECTURE|append-system-change-log.sh|update-application-archive-log.sh" .
rg -n "CHANGE-LOG.md|ARCHIVE-LOG.md|--dry-run|--full|受管区块" .agent/skills/docs-archive
```

Expected:
- `bash -n` 全通过
- 旧拼写/旧脚本 0 命中
- 新术语在 skill/reference 中稳定命中

- [ ] **Step 2: 运行 lints（仅针对改动路径）**

Run:
```bash
# 使用 IDE ReadLints 或项目既有 lint 命令（若有）
echo "ReadLints: .agent/skills/docs-archive, system/architecture, system/changelogs"
```

Expected: 无新增可修复问题。

- [ ] **Step 3: 更新 gotchas（若发现迁移陷阱）**

```markdown
- 旧脚本已删除，任何遗留调用会直接失败。
- 仅允许写入受管区块，区块外禁止自动覆盖。
```

- [ ] **Step 4: 汇总验证证据**

Run:
```bash
git status --short
git diff -- .agent/skills/docs-archive system/architecture system/changelogs
```

Expected: 改动集中且可审阅。

- [ ] **Step 5: Commit**

```bash
git add .agent/skills/docs-archive system/architecture system/changelogs
git commit -m "feat(docs-archive): 完成归档流程重构与日志命名统一"
```

---

## Self-Review

- **Spec coverage:** 已覆盖命名统一（`*-LOG.md` + `*-ARCHITECTURE.md`）、流程原子性、`--dry-run`/`--full`、脚本重构与旧入口删除。  
- **Placeholder scan:** 无 `TODO/TBD/implement later` 占位语。  
- **Type consistency:** 参数名统一使用 `--app --since --full --dry-run`；日志文件命名统一为 `CHANGE-LOG.md`/`ARCHIVE-LOG.md`。  

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-04-07-docs-archive-skill-refactor.md`. Two execution options:

1. **Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration
2. **Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach?

