---
name: sdx-analysis
description: >
  在已共识 SOLUTION 上细化 FR/MVP/依赖/风险，产出 ANALYSIS-{IDEA-ID}.md（六章）与会话 spec。
  触发：/sdx-analysis、「拆 MVP」「需求分析」「细化方案」且可对齐上游 SOLUTION。
  分流：无 SOLUTION、只要其他 SDX 阶段或 docs-* 主路径 → 对应技能。
  门禁：总确认前禁写 {DOC_DIR}/analysis/ANALYSIS-*.md（例外见 gates.md）。
compatibility: Bash 5+；钩子 python3 agent/hooks/sdx_gate_common.py --gate analysis。
---

# sdx-analysis

读 references/ → 会话 spec → 门禁 → ANALYSIS 终稿。无 SOLUTION → 引导 sdx-solution。

## 边界

| 负责 | 不负责 |
|------|--------|
| ANALYSIS-*.md、基于 SOLUTION 的细化 | SOLUTION 初稿；PRD/ASD/DSD；docs-* 主路径 |

## 路由

| 目的 | 文件 |
|------|------|
| 会话 spec 路径 | [session-spec-path.md](../../references/session-spec-path.md) |
| 门禁 | [gates.md](references/gates.md) |
| 流程（含公司库） | [workflow.md](references/workflow.md) |
| brainstorming | [brainstorming-integration.md](references/brainstorming-integration.md) |
| IDEA-ID / depth | [core-concepts.md](references/core-concepts.md) |
| 原则 / 反模式 / 受众 | [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md)、[audience-and-language.md](references/audience-and-language.md) |
| 终检 / 易错 | [quality-checklist.md](references/quality-checklist.md)、[gotchas.md](gotchas.md) |
| 模板 | [analysis-session-spec-template.md](assets/analysis-session-spec-template.md)、[analysis-template.md](assets/analysis-template.md) |

## 最少输入

- 可对齐的 **SOLUTION-{IDEA-ID}.md**；IDEA-ID 一致；门禁粒度（6G/4G）；`{DOC_DIR}/analysis/` 可写。

## 门禁

总确认前禁止 `{DOC_DIR}/analysis/ANALYSIS-*.md`（[gates.md](references/gates.md)）。

## 产出与校验

- Spec：`{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-sdx-analysis.md`
- 正式：`{DOC_DIR}/analysis/ANALYSIS-{IDEA-ID}.md`

```bash
agent/skills/sdx-analysis/scripts/validate-analysis.sh
agent/skills/sdx-analysis/scripts/validate-analysis.sh --file path/to/ANALYSIS-xxx.md --gate-check
```

## 评测 / 钩子

评测：`evals/evals.json`、[grader.md](agents/grader.md)。钩子：`python3 agent/hooks/sdx_gate_common.py --gate analysis`。
