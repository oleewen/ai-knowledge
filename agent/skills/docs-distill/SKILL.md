---
name: docs-distill
description: >
  将应用知识库（system/application-{name}/）已核实内容蒸馏后写入系统知识库（system/architecture/overview/{APPNAME}-overview.md）。
  当用户执行 /docs-distill，或提到「知识蒸馏」「提炼应用知识到系统」「同步应用知识到系统」「把应用侧内容提炼后推上去」
  「更新主库」「上行蒸馏」「推送到系统库」「knowledge 蒸馏」「SDD 蒸馏」「生成 overview」「更新 overview」时必须触发本技能。
  支持 --app --since --full --dry-run，默认按增量锚点蒸馏。
  即使用户只是说「帮我蒸馏一下 billing」或「把最新的变更同步上去」也应触发本技能。
---

# docs-distill：应用知识蒸馏并上行到系统库

> 把 `system/application-{name}/` 的可晋升内容蒸馏后写入 `system/architecture/overview/{APPNAME}-overview.md`，形成以应用为单位的完整知识快照，并维护可追溯日志链路。

## 快速定向

| 需要做什么 | 去读 |
|-----------|------|
| 了解三日志职责、参数契约、原子顺序 | 本文件（继续往下读） |
| 闸门触发条件、会话 spec 标记、交互节奏 | [reference/interaction-gate.md](reference/interaction-gate.md) |
| 蒸馏目标范围、变更发现方式、批次日志格式 | [reference/archive-spec.md](reference/archive-spec.md) |
| 联邦层级、overview 提炼规则、五架构视角蒸馏顺序 | [reference/federation-spec.md](reference/federation-spec.md) |
| 锚点文件格式、增量范围逻辑、dry-run 约束 | [reference/archive-log-spec.md](reference/archive-log-spec.md) |
| 常见陷阱与完整自查清单 | [gotchas.md](gotchas.md) |
| 日志写入脚本（可直接执行） | [scripts/](scripts/)（见下文「脚本说明」） |

---

## 三日志职责（必须区分）

| 日志文件 | 职责 | 写入时机 |
|---------|------|---------|
| `system/application-{name}/changelogs/CHANGE-LOG.md` | 应用侧变更来源，定义可蒸馏增量候选区间 | 步骤 0 读取，**本技能不写入** |
| `system/application-{name}/changelogs/ARCHIVE-LOG.md` | 应用侧蒸馏锚点，记录已蒸馏到哪个变更位置 | 蒸馏成功后更新（步骤 4 最后执行） |
| `system/changelogs/CHANGE-LOG.md` | 系统侧蒸馏批次总账，记录本次蒸馏结果与范围 | 每次蒸馏先写（步骤 4a 先执行） |

---

## 参数契约

| 参数 | 默认 | 说明 |
|-----|------|------|
| `--app` | 全部已登记应用 | 仅处理指定应用，如 `billing-appeal`（对应 `system/application-billing-appeal/`） |
| `--since` | 从应用 `ARCHIVE-LOG.md` 锚点继续 | 手动指定起始变更点，覆盖自动锚点 |
| `--full` | `false` | 全量重新提炼所有章节，忽略锚点 |
| `--dry-run` | `false` | 仅预览不落盘，输出三层预览：候选变更区间、目标文件状态、将写入三日志的条目摘要 |

---

## 交互与确认闸门

写入前须完成**Spec草稿 + 用户总确认**（`PENDING` → `CONFIRMED`）。触发 HARD-GATE 时默认先 `--dry-run` 再落盘。完整触发条件表与推荐交互节奏见 [reference/interaction-gate.md](reference/interaction-gate.md)。

---

## 原子顺序（严格执行）

```
步骤 0  读取应用 CHANGE-LOG.md，结合 --since/--full 计算蒸馏范围

步骤 1  检查 system/architecture/overview/{APPNAME}-overview.md 是否存在
        - 不存在：以 NAME-overview.md 为模板创建，替换 NAME → APPNAME
        - 存在：则继续下一步

步骤 2  读取应用侧 knowledge（四视角 YAML/MD）+ SDD 文档，作为提炼的知识来源
        （这些文档不再是蒸馏目标，仅作为提炼的输入）

步骤 3  读取 {APPNAME}-overview.md 五架构视角知识索引表，
        逐条读取副标题列文件链接对应章节的「应填内容 + 产出建议」要求和已有内容，
        从应用知识库提炼相应业务知识，并判断知识变动标识（A/U/D），
        写入第三列（完整内容快照，含变动标识）

步骤 4a 先写 system/changelogs/CHANGE-LOG.md（系统总账）
步骤 4b 再写 system/application-{name}/changelogs/ARCHIVE-LOG.md（应用锚点前移）
```

**关键约束**：步骤 4a 失败时禁止执行步骤 4b；步骤 3 写入失败时禁止执行步骤 4。

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

`scripts/` 目录提供可直接执行的日志写入脚本，**仅处理日志追加，不执行内容提炼写入**：

| 脚本 | 用途 | 何时使用 |
|-----|------|---------|
| `run-docs-distill.sh` | 最小可执行入口，支持 dry-run 三层预览与日志写入编排 | 步骤 0–4 的自动化入口（承载 docs-distill 工作流） |
| `append-change-log.sh` | 向系统侧 `CHANGE-LOG.md` 追加批次记录 | 步骤 4a |
| `update-archive-log.sh` | 向应用侧 `ARCHIVE-LOG.md` 追加锚点记录 | 步骤 4b |

内容提炼（步骤 1–3）由 Agent 按 [reference/federation-spec.md](reference/federation-spec.md) 规则执行，脚本不覆盖此部分。

---

## 核心约束

- 默认增量，不重复蒸馏已锚定区间
- `--full` 重新提炼全部章节，不受锚点限制
- 蒸馏内容已按五架构视角逐节写入 `{APPNAME}-overview.md` 第三列
- 蒸馏前先读目标文件，确认现有内容（用于判断 A/U/D）
