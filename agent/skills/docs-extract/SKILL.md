---
name: docs-extract
description: >
  按段落关键词相关度从 --sources 提炼业务知识，写入 --overview 第三列（A/U/D）；支持 --dry-run。不写 DISTILL-LOG。
  触发：/docs-extract、「提炼进 overview」「从设计文档整理进知识库」等。
  分流：用户只要 docs-distill/archive/indexing 或 SDD 为主路径 → 对应技能。
  门禁：阶段 3 未 CONFIRMED 禁止阶段 4（docs-extract-gate；见 gates.md）。
---

# docs-extract：任意源 → overview 第三列

判定主责 → 读 references/ → 段落筛选 → 更新第三列。

## 边界

| 负责 | 不负责 |
|------|--------|
| 任意源 → overview 第三列；A/U/D；docs-extract-gate | docs-distill 上行；docs-archive；docs-indexing；SDD 终稿 |

## 最短路径

1. [gates.md](references/gates.md)
2. [workflow.md](references/workflow.md)
3. [interaction-gate.md](references/interaction-gate.md)
4. [core-concepts.md](references/core-concepts.md)
5. [extract-spec.md](references/extract-spec.md)
6. [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md)
7. [quality-checklist.md](references/quality-checklist.md)
8. [gotchas.md](gotchas.md)
9. [brainstorming-integration.md](references/brainstorming-integration.md)
10. [docs-extract-session-spec-template.md](assets/docs-extract-session-spec-template.md)

## 门禁

阶段 3 未 `CONFIRMED` → **禁止**阶段 4（[gates.md](references/gates.md)）。

## 产出

- Spec：`{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-docs-extract.md`
- 正式：`--overview` 第三列更新

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)。钩子：`python3 agent/hooks/sdx_gate_common.py --gate extract`（详 gates.md）。
