# docs-build 门禁

主干 [SKILL.md](../SKILL.md)；流程 [workflow.md](workflow.md)；节奏 [interaction-gate.md](interaction-gate.md)。

## CONVENTIONS

[CONVENTIONS.md §artifact-gates](../../../rules/CONVENTIONS.md#artifact-gates)：docs-build **高风险** → `{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-docs-build.md`，`PENDING`→`CONFIRMED`，Hooks 下 `sdx_gate_common.py --gate build` 证据链。

## 核心

总确认前禁止写 `{DOC_DIR}/knowledge/`（`*_knowledge.json`、`README`、`KNOWLEDGE_INDEX` 等）。

例外：同会话用户**明示**跳过、只要草稿或授权直写。无 env bypass。

## spec 与标记

- 文末：`<!-- docs-build-gate: PENDING -->` → 总确认后 `CONFIRMED`
- 正文须含目标之一：`KNOWLEDGE_INDEX.md` 或本轮 `*_knowledge.json` / `README.md` basename

**Qclose-1**（阶段 1 末）：列视角、路径、文件清单，问：

> 是否按上述参数提取并写入 `{DOC_DIR}/knowledge/`？（C / M / S）

**C 或 S** 后改 `CONFIRMED`，进阶段 2。

进度表与 sdx 同构时锚到本会话内小节；例见 [sdx-solution 模板](../../sdx-solution/assets/solution-session-spec-template.md)「门禁进度」。

## 钩子

[hooks.json](../../../hooks.json)：`python3 agent/hooks/sdx_gate_common.py --gate build`。证据：`CONFIRMED` + 目标文件名。详 [hooks/README.md](../../../hooks/README.md)。
