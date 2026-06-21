---
name: sdx-prd
description: >
  将 ANALYSIS 当前 MVP 细化为 PRD（十一章）：用户故事、用例、流程、验收。
  触发：/sdx-prd、「写 PRD」「细化用户故事/业务流程」。
  分流：无 SOLUTION/ANALYSIS、只要其他 SDX 或 docs-* 主路径 → 对应技能。
  门禁：总确认前禁写 {DOC_DIR}/requirements/**/PRD-*.md（例外见 gates.md）。
compatibility: Bash 5+；config-bootstrap 解析 DOC_ROOT；钩子 python3 agent/hooks/sdx_gate_common.py --gate prd。
---

# 产品需求（sdx-prd）

判主责 → 读 references/ → 会话 spec → PRD 终稿（十一章）。

## 边界

| 负责 | 不负责 |
|------|--------|
| PRD-*.md、MVP-Phase-{N} 内 US/UC/FR/BR/AC | SOLUTION/ANALYSIS 初稿；ASD/DSD；docs-* 主线 |

## 路由

| 目的 | 文件 |
|------|------|
| 会话 spec 路径 | [session-spec-path.md](../../references/session-spec-path.md) |
| 门禁 | [gates.md](references/gates.md) |
| 流程（含前置、公司库） | [workflow.md](references/workflow.md) |
| brainstorming | [brainstorming-integration.md](references/brainstorming-integration.md) |
| 口径 / 原则 / 反模式 | [core-concepts.md](references/core-concepts.md)、[design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md) |
| 易错 / 受众 / 终检 | [gotchas.md](gotchas.md)、[audience-and-language.md](references/audience-and-language.md)、[quality-checklist.md](references/quality-checklist.md) |
| 模板 | [prd-session-spec-template.md](assets/prd-session-spec-template.md)、[prd-template.md](assets/prd-template.md) |

## 最少输入

- **ANALYSIS-{IDEA-ID}.md** 含目标 MVP（缺则 sdx-analysis）；IDEA-ID 与 **N** 与路径一致。

## 门禁

总确认前禁止 `{DOC_DIR}/requirements/**/PRD-*.md`（[gates.md](references/gates.md)）。

## 产出与校验

- Spec：`{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-sdx-prd.md`
- PRD：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-{IDEA-ID}-{N}.md`

```bash
agent/skills/sdx-prd/scripts/validate-prd.sh
agent/skills/sdx-prd/scripts/validate-prd.sh --file path/to/PRD-xxx.md --gate-check
```

## 评测 / 钩子

评测：`evals/evals.json`、[grader.md](agents/grader.md)。钩子：`python3 agent/hooks/sdx_gate_common.py --gate prd`。
