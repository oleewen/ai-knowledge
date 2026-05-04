# docs-distill 工作流

[SKILL.md](../SKILL.md) 为主干；写入类门禁与例外见 [gates.md](gates.md)。

---

## 两日志职责（必须区分）

| 日志文件 | 职责 | 写入时机 |
|---------|------|----------|
| `system/application-{name}/changelogs/CHANGE-LOG.md` | 应用侧变更来源，定义可蒸馏增量候选区间 | 阶段 1 读取，**本技能不写入** |
| `system/changelogs/DISTILL-LOG.md` | 蒸馏记录，兼作锚点（按 `app` 列过滤取该应用最新一条） | 阶段 4 步骤 4.4，且须在 4.3 成功后 |

混淆会导致锚点错位或漏蒸馏。

---

## 参数契约

| 参数 | 默认 | 说明 |
|-----|------|------|
| `--app` | 全部已登记应用 | 仅处理指定应用，如 `billing-appeal`（对应 `system/application-billing-appeal/`） |
| `--since` | 从应用 `ARCHIVE-LOG.md` 与 DISTILL-LOG 推导的锚点继续 | 手动指定起始变更点，覆盖自动锚点 |
| `--full` | `false` | 全量重新提炼所有章节，忽略锚点 |
| `--dry-run` | `false` | 仅预览不落盘：候选变更区间、目标文件状态、将写入 DISTILL-LOG 的条目摘要 |

---

## 五阶段与硬门禁

| 阶段 | 名称 | 摘要 | 详见 |
|------|------|------|------|
| 1 | EXPLORE | 读应用 `CHANGE-LOG.md`、`ARCHIVE-LOG.md`；计算蒸馏范围 | [distill-log-spec.md](distill-log-spec.md) |
| 2 | CLARIFY | 确认 `--app` / `--since` / `--full`；首次创建 overview 时确认文件结构；单次一问 | [interaction-gate.md](interaction-gate.md) |
| 3 | CONFIRM（HARD-GATE） | `dry-run` 展示候选区间、受影响路径、日志摘要；spec 标记 `CONFIRMED` 后解锁阶段 4 | [gates.md](gates.md) |
| 4 | EXECUTE | 4.1 检查/创建 overview → 4.2 读应用知识库 → 4.3 提炼写入第三列 → 4.4 写入 DISTILL-LOG | [federation-spec.md](federation-spec.md) |
| 5 | CLOSE | 变更摘要；DISTILL-LOG **最新在前**；不自动 `git commit` | — |

**HARD-GATE**：阶段 3 未 `CONFIRMED` 前，禁止执行阶段 4（写入 `system/architecture/`、写入 DISTILL-LOG）。`dry-run` 属于阶段 3。

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

`scripts/` **仅处理日志编排与写入**，不执行内容提炼。新记录均采用**最新在前**策略。

| 脚本 | 用途 | 写入路径 | 何时使用 |
|-----|------|---------|----------|
| `run-docs-distill.sh` | 入口：`dry-run` 预览与日志写入编排；须从仓库根执行或 `--root` | — | 阶段 4 步骤 4.4 |
| `append-change-log.sh` | 向 DISTILL-LOG 追加记录（含 `app` 列） | `system/changelogs/DISTILL-LOG.md` | 阶段 4 步骤 4.4 |

阶段 4 步骤 4.2–4.3 由 Agent 按 [federation-spec.md](federation-spec.md) 执行。

---

## 核心约束（执行摘要）

- 默认增量，锚定区间安全可重入。
- `--full` 须先 `dry-run` 再落盘。
- 第三列按五架构视角逐节写入；正文不记录来源（不写 `(来源：…)`、出处、参见链接）。
- 写入前须读目标 overview，用于 A/U/D 判断。
