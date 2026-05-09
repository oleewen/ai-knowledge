# 工作流

主干：[SKILL.md](../SKILL.md)；写入门禁：[gates.md](gates.md)。

## 两日志

| 文件 | 职责 | 本技能写入 |
| ---- | ----- | --------- |
| `system/application-{name}/changelogs/CHANGE-LOG.md` | 增量候选来源 | **否** |
| `system/changelogs/DISTILL-LOG.md` | 记录 + 锚点（按 **`app`** 取该应用最新一条） | **是**（4.3 成功后） |

混用会导致锚点错、漏蒸馏。

## 参数

| 参数 | 默认 | 说明 |
| ---- | ----- | ---- |
| `--app` | 全部已登记 | 指定应用目录名 |
| `--since` | 自动推导 | 覆盖锚点起点 |
| `--full` | 否 | 全量忽略锚点；须先门禁与预览 |
| `--dry-run` | 否 | 仅预览区间、目标状态、拟写 DISTILL-LOG |

## 五阶段

| 阶段 | 名 | 要点 |
| ---- | ----- | ----- |
| 1 EXPLORE | 读 CHANGE-LOG、应用 `ARCHIVE-LOG.md`（若有）；算范围 | [distill-log-spec.md](distill-log-spec.md) |
| 2 CLARIFY | 确认 `--app`/`--since`/`--full`；单次一问 | [interaction-gate.md](interaction-gate.md) |
| 3 CONFIRM | HARD-GATE：`dry-run`、spec **CONFIRMED** 后解锁 4 | [gates.md](gates.md) |
| 4 EXECUTE | 4.1 overview 检查/创建 → 4.2 读应用知识 → **4.3 写第三列** → **4.4 DISTILL-LOG** | [federation-spec.md](federation-spec.md) |
| 5 CLOSE | 摘要；DISTILL **最新在前**；不自动 commit | — |

**HARD-GATE**：阶段 3 未 `CONFIRMED` → 禁止阶段 4（含 `system/architecture/` overview 内容与 DISTILL-LOG）。`dry-run` 属阶段 3。  
**原子**：**4.3 失败禁止 4.4**。

## 命令示例

```bash
/docs-distill --app billing-appeal --dry-run
/docs-distill --app billing-appeal --since v1.2.0
/docs-distill --app billing-appeal --full
/docs-distill --app billing-appeal
```

## 脚本

`scripts/`：**编排日志**，不代工「内容提炼」。新记录一律**最新在前**。

| 脚本 | 用途 |
| ---- | ---- |
| `run-docs-distill.sh` | `--dry-run` / 编排；仓库根或 `--root` |
| `append-change-log.sh` | 追加 DISTILL-LOG（含 `app`） |

内容提炼步骤 4.2–4.3：`federation-spec.md`。

## 执行摘要

- 默认增量；`--full` 须先预览与确认。
- 第三列五视角逐节写；不写 `(来源…)`。
- 落盘前先读现有 overview，做 **A/U/D**。
