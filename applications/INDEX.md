# 应用知识库 — 索引

本文件为 applications 的索引入口。结构与约定参照系统级知识库（见 `system/INDEX.md`、`system/DESIGN.md`），应用侧在此基础上做最小必要的补充。

---

## 一、应用知识结构

> 与 system 侧四视角保持一致；如需扩展，优先补充到 system（可复用）或在应用侧注明差异。

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

- 方案、分析与交付文档应按推荐命名与目录组织，便于与 system 映射与追踪。

---

## 三、关联与治理信息

- 治理与命名：参考 `system/knowledge/constitution/`
- 映射字段：参考 `system/INDEX.md`（映射速查）

---

## 四、快速导航与模板引用

- [README.md](./README.md)：applications 总览与入口
- [system/DESIGN.md](../system/DESIGN.md)
- [system/INDEX.md](../system/INDEX.md)
- [scripts/sdx-init.sh](../scripts/sdx-init.sh)

---
