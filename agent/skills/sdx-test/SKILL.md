---
name: sdx-test
description: >-
  基于 PRD 与 **DSD**（及 **ASD**）产出测试设计 `TDD-{IDEA-ID}-{N}.md`（六章）与会话 spec：策略、用例、数据与环境、进出标准、回归范围。用于 `/sdx-test`，或口述「测试方案」「用例」「TDD」「进出标准」「PRD/DSD 转测试」。
  总确认前禁写 `{DOC_DIR}/requirements/**/TDD-*.md`（例外见 references/gates.md）。
  用户只要上游 SDX 正文（solution/analysis/prd/architect/design）或仅以 docs-distill/extract/archive/indexing/build 交付时，分流对应技能。不产出自动化代码与执行报告。
---

# sdx-test

顺序：**是否本技能 → 读 references → 会话 spec → 门禁 → 校验**。

读者：测试/质量主写；研发评审可执行性与和 DSD 一致。**上游**：`sdx-prd`（必需）；`sdx-architect`、`sdx-design`（推荐）。

---

## 边界

| 负责 | 不负责 |
|------|--------|
| `TDD-*.md`、会话 spec、`…-sdx-test.md`、G1–G6 / 精简 4G、进出与回归表述 | 自动化测试、测试报告；以 SOLUTION/ANALYSIS/PRD/ASD/DSD 替代本产物；**docs-*** 主路径 |

用户锁定其他产物时转对应 `sdx-*` 或 **docs-***。

---

## 最少输入

- **IDEA-ID**、**MVP 阶段 N**（与 PRD/DSD 路径一致）。
- 门禁粒度（6G / 精简 4G）、`--depth`（`quick` / `standard` / `deep`）。
- `{DOC_DIR}`、`docs/superpowers/specs/` 可写路径。

---

## 路由表

| 目的 | 文件 |
|------|------|
| 门禁与例外 | `references/gates.md` |
| 流程与 G{n} 要点 | `references/workflow.md` |
| brainstorming | `references/brainstorming-integration.md` |
| IDEA-ID、TC 前缀、`--depth` | `references/core-concepts.md` |
| 原则与异常处理 | `references/design-principles.md` |
| 边界类反模式 | `references/anti-patterns.md` |
| 操作易错 | `gotchas.md` |
| 受众与语言 | `references/audience-and-language.md` |
| 终检摘要 | `references/quality-checklist.md` |
| 模板 | 阶段二 `assets/test-session-spec-template.md`；阶段三 `assets/tdd-template.md` |

---

## 门禁

总确认前禁止写入 `{DOC_DIR}/requirements/**/TDD-*.md`。`PENDING` / `CONFIRMED` 见 `references/gates.md`。

---

## 阶段摘要

- **一**：锁定 IDEA-ID、门禁粒度、`--depth`（见 `workflow.md`、`core-concepts.md`）。
- **二**：`docs/superpowers/specs/…-sdx-test.md`；单次一段一点，末附 **C/M/S/F**（`gates.md`）。
- **三**：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/TDD-{IDEA-ID}-{N}.md`，按 `tdd-template.md` 分块与终检。

---

## 产出与校验

- 会话 spec：`docs/superpowers/specs/YYYY-MM-DD-<topic>-sdx-test.md`
- 正式：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/TDD-{IDEA-ID}-{N}.md`

```bash
agent/skills/sdx-test/scripts/validate-test.sh
agent/skills/sdx-test/scripts/validate-test.sh --file path/to/TDD-xxx.md --gate-check
```

---

## 评测

样本：`evals/evals.json`；元数据：`evals/eval-metadata-template.json`；评分：`agents/grader.md`；归因：`agents/analyzer.md`。

---

## 钩子

`python3 agent/hooks/sdx_gate_common.py --gate test`（`agent/hooks.json`，须启用 Hooks）。
