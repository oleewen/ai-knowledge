# docs-indexing 门禁规则

[SKILL.md](../SKILL.md) 为主干；六步流程与参数见 [workflow.md](workflow.md)；会话节奏见 [interaction-gate.md](interaction-gate.md)。

---

## 与 CONVENTIONS 对齐

按 [agent/rules/CONVENTIONS.md](../../../rules/CONVENTIONS.md#artifact-gates) 总表，**docs-indexing 为高风险**：须 **`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-indexing.md`** + `PENDING` → `CONFIRMED` + **`sdx_gate_common.py --gate indexing`** 证据链（启用 Hooks 且会话已激活时）。

---

## 双层确认

1. **参数面（Qclose-1，会话内）**：`mode` / `depth` / `output` / `since` 须经用户 **C/M/S** 确认（与 [workflow.md](workflow.md) 步骤 2 一致）。摘要建议写入会话 spec 正文，便于审计。
2. **写入面（落盘 spec）**：在未将 `<!-- docs-indexing-gate: PENDING -->` 改为 **`CONFIRMED`** 前，禁止 `Write` / `StrReplace` 写入受管的 `INDEX_GUIDE.md` 或 `*/changelogs/INDEXING-LOG.md`。

---

## 路径证据（与同 basename 多文件）

仓库内可能存在多份 `INDEX_GUIDE.md`（如根、`application/`、`system/`）及多份 `*/changelogs/INDEXING-LOG.md`。钩子除 `CONFIRMED` 标记外，要求会话 spec 正文**逐字包含**本轮将写入的**仓库根相对路径**（例如 `application/INDEX_GUIDE.md`、`application/changelogs/INDEXING-LOG.md`），与工具 payload 归一化后一致方可放行。

---

## 门禁标记与 spec 约束

- 文末：`<!-- docs-indexing-gate: PENDING -->` → 用户总确认后 `<!-- docs-indexing-gate: CONFIRMED -->`。
- **无**环境变量 bypass（与 CONVENTIONS 一致）。

---

## 与 preToolUse 钩子

仓库 [hooks.json](../../../hooks.json) 注册 `python3 agent/hooks/sdx_gate_common.py --gate indexing`。详见 [hooks/README.md](../../../hooks/README.md)。
