# 归档规范

docs-archive 归档阶段（步骤一）的范围界定、变更发现方式与产物格式。

---

## 归档范围

- **主库联邦模式**：`applications/*/`（排除仅模板说明用的空壳目录，以用户指定为准）
- **主库独立模式**：`application/` 下应用文档
- **外仓**：用户给出路径列表或应用知识库根目录时，仅处理用户声明的应用知识根（与 `INDEX_GUIDE.md`、`knowledge/` 同级树）

---

## 变更发现方式（择一或组合）

| 方式 | 说明 |
|------|------|
| **Git diff** | 自上次归档标签/提交或用户给定区间，对 `applications/`（或各应用知识路径）做 `git diff` / 文件列表统计 |
| **清单驱动** | 用户粘贴「已修改文件路径」列表 |
| **全量快照** | 无基线时，记录当前各应用 `INDEX_GUIDE.md`、`knowledge/` 下主要文件清单与哈希或行数摘要（轻量索引，非通读） |

---

## 归档产物

| 产物 | 路径 | 内容 |
|------|------|------|
| **批次归档** | `system/changelogs/upstream-from-applications/ARCHIVE-{YYYYMMDD}-{批次简述}.md`（目录不存在则创建） | 按应用分节：变更文件路径、变更类型（新增/修改/删除）、一句话摘要、可选提交号 |
| **应用内留痕** | `applications/<app>/CHANGELOG.md` 或 `applications/<app>/archive/promotion-notes.md` | 追加本节同步摘要，与应用 README 中联邦说明一致 |

### 批次归档文档格式

```markdown
## 应用 {app-name}（{APP-ID}）

| 路径 | 动作 | 摘要 |
|------|------|------|
| knowledge/technical/... | 修改 | 新增 MS-YYY 接口登记 |
| knowledge/business/...  | 新增 | BC-ZZZ 限界上下文定义 |
```
