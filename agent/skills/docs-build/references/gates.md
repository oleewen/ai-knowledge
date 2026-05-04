# docs-build 门禁规则

[SKILL.md](../SKILL.md) 为主干；四阶段流程与参数见 [workflow.md](workflow.md)；会话节奏见 [interaction-gate.md](interaction-gate.md)。

---

## 与 CONVENTIONS 对齐

按 [agent/rules/CONVENTIONS.md](../../../rules/CONVENTIONS.md#artifact-gates) 总表，**docs-build 为高风险**：须 **`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-build.md`** + `PENDING` → `CONFIRMED` + **`sdx_gate_common.py --gate build`** 证据链（启用 Hooks 且会话已激活时）。

---

## 核心门禁

- **总确认前，禁止写入** `{DOC_DIR}/knowledge/` 下任意受管文件（各视角 `*_knowledge.json`、`README.md`、`KNOWLEDGE_INDEX.md` 等）。
- 合法例外**仅**：用户在同一会话中**明示**跳过闸门、仅要草稿、或授权直写。
- **无**环境变量 bypass（与 CONVENTIONS 一致）。

---

## 门禁标记与 spec 约束

- 文末：`<!-- docs-build-gate: PENDING -->` → 总确认后 `<!-- docs-build-gate: CONFIRMED -->`。
- 正文须至少出现目标文件名形态之一：`KNOWLEDGE_INDEX.md` 或具体视角 `*_knowledge.json` / `README.md`（basename 与本轮写入一致）。
- **Qclose-1**（阶段 1 完成后）：展示将写入的视角、路径与文件清单，询问：

  > 是否同意以上述参数执行知识实体提取并写入 `{DOC_DIR}/knowledge/`？（C 确认 / M 修改参数 / S 跳过）

  收到 **C / S** 后将 `PENDING` 改为 `CONFIRMED`，进入阶段 2。

**门禁进度表锚点（与 sdx-* 对齐）**：若会话草稿含与 `sdx-*` 同构的进度表，两列锚到**本会话稿内**小节。示例见 [`sdx-solution` 会话模板](../../sdx-solution/assets/solution-session-spec-template.md)「门禁进度」。

---

## 与 preToolUse 钩子

仓库 [hooks.json](../../../hooks.json) 注册 `python3 agent/hooks/sdx_gate_common.py --gate build`。证据：`docs-build-gate: CONFIRMED` + 目标文件名引用。详见 [hooks/README.md](../../../hooks/README.md)。
