---
name: docs-archive
description: >
  将 overview 知识按表格行内副标题链接归档到 system/company 视角章节；确认后清理 overview、做冲突检查。
  触发：/docs-archive、「知识归档」「overview 落盘」「冲突检查」等。
  分流：用户只要 extract/distill/build/upgrade 或仅 SDD/KNOWLEDGE_INDEX → 对应技能。
  门禁：方案确认书与用户确认前禁止写目标文档（见 gates.md）。
---

# docs-archive：overview → 架构视角章节

判定归属 → 读 references/ → 方案确认书 + 门禁 → 写目标章并可选回写 overview。

## 边界

| 负责 | 不负责 |
| ---- | ------ |
| overview → 链接指向的视角章节；确认书；冲突检查 | extract；distill；docs-build；docs-upgrade；SDD 终稿 |

## 最短路径

1. [gates.md](references/gates.md)
2. [workflow.md](references/workflow.md)（步骤 0–6；HARD-GATE 步骤 3→4）
3. [links-and-index.md](references/links-and-index.md)
4. [core-concepts.md](references/core-concepts.md)
5. [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md)
6. [brainstorming-integration.md](references/brainstorming-integration.md)
7. [quality-checklist.md](references/quality-checklist.md)、[gotchas.md](gotchas.md)
8. [archive-template.md](assets/archive-template.md)、[docs-archive-session-spec-template.md](assets/docs-archive-session-spec-template.md)

## 门禁

确认书与用户确认前 **禁止**写目标文档（[gates.md](references/gates.md)）。

## 产出

- Spec（可选）：`{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-docs-archive.md`
- 正式：目标章节增补；overview 按策略回写

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)。钩子：`python3 agent/hooks/sdx_gate_common.py --gate archive`（详 gates.md）。
