# 核心概念

联邦与细节：[federation-spec.md](federation-spec.md)、[distill-log-spec.md](distill-log-spec.md)。

## 路径与标识

| 术语 | 含义 |
| ------ | ------ |
| `{name}`/`{APPNAME}` | 应用目录名（如 `billing-appeal`），与 `system/application-{name}/` 一致 |
| `{APPNAME}-overview.md` | `system/knowledge/overview/` 下产物 |
| `changelog_id` | CHANGE-LOG 条目稳定 id；规则见 distill-log-spec |

## 日志（摘要）

- **应用 CHANGE-LOG**：候选增量；本技能**不写**。
- **DISTILL-LOG**：历史 + 下次锚点；按 **`app` 列取该应用最新一行**（文件内最新在前）。
- **应用 `ARCHIVE-LOG.md`**：与批次锚点联读 → distill-log-spec。

## 第三列语义

业务知识列：系统级**摘要**，标 **A/U/D**（相对上一版第三列）；无变化可不标（以 federation-spec、gotchas 为准）。
