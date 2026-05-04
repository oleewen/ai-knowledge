# docs-distill 核心概念

[SKILL.md](../SKILL.md) 为主干；术语与联邦细节另见 [federation-spec.md](federation-spec.md)、[distill-log-spec.md](distill-log-spec.md)。

---

## 标识与路径

| 术语 | 含义 |
|------|------|
| `{name}` / `{APPNAME}` | 应用目录名，如 `billing-appeal`；与 `system/application-{name}/` 段一致 |
| `{APPNAME}-overview.md` | 系统侧产物：`system/architecture/overview/{APPNAME}-overview.md` |
| `changelog_id` | `CHANGE-LOG.md` 条目的稳定标识，用于锚点与 DISTILL-LOG；规则见 distill-log-spec |

---

## 日志与锚点（摘要）

- **应用 `CHANGE-LOG.md`**：增量候选来源；本技能不写入。
- **`DISTILL-LOG.md`**：蒸馏历史 + 下次增量锚点；按 `app` 列取该应用**最新一条**（文件内最新在前）。
- **`ARCHIVE-LOG.md`（应用侧）**：与批次归档相关的锚点上下文；与 `CHANGE-LOG` 联读，详见 distill-log-spec。

---

## 写入语义

- **第三列**：overview 表格中业务知识列；须提炼为系统级摘要，标注 **A/U/D**（增/改/删）。
- **A/U/D**：相对上一版第三列内容；无变化可不标（按 federation-spec 与 gotchas 执行）。
