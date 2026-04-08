# 归档规范

docs-archive 归档阶段（步骤一）的范围界定、变更发现方式与产物格式。

---

## 系统侧范围（归档目标目录根目录 `system/architecture/` 全树）

**归档写入的归档目标目录根目录**指仓库根下 **`system/architecture/` 目录的全部约定子区域**，包括但不限于：

- `system/architecture/BUSINESS-ARCHITECTURE.md`、`system/architecture/TECHNICAL-ARCHITECTURE.md`、`system/architecture/DATA-ARCHITECTURE.md`、`system/architecture/PRODUCT-ARCHITECTURE.md` 四视角架构文档
- `system/INDEX_GUIDE.md`、`system/README.md`、`system/DESIGN.md`、`system/docs_meta.yaml` 等根级文件
- `system/changelogs/CHANGE-LOG.md`（批次归档总日志，文件不存在则创建）

---

## 变更发现方式（择一或组合）

| 方式 | 说明 |
|------|------|
| **Git diff** | 自上次归档标签/提交或用户给定区间，对应用知识库根目录 `system/application-{name}/`（或用户给定的应用知识路径）做 `git diff` / 文件列表统计 |
| **清单驱动** | 用户粘贴「已修改文件路径」列表 |
| **全量快照** | 无基线时，记录当前各应用 `INDEX_GUIDE.md` 及可归档路径（`BUSINESS-ARCHITECTURE.md`、`TECHNICAL-ARCHITECTURE.md`、`DATA-ARCHITECTURE.md`、`PRODUCT-ARCHITECTURE.md`）主要文件清单与哈希或行数摘要（轻量索引，非通读） |

---

## 归档产物

| 产物 | 路径 | 内容 |
|------|------|------|
| **批次归档** | `system/changelogs/CHANGE-LOG.md`（文件不存在则创建） | 按应用分节追加：变更文件路径、变更类型（新增/修改/删除）、一句话摘要、可选提交号 |
| **应用内留痕** | 应用知识库根目录下 `system/application-{name}/changelogs/ARCHIVE-LOG.md` | 追加本节归档锚点记录（用于下次增量起点） |
