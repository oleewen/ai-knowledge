---
name: sdx-architect
description: >
  基于 PRD（ANALYSIS 推荐）产出 ASD §1–§3；可选 `spec-asd-*.md`（asd-spec-template）。
  覆盖服务边界、架构图、服务变更表；KNOWLEDGE_TYPE=system|company 时为联邦概要。
  实现级 API/DDL 与 **DSD（详设文档）** → /sdx-design；仅里程碑或 docs-* → 对应 sdx-/docs- 技能。
  触发：ASD、边界、变更、§3 规约摘要或 spec-asd-*。
  门禁：未经「用户总确认」不写 `{DOC_DIR}/requirements/**/ASD-*.md`（例外见 references/gates.md）。
compatibility: Bash 5+（仓库根）；`scripts/config-bootstrap.sh` 解析 `DOC_ROOT`；校验方式见正文。
---

# sdx-architect（架构设计）

判定主路径 → 读 `references/` → 草稿与总确认 → 落盘 ASD 并校验。

## 路由

| 诉求 | 技能 |
|------|------|
| 会话 spec 路径 | [session-spec-path.md](../../references/session-spec-path.md) |
| docs-distill / extract / archive / indexing | **docs-*** |
| SOLUTION / ANALYSIS / PRD / TDD，不要 ASD | 对应 **sdx-*** |
| API/DDL、DSD | [sdx-design](../sdx-design/SKILL.md) |
| ASD、边界、变更、规约摘要、可选 spec-asd-*.md | **本技能** |

产物：`asd-template`、`asd-stub-sections-federated`、会话 spec、`asd-spec-template`（spec-asd-*）。不含 **DSD** 全文。

## 输入（落盘前）

- PRD（必需）；ANALYSIS、`.docsconfig` 中 `KNOWLEDGE_TYPE`（建议）
- 缺项先澄清，不落正式 ASD

## 阅读顺序（先读后写）

1. `references/gates.md` → `workflow.md` → `brainstorming-integration.md` → `quality-checklist.md`
2. 歧义：`anti-patterns.md`、`knowledge-type-modes.md`
3. 结构：`assets/asd-template.md`、`assets/samples/mini-asd-example.md`

## 门禁

总确认前禁止 `{DOC_DIR}/requirements/**/ASD-*.md`；例外见 `references/gates.md`（含 `SDX_ARCHITECT_ALLOW_ASD_WRITE=1`、`--gate-check`）。

## 产出与校验

- **会话 spec**：`*/specs/YYYY-MM-DD-<topic>-sdx-architect.md`（路径契约：[session-spec-path.md](../../references/session-spec-path.md)）
- **ASD**：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/ASD-{IDEA-ID}-{N}.md`

```bash
# 仓库根
agent/skills/sdx-architect/scripts/validate-asd.sh
agent/skills/sdx-architect/scripts/validate-asd.sh --file path/to/ASD-xxx.md --gate-check
```

在 `agent/skills/sdx-architect/`：`./scripts/validate-asd.sh`（同上参数）。

## 评测

见 `evals/`、`agents/grader.md`、`agents/analyzer.md`。

## 工程化

`python3 agent/hooks/sdx_gate_common.py --gate architect`（仓库根，`agent/hooks.json`）。