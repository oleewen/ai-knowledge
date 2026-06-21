---
name: docs-archive
description: >
  将 overview 知识按表格行内副标题链接归档到架构视角章节（`system/knowledge/` 或 `company/knowledge/`），并在确认后清理 overview、做冲突检查。
  触发：/docs-archive，或「知识归档」「overview 落盘」「补架构视角」「合并进目标章」「冲突检查」「结构对齐」等同类表述（不必等用户说命令名）。
  工作流：探索 → 澄清 → 2～3 方案 → 方案确认书 → 用户确认后落盘；禁止未确认批量改写。
  若用户只要 docs-extract、docs-distill、docs-build、docs-upgrade、仅 SDD 终稿或仅 KNOWLEDGE_INDEX，则分流，不以本技能为主路径。
---

# docs-archive：overview → 架构视角章节

调度器：判定归属 → 读 `references/` → **方案确认书 + 门禁** → 写目标章并可选回写 overview。目标路径由 overview **行内副标题链接**解析（见 [references/core-concepts.md](references/core-concepts.md)）。

## 边界

| 负责 | 不负责 |
| ---- | ------ |
| overview（可选锚点）→ 链接指向的视角章节；确认书；来源清理；步骤 5～6 质量与摘要 | 任意源 → overview 第三列（**docs-extract**）；上行蒸馏（**docs-distill**）；实体 ID / KNOWLEDGE_INDEX（**docs-build**）；全库术语与引用链（**docs-upgrade**）；SDD 终稿代写（**sdx-***） |

## 前置

- 路径契约：[session-spec-path.md](../../references/session-spec-path.md)、[knowledge-layout.md](../../references/knowledge-layout.md)
- 有 **overview 路径**（`system/knowledge/overview/` 或 `company/knowledge/overview/`，及可选 `#锚点`）；知目标来自**表格行链接**。
- 知会话 spec：`{DOC_DIR}/superpowers/specs/`，钩子要 `CONFIRMED` + 目标 **basename**（见 `references/gates.md`）。

## 读序（先读后写）

1. `references/gates.md`
2. `references/workflow.md`（步骤 0～6、澄清维度）
3. `references/links-and-index.md`（路径、链接、Git）
4. `references/core-concepts.md`（overview 语法、简写陷阱）
5. `references/design-principles.md`、`references/anti-patterns.md`（对齐方案）
6. 长澄清链：`references/brainstorming-integration.md`
7. 落盘前后：`references/quality-checklist.md`
8. 易错：`gotchas.md`
9. 索：`references/README.md`
10. 确认书：`assets/archive-template.md`；会话骨架：`assets/docs-archive-session-spec-template.md`

## 门禁

用户确认**方案确认书**前，**禁止写任何目标文档**。见 `references/gates.md`、[agent/rules/CONVENTIONS.md](../../rules/CONVENTIONS.md#artifact-gates)。

## 产出

- 会话 spec（可选）：`{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-docs-archive.md`
- 正式：按目标体例增补的 Markdown（链接指向章节）；overview 按确认策略回写

## 评测

`evals/evals.json`、`evals/eval-metadata-template.json`、`agents/grader.md`、`agents/analyzer.md`

## 工程化

`python3 agent/hooks/sdx_gate_common.py --gate archive`（见 `agent/hooks.json`）；细则 `references/gates.md`、`agent/hooks/README.md`。

## 相近技能

| 场景 | 技能 |
| ---- | ---- |
| 实体与 KNOWLEDGE_INDEX | `docs-build` |
| 术语 + 引用链 | `docs-upgrade` |
| 源 → overview 第三列 | `docs-extract` |
| SDD 标准产物 | `sdx-*` |
| overview 行链接 → 视角章节 + 冲突处理 | **本技能** |

**HARD-GATE**：步骤 3 用户确认前，不得执行步骤 4（详见 `references/workflow.md`）。

## 依赖

| 类型 | 说明 |
| ---- | ---- |
| 可选上游 | `docs-indexing` — 查 `INDEX_GUIDE.md` |
| 相邻 | `docs-build` / `docs-upgrade` / `docs-extract` / `sdx-*` |

澄清维度与参数表与步骤 0～6 合一，见 [references/workflow.md](references/workflow.md)。
