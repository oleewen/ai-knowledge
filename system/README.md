---
type: Documentation Root
tags: [governance]
title: "系统知识库（顶层 `system/`）"
---
# 系统知识库（顶层 `system/`）

本目录为 **目标态下的「系统知识库」语义**：组织级视图、架构文档与 **`application-{name}/`** 联邦槽位（应用镜像经 [`/docs-pull`](../agent/skills/docs-pull/SKILL.md) 同步）。

## 子目录

| 路径 | 说明 |
|------|------|
| [DESIGN.md](DESIGN.md) | 设计边界、SSOT 继承矩阵、同步闭环与 SDD 阶段链 |
| [INDEX_GUIDE.md](INDEX_GUIDE.md) | Agent 九章机器索引（本 `system/` 文档根） |
| [docs-meta.md](docs-meta.md) | 目录元数据与 SSOT 指针 |
| [knowledge-links.yaml](knowledge-links.yaml) | 联邦应用建联清单 |
| [agent/knowledge/knowledge-governance.md](../agent/knowledge/knowledge-governance.md) | 治理与命名 SSOT：术语边界、槽位约定 |
| [knowledge/README.md](knowledge/README.md) | 五视角架构索引（业务 / 产品 / 应用 / 数据 / 技术） |
| [adr/README.md](adr/README.md) | 系统层 ADR 正文目录 |
| [solutions/README.md](solutions/README.md) | SDD 解决方案阶段：产出 `SOLUTION-{IDEA-ID}.md`，作为 analysis 上游输入 |
| [analysis/README.md](analysis/README.md) | SDD 需求分析阶段：产出 `ANALYSIS-{IDEA-ID}.md`，衔接 solutions 与 requirements |
| [requirements/README.md](requirements/README.md) | SDD 需求交付：按 `REQUIREMENT-{IDEA-ID}/` 组织 PRD、ASD、DSD、TDD 等阶段产物 |
| [application-APPNAME/README.md](application-APPNAME/README.md) | 联邦应用槽位占位；真实应用名替换 `APPNAME`，内容经 `/docs-pull` 填入 |
| [changelogs/README.md](changelogs/README.md) | 变更留痕与索引运维：`CHANGE-LOG.md`、`INDEXING-LOG.md`（docs-change / docs-indexing） |

## 阅读顺序

1. [DESIGN.md](DESIGN.md) — 目录契约与 SSOT 继承  
2. [knowledge/README.md](knowledge/README.md) — 五视角索引入口  
3. [knowledge/business/README.md](knowledge/business/README.md) / [knowledge/product/README.md](knowledge/product/README.md) — 业务与产品语境  
4. [knowledge/application/README.md](knowledge/application/README.md) / [knowledge/data/README.md](knowledge/data/README.md) / [knowledge/technical/README.md](knowledge/technical/README.md) — 系统、数据与技术落地  

与公司知识库侧 [`../company/knowledge/`](../company/knowledge/README.md) 对照阅读。
