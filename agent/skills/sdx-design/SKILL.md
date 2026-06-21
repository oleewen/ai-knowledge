---
name: sdx-design
description: >
  产出 DSD（§1–§3）：唯一正式详设；把 ASD §3 或 spec-asd-*.md 扩写到实现级（API、DDL、错误码、幂等）。
  触发：/sdx-design、编写/修改 DSD、validate-dsd。**不写 ASD**。
  分流：docs-* 主路径或只要其他 SDX 阶段 → 对应技能。
  门禁：总确认前禁写 {DOC_DIR}/requirements/**/DSD-*.md（例外见 gates.md）。
compatibility: Bash 5+；config-bootstrap；钩子 python3 agent/hooks/sdx_gate_common.py --gate design。
---

# 详细设计（sdx-design）

判主责 → 会话 spec → CONFIRMED → **DSD**。**不写 ASD**。上游：ASD-* 和/或 `{DOC_DIR}/specs/spec-asd-*.md` + PRD（同 IDEA-ID、{N}）。

## 边界

| 负责 | 不负责 |
|------|--------|
| DSD §1–§3、Gd/Qclose、§2 实现级契约 | ASD/PRD/TDD 顶替详设；docs-* 主线 |

## 路由

| 目的 | 文件 |
|------|------|
| 索引 | [references/README.md](references/README.md) |
| 会话 spec 路径 | [session-spec-path.md](../../references/session-spec-path.md) |
| 门禁 / 流程（含前置） | [gates.md](references/gates.md)、[workflow.md](references/workflow.md) |
| brainstorming | [brainstorming-integration.md](references/brainstorming-integration.md) |
| KNOWLEDGE_TYPE | [knowledge-type-modes.md](../sdx-architect/references/knowledge-type-modes.md) |
| 原则 / 反模式 / 受众 / 终检 | [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md)、[audience-and-language.md](references/audience-and-language.md)、[quality-checklist.md](references/quality-checklist.md) |
| 易错 / 评测 schema | [gotchas.md](gotchas.md)、[schemas.md](references/schemas.md) |
| 模板 | [design-session-spec-template.md](assets/design-session-spec-template.md)、[dsd-template.md](assets/dsd-template.md)；spec-asd 对齐 [asd-spec-template](../sdx-architect/assets/asd-spec-template.md) |

## 最少输入

- **PRD**（硬）；**ASD 和/或 spec-asd**；IDEA-ID、{N}、`{DOC_DIR}/superpowers/specs/`。

## 门禁

总确认前禁止 `{DOC_DIR}/requirements/**/DSD-*.md`（[gates.md](references/gates.md)）。

## 产出与校验

- Spec：`{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-sdx-design.md`
- DSD：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/DSD-{IDEA-ID}-{N}.md`

```bash
agent/skills/sdx-design/scripts/validate-dsd.sh
agent/skills/sdx-design/scripts/validate-dsd.sh --file path/to/DSD-xxx.md --gate-check
```

## 评测 / 钩子

评测：`evals/evals.json`、[grader.md](agents/grader.md)。钩子：`python3 agent/hooks/sdx_gate_common.py --gate design`。
