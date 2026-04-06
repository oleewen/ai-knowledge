# system — 系统知识库

`system/` 负责维护系统层面的稳定事实与阶段交付物，是全仓库的知识中枢。  
本文件仅回答“在 `system/` 里按什么顺序读、到哪里写”，避免重复仓库根导航内容。

## 推荐阅读路径

1. [SYSTEM_INDEX.md](SYSTEM_INDEX.md)：先看目录总览、映射字段和接入位置
2. [DESIGN.md](DESIGN.md)：再看元模型与跨视角关系
3. [CONTRIBUTING.md](CONTRIBUTING.md)：最后看新增/修改流程与模板约束

## 阶段流转（SDD）

| 阶段 | 目录 | 主要产物 |
|------|------|----------|
| 知识基线 | [knowledge](knowledge) | 四视角与宪法层实体 |
| 方案阶段 | [solutions](solutions) | `SOLUTION-{IDEA-ID}.md` |
| 分析阶段 | [analysis](analysis) | `ANALYSIS-{IDEA-ID}.md` |
| 交付阶段 | [requirements](requirements) | `REQUIREMENT-{IDEA-ID}/MVP-Phase-*`（PRD/ADD/TDD/`specs/`） |

变更留痕与索引运维见 [changelogs/README.md](changelogs/README.md)。

## 子目录入口

| 目录 | 入口说明 |
|------|----------|
| [knowledge/README.md](knowledge/README.md) | 知识实体组织与映射规则 |
| [solutions/README.md](solutions/README.md) | 方案阶段编写规则 |
| [analysis/README.md](analysis/README.md) | 分析阶段编写规则 |
| [requirements/README.md](requirements/README.md) | 交付阶段结构与产物规则 |
| [changelogs/README.md](changelogs/README.md) | 变更记录与索引运维文件 |

## 机器可读元数据

- 根元数据：`system_meta.yaml`
- 子目录元数据：`knowledge_meta.yaml`、`solutions_meta.yaml`、`analysis_meta.yaml`、`requirements_meta.yaml`、`changelogs_meta.yaml`

> 约束细则以对应 YAML 与 `DESIGN.md` 为准，本文件不复写字段定义。
