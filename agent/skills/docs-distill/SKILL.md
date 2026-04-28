---
name: docs-distill
description: >
  将应用知识库（system/application-{name}/）已核实内容蒸馏后写入系统知识库（system/architecture/overview/{APPNAME}-overview.md）。
  只要用户提到以下任意一种意图，就应立即触发本技能，不要等用户明确说出命令名：
  「知识蒸馏」「提炼应用知识到系统」「同步应用知识到系统」「把应用侧内容提炼后推上去」「更新主库」「上行蒸馏」
  「推送到系统库」「knowledge 蒸馏」「SDD 蒸馏」「生成 overview」「更新 overview」「overview 需要更新」
  「应用知识有变更要同步」「帮我蒸馏一下 {app}」「把最新变更同步上去」「系统库需要刷新」。
  支持 --app --since --full --dry-run，默认按增量锚点蒸馏。
  用户执行 /docs-distill 时必须触发。
---

# docs-distill：应用知识蒸馏并上行到系统库

> 把 `system/application-{name}/` 的可晋升内容蒸馏后写入 `system/architecture/overview/{APPNAME}-overview.md`，形成以应用为单位的完整知识快照。可追溯性通过日志链路维护——overview 正文不记录来源（不写 `(来源：...)`、出处、参见链接），保持内容干净。

## 快速定向

| 需要做什么 | 去读 | 何时打开 |
|-----------|------|---------|
| 两日志职责、参数契约、原子顺序 | 本文件（继续往下读） | 每次执行前 |
| 闸门触发条件、会话 spec 标记、交互节奏 | [reference/interaction-gate.md](reference/interaction-gate.md) | 任意写入前；`--full` / 锚点异常 / 冲突 / 多应用 |
| 蒸馏目标范围、变更发现方式 | [reference/distill-spec.md](reference/distill-spec.md) | 定蒸馏范围时 |
| 联邦层级、overview 提炼规则、五架构视角顺序 | [reference/federation-spec.md](reference/federation-spec.md) | 步骤 4.2–4.3 写入时 |
| 锚点文件格式、增量范围逻辑、dry-run 约束 | [reference/distill-log-spec.md](reference/distill-log-spec.md) | 步骤 1 读锚点、步骤 4.4 更新锚点时 |
| 常见陷阱与完整自查清单 | [gotchas.md](gotchas.md) | 遇到异常或执行完毕自查时 |
| 日志写入脚本（可直接执行） | [scripts/](scripts/)（见下文「脚本说明」） | 步骤 4.4 |

---

## 两日志职责（必须区分）

两个日志文件职责不同，混淆会导致锚点错位或漏蒸馏：

| 日志文件 | 职责 | 写入时机 |
|---------|------|---------|
| `system/application-{name}/changelogs/CHANGE-LOG.md` | 应用侧变更来源，定义可蒸馏增量候选区间 | 阶段 1 读取，**本技能不写入** |
| `system/changelogs/DISTILL-LOG.md` | 蒸馏记录，兼作锚点：记录每次蒸馏结果与范围，下次增量从该应用最新一条继续（含 `app` 列） | 蒸馏成功后写入（阶段 4 步骤 4.4） |

---

## 参数契约

| 参数 | 默认 | 说明 |
|-----|------|------|
| `--app` | 全部已登记应用 | 仅处理指定应用，如 `billing-appeal`（对应 `system/application-billing-appeal/`） |
| `--since` | 从应用 `ARCHIVE-LOG.md` 锚点继续 | 手动指定起始变更点，覆盖自动锚点 |
| `--full` | `false` | 全量重新提炼所有章节，忽略锚点 |
| `--dry-run` | `false` | 仅预览不落盘，输出三层预览：候选变更区间、目标文件状态、将写入 DISTILL-LOG 的条目摘要 |

---

## 交互与确认闸门

写入前须完成**Spec草稿 + 用户总确认**（`PENDING` → `CONFIRMED`）。这个节奏的目的是让用户在落盘前看到蒸馏范围和影响面，避免意外覆盖。触发 HARD-GATE 时默认先 `--dry-run` 再落盘。完整触发条件表与推荐交互节奏见 [reference/interaction-gate.md](reference/interaction-gate.md)。

HARD-GATE 固定在**阶段 3 与阶段 4 之间**。

