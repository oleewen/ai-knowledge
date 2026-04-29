# docs-distill 交互与确认闸门

与 SDD 各阶段的 **sdx-*-gate** 采用同一话语体系，便于复用「中间会话 spec → 用户总确认 → 落盘」的节奏。差异在于：sdx 已提供 `preToolUse` 写入拦截，**docs-distill 当前不设独立钩子**，执行者须在对话中遵守下表（IDE 不代为拦截）。

**目录**：[与 sdx-*-gate 对齐](#与-sdx--gate-对齐的约定) · [HARD-GATE 触发条件](#hard-gate默认禁止落盘) · [会话 spec 与门禁标记](#中间会话-spec-与门禁标记) · [推荐交互节奏](#推荐交互节奏brainstorming-机制子集) · [与钩子的关系](#与校验脚本钩子的关系)

---

## 与 sdx-*-gate 对齐的约定

| 概念 | 对齐方式 |
|------|----------|
| 中间会话 spec | 路径：`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-distill.md`（与 `sdx-design` 等同级目录） |
| 用户总确认 | 会话 spec 文末标记由 `PENDING` 改为 `CONFIRMED`（见下文「门禁标记」） |
| 合法例外 | 用户在同一会话中**明示**跳过闸门、仅要预览、或授权直写；或环境变量 **`DOCS_DISTILL_ALLOW_WRITE=1`**（仅限人工知情场景，类比 `SDX_DESIGN_ALLOW_ADD_WRITE=1`） |
| 预览优先 | 触发 HARD-GATE 时，**先** `--dry-run`，再谈是否落盘 |

---

## HARD-GATE（默认禁止落盘）

在取得 **用户总确认**（会话 spec 中 `CONFIRMED`，或同会话明示授权）之前，**禁止**执行 [上级 SKILL.md](../SKILL.md) 中原子顺序的**步骤 2–4**（写入 `system/architecture/`、写入 `system/changelogs/DISTILL-LOG.md`）。

**允许**的步骤：步骤 0–1 的读取、范围计算、提取与映射规划；以及**仅预览**的 `--dry-run`（不产生上述落盘）。

下列**任一**成立即进入 HARD-GATE（须先 dry-run 或取得总确认后再写入）：

| 触发条件 | 执行者动作 | 详细说明 |
|----------|------------|----------|
| `--full` | 警告全量重新提炼风险；默认先 `--dry-run`；总确认后再写 | 见 [gotchas.md](../gotchas.md)「`--full` 参数误用」 |
| 应用 `ARCHIVE-LOG.md` 中的锚点 id 在应用 `CHANGE-LOG.md` 中找不到 | **不得**静默改为全量；说明风险并请用户选择修正锚点、手动 `--since` 或授权全量 | 见 gotchas「锚点 changelog_id…」 |
| 首次为某应用创建 overview 文件（`{APPNAME}-overview.md` 不存在） | 须先 `--dry-run` 预览将创建的文件结构（文件名、标题、五架构视角章节数）；总确认后再创建并写入 | 首次创建会生成新文件，须用户确认文件结构符合预期 |
| 应用侧与系统侧内容冲突且无法按联邦规则自动消解 | 不强行覆盖；标为待人工确认或仅更新无争议区块 | 见 gotchas「应用侧与系统侧冲突时强行覆盖」 |
| 多应用均有待蒸馏区间且调用未带 `--app` | 列出候选应用与各自锚点；建议先按应用分别 `--dry-run` 再分批确认 | 见 gotchas「多应用蒸馏」 |
| 步骤 3 写入**失败** | **禁止**执行步骤 4（保持「overview 写入先于 DISTILL-LOG」原子约束） | 见上级 SKILL「原子顺序」 |

未列入上表、但 [gotchas.md](../gotchas.md) 要求「须警告并请用户确认」的情形，**同等适用** HARD-GATE 精神：先说明事实与选项，再写入。

---

## 中间会话 spec 与门禁标记

**路径**：`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-distill.md`

**文末标记**（与 sdx 一致，仅换前缀名）：

- 总确认前：`<!-- docs-distill-gate: PENDING -->`
- 用户总确认后：`<!-- docs-distill-gate: CONFIRMED -->`

**文中至少写明**（供后续审计与可能的自动化对齐）：目标 `--app`（或声明处理全部已登记应用）、是否 `--full`、是否使用 `--since` 及其值、是否已执行 `--dry-run` 及结论摘要、是否为首次创建 overview 文件（新建 vs 更新）。

**门禁进度表锚点（与 sdx-* 对齐）**：若本会话草稿含「门禁」「覆盖模板」等与 `sdx-*` 会话 spec 同构的进度表，两列均应使用指向**本会话稿内**小节锚点。示例见 [`sdx-solution` 会话模板](../../sdx-solution/assets/solution-session-spec-template.md)「门禁进度」。

---

## 推荐交互节奏（brainstorming 机制子集）

1. **上下文探索**：读取应用 `CHANGE-LOG.md`、`ARCHIVE-LOG.md`，必要时对照 [distill-log-spec.md](distill-log-spec.md) 与 gotchas。
2. **触发 HARD-GATE 时**：先 `--dry-run`，展示候选区间、受影响路径与日志摘要。
3. **单次一个待确认点**：优先选择题或「范围 / 风险 / 授权」三要素之一；避免一次抛出无关问题（与 `sdx-design` 阶段二「每次只呈现一段」同构）。
4. **用户总确认后**：再执行原子顺序步骤 2–4；失败则按 gotchas 回滚语义处理，不前移锚点。

---

## 与校验脚本、钩子的关系

- 若仓库后续为 `system/architecture/**` 或蒸馏日志路径增加 `preToolUse` 钩子，建议复用 **`docs-distill-gate: PENDING|CONFIRMED`** 与上述会话 spec 路径，与 **sdx-*-gate** 的 `CONFIRMED` + 文件名引用模式保持一致。
- 在此之前，以本文件与 [上级 SKILL.md](../SKILL.md) 为**规范来源**。
