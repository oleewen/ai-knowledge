---
name: sdx-solution
description: >
  产出共识级 SOLUTION-{IDEA-ID}.md（七章）与会话 spec。
  触发：/sdx-solution、「写方案」「整理业务目标」、需求模糊需结构化与 MVP。
  分流：用户只要 ANALYSIS/PRD/ASD/DSD 或 docs-distill/extract/indexing → 对应技能。
  门禁：总确认前禁写 {DOC_DIR}/solutions/SOLUTION-*.md（例外见 gates.md）。
compatibility: Bash 5+；钩子 python3 agent/hooks/sdx_gate_common.py --gate solution。
---

# sdx-solution

读 references/ → 会话 spec → 门禁 → SOLUTION 终稿。

## 边界

| 负责 | 不负责 |
|------|--------|
| SOLUTION-*.md、会话 spec、MVP/冲突共识（业务表述） | ANALYSIS/PRD/ASD/DSD/TDD；docs-* 主路径 |

## 路由

| 目的 | 文件 |
|------|------|
| 会话 spec 路径 | [session-spec-path.md](../../references/session-spec-path.md) |
| 门禁 | [gates.md](references/gates.md) |
| 流程 | [workflow.md](references/workflow.md) |
| brainstorming | [brainstorming-integration.md](references/brainstorming-integration.md) |
| IDEA-ID / depth | [core-concepts.md](references/core-concepts.md) |
| 原则 / 反模式 | [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md) |
| 易错 / 受众 / 终检 | [gotchas.md](gotchas.md)、[audience-and-language.md](references/audience-and-language.md)、[quality-checklist.md](references/quality-checklist.md) |
| 模板 | [solution-session-spec-template.md](assets/solution-session-spec-template.md)、[solution-template.md](assets/solution-template.md) |
| sdx 族结构 | [sdx-skill-skeleton.md](references/sdx-skill-skeleton.md) |

## 最少输入

- 原始业务描述（过短则先补）；IDEA-ID；门禁粒度（7G/5G）；`{DOC_DIR}/superpowers/specs/` 可写。

## 门禁

总确认前禁止 `{DOC_DIR}/solutions/SOLUTION-*.md`（[gates.md](references/gates.md)）。

## 产出与校验

- Spec：`{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-sdx-solution.md`
- 正式：`{DOC_DIR}/solutions/SOLUTION-{IDEA-ID}.md`

```bash
agent/skills/sdx-solution/scripts/validate-solution.sh
agent/skills/sdx-solution/scripts/validate-solution.sh --file path/to/SOLUTION-xxx.md --gate-check
```

## 评测 / 钩子

评测：`evals/evals.json`、[grader.md](agents/grader.md)。钩子：`python3 agent/hooks/sdx_gate_common.py --gate solution`。