**门禁标记**：会话 spec 中使用 `<!-- docs-distill-gate: PENDING -->`，用户总确认后改为 `<!-- docs-distill-gate: CONFIRMED -->`，且正文须出现目标文件名（basename）。本 gate **无 bypass 环境变量**，须完整走确认流程；唯一例外是用户在同一对话中明示跳过。

---

## 工作流（五阶段）

| 阶段 | 名称 | 摘要 | 详见 |
|------|------|------|------|
| 1 | EXPLORE | 读应用 CHANGE-LOG.md + ARCHIVE-LOG.md；计算蒸馏范围 | [distill-log-spec.md](reference/distill-log-spec.md) |
| 2 | CLARIFY | 确认 --app / --since / --full 参数；首次创建 overview 时确认文件结构；单次一问 | [interaction-gate.md](reference/interaction-gate.md) |
| 3 | CONFIRM（HARD-GATE）| dry-run 展示候选区间、受影响路径、三日志摘要；会话 spec 标记 CONFIRMED 后解锁阶段 4 | [interaction-gate.md](reference/interaction-gate.md) |
| 4 | EXECUTE | 4.1 检查/创建 overview 文件 → 4.2 读应用知识库 → 4.3 提炼写入第三列 → 4.4 写入 DISTILL-LOG | [federation-spec.md](reference/federation-spec.md) |
| 5 | CLOSE | 变更摘要；DISTILL-LOG 最新在前（新记录插入表头分隔行之后、上一条记录之前）；不自动 git commit | — |

> **HARD-GATE**：阶段 3 会话 spec 标记 CONFIRMED 前，禁止执行阶段 4（写入 `system/architecture/`、写入 DISTILL-LOG）。dry-run 属于阶段 3，不单独占阶段。

**阶段 4 原子约束**：4.3 写入失败时禁止执行 4.4。

---

## 命令示例

```bash
/docs-distill --app billing-appeal --dry-run
/docs-distill --app billing-appeal --since v1.2.0
/docs-distill --app billing-appeal --full
/docs-distill --app billing-appeal
```

---

## 脚本说明

`scripts/` 目录提供可直接执行的日志写入脚本，**仅处理日志写入，不执行内容提炼**。两个日志脚本均采用**最新在前**策略：新记录插入表头分隔行之后、上一条记录之前。

| 脚本 | 用途 | 写入路径 | 何时使用 |
|-----|------|---------|---------|
| `run-docs-distill.sh` | 最小可执行入口，支持 dry-run 三层预览与日志写入编排；须从项目根目录执行（或 `--root` 指定） | — | 阶段 4 步骤 4.4 的自动化入口 |
| `append-change-log.sh` | 向 `system/changelogs/DISTILL-LOG.md` 写入蒸馏记录（含 `app` 列，最新在前）；兼作锚点来源 | `system/changelogs/DISTILL-LOG.md` | 阶段 4 步骤 4.4 |

内容提炼（阶段 4 步骤 4.2–4.3）由 Agent 按 [reference/federation-spec.md](reference/federation-spec.md) 规则执行，脚本不覆盖此部分。

---

## 核心约束

- 默认增量，不重复蒸馏已锚定区间——这样多次执行是安全的
- `--full` 重新提炼全部章节，不受锚点限制；使用前先 `--dry-run` 确认影响面
- 蒸馏内容已按五架构视角逐节写入 `{APPNAME}-overview.md` 第三列
- 写入到 `{APPNAME}-overview.md` 第三列的知识正文不记录来源（不写 `(来源：...)`、出处、参见链接等）
- 蒸馏前先读目标文件，确认现有内容（用于判断 A/U/D）

---

## 工程化支持

仓库 [agent/hooks.json](../../hooks.json) 注册了 `preToolUse` 钩子（`Write` / `StrReplace`），脚本见 [agent/hooks/sdx_gate_common.py](../../hooks/sdx_gate_common.py)（`python3 agent/hooks/sdx_gate_common.py --gate distill`）；需启用 Hooks 方生效。

钩子证据校验逻辑：检查 `docs/superpowers/specs/` 下是否存在包含 `<!-- docs-distill-gate: CONFIRMED -->` 且引用目标文件名的 spec 文件；未通过则拒绝写入。**本 gate 无 bypass 环境变量。**
