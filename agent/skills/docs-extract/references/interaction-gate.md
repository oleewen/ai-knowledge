# docs-extract 交互与确认闸门

与 `docs-distill` 采用同一话语体系：**中间会话 spec → 用户总确认 → 落盘**。差异在于：`docs-extract` **无** `DISTILL-LOG` / 应用蒸馏锚点；「按次任务从 `--sources` 扫描」**不等于**对整张 overview 做 `docs-distill --full` 式全量重炼。

**硬规则与触发条件表**见 [gates.md](gates.md)；**阶段、参数、原子顺序**见 [workflow.md](workflow.md)。

**目录**：[与 docs-distill 对齐](#与-docs-distill-对齐的约定) · [推荐交互节奏](#推荐交互节奏) · [与钩子](#与钩子)

---

## 与 docs-distill 对齐的约定

| 概念 | 对齐方式 |
|------|----------|
| 中间会话 spec | `docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-extract.md` |
| 用户总确认 | `PENDING` → `CONFIRMED`（见 [gates.md](gates.md)） |
| 合法例外 | 同会话明示（见 gates） |
| 预览优先 | HARD-GATE 场景下**先** `--dry-run` |

---

## 推荐交互节奏

1. **上下文探索**：读 overview 关键词附录；枚举 `--sources` 规模；必要时对照 [extract-spec.md](extract-spec.md) 与 [gotchas.md](../gotchas.md)。
2. **触发 HARD-GATE 时**：先 `--dry-run`，展示命中段落摘要与 A/U/D 变动列表。
3. **单次一个待确认点**：范围 / 风险 / 授权之一。多方案节奏见 [brainstorming-integration.md](brainstorming-integration.md)。
4. **用户总确认后**：执行 [workflow.md](workflow.md) 阶段 4；失败则整体回滚。

---

## 与钩子

- 仓库已在 [hooks.json](../../../hooks.json) 注册 `python3 agent/hooks/sdx_gate_common.py --gate extract`。
- 证据与会话 spec 中 `docs-extract-gate: CONFIRMED` 及目标 overview basename 对齐；会话激活与排查见 [hooks/README.md](../../../hooks/README.md)。
