# 归档规范

docs-archive 归档阶段（步骤一）的范围界定、变更发现方式与产物格式。

---

## 系统侧范围（system/ 全树）

**归档写入的系统知识库**指仓库根下 **`system/` 目录的全部约定子区域**，包括但不限于：

- `system/knowledge/`（四视角、constitution 等）
- `system/solutions/`、`system/analysis/`、`system/requirements/`、`system/specs/`
- `system/changelogs/upstream-from-applications/`（批次 `ARCHIVE-*.md`）
- 以及随本次变更需要维护的 `system/SYSTEM_INDEX.md`、`system/README.md`、`system/DESIGN.md`、`system/CONTRIBUTING.md`、`system/system_meta.yaml` 等根级文件

**不是**仅向 `system/knowledge/` 写入；具体落点由变更类型与 `--scope` 决定。

---

## 归档范围

- **主库联邦模式**：`applications/*/`（排除仅模板说明用的空壳目录，以用户指定为准）
- **主库独立模式**：`application/` 下应用文档
- **外仓**：用户给出路径列表或应用知识库根目录时，仅处理用户声明的应用知识根

归档内容涵盖应用侧所有子目录，按 `--scope` 参数控制：

| scope | 应用侧扫描路径 | 系统侧落点 |
|-------|-------------|-----------|
| `knowledge` | `knowledge/` | `system/knowledge/` |
| `solutions` | `solutions/` 或 `requirements/` 中的 SOLUTION-*.md | `system/solutions/` |
| `analysis` | `requirements/` 或 `analysis/` 中的 ANALYSIS-*.md | `system/analysis/` |
| `requirements` | `requirements/REQUIREMENT-*/` | `system/requirements/REQUIREMENT-*/` |
| `all`（默认） | 以上全部 | 以上全部 |

---

## 变更发现方式（择一或组合）

| 方式 | 说明 |
|------|------|
| **Git diff** | 自上次归档标签/提交或用户给定区间，对 `applications/`（或各应用知识路径）做 `git diff` / 文件列表统计 |
| **清单驱动** | 用户粘贴「已修改文件路径」列表 |
| **全量快照** | 无基线时，记录当前各应用 `INDEX_GUIDE.md` 及可归档路径（`knowledge/`、`solutions/`、`requirements/` 等）主要文件清单与哈希或行数摘要（轻量索引，非通读） |

---

## 归档产物

| 产物 | 路径 | 内容 |
|------|------|------|
| **批次归档** | `system/changelogs/upstream-from-applications/ARCHIVE-{YYYYMMDD}-{批次简述}.md`（目录不存在则创建） | 按应用分节：变更文件路径、变更类型（新增/修改/删除）、一句话摘要、可选提交号 |
| **应用内留痕** | `applications/<app>/CHANGELOG.md` 或 `applications/<app>/archive/promotion-notes.md` | 追加本节同步摘要，与应用 README 中联邦说明一致 |

### 批次归档文档格式

```markdown
## 应用 {app-name}（{APP-ID}）

**归档范围**：changelog {from_id} → {to_id}（{from_time} ～ {to_time}）

### knowledge 变更

| 路径 | 动作 | 摘要 |
|------|------|------|
| knowledge/technical/... | 修改 | 新增 MS-YYY 接口登记 |
| knowledge/business/...  | 新增 | BC-ZZZ 限界上下文定义 |

### SDD 文档归档

| 文档 | 类型 | 状态 |
|------|------|------|
| SOLUTION-{IDEA-ID}.md | 解决方案 | approved |
| ANALYSIS-{IDEA-ID}.md | 需求分析 | approved |
| REQUIREMENT-{IDEA-ID}/ | 需求交付包 | — |
```
