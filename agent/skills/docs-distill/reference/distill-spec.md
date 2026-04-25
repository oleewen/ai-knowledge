# 蒸馏规范

docs-distill 蒸馏阶段（步骤 2–3）的范围界定、变更发现方式与产物格式。

**目录**：[系统侧范围](#系统侧范围蒸馏目标) · [变更发现方式](#变更发现方式择一或组合) · [蒸馏产物](#蒸馏产物)

---

## 系统侧范围（蒸馏目标）

蒸馏写入的唯一目标文件：

```
system/architecture/overview/{APPNAME}-overview.md
```

文件不存在时以 `system/architecture/overview/NAME-overview.md` 为模板创建（替换 NAME → APPNAME）。

以下文件**仅作为知识来源**，不直接蒸馏：
- `system/architecture/business/`、`product/`、`application/`、`technical/`、`data/` 下各视角详细文档
- 应用侧 knowledge YAML/MD
- 应用侧 SDD 文档（solutions/analysis/requirements）

日志文件（不变）：
- `system/changelogs/DISTILL-LOG.md`（蒸馏记录，兼作锚点，所有应用共用，含 `app` 列，文件不存在则创建）

---

## 变更发现方式（择一或组合）

| 方式 | 说明 |
|------|------|
| **Git diff** | 自上次蒸馏标签/提交或用户给定区间，对应用知识库根目录 `system/application-{name}/` 做 `git diff` / 文件列表统计 |
| **清单驱动** | 用户粘贴「已修改文件路径」列表 |
| **全量快照** | 无基线时，读取应用侧 knowledge 和 SDD 文档全量内容作为提炼来源 |

---

## 蒸馏产物

| 产物 | 路径 | 内容 |
|------|------|------|
| **overview 蒸馏** | `system/architecture/overview/{APPNAME}-overview.md` | 五架构视角完整知识快照，第三列含变动标识（A/U/D） |
| **蒸馏记录** | `system/changelogs/DISTILL-LOG.md`（文件不存在则创建） | 所有应用共用，含 `app` 列；记录变更文件路径、变更类型、一句话摘要；兼作下次增量锚点 |
