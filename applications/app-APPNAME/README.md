# 应用知识库根目录 — 应用级知识库

**应用知识库根目录**（本仓库模板物理路径为 `applications/app-APPNAME/`，供初始化脚本引用）为**应用联邦单元**模板：其下 `knowledge/`、`requirements/`、`changelogs/` 与中央库 `system/` **同构对齐**，由 [knowledge-init.sh](../../scripts/knowledge-init.sh) 等拷贝到目标工程（常见为 `docs/`）。路径与命令以仓库根目录 [README.md](../../README.md) 为准。

---

## 查阅顺序（与 AGENTS、中央库对齐）

1. 仓库级地图：[../../INDEX.md](../../INDEX.md)（Index Guide）、[../../README.md](../../README.md)、[../../AGENTS.md](../../AGENTS.md)
2. **本应用**导航：[INDEX.md](./INDEX.md)
3. 中央库设计与贡献：[../../system/DESIGN.md](../../system/DESIGN.md)、[../../system/CONTRIBUTING.md](../../system/CONTRIBUTING.md)；中央库索引：[../../system/INDEX.md](../../system/INDEX.md)
4. 各子目录 [knowledge/README.md](./knowledge/README.md)（按需下钻）

---

## 本应用范围（相对中央库）

| 本应用具备 | 说明 |
|------------|------|
| [knowledge/](./knowledge/) | 宪法层 + 四视角（与 `system/knowledge` 结构对齐；**联邦** SSOT，非中央库替代品） |
| [requirements/](./requirements/) | 需求交付包 `REQUIREMENT-{ID}/`；上游 analysis/solution 多在 **system/** 或兄弟仓 |
| [changelogs/](./changelogs/) | 应用侧变更记录与可选索引运维说明 |


| 通常在中央库 `system/` | 说明 |
|------------------------|------|
| [system/solutions/](../../system/solutions/) | 解决方案阶段 |
| [system/analysis/](../../system/analysis/) | 需求分析阶段 |
| [system/specs/](../../system/specs/) | 规约目录，各阶段引用 |

**推荐闭环**：本应用维护事实与交付物 → 归档 / 上行时按 [system/DESIGN.md](../../system/DESIGN.md) 与 `/knowledge-archive` 类工作流回写 `system/knowledge/`（若适用）。

---

## 快速导航

| 文档 | 说明 |
|------|------|
| [application_meta.yaml](./application_meta.yaml) | 应用知识库根目录索引（`knowledge` / `requirements` / `changelogs` 指针） |
| [INDEX.md](./INDEX.md) | 本应用索引（知识树、交付、变更） |
| [knowledge/README.md](./knowledge/README.md) | 四视角 + 宪法层入口 |
| [knowledge/knowledge_meta.yaml](./knowledge/knowledge_meta.yaml) | 本应用知识树元数据 |
| [requirements/README.md](./requirements/README.md) | 需求交付结构与示例 |
| [requirements/requirements_meta.yaml](./requirements/requirements_meta.yaml) | 需求交付元数据 |
| [changelogs/CHANGELOG.md](./changelogs/CHANGELOG.md) | 应用侧维护性变更记录 |
| [changelogs/changelogs_meta.yaml](./changelogs/changelogs_meta.yaml) | 变更日志目录元数据 |

### 各一级子目录元数据（YAML）

| 目录 | 元数据 |
|------|--------|
| [knowledge/](./knowledge/) | [knowledge_meta.yaml](./knowledge/knowledge_meta.yaml) |
| [requirements/](./requirements/) | [requirements_meta.yaml](./requirements/requirements_meta.yaml) |
| [changelogs/](./changelogs/) | [changelogs_meta.yaml](./changelogs/changelogs_meta.yaml) |
