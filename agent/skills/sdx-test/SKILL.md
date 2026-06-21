---
name: sdx-test
description: >
  基于 PRD 与 DSD（及 ASD）产出 TDD-{IDEA-ID}-{N}.md（六章）与会话 spec：策略、用例、进出标准、回归范围。
  触发：/sdx-test、「测试方案」「用例」「TDD」「PRD/DSD 转测试」。
  分流：只要上游 SDX 正文或 docs-* 主路径 → 对应技能。不产出自动化代码与执行报告。
  门禁：总确认前禁写 {DOC_DIR}/requirements/**/TDD-*.md（例外见 gates.md）。
compatibility: Bash 5+；钩子 python3 agent/hooks/sdx_gate_common.py --gate test。
---

# sdx-test

读 references/ → 会话 spec → 门禁 → TDD 终稿。上游：**PRD**（必需）；**DSD/ASD**（推荐）。

## 边界

| 负责 | 不负责 |
|------|--------|
| TDD-*.md、G1–G6/4G、进出与回归表述 | 自动化测试/报告；以其他 SDX 替代 TDD；docs-* 主路径 |

## 路由

| 目的 | 文件 |
|------|------|
| 会话 spec 路径 | [session-spec-path.md](../../references/session-spec-path.md) |
| 门禁 / 流程（含阶段摘要） | [gates.md](references/gates.md)、[workflow.md](references/workflow.md) |
| brainstorming | [brainstorming-integration.md](references/brainstorming-integration.md) |
| IDEA-ID / depth | [core-concepts.md](references/core-concepts.md) |
| 原则 / 反模式 / 受众 / 终检 | [design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md)、[audience-and-language.md](references/audience-and-language.md)、[quality-checklist.md](references/quality-checklist.md) |
| 易错 | [gotchas.md](gotchas.md) |
| 模板 | [test-session-spec-template.md](assets/test-session-spec-template.md)、[tdd-template.md](assets/tdd-template.md) |

## 最少输入

- IDEA-ID、MVP 阶段 **N**（与 PRD/DSD 一致）；门禁粒度（6G/4G）；`--depth`。

## 门禁

总确认前禁止 `{DOC_DIR}/requirements/**/TDD-*.md`（[gates.md](references/gates.md)）。

## 产出与校验

- Spec：`{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-sdx-test.md`
- TDD：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/TDD-{IDEA-ID}-{N}.md`

```bash
agent/skills/sdx-test/scripts/validate-test.sh
agent/skills/sdx-test/scripts/validate-test.sh --file path/to/TDD-xxx.md --gate-check
```

## 评测 / 钩子

评测：`evals/evals.json`、[grader.md](agents/grader.md)。钩子：`python3 agent/hooks/sdx_gate_common.py --gate test`。
