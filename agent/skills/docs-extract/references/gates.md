# docs-extract 门禁规则

[SKILL.md](../SKILL.md) 为主干；五阶段、参数与原子顺序见 [workflow.md](workflow.md)；交互节奏见 [interaction-gate.md](interaction-gate.md)。

---

## 核心门禁

- **总确认前，禁止进入阶段 4 的落盘**：即禁止写入 `system/architecture/overview/` 下目标 `*.md` 的**第三列**（**允许**阶段 1–3 的路径校验、关键词读取、段落筛选与 **`--dry-run` 预览**；dry-run 不产生上述落盘）。
- 合法例外**仅**在以下情形，且须在对话中留下明确依据：
  1. 用户在同一会话中**明示**跳过闸门、仅要预览、或授权直写。

除以上情形外，一律按门禁执行。`docs-extract` **不设**环境变量 bypass（与 [agent/rules/CONVENTIONS.md](../../../rules/CONVENTIONS.md#artifact-gates) 总表一致）。

---

## 门禁标记与 spec 约束

- Spec 路径：`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-extract.md`。
- 文末使用 `<!-- docs-extract-gate: PENDING -->`；用户总确认后改为 `<!-- docs-extract-gate: CONFIRMED -->`。
- Spec 正文须至少出现一次目标 overview 文件名形态：`XX-overview.md`（basename 与 `--overview` 一致）。

**文中至少写明**：`--sources` 路径列表、`--overview` 目标路径、命中段落数量与归属章节摘要、是否已 `--dry-run` 及结论摘要。

**门禁进度表锚点（与 sdx-* 对齐）**：若本会话草稿含与 `sdx-*` 会话 spec 同构的进度表，两列均应指向**本会话稿内**小节锚点。示例见 [`sdx-solution` 会话模板](../../sdx-solution/assets/solution-session-spec-template.md)「门禁进度」。

---

## HARD-GATE 触发条件（须先 dry-run 或取得总确认后再写入）

下列**任一**成立即进入 HARD-GATE：

| 触发条件 | 执行者动作 | 详细说明 |
|----------|------------|----------|
| 首次为某 overview 写入实质内容（第三列全为 `—` 或空） | 先 `--dry-run` 预览将写入的章节与摘要；总确认后再写入 | 见 [gotchas.md](../gotchas.md) |
| 命中段落数量异常多（例如 > 50） | 警告关键词可能过宽；建议收窄后再执行 | 见 gotchas「关键词过于宽泛」 |
| 源路径包含敏感文件名（如 `.env`、`credentials`、`secret`） | 警告并请用户确认是否继续 | — |
| overview 第三列已有大量内容且本次将触发多处 `[U]`（例如 > 10） | 先 `--dry-run` 展示变动摘要；总确认后再写入 | — |
| 阶段 4 步骤 **4.3** 写入**失败** | **整体回滚**，不做部分落盘 | 见 [workflow.md](workflow.md)「阶段 4 原子约束」 |

未列入上表、但 [gotchas.md](../gotchas.md) 要求「须警告并请用户确认」的情形，**同等适用** HARD-GATE 精神。

---

## 与 preToolUse 钩子

仓库 [hooks.json](../../../hooks.json) 已注册 `python3 agent/hooks/sdx_gate_common.py --gate extract`（`Write` / `StrReplace`）。放行规则与会话 spec、`CONFIRMED` 及目标文件名引用对齐；启用 Hooks 与会话激活条件见 [hooks/README.md](../../../hooks/README.md)。**规范真源**仍以本目录与 `SKILL.md` 为准；钩子未启用时执行者须在对话中同等遵守。
