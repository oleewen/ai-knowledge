# 应用知识库 — 索引

本文件为具体应用或微服务的知识库与交付文档入口。结构、约定与管理方式参照主系统知识库（见 [../../system/INDEX.md](../../system/INDEX.md)），并结合应用自身需求，细化各核心交付物。

---

## 一、应用知识结构 

> 建议与主库四视角（业务/产品/技术/数据）保持一致，如有特有视角、子域或模型可酌情扩展。

| 入口 | 说明 |
|------|------|
| [./knowledge/README.md](./knowledge/README.md) | 应用知识四视角与映射约定 |
| [./knowledge/business/](./knowledge/business/) | 应用级业务域/子域/聚合（BD/BC/AGG） |
| [./knowledge/product/](./knowledge/product/) | 产品线/模块/功能点/用例（PL/PM/FT/UC） |
| [./knowledge/technical/](./knowledge/technical/) | 应用子系统、服务、接口（APP/MS） |
| [./knowledge/data/](./knowledge/data/) | 业务主数据、实体、数据字典（ENT/DS） |

*可根据实际情况删减/补充，所有ID须保持全局唯一，跨仓库可追溯。*

---

## 二、应用方案与需求 (solutions, analysis, requirements)

| 入口 | 说明 |
|------|------|
| [./solutions/README.md](./solutions/README.md) | 应用级解决方案（SOLUTION-）及标准 |
| [./analysis/README.md](./analysis/README.md) | 需求分析（REQUIREMENT-） |
| [./requirements/README.md](./requirements/README.md) | 需求交付（PRD/ADD/TDD 等） |
| [./specs/](./specs/) | 详细接口/服务/数据规约 |

- 方案、分析与交付文档应按推荐命名与目录组织，方便与主知识库映射 & 自动化追踪。
- 可直接采用主库模板或自定义 `.ai/rules/` 补充校验要求。

---

## 三、关联与治理信息

- [application/_meta.yaml](./application/_meta.yaml)：应用基础元信息（含 id、命名、治理锚点等）
- [application/manifest.yaml](./application/manifest.yaml)：应用知识清单、接口规约等
- 如需补充联邦治理/命名规范/扩展知识字段，参考主库 constitution、standards、principles

---

## 四、快速导航与模板引用

- [README.md](./README.md)：应用知识库总览及快速初始化教程
- [system/DESIGN.md](../../system/DESIGN.md) — 知识库设计原则与结构说明
- [scripts/sdx-init.sh](../../scripts/sdx-init.sh) — 初始化工具
- [system/INDEX.md](../../system/INDEX.md) — 系统知识库映射与关系字段

---
