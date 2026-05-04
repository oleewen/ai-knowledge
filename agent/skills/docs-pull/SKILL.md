---
name: docs-pull
description: >
  从已通过中央知识库挂载建联注册的目标工程拉取最新文档，覆盖更新本仓库联邦镜像
  applications/app-{APPNAME}/，并追加同步 changelog。
  只要用户提到以下任意场景，就应立即使用本技能，不要等用户明确说"/docs-pull"：
  同步应用文档、拉取最新知识库、更新联邦镜像、应用侧有更新要拉到中央库、
  "把应用的文档同步过来"、"拉一下最新的"、"应用知识库更新了帮我同步"、
  "更新一下 app 镜像"、"docs-pull 一下"。
  若用户已明确要求只做 docs-distill、docs-extract、docs-archive、SDD 终稿落盘或仅改 system overview，则不要以本技能为唯一主路径，应分流到对应技能。
---

# 应用知识库拉取（docs-pull）

本技能以「调度器」方式工作：先判定是否应由 `docs-pull` 处理，再按序读取 `references/` 下规范，在**低风险参数确认**（见 [agent/rules/CONVENTIONS.md](../../rules/CONVENTIONS.md#artifact-gates)）下更新联邦镜像 `applications/app-{APPNAME}/`。

> **联邦镜像**指本仓库 `applications/app-{APPNAME}/`。**应用知识库 SSOT**在目标工程 `{DOC_DIR}/`；本技能默认不修改中央库 `{DOC_DIR}/` 本体。

---

## 适用边界

- **本技能负责**：已注册应用的远端文档 → 联邦镜像；`pull-log.md` 追加；manifest `last_pulled_*` 更新（由脚本）；`--dry-run` / `--force` 语义下的确认节奏。
- **本技能不负责**：写入 `system/architecture/overview/`（走 **docs-extract** / **docs-distill**）；归档 **docs-archive**；`APPLICATIONS_INDEX.md` 自动改写；SDD 终稿。
- **分流**：用户只要上述产物时，转对应技能。

---

## 输入与前置检查

- `applications/app-{APPNAME}/` 与 `{APPNAME}_manifest.yaml` 已存在（未注册须先挂载建联）。
- 从仓库根可调用 `agent/skills/docs-pull/scripts/pull-docs.sh`（或等价封装）。

---

## 执行路由（先读后写）

1. **写盘闸门与何时停问**：先读 `references/gates.md`（**非** SDX 式 spec gate）
2. **四步工作流、参数、脚本形态**：再读 `references/workflow.md`
3. **manifest 字段**：解析或不确定时读 `references/manifest-spec.md`
4. **术语**：读 `references/core-concepts.md`
5. **原则层**：范围判断时读 `references/design-principles.md`
6. **反模式**：收敛前读 `references/anti-patterns.md`
7. **实跑前后验收**：读 `references/quality-checklist.md`
8. **与 SDD / brainstorming 边界**：读 `references/brainstorming-integration.md`
9. **操作层陷阱**：读 `gotchas.md`
10. **一纸速查（可选）**：`assets/docs-pull-run-checklist.md`

---

## 门禁与确认（必须执行）

- 实跑拉取前满足 `references/gates.md` 写盘 HARD-GATE；**不**要求 `docs/superpowers/specs/` 文稿或 HTML gate 标记（与 CONVENTIONS 低风险表一致）。

---

## 产出与校验

- **镜像树**：`applications/app-{APPNAME}/`（rsync 结果）。
- **同步记录**：`applications/app-{APPNAME}/changelogs/pull-log.md`（追加）。
- **脚本**：从仓库根执行，示例见 `references/workflow.md`。

---

## 评测与迭代（skill-creator 对齐）

- 评测样本：`evals/evals.json`（可扩展 `assertions`）
- 评测元模板：`evals/eval-metadata-template.json`
- 评分规则：`agents/grader.md`
- 失败分析：`agents/analyzer.md`

---

## 工程化支持

本技能路径**无** `preToolUse` 专用钩子；依赖对话内遵守 `gates.md`。若未来升级闸门层级，须先改 CONVENTIONS 与 `agent/hooks.json` 再改本技能。

---

## 快速定向表

| 需要做什么 | 去读 |
|-----------|------|
| 全目录索引与何时打开 | [references/README.md](references/README.md) |
