# docs-distill 交互与确认闸门

与 SDD **sdx-*-gate** 同构的「中间会话 spec → 用户总确认 → 落盘」节奏。**硬规则与触发条件表**见 [gates.md](gates.md)；**阶段、参数、脚本**见 [workflow.md](workflow.md)。

**目录**：[与 sdx-*-gate 对齐](#与-sdx--gate-对齐的约定) · [推荐交互节奏](#推荐交互节奏) · [与钩子](#与钩子)

---

## 与 sdx-*-gate 对齐的约定

| 概念 | 对齐方式 |
|------|----------|
| 中间会话 spec | `docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-distill.md` |
| 用户总确认 | `PENDING` → `CONFIRMED`（见 [gates.md](gates.md)） |
| 合法例外 | 同会话明示或 `DOCS_DISTILL_ALLOW_WRITE=1`（见 gates） |
| 预览优先 | HARD-GATE 场景下**先** `--dry-run` |

---

## 推荐交互节奏

1. **上下文探索**：读取应用 `CHANGE-LOG.md`、`ARCHIVE-LOG.md`，必要时对照 [distill-log-spec.md](distill-log-spec.md) 与 [gotchas.md](../gotchas.md)。
2. **触发 HARD-GATE 时**：先 `--dry-run`，展示候选区间、受影响路径与日志摘要。
3. **单次一个待确认点**：优先选择题或「范围 / 风险 / 授权」之一（与 `sdx-design` 阶段二「每次只呈现一段」同构）。嵌入多方案节奏见 [brainstorming-integration.md](brainstorming-integration.md)。
4. **用户总确认后**：再执行 [workflow.md](workflow.md) 阶段 4；失败则按 gotchas 回滚语义处理，不前移锚点。

---

## 与钩子

- 仓库已在 [hooks.json](../../../hooks.json) 注册 `preToolUse` → `python3 agent/hooks/sdx_gate_common.py --gate distill`（与 sdx-* 同源实现）。
- 钩子证据与会话 spec 中 `docs-distill-gate: CONFIRMED` 及目标文件名引用对齐；会话激活与排查见 [hooks/README.md](../../../hooks/README.md)。
- 钩子未命中或禁用时，仍以 [gates.md](gates.md) 与 [SKILL.md](../SKILL.md) 为执行约束。
