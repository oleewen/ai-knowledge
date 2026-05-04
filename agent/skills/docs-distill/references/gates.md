# docs-distill 门禁规则

[SKILL.md](../SKILL.md) 为主干；五阶段、两日志、参数与原子顺序见 [workflow.md](workflow.md)；交互节奏见 [interaction-gate.md](interaction-gate.md)。

---

## 核心门禁

- **总确认前，禁止进入阶段 4 的落盘子步骤**：即禁止写入 `system/architecture/` 下受管 overview 内容及禁止向 `system/changelogs/DISTILL-LOG.md` 追加蒸馏记录（**允许**阶段 1–3 的读取、范围计算、`--dry-run` 预览；dry-run 不产生上述落盘）。
- 合法例外**仅**在以下情形，且须在对话中留下明确依据：
  1. 用户在同一会话中**明示**跳过闸门、仅要预览、或授权直写。
  2. 环境变量 **`DOCS_DISTILL_ALLOW_WRITE=1`**（仅限人工知情场景，类比 `SDX_DESIGN_ALLOW_DSD_WRITE=1`）。

除以上两项外，一律按门禁执行。

---

## 门禁标记与 spec 约束

- Spec 路径：`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-distill.md`。
- 文末使用 `<!-- docs-distill-gate: PENDING -->`；用户总确认后改为 `<!-- docs-distill-gate: CONFIRMED -->`。
- Spec 正文须至少出现一次目标 overview 文件名形态：`{APPNAME}-overview.md`（basename 与所选应用一致）。

**文中至少写明**（供审计与钩子对齐）：目标 `--app`（或声明处理全部已登记应用）、是否 `--full`、是否使用 `--since` 及其值、是否已执行 `--dry-run` 及结论摘要、是否为首次创建 overview（新建 vs 更新）。

**门禁进度表锚点（与 sdx-* 对齐）**：若本会话草稿含与 `sdx-*` 会话 spec 同构的进度表，两列均应指向**本会话稿内**小节锚点。示例见 [`sdx-solution` 会话模板](../../sdx-solution/assets/solution-session-spec-template.md)「门禁进度」。

---

## HARD-GATE 触发条件（须先 dry-run 或取得总确认后再写入）

下列**任一**成立即进入 HARD-GATE：

| 触发条件 | 执行者动作 | 详细说明 |
|----------|------------|----------|
| `--full` | 警告全量重新提炼风险；默认先 `--dry-run`；总确认后再写 | 见 [gotchas.md](../gotchas.md)「`--full` 参数误用」 |
| 应用 `ARCHIVE-LOG.md` 中的锚点 id 在应用 `CHANGE-LOG.md` 中找不到 | **不得**静默改为全量；说明风险并请用户选择修正锚点、手动 `--since` 或授权全量 | 见 gotchas「锚点 changelog_id…」 |
| 首次为某应用创建 overview（`{APPNAME}-overview.md` 不存在） | 须先 `--dry-run` 预览将创建的文件结构；总确认后再创建并写入 | 首次创建须用户确认结构 |
| 应用侧与系统侧内容冲突且无法按联邦规则自动消解 | 不强行覆盖；标为待人工确认或仅更新无争议区块 | 见 gotchas「应用侧与系统侧冲突时强行覆盖」 |
| 多应用均有待蒸馏区间且调用未带 `--app` | 列出候选应用与各自锚点；建议分应用 `--dry-run` 再分批确认 | 见 gotchas「多应用蒸馏」 |
| 阶段 4 步骤 **4.3**（overview 第三列写入）**失败** | **禁止**执行步骤 **4.4**（DISTILL-LOG） | 见 [workflow.md](workflow.md)「阶段 4 原子约束」 |

未列入上表、但 [gotchas.md](../gotchas.md) 要求「须警告并请用户确认」的情形，**同等适用** HARD-GATE 精神。

---

## 与 preToolUse 钩子

仓库 [hooks.json](../../../hooks.json) 已注册 `python3 agent/hooks/sdx_gate_common.py --gate distill`（`Write` / `StrReplace`）。放行规则与会话 spec、`CONFIRMED` 及目标文件名引用对齐；启用 Hooks 与会话激活条件见 [hooks/README.md](../../../hooks/README.md)。**规范真源**仍以本目录与 `SKILL.md` 为准；钩子未启用时执行者须在对话中同等遵守。
