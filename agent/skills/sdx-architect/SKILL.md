---
name: sdx-architect
description: >
  基于 PRD/ANALYSIS 产出 ASD（§1/§2/§3），可选 `{DOC_DIR}/specs/spec-asd-*.md`（asd-spec-template）。
  用于服务边界、架构图、服务变更表、系统/公司联邦概要（KNOWLEDGE_TYPE=system|company）或 ASD 终稿。
  不写 DSD/实现级 API·DDL/spec-dsd-*.md 全文 → /sdx-design；主路径为 SOLUTION/ANALYSIS/PRD/TDD 或 docs-* → 对应 sdx-/docs- 技能。
  门禁：未「用户总确认」不得写 `{DOC_DIR}/requirements/**/ASD-*.md`（例外见 references/gates.md）。
compatibility: 仓库根 Bash 5+；`scripts/config-bootstrap.sh` 解析 `DOC_ROOT`；校验见正文。
---

# 架构设计（sdx-architect）

主责判定 → 按需读 `references/` → 会话草稿与用户总确认 → 可校验 **ASD**。

## 路由

| 主路径 | 技能 |
|--------|------|
| docs-distill / extract / archive / indexing | 对应 **docs-*** |
| 只要 SOLUTION / ANALYSIS / PRD / TDD，不要 ASD | 对应 **sdx-*** |
| API/DDL、spec-dsd-*.md、DSD | **[sdx-design](../sdx-design/SKILL.md)** |
| ASD、架构边界、服务变更、规约摘要、可选 **spec-asd-*.md** | **本技能** |

**负责**：`assets/asd-template.md`、`asd-stub-sections-federated.md`、可选 **`spec-asd-*.md`**（`assets/asd-spec-template.md`）、`assets/architect-session-spec-template.md`。  
**不负责**：DSD、详设规约全文（`spec-dsd-*.md`）。

## 输入（落盘前最少）

- `PRD`（必需）、`ANALYSIS`（推荐）、`.docsconfig` 的 `KNOWLEDGE_TYPE`（建议）  
- 不全则先澄清，不写正式 ASD。

## 执行路由（先读后写）

1. `references/gates.md`
2. `references/workflow.md`
3. `references/quality-checklist.md`
4. 歧义时：`references/anti-patterns.md`、`references/knowledge-type-modes.md`
5. 样式：`assets/asd-template.md`、`assets/samples/mini-asd-example.md`

## 门禁

- 总确认前禁止写 `{DOC_DIR}/requirements/**/ASD-*.md`。  
- 例外：用户明确放行，或 `SDX_ARCHITECT_ALLOW_ASD_WRITE=1`。草稿状态与 `--gate-check` 见 `references/gates.md`。

## 产出与校验

- 正式：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/ASD-{IDEA-ID}-{N}.md`

仓库根执行：

```bash
agent/skills/sdx-architect/scripts/validate-asd.sh
agent/skills/sdx-architect/scripts/validate-asd.sh --file path/to/ASD-xxx.md --gate-check
```

或在 `agent/skills/sdx-architect/` 下：`./scripts/validate-asd.sh`（参数同上）。

## 评测

`evals/evals.json`、`evals/eval-metadata-template.json`、`agents/grader.md`、`agents/analyzer.md`。

## 工程化

Hooks：`python3 agent/hooks/sdx_gate_common.py --gate architect`（仓库根；见 `agent/hooks.json`）。
