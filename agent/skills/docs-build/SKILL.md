---
name: docs-build
description: >
  从五视角提取实体 ID，产出 per-entity {ID}.md、各视角 README、扫描生成 KNOWLEDGE_INDEX.md。依赖主 Index Guide。
  触发：初始化/同步知识实体、对齐 ID、docs-indexing 下游要实体等。
  分流：用户只要 INDEX、overview、归档或 SDD 为主路径 → 对应技能。
  门禁：Qclose-1 后须 docs-build-gate CONFIRMED 才写 {DOC_DIR}/knowledge/（见 gates.md）。
---

# docs-build（知识实体提取）

判定主路径 → 读 references/ → 会话 spec + Qclose-1 → 写 `{DOC_DIR}/knowledge/`。

## 边界

| 负责 | 不负责 |
|------|--------|
| 五视角 per-entity、README、KNOWLEDGE_INDEX、validate-extraction | INDEX_GUIDE；docs-okf 迁移；distill/extract；docs-archive；SDD |

## 最短路径

1. [gates.md](references/gates.md)
2. [workflow.md](references/workflow.md)
3. [interaction-gate.md](references/interaction-gate.md)
4. [builtin-config.md](references/builtin-config.md)、[extraction-rules.md](references/extraction-rules.md)
5. [readme-fill-spec.md](references/readme-fill-spec.md)、[consolidation-spec.md](references/consolidation-spec.md)
6. [core-concepts.md](references/core-concepts.md)、[brainstorming-integration.md](references/brainstorming-integration.md)
7. [quality-checklist.md](references/quality-checklist.md)、[gotchas.md](gotchas.md)
8. [docs-build-session-spec-template.md](assets/docs-build-session-spec-template.md)

## 门禁

阶段 1 后须 **Qclose-1**；`CONFIRMED` 前禁止写 `{DOC_DIR}/knowledge/`（[gates.md](references/gates.md)）。

## 产出

- Spec：`{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-docs-build.md`
- 产物：各视角 `{ID}.md`、README、KNOWLEDGE_INDEX.md

```bash
agent/skills/docs-build/scripts/validate-extraction.sh
```

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)。钩子：`python3 agent/hooks/sdx_gate_common.py --gate build`（详 gates.md）。
