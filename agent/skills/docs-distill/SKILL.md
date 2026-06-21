---
name: docs-distill
description: >
  将 system/application-{name}/ 已核实内容蒸馏写入 system/knowledge/overview/{APPNAME}-overview.md 第三列。
  触发：/docs-distill、「知识蒸馏」「更新 overview」「同步应用知识」等。
  分流：用户只要 docs-extract/archive/indexing 或仅 SDD → 对应技能。
  门禁：阶段 3 未 CONFIRMED 禁止阶段 4 落盘（docs-distill-gate；见 gates.md）。
---

# docs-distill：应用 → 系统 overview

判定归属 → 读 references/ → 门禁 → 更新 overview 第三列与 DISTILL-LOG。第三列不写来源脚注。

## 边界

| 负责 | 不负责 |
| ---- | ------ |
| 已核实应用 → overview 第三列；增量/全量；DISTILL-LOG；会话 spec | docs-extract；docs-archive；docs-indexing；SDD 终稿代写 |

## 最短路径

1. [gates.md](references/gates.md)
2. [workflow.md](references/workflow.md)
3. [interaction-gate.md](references/interaction-gate.md)
4. [core-concepts.md](references/core-concepts.md)
5. [distill-spec.md](references/distill-spec.md)、[distill-log-spec.md](references/distill-log-spec.md)
6. [federation-spec.md](references/federation-spec.md)
7. [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md)
8. [quality-checklist.md](references/quality-checklist.md)
9. [gotchas.md](gotchas.md)
10. [brainstorming-integration.md](references/brainstorming-integration.md)
11. [docs-distill-session-spec-template.md](assets/docs-distill-session-spec-template.md)

## 门禁

阶段 3 未 **CONFIRMED**（无合法例外）→ 禁止阶段 4（[gates.md](references/gates.md)）。

## 产出

- Spec：`{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-docs-distill.md`
- `{APPNAME}-overview.md` 第三列；`system/changelogs/DISTILL-LOG.md`（4.3 成功后）

```bash
agent/skills/docs-distill/scripts/run-docs-distill.sh --help
```

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)。钩子：`python3 agent/hooks/sdx_gate_common.py --gate distill`（详 gates.md）。
