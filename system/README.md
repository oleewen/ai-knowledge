# system — 系统知识库

`system/` 是本仓库的**系统级知识体**：稳定事实（knowledge）与 SDD 阶段文档（solutions → analysis → requirements）同层存放，供初始化脚本拷贝到目标项目的 `docs/system/`（路径以根目录 [README.md](../README.md) 为准）。

---

## 查阅顺序（与 AGENTS 对齐）

1. 仓库级地图：[INDEX.md](../INDEX.md)（Index Guide）、[README.md](../README.md)（命令与总览）、[AGENTS.md](../AGENTS.md)（Agent 契约）
2. 本树导航：[INDEX.md](./INDEX.md)
3. 设计与贡献：[DESIGN.md](./DESIGN.md)、[CONTRIBUTING.md](./CONTRIBUTING.md)
4. 各子目录 [README.md](./knowledge/README.md)（按需下钻）

---

## SDD 主线（五段）


| 步骤  | 目录                               | 产出 / 作用                                                   |
| --- | -------------------------------- | --------------------------------------------------------- |
| 0   | [knowledge/](./knowledge/)       | SSOT：宪法层 + 业务 / 产品 / 技术 / 数据四视角                           |
| 1   | [solutions/](./solutions/)       | `记录解决方案，SOLUTION-{ID}.md`                                 |
| 2   | [analysis/](./analysis/)         | `记录需求分析，REQUIREMENT-{ID}.md`（`parent` → Solution）         |
| 3   | [requirements/](./requirements/) | `记录需求版本，REQUIREMENT-{ID}/MVP-Phase-*/`（PRD / ADD / TDD 等） |
| 4   | [specs/](./specs/)               | 记录需求规约，接口 / 服务等规约（各阶段可引用）                                 |


闭环与运维：变更与里程碑记在 [changelogs/](./changelogs/)；应用向中央库登记见 [INDEX.md](./INDEX.md)「应用接入」；全库 AI 构建见 [INDEX.md](./INDEX.md)「AI 工作流」。

---

## 快速导航


| 文档                                                   | 说明                       |
| ---------------------------------------------------- | ------------------------ |
| [system_meta.yaml](./system_meta.yaml)               | `system/` 根目录索引（机器可读约定）   |
| [INDEX.md](./INDEX.md)                               | 本目录索引、映射速查、接入登记、AI 工作流指针 |
| [DESIGN.md](./DESIGN.md)                             | 原则、元模型、目录约定、映射字段、演进      |
| [CONTRIBUTING.md](./CONTRIBUTING.md)                 | 新增 / 修改规则与模板入口           |
| [knowledge/README.md](./knowledge/README.md)         | 四视角 + 宪法层入口              |
| [solutions/README.md](./solutions/README.md)         | 解决方案阶段                   |
| [analysis/README.md](./analysis/README.md)           | 需求分析阶段                   |
| [requirements/README.md](./requirements/README.md)   | 需求交付阶段                   |
| [specs/README.md](./specs/README.md)                 | 需求规约目录                   |
| [changelogs/CHANGELOG.md](./changelogs/CHANGELOG.md) | system 侧维护性变更记录          |

---

## 各一级子目录元数据（YAML）

细节以各文件为准；README 仅作导航引用。

| 目录 | 元数据 |
|------|--------|
| [knowledge/](./knowledge/) | [knowledge_meta.yaml](./knowledge/knowledge_meta.yaml) |
| [solutions/](./solutions/) | [solutions_meta.yaml](./solutions/solutions_meta.yaml) |
| [analysis/](./analysis/) | [analysis_meta.yaml](./analysis/analysis_meta.yaml) |
| [requirements/](./requirements/) | [requirements_meta.yaml](./requirements/requirements_meta.yaml) |
| [specs/](./specs/) | [specs_meta.yaml](./specs/specs_meta.yaml) |
| [changelogs/](./changelogs/) | [changelogs_meta.yaml](./changelogs/changelogs_meta.yaml) |


