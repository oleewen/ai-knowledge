---
type: Documentation
title: application（应用知识库，mode=s）
---
# application（应用知识库，mode=s）

`application/` 维护应用侧稳定事实、实现登记与阶段交付物，是全仓库的重要知识中枢。  
本文件面向知识库安装 standalone（独立安装模式）（`mode=s`）阅读与维护场景，回答「在 `application/` 里按什么顺序读、到哪里写」；九章机器索引与 **中央知识库挂载建联登记**见 [INDEX-GUIDE.md](INDEX-GUIDE.md)。

## 推荐阅读路径

1. [INDEX-GUIDE.md](INDEX-GUIDE.md)：九章索引（docs-indexing 产出）、文末 **「十、中央知识库接入工程」** 为中央知识库挂载建联之登记
2. [DESIGN.md](DESIGN.md)：元模型与跨视角关系
3. [CONTRIBUTING.md](CONTRIBUTING.md)：新增/修改流程与模板约束

## SDD 文档流（一页纸）

```text
knowledge（实体登记、实现映射与应用层实体主库）
    ↑ 蒸馏 / 回写（如 docs-distill）
    │
solutions ──→ analysis ──→ requirements
    │              │              │
    └──────────────┴──────────────┴──→ 规约：需求包内 specs/ 或 knowledge/application/（可选）
```

**推荐落地顺序**：先查 / 补 **knowledge** 实体与 ID（读 [DESIGN.md](DESIGN.md)、[CONTRIBUTING.md](CONTRIBUTING.md)）→ 写 **solutions** / **analysis** → 建 **requirements** 包；规约与 `ANALYSIS-*` 对齐 **IDEA-ID**。

## 阶段流转（SDD）

| 阶段 | 目录 | 主要产物 |
|------|------|----------|
| 知识基线 | [agent/knowledge/](../agent/knowledge/knowledge-governance.md)、[knowledge](knowledge) | 治理规则、五视角实体登记与应用层实体 |
| 方案阶段 | [solutions](solutions) | `SOLUTION-{IDEA-ID}.md` |
| 分析阶段 | [analysis](analysis) | `ANALYSIS-{IDEA-ID}.md` |
| 交付阶段 | [requirements](requirements) | `REQUIREMENT-{IDEA-ID}/MVP-Phase-*`（PRD/ASD/DSD/TDD/`specs/`） |

变更留痕与索引运维见 [changelogs/README.md](changelogs/README.md)。

## 子目录入口

| 目录 | 入口说明 |
|------|----------|
| [knowledge/README.md](knowledge/README.md) | 五视角知识实体组织与映射规则 |
| [solutions/README.md](solutions/README.md) | 方案阶段编写规则 |
| [analysis/README.md](analysis/README.md) | 分析阶段编写规则 |
| [requirements/README.md](requirements/README.md) | 交付阶段结构与产物规则 |
| [changelogs/README.md](changelogs/README.md) | 变更记录与索引运维文件 |

## 机器可读元数据

- 根元数据：[docs-meta.md](docs-meta.md)
- 子目录元数据：`knowledge/knowledge-meta.md`（**solutions** / **analysis** / **requirements** / **changelogs** 见各目录 `README.md`）

> 约束细则以 `docs-meta.md` 与 `DESIGN.md` 为准，本文件不复写字段定义。
