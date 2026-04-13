---
name: docs-archive
description: >
  将应用知识库（system/application-{name}/）已核实内容归档到系统知识库（system/architecture/）。
  当用户执行 /docs-archive，或提到「归档」「同步应用知识到系统」「同步一下」「把应用侧内容推上去」
  「更新主库」「上行归档」「推送到系统库」「knowledge 归档」「SDD 归档」时必须触发本技能。
  支持 --app --since --full --dry-run，默认按增量锚点归档。
  即使用户只是说「帮我归档一下 billing」或「把最新的 analysis 同步上去」也应触发本技能。
---

# docs-archive：应用知识归档到系统库

> 把 `system/application-{name}/` 的可晋升内容归档到 `system/architecture/` 受管区块，并形成可追溯日志链路。

## 快速定向

| 需要做什么 | 去读 |
|-----------|------|
| 了解三日志职责、参数契约、原子顺序 | 本文件（继续往下读） |
| 闸门触发条件、会话 spec 标记、交互节奏 | [reference/interaction-gate.md](reference/interaction-gate.md) |
| 归档目标范围、变更发现方式、批次日志格式 | [reference/archive-spec.md](reference/archive-spec.md) |
| 联邦层级、knowledge 提炼规则、SDD 直接归档、归档顺序 | [reference/federation-spec.md](reference/federation-spec.md) |
| 锚点文件格式、增量范围逻辑、dry-run 约束 | [reference/archive-log-spec.md](reference/archive-log-spec.md) |
| 常见陷阱与完整自查清单 | [gotchas.md](gotchas.md) |
| 日志写入脚本（可直接执行） | [scripts/](scripts/)（见下文「脚本说明」） |

---

## 三日志职责（必须区分）

| 日志文件 | 职责 | 写入时机 |
|---------|------|---------|
| `system/application-{name}/changelogs/CHANGE-LOG.md` | 应用侧变更来源，定义可归档增量候选区间 | 步骤 0 读取，**本技能不写入** |
| `system/application-{name}/changelogs/ARCHIVE-LOG.md` | 应用侧归档锚点，记录已归档到哪个变更位置 | 归档成功后更新（步骤 3 最后执行） |
| `system/changelogs/CHANGE-LOG.md` | 系统侧归档批次总账，记录本次归档结果与范围 | 每次归档先写（步骤 3 先执行） |

---

## 参数契约

| 参数 | 默认 | 说明 |
|-----|------|------|
| `--app` | 全部已登记应用 | 仅处理指定应用，如 `billing`（对应 `system/application-billing/`） |
| `--since` | 从应用 `ARCHIVE-LOG.md` 锚点继续 | 手动指定起始变更点，覆盖自动锚点 |
| `--full` | `false` | 全量重建归档内容，但**仅覆盖目标文件中的受管区块**，区块外内容保持不变 |
| `--dry-run` | `false` | 仅预览不落盘，输出三层预览：候选变更区间、受影响目标文件/区块、将写入三日志的条目摘要 |

---

## 交互与确认闸门

写入前须完成**中间会话 spec + 用户总确认**（`PENDING` → `CONFIRMED`）。触发 HARD-GATE 时默认先 `--dry-run` 再落盘。完整触发条件表与推荐交互节奏见 [reference/interaction-gate.md](reference/interaction-gate.md)。

---

## 原子顺序（严格执行）

```
步骤 0  读取应用 CHANGE-LOG.md，结合 --since/--full 计算归档范围
步骤 1  提取可晋升内容，映射到 system/architecture/ 目标文件
步骤 2  写入系统归档目标（仅受管区块 BEGIN/END MANAGED BLOCK）
步骤 3a 先写 system/changelogs/CHANGE-LOG.md（系统总账）
步骤 3b 再写 system/application-{name}/changelogs/ARCHIVE-LOG.md（应用锚点前移）
```

**关键约束**：步骤 3a 失败时禁止执行步骤 3b；任意步骤 2 写入失败时禁止执行步骤 3。

---

## 命令示例

```bash
/docs-archive --app billing --dry-run
/docs-archive --app billing --since v1.2.0
/docs-archive --app billing --full
/docs-archive --app billing --since "2026-04-01T00:00:00Z" --dry-run
```

---

## 脚本说明

`scripts/` 目录提供可直接执行的日志写入脚本，**仅处理日志追加，不执行架构内容提炼写入**：

| 脚本 | 用途 | 何时使用 |
|-----|------|---------|
| `run-docs-archive.sh` | 最小可执行入口，支持 dry-run 三层预览与日志写入编排 | 步骤 0–3 的自动化入口 |
| `append-change-log.sh` | 向系统侧 `CHANGE-LOG.md` 追加批次记录 | 步骤 3a |
| `update-archive-log.sh` | 向应用侧 `ARCHIVE-LOG.md` 追加锚点记录 | 步骤 3b |

架构内容提炼（步骤 1–2）由 Agent 按 [reference/federation-spec.md](reference/federation-spec.md) 规则执行，脚本不覆盖此部分。

---

## 核心约束

- 默认增量，不重复归档已锚定区间
- `--full` 仅覆盖受管区块，不做全文件覆盖
- 禁止修改已有实体 ID；新增 ID 必须全局唯一
- 归档前先读目标文件，确认现有 ID 和字段结构
