# 蒸馏范围与变更发现

**写目标**与表格体例：**[federation-spec.md](federation-spec.md)**。本节：源范围、产物清单。

## 边

| `DOC_DIR` | 源（仅槽位） | 目标 |
| --- | --- | --- |
| `system` | `system/application-slots/application-{NAME}/` | `system/knowledge/overview/{NAME}-overview.md` |
| `company` | `company/system-slots/system-{NAME}/` | `company/knowledge/overview/{NAME}-overview.md` |

目标不存在则用同层 `NAME-overview.md` 模板，**文件名与 `# {NAME} 架构概览` 同步替换**。

以下内容**仅来源**，不单列作蒸馏终稿：各视角长篇、槽位内 knowledge、SDD 目录。

**不写** `DISTILL-LOG`；无增量锚点。模式恒全量。

## 变更发现

本技能**仅全量**：读槽位内 knowledge + SDD 全量作源，与目标 overview 第三列按 federation-spec 去重后写 delta。

可选辅助（不改变「仅全量」契约）：

| 方式 | 说明 |
| ---- | ---- |
| 清单 | 用户给已改路径列表，作阅读优先提示 |
| Git diff | 对槽位 path 的 diff，作阅读优先提示 |

## 产物

| 产物 | 路径 | 内容 |
| ---- | ----- | ----- |
| overview | `{DOC_DIR}/knowledge/overview/{NAME}-overview.md` | 五视角表；第三列 + A/U/D |
