# application — 应用知识库（mode=s）

`application/` 维护应用层面的稳定事实与阶段交付物，是全仓库的知识中枢。  
本文件面向 `docs-init --mode=standalone`（`mode=s`）阅读与维护场景，回答「在 `application/` 里按什么顺序读、到哪里写」；九章机器索引与 **central 登记**见 [INDEX_GUIDE.md](INDEX_GUIDE.md)。

## 推荐阅读路径

1. [INDEX_GUIDE.md](INDEX_GUIDE.md)：九章索引（docs-indexing 产出）、文末 **「十、中央知识库接入工程」** 为 `docs-init central` 登记
2. [DESIGN.md](DESIGN.md)：元模型与跨视角关系
3. [CONTRIBUTING.md](CONTRIBUTING.md)：新增/修改流程与模板约束

## SDD 文档流（一页纸）

```text
knowledge（SSOT）
    ↑ 归档 / 回写（如 docs-archive）
    │
solutions ──→ analysis ──→ requirements
    │              │              │
    └──────────────┴──────────────┴──→ 规约：需求包内 specs/ 或 knowledge/technical/（可选）
```

**推荐落地顺序**：先查 / 补 **knowledge** 实体与 ID（读 [DESIGN.md](DESIGN.md)、[CONTRIBUTING.md](CONTRIBUTING.md)）→ 写 **solutions** / **analysis** → 建 **requirements** 包；规约与 `ANALYSIS-*` 对齐 **IDEA-ID**。

## 阶段流转（SDD）

| 阶段 | 目录 | 主要产物 |
|------|------|----------|
| 知识基线 | [constitution](constitution/README.md)、[knowledge](knowledge) | 宪法层与四视角实体 |
| 方案阶段 | [solutions](solutions) | `SOLUTION-{IDEA-ID}.md` |
| 分析阶段 | [analysis](analysis) | `ANALYSIS-{IDEA-ID}.md` |
| 交付阶段 | [requirements](requirements) | `REQUIREMENT-{IDEA-ID}/MVP-Phase-*`（PRD/ADD/TDD/`specs/`） |

变更留痕与索引运维见 [changelogs/README.md](changelogs/README.md)。

## 子目录入口

| 目录 | 入口说明 |
|------|----------|
| [constitution/README.md](constitution/README.md) | 宪法层：术语、原则、标准、ADR |
| [knowledge/README.md](knowledge/README.md) | 四视角知识实体组织与映射规则 |
| [solutions/README.md](solutions/README.md) | 方案阶段编写规则 |
| [analysis/README.md](analysis/README.md) | 分析阶段编写规则 |
| [requirements/README.md](requirements/README.md) | 交付阶段结构与产物规则 |
| [changelogs/README.md](changelogs/README.md) | 变更记录与索引运维文件 |

## 机器可读元数据

- 根元数据：[docs_meta.yaml](docs_meta.yaml)
- 子目录元数据：`constitution/constitution_meta.yaml`、`knowledge_meta.yaml`、`solutions_meta.yaml`、`analysis_meta.yaml`、`requirements_meta.yaml`、`changelogs_meta.yaml`

> 约束细则以对应 YAML 与 `DESIGN.md` 为准，本文件不复写字段定义。
