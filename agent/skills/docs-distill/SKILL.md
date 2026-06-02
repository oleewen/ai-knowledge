---
name: docs-distill
description: >
  将 application-{name}/ 已核实内容蒸馏写入 system/architecture/overview/{APPNAME}-overview.md 第三列。
  触发：/docs-distill，或「知识蒸馏」「上行系统库」「更新 overview」「同步应用知识」「系统库刷新」等（不必等用户说命令名）。
  参数：--app、--since、--full、--dry-run；默认增量锚点。
  分流：用户只要 docs-extract、docs-archive、docs-indexing、仅 SDD 终稿等 → 不以本技能为唯一主路径。
---

# docs-distill：应用 → 系统 overview

调度器：判定归属 → 读 `references/` → **门禁** → 更新 `{APPNAME}-overview.md`（第三列）与 `DISTILL-LOG.md`。

> 正文第三列不写来源脚注；追溯走 CHANGE-LOG / DISTILL-LOG / 会话 spec。

## 边界

| 负责 | 不负责 |
| ---- | ------ |
| 已核实应用内容 → overview 第三列；增量/全量；DISTILL-LOG 锚点；会话 spec、`docs-distill-gate`；`--dry-run` 预览 | **docs-extract**（任意源→overview）；**docs-archive**（视角归档）；**docs-indexing**；SDD 终稿正文代写 |

## 前置

- 路径契约：[session-spec-path.md](../../references/session-spec-path.md)（闸门 spec 在 `{DOC_DIR}/superpowers/`）
- 可读 `system/application-{name}/changelogs/CHANGE-LOG.md`（过短则补背景）。
- 明确 `{APPNAME}` / `--app`；多应用宜带 `--app`。
- 知 `{DOC_DIR}/superpowers/`（闸门 spec）、`system/architecture/overview/`。

## 读序

1. `references/gates.md`
2. `references/workflow.md`（两日志、参数、五阶段、脚本）
3. `references/interaction-gate.md`
4. `references/core-concepts.md`
5. `references/distill-spec.md`、`references/distill-log-spec.md`
6. `references/federation-spec.md`（阶段 4.2–4.3）
7. `references/design-principles.md`、`references/anti-patterns.md`
8. `references/quality-checklist.md`
9. `gotchas.md`
10. `references/brainstorming-integration.md`
11. `assets/docs-distill-session-spec-template.md`

## 门禁

阶段 3 未 **`CONFIRMED`**（且无合法例外）→ **禁止**阶段 4 落盘。见 `references/gates.md`。建议 spec 使用 `docs-distill-gate` PENDING/CONFIRMED。

## 产出与脚本

- 会话 spec：`{DOC_DIR}/superpowers/YYYY-MM-DD-<topic>-docs-distill.md`
- `{APPNAME}-overview.md` 第三列；`system/changelogs/DISTILL-LOG.md`（仅 4.3 成功后追加）

```bash
agent/skills/docs-distill/scripts/run-docs-distill.sh --help
```

## 评测

`evals/evals.json`、`evals/eval-metadata-template.json`、`agents/grader.md`、`agents/analyzer.md`

## 工程化

`python3 agent/hooks/sdx_gate_common.py --gate distill`（`agent/hooks.json`）；证据：`CONFIRMED` + 目标 overview **basename**。见 `references/gates.md`、`agent/hooks/README.md`。

## 相近技能速查

| 需求 | 技能 |
| ---- | ----- |
| 实体与 KNOWLEDGE_INDEX | docs-build |
| 源→overview 第三列（非上行蒸馏主流程） | docs-extract |
| overview→视角章节归档 | docs-archive |
| INDEX | docs-indexing |
| 本表未列索引 | [references/README.md](references/README.md) |

## 依赖

可选上游：`docs-indexing`（查 INDEX）。相邻：`docs-extract`、`docs-archive`、`sdx-*`。
