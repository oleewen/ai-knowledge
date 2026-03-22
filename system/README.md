# system — 系统知识库

`system/` 是本仓库的**系统级知识体**：维护全局稳定事实（knowledge）与 SDD 阶段文档（solutions → analysis → requirements），保持同层存放，囊括了存放于 `applications/` 下的各应用知识库。

---

## 查阅顺序（与 AGENTS 对齐）

1. 仓库级地图：[INDEX_GUIDE.md](../INDEX_GUIDE.md)（Index Guide；[PROJECT_INDEX.md](../PROJECT_INDEX.md) 短入口）、[README.md](../README.md)（命令与总览）、[AGENTS.md](../AGENTS.md)（Agent 契约）
2. 本树导航：[SYSTEM_INDEX.md](./SYSTEM_INDEX.md)（`INDEX.md` 为短入口）
3. 设计与贡献：[DESIGN.md](./DESIGN.md)、[CONTRIBUTING.md](./CONTRIBUTING.md)
4. 各子目录 [knowledge/](./knowledge/)、[solutions/](./solutions/) 、[analysis/](./analysis/) 、[requirements/](./requirements/) （按需下钻）；接口/数据等规约落在各 `REQUIREMENT-{ID}/…/specs/` 或 [knowledge/technical/](./knowledge/technical/)

---

## SDD 主线（四段 + 规约落位）


| 步骤  | 目录                               | 产出 / 作用                                                   |
| --- | -------------------------------- | --------------------------------------------------------- |
| 0   | [knowledge/](./knowledge/)       | SSOT：宪法层 + 业务 / 产品 / 技术 / 数据四视角                           |
| 1   | [solutions/](./solutions/)       | `记录解决方案，SOLUTION-{ID}.md`                                 |
| 2   | [analysis/](./analysis/)         | `记录需求分析，ANALYSIS-{ID}.md`（`parent` → Solution）            |
| 3   | [requirements/](./requirements/) | `记录需求版本，REQUIREMENT-{ID}/MVP-Phase-*/`（PRD / ADD / TDD、按需 `specs/`） |


闭环与运维：变更与里程碑记在 [changelogs/](./changelogs/)；应用向中央库登记见 [SYSTEM_INDEX.md](./SYSTEM_INDEX.md)「应用接入」；全库 AI 构建见 [SYSTEM_INDEX.md](./SYSTEM_INDEX.md)「AI 工作流」。

---

## 快速导航


| 文档                                                   | 说明                       |
| ---------------------------------------------------- | ------------------------ |
| [system_meta.yaml](./system_meta.yaml)               | `system/` 根目录索引（机器可读约定）  |
| [SYSTEM_INDEX.md](./SYSTEM_INDEX.md)                 | 本目录索引、映射速查、接入登记、AI 工作流指针 |
| [DESIGN.md](./DESIGN.md)                             | 原则、元模型、目录约定、映射字段、演进      |
| [CONTRIBUTING.md](./CONTRIBUTING.md)                 | 新增 / 修改规则与模板入口           |
| [knowledge/README.md](./knowledge/README.md)         | 四视角 + 宪法层入口              |
| [solutions/README.md](./solutions/README.md)         | 解决方案阶段                   |
| [analysis/README.md](./analysis/README.md)           | 需求分析阶段                   |
| [requirements/README.md](./requirements/README.md)   | 需求交付阶段（含各需求包内规约 `specs/`） |
| [changelogs/CHANGELOG.md](./changelogs/CHANGELOG.md) | system 侧维护性变更记录          |


---

## 各一级子目录元数据（YAML）

细节以各文件为准；README 仅作导航引用。


| 目录                               | 元数据                                                             |
| -------------------------------- | --------------------------------------------------------------- |
| [knowledge/](./knowledge/)       | [knowledge_meta.yaml](./knowledge/knowledge_meta.yaml)          |
| [solutions/](./solutions/)       | [solutions_meta.yaml](./solutions/solutions_meta.yaml)          |
| [analysis/](./analysis/)         | [analysis_meta.yaml](./analysis/analysis_meta.yaml)             |
| [requirements/](./requirements/) | [requirements_meta.yaml](./requirements/requirements_meta.yaml) |
| [changelogs/](./changelogs/)     | [changelogs_meta.yaml](./changelogs/changelogs_meta.yaml)       |


